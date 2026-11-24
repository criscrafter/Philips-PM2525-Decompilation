/* measure.c (hand-cleaned) - measurement engine (firmware S25)
 *
 * Original: 0x0ABF, 0x1009-0x2A7F, 0x3AE2-0x3F8D, 0x48A7, 0x550C, 0x5BCB-0x5DF1 (93 functions,
 * 6199 bytes). This file follows the original's structure and data flow at the semantic level;
 * the hardware sequencing (motor switch, OQ0071 commands, timer set-up) is summarised where the
 * generated src/measure.c is the better reference. Constants are the ROM values (addresses given).
 *
 * Phases (task_measure, one step per main-loop pass, context XDATA 0x00BE <-> IRAM 2Ah-37h):
 *   switch  (2Ch.0)  motor switch to the function's position, analog latches, settle time
 *   acquire (2Ch.1)  start an ADC cycle / timer measurement
 *   process (2Ch.2)  count -> value, ranging, calibration, filtering, result
 * Numbers: counts are 24-bit integers, values pm_float (double here).
 */
#include <stdbool.h>
#include <stdint.h>
#include <math.h>

extern uint8_t meter_state, meter_mode;      /* 20h, 21h */
extern bool meter_autorange, cal_mode, cal_enable, db_mode, zero_mode;
extern bool peak_mode_b0, peak_mode_b1, current_10a, trigger_pending;
extern uint8_t xram[0x800];

double  xram_float(uint16_t a);
void    xram_store_float(uint16_t a, double v);
int32_t xram_i24(uint16_t a);
void    xram_store_i24(uint16_t a, int32_t v);
uint8_t rms_get_byte(void);
double  cal_apply(double raw, bool vpeak_second);
void    cal_load_range(void);
void    cal_compute_effective(void);
void    cal_step_zero(double raw, bool vpeak_second, bool temp_unsettled);
void    cal_fail_code(uint8_t c);
void    internal_temp_update(int32_t count);
void    internal_temp_from_count(int32_t count);
void    internal_temp_track(int32_t count);
void    adc_send_cmd(uint8_t cmd);           /* OQ0071 on I2C bus B */
void    probe_set_bit0(bool v);              /* PCF8574 0x4E on bus A */
void    lcd_show_message(uint16_t rom_text);
void    diag_count_event(uint8_t id);
void    P1_2_watchdog_pulse(void);         /* P1.2 low/high: external watchdog */
void    iface_report_status(void);
bool    cal_step_allowed_c(void);            /* carry: no step allowed */
extern const uint8_t speed_ranges[14][3];   /* 0x6ED4 */

static unsigned func(void)  { return meter_state & 0x0F; }
static unsigned range(void) { return (meter_state >> 4) & 7; }
static unsigned speed(void) { return meter_mode & 3; }    /* 0 SPEED 1, 1 SPEED 2, 2 SPEED 3 */
static bool fast(void)      { return speed() == 2; }
static bool summing(void)   { return speed() == 0 && func() != 10; }   /* SPEED 1: 10 conversions */

static double pow10i(int e) { double p = 1; for (; e > 0; e--) p *= 10; for (; e < 0; e++) p /= 10; return p; }

/* ---- status of the conversion being processed (bits in the swapped context) ---------------- */
static bool overload;        /* 2Dh.1  'O' */
static bool crest;           /* 2Dh.0  'C' (P3.4 latch) */
static bool cal_step_failed; /* 2Ch.4  'F' */
static bool not_settled;     /* 2Bh.6  'R' */
extern bool range_invalid;   /* 23h.7  'N' (calibration.c) */
static bool db_underflow;    /* 2Bh.5  'U' */
static bool complete;        /* 2Eh.2  last conversion of a reading (SPEED 1: the 10th) */
static bool result_ok;       /* 2Bh.4  reading usable */
static uint8_t unstable_count;  /* 34h */
static bool range_changed;   /* 22h.3 */

/* ========================================================================================= */
/* scaling                                                                                    */
/* ========================================================================================= */

/* 0x165A: decimal exponent of one count. Base per function + range. */
int range_scale_exp(void)
{
    static const int8_t base[14] = { -4, -5, -5, -5, -2, -2, -11, -11, 0, -14, -3, -1, -4, -2 };
    int b = base[func()];
    if ((func() == 6 || func() == 7) && current_10a) b = -9;
    if (func() == 10 && range() == 6) b = -4;
    return (int)range() + b;
}
double count_to_value(int32_t c) { return c * pow10i(range_scale_exp()); }                 /* 0x16BA */
int32_t value_to_count(double v)                                                          /* 0x16CC */
{
    double c = v / pow10i(range_scale_exp());
    return (int32_t)(c >= 0 ? c + 0.5 : c - 0.5);
}

/* 0x19A8 range_param_lookup: autorange thresholds in counts (down, up, overload).
 * Values from ROM 0x6FE9-0x7031 (emulator-free reading of the switch at 0x19A8). For Vpeak and
 * V the upper ranges (bit 2 set: range 4-7) end at half scale, e.g. 1000 V on a 2000-count range. */
typedef struct { int32_t down, up, over; } range_limits;
static range_limits range_param_lookup(void)
{
    bool high = meter_state & 0x40;
    switch (func()) {
    case 0:  return high ? (range_limits){ 180, 1000, 1100 } : (range_limits){ 180, 2000, 2100 };
    case 1: case 2: case 3:
             return high ? (range_limits){ 1800, 10000, 11000 } : (range_limits){ 1800, 20000, 21000 };
    case 4: case 5: return (range_limits){ 1800, 20000, 21000 };
    case 6: case 7: return (range_limits){ 900, 10000, 11000 };   /* current: decades of 10000 */
    case 8:  return (range_limits){ 0, 100000, 110000 };
    case 9:  return (range_limits){ 1800, 20000, 21000 };
    case 10: return (high && (meter_state & 0x20)) ? (range_limits){ 9000, 200000, 210000 }
                                                    : (range_limits){ 9000, 100000, 110000 };
    case 11: return (range_limits){ 0, 4000, 4000 };
    default: return (range_limits){ 0, 21000, 21000 };             /* diode, continuity */
    }
}

/* 0x1288: signed count = raw counter - T2. The delta-modulation ADC counts up and down around
 * T2 (29360, SPEED 3: 2936). |count| >= T2 = overload. */
static int32_t adc_count_minus_zero(uint16_t raw)
{
    int32_t t2 = fast() ? 2936 : 29360;
    int32_t c = (int32_t)raw - t2;
    if ((c < 0 ? -c : c) >= t2) overload = true;
    return c;
}

/* 0x1145 meas_scale_result: function offsets before ranging */
static int32_t meas_scale_result(uint16_t raw, bool *special)
{
    *special = false;
    int32_t c = adc_count_minus_zero(raw);
    switch (func()) {
    case 2: case 3: case 7: {                                  /* AC: RMS converter offset */
        int32_t off = rms_get_byte();
        if (fast()) off /= 10;
        c -= off;
        break; }
    case 0: c -= 100; break;                                   /* Vpeak (0x7040) */
    case 9: c = c / 10 - 3; break;                             /* capacitance (0x6FE3, 0x6FEC) */
    default:                                                   /* DC: subtract the drift offset */
        c -= xram_i24((func() == 6 && (meter_state & 0x10)) || (func() != 11 && func() != 12 && range() == 0)
                      ? 0x011D : 0x0120) / (fast() ? 100 : 10);
        break;
    }
    return c;
}

/* frequency: counts x gate correction. 1/1.048576 (0x7055) for the 1.05 s gate, 1/1.31072 for
 * 131 ms (0x7059); 0x7049/0x704D/0x7051 are the same about 24 ppm smaller (gate latency). */
static int32_t freq_correct(int32_t n, bool short_gate, bool latency_variant)
{
    double k = short_gate ? (latency_variant ? 0.7627939581871033 : 0.7627868056297302)
                          : (latency_variant ? 0.9536515474319458 : 0.95367431640625);
    double v = n * k;
    return (int32_t)(v + 0.5);
}

/* ========================================================================================= */
/* ranging                                                                                    */
/* ========================================================================================= */
static bool range_allowed(unsigned r) { return r < 8 && (speed_ranges[func()][speed()] >> r) & 1; }

static bool range_can_go_up(void)   { return range() < 7 && range_allowed(range() + 1); }          /* 0x194C */
static bool range_can_go_down(void)                                                                /* 0x1959 */
{
    if ((func() == 6 || func() == 7) && current_10a) return false;
    return range() > 0 && range_allowed(range() - 1);
}

/* 0x1AFE autorange_step: one decade per reading; in manual range only the overload test */
static int32_t autorange_step(int32_t c)
{
    range_limits L = range_param_lookup();
    bool neg = c < 0;
    int32_t a = neg ? -c : c;
    if (!cal_mode) {
        if (meter_autorange && !overload && a < L.up) {
            if (a < L.down && range_can_go_down()) { meter_state -= 0x10; range_changed = true; }
        } else if (meter_autorange && range_can_go_up()) {
            meter_state += 0x10; range_changed = true;
        } else if (a >= L.over) {
            overload = true;
        }
    }
    if (overload) a = L.over;                               /* overload shows as the limit */
    return neg ? -a : a;
}

/* 0x3F1D range_by_value (RNG <number>): smallest range whose full scale covers the value; if that
 * range does not exist at this speed, the next lower existing one. Refused if none. */
bool range_by_value(double v, unsigned (*full_scale_range)(double))
{
    unsigned r = full_scale_range(v < 0 ? -v : v);          /* range_find_for_value 0x3EB1 */
    for (int i = (int)r; i >= 0; i--)
        if (range_allowed((unsigned)i)) { meter_state = (uint8_t)((meter_state & 0x0F) | (i << 4)); return true; }
    return false;
}

/* ========================================================================================= */
/* filtering                                                                                  */
/* ========================================================================================= */

/* 0x1DE7 input_step_detect: in SPEED 1 (and FRQ, VAC range 2) a jump of more than 10 counts (VDC,
 * degC) or 1000 counts against the last reading restarts the averaging; a second jump in a row
 * also restarts autoranging */
static bool step_seen;          /* 2Ch.3 */
static void input_step_detect(int32_t c)
{
    if (!(summing() || (meter_state & 0x7F) == 0x2A)) return;
    int32_t last = xram_i24(0x00FA), d = c - last;
    if (d < 0) d = -d;
    int32_t lim = (func() == 1 || func() == 11) ? 10 : 1000;
    if (d < lim) { step_seen = false; xram_store_i24(0x00FA, c); return; }
    if (!step_seen) {
        step_seen = true;
        if (func() == 1 || func() == 11) { result_ok = false; xram[0x0094]++; complete = false; }
    } else {
        xram_store_i24(0x00FA, c);
        /* autorange_count_step(); 2Bh.1 = 1 */
    }
}

/* 0x1E6B: more than 9 unstable readings in a row (29 in calibration mode) -> 'R' */
static void meas_check_settled(void)
{
    if (unstable_count > (cal_mode ? 29 : 9)) not_settled = true;
}

/* 0x5C02 display_stabilize / 0x5BED meas_digital_filter: last-digit hysteresis. While the new
 * count stays within a few counts of the held one (4, VDC 15), a signed tally of the differences
 * is kept; only when it reaches 6 (VDC 20) is the held count moved by one (three if the difference
 * is 10 or more and the filter is in fast-follow mode). A bigger jump is taken immediately. */
typedef struct { int8_t tally; int32_t held; } stab_t;
static int32_t stabilize(stab_t *s, int32_t c, int near, int threshold, bool fast_follow)
{
    int32_t d = c - s->held;
    int32_t ad = d < 0 ? -d : d;
    if (ad >= near) { s->tally = 0; s->held = c; return c; }
    if (s->tally > 0) s->tally--; else if (s->tally < 0) s->tally++;
    s->tally = (int8_t)(s->tally + (d < 0 ? -2 * ad : 2 * ad));
    int t = s->tally < 0 ? -s->tally : s->tally;
    if (t >= threshold + (d < 0)) {
        int steps = (fast_follow && ad > 9) ? 3 : 1;
        s->held += d < 0 ? -steps : steps;
        s->tally = 0;
    }
    return s->held;
}
static stab_t stab_display, stab_vdc;                         /* XDATA 0x00D3, 0x00D7 */
void filter_init(void) { stab_display.held = stab_vdc.held = 0x7FFFFF; stab_display.tally = stab_vdc.tally = 0; }

/* 0x1636: SPEED 3 (and FRQ in SPEED 2): the count was divided by 10 before the stabiliser;
 * multiplying back by 10 leaves the last digit 0 (shown blank) */
static int32_t fast_mode_drop_digit(int32_t c)
{
    return (fast() || (func() == 10 && speed() == 1)) ? c * 10 : c;
}

/* ========================================================================================= */
/* result                                                                                     */
/* ========================================================================================= */

/* 0x1E80: Pt-100 resistance (in counts of 0.01 Ohm scale) -> degC, Callendar-Van Dusen inverted:
 * T = 3367.85 - sqrt(13065975 - 17235.58 * R) */
static double pt100_r_to_temp(double r) { return 3367.850341796875 - sqrt(13065975.0 - 17235.583984375 * r); }

/* 0x1FF0 result_convert_function: sign handling. The input stages of Vp- and of functions 2-7
 * and 11-13 invert, so those readings are negated (VDC, time, CAP and FRQ are not). Outside
 * cal-enable a reading of the wrong sign is then clamped to 0 (except VDC and IDC). */
static double result_convert_function(double v)
{
    unsigned f = func();
    bool keep = (f == 0) ? peak_mode_b0 : (f < 8 ? f == 1 : f < 11);
    if (!keep && v != 0) v = -v;
    if (!cal_enable && f != 1 && f != 6) {
        if (f == 0 && !peak_mode_b0) { if (v >= 0) v = 0; }   /* Vp-: only negative */
        else if (v < 0) v = 0;
    }
    if (f == 11) v = pt100_r_to_temp(v);
    return v;
}

/* 0x17AC result_apply_db_rel: dB = 10 log10(V^2 * 1000 / Zref)  (dBm into the reference
 * impedance, XDATA 0x0075, default 600). Readings below 8 counts give 'U' and -max.
 * Then relative: value - reference (XDATA 0x0079). */
static double result_apply_db_rel(double v)
{
    if (db_mode) {
        int32_t c = (int32_t)(v * pow10i(6 - (int)(speed() + range())));
        if (c < 0) c = -c;
        xram_store_i24(0x0116, c);
        if (c < 8) { db_underflow = true; v = -3.6893485e19; }
        else       v = 10.0 * log10(v * v * 1000.0 / xram_float(0x0075));
    }
    if (!db_underflow && zero_mode) v -= xram_float(0x0079);
    return v;
}

/* 0x1839: status bytes. st0: b0 C, b1 O, b2 F, b3 R, b4 N, b5 U, b7 = not the final conversion.
 * st1: range << 4, b7 = 10 A input (IDC/IAC). b3 (no reading yet, '?') is set by
 * result_record_clear 0x3CD4 after a function/trigger change. */
static void meas_build_status(uint8_t *st0, uint8_t *st1)
{
    *st0 = (uint8_t)(crest | overload << 1 | cal_step_failed << 2 | not_settled << 3 |
                     range_invalid << 4 | db_underflow << 5 | (!complete) << 7);
    *st1 = meter_state & 0x70;
    if ((meter_state & 0x0E) == 6) *st1 |= (uint8_t)(current_10a << 7);
}

/* 0x1872 minmax_update: min at 0x007D (status 0x0069), max at 0x0081 (status 0x006B) */
static void minmax_update(double v, uint8_t st0, uint8_t st1)
{
    if (v < xram_float(0x007D)) { xram_store_float(0x007D, v); xram[0x0069] = st0; xram[0x006A] = st1; }
    if (v > xram_float(0x0081)) { xram_store_float(0x0081, v); xram[0x006B] = st0; xram[0x006C] = st1; }
}
void min_reset(void) { xram_store_float(0x007D, 3.6893485e19);  xram[0x0069] = 0; xram[0x006A] = 4; }   /* 0x3AE2 */
void max_reset(void) { xram_store_float(0x0081, -3.6893485e19); xram[0x006B] = 0; xram[0x006C] = 4; }   /* 0x3B11 */

/* 0x18AF / 0x18D5 / 0x18EF: publish for the interface (0x0064/0x0065 + value 0x0085, read by
 * task_remote_reply) and for the display (0x0067/0x0068 + 0x0089). 0x0066 bit 0 = any error. */
extern bool new_reading, display_new;
static void meas_result_complete(double v, double v_unrel, uint8_t st0, uint8_t st1)
{
    if (complete) {
        if (!overload && !db_underflow) { xram_store_float(0x0091, v_unrel); xram_store_float(0x008D, v); }
        /* time interval >= 10 s and continuity above 10 counts switch the ADC to alternate mode */
        new_reading = true; trigger_pending = false;
        xram[0x0064] = st0; xram[0x0065] = st1; xram_store_float(0x0085, v);
        if (st0 & 0x2F) xram[0x0066] |= 1;
    }
    display_new = true;
    xram[0x0067] = st0; xram[0x0068] = st1; xram_store_float(0x0089, v);
}

void result_record_clear(void)                                                           /* 0x3CD4 */
{
    xram[0x0067] = 0; xram[0x0064] = 0;
    xram[0x0068] = xram[0x0065] = (uint8_t)((meter_state & 0x70) | 0x08);
}

/* ========================================================================================= */
/* process phase                                                                              */
/* ========================================================================================= */

/* 0x1EA4 meas_postprocess: SPEED 1 summing, filtering and calibration */
static double meas_postprocess(int32_t c, int32_t *sum)
{
    if (summing()) *sum += c;                                   /* XDATA 0x00F6 */
    if (cal_mode && (overload || not_settled)) {                /* code 0x15: reading unusable */
        cal_fail_code(0x15); overload = not_settled = false;
    }
    double v;
    if (fast() || func() == 10) {
        if ((meter_state & 0x7F) == 0x2A) c = fast_mode_drop_digit(c);
        v = cal_mode ? count_to_value(c) : cal_apply(count_to_value(c), false);
    } else {
        c = stabilize(&stab_vdc, *sum, func() == 1 ? 15 : 4, func() == 1 ? 20 : 6, func() == 1);
        v = cal_mode ? count_to_value(c) : cal_apply(count_to_value(c) / 10, false) * 10;
    }
    if (!cal_mode) c = value_to_count(v);
    if (func() == 0 && peak_mode_b0 && peak_mode_b1)            /* Vpp = Vp+ + |Vp-| */
        c = xram_i24(0x0101) + xram_i24(0x0104);
    if ((func() == 0 || (func() != 8 && func() != 10 && func() != 13)) && (cal_mode || (meter_mode & 0x0C) == 0)) {
        if (fast() || (func() == 10 && speed() == 1)) c /= 10;
        c = stabilize(&stab_display, c, 4, 6, false);
        c = fast_mode_drop_digit(c);
    }
    v = count_to_value(c);
    if (summing()) v /= 10;
    if (cal_mode && trigger_pending) {
        cal_step_zero(v, peak_mode_b0, false);
        if (!complete) result_ok = false;
        else if (!cal_step_failed) { cal_load_range(); cal_compute_effective(); v = cal_apply(v, peak_mode_b0); }
    }
    return v;
}

/* 0x2092 meas_phase_process */
void meas_phase_process(uint16_t raw)
{
    static int32_t sum;
    bool special;
    int32_t c = meas_scale_result(raw, &special);
    if (special) { internal_temp_update(c); return; }          /* internal temperature conversions */
    double v = 0;
    bool have = false;
    if (func() == 8) {
        /* meas_process_time 0x1515: seconds = (overflows * 65536 + T1) * 1e-6, decade autorange
         * (range r = 10^(r-1) s), timebase calibration applied */
        have = true;
    } else {
        c = autorange_step(c);                                  /* via meas_range_checks */
        if (result_ok) {
            if (!overload) input_step_detect(c);
            if (!result_ok) meas_check_settled();
            if (result_ok) { v = meas_postprocess(c, &sum); have = true; }
        }
    }
    if (have) {
        double before_rel = result_convert_function(v);
        v = result_apply_db_rel(before_rel);
        if (trigger_pending && result_ok) {
            uint8_t st0, st1;
            meas_build_status(&st0, &st1);
            if (complete && !cal_mode) minmax_update(v, st0, st1);
            meas_result_complete(v, before_rel, st0, st1);
        }
    }
    /* afterwards: if not complete, start the next conversion; when complete, the restart counter
     * (33h) is checked against the measuring-time limit (out_format_params_a / 10) */
}

/* ========================================================================================= */
/* task and trigger                                                                           */
/* ========================================================================================= */
extern bool phase_switch, phase_acquire, phase_process;     /* 2Ch.0 .. 2Ch.2 */
extern bool adc_alt_mode;                                   /* 26h.6 */
extern uint16_t adc_timeout;                                /* 12h/13h, 0x0420 passes */
void meas_phase_switch(void);                               /* 0x259E, see src/measure.c */
void meas_phase_acquire(void);                              /* 0x213B, see src/measure.c */
uint16_t adc_read_counter(void);

/* 0x14A2 adc_start_cycle: OQ0071 cmd 0x89 (0x8B alternate) and PCF8574 0x4E bit 0 = !alternate */
void adc_start_cycle(bool alternate)
{
    adc_alt_mode = alternate;
    adc_send_cmd(alternate ? 0x8B : 0x89);
    probe_set_bit0(!alternate);
}

/* 0x10A0 meas_restart: after a function/range change */
void meas_restart(void)
{
    range_changed = true;
    unstable_count = 0x7F;
    adc_start_cycle(false);
    /* autorange_reset; meas_stop_and_reset (timers/interrupts off, phase flags reset) */
}

/* 0x1009 task_measure */
void task_measure(void)
{
    /* context swap in; SPEED 3 forced during fast autoranging (2Ch.5) */
    P1_2_watchdog_pulse();
    if (adc_timeout && --adc_timeout == 0) { diag_count_event(0x0B); meas_restart(); return; }
    if (phase_process) { meas_phase_process(adc_read_counter()); return; }
    if (phase_switch)  { meas_phase_switch(); return; }
    if (phase_acquire) { meas_phase_acquire(); return; }
    diag_count_event(0x0C);                                  /* no phase: restart */
    meas_restart();
}

/* 0x5D96 task_trigger: internal trigger = every reading; bus/external trigger (TRG B/E, also the
 * ZERO key in calibration mode) arm one reading. In calibration mode a trigger is refused when the
 * range has no step for the selected cold/hot calibration (23h.6 = refused). */
extern bool trigger_request, bus_trigger_seen, ext_trigger_seen, int_trigger_ready, trig_refused;
void trigger_restart_measure(void);
void task_trigger(void)
{
    bool fire = false;
    if (xram[0x00EB] & 1) {                                  /* X / ZERO key */
        if (!cal_mode || !cal_step_allowed_c()) {
            trigger_restart_measure();
            xram[0x00EB] &= 0xFE;
            fire = true;
        } else trig_refused = true;
    } else {
        unsigned t = (meter_mode >> 2) & 3;                  /* 0 I, 1 B, 2 E */
        fire = (t == 1 || t == 2) ? ext_trigger_seen : int_trigger_ready;
    }
    if (fire) { int_trigger_ready = ext_trigger_seen = false; trigger_pending = true; }
}

/* 0x0ABF: JCV in calibration mode clears the 22 diagnostic counters at 0x076C */
void diag_clear_counters(void) { for (int i = 0; i < 22; i++) xram[0x076C + i] = 0; }

/* 0x211D: event counters, ++XDATA[0x0772 + id] and the total at 0x076C.
 * 0x0B = ADC never ready, 0x0C = no phase */
void diag_count_event(uint8_t id) { xram[0x0772 + id]++; xram[0x076C]++; }
