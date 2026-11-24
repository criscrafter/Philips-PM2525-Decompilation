/* i2c.c (hand-cleaned) - the two bit-banged I2C buses of the PM2525 (firmware S25)
 *
 * Rewritten from the assembly at 0x6354-0x6417 (bus A) and 0x6B35-0x6BC2 (bus B); every function
 * keeps its original name and address. Both buses are open-drain, MSB first, and wait for SCL to
 * actually go high (clock stretching). The bus-A routines add NOPs in every phase: that bus runs
 * through the optocouplers of the galvanic separation board, about 67 kHz.
 *
 *   bus A = option bus   SDA = P1.1, SCL = P3.2 (INT0)
 *           0x4E/0x4F  PCF8574 of the data-hold probe (PM9267), 0x58-0x5E interface board (your Pico)
 *   bus B = internal bus SDA = P1.7, SCL = P3.5 (T1)
 *           0x70 PCF8576 LCD driver, 0x48 PCF8574 keyboard, 0x80-0x8D OQ0071 ADC interface,
 *           and the analog shift registers (latched with P1.3, see measure.c)
 *
 * Calling convention (as in the original): the byte goes in/out in A, ACK/NACK comes back in the
 * carry flag (C = 1 means the slave did NOT acknowledge). Here: functions return bool nack.
 * Several original routines fall through into the next one; that is written as an explicit call.
 */
#include <stdbool.h>
#include <stdint.h>

/* port pins (8051 SFR bits) */
extern volatile bool P1_1, P3_2, P1_7, P3_5;
#define SDA_A P1_1
#define SCL_A P3_2
#define SDA_B P1_7
#define SCL_B P3_5
static inline void nop(void) { }                 /* one machine cycle, 1 us at 12 MHz */
static inline void wait_high(volatile bool *scl) { while (!*scl) { } }   /* clock stretching */

/* ======================================================================= bus A (option bus) */

/* 0x63C8 i2cA_stop: SDA low, SCL released (wait high), SDA released */
void i2cA_stop(void)
{
    SDA_A = 0; nop();
    SCL_A = 1; nop(); nop(); wait_high(&SCL_A); nop(); nop();
    SDA_A = 1; nop();
}

/* 0x63AD i2cA_read_ack_bit: release SDA, one clock, sample SDA (= ACK bit, 1 = NACK) */
bool i2cA_read_ack_bit(void)
{
    SDA_A = 1; nop(); nop(); nop();
    SCL_A = 1; nop(); nop(); wait_high(&SCL_A); nop(); nop();
    bool nack = SDA_A;
    SCL_A = 0; nop();
    return nack;
}

/* 0x6397 i2cA_send_byte: 8 bits MSB first, then read the ACK */
bool i2cA_send_byte(uint8_t a)
{
    for (int i = 0; i < 8; i++) {
        SDA_A = (a & 0x80) != 0; a <<= 1; nop();
        SCL_A = 1; nop(); nop(); wait_high(&SCL_A); nop(); nop();
        SCL_A = 0; nop();
    }
    return i2cA_read_ack_bit();
}

/* 0x6377 / 0x6388: START condition (SDA falls while SCL is high) + address byte.
 * write: R/W bit (ACC.0) = 0, read: R/W bit = 1 */
static bool i2cA_start(uint8_t addr)
{
    SDA_A = 0; nop(); nop(); nop(); nop();
    SCL_A = 0; nop();
    return i2cA_send_byte(addr);
}
bool i2cA_start_write(uint8_t addr) { return i2cA_start(addr & 0xFE); }  /* 0x6377 */
bool i2cA_start_read(uint8_t addr)  { return i2cA_start(addr | 0x01); }  /* 0x6388 */

/* 0x63FA i2cA_recv_byte: release SDA, clock in 8 bits MSB first */
uint8_t i2cA_recv_byte(void)
{
    uint8_t a = 0;
    SDA_A = 1;
    for (int i = 0; i < 8; i++) {
        nop(); nop();
        SCL_A = 1; nop(); nop(); wait_high(&SCL_A); nop();
        a = (uint8_t)((a << 1) | SDA_A);
        SCL_A = 0; nop();
    }
    return a;
}

/* 0x63E1 i2cA_send_ack: SDA low for one clock */
void i2cA_send_ack(void)
{
    SDA_A = 0; nop();
    SCL_A = 1; nop(); nop(); wait_high(&SCL_A); nop(); nop();
    SCL_A = 0; nop();
}

/* 0x63DD i2cA_recv_ack: receive a byte and acknowledge it (more bytes follow) */
uint8_t i2cA_recv_ack(void) { uint8_t a = i2cA_recv_byte(); i2cA_send_ack(); return a; }

/* 0x635C i2cA_nack_stop: one clock with SDA released (NACK), then STOP */
void i2cA_nack_stop(void) { (void)i2cA_read_ack_bit(); i2cA_stop(); }

/* 0x6359 i2cA_recv_nack_stop: last byte of a read */
uint8_t i2cA_recv_nack_stop(void) { uint8_t a = i2cA_recv_byte(); i2cA_nack_stop(); return a; }

/* 0x6369 i2cA_send_stop: send a byte, then STOP regardless of the ACK */
void i2cA_send_stop(uint8_t a) { (void)i2cA_send_byte(a); i2cA_stop(); }

/* 0x6354 i2cA_read1: read one byte from a device. Returns false (C = 1) if nobody answered. */
bool i2cA_read1(uint8_t addr, uint8_t *data)
{
    if (i2cA_start_read(addr)) { i2cA_stop(); return false; }
    *data = i2cA_recv_nack_stop();
    return true;
}

/* 0x6363 i2cA_write1: write one byte (R3 in the original) to a device */
bool i2cA_write1(uint8_t addr, uint8_t data)
{
    if (i2cA_start_write(addr)) { i2cA_stop(); return false; }
    i2cA_send_stop(data);
    return true;
}

/* ======================================================================= bus B (internal bus)
 * Same protocol, fewer NOPs (fast, on-board). */

void i2cB_stop(void)                           /* 0x6B8F */
{
    SDA_B = 0;
    SCL_B = 1; wait_high(&SCL_B); nop(); nop();
    SDA_B = 1;
}

bool i2cB_read_ack_bit(void)                   /* 0x6B81 */
{
    SDA_B = 1;
    SCL_B = 1; wait_high(&SCL_B); nop(); nop();
    bool nack = SDA_B;
    SCL_B = 0;
    return nack;
}

bool i2cB_send_byte(uint8_t a)                 /* 0x6B6F */
{
    for (int i = 0; i < 8; i++) {
        SDA_B = (a & 0x80) != 0; a <<= 1;
        SCL_B = 1; wait_high(&SCL_B); nop(); nop();
        SCL_B = 0;
    }
    return i2cB_read_ack_bit();
}

/* 0x6B64 i2cB_start: START + address byte as given (ACC.0 = R/W already set by the caller).
 * Also used directly for the OQ0071 ADC interface, whose "address" byte is group 8 + a command
 * nibble (0x80 latches, 0x82/0x84 times, 0x89/0x8B start, 0x8D read counter). */
bool i2cB_start(uint8_t addr)
{
    SDA_B = 0; nop(); nop(); nop();
    SCL_B = 0;
    return i2cB_send_byte(addr);
}
bool i2cB_start_write(uint8_t addr) { return i2cB_start(addr & 0xFE); }  /* 0x6B55 */
bool i2cB_start_read(uint8_t addr)  { return i2cB_start(addr | 0x01); }  /* 0x6B62 */

uint8_t i2cB_recv_byte(void)                   /* 0x6BB0 */
{
    uint8_t a = 0;
    SDA_B = 1;
    for (int i = 0; i < 8; i++) {
        nop();
        SCL_B = 1; wait_high(&SCL_B); nop();
        a = (uint8_t)((a << 1) | SDA_B);
        SCL_B = 0;
    }
    return a;
}

/* 0x6B3A: last byte of a read (NACK + STOP) */
uint8_t i2cB_recv_nack_stop(void)
{
    uint8_t a = i2cB_recv_byte();
    (void)i2cB_read_ack_bit();
    i2cB_stop();
    return a;
}

/* 0x6B35 i2cB_read1_stop: complete one-byte read (start, receive, NACK clock, stop).
 * Used for the keyboard PCF8574 (key_read_matrix). */
bool i2cB_read1_stop(uint8_t addr, uint8_t *data)
{
    if (i2cB_start_read(addr)) { i2cB_stop(); return false; }
    *data = i2cB_recv_nack_stop();
    return true;
}

void i2cB_send_stop(uint8_t a) { (void)i2cB_send_byte(a); i2cB_stop(); }   /* 0x6B4A */

bool i2cB_write1(uint8_t addr, uint8_t data)   /* 0x6B44 */
{
    if (i2cB_start_write(addr)) { i2cB_stop(); return false; }
    i2cB_send_stop(data);
    return true;
}

/* 0x6B9B i2cB_read1: used only for the OQ0071 counter read (0x8D): first byte here, the second
 * one via i2cB_recv_nack_stop by the caller (adc_wait_ready_read) */
bool i2cB_read1(uint8_t addr, uint8_t *first)
{
    if (i2cB_start_read(addr)) return false;
    *first = i2cB_recv_byte();
    SDA_B = 0;                                  /* ACK: more bytes follow */
    SCL_B = 1; wait_high(&SCL_B); nop(); nop();
    SCL_B = 0;
    return true;
}

/* ======================================================================= both buses */

/* 0x5344 i2c_both_buses_stop: pull both SCL lines low (P3 &= 0xDB), then STOP on both buses.
 * Called at power-up and from the main loop: a periodic bus reset, which is why the interface
 * sees lone STOP conditions about every millisecond. */
extern volatile uint8_t P3;
void i2c_both_buses_stop(void)
{
    P3 &= 0xDB;
    i2cB_stop();
    i2cA_stop();
}
