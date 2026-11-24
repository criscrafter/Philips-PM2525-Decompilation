/* lib_math.c (hand-cleaned) - the number library of the PM2525 (firmware S25)
 *
 * Original: hand-written 8051 assembly at 0x6417-0x6D97, operating on IRAM through R0/R1.
 * This version is written at the semantic level: each function computes what the original
 * computes (verified by running the original in the emulator, tools/probe_lib.py), using the
 * firmware's number formats below. Where the original's exact rounding matters, the routine that
 * implements it is named.
 *
 * pm_float - 4 bytes, value = mantissa / 2^24 * 2^(exponent - 62)
 *     byte 0: bit 7 sign, bits 0-6 exponent (bias 62); 0 = zero
 *     bytes 1-3: 24-bit mantissa with explicit leading 1 (normalised: bit 23 set)
 *     largest: 7F FFFFFF (about 3.7e19). In IRAM the exponent byte sits at the highest address and
 *     routines receive a pointer to it (R0 = first operand / result, R1 = second operand).
 * pm_i24 - 24-bit two's complement, MSB at the highest IRAM address.
 *
 * Examples from the ROM: 4C9C3C00 = 9999, 31D1B717 = 1e-4, 66E8D4A4 = 1e12, 3ED4... etc.
 */
#include <math.h>
#include <stdbool.h>
#include <stdint.h>

typedef struct { uint8_t b[4]; } pm_float;   /* b[0] = sign|exponent, b[1..3] mantissa (MSB first) */
typedef int32_t pm_i24;                       /* kept sign-extended in 32 bits here */

#define PM_FLOAT_MAX 3.6893485e19

double pm_to_double(pm_float f)
{
    if ((f.b[0] & 0x7F) == 0) return 0.0;
    uint32_t m = (uint32_t)f.b[1] << 16 | (uint32_t)f.b[2] << 8 | f.b[3];
    double v = ldexp((double)m / 16777216.0, (f.b[0] & 0x7F) - 62);
    return (f.b[0] & 0x80) ? -v : v;
}

/* nearest representable value; saturates at +-max like the original (fp_ld_max_r0) */
pm_float pm_from_double(double x)
{
    pm_float f = { { 0, 0, 0, 0 } };
    if (x == 0.0 || isnan(x)) return f;
    int e;
    double m = frexp(fabs(x), &e);                /* m in [0.5, 1) */
    uint32_t mi = (uint32_t)llround(m * 16777216.0);
    if (mi >= (1u << 24)) { mi >>= 1; e++; }
    if (e + 62 > 0x7F) { f.b[0] = 0x7F; f.b[1] = f.b[2] = f.b[3] = 0xFF; }   /* overflow -> max */
    else if (e + 62 <= 0) return f;                                            /* underflow -> 0 */
    else { f.b[0] = (uint8_t)(e + 62); f.b[1] = (uint8_t)(mi >> 16); f.b[2] = (uint8_t)(mi >> 8); f.b[3] = (uint8_t)mi; }
    if (x < 0) f.b[0] |= 0x80;
    return f;
}

/* ---- float arithmetic (rounding: fp_round_normalize 0x6748, exponents: fp_exp_add 0x671C) ---- */
pm_float fp_add(pm_float a, pm_float b)  { return pm_from_double(pm_to_double(a) + pm_to_double(b)); }  /* 0x657D */
pm_float fp_sub(pm_float a, pm_float b)  { return pm_from_double(pm_to_double(a) - pm_to_double(b)); }  /* 0x656F */
pm_float fp_rsub(pm_float a, pm_float b) { return pm_from_double(pm_to_double(b) - pm_to_double(a)); }  /* 0x6577 */
pm_float fp_mul(pm_float a, pm_float b)  { return pm_from_double(pm_to_double(a) * pm_to_double(b)); }  /* 0x66EA */

/* 0x664C fp_div: a / b. Division by zero sets C and OV and leaves a unchanged. */
pm_float fp_div(pm_float a, pm_float b, bool *div0)
{
    *div0 = (b.b[0] & 0x7F) == 0;
    if (*div0) return a;
    return pm_from_double(pm_to_double(a) / pm_to_double(b));
}

/* 0x6767 fp_cmp: true when a < b. The original returns this in C and A = 0 when a == b
 * (verified in the emulator: (2,5) C=1, (5,2) C=0, (3,3) C=0 A=0, (-5,-2) C=1). */
bool fp_cmp(pm_float a, pm_float b) { return pm_to_double(a) < pm_to_double(b); }

pm_float fp_sqrt(pm_float a)  { return pm_from_double(sqrt(pm_to_double(a))); }              /* 0x6417 */
pm_float fp_ln(pm_float a)    { return pm_from_double(log(pm_to_double(a))); }               /* 0x646A */
pm_float fp_log10(pm_float a) { return pm_from_double(log(pm_to_double(a)) * 0.4342945); }   /* 0x645D */

/* 0x68CB fp_ld_pow10_r1: 10^n for n = -18..19, from the ROM table pow10_table at 0x68DF */
pm_float fp_ld_pow10(int8_t n) { return pm_from_double(pow(10.0, n)); }

pm_float fp_ld_max(void) { pm_float f = { { 0x7F, 0xFF, 0xFF, 0xFF } }; return f; }          /* 0x67E0 */
pm_float fp_clr(void)    { pm_float f = { { 0, 0, 0, 0 } }; return f; }                       /* 0x67EF */

/* ---- conversions ---------------------------------------------------------------------- */
pm_float i24_to_fp(pm_i24 v) { return pm_from_double((double)v); }                           /* 0x631D */

/* 0x62B3 fp_to_i24_round: round half away from zero (5.5 -> 6, -5.5 -> -6); *zero = result is 0 */
pm_i24 fp_to_i24_round(pm_float a, bool *zero)
{
    double v = pm_to_double(a);
    double r = (v >= 0) ? floor(v + 0.5) : -floor(-v + 0.5);
    /* out-of-range behaviour of the original not tested; clamped here */
    if (r > 8388607.0) r = 8388607.0;
    if (r < -8388608.0) r = -8388608.0;
    *zero = (r == 0.0);
    return (pm_i24)r;
}

/* ---- 24-bit integers -------------------------------------------------------------------- */
static pm_i24 wrap24(int32_t v) { v &= 0xFFFFFF; return (v & 0x800000) ? v - 0x1000000 : v; }

pm_i24 i24_add(pm_i24 a, pm_i24 b) { return wrap24(a + b); }          /* 0x6A34 */
pm_i24 i24_sub(pm_i24 a, pm_i24 b) { return wrap24(a - b); }          /* 0x6CA9 */
pm_i24 i24_neg(pm_i24 a)           { return wrap24(-a); }             /* 0x6AA0 */
pm_i24 i24_abs(pm_i24 a)           { return a < 0 ? wrap24(-a) : a; } /* 0x6A9B */
pm_i24 i24_shl1(pm_i24 a)          { return wrap24(a * 2); }          /* 0x6C73 */
pm_i24 i24_sar1(pm_i24 a)          { return a >> 1; }                 /* 0x6C81 */
pm_i24 i24_inc(pm_i24 a)           { return wrap24(a + 1); }          /* 0x6CFA / 0x6D0C */
pm_i24 i24_dec(pm_i24 a)           { return wrap24(a - 1); }          /* 0x6CCE / 0x6CE4 */
bool   i24_is_zero(pm_i24 a)       { return a == 0; }                 /* 0x6CBE / 0x6CC6 */
pm_i24 i24_ld_max(void)            { return 0x7FFFFF; }               /* 0x6BC3 */

/* 0x6AF1 i24_cmp / 0x6AE7 i24_cmp_signed: true when a < b (C), A = 0 when equal (emulator-verified) */
bool i24_cmp(uint32_t a, uint32_t b)       { return (a & 0xFFFFFF) < (b & 0xFFFFFF); }
bool i24_cmp_signed(pm_i24 a, pm_i24 b)    { return a < b; }

/* 0x6A59 i24_mul_signed (via mant_mul24 0x6C02, a 24 x 24 -> 48-bit product) */
pm_i24 i24_mul_signed(pm_i24 a, pm_i24 b)  { return wrap24((int32_t)((int64_t)a * b)); }

/* 0x69BE i24_div (unsigned restoring division) and 0x698A i24_div_signed */
uint32_t i24_div(uint32_t a, uint32_t b, bool *div0)
{
    *div0 = (b & 0xFFFFFF) == 0;
    return *div0 ? a : (a & 0xFFFFFF) / (b & 0xFFFFFF);
}
pm_i24 i24_div_signed(pm_i24 a, pm_i24 b, bool *div0)
{
    *div0 = b == 0;
    if (*div0) return a;
    return a / b;                                  /* truncates toward zero, like the original */
}

/* 0x6C54 i24_div10_rem: a /= 10, returns the remainder (used to print digits) */
uint8_t i24_div10_rem(uint32_t *a) { uint8_t r = (uint8_t)(*a % 10); *a /= 10; return r; }
