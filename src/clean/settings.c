/* settings.c (hand-cleaned) - stored settings of the PM2525 (firmware S25)
 *
 * Rewritten from the assembly at 0x5ACF-0x5BCA, 0x3D7F-0x3E5A and 0x5B93-0x5BCA.
 *
 * The small settings live in the battery-backed 6116 RAM, each byte stored three times right
 * after the three calibration copies, and read with a 2-of-3 vote that repairs a bad copy:
 *
 *   byte n (1..5) at XDATA 0x03CA+n-1, 0x0599+n-1, 0x0768+n-1
 *     1  interface config: bits 0-4 GPIB address (0-30, invalid or 31 -> 22), bit 7 talk-only (TOL)
 *     2  mains frequency: non-zero = 60 Hz (written as 0x55), 0 = 50 Hz   (SIX ON/OFF, CHECK "60H")
 *     3  carriage return after every output: non-zero = on (0x55)     (CR ON/OFF, CHECK "Cr")
 *     4  calibration seal: 'N' normal, 'a' calibration data altered  (CDP R / CDP S)
 *   (byte 5 of copy 3 overlaps the error counter at 0x076C and is not used.)
 *
 * The RMS byte (AC zero offset, RMS n in calibration mode) is stored separately at 0x07FD as
 * value, value+0x55, value+0xAA, so that a corrupted byte is detected.
 */
#include <stdbool.h>
#include <stdint.h>

extern uint8_t xram[0x800];             /* battery-backed RAM */
extern uint8_t meter_state, meter_mode; /* IRAM 0x20, 0x21 */
extern bool mains_60hz, cr_enabled;     /* 22h.4, 23h.5 */
extern const uint8_t valid_range_masks[14][3];   /* ROM 0x6ED4 */

#define FUNCTION()   (meter_state & 0x0F)
#define SPEED()      (meter_mode & 0x03)         /* 0 = SPEED 1, 1 = SPEED 2, 2 = SPEED 3 */
#define SET_SPEED(s) (meter_mode = (uint8_t)((meter_mode & 0xFC) | (s)))

static const uint16_t nv_copy_base[3] = { 0x03CA, 0x0599, 0x0768 };  /* nv_addr_copy1..3 */

/* 0x5B1B nv_setting_read: 2-of-3 vote. If two copies agree the third is overwritten.
 * Returns false (F0 = 1 in the original) if all three copies differ. */
bool nv_setting_read(uint8_t n, uint8_t *value)
{
    uint8_t c1 = xram[nv_copy_base[0] + n - 1];
    uint8_t c2 = xram[nv_copy_base[1] + n - 1];
    uint8_t c3 = xram[nv_copy_base[2] + n - 1];
    if (c3 == c2) { if (c3 != c1) xram[nv_copy_base[0] + n - 1] = c3; *value = c3; return true; }
    if (c3 == c1) { xram[nv_copy_base[1] + n - 1] = c3; *value = c3; return true; }
    if (c1 == c2) { xram[nv_copy_base[2] + n - 1] = c1; *value = c1; return true; }
    return false;
}

/* 0x5B67 nv_setting_write: same value into all three copies */
void nv_setting_write(uint8_t n, uint8_t value)
{
    for (int k = 0; k < 3; k++)
        xram[nv_copy_base[k] + n - 1] = value;
}

/* ---- byte 1: interface configuration ---------------------------------------------- */

/* 0x5ACF nv_get_iface_config: GPIB address 31 or unreadable -> default 22 written back */
uint8_t nv_get_iface_config(void)
{
    uint8_t v;
    if (!nv_setting_read(1, &v) || (v & 0x1F) == 0x1F) {
        v = 22;
        nv_setting_write(1, v);
    }
    return v;
}

void nv_set_iface_config(uint8_t v) { nv_setting_write(1, v); }          /* 0x5AE3 */

/* ---- byte 2: mains frequency -------------------------------------------------------- */
/* The flag selects the integration gate loaded by the INT1 handler:
 * Timer 1 = 0xB1E0 (20.000 ms, 50 Hz) or 0xBEE5 (16.667 ms, 60 Hz). */
static void mains_apply(uint8_t v) { mains_60hz = (v != 0); }
void mains_set_60hz(void) { nv_setting_write(2, 0x55); mains_apply(0x55); }   /* 0x5AE9  SIX ON  */
void mains_set_50hz(void) { nv_setting_write(2, 0x00); mains_apply(0x00); }   /* 0x5AF5  SIX OFF */
void mains_load_setting(void)                                                  /* 0x5AED */
{
    uint8_t v;
    if (!nv_setting_read(2, &v)) { v = 0; nv_setting_write(2, v); }
    mains_apply(v);
}

/* ---- byte 3: CR after every output -------------------------------------------------- */
static void cr_apply(uint8_t v) { cr_enabled = (v != 0); }
void cr_set_on(void)  { nv_setting_write(3, 0x55); cr_apply(0x55); }           /* 0x5B02 */
void cr_set_off(void) { nv_setting_write(3, 0x00); cr_apply(0x00); }           /* 0x5B0E */
void cr_load_setting(void)                                                     /* 0x5B06 */
{
    uint8_t v;
    if (!nv_setting_read(3, &v)) { v = 0; nv_setting_write(3, v); }
    cr_apply(v);
}

/* ---- byte 4: calibration seal -------------------------------------------------------- */
void cal_seal_normal(void)  { nv_setting_write(4, 'N'); }                      /* 0x5B86  CDP R */
void cal_seal_altered(void) { nv_setting_write(4, 'a'); }                      /* 0x5B8A  CDP S */

/* 0x5B74 cal_seal_check: true (C = 1) when the seal says "altered": the meter then shows NC on
 * every range and flags every CDP ? line with N. An unreadable seal is reset to 'N'. */
bool cal_seal_check(void)
{
    uint8_t v;
    if (nv_setting_read(4, &v)) {
        if (v == 'a') return true;
        if (v == 'N') return false;
    }
    cal_seal_normal();
    return false;
}

/* ---- RMS byte: AC zero offset --------------------------------------------------------- */
void rms_set_byte(uint8_t v)                                                   /* 0x5BBB */
{
    xram[0x07FD] = v;
    xram[0x07FE] = (uint8_t)(v + 0x55);
    xram[0x07FF] = (uint8_t)(v + 0xAA);
}

/* 0x5B93 rms_get_byte: accept the value if two of the three encodings agree, else 'A' (65) */
uint8_t rms_get_byte(void)
{
    uint8_t a = xram[0x07FD];
    uint8_t b = (uint8_t)(xram[0x07FE] - 0x55);
    uint8_t c = (uint8_t)(xram[0x07FF] - 0xAA);
    uint8_t v;
    if (a == b && a == c) return a;
    if (a == b || a == c) v = a;
    else if (b == c)      v = b;
    else                  v = 'A';
    rms_set_byte(v);
    return v;
}

/* ---- SPEED ---------------------------------------------------------------------------- */
/* XDATA 0x01CC keeps the VDC speed only: the manual's "last selected speed stays valid". */

/* 0x3DE8 speed_store: default speed when a function is selected (cmd = command index 2Eh) */
void speed_store(uint8_t cmd)
{
    switch (cmd) {
    case 0x10: SET_SPEED(0); break;                    /* TDC (degC): SPEED 1 */
    case 0x12: SET_SPEED(2); break;                    /* CON: SPEED 3 */
    case 0x03: SET_SPEED(xram[0x01CC] & 3); break;     /* VDC: the remembered VDC speed */
    default:   SET_SPEED(1); break;                    /* everything else: SPEED 2 */
    }
}

/* 0x3E14 speed_load: first speed (SPEED 1, 2, 3) that has any valid range for the function;
 * for VDC it is remembered in 0x01CC. Called on entry to calibration mode (cal_mode_enter) and
 * from one keyboard path (0x4788). */
void speed_load(void)
{
    for (uint8_t s = 0; s < 3; s++) {
        if (valid_range_masks[FUNCTION()][s]) {
            SET_SPEED(s);
            if (FUNCTION() == 1)                       /* VDC */
                xram[0x01CC] = SPEED();
            return;
        }
    }
}
