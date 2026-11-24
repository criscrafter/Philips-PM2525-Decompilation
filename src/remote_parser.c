/* remote_parser.c - character-level parser for remote commands
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 35 functions, 1047 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/remote_parser.c.
 */
#include "pm2525.h"

/* ---- task_remote_parse  @0x543C  (39 bytes)
 *      swap in parser context (XDATA 0x00DB, 13 bytes + float 0x01D1) and run one parser step */
void task_remote_parse(void)

{
  xdata_to_iram(0xdb,0x2a,0xd);
  fp_ld_xdata_r0(0x1d1,0x5f);
  parser_step();
  fp_st_r0_xdata(0x1d1,0x5f);
  iram_to_xdata(0xdb,0x2a,0xd);
  return;
}

/* ---- task_remote_parse_tail  @0x5463  (5 bytes) */
void task_remote_parse_tail(void)

{
  parser_restart();
  fp_st_r0_xdata(0x1d1,0x5f);
  iram_to_xdata(0xdb,0x2a,0xd);
  return;
}

/* ---- parser_restart  @0x77AE  (8 bytes) */
void parser_restart(void)

{
  bit_2A_0 = 0;
  ram_2F = 0;
  parser_reset();
  return;
}

/* ---- parser_step  @0x77B6  (63 bytes) */
// DECOMPILATION FAILED: Exception while decompiling CODE:77b6: Decompiler process died

/* ---- rx_clear  @0x77D7  (7 bytes) */
void rx_clear(void)

{
  rx_index = 0;
  rx_count = 0;
  return;
}

/* ---- parser_reset  @0x7804  (15 bytes) */
void parser_reset(void)

{
  uint8_t *puVar1;
  
  ram_34 = 0;
  ram_2D = 0;
  puVar1 = &cmd_table;
  if (bit_2A_0 != '\0') {
    puVar1 = (uint8_t *)0x0;
  }
  ram_36 = (char)((uint16_t)puVar1 >> 8);
  ram_35 = (char)puVar1;
  return;
}

/* ---- parser_set_table_ptr  @0x7813  (7 bytes) */
void parser_set_table_ptr(uint16_t param_1)

{
  ram_36 = (char)((uint16_t)param_1 >> 8);
  ram_35 = (char)param_1;
  return;
}

/* ---- parser_dispatch_char  @0x781A  (3 bytes)
 *      ';' and ',' handling, then per-state jump table 0x7867 */
void parser_dispatch_char(char param_1,uint8_t param_2,char param_3)

{
  char cVar1;
  uint8_t *puVar2;
  short sVar3;
  
  if ((param_2 == 0x3b) || (param_2 == 0x2c)) {
    parser_end_token();
    if (-1 < param_1) {
      if (bit_2D_6 != '\0') {
        ram_2D = *(uint8_t *)(CONCAT11(ram_36,ram_35) + 3);
        bit_2D_4 = 0;
        ram_34 = 9;
        rx_consume_char();
        return;
      }
      rx_consume_char();
      ram_34 = 0;
      ram_2D = 0;
      puVar2 = &cmd_table;
      if (bit_2A_0 != '\0') {
        puVar2 = (uint8_t *)0x0;
      }
      ram_36 = (uint8_t)((uint16_t)puVar2 >> 8);
      ram_35 = SUB21(puVar2,0);
    }
    return;
  }
  cVar1 = (0x1f < param_2) << 7;
  if (0x1f >= param_2) {
LAB_CODE_789d:
    rx_consume_char();
    return;
  }
  if ((ram_34 >> 5 & 1) != 0) {
    parser_number_accumulate();
    return;
  }
  ram_2B = 0;
  ram_2C = 0;
  if (((ram_34 >> 4 & 1) == 1) || ((ram_34 >> 3 & 1) != 0)) {
                    /* WARNING: Could not recover jumptable at 0x7866. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (*(code *)((uint16_t)(ram_34 * '\x03') + 0x784f))(param_1);
    return;
  }
  parser_is_letter();
  sVar3 = CONCAT11(ram_36,ram_35);
  if (-1 < cVar1) goto LAB_CODE_78a3;
  if (ram_34 == 0) {
    if (param_2 == 0x20) goto LAB_CODE_789d;
  }
  else {
    while( true ) {
      while (ram_34 != 0) {
        rx_insert_char(*(uint8_t *)(sVar3 + (uint16_t)(ram_34 - 1)));
        ram_34 = ram_34 - 1;
        if (ram_34 == 0) {
          parser_next_entry();
          parser_set_table_ptr();
          return;
        }
      }
      parser_next_entry();
LAB_CODE_78a3:
      if (*(char *)(sVar3 + (uint16_t)ram_34) == '\0') break;
      if (*(char *)(sVar3 + (uint16_t)ram_34) == param_3) {
        parser_set_table_ptr();
        if ((ram_34 != 2) &&
           (ram_34 = ram_34 + 1, *(char *)(sVar3 + (uint16_t)ram_34) != ' ')) {
          rx_consume_char();
          return;
        }
        ram_2E = *(uint8_t *)(sVar3 + 4);
        ram_2D = *(char *)(sVar3 + 3);
        ram_2F = 0x20;
        if (*(char *)(sVar3 + 3) == '\0') {
          ram_34 = 0x12;
          ram_2F = 0xa5;
          return;
        }
        ram_34 = 8;
        return;
      }
    }
  }
  bit_23_6 = 1;
  ram_34 = 0x12;
  rx_consume_char();
  return;
}

/* ---- parser_dispatch_char  @0x781D  (222 bytes)
 *      ';' and ',' handling, then per-state jump table 0x7867 */
void parser_dispatch_char(char param_1,uint8_t param_2,char param_3)

{
  char cVar1;
  uint8_t *puVar2;
  short sVar3;
  
  if ((param_2 == 0x3b) || (param_2 == 0x2c)) {
    parser_end_token();
    if (-1 < param_1) {
      if (bit_2D_6 != '\0') {
        ram_2D = *(uint8_t *)(CONCAT11(ram_36,ram_35) + 3);
        bit_2D_4 = 0;
        ram_34 = 9;
        rx_consume_char();
        return;
      }
      rx_consume_char();
      ram_34 = 0;
      ram_2D = 0;
      puVar2 = &cmd_table;
      if (bit_2A_0 != '\0') {
        puVar2 = (uint8_t *)0x0;
      }
      ram_36 = (uint8_t)((uint16_t)puVar2 >> 8);
      ram_35 = SUB21(puVar2,0);
    }
    return;
  }
  cVar1 = (0x1f < param_2) << 7;
  if (0x1f >= param_2) {
LAB_CODE_789d:
    rx_consume_char();
    return;
  }
  if ((ram_34 >> 5 & 1) != 0) {
    parser_number_accumulate();
    return;
  }
  ram_2B = 0;
  ram_2C = 0;
  if (((ram_34 >> 4 & 1) == 1) || ((ram_34 >> 3 & 1) != 0)) {
                    /* WARNING: Could not recover jumptable at 0x7866. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (*(code *)((uint16_t)(ram_34 * '\x03') + 0x784f))(param_1);
    return;
  }
  parser_is_letter();
  sVar3 = CONCAT11(ram_36,ram_35);
  if (-1 < cVar1) goto LAB_CODE_78a3;
  if (ram_34 == 0) {
    if (param_2 == 0x20) goto LAB_CODE_789d;
  }
  else {
    while( true ) {
      while (ram_34 != 0) {
        rx_insert_char(*(uint8_t *)(sVar3 + (uint16_t)(ram_34 - 1)));
        ram_34 = ram_34 - 1;
        if (ram_34 == 0) {
          parser_next_entry();
          parser_set_table_ptr();
          return;
        }
      }
      parser_next_entry();
LAB_CODE_78a3:
      if (*(char *)(sVar3 + (uint16_t)ram_34) == '\0') break;
      if (*(char *)(sVar3 + (uint16_t)ram_34) == param_3) {
        parser_set_table_ptr();
        if ((ram_34 != 2) &&
           (ram_34 = ram_34 + 1, *(char *)(sVar3 + (uint16_t)ram_34) != ' ')) {
          rx_consume_char();
          return;
        }
        ram_2E = *(uint8_t *)(sVar3 + 4);
        ram_2D = *(char *)(sVar3 + 3);
        ram_2F = 0x20;
        if (*(char *)(sVar3 + 3) == '\0') {
          ram_34 = 0x12;
          ram_2F = 0xa5;
          return;
        }
        ram_34 = 8;
        return;
      }
    }
  }
  bit_23_6 = 1;
  ram_34 = 0x12;
  rx_consume_char();
  return;
}

/* ---- parser_next_entry  @0x78FB  (6 bytes)
 *      cmd_table entry = 5 bytes */
void parser_next_entry(void)

{
  char cVar1;
  
  cVar1 = '\x05';
  do {
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- parser_st_header  @0x7901  (9 bytes) */
void parser_st_header(void)

{
  char in_PSW;
  
  parser_is_letter();
  if (in_PSW < '\0') {
    ram_34 = 10;
    return;
  }
  rx_consume_char();
  return;
}

/* ---- parser_st_param_start  @0x790A  (127 bytes) */
void parser_st_param_start(uint8_t param_1)

{
  char cVar1;
  
  cVar1 = (param_1 < 0x20) << 7;
  if (param_1 == 0x20) {
    rx_consume_char();
    return;
  }
  if (bit_2D_1 != '\0') {
    parser_is_digit();
    if (-1 < cVar1) {
      ram_30 = 0;
      ram_2F = ram_2F + '\x02';
      ram_34 = 0xd;
      return;
    }
    bit_2D_1 = '\0';
  }
  if (bit_2D_2 != '\0') {
    ram_34 = 0xe;
    parser_sign_char();
    if (-1 < cVar1) {
      i24_clr_r0(0x32);
      parser_set_kind(3);
      return;
    }
    bit_2D_2 = '\0';
  }
  if (bit_2D_3 != '\0') {
    if (((param_1 == 0x2e) || (param_1 == 0x2d)) ||
       (cVar1 = (0xfd < param_1 - 0x2d) << 7, param_1 == 0x2b)) {
LAB_CODE_7951:
      ram_34 = 0x20;
      parser_set_kind(4);
      return;
    }
    parser_is_digit();
    if (-1 < cVar1) goto LAB_CODE_7951;
    bit_2D_3 = '\0';
  }
  if (bit_2D_5 != '\0') {
    if (param_1 == 0x3f) {
      parser_set_kind(0x86);
      goto LAB_CODE_7a15;
    }
    bit_2D_5 = '\0';
  }
  if (bit_2D_0 != '\0') {
    if ((param_1 & 0x5f) == 0x4f) {
      ram_34 = 0xb;
      rx_consume_char();
      return;
    }
    bit_2D_0 = '\0';
  }
  if (bit_2D_4 != '\0') {
    ram_2F = 0x60;
    ram_34 = 0x10;
    ram_30 = rx_index;
    ram_31 = 0;
    return;
  }
  bit_23_6 = 1;
LAB_CODE_7a15:
  ram_34 = 0x12;
  rx_consume_char();
  return;
}

/* ---- parser_flag_kind4  @0x7954  (5 bytes) */
void parser_flag_kind4(void)

{
  parser_set_kind(4);
  return;
}

/* ---- parser_st_mnemonic  @0x798E  (21 bytes) */
void parser_st_mnemonic(uint8_t param_1)

{
  char cVar1;
  
  cVar1 = (param_1 < 0x20) << 7;
  if (param_1 == 0x20) {
    rx_consume_char();
    return;
  }
  parser_is_letter();
  if (cVar1 < '\0') {
    ram_2F = 0;
    ram_34 = 10;
    return;
  }
  parser_reset();
  return;
}

/* ---- parser_st_mnemonic_more  @0x79A3  (31 bytes) */
void parser_st_mnemonic_more(uint8_t param_1)

{
  if ((param_1 & 0x5f) == 0x4e) {
    parser_set_kind(0x81);
    ram_34 = 0x12;
    rx_consume_char();
    return;
  }
  if ((param_1 & 0x5f) == 0x46) {
    ram_34 = 0xc;
    rx_consume_char();
    return;
  }
  rx_insert_char(0x4f);
  ram_34 = 10;
  bit_2D_0 = 0;
  return;
}

/* ---- parser_st_on_off  @0x79C2  (19 bytes) */
void parser_st_on_off(uint8_t param_1)

{
  if ((param_1 & 0x5f) == 0x46) {
    parser_set_kind(0x80);
    ram_34 = 0x12;
    rx_consume_char();
    return;
  }
  rx_insert_char(0x46);
  rx_insert_char(0x4f);
  ram_34 = 10;
  bit_2D_0 = 0;
  return;
}

/* ---- parser_st_number  @0x79D5  (93 bytes) */
void parser_st_number(uint8_t param_1)

{
  char cVar1;
  uint8_t bVar2;
  char in_PSW;
  
  bVar2 = parser_is_digit();
  if (in_PSW < '\0') {
    if (((param_1 != 0x2e) && ((param_1 & 0x5f) != 0x45)) || (bit_2D_3 != '\x01')) goto LAB_CODE_7a10;
  }
  else {
    cVar1 = OV;
    if ((cVar1 != '\x01') && (!CARRY1(ram_30 * '\n',bVar2))) {
      ram_30 = ram_30 * '\n' + bVar2;
      rx_consume_char();
      return;
    }
    if (bit_2D_2 != '\0') {
      ram_31 = 0;
      ram_32 = 0;
      ram_34 = ram_34 + '\x01';
      parser_set_kind(3);
      return;
    }
    if (bit_2D_3 == '\0') {
      ram_30 = -1;
LAB_CODE_7a10:
      parser_set_kind(0x82);
      ram_34 = 0x12;
      rx_consume_char();
      return;
    }
  }
  ram_31 = 0;
  ram_32 = 0;
  ram_34 = 0x22;
  F0 = 0;
  parser_flag_kind4(0);
  i24_to_fp(0x32);
  return;
}

/* ---- parser_st_digits  @0x7A32  (97 bytes) */
void parser_st_digits(void)

{
  uint8_t bVar1;
  uint8_t *puVar2;
  uint8_t *pbVar3;
  uint8_t *puVar4;
  uint8_t uVar5;
  uint8_t bVar6;
  char cVar7;
  char in_PSW;
  
  bVar6 = parser_is_digit();
  if (in_PSW < '\0') {
    if (bit_2D_3 == '\0') goto LAB_CODE_7a15;
    cVar7 = i24_test_r0(0x32);
    if (cVar7 == '\0') {
      ram_34 = 0x20;
      return;
    }
  }
  else {
    puVar4 = &ram_32;
    puVar2 = &ram_5E;
    i24_copy_r1_to_r0();
    uVar5 = *puVar4;
    *puVar4 = 10;
    i24_div10_rem();
    *puVar4 = uVar5;
    if (-1 < in_PSW) {
      pbVar3 = puVar2 + -2;
      bVar1 = *pbVar3;
      *pbVar3 = bVar6 + *pbVar3;
      puVar2[-1] = puVar2[-1] - ((CARRY1(bVar6,bVar1) << 7) >> 7);
      *puVar2 = *puVar2;
      i24_copy_r1_to_r0(0x32,0x5e);
      rx_consume_char();
      return;
    }
    if (bit_2D_3 == '\0') {
      i24_ld_max_r0(0x32);
LAB_CODE_7a15:
      parser_end_token();
      ram_34 = 0x12;
      rx_consume_char();
      return;
    }
  }
  if (ram_34 == '\x0f') {
    i24_neg();
  }
  ram_34 = 0x22;
  F0 = 0;
  parser_flag_kind4(0);
  i24_to_fp(0x32);
  return;
}

/* ---- parser_number_accumulate  @0x7A93  (37 bytes) */
void parser_number_accumulate(uint8_t param_1)

{
  uint8_t bVar1;
  
  F0 = bit_2B_0 & 1;
  parse_number_char(0x33,0x5f,param_1);
  bVar1 = F0;
  bit_2B_0 = bVar1 & 1;
  if (ram_34 == '\x12') {
    bit_23_6 = 1;
  }
  rx_consume_char();
  return;
}

/* ---- rx_consume_char  @0x7AB8  (5 bytes) */
void rx_consume_char(void)

{
  ram_31 = ram_31 + '\x01';
  rx_consume_char();
  return;
}

/* ---- parser_st_query  @0x7ABD  (6 bytes) */
void parser_st_query(void)

{
  ram_2F = 0x40;
  ram_34 = 0x10;
  ram_30 = rx_index;
  ram_31 = 0;
  return;
}

/* ---- rx_consume_char  @0x7AC3  (5 bytes) */
void rx_consume_char(void)

{
  rx_index = rx_index + '\x01';
  rx_count = rx_count + -1;
  return;
}

/* ---- rx_insert_char  @0x7AC8  (33 bytes) */
void rx_insert_char(uint8_t param_1,uint8_t *param_2)

{
  uint8_t uVar1;
  uint8_t bVar2;
  
  parser_getc();
  if (rx_index != '\0') {
    rx_index = rx_index + -1;
    rx_count = rx_count + 1;
    return;
  }
  bVar2 = rx_count & 0x3f;
  if (bVar2 != 0) {
    uVar1 = param_1;
    do {
      param_1 = *param_2;
      *param_2 = uVar1;
      param_2 = param_2 + 1;
      bVar2 = bVar2 - 1;
      uVar1 = param_1;
    } while (bVar2 != 0);
  }
  *param_2 = param_1;
  rx_count = rx_count + 1;
  return;
}

/* ---- parser_end_token  @0x7AE9  (50 bytes) */
void parser_end_token(uint8_t param_1)

{
  uint8_t bVar1;
  char cVar2;
  
  bVar1 = ram_34;
  ram_34 = 0x12;
  if ((bVar1 >> 5 & 1) == 1) {
    F0 = bit_2B_0 & 1;
    cVar2 = parse_number_char(0x33,0x5f,ram_2B,ram_2C,bVar1,0x3b);
    if (cVar2 != -1) {
      ram_2F = ram_2F | 0x80;
      ram_34 = 0x12;
      return;
    }
  }
  else if (((bVar1 >> 4 & 1) == 1) || ((bVar1 >> 3 & 1) == 1)) {
                    /* WARNING: Switch is manually overridden */
    switch(bVar1 * '\x03') {
    case 0x18:
      parser_end_param();
      return;
    case 0x1b:
      ram_34 = 0x12;
      return;
    case 0x1e:
      parser_end_param();
      return;
    case 0x21:
      parser_end_param1();
      return;
    case 0x24:
      parser_end_param2();
      return;
    case 0x27:
      parser_emit_token();
      return;
    case 0x2a:
      parser_emit_token();
      return;
    case 0x2d:
      parser_emit_token();
      i24_neg(0x32);
      return;
    case 0x30:
      parser_set_kind(0xd0);
      return;
    case 0x33:
      parser_end_reset(param_1);
      return;
    case 0x36:
      ram_34 = 0x12;
      return;
    case 0x39:
    }
  }
  else if (bVar1 == 0) {
    ram_34 = 0x12;
    return;
  }
  bit_23_6 = 1;
  return;
}

/* ---- parser_emit_token  @0x7B47  (10 bytes)
 *      2Fh |= 0x80, wait for consumer */
void parser_emit_token(void)

{
  ram_2F = ram_2F | 0x80;
  ram_34 = 0x12;
  return;
}

/* ---- parser_end_reset  @0x7B51  (11 bytes) */
void parser_end_reset(void)

{
  ram_31 = 0;
  ram_2F = 0;
  parser_set_kind(0xd0);
  return;
}

/* ---- parser_end_param  @0x7B5C  (10 bytes) */
void parser_end_param(void)

{
  if (bit_2D_7 == '\0') {
    bit_23_6 = 1;
  }
  else {
    ram_2F = ram_2F & 0xb8 | 0x85;
  }
  return;
}

/* ---- parser_set_kind  @0x7B61  (8 bytes) */
void parser_set_kind(uint8_t param_1)

{
  ram_2F = ram_2F & 0xb8 | param_1;
  return;
}

/* ---- parser_end_param1  @0x7B6E  (15 bytes) */
void parser_end_param1(void)

{
  if (bit_2D_4 == '\0') {
    bit_23_6 = 1;
    return;
  }
  ram_31 = 1;
  parser_insert_terminator();
  rx_consume_char();
  parser_set_kind(0xd0);
  return;
}

/* ---- parser_end_param2  @0x7B7D  (20 bytes) */
void parser_end_param2(void)

{
  if (bit_2D_4 == '\0') {
    bit_23_6 = 1;
    return;
  }
  rx_insert_char(0x46);
  ram_31 = 2;
  parser_insert_terminator();
  rx_consume_char();
  rx_consume_char();
  parser_set_kind(0xd0);
  return;
}

/* ---- parser_insert_terminator  @0x7B91  (9 bytes) */
void parser_insert_terminator(void)

{
  rx_insert_char(0x4f);
  ram_30 = rx_index;
  return;
}

/* ---- parser_is_letter  @0x7B9A  (12 bytes) */
char parser_is_letter(uint8_t param_1)

{
  char cVar1;
  
  param_1 = param_1 & 0x5f;
  cVar1 = param_1 + 0xa5;
  if (param_1 < 0x5b) {
    cVar1 = param_1 + 0xbf;
  }
  return cVar1;
}

/* ---- parser_sign_char  @0x7BA6  (15 bytes) */
char parser_sign_char(uint8_t param_1)

{
  char cVar1;
  
  if (param_1 == 0x2b) {
    cVar1 = rx_consume_char();
    return cVar1;
  }
  if (param_1 == 0x2d) {
    ram_34 = ram_34 + '\x01';
    cVar1 = rx_consume_char();
    return cVar1;
  }
  cVar1 = param_1 - 0x3a;
  if (param_1 < 0x3a) {
    cVar1 = param_1 - 0x30;
  }
  return cVar1;
}

/* ---- parser_is_digit  @0x7BB5  (9 bytes) */
char parser_is_digit(uint8_t param_1)

{
  char cVar1;
  
  cVar1 = param_1 - 0x3a;
  if (param_1 < 0x3a) {
    cVar1 = param_1 - 0x30;
  }
  return cVar1;
}

/* ---- parser_getc  @0x7BBE  (15 bytes)
 *      A = iface_rx_buf[rx_index] */
uint8_t parser_getc(void)

{
  uint8_t *puVar1;
  
  puVar1 = (uint8_t *)(uint16_t)(rx_index + 0x13);
  if (0xec < rx_index) {
    puVar1 = (uint8_t *)CONCAT11(1,rx_index + 0x13);
  }
  return *puVar1;
}

