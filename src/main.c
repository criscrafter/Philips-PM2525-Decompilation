/* main.c - boot, main loop, interrupt handlers, task dispatch
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 14 functions, 931 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/main.c.
 */
#include "pm2525.h"

/* ---- start  @0x0000  (6 bytes) */
void start(void)

{
  nop();
  nop();
  nop();
  start();
  return;
}

/* ---- isr_timer0  @0x000B  (3 bytes)
 *      Timer 0 overflow */
uint8_t isr_timer0(uint8_t param_1)

{
  if (bit_27_5 != '\0') {
    P1_2 = 0;
    P1_2 = 1;
    BANK3_R3 = BANK3_R3 + -1;
    if (BANK3_R3 == '\0') {
      bit_27_5 = '\0';
      TR0 = 0;
    }
    return param_1;
  }
  if (bit_25_1 != '\0') {
    adc_count_mid = adc_count_mid + '\x01';
    return param_1;
  }
  if ((meter_state & 0xf) == 8) {
    TR0 = 0;
    if (bit_25_0 != '\x01') {
      TR1 = 1;
      TXD = time_stop_negslope & 1;
      TL0 = 0xff;
      TH0 = 0xff;
      TR0 = 1;
      bit_25_0 = 1;
      time_started = 1;
      return param_1;
    }
  }
  else if ((meter_state & 0xf) == 10) {
    adc_count_hi = adc_count_hi + '\x01';
    return param_1;
  }
  TR1 = 0;
  TR0 = 0;
  bit_25_0 = 0;
  return param_1;
}

/* ---- isr_int1_gate  @0x0013  (3 bytes)
 *      INT1 edge: stop T0, start T1 with reload (time/frequency gate); not ADC READY */
void isr_int1_gate(void)

{
  EX1 = 0;
  TR0 = 0;
  if (bit_25_1 != '\0') {
    bit_25_0 = 0;
    return;
  }
  TL1 = 0xe0;
  TH1 = 0xb1;
  if (mains_60hz != '\0') {
    TL1 = 0xe5;
    TH1 = 0xbe;
  }
  TR1 = 1;
  time_started = 0;
  bit_27_0 = 1;
  return;
}

/* ---- isr_timer1  @0x001B  (3 bytes)
 *      Timer 1 overflow */
uint8_t isr_timer1(uint8_t param_1)

{
  bool bVar1;
  uint8_t bVar2;
  char cVar3;
  
  if (bit_23_0 != '\0') {
    BANK3_R0 = BANK3_R0 - 1;
    if (BANK3_R0 == '\0') {
      TR1 = 0;
    }
    return param_1;
  }
  if ((meter_state & 0xf) == 8) {
LAB_CODE_53cc:
    bVar1 = 0xfe < adc_count_mid;
    adc_count_mid = adc_count_mid + 1;
    if ((bVar1) && (bVar1 = 0xfe < adc_count_hi, adc_count_hi = adc_count_hi + 1, bVar1)) {
      BANK2_R1 = BANK2_R1 + '\x01';
    }
  }
  else {
    if ((meter_state & 0xf) == 9) {
      if (bit_27_0 != '\x01') goto LAB_CODE_53cc;
    }
    else {
      BANK2_R5 = BANK2_R5 + -1;
      if (BANK2_R5 != '\0') {
        return param_1;
      }
      if ((bit_20_4 != '\x01') && (bit_20_6 != '\x01')) {
        if (speed_b0 == '\0') {
          TR0 = 0;
          BANK2_R6 = TL0;
          BANK2_R7 = TH0;
          cVar3 = TF0;
          TR0 = 1;
          BANK3_R0 = adc_count_hi;
          if (cVar3 << 7 < '\0') {
            BANK3_R0 = adc_count_hi + 1;
          }
          BANK2_R5 = '\x10';
        }
        else {
          bVar2 = TL0;
          BANK2_R7 = TH0;
          BANK2_R6 = TL0;
          if (BANK2_R6 < bVar2) {
            BANK2_R7 = TH0;
          }
          BANK3_R0 = 0;
          BANK2_R5 = '\x02';
        }
        bit_25_0 = 1;
      }
      BANK2_R4 = BANK2_R4 + -1;
      if (BANK2_R4 != '\0') {
        return param_1;
      }
      TR0 = 0;
    }
    TR1 = 0;
  }
  return param_1;
}

/* ---- main_loop  @0x002B  (185 bytes)
 *      main super-loop; re-inits SP each pass, polls interface, runs all tasks */
void main_loop(void)

{
  uint8_t bVar1;
  char cVar2;
  char cVar3;
  
  do {
    do {
      bVar1 = P3;
      P3 = bVar1 & 0xdb;
      i2cB_stop();
      i2cA_stop();
      bVar1 = P1;
      P1 = bVar1 | 0xc6;
      bVar1 = P3;
      P3 = bVar1 | 0x3d;
      SP = 0x60;
      if (iface_chan_hi != '\0' || iface_chan_lo != '\0') {
        iface_poll_channel(CONCAT11(iface_chan_hi,iface_chan_lo));
        if ((xram_00EB >> 1 & 1) != 0) {
          xram_00EB = xram_00EB & 0xfd;
          system_init();
        }
        if ((char)rx_count < '\0') {
          if ((rx_count & 0x3f) != 0) {
            bit_23_3 = 0;
          }
          task_remote_parse();
        }
      }
      task_display_menu();
      task_keyboard();
      task_5468();
      task_trigger();
      task_5D02();
      task_measure();
      if (bit_24_1 != '\0') {
        task_display_update();
      }
      task_remote_reply();
      if (xram_00A3 != '\0' || xram_00A2 != '\0') {
        if (xram_00A2 == '\0') {
          xram_00A3 = xram_00A3 + -1;
          xram_00A2 = -1;
        }
        else {
          xram_00A2 = xram_00A2 + -1;
          if ((xram_00A2 == '\0') && (xram_00A3 == '\0')) {
            bit_24_1 = '\x01';
          }
        }
      }
      cVar3 = (xram_0012 != '\0') << 7;
      xram_0012 = xram_0012 + -1;
    } while (xram_0012 != '\0');
    xram_0012 = '2';
    bit_24_1 = '\x01';
    iface_poll_channel(0x56);
    iface_poll_channel(0x53);
    if (xram_0055 < '\0') {
      cVar2 = iface_receive_channel(0x53);
      if ((cVar3 < '\0') && (xram_0059 = cVar2, cVar2 == '\0')) {
        xram_0053 = xram_0053 | 0x80;
      }
    }
    iface_select_pending();
  } while( true );
}

/* ---- start  @0x51FA  (44 bytes) */
void start(void)

{
  uint8_t bVar1;
  char cVar2;
  
  SP = 0x60;
  P1 = 0xc3;
  P1_2 = 1;
  i2c_both_buses_stop();
  iface_boot_handshake();
  bVar1 = ram_23;
  system_init();
  ram_23 = bVar1 & 0x2c;
  TXD = 1;
  cVar2 = TXD;
  if (cVar2 == '\x01') {
    P1_2 = 1;
    bVar1 = P1_2;
    bit_23_4 = bVar1 & 1 ^ 1;
  }
  else {
    cal_enable = 1;
  }
  main_loop();
  return;
}

/* ---- iface_boot_handshake  @0x5226  (79 bytes)
 *      power-up handshake with interface board (I2C bus A, 0x58..) */
void iface_boot_handshake(void)

{
  char cVar1;
  uint8_t bVar2;
  char in_PSW;
  
  xram_00EB = 8;
  read_option_switches();
  iface_send_channel(0x53);
  if (xram_0055 < '\0') {
    do {
      cVar1 = iface_receive_channel(0x53);
    } while (-1 < in_PSW);
    xram_0059 = cVar1;
    if (cVar1 == '\0') {
      bVar2 = read_option_switches();
      bVar2 = bVar2 | 0x80;
    }
    else {
      if (cVar1 != '\x03') goto LAB_CODE_5261;
      bVar2 = 0x60;
    }
    iface_send_channel(bVar2,0x53);
  }
LAB_CODE_5261:
  iface_send_channel(0,0x56,0);
  iface_select_pending();
  cr_load_setting();
  task_remote_parse_tail();
  return;
}

/* ---- read_option_switches  @0x5275  (32 bytes)
 *      reads option/config byte via 5ACF, stores flags 23h.2/23h.3 */
uint8_t read_option_switches(void)

{
  uint8_t bVar1;
  uint8_t in_PSW;
  
  bVar1 = nv_get_iface_config();
  bit_23_3 = bVar1 >> 7;
  emo_continuous = bVar1 >> 7;
  i24_clr_r0(in_PSW >> 7,0x56,bVar1 & 0x80);
  i24_st_r0_xdata(0x95);
  return bVar1 & 0x1f | 0x60;
}

/* ---- system_init  @0x5295  (150 bytes)
 *      IE/TCON/SCON off, clear IRAM 08..5F, init state, LCD test pattern */
void system_init(void)

{
  uint8_t *puVar1;
  char cVar2;
  
  IE = 0;
  TCON = 0;
  SCON = 0;
  P1_2 = 0;
  P1_2 = 1;
  i2c_both_buses_stop(0);
  puVar1 = &shiftreg_out0;
  cVar2 = 'X';
  do {
    *puVar1 = 0;
    puVar1 = puVar1 + '\x01';
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  ram_23 = ram_23 & 0x30;
  xdata_clear3(0x95);
  meter_state = 0xa1;
  if (2 < speed_saved) {
    speed_saved = 1;
  }
  ram_22 = 8;
  meter_mode = speed_saved;
  fp_ld_code_r0(0x6fd0,0x43);
  fp_st_r0_xdata(0x79);
  fp_ld_code_r0(0x6fdc);
  fp_st_r0_xdata(0x75);
  min_reset();
  max_reset();
  result_flags = 8;
  iface_report_status();
  result_record_clear();
  menu_init();
  reply_init();
  display_timer_init();
  meas_init();
  trigger_clear();
  lcd_show_message(&msg_table);
  lcd_refresh();
  P1_2 = 0;
  P1_2 = 1;
  i2cB_start_write(0x70);
  cVar2 = '\x19';
  do {
    i2cB_send_byte(*(uint8_t *)((uint16_t)(cVar2 + 7) + 0x5323));
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  i2cB_stop();
  return;
}

/* ---- isr_timer0  @0x534D  (75 bytes)
 *      Timer 0 overflow */
uint8_t isr_timer0(uint8_t param_1)

{
  if (bit_27_5 != '\0') {
    P1_2 = 0;
    P1_2 = 1;
    BANK3_R3 = BANK3_R3 + -1;
    if (BANK3_R3 == '\0') {
      bit_27_5 = '\0';
      TR0 = 0;
    }
    return param_1;
  }
  if (bit_25_1 != '\0') {
    adc_count_mid = adc_count_mid + '\x01';
    return param_1;
  }
  if ((meter_state & 0xf) == 8) {
    TR0 = 0;
    if (bit_25_0 != '\x01') {
      TR1 = 1;
      TXD = time_stop_negslope & 1;
      TL0 = 0xff;
      TH0 = 0xff;
      TR0 = 1;
      bit_25_0 = 1;
      time_started = 1;
      return param_1;
    }
  }
  else if ((meter_state & 0xf) == 10) {
    adc_count_hi = adc_count_hi + '\x01';
    return param_1;
  }
  TR1 = 0;
  TR0 = 0;
  bit_25_0 = 0;
  return param_1;
}

/* ---- isr_int1_gate  @0x5398  (32 bytes)
 *      INT1 edge: stop T0, start T1 with reload (time/frequency gate); not ADC READY */
void isr_int1_gate(void)

{
  EX1 = 0;
  TR0 = 0;
  if (bit_25_1 != '\0') {
    bit_25_0 = 0;
    return;
  }
  TL1 = 0xe0;
  TH1 = 0xb1;
  if (mains_60hz != '\0') {
    TL1 = 0xe5;
    TH1 = 0xbe;
  }
  TR1 = 1;
  time_started = 0;
  bit_27_0 = 1;
  return;
}

/* ---- isr_timer1  @0x53B8  (132 bytes)
 *      Timer 1 overflow */
uint8_t isr_timer1(uint8_t param_1)

{
  bool bVar1;
  uint8_t bVar2;
  char cVar3;
  
  if (bit_23_0 != '\0') {
    BANK3_R0 = BANK3_R0 - 1;
    if (BANK3_R0 == '\0') {
      TR1 = 0;
    }
    return param_1;
  }
  if ((meter_state & 0xf) == 8) {
LAB_CODE_53cc:
    bVar1 = 0xfe < adc_count_mid;
    adc_count_mid = adc_count_mid + 1;
    if ((bVar1) && (bVar1 = 0xfe < adc_count_hi, adc_count_hi = adc_count_hi + 1, bVar1)) {
      BANK2_R1 = BANK2_R1 + '\x01';
    }
  }
  else {
    if ((meter_state & 0xf) == 9) {
      if (bit_27_0 != '\x01') goto LAB_CODE_53cc;
    }
    else {
      BANK2_R5 = BANK2_R5 + -1;
      if (BANK2_R5 != '\0') {
        return param_1;
      }
      if ((bit_20_4 != '\x01') && (bit_20_6 != '\x01')) {
        if (speed_b0 == '\0') {
          TR0 = 0;
          BANK2_R6 = TL0;
          BANK2_R7 = TH0;
          cVar3 = TF0;
          TR0 = 1;
          BANK3_R0 = adc_count_hi;
          if (cVar3 << 7 < '\0') {
            BANK3_R0 = adc_count_hi + 1;
          }
          BANK2_R5 = '\x10';
        }
        else {
          bVar2 = TL0;
          BANK2_R7 = TH0;
          BANK2_R6 = TL0;
          if (BANK2_R6 < bVar2) {
            BANK2_R7 = TH0;
          }
          BANK3_R0 = 0;
          BANK2_R5 = '\x02';
        }
        bit_25_0 = 1;
      }
      BANK2_R4 = BANK2_R4 + -1;
      if (BANK2_R4 != '\0') {
        return param_1;
      }
      TR0 = 0;
    }
    TR1 = 0;
  }
  return param_1;
}

/* ---- task_5468  @0x5468  (134 bytes)
 *      uses P1.6 */
void task_5468(void)

{
  char cVar1;
  char cVar2;
  uint8_t bVar3;
  char in_PSW;
  
  func_is_time_or_cont();
  if (-1 < in_PSW) goto LAB_CODE_54a4;
  if ((((xram_00EB >> 4 & 1) == 0) && (bVar3 = meter_state & 0xf, bVar3 != 1)) &&
     (bVar3 != 10)) {
    if (((cal_mode == '\0') || ((bVar3 != 1 && (bVar3 != 10)))) && (bVar3 != 0xb)) {
      if ((speed_b0 == '\0') || (speed_b1 == '\x01')) goto LAB_CODE_549a;
    }
    else if ((speed_b0 == '\x01') || (speed_b1 != '\0')) goto LAB_CODE_549a;
LAB_CODE_54a4:
    bit_22_2 = 0;
  }
  else {
LAB_CODE_549a:
    bit_22_2 = 1;
  }
  cVar2 = '\0';
  bVar3 = meter_state & 0xe;
  if (bit_25_6 == '\x01') {
    cVar1 = P1_6;
    if (cVar1 != '\0') {
      do {
        cVar2 = cVar2 + -1;
      } while (cVar2 != '\0');
      cVar2 = P1_6;
      if (cVar2 != '\0') {
        bit_25_6 = '\0';
        if (bVar3 == 6) goto LAB_CODE_54c3;
        cal_status_or_dashes();
      }
      return;
    }
    if (bVar3 == 6) {
      return;
    }
  }
  else {
    cVar1 = P1_6;
    if (cVar1 == '\x01') {
      return;
    }
    do {
      cVar2 = cVar2 + -1;
    } while (cVar2 != '\0');
    cVar2 = P1_6;
    if (cVar2 == '\x01') {
      return;
    }
    bit_25_6 = '\x01';
    if (bVar3 == 6) {
LAB_CODE_54c3:
      meter_state = meter_state & 0x8f | 0x60;
      meas_restart_from_ui();
      trigger_clear();
      cal_status_or_dashes();
      result_restart();
      return;
    }
    bit_23_6 = 1;
  }
  if (bit_26_1 != '\x01') {
    lcd_show_message(0x7111);
  }
  return;
}

/* ---- task_5D02  @0x5D02  (53 bytes) */
void task_5D02(void)

{
  uint8_t bVar1;
  
  if (iface_chan_hi == '\0' && iface_chan_lo == '\0') {
    return;
  }
  bVar1 = 7;
  if ((result_flags & 1) == 0) {
    bVar1 = 3;
  }
  else {
    result_flags = result_flags & 0xfe;
  }
  if ((result_flags & 4) == 0) {
    bVar1 = bVar1 & 0xfd;
  }
  else {
    result_flags = result_flags & 0xfb;
  }
  if (bit_23_6 == '\0') {
    bVar1 = bVar1 & 0xfe;
  }
  else {
    bit_23_6 = '\0';
  }
  if (bVar1 == 0) {
    iface_status_compose();
    return;
  }
  xram_00EA = bVar1 | 0x20 | (result_flags >> 3 & 1) << 4;
  iface_send_status_now(CONCAT11(iface_chan_hi,iface_chan_lo));
  return;
}

