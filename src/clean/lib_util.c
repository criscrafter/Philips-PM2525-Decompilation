/* lib_util.c (hand-cleaned) - memory, pointer and text helpers (firmware S25)
 *
 * Rewritten from the assembly at 0x6284-0x62B2 and 0x6D1E-0x6DAA, plus the entry points of the
 * text formatter and number parser. All of these are tiny register-level helpers in the original;
 * in C most of them collapse to one line.
 */
#include <stdbool.h>
#include <stdint.h>

extern uint8_t xram[0x800];
extern uint8_t iram[0x80];

/* ---- DPTR arithmetic (table indexing) --------------------------------------------------- */
uint16_t dptr_add_a(uint16_t dptr, uint8_t a)              { return (uint16_t)(dptr + a); }          /* 0x6D78 */
uint16_t dptr_add_r6r7(uint16_t dptr, uint16_t r6r7)       { return (uint16_t)(dptr + r6r7); }       /* 0x6D81 */
uint16_t dptr_add_a_mul_b(uint16_t dptr, uint8_t a, uint8_t b) { return (uint16_t)(dptr + a * b); }  /* 0x6D8C */
uint16_t add16_r6r7_r4r5(uint16_t a, uint16_t b)           { return (uint16_t)(a + b); }             /* 0x6D71 */
uint16_t shl16_r6r7(uint16_t v, uint8_t n)                 { return (uint16_t)(v << n); }            /* 0x6D98 */

/* ---- block moves between IRAM and XDATA (R0 = IRAM, DPTR = XDATA, R2 = count) ------------ */
void xdata_to_iram(uint16_t x, uint8_t r, uint8_t n) { while (n--) iram[r++] = xram[x++]; }                    /* 0x6D34 */
void iram_to_xdata(uint16_t x, uint8_t r, uint8_t n) { while (n--) xram[x++] = iram[r++]; }                    /* 0x6D3B */
void xdata_swap_iram(uint16_t x, uint8_t r, uint8_t n)                                                         /* 0x6D42 */
{
    while (n--) { uint8_t t = xram[x]; xram[x++] = iram[r]; iram[r++] = t; }
}
void xdata_clear3(uint16_t x)   { xram[x] = xram[x + 1] = xram[x + 2] = 0; }                                   /* 0x6D1E */
bool xdata_is_zero3(uint16_t x) { return (xram[x] | xram[x + 1] | xram[x + 2]) == 0; }                         /* 0x6D25 */

/* 0x6D4A xdata_block_xfer: copy (C = 0) or exchange (C = 1) n bytes between two XDATA areas */
void xdata_block_xfer(uint16_t dst, uint16_t src, uint16_t n, bool exchange)
{
    while (n--) {
        uint8_t t = xram[dst];
        xram[dst] = xram[src];
        if (exchange) xram[src] = t;
        dst++; src++;
    }
}

/* ---- text output into XDATA (DPTR = write position) ------------------------------------ */
static uint16_t out_pos;
void put_char_dptr(uint8_t c)              { xram[out_pos++] = c; }                     /* 0x628B */
void put_char_repeat(uint8_t c, uint8_t n) { while (n--) put_char_dptr(c); }            /* 0x62A9 */
void put_sign_char(bool negative, bool plus_wanted)                                    /* 0x6270 */
{
    if (negative) put_char_dptr('-');
    else if (plus_wanted) put_char_dptr('+');
}
void put_digit(uint8_t d)                  { put_char_dptr((uint8_t)('0' + d)); }       /* 0x6284 */
bool is_digit(uint8_t c)                   { return c >= '0' && c <= '9'; }             /* 0x5F42 / parser_is_digit */

/* 0x5F4B fp_format: float -> text, the 805-byte formatter behind every reading and reply.
 * Output examples: "+1.200000E-02" (CDP), "-000.019E-03" (readings), "200.E-03" (RNG ?).
 * Parameters (IRAM): 2Fh = field width / flags (0x60 | digits, 0x67 = 7 digits), 31h = format bits
 * (0x40 = E notation with sign, 0x48 = fixed digits, 0xF0 | n = n digits before the point), 35h =
 * exponent alignment. A C equivalent for the common E format: */
#include <math.h>
#include <stdio.h>
void fp_format_e(char *out, double v, int digits)
{
    /* "%+.*E" gives the same layout as the meter's E format (sign, d.ddddddE+xx) */
    sprintf(out, "%+.*E", digits - 1, v);
}

/* 0x5E1A parse_number_char: the decimal accumulator of the command parser. Accepts an optional
 * sign, digits, a decimal point and an exponent (E or e, optional sign), e.g. "2.5E3", "-3",
 * "200E-3"; the value ends up as a pm_float in IRAM 30h-33h. Verified with tools/parse_cmd.py. */
