/* settings.c - triple-redundant settings bytes: GPIB address, talk-only, 50/60 Hz, CR, seal, speed
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 17 functions, 314 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/settings.c.
 */
#include "pm2525.h"

/* ---- speed_force_fast  @0x172E  (24 bytes)
 *      some functions measure in SPEED 3 while ranging */
void speed_force_fast(void)

{
  uint8_t bVar1;
  
  bVar1 = meter_state & 0xf;
  if (bit_20_3 == '\x01') {
    if ((bVar1 != 9) && (bVar1 != 0xc)) {
      return;
    }
  }
  else if (bVar1 == 0) {
    return;
  }
  speed_b1 = 1;
  speed_b0 = 0;
  return;
}

/* ---- speed_restore  @0x1746  (10 bytes) */
void speed_restore(void)

{
  meter_mode = meter_mode & 0xfc | ram_35 & 3;
  return;
}

/* ---- speed_store  @0x3DE8  (44 bytes)
 *      SPEED -> XDATA 0x01CC (kept over power-off) */
void speed_store(void)

{
  speed_b1 = 0;
  if (ram_2E == '\x10') {
    speed_b0 = 0;
  }
  else if (ram_2E == '\x12') {
    speed_b0 = 0;
    speed_b1 = 1;
  }
  else if (ram_2E == '\x03') {
    meter_mode = speed_saved | meter_mode & 0xfc;
  }
  else {
    speed_b0 = 1;
  }
  return;
}

/* ---- speed_load  @0x3E14  (71 bytes) */
char speed_load(void)

{
  uint8_t bVar1;
  
  ram_34 = 0;
  while (ram_34 < 3) {
    bVar1 = (meter_state & 0xf) * '\x03';
    if (*(char *)(CONCAT11('n' - (((0x2b < bVar1) << 7) >> 7),bVar1 - 0x2c) + (uint16_t)ram_34)
        == '\0') {
      ram_34 = ram_34 + 1;
    }
    else {
      meter_mode = meter_mode & 0xfc | ram_34;
      if ((meter_state & 0xf) == 1) {
        speed_saved = ram_34 & 3;
      }
      ram_34 = 0xff;
    }
  }
  return ram_34 - 3;
}

/* ---- nv_get_iface_config  @0x5ACF  (20 bytes)
 *      byte 1; invalid/31 -> 22 written back */
uint8_t nv_get_iface_config(void)

{
  char cVar1;
  uint8_t bVar2;
  
  bVar2 = nv_setting_read(1);
  cVar1 = F0;
  if ((cVar1 == '\x01') || ((bVar2 & 0x1f) == 0x1f)) {
    bVar2 = nv_setting_write(0x16,1);
  }
  return bVar2;
}

/* ---- nv_set_iface_config  @0x5AE3  (6 bytes) */
void nv_set_iface_config(void)

{
  nv_setting_write(1);
  return;
}

/* ---- mains_set_60hz  @0x5AE9  (4 bytes)
 *      SIX ON */
void mains_set_60hz(void)

{
  char cVar1;
  
  cVar1 = nv_setting_write(0x55,2);
  mains_60hz = cVar1 != '\0';
  return;
}

/* ---- mains_load_setting  @0x5AED  (8 bytes) */
void mains_load_setting(void)

{
  char cVar1;
  char cVar2;
  
  cVar2 = nv_setting_read(2);
  cVar1 = F0;
  if (cVar1 != '\0') {
    cVar2 = nv_setting_write(0,2);
  }
  mains_60hz = cVar2 != '\0';
  return;
}

/* ---- mains_set_50hz  @0x5AF5  (13 bytes)
 *      SIX OFF */
void mains_set_50hz(void)

{
  char cVar1;
  
  cVar1 = nv_setting_write(0,2);
  mains_60hz = cVar1 != '\0';
  return;
}

/* ---- cr_set_on  @0x5B02  (4 bytes)
 *      CR ON: append \r to output */
void cr_set_on(void)

{
  char cVar1;
  
  cVar1 = nv_setting_write(0x55,3);
  cr_enabled = cVar1 != '\0';
  return;
}

/* ---- cr_load_setting  @0x5B06  (8 bytes) */
void cr_load_setting(void)

{
  char cVar1;
  char cVar2;
  
  cVar2 = nv_setting_read(3);
  cVar1 = F0;
  if (cVar1 != '\0') {
    cVar2 = nv_setting_write(0,3);
  }
  cr_enabled = cVar2 != '\0';
  return;
}

/* ---- cr_set_off  @0x5B0E  (13 bytes) */
void cr_set_off(void)

{
  char cVar1;
  
  cVar1 = nv_setting_write(0,3);
  cr_enabled = cVar1 != '\0';
  return;
}

/* ---- nv_setting_read  @0x5B1B  (46 bytes)
 *      R2 = byte no.: 2-of-3 vote, repair; F0 = 1 if all copies differ */
void nv_setting_read(char *param_1)

{
  char cVar1;
  char cVar2;
  
  F0 = 0;
  nv_addr_copy3();
  cVar2 = *param_1;
  nv_addr_copy2();
  nv_addr_copy1(*param_1);
  cVar1 = *param_1;
  if (cVar1 == R6) {
    if (cVar1 == R7) {
      return;
    }
    cVar2 = nv_addr_copy3();
    *param_1 = cVar2;
    return;
  }
  if (cVar1 == R7) {
    cVar2 = nv_addr_copy2(cVar1);
    *param_1 = cVar2;
    return;
  }
  if (cVar2 == R6) {
    *param_1 = cVar2;
    return;
  }
  F0 = 1;
  return;
}

/* ---- nv_addr_copy1  @0x5B49  (8 bytes)
 *      0x03CA + n - 1 */
void nv_addr_copy1(void)

{
  char cVar1;
  
  cVar1 = R2;
  do {
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- nv_addr_copy2  @0x5B51  (8 bytes)
 *      0x0599 + n - 1 */
void nv_addr_copy2(void)

{
  char cVar1;
  
  cVar1 = R2;
  do {
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- nv_addr_copy3  @0x5B59  (14 bytes)
 *      0x0768 + n - 1 */
void nv_addr_copy3(void)

{
  char cVar1;
  
  cVar1 = R2;
  do {
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}

/* ---- nv_setting_write  @0x5B67  (13 bytes)
 *      write A to byte R2 in all three copies */
void nv_setting_write(uint8_t *param_1)

{
  uint8_t uVar1;
  
  uVar1 = nv_addr_copy1();
  *param_1 = uVar1;
  uVar1 = nv_addr_copy2();
  *param_1 = uVar1;
  uVar1 = nv_addr_copy3();
  *param_1 = uVar1;
  return;
}

