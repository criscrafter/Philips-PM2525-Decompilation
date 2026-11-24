/* remote_commands.c - command execution shared by keyboard and remote, query replies
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 36 functions, 2067 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/remote_commands.c.
 */
#include "pm2525.h"

/* ---- jcv_set_ptr  @0x3D2B  (11 bytes) */
void jcv_set_ptr(void)

{
  jcv_ptr = ram_30;
  xram_009B = ram_31;
  return;
}

/* ---- jcv_get_ptr  @0x3D36  (13 bytes)
 *      one-shot: read and clear XDATA 0x009A/0x009B */
void jcv_get_ptr(void)

{
  jcv_ptr = 0;
  xram_009B = 0;
  return;
}

/* ---- cmd_param_first_char  @0x3D6E  (17 bytes)
 *      first character of a mnemonic parameter */
uint8_t cmd_param_first_char(void)

{
  char cVar1;
  uint8_t *pbVar2;
  
  cVar1 = ram_30;
  ram_31 = ram_31 + -1;
  ram_30 = ram_30 + '\x01';
  pbVar2 = &iface_rx_buf;
  dptr_add_a(cVar1);
  return *pbVar2 & 0x5f;
}

/* ---- set_speed  @0x3D7F  (105 bytes)
 *      MSP n */
void set_speed(void)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar3;
  
  bVar1 = (meter_state & 0xf) * '\x03';
  ram_34 =
       *(uint8_t *)(CONCAT11('n' - (((0x2b < bVar1) << 7) >> 7),bVar1 - 0x2c) +
                (uint16_t)(ram_30 - 1));
  cVar2 = (meter_state >> 4 & 7) + 1;
  bVar3 = 0;
  bVar1 = 1;
  do {
    bVar3 = bVar3 << 1 | bVar1;
    bVar1 = 0;
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  ram_3C = bVar3 & ram_34;
  if (meter_autorange == '\0') {
    if (ram_3C == 0) {
      bit_2D_2 = '\x01';
    }
  }
  else if (ram_34 == 0) {
    bit_2D_2 = '\x01';
  }
  else if (ram_3C == 0) {
    meas_set_function_flags();
  }
  if (bit_2D_2 != '\x01') {
    meter_mode = ram_30 - 1U | meter_mode & 0xfc;
    if ((meter_state & 0xf) == 1) {
      speed_saved = ram_30 - 1U & 3;
    }
  }
  return;
}

/* ---- cdp_int_to_fp  @0x3E81  (10 bytes) */
void cdp_int_to_fp(void)

{
  ram_31 = 0;
  ram_32 = 0;
  i24_to_fp();
  return;
}

/* ---- cdp_write_slot  @0x3E8B  (38 bytes)
 *      CDP n,value: cal slot n -> XDATA 0x0200+4(n-1), all three copies */
void cdp_write_slot(void)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  
  bVar3 = 0;
  cVar2 = '\x02';
  bVar4 = cdp_slot - 1;
  do {
    bVar1 = bVar4 * '\x02';
    bVar3 = bVar3 << 1 | bVar4 >> 7;
    cVar2 = cVar2 + -1;
    bVar4 = bVar1;
  } while (cVar2 != '\0');
  cal_write_all_copies_safe(CONCAT11(bVar3 + 2,bVar1),0x33);
  return;
}

/* ---- cmd_fnc_lookup  @0x3F8E  (44 bytes)
 *      FNC <mnemonic>: find function mnemonic in cmd_table */
void cmd_fnc_lookup(void)

{
  uint8_t uVar1;
  uint8_t uVar2;
  uint8_t uVar3;
  uint8_t uVar4;
  
  uVar4 = ram_36;
  uVar3 = ram_35;
  uVar2 = ram_34;
  uVar1 = ram_2D;
  parser_reset();
  xram_00E5 = ram_34;
  xram_00DE = ram_2D;
  xram_00E7 = ram_36;
  xram_00E6 = ram_35;
  ram_35 = uVar3;
  ram_36 = uVar4;
  ram_2D = uVar1;
  ram_34 = uVar2;
  return;
}

/* ---- iee_store_address  @0x3FBA  (35 bytes)
 *      IEE n -> settings byte 1, tell the interface (C0|addr) */
void iee_store_address(void)

{
  uint8_t uVar1;
  uint8_t uVar2;
  
  nv_set_iface_config(ram_34);
  uVar2 = ram_2F;
  uVar1 = ram_2E;
  if ((xram_0055 < '\0') && (xram_0059 == '\0')) {
    iface_send_config_address(ram_34,0x53);
  }
  ram_2E = uVar1;
  ram_2F = uVar2;
  return;
}

/* ---- rtl_go_local  @0x3FDE  (18 bytes)
 *      rTL: clear remote state in the interface context */
void rtl_go_local(void)

{
  uint8_t uVar1;
  uint8_t uVar2;
  
  uVar2 = ram_2F;
  uVar1 = ram_2E;
  iface_clear_remote(iface_chan_lo);
  ram_2E = uVar1;
  ram_2F = uVar2;
  return;
}

/* ---- emo_set_count  @0x3FF0  (22 bytes)
 *      EMO n: output n readings (XDATA 0x0095) */
void emo_set_count(void)

{
  if ((ram_32 & 0x80) == 0) {
    i24_st_r0_xdata(0x95,0x32);
    emo_continuous = 0;
  }
  else {
    bit_2D_2 = 1;
  }
  return;
}

/* ---- tol_set  @0x4006  (52 bytes)
 *      TOL ON/OFF (talk only, byte 1 bit 7); keyboard T.ONLY step */
void tol_set(void)

{
  uint8_t bVar1;
  uint8_t in_PSW;
  uint8_t bVar2;
  
  bVar2 = in_PSW & 0xdd;
  if ((ram_2F & 0x46) == 0) {
    bVar1 = nv_get_iface_config();
    ram_34 = bVar1 & 0x7f;
    if ((char)(ram_2F << 7) < '\0') {
      ram_34 = ram_34 | 0x80;
      emo_continuous = 1;
      bit_23_3 = 1;
    }
    else {
      emo_continuous = 0;
      bit_23_3 = 0;
      xdata_clear3(ram_2F >> 1 | bVar2 & 0x80,0x95);
    }
    iee_store_address();
  }
  else {
    bit_2D_2 = 1;
  }
  return;
}

/* ---- zer_set_reference  @0x403A  (37 bytes)
 *      ZER <number> */
void zer_set_reference(void)

{
  char in_PSW;
  
  fp_ld_code_r0(0x6fcc,0x41);
  fp_cmp(0x33);
  if (-1 < in_PSW) {
    fp_ld_code_r1(0x6fc8,0x41);
    fp_cmp(0x33);
    if (-1 < in_PSW) {
      fp_st_r0_xdata(0x79);
    }
  }
  return;
}

/* ---- dbm_set_reference  @0x4061  (37 bytes)
 *      DBM <number>: 1e-4..9999, stored at XDATA 0x0075 (default 600) */
void dbm_set_reference(void)

{
  char in_PSW;
  
  fp_ld_code_r0(0x6fd8,0x41);
  fp_cmp(0x33);
  if (-1 < in_PSW) {
    fp_ld_code_r1(0x6fd4,0x41);
    fp_cmp(0x33);
    if (-1 < in_PSW) {
      fp_st_r0_xdata(0x75);
    }
  }
  return;
}

/* ---- cdp_slot_valid  @0x4088  (18 bytes)
 *      1..114 (ROM 0x6FB9) */
void cdp_slot_valid(void)

{
  if ((rom_6FB9 < ram_30) || (ram_30 == 0)) {
    return;
  }
  return;
}

/* ---- func_to_cmd_index  @0x4814  (54 bytes)
 *      current function -> mnemonic index (for FNC?, RSL) */
char func_to_cmd_index(void)

{
  if ((meter_state & 0xf) == 0) {
    return ((meter_mode >> 7) << 1 | (meter_mode & 0x7f) >> 6) - 1;
  }
  if ((meter_state & 0xf) < 8) {
    return (meter_state & 0xf) + 2;
  }
  if ((meter_state & 0xf) == 8) {
    return (meter_mode >> 4 & 3) + 10;
  }
  return (meter_state & 0xf) + 5;
}

/* ---- reply_value_cmp_ten  @0x484A  (14 bytes) */
void reply_value_cmp_ten(void)

{
  fp_ld_xdata_r0(ram_2A,0x57);
  fp_cmp_ten();
  return;
}

/* ---- reply_put_float  @0x485A  (22 bytes)
 *      format float (e.g. +1.250000E+00) */
void reply_put_float(void)

{
  dptr_add_a_b(reply_len,0x34);
  fp_format(ram_31,0x3d,0x39,ram_2F,ram_35);
  return;
}

/* ---- reply_decimal_pos  @0x4870  (29 bytes) */
uint8_t reply_decimal_pos(uint8_t param_1)

{
  uint8_t bVar1;
  uint8_t uVar2;
  
  uVar2 = ram_2E;
  if (bit_22_0 == '\0') {
    bVar1 = *(uint8_t *)(CONCAT11(ram_2B,ram_2C) + 1);
    bit_2E_3 = bVar1 >> 7;
    lcd_decimal_point((bVar1 & 0x70) >> 4);
    ram_2E = uVar2;
    return param_1;
  }
  return 0;
}

/* ---- reply_ld_value  @0x489B  (12 bytes) */
void reply_ld_value(void)

{
  fp_ld_xdata_r0(ram_2A,0x3d);
  return;
}

/* ---- cdp_load_slot  @0x4921  (21 bytes)
 *      load slot (vote over the 3 copies); 23h.7 if no majority -> 'E' */
void cdp_load_slot(void)

{
  bit_27_4 = 1;
  cal_ld_slot(ram_2A,0x57);
  fp_copy_r1_to_r0(0x3d,0x57);
  return;
}

/* ---- reply_after_reading  @0x4936  (31 bytes)
 *      clear "new result" flag, restart if not triggered */
void reply_after_reading(void)

{
  if ((bit_21_2 == '\x01') || (bit_21_3 == '\x01')) {
    result_flags = result_flags & 0xf7;
    if ((bit_24_5 == '\0') || (xram_005A != '\0')) {
      iface_report_status();
    }
  }
  else {
    iface_report_status();
  }
  return;
}

/* ---- reply_put_value_field  @0x4955  (19 bytes) */
void reply_put_value_field(void)

{
  reply_ld_value();
  ram_31 = 0x48;
  ram_2F = 0x67;
  reply_put_float();
  reply_len = reply_len + '\r';
  return;
}

/* ---- reply_put_mnemonic  @0x4968  (79 bytes)
 *      append 3-char mnemonic #(33h) from table 0x59B1 to reply buffer */
void reply_put_mnemonic(void)

{
  uint8_t uVar1;
  uint8_t *puVar2;
  
  puVar2 = &cmd_table;
  dptr_add_a_mul_b(ram_33,5);
  uVar1 = *puVar2;
  puVar2 = &reply_buf;
  dptr_add_a(reply_len);
  *puVar2 = uVar1;
  puVar2 = &rom_59B2;
  dptr_add_a_mul_b(ram_33,5);
  uVar1 = *puVar2;
  puVar2 = &xram_0035;
  dptr_add_a(reply_len);
  *puVar2 = uVar1;
  puVar2 = &rom_59B3;
  dptr_add_a_mul_b(ram_33,5);
  uVar1 = *puVar2;
  puVar2 = &xram_0036;
  dptr_add_a(reply_len);
  *puVar2 = uVar1;
  reply_len = reply_len + '\x03';
  return;
}

/* ---- reply_put_string  @0x49B7  (44 bytes)
 *      append '#'-terminated code string at (2Dh:2Eh) */
void reply_put_string(void)

{
  uint8_t uVar1;
  uint8_t *puVar2;
  
  for (ram_35 = 0;
      *(char *)(CONCAT11(ram_2D,ram_2E) + (uint16_t)ram_35) != '#';
      ram_35 = ram_35 + 1) {
    uVar1 = *(uint8_t *)(CONCAT11(ram_2D,ram_2E) + (uint16_t)ram_35);
    puVar2 = &reply_buf;
    dptr_add_a(reply_len);
    *puVar2 = uVar1;
    reply_len = reply_len + '\x01';
  }
  return;
}

/* ---- reply_send  @0x49E3  (35 bytes) */
void reply_send(void)

{
  if ((*(uint8_t *)(CONCAT11(iface_chan_hi,iface_chan_lo) + 2) & 0x40) == 0) {
    reply_len = 0x80;
  }
  else {
    reply_len = reply_len | 0x80;
    iface_send(CONCAT11(iface_chan_hi,iface_chan_lo));
  }
  return;
}

/* ---- reply_send_last  @0x4A06  (26 bytes)
 *      (+CR if CR ON) mark end of message, send */
void reply_send_last(void)

{
  uint8_t *puVar1;
  
  if (cr_enabled != '\0') {
    puVar1 = &reply_buf;
    dptr_add_a(reply_len);
    *puVar1 = 0xd;
    reply_len = reply_len + 1;
  }
  reply_len = reply_len | 0x40;
  reply_send();
  return;
}

/* ---- reply_put_2digits  @0x4A20  (47 bytes) */
void reply_put_2digits(void)

{
  uint8_t bVar1;
  uint8_t *pbVar2;
  
  bVar1 = ram_30 / 10 | 0x30;
  pbVar2 = &reply_buf;
  dptr_add_a(reply_len,ram_30 % 10);
  *pbVar2 = bVar1;
  bVar1 = ram_30 % 10 | 0x30;
  pbVar2 = &xram_0035;
  dptr_add_a(reply_len);
  *pbVar2 = bVar1;
  reply_len = reply_len + '\x02';
  return;
}

/* ---- reply_put_3digits  @0x4A4F  (47 bytes)
 *      3-digit decimal + ',' */
void reply_put_3digits(void)

{
  uint8_t bVar1;
  uint8_t *pbVar2;
  uint8_t *puVar3;
  
  bVar1 = ram_30 / 100 | 0x30;
  pbVar2 = &reply_buf;
  dptr_add_a(reply_len,ram_30 % 100);
  *pbVar2 = bVar1;
  bVar1 = ram_30 / 100;
  ram_30 = ram_30 % 100;
  reply_len = reply_len + '\x01';
  reply_put_2digits(bVar1);
  puVar3 = &reply_buf;
  dptr_add_a(reply_len);
  *puVar3 = 0x2c;
  reply_len = reply_len + '\x01';
  return;
}

/* ---- reply_nc_check  @0x4A7E  (5 bytes) */
void reply_nc_check(void)

{
  value_is_signed();
  return;
}

/* ---- reply_put_reading_value  @0x4A84  (468 bytes) */
void reply_put_reading_value(void)

{
  bool bVar1;
  char cVar2;
  uint8_t bVar3;
  uint8_t *puVar4;
  
  cVar2 = (ram_33 < 0x12) << 7;
  if (ram_33 == 0x12) {
    reply_value_cmp_ten();
    if (cVar2 < '\0') {
      ram_2E = 0x7f;
    }
    else {
      ram_2E = 0x87;
    }
    ram_2D = 0x6e;
    reply_put_string();
    return;
  }
  ram_34 = *(uint8_t *)(CONCAT11(ram_2B,ram_2C) + 1) >> 4 & 7;
  bVar3 = (uint8_t)((uint16_t)ram_33 * 3);
  ram_32 =
       *(uint8_t *)(CONCAT11((char)((uint16_t)ram_33 * 3 >> 8) +
                          ('n' - (((0xbf < bVar3) << 7) >> 7)),bVar3 + 0x40) +
                (uint16_t)(meter_mode & 3));
  if (((ram_33 == 7) && (ram_34 == 6)) ||
     ((ram_33 == 0xe && (ram_34 == 7)))) {
    ram_32 = ram_32 - 1;
  }
  if (bit_22_1 != '\0') {
    ram_32 = 7;
    ram_31 = 0x48;
  }
  if (bit_22_0 != '\0') {
    ram_32 = 4;
    ram_31 = 0xf1;
    ram_35 = '\0';
  }
  do {
  } while (ram_32 == 0);
  bVar3 = meter_state & 0xf;
  cVar2 = '\0';
  shl16_r6r7(3);
  ram_34 =
       *(uint8_t *)(CONCAT11(cVar2 + ('m' - (((0x3f < bVar3) << 7) >> 7)),bVar3 - 0x40) +
                (uint16_t)ram_34);
  if (((*(uint8_t *)(CONCAT11(ram_2B,ram_2C) + 1) & 0x80) != 0) &&
     ((ram_33 == 8 || (ram_33 == 9)))) {
    ram_34 = ram_34 - 1;
  }
  if (((*(uint8_t *)(CONCAT11(ram_2B,ram_2C) + 1) & 8) == 0 &&
       (*(uint8_t *)CONCAT11(ram_2B,ram_2C) & 0x26) == 0) &&
     ((((*(uint8_t *)(CONCAT11(ram_2B,ram_2C) + 1) & 0x80) == 0 || (ram_33 == 8))
      || (ram_33 == 9)))) {
    reply_ld_value();
    if ((bit_22_0 != '\x01') && (bit_22_1 != '\x01')) {
      ram_35 = reply_decimal_pos();
      if ((*(uint8_t *)CONCAT11(ram_2B,ram_2C) & 8) != 0) {
        ram_32 = ram_32 - 1;
      }
      cVar2 = (ram_32 < ram_34) << 7;
      ram_31 = ram_32 - ram_34 | 0xf0;
      reply_nc_check();
      if (cVar2 < '\0') {
        ram_3D = ram_3D & 0x7f;
        ram_31 = ram_31 & 0xbf;
      }
    }
    ram_2F = ram_32 | 0x60;
    reply_put_float();
    reply_len = reply_len + '\r';
  }
  else {
    ram_2F = reply_len + 1;
    ram_2D = 0x6e;
    ram_2E = 0x8f;
    reply_put_string();
    if ((bit_22_1 == '\0') || (bit_22_0 == '\x01')) {
      ram_35 = 0;
      do {
        if (7 - ram_32 <= ram_35) break;
        puVar4 = &reply_buf;
        dptr_add_a();
        *puVar4 = 0x20;
        bVar1 = ram_35 != 0xff;
        ram_35 = ram_35 + 1;
      } while (bVar1);
    }
    else {
      ram_35 = 0;
    }
    cVar2 = CARRY1(ram_35,ram_2F) << 7;
    ram_2F = (ram_35 + ram_2F) - 1;
    if ((*(uint8_t *)(CONCAT11(ram_2B,ram_2C) + 1) & 8) == 0) {
      if ((*(uint8_t *)CONCAT11(ram_29,ram_2A) & 0x80) == 0) {
        puVar4 = &reply_buf;
        dptr_add_a(ram_2F);
        *puVar4 = 0x2b;
      }
      else {
        puVar4 = &reply_buf;
        dptr_add_a(ram_2F);
        *puVar4 = 0x2d;
      }
    }
    else {
      puVar4 = &reply_buf;
      dptr_add_a(ram_2F);
      *puVar4 = 0x2b;
    }
    reply_nc_check();
    if (cVar2 < '\0') {
      puVar4 = &reply_buf;
      dptr_add_a(ram_2F);
      *puVar4 = 0x20;
    }
    ram_35 = ram_2F + 4;
    puVar4 = &reply_buf;
    dptr_add_a(ram_35);
    *puVar4 = 0x2e;
  }
  return;
}

/* ---- reply_put_reading_header  @0x4C58  (186 bytes) */
void reply_put_reading_header(void)

{
  uint8_t *puVar1;
  
  reply_put_mnemonic();
  if (bit_22_0 == '\0') {
    puVar1 = &reply_buf;
    dptr_add_a(reply_len);
    *puVar1 = 0x20;
  }
  else {
    puVar1 = &reply_buf;
    dptr_add_a(reply_len);
    *puVar1 = 0x44;
  }
  if (cal_mode == '\0') {
    if (bit_22_1 == '\0') {
      puVar1 = &xram_0035;
      dptr_add_a(reply_len);
      *puVar1 = 0x20;
    }
    else {
      puVar1 = &xram_0035;
      dptr_add_a(reply_len);
      *puVar1 = 0x5a;
    }
  }
  else {
    puVar1 = &xram_0035;
    dptr_add_a(reply_len);
    *puVar1 = 0x43;
  }
  if ((*(uint8_t *)(CONCAT11(ram_2B,ram_2C) + 1) & 8) == 0) {
    ram_31 = *(uint8_t *)CONCAT11(ram_2B,ram_2C);
    if ((ram_31 & 2) == 0) {
      if ((ram_31 & 4) == 0) {
        if ((ram_31 & 0x10) == 0) {
          if ((ram_31 & 0x20) == 0) {
            if ((ram_31 & 8) == 0) {
              if ((ram_31 & 1) == 0) {
                ram_2F = 0x20;
              }
              else {
                ram_2F = 0x43;
              }
            }
            else {
              ram_2F = 0x52;
            }
          }
          else {
            ram_2F = 0x55;
          }
        }
        else {
          ram_2F = 0x4e;
        }
      }
      else {
        ram_2F = 0x46;
      }
    }
    else {
      ram_2F = 0x4f;
    }
  }
  else {
    ram_2F = 0x3f;
  }
  puVar1 = &xram_0036;
  dptr_add_a(reply_len);
  *puVar1 = ram_2F;
  reply_len = reply_len + '\x03';
  return;
}

/* ---- reply_abort  @0x4D12  (9 bytes) */
void reply_abort(void)

{
  reply_len = 0;
  reply_items_left = 0;
  return;
}

/* ---- reply_init  @0x4D1B  (16 bytes) */
void reply_init(void)

{
  reply_len = 0;
  reply_pending_cmd = 0;
  reply_items_left = 0;
  jcv_get_ptr();
  return;
}

/* ---- task_remote_reply  @0x4D2B  (390 bytes)
 *      1228 B: builds interface replies (command table at 0x59B1) */
uint8_t task_remote_reply(char param_1,uint8_t param_2)

{
  bool bVar1;
  uint8_t bVar2;
  char cVar3;
  uint8_t uVar4;
  char cVar5;
  uint8_t *puVar6;
  char *pcVar7;
  uint8_t *pbVar8;
  
  if (iface_chan_hi == '\0' && iface_chan_lo == '\0') {
    reply_items_left = 0;
    reply_pending_cmd = 0;
    return 0;
  }
  if ((reply_len & 0x80) != 0) {
    bVar2 = *(uint8_t *)(CONCAT11(iface_chan_hi,iface_chan_lo) + 2) & 0x10;
    if (bVar2 == 0) {
      bVar2 = reply_send();
    }
    return bVar2;
  }
  if ((*(uint8_t *)(CONCAT11(iface_chan_hi,iface_chan_lo) + 2) & 0x40) == 0) {
    return 0;
  }
  bVar2 = (xram_00E0 | rx_count) & 0x80;
  if (bVar2 != 0) {
    return bVar2;
  }
  reply_len = '\0';
  if (xram_005A == 5) {
    if (bit_23_1 == '\x01') {
      xdata_block_xfer(0x5b,9,0,0x34,0);
      reply_len = '\t';
      bit_23_1 = '\0';
      reply_send_last();
      bVar2 = 0;
      reply_items_left = 0;
    }
    else {
      bVar2 = 5;
    }
    return bVar2;
  }
  if (reply_pending_cmd == 0) {
    bVar2 = xram_00EB >> 1 | (xram_005A < 5) << 7;
    if ((char)(xram_00EB << 7) < '\0') {
      return bVar2;
    }
    if (bit_24_0 != '\x01') {
      return bVar2;
    }
    if ((xram_005A == 3) && (emo_continuous == '\0')) {
      i24_ld_xdata_r0(0x95,0x3a);
      cVar3 = i24_test_r0();
      if (cVar3 == '\0') {
        return 0;
      }
      i24_dec_r0();
      i24_st_r0_xdata(0x95);
    }
    ram_29 = 0;
    ram_2A = 0x85;
    ram_2B = 0;
    ram_2C = 100;
    ram_33 = func_to_cmd_index();
    if (bit_22_7 != '\x01') {
      reply_put_reading_header();
    }
    reply_put_reading_value();
    reply_after_reading();
    reply_items_left = 0;
    bVar2 = reply_send_last();
    return bVar2;
  }
  if ((reply_pending_cmd == 0x21) && (reply_items_left == 0)) {
    reply_items_left = 0xb;
    ram_34 = reply_strings;
  }
  else if (reply_pending_cmd == 0x21) {
    ram_34 = (&reply_strings)[~reply_items_left + 0xc];
  }
  else {
    ram_34 = reply_pending_cmd;
    if (reply_pending_cmd == 0x22) {
      if (reply_items_left == 0) {
        reply_items_left = rom_6FB9;
      }
    }
    else {
      reply_items_left = 1;
    }
  }
  ram_2F = 0;
  do {
    if (2 < ram_2F) break;
    param_1 = '\0';
    param_2 = ram_2F;
    add16_r6r7_r4r5((char)((uint16_t)ram_34 * 5 >> 8),(char)((uint16_t)ram_34 * 5));
    puVar6 = &cmd_table;
    dptr_add_r6r7();
    uVar4 = *puVar6;
    puVar6 = &reply_buf;
    dptr_add_a();
    *puVar6 = uVar4;
    bVar1 = ram_2F != 0xff;
    ram_2F = ram_2F + 1;
  } while (bVar1);
  puVar6 = &xram_0037;
  dptr_add_a(reply_len);
  *puVar6 = 0x20;
  reply_len = reply_len + '\x04';
                    /* WARNING: Switch is manually overridden */
  switch((ram_34 - 0x13) * '\x03') {
  case 0:
    ram_33 = func_to_cmd_index();
    reply_put_mnemonic();
    break;
  case 3:
    if (meter_autorange == '\x01') {
      ram_2D = 0x6e;
      ram_2E = 0x9d;
      reply_put_string();
    }
    else if (meter_state == 0x6a) {
      ram_2D = 0x6e;
      ram_2E = 0xa6;
      reply_put_string();
    }
    else {
      digits_for_range();
      reply_len = reply_len + -1;
      ram_31 = 0x30;
      ram_2F = 0x23;
      ram_35 = ((ram_5B + 9U) / 3) * '\x03' + -9;
      reply_put_float();
      reply_len = reply_len + '\t';
    }
    break;
  case 6:
    if (bit_22_0 == '\0') {
      ram_2E = 0xb6;
    }
    else {
      ram_2E = 0xbb;
    }
    ram_2D = 0x6d;
    reply_put_string();
    ram_29 = '\0';
    ram_2A = 'u';
    reply_put_value_field();
    break;
  case 9:
    if (bit_22_1 == '\0') {
      ram_2E = 0xb6;
    }
    else {
      ram_2E = 0xbb;
    }
    ram_2D = 0x6d;
    reply_put_string();
    ram_29 = '\0';
    ram_2A = 'y';
    reply_put_value_field();
    break;
  case 0xc:
    ram_2D = 0x6e;
    ram_2E = 0xaf;
    reply_put_string();
    ram_29 = '\0';
    ram_2A = '}';
    ram_2B = '\0';
    ram_2C = 0x69;
    ram_33 = func_to_cmd_index();
    if (bit_22_7 != '\x01') {
      reply_put_reading_header();
    }
    reply_put_reading_value();
    break;
  case 0xf:
    ram_2D = 0x6e;
    ram_2E = 0xb1;
    reply_put_string();
    ram_29 = '\0';
    ram_2A = -0x7f;
    ram_2B = '\0';
    ram_2C = 0x6b;
    ram_33 = func_to_cmd_index();
    if (bit_22_7 != '\x01') {
      reply_put_reading_header();
    }
    reply_put_reading_value();
    break;
  case 0x12:
    break;
  case 0x15:
    cVar3 = (meter_mode & 3) + 0x31;
    pcVar7 = &reply_buf;
    dptr_add_a(reply_len);
    *pcVar7 = cVar3;
    reply_len = reply_len + '\x01';
    break;
  case 0x18:
    ram_33 = func_to_cmd_index();
    bVar2 = (uint8_t)((uint16_t)ram_33 * 3);
    ram_32 =
         *(uint8_t *)(CONCAT11((char)((uint16_t)ram_33 * 3 >> 8) +
                            ('n' - (((0xbf < bVar2) << 7) >> 7)),bVar2 + 0x40) +
                  (uint16_t)(meter_mode & 3));
    if ((ram_33 == 7) && ((meter_state & 0x70) == 0x60)) {
      ram_32 = ram_32 - 1;
    }
    do {
    } while (ram_32 == 0);
    bVar2 = ram_32 | 0x30;
    pbVar8 = &reply_buf;
    dptr_add_a(reply_len);
    *pbVar8 = bVar2;
    reply_len = reply_len + '\x01';
    break;
  case 0x1b:
    ram_2F = meter_mode >> 2 & 3;
    switch(ram_2F) {
    case 0:
      ram_2E = 0xb3;
      break;
    case 1:
      ram_2E = 0xb5;
      break;
    case 2:
      ram_2E = 0xb7;
      break;
    case 3:
      ram_2E = 0xb9;
    }
    ram_2D = 0x6e;
    reply_put_string();
    break;
  case 0x1e:
    break;
  case 0x21:
    if (cal_mode == '\x01') {
      if (cal_hot == '\0') {
        ram_2E = 0xc0;
      }
      else {
        ram_2E = 0xbb;
      }
    }
    else {
      ram_2E = 0xc5;
    }
    ram_2D = 0x6e;
    reply_put_string();
    break;
  case 0x24:
    if (bit_22_7 == '\0') {
      ram_2E = 0xcc;
    }
    else {
      ram_2E = 0xca;
    }
    ram_2D = 0x6e;
    reply_put_string();
    break;
  case 0x27:
    jcv_get_ptr();
    ram_2B = param_1;
    ram_2C = param_2;
    if (param_1 == '\0' && param_2 == 0) {
      ram_2B = '\a';
      ram_2C = 0x6c;
    }
    ram_2F = 0;
    do {
      if (5 < ram_2F) break;
      pbVar8 = (uint8_t *)CONCAT11(ram_2B,ram_2C);
      dptr_add_a(ram_2F);
      ram_30 = *pbVar8;
      reply_put_3digits();
      bVar1 = ram_2F != 0xff;
      ram_2F = ram_2F + 1;
    } while (bVar1);
    reply_len = reply_len + -1;
    break;
  case 0x2a:
    break;
  case 0x2d:
    cVar5 = rom_6FB9 - reply_items_left;
    ram_30 = cVar5 + 1;
    cVar3 = '\0';
    shl16_r6r7(2);
    ram_29 = cVar3 + '\x02';
    cVar3 = bit_23_7 << 7;
    bit_25_2 = bit_23_7 & 1;
    bit_23_7 = '\0';
    ram_2A = cVar5;
    cdp_load_slot();
    if ((cal_enable == '\x01') || (cal_seal_check(), -1 < cVar3)) {
      if (bit_23_7 == '\0') {
        ram_2E = 0xd2;
      }
      else {
        ram_2E = 0xd0;
      }
    }
    else {
      ram_2E = 0xce;
    }
    ram_2D = 0x6e;
    reply_put_string();
    bit_23_7 = bit_25_2 & 1;
    reply_put_3digits();
    ram_2F = 0x67;
    ram_31 = 0x40;
    reply_put_float();
    reply_len = reply_len + '\r';
    break;
  case 0x30:
    ram_30 = rms_get_byte();
    reply_put_3digits();
    reply_len = reply_len + -1;
    break;
  case 0x33:
    if (mains_60hz == '\0') {
      ram_2E = 0xb6;
    }
    else {
      ram_2E = 0xbb;
    }
    ram_2D = 0x6d;
    reply_put_string();
    reply_len = reply_len + -1;
    break;
  case 0x36:
    if (cr_enabled == '\0') {
      ram_2E = 0xb6;
    }
    else {
      ram_2E = 0xbb;
    }
    ram_2D = 0x6d;
    reply_put_string();
    reply_len = reply_len + -1;
    break;
  case 0x39:
    bVar2 = nv_get_iface_config();
    ram_30 = bVar2 & 0x9f;
    reply_put_3digits();
    reply_len = reply_len + -1;
    break;
  case 0x3c:
    ram_30 = funcswitch_step_count;
    reply_put_3digits();
    reply_len = reply_len + -1;
  }
  reply_items_left = reply_items_left - 1;
  if ((reply_items_left == 0) || (reply_pending_cmd == 0x22)) {
    reply_send_last();
    bVar2 = reply_items_left;
    if (reply_items_left == 0) {
      bVar2 = 0;
      reply_pending_cmd = 0;
    }
  }
  else {
    puVar6 = &reply_buf;
    dptr_add_a(reply_len);
    *puVar6 = 0x3b;
    reply_len = reply_len + '\x01';
    bVar2 = reply_send();
  }
  return bVar2;
}

/* ---- rms_get_byte  @0x5B93  (40 bytes)
 *      validate/repair, default 'A' */
char rms_get_byte(void)

{
  char cVar1;
  
  if (rms_byte == R6) {
    if (rms_byte == R7) {
      return rms_byte;
    }
  }
  else {
    if (rms_byte == R7) {
      cVar1 = rms_set_byte(xram_07FF + 'V');
      return cVar1;
    }
    if (xram_07FE + -0x55 == R7) {
      cVar1 = rms_set_byte(xram_07FF + 'V');
      return cVar1;
    }
    rms_byte = 'A';
  }
  xram_07FE = rms_byte + 'U';
  xram_07FF = rms_byte + -0x56;
  return rms_byte;
}

/* ---- rms_set_byte  @0x5BBB  (16 bytes)
 *      protected byte at 0x07FD (n, n+0x55, n-0x56) */
char rms_set_byte(char param_1)

{
  rms_byte = param_1;
  xram_07FE = param_1 + 'U';
  xram_07FF = param_1 + -0x56;
  return param_1;
}

