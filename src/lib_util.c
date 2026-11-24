/* lib_util.c - memory, DPTR, text and number conversion helpers
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 19 functions, 507 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/lib_util.c.
 */
#include "pm2525.h"

/* ---- xdata_copy  @0x0A91  (4 bytes) */
void xdata_copy(void)

{
  xdata_block_xfer();
  return;
}

/* ---- parse_number_xdata  @0x5E0A  (16 bytes) */
void parse_number_xdata(uint8_t *param_1,uint8_t param_2)

{
  uint8_t uVar1;
  uint8_t bVar2;
  uint8_t in_PSW;
  
  bVar2 = 0x20;
  do {
    uVar1 = *param_1;
    param_1 = param_1 + 1;
    parse_number_char(param_2,uVar1);
    param_2 = in_PSW;
    in_PSW = param_2 & 0x7f | (bVar2 < 0x12) << 7;
  } while (bVar2 != 0x12);
  return;
}

/* ---- parse_number_char  @0x5E1A  (296 bytes)
 *      decimal number accumulator used by the command parser */
uint8_t parse_number_char(uint8_t param_1,uint8_t *param_2,uint8_t *param_3,uint8_t param_4,uint8_t param_5,
                      uint8_t param_6,uint8_t param_7)

{
  bool bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  char cVar5;
  
  if (param_7 == 0x20) {
    return param_1;
  }
  if (param_6 == 0x20) {
    param_1 = 0;
    *param_2 = 0;
    param_4 = 0;
    param_5 = 0;
    F0 = 0;
    if ((param_7 == 0x2b) || (param_7 == 0x2d)) {
      return param_1;
    }
    cVar5 = (param_7 < 0x2e) << 7;
    if ((param_7 != 0x2e) && (param_1 = is_digit_r7(), cVar5 < '\0')) {
      return 0xff;
    }
    param_6 = 0x21;
LAB_CODE_5e5a:
    if ((param_7 == 0x65) || (param_7 == 0x45)) {
      if (param_6 == 0x22) {
        return param_1;
      }
      return 0xff;
    }
    bVar3 = (param_7 < 0x2e) << 7;
    if (param_7 == 0x2e) {
      cVar5 = F0;
      if (cVar5 != '\x01') {
        F0 = 1;
        return param_1;
      }
    }
    else {
      bVar4 = is_digit_r7();
      if (-1 < (char)bVar3) {
        cVar5 = F0;
        if ((cVar5 != '\0') && (bVar3 = (param_5 < 0x26) << 7, param_5 == 0x26)) {
          return 0xff;
        }
        if (*param_2 != 0) {
          fp_ld_pow10_r1(1);
          fp_mul();
          if ((char)bVar3 < '\0') {
            return 0xff;
          }
        }
        bVar2 = 0;
        if (bVar4 != 0) {
          param_3[-1] = 0;
          param_3[-2] = 0;
          param_3[-3] = bVar4;
          param_3 = param_3 + -1;
          i24_to_fp(bVar4);
          bVar4 = *param_2;
          if (*param_2 == 0) {
            bVar4 = param_4;
          }
          bVar3 = bVar3 & 0xdd;
          *param_3 = bVar4 & 0x80 | *param_3;
          bVar2 = fp_add();
          if ((char)bVar3 < '\0') {
            return 0xff;
          }
        }
        return bVar2;
      }
    }
    if (param_6 != 0x22) {
      return 0xff;
    }
    *param_3 = 0;
  }
  else {
    if ((param_6 == 0x21) || (param_6 == 0x22)) goto LAB_CODE_5e5a;
    cVar5 = (param_6 < 0x23) << 7;
    if (param_6 == 0x23) {
      *param_3 = 0;
      F0 = 0;
      if (param_7 == 0x2b) {
        return param_1;
      }
      cVar5 = (param_7 < 0x2d) << 7;
      if (param_7 == 0x2d) {
        F0 = 1;
        return param_1;
      }
      is_digit_r7();
      if (cVar5 < '\0') {
        return 0xff;
      }
      param_6 = 0x25;
    }
    bVar3 = is_digit_r7();
    if (-1 < cVar5) {
      bVar4 = *param_3;
      *param_3 = bVar3;
      bVar3 = bVar4 * '\n' + *param_3;
      *param_3 = bVar3;
      if (*param_3 < 0x14) {
        return bVar3;
      }
      return 0xff;
    }
    if (param_6 != 0x25) {
      return 0xff;
    }
  }
  bVar3 = *param_3;
  cVar5 = F0;
  if (cVar5 != '\0') {
    bVar3 = ~bVar3 + 1;
  }
  bVar3 = bVar3 - param_5;
  if (bVar3 == 0) {
    OV = 0;
  }
  else if ((char)bVar3 < '\0') {
    bVar4 = ~bVar3 + 1;
    if (0x13 < bVar4) {
      bVar1 = ~bVar3 - 0x12 < 0x14;
      cVar5 = bVar1 << 7;
      if (!bVar1) {
        *param_2 = 0;
        OV = 0;
        goto LAB_CODE_5ec9;
      }
      fp_ld_pow10_r1();
      fp_div();
      if (cVar5 < '\0') goto LAB_CODE_5ec9;
      bVar4 = 0x13;
    }
    fp_ld_pow10_r1(bVar4);
    fp_div();
  }
  else {
    fp_ld_pow10_r1();
    fp_mul();
  }
LAB_CODE_5ec9:
  return *param_2;
}

/* ---- is_digit_r7  @0x5F42  (9 bytes) */
char is_digit_r7(uint8_t param_1)

{
  char cVar1;
  
  cVar1 = param_1 - 0x3a;
  if (param_1 < 0x3a) {
    cVar1 = param_1 - 0x30;
  }
  return cVar1;
}

/* ---- put_sign_char  @0x6270  (20 bytes)
 *      '-' or '+' (R5.6) */
void put_sign_char(char *param_1,uint8_t param_2)

{
  if (*param_1 < '\0') {
    put_char_dptr(0x2d);
    return;
  }
  if ((param_2 >> 6 & 1) == 0) {
    put_char_dptr(0x20);
    return;
  }
  put_char_dptr(0x2b);
  return;
}

/* ---- put_digit  @0x6284  (7 bytes) */
void put_digit(char *param_1,char param_2)

{
  char cVar1;
  
  cVar1 = i24_div10_rem(param_2 + -1);
  *param_1 = cVar1 + '0';
  return;
}

/* ---- put_char_dptr  @0x628B  (3 bytes)
 *      MOVX @DPTR,A; INC DPTR */
void put_char_dptr(uint8_t param_1,uint8_t *param_2)

{
  *param_2 = param_1;
  return;
}

/* ---- put_pad  @0x6299  (16 bytes) */
void put_pad(char param_1,char param_2)

{
  uint8_t uVar1;
  
  if (-1 < param_2) {
    put_char_repeat(0x20);
    put_sign_char();
    return;
  }
  put_sign_char();
  if (param_1 != '\0') {
    uVar1 = 0x30;
    do {
      uVar1 = put_char_dptr(uVar1);
      param_1 = param_1 + -1;
    } while (param_1 != '\0');
  }
  return;
}

/* ---- put_char_repeat  @0x62A9  (10 bytes) */
void put_char_repeat(uint8_t param_1,char param_2)

{
  if (param_2 != '\0') {
    do {
      param_1 = put_char_dptr(param_1);
      param_2 = param_2 + -1;
    } while (param_2 != '\0');
  }
  return;
}

/* ---- dptr_add_a_b  @0x68C0  (11 bytes)
 *      DPTR += A */
uint8_t dptr_add_a_b(uint8_t param_1)

{
  return param_1;
}

/* ---- xdata_clear3  @0x6D1E  (7 bytes) */
void xdata_clear3(uint8_t *param_1)

{
  *param_1 = 0;
  param_1[1] = 0;
  param_1[2] = 0;
  return;
}

/* ---- xdata_is_zero3  @0x6D25  (15 bytes)
 *      C=1 if 3 bytes at DPTR are zero */
void xdata_is_zero3(char *param_1)

{
  if (((*param_1 == '\0') && (param_1[1] == '\0')) && (param_1[2] == '\0')) {
    return;
  }
  return;
}

/* ---- xdata_to_iram  @0x6D34  (7 bytes)
 *      copy R2 bytes XDATA@DPTR -> IRAM@R0 */
void xdata_to_iram(uint8_t *param_1,uint8_t *param_2,char param_3)

{
  do {
    *param_2 = *param_1;
    param_2 = param_2 + '\x01';
    param_1 = param_1 + 1;
    param_3 = param_3 + -1;
  } while (param_3 != '\0');
  return;
}

/* ---- iram_to_xdata  @0x6D3B  (7 bytes)
 *      copy R2 bytes IRAM@R0 -> XDATA@DPTR */
void iram_to_xdata(uint8_t *param_1,uint8_t *param_2,char param_3)

{
  do {
    *param_1 = *param_2;
    param_2 = param_2 + '\x01';
    param_1 = param_1 + 1;
    param_3 = param_3 + -1;
  } while (param_3 != '\0');
  return;
}

/* ---- xdata_swap_iram  @0x6D42  (8 bytes)
 *      exchange R2 bytes */
void xdata_swap_iram(uint8_t *param_1,uint8_t *param_2,char param_3)

{
  uint8_t uVar1;
  
  do {
    uVar1 = *param_2;
    *param_2 = *param_1;
    *param_1 = uVar1;
    param_2 = param_2 + '\x01';
    param_1 = param_1 + 1;
    param_3 = param_3 + -1;
  } while (param_3 != '\0');
  return;
}

/* ---- xdata_block_xfer  @0x6D4A  (39 bytes) */
void xdata_block_xfer(uint8_t *param_1,char param_2,char param_3,uint8_t param_4,
                     uint8_t param_5,uint8_t param_6)

{
  uint8_t uVar1;
  char in_PSW;
  uint8_t *puVar2;
  
  puVar2 = (uint8_t *)CONCAT11(param_5,param_4);
  param_3 = param_3 + '\x01';
  do {
    uVar1 = *param_1;
    if (in_PSW < '\0') {
      param_6 = *puVar2;
    }
    *puVar2 = uVar1;
    puVar2 = puVar2 + 1;
    if (in_PSW < '\0') {
      *param_1 = param_6;
      param_6 = uVar1;
    }
    param_1 = param_1 + 1;
    param_2 = param_2 + -1;
  } while ((param_2 != '\0') || (param_3 = param_3 + -1, param_3 != '\0'));
  return;
}

/* ---- dptr_add_a  @0x6D78  (9 bytes)
 *      DPTR += A */
void dptr_add_a(void)

{
  return;
}

/* ---- dptr_add_r6r7  @0x6D81  (11 bytes)
 *      DPTR += R6:R7 */
char dptr_add_r6r7(uint16_t param_1,char param_2,uint8_t param_3)

{
  return param_2 + ((char)((uint16_t)param_1 >> 8) - ((CARRY1(param_3,(uint8_t)param_1) << 7) >> 7));
}

/* ---- dptr_add_a_mul_b  @0x6D8C  (12 bytes)
 *      DPTR += A*B (table index) */
char dptr_add_a_mul_b(uint8_t param_1,uint16_t param_2,uint8_t param_3)

{
  return (char)((uint16_t)param_2 >> 8) +
         ((char)((uint16_t)param_1 * (uint16_t)param_3 >> 8) -
         ((CARRY1((uint8_t)((uint16_t)param_1 * (uint16_t)param_3),(uint8_t)param_2) << 7) >> 7));
}

