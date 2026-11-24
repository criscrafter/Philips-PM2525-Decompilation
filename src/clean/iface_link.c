/* iface_link.c (hand-cleaned) - the meter side of the option-board link (firmware S25)
 *
 * Rewritten from the assembly at 0x7BDA-0x7FD7 (plus 0x5D37-0x5E09). This is exactly what an
 * interface board, or the Pico emulating one, has to answer. See manuals/06 for the same protocol
 * observed on the real bus. All transfers are on I2C bus A (option bus), the meter is master.
 *
 * Slave address: 0x58 | ((cfg >> 4) & 0x06)  ->  0x58, 0x5A, 0x5C, 0x5E (7-bit 0x2C..0x2F).
 * Two channel descriptors exist (XDATA 0x0053 and 0x0056); each is 3 bytes:
 *     [0] cfg   bits 0-4 GPIB address, bits 5-6 mode/slot, bit 7 "send address on init"
 *     [1] state bit 0 resend, bits 3-4/6-7 select the F4/F5/F6 init code
 *     [2] flags bit 7 board present, bit 6 talk requested, bit 5 identity requested,
 *               bit 4 reply waiting, bit 3 init pending, bits 0-2 FF countdown
 * Shared link state (XDATA 0x00EA/0x00EB, loaded into IRAM 2Eh/2Fh while a channel is serviced):
 *     2Eh = status byte to report (bit 7 = already sent), 2Fh = remote state:
 *           bit0 GET, bit1 DCL, bit2 END pending, bit4 remote (REN), bit5-6 mode, bit7 lockout.
 *
 * Meter -> board (writes):  F8 / F3 + C0|addr / F4|F5|F6 / FE / FA during init, 80|status,
 *                           FF = message received, F1 xx, and reply blocks 20|len (+40 = END) data.. ck,
 *                           identity 60|len "PM25253 S25" ck.
 * Board -> meter (reads):   0nnnnnnn = command block header (n = bits 0-4 data bytes, bit 6 END),
 *                           then data and checksum; 80 xx = idle/status (2 bytes);
 *                           single-byte events FE talk, E1 identity, FF (counted down), F5 REN,
 *                           F6 REN off, F7 GTL, F8 LLO, F9 GET, FA DCL, FB/FD resend address/status,
 *                           100aaaaa = address switches.
 * Checksum (both directions): ck = 0; for each data byte: ck = rotate_right(ck + byte).
 */
#include <stdbool.h>
#include <stdint.h>

/* I2C bus A primitives (clean/i2c.c) */
bool i2cA_start_write(uint8_t addr); bool i2cA_start_read(uint8_t addr);
bool i2cA_send_byte(uint8_t b);      void i2cA_send_stop(uint8_t b);   void i2cA_stop(void);
uint8_t i2cA_recv_byte(void);        uint8_t i2cA_recv_ack(void);      void i2cA_send_ack(void);
void i2cA_nack_stop(void);

extern uint8_t xram[0x800];
extern uint8_t rx_index, rx_count;        /* IRAM 0x0C, 0x0D: command line in iface_rx_buf */
extern uint8_t reply_len;                 /* IRAM 0x0B: bit7 reply ready, bit6 END, bits 0-5 length */
extern uint8_t iface_chan_hi, iface_chan_lo;
void reply_abort(void);

#define RX_BUF   0x0013                   /* command line buffer, 32 bytes */
#define REPLY_BUF 0x0034
#define VERSION_STRING 0x59A5             /* ROM: length byte + "PM25253 S25" */
extern const uint8_t rom[0x8000];

/* ---- channel context ------------------------------------------------------------------ */
static uint16_t ch_ptr;                   /* R0/R1 in the original */
static uint8_t cfg, state, flags;         /* R4, R3, B */
static uint8_t status, remote;            /* 2Eh, 2Fh */

static uint8_t rr(uint8_t v) { return (uint8_t)((v >> 1) | (v << 7)); }

void iface_load_channel(uint16_t desc)                                   /* 0x7FC1 */
{
    ch_ptr = desc;
    cfg = xram[desc]; state = xram[desc + 1]; flags = xram[desc + 2];
    status = xram[0x00EA]; remote = xram[0x00EB];                        /* iface_ctx_load */
}
void iface_save_channel(void)                                            /* 0x7CEC */
{
    xram[0x00EA] = status; xram[0x00EB] = remote;                        /* iface_ctx_save */
    xram[ch_ptr] = cfg; xram[ch_ptr + 1] = state; xram[ch_ptr + 2] = flags;
}

static uint8_t iface_i2c_addr(void) { return (uint8_t)(0x58 | ((cfg >> 4) & 0x06)); }  /* 0x7F3E */
static bool iface_start_write(void) { return i2cA_start_write(iface_i2c_addr()); }   /* 0x7F45 */
static bool iface_start_read(void)  { return i2cA_start_read(iface_i2c_addr()); }    /* 0x7F4B */

/* 0x7F5C: one control byte in its own transfer */
static void iface_write_ctrl(uint8_t code) { iface_start_write(); i2cA_send_stop(code); }
static void iface_write_ff(void)           { iface_write_ctrl(0xFF); }  /* 0x7F39 message received */
static void iface_send_address(void)       { iface_write_ctrl((uint8_t)(0xC0 | (cfg & 0x1F))); } /* 0x7F56 */

/* 0x7F8C iface_send_status: 80 | (status & 0x3F); bit 7 of the stored status marks "sent" */
static void iface_send_status(void)
{
    iface_start_write();
    status = (uint8_t)((status & 0x3F) | 0x80);
    i2cA_send_stop(status);
}

/* 0x7F9A iface_send_f1: F1 xx (serial-poll style status byte) */
static void iface_send_f1(uint8_t v)
{
    iface_start_write(); i2cA_send_byte(0xF1); i2cA_send_stop(v);
}

/* 0x7FAE iface_mode_match: the board's mode bits (remote bits 5-6) must equal cfg bits 5-6 */
static bool iface_mode_match(void) { return ((remote ^ cfg) & 0x60) == 0; }
/* 0x7FA7 iface_addressed: not in remote, or in remote with matching mode */
static bool iface_addressed(void)  { return !(remote & 0x10) || iface_mode_match(); }

/* 0x7F63/0x7F69 iface_read_status: read the board's status. Bytes 0x80-0xBF are two-byte status
 * (80 xx); the second byte's bits 1-5 go into state. Returns true for a two-byte status. */
static bool iface_read_status(uint8_t *first, uint8_t *second)
{
    iface_start_read();
    uint8_t a = i2cA_recv_byte();
    *first = a;
    if ((a & 0x80) && !(a & 0x40)) {                 /* 80..BF */
        i2cA_send_ack();
        *second = i2cA_recv_byte();
        i2cA_nack_stop();
        state = (uint8_t)((state & 0xC1) | (a & 0x3E));
        return true;
    }
    i2cA_nack_stop();
    return false;
}

static void iface_handle_event(uint8_t ev);

/* 0x7DBE iface_rx_complete: a command line (possibly empty) is ready for the parser */
static void iface_rx_complete(uint8_t header)
{
    rx_index = 0;
    rx_count = (uint8_t)(header | 0x80);             /* bit 7 line present, bit 6 END, count */
    iface_write_ff();                                /* tell the board: message received */
    flags &= (uint8_t)~0x40;                         /* talk request done */
    if (flags & 0x10) { flags &= (uint8_t)~0x10; reply_abort(); }   /* new command cancels a reply */
}

/* 0x7D88 iface_read_message: read one transfer from the board */
static void iface_read_message(void)
{
    uint8_t h = i2cA_recv_byte();
    if ((h & 0xC0) == 0x80) {                        /* 80..BF: two-byte status "80 xx" (idle) */
        i2cA_send_ack();
        (void)i2cA_recv_byte();
        i2cA_nack_stop();
        state = (uint8_t)((state & 0xC1) | (h & 0x3E));
        return;
    }
    if (h & 0x80) {                                  /* C0..FF: single-byte event */
        i2cA_nack_stop();
        iface_handle_event(h);
        return;
    }
    uint8_t n = h & 0x1F;
    if (n == 0) { i2cA_nack_stop(); iface_handle_event(h); return; }   /* flags only (END) */
    if (!iface_addressed() || (rx_count & 0x80)) {   /* not for us, or the last line is still queued */
        i2cA_nack_stop();
        return;
    }
    i2cA_send_ack();
    uint8_t ck = 0;
    for (uint8_t i = 0; i < n; i++) {
        uint8_t b = i2cA_recv_ack();
        xram[RX_BUF + i] = b;
        ck = rr((uint8_t)(ck + b));
    }
    uint8_t rx_ck = i2cA_recv_byte();
    i2cA_nack_stop();
    if ((rx_ck ^ ck) == 0)
        iface_rx_complete(h);
    /* bad checksum: the line is dropped; the board will resend */
}

/* 0x7E18 iface_send_reply_block: header 20|len (+bit 6 END), data, checksum, then the board's
 * status: bit 0 set = please resend */
static void iface_send_reply_block(void)
{
    iface_start_write();
    uint8_t h = (uint8_t)((reply_len & 0x5F) | 0x20);
    i2cA_send_byte(h);
    uint8_t n = h & 0x1F, ck = 0;
    if (n == 0) { i2cA_stop(); flags &= (uint8_t)~0x10; reply_len = 0; return; }
    for (uint8_t i = 0; i < n; i++) {
        uint8_t b = xram[REPLY_BUF + i];
        ck = rr((uint8_t)(ck + b));
        i2cA_send_byte(b);
    }
    i2cA_send_stop(ck);
    uint8_t s1, s2;
    if (!iface_read_status(&s1, &s2)) { iface_handle_event(s1); return; }
    if (!(s1 & 0x01)) { flags &= (uint8_t)~0x10; reply_len = 0; }   /* accepted: reply done */
}

/* 0x7E4F iface_send_identity: on E1 -> 60|len + version string + checksum */
static void iface_send_identity(void)
{
    iface_start_write();
    uint8_t n = rom[VERSION_STRING], ck = 0;
    i2cA_send_byte((uint8_t)(n | 0x60));
    for (uint8_t i = 1; i <= n; i++) {
        uint8_t b = rom[VERSION_STRING + i];
        ck = rr((uint8_t)(ck + b));
        i2cA_send_byte(b);
    }
    i2cA_send_stop(ck);
    uint8_t s1, s2;
    if (!iface_read_status(&s1, &s2)) { iface_handle_event(s1); return; }
    if (!(s1 & 0x01)) flags &= (uint8_t)~0x20;
}

/* 0x7D26 iface_i2c_write_block (init): introduce the meter to the board */
static void iface_init_board(void)
{
    if (iface_start_write()) { i2cA_stop(); return; }   /* nobody there */
    flags |= 0x80;                                        /* board present */
    i2cA_stop();
    iface_send_status();                                  /* 80 | status */
    iface_write_ctrl(0xF8);
    if (cfg & 0x80) { iface_write_ctrl(0xF3); iface_send_address(); }
    uint8_t code = 0xF4;
    if ((state & 0x18) == 0x18)
        code = (state & 0x40) ? 0xF5 : (state & 0x80) ? 0xF6 : 0xF4;
    iface_write_ctrl(code);
    if (iface_addressed() && !(rx_count & 0x80)) { iface_write_ctrl(0xFE); flags &= (uint8_t)~0x08; }
    iface_write_ctrl(0xFA);
}

/* 0x7E86 iface_handle_event: everything the board can send as a single byte */
static void iface_handle_event(uint8_t ev)
{
    if (!(ev & 0x80)) {                               /* 0x00..0x7F: header without data */
        if (ev & 0x1F) return;
        if (iface_addressed()) {
            if (!(rx_count & 0x80)) { iface_rx_complete(ev); return; }   /* empty line (END) */
            if (ev & 0x40) remote |= 0x04;            /* remember END for later */
        }
        return;
    }
    switch (ev) {
    case 0xFE:                                        /* talk: send the reply if one is waiting.
                                                         (the original has two FE paths, 0x7DFE in the read
                                                         path and 0x7EA2 here; merged in this version) */
        if (flags & 0x18) return;
        flags |= 0x40;
        if ((flags & 0x10) && (reply_len & 0x80)) iface_send_reply_block();
        return;
    case 0xE1: flags |= 0x20; if (!(flags & 0x08)) iface_send_identity(); return;
    case 0xFF:                                        /* "nothing" - do NOT use as idle */
        if (flags & 0x07) { flags--; return; }        /* counted down ... */
        flags |= 0x07; iface_init_board(); return;    /* ... at 0 the link is re-initialised */
    case 0xF9: if (iface_addressed()) remote |= 0x01; return;   /* GET: trigger */
    case 0xFA: if (iface_addressed()) remote |= 0x02; return;   /* DCL/SDC: restart the meter */
    case 0xFB: iface_send_address(); return;
    case 0xFD: iface_send_status(); return;
    case 0xF5:                                        /* REN */
        if (iface_addressed() && !(remote & 0x80))
            remote = (uint8_t)(((remote | 0x80) & 0x9F) | (cfg & 0x60));
        return;
    case 0xF6: if (iface_mode_match()) remote &= (uint8_t)~0x90; return;   /* REN false */
    case 0xF7: if (iface_mode_match()) remote &= (uint8_t)~0x10; return;   /* GTL */
    case 0xF8:                                        /* LLO: remote + keyboard lockout */
        if (iface_mode_match() || (remote & 0x80))
            remote = (uint8_t)((((remote & 0x9F) | (cfg & 0x60))) | 0x10);
        return;
    default:
        if ((ev & 0xE0) == 0x80) {                    /* 100aaaaa: address switches of the board */
            cfg = (uint8_t)((cfg & 0xE0) | (ev & 0x1F));
            return;
        }
        iface_write_ff();
        return;
    }
}

/* ---- entry points used by the rest of the firmware ------------------------------------ */

/* 0x7BDA iface_poll_channel: one service pass on a channel (called from the main loop) */
void iface_poll_channel(uint16_t desc)
{
    iface_load_channel(desc);
    if (!(rx_count & 0x80) && (remote & 0x04)) {      /* END arrived while the parser was busy */
        remote &= (uint8_t)~0x04;
        rx_count = 0xC0;                              /* deliver an empty END line */
    }
    if (!(flags & 0x80)) {                            /* no board known yet: try to initialise */
        iface_init_board();
    } else if (!iface_start_read()) {                 /* board answered: read what it has */
        iface_read_message();
    } else {
        i2cA_stop();
        if (!iface_start_write()) {                   /* reads fail but writes work: re-initialise */
            flags &= (uint8_t)~0x80;
            iface_init_board();
        } else {                                      /* board gone */
            i2cA_stop();
            if ((flags & 0x10) && (reply_len & 0x80)) { flags &= (uint8_t)~0x10; reply_len = 0; }
            state &= 0xF8;
            flags = 0;
            if (iface_mode_match()) remote &= (uint8_t)~0x90;   /* drop remote state */
        }
    }
    iface_save_channel();
}

/* 0x7BF0 iface_send_channel: (re)configure a channel with a new config byte */
void iface_send_channel(uint16_t desc, uint8_t new_cfg)
{
    iface_load_channel(desc);
    cfg = new_cfg;
    state = (new_cfg & 0x80) ? 0xB8 : (new_cfg & 0x40) ? 0x58 : 0x00;
    flags = 0;
    iface_init_board();
    iface_write_ctrl(0xFA);
    uint8_t s1, s2;
    if (!iface_read_status(&s1, &s2)) iface_handle_event(s1);
    iface_save_channel();
}

/* 0x7C8E iface_receive_channel: ask the board for its status (used at boot). Returns true and the
 * second status byte if the board sent a two-byte status. */
bool iface_receive_channel(uint16_t desc, uint8_t *v)
{
    iface_load_channel(desc);
    iface_write_ctrl(0xFA);
    uint8_t s1, s2 = 0;
    bool two = iface_read_status(&s1, &s2);
    if (!two) iface_handle_event(s1);
    *v = s2;
    iface_save_channel();
    return two;
}

/* 0x7C24 iface_send: a reply is ready in reply_buf -> wait for the board's talk request */
void iface_send(uint16_t desc)
{
    iface_load_channel(desc);
    if (reply_len & 0x80) { flags &= (uint8_t)~0x40; flags |= 0x10; }
    iface_save_channel();
}

/* 0x7C43 iface_clear_remote (rTL key): leave remote unless locked out */
void iface_clear_remote(uint16_t desc)
{
    iface_load_channel(desc);
    if (!(remote & 0x80)) remote &= (uint8_t)~0x10;
    iface_save_channel();
}

/* 0x7C12 iface_send_status_now */
void iface_send_status_now(uint16_t desc)
{
    iface_load_channel(desc);
    iface_send_status();
    iface_save_channel();
}

/* 0x5D5F iface_status_compose / 0x5D40 iface_report_status: build the status byte
 *   bit 0 = reading or reply pending, bit 1 = 24h.6, bit 4 = result_flags bit 3, bit 7 kept,
 * and send it at once if it changed (see manuals/06 for the values seen on the real meter). */
void iface_report_status(uint8_t result_flags, bool reading_pending, bool flag_24h6)
{
    if (!(iface_chan_hi | iface_chan_lo)) return;
    uint8_t old = xram[0x00EA];
    uint8_t s = (uint8_t)((old & 0x80) | (reading_pending ? 0x01 : 0) |
                          ((result_flags >> 3) & 1) << 4 | (flag_24h6 ? 0x02 : 0));
    xram[0x00EA] = s;
    if (s != old) iface_send_status_now((uint16_t)(iface_chan_hi << 8 | iface_chan_lo));
}
