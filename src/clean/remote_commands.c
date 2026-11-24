/* remote_commands.c (hand-cleaned) - remote command handlers and query replies (firmware S25)
 *
 * Original: 0x3D2B-0x4088 (handlers called from fnsel_dispatch), 0x4814-0x4EB0 (reply builder,
 * task_remote_reply 0x4D2B) and 0x5B93-0x5BCA (RMS byte). Semantics checked against the emulator
 * runs (tools/emu_cdp.py, tools/parse_cmd.py) and the real meter (CDP?/JCV dumps, see
 * CALIBRATION_BACKUP.md).
 *
 * The reply is built in XDATA reply_buf (0x0034) with reply_len (bank 1 R3): bit 7 = buffer full,
 * waiting for the interface, bit 6 = last part of the message, bits 0-5 = length. One call of
 * task_remote_reply produces at most one part; multi-part replies (DMP?, CDP?) continue on later
 * main-loop passes, counted by reply_items_left.
 */
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

/* ---- state used here (names from tools/s25.sym) ------------------------------------------ */
extern uint8_t meter_state;          /* IRAM 20h: bits 0-3 function, 4-6 range, 7 autorange */
extern uint8_t meter_mode;           /* IRAM 21h: bits 0-1 speed, 2-3 trigger, 4-5 time slope, 6-7 peak kind */
extern bool    meter_autorange;
extern bool    db_mode;              /* 22h.0  DBM ON  -> header 'D' */
extern bool    zero_mode;            /* 22h.1  ZER ON  -> header 'Z' */
extern bool    out_no_header;        /* 22h.7  OUT N   (OUT S = header on) */
extern bool    cal_mode, cal_hot, cal_enable;
extern bool    cr_enabled, mains_60hz;
extern bool    emo_continuous;
extern bool    cmd_error;            /* 2Dh.2  parameter refused */
extern uint8_t speed_saved;          /* XDATA 0x01CC: VDC speed */
extern uint8_t funcswitch_step_count;/* XDATA 0x01CB: MTS? */
extern uint8_t reply_buf[64];        /* XDATA 0x0034 */
extern uint8_t reply_len, reply_pending_cmd, reply_items_left;
extern uint8_t xram[0x800];

extern const struct { char name[3]; uint8_t type, index; } cmd_table[42];   /* ROM 0x59B1 */

/* ROM tables */
extern const uint8_t speed_ranges[14][3];     /* 0x6ED4: [function][speed] = bit mask of allowed ranges */
extern const uint8_t resolution_table[20][3]; /* 0x6E40: [mnemonic][speed] = digits in the reply (RSL?) */
extern const uint8_t range_decimal_table[14][8]; /* 0x6DC0: [function][range] = digits before the point */
static const uint8_t dmp_items[11] = {        /* 0x6DAB: DMP? = FNC RNG DBM ZER MSP RSL TRG CAL OUT CR SIX */
    19, 20, 21, 22, 26, 27, 28, 30, 31, 37, 36 };

#define CDP_SLOTS   114                       /* ROM 0x6FB9 */
#define JCV_DEFAULT 0x076C                    /* the 22 error counters */
#define DBM_REF     0x0075                    /* XDATA float, default 600 Ohm */
#define ZER_REF     0x0079                    /* XDATA float */

/* elsewhere */
double  xram_float(uint16_t a);
void    xram_store_float(uint16_t a, double v);
void    meas_set_function_flags(void);
void    nv_set_iface_config(uint8_t v);
uint8_t nv_get_iface_config(void);
void    iface_send_config_address(uint8_t addr);
void    iface_clear_remote(void);
void    iface_send_reply(const uint8_t *buf, uint8_t len_flags);
bool    iface_ready_for_reply(void);      /* channel flags bit 6 */
void    iface_report_status(void);
void    cal_write_all_copies(uint16_t addr, double v);
double  cal_ld_slot_vote(uint16_t addr, bool *no_majority);
bool    cal_seal_ok(void);
bool    value_is_signed(void);        /* display.c, 0x377C */
void    fp_format(char *out, double v, uint8_t width_flags, uint8_t fmt, uint8_t exp_align);
uint8_t range_exponent(void);             /* digits_for_range: exponent of the range (5Bh) */
uint8_t rms_get_byte(void);
bool    iface_channel_open(void);         /* bank 3 R5/R6 != 0 */
bool    iface_busy(void);                 /* channel flags bit 4 */
extern bool    identity_requested;        /* 23h.1 */
extern bool    new_reading;               /* 24h.0 */
extern bool    bus_wait_trigger;          /* 24h.5 */
extern uint8_t rx_count;                  /* IRAM 0Dh */
extern uint8_t result_flags;

static uint16_t jcv_ptr;                  /* XDATA 0x009A/0x009B, one-shot */
static uint32_t emo_count;                /* XDATA 0x0095 (24 bit) */
static uint8_t  cdp_slot;

static unsigned func(void)  { return meter_state & 0x0F; }
static unsigned range(void) { return (meter_state >> 4) & 7; }
static unsigned speed(void) { return meter_mode & 3; }

/* ======================================================================================== */
/* command handlers (parameter already parsed: int in 30h/31h, number in 30h-33h)             */
/* ======================================================================================== */

void jcv_set_ptr(uint16_t addr) { jcv_ptr = addr; }                          /* 0x3D2B */
static uint16_t jcv_take_ptr(void) { uint16_t p = jcv_ptr; jcv_ptr = 0; return p; }   /* 0x3D36 */

/* 0x3D7F MSP n (1..3). Allowed only if the current range exists at that speed (speed_ranges).
 * With autorange on, a speed whose range set is empty is refused; if only the current range is
 * missing, the function is re-selected so autorange picks a valid one. */
void set_speed(uint8_t n)
{
    uint8_t allowed = speed_ranges[func()][n - 1];
    bool in_range = allowed & (1u << range());
    if (meter_autorange ? allowed == 0 : !in_range) { cmd_error = true; return; }
    if (meter_autorange && !in_range) meas_set_function_flags();
    meter_mode = (uint8_t)((meter_mode & 0xFC) | (n - 1));
    if (func() == 1) speed_saved = (uint8_t)((n - 1) & 3);    /* VDC remembers its speed */
}

/* 0x3E8B CDP n,value: write calibration slot n (1..114) into all three copies */
void cdp_write_slot(uint8_t n, double value)
{
    cal_write_all_copies((uint16_t)(0x0200 + 4 * (n - 1)), value);
}
bool cdp_slot_valid(uint8_t n) { return n >= 1 && n <= CDP_SLOTS; }          /* 0x4088 */

/* 0x3FBA IEE n: store the GPIB address (settings byte 1) and pass it to the interface */
void iee_store_address(uint8_t cfg)
{
    nv_set_iface_config(cfg);
    if ((int8_t)xram[0x0055] < 0 && xram[0x0059] == 0)       /* interface present and idle */
        iface_send_config_address(cfg);
}

void rtl_go_local(void) { iface_clear_remote(); }                             /* 0x3FDE */

/* 0x3FF0 EMO n: send n readings (EMO A = continuous, handled by the caller) */
void emo_set_count(int32_t n)
{
    if (n < 0) { cmd_error = true; return; }
    emo_count = (uint32_t)n;
    emo_continuous = false;
}

/* 0x4006 TOL ON/OFF: talk-only = settings byte 1 bit 7. Only ON/OFF is accepted. */
void tol_set(bool on, bool other_param)
{
    if (other_param) { cmd_error = true; return; }
    uint8_t cfg = nv_get_iface_config() & 0x7F;
    if (on) { cfg |= 0x80; emo_continuous = true;  /* 23h.3 */ }
    else    { emo_continuous = false; emo_count = 0; }
    iee_store_address(cfg);
}

/* 0x403A ZER <number>: reference, accepted for -1e12 <= x <= 1e12 (ROM 0x6FCC/0x6FC8) */
void zer_set_reference(double x) { if (x >= -1e12 && x <= 1e12) xram_store_float(ZER_REF, x); }

/* 0x4061 DBM <number>: reference impedance, 1e-4 <= x <= 9999 (ROM 0x6FD4/0x6FD8) */
void dbm_set_reference(double x) { if (x >= 1e-4 && x <= 9999) xram_store_float(DBM_REF, x); }

/* 0x4814: current function -> its mnemonic index in cmd_table (VPU..CON) */
uint8_t func_to_cmd_index(void)
{
    unsigned f = func();
    if (f == 0) return (uint8_t)((meter_mode >> 6) - 1);   /* Vpeak: VPU/VPL/VPP from mode bits 6-7 */
    if (f < 8)  return (uint8_t)(f + 2);                   /* VDC .. IAC */
    if (f == 8) return (uint8_t)(((meter_mode >> 4) & 3) + 10);  /* TPP/TPN/TNP/TNN */
    return (uint8_t)(f + 5);                               /* CAP FRQ TDC DIO CON */
}

/* 0x5B93 / 0x5BBB  RMS byte: n at 0x07FD, n+0x55 at 0x07FE, n-0x56 at 0x07FF; 2-of-3 repair,
 * fallback 'A' (65) */
uint8_t rms_set_byte(uint8_t n)
{
    xram[0x07FD] = n; xram[0x07FE] = (uint8_t)(n + 0x55); xram[0x07FF] = (uint8_t)(n - 0x56);
    return n;
}
uint8_t rms_get_byte(void)
{
    uint8_t a = xram[0x07FD], b = (uint8_t)(xram[0x07FE] - 0x55), c = (uint8_t)(xram[0x07FF] + 0x56);
    if (a == b && a == c) return a;
    if (a == b || a == c) return rms_set_byte(a);
    if (b == c) return rms_set_byte(b);
    return rms_set_byte('A');
}

/* ======================================================================================== */
/* reply builder                                                                             */
/* ======================================================================================== */

static void put(const char *s)          { size_t n = strlen(s); memcpy(&reply_buf[reply_len], s, n); reply_len += (uint8_t)n; }
static void putc_(char c)               { reply_buf[reply_len++] = (uint8_t)c; }
static void put_mnemonic(uint8_t i)     { memcpy(&reply_buf[reply_len], cmd_table[i].name, 3); reply_len += 3; }  /* 0x4968 */
static void put_3digits(uint8_t v)      { putc_('0' + v / 100); putc_('0' + v / 10 % 10); putc_('0' + v % 10); putc_(','); } /* 0x4A4F */
static void put_float(double v, uint8_t width, uint8_t fmt, uint8_t align)                     /* 0x485A */
{
    char tmp[24];
    fp_format(tmp, v, width, fmt, align);
    put(tmp);
}

/* 0x49E3 / 0x4A06 */
static void reply_send(void)
{
    if (!iface_ready_for_reply()) { reply_len = 0x80; return; }
    reply_len |= 0x80;
    iface_send_reply(reply_buf, reply_len);
}
static void reply_send_last(void)
{
    if (cr_enabled) putc_('\r');
    reply_len |= 0x40;
    reply_send();
}

/* result block: status bytes at 0x0064/0x0065, value at 0x0085 (0x0069/0x007D, 0x006B/0x0081 for MIN/MAX) */
typedef struct { uint8_t st0, st1; uint16_t value_addr; } result_ref;

/* 0x4C58: "<mnemonic><D| ><Z|C| ><flag>"  (flag order ? O F N U R C, see DECOMPILATION.md) */
static void put_reading_header(uint8_t idx, result_ref r)
{
    put_mnemonic(idx);
    putc_(db_mode ? 'D' : ' ');
    putc_(cal_mode ? 'C' : zero_mode ? 'Z' : ' ');
    char flag = ' ';
    if (r.st1 & 0x08)      flag = '?';
    else if (r.st0 & 0x02) flag = 'O';
    else if (r.st0 & 0x04) flag = 'F';
    else if (r.st0 & 0x10) flag = 'N';
    else if (r.st0 & 0x20) flag = 'U';
    else if (r.st0 & 0x08) flag = 'R';
    else if (r.st0 & 0x01) flag = 'C';
    putc_(flag);
}

/* 0x4A84: the value field. Digits come from resolution_table (per mnemonic and speed), the
 * decimal point from range_decimal_table (per function and range). dB readings use 4 digits in
 * fixed format, relative readings 7 digits. Without a valid reading (overload, no reading yet,
 * failed, dB underflow; or a range flagged invalid except for IDC/IAC) the field is
 * "+99999999E+09" shortened to the same width, with the point where the reading would have it. */
static void put_reading_value(uint8_t idx, result_ref r)
{
    double v = xram_float(r.value_addr);
    if (idx == 18) { put(v < 10.0 ? " CLOSED" : "   OPEN"); return; }   /* continuity */

    uint8_t digits = resolution_table[idx][speed()];
    if ((idx == 7 && range() == 6) || (idx == 14 && range() == 7)) digits--;  /* RTW top, CAP top */
    uint8_t fmt = 0, align = 0;
    if (zero_mode) { digits = 7; fmt = 0x48; }
    if (db_mode)   { digits = 4; fmt = 0xF1; align = 0; }

    uint8_t before_point = range_decimal_table[func()][range()];
    bool range_flag = r.st1 & 0x80;
    if (range_flag && (idx == 8 || idx == 9)) before_point--;

    bool valid = !(r.st1 & 0x08) && !(r.st0 & 0x26) && (!range_flag || idx == 8 || idx == 9);
    if (valid) {
        if (!db_mode && !zero_mode) {
            if (r.st0 & 0x08) digits--;                    /* not settled: one digit less */
            fmt = (uint8_t)(((digits - before_point) & 0x0F) | 0xF0);
            if (!value_is_signed()) { if (v < 0) v = -v; fmt &= 0xBF; }   /* reply_nc_check 0x4A7E: no sign */
        }
        put_float(v, (uint8_t)(digits | 0x60), fmt, align);
    } else {
        uint8_t start = reply_len;
        put(" 99999999E+09");
        uint8_t blanks = (!zero_mode || db_mode) ? (uint8_t)(7 - digits) : 0;
        memset(&reply_buf[start + 1], ' ', blanks);        /* left-pad, keeps the total width */
        uint8_t sign_pos = (uint8_t)(start + blanks);
        reply_buf[sign_pos] = !value_is_signed() ? ' '
                            : (!(r.st1 & 0x08) && (xram[r.value_addr] & 0x80)) ? '-' : '+';
        reply_buf[sign_pos + 4] = '.';
    }
}

/* 0x4936: after a reading has been sent. With bus or external trigger the "new reading" flag is
 * cleared (one reading per trigger) and the status byte reported unless still waiting for a bus
 * trigger in interface mode 0. */
static void reply_after_reading(void)
{
    if (meter_mode & 0x0C) {
        result_flags &= 0xF7;
        if (!bus_wait_trigger || xram[0x005A] != 0) iface_report_status();
    } else {
        iface_report_status();
    }
}

void reply_init(void) { reply_len = 0; reply_pending_cmd = 0; reply_items_left = 0; jcv_take_ptr(); }   /* 0x4D1B */
void reply_abort(void) { reply_len = 0; reply_items_left = 0; }                                         /* 0x4D12 */

static void put_on_off_value(bool on, uint16_t addr)  /* "OFF," / " ON," + 7-digit value */
{
    put(on ? " ON," : "OFF,");
    put_float(xram_float(addr), 0x67, 0x48, 0);
}

/* one query item: "<CMD> " + answer */
static void put_query_item(uint8_t cmd)
{
    put_mnemonic(cmd);
    putc_(' ');
    switch (cmd) {
    case 19: put_mnemonic(func_to_cmd_index()); break;                               /* FNC? */
    case 20:                                                                          /* RNG? */
        if (meter_autorange)        put("    AUTO");
        else if (meter_state == 0x6A) put(" 20.E+06");                                /* FRQ top range */
        else {
            uint8_t e = range_exponent();
            reply_len--;
            put_float(0, 0x23, 0x30, (uint8_t)((e + 9) / 3 * 3 - 9));                /* "200.E-03" */
        }
        break;
    case 21: put_on_off_value(db_mode, DBM_REF); break;                               /* DBM? */
    case 22: put_on_off_value(zero_mode, ZER_REF); break;                             /* ZER? */
    case 23: case 24: {                                                               /* MIN? MAX? */
        result_ref r = { xram[cmd == 23 ? 0x0069 : 0x006B], xram[(cmd == 23 ? 0x0069 : 0x006B) + 1],
                         cmd == 23 ? 0x007D : 0x0081 };
        putc_(',');
        if (!out_no_header) put_reading_header(func_to_cmd_index(), r);
        put_reading_value(func_to_cmd_index(), r);
        break; }
    case 26: putc_((char)('1' + speed())); break;                                     /* MSP? */
    case 27: {                                                                        /* RSL? */
        uint8_t idx = func_to_cmd_index();
        uint8_t d = resolution_table[idx][speed()];
        if (idx == 7 && range() == 6) d--;
        putc_((char)('0' + d));
        break; }
    case 28: putc_("IBE?"[(meter_mode >> 2) & 3]); break;                             /* TRG? */
    case 30: put(cal_mode ? (cal_hot ? "ON,1" : "ON,0") : " OFF"); break;             /* CAL? */
    case 31: putc_(out_no_header ? 'N' : 'S'); break;                                 /* OUT? */
    case 32: {                                                                        /* JCV? */
        uint16_t p = jcv_take_ptr();
        if (p == 0) p = JCV_DEFAULT;
        for (int i = 0; i < 6; i++) put_3digits(xram[(p + i) & 0x7FF]);
        reply_len--;                                                                  /* drop last ',' */
        break; }
    case 34: {                                                                        /* CDP? one slot */
        uint8_t n = (uint8_t)(CDP_SLOTS - reply_items_left + 1);
        bool no_majority;
        double v = cal_ld_slot_vote((uint16_t)(0x0200 + 4 * (n - 1)), &no_majority);
        putc_((!cal_enable && !cal_seal_ok()) ? 'N' : no_majority ? 'E' : ' ');
        put_3digits(n);
        put_float(v, 0x67, 0x40, 0);                                                  /* +1.353806E+06 */
        break; }
    case 35: put_3digits(rms_get_byte()); reply_len--; break;                         /* RMS? */
    case 36: put(mains_60hz ? " ON" : "OFF"); break;                                  /* SIX? */
    case 37: put(cr_enabled ? " ON" : "OFF"); break;                                  /* CR?  */
    case 38: put_3digits(nv_get_iface_config() & 0x9F); reply_len--; break;           /* IEE? */
    case 39: put_3digits(funcswitch_step_count); reply_len--; break;                  /* MTS? */
    default: break;                                                                   /* MIN/X/DMP: nothing */
    }
}

/* 0x4D2B task_remote_reply: one part of a reply per call. Priority:
 *   1. a part still waiting in the buffer is (re)sent
 *   2. interface mode 5: the 9-byte identity block at 0x005B
 *   3. no query pending: a measurement output (EMO / talk-only), if a new reading is there
 *   4. a query: one item; DMP? = 11 items joined by ';', CDP? = 114 separate messages */
void task_remote_reply(void)
{
    if (!iface_channel_open()) { reply_items_left = 0; reply_pending_cmd = 0; return; }
    if (reply_len & 0x80) { if (!iface_busy()) reply_send(); return; }
    if (!iface_ready_for_reply()) return;
    if ((xram[0x00E0] | rx_count) & 0x80) return;        /* a command line is still being parsed */

    reply_len = 0;
    uint8_t mode = xram[0x005A];
    if (mode == 5) {
        if (identity_requested) {
            memcpy(reply_buf, &xram[0x005B], 9);
            reply_len = 9;
            identity_requested = false;
            reply_send_last();
            reply_items_left = 0;
        }
        return;
    }

    if (reply_pending_cmd == 0) {                          /* measurement output */
        if ((xram[0x00EB] & 1) || !new_reading) return;
        if (mode == 3 && !emo_continuous) {                /* EMO n: count down */
            if (emo_count == 0) return;
            emo_count--;
        }
        result_ref r = { xram[0x0064], xram[0x0065], 0x0085 };
        uint8_t idx = func_to_cmd_index();
        if (!out_no_header) put_reading_header(idx, r);
        put_reading_value(idx, r);
        reply_after_reading();
        reply_items_left = 0;
        reply_send_last();
        return;
    }

    uint8_t cmd;
    if (reply_pending_cmd == 33) {                         /* DMP? */
        if (reply_items_left == 0) reply_items_left = 11;
        cmd = dmp_items[11 - reply_items_left];
    } else {
        cmd = reply_pending_cmd;
        if (cmd == 34) { if (reply_items_left == 0) reply_items_left = CDP_SLOTS; }
        else reply_items_left = 1;
    }
    put_query_item(cmd);

    reply_items_left--;
    if (reply_items_left == 0 || reply_pending_cmd == 34) {   /* CDP: every slot is its own message */
        reply_send_last();
        if (reply_items_left == 0) reply_pending_cmd = 0;
    } else {
        putc_(';');
        reply_send();
    }
}
