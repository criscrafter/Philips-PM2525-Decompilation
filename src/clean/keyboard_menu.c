/* keyboard_menu.c (hand-cleaned) - key scan, command executor, data-hold probe, menus (S25)
 *
 * Original: 0x2B31-0x3240 (keys, menus), 0x3A79, 0x3D51, 0x409C-0x46FF (task_keyboard =
 * the command executor shared by keys and remote), 0x54F8, 0x5934-0x5A8D.
 *
 * One executor for both sources: a key handler or the remote parser leaves a token in the
 * keyboard context (IRAM 2Dh type, 2Eh command index, 2Fh parameter kind, 30h.. value; see
 * remote_parser.c). task_keyboard runs it, then applies the command's side effects from the
 * action table at ROM 0x6F24. Errors (2Dh.2) show on the LCD for keys, or set the interface
 * error bit (23h.6) for remote commands.
 */
#include <stdbool.h>
#include <stdint.h>

extern uint8_t meter_state, meter_mode, xram[0x800];
extern bool meter_autorange, cal_mode, cal_enable, cal_hot, db_mode, zero_mode, out_no_header;
extern bool peak_mode_b0, peak_mode_b1, time_start_negslope, time_stop_negslope, current_10a;
extern bool emo_continuous, adc_alt_mode;
extern uint8_t reply_pending_cmd;

typedef struct {
    uint8_t type, index, kind;        /* 2Dh, 2Eh, 2Fh (bits 0-2 kind, bit 6 word, bit 5 first param) */
    uint8_t i0, i1, i2;               /* 30h-32h: integer (16/24 bit) */
    double  number;                   /* 30h-33h */
    const char *word;                 /* mnemonic text in iface_rx_buf */
} cmd_token;
enum { K_OFF = 0, K_ON = 1, K_INT = 2, K_INT16 = 3, K_NUMBER = 4, K_NONE = 5, K_QUERY = 6 };

/* elsewhere */
void set_speed(uint8_t n);  void cdp_write_slot(uint8_t n, double v); bool cdp_slot_valid(uint8_t n);
void iee_store_address(uint8_t cfg); void rtl_go_local(void); void emo_set_count(int32_t n);
void tol_set(bool on, bool other); void zer_set_reference(double x); void dbm_set_reference(double x);
uint8_t func_to_cmd_index(void); void jcv_set_ptr(uint16_t a); void diag_clear_counters(void);
uint8_t rms_set_byte(uint8_t n); void mains_set(bool sixty); void cr_set(bool on);
uint8_t nv_get_iface_config(void); void cal_mode_enter(void); bool cal_step_allowed_c(void);
void cal_seal_normal(void); void cal_seal_altered(void); void min_reset(void); void max_reset(void);
bool range_by_value(double v, unsigned (*fs)(double)); unsigned range_find_for_value(double v);
void meas_set_function_flags(void); void meas_restart(void); void trigger_clear(void);
void trigger_restart_measure(void); void cal_status_or_dashes(void); void result_restart(void);
void speed_store(void); void speed_load(void); void internal_temp_init(void);
void lcd_show_error(uint8_t code); void menu_exit(bool a);
bool range_can_go_down_c(void); bool range_can_go_up_c(void);
uint8_t i2cA_read1(uint8_t addr, bool *nack); void i2cA_write1(uint8_t addr, uint8_t v);
uint8_t i2cB_read1(uint8_t addr, bool *nack); bool i2cB_write1(uint8_t addr, uint8_t v);
extern const uint8_t resolution_table[20][3];
extern uint8_t cdp_slot;               /* bit 7 = slot number given, value follows */
extern uint8_t iface_mode;             /* XDATA 0x005A */
extern bool trig_refused, bus_trigger_armed, ext_trigger_seen, tol_hold;  /* 23h.6, 24h.5, 24h.4, 27h.3 */
extern bool probe_hold, hold_active;   /* 24h.7, 24h.6 */
extern bool minmax_valid;              /* 26h.5 */

/* ROM 0x6F24: side effects per command index. bit 0 restart the measurement, bit 2 remember the
 * speed, bit 3 reset min/max, bit 4 dB and relative off, bit 6 restart the result record,
 * bit 7 min/max no longer valid. Function commands 0xDF, RNG/TRG/RMS/range keys 0x41,
 * DBM/ZER/MSP/RSL 0xC9, CAL 0xD1, CLM 0x08, SIX 0x01. */
extern const uint8_t cmd_actions[49];

static unsigned func(void) { return meter_state & 0x0F; }
static void set_trigger(unsigned t) { meter_mode = (uint8_t)((meter_mode & 0xF3) | (t << 2)); }  /* 0 I 1 B 2 E */
static unsigned trigger(void) { return (meter_mode >> 2) & 3; }

/* 0x409C task_keyboard (fnsel_dispatch). `remote` = token came from the interface (2Dh.3). */
void task_keyboard(cmd_token *t, bool remote)
{
    int new_func = -1;
    bool error = false;
    bool func_cmd = t->index < 0x13;                     /* 2Dh.1: function or range command */
    uint8_t actions = cmd_actions[t->index];
    uint8_t kind = t->kind & 0x47;

    if (kind == K_QUERY) {                               /* any query: queue the reply */
        if (cal_mode && (t->index == 23 || t->index == 24)) error = true;   /* no MIN?/MAX? in cal */
        else reply_pending_cmd = t->index;
        goto finish;
    }
    if ((t->kind & 0x40) && t->i1 == 0) goto finish;     /* empty second parameter */
    if (current_10a && func_cmd && t->index != 8 && t->index != 9) {   /* 10 A input: only IDC/IAC */
        if (!remote) lcd_show_error((uint8_t)(t->index - 0x13));
        error = true; goto finish;
    }

    switch (t->index) {
    case 0: peak_mode_b1 = 0; peak_mode_b0 = 1; new_func = 0; break;   /* VPU */
    case 1: peak_mode_b1 = 1; peak_mode_b0 = 0; new_func = 0; break;   /* VPL */
    case 2: peak_mode_b1 = 1; peak_mode_b0 = 1; new_func = 0; break;   /* VPP */
    case 3: case 4: case 5: case 6: case 7: case 8: case 9:            /* VDC .. IAC */
        new_func = t->index - 2; break;
    case 10: case 11: case 12: case 13:                                /* TPP TPN TNP TNN */
        time_start_negslope = (t->index - 10) >> 1;
        time_stop_negslope  = (t->index - 10) & 1;
        new_func = 8; break;
    case 14: case 15: case 16: case 17: case 18: new_func = t->index - 5; break;   /* CAP..CON */
    case 19: /* FNC <mnemonic>: re-parse the word as a function command (cmd_fnc_lookup) */ break;
    case 20: func_cmd = true; break;                                   /* RNG */
    case 21:                                                           /* DBM */
        if (kind == K_ON) {
            if (func() == 0 || func() > 3 || cal_mode) error = true;   /* voltage functions only */
            else { if (db_mode) goto finish; db_mode = true; zero_mode = false; }
        } else if (kind == K_OFF) {
            if (!db_mode) goto finish;
            db_mode = false; zero_mode = false;
        } else {
            dbm_set_reference(t->number);
            if (!remote) db_mode = true;
            if (!db_mode) goto finish;
            zero_mode = false;
        }
        break;
    case 22:                                                           /* ZER */
        if (func() == 13) { error = true; goto finish; }
        if (kind == K_ON)       { if (cal_mode) error = true; else zero_mode = true; }
        else if (kind == K_OFF) zero_mode = false;
        else if (t->kind & 0x40) {                                     /* ZER MIN / ZER MAX */
            if (t->word[0] != 'M' || cal_mode || !minmax_valid) error = true;
            else {
                /* copies the min/max reading (without dB: 0x0091, with dB: 0x008D) to 0x0079 */
                for (int i = 0; i < 4; i++) xram[0x0079 + i] = xram[(db_mode ? 0x008D : 0x0091) + i];
                zero_mode = true;
            }
        } else if (kind == K_NUMBER) {
            zer_set_reference(t->number);
            if (!remote) zero_mode = true;
        }
        break;
    case 23: case 24:                                                  /* MIN, MAX: show */
        if (cal_mode) { error = true; goto finish; }
        reply_pending_cmd = t->index; break;
    case 25: if (cal_mode) { error = true; goto finish; } break;       /* CLM (action: reset) */
    case 26:                                                           /* MSP n */
        if (t->i0 == 0 || t->i0 > 3) error = true;
        else if (!cal_mode) set_speed(t->i0);
        else error = (meter_mode & 3) != t->i0 - 1;                    /* fixed in cal mode */
        break;
    case 27: {                                                         /* RSL n: digits -> speed */
        uint8_t idx = func_to_cmd_index();
        int s = -1;
        for (int i = 0; i < 3; i++) if (resolution_table[idx][i] == t->i0) { s = i; break; }
        if (s < 0) error = true;
        else if (!cal_mode) set_speed((uint8_t)(s + 1));
        else error = (meter_mode & 3) != s;
        break; }
    case 28: {                                                         /* TRG */
        uint8_t before = meter_mode;
        if (!remote) { if (t->i0 == 0) set_trigger(0); else { set_trigger(2); tol_hold = true; } }
        else switch (t->word[0] & 0x5F) {
            case 'I': if (cal_mode) error = true; else set_trigger(0); break;
            case 'B': set_trigger(1); tol_hold = false; break;
            case 'E': set_trigger(2); tol_hold = false; break;
            default:  error = true;
        }
        if (meter_mode != before) hold_active = false;
        break; }
    case 29:                                                           /* X: trigger */
        if (kind == K_INT && t->i0 != 1) { error = true; goto finish; }
        if ((trigger() == 1 || trigger() == 2) && (!cal_mode || !cal_step_allowed_c())) {
            bus_trigger_armed = remote;
            trigger_restart_measure();
            ext_trigger_seen = true;
        } else if (remote) error = true;
        break;
    case 30:                                                           /* CAL */
        if (kind == K_ON || kind == K_OFF) {
            if (kind == K_ON) { if (!cal_enable) error = true; else cal_mode_enter(); }
            else if (!cal_mode) cal_enable = false;                    /* second CAL OFF */
            else { cal_mode = false; if (!(xram[0x00EB] & 0x10)) set_trigger(0); }
        } else if (kind == K_INT && t->i0 < 2 && ((cal_mode && remote) || (cal_enable && !remote) ||
                                                   (cal_enable && remote))) {
            cal_hot = t->i0 & 1;                                       /* CAL ON,n / CHECK CAL n */
            if (!cal_mode) cal_mode_enter();
        } else error = true;
        break;
    case 31:                                                           /* OUT S / OUT N */
        switch (t->word[0] & 0x5F) {
            case 'S': out_no_header = false; break;
            case 'N': if (cal_mode) { error = true; goto finish; } out_no_header = true; break;
            default:  error = true;
        }
        break;
    case 32:                                                           /* JCV */
        if (kind == K_INT16) { jcv_set_ptr((uint16_t)(t->i0 | t->i1 << 8)); reply_pending_cmd = 32; }
        else if (!cal_mode) error = true;
        else diag_clear_counters();
        break;
    case 33: reply_pending_cmd = 33; break;                            /* DMP */
    case 34:                                                           /* CDP */
        if (!cal_mode) { error = true; goto finish; }
        if (!(t->kind & 0x20)) {                                       /* second parameter: value */
            if (!(cdp_slot & 0x80)) error = true;
            else {
                cdp_slot &= 0x7F;
                double v = (kind == K_INT) ? t->i0 : t->number;       /* cdp_int_to_fp */
                cdp_write_slot(cdp_slot, v);
            }
        } else if (!(t->kind & 0x40)) {                                /* first parameter: slot */
            if (kind == K_INT && cdp_slot_valid(t->i0)) cdp_slot = (uint8_t)(t->i0 | 0x80);
            else error = true;
        } else switch (t->word[0] & 0x5F) {                            /* CDP R / CDP S */
            case 'R': cal_seal_normal();  actions = 0x41; break;
            case 'S': cal_seal_altered(); actions = 0x41; break;
            default:  error = true;
        }
        break;
    case 35: if (!cal_mode) { error = true; goto finish; } rms_set_byte(t->i0); break;  /* RMS */
    case 36: mains_set(kind == K_ON); break;                           /* SIX */
    case 37: cr_set(kind == K_ON); break;                              /* CR  */
    case 38:                                                           /* IEE n (0..30) */
        if ((!remote || (xram[0x0058] & 0x80)) && t->i0 < 31)
            iee_store_address((uint8_t)((nv_get_iface_config() & 0x80) | t->i0));
        else error = true;
        break;
    case 39: break;                                                    /* MTS (query only) */
    case 40:                                                           /* EMO / TOL */
        if (!remote || (xram[0x0058] & 0x80)) tol_set(kind == K_ON, kind != K_ON && kind != K_OFF);
        else if (iface_mode != 3) error = true;
        else if (t->kind & 0x40) { if ((t->word[0] & 0x5F) == 'A') emo_continuous = true; else error = true; }
        else emo_set_count(kind == K_NONE ? 1 : (int32_t)(t->i0 | t->i1 << 8 | t->i2 << 16));
        break;
    case 41: if (kind == K_ON) rtl_go_local(); break;                  /* rTL (CHECK menu) */
    case 42: if (range_can_go_down_c()) { meter_state -= 0x10; } else actions = 0; break;   /* key */
    case 43: if (range_can_go_up_c())   { meter_state += 0x10; } else actions = 0; break;
    case 44: meter_autorange = t->kind & 1; break;                     /* AUTO key */
    case 45: min_reset(); break;
    case 46: max_reset(); break;
    default: break;
    }

    /* a mnemonic for a function/range command other than AUTO, or AUTO in calibration mode */
    if (func_cmd && (t->kind & 0x40) && ((t->word[0] & 0x5F) != 'A' || cal_mode)) error = true;

    if (new_func >= 0 && !error && (int)func() != new_func) {
        if (func() == 10) { xram[0x00C1] |= 8; internal_temp_init(); }
        meter_state = (uint8_t)((meter_state & 0xF0) | new_func);
        if (new_func != 8 && tol_hold) { if (!cal_mode) set_trigger(0); tol_hold = false; }
        xram[0x00A4] = new_func == 13 ? 8 : 9;                         /* func_change_hook 0x3A79 */
        xram[0x00A0] &= 0xFC;
        if (new_func != 0) peak_mode_b0 = peak_mode_b1 = false;
        hold_active = false;
        /* 25h.7 = 4-wire input (RFW, TDC) */
    }

    if (!error) {
        if ((actions & 0x04) && !cal_mode) speed_store();
        if (func_cmd) {
            if (t->index != 20) { if (!cal_mode) speed_store(); else speed_load(); }
            if (kind == K_NUMBER) { if (!range_by_value(t->number, range_find_for_value)) error = true; meter_autorange = false; }
            else { if (t->index != 20) meas_set_function_flags(); if (!cal_mode) meter_autorange = true; }
        }
        if (actions & 0x10) { db_mode = false; zero_mode = false; }
        if (actions & 0x08) { min_reset(); max_reset(); }
        if (actions & 0x80) minmax_valid = false;
        if (remote && (xram[0x00EB] & 0x10)) menu_exit(xram[0x00EB] & 0x80);
        if (actions & 0x01) { meas_restart(); trigger_clear(); cal_status_or_dashes(); }
        if (actions & 0x40) result_restart();
    }
finish:
    if (error && remote) trig_refused = true;                          /* 23h.6 -> interface status */
    if (trigger() == 0) xram[0x0066] |= 8;
}

/* ======================================================================================== */
/* keys                                                                                     */
/* ======================================================================================== */
extern const uint8_t key_code_table[16];    /* ROM 0x5974 */

/* 0x5984: PCF8574 at 0x48 on bus B. Rows and columns are read in two halves and ORed;
 * 0xFF = no key. */
static uint8_t key_read_matrix(bool *nack)
{
    if ((*nack = !i2cB_write1(0x48, 0xF0))) return 0xFF;
    uint8_t a = i2cB_read1(0x48, nack);
    if (*nack || (*nack = !i2cB_write1(0x48, 0x0F))) return 0xFF;
    return (uint8_t)(a | i2cB_read1(0x48, nack));
}
static void key_debounce_delay(void) { for (volatile int i = 0; i < 20 * 113; i++) ; }   /* 0x5A84, ~5 ms */

/* 0x5934 key_scan: one debounced key number 0-15 into 35h (0xFF = none), one per press */
static bool key_down;            /* 2Bh.2 */
uint8_t key_scan(uint8_t pending)
{
    bool nack;
    uint8_t m = key_read_matrix(&nack);
    if (nack) return pending;
    if (m == 0xFF) {                                    /* released */
        if (key_down) { key_debounce_delay(); if (key_read_matrix(&nack) == 0xFF) key_down = false; }
        return pending;
    }
    if (pending != 0xFF || key_down) return pending;
    key_debounce_delay();
    m = key_read_matrix(&nack);
    for (int k = 15; k >= 0; k--)
        if (key_code_table[k] == m) { key_down = true; return (uint8_t)k; }
    return pending;
}

/* 0x31C5 probe_hold_poll: PCF8574 at 0x4E on the option bus. Input bit 7 = the data-hold probe's
 * button (low = pressed, debounced); output bit 1 = its LED (low = on, while holding); bit 0 =
 * NOT adc_alt_mode. In time interval with bus/external trigger the probe button acts as the
 * trigger. Without a probe (no ACK) the hold state is cleared. */
void probe_hold_poll(void)
{
    bool nack;
    uint8_t v = i2cA_read1(0x4E, &nack);
    if (nack) { hold_active = false; probe_hold = false; return; }
    bool pressed = !(v & 0x80);
    if (!pressed) {
        if (probe_hold) { key_debounce_delay(); if (i2cA_read1(0x4E, &nack) & 0x80) probe_hold = false; }
    } else if (!probe_hold) {
        key_debounce_delay();
        if (!(i2cA_read1(0x4E, &nack) & 0x80)) {
            probe_hold = true;
            if (trigger() == 2) hold_active = false;          /* external trigger: acts as X */
            else if (trigger() == 0) hold_active = !hold_active;
        }
    }
    i2cA_write1(0x4E, (uint8_t)((hold_active ? 0xFD : 0xFF) & 0xFE) | !adc_alt_mode);
}

/* ======================================================================================== */
/* menus (task_display_menu 0x2B5F, 862 bytes)                                              */
/* ======================================================================================== */
/* With SHIFT, keys 10-15 open edit menus: 10 the dB reference (menu_show_dbm_ref), 11 the zero
 * reference, 13 the min/max display, 14 CHECK. CHECK steps: CAL 0 / CAL 1 (only with cal
 * enabled), then with an interface: rTL, ADDr nn, T.ONLY, Cr; then 60H 0/1 and SOFT xx. The
 * value being edited is typed with the digit keys (menu_digit_key 0x315B: two digits, the second
 * shown as '-' until typed; menu_key_to_char 0x2FF5 maps key 15 to '-' and 0/1 to on/off).
 * ENTER makes a token for the executor above (command indices 30, 41, 38, 40, 37, 36), so the
 * menu and the remote commands share all checks. */
