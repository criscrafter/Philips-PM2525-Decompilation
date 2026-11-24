/* measure.c - measurement state machine, ADC interface, timing functions, ranging, result processing
 * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.
 * 94 functions, 6208 bytes of 8051 code. Addresses refer to PM2525_S25.BIN.
 * A hand-cleaned version of this module is in clean/measure.c.
 */
#include "pm2525.h"

/* ---- diag_clear_counters  @0x0ABF  (29 bytes)
 *      JCV (cal mode): clear 22 bytes from 0x076C */
uint8_t diag_clear_counters(uint8_t param_1)

{
  char cVar1;
  uint8_t *puVar2;
  
  puVar2 = &diag_err_total;
  cVar1 = '\x16';
  do {
    *puVar2 = 0;
    puVar2 = puVar2 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return param_1;
}

/* ---- task_measure  @0x1009  (118 bytes)
 *      1965 B: measurement sequencing, timers T0/T1, ADC cycles */
void task_measure(void)

{
  meas_ctx_ptr();
  xdata_to_iram();
  if (bit_2C_5 != '\0') {
    speed_force_fast();
  }
  i24_inc_r0(0x33);
  if ((bit_2F_2 != '\0') && (BANK3_R4 = BANK3_R4 + -1, BANK3_R4 == '\0')) {
    bit_2F_2 = '\0';
  }
  if (bit_2E_0 == '\0') {
    if ((bit_2F_0 == '\x01') || (bit_2F_1 != '\0')) {
      if (bit_27_5 == '\x01') {
meas_exit:
        meas_ctx_ptr();
        iram_to_xdata();
        if (bit_2C_5 != '\0') {
          speed_restore();
        }
        return;
      }
      bit_2C_1 = '\x01';
    }
    else {
      if (bit_27_5 == '\x01') goto meas_exit;
      if ((adc_alt_mode != '\0') && (BANK3_R1 = BANK3_R1 + -1, BANK3_R1 == '\0')) {
        adc_start_cycle();
      }
      if (((bit_2E_3 != '\0') && (adc_timeout_lo = adc_timeout_lo + -1, adc_timeout_lo == '\0')) &&
         (adc_timeout_hi = adc_timeout_hi + -1, adc_timeout_hi == '\0')) {
        diag_count_event(0xb);
        goto meas_restart;
      }
    }
  }
  else {
    if (bit_27_5 == '\x01') goto meas_exit;
    bit_2C_0 = '\x01';
  }
  P1_2 = 0;
  P1_2 = 1;
  if (bit_2C_2 != '\0') {
    meas_phase_process();
    return;
  }
  if (bit_2C_0 != '\0') {
    meas_phase_switch();
    return;
  }
  if (bit_2C_1 != '\0') {
    meas_phase_acquire();
    return;
  }
  diag_count_event(0xc);
meas_restart:
  bit_23_0 = 0;
  bit_22_3 = 1;
  bit_2C_5 = 0;
  bit_25_4 = 1;
  prev_count = 0x7f;
  bit_2C_7 = 1;
  bit_2B_1 = 1;
  adc_start_cycle();
  F0 = bit_23_0 & 1 ^ 1;
  autorange_reset();
  meas_ctx_ptr();
  xdata_swap_iram();
  return;
}

/* ---- meas_ctx_ptr  @0x107F  (8 bytes)
 *      DPTR=0x00BE, R0=0x2A, R2=14: measurement context descriptor */
void meas_ctx_ptr(void)

{
  return;
}

/* ---- meas_init  @0x1087  (25 bytes)
 *      power-up init of measurement engine (EA off, flags, calls 10D1/5BCB) */
void meas_init(void)

{
  EA = 0;
  mains_load_setting();
  ram_2D = ram_2D & 0xe7 | 0xc0;
  bit_25_1 = 1;
  bit_2A_0 = 1;
  bit_2A_1 = 0;
  internal_temp_init();
  filter_init();
  bit_23_0 = 0;
  bit_22_3 = 1;
  bit_2C_5 = 0;
  bit_25_4 = 1;
  prev_count = 0x7f;
  bit_2C_7 = 1;
  bit_2B_1 = 1;
  adc_start_cycle();
  F0 = bit_23_0 & 1 ^ 1;
  autorange_reset();
  meas_ctx_ptr();
  xdata_swap_iram();
  return;
}

/* ---- meas_restart_from_ui  @0x10A0  (12 bytes)
 *      called from keyboard / task_5468 after a function or range change */
void meas_restart_from_ui(void)

{
  meas_ctx_ptr();
  xdata_swap_iram();
  bit_23_0 = 0;
  bit_22_3 = 1;
  bit_2C_5 = 0;
  bit_25_4 = 1;
  prev_count = 0x7f;
  bit_2C_7 = 1;
  bit_2B_1 = 1;
  adc_start_cycle();
  F0 = bit_23_0 & 1 ^ 1;
  autorange_reset();
  meas_ctx_ptr();
  xdata_swap_iram();
  return;
}

/* ---- meas_restart_b  @0x10AC  (37 bytes)
 *      same, called from 3CC3 */
void meas_restart_b(void)

{
  meas_ctx_ptr();
  xdata_swap_iram();
  bit_2C_5 = 0;
  bit_25_4 = 1;
  prev_count = 0x7f;
  bit_2C_7 = 1;
  bit_2B_1 = 1;
  adc_start_cycle();
  F0 = bit_23_0 & 1 ^ 1;
  autorange_reset();
  meas_ctx_ptr();
  xdata_swap_iram();
  return;
}

/* ---- meas_set_function_flags  @0x10DB  (14 bytes)
 *      per-function jump table 0x10E9 */
void meas_set_function_flags(void)

{
  uint8_t bVar1;
  
  bVar1 = meter_state;
  bit_22_3 = 1;
  meter_state = meter_state & 0x8f;
                    /* WARNING: Switch is manually overridden */
  switch((bVar1 & 0xf) << 1) {
  case 0:
    break;
  case 2:
    break;
  case 4:
    break;
  case 6:
    break;
  case 8:
    break;
  case 10:
    break;
  case 0xc:
    goto LAB_CODE_1108;
  case 0xe:
    goto LAB_CODE_1108;
  case 0x10:
    bit_20_4 = 1;
    return;
  case 0x12:
    bit_20_6 = 1;
    return;
  case 0x14:
LAB_CODE_1108:
    meter_state = meter_state | 0x60;
    return;
  case 0x16:
    bit_22_3 = 1;
    return;
  case 0x18:
    bit_22_3 = 1;
    return;
  case 0x1a:
    return;
  case 0x1e:
    goto override_jmp_CODE_10e8_case_15;
  }
  bit_20_5 = 1;
override_jmp_CODE_10e8_case_15:
  return;
}

/* ---- meas_offset_select  @0x1113  (50 bytes)
 *      per-function 24-bit offset (current: XDATA 0x011D/0x0120) */
void meas_offset_select(void)

{
  uint8_t bVar1;
  uint16_t uVar2;
  
  if (bit_23_4 != '\0') {
    i24_clr_r0();
    return;
  }
  bVar1 = meter_state & 0xf;
  if (bVar1 == 6) {
    if ((meter_state & 0x10) != 0) {
LAB_CODE_1128:
      uVar2 = 0x11d;
      goto LAB_CODE_1130;
    }
  }
  else if (((bVar1 != 0xb) && (bVar1 != 0xc)) && ((meter_state & 0x70) == 0)) goto LAB_CODE_1128;
  uVar2 = 0x120;
LAB_CODE_1130:
  i24_ld_xdata_r0(uVar2,0x42);
  return;
}

/* ---- meas_scale_result  @0x1145  (323 bytes)
 *      converts raw count to value using range constants (0x7040..) and float math */
void meas_scale_result(void)

{
  uint8_t uVar1;
  uint8_t bVar2;
  char cVar3;
  uint16_t uVar4;
  uint8_t *puVar5;
  
  ram_2B = ram_2B & 0xf;
  bit_2C_4 = 0;
  if (bit_25_1 == '\x01') {
    bit_2C_4 = 0;
    return;
  }
  if (bit_2D_3 == '\x01') {
LAB_CODE_115a:
    i24_ld_code_r1(0x7040);
    i24_sub();
    return;
  }
  if (bit_2D_6 != '\0') {
    if (bit_2D_4 == '\x01') {
      adc_count_minus_zero(&adc_count_time_norm,0x10,0x42);
      return;
    }
    goto LAB_CODE_115a;
  }
  if (bit_20_3 == '\x01') {
    if (10 < (meter_state & 0xf)) goto LAB_CODE_117e;
  }
  else if ((meter_state & 0xf) != 0) {
LAB_CODE_117e:
    if (speed_b1 == '\0') {
      puVar5 = &adc_count_time_norm;
    }
    else {
      puVar5 = &adc_count_time_fast;
    }
    adc_count_minus_zero(puVar5,0x10,0x42);
    bVar2 = meter_state & 0xf;
    if (bVar2 == 2) {
      cVar3 = '\0';
    }
    else if (bVar2 == 3) {
      cVar3 = '\0';
    }
    else {
      cVar3 = (bVar2 < 7) << 7;
      if (bVar2 != 7) {
        meas_offset_select();
        if (speed_b1 == '\0') {
          uVar4 = 0x6fe3;
        }
        else {
          uVar4 = 0x6fe6;
        }
        i24_ld_code_r1(uVar4,0x42,0x46);
        i24_div_signed();
        i24_st_r0_xdata(0x107,0x10);
        i24_sub(0x42);
        return;
      }
    }
    if (bit_23_4 == '\x01') {
      return;
    }
    ram_40 = rms_get_byte(0x10);
    uVar1 = 0x4c;
    if (speed_b1 != '\0') {
      cVar3 = '\0';
      ram_40 = ram_40 / 10;
      uVar1 = 0xee;
    }
    ram_41 = 0;
    range_lim_down = 0;
    i24_sub();
    if (cal_enable == '\x01') {
      return;
    }
    ram_41 = 0xff;
    range_lim_down = 0xff;
    ram_40 = uVar1;
    i24_cmp_signed();
    if (cVar3 < '\0') {
      return;
    }
    i24_clr_r0();
    return;
  }
  if ((meter_state & 0xf) == 9) {
    i24_ld_code_r1(0x6fe3);
    i24_div();
    uVar4 = 0x6fec;
  }
  else {
    if ((meter_state & 0xf) != 0) goto LAB_CODE_121b;
    uVar4 = 0x7040;
  }
  i24_ld_code_r1(uVar4);
  i24_sub();
LAB_CODE_121b:
  if ((meter_state & 0xf) != 10) {
    return;
  }
  if (bit_2C_5 == '\x01') {
    return;
  }
  if (bit_2E_2 != '\0') {
    if ((meter_state & 0x70) == 0x20) {
      if (speed_b0 == '\x01') {
        puVar5 = &freq_corr_latency;
      }
      else {
        puVar5 = &freq_corr_1s;
      }
    }
    else if (speed_b0 == '\x01') {
      puVar5 = (uint8_t *)0x7051;
    }
    else {
      puVar5 = (uint8_t *)0x704d;
    }
    fp_ld_code_r1(puVar5,0x43);
    i24_to_fp(0x10);
    fp_mul();
    fp_to_i24_round();
  }
  if ((meter_state & 0x70) != 0x20) {
    return;
  }
  if (speed_b0 == '\x01') {
    puVar5 = &freq_corr_131ms;
  }
  else {
    puVar5 = &freq_corr_1s;
  }
  fp_ld_code_r1(puVar5,0x47);
  i24_copy_r1_to_r0(0x42,0x18);
  i24_to_fp();
  fp_mul(0x47);
  fp_to_i24_round();
  i24_copy_r1_to_r0(0x18,0x42);
  return;
}

/* ---- adc_count_minus_zero  @0x1288  (26 bytes)
 *      signed count = raw - T2 (29360, 2936 in SPEED 3); |count| >= T2 -> overload */
void adc_count_minus_zero(void)

{
  char in_PSW;
  
  i24_ld_code_r1();
  i24_sub();
  i24_copy_r1_to_r0(0x46,0x10);
  i24_abs();
  i24_cmp(0x42);
  if (-1 < in_PSW) {
    bit_2D_1 = 1;
  }
  return;
}

/* ---- meas_process_special  @0x1487  (20 bytes)
 *      processing for modes 25h.1 / 2Dh.3 / 2Dh.6 (peak/temperature?) */
void meas_process_special(void)

{
  if (bit_25_1 != '\0') {
    internal_temp_from_count();
    return;
  }
  bit_2E_4 = 1;
  if ((bit_2D_3 == '\x01') || (bit_2D_4 != '\x01')) {
    internal_temp_update();
    return;
  }
  internal_temp_track();
  return;
}

/* ---- adc_start_alt_mode  @0x149B  (7 bytes) */
void adc_start_alt_mode(void)

{
  uint8_t bVar1;
  
  BANK3_R1 = 0xff;
  adc_alt_mode = 1;
  i2cB_start(0x8b);
  i2cB_stop();
  bVar1 = i2cA_read1(0x4e);
  i2cA_write1(0x4e,bVar1 & 0xfe | adc_alt_mode & 1 ^ 1);
  return;
}

/* ---- adc_start_cycle  @0x14A2  (31 bytes)
 *      cmd 0x89 (or 0x8B if 26h.6) then PCF8574@0x4E bit0 = !26h.6 */
/* WARNING: Removing unreachable block (CODE,0x14a9) */

void adc_start_cycle(void)

{
  uint8_t bVar1;
  
  adc_alt_mode = 0;
  i2cB_start(0x89);
  i2cB_stop();
  bVar1 = i2cA_read1(0x4e);
  i2cA_write1(0x4e,bVar1 & 0xfe | adc_alt_mode & 1 ^ 1);
  return;
}

/* ---- meas_stop_and_reset  @0x14C1  (40 bytes)
 *      timers/interrupts off, phase flags reset */
void meas_stop_and_reset(void)

{
  uint8_t bVar1;
  char cVar2;
  
  cVar2 = F0;
  if (cVar2 == '\0') {
    bVar1 = IE;
    IE = bVar1 & 0x88;
    bVar1 = TCON;
    TCON = bVar1 & 0xc0;
  }
  else {
    IE = 0;
    TCON = 0;
  }
  IP = 0;
  ram_2E = ram_2E & 0xf4;
  bit_2E_2 = 1;
  bit_2B_4 = 1;
  bit_2B_7 = 1;
  ram_2F = ram_2F & 0xfc;
  bit_25_0 = 0;
  ram_27 = ram_27 & 0xdc;
  bit_2C_3 = 0;
  return;
}

/* ---- time_read_counter  @0x14E9  (44 bytes) */
void time_read_counter(void)

{
  char cVar1;
  
  if (bit_2E_2 != '\x01') {
    ET1 = 0;
  }
  ram_50 = BANK2_R1;
  ram_4F = adc_count_hi;
  ram_4E = adc_count_mid;
  ram_4D = TH1;
  cVar1 = TF1;
  if (bit_2E_2 == '\0') {
    ET1 = 1;
    ram_4C = 0;
  }
  else {
    ram_4C = TL1;
  }
  if ((cVar1 << 7 < '\0') && (cVar1 = TH1, cVar1 == '\0')) {
    i24_inc_r0(0x50);
  }
  return;
}

/* ---- meas_process_time  @0x1515  (266 bytes)
 *      seconds = (T1 overflows*65536 + T1) * 1e-6; decade autorange; cal (timebase) applied */
void meas_process_time(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t in_PSW;
  
  time_read_counter();
  i24_copy_r1_to_r0(0x42,0x50);
  i24_to_fp();
  fp_ld_code_r1(0x7069,0x47);
  fp_mul();
  ram_4F = 0;
  ram_4E = ram_4D;
  ram_4D = ram_4C;
  i24_to_fp(0x4f);
  fp_add(0x43);
  fp_ld_pow10_r1(0xfa);
  fp_mul();
  fp_ld_xdata_r1(0x10a);
  fp_cmp();
  if ((-1 < (char)in_PSW) || (bit_2E_2 != 0)) {
    bit_2B_7 = 1;
    fp_ld_code_r1(0x6f69,0x43,0x47);
    fp_add();
    fp_st_r0_xdata(0x10a);
  }
  fp_ld_xdata_r1(0x10e,0x50,0x43);
  fp_cmp();
  if ((-1 < (char)in_PSW) || (bit_2E_2 == 1)) {
    fp_ld_pow10_r1(0,0x43,0x47);
    fp_add();
    fp_st_r0_xdata(0x10e);
    if (meter_autorange == '\0') {
      time_range_limit(0x47);
      bVar2 = fp_cmp(0x50,0x47);
      if (-1 < (char)in_PSW) {
        bit_2D_1 = '\x01';
      }
    }
    else {
      ram_43 = 0;
      bit_2B_3 = '\0';
      do {
        fp_ld_pow10_r1(ram_43,0x47);
        fp_cmp(0x50);
        if ((char)in_PSW < '\0') {
          range_lim_down = (ram_43 + 1) * '\x10';
          in_PSW = 0;
          meter_state = meter_state & 0x8f | range_lim_down;
          bit_2B_3 = '\x01';
        }
        bVar1 = ram_43 + 1;
        bVar2 = bVar1;
        if (bit_2B_3 == '\x01') break;
        in_PSW = (bVar1 < 6) << 7;
        bVar2 = ram_43 - 5;
        ram_43 = bVar1;
      } while ((char)in_PSW < '\0');
      ram_43 = bVar1;
      if (bit_2B_3 != '\x01') {
        in_PSW = in_PSW & 0xdd;
        fp_ld_code_r1(meter_state & 0x8f | 0x60,0x706d,0x43);
        bVar2 = fp_cmp();
        if ((char)in_PSW < '\0') {
          bit_2D_1 = '\x01';
        }
      }
    }
    if (bit_2D_1 == '\0') {
      cal_apply(bVar2);
    }
    else {
      F0 = 1;
      meas_stop_and_reset();
      time_range_limit(0x50);
    }
    fp_ld_xdata_r1(0x112,0x50,0x43);
    fp_cmp();
    if ((-1 < (char)in_PSW) || (bit_2E_2 != 0)) {
      ram_2B = ram_2B | 0x90;
      bit_2B_1 = bit_2E_2 & 1 ^ 1;
    }
  }
  return;
}

/* ---- time_range_limit  @0x161F  (23 bytes)
 *      10^(range-1) s * 1.1 (manual-range overload) */
void time_range_limit(void)

{
  fp_ld_pow10_r1((meter_state & 0x70) / 0x10 - 1,(meter_state & 0x70) % 0x10,0x43);
  fp_ld_code_r0(0x6f91);
  fp_mul();
  return;
}

/* ---- fast_mode_drop_digit  @0x1636  (36 bytes)
 *      SPEED 3 (and FRQ SPEED 2): count / 10 */
void fast_mode_drop_digit(uint8_t param_1,uint8_t param_2,uint8_t param_3)

{
  if (((((meter_state & 0xf) == 10) && (speed_b1 != '\x01')) && (speed_b0 == '\x01')) ||
     (speed_b1 != '\0')) {
    i24_ld_code_r1(0x6fe3,0x42);
    i24_mul_signed(0x4f);
    ram_4D = param_1;
    ram_4E = param_2;
    ram_4F = param_3;
  }
  return;
}

/* ---- range_scale_exp  @0x165A  (9 bytes)
 *      A = base(function) + range. Bases: Vpk -4, V -5, ohm -2, I -11 (-9 if 25h.6), time 0, C -14, f -3 (-4 in range 6), degC -1, diode -4, cont -2 */
char range_scale_exp(void)

{
  char cVar1;
  
  cVar1 = (meter_state & 0xf) << 1;
                    /* WARNING: Switch is manually overridden */
  switch(cVar1) {
  case '\0':
  case '\x1c':
override_jmp_CODE_1662_case_14:
    cVar1 = -4;
override_jmp_CODE_1662_case_15:
    break;
  case '\x02':
    goto LAB_CODE_1683;
  case '\x04':
    goto LAB_CODE_1683;
  case '\x06':
LAB_CODE_1683:
    cVar1 = -5;
    break;
  case '\b':
    goto LAB_CODE_1687;
  case '\n':
    goto LAB_CODE_1687;
  case '\f':
    goto LAB_CODE_168b;
  case '\x0e':
LAB_CODE_168b:
    if (bit_25_6 == '\0') {
      cVar1 = -0xb;
    }
    else {
      cVar1 = -9;
    }
    break;
  case '\x10':
    cVar1 = '\0';
    break;
  case '\x12':
    cVar1 = -0xe;
    break;
  case '\x14':
    if ((meter_state & 0x70) == 0x60) {
      cVar1 = -4;
    }
    else {
      cVar1 = -3;
    }
    break;
  case '\x16':
    cVar1 = -1;
    break;
  case '\x18':
    goto override_jmp_CODE_1662_case_14;
  case '\x1a':
LAB_CODE_1687:
    cVar1 = -2;
    break;
  case '\x1e':
    goto override_jmp_CODE_1662_case_15;
  }
  return (meter_state & 0x70) / 0x10 + cVar1;
}

/* ---- count_to_value  @0x16BA  (18 bytes)
 *      4Fh (i24 count) -> float * 10^range_scale_exp */
void count_to_value(void)

{
  i24_to_fp(0x4f);
  range_scale_exp();
  fp_ld_pow10_r1(0x43);
  fp_mul(0x50);
  return;
}

/* ---- value_to_count  @0x16CC  (16 bytes)
 *      inverse of count_to_value */
void value_to_count(void)

{
  range_scale_exp();
  fp_ld_pow10_r1(0x43);
  fp_div(0x50);
  fp_to_i24_round();
  return;
}

/* ---- autorange_finish_common  @0x1750  (16 bytes) */
void autorange_finish_common(void)

{
  meas_stop_and_reset();
  ram_2E = ram_2E & 0xf9;
  bit_25_0 = 0;
  bit_2B_4 = 0;
  bit_2C_0 = 1;
  ram_2C = ram_2C & 0xf9;
  return;
}

/* ---- autorange_enter_fast  @0x1760  (28 bytes)
 *      (inferred) remember speed, go fast while ranging */
void autorange_enter_fast(void)

{
  if (bit_2C_5 != '\x01') {
    bit_2C_5 = '\x01';
    ram_35 = ram_35 & 0xfc | meter_mode & 3;
    speed_force_fast();
  }
  bit_22_3 = 1;
  xram_01A3 = xram_01A3 + '\x01';
  autorange_finish_common();
  return;
}

/* ---- autorange_leave_fast  @0x177C  (13 bytes) */
void autorange_leave_fast(void)

{
  if (bit_2C_5 != '\0') {
    speed_restore();
    bit_22_3 = 1;
    bit_2C_5 = '\0';
  }
  autorange_finish_common();
  return;
}

/* ---- autorange_count_step  @0x1789  (21 bytes) */
void autorange_count_step(void)

{
  ram_34 = ram_34 + '\x01';
  if ((meter_state & 0xf) == 10) {
    ram_35 = ram_35 & 0x8f | 0x60;
    autorange_enter_fast();
    return;
  }
  autorange_leave_fast();
  return;
}

/* ---- autorange_reset  @0x179E  (14 bytes) */
void autorange_reset(void)

{
  ram_34 = 0;
  BANK3_R2 = 0;
  xram_01A3 = 0;
  bit_2A_3 = 0;
  autorange_count_step();
  return;
}

/* ---- result_apply_db_rel  @0x17AC  (128 bytes)
 *      dB conversion (reference XDATA 0x0075) and zero/relative subtraction (0x0079) */
void result_apply_db_rel(void)

{
  uint8_t bVar1;
  char cVar2;
  
  if (bit_22_0 != '\0') {
    bVar1 = (meter_mode & 3) + ((meter_state & 0x70) >> 4);
    cVar2 = (6 < bVar1) << 7;
    fp_ld_pow10_r1('\x06' - bVar1,0x43);
    fp_mul(0x43,0x50);
    fp_to_i24_round();
    i24_abs();
    i24_st_r0_xdata(0x116);
    i24_ld_code_r1(0x6fef,0x46);
    i24_cmp();
    if (cVar2 < '\0') {
      fp_ld_max_r0();
      ram_50 = ram_50 | 0x80;
      bit_2B_5 = '\x01';
    }
    else {
      fp_copy_r0_to_r1(0x50);
      fp_mul();
      fp_ld_pow10_r1(3);
      fp_mul();
      fp_ld_xdata_r1(0x75);
      fp_div();
      db_log10_value(3);
      fp_ld_pow10_r1(1);
      fp_mul();
    }
  }
  if ((bit_2B_5 != '\x01') && (bit_22_1 != '\0')) {
    fp_ld_xdata_r1(0x79,0x50,0x43);
    fp_sub();
  }
  return;
}

/* ---- result_store  @0x182C  (13 bytes)
 *      store float result to XDATA 0x00F2 */
void result_store(void)

{
  bit_26_7 = 1;
  fp_st_r0_xdata(0xf2,0x50);
  bit_24_1 = 1;
  return;
}

/* ---- meas_build_status  @0x1839  (57 bytes)
 *      status byte 0 (56h): b0 crest(C) b1 overload(O) b2 cal fail(F) b3 unsettled(R) b4 uncal(N) b5 dB underflow(U) b7 no fresh conv. */
void meas_build_status(void)

{
  ram_56 =
       (bit_2D_1 & 1) << 1 | bit_2D_0 & 1 | (bit_2C_4 & 1) << 2 | (bit_2B_6 & 1) << 3 | (bit_23_7 & 1) << 4 |
       (bit_2B_5 & 1) << 5 | (bit_2E_2 & 1 ^ 1) << 7;
  ram_57 = meter_state & 0x70;
  if ((meter_state & 0xe) == 6) {
    ram_57 = ram_57 | bit_25_6 << 7;
  }
  return;
}

/* ---- minmax_update  @0x1872  (61 bytes)
 *      compare result with min (0x007D) / max (0x0081), store */
void minmax_update(void)

{
  char cVar1;
  char in_PSW;
  
  fp_ld_xdata_r1(0x7d,0x50,0x43);
  fp_cmp();
  if (in_PSW < '\0') {
    fp_st_r0_xdata(0x7d);
    xram_0069 = ram_56;
    xram_006A = ram_57;
  }
  fp_ld_xdata_r1(0x81);
  cVar1 = fp_cmp();
  if ((cVar1 != '\0') && (-1 < in_PSW)) {
    fp_st_r0_xdata(0x81);
    xram_006B = ram_56;
    xram_006C = ram_57;
  }
  return;
}

/* ---- meas_publish_result  @0x18AF  (38 bytes)
 *      0x0064/0x0065 status, 0x0085 value (float), 0x0066 |= 1 on any error */
void meas_publish_result(void)

{
  bit_24_0 = 1;
  trigger_pending = 0;
  bit_25_4 = 1;
  result_status0 = ram_56;
  result_status1 = ram_57;
  fp_st_r0_xdata(0x85,0x50);
  if ((ram_56 & 0x2f) != 0) {
    result_flags = result_flags | 1;
  }
  return;
}

/* ---- hold_store_result  @0x18D5  (26 bytes)
 *      held status 0x0067/0x0068, value 0x0089 */
void hold_store_result(void)

{
  bit_24_1 = 1;
  bit_26_3 = 1;
  bit_2B_1 = 0;
  xram_0067 = ram_56;
  xram_0068 = ram_57;
  fp_st_r0_xdata(0x89,0x50);
  return;
}

/* ---- meas_result_complete  @0x18EF  (93 bytes)
 *      publish result, min/max values 0x0089/0x008D/0x0091, restart ADC */
void meas_result_complete(void)

{
  uint8_t bVar1;
  char cVar2;
  
  if (bit_2E_2 != '\0') {
    if ((bit_2D_1 != '\x01') && (bit_2B_5 != '\x01')) {
      fp_st_r0_xdata(0x91,0x55);
      fp_st_r0_xdata(0x8d,0x50);
      bit_26_5 = 1;
    }
    cVar2 = ((meter_state & 0xf) < 8) << 7;
    if ((meter_state & 0xf) == 8) {
      fp_ld_pow10_r1(1,0x55,0x43);
      fp_cmp();
      if (-1 < cVar2) {
        adc_start_alt_mode();
      }
    }
    bVar1 = ram_50;
    cVar2 = ((meter_state & 0xf) < 0xd) << 7;
    if ((meter_state & 0xf) == 0xd) {
      ram_50 = ram_50 & 0x7f;
      fp_ld_pow10_r1(1,0x50,0x43);
      fp_cmp();
      ram_50 = bVar1;
      if (cVar2 < '\0') {
        adc_start_alt_mode();
      }
      else {
        adc_start_cycle();
      }
    }
    meas_publish_result();
  }
  hold_store_result();
  return;
}

/* ---- range_can_go_up  @0x194C  (13 bytes)
 *      C=1 if range+1 is enabled in valid_range_masks */
uint8_t range_can_go_up(void)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar4;
  uint8_t bVar3;
  uint8_t *pbVar5;
  
  bVar1 = meter_state >> 4 & 7;
  if (bVar1 == 7) {
    return 7;
  }
  cVar2 = bVar1 + 1;
  pbVar5 = (uint8_t *)(s_CLOSED__OPEN__99999999E_09__AUTO_CODE_6e7f + 0x55);
  bVar4 = (meter_state & 0xf) * '\x03';
  bVar1 = CARRY1(meter_mode & 3,bVar4) << 7;
  dptr_add_a_b((meter_mode & 3) + bVar4);
  cVar2 = cVar2 + '\x01';
  bVar4 = *pbVar5;
  do {
    bVar3 = bVar4 >> 1 | bVar1 & 0x80;
    bVar1 = bVar4 << 7;
    cVar2 = cVar2 + -1;
    bVar4 = bVar3;
  } while (cVar2 != '\0');
  return bVar3;
}

/* ---- range_can_go_down  @0x1959  (60 bytes)
 *      C=1 if range-1 is enabled (current on 25h.6 input: only from range 6/7) */
uint8_t range_can_go_down(void)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar4;
  uint8_t bVar3;
  uint8_t *pbVar5;
  
  if ((((meter_state & 0xf ^ 6) & 0xe) == 0) && (bit_25_6 != '\0')) {
    return 0;
  }
  bVar1 = meter_state >> 4 & 7;
  if (bVar1 == 0) {
    return 0;
  }
  cVar2 = bVar1 - 1;
  pbVar5 = (uint8_t *)(s_CLOSED__OPEN__99999999E_09__AUTO_CODE_6e7f + 0x55);
  bVar4 = (meter_state & 0xf) * '\x03';
  bVar1 = CARRY1(meter_mode & 3,bVar4) << 7;
  dptr_add_a_b((meter_mode & 3) + bVar4);
  cVar2 = cVar2 + '\x01';
  bVar4 = *pbVar5;
  do {
    bVar3 = bVar4 >> 1 | bVar1 & 0x80;
    bVar1 = bVar4 << 7;
    cVar2 = cVar2 + -1;
    bVar4 = bVar3;
  } while (cVar2 != '\0');
  return bVar3;
}

/* ---- range_can_go_up_saved  @0x1995  (19 bytes) */
void range_can_go_up_saved(void)

{
  uint8_t uVar1;
  
  uVar1 = meter_mode;
  if (bit_2C_5 == '\0') {
    range_can_go_up();
  }
  else {
    speed_restore();
    range_can_go_up();
    meter_mode = uVar1;
  }
  return;
}

/* ---- range_param_lookup  @0x19A8  (19 bytes)
 *      per-range constants (tables 0x6FE9..0x7031) */
void range_param_lookup(void)

{
  i24_clr_r0(0x42);
                    /* WARNING: Switch is manually overridden */
  switch((meter_state & 0xf) * '\x03') {
  case 0:
    i24_ld_code_r0(0x6ffb);
    if (bit_20_6 == '\x01') {
      i24_ld_code_r1(&range_count_limits,0x4a);
      i24_ld_code_r0(0x7007);
    }
    else {
      i24_ld_code_r1(0x700d,0x4a);
      i24_ld_code_r0(0x7010);
    }
    break;
  case 3:
    goto LAB_CODE_1a0d;
  case 6:
    goto LAB_CODE_1a0d;
  case 9:
LAB_CODE_1a0d:
    i24_ld_code_r0(0x700a);
    if (bit_20_6 == '\x01') {
LAB_CODE_1a35:
      i24_ld_code_r1(0x7019);
      i24_ld_code_r0(0x701c,0x4a);
    }
    else {
LAB_CODE_1a1e:
      i24_ld_code_r1(0x7022);
      i24_ld_code_r0(0x7025,0x4a);
    }
    break;
  case 0xc:
    goto LAB_CODE_1a18;
  case 0xf:
LAB_CODE_1a18:
    i24_ld_code_r0(0x700a);
    goto LAB_CODE_1a1e;
  case 0x12:
    goto LAB_CODE_1a2f;
  case 0x15:
LAB_CODE_1a2f:
    i24_ld_code_r0(0x7001);
    goto LAB_CODE_1a35;
  case 0x18:
    i24_ld_code_r1(0x7028,0,0x46);
    i24_ld_code_r0(0x702b,0x4a);
    break;
  case 0x1b:
    i24_ld_code_r0(0x700a);
    i24_ld_code_r1(0x7022);
    i24_ld_code_r0(0x7025,0x4a);
    break;
  case 0x1e:
    i24_ld_code_r0(0x7016);
    if ((bit_20_6 == '\0') || (bit_20_5 != '\x01')) {
      i24_ld_code_r1(0x7028,0x4a);
      i24_ld_code_r0(0x702b);
    }
    else {
      i24_ld_code_r1(0x702e,0x4a);
      i24_ld_code_r0(0x7031);
    }
    break;
  case 0x21:
    i24_ld_code_r1(0x7013,0,0x46);
    i24_copy_r1_to_r0(0x4a);
    break;
  case 0x24:
    goto LAB_CODE_1aa4;
  case 0x27:
LAB_CODE_1aa4:
    i24_ld_code_r1(0x7025,0,0x46);
    i24_copy_r1_to_r0(0x4a);
  }
  return;
}

/* ---- count_calibrated  @0x1AB0  (16 bytes)
 *      count -> value -> cal_apply -> count */
void count_calibrated(void)

{
  fast_mode_drop_digit();
  if (cal_mode != '\x01') {
    count_to_value();
    cal_apply();
    value_to_count();
  }
  return;
}

/* ---- meas_prepare_count  @0x1AC0  (62 bytes) */
void meas_prepare_count(void)

{
  if ((meter_state & 0x7f) == 0x2a) {
    if (BANK2_R4 == '\t') {
      xdata_clear3(0xfe);
    }
    i24_copy_r1_to_r0(0x18);
    i24_ld_xdata_r1(0xfe,0x42);
    i24_sub();
    i24_st_r1_xdata(0xfe,0x18);
    ram_43 = 10;
    i24_div10_rem(0x43);
  }
  else {
    i24_copy_r1_to_r0(0x4f,0x10);
  }
  count_calibrated();
  return;
}

/* ---- autorange_step  @0x1AFE  (118 bytes)
 *      compare count with 42h (down), 46h (up), 4Ah (overload); step meter_state range by +-0x10 */
void autorange_step(void)

{
  bool bVar1;
  char in_PSW;
  
  range_param_lookup();
  bVar1 = ram_4F < '\0';
  if (bVar1) {
    i24_abs();
  }
  bit_2B_2 = bVar1;
  if (cal_mode == '\x01') goto LAB_CODE_1b54;
  if (meter_autorange != '\0') {
    if ((bit_2D_1 != '\x01') && (i24_cmp(0x46), in_PSW < '\0')) {
      i24_cmp(0x42);
      if ((in_PSW < '\0') && (range_can_go_down(), in_PSW < '\0')) {
        bit_22_3 = 1;
        meter_state = meter_state - 0x10;
      }
      goto LAB_CODE_1b54;
    }
    range_can_go_up_saved();
    if (in_PSW < '\0') {
      bit_22_3 = 1;
      meter_state = meter_state + 0x10;
      goto LAB_CODE_1b54;
    }
  }
  i24_cmp(0x4a);
  if (-1 < in_PSW) {
    bit_2D_1 = '\x01';
  }
LAB_CODE_1b54:
  if ((((bit_2D_1 != '\0') && (i24_copy_r1_to_r0(0x4f,0x4a), (meter_state & 0xf) == 0)) &&
      (peak_mode_b1 != '\0')) && (peak_mode_b0 != '\0')) {
    clc_thunk();
  }
  if (bit_2B_2 != '\0') {
    i24_neg();
  }
  return;
}

/* ---- autorange_apply  @0x1B74  (67 bytes)
 *      step range, show dashes while ranging */
void autorange_apply(void)

{
  F0 = 1;
  if (bit_22_3 == '\0') {
    if (bit_2C_5 != '\0') {
      autorange_leave_fast();
      bit_2B_1 = 1;
      return;
    }
    if (bit_2D_1 != '\0') {
      meas_stop_and_reset();
    }
    bit_2B_4 = 1;
    return;
  }
  if ((meter_state & 0xf) == 10) {
    ram_35 = ram_35 & 0x8f | 0x60;
  }
  autorange_enter_fast();
  if (((((meter_state & 0xf) == 10) || (trigger_pending == '\0')) || (bit_26_1 == '\x01')) ||
     (xram_01A3 < 10)) {
    return;
  }
  lcd_show_message(&msg_table);
  return;
}

/* ---- vpp_range_check  @0x1BB7  (105 bytes)
 *      Vpp: both polarity counts (0x0101/0x0104) */
void vpp_range_check(void)

{
  char cVar1;
  
  if (bit_2E_2 == '\0') {
    meas_prepare_count();
    i24_st_r0_xdata(0x101,0x4f);
  }
  else {
    meas_prepare_count();
    i24_st_r0_xdata(0x104,0x4f);
    ram_51 = meter_state;
    cVar1 = autorange_step();
    if ((bit_2D_1 != '\x01') &&
       ((bit_22_3 == '\0' || (cVar1 = ram_51 - meter_state, meter_state <= ram_51)))) {
      bit_2B_3 = bit_22_3 != '\0';
      if ((bool)bit_2B_3) {
        bit_22_3 = '\0';
        meter_state = ram_51;
      }
      i24_ld_xdata_r0(cVar1,0x101,0x4f);
      cVar1 = autorange_step();
      if (((bit_2D_1 != '\x01') &&
          (((bit_22_3 == '\0' || (cVar1 = ram_51 - meter_state, meter_state <= ram_51)) &&
           (bit_22_3 != '\0')))) && (bit_2B_3 != '\x01')) {
        bit_22_3 = '\0';
        meter_state = ram_51;
      }
    }
    autorange_apply(cVar1);
  }
  return;
}

/* ---- cap_range_check  @0x1C20  (67 bytes)
 *      capacitance branch of meas_range_checks */
void cap_range_check(void)

{
  if (bit_2E_2 == '\0') {
    i24_st_r0_xdata(0xf6,0x10);
    return;
  }
  i24_copy_r1_to_r0(0x4f,0x10);
  i24_ld_xdata_r1(0xf6,0x42);
  i24_add();
  i24_sar1();
  count_calibrated();
  autorange_step();
  F0 = 1;
  if (bit_22_3 == '\0') {
    if (bit_2C_5 == '\0') {
      bit_2B_4 = 1;
      return;
    }
    autorange_leave_fast();
    return;
  }
  if ((meter_state >> 4 & 7) < 6) {
    autorange_enter_fast();
    return;
  }
  autorange_leave_fast();
  return;
}

/* ---- meas_range_checks  @0x1C63  (35 bytes)
 *      calls 1BB7/1C20/1AC0/1AFE/1B74 (over/under-range handling?) */
void meas_range_checks(void)

{
  if ((((meter_state & 0xf) == 0) && (peak_mode_b1 != '\0')) && (peak_mode_b0 != '\0')) {
    vpp_range_check();
  }
  else if ((meter_state & 0xf) == 9) {
    cap_range_check();
  }
  else {
    meas_prepare_count();
    autorange_step();
    autorange_apply();
  }
  return;
}

/* ---- freq_autorange  @0x1C86  (41 bytes)
 *      function 10 only: gate-time autorange, thresholds 90/103, 900/1003 counts */
void freq_autorange(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  uint8_t in_PSW;
  uint8_t bVar3;
  char cVar4;
  uint16_t uVar5;
  
  F0 = 1;
  bVar1 = meter_state >> 4 & 7;
  if (meter_autorange == '\x01') {
    bit_2B_3 = '\0';
    bVar3 = in_PSW & 0xdd;
                    /* WARNING: Switch is manually overridden */
    switch(ram_35 >> 4 & 7) {
    case 2:
      break;
    case 4:
      i24_ld_code_r1(0x6ff8,0x10,0x42);
      i24_cmp();
      if ((char)bVar3 < '\0') {
        i24_ld_code_r1(0x6ff5);
        i24_cmp();
        if (((char)bVar3 < '\0') || (bVar1 != 4)) goto LAB_CODE_1d59;
      }
      if (bVar1 != 4) {
        meter_state = meter_state & 0x8f | 0x40;
      }
      bit_2B_3 = '\x01';
      goto LAB_CODE_1d59;
    case 6:
      i24_ld_code_r1(0x7004,0x10,0x42);
      i24_cmp();
      if ((char)bVar3 < '\0') {
        i24_ld_code_r1(0x7001);
        i24_cmp();
        if (((char)bVar3 < '\0') || (bVar3 = (bVar1 < 6) << 7, bVar1 != 6)) {
          i24_ld_code_r1(0x6ff8);
          i24_cmp();
          if ((char)bVar3 < '\0') {
            i24_ld_code_r1(0x6ff5);
            i24_cmp();
            if (((char)bVar3 < '\0') || (bVar1 != 5)) goto LAB_CODE_1d59;
          }
          if (bVar1 != 5) {
            meter_state = meter_state & 0x8f | 0x50;
          }
          bit_2B_3 = '\x01';
          goto LAB_CODE_1d59;
        }
      }
      if (bVar1 != 6) {
        meter_state = meter_state & 0x8f | 0x60;
      }
      bit_2B_3 = '\x01';
      goto LAB_CODE_1d59;
    }
    bit_2B_3 = '\x01';
    i24_ld_code_r1(0x6ff8,0x10,0x42);
    i24_cmp();
    if ((char)bVar3 < '\0') {
      i24_ld_code_r1(0x6ff5);
      i24_cmp();
      if (((char)bVar3 < '\0') || (bVar1 != 3)) {
        if (bVar1 != 2) {
          meter_state = meter_state & 0x8f | 0x20;
          bit_2B_1 = 1;
        }
        goto LAB_CODE_1d59;
      }
    }
    if (bVar1 != 3) {
      meter_state = meter_state & 0x8f | 0x30;
    }
LAB_CODE_1d59:
    if (bit_2B_3 == '\0') {
      ram_35 = ram_35 - 0x20;
      autorange_enter_fast();
      return;
    }
    autorange_leave_fast();
    return;
  }
  bVar2 = ram_35 >> 4 & 7;
  bVar3 = in_PSW & 0xdd;
                    /* WARNING: Switch is manually overridden */
  switch(bVar1 << 1) {
  case 4:
    goto LAB_CODE_1d83;
  case 6:
LAB_CODE_1d83:
    cVar4 = (bVar2 < 6) << 7;
    if (bVar2 == 6) {
      i24_ld_code_r1(0x6ffe,0x10,0x42);
      i24_cmp();
      if (cVar4 < '\0') {
        ram_35 = ram_35 & 0x8f | 0x40;
        autorange_enter_fast();
      }
      else {
        bit_2D_1 = '\x01';
      }
      goto LAB_CODE_1dc9;
    }
    cVar4 = (bVar1 < 2) << 7;
    if (bVar1 == 2) {
      uVar5 = 0x6ff2;
    }
    else {
      uVar5 = 0x6ffe;
    }
    i24_ld_code_r1(uVar5,0x10,0x42);
    i24_cmp();
    if (-1 < cVar4) {
      bit_2D_1 = '\x01';
      goto LAB_CODE_1dc9;
    }
    break;
  case 8:
    i24_ld_code_r1(0x6ffe,0x10,0x42);
    i24_cmp();
    if (-1 < (char)bVar3) {
      bit_2D_1 = '\x01';
      goto LAB_CODE_1dc9;
    }
    break;
  case 10:
    break;
  case 0xc:
  }
  autorange_leave_fast();
LAB_CODE_1dc9:
  if (bit_2D_1 != '\0') {
    meas_stop_and_reset();
    range_param_lookup();
    i24_copy_r1_to_r0(0x10,0x4a);
    count_to_value();
    if (cal_mode != '\0') {
      bit_2D_1 = '\0';
      cal_fail(0x14);
    }
  }
  return;
}

/* ---- input_step_detect  @0x1DE7  (132 bytes)
 *      count jump > 10 (VDC, degC) or > 1000: restart averaging */
void input_step_detect(uint8_t param_1)

{
  uint8_t bVar1;
  char cVar2;
  uint16_t uVar3;
  
  if ((((speed_b0 != '\x01') && (speed_b1 != '\x01')) && ((param_1 & 0xf) != 10)) ||
     ((meter_state & 0x7f) == 0x2a)) {
    i24_copy_r1_to_r0(0x42,0x4f);
    i24_ld_xdata_r1(0xfa,0x46);
    i24_sub();
    i24_abs();
    bVar1 = meter_state & 0xf;
    if (bVar1 == 1) {
      uVar3 = 0x7034;
      cVar2 = '\0';
    }
    else {
      cVar2 = (bVar1 < 0xb) << 7;
      if (bVar1 == 0xb) {
        uVar3 = 0x7037;
      }
      else {
        uVar3 = 0x703a;
      }
    }
    i24_ld_code_r1(uVar3,0x4a);
    i24_cmp(0x42);
    if (cVar2 < '\0') {
      bit_2C_3 = '\0';
      i24_st_r0_xdata(0xfa,0x4f);
    }
    else if (bit_2C_3 == '\0') {
      bit_2C_3 = '\x01';
      if (((meter_state & 0xf) == 1) || ((meter_state & 0xf) == 0xb)) {
        bit_2B_4 = 0;
        BANK2_R4 = BANK2_R4 + '\x01';
        if (bit_2E_2 != '\0') {
          bit_2E_2 = '\0';
          bit_2E_1 = 1;
        }
      }
    }
    else {
      i24_st_r0_xdata(0xfa,0x4f);
      F0 = 1;
      autorange_count_step();
      bit_2B_1 = 1;
    }
  }
  return;
}

/* ---- meas_check_settled  @0x1E6B  (21 bytes)
 *      >9 unstable readings (29 in cal mode) -> 'R' */
void meas_check_settled(void)

{
  bool bVar1;
  
  if (cal_mode == '\0') {
    bVar1 = 9 < ram_34;
  }
  else {
    bVar1 = 0x1d < ram_34;
  }
  if (bVar1 << 7 < '\0') {
    F0 = 1;
    meas_stop_and_reset();
    bit_2B_6 = 1;
  }
  return;
}

/* ---- pt100_r_to_temp  @0x1E80  (36 bytes)
 *      Callendar-Van Dusen inversion with fp_sqrt (constants 0x7071/0x7075/0x7079) */
void pt100_r_to_temp(void)

{
  fp_ld_code_r1(0x7071,0x50,0x5b);
  fp_mul();
  fp_ld_code_r1(0x7075);
  fp_rsub();
  fp_sqrt(3);
  fp_ld_code_r1(0x7079);
  fp_rsub();
  return;
}

/* ---- meas_postprocess  @0x1EA4  (332 bytes)
 *      SPEED 1 summing (0x0101/0x0104), digit drop, filter, cal_apply, count_to_value, cal step */
void meas_postprocess(void)

{
  uint8_t bVar1;
  
  if (((speed_b0 != '\x01') && (speed_b1 != '\x01')) && ((meter_state & 0xf) != 10)) {
    i24_ld_xdata_r0(0xf6,0x42);
    i24_ld_xdata_r1(0x107,0x46);
    i24_add();
    i24_st_r0_xdata(0xf6);
  }
  if (((bit_2E_2 == '\0') || (bit_2D_1 == '\x01')) || (bit_2B_6 != '\0')) {
    if ((cal_mode != '\0') && ((bit_2D_1 == '\x01' || (bit_2B_6 != '\0')))) {
      cal_fail(0x15);
      bit_2D_1 = '\0';
      bit_2B_6 = '\0';
    }
    count_to_value();
    return;
  }
  if (((speed_b0 == '\x01') || (speed_b1 == '\x01')) || ((meter_state & 0xf) == 10)) {
    if ((meter_state & 0x7f) != 0x2a) goto LAB_CODE_1f41;
    i24_copy_r1_to_r0(0x10);
    fast_mode_drop_digit();
  }
  else {
    i24_ld_xdata_r0(0xf6,0x4f);
    meas_digital_filter();
    meas_offset_select();
    i24_sub(0x4f,0x42);
  }
  if (cal_mode != '\x01') {
    count_to_value();
    if (((speed_b0 == '\x01') || (speed_b1 == '\x01')) || ((meter_state & 0xf) == 10)) {
      cal_apply();
    }
    else {
      fp_ld_pow10_r1(1,0x50,0x43);
      fp_div();
      cal_apply();
      fp_ld_pow10_r1(1,0x50,0x43);
      fp_mul();
    }
    value_to_count();
  }
LAB_CODE_1f41:
  if ((((meter_state & 0xf) == 0) && (peak_mode_b1 != '\0')) && (peak_mode_b0 != '\0')) {
    i24_ld_xdata_r0(0x101,0x4f);
    i24_ld_xdata_r1(0x104,0x42);
    i24_add();
  }
  bVar1 = meter_state & 0xf;
  if (((bVar1 == 0) || (((bVar1 != 8 && (bVar1 != 10)) && (bVar1 != 0xd)))) &&
     ((cal_mode == '\x01' || ((bit_21_2 != '\x01' && (bit_21_3 != '\x01')))))) {
    if ((((meter_state & 0xf) == 10) && (speed_b0 == '\x01')) || (speed_b1 != '\0')) {
      ram_40 = 10;
      ram_41 = 0;
      range_lim_down = 0;
      i24_div_signed(0x42);
    }
    display_stabilize();
    fast_mode_drop_digit();
  }
  count_to_value();
  if (((speed_b0 != '\x01') && (speed_b1 != '\x01')) && ((meter_state & 0xf) != 10)) {
    fp_ld_pow10_r1(1,0x50,0x43);
    fp_div();
  }
  if ((cal_mode != '\0') && (trigger_pending != '\0')) {
    cal_step_zero();
    if (bit_2E_2 == '\0') {
      bit_2B_4 = 0;
    }
    else if (bit_2C_4 != '\x01') {
      cal_load_range();
      cal_compute_effective();
      cal_apply();
    }
  }
  return;
}

/* ---- result_convert_function  @0x1FF0  (88 bytes)
 *      function-specific conversion (Pt-100 -> degC via pt100_r_to_temp, peak sign) */
void result_convert_function(void)

{
  uint8_t bVar1;
  uint8_t bVar2;
  
  bVar1 = meter_state & 0xf;
  bVar2 = peak_mode_b0;
  if ((bVar1 == 0) || (bVar2 = bVar1, bit_20_3 != '\x01')) {
    if (bVar2 == 1) goto LAB_CODE_200f;
  }
  else if (bVar1 < 0xb) goto LAB_CODE_200f;
  if (ram_50 != 0) {
    ram_50 = ram_50 ^ 0x80;
  }
LAB_CODE_200f:
  if (((cal_enable != '\x01') && (bVar2 = meter_state & 0xf, bVar2 != 1)) && (bVar2 != 6)) {
    if ((bVar2 == 0) && (peak_mode_b0 != 1)) {
      if (-1 < (char)ram_50) {
        ram_50 = 0;
      }
    }
    else if ((char)ram_50 < '\0') {
      ram_50 = 0;
    }
  }
  if ((meter_state & 0xf) == 0xb) {
    pt100_r_to_temp();
  }
  fp_copy_r0_to_r1(0x50,0x55);
  return;
}

/* ---- meas_phase_process  @0x2092  (213 bytes)
 *      process finished conversion: scale, autorange, filter, store */
void meas_phase_process(void)

{
  uint8_t uVar1;
  uint8_t uVar2;
  uint8_t bVar3;
  char in_PSW;
  
  meas_scale_result();
  if (((bit_25_1 == '\x01') || (bit_2D_3 == '\x01')) || (bit_2D_6 != '\0')) {
    meas_process_special();
  }
  else {
    bVar3 = meter_state & 0xf;
    in_PSW = (bVar3 < 8) << 7;
    if (bVar3 == 8) {
      meas_process_time();
    }
    else {
      if ((bit_2C_5 == '\0') || (bVar3 != 10)) {
        meas_range_checks();
        if (bit_2B_4 != 0) {
          if (bit_2D_1 != '\x01') {
            input_step_detect();
          }
          if (bit_2B_4 != 1) {
            meas_check_settled();
          }
          if (bit_2B_4 != 0) {
            meas_postprocess();
          }
        }
      }
      else {
        freq_autorange();
      }
      in_PSW = bit_2B_4 << 7;
      bit_2B_7 = bit_2B_4 & 1;
    }
    if (bit_2B_7 != 0) {
      result_convert_function();
      result_apply_db_rel();
      result_store();
      if (((trigger_pending != '\0') && (bit_2B_4 != 0)) && (bit_24_6 != '\x01')) {
        if (bit_2E_2 != '\x01') {
          if ((bit_2B_1 == '\0') || (cal_mode == '\x01')) goto LAB_CODE_2048;
          if ((speed_b0 == '\x01') || (speed_b1 != '\0')) {
            if ((meter_state & 0x7f) == 0x2a) {
              in_PSW = '\0';
            }
            else {
              in_PSW = ((meter_state & 0xf) < 8) << 7;
              if ((meter_state & 0xf) != 8) goto LAB_CODE_2048;
            }
          }
        }
        meas_build_status();
        if ((bit_2E_2 != '\0') && (cal_mode != '\x01')) {
          minmax_update();
        }
        meas_result_complete();
      }
    }
  }
LAB_CODE_2048:
  uVar2 = ram_31;
  uVar1 = ram_30;
  bit_2C_2 = 0;
  if (bit_2E_2 == '\0') {
    if (bit_2E_1 != '\0') {
      bit_2C_1 = 1;
    }
  }
  else {
    if (((bit_23_4 != '\x01') && (bit_2D_6 != '\x01')) && (bit_2D_3 != '\x01')) {
      out_format_params_a();
      ram_40 = ram_30;
      ram_41 = ram_31;
      range_lim_down = 0;
      ram_43 = 10;
      ram_30 = uVar1;
      ram_31 = uVar2;
      i24_div10_rem(0x42);
      i24_cmp(0x33,0x42);
      if (-1 < in_PSW) {
        i24_clr_r0();
        bit_2D_6 = '\x01';
        bit_22_3 = 1;
      }
    }
    F0 = 0;
    autorange_reset();
  }
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- diag_count_event  @0x211D  (30 bytes)
 *      A = event id: ++XDATA[0x0772+A], ++XDATA[0x076C]. 0x0A,0x0B (ADC timeout),0x0C (no phase) */
void diag_count_event(uint8_t param_1)

{
  char *pcVar1;
  
  pcVar1 = (char *)CONCAT11('\a' - (((0x8d < param_1) << 7) >> 7),param_1 + 0x72);
  *pcVar1 = *pcVar1 + '\x01';
  diag_err_total = diag_err_total + '\x01';
  return;
}

/* ---- meas_phase_acquire  @0x213B  (142 bytes)
 *      start acquisition; branches per function: 0->2201, 8->238C, 9->23E1, 10->24FF, else ADC 22CE */
void meas_phase_acquire(void)

{
  uint8_t uVar1;
  uint8_t bVar2;
  
  if (bit_2E_1 != '\x01') {
    if (bit_2E_2 != '\0') {
      bit_2C_1 = 0;
      diag_count_event(10);
      bit_23_0 = 0;
      bit_22_3 = 1;
      bit_2C_5 = 0;
      bit_25_4 = 1;
      prev_count = 0x7f;
      bit_2C_7 = 1;
      bit_2B_1 = 1;
      adc_start_cycle();
      F0 = bit_23_0 & 1 ^ 1;
      autorange_reset();
      meas_ctx_ptr();
      xdata_swap_iram();
      return;
    }
    xdata_clear3(0xf6);
    uVar1 = 0;
    if ((bit_21_2 != '\x01') && (bit_21_3 != '\x01')) {
      if (bit_2C_7 == '\0') {
        uVar1 = 1;
      }
      else {
        bit_2C_7 = '\0';
      }
    }
    fp_ld_pow10_r1(uVar1,0x11);
    fp_st_r1_xdata(0x112);
    fp_ld_code_r1(0x6f69);
    fp_st_r1_xdata(0x10a);
    fp_ld_pow10_r1(0);
    fp_st_r1_xdata(0x10e);
    i24_clr_r1();
    bit_2D_1 = 0;
    bit_2D_0 = 0;
  }
  if (bit_25_1 == '\x01') {
    if (bit_2E_1 == '\x01') {
      if (bit_25_0 != '\x01') {
        adc_count_hi = adc_count_mid;
        adc_count_mid = TH0;
        adc_count_lo = TL0;
        acq_done();
        return;
      }
    }
    else {
      freq_gate_setup();
    }
    meas_ctx_ptr();
    iram_to_xdata();
    if (bit_2C_5 != '\0') {
      speed_restore();
    }
    return;
  }
  if (bit_2D_3 != '\x01') {
    if (bit_2D_6 == '\0') {
      bVar2 = meter_state & 0xf;
      if (bVar2 != 0) {
        if (bVar2 == 8) {
          acq_time();
          return;
        }
        if (bVar2 == 9) {
          acq_cap();
          return;
        }
        if (bVar2 == 10) {
          acq_freq();
          return;
        }
        goto LAB_CODE_21ae;
      }
    }
    else if (bit_2D_4 == '\x01') {
LAB_CODE_21ae:
      acq_adc();
      return;
    }
  }
  acq_vpeak();
  return;
}

/* ---- adc_start_cycle_alt  @0x21B1  (14 bytes)
 *      cmd 0x8B if 26h.6 else adc_start_cycle */
void adc_start_cycle_alt(void)

{
  if (adc_alt_mode == '\0') {
    adc_start_cycle();
    return;
  }
  i2cB_start(0x8b);
  i2cB_stop();
  return;
}

/* ---- freq_gate_setup  @0x21D7  (42 bytes)
 *      INT1 edge gate + T0/T1 for time/frequency functions */
void freq_gate_setup(void)

{
  uint8_t bVar1;
  
  F0 = 0;
  adc_set_times(0x43,0xe0);
  bVar1 = TMOD;
  TMOD = bVar1 & 0xf1;
  bVar1 = TMOD;
  TMOD = bVar1 | 1;
  bVar1 = TCON;
  TCON = bVar1 & 199;
  IT1 = 1;
  PT0 = 0;
  PX1 = 1;
  TL0 = 0;
  TH0 = 0;
  adc_arm_timeout();
  adc_start_cycle_alt();
  TR0 = 1;
  bVar1 = IE;
  IE = bVar1 | 0x86;
  return;
}

/* ---- acq_vpeak  @0x2201  (205 bytes)
 *      Vpeak: T1=T2=0xF9A7, latch b5/b4 = +/- peak detector, up to 10 repeats, Vpp = both polarities */
void acq_vpeak(void)

{
  uint8_t bVar1;
  char cVar2;
  char cVar3;
  
  if (bit_2E_1 == '\0') {
    BANK2_R4 = '\x01';
    if ((bit_2D_3 != '\x01') && (bit_2D_6 == '\0')) {
      if ((peak_mode_b1 != 0) && (peak_mode_b0 != '\0')) {
        BANK2_R4 = '\x02';
      }
      F0 = peak_mode_b1 & 1;
      goto LAB_CODE_2239;
    }
    BANK2_R7 = '\x02';
    adc_latch_byte = adc_latch_byte & 0xcf;
  }
  else {
    if (bit_25_0 != '\0') goto LAB_CODE_2296;
    F0 = peak_mode_b1 & 1;
    peak_mode_b1 = peak_mode_b1 ^ 1;
LAB_CODE_2239:
    BANK2_R7 = '\n';
    if (peak_mode_b1 == 1) {
      adc_latch_byte = adc_latch_byte & 0xdf | 0x10;
    }
    else {
      adc_latch_byte = adc_latch_byte & 0xef | 0x20;
    }
    bVar1 = F0;
    peak_mode_b1 = bVar1 & 1;
  }
  adc_write_latches(0xa7,0xf9);
  F0 = 0;
  adc_set_times();
  i24_clr_r0(0x10);
  bVar1 = IE;
  IE = bVar1 & 0xf9;
  bVar1 = TMOD;
  TMOD = bVar1 & 0xf5;
  bVar1 = TMOD;
  TMOD = bVar1 | 5;
  bVar1 = TCON;
  TCON = bVar1 & 0xcf;
  TL0 = 0xff;
  TH0 = 0xff;
  adc_arm_timeout();
  shiftreg_out0 = shiftreg_out0 | 0x40;
  shiftreg_write_analog();
  key_debounce_delay();
  shiftreg_out0 = shiftreg_out0 & 0xbf;
  shiftreg_write_analog();
  cVar2 = '\x02';
  cVar3 = -0xc;
  do {
    do {
      cVar3 = cVar3 + -1;
    } while (cVar3 != '\0');
    cVar2 = cVar2 + -1;
  } while (cVar2 != '\0');
  adc_start_cycle_alt();
  TR0 = 1;
LAB_CODE_2296:
  do {
    cVar2 = TF0;
    if ((cVar2 == '\x01') || (cVar2 = T0, cVar2 != '\x01')) {
      TF0 = 0;
      TL0 = 0xff;
      TH0 = 0xff;
      P1 = 0xd7;
      nop();
      nop();
      P1 = 0xe7;
      i24_inc_r0(0x10);
    }
    cVar2 = INT1;
  } while (cVar2 != '\0');
  BANK2_R7 = BANK2_R7 + -1;
  if (BANK2_R7 == '\0') {
    TR0 = 0;
    bit_2E_3 = 0;
    bit_25_0 = '\0';
    BANK2_R4 = BANK2_R4 + -1;
    if (BANK2_R4 == '\0') {
      acq_done();
      return;
    }
    bit_2C_1 = 0;
    bit_2C_2 = 1;
  }
  else {
    adc_start_cycle_alt();
  }
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- acq_adc  @0x22CE  (190 bytes)
 *      default ADC path; AC functions first run a two-phase RMS auto-zero (latch b6 / shiftreg 08h b7) */
void acq_adc(void)

{
  char cVar1;
  uint8_t uVar2;
  uint8_t uVar3;
  uint8_t bVar4;
  
  if (bit_2E_1 == '\0') {
    if ((bit_2D_6 != '\x01') &&
       (((bVar4 = meter_state & 0xf, bVar4 == 2 || (bVar4 == 3)) || (bVar4 == 7)))) {
      if (bit_2F_0 != '\0') {
        bit_2F_0 = '\0';
        shiftreg_out0 = shiftreg_out0 | 0x80;
        shiftreg_write_analog();
        adc_latch_byte = adc_latch_byte & 0xbf;
        adc_write_latches();
        ac_autozero_phase_b();
        bit_2F_1 = '\x01';
        goto meas_exit;
      }
      if (bit_2F_1 == '\0') {
        adc_latch_byte = adc_latch_byte | 0x40;
        adc_write_latches();
        shiftreg_out0 = shiftreg_out0 & 0x7f;
        shiftreg_write_analog();
        ac_autozero_phase_a();
        bit_2F_0 = '\x01';
        goto meas_exit;
      }
      bit_2F_1 = '\0';
    }
    if (bit_2D_6 == '\x01') {
LAB_CODE_2326:
      uVar2 = 0x50;
      uVar3 = 0x8d;
    }
    else {
      uVar2 = 0x88;
      uVar3 = 0xf4;
      if (speed_b1 != '\x01') goto LAB_CODE_2326;
    }
    adc_set_count_time(uVar2,uVar3);
    BANK2_R4 = '\x01';
    if (((bit_2D_6 != '\x01') && (speed_b1 != '\x01')) && (speed_b0 != '\x01')) {
      BANK2_R4 = '\n';
    }
    F0 = 1;
    adc_set_times(xram_00F1,adc_wait_time);
  }
  else if (bit_25_0 != '\0') {
    cVar1 = INT1;
    if (cVar1 == '\x01') goto meas_exit;
    bit_25_0 = '\0';
    bit_2E_3 = 0;
    adc_count_mid = i2cB_read1(0x8d);
    adc_count_lo = i2cB_recv_nack_stop();
    adc_count_hi = 0;
    bit_2C_1 = 0;
    bit_2C_2 = 1;
    BANK2_R4 = BANK2_R4 + -1;
    if (BANK2_R4 == '\0') {
      bit_2E_2 = 1;
      bit_2E_1 = '\0';
      bVar4 = meter_state & 0xf;
      if ((((bVar4 == 2) || (bVar4 == 3)) || (bVar4 == 7)) && (cVar1 = T0, cVar1 != '\x01')) {
        bit_2D_0 = 1;
      }
      goto meas_exit;
    }
  }
  adc_start_cycle_alt();
  adc_arm_timeout();
meas_exit:
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- acq_time  @0x238C  (85 bytes)
 *      function 8 */
void acq_time(void)

{
  uint8_t bVar1;
  char cVar2;
  
  if (bit_2E_1 == '\x01') {
    if (time_started == '\0') {
      if (bit_25_0 == '\x01') {
        bit_2C_1 = 0;
        bit_2C_2 = 1;
      }
      else {
        cVar2 = TR0;
        if (cVar2 != '\x01') {
          acq_done();
          return;
        }
      }
    }
    else {
      time_started = '\0';
      BANK3_R4 = 0xd7;
      bit_2F_2 = '\x01';
    }
  }
  else if ((trigger_pending == '\x01') && (((bit_21_2 == '\x01' || (bit_21_3 == '\x01')) || (bit_2F_2 == '\0')))
          ) {
    TMOD = 0x15;
    bVar1 = TCON;
    TCON = bVar1 & 0xf;
    PT1 = 0;
    PT0 = 1;
    TL1 = 0;
    TH1 = 0;
    TXD = 0;
    if (time_start_negslope != '\0') {
      TXD = 1;
    }
    TL0 = 0xff;
    TH0 = 0xff;
    bit_2E_1 = '\x01';
    bVar1 = IE;
    IE = bVar1 | 0x8a;
    TR0 = 1;
  }
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- acq_cap  @0x23E1  (275 bytes)
 *      function 9 */
void acq_cap(void)

{
  bool bVar1;
  char cVar2;
  uint8_t bVar3;
  
  if (bit_2E_1 == '\0') {
    TMOD = 0x15;
    TCON = 4;
    IP = 6;
    IE = 0x8a;
    F0 = 0;
    adc_set_times(xram_00F1,adc_wait_time);
    BANK2_R4 = '\x02';
    if (bit_2E_4 == '\0') {
      adc_start_cycle();
      bVar3 = TCON;
      TCON = bVar3 & 0x55;
      EX1 = 1;
    }
    else {
      BANK2_R4 = '\x01';
    }
  }
  else {
    if (time_started == '\x01') goto meas_exit;
    if (bit_27_0 == '\0') {
      if (bit_25_0 == '\0') {
        P1_5 = 1;
        adc_latch_byte = adc_latch_byte | 2;
        adc_write_latches();
        bit_2E_3 = 0;
        adc_count_hi = adc_count_mid;
        adc_count_mid = TH1;
        adc_count_lo = TL1;
        BANK2_R4 = BANK2_R4 + -1;
        if (BANK2_R4 != '\0') {
          time_started = '\x01';
          bit_2C_1 = 0;
          bit_2C_2 = 1;
          goto meas_exit;
        }
      }
      else {
        if (speed_b1 == '\x01') {
          bVar3 = TH1;
          bVar1 = bVar3 < 0x62;
          if (bVar3 != 0x62) {
LAB_CODE_24b0:
            if (bVar1 << 7 < '\0') goto meas_exit;
          }
        }
        else {
          if (adc_count_mid + -3 < '\0') goto meas_exit;
          if (adc_count_mid == '\x03') {
            bVar3 = TH1;
            bVar1 = bVar3 < 0xd1;
            if (bVar3 != 0xd1) goto LAB_CODE_24b0;
          }
        }
        IE = 0;
        TCON = 0;
        adc_latch_byte = adc_latch_byte | 2;
        adc_write_latches();
        P1_5 = 1;
        bit_25_0 = '\0';
        bit_2D_1 = 1;
        BANK2_R4 = '\0';
        ram_27 = ram_27 & 0xfc;
      }
      bit_2E_3 = 0;
      if (bit_2E_4 == '\0') {
        acq_done();
        return;
      }
      bit_2E_4 = '\0';
      F0 = 1;
      autorange_reset();
      goto meas_exit;
    }
    do {
      cVar2 = TR1;
    } while (cVar2 == '\x01');
    bit_27_0 = '\0';
  }
  TL0 = 0xff;
  TH0 = 0xff;
  i24_clr_r0(0x10);
  BANK2_R1 = 0;
  TL1 = 0;
  TH1 = 0;
  P1_5 = 0;
  shiftreg_out1 = 0xd1;
  if ((meter_state & 0x70) != 0x70) {
    shiftreg_out1 = 0xd0;
  }
  adc_latch_byte = adc_latch_byte & 0xfe | 0x40;
  shiftreg_write_analog();
  adc_write_latches();
  adc_latch_byte = adc_latch_byte | 4;
  adc_write_latches();
  key_debounce_delay();
  adc_latch_byte = adc_latch_byte & 0xfb;
  adc_write_latches();
  P1_5 = 1;
  bVar3 = (meter_state & 0x70) >> 4;
  if (speed_b1 != '\0') {
    bVar3 = bVar3 + 1;
  }
  shiftreg_out1 = (&cap_range_table)[bVar3 * '\x03' - 5] & 0xf7;
  shiftreg_write_analog(0);
  adc_latch_byte = adc_latch_byte & 0xbd | 1;
  adc_write_latches();
  key_debounce_delay();
  adc_arm_timeout();
  bVar3 = TCON;
  TCON = bVar3 | 0x50;
  P1_5 = 0;
meas_exit:
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- acq_done  @0x24F4  (11 bytes)
 *      conversion finished (2Eh.1 -> 2Eh.2) */
void acq_done(void)

{
  bit_2E_1 = 0;
  bit_2E_2 = 1;
  bit_2C_1 = 0;
  bit_2C_2 = 1;
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- acq_freq  @0x24FF  (97 bytes)
 *      function 10 */
void acq_freq(void)

{
  uint8_t bVar1;
  
  if (bit_2E_1 == '\x01') {
    if (BANK2_R4 == '\0') {
      adc_count_lo = TL0;
      adc_count_mid = TH0;
      bit_2E_2 = 1;
      bit_2E_1 = '\0';
    }
    else if (bit_25_0 == '\0') goto meas_exit;
    bit_25_0 = '\0';
    bit_2C_1 = 0;
    bit_2C_2 = 1;
  }
  else {
    TMOD = 0x15;
    bVar1 = TCON;
    TCON = bVar1 & 0xf;
    PT0 = 0;
    PT1 = 1;
    bVar1 = IE;
    IE = bVar1 | 0x8a;
    ram_27 = ram_27 & 0xfc;
    BANK2_R4 = '\x01';
    if (bit_2C_5 == '\0') {
      if ((bit_20_4 != '\x01') && (bit_20_6 != '\x01')) {
        BANK2_R4 = '\n';
      }
      TL1 = 0;
      TH1 = 0;
      BANK2_R5 = 0x10;
      if (speed_b0 != '\0') {
        BANK2_R5 = 2;
      }
    }
    else {
      TL1 = 0xf0;
      TH1 = 0xd8;
      BANK2_R5 = 1;
    }
    TL0 = 0;
    TH0 = 0;
    bit_2E_1 = '\x01';
    bVar1 = TCON;
    TCON = bVar1 | 0x50;
  }
meas_exit:
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- adc_arm_timeout  @0x2560  (13 bytes)
 *      timeout counter 12h/13h = 0x0420 passes, set busy flags 2Eh.3/25h.0/2Eh.1 */
void adc_arm_timeout(void)

{
  adc_timeout_lo = 0x20;
  adc_timeout_hi = 4;
  bit_2E_3 = 1;
  bit_25_0 = 1;
  bit_2E_1 = 1;
  return;
}

/* ---- adc_write_latches  @0x256D  (6 bytes)
 *      cmd 0x80, 0xD0, IRAM 0Ah = 8 output latches (input sensitivity, beeper) */
void adc_write_latches(void)

{
  adc_latch_cmd_begin();
  i2cB_send_stop();
  return;
}

/* ---- adc_latch_cmd_begin  @0x2573  (13 bytes) */
uint8_t adc_latch_cmd_begin(void)

{
  i2cB_start(0x80);
  i2cB_send_byte(0xd0);
  return adc_latch_byte;
}

/* ---- adc_set_times  @0x2580  (17 bytes)
 *      cmd 0x82 + R6,R5 = wait time T1; if F0=0 also 0x84 (count time T2) */
void adc_set_times(uint8_t param_1,uint8_t param_2)

{
  char cVar1;
  
  i2cB_start(0x82);
  i2cB_send_byte(param_2);
  i2cB_send_stop(param_1);
  cVar1 = F0;
  if (cVar1 == '\0') {
    i2cB_start(0x84);
    i2cB_send_byte(param_2);
    i2cB_send_stop(param_1);
    return;
  }
  return;
}

/* ---- adc_set_count_time  @0x2591  (13 bytes)
 *      cmd 0x84 + R6,R5 = count time T2 */
void adc_set_count_time(uint8_t param_1,uint8_t param_2)

{
  i2cB_start(0x84);
  i2cB_send_byte(param_2);
  i2cB_send_stop(param_1);
  return;
}

/* ---- meas_phase_switch  @0x259E  (592 bytes)
 *      drive motor switch to table position (funcswitch_pos_table), set relays, settle */
void meas_phase_switch(uint8_t *param_1,uint8_t param_2,uint8_t param_3)

{
  uint8_t *puVar1;
  char cVar2;
  char cVar3;
  uint8_t bVar4;
  uint8_t bVar5;
  uint8_t *puVar6;
  
  if (bit_23_4 != '\0') {
    ram_2D = ram_2D & 0x27;
  }
  bit_2C_0 = 0;
LAB_CODE_25a6:
  ram_30 = 0x10;
  if ((bit_2A_0 != '\x01') && (ram_30 = 8, bit_2A_1 != '\x01')) {
    if (((meter_state & 0xf) == 0) && ((peak_mode_b1 != '\0' && (peak_mode_b0 != '\0')))) {
      ram_30 = 8;
    }
    else {
      param_1 = &funcswitch_pos_table;
      ram_30 = (&funcswitch_pos_table)[meter_state & 0xf];
      if (((ram_30 >> 1 & 1) != 0) && ((((meter_state & 0x70) >> 4) - 1 >> 2 & 1) != 0)) {
        ram_30 = 1;
      }
    }
  }
  bVar4 = funcswitch_read_pos(param_3);
  if (bit_2A_1 == '\x01') {
    if (bVar4 == 0) {
      if (bit_2A_2 == '\0') goto LAB_CODE_2655;
      funcswitch_step_count = ram_37 >> 1;
      param_1 = (uint8_t *)0x1cb;
      bit_2A_1 = '\0';
      param_3 = 0;
      goto LAB_CODE_25a6;
    }
    bVar5 = (bVar4 < ram_30) << 7;
    if (bVar4 != ram_30) goto LAB_CODE_263d;
    bit_2A_2 = '\x01';
    ram_37 = ram_37 + 1;
LAB_CODE_2607:
    shiftreg_out0 = shiftreg_out0 & 0xef;
    shiftreg_write_analog();
    shiftreg_out0 = shiftreg_out0 | 0x10;
    shiftreg_write_analog();
    TL0 = 0xd0;
    TH0 = 0x8a;
    BANK3_R3 = 1;
    timer0_start_settle();
LAB_CODE_261f:
    if (bit_2A_0 == '\0') {
      if ((bit_2A_1 != '\x01') && (ram_37 = ram_37 - 1, ram_37 == 0)) {
        bit_2C_0 = 1;
        bit_2E_0 = '\0';
      }
      goto meas_exit;
    }
    ram_2A = ram_2A & 0xfa;
    bVar5 = bVar5 & 0xdd;
    bit_2A_1 = '\x01';
    ram_37 = 0;
    if (bit_2E_0 != '\0') goto meas_exit;
  }
  else {
    if (bVar4 == 0) goto LAB_CODE_2655;
    bVar5 = (bVar4 < ram_30) << 7;
    if (bVar4 == ram_30) {
      if (bit_2E_0 == '\x01') goto LAB_CODE_2607;
      if (bit_2A_0 == '\x01') goto LAB_CODE_261f;
      if (bit_22_3 != '\x01') {
        if ((((bit_25_1 == '\x01') || (bit_2D_3 == '\x01')) || (bit_2D_6 == '\x01')) ||
           ((meter_state & 0xf) != 9)) goto LAB_CODE_27e6;
        goto LAB_CODE_27cb;
      }
      if (((bit_25_1 != '\x01') && (bit_2D_3 != '\x01')) && (bit_2D_6 != '\x01')) {
        cal_load_range();
        if ((cal_enable != '\x01') && (cal_seal_check(), (char)bVar5 < '\0')) {
          bit_23_7 = '\x01';
        }
        if (bit_23_7 != '\0') {
          param_1 = (uint8_t *)0x66;
          result_flags = result_flags | 4;
        }
        cal_compute_effective();
      }
      meas_calc_wait_time();
      adc_latch_byte = adc_latch_byte | 0x40;
      adc_write_latches();
      if (bit_2D_3 == '\x01') {
LAB_CODE_26d3:
        if ((meter_state & 0xf) != 10) {
          adc_latch_byte = adc_latch_byte & 0x7f;
          adc_write_latches();
          shiftreg_out0 = shiftreg_out0 & 0x3f;
          shiftreg_out1 = shiftreg_out1 & 0x7f | 0x68;
          shiftreg_write_analog();
          adc_latch_byte = adc_latch_byte & 0xcf;
          timer1_setup_count();
          adc_latch_send_timed();
          shiftreg_out0 = shiftreg_out0 | 0x20;
          shiftreg_out1 = shiftreg_out1 | 2;
          shiftreg_write_analog();
          P1 = 0xe7;
          TXD = 0;
          adc_latch_byte = adc_latch_byte | 3;
          adc_write_latches();
          shiftreg_out1 = shiftreg_out1 & 0xf2 | 0x10;
          shiftreg_write_analog();
          goto LAB_CODE_27cb;
        }
        bit_2D_3 = '\0';
        bit_2D_4 = '\x01';
      }
      else {
        if (bit_2D_6 == '\0') {
          bVar4 = analog_cfg_flags();
          TXD = bVar4 & 1;
          P1_4 = bVar4 >> 4 & 1;
          if ((bit_2C_5 == '\0') || (param_2 != 0x14)) {
            bVar4 = meter_state;
            if ((speed_b1 != '\0') && (param_2 == 0x12)) {
              bVar4 = meter_state + 0x10;
            }
          }
          else {
            bVar4 = ram_35;
          }
          puVar6 = &analog_cfg_table;
          puVar1 = &shiftreg_out0;
          cVar2 = '\x03';
          do {
            *puVar1 = puVar6[param_1[(uint16_t)param_2 + 1] + ((bVar4 & 0x70) >> 4) * '\x03'];
            puVar1 = puVar1 + '\x01';
            puVar6 = puVar6 + 1;
            cVar2 = cVar2 + -1;
          } while (cVar2 != '\0');
LAB_CODE_276b:
          bVar4 = shiftreg_out0;
          shiftreg_out0 = shiftreg_out0 & 0x7f;
          shiftreg_write_analog();
          bVar5 = adc_latch_byte;
          adc_latch_byte = adc_latch_byte | 0x4c;
          F0 = 0;
          adc_latch_send_timed();
          cVar2 = '\0';
          cVar3 = '\x04';
          do {
            do {
              cVar2 = cVar2 + -1;
            } while (cVar2 != '\0');
            cVar3 = cVar3 + -1;
          } while (cVar3 != '\0');
          adc_latch_byte = bVar5;
          adc_write_latches();
          shiftreg_out0 = bVar4;
          shiftreg_write_analog();
          if (bit_25_1 != '\x01') {
            if (bit_2D_3 != '\x01') {
              if (bit_2D_6 == '\0') {
                bVar4 = meter_state & 0xf;
                if ((((bVar4 != 0) && (bVar4 != 2)) && (bVar4 != 3)) && (bVar4 != 7)) {
                  if (bVar4 == 8) {
                    shiftreg_out1 = shiftreg_out1 & 0xbf;
                  }
                  else if (bVar4 != 9) goto LAB_CODE_27cb;
                }
              }
              else if (bit_2D_4 != '\0') goto LAB_CODE_27cb;
            }
            cVar2 = '\x02';
            cVar3 = -0xc;
            do {
              do {
                cVar3 = cVar3 + -1;
              } while (cVar3 != '\0');
              cVar2 = cVar2 + -1;
            } while (cVar2 != '\0');
            shiftreg_out1 = shiftreg_out1 & 0xf7;
            shiftreg_write_analog();
          }
LAB_CODE_27cb:
          meas_settle_time_select();
          bit_2C_6 = 0;
          bit_22_3 = '\0';
LAB_CODE_27e6:
          ram_2F = ram_2F & 0xfc;
          bit_2C_1 = 1;
          goto meas_exit;
        }
        if (bit_2D_4 != '\x01') goto LAB_CODE_26d3;
      }
      if ((meter_state & 0xf) == 9) {
        shiftreg_out0 = shiftreg_out0 & 0xfc;
      }
      adc_latch_byte = adc_latch_byte & 0xfb | 0xc9;
      analog_cfg_flags();
      goto LAB_CODE_276b;
    }
  }
LAB_CODE_263d:
  bit_2E_5 = '\x01';
  if ((char)bVar5 < '\0') {
    shiftreg_out1 = shiftreg_out1 | 2;
    bVar4 = ram_30 >> 1 | ram_30 << 7;
  }
  else {
    shiftreg_out1 = shiftreg_out1 & 0xfd;
    bVar4 = ram_30 << 1 | ram_30 >> 7;
  }
  if (bVar4 == R7) {
    bit_2E_5 = '\0';
  }
LAB_CODE_2655:
  if (bit_2E_0 != '\x01') {
    shiftreg_out0 = shiftreg_out0 & 0x7f;
    shiftreg_write_analog();
    adc_latch_byte = adc_latch_byte | 0x40;
    adc_write_latches();
    bit_22_3 = '\x01';
  }
  shiftreg_out0 = shiftreg_out0 & 0xef;
  shiftreg_write_analog();
  shiftreg_out0 = shiftreg_out0 | 0x10;
  shiftreg_write_analog();
  TL0 = 0x80;
  TH0 = 0xc1;
  BANK3_R3 = 1;
  if (bit_2E_5 != '\x01') {
    TL0 = 0xd0;
    TH0 = 0x8a;
  }
  timer0_start_settle();
  bit_2E_0 = '\x01';
  if ((bit_2A_0 != '\x01') && (bit_2A_1 != '\x01')) {
    ram_37 = funcswitch_step_count;
  }
meas_exit:
  meas_ctx_ptr();
  iram_to_xdata();
  if (bit_2C_5 != '\0') {
    speed_restore();
  }
  return;
}

/* ---- meas_settle_time_select  @0x27EE  (12 bytes)
 *      T0 settle time per function/range from 3-byte table 0x71D0..0x71EB */
uint8_t meas_settle_time_select(void)

{
  uint8_t bVar1;
  uint8_t uVar2;
  uint8_t *puVar3;
  
  if ((bit_25_1 != '\x01') && (bit_2D_3 != '\x01')) {
    if (bit_2D_6 == '\0') {
      bVar1 = meter_state;
      if (bit_2C_6 != '\0') {
        if ((meter_state & 0x7f) == 0x55) {
          if (cal_mode == '\0') {
            puVar3 = &rom_71E5;
            if (speed_b1 != '\0') {
              puVar3 = &rom_71DF;
            }
            goto LAB_CODE_2871;
          }
        }
        else {
          if ((meter_state & 0x7f) != 0x65) {
            bVar1 = meter_state & 0xf;
            if (bVar1 == 9) {
              puVar3 = &rom_71D3;
              if (speed_b1 != '\x01') {
                puVar3 = &rom_71E2;
              }
              goto LAB_CODE_2871;
            }
            goto LAB_CODE_283d;
          }
          puVar3 = &rom_71E5;
          if (speed_b1 == '\x01') goto LAB_CODE_2871;
        }
        puVar3 = &rom_71EB;
        goto LAB_CODE_2871;
      }
LAB_CODE_283d:
      bVar1 = bVar1 & 0xf;
      if (bVar1 == 0) {
        puVar3 = &rom_71D0;
        goto LAB_CODE_2871;
      }
      if (bVar1 != 8) {
        if (bVar1 != 9) {
          if (bVar1 == 10) {
            uVar2 = ac_autozero_phase_a();
            return uVar2;
          }
          if (((meter_state & 0x7c) == 0) && (speed_b1 != '\x01')) {
            puVar3 = &rom_71E8;
          }
          else {
            puVar3 = &rom_71DC;
          }
          goto LAB_CODE_2871;
        }
        if ((meter_state & 0x60) != 0x60) goto LAB_CODE_27ff;
      }
      puVar3 = &rom_71D9;
      goto LAB_CODE_2871;
    }
    if (bit_2D_4 == '\x01') {
LAB_CODE_27ff:
      puVar3 = &rom_71D6;
      goto LAB_CODE_2871;
    }
  }
  puVar3 = (uint8_t *)0x71cd;
LAB_CODE_2871:
  BANK3_R3 = *puVar3;
  TH0 = puVar3[1];
  TL0 = puVar3[2];
  bit_27_5 = 1;
  bVar1 = TMOD;
  TMOD = bVar1 & 0xf1;
  bVar1 = TMOD;
  TMOD = bVar1 | 1;
  bVar1 = TCON;
  TCON = bVar1 | 0x10;
  bVar1 = IE;
  IE = bVar1 | 0x82;
  return puVar3[2];
}

/* ---- ac_autozero_phase_a  @0x27FA  (8 bytes) */
uint8_t ac_autozero_phase_a(void)

{
  uint8_t bVar1;
  
  BANK3_R3 = uCODE71cd;
  TH0 = uCODE71ce;
  TL0 = uCODE71cf;
  bit_27_5 = 1;
  bVar1 = TMOD;
  TMOD = bVar1 & 0xf1;
  bVar1 = TMOD;
  TMOD = bVar1 | 1;
  bVar1 = TCON;
  TCON = bVar1 | 0x10;
  bVar1 = IE;
  IE = bVar1 | 0x82;
  return uCODE71cf;
}

/* ---- ac_autozero_phase_b  @0x2838  (19 bytes) */
uint8_t ac_autozero_phase_b(void)

{
  uint8_t bVar1;
  
  BANK3_R3 = rom_71E2;
  TH0 = rom_71E3;
  TL0 = rom_71E4;
  bit_27_5 = 1;
  bVar1 = TMOD;
  TMOD = bVar1 & 0xf1;
  bVar1 = TMOD;
  TMOD = bVar1 | 1;
  bVar1 = TCON;
  TCON = bVar1 | 0x10;
  bVar1 = IE;
  IE = bVar1 | 0x82;
  return rom_71E4;
}

/* ---- timer0_start_settle  @0x287F  (15 bytes)
 *      T0 as settle timer (27h.5 mode: ISR kicks watchdog P1.2) */
void timer0_start_settle(void)

{
  uint8_t bVar1;
  
  bit_27_5 = 1;
  bVar1 = TMOD;
  TMOD = bVar1 & 0xf1;
  bVar1 = TMOD;
  TMOD = bVar1 | 1;
  bVar1 = TCON;
  TCON = bVar1 | 0x10;
  bVar1 = IE;
  IE = bVar1 | 0x82;
  return;
}

/* ---- meas_calc_wait_time  @0x288E  (184 bytes)
 *      T1 (XDATA 0x00F0) from mains setting and function */
void meas_calc_wait_time(void)

{
  char cVar1;
  char cVar2;
  uint8_t bVar3;
  char in_PSW;
  uint16_t uVar4;
  
  cVar1 = 'G';
  fp_ld_xdata_r0(0xec);
  cVar2 = 'C';
  fp_ld_code_r1(0x7081,0x43);
  fp_cmp();
  if (in_PSW < '\0') {
    bit_25_1 = 1;
    return;
  }
  fp_ld_code_r1(0x7085);
  fp_cmp();
  if (-1 < in_PSW) {
    bit_25_1 = 1;
    return;
  }
  bit_2B_0 = '\0';
  if (bit_2D_3 == '\x01') {
    return;
  }
  if (bit_2D_6 == '\x01') {
LAB_CODE_28fa:
    uVar4 = 0x7089;
    if (mains_60hz != '\0') {
      uVar4 = 0x708d;
    }
  }
  else {
    bVar3 = meter_state & 0xf;
    if (bVar3 == 0) {
      bit_2B_0 = 0;
      return;
    }
    if (bVar3 == 8) {
      bit_2B_0 = 0;
      return;
    }
    if (bVar3 == 10) {
      bit_2B_0 = 0;
      return;
    }
    if (bVar3 == 9) {
      uVar4 = 0x70a1;
      if (mains_60hz != '\0') {
        uVar4 = 0x70a5;
      }
      if (speed_b1 != '\x01') {
        if ((meter_state & 0x60) == 0x60) {
          uVar4 = 0x70a9;
          if (mains_60hz != '\0') {
            uVar4 = 0x70ad;
          }
        }
        else {
          uVar4 = 0x70b1;
          if (mains_60hz != '\0') {
            uVar4 = 0x70b5;
          }
        }
      }
    }
    else {
      bit_2B_0 = '\x01';
      if (speed_b1 != '\x01') goto LAB_CODE_28fa;
      uVar4 = 0x7091;
      if (mains_60hz != '\0') {
        uVar4 = 0x7095;
      }
    }
  }
  fp_ld_code_r1(uVar4);
  fp_mul();
  fp_to_i24_round();
  if (bit_2D_6 == '\x01') {
LAB_CODE_2920:
    ram_40 = 0x50;
    ram_41 = 0x8d;
  }
  else {
    if (bit_2B_0 == '\0') goto LAB_CODE_2935;
    if (speed_b1 != '\x01') goto LAB_CODE_2920;
    ram_40 = 0x88;
    ram_41 = 0xf4;
  }
  range_lim_down = 0xff;
  i24_add(cVar2 + -1);
LAB_CODE_2935:
  i24_neg();
  adc_wait_time = *(uint8_t *)(cVar1 + -1);
  xram_00F1 = *(uint8_t *)(cVar1 + -2);
  return;
}

/* ---- adc_latch_send_timed  @0x2946  (55 bytes) */
void adc_latch_send_timed(void)

{
  char cVar1;
  char cVar2;
  uint8_t bVar3;
  uint8_t bVar4;
  uint8_t in_PSW;
  
  bVar3 = adc_latch_cmd_begin();
  cVar2 = '\b';
  do {
    bVar4 = bVar3;
    bVar3 = bVar4 << 1 | in_PSW >> 7;
    in_PSW = bVar4 & 0x80;
    P1_7 = bVar4 >> 7;
    T1 = 1;
    do {
      cVar1 = T1;
    } while (cVar1 == '\0');
    if (cVar2 == '\x01') {
      cVar1 = F0;
      if (cVar1 == '\x01') {
        TR1 = bit_2B_3 & 1;
      }
      else {
        if (bit_23_0 != '\0') {
          do {
            cVar1 = TR1;
            if (cVar1 == '\0') goto LAB_CODE_2968;
            cVar1 = ET1;
          } while (cVar1 == '\x01');
          TR1 = 0;
LAB_CODE_2968:
          bit_23_0 = '\0';
        }
        P1_5 = bit_2B_3 & 1;
      }
    }
    T1 = 0;
    cVar2 = cVar2 + -1;
    if (cVar2 == '\0') {
      i2cB_read_ack_bit(bVar3 << 1 | bVar4 >> 7);
      i2cB_stop();
      return;
    }
  } while( true );
}

/* ---- analog_cfg_flags  @0x297D  (15 bytes) */
void analog_cfg_flags(void)

{
  bit_2B_3 = (uint8_t)(&analog_cfg_index)[(meter_state & 0xf) << 1] >> 5 & 1;
  return;
}

/* ---- timer1_setup_count  @0x298C  (54 bytes) */
void timer1_setup_count(void)

{
  uint8_t bVar1;
  
  F0 = 1;
  if (((meter_state & 0xf) < 0xb) && ((meter_state & 0xe) != 4)) {
    bit_2B_3 = 0;
    return;
  }
  bit_2B_3 = 1;
  bVar1 = TMOD;
  TMOD = bVar1 & 0x1f;
  bVar1 = TMOD;
  TMOD = bVar1 | 0x10;
  bVar1 = TCON;
  TCON = bVar1 & 0x3f;
  bVar1 = IE;
  IE = bVar1 | 0x88;
  bit_23_0 = 1;
  TL1 = 0x10;
  TH1 = 0xb6;
  if (mains_60hz != '\x01') {
    TL1 = 0;
    TH1 = 0x8f;
  }
  BANK3_R0 = 3;
  return;
}

/* ---- value_is_signed  @0x377C  (9 bytes)
 *      C=1: value shown with sign (VDC, IDC, degC, Vp+, Vp-, or dB/rel/cal-enable); verified */
void value_is_signed(void)

{
  uint8_t bVar1;
  
  if ((((bit_23_4 != '\x01') && (cal_enable != '\x01')) && (bit_22_1 != '\x01')) && (bit_22_0 != '\x01')) {
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

/* ---- range_decimal_pos  @0x387A  (20 bytes)
 *      decimal point per function/range, table 0x6DC0 */
char range_decimal_pos(char param_1)

{
  uint8_t bVar1;
  
  bVar1 = (&range_decimal_table)[(meter_state & 0xf) * '\b' + param_1];
  if (bit_2E_3 != '\0') {
    bVar1 = bVar1 - 1;
  }
  return ~bVar1 + 1;
}

/* ---- min_reset  @0x3AE2  (47 bytes)
 *      min (XDATA 0x007D) = +max float */
void min_reset(void)

{
  bool bVar1;
  uint8_t uVar2;
  uint8_t *puVar3;
  
  ram_34 = 0;
  do {
    if (3 < ram_34) {
      xram_0069 = 0;
      xram_006A = 4;
      return;
    }
    uVar2 = (&const_fp_table)[ram_34];
    puVar3 = &minmax_min;
    dptr_add_a(ram_34);
    *puVar3 = uVar2;
    bVar1 = ram_34 != 0xff;
    ram_34 = ram_34 + 1;
  } while (bVar1);
  xram_0069 = 0;
  xram_006A = 4;
  return;
}

/* ---- max_reset  @0x3B11  (47 bytes)
 *      max (XDATA 0x0081) = -max float */
void max_reset(void)

{
  bool bVar1;
  uint8_t uVar2;
  uint8_t *puVar3;
  
  ram_34 = 0;
  do {
    if (3 < ram_34) {
      xram_006B = 0;
      xram_006C = 4;
      return;
    }
    uVar2 = (&rom_6FC4)[ram_34];
    puVar3 = &minmax_max;
    dptr_add_a(ram_34);
    *puVar3 = uVar2;
    bVar1 = ram_34 != 0xff;
    ram_34 = ram_34 + 1;
  } while (bVar1);
  xram_006B = 0;
  xram_006C = 4;
  return;
}

/* ---- trigger_restart_measure  @0x3CC3  (17 bytes) */
void trigger_restart_measure(void)

{
  meas_restart_b();
  result_flags = result_flags | 8;
  iface_report_status();
  lcd_show_dashes();
  return;
}

/* ---- result_record_clear  @0x3CD4  (26 bytes)
 *      status1 bit3 = "no reading yet" ('?') */
void result_record_clear(void)

{
  xram_0067 = 0;
  result_status0 = 0;
  xram_0068 = meter_state & 0x70 | 8;
  result_status1 = xram_0068;
  bit_26_3 = 0;
  return;
}

/* ---- result_restart  @0x3CEE  (61 bytes) */
void result_restart(void)

{
  uint8_t bVar1;
  
  result_record_clear();
  bVar1 = bit_21_2;
  if (bit_21_3 != '\0') {
    bVar1 = bit_21_2 & 1 ^ 1;
  }
  if ((char)(bVar1 << 7) < '\0') {
    if (((bit_24_0 == '\x01') || ((result_flags & 8) != 0)) || ((reply_len & 0x80) != 0)) {
      result_flags = result_flags & 0xf7;
      if ((bit_21_2 == 0) || (bit_21_3 == '\x01')) {
        iface_report_status();
      }
      else {
        bit_24_0 = '\x01';
      }
    }
  }
  else {
    result_flags = result_flags | 8;
    iface_report_status();
  }
  return;
}

/* ---- range_find_for_value  @0x3EB1  (106 bytes)
 *      RNG <value>: smallest range covering the value */
char range_find_for_value(void)

{
  uint8_t bVar1;
  char cVar2;
  uint8_t bVar3;
  char cVar4;
  
  if ((((meter_state & 0xf) == 6) || ((meter_state & 0xf) == 7)) && (bit_25_6 != '\0')) {
    ram_5A = 0xe;
  }
  else {
    ram_5A = meter_state & 0xf;
  }
  ram_58 = (&rom_6F14)[ram_5A];
  cVar4 = (8 < (ram_58 & 0x1f)) << 7;
  ram_59 = (ram_58 & 0x1f) - 9;
  cVar2 = '\0';
  ram_5B = (&rom_6F04)[ram_5A];
  for (bVar3 = ram_5B; (bVar3 & 1) != 1; bVar3 = bVar3 >> 1 | bVar3 << 7) {
    cVar2 = cVar2 + '\x01';
  }
  while( true ) {
    fp_ld_pow10_r1(ram_59,0x41,cVar2);
    if ((ram_58 >> 5 & 1) != 0) {
      ram_41 = ram_41 + '\x01';
    }
    fp_cmp(0x41,0x5f);
    if ((-1 < cVar4) || (bVar1 = bVar3 >> 1, bVar3 = bVar1 | bVar3 << 7, (bVar1 & 1) == 0)) break;
    cVar2 = cVar2 + '\x01';
    ram_59 = ram_59 + '\x01';
  }
  fp_copy_r0_to_r1();
  return cVar2;
}

/* ---- range_by_value  @0x3F1D  (113 bytes)
 *      RNG <number> */
void range_by_value(void)

{
  char cVar1;
  uint8_t bVar2;
  
  ram_39 = meter_state & 0xf;
  ram_33 = ram_33 & 0x7f;
  fp_copy_r0_to_r1(0x33,0x5f);
  ram_3C = range_find_for_value();
  cVar1 = ram_3C + 1;
  ram_34 = 0;
  bVar2 = 1;
  do {
    ram_34 = ram_34 << 1 | bVar2;
    bVar2 = 0;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  while ((bit_2D_1 != '\0' && (ram_34 != 0))) {
    bVar2 = (uint8_t)((uint16_t)ram_39 * 3);
    if ((*(uint8_t *)(CONCAT11((char)((uint16_t)ram_39 * 3 >> 8) +
                            ('n' - (((0x2b < bVar2) << 7) >> 7)),bVar2 - 0x2c) +
                  (uint16_t)(meter_mode & 3)) & ram_34) == 0) {
      ram_34 = ram_34 >> 1;
      ram_3C = ram_3C - 1;
    }
    else {
      bit_2D_1 = '\0';
    }
  }
  if (ram_34 == 0) {
    bit_2D_2 = 1;
  }
  else {
    ram_34 = (ram_3C & 7) << 4;
    meter_state = meter_state & 0xf | ram_34;
  }
  return;
}

/* ---- digits_for_range  @0x48A7  (122 bytes)
 *      (inferred) digit count / decimal position from tables 0x6F04/0x6F14 */
void digits_for_range(void)

{
  char cVar1;
  
  if ((((meter_state & 0xf) == 7) || ((meter_state & 0xf) == 6)) && (bit_25_6 != '\0')) {
    ram_59 = 0xe;
  }
  else {
    ram_59 = meter_state & 0xf;
  }
  ram_5A = (&rom_6F14)[ram_59];
  ram_59 = (&rom_6F04)[ram_59];
  ram_58 = '\0';
  for (; -1 < (char)(ram_59 << 7); ram_59 = ram_59 >> 1) {
    ram_58 = ram_58 + '\x01';
  }
  ram_5B = ((meter_state >> 4 & 7) + ((ram_5A & 0x1f) - 9)) - ram_58;
  F0 = 0;
  if ((meter_state & 0x7f | 0x6a) == 0) {
    F0 = 1;
    ram_5B = ram_5B + -1;
  }
  fp_ld_pow10_r1(ram_5B,0x3d);
  cVar1 = F0;
  if ((cVar1 == '\x01') || ((ram_5A >> 5 & 1) != 0)) {
    ram_3D = ram_3D + '\x01';
  }
  return;
}

/* ---- db_log10_value  @0x550C  (61 bytes)
 *      dB: log10 wrapper with saved context (XDATA 0x01AA) */
uint8_t db_log10_value(uint8_t param_1,uint8_t param_2)

{
  uint8_t uVar1;
  uint8_t in_PSW;
  uint8_t bVar2;
  
  xram_01AA = SP;
  bVar2 = in_PSW & 0x7f | (xram_01AA < 0x60) << 7;
  iram_to_xdata(0x1ab,0x60,xram_01AA + 0xa1,param_2,param_1);
  SP = 0x60;
  uVar1 = fp_log10(param_1,param_2);
  SP = xram_01AA;
  xdata_to_iram(0x1ab,0x60,xram_01AA + 0xa1,param_2,uVar1,bVar2);
  return uVar1;
}

/* ---- shiftreg_write_analog  @0x5A8D  (22 bytes)
 *      shift out IRAM 08h,09h on P1.7/T1, latch with P1.3. 09h.1 = switch-motor direction, 08h.4 strobe */
void shiftreg_write_analog(void)

{
  char cVar1;
  
  cVar1 = '\b';
  T1 = 0;
  shiftreg_out_byte(8);
  shiftreg_out_byte(cVar1 + '\x01');
  P1_3 = 1;
  nop();
  P1_3 = 0;
  T1 = 1;
  nop();
  P1_7 = 1;
  return;
}

/* ---- shiftreg_out_byte  @0x5AA3  (15 bytes) */
uint8_t shiftreg_out_byte(uint8_t *param_1)

{
  char cVar1;
  uint8_t bVar2;
  
  bVar2 = *param_1;
  cVar1 = '\b';
  do {
    P1_7 = bVar2 >> 7;
    T1 = 1;
    T1 = 0;
    bVar2 = bVar2 << 1 | bVar2 >> 7;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return bVar2;
}

/* ---- funcswitch_read_pos  @0x5AB2  (29 bytes)
 *      shift in 8 bits from P1.0 = function-switch position (motor-driven rotary switch) */
uint8_t funcswitch_read_pos(uint8_t param_1)

{
  uint8_t bVar1;
  uint8_t bVar2;
  char cVar3;
  
  T1 = 0;
  P1_0 = 1;
  P1_7 = 0;
  cVar3 = '\b';
  P1_7 = 1;
  do {
    bVar2 = P1_0;
    T1 = 1;
    bVar1 = param_1 << 1;
    param_1 = bVar1 | bVar2 & 1;
    T1 = 0;
    cVar3 = cVar3 + -1;
  } while (cVar3 != '\0');
  T1 = 1;
  nop();
  P1_7 = 1;
  return bVar1 & 0x7f | bVar2 & 1;
}

/* ---- filter_init  @0x5BCB  (20 bytes)
 *      XDATA 0x00CC / stabilizer = max */
void filter_init(void)

{
  char cVar1;
  
  cVar1 = 'B';
  i24_ld_max_r0();
  *(uint8_t *)(cVar1 + '\x01') = 0;
  fp_st_r0_xdata(0xcc);
  fp_st_r0_xdata(0xd3);
  return;
}

/* ---- meas_digital_filter  @0x5BED  (21 bytes)
 *      (inferred) running filter on the count, state XDATA 0x00D3/0x00D7 */
void meas_digital_filter(uint8_t param_1)

{
  char cVar1;
  char *pcVar2;
  char cVar3;
  bool bVar4;
  uint8_t bVar5;
  uint8_t *pbVar6;
  
  if ((meter_state & 0xf) == 1) {
    param_1 = param_1 | 0x80;
    pbVar6 = (uint8_t *)0xd7;
    range_lim_overload = 0xf;
    ram_49 = 0x14;
  }
  else {
    param_1 = param_1 & 0x7f;
    pbVar6 = &stabilize_counter;
    range_lim_overload = 4;
    ram_49 = 6;
  }
  ram_4B = *pbVar6;
  i24_ld_xdata_r0(pbVar6 + 1,0x42);
  pcVar2 = &range_lim_up;
  i24_copy_r1_to_r0(0x4f);
  i24_sub(0x42);
  i24_abs_sign_f0();
  bVar5 = ram_4B;
  if ((*pcVar2 == '\0' && pcVar2[-1] == '\0') && ((uint8_t)pcVar2[-2] < range_lim_overload)) {
    ram_4B = ram_4B - 1;
    if ((char)bVar5 < '\0') {
      ram_4B = bVar5 + 1;
    }
    bVar4 = false;
    if ((9 < ram_44) && ((char)param_1 < '\0')) {
      bVar4 = true;
    }
    bVar5 = ram_44 << 1 | ram_44 >> 7;
    cVar3 = F0;
    if (cVar3 != '\0') {
      bVar5 = ~bVar5 + 1;
    }
    ram_4B = bVar5 + ram_4B;
    cVar3 = F0;
    bVar5 = ram_4B;
    if (cVar3 != '\0') {
      bVar5 = ~ram_4B + 1;
      ram_49 = ram_49 + 1;
    }
    if ((-1 < (char)bVar5) && (ram_49 <= bVar5)) {
      cVar3 = '\x01';
      if (bVar4) {
        cVar3 = '\x03';
      }
      do {
        cVar1 = F0;
        if (cVar1 == '\x01') {
          i24_dec_r1();
        }
        else {
          i24_inc_r1();
        }
        cVar3 = cVar3 + -1;
      } while (cVar3 != '\0');
      ram_4B = 0;
    }
    i24_copy_r1_to_r0(0x4f);
  }
  else {
    ram_4B = 0;
    i24_copy_r1_to_r0(0x42,0x4f);
  }
  *pbVar6 = ram_4B;
  i24_st_r0_xdata(pbVar6 + 1,0x42);
  return;
}

/* ---- display_stabilize  @0x5C02  (165 bytes)
 *      last-digit hysteresis against the previous count (XDATA 0x00D3/0x00D4) */
void display_stabilize(uint8_t param_1)

{
  char cVar1;
  char *pcVar2;
  char cVar3;
  bool bVar4;
  uint8_t bVar5;
  
  if ((meter_state & 0xf) == 0xb) {
    return;
  }
  param_1 = param_1 & 0x7f;
  range_lim_overload = 4;
  ram_49 = 6;
  ram_4B = stabilize_counter;
  i24_ld_xdata_r0(0xd4,0x42);
  pcVar2 = &range_lim_up;
  i24_copy_r1_to_r0(0x4f);
  i24_sub(0x42);
  i24_abs_sign_f0();
  cVar3 = ram_4B;
  if ((*pcVar2 == '\0' && pcVar2[-1] == '\0') && ((uint8_t)pcVar2[-2] < range_lim_overload)) {
    ram_4B = ram_4B + -1;
    if (cVar3 < '\0') {
      ram_4B = cVar3 + '\x01';
    }
    bVar4 = false;
    if ((9 < ram_44) && ((char)param_1 < '\0')) {
      bVar4 = true;
    }
    bVar5 = ram_44 << 1 | ram_44 >> 7;
    cVar3 = F0;
    if (cVar3 != '\0') {
      bVar5 = ~bVar5 + 1;
    }
    ram_4B = bVar5 + ram_4B;
    cVar3 = F0;
    bVar5 = ram_4B;
    if (cVar3 != '\0') {
      bVar5 = ~ram_4B + 1;
      ram_49 = ram_49 + 1;
    }
    if ((-1 < (char)bVar5) && (ram_49 <= bVar5)) {
      cVar3 = '\x01';
      if (bVar4) {
        cVar3 = '\x03';
      }
      do {
        cVar1 = F0;
        if (cVar1 == '\x01') {
          i24_dec_r1();
        }
        else {
          i24_inc_r1();
        }
        cVar3 = cVar3 + -1;
      } while (cVar3 != '\0');
      ram_4B = 0;
    }
    i24_copy_r1_to_r0(0x4f);
  }
  else {
    ram_4B = 0;
    i24_copy_r1_to_r0(0x42,0x4f);
  }
  stabilize_counter = ram_4B;
  i24_st_r0_xdata(0xd4,0x42);
  return;
}

/* ---- trigger_clear  @0x5D91  (5 bytes) */
void trigger_clear(void)

{
  bit_24_4 = 0;
  trigger_pending = 0;
  return;
}

/* ---- task_trigger  @0x5D96  (91 bytes)
 *      ZERO key / TRG: sets trigger_pending */
void task_trigger(void)

{
  uint8_t bVar1;
  uint8_t in_PSW;
  char cVar2;
  
  if ((iface_chan_hi != '\0' || iface_chan_lo != '\0') &&
     (in_PSW = in_PSW & 0xdd, ((xram_00E0 | rx_count) & 0x80) != 0)) {
    return;
  }
  if ((xram_00AA & 0x80) != 0) {
    return;
  }
  bit_25_2 = 0;
  cVar2 = xram_00EB << 7;
  if (cVar2 < '\0') {
    if ((cal_mode == '\0') || (cal_step_allowed(xram_00EB >> 1 | in_PSW & 0x80), -1 < cVar2))
    {
      bit_24_5 = 1;
      trigger_restart_measure();
      xram_00EB = xram_00EB & 0xfe;
      bit_25_2 = 1;
    }
    else {
      bit_23_6 = 1;
    }
  }
  else {
    bVar1 = bit_21_3;
    if (bit_21_2 != '\0') {
      bVar1 = bit_21_3 & 1 ^ 1;
    }
    if ((char)(bVar1 << 7) < '\0') {
      bit_25_2 = bit_24_4 & 1;
    }
    else {
      bit_25_2 = bit_25_4 & 1;
    }
  }
  if (bit_25_2 != 0) {
    bit_25_4 = 0;
    bit_24_4 = 0;
    trigger_pending = 1;
  }
  return;
}

