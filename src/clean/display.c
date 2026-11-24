/* display.c (hand-cleaned) - LCD text, segments, annunciators, indicator (firmware S25)
 *
 * Original: 0x326C-0x3ADF (formatting, task_display_update) and 0x5549-0x58EB (frame, font).
 * The text is built as ASCII in XDATA 0x0000 ('#' terminated), then encoded through the 7-segment
 * font and sent to the PCF8576 (address 0x70, I2C bus B).
 */
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

extern uint8_t meter_state, meter_mode, xram[0x800];
extern bool cal_mode, cal_enable, cal_hot, db_mode, zero_mode, meter_autorange, current_10a;
extern bool peak_mode_b0, peak_mode_b1, trigger_pending;
extern const uint8_t lcd_font_7seg[96];        /* ROM 0x580C: ASCII 0x20-0x7F, bits d c a b dp e f g */
extern const uint8_t lcd_font_aux[];           /* ROM 0x586C: 2-digit auxiliary field */
extern const uint8_t resolution_table[20][3], range_decimal_table[14][8];

uint8_t func_to_cmd_index(void);
double  xram_float(uint16_t a);
void    fp_format(char *out, double v, uint8_t width_flags, uint8_t fmt, uint8_t exp_align);
bool    i2cB_send(uint8_t addr, const uint8_t *data, uint8_t n);

static unsigned func(void)  { return meter_state & 0x0F; }
static unsigned range(void) { return (meter_state >> 4) & 7; }
static unsigned speed(void) { return meter_mode & 3; }

char *const lcd_text = (char *)&xram[0];

/* ---- messages (ROM, '#' terminated) ---------------------------------------------------- */
#define MSG_OL     0x70ED   /* " -OL----"  overload */
#define MSG_UL     0x70F6   /* " -UL----"  dB underflow */
#define MSG_FAIL   0x70FF   /* " FAIL   "  calibration step failed (2Ah.2 from status 'F') */
#define MSG_OFL    0x7108   /* " -OFL---"  value does not fit the display */
#define MSG_OPEN   0x7152
#define MSG_CLOSED 0x715F

void lcd_show_message(uint16_t rom_text);       /* 0x5B30: copy ROM text to 0x0000 */
void lcd_show_dashes(void);                     /* 0x3CA7 */
void lcd_send_frame(void);

/* ---- reading -> text -------------------------------------------------------------------- */
/* status bits of the reading being shown (st0 from meas_build_status) */
typedef struct { uint8_t st0, st1; double v; } shown_t;

/* 0x357C: "NC" over text positions 7-8 (6-7 if position 7 holds the point) when the range is
 * not calibrated (status 'N') */
static void lcd_append_nc(bool uncal)
{
    if (!uncal) return;
    int p = lcd_text[7] == '.' ? 6 : 7;
    lcd_text[p] = 'N';
    lcd_text[p + 1 + (p == 6)] = 'C';
}

/* 0x377C value_is_signed (0x3785 func_class_check is its second entry, without the first checks):
 * C = 1 when the value is shown with a sign: VDC, IDC, degC, Vp+ and Vp-, and anything in dB, relative
 * or cal-enable mode (or 23h.4). The other functions (Vpp, VAC, Vrms, Ohm, IAC, time, CAP,
 * FRQ, diode, continuity) are shown without sign. Verified in the emulator (tools/check_clean.py
 * "readings"). */
extern bool cal_skip_verify;
bool value_is_signed(void)
{
    if (cal_skip_verify || cal_enable || zero_mode || db_mode) return true;
    if (func() == 0) return !(peak_mode_b0 && peak_mode_b1);
    return func() == 1 || func() == 6 || func() == 11;
}

/* 0x3385 lcd_format_reading */
void lcd_format_reading(shown_t r)
{
    bool neg = r.v < 0;
    double a = neg ? -r.v : r.v;
    if (func() == 13) lcd_show_message(a < 10 ? MSG_CLOSED : MSG_OPEN);
    if (r.st0 & 0x02) {                                  /* overload */
        lcd_show_message(MSG_OL);
        goto sign;
    }
    if (r.st0 & 0x04) lcd_show_message(MSG_FAIL);
    if (!db_mode) {
        /* digits from resolution_table, point from range_decimal_table; the value is rounded to
         * the display resolution (lcd_round_value 0x3724) and printed with fp_format. If it does
         * not fit, the range is shifted by 10^3 (engineering prefix change, 2Eh.4-6), and as the
         * last resort " -OFL---" is shown. 'r' is appended at position 8 in calibration mode, NC
         * otherwise. */
        uint8_t digits = resolution_table[func_to_cmd_index()][speed()];
        uint8_t before = range_decimal_table[func()][range()];
        uint8_t fmt = (uint8_t)(0xF0 | ((digits - before) & 0x0F));
        fp_format(lcd_text, a, (uint8_t)(0x60 | digits), fmt, 0);
        strcat(lcd_text, "#");
        if (!cal_mode) lcd_append_nc(r.st0 & 0x10);
        else lcd_text[8] = 'r';
    } else {
        if (r.st0 & 0x20) lcd_show_message(MSG_UL);      /* dB underflow */
        else {
            /* dB: 3 decimals, or 4 when the level count (0x0116) is large enough (> ROM 0x70D5) */
            fp_format(lcd_text, a, 0x60 | 4, 0xF1, 0);
            strcat(lcd_text, "#");
            lcd_append_nc(r.st0 & 0x10);
        }
    }
sign:
    lcd_text[0] = !value_is_signed() ? ' ' : neg ? '-' : '+';
}

/* 0x37F5 lcd_refresh: for a message that has a numeric part (the CAL codes, " 100000C"), insert
 * the range's decimal point and blank leading zeros and '-' */
void lcd_refresh(void)
{
    int digits, before;
    if (!db_mode) { digits = resolution_table[func_to_cmd_index()][speed()]; before = range_decimal_table[func()][range()]; }
    else { digits = 4; before = -3; }
    int p = 1;
    for (; before != 0; before++) { p++; digits--; }
    char carry = lcd_text[p];
    lcd_text[p] = '.';
    for (p++; digits > 0; digits--, p++) { char c = lcd_text[p]; lcd_text[p] = carry; carry = c; }
    while (carry != '#') {
        char c = (carry == '-' || carry == '0') ? ' ' : carry;
        carry = lcd_text[p]; lcd_text[p++] = c;
    }
    lcd_text[p] = '#';
}

/* ---- annunciators (0x3598 lcd_unit_symbols, 0x35FF lcd_mode_symbols, 0x3676 lcd_build_annunciators)
 * Bits in the display context 2Bh-2Fh, sent as the last frame byte(s):
 *   unit per function (jump table 0x35C8): V, mV, Ohm, kOhm/MOhm, A, mA, s, F, Hz, degC
 *   SPEED 1/2/3 (2Ch.0-2), TRIG (2Ch.5, bus/external trigger), REMOTE (2Ch.6, 0x00EB bit 4),
 *   LOCAL/LISTEN from RXD (2Eh.2), CAL 0/1 (2Fh.4/5), MAN (2Bh.7 = autorange off), Z (2Fh.3),
 *   blinking HOLD while the probe hold is active (0x00A7 bit 0, toggled by out_format_params_b) */

/* ---- indicator (0x38FE lcd_prepare_value): a 16-segment ring/bar, 2 bytes, active low,
 * pattern = table[n]:
 *   normal:     0x3A91, 15 steps; n moves one step up or down per reading with the trend of the
 *               value (a rotating "activity/trend" indicator)
 *   relative:   0x3AAF, centre-zero bar, n = 7 + deviation (lcd_scale_value)
 *   continuity: 0x3ACD, 8-step bar by magnitude
 *   time:       0x3A91, advancing while a measurement runs
 *   idle:       0x3ADD (all off) */
extern const uint16_t indicator_trend[15], indicator_rel[15], indicator_cont[8];   /* 0x3A91 0x3AAF 0x3ACD */

/* ---- frame (0x5549 lcd_send_frame, 0x57A2 lcd_encode_chars) ------------------------------- */
/* Command bytes C8 (mode set: display enabled), 86 (data pointer 6), E0 device 0,
 * F8 bank 0, 70 blink off; then 13 data bytes: 7 main digits, 2 aux digits, annunciators.
 * A '.' merges into the previous digit's dp segment (bit 3). Characters outside 0x20-0x7F show
 * blank; 0x80-0x83 are special glyphs for the aux font. */
uint8_t lcd_encode_char(char c) { return (c < 0x20 || (uint8_t)c > 0x7F) ? 0 : lcd_font_7seg[c - 0x20]; }

int lcd_encode_text(const char *t, uint8_t *seg, int n)
{
    int k = 0;
    for (; *t != '#' && k < n; t++) {
        if (*t == '.' && k > 0) { seg[k - 1] |= 0x08; continue; }
        seg[k++] = lcd_encode_char(*t);
    }
    while (k < n) seg[k++] = 0;
    return k;
}

/* ---- task (0x326C task_display_update, every 50 main-loop passes) --------------------------- */
/* Shows, in order of priority: a running edit menu (26h.2) with its blinking cursor, the held
 * reading (0x0089 + status 0x0067/0x0068) when a new one is there (26h.3), or the min/max value
 * (0x007D/0x0081, 26h.0) in the MIN/MAX menu; then annunciators, indicator, frame. In interface
 * mode 5 a new good reading is also copied to 0x005B as the 9-byte identity/value block. */
