/* keyboard_menu.c - key matrix, key handlers, SHIFT/CHECK edit menus, data-hold probe
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 30 functions, 1800 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/keyboard_menu.c.
 */
#include "pm2525.h"

/* ---- task_display_menu  @0x2AA9  (862 bytes)
 *      1385 B: display/CHECK menu (ADDr, rTL, T.ONLY, Cr, 60H, SOFT, CAL, version) */
void task_display_menu(uint8_t param_1)

{
  uint8_t bVar1;
  char cVar2;
  char cVar3;
  uint8_t uVar4;
  uint16_t uVar5;
  
  if (xram_00C1 < '\0') {
    return;
  }
  xdata_to_iram(0xa5,0x2b,0x19);
  P1_7 = 0;
  P1_7 = 1;
  cVar3 = P1_0;
  if (cVar3 == '\x01') {
LAB_CODE_2acd:
    if (((xram_0012 % 5 == 0) && (bit_2E_5 != '\x01')) && (bit_2E_4 != '\x01')) {
      probe_hold_poll();
    }
    goto LAB_CODE_2feb;
  }
  ram_35 = 0xff;
  key_scan();
  if (ram_35 == 0xff) goto LAB_CODE_2acd;
  bVar1 = meter_state & 0xf;
  if (bit_2E_5 != '\0') {
    if ((xram_00EB >> 4 & 1) == 0) {
      if ((char)(ram_35 - 10) < '\0') goto LAB_CODE_2feb;
                    /* WARNING: Switch is manually overridden */
      switch((ram_35 - 10) * '\x03') {
      case 0:
        if (((cal_mode == '\x01') || (bVar1 == 0)) || ((bVar1 >> 3 == 1 || ((bVar1 >> 2 & 1) == 1)))
           ) goto LAB_CODE_2feb;
        ram_2F = 0x15;
        menu_set_flag();
        bit_2C_0 = 0;
        bit_2D_0 = 1;
        bit_2C_1 = 1;
        bit_24_2 = 1;
        ram_36 = 3;
        menu_show_dbm_ref();
        goto LAB_CODE_2fe9;
      case 3:
        if ((cal_mode != '\x01') && (cVar3 = (bVar1 < 0xd) << 7, bVar1 != 0xd)) {
          ram_2F = 0x16;
          menu_set_flag();
          ram_2D = ram_2D | 9;
          bit_2C_0 = 0;
          func_class_check();
          if (cVar3 < '\0') {
            bit_2C_0 = 1;
          }
          bit_2C_1 = 1;
          bit_24_2 = 0;
          xram_006D = meter_state & 0x70 | bit_25_6 << 7;
          ram_36 = 0;
          if (bit_22_0 != '\0') {
            ram_36 = 3;
          }
          menu_edit_value(0x79);
          return;
        }
        goto LAB_CODE_2feb;
      case 6:
        break;
      case 9:
        bit_26_1 = 1;
        bit_24_2 = 0;
        bit_2E_3 = 1;
        ram_2F = 0x17;
        menu_enter_edit();
        menu_edit_value(0x7d);
        return;
      case 0xc:
        if (cal_enable == '\0') {
LAB_CODE_2d36:
          bit_2D_0 = 1;
          if ((iface_chan_hi != '\0' || iface_chan_lo != '\0') && (xram_005A != '\x05'))
          goto LAB_CODE_2d4c;
LAB_CODE_2d45:
          ram_2F = 0x24;
          uVar5 = 0x716c;
        }
        else {
          ram_2F = 0x1e;
          uVar5 = 0x7193;
        }
        goto LAB_CODE_2d51;
      case 0xf:
      }
      ram_2E = ram_2E & 0xde;
    }
    else {
      if (ram_35 != 0xe) {
LAB_CODE_3058:
        ram_30 = 0;
        ram_2B = 0;
        ram_2C = 0;
        ram_2D = 0;
        ram_2E = 0;
        ram_26 = ram_26 & 0xfc;
        goto LAB_CODE_2feb;
      }
LAB_CODE_2d4c:
      ram_2F = 0x29;
      uVar5 = 0x712b;
LAB_CODE_2d51:
      menu_show_step(uVar5);
      menu_enter_edit();
      if (ram_2F == 0x24) {
        bit_2B_0 = mains_60hz & 1 ^ 1;
        if (-1 < (char)(bit_2B_0 << 7)) {
          ram_3E = 0x31;
        }
      }
      else if ((ram_2F == 0x1e) && (bit_2B_0 = cal_hot & 1 ^ 1, -1 < (char)(bit_2B_0 << 7))) {
        ram_3D = 0x31;
      }
      bit_2B_4 = '\x01';
      bit_24_2 = 1;
LAB_CODE_2fce:
      menu_store_text();
    }
LAB_CODE_2fe9:
    bit_24_1 = 1;
    goto LAB_CODE_2feb;
  }
  if (bit_2E_4 != '\0') {
    if ((xram_00EB >> 4 & 1) == 0) {
      if (bit_2B_4 != '\0') goto LAB_CODE_2e7d;
      cVar3 = (ram_2F < 0x15) << 7;
      if (ram_2F == 0x15) {
        menu_edit_digits();
        if (bit_2B_7 == '\x01') {
          if (bit_2B_0 == 1) goto LAB_CODE_2e2a;
          menu_parse_number();
          fp_ld_code_r1(0x6fd4,0x5b);
          fp_cmp();
          if (-1 < cVar3) {
            fp_ld_code_r1(0x6fd8,0x5b);
            cVar2 = fp_cmp();
            if ((cVar2 == '\0') || (cVar3 < '\0')) {
              menu_clear_state();
              goto LAB_CODE_2e27;
            }
          }
          menu_set_flag();
          code_to_iram_copy(0x7186,0x38,9);
          ram_41 = 0x83;
        }
        else if (bit_2C_2 == 1) {
          range_lim_down = 0x83;
        }
        else {
          ram_41 = 0x83;
        }
      }
      else {
        cVar3 = (ram_2F < 0x16) << 7;
        if (ram_2F != 0x16) {
          if (bit_2E_3 == '\0') {
            if (bit_2E_2 == '\0') goto LAB_CODE_3058;
            if (ram_35 == 0xc) {
              bit_2E_2 = '\0';
              menu_clear_state();
              goto LAB_CODE_2feb;
            }
            if (ram_35 != 0xf) goto LAB_CODE_2feb;
            ram_2F = 0x2e;
          }
          else {
            if (ram_35 == 0xc) {
              bit_2E_2 = 1;
              bit_2E_3 = 0;
              ram_2F = 0x18;
              menu_edit_value(0x81);
              return;
            }
            if (ram_35 != 0xf) goto LAB_CODE_2feb;
            ram_2F = 0x2d;
          }
          goto LAB_CODE_2fda;
        }
        bit_26_0 = 0;
        menu_edit_digits();
        if (bit_2B_7 != '\0') {
          if (bit_2B_0 != 1) {
            menu_parse_number();
            if (bit_22_0 == '\0') {
              lcd_decimal_point((xram_00A0 & 0x70) >> 4);
              fp_ld_pow10_r1(param_1,0x34,0x5f);
              fp_mul();
            }
            else {
              fp_ld_pow10_r1(3,0x34,0x5f);
              fp_cmp();
              if (-1 < cVar3) {
                menu_start_blank();
                goto LAB_CODE_2fce;
              }
            }
          }
LAB_CODE_2e27:
          ram_30 = 0xa4;
LAB_CODE_2e2a:
          ram_2D = ram_2D & 0xf6;
          menu_clear_state();
          goto LAB_CODE_2feb;
        }
        if ((ram_35 == 0xf) || (-1 < (char)((bit_2C_2 & 1 | bit_2C_6) << 7))) {
          ram_40 = 0x23;
        }
        else {
          ram_41 = 0x23;
        }
      }
      goto LAB_CODE_2fce;
    }
    if (bit_2B_4 != '\x01') goto LAB_CODE_3058;
LAB_CODE_2e7d:
    if ((ram_35 == 0xf) && (bit_2C_6 != 0)) {
      if ((cal_mode != '\0') && (ram_2F == 0x1e)) {
        ram_30 = 0xa0;
      }
    }
    else {
      if (ram_2F != 0x1e) {
        if (ram_2F == 0x29) {
          if (ram_35 != 0xc) goto LAB_CODE_2efe;
          if (bit_2C_6 == 0) goto LAB_CODE_2ef2;
          if ((xram_00EB >> 4 & 1) != 0) goto LAB_CODE_2fd3;
          ram_2F = 0x28;
          menu_show_step(0x7138);
          bit_2B_0 = 0;
          if (xram_005A == '\0') {
            if ((iface_chan_lo == 'S') && (iface_chan_hi == '\0')) {
              if ((xram_0054 & 0x38) == 0x38) {
LAB_CODE_2ee1:
                ram_40 = 0x31;
                bit_2B_0 = 1;
              }
            }
            else {
              cVar3 = nv_get_iface_config();
              if (cVar3 < '\0') goto LAB_CODE_2ee1;
            }
          }
          else if (bit_23_3 == '\x01') goto LAB_CODE_2ee1;
        }
        else if (ram_2F == 0x28) {
          if (ram_35 == 0xc) {
            if (bit_2C_6 == 0) goto LAB_CODE_2ef2;
            if (xram_005A != '\0') goto LAB_CODE_2f45;
            ram_2F = 0x26;
            menu_show_step(0x711e);
            bVar1 = nv_get_iface_config();
            ram_31 = bVar1 & 0x1f;
            put_2digits_iram(0x3e);
          }
          else {
            uVar4 = menu_key_to_char();
            if (bit_2B_7 != '\0') {
              ram_40 = uVar4;
            }
          }
        }
        else if (ram_2F == 0x26) {
          if (ram_35 == 0xc) {
            if (bit_2C_6 == 0) {
              if (bit_2B_0 == 0) goto LAB_CODE_2f5e;
              goto LAB_CODE_2fd3;
            }
LAB_CODE_2f45:
            ram_2F = 0x25;
            menu_show_step(0x7145);
            if (cr_enabled != '\0') {
              ram_3E = 0x31;
              bit_2B_0 = 0;
            }
          }
          else if (ram_35 == 0xf) {
            menu_show_step(0x711e);
          }
          else {
            menu_digit_key(0x3e);
            if ((ram_31 != 0x1e) && (0x1d < ram_31)) {
              menu_show_step(0x711e);
            }
          }
        }
        else if (ram_2F == 0x25) {
          if (ram_35 == 0xc) {
            if (bit_2C_6 != 0) goto LAB_CODE_2d45;
LAB_CODE_2ef2:
            ram_30 = 0xa0;
            if (bit_2B_0 != 1) {
              ram_30 = 0xa1;
            }
            goto LAB_CODE_2fd3;
          }
LAB_CODE_2fbb:
          uVar4 = menu_key_to_char();
          if (bit_2B_7 != '\0') {
            ram_3E = uVar4;
          }
        }
        else if (ram_2F == 0x24) {
          if (ram_35 != 0xc) goto LAB_CODE_2fbb;
          if (bit_2C_6 == 0) goto LAB_CODE_2ef2;
          ram_2F = 200;
          menu_show_step(0x7179);
          ram_3E = rom_59AF;
          ram_3F = rom_59B0;
          bit_2D_0 = 0;
        }
        else {
          if (ram_2F != 200) goto LAB_CODE_2fd3;
          if (ram_35 == 0xc) goto LAB_CODE_2d36;
        }
        goto LAB_CODE_2fce;
      }
      if (ram_35 != 0xc) {
LAB_CODE_2efe:
        uVar4 = menu_key_to_char();
        if (bit_2B_7 != '\0') {
          ram_3D = uVar4;
        }
        goto LAB_CODE_2fce;
      }
      ram_30 = 0xa2;
      ram_31 = bit_2B_0 & 1 ^ 1;
    }
LAB_CODE_2fd3:
    bit_2B_4 = '\0';
    menu_clear_state();
    goto LAB_CODE_2feb;
  }
  if ((iface_chan_hi != '\0' || iface_chan_lo != '\0') &&
     (((cal_mode == '\0' || (ram_35 != 0xb)) && ((xram_00EB >> 4 & 1) != 0)))) {
    if (((char)xram_00EB < '\0') || (ram_35 != 0xc)) goto LAB_CODE_2feb;
key_12_status:
    ram_2E = ram_2E | 0x21;
    goto LAB_CODE_2fe9;
  }
  if (bit_26_2 != '\0') {
    bit_26_2 = '\0';
    menu_clear_state();
  }
  uVar4 = (uint8_t)((uint16_t)ram_35 * 3 >> 8);
                    /* WARNING: Switch is manually overridden */
  switch((uint16_t)ram_35 * 3 & 0xff) {
  case 0:
    if (bVar1 != 1) {
      ram_2F = 3;
      break;
    }
    if (cal_mode != '\0') goto LAB_CODE_2feb;
    ram_2F = 0x1a;
    if (speed_b1 == '\x01') {
      ram_31 = 2;
    }
    else if (speed_b0 == '\x01') {
      ram_31 = 1;
    }
    else {
      ram_31 = 3;
    }
LAB_CODE_2f5e:
    ram_30 = 0xa2;
    goto LAB_CODE_2fd3;
  case 3:
    if (bVar1 == 2) {
      ram_2F = 5;
    }
    else {
      ram_2F = 4;
    }
    break;
  case 6:
    if (peak_mode_b0 == '\0') {
      ram_2F = 2;
    }
    else if (peak_mode_b1 == '\0') {
      ram_2F = 1;
    }
    else {
      ram_2F = 0;
    }
    break;
  case 9:
    if (bVar1 == 5) {
      ram_2F = 0x12;
    }
    else {
      ram_2F = 7;
    }
    break;
  case 0xc:
    if (bVar1 == 4) {
      ram_2F = 0x10;
    }
    else {
      ram_2F = 6;
    }
    break;
  case 0xf:
    ram_2F = 8;
    break;
  case 0x12:
    ram_2F = 9;
    break;
  case 0x15:
    if (bVar1 == 9) {
      ram_2F = 0x11;
    }
    else {
      ram_2F = 0xe;
    }
    break;
  case 0x18:
    if (bVar1 == 10) {
      if (cal_mode != '\0') goto LAB_CODE_2feb;
      ram_2F = 0x1a;
      if ((speed_b0 == '\x01') || (speed_b1 == '\x01')) {
        ram_31 = 1;
      }
      else {
        ram_31 = 2;
      }
      goto LAB_CODE_2f5e;
    }
    ram_2F = 0xf;
    break;
  case 0x1b:
    if (bVar1 == 8) {
      if (time_stop_negslope == '\x01') {
        if (time_start_negslope == '\x01') goto LAB_CODE_2c16;
        ram_2F = 0xc;
      }
      else if (time_start_negslope == '\x01') {
        ram_2F = 0xd;
      }
      else {
        ram_2F = 0xb;
      }
    }
    else {
LAB_CODE_2c16:
      ram_2F = 10;
    }
    break;
  case 0x1e:
    if (((cal_mode == '\x01') || (bit_20_3 == '\x01')) || ((bit_20_2 == '\x01' || (bVar1 == 0))))
    goto LAB_CODE_2feb;
    ram_2F = 0x15;
    if (bit_22_0 != '\x01') {
      ram_30 = 0xa4;
      bit_24_2 = 1;
      ram_26 = ram_26 | 6;
      menu_show_dbm_ref();
      goto LAB_CODE_2fe9;
    }
    goto LAB_CODE_2c8a;
  case 0x21:
    if (cal_mode == '\0') {
      if (bVar1 == 0xd) goto LAB_CODE_2feb;
      ram_2F = 0x16;
      if (bit_22_1 != '\x01') {
        ram_30 = 0xa4;
        bit_24_2 = 0;
        ram_26 = ram_26 | 6;
        if (bit_26_5 != '\x01') {
          menu_edit_value(0x79,uVar4);
          return;
        }
        uVar5 = 0x91;
        if (bit_22_0 != '\0') {
          uVar5 = 0x8d;
        }
        menu_edit_value(uVar5,uVar4);
        return;
      }
      goto LAB_CODE_2c8a;
    }
    if (bit_21_3 == '\0') goto LAB_CODE_2feb;
    ram_2F = 0x1d;
    break;
  case 0x24:
    goto key_12_status;
  case 0x27:
    ram_2F = 0x2a;
    goto LAB_CODE_2fe4;
  case 0x2a:
    ram_2F = 0x2b;
LAB_CODE_2fe4:
    ram_30 = 0xa1;
    goto LAB_CODE_2feb;
  case 0x2d:
    if (cal_mode != '\0') goto LAB_CODE_2feb;
    ram_2F = 0x2c;
    if (meter_autorange != '\x01') goto LAB_CODE_2fe4;
LAB_CODE_2c8a:
    ram_30 = 0xa0;
    goto LAB_CODE_2feb;
  }
LAB_CODE_2fda:
  ram_30 = 0xa5;
LAB_CODE_2feb:
  iram_to_xdata(0xa5,0x2b,0x19);
  return;
}

/* ---- menu_key_to_char  @0x2FF5  (30 bytes) */
uint8_t menu_key_to_char(uint8_t param_1)

{
  bit_2B_7 = 1;
  if (param_1 == 0xf) {
    bit_2C_6 = 1;
    return 0x2d;
  }
  if (param_1 == 0) {
    bit_2B_0 = 1;
  }
  else {
    if (param_1 != 1) {
      bit_2B_7 = 0;
      return param_1;
    }
    bit_2B_0 = 0;
  }
  bit_2C_6 = 0;
  return param_1 | 0x30;
}

/* ---- menu_show_step  @0x3013  (15 bytes)
 *      show a CHECK/edit menu message */
void menu_show_step(void)

{
  bit_2C_6 = 1;
  bit_2B_7 = 0;
  bit_2C_3 = 0;
  bit_2B_0 = 1;
  code_to_iram_copy(0x38,0xc);
  return;
}

/* ---- menu_exit_a  @0x3022  (9 bytes)
 *      save menu context (IRAM 2Bh.. -> XDATA 0x00A5) and leave */
void menu_exit_a(void)

{
  if ((xram_00A8 & 1) == 1) {
    lcd_dashes_refresh();
    bit_24_2 = 0;
    ram_30 = 0;
    ram_2B = 0;
    ram_2C = 0;
    ram_2D = 0;
    ram_2E = 0;
    ram_26 = ram_26 & 0xfc;
    iram_to_xdata(0xa5,0x2b,0x19);
    return;
  }
  xram_00AA = 0;
  return;
}

/* ---- menu_exit_b  @0x302B  (39 bytes) */
void menu_exit_b(void)

{
  if ((xram_00A8 & 1) == 1) {
    if (((xram_00A8 >> 4 & 1) != 0) &&
       (((xram_00A5 >> 4 & 1) == 0 || (xram_00A9 != ')')))) {
      lcd_dashes_refresh();
      bit_24_2 = 0;
      ram_30 = 0;
      ram_2B = 0;
      ram_2C = 0;
      ram_2D = 0;
      ram_2E = 0;
      ram_26 = ram_26 & 0xfc;
      iram_to_xdata(0xa5,0x2b,0x19);
      return;
    }
  }
  else {
    xram_00AA = 0;
  }
  return;
}

/* ---- menu_init  @0x3052  (24 bytes) */
void menu_init(void)

{
  ram_35 = 0xff;
  key_scan();
  ram_30 = 0;
  ram_2B = 0;
  ram_2C = 0;
  ram_2D = 0;
  ram_2E = 0;
  ram_26 = ram_26 & 0xfc;
  iram_to_xdata(0xa5,0x2b,0x19);
  return;
}

/* ---- menu_clear_state  @0x306A  (10 bytes) */
void menu_clear_state(void)

{
  ram_2E = ram_2E & 0xce;
  bit_2D_0 = 0;
  ram_26 = ram_26 & 0xfc;
  bit_24_2 = 0;
  lcd_show_message(&msg_table);
  lcd_refresh();
  return;
}

/* ---- menu_show_dbm_ref  @0x307D  (45 bytes)
 *      format the dB reference (XDATA 0x0075) for the edit menu */
void menu_show_dbm_ref(void)

{
  fp_ld_xdata_r1(0x75,0x34);
  fp_format(0x20,0,0x34,0x5b,100,0);
  bit_26_0 = 0;
  xram_0009 = 0x20;
  xram_000A = 0x83;
  fp_ld_xdata_r1(0x75,0x34);
  return;
}

/* ---- menu_set_flag  @0x30AA  (2 bytes) */
void menu_set_flag(void)

{
  bit_2D_0 = 1;
  bit_2E_4 = 1;
  bit_2C_6 = 1;
  bit_2B_0 = 1;
  ram_26 = ram_26 | 0x12;
  bit_2E_5 = 0;
  bit_2B_7 = 0;
  ram_2C = ram_2C & 0xf3;
  ram_37 = 0;
  ram_43 = 0x3d;
  return;
}

/* ---- menu_enter_edit  @0x30AC  (23 bytes) */
void menu_enter_edit(void)

{
  bit_2E_4 = 1;
  bit_2C_6 = 1;
  bit_2B_0 = 1;
  ram_26 = ram_26 | 0x12;
  bit_2E_5 = 0;
  bit_2B_7 = 0;
  ram_2C = ram_2C & 0xf3;
  ram_37 = 0;
  ram_43 = 0x3d;
  return;
}

/* ---- menu_edit_digits  @0x30C3  (57 bytes)
 *      (inferred) digit entry in the SHIFT edit menus */
void menu_edit_digits(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  
  if (ram_35 == 0xc) {
    bit_2B_7 = 1;
    return;
  }
  if (ram_35 == 0xb) {
    if ((bit_2C_1 != '\0') && (bit_2C_2 != '\x01')) {
      menu_blink_cursor();
      bit_2C_2 = '\x01';
      bVar1 = 0x2e;
      ram_40 = 0x20;
LAB_CODE_311e:
      ram_37 = ram_37 + '\x01';
      bVar2 = ram_36 + ram_37;
      if (((bVar2 == 7) || (bVar2 < 7)) || ((bit_2C_2 != '\0' && (bVar2 == 8)))) {
        *(uint8_t *)(bVar2 + 0x38) = bVar1;
        return;
      }
      bit_2C_3 = 1;
      bit_2C_2 = 1;
      return;
    }
  }
  else if (ram_35 == 10) {
    if (bit_2C_0 != '\0') {
      menu_load_text();
      bit_2B_0 = 0;
      if (ram_38 == '-') {
        ram_38 = 0x2b;
        return;
      }
      ram_38 = 0x2d;
      return;
    }
  }
  else {
    if (ram_35 == 0xf) {
      ram_37 = 0;
      bit_2B_0 = 1;
      bit_2C_6 = 1;
      bit_2B_7 = 0;
      ram_2C = ram_2C & 0xf3;
      code_to_iram_copy(0x7186,0x38,9);
      return;
    }
    if ((bit_2C_3 != '\x01') && ((ram_35 == 9 || ((ram_35 < 9) << 7 < '\0')))) {
      bVar1 = ram_35 | 0x30;
      menu_blink_cursor();
      goto LAB_CODE_311e;
    }
  }
  xdata_to_iram(0,0x38,0xc);
  return;
}

/* ---- menu_start_blank  @0x30FC  (22 bytes) */
void menu_start_blank(void)

{
  ram_37 = 0;
  bit_2B_0 = 1;
  bit_2C_6 = 1;
  bit_2B_7 = 0;
  ram_2C = ram_2C & 0xf3;
  code_to_iram_copy(0x7186,0x38,9);
  return;
}

/* ---- menu_load_text  @0x313F  (10 bytes) */
void menu_load_text(void)

{
  xdata_to_iram(0,0x38,0xc);
  return;
}

/* ---- menu_blink_cursor  @0x3149  (18 bytes) */
void menu_blink_cursor(void)

{
  uint8_t uVar1;
  
  if (bit_2C_6 == '\0') {
    return;
  }
  bit_2C_6 = 0;
  uVar1 = 0x38;
  if (bit_2B_0 == '\0') {
    uVar1 = 0x39;
  }
  else {
    bit_2B_0 = '\0';
  }
  code_to_iram_copy(0x7189,uVar1,9);
  return;
}

/* ---- menu_digit_key  @0x315B  (42 bytes) */
void menu_digit_key(uint8_t param_1,uint8_t *param_2)

{
  if (((param_1 != 9) && (-1 < (param_1 < 9) << 7)) || (bit_2B_7 == '\x01')) {
    return;
  }
  if (bit_2C_6 == '\0') {
    ram_31 = ram_31 * '\n' + param_1;
    param_2['\x01'] = param_1 | 0x30;
    bit_2B_7 = 1;
    return;
  }
  ram_31 = param_1;
  *param_2 = param_1 | 0x30;
  param_2['\x01'] = 0x2d;
  bit_2C_6 = 0;
  bit_2B_0 = 0;
  return;
}

/* ---- put_2digits_iram  @0x3185  (14 bytes) */
void put_2digits_iram(uint8_t param_1,uint8_t *param_2)

{
  *param_2 = param_1 / 10 | 0x30;
  param_2['\x01'] = param_1 % 10 | 0x30;
  return;
}

/* ---- menu_edit_value  @0x3193  (11 bytes) */
void menu_edit_value(void)

{
  menu_set_value_ptr();
  fp_ld_xdata_r1(0x34);
  iram_to_xdata(0xa5,0x2b,0x19);
  return;
}

/* ---- menu_store_text  @0x319E  (10 bytes) */
void menu_store_text(void)

{
  iram_to_xdata(0,0x38,0xc);
  return;
}

/* ---- menu_parse_number  @0x31A8  (10 bytes) */
void menu_parse_number(void)

{
  parse_number_xdata(0,0x34,0x5f);
  return;
}

/* ---- menu_set_value_ptr  @0x31B2  (19 bytes)
 *      XDATA 0x0098 */
void menu_set_value_ptr(uint16_t param_1)

{
  xram_0098 = (char)((uint16_t)param_1 >> 8);
  xram_0099 = (char)param_1;
  bit_26_0 = 1;
  return;
}

/* ---- probe_hold_poll  @0x31C5  (167 bytes)
 *      PCF8574 0x4E/0x4F on the option bus: bit7 = data-hold probe button (PM9267), writes LED bit */
void probe_hold_poll(void)

{
  char cVar1;
  uint8_t bVar2;
  char in_PSW;
  
  cVar1 = i2cA_read1(0x4e);
  if (in_PSW < '\0') {
    ram_24 = ram_24 & 0x3f;
    bVar2 = meter_state & 0xf;
    if ((bVar2 != 4) && (bVar2 != 0xb)) {
      bit_25_7 = 0;
    }
    if (((((bVar2 == 8) && (cal_mode != '\x01')) && ((xram_00EB >> 4 & 1) != 1)) &&
        ((bit_21_2 == '\x01' || (bit_21_3 != '\0')))) && (bit_27_3 != '\0')) {
      ram_2F = 0x1c;
      ram_30 = 0xa2;
      ram_31 = 0;
    }
    return;
  }
  bit_25_7 = 1;
  if ((((meter_state & 0xf) == 8) && (cal_mode != '\x01')) &&
     (((xram_00EB >> 4 & 1) != 1 && (bit_21_3 != '\x01')))) {
    ram_2F = 0x1c;
    ram_30 = 0xa2;
    ram_31 = 2;
    bit_24_6 = 0;
    return;
  }
  if (cVar1 < '\0') {
    if (bit_24_7 != '\0') {
      key_debounce_delay();
      cVar1 = i2cA_read1(0x4e);
      if (cVar1 < '\0') {
        bit_24_7 = '\0';
      }
    }
  }
  else if (bit_24_7 != '\x01') {
    key_debounce_delay();
    cVar1 = i2cA_read1(0x4e);
    if ((-1 < cVar1) && (bit_24_7 = '\x01', bit_21_2 != '\x01')) {
      if (bit_21_3 == '\x01') {
        bit_24_6 = 0;
        ram_2F = 0x1d;
        ram_30 = 0xa5;
      }
      else {
        bit_24_6 = bit_24_6 ^ 1;
      }
    }
  }
  bVar2 = 0xfd;
  if (bit_24_6 != 1) {
    bVar2 = 0xff;
  }
  i2cA_write1(0x4e,bVar2 & 0xfe | adc_alt_mode & 1 ^ 1);
  return;
}

/* ---- code_to_iram_copy  @0x37A7  (8 bytes) */
void code_to_iram_copy(uint8_t *param_1,uint8_t *param_2,char param_3)

{
  do {
    *param_2 = *param_1;
    param_2 = param_2 + '\x01';
    param_1 = param_1 + 1;
    param_3 = param_3 + -1;
  } while (param_3 != '\0');
  return;
}

/* ---- func_change_hook  @0x3A79  (24 bytes)
 *      (inferred) per-function setup (continuity special case) */
void func_change_hook(void)

{
  xram_00A4 = 9;
  if ((meter_state & 0xf) == 0xd) {
    xram_00A4 = 8;
  }
  xram_00A0 = xram_00A0 & 0xfc;
  return;
}

/* ---- kbd_ctx_swap  @0x3D43  (14 bytes) */
void kbd_ctx_swap(void)

{
  xdata_swap_iram(ram_38,0x2e,6);
  return;
}

/* ---- kbd_cmd_finish  @0x3D51  (29 bytes)
 *      common exit of all key/command handlers */
void kbd_cmd_finish(void)

{
  bit_2F_7 = 0;
  if (bit_2D_3 == '\0') {
    ram_38 = 0xa9;
  }
  else {
    bit_23_6 = bit_2D_2 & 1 | bit_23_6 & 1;
    ram_38 = 0xdf;
  }
  ram_37 = 0;
  kbd_ctx_swap();
  return;
}

/* ---- task_keyboard  @0x409C  (162 bytes)
 *      1906 B: key handling / function+range selection state machine */
void task_keyboard(void)

{
  bool bVar1;
  uint8_t bVar2;
  uint8_t uVar3;
  uint8_t bVar4;
  char cVar5;
  uint8_t *puVar6;
  
  if ((xram_00E0 & 0x80) == 0) {
    if ((xram_00AA & 0x80) == 0) {
      return;
    }
    ram_38 = 0xa9;
    bit_2D_3 = '\0';
  }
  else {
    ram_38 = 0xdf;
    bit_2D_3 = '\x01';
  }
  ram_37 = 0;
  kbd_ctx_swap();
  fnsel_new_function = 0xff;
  bit_2D_2 = '\0';
  bit_2D_1 = 0;
  ram_3B = (&rom_6F24)[ram_2E];
  if ((ram_2F & 0x47) == 6) {
    if ((cal_mode == '\0') || ((ram_2E != 0x17 && (ram_2E != 0x18)))) {
      reply_pending_cmd = ram_2E;
    }
    else {
      bit_2D_2 = '\x01';
    }
    kbd_cmd_finish();
    return;
  }
  if (((ram_2F & 0x40) != 0) && (ram_31 == '\0')) {
    kbd_cmd_finish();
    return;
  }
  if ((((bit_25_6 != '\0') && (ram_2E < 0x13)) && (ram_2E != 8)) && (ram_2E != 9))
  {
    bit_2D_2 = 1;
    if (bit_2D_3 != '\x01') {
      lcd_show_error(ram_2E - 0x13);
    }
    kbd_cmd_finish();
    return;
  }
  bit_2D_1 = ram_2E < 0x13;
  bVar1 = CARRY1(ram_2E * '\x02',ram_2E);
  cVar5 = bVar1 << 7;
  bVar4 = ram_2E * '\x03';
                    /* WARNING: Switch is manually overridden */
  switch(bVar4) {
  case 0:
    peak_mode_b1 = 0;
    peak_mode_b0 = 1;
    fnsel_new_function = 0;
    break;
  case 3:
    peak_mode_b1 = 1;
    peak_mode_b0 = 0;
    fnsel_new_function = 0;
    break;
  case 6:
    peak_mode_b1 = 1;
    peak_mode_b0 = 1;
    fnsel_new_function = 0;
    break;
  case 9:
    fnsel_new_function = 1;
    break;
  case 0xc:
    fnsel_new_function = 2;
    break;
  case 0xf:
    fnsel_new_function = 3;
    break;
  case 0x12:
    fnsel_new_function = 4;
    break;
  case 0x15:
    fnsel_new_function = 5;
    break;
  case 0x18:
    fnsel_new_function = 6;
    break;
  case 0x1b:
    fnsel_new_function = 7;
    break;
  case 0x1e:
    time_start_negslope = 0;
    time_stop_negslope = 0;
    fnsel_new_function = 8;
    break;
  case 0x21:
    time_start_negslope = 0;
    time_stop_negslope = 1;
    fnsel_new_function = 8;
    break;
  case 0x24:
    time_start_negslope = 1;
    time_stop_negslope = 0;
    fnsel_new_function = 8;
    break;
  case 0x27:
    time_start_negslope = 1;
    time_stop_negslope = 1;
    fnsel_new_function = 8;
    break;
  case 0x2a:
    fnsel_new_function = 9;
    break;
  case 0x2d:
    fnsel_new_function = 10;
    break;
  case 0x30:
    fnsel_new_function = 0xb;
    break;
  case 0x33:
    fnsel_new_function = 0xc;
    break;
  case 0x36:
    fnsel_new_function = 0xd;
    break;
  case 0x39:
    rx_index = ram_30;
    rx_count = rx_count + ram_31 & 0x3f | rx_count & 0xc0;
    bVar4 = cmd_fnc_lookup();
    break;
  case 0x3c:
    bit_2D_1 = '\x01';
    break;
  case 0x3f:
    cVar5 = ((ram_2F & 7) == 0) << 7;
    if ((ram_2F & 7) == 1) {
      bVar4 = 0;
      if ((((meter_state & 0xf) == 0) || (bVar4 = (meter_state & 0xf) - 4, 3 < (meter_state & 0xf)))
         || (cal_mode == '\x01')) {
        bit_2D_2 = '\x01';
      }
      else {
        if (bit_22_0 == '\x01') {
          kbd_cmd_finish(bVar4);
          return;
        }
        bit_22_0 = '\x01';
        bit_22_1 = 0;
      }
    }
    else if ((ram_2F & 7) == 0) {
      if (bit_22_0 == '\0') {
        kbd_cmd_finish();
        return;
      }
      bit_22_0 = '\0';
      bit_22_1 = 0;
      bVar4 = 0;
    }
    else {
      bVar4 = dbm_set_reference();
      if (cVar5 < '\0') {
        bit_2D_2 = '\x01';
      }
      else {
        if (bit_2D_3 != '\x01') {
          bit_22_0 = '\x01';
        }
        if (bit_22_0 == '\0') {
          kbd_cmd_finish();
          return;
        }
        bit_22_1 = 0;
      }
    }
    break;
  case 0x42:
    if ((meter_state & 0xf) == 0xd) {
      bit_2D_2 = 1;
      kbd_cmd_finish();
      return;
    }
    if ((ram_2F & 0x46) == 0) {
      bVar4 = ram_2F >> 1 | ((meter_state & 0xf) < 0xd) << 7;
      if ((char)(ram_2F << 7) < '\0') {
        if (cal_mode == '\0') {
          bit_22_1 = 1;
        }
        bit_2D_2 = cal_mode != '\0';
      }
      else {
        bit_22_1 = 0;
      }
    }
    else if (bit_2F_6 == '\x01') {
      bVar4 = cmd_param_first_char();
      if (bVar4 == 0x4d) {
        if (cal_mode == '\0') {
          if (bit_26_5 == '\x01') {
            if (bit_22_0 == '\0') {
              ram_34 = 0;
              do {
                bVar4 = ram_34 - 4;
                if (3 < ram_34) break;
                puVar6 = &xram_0091;
                dptr_add_a(ram_34);
                uVar3 = *puVar6;
                puVar6 = &zero_reference;
                dptr_add_a(ram_34);
                *puVar6 = uVar3;
                bVar1 = ram_34 != 0xff;
                bVar4 = ram_34 + 1;
                ram_34 = bVar4;
              } while (bVar1);
            }
            else {
              ram_34 = 0;
              do {
                bVar4 = ram_34 - 4;
                if (3 < ram_34) break;
                puVar6 = &xram_008D;
                dptr_add_a(ram_34);
                uVar3 = *puVar6;
                puVar6 = &zero_reference;
                dptr_add_a(ram_34);
                *puVar6 = uVar3;
                bVar1 = ram_34 != 0xff;
                bVar4 = ram_34 + 1;
                ram_34 = bVar4;
              } while (bVar1);
            }
            bit_22_1 = 1;
          }
          else {
            bit_2D_2 = '\x01';
          }
        }
        else {
          bit_2D_2 = '\x01';
        }
      }
      else {
        bit_2D_2 = '\x01';
      }
    }
    else {
      bVar4 = ram_2F & 0x47;
      cVar5 = (bVar4 < 4) << 7;
      if (bVar4 == 4) {
        bVar4 = zer_set_reference();
        if (cVar5 < '\0') {
          bit_2D_2 = '\x01';
        }
        else if (bit_2D_3 != '\x01') {
          bit_22_1 = 1;
        }
      }
    }
    break;
  case 0x45:
    if (cal_mode != '\0') {
      bit_2D_2 = 1;
      kbd_cmd_finish();
      return;
    }
    reply_pending_cmd = ram_2E;
    bVar4 = ram_2E;
    break;
  case 0x48:
    if (cal_mode != '\0') {
      bit_2D_2 = 1;
      kbd_cmd_finish();
      return;
    }
    reply_pending_cmd = ram_2E;
    bVar4 = ram_2E;
    break;
  case 0x4b:
    if (cal_mode != '\0') {
      bit_2D_2 = 1;
      kbd_cmd_finish();
      return;
    }
    break;
  case 0x4e:
    bVar4 = ram_30;
    if ((ram_30 == 0) || (bVar4 = ram_30 - 4, 3 < ram_30)) {
      bit_2D_2 = '\x01';
    }
    else if (cal_mode == '\0') {
      bVar4 = set_speed(bVar4);
    }
    else {
      bVar4 = (meter_mode & 3) - (ram_30 - 1);
      bit_2D_2 = bVar4 != 0;
    }
    break;
  case 0x51:
    ram_39 = func_to_cmd_index();
    ram_34 = 0;
    while (ram_34 < 3) {
      bVar4 = (uint8_t)((uint16_t)ram_39 * 3);
      if (*(uint8_t *)(CONCAT11((char)((uint16_t)ram_39 * 3 >> 8) +
                             ('n' - (((0xbf < bVar4) << 7) >> 7)),bVar4 + 0x40) +
                   (uint16_t)ram_34) == ram_30) {
        ram_34 = ram_34 + 10;
      }
      else {
        ram_34 = ram_34 + 1;
      }
    }
    bVar4 = ram_34 - 10;
    if (ram_34 < 10) {
      bit_2D_2 = '\x01';
    }
    else {
      ram_30 = ram_34 - 9;
      if (cal_mode == '\0') {
        bVar4 = set_speed();
      }
      else {
        bVar4 = (meter_mode & 3) - (ram_34 - 10);
        if (bVar4 != 0) {
          bit_2D_2 = '\x01';
        }
      }
    }
    break;
  case 0x54:
    ram_39 = meter_mode;
    if (bit_2D_3 == '\0') {
      if (ram_30 == 0) {
        bit_21_2 = 0;
        bit_21_3 = '\0';
      }
      else {
        bit_21_2 = 0;
        bit_21_3 = '\x01';
        bit_27_3 = '\x01';
      }
    }
    else {
      ram_34 = cmd_param_first_char();
      if (ram_34 == 0x49) {
        if (cal_mode == '\0') {
          bit_21_2 = 0;
          bit_21_3 = '\0';
        }
        else {
          bit_2D_2 = '\x01';
        }
      }
      else if (ram_34 == 0x42) {
        bit_21_2 = 1;
        bit_21_3 = '\0';
        bit_27_3 = '\0';
      }
      else if (ram_34 == 0x45) {
        bit_21_2 = 0;
        bit_21_3 = '\x01';
        bit_27_3 = '\0';
      }
      else {
        bit_2D_2 = '\x01';
      }
    }
    bVar4 = ram_39 - meter_mode;
    if (bVar4 != 0) {
      bit_24_6 = 0;
    }
    break;
  case 0x57:
    bVar4 = ram_2F & 0x47;
    if ((bVar4 == 2) && (ram_30 != 1)) {
      bit_2D_2 = 1;
      kbd_cmd_finish();
      return;
    }
    bVar2 = bit_21_2;
    if (bit_21_3 != '\0') {
      bVar2 = bit_21_2 & 1 ^ 1;
    }
    cVar5 = bVar2 << 7;
    if ((cVar5 < '\0') && ((cal_mode == '\0' || (bVar4 = cal_step_allowed(), -1 < cVar5)))) {
      bit_24_5 = bit_2D_3 != '\0';
      bVar4 = trigger_restart_measure();
      bit_24_4 = 1;
    }
    else if (bit_2D_3 != '\0') {
      bit_2D_2 = '\x01';
    }
    break;
  case 0x5a:
    if ((ram_2F & 0x46) == 0) {
      bVar4 = ram_2F >> 1 | bVar1 << 7;
      if ((char)(ram_2F << 7) < '\0') {
        if (cal_enable == '\0') {
          bit_2D_2 = '\x01';
        }
        else {
          bVar4 = cal_mode_enter(bVar4);
        }
      }
      else if (cal_mode == '\0') {
        cal_enable = '\0';
      }
      else {
        cal_mode = '\0';
        bVar4 = xram_00EB & 0x10;
        if (bVar4 == 0) {
          bit_21_2 = 0;
          bit_21_3 = '\0';
        }
      }
    }
    else {
      bVar4 = ram_2F & 0x47;
      if (bVar4 == 2) {
        bVar4 = ram_30 - 2;
        if (ram_30 < 2) {
          if (((cal_mode == '\0') || (bit_2D_3 != '\x01')) && ((cal_enable == '\0' || (bit_2D_3 == '\x01')))
             ) {
            bit_2D_2 = '\x01';
          }
          else {
            bVar4 = ram_30 >> 1 | (ram_30 < 2) << 7;
            cal_hot = ram_30 & 1;
            if (cal_mode != '\x01') {
              bVar4 = cal_mode_enter(bVar4);
            }
          }
        }
        else {
          bit_2D_2 = '\x01';
        }
      }
      else {
        bit_2D_2 = '\x01';
      }
    }
    break;
  case 0x5d:
    bVar4 = cmd_param_first_char();
    ram_34 = bVar4;
    if (bVar4 == 0x53) {
      bit_22_7 = 0;
    }
    else if (bVar4 == 0x4e) {
      if (cal_mode != '\0') {
        bit_2D_2 = 1;
        kbd_cmd_finish();
        return;
      }
      bit_22_7 = 1;
    }
    else {
      bit_2D_2 = '\x01';
    }
    break;
  case 0x60:
    bVar4 = ram_2F & 0x47;
    if (bVar4 == 3) {
      jcv_set_ptr();
      reply_pending_cmd = ram_2E;
      bVar4 = ram_2E;
    }
    else if (cal_mode == '\0') {
      bit_2D_2 = '\x01';
    }
    else {
      bVar4 = diag_clear_counters();
    }
    break;
  case 99:
    reply_pending_cmd = ram_2E;
    bVar4 = ram_2E;
    break;
  case 0x66:
    if (cal_mode != '\x01') {
      bit_2D_2 = 1;
      kbd_cmd_finish();
      return;
    }
    if (bit_2F_5 == '\0') {
      if ((cdp_slot & 0x80) == 0) {
        bit_2D_2 = '\x01';
        bVar4 = 0;
      }
      else {
        cdp_slot = cdp_slot & 0x7f;
        if ((ram_2F & 0x47) == 2) {
          cdp_int_to_fp();
        }
        bVar4 = cdp_write_slot();
      }
    }
    else if (bit_2F_6 == '\0') {
      bVar4 = ram_2F & 0x47;
      cVar5 = (bVar4 < 2) << 7;
      if (bVar4 == 2) {
        bVar4 = cdp_slot_valid();
        if (cVar5 < '\0') {
          bVar4 = ram_30 | 0x80;
          cdp_slot = bVar4;
        }
        else {
          bit_2D_2 = '\x01';
        }
      }
      else {
        bit_2D_2 = '\x01';
      }
    }
    else {
      bVar4 = cmd_param_first_char();
      ram_34 = bVar4;
      if (bVar4 == 0x52) {
        bVar4 = cal_seal_normal();
        ram_3B = 0x41;
      }
      else if (bVar4 == 0x53) {
        bVar4 = cal_seal_altered();
        ram_3B = 0x41;
      }
      else {
        bit_2D_2 = '\x01';
      }
    }
    break;
  case 0x69:
    if (cal_mode != '\x01') {
      bit_2D_2 = 1;
      kbd_cmd_finish();
      return;
    }
    bVar4 = rms_set_byte(ram_30);
    break;
  case 0x6c:
    if ((char)(ram_2F << 7) < '\0') {
      bVar4 = mains_set_60hz();
    }
    else {
      bVar4 = mains_set_50hz(ram_2F >> 1 | bVar1 << 7);
    }
    break;
  case 0x6f:
    if ((char)(ram_2F << 7) < '\0') {
      bVar4 = cr_set_on();
    }
    else {
      bVar4 = cr_set_off(ram_2F >> 1 | bVar1 << 7);
    }
    break;
  case 0x72:
    if (((bit_2D_3 == '\0') || (bVar4 = 0, (xram_0058 & 0x80) != 0)) &&
       (bVar4 = 0x1e - ram_30, ram_30 < 0x1f)) {
      bVar4 = nv_get_iface_config(bVar4);
      ram_34 = bVar4 & 0x80 | ram_30;
      bVar4 = iee_store_address();
    }
    else {
      bit_2D_2 = '\x01';
    }
    break;
  case 0x75:
    break;
  case 0x78:
    if (bit_2D_3 == '\0') {
      bVar4 = tol_set();
    }
    else if ((xram_0058 & 0x80) == 0) {
      if (xram_005A == 3) {
        if (bit_2F_6 == '\0') {
          if ((ram_2F & 7) == 5) {
            ram_31 = '\0';
            ram_32 = 0;
            ram_30 = 1;
          }
          bVar4 = emo_set_count();
        }
        else {
          bVar4 = cmd_param_first_char();
          if (bVar4 == 0x41) {
            emo_continuous = 1;
          }
          else {
            bit_2D_2 = '\x01';
          }
        }
      }
      else {
        bit_2D_2 = '\x01';
        bVar4 = xram_005A;
      }
    }
    else {
      bVar4 = tol_set();
    }
    break;
  case 0x7b:
    bVar4 = ram_2F >> 1 | bVar1 << 7;
    if ((char)(ram_2F << 7) < '\0') {
      bVar4 = rtl_go_local(bVar4);
    }
    break;
  case 0x7e:
    bVar4 = range_can_go_down();
    if (cVar5 < '\0') {
      bVar4 = meter_state - 0x10;
      bit_22_3 = 1;
      meter_state = bVar4;
    }
    else {
      ram_3B = 0;
    }
    break;
  case 0x81:
    bVar4 = range_can_go_up();
    if (cVar5 < '\0') {
      bVar4 = meter_state + 0x10;
      bit_22_3 = 1;
      meter_state = bVar4;
    }
    else {
      ram_3B = 0;
    }
    break;
  case 0x84:
    meter_autorange = ram_2F & 1;
    bVar4 = ram_2F >> 1 | bVar1 << 7;
    break;
  case 0x87:
    bVar4 = min_reset();
    break;
  case 0x8a:
    bVar4 = max_reset();
    break;
  case 0x8d:
    break;
  case 0x90:
  }
  if (((bit_2D_1 != '\0') && (bit_2F_6 != '\0')) &&
     ((cVar5 = cmd_param_first_char(bVar4), cVar5 != 'A' ||
      ((cVar5 = cmd_param_first_char(), cVar5 == 'A' && (cal_mode != '\0')))))) {
    bit_2D_2 = '\x01';
  }
  if (((fnsel_new_function != 0xff) && (bit_2D_2 == '\0')) &&
     ((meter_state & 0xf) != fnsel_new_function)) {
    if ((meter_state & 0xf) == 10) {
      xram_00C1 = xram_00C1 | 8;
      internal_temp_init();
    }
    meter_state = meter_state & 0xf0 | fnsel_new_function;
    if ((fnsel_new_function != 8) && (bit_27_3 != '\0')) {
      if (cal_mode != '\x01') {
        bit_21_2 = 0;
        bit_21_3 = '\0';
      }
      bit_27_3 = '\0';
    }
    func_change_hook();
    if (fnsel_new_function != 0) {
      peak_mode_b1 = 0;
      peak_mode_b0 = 0;
    }
    bit_24_6 = 0;
    if ((fnsel_new_function == 4) || (fnsel_new_function == 0xb)) {
      bit_25_7 = 1;
    }
    else {
      bit_25_7 = 0;
    }
  }
  if (bit_2D_2 == '\0') {
    if (((ram_3B & 4) != 0) && (cal_mode != '\x01')) {
      speed_store();
    }
    if (bit_2D_1 != '\0') {
      if (ram_2E != 0x14) {
        if (cal_mode == '\0') {
          speed_store();
        }
        else {
          speed_load();
        }
      }
      if ((ram_2F & 0x47) == 4) {
        range_by_value();
        meter_autorange = 0;
      }
      else {
        if (ram_2E != 0x14) {
          meas_set_function_flags();
        }
        if (cal_mode != '\x01') {
          meter_autorange = 1;
        }
      }
    }
    if ((ram_3B & 0x10) != 0) {
      bit_22_0 = '\0';
      bit_22_1 = 0;
    }
    if ((ram_3B & 8) != 0) {
      min_reset();
      max_reset();
    }
    if ((ram_3B & 0x80) != 0) {
      bit_26_5 = '\0';
    }
    if ((bit_2D_3 != '\0') && ((xram_00EB & 0x10) != 0)) {
      if ((xram_00EB & 0x80) == 0) {
        menu_exit_b();
      }
      else {
        menu_exit_a();
      }
    }
    if ((ram_3B & 1) == 1) {
      meas_restart_from_ui();
      trigger_clear();
      cal_status_or_dashes();
    }
    if ((ram_3B & 0x40) != 0) {
      result_restart();
    }
  }
  kbd_cmd_finish();
  if ((bit_21_2 != 1) && (bit_21_3 != '\x01')) {
    result_flags = result_flags | 8;
  }
  return;
}

/* ---- func_is_time_or_cont  @0x54F8  (18 bytes) */
void func_is_time_or_cont(void)

{
  uint8_t bVar1;
  
  bVar1 = meter_state & 0xf;
  if (((bVar1 == 8) || (bVar1 == 0)) || (bVar1 == 0xd)) {
    return;
  }
  return;
}

/* ---- key_scan  @0x5934  (64 bytes)
 *      debounced key number 0-15 -> 35h (FF = none) */
void key_scan(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  char cVar3;
  char in_PSW;
  char cVar4;
  
  bVar2 = key_read_matrix();
  if (in_PSW < '\0') {
    return;
  }
  bVar1 = DAT_SFR_ff;
  cVar4 = (bVar2 < bVar1) << 7;
  bVar1 = DAT_SFR_ff;
  if (bVar2 == bVar1) {
    if (bit_2B_2 != '\0') {
      key_debounce_delay();
      cVar3 = key_read_matrix();
      if (cVar4 < '\0') {
        return;
      }
      if (cVar3 == -1) {
        bit_2B_2 = 0;
        return;
      }
    }
  }
  else {
    cVar4 = '\0';
    if ((ram_35 == -1) && (bit_2B_2 != '\x01')) {
      key_debounce_delay();
      key_read_matrix();
      if (cVar4 < '\0') {
        return;
      }
      cVar4 = '\x10';
      do {
        if ((&key_code_table)[cVar4 - 1] == R3) {
          ram_35 = cVar4 + -1;
          bit_2B_2 = 1;
          return;
        }
        cVar4 = cVar4 + -1;
      } while (cVar4 != '\0');
    }
  }
  return;
}

/* ---- key_read_matrix  @0x5984  (33 bytes)
 *      PCF8574: write F0/read, write 0F/read, OR */
uint8_t key_read_matrix(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  char in_PSW;
  
  bVar1 = i2cB_write1(0x48,0xf0);
  if (-1 < in_PSW) {
    bVar2 = i2cB_read1_stop(0x48);
    bVar1 = bVar2;
    if (-1 < in_PSW) {
      bVar1 = i2cB_write1(0x48,0xf,bVar2);
      if (-1 < in_PSW) {
        bVar1 = i2cB_read1_stop(0x48);
        bVar1 = bVar1 | bVar2;
      }
    }
  }
  return bVar1;
}

/* ---- key_debounce_delay  @0x5A84  (9 bytes) */
void key_debounce_delay(void)

{
  char cVar1;
  char cVar2;
  
  cVar1 = 'q';
  cVar2 = '\x14';
  do {
    do {
      cVar1 = cVar1 + -1;
    } while (cVar1 != '\0');
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  return;
}

