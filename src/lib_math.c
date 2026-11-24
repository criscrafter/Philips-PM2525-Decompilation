/* lib_math.c - float (sign+exp bias 62, 24-bit mantissa) and 24-bit integer library
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 79 functions, 2988 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/lib_math.c.
 */
#include "pm2525.h"

/* ---- fp_ld_code_r0  @0x07A1  (3 bytes)
 *      @R0 = float from code @DPTR */
void fp_ld_code_r0(char *param_1,char *param_2)

{
  char cVar1;
  
  cVar1 = '\x04';
  do {
    *param_2 = cVar1;
    cVar1 = *param_2;
    *param_2 = *param_1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- ret_peek_dptr  @0x081C  (17 bytes)
 *      fetch the caller's saved DPTR from the stack */
void ret_peek_dptr(void)

{
  uint8_t uStackX_0;
  uint8_t in_stack_000000ff;
  
  R2 = uStackX_0;
  R3 = in_stack_000000ff;
  return;
}

/* ---- fp_cmp_ten  @0x388E  (20 bytes) */
void fp_cmp_ten(void)

{
  uint8_t bVar1;
  
  bVar1 = ram_57;
  ram_57 = ram_57 & 0x7f;
  fp_ld_pow10_r1(1,0x57,0x5f);
  fp_cmp();
  ram_57 = bVar1;
  return;
}

/* ---- i24_abs_sign_f0  @0x5CF6  (12 bytes)
 *      F0 = sign, x = |x| */
void i24_abs_sign_f0(uint8_t *param_1)

{
  char cVar1;
  
  F0 = *param_1 >> 7;
  cVar1 = F0;
  if (cVar1 != '\0') {
    i24_neg(*param_1);
  }
  return;
}

/* ---- ret_clc  @0x5DF2  (1 bytes) */
void ret_clc(void)

{
  return;
}

/* ---- ret_nop  @0x5DF3  (1 bytes) */
void ret_nop(void)

{
  return;
}

/* ---- fp_format  @0x5F4B  (805 bytes)
 *      float -> text (E-notation, digits/format in 2Fh/31h/35h) */
void fp_format(uint8_t param_1,uint8_t *param_2,uint8_t *param_3,uint8_t param_4,uint8_t param_5)

{
  bool bVar1;
  short sVar2;
  short sVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  uint8_t bVar6;
  uint8_t bVar7;
  uint8_t bVar8;
  uint8_t bVar9;
  char cVar10;
  char cVar11;
  uint8_t bStack_4;
  
  bVar4 = param_4 & 0xf;
  if ((bVar4 < 9) << 7 < '\0') {
    if (bVar4 < 3) {
      if ((((param_1 >> 4 & 1) == 1) || ((param_1 >> 5 & 1) == 1)) || ((param_1 >> 3 & 1) == 0)) {
        bVar4 = param_4 & 0xf;
        if (bVar4 != 0) goto LAB_CODE_5f77;
        bVar4 = 1;
      }
      else {
        bVar4 = 3;
      }
      goto LAB_CODE_5f72;
    }
  }
  else {
    bVar4 = 8;
LAB_CODE_5f72:
    param_4 = param_4 & 0xf0 | bVar4;
  }
LAB_CODE_5f77:
  bVar5 = param_4 & 0xf;
  bVar6 = (param_4 >> 4) + 7;
  if (bVar4 + 6 <= bVar6) {
    put_char_repeat(0x20,bVar6 - (bVar4 + 6));
  }
  if (*param_2 != 0) {
    bVar6 = *param_2 & 0x7f;
    sVar2 = (uint16_t)bVar6 * 0x10;
    bVar4 = (uint8_t)((uint16_t)sVar2 >> 8);
    sVar3 = (uint16_t)bVar6 * 0x4d;
    bVar6 = (uint8_t)sVar3;
    bStack_4 = (char)((uint16_t)sVar3 >> 8) - ((CARRY1(bVar6,bVar4) << 7) >> 7);
    bVar4 = 0x12 - (((bVar6 + bVar4 < 0xf6U - ((((uint8_t)sVar2 < 0xf0) << 7) >> 7)) << 7) >> 7);
    cVar11 = (bStack_4 < bVar4) << 7;
    bStack_4 = bStack_4 - bVar4;
    bVar4 = bStack_4;
    if ((char)bStack_4 < '\0') {
      bVar4 = ~bStack_4 + 1;
    }
    fp_ld_pow10_r1(bVar4);
    bVar4 = bStack_4;
    bVar6 = param_1;
    fp_push_r0();
    if ((char)bVar4 < '\0') {
      fp_mul();
    }
    else {
      fp_div();
    }
    bVar4 = *param_2;
    *param_2 = bVar4 & 0x7f;
    fp_ld_pow10_r1(1);
    fp_cmp();
    *param_2 = bVar4;
    if (cVar11 < '\0') {
      fp_clr_r1();
    }
    else {
      fp_clr_r0();
      bStack_4 = bStack_4 + 1;
      bVar4 = bStack_4;
      if ((char)bStack_4 < '\0') {
        bVar4 = ~bStack_4 + 1;
      }
      bVar7 = bStack_4;
      fp_ld_pow10_r1(bVar4);
      if ((char)bVar7 < '\0') {
        fp_mul();
      }
      else {
        fp_div();
      }
    }
    bVar4 = bVar6;
    if ((param_1 >> 4 & 1) != 0) {
      bVar7 = param_1 & 0xf;
      cVar11 = (bVar5 < bVar7) << 7;
      bVar4 = bVar5 - bVar7;
      if (bVar5 < bVar7) {
        param_1 = param_1 & 0xf0 | bVar5;
        bVar4 = 0;
        cVar11 = '\0';
      }
      bStack_4 = (bStack_4 - (bVar4 - (cVar11 >> 7))) + 1;
    }
    if ((param_1 >> 5 & 1) == 1) {
      bVar7 = bStack_4 - param_5;
      if ((param_1 >> 4 & 1) == 1) {
        if ((char)bVar7 < '\0') goto LAB_CODE_606f;
        goto LAB_CODE_6096;
      }
      if (-1 < (char)bVar7) {
        bVar4 = bVar5 - (((bStack_4 < param_5) << 7) >> 7);
        if ((char)(bVar7 - bVar4) < '\0') {
          bVar4 = bVar7 + 1;
          bStack_4 = param_5;
        }
        else {
          bStack_4 = (bStack_4 - (bVar5 - (((bVar7 < bVar4) << 7) >> 7))) + 1;
          bVar4 = bVar5;
        }
        goto LAB_CODE_6096;
      }
      bVar4 = 0;
      bVar7 = bVar7 + 1;
LAB_CODE_606f:
      bVar7 = bVar7 + bVar5;
      if ((char)bVar7 < '\0') goto LAB_CODE_621c;
      bVar7 = bVar7 >> 4 | bVar7 * '\x10';
      bStack_4 = param_5;
    }
    else {
      if ((param_1 >> 4 & 1) != 1) {
        if ((param_1 >> 3 & 1) == 0) {
          bVar4 = 1;
        }
        else {
          bVar7 = bStack_4;
          if ((char)bStack_4 < '\0') {
            bVar7 = ~bStack_4 + 1;
          }
          cVar11 = '\0';
          bVar7 = bVar7 % 3;
          if ((bVar7 != 0) && ((char)bStack_4 < '\0')) {
            cVar11 = (3 < bVar7) << 7;
            bVar7 = 3 - bVar7;
          }
          bVar4 = bVar7 + 1;
          bStack_4 = bStack_4 - (bVar7 - (cVar11 >> 7));
        }
      }
LAB_CODE_6096:
      bVar7 = bVar5 >> 4 | bVar5 << 4;
    }
    bVar7 = bVar7 | bVar5;
    fp_ld_pow10_r1();
    *param_3 = *param_3 - 1;
    if (*param_2 - *param_3 == '\x18') {
      fp_push_r0();
      bVar1 = 0x7f < bVar6;
      if (bVar6 == 0x80) {
        bVar6 = 0;
      }
      bVar5 = bVar6;
      if (bVar1) {
        bVar5 = ~bVar6 + 1;
      }
      fp_ld_pow10_r1(6);
      param_3 = param_3 + -1;
      *param_2 = bVar5;
      i24_div10_rem(bVar5);
      i24_shr8_ins_a();
      i24_shr1();
      i24_shr1();
      i24_shr1();
      bVar5 = *param_3;
      param_3 = param_3 + '\x01';
      fp_clr_r0(bVar5);
      fp_push_r0();
      bVar8 = bVar5;
      fp_ld_pow10_r1(6);
      param_2 = param_2 + -1;
      param_3 = param_3 + -1;
      mant_mul24();
      param_2 = param_2 + '\x01';
      param_3 = param_3 + '\x01';
      fp_clr_r0();
      cVar11 = (bVar6 < 0x80) << 7;
      if (cVar11 < '\0') {
        cVar11 = (CARRY1(bVar8,bVar5) | bVar8 + bVar5 >> 7) << 7;
joined_c0x6122:
        if (cVar11 < '\0') {
          param_2 = param_2 + -1;
          i24_inc_r0();
          param_2 = param_2 + '\x01';
        }
      }
      else {
        bVar5 = bVar5 - (cVar11 >> 7);
        cVar11 = bVar8 - bVar5;
        if (bVar5 <= bVar8) goto joined_c0x6122;
      }
      bVar6 = 0x80;
    }
    else {
      bVar5 = *param_2 >> 7;
      bVar6 = bVar5 << 7;
      bVar5 = bVar5 << 7;
      *param_2 = *param_2 & 0x7f;
      fp_add();
      fp_ld_pow10_r1(1);
      fp_cmp();
      *param_2 = *param_2 & 0x7f | bVar5 & 0x80;
      bVar6 = bVar6 & 0x80;
      if (-1 < (char)bVar6) {
        fp_div();
        bVar6 = 0;
      }
    }
    bVar5 = bVar7 & 0xf;
    bVar7 = bVar7 >> 4;
    if (-1 < (char)bVar6) {
      if (((param_1 >> 4 & 1) == 1) || ((param_1 >> 5 & 1) == 1)) {
        if (((param_1 >> 5 & 1) == 0) || (bStack_4 != param_5)) goto LAB_CODE_61a8;
        if (((param_1 >> 4 & 1) == 1) || (bVar5 <= bVar4)) {
          if (bVar5 <= bVar7) goto LAB_CODE_61a8;
          bVar7 = bVar7 + 1;
        }
        else {
          bVar4 = bVar4 + 1;
        }
      }
      else if ((param_1 >> 3 & 1) == 0) {
LAB_CODE_61a8:
        bStack_4 = bStack_4 + 1;
      }
      else if (bVar4 == 3) {
        bVar4 = 1;
        bStack_4 = bStack_4 + 3;
      }
      else {
        bVar4 = bVar4 + 1;
      }
    }
    if (bVar7 != 0) {
      *param_3 = 10;
      bVar6 = (0x3d < (*param_2 & 0x7f)) << 7;
      cVar11 = (*param_2 & 0x7f) - 0x3e;
      bVar8 = 0;
      param_2 = param_2 + -1;
      do {
        bVar9 = clc_thunk(bVar8);
        bVar8 = bVar9 << 1 | bVar6 >> 7;
        bVar6 = bVar9 & 0x80;
        cVar11 = cVar11 + -1;
      } while (cVar11 != '\0');
      cVar10 = bVar8 + 0x30;
      cVar11 = (bVar7 + bVar4 < bVar5) << 7;
      if ((cVar11 < '\0') || (bVar7 + bVar4 == bVar5)) {
        put_pad(cVar10,param_2 + '\x01',bVar4);
        put_char_dptr(0x2e);
        put_char_repeat(0x30,(bVar5 - bVar4) - (bVar7 - (((bVar5 < bVar4) << 7) >> 7)));
        put_char_dptr(cVar10);
        while (bVar7 = bVar7 - 1, bVar7 != 0) {
          put_digit();
        }
      }
      else {
        put_pad(param_2 + '\x01',bVar5 - (bVar7 - (cVar11 >> 7)));
        put_char_dptr(cVar10);
        bVar5 = (bVar4 + bVar7) - bVar5;
        if (bVar5 == 1) {
          put_char_dptr(0x2e);
        }
        bVar4 = 1;
        while (bVar7 != bVar4) {
          bVar4 = bVar4 + 1;
          put_digit();
          if (bVar5 == bVar4) {
            put_char_dptr(0x2e);
          }
        }
      }
      goto LAB_CODE_6244;
    }
  }
LAB_CODE_621c:
  if ((param_1 >> 4 & 1) == 1) {
    bVar4 = param_1 & 0xf;
    put_pad(bVar5 - bVar4);
    bStack_4 = param_5;
  }
  else {
    put_sign_char();
    bVar4 = bVar5;
    bStack_4 = param_5;
  }
  put_char_dptr(0x2e);
  put_char_repeat(0x30,bVar4);
  if ((param_1 >> 5 & 1) == 0) {
    bStack_4 = 0;
  }
LAB_CODE_6244:
  put_char_dptr(0x45);
  if ((char)bStack_4 < '\0') {
    put_char_dptr(0x2d);
  }
  else {
    put_char_dptr(0x2b);
  }
  if ((char)bStack_4 < '\0') {
    bStack_4 = ~bStack_4 + 1;
  }
  bVar4 = bStack_4 % 10;
  put_char_dptr(bStack_4 / 10 + 0x30,bVar4);
  put_char_dptr(bVar4 + 0x30);
  return;
}

/* ---- fp_to_i24_round  @0x62B3  (106 bytes)
 *      round half away from zero, C=1 if result 0 */
void fp_to_i24_round(uint8_t *param_1)

{
  bool bVar1;
  uint8_t *pbVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  char cVar5;
  uint8_t bVar6;
  
  pbVar2 = param_1 + -1;
  if (*param_1 != 0) {
    bVar3 = *param_1 & 0x7f;
    if (0x3d < bVar3) {
      if (0x17 < bVar3 - 0x3e) {
        i24_ld_max_r0();
        if ((char)pbVar2['\x01'] < '\0') {
          i24_neg(pbVar2);
        }
        OV = 1;
        return;
      }
      bVar3 = ~(bVar3 + 0xaa) + 1;
      bVar6 = 0;
      while (7 < bVar3) {
        bVar4 = i24_shr8_ins_a();
        if (bVar6 != 0) {
          bVar4 = bVar4 | 1;
        }
        bVar3 = *pbVar2;
        *pbVar2 = 0;
        bVar6 = bVar4;
      }
      bVar1 = 0xf7 < bVar3 - 8;
      if (bVar3 != 0) {
        do {
          bVar3 = bVar1 << 7;
          cVar5 = i24_shr1(bVar6);
          bVar1 = (bool)(bVar6 & 1 | bVar6 >> 1 & 1);
          bVar6 = bVar6 >> 1 & 0xfe | bVar3 & 0x80 | bVar1;
        } while (cVar5 != '\x01');
      }
      i24_round_r5();
      if ((char)*pbVar2 < '\0') {
        i24_ld_max_r0();
      }
      else {
        cVar5 = i24_test_r0();
        if (cVar5 == '\0') {
          return;
        }
      }
      if ((char)pbVar2['\x01'] < '\0') {
        i24_neg(pbVar2);
      }
      return;
    }
    OV = 0;
  }
  i24_clr_r0();
  return;
}

/* ---- i24_to_fp  @0x631D  (55 bytes)
 *      in place, result 1 byte longer (R0 + 1) */
uint8_t i24_to_fp(uint8_t *param_1)

{
  char cVar1;
  uint8_t in_PSW;
  uint8_t bVar2;
  
  cVar1 = i24_test_r0();
  if (cVar1 == '\0') {
    *param_1 = 0x80;
    param_1['\x01'] = 0;
    return 0;
  }
  bVar2 = *param_1 & 0x80;
  if ((char)bVar2 < '\0') {
    i24_neg(*param_1 << 1 | in_PSW >> 7);
    bVar2 = 0x80;
  }
  param_1['\x01'] = bVar2 + 0x56;
  while (bVar2 = *param_1, bVar2 == 0) {
    i24_shl8_ins_a();
    param_1['\x01'] = param_1['\x01'] - 8;
  }
  while (-1 < (char)bVar2) {
    clc_thunk();
    param_1['\x01'] = param_1['\x01'] - 1;
    bVar2 = *param_1;
  }
  return param_1['\x01'];
}

/* ---- fp_sqrt  @0x6417  (70 bytes)
 *      verified: 10 -> 3.162278, 2 -> 1.414214 */
void fp_sqrt(char param_1,uint8_t *param_2,uint8_t *param_3)

{
  uint8_t bVar1;
  
  if (*param_2 != 0) {
    bVar1 = *param_2 & 0x7f;
    *param_2 = bVar1;
    bVar1 = bVar1 - 0x3f;
    *param_2 = ~(bVar1 & 0xfe) + 1 + *param_2;
    *param_3 = 0x3f;
    param_3[-1] = 0xb5;
    param_3[-2] = 4;
    param_3[-3] = 0xf3;
    fp_push_r0(param_3);
    do {
      fp_clr_r0();
      fp_push_r0();
      fp_div();
      fp_add();
      *param_2 = *param_2 - 1;
      fp_swap();
      param_1 = param_1 + -1;
    } while (param_1 != '\0');
    fp_clr_r0();
    fp_swap();
    *param_2 = (bVar1 >> 1 | bVar1 & 0x80) + *param_2;
  }
  return;
}

/* ---- fp_log10  @0x645D  (13 bytes)
 *      ln(x) * 0.4342945 */
void fp_log10(void)

{
  fp_ln();
  fp_ld_code_r1(0x6547);
  fp_mul();
  return;
}

/* ---- fp_ln  @0x646A  (217 bytes) */
void fp_ln(char param_1,uint8_t *param_2,char *param_3)

{
  short sVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  char cVar4;
  
  if ((*param_2 & 0x7f) == 0) {
    fp_ld_max_r0();
    *param_2 = *param_2 | 0x80;
    OV = 1;
    return;
  }
  bVar3 = (*param_2 & 0x7f) - 0x3f;
  *param_2 = 0x3f;
  param_2 = param_2 + -1;
  bVar2 = *param_2;
  if (bVar2 < 0xa1) {
    cVar4 = '\0';
  }
  else if (bVar2 + 0x5f < 0x2aU - (((bVar2 < 0xa1) << 7) >> 7)) {
    cVar4 = '\x01';
  }
  else {
    cVar4 = '\x02';
  }
  dptr_add_a_b(0x654b);
  fp_ld_code_r1();
  param_2 = param_2 + '\x01';
  fp_push_r0();
  fp_add();
  fp_clr_r1();
  *param_3 = *param_3 + '\x01';
  fp_push_r0();
  fp_sub();
  fp_clr_r1();
  fp_div();
  if (param_1 != '\x01') {
    fp_push_r0();
    fp_copy_r0_to_r1();
    fp_mul();
    if (param_1 == '\x03') {
      fp_push_r0();
    }
    sVar1 = (uint16_t)(3 - param_1) * 4;
    dptr_add_a_b((char)sVar1,0x6563,(char)((uint16_t)sVar1 >> 8));
    fp_ld_code_r1();
    fp_mul();
    fp_ld_code_r1();
    fp_add();
    if (param_1 == '\x03') {
      fp_clr_r1();
      fp_mul();
      fp_ld_code_r1();
      fp_add();
    }
    fp_clr_r1();
    fp_mul();
  }
  *param_2 = *param_2 + 1 ^ 0x80;
  dptr_add_a_b(cVar4 << 2,0x6557);
  fp_ld_code_r1();
  fp_add();
  fp_push_r0();
  bVar2 = 0;
  if ((char)bVar3 < '\0') {
    bVar2 = 0xff;
  }
  param_2[-1] = bVar2;
  param_2[-2] = bVar2;
  param_2[-3] = bVar3;
  i24_to_fp(param_2 + -1);
  fp_ld_code_r1(0x6543);
  fp_mul();
  fp_clr_r1();
  fp_add();
  return;
}

/* ---- fp_sub  @0x656F  (8 bytes)
 *      @R0 -= @R1 (negate R1, add) */
uint8_t fp_sub(uint8_t *param_1,uint8_t *param_2)

{
  bool bVar1;
  uint8_t *pbVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  uint8_t bVar6;
  char cVar7;
  
  if (*param_2 != 0) {
    *param_2 = *param_2 ^ 0x80;
    bVar4 = fp_add();
    return bVar4;
  }
  if (*param_2 != 0) {
    if (*param_1 != 0) {
      bVar4 = (*param_1 & 0x7f) - (*param_2 & 0x7f);
      bVar3 = 0;
      if (bVar4 != 0) {
        if ((*param_1 & 0x7f) < (*param_2 & 0x7f)) {
          bVar4 = fp_swap();
          bVar4 = ~bVar4 + 1;
        }
        if ((0x18 < bVar4) << 7 < '\0') goto LAB_CODE_6586;
        param_1 = param_1 + -1;
        param_2 = param_2 + -1;
        while (7 < bVar4) {
          bVar5 = i24_shr8_ins_a_r1();
          if (bVar3 != 0) {
            bVar5 = bVar5 | 1;
          }
          bVar4 = *param_2;
          *param_2 = 0;
          bVar3 = bVar5;
        }
        bVar1 = 0xf7 < bVar4 - 8;
        if (bVar4 != 0) {
          do {
            bVar5 = bVar1 << 7;
            i24_shr1_r1();
            bVar1 = (bool)(bVar3 & 1 | bVar3 >> 1 & 1);
            bVar3 = bVar3 >> 1 & 0xfe | bVar5 & 0x80 | bVar1;
            bVar4 = bVar4 - 1;
          } while (bVar4 != 0);
        }
        param_1 = param_1 + '\x01';
        param_2 = param_2 + '\x01';
      }
      bVar4 = *param_1;
      bVar5 = bVar4 & 0x7f;
      bVar6 = bVar4 << 7;
      param_1 = param_1 + -1;
      pbVar2 = param_2 + -1;
      if (-1 < (char)(bVar4 & 0x80 ^ *param_2)) {
        i24_add();
        if ((char)bVar6 < '\0') {
          i24_rrc();
          bVar5 = bVar5 + 1;
          if (bVar5 == 0x7f) {
            param_1 = param_1 + '\x01';
            OV = 1;
            bVar3 = fp_ld_max_r0(*param_1 & 0x80,pbVar2 + '\x01',
                                 bVar3 >> 1 & 0xfe | bVar6 & 0x80 | bVar3 & 1 | bVar3 >> 1 & 1);
            bVar4 = *param_1;
            *param_1 = bVar3 | bVar4;
            return bVar3 | bVar4;
          }
        }
LAB_CODE_6639:
        param_1['\x01'] = param_1['\x01'] & 0x80 | bVar5;
        bVar4 = fp_round_normalize(pbVar2 + '\x01');
        return bVar4;
      }
      cVar7 = (bVar3 != 0) << 7;
      bVar3 = -bVar3;
      bVar4 = i24_sub_core(pbVar2);
      bVar4 = bVar4 | bVar3;
      if (bVar4 == 0) {
        *param_1 = 0x80;
      }
      else {
        if (cVar7 < '\0') {
          param_1['\x01'] = param_1['\x01'] ^ 0x80;
          bVar3 = -bVar3;
          bVar4 = i24_neg_c();
        }
        while ((bVar4 == 0 && (8 < bVar5))) {
          bVar5 = bVar5 - 8;
          bVar4 = bVar3 & 1;
          bVar3 = 0;
          if (bVar4 != 0) {
            bVar3 = 0xff;
          }
          i24_shl8_ins_a();
          bVar4 = *param_1;
        }
        do {
          if ((char)*param_1 < '\0') goto LAB_CODE_6639;
          bVar3 = bVar3 << 1 | bVar3 & 1;
          i24_shl1(bVar3);
          bVar5 = bVar5 - 1;
        } while (bVar5 != 0);
      }
      OV = 0;
      param_1['\x01'] = 0;
      return 0;
    }
    fp_copy_r1_to_r0();
  }
LAB_CODE_6586:
  return *param_1;
}

/* ---- fp_rsub  @0x6577  (6 bytes)
 *      @R0 = @R1 - @R0 */
uint8_t fp_rsub(uint8_t *param_1,uint8_t *param_2)

{
  bool bVar1;
  uint8_t *pbVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  uint8_t bVar6;
  char cVar7;
  
  if (*param_1 != 0) {
    *param_1 = *param_1 ^ 0x80;
  }
  if (*param_2 != 0) {
    if (*param_1 != 0) {
      bVar4 = (*param_1 & 0x7f) - (*param_2 & 0x7f);
      bVar3 = 0;
      if (bVar4 != 0) {
        if ((*param_1 & 0x7f) < (*param_2 & 0x7f)) {
          bVar4 = fp_swap();
          bVar4 = ~bVar4 + 1;
        }
        if ((0x18 < bVar4) << 7 < '\0') goto LAB_CODE_6586;
        param_1 = param_1 + -1;
        param_2 = param_2 + -1;
        while (7 < bVar4) {
          bVar5 = i24_shr8_ins_a_r1();
          if (bVar3 != 0) {
            bVar5 = bVar5 | 1;
          }
          bVar4 = *param_2;
          *param_2 = 0;
          bVar3 = bVar5;
        }
        bVar1 = 0xf7 < bVar4 - 8;
        if (bVar4 != 0) {
          do {
            bVar5 = bVar1 << 7;
            i24_shr1_r1();
            bVar1 = (bool)(bVar3 & 1 | bVar3 >> 1 & 1);
            bVar3 = bVar3 >> 1 & 0xfe | bVar5 & 0x80 | bVar1;
            bVar4 = bVar4 - 1;
          } while (bVar4 != 0);
        }
        param_1 = param_1 + '\x01';
        param_2 = param_2 + '\x01';
      }
      bVar4 = *param_1;
      bVar5 = bVar4 & 0x7f;
      bVar6 = bVar4 << 7;
      param_1 = param_1 + -1;
      pbVar2 = param_2 + -1;
      if (-1 < (char)(bVar4 & 0x80 ^ *param_2)) {
        i24_add();
        if ((char)bVar6 < '\0') {
          i24_rrc();
          bVar5 = bVar5 + 1;
          if (bVar5 == 0x7f) {
            param_1 = param_1 + '\x01';
            OV = 1;
            bVar3 = fp_ld_max_r0(*param_1 & 0x80,pbVar2 + '\x01',
                                 bVar3 >> 1 & 0xfe | bVar6 & 0x80 | bVar3 & 1 | bVar3 >> 1 & 1);
            bVar4 = *param_1;
            *param_1 = bVar3 | bVar4;
            return bVar3 | bVar4;
          }
        }
LAB_CODE_6639:
        param_1['\x01'] = param_1['\x01'] & 0x80 | bVar5;
        bVar4 = fp_round_normalize(pbVar2 + '\x01');
        return bVar4;
      }
      cVar7 = (bVar3 != 0) << 7;
      bVar3 = -bVar3;
      bVar4 = i24_sub_core(pbVar2);
      bVar4 = bVar4 | bVar3;
      if (bVar4 == 0) {
        *param_1 = 0x80;
      }
      else {
        if (cVar7 < '\0') {
          param_1['\x01'] = param_1['\x01'] ^ 0x80;
          bVar3 = -bVar3;
          bVar4 = i24_neg_c();
        }
        while ((bVar4 == 0 && (8 < bVar5))) {
          bVar5 = bVar5 - 8;
          bVar4 = bVar3 & 1;
          bVar3 = 0;
          if (bVar4 != 0) {
            bVar3 = 0xff;
          }
          i24_shl8_ins_a();
          bVar4 = *param_1;
        }
        do {
          if ((char)*param_1 < '\0') goto LAB_CODE_6639;
          bVar3 = bVar3 << 1 | bVar3 & 1;
          i24_shl1(bVar3);
          bVar5 = bVar5 - 1;
        } while (bVar5 != 0);
      }
      OV = 0;
      param_1['\x01'] = 0;
      return 0;
    }
    fp_copy_r1_to_r0();
  }
LAB_CODE_6586:
  return *param_1;
}

/* ---- fp_add  @0x657D  (207 bytes)
 *      @R0 += @R1 */
uint8_t fp_add(uint8_t *param_1,uint8_t *param_2)

{
  bool bVar1;
  uint8_t *pbVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  uint8_t bVar6;
  char cVar7;
  
  if (*param_2 != 0) {
    if (*param_1 != 0) {
      bVar4 = (*param_1 & 0x7f) - (*param_2 & 0x7f);
      bVar3 = 0;
      if (bVar4 != 0) {
        if ((*param_1 & 0x7f) < (*param_2 & 0x7f)) {
          bVar4 = fp_swap();
          bVar4 = ~bVar4 + 1;
        }
        if ((0x18 < bVar4) << 7 < '\0') goto LAB_CODE_6586;
        param_1 = param_1 + -1;
        param_2 = param_2 + -1;
        while (7 < bVar4) {
          bVar5 = i24_shr8_ins_a_r1();
          if (bVar3 != 0) {
            bVar5 = bVar5 | 1;
          }
          bVar4 = *param_2;
          *param_2 = 0;
          bVar3 = bVar5;
        }
        bVar1 = 0xf7 < bVar4 - 8;
        if (bVar4 != 0) {
          do {
            bVar5 = bVar1 << 7;
            i24_shr1_r1();
            bVar1 = (bool)(bVar3 & 1 | bVar3 >> 1 & 1);
            bVar3 = bVar3 >> 1 & 0xfe | bVar5 & 0x80 | bVar1;
            bVar4 = bVar4 - 1;
          } while (bVar4 != 0);
        }
        param_1 = param_1 + '\x01';
        param_2 = param_2 + '\x01';
      }
      bVar4 = *param_1;
      bVar5 = bVar4 & 0x7f;
      bVar6 = bVar4 << 7;
      param_1 = param_1 + -1;
      pbVar2 = param_2 + -1;
      if (-1 < (char)(bVar4 & 0x80 ^ *param_2)) {
        i24_add();
        if ((char)bVar6 < '\0') {
          i24_rrc();
          bVar5 = bVar5 + 1;
          if (bVar5 == 0x7f) {
            param_1 = param_1 + '\x01';
            OV = 1;
            bVar3 = fp_ld_max_r0(*param_1 & 0x80,pbVar2 + '\x01',
                                 bVar3 >> 1 & 0xfe | bVar6 & 0x80 | bVar3 & 1 | bVar3 >> 1 & 1);
            bVar4 = *param_1;
            *param_1 = bVar3 | bVar4;
            return bVar3 | bVar4;
          }
        }
LAB_CODE_6639:
        param_1['\x01'] = param_1['\x01'] & 0x80 | bVar5;
        bVar4 = fp_round_normalize(pbVar2 + '\x01');
        return bVar4;
      }
      cVar7 = (bVar3 != 0) << 7;
      bVar3 = -bVar3;
      bVar4 = i24_sub_core(pbVar2);
      bVar4 = bVar4 | bVar3;
      if (bVar4 == 0) {
        *param_1 = 0x80;
      }
      else {
        if (cVar7 < '\0') {
          param_1['\x01'] = param_1['\x01'] ^ 0x80;
          bVar3 = -bVar3;
          bVar4 = i24_neg_c();
        }
        while ((bVar4 == 0 && (8 < bVar5))) {
          bVar5 = bVar5 - 8;
          bVar4 = bVar3 & 1;
          bVar3 = 0;
          if (bVar4 != 0) {
            bVar3 = 0xff;
          }
          i24_shl8_ins_a();
          bVar4 = *param_1;
        }
        do {
          if ((char)*param_1 < '\0') goto LAB_CODE_6639;
          bVar3 = bVar3 << 1 | bVar3 & 1;
          i24_shl1(bVar3);
          bVar5 = bVar5 - 1;
        } while (bVar5 != 0);
      }
      OV = 0;
      param_1['\x01'] = 0;
      return 0;
    }
    fp_copy_r1_to_r0();
  }
LAB_CODE_6586:
  return *param_1;
}

/* ---- fp_div  @0x664C  (158 bytes)
 *      @R0 /= @R1; C=1,OV=1 on divide by zero */
uint8_t fp_div(uint8_t *param_1,char *param_2)

{
  char cVar1;
  uint8_t *pbVar2;
  char *pcVar3;
  uint8_t *pbVar4;
  char cVar5;
  uint8_t bVar6;
  uint8_t bVar7;
  uint8_t bVar8;
  uint8_t bVar9;
  uint8_t bVar10;
  uint8_t bVar11;
  uint8_t bVar12;
  uint8_t bVar13;
  uint8_t bVar14;
  uint8_t uVar15;
  uint8_t bVar16;
  
  if (*param_2 == '\0') {
    OV = 1;
    bVar9 = *param_1;
  }
  else {
    bVar9 = 0;
    if (*param_1 != 0) {
      bVar9 = *param_1;
      *param_1 = 0;
      bVar14 = param_1[-1];
      param_1[-1] = 0;
      bVar13 = param_1[-2];
      param_1[-2] = 0;
      bVar6 = param_1[-3];
      param_1[-3] = 0;
      cVar5 = '\x1f';
      bVar10 = 0x80;
      pcVar3 = param_2 + -1;
LAB_CODE_6670:
      bVar16 = (bVar14 < (uint8_t)(*pcVar3 -
                               (((bVar13 < (uint8_t)(param_2[-2] -
                                                 (((bVar6 < (uint8_t)param_2[-3]) << 7) >> 7))) << 7)
                               >> 7))) << 7;
      bVar7 = bVar6;
      bVar8 = bVar13;
      bVar12 = bVar14;
      bVar11 = bVar10;
      if ((char)bVar16 < '\0') goto LAB_CODE_668d;
      do {
        bVar16 = param_2[-3] - ((char)bVar16 >> 7);
        bVar8 = param_2[-2] - (((bVar6 < bVar16) << 7) >> 7);
        bVar12 = bVar14 - (*pcVar3 - (((bVar13 < bVar8) << 7) >> 7));
        bVar14 = *param_1;
        *param_1 = bVar12;
        *param_1 = bVar14 | bVar10;
        bVar7 = bVar6 - bVar16;
        bVar8 = bVar13 - bVar8;
        bVar11 = bVar10;
LAB_CODE_668d:
        while( true ) {
          cVar5 = cVar5 + -1;
          if (cVar5 == '\0') {
            bVar14 = 0;
            if ((bVar12 != 0 || bVar8 != 0) || bVar7 != 0) {
              bVar14 = *param_1 | 1;
              *param_1 = bVar14;
            }
            bVar14 = bVar14 << 7;
            pbVar2 = param_1 + '\x03';
            if (-1 < (char)*pbVar2) {
              param_1 = param_1 + '\x02';
              i24_shl1();
              pbVar2 = param_1 + '\x01';
              *pbVar2 = *pbVar2 << 1 | bVar14 >> 7;
              bVar9 = bVar9 - 1;
            }
            bVar14 = *pbVar2;
            *pbVar2 = bVar9;
            pbVar2 = pbVar2 + -1;
            uVar15 = i24_shr8_ins_a(bVar14);
            pbVar2 = pbVar2 + '\x01';
            pbVar4 = (uint8_t *)(pcVar3 + '\x01');
            bVar9 = *pbVar4;
            F0 = bVar9 >> 7;
            cVar1 = F0;
            cVar5 = cVar1 << 7;
            *pbVar4 = ~(bVar9 & 0x7f) + 0x7f & 0x7f | cVar1 << 7;
            fp_exp_add(uVar15);
            *pbVar4 = bVar9;
            if (-1 < cVar5) {
              fp_round_normalize();
            }
            return *pbVar2;
          }
          bVar10 = bVar11 >> 1 | bVar11 << 7;
          if ((bVar11 & 1) != 0) {
            param_1 = param_1 + -1;
          }
          bVar6 = bVar7 << 1;
          bVar13 = bVar8 << 1 | bVar7 >> 7;
          bVar14 = bVar12 << 1 | bVar8 >> 7;
          bVar16 = bVar12 & 0x80;
          cVar1 = C;
          if (cVar1 != '\0') break;
          bVar16 = bVar12 & 0x7f;
          bVar7 = bVar6;
          bVar8 = bVar13;
          bVar12 = bVar14;
          bVar11 = bVar10;
          if (bVar16 >> 6 != 0) goto LAB_CODE_6670;
        }
        C = 0;
      } while( true );
    }
  }
  return bVar9;
}

/* ---- fp_mul  @0x66EA  (50 bytes)
 *      @R0 *= @R1 */
void fp_mul(char *param_1,char *param_2,char param_3,char param_4,uint8_t param_5)

{
  uint8_t bVar1;
  
  bVar1 = 0;
  if (*param_1 != '\0') {
    if (*param_2 != '\0') {
      param_1 = param_1 + -1;
      param_2 = param_2 + -1;
      mant_mul24(param_2);
      if (param_4 != '\0' || param_3 != '\0') {
        param_5 = param_5 | 1;
      }
      if (*param_1 < '\0') {
        param_1 = param_1 + '\x01';
        *param_1 = *param_1 + '\x01';
      }
      else {
        bVar1 = param_5 & 0x80;
        i24_shl1(param_5 << 1 | param_5 & 1);
        param_1 = param_1 + '\x01';
      }
      fp_exp_add(param_1,param_2 + '\x01');
      if (-1 < (char)bVar1) {
        fp_round_normalize();
      }
      return;
    }
    *param_1 = '\0';
  }
  return;
}

/* ---- fp_exp_add  @0x671C  (44 bytes)
 *      exponent arithmetic for mul/div, over/underflow */
void fp_exp_add(uint8_t *param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  
  bVar1 = (*param_2 ^ *param_1) & 0x80;
  *param_1 = *param_1 & 0x7f;
  bVar2 = (*param_2 & 0x7f) + *param_1;
  if (bVar2 < 0x40) {
    OV = 0;
    *param_1 = 0;
    return;
  }
  if ((bVar2 < 0xbe) << 7 < '\0') {
    *param_1 = bVar2 - 0x3f;
  }
  else {
    OV = 1;
    fp_ld_max_r0();
  }
  *param_1 = *param_1 ^ bVar1;
  return;
}

/* ---- fp_round_normalize  @0x6748  (31 bytes) */
uint8_t fp_round_normalize(char param_1)

{
  uint8_t *puVar1;
  uint8_t *pbVar2;
  uint8_t bVar3;
  char in_PSW;
  
  puVar1 = (uint8_t *)(param_1 + -1);
  i24_round_r5();
  pbVar2 = puVar1 + '\x01';
  if (in_PSW < '\0') {
    if ((*pbVar2 | 0x81) == 0xff) {
      bVar3 = fp_ld_max_r0(*pbVar2 & 0x80);
      *pbVar2 = bVar3 | *pbVar2;
    }
    else {
      *pbVar2 = *pbVar2 + 1;
      *puVar1 = 0x80;
    }
  }
  return *pbVar2;
}

/* ---- fp_cmp  @0x6767  (47 bytes)
 *      compare @R0 with @R1 -> C */
uint8_t fp_cmp(uint8_t *param_1,uint8_t *param_2)

{
  uint8_t uVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  char cVar4;
  char cVar5;
  
  F0 = *param_1 >> 7;
  if (-1 < (char)(*param_1 ^ *param_2)) {
    bVar2 = *param_1 & 0x7f;
    bVar3 = *param_2 & 0x7f;
    cVar5 = (bVar3 < bVar2) << 7;
    if (bVar3 >= bVar2) {
      if (bVar3 == bVar2) {
        if (*param_1 == 0) {
          return 0;
        }
        cVar4 = i24_cmp(param_1 + -1,param_2 + -1);
        if (cVar4 == '\0') {
          return 0;
        }
        if (-1 < cVar5) goto LAB_CODE_6770;
      }
      bVar2 = F0;
      F0 = bVar2 ^ 1;
    }
  }
LAB_CODE_6770:
  uVar1 = F0;
  return 0xff;
}

/* ---- fp_copy_r0_to_r1  @0x6796  (21 bytes) */
void fp_copy_r0_to_r1(uint8_t *param_1,uint8_t *param_2)

{
  param_2[-3] = param_1[-3];
  param_2[-2] = param_1[-2];
  param_2[-1] = param_1[-1];
  *param_2 = *param_1;
  return;
}

/* ---- fp_copy_r1_to_r0  @0x67AB  (21 bytes) */
void fp_copy_r1_to_r0(uint8_t *param_1,uint8_t *param_2)

{
  param_1[-3] = param_2[-3];
  param_1[-2] = param_2[-2];
  param_1[-1] = param_2[-1];
  *param_1 = *param_2;
  return;
}

/* ---- fp_ld_code_r0  @0x67C0  (16 bytes)
 *      @R0 = float from code @DPTR */
void fp_ld_code_r0(char *param_1,char *param_2)

{
  char cVar1;
  
  cVar1 = '\x04';
  do {
    *param_2 = cVar1;
    cVar1 = *param_2;
    *param_2 = *param_1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- fp_ld_code_r1  @0x67D0  (16 bytes) */
void fp_ld_code_r1(char *param_1,char *param_2)

{
  char cVar1;
  
  cVar1 = '\x04';
  do {
    *param_2 = cVar1;
    cVar1 = *param_2;
    *param_2 = *param_1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- fp_ld_max_r0  @0x67E0  (15 bytes)
 *      7F FFFFFF */
void fp_ld_max_r0(uint8_t *param_1)

{
  param_1[-3] = 0xff;
  param_1[-2] = 0xff;
  param_1[-1] = 0xff;
  *param_1 = 0x7e;
  return;
}

/* ---- fp_clr_r0  @0x67EF  (31 bytes) */
void fp_clr_r0(uint8_t *param_1)

{
  uint8_t in_stack_000000fb;
  uint8_t in_stack_000000fc;
  uint8_t in_stack_000000fd;
  uint8_t in_stack_000000fe;
  
  param_1[-3] = in_stack_000000fe;
  param_1[-2] = in_stack_000000fd;
  param_1[-1] = in_stack_000000fc;
  *param_1 = in_stack_000000fb;
  return;
}

/* ---- fp_clr_r1  @0x680E  (31 bytes) */
void fp_clr_r1(uint8_t *param_1)

{
  uint8_t in_stack_000000fb;
  uint8_t in_stack_000000fc;
  uint8_t in_stack_000000fd;
  uint8_t in_stack_000000fe;
  
  param_1[-3] = in_stack_000000fe;
  param_1[-2] = in_stack_000000fd;
  param_1[-1] = in_stack_000000fc;
  *param_1 = in_stack_000000fb;
  return;
}

/* ---- fp_push_r0  @0x682D  (31 bytes)
 *      push float @R0 on the stack (keeps return address) */
void fp_push_r0(void)

{
  return;
}

/* ---- fp_push_r1  @0x684C  (31 bytes) */
void fp_push_r1(void)

{
  return;
}

/* ---- fp_swap  @0x686B  (25 bytes) */
uint8_t fp_swap(uint8_t param_1,uint8_t *param_2,uint8_t *param_3)

{
  uint8_t uVar1;
  uint8_t uVar2;
  uint8_t *puVar3;
  uint8_t *puVar4;
  
  puVar3 = param_3 + -2;
  puVar4 = param_3 + -3;
  uVar1 = *puVar4;
  *puVar4 = param_1;
  uVar2 = param_2[-3];
  param_2[-3] = uVar1;
  uVar1 = *puVar4;
  *puVar4 = uVar2;
  uVar2 = *puVar3;
  *puVar3 = uVar1;
  uVar1 = param_2[-2];
  param_2[-2] = uVar2;
  uVar2 = *puVar3;
  *puVar3 = uVar1;
  puVar3 = param_3 + -1;
  uVar1 = *puVar3;
  *puVar3 = uVar2;
  uVar2 = param_2[-1];
  param_2[-1] = uVar1;
  uVar1 = *puVar3;
  *puVar3 = uVar2;
  uVar2 = *param_3;
  *param_3 = uVar1;
  uVar1 = *param_2;
  *param_2 = uVar2;
  uVar2 = *param_3;
  *param_3 = uVar1;
  return uVar2;
}

/* ---- fp_ld_xdata_r0  @0x6884  (15 bytes) */
void fp_ld_xdata_r0(char *param_1,char *param_2)

{
  char cVar1;
  
  cVar1 = '\x04';
  do {
    *param_2 = cVar1;
    cVar1 = *param_2;
    *param_2 = *param_1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- fp_ld_xdata_r1  @0x6893  (15 bytes) */
void fp_ld_xdata_r1(char *param_1,char *param_2)

{
  char cVar1;
  
  cVar1 = '\x04';
  do {
    *param_2 = cVar1;
    cVar1 = *param_2;
    *param_2 = *param_1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- fp_st_r0_xdata  @0x68A2  (15 bytes) */
void fp_st_r0_xdata(char *param_1,char *param_2)

{
  char cVar1;
  char cVar2;
  
  cVar2 = '\x04';
  do {
    cVar1 = *param_2;
    *param_2 = cVar2;
    *param_1 = cVar1;
    cVar2 = *param_2;
    *param_2 = cVar1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  return;
}

/* ---- fp_st_r1_xdata  @0x68B1  (15 bytes) */
void fp_st_r1_xdata(char *param_1,char *param_2)

{
  char cVar1;
  char cVar2;
  
  cVar2 = '\x04';
  do {
    cVar1 = *param_2;
    *param_2 = cVar2;
    *param_1 = cVar1;
    cVar2 = *param_2;
    *param_2 = cVar1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  return;
}

/* ---- fp_ld_pow10_r1  @0x68CB  (20 bytes)
 *      @R1 = 10^A, A = -18..19 (table 0x68DF) */
void fp_ld_pow10_r1(char param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar3;
  
  bVar3 = param_1 + 0x12;
  bVar3 = ((bVar3 * '\x02' | bVar3 >> 7) << 1 | (bVar3 & 0x7f) >> 6) + 10;
  cVar2 = '\x04';
  do {
    *param_2 = bVar3;
    bVar1 = *param_2;
    *param_2 = *(uint8_t *)((uint16_t)bVar3 + 0x68d5);
    param_2 = param_2 + -1;
    bVar3 = bVar1 + 1;
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  return;
}

/* ---- i24_round_r5  @0x6977  (19 bytes) */
void i24_round_r5(char param_1,uint8_t param_2)

{
  char cVar1;
  
  if (0x7f < param_2) {
    cVar1 = i24_inc_r0();
    if (cVar1 == '\0') {
      *(uint8_t *)(param_1 + -2) = *(uint8_t *)(param_1 + -2) & 0xfe;
    }
  }
  return;
}

/* ---- i24_div_signed  @0x698A  (4 bytes) */
uint8_t i24_div_signed(char *param_1,char *param_2,char param_3,char param_4,char param_5)

{
  uint8_t uVar1;
  char in_PSW;
  
  if (*param_2 < '\0') {
    i24_neg();
    i24_neg_r1();
    uVar1 = i24_div_signed_core();
    if (in_PSW < '\0') {
      return uVar1;
    }
    i24_neg_r1(uVar1);
  }
  else {
    if (-1 < *param_1) {
      uVar1 = i24_div();
      return uVar1;
    }
    i24_neg();
    uVar1 = i24_div();
    if (in_PSW < '\0') {
      return uVar1;
    }
    param_3 = param_3 - (in_PSW >> 7);
    param_4 = param_4 - (((param_3 != '\0') << 7) >> 7);
    i24_neg(uVar1,-param_3,-param_4,-(param_5 - (((param_4 != '\0') << 7) >> 7)));
  }
  return uVar1;
}

/* ---- i24_div_signed_core  @0x698E  (33 bytes) */
uint8_t i24_div_signed_core(char *param_1,char param_2,char param_3,char param_4)

{
  uint8_t uVar1;
  char in_PSW;
  
  if (-1 < *param_1) {
    uVar1 = i24_div();
    return uVar1;
  }
  i24_neg();
  uVar1 = i24_div();
  if (-1 < in_PSW) {
    param_2 = param_2 - (in_PSW >> 7);
    param_3 = param_3 - (((param_2 != '\0') << 7) >> 7);
    i24_neg(uVar1,-param_2,-param_3,-(param_4 - (((param_3 != '\0') << 7) >> 7)));
  }
  return uVar1;
}

/* ---- i24_div  @0x69BE  (118 bytes)
 *      24-bit restoring division */
void i24_div(uint8_t *param_1,char *param_2)

{
  char cVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  char cVar5;
  uint8_t bVar6;
  uint8_t bVar7;
  uint8_t bVar8;
  
  bVar4 = 0;
  bVar3 = 0;
  bVar2 = 0;
  cVar5 = i24_test_r1();
  if (cVar5 == '\0') {
    return;
  }
  cVar5 = i24_test_r0();
  if (cVar5 != '\0') {
    cVar5 = '\x18';
    bVar8 = 0;
    do {
      bVar6 = param_1[-2];
      param_1[-2] = bVar6 << 1 | bVar8 >> 7;
      bVar8 = param_1[-1];
      param_1[-1] = bVar8 << 1 | bVar6 >> 7;
      bVar6 = *param_1;
      *param_1 = bVar6 << 1 | bVar8 >> 7;
      bVar8 = bVar2 << 1 | bVar6 >> 7;
      bVar6 = bVar3 << 1 | bVar2 >> 7;
      bVar7 = bVar4 << 1 | bVar3 >> 7;
      bVar4 = param_2[-2] - ((char)bVar4 >> 7);
      bVar2 = bVar8 - bVar4;
      bVar4 = param_2[-1] - (((bVar8 < bVar4) << 7) >> 7);
      bVar3 = bVar6 - bVar4;
      bVar6 = *param_2 - (((bVar6 < bVar4) << 7) >> 7);
      bVar4 = bVar7 - bVar6;
      bVar8 = (bVar6 <= bVar7) << 7;
      if (bVar6 > bVar7) {
        while( true ) {
          cVar5 = cVar5 + -1;
          if (cVar5 == '\0') {
            i24_add_r345();
            goto LAB_CODE_6a2c;
          }
          bVar6 = param_1[-2];
          param_1[-2] = bVar6 << 1 | bVar8 >> 7;
          bVar8 = param_1[-1];
          param_1[-1] = bVar8 << 1 | bVar6 >> 7;
          bVar6 = *param_1;
          *param_1 = bVar6 << 1 | bVar8 >> 7;
          bVar8 = bVar2 << 1 | bVar6 >> 7;
          bVar6 = bVar3 << 1 | bVar2 >> 7;
          bVar7 = bVar4 << 1 | bVar3 >> 7;
          F0 = bVar4 >> 7;
          bVar2 = bVar8 + param_2[-2];
          bVar4 = param_2[-1] - ((CARRY1(bVar8,param_2[-2]) << 7) >> 7);
          bVar3 = bVar6 + bVar4;
          bVar4 = *param_2 - ((CARRY1(bVar6,bVar4) << 7) >> 7);
          bVar8 = CARRY1(bVar7,bVar4) << 7;
          bVar4 = bVar7 + bVar4;
          cVar1 = F0;
          if ((cVar1 != '\0') && ((char)bVar8 < '\0')) break;
          bVar8 = 0;
        }
      }
      cVar5 = cVar5 + -1;
    } while (cVar5 != '\0');
LAB_CODE_6a2c:
    i24_shl1();
    i24_test_r0();
  }
  return;
}

/* ---- i24_add  @0x6A34  (21 bytes)
 *      verified 1000 + 7 */
uint8_t i24_add(uint8_t *param_1,char *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  uint8_t bVar5;
  
  pbVar4 = param_1 + -1;
  bVar1 = param_1[-2];
  bVar2 = param_2[-2];
  bVar5 = bVar1 + bVar2;
  param_1[-2] = bVar5;
  bVar3 = *pbVar4;
  *pbVar4 = bVar5;
  bVar5 = param_2[-1] - ((CARRY1(bVar1,bVar2) << 7) >> 7);
  bVar1 = *pbVar4;
  *pbVar4 = bVar3 + bVar5;
  bVar2 = *param_1;
  *param_1 = bVar1 | *pbVar4;
  bVar1 = *param_1;
  *param_1 = bVar2 + (*param_2 - ((CARRY1(bVar3,bVar5) << 7) >> 7));
  return bVar1 | *param_1;
}

/* ---- i24_add_r345  @0x6A49  (16 bytes) */
uint8_t i24_add_r345(char *param_1,uint8_t param_2,uint8_t param_3,char param_4)

{
  uint8_t bVar1;
  
  bVar1 = param_1[-1] - ((CARRY1(param_2,param_1[-2]) << 7) >> 7);
  return param_2 + param_1[-2] | param_3 + bVar1 |
         param_4 + (*param_1 - ((CARRY1(param_3,bVar1) << 7) >> 7));
}

/* ---- i24_mul_signed  @0x6A59  (66 bytes)
 *      24x24 signed multiply (mant_mul24 + sign fix) */
uint8_t i24_mul_signed(char *param_1,char *param_2,char param_3,char param_4,char param_5)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  
  bVar2 = 0;
  if (*param_1 < '\0') {
    bVar2 = 0x80;
    i24_neg();
  }
  if (*param_2 < '\0') {
    bVar2 = bVar2 | 0x40;
    i24_neg_r1();
  }
  bVar3 = mant_mul24();
  if ((bVar2 >> 6 & 1) != 0) {
    i24_neg_r1();
  }
  if (((bVar2 >> 1 ^ bVar2) >> 6 & 1) == 1) {
    param_4 = param_4 - (((param_3 != '\0') << 7) >> 7);
    bVar2 = -param_4;
    bVar1 = -(param_5 - (((param_4 != '\0') << 7) >> 7));
    bVar3 = bVar3 | -param_3 | bVar2 | bVar1;
    i24_neg_c(bVar3,-param_3,bVar2,bVar1);
    return bVar3;
  }
  return bVar3;
}

/* ---- i24_abs  @0x6A9B  (5 bytes) */
void i24_abs(char *param_1)

{
  char cVar1;
  
  if (*param_1 < '\0') {
    cVar1 = param_1[-2];
    param_1[-2] = -cVar1;
    cVar1 = param_1[-1] - (((cVar1 != '\0') << 7) >> 7);
    param_1[-1] = -cVar1;
    *param_1 = -(*param_1 - (((cVar1 != '\0') << 7) >> 7));
    return;
  }
  return;
}

/* ---- i24_neg  @0x6AA0  (1 bytes)
 *      0 - x */
void i24_neg(char *param_1)

{
  char cVar1;
  
  cVar1 = param_1[-2];
  param_1[-2] = -cVar1;
  cVar1 = param_1[-1] - (((cVar1 != '\0') << 7) >> 7);
  param_1[-1] = -cVar1;
  *param_1 = -(*param_1 - (((cVar1 != '\0') << 7) >> 7));
  return;
}

/* ---- i24_neg_c  @0x6AA1  (14 bytes) */
void i24_neg_c(char *param_1)

{
  char cVar1;
  char in_PSW;
  
  cVar1 = param_1[-2] - (in_PSW >> 7);
  param_1[-2] = -cVar1;
  cVar1 = param_1[-1] - (((cVar1 != '\0') << 7) >> 7);
  param_1[-1] = -cVar1;
  *param_1 = -(*param_1 - (((cVar1 != '\0') << 7) >> 7));
  return;
}

/* ---- i24_shl8_ins_a  @0x6AAF  (8 bytes) */
uint8_t i24_shl8_ins_a(uint8_t param_1,uint8_t *param_2)

{
  uint8_t uVar1;
  uint8_t uVar2;
  
  uVar1 = param_2[-2];
  param_2[-2] = param_1;
  uVar2 = param_2[-1];
  param_2[-1] = uVar1;
  uVar1 = *param_2;
  *param_2 = uVar2;
  return uVar1;
}

/* ---- i24_shr8_ins_a  @0x6AB7  (8 bytes)
 *      shift right one byte, A in at the top */
uint8_t i24_shr8_ins_a(uint8_t param_1,uint8_t *param_2)

{
  uint8_t uVar1;
  uint8_t uVar2;
  
  uVar1 = *param_2;
  *param_2 = param_1;
  uVar2 = param_2[-1];
  param_2[-1] = uVar1;
  uVar1 = param_2[-2];
  param_2[-2] = uVar2;
  return uVar1;
}

/* ---- i24_shr8_ins_a_r1  @0x6ABF  (8 bytes) */
uint8_t i24_shr8_ins_a_r1(uint8_t param_1,uint8_t *param_2)

{
  uint8_t uVar1;
  uint8_t uVar2;
  
  uVar1 = *param_2;
  *param_2 = param_1;
  uVar2 = param_2[-1];
  param_2[-1] = uVar1;
  uVar1 = param_2[-2];
  param_2[-2] = uVar2;
  return uVar1;
}

/* ---- i24_neg_r1  @0x6AC7  (10 bytes) */
uint8_t i24_neg_r1(uint8_t param_1,uint8_t param_2,uint8_t param_3)

{
  uint8_t uVar1;
  
  uVar1 = i24_neg(param_1,param_3,param_2);
  return uVar1;
}

/* ---- i24_clr_r0  @0x6AD1  (11 bytes) */
void i24_clr_r0(uint8_t *param_1)

{
  *param_1 = 0;
  param_1[-1] = 0;
  param_1[-2] = 0;
  return;
}

/* ---- i24_clr_r1  @0x6ADC  (11 bytes) */
void i24_clr_r1(uint8_t *param_1)

{
  *param_1 = 0;
  param_1[-1] = 0;
  param_1[-2] = 0;
  return;
}

/* ---- i24_cmp_signed  @0x6AE7  (10 bytes) */
uint8_t i24_cmp_signed(uint8_t *param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  
  if ((char)(*param_1 ^ *param_2) < '\0') {
    return 1;
  }
  bVar1 = param_2[-1] - (((param_1[-2] < param_2[-2]) << 7) >> 7);
  return *param_1 - (*param_2 - (((param_1[-1] < bVar1) << 7) >> 7)) |
         param_1[-1] - bVar1 | param_1[-2] - param_2[-2];
}

/* ---- i24_cmp  @0x6AF1  (20 bytes)
 *      @R0 - @R1 -> C (and zero test) */
uint8_t i24_cmp(char *param_1,char *param_2)

{
  uint8_t bVar1;
  
  bVar1 = param_2[-1] - ((((uint8_t)param_1[-2] < (uint8_t)param_2[-2]) << 7) >> 7);
  return *param_1 - (*param_2 - ((((uint8_t)param_1[-1] < bVar1) << 7) >> 7)) |
         param_1[-1] - bVar1 | param_1[-2] - param_2[-2];
}

/* ---- i24_copy_r1_to_r0  @0x6B05  (18 bytes) */
uint8_t i24_copy_r1_to_r0(uint8_t param_1,uint8_t *param_2,uint8_t *param_3)

{
  uint8_t uVar1;
  uint8_t uVar2;
  uint8_t *puVar3;
  
  uVar1 = *param_3;
  *param_3 = param_1;
  *param_2 = uVar1;
  uVar2 = *param_3;
  *param_3 = uVar1;
  puVar3 = param_3 + -1;
  uVar1 = *puVar3;
  *puVar3 = uVar2;
  param_2[-1] = uVar1;
  uVar2 = *puVar3;
  *puVar3 = uVar1;
  param_3 = param_3 + -2;
  uVar1 = *param_3;
  *param_3 = uVar2;
  param_2[-2] = uVar1;
  uVar2 = *param_3;
  *param_3 = uVar1;
  return uVar2;
}

/* ---- i24_ld_code_r0  @0x6B17  (15 bytes) */
void i24_ld_code_r0(char *param_1,char *param_2)

{
  char cVar1;
  
  cVar1 = '\x03';
  do {
    *param_2 = cVar1;
    cVar1 = *param_2;
    *param_2 = *param_1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- i24_ld_code_r1  @0x6B26  (15 bytes) */
void i24_ld_code_r1(char *param_1,char *param_2)

{
  char cVar1;
  
  cVar1 = '\x03';
  do {
    *param_2 = cVar1;
    cVar1 = *param_2;
    *param_2 = *param_1;
    param_2 = param_2 + -1;
    param_1 = param_1 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- i24_ld_max_r0  @0x6BC3  (11 bytes) */
void i24_ld_max_r0(uint8_t *param_1)

{
  *param_1 = 0x7f;
  param_1[-1] = 0xff;
  param_1[-2] = 0xff;
  return;
}

/* ---- i24_st_r0_xdata  @0x6BCE  (13 bytes) */
void i24_st_r0_xdata(uint8_t *param_1,uint8_t *param_2)

{
  *param_1 = *param_2;
  param_1[1] = param_2[-1];
  param_1[2] = param_2[-2];
  return;
}

/* ---- i24_st_r1_xdata  @0x6BDB  (13 bytes) */
void i24_st_r1_xdata(uint8_t *param_1,uint8_t *param_2)

{
  *param_1 = *param_2;
  param_1[1] = param_2[-1];
  param_1[2] = param_2[-2];
  return;
}

/* ---- i24_ld_xdata_r0  @0x6BE8  (13 bytes) */
void i24_ld_xdata_r0(uint8_t *param_1,uint8_t *param_2)

{
  *param_2 = *param_1;
  param_2[-1] = param_1[1];
  param_2[-2] = param_1[2];
  return;
}

/* ---- i24_ld_xdata_r1  @0x6BF5  (13 bytes) */
void i24_ld_xdata_r1(uint8_t *param_1,uint8_t *param_2)

{
  *param_2 = *param_1;
  param_2[-1] = param_1[1];
  param_2[-2] = param_1[2];
  return;
}

/* ---- mant_mul24  @0x6C02  (82 bytes)
 *      24x24 mantissa multiply (used by fp_mul) */
uint8_t mant_mul24(char param_1,uint8_t *param_2)

{
  bool bVar1;
  uint8_t *pbVar2;
  uint8_t *pbVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  uint8_t bVar6;
  uint8_t bVar7;
  uint8_t bVar8;
  uint8_t bVar9;
  
  bVar5 = 0;
  bVar6 = 0;
  bVar7 = 0;
  pbVar2 = (uint8_t *)(param_1 + -2);
  bVar4 = 0xc0;
  do {
    pbVar3 = pbVar2;
    bVar8 = (uint8_t)((uint16_t)*pbVar3 * (uint16_t)param_2[-2]);
    bVar9 = bVar8 + bVar5;
    bVar5 = (char)((uint16_t)*pbVar3 * (uint16_t)param_2[-2] >> 8) - ((CARRY1(bVar8,bVar5) << 7) >> 7);
    bVar8 = bVar6 + bVar5;
    if ((CARRY1(bVar6,bVar5)) && (bVar7 = bVar7 + 1, bVar7 == 0)) {
      bVar4 = bVar4 + 1;
    }
    bVar6 = (uint8_t)((uint16_t)*pbVar3 * (uint16_t)param_2[-1]);
    bVar5 = bVar6 + bVar8;
    bVar6 = (char)((uint16_t)*pbVar3 * (uint16_t)param_2[-1] >> 8) - ((CARRY1(bVar6,bVar8) << 7) >> 7);
    bVar8 = bVar7 + bVar6;
    if (CARRY1(bVar7,bVar6)) {
      bVar4 = bVar4 + 1;
    }
    bVar7 = (uint8_t)((uint16_t)*pbVar3 * (uint16_t)*param_2);
    bVar6 = bVar7 + bVar8;
    bVar8 = (char)((uint16_t)*pbVar3 * (uint16_t)*param_2 >> 8) - ((CARRY1(bVar7,bVar8) << 7) >> 7);
    bVar7 = (bVar4 & 0xf) + bVar8;
    *pbVar3 = bVar9;
    bVar1 = (char)bVar4 < '\0';
    pbVar2 = pbVar3 + '\x01';
    bVar4 = (bVar4 & 0xf0) << 1 | CARRY1(bVar4 & 0xf,bVar8);
  } while (bVar1);
  *pbVar3 = bVar7;
  pbVar3[-1] = bVar6;
  pbVar3[-2] = bVar5;
  return bVar7 | bVar6 | bVar5;
}

/* ---- i24_div10_rem  @0x6C54  (30 bytes)
 *      remainder in A (used by put_digit) */
char i24_div10_rem(uint8_t *param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  short sVar4;
  uint8_t *pbVar5;
  uint8_t bVar6;
  uint8_t bVar7;
  
  pbVar5 = param_1 + -1;
  sVar4 = (uint16_t)param_1[-2] * (uint16_t)*param_2;
  param_1[-2] = (uint8_t)sVar4;
  bVar1 = *pbVar5;
  *pbVar5 = (uint8_t)((uint16_t)sVar4 >> 8);
  bVar2 = *param_2;
  bVar6 = (uint8_t)((uint16_t)bVar1 * (uint16_t)bVar2);
  bVar7 = *pbVar5;
  *pbVar5 = bVar6 + *pbVar5;
  bVar3 = *param_1;
  *param_1 = (char)((uint16_t)bVar1 * (uint16_t)bVar2 >> 8) - ((CARRY1(bVar6,bVar7) << 7) >> 7);
  bVar1 = *param_2;
  bVar7 = (uint8_t)((uint16_t)bVar3 * (uint16_t)bVar1);
  bVar2 = *param_1;
  *param_1 = bVar7 + *param_1;
  return (char)((uint16_t)bVar3 * (uint16_t)bVar1 >> 8) - ((CARRY1(bVar7,bVar2) << 7) >> 7);
}

/* ---- clc_thunk  @0x6C72  (1 bytes) */
uint8_t clc_thunk(uint8_t param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  uint8_t *pbVar5;
  
  pbVar4 = param_2 + -1;
  pbVar5 = param_2 + -2;
  bVar1 = *pbVar5;
  *pbVar5 = param_1;
  bVar2 = *pbVar5;
  *pbVar5 = bVar1 << 1;
  bVar3 = *pbVar4;
  *pbVar4 = bVar2;
  bVar2 = *pbVar4;
  *pbVar4 = bVar3 << 1 | bVar1 >> 7;
  bVar1 = *param_2;
  *param_2 = bVar2;
  bVar2 = *param_2;
  *param_2 = bVar1 << 1 | bVar3 >> 7;
  return bVar2;
}

/* ---- i24_shl1  @0x6C73  (14 bytes)
 *      verified 1000 -> 2000 */
uint8_t i24_shl1(uint8_t param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  uint8_t *pbVar5;
  uint8_t in_PSW;
  
  pbVar4 = param_2 + -1;
  pbVar5 = param_2 + -2;
  bVar1 = *pbVar5;
  *pbVar5 = param_1;
  bVar2 = *pbVar5;
  *pbVar5 = bVar1 << 1 | in_PSW >> 7;
  bVar3 = *pbVar4;
  *pbVar4 = bVar2;
  bVar2 = *pbVar4;
  *pbVar4 = bVar3 << 1 | bVar1 >> 7;
  bVar1 = *param_2;
  *param_2 = bVar2;
  bVar2 = *param_2;
  *param_2 = bVar1 << 1 | bVar3 >> 7;
  return bVar2;
}

/* ---- i24_sar1  @0x6C81  (5 bytes) */
uint8_t i24_sar1(uint8_t param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  
  bVar1 = *param_2;
  *param_2 = param_1;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1 | bVar1 & 0x80;
  pbVar4 = param_2 + -1;
  bVar3 = *pbVar4;
  *pbVar4 = bVar2;
  bVar2 = *pbVar4;
  *pbVar4 = bVar3 >> 1 | bVar1 << 7;
  param_2 = param_2 + -2;
  bVar1 = *param_2;
  *param_2 = bVar2;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1 | bVar3 << 7;
  return bVar2;
}

/* ---- i24_shr1  @0x6C86  (1 bytes) */
uint8_t i24_shr1(uint8_t param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  
  bVar1 = *param_2;
  *param_2 = param_1;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1;
  pbVar4 = param_2 + -1;
  bVar3 = *pbVar4;
  *pbVar4 = bVar2;
  bVar2 = *pbVar4;
  *pbVar4 = bVar3 >> 1 | bVar1 << 7;
  param_2 = param_2 + -2;
  bVar1 = *param_2;
  *param_2 = bVar2;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1 | bVar3 << 7;
  return bVar2;
}

/* ---- i24_rrc  @0x6C87  (14 bytes) */
uint8_t i24_rrc(uint8_t param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  uint8_t in_PSW;
  
  bVar1 = *param_2;
  *param_2 = param_1;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1 | in_PSW & 0x80;
  pbVar4 = param_2 + -1;
  bVar3 = *pbVar4;
  *pbVar4 = bVar2;
  bVar2 = *pbVar4;
  *pbVar4 = bVar3 >> 1 | bVar1 << 7;
  param_2 = param_2 + -2;
  bVar1 = *param_2;
  *param_2 = bVar2;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1 | bVar3 << 7;
  return bVar2;
}

/* ---- i24_shr1_r1  @0x6C9A  (15 bytes) */
uint8_t i24_shr1_r1(uint8_t param_1,uint8_t *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  
  bVar1 = *param_2;
  *param_2 = param_1;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1;
  pbVar4 = param_2 + -1;
  bVar3 = *pbVar4;
  *pbVar4 = bVar2;
  bVar2 = *pbVar4;
  *pbVar4 = bVar3 >> 1 | bVar1 << 7;
  param_2 = param_2 + -2;
  bVar1 = *param_2;
  *param_2 = bVar2;
  bVar2 = *param_2;
  *param_2 = bVar1 >> 1 | bVar3 << 7;
  return bVar2;
}

/* ---- i24_sub  @0x6CA9  (1 bytes)
 *      verified 1000 - 7 */
uint8_t i24_sub(uint8_t *param_1,char *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  uint8_t bVar5;
  
  pbVar4 = param_1 + -1;
  bVar1 = param_1[-2];
  bVar2 = param_2[-2];
  bVar5 = bVar1 - bVar2;
  param_1[-2] = bVar5;
  bVar3 = *pbVar4;
  *pbVar4 = bVar5;
  bVar5 = param_2[-1] - (((bVar1 < bVar2) << 7) >> 7);
  bVar1 = *pbVar4;
  *pbVar4 = bVar3 - bVar5;
  bVar2 = *param_1;
  *param_1 = bVar1 | *pbVar4;
  bVar1 = *param_1;
  *param_1 = bVar2 - (*param_2 - (((bVar3 < bVar5) << 7) >> 7));
  return bVar1 | *param_1;
}

/* ---- i24_sub_core  @0x6CAA  (20 bytes) */
uint8_t i24_sub_core(uint8_t *param_1,char *param_2)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  uint8_t *pbVar4;
  uint8_t bVar5;
  char in_PSW;
  
  pbVar4 = param_1 + -1;
  bVar1 = param_1[-2];
  bVar3 = param_2[-2] - (in_PSW >> 7);
  bVar5 = bVar1 - bVar3;
  param_1[-2] = bVar5;
  bVar2 = *pbVar4;
  *pbVar4 = bVar5;
  bVar5 = param_2[-1] - (((bVar1 < bVar3) << 7) >> 7);
  bVar1 = *pbVar4;
  *pbVar4 = bVar2 - bVar5;
  bVar3 = *param_1;
  *param_1 = bVar1 | *pbVar4;
  bVar1 = *param_1;
  *param_1 = bVar3 - (*param_2 - (((bVar2 < bVar5) << 7) >> 7));
  return bVar1 | *param_1;
}

/* ---- i24_test_r0  @0x6CBE  (8 bytes)
 *      A = OR of bytes (Z if zero) */
uint8_t i24_test_r0(uint8_t *param_1)

{
  return param_1[-2] | param_1[-1] | *param_1;
}

/* ---- i24_test_r1  @0x6CC6  (8 bytes) */
uint8_t i24_test_r1(uint8_t *param_1)

{
  return param_1[-2] | param_1[-1] | *param_1;
}

/* ---- i24_dec_r0  @0x6CCE  (22 bytes) */
void i24_dec_r0(char *param_1)

{
  char *pcVar1;
  char *pcVar2;
  
  pcVar1 = param_1 + -1;
  pcVar2 = param_1 + -2;
  *pcVar2 = *pcVar2 + -1;
  if (((*pcVar2 == -1) && (*pcVar1 = *pcVar1 + -1, *pcVar1 == -1)) &&
     (*param_1 = *param_1 + -1, *param_1 == -1)) {
    return;
  }
  return;
}

/* ---- i24_dec_r1  @0x6CE4  (22 bytes) */
void i24_dec_r1(char *param_1)

{
  char *pcVar1;
  char *pcVar2;
  
  pcVar1 = param_1 + -1;
  pcVar2 = param_1 + -2;
  *pcVar2 = *pcVar2 + -1;
  if (((*pcVar2 == -1) && (*pcVar1 = *pcVar1 + -1, *pcVar1 == -1)) &&
     (*param_1 = *param_1 + -1, *param_1 == -1)) {
    return;
  }
  return;
}

/* ---- i24_inc_r0  @0x6CFA  (18 bytes) */
void i24_inc_r0(char *param_1)

{
  char *pcVar1;
  char *pcVar2;
  
  pcVar1 = param_1 + -1;
  pcVar2 = param_1 + -2;
  *pcVar2 = *pcVar2 + '\x01';
  if (((*pcVar2 == '\0') && (*pcVar1 = *pcVar1 + '\x01', *pcVar1 == '\0')) &&
     (*param_1 = *param_1 + '\x01', *param_1 == '\0')) {
    return;
  }
  return;
}

/* ---- i24_inc_r1  @0x6D0C  (18 bytes) */
void i24_inc_r1(char *param_1)

{
  char *pcVar1;
  char *pcVar2;
  
  pcVar1 = param_1 + -1;
  pcVar2 = param_1 + -2;
  *pcVar2 = *pcVar2 + '\x01';
  if (((*pcVar2 == '\0') && (*pcVar1 = *pcVar1 + '\x01', *pcVar1 == '\0')) &&
     (*param_1 = *param_1 + '\x01', *param_1 == '\0')) {
    return;
  }
  return;
}

/* ---- add16_r6r7_r4r5  @0x6D71  (7 bytes) */
char add16_r6r7_r4r5(char param_1,uint8_t param_2,char param_3,uint8_t param_4)

{
  return param_1 + (param_3 - ((CARRY1(param_2,param_4) << 7) >> 7));
}

/* ---- shl16_r6r7  @0x6D98  (19 bytes) */
uint8_t shl16_r6r7(char param_1,uint8_t param_2,uint8_t param_3)

{
  uint8_t bVar1;
  
  bVar1 = 0;
  if (param_1 != '\0') {
    do {
      param_2 = param_2 << 1 | param_3 >> 7;
      param_1 = param_1 + -1;
      param_3 = param_3 << 1;
      bVar1 = param_2;
    } while (param_1 != '\0');
  }
  return bVar1;
}

