/* i2c.c - bit-banged I2C buses: A = option bus (P1.1/P3.2), B = internal bus (P1.7/P3.5)
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 24 functions, 295 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/i2c.c.
 */
#include "pm2525.h"

/* ---- i2c_both_buses_stop  @0x5344  (9 bytes)
 *      release both bit-banged I2C buses */
void i2c_both_buses_stop(void)

{
  uint8_t bVar1;
  
  bVar1 = P3;
  P3 = bVar1 & 0xdb;
  i2cB_stop();
  i2cA_stop();
  return;
}

/* ---- i2cA_read1  @0x6354  (5 bytes)
 *      A=addr: start+addr(R), read 1 byte w/ NACK, stop. C=1 on no-ack */
void i2cA_read1(void)

{
  char in_PSW;
  
  i2cA_start_read();
  if (-1 < in_PSW) {
                    /* WARNING: Subroutine does not return */
    i2cA_recv_byte();
  }
  i2cA_stop();
  return;
}

/* ---- i2cA_recv_nack_stop  @0x6359  (3 bytes) */
void i2cA_recv_nack_stop(void)

{
                    /* WARNING: Subroutine does not return */
  i2cA_recv_byte();
}

/* ---- i2cA_write1  @0x6363  (6 bytes)
 *      A=addr, R3=data: start+addr(W), send, stop */
void i2cA_write1(uint8_t param_1)

{
  char in_PSW;
  
  i2cA_start_write();
  if (-1 < in_PSW) {
    i2cA_send_byte(param_1);
  }
  i2cA_stop();
  return;
}

/* ---- i2cA_send_stop  @0x6369  (6 bytes)
 *      send A then stop */
void i2cA_send_stop(void)

{
  i2cA_send_byte();
  i2cA_stop();
  return;
}

/* ---- i2cA_start_write  @0x6377  (5 bytes)
 *      start + addr (R/W=0); C=1 if NACK */
void i2cA_start_write(uint8_t param_1)

{
  P1_1 = 0;
  nop();
  nop();
  nop();
  nop();
  INT0 = 0;
  nop();
  i2cA_send_byte(param_1 & 0xfe);
  return;
}

/* ---- i2cA_start_read  @0x6388  (14 bytes)
 *      start + addr (R/W=1); C=1 if NACK */
void i2cA_start_read(uint8_t param_1)

{
  P1_1 = 0;
  nop();
  nop();
  nop();
  nop();
  INT0 = 0;
  nop();
  i2cA_send_byte(param_1 | 1);
  return;
}

/* ---- i2cA_send_byte  @0x6397  (22 bytes)
 *      8 bits MSB first, waits for clock stretching, returns ACK in C */
uint8_t i2cA_send_byte(uint8_t param_1)

{
  uint8_t uVar1;
  char cVar2;
  char cVar3;
  uint8_t bVar4;
  uint8_t in_PSW;
  
  cVar3 = '\b';
  do {
    bVar4 = param_1;
    param_1 = bVar4 << 1 | in_PSW >> 7;
    in_PSW = bVar4 & 0x80;
    P1_1 = bVar4 >> 7;
    nop();
    INT0 = 1;
    nop();
    nop();
    do {
      cVar2 = INT0;
    } while (cVar2 == '\0');
    nop();
    nop();
    INT0 = 0;
    nop();
    cVar3 = cVar3 + -1;
  } while (cVar3 != '\0');
  nop();
  P1_1 = 1;
  nop();
  INT0 = 1;
  nop();
  nop();
  do {
    cVar3 = INT0;
  } while (cVar3 == '\0');
  nop();
  nop();
  uVar1 = P1_1;
  INT0 = 0;
  nop();
  return param_1 << 1 | bVar4 >> 7;
}

/* ---- i2cA_read_ack_bit  @0x63AD  (27 bytes) */
void i2cA_read_ack_bit(void)

{
  uint8_t uVar1;
  char cVar2;
  
  P1_1 = 1;
  nop();
  INT0 = 1;
  nop();
  nop();
  do {
    cVar2 = INT0;
  } while (cVar2 == '\0');
  nop();
  nop();
  uVar1 = P1_1;
  INT0 = 0;
  nop();
  return;
}

/* ---- i2cA_stop  @0x63C8  (16 bytes) */
void i2cA_stop(void)

{
  char cVar1;
  
  P1_1 = 0;
  nop();
  INT0 = 1;
  nop();
  nop();
  do {
    cVar1 = INT0;
  } while (cVar1 == '\0');
  nop();
  nop();
  P1_1 = 1;
  nop();
  return;
}

/* ---- i2cA_send_ack  @0x63E1  (25 bytes) */
void i2cA_send_ack(void)

{
  char cVar1;
  
  P1_1 = 0;
  nop();
  INT0 = 1;
  nop();
  nop();
  do {
    cVar1 = INT0;
  } while (cVar1 == '\0');
  nop();
  nop();
  INT0 = 0;
  nop();
  return;
}

/* ---- i2cA_recv_byte  @0x63FA  (29 bytes) */
uint8_t i2cA_recv_byte(uint8_t param_1)

{
  uint8_t bVar1;
  char cVar2;
  char cVar3;
  
  cVar3 = '\b';
  P1_1 = 1;
  do {
    nop();
    nop();
    INT0 = 1;
    nop();
    nop();
    do {
      cVar2 = INT0;
    } while (cVar2 == '\0');
    nop();
    bVar1 = P1_1;
    INT0 = 0;
    nop();
    param_1 = param_1 << 1 | bVar1 & 1;
    cVar3 = cVar3 + -1;
  } while (cVar3 != '\0');
  return param_1;
}

/* ---- i2cB_read1_stop  @0x6B35  (5 bytes)
 *      complete one-byte read (keyboard PCF8574) */
void i2cB_read1_stop(void)

{
  char in_PSW;
  
  i2cB_start_read();
  if (-1 < in_PSW) {
    i2cB_recv_byte();
    i2cB_read_ack_bit();
  }
  i2cB_stop();
  return;
}

/* ---- i2cB_recv_nack_stop  @0x6B3A  (10 bytes) */
void i2cB_recv_nack_stop(void)

{
  i2cB_recv_byte();
  i2cB_read_ack_bit();
  i2cB_stop();
  return;
}

/* ---- i2cB_write1  @0x6B44  (6 bytes)
 *      A=addr, R3=data */
void i2cB_write1(uint8_t param_1)

{
  char in_PSW;
  
  i2cB_start_write();
  if (-1 < in_PSW) {
    i2cB_send_byte(param_1);
  }
  i2cB_stop();
  return;
}

/* ---- i2cB_send_stop  @0x6B4A  (6 bytes) */
void i2cB_send_stop(void)

{
  i2cB_send_byte();
  i2cB_stop();
  return;
}

/* ---- i2cB_start_write  @0x6B55  (5 bytes) */
void i2cB_start_write(uint8_t param_1)

{
  i2cB_start(param_1 & 0xfe);
  return;
}

/* ---- i2cB_start_read  @0x6B62  (2 bytes) */
void i2cB_start_read(uint8_t param_1)

{
  P1_7 = 0;
  nop();
  nop();
  nop();
  T1 = 0;
  i2cB_send_byte(param_1 | 1);
  return;
}

/* ---- i2cB_start  @0x6B64  (10 bytes)
 *      start condition + address byte (ACC.0 = R/W) */
void i2cB_start(void)

{
  P1_7 = 0;
  nop();
  nop();
  nop();
  T1 = 0;
  i2cB_send_byte();
  return;
}

/* ---- i2cB_send_byte  @0x6B6F  (18 bytes) */
uint8_t i2cB_send_byte(uint8_t param_1)

{
  uint8_t uVar1;
  char cVar2;
  char cVar3;
  uint8_t bVar4;
  uint8_t in_PSW;
  
  cVar3 = '\b';
  do {
    bVar4 = param_1;
    param_1 = bVar4 << 1 | in_PSW >> 7;
    in_PSW = bVar4 & 0x80;
    P1_7 = bVar4 >> 7;
    T1 = 1;
    do {
      cVar2 = T1;
    } while (cVar2 == '\0');
    nop();
    nop();
    T1 = 0;
    cVar3 = cVar3 + -1;
  } while (cVar3 != '\0');
  nop();
  P1_7 = 1;
  T1 = 1;
  do {
    cVar3 = T1;
  } while (cVar3 == '\0');
  nop();
  nop();
  uVar1 = P1_7;
  T1 = 0;
  return param_1 << 1 | bVar4 >> 7;
}

/* ---- i2cB_read_ack_bit  @0x6B81  (14 bytes) */
void i2cB_read_ack_bit(void)

{
  uint8_t uVar1;
  char cVar2;
  
  P1_7 = 1;
  T1 = 1;
  do {
    cVar2 = T1;
  } while (cVar2 == '\0');
  nop();
  nop();
  uVar1 = P1_7;
  T1 = 0;
  return;
}

/* ---- i2cB_stop  @0x6B8F  (12 bytes) */
void i2cB_stop(void)

{
  char cVar1;
  
  P1_7 = 0;
  T1 = 1;
  do {
    cVar1 = T1;
  } while (cVar1 == '\0');
  nop();
  nop();
  P1_7 = 1;
  return;
}

/* ---- i2cB_read1  @0x6B9B  (21 bytes) */
void i2cB_read1(void)

{
  char cVar1;
  char in_PSW;
  
  i2cB_start_read();
  if (-1 < in_PSW) {
    i2cB_recv_byte();
    P1_7 = 0;
    T1 = 1;
    do {
      cVar1 = T1;
    } while (cVar1 == '\0');
    nop();
    nop();
    T1 = 0;
  }
  return;
}

/* ---- i2cB_recv_byte  @0x6BB0  (19 bytes) */
uint8_t i2cB_recv_byte(uint8_t param_1)

{
  uint8_t bVar1;
  char cVar2;
  char cVar3;
  
  cVar3 = '\b';
  P1_7 = 1;
  do {
    nop();
    T1 = 1;
    do {
      cVar2 = T1;
    } while (cVar2 == '\0');
    nop();
    bVar1 = P1_7;
    T1 = 0;
    param_1 = param_1 << 1 | bVar1 & 1;
    cVar3 = cVar3 + -1;
  } while (cVar3 != '\0');
  return param_1;
}

