/* main.c (hand-cleaned) - reset, initialisation, main loop and interrupt handlers (firmware S25)
 *
 * Rewritten from the assembly at 0x0000-0x0110, 0x51FA-0x5343 and 0x534D-0x543B.
 * Hardware: Intel 8031AH, 12 MHz crystal (1 us machine cycle), 27C256 EPROM, 6116 battery RAM.
 *
 * Structure: there is no RTOS. main_loop() calls every task once per pass, each task does one small
 * step and returns. Tasks keep their state in a 13-14 byte context that they swap between XDATA and
 * IRAM 0x2A-0x37 on entry/exit (measurement 0x00BE, parser 0x00DB, menu 0x00A5, ...).
 * P1.2 is pulsed regularly: it retriggers the external watchdog.
 */
#include <stdbool.h>
#include <stdint.h>

extern volatile uint8_t P1, P3, IE, TCON, SCON, PSW, SP, TL0, TH0, TL1, TH1;
extern volatile bool P1_2, TXD, TR0, TR1, TF0, EX1, ET1;
extern uint8_t xram[0x800];
extern uint8_t iram[0x80];
extern uint8_t meter_state, meter_mode;           /* 0x20, 0x21 */
extern uint8_t rx_count;                          /* 0x0D: remote line state */
extern uint8_t iface_chan_hi, iface_chan_lo;      /* 0x1D/0x1E: active interface channel descriptor */
extern bool cal_enable, emo_continuous, display_due, mains_60hz;

#define WATCHDOG_KICK() do { P1_2 = 0; P1_2 = 1; } while (0)
#define FUNCTION()      (meter_state & 0x0F)

/* tasks and helpers (other modules) */
void i2c_both_buses_stop(void);   void i2cB_stop(void);  void i2cA_stop(void);
void iface_poll_channel(uint16_t desc);           void iface_send_channel(uint16_t desc, uint8_t cfg);
bool iface_receive_channel(uint16_t desc, uint8_t *v);
bool iface_status_ready(uint16_t desc);
void task_remote_parse(void);   void task_display_menu(void);  void task_keyboard(void);
void task_5468(void);           void task_trigger(void);       void task_5D02(void);
void task_measure(void);        void task_display_update(void); void task_remote_reply(void);
void cr_load_setting(void);     uint8_t nv_get_iface_config(void);
void min_reset(void); void max_reset(void); void iface_report_status(void); void result_record_clear(void);
void menu_init(void); void reply_init(void); void display_timer_init(void); void meas_init(void);
void trigger_clear(void); void lcd_show_message(uint16_t msg); void lcd_refresh(void);
bool i2cB_start_write(uint8_t a); bool i2cB_send_byte(uint8_t b);
void fp_copy_rom_to_xdata(uint16_t rom, uint16_t xd);
extern const uint8_t lcd_test_pattern[25];        /* ROM 0x532B */

#define XDATA_ADDR_DESC1 0x0053                   /* interface channel descriptor 1 (slot 0x58) */
#define XDATA_ADDR_DESC2 0x0056                   /* channel descriptor 2 (slot 0x5E)          */

/* --------------------------------------------------------------------------- reset (0x0000) */
/* 0x0000: NOP NOP NOP, then 0x0003: LJMP start. 0x0003 is also the INT0 vector, but INT0 is used as
 * SCL of the option bus, so holding that line low for long would restart the meter. */

/* --------------------------------------------------------------------------- 0x5275 */
/* read_option_switches: settings byte 1 = interface configuration. Talk-only (bit 7) also selects
 * continuous measurement output (EMO A). Returns the configuration byte for the interface: 0x60 | addr. */
uint8_t read_option_switches(void)
{
    uint8_t cfg = nv_get_iface_config();
    bool talk_only = (cfg & 0x80) != 0;
    iram[0x23] = (uint8_t)((iram[0x23] & ~0x08) | (talk_only ? 0x08 : 0));   /* 23h.3 */
    emo_continuous = talk_only;                                             /* 23h.2 */
    xram[0x95] = xram[0x96] = xram[0x97] = 0;                               /* EMO count = 0 */
    return (uint8_t)((cfg & 0x1F) | 0x60);
}

/* --------------------------------------------------------------------------- 0x5226 */
/* iface_boot_handshake: introduce the meter to the interface boards (two channel descriptors). */
static void iface_boot_handshake(void)
{
    xram[0x00EB] = 0x08;
    iface_send_channel(XDATA_ADDR_DESC1, read_option_switches());
    if (xram[0x0055] & 0x80) {                    /* a board answered on channel 1 */
        uint8_t v;
        while (!iface_receive_channel(XDATA_ADDR_DESC1, &v)) { }
        xram[0x0059] = v;
        if (v == 0)
            iface_send_channel(XDATA_ADDR_DESC1, read_option_switches() | 0x80);
        else if (v == 3)
            iface_send_channel(XDATA_ADDR_DESC1, 0x60);
    }
    iface_send_channel(XDATA_ADDR_DESC2, 0x00);
    /* then: iface_select_pending(), cr_load_setting(), continue in the parser task tail */
}

/* --------------------------------------------------------------------------- 0x5295 */
void system_init(void)
{
    IE = 0; TCON = 0; SCON = 0; PSW = 0;
    WATCHDOG_KICK();
    i2c_both_buses_stop();

    uint8_t keep23 = iram[0x23];
    for (int a = 0x08; a < 0x60; a++) iram[a] = 0;   /* clear registers banks 1-3, bits, variables */
    iram[0x23] = keep23 & 0x30;                      /* keep 23h.4 (CR) and 23h.5 */
    xram[0x95] = xram[0x96] = xram[0x97] = 0;        /* EMO count */

    meter_state = 0xA1;                              /* VDC, range 2 (20 V), autorange on */
    if (xram[0x01CC] >= 3) xram[0x01CC] = 1;         /* stored VDC speed, default SPEED 2 */
    meter_mode = xram[0x01CC];
    iram[0x22] = 0x08;

    fp_copy_rom_to_xdata(0x6FD0, 0x0079);            /* zero/relative reference = ~0 */
    fp_copy_rom_to_xdata(0x6FDC, 0x0075);            /* dB reference impedance = 600 ohm */
    min_reset(); max_reset();
    xram[0x0066] = 0x08;                             /* result flags: no reading yet */
    iface_report_status();
    result_record_clear();
    menu_init(); reply_init(); display_timer_init(); meas_init(); trigger_clear();

    lcd_show_message(0x70E4);                        /* " -------" */
    lcd_refresh();
    WATCHDOG_KICK();
    /* power-up lamp test: write the all-segments pattern straight to the PCF8576 */
    i2cB_start_write(0x70);
    for (int i = 25; i > 0; i--) i2cB_send_byte(lcd_test_pattern[i - 1]);
    i2cB_stop();
}

/* --------------------------------------------------------------------------- 0x51FA */
void main_loop(void);
void start(void)
{
    SP = 0x60;
    P1 = 0xC3;
    P1_2 = 1;
    i2c_both_buses_stop();
    iface_boot_handshake();
    uint8_t keep23 = iram[0x23];
    system_init();
    iram[0x23] = keep23 & 0x2C;
    /* CAL key: held at reset it pulls P3.1 (TXD) low -> calibration enable */
    TXD = 1;
    if (!TXD)
        cal_enable = true;                           /* 22h.5 */
    else {
        P1_2 = 1;
        iram[0x23] = (uint8_t)((iram[0x23] & ~0x10) | (P1_2 ? 0 : 0x10));   /* 23h.4 = !P1.2 */
    }
    main_loop();
}

/* --------------------------------------------------------------------------- 0x00E4 */
/* iface_select_pending: choose the interface channel that has something to do */
void iface_select_pending(void)
{
    if (xram[0x0058] & 0x80)      { iface_chan_hi = 0x00; iface_chan_lo = 0x56; xram[0x005A] = 0; }
    else if (xram[0x0055] & 0x80) { iface_chan_hi = 0x00; iface_chan_lo = 0x53; xram[0x005A] = xram[0x0059]; }
    else                          { iface_chan_hi = 0x00; iface_chan_lo = 0x00; }
}

/* --------------------------------------------------------------------------- 0x002B */
void main_loop(void)
{
    for (;;) {
        PSW = 0;
        P3 &= 0xDB;                                   /* periodic I2C bus reset (both SCL low) */
        i2cB_stop(); i2cA_stop();
        P1 |= 0xC6; P3 |= 0x3D;
        SP = 0x60;                                    /* the stack is reset every pass */

        uint16_t chan = (uint16_t)(iface_chan_hi << 8 | iface_chan_lo);
        if (chan) {
            iface_poll_channel(chan);                 /* talk to the interface board / Pico */
            if (xram[0x00EB] & 0x02) { xram[0x00EB] &= ~0x02; system_init(); }   /* device clear */
            if (rx_count & 0x80) {                    /* a remote line is waiting */
                if (rx_count & 0x3F) iram[0x23] &= ~0x08;
                task_remote_parse();
            }
        }
        task_display_menu();
        task_keyboard();
        task_5468();
        task_trigger();
        task_5D02();
        task_measure();
        if (display_due) task_display_update();       /* 24h.1 */
        task_remote_reply();

        /* 16-bit down counter, XDATA 0x00A2 = low byte, 0x00A3 = high byte (display_timer_init sets 0x0505):
         * sets display_due when it runs out */
        uint16_t t = (uint16_t)(xram[0x00A3] << 8 | xram[0x00A2]);
        if (t) {
            if (--t == 0) display_due = true;
            xram[0x00A2] = (uint8_t)t; xram[0x00A3] = (uint8_t)(t >> 8);
        }
        /* every 50 passes: force a display update and service both interface channels */
        if (--xram[0x0012] == 0) {
            xram[0x0012] = 50;
            display_due = true;
            iface_poll_channel(XDATA_ADDR_DESC2);
            iface_poll_channel(XDATA_ADDR_DESC1);
            uint8_t v;
            if ((xram[0x0055] & 0x80) && iface_receive_channel(XDATA_ADDR_DESC1, &v)) {
                xram[0x0059] = v;
                if (v == 0) xram[0x0053] |= 0x80;
            }
            iface_select_pending();
        }
    }
}

/* =========================================================================== interrupts
 * Timer 1 counts 1 us ticks, Timer 0 counts edges on P3.4 (the input comparator) in the timer
 * functions (TMOD = 0x15). The handlers keep their counter extensions in IRAM 0x0F-0x11, 0x16-0x18.
 * Flags: 27h.5 settle-timer mode, 25h.1 counter-extension mode, 25h.0 gate open, 23h.0 T1 countdown. */

/* 0x534D isr_timer0 */
void isr_timer0(void)
{
    if (iram[0x27] & 0x20) {                         /* settle timer: kick watchdog, count 1Bh down */
        WATCHDOG_KICK();
        if (--iram[0x1B] == 0) { iram[0x27] &= ~0x20; TR0 = 0; }
        return;
    }
    if (iram[0x25] & 0x02) { iram[0x0F]++; return; } /* extend a running count */
    if (FUNCTION() == 8) {                           /* time interval: an edge on the input */
        TR0 = 0;
        if (!(iram[0x25] & 0x01)) {                  /* start edge */
            TR1 = 1;                                 /* start the 1 us timer */
            iram[0x25] |= 0x01;
            TXD = (iram[0x21] & 0x10) != 0;          /* comparator slope for the stop edge */
            TL0 = 0xFF; TH0 = 0xFF;                  /* next edge overflows T0 again */
            TR0 = 1;
            iram[0x27] |= 0x02;                      /* time_started */
        } else {                                     /* stop edge */
            TR1 = 0; TR0 = 0; iram[0x25] &= ~0x01;
        }
    } else if (FUNCTION() == 10) {
        iram[0x10]++;                                /* frequency: extend the edge count */
    } else {
        TR1 = 0; TR0 = 0; iram[0x25] &= ~0x01;
    }
}

/* 0x5398 isr_int1_gate: INT1 edge (comparator / gate). Stops T0 and starts the mains-period gate
 * on T1: 20.000 ms (0xB1E0) at 50 Hz, 16.667 ms (0xBEE5) at 60 Hz. */
void isr_int1_gate(void)
{
    EX1 = 0;
    TR0 = 0;
    if (iram[0x25] & 0x02) { iram[0x25] &= ~0x01; return; }
    if (mains_60hz) { TL1 = 0xE5; TH1 = 0xBE; }
    else            { TL1 = 0xE0; TH1 = 0xB1; }
    TR1 = 1;
    iram[0x27] &= ~0x02;
    iram[0x27] |= 0x01;
}

/* 0x53B8 isr_timer1 */
void isr_timer1(void)
{
    if (iram[0x23] & 0x01) {                         /* plain countdown use of T1 */
        if (--iram[0x18] == 0) TR1 = 0;
        return;
    }
    uint8_t f = FUNCTION();
    if (f == 8 || (f == 9 && !(iram[0x27] & 0x01))) {
        /* time interval / capacitance: 32-bit extension of the 1 us count in 0x0F..0x11 */
        if (++iram[0x0F] == 0 && ++iram[0x10] == 0) iram[0x11]++;
        return;
    }
    /* frequency: one gate period of 65.536 ms elapsed; 15h counts the periods of the gate.
     * NOTE: this branch is reconstructed from a partial reading (0x53EC-0x5437); details are approximate. */
    if (--iram[0x15] != 0) return;
    if (meter_state & 0x50) { /* higher ranges: just close the gate */ }
    else if (iram[0x21] & 0x01) {
        /* SPEED 2: sample T0 twice (0x16-0x18) and run two short periods */
        iram[0x16] = TL0; iram[0x17] = TH0; iram[0x18] = 0;
        iram[0x15] = 2;
        iram[0x25] |= 0x01;
        goto close_check;
    } else {
        TR0 = 0;
        iram[0x16] = TL0; iram[0x17] = TH0;          /* edge count at the gate end */
        iram[0x18] = (uint8_t)(iram[0x10] + (TF0 ? 1 : 0));
        TR0 = 1;
        iram[0x15] = 16;                             /* 16 x 65.536 ms = 1.048576 s */
        iram[0x25] |= 0x01;
    }
close_check:
    if (--iram[0x14] == 0) TR0 = 0;                  /* repetitions (10 on the lowest range) */
}
