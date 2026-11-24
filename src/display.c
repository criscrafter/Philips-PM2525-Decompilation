/* display.c - LCD text formatting, font, annunciators, messages
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 31 functions, 2760 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/display.c.
 */
#include "pm2525.h"

/* ---- lcd_dashes_refresh  @0x3074  (9 bytes) */
void lcd_dashes_refresh(void)

{
  lcd_show_message(&msg_table);
  lcd_refresh();
  return;
}

/* ---- task_display_update  @0x326C  (144 bytes)
 *      every 50 main-loop passes (24h.1): result -> LCD */
void task_display_update(void)

{
  char cVar1;
  uint8_t *puVar2;
  
  if (xram_00C1 < '\0') {
    return;
  }
  puVar2 = (uint8_t *)0x9d;
  xdata_to_iram(0x2b,8);
  if (bit_26_2 == '\x01') {
    if (bit_2F_6 == '\0') {
      bit_2F_6 = '\x01';
      out_format_params_a();
      goto LAB_CODE_32aa;
    }
    if (ram_30 == '\0' && ram_31 == '\0') {
      bit_24_2 = '\0';
      ram_26 = ram_26 & 0xf8;
      bit_2F_6 = '\0';
      if (bit_26_3 == '\x01') goto LAB_CODE_32aa;
      puVar2 = &msg_table;
      lcd_show_message();
      lcd_refresh();
    }
    else {
LAB_CODE_32c6:
      if (bit_24_2 == '\x01') goto LAB_CODE_32e4;
    }
    lcd_unit_symbols();
LAB_CODE_32cc:
    lcd_build_annunciators();
    lcd_prepare_value();
    lcd_send_frame();
    cVar1 = (char)((uint16_t)puVar2 >> 8);
    if ((uint8_t)puVar2 < 2) {
      cVar1 = cVar1 + -1;
    }
    *(uint8_t *)CONCAT11(cVar1,(uint8_t)puVar2 - 2) = 0x23;
  }
  else {
    bit_2F_6 = '\0';
LAB_CODE_32aa:
    if (((meter_state & 0xe) == 6) || (bit_25_6 != '\x01')) {
      if (bit_26_1 != '\x01') {
        display_show_held_value();
        goto LAB_CODE_32cc;
      }
      if (bit_26_0 == '\0') goto LAB_CODE_32c6;
      lcd_format_minmax();
    }
    else {
LAB_CODE_32e4:
      lcd_clear_flags();
    }
    lcd_build_annunciators();
    lcd_prepare_value();
    lcd_send_frame();
  }
  bit_24_1 = 0;
  iram_to_xdata(0x9d,0x2b,8);
  return;
}

/* ---- display_show_held_value  @0x32FC  (59 bytes) */
void display_show_held_value(void)

{
  if (bit_26_3 != '\0') {
    bit_26_3 = '\0';
    fp_ld_xdata_r0(0x89,0x57);
    ram_2A = xram_0067;
    ram_53 = xram_0068;
    lcd_format_reading();
    if ((xram_005A == '\x05') && ((ram_2A & 0xa6) == 0)) {
      bit_23_1 = 1;
      xdata_block_xfer(0,9,0,0x5b,0);
    }
  }
  lcd_unit_symbols();
  return;
}

/* ---- lcd_format_minmax  @0x3337  (78 bytes)
 *      (inferred) MIN/MAX value display */
void lcd_format_minmax(void)

{
  uint8_t *puVar1;
  
  fp_ld_xdata_r0(CONCAT11(xram_0098,xram_0099),0x57);
  if ((xram_00A8 >> 3 & 1) == 0) {
    if ((xram_00A8 >> 2 & 1) == 0) {
      ram_2A = 0;
      if ((xram_00A7 >> 3 & 1) == 0) {
        ram_53 = meter_state & 0x70;
        bit_2E_3 = bit_25_6 & 1;
      }
      else {
        ram_53 = xram_006D;
      }
      goto LAB_CODE_337f;
    }
    puVar1 = &xram_006B;
  }
  else {
    puVar1 = &xram_0069;
  }
  ram_2A = *puVar1;
  ram_53 = puVar1[1];
LAB_CODE_337f:
  lcd_format_reading();
  lcd_unit_symbols();
  return;
}

/* ---- lcd_format_reading  @0x3385  (481 bytes)
 *      value -> LCD text buffer XDATA 0x0000; 'r' at pos 8 in cal mode, "NC" when uncalibrated */
void lcd_format_reading(uint8_t param_1)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  char cVar4;
  uint16_t uVar5;
  uint8_t *puVar6;
  
  bit_26_4 = 0;
  lcd_copy_range_bits(0x53);
  bit_2E_3 = ram_53 >> 7;
  bit_2D_5 = bit_2A_0 & 1;
  bit_2A_6 = ram_57 >> 7;
  ram_57 = ram_57 & 0x7f;
  cVar4 = ((meter_state & 0xf) < 0xd) << 7;
  if ((meter_state & 0xf) == 0xd) {
    fp_cmp_ten();
    if (cVar4 < '\0') {
      uVar5 = 0x715f;
    }
    else {
      uVar5 = 0x7152;
    }
    lcd_copy_message(uVar5);
    return;
  }
  if (bit_2A_1 != '\0') {
    lcd_show_msg_thunk(0x70ed);
    value_is_signed();
    if (-1 < cVar4) {
      return;
    }
    goto LAB_CODE_33cf;
  }
  if (bit_2A_2 != '\0') {
    lcd_copy_message(0x70ff);
    return;
  }
  if (bit_22_0 == '\0') {
    lcd_decimal_point((ram_2E & 0x70) >> 4,0x57,0x5f);
    bVar2 = resolution_digits();
    if ((bit_2A_7 == '\x01') || (bit_2A_3 != '\0')) {
      if ((meter_state & 0xf) == 8) {
        bVar2 = range_decimal_pos((ram_2E & 0x70) >> 4);
        bVar2 = ~bVar2 + 1;
      }
      else {
        bVar2 = bVar2 - 1;
      }
    }
    ram_35 = bVar2;
    bVar2 = range_decimal_pos((ram_2E & 0x70) >> 4,
                              bVar2 - 1 >> 4 | (bVar2 - 1) * '\x10' | bVar2);
    cVar4 = CARRY1(bVar2,ram_35) << 7;
    bVar2 = bVar2 + ram_35;
    bVar1 = 0x40;
    if ((((bit_22_1 == '\0') || (bit_26_2 == '\x01')) || ((xram_00A7 & 1) != 0)) &&
       (func_class_check(), -1 < cVar4)) {
      bVar1 = 0;
    }
    bVar3 = param_1 - bVar2;
    cVar4 = CARRY1(bVar3,ram_35) << 7;
    lcd_round_value(bVar3,bVar3 + ram_35);
    fp_cmp();
    if (cVar4 < '\0') {
      lcd_set_sign();
      bVar2 = bVar2 | 0xb0;
      goto LAB_CODE_34fb;
    }
    cVar4 = CARRY1(ram_35,param_1) << 7;
    lcd_round_value(param_1,ram_35 + param_1);
    fp_cmp();
    if (cVar4 < '\0') {
      lcd_set_sign();
      bVar2 = 0xa0;
      goto LAB_CODE_34fb;
    }
    if (bit_2E_6 != '\x01') {
      if ((bit_2E_5 == '\x01') || (bit_2E_4 == '\x01')) {
        if (param_1 != 0) {
          bit_2E_6 = '\x01';
          ram_2E = ram_2E & 0xcf;
          goto LAB_CODE_34da;
        }
      }
      else if (bit_20_3 != '\x01') {
        bit_2E_6 = '\0';
        ram_2E = ram_2E | 0x30;
LAB_CODE_34da:
        param_1 = param_1 + 3;
        cVar4 = CARRY1(ram_35,param_1) << 7;
        lcd_round_value(param_1,ram_35 + param_1);
        fp_cmp();
        if (cVar4 < '\0') {
          lcd_set_sign();
          bVar2 = 0xa0;
LAB_CODE_34fb:
          puVar6 = (uint8_t *)0x0;
          fp_format(bVar2 | bVar1);
          lcd_pad_spaces();
          *puVar6 = 0x23;
          if (cal_mode == '\0') {
            lcd_append_nc();
            return;
          }
          xram_0008 = 0x72;
          return;
        }
      }
    }
    cVar4 = (3 < param_1 + 0xd) << 7;
    lcd_round_value(param_1 + 0xd);
    fp_cmp();
    if (cVar4 < '\0') {
      fp_ld_pow10_r1(~param_1 + 1);
      fp_mul();
      fp_ld_code_r1(0x70dc,bVar1);
      fp_cmp();
      if (cVar4 < '\0') {
        bVar2 = 0x88;
      }
      else {
        bVar2 = 0xb0;
      }
      ram_35 = 4;
      lcd_set_sign(bVar2 | bVar1,0x34);
      fp_format(0);
      xram_0008 = xram_0009;
      xram_0009 = 0x23;
      lcd_append_nc();
      return;
    }
  }
  else {
    if (bit_2A_5 != '\0') {
      lcd_show_msg_thunk(0x70f6);
      return;
    }
    fp_ld_pow10_r1(3,0x57);
    fp_cmp();
    if (cVar4 < '\0') {
      if (bit_26_0 != '\x01') {
        i24_ld_xdata_r0(0x116,0x5b);
        i24_ld_code_r1(0x70d5,0x5f);
        i24_cmp();
        if (cVar4 < '\0') {
          ram_35 = 3;
          bVar2 = 0;
          goto LAB_CODE_3434;
        }
      }
      ram_35 = 4;
      bVar2 = 1;
LAB_CODE_3434:
      lcd_set_sign(0x57,bVar2);
      puVar6 = (uint8_t *)0x0;
      fp_format(bVar2 | 0xf0,ram_35 - 1 >> 4 | (ram_35 - 1) * '\x10' | ram_35,0
               );
      lcd_pad_spaces();
      *puVar6 = 0x23;
      lcd_append_nc();
      return;
    }
  }
  lcd_set_sign();
  lcd_show_msg_thunk(0x7108);
LAB_CODE_33cf:
  lcd_text_buf = 0x2b;
  if (bit_2A_6 != 0) {
    lcd_text_buf = 0x2d;
  }
  return;
}

/* ---- lcd_pad_spaces  @0x3566  (22 bytes) */
void lcd_pad_spaces(void)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t *puVar3;
  
  puVar3 = (uint8_t *)0x2;
  bVar1 = dptr_add_a_b(ram_35);
  cVar2 = ~bVar1 + 8;
  if (cVar2 != '\0') {
    do {
      *puVar3 = 0x20;
      puVar3 = puVar3 + 1;
      cVar2 = cVar2 + -1;
    } while (cVar2 != '\0');
  }
  return;
}

/* ---- lcd_append_nc  @0x357C  (28 bytes)
 *      "NC" at text positions 7-8 */
void lcd_append_nc(void)

{
  char cVar1;
  uint8_t *puVar2;
  uint8_t *puVar3;
  
  if (bit_2A_4 != '\0') {
    puVar2 = &xram_0007;
    F0 = 0;
    if (xram_0007 == '.') {
      F0 = 1;
      puVar2 = &xram_0006;
    }
    *puVar2 = 0x4e;
    puVar3 = puVar2 + 1;
    cVar1 = F0;
    if (cVar1 != '\0') {
      puVar3 = puVar2 + 2;
    }
    *puVar3 = 0x43;
  }
  return;
}

/* ---- lcd_unit_symbols  @0x3598  (48 bytes)
 *      per-function jump table 0x35C8 sets the unit annunciator bits */
void lcd_unit_symbols(void)

{
  if (bit_26_4 != '\0') {
    bit_26_4 = '\0';
    lcd_copy_range_bits(0x20);
    bit_2E_3 = bit_25_6 & 1;
  }
  if (bit_22_0 == '\0') {
    lcd_mode_symbols(0x20,0x20);
  }
  lcd_insert_unit_char();
  lcd_clear_flags();
                    /* WARNING: Switch is manually overridden */
  switch((meter_state & 0xf) * '\x03') {
  case 0:
    return;
  case 3:
    bit_2D_2 = 1;
    return;
  case 6:
    bit_2D_3 = 1;
    return;
  case 9:
    break;
  case 0xc:
    bit_2D_1 = 1;
    return;
  case 0xf:
    bit_2D_0 = 1;
    return;
  case 0x12:
    bit_2D_2 = 1;
    return;
  case 0x15:
    bit_2D_3 = 1;
    return;
  case 0x18:
    bit_2B_6 = 1;
    return;
  case 0x1b:
    return;
  case 0x1e:
    bit_2B_1 = 1;
    return;
  case 0x21:
    return;
  case 0x24:
    bit_2D_6 = 1;
    return;
  case 0x27:
    bit_2D_7 = 1;
    return;
  }
  bit_2C_4 = 1;
  bit_2D_3 = 1;
  return;
}

/* ---- lcd_copy_range_bits  @0x35F6  (9 bytes) */
void lcd_copy_range_bits(uint8_t *param_1)

{
  ram_2E = ram_2E & 0x8f | *param_1 & 0x70;
  return;
}

/* ---- lcd_mode_symbols  @0x35FF  (119 bytes)
 *      (inferred) */
void lcd_mode_symbols(void)

{
  if (bit_20_3 == '\x01') {
    if (bit_20_2 != '\0') {
      if (bit_20_0 == '\0') {
        return;
      }
      return;
    }
    if (bit_20_1 != '\x01') {
      if (bit_20_0 == '\x01') {
        if (bit_2E_6 == '\0') {
          return;
        }
        return;
      }
      if (time_stop_negslope == '\x01') {
        return;
      }
      return;
    }
    if (bit_20_0 == '\x01') {
      return;
    }
  }
  else {
    if (bit_20_2 != '\x01') {
      if ((bit_20_1 == '\x01') || (bit_20_0 == '\x01')) {
        return;
      }
      return;
    }
    if (bit_20_1 != '\0') {
      if (bit_2E_3 == '\x01') {
        return;
      }
      if (bit_2E_6 == '\x01') {
        return;
      }
      return;
    }
  }
  if (bit_2E_6 != '\0') {
    return;
  }
  if ((bit_2E_5 == '\x01') || (bit_2E_4 != '\0')) {
    return;
  }
  return;
}

/* ---- lcd_build_annunciators  @0x3676  (174 bytes)
 *      (inferred) mode/speed/trigger annunciators (0x00A7/0x00A8) */
void lcd_build_annunciators(void)

{
  char cVar1;
  uint8_t bVar2;
  
  ram_2C = ram_2C & 0xf8;
  if (bit_22_2 != '\0') {
    if (speed_b1 == '\x01') {
      bit_2C_2 = 1;
    }
    else if (speed_b0 == '\x01') {
      bit_2C_1 = 1;
    }
    else {
      bit_2C_0 = 1;
    }
  }
  bit_2C_5 = bit_21_3 & 1 | bit_21_2 & 1;
  bit_2C_6 = xram_00EB >> 4 & 1;
  bVar2 = RXD;
  bit_2E_2 = bVar2 & 1 ^ 1;
  bit_2C_7 = 0;
  ram_2F = ram_2F & 0xc0;
  if (cal_mode != '\0') {
    bit_2F_5 = cal_hot & 1;
    bit_2F_4 = cal_hot & 1 ^ 1;
  }
  ram_2B = ram_2B & 0x42 | xram_00A8;
  bit_2B_7 = meter_autorange & 1 ^ 1;
  if (bit_26_2 != '\x01') {
    if ((xram_00A7 & 1) != 0) {
      bVar2 = xram_00A7;
      if (ram_30 == 0 && ram_31 == 0) {
        out_format_params_b();
        bit_2F_7 = bit_2F_7 ^ 1;
      }
      bit_2F_0 = bit_2F_7 & 1;
      bit_2F_3 = bit_2F_7 & 1 & bVar2 >> 3 & 1;
      return;
    }
    if (((meter_state & 0xf) == 10) &&
       (((bit_2D_3 = 0, bit_21_2 != 1 && (bit_21_3 == 0)) || (trigger_pending != '\0')))) {
      if (ram_30 == 0 && ram_31 == 0) {
        out_format_params_b();
        bit_2F_7 = bit_2F_7 ^ 1;
        if (((bit_2F_7 != 0) && (speed_b0 != '\x01')) && (speed_b1 != '\x01')) {
          cVar1 = '\x03';
          do {
            bVar2 = ram_30 << 1;
            ram_31 = ram_31 << 1 | ram_30 >> 7;
            cVar1 = cVar1 + -1;
            ram_30 = bVar2;
          } while (cVar1 != '\0');
        }
      }
      bit_2D_3 = bit_2F_7 & 1;
    }
    else {
      bit_2F_7 = 0;
      ram_30 = 0;
      ram_31 = 0;
    }
  }
  bit_2F_3 = bit_22_1 & 1;
  return;
}

/* ---- lcd_round_value  @0x3724  (30 bytes) */
void lcd_round_value(uint8_t param_1)

{
  char *pcVar1;
  
  pcVar1 = &ram_5F;
  ram_36 = param_1;
  fp_ld_pow10_r1(0x5b);
  fp_copy_r1_to_r0();
  *pcVar1 = *pcVar1 + -1;
  *pcVar1 = *pcVar1 + -1;
  fp_sub();
  fp_ld_pow10_r1(ram_36);
  fp_add();
  return;
}

/* ---- lcd_set_sign  @0x3742  (9 bytes) */
uint8_t lcd_set_sign(uint8_t param_1)

{
  ram_57 = ram_57 & 0x7f | bit_2A_6 << 7;
  return param_1;
}

/* ---- lcd_insert_unit_char  @0x374B  (20 bytes) */
void lcd_insert_unit_char(char param_1,char param_2)

{
  char cVar1;
  char *pcVar3;
  char *pcVar2;
  
  cVar1 = '\t';
  pcVar2 = (char *)0x7;
  do {
    pcVar3 = pcVar2;
    pcVar2 = pcVar3 + 1;
    cVar1 = cVar1 + -1;
    if (cVar1 == '\0') {
      return;
    }
  } while (*pcVar2 != '#');
  *pcVar2 = param_1;
  pcVar3[2] = param_2;
  return;
}

/* ---- display_timer_init  @0x375F  (20 bytes)
 *      XDATA 0x009F..0x00A3 */
void display_timer_init(void)

{
  xram_009F = 0;
  xram_00A0 = 0x80;
  xram_00A2 = 5;
  xram_00A3 = 5;
  return;
}

/* ---- lcd_clear_flags  @0x3773  (9 bytes) */
void lcd_clear_flags(void)

{
  bit_2C_4 = 0;
  ram_2B = ram_2B & 0xbd;
  ram_2D = ram_2D & 0x30;
  return;
}

/* ---- func_class_check  @0x3785  (34 bytes)
 *      (inferred) C depends on function/peak/dB state */
void func_class_check(void)

{
  uint8_t bVar1;
  
  if (bit_22_0 != '\x01') {
    bVar1 = meter_state & 0xf;
    if (bVar1 == 0) {
      if ((peak_mode_b1 != '\0') && (peak_mode_b0 != '\0')) {
        return;
      }
    }
    else if (((bVar1 != 1) && (bVar1 != 6)) && (bVar1 != 0xb)) {
      return;
    }
  }
  return;
}

/* ---- lcd_decimal_point  @0x37AF  (67 bytes)
 *      (inferred) */
void lcd_decimal_point(uint8_t param_1)

{
  if (bit_20_3 == '\x01') {
    if (bit_20_2 == '\x01') {
      return;
    }
    if (bit_20_1 != '\x01') {
      if (bit_20_0 == '\0') {
        return;
      }
      if ((param_1 >> 2 & 1) == 0) {
        return;
      }
      return;
    }
    if (bit_20_0 != '\0') {
      return;
    }
  }
  else {
    if (bit_20_2 != '\x01') {
      if (param_1 == 0) {
        return;
      }
      return;
    }
    if (bit_20_1 == '\x01') {
      if (bit_2E_3 == '\x01') {
        return;
      }
      if ((param_1 >> 2 & 1) == 0) {
        return;
      }
      return;
    }
  }
  if ((param_1 >> 2 & 1) != 0) {
    return;
  }
  if (param_1 == 0) {
    return;
  }
  return;
}

/* ---- lcd_show_msg_thunk  @0x37F2  (3 bytes) */
void lcd_show_msg_thunk(void)

{
  char cVar1;
  uint8_t uVar2;
  char cVar3;
  char cVar4;
  char *pcVar5;
  
  lcd_copy_message();
  uVar2 = ram_2E;
  if ((meter_state & 0xf) == 0xd) {
    return;
  }
  if (bit_22_0 == '\0') {
    ram_2E = meter_state & 0x70;
    bit_2E_3 = bit_25_6 & 1;
    cVar3 = resolution_digits();
    cVar4 = range_decimal_pos(ram_2E >> 4);
  }
  else {
    cVar3 = '\x04';
    cVar4 = -3;
  }
  pcVar5 = (char *)0x1;
  for (; cVar4 != '\0'; cVar4 = cVar4 + '\x01') {
    pcVar5 = pcVar5 + 1;
    cVar3 = cVar3 + -1;
  }
  cVar4 = *pcVar5;
  *pcVar5 = '.';
  for (; pcVar5 = pcVar5 + 1, cVar3 != '\0'; cVar3 = cVar3 + -1) {
    cVar1 = *pcVar5;
    *pcVar5 = cVar4;
    cVar4 = cVar1;
  }
  while (cVar4 != '#') {
    cVar3 = cVar4;
    if (cVar4 == '-') {
      cVar3 = ' ';
    }
    if (cVar3 == '0') {
      cVar3 = ' ';
    }
    cVar4 = *pcVar5;
    *pcVar5 = cVar3;
    pcVar5 = pcVar5 + 1;
  }
  *pcVar5 = '#';
  ram_2E = uVar2;
  return;
}

/* ---- lcd_refresh  @0x37F5  (90 bytes) */
void lcd_refresh(void)

{
  char cVar1;
  uint8_t uVar2;
  char cVar3;
  char cVar4;
  char *pcVar5;
  
  uVar2 = ram_2E;
  if ((meter_state & 0xf) == 0xd) {
    return;
  }
  if (bit_22_0 == '\0') {
    ram_2E = meter_state & 0x70;
    bit_2E_3 = bit_25_6 & 1;
    cVar3 = resolution_digits();
    cVar4 = range_decimal_pos(ram_2E >> 4);
  }
  else {
    cVar3 = '\x04';
    cVar4 = -3;
  }
  pcVar5 = (char *)0x1;
  for (; cVar4 != '\0'; cVar4 = cVar4 + '\x01') {
    pcVar5 = pcVar5 + 1;
    cVar3 = cVar3 + -1;
  }
  cVar4 = *pcVar5;
  *pcVar5 = '.';
  for (; pcVar5 = pcVar5 + 1, cVar3 != '\0'; cVar3 = cVar3 + -1) {
    cVar1 = *pcVar5;
    *pcVar5 = cVar4;
    cVar4 = cVar1;
  }
  while (cVar4 != '#') {
    cVar3 = cVar4;
    if (cVar4 == '-') {
      cVar3 = ' ';
    }
    if (cVar3 == '0') {
      cVar3 = ' ';
    }
    cVar4 = *pcVar5;
    *pcVar5 = cVar3;
    pcVar5 = pcVar5 + 1;
  }
  *pcVar5 = '#';
  ram_2E = uVar2;
  return;
}

/* ---- resolution_digits  @0x384F  (43 bytes)
 *      digits per function/speed, table 0x6E40 (also used by RSL ?) */
char resolution_digits(void)

{
  char cVar1;
  char cVar2;
  
  cVar1 = func_to_cmd_index();
  cVar2 = (&resolution_table)[(meter_mode & 3) + cVar1 * '\x03'];
  if (((cVar1 == '\a') && ((ram_2E & 0x70) == 0x60)) ||
     ((cVar1 == '\x0e' && ((ram_2E & 0x70) == 0x70)))) {
    cVar2 = cVar2 + -1;
  }
  return cVar2;
}

/* ---- out_format_params_a  @0x38A2  (46 bytes)
 *      (inferred) field parameters depending on interface/function */
void out_format_params_a(void)

{
  if (iface_chan_hi == '\0' && iface_chan_lo == '\0') {
    if ((meter_state & 0xf) == 0) {
      ram_30 = 0x30;
      ram_31 = 0;
      return;
    }
    ram_30 = 0;
    ram_31 = 3;
    return;
  }
  if ((meter_state & 0xf) == 0) {
    ram_30 = 0x18;
    ram_31 = 0;
    return;
  }
  ram_30 = 0x50;
  ram_31 = 1;
  return;
}

/* ---- out_format_params_b  @0x38D0  (46 bytes) */
void out_format_params_b(void)

{
  if (iface_chan_hi == '\0' && iface_chan_lo == '\0') {
    if ((meter_state & 0xf) == 0) {
      ram_30 = 8;
      ram_31 = 0;
      return;
    }
    ram_30 = 0xe0;
    ram_31 = 0;
    return;
  }
  if ((meter_state & 0xf) == 0) {
    ram_30 = 8;
    ram_31 = 0;
    return;
  }
  ram_30 = 0x70;
  ram_31 = 0;
  return;
}

/* ---- lcd_prepare_value  @0x38FE  (290 bytes)
 *      (inferred) result (0x00F2) -> display value with range/resolution */
void lcd_prepare_value(uint8_t param_1)

{
  uint8_t *pbVar1;
  uint8_t bVar2;
  char cVar3;
  char cVar4;
  char cVar5;
  uint8_t *puVar6;
  
  bit_2E_0 = 1;
  bVar2 = meter_state & 0xf;
  if (bVar2 == 8) {
    if ((bit_26_7 != '\0') && (ram_32 = ram_32 + 1, ram_32 == 0xf)) {
      ram_32 = 0;
    }
    puVar6 = &rom_3A91;
    goto LAB_CODE_3a11;
  }
  if (bVar2 == 0xd) {
    if (bit_26_7 != '\0') {
      pbVar1 = &ram_57;
      fp_ld_xdata_r0(0xf2);
      ram_57 = ram_57 & 0x7f;
      bVar2 = *pbVar1 - 0x3e;
      if ((char)bVar2 < '\0') {
        ram_32 = 0;
      }
      else {
        *pbVar1 = bVar2;
        ram_32 = bVar2 & 7;
        if (ram_32 != ram_57) {
          ram_32 = 8;
        }
      }
    }
    puVar6 = &rom_3ACD;
    goto LAB_CODE_3a11;
  }
  if (bit_22_1 != '\0') {
    if (bit_26_7 != '\0') {
      bVar2 = lcd_scale_value();
      if (bit_2A_6 != 0) {
        bVar2 = ~bVar2 + 1;
      }
      ram_32 = bVar2 + 7;
    }
    puVar6 = &rom_3AAF;
    goto LAB_CODE_3a11;
  }
  if ((bVar2 == 10) || (bVar2 == 0xb)) {
    bit_2E_0 = 0;
    return;
  }
  if (bit_26_7 == '\x01') {
    if (bit_2E_1 == '\x01') {
      pbVar1 = &ram_5B;
      fp_ld_xdata_r0(0x1a6);
      fp_copy_r0_to_r1(0x5f);
      bVar2 = (*pbVar1 & 0x7f) - 7;
      if (6 < (*pbVar1 & 0x7f)) {
        bVar2 = 0;
      }
      *pbVar1 = bVar2;
      bVar2 = (ram_2E & 0x70) >> 4;
      lcd_decimal_point(bVar2);
      bit_2E_3 = bit_25_6 & 1;
      cVar3 = range_decimal_pos(bVar2);
      cVar4 = resolution_digits();
      if ((speed_b0 != '\x01') && (speed_b1 != '\x01')) {
        cVar4 = cVar4 + -1;
      }
      cVar5 = (param_1 < (uint8_t)(cVar4 + cVar3)) << 7;
      fp_ld_pow10_r1((param_1 - (cVar4 + cVar3)) + '\x01',0x5b,0x57);
      fp_cmp();
      if (cVar5 < '\0') {
        fp_copy_r1_to_r0();
      }
      pbVar1 = &ram_5F;
      fp_ld_xdata_r1(0xf2,0x57);
      fp_sub();
      bit_2A_6 = *pbVar1 >> 7;
      cVar3 = bit_2A_6 << 7;
      *pbVar1 = *pbVar1 & 0x7f;
      fp_cmp(0x5b);
      if (cVar3 < '\0') goto LAB_CODE_3a0e;
      if (bit_2A_6 == 0) {
        ram_32 = ram_32 - 1;
        if (ram_32 == 0xff) {
          ram_32 = 0xe;
        }
      }
      else {
        ram_32 = ram_32 + 1;
        if (ram_32 == 0xf) {
          ram_32 = 0;
        }
      }
    }
    else {
      ram_32 = 0xe;
    }
    fp_ld_xdata_r0(0xf2,0x57);
    fp_st_r0_xdata(0x1a6);
    bit_2E_1 = '\x01';
  }
  else if (bit_2E_1 == '\0') {
    ram_32 = 0;
    puVar6 = &rom_3ADD;
    goto LAB_CODE_3a11;
  }
LAB_CODE_3a0e:
  puVar6 = &rom_3A91;
LAB_CODE_3a11:
  bVar2 = ram_32 << 1 | ram_32 >> 7;
  ram_34 = puVar6[bVar2];
  ram_33 = puVar6[bVar2 + 1];
  bit_26_7 = 0;
  return;
}

/* ---- lcd_scale_value  @0x3A20  (89 bytes)
 *      (inferred) */
uint8_t lcd_scale_value(void)

{
  uint8_t *pbVar1;
  char cVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  
  pbVar1 = &ram_57;
  fp_ld_xdata_r0(0xf2);
  if (bit_22_0 == '\0') {
    digits_for_range();
    if (((uint8_t)(&rom_6F14)[meter_state & 0xf] >> 5 & 1) != 0) {
      ram_3D = ram_3D + -1;
    }
    cVar2 = resolution_digits();
    fp_ld_pow10_r1(cVar2 + -1,0x3d,0x5b);
    fp_div();
    pbVar1 = &ram_57;
    fp_div(0x3d);
  }
  else {
    fp_ld_pow10_r1(1,0x3d);
    fp_mul();
  }
  bit_2A_6 = *pbVar1 >> 7;
  bVar3 = *pbVar1 & 0x7f;
  bVar4 = bVar3 - 0x3f;
  if (bit_22_0 != '\x01') {
    bVar4 = bVar3 + 0xbd;
  }
  if ((char)bVar4 < '\0') {
    return 0;
  }
  if ((bVar4 != 7) && (6 < bVar4)) {
    bVar4 = 7;
  }
  return bVar4;
}

/* ---- lcd_show_dashes  @0x3B58  (16 bytes)
 *      " -------" */
void lcd_show_dashes(void)

{
  if (bit_26_1 == '\0') {
    lcd_show_message(&msg_table);
    lcd_refresh();
  }
  return;
}

/* ---- lcd_show_error  @0x54D7  (10 bytes) */
void lcd_show_error(void)

{
  if (bit_26_1 != '\x01') {
    lcd_show_message(0x7111);
  }
  return;
}

/* ---- lcd_send_frame  @0x5549  (601 bytes)
 *      text buffer XDATA 0x0000 -> segments; header C8 86 E0 F8 70, 13 data bytes, annunciators */
void lcd_send_frame(void)

{
  uint8_t *puVar1;
  char cVar2;
  uint8_t uVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  code cVar6;
  uint8_t *pbVar7;
  code *pcVar8;
  
  bVar4 = 0;
  if (iface_chan_hi != '\0' || iface_chan_lo != '\0') {
    pbVar7 = (uint8_t *)(CONCAT11(iface_chan_hi,iface_chan_lo) + 1);
    if (xram_005A == '\0') {
      bVar5 = *pbVar7 & 0x38;
      if (bVar5 == 0x18) {
        bVar4 = 0x20;
      }
      else {
        if (bVar5 != 0x38) {
          if (bVar5 >> 5 != 0) {
            bVar4 = 0x10;
          }
          if ((bVar5 >> 4 & 1) != 0) {
            bVar4 = bVar4 | 0x20;
          }
          if ((bVar5 >> 3 & 1) != 0) {
            bVar4 = bVar4 | 0x40;
          }
          goto LAB_CODE_55b0;
        }
        bVar4 = 0x40;
      }
      bVar4 = bVar4 | 0x80;
    }
    else if (xram_005A != '\x05') {
      if ((*pbVar7 & 0x18) == 0x10) {
        bVar4 = 0x20;
      }
      else {
        bVar5 = bVar4;
        if ((((((*(uint8_t *)(CONCAT11(iface_chan_hi,iface_chan_lo) + 2) >> 5 & 1) == 1) ||
              (emo_continuous == '\x01')) ||
             (cVar2 = xdata_is_zero3(0x95,xram_005A), bVar5 = bVar4, cVar2 != '\0')) ||
            (reply_pending_cmd != '\0')) && (bVar4 = bVar5 | 0x40, bit_23_3 != '\0')) {
          bVar4 = bVar5 | 0xc0;
        }
      }
    }
  }
LAB_CODE_55b0:
  puVar1 = &ram_36;
  cVar2 = '\f';
  uVar3 = 7;
  if (lcd_text_buf == '+') {
    bVar4 = bVar4 | 6;
  }
  else if (lcd_text_buf == '-') {
    bVar4 = bVar4 | 2;
  }
  pcVar8 = start + 1;
  cVar6 = cEXTMEM0001;
  while (cVar6 == (code)0x2e) {
    bVar4 = bVar4 | 1;
    pcVar8 = pcVar8 + 1;
    cVar6 = *pcVar8;
  }
  if (cVar6 == (code)0x51) {
    ram_36 = 0xfe;
    puVar1 = &ram_37;
    uVar3 = 6;
    pcVar8 = pcVar8 + 1;
    cVar6 = *pcVar8;
  }
  bVar5 = bVar4 & 0xfe;
  F0 = 0;
  lcd_encode_chars(cVar6,bVar5,uVar3,0x58);
  if (bit_2E_0 == '\0') {
    *puVar1 = 0;
    puVar1['\x01'] = 0;
  }
  else {
    *puVar1 = ram_33;
    puVar1['\x01'] = ram_34;
  }
  puVar1 = puVar1 + '\x02';
  F0 = 0;
  lcd_encode_chars(*pcVar8,bVar5 | 1,2,cVar2 + '`');
  i2cB_start_write(0x70);
  i2cB_send_byte(200);
  i2cB_send_byte(0x86);
  i2cB_send_byte(0xe0);
  i2cB_send_byte(0xf8);
  i2cB_send_byte(0x70);
  cVar2 = '\r';
  do {
    puVar1 = puVar1 + -1;
    i2cB_send_byte(*puVar1);
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  bVar5 = 0;
  if ((bVar4 & 1) != 0) {
    bVar5 = 0x80;
  }
  if ((bVar4 >> 1 & 1) != 0) {
    bVar5 = bVar5 | 0x40;
  }
  if ((bVar4 >> 4 & 1) != 0) {
    bVar5 = bVar5 | 0x20;
  }
  if (bit_2D_5 != '\0') {
    bVar5 = bVar5 | 0x10;
  }
  if (bit_2E_2 != '\0') {
    bVar5 = bVar5 | 8;
  }
  if ((bVar4 >> 2 & 1) != 0) {
    bVar5 = bVar5 | 4;
  }
  if (bit_2C_6 != '\0') {
    bVar5 = bVar5 | 2;
  }
  if (bit_2C_7 != '\0') {
    bVar5 = bVar5 | 1;
  }
  i2cB_send_byte(bVar5);
  bVar5 = 0;
  if (bit_2F_0 != '\0') {
    bVar5 = 0x20;
  }
  if (bit_2F_3 != '\0') {
    bVar5 = bVar5 | 0x10;
  }
  if (bit_2B_5 != '\0') {
    bVar5 = bVar5 | 8;
  }
  if (bit_2C_5 != '\0') {
    bVar5 = bVar5 | 4;
  }
  if ((bVar4 >> 5 & 1) != 0) {
    bVar5 = bVar5 | 2;
  }
  if (bit_2B_7 != '\0') {
    bVar5 = bVar5 | 1;
  }
  i2cB_send_byte(bVar5);
  bVar5 = 0;
  if (bit_22_2 != '\0') {
    bVar5 = 0x80;
  }
  if (bit_2C_0 != '\0') {
    bVar5 = bVar5 | 0x40;
  }
  if ((bVar4 >> 6 & 1) != 0) {
    bVar5 = bVar5 | 0x20;
  }
  if (bit_2C_1 != '\0') {
    bVar5 = bVar5 | 0x10;
  }
  if (bit_2B_4 != '\0') {
    bVar5 = bVar5 | 8;
  }
  if (bit_2C_7 != '\0') {
    bVar5 = bVar5 | 4;
  }
  if ((char)bVar4 < '\0') {
    bVar5 = bVar5 | 2;
  }
  if (bit_2C_2 != '\0') {
    bVar5 = bVar5 | 1;
  }
  i2cB_send_byte(bVar5);
  bVar5 = 0;
  if (bit_2C_7 != '\0') {
    bVar5 = 0xc0;
  }
  if (bit_2E_0 != '\0') {
    bVar5 = bVar5 | 0x20;
  }
  if (bit_2F_4 != '\0') {
    bVar5 = bVar5 | 0x10;
  }
  if (bit_2F_5 != '\0') {
    bVar5 = bVar5 | 8;
  }
  if (bit_25_7 != '\0') {
    bVar5 = bVar5 | 4;
  }
  if (bit_2B_6 != '\0') {
    bVar5 = bVar5 | 2;
  }
  if (bit_24_6 != '\0') {
    bVar5 = bVar5 | 1;
  }
  i2cB_send_byte(bVar5);
  i2cB_stop();
  i2cB_start_write(0x70);
  i2cB_send_byte(200);
  i2cB_send_byte(0x80);
  i2cB_send_byte(0xe0);
  i2cB_send_byte(0xf8);
  i2cB_send_byte(0x70);
  bVar5 = 0;
  if (bit_2D_2 != '\0') {
    bVar5 = 0x80;
  }
  if (bit_2D_3 != '\0') {
    bVar5 = bVar5 | 0x40;
  }
  if (bit_2C_7 != '\0') {
    bVar5 = bVar5 | 0x38;
  }
  if (bit_2B_2 != '\0') {
    bVar5 = bVar5 | 4;
  }
  if (bit_2C_7 != '\0') {
    bVar5 = bVar5 | 3;
  }
  i2cB_send_byte(bVar5);
  bVar5 = 0;
  if (bit_2C_7 != '\0') {
    bVar5 = 0x80;
  }
  if (bit_2B_3 != '\0') {
    bVar5 = bVar5 | 0x40;
  }
  if (bit_2C_7 != '\0') {
    bVar5 = bVar5 | 0x20;
  }
  if (cal_enable != '\0') {
    bVar5 = bVar5 | 0x10;
  }
  if (bit_2D_1 != '\0') {
    bVar5 = bVar5 | 4;
  }
  if (bit_2D_7 != '\0') {
    bVar5 = bVar5 | 2;
  }
  if (bit_2B_0 != '\0') {
    bVar5 = bVar5 | 1;
  }
  i2cB_send_byte(bVar5);
  bVar5 = 0;
  if (bit_2C_4 != '\0') {
    bVar5 = 0x80;
  }
  if (bit_2C_7 != '\0') {
    bVar5 = bVar5 | 0x40;
  }
  if (bit_2D_6 != '\0') {
    bVar5 = bVar5 | 0x20;
  }
  if (bit_2D_0 != '\0') {
    bVar5 = bVar5 | 0x10;
  }
  if ((bVar4 >> 3 & 1) != 0) {
    bVar5 = bVar5 | 8;
  }
  if (bit_2B_1 != '\0') {
    bVar5 = bVar5 | 4;
  }
  if ((peak_mode_b0 != '\0') && (bit_24_2 != '\x01')) {
    bVar5 = bVar5 | 2;
  }
  if ((peak_mode_b1 != '\0') && (bit_24_2 != '\x01')) {
    bVar5 = bVar5 | 1;
  }
  i2cB_send_byte(bVar5);
  i2cB_stop();
  return;
}

/* ---- lcd_encode_chars  @0x57A2  (106 bytes)
 *      ASCII -> segment bytes via font, '.' merged into dp */
void lcd_encode_chars(uint8_t param_1,uint8_t *param_2,uint8_t param_3,uint8_t *param_4,uint8_t param_5,
                     char param_6,uint8_t param_7,uint8_t param_8,uint8_t param_9)

{
  char cVar1;
  uint8_t bVar2;
  uint8_t bVar3;
  
  do {
    if (((param_1 < 0x20) << 7 < '\0') ||
       ((((param_3 & 1) == 0 || (0x83 < param_1)) && (0x7f < param_1)))) {
      param_1 = 0x20;
    }
    if (param_1 == 0x2e) {
      F0 = 1;
      param_6 = param_6 + '\x01';
      bVar3 = param_5;
    }
    else {
      if ((param_1 == 0x83) && (F0 = 1, param_4 == &ram_3F)) {
        param_1 = 0x20;
      }
      if (param_4 == &ram_3F) {
        F0 = 0;
      }
      param_1 = param_1 - 0x20;
      if ((param_3 & 1) != 0) {
        param_9 = (param_1 * '\x02' | param_1 >> 7) + 1;
        param_1 = param_9;
      }
      bVar3 = *(uint8_t *)(CONCAT11(param_7,param_8) + (uint16_t)param_1);
      cVar1 = F0;
      bVar2 = bVar3;
      if (cVar1 == '\0') {
LAB_CODE_57f1:
        bVar3 = param_5;
        param_5 = bVar2;
        if ((param_3 & 1) != 0) {
          *param_4 = bVar2;
          param_4 = param_4 + '\x01';
          param_5 = *(uint8_t *)(CONCAT11(param_7,param_8) + (uint16_t)(param_9 - 1));
        }
      }
      else {
        bVar2 = param_5;
        if ((param_3 & 1) != 0) {
          bVar2 = bVar3;
          bVar3 = param_5;
        }
        param_5 = bVar3 | 8;
        bVar3 = bVar2;
        if ((param_3 & 1) != 0) goto LAB_CODE_57f1;
      }
      *param_4 = param_5;
      param_4 = param_4 + '\x01';
      F0 = 0;
    }
    param_2 = param_2 + 1;
    param_1 = *param_2;
    param_6 = param_6 + -1;
    param_5 = bVar3;
    if (param_6 == '\0') {
      return;
    }
  } while( true );
}

/* ---- lcd_show_message  @0x5CA7  (19 bytes)
 *      DPTR -> message in table 0x70E4 ('#'-terminated, 11 chars) */
void lcd_show_message(short param_1)

{
  uint16_t uVar1;
  uint8_t bVar2;
  char *pcVar3;
  
  bit_26_4 = 1;
  bit_24_1 = 1;
  xram_009F = xram_009F & 0xdf;
  bVar2 = 0;
  pcVar3 = (char *)0x0;
  do {
    uVar1 = (uint16_t)bVar2;
    bVar2 = bVar2 + 1;
    *pcVar3 = *(char *)(param_1 + uVar1);
    pcVar3 = pcVar3 + 1;
  } while (*(char *)(param_1 + uVar1) != '#');
  return;
}

/* ---- lcd_copy_message  @0x5CBA  (41 bytes)
 *      '#'-terminated ROM string -> lcd_text_buf */
void lcd_copy_message(short param_1)

{
  uint16_t uVar1;
  uint8_t bVar2;
  char *pcVar3;
  
  bVar2 = 0;
  pcVar3 = (char *)0x0;
  do {
    uVar1 = (uint16_t)bVar2;
    bVar2 = bVar2 + 1;
    *pcVar3 = *(char *)(param_1 + uVar1);
    pcVar3 = pcVar3 + 1;
  } while (*(char *)(param_1 + uVar1) != '#');
  return;
}

