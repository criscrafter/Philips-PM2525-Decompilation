/* calibration.c (hand-cleaned) - calibration storage, recipes, coefficients, calibration run (S25)
 *
 * Original: 0x0111-0x0EDF, 0x10D1-0x146A, 0x16DC, 0x3B40-0x3E5B, 0x5B74-0x5B8A (78 functions).
 * Storage and recipe decoding verified on the real meter's RAM dump (tools/check_cal_backup.py,
 * tools/cal_recipes.py); the run flow is from the code (DECOMPILATION.md "Calibration run").
 *
 * RAM layout (XDATA, battery backed):
 *   0x0200-0x03C7  copy 1: 114 float slots          0x03C8  16-bit additive checksum
 *   0x03CF-0x0596  copy 2 (+0x1CF)                   0x0597
 *   0x059E-0x0765  copy 3 (+0x39E)                   0x0766
 *   0x076C-0x0771  counters (shared bytes: 0x0770 is also the "used default" flags, 0x0771 the
 *                  last fail code; the firmware really increments those as repair counters too)
 *   0x015F-0x0173  coefficient set 0: K0 K1 K2 K3 K4 K5;  0x0177 zero_eff, 0x017B gain_eff
 *   0x017F-0x0193  set 1 (second polarity),             0x0197 zero_eff, 0x019B gain_eff
 *   0x0119         internal temperature T (relative units, about 0.3-0.7)
 */
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

extern uint8_t xram[0x800];
extern uint8_t meter_state, meter_mode;
extern bool meter_autorange, cal_mode, cal_hot, cal_enable;
extern bool peak_mode_b0, peak_mode_b1;      /* 21h.6/21h.7 */
extern bool current_10a;                     /* 25h.6 */
extern bool cal_skip_verify;                 /* 23h.4: copies already checked this pass */

double xram_float(uint16_t a);
void   xram_store_float(uint16_t a, double v);
double rom_float(uint16_t a);
double range_nominal(void);                  /* range_param_lookup * 10^range_scale_exp */
int    range_scale_exp(void);
uint8_t nv_setting_read(uint8_t i, bool *bad);
void   nv_setting_write(uint8_t i, uint8_t v);
void   speed_load(void);
void   autorange_count_step(void);
void   lcd_show_message(uint16_t rom_text);
void   lcd_show_dashes(void);
void   lcd_refresh(void);
extern char lcd_text[18];                    /* XDATA 0x0000: text being shown */

#define CAL1 0x0200
#define CAL_SIZE 456
#define COPY2 0x01CF
#define COPY3 0x039E
#define T_INT 0x0119
#define SET0 0x015F
#define SET1 0x017F
enum { K0 = 0, K1 = 4, K2 = 8, K3 = 12, K4 = 16, K5 = 20, ZERO_EFF = 24, GAIN_EFF = 28 };

#define CNT_SUM1   0x076C   /* also diag_err_total */
#define CNT_SUM2   0x076D
#define CNT_SUM3   0x076E
#define CNT_REP1   0x076F
#define CNT_REP2   0x0770
#define CNT_REP3   0x0771
#define CAL_FALLBACK 0x0770
#define CAL_FAIL     0x0771

static double pow10i(int e) { double p = 1; for (; e > 0; e--) p *= 10; for (; e < 0; e++) p /= 10; return p; }
static unsigned func(void)  { return meter_state & 0x0F; }
static unsigned range(void) { return (meter_state >> 4) & 7; }
static uint8_t  fr(void)    { return meter_state & 0x7F; }        /* function | range << 4 */

static bool range_invalid;   /* 23h.7: coefficients of this range unusable -> NC */
static bool voting;          /* 27h.4: majority repair running, skip checksum refresh */
static bool cal_failed;      /* 2Ch.4 */

/* ======================================================================================== */
/* three copies                                                                              */
/* ======================================================================================== */

static uint16_t sum16(uint16_t a)
{
    uint16_t s = 0;
    for (int i = 0; i < CAL_SIZE; i++) s = (uint16_t)(s + xram[a + i]);
    return s;
}
static const uint16_t copy_base[3] = { CAL1, CAL1 + COPY2, CAL1 + COPY3 };

/* 0x091B / 0x0955 / 0x098F: store (store = true) or verify the checksum of one copy */
static bool cal_checksum(int copy, bool store)
{
    uint16_t a = copy_base[copy], s = sum16(a);
    if (store) { xram[a + CAL_SIZE] = (uint8_t)(s >> 8); xram[a + CAL_SIZE + 1] = (uint8_t)s; return true; }
    return xram[a + CAL_SIZE] == (uint8_t)(s >> 8) && xram[a + CAL_SIZE + 1] == (uint8_t)s;
}
static void cal_copy(int from, int to)                                       /* 0x0A41..0x0A7D */
{
    memmove(&xram[copy_base[to]], &xram[copy_base[from]], CAL_SIZE);
    cal_checksum(to, true);
}
static void count(uint16_t a) { xram[a]++; }

/* 0x09F0: byte-wise 2-of-3 vote over the whole block; the odd copy is repaired */
static void cal_majority_repair(void)
{
    for (int i = 0; i < CAL_SIZE; i++) {
        uint8_t *a = &xram[CAL1 + i], *b = a + COPY2, *c = a + COPY3;
        if (*a == *b)      { if (*c != *a) { *c = *a; count(CNT_REP3); } }
        else if (*a == *c) { *b = *a; count(CNT_REP2); }
        else if (*b == *c) { *a = *b; count(CNT_REP1); }
    }
}

/* run on every range change (first part of cal_load_range) */
static void cal_verify_copies(void)
{
    unsigned bad = 0;
    for (int k = 0; k < 3; k++) if (!cal_checksum(k, false)) bad |= 1u << k;
    switch (bad) {
    case 0: break;
    case 1: cal_copy(1, 0); count(CNT_SUM1); break;
    case 2: cal_copy(0, 1); count(CNT_SUM2); break;
    case 4: cal_copy(0, 2); count(CNT_SUM3); break;
    case 3: cal_copy(2, 1); cal_copy(1, 0); count(CNT_SUM2); count(CNT_SUM1); break;
    case 5: cal_copy(1, 0); cal_copy(0, 2); count(CNT_SUM1); count(CNT_SUM3); break;
    case 6: cal_copy(0, 1); cal_copy(0, 2); count(CNT_SUM2); count(CNT_SUM3); break;
    default: voting = true; cal_majority_repair(); break;       /* all three bad */
    }
}

/* 0x07A4 cal_ld_slot: read one 4-byte slot with a per-byte 2-of-3 vote, repairing the odd copy
 * (and its checksum). *no_majority (23h.7) when all three copies of a byte differ. */
double cal_ld_slot_vote(uint16_t a, bool *no_majority)
{
    *no_majority = false;
    for (int i = 0; i < 4; i++) {
        uint8_t *x = &xram[a + i], *y = x + COPY2, *z = x + COPY3;
        if (*x == *y)      { if (*z != *x) { *z = *x; if (!voting) cal_checksum(2, true); count(CNT_REP3); } }
        else if (*x == *z) { *y = *x; if (!voting) cal_checksum(1, true); count(CNT_REP2); }
        else if (*y == *z) { *x = *y; if (!voting) cal_checksum(0, true); count(CNT_REP1); }
        else { *no_majority = true; break; }
    }
    return xram_float(a);
}

/* 0x0877 cal_write_all_copies: each byte is written until it reads back (0x08AB), then the
 * checksum of that copy is refreshed */
void cal_write_all_copies(uint16_t a, double v)
{
    for (int k = 0; k < 3; k++) {
        uint16_t p = (uint16_t)(a + (k == 1 ? COPY2 : k == 2 ? COPY3 : 0));
        xram_store_float(p, v);                    /* original: write-verify loop per byte */
        cal_checksum(k, true);
    }
}

/* ======================================================================================== */
/* recipes                                                                                   */
/* ======================================================================================== */
/* cal_recipe_ptr (0x06F0): entry = cal_recipe_table (0x76A2) + cal_recipe_offsets[function]
 * (ROM 0x0738) + 4 * range; IDC/IAC on the 10 A input use range + 2. Entry: 16-bit pointer to the
 * records, step flags of set 0, step flags of set 1. Flag bit 7 = two records (two coefficient sets).
 *
 * Record (cal_record_layout 0x0754), all pointers 16-bit big-endian, < 0x0800 = cal slot, else a
 * ROM float constant:
 *   h0 h1  A[nA] B[nB] X C[nA+1] D[nD]        nA = (h0&1)+1, nB = (h0>>3)&7, nD = (h1>>3)&7
 *   h0 bit 1: A/C1 are ROM constants, bit 2: B0 is a constant; h1 bit 0: X, bit 1: C0, bit 2: D0
 *   h0 >> 6 / h1 >> 6: how many of the following B / D entries multiply (or subtract); the rest divide (add)
 */
extern const uint8_t  cal_recipe_table[];          /* ROM 0x76A2 (indexed from 0x76A2) */
extern const int16_t  cal_recipe_offsets[14];      /* ROM 0x0738 */
uint8_t rom_byte(uint16_t a);

static uint16_t recipe_entry(void)
{
    unsigned r = range();
    if ((func() == 6 || func() == 7) && current_10a) r += 2;
    return (uint16_t)(0x76A2 + cal_recipe_offsets[func()] + 4 * r);
}
static uint16_t rd16(uint16_t a) { return (uint16_t)(rom_byte(a) << 8 | rom_byte((uint16_t)(a + 1))); }

/* 0x0B0B: flag byte of the current range (A = entry byte 2, set 0) and of set 1 (B = entry
 * byte 3, used for Vp- and negative VDC); 0 for Vpp (peak kind 3) */
uint8_t cal_point_flags_set1;
uint8_t cal_point_flags(void)
{
    if (func() == 0 && peak_mode_b0 && peak_mode_b1) return 0;
    cal_point_flags_set1 = rom_byte((uint16_t)(recipe_entry() + 3));
    return rom_byte((uint16_t)(recipe_entry() + 2));
}

typedef struct { uint8_t h0, h1; uint16_t A, B, X, C, D; uint8_t nA, nB, nD; uint16_t end; } record_t;

static record_t record_at(uint16_t a)
{
    record_t r;
    r.h0 = rom_byte(a); r.h1 = rom_byte((uint16_t)(a + 1));
    r.nA = (uint8_t)((r.h0 & 1) + 1); r.nB = (r.h0 >> 3) & 7; r.nD = (r.h1 >> 3) & 7;
    r.A = (uint16_t)(a + 2);
    r.B = (uint16_t)(r.A + 2 * r.nA);
    r.X = (uint16_t)(r.B + 2 * r.nB);
    r.C = (uint16_t)(r.X + 2);
    r.D = (uint16_t)(r.C + 2 * (r.nA + 1));
    r.end = (uint16_t)(r.D + 2 * r.nD);
    return r;
}

/* limits for the loaded coefficients: [lo, hi] (XDATA 0x079E / 0x079A in the original) */
typedef struct { double lo, hi; } window_t;

/* a pointer of the recipe: slot (with vote and limit check) or ROM constant */
static bool load_term(uint16_t ptr, bool constant, window_t w, bool check, double *v)
{
    bool bad;
    if (constant || ptr >= 0x0800) { *v = rom_float(ptr); return true; }
    *v = cal_ld_slot_vote(ptr, &bad);
    if (bad) return false;
    return !check || (*v >= w.lo && *v < w.hi);
}

/* cal_f_zero 0x0453 / cal_f_zero_tslope 0x057F: product of 1 or 2 terms */
static bool coef_product(uint16_t list, uint8_t n, bool constant, window_t w, double *out)
{
    double v, t;
    if (!load_term(rd16(list), constant, w, false, &v)) return false;
    if (n == 2) { if (!load_term(rd16((uint16_t)(list + 2)), false, w, false, &t)) return false; v *= t; }
    if (!(v >= w.lo && v < w.hi)) return false;
    *out = v;
    return true;
}

/* cal_f_gain 0x0496 (mul/div) and cal_f_gain_tslope 0x05C2 (sub/add) */
static bool coef_chain(uint16_t list, uint8_t n, uint8_t n_first_op, bool constant, window_t w,
                       bool additive, double *out)
{
    double v, t;
    if (!load_term(rd16(list), constant, w, true, &v)) return false;
    for (uint8_t i = 1; i < n; i++) {
        if (!load_term(rd16((uint16_t)(list + 2 * i)), false, w, true, &t)) return false;  /* each term checked */
        bool first_op = i <= n_first_op;
        if (additive) v = first_op ? v - t : v + t;
        else          v = first_op ? v * t : v / t;
    }
    *out = v;
    return true;
}

/* evaluate coefficient k (0..5) of one record. A failed term gives the default in calibration mode
 * (and records it in 0x0770 bits 1-6), otherwise makes the whole range invalid. */
static const double k_default[6] = { 0.0, 1.0, 0.5, 0.5, 0.0, 0.0 };

static double eval_coef(const record_t *r, int k, window_t w)
{
    double v = 0;
    bool ok;
    switch (k) {
    case 0: ok = coef_product(r->A, r->nA, r->h0 & 2, w, &v); break;
    case 1: ok = r->nB ? coef_chain(r->B, r->nB, r->h0 >> 6, r->h0 & 4, w, false, &v) : (v = 1, true); break;
    case 2: ok = load_term(rd16(r->X), r->h1 & 1, w, true, &v); break;
    case 3: ok = load_term(rd16(r->C), r->h1 & 2, w, true, &v); break;
    case 4: ok = coef_product((uint16_t)(r->C + 2), r->nA, r->h0 & 2, w, &v); break;
    default: ok = r->nD ? coef_chain(r->D, r->nD, r->h1 >> 6, r->h1 & 4, w, true, &v) : (v = 0, true); break;
    }
    if (ok) return v;
    if (cal_mode) { xram[CAL_FALLBACK] |= (uint8_t)(2 << k); return k_default[k]; }
    range_invalid = true;
    return 0;
}

/* 0x0ADC: hot slope limit, 0.5 (5 for Ohm2W 2 MOhm/20 MOhm and 2 VAC... fr 0x65, 0x55, 0x29) */
static double slope_limit(void) { return (fr() == 0x65 || fr() == 0x55 || fr() == 0x29) ? 5.0 : 0.5; }

/* 0x0111 cal_load_range: verify the copies, then evaluate K0..K5 of each set of the current range */
void cal_load_range(void)
{
    range_invalid = false;
    if (!cal_skip_verify) {
        voting = false;
        cal_verify_copies();
    }
    double nom = range_nominal();
    if ((meter_state & 0x0C) == 0 && (meter_state & 0x40)) nom *= 2;   /* exponent +1 */
    double sl = slope_limit();
    window_t w[6] = {
        { -0.2 * nom, 0.2 * nom },                            /* K0 zero       (0x0782/0x0786) */
        fr() == 0x65 ? (window_t){ 0.75, 1.5 } : (window_t){ 0.8, 1.2 },  /* K1 gain */
        { 0.3, 0.7 }, { 0.3, 0.7 },                           /* K2 K3 reference temperatures */
        { -0.5 * nom, 0.5 * nom },                            /* K4 zero slope (0x078A/0x078E) */
        { -sl, sl },                                          /* K5 gain slope (0x0792/0x0796) */
    };
    xram[CAL_FALLBACK] = 0;
    uint16_t e = recipe_entry();
    bool two_sets = rom_byte((uint16_t)(e + 2)) & 0x80;
    record_t r0 = record_at(rd16(e)), r1 = record_at(r0.end);
    for (int k = 0; k < 6 && !range_invalid; k++) {
        xram_store_float((uint16_t)(SET0 + 4 * k), eval_coef(&r0, k, w[k]));
        if (two_sets) xram_store_float((uint16_t)(SET1 + 4 * k), eval_coef(&r1, k, w[k]));
    }
    if (range_invalid)                                        /* both sets: defaults, range shows NC */
        for (int k = 0; k < 6; k++) {
            xram_store_float((uint16_t)(SET0 + 4 * k), k_default[k]);
            xram_store_float((uint16_t)(SET1 + 4 * k), k_default[k]);
        }
}

/* 0x0642 cal_adjust_slot: write a new value into the slot that coefficient k of the current
 * recipe reads (K0: A0, K1: B0, K2: X, K3: C0, K4: C1, K5: D0); set 1 when `second` (2Fh.7).
 * The original halts (endless loop) if that field is a constant or the recipe has several
 * terms there: the calibration flags never allow such a step. */
void cal_adjust_slot(int k, bool second, double v)
{
    uint16_t e = recipe_entry();
    record_t r = record_at(rd16(e));
    if (second) r = record_at(r.end);
    uint16_t field[6] = { r.A, r.B, r.X, r.C, (uint16_t)(r.C + 2), r.D };
    cal_write_all_copies(rd16(field[k]), v);
}

/* ======================================================================================== */
/* applying the coefficients                                                                 */
/* ======================================================================================== */

/* 0x12BD: zero_eff = K0 + K4 (T - K2), gain_eff = K1 + K5 (T - K3). During a cold calibration the
 * plain K0/K1 are used. */
static void cal_temp_compensate(uint16_t set)
{
    double T = xram_float(T_INT);
    double k[6];
    for (int i = 0; i < 6; i++) k[i] = xram_float((uint16_t)(set + 4 * i));
    bool comp = !cal_mode || cal_hot;
    xram_store_float((uint16_t)(set + ZERO_EFF), comp ? k[0] + k[4] * (T - k[2]) : k[0]);
    xram_store_float((uint16_t)(set + GAIN_EFF), comp ? k[1] + k[5] * (T - k[3]) : k[1]);
}
void cal_compute_effective(void)                                             /* 0x12A2 */
{
    cal_temp_compensate(SET0);
    if (func() == 0 || func() == 1 || func() == 9) cal_temp_compensate(SET1);
}

/* 0x16DC: value = (raw - zero_eff) * gain_eff; set 1 for Vp-, negative VDC and CAP in SPEED 3 */
double cal_apply(double raw, bool vpeak_second)
{
    bool s1 = (func() == 0 && vpeak_second) || (func() == 1 && raw < 0) || (func() == 9 && (meter_mode & 2));
    uint16_t set = s1 ? SET1 : SET0;
    return (raw - xram_float((uint16_t)(set + ZERO_EFF))) * xram_float((uint16_t)(set + GAIN_EFF));
}

/* ======================================================================================== */
/* internal temperature                                                                      */
/* ======================================================================================== */
static bool temp_in_range(double t) { return t >= 0.31 && t < 0.69; }        /* 0x0D77 */
static double temp_filter(double old, double nw) { return 0.8 * old + 0.2 * nw; }  /* 0x146A */

void internal_temp_init(void) { xram[T_INT] = 0; xram[T_INT + 1] = 0x80; }    /* 0x10D1 */

/* 0x1359: T = count / 2000, ignored outside 0.31..0.69; small steps (< 0.01) are filtered,
 * larger ones taken directly */
void internal_temp_update(int32_t count)
{
    double t = count / 2000.0, old = xram_float(T_INT);
    if (!temp_in_range(t)) return;
    if (t - old < 0.01 && old - t < 0.01) {
        xram_store_float(T_INT, temp_filter(old, t));
        /* also: 2Dh.4 set unless 2Dh.3, 2Dh.6 cleared unless 2Dh.7, 2Ch.6 and 22h.3 set */
    } else {
        xram_store_float(T_INT, t);
    }
}

/* ======================================================================================== */
/* calibration run                                                                           */
/* ======================================================================================== */
static void cal_fail(uint8_t code) { xram[CAL_FAIL] = code; cal_failed = true; }   /* 0x0EDF */

static uint8_t step_flags;       /* 39h: cal_point_flags of the range */
static bool    is_zero_point;    /* 2Fh.6 */
static bool    use_set1;         /* 2Fh.7 */
static bool    classify_failed;  /* 2Ah.3 */
static double  step_nominal;     /* 4Bh: nominal, negated for functions that read negative */
extern uint8_t cal_try_count;    /* bank 3 R2 */

/* 0x0B3E cal_classify_input: returns 0 if the step is allowed, else fail code 1..9 */
static uint8_t cal_classify_input(double raw, bool vpeak_second)
{
    double nom = range_nominal();
    if (func() == 4 || func() == 5) nom /= 2;                 /* exponent -1 */
    else if (func() == 11) nom = 100;                         /* Pt100 */
    else if (fr() == 0x42) nom = 600;                         /* VAC 2 V? range 4 of VAC: 600 */
    xram_store_float(0x07A2, nom);

    double lo, hi;                                            /* gain window, x nominal */
    if (func() == 1 || func() == 10) { lo = 0.90; hi = 1.10; }
    else if (fr() == 0x65)           { lo = 0.68; hi = 1.32; }
    else                             { lo = 0.81; hi = 1.19; }

    uint8_t code = 0;
    double a = raw < 0 ? -raw : raw;
    if (func() == 0 && raw <= -100.0 * pow10i(range_scale_exp())) code = 1;   /* Vpeak: input too negative */
    else if (a >= 0.099 * nom) {                              /* gain point */
        is_zero_point = false;
        if (a < lo * nom)       code = 2;
        else if (a >= hi * nom) code = 3;
        else if (func() == 5 || func() == 4 || func() == 11 || func() == 6 || func() == 12 ||
                 func() == 2 || func() == 7) { if (raw >= 0) code = 4; else nom = -nom; }  /* these read negative */
        else if (func() != 1 && raw < 0) code = 5;
    } else {
        is_zero_point = true;
    }
    if (!code) {
        if ((func() == 0 && vpeak_second) || (func() == 1 && !is_zero_point && raw < 0)) {
            use_set1 = true;
            step_flags = cal_point_flags_set1;          /* set 1 has its own step flags */
        }
        if (!is_zero_point) code = cal_hot ? (step_flags & 0x20 ? 0 : 9) : (step_flags & 0x02 ? 0 : 8);
        else                code = cal_hot ? (step_flags & 0x10 ? 0 : 7) : (step_flags & 0x01 ? 0 : 6);
    }
    step_nominal = nom;
    if (code) { if (classify_failed) cal_failed = true; classify_failed = true; }
    else classify_failed = false;
    return code;
}

/* stability window per function: table 0x0D0B (0.5, 0.05 for VDC, 0.15 for TempC; 5 for fr 0x65)
 * times 10^range_scale_exp */
extern const uint16_t cal_window_table[14];
static double stability_window(void)
{
    double w = fr() == 0x65 ? 5.0 : rom_float(cal_window_table[func()]);
    return w * pow10i(range_scale_exp());
}

static bool gain_ok(double g)                                                /* 0x0D23 */
{
    double lo = fr() == 0x65 ? 0.75 : 0.8, hi = fr() == 0x65 ? 1.5 : 1.2;
    return g < 0.99 * hi && g >= 1.01 * lo;
}

static void cal_step_gain(double raw);

/* 0x0D8D cal_step_zero: entry of every calibration step (also for gain points) */
void cal_step_zero(double raw, bool vpeak_second, bool temp_unsettled)
{
    if (temp_unsettled && (func() == 1 || func() == 4 || func() == 5 || func() == 6 || func() > 10)) {
        cal_fail(0x21); return;
    }
    double T = xram_float(T_INT);
    if (!temp_in_range(T)) { cal_fail(0x22); return; }
    use_set1 = is_zero_point = false;
    step_flags = cal_point_flags();
    uint8_t code = cal_classify_input(raw, vpeak_second);
    if (cal_failed) { cal_fail(code); return; }

    if (!classify_failed) {
        /* three agreeing readings: this one and the two before (XDATA 0x019F, 0x01CD) */
        double prev1 = xram_float(0x019F), prev2 = xram_float(0x01CD), w = stability_window();
        if (++cal_try_count > 2) {
            bool stable = (raw - prev1 < w && prev1 - raw < w) && (raw - prev2 < w && prev2 - raw < w);
            if (stable) {
                if (!is_zero_point) { cal_step_gain(raw); return; }
                if (!cal_hot) {
                    cal_adjust_slot(0, use_set1, raw);                       /* K0 */
                    if (step_flags & 0x04) cal_adjust_slot(2, use_set1, T);  /* K2 = T */
                    return;
                }
                uint16_t set = use_set1 ? SET1 : SET0;
                double dT = T - xram_float((uint16_t)(set + K2));
                if (dT < 0.01 && dT > -0.01) { xram[CAL_FAIL] = 0x0C; cal_failed = true; return; }
                double slope = (raw - xram_float((uint16_t)(set + K0))) / dT;
                double lim = 0.5 * xram_float(0x07A2);     /* limit direction inferred: Ghidra lost the carry here */
                if (!(slope < lim && slope > -lim)) { cal_fail(0x0B); return; }
                cal_adjust_slot(4, use_set1, slope);                         /* K4 */
                return;
            }
            if (cal_try_count > 29) { cal_fail(0x12); return; }
        }
        xram_store_float(0x01CD, prev1);
        xram_store_float(0x019F, raw);
    }
    autorange_count_step();
}

/* 0x0EE6 */
static void cal_step_gain(double raw)
{
    uint16_t set = use_set1 ? SET1 : SET0;
    double nom = step_nominal;
    if (use_set1 && func() == 1) nom = -nom;                  /* -20 V point */
    if (!cal_hot) {
        double g = nom / (raw - xram_float((uint16_t)(set + K0)));
        if (!gain_ok(g)) { cal_fail(0x0E); return; }
        cal_adjust_slot(1, use_set1, g);                                     /* K1 */
        if (step_flags & 0x08) cal_adjust_slot(3, use_set1, xram_float(T_INT));   /* K3 = T */
        return;
    }
    double dT = xram_float(T_INT) - xram_float((uint16_t)(set + K3));
    if (dT < 0.01 && dT > -0.01) { xram[CAL_FAIL] = 0x0C; cal_failed = true; return; }
    double g = nom / (raw - xram_float((uint16_t)(set + ZERO_EFF)));
    if (!gain_ok(g)) { cal_fail(0x10); return; }
    double slope = (g - xram_float((uint16_t)(set + K1))) / dT;
    double lim = slope_limit();
    if (!(slope < 0.99 * lim && slope > -0.99 * lim)) { cal_fail(0x11); return; }
    cal_adjust_slot(5, use_set1, slope);                                     /* K5 */
}

/* ======================================================================================== */
/* calibration mode display and seal                                                         */
/* ======================================================================================== */

/* 0x3B40: steps possible in this range for the selected cold/hot calibration */
static uint8_t cal_step_allowed(void)
{
    uint8_t f = cal_point_flags();
    return cal_hot ? (f & 0x30) : (f & 0x7F);
}

/* 0x3B9A cal_show_status: in calibration mode the display shows the input to apply as a code
 * (" 000000C", " 100000C", " 200000C", "  60000C": the digit pattern of the nominal value) or
 * dashes. If the range has no step for the selected cold/hot calibration, the last two characters
 * before the '#' end marker become "NA" (before a '.' if there is one): this is the manual's "nA". */
void cal_show_status(bool display_busy)   /* NA: also, a trigger in cal mode is refused (0x442C) */
{
    if (display_busy) return;                                 /* 26h.1 */
    unsigned f = func(), r = range();
    if (f < 4) {
        if (fr() == 0x42) lcd_show_message(0x71C4);           /* VAC range 4: 600 V */
        else lcd_show_message(r == 4 ? 0x71A9 : 0x71B2);
    } else switch (f) {
        case 4:  lcd_show_message(r == 1 || r == 2 ? 0x71A9 : 0x71B2); break;
        case 5:  lcd_show_message(r > 2 ? 0x71A9 : 0x71B2); break;
        case 6: case 7: case 10: lcd_show_message(0x71A9); break;
        case 8: case 13: lcd_show_dashes(); break;
        case 9: case 12: lcd_show_message(0x71B2); break;
        case 11: lcd_show_message(0x71A0); break;
        default: break;
    }
    lcd_refresh();
    if (cal_step_allowed() == 0) {
        for (int i = 0; i < 18; i++)
            if (lcd_text[i] == '#') {
                int p = lcd_text[i - 2] == '.' ? i - 3 : i - 2;
                lcd_text[p] = 'N';
                lcd_text[i - 1] = 'A';
                break;
            }
    }
}
void cal_status_or_dashes(void) { if (!cal_mode) lcd_show_dashes(); else cal_show_status(false); }   /* 0x3CB7 */

/* 0x3E5B: enter calibration mode (CAL ON,n). Autorange off; with internal trigger the trigger
 * becomes external (2) and slot x384 is cleared in all copies. */
void cal_mode_enter(void)
{
    speed_load();
    cal_mode = true;
    meter_autorange = false;
    if ((meter_mode & 0x0C) == 0) {
        meter_mode = (uint8_t)((meter_mode & 0xF3) | 0x08);
        cal_write_all_copies(0x0384, 0.0);
    }
}

/* 0x5B74 / 0x5B86 / 0x5B8A: seal byte (settings byte 4): 'N' normal, 'a' altered (CDP S).
 * Anything else, or a failed vote, is reset to 'N'. Returns true when sealed normal. */
bool cal_seal_ok(void)
{
    bool bad;
    uint8_t v = nv_setting_read(4, &bad);
    if (!bad && (v == 'a' || v == 'N')) return v == 'N';
    nv_setting_write(4, 'N');
    return true;
}
void cal_seal_normal(void)  { nv_setting_write(4, 'N'); }
void cal_seal_altered(void) { nv_setting_write(4, 'a'); }
