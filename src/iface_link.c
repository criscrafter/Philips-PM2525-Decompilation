/* iface_link.c - option-board link (Pico/UR488 side): framing, events, status, channels
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 35 functions, 825 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/iface_link.c.
 */
#include "pm2525.h"

/* ---- iface_select_pending  @0x00E4  (45 bytes)
 *      pick pending interface channel (xdata 0x56/0x53) into ptr 1Dh:1Eh */
void iface_select_pending(void)

{
  if (xram_0058 < '\0') {
    iface_chan_lo = 0x56;
    xram_005A = 0;
  }
  else {
    if (-1 < xram_0055) {
      iface_chan_hi = 0;
      iface_chan_lo = 0;
      return;
    }
    iface_chan_lo = 0x53;
    xram_005A = xram_0059;
  }
  iface_chan_hi = 0;
  return;
}

/* ---- iface_current_poll  @0x5D37  (9 bytes) */
void iface_current_poll(void)

{
  iface_send_status_now(iface_chan_lo);
  return;
}

/* ---- iface_report_status  @0x5D40  (31 bytes)
 *      result/trigger state -> interface status byte */
void iface_report_status(void)

{
  bool bVar1;
  uint8_t uVar2;
  uint8_t uVar3;
  
  uVar3 = ram_2F;
  uVar2 = ram_2E;
  if (iface_chan_hi == '\0' && iface_chan_lo == '\0') {
    return;
  }
  bit_24_0 = 0;
  ram_2E = (xram_00EA ^ 0x80) & 0x80 | (result_flags >> 3 & 1) << 4 | (bit_24_6 & 1) << 1;
  bVar1 = xram_00EA != ram_2E;
  xram_00EA = ram_2E;
  if (bVar1) {
    iface_current_poll();
  }
  ram_2F = uVar3;
  ram_2E = uVar2;
  return;
}

/* ---- iface_status_compose  @0x5D5F  (47 bytes)
 *      status byte: b0 reading/reply pending, b1 24h.6, b4 result flag 3, b7 kept */
void iface_status_compose(uint8_t param_1)

{
  bool bVar1;
  uint8_t bVar2;
  uint8_t uStackX_0;
  uint8_t in_stack_000000ff;
  
  bVar2 = bit_24_0 << 7 | reply_len & 0x80;
  if (reply_pending_cmd != '\0') {
    bVar2 = 0x80;
  }
  ram_2E = xram_00EA & 0x80 | bVar2 >> 7 | (param_1 >> 3 & 1) << 4 | (bit_24_6 & 1) << 1;
  bVar1 = xram_00EA != ram_2E;
  xram_00EA = ram_2E;
  if (bVar1) {
    iface_current_poll();
  }
  ram_2F = uStackX_0;
  ram_2E = in_stack_000000ff;
  return;
}

/* ---- iface_ctx_load  @0x5DF4  (11 bytes)
 *      XDATA 0x00EA -> 2Eh/2Fh */
void iface_ctx_load(void)

{
  ram_2E = xram_00EA;
  ram_2F = xram_00EB;
  return;
}

/* ---- iface_ctx_save  @0x5DFF  (11 bytes) */
void iface_ctx_save(void)

{
  xram_00EA = ram_2E;
  xram_00EB = ram_2F;
  return;
}

/* ---- iface_poll_channel  @0x7BDA  (22 bytes)
 *      DPTR=channel descriptor (xdata); service interface board */
void iface_poll_channel(void)

{
  iface_load_channel();
  if ((-1 < rx_count) && (bit_2F_2 != '\0')) {
    bit_2F_2 = '\0';
    rx_count = -0x40;
  }
  iface_i2c_read_block();
  iface_save_channel();
  return;
}

/* ---- iface_send_channel  @0x7BF0  (34 bytes) */
void iface_send_channel(uint8_t param_1,uint8_t param_2)

{
  uint8_t uVar1;
  char in_PSW;
  
  uVar1 = iface_load_channel();
  if (in_PSW < '\0') {
    iface_send_f1(uVar1);
  }
  else {
    uVar1 = 0xb8;
    if (((char)param_1 < '\0') || (uVar1 = 0x58, (param_1 >> 6 & 1) == 1)) goto LAB_CODE_7c09;
  }
  uVar1 = 0;
LAB_CODE_7c09:
  iface_i2c_write_block(0,uVar1);
  iface_write_ctrl(0xfa);
  iface_read_status();
  if (-1 < in_PSW) {
    iface_handle_event();
  }
  iface_save_channel(param_2);
  return;
}

/* ---- iface_send_status_now  @0x7C12  (9 bytes) */
void iface_send_status_now(void)

{
  iface_load_channel();
  iface_send_status();
  iface_save_channel();
  return;
}

/* ---- iface_send  @0x7C24  (18 bytes)
 *      hand the reply buffer to the interface board */
void iface_send(uint8_t param_1)

{
  iface_load_channel();
  if (reply_len < '\0') {
    iface_save_channel(param_1 & 0xbf | 0x10);
    return;
  }
  iface_save_channel();
  return;
}

/* ---- iface_clear_remote  @0x7C43  (15 bytes) */
void iface_clear_remote(void)

{
  iface_load_channel();
  if ((char)ram_2F < '\0') {
    iface_save_channel();
    return;
  }
  ram_2F = ram_2F & 0xef;
  iface_save_channel();
  return;
}

/* ---- iface_send_config_address  @0x7C52  (54 bytes)
 *      F4 + C0|address to the interface board */
void iface_send_config_address(uint8_t param_1)

{
  uint8_t bVar1;
  char cVar2;
  char cVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  
  bVar4 = iface_load_channel();
  bVar5 = bVar4 & 0x1f;
  bVar1 = 0;
  if ((bVar4 & 0xc0) != 0) {
    bVar1 = bVar4 & 0xc0;
  }
  cVar2 = -0xc;
  iface_write_ctrl(0xf4,bVar5);
  cVar3 = cVar2 + '\x01';
  if (((bVar1 >> 6 & 1) == 1) || (cVar3 = cVar2 + '\x02', (char)bVar1 < '\0')) {
    iface_write_ctrl(cVar3);
  }
  iface_send_f4_address(param_1 & 0xe0 | bVar5);
  iface_save_channel();
  return;
}

/* ---- iface_receive_channel  @0x7C8E  (21 bytes)
 *      returns C=1 when a byte/command arrived */
void iface_receive_channel(uint8_t param_1)

{
  char in_PSW;
  
  iface_load_channel();
  iface_write_ctrl(0xfa);
  iface_read_status();
  if (-1 < in_PSW) {
    iface_handle_event();
  }
  iface_save_channel(param_1);
  return;
}

/* ---- iface_save_channel  @0x7CEC  (21 bytes) */
uint8_t
iface_save_channel(uint8_t param_1,uint8_t param_2,uint8_t param_3,uint8_t param_4,
                  uint8_t param_5,uint8_t param_6)

{
  uint8_t *puVar1;
  
  iface_ctx_save(param_1);
  puVar1 = (uint8_t *)CONCAT11(param_4,param_3);
  *puVar1 = param_6;
  puVar1[1] = param_5;
  puVar1[2] = param_2;
  return param_1;
}

/* ---- iface_i2c_read_block  @0x7D01  (40 bytes) */
uint8_t iface_i2c_read_block(uint8_t param_1,uint8_t param_2,char param_3)

{
  uint8_t uVar1;
  uint8_t bVar2;
  uint8_t in_PSW;
  
  if ((char)param_1 < '\0') {
    iface_start_read();
    if (-1 < (char)in_PSW) {
                    /* WARNING: Subroutine does not return */
      i2cA_recv_byte();
    }
    i2cA_stop();
    iface_start_write();
    if ((char)in_PSW < '\0') {
      if (((param_1 >> 4 & 1) != 0) && (reply_len < '\0')) {
        iface_reply_done();
      }
      in_PSW = in_PSW & 0xdd;
      bVar2 = iface_mode_match(0,param_2 & 0xf8);
      if ((char)in_PSW < '\0') {
        ram_2F = bVar2 & 0x6f;
        return bVar2 & 0x6f;
      }
      return bVar2;
    }
  }
  else {
    iface_start_write();
    if ((char)in_PSW < '\0') {
      bVar2 = i2cA_stop();
      return bVar2;
    }
    param_1 = param_1 | 0x80;
    ret_clc(param_1);
    if ((char)in_PSW < '\0') {
      i2cA_send_byte(0xfd);
      i2cA_send_byte(0x40);
    }
  }
  i2cA_stop();
  iface_send_status();
  iface_write_ctrl(0xf8);
  if (param_3 < '\0') {
    iface_write_ctrl(0xf3);
    iface_send_address();
  }
  uVar1 = 0xf4;
  in_PSW = in_PSW & 0xdd;
  if ((((param_2 & 0x18) == 0x18) && (uVar1 = 0xf5, (param_2 >> 6 & 1) != 1)) &&
     (uVar1 = 0xf6, -1 < (char)param_2)) {
    uVar1 = 0xf4;
  }
  iface_write_ctrl(uVar1);
  iface_addressed();
  if (((char)in_PSW < '\0') && (-1 < rx_count)) {
    iface_write_ctrl(param_1 & 0xf7,0xfe);
  }
  bVar2 = iface_write_ctrl(0xfa);
  return bVar2;
}

/* ---- iface_i2c_write_block  @0x7D26  (93 bytes) */
uint8_t iface_i2c_write_block(uint8_t param_1,uint8_t param_2,char param_3)

{
  uint8_t uVar1;
  uint8_t in_PSW;
  
  iface_start_write();
  if ((char)in_PSW < '\0') {
    uVar1 = i2cA_stop();
    return uVar1;
  }
  param_1 = param_1 | 0x80;
  ret_clc(param_1);
  if ((char)in_PSW < '\0') {
    i2cA_send_byte(0xfd);
    i2cA_send_byte(0x40);
  }
  i2cA_stop();
  iface_send_status();
  iface_write_ctrl(0xf8);
  if (param_3 < '\0') {
    iface_write_ctrl(0xf3);
    iface_send_address();
  }
  uVar1 = 0xf4;
  in_PSW = in_PSW & 0xdd;
  if ((((param_2 & 0x18) == 0x18) && (uVar1 = 0xf5, (param_2 >> 6 & 1) != 1)) &&
     (uVar1 = 0xf6, -1 < (char)param_2)) {
    uVar1 = 0xf4;
  }
  iface_write_ctrl(uVar1);
  iface_addressed();
  if (((char)in_PSW < '\0') && (-1 < rx_count)) {
    iface_write_ctrl(param_1 & 0xf7,0xfe);
  }
  uVar1 = iface_write_ctrl(0xfa);
  return uVar1;
}

/* ---- iface_set_resend  @0x7D83  (5 bytes) */
uint8_t iface_set_resend(uint8_t param_1)

{
  return param_1;
}

/* ---- iface_poll_once  @0x7DB6  (8 bytes)
 *      read status; message -> iface_read_message, else iface_handle_event */
void iface_poll_once(void)

{
  char in_PSW;
  
  iface_read_status();
  if (in_PSW < '\0') {
    return;
  }
  iface_handle_event();
  return;
}

/* ---- iface_rx_complete  @0x7DBE  (29 bytes)
 *      rx_index = 0, rx_count = header | 0x80 */
void iface_rx_complete(uint8_t param_1,uint8_t param_2)

{
  uint8_t bVar1;
  
  rx_index = 0;
  rx_count = param_2 | 0x80;
  iface_write_ff();
  bVar1 = reply_len;
  if (((param_1 & 0xbf) >> 4 & 1) != 0) {
    reply_len = 0;
    ret_nop(bVar1 & 0x1f,param_1 & 0xaf);
  }
  reply_abort();
  return;
}

/* ---- iface_reply_done  @0x7E49  (6 bytes) */
void iface_reply_done(void)

{
  reply_len = 0;
  return;
}

/* ---- iface_handle_event  @0x7E86  (167 bytes)
 *      FE talk, E1 identity, FF countdown, F5-F8 remote/local, F9 GET, FA DCL, FB/FD resend */
uint8_t iface_handle_event(uint8_t param_1,uint8_t param_2,uint8_t param_3)

{
  uint8_t bVar1;
  uint8_t in_PSW;
  uint8_t bVar2;
  char cVar3;
  
  if ((char)param_1 < '\0') {
    if (param_1 != 0xfe) {
      if (param_1 == 0xe1) {
        return 0xe1;
      }
      if (param_1 == 0xff) {
        return 0xff;
      }
      if ((param_1 >> 5 & 1) != 1) {
        return param_3 & 0xe0 | param_1 & 0x1f;
      }
      cVar3 = (param_1 < 0xf9) << 7;
      if (param_1 == 0xf9) {
        bVar1 = iface_addressed();
        if (cVar3 < '\0') {
          bit_2F_0 = 1;
          return bVar1;
        }
      }
      else {
        cVar3 = (param_1 < 0xfa) << 7;
        if (param_1 == 0xfa) {
          bVar1 = iface_addressed();
          if (cVar3 < '\0') {
            bit_2F_1 = 1;
          }
        }
        else {
          if (param_1 == 0xfb) {
            bVar1 = iface_send_address();
            return bVar1;
          }
          if (param_1 == 0xfd) {
            bVar1 = iface_send_status();
            return bVar1;
          }
          cVar3 = (param_1 < 0xf5) << 7;
          if (param_1 == 0xf5) {
            bVar1 = iface_addressed();
            if ((cVar3 < '\0') && (-1 < (char)bVar1)) {
              ram_2F = param_3 & 0x60 | bVar1 & 0x9f | 0x80;
              return ram_2F;
            }
          }
          else {
            cVar3 = (param_1 < 0xf6) << 7;
            if (param_1 == 0xf6) {
              bVar1 = iface_mode_match();
              if (cVar3 < '\0') {
                bVar1 = bVar1 & 0x7f;
LAB_CODE_7f10:
                ram_2F = bVar1 & 0xef;
                return bVar1 & 0xef;
              }
            }
            else {
              cVar3 = (param_1 < 0xf7) << 7;
              if (param_1 == 0xf7) {
                bVar1 = iface_mode_match();
                if (-1 < cVar3) {
                  return bVar1;
                }
                goto LAB_CODE_7f10;
              }
              cVar3 = (param_1 < 0xf8) << 7;
              if (param_1 != 0xf8) {
                bVar1 = iface_write_ctrl(0xff);
                return bVar1;
              }
              bVar1 = iface_mode_match();
              if ((cVar3 < '\0') || (-1 < (char)bVar1)) {
                bVar1 = iface_merge_mode_bits();
                ram_2F = bVar1 | 0x10;
                iface_poll_once();
                iface_poll_once();
                bVar1 = reply_len;
                if (((param_2 & 0xbf) >> 4 & 1) != 0) {
                  reply_len = 0;
                  ret_nop(bVar1 & 0x1f,param_2 & 0xaf);
                }
                bVar1 = reply_abort();
                return bVar1;
              }
            }
          }
        }
      }
      return bVar1;
    }
    bVar1 = 0xfe;
    if (((param_2 >> 4 & 1) != 1) && ((param_2 >> 3 & 1) != 1)) {
      return 0xfe;
    }
  }
  else {
    bVar1 = param_1 & 0x1f;
    bVar2 = in_PSW & 0xdd;
    if (bVar1 == 0) {
      bVar1 = iface_addressed();
      if ((char)bVar2 < '\0') {
        if (-1 < rx_count) {
          bVar1 = iface_rx_complete();
          return bVar1;
        }
        bVar1 = param_1;
        if ((param_1 >> 6 & 1) != 0) {
          bit_2F_2 = 1;
        }
      }
      return bVar1;
    }
  }
  return bVar1;
}

/* ---- iface_merge_mode_bits  @0x7EFA  (12 bytes) */
void iface_merge_mode_bits(uint8_t param_1,uint8_t param_2)

{
  ram_2F = param_2 & 0x60 | param_1 & 0x9f;
  return;
}

/* ---- iface_write_ff  @0x7F39  (5 bytes)
 *      FF = message received */
void iface_write_ff(void)

{
  iface_write_ctrl(0xff);
  return;
}

/* ---- iface_i2c_addr  @0x7F3E  (7 bytes)
 *      address = 0x58 | ((R4>>4)&6) */
uint8_t iface_i2c_addr(uint8_t param_1)

{
  return param_1 >> 4 & 6 | 0x58;
}

/* ---- iface_start_write  @0x7F45  (6 bytes) */
void iface_start_write(void)

{
  iface_i2c_addr();
  i2cA_start_write();
  return;
}

/* ---- iface_start_read  @0x7F4B  (6 bytes) */
void iface_start_read(void)

{
  iface_i2c_addr();
  i2cA_start_read();
  return;
}

/* ---- iface_send_f4_address  @0x7F51  (5 bytes) */
void iface_send_f4_address(uint8_t param_1)

{
  uint8_t bVar1;
  
  iface_write_ctrl(0xf4);
  bVar1 = param_1 & 0x1f | 0xc0;
  iface_start_write(bVar1);
  i2cA_send_stop(bVar1);
  return;
}

/* ---- iface_send_address  @0x7F56  (6 bytes)
 *      C0 | GPIB address */
void iface_send_address(uint8_t param_1)

{
  uint8_t bVar1;
  
  bVar1 = param_1 & 0x1f | 0xc0;
  iface_start_write(bVar1);
  i2cA_send_stop(bVar1);
  return;
}

/* ---- iface_write_ctrl  @0x7F5C  (7 bytes)
 *      single control byte R5 */
void iface_write_ctrl(uint8_t param_1)

{
  iface_start_write();
  i2cA_send_stop(param_1);
  return;
}

/* ---- iface_read_status  @0x7F63  (6 bytes)
 *      read 1 (or 2 for 8x) status bytes */
void iface_read_status(void)

{
  iface_start_read();
                    /* WARNING: Subroutine does not return */
  i2cA_recv_byte();
}

/* ---- iface_send_status  @0x7F8C  (14 bytes)
 *      0x80 | (2Eh & 0x3F) */
void iface_send_status(void)

{
  iface_start_write();
  ram_2E = ram_2E & 0x3f | 0x80;
  i2cA_send_stop();
  return;
}

/* ---- iface_send_f1  @0x7F9A  (13 bytes)
 *      F1 xx */
void iface_send_f1(uint8_t param_1)

{
  iface_start_write(param_1);
  i2cA_send_byte(0xf1);
  i2cA_send_stop(param_1);
  return;
}

/* ---- iface_addressed  @0x7FA7  (7 bytes) */
uint8_t iface_addressed(void)

{
  if ((ram_2F >> 4 & 1) == 1) {
    return ram_2F;
  }
  return ram_2F;
}

/* ---- iface_mode_match  @0x7FAE  (12 bytes) */
uint8_t iface_mode_match(void)

{
  return ram_2F;
}

/* ---- iface_load_channel  @0x7FC1  (23 bytes)
 *      3-byte channel descriptor (R4 config/address, R3 state, B flags) + context */
uint8_t iface_load_channel(uint8_t param_1,uint8_t *param_2)

{
  iface_ctx_load(param_2[2],(char)param_2,(char)((uint16_t)param_2 >> 8),param_2[1],*param_2);
  return param_1;
}

