/* calibration.c - calibration storage (3 copies), recipes, coefficients, calibration run
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 78 functions, 4607 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/calibration.c.
 */
#include "pm2525.h"

/* ---- cal_load_range  @0x0111  (680 bytes)
 *      verify/repair 3 copies, evaluate recipe of current range into cal_work_set0/1 */
void cal_load_range(void)

{
  uint8_t *pbVar1;
  uint8_t *puVar2;
  uint16_t uVar3;
  
  cal_ctx_save();
  bit_23_7 = '\0';
  if (bit_23_4 == '\0') {
    bit_27_4 = 0;
    ram_5D = '\0';
    cal_checksum_copy1(0xff);
    cal_checksum_copy2();
    cal_checksum_copy3();
    if (ram_5D != '\0') {
      if (ram_5D == '\x01') {
        cal_copy2_to_1();
        cnt_sum_err_copy1();
      }
      else if (ram_5D == '\x02') {
        cal_copy1_to_2();
        cnt_sum_err_copy2();
      }
      else if (ram_5D == '\x04') {
        cal_copy1_to_3();
        cnt_sum_err_copy3();
      }
      else if (ram_5D == '\x03') {
        cal_copy3_to_2();
        cal_copy2_to_1();
        cnt_sum_err_copy2();
        cnt_sum_err_copy1();
      }
      else if (ram_5D == '\x05') {
        cal_copy2_to_1();
        cal_copy1_to_3();
        cnt_sum_err_copy1();
        cnt_sum_err_copy3();
      }
      else if (ram_5D == '\x06') {
        cal_copy1_to_2();
        cal_copy1_to_3();
        cnt_sum_err_copy2();
        cnt_sum_err_copy3();
      }
      else {
        bit_27_4 = 1;
        cal_majority_repair();
      }
    }
    cal_nominal_value();
    pbVar1 = &ram_47;
    if (((meter_state & 0xc) == 0) && (bit_20_6 != '\0')) {
      ram_4B = ram_4B + '\x01';
    }
    fp_ld_code_r0(0x6f69);
    fp_mul();
    fp_st_r0_xdata(0x782);
    *pbVar1 = *pbVar1 ^ 0x80;
    fp_st_r0_xdata(0x786);
    fp_ld_code_r0(0x6f71);
    fp_mul();
    fp_st_r0_xdata(cal_next_ptr);
    *pbVar1 = *pbVar1 ^ 0x80;
    fp_st_r0_xdata(0x78e);
    cal_set_slope_limits();
    puVar2 = (uint8_t *)0x770;
    cal_fallback_flags = 0;
    cal_recipe_ptr();
    bit_2B_3 = (uint8_t)puVar2[2] >> 7;
    F0 = bit_2B_3;
    ram_5C = *puVar2;
    ram_5B = puVar2[1];
    cal_lim_lo_from_xdata(0x782);
    cal_lim_hi_from_xdata(0x786);
    F0 = bit_2B_3 & 1;
    cal_eval_field(0,CONCAT11(ram_5C,ram_5B));
    if (bit_23_7 == '\0') {
      fp_st_r0_xdata(0x15f,0x43);
      if ((char)(bit_2B_3 << 7) < '\0') {
        fp_st_r0_xdata(0x17f,0x47);
      }
      uVar3 = 0x6f99;
      if ((meter_state & 0x7f) == 0x65) {
        uVar3 = 0x70b9;
      }
      cal_lim_lo_from_rom(uVar3);
      uVar3 = 0x6f7d;
      if ((meter_state & 0x7f) == 0x65) {
        uVar3 = 0x6f79;
      }
      cal_lim_hi_from_rom(uVar3);
      F0 = bit_2B_3 & 1;
      cal_eval_field(1,CONCAT11(ram_5C,ram_5B));
      if (bit_23_7 == '\0') {
        fp_st_r0_xdata(0x163,0x43);
        if ((char)(bit_2B_3 << 7) < '\0') {
          fp_st_r0_xdata(0x183,0x47);
        }
        cal_lim_lo_from_rom(0x70c1);
        cal_lim_hi_from_rom(0x70bd);
        F0 = bit_2B_3 & 1;
        cal_eval_field(2,CONCAT11(ram_5C,ram_5B));
        if (bit_23_7 == '\0') {
          fp_st_r0_xdata(0x167,0x43);
          if ((char)(bit_2B_3 << 7) < '\0') {
            fp_st_r0_xdata(0x187,0x47);
          }
          cal_lim_lo_from_rom(0x70c1);
          cal_lim_hi_from_rom(0x70bd);
          F0 = bit_2B_3 & 1;
          cal_eval_field(3,CONCAT11(ram_5C,ram_5B));
          if (bit_23_7 == '\0') {
            fp_st_r0_xdata(0x16b,0x43);
            if ((char)(bit_2B_3 << 7) < '\0') {
              fp_st_r0_xdata(0x18b,0x47);
            }
            cal_lim_lo_from_xdata(cal_next_ptr);
            cal_lim_hi_from_xdata(0x78e);
            F0 = bit_2B_3 & 1;
            cal_eval_field(4,CONCAT11(ram_5C,ram_5B));
            if (bit_23_7 == '\0') {
              fp_st_r0_xdata(0x16f,0x43);
              if ((char)(bit_2B_3 << 7) < '\0') {
                fp_st_r0_xdata(399,0x47);
              }
              cal_lim_lo_from_xdata(0x792);
              cal_lim_hi_from_xdata(0x796);
              F0 = bit_2B_3 & 1;
              cal_eval_field(5,CONCAT11(ram_5C,ram_5B));
              if (bit_23_7 == '\0') {
                fp_st_r0_xdata(0x173,0x43);
                if ((char)(bit_2B_3 << 7) < '\0') {
                  fp_st_r0_xdata(0x193,0x47);
                }
                goto LAB_CODE_0343;
              }
            }
          }
        }
      }
    }
  }
  fp_ld_code_r0(0x6f59,0x43,0x4b);
  fp_st_r0_xdata(0x15f);
  fp_st_r0_xdata(0x17f);
  fp_ld_code_r0(0x6927);
  fp_st_r0_xdata(0x163);
  fp_st_r0_xdata(0x183);
  fp_ld_code_r0(0x6f71);
  fp_st_r0_xdata(0x167);
  fp_st_r0_xdata(0x187);
  fp_ld_code_r0(0x6f71);
  fp_st_r0_xdata(0x16b);
  fp_st_r0_xdata(0x18b);
  fp_ld_code_r0(0x6f59);
  fp_st_r0_xdata(0x16f);
  fp_st_r0_xdata(399);
  fp_ld_code_r0(0x6f59);
  fp_st_r0_xdata(0x173);
  fp_st_r0_xdata(0x193);
LAB_CODE_0343:
  cal_ctx_restore();
  return;
}

/* ---- cal_lim_lo_from_xdata  @0x03B9  (9 bytes) */
void cal_lim_lo_from_xdata(void)

{
  fp_ld_xdata_r1();
  fp_st_r1_xdata(0x79a);
  return;
}

/* ---- cal_lim_hi_from_xdata  @0x03C2  (9 bytes) */
void cal_lim_hi_from_xdata(void)

{
  fp_ld_xdata_r1();
  fp_st_r1_xdata(0x79e);
  return;
}

/* ---- cal_lim_lo_from_rom  @0x03CB  (9 bytes) */
void cal_lim_lo_from_rom(void)

{
  fp_ld_code_r1();
  fp_st_r1_xdata(0x79a);
  return;
}

/* ---- cal_lim_hi_from_rom  @0x03D4  (9 bytes)
 *      limits for the coefficient checks at XDATA 0x079A/0x079E */
void cal_lim_hi_from_rom(void)

{
  fp_ld_code_r1();
  fp_st_r1_xdata(0x79e);
  return;
}

/* ---- cal_eval_field  @0x03DD  (118 bytes)
 *      evaluate one coefficient (mode 0-5) for all records of the recipe */
void cal_eval_field(char param_1,short param_2)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t uVar3;
  
  ram_3F = ram_2E;
  ram_5E = ram_2F;
  ram_5A = 0;
  uVar3 = 0x43;
  ram_52 = (uint8_t)param_2;
  ram_53 = (uint8_t)((uint16_t)param_2 >> 8);
  ram_51 = param_1;
  while( true ) {
    ram_2E = *(uint8_t *)(param_2 + (uint16_t)ram_5A);
    ram_2F = *(uint8_t *)(param_2 + (uint16_t)(ram_5A + 1));
    cal_record_layout(uVar3);
    bVar1 = F0;
    bit_2D_2 = bVar1 & 1;
    if (ram_51 == '\0') {
      cal_f_zero();
    }
    else if (ram_51 == '\x01') {
      cal_f_gain();
    }
    else if (ram_51 == '\x02') {
      cal_f_zero_tref();
    }
    else if (ram_51 == '\x03') {
      cal_f_gain_tref();
    }
    else if (ram_51 == '\x04') {
      cal_f_zero_tslope();
    }
    else {
      if (ram_51 != '\x05') {
        do {
                    /* WARNING: Do nothing block with infinite loop */
        } while( true );
      }
      cal_f_gain_tslope();
    }
    param_2 = CONCAT11(ram_53,ram_52);
    F0 = bit_2D_2 & 1;
    cVar2 = F0;
    if (cVar2 == '\0') break;
    F0 = 0;
    uVar3 = 0x47;
  }
  ram_2E = ram_3F;
  ram_2F = ram_5E;
  return;
}

/* ---- cal_f_zero  @0x0453  (67 bytes)
 *      mode 0: K0 = product of A pointers (default 0) */
void cal_f_zero(void)

{
  bool bVar1;
  char in_PSW;
  
  cal_next_ptr(0x54);
  if (bit_2E_1 == '\x01') {
    fp_ld_code_r0();
  }
  else {
    cal_ld_slot();
    if (bit_23_7 == '\x01') goto LAB_CODE_047f;
  }
  if (bit_2E_0 != '\0') {
    cal_next_ptr(0x54);
    cal_ld_slot_r1();
    if (bit_23_7 == '\x01') goto LAB_CODE_047f;
    fp_mul();
  }
  if ((bit_23_7 != '\x01') && (cal_check_limits_r1(), -1 < in_PSW)) {
    return;
  }
LAB_CODE_047f:
  bVar1 = cal_mode == '\0';
  if (!bVar1) {
    fp_ld_code_r0(0x6f59);
    cal_fallback_flags = cal_fallback_flags | 2;
  }
  bit_23_7 = bVar1;
  return;
}

/* ---- cal_f_gain  @0x0496  (133 bytes)
 *      mode 1: K1 = B0 * B1.. / Bn (h0>>6 multiplies) (default 1) */
void cal_f_gain(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  char cVar3;
  char in_PSW;
  char cVar4;
  
  cal_next_ptr(0x55);
  if (bit_2E_2 == '\x01') {
    fp_ld_code_r0();
  }
  else {
    cal_ld_slot();
    if ((bit_23_7 == '\x01') || (cal_check_limits_r1(), in_PSW < '\0')) goto LAB_CODE_0504;
  }
  bVar1 = ram_2E >> 3 & 7;
  bVar2 = ram_2E >> 6;
  cVar4 = (bVar1 < bVar2) << 7;
  ram_3E = (bVar1 - bVar2) + -1;
  while (bVar2 != 0) {
    ram_3D = bVar2;
    cal_next_ptr(0x55);
    cal_ld_slot_r1();
    if ((bit_23_7 == '\x01') || (cal_check_limits_r0(), cVar4 < '\0')) goto LAB_CODE_0504;
    fp_mul();
    bVar2 = ram_3D - 1;
  }
  cVar3 = ram_3E;
  while( true ) {
    if (cVar3 == '\0') {
      return;
    }
    cal_next_ptr(0x55);
    cal_ld_slot_r1();
    if ((bit_23_7 == '\x01') || (cal_check_limits_r0(), cVar4 < '\0')) break;
    fp_div();
    cVar3 = cVar3 + -1;
  }
LAB_CODE_0504:
  if (cal_mode == '\0') {
    bit_23_7 = 1;
    return;
  }
  fp_ld_code_r0(0x6927);
  cal_fallback_flags = cal_fallback_flags | 4;
  bit_23_7 = 0;
  return;
}

/* ---- cal_f_zero_tref  @0x051B  (50 bytes)
 *      mode 2: K2 = X (default 0.5) */
void cal_f_zero_tref(void)

{
  bool bVar1;
  char in_PSW;
  
  cal_next_ptr(0x56);
  if (bit_2F_0 == '\x01') {
    fp_ld_code_r0();
  }
  else {
    cal_ld_slot();
    if (bit_23_7 == '\x01') goto LAB_CODE_0536;
  }
  if ((bit_23_7 != '\x01') && (cal_check_limits_r1(), -1 < in_PSW)) {
    return;
  }
LAB_CODE_0536:
  bVar1 = cal_mode == '\0';
  if (!bVar1) {
    fp_ld_code_r0(0x6f71);
    cal_fallback_flags = cal_fallback_flags | 8;
  }
  bit_23_7 = bVar1;
  return;
}

/* ---- cal_f_gain_tref  @0x054D  (50 bytes)
 *      mode 3: K3 = C0 (default 0.5) */
void cal_f_gain_tref(void)

{
  bool bVar1;
  char in_PSW;
  
  cal_next_ptr(0x57);
  if (bit_2F_1 == '\x01') {
    fp_ld_code_r0();
  }
  else {
    cal_ld_slot();
    if (bit_23_7 == '\x01') goto LAB_CODE_0568;
  }
  if ((bit_23_7 != '\x01') && (cal_check_limits_r1(), -1 < in_PSW)) {
    return;
  }
LAB_CODE_0568:
  bVar1 = cal_mode == '\0';
  if (!bVar1) {
    fp_ld_code_r0(0x6f71);
    cal_fallback_flags = cal_fallback_flags | 0x10;
  }
  bit_23_7 = bVar1;
  return;
}

/* ---- cal_f_zero_tslope  @0x057F  (67 bytes)
 *      mode 4: K4 = product of C1.. (default 0) */
void cal_f_zero_tslope(void)

{
  bool bVar1;
  char in_PSW;
  
  cal_next_ptr(0x58);
  if (bit_2E_1 == '\x01') {
    fp_ld_code_r0();
  }
  else {
    cal_ld_slot();
    if (bit_23_7 == '\x01') goto LAB_CODE_05ab;
  }
  if (bit_2E_0 != '\0') {
    cal_next_ptr(0x58);
    cal_ld_slot_r1();
    if (bit_23_7 == '\x01') goto LAB_CODE_05ab;
    fp_mul();
  }
  if ((bit_23_7 != '\x01') && (cal_check_limits_r1(), -1 < in_PSW)) {
    return;
  }
LAB_CODE_05ab:
  bVar1 = cal_mode == '\0';
  if (!bVar1) {
    fp_ld_code_r0(0x6f59);
    cal_fallback_flags = cal_fallback_flags | 0x20;
  }
  bit_23_7 = bVar1;
  return;
}

/* ---- cal_f_gain_tslope  @0x05C2  (128 bytes)
 *      mode 5: K5 = from D (default 0) */
void cal_f_gain_tslope(void)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar3;
  char in_PSW;
  char cVar4;
  
  cal_next_ptr(0x59);
  if (bit_2F_2 == '\x01') {
    fp_ld_code_r0();
  }
  else {
    cal_ld_slot();
    if ((bit_23_7 == '\x01') || (cal_check_limits_r1(), in_PSW < '\0')) goto LAB_CODE_062b;
  }
  bVar1 = ram_2F >> 3 & 7;
  bVar3 = ram_2F >> 6;
  cVar4 = (bVar1 < bVar3) << 7;
  cVar2 = (bVar1 - bVar3) + -1;
  while (bVar3 != 0) {
    ram_3D = bVar3;
    cal_next_ptr(0x59);
    cal_ld_slot_r1();
    if ((bit_23_7 == '\x01') || (cal_check_limits_r0(), cVar4 < '\0')) goto LAB_CODE_062b;
    fp_sub();
    bVar3 = ram_3D - 1;
  }
  while( true ) {
    if (cVar2 == '\0') {
      return;
    }
    cal_next_ptr(0x59);
    cal_ld_slot_r1();
    cal_check_limits_r0();
    if (cVar4 < '\0') break;
    fp_add();
    cVar2 = cVar2 + -1;
  }
LAB_CODE_062b:
  if (cal_mode == '\0') {
    bit_23_7 = 1;
    return;
  }
  fp_ld_code_r0(0x6f59);
  cal_fallback_flags = cal_fallback_flags | 0x40;
  bit_23_7 = 0;
  return;
}

/* ---- cal_adjust_slot  @0x0642  (174 bytes)
 *      calibration run: writes a newly measured value into the recipe's slot (mode 0-5) */
void cal_adjust_slot(char param_1,short *param_2)

{
  char cVar1;
  uint8_t uVar2;
  short sVar3;
  
  cal_ctx_save();
  fp_copy_r0_to_r1(0x43);
  ram_3F = ram_2E;
  ram_5E = ram_2F;
  F0 = bit_2F_7 & 1;
  ram_51 = param_1;
  cal_recipe_ptr(0x43);
  ram_53 = *(uint8_t *)param_2;
  ram_52 = (uint8_t)*param_2;
  sVar3 = *param_2;
  ram_5A = 0;
  while( true ) {
    ram_2E = *(uint8_t *)(sVar3 + (uint16_t)ram_5A);
    ram_2F = *(uint8_t *)(sVar3 + (uint16_t)(ram_5A + 1));
    cal_record_layout();
    cVar1 = F0;
    if (cVar1 == '\0') break;
    F0 = 0;
  }
  if (ram_51 == '\0') {
    do {
    } while (bit_2E_1 == '\x01');
    do {
    } while (bit_2E_0 == '\x01');
    uVar2 = 0x54;
    goto LAB_CODE_069c;
  }
  if (ram_51 != '\x01') {
    if (ram_51 == '\x02') {
      do {
      } while (bit_2F_0 == '\x01');
      uVar2 = 0x56;
      goto LAB_CODE_069c;
    }
    if (ram_51 == '\x03') {
      do {
      } while (bit_2F_1 == '\x01');
      uVar2 = 0x57;
      goto LAB_CODE_069c;
    }
    if (ram_51 == '\x04') {
      do {
      } while (bit_2E_1 == '\x01');
      do {
      } while (bit_2E_0 == '\x01');
      uVar2 = 0x58;
      goto LAB_CODE_069c;
    }
    if (ram_51 != '\x05') {
      do {
                    /* WARNING: Do nothing block with infinite loop */
      } while( true );
    }
    if (bit_2F_2 != '\x01') {
      if ((ram_2F & 0x38) != 8) {
        do {
                    /* WARNING: Do nothing block with infinite loop */
        } while( true );
      }
      uVar2 = 0x59;
      goto LAB_CODE_069c;
    }
  }
  do {
  } while (bit_2E_2 == '\x01');
  if ((ram_2E & 0x38) != 8) {
    do {
                    /* WARNING: Do nothing block with infinite loop */
    } while( true );
  }
  uVar2 = 0x55;
LAB_CODE_069c:
  cal_next_ptr(uVar2);
  cal_write_all_copies();
  ram_2E = ram_3F;
  ram_2F = ram_5E;
  cal_ctx_restore();
  return;
}

/* ---- cal_recipe_ptr  @0x06F0  (72 bytes)
 *      DPTR = cal_recipe_table + cal_recipe_offsets[function] + range*4 (current, 25h.6: range+2) */
char cal_recipe_ptr(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  
  if ((((meter_state & 0xf) == 6) || ((meter_state & 0xf) == 7)) && (bit_25_6 != '\0')) {
    bVar2 = ((meter_state & 0x70) >> 4) + 2;
  }
  else {
    bVar2 = (meter_state & 0x70) >> 4;
  }
  bVar1 = (meter_state & 0xf) * '\x02';
  return ((&cal_recipe_offsets)[bVar1] -
         ((CARRY1((&cal_recipe_offsets)[bVar1 + 1],bVar2 * '\x04') << 7) >> 7)) +
         ('v' - (((0x5d < (&cal_recipe_offsets)[bVar1 + 1] + bVar2 * '\x04') << 7) >> 7));
}

/* ---- cal_record_layout  @0x0754  (54 bytes)
 *      field offsets of one record from header bytes h0 (2Eh), h1 (2Fh) */
void cal_record_layout(void)

{
  ram_54 = ram_5A + '\x02';
  ram_55 = ((ram_2E & 1) + 1) * '\x02' + ram_5A + '\x02';
  ram_56 = (ram_2E >> 2 & 0xe) + ram_55;
  ram_57 = ram_56 + '\x02';
  ram_58 = ram_56 + '\x04';
  ram_59 = (ram_56 + '\x02' + ram_55) - ram_5A;
  ram_5A = (ram_2F >> 2 & 0xe) + ram_59;
  return;
}

/* ---- cal_next_ptr  @0x078A  (23 bytes)
 *      fetch next 16-bit pointer of the current record field */
uint8_t cal_next_ptr(uint8_t *param_1)

{
  uint8_t bVar1;
  short sVar2;
  
  sVar2 = CONCAT11(ram_53,ram_52);
  bVar1 = *param_1;
  *param_1 = *param_1 + 1;
  *param_1 = *param_1 + 1;
  return *(uint8_t *)(sVar2 + (uint16_t)bVar1);
}

/* ---- cal_ld_slot  @0x07A4  (110 bytes)
 *      load a slot (XDATA) or ROM constant, with validity check */
void cal_ld_slot(char *param_1,char *param_2)

{
  char cVar1;
  char *pcVar2;
  
  cVar1 = '\x04';
  do {
    *param_2 = *param_1;
    pcVar2 = param_1;
    cal_addr_copy2();
    if (*pcVar2 == *param_2) {
      cal_addr_copy3();
      if (*pcVar2 != *param_2) {
        *pcVar2 = *param_2;
        if (bit_27_4 != '\x01') {
          cal_checksum_copy3();
        }
        cnt_repair_copy3();
      }
    }
    else {
      cal_addr_copy3();
      if (*pcVar2 == *param_2) {
        cal_addr_copy2();
        *pcVar2 = *param_2;
        if (bit_27_4 != '\x01') {
          cal_checksum_copy2();
        }
        cnt_repair_copy2();
      }
      else {
        cal_addr_copy2();
        *param_2 = *pcVar2;
        cal_addr_copy3();
        if (*pcVar2 == *param_2) {
          ret_peek_dptr();
          *pcVar2 = *param_2;
          if (bit_27_4 != '\x01') {
            cal_checksum_copy1();
          }
          cnt_repair_copy1();
        }
        else {
          bit_23_7 = 1;
          cVar1 = '\x01';
        }
      }
    }
    param_1 = param_1 + 1;
    param_2 = param_2 + -1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- cal_ld_slot_r1  @0x0812  (10 bytes) */
uint8_t cal_ld_slot_r1(uint8_t param_1,uint8_t param_2,uint8_t param_3)

{
  uint8_t uVar1;
  
  uVar1 = cal_ld_slot(param_1,param_3,param_2);
  return uVar1;
}

/* ---- cal_addr_copy2  @0x082D  (27 bytes)
 *      DPTR += 0x01CF */
char cal_addr_copy2(void)

{
  uint8_t uStackX_0;
  uint8_t in_stack_000000fd;
  char in_stack_000000fe;
  uint8_t in_stack_000000ff;
  
  R2 = uStackX_0;
  R3 = in_stack_000000ff;
  return in_stack_000000fe + ('\x01' - (((0x30 < in_stack_000000fd) << 7) >> 7));
}

/* ---- cal_addr_copy3  @0x0848  (27 bytes)
 *      DPTR += 0x039E */
char cal_addr_copy3(void)

{
  uint8_t uStackX_0;
  uint8_t in_stack_000000fd;
  char in_stack_000000fe;
  uint8_t in_stack_000000ff;
  
  R2 = uStackX_0;
  R3 = in_stack_000000ff;
  return in_stack_000000fe + ('\x03' - (((0x61 < in_stack_000000fd) << 7) >> 7));
}

/* ---- cal_write_all_copies_safe  @0x0863  (20 bytes) */
void cal_write_all_copies_safe(void)

{
  uint8_t uVar1;
  uint8_t uVar2;
  uint8_t uVar3;
  uint8_t uVar4;
  
  uVar4 = ram_3E;
  uVar3 = ram_3D;
  uVar2 = ram_3C;
  uVar1 = ram_3B;
  cal_write_all_copies();
  ram_3E = uVar4;
  ram_3D = uVar3;
  ram_3C = uVar2;
  ram_3B = uVar1;
  return;
}

/* ---- cal_write_all_copies  @0x0877  (52 bytes)
 *      write value to all three copies, refresh the three checksums */
void cal_write_all_copies(uint16_t param_1)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar3;
  
  bVar3 = (uint8_t)param_1;
  cVar2 = (char)((uint16_t)param_1 >> 8);
  cal_write_verify();
  cal_checksum_copy1(0);
  bVar1 = bVar3 - 0x31;
  cVar2 = cVar2 + ('\x01' - (((0x30 < bVar3) << 7) >> 7));
  cal_write_verify(cVar2,bVar1);
  cal_checksum_copy2(0);
  cal_write_verify(cVar2 + ('\x01' - (((0x30 < bVar1) << 7) >> 7)),bVar1 - 0x31);
  cal_checksum_copy3(0);
  return;
}

/* ---- cal_write_verify  @0x08AB  (52 bytes)
 *      write 4 bytes with read-back check */
void cal_write_verify(char *param_1,char *param_2)

{
  do {
    *param_1 = *param_2;
  } while (*param_1 != *param_2);
  do {
    param_1[1] = param_2[-1];
  } while (param_1[1] != param_2[-1]);
  do {
    param_1[2] = param_2[-2];
  } while (param_1[2] != param_2[-2]);
  do {
    param_1[3] = param_2[-3];
  } while (param_1[3] != param_2[-3]);
  return;
}

/* ---- cal_check_limits_r1  @0x08DF  (30 bytes) */
void cal_check_limits_r1(uint8_t param_1)

{
  char in_PSW;
  
  ram_3C = param_1;
  fp_ld_xdata_r1(0x79a,0x50);
  fp_cmp();
  if (in_PSW < '\0') {
    fp_ld_xdata_r1(0x79e);
    fp_cmp();
  }
  return;
}

/* ---- cal_check_limits_r0  @0x08FD  (30 bytes) */
void cal_check_limits_r0(uint8_t param_1)

{
  char in_PSW;
  
  ram_3B = param_1;
  fp_ld_xdata_r0(0x79a,0x50);
  fp_cmp();
  if (-1 < in_PSW) {
    fp_ld_xdata_r0(0x79e);
    fp_cmp();
  }
  return;
}

/* ---- cal_checksum_copy1  @0x091B  (58 bytes)
 *      B=0: store sum, else compare (sets 5Dh.0 on mismatch) */
void cal_checksum_copy1(uint16_t param_1,char param_2,uint8_t param_3,uint8_t param_4,
                       uint8_t param_5,uint8_t param_6)

{
  char cVar1;
  
  ram_3E = (uint8_t)((uint16_t)param_1 >> 8);
  ram_3D = (uint8_t)param_1;
  ram_3B = param_3;
  ram_3C = param_4;
  sum16_xdata(0x200,200,1);
  if (param_2 == '\0') {
    sum16_store();
  }
  else {
    cVar1 = sum16_compare(0x3c8);
    ram_51 = param_5;
    ram_52 = param_6;
    if (cVar1 != '\0') {
      ram_5D = ram_5D | 1;
    }
  }
  return;
}

/* ---- cal_checksum_copy2  @0x0955  (58 bytes) */
void cal_checksum_copy2(uint16_t param_1,char param_2,uint8_t param_3,uint8_t param_4,
                       uint8_t param_5,uint8_t param_6)

{
  char cVar1;
  
  ram_3E = (uint8_t)((uint16_t)param_1 >> 8);
  ram_3D = (uint8_t)param_1;
  ram_3B = param_3;
  ram_3C = param_4;
  sum16_xdata(0x3cf,200,1);
  if (param_2 == '\0') {
    sum16_store();
  }
  else {
    cVar1 = sum16_compare(0x597);
    ram_53 = param_5;
    ram_54 = param_6;
    if (cVar1 != '\0') {
      ram_5D = ram_5D | 2;
    }
  }
  return;
}

/* ---- cal_checksum_copy3  @0x098F  (58 bytes) */
void cal_checksum_copy3(uint16_t param_1,char param_2,uint8_t param_3,uint8_t param_4,
                       uint8_t param_5,uint8_t param_6)

{
  char cVar1;
  
  ram_3E = (uint8_t)((uint16_t)param_1 >> 8);
  ram_3D = (uint8_t)param_1;
  ram_3B = param_3;
  ram_3C = param_4;
  sum16_xdata(0x59e,200,1);
  if (param_2 == '\0') {
    sum16_store();
  }
  else {
    cVar1 = sum16_compare(0x766);
    ram_55 = param_5;
    ram_56 = param_6;
    if (cVar1 != '\0') {
      ram_5D = ram_5D | 4;
    }
  }
  return;
}

/* ---- sum16_store  @0x09C9  (6 bytes) */
void sum16_store(uint8_t *param_1,uint8_t param_2,uint8_t param_3)

{
  *param_1 = param_2;
  param_1[1] = param_3;
  return;
}

/* ---- sum16_compare  @0x09CF  (14 bytes) */
uint8_t sum16_compare(char *param_1)

{
  if ((*param_1 == R2) && (param_1[1] == R3)) {
    return 0;
  }
  return 0xff;
}

/* ---- sum16_xdata  @0x09DD  (19 bytes)
 *      16-bit additive sum of R1:R0 bytes at DPTR -> R3:R2 */
char sum16_xdata(uint8_t *param_1,char param_2,char param_3)

{
  bool bVar1;
  uint8_t bVar2;
  char cVar3;
  
  param_3 = param_3 + '\x01';
  bVar2 = 0;
  cVar3 = '\0';
  while( true ) {
    bVar1 = CARRY1(*param_1,bVar2);
    bVar2 = *param_1 + bVar2;
    cVar3 = cVar3 - ((bVar1 << 7) >> 7);
    param_2 = param_2 + -1;
    if ((param_2 == '\0') && (param_3 = param_3 + -1, param_3 == '\0')) break;
    param_1 = param_1 + 1;
  }
  return cVar3;
}

/* ---- cal_majority_repair  @0x09F0  (81 bytes)
 *      byte-wise 2-of-3 vote over the copies, repairs the odd one, counts events */
void cal_majority_repair(void)

{
  char cVar1;
  char cVar2;
  char cVar3;
  char *pcVar4;
  char *pcVar5;
  
  cVar2 = -0x38;
  cVar3 = '\x02';
  pcVar4 = &cal_data_copy1;
  do {
    cVar1 = *pcVar4;
    pcVar5 = pcVar4;
    cal_addr_copy2();
    if (*pcVar5 == cVar1) {
      cal_addr_copy3();
      if (*pcVar5 != cVar1) {
        *pcVar5 = cVar1;
        cnt_repair_copy3();
      }
    }
    else {
      cal_addr_copy3();
      if (*pcVar5 == cVar1) {
        cal_addr_copy2();
        *pcVar5 = cVar1;
        cnt_repair_copy2();
      }
      else {
        cVar1 = *pcVar5;
        cal_addr_copy2();
        if (*pcVar5 == cVar1) {
          ret_peek_dptr();
          *pcVar5 = cVar1;
          cnt_repair_copy1();
        }
      }
    }
    pcVar4 = pcVar4 + 1;
    cVar2 = cVar2 + -1;
  } while ((cVar2 != '\0') || (cVar3 = cVar3 + -1, cVar3 != '\0'));
  return;
}

/* ---- cal_copy1_to_2  @0x0A41  (20 bytes) */
void cal_copy1_to_2(void)

{
  xdata_copy(0x200,0xca,1,0xcf,3);
  cal_checksum_copy2(0);
  return;
}

/* ---- cal_copy1_to_3  @0x0A55  (20 bytes) */
void cal_copy1_to_3(void)

{
  xdata_copy(0x200,0xca,1,0x9e,5);
  cal_checksum_copy3(0);
  return;
}

/* ---- cal_copy2_to_1  @0x0A69  (20 bytes) */
void cal_copy2_to_1(void)

{
  xdata_copy(0x3cf,0xca,1,0,2);
  cal_checksum_copy1(0);
  return;
}

/* ---- cal_copy3_to_2  @0x0A7D  (20 bytes) */
void cal_copy3_to_2(void)

{
  xdata_copy(0x59e,0xca,1,0xcf,3);
  cal_checksum_copy2(0);
  return;
}

/* ---- cnt_sum_err_copy1  @0x0A95  (7 bytes) */
void cnt_sum_err_copy1(void)

{
  diag_err_total = diag_err_total + '\x01';
  return;
}

/* ---- cnt_sum_err_copy2  @0x0A9C  (7 bytes) */
void cnt_sum_err_copy2(void)

{
  cal_sum_err_copy2 = cal_sum_err_copy2 + '\x01';
  return;
}

/* ---- cnt_sum_err_copy3  @0x0AA3  (7 bytes) */
void cnt_sum_err_copy3(void)

{
  cal_sum_err_copy3 = cal_sum_err_copy3 + '\x01';
  return;
}

/* ---- cnt_repair_copy1  @0x0AAA  (7 bytes) */
void cnt_repair_copy1(void)

{
  cal_repair_copy1 = cal_repair_copy1 + '\x01';
  return;
}

/* ---- cnt_repair_copy2  @0x0AB1  (7 bytes) */
void cnt_repair_copy2(void)

{
  cal_fallback_flags = cal_fallback_flags + '\x01';
  return;
}

/* ---- cnt_repair_copy3  @0x0AB8  (7 bytes) */
void cnt_repair_copy3(void)

{
  cal_fail_code = cal_fail_code + '\x01';
  return;
}

/* ---- cal_set_slope_limits  @0x0ADC  (47 bytes) */
void cal_set_slope_limits(uint8_t *param_1)

{
  uint8_t bVar1;
  uint16_t uVar2;
  
  bVar1 = meter_state & 0x7f;
  if (((bVar1 == 0x65) || (bVar1 == 0x55)) || (bVar1 == 0x29)) {
    uVar2 = 0x6fa9;
  }
  else {
    uVar2 = 0x6f71;
  }
  fp_ld_code_r0(uVar2);
  fp_st_r0_xdata(0x792);
  *param_1 = *param_1 ^ 0x80;
  fp_st_r0_xdata(0x796);
  return;
}

/* ---- cal_point_flags  @0x0B0B  (26 bytes)
 *      flag byte of the recipe table entry (bit0 zero-cold,1 gain-cold,2 zero-Tref,3 gain-Tref,4 zero-hot,5 gain-hot,7 two sets) */
uint8_t cal_point_flags(short param_1)

{
  if ((((meter_state & 0xf) == 0) && (peak_mode_b1 != '\0')) && (peak_mode_b0 != '\0')) {
    return 0;
  }
  cal_recipe_ptr();
  return *(uint8_t *)(param_1 + 2);
}

/* ---- cal_ctx_save  @0x0B25  (15 bytes)
 *      IRAM 39h..5Fh -> XDATA 0x07A2 */
void cal_ctx_save(uint8_t param_1)

{
  ram_3B = param_1;
  iram_to_xdata(0x7a2,0x39,0x27);
  return;
}

/* ---- cal_ctx_restore  @0x0B34  (10 bytes) */
void cal_ctx_restore(void)

{
  xdata_to_iram(0x7a2,0x39,0x27);
  return;
}

/* ---- cal_classify_input  @0x0B3E  (360 bytes)
 *      zero vs gain point, level window, polarity, allowed by flags -> codes 1..9 */
uint8_t cal_classify_input(void)

{
  bool bVar1;
  uint8_t bVar2;
  
  cal_nominal_value();
  bVar2 = meter_state & 0xf;
  if ((bVar2 == 4) || (bVar2 == 5)) {
    ram_4B = ram_4B - 1;
  }
  else if (bVar2 == 0xb) {
    fp_ld_code_r0(0x692f,0x4b);
  }
  else if ((meter_state & 0x7f) == 0x42) {
    fp_ld_code_r0(0x6fb1,0x4b);
  }
  fp_st_r0_xdata(0x7a2,0x4b);
  bVar2 = meter_state & 0xf;
  if (bVar2 == 1) {
    bVar1 = false;
LAB_CODE_0b85:
    bVar2 = bVar1 << 7;
    fp_ld_code_r0(0x6f85,0x5b,0x5f);
    fp_ld_code_r1(0x6f91);
  }
  else {
    bVar1 = bVar2 < 10;
    if (bVar2 == 10) goto LAB_CODE_0b85;
    bVar2 = ((meter_state & 0x7f) < 0x65) << 7;
    if ((meter_state & 0x7f) == 0x65) {
      fp_ld_code_r0(0x6f75,0x5b,0x5f);
      fp_ld_code_r1(0x6fa1);
    }
    else {
      fp_ld_code_r0(0x6f81,0x5b,0x5f);
      fp_ld_code_r1(0x6f95);
    }
  }
  bVar2 = bVar2 & 0xdd;
  if ((meter_state & 0xf) == 0) {
    cal_nominal_from_range();
    ram_47 = ram_47 ^ 0x80;
    fp_cmp(0x50);
    if (-1 < (char)bVar2) {
      bVar2 = 1;
      goto LAB_CODE_0c12;
    }
  }
  fp_copy_r1_to_r0(0x43,0x50);
  ram_43 = ram_43 & 0x7f;
  bVar2 = bVar2 & 0xdd;
  fp_ld_code_r0(0x6f61,0x47);
  fp_mul(0x4b);
  fp_cmp(0x43);
  if ((char)bVar2 < '\0') {
    fp_mul(0x5b,0x4b);
    fp_cmp(0x43);
    if (-1 < (char)bVar2) {
      bVar2 = 2;
      goto LAB_CODE_0c12;
    }
    fp_mul(0x5f,0x4b);
    fp_cmp(0x43);
    if ((char)bVar2 < '\0') {
      bVar2 = 3;
      goto LAB_CODE_0c12;
    }
    bVar2 = meter_state & 0xf;
    if (((((bVar2 == 5) || (bVar2 == 4)) || (bVar2 == 0xb)) || ((bVar2 == 6 || (bVar2 == 0xc)))) ||
       ((bVar2 == 2 || (bVar2 == 7)))) {
      if (-1 < ram_50) {
        bVar2 = 4;
        goto LAB_CODE_0c12;
      }
      ram_4B = ram_4B ^ 0x80;
    }
    else if ((bVar2 != 1) && (ram_50 < '\0')) {
      bVar2 = 5;
      goto LAB_CODE_0c12;
    }
  }
  else {
    bit_2F_6 = '\x01';
  }
  if ((((meter_state & 0xf) == 0) && (peak_mode_b0 != '\0')) ||
     (((meter_state & 0xf) == 1 && ((bit_2F_6 != '\x01' && (ram_50 < '\0')))))) {
    bit_2F_7 = 1;
    ram_39 = fnsel_new_function;
  }
  if (bit_2F_6 == '\0') {
    if (cal_hot == '\x01') {
      if ((ram_39 >> 5 & 1) == 1) {
        bit_2A_3 = 0;
        return ram_39;
      }
      bVar2 = 9;
    }
    else {
      if ((ram_39 >> 1 & 1) == 1) {
        bit_2A_3 = 0;
        return ram_39;
      }
      bVar2 = 8;
    }
  }
  else if (cal_hot == '\x01') {
    if ((ram_39 >> 4 & 1) == 1) {
      bit_2A_3 = 0;
      return ram_39;
    }
    bVar2 = 7;
  }
  else {
    if ((ram_39 & 1) == 1) {
      bit_2A_3 = 0;
      return ram_39;
    }
    bVar2 = 6;
  }
LAB_CODE_0c12:
  if (bit_2A_3 != '\0') {
    bit_2C_4 = 1;
  }
  bit_2A_3 = 1;
  return bVar2;
}

/* ---- cal_nominal_value  @0x0CA6  (24 bytes)
 *      nominal full-scale value of the range (from range limits and scale) */
void cal_nominal_value(void)

{
  range_param_lookup();
  i24_to_fp(0x46);
  range_scale_exp();
  fp_ld_pow10_r1(0x4b);
  fp_mul(0x4b,0x47);
  return;
}

/* ---- cal_nominal_from_range  @0x0CBE  (26 bytes) */
void cal_nominal_from_range(void)

{
  i24_ld_code_r0(0x7040,0x46);
  i24_to_fp();
  range_scale_exp();
  fp_ld_pow10_r1(0x55);
  fp_mul(0x47,0x55);
  return;
}

/* ---- cal_stability_window  @0x0CD8  (51 bytes)
 *      per-function window table 0x0D0B */
void cal_stability_window(void)

{
  uint8_t bVar1;
  
  if ((meter_state & 0x7f) == 0x65) {
    fp_ld_code_r0(0x6fa9,0x47);
  }
  else {
    bVar1 = (meter_state & 0xf) * '\x02';
    fp_ld_code_r0(CONCAT11((&rom_0D0B)[bVar1],(&rom_0D0C)[bVar1]),0x47);
  }
  range_scale_exp();
  fp_ld_pow10_r1(0x47,0x5b);
  fp_mul();
  return;
}

/* ---- cal_gain_limit_check  @0x0D23  (36 bytes) */
void cal_gain_limit_check(void)

{
  char cVar1;
  uint16_t uVar2;
  
  uVar2 = 0x6f99;
  if ((meter_state & 0x7f) == 0x65) {
    uVar2 = 0x70b9;
  }
  fp_ld_code_r0(uVar2,0x47);
  uVar2 = 0x6f7d;
  cVar1 = ((meter_state & 0x7f) < 0x65) << 7;
  if ((meter_state & 0x7f) == 0x65) {
    uVar2 = 0x6f79;
  }
  fp_ld_code_r0(uVar2,0x4b);
  fp_ld_code_r0(0x6f89,0x5b);
  fp_mul(0x47);
  fp_cmp(0x43,0x5b);
  if (cVar1 < '\0') {
    fp_ld_code_r0(0x6f8d,0x5b);
    fp_mul(0x4b);
    fp_cmp(0x43,0x5b);
    if (-1 < cVar1) {
      return;
    }
  }
  return;
}

/* ---- cal_slope_limit_check  @0x0D47  (48 bytes) */
void cal_slope_limit_check(void)

{
  char in_PSW;
  
  fp_ld_code_r0(0x6f89,0x5b);
  fp_mul(0x47);
  fp_cmp(0x43,0x5b);
  if (in_PSW < '\0') {
    fp_ld_code_r0(0x6f8d,0x5b);
    fp_mul(0x4b);
    fp_cmp(0x43,0x5b);
    if (-1 < in_PSW) {
      return;
    }
  }
  return;
}

/* ---- temp_in_range  @0x0D77  (22 bytes)
 *      internal temperature within 0x70C5..0x70C9 */
void temp_in_range(void)

{
  char in_PSW;
  
  fp_ld_code_r1(0x70c5);
  fp_cmp();
  if (in_PSW < '\0') {
    return;
  }
  fp_ld_code_r1(0x70c9);
  fp_cmp();
  return;
}

/* ---- cal_step_zero  @0x0D8D  (310 bytes)
 *      zero point: needs 3 stable readings (max 29); cold: K0 (+K2=T), hot: K4 slope */
void cal_step_zero(uint8_t param_1)

{
  uint8_t bVar1;
  char in_PSW;
  
  if ((bit_2D_5 != '\0') &&
     ((((bVar1 = meter_state & 0xf, bVar1 == 1 || (bVar1 == 4)) || (bVar1 == 5)) ||
      ((bVar1 == 6 || (in_PSW = (10 < bVar1) << 7, 10 < bVar1)))))) {
    cal_fail(0x21);
    return;
  }
  fp_ld_xdata_r1(0x119,0x43);
  temp_in_range(0x47);
  if (-1 < in_PSW) {
    cal_fail(0x22);
    return;
  }
  bit_2F_7 = '\0';
  bit_2F_6 = '\0';
  ram_39 = cal_point_flags();
  fnsel_new_function = param_1;
  cal_classify_input();
  if (bit_2C_4 != '\0') {
    cal_fail();
    return;
  }
  if (bit_2A_3 != '\x01') {
    BANK3_R2 = BANK3_R2 + 1;
    bVar1 = (2 < BANK3_R2) << 7;
    if (2 < BANK3_R2) {
      cal_reading_stable(0x19f);
      if (((char)bVar1 < '\0') && (cal_reading_stable(0x1cd), (char)bVar1 < '\0')) {
        if (bit_2F_6 != '\x01') {
          cal_step_gain();
          return;
        }
        if (cal_hot != '\x01') {
          cal_adjust_slot(0,0x50);
          if ((ram_39 >> 2 & 1) != 0) {
            fp_ld_xdata_r0(0x119,0x47);
            cal_adjust_slot(2);
          }
          return;
        }
        if (bit_2F_7 == '\0') {
          fp_ld_xdata_r0(0x15f,0x5b);
          fp_ld_xdata_r0(0x167,0x5f);
        }
        else {
          fp_ld_xdata_r0(0x17f,0x5b);
          fp_ld_xdata_r0(0x187,0x5f);
        }
        fp_ld_xdata_r0(0x119,0x43);
        fp_sub(0x5f);
        fp_copy_r0_to_r1(0x4b);
        ram_43 = ram_43 & 0x7f;
        bVar1 = bVar1 & 0xdd;
        fp_ld_code_r1(0x691f,0x47);
        fp_cmp();
        if ((char)bVar1 < '\0') {
          cal_fail_code = 0xc;
          bit_2C_4 = 1;
          return;
        }
        fp_copy_r1_to_r0(0x50);
        fp_sub(0x5b);
        fp_div(0x4b);
        fp_copy_r0_to_r1(0x47);
        ram_47 = ram_47 & 0x7f;
        bVar1 = bVar1 & 0xdd;
        fp_ld_code_r1(0x6f71,0x4b);
        fp_ld_xdata_r0(0x7a2,0x5b);
        fp_mul();
        fp_cmp(0x47);
        if ((char)bVar1 < '\0') {
          cal_fail(0xb);
          return;
        }
        cal_adjust_slot(4,0x43);
        return;
      }
      if (0x1d < BANK3_R2) {
        cal_fail(0x12);
        return;
      }
    }
    fp_ld_xdata_r0(0x19f,0x43);
    fp_st_r0_xdata(0x1cd);
    fp_st_r0_xdata(0x19f,0x50);
  }
  F0 = 1;
  autorange_count_step();
  return;
}

/* ---- cal_reading_stable  @0x0E1B  (28 bytes) */
void cal_reading_stable(void)

{
  fp_copy_r0_to_r1(0x50,0x5b);
  fp_ld_xdata_r0(0x43);
  fp_rsub();
  ram_43 = ram_43 & 0x7f;
  cal_stability_window();
  fp_cmp(0x43,0x47);
  return;
}

/* ---- cal_fail  @0x0EDF  (7 bytes)
 *      A = fail code -> XDATA 0x0771, sets fail flag */
void cal_fail(uint8_t param_1)

{
  cal_fail_code = param_1;
  bit_2C_4 = 1;
  return;
}

/* ---- cal_step_gain  @0x0EE6  (291 bytes)
 *      gain point: cold: K1 (+K3=T), hot: K5 slope */
void cal_step_gain(void)

{
  uint8_t uVar1;
  uint8_t in_PSW;
  uint8_t bVar2;
  
  if (cal_hot == '\0') {
    if (bit_2F_7 == '\0') {
      uVar1 = 0x43;
      fp_ld_xdata_r0(0x15f,0x43);
    }
    else {
      uVar1 = 0x43;
      fp_ld_xdata_r0(0x17f,0x43);
      in_PSW = in_PSW & 0xdd;
      if ((meter_state & 0xf) == 1) {
        ram_4B = ram_4B ^ 0x80;
      }
    }
    fp_copy_r0_to_r1(0x50,0x5f,uVar1);
    fp_rsub(uVar1);
    fp_div(0x4b,0x43);
    fp_copy_r0_to_r1();
    cal_gain_limit_check();
    if ((char)in_PSW < '\0') {
      cal_fail(0xe);
      return;
    }
    cal_adjust_slot(1,0x43);
    if ((ram_39 >> 3 & 1) != 0) {
      fp_ld_xdata_r0(0x119,0x47);
      cal_adjust_slot(3);
    }
    return;
  }
  if (bit_2F_7 == '\0') {
    fp_ld_xdata_r1(0x177,0x5b);
    fp_ld_xdata_r1(0x163,0x5f);
    fp_ld_xdata_r1(0x16b,0x55);
  }
  else {
    in_PSW = in_PSW & 0xdd;
    if ((meter_state & 0xf) == 1) {
      ram_4B = ram_4B ^ 0x80;
    }
    fp_ld_xdata_r1(0x197,0x5b);
    fp_ld_xdata_r1(0x183,0x5f);
    fp_ld_xdata_r1(0x18b,0x55);
  }
  fp_ld_xdata_r0(0x119,0x43);
  fp_sub(0x55);
  fp_copy_r0_to_r1();
  ram_43 = ram_43 & 0x7f;
  bVar2 = in_PSW & 0xdd;
  fp_ld_code_r1(0x691f,0x47);
  fp_cmp();
  if ((char)bVar2 < '\0') {
    cal_fail_code = 0xc;
    bit_2C_4 = 1;
    return;
  }
  fp_copy_r0_to_r1(0x50,0x43);
  fp_rsub(0x5b);
  fp_div(0x4b,0x5b);
  fp_copy_r0_to_r1(0x43);
  cal_gain_limit_check();
  if ((char)bVar2 < '\0') {
    cal_fail(0x10);
    return;
  }
  fp_sub(0x43,0x5f);
  fp_div(0x55);
  fp_copy_r0_to_r1(0x43,0x5f);
  ram_43 = ram_43 & 0x7f;
  bVar2 = bVar2 & 0xdd;
  cal_set_slope_limits(0x47);
  fp_ld_xdata_r0(0x792);
  fp_ld_xdata_r0(0x796,0x4b);
  cal_slope_limit_check();
  if ((char)bVar2 < '\0') {
    cal_fail(0x11);
    return;
  }
  cal_adjust_slot(5,0x5f);
  return;
}

/* ---- internal_temp_init  @0x10D1  (10 bytes) */
void internal_temp_init(void)

{
  internal_temp = 0;
  xram_011A = 0x80;
  return;
}

/* ---- cal_compute_effective  @0x12A2  (27 bytes)
 *      temp-compensate set 0 (and set 1 for Vpeak/VDC/CAP) */
void cal_compute_effective(void)

{
  uint8_t bVar1;
  
  cal_temp_compensate();
  bVar1 = meter_state & 0xf;
  if (((bVar1 == 0) || (bVar1 == 1)) || (bVar1 == 9)) {
    cal_swap_sets();
    cal_temp_compensate();
    cal_swap_sets();
  }
  return;
}

/* ---- cal_temp_compensate  @0x12BD  (112 bytes)
 *      zero_eff = K0 + K4*(T-K2), gain_eff = K1 + K5*(T-K3); T = internal_temp */
void cal_temp_compensate(void)

{
  if ((cal_mode == '\0') || (cal_hot == '\x01')) {
    fp_ld_xdata_r0(0x119,0x43,0x47);
    fp_ld_xdata_r1(0x16b);
    fp_sub();
    fp_ld_xdata_r1(0x173);
    fp_mul();
    fp_ld_xdata_r1(0x163);
    fp_add();
    fp_st_r0_xdata(0x17b);
    fp_ld_xdata_r0(0x119);
    fp_ld_xdata_r1(0x167);
    fp_sub();
    fp_ld_xdata_r1(0x16f);
    fp_mul();
    fp_ld_xdata_r1(0x15f);
    fp_add();
    fp_st_r0_xdata(0x177);
    return;
  }
  fp_ld_xdata_r0(0x163,0x43,0x47);
  fp_st_r0_xdata(0x17b);
  fp_ld_xdata_r0(0x15f);
  fp_st_r0_xdata(0x177);
  return;
}

/* ---- cal_swap_sets  @0x132D  (15 bytes)
 *      exchange cal_work_set0 and cal_work_set1 */
void cal_swap_sets(void)

{
  xdata_block_xfer(0x15f,0x20,0,0x7f,1);
  return;
}

/* ---- internal_temp_from_count  @0x133C  (29 bytes)
 *      200000 / count -> XDATA 0x00EC */
void internal_temp_from_count(void)

{
  i24_to_fp(0x10);
  fp_ld_code_r0(0x707d,0x43,0x11);
  fp_div();
  fp_st_r0_xdata(0xec);
  bit_25_1 = 0;
  bit_22_3 = 1;
  return;
}

/* ---- internal_temp_update  @0x1359  (97 bytes)
 *      new internal-temperature reading -> filtered internal_temp */
void internal_temp_update(void)

{
  uint8_t in_PSW;
  
  i24_to_fp(0x10);
  fp_ld_code_r1(0x7065,0x43);
  fp_div();
  temp_in_range();
  if ((char)in_PSW < '\0') {
    fp_copy_r0_to_r1();
    fp_ld_xdata_r1(0x119,0x47);
    fp_sub(0x43);
    ram_43 = ram_43 & 0x7f;
    in_PSW = in_PSW & 0xdd;
    fp_ld_code_r1(0x691f,0x4b);
    fp_cmp();
    if ((char)in_PSW < '\0') {
      fp_ld_xdata_r0(0x119,0x47);
      internal_temp_filter();
      fp_st_r0_xdata(0x119);
      if (bit_2D_3 != '\x01') {
        bit_2D_4 = 1;
      }
      if (bit_2D_7 != '\x01') {
        bit_2D_6 = 0;
      }
      bit_2D_3 = '\0';
      bit_2C_6 = 1;
      bit_22_3 = 1;
    }
    else {
      fp_st_r0_xdata(0x119,0x11);
    }
  }
  return;
}

/* ---- internal_temp_track  @0x13BA  (150 bytes)
 *      two references XDATA 0x00CD / 0x00D0 */
void internal_temp_track(void)

{
  char in_PSW;
  uint16_t uVar1;
  
  internal_temp_delta_check(0xcd);
  if (in_PSW < '\0') {
    bit_2D_5 = '\0';
    i24_to_fp(0x10);
    i24_ld_xdata_r0(0xcd,0x46);
    i24_to_fp();
    internal_temp_filter();
    fp_copy_r1_to_r0(0x47,0x11);
    fp_to_i24_round();
    i24_st_r0_xdata(0xcd);
    goto LAB_CODE_140a;
  }
  if (bit_2D_7 == '\x01') {
LAB_CODE_13cd:
    bit_2D_5 = '\0';
    uVar1 = 0xcd;
  }
  else {
    internal_temp_delta_check(0xd0);
    if (in_PSW < '\0') goto LAB_CODE_13cd;
    bit_2D_5 = '\x01';
    uVar1 = 0xd0;
  }
  i24_st_r0_xdata(uVar1,0x10);
  i24_to_fp();
LAB_CODE_140a:
  if (bit_2D_5 == '\x01') {
    ram_36 = ram_36 + 1;
  }
  else {
    ram_36 = 0;
    fp_ld_code_r0(0x7061,0x43);
    fp_mul();
    fp_to_i24_round();
    i24_st_r0_xdata(0x11d);
    fp_ld_code_r0(0x705d,0x43,0x11);
    fp_mul();
    fp_to_i24_round();
    i24_st_r0_xdata(0x120);
  }
  if ((bit_2D_5 == '\0') || (2 < ram_36)) {
    ram_36 = 0;
    ram_2D = ram_2D & 0x2f;
    bit_22_3 = 1;
  }
  return;
}

/* ---- internal_temp_delta_check  @0x1450  (26 bytes) */
void internal_temp_delta_check(void)

{
  char *pcVar1;
  
  pcVar1 = &ram_43;
  i24_ld_xdata_r0();
  i24_sub(0x10);
  i24_abs();
  if (*pcVar1 == '\0' && pcVar1[-1] == '\0') {
    return;
  }
  return;
}

/* ---- internal_temp_filter  @0x146A  (29 bytes) */
void internal_temp_filter(void)

{
  fp_ld_code_r1(0x6f7d,0x47,0x43);
  fp_mul();
  fp_ld_code_r1(0x6f69,0x11);
  fp_mul();
  fp_add(0x47);
  return;
}

/* ---- cal_apply  @0x16DC  (82 bytes)
 *      value = (count - zero_eff) * gain_eff (set 1 for negative VDC, Vp-, CAP in SPEED 3) */
void cal_apply(void)

{
  uint8_t bVar1;
  uint16_t uVar2;
  uint8_t uStack_1;
  
  fp_push_r1(0x43);
  bVar1 = meter_state & 0xf;
  if (bVar1 == 0) {
    if ((peak_mode_b0 != '\0') && ((peak_mode_b1 == '\0' || (bit_2E_2 == '\x01')))) goto LAB_CODE_1702;
  }
  else if (bVar1 == 1) {
    if (ram_50 < '\0') {
LAB_CODE_1702:
      uStack_1 = 0x9b;
      uVar2 = 0x197;
      goto LAB_CODE_1718;
    }
  }
  else if ((bVar1 == 9) && (speed_b1 != '\0')) goto LAB_CODE_1702;
  uStack_1 = 0x7b;
  uVar2 = 0x177;
LAB_CODE_1718:
  fp_ld_xdata_r1(uVar2);
  fp_sub(0x50);
  fp_ld_xdata_r1(CONCAT11(1,uStack_1));
  fp_mul();
  fp_clr_r1();
  return;
}

/* ---- cal_step_allowed  @0x3B40  (24 bytes)
 *      flags for the current range and cold/hot */
void cal_step_allowed(void)

{
  uint8_t bVar1;
  
  bVar1 = cal_point_flags();
  ram_39 = bVar1 & 0x7f;
  if (cal_hot != '\0') {
    ram_39 = bVar1 & 0x30;
  }
  if (ram_39 == 0) {
    return;
  }
  return;
}

/* ---- cal_msg_000000C  @0x3B68  (10 bytes) */
void cal_msg_000000C(void)

{
  lcd_show_message(0x71a0);
  lcd_refresh();
  return;
}

/* ---- cal_msg_100000C  @0x3B72  (10 bytes) */
void cal_msg_100000C(void)

{
  lcd_show_message(0x71a9);
  lcd_refresh();
  return;
}

/* ---- cal_msg_200000C  @0x3B7C  (10 bytes) */
void cal_msg_200000C(void)

{
  lcd_show_message(0x71b2);
  lcd_refresh();
  return;
}

/* ---- cal_msg_60000C  @0x3B90  (10 bytes) */
void cal_msg_60000C(void)

{
  lcd_show_message(0x71c4);
  lcd_refresh();
  return;
}

/* ---- cal_show_status  @0x3B9A  (158 bytes)
 *      calibration mode: show the step codes 000000C/100000C/200000C/60000C */
uint8_t cal_show_status(uint8_t param_1)

{
  bool bVar1;
  uint8_t bVar2;
  char cVar3;
  char *pcVar4;
  uint8_t *puVar5;
  
  if (bit_26_1 != '\0') {
    return param_1;
  }
  if ((meter_state & 0xf) < 4) {
    cVar3 = ((meter_state & 0x7f) < 0x42) << 7;
    if ((meter_state & 0x7f) == 0x42) {
      cal_msg_60000C();
    }
    else {
      cVar3 = ((meter_state & 0x70) < 0x40) << 7;
      if ((meter_state & 0x70) == 0x40) {
        cal_msg_100000C();
      }
      else {
        cal_msg_200000C();
      }
    }
  }
  else {
    bVar2 = (meter_state & 0xf) - 4;
    cVar3 = CARRY1(bVar2 * '\x02',bVar2) << 7;
                    /* WARNING: Switch is manually overridden */
    switch(bVar2 * '\x03') {
    case 0:
      if ((meter_state & 0x70) == 0x10) {
        cVar3 = '\0';
      }
      else {
        cVar3 = ((meter_state & 0x70) < 0x20) << 7;
        if ((meter_state & 0x70) != 0x20) {
          cal_msg_200000C();
          break;
        }
      }
      cal_msg_100000C();
      break;
    case 3:
      bVar2 = meter_state & 0x70;
      cVar3 = (0x20 < bVar2) << 7;
      if (0x20 < bVar2) {
        cal_msg_100000C();
      }
      else {
        cal_msg_200000C(' ' - bVar2);
      }
      break;
    case 6:
      cal_msg_100000C();
      break;
    case 9:
      cal_msg_100000C();
      break;
    case 0xc:
      lcd_show_dashes();
      break;
    case 0xf:
      cal_msg_200000C();
      break;
    case 0x12:
      cal_msg_100000C();
      break;
    case 0x15:
      cal_msg_000000C();
      break;
    case 0x18:
      cal_msg_200000C();
      break;
    case 0x1b:
      lcd_show_dashes();
      break;
    case 0x1e:
      break;
    case 0x21:
    }
  }
  bVar2 = cal_step_allowed();
  if (cVar3 < '\0') {
    ram_39 = 0;
    do {
      if (0x11 < ram_39) {
        return ram_39 - 0x12;
      }
      pcVar4 = (char *)0x0;
      dptr_add_a(ram_39);
      if (*pcVar4 == '#') {
        pcVar4 = (char *)0x0;
        dptr_add_a(ram_39 - 2);
        if (*pcVar4 == '.') {
          puVar5 = (uint8_t *)0x0;
          dptr_add_a(ram_39 - 3);
          *puVar5 = 0x4e;
        }
        else {
          puVar5 = (uint8_t *)0x0;
          dptr_add_a(ram_39 - 2);
          *puVar5 = 0x4e;
        }
        puVar5 = (uint8_t *)0x0;
        dptr_add_a(ram_39 - 1);
        *puVar5 = 0x41;
        ram_39 = 0x12;
      }
      bVar1 = ram_39 != 0xff;
      bVar2 = ram_39 + 1;
      ram_39 = bVar2;
    } while (bVar1);
  }
  return bVar2;
}

/* ---- cal_status_or_dashes  @0x3CB7  (12 bytes) */
void cal_status_or_dashes(void)

{
  if (cal_mode == '\0') {
    lcd_show_dashes();
  }
  else {
    cal_show_status();
  }
  return;
}

/* ---- cal_mode_enter  @0x3E5B  (38 bytes)
 *      sets cal_mode, autorange off */
void cal_mode_enter(void)

{
  speed_load();
  cal_mode = 1;
  meter_autorange = 0;
  if ((bit_21_2 == '\0') && (bit_21_3 == '\0')) {
    bit_21_2 = '\0';
    bit_21_3 = '\x01';
    ram_57 = 0;
    ram_56 = 0x80;
    cal_write_all_copies_safe(900,0x57);
  }
  return;
}

/* ---- cal_seal_check  @0x5B74  (18 bytes)
 *      C=1 if seal byte = 'a' (cal data altered): ranges show NC, CDP? items flagged N */
void cal_seal_check(void)

{
  char cVar1;
  char cVar2;
  
  cVar2 = nv_setting_read(4);
  cVar1 = F0;
  if (cVar1 != '\x01') {
    if (cVar2 == 'a') {
      return;
    }
    if (cVar2 == 'N') {
      return;
    }
  }
  nv_setting_write(0x4e,4);
  return;
}

/* ---- cal_seal_normal  @0x5B86  (4 bytes)
 *      CDP R: seal byte = 'N' */
void cal_seal_normal(void)

{
  nv_setting_write(0x4e,4);
  return;
}

/* ---- cal_seal_altered  @0x5B8A  (9 bytes)
 *      CDP S: seal byte = 'a' */
void cal_seal_altered(void)

{
  nv_setting_write(0x61,4);
  return;
}

