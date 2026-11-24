; PM2525 firmware S25 - relocatable source for sdas8051 (SDCC 4.5)
; Generated once by tools/make_asm.py; from now on this file is the source. Build: python tools/build_fw.py
;
; Areas: VECT (fixed 0x0000), CODE_A (moves, from 0x002B), PINNED (fixed 0x6DAB-0x77B5:
; strings, constants, recipes), CODE_B (moves, from 0x77B6). Code in CODE_A/CODE_B may be
; edited, grown or deleted; the linker moves everything after it. 'FREE' .db lines are unused
; 0xFF bytes: delete them to make room. CODE_A must end before 0x6DAB and CODE_B before 0x8000
; (build_fw.py checks). Do not move anything inside PINNED.

        .module pm2525

; ---- equates: SFRs, IRAM, bits, XDATA ----
x_lcd_text_buf               = 0x0000
meter_autorange              = 0x0007
shiftreg_out0                = 0x0008
speed_b0                     = 0x0008
shiftreg_out1                = 0x0009
speed_b1                     = 0x0009
adc_latch_byte               = 0x000A
rx_index                     = 0x000C
time_stop_negslope           = 0x000C
rx_count                     = 0x000D
time_start_negslope          = 0x000D
adc_count_lo                 = 0x000E
peak_mode_b0                 = 0x000E
adc_count_mid                = 0x000F
peak_mode_b1                 = 0x000F
adc_count_hi                 = 0x0010
adc_timeout_lo               = 0x0012
adc_timeout_hi               = 0x0013
x_iface_rx_buf               = 0x0013
mains_60hz                   = 0x0014
cal_enable                   = 0x0015
cal_mode                     = 0x0016
emo_continuous               = 0x001A
cr_enabled                   = 0x001D
meter_state                  = 0x0020
meter_mode                   = 0x0021
trigger_pending              = 0x0023
x_reply_buf                  = 0x0034
adc_alt_mode                 = 0x0036
time_started                 = 0x0039
cal_hot                      = 0x003A
fnsel_new_function           = 0x003A
range_lim_down               = 0x0042
range_lim_up                 = 0x0046
range_lim_overload           = 0x004A
x_result_status0             = 0x0064
x_result_status1             = 0x0065
x_result_flags               = 0x0066
x_dbm_reference              = 0x0075
x_zero_reference             = 0x0079
x_minmax_min                 = 0x007D
sfr_P0                       = 0x0080
sfr_SP                       = 0x0081
x_minmax_max                 = 0x0081
sfr_DPL                      = 0x0082
sfr_DPH                      = 0x0083
x_result_value               = 0x0085
sfr_PCON                     = 0x0087
sbit_IT0                     = 0x0088
sfr_TCON                     = 0x0088
sbit_IE0                     = 0x0089
sfr_TMOD                     = 0x0089
sbit_IT1                     = 0x008A
sfr_TL0                      = 0x008A
sbit_IE1                     = 0x008B
sfr_TL1                      = 0x008B
sbit_TR0                     = 0x008C
sfr_TH0                      = 0x008C
sbit_TF0                     = 0x008D
sfr_TH1                      = 0x008D
sbit_TR1                     = 0x008E
sbit_TF1                     = 0x008F
sfr_P1                       = 0x0090
x_emo_count                  = 0x0095
sbit_RI                      = 0x0098
sfr_SCON                     = 0x0098
sbit_TI                      = 0x0099
sfr_SBUF                     = 0x0099
sbit_RB8                     = 0x009A
x_jcv_ptr                    = 0x009A
sbit_TB8                     = 0x009B
sbit_REN                     = 0x009C
x_cdp_slot                   = 0x009C
sbit_SM2                     = 0x009D
sbit_SM1                     = 0x009E
sbit_SM0                     = 0x009F
sfr_P2                       = 0x00A0
sbit_EX0                     = 0x00A8
sfr_IE                       = 0x00A8
sbit_ET0                     = 0x00A9
sbit_EX1                     = 0x00AA
sbit_ET1                     = 0x00AB
sbit_ES                      = 0x00AC
sbit_EA                      = 0x00AF
sbit_RXD                     = 0x00B0
sfr_P3                       = 0x00B0
sbit_TXD                     = 0x00B1
sbit_INT0                    = 0x00B2
sbit_INT1                    = 0x00B3
sbit_T0                      = 0x00B4
sbit_T1                      = 0x00B5
sbit_WR                      = 0x00B6
sbit_RD                      = 0x00B7
sbit_PX0                     = 0x00B8
sfr_IP                       = 0x00B8
sbit_PT0                     = 0x00B9
sbit_PX1                     = 0x00BA
sbit_PT1                     = 0x00BB
sbit_PS                      = 0x00BC
x_meas_ctx_save              = 0x00BE
sbit_P                       = 0x00D0
sfr_PSW                      = 0x00D0
sbit_OV                      = 0x00D2
sbit_RS0                     = 0x00D3
x_stabilize_counter          = 0x00D3
sbit_RS1                     = 0x00D4
x_stabilize_prev             = 0x00D4
sbit_F0                      = 0x00D5
sbit_AC                      = 0x00D6
sbit_CY                      = 0x00D7
x_parser_ctx                 = 0x00DB
sfr_ACC                      = 0x00E0
x_reply_pending_cmd          = 0x00E8
x_reply_items_left           = 0x00E9
sfr_B                        = 0x00F0
x_adc_wait_time              = 0x00F0
x_meas_result                = 0x00F2
x_prev_count                 = 0x00FA
x_internal_temp              = 0x0119
x_cal_work_set0              = 0x015F
x_cal_zero_eff               = 0x0177
x_cal_gain_eff               = 0x017B
x_cal_work_set1              = 0x017F
x_cal_zero_eff1              = 0x0197
x_cal_gain_eff1              = 0x019B
x_funcswitch_step_count      = 0x01CB
x_speed_saved                = 0x01CC
x_parser_number              = 0x01D1
x_cal_data_copy1             = 0x0200
x_cal_sum_copy1              = 0x03C8
x_nv_settings_copy1          = 0x03CA
x_cal_data_copy2             = 0x03CF
x_cal_sum_copy2              = 0x0597
x_nv_settings_copy2          = 0x0599
x_cal_data_copy3             = 0x059E
x_cal_sum_copy3              = 0x0766
x_nv_settings_copy3          = 0x0768
x_diag_err_total             = 0x076C
x_cal_sum_err_copy2          = 0x076D
x_cal_sum_err_copy3          = 0x076E
x_cal_repair_copy1           = 0x076F
x_cal_fallback_flags         = 0x0770
x_cal_fail_code              = 0x0771
x_diag_event_counters        = 0x0772
x_cal_ctx_save_area          = 0x07A2
x_rms_byte                   = 0x07FD

        .area   VECT    (ABS,CODE)
        .org    0x0000

reset_vector::
        nop                                          ; 0000
        nop                                          ; 0001
        nop                                          ; 0002
L_0003::
        ljmp   start                                 ; 0003
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF                                                     ; 0006 .....

vec_timer0::
        ljmp   isr_timer0                            ; 000B
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF                                                     ; 000E .....

vec_int1::
        ljmp   isr_int1_gate                         ; 0013
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF                                                     ; 0016 .....

vec_timer1::
        ljmp   isr_timer1                            ; 001B
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF     ; 001E .............

        .area   CODE_A  (REL,CON,CODE)

; main super-loop; re-inits SP each pass, polls interface, runs all tasks
main_loop::
        mov    sfr_PSW, #0x00                        ; 002B
        anl    sfr_P3, #0xDB                         ; 002E
        lcall  i2cB_stop                             ; 0031
        lcall  i2cA_stop                             ; 0034
        orl    sfr_P1, #0xC6                         ; 0037
        orl    sfr_P3, #0x3D                         ; 003A
        mov    sfr_SP, #0x60                         ; 003D
        mov    a, 0x1D                               ; 0040
        mov    sfr_DPH, a                            ; 0042
        orl    a, 0x1E                               ; 0044
        jz     L_0069                                ; 0046
        mov    sfr_DPL, 0x1E                         ; 0048
        lcall  iface_poll_channel                    ; 004B
        mov    dptr, #0x00EB                         ; 004E
        movx   a, @dptr                              ; 0051
        jnb    0xE1, L_005B                          ; 0052
        clr    0xE1                                  ; 0055
        movx   @dptr, a                              ; 0057
        lcall  system_init                           ; 0058
L_005B::
        mov    a, rx_count                           ; 005B
        jnb    0xE7, L_0069                          ; 005D
        anl    a, #0x3F                              ; 0060
        jz     L_0066                                ; 0062
        clr    0x1B                                  ; 0064
L_0066::
        lcall  task_remote_parse                     ; 0066
L_0069::
        lcall  task_display_menu                     ; 0069
        lcall  task_keyboard                         ; 006C
        lcall  task_5468                             ; 006F
        lcall  task_trigger                          ; 0072
        lcall  task_5D02                             ; 0075
        lcall  task_measure                          ; 0078
        jnb    0x21, L_0081                          ; 007B
        lcall  task_display_update                   ; 007E
L_0081::
        lcall  task_remote_reply                     ; 0081
        mov    dptr, #0x00A2                         ; 0084
        movx   a, @dptr                              ; 0087
        mov    r6, a                                 ; 0088
        inc    dptr                                  ; 0089
        movx   a, @dptr                              ; 008A
        mov    r7, a                                 ; 008B
        orl    a, r6                                 ; 008C
        jz     L_00A8                                ; 008D
        mov    a, r6                                 ; 008F
        jz     L_009D                                ; 0090
        dec    r6                                    ; 0092
        cjne   r6, #0x00, L_00A0                     ; 0093
        cjne   r7, #0x00, L_00A0                     ; 0096
        setb   0x21                                  ; 0099
        sjmp   L_00A0                                ; 009B
L_009D::
        dec    r7                                    ; 009D
        mov    r6, #0xFF                             ; 009E
L_00A0::
        mov    dptr, #0x00A2                         ; 00A0
        mov    a, r6                                 ; 00A3
        movx   @dptr, a                              ; 00A4
        inc    dptr                                  ; 00A5
        mov    a, r7                                 ; 00A6
        movx   @dptr, a                              ; 00A7
L_00A8::
        mov    dptr, #0x0012                         ; 00A8
        movx   a, @dptr                              ; 00AB
        add    a, #0xFF                              ; 00AC
        movx   @dptr, a                              ; 00AE
        jnz    L_00E1                                ; 00AF
        mov    a, #0x32                              ; 00B1
        movx   @dptr, a                              ; 00B3
        setb   0x21                                  ; 00B4
        mov    dptr, #0x0056                         ; 00B6
        lcall  iface_poll_channel                    ; 00B9
        mov    dptr, #0x0053                         ; 00BC
        lcall  iface_poll_channel                    ; 00BF
        mov    dptr, #0x0055                         ; 00C2
        movx   a, @dptr                              ; 00C5
        jnb    0xE7, L_00DE                          ; 00C6
        mov    dptr, #0x0053                         ; 00C9
        lcall  iface_receive_channel                 ; 00CC
        jnc    L_00DE                                ; 00CF
        mov    dptr, #0x0059                         ; 00D1
        movx   @dptr, a                              ; 00D4
        jnz    L_00DE                                ; 00D5
        mov    dptr, #0x0053                         ; 00D7
        movx   a, @dptr                              ; 00DA
        orl    a, #0x80                              ; 00DB
        movx   @dptr, a                              ; 00DD
L_00DE::
        lcall  iface_select_pending                  ; 00DE
L_00E1::
        ljmp   main_loop                             ; 00E1

; pick pending interface channel (xdata 0x56/0x53) into ptr 1Dh:1Eh
iface_select_pending::
        mov    dptr, #0x0058                         ; 00E4
        movx   a, @dptr                              ; 00E7
        jnb    0xE7, L_00F8                          ; 00E8
        mov    0x1D, #0x00                           ; 00EB
        mov    0x1E, #0x56                           ; 00EE
        clr    a                                     ; 00F1
L_00F2::
        mov    dptr, #0x005A                         ; 00F2
        movx   @dptr, a                              ; 00F5
        sjmp   L_0110                                ; 00F6
L_00F8::
        mov    dptr, #0x0055                         ; 00F8
        movx   a, @dptr                              ; 00FB
        jnb    0xE7, L_010B                          ; 00FC
        mov    0x1D, #0x00                           ; 00FF
        mov    0x1E, #0x53                           ; 0102
        mov    dptr, #0x0059                         ; 0105
        movx   a, @dptr                              ; 0108
        sjmp   L_00F2                                ; 0109
L_010B::
        clr    a                                     ; 010B
        mov    0x1D, a                               ; 010C
        mov    0x1E, a                               ; 010E
L_0110::
        ret                                          ; 0110

; verify/repair 3 copies, evaluate recipe of current range into cal_work_set0/1
cal_load_range::
        lcall  cal_ctx_save                          ; 0111
        clr    0x1F                                  ; 0114
        jnb    0x1C, L_011C                          ; 0116
        ljmp   L_0347                                ; 0119
L_011C::
        clr    0x3C                                  ; 011C
        mov    sfr_B, #0xFF                          ; 011E
        mov    0x5D, #0x00                           ; 0121
        lcall  cal_checksum_copy1                    ; 0124
        lcall  cal_checksum_copy2                    ; 0127
        lcall  cal_checksum_copy3                    ; 012A
        mov    a, 0x5D                               ; 012D
        jz     L_018A                                ; 012F
        cjne   a, #0x01, L_013C                      ; 0131
        lcall  cal_copy2_to_1                        ; 0134
        lcall  cnt_sum_err_copy1                     ; 0137
        sjmp   L_018A                                ; 013A
L_013C::
        cjne   a, #0x02, L_0147                      ; 013C
        lcall  cal_copy1_to_2                        ; 013F
        lcall  cnt_sum_err_copy2                     ; 0142
        sjmp   L_018A                                ; 0145
L_0147::
        cjne   a, #0x04, L_0152                      ; 0147
        lcall  cal_copy1_to_3                        ; 014A
        lcall  cnt_sum_err_copy3                     ; 014D
        sjmp   L_018A                                ; 0150
L_0152::
        cjne   a, #0x03, L_0163                      ; 0152
        lcall  cal_copy3_to_2                        ; 0155
        lcall  cal_copy2_to_1                        ; 0158
        lcall  cnt_sum_err_copy2                     ; 015B
        lcall  cnt_sum_err_copy1                     ; 015E
        sjmp   L_018A                                ; 0161
L_0163::
        cjne   a, #0x05, L_0174                      ; 0163
        lcall  cal_copy2_to_1                        ; 0166
        lcall  cal_copy1_to_3                        ; 0169
        lcall  cnt_sum_err_copy1                     ; 016C
        lcall  cnt_sum_err_copy3                     ; 016F
        sjmp   L_018A                                ; 0172
L_0174::
        cjne   a, #0x06, L_0185                      ; 0174
        lcall  cal_copy1_to_2                        ; 0177
        lcall  cal_copy1_to_3                        ; 017A
        lcall  cnt_sum_err_copy2                     ; 017D
        lcall  cnt_sum_err_copy3                     ; 0180
        sjmp   L_018A                                ; 0183
L_0185::
        setb   0x3C                                  ; 0185
        lcall  cal_majority_repair                   ; 0187
L_018A::
        lcall  cal_nominal_value                     ; 018A
        mov    r0, #0x47                             ; 018D
        mov    r1, #0x4B                             ; 018F
        mov    a, meter_state                        ; 0191
        anl    a, #0x0C                              ; 0193
        jnz    L_019B                                ; 0195
        jnb    0x06, L_019B                          ; 0197
        inc    @r1                                   ; 019A
L_019B::
        mov    dptr, #T_6F69                         ; 019B
        lcall  fp_ld_code_r0                         ; 019E
        lcall  fp_mul                                ; 01A1
        mov    dptr, #0x0782                         ; 01A4
        lcall  fp_st_r0_xdata                        ; 01A7
        mov    a, @r0                                ; 01AA
        cpl    0xE7                                  ; 01AB
        mov    @r0, a                                ; 01AD
        mov    dptr, #0x0786                         ; 01AE
        lcall  fp_st_r0_xdata                        ; 01B1
        mov    dptr, #T_6F71                         ; 01B4
        lcall  fp_ld_code_r0                         ; 01B7
        lcall  fp_mul                                ; 01BA
        mov    dptr, #0x078A                         ; 01BD
        lcall  fp_st_r0_xdata                        ; 01C0
        mov    a, @r0                                ; 01C3
        cpl    0xE7                                  ; 01C4
        mov    @r0, a                                ; 01C6
        mov    dptr, #0x078E                         ; 01C7
        lcall  fp_st_r0_xdata                        ; 01CA
        lcall  cal_set_slope_limits                  ; 01CD
        clr    a                                     ; 01D0
        mov    dptr, #x_cal_fallback_flags           ; 01D1
        movx   @dptr, a                              ; 01D4
        lcall  cal_recipe_ptr                        ; 01D5
        mov    a, #0x02                              ; 01D8
        movc   a, @a+dptr                            ; 01DA
        mov    c, 0xE7                               ; 01DB
        mov    sbit_F0, c                            ; 01DD
        mov    0x5B, c                               ; 01DF
        clr    a                                     ; 01E1
        movc   a, @a+dptr                            ; 01E2
        push   sfr_ACC                               ; 01E3
        mov    a, #0x01                              ; 01E5
        movc   a, @a+dptr                            ; 01E7
        mov    sfr_DPL, a                            ; 01E8
        mov    0x5B, a                               ; 01EA
        pop    sfr_ACC                               ; 01EC
        mov    sfr_DPH, a                            ; 01EE
        mov    0x5C, a                               ; 01F0
        mov    dptr, #0x0782                         ; 01F2
        lcall  cal_lim_lo_from_xdata                 ; 01F5
        mov    dptr, #0x0786                         ; 01F8
        lcall  cal_lim_hi_from_xdata                 ; 01FB
        clr    a                                     ; 01FE
        mov    sfr_DPL, 0x5B                         ; 01FF
        mov    sfr_DPH, 0x5C                         ; 0202
        mov    c, 0x5B                               ; 0205
        mov    sbit_F0, c                            ; 0207
        lcall  cal_eval_field                        ; 0209
        jnb    0x1F, L_0212                          ; 020C
        ljmp   L_0347                                ; 020F
L_0212::
        mov    dptr, #x_cal_work_set0                ; 0212
        mov    r0, #0x43                             ; 0215
        lcall  fp_st_r0_xdata                        ; 0217
        mov    c, 0x5B                               ; 021A
        jnc    L_0226                                ; 021C
        mov    dptr, #x_cal_work_set1                ; 021E
        mov    r0, #0x47                             ; 0221
        lcall  fp_st_r0_xdata                        ; 0223
L_0226::
        mov    a, meter_state                        ; 0226
        anl    a, #0x7F                              ; 0228
        mov    dptr, #T_6F99                         ; 022A
        cjne   a, #0x65, L_0233                      ; 022D
        mov    dptr, #T_70B9                         ; 0230
L_0233::
        lcall  cal_lim_lo_from_rom                   ; 0233
        mov    a, meter_state                        ; 0236
        anl    a, #0x7F                              ; 0238
        mov    dptr, #T_6F7D                         ; 023A
        cjne   a, #0x65, L_0243                      ; 023D
        mov    dptr, #T_6F79                         ; 0240
L_0243::
        lcall  cal_lim_hi_from_rom                   ; 0243
        mov    a, #0x01                              ; 0246
        mov    sfr_DPL, 0x5B                         ; 0248
        mov    sfr_DPH, 0x5C                         ; 024B
        mov    c, 0x5B                               ; 024E
        mov    sbit_F0, c                            ; 0250
        lcall  cal_eval_field                        ; 0252
        jnb    0x1F, L_025B                          ; 0255
        ljmp   L_0347                                ; 0258
L_025B::
        mov    dptr, #0x0163                         ; 025B
        mov    r0, #0x43                             ; 025E
        lcall  fp_st_r0_xdata                        ; 0260
        mov    c, 0x5B                               ; 0263
        jnc    L_026F                                ; 0265
        mov    dptr, #0x0183                         ; 0267
        mov    r0, #0x47                             ; 026A
        lcall  fp_st_r0_xdata                        ; 026C
L_026F::
        mov    dptr, #T_70C1                         ; 026F
        lcall  cal_lim_lo_from_rom                   ; 0272
        mov    dptr, #T_70BD                         ; 0275
        lcall  cal_lim_hi_from_rom                   ; 0278
        mov    a, #0x02                              ; 027B
        mov    sfr_DPL, 0x5B                         ; 027D
        mov    sfr_DPH, 0x5C                         ; 0280
        mov    c, 0x5B                               ; 0283
        mov    sbit_F0, c                            ; 0285
        lcall  cal_eval_field                        ; 0287
        jnb    0x1F, L_0290                          ; 028A
        ljmp   L_0347                                ; 028D
L_0290::
        mov    dptr, #0x0167                         ; 0290
        mov    r0, #0x43                             ; 0293
        lcall  fp_st_r0_xdata                        ; 0295
        mov    c, 0x5B                               ; 0298
        jnc    L_02A4                                ; 029A
        mov    dptr, #0x0187                         ; 029C
        mov    r0, #0x47                             ; 029F
        lcall  fp_st_r0_xdata                        ; 02A1
L_02A4::
        mov    dptr, #T_70C1                         ; 02A4
        lcall  cal_lim_lo_from_rom                   ; 02A7
        mov    dptr, #T_70BD                         ; 02AA
        lcall  cal_lim_hi_from_rom                   ; 02AD
        mov    a, #0x03                              ; 02B0
        mov    sfr_DPL, 0x5B                         ; 02B2
        mov    sfr_DPH, 0x5C                         ; 02B5
        mov    c, 0x5B                               ; 02B8
        mov    sbit_F0, c                            ; 02BA
        lcall  cal_eval_field                        ; 02BC
        jnb    0x1F, L_02C5                          ; 02BF
        ljmp   L_0347                                ; 02C2
L_02C5::
        mov    dptr, #0x016B                         ; 02C5
        mov    r0, #0x43                             ; 02C8
        lcall  fp_st_r0_xdata                        ; 02CA
        mov    c, 0x5B                               ; 02CD
        jnc    L_02D9                                ; 02CF
        mov    dptr, #0x018B                         ; 02D1
        mov    r0, #0x47                             ; 02D4
        lcall  fp_st_r0_xdata                        ; 02D6
L_02D9::
        mov    dptr, #0x078A                         ; 02D9
        lcall  cal_lim_lo_from_xdata                 ; 02DC
        mov    dptr, #0x078E                         ; 02DF
        lcall  cal_lim_hi_from_xdata                 ; 02E2
        mov    a, #0x04                              ; 02E5
        mov    sfr_DPL, 0x5B                         ; 02E7
        mov    sfr_DPH, 0x5C                         ; 02EA
        mov    c, 0x5B                               ; 02ED
        mov    sbit_F0, c                            ; 02EF
        lcall  cal_eval_field                        ; 02F1
        jnb    0x1F, L_02FA                          ; 02F4
        ljmp   L_0347                                ; 02F7
L_02FA::
        mov    dptr, #0x016F                         ; 02FA
        mov    r0, #0x43                             ; 02FD
        lcall  fp_st_r0_xdata                        ; 02FF
        mov    c, 0x5B                               ; 0302
        jnc    L_030E                                ; 0304
        mov    dptr, #0x018F                         ; 0306
        mov    r0, #0x47                             ; 0309
        lcall  fp_st_r0_xdata                        ; 030B
L_030E::
        mov    dptr, #0x0792                         ; 030E
        lcall  cal_lim_lo_from_xdata                 ; 0311
        mov    dptr, #0x0796                         ; 0314
        lcall  cal_lim_hi_from_xdata                 ; 0317
        mov    a, #0x05                              ; 031A
        mov    sfr_DPL, 0x5B                         ; 031C
        mov    sfr_DPH, 0x5C                         ; 031F
        mov    c, 0x5B                               ; 0322
        mov    sbit_F0, c                            ; 0324
        lcall  cal_eval_field                        ; 0326
        jnb    0x1F, L_032F                          ; 0329
        ljmp   L_0347                                ; 032C
L_032F::
        mov    dptr, #0x0173                         ; 032F
        mov    r0, #0x43                             ; 0332
        lcall  fp_st_r0_xdata                        ; 0334
        mov    c, 0x5B                               ; 0337
        jnc    L_0343                                ; 0339
        mov    dptr, #0x0193                         ; 033B
        mov    r0, #0x47                             ; 033E
        lcall  fp_st_r0_xdata                        ; 0340
L_0343::
        lcall  cal_ctx_restore                       ; 0343
        ret                                          ; 0346
L_0347::
        mov    r0, #0x43                             ; 0347
        mov    r1, #0x4B                             ; 0349
        mov    dptr, #T_6F59                         ; 034B
        lcall  fp_ld_code_r0_thunk                   ; 034E
        mov    dptr, #x_cal_work_set0                ; 0351
        lcall  fp_st_r0_xdata                        ; 0354
        mov    dptr, #x_cal_work_set1                ; 0357
        lcall  fp_st_r0_xdata                        ; 035A
        mov    dptr, #T_6927                         ; 035D
        lcall  fp_ld_code_r0_thunk                   ; 0360
        mov    dptr, #0x0163                         ; 0363
        lcall  fp_st_r0_xdata                        ; 0366
        mov    dptr, #0x0183                         ; 0369
        lcall  fp_st_r0_xdata                        ; 036C
        mov    dptr, #T_6F71                         ; 036F
        lcall  fp_ld_code_r0_thunk                   ; 0372
        mov    dptr, #0x0167                         ; 0375
        lcall  fp_st_r0_xdata                        ; 0378
        mov    dptr, #0x0187                         ; 037B
        lcall  fp_st_r0_xdata                        ; 037E
        mov    dptr, #T_6F71                         ; 0381
        lcall  fp_ld_code_r0_thunk                   ; 0384
        mov    dptr, #0x016B                         ; 0387
        lcall  fp_st_r0_xdata                        ; 038A
        mov    dptr, #0x018B                         ; 038D
        lcall  fp_st_r0_xdata                        ; 0390
        mov    dptr, #T_6F59                         ; 0393
        lcall  fp_ld_code_r0_thunk                   ; 0396
        mov    dptr, #0x016F                         ; 0399
        lcall  fp_st_r0_xdata                        ; 039C
        mov    dptr, #0x018F                         ; 039F
        lcall  fp_st_r0_xdata                        ; 03A2
        mov    dptr, #T_6F59                         ; 03A5
        lcall  fp_ld_code_r0_thunk                   ; 03A8
        mov    dptr, #0x0173                         ; 03AB
        lcall  fp_st_r0_xdata                        ; 03AE
        mov    dptr, #0x0193                         ; 03B1
        lcall  fp_st_r0_xdata                        ; 03B4
        sjmp   L_0343                                ; 03B7

cal_lim_lo_from_xdata::
        lcall  fp_ld_xdata_r1                        ; 03B9
        mov    dptr, #0x079A                         ; 03BC
        ljmp   fp_st_r1_xdata                        ; 03BF

cal_lim_hi_from_xdata::
        lcall  fp_ld_xdata_r1                        ; 03C2
        mov    dptr, #0x079E                         ; 03C5
        ljmp   fp_st_r1_xdata                        ; 03C8

cal_lim_lo_from_rom::
        lcall  fp_ld_code_r1                         ; 03CB
        mov    dptr, #0x079A                         ; 03CE
        ljmp   fp_st_r1_xdata                        ; 03D1

; limits for the coefficient checks at XDATA 0x079A/0x079E
cal_lim_hi_from_rom::
        lcall  fp_ld_code_r1                         ; 03D4
        mov    dptr, #0x079E                         ; 03D7
        ljmp   fp_st_r1_xdata                        ; 03DA

; evaluate one coefficient (mode 0-5) for all records of the recipe
cal_eval_field::
        mov    0x51, a                               ; 03DD
        mov    a, 0x2E                               ; 03DF
        mov    0x3F, a                               ; 03E1
        mov    a, 0x2F                               ; 03E3
        mov    0x5E, a                               ; 03E5
        mov    0x5A, #0x00                           ; 03E7
        mov    r0, #0x43                             ; 03EA
        mov    r1, #0x4B                             ; 03EC
        mov    0x52, sfr_DPL                         ; 03EE
        mov    0x53, sfr_DPH                         ; 03F1
L_03F4::
        mov    a, 0x5A                               ; 03F4
        movc   a, @a+dptr                            ; 03F6
        mov    0x2E, a                               ; 03F7
        mov    a, 0x5A                               ; 03F9
        inc    a                                     ; 03FB
        movc   a, @a+dptr                            ; 03FC
        mov    0x2F, a                               ; 03FD
        lcall  cal_record_layout                     ; 03FF
        mov    c, sbit_F0                            ; 0402
        mov    0x6A, c                               ; 0404
        mov    a, 0x51                               ; 0406
        jz     L_041B                                ; 0408
        dec    a                                     ; 040A
        jz     L_0420                                ; 040B
        dec    a                                     ; 040D
        jz     L_0425                                ; 040E
        dec    a                                     ; 0410
        jz     L_042A                                ; 0411
        dec    a                                     ; 0413
        jz     L_042F                                ; 0414
        dec    a                                     ; 0416
        jz     L_0434                                ; 0417
L_0419::
        sjmp   L_0419                                ; 0419
L_041B::
        lcall  cal_f_zero                            ; 041B
        sjmp   L_0437                                ; 041E
L_0420::
        lcall  cal_f_gain                            ; 0420
        sjmp   L_0437                                ; 0423
L_0425::
        lcall  cal_f_zero_tref                       ; 0425
        sjmp   L_0437                                ; 0428
L_042A::
        lcall  cal_f_gain_tref                       ; 042A
        sjmp   L_0437                                ; 042D
L_042F::
        lcall  cal_f_zero_tslope                     ; 042F
        sjmp   L_0437                                ; 0432
L_0434::
        lcall  cal_f_gain_tslope                     ; 0434
L_0437::
        mov    sfr_DPL, 0x52                         ; 0437
        mov    sfr_DPH, 0x53                         ; 043A
        mov    c, 0x6A                               ; 043D
        mov    sbit_F0, c                            ; 043F
        jnb    sbit_F0, L_044A                       ; 0441
        clr    sbit_F0                               ; 0444
        mov    r0, #0x47                             ; 0446
        sjmp   L_03F4                                ; 0448
L_044A::
        mov    a, 0x3F                               ; 044A
        mov    0x2E, a                               ; 044C
        mov    a, 0x5E                               ; 044E
        mov    0x2F, a                               ; 0450
        ret                                          ; 0452

; mode 0: K0 = product of A pointers (default 0)
cal_f_zero::
        mov    r1, #0x54                             ; 0453
        lcall  cal_next_ptr                          ; 0455
        jb     0x71, L_0463                          ; 0458
        lcall  cal_ld_slot                           ; 045B
        jb     0x1F, L_047F                          ; 045E
        sjmp   L_0466                                ; 0461
L_0463::
        lcall  fp_ld_code_r0_thunk                   ; 0463
L_0466::
        jnb    0x70, L_0477                          ; 0466
        mov    r1, #0x54                             ; 0469
        lcall  cal_next_ptr                          ; 046B
        lcall  cal_ld_slot_r1                        ; 046E
        jb     0x1F, L_047F                          ; 0471
        lcall  fp_mul                                ; 0474
L_0477::
        jb     0x1F, L_047F                          ; 0477
        lcall  cal_check_limits_r1                   ; 047A
        jnc    L_0495                                ; 047D
L_047F::
        jnb    cal_mode, L_0493                      ; 047F
        mov    dptr, #T_6F59                         ; 0482
        lcall  fp_ld_code_r0_thunk                   ; 0485
        clr    0x1F                                  ; 0488
        mov    dptr, #x_cal_fallback_flags           ; 048A
        movx   a, @dptr                              ; 048D
        setb   0xE1                                  ; 048E
        movx   @dptr, a                              ; 0490
        sjmp   L_0495                                ; 0491
L_0493::
        setb   0x1F                                  ; 0493
L_0495::
        ret                                          ; 0495

; mode 1: K1 = B0 * B1.. / Bn (h0>>6 multiplies) (default 1)
cal_f_gain::
        mov    r1, #0x55                             ; 0496
        lcall  cal_next_ptr                          ; 0498
        jb     0x72, L_04AB                          ; 049B
        lcall  cal_ld_slot                           ; 049E
        jb     0x1F, L_0504                          ; 04A1
        lcall  cal_check_limits_r1                   ; 04A4
        jc     L_0504                                ; 04A7
        sjmp   L_04AE                                ; 04A9
L_04AB::
        lcall  fp_ld_code_r0_thunk                   ; 04AB
L_04AE::
        mov    a, 0x2E                               ; 04AE
        rr     a                                     ; 04B0
        rr     a                                     ; 04B1
        rr     a                                     ; 04B2
        mov    sfr_B, a                              ; 04B3
        anl    a, #0x07                              ; 04B5
        xch    a, sfr_B                              ; 04B7
        rr     a                                     ; 04B9
        rr     a                                     ; 04BA
        rr     a                                     ; 04BB
        anl    a, #0x03                              ; 04BC
        xch    a, sfr_B                              ; 04BE
        clr    c                                     ; 04C0
        subb   a, sfr_B                              ; 04C1
        dec    a                                     ; 04C3
        mov    0x3E, a                               ; 04C4
        mov    a, sfr_B                              ; 04C6
L_04C8::
        jz     L_04E4                                ; 04C8
        mov    0x3D, a                               ; 04CA
        mov    r1, #0x55                             ; 04CC
        lcall  cal_next_ptr                          ; 04CE
        lcall  cal_ld_slot_r1                        ; 04D1
        jb     0x1F, L_0504                          ; 04D4
        lcall  cal_check_limits_r0                   ; 04D7
        jc     L_0504                                ; 04DA
        lcall  fp_mul                                ; 04DC
        mov    a, 0x3D                               ; 04DF
        dec    a                                     ; 04E1
        sjmp   L_04C8                                ; 04E2
L_04E4::
        mov    a, 0x3E                               ; 04E4
L_04E6::
        jz     L_0502                                ; 04E6
        mov    sfr_B, a                              ; 04E8
        mov    r1, #0x55                             ; 04EA
        lcall  cal_next_ptr                          ; 04EC
        lcall  cal_ld_slot_r1                        ; 04EF
        jb     0x1F, L_0504                          ; 04F2
        lcall  cal_check_limits_r0                   ; 04F5
        jc     L_0504                                ; 04F8
        lcall  fp_div                                ; 04FA
        mov    a, sfr_B                              ; 04FD
        dec    a                                     ; 04FF
        sjmp   L_04E6                                ; 0500
L_0502::
        sjmp   L_051A                                ; 0502
L_0504::
        jnb    cal_mode, L_0518                      ; 0504
        mov    dptr, #T_6927                         ; 0507
        lcall  fp_ld_code_r0_thunk                   ; 050A
        clr    0x1F                                  ; 050D
        mov    dptr, #x_cal_fallback_flags           ; 050F
        movx   a, @dptr                              ; 0512
        setb   0xE2                                  ; 0513
        movx   @dptr, a                              ; 0515
        sjmp   L_051A                                ; 0516
L_0518::
        setb   0x1F                                  ; 0518
L_051A::
        ret                                          ; 051A

; mode 2: K2 = X (default 0.5)
cal_f_zero_tref::
        mov    r1, #0x56                             ; 051B
        lcall  cal_next_ptr                          ; 051D
        jb     0x78, L_052B                          ; 0520
        lcall  cal_ld_slot                           ; 0523
        jb     0x1F, L_0536                          ; 0526
        sjmp   L_052E                                ; 0529
L_052B::
        lcall  fp_ld_code_r0_thunk                   ; 052B
L_052E::
        jb     0x1F, L_0536                          ; 052E
        lcall  cal_check_limits_r1                   ; 0531
        jnc    L_054C                                ; 0534
L_0536::
        jnb    cal_mode, L_054A                      ; 0536
        mov    dptr, #T_6F71                         ; 0539
        lcall  fp_ld_code_r0_thunk                   ; 053C
        clr    0x1F                                  ; 053F
        mov    dptr, #x_cal_fallback_flags           ; 0541
        movx   a, @dptr                              ; 0544
        setb   0xE3                                  ; 0545
        movx   @dptr, a                              ; 0547
        sjmp   L_054C                                ; 0548
L_054A::
        setb   0x1F                                  ; 054A
L_054C::
        ret                                          ; 054C

; mode 3: K3 = C0 (default 0.5)
cal_f_gain_tref::
        mov    r1, #0x57                             ; 054D
        lcall  cal_next_ptr                          ; 054F
        jb     0x79, L_055D                          ; 0552
        lcall  cal_ld_slot                           ; 0555
        jb     0x1F, L_0568                          ; 0558
        sjmp   L_0560                                ; 055B
L_055D::
        lcall  fp_ld_code_r0_thunk                   ; 055D
L_0560::
        jb     0x1F, L_0568                          ; 0560
        lcall  cal_check_limits_r1                   ; 0563
        jnc    L_057E                                ; 0566
L_0568::
        jnb    cal_mode, L_057C                      ; 0568
        mov    dptr, #T_6F71                         ; 056B
        lcall  fp_ld_code_r0_thunk                   ; 056E
        clr    0x1F                                  ; 0571
        mov    dptr, #x_cal_fallback_flags           ; 0573
        movx   a, @dptr                              ; 0576
        setb   0xE4                                  ; 0577
        movx   @dptr, a                              ; 0579
        sjmp   L_057E                                ; 057A
L_057C::
        setb   0x1F                                  ; 057C
L_057E::
        ret                                          ; 057E

; mode 4: K4 = product of C1.. (default 0)
cal_f_zero_tslope::
        mov    r1, #0x58                             ; 057F
        lcall  cal_next_ptr                          ; 0581
        jb     0x71, L_058F                          ; 0584
        lcall  cal_ld_slot                           ; 0587
        jb     0x1F, L_05AB                          ; 058A
        sjmp   L_0592                                ; 058D
L_058F::
        lcall  fp_ld_code_r0_thunk                   ; 058F
L_0592::
        jnb    0x70, L_05A3                          ; 0592
        mov    r1, #0x58                             ; 0595
        lcall  cal_next_ptr                          ; 0597
        lcall  cal_ld_slot_r1                        ; 059A
        jb     0x1F, L_05AB                          ; 059D
        lcall  fp_mul                                ; 05A0
L_05A3::
        jb     0x1F, L_05AB                          ; 05A3
        lcall  cal_check_limits_r1                   ; 05A6
        jnc    L_05C1                                ; 05A9
L_05AB::
        jnb    cal_mode, L_05BF                      ; 05AB
        mov    dptr, #T_6F59                         ; 05AE
        lcall  fp_ld_code_r0_thunk                   ; 05B1
        clr    0x1F                                  ; 05B4
        mov    dptr, #x_cal_fallback_flags           ; 05B6
        movx   a, @dptr                              ; 05B9
        setb   0xE5                                  ; 05BA
        movx   @dptr, a                              ; 05BC
        sjmp   L_05C1                                ; 05BD
L_05BF::
        setb   0x1F                                  ; 05BF
L_05C1::
        ret                                          ; 05C1

; mode 5: K5 = from D (default 0)
cal_f_gain_tslope::
        mov    r1, #0x59                             ; 05C2
        lcall  cal_next_ptr                          ; 05C4
        jb     0x7A, L_05D7                          ; 05C7
        lcall  cal_ld_slot                           ; 05CA
        jb     0x1F, L_062B                          ; 05CD
        lcall  cal_check_limits_r1                   ; 05D0
        jc     L_062B                                ; 05D3
        sjmp   L_05DA                                ; 05D5
L_05D7::
        lcall  fp_ld_code_r0_thunk                   ; 05D7
L_05DA::
        mov    a, 0x2F                               ; 05DA
        rr     a                                     ; 05DC
        rr     a                                     ; 05DD
        rr     a                                     ; 05DE
        mov    sfr_B, a                              ; 05DF
        anl    a, #0x07                              ; 05E1
        xch    a, sfr_B                              ; 05E3
        rr     a                                     ; 05E5
        rr     a                                     ; 05E6
        rr     a                                     ; 05E7
        anl    a, #0x03                              ; 05E8
        xch    a, sfr_B                              ; 05EA
        clr    c                                     ; 05EC
        subb   a, sfr_B                              ; 05ED
        dec    a                                     ; 05EF
        xch    a, sfr_B                              ; 05F0
L_05F2::
        jz     L_060E                                ; 05F2
        mov    0x3D, a                               ; 05F4
        mov    r1, #0x59                             ; 05F6
        lcall  cal_next_ptr                          ; 05F8
        lcall  cal_ld_slot_r1                        ; 05FB
        jb     0x1F, L_062B                          ; 05FE
        lcall  cal_check_limits_r0                   ; 0601
        jc     L_062B                                ; 0604
        lcall  fp_sub                                ; 0606
        mov    a, 0x3D                               ; 0609
        dec    a                                     ; 060B
        sjmp   L_05F2                                ; 060C
L_060E::
        mov    a, sfr_B                              ; 060E
L_0610::
        jz     L_0629                                ; 0610
        mov    sfr_B, a                              ; 0612
        mov    r1, #0x59                             ; 0614
        lcall  cal_next_ptr                          ; 0616
        lcall  cal_ld_slot_r1                        ; 0619
        lcall  cal_check_limits_r0                   ; 061C
        jc     L_062B                                ; 061F
        lcall  fp_add                                ; 0621
        mov    a, sfr_B                              ; 0624
        dec    a                                     ; 0626
        sjmp   L_0610                                ; 0627
L_0629::
        sjmp   L_0641                                ; 0629
L_062B::
        jnb    cal_mode, L_063F                      ; 062B
        mov    dptr, #T_6F59                         ; 062E
        lcall  fp_ld_code_r0_thunk                   ; 0631
        clr    0x1F                                  ; 0634
        mov    dptr, #x_cal_fallback_flags           ; 0636
        movx   a, @dptr                              ; 0639
        setb   0xE6                                  ; 063A
        movx   @dptr, a                              ; 063C
        sjmp   L_0641                                ; 063D
L_063F::
        setb   0x1F                                  ; 063F
L_0641::
        ret                                          ; 0641

; calibration run: writes a newly measured value into the recipe's slot (mode 0-5)
cal_adjust_slot::
        mov    sfr_B, a                              ; 0642
        lcall  cal_ctx_save                          ; 0644
        mov    r1, #0x43                             ; 0647
        lcall  fp_copy_r0_to_r1                      ; 0649
        mov    r0, #0x43                             ; 064C
        mov    0x51, sfr_B                           ; 064E
        mov    a, 0x2E                               ; 0651
        mov    0x3F, a                               ; 0653
        mov    a, 0x2F                               ; 0655
        mov    0x5E, a                               ; 0657
        mov    c, 0x7F                               ; 0659
        mov    sbit_F0, c                            ; 065B
        lcall  cal_recipe_ptr                        ; 065D
        clr    a                                     ; 0660
        movc   a, @a+dptr                            ; 0661
        xch    a, r5                                 ; 0662
        mov    a, #0x01                              ; 0663
        movc   a, @a+dptr                            ; 0665
        mov    sfr_DPL, a                            ; 0666
        mov    0x52, a                               ; 0668
        xch    a, r5                                 ; 066A
        mov    sfr_DPH, a                            ; 066B
        mov    0x53, a                               ; 066D
        mov    0x5A, #0x00                           ; 066F
L_0672::
        mov    a, 0x5A                               ; 0672
        movc   a, @a+dptr                            ; 0674
        mov    0x2E, a                               ; 0675
        mov    a, 0x5A                               ; 0677
        inc    a                                     ; 0679
        movc   a, @a+dptr                            ; 067A
        mov    0x2F, a                               ; 067B
        lcall  cal_record_layout                     ; 067D
        jnb    sbit_F0, L_0687                       ; 0680
        clr    sbit_F0                               ; 0683
        sjmp   L_0672                                ; 0685
L_0687::
        mov    a, 0x51                               ; 0687
        jz     L_06AE                                ; 0689
        dec    a                                     ; 068B
        jz     L_06B8                                ; 068C
        dec    a                                     ; 068E
        jz     L_06C8                                ; 068F
        dec    a                                     ; 0691
        jz     L_06CF                                ; 0692
        dec    a                                     ; 0694
        jz     L_06D6                                ; 0695
        dec    a                                     ; 0697
        jz     L_06E0                                ; 0698
L_069A::
        sjmp   L_069A                                ; 069A
L_069C::
        lcall  cal_next_ptr                          ; 069C
        lcall  cal_write_all_copies                  ; 069F
        mov    a, 0x3F                               ; 06A2
        mov    0x2E, a                               ; 06A4
        mov    a, 0x5E                               ; 06A6
        mov    0x2F, a                               ; 06A8
        lcall  cal_ctx_restore                       ; 06AA
        ret                                          ; 06AD
L_06AE::
        jb     0x71, L_06AE                          ; 06AE
L_06B1::
        jb     0x70, L_06B1                          ; 06B1
        mov    r1, #0x54                             ; 06B4
        sjmp   L_069C                                ; 06B6
L_06B8::
        jb     0x72, L_06B8                          ; 06B8
        mov    a, 0x2E                               ; 06BB
        anl    a, #0x38                              ; 06BD
        cjne   a, #0x08, L_06C6                      ; 06BF
        mov    r1, #0x55                             ; 06C2
        sjmp   L_069C                                ; 06C4
L_06C6::
        sjmp   L_06C6                                ; 06C6
L_06C8::
        jb     0x78, L_06C8                          ; 06C8
        mov    r1, #0x56                             ; 06CB
        sjmp   L_069C                                ; 06CD
L_06CF::
        jb     0x79, L_06CF                          ; 06CF
        mov    r1, #0x57                             ; 06D2
        sjmp   L_069C                                ; 06D4
L_06D6::
        jb     0x71, L_06D6                          ; 06D6
L_06D9::
        jb     0x70, L_06D9                          ; 06D9
        mov    r1, #0x58                             ; 06DC
        sjmp   L_069C                                ; 06DE
L_06E0::
        jb     0x7A, L_06B8                          ; 06E0
        mov    a, 0x2F                               ; 06E3
        anl    a, #0x38                              ; 06E5
        cjne   a, #0x08, L_06EE                      ; 06E7
        mov    r1, #0x59                             ; 06EA
        sjmp   L_069C                                ; 06EC
L_06EE::
        sjmp   L_06EE                                ; 06EE

; DPTR = cal_recipe_table + cal_recipe_offsets[function] + range*4 (current, 25h.6: range+2)
cal_recipe_ptr::
        mov    a, meter_state                        ; 06F0
        anl    a, #0x0F                              ; 06F2
        cjne   a, #0x06, L_06F9                      ; 06F4
        sjmp   L_06FC                                ; 06F7
L_06F9::
        cjne   a, #0x07, L_0708                      ; 06F9
L_06FC::
        jnb    0x2E, L_0708                          ; 06FC
        mov    a, meter_state                        ; 06FF
        anl    a, #0x70                              ; 0701
        swap   a                                     ; 0703
        add    a, #0x02                              ; 0704
        sjmp   L_070D                                ; 0706
L_0708::
        mov    a, meter_state                        ; 0708
        anl    a, #0x70                              ; 070A
        swap   a                                     ; 070C
L_070D::
        mov    sfr_B, #0x04                          ; 070D
        mul    ab                                    ; 0710
        mov    sfr_B, a                              ; 0711
        mov    a, meter_state                        ; 0713
        anl    a, #0x0F                              ; 0715
        rl     a                                     ; 0717
        push   sfr_ACC                               ; 0718
        inc    a                                     ; 071A
        mov    dptr, #cal_recipe_offsets             ; 071B
        movc   a, @a+dptr                            ; 071E
        add    a, sfr_B                              ; 071F
        mov    sfr_B, a                              ; 0721
        pop    sfr_ACC                               ; 0723
        movc   a, @a+dptr                            ; 0725
        addc   a, #0x00                              ; 0726
        xch    a, sfr_B                              ; 0728
        mov    dptr, #cal_recipe_table               ; 072A
        add    a, sfr_DPL                            ; 072D
        mov    sfr_DPL, a                            ; 072F
        mov    a, sfr_B                              ; 0731
        addc   a, sfr_DPH                            ; 0733
        mov    sfr_DPH, a                            ; 0735
        ret                                          ; 0737
cal_recipe_offsets::
        .db 0xFF, 0xFC, 0x00, 0x10, 0x00, 0x24, 0x00, 0x38, 0x00, 0x4C, 0x00, 0x60, 0x00, 0x78, 0x00, 0x98 ; 0738 .....$.8.L.`.x..
        .db 0x00, 0xB8, 0x00, 0xCC, 0x00, 0xE4, 0x01, 0x00, 0x01, 0x04, 0x01, 0x08           ; 0748 ............

; field offsets of one record from header bytes h0 (2Eh), h1 (2Fh)
cal_record_layout::
        mov    a, 0x5A                               ; 0754
        add    a, #0x02                              ; 0756
        mov    0x54, a                               ; 0758
        mov    a, 0x2E                               ; 075A
        anl    a, #0x01                              ; 075C
        inc    a                                     ; 075E
        rl     a                                     ; 075F
        add    a, 0x54                               ; 0760
        mov    0x55, a                               ; 0762
        mov    a, 0x2E                               ; 0764
        rr     a                                     ; 0766
        rr     a                                     ; 0767
        anl    a, #0x0E                              ; 0768
        add    a, 0x55                               ; 076A
        mov    0x56, a                               ; 076C
        add    a, #0x02                              ; 076E
        mov    0x57, a                               ; 0770
        add    a, #0x02                              ; 0772
        mov    0x58, a                               ; 0774
        mov    a, 0x57                               ; 0776
        add    a, 0x55                               ; 0778
        clr    c                                     ; 077A
        subb   a, 0x5A                               ; 077B
        mov    0x59, a                               ; 077D
        mov    a, 0x2F                               ; 077F
        rr     a                                     ; 0781
        rr     a                                     ; 0782
        anl    a, #0x0E                              ; 0783
        add    a, 0x59                               ; 0785
        mov    0x5A, a                               ; 0787
        ret                                          ; 0789

; fetch next 16-bit pointer of the current record field
cal_next_ptr::
        mov    sfr_DPL, 0x52                         ; 078A
        mov    sfr_DPH, 0x53                         ; 078D
        mov    a, @r1                                ; 0790
        movc   a, @a+dptr                            ; 0791
        push   sfr_ACC                               ; 0792
        inc    @r1                                   ; 0794
        mov    a, @r1                                ; 0795
        movc   a, @a+dptr                            ; 0796
        mov    sfr_DPL, a                            ; 0797
        inc    @r1                                   ; 0799
        pop    sfr_ACC                               ; 079A
        mov    sfr_DPH, a                            ; 079C
        mov    r1, #0x4B                             ; 079E
        ret                                          ; 07A0

fp_ld_code_r0_thunk::
        ljmp   fp_ld_code_r0                         ; 07A1

; load a slot (XDATA) or ROM constant, with validity check
cal_ld_slot::
        push   sfr_B                                 ; 07A4
        mov    sfr_B, #0x00                          ; 07A6
        mov    r4, #0x04                             ; 07A9
L_07AB::
        push   sfr_DPL                               ; 07AB
        push   sfr_DPH                               ; 07AD
        movx   a, @dptr                              ; 07AF
        mov    @r0, a                                ; 07B0
        lcall  cal_addr_copy2                        ; 07B1
        movx   a, @dptr                              ; 07B4
        xrl    a, @r0                                ; 07B5
        jnz    L_07CC                                ; 07B6
        lcall  cal_addr_copy3                        ; 07B8
        movx   a, @dptr                              ; 07BB
        xrl    a, @r0                                ; 07BC
        jz     L_0803                                ; 07BD
        mov    a, @r0                                ; 07BF
        movx   @dptr, a                              ; 07C0
        jb     0x3C, L_07C7                          ; 07C1
        lcall  cal_checksum_copy3                    ; 07C4
L_07C7::
        lcall  cnt_repair_copy3                      ; 07C7
        sjmp   L_0803                                ; 07CA
L_07CC::
        lcall  cal_addr_copy3                        ; 07CC
        movx   a, @dptr                              ; 07CF
        xrl    a, @r0                                ; 07D0
        jnz    L_07E3                                ; 07D1
        lcall  cal_addr_copy2                        ; 07D3
        mov    a, @r0                                ; 07D6
        movx   @dptr, a                              ; 07D7
        jb     0x3C, L_07DE                          ; 07D8
        lcall  cal_checksum_copy2                    ; 07DB
L_07DE::
        lcall  cnt_repair_copy2                      ; 07DE
        sjmp   L_0803                                ; 07E1
L_07E3::
        lcall  cal_addr_copy2                        ; 07E3
        movx   a, @dptr                              ; 07E6
        mov    @r0, a                                ; 07E7
        lcall  cal_addr_copy3                        ; 07E8
        movx   a, @dptr                              ; 07EB
        xrl    a, @r0                                ; 07EC
        jnz    L_07FF                                ; 07ED
        lcall  ret_peek_dptr                         ; 07EF
        mov    a, @r0                                ; 07F2
        movx   @dptr, a                              ; 07F3
        jb     0x3C, L_07FA                          ; 07F4
        lcall  cal_checksum_copy1                    ; 07F7
L_07FA::
        lcall  cnt_repair_copy1                      ; 07FA
        sjmp   L_0803                                ; 07FD
L_07FF::
        setb   0x1F                                  ; 07FF
        mov    r4, #0x01                             ; 0801
L_0803::
        pop    sfr_DPH                               ; 0803
        pop    sfr_DPL                               ; 0805
        inc    dptr                                  ; 0807
        dec    r0                                    ; 0808
        djnz   r4, L_07AB                            ; 0809
        pop    sfr_B                                 ; 080B
        inc    r0                                    ; 080D
        inc    r0                                    ; 080E
        inc    r0                                    ; 080F
        inc    r0                                    ; 0810
        ret                                          ; 0811

cal_ld_slot_r1::
        xch    a, r0                                 ; 0812
        xch    a, r1                                 ; 0813
        xch    a, r0                                 ; 0814
        lcall  cal_ld_slot                           ; 0815
        xch    a, r0                                 ; 0818
        xch    a, r1                                 ; 0819
        xch    a, r0                                 ; 081A
        ret                                          ; 081B

; fetch the caller's saved DPTR from the stack
ret_peek_dptr::
        pop    0x02                                  ; 081C
        pop    0x03                                  ; 081E
        pop    sfr_DPH                               ; 0820
        pop    sfr_DPL                               ; 0822
        push   sfr_DPL                               ; 0824
        push   sfr_DPH                               ; 0826
        push   0x03                                  ; 0828
        push   0x02                                  ; 082A
        ret                                          ; 082C

; DPTR += 0x01CF
cal_addr_copy2::
        pop    0x02                                  ; 082D
        pop    0x03                                  ; 082F
        pop    sfr_DPH                               ; 0831
        pop    sfr_ACC                               ; 0833
        push   sfr_ACC                               ; 0835
        push   sfr_DPH                               ; 0837
        add    a, #0xCF                              ; 0839
        mov    sfr_DPL, a                            ; 083B
        mov    a, sfr_DPH                            ; 083D
        addc   a, #0x01                              ; 083F
        mov    sfr_DPH, a                            ; 0841
        push   0x03                                  ; 0843
        push   0x02                                  ; 0845
        ret                                          ; 0847

; DPTR += 0x039E
cal_addr_copy3::
        pop    0x02                                  ; 0848
        pop    0x03                                  ; 084A
        pop    sfr_DPH                               ; 084C
        pop    sfr_ACC                               ; 084E
        push   sfr_ACC                               ; 0850
        push   sfr_DPH                               ; 0852
        add    a, #0x9E                              ; 0854
        mov    sfr_DPL, a                            ; 0856
        mov    a, sfr_DPH                            ; 0858
        addc   a, #0x03                              ; 085A
        mov    sfr_DPH, a                            ; 085C
        push   0x03                                  ; 085E
        push   0x02                                  ; 0860
        ret                                          ; 0862

cal_write_all_copies_safe::
        push   0x3B                                  ; 0863
        push   0x3C                                  ; 0865
        push   0x3D                                  ; 0867
        push   0x3E                                  ; 0869
        lcall  cal_write_all_copies                  ; 086B
        pop    0x3E                                  ; 086E
        pop    0x3D                                  ; 0870
        pop    0x3C                                  ; 0872
        pop    0x3B                                  ; 0874
        ret                                          ; 0876

; write value to all three copies, refresh the three checksums
cal_write_all_copies::
        lcall  cal_write_verify                      ; 0877
        mov    sfr_B, #0x00                          ; 087A
        lcall  cal_checksum_copy1                    ; 087D
        mov    a, sfr_DPL                            ; 0880
        add    a, #0xCF                              ; 0882
        mov    sfr_DPL, a                            ; 0884
        mov    a, sfr_DPH                            ; 0886
        addc   a, #0x01                              ; 0888
        mov    sfr_DPH, a                            ; 088A
        lcall  cal_write_verify                      ; 088C
        mov    sfr_B, #0x00                          ; 088F
        lcall  cal_checksum_copy2                    ; 0892
        mov    a, sfr_DPL                            ; 0895
        add    a, #0xCF                              ; 0897
        mov    sfr_DPL, a                            ; 0899
        mov    a, sfr_DPH                            ; 089B
        addc   a, #0x01                              ; 089D
        mov    sfr_DPH, a                            ; 089F
        lcall  cal_write_verify                      ; 08A1
        mov    sfr_B, #0x00                          ; 08A4
        lcall  cal_checksum_copy3                    ; 08A7
        ret                                          ; 08AA

; write 4 bytes with read-back check
cal_write_verify::
        mov    a, @r0                                ; 08AB
        mov    sfr_B, a                              ; 08AC
        movx   @dptr, a                              ; 08AE
        movx   a, @dptr                              ; 08AF
        cjne   a, sfr_B, cal_write_verify            ; 08B0
        inc    dptr                                  ; 08B3
        dec    r0                                    ; 08B4
L_08B5::
        mov    a, @r0                                ; 08B5
        mov    sfr_B, a                              ; 08B6
        movx   @dptr, a                              ; 08B8
        movx   a, @dptr                              ; 08B9
        cjne   a, sfr_B, L_08B5                      ; 08BA
        inc    dptr                                  ; 08BD
        dec    r0                                    ; 08BE
L_08BF::
        mov    a, @r0                                ; 08BF
        mov    sfr_B, a                              ; 08C0
        movx   @dptr, a                              ; 08C2
        movx   a, @dptr                              ; 08C3
        cjne   a, sfr_B, L_08BF                      ; 08C4
        inc    dptr                                  ; 08C7
        dec    r0                                    ; 08C8
L_08C9::
        mov    a, @r0                                ; 08C9
        mov    sfr_B, a                              ; 08CA
        movx   @dptr, a                              ; 08CC
        movx   a, @dptr                              ; 08CD
        cjne   a, sfr_B, L_08C9                      ; 08CE
        inc    r0                                    ; 08D1
        inc    r0                                    ; 08D2
        inc    r0                                    ; 08D3
        mov    a, sfr_DPL                            ; 08D4
        add    a, #0xFD                              ; 08D6
        mov    sfr_DPL, a                            ; 08D8
        jc     L_08DE                                ; 08DA
        dec    sfr_DPH                               ; 08DC
L_08DE::
        ret                                          ; 08DE

cal_check_limits_r1::
        mov    0x3C, r1                              ; 08DF
        mov    r1, #0x50                             ; 08E1
        mov    dptr, #0x079A                         ; 08E3
        lcall  fp_ld_xdata_r1                        ; 08E6
        lcall  fp_cmp                                ; 08E9
        jc     L_08F1                                ; 08EC
        setb   c                                     ; 08EE
        sjmp   L_08FA                                ; 08EF
L_08F1::
        mov    dptr, #0x079E                         ; 08F1
        lcall  fp_ld_xdata_r1                        ; 08F4
        lcall  fp_cmp                                ; 08F7
L_08FA::
        mov    r1, 0x3C                              ; 08FA
        ret                                          ; 08FC

cal_check_limits_r0::
        mov    0x3B, r0                              ; 08FD
        mov    r0, #0x50                             ; 08FF
        mov    dptr, #0x079A                         ; 0901
        lcall  fp_ld_xdata_r0                        ; 0904
        lcall  fp_cmp                                ; 0907
        jnc    L_090E                                ; 090A
        sjmp   L_0918                                ; 090C
L_090E::
        mov    dptr, #0x079E                         ; 090E
        lcall  fp_ld_xdata_r0                        ; 0911
        lcall  fp_cmp                                ; 0914
        cpl    c                                     ; 0917
L_0918::
        mov    r0, 0x3B                              ; 0918
        ret                                          ; 091A

; B=0: store sum, else compare (sets 5Dh.0 on mismatch)
cal_checksum_copy1::
        mov    0x3E, sfr_DPH                         ; 091B
        mov    0x3D, sfr_DPL                         ; 091E
        mov    0x3B, r0                              ; 0921
        mov    0x3C, r1                              ; 0923
        mov    dptr, #x_cal_data_copy1               ; 0925
        mov    r0, #0xC8                             ; 0928
        mov    r1, #0x01                             ; 092A
        lcall  sum16_xdata                           ; 092C
        mov    dptr, #x_cal_sum_copy1                ; 092F
        mov    a, sfr_B                              ; 0932
        jnz    L_093B                                ; 0934
        lcall  sum16_store                           ; 0936
        sjmp   L_094A                                ; 0939
L_093B::
        lcall  sum16_compare                         ; 093B
        mov    0x51, r2                              ; 093E
        mov    0x52, r3                              ; 0940
        jz     L_094A                                ; 0942
        mov    a, 0x5D                               ; 0944
        setb   0xE0                                  ; 0946
        mov    0x5D, a                               ; 0948
L_094A::
        mov    r0, 0x3B                              ; 094A
        mov    r1, 0x3C                              ; 094C
        mov    sfr_DPH, 0x3E                         ; 094E
        mov    sfr_DPL, 0x3D                         ; 0951
        ret                                          ; 0954

cal_checksum_copy2::
        mov    0x3E, sfr_DPH                         ; 0955
        mov    0x3D, sfr_DPL                         ; 0958
        mov    0x3B, r0                              ; 095B
        mov    0x3C, r1                              ; 095D
        mov    dptr, #x_cal_data_copy2               ; 095F
        mov    r0, #0xC8                             ; 0962
        mov    r1, #0x01                             ; 0964
        lcall  sum16_xdata                           ; 0966
        mov    dptr, #x_cal_sum_copy2                ; 0969
        mov    a, sfr_B                              ; 096C
        jnz    L_0975                                ; 096E
        lcall  sum16_store                           ; 0970
        sjmp   L_0984                                ; 0973
L_0975::
        lcall  sum16_compare                         ; 0975
        mov    0x53, r2                              ; 0978
        mov    0x54, r3                              ; 097A
        jz     L_0984                                ; 097C
        mov    a, 0x5D                               ; 097E
        setb   0xE1                                  ; 0980
        mov    0x5D, a                               ; 0982
L_0984::
        mov    r0, 0x3B                              ; 0984
        mov    r1, 0x3C                              ; 0986
        mov    sfr_DPH, 0x3E                         ; 0988
        mov    sfr_DPL, 0x3D                         ; 098B
        ret                                          ; 098E

cal_checksum_copy3::
        mov    0x3E, sfr_DPH                         ; 098F
        mov    0x3D, sfr_DPL                         ; 0992
        mov    0x3B, r0                              ; 0995
        mov    0x3C, r1                              ; 0997
        mov    dptr, #x_cal_data_copy3               ; 0999
        mov    r0, #0xC8                             ; 099C
        mov    r1, #0x01                             ; 099E
        lcall  sum16_xdata                           ; 09A0
        mov    dptr, #x_cal_sum_copy3                ; 09A3
        mov    a, sfr_B                              ; 09A6
        jnz    L_09AF                                ; 09A8
        lcall  sum16_store                           ; 09AA
        sjmp   L_09BE                                ; 09AD
L_09AF::
        lcall  sum16_compare                         ; 09AF
        mov    0x55, r2                              ; 09B2
        mov    0x56, r3                              ; 09B4
        jz     L_09BE                                ; 09B6
        mov    a, 0x5D                               ; 09B8
        setb   0xE2                                  ; 09BA
        mov    0x5D, a                               ; 09BC
L_09BE::
        mov    r0, 0x3B                              ; 09BE
        mov    r1, 0x3C                              ; 09C0
        mov    sfr_DPH, 0x3E                         ; 09C2
        mov    sfr_DPL, 0x3D                         ; 09C5
        ret                                          ; 09C8

sum16_store::
        mov    a, r2                                 ; 09C9
        movx   @dptr, a                              ; 09CA
        inc    dptr                                  ; 09CB
        mov    a, r3                                 ; 09CC
        movx   @dptr, a                              ; 09CD
        ret                                          ; 09CE

sum16_compare::
        movx   a, @dptr                              ; 09CF
        cjne   a, 0x02, L_09DA                       ; 09D0
        inc    dptr                                  ; 09D3
        movx   a, @dptr                              ; 09D4
        cjne   a, 0x03, L_09DA                       ; 09D5
        clr    a                                     ; 09D8
        ret                                          ; 09D9
L_09DA::
        mov    a, #0xFF                              ; 09DA
        ret                                          ; 09DC

; 16-bit additive sum of R1:R0 bytes at DPTR -> R3:R2
sum16_xdata::
        inc    r1                                    ; 09DD
        mov    r2, #0x00                             ; 09DE
        mov    r3, #0x00                             ; 09E0
L_09E2::
        movx   a, @dptr                              ; 09E2
        add    a, r2                                 ; 09E3
        mov    r2, a                                 ; 09E4
        clr    a                                     ; 09E5
        addc   a, r3                                 ; 09E6
        mov    r3, a                                 ; 09E7
        djnz   r0, L_09ED                            ; 09E8
        djnz   r1, L_09ED                            ; 09EA
        ret                                          ; 09EC
L_09ED::
        inc    dptr                                  ; 09ED
        sjmp   L_09E2                                ; 09EE

; byte-wise 2-of-3 vote over the copies, repairs the odd one, counts events
cal_majority_repair::
        mov    r4, #0xC8                             ; 09F0
        mov    r5, #0x01                             ; 09F2
        inc    r5                                    ; 09F4
        mov    dptr, #x_cal_data_copy1               ; 09F5
L_09F8::
        push   sfr_DPL                               ; 09F8
        push   sfr_DPH                               ; 09FA
        movx   a, @dptr                              ; 09FC
        mov    r0, a                                 ; 09FD
        lcall  cal_addr_copy2                        ; 09FE
        movx   a, @dptr                              ; 0A01
        xrl    a, r0                                 ; 0A02
        jnz    L_0A13                                ; 0A03
        lcall  cal_addr_copy3                        ; 0A05
        movx   a, @dptr                              ; 0A08
        xrl    a, r0                                 ; 0A09
        jz     L_0A37                                ; 0A0A
        mov    a, r0                                 ; 0A0C
        movx   @dptr, a                              ; 0A0D
        lcall  cnt_repair_copy3                      ; 0A0E
        sjmp   L_0A37                                ; 0A11
L_0A13::
        lcall  cal_addr_copy3                        ; 0A13
        movx   a, @dptr                              ; 0A16
        xrl    a, r0                                 ; 0A17
        jnz    L_0A24                                ; 0A18
        lcall  cal_addr_copy2                        ; 0A1A
        mov    a, r0                                 ; 0A1D
        movx   @dptr, a                              ; 0A1E
        lcall  cnt_repair_copy2                      ; 0A1F
        sjmp   L_0A37                                ; 0A22
L_0A24::
        movx   a, @dptr                              ; 0A24
        mov    r0, a                                 ; 0A25
        lcall  cal_addr_copy2                        ; 0A26
        movx   a, @dptr                              ; 0A29
        xrl    a, r0                                 ; 0A2A
        jnz    L_0A37                                ; 0A2B
        lcall  ret_peek_dptr                         ; 0A2D
        mov    a, r0                                 ; 0A30
        movx   @dptr, a                              ; 0A31
        lcall  cnt_repair_copy1                      ; 0A32
        sjmp   L_0A37                                ; 0A35
L_0A37::
        pop    sfr_DPH                               ; 0A37
        pop    sfr_DPL                               ; 0A39
        inc    dptr                                  ; 0A3B
        djnz   r4, L_09F8                            ; 0A3C
        djnz   r5, L_09F8                            ; 0A3E
        ret                                          ; 0A40

cal_copy1_to_2::
        mov    dptr, #x_cal_data_copy1               ; 0A41
        mov    r2, #0xCF                             ; 0A44
        mov    r3, #0x03                             ; 0A46
        mov    r0, #0xCA                             ; 0A48
        mov    r1, #0x01                             ; 0A4A
        lcall  xdata_copy                            ; 0A4C
        mov    sfr_B, #0x00                          ; 0A4F
        ljmp   cal_checksum_copy2                    ; 0A52

cal_copy1_to_3::
        mov    dptr, #x_cal_data_copy1               ; 0A55
        mov    r2, #0x9E                             ; 0A58
        mov    r3, #0x05                             ; 0A5A
        mov    r0, #0xCA                             ; 0A5C
        mov    r1, #0x01                             ; 0A5E
        lcall  xdata_copy                            ; 0A60
        mov    sfr_B, #0x00                          ; 0A63
        ljmp   cal_checksum_copy3                    ; 0A66

cal_copy2_to_1::
        mov    dptr, #x_cal_data_copy2               ; 0A69
        mov    r2, #0x00                             ; 0A6C
        mov    r3, #0x02                             ; 0A6E
        mov    r0, #0xCA                             ; 0A70
        mov    r1, #0x01                             ; 0A72
        lcall  xdata_copy                            ; 0A74
        mov    sfr_B, #0x00                          ; 0A77
        ljmp   cal_checksum_copy1                    ; 0A7A

cal_copy3_to_2::
        mov    dptr, #x_cal_data_copy3               ; 0A7D
        mov    r2, #0xCF                             ; 0A80
        mov    r3, #0x03                             ; 0A82
        mov    r0, #0xCA                             ; 0A84
        mov    r1, #0x01                             ; 0A86
        lcall  xdata_copy                            ; 0A88
        mov    sfr_B, #0x00                          ; 0A8B
        ljmp   cal_checksum_copy2                    ; 0A8E

xdata_copy::
        clr    c                                     ; 0A91
        ljmp   xdata_block_xfer                      ; 0A92

cnt_sum_err_copy1::
        mov    dptr, #x_diag_err_total               ; 0A95
        movx   a, @dptr                              ; 0A98
        inc    a                                     ; 0A99
        movx   @dptr, a                              ; 0A9A
        ret                                          ; 0A9B

cnt_sum_err_copy2::
        mov    dptr, #x_cal_sum_err_copy2            ; 0A9C
        movx   a, @dptr                              ; 0A9F
        inc    a                                     ; 0AA0
        movx   @dptr, a                              ; 0AA1
        ret                                          ; 0AA2

cnt_sum_err_copy3::
        mov    dptr, #x_cal_sum_err_copy3            ; 0AA3
        movx   a, @dptr                              ; 0AA6
        inc    a                                     ; 0AA7
        movx   @dptr, a                              ; 0AA8
        ret                                          ; 0AA9

cnt_repair_copy1::
        mov    dptr, #x_cal_repair_copy1             ; 0AAA
        movx   a, @dptr                              ; 0AAD
        inc    a                                     ; 0AAE
        movx   @dptr, a                              ; 0AAF
        ret                                          ; 0AB0

cnt_repair_copy2::
        mov    dptr, #x_cal_fallback_flags           ; 0AB1
        movx   a, @dptr                              ; 0AB4
        inc    a                                     ; 0AB5
        movx   @dptr, a                              ; 0AB6
        ret                                          ; 0AB7

cnt_repair_copy3::
        mov    dptr, #x_cal_fail_code                ; 0AB8
        movx   a, @dptr                              ; 0ABB
        inc    a                                     ; 0ABC
        movx   @dptr, a                              ; 0ABD
        ret                                          ; 0ABE

; JCV (cal mode): clear 22 bytes from 0x076C
diag_clear_counters::
        push   sfr_DPL                               ; 0ABF
        push   sfr_DPH                               ; 0AC1
        push   sfr_ACC                               ; 0AC3
        push   sfr_B                                 ; 0AC5
        mov    dptr, #x_diag_err_total               ; 0AC7
        clr    a                                     ; 0ACA
        mov    sfr_B, #0x16                          ; 0ACB
L_0ACE::
        movx   @dptr, a                              ; 0ACE
        inc    dptr                                  ; 0ACF
        djnz   sfr_B, L_0ACE                         ; 0AD0
        pop    sfr_B                                 ; 0AD3
        pop    sfr_ACC                               ; 0AD5
        pop    sfr_DPH                               ; 0AD7
        pop    sfr_DPL                               ; 0AD9
        ret                                          ; 0ADB

cal_set_slope_limits::
        mov    a, meter_state                        ; 0ADC
        clr    0xE7                                  ; 0ADE
        cjne   a, #0x65, L_0AE5                      ; 0AE0
        sjmp   L_0AF4                                ; 0AE3
L_0AE5::
        cjne   a, #0x55, L_0AEA                      ; 0AE5
        sjmp   L_0AF4                                ; 0AE8
L_0AEA::
        cjne   a, #0x29, L_0AEF                      ; 0AEA
        sjmp   L_0AF4                                ; 0AED
L_0AEF::
        mov    dptr, #T_6F71                         ; 0AEF
        sjmp   L_0AF7                                ; 0AF2
L_0AF4::
        mov    dptr, #T_6FA9                         ; 0AF4
L_0AF7::
        lcall  fp_ld_code_r0                         ; 0AF7
        mov    dptr, #0x0792                         ; 0AFA
        lcall  fp_st_r0_xdata                        ; 0AFD
        mov    a, @r0                                ; 0B00
        cpl    0xE7                                  ; 0B01
        mov    @r0, a                                ; 0B03
        mov    dptr, #0x0796                         ; 0B04
        lcall  fp_st_r0_xdata                        ; 0B07
        ret                                          ; 0B0A

; flag byte of the recipe table entry (bit0 zero-cold,1 gain-cold,2 zero-Tref,3 gain-Tref,4 zero-hot,5 gain-hot,7 two sets)
cal_point_flags::
        mov    a, meter_state                        ; 0B0B
        anl    a, #0x0F                              ; 0B0D
        jnz    L_0B19                                ; 0B0F
        jnb    peak_mode_b1, L_0B19                  ; 0B11
        jnb    peak_mode_b0, L_0B19                  ; 0B14
        clr    a                                     ; 0B17
        ret                                          ; 0B18
L_0B19::
        lcall  cal_recipe_ptr                        ; 0B19
        mov    a, #0x03                              ; 0B1C
        movc   a, @a+dptr                            ; 0B1E
        mov    sfr_B, a                              ; 0B1F
        mov    a, #0x02                              ; 0B21
        movc   a, @a+dptr                            ; 0B23
        ret                                          ; 0B24

; IRAM 39h..5Fh -> XDATA 0x07A2
cal_ctx_save::
        mov    0x3B, r0                              ; 0B25
        mov    r0, #0x39                             ; 0B27
        mov    dptr, #x_cal_ctx_save_area            ; 0B29
        mov    r2, #0x27                             ; 0B2C
        lcall  iram_to_xdata                         ; 0B2E
        mov    r0, 0x3B                              ; 0B31
        ret                                          ; 0B33

cal_ctx_restore::
        mov    r0, #0x39                             ; 0B34
        mov    dptr, #x_cal_ctx_save_area            ; 0B36
        mov    r2, #0x27                             ; 0B39
        ljmp   xdata_to_iram                         ; 0B3B

; zero vs gain point, level window, polarity, allowed by flags -> codes 1..9
cal_classify_input::
        lcall  cal_nominal_value                     ; 0B3E
        mov    a, meter_state                        ; 0B41
        anl    a, #0x0F                              ; 0B43
        cjne   a, #0x04, L_0B4A                      ; 0B45
        sjmp   L_0B4D                                ; 0B48
L_0B4A::
        cjne   a, #0x05, L_0B51                      ; 0B4A
L_0B4D::
        dec    0x4B                                  ; 0B4D
        sjmp   L_0B6D                                ; 0B4F
L_0B51::
        cjne   a, #0x0B, L_0B5E                      ; 0B51
        mov    r0, #0x4B                             ; 0B54
        mov    dptr, #T_692F                         ; 0B56
        lcall  fp_ld_code_r0                         ; 0B59
        sjmp   L_0B6D                                ; 0B5C
L_0B5E::
        mov    a, meter_state                        ; 0B5E
        anl    a, #0x7F                              ; 0B60
        cjne   a, #0x42, L_0B6D                      ; 0B62
        mov    r0, #0x4B                             ; 0B65
        mov    dptr, #T_6FB1                         ; 0B67
        lcall  fp_ld_code_r0                         ; 0B6A
L_0B6D::
        mov    r0, #0x4B                             ; 0B6D
        mov    dptr, #x_cal_ctx_save_area            ; 0B6F
        lcall  fp_st_r0_xdata                        ; 0B72
        mov    r0, #0x5B                             ; 0B75
        mov    r1, #0x5F                             ; 0B77
        mov    a, meter_state                        ; 0B79
        anl    a, #0x0F                              ; 0B7B
        cjne   a, #0x01, L_0B82                      ; 0B7D
        sjmp   L_0B85                                ; 0B80
L_0B82::
        cjne   a, #0x0A, L_0B93                      ; 0B82
L_0B85::
        mov    dptr, #T_6F85                         ; 0B85
        lcall  fp_ld_code_r0                         ; 0B88
        mov    dptr, #T_6F91                         ; 0B8B
        lcall  fp_ld_code_r1                         ; 0B8E
        sjmp   L_0BB4                                ; 0B91
L_0B93::
        mov    a, meter_state                        ; 0B93
        anl    a, #0x7F                              ; 0B95
        cjne   a, #0x65, L_0BA8                      ; 0B97
        mov    dptr, #T_6F75                         ; 0B9A
        lcall  fp_ld_code_r0                         ; 0B9D
        mov    dptr, #T_6FA1                         ; 0BA0
        lcall  fp_ld_code_r1                         ; 0BA3
        sjmp   L_0BB4                                ; 0BA6
L_0BA8::
        mov    dptr, #T_6F81                         ; 0BA8
        lcall  fp_ld_code_r0                         ; 0BAB
        mov    dptr, #T_6F95                         ; 0BAE
        lcall  fp_ld_code_r1                         ; 0BB1
L_0BB4::
        mov    a, meter_state                        ; 0BB4
        anl    a, #0x0F                              ; 0BB6
        jnz    L_0BCE                                ; 0BB8
        lcall  cal_nominal_from_range                ; 0BBA
        mov    a, 0x47                               ; 0BBD
        cpl    0xE7                                  ; 0BBF
        mov    0x47, a                               ; 0BC1
        mov    r1, #0x50                             ; 0BC3
        lcall  fp_cmp                                ; 0BC5
        jc     L_0BCE                                ; 0BC8
        mov    a, #0x01                              ; 0BCA
        sjmp   L_0C12                                ; 0BCC
L_0BCE::
        mov    r1, #0x50                             ; 0BCE
        mov    r0, #0x43                             ; 0BD0
        lcall  fp_copy_r1_to_r0                      ; 0BD2
        anl    0x43, #0x7F                           ; 0BD5
        mov    r0, #0x47                             ; 0BD8
        mov    dptr, #T_6F61                         ; 0BDA
        lcall  fp_ld_code_r0                         ; 0BDD
        mov    r1, #0x4B                             ; 0BE0
        lcall  fp_mul                                ; 0BE2
        mov    r1, #0x43                             ; 0BE5
        lcall  fp_cmp                                ; 0BE7
        jc     L_0BF0                                ; 0BEA
        setb   0x7E                                  ; 0BEC
        sjmp   L_0C5E                                ; 0BEE
L_0BF0::
        mov    r0, #0x5B                             ; 0BF0
        mov    r1, #0x4B                             ; 0BF2
        lcall  fp_mul                                ; 0BF4
        mov    r1, #0x43                             ; 0BF7
        lcall  fp_cmp                                ; 0BF9
        jc     L_0C02                                ; 0BFC
        mov    a, #0x02                              ; 0BFE
        sjmp   L_0C12                                ; 0C00
L_0C02::
        mov    r0, #0x5F                             ; 0C02
        mov    r1, #0x4B                             ; 0C04
        lcall  fp_mul                                ; 0C06
        mov    r1, #0x43                             ; 0C09
        lcall  fp_cmp                                ; 0C0B
        jnc    L_0C1A                                ; 0C0E
        mov    a, #0x03                              ; 0C10
L_0C12::
        jnb    0x53, L_0C17                          ; 0C12
        setb   0x64                                  ; 0C15
L_0C17::
        setb   0x53                                  ; 0C17
        ret                                          ; 0C19
L_0C1A::
        mov    a, meter_state                        ; 0C1A
        anl    a, #0x0F                              ; 0C1C
        cjne   a, #0x05, L_0C23                      ; 0C1E
        sjmp   L_0C3F                                ; 0C21
L_0C23::
        cjne   a, #0x04, L_0C28                      ; 0C23
        sjmp   L_0C3F                                ; 0C26
L_0C28::
        cjne   a, #0x0B, L_0C2D                      ; 0C28
        sjmp   L_0C3F                                ; 0C2B
L_0C2D::
        cjne   a, #0x06, L_0C32                      ; 0C2D
        sjmp   L_0C3F                                ; 0C30
L_0C32::
        cjne   a, #0x0C, L_0C37                      ; 0C32
        sjmp   L_0C3F                                ; 0C35
L_0C37::
        cjne   a, #0x02, L_0C3C                      ; 0C37
        sjmp   L_0C3F                                ; 0C3A
L_0C3C::
        cjne   a, #0x07, L_0C50                      ; 0C3C
L_0C3F::
        mov    a, 0x50                               ; 0C3F
        jb     0xE7, L_0C48                          ; 0C41
        mov    a, #0x04                              ; 0C44
        sjmp   L_0C12                                ; 0C46
L_0C48::
        mov    a, 0x4B                               ; 0C48
        cpl    0xE7                                  ; 0C4A
        mov    0x4B, a                               ; 0C4C
        sjmp   L_0C5E                                ; 0C4E
L_0C50::
        cjne   a, #0x01, L_0C55                      ; 0C50
        sjmp   L_0C5E                                ; 0C53
L_0C55::
        mov    a, 0x50                               ; 0C55
        jnb    0xE7, L_0C5E                          ; 0C57
        mov    a, #0x05                              ; 0C5A
        sjmp   L_0C12                                ; 0C5C
L_0C5E::
        mov    a, meter_state                        ; 0C5E
        anl    a, #0x0F                              ; 0C60
        jnz    L_0C69                                ; 0C62
        jnb    peak_mode_b0, L_0C69                  ; 0C64
        sjmp   L_0C74                                ; 0C67
L_0C69::
        djnz   sfr_ACC, L_0C7A                       ; 0C69
        jb     0x7E, L_0C7A                          ; 0C6C
        mov    a, 0x50                               ; 0C6F
        jnb    0xE7, L_0C7A                          ; 0C71
L_0C74::
        setb   0x7F                                  ; 0C74
        mov    a, fnsel_new_function                 ; 0C76
        mov    0x39, a                               ; 0C78
L_0C7A::
        mov    a, 0x39                               ; 0C7A
        jnb    0x7E, L_0C90                          ; 0C7C
        jb     cal_hot, L_0C89                       ; 0C7F
        jb     0xE0, L_0CA3                          ; 0C82
        mov    a, #0x06                              ; 0C85
        sjmp   L_0C12                                ; 0C87
L_0C89::
        jb     0xE4, L_0CA3                          ; 0C89
        mov    a, #0x07                              ; 0C8C
        sjmp   L_0C12                                ; 0C8E
L_0C90::
        jb     cal_hot, L_0C9B                       ; 0C90
        jb     0xE1, L_0CA3                          ; 0C93
        mov    a, #0x08                              ; 0C96
        ljmp   L_0C12                                ; 0C98
L_0C9B::
        jb     0xE5, L_0CA3                          ; 0C9B
        mov    a, #0x09                              ; 0C9E
        ljmp   L_0C12                                ; 0CA0
L_0CA3::
        clr    0x53                                  ; 0CA3
        ret                                          ; 0CA5

; nominal full-scale value of the range (from range limits and scale)
cal_nominal_value::
        lcall  range_param_lookup                    ; 0CA6
        mov    r0, #0x46                             ; 0CA9
        lcall  i24_to_fp                             ; 0CAB
        lcall  range_scale_exp                       ; 0CAE
        mov    r1, #0x4B                             ; 0CB1
        lcall  fp_ld_pow10_r1                        ; 0CB3
        mov    r0, #0x4B                             ; 0CB6
        mov    r1, #0x47                             ; 0CB8
        lcall  fp_mul                                ; 0CBA
        ret                                          ; 0CBD

cal_nominal_from_range::
        mov    dptr, #T_7040                         ; 0CBE
        mov    r0, #0x46                             ; 0CC1
        lcall  i24_ld_code_r0                        ; 0CC3
        lcall  i24_to_fp                             ; 0CC6
        lcall  range_scale_exp                       ; 0CC9
        mov    r1, #0x55                             ; 0CCC
        lcall  fp_ld_pow10_r1                        ; 0CCE
        mov    r0, #0x47                             ; 0CD1
        mov    r1, #0x55                             ; 0CD3
        ljmp   fp_mul                                ; 0CD5

; per-function window table 0x0D0B
cal_stability_window::
        mov    r0, #0x47                             ; 0CD8
        mov    a, meter_state                        ; 0CDA
        clr    0xE7                                  ; 0CDC
        cjne   a, #0x65, L_0CE9                      ; 0CDE
        mov    dptr, #T_6FA9                         ; 0CE1
        lcall  fp_ld_code_r0                         ; 0CE4
        sjmp   L_0CFE                                ; 0CE7
L_0CE9::
        mov    a, meter_state                        ; 0CE9
        anl    a, #0x0F                              ; 0CEB
        add    a, sfr_ACC                            ; 0CED
        mov    r2, a                                 ; 0CEF
        mov    dptr, #T_0D0B                         ; 0CF0
        movc   a, @a+dptr                            ; 0CF3
        xch    a, r2                                 ; 0CF4
        inc    dptr                                  ; 0CF5
        movc   a, @a+dptr                            ; 0CF6
        mov    sfr_DPL, a                            ; 0CF7
        mov    sfr_DPH, r2                           ; 0CF9
        lcall  fp_ld_code_r0                         ; 0CFB
L_0CFE::
        lcall  range_scale_exp                       ; 0CFE
        mov    r0, #0x47                             ; 0D01
        mov    r1, #0x5B                             ; 0D03
        lcall  fp_ld_pow10_r1                        ; 0D05
        ljmp   fp_mul                                ; 0D08
T_0D0B::
        .db 0x6F, 0x71, 0x6F, 0x5D, 0x6F, 0x71, 0x00, 0x00, 0x6F, 0x71, 0x6F, 0x71, 0x6F, 0x71, 0x6F, 0x71 ; 0D0B oqo]oq..oqoqoqoq
        .db 0x00, 0x00, 0x6F, 0x71, 0x6F, 0x71, 0x6F, 0x65                                   ; 0D1B ..oqoqoe

cal_gain_limit_check::
        mov    r0, #0x47                             ; 0D23
        mov    dptr, #T_6F99                         ; 0D25
        mov    a, meter_state                        ; 0D28
        anl    a, #0x7F                              ; 0D2A
        cjne   a, #0x65, L_0D32                      ; 0D2C
        mov    dptr, #T_70B9                         ; 0D2F
L_0D32::
        lcall  fp_ld_code_r0                         ; 0D32
        mov    r0, #0x4B                             ; 0D35
        mov    dptr, #T_6F7D                         ; 0D37
        mov    a, meter_state                        ; 0D3A
        anl    a, #0x7F                              ; 0D3C
        cjne   a, #0x65, L_0D44                      ; 0D3E
        mov    dptr, #T_6F79                         ; 0D41
L_0D44::
        lcall  fp_ld_code_r0                         ; 0D44

cal_slope_limit_check::
        mov    dptr, #T_6F89                         ; 0D47
        mov    r0, #0x5B                             ; 0D4A
        lcall  fp_ld_code_r0                         ; 0D4C
        mov    r1, #0x47                             ; 0D4F
        lcall  fp_mul                                ; 0D51
        mov    r0, #0x43                             ; 0D54
        mov    r1, #0x5B                             ; 0D56
        lcall  fp_cmp                                ; 0D58
        jnc    L_0D75                                ; 0D5B
        mov    dptr, #T_6F8D                         ; 0D5D
        mov    r0, #0x5B                             ; 0D60
        lcall  fp_ld_code_r0                         ; 0D62
        mov    r1, #0x4B                             ; 0D65
        lcall  fp_mul                                ; 0D67
        mov    r0, #0x43                             ; 0D6A
        mov    r1, #0x5B                             ; 0D6C
        lcall  fp_cmp                                ; 0D6E
        jc     L_0D75                                ; 0D71
        clr    c                                     ; 0D73
        ret                                          ; 0D74
L_0D75::
        setb   c                                     ; 0D75
        ret                                          ; 0D76

; internal temperature within 0x70C5..0x70C9
temp_in_range::
        mov    dptr, #T_70C5                         ; 0D77
        lcall  fp_ld_code_r1                         ; 0D7A
        lcall  fp_cmp                                ; 0D7D
        jc     L_0D8B                                ; 0D80
        mov    dptr, #T_70C9                         ; 0D82
        lcall  fp_ld_code_r1                         ; 0D85
        ljmp   fp_cmp                                ; 0D88
L_0D8B::
        clr    c                                     ; 0D8B
        ret                                          ; 0D8C

; zero point: needs 3 stable readings (max 29); cold: K0 (+K2=T), hot: K4 slope
cal_step_zero::
        jnb    0x6D, L_0DB1                          ; 0D8D
        mov    a, meter_state                        ; 0D90
        anl    a, #0x0F                              ; 0D92
        cjne   a, #0x01, L_0D99                      ; 0D94
        sjmp   L_0DAC                                ; 0D97
L_0D99::
        cjne   a, #0x04, L_0D9E                      ; 0D99
        sjmp   L_0DAC                                ; 0D9C
L_0D9E::
        cjne   a, #0x05, L_0DA3                      ; 0D9E
        sjmp   L_0DAC                                ; 0DA1
L_0DA3::
        cjne   a, #0x06, L_0DA8                      ; 0DA3
        sjmp   L_0DAC                                ; 0DA6
L_0DA8::
        add    a, #0xF5                              ; 0DA8
        jnc    L_0DB1                                ; 0DAA
L_0DAC::
        mov    a, #0x21                              ; 0DAC
        ljmp   cal_fail                              ; 0DAE
L_0DB1::
        mov    dptr, #x_internal_temp                ; 0DB1
        mov    r0, #0x43                             ; 0DB4
        lcall  fp_ld_xdata_r1                        ; 0DB6
        mov    r1, #0x47                             ; 0DB9
        lcall  temp_in_range                         ; 0DBB
        jc     L_0DC5                                ; 0DBE
        mov    a, #0x22                              ; 0DC0
        ljmp   cal_fail                              ; 0DC2
L_0DC5::
        clr    0x7F                                  ; 0DC5
        clr    0x7E                                  ; 0DC7
        lcall  cal_point_flags                       ; 0DC9
        mov    0x39, a                               ; 0DCC
        mov    fnsel_new_function, sfr_B             ; 0DCE
        lcall  cal_classify_input                    ; 0DD1
        jnb    0x64, L_0DDA                          ; 0DD4
        ljmp   cal_fail                              ; 0DD7
L_0DDA::
        jb     0x53, L_0E16                          ; 0DDA
        inc    0x1A                                  ; 0DDD
        mov    a, 0x1A                               ; 0DDF
        add    a, #0xFD                              ; 0DE1
        jnc    L_0E00                                ; 0DE3
        mov    dptr, #0x019F                         ; 0DE5
        lcall  cal_reading_stable                    ; 0DE8
        jnc    L_0DF5                                ; 0DEB
        mov    dptr, #0x01CD                         ; 0DED
        lcall  cal_reading_stable                    ; 0DF0
        jc     L_0E37                                ; 0DF3
L_0DF5::
        mov    a, 0x1A                               ; 0DF5
        add    a, #0xE2                              ; 0DF7
        jnc    L_0E00                                ; 0DF9
        mov    a, #0x12                              ; 0DFB
        ljmp   cal_fail                              ; 0DFD
L_0E00::
        mov    r0, #0x43                             ; 0E00
        mov    dptr, #0x019F                         ; 0E02
        lcall  fp_ld_xdata_r0                        ; 0E05
        mov    dptr, #0x01CD                         ; 0E08
        lcall  fp_st_r0_xdata                        ; 0E0B
        mov    r0, #0x50                             ; 0E0E
        mov    dptr, #0x019F                         ; 0E10
        lcall  fp_st_r0_xdata                        ; 0E13
L_0E16::
        setb   sbit_F0                               ; 0E16
        ljmp   autorange_count_step                  ; 0E18

cal_reading_stable::
        mov    r0, #0x50                             ; 0E1B
        mov    r1, #0x5B                             ; 0E1D
        lcall  fp_copy_r0_to_r1                      ; 0E1F
        mov    r0, #0x43                             ; 0E22
        lcall  fp_ld_xdata_r0                        ; 0E24
        lcall  fp_rsub                               ; 0E27
        anl    0x43, #0x7F                           ; 0E2A
        lcall  cal_stability_window                  ; 0E2D
        mov    r0, #0x43                             ; 0E30
        mov    r1, #0x47                             ; 0E32
        ljmp   fp_cmp                                ; 0E34
L_0E37::
        jb     0x7E, L_0E3D                          ; 0E37
        ljmp   cal_step_gain                         ; 0E3A
L_0E3D::
        jb     cal_hot, L_0E5A                       ; 0E3D
        mov    r0, #0x50                             ; 0E40
        mov    a, #0x00                              ; 0E42
        lcall  cal_adjust_slot                       ; 0E44
        mov    a, 0x39                               ; 0E47
        jnb    0xE2, L_0E59                          ; 0E49
        mov    r0, #0x47                             ; 0E4C
        mov    dptr, #x_internal_temp                ; 0E4E
        lcall  fp_ld_xdata_r0                        ; 0E51
        mov    a, #0x02                              ; 0E54
        lcall  cal_adjust_slot                       ; 0E56
L_0E59::
        ret                                          ; 0E59
L_0E5A::
        jnb    0x7F, L_0E6F                          ; 0E5A
        mov    r0, #0x5B                             ; 0E5D
        mov    dptr, #x_cal_work_set1                ; 0E5F
        lcall  fp_ld_xdata_r0                        ; 0E62
        mov    r0, #0x5F                             ; 0E65
        mov    dptr, #0x0187                         ; 0E67
        lcall  fp_ld_xdata_r0                        ; 0E6A
        sjmp   L_0E7F                                ; 0E6D
L_0E6F::
        mov    r0, #0x5B                             ; 0E6F
        mov    dptr, #x_cal_work_set0                ; 0E71
        lcall  fp_ld_xdata_r0                        ; 0E74
        mov    r0, #0x5F                             ; 0E77
        mov    dptr, #0x0167                         ; 0E79
        lcall  fp_ld_xdata_r0                        ; 0E7C
L_0E7F::
        mov    r0, #0x43                             ; 0E7F
        mov    dptr, #x_internal_temp                ; 0E81
        lcall  fp_ld_xdata_r0                        ; 0E84
        mov    r1, #0x5F                             ; 0E87
        lcall  fp_sub                                ; 0E89
        mov    r1, #0x4B                             ; 0E8C
        lcall  fp_copy_r0_to_r1                      ; 0E8E
        anl    0x43, #0x7F                           ; 0E91
        mov    r1, #0x47                             ; 0E94
        mov    dptr, #T_691F                         ; 0E96
        lcall  fp_ld_code_r1                         ; 0E99
        lcall  fp_cmp                                ; 0E9C
        jc     L_0EDD                                ; 0E9F
        mov    r1, #0x50                             ; 0EA1
        lcall  fp_copy_r1_to_r0                      ; 0EA3
        mov    r1, #0x5B                             ; 0EA6
        lcall  fp_sub                                ; 0EA8
        mov    r1, #0x4B                             ; 0EAB
        lcall  fp_div                                ; 0EAD
        mov    r1, #0x47                             ; 0EB0
        lcall  fp_copy_r0_to_r1                      ; 0EB2
        anl    0x47, #0x7F                           ; 0EB5
        mov    dptr, #T_6F71                         ; 0EB8
        mov    r1, #0x4B                             ; 0EBB
        lcall  fp_ld_code_r1                         ; 0EBD
        mov    r0, #0x5B                             ; 0EC0
        mov    dptr, #x_cal_ctx_save_area            ; 0EC2
        lcall  fp_ld_xdata_r0                        ; 0EC5
        lcall  fp_mul                                ; 0EC8
        mov    r1, #0x47                             ; 0ECB
        lcall  fp_cmp                                ; 0ECD
        jnc    L_0ED6                                ; 0ED0
        mov    a, #0x0B                              ; 0ED2
        sjmp   cal_fail                              ; 0ED4
L_0ED6::
        mov    r0, #0x43                             ; 0ED6
        mov    a, #0x04                              ; 0ED8
        ljmp   cal_adjust_slot                       ; 0EDA
L_0EDD::
        mov    a, #0x0C                              ; 0EDD

; A = fail code -> XDATA 0x0771, sets fail flag
cal_fail::
        mov    dptr, #x_cal_fail_code                ; 0EDF
        movx   @dptr, a                              ; 0EE2
        setb   0x64                                  ; 0EE3
        ret                                          ; 0EE5

; gain point: cold: K1 (+K3=T), hot: K5 slope
cal_step_gain::
        jnb    cal_hot, L_0EEB                       ; 0EE6
        sjmp   L_0F48                                ; 0EE9
L_0EEB::
        jnb    0x7F, L_0F05                          ; 0EEB
        mov    dptr, #x_cal_work_set1                ; 0EEE
        mov    r0, #0x43                             ; 0EF1
        lcall  fp_ld_xdata_r0                        ; 0EF3
        mov    a, meter_state                        ; 0EF6
        anl    a, #0x0F                              ; 0EF8
        djnz   sfr_ACC, L_0F0D                       ; 0EFA
        mov    a, 0x4B                               ; 0EFD
        cpl    0xE7                                  ; 0EFF
        mov    0x4B, a                               ; 0F01
        sjmp   L_0F0D                                ; 0F03
L_0F05::
        mov    dptr, #x_cal_work_set0                ; 0F05
        mov    r0, #0x43                             ; 0F08
        lcall  fp_ld_xdata_r0                        ; 0F0A
L_0F0D::
        mov    a, r0                                 ; 0F0D
        mov    r2, a                                 ; 0F0E
        mov    r0, #0x50                             ; 0F0F
        mov    r1, #0x5F                             ; 0F11
        lcall  fp_copy_r0_to_r1                      ; 0F13
        mov    a, r2                                 ; 0F16
        mov    r0, a                                 ; 0F17
        lcall  fp_rsub                               ; 0F18
        mov    r0, #0x4B                             ; 0F1B
        mov    r1, #0x43                             ; 0F1D
        lcall  fp_div                                ; 0F1F
        lcall  fp_copy_r0_to_r1                      ; 0F22
        lcall  cal_gain_limit_check                  ; 0F25
        jnc    L_0F2E                                ; 0F28
        mov    a, #0x0E                              ; 0F2A
        sjmp   cal_fail                              ; 0F2C
L_0F2E::
        mov    r0, #0x43                             ; 0F2E
        mov    a, #0x01                              ; 0F30
        lcall  cal_adjust_slot                       ; 0F32
        mov    a, 0x39                               ; 0F35
        jnb    0xE3, L_0F47                          ; 0F37
        mov    r0, #0x47                             ; 0F3A
        mov    dptr, #x_internal_temp                ; 0F3C
        lcall  fp_ld_xdata_r0                        ; 0F3F
        mov    a, #0x03                              ; 0F42
        lcall  cal_adjust_slot                       ; 0F44
L_0F47::
        ret                                          ; 0F47
L_0F48::
        jnb    0x7F, L_0F72                          ; 0F48
        mov    a, meter_state                        ; 0F4B
        anl    a, #0x0F                              ; 0F4D
        djnz   sfr_ACC, L_0F58                       ; 0F4F
        mov    a, 0x4B                               ; 0F52
        cpl    0xE7                                  ; 0F54
        mov    0x4B, a                               ; 0F56
L_0F58::
        mov    r1, #0x5B                             ; 0F58
        mov    dptr, #x_cal_zero_eff1                ; 0F5A
        lcall  fp_ld_xdata_r1                        ; 0F5D
        mov    r1, #0x5F                             ; 0F60
        mov    dptr, #0x0183                         ; 0F62
        lcall  fp_ld_xdata_r1                        ; 0F65
        mov    r1, #0x55                             ; 0F68
        mov    dptr, #0x018B                         ; 0F6A
        lcall  fp_ld_xdata_r1                        ; 0F6D
        sjmp   L_0F8A                                ; 0F70
L_0F72::
        mov    r1, #0x5B                             ; 0F72
        mov    dptr, #x_cal_zero_eff                 ; 0F74
        lcall  fp_ld_xdata_r1                        ; 0F77
        mov    r1, #0x5F                             ; 0F7A
        mov    dptr, #0x0163                         ; 0F7C
        lcall  fp_ld_xdata_r1                        ; 0F7F
        mov    r1, #0x55                             ; 0F82
        mov    dptr, #0x016B                         ; 0F84
        lcall  fp_ld_xdata_r1                        ; 0F87
L_0F8A::
        mov    r0, #0x43                             ; 0F8A
        mov    dptr, #x_internal_temp                ; 0F8C
        lcall  fp_ld_xdata_r0                        ; 0F8F
        mov    r1, #0x55                             ; 0F92
        lcall  fp_sub                                ; 0F94
        lcall  fp_copy_r0_to_r1                      ; 0F97
        anl    0x43, #0x7F                           ; 0F9A
        mov    r1, #0x47                             ; 0F9D
        mov    dptr, #T_691F                         ; 0F9F
        lcall  fp_ld_code_r1                         ; 0FA2
        lcall  fp_cmp                                ; 0FA5
        jnc    L_0FAD                                ; 0FA8
        ljmp   L_0EDD                                ; 0FAA
L_0FAD::
        mov    r1, #0x43                             ; 0FAD
        mov    r0, #0x50                             ; 0FAF
        lcall  fp_copy_r0_to_r1                      ; 0FB1
        mov    r0, #0x5B                             ; 0FB4
        lcall  fp_rsub                               ; 0FB6
        mov    r0, #0x4B                             ; 0FB9
        mov    r1, #0x5B                             ; 0FBB
        lcall  fp_div                                ; 0FBD
        mov    r1, #0x43                             ; 0FC0
        lcall  fp_copy_r0_to_r1                      ; 0FC2
        lcall  cal_gain_limit_check                  ; 0FC5
        jnc    L_0FCF                                ; 0FC8
        mov    a, #0x10                              ; 0FCA
        ljmp   cal_fail                              ; 0FCC
L_0FCF::
        mov    r0, #0x43                             ; 0FCF
        mov    r1, #0x5F                             ; 0FD1
        lcall  fp_sub                                ; 0FD3
        mov    r1, #0x55                             ; 0FD6
        lcall  fp_div                                ; 0FD8
        mov    r0, #0x43                             ; 0FDB
        mov    r1, #0x5F                             ; 0FDD
        lcall  fp_copy_r0_to_r1                      ; 0FDF
        anl    0x43, #0x7F                           ; 0FE2
        mov    r0, #0x47                             ; 0FE5
        lcall  cal_set_slope_limits                  ; 0FE7
        mov    dptr, #0x0792                         ; 0FEA
        lcall  fp_ld_xdata_r0                        ; 0FED
        mov    r0, #0x4B                             ; 0FF0
        mov    dptr, #0x0796                         ; 0FF2
        lcall  fp_ld_xdata_r0                        ; 0FF5
        lcall  cal_slope_limit_check                 ; 0FF8
        jnc    L_1002                                ; 0FFB
        mov    a, #0x11                              ; 0FFD
        ljmp   cal_fail                              ; 0FFF
L_1002::
        mov    r0, #0x5F                             ; 1002
        mov    a, #0x05                              ; 1004
        ljmp   cal_adjust_slot                       ; 1006

; 1965 B: measurement sequencing, timers T0/T1, ADC cycles
task_measure::
        lcall  meas_ctx_ptr                          ; 1009
        lcall  xdata_to_iram                         ; 100C
        jnb    0x65, L_1015                          ; 100F
        lcall  speed_force_fast                      ; 1012
L_1015::
        mov    r0, #0x33                             ; 1015
        lcall  i24_inc_r0                            ; 1017
        jnb    0x7A, L_1022                          ; 101A
        djnz   0x1C, L_1022                          ; 101D
        clr    0x7A                                  ; 1020
L_1022::
        jnb    0x70, L_102C                          ; 1022
        jb     0x3D, meas_exit                       ; 1025
        setb   0x60                                  ; 1028
        sjmp   L_1055                                ; 102A
L_102C::
        jb     0x78, L_1032                          ; 102C
        jnb    0x79, L_1039                          ; 102F
L_1032::
        jb     0x3D, meas_exit                       ; 1032
        setb   0x61                                  ; 1035
        sjmp   L_1055                                ; 1037
L_1039::
        jb     0x3D, meas_exit                       ; 1039
        jnb    adc_alt_mode, L_1045                  ; 103C
        djnz   0x19, L_1045                          ; 103F
        lcall  adc_start_cycle                       ; 1042
L_1045::
        jnb    0x73, L_1055                          ; 1045
        djnz   adc_timeout_lo, L_1055                ; 1048
        djnz   adc_timeout_hi, L_1055                ; 104B
        mov    a, #0x0B                              ; 104E
        lcall  diag_count_event                      ; 1050
        sjmp   meas_restart                          ; 1053
L_1055::
        clr    0x92                                  ; 1055
        setb   0x92                                  ; 1057
        jnb    0x62, L_105F                          ; 1059
        ljmp   meas_phase_process                    ; 105C
L_105F::
        jnb    0x60, L_1065                          ; 105F
        ljmp   meas_phase_switch                     ; 1062
L_1065::
        jnb    0x61, L_106B                          ; 1065
        ljmp   meas_phase_acquire                    ; 1068
L_106B::
        mov    a, #0x0C                              ; 106B
        lcall  diag_count_event                      ; 106D
        sjmp   meas_restart                          ; 1070

; save context back to XDATA and return
meas_exit::
        lcall  meas_ctx_ptr                          ; 1072
        lcall  iram_to_xdata                         ; 1075
        jnb    0x65, L_107E                          ; 1078
        lcall  speed_restore                         ; 107B
L_107E::
        ret                                          ; 107E

; DPTR=0x00BE, R0=0x2A, R2=14: measurement context descriptor
meas_ctx_ptr::
        mov    dptr, #x_meas_ctx_save                ; 107F
        mov    r0, #0x2A                             ; 1082
        mov    r2, #0x0E                             ; 1084
        ret                                          ; 1086

; power-up init of measurement engine (EA off, flags, calls 10D1/5BCB)
meas_init::
        clr    sbit_EA                               ; 1087
        lcall  mains_load_setting                    ; 1089
        orl    0x2D, #0xC0                           ; 108C
        anl    0x2D, #0xE7                           ; 108F
        setb   0x29                                  ; 1092
        setb   0x50                                  ; 1094
        clr    0x51                                  ; 1096
        lcall  internal_temp_init                    ; 1098
        lcall  filter_init                           ; 109B
        sjmp   meas_restart                          ; 109E

; called from keyboard / task_5468 after a function or range change
meas_restart_from_ui::
        lcall  meas_ctx_ptr                          ; 10A0
        lcall  xdata_swap_iram                       ; 10A3

; restart the measurement sequence (clears 23h.0, sets 22h.3)
meas_restart::
        clr    0x18                                  ; 10A6
        setb   0x13                                  ; 10A8
        sjmp   L_10B2                                ; 10AA

; same, called from 3CC3
meas_restart_b::
        lcall  meas_ctx_ptr                          ; 10AC
        lcall  xdata_swap_iram                       ; 10AF
L_10B2::
        clr    0x65                                  ; 10B2
        setb   0x2C                                  ; 10B4
        mov    a, #0x7F                              ; 10B6
        mov    dptr, #x_prev_count                   ; 10B8
        movx   @dptr, a                              ; 10BB
        setb   0x67                                  ; 10BC
        setb   0x59                                  ; 10BE
        lcall  adc_start_cycle                       ; 10C0
        mov    c, 0x18                               ; 10C3
        cpl    c                                     ; 10C5
        mov    sbit_F0, c                            ; 10C6
        lcall  autorange_reset                       ; 10C8
        lcall  meas_ctx_ptr                          ; 10CB
        ljmp   xdata_swap_iram                       ; 10CE

internal_temp_init::
        mov    dptr, #x_internal_temp                ; 10D1
        clr    a                                     ; 10D4
        movx   @dptr, a                              ; 10D5
        inc    dptr                                  ; 10D6
        mov    a, #0x80                              ; 10D7
        movx   @dptr, a                              ; 10D9
        ret                                          ; 10DA

; per-function jump table 0x10E9
meas_set_function_flags::
        setb   0x13                                  ; 10DB
        anl    meter_state, #0x8F                    ; 10DD
        mov    a, meter_state                        ; 10E0
        anl    a, #0x0F                              ; 10E2
        rl     a                                     ; 10E4
        mov    dptr, #L_10E9                         ; 10E5
        jmp    @a+dptr                               ; 10E8
L_10E9::
        sjmp   L_1105                                ; 10E9
L_10EB::
        sjmp   L_1105                                ; 10EB
L_10ED::
        sjmp   L_1105                                ; 10ED
L_10EF::
        sjmp   L_1105                                ; 10EF
L_10F1::
        sjmp   L_1105                                ; 10F1
L_10F3::
        sjmp   L_1105                                ; 10F3
L_10F5::
        sjmp   L_1108                                ; 10F5
L_10F7::
        sjmp   L_1108                                ; 10F7
L_10F9::
        sjmp   L_110C                                ; 10F9
L_10FB::
        sjmp   L_110F                                ; 10FB
L_10FD::
        sjmp   L_1108                                ; 10FD
L_10FF::
        sjmp   L_1112                                ; 10FF
L_1101::
        sjmp   L_1112                                ; 1101
L_1103::
        sjmp   L_1112                                ; 1103
L_1105::
        setb   0x05                                  ; 1105
L_1107::
        ret                                          ; 1107
L_1108::
        orl    meter_state, #0x60                    ; 1108
        ret                                          ; 110B
L_110C::
        setb   0x04                                  ; 110C
        ret                                          ; 110E
L_110F::
        setb   0x06                                  ; 110F
        ret                                          ; 1111
L_1112::
        ret                                          ; 1112

; per-function 24-bit offset (current: XDATA 0x011D/0x0120)
meas_offset_select::
        mov    r0, #0x42                             ; 1113
        jnb    0x1C, L_111B                          ; 1115
        ljmp   i24_clr_r0                            ; 1118
L_111B::
        mov    a, meter_state                        ; 111B
        anl    a, #0x0F                              ; 111D
        cjne   a, #0x06, L_1133                      ; 111F
        mov    a, meter_state                        ; 1122
        anl    a, #0x10                              ; 1124
        jz     L_112D                                ; 1126
L_1128::
        mov    dptr, #0x011D                         ; 1128
        sjmp   L_1130                                ; 112B
L_112D::
        mov    dptr, #0x0120                         ; 112D
L_1130::
        ljmp   i24_ld_xdata_r0                       ; 1130
L_1133::
        cjne   a, #0x0B, L_1138                      ; 1133
        sjmp   L_112D                                ; 1136
L_1138::
        cjne   a, #0x0C, L_113D                      ; 1138
        sjmp   L_112D                                ; 113B
L_113D::
        mov    a, meter_state                        ; 113D
        anl    a, #0x70                              ; 113F
        jz     L_1128                                ; 1141
        sjmp   L_112D                                ; 1143

; converts raw count to value using range constants (0x7040..) and float math
meas_scale_result::
        anl    0x2B, #0x0F                           ; 1145
        clr    0x64                                  ; 1148
        mov    r0, #0x10                             ; 114A
        mov    r1, #0x42                             ; 114C
        jb     0x29, L_116B                          ; 114E
        jb     0x6B, L_115A                          ; 1151
        jnb    0x6E, L_116E                          ; 1154
        jb     0x6C, L_1165                          ; 1157
L_115A::
        mov    dptr, #T_7040                         ; 115A
        lcall  i24_ld_code_r1                        ; 115D
        lcall  i24_sub                               ; 1160
        sjmp   L_116B                                ; 1163
L_1165::
        mov    dptr, #adc_count_time_norm            ; 1165
        lcall  adc_count_minus_zero                  ; 1168
L_116B::
        ljmp   L_1287                                ; 116B
L_116E::
        mov    a, meter_state                        ; 116E
        anl    a, #0x0F                              ; 1170
        jb     0x03, L_117A                          ; 1172
        jnz    L_117E                                ; 1175
L_1177::
        ljmp   L_11F7                                ; 1177
L_117A::
        add    a, #0xF5                              ; 117A
        jnc    L_1177                                ; 117C
L_117E::
        jnb    speed_b1, L_1186                      ; 117E
        mov    dptr, #adc_count_time_fast            ; 1181
        sjmp   L_1189                                ; 1184
L_1186::
        mov    dptr, #adc_count_time_norm            ; 1186
L_1189::
        lcall  adc_count_minus_zero                  ; 1189
        mov    a, meter_state                        ; 118C
        anl    a, #0x0F                              ; 118E
        cjne   a, #0x02, L_1195                      ; 1190
        sjmp   L_119D                                ; 1193
L_1195::
        cjne   a, #0x03, L_119A                      ; 1195
        sjmp   L_119D                                ; 1198
L_119A::
        cjne   a, #0x07, L_11CF                      ; 119A
L_119D::
        jb     0x1C, L_11CD                          ; 119D
        mov    r0, #0x10                             ; 11A0
        lcall  rms_get_byte                          ; 11A2
        mov    r6, #0x4C                             ; 11A5
        jnb    speed_b1, L_11B0                      ; 11A7
        mov    sfr_B, #0x0A                          ; 11AA
        div    ab                                    ; 11AD
        mov    r6, #0xEE                             ; 11AE
L_11B0::
        mov    0x40, a                               ; 11B0
        clr    a                                     ; 11B2
        mov    0x41, a                               ; 11B3
        mov    range_lim_down, a                     ; 11B5
        lcall  i24_sub                               ; 11B7
        jb     cal_enable, L_11CD                    ; 11BA
        mov    0x40, r6                              ; 11BD
        mov    0x41, #0xFF                           ; 11BF
        mov    range_lim_down, #0xFF                 ; 11C2
        lcall  i24_cmp_signed                        ; 11C5
        jc     L_11CD                                ; 11C8
        lcall  i24_clr_r0                            ; 11CA
L_11CD::
        sjmp   L_11F4                                ; 11CD
L_11CF::
        lcall  meas_offset_select                    ; 11CF
        mov    r0, #0x42                             ; 11D2
        mov    r1, #0x46                             ; 11D4
        jnb    speed_b1, L_11DE                      ; 11D6
        mov    dptr, #T_6FE6                         ; 11D9
        sjmp   L_11E1                                ; 11DC
L_11DE::
        mov    dptr, #T_6FE3                         ; 11DE
L_11E1::
        lcall  i24_ld_code_r1                        ; 11E1
        lcall  i24_div_signed                        ; 11E4
        mov    r0, #0x10                             ; 11E7
        mov    dptr, #0x0107                         ; 11E9
        lcall  i24_st_r0_xdata                       ; 11EC
        mov    r1, #0x42                             ; 11EF
        lcall  i24_sub                               ; 11F1
L_11F4::
        ljmp   L_1287                                ; 11F4
L_11F7::
        mov    a, meter_state                        ; 11F7
        anl    a, #0x0F                              ; 11F9
        cjne   a, #0x09, L_120C                      ; 11FB
        mov    dptr, #T_6FE3                         ; 11FE
        lcall  i24_ld_code_r1                        ; 1201
        lcall  i24_div                               ; 1204
        mov    dptr, #T_6FEC                         ; 1207
        sjmp   L_1215                                ; 120A
L_120C::
        mov    a, meter_state                        ; 120C
        anl    a, #0x0F                              ; 120E
        jnz    L_121B                                ; 1210
        mov    dptr, #T_7040                         ; 1212
L_1215::
        lcall  i24_ld_code_r1                        ; 1215
        lcall  i24_sub                               ; 1218
L_121B::
        mov    a, meter_state                        ; 121B
        anl    a, #0x0F                              ; 121D
        cjne   a, #0x0A, L_1287                      ; 121F
        jb     0x65, L_1287                          ; 1222
        jnb    0x72, L_1257                          ; 1225
        mov    a, meter_state                        ; 1228
        anl    a, #0x70                              ; 122A
        cjne   a, #0x20, L_123C                      ; 122C
        jb     speed_b0, L_1237                      ; 122F
        mov    dptr, #freq_corr_1s                   ; 1232
        sjmp   L_123A                                ; 1235
L_1237::
        mov    dptr, #freq_corr_latency              ; 1237
L_123A::
        sjmp   L_1247                                ; 123A
L_123C::
        jb     speed_b0, L_1244                      ; 123C
        mov    dptr, #T_704D                         ; 123F
        sjmp   L_1247                                ; 1242
L_1244::
        mov    dptr, #T_7051                         ; 1244
L_1247::
        mov    r1, #0x43                             ; 1247
        lcall  fp_ld_code_r1                         ; 1249
        mov    r0, #0x10                             ; 124C
        lcall  i24_to_fp                             ; 124E
        lcall  fp_mul                                ; 1251
        lcall  fp_to_i24_round                       ; 1254
L_1257::
        mov    a, meter_state                        ; 1257
        anl    a, #0x70                              ; 1259
        cjne   a, #0x20, L_1287                      ; 125B
        jb     speed_b0, L_1266                      ; 125E
        mov    dptr, #freq_corr_1s                   ; 1261
        sjmp   L_1269                                ; 1264
L_1266::
        mov    dptr, #freq_corr_131ms                ; 1266
L_1269::
        mov    r1, #0x47                             ; 1269
        lcall  fp_ld_code_r1                         ; 126B
        mov    r0, #0x42                             ; 126E
        mov    r1, #0x18                             ; 1270
        lcall  i24_copy_r1_to_r0                     ; 1272
        lcall  i24_to_fp                             ; 1275
        mov    r1, #0x47                             ; 1278
        lcall  fp_mul                                ; 127A
        lcall  fp_to_i24_round                       ; 127D
        mov    r0, #0x18                             ; 1280
        mov    r1, #0x42                             ; 1282
        lcall  i24_copy_r1_to_r0                     ; 1284
L_1287::
        ret                                          ; 1287

; signed count = raw - T2 (29360, 2936 in SPEED 3); |count| >= T2 -> overload
adc_count_minus_zero::
        lcall  i24_ld_code_r1                        ; 1288
        lcall  i24_sub                               ; 128B
        mov    r1, #0x10                             ; 128E
        mov    r0, #0x46                             ; 1290
        lcall  i24_copy_r1_to_r0                     ; 1292
        lcall  i24_abs                               ; 1295
        mov    r1, #0x42                             ; 1298
        lcall  i24_cmp                               ; 129A
        jc     L_12A1                                ; 129D
        setb   0x69                                  ; 129F
L_12A1::
        ret                                          ; 12A1

; temp-compensate set 0 (and set 1 for Vpeak/VDC/CAP)
cal_compute_effective::
        lcall  cal_temp_compensate                   ; 12A2
        mov    a, meter_state                        ; 12A5
        anl    a, #0x0F                              ; 12A7
        jz     L_12B3                                ; 12A9
        cjne   a, #0x01, L_12B0                      ; 12AB
        sjmp   L_12B3                                ; 12AE
L_12B0::
        cjne   a, #0x09, L_12BC                      ; 12B0
L_12B3::
        lcall  cal_swap_sets                         ; 12B3
        lcall  cal_temp_compensate                   ; 12B6
        lcall  cal_swap_sets                         ; 12B9
L_12BC::
        ret                                          ; 12BC

; zero_eff = K0 + K4*(T-K2), gain_eff = K1 + K5*(T-K3); T = internal_temp
cal_temp_compensate::
        mov    r0, #0x43                             ; 12BD
        mov    r1, #0x47                             ; 12BF
        jnb    cal_mode, L_12DF                      ; 12C1
        jb     cal_hot, L_12DF                       ; 12C4
        mov    dptr, #0x0163                         ; 12C7
        lcall  fp_ld_xdata_r0                        ; 12CA
        mov    dptr, #x_cal_gain_eff                 ; 12CD
        lcall  fp_st_r0_xdata                        ; 12D0
        mov    dptr, #x_cal_work_set0                ; 12D3
        lcall  fp_ld_xdata_r0                        ; 12D6
        mov    dptr, #x_cal_zero_eff                 ; 12D9
        ljmp   fp_st_r0_xdata                        ; 12DC
L_12DF::
        mov    dptr, #x_internal_temp                ; 12DF
        lcall  fp_ld_xdata_r0                        ; 12E2
        mov    dptr, #0x016B                         ; 12E5
        lcall  fp_ld_xdata_r1                        ; 12E8
        lcall  fp_sub                                ; 12EB
        mov    dptr, #0x0173                         ; 12EE
        lcall  fp_ld_xdata_r1                        ; 12F1
        lcall  fp_mul                                ; 12F4
        mov    dptr, #0x0163                         ; 12F7
        lcall  fp_ld_xdata_r1                        ; 12FA
        lcall  fp_add                                ; 12FD
        mov    dptr, #x_cal_gain_eff                 ; 1300
        lcall  fp_st_r0_xdata                        ; 1303
        mov    dptr, #x_internal_temp                ; 1306
        lcall  fp_ld_xdata_r0                        ; 1309
        mov    dptr, #0x0167                         ; 130C
        lcall  fp_ld_xdata_r1                        ; 130F
        lcall  fp_sub                                ; 1312
        mov    dptr, #0x016F                         ; 1315
        lcall  fp_ld_xdata_r1                        ; 1318
        lcall  fp_mul                                ; 131B
        mov    dptr, #x_cal_work_set0                ; 131E
        lcall  fp_ld_xdata_r1                        ; 1321
        lcall  fp_add                                ; 1324
        mov    dptr, #x_cal_zero_eff                 ; 1327
        ljmp   fp_st_r0_xdata                        ; 132A

; exchange cal_work_set0 and cal_work_set1
cal_swap_sets::
        mov    dptr, #x_cal_work_set0                ; 132D
        mov    r0, #0x20                             ; 1330
        mov    r1, #0x00                             ; 1332
        mov    r2, #0x7F                             ; 1334
        mov    r3, #0x01                             ; 1336
        setb   c                                     ; 1338
        ljmp   xdata_block_xfer                      ; 1339

; 200000 / count -> XDATA 0x00EC
internal_temp_from_count::
        mov    r0, #0x10                             ; 133C
        lcall  i24_to_fp                             ; 133E
        mov    r0, #0x43                             ; 1341
        mov    r1, #0x11                             ; 1343
        mov    dptr, #T_707D                         ; 1345
        lcall  fp_ld_code_r0                         ; 1348
        lcall  fp_div                                ; 134B
        mov    dptr, #0x00EC                         ; 134E
        lcall  fp_st_r0_xdata                        ; 1351
        clr    0x29                                  ; 1354
        setb   0x13                                  ; 1356
        ret                                          ; 1358

; new internal-temperature reading -> filtered internal_temp
internal_temp_update::
        mov    r0, #0x10                             ; 1359
        lcall  i24_to_fp                             ; 135B
        mov    r1, #0x43                             ; 135E
        mov    dptr, #T_7065                         ; 1360
        lcall  fp_ld_code_r1                         ; 1363
        lcall  fp_div                                ; 1366
        lcall  temp_in_range                         ; 1369
        jnc    L_13B9                                ; 136C
        lcall  fp_copy_r0_to_r1                      ; 136E
        mov    r1, #0x47                             ; 1371
        mov    dptr, #x_internal_temp                ; 1373
        lcall  fp_ld_xdata_r1                        ; 1376
        mov    r0, #0x43                             ; 1379
        lcall  fp_sub                                ; 137B
        anl    0x43, #0x7F                           ; 137E
        mov    dptr, #T_691F                         ; 1381
        mov    r1, #0x4B                             ; 1384
        lcall  fp_ld_code_r1                         ; 1386
        lcall  fp_cmp                                ; 1389
        jnc    L_13B1                                ; 138C
        mov    dptr, #x_internal_temp                ; 138E
        mov    r0, #0x47                             ; 1391
        lcall  fp_ld_xdata_r0                        ; 1393
        lcall  internal_temp_filter                  ; 1396
        mov    dptr, #x_internal_temp                ; 1399
        lcall  fp_st_r0_xdata                        ; 139C
        jb     0x6B, L_13A4                          ; 139F
        setb   0x6C                                  ; 13A2
L_13A4::
        jb     0x6F, L_13A9                          ; 13A4
        clr    0x6E                                  ; 13A7
L_13A9::
        clr    0x6B                                  ; 13A9
        setb   0x66                                  ; 13AB
        setb   0x13                                  ; 13AD
        sjmp   L_13B9                                ; 13AF
L_13B1::
        mov    r0, #0x11                             ; 13B1
        mov    dptr, #x_internal_temp                ; 13B3
        lcall  fp_st_r0_xdata                        ; 13B6
L_13B9::
        ret                                          ; 13B9

; two references XDATA 0x00CD / 0x00D0
internal_temp_track::
        mov    dptr, #0x00CD                         ; 13BA
        lcall  internal_temp_delta_check             ; 13BD
        jc     L_13E5                                ; 13C0
        jb     0x6F, L_13CD                          ; 13C2
        mov    dptr, #0x00D0                         ; 13C5
        lcall  internal_temp_delta_check             ; 13C8
        jnc    L_13D4                                ; 13CB
L_13CD::
        clr    0x6D                                  ; 13CD
        mov    dptr, #0x00CD                         ; 13CF
        sjmp   L_13D9                                ; 13D2
L_13D4::
        setb   0x6D                                  ; 13D4
        mov    dptr, #0x00D0                         ; 13D6
L_13D9::
        mov    r0, #0x10                             ; 13D9
        lcall  i24_st_r0_xdata                       ; 13DB
        lcall  i24_to_fp                             ; 13DE
        mov    r1, #0x11                             ; 13E1
        sjmp   L_140A                                ; 13E3
L_13E5::
        clr    0x6D                                  ; 13E5
        mov    r0, #0x10                             ; 13E7
        lcall  i24_to_fp                             ; 13E9
        mov    r0, #0x46                             ; 13EC
        mov    dptr, #0x00CD                         ; 13EE
        lcall  i24_ld_xdata_r0                       ; 13F1
        lcall  i24_to_fp                             ; 13F4
        lcall  internal_temp_filter                  ; 13F7
        mov    r1, #0x11                             ; 13FA
        mov    r0, #0x47                             ; 13FC
        lcall  fp_copy_r1_to_r0                      ; 13FE
        lcall  fp_to_i24_round                       ; 1401
        mov    dptr, #0x00CD                         ; 1404
        lcall  i24_st_r0_xdata                       ; 1407
L_140A::
        jb     0x6D, L_143C                          ; 140A
        mov    0x36, #0x00                           ; 140D
        mov    r0, #0x43                             ; 1410
        mov    dptr, #T_7061                         ; 1412
        lcall  fp_ld_code_r0                         ; 1415
        lcall  fp_mul                                ; 1418
        lcall  fp_to_i24_round                       ; 141B
        mov    dptr, #0x011D                         ; 141E
        lcall  i24_st_r0_xdata                       ; 1421
        mov    r1, #0x11                             ; 1424
        mov    r0, #0x43                             ; 1426
        mov    dptr, #T_705D                         ; 1428
        lcall  fp_ld_code_r0                         ; 142B
        lcall  fp_mul                                ; 142E
        lcall  fp_to_i24_round                       ; 1431
        mov    dptr, #0x0120                         ; 1434
        lcall  i24_st_r0_xdata                       ; 1437
        sjmp   L_143E                                ; 143A
L_143C::
        inc    0x36                                  ; 143C
L_143E::
        jnb    0x6D, L_1447                          ; 143E
        mov    a, 0x36                               ; 1441
        add    a, #0xFD                              ; 1443
        jnc    L_144F                                ; 1445
L_1447::
        mov    0x36, #0x00                           ; 1447
        anl    0x2D, #0x2F                           ; 144A
        setb   0x13                                  ; 144D
L_144F::
        ret                                          ; 144F

internal_temp_delta_check::
        mov    r0, #0x43                             ; 1450
        lcall  i24_ld_xdata_r0                       ; 1452
        mov    r1, #0x10                             ; 1455
        lcall  i24_sub                               ; 1457
        lcall  i24_abs                               ; 145A
        mov    a, @r0                                ; 145D
        dec    r0                                    ; 145E
        orl    a, @r0                                ; 145F
        jz     L_1464                                ; 1460
        clr    c                                     ; 1462
        ret                                          ; 1463
L_1464::
        dec    r0                                    ; 1464
        mov    a, @r0                                ; 1465
        cjne   a, #0x0F, L_1469                      ; 1466
L_1469::
        ret                                          ; 1469

internal_temp_filter::
        mov    r0, #0x47                             ; 146A
        mov    r1, #0x43                             ; 146C
        mov    dptr, #T_6F7D                         ; 146E
        lcall  fp_ld_code_r1                         ; 1471
        lcall  fp_mul                                ; 1474
        mov    r0, #0x11                             ; 1477
        mov    dptr, #T_6F69                         ; 1479
        lcall  fp_ld_code_r1                         ; 147C
        lcall  fp_mul                                ; 147F
        mov    r1, #0x47                             ; 1482
        ljmp   fp_add                                ; 1484

; processing for modes 25h.1 / 2Dh.3 / 2Dh.6 (peak/temperature?)
meas_process_special::
        jnb    0x29, L_148D                          ; 1487
        ljmp   internal_temp_from_count              ; 148A
L_148D::
        setb   0x74                                  ; 148D
        jb     0x6B, L_1495                          ; 148F
        jb     0x6C, L_1498                          ; 1492
L_1495::
        ljmp   internal_temp_update                  ; 1495
L_1498::
        ljmp   internal_temp_track                   ; 1498

adc_start_alt_mode::
        mov    0x19, #0xFF                           ; 149B
        setb   adc_alt_mode                          ; 149E
        sjmp   L_14A4                                ; 14A0

; cmd 0x89 (or 0x8B if 26h.6) then PCF8574@0x4E bit0 = !26h.6
adc_start_cycle::
        clr    adc_alt_mode                          ; 14A2
L_14A4::
        mov    a, #0x89                              ; 14A4
        jnb    adc_alt_mode, L_14AB                  ; 14A6
        mov    a, #0x8B                              ; 14A9
L_14AB::
        lcall  i2cB_start                            ; 14AB
        lcall  i2cB_stop                             ; 14AE
        mov    a, #0x4E                              ; 14B1
        lcall  i2cA_read1                            ; 14B3
        mov    c, adc_alt_mode                       ; 14B6
        cpl    c                                     ; 14B8
        mov    0xE0, c                               ; 14B9
        mov    r3, a                                 ; 14BB
        mov    a, #0x4E                              ; 14BC
        ljmp   i2cA_write1                           ; 14BE

; timers/interrupts off, phase flags reset
meas_stop_and_reset::
        jnb    sbit_F0, L_14CC                       ; 14C1
        mov    sfr_IE, #0x00                         ; 14C4
        mov    sfr_TCON, #0x00                       ; 14C7
        sjmp   L_14D2                                ; 14CA
L_14CC::
        anl    sfr_IE, #0x88                         ; 14CC
        anl    sfr_TCON, #0xC0                       ; 14CF
L_14D2::
        mov    sfr_IP, #0x00                         ; 14D2
        anl    0x2E, #0xF4                           ; 14D5
        setb   0x72                                  ; 14D8
        setb   0x5C                                  ; 14DA
        setb   0x5F                                  ; 14DC
        anl    0x2F, #0xFC                           ; 14DE
        clr    0x28                                  ; 14E1
        anl    0x27, #0xDC                           ; 14E3
        clr    0x63                                  ; 14E6
        ret                                          ; 14E8

time_read_counter::
        jb     0x72, L_14EE                          ; 14E9
        clr    sbit_ET1                              ; 14EC
L_14EE::
        mov    0x50, 0x11                            ; 14EE
        mov    0x4F, adc_count_hi                    ; 14F1
        mov    0x4E, adc_count_mid                   ; 14F4
        mov    0x4D, sfr_TH1                         ; 14F7
        mov    c, sbit_TF1                           ; 14FA
        jnb    0x72, L_1504                          ; 14FC
        mov    0x4C, sfr_TL1                         ; 14FF
        sjmp   L_1509                                ; 1502
L_1504::
        setb   sbit_ET1                              ; 1504
        mov    0x4C, #0x00                           ; 1506
L_1509::
        jnc    L_1514                                ; 1509
        mov    a, sfr_TH1                            ; 150B
        jnz    L_1514                                ; 150D
        mov    r0, #0x50                             ; 150F
        lcall  i24_inc_r0                            ; 1511
L_1514::
        ret                                          ; 1514

; seconds = (T1 overflows*65536 + T1) * 1e-6; decade autorange; cal (timebase) applied
meas_process_time::
        lcall  time_read_counter                     ; 1515
        mov    r0, #0x42                             ; 1518
        mov    r1, #0x50                             ; 151A
        lcall  i24_copy_r1_to_r0                     ; 151C
        lcall  i24_to_fp                             ; 151F
        mov    r1, #0x47                             ; 1522
        mov    dptr, #T_7069                         ; 1524
        lcall  fp_ld_code_r1                         ; 1527
        lcall  fp_mul                                ; 152A
        mov    0x4F, #0x00                           ; 152D
        mov    0x4E, 0x4D                            ; 1530
        mov    0x4D, 0x4C                            ; 1533
        mov    r0, #0x4F                             ; 1536
        lcall  i24_to_fp                             ; 1538
        mov    r1, #0x43                             ; 153B
        lcall  fp_add                                ; 153D
        mov    a, #0xFA                              ; 1540
        lcall  fp_ld_pow10_r1                        ; 1542
        lcall  fp_mul                                ; 1545
        mov    dptr, #0x010A                         ; 1548
        lcall  fp_ld_xdata_r1                        ; 154B
        lcall  fp_cmp                                ; 154E
        jnc    L_1556                                ; 1551
        jnb    0x72, L_156B                          ; 1553
L_1556::
        setb   0x5F                                  ; 1556
        mov    r0, #0x43                             ; 1558
        mov    r1, #0x47                             ; 155A
        mov    dptr, #T_6F69                         ; 155C
        lcall  fp_ld_code_r1                         ; 155F
        lcall  fp_add                                ; 1562
        mov    dptr, #0x010A                         ; 1565
        lcall  fp_st_r0_xdata                        ; 1568
L_156B::
        mov    r0, #0x50                             ; 156B
        mov    r1, #0x43                             ; 156D
        mov    dptr, #0x010E                         ; 156F
        lcall  fp_ld_xdata_r1                        ; 1572
        lcall  fp_cmp                                ; 1575
        jnc    L_1580                                ; 1578
        jb     0x72, L_1580                          ; 157A
        ljmp   L_161E                                ; 157D
L_1580::
        mov    r0, #0x43                             ; 1580
        mov    r1, #0x47                             ; 1582
        mov    a, #0x00                              ; 1584
        lcall  fp_ld_pow10_r1                        ; 1586
        lcall  fp_add                                ; 1589
        mov    dptr, #0x010E                         ; 158C
        lcall  fp_st_r0_xdata                        ; 158F
        jnb    meter_autorange, L_15E2               ; 1592
        mov    0x43, #0x00                           ; 1595
        clr    0x5B                                  ; 1598
L_159A::
        mov    r1, #0x47                             ; 159A
        mov    a, 0x43                               ; 159C
        lcall  fp_ld_pow10_r1                        ; 159E
        mov    r0, #0x50                             ; 15A1
        lcall  fp_cmp                                ; 15A3
        jnc    L_15BB                                ; 15A6
        mov    a, 0x43                               ; 15A8
        inc    a                                     ; 15AA
        mov    sfr_B, #0x10                          ; 15AB
        mul    ab                                    ; 15AE
        mov    range_lim_down, a                     ; 15AF
        mov    a, meter_state                        ; 15B1
        anl    a, #0x8F                              ; 15B3
        orl    a, range_lim_down                     ; 15B5
        mov    meter_state, a                        ; 15B7
        setb   0x5B                                  ; 15B9
L_15BB::
        mov    a, 0x43                               ; 15BB
        inc    a                                     ; 15BD
        mov    0x43, a                               ; 15BE
        jb     0x5B, L_15C8                          ; 15C0
        clr    c                                     ; 15C3
        subb   a, #0x06                              ; 15C4
        jc     L_159A                                ; 15C6
L_15C8::
        jb     0x5B, L_15E0                          ; 15C8
        mov    a, meter_state                        ; 15CB
        anl    a, #0x8F                              ; 15CD
        orl    a, #0x60                              ; 15CF
        mov    r1, #0x43                             ; 15D1
        mov    dptr, #T_706D                         ; 15D3
        lcall  fp_ld_code_r1                         ; 15D6
        lcall  fp_cmp                                ; 15D9
        jnc    L_15E0                                ; 15DC
        setb   0x69                                  ; 15DE
L_15E0::
        sjmp   L_15F2                                ; 15E0
L_15E2::
        mov    r0, #0x47                             ; 15E2
        lcall  time_range_limit                      ; 15E4
        mov    r0, #0x50                             ; 15E7
        mov    r1, #0x47                             ; 15E9
        lcall  fp_cmp                                ; 15EB
        jc     L_15F2                                ; 15EE
        setb   0x69                                  ; 15F0
L_15F2::
        jnb    0x69, L_1601                          ; 15F2
        setb   sbit_F0                               ; 15F5
        lcall  meas_stop_and_reset                   ; 15F7
        mov    r0, #0x50                             ; 15FA
        lcall  time_range_limit                      ; 15FC
        sjmp   L_1604                                ; 15FF
L_1601::
        lcall  cal_apply                             ; 1601
L_1604::
        mov    r0, #0x50                             ; 1604
        mov    r1, #0x43                             ; 1606
        mov    dptr, #0x0112                         ; 1608
        lcall  fp_ld_xdata_r1                        ; 160B
        lcall  fp_cmp                                ; 160E
        jnc    L_1616                                ; 1611
        jnb    0x72, L_161E                          ; 1613
L_1616::
        orl    0x2B, #0x90                           ; 1616
        mov    c, 0x72                               ; 1619
        cpl    c                                     ; 161B
        mov    0x59, c                               ; 161C
L_161E::
        ret                                          ; 161E

; 10^(range-1) s * 1.1 (manual-range overload)
time_range_limit::
        mov    r1, #0x43                             ; 161F
        mov    a, meter_state                        ; 1621
        anl    a, #0x70                              ; 1623
        mov    sfr_B, #0x10                          ; 1625
        div    ab                                    ; 1628
        dec    a                                     ; 1629
        lcall  fp_ld_pow10_r1                        ; 162A
        mov    dptr, #T_6F91                         ; 162D
        lcall  fp_ld_code_r0                         ; 1630
        ljmp   fp_mul                                ; 1633

; SPEED 3 (and FRQ SPEED 2): count / 10
fast_mode_drop_digit::
        mov    a, meter_state                        ; 1636
        anl    a, #0x0F                              ; 1638
        cjne   a, #0x0A, L_1643                      ; 163A
        jb     speed_b1, L_1643                      ; 163D
        jb     speed_b0, L_1646                      ; 1640
L_1643::
        jnb    speed_b1, L_1659                      ; 1643
L_1646::
        mov    dptr, #T_6FE3                         ; 1646
        mov    r1, #0x42                             ; 1649
        lcall  i24_ld_code_r1                        ; 164B
        mov    r0, #0x4F                             ; 164E
        lcall  i24_mul_signed                        ; 1650
        mov    0x4D, r3                              ; 1653
        mov    0x4E, r4                              ; 1655
        mov    0x4F, r5                              ; 1657
L_1659::
        ret                                          ; 1659

; A = base(function) + range. Bases: Vpk -4, V -5, ohm -2, I -11 (-9 if 25h.6), time 0, C -14, f -3 (-4 in range 6), degC -1, diode -4, cont -2
range_scale_exp::
        mov    a, meter_state                        ; 165A
        anl    a, #0x0F                              ; 165C
        rl     a                                     ; 165E
        mov    dptr, #L_1663                         ; 165F
        jmp    @a+dptr                               ; 1662
L_1663::
        sjmp   L_167F                                ; 1663
L_1665::
        sjmp   L_1683                                ; 1665
L_1667::
        sjmp   L_1683                                ; 1667
L_1669::
        sjmp   L_1683                                ; 1669
L_166B::
        sjmp   L_1687                                ; 166B
L_166D::
        sjmp   L_1687                                ; 166D
L_166F::
        sjmp   L_168B                                ; 166F
L_1671::
        sjmp   L_168B                                ; 1671
L_1673::
        sjmp   L_1696                                ; 1673
L_1675::
        sjmp   L_169A                                ; 1675
L_1677::
        sjmp   L_169E                                ; 1677
L_1679::
        sjmp   L_16AD                                ; 1679
L_167B::
        sjmp   L_167F                                ; 167B
L_167D::
        sjmp   L_1687                                ; 167D
L_167F::
        mov    a, #0xFC                              ; 167F
L_1681::
        sjmp   L_16AF                                ; 1681
L_1683::
        mov    a, #0xFB                              ; 1683
        sjmp   L_16AF                                ; 1685
L_1687::
        mov    a, #0xFE                              ; 1687
        sjmp   L_16AF                                ; 1689
L_168B::
        jnb    0x2E, L_1692                          ; 168B
        mov    a, #0xF7                              ; 168E
        sjmp   L_1694                                ; 1690
L_1692::
        mov    a, #0xF5                              ; 1692
L_1694::
        sjmp   L_16AF                                ; 1694
L_1696::
        mov    a, #0x00                              ; 1696
        sjmp   L_16AF                                ; 1698
L_169A::
        mov    a, #0xF2                              ; 169A
        sjmp   L_16AF                                ; 169C
L_169E::
        mov    a, meter_state                        ; 169E
        anl    a, #0x70                              ; 16A0
        cjne   a, #0x60, L_16A9                      ; 16A2
        mov    a, #0xFC                              ; 16A5
        sjmp   L_16AB                                ; 16A7
L_16A9::
        mov    a, #0xFD                              ; 16A9
L_16AB::
        sjmp   L_16AF                                ; 16AB
L_16AD::
        mov    a, #0xFF                              ; 16AD
L_16AF::
        mov    r0, a                                 ; 16AF
        mov    a, meter_state                        ; 16B0
        anl    a, #0x70                              ; 16B2
        mov    sfr_B, #0x10                          ; 16B4
        div    ab                                    ; 16B7
        add    a, r0                                 ; 16B8
        ret                                          ; 16B9

; 4Fh (i24 count) -> float * 10^range_scale_exp
count_to_value::
        mov    r0, #0x4F                             ; 16BA
        lcall  i24_to_fp                             ; 16BC
        lcall  range_scale_exp                       ; 16BF
        mov    r1, #0x43                             ; 16C2
        lcall  fp_ld_pow10_r1                        ; 16C4
        mov    r0, #0x50                             ; 16C7
        ljmp   fp_mul                                ; 16C9

; inverse of count_to_value
value_to_count::
        lcall  range_scale_exp                       ; 16CC
        mov    r1, #0x43                             ; 16CF
        lcall  fp_ld_pow10_r1                        ; 16D1
        mov    r0, #0x50                             ; 16D4
        lcall  fp_div                                ; 16D6
        ljmp   fp_to_i24_round                       ; 16D9

; value = (count - zero_eff) * gain_eff (set 1 for negative VDC, Vp-, CAP in SPEED 3)
cal_apply::
        mov    r1, #0x43                             ; 16DC
        lcall  fp_push_r1                            ; 16DE
        mov    a, meter_state                        ; 16E1
        anl    a, #0x0F                              ; 16E3
        jnz    L_16F2                                ; 16E5
        jnb    peak_mode_b0, L_170E                  ; 16E7
        jnb    peak_mode_b1, L_1702                  ; 16EA
        jb     0x72, L_1702                          ; 16ED
        sjmp   L_170E                                ; 16F0
L_16F2::
        cjne   a, #0x01, L_16FC                      ; 16F2
        mov    a, 0x50                               ; 16F5
        jb     0xE7, L_1702                          ; 16F7
        sjmp   L_170E                                ; 16FA
L_16FC::
        cjne   a, #0x09, L_170E                      ; 16FC
        jnb    speed_b1, L_170E                      ; 16FF
L_1702::
        mov    dptr, #x_cal_gain_eff1                ; 1702
        push   sfr_DPL                               ; 1705
        push   sfr_DPH                               ; 1707
        mov    dptr, #x_cal_zero_eff1                ; 1709
        sjmp   L_1718                                ; 170C
L_170E::
        mov    dptr, #x_cal_gain_eff                 ; 170E
        push   sfr_DPL                               ; 1711
        push   sfr_DPH                               ; 1713
        mov    dptr, #x_cal_zero_eff                 ; 1715
L_1718::
        lcall  fp_ld_xdata_r1                        ; 1718
        mov    r0, #0x50                             ; 171B
        lcall  fp_sub                                ; 171D
        pop    sfr_DPH                               ; 1720
        pop    sfr_DPL                               ; 1722
        lcall  fp_ld_xdata_r1                        ; 1724
        lcall  fp_mul                                ; 1727
        lcall  fp_clr_r1                             ; 172A
        ret                                          ; 172D

; some functions measure in SPEED 3 while ranging
speed_force_fast::
        mov    a, meter_state                        ; 172E
        anl    a, #0x0F                              ; 1730
        jb     0x03, L_1739                          ; 1732
        jz     L_1745                                ; 1735
        sjmp   L_1741                                ; 1737
L_1739::
        cjne   a, #0x09, L_173E                      ; 1739
        sjmp   L_1741                                ; 173C
L_173E::
        cjne   a, #0x0C, L_1745                      ; 173E
L_1741::
        clr    speed_b0                              ; 1741
        setb   speed_b1                              ; 1743
L_1745::
        ret                                          ; 1745

speed_restore::
        mov    a, 0x35                               ; 1746
        anl    a, #0x03                              ; 1748
        anl    meter_mode, #0xFC                     ; 174A
        orl    meter_mode, a                         ; 174D
        ret                                          ; 174F

autorange_finish_common::
        lcall  meas_stop_and_reset                   ; 1750
        anl    0x2E, #0xF9                           ; 1753
        clr    0x28                                  ; 1756
        clr    0x5C                                  ; 1758
        setb   0x60                                  ; 175A
        anl    0x2C, #0xF9                           ; 175C
        ret                                          ; 175F

; (inferred) remember speed, go fast while ranging
autorange_enter_fast::
        jb     0x65, L_1771                          ; 1760
        setb   0x65                                  ; 1763
        anl    0x35, #0xFC                           ; 1765
        mov    a, meter_mode                         ; 1768
        anl    a, #0x03                              ; 176A
        orl    0x35, a                               ; 176C
        lcall  speed_force_fast                      ; 176E
L_1771::
        setb   0x13                                  ; 1771
        mov    dptr, #0x01A3                         ; 1773
        movx   a, @dptr                              ; 1776
        inc    a                                     ; 1777
        movx   @dptr, a                              ; 1778
        ljmp   autorange_finish_common               ; 1779

autorange_leave_fast::
        jnb    0x65, L_1786                          ; 177C
        lcall  speed_restore                         ; 177F
        setb   0x13                                  ; 1782
        clr    0x65                                  ; 1784
L_1786::
        ljmp   autorange_finish_common               ; 1786

autorange_count_step::
        inc    0x34                                  ; 1789
        mov    a, meter_state                        ; 178B
        anl    a, #0x0F                              ; 178D
        cjne   a, #0x0A, L_179B                      ; 178F
        anl    0x35, #0x8F                           ; 1792
        orl    0x35, #0x60                           ; 1795
        ljmp   autorange_enter_fast                  ; 1798
L_179B::
        ljmp   autorange_leave_fast                  ; 179B

autorange_reset::
        clr    a                                     ; 179E
        mov    0x34, a                               ; 179F
        mov    0x1A, a                               ; 17A1
        mov    dptr, #0x01A3                         ; 17A3
        movx   @dptr, a                              ; 17A6
        clr    0x53                                  ; 17A7
        ljmp   autorange_count_step                  ; 17A9

; dB conversion (reference XDATA 0x0075) and zero/relative subtraction (0x0079)
result_apply_db_rel::
        jnb    0x10, L_1818                          ; 17AC
        mov    a, meter_state                        ; 17AF
        anl    a, #0x70                              ; 17B1
        swap   a                                     ; 17B3
        mov    sfr_B, a                              ; 17B4
        mov    a, meter_mode                         ; 17B6
        anl    a, #0x03                              ; 17B8
        add    a, sfr_B                              ; 17BA
        mov    sfr_B, a                              ; 17BC
        mov    a, #0x06                              ; 17BE
        clr    c                                     ; 17C0
        subb   a, sfr_B                              ; 17C1
        mov    r1, #0x43                             ; 17C3
        lcall  fp_ld_pow10_r1                        ; 17C5
        mov    r0, #0x43                             ; 17C8
        mov    r1, #0x50                             ; 17CA
        lcall  fp_mul                                ; 17CC
        lcall  fp_to_i24_round                       ; 17CF
        lcall  i24_abs                               ; 17D2
        mov    dptr, #0x0116                         ; 17D5
        lcall  i24_st_r0_xdata                       ; 17D8
        mov    dptr, #T_6FEF                         ; 17DB
        mov    r1, #0x46                             ; 17DE
        lcall  i24_ld_code_r1                        ; 17E0
        lcall  i24_cmp                               ; 17E3
        mov    r0, #0x50                             ; 17E6
        jnc    L_17F4                                ; 17E8
        lcall  fp_ld_max_r0                          ; 17EA
        orl    0x50, #0x80                           ; 17ED
        setb   0x5D                                  ; 17F0
        sjmp   L_1818                                ; 17F2
L_17F4::
        lcall  fp_copy_r0_to_r1                      ; 17F4
        lcall  fp_mul                                ; 17F7
        mov    a, #0x03                              ; 17FA
        lcall  fp_ld_pow10_r1                        ; 17FC
        lcall  fp_mul                                ; 17FF
        mov    dptr, #x_dbm_reference                ; 1802
        lcall  fp_ld_xdata_r1                        ; 1805
        lcall  fp_div                                ; 1808
        mov    a, #0x03                              ; 180B
        lcall  db_log10_value                        ; 180D
        mov    a, #0x01                              ; 1810
        lcall  fp_ld_pow10_r1                        ; 1812
        lcall  fp_mul                                ; 1815
L_1818::
        jb     0x5D, L_182B                          ; 1818
        jnb    0x11, L_182B                          ; 181B
        mov    dptr, #x_zero_reference               ; 181E
        mov    r0, #0x50                             ; 1821
        mov    r1, #0x43                             ; 1823
        lcall  fp_ld_xdata_r1                        ; 1825
        lcall  fp_sub                                ; 1828
L_182B::
        ret                                          ; 182B

; store float result to XDATA 0x00F2
result_store::
        setb   0x37                                  ; 182C
        mov    r0, #0x50                             ; 182E
        mov    dptr, #x_meas_result                  ; 1830
        lcall  fp_st_r0_xdata                        ; 1833
        setb   0x21                                  ; 1836
        ret                                          ; 1838

; status byte 0 (56h): b0 crest(C) b1 overload(O) b2 cal fail(F) b3 unsettled(R) b4 uncal(N) b5 dB underflow(U) b7 no fresh conv.
meas_build_status::
        clr    a                                     ; 1839
        mov    c, 0x69                               ; 183A
        mov    0xE1, c                               ; 183C
        mov    c, 0x68                               ; 183E
        mov    0xE0, c                               ; 1840
        mov    c, 0x64                               ; 1842
        mov    0xE2, c                               ; 1844
        mov    c, 0x5E                               ; 1846
        mov    0xE3, c                               ; 1848
        mov    c, 0x1F                               ; 184A
        mov    0xE4, c                               ; 184C
        mov    c, 0x5D                               ; 184E
        mov    0xE5, c                               ; 1850
        mov    c, 0x72                               ; 1852
        cpl    c                                     ; 1854
        mov    0xE7, c                               ; 1855
        mov    0x56, a                               ; 1857
        mov    a, meter_state                        ; 1859
        anl    a, #0x70                              ; 185B
        xch    a, sfr_B                              ; 185D
        mov    a, meter_state                        ; 185F
        anl    a, #0x0E                              ; 1861
        cjne   a, #0x06, L_186C                      ; 1863
        mov    c, 0x2E                               ; 1866
        mov    0xF7, c                               ; 1868
        sjmp   L_186E                                ; 186A
L_186C::
        clr    0xF7                                  ; 186C
L_186E::
        mov    0x57, sfr_B                           ; 186E
        ret                                          ; 1871

; compare result with min (0x007D) / max (0x0081), store
minmax_update::
        mov    r0, #0x50                             ; 1872
        mov    r1, #0x43                             ; 1874
        mov    dptr, #x_minmax_min                   ; 1876
        lcall  fp_ld_xdata_r1                        ; 1879
        lcall  fp_cmp                                ; 187C
        jnc    L_1891                                ; 187F
        mov    dptr, #x_minmax_min                   ; 1881
        lcall  fp_st_r0_xdata                        ; 1884
        mov    dptr, #0x0069                         ; 1887
        mov    a, 0x56                               ; 188A
        movx   @dptr, a                              ; 188C
        inc    dptr                                  ; 188D
        mov    a, 0x57                               ; 188E
        movx   @dptr, a                              ; 1890
L_1891::
        mov    dptr, #x_minmax_max                   ; 1891
        lcall  fp_ld_xdata_r1                        ; 1894
        lcall  fp_cmp                                ; 1897
        jz     L_18AE                                ; 189A
        jc     L_18AE                                ; 189C
        mov    dptr, #x_minmax_max                   ; 189E
        lcall  fp_st_r0_xdata                        ; 18A1
        mov    dptr, #0x006B                         ; 18A4
        mov    a, 0x56                               ; 18A7
        movx   @dptr, a                              ; 18A9
        inc    dptr                                  ; 18AA
        mov    a, 0x57                               ; 18AB
        movx   @dptr, a                              ; 18AD
L_18AE::
        ret                                          ; 18AE

; 0x0064/0x0065 status, 0x0085 value (float), 0x0066 |= 1 on any error
meas_publish_result::
        setb   0x20                                  ; 18AF
        clr    trigger_pending                       ; 18B1
        setb   0x2C                                  ; 18B3
        mov    dptr, #x_result_status0               ; 18B5
        mov    a, 0x56                               ; 18B8
        movx   @dptr, a                              ; 18BA
        inc    dptr                                  ; 18BB
        mov    a, 0x57                               ; 18BC
        movx   @dptr, a                              ; 18BE
        mov    r0, #0x50                             ; 18BF
        mov    dptr, #x_result_value                 ; 18C1
        lcall  fp_st_r0_xdata                        ; 18C4
        mov    a, 0x56                               ; 18C7
        anl    a, #0x2F                              ; 18C9
        jz     L_18D4                                ; 18CB
        mov    dptr, #x_result_flags                 ; 18CD
        movx   a, @dptr                              ; 18D0
        setb   0xE0                                  ; 18D1
        movx   @dptr, a                              ; 18D3
L_18D4::
        ret                                          ; 18D4

; held status 0x0067/0x0068, value 0x0089
hold_store_result::
        setb   0x21                                  ; 18D5
        setb   0x33                                  ; 18D7
        clr    0x59                                  ; 18D9
        mov    dptr, #0x0067                         ; 18DB
        mov    a, 0x56                               ; 18DE
        movx   @dptr, a                              ; 18E0
        mov    dptr, #0x0068                         ; 18E1
        mov    a, 0x57                               ; 18E4
        movx   @dptr, a                              ; 18E6
        mov    r0, #0x50                             ; 18E7
        mov    dptr, #0x0089                         ; 18E9
        ljmp   fp_st_r0_xdata                        ; 18EC

; publish result, min/max values 0x0089/0x008D/0x0091, restart ADC
meas_result_complete::
        jnb    0x72, L_1949                          ; 18EF
        jb     0x69, L_190A                          ; 18F2
        jb     0x5D, L_190A                          ; 18F5
        mov    r0, #0x55                             ; 18F8
        mov    dptr, #0x0091                         ; 18FA
        lcall  fp_st_r0_xdata                        ; 18FD
        mov    r0, #0x50                             ; 1900
        mov    dptr, #0x008D                         ; 1902
        lcall  fp_st_r0_xdata                        ; 1905
        setb   0x35                                  ; 1908
L_190A::
        mov    a, meter_state                        ; 190A
        anl    a, #0x0F                              ; 190C
        cjne   a, #0x08, L_1922                      ; 190E
        mov    r0, #0x55                             ; 1911
        mov    r1, #0x43                             ; 1913
        mov    a, #0x01                              ; 1915
        lcall  fp_ld_pow10_r1                        ; 1917
        lcall  fp_cmp                                ; 191A
        jc     L_1922                                ; 191D
        lcall  adc_start_alt_mode                    ; 191F
L_1922::
        mov    a, meter_state                        ; 1922
        anl    a, #0x0F                              ; 1924
        cjne   a, #0x0D, L_1946                      ; 1926
        mov    r0, #0x50                             ; 1929
        push   0x50                                  ; 192B
        anl    0x50, #0x7F                           ; 192D
        mov    r1, #0x43                             ; 1930
        mov    a, #0x01                              ; 1932
        lcall  fp_ld_pow10_r1                        ; 1934
        lcall  fp_cmp                                ; 1937
        pop    0x50                                  ; 193A
        jnc    L_1943                                ; 193C
        lcall  adc_start_alt_mode                    ; 193E
        sjmp   L_1946                                ; 1941
L_1943::
        lcall  adc_start_cycle                       ; 1943
L_1946::
        lcall  meas_publish_result                   ; 1946
L_1949::
        ljmp   hold_store_result                     ; 1949

; C=1 if range+1 is enabled in valid_range_masks
range_can_go_up::
        mov    a, meter_state                        ; 194C
        swap   a                                     ; 194E
        anl    a, #0x07                              ; 194F
        cjne   a, #0x07, L_1956                      ; 1951
        clr    c                                     ; 1954
        ret                                          ; 1955
L_1956::
        inc    a                                     ; 1956
        sjmp   range_mask_test                       ; 1957

; C=1 if range-1 is enabled (current on 25h.6 input: only from range 6/7)
range_can_go_down::
        mov    a, meter_state                        ; 1959
        anl    a, #0x0F                              ; 195B
        xrl    a, #0x06                              ; 195D
        anl    a, #0x0E                              ; 195F
        jnz    L_196B                                ; 1961
        jnb    0x2E, L_196B                          ; 1963
        mov    c, 0x06                               ; 1966
        anl    c, 0x05                               ; 1968
        ret                                          ; 196A
L_196B::
        mov    a, meter_state                        ; 196B
        swap   a                                     ; 196D
        anl    a, #0x07                              ; 196E
        jnz    L_1974                                ; 1970
        clr    c                                     ; 1972
        ret                                          ; 1973
L_1974::
        dec    a                                     ; 1974

; tests bit R0 of valid_range_masks[function*3 + speed]
range_mask_test::
        mov    r0, a                                 ; 1975
        mov    dptr, #valid_range_masks              ; 1976
        mov    a, meter_state                        ; 1979
        anl    a, #0x0F                              ; 197B
        mov    sfr_B, #0x03                          ; 197D
        mul    ab                                    ; 1980
        xch    a, sfr_B                              ; 1981
        mov    a, meter_mode                         ; 1983
        anl    a, #0x03                              ; 1985
        add    a, sfr_B                              ; 1987
        lcall  dptr_add_a_b                          ; 1989
        clr    a                                     ; 198C
        movc   a, @a+dptr                            ; 198D
        xch    a, r0                                 ; 198E
        inc    a                                     ; 198F
        xch    a, r0                                 ; 1990
L_1991::
        rrc    a                                     ; 1991
        djnz   r0, L_1991                            ; 1992
        ret                                          ; 1994

range_can_go_up_saved::
        jnb    0x65, L_19A4                          ; 1995
        push   meter_mode                            ; 1998
        lcall  speed_restore                         ; 199A
        lcall  range_can_go_up                       ; 199D
        pop    meter_mode                            ; 19A0
        sjmp   L_19A7                                ; 19A2
L_19A4::
        lcall  range_can_go_up                       ; 19A4
L_19A7::
        ret                                          ; 19A7

; per-range constants (tables 0x6FE9..0x7031)
range_param_lookup::
        mov    r0, #0x42                             ; 19A8
        lcall  i24_clr_r0                            ; 19AA
        mov    r1, #0x46                             ; 19AD
        mov    a, meter_state                        ; 19AF
        anl    a, #0x0F                              ; 19B1
        mov    sfr_B, #0x03                          ; 19B3
        mul    ab                                    ; 19B6
        mov    dptr, #L_19BB                         ; 19B7
        jmp    @a+dptr                               ; 19BA
L_19BB::
        ljmp   L_19E5                                ; 19BB
L_19BE::
        ljmp   L_1A0D                                ; 19BE
L_19C1::
        ljmp   L_1A0D                                ; 19C1
L_19C4::
        ljmp   L_1A0D                                ; 19C4
L_19C7::
        ljmp   L_1A18                                ; 19C7
L_19CA::
        ljmp   L_1A18                                ; 19CA
L_19CD::
        ljmp   L_1A2F                                ; 19CD
L_19D0::
        ljmp   L_1A2F                                ; 19D0
L_19D3::
        ljmp   L_1A46                                ; 19D3
L_19D6::
        ljmp   L_1A57                                ; 19D6
L_19D9::
        ljmp   L_1A6D                                ; 19D9
L_19DC::
        ljmp   L_1A97                                ; 19DC
L_19DF::
        ljmp   L_1AA4                                ; 19DF
L_19E2::
        ljmp   L_1AA4                                ; 19E2
L_19E5::
        mov    dptr, #T_6FFB                         ; 19E5
        lcall  i24_ld_code_r0                        ; 19E8
        mov    r0, #0x4A                             ; 19EB
        jb     0x06, L_19FE                          ; 19ED
        mov    dptr, #T_700D                         ; 19F0
        lcall  i24_ld_code_r1                        ; 19F3
        mov    dptr, #T_7010                         ; 19F6
        lcall  i24_ld_code_r0                        ; 19F9
        sjmp   L_1A0A                                ; 19FC
L_19FE::
        mov    dptr, #range_count_limits             ; 19FE
        lcall  i24_ld_code_r1                        ; 1A01
        mov    dptr, #T_7007                         ; 1A04
        lcall  i24_ld_code_r0                        ; 1A07
L_1A0A::
        ljmp   L_1AAF                                ; 1A0A
L_1A0D::
        mov    dptr, #T_700A                         ; 1A0D
        lcall  i24_ld_code_r0                        ; 1A10
        jb     0x06, L_1A35                          ; 1A13
        sjmp   L_1A1E                                ; 1A16
L_1A18::
        mov    dptr, #T_700A                         ; 1A18
        lcall  i24_ld_code_r0                        ; 1A1B
L_1A1E::
        mov    dptr, #T_7022                         ; 1A1E
        lcall  i24_ld_code_r1                        ; 1A21
        mov    dptr, #T_7025                         ; 1A24
        mov    r0, #0x4A                             ; 1A27
        lcall  i24_ld_code_r0                        ; 1A29
        ljmp   L_1AAF                                ; 1A2C
L_1A2F::
        mov    dptr, #T_7001                         ; 1A2F
        lcall  i24_ld_code_r0                        ; 1A32
L_1A35::
        mov    dptr, #T_7019                         ; 1A35
        lcall  i24_ld_code_r1                        ; 1A38
        mov    dptr, #T_701C                         ; 1A3B
        mov    r0, #0x4A                             ; 1A3E
        lcall  i24_ld_code_r0                        ; 1A40
        ljmp   L_1AAF                                ; 1A43
L_1A46::
        mov    dptr, #T_7028                         ; 1A46
        lcall  i24_ld_code_r1                        ; 1A49
        mov    r0, #0x4A                             ; 1A4C
        mov    dptr, #T_702B                         ; 1A4E
        lcall  i24_ld_code_r0                        ; 1A51
        ljmp   L_1AAF                                ; 1A54
L_1A57::
        mov    dptr, #T_700A                         ; 1A57
        lcall  i24_ld_code_r0                        ; 1A5A
        mov    dptr, #T_7022                         ; 1A5D
        lcall  i24_ld_code_r1                        ; 1A60
        mov    dptr, #T_7025                         ; 1A63
        mov    r0, #0x4A                             ; 1A66
        lcall  i24_ld_code_r0                        ; 1A68
        sjmp   L_1AAF                                ; 1A6B
L_1A6D::
        mov    dptr, #T_7016                         ; 1A6D
        lcall  i24_ld_code_r0                        ; 1A70
        mov    r0, #0x4A                             ; 1A73
        jnb    0x06, L_1A7B                          ; 1A75
        jb     0x05, L_1A89                          ; 1A78
L_1A7B::
        mov    dptr, #T_7028                         ; 1A7B
        lcall  i24_ld_code_r1                        ; 1A7E
        mov    dptr, #T_702B                         ; 1A81
        lcall  i24_ld_code_r0                        ; 1A84
        sjmp   L_1A95                                ; 1A87
L_1A89::
        mov    dptr, #T_702E                         ; 1A89
        lcall  i24_ld_code_r1                        ; 1A8C
        mov    dptr, #T_7031                         ; 1A8F
        lcall  i24_ld_code_r0                        ; 1A92
L_1A95::
        sjmp   L_1AAF                                ; 1A95
L_1A97::
        mov    dptr, #T_7013                         ; 1A97
        lcall  i24_ld_code_r1                        ; 1A9A
        mov    r0, #0x4A                             ; 1A9D
        lcall  i24_copy_r1_to_r0                     ; 1A9F
        sjmp   L_1AAF                                ; 1AA2
L_1AA4::
        mov    dptr, #T_7025                         ; 1AA4
        lcall  i24_ld_code_r1                        ; 1AA7
        mov    r0, #0x4A                             ; 1AAA
        lcall  i24_copy_r1_to_r0                     ; 1AAC
L_1AAF::
        ret                                          ; 1AAF

; count -> value -> cal_apply -> count
count_calibrated::
        lcall  fast_mode_drop_digit                  ; 1AB0
        jb     cal_mode, L_1ABF                      ; 1AB3
        lcall  count_to_value                        ; 1AB6
        lcall  cal_apply                             ; 1AB9
        lcall  value_to_count                        ; 1ABC
L_1ABF::
        ret                                          ; 1ABF

meas_prepare_count::
        mov    r0, #0x4F                             ; 1AC0
        mov    a, meter_state                        ; 1AC2
        anl    a, #0x7F                              ; 1AC4
        cjne   a, #0x2A, L_1AF6                      ; 1AC6
        mov    a, 0x14                               ; 1AC9
        cjne   a, #0x09, L_1AD4                      ; 1ACB
        mov    dptr, #0x00FE                         ; 1ACE
        lcall  xdata_clear3                          ; 1AD1
L_1AD4::
        mov    r1, #0x18                             ; 1AD4
        lcall  i24_copy_r1_to_r0                     ; 1AD6
        mov    r1, #0x42                             ; 1AD9
        mov    dptr, #0x00FE                         ; 1ADB
        lcall  i24_ld_xdata_r1                       ; 1ADE
        lcall  i24_sub                               ; 1AE1
        mov    r1, #0x18                             ; 1AE4
        mov    dptr, #0x00FE                         ; 1AE6
        lcall  i24_st_r1_xdata                       ; 1AE9
        mov    r1, #0x43                             ; 1AEC
        mov    0x43, #0x0A                           ; 1AEE
        lcall  i24_div10_rem                         ; 1AF1
        sjmp   L_1AFB                                ; 1AF4
L_1AF6::
        mov    r1, #0x10                             ; 1AF6
        lcall  i24_copy_r1_to_r0                     ; 1AF8
L_1AFB::
        ljmp   count_calibrated                      ; 1AFB

; compare count with 42h (down), 46h (up), 4Ah (overload); step meter_state range by +-0x10
autorange_step::
        lcall  range_param_lookup                    ; 1AFE
        mov    r0, #0x4F                             ; 1B01
        mov    a, @r0                                ; 1B03
        jnb    0xE7, L_1B0E                          ; 1B04
        lcall  i24_abs                               ; 1B07
        setb   0x5A                                  ; 1B0A
        sjmp   L_1B10                                ; 1B0C
L_1B0E::
        clr    0x5A                                  ; 1B0E
L_1B10::
        jb     cal_mode, L_1B54                      ; 1B10
        jnb    meter_autorange, L_1B52               ; 1B13
        jb     0x69, L_1B20                          ; 1B16
        mov    r1, #0x46                             ; 1B19
        lcall  i24_cmp                               ; 1B1B
        jc     L_1B3C                                ; 1B1E
L_1B20::
        lcall  range_can_go_up_saved                 ; 1B20
        mov    r0, #0x4F                             ; 1B23
        jnc    L_1B31                                ; 1B25
        setb   0x13                                  ; 1B27
        mov    a, meter_state                        ; 1B29
        add    a, #0x10                              ; 1B2B
        mov    meter_state, a                        ; 1B2D
        sjmp   L_1B3A                                ; 1B2F
L_1B31::
        mov    r1, #0x4A                             ; 1B31
        lcall  i24_cmp                               ; 1B33
        jc     L_1B3A                                ; 1B36
        setb   0x69                                  ; 1B38
L_1B3A::
        sjmp   L_1B50                                ; 1B3A
L_1B3C::
        mov    r1, #0x42                             ; 1B3C
        lcall  i24_cmp                               ; 1B3E
        jnc    L_1B50                                ; 1B41
        lcall  range_can_go_down                     ; 1B43
        jnc    L_1B50                                ; 1B46
        setb   0x13                                  ; 1B48
        mov    a, meter_state                        ; 1B4A
        add    a, #0xF0                              ; 1B4C
        mov    meter_state, a                        ; 1B4E
L_1B50::
        sjmp   L_1B54                                ; 1B50
L_1B52::
        sjmp   L_1B31                                ; 1B52
L_1B54::
        mov    r0, #0x4F                             ; 1B54
        jnb    0x69, L_1B6D                          ; 1B56
        mov    r1, #0x4A                             ; 1B59
        lcall  i24_copy_r1_to_r0                     ; 1B5B
        mov    a, meter_state                        ; 1B5E
        anl    a, #0x0F                              ; 1B60
        jnz    L_1B6D                                ; 1B62
        jnb    peak_mode_b1, L_1B6D                  ; 1B64
        jnb    peak_mode_b0, L_1B6D                  ; 1B67
        lcall  clc_thunk                             ; 1B6A
L_1B6D::
        jnb    0x5A, L_1B73                          ; 1B6D
        lcall  i24_neg                               ; 1B70
L_1B73::
        ret                                          ; 1B73

; step range, show dashes while ranging
autorange_apply::
        setb   sbit_F0                               ; 1B74
        jnb    0x13, L_1BA5                          ; 1B76
        mov    a, meter_state                        ; 1B79
        anl    a, #0x0F                              ; 1B7B
        cjne   a, #0x0A, L_1B86                      ; 1B7D
        anl    0x35, #0x8F                           ; 1B80
        orl    0x35, #0x60                           ; 1B83
L_1B86::
        lcall  autorange_enter_fast                  ; 1B86
        mov    a, meter_state                        ; 1B89
        anl    a, #0x0F                              ; 1B8B
        cjne   a, #0x0A, L_1B91                      ; 1B8D
L_1B90::
        ret                                          ; 1B90
L_1B91::
        jnb    trigger_pending, L_1B90               ; 1B91
        jb     0x31, L_1B90                          ; 1B94
        mov    dptr, #0x01A3                         ; 1B97
        movx   a, @dptr                              ; 1B9A
        add    a, #0xF6                              ; 1B9B
        jnc    L_1B90                                ; 1B9D
        mov    dptr, #msg_table                      ; 1B9F
        ljmp   lcd_show_message                      ; 1BA2
L_1BA5::
        jnb    0x65, L_1BAE                          ; 1BA5
        lcall  autorange_leave_fast                  ; 1BA8
        setb   0x59                                  ; 1BAB
        ret                                          ; 1BAD
L_1BAE::
        jnb    0x69, L_1BB4                          ; 1BAE
        lcall  meas_stop_and_reset                   ; 1BB1
L_1BB4::
        setb   0x5C                                  ; 1BB4
        ret                                          ; 1BB6

; Vpp: both polarity counts (0x0101/0x0104)
vpp_range_check::
        jnb    0x72, L_1C14                          ; 1BB7
        lcall  meas_prepare_count                    ; 1BBA
        mov    r0, #0x4F                             ; 1BBD
        mov    dptr, #0x0104                         ; 1BBF
        lcall  i24_st_r0_xdata                       ; 1BC2
        mov    0x51, meter_state                     ; 1BC5
        lcall  autorange_step                        ; 1BC8
        jb     0x69, L_1C0F                          ; 1BCB
        jnb    0x13, L_1BDB                          ; 1BCE
        mov    sfr_B, meter_state                    ; 1BD1
        mov    a, 0x51                               ; 1BD4
        clr    c                                     ; 1BD6
        subb   a, sfr_B                              ; 1BD7
        jc     L_1C0F                                ; 1BD9
L_1BDB::
        jnb    0x13, L_1BE7                          ; 1BDB
        clr    0x13                                  ; 1BDE
        mov    meter_state, 0x51                     ; 1BE0
        setb   0x5B                                  ; 1BE3
        sjmp   L_1BE9                                ; 1BE5
L_1BE7::
        clr    0x5B                                  ; 1BE7
L_1BE9::
        mov    r0, #0x4F                             ; 1BE9
        mov    dptr, #0x0101                         ; 1BEB
        lcall  i24_ld_xdata_r0                       ; 1BEE
        lcall  autorange_step                        ; 1BF1
        jb     0x69, L_1C0F                          ; 1BF4
        jnb    0x13, L_1C04                          ; 1BF7
        mov    sfr_B, meter_state                    ; 1BFA
        mov    a, 0x51                               ; 1BFD
        clr    c                                     ; 1BFF
        subb   a, sfr_B                              ; 1C00
        jc     L_1C0F                                ; 1C02
L_1C04::
        jnb    0x13, L_1C0F                          ; 1C04
        jb     0x5B, L_1C0F                          ; 1C07
        clr    0x13                                  ; 1C0A
        mov    meter_state, 0x51                     ; 1C0C
L_1C0F::
        lcall  autorange_apply                       ; 1C0F
        sjmp   L_1C1F                                ; 1C12
L_1C14::
        lcall  meas_prepare_count                    ; 1C14
        mov    r0, #0x4F                             ; 1C17
        mov    dptr, #0x0101                         ; 1C19
        lcall  i24_st_r0_xdata                       ; 1C1C
L_1C1F::
        ret                                          ; 1C1F

; capacitance branch of meas_range_checks
cap_range_check::
        jnb    0x72, L_1C5B                          ; 1C20
        mov    r0, #0x4F                             ; 1C23
        mov    r1, #0x10                             ; 1C25
        lcall  i24_copy_r1_to_r0                     ; 1C27
        mov    r1, #0x42                             ; 1C2A
        mov    dptr, #0x00F6                         ; 1C2C
        lcall  i24_ld_xdata_r1                       ; 1C2F
        lcall  i24_add                               ; 1C32
        lcall  i24_sar1                              ; 1C35
        lcall  count_calibrated                      ; 1C38
        lcall  autorange_step                        ; 1C3B
        setb   sbit_F0                               ; 1C3E
        jnb    0x13, L_1C52                          ; 1C40
        mov    a, meter_state                        ; 1C43
        swap   a                                     ; 1C45
        anl    a, #0x07                              ; 1C46
        add    a, #0xFA                              ; 1C48
        jc     L_1C4F                                ; 1C4A
        ljmp   autorange_enter_fast                  ; 1C4C
L_1C4F::
        ljmp   autorange_leave_fast                  ; 1C4F
L_1C52::
        jnb    0x65, L_1C58                          ; 1C52
        ljmp   autorange_leave_fast                  ; 1C55
L_1C58::
        setb   0x5C                                  ; 1C58
        ret                                          ; 1C5A
L_1C5B::
        mov    r0, #0x10                             ; 1C5B
        mov    dptr, #0x00F6                         ; 1C5D
        ljmp   i24_st_r0_xdata                       ; 1C60

; calls 1BB7/1C20/1AC0/1AFE/1B74 (over/under-range handling?)
meas_range_checks::
        mov    a, meter_state                        ; 1C63
        anl    a, #0x0F                              ; 1C65
        jnz    L_1C74                                ; 1C67
        jnb    peak_mode_b1, L_1C74                  ; 1C69
        jnb    peak_mode_b0, L_1C74                  ; 1C6C
        lcall  vpp_range_check                       ; 1C6F
        sjmp   L_1C85                                ; 1C72
L_1C74::
        cjne   a, #0x09, L_1C7C                      ; 1C74
        lcall  cap_range_check                       ; 1C77
        sjmp   L_1C85                                ; 1C7A
L_1C7C::
        lcall  meas_prepare_count                    ; 1C7C
        lcall  autorange_step                        ; 1C7F
        lcall  autorange_apply                       ; 1C82
L_1C85::
        ret                                          ; 1C85

; function 10 only: gate-time autorange, thresholds 90/103, 900/1003 counts
freq_autorange::
        setb   sbit_F0                               ; 1C86
        mov    r0, #0x10                             ; 1C88
        mov    r1, #0x42                             ; 1C8A
        mov    a, meter_state                        ; 1C8C
        swap   a                                     ; 1C8E
        anl    a, #0x07                              ; 1C8F
        mov    r7, a                                 ; 1C91
        jb     meter_autorange, L_1C98               ; 1C92
        ljmp   L_1D6D                                ; 1C95
L_1C98::
        clr    0x5B                                  ; 1C98
        mov    a, 0x35                               ; 1C9A
        swap   a                                     ; 1C9C
        anl    a, #0x07                              ; 1C9D
        mov    dptr, #L_1CA3-2                       ; 1C9F
        jmp    @a+dptr                               ; 1CA2
L_1CA3::
        sjmp   L_1CA9                                ; 1CA3
L_1CA5::
        sjmp   L_1CFC                                ; 1CA5
L_1CA7::
        sjmp   L_1CAC                                ; 1CA7
L_1CA9::
        ljmp   L_1D24                                ; 1CA9
L_1CAC::
        mov    dptr, #T_7004                         ; 1CAC
        lcall  i24_ld_code_r1                        ; 1CAF
        lcall  i24_cmp                               ; 1CB2
        jnc    L_1CC5                                ; 1CB5
        mov    dptr, #T_7001                         ; 1CB7
        lcall  i24_ld_code_r1                        ; 1CBA
        lcall  i24_cmp                               ; 1CBD
        jc     L_1CD4                                ; 1CC0
        cjne   r7, #0x06, L_1CD4                     ; 1CC2
L_1CC5::
        cjne   r7, #0x06, L_1CCA                     ; 1CC5
        sjmp   L_1CD0                                ; 1CC8
L_1CCA::
        anl    meter_state, #0x8F                    ; 1CCA
        orl    meter_state, #0x60                    ; 1CCD
L_1CD0::
        setb   0x5B                                  ; 1CD0
        sjmp   L_1CFA                                ; 1CD2
L_1CD4::
        mov    dptr, #T_6FF8                         ; 1CD4
        lcall  i24_ld_code_r1                        ; 1CD7
        lcall  i24_cmp                               ; 1CDA
        jnc    L_1CED                                ; 1CDD
        mov    dptr, #T_6FF5                         ; 1CDF
        lcall  i24_ld_code_r1                        ; 1CE2
        lcall  i24_cmp                               ; 1CE5
        jc     L_1CFA                                ; 1CE8
        cjne   r7, #0x05, L_1CFA                     ; 1CEA
L_1CED::
        cjne   r7, #0x05, L_1CF2                     ; 1CED
        sjmp   L_1CF8                                ; 1CF0
L_1CF2::
        anl    meter_state, #0x8F                    ; 1CF2
        orl    meter_state, #0x50                    ; 1CF5
L_1CF8::
        setb   0x5B                                  ; 1CF8
L_1CFA::
        sjmp   L_1D59                                ; 1CFA
L_1CFC::
        mov    dptr, #T_6FF8                         ; 1CFC
        lcall  i24_ld_code_r1                        ; 1CFF
        lcall  i24_cmp                               ; 1D02
        jnc    L_1D15                                ; 1D05
        mov    dptr, #T_6FF5                         ; 1D07
        lcall  i24_ld_code_r1                        ; 1D0A
        lcall  i24_cmp                               ; 1D0D
        jc     L_1D22                                ; 1D10
        cjne   r7, #0x04, L_1D22                     ; 1D12
L_1D15::
        cjne   r7, #0x04, L_1D1A                     ; 1D15
        sjmp   L_1D20                                ; 1D18
L_1D1A::
        anl    meter_state, #0x8F                    ; 1D1A
        orl    meter_state, #0x40                    ; 1D1D
L_1D20::
        setb   0x5B                                  ; 1D20
L_1D22::
        sjmp   L_1D59                                ; 1D22
L_1D24::
        setb   0x5B                                  ; 1D24
        mov    dptr, #T_6FF8                         ; 1D26
        lcall  i24_ld_code_r1                        ; 1D29
        lcall  i24_cmp                               ; 1D2C
        jnc    L_1D3F                                ; 1D2F
        mov    dptr, #T_6FF5                         ; 1D31
        lcall  i24_ld_code_r1                        ; 1D34
        lcall  i24_cmp                               ; 1D37
        jc     L_1D4C                                ; 1D3A
        cjne   r7, #0x03, L_1D4C                     ; 1D3C
L_1D3F::
        cjne   r7, #0x03, L_1D44                     ; 1D3F
        sjmp   L_1D4A                                ; 1D42
L_1D44::
        anl    meter_state, #0x8F                    ; 1D44
        orl    meter_state, #0x30                    ; 1D47
L_1D4A::
        sjmp   L_1D59                                ; 1D4A
L_1D4C::
        cjne   r7, #0x02, L_1D51                     ; 1D4C
        sjmp   L_1D59                                ; 1D4F
L_1D51::
        anl    meter_state, #0x8F                    ; 1D51
        orl    meter_state, #0x20                    ; 1D54
        setb   0x59                                  ; 1D57
L_1D59::
        jnb    0x5B, L_1D61                          ; 1D59
        lcall  autorange_leave_fast                  ; 1D5C
        sjmp   L_1D6A                                ; 1D5F
L_1D61::
        mov    a, 0x35                               ; 1D61
        add    a, #0xE0                              ; 1D63
        mov    0x35, a                               ; 1D65
        lcall  autorange_enter_fast                  ; 1D67
L_1D6A::
        ljmp   L_1DE6                                ; 1D6A
L_1D6D::
        mov    a, 0x35                               ; 1D6D
        swap   a                                     ; 1D6F
        anl    a, #0x07                              ; 1D70
        mov    r6, a                                 ; 1D72
        mov    a, r7                                 ; 1D73
        rl     a                                     ; 1D74
L_1D75::
        mov    dptr, #L_1D75                         ; 1D75
        jmp    @a+dptr                               ; 1D78
L_1D79::
        sjmp   L_1D83                                ; 1D79
L_1D7B::
        sjmp   L_1D83                                ; 1D7B
L_1D7D::
        sjmp   L_1DB7                                ; 1D7D
L_1D7F::
        sjmp   L_1DC6                                ; 1D7F
L_1D81::
        sjmp   L_1DC6                                ; 1D81
L_1D83::
        cjne   r6, #0x06, L_1DA0                     ; 1D83
        mov    dptr, #T_6FFE                         ; 1D86
        lcall  i24_ld_code_r1                        ; 1D89
        lcall  i24_cmp                               ; 1D8C
        jc     L_1D95                                ; 1D8F
        setb   0x69                                  ; 1D91
        sjmp   L_1D9E                                ; 1D93
L_1D95::
        anl    0x35, #0x8F                           ; 1D95
        orl    0x35, #0x40                           ; 1D98
        lcall  autorange_enter_fast                  ; 1D9B
L_1D9E::
        sjmp   L_1DC9                                ; 1D9E
L_1DA0::
        cjne   r7, #0x02, L_1DA8                     ; 1DA0
        mov    dptr, #T_6FF2                         ; 1DA3
        sjmp   L_1DAB                                ; 1DA6
L_1DA8::
        mov    dptr, #T_6FFE                         ; 1DA8
L_1DAB::
        lcall  i24_ld_code_r1                        ; 1DAB
        lcall  i24_cmp                               ; 1DAE
        jc     L_1DC6                                ; 1DB1
        setb   0x69                                  ; 1DB3
        sjmp   L_1DC9                                ; 1DB5
L_1DB7::
        mov    dptr, #T_6FFE                         ; 1DB7
        lcall  i24_ld_code_r1                        ; 1DBA
        lcall  i24_cmp                               ; 1DBD
        jc     L_1DC6                                ; 1DC0
        setb   0x69                                  ; 1DC2
        sjmp   L_1DC9                                ; 1DC4
L_1DC6::
        lcall  autorange_leave_fast                  ; 1DC6
L_1DC9::
        jnb    0x69, L_1DE6                          ; 1DC9
        lcall  meas_stop_and_reset                   ; 1DCC
        lcall  range_param_lookup                    ; 1DCF
        mov    r0, #0x10                             ; 1DD2
        mov    r1, #0x4A                             ; 1DD4
        lcall  i24_copy_r1_to_r0                     ; 1DD6
        lcall  count_to_value                        ; 1DD9
        jnb    cal_mode, L_1DE6                      ; 1DDC
        clr    0x69                                  ; 1DDF
        mov    a, #0x14                              ; 1DE1
        lcall  cal_fail                              ; 1DE3
L_1DE6::
        ret                                          ; 1DE6

; count jump > 10 (VDC, degC) or > 1000: restart averaging
input_step_detect::
        jb     speed_b0, L_1DF2                      ; 1DE7
        jb     speed_b1, L_1DF2                      ; 1DEA
        anl    a, #0x0F                              ; 1DED
        cjne   a, #0x0A, L_1DF9                      ; 1DEF
L_1DF2::
        mov    a, meter_state                        ; 1DF2
        anl    a, #0x7F                              ; 1DF4
        cjne   a, #0x2A, L_1E6A                      ; 1DF6
L_1DF9::
        mov    r0, #0x42                             ; 1DF9
        mov    r1, #0x4F                             ; 1DFB
        lcall  i24_copy_r1_to_r0                     ; 1DFD
        mov    r1, #0x46                             ; 1E00
        mov    dptr, #x_prev_count                   ; 1E02
        lcall  i24_ld_xdata_r1                       ; 1E05
        lcall  i24_sub                               ; 1E08
        lcall  i24_abs                               ; 1E0B
        mov    a, meter_state                        ; 1E0E
        anl    a, #0x0F                              ; 1E10
        cjne   a, #0x01, L_1E1A                      ; 1E12
        mov    dptr, #T_7034                         ; 1E15
        sjmp   L_1E25                                ; 1E18
L_1E1A::
        cjne   a, #0x0B, L_1E22                      ; 1E1A
        mov    dptr, #T_7037                         ; 1E1D
        sjmp   L_1E25                                ; 1E20
L_1E22::
        mov    dptr, #T_703A                         ; 1E22
L_1E25::
        mov    r1, #0x4A                             ; 1E25
        lcall  i24_ld_code_r1                        ; 1E27
        mov    r0, #0x42                             ; 1E2A
        lcall  i24_cmp                               ; 1E2C
        jc     L_1E60                                ; 1E2F
        jnb    0x63, L_1E45                          ; 1E31
        mov    r0, #0x4F                             ; 1E34
        mov    dptr, #x_prev_count                   ; 1E36
        lcall  i24_st_r0_xdata                       ; 1E39
        setb   sbit_F0                               ; 1E3C
        lcall  autorange_count_step                  ; 1E3E
        setb   0x59                                  ; 1E41
        sjmp   L_1E5E                                ; 1E43
L_1E45::
        setb   0x63                                  ; 1E45
        mov    a, meter_state                        ; 1E47
        anl    a, #0x0F                              ; 1E49
        cjne   a, #0x01, L_1E50                      ; 1E4B
        sjmp   L_1E53                                ; 1E4E
L_1E50::
        cjne   a, #0x0B, L_1E5E                      ; 1E50
L_1E53::
        clr    0x5C                                  ; 1E53
        inc    0x14                                  ; 1E55
        jnb    0x72, L_1E5E                          ; 1E57
        clr    0x72                                  ; 1E5A
        setb   0x71                                  ; 1E5C
L_1E5E::
        sjmp   L_1E6A                                ; 1E5E
L_1E60::
        clr    0x63                                  ; 1E60
        mov    r0, #0x4F                             ; 1E62
        mov    dptr, #x_prev_count                   ; 1E64
        lcall  i24_st_r0_xdata                       ; 1E67
L_1E6A::
        ret                                          ; 1E6A

; >9 unstable readings (29 in cal mode) -> 'R'
meas_check_settled::
        mov    a, 0x34                               ; 1E6B
        jnb    cal_mode, L_1E74                      ; 1E6D
        add    a, #0xE2                              ; 1E70
        sjmp   L_1E76                                ; 1E72
L_1E74::
        add    a, #0xF6                              ; 1E74
L_1E76::
        jnc    L_1E7F                                ; 1E76
        setb   sbit_F0                               ; 1E78
        lcall  meas_stop_and_reset                   ; 1E7A
        setb   0x5E                                  ; 1E7D
L_1E7F::
        ret                                          ; 1E7F

; Callendar-Van Dusen inversion with fp_sqrt (constants 0x7071/0x7075/0x7079)
pt100_r_to_temp::
        mov    r0, #0x50                             ; 1E80
        mov    r1, #0x5B                             ; 1E82
        mov    dptr, #T_7071                         ; 1E84
        lcall  fp_ld_code_r1                         ; 1E87
        lcall  fp_mul                                ; 1E8A
        mov    dptr, #T_7075                         ; 1E8D
        lcall  fp_ld_code_r1                         ; 1E90
        lcall  fp_rsub                               ; 1E93
        mov    a, #0x03                              ; 1E96
        lcall  fp_sqrt                               ; 1E98
        mov    dptr, #T_7079                         ; 1E9B
        lcall  fp_ld_code_r1                         ; 1E9E
        ljmp   fp_rsub                               ; 1EA1

; SPEED 1 summing (0x0101/0x0104), digit drop, filter, cal_apply, count_to_value, cal step
meas_postprocess::
        jb     speed_b0, L_1ECB                      ; 1EA4
        jb     speed_b1, L_1ECB                      ; 1EA7
        mov    a, meter_state                        ; 1EAA
        anl    a, #0x0F                              ; 1EAC
        xrl    a, #0x0A                              ; 1EAE
        jz     L_1ECB                                ; 1EB0
        mov    r0, #0x42                             ; 1EB2
        mov    dptr, #0x00F6                         ; 1EB4
        lcall  i24_ld_xdata_r0                       ; 1EB7
        mov    r1, #0x46                             ; 1EBA
        mov    dptr, #0x0107                         ; 1EBC
        lcall  i24_ld_xdata_r1                       ; 1EBF
        lcall  i24_add                               ; 1EC2
        mov    dptr, #0x00F6                         ; 1EC5
        lcall  i24_st_r0_xdata                       ; 1EC8
L_1ECB::
        jnb    0x72, L_1ED4                          ; 1ECB
        jb     0x69, L_1ED4                          ; 1ECE
        jnb    0x5E, L_1ED7                          ; 1ED1
L_1ED4::
        ljmp   L_1FDA                                ; 1ED4
L_1ED7::
        mov    r0, #0x4F                             ; 1ED7
        jb     speed_b0, L_1EE6                      ; 1ED9
        jb     speed_b1, L_1EE6                      ; 1EDC
        mov    a, meter_state                        ; 1EDF
        anl    a, #0x0F                              ; 1EE1
        cjne   a, #0x0A, L_1EF7                      ; 1EE3
L_1EE6::
        mov    a, meter_state                        ; 1EE6
        anl    a, #0x7F                              ; 1EE8
        cjne   a, #0x2A, L_1F41                      ; 1EEA
        mov    r1, #0x10                             ; 1EED
        lcall  i24_copy_r1_to_r0                     ; 1EEF
        lcall  fast_mode_drop_digit                  ; 1EF2
        sjmp   L_1F0A                                ; 1EF5
L_1EF7::
        mov    dptr, #0x00F6                         ; 1EF7
        lcall  i24_ld_xdata_r0                       ; 1EFA
        lcall  meas_digital_filter                   ; 1EFD
        lcall  meas_offset_select                    ; 1F00
        mov    r0, #0x4F                             ; 1F03
        mov    r1, #0x42                             ; 1F05
        lcall  i24_sub                               ; 1F07
L_1F0A::
        jb     cal_mode, L_1F41                      ; 1F0A
        lcall  count_to_value                        ; 1F0D
        jb     speed_b0, L_1F3B                      ; 1F10
        jb     speed_b1, L_1F3B                      ; 1F13
        mov    a, meter_state                        ; 1F16
        anl    a, #0x0F                              ; 1F18
        xrl    a, #0x0A                              ; 1F1A
        jz     L_1F3B                                ; 1F1C
        mov    r0, #0x50                             ; 1F1E
        mov    r1, #0x43                             ; 1F20
        mov    a, #0x01                              ; 1F22
        lcall  fp_ld_pow10_r1                        ; 1F24
        lcall  fp_div                                ; 1F27
        lcall  cal_apply                             ; 1F2A
        mov    r0, #0x50                             ; 1F2D
        mov    r1, #0x43                             ; 1F2F
        mov    a, #0x01                              ; 1F31
        lcall  fp_ld_pow10_r1                        ; 1F33
        lcall  fp_mul                                ; 1F36
        sjmp   L_1F3E                                ; 1F39
L_1F3B::
        lcall  cal_apply                             ; 1F3B
L_1F3E::
        lcall  value_to_count                        ; 1F3E
L_1F41::
        mov    r0, #0x4F                             ; 1F41
        mov    a, meter_state                        ; 1F43
        anl    a, #0x0F                              ; 1F45
        jnz    L_1F60                                ; 1F47
        jnb    peak_mode_b1, L_1F60                  ; 1F49
        jnb    peak_mode_b0, L_1F60                  ; 1F4C
        mov    dptr, #0x0101                         ; 1F4F
        lcall  i24_ld_xdata_r0                       ; 1F52
        mov    r1, #0x42                             ; 1F55
        mov    dptr, #0x0104                         ; 1F57
        lcall  i24_ld_xdata_r1                       ; 1F5A
        lcall  i24_add                               ; 1F5D
L_1F60::
        mov    a, meter_state                        ; 1F60
        anl    a, #0x0F                              ; 1F62
        jz     L_1F75                                ; 1F64
        cjne   a, #0x08, L_1F6B                      ; 1F66
        sjmp   L_1F9F                                ; 1F69
L_1F6B::
        cjne   a, #0x0A, L_1F70                      ; 1F6B
        sjmp   L_1F9F                                ; 1F6E
L_1F70::
        cjne   a, #0x0D, L_1F75                      ; 1F70
        sjmp   L_1F9F                                ; 1F73
L_1F75::
        jb     cal_mode, L_1F7E                      ; 1F75
        jb     0x0A, L_1F9F                          ; 1F78
        jb     0x0B, L_1F9F                          ; 1F7B
L_1F7E::
        mov    a, meter_state                        ; 1F7E
        anl    a, #0x0F                              ; 1F80
        cjne   a, #0x0A, L_1F88                      ; 1F82
        jb     speed_b0, L_1F8B                      ; 1F85
L_1F88::
        jnb    speed_b1, L_1F99                      ; 1F88
L_1F8B::
        mov    r1, #0x42                             ; 1F8B
        mov    0x40, #0x0A                           ; 1F8D
        mov    0x41, #0x00                           ; 1F90
        mov    range_lim_down, #0x00                 ; 1F93
        lcall  i24_div_signed                        ; 1F96
L_1F99::
        lcall  display_stabilize                     ; 1F99
        lcall  fast_mode_drop_digit                  ; 1F9C
L_1F9F::
        lcall  count_to_value                        ; 1F9F
        jb     speed_b0, L_1FBC                      ; 1FA2
        jb     speed_b1, L_1FBC                      ; 1FA5
        mov    a, meter_state                        ; 1FA8
        anl    a, #0x0F                              ; 1FAA
        xrl    a, #0x0A                              ; 1FAC
        jz     L_1FBC                                ; 1FAE
        mov    r0, #0x50                             ; 1FB0
        mov    r1, #0x43                             ; 1FB2
        mov    a, #0x01                              ; 1FB4
        lcall  fp_ld_pow10_r1                        ; 1FB6
        lcall  fp_div                                ; 1FB9
L_1FBC::
        jnb    cal_mode, L_1FD8                      ; 1FBC
        jnb    trigger_pending, L_1FD8               ; 1FBF
        lcall  cal_step_zero                         ; 1FC2
        jnb    0x72, L_1FD6                          ; 1FC5
        jb     0x64, L_1FD4                          ; 1FC8
        lcall  cal_load_range                        ; 1FCB
        lcall  cal_compute_effective                 ; 1FCE
        lcall  cal_apply                             ; 1FD1
L_1FD4::
        sjmp   L_1FD8                                ; 1FD4
L_1FD6::
        clr    0x5C                                  ; 1FD6
L_1FD8::
        sjmp   L_1FEF                                ; 1FD8
L_1FDA::
        jnb    cal_mode, L_1FEC                      ; 1FDA
        jb     0x69, L_1FE3                          ; 1FDD
        jnb    0x5E, L_1FEC                          ; 1FE0
L_1FE3::
        mov    a, #0x15                              ; 1FE3
        lcall  cal_fail                              ; 1FE5
        clr    0x69                                  ; 1FE8
        clr    0x5E                                  ; 1FEA
L_1FEC::
        lcall  count_to_value                        ; 1FEC
L_1FEF::
        ret                                          ; 1FEF

; function-specific conversion (Pt-100 -> degC via pt100_r_to_temp, peak sign)
result_convert_function::
        mov    a, meter_state                        ; 1FF0
        anl    a, #0x0F                              ; 1FF2
        jnz    L_1FFB                                ; 1FF4
        jb     peak_mode_b0, L_200F                  ; 1FF6
        sjmp   L_2007                                ; 1FF9
L_1FFB::
        jb     0x03, L_2003                          ; 1FFB
        cjne   a, #0x01, L_2007                      ; 1FFE
        sjmp   L_200F                                ; 2001
L_2003::
        add    a, #0xF5                              ; 2003
        jnc    L_200F                                ; 2005
L_2007::
        mov    a, 0x50                               ; 2007
        jz     L_200F                                ; 2009
        cpl    0xE7                                  ; 200B
        mov    0x50, a                               ; 200D
L_200F::
        jb     cal_enable, L_2037                    ; 200F
        mov    a, meter_state                        ; 2012
        anl    a, #0x0F                              ; 2014
        cjne   a, #0x01, L_201B                      ; 2016
        sjmp   L_2037                                ; 2019
L_201B::
        cjne   a, #0x06, L_2020                      ; 201B
        sjmp   L_2037                                ; 201E
L_2020::
        jnz    L_202F                                ; 2020
        jb     peak_mode_b0, L_202F                  ; 2022
        mov    a, 0x50                               ; 2025
        jb     0xE7, L_202D                          ; 2027
        mov    0x50, #0x00                           ; 202A
L_202D::
        sjmp   L_2037                                ; 202D
L_202F::
        mov    a, 0x50                               ; 202F
        jnb    0xE7, L_2037                          ; 2031
        mov    0x50, #0x00                           ; 2034
L_2037::
        mov    a, meter_state                        ; 2037
        anl    a, #0x0F                              ; 2039
        cjne   a, #0x0B, L_2041                      ; 203B
        lcall  pt100_r_to_temp                       ; 203E
L_2041::
        mov    r0, #0x50                             ; 2041
        mov    r1, #0x55                             ; 2043
        ljmp   fp_copy_r0_to_r1                      ; 2045
L_2048::
        clr    0x62                                  ; 2048
        jnb    0x72, L_208A                          ; 204A
        jb     0x1C, L_2083                          ; 204D
        jb     0x6E, L_2083                          ; 2050
        jb     0x6B, L_2083                          ; 2053
        push   0x30                                  ; 2056
        push   0x31                                  ; 2058
        lcall  out_format_params_a                   ; 205A
        mov    0x40, 0x30                            ; 205D
        mov    0x41, 0x31                            ; 2060
        mov    range_lim_down, #0x00                 ; 2063
        pop    0x31                                  ; 2066
        pop    0x30                                  ; 2068
        mov    r0, #0x42                             ; 206A
        mov    r1, #0x43                             ; 206C
        mov    @r1, #0x0A                            ; 206E
        lcall  i24_div10_rem                         ; 2070
        mov    r1, #0x42                             ; 2073
        mov    r0, #0x33                             ; 2075
        lcall  i24_cmp                               ; 2077
        jc     L_2083                                ; 207A
        lcall  i24_clr_r0                            ; 207C
        setb   0x6E                                  ; 207F
        setb   0x13                                  ; 2081
L_2083::
        clr    sbit_F0                               ; 2083
        lcall  autorange_reset                       ; 2085
        sjmp   L_208F                                ; 2088
L_208A::
        jnb    0x71, L_208F                          ; 208A
        setb   0x61                                  ; 208D
L_208F::
        ljmp   meas_exit                             ; 208F

; process finished conversion: scale, autorange, filter, store
meas_phase_process::
        lcall  meas_scale_result                     ; 2092
        jb     0x29, L_209E                          ; 2095
        jb     0x6B, L_209E                          ; 2098
        jnb    0x6E, L_20A4                          ; 209B
L_209E::
        lcall  meas_process_special                  ; 209E
        ljmp   L_211A                                ; 20A1
L_20A4::
        mov    a, meter_state                        ; 20A4
        anl    a, #0x0F                              ; 20A6
        cjne   a, #0x08, L_20B1                      ; 20A8
        lcall  meas_process_time                     ; 20AB
        ljmp   L_20D9                                ; 20AE
L_20B1::
        jnb    0x65, L_20BD                          ; 20B1
        cjne   a, #0x0A, L_20BD                      ; 20B4
        lcall  freq_autorange                        ; 20B7
        ljmp   L_20D5                                ; 20BA
L_20BD::
        lcall  meas_range_checks                     ; 20BD
        jnb    0x5C, L_20D5                          ; 20C0
        jb     0x69, L_20C9                          ; 20C3
        lcall  input_step_detect                     ; 20C6
L_20C9::
        jb     0x5C, L_20CF                          ; 20C9
        lcall  meas_check_settled                    ; 20CC
L_20CF::
        jnb    0x5C, L_20D5                          ; 20CF
        lcall  meas_postprocess                      ; 20D2
L_20D5::
        mov    c, 0x5C                               ; 20D5
        mov    0x5F, c                               ; 20D7
L_20D9::
        jnb    0x5F, L_211A                          ; 20D9
        lcall  result_convert_function               ; 20DC
        lcall  result_apply_db_rel                   ; 20DF
        lcall  result_store                          ; 20E2
        jnb    trigger_pending, L_211A               ; 20E5
        jnb    0x5C, L_211A                          ; 20E8
        jb     0x26, L_211A                          ; 20EB
        jb     0x72, L_210B                          ; 20EE
        jnb    0x59, L_211A                          ; 20F1
        jb     cal_mode, L_211A                      ; 20F4
        jb     speed_b0, L_20FD                      ; 20F7
        jnb    speed_b1, L_210B                      ; 20FA
L_20FD::
        mov    a, meter_state                        ; 20FD
        anl    a, #0x7F                              ; 20FF
        cjne   a, #0x2A, L_2106                      ; 2101
        sjmp   L_210B                                ; 2104
L_2106::
        anl    a, #0x0F                              ; 2106
        cjne   a, #0x08, L_211A                      ; 2108
L_210B::
        lcall  meas_build_status                     ; 210B
        jnb    0x72, L_2117                          ; 210E
        jb     cal_mode, L_2117                      ; 2111
        lcall  minmax_update                         ; 2114
L_2117::
        lcall  meas_result_complete                  ; 2117
L_211A::
        ljmp   L_2048                                ; 211A

; A = event id: ++XDATA[0x0772+A], ++XDATA[0x076C]. 0x0A,0x0B (ADC timeout),0x0C (no phase)
diag_count_event::
        push   sfr_DPL                               ; 211D
        push   sfr_DPH                               ; 211F
        mov    dptr, #x_diag_event_counters          ; 2121
        add    a, sfr_DPL                            ; 2124
        mov    sfr_DPL, a                            ; 2126
        clr    a                                     ; 2128
        addc   a, sfr_DPH                            ; 2129
        mov    sfr_DPH, a                            ; 212B
        movx   a, @dptr                              ; 212D
        inc    a                                     ; 212E
        movx   @dptr, a                              ; 212F
        mov    dptr, #x_diag_err_total               ; 2130
        movx   a, @dptr                              ; 2133
        inc    a                                     ; 2134
        movx   @dptr, a                              ; 2135
        pop    sfr_DPH                               ; 2136
        pop    sfr_DPL                               ; 2138
        ret                                          ; 213A

; start acquisition; branches per function: 0->2201, 8->238C, 9->23E1, 10->24FF, else ADC 22CE
meas_phase_acquire::
        jb     0x71, L_2185                          ; 213B
        jnb    0x72, L_214B                          ; 213E
        clr    0x61                                  ; 2141
        mov    a, #0x0A                              ; 2143
        lcall  diag_count_event                      ; 2145
        ljmp   meas_restart                          ; 2148
L_214B::
        mov    dptr, #0x00F6                         ; 214B
        lcall  xdata_clear3                          ; 214E
        mov    a, #0x00                              ; 2151
        jb     0x0A, L_215D                          ; 2153
        jb     0x0B, L_215D                          ; 2156
        jbc    0x67, L_215D                          ; 2159
        inc    a                                     ; 215C
L_215D::
        mov    r1, #0x11                             ; 215D
        lcall  fp_ld_pow10_r1                        ; 215F
        mov    dptr, #0x0112                         ; 2162
        lcall  fp_st_r1_xdata                        ; 2165
        mov    dptr, #T_6F69                         ; 2168
        lcall  fp_ld_code_r1                         ; 216B
        mov    dptr, #0x010A                         ; 216E
        lcall  fp_st_r1_xdata                        ; 2171
        clr    a                                     ; 2174
        lcall  fp_ld_pow10_r1                        ; 2175
        mov    dptr, #0x010E                         ; 2178
        lcall  fp_st_r1_xdata                        ; 217B
        lcall  i24_clr_r1                            ; 217E
        clr    0x69                                  ; 2181
        clr    0x68                                  ; 2183
L_2185::
        jb     0x29, L_21BF                          ; 2185
        jb     0x6B, L_2199                          ; 2188
        jnb    0x6E, L_2193                          ; 218B
        jb     0x6C, L_21AE                          ; 218E
        sjmp   L_2199                                ; 2191
L_2193::
        mov    a, meter_state                        ; 2193
        anl    a, #0x0F                              ; 2195
        jnz    L_219C                                ; 2197
L_2199::
        ljmp   acq_vpeak                             ; 2199
L_219C::
        cjne   a, #0x08, L_21A2                      ; 219C
        ljmp   acq_time                              ; 219F
L_21A2::
        cjne   a, #0x09, L_21A8                      ; 21A2
        ljmp   acq_cap                               ; 21A5
L_21A8::
        cjne   a, #0x0A, L_21AE                      ; 21A8
        ljmp   acq_freq                              ; 21AB
L_21AE::
        ljmp   acq_adc                               ; 21AE

; cmd 0x8B if 26h.6 else adc_start_cycle
adc_start_cycle_alt::
        jnb    adc_alt_mode, L_21BC                  ; 21B1
        mov    a, #0x8B                              ; 21B4
        lcall  i2cB_start                            ; 21B6
        ljmp   i2cB_stop                             ; 21B9
L_21BC::
        ljmp   adc_start_cycle                       ; 21BC
L_21BF::
        jb     0x71, L_21C8                          ; 21BF
        lcall  freq_gate_setup                       ; 21C2
L_21C5::
        ljmp   meas_exit                             ; 21C5
L_21C8::
        jb     0x28, L_21C5                          ; 21C8
        mov    adc_count_hi, adc_count_mid           ; 21CB
        mov    adc_count_mid, sfr_TH0                ; 21CE
        mov    adc_count_lo, sfr_TL0                 ; 21D1
        ljmp   acq_done                              ; 21D4

; INT1 edge gate + T0/T1 for time/frequency functions
freq_gate_setup::
        mov    r6, #0xE0                             ; 21D7
        mov    r5, #0x43                             ; 21D9
        clr    sbit_F0                               ; 21DB
        lcall  adc_set_times                         ; 21DD
        anl    sfr_TMOD, #0xF1                       ; 21E0
        orl    sfr_TMOD, #0x01                       ; 21E3
        anl    sfr_TCON, #0xC7                       ; 21E6
        setb   sbit_IT1                              ; 21E9
        clr    sbit_PT0                              ; 21EB
        setb   sbit_PX1                              ; 21ED
        mov    sfr_TL0, #0x00                        ; 21EF
        mov    sfr_TH0, #0x00                        ; 21F2
        lcall  adc_arm_timeout                       ; 21F5
        lcall  adc_start_cycle_alt                   ; 21F8
        setb   sbit_TR0                              ; 21FB
        orl    sfr_IE, #0x86                         ; 21FD
        ret                                          ; 2200

; Vpeak: T1=T2=0xF9A7, latch b5/b4 = +/- peak detector, up to 10 repeats, Vpp = both polarities
acq_vpeak::
        jnb    0x71, L_2213                          ; 2201
        jnb    0x28, L_220A                          ; 2204
        ljmp   L_2296                                ; 2207
L_220A::
        mov    c, peak_mode_b1                       ; 220A
        mov    sbit_F0, c                            ; 220C
        cpl    peak_mode_b1                          ; 220E
        ljmp   L_2239                                ; 2210
L_2213::
        mov    0x14, #0x01                           ; 2213
        jb     0x6B, L_221C                          ; 2216
        jnb    0x6E, L_222C                          ; 2219
L_221C::
        mov    r6, #0xF9                             ; 221C
        mov    r5, #0xA7                             ; 221E
        mov    0x17, #0x02                           ; 2220
        mov    a, adc_latch_byte                     ; 2223
        clr    0xE5                                  ; 2225
        clr    0xE4                                  ; 2227
        ljmp   L_2256                                ; 2229
L_222C::
        jnb    peak_mode_b1, L_2235                  ; 222C
        jnb    peak_mode_b0, L_2235                  ; 222F
        mov    0x14, #0x02                           ; 2232
L_2235::
        mov    c, peak_mode_b1                       ; 2235
        mov    sbit_F0, c                            ; 2237
L_2239::
        mov    r6, #0xF9                             ; 2239
        mov    r5, #0xA7                             ; 223B
        mov    0x17, #0x0A                           ; 223D
        jb     peak_mode_b1, L_224C                  ; 2240
        mov    a, adc_latch_byte                     ; 2243
        setb   0xE5                                  ; 2245
        clr    0xE4                                  ; 2247
        ljmp   L_2252                                ; 2249
L_224C::
        mov    a, adc_latch_byte                     ; 224C
        clr    0xE5                                  ; 224E
        setb   0xE4                                  ; 2250
L_2252::
        mov    c, sbit_F0                            ; 2252
        mov    peak_mode_b1, c                       ; 2254
L_2256::
        mov    adc_latch_byte, a                     ; 2256
        lcall  adc_write_latches                     ; 2258
        clr    sbit_F0                               ; 225B
        lcall  adc_set_times                         ; 225D
        mov    r0, #0x10                             ; 2260
        lcall  i24_clr_r0                            ; 2262
        anl    sfr_IE, #0xF9                         ; 2265
        anl    sfr_TMOD, #0xF5                       ; 2268
        orl    sfr_TMOD, #0x05                       ; 226B
        anl    sfr_TCON, #0xCF                       ; 226E
        mov    sfr_TL0, #0xFF                        ; 2271
        mov    sfr_TH0, #0xFF                        ; 2274
        lcall  adc_arm_timeout                       ; 2277
        orl    shiftreg_out0, #0x40                  ; 227A
        lcall  shiftreg_write_analog                 ; 227D
        lcall  key_debounce_delay                    ; 2280
        anl    shiftreg_out0, #0xBF                  ; 2283
        lcall  shiftreg_write_analog                 ; 2286
        mov    r2, #0x02                             ; 2289
        mov    r3, #0xF4                             ; 228B
L_228D::
        djnz   r3, L_228D                            ; 228D
        djnz   r2, L_228D                            ; 228F
        lcall  adc_start_cycle_alt                   ; 2291
        setb   sbit_TR0                              ; 2294
L_2296::
        jb     sbit_TF0, L_229C                      ; 2296
        jb     sbit_T0, L_22B1                       ; 2299
L_229C::
        clr    sbit_TF0                              ; 229C
        mov    sfr_TL0, #0xFF                        ; 229E
        mov    sfr_TH0, #0xFF                        ; 22A1
        mov    sfr_P1, #0xD7                         ; 22A4
        nop                                          ; 22A7
        nop                                          ; 22A8
        mov    sfr_P1, #0xE7                         ; 22A9
        mov    r0, #0x10                             ; 22AC
        lcall  i24_inc_r0                            ; 22AE
L_22B1::
        jnb    sbit_INT1, L_22BC                     ; 22B1
        sjmp   L_2296                                ; 22B4
L_22B6::
        lcall  adc_start_cycle_alt                   ; 22B6
        ljmp   meas_exit                             ; 22B9
L_22BC::
        djnz   0x17, L_22B6                          ; 22BC
        clr    sbit_TR0                              ; 22BF
        clr    0x73                                  ; 22C1
        clr    0x28                                  ; 22C3
        djnz   0x14, L_22CB                          ; 22C5
        ljmp   acq_done                              ; 22C8
L_22CB::
        ljmp   L_24F8                                ; 22CB

; default ADC path; AC functions first run a two-phase RMS auto-zero (latch b6 / shiftreg 08h b7)
acq_adc::
        jnb    0x71, L_22DA                          ; 22CE
        jnb    0x28, L_22D7                          ; 22D1
        ljmp   adc_wait_ready_read                   ; 22D4
L_22D7::
        ljmp   L_2349                                ; 22D7
L_22DA::
        jb     0x6E, L_231C                          ; 22DA
        mov    a, meter_state                        ; 22DD
        anl    a, #0x0F                              ; 22DF
        cjne   a, #0x02, L_22E6                      ; 22E1
        sjmp   L_22EE                                ; 22E4
L_22E6::
        cjne   a, #0x03, L_22EB                      ; 22E6
        sjmp   L_22EE                                ; 22E9
L_22EB::
        cjne   a, #0x07, L_231C                      ; 22EB
L_22EE::
        jbc    0x78, L_2308                          ; 22EE
        jbc    0x79, L_231C                          ; 22F1
        orl    adc_latch_byte, #0x40                 ; 22F4
        lcall  adc_write_latches                     ; 22F7
        anl    shiftreg_out0, #0x7F                  ; 22FA
        lcall  shiftreg_write_analog                 ; 22FD
        lcall  ac_autozero_phase_a                   ; 2300
        setb   0x78                                  ; 2303
        ljmp   meas_exit                             ; 2305
L_2308::
        orl    shiftreg_out0, #0x80                  ; 2308
        lcall  shiftreg_write_analog                 ; 230B
        anl    adc_latch_byte, #0xBF                 ; 230E
        lcall  adc_write_latches                     ; 2311
        lcall  ac_autozero_phase_b                   ; 2314
        setb   0x79                                  ; 2317
        ljmp   meas_exit                             ; 2319
L_231C::
        jb     0x6E, L_2326                          ; 231C
        mov    r5, #0x88                             ; 231F
        mov    r6, #0xF4                             ; 2321
        jb     speed_b1, L_232A                      ; 2323
L_2326::
        mov    r5, #0x50                             ; 2326
        mov    r6, #0x8D                             ; 2328
L_232A::
        lcall  adc_set_count_time                    ; 232A
        mov    0x14, #0x01                           ; 232D
        jb     0x6E, L_233C                          ; 2330
        jb     speed_b1, L_233C                      ; 2333
        jb     speed_b0, L_233C                      ; 2336
        mov    0x14, #0x0A                           ; 2339
L_233C::
        mov    dptr, #x_adc_wait_time                ; 233C
        movx   a, @dptr                              ; 233F
        mov    r6, a                                 ; 2340
        inc    dptr                                  ; 2341
        movx   a, @dptr                              ; 2342
        mov    r5, a                                 ; 2343
        setb   sbit_F0                               ; 2344
        lcall  adc_set_times                         ; 2346
L_2349::
        lcall  adc_start_cycle_alt                   ; 2349
        lcall  adc_arm_timeout                       ; 234C
L_234F::
        ljmp   meas_exit                             ; 234F

; poll INT1 pin (OQ0071 READY, active low), read 0x8D -> count in 10h:0Fh:0Eh
adc_wait_ready_read::
        jb     sbit_INT1, L_234F                     ; 2352
        clr    0x28                                  ; 2355
        clr    0x73                                  ; 2357
        mov    a, #0x8D                              ; 2359
        lcall  i2cB_read1                            ; 235B
        mov    adc_count_mid, a                      ; 235E
        lcall  i2cB_recv_nack_stop                   ; 2360
        mov    adc_count_lo, a                       ; 2363
        mov    adc_count_hi, #0x00                   ; 2365
        clr    0x61                                  ; 2368
        setb   0x62                                  ; 236A
        djnz   0x14, L_2349                          ; 236C
        setb   0x72                                  ; 236F
        clr    0x71                                  ; 2371
        mov    a, meter_state                        ; 2373
        anl    a, #0x0F                              ; 2375
        cjne   a, #0x02, L_237C                      ; 2377
        sjmp   L_2384                                ; 237A
L_237C::
        cjne   a, #0x03, L_2381                      ; 237C
        sjmp   L_2384                                ; 237F
L_2381::
        cjne   a, #0x07, L_234F                      ; 2381
L_2384::
        jb     sbit_T0, L_234F                       ; 2384
        setb   0x68                                  ; 2387
        ljmp   meas_exit                             ; 2389

; function 8
acq_time::
        jb     0x71, time_wait_stop                  ; 238C
        jb     trigger_pending, L_2395               ; 238F
        ljmp   meas_exit                             ; 2392
L_2395::
        jb     0x0A, time_arm                        ; 2395
        jb     0x0B, time_arm                        ; 2398
        jnb    0x7A, time_arm                        ; 239B
        ljmp   meas_exit                             ; 239E

; P3.1 = start slope, T0 = FFFF (first edge overflows), enable T0/T1 interrupts
time_arm::
        mov    sfr_TMOD, #0x15                       ; 23A1
        anl    sfr_TCON, #0x0F                       ; 23A4
        clr    sbit_PT1                              ; 23A7
        setb   sbit_PT0                              ; 23A9
        mov    sfr_TL1, #0x00                        ; 23AB
        mov    sfr_TH1, #0x00                        ; 23AE
        clr    sbit_TXD                              ; 23B1
        jnb    time_start_negslope, L_23B8           ; 23B3
        setb   sbit_TXD                              ; 23B6
L_23B8::
        mov    sfr_TL0, #0xFF                        ; 23B8
        mov    sfr_TH0, #0xFF                        ; 23BB
        setb   0x71                                  ; 23BE
        orl    sfr_IE, #0x8A                         ; 23C0
        setb   sbit_TR0                              ; 23C3
        ljmp   meas_exit                             ; 23C5

; start seen: stop-edge timeout 1Ch = 0xD7 passes
time_wait_stop::
        jnb    time_started, L_23D5                  ; 23C8
        clr    time_started                          ; 23CB
        mov    0x1C, #0xD7                           ; 23CD
        setb   0x7A                                  ; 23D0
L_23D2::
        ljmp   meas_exit                             ; 23D2
L_23D5::
        jb     0x28, L_23DE                          ; 23D5
        jb     sbit_TR0, L_23D2                      ; 23D8
        ljmp   acq_done                              ; 23DB
L_23DE::
        ljmp   L_24F8                                ; 23DE

; function 9
acq_cap::
        jnb    0x71, L_23E7                          ; 23E1
        ljmp   cap_wait_charge                       ; 23E4
L_23E7::
        mov    sfr_TMOD, #0x15                       ; 23E7
        mov    sfr_TCON, #0x04                       ; 23EA
        mov    sfr_IP, #0x06                         ; 23ED
        mov    sfr_IE, #0x8A                         ; 23F0
        mov    dptr, #x_adc_wait_time                ; 23F3
        movx   a, @dptr                              ; 23F6
        mov    r6, a                                 ; 23F7
        inc    dptr                                  ; 23F8
        movx   a, @dptr                              ; 23F9
        mov    r5, a                                 ; 23FA
        clr    sbit_F0                               ; 23FB
        lcall  adc_set_times                         ; 23FD
        mov    0x14, #0x02                           ; 2400
        jnb    0x74, L_240B                          ; 2403
        mov    0x14, #0x01                           ; 2406
        sjmp   cap_charge_start                      ; 2409
L_240B::
        lcall  adc_start_cycle                       ; 240B
        anl    sfr_TCON, #0x55                       ; 240E
        setb   sbit_EX1                              ; 2411

; P1.5 low = discharge released, T1 times the charge until the comparator fires INT1
cap_charge_start::
        mov    sfr_TL0, #0xFF                        ; 2413
        mov    sfr_TH0, #0xFF                        ; 2416
        mov    r0, #0x10                             ; 2419
        lcall  i24_clr_r0                            ; 241B
        mov    0x11, #0x00                           ; 241E
        mov    sfr_TL1, #0x00                        ; 2421
        mov    sfr_TH1, #0x00                        ; 2424
        clr    0x95                                  ; 2427
        mov    shiftreg_out1, #0xD1                  ; 2429
        mov    a, meter_state                        ; 242C
        anl    a, #0x70                              ; 242E
        cjne   a, #0x70, L_2435                      ; 2430
        sjmp   L_2438                                ; 2433
L_2435::
        mov    shiftreg_out1, #0xD0                  ; 2435
L_2438::
        orl    adc_latch_byte, #0x40                 ; 2438
        anl    adc_latch_byte, #0xFE                 ; 243B
        lcall  shiftreg_write_analog                 ; 243E
        lcall  adc_write_latches                     ; 2441
        orl    adc_latch_byte, #0x04                 ; 2444
        lcall  adc_write_latches                     ; 2447
        lcall  key_debounce_delay                    ; 244A
        anl    adc_latch_byte, #0xFB                 ; 244D
        lcall  adc_write_latches                     ; 2450
        setb   0x95                                  ; 2453
        mov    a, meter_state                        ; 2455
        anl    a, #0x70                              ; 2457
        swap   a                                     ; 2459
        jnb    speed_b1, L_245E                      ; 245A
        inc    a                                     ; 245D
L_245E::
        mov    sfr_B, #0x03                          ; 245E
        mul    ab                                    ; 2461
        add    a, #0xFB                              ; 2462
        mov    dptr, #cap_range_table                ; 2464
        movc   a, @a+dptr                            ; 2467
        anl    a, #0xF7                              ; 2468
        mov    shiftreg_out1, a                      ; 246A
        lcall  shiftreg_write_analog                 ; 246C
        anl    adc_latch_byte, #0xBD                 ; 246F
        orl    adc_latch_byte, #0x01                 ; 2472
        lcall  adc_write_latches                     ; 2475
        lcall  key_debounce_delay                    ; 2478
        lcall  adc_arm_timeout                       ; 247B
        orl    sfr_TCON, #0x50                       ; 247E
        clr    0x95                                  ; 2481
        sjmp   L_24FC                                ; 2483

; overrange when T1 passes 0xD1xx (0x62xx in SPEED 3)
cap_wait_charge::
        jb     time_started, L_24FC                  ; 2485
        jnb    0x38, L_2493                          ; 2488
L_248B::
        jb     sbit_TR1, L_248B                      ; 248B
        clr    0x38                                  ; 248E
        ljmp   cap_charge_start                      ; 2490
L_2493::
        jnb    0x28, L_24CE                          ; 2493
        jb     speed_b1, L_24A9                      ; 2496
        mov    a, adc_count_mid                      ; 2499
        add    a, #0xFD                              ; 249B
        jb     0xE7, L_24FC                          ; 249D
        jnz    L_24B2                                ; 24A0
        mov    a, sfr_TH1                            ; 24A2
        cjne   a, #0xD1, L_24B0                      ; 24A4
        sjmp   L_24B2                                ; 24A7
L_24A9::
        mov    a, sfr_TH1                            ; 24A9
        cjne   a, #0x62, L_24B0                      ; 24AB
        sjmp   L_24B2                                ; 24AE
L_24B0::
        jc     L_24FC                                ; 24B0
L_24B2::
        mov    sfr_IE, #0x00                         ; 24B2
        mov    sfr_TCON, #0x00                       ; 24B5
        orl    adc_latch_byte, #0x02                 ; 24B8
        lcall  adc_write_latches                     ; 24BB
        setb   0x95                                  ; 24BE
        clr    0x28                                  ; 24C0
        clr    0x73                                  ; 24C2
        setb   0x69                                  ; 24C4
        mov    0x14, #0x00                           ; 24C6
        anl    0x27, #0xFC                           ; 24C9
        sjmp   L_24E4                                ; 24CC
L_24CE::
        setb   0x95                                  ; 24CE
        orl    adc_latch_byte, #0x02                 ; 24D0
        lcall  adc_write_latches                     ; 24D3
        clr    0x73                                  ; 24D6
        mov    adc_count_hi, adc_count_mid           ; 24D8
        mov    adc_count_mid, sfr_TH1                ; 24DB
        mov    adc_count_lo, sfr_TL1                 ; 24DE
        djnz   0x14, L_24F0                          ; 24E1
L_24E4::
        jbc    0x74, L_24E9                          ; 24E4
        sjmp   acq_done                              ; 24E7
L_24E9::
        setb   sbit_F0                               ; 24E9
        lcall  autorange_reset                       ; 24EB
        sjmp   L_24FC                                ; 24EE
L_24F0::
        setb   time_started                          ; 24F0
        sjmp   L_24F8                                ; 24F2

; conversion finished (2Eh.1 -> 2Eh.2)
acq_done::
        clr    0x71                                  ; 24F4
        setb   0x72                                  ; 24F6
L_24F8::
        clr    0x61                                  ; 24F8
        setb   0x62                                  ; 24FA
L_24FC::
        ljmp   meas_exit                             ; 24FC

; function 10
acq_freq::
        jb     0x71, freq_gate_done                  ; 24FF

; T0 counts input edges; T1 gate: 16 x 65.536 ms (1.048576 s), 2x in SPEED 2, 10 ms quick gate
freq_gate_start::
        mov    sfr_TMOD, #0x15                       ; 2502
        anl    sfr_TCON, #0x0F                       ; 2505
        clr    sbit_PT0                              ; 2508
        setb   sbit_PT1                              ; 250A
        orl    sfr_IE, #0x8A                         ; 250C
        anl    0x27, #0xFC                           ; 250F
        mov    0x14, #0x01                           ; 2512
        jnb    0x65, L_2524                          ; 2515
        mov    sfr_TL1, #0xF0                        ; 2518
        mov    sfr_TH1, #0xD8                        ; 251B
        mov    0x15, #0x01                           ; 251E
        ljmp   L_253C                                ; 2521
L_2524::
        jb     0x04, L_252D                          ; 2524
        jb     0x06, L_252D                          ; 2527
        mov    0x14, #0x0A                           ; 252A
L_252D::
        mov    sfr_TL1, #0x00                        ; 252D
        mov    sfr_TH1, #0x00                        ; 2530
        mov    0x15, #0x10                           ; 2533
        jnb    speed_b0, L_253C                      ; 2536
        mov    0x15, #0x02                           ; 2539
L_253C::
        mov    sfr_TL0, #0x00                        ; 253C
        mov    sfr_TH0, #0x00                        ; 253F
        setb   0x71                                  ; 2542
        orl    sfr_TCON, #0x50                       ; 2544
        sjmp   L_24FC                                ; 2547

freq_gate_done::
        mov    a, 0x14                               ; 2549
        jnz    L_2559                                ; 254B
        mov    adc_count_lo, sfr_TL0                 ; 254D
        mov    adc_count_mid, sfr_TH0                ; 2550
        setb   0x72                                  ; 2553
        clr    0x71                                  ; 2555
        sjmp   L_255C                                ; 2557
L_2559::
        jnb    0x28, L_24FC                          ; 2559
L_255C::
        clr    0x28                                  ; 255C
        sjmp   L_24F8                                ; 255E

; timeout counter 12h/13h = 0x0420 passes, set busy flags 2Eh.3/25h.0/2Eh.1
adc_arm_timeout::
        mov    adc_timeout_lo, #0x20                 ; 2560
        mov    adc_timeout_hi, #0x04                 ; 2563
        setb   0x73                                  ; 2566
        setb   0x28                                  ; 2568
        setb   0x71                                  ; 256A
        ret                                          ; 256C

; cmd 0x80, 0xD0, IRAM 0Ah = 8 output latches (input sensitivity, beeper)
adc_write_latches::
        lcall  adc_latch_cmd_begin                   ; 256D
        ljmp   i2cB_send_stop                        ; 2570

adc_latch_cmd_begin::
        mov    a, #0x80                              ; 2573
        lcall  i2cB_start                            ; 2575
        mov    a, #0xD0                              ; 2578
        lcall  i2cB_send_byte                        ; 257A
        mov    a, adc_latch_byte                     ; 257D
        ret                                          ; 257F

; cmd 0x82 + R6,R5 = wait time T1; if F0=0 also 0x84 (count time T2)
adc_set_times::
        mov    a, #0x82                              ; 2580
        lcall  i2cB_start                            ; 2582
        mov    a, r6                                 ; 2585
        lcall  i2cB_send_byte                        ; 2586
        mov    a, r5                                 ; 2589
        lcall  i2cB_send_stop                        ; 258A
        jnb    sbit_F0, adc_set_count_time           ; 258D
        ret                                          ; 2590

; cmd 0x84 + R6,R5 = count time T2
adc_set_count_time::
        mov    a, #0x84                              ; 2591
        lcall  i2cB_start                            ; 2593
        mov    a, r6                                 ; 2596
        lcall  i2cB_send_byte                        ; 2597
        mov    a, r5                                 ; 259A
        ljmp   i2cB_send_stop                        ; 259B

; drive motor switch to table position (funcswitch_pos_table), set relays, settle
meas_phase_switch::
        jnb    0x1C, L_25A4                          ; 259E
        anl    0x2D, #0x27                           ; 25A1
L_25A4::
        clr    0x60                                  ; 25A4
L_25A6::
        mov    0x30, #0x10                           ; 25A6
        jb     0x50, L_25D8                          ; 25A9
        mov    0x30, #0x08                           ; 25AC
        jb     0x51, L_25D8                          ; 25AF
        mov    a, meter_state                        ; 25B2
        anl    a, #0x0F                              ; 25B4
        jnz    L_25C3                                ; 25B6
        jnb    peak_mode_b1, L_25C3                  ; 25B8
        jnb    peak_mode_b0, L_25C3                  ; 25BB
        mov    0x30, #0x08                           ; 25BE
        sjmp   L_25D8                                ; 25C1
L_25C3::
        mov    dptr, #funcswitch_pos_table           ; 25C3
        movc   a, @a+dptr                            ; 25C6
        mov    0x30, a                               ; 25C7
        jnb    0xE1, L_25D8                          ; 25C9
        mov    a, meter_state                        ; 25CC
        anl    a, #0x70                              ; 25CE
        swap   a                                     ; 25D0
        dec    a                                     ; 25D1
        jnb    0xE2, L_25D8                          ; 25D2
        mov    0x30, #0x01                           ; 25D5
L_25D8::
        lcall  funcswitch_read_pos                   ; 25D8
        mov    r7, a                                 ; 25DB
        jb     0x51, L_25ED                          ; 25DC
        jz     L_2655                                ; 25DF
        cjne   a, 0x30, L_263D                       ; 25E1
        jb     0x70, L_2607                          ; 25E4
        jb     0x50, L_261F                          ; 25E7
        ljmp   meas_setup_analog                     ; 25EA
L_25ED::
        jz     L_25F8                                ; 25ED
        cjne   a, 0x30, L_263D                       ; 25EF
        setb   0x52                                  ; 25F2
        inc    0x37                                  ; 25F4
        sjmp   L_2607                                ; 25F6
L_25F8::
        jnb    0x52, L_2655                          ; 25F8
        mov    a, 0x37                               ; 25FB
        clr    c                                     ; 25FD
        rrc    a                                     ; 25FE
        mov    dptr, #x_funcswitch_step_count        ; 25FF
        movx   @dptr, a                              ; 2602
        clr    0x51                                  ; 2603
        sjmp   L_25A6                                ; 2605
L_2607::
        anl    shiftreg_out0, #0xEF                  ; 2607
        lcall  shiftreg_write_analog                 ; 260A
        orl    shiftreg_out0, #0x10                  ; 260D
        lcall  shiftreg_write_analog                 ; 2610
        mov    sfr_TL0, #0xD0                        ; 2613
        mov    sfr_TH0, #0x8A                        ; 2616
        mov    0x1B, #0x01                           ; 2619
        lcall  timer0_start_settle                   ; 261C
L_261F::
        jnb    0x50, L_2630                          ; 261F
        anl    0x2A, #0xFA                           ; 2622
        setb   0x51                                  ; 2625
        mov    0x37, #0x00                           ; 2627
        jnb    0x70, L_263D                          ; 262A
        ljmp   meas_exit                             ; 262D
L_2630::
        jb     0x51, L_263A                          ; 2630
        djnz   0x37, L_263A                          ; 2633
        setb   0x60                                  ; 2636
        clr    0x70                                  ; 2638
L_263A::
        ljmp   meas_exit                             ; 263A
L_263D::
        setb   0x75                                  ; 263D
        jnc    L_264A                                ; 263F
        orl    shiftreg_out1, #0x02                  ; 2641
        mov    a, 0x30                               ; 2644
        rr     a                                     ; 2646
        ljmp   L_2650                                ; 2647
L_264A::
        anl    shiftreg_out1, #0xFD                  ; 264A
        mov    a, 0x30                               ; 264D
        rl     a                                     ; 264F
L_2650::
        cjne   a, 0x07, L_2655                       ; 2650
        clr    0x75                                  ; 2653
L_2655::
        jb     0x70, L_2666                          ; 2655
        anl    shiftreg_out0, #0x7F                  ; 2658
        lcall  shiftreg_write_analog                 ; 265B
        orl    adc_latch_byte, #0x40                 ; 265E
        lcall  adc_write_latches                     ; 2661
        setb   0x13                                  ; 2664
L_2666::
        anl    shiftreg_out0, #0xEF                  ; 2666
        lcall  shiftreg_write_analog                 ; 2669
        orl    shiftreg_out0, #0x10                  ; 266C
        lcall  shiftreg_write_analog                 ; 266F
        mov    sfr_TL0, #0x80                        ; 2672
        mov    sfr_TH0, #0xC1                        ; 2675
        mov    0x1B, #0x01                           ; 2678
        jb     0x75, L_2684                          ; 267B
        mov    sfr_TL0, #0xD0                        ; 267E
        mov    sfr_TH0, #0x8A                        ; 2681
L_2684::
        lcall  timer0_start_settle                   ; 2684
        setb   0x70                                  ; 2687
        jb     0x50, L_2695                          ; 2689
        jb     0x51, L_2695                          ; 268C
        mov    dptr, #x_funcswitch_step_count        ; 268F
        movx   a, @dptr                              ; 2692
        mov    0x37, a                               ; 2693
L_2695::
        ljmp   meas_exit                             ; 2695

; after the switch settles: load cal coefficients, wait time, analog config per function/range
meas_setup_analog::
        jb     0x13, L_269E                          ; 2698
        ljmp   L_27D4                                ; 269B
L_269E::
        jb     0x29, L_26C1                          ; 269E
        jb     0x6B, L_26C1                          ; 26A1
        jb     0x6E, L_26C1                          ; 26A4
        lcall  cal_load_range                        ; 26A7
        jb     cal_enable, L_26B4                    ; 26AA
        lcall  cal_seal_check                        ; 26AD
        jnc    L_26B4                                ; 26B0
        setb   0x1F                                  ; 26B2
L_26B4::
        jnb    0x1F, L_26BE                          ; 26B4
        mov    dptr, #x_result_flags                 ; 26B7
        movx   a, @dptr                              ; 26BA
        setb   0xE2                                  ; 26BB
        movx   @dptr, a                              ; 26BD
L_26BE::
        lcall  cal_compute_effective                 ; 26BE
L_26C1::
        lcall  meas_calc_wait_time                   ; 26C1
        orl    adc_latch_byte, #0x40                 ; 26C4
        lcall  adc_write_latches                     ; 26C7
        jb     0x6B, L_26D3                          ; 26CA
        jnb    0x6E, L_272F                          ; 26CD
        jb     0x6C, L_271A                          ; 26D0
L_26D3::
        mov    a, meter_state                        ; 26D3
        anl    a, #0x0F                              ; 26D5
        xrl    a, #0x0A                              ; 26D7
        jz     L_2716                                ; 26D9
        anl    adc_latch_byte, #0x7F                 ; 26DB
        lcall  adc_write_latches                     ; 26DE
        anl    shiftreg_out0, #0x3F                  ; 26E1
        anl    shiftreg_out1, #0x7F                  ; 26E4
        orl    shiftreg_out1, #0x68                  ; 26E7
        lcall  shiftreg_write_analog                 ; 26EA
        anl    adc_latch_byte, #0xCF                 ; 26ED
        lcall  timer1_setup_count                    ; 26F0
        lcall  adc_latch_send_timed                  ; 26F3
        orl    shiftreg_out0, #0x20                  ; 26F6
        orl    shiftreg_out1, #0x02                  ; 26F9
        lcall  shiftreg_write_analog                 ; 26FC
        mov    sfr_P1, #0xE7                         ; 26FF
        clr    sbit_TXD                              ; 2702
        orl    adc_latch_byte, #0x03                 ; 2704
        lcall  adc_write_latches                     ; 2707
        anl    shiftreg_out1, #0xF2                  ; 270A
        orl    shiftreg_out1, #0x10                  ; 270D
        lcall  shiftreg_write_analog                 ; 2710
        ljmp   L_27CB                                ; 2713
L_2716::
        clr    0x6B                                  ; 2716
        setb   0x6C                                  ; 2718
L_271A::
        mov    a, meter_state                        ; 271A
        anl    a, #0x0F                              ; 271C
        cjne   a, #0x09, L_2724                      ; 271E
        anl    shiftreg_out0, #0xFC                  ; 2721
L_2724::
        anl    adc_latch_byte, #0xFB                 ; 2724
        orl    adc_latch_byte, #0xC9                 ; 2727
        lcall  analog_cfg_flags                      ; 272A
        sjmp   L_276B                                ; 272D
L_272F::
        lcall  analog_cfg_flags                      ; 272F
        mov    c, 0xE0                               ; 2732
        mov    sbit_TXD, c                           ; 2734
        mov    c, 0xE4                               ; 2736
        mov    0x94, c                               ; 2738
        jnb    0x65, L_2744                          ; 273A
        cjne   r2, #0x14, L_2744                     ; 273D
        mov    a, 0x35                               ; 2740
        sjmp   L_274E                                ; 2742
L_2744::
        mov    a, meter_state                        ; 2744
        jnb    speed_b1, L_274E                      ; 2746
        cjne   r2, #0x12, L_274E                     ; 2749
        add    a, #0x10                              ; 274C
L_274E::
        anl    a, #0x70                              ; 274E
        swap   a                                     ; 2750
        mov    sfr_B, #0x03                          ; 2751
        mul    ab                                    ; 2754
        mov    sfr_B, a                              ; 2755
        mov    a, r2                                 ; 2757
        inc    dptr                                  ; 2758
        movc   a, @a+dptr                            ; 2759
        add    a, sfr_B                              ; 275A
        mov    r2, a                                 ; 275C
        mov    dptr, #analog_cfg_table               ; 275D
        mov    r0, #0x08                             ; 2760
        mov    r3, #0x03                             ; 2762
L_2764::
        mov    a, r2                                 ; 2764
        movc   a, @a+dptr                            ; 2765
        mov    @r0, a                                ; 2766
        inc    r0                                    ; 2767
        inc    dptr                                  ; 2768
        djnz   r3, L_2764                            ; 2769
L_276B::
        push   shiftreg_out0                         ; 276B
        anl    shiftreg_out0, #0x7F                  ; 276D
        lcall  shiftreg_write_analog                 ; 2770
        push   adc_latch_byte                        ; 2773
        orl    adc_latch_byte, #0x4C                 ; 2775
        clr    sbit_F0                               ; 2778
        lcall  adc_latch_send_timed                  ; 277A
        mov    r2, #0x00                             ; 277D
        mov    r3, #0x04                             ; 277F
L_2781::
        djnz   r2, L_2781                            ; 2781
        djnz   r3, L_2781                            ; 2783
        pop    adc_latch_byte                        ; 2785
        lcall  adc_write_latches                     ; 2787
        pop    shiftreg_out0                         ; 278A
        lcall  shiftreg_write_analog                 ; 278C
        jb     0x29, L_27CB                          ; 278F
        jb     0x6B, L_27BD                          ; 2792
        jnb    0x6E, L_279D                          ; 2795
        jnb    0x6C, L_27BD                          ; 2798
        sjmp   L_27CB                                ; 279B
L_279D::
        mov    a, meter_state                        ; 279D
        anl    a, #0x0F                              ; 279F
        jz     L_27BD                                ; 27A1
        cjne   a, #0x02, L_27A8                      ; 27A3
        sjmp   L_27BD                                ; 27A6
L_27A8::
        cjne   a, #0x03, L_27AD                      ; 27A8
        sjmp   L_27BD                                ; 27AB
L_27AD::
        cjne   a, #0x07, L_27B2                      ; 27AD
        sjmp   L_27BD                                ; 27B0
L_27B2::
        cjne   a, #0x08, L_27BA                      ; 27B2
        anl    shiftreg_out1, #0xBF                  ; 27B5
        sjmp   L_27BD                                ; 27B8
L_27BA::
        cjne   a, #0x09, L_27CB                      ; 27BA
L_27BD::
        mov    r2, #0x02                             ; 27BD
        mov    r3, #0xF4                             ; 27BF
L_27C1::
        djnz   r3, L_27C1                            ; 27C1
        djnz   r2, L_27C1                            ; 27C3
        anl    shiftreg_out1, #0xF7                  ; 27C5
        lcall  shiftreg_write_analog                 ; 27C8
L_27CB::
        lcall  meas_settle_time_select               ; 27CB
        clr    0x66                                  ; 27CE
        clr    0x13                                  ; 27D0
        sjmp   L_27E6                                ; 27D2
L_27D4::
        jb     0x29, L_27E6                          ; 27D4
        jb     0x6B, L_27E6                          ; 27D7
        jb     0x6E, L_27E6                          ; 27DA
        mov    a, meter_state                        ; 27DD
        anl    a, #0x0F                              ; 27DF
        cjne   a, #0x09, L_27E6                      ; 27E1
        sjmp   L_27CB                                ; 27E4
L_27E6::
        anl    0x2F, #0xFC                           ; 27E6
        setb   0x61                                  ; 27E9
        ljmp   meas_exit                             ; 27EB

; T0 settle time per function/range from 3-byte table 0x71D0..0x71EB
meas_settle_time_select::
        jb     0x29, ac_autozero_phase_a             ; 27EE
        jb     0x6B, ac_autozero_phase_a             ; 27F1
        jnb    0x6E, L_2805                          ; 27F4
        jb     0x6C, L_27FF                          ; 27F7

ac_autozero_phase_a::
        mov    dptr, #T_71CD                         ; 27FA
        sjmp   L_2802                                ; 27FD
L_27FF::
        mov    dptr, #T_71D6                         ; 27FF
L_2802::
        ljmp   L_2871                                ; 2802
L_2805::
        mov    a, meter_state                        ; 2805
        jnb    0x66, L_283D                          ; 2807
        anl    a, #0x7F                              ; 280A
        cjne   a, #0x55, L_2822                      ; 280C
        jnb    cal_mode, L_2817                      ; 280F
L_2812::
        mov    dptr, #T_71EB                         ; 2812
        sjmp   L_2871                                ; 2815
L_2817::
        mov    dptr, #T_71E5                         ; 2817
        jnb    speed_b1, L_2871                      ; 281A
        mov    dptr, #T_71DF                         ; 281D
        sjmp   L_2871                                ; 2820
L_2822::
        cjne   a, #0x65, L_282D                      ; 2822
        mov    dptr, #T_71E5                         ; 2825
        jb     speed_b1, L_2871                      ; 2828
        sjmp   L_2812                                ; 282B
L_282D::
        anl    a, #0x0F                              ; 282D
        cjne   a, #0x09, L_283D                      ; 282F
        mov    dptr, #T_71D3                         ; 2832
        jb     speed_b1, L_2871                      ; 2835

ac_autozero_phase_b::
        mov    dptr, #T_71E2                         ; 2838
        sjmp   L_2871                                ; 283B
L_283D::
        anl    a, #0x0F                              ; 283D
        jnz    L_2846                                ; 283F
        mov    dptr, #T_71D0                         ; 2841
        sjmp   L_2871                                ; 2844
L_2846::
        cjne   a, #0x08, L_284E                      ; 2846
L_2849::
        mov    dptr, #T_71D9                         ; 2849
        sjmp   L_2871                                ; 284C
L_284E::
        cjne   a, #0x09, L_285A                      ; 284E
        mov    a, meter_state                        ; 2851
        anl    a, #0x60                              ; 2853
        cjne   a, #0x60, L_27FF                      ; 2855
        sjmp   L_2849                                ; 2858
L_285A::
        cjne   a, #0x0A, L_285F                      ; 285A
        sjmp   ac_autozero_phase_a                   ; 285D
L_285F::
        mov    a, meter_state                        ; 285F
        anl    a, #0x7C                              ; 2861
        cjne   a, #0x00, L_286E                      ; 2863
        jb     speed_b1, L_286E                      ; 2866
        mov    dptr, #T_71E8                         ; 2869
        sjmp   L_2871                                ; 286C
L_286E::
        mov    dptr, #T_71DC                         ; 286E
L_2871::
        clr    a                                     ; 2871
        movc   a, @a+dptr                            ; 2872
        mov    0x1B, a                               ; 2873
        inc    dptr                                  ; 2875
        clr    a                                     ; 2876
        movc   a, @a+dptr                            ; 2877
        mov    sfr_TH0, a                            ; 2878
        inc    dptr                                  ; 287A
        clr    a                                     ; 287B
        movc   a, @a+dptr                            ; 287C
        mov    sfr_TL0, a                            ; 287D

; T0 as settle timer (27h.5 mode: ISR kicks watchdog P1.2)
timer0_start_settle::
        setb   0x3D                                  ; 287F
        anl    sfr_TMOD, #0xF1                       ; 2881
        orl    sfr_TMOD, #0x01                       ; 2884
        orl    sfr_TCON, #0x10                       ; 2887
        orl    sfr_IE, #0x82                         ; 288A
        ret                                          ; 288D

; T1 (XDATA 0x00F0) from mains setting and function
meas_calc_wait_time::
        mov    r0, #0x47                             ; 288E
        mov    dptr, #0x00EC                         ; 2890
        lcall  fp_ld_xdata_r0                        ; 2893
        mov    r1, #0x43                             ; 2896
        mov    dptr, #T_7081                         ; 2898
        lcall  fp_ld_code_r1                         ; 289B
        lcall  fp_cmp                                ; 289E
        jc     L_28F3                                ; 28A1
        mov    dptr, #T_7085                         ; 28A3
        lcall  fp_ld_code_r1                         ; 28A6
        lcall  fp_cmp                                ; 28A9
        jnc    L_28F3                                ; 28AC
        clr    0x58                                  ; 28AE
        jb     0x6B, L_28BC                          ; 28B0
        jb     0x6E, L_28FA                          ; 28B3
        mov    a, meter_state                        ; 28B6
        anl    a, #0x0F                              ; 28B8
        jnz    L_28BD                                ; 28BA
L_28BC::
        ret                                          ; 28BC
L_28BD::
        cjne   a, #0x08, L_28C2                      ; 28BD
        sjmp   L_28BC                                ; 28C0
L_28C2::
        cjne   a, #0x0A, L_28C7                      ; 28C2
        sjmp   L_28BC                                ; 28C5
L_28C7::
        cjne   a, #0x09, L_28F5                      ; 28C7
        mov    dptr, #T_70A1                         ; 28CA
        jnb    mains_60hz, L_28D3                    ; 28CD
        mov    dptr, #T_70A5                         ; 28D0
L_28D3::
        jb     speed_b1, L_290E                      ; 28D3
        mov    a, meter_state                        ; 28D6
        anl    a, #0x60                              ; 28D8
        cjne   a, #0x60, L_28E8                      ; 28DA
        mov    dptr, #T_70A9                         ; 28DD
        jnb    mains_60hz, L_290E                    ; 28E0
        mov    dptr, #T_70AD                         ; 28E3
        sjmp   L_290E                                ; 28E6
L_28E8::
        mov    dptr, #T_70B1                         ; 28E8
        jnb    mains_60hz, L_290E                    ; 28EB
        mov    dptr, #T_70B5                         ; 28EE
        sjmp   L_290E                                ; 28F1
L_28F3::
        sjmp   L_2943                                ; 28F3
L_28F5::
        setb   0x58                                  ; 28F5
        jb     speed_b1, L_2905                      ; 28F7
L_28FA::
        mov    dptr, #T_7089                         ; 28FA
        jnb    mains_60hz, L_290E                    ; 28FD
        mov    dptr, #T_708D                         ; 2900
        sjmp   L_290E                                ; 2903
L_2905::
        mov    dptr, #T_7091                         ; 2905
        jnb    mains_60hz, L_290E                    ; 2908
        mov    dptr, #T_7095                         ; 290B
L_290E::
        lcall  fp_ld_code_r1                         ; 290E
        lcall  fp_mul                                ; 2911
        lcall  fp_to_i24_round                       ; 2914
        jb     0x6E, L_2920                          ; 2917
        jnb    0x58, L_2935                          ; 291A
        jb     speed_b1, L_2928                      ; 291D
L_2920::
        mov    0x40, #0x50                           ; 2920
        mov    0x41, #0x8D                           ; 2923
        sjmp   L_292E                                ; 2926
L_2928::
        mov    0x40, #0x88                           ; 2928
        mov    0x41, #0xF4                           ; 292B
L_292E::
        mov    range_lim_down, #0xFF                 ; 292E
        dec    r1                                    ; 2931
        lcall  i24_add                               ; 2932
L_2935::
        lcall  i24_neg                               ; 2935
        dec    r0                                    ; 2938
        mov    dptr, #x_adc_wait_time                ; 2939
        mov    a, @r0                                ; 293C
        movx   @dptr, a                              ; 293D
        dec    r0                                    ; 293E
        inc    dptr                                  ; 293F
        mov    a, @r0                                ; 2940
        movx   @dptr, a                              ; 2941
        ret                                          ; 2942
L_2943::
        setb   0x29                                  ; 2943
        ret                                          ; 2945

adc_latch_send_timed::
        lcall  adc_latch_cmd_begin                   ; 2946
        mov    r2, #0x08                             ; 2949
L_294B::
        rlc    a                                     ; 294B
        mov    0x97, c                               ; 294C
        setb   sbit_T1                               ; 294E
L_2950::
        jnb    sbit_T1, L_2950                       ; 2950
        push   sfr_PSW                               ; 2953
        cjne   r2, #0x01, L_296C                     ; 2955
        mov    c, 0x5B                               ; 2958
        jb     sbit_F0, L_2979                       ; 295A
        jnb    0x18, L_296A                          ; 295D
L_2960::
        jnb    sbit_TR1, L_2968                      ; 2960
        jb     sbit_ET1, L_2960                      ; 2963
        clr    sbit_TR1                              ; 2966
L_2968::
        clr    0x18                                  ; 2968
L_296A::
        mov    0x95, c                               ; 296A
L_296C::
        clr    sbit_T1                               ; 296C
        pop    sfr_PSW                               ; 296E
        djnz   r2, L_294B                            ; 2970
        rlc    a                                     ; 2972
        lcall  i2cB_read_ack_bit                     ; 2973
        ljmp   i2cB_stop                             ; 2976
L_2979::
        mov    sbit_TR1, c                           ; 2979
        sjmp   L_296C                                ; 297B

analog_cfg_flags::
        mov    a, meter_state                        ; 297D
        anl    a, #0x0F                              ; 297F
        rl     a                                     ; 2981
        mov    r2, a                                 ; 2982
        mov    dptr, #analog_cfg_index               ; 2983
        movc   a, @a+dptr                            ; 2986
        mov    c, 0xE5                               ; 2987
        mov    0x5B, c                               ; 2989
        ret                                          ; 298B

timer1_setup_count::
        setb   sbit_F0                               ; 298C
        mov    a, meter_state                        ; 298E
        anl    a, #0x0F                              ; 2990
        cjne   a, #0x0B, L_2995                      ; 2992
L_2995::
        jnc    L_299C                                ; 2995
        anl    a, #0xFE                              ; 2997
        cjne   a, #0x04, L_29BF                      ; 2999
L_299C::
        setb   0x5B                                  ; 299C
        anl    sfr_TMOD, #0x1F                       ; 299E
        orl    sfr_TMOD, #0x10                       ; 29A1
        anl    sfr_TCON, #0x3F                       ; 29A4
        orl    sfr_IE, #0x88                         ; 29A7
        setb   0x18                                  ; 29AA
        mov    sfr_TL1, #0x10                        ; 29AC
        mov    sfr_TH1, #0xB6                        ; 29AF
        jb     mains_60hz, L_29BB                    ; 29B2
        mov    sfr_TL1, #0x00                        ; 29B5
        mov    sfr_TH1, #0x8F                        ; 29B8
L_29BB::
        mov    0x18, #0x03                           ; 29BB
        ret                                          ; 29BE
L_29BF::
        clr    0x5B                                  ; 29BF
        ret                                          ; 29C1
funcswitch_pos_table::
        .db 0x10, 0x10, 0x08, 0x10, 0x40, 0x20, 0x02, 0x02, 0x10, 0x20, 0x04, 0x40, 0x20, 0x20 ; 29C2 ....@ ... .@  
analog_cfg_index::
        .db 0x20, 0xFD, 0x21, 0x0C, 0x21, 0x1B, 0x21, 0x2A, 0x01, 0x39, 0x01, 0x48, 0x21, 0x5A, 0x21, 0x6C ; 29D0  .!.!.!*.9.H!Z!l
        .db 0x20, 0x7E, 0x20, 0x8D, 0x21, 0x9F, 0x01, 0xB4, 0x01, 0xB7, 0x01, 0xBA           ; 29E0  ~ .!.......
analog_cfg_table::
        .db 0x10, 0x7A, 0x07, 0x14, 0x7A, 0x07, 0x11, 0x7A, 0x07, 0x12, 0x7A, 0x07, 0x78, 0x62, 0x8B, 0x78 ; 29EC .z..z..z..z.xb.x
        .db 0x62, 0x87, 0x7C, 0x62, 0x87, 0x79, 0x62, 0x87, 0x7A, 0x62, 0x87, 0xF0, 0x6A, 0x0B, 0xF0, 0x6A ; 29FC b.|b.yb.zb..j..j
        .db 0x07, 0xF4, 0x6A, 0x07, 0xF1, 0x6A, 0x07, 0xF2, 0x6A, 0x07, 0xF0, 0x6A, 0x0B, 0xF0, 0x6A, 0x07 ; 2A0C ..j..j..j..j..j.
        .db 0xF4, 0x6A, 0x07, 0xF1, 0x6A, 0x07, 0xF2, 0x6A, 0x07, 0x10, 0x50, 0xA9, 0x10, 0x50, 0xA5, 0x10 ; 2A1C .j..j..j..P..P..
        .db 0x51, 0xA5, 0x10, 0x44, 0xA5, 0x10, 0x45, 0xA5, 0x10, 0x50, 0xA9, 0x10, 0x50, 0xA5, 0x10, 0x51 ; 2A2C Q..D..E..P..P..Q
        .db 0xA5, 0x10, 0x44, 0xA5, 0x10, 0x45, 0xA5, 0x10, 0x40, 0xA5, 0x10, 0x41, 0xA5, 0x70, 0x72, 0x8B ; 2A3C ..D..E..@..A.pr.
        .db 0x70, 0x72, 0x87, 0x74, 0x72, 0x8B, 0x74, 0x72, 0x87, 0x70, 0x72, 0x8B, 0x70, 0x72, 0x87, 0xF0 ; 2A4C pr.tr.tr.pr.pr..
        .db 0x7A, 0x0B, 0xF0, 0x7A, 0x07, 0xF4, 0x7A, 0x0B, 0xF4, 0x7A, 0x07, 0xF0, 0x7A, 0x0B, 0xF0, 0x7A ; 2A5C z..z..z..z..z..z
        .db 0x07, 0x50, 0x69, 0x27, 0x50, 0x69, 0x27, 0x50, 0x69, 0x27, 0x50, 0x69, 0x27, 0x50, 0x69, 0x27 ; 2A6C .Pi'Pi'Pi'Pi'Pi'
        .db 0x50, 0x69, 0x27                                                                 ; 2A7C Pi'
cap_range_table::
        .db 0x13, 0xC8, 0x93, 0x13, 0xCD, 0x93, 0x13, 0xCC, 0x93, 0x13, 0xD9, 0x93, 0x13, 0xD8, 0x93, 0x13 ; 2A7F ................
        .db 0xD8, 0x93, 0x74, 0x69, 0x47, 0x74, 0x69, 0x47, 0x74, 0x61, 0x47, 0x74, 0x21, 0x47, 0x74, 0x21 ; 2A8F ..tiGtiGtaGt!Gt!
        .db 0x47, 0x10, 0x50, 0xA5, 0x10, 0x50, 0xA5, 0x10, 0x50, 0xA9                       ; 2A9F G.P..P..P.

; 1385 B: display/CHECK menu (ADDr, rTL, T.ONLY, Cr, 60H, SOFT, CAL, version)
task_display_menu::
        mov    dptr, #0x00C1                         ; 2AA9
        movx   a, @dptr                              ; 2AAC
        jnb    0xE7, L_2AB1                          ; 2AAD
        ret                                          ; 2AB0
L_2AB1::
        mov    dptr, #0x00A5                         ; 2AB1
        mov    r0, #0x2B                             ; 2AB4
        mov    r2, #0x19                             ; 2AB6
        lcall  xdata_to_iram                         ; 2AB8
        clr    0x97                                  ; 2ABB
        setb   0x97                                  ; 2ABD
        jb     0x90, L_2ACD                          ; 2ABF
        mov    0x35, #0xFF                           ; 2AC2
        lcall  key_scan                              ; 2AC5
        mov    a, 0x35                               ; 2AC8
        cpl    a                                     ; 2ACA
        jnz    L_2AE6                                ; 2ACB
L_2ACD::
        mov    dptr, #0x0012                         ; 2ACD
        movx   a, @dptr                              ; 2AD0
        mov    sfr_B, #0x05                          ; 2AD1
        div    ab                                    ; 2AD4
        mov    a, sfr_B                              ; 2AD5
        cjne   a, #0x00, L_2AE3                      ; 2AD7
        jb     0x75, L_2AE3                          ; 2ADA
        jb     0x74, L_2AE3                          ; 2ADD
        lcall  probe_hold_poll                       ; 2AE0
L_2AE3::
        ljmp   L_2FEB                                ; 2AE3
L_2AE6::
        mov    a, meter_state                        ; 2AE6
        anl    a, #0x0F                              ; 2AE8
        mov    r2, a                                 ; 2AEA
        mov    r0, #0x2F                             ; 2AEB
        mov    r1, #0x35                             ; 2AED
        mov    a, @r1                                ; 2AEF
        jnb    0x75, L_2AF6                          ; 2AF0
        ljmp   L_2C8D                                ; 2AF3
L_2AF6::
        jnb    0x74, L_2AFC                          ; 2AF6
        ljmp   L_2D82                                ; 2AF9
L_2AFC::
        mov    a, 0x1D                               ; 2AFC
        orl    a, 0x1E                               ; 2AFE
        jz     L_2B1D                                ; 2B00
        mov    dptr, #0x00EB                         ; 2B02
        movx   a, @dptr                              ; 2B05
        jnb    cal_mode, L_2B0E                      ; 2B06
        cjne   @r1, #0x0B, L_2B0E                    ; 2B09
        sjmp   L_2B1D                                ; 2B0C
L_2B0E::
        jnb    0xE4, L_2B1D                          ; 2B0E
        jb     0xE7, L_2B1A                          ; 2B11
        cjne   @r1, #0x0C, L_2B1A                    ; 2B14
        ljmp   key_12_status                         ; 2B17
L_2B1A::
        ljmp   L_2FEB                                ; 2B1A
L_2B1D::
        jnb    0x32, L_2B27                          ; 2B1D
        clr    0x32                                  ; 2B20
        lcall  menu_clear_state                      ; 2B22
        mov    r0, #0x2F                             ; 2B25
L_2B27::
        mov    a, 0x35                               ; 2B27
        mov    sfr_B, #0x03                          ; 2B29
        mul    ab                                    ; 2B2C
        mov    dptr, #key_jtab                       ; 2B2D
        jmp    @a+dptr                               ; 2B30

; 16 x LJMP, key handlers store a command index for the executor
key_jtab::
        ljmp   key_0_vdc_speed                       ; 2B31
L_2B34::
        ljmp   key_1_vac_vrms                        ; 2B34
L_2B37::
        ljmp   key_2_vpeak_cycle                     ; 2B37
L_2B3A::
        ljmp   key_3_ohm2w_cont                      ; 2B3A
L_2B3D::
        ljmp   key_4_ohm4w_temp                      ; 2B3D
L_2B40::
        ljmp   key_5_idc                             ; 2B40
L_2B43::
        ljmp   key_6_iac                             ; 2B43
L_2B46::
        ljmp   key_7_cap_diode                       ; 2B46
L_2B49::
        ljmp   key_8_frq_speed                       ; 2B49
L_2B4C::
        ljmp   key_9_time_cycle                      ; 2B4C
L_2B4F::
        ljmp   key_10_dbm                            ; 2B4F
L_2B52::
        ljmp   key_11_zero                           ; 2B52
L_2B55::
        ljmp   key_12_status                         ; 2B55
L_2B58::
        ljmp   key_13_range_down                     ; 2B58
L_2B5B::
        ljmp   key_14_range_up                       ; 2B5B
L_2B5E::
        ljmp   key_15_auto                           ; 2B5E

key_0_vdc_speed::
        cjne   r2, #0x01, L_2B82                     ; 2B61
        jnb    cal_mode, L_2B6A                      ; 2B64
        ljmp   L_2FEB                                ; 2B67
L_2B6A::
        mov    @r0, #0x1A                            ; 2B6A
        jb     speed_b1, L_2B7C                      ; 2B6C
        jb     speed_b0, L_2B77                      ; 2B6F
        mov    0x31, #0x03                           ; 2B72
        sjmp   L_2B7F                                ; 2B75
L_2B77::
        mov    0x31, #0x01                           ; 2B77
        sjmp   L_2B7F                                ; 2B7A
L_2B7C::
        mov    0x31, #0x02                           ; 2B7C
L_2B7F::
        ljmp   L_2F5E                                ; 2B7F
L_2B82::
        mov    @r0, #0x03                            ; 2B82
        ljmp   L_2FDA                                ; 2B84

key_1_vac_vrms::
        cjne   r2, #0x02, L_2B8F                     ; 2B87
        mov    @r0, #0x05                            ; 2B8A
        ljmp   L_2FDA                                ; 2B8C
L_2B8F::
        mov    @r0, #0x04                            ; 2B8F
        ljmp   L_2FDA                                ; 2B91

key_2_vpeak_cycle::
        jnb    peak_mode_b0, L_2BA4                  ; 2B94
        jnb    peak_mode_b1, L_2B9F                  ; 2B97
        mov    @r0, #0x00                            ; 2B9A
        ljmp   L_2FDA                                ; 2B9C
L_2B9F::
        mov    @r0, #0x01                            ; 2B9F
        ljmp   L_2FDA                                ; 2BA1
L_2BA4::
        mov    @r0, #0x02                            ; 2BA4
        ljmp   L_2FDA                                ; 2BA6

key_3_ohm2w_cont::
        cjne   r2, #0x05, L_2BB1                     ; 2BA9
        mov    @r0, #0x12                            ; 2BAC
        ljmp   L_2FDA                                ; 2BAE
L_2BB1::
        mov    @r0, #0x07                            ; 2BB1
        ljmp   L_2FDA                                ; 2BB3

key_4_ohm4w_temp::
        cjne   r2, #0x04, L_2BBE                     ; 2BB6
        mov    @r0, #0x10                            ; 2BB9
        ljmp   L_2FDA                                ; 2BBB
L_2BBE::
        mov    @r0, #0x06                            ; 2BBE
        ljmp   L_2FDA                                ; 2BC0

key_5_idc::
        mov    @r0, #0x08                            ; 2BC3
        ljmp   L_2FDA                                ; 2BC5

key_6_iac::
        mov    @r0, #0x09                            ; 2BC8
        ljmp   L_2FDA                                ; 2BCA

key_7_cap_diode::
        cjne   r2, #0x09, L_2BD5                     ; 2BCD
        mov    @r0, #0x11                            ; 2BD0
        ljmp   L_2FDA                                ; 2BD2
L_2BD5::
        mov    @r0, #0x0E                            ; 2BD5
        ljmp   L_2FDA                                ; 2BD7

key_8_frq_speed::
        cjne   r2, #0x0A, L_2BF6                     ; 2BDA
        jnb    cal_mode, L_2BE3                      ; 2BDD
        ljmp   L_2FEB                                ; 2BE0
L_2BE3::
        mov    @r0, #0x1A                            ; 2BE3
        jb     speed_b0, L_2BF0                      ; 2BE5
        jb     speed_b1, L_2BF0                      ; 2BE8
        mov    0x31, #0x02                           ; 2BEB
        sjmp   L_2BF3                                ; 2BEE
L_2BF0::
        mov    0x31, #0x01                           ; 2BF0
L_2BF3::
        ljmp   L_2F5E                                ; 2BF3
L_2BF6::
        mov    @r0, #0x0F                            ; 2BF6
        ljmp   L_2FDA                                ; 2BF8

key_9_time_cycle::
        cjne   r2, #0x08, L_2C16                     ; 2BFB
        jb     time_stop_negslope, L_2C09            ; 2BFE
        jb     time_start_negslope, L_2C11           ; 2C01
        mov    @r0, #0x0B                            ; 2C04
        ljmp   L_2FDA                                ; 2C06
L_2C09::
        jb     time_start_negslope, L_2C16           ; 2C09
        mov    @r0, #0x0C                            ; 2C0C
        ljmp   L_2FDA                                ; 2C0E
L_2C11::
        mov    @r0, #0x0D                            ; 2C11
        ljmp   L_2FDA                                ; 2C13
L_2C16::
        mov    @r0, #0x0A                            ; 2C16
        ljmp   L_2FDA                                ; 2C18

key_10_dbm::
        jb     cal_mode, L_2C48                      ; 2C1B
        jb     0x03, L_2C48                          ; 2C1E
        jb     0x02, L_2C48                          ; 2C21
        mov    a, r2                                 ; 2C24
        jz     L_2C48                                ; 2C25
        mov    @r0, #0x15                            ; 2C27
        jb     0x10, L_2C8A                          ; 2C29
        mov    0x30, #0xA4                           ; 2C2C
        setb   0x22                                  ; 2C2F
        orl    0x26, #0x06                           ; 2C31
        lcall  menu_show_dbm_ref                     ; 2C34
        ljmp   L_2FE9                                ; 2C37

key_11_zero::
        jnb    cal_mode, L_2C45                      ; 2C3A
        jnb    0x0B, L_2C48                          ; 2C3D
        mov    @r0, #0x1D                            ; 2C40
        ljmp   L_2FDA                                ; 2C42
L_2C45::
        cjne   r2, #0x0D, L_2C4B                     ; 2C45
L_2C48::
        ljmp   L_2FEB                                ; 2C48
L_2C4B::
        mov    @r0, #0x16                            ; 2C4B
        jb     0x11, L_2C8A                          ; 2C4D
        mov    0x30, #0xA4                           ; 2C50
        clr    0x22                                  ; 2C53
        orl    0x26, #0x06                           ; 2C55
        jb     0x35, L_2C61                          ; 2C58
        mov    dptr, #x_zero_reference               ; 2C5B
        ljmp   menu_edit_value                       ; 2C5E
L_2C61::
        mov    dptr, #0x0091                         ; 2C61
        jnb    0x10, L_2C6A                          ; 2C64
        mov    dptr, #0x008D                         ; 2C67
L_2C6A::
        ljmp   menu_edit_value                       ; 2C6A

key_12_status::
        orl    0x2E, #0x21                           ; 2C6D
        ljmp   L_2FE9                                ; 2C70

key_13_range_down::
        mov    @r0, #0x2A                            ; 2C73
L_2C75::
        ljmp   L_2FE4                                ; 2C75

key_14_range_up::
        mov    @r0, #0x2B                            ; 2C78
        sjmp   L_2C75                                ; 2C7A

key_15_auto::
        jnb    cal_mode, L_2C82                      ; 2C7C
        ljmp   L_2FEB                                ; 2C7F
L_2C82::
        mov    @r0, #0x2C                            ; 2C82
        jb     meter_autorange, L_2C8A               ; 2C84
        ljmp   L_2FE4                                ; 2C87
L_2C8A::
        ljmp   L_2FDF                                ; 2C8A
L_2C8D::
        mov    dptr, #0x00EB                         ; 2C8D
        movx   a, @dptr                              ; 2C90
        jnb    0xE4, L_2C9D                          ; 2C91
        cjne   @r1, #0x0E, L_2C9A                    ; 2C94
        ljmp   L_2D4C                                ; 2C97
L_2C9A::
        ljmp   L_3058                                ; 2C9A
L_2C9D::
        mov    a, #0xF6                              ; 2C9D
        add    a, @r1                                ; 2C9F
        jb     0xE7, L_2C48                          ; 2CA0
        mov    sfr_B, #0x03                          ; 2CA3
        mul    ab                                    ; 2CA6
        mov    dptr, #L_2CAB                         ; 2CA7
        jmp    @a+dptr                               ; 2CAA
L_2CAB::
        ljmp   L_2CBD                                ; 2CAB
L_2CAE::
        ljmp   L_2CDF                                ; 2CAE
L_2CB1::
        ljmp   L_2D18                                ; 2CB1
L_2CB4::
        ljmp   L_2D1B                                ; 2CB4
L_2CB7::
        ljmp   L_2D2C                                ; 2CB7
L_2CBA::
        ljmp   L_2D7C                                ; 2CBA
L_2CBD::
        jb     cal_mode, L_2CE5                      ; 2CBD
        mov    a, r2                                 ; 2CC0
        jz     L_2CE5                                ; 2CC1
        jb     0xE3, L_2CE5                          ; 2CC3
        jb     0xE2, L_2CE5                          ; 2CC6
        mov    @r0, #0x15                            ; 2CC9
        lcall  menu_set_flag                         ; 2CCB
        clr    0x60                                  ; 2CCE
        setb   0x68                                  ; 2CD0
        setb   0x61                                  ; 2CD2
        setb   0x22                                  ; 2CD4
        mov    0x36, #0x03                           ; 2CD6
        lcall  menu_show_dbm_ref                     ; 2CD9
        ljmp   L_2FE9                                ; 2CDC
L_2CDF::
        jb     cal_mode, L_2CE5                      ; 2CDF
        cjne   r2, #0x0D, L_2CE8                     ; 2CE2
L_2CE5::
        ljmp   L_2FEB                                ; 2CE5
L_2CE8::
        mov    @r0, #0x16                            ; 2CE8
        lcall  menu_set_flag                         ; 2CEA
        orl    0x2D, #0x09                           ; 2CED
        clr    0x60                                  ; 2CF0
        lcall  func_class_check                      ; 2CF2
        jnc    L_2CF9                                ; 2CF5
        setb   0x60                                  ; 2CF7
L_2CF9::
        setb   0x61                                  ; 2CF9
        clr    0x22                                  ; 2CFB
        mov    a, meter_state                        ; 2CFD
        anl    a, #0x70                              ; 2CFF
        mov    c, 0x2E                               ; 2D01
        mov    0xE7, c                               ; 2D03
        mov    dptr, #0x006D                         ; 2D05
        movx   @dptr, a                              ; 2D08
        mov    0x36, #0x00                           ; 2D09
        jnb    0x10, L_2D12                          ; 2D0C
        mov    0x36, #0x03                           ; 2D0F
L_2D12::
        mov    dptr, #x_zero_reference               ; 2D12
        ljmp   menu_edit_value                       ; 2D15
L_2D18::
        ljmp   L_2D7C                                ; 2D18
L_2D1B::
        setb   0x31                                  ; 2D1B
        clr    0x22                                  ; 2D1D
        setb   0x73                                  ; 2D1F
        mov    @r0, #0x17                            ; 2D21
        lcall  menu_enter_edit                       ; 2D23
        mov    dptr, #x_minmax_min                   ; 2D26
        ljmp   menu_edit_value                       ; 2D29
L_2D2C::
        jnb    cal_enable, L_2D36                    ; 2D2C
        mov    @r0, #0x1E                            ; 2D2F
        mov    dptr, #T_7193                         ; 2D31
        sjmp   L_2D51                                ; 2D34
L_2D36::
        setb   0x68                                  ; 2D36
        mov    a, 0x1D                               ; 2D38
        orl    a, 0x1E                               ; 2D3A
        jz     L_2D45                                ; 2D3C
        mov    dptr, #0x005A                         ; 2D3E
        movx   a, @dptr                              ; 2D41
        cjne   a, #0x05, L_2D4C                      ; 2D42
L_2D45::
        mov    @r0, #0x24                            ; 2D45
        mov    dptr, #T_716C                         ; 2D47
        sjmp   L_2D51                                ; 2D4A
L_2D4C::
        mov    @r0, #0x29                            ; 2D4C
        mov    dptr, #T_712B                         ; 2D4E
L_2D51::
        lcall  menu_show_step                        ; 2D51
        lcall  menu_enter_edit                       ; 2D54
        mov    r0, #0x2F                             ; 2D57
        cjne   @r0, #0x24, L_2D68                    ; 2D59
        mov    c, mains_60hz                         ; 2D5C
        cpl    c                                     ; 2D5E
        mov    0x58, c                               ; 2D5F
        jc     L_2D75                                ; 2D61
        mov    0x3E, #0x31                           ; 2D63
        sjmp   L_2D75                                ; 2D66
L_2D68::
        cjne   @r0, #0x1E, L_2D75                    ; 2D68
        mov    c, cal_hot                            ; 2D6B
        cpl    c                                     ; 2D6D
        mov    0x58, c                               ; 2D6E
        jc     L_2D75                                ; 2D70
        mov    0x3D, #0x31                           ; 2D72
L_2D75::
        setb   0x5C                                  ; 2D75
        setb   0x22                                  ; 2D77
        ljmp   L_2FCE                                ; 2D79
L_2D7C::
        anl    0x2E, #0xDE                           ; 2D7C
        ljmp   L_2FE9                                ; 2D7F
L_2D82::
        mov    dptr, #0x00EB                         ; 2D82
        movx   a, @dptr                              ; 2D85
        jnb    0xE4, L_2D8F                          ; 2D86
        jb     0x5C, L_2D94                          ; 2D89
        ljmp   L_3058                                ; 2D8C
L_2D8F::
        mov    a, 0x35                               ; 2D8F
        jnb    0x5C, L_2D97                          ; 2D91
L_2D94::
        ljmp   L_2E7D                                ; 2D94
L_2D97::
        cjne   @r0, #0x15, L_2DEA                    ; 2D97
        lcall  menu_edit_digits                      ; 2D9A
        jb     0x5F, L_2DAF                          ; 2D9D
        jb     0x62, L_2DA9                          ; 2DA0
        mov    0x41, #0x83                           ; 2DA3
        ljmp   L_2FCE                                ; 2DA6
L_2DA9::
        mov    range_lim_down, #0x83                 ; 2DA9
        ljmp   L_2FCE                                ; 2DAC
L_2DAF::
        jb     0x58, L_2E2A                          ; 2DAF
        lcall  menu_parse_number                     ; 2DB2
        mov    dptr, #T_6FD4                         ; 2DB5
        mov    r1, #0x5B                             ; 2DB8
        lcall  fp_ld_code_r1                         ; 2DBA
        lcall  fp_cmp                                ; 2DBD
        jc     L_2DD1                                ; 2DC0
        mov    dptr, #T_6FD8                         ; 2DC2
        mov    r1, #0x5B                             ; 2DC5
        lcall  fp_ld_code_r1                         ; 2DC7
        lcall  fp_cmp                                ; 2DCA
        jz     L_2DE4                                ; 2DCD
        jc     L_2DE4                                ; 2DCF
L_2DD1::
        lcall  menu_set_flag                         ; 2DD1
        mov    dptr, #T_7186                         ; 2DD4
        mov    r0, #0x38                             ; 2DD7
        mov    r2, #0x09                             ; 2DD9
        lcall  code_to_iram_copy                     ; 2DDB
        mov    0x41, #0x83                           ; 2DDE
        ljmp   L_2FCE                                ; 2DE1
L_2DE4::
        lcall  menu_clear_state                      ; 2DE4
        ljmp   L_2E27                                ; 2DE7
L_2DEA::
        cjne   @r0, #0x16, L_2E4A                    ; 2DEA
        clr    0x30                                  ; 2DED
        lcall  menu_edit_digits                      ; 2DEF
        jnb    0x5F, L_2E33                          ; 2DF2
        jb     0x58, L_2E27                          ; 2DF5
        lcall  menu_parse_number                     ; 2DF8
        jnb    0x10, L_2E12                          ; 2DFB
        mov    a, #0x03                              ; 2DFE
        mov    r0, #0x34                             ; 2E00
        mov    r1, #0x5F                             ; 2E02
        lcall  fp_ld_pow10_r1                        ; 2E04
        lcall  fp_cmp                                ; 2E07
        jc     L_2E27                                ; 2E0A
        lcall  menu_start_blank                      ; 2E0C
        ljmp   L_2FCE                                ; 2E0F
L_2E12::
        mov    dptr, #0x00A0                         ; 2E12
        movx   a, @dptr                              ; 2E15
        anl    a, #0x70                              ; 2E16
        swap   a                                     ; 2E18
        lcall  lcd_decimal_point                     ; 2E19
        mov    a, r7                                 ; 2E1C
        mov    r0, #0x34                             ; 2E1D
        mov    r1, #0x5F                             ; 2E1F
        lcall  fp_ld_pow10_r1                        ; 2E21
        lcall  fp_mul                                ; 2E24
L_2E27::
        mov    0x30, #0xA4                           ; 2E27
L_2E2A::
        anl    0x2D, #0xF6                           ; 2E2A
        lcall  menu_clear_state                      ; 2E2D
        ljmp   L_2FEB                                ; 2E30
L_2E33::
        mov    a, 0x35                               ; 2E33
        cjne   a, #0x0F, L_2E3E                      ; 2E35
L_2E38::
        mov    0x40, #0x23                           ; 2E38
        ljmp   L_2FCE                                ; 2E3B
L_2E3E::
        mov    c, 0x62                               ; 2E3E
        orl    c, 0x66                               ; 2E40
        jnc    L_2E38                                ; 2E42
        mov    0x41, #0x23                           ; 2E44
        ljmp   L_2FCE                                ; 2E47
L_2E4A::
        jnb    0x73, L_2E64                          ; 2E4A
        cjne   a, #0x0C, L_2E5C                      ; 2E4D
        setb   0x72                                  ; 2E50
        clr    0x73                                  ; 2E52
        mov    @r0, #0x18                            ; 2E54
        mov    dptr, #x_minmax_max                   ; 2E56
        ljmp   menu_edit_value                       ; 2E59
L_2E5C::
        cjne   a, #0x0F, L_2E6F                      ; 2E5C
        mov    @r0, #0x2D                            ; 2E5F
        ljmp   L_2FDA                                ; 2E61
L_2E64::
        jnb    0x72, L_2E7A                          ; 2E64
        cjne   a, #0x0C, L_2E72                      ; 2E67
        clr    0x72                                  ; 2E6A
        lcall  menu_clear_state                      ; 2E6C
L_2E6F::
        ljmp   L_2FEB                                ; 2E6F
L_2E72::
        cjne   a, #0x0F, L_2E6F                      ; 2E72
        mov    @r0, #0x2E                            ; 2E75
        ljmp   L_2FDA                                ; 2E77
L_2E7A::
        ljmp   L_3058                                ; 2E7A
L_2E7D::
        mov    a, 0x35                               ; 2E7D
        cjne   a, #0x0F, L_2E91                      ; 2E7F
        jnb    0x66, L_2E91                          ; 2E82
        jnb    cal_mode, L_2E8E                      ; 2E85
        cjne   @r0, #0x1E, L_2E8E                    ; 2E88
        mov    0x30, #0xA0                           ; 2E8B
L_2E8E::
        ljmp   L_2FD3                                ; 2E8E
L_2E91::
        cjne   @r0, #0x1E, L_2EA5                    ; 2E91
        cjne   a, #0x0C, L_2EFE                      ; 2E94
        mov    0x30, #0xA2                           ; 2E97
        clr    a                                     ; 2E9A
        mov    c, 0x58                               ; 2E9B
        cpl    c                                     ; 2E9D
        mov    0xE0, c                               ; 2E9E
        mov    0x31, a                               ; 2EA0
        ljmp   L_2FD3                                ; 2EA2
L_2EA5::
        cjne   @r0, #0x29, L_2F09                    ; 2EA5
        cjne   a, #0x0C, L_2EFE                      ; 2EA8
        jnb    0x66, L_2EF2                          ; 2EAB
        mov    dptr, #0x00EB                         ; 2EAE
        movx   a, @dptr                              ; 2EB1
        jnb    0xE4, L_2EB8                          ; 2EB2
        ljmp   L_2FD3                                ; 2EB5
L_2EB8::
        mov    @r0, #0x28                            ; 2EB8
        mov    dptr, #T_7138                         ; 2EBA
        lcall  menu_show_step                        ; 2EBD
        clr    0x58                                  ; 2EC0
        mov    dptr, #0x005A                         ; 2EC2
        movx   a, @dptr                              ; 2EC5
        jz     L_2ECD                                ; 2EC6
        jb     0x1B, L_2EE1                          ; 2EC8
        sjmp   L_2EE6                                ; 2ECB
L_2ECD::
        mov    dptr, #0x0053                         ; 2ECD
        mov    a, sfr_DPL                            ; 2ED0
        cjne   a, 0x1E, L_2EE9                       ; 2ED2
        mov    a, sfr_DPH                            ; 2ED5
        cjne   a, 0x1D, L_2EE9                       ; 2ED7
        inc    dptr                                  ; 2EDA
        movx   a, @dptr                              ; 2EDB
        anl    a, #0x38                              ; 2EDC
        cjne   a, #0x38, L_2EE6                      ; 2EDE
L_2EE1::
        mov    0x40, #0x31                           ; 2EE1
        setb   0x58                                  ; 2EE4
L_2EE6::
        ljmp   L_2FCE                                ; 2EE6
L_2EE9::
        lcall  nv_get_iface_config                   ; 2EE9
        jb     0xE7, L_2EE1                          ; 2EEC
        ljmp   L_2FCE                                ; 2EEF
L_2EF2::
        mov    0x30, #0xA0                           ; 2EF2
        jb     0x58, L_2EFB                          ; 2EF5
        mov    0x30, #0xA1                           ; 2EF8
L_2EFB::
        ljmp   L_2FD3                                ; 2EFB
L_2EFE::
        lcall  menu_key_to_char                      ; 2EFE
        jnb    0x5F, L_2F06                          ; 2F01
        mov    0x3D, a                               ; 2F04
L_2F06::
        ljmp   L_2FCE                                ; 2F06
L_2F09::
        cjne   @r0, #0x28, L_2F3C                    ; 2F09
        cjne   a, #0x0C, L_2F31                      ; 2F0C
        jnb    0x66, L_2EF2                          ; 2F0F
        mov    dptr, #0x005A                         ; 2F12
        movx   a, @dptr                              ; 2F15
        jz     L_2F1A                                ; 2F16
        sjmp   L_2F45                                ; 2F18
L_2F1A::
        mov    @r0, #0x26                            ; 2F1A
        mov    dptr, #T_711E                         ; 2F1C
        lcall  menu_show_step                        ; 2F1F
        lcall  nv_get_iface_config                   ; 2F22
        anl    a, #0x1F                              ; 2F25
        mov    0x31, a                               ; 2F27
        mov    r0, #0x3E                             ; 2F29
        lcall  put_2digits_iram                      ; 2F2B
        ljmp   L_2FCE                                ; 2F2E
L_2F31::
        lcall  menu_key_to_char                      ; 2F31
        jnb    0x5F, L_2F39                          ; 2F34
        mov    0x40, a                               ; 2F37
L_2F39::
        ljmp   L_2FCE                                ; 2F39
L_2F3C::
        cjne   @r0, #0x26, L_2F88                    ; 2F3C
        cjne   a, #0x0C, L_2F64                      ; 2F3F
        jnb    0x66, L_2F58                          ; 2F42
L_2F45::
        mov    @r0, #0x25                            ; 2F45
        mov    dptr, #T_7145                         ; 2F47
        lcall  menu_show_step                        ; 2F4A
        jnb    cr_enabled, L_2F55                    ; 2F4D
        mov    0x3E, #0x31                           ; 2F50
        clr    0x58                                  ; 2F53
L_2F55::
        ljmp   L_2FCE                                ; 2F55
L_2F58::
        jnb    0x58, L_2F5E                          ; 2F58
        ljmp   L_2FD3                                ; 2F5B
L_2F5E::
        mov    0x30, #0xA2                           ; 2F5E
        ljmp   L_2FD3                                ; 2F61
L_2F64::
        cjne   a, #0x0F, L_2F70                      ; 2F64
        mov    dptr, #T_711E                         ; 2F67
        lcall  menu_show_step                        ; 2F6A
        ljmp   L_2FCE                                ; 2F6D
L_2F70::
        mov    r0, #0x3E                             ; 2F70
        lcall  menu_digit_key                        ; 2F72
        mov    a, 0x31                               ; 2F75
        cjne   a, #0x1E, L_2F7D                      ; 2F77
        ljmp   L_2FCE                                ; 2F7A
L_2F7D::
        jc     L_2F85                                ; 2F7D
        mov    dptr, #T_711E                         ; 2F7F
        lcall  menu_show_step                        ; 2F82
L_2F85::
        ljmp   L_2FCE                                ; 2F85
L_2F88::
        cjne   @r0, #0x25, L_2F97                    ; 2F88
        cjne   a, #0x0C, L_2FBB                      ; 2F8B
        jnb    0x66, L_2F94                          ; 2F8E
        ljmp   L_2D45                                ; 2F91
L_2F94::
        ljmp   L_2EF2                                ; 2F94
L_2F97::
        cjne   @r0, #0x24, L_2FC5                    ; 2F97
        cjne   a, #0x0C, L_2FBB                      ; 2F9A
        jnb    0x66, L_2FB8                          ; 2F9D
        mov    @r0, #0xC8                            ; 2FA0
        mov    dptr, #T_7179                         ; 2FA2
        lcall  menu_show_step                        ; 2FA5
        mov    dptr, #T_59AF                         ; 2FA8
        clr    a                                     ; 2FAB
        movc   a, @a+dptr                            ; 2FAC
        mov    0x3E, a                               ; 2FAD
        mov    a, #0x01                              ; 2FAF
        movc   a, @a+dptr                            ; 2FB1
        mov    0x3F, a                               ; 2FB2
        clr    0x68                                  ; 2FB4
        sjmp   L_2FCE                                ; 2FB6
L_2FB8::
        ljmp   L_2EF2                                ; 2FB8
L_2FBB::
        lcall  menu_key_to_char                      ; 2FBB
        jnb    0x5F, L_2FC3                          ; 2FBE
        mov    0x3E, a                               ; 2FC1
L_2FC3::
        sjmp   L_2FCE                                ; 2FC3
L_2FC5::
        cjne   @r0, #0xC8, L_2FD3                    ; 2FC5
        cjne   a, #0x0C, L_2FCE                      ; 2FC8
        ljmp   L_2D36                                ; 2FCB
L_2FCE::
        lcall  menu_store_text                       ; 2FCE
        sjmp   L_2FE9                                ; 2FD1
L_2FD3::
        clr    0x5C                                  ; 2FD3
        lcall  menu_clear_state                      ; 2FD5
        sjmp   L_2FEB                                ; 2FD8
L_2FDA::
        mov    0x30, #0xA5                           ; 2FDA
        sjmp   L_2FEB                                ; 2FDD
L_2FDF::
        mov    0x30, #0xA0                           ; 2FDF
        sjmp   L_2FEB                                ; 2FE2
L_2FE4::
        mov    0x30, #0xA1                           ; 2FE4
        sjmp   L_2FEB                                ; 2FE7
L_2FE9::
        setb   0x21                                  ; 2FE9
L_2FEB::
        mov    dptr, #0x00A5                         ; 2FEB
        mov    r0, #0x2B                             ; 2FEE
        mov    r2, #0x19                             ; 2FF0
        ljmp   iram_to_xdata                         ; 2FF2

menu_key_to_char::
        setb   0x5F                                  ; 2FF5
        cjne   a, #0x0F, L_2FFF                      ; 2FF7
        mov    a, #0x2D                              ; 2FFA
        setb   0x66                                  ; 2FFC
        ret                                          ; 2FFE
L_2FFF::
        cjne   a, #0x00, L_3006                      ; 2FFF
        setb   0x58                                  ; 3002
        sjmp   L_300B                                ; 3004
L_3006::
        cjne   a, #0x01, L_3010                      ; 3006
        clr    0x58                                  ; 3009
L_300B::
        clr    0x66                                  ; 300B
        orl    a, #0x30                              ; 300D
        ret                                          ; 300F
L_3010::
        clr    0x5F                                  ; 3010
        ret                                          ; 3012

; show a CHECK/edit menu message
menu_show_step::
        setb   0x66                                  ; 3013
        clr    0x5F                                  ; 3015
        clr    0x63                                  ; 3017
        setb   0x58                                  ; 3019
        mov    r0, #0x38                             ; 301B
        mov    r2, #0x0C                             ; 301D
        ljmp   code_to_iram_copy                     ; 301F

; save menu context (IRAM 2Bh.. -> XDATA 0x00A5) and leave
menu_exit_a::
        mov    dptr, #0x00A8                         ; 3022
        movx   a, @dptr                              ; 3025
        jb     0xE0, L_304B                          ; 3026
        sjmp   L_3032                                ; 3029

menu_exit_b::
        mov    dptr, #0x00A8                         ; 302B
        movx   a, @dptr                              ; 302E
        jb     0xE0, L_3038                          ; 302F
L_3032::
        mov    dptr, #0x00AA                         ; 3032
        clr    a                                     ; 3035
        movx   @dptr, a                              ; 3036
L_3037::
        ret                                          ; 3037
L_3038::
        jnb    0xE4, L_3037                          ; 3038
        mov    dptr, #0x00A5                         ; 303B
        movx   a, @dptr                              ; 303E
        jnb    0xE4, L_304B                          ; 303F
        mov    dptr, #0x00A9                         ; 3042
        movx   a, @dptr                              ; 3045
        cjne   a, #0x29, L_304B                      ; 3046
        sjmp   L_3037                                ; 3049
L_304B::
        lcall  lcd_dashes_refresh                    ; 304B
        clr    0x22                                  ; 304E
        sjmp   L_3058                                ; 3050

menu_init::
        mov    0x35, #0xFF                           ; 3052
        lcall  key_scan                              ; 3055
L_3058::
        mov    0x30, #0x00                           ; 3058
        clr    a                                     ; 305B
        mov    0x2B, a                               ; 305C
        mov    0x2C, a                               ; 305E
        mov    0x2D, a                               ; 3060
        mov    0x2E, a                               ; 3062
        anl    0x26, #0xFC                           ; 3064
        ljmp   L_2FEB                                ; 3067

menu_clear_state::
        anl    0x2E, #0xCE                           ; 306A
        clr    0x68                                  ; 306D
        anl    0x26, #0xFC                           ; 306F
        clr    0x22                                  ; 3072

lcd_dashes_refresh::
        mov    dptr, #msg_table                      ; 3074
        lcall  lcd_show_message                      ; 3077
        ljmp   lcd_refresh                           ; 307A

; format the dB reference (XDATA 0x0075) for the edit menu
menu_show_dbm_ref::
        mov    dptr, #x_dbm_reference                ; 307D
        mov    r1, #0x34                             ; 3080
        lcall  fp_ld_xdata_r1                        ; 3082
        mov    a, #0x20                              ; 3085
        mov    r6, #0x64                             ; 3087
        mov    r1, #0x5B                             ; 3089
        mov    r0, #0x34                             ; 308B
        mov    dptr, #x_lcd_text_buf                 ; 308D
        mov    r7, #0x00                             ; 3090
        lcall  fp_format                             ; 3092
        clr    0x30                                  ; 3095
        mov    dptr, #0x0009                         ; 3097
        mov    a, #0x20                              ; 309A
        movx   @dptr, a                              ; 309C
        inc    dptr                                  ; 309D
        mov    a, #0x83                              ; 309E
        movx   @dptr, a                              ; 30A0
        mov    dptr, #x_dbm_reference                ; 30A1
        mov    r1, #0x34                             ; 30A4
        lcall  fp_ld_xdata_r1                        ; 30A6
        ret                                          ; 30A9

menu_set_flag::
        setb   0x68                                  ; 30AA

menu_enter_edit::
        setb   0x74                                  ; 30AC
        setb   0x66                                  ; 30AE
        setb   0x58                                  ; 30B0
        orl    0x26, #0x12                           ; 30B2
        clr    0x75                                  ; 30B5
        clr    0x5F                                  ; 30B7
        anl    0x2C, #0xF3                           ; 30B9
        mov    0x37, #0x00                           ; 30BC
        mov    0x43, #0x3D                           ; 30BF
        ret                                          ; 30C2

; (inferred) digit entry in the SHIFT edit menus
menu_edit_digits::
        mov    a, 0x35                               ; 30C3
        cjne   a, #0x0C, L_30CB                      ; 30C5
        setb   0x5F                                  ; 30C8
        ret                                          ; 30CA
L_30CB::
        cjne   a, #0x0B, L_30E1                      ; 30CB
        jnb    0x61, menu_load_text                  ; 30CE
        jb     0x62, menu_load_text                  ; 30D1
        lcall  menu_blink_cursor                     ; 30D4
        setb   0x62                                  ; 30D7
        mov    r3, #0x2E                             ; 30D9
        mov    0x40, #0x20                           ; 30DB
        ljmp   L_311E                                ; 30DE
L_30E1::
        cjne   a, #0x0A, L_30F9                      ; 30E1
        jnb    0x60, menu_load_text                  ; 30E4
        lcall  menu_load_text                        ; 30E7
        clr    0x58                                  ; 30EA
        mov    a, 0x38                               ; 30EC
        cjne   a, #0x2D, L_30F5                      ; 30EE
        mov    0x38, #0x2B                           ; 30F1
        ret                                          ; 30F4
L_30F5::
        mov    0x38, #0x2D                           ; 30F5
        ret                                          ; 30F8
L_30F9::
        cjne   a, #0x0F, L_3112                      ; 30F9

menu_start_blank::
        mov    0x37, #0x00                           ; 30FC
        setb   0x58                                  ; 30FF
        setb   0x66                                  ; 3101
        clr    0x5F                                  ; 3103
        anl    0x2C, #0xF3                           ; 3105
        mov    dptr, #T_7186                         ; 3108
        mov    r0, #0x38                             ; 310B
        mov    r2, #0x09                             ; 310D
        ljmp   code_to_iram_copy                     ; 310F
L_3112::
        jb     0x63, menu_load_text                  ; 3112
        cjne   a, #0x09, L_313D                      ; 3115
L_3118::
        orl    a, #0x30                              ; 3118
        mov    r3, a                                 ; 311A
        lcall  menu_blink_cursor                     ; 311B
L_311E::
        mov    a, 0x36                               ; 311E
        inc    0x37                                  ; 3120
        add    a, 0x37                               ; 3122
        cjne   a, #0x07, L_312D                      ; 3124
L_3127::
        add    a, #0x38                              ; 3127
        mov    r1, a                                 ; 3129
        mov    a, r3                                 ; 312A
        mov    @r1, a                                ; 312B
        ret                                          ; 312C
L_312D::
        jc     L_3127                                ; 312D
        jnb    0x62, L_3138                          ; 312F
        cjne   a, #0x08, L_3138                      ; 3132
        ljmp   L_3127                                ; 3135
L_3138::
        setb   0x63                                  ; 3138
        setb   0x62                                  ; 313A
        ret                                          ; 313C
L_313D::
        jc     L_3118                                ; 313D

menu_load_text::
        mov    dptr, #x_lcd_text_buf                 ; 313F
        mov    r0, #0x38                             ; 3142
        mov    r2, #0x0C                             ; 3144
        ljmp   xdata_to_iram                         ; 3146

menu_blink_cursor::
        jbc    0x66, L_314D                          ; 3149
        ret                                          ; 314C
L_314D::
        mov    dptr, #T_7189                         ; 314D
        mov    r0, #0x38                             ; 3150
        mov    r2, #0x09                             ; 3152
        jbc    0x58, L_3158                          ; 3154
        inc    r0                                    ; 3157
L_3158::
        ljmp   code_to_iram_copy                     ; 3158

menu_digit_key::
        cjne   a, #0x09, L_3182                      ; 315B
L_315E::
        jb     0x5F, L_3184                          ; 315E
        jnb    0x66, L_3171                          ; 3161
        mov    0x31, a                               ; 3164
        orl    a, #0x30                              ; 3166
        mov    @r0, a                                ; 3168
        inc    r0                                    ; 3169
        mov    @r0, #0x2D                            ; 316A
        clr    0x66                                  ; 316C
        clr    0x58                                  ; 316E
        ret                                          ; 3170
L_3171::
        xch    a, 0x31                               ; 3171
        mov    sfr_B, #0x0A                          ; 3173
        mul    ab                                    ; 3176
        add    a, 0x31                               ; 3177
        xch    a, 0x31                               ; 3179
        orl    a, #0x30                              ; 317B
        inc    r0                                    ; 317D
        mov    @r0, a                                ; 317E
        setb   0x5F                                  ; 317F
        ret                                          ; 3181
L_3182::
        jc     L_315E                                ; 3182
L_3184::
        ret                                          ; 3184

put_2digits_iram::
        mov    sfr_B, #0x0A                          ; 3185
        div    ab                                    ; 3188
        orl    a, #0x30                              ; 3189
        mov    @r0, a                                ; 318B
        orl    sfr_B, #0x30                          ; 318C
        inc    r0                                    ; 318F
        mov    @r0, sfr_B                            ; 3190
        ret                                          ; 3192

menu_edit_value::
        lcall  menu_set_value_ptr                    ; 3193
        mov    r1, #0x34                             ; 3196
        lcall  fp_ld_xdata_r1                        ; 3198
        ljmp   L_2FEB                                ; 319B

menu_store_text::
        mov    dptr, #x_lcd_text_buf                 ; 319E
        mov    r0, #0x38                             ; 31A1
        mov    r2, #0x0C                             ; 31A3
        ljmp   iram_to_xdata                         ; 31A5

menu_parse_number::
        mov    r0, #0x34                             ; 31A8
        mov    r1, #0x5F                             ; 31AA
        mov    dptr, #x_lcd_text_buf                 ; 31AC
        ljmp   parse_number_xdata                    ; 31AF

; XDATA 0x0098
menu_set_value_ptr::
        mov    r2, sfr_DPL                           ; 31B2
        mov    r3, sfr_DPH                           ; 31B4
        mov    a, r3                                 ; 31B6
        mov    dptr, #0x0098                         ; 31B7
        movx   @dptr, a                              ; 31BA
        inc    dptr                                  ; 31BB
        mov    a, r2                                 ; 31BC
        movx   @dptr, a                              ; 31BD
        setb   0x30                                  ; 31BE
        mov    sfr_DPL, r2                           ; 31C0
        mov    sfr_DPH, r3                           ; 31C2
        ret                                          ; 31C4

; PCF8574 0x4E/0x4F on the option bus: bit7 = data-hold probe button (PM9267), writes LED bit
probe_hold_poll::
        mov    a, #0x4E                              ; 31C5
        lcall  i2cA_read1                            ; 31C7
        jc     L_3239                                ; 31CA
        setb   0x2F                                  ; 31CC
        mov    r2, a                                 ; 31CE
        mov    a, meter_state                        ; 31CF
        anl    a, #0x0F                              ; 31D1
        cjne   a, #0x08, L_31EF                      ; 31D3
        jb     cal_mode, L_31EF                      ; 31D6
        mov    dptr, #0x00EB                         ; 31D9
        movx   a, @dptr                              ; 31DC
        jb     0xE4, L_31EF                          ; 31DD
        jb     0x0B, L_31EF                          ; 31E0
        mov    0x2F, #0x1C                           ; 31E3
        mov    0x30, #0xA2                           ; 31E6
        mov    0x31, #0x02                           ; 31E9
        clr    0x26                                  ; 31EC
        ret                                          ; 31EE
L_31EF::
        mov    a, r2                                 ; 31EF
        jb     0xE7, L_3217                          ; 31F0
        jb     0x27, L_3227                          ; 31F3
        lcall  key_debounce_delay                    ; 31F6
        mov    a, #0x4E                              ; 31F9
        lcall  i2cA_read1                            ; 31FB
        jb     0xE7, L_3227                          ; 31FE
        setb   0x27                                  ; 3201
        jb     0x0A, L_3227                          ; 3203
        jb     0x0B, L_320D                          ; 3206
        cpl    0x26                                  ; 3209
        sjmp   L_3227                                ; 320B
L_320D::
        clr    0x26                                  ; 320D
        mov    0x2F, #0x1D                           ; 320F
        mov    0x30, #0xA5                           ; 3212
        sjmp   L_3227                                ; 3215
L_3217::
        jnb    0x27, L_3227                          ; 3217
        lcall  key_debounce_delay                    ; 321A
        mov    a, #0x4E                              ; 321D
        lcall  i2cA_read1                            ; 321F
        jnb    0xE7, L_3227                          ; 3222
        clr    0x27                                  ; 3225
L_3227::
        mov    a, #0xFD                              ; 3227
        jb     0x26, L_322E                          ; 3229
        mov    a, #0xFF                              ; 322C
L_322E::
        mov    c, adc_alt_mode                       ; 322E
        cpl    c                                     ; 3230
        mov    0xE0, c                               ; 3231
        mov    r3, a                                 ; 3233
        mov    a, #0x4E                              ; 3234
        ljmp   i2cA_write1                           ; 3236
L_3239::
        anl    0x24, #0x3F                           ; 3239
        mov    a, meter_state                        ; 323C
        anl    a, #0x0F                              ; 323E
        cjne   a, #0x04, L_3245                      ; 3240
        sjmp   L_324C                                ; 3243
L_3245::
        cjne   a, #0x0B, L_324A                      ; 3245
        sjmp   L_324C                                ; 3248
L_324A::
        clr    0x2F                                  ; 324A
L_324C::
        cjne   a, #0x08, L_326B                      ; 324C
        mov    dptr, #0x00EB                         ; 324F
        movx   a, @dptr                              ; 3252
        jb     cal_mode, L_326B                      ; 3253
        jb     0xE4, L_326B                          ; 3256
        jb     0x0A, L_325F                          ; 3259
        jnb    0x0B, L_326B                          ; 325C
L_325F::
        jnb    0x3B, L_326B                          ; 325F
        mov    0x2F, #0x1C                           ; 3262
        mov    0x30, #0xA2                           ; 3265
        mov    0x31, #0x00                           ; 3268
L_326B::
        ret                                          ; 326B

; every 50 main-loop passes (24h.1): result -> LCD
task_display_update::
        mov    dptr, #0x00C1                         ; 326C
        movx   a, @dptr                              ; 326F
        jnb    0xE7, L_3274                          ; 3270
        ret                                          ; 3273
L_3274::
        mov    r0, #0x2B                             ; 3274
        mov    dptr, #0x009D                         ; 3276
        mov    r2, #0x08                             ; 3279
        lcall  xdata_to_iram                         ; 327B
        jb     0x32, L_3285                          ; 327E
        clr    0x7E                                  ; 3281
        sjmp   L_32AA                                ; 3283
L_3285::
        jnb    0x7E, L_32A5                          ; 3285
        mov    a, 0x30                               ; 3288
        orl    a, 0x31                               ; 328A
        jnz    L_32A3                                ; 328C
        clr    0x22                                  ; 328E
        anl    0x26, #0xF8                           ; 3290
        clr    0x7E                                  ; 3293
        jb     0x33, L_32AA                          ; 3295
        mov    dptr, #msg_table                      ; 3298
        lcall  lcd_show_message                      ; 329B
        lcall  lcd_refresh                           ; 329E
        sjmp   L_32C9                                ; 32A1
L_32A3::
        sjmp   L_32C6                                ; 32A3
L_32A5::
        setb   0x7E                                  ; 32A5
        lcall  out_format_params_a                   ; 32A7
L_32AA::
        mov    a, meter_state                        ; 32AA
        anl    a, #0x0E                              ; 32AC
        cjne   a, #0x06, L_32B3                      ; 32AE
        sjmp   L_32B6                                ; 32B1
L_32B3::
        jb     0x2E, L_32E4                          ; 32B3
L_32B6::
        jb     0x31, L_32BE                          ; 32B6
        lcall  display_show_held_value               ; 32B9
        sjmp   L_32CC                                ; 32BC
L_32BE::
        jnb    0x30, L_32C6                          ; 32BE
        lcall  lcd_format_minmax                     ; 32C1
        sjmp   L_32E7                                ; 32C4
L_32C6::
        jb     0x22, L_32E4                          ; 32C6
L_32C9::
        lcall  lcd_unit_symbols                      ; 32C9
L_32CC::
        lcall  lcd_build_annunciators                ; 32CC
        lcall  lcd_prepare_value                     ; 32CF
        lcall  lcd_send_frame                        ; 32D2
        mov    a, sfr_DPL                            ; 32D5
        add    a, #0xFE                              ; 32D7
        mov    sfr_DPL, a                            ; 32D9
        jc     L_32DF                                ; 32DB
        dec    sfr_DPH                               ; 32DD
L_32DF::
        mov    a, #0x23                              ; 32DF
        movx   @dptr, a                              ; 32E1
        sjmp   L_32F0                                ; 32E2
L_32E4::
        lcall  lcd_clear_flags                       ; 32E4
L_32E7::
        lcall  lcd_build_annunciators                ; 32E7
        lcall  lcd_prepare_value                     ; 32EA
        lcall  lcd_send_frame                        ; 32ED
L_32F0::
        clr    0x21                                  ; 32F0
        mov    r0, #0x2B                             ; 32F2
        mov    dptr, #0x009D                         ; 32F4
        mov    r2, #0x08                             ; 32F7
        ljmp   iram_to_xdata                         ; 32F9

display_show_held_value::
        jnb    0x33, L_3334                          ; 32FC
        clr    0x33                                  ; 32FF
        mov    r0, #0x57                             ; 3301
        mov    dptr, #0x0089                         ; 3303
        lcall  fp_ld_xdata_r0                        ; 3306
        mov    dptr, #0x0067                         ; 3309
        movx   a, @dptr                              ; 330C
        mov    0x2A, a                               ; 330D
        inc    dptr                                  ; 330F
        movx   a, @dptr                              ; 3310
        mov    0x53, a                               ; 3311
        lcall  lcd_format_reading                    ; 3313
        mov    dptr, #0x005A                         ; 3316
        movx   a, @dptr                              ; 3319
        cjne   a, #0x05, L_3334                      ; 331A
        mov    a, 0x2A                               ; 331D
        anl    a, #0xA6                              ; 331F
        jnz    L_3334                                ; 3321
        setb   0x19                                  ; 3323
        mov    r0, #0x09                             ; 3325
        mov    r1, #0x00                             ; 3327
        mov    r2, #0x5B                             ; 3329
        mov    r3, #0x00                             ; 332B
        mov    dptr, #x_lcd_text_buf                 ; 332D
        clr    c                                     ; 3330
        lcall  xdata_block_xfer                      ; 3331
L_3334::
        ljmp   lcd_unit_symbols                      ; 3334

; (inferred) MIN/MAX value display
lcd_format_minmax::
        mov    dptr, #0x0098                         ; 3337
        movx   a, @dptr                              ; 333A
        mov    r2, a                                 ; 333B
        inc    dptr                                  ; 333C
        movx   a, @dptr                              ; 333D
        mov    sfr_DPH, r2                           ; 333E
        mov    sfr_DPL, a                            ; 3340
        mov    r0, #0x57                             ; 3342
        lcall  fp_ld_xdata_r0                        ; 3344
        mov    dptr, #0x00A8                         ; 3347
        movx   a, @dptr                              ; 334A
        jnb    0xE3, L_3353                          ; 334B
        mov    dptr, #0x0069                         ; 334E
        sjmp   L_3359                                ; 3351
L_3353::
        jnb    0xE2, L_3362                          ; 3353
        mov    dptr, #0x006B                         ; 3356
L_3359::
        movx   a, @dptr                              ; 3359
        mov    0x2A, a                               ; 335A
        inc    dptr                                  ; 335C
        movx   a, @dptr                              ; 335D
        mov    0x53, a                               ; 335E
        sjmp   L_337F                                ; 3360
L_3362::
        mov    0x2A, #0x00                           ; 3362
        mov    dptr, #0x00A7                         ; 3365
        movx   a, @dptr                              ; 3368
        jnb    0xE3, L_3374                          ; 3369
        mov    dptr, #0x006D                         ; 336C
        movx   a, @dptr                              ; 336F
        mov    0x53, a                               ; 3370
        sjmp   L_337F                                ; 3372
L_3374::
        clr    a                                     ; 3374
        mov    a, meter_state                        ; 3375
        anl    a, #0x70                              ; 3377
        mov    0x53, a                               ; 3379
        mov    c, 0x2E                               ; 337B
        mov    0x73, c                               ; 337D
L_337F::
        lcall  lcd_format_reading                    ; 337F
        ljmp   lcd_unit_symbols                      ; 3382

; value -> LCD text buffer XDATA 0x0000; 'r' at pos 8 in cal mode, "NC" when uncalibrated
lcd_format_reading::
        clr    0x34                                  ; 3385
        mov    r1, #0x53                             ; 3387
        lcall  lcd_copy_range_bits                   ; 3389
        mov    a, 0x53                               ; 338C
        mov    c, 0xE7                               ; 338E
        mov    0x73, c                               ; 3390
        mov    c, 0x50                               ; 3392
        mov    0x6D, c                               ; 3394
        mov    a, 0x57                               ; 3396
        mov    c, 0xE7                               ; 3398
        mov    0x56, c                               ; 339A
        clr    0xE7                                  ; 339C
        mov    0x57, a                               ; 339E
        mov    a, meter_state                        ; 33A0
        anl    a, #0x0F                              ; 33A2
        cjne   a, #0x0D, L_33B7                      ; 33A4
        lcall  fp_cmp_ten                            ; 33A7
        jnc    L_33B1                                ; 33AA
        mov    dptr, #T_715F                         ; 33AC
        sjmp   L_33B4                                ; 33AF
L_33B1::
        mov    dptr, #T_7152                         ; 33B1
L_33B4::
        ljmp   lcd_copy_message                      ; 33B4
L_33B7::
        jnb    0x51, L_33DB                          ; 33B7
        mov    dptr, #T_70ED                         ; 33BA
        lcall  lcd_show_msg_thunk                    ; 33BD
        lcall  value_is_signed                       ; 33C0
        jc     L_33CF                                ; 33C3
        ret                                          ; 33C5
L_33C6::
        lcall  lcd_set_sign                          ; 33C6
        mov    dptr, #T_7108                         ; 33C9
        lcall  lcd_show_msg_thunk                    ; 33CC
L_33CF::
        mov    a, #0x2B                              ; 33CF
        jnb    0x56, L_33D6                          ; 33D1
        mov    a, #0x2D                              ; 33D4
L_33D6::
        mov    dptr, #x_lcd_text_buf                 ; 33D6
        movx   @dptr, a                              ; 33D9
        ret                                          ; 33DA
L_33DB::
        jnb    0x52, L_33E4                          ; 33DB
        mov    dptr, #T_70FF                         ; 33DE
        ljmp   lcd_copy_message                      ; 33E1
L_33E4::
        mov    r1, #0x5F                             ; 33E4
        mov    r0, #0x57                             ; 33E6
        jnb    0x10, L_33ED                          ; 33E8
        sjmp   L_33F8                                ; 33EB
L_33ED::
        mov    a, 0x2E                               ; 33ED
        anl    a, #0x70                              ; 33EF
        swap   a                                     ; 33F1
        lcall  lcd_decimal_point                     ; 33F2
        ljmp   L_3455                                ; 33F5
L_33F8::
        jnb    0x55, L_3401                          ; 33F8
        mov    dptr, #T_70F6                         ; 33FB
        ljmp   lcd_show_msg_thunk                    ; 33FE
L_3401::
        mov    r0, #0x57                             ; 3401
        mov    a, #0x03                              ; 3403
        lcall  fp_ld_pow10_r1                        ; 3405
        lcall  fp_cmp                                ; 3408
        jc     L_3410                                ; 340B
        ljmp   L_33C6                                ; 340D
L_3410::
        jb     0x30, L_342F                          ; 3410
        mov    r0, #0x5B                             ; 3413
        mov    dptr, #0x0116                         ; 3415
        lcall  i24_ld_xdata_r0                       ; 3418
        mov    r1, #0x5F                             ; 341B
        mov    dptr, #T_70D5                         ; 341D
        lcall  i24_ld_code_r1                        ; 3420
        lcall  i24_cmp                               ; 3423
        jnc    L_342F                                ; 3426
        mov    0x35, #0x03                           ; 3428
        mov    r5, #0x00                             ; 342B
        sjmp   L_3434                                ; 342D
L_342F::
        mov    0x35, #0x04                           ; 342F
        mov    r5, #0x01                             ; 3432
L_3434::
        mov    r0, #0x57                             ; 3434
        lcall  lcd_set_sign                          ; 3436
        mov    r7, #0x00                             ; 3439
        mov    a, 0x35                               ; 343B
        add    a, #0xFF                              ; 343D
        swap   a                                     ; 343F
        orl    a, 0x35                               ; 3440
        mov    r6, a                                 ; 3442
        mov    dptr, #x_lcd_text_buf                 ; 3443
        mov    a, r5                                 ; 3446
        orl    a, #0xF0                              ; 3447
        lcall  fp_format                             ; 3449
        lcall  lcd_pad_spaces                        ; 344C
        mov    a, #0x23                              ; 344F
        movx   @dptr, a                              ; 3451
        ljmp   lcd_append_nc                         ; 3452
L_3455::
        lcall  resolution_digits                     ; 3455
        jb     0x57, L_345E                          ; 3458
        jnb    0x53, L_3474                          ; 345B
L_345E::
        mov    r1, a                                 ; 345E
        mov    a, meter_state                        ; 345F
        anl    a, #0x0F                              ; 3461
        cjne   a, #0x08, L_3472                      ; 3463
        mov    a, 0x2E                               ; 3466
        anl    a, #0x70                              ; 3468
        swap   a                                     ; 346A
        lcall  range_decimal_pos                     ; 346B
        cpl    a                                     ; 346E
        inc    a                                     ; 346F
        sjmp   L_3474                                ; 3470
L_3472::
        mov    a, r1                                 ; 3472
        dec    a                                     ; 3473
L_3474::
        mov    r6, a                                 ; 3474
        mov    0x35, a                               ; 3475
        dec    a                                     ; 3477
        swap   a                                     ; 3478
        orl    a, r6                                 ; 3479
        mov    r6, a                                 ; 347A
        mov    a, 0x2E                               ; 347B
        anl    a, #0x70                              ; 347D
        swap   a                                     ; 347F
        lcall  range_decimal_pos                     ; 3480
        add    a, 0x35                               ; 3483
        mov    r3, a                                 ; 3485
        mov    r4, #0x40                             ; 3486
        jnb    0x11, L_3495                          ; 3488
        jb     0x32, L_3495                          ; 348B
        mov    dptr, #0x00A7                         ; 348E
        movx   a, @dptr                              ; 3491
        jnb    0xE0, L_349C                          ; 3492
L_3495::
        lcall  func_class_check                      ; 3495
        jc     L_349C                                ; 3498
        mov    r4, #0x00                             ; 349A
L_349C::
        clr    c                                     ; 349C
        mov    a, r7                                 ; 349D
        subb   a, r3                                 ; 349E
        mov    r5, a                                 ; 349F
        add    a, 0x35                               ; 34A0
        xch    a, r5                                 ; 34A2
        lcall  lcd_round_value                       ; 34A3
        lcall  fp_cmp                                ; 34A6
        jc     L_34F5                                ; 34A9
        mov    a, 0x35                               ; 34AB
        add    a, r7                                 ; 34AD
        mov    r5, a                                 ; 34AE
        mov    a, r7                                 ; 34AF
        lcall  lcd_round_value                       ; 34B0
        lcall  fp_cmp                                ; 34B3
        jnc    L_34BF                                ; 34B6
        lcall  lcd_set_sign                          ; 34B8
        mov    a, #0xA0                              ; 34BB
        sjmp   L_34FB                                ; 34BD
L_34BF::
        mov    a, r7                                 ; 34BF
        jb     0x76, L_34F2                          ; 34C0
        jb     0x75, L_34D3                          ; 34C3
        jb     0x74, L_34D3                          ; 34C6
        jb     0x03, L_34F2                          ; 34C9
        clr    0x76                                  ; 34CC
        orl    0x2E, #0x30                           ; 34CE
        sjmp   L_34DA                                ; 34D1
L_34D3::
        jz     L_34F2                                ; 34D3
        setb   0x76                                  ; 34D5
        anl    0x2E, #0xCF                           ; 34D7
L_34DA::
        mov    a, r7                                 ; 34DA
        add    a, #0x03                              ; 34DB
        mov    r7, a                                 ; 34DD
        mov    a, 0x35                               ; 34DE
        add    a, r7                                 ; 34E0
        mov    r5, a                                 ; 34E1
        mov    a, r7                                 ; 34E2
        lcall  lcd_round_value                       ; 34E3
        lcall  fp_cmp                                ; 34E6
        jnc    L_34F2                                ; 34E9
        lcall  lcd_set_sign                          ; 34EB
        mov    a, #0xA0                              ; 34EE
        sjmp   L_34FB                                ; 34F0
L_34F2::
        ljmp   L_3515                                ; 34F2
L_34F5::
        lcall  lcd_set_sign                          ; 34F5
        mov    a, r3                                 ; 34F8
        orl    a, #0xB0                              ; 34F9
L_34FB::
        orl    a, r4                                 ; 34FB
        mov    dptr, #x_lcd_text_buf                 ; 34FC
        lcall  fp_format                             ; 34FF
        lcall  lcd_pad_spaces                        ; 3502
        mov    a, #0x23                              ; 3505
        movx   @dptr, a                              ; 3507
        jnb    cal_mode, L_3512                      ; 3508
        mov    dptr, #0x0008                         ; 350B
        mov    a, #0x72                              ; 350E
        movx   @dptr, a                              ; 3510
        ret                                          ; 3511
L_3512::
        ljmp   lcd_append_nc                         ; 3512
L_3515::
        mov    a, r7                                 ; 3515
        add    a, #0x0D                              ; 3516
        mov    r5, a                                 ; 3518
        add    a, #0xFC                              ; 3519
        lcall  lcd_round_value                       ; 351B
        lcall  fp_cmp                                ; 351E
        jc     L_3526                                ; 3521
        ljmp   L_33C6                                ; 3523
L_3526::
        mov    a, r7                                 ; 3526
        cpl    a                                     ; 3527
        inc    a                                     ; 3528
        lcall  fp_ld_pow10_r1                        ; 3529
        mov    a, r4                                 ; 352C
        push   sfr_ACC                               ; 352D
        lcall  fp_mul                                ; 352F
        pop    sfr_ACC                               ; 3532
        mov    r4, a                                 ; 3534
        mov    dptr, #T_70DC                         ; 3535
        lcall  fp_ld_code_r1                         ; 3538
        lcall  fp_cmp                                ; 353B
        jnc    L_3544                                ; 353E
        mov    a, #0x88                              ; 3540
        sjmp   L_3548                                ; 3542
L_3544::
        mov    a, #0xB0                              ; 3544
        mov    r7, #0x09                             ; 3546
L_3548::
        orl    a, r4                                 ; 3548
        mov    0x35, #0x04                           ; 3549
        mov    r6, #0x34                             ; 354C
        lcall  lcd_set_sign                          ; 354E
        mov    dptr, #x_lcd_text_buf                 ; 3551
        lcall  fp_format                             ; 3554
        mov    dptr, #0x0009                         ; 3557
        movx   a, @dptr                              ; 355A
        mov    dptr, #0x0008                         ; 355B
        movx   @dptr, a                              ; 355E
        inc    dptr                                  ; 355F
        mov    a, #0x23                              ; 3560
        movx   @dptr, a                              ; 3562
        ljmp   lcd_append_nc                         ; 3563

lcd_pad_spaces::
        mov    dptr, #0x0002                         ; 3566
        mov    a, 0x35                               ; 3569
        lcall  dptr_add_a_b                          ; 356B
        cpl    a                                     ; 356E
        inc    a                                     ; 356F
        add    a, #0x07                              ; 3570
        jz     L_357B                                ; 3572
        mov    r2, a                                 ; 3574
        mov    a, #0x20                              ; 3575
L_3577::
        movx   @dptr, a                              ; 3577
        inc    dptr                                  ; 3578
        djnz   r2, L_3577                            ; 3579
L_357B::
        ret                                          ; 357B

; "NC" at text positions 7-8
lcd_append_nc::
        jnb    0x54, L_3597                          ; 357C
        mov    dptr, #0x0007                         ; 357F
        movx   a, @dptr                              ; 3582
        clr    sbit_F0                               ; 3583
        cjne   a, #0x2E, L_358C                      ; 3585
        setb   sbit_F0                               ; 3588
        dec    sfr_DPL                               ; 358A
L_358C::
        mov    a, #0x4E                              ; 358C
        movx   @dptr, a                              ; 358E
        inc    dptr                                  ; 358F
        jnb    sbit_F0, L_3594                       ; 3590
        inc    dptr                                  ; 3593
L_3594::
        mov    a, #0x43                              ; 3594
        movx   @dptr, a                              ; 3596
L_3597::
        ret                                          ; 3597

; per-function jump table 0x35C8 sets the unit annunciator bits
lcd_unit_symbols::
        jnb    0x34, L_35A6                          ; 3598
        clr    0x34                                  ; 359B
        mov    r1, #0x20                             ; 359D
        lcall  lcd_copy_range_bits                   ; 359F
        mov    c, 0x2E                               ; 35A2
        mov    0x73, c                               ; 35A4
L_35A6::
        mov    r2, #0x20                             ; 35A6
        mov    r3, #0x20                             ; 35A8
        jnb    0x10, L_35B3                          ; 35AA
        mov    r2, #0x64                             ; 35AD
        mov    r3, #0x42                             ; 35AF
        sjmp   L_35B6                                ; 35B1
L_35B3::
        lcall  lcd_mode_symbols                      ; 35B3
L_35B6::
        lcall  lcd_insert_unit_char                  ; 35B6
        lcall  lcd_clear_flags                       ; 35B9
        mov    a, meter_state                        ; 35BC
        anl    a, #0x0F                              ; 35BE
        mov    sfr_B, #0x03                          ; 35C0
        mul    ab                                    ; 35C3
        mov    dptr, #L_35C8                         ; 35C4
        jmp    @a+dptr                               ; 35C7
L_35C8::
        ret                                          ; 35C8
T_35C9::
        .db 0x00, 0x00                                                                       ; 35C9 ..
L_35CB::
        setb   0x6A                                  ; 35CB
        ret                                          ; 35CD
L_35CE::
        setb   0x6B                                  ; 35CE
        ret                                          ; 35D0
L_35D1::
        sjmp   L_35F2                                ; 35D1
T_35D3::
        .db 0x00                                                                             ; 35D3 .
L_35D4::
        setb   0x69                                  ; 35D4
        ret                                          ; 35D6
L_35D7::
        setb   0x68                                  ; 35D7
        ret                                          ; 35D9
L_35DA::
        setb   0x6A                                  ; 35DA
        ret                                          ; 35DC
L_35DD::
        setb   0x6B                                  ; 35DD
        ret                                          ; 35DF
L_35E0::
        setb   0x5E                                  ; 35E0
        ret                                          ; 35E2
L_35E3::
        ret                                          ; 35E3
T_35E4::
        .db 0x00, 0x00                                                                       ; 35E4 ..
L_35E6::
        setb   0x59                                  ; 35E6
        ret                                          ; 35E8
L_35E9::
        ret                                          ; 35E9
T_35EA::
        .db 0x00, 0x00                                                                       ; 35EA ..
L_35EC::
        setb   0x6E                                  ; 35EC
        ret                                          ; 35EE
L_35EF::
        setb   0x6F                                  ; 35EF
        ret                                          ; 35F1
L_35F2::
        setb   0x64                                  ; 35F2
        sjmp   L_35DD                                ; 35F4

lcd_copy_range_bits::
        anl    0x2E, #0x8F                           ; 35F6
        mov    a, @r1                                ; 35F9
        anl    a, #0x70                              ; 35FA
        orl    0x2E, a                               ; 35FC
        ret                                          ; 35FE

; (inferred)
lcd_mode_symbols::
        jb     0x03, L_3640                          ; 35FF
        jb     0x02, L_361E                          ; 3602
        jb     0x01, L_3610                          ; 3605
        jb     0x00, L_3610                          ; 3608
        mov    r2, #0x56                             ; 360B
        mov    r3, #0x70                             ; 360D
        ret                                          ; 360F
L_3610::
        jb     0x76, L_361B                          ; 3610
        jb     0x75, L_361B                          ; 3613
        jb     0x74, L_361B                          ; 3616
L_3619::
        mov    r2, #0x6D                             ; 3619
L_361B::
        mov    r3, #0x56                             ; 361B
        ret                                          ; 361D
L_361E::
        jnb    0x01, L_362F                          ; 361E
        mov    r3, #0x41                             ; 3621
        jb     0x73, L_3675                          ; 3623
        jb     0x76, L_362C                          ; 3626
        mov    r2, #0x75                             ; 3629
        ret                                          ; 362B
L_362C::
        mov    r2, #0x6D                             ; 362C
        ret                                          ; 362E
L_362F::
        mov    r3, #0x83                             ; 362F
L_3631::
        jnb    0x76, L_3637                          ; 3631
        mov    r2, #0x4D                             ; 3634
        ret                                          ; 3636
L_3637::
        jb     0x75, L_363D                          ; 3637
        jnb    0x74, L_3675                          ; 363A
L_363D::
        mov    r2, #0x6B                             ; 363D
        ret                                          ; 363F
L_3640::
        jnb    0x02, L_3647                          ; 3640
        jnb    0x00, L_3619                          ; 3643
        ret                                          ; 3646
L_3647::
        jb     0x01, L_366A                          ; 3647
        jb     0x00, L_365F                          ; 364A
        jb     time_start_negslope, L_3654           ; 364D
        mov    r2, #0x81                             ; 3650
        sjmp   L_3656                                ; 3652
L_3654::
        mov    r2, #0x82                             ; 3654
L_3656::
        jb     time_stop_negslope, L_365C            ; 3656
        mov    r3, #0x81                             ; 3659
        ret                                          ; 365B
L_365C::
        mov    r3, #0x82                             ; 365C
        ret                                          ; 365E
L_365F::
        mov    r3, #0x46                             ; 365F
        jnb    0x76, L_3667                          ; 3661
        mov    r2, #0x75                             ; 3664
        ret                                          ; 3666
L_3667::
        mov    r2, #0x6E                             ; 3667
        ret                                          ; 3669
L_366A::
        jb     0x00, L_3671                          ; 366A
        mov    r3, #0x48                             ; 366D
        sjmp   L_3631                                ; 366F
L_3671::
        mov    r2, #0x80                             ; 3671
        mov    r3, #0x43                             ; 3673
L_3675::
        ret                                          ; 3675

; (inferred) mode/speed/trigger annunciators (0x00A7/0x00A8)
lcd_build_annunciators::
        anl    0x2C, #0xF8                           ; 3676
        jnb    0x12, L_368C                          ; 3679
        jb     speed_b1, L_368A                      ; 367C
        jb     speed_b0, L_3686                      ; 367F
        setb   0x60                                  ; 3682
        sjmp   L_368C                                ; 3684
L_3686::
        setb   0x61                                  ; 3686
        sjmp   L_368C                                ; 3688
L_368A::
        setb   0x62                                  ; 368A
L_368C::
        mov    c, 0x0B                               ; 368C
        orl    c, 0x0A                               ; 368E
        mov    0x65, c                               ; 3690
        mov    dptr, #0x00EB                         ; 3692
        movx   a, @dptr                              ; 3695
        mov    c, 0xE4                               ; 3696
        mov    0x66, c                               ; 3698
        mov    c, sbit_RXD                           ; 369A
        cpl    c                                     ; 369C
        mov    0x72, c                               ; 369D
        clr    0x67                                  ; 369F
        anl    0x2B, #0x42                           ; 36A1
        mov    dptr, #0x00A8                         ; 36A4
        movx   a, @dptr                              ; 36A7
        anl    0x2F, #0xC0                           ; 36A8
        mov    c, cal_hot                            ; 36AB
        jnb    cal_mode, L_36B5                      ; 36AD
        mov    0x7D, c                               ; 36B0
        cpl    c                                     ; 36B2
        mov    0x7C, c                               ; 36B3
L_36B5::
        orl    0x2B, a                               ; 36B5
        mov    c, meter_autorange                    ; 36B7
        cpl    c                                     ; 36B9
        mov    0x5F, c                               ; 36BA
        jb     0x32, L_371F                          ; 36BC
        mov    dptr, #0x00A7                         ; 36BF
        movx   a, @dptr                              ; 36C2
        mov    r7, a                                 ; 36C3
        jnb    0xE0, L_36DC                          ; 36C4
        mov    a, 0x30                               ; 36C7
        orl    a, 0x31                               ; 36C9
        jnz    L_36D2                                ; 36CB
        lcall  out_format_params_b                   ; 36CD
        cpl    0x7F                                  ; 36D0
L_36D2::
        mov    c, 0x7F                               ; 36D2
        mov    0x78, c                               ; 36D4
        mov    a, r7                                 ; 36D6
        anl    c, 0xE3                               ; 36D7
        mov    0x7B, c                               ; 36D9
        ret                                          ; 36DB
L_36DC::
        mov    a, meter_state                        ; 36DC
        anl    a, #0x0F                              ; 36DE
        cjne   a, #0x0A, L_3717                      ; 36E0
        clr    0x6B                                  ; 36E3
        jb     0x0A, L_36EB                          ; 36E5
        jnb    0x0B, L_36EE                          ; 36E8
L_36EB::
        jnb    trigger_pending, L_3717               ; 36EB
L_36EE::
        mov    a, 0x30                               ; 36EE
        orl    a, 0x31                               ; 36F0
        jnz    L_3711                                ; 36F2
        lcall  out_format_params_b                   ; 36F4
        cpl    0x7F                                  ; 36F7
        jnb    0x7F, L_3711                          ; 36F9
        jb     speed_b0, L_3711                      ; 36FC
        jb     speed_b1, L_3711                      ; 36FF
        mov    r2, #0x03                             ; 3702
L_3704::
        clr    c                                     ; 3704
        mov    a, 0x30                               ; 3705
        rlc    a                                     ; 3707
        mov    0x30, a                               ; 3708
        mov    a, 0x31                               ; 370A
        rlc    a                                     ; 370C
        mov    0x31, a                               ; 370D
        djnz   r2, L_3704                            ; 370F
L_3711::
        mov    c, 0x7F                               ; 3711
        mov    0x6B, c                               ; 3713
        sjmp   L_371F                                ; 3715
L_3717::
        clr    0x7F                                  ; 3717
        mov    0x30, #0x00                           ; 3719
        mov    0x31, #0x00                           ; 371C
L_371F::
        mov    c, 0x11                               ; 371F
        mov    0x7B, c                               ; 3721
        ret                                          ; 3723

lcd_round_value::
        mov    0x36, r5                              ; 3724
        mov    r1, #0x5B                             ; 3726
        mov    r0, #0x5F                             ; 3728
        lcall  fp_ld_pow10_r1                        ; 372A
        lcall  fp_copy_r1_to_r0                      ; 372D
        dec    @r0                                   ; 3730
        dec    @r0                                   ; 3731
        lcall  fp_sub                                ; 3732
        mov    a, 0x36                               ; 3735
        lcall  fp_ld_pow10_r1                        ; 3737
        lcall  fp_add                                ; 373A
        mov    r0, #0x57                             ; 373D
        mov    r1, #0x5F                             ; 373F
        ret                                          ; 3741

lcd_set_sign::
        xch    a, 0x57                               ; 3742
        mov    c, 0x56                               ; 3744
        mov    0xE7, c                               ; 3746
        xch    a, 0x57                               ; 3748
        ret                                          ; 374A

lcd_insert_unit_char::
        mov    r4, #0x0A                             ; 374B
        dec    r4                                    ; 374D
        mov    dptr, #0x0007                         ; 374E
L_3751::
        inc    dptr                                  ; 3751
        movx   a, @dptr                              ; 3752
        djnz   r4, L_3756                            ; 3753
        ret                                          ; 3755
L_3756::
        cjne   a, #0x23, L_3751                      ; 3756
        mov    a, r2                                 ; 3759
        movx   @dptr, a                              ; 375A
        inc    dptr                                  ; 375B
        mov    a, r3                                 ; 375C
        movx   @dptr, a                              ; 375D
        ret                                          ; 375E

; XDATA 0x009F..0x00A3
display_timer_init::
        clr    a                                     ; 375F
        mov    dptr, #0x009F                         ; 3760
        movx   @dptr, a                              ; 3763
        mov    a, #0x80                              ; 3764
        mov    dptr, #0x00A0                         ; 3766
        movx   @dptr, a                              ; 3769
        mov    a, #0x05                              ; 376A
        mov    dptr, #0x00A2                         ; 376C
        movx   @dptr, a                              ; 376F
        inc    dptr                                  ; 3770
        movx   @dptr, a                              ; 3771
        ret                                          ; 3772

lcd_clear_flags::
        clr    0x64                                  ; 3773
        anl    0x2B, #0xBD                           ; 3775
        anl    0x2D, #0x30                           ; 3778
        ret                                          ; 377B

; C=1: value shown with sign (VDC, IDC, degC, Vp+, Vp-, or dB/rel/cal-enable); verified
value_is_signed::
        jb     0x1C, L_37A3                          ; 377C
        jb     cal_enable, L_37A3                    ; 377F
        jb     0x11, L_37A3                          ; 3782

; (inferred) C depends on function/peak/dB state
func_class_check::
        jb     0x10, L_37A3                          ; 3785
        mov    a, meter_state                        ; 3788
        anl    a, #0x0F                              ; 378A
        jnz    L_3796                                ; 378C
        jnb    peak_mode_b1, L_37A3                  ; 378E
        jnb    peak_mode_b0, L_37A3                  ; 3791
        sjmp   L_37A5                                ; 3794
L_3796::
        cjne   a, #0x01, L_379B                      ; 3796
        sjmp   L_37A3                                ; 3799
L_379B::
        cjne   a, #0x06, L_37A0                      ; 379B
        sjmp   L_37A3                                ; 379E
L_37A0::
        cjne   a, #0x0B, L_37A5                      ; 37A0
L_37A3::
        setb   c                                     ; 37A3
        ret                                          ; 37A4
L_37A5::
        clr    c                                     ; 37A5
        ret                                          ; 37A6

code_to_iram_copy::
        clr    a                                     ; 37A7
        movc   a, @a+dptr                            ; 37A8
        mov    @r0, a                                ; 37A9
        inc    r0                                    ; 37AA
        inc    dptr                                  ; 37AB
        djnz   r2, code_to_iram_copy                 ; 37AC
        ret                                          ; 37AE

; (inferred)
lcd_decimal_point::
        mov    r7, #0x00                             ; 37AF
        jb     0x03, L_37D6                          ; 37B1
        jb     0x02, L_37BC                          ; 37B4
        jnz    L_37F1                                ; 37B7
        mov    r7, #0xFD                             ; 37B9
        ret                                          ; 37BB
L_37BC::
        jb     0x01, L_37CA                          ; 37BC
L_37BF::
        jnb    0xE2, L_37C5                          ; 37BF
        mov    r7, #0x06                             ; 37C2
        ret                                          ; 37C4
L_37C5::
        jz     L_37F1                                ; 37C5
        mov    r7, #0x03                             ; 37C7
        ret                                          ; 37C9
L_37CA::
        jb     0x73, L_37F1                          ; 37CA
        jnb    0xE2, L_37D3                          ; 37CD
        mov    r7, #0xFD                             ; 37D0
        ret                                          ; 37D2
L_37D3::
        mov    r7, #0xFA                             ; 37D3
        ret                                          ; 37D5
L_37D6::
        jb     0x02, L_37EC                          ; 37D6
        jb     0x01, L_37E8                          ; 37D9
        jnb    0x00, L_37F1                          ; 37DC
        jnb    0xE2, L_37E5                          ; 37DF
        mov    r7, #0xFA                             ; 37E2
        ret                                          ; 37E4
L_37E5::
        mov    r7, #0xF7                             ; 37E5
        ret                                          ; 37E7
L_37E8::
        jnb    0x00, L_37BF                          ; 37E8
        ret                                          ; 37EB
L_37EC::
        jb     0x00, L_37F1                          ; 37EC
        mov    r7, #0xFD                             ; 37EF
L_37F1::
        ret                                          ; 37F1

lcd_show_msg_thunk::
        lcall  lcd_copy_message                      ; 37F2

lcd_refresh::
        mov    a, meter_state                        ; 37F5
        anl    a, #0x0F                              ; 37F7
        cjne   a, #0x0D, L_37FD                      ; 37F9
        ret                                          ; 37FC
L_37FD::
        jnb    0x10, L_3806                          ; 37FD
        mov    r1, #0x04                             ; 3800
        mov    a, #0xFD                              ; 3802
        sjmp   L_3820                                ; 3804
L_3806::
        push   0x2E                                  ; 3806
        mov    a, meter_state                        ; 3808
        anl    a, #0x70                              ; 380A
        mov    0x2E, a                               ; 380C
        mov    c, 0x2E                               ; 380E
        mov    0x73, c                               ; 3810
        lcall  resolution_digits                     ; 3812
        mov    r1, a                                 ; 3815
        mov    a, 0x2E                               ; 3816
        swap   a                                     ; 3818
        anl    a, #0x0F                              ; 3819
        lcall  range_decimal_pos                     ; 381B
        pop    0x2E                                  ; 381E
L_3820::
        mov    dptr, #0x0001                         ; 3820
        jz     L_382A                                ; 3823
L_3825::
        inc    dptr                                  ; 3825
        dec    r1                                    ; 3826
        inc    a                                     ; 3827
        jnz    L_3825                                ; 3828
L_382A::
        movx   a, @dptr                              ; 382A
        mov    r2, a                                 ; 382B
        mov    a, #0x2E                              ; 382C
        movx   @dptr, a                              ; 382E
L_382F::
        mov    a, r1                                 ; 382F
        inc    dptr                                  ; 3830
        jz     L_3839                                ; 3831
        movx   a, @dptr                              ; 3833
        xch    a, r2                                 ; 3834
        movx   @dptr, a                              ; 3835
        dec    r1                                    ; 3836
        sjmp   L_382F                                ; 3837
L_3839::
        cjne   r2, #0x23, L_383F                     ; 3839
        mov    a, r2                                 ; 383C
        movx   @dptr, a                              ; 383D
        ret                                          ; 383E
L_383F::
        cjne   r2, #0x2D, L_3844                     ; 383F
        mov    r2, #0x20                             ; 3842
L_3844::
        cjne   r2, #0x30, L_3849                     ; 3844
        mov    r2, #0x20                             ; 3847
L_3849::
        movx   a, @dptr                              ; 3849
        xch    a, r2                                 ; 384A
        movx   @dptr, a                              ; 384B
        inc    dptr                                  ; 384C
        sjmp   L_3839                                ; 384D

; digits per function/speed, table 0x6E40 (also used by RSL ?)
resolution_digits::
        lcall  func_to_cmd_index                     ; 384F
        mov    r2, a                                 ; 3852
        mov    sfr_B, #0x03                          ; 3853
        mul    ab                                    ; 3856
        mov    r0, a                                 ; 3857
        mov    a, meter_mode                         ; 3858
        anl    a, #0x03                              ; 385A
        add    a, r0                                 ; 385C
        mov    dptr, #resolution_table               ; 385D
        movc   a, @a+dptr                            ; 3860
        push   sfr_ACC                               ; 3861
        mov    a, 0x2E                               ; 3863
        anl    a, #0x70                              ; 3865
        mov    r1, a                                 ; 3867
        pop    sfr_ACC                               ; 3868
        cjne   r2, #0x07, L_3872                     ; 386A
        cjne   r1, #0x60, L_3872                     ; 386D
        sjmp   L_3878                                ; 3870
L_3872::
        cjne   r2, #0x0E, L_3879                     ; 3872
        cjne   r1, #0x70, L_3879                     ; 3875
L_3878::
        dec    a                                     ; 3878
L_3879::
        ret                                          ; 3879

; decimal point per function/range, table 0x6DC0
range_decimal_pos::
        mov    r0, a                                 ; 387A
        mov    a, meter_state                        ; 387B
        anl    a, #0x0F                              ; 387D
        rl     a                                     ; 387F
        rl     a                                     ; 3880
        rl     a                                     ; 3881
        add    a, r0                                 ; 3882
        mov    dptr, #range_decimal_table            ; 3883
        movc   a, @a+dptr                            ; 3886
        jnb    0x73, L_388B                          ; 3887
        dec    a                                     ; 388A
L_388B::
        cpl    a                                     ; 388B
        inc    a                                     ; 388C
        ret                                          ; 388D

fp_cmp_ten::
        mov    r0, #0x57                             ; 388E
        push   0x57                                  ; 3890
        anl    0x57, #0x7F                           ; 3892
        mov    r1, #0x5F                             ; 3895
        mov    a, #0x01                              ; 3897
        lcall  fp_ld_pow10_r1                        ; 3899
        lcall  fp_cmp                                ; 389C
        pop    0x57                                  ; 389F
        ret                                          ; 38A1

; (inferred) field parameters depending on interface/function
out_format_params_a::
        mov    a, 0x1D                               ; 38A2
        orl    a, 0x1E                               ; 38A4
        jz     L_38BC                                ; 38A6
        mov    a, meter_state                        ; 38A8
        anl    a, #0x0F                              ; 38AA
        jz     L_38B5                                ; 38AC
        mov    0x30, #0x50                           ; 38AE
        mov    0x31, #0x01                           ; 38B1
        ret                                          ; 38B4
L_38B5::
        mov    0x30, #0x18                           ; 38B5
        mov    0x31, #0x00                           ; 38B8
        ret                                          ; 38BB
L_38BC::
        mov    a, meter_state                        ; 38BC
        anl    a, #0x0F                              ; 38BE
        jz     L_38C9                                ; 38C0
        mov    0x30, #0x00                           ; 38C2
        mov    0x31, #0x03                           ; 38C5
        ret                                          ; 38C8
L_38C9::
        mov    0x30, #0x30                           ; 38C9
        mov    0x31, #0x00                           ; 38CC
        ret                                          ; 38CF

out_format_params_b::
        mov    a, 0x1D                               ; 38D0
        orl    a, 0x1E                               ; 38D2
        jz     L_38EA                                ; 38D4
        mov    a, meter_state                        ; 38D6
        anl    a, #0x0F                              ; 38D8
        jz     L_38E3                                ; 38DA
        mov    0x30, #0x70                           ; 38DC
        mov    0x31, #0x00                           ; 38DF
        ret                                          ; 38E2
L_38E3::
        mov    0x30, #0x08                           ; 38E3
        mov    0x31, #0x00                           ; 38E6
        ret                                          ; 38E9
L_38EA::
        mov    a, meter_state                        ; 38EA
        anl    a, #0x0F                              ; 38EC
        jz     L_38F7                                ; 38EE
        mov    0x30, #0xE0                           ; 38F0
        mov    0x31, #0x00                           ; 38F3
        ret                                          ; 38F6
L_38F7::
        mov    0x30, #0x08                           ; 38F7
        mov    0x31, #0x00                           ; 38FA
        ret                                          ; 38FD

; (inferred) result (0x00F2) -> display value with range/resolution
lcd_prepare_value::
        setb   0x70                                  ; 38FE
        mov    a, meter_state                        ; 3900
        anl    a, #0x0F                              ; 3902
        cjne   a, #0x08, L_391A                      ; 3904
        jnb    0x37, L_3914                          ; 3907
        mov    a, #0x0F                              ; 390A
        inc    0x32                                  ; 390C
        cjne   a, 0x32, L_3914                       ; 390E
        mov    0x32, #0x00                           ; 3911
L_3914::
        mov    dptr, #T_3A91                         ; 3914
        ljmp   L_3A11                                ; 3917
L_391A::
        cjne   a, #0x0D, L_3946                      ; 391A
        jnb    0x37, L_393C                          ; 391D
        mov    dptr, #x_meas_result                  ; 3920
        mov    r0, #0x57                             ; 3923
        lcall  fp_ld_xdata_r0                        ; 3925
        anl    0x57, #0x7F                           ; 3928
        mov    a, @r0                                ; 392B
        add    a, #0xC2                              ; 392C
        jnb    0xE7, L_3934                          ; 392E
        clr    a                                     ; 3931
        sjmp   L_393A                                ; 3932
L_3934::
        mov    @r0, a                                ; 3934
        anl    a, #0x07                              ; 3935
        cjne   a, 0x57, L_3942                       ; 3937
L_393A::
        mov    0x32, a                               ; 393A
L_393C::
        mov    dptr, #T_3ACD                         ; 393C
        ljmp   L_3A11                                ; 393F
L_3942::
        mov    a, #0x08                              ; 3942
        sjmp   L_393A                                ; 3944
L_3946::
        jnb    0x11, L_395E                          ; 3946
        jnb    0x37, L_3958                          ; 3949
        lcall  lcd_scale_value                       ; 394C
        jnb    0x56, L_3954                          ; 394F
        cpl    a                                     ; 3952
        inc    a                                     ; 3953
L_3954::
        add    a, #0x07                              ; 3954
        mov    0x32, a                               ; 3956
L_3958::
        mov    dptr, #T_3AAF                         ; 3958
        ljmp   L_3A11                                ; 395B
L_395E::
        cjne   a, #0x0A, L_3963                      ; 395E
        sjmp   L_3966                                ; 3961
L_3963::
        cjne   a, #0x0B, L_3969                      ; 3963
L_3966::
        clr    0x70                                  ; 3966
        ret                                          ; 3968
L_3969::
        jb     0x37, L_397B                          ; 3969
        jnb    0x71, L_3972                          ; 396C
        ljmp   L_3A0E                                ; 396F
L_3972::
        mov    0x32, #0x00                           ; 3972
        mov    dptr, #T_3ADD                         ; 3975
        ljmp   L_3A11                                ; 3978
L_397B::
        jb     0x71, L_3983                          ; 397B
        mov    0x32, #0x0E                           ; 397E
        sjmp   L_39FE                                ; 3981
L_3983::
        mov    r0, #0x5B                             ; 3983
        mov    dptr, #0x01A6                         ; 3985
        lcall  fp_ld_xdata_r0                        ; 3988
        mov    r1, #0x5F                             ; 398B
        lcall  fp_copy_r0_to_r1                      ; 398D
        mov    a, @r0                                ; 3990
        clr    0xE7                                  ; 3991
        add    a, #0xF9                              ; 3993
        jnc    L_3998                                ; 3995
        clr    a                                     ; 3997
L_3998::
        mov    @r0, a                                ; 3998
        mov    a, 0x2E                               ; 3999
        anl    a, #0x70                              ; 399B
        swap   a                                     ; 399D
        mov    r6, a                                 ; 399E
        lcall  lcd_decimal_point                     ; 399F
        mov    a, r6                                 ; 39A2
        mov    c, 0x2E                               ; 39A3
        mov    0x73, c                               ; 39A5
        lcall  range_decimal_pos                     ; 39A7
        mov    r6, a                                 ; 39AA
        lcall  resolution_digits                     ; 39AB
        jb     speed_b0, L_39B5                      ; 39AE
        jb     speed_b1, L_39B5                      ; 39B1
        dec    a                                     ; 39B4
L_39B5::
        add    a, r6                                 ; 39B5
        xch    a, r7                                 ; 39B6
        clr    c                                     ; 39B7
        subb   a, r7                                 ; 39B8
        inc    a                                     ; 39B9
        mov    r0, #0x5B                             ; 39BA
        mov    r1, #0x57                             ; 39BC
        lcall  fp_ld_pow10_r1                        ; 39BE
        lcall  fp_cmp                                ; 39C1
        jnc    L_39C9                                ; 39C4
        lcall  fp_copy_r1_to_r0                      ; 39C6
L_39C9::
        mov    r0, #0x5F                             ; 39C9
        mov    r1, #0x57                             ; 39CB
        mov    dptr, #x_meas_result                  ; 39CD
        lcall  fp_ld_xdata_r1                        ; 39D0
        lcall  fp_sub                                ; 39D3
        mov    a, @r0                                ; 39D6
        mov    c, 0xE7                               ; 39D7
        mov    0x56, c                               ; 39D9
        clr    0xE7                                  ; 39DB
        mov    @r0, a                                ; 39DD
        mov    r1, #0x5B                             ; 39DE
        lcall  fp_cmp                                ; 39E0
        jc     L_3A0E                                ; 39E3
        jnb    0x56, L_39F4                          ; 39E5
        mov    a, #0x0F                              ; 39E8
        inc    0x32                                  ; 39EA
        cjne   a, 0x32, L_39FE                       ; 39EC
        mov    0x32, #0x00                           ; 39EF
        sjmp   L_39FE                                ; 39F2
L_39F4::
        dec    0x32                                  ; 39F4
        mov    a, #0xFF                              ; 39F6
        cjne   a, 0x32, L_39FE                       ; 39F8
        mov    0x32, #0x0E                           ; 39FB
L_39FE::
        mov    r0, #0x57                             ; 39FE
        mov    dptr, #x_meas_result                  ; 3A00
        lcall  fp_ld_xdata_r0                        ; 3A03
        mov    dptr, #0x01A6                         ; 3A06
        lcall  fp_st_r0_xdata                        ; 3A09
        setb   0x71                                  ; 3A0C
L_3A0E::
        mov    dptr, #T_3A91                         ; 3A0E
L_3A11::
        mov    a, 0x32                               ; 3A11
        rl     a                                     ; 3A13
        mov    r0, a                                 ; 3A14
        movc   a, @a+dptr                            ; 3A15
        mov    0x34, a                               ; 3A16
        mov    a, r0                                 ; 3A18
        inc    a                                     ; 3A19
        movc   a, @a+dptr                            ; 3A1A
        mov    0x33, a                               ; 3A1B
        clr    0x37                                  ; 3A1D
        ret                                          ; 3A1F

; (inferred)
lcd_scale_value::
        mov    r0, #0x57                             ; 3A20
        mov    dptr, #x_meas_result                  ; 3A22
        lcall  fp_ld_xdata_r0                        ; 3A25
        jnb    0x10, L_3A37                          ; 3A28
        mov    a, #0x01                              ; 3A2B
        mov    r1, #0x3D                             ; 3A2D
        lcall  fp_ld_pow10_r1                        ; 3A2F
        lcall  fp_mul                                ; 3A32
        sjmp   L_3A5C                                ; 3A35
L_3A37::
        lcall  digits_for_range                      ; 3A37
        mov    a, meter_state                        ; 3A3A
        anl    a, #0x0F                              ; 3A3C
        mov    dptr, #T_6F14                         ; 3A3E
        movc   a, @a+dptr                            ; 3A41
        jnb    0xE5, L_3A47                          ; 3A42
        dec    0x3D                                  ; 3A45
L_3A47::
        lcall  resolution_digits                     ; 3A47
        dec    a                                     ; 3A4A
        mov    r0, #0x3D                             ; 3A4B
        mov    r1, #0x5B                             ; 3A4D
        lcall  fp_ld_pow10_r1                        ; 3A4F
        lcall  fp_div                                ; 3A52
        mov    r1, #0x3D                             ; 3A55
        mov    r0, #0x57                             ; 3A57
        lcall  fp_div                                ; 3A59
L_3A5C::
        mov    a, @r0                                ; 3A5C
        mov    c, 0xE7                               ; 3A5D
        mov    0x56, c                               ; 3A5F
        clr    0xE7                                  ; 3A61
        add    a, #0xC1                              ; 3A63
        jb     0x10, L_3A6A                          ; 3A65
        add    a, #0xFC                              ; 3A68
L_3A6A::
        jnb    0xE7, L_3A6F                          ; 3A6A
        clr    a                                     ; 3A6D
        ret                                          ; 3A6E
L_3A6F::
        cjne   a, #0x07, L_3A74                      ; 3A6F
        sjmp   L_3A78                                ; 3A72
L_3A74::
        jc     L_3A78                                ; 3A74
        mov    a, #0x07                              ; 3A76
L_3A78::
        ret                                          ; 3A78

; (inferred) per-function setup (continuity special case)
func_change_hook::
        mov    dptr, #0x00A4                         ; 3A79
        mov    r0, #0x09                             ; 3A7C
        mov    a, meter_state                        ; 3A7E
        anl    a, #0x0F                              ; 3A80
        cjne   a, #0x0D, L_3A87                      ; 3A82
        mov    r0, #0x08                             ; 3A85
L_3A87::
        mov    a, r0                                 ; 3A87
        movx   @dptr, a                              ; 3A88
        mov    dptr, #0x00A0                         ; 3A89
        movx   a, @dptr                              ; 3A8C
        anl    a, #0xFC                              ; 3A8D
        movx   @dptr, a                              ; 3A8F
        ret                                          ; 3A90
T_3A91::
        .db 0xFF, 0xCF, 0xFD, 0xDF, 0xFC, 0xFF, 0xFA, 0xFF, 0xF3, 0xFF, 0x77, 0xFF, 0x3F, 0xFF, 0xAF, 0xFF ; 3A91 ..........w.?...
        .db 0xEF, 0xFD, 0xFF, 0xFC, 0xFF, 0xFA, 0xFF, 0xF3, 0xFF, 0x77, 0xFF, 0x3F, 0xFF, 0xAF ; 3AA1 .........w.?..
T_3AAF::
        .db 0x20, 0xFF, 0x20, 0xFD, 0x20, 0xFC, 0x20, 0xF8, 0x20, 0xF0, 0x20, 0x70, 0x20, 0x30, 0x20, 0x20 ; 3AAF  . . . . . p 0  
        .db 0x22, 0x20, 0x23, 0x20, 0x27, 0x20, 0x2F, 0x20, 0xAF, 0x20, 0xEF, 0x20, 0xFF, 0x20 ; 3ABF " # ' / . . . 
T_3ACD::
        .db 0xFF, 0xFF, 0xFF, 0xDF, 0xFD, 0xCF, 0xFC, 0x8F, 0xF8, 0x0F, 0xF0, 0x07, 0x70, 0x03, 0x30, 0x02 ; 3ACD ............p.0.
T_3ADD::
        .db 0x20, 0x00, 0x22, 0x22, 0x22                                                     ; 3ADD  ."""

; min (XDATA 0x007D) = +max float
min_reset::
        mov    0x34, #0x00                           ; 3AE2
L_3AE5::
        mov    a, 0x34                               ; 3AE5
        setb   c                                     ; 3AE7
        subb   a, #0x03                              ; 3AE8
        jnc    L_3B05                                ; 3AEA
        mov    a, 0x34                               ; 3AEC
        mov    dptr, #const_fp_table                 ; 3AEE
        movc   a, @a+dptr                            ; 3AF1
        mov    r2, a                                 ; 3AF2
        mov    a, 0x34                               ; 3AF3
        mov    dptr, #x_minmax_min                   ; 3AF5
        lcall  dptr_add_a                            ; 3AF8
        mov    a, r2                                 ; 3AFB
        movx   @dptr, a                              ; 3AFC
        mov    a, 0x34                               ; 3AFD
        add    a, #0x01                              ; 3AFF
        mov    0x34, a                               ; 3B01
        jnc    L_3AE5                                ; 3B03
L_3B05::
        mov    dptr, #0x0069                         ; 3B05
        clr    a                                     ; 3B08
        movx   @dptr, a                              ; 3B09
        mov    dptr, #0x006A                         ; 3B0A
        mov    a, #0x04                              ; 3B0D
        movx   @dptr, a                              ; 3B0F
        ret                                          ; 3B10

; max (XDATA 0x0081) = -max float
max_reset::
        mov    0x34, #0x00                           ; 3B11
L_3B14::
        mov    a, 0x34                               ; 3B14
        setb   c                                     ; 3B16
        subb   a, #0x03                              ; 3B17
        jnc    L_3B34                                ; 3B19
        mov    a, 0x34                               ; 3B1B
        mov    dptr, #T_6FC4                         ; 3B1D
        movc   a, @a+dptr                            ; 3B20
        mov    r2, a                                 ; 3B21
        mov    a, 0x34                               ; 3B22
        mov    dptr, #x_minmax_max                   ; 3B24
        lcall  dptr_add_a                            ; 3B27
        mov    a, r2                                 ; 3B2A
        movx   @dptr, a                              ; 3B2B
        mov    a, 0x34                               ; 3B2C
        add    a, #0x01                              ; 3B2E
        mov    0x34, a                               ; 3B30
        jnc    L_3B14                                ; 3B32
L_3B34::
        mov    dptr, #0x006B                         ; 3B34
        clr    a                                     ; 3B37
        movx   @dptr, a                              ; 3B38
        mov    dptr, #0x006C                         ; 3B39
        mov    a, #0x04                              ; 3B3C
        movx   @dptr, a                              ; 3B3E
        ret                                          ; 3B3F

; flags for the current range and cold/hot
cal_step_allowed::
        lcall  cal_point_flags                       ; 3B40
        anl    a, #0x7F                              ; 3B43
        mov    0x39, a                               ; 3B45
        jnb    cal_hot, L_3B50                       ; 3B47
        mov    a, #0x30                              ; 3B4A
        anl    a, 0x39                               ; 3B4C
        mov    0x39, a                               ; 3B4E
L_3B50::
        mov    a, 0x39                               ; 3B50
        jnz    L_3B56                                ; 3B52
        setb   c                                     ; 3B54
        ret                                          ; 3B55
L_3B56::
        clr    c                                     ; 3B56
        ret                                          ; 3B57

; " -------"
lcd_show_dashes::
        jnb    0x31, L_3B5E                          ; 3B58
        ljmp   L_3B67                                ; 3B5B
L_3B5E::
        mov    dptr, #msg_table                      ; 3B5E
        lcall  lcd_show_message                      ; 3B61
        lcall  lcd_refresh                           ; 3B64
L_3B67::
        ret                                          ; 3B67

cal_msg_000000C::
        mov    dptr, #T_71A0                         ; 3B68
        lcall  lcd_show_message                      ; 3B6B
        lcall  lcd_refresh                           ; 3B6E
        ret                                          ; 3B71

cal_msg_100000C::
        mov    dptr, #T_71A9                         ; 3B72
        lcall  lcd_show_message                      ; 3B75
        lcall  lcd_refresh                           ; 3B78
        ret                                          ; 3B7B

cal_msg_200000C::
        mov    dptr, #T_71B2                         ; 3B7C
        lcall  lcd_show_message                      ; 3B7F
        lcall  lcd_refresh                           ; 3B82
        ret                                          ; 3B85
L_3B86::
        mov    dptr, #T_71BB                         ; 3B86
        lcall  lcd_show_message                      ; 3B89
        lcall  lcd_refresh                           ; 3B8C
        ret                                          ; 3B8F

cal_msg_60000C::
        mov    dptr, #T_71C4                         ; 3B90
        lcall  lcd_show_message                      ; 3B93
        lcall  lcd_refresh                           ; 3B96
        ret                                          ; 3B99

; calibration mode: show the step codes 000000C/100000C/200000C/60000C
cal_show_status::
        jnb    0x31, L_3BA0                          ; 3B9A
        ljmp   L_3CB6                                ; 3B9D
L_3BA0::
        mov    a, #0x0F                              ; 3BA0
        anl    a, meter_state                        ; 3BA2
        clr    c                                     ; 3BA4
        subb   a, #0x04                              ; 3BA5
        jnc    L_3BC7                                ; 3BA7
        mov    a, #0x7F                              ; 3BA9
        anl    a, meter_state                        ; 3BAB
        cjne   a, #0x42, L_3BB5                      ; 3BAD
        lcall  cal_msg_60000C                        ; 3BB0
        sjmp   L_3BC4                                ; 3BB3
L_3BB5::
        mov    a, #0x70                              ; 3BB5
        anl    a, meter_state                        ; 3BB7
        cjne   a, #0x40, L_3BC1                      ; 3BB9
        lcall  cal_msg_100000C                       ; 3BBC
        sjmp   L_3BC4                                ; 3BBF
L_3BC1::
        lcall  cal_msg_200000C                       ; 3BC1
L_3BC4::
        ljmp   L_3C57                                ; 3BC4
L_3BC7::
        mov    a, #0x0F                              ; 3BC7
        anl    a, meter_state                        ; 3BC9
        clr    c                                     ; 3BCB
        subb   a, #0x04                              ; 3BCC
        clr    c                                     ; 3BCE
        mov    sfr_B, a                              ; 3BCF
        rlc    a                                     ; 3BD1
        add    a, sfr_B                              ; 3BD2
        mov    dptr, #L_3C33                         ; 3BD4
        jmp    @a+dptr                               ; 3BD7
L_3BD8::
        mov    a, #0x70                              ; 3BD8
        anl    a, meter_state                        ; 3BDA
        cjne   a, #0x10, L_3BE1                      ; 3BDC
        sjmp   L_3BE8                                ; 3BDF
L_3BE1::
        mov    a, #0x70                              ; 3BE1
        anl    a, meter_state                        ; 3BE3
        cjne   a, #0x20, L_3BED                      ; 3BE5
L_3BE8::
        lcall  cal_msg_100000C                       ; 3BE8
        sjmp   L_3BF0                                ; 3BEB
L_3BED::
        lcall  cal_msg_200000C                       ; 3BED
L_3BF0::
        sjmp   L_3C57                                ; 3BF0
L_3BF2::
        mov    a, #0x70                              ; 3BF2
        anl    a, meter_state                        ; 3BF4
        mov    r2, a                                 ; 3BF6
        mov    a, #0x20                              ; 3BF7
        clr    c                                     ; 3BF9
        subb   a, r2                                 ; 3BFA
        jnc    L_3C02                                ; 3BFB
        lcall  cal_msg_100000C                       ; 3BFD
        sjmp   L_3C05                                ; 3C00
L_3C02::
        lcall  cal_msg_200000C                       ; 3C02
L_3C05::
        sjmp   L_3C57                                ; 3C05
L_3C07::
        lcall  cal_msg_100000C                       ; 3C07
        sjmp   L_3C57                                ; 3C0A
L_3C0C::
        lcall  cal_msg_100000C                       ; 3C0C
        sjmp   L_3C57                                ; 3C0F
L_3C11::
        lcall  lcd_show_dashes                       ; 3C11
        sjmp   L_3C57                                ; 3C14
L_3C16::
        lcall  cal_msg_200000C                       ; 3C16
        sjmp   L_3C57                                ; 3C19
L_3C1B::
        lcall  cal_msg_100000C                       ; 3C1B
        sjmp   L_3C57                                ; 3C1E
L_3C20::
        lcall  cal_msg_000000C                       ; 3C20
        sjmp   L_3C57                                ; 3C23
L_3C25::
        lcall  cal_msg_200000C                       ; 3C25
        sjmp   L_3C57                                ; 3C28
L_3C2A::
        lcall  lcd_show_dashes                       ; 3C2A
        sjmp   L_3C57                                ; 3C2D
L_3C2F::
        sjmp   L_3C57                                ; 3C2F
L_3C31::
        sjmp   L_3C57                                ; 3C31
L_3C33::
        ljmp   L_3BD8                                ; 3C33
L_3C36::
        ljmp   L_3BF2                                ; 3C36
L_3C39::
        ljmp   L_3C07                                ; 3C39
L_3C3C::
        ljmp   L_3C0C                                ; 3C3C
L_3C3F::
        ljmp   L_3C11                                ; 3C3F
L_3C42::
        ljmp   L_3C16                                ; 3C42
L_3C45::
        ljmp   L_3C1B                                ; 3C45
L_3C48::
        ljmp   L_3C20                                ; 3C48
L_3C4B::
        ljmp   L_3C25                                ; 3C4B
L_3C4E::
        ljmp   L_3C2A                                ; 3C4E
L_3C51::
        ljmp   L_3C2F                                ; 3C51
L_3C54::
        ljmp   L_3C31                                ; 3C54
L_3C57::
        lcall  cal_step_allowed                      ; 3C57
        jnc    L_3CB6                                ; 3C5A
        mov    0x39, #0x00                           ; 3C5C
L_3C5F::
        mov    a, 0x39                               ; 3C5F
        setb   c                                     ; 3C61
        subb   a, #0x11                              ; 3C62
        jnc    L_3CB6                                ; 3C64
        mov    a, 0x39                               ; 3C66
        mov    dptr, #x_lcd_text_buf                 ; 3C68
        lcall  dptr_add_a                            ; 3C6B
        movx   a, @dptr                              ; 3C6E
        cjne   a, #0x23, L_3CAE                      ; 3C6F
        mov    a, 0x39                               ; 3C72
        clr    c                                     ; 3C74
        subb   a, #0x02                              ; 3C75
        mov    dptr, #x_lcd_text_buf                 ; 3C77
        lcall  dptr_add_a                            ; 3C7A
        movx   a, @dptr                              ; 3C7D
        cjne   a, #0x2E, L_3C91                      ; 3C7E
        mov    a, 0x39                               ; 3C81
        clr    c                                     ; 3C83
        subb   a, #0x03                              ; 3C84
        mov    dptr, #x_lcd_text_buf                 ; 3C86
        lcall  dptr_add_a                            ; 3C89
        mov    a, #0x4E                              ; 3C8C
        movx   @dptr, a                              ; 3C8E
        sjmp   L_3C9F                                ; 3C8F
L_3C91::
        mov    a, 0x39                               ; 3C91
        clr    c                                     ; 3C93
        subb   a, #0x02                              ; 3C94
        mov    dptr, #x_lcd_text_buf                 ; 3C96
        lcall  dptr_add_a                            ; 3C99
        mov    a, #0x4E                              ; 3C9C
        movx   @dptr, a                              ; 3C9E
L_3C9F::
        mov    a, 0x39                               ; 3C9F
        dec    a                                     ; 3CA1
        mov    dptr, #x_lcd_text_buf                 ; 3CA2
        lcall  dptr_add_a                            ; 3CA5
        mov    a, #0x41                              ; 3CA8
        movx   @dptr, a                              ; 3CAA
        mov    0x39, #0x12                           ; 3CAB
L_3CAE::
        mov    a, 0x39                               ; 3CAE
        add    a, #0x01                              ; 3CB0
        mov    0x39, a                               ; 3CB2
        jnc    L_3C5F                                ; 3CB4
L_3CB6::
        ret                                          ; 3CB6

cal_status_or_dashes::
        jnb    cal_mode, L_3CBF                      ; 3CB7
        lcall  cal_show_status                       ; 3CBA
        sjmp   L_3CC2                                ; 3CBD
L_3CBF::
        lcall  lcd_show_dashes                       ; 3CBF
L_3CC2::
        ret                                          ; 3CC2

trigger_restart_measure::
        lcall  meas_restart_b                        ; 3CC3
        mov    dptr, #x_result_flags                 ; 3CC6
        movx   a, @dptr                              ; 3CC9
        orl    a, #0x08                              ; 3CCA
        movx   @dptr, a                              ; 3CCC
        lcall  iface_report_status                   ; 3CCD
        lcall  lcd_show_dashes                       ; 3CD0
        ret                                          ; 3CD3

; status1 bit3 = "no reading yet" ('?')
result_record_clear::
        mov    dptr, #0x0067                         ; 3CD4
        clr    a                                     ; 3CD7
        movx   @dptr, a                              ; 3CD8
        mov    dptr, #x_result_status0               ; 3CD9
        movx   @dptr, a                              ; 3CDC
        mov    a, #0x70                              ; 3CDD
        anl    a, meter_state                        ; 3CDF
        orl    a, #0x08                              ; 3CE1
        mov    dptr, #0x0068                         ; 3CE3
        movx   @dptr, a                              ; 3CE6
        mov    dptr, #x_result_status1               ; 3CE7
        movx   @dptr, a                              ; 3CEA
        clr    0x33                                  ; 3CEB
        ret                                          ; 3CED

result_restart::
        lcall  result_record_clear                   ; 3CEE
        mov    c, 0x0A                               ; 3CF1
        jnb    0x0B, L_3CF7                          ; 3CF3
        cpl    c                                     ; 3CF6
L_3CF7::
        jnc    L_3D20                                ; 3CF7
        jb     0x20, L_3D0A                          ; 3CF9
        mov    dptr, #x_result_flags                 ; 3CFC
        movx   a, @dptr                              ; 3CFF
        anl    a, #0x08                              ; 3D00
        jnz    L_3D0A                                ; 3D02
        mov    a, #0x80                              ; 3D04
        anl    a, 0x0B                               ; 3D06
        jz     L_3D1E                                ; 3D08
L_3D0A::
        mov    dptr, #x_result_flags                 ; 3D0A
        movx   a, @dptr                              ; 3D0D
        anl    a, #0xF7                              ; 3D0E
        movx   @dptr, a                              ; 3D10
        jnb    0x0A, L_3D1B                          ; 3D11
        jb     0x0B, L_3D1B                          ; 3D14
        setb   0x20                                  ; 3D17
        sjmp   L_3D1E                                ; 3D19
L_3D1B::
        lcall  iface_report_status                   ; 3D1B
L_3D1E::
        sjmp   L_3D2A                                ; 3D1E
L_3D20::
        mov    dptr, #x_result_flags                 ; 3D20
        movx   a, @dptr                              ; 3D23
        orl    a, #0x08                              ; 3D24
        movx   @dptr, a                              ; 3D26
        lcall  iface_report_status                   ; 3D27
L_3D2A::
        ret                                          ; 3D2A

jcv_set_ptr::
        mov    dptr, #x_jcv_ptr                      ; 3D2B
        mov    a, 0x30                               ; 3D2E
        movx   @dptr, a                              ; 3D30
        inc    dptr                                  ; 3D31
        mov    a, 0x31                               ; 3D32
        movx   @dptr, a                              ; 3D34
        ret                                          ; 3D35

; one-shot: read and clear XDATA 0x009A/0x009B
jcv_get_ptr::
        mov    dptr, #x_jcv_ptr                      ; 3D36
        movx   a, @dptr                              ; 3D39
        mov    r7, a                                 ; 3D3A
        clr    a                                     ; 3D3B
        movx   @dptr, a                              ; 3D3C
        inc    dptr                                  ; 3D3D
        movx   a, @dptr                              ; 3D3E
        mov    r6, a                                 ; 3D3F
        clr    a                                     ; 3D40
        movx   @dptr, a                              ; 3D41
        ret                                          ; 3D42

kbd_ctx_swap::
        mov    sfr_DPH, 0x37                         ; 3D43
        mov    sfr_DPL, 0x38                         ; 3D46
        mov    r0, #0x2E                             ; 3D49
        mov    r2, #0x06                             ; 3D4B
        lcall  xdata_swap_iram                       ; 3D4D
        ret                                          ; 3D50

; common exit of all key/command handlers
kbd_cmd_finish::
        clr    0x7F                                  ; 3D51
        jnb    0x6B, L_3D64                          ; 3D53
        mov    c, 0x6A                               ; 3D56
        orl    c, 0x1E                               ; 3D58
        mov    0x1E, c                               ; 3D5A
        mov    0x37, #0x00                           ; 3D5C
        mov    0x38, #0xDF                           ; 3D5F
        sjmp   L_3D6A                                ; 3D62
L_3D64::
        mov    0x37, #0x00                           ; 3D64
        mov    0x38, #0xA9                           ; 3D67
L_3D6A::
        lcall  kbd_ctx_swap                          ; 3D6A
        ret                                          ; 3D6D

; first character of a mnemonic parameter
cmd_param_first_char::
        dec    0x31                                  ; 3D6E
        inc    0x30                                  ; 3D70
        mov    a, 0x30                               ; 3D72
        dec    a                                     ; 3D74
        mov    dptr, #x_iface_rx_buf                 ; 3D75
        lcall  dptr_add_a                            ; 3D78
        movx   a, @dptr                              ; 3D7B
        anl    a, #0x5F                              ; 3D7C
        ret                                          ; 3D7E

; MSP n
set_speed::
        mov    a, 0x30                               ; 3D7F
        dec    a                                     ; 3D81
        mov    sfr_B, #0x03                          ; 3D82
        mov    r2, a                                 ; 3D85
        mov    a, #0x0F                              ; 3D86
        anl    a, meter_state                        ; 3D88
        mul    ab                                    ; 3D8A
        mov    r4, sfr_B                             ; 3D8B
        mov    r5, a                                 ; 3D8D
        mov    a, r5                                 ; 3D8E
        add    a, #0xD4                              ; 3D8F
        mov    sfr_DPL, a                            ; 3D91
        mov    a, r4                                 ; 3D93
        addc   a, #0x6E                              ; 3D94
        mov    sfr_DPH, a                            ; 3D96
        mov    a, r2                                 ; 3D98
        movc   a, @a+dptr                            ; 3D99
        mov    0x34, a                               ; 3D9A
        mov    a, meter_state                        ; 3D9C
        swap   a                                     ; 3D9E
        anl    a, #0x0F                              ; 3D9F
        anl    a, #0x07                              ; 3DA1
        mov    r2, a                                 ; 3DA3
        mov    a, #0x01                              ; 3DA4
        inc    r2                                    ; 3DA6
        rrc    a                                     ; 3DA7
L_3DA8::
        rlc    a                                     ; 3DA8
        clr    c                                     ; 3DA9
        djnz   r2, L_3DA8                            ; 3DAA
        anl    a, 0x34                               ; 3DAC
        mov    0x3C, a                               ; 3DAE
        jnb    meter_autorange, L_3DC4               ; 3DB0
        mov    a, 0x34                               ; 3DB3
        jnz    L_3DBB                                ; 3DB5
        setb   0x6A                                  ; 3DB7
        sjmp   L_3DC2                                ; 3DB9
L_3DBB::
        mov    a, 0x3C                               ; 3DBB
        jnz    L_3DC2                                ; 3DBD
        lcall  meas_set_function_flags               ; 3DBF
L_3DC2::
        sjmp   L_3DCA                                ; 3DC2
L_3DC4::
        mov    a, 0x3C                               ; 3DC4
        jnz    L_3DCA                                ; 3DC6
        setb   0x6A                                  ; 3DC8
L_3DCA::
        jb     0x6A, L_3DE7                          ; 3DCA
        mov    a, #0xFC                              ; 3DCD
        anl    a, meter_mode                         ; 3DCF
        mov    r2, a                                 ; 3DD1
        mov    a, 0x30                               ; 3DD2
        dec    a                                     ; 3DD4
        orl    a, r2                                 ; 3DD5
        mov    meter_mode, a                         ; 3DD6
        mov    a, #0x0F                              ; 3DD8
        anl    a, meter_state                        ; 3DDA
        cjne   a, #0x01, L_3DE7                      ; 3DDC
        mov    a, #0x03                              ; 3DDF
        anl    a, meter_mode                         ; 3DE1
        mov    dptr, #x_speed_saved                  ; 3DE3
        movx   @dptr, a                              ; 3DE6
L_3DE7::
        ret                                          ; 3DE7

; SPEED -> XDATA 0x01CC (kept over power-off)
speed_store::
        clr    speed_b1                              ; 3DE8
        mov    r2, 0x2E                              ; 3DEA
        cjne   r2, #0x10, L_3DF3                     ; 3DEC
        clr    speed_b0                              ; 3DEF
        sjmp   L_3E13                                ; 3DF1
L_3DF3::
        mov    r2, 0x2E                              ; 3DF3
        cjne   r2, #0x12, L_3DFE                     ; 3DF5
        clr    speed_b0                              ; 3DF8
        setb   speed_b1                              ; 3DFA
        sjmp   L_3E13                                ; 3DFC
L_3DFE::
        mov    r2, 0x2E                              ; 3DFE
        cjne   r2, #0x03, L_3E11                     ; 3E00
        mov    a, #0xFC                              ; 3E03
        anl    a, meter_mode                         ; 3E05
        mov    dptr, #x_speed_saved                  ; 3E07
        mov    r2, a                                 ; 3E0A
        movx   a, @dptr                              ; 3E0B
        orl    a, r2                                 ; 3E0C
        mov    meter_mode, a                         ; 3E0D
        sjmp   L_3E13                                ; 3E0F
L_3E11::
        setb   speed_b0                              ; 3E11
L_3E13::
        ret                                          ; 3E13

speed_load::
        mov    0x34, #0x00                           ; 3E14
L_3E17::
        mov    a, 0x34                               ; 3E17
        clr    c                                     ; 3E19
        subb   a, #0x03                              ; 3E1A
        jnc    L_3E5A                                ; 3E1C
        mov    a, 0x34                               ; 3E1E
        mov    sfr_B, #0x03                          ; 3E20
        mov    r2, a                                 ; 3E23
        mov    a, #0x0F                              ; 3E24
        anl    a, meter_state                        ; 3E26
        mul    ab                                    ; 3E28
        mov    r4, sfr_B                             ; 3E29
        mov    r5, a                                 ; 3E2B
        mov    a, r5                                 ; 3E2C
        add    a, #0xD4                              ; 3E2D
        mov    sfr_DPL, a                            ; 3E2F
        mov    a, r4                                 ; 3E31
        addc   a, #0x6E                              ; 3E32
        mov    sfr_DPH, a                            ; 3E34
        mov    a, r2                                 ; 3E36
        movc   a, @a+dptr                            ; 3E37
        jz     L_3E56                                ; 3E38
        mov    a, #0xFC                              ; 3E3A
        anl    a, meter_mode                         ; 3E3C
        orl    a, 0x34                               ; 3E3E
        mov    meter_mode, a                         ; 3E40
        mov    a, #0x0F                              ; 3E42
        anl    a, meter_state                        ; 3E44
        cjne   a, #0x01, L_3E51                      ; 3E46
        mov    a, #0x03                              ; 3E49
        anl    a, meter_mode                         ; 3E4B
        mov    dptr, #x_speed_saved                  ; 3E4D
        movx   @dptr, a                              ; 3E50
L_3E51::
        mov    0x34, #0xFF                           ; 3E51
        sjmp   L_3E58                                ; 3E54
L_3E56::
        inc    0x34                                  ; 3E56
L_3E58::
        sjmp   L_3E17                                ; 3E58
L_3E5A::
        ret                                          ; 3E5A

; sets cal_mode, autorange off
cal_mode_enter::
        lcall  speed_load                            ; 3E5B
        setb   cal_mode                              ; 3E5E
        clr    meter_autorange                       ; 3E60
        jnb    0x0A, L_3E68                          ; 3E62
        ljmp   L_3E80                                ; 3E65
L_3E68::
        jnb    0x0B, L_3E6E                          ; 3E68
        ljmp   L_3E80                                ; 3E6B
L_3E6E::
        clr    0x0A                                  ; 3E6E
        setb   0x0B                                  ; 3E70
        mov    r0, #0x57                             ; 3E72
        mov    0x57, #0x00                           ; 3E74
        mov    0x56, #0x80                           ; 3E77
        mov    dptr, #0x0384                         ; 3E7A
        lcall  cal_write_all_copies_safe             ; 3E7D
L_3E80::
        ret                                          ; 3E80

cdp_int_to_fp::
        clr    a                                     ; 3E81
        mov    r0, #0x31                             ; 3E82
        mov    @r0, a                                ; 3E84
        inc    r0                                    ; 3E85
        mov    @r0, a                                ; 3E86
        lcall  i24_to_fp                             ; 3E87
        ret                                          ; 3E8A

; CDP n,value: cal slot n -> XDATA 0x0200+4(n-1), all three copies
cdp_write_slot::
        mov    dptr, #x_cdp_slot                     ; 3E8B
        movx   a, @dptr                              ; 3E8E
        dec    a                                     ; 3E8F
        mov    sfr_B, #0x00                          ; 3E90
        mov    r0, #0x02                             ; 3E93
L_3E95::
        clr    c                                     ; 3E95
        rlc    a                                     ; 3E96
        xch    a, sfr_B                              ; 3E97
        rlc    a                                     ; 3E99
        xch    a, sfr_B                              ; 3E9A
        djnz   r0, L_3E95                            ; 3E9C
        mov    dptr, #x_cal_data_copy1               ; 3E9E
        add    a, sfr_DPL                            ; 3EA1
        mov    sfr_DPL, a                            ; 3EA3
        mov    a, sfr_B                              ; 3EA5
        addc   a, sfr_DPH                            ; 3EA7
        mov    sfr_DPH, a                            ; 3EA9
        mov    r0, #0x33                             ; 3EAB
        lcall  cal_write_all_copies_safe             ; 3EAD
        ret                                          ; 3EB0

; RNG <value>: smallest range covering the value
range_find_for_value::
        mov    a, #0x0F                              ; 3EB1
        anl    a, meter_state                        ; 3EB3
        cjne   a, #0x06, L_3EBA                      ; 3EB5
        sjmp   L_3EC1                                ; 3EB8
L_3EBA::
        mov    a, #0x0F                              ; 3EBA
        anl    a, meter_state                        ; 3EBC
        cjne   a, #0x07, L_3EC9                      ; 3EBE
L_3EC1::
        jnb    0x2E, L_3EC9                          ; 3EC1
        mov    0x5A, #0x0E                           ; 3EC4
        sjmp   L_3ECF                                ; 3EC7
L_3EC9::
        mov    a, #0x0F                              ; 3EC9
        anl    a, meter_state                        ; 3ECB
        mov    0x5A, a                               ; 3ECD
L_3ECF::
        mov    a, 0x5A                               ; 3ECF
        mov    dptr, #T_6F04                         ; 3ED1
        movc   a, @a+dptr                            ; 3ED4
        mov    0x5B, a                               ; 3ED5
        mov    a, 0x5A                               ; 3ED7
        mov    dptr, #T_6F14                         ; 3ED9
        movc   a, @a+dptr                            ; 3EDC
        mov    0x58, a                               ; 3EDD
        mov    a, #0x1F                              ; 3EDF
        anl    a, 0x58                               ; 3EE1
        add    a, #0xF7                              ; 3EE3
        mov    0x59, a                               ; 3EE5
        mov    r3, #0x00                             ; 3EE7
        mov    a, 0x5B                               ; 3EE9
L_3EEB::
        jb     0xE0, L_3EF2                          ; 3EEB
        inc    r3                                    ; 3EEE
        rr     a                                     ; 3EEF
        sjmp   L_3EEB                                ; 3EF0
L_3EF2::
        mov    sfr_B, a                              ; 3EF2
        mov    a, 0x59                               ; 3EF4
        mov    r1, #0x41                             ; 3EF6
        lcall  fp_ld_pow10_r1                        ; 3EF8
        mov    a, 0x58                               ; 3EFB
        jnb    0xE5, L_3F02                          ; 3EFD
        inc    0x41                                  ; 3F00
L_3F02::
        mov    r0, #0x41                             ; 3F02
        mov    r1, #0x5F                             ; 3F04
        lcall  fp_cmp                                ; 3F06
        jc     L_3F10                                ; 3F09
L_3F0B::
        lcall  fp_copy_r0_to_r1                      ; 3F0B
        mov    a, r3                                 ; 3F0E
        ret                                          ; 3F0F
L_3F10::
        mov    a, sfr_B                              ; 3F10
        rr     a                                     ; 3F12
        jnb    0xE0, L_3F0B                          ; 3F13
        inc    r3                                    ; 3F16
        inc    0x59                                  ; 3F17
        sjmp   L_3EF2                                ; 3F19
L_3F1B::
        clr    a                                     ; 3F1B
        ret                                          ; 3F1C

; RNG <number>
range_by_value::
        mov    a, #0x0F                              ; 3F1D
        anl    a, meter_state                        ; 3F1F
        mov    0x39, a                               ; 3F21
        mov    a, #0x7F                              ; 3F23
        anl    a, 0x33                               ; 3F25
        mov    0x33, a                               ; 3F27
        mov    r0, #0x33                             ; 3F29
        mov    r1, #0x5F                             ; 3F2B
        lcall  fp_copy_r0_to_r1                      ; 3F2D
        lcall  range_find_for_value                  ; 3F30
        mov    0x3C, a                               ; 3F33
        mov    r2, 0x3C                              ; 3F35
        mov    a, #0x01                              ; 3F37
        inc    r2                                    ; 3F39
        rrc    a                                     ; 3F3A
L_3F3B::
        rlc    a                                     ; 3F3B
        clr    c                                     ; 3F3C
        djnz   r2, L_3F3B                            ; 3F3D
        mov    0x34, a                               ; 3F3F
L_3F41::
        jnb    0x69, L_3F74                          ; 3F41
        mov    a, 0x34                               ; 3F44
        jz     L_3F74                                ; 3F46
        mov    a, #0x03                              ; 3F48
        anl    a, meter_mode                         ; 3F4A
        mov    sfr_B, #0x03                          ; 3F4C
        mov    r2, a                                 ; 3F4F
        mov    a, 0x39                               ; 3F50
        mul    ab                                    ; 3F52
        mov    r4, sfr_B                             ; 3F53
        mov    r5, a                                 ; 3F55
        mov    a, r5                                 ; 3F56
        add    a, #0xD4                              ; 3F57
        mov    sfr_DPL, a                            ; 3F59
        mov    a, r4                                 ; 3F5B
        addc   a, #0x6E                              ; 3F5C
        mov    sfr_DPH, a                            ; 3F5E
        mov    a, r2                                 ; 3F60
        movc   a, @a+dptr                            ; 3F61
        anl    a, 0x34                               ; 3F62
        jnz    L_3F70                                ; 3F64
        mov    a, 0x34                               ; 3F66
        clr    c                                     ; 3F68
        rrc    a                                     ; 3F69
        mov    0x34, a                               ; 3F6A
        dec    0x3C                                  ; 3F6C
        sjmp   L_3F72                                ; 3F6E
L_3F70::
        clr    0x69                                  ; 3F70
L_3F72::
        sjmp   L_3F41                                ; 3F72
L_3F74::
        mov    a, 0x34                               ; 3F74
        jz     L_3F8B                                ; 3F76
        mov    a, 0x3C                               ; 3F78
        swap   a                                     ; 3F7A
        anl    a, #0xF0                              ; 3F7B
        anl    a, #0x7F                              ; 3F7D
        mov    0x34, a                               ; 3F7F
        mov    a, #0x0F                              ; 3F81
        anl    a, meter_state                        ; 3F83
        orl    a, 0x34                               ; 3F85
        mov    meter_state, a                        ; 3F87
        sjmp   L_3F8D                                ; 3F89
L_3F8B::
        setb   0x6A                                  ; 3F8B
L_3F8D::
        ret                                          ; 3F8D

; FNC <mnemonic>: find function mnemonic in cmd_table
cmd_fnc_lookup::
        push   0x34                                  ; 3F8E
        push   0x2D                                  ; 3F90
        push   0x36                                  ; 3F92
        push   0x35                                  ; 3F94
        lcall  parser_reset                          ; 3F96
        mov    a, 0x34                               ; 3F99
        mov    dptr, #0x00E5                         ; 3F9B
        movx   @dptr, a                              ; 3F9E
        mov    a, 0x2D                               ; 3F9F
        mov    dptr, #0x00DE                         ; 3FA1
        movx   @dptr, a                              ; 3FA4
        mov    a, 0x36                               ; 3FA5
        mov    dptr, #0x00E7                         ; 3FA7
        movx   @dptr, a                              ; 3FAA
        mov    a, 0x35                               ; 3FAB
        mov    dptr, #0x00E6                         ; 3FAD
        movx   @dptr, a                              ; 3FB0
        pop    0x35                                  ; 3FB1
        pop    0x36                                  ; 3FB3
        pop    0x2D                                  ; 3FB5
        pop    0x34                                  ; 3FB7
        ret                                          ; 3FB9

; IEE n -> settings byte 1, tell the interface (C0|addr)
iee_store_address::
        mov    a, 0x34                               ; 3FBA
        lcall  nv_set_iface_config                   ; 3FBC
        mov    dptr, #0x0055                         ; 3FBF
        movx   a, @dptr                              ; 3FC2
        jnb    0xE7, L_3FDC                          ; 3FC3
        mov    dptr, #0x0059                         ; 3FC6
        movx   a, @dptr                              ; 3FC9
        jnz    L_3FDC                                ; 3FCA
        mov    a, 0x34                               ; 3FCC
        mov    dptr, #0x0053                         ; 3FCE
        push   0x2F                                  ; 3FD1
        push   0x2E                                  ; 3FD3
        lcall  iface_send_config_address             ; 3FD5
        pop    0x2E                                  ; 3FD8
        pop    0x2F                                  ; 3FDA
L_3FDC::
        ret                                          ; 3FDC
L_3FDD::
        ret                                          ; 3FDD

; rTL: clear remote state in the interface context
rtl_go_local::
        mov    sfr_DPH, 0x1D                         ; 3FDE
        mov    sfr_DPL, 0x1E                         ; 3FE1
        push   0x2F                                  ; 3FE4
        push   0x2E                                  ; 3FE6
        lcall  iface_clear_remote                    ; 3FE8
        pop    0x2E                                  ; 3FEB
        pop    0x2F                                  ; 3FED
        ret                                          ; 3FEF

; EMO n: output n readings (XDATA 0x0095)
emo_set_count::
        mov    a, #0x80                              ; 3FF0
        anl    a, 0x32                               ; 3FF2
        jz     L_3FFB                                ; 3FF4
        setb   0x6A                                  ; 3FF6
        ljmp   L_4005                                ; 3FF8
L_3FFB::
        mov    r0, #0x32                             ; 3FFB
        mov    dptr, #x_emo_count                    ; 3FFD
        lcall  i24_st_r0_xdata                       ; 4000
        clr    emo_continuous                        ; 4003
L_4005::
        ret                                          ; 4005

; TOL ON/OFF (talk only, byte 1 bit 7); keyboard T.ONLY step
tol_set::
        mov    a, #0x46                              ; 4006
        anl    a, 0x2F                               ; 4008
        jz     L_400F                                ; 400A
        ljmp   L_4037                                ; 400C
L_400F::
        lcall  nv_get_iface_config                   ; 400F
        anl    a, #0x7F                              ; 4012
        mov    0x34, a                               ; 4014
        mov    a, 0x2F                               ; 4016
        rrc    a                                     ; 4018
        jnc    L_4028                                ; 4019
        mov    a, #0x80                              ; 401B
        orl    a, 0x34                               ; 401D
        mov    0x34, a                               ; 401F
        setb   emo_continuous                        ; 4021
        setb   0x1B                                  ; 4023
        ljmp   L_4032                                ; 4025
L_4028::
        clr    emo_continuous                        ; 4028
        clr    0x1B                                  ; 402A
        mov    dptr, #x_emo_count                    ; 402C
        lcall  xdata_clear3                          ; 402F
L_4032::
        lcall  iee_store_address                     ; 4032
        sjmp   L_4039                                ; 4035
L_4037::
        setb   0x6A                                  ; 4037
L_4039::
        ret                                          ; 4039

; ZER <number>
zer_set_reference::
        mov    dptr, #T_6FCC                         ; 403A
        mov    r0, #0x41                             ; 403D
        lcall  fp_ld_code_r0                         ; 403F
        mov    r1, #0x33                             ; 4042
        lcall  fp_cmp                                ; 4044
        jc     L_405E                                ; 4047
        mov    dptr, #T_6FC8                         ; 4049
        mov    r1, #0x41                             ; 404C
        lcall  fp_ld_code_r1                         ; 404E
        mov    r0, #0x33                             ; 4051
        lcall  fp_cmp                                ; 4053
        jc     L_405E                                ; 4056
        mov    dptr, #x_zero_reference               ; 4058
        lcall  fp_st_r0_xdata                        ; 405B
L_405E::
        ret                                          ; 405E
L_405F::
        clr    c                                     ; 405F
        ret                                          ; 4060

; DBM <number>: 1e-4..9999, stored at XDATA 0x0075 (default 600)
dbm_set_reference::
        mov    dptr, #T_6FD8                         ; 4061
        mov    r0, #0x41                             ; 4064
        lcall  fp_ld_code_r0                         ; 4066
        mov    r1, #0x33                             ; 4069
        lcall  fp_cmp                                ; 406B
        jc     L_4085                                ; 406E
        mov    dptr, #T_6FD4                         ; 4070
        mov    r1, #0x41                             ; 4073
        lcall  fp_ld_code_r1                         ; 4075
        mov    r0, #0x33                             ; 4078
        lcall  fp_cmp                                ; 407A
        jc     L_4085                                ; 407D
        mov    dptr, #x_dbm_reference                ; 407F
        lcall  fp_st_r0_xdata                        ; 4082
L_4085::
        ret                                          ; 4085
L_4086::
        clr    c                                     ; 4086
        ret                                          ; 4087

; 1..114 (ROM 0x6FB9)
cdp_slot_valid::
        mov    dptr, #T_6FB9                         ; 4088
        clr    a                                     ; 408B
        movc   a, @a+dptr                            ; 408C
        cjne   a, 0x30, L_4090                       ; 408D
L_4090::
        jc     L_4096                                ; 4090
        mov    a, 0x30                               ; 4092
        jnz    L_4098                                ; 4094
L_4096::
        clr    c                                     ; 4096
        ret                                          ; 4097
L_4098::
        setb   c                                     ; 4098
        ret                                          ; 4099
L_409A::
        clr    c                                     ; 409A
        ret                                          ; 409B

; 1906 B: key handling / function+range selection state machine
task_keyboard::
        mov    dptr, #0x00E0                         ; 409C
        movx   a, @dptr                              ; 409F
        anl    a, #0x80                              ; 40A0
        jz     L_40AE                                ; 40A2
        mov    0x37, #0x00                           ; 40A4
        mov    0x38, #0xDF                           ; 40A7
        setb   0x6B                                  ; 40AA
        sjmp   L_40C1                                ; 40AC
L_40AE::
        mov    dptr, #0x00AA                         ; 40AE
        movx   a, @dptr                              ; 40B1
        anl    a, #0x80                              ; 40B2
        jz     L_40C0                                ; 40B4
        mov    0x37, #0x00                           ; 40B6
        mov    0x38, #0xA9                           ; 40B9
        clr    0x6B                                  ; 40BC
        sjmp   L_40C1                                ; 40BE
L_40C0::
        ret                                          ; 40C0
L_40C1::
        lcall  kbd_ctx_swap                          ; 40C1
        mov    fnsel_new_function, #0xFF             ; 40C4
        clr    0x6A                                  ; 40C7
        clr    0x69                                  ; 40C9
        mov    a, 0x2E                               ; 40CB
        mov    dptr, #T_6F24                         ; 40CD
        movc   a, @a+dptr                            ; 40D0
        mov    0x3B, a                               ; 40D1
        mov    a, #0x47                              ; 40D3
        anl    a, 0x2F                               ; 40D5
        cjne   a, #0x06, L_40F7                      ; 40D7
        jnb    cal_mode, L_40ED                      ; 40DA
        mov    r2, 0x2E                              ; 40DD
        cjne   r2, #0x17, L_40E4                     ; 40DF
        sjmp   L_40E9                                ; 40E2
L_40E4::
        mov    r2, 0x2E                              ; 40E4
        cjne   r2, #0x18, L_40ED                     ; 40E6
L_40E9::
        setb   0x6A                                  ; 40E9
        sjmp   L_40F3                                ; 40EB
L_40ED::
        mov    dptr, #x_reply_pending_cmd            ; 40ED
        mov    a, 0x2E                               ; 40F0
        movx   @dptr, a                              ; 40F2
L_40F3::
        lcall  kbd_cmd_finish                        ; 40F3
        ret                                          ; 40F6
L_40F7::
        mov    a, #0x40                              ; 40F7
        anl    a, 0x2F                               ; 40F9
        jz     L_4105                                ; 40FB
        mov    a, 0x31                               ; 40FD
        jnz    L_4105                                ; 40FF
        lcall  kbd_cmd_finish                        ; 4101
        ret                                          ; 4104
L_4105::
        jnb    0x2E, L_4129                          ; 4105
        mov    a, 0x2E                               ; 4108
        clr    c                                     ; 410A
        subb   a, #0x13                              ; 410B
        jnc    L_4129                                ; 410D
        mov    r2, 0x2E                              ; 410F
        cjne   r2, #0x08, L_4116                     ; 4111
        sjmp   L_4129                                ; 4114
L_4116::
        mov    r2, 0x2E                              ; 4116
        cjne   r2, #0x09, L_411D                     ; 4118
        sjmp   L_4129                                ; 411B
L_411D::
        setb   0x6A                                  ; 411D
        jb     0x6B, L_4125                          ; 411F
        lcall  lcd_show_error                        ; 4122
L_4125::
        lcall  kbd_cmd_finish                        ; 4125
        ret                                          ; 4128
L_4129::
        mov    a, 0x2E                               ; 4129
        clr    c                                     ; 412B
        subb   a, #0x13                              ; 412C
        jnc    fnsel_dispatch                        ; 412E
        setb   0x69                                  ; 4130

; 2Eh = command index 0..0x12 (VPU..CON) -> jump table fnsel_jtab
fnsel_dispatch::
        mov    a, 0x2E                               ; 4132
        clr    c                                     ; 4134
        mov    sfr_B, a                              ; 4135
        rlc    a                                     ; 4137
        add    a, sfr_B                              ; 4138
        mov    dptr, #fnsel_jtab                     ; 413A
        jmp    @a+dptr                               ; 413D

fnsel_VPU::
        clr    peak_mode_b1                          ; 413E
        setb   peak_mode_b0                          ; 4140
        mov    fnsel_new_function, #0x00             ; 4142
        ljmp   fnsel_apply                           ; 4145

fnsel_VPL::
        setb   peak_mode_b1                          ; 4148
        clr    peak_mode_b0                          ; 414A
        mov    fnsel_new_function, #0x00             ; 414C
        ljmp   fnsel_apply                           ; 414F

fnsel_VPP::
        setb   peak_mode_b1                          ; 4152
        setb   peak_mode_b0                          ; 4154
        mov    fnsel_new_function, #0x00             ; 4156
        ljmp   fnsel_apply                           ; 4159

fnsel_VDC::
        mov    fnsel_new_function, #0x01             ; 415C
        ljmp   fnsel_apply                           ; 415F

fnsel_VAC::
        mov    fnsel_new_function, #0x02             ; 4162
        ljmp   fnsel_apply                           ; 4165

fnsel_VRM::
        mov    fnsel_new_function, #0x03             ; 4168
        ljmp   fnsel_apply                           ; 416B

fnsel_RFW::
        mov    fnsel_new_function, #0x04             ; 416E
        ljmp   fnsel_apply                           ; 4171

fnsel_RTW::
        mov    fnsel_new_function, #0x05             ; 4174
        ljmp   fnsel_apply                           ; 4177

fnsel_IDC::
        mov    fnsel_new_function, #0x06             ; 417A
        ljmp   fnsel_apply                           ; 417D

fnsel_IAC::
        mov    fnsel_new_function, #0x07             ; 4180
        ljmp   fnsel_apply                           ; 4183

fnsel_TPP::
        clr    time_start_negslope                   ; 4186
        clr    time_stop_negslope                    ; 4188
        mov    fnsel_new_function, #0x08             ; 418A
        ljmp   fnsel_apply                           ; 418D

fnsel_TPN::
        clr    time_start_negslope                   ; 4190
        setb   time_stop_negslope                    ; 4192
        mov    fnsel_new_function, #0x08             ; 4194
        ljmp   fnsel_apply                           ; 4197

fnsel_TNP::
        setb   time_start_negslope                   ; 419A
        clr    time_stop_negslope                    ; 419C
        mov    fnsel_new_function, #0x08             ; 419E
        ljmp   fnsel_apply                           ; 41A1

fnsel_TNN::
        setb   time_start_negslope                   ; 41A4
        setb   time_stop_negslope                    ; 41A6
        mov    fnsel_new_function, #0x08             ; 41A8
        ljmp   fnsel_apply                           ; 41AB

fnsel_CAP::
        mov    fnsel_new_function, #0x09             ; 41AE
        ljmp   fnsel_apply                           ; 41B1

fnsel_FRQ::
        mov    fnsel_new_function, #0x0A             ; 41B4
        ljmp   fnsel_apply                           ; 41B7

fnsel_TDC::
        mov    fnsel_new_function, #0x0B             ; 41BA
        ljmp   fnsel_apply                           ; 41BD

fnsel_DIO::
        mov    fnsel_new_function, #0x0C             ; 41C0
        ljmp   fnsel_apply                           ; 41C3

fnsel_CON::
        mov    fnsel_new_function, #0x0D             ; 41C6
        ljmp   fnsel_apply                           ; 41C9

cmd_FNC::
        mov    rx_index, 0x30                        ; 41CC
        mov    a, #0xC0                              ; 41CF
        anl    a, rx_count                           ; 41D1
        mov    r2, a                                 ; 41D3
        mov    a, rx_count                           ; 41D4
        add    a, 0x31                               ; 41D6
        anl    a, #0x3F                              ; 41D8
        orl    a, r2                                 ; 41DA
        mov    rx_count, a                           ; 41DB
        lcall  cmd_fnc_lookup                        ; 41DD
        ljmp   fnsel_apply                           ; 41E0

cmd_RNG::
        setb   0x69                                  ; 41E3
        ljmp   fnsel_apply                           ; 41E5

cmd_DBM::
        mov    a, #0x07                              ; 41E8
        anl    a, 0x2F                               ; 41EA
        cjne   a, #0x01, L_4214                      ; 41EC
        mov    a, #0x0F                              ; 41EF
        anl    a, meter_state                        ; 41F1
        jz     L_4210                                ; 41F3
        mov    a, #0x0F                              ; 41F5
        anl    a, meter_state                        ; 41F7
        clr    c                                     ; 41F9
        subb   a, #0x04                              ; 41FA
        jnc    L_4210                                ; 41FC
        jb     cal_mode, L_4210                      ; 41FE
        jb     0x10, L_420A                          ; 4201
        setb   0x10                                  ; 4204
        clr    0x11                                  ; 4206
        sjmp   L_420E                                ; 4208
L_420A::
        lcall  kbd_cmd_finish                        ; 420A
        ret                                          ; 420D
L_420E::
        sjmp   L_4212                                ; 420E
L_4210::
        setb   0x6A                                  ; 4210
L_4212::
        sjmp   L_4242                                ; 4212
L_4214::
        mov    a, #0x07                              ; 4214
        anl    a, 0x2F                               ; 4216
        jnz    L_4229                                ; 4218
        jnb    0x10, L_4223                          ; 421A
        clr    0x10                                  ; 421D
        clr    0x11                                  ; 421F
        sjmp   L_4227                                ; 4221
L_4223::
        lcall  kbd_cmd_finish                        ; 4223
        ret                                          ; 4226
L_4227::
        sjmp   L_4242                                ; 4227
L_4229::
        lcall  dbm_set_reference                     ; 4229
        jnc    L_4232                                ; 422C
        setb   0x6A                                  ; 422E
        sjmp   L_4242                                ; 4230
L_4232::
        jb     0x6B, L_4237                          ; 4232
        setb   0x10                                  ; 4235
L_4237::
        jnb    0x10, L_423E                          ; 4237
        clr    0x11                                  ; 423A
        sjmp   L_4242                                ; 423C
L_423E::
        lcall  kbd_cmd_finish                        ; 423E
        ret                                          ; 4241
L_4242::
        ljmp   fnsel_apply                           ; 4242

cmd_ZER::
        mov    a, #0x0F                              ; 4245
        anl    a, meter_state                        ; 4247
        cjne   a, #0x0D, L_4252                      ; 4249
        setb   0x6A                                  ; 424C
        lcall  kbd_cmd_finish                        ; 424E
        ret                                          ; 4251
L_4252::
        mov    a, #0x46                              ; 4252
        anl    a, 0x2F                               ; 4254
        jnz    L_426D                                ; 4256
        mov    a, 0x2F                               ; 4258
        rrc    a                                     ; 425A
        jnc    L_4268                                ; 425B
        jnb    cal_mode, L_4264                      ; 425D
        setb   0x6A                                  ; 4260
        sjmp   L_4266                                ; 4262
L_4264::
        setb   0x11                                  ; 4264
L_4266::
        sjmp   L_426A                                ; 4266
L_4268::
        clr    0x11                                  ; 4268
L_426A::
        ljmp   L_42FA                                ; 426A
L_426D::
        jb     0x7E, L_4273                          ; 426D
        ljmp   L_42E5                                ; 4270
L_4273::
        lcall  cmd_param_first_char                  ; 4273
        cjne   a, #0x4D, L_427B                      ; 4276
        sjmp   L_427E                                ; 4279
L_427B::
        ljmp   L_42E1                                ; 427B
L_427E::
        jnb    cal_mode, L_4285                      ; 427E
        setb   0x6A                                  ; 4281
        sjmp   L_42DF                                ; 4283
L_4285::
        jb     0x35, L_428C                          ; 4285
        setb   0x6A                                  ; 4288
        sjmp   L_42DF                                ; 428A
L_428C::
        jnb    0x10, L_42B7                          ; 428C
        mov    0x34, #0x00                           ; 428F
L_4292::
        mov    a, 0x34                               ; 4292
        setb   c                                     ; 4294
        subb   a, #0x03                              ; 4295
        jnc    L_42B5                                ; 4297
        mov    a, 0x34                               ; 4299
        mov    dptr, #0x008D                         ; 429B
        lcall  dptr_add_a                            ; 429E
        movx   a, @dptr                              ; 42A1
        mov    r2, a                                 ; 42A2
        mov    a, 0x34                               ; 42A3
        mov    dptr, #x_zero_reference               ; 42A5
        lcall  dptr_add_a                            ; 42A8
        mov    a, r2                                 ; 42AB
        movx   @dptr, a                              ; 42AC
        mov    a, 0x34                               ; 42AD
        add    a, #0x01                              ; 42AF
        mov    0x34, a                               ; 42B1
        jnc    L_4292                                ; 42B3
L_42B5::
        sjmp   L_42DD                                ; 42B5
L_42B7::
        mov    0x34, #0x00                           ; 42B7
L_42BA::
        mov    a, 0x34                               ; 42BA
        setb   c                                     ; 42BC
        subb   a, #0x03                              ; 42BD
        jnc    L_42DD                                ; 42BF
        mov    a, 0x34                               ; 42C1
        mov    dptr, #0x0091                         ; 42C3
        lcall  dptr_add_a                            ; 42C6
        movx   a, @dptr                              ; 42C9
        mov    r2, a                                 ; 42CA
        mov    a, 0x34                               ; 42CB
        mov    dptr, #x_zero_reference               ; 42CD
        lcall  dptr_add_a                            ; 42D0
        mov    a, r2                                 ; 42D3
        movx   @dptr, a                              ; 42D4
        mov    a, 0x34                               ; 42D5
        add    a, #0x01                              ; 42D7
        mov    0x34, a                               ; 42D9
        jnc    L_42BA                                ; 42DB
L_42DD::
        setb   0x11                                  ; 42DD
L_42DF::
        sjmp   L_42E3                                ; 42DF
L_42E1::
        setb   0x6A                                  ; 42E1
L_42E3::
        sjmp   L_42FA                                ; 42E3
L_42E5::
        mov    a, #0x47                              ; 42E5
        anl    a, 0x2F                               ; 42E7
        cjne   a, #0x04, L_42FA                      ; 42E9
        lcall  zer_set_reference                     ; 42EC
        jnc    L_42F5                                ; 42EF
        setb   0x6A                                  ; 42F1
        sjmp   L_42FA                                ; 42F3
L_42F5::
        jb     0x6B, L_42FA                          ; 42F5
        setb   0x11                                  ; 42F8
L_42FA::
        ljmp   fnsel_apply                           ; 42FA

cmd_MIN::
        jnb    cal_mode, L_4306                      ; 42FD
        setb   0x6A                                  ; 4300
        lcall  kbd_cmd_finish                        ; 4302
        ret                                          ; 4305
L_4306::
        mov    dptr, #x_reply_pending_cmd            ; 4306
        mov    a, 0x2E                               ; 4309
        movx   @dptr, a                              ; 430B
        ljmp   fnsel_apply                           ; 430C

cmd_MAX::
        jnb    cal_mode, L_4318                      ; 430F
        setb   0x6A                                  ; 4312
        lcall  kbd_cmd_finish                        ; 4314
        ret                                          ; 4317
L_4318::
        mov    dptr, #x_reply_pending_cmd            ; 4318
        mov    a, 0x2E                               ; 431B
        movx   @dptr, a                              ; 431D
        ljmp   fnsel_apply                           ; 431E

cmd_CLM::
        jnb    cal_mode, L_432A                      ; 4321
        setb   0x6A                                  ; 4324
        lcall  kbd_cmd_finish                        ; 4326
        ret                                          ; 4329
L_432A::
        ljmp   fnsel_apply                           ; 432A

cmd_MSP::
        mov    a, 0x30                               ; 432D
        jz     L_434F                                ; 432F
        mov    a, 0x30                               ; 4331
        clr    c                                     ; 4333
        subb   a, #0x04                              ; 4334
        jnc    L_434F                                ; 4336
        jnb    cal_mode, L_434A                      ; 4338
        mov    a, #0x03                              ; 433B
        anl    a, meter_mode                         ; 433D
        mov    r2, 0x30                              ; 433F
        dec    r2                                    ; 4341
        clr    c                                     ; 4342
        subb   a, r2                                 ; 4343
        jz     L_4348                                ; 4344
        setb   0x6A                                  ; 4346
L_4348::
        sjmp   L_434D                                ; 4348
L_434A::
        lcall  set_speed                             ; 434A
L_434D::
        sjmp   L_4351                                ; 434D
L_434F::
        setb   0x6A                                  ; 434F
L_4351::
        ljmp   fnsel_apply                           ; 4351

cmd_RSL::
        lcall  func_to_cmd_index                     ; 4354
        mov    0x39, a                               ; 4357
        mov    0x34, #0x00                           ; 4359
L_435C::
        mov    a, 0x34                               ; 435C
        clr    c                                     ; 435E
        subb   a, #0x03                              ; 435F
        jnc    L_438C                                ; 4361
        mov    a, 0x34                               ; 4363
        mov    sfr_B, #0x03                          ; 4365
        mov    r2, a                                 ; 4368
        mov    a, 0x39                               ; 4369
        mul    ab                                    ; 436B
        mov    r4, sfr_B                             ; 436C
        mov    r5, a                                 ; 436E
        mov    a, r5                                 ; 436F
        add    a, #0x40                              ; 4370
        mov    sfr_DPL, a                            ; 4372
        mov    a, r4                                 ; 4374
        addc   a, #0x6E                              ; 4375
        mov    sfr_DPH, a                            ; 4377
        mov    a, r2                                 ; 4379
        movc   a, @a+dptr                            ; 437A
        clr    c                                     ; 437B
        subb   a, 0x30                               ; 437C
        jnz    L_4388                                ; 437E
        mov    a, 0x34                               ; 4380
        add    a, #0x0A                              ; 4382
        mov    0x34, a                               ; 4384
        sjmp   L_438A                                ; 4386
L_4388::
        inc    0x34                                  ; 4388
L_438A::
        sjmp   L_435C                                ; 438A
L_438C::
        mov    a, 0x34                               ; 438C
        clr    c                                     ; 438E
        subb   a, #0x0A                              ; 438F
        jnc    L_4397                                ; 4391
        setb   0x6A                                  ; 4393
        sjmp   L_43B3                                ; 4395
L_4397::
        mov    a, 0x34                               ; 4397
        clr    c                                     ; 4399
        subb   a, #0x09                              ; 439A
        mov    0x30, a                               ; 439C
        jnb    cal_mode, L_43B0                      ; 439E
        mov    a, #0x03                              ; 43A1
        anl    a, meter_mode                         ; 43A3
        mov    r2, 0x30                              ; 43A5
        dec    r2                                    ; 43A7
        clr    c                                     ; 43A8
        subb   a, r2                                 ; 43A9
        jz     L_43AE                                ; 43AA
        setb   0x6A                                  ; 43AC
L_43AE::
        sjmp   L_43B3                                ; 43AE
L_43B0::
        lcall  set_speed                             ; 43B0
L_43B3::
        ljmp   fnsel_apply                           ; 43B3

cmd_TRG::
        mov    0x39, meter_mode                      ; 43B6
        jnb    0x6B, L_43F1                          ; 43B9
        lcall  cmd_param_first_char                  ; 43BC
        mov    0x34, a                               ; 43BF
        mov    r2, 0x34                              ; 43C1
        cjne   r2, #0x49, L_43D3                     ; 43C3
        jnb    cal_mode, L_43CD                      ; 43C6
        setb   0x6A                                  ; 43C9
        sjmp   L_43D1                                ; 43CB
L_43CD::
        clr    0x0A                                  ; 43CD
        clr    0x0B                                  ; 43CF
L_43D1::
        sjmp   L_43EF                                ; 43D1
L_43D3::
        mov    r2, 0x34                              ; 43D3
        cjne   r2, #0x42, L_43E0                     ; 43D5
        setb   0x0A                                  ; 43D8
        clr    0x0B                                  ; 43DA
        clr    0x3B                                  ; 43DC
        sjmp   L_43EF                                ; 43DE
L_43E0::
        mov    r2, 0x34                              ; 43E0
        cjne   r2, #0x45, L_43ED                     ; 43E2
        clr    0x0A                                  ; 43E5
        setb   0x0B                                  ; 43E7
        clr    0x3B                                  ; 43E9
        sjmp   L_43EF                                ; 43EB
L_43ED::
        setb   0x6A                                  ; 43ED
L_43EF::
        sjmp   L_4401                                ; 43EF
L_43F1::
        mov    a, 0x30                               ; 43F1
        jnz    L_43FB                                ; 43F3
        clr    0x0A                                  ; 43F5
        clr    0x0B                                  ; 43F7
        sjmp   L_4401                                ; 43F9
L_43FB::
        clr    0x0A                                  ; 43FB
        setb   0x0B                                  ; 43FD
        setb   0x3B                                  ; 43FF
L_4401::
        mov    a, 0x39                               ; 4401
        clr    c                                     ; 4403
        subb   a, meter_mode                         ; 4404
        jz     L_440A                                ; 4406
        clr    0x26                                  ; 4408
L_440A::
        ljmp   fnsel_apply                           ; 440A

cmd_X::
        mov    a, #0x47                              ; 440D
        anl    a, 0x2F                               ; 440F
        cjne   a, #0x02, L_4421                      ; 4411
        mov    r2, 0x30                              ; 4414
        cjne   r2, #0x01, L_441B                     ; 4416
        sjmp   L_4421                                ; 4419
L_441B::
        setb   0x6A                                  ; 441B
        lcall  kbd_cmd_finish                        ; 441D
        ret                                          ; 4420
L_4421::
        mov    c, 0x0A                               ; 4421
        jnb    0x0B, L_4427                          ; 4423
        cpl    c                                     ; 4426
L_4427::
        jnc    L_4441                                ; 4427
        jnb    cal_mode, L_4431                      ; 4429
        lcall  cal_step_allowed                      ; 442C
        jc     L_4441                                ; 442F
L_4431::
        jnb    0x6B, L_4438                          ; 4431
        setb   0x25                                  ; 4434
        sjmp   L_443A                                ; 4436
L_4438::
        clr    0x25                                  ; 4438
L_443A::
        lcall  trigger_restart_measure               ; 443A
        setb   0x24                                  ; 443D
        sjmp   L_4446                                ; 443F
L_4441::
        jnb    0x6B, L_4446                          ; 4441
        setb   0x6A                                  ; 4444
L_4446::
        ljmp   fnsel_apply                           ; 4446

; CAL [ON[,n]|OFF] handler in task_keyboard (keyboard + remote share it)
cmd_cal::
        mov    a, #0x46                              ; 4449
        anl    a, 0x2F                               ; 444B
        jnz    L_4477                                ; 444D
        mov    a, 0x2F                               ; 444F
        rrc    a                                     ; 4451
        jnc    L_4460                                ; 4452
        jnb    cal_enable, L_445C                    ; 4454
        lcall  cal_mode_enter                        ; 4457
        sjmp   L_445E                                ; 445A
L_445C::
        setb   0x6A                                  ; 445C
L_445E::
        sjmp   L_4475                                ; 445E
L_4460::
        jnb    cal_mode, L_4473                      ; 4460
        clr    cal_mode                              ; 4463
        mov    dptr, #0x00EB                         ; 4465
        movx   a, @dptr                              ; 4468
        anl    a, #0x10                              ; 4469
        jnz    L_4471                                ; 446B
        clr    0x0A                                  ; 446D
        clr    0x0B                                  ; 446F
L_4471::
        sjmp   L_4475                                ; 4471
L_4473::
        clr    cal_enable                            ; 4473
L_4475::
        sjmp   L_44A8                                ; 4475
L_4477::
        mov    a, #0x47                              ; 4477
        anl    a, 0x2F                               ; 4479
        cjne   a, #0x02, L_44A6                      ; 447B
        mov    a, 0x30                               ; 447E
        clr    c                                     ; 4480
        subb   a, #0x02                              ; 4481
        jnc    L_44A2                                ; 4483
        jnb    cal_mode, L_448B                      ; 4485
        jb     0x6B, L_4491                          ; 4488
L_448B::
        jnb    cal_enable, L_449E                    ; 448B
        jb     0x6B, L_449E                          ; 448E
L_4491::
        mov    a, 0x30                               ; 4491
        rrc    a                                     ; 4493
        mov    cal_hot, c                            ; 4494
        jb     cal_mode, L_449C                      ; 4496
        lcall  cal_mode_enter                        ; 4499
L_449C::
        sjmp   L_44A0                                ; 449C
L_449E::
        setb   0x6A                                  ; 449E
L_44A0::
        sjmp   L_44A4                                ; 44A0
L_44A2::
        setb   0x6A                                  ; 44A2
L_44A4::
        sjmp   L_44A8                                ; 44A4
L_44A6::
        setb   0x6A                                  ; 44A6
L_44A8::
        ljmp   fnsel_apply                           ; 44A8

cmd_OUT::
        lcall  cmd_param_first_char                  ; 44AB
        mov    0x34, a                               ; 44AE
        mov    r2, 0x34                              ; 44B0
        cjne   r2, #0x53, L_44B9                     ; 44B2
        clr    0x17                                  ; 44B5
        sjmp   L_44CF                                ; 44B7
L_44B9::
        mov    r2, 0x34                              ; 44B9
        cjne   r2, #0x4E, L_44CD                     ; 44BB
        jnb    cal_mode, L_44C9                      ; 44BE
        setb   0x6A                                  ; 44C1
        lcall  kbd_cmd_finish                        ; 44C3
        ret                                          ; 44C6
L_44C7::
        sjmp   L_44CB                                ; 44C7
L_44C9::
        setb   0x17                                  ; 44C9
L_44CB::
        sjmp   L_44CF                                ; 44CB
L_44CD::
        setb   0x6A                                  ; 44CD
L_44CF::
        ljmp   fnsel_apply                           ; 44CF

cmd_JCV::
        mov    a, #0x47                              ; 44D2
        anl    a, 0x2F                               ; 44D4
        cjne   a, #0x03, L_44E4                      ; 44D6
        lcall  jcv_set_ptr                           ; 44D9
        mov    dptr, #x_reply_pending_cmd            ; 44DC
        mov    a, 0x2E                               ; 44DF
        movx   @dptr, a                              ; 44E1
        sjmp   L_44EE                                ; 44E2
L_44E4::
        jnb    cal_mode, L_44EC                      ; 44E4
        lcall  diag_clear_counters                   ; 44E7
        sjmp   L_44EE                                ; 44EA
L_44EC::
        setb   0x6A                                  ; 44EC
L_44EE::
        ljmp   fnsel_apply                           ; 44EE

cmd_DMP::
        mov    dptr, #x_reply_pending_cmd            ; 44F1
        mov    a, 0x2E                               ; 44F4
        movx   @dptr, a                              ; 44F6
        ljmp   fnsel_apply                           ; 44F7

cmd_CDP::
        jb     cal_mode, L_4503                      ; 44FA
        setb   0x6A                                  ; 44FD
        lcall  kbd_cmd_finish                        ; 44FF
        ret                                          ; 4502
L_4503::
        jnb    0x7D, L_454A                          ; 4503
        jnb    0x7E, L_452C                          ; 4506
        lcall  cmd_param_first_char                  ; 4509
        mov    0x34, a                               ; 450C
        mov    r2, 0x34                              ; 450E
        cjne   r2, #0x52, L_451B                     ; 4510
        lcall  cal_seal_normal                       ; 4513
        mov    0x3B, #0x41                           ; 4516
        sjmp   L_452A                                ; 4519
L_451B::
        mov    r2, 0x34                              ; 451B
        cjne   r2, #0x53, L_4528                     ; 451D
        lcall  cal_seal_altered                      ; 4520
        mov    0x3B, #0x41                           ; 4523
        sjmp   L_452A                                ; 4526
L_4528::
        setb   0x6A                                  ; 4528
L_452A::
        sjmp   L_4548                                ; 452A
L_452C::
        mov    a, #0x47                              ; 452C
        anl    a, 0x2F                               ; 452E
        cjne   a, #0x02, L_4546                      ; 4530
        lcall  cdp_slot_valid                        ; 4533
        jnc    L_4542                                ; 4536
        mov    a, #0x80                              ; 4538
        orl    a, 0x30                               ; 453A
        mov    dptr, #x_cdp_slot                     ; 453C
        movx   @dptr, a                              ; 453F
        sjmp   L_4544                                ; 4540
L_4542::
        setb   0x6A                                  ; 4542
L_4544::
        sjmp   L_4548                                ; 4544
L_4546::
        setb   0x6A                                  ; 4546
L_4548::
        sjmp   L_456A                                ; 4548
L_454A::
        mov    dptr, #x_cdp_slot                     ; 454A
        movx   a, @dptr                              ; 454D
        anl    a, #0x80                              ; 454E
        jnz    L_4556                                ; 4550
        setb   0x6A                                  ; 4552
        sjmp   L_456A                                ; 4554
L_4556::
        mov    dptr, #x_cdp_slot                     ; 4556
        movx   a, @dptr                              ; 4559
        anl    a, #0x7F                              ; 455A
        movx   @dptr, a                              ; 455C
        mov    a, #0x47                              ; 455D
        anl    a, 0x2F                               ; 455F
        cjne   a, #0x02, L_4567                      ; 4561
        lcall  cdp_int_to_fp                         ; 4564
L_4567::
        lcall  cdp_write_slot                        ; 4567
L_456A::
        ljmp   fnsel_apply                           ; 456A

cmd_RMS::
        jb     cal_mode, L_4576                      ; 456D
        setb   0x6A                                  ; 4570
        lcall  kbd_cmd_finish                        ; 4572
        ret                                          ; 4575
L_4576::
        mov    a, 0x30                               ; 4576
        lcall  rms_set_byte                          ; 4578
        ljmp   fnsel_apply                           ; 457B

cmd_SIX::
        mov    a, 0x2F                               ; 457E
        rrc    a                                     ; 4580
        jnc    L_4588                                ; 4581
        lcall  mains_set_60hz                        ; 4583
        sjmp   L_458B                                ; 4586
L_4588::
        lcall  mains_set_50hz                        ; 4588
L_458B::
        ljmp   fnsel_apply                           ; 458B

cmd_CR::
        mov    a, 0x2F                               ; 458E
        rrc    a                                     ; 4590
        jnc    L_4598                                ; 4591
        lcall  cr_set_on                             ; 4593
        sjmp   L_459B                                ; 4596
L_4598::
        lcall  cr_set_off                            ; 4598
L_459B::
        ljmp   fnsel_apply                           ; 459B

cmd_IEE::
        jnb    0x6B, L_45A9                          ; 459E
        mov    dptr, #0x0058                         ; 45A1
        movx   a, @dptr                              ; 45A4
        anl    a, #0x80                              ; 45A5
        jz     L_45B0                                ; 45A7
L_45A9::
        mov    a, #0x1E                              ; 45A9
        clr    c                                     ; 45AB
        subb   a, 0x30                               ; 45AC
        jnc    L_45B4                                ; 45AE
L_45B0::
        setb   0x6A                                  ; 45B0
        sjmp   L_45C0                                ; 45B2
L_45B4::
        lcall  nv_get_iface_config                   ; 45B4
        anl    a, #0x80                              ; 45B7
        orl    a, 0x30                               ; 45B9
        mov    0x34, a                               ; 45BB
        lcall  iee_store_address                     ; 45BD
L_45C0::
        ljmp   fnsel_apply                           ; 45C0

cmd_MTS::
        ljmp   fnsel_apply                           ; 45C3

cmd_EMO_TOL::
        jnb    0x6B, L_4607                          ; 45C6
        mov    dptr, #0x0058                         ; 45C9
        movx   a, @dptr                              ; 45CC
        anl    a, #0x80                              ; 45CD
        jz     L_45D6                                ; 45CF
        lcall  tol_set                               ; 45D1
        sjmp   L_4605                                ; 45D4
L_45D6::
        mov    dptr, #0x005A                         ; 45D6
        movx   a, @dptr                              ; 45D9
        cjne   a, #0x03, L_4603                      ; 45DA
        jnb    0x7E, L_45EE                          ; 45DD
        lcall  cmd_param_first_char                  ; 45E0
        cjne   a, #0x41, L_45EA                      ; 45E3
        setb   emo_continuous                        ; 45E6
        sjmp   L_45EC                                ; 45E8
L_45EA::
        setb   0x6A                                  ; 45EA
L_45EC::
        sjmp   L_4601                                ; 45EC
L_45EE::
        mov    a, #0x07                              ; 45EE
        anl    a, 0x2F                               ; 45F0
        cjne   a, #0x05, L_45FE                      ; 45F2
        mov    0x31, #0x00                           ; 45F5
        mov    0x32, #0x00                           ; 45F8
        mov    0x30, #0x01                           ; 45FB
L_45FE::
        lcall  emo_set_count                         ; 45FE
L_4601::
        sjmp   L_4605                                ; 4601
L_4603::
        setb   0x6A                                  ; 4603
L_4605::
        sjmp   L_460A                                ; 4605
L_4607::
        lcall  tol_set                               ; 4607
L_460A::
        ljmp   fnsel_apply                           ; 460A
L_460D::
        mov    a, 0x2F                               ; 460D
        rrc    a                                     ; 460F
        jnc    L_4615                                ; 4610
        lcall  rtl_go_local                          ; 4612
L_4615::
        ljmp   fnsel_apply                           ; 4615

key_range_down::
        lcall  range_can_go_down                     ; 4618
        jnc    L_4628                                ; 461B
        mov    a, meter_state                        ; 461D
        clr    c                                     ; 461F
        subb   a, #0x10                              ; 4620
        mov    meter_state, a                        ; 4622
        setb   0x13                                  ; 4624
        sjmp   L_462B                                ; 4626
L_4628::
        mov    0x3B, #0x00                           ; 4628
L_462B::
        ljmp   fnsel_apply                           ; 462B

key_range_up::
        lcall  range_can_go_up                       ; 462E
        jnc    L_463D                                ; 4631
        mov    a, meter_state                        ; 4633
        add    a, #0x10                              ; 4635
        mov    meter_state, a                        ; 4637
        setb   0x13                                  ; 4639
        sjmp   L_4640                                ; 463B
L_463D::
        mov    0x3B, #0x00                           ; 463D
L_4640::
        ljmp   fnsel_apply                           ; 4640

key_autorange::
        mov    a, 0x2F                               ; 4643
        rrc    a                                     ; 4645
        mov    meter_autorange, c                    ; 4646
        ljmp   fnsel_apply                           ; 4648
L_464B::
        lcall  min_reset                             ; 464B
        ljmp   fnsel_apply                           ; 464E
L_4651::
        lcall  max_reset                             ; 4651
        ljmp   fnsel_apply                           ; 4654
L_4657::
        ljmp   fnsel_apply                           ; 4657
L_465A::
        ljmp   fnsel_apply                           ; 465A

; 19 x LJMP, one per function mnemonic
fnsel_jtab::
        ljmp   fnsel_VPU                             ; 465D
L_4660::
        ljmp   fnsel_VPL                             ; 4660
L_4663::
        ljmp   fnsel_VPP                             ; 4663
L_4666::
        ljmp   fnsel_VDC                             ; 4666
L_4669::
        ljmp   fnsel_VAC                             ; 4669
L_466C::
        ljmp   fnsel_VRM                             ; 466C
L_466F::
        ljmp   fnsel_RFW                             ; 466F
L_4672::
        ljmp   fnsel_RTW                             ; 4672
L_4675::
        ljmp   fnsel_IDC                             ; 4675
L_4678::
        ljmp   fnsel_IAC                             ; 4678
L_467B::
        ljmp   fnsel_TPP                             ; 467B
L_467E::
        ljmp   fnsel_TPN                             ; 467E
L_4681::
        ljmp   fnsel_TNP                             ; 4681
L_4684::
        ljmp   fnsel_TNN                             ; 4684
L_4687::
        ljmp   fnsel_CAP                             ; 4687
L_468A::
        ljmp   fnsel_FRQ                             ; 468A
L_468D::
        ljmp   fnsel_TDC                             ; 468D
L_4690::
        ljmp   fnsel_DIO                             ; 4690
L_4693::
        ljmp   fnsel_CON                             ; 4693
L_4696::
        ljmp   cmd_FNC                               ; 4696
L_4699::
        ljmp   cmd_RNG                               ; 4699
L_469C::
        ljmp   cmd_DBM                               ; 469C
L_469F::
        ljmp   cmd_ZER                               ; 469F
L_46A2::
        ljmp   cmd_MIN                               ; 46A2
L_46A5::
        ljmp   cmd_MAX                               ; 46A5
L_46A8::
        ljmp   cmd_CLM                               ; 46A8
L_46AB::
        ljmp   cmd_MSP                               ; 46AB
L_46AE::
        ljmp   cmd_RSL                               ; 46AE
L_46B1::
        ljmp   cmd_TRG                               ; 46B1
L_46B4::
        ljmp   cmd_X                                 ; 46B4
L_46B7::
        ljmp   cmd_cal                               ; 46B7
L_46BA::
        ljmp   cmd_OUT                               ; 46BA
L_46BD::
        ljmp   cmd_JCV                               ; 46BD
L_46C0::
        ljmp   cmd_DMP                               ; 46C0
L_46C3::
        ljmp   cmd_CDP                               ; 46C3
L_46C6::
        ljmp   cmd_RMS                               ; 46C6
L_46C9::
        ljmp   cmd_SIX                               ; 46C9
L_46CC::
        ljmp   cmd_CR                                ; 46CC
L_46CF::
        ljmp   cmd_IEE                               ; 46CF
L_46D2::
        ljmp   cmd_MTS                               ; 46D2
L_46D5::
        ljmp   cmd_EMO_TOL                           ; 46D5
L_46D8::
        ljmp   L_460D                                ; 46D8
L_46DB::
        ljmp   key_range_down                        ; 46DB
L_46DE::
        ljmp   key_range_up                          ; 46DE
L_46E1::
        ljmp   key_autorange                         ; 46E1
L_46E4::
        ljmp   L_464B                                ; 46E4
L_46E7::
        ljmp   L_4651                                ; 46E7
L_46EA::
        ljmp   L_4657                                ; 46EA
L_46ED::
        ljmp   L_465A                                ; 46ED

; 3Ah = new function number; applies it to meter_state
fnsel_apply::
        jnb    0x69, L_4707                          ; 46F0
        jnb    0x7E, L_4707                          ; 46F3
        lcall  cmd_param_first_char                  ; 46F6
        cjne   a, #0x41, L_4705                      ; 46F9
        lcall  cmd_param_first_char                  ; 46FC
        cjne   a, #0x41, L_4707                      ; 46FF
        jnb    cal_mode, L_4707                      ; 4702
L_4705::
        setb   0x6A                                  ; 4705
L_4707::
        mov    r2, fnsel_new_function                ; 4707
        cjne   r2, #0xFF, L_470F                     ; 4709
        ljmp   L_4769                                ; 470C
L_470F::
        jnb    0x6A, L_4715                          ; 470F
        ljmp   L_4769                                ; 4712
L_4715::
        mov    a, #0x0F                              ; 4715
        anl    a, meter_state                        ; 4717
        clr    c                                     ; 4719
        subb   a, fnsel_new_function                 ; 471A
        jz     L_4769                                ; 471C
        mov    a, #0x0F                              ; 471E
        anl    a, meter_state                        ; 4720
        cjne   a, #0x0A, L_472F                      ; 4722
        mov    dptr, #0x00C1                         ; 4725
        movx   a, @dptr                              ; 4728
        orl    a, #0x08                              ; 4729
        movx   @dptr, a                              ; 472B
        lcall  internal_temp_init                    ; 472C
L_472F::
        mov    a, #0xF0                              ; 472F
        anl    a, meter_state                        ; 4731
        orl    a, fnsel_new_function                 ; 4733
        mov    meter_state, a                        ; 4735
        mov    r2, fnsel_new_function                ; 4737
        cjne   r2, #0x08, L_473E                     ; 4739
        sjmp   L_474A                                ; 473C
L_473E::
        jnb    0x3B, L_474A                          ; 473E
        jb     cal_mode, L_4748                      ; 4741
        clr    0x0A                                  ; 4744
        clr    0x0B                                  ; 4746
L_4748::
        clr    0x3B                                  ; 4748
L_474A::
        lcall  func_change_hook                      ; 474A
        mov    a, fnsel_new_function                 ; 474D
        jz     L_4755                                ; 474F
        clr    peak_mode_b1                          ; 4751
        clr    peak_mode_b0                          ; 4753
L_4755::
        clr    0x26                                  ; 4755
        mov    r2, fnsel_new_function                ; 4757
        cjne   r2, #0x04, L_475E                     ; 4759
        sjmp   L_4763                                ; 475C
L_475E::
        mov    r2, fnsel_new_function                ; 475E
        cjne   r2, #0x0B, L_4767                     ; 4760
L_4763::
        setb   0x2F                                  ; 4763
        sjmp   L_4769                                ; 4765
L_4767::
        clr    0x2F                                  ; 4767
L_4769::
        jnb    0x6A, L_476F                          ; 4769
        ljmp   L_47FF                                ; 476C
L_476F::
        mov    a, #0x04                              ; 476F
        anl    a, 0x3B                               ; 4771
        jz     L_477B                                ; 4773
        jb     cal_mode, L_477B                      ; 4775
        lcall  speed_store                           ; 4778
L_477B::
        jnb    0x69, L_47AD                          ; 477B
        mov    r2, 0x2E                              ; 477E
        cjne   r2, #0x14, L_4785                     ; 4780
        sjmp   L_4790                                ; 4783
L_4785::
        jnb    cal_mode, L_478D                      ; 4785
        lcall  speed_load                            ; 4788
        sjmp   L_4790                                ; 478B
L_478D::
        lcall  speed_store                           ; 478D
L_4790::
        mov    a, #0x47                              ; 4790
        anl    a, 0x2F                               ; 4792
        cjne   a, #0x04, L_479E                      ; 4794
        lcall  range_by_value                        ; 4797
        clr    meter_autorange                       ; 479A
        sjmp   L_47AD                                ; 479C
L_479E::
        mov    r2, 0x2E                              ; 479E
        cjne   r2, #0x14, L_47A5                     ; 47A0
        sjmp   L_47A8                                ; 47A3
L_47A5::
        lcall  meas_set_function_flags               ; 47A5
L_47A8::
        jb     cal_mode, L_47AD                      ; 47A8
        setb   meter_autorange                       ; 47AB
L_47AD::
        mov    a, #0x10                              ; 47AD
        anl    a, 0x3B                               ; 47AF
        jz     L_47B7                                ; 47B1
        clr    0x10                                  ; 47B3
        clr    0x11                                  ; 47B5
L_47B7::
        mov    a, #0x08                              ; 47B7
        anl    a, 0x3B                               ; 47B9
        jz     L_47C3                                ; 47BB
        lcall  min_reset                             ; 47BD
        lcall  max_reset                             ; 47C0
L_47C3::
        mov    a, #0x80                              ; 47C3
        anl    a, 0x3B                               ; 47C5
        jz     L_47CB                                ; 47C7
        clr    0x35                                  ; 47C9
L_47CB::
        jnb    0x6B, L_47E6                          ; 47CB
        mov    dptr, #0x00EB                         ; 47CE
        movx   a, @dptr                              ; 47D1
        anl    a, #0x10                              ; 47D2
        jz     L_47E6                                ; 47D4
        mov    dptr, #0x00EB                         ; 47D6
        movx   a, @dptr                              ; 47D9
        anl    a, #0x80                              ; 47DA
        jz     L_47E3                                ; 47DC
        lcall  menu_exit_a                           ; 47DE
        sjmp   L_47E6                                ; 47E1
L_47E3::
        lcall  menu_exit_b                           ; 47E3
L_47E6::
        mov    a, #0x01                              ; 47E6
        anl    a, 0x3B                               ; 47E8
        cjne   a, #0x01, L_47F6                      ; 47EA
        lcall  meas_restart_from_ui                  ; 47ED
        lcall  trigger_clear                         ; 47F0
        lcall  cal_status_or_dashes                  ; 47F3
L_47F6::
        mov    a, #0x40                              ; 47F6
        anl    a, 0x3B                               ; 47F8
        jz     L_47FF                                ; 47FA
        lcall  result_restart                        ; 47FC
L_47FF::
        lcall  kbd_cmd_finish                        ; 47FF
        jb     0x0A, L_480F                          ; 4802
        jb     0x0B, L_480F                          ; 4805
        mov    dptr, #x_result_flags                 ; 4808
        movx   a, @dptr                              ; 480B
        orl    a, #0x08                              ; 480C
        movx   @dptr, a                              ; 480E
L_480F::
        ret                                          ; 480F
L_4810::
        ret                                          ; 4810
L_4811::
        ret                                          ; 4811
L_4812::
        ret                                          ; 4812
L_4813::
        ret                                          ; 4813

; current function -> mnemonic index (for FNC?, RSL)
func_to_cmd_index::
        mov    a, #0x0F                              ; 4814
        anl    a, meter_state                        ; 4816
        jnz    L_4822                                ; 4818
        mov    a, meter_mode                         ; 481A
        rl     a                                     ; 481C
        rl     a                                     ; 481D
        anl    a, #0x03                              ; 481E
        dec    a                                     ; 4820
        ret                                          ; 4821
L_4822::
        mov    a, #0x0F                              ; 4822
        anl    a, meter_state                        ; 4824
        clr    c                                     ; 4826
        subb   a, #0x08                              ; 4827
        jnc    L_4832                                ; 4829
        mov    a, #0x0F                              ; 482B
        anl    a, meter_state                        ; 482D
        add    a, #0x02                              ; 482F
        ret                                          ; 4831
L_4832::
        mov    a, #0x0F                              ; 4832
        anl    a, meter_state                        ; 4834
        cjne   a, #0x08, L_4843                      ; 4836
        mov    a, meter_mode                         ; 4839
        swap   a                                     ; 483B
        anl    a, #0x0F                              ; 483C
        anl    a, #0x03                              ; 483E
        add    a, #0x0A                              ; 4840
        ret                                          ; 4842
L_4843::
        mov    a, #0x0F                              ; 4843
        anl    a, meter_state                        ; 4845
        add    a, #0x05                              ; 4847
        ret                                          ; 4849

reply_value_cmp_ten::
        mov    sfr_DPH, 0x29                         ; 484A
        mov    sfr_DPL, 0x2A                         ; 484D
        mov    r0, #0x57                             ; 4850
        lcall  fp_ld_xdata_r0                        ; 4852
        ljmp   fp_cmp_ten                            ; 4855
L_4858::
        clr    c                                     ; 4858
        ret                                          ; 4859

; format float (e.g. +1.250000E+00)
reply_put_float::
        mov    a, 0x0B                               ; 485A
        mov    dptr, #x_reply_buf                    ; 485C
        lcall  dptr_add_a_b                          ; 485F
        mov    r0, #0x3D                             ; 4862
        mov    r1, #0x39                             ; 4864
        mov    r6, 0x2F                              ; 4866
        mov    r7, 0x35                              ; 4868
        mov    a, 0x31                               ; 486A
        lcall  fp_format                             ; 486C
        ret                                          ; 486F

reply_decimal_pos::
        jnb    0x10, L_4875                          ; 4870
        clr    a                                     ; 4873
        ret                                          ; 4874
L_4875::
        mov    sfr_DPL, 0x2C                         ; 4875
        mov    sfr_DPH, 0x2B                         ; 4878
        inc    dptr                                  ; 487B
        movx   a, @dptr                              ; 487C
        push   0x2E                                  ; 487D
        mov    c, 0xE7                               ; 487F
        mov    0x73, c                               ; 4881
        anl    a, #0x70                              ; 4883
        swap   a                                     ; 4885
        lcall  lcd_decimal_point                     ; 4886
        pop    0x2E                                  ; 4889
        mov    a, r7                                 ; 488B
        ret                                          ; 488C
L_488D::
        clr    a                                     ; 488D
        ret                                          ; 488E
L_488F::
        mov    sfr_DPL, 0x2A                         ; 488F
        mov    sfr_DPH, 0x29                         ; 4892
        mov    r0, #0x3D                             ; 4895
        lcall  fp_ld_code_r0                         ; 4897
        ret                                          ; 489A

reply_ld_value::
        mov    sfr_DPL, 0x2A                         ; 489B
        mov    sfr_DPH, 0x29                         ; 489E
        mov    r0, #0x3D                             ; 48A1
        lcall  fp_ld_xdata_r0                        ; 48A3
        ret                                          ; 48A6

; (inferred) digit count / decimal position from tables 0x6F04/0x6F14
digits_for_range::
        mov    a, #0x0F                              ; 48A7
        anl    a, meter_state                        ; 48A9
        cjne   a, #0x07, L_48B0                      ; 48AB
        sjmp   L_48B7                                ; 48AE
L_48B0::
        mov    a, #0x0F                              ; 48B0
        anl    a, meter_state                        ; 48B2
        cjne   a, #0x06, L_48BF                      ; 48B4
L_48B7::
        jnb    0x2E, L_48BF                          ; 48B7
        mov    0x59, #0x0E                           ; 48BA
        sjmp   L_48C5                                ; 48BD
L_48BF::
        mov    a, #0x0F                              ; 48BF
        anl    a, meter_state                        ; 48C1
        mov    0x59, a                               ; 48C3
L_48C5::
        mov    a, 0x59                               ; 48C5
        mov    dptr, #T_6F14                         ; 48C7
        movc   a, @a+dptr                            ; 48CA
        mov    0x5A, a                               ; 48CB
        mov    a, #0x1F                              ; 48CD
        anl    a, 0x5A                               ; 48CF
        add    a, #0xF7                              ; 48D1
        mov    0x5B, a                               ; 48D3
        mov    a, meter_state                        ; 48D5
        swap   a                                     ; 48D7
        anl    a, #0x0F                              ; 48D8
        anl    a, #0x07                              ; 48DA
        add    a, 0x5B                               ; 48DC
        mov    0x5B, a                               ; 48DE
        mov    a, 0x59                               ; 48E0
        mov    dptr, #T_6F04                         ; 48E2
        movc   a, @a+dptr                            ; 48E5
        mov    0x59, a                               ; 48E6
        mov    0x58, #0x00                           ; 48E8
L_48EB::
        mov    a, 0x59                               ; 48EB
        rrc    a                                     ; 48ED
        jc     L_48FA                                ; 48EE
        inc    0x58                                  ; 48F0
        mov    a, 0x59                               ; 48F2
        clr    c                                     ; 48F4
        rrc    a                                     ; 48F5
        mov    0x59, a                               ; 48F6
        sjmp   L_48EB                                ; 48F8
L_48FA::
        mov    a, 0x5B                               ; 48FA
        clr    c                                     ; 48FC
        subb   a, 0x58                               ; 48FD
        mov    0x5B, a                               ; 48FF
        mov    a, meter_state                        ; 4901
        anl    a, #0x7F                              ; 4903
        orl    a, #0x6A                              ; 4905
        clr    sbit_F0                               ; 4907
        jnz    L_490F                                ; 4909
        setb   sbit_F0                               ; 490B
        dec    0x5B                                  ; 490D
L_490F::
        mov    a, 0x5B                               ; 490F
        mov    r1, #0x3D                             ; 4911
        lcall  fp_ld_pow10_r1                        ; 4913
        jb     sbit_F0, L_491E                       ; 4916
        mov    a, 0x5A                               ; 4919
        jnb    0xE5, L_4920                          ; 491B
L_491E::
        inc    0x3D                                  ; 491E
L_4920::
        ret                                          ; 4920

; load slot (vote over the 3 copies); 23h.7 if no majority -> 'E'
cdp_load_slot::
        setb   0x3C                                  ; 4921
        mov    sfr_DPL, 0x2A                         ; 4923
        mov    sfr_DPH, 0x29                         ; 4926
        mov    r0, #0x57                             ; 4929
        lcall  cal_ld_slot                           ; 492B
        mov    r1, #0x57                             ; 492E
        mov    r0, #0x3D                             ; 4930
        lcall  fp_copy_r1_to_r0                      ; 4932
        ret                                          ; 4935

; clear "new result" flag, restart if not triggered
reply_after_reading::
        jb     0x0A, L_4941                          ; 4936
        jb     0x0B, L_4941                          ; 4939
        lcall  iface_report_status                   ; 493C
        sjmp   L_4954                                ; 493F
L_4941::
        mov    dptr, #x_result_flags                 ; 4941
        movx   a, @dptr                              ; 4944
        anl    a, #0xF7                              ; 4945
        movx   @dptr, a                              ; 4947
        jnb    0x25, L_4951                          ; 4948
        mov    dptr, #0x005A                         ; 494B
        movx   a, @dptr                              ; 494E
        jz     L_4954                                ; 494F
L_4951::
        lcall  iface_report_status                   ; 4951
L_4954::
        ret                                          ; 4954

reply_put_value_field::
        lcall  reply_ld_value                        ; 4955
        mov    0x31, #0x48                           ; 4958
        mov    0x2F, #0x67                           ; 495B
        lcall  reply_put_float                       ; 495E
        mov    a, 0x0B                               ; 4961
        add    a, #0x0D                              ; 4963
        mov    0x0B, a                               ; 4965
        ret                                          ; 4967

; append 3-char mnemonic #(33h) from table 0x59B1 to reply buffer
reply_put_mnemonic::
        mov    sfr_B, #0x05                          ; 4968
        mov    a, 0x33                               ; 496B
        mov    dptr, #cmd_table                      ; 496D
        lcall  dptr_add_a_mul_b                      ; 4970
        clr    a                                     ; 4973
        movc   a, @a+dptr                            ; 4974
        mov    r2, a                                 ; 4975
        mov    a, 0x0B                               ; 4976
        mov    dptr, #x_reply_buf                    ; 4978
        lcall  dptr_add_a                            ; 497B
        mov    a, r2                                 ; 497E
        movx   @dptr, a                              ; 497F
        mov    sfr_B, #0x05                          ; 4980
        mov    a, 0x33                               ; 4983
        mov    dptr, #T_59B2                         ; 4985
        lcall  dptr_add_a_mul_b                      ; 4988
        clr    a                                     ; 498B
        movc   a, @a+dptr                            ; 498C
        mov    r2, a                                 ; 498D
        mov    a, 0x0B                               ; 498E
        mov    dptr, #0x0035                         ; 4990
        lcall  dptr_add_a                            ; 4993
        mov    a, r2                                 ; 4996
        movx   @dptr, a                              ; 4997
        mov    sfr_B, #0x05                          ; 4998
        mov    a, 0x33                               ; 499B
        mov    dptr, #T_59B3                         ; 499D
        lcall  dptr_add_a_mul_b                      ; 49A0
        clr    a                                     ; 49A3
        movc   a, @a+dptr                            ; 49A4
        mov    r2, a                                 ; 49A5
        mov    a, 0x0B                               ; 49A6
        mov    dptr, #0x0036                         ; 49A8
        lcall  dptr_add_a                            ; 49AB
        mov    a, r2                                 ; 49AE
        movx   @dptr, a                              ; 49AF
        mov    a, 0x0B                               ; 49B0
        add    a, #0x03                              ; 49B2
        mov    0x0B, a                               ; 49B4
        ret                                          ; 49B6

; append '#'-terminated code string at (2Dh:2Eh)
reply_put_string::
        mov    0x35, #0x00                           ; 49B7
L_49BA::
        mov    a, 0x35                               ; 49BA
        mov    sfr_DPL, 0x2E                         ; 49BC
        mov    sfr_DPH, 0x2D                         ; 49BF
        movc   a, @a+dptr                            ; 49C2
        cjne   a, #0x23, L_49C8                      ; 49C3
        sjmp   L_49E2                                ; 49C6
L_49C8::
        mov    a, 0x35                               ; 49C8
        mov    sfr_DPL, 0x2E                         ; 49CA
        mov    sfr_DPH, 0x2D                         ; 49CD
        movc   a, @a+dptr                            ; 49D0
        mov    r2, a                                 ; 49D1
        mov    a, 0x0B                               ; 49D2
        mov    dptr, #x_reply_buf                    ; 49D4
        lcall  dptr_add_a                            ; 49D7
        mov    a, r2                                 ; 49DA
        movx   @dptr, a                              ; 49DB
        inc    0x0B                                  ; 49DC
        inc    0x35                                  ; 49DE
        sjmp   L_49BA                                ; 49E0
L_49E2::
        ret                                          ; 49E2

reply_send::
        mov    sfr_DPL, 0x1E                         ; 49E3
        mov    sfr_DPH, 0x1D                         ; 49E6
        inc    dptr                                  ; 49E9
        inc    dptr                                  ; 49EA
        movx   a, @dptr                              ; 49EB
        anl    a, #0x40                              ; 49EC
        jnz    L_49F6                                ; 49EE
        mov    0x0B, #0x80                           ; 49F0
        ljmp   L_4A05                                ; 49F3
L_49F6::
        mov    a, #0x80                              ; 49F6
        orl    a, 0x0B                               ; 49F8
        mov    0x0B, a                               ; 49FA
        mov    sfr_DPH, 0x1D                         ; 49FC
        mov    sfr_DPL, 0x1E                         ; 49FF
        lcall  iface_send                            ; 4A02
L_4A05::
        ret                                          ; 4A05

; (+CR if CR ON) mark end of message, send
reply_send_last::
        jnb    cr_enabled, L_4A16                    ; 4A06
        mov    a, 0x0B                               ; 4A09
        mov    dptr, #x_reply_buf                    ; 4A0B
        lcall  dptr_add_a                            ; 4A0E
        mov    a, #0x0D                              ; 4A11
        movx   @dptr, a                              ; 4A13
        inc    0x0B                                  ; 4A14
L_4A16::
        mov    a, #0x40                              ; 4A16
        orl    a, 0x0B                               ; 4A18
        mov    0x0B, a                               ; 4A1A
        lcall  reply_send                            ; 4A1C
        ret                                          ; 4A1F

reply_put_2digits::
        mov    sfr_B, #0x0A                          ; 4A20
        mov    a, 0x30                               ; 4A23
        div    ab                                    ; 4A25
        orl    a, #0x30                              ; 4A26
        mov    r2, a                                 ; 4A28
        mov    a, 0x0B                               ; 4A29
        mov    dptr, #x_reply_buf                    ; 4A2B
        lcall  dptr_add_a                            ; 4A2E
        mov    a, r2                                 ; 4A31
        movx   @dptr, a                              ; 4A32
        mov    sfr_B, #0x0A                          ; 4A33
        mov    a, 0x30                               ; 4A36
        div    ab                                    ; 4A38
        mov    a, sfr_B                              ; 4A39
        orl    a, #0x30                              ; 4A3B
        mov    r2, a                                 ; 4A3D
        mov    a, 0x0B                               ; 4A3E
        mov    dptr, #0x0035                         ; 4A40
        lcall  dptr_add_a                            ; 4A43
        mov    a, r2                                 ; 4A46
        movx   @dptr, a                              ; 4A47
        mov    a, 0x0B                               ; 4A48
        add    a, #0x02                              ; 4A4A
        mov    0x0B, a                               ; 4A4C
        ret                                          ; 4A4E

; 3-digit decimal + ','
reply_put_3digits::
        mov    sfr_B, #0x64                          ; 4A4F
        mov    a, 0x30                               ; 4A52
        div    ab                                    ; 4A54
        orl    a, #0x30                              ; 4A55
        mov    r2, a                                 ; 4A57
        mov    a, 0x0B                               ; 4A58
        mov    dptr, #x_reply_buf                    ; 4A5A
        lcall  dptr_add_a                            ; 4A5D
        mov    a, r2                                 ; 4A60
        movx   @dptr, a                              ; 4A61
        mov    sfr_B, #0x64                          ; 4A62
        mov    a, 0x30                               ; 4A65
        div    ab                                    ; 4A67
        mov    0x30, sfr_B                           ; 4A68
        inc    0x0B                                  ; 4A6B
        lcall  reply_put_2digits                     ; 4A6D
        mov    a, 0x0B                               ; 4A70
        mov    dptr, #x_reply_buf                    ; 4A72
        lcall  dptr_add_a                            ; 4A75
        mov    a, #0x2C                              ; 4A78
        movx   @dptr, a                              ; 4A7A
        inc    0x0B                                  ; 4A7B
        ret                                          ; 4A7D

reply_nc_check::
        lcall  value_is_signed                       ; 4A7E
        cpl    c                                     ; 4A81
        ret                                          ; 4A82
L_4A83::
        ret                                          ; 4A83

reply_put_reading_value::
        mov    r2, 0x33                              ; 4A84
        cjne   r2, #0x12, L_4A8B                     ; 4A86
        sjmp   L_4A8E                                ; 4A89
L_4A8B::
        ljmp   L_4AA5                                ; 4A8B
L_4A8E::
        lcall  reply_value_cmp_ten                   ; 4A8E
        jnc    L_4A9B                                ; 4A91
        mov    0x2D, #0x6E                           ; 4A93
        mov    0x2E, #0x7F                           ; 4A96
        sjmp   L_4AA1                                ; 4A99
L_4A9B::
        mov    0x2D, #0x6E                           ; 4A9B
        mov    0x2E, #0x87                           ; 4A9E
L_4AA1::
        lcall  reply_put_string                      ; 4AA1
        ret                                          ; 4AA4
L_4AA5::
        mov    sfr_DPL, 0x2C                         ; 4AA5
        mov    sfr_DPH, 0x2B                         ; 4AA8
        inc    dptr                                  ; 4AAB
        movx   a, @dptr                              ; 4AAC
        swap   a                                     ; 4AAD
        anl    a, #0x0F                              ; 4AAE
        anl    a, #0x07                              ; 4AB0
        mov    0x34, a                               ; 4AB2
        mov    a, #0x03                              ; 4AB4
        anl    a, meter_mode                         ; 4AB6
        mov    sfr_B, #0x03                          ; 4AB8
        mov    r2, a                                 ; 4ABB
        mov    a, 0x33                               ; 4ABC
        mul    ab                                    ; 4ABE
        mov    r4, sfr_B                             ; 4ABF
        mov    r5, a                                 ; 4AC1
        mov    a, r5                                 ; 4AC2
        add    a, #0x40                              ; 4AC3
        mov    sfr_DPL, a                            ; 4AC5
        mov    a, r4                                 ; 4AC7
        addc   a, #0x6E                              ; 4AC8
        mov    sfr_DPH, a                            ; 4ACA
        mov    a, r2                                 ; 4ACC
        movc   a, @a+dptr                            ; 4ACD
        mov    0x32, a                               ; 4ACE
        mov    r2, 0x33                              ; 4AD0
        cjne   r2, #0x07, L_4ADC                     ; 4AD2
        mov    r2, 0x34                              ; 4AD5
        cjne   r2, #0x06, L_4ADC                     ; 4AD7
        sjmp   L_4AE6                                ; 4ADA
L_4ADC::
        mov    r2, 0x33                              ; 4ADC
        cjne   r2, #0x0E, L_4AE8                     ; 4ADE
        mov    r2, 0x34                              ; 4AE1
        cjne   r2, #0x07, L_4AE8                     ; 4AE3
L_4AE6::
        dec    0x32                                  ; 4AE6
L_4AE8::
        jnb    0x11, L_4AF1                          ; 4AE8
        mov    0x32, #0x07                           ; 4AEB
        mov    0x31, #0x48                           ; 4AEE
L_4AF1::
        jnb    0x10, L_4AFD                          ; 4AF1
        mov    0x32, #0x04                           ; 4AF4
        mov    0x31, #0xF1                           ; 4AF7
        mov    0x35, #0x00                           ; 4AFA
L_4AFD::
        mov    a, 0x32                               ; 4AFD
        jnz    L_4B03                                ; 4AFF
        sjmp   L_4AFD                                ; 4B01
L_4B03::
        mov    a, 0x34                               ; 4B03
        mov    r2, a                                 ; 4B05
        mov    a, #0x0F                              ; 4B06
        anl    a, meter_state                        ; 4B08
        mov    r7, a                                 ; 4B0A
        mov    r6, #0x00                             ; 4B0B
        mov    a, #0x03                              ; 4B0D
        lcall  shl16_r6r7                            ; 4B0F
        mov    a, r7                                 ; 4B12
        add    a, #0xC0                              ; 4B13
        mov    sfr_DPL, a                            ; 4B15
        mov    a, r6                                 ; 4B17
        addc   a, #0x6D                              ; 4B18
        mov    sfr_DPH, a                            ; 4B1A
        mov    a, r2                                 ; 4B1C
        movc   a, @a+dptr                            ; 4B1D
        mov    0x34, a                               ; 4B1E
        mov    sfr_DPL, 0x2C                         ; 4B20
        mov    sfr_DPH, 0x2B                         ; 4B23
        inc    dptr                                  ; 4B26
        movx   a, @dptr                              ; 4B27
        anl    a, #0x80                              ; 4B28
        jz     L_4B3A                                ; 4B2A
        mov    r2, 0x33                              ; 4B2C
        cjne   r2, #0x08, L_4B33                     ; 4B2E
        sjmp   L_4B38                                ; 4B31
L_4B33::
        mov    r2, 0x33                              ; 4B33
        cjne   r2, #0x09, L_4B3A                     ; 4B35
L_4B38::
        dec    0x34                                  ; 4B38
L_4B3A::
        mov    sfr_DPL, 0x2C                         ; 4B3A
        mov    sfr_DPH, 0x2B                         ; 4B3D
        movx   a, @dptr                              ; 4B40
        anl    a, #0x26                              ; 4B41
        mov    sfr_DPL, 0x2C                         ; 4B43
        mov    sfr_DPH, 0x2B                         ; 4B46
        inc    dptr                                  ; 4B49
        mov    r2, a                                 ; 4B4A
        movx   a, @dptr                              ; 4B4B
        anl    a, #0x08                              ; 4B4C
        orl    a, r2                                 ; 4B4E
        jnz    L_4B70                                ; 4B4F
        mov    sfr_DPL, 0x2C                         ; 4B51
        mov    sfr_DPH, 0x2B                         ; 4B54
        inc    dptr                                  ; 4B57
        movx   a, @dptr                              ; 4B58
        anl    a, #0x80                              ; 4B59
        jnz    L_4B60                                ; 4B5B
        ljmp   L_4C13                                ; 4B5D
L_4B60::
        mov    r2, 0x33                              ; 4B60
        cjne   r2, #0x08, L_4B68                     ; 4B62
        ljmp   L_4C13                                ; 4B65
L_4B68::
        mov    r2, 0x33                              ; 4B68
        cjne   r2, #0x09, L_4B70                     ; 4B6A
        ljmp   L_4C13                                ; 4B6D
L_4B70::
        mov    r2, 0x0B                              ; 4B70
        inc    r2                                    ; 4B72
        mov    0x2F, r2                              ; 4B73
        mov    0x2D, #0x6E                           ; 4B75
        mov    0x2E, #0x8F                           ; 4B78
        lcall  reply_put_string                      ; 4B7B
        jnb    0x11, L_4B89                          ; 4B7E
        jb     0x10, L_4B89                          ; 4B81
        mov    0x35, #0x00                           ; 4B84
        sjmp   L_4BAD                                ; 4B87
L_4B89::
        mov    0x35, #0x00                           ; 4B89
L_4B8C::
        mov    a, #0x06                              ; 4B8C
        clr    c                                     ; 4B8E
        subb   a, 0x32                               ; 4B8F
        mov    r2, a                                 ; 4B91
        mov    a, 0x35                               ; 4B92
        setb   c                                     ; 4B94
        subb   a, r2                                 ; 4B95
        jnc    L_4BAD                                ; 4B96
        mov    a, 0x2F                               ; 4B98
        add    a, 0x35                               ; 4B9A
        mov    dptr, #x_reply_buf                    ; 4B9C
        lcall  dptr_add_a                            ; 4B9F
        mov    a, #0x20                              ; 4BA2
        movx   @dptr, a                              ; 4BA4
        mov    a, 0x35                               ; 4BA5
        add    a, #0x01                              ; 4BA7
        mov    0x35, a                               ; 4BA9
        jnc    L_4B8C                                ; 4BAB
L_4BAD::
        mov    a, 0x35                               ; 4BAD
        add    a, 0x2F                               ; 4BAF
        dec    a                                     ; 4BB1
        mov    0x2F, a                               ; 4BB2
        mov    sfr_DPL, 0x2C                         ; 4BB4
        mov    sfr_DPH, 0x2B                         ; 4BB7
        inc    dptr                                  ; 4BBA
        movx   a, @dptr                              ; 4BBB
        anl    a, #0x08                              ; 4BBC
        jz     L_4BCD                                ; 4BBE
        mov    a, 0x2F                               ; 4BC0
        mov    dptr, #x_reply_buf                    ; 4BC2
        lcall  dptr_add_a                            ; 4BC5
        mov    a, #0x2B                              ; 4BC8
        movx   @dptr, a                              ; 4BCA
        sjmp   L_4BF0                                ; 4BCB
L_4BCD::
        mov    sfr_DPL, 0x2A                         ; 4BCD
        mov    sfr_DPH, 0x29                         ; 4BD0
        movx   a, @dptr                              ; 4BD3
        anl    a, #0x80                              ; 4BD4
        jz     L_4BE5                                ; 4BD6
        mov    a, 0x2F                               ; 4BD8
        mov    dptr, #x_reply_buf                    ; 4BDA
        lcall  dptr_add_a                            ; 4BDD
        mov    a, #0x2D                              ; 4BE0
        movx   @dptr, a                              ; 4BE2
        sjmp   L_4BF0                                ; 4BE3
L_4BE5::
        mov    a, 0x2F                               ; 4BE5
        mov    dptr, #x_reply_buf                    ; 4BE7
        lcall  dptr_add_a                            ; 4BEA
        mov    a, #0x2B                              ; 4BED
        movx   @dptr, a                              ; 4BEF
L_4BF0::
        lcall  reply_nc_check                        ; 4BF0
        jnc    L_4C00                                ; 4BF3
        mov    a, 0x2F                               ; 4BF5
        mov    dptr, #x_reply_buf                    ; 4BF7
        lcall  dptr_add_a                            ; 4BFA
        mov    a, #0x20                              ; 4BFD
        movx   @dptr, a                              ; 4BFF
L_4C00::
        mov    a, 0x2F                               ; 4C00
        add    a, #0x04                              ; 4C02
        mov    0x35, a                               ; 4C04
        mov    a, 0x35                               ; 4C06
        mov    dptr, #x_reply_buf                    ; 4C08
        lcall  dptr_add_a                            ; 4C0B
        mov    a, #0x2E                              ; 4C0E
        movx   @dptr, a                              ; 4C10
        sjmp   L_4C57                                ; 4C11
L_4C13::
        lcall  reply_ld_value                        ; 4C13
        jb     0x10, L_4C48                          ; 4C16
        jb     0x11, L_4C48                          ; 4C19
        lcall  reply_decimal_pos                     ; 4C1C
        mov    0x35, a                               ; 4C1F
        mov    sfr_DPL, 0x2C                         ; 4C21
        mov    sfr_DPH, 0x2B                         ; 4C24
        movx   a, @dptr                              ; 4C27
        anl    a, #0x08                              ; 4C28
        jz     L_4C2E                                ; 4C2A
        dec    0x32                                  ; 4C2C
L_4C2E::
        mov    a, 0x32                               ; 4C2E
        clr    c                                     ; 4C30
        subb   a, 0x34                               ; 4C31
        orl    a, #0xF0                              ; 4C33
        mov    0x31, a                               ; 4C35
        lcall  reply_nc_check                        ; 4C37
        jnc    L_4C48                                ; 4C3A
        mov    a, #0x7F                              ; 4C3C
        anl    a, 0x3D                               ; 4C3E
        mov    0x3D, a                               ; 4C40
        mov    a, #0xBF                              ; 4C42
        anl    a, 0x31                               ; 4C44
        mov    0x31, a                               ; 4C46
L_4C48::
        mov    a, 0x32                               ; 4C48
        orl    a, #0x60                              ; 4C4A
        mov    0x2F, a                               ; 4C4C
        lcall  reply_put_float                       ; 4C4E
        mov    a, 0x0B                               ; 4C51
        add    a, #0x0D                              ; 4C53
        mov    0x0B, a                               ; 4C55
L_4C57::
        ret                                          ; 4C57

reply_put_reading_header::
        lcall  reply_put_mnemonic                    ; 4C58
        jnb    0x10, L_4C6B                          ; 4C5B
        mov    a, 0x0B                               ; 4C5E
        mov    dptr, #x_reply_buf                    ; 4C60
        lcall  dptr_add_a                            ; 4C63
        mov    a, #0x44                              ; 4C66
        movx   @dptr, a                              ; 4C68
        sjmp   L_4C76                                ; 4C69
L_4C6B::
        mov    a, 0x0B                               ; 4C6B
        mov    dptr, #x_reply_buf                    ; 4C6D
        lcall  dptr_add_a                            ; 4C70
        mov    a, #0x20                              ; 4C73
        movx   @dptr, a                              ; 4C75
L_4C76::
        jnb    cal_mode, L_4C86                      ; 4C76
        mov    a, 0x0B                               ; 4C79
        mov    dptr, #0x0035                         ; 4C7B
        lcall  dptr_add_a                            ; 4C7E
        mov    a, #0x43                              ; 4C81
        movx   @dptr, a                              ; 4C83
        sjmp   L_4CA1                                ; 4C84
L_4C86::
        jnb    0x11, L_4C96                          ; 4C86
        mov    a, 0x0B                               ; 4C89
        mov    dptr, #0x0035                         ; 4C8B
        lcall  dptr_add_a                            ; 4C8E
        mov    a, #0x5A                              ; 4C91
        movx   @dptr, a                              ; 4C93
        sjmp   L_4CA1                                ; 4C94
L_4C96::
        mov    a, 0x0B                               ; 4C96
        mov    dptr, #0x0035                         ; 4C98
        lcall  dptr_add_a                            ; 4C9B
        mov    a, #0x20                              ; 4C9E
        movx   @dptr, a                              ; 4CA0
L_4CA1::
        mov    sfr_DPL, 0x2C                         ; 4CA1
        mov    sfr_DPH, 0x2B                         ; 4CA4
        inc    dptr                                  ; 4CA7
        movx   a, @dptr                              ; 4CA8
        anl    a, #0x08                              ; 4CA9
        jz     L_4CB2                                ; 4CAB
        mov    0x2F, #0x3F                           ; 4CAD
        sjmp   L_4D00                                ; 4CB0
L_4CB2::
        mov    sfr_DPL, 0x2C                         ; 4CB2
        mov    sfr_DPH, 0x2B                         ; 4CB5
        movx   a, @dptr                              ; 4CB8
        mov    0x31, a                               ; 4CB9
        mov    a, #0x02                              ; 4CBB
        anl    a, 0x31                               ; 4CBD
        jz     L_4CC6                                ; 4CBF
        mov    0x2F, #0x4F                           ; 4CC1
        sjmp   L_4D00                                ; 4CC4
L_4CC6::
        mov    a, #0x04                              ; 4CC6
        anl    a, 0x31                               ; 4CC8
        jz     L_4CD1                                ; 4CCA
        mov    0x2F, #0x46                           ; 4CCC
        sjmp   L_4D00                                ; 4CCF
L_4CD1::
        mov    a, #0x10                              ; 4CD1
        anl    a, 0x31                               ; 4CD3
        jz     L_4CDC                                ; 4CD5
        mov    0x2F, #0x4E                           ; 4CD7
        sjmp   L_4D00                                ; 4CDA
L_4CDC::
        mov    a, #0x20                              ; 4CDC
        anl    a, 0x31                               ; 4CDE
        jz     L_4CE7                                ; 4CE0
        mov    0x2F, #0x55                           ; 4CE2
        sjmp   L_4D00                                ; 4CE5
L_4CE7::
        mov    a, #0x08                              ; 4CE7
        anl    a, 0x31                               ; 4CE9
        jz     L_4CF2                                ; 4CEB
        mov    0x2F, #0x52                           ; 4CED
        sjmp   L_4D00                                ; 4CF0
L_4CF2::
        mov    a, #0x01                              ; 4CF2
        anl    a, 0x31                               ; 4CF4
        jz     L_4CFD                                ; 4CF6
        mov    0x2F, #0x43                           ; 4CF8
        sjmp   L_4D00                                ; 4CFB
L_4CFD::
        mov    0x2F, #0x20                           ; 4CFD
L_4D00::
        mov    a, 0x0B                               ; 4D00
        mov    dptr, #0x0036                         ; 4D02
        lcall  dptr_add_a                            ; 4D05
        mov    a, 0x2F                               ; 4D08
        movx   @dptr, a                              ; 4D0A
        mov    a, 0x0B                               ; 4D0B
        add    a, #0x03                              ; 4D0D
        mov    0x0B, a                               ; 4D0F
        ret                                          ; 4D11

reply_abort::
        mov    0x0B, #0x00                           ; 4D12
        mov    dptr, #x_reply_items_left             ; 4D15
        clr    a                                     ; 4D18
        movx   @dptr, a                              ; 4D19
        ret                                          ; 4D1A

reply_init::
        mov    0x0B, #0x00                           ; 4D1B
        mov    dptr, #x_reply_pending_cmd            ; 4D1E
        clr    a                                     ; 4D21
        movx   @dptr, a                              ; 4D22
        mov    dptr, #x_reply_items_left             ; 4D23
        movx   @dptr, a                              ; 4D26
        lcall  jcv_get_ptr                           ; 4D27
        ret                                          ; 4D2A

; 1228 B: builds interface replies (command table at 0x59B1)
task_remote_reply::
        mov    a, 0x1D                               ; 4D2B
        orl    a, 0x1E                               ; 4D2D
        jnz    L_4D3B                                ; 4D2F
        mov    dptr, #x_reply_items_left             ; 4D31
        clr    a                                     ; 4D34
        movx   @dptr, a                              ; 4D35
        mov    dptr, #x_reply_pending_cmd            ; 4D36
        movx   @dptr, a                              ; 4D39
        ret                                          ; 4D3A
L_4D3B::
        mov    a, #0x80                              ; 4D3B
        anl    a, 0x0B                               ; 4D3D
        jz     L_4D52                                ; 4D3F
        mov    sfr_DPL, 0x1E                         ; 4D41
        mov    sfr_DPH, 0x1D                         ; 4D44
        inc    dptr                                  ; 4D47
        inc    dptr                                  ; 4D48
        movx   a, @dptr                              ; 4D49
        anl    a, #0x10                              ; 4D4A
        jnz    L_4D51                                ; 4D4C
        lcall  reply_send                            ; 4D4E
L_4D51::
        ret                                          ; 4D51
L_4D52::
        mov    sfr_DPL, 0x1E                         ; 4D52
        mov    sfr_DPH, 0x1D                         ; 4D55
        inc    dptr                                  ; 4D58
        inc    dptr                                  ; 4D59
        movx   a, @dptr                              ; 4D5A
        anl    a, #0x40                              ; 4D5B
        jnz    L_4D60                                ; 4D5D
        ret                                          ; 4D5F
L_4D60::
        mov    dptr, #0x00E0                         ; 4D60
        movx   a, @dptr                              ; 4D63
        orl    a, rx_count                           ; 4D64
        anl    a, #0x80                              ; 4D66
        jz     L_4D6B                                ; 4D68
        ret                                          ; 4D6A
L_4D6B::
        mov    0x0B, #0x00                           ; 4D6B
        mov    dptr, #0x005A                         ; 4D6E
        movx   a, @dptr                              ; 4D71
        cjne   a, #0x05, L_4D77                      ; 4D72
        sjmp   L_4D7A                                ; 4D75
L_4D77::
        ljmp   L_4D9D                                ; 4D77
L_4D7A::
        jb     0x19, L_4D80                          ; 4D7A
        ljmp   L_4D9C                                ; 4D7D
L_4D80::
        mov    r0, #0x09                             ; 4D80
        mov    r1, #0x00                             ; 4D82
        mov    r2, #0x34                             ; 4D84
        mov    r3, #0x00                             ; 4D86
        mov    dptr, #0x005B                         ; 4D88
        clr    c                                     ; 4D8B
        lcall  xdata_block_xfer                      ; 4D8C
        mov    0x0B, #0x09                           ; 4D8F
        clr    0x19                                  ; 4D92
        lcall  reply_send_last                       ; 4D94
        mov    dptr, #x_reply_items_left             ; 4D97
        clr    a                                     ; 4D9A
        movx   @dptr, a                              ; 4D9B
L_4D9C::
        ret                                          ; 4D9C
L_4D9D::
        mov    dptr, #x_reply_pending_cmd            ; 4D9D
        movx   a, @dptr                              ; 4DA0
        jz     L_4DA6                                ; 4DA1
        ljmp   L_4E06                                ; 4DA3
L_4DA6::
        mov    dptr, #0x00EB                         ; 4DA6
        movx   a, @dptr                              ; 4DA9
        rrc    a                                     ; 4DAA
        jnc    L_4DAE                                ; 4DAB
        ret                                          ; 4DAD
L_4DAE::
        jb     0x20, L_4DB4                          ; 4DAE
        ljmp   L_4E05                                ; 4DB1
L_4DB4::
        mov    dptr, #0x005A                         ; 4DB4
        movx   a, @dptr                              ; 4DB7
        cjne   a, #0x03, L_4DBD                      ; 4DB8
        sjmp   L_4DC0                                ; 4DBB
L_4DBD::
        ljmp   L_4DDD                                ; 4DBD
L_4DC0::
        jnb    emo_continuous, L_4DC6                ; 4DC0
        ljmp   L_4DDD                                ; 4DC3
L_4DC6::
        mov    dptr, #x_emo_count                    ; 4DC6
        mov    r0, #0x3A                             ; 4DC9
        lcall  i24_ld_xdata_r0                       ; 4DCB
        lcall  i24_test_r0                           ; 4DCE
        jnz    L_4DD4                                ; 4DD1
        ret                                          ; 4DD3
L_4DD4::
        lcall  i24_dec_r0                            ; 4DD4
        mov    dptr, #x_emo_count                    ; 4DD7
        lcall  i24_st_r0_xdata                       ; 4DDA
L_4DDD::
        mov    0x29, #0x00                           ; 4DDD
        mov    0x2A, #0x85                           ; 4DE0
        mov    0x2B, #0x00                           ; 4DE3
        mov    0x2C, #0x64                           ; 4DE6
        lcall  func_to_cmd_index                     ; 4DE9
        mov    0x33, a                               ; 4DEC
        jb     0x17, L_4DF4                          ; 4DEE
        lcall  reply_put_reading_header              ; 4DF1
L_4DF4::
        lcall  reply_put_reading_value               ; 4DF4
        lcall  reply_after_reading                   ; 4DF7
        mov    dptr, #x_reply_items_left             ; 4DFA
        clr    a                                     ; 4DFD
        movx   @dptr, a                              ; 4DFE
        lcall  reply_send_last                       ; 4DFF
        ret                                          ; 4E02
L_4E03::
        sjmp   L_4E06                                ; 4E03
L_4E05::
        ret                                          ; 4E05
L_4E06::
        mov    dptr, #x_reply_pending_cmd            ; 4E06
        movx   a, @dptr                              ; 4E09
        cjne   a, #0x21, L_4E22                      ; 4E0A
        mov    dptr, #x_reply_items_left             ; 4E0D
        movx   a, @dptr                              ; 4E10
        jnz    L_4E22                                ; 4E11
        mov    dptr, #x_reply_items_left             ; 4E13
        mov    a, #0x0B                              ; 4E16
        movx   @dptr, a                              ; 4E18
        mov    dptr, #reply_strings                  ; 4E19
        clr    a                                     ; 4E1C
        movc   a, @a+dptr                            ; 4E1D
        mov    0x34, a                               ; 4E1E
        sjmp   L_4E5C                                ; 4E20
L_4E22::
        mov    dptr, #x_reply_pending_cmd            ; 4E22
        movx   a, @dptr                              ; 4E25
        cjne   a, #0x21, L_4E2B                      ; 4E26
        sjmp   L_4E4E                                ; 4E29
L_4E2B::
        mov    dptr, #x_reply_pending_cmd            ; 4E2B
        movx   a, @dptr                              ; 4E2E
        mov    0x34, a                               ; 4E2F
        movx   a, @dptr                              ; 4E31
        cjne   a, #0x22, L_4E46                      ; 4E32
        mov    dptr, #x_reply_items_left             ; 4E35
        movx   a, @dptr                              ; 4E38
        jnz    L_4E44                                ; 4E39
        mov    dptr, #T_6FB9                         ; 4E3B
        clr    a                                     ; 4E3E
        movc   a, @a+dptr                            ; 4E3F
        mov    dptr, #x_reply_items_left             ; 4E40
        movx   @dptr, a                              ; 4E43
L_4E44::
        sjmp   L_4E4C                                ; 4E44
L_4E46::
        mov    dptr, #x_reply_items_left             ; 4E46
        mov    a, #0x01                              ; 4E49
        movx   @dptr, a                              ; 4E4B
L_4E4C::
        sjmp   L_4E5C                                ; 4E4C
L_4E4E::
        mov    dptr, #x_reply_items_left             ; 4E4E
        movx   a, @dptr                              ; 4E51
        cpl    a                                     ; 4E52
        inc    a                                     ; 4E53
        add    a, #0x0B                              ; 4E54
        mov    dptr, #reply_strings                  ; 4E56
        movc   a, @a+dptr                            ; 4E59
        mov    0x34, a                               ; 4E5A
L_4E5C::
        mov    0x2F, #0x00                           ; 4E5C
L_4E5F::
        mov    a, 0x2F                               ; 4E5F
        setb   c                                     ; 4E61
        subb   a, #0x02                              ; 4E62
        jnc    L_4E93                                ; 4E64
        mov    r7, 0x2F                              ; 4E66
        mov    r6, #0x00                             ; 4E68
        mov    sfr_B, #0x05                          ; 4E6A
        mov    a, 0x34                               ; 4E6D
        mul    ab                                    ; 4E6F
        mov    r5, a                                 ; 4E70
        mov    r4, sfr_B                             ; 4E71
        lcall  add16_r6r7_r4r5                       ; 4E73
        mov    dptr, #cmd_table                      ; 4E76
        lcall  dptr_add_r6r7                         ; 4E79
        clr    a                                     ; 4E7C
        movc   a, @a+dptr                            ; 4E7D
        mov    r2, a                                 ; 4E7E
        mov    a, 0x0B                               ; 4E7F
        add    a, 0x2F                               ; 4E81
        mov    dptr, #x_reply_buf                    ; 4E83
        lcall  dptr_add_a                            ; 4E86
        mov    a, r2                                 ; 4E89
        movx   @dptr, a                              ; 4E8A
        mov    a, 0x2F                               ; 4E8B
        add    a, #0x01                              ; 4E8D
        mov    0x2F, a                               ; 4E8F
        jnc    L_4E5F                                ; 4E91
L_4E93::
        mov    a, 0x0B                               ; 4E93
        mov    dptr, #0x0037                         ; 4E95
        lcall  dptr_add_a                            ; 4E98
        mov    a, #0x20                              ; 4E9B
        movx   @dptr, a                              ; 4E9D
        mov    a, 0x0B                               ; 4E9E
        add    a, #0x04                              ; 4EA0
        mov    0x0B, a                               ; 4EA2
        mov    a, 0x34                               ; 4EA4
        clr    c                                     ; 4EA6
        subb   a, #0x13                              ; 4EA7
        clr    c                                     ; 4EA9
        mov    sfr_B, a                              ; 4EAA
        rlc    a                                     ; 4EAC
        add    a, sfr_B                              ; 4EAD
        mov    dptr, #L_5189                         ; 4EAF
        jmp    @a+dptr                               ; 4EB2
L_4EB3::
        lcall  func_to_cmd_index                     ; 4EB3
        mov    0x33, a                               ; 4EB6
        lcall  reply_put_mnemonic                    ; 4EB8
        ljmp   L_51C8                                ; 4EBB
L_4EBE::
        jb     meter_autorange, L_4EC4               ; 4EBE
        ljmp   L_4ED0                                ; 4EC1
L_4EC4::
        mov    0x2D, #0x6E                           ; 4EC4
        mov    0x2E, #0x9D                           ; 4EC7
        lcall  reply_put_string                      ; 4ECA
        ljmp   L_4F0B                                ; 4ECD
L_4ED0::
        mov    r2, meter_state                       ; 4ED0
        cjne   r2, #0x6A, L_4ED7                     ; 4ED2
        sjmp   L_4EDA                                ; 4ED5
L_4ED7::
        ljmp   L_4EE5                                ; 4ED7
L_4EDA::
        mov    0x2D, #0x6E                           ; 4EDA
        mov    0x2E, #0xA6                           ; 4EDD
        lcall  reply_put_string                      ; 4EE0
        sjmp   L_4F0B                                ; 4EE3
L_4EE5::
        lcall  digits_for_range                      ; 4EE5
        dec    0x0B                                  ; 4EE8
        mov    0x31, #0x30                           ; 4EEA
        mov    0x2F, #0x23                           ; 4EED
        mov    sfr_B, #0x03                          ; 4EF0
        mov    r2, sfr_B                             ; 4EF3
        mov    a, 0x5B                               ; 4EF5
        add    a, #0x09                              ; 4EF7
        div    ab                                    ; 4EF9
        mov    sfr_B, r2                             ; 4EFA
        mul    ab                                    ; 4EFC
        clr    c                                     ; 4EFD
        subb   a, #0x09                              ; 4EFE
        mov    0x35, a                               ; 4F00
        lcall  reply_put_float                       ; 4F02
        mov    a, 0x0B                               ; 4F05
        add    a, #0x09                              ; 4F07
        mov    0x0B, a                               ; 4F09
L_4F0B::
        ljmp   L_51C8                                ; 4F0B
L_4F0E::
        jnb    0x10, L_4F19                          ; 4F0E
        mov    0x2D, #0x6D                           ; 4F11
        mov    0x2E, #0xBB                           ; 4F14
        sjmp   L_4F1F                                ; 4F17
L_4F19::
        mov    0x2D, #0x6D                           ; 4F19
        mov    0x2E, #0xB6                           ; 4F1C
L_4F1F::
        lcall  reply_put_string                      ; 4F1F
        mov    0x29, #0x00                           ; 4F22
        mov    0x2A, #0x75                           ; 4F25
        lcall  reply_put_value_field                 ; 4F28
        ljmp   L_51C8                                ; 4F2B
L_4F2E::
        jnb    0x11, L_4F39                          ; 4F2E
        mov    0x2D, #0x6D                           ; 4F31
        mov    0x2E, #0xBB                           ; 4F34
        sjmp   L_4F3F                                ; 4F37
L_4F39::
        mov    0x2D, #0x6D                           ; 4F39
        mov    0x2E, #0xB6                           ; 4F3C
L_4F3F::
        lcall  reply_put_string                      ; 4F3F
        mov    0x29, #0x00                           ; 4F42
        mov    0x2A, #0x79                           ; 4F45
        lcall  reply_put_value_field                 ; 4F48
        ljmp   L_51C8                                ; 4F4B
L_4F4E::
        mov    0x2D, #0x6E                           ; 4F4E
        mov    0x2E, #0xAF                           ; 4F51
        lcall  reply_put_string                      ; 4F54
        mov    0x29, #0x00                           ; 4F57
        mov    0x2A, #0x7D                           ; 4F5A
        mov    0x2B, #0x00                           ; 4F5D
        mov    0x2C, #0x69                           ; 4F60
        lcall  func_to_cmd_index                     ; 4F63
        mov    0x33, a                               ; 4F66
        jb     0x17, L_4F6E                          ; 4F68
        lcall  reply_put_reading_header              ; 4F6B
L_4F6E::
        lcall  reply_put_reading_value               ; 4F6E
        ljmp   L_51C8                                ; 4F71
L_4F74::
        mov    0x2D, #0x6E                           ; 4F74
        mov    0x2E, #0xB1                           ; 4F77
        lcall  reply_put_string                      ; 4F7A
        mov    0x29, #0x00                           ; 4F7D
        mov    0x2A, #0x81                           ; 4F80
        mov    0x2B, #0x00                           ; 4F83
        mov    0x2C, #0x6B                           ; 4F86
        lcall  func_to_cmd_index                     ; 4F89
        mov    0x33, a                               ; 4F8C
        jb     0x17, L_4F94                          ; 4F8E
        lcall  reply_put_reading_header              ; 4F91
L_4F94::
        lcall  reply_put_reading_value               ; 4F94
        ljmp   L_51C8                                ; 4F97
L_4F9A::
        ljmp   L_51C8                                ; 4F9A
L_4F9D::
        mov    a, #0x03                              ; 4F9D
        anl    a, meter_mode                         ; 4F9F
        add    a, #0x31                              ; 4FA1
        mov    r2, a                                 ; 4FA3
        mov    a, 0x0B                               ; 4FA4
        mov    dptr, #x_reply_buf                    ; 4FA6
        lcall  dptr_add_a                            ; 4FA9
        mov    a, r2                                 ; 4FAC
        movx   @dptr, a                              ; 4FAD
        inc    0x0B                                  ; 4FAE
        ljmp   L_51C8                                ; 4FB0
L_4FB3::
        lcall  func_to_cmd_index                     ; 4FB3
        mov    0x33, a                               ; 4FB6
        mov    a, #0x03                              ; 4FB8
        anl    a, meter_mode                         ; 4FBA
        mov    sfr_B, #0x03                          ; 4FBC
        mov    r2, a                                 ; 4FBF
        mov    a, 0x33                               ; 4FC0
        mul    ab                                    ; 4FC2
        mov    r4, sfr_B                             ; 4FC3
        mov    r5, a                                 ; 4FC5
        mov    a, r5                                 ; 4FC6
        add    a, #0x40                              ; 4FC7
        mov    sfr_DPL, a                            ; 4FC9
        mov    a, r4                                 ; 4FCB
        addc   a, #0x6E                              ; 4FCC
        mov    sfr_DPH, a                            ; 4FCE
        mov    a, r2                                 ; 4FD0
        movc   a, @a+dptr                            ; 4FD1
        mov    0x32, a                               ; 4FD2
        mov    r2, 0x33                              ; 4FD4
        cjne   r2, #0x07, L_4FE2                     ; 4FD6
        mov    a, #0x70                              ; 4FD9
        anl    a, meter_state                        ; 4FDB
        cjne   a, #0x60, L_4FE2                      ; 4FDD
        dec    0x32                                  ; 4FE0
L_4FE2::
        mov    a, 0x32                               ; 4FE2
        jnz    L_4FE8                                ; 4FE4
        sjmp   L_4FE2                                ; 4FE6
L_4FE8::
        mov    a, #0x30                              ; 4FE8
        orl    a, 0x32                               ; 4FEA
        mov    r2, a                                 ; 4FEC
        mov    a, 0x0B                               ; 4FED
        mov    dptr, #x_reply_buf                    ; 4FEF
        lcall  dptr_add_a                            ; 4FF2
        mov    a, r2                                 ; 4FF5
        movx   @dptr, a                              ; 4FF6
        inc    0x0B                                  ; 4FF7
        ljmp   L_51C8                                ; 4FF9
L_4FFC::
        mov    a, meter_mode                         ; 4FFC
        rr     a                                     ; 4FFE
        rr     a                                     ; 4FFF
        anl    a, #0x3F                              ; 5000
        anl    a, #0x03                              ; 5002
        mov    0x2F, a                               ; 5004
        mov    a, 0x2F                               ; 5006
        clr    c                                     ; 5008
        mov    sfr_B, a                              ; 5009
        rlc    a                                     ; 500B
        add    a, sfr_B                              ; 500C
        mov    dptr, #L_5032                         ; 500E
        jmp    @a+dptr                               ; 5011
L_5012::
        mov    0x2D, #0x6E                           ; 5012
        mov    0x2E, #0xB3                           ; 5015
        sjmp   L_503E                                ; 5018
L_501A::
        mov    0x2D, #0x6E                           ; 501A
        mov    0x2E, #0xB5                           ; 501D
        sjmp   L_503E                                ; 5020
L_5022::
        mov    0x2D, #0x6E                           ; 5022
        mov    0x2E, #0xB7                           ; 5025
        sjmp   L_503E                                ; 5028
L_502A::
        mov    0x2D, #0x6E                           ; 502A
        mov    0x2E, #0xB9                           ; 502D
        sjmp   L_503E                                ; 5030
L_5032::
        ljmp   L_5012                                ; 5032
L_5035::
        ljmp   L_501A                                ; 5035
L_5038::
        ljmp   L_5022                                ; 5038
L_503B::
        ljmp   L_502A                                ; 503B
L_503E::
        lcall  reply_put_string                      ; 503E
        ljmp   L_51C8                                ; 5041
L_5044::
        ljmp   L_51C8                                ; 5044
L_5047::
        jb     cal_mode, L_504D                      ; 5047
        ljmp   L_5060                                ; 504A
L_504D::
        jnb    cal_hot, L_5058                       ; 504D
        mov    0x2D, #0x6E                           ; 5050
        mov    0x2E, #0xBB                           ; 5053
        sjmp   L_505E                                ; 5056
L_5058::
        mov    0x2D, #0x6E                           ; 5058
        mov    0x2E, #0xC0                           ; 505B
L_505E::
        sjmp   L_5066                                ; 505E
L_5060::
        mov    0x2D, #0x6E                           ; 5060
        mov    0x2E, #0xC5                           ; 5063
L_5066::
        lcall  reply_put_string                      ; 5066
        ljmp   L_51C8                                ; 5069
L_506C::
        jnb    0x17, L_5077                          ; 506C
        mov    0x2D, #0x6E                           ; 506F
        mov    0x2E, #0xCA                           ; 5072
        sjmp   L_507D                                ; 5075
L_5077::
        mov    0x2D, #0x6E                           ; 5077
        mov    0x2E, #0xCC                           ; 507A
L_507D::
        lcall  reply_put_string                      ; 507D
        ljmp   L_51C8                                ; 5080
L_5083::
        lcall  jcv_get_ptr                           ; 5083
        mov    0x2B, r6                              ; 5086
        mov    0x2C, r7                              ; 5088
        mov    a, 0x2B                               ; 508A
        orl    a, 0x2C                               ; 508C
        jnz    L_5096                                ; 508E
        mov    0x2B, #0x07                           ; 5090
        mov    0x2C, #0x6C                           ; 5093
L_5096::
        mov    0x2F, #0x00                           ; 5096
L_5099::
        mov    a, 0x2F                               ; 5099
        setb   c                                     ; 509B
        subb   a, #0x05                              ; 509C
        jnc    L_50B9                                ; 509E
        mov    a, 0x2F                               ; 50A0
        mov    sfr_DPL, 0x2C                         ; 50A2
        mov    sfr_DPH, 0x2B                         ; 50A5
        lcall  dptr_add_a                            ; 50A8
        movx   a, @dptr                              ; 50AB
        mov    0x30, a                               ; 50AC
        lcall  reply_put_3digits                     ; 50AE
        mov    a, 0x2F                               ; 50B1
        add    a, #0x01                              ; 50B3
        mov    0x2F, a                               ; 50B5
        jnc    L_5099                                ; 50B7
L_50B9::
        dec    0x0B                                  ; 50B9
        ljmp   L_51C8                                ; 50BB
L_50BE::
        ljmp   L_51C8                                ; 50BE
L_50C1::
        mov    dptr, #x_reply_items_left             ; 50C1
        movx   a, @dptr                              ; 50C4
        mov    dptr, #T_6FB9                         ; 50C5
        mov    r2, a                                 ; 50C8
        clr    a                                     ; 50C9
        movc   a, @a+dptr                            ; 50CA
        clr    c                                     ; 50CB
        subb   a, r2                                 ; 50CC
        inc    a                                     ; 50CD
        mov    0x30, a                               ; 50CE
        mov    a, 0x30                               ; 50D0
        clr    c                                     ; 50D2
        subb   a, #0x01                              ; 50D3
        mov    r7, a                                 ; 50D5
        mov    r6, #0x00                             ; 50D6
        mov    a, #0x02                              ; 50D8
        lcall  shl16_r6r7                            ; 50DA
        mov    a, r7                                 ; 50DD
        add    a, #0x00                              ; 50DE
        mov    r7, a                                 ; 50E0
        mov    a, r6                                 ; 50E1
        addc   a, #0x02                              ; 50E2
        mov    r6, a                                 ; 50E4
        mov    0x29, r6                              ; 50E5
        mov    0x2A, r7                              ; 50E7
        mov    c, 0x1F                               ; 50E9
        mov    0x2A, c                               ; 50EB
        clr    0x1F                                  ; 50ED
        lcall  cdp_load_slot                         ; 50EF
        jb     cal_enable, L_5103                    ; 50F2
        lcall  cal_seal_check                        ; 50F5
        jnc    L_5103                                ; 50F8
        mov    0x2D, #0x6E                           ; 50FA
        mov    0x2E, #0xCE                           ; 50FD
        ljmp   L_5114                                ; 5100
L_5103::
        jnb    0x1F, L_510E                          ; 5103
        mov    0x2D, #0x6E                           ; 5106
        mov    0x2E, #0xD0                           ; 5109
        sjmp   L_5114                                ; 510C
L_510E::
        mov    0x2D, #0x6E                           ; 510E
        mov    0x2E, #0xD2                           ; 5111
L_5114::
        lcall  reply_put_string                      ; 5114
        mov    c, 0x2A                               ; 5117
        mov    0x1F, c                               ; 5119
        lcall  reply_put_3digits                     ; 511B
        mov    0x2F, #0x67                           ; 511E
        mov    0x31, #0x40                           ; 5121
        lcall  reply_put_float                       ; 5124
        mov    a, 0x0B                               ; 5127
        add    a, #0x0D                              ; 5129
        mov    0x0B, a                               ; 512B
        ljmp   L_51C8                                ; 512D
L_5130::
        lcall  rms_get_byte                          ; 5130
        mov    0x30, a                               ; 5133
        lcall  reply_put_3digits                     ; 5135
        dec    0x0B                                  ; 5138
        ljmp   L_51C8                                ; 513A
L_513D::
        jnb    mains_60hz, L_5148                    ; 513D
        mov    0x2D, #0x6D                           ; 5140
        mov    0x2E, #0xBB                           ; 5143
        sjmp   L_514E                                ; 5146
L_5148::
        mov    0x2D, #0x6D                           ; 5148
        mov    0x2E, #0xB6                           ; 514B
L_514E::
        lcall  reply_put_string                      ; 514E
        dec    0x0B                                  ; 5151
        ljmp   L_51C8                                ; 5153
L_5156::
        jnb    cr_enabled, L_5161                    ; 5156
        mov    0x2D, #0x6D                           ; 5159
        mov    0x2E, #0xBB                           ; 515C
        sjmp   L_5167                                ; 515F
L_5161::
        mov    0x2D, #0x6D                           ; 5161
        mov    0x2E, #0xB6                           ; 5164
L_5167::
        lcall  reply_put_string                      ; 5167
        dec    0x0B                                  ; 516A
        sjmp   L_51C8                                ; 516C
L_516E::
        lcall  nv_get_iface_config                   ; 516E
        anl    a, #0x9F                              ; 5171
        mov    0x30, a                               ; 5173
        lcall  reply_put_3digits                     ; 5175
        dec    0x0B                                  ; 5178
        sjmp   L_51C8                                ; 517A
L_517C::
        mov    dptr, #x_funcswitch_step_count        ; 517C
        movx   a, @dptr                              ; 517F
        mov    0x30, a                               ; 5180
        lcall  reply_put_3digits                     ; 5182
        dec    0x0B                                  ; 5185
        sjmp   L_51C8                                ; 5187
L_5189::
        ljmp   L_4EB3                                ; 5189
L_518C::
        ljmp   L_4EBE                                ; 518C
L_518F::
        ljmp   L_4F0E                                ; 518F
L_5192::
        ljmp   L_4F2E                                ; 5192
L_5195::
        ljmp   L_4F4E                                ; 5195
L_5198::
        ljmp   L_4F74                                ; 5198
L_519B::
        ljmp   L_4F9A                                ; 519B
L_519E::
        ljmp   L_4F9D                                ; 519E
L_51A1::
        ljmp   L_4FB3                                ; 51A1
L_51A4::
        ljmp   L_4FFC                                ; 51A4
L_51A7::
        ljmp   L_5044                                ; 51A7
L_51AA::
        ljmp   L_5047                                ; 51AA
L_51AD::
        ljmp   L_506C                                ; 51AD
L_51B0::
        ljmp   L_5083                                ; 51B0
L_51B3::
        ljmp   L_50BE                                ; 51B3
L_51B6::
        ljmp   L_50C1                                ; 51B6
L_51B9::
        ljmp   L_5130                                ; 51B9
L_51BC::
        ljmp   L_513D                                ; 51BC
L_51BF::
        ljmp   L_5156                                ; 51BF
L_51C2::
        ljmp   L_516E                                ; 51C2
L_51C5::
        ljmp   L_517C                                ; 51C5
L_51C8::
        mov    dptr, #x_reply_items_left             ; 51C8
        movx   a, @dptr                              ; 51CB
        dec    a                                     ; 51CC
        movx   @dptr, a                              ; 51CD
        movx   a, @dptr                              ; 51CE
        jz     L_51D8                                ; 51CF
        mov    dptr, #x_reply_pending_cmd            ; 51D1
        movx   a, @dptr                              ; 51D4
        cjne   a, #0x22, L_51E8                      ; 51D5
L_51D8::
        lcall  reply_send_last                       ; 51D8
        mov    dptr, #x_reply_items_left             ; 51DB
        movx   a, @dptr                              ; 51DE
        jnz    L_51E6                                ; 51DF
        mov    dptr, #x_reply_pending_cmd            ; 51E1
        clr    a                                     ; 51E4
        movx   @dptr, a                              ; 51E5
L_51E6::
        sjmp   L_51F8                                ; 51E6
L_51E8::
        mov    a, 0x0B                               ; 51E8
        mov    dptr, #x_reply_buf                    ; 51EA
        lcall  dptr_add_a                            ; 51ED
        mov    a, #0x3B                              ; 51F0
        movx   @dptr, a                              ; 51F2
        inc    0x0B                                  ; 51F3
        lcall  reply_send                            ; 51F5
L_51F8::
        ret                                          ; 51F8
L_51F9::
        ret                                          ; 51F9

start::
        mov    sfr_SP, #0x60                         ; 51FA
        mov    sfr_P1, #0xC3                         ; 51FD
        setb   0x92                                  ; 5200
        lcall  i2c_both_buses_stop                   ; 5202
        lcall  iface_boot_handshake                  ; 5205
        push   0x23                                  ; 5208
        lcall  system_init                           ; 520A
        pop    sfr_ACC                               ; 520D
        anl    a, #0x2C                              ; 520F
        mov    0x23, a                               ; 5211
        setb   sbit_TXD                              ; 5213
        jb     sbit_TXD, L_521C                      ; 5215
        setb   cal_enable                            ; 5218
        sjmp   L_5223                                ; 521A
L_521C::
        setb   0x92                                  ; 521C
        mov    c, 0x92                               ; 521E
        cpl    c                                     ; 5220
        mov    0x1C, c                               ; 5221
L_5223::
        ljmp   main_loop                             ; 5223

; power-up handshake with interface board (I2C bus A, 0x58..)
iface_boot_handshake::
        mov    a, #0x08                              ; 5226
        mov    dptr, #0x00EB                         ; 5228
        movx   @dptr, a                              ; 522B
        lcall  read_option_switches                  ; 522C
        mov    dptr, #0x0053                         ; 522F
        lcall  iface_send_channel                    ; 5232
        mov    dptr, #0x0055                         ; 5235
        movx   a, @dptr                              ; 5238
        jnb    0xE7, L_5261                          ; 5239
L_523C::
        mov    dptr, #0x0053                         ; 523C
        lcall  iface_receive_channel                 ; 523F
        jnc    L_523C                                ; 5242
        mov    dptr, #0x0059                         ; 5244
        movx   @dptr, a                              ; 5247
        jnz    L_5257                                ; 5248
        lcall  read_option_switches                  ; 524A
        orl    a, #0x80                              ; 524D
L_524F::
        mov    dptr, #0x0053                         ; 524F
        lcall  iface_send_channel                    ; 5252
        sjmp   L_5261                                ; 5255
L_5257::
        cjne   a, #0x03, L_5261                      ; 5257
        setb   c                                     ; 525A
        mov    a, #0x60                              ; 525B
        mov    r2, #0x00                             ; 525D
        sjmp   L_524F                                ; 525F
L_5261::
        mov    a, #0x00                              ; 5261
        mov    r2, #0x00                             ; 5263
        mov    dptr, #0x0056                         ; 5265
        clr    c                                     ; 5268
        lcall  iface_send_channel                    ; 5269
        lcall  iface_select_pending                  ; 526C
        lcall  cr_load_setting                       ; 526F
        ljmp   task_remote_parse_tail                ; 5272

; reads option/config byte via 5ACF, stores flags 23h.2/23h.3
read_option_switches::
        lcall  nv_get_iface_config                   ; 5275
        push   sfr_ACC                               ; 5278
        anl    a, #0x80                              ; 527A
        mov    r2, a                                 ; 527C
        rlc    a                                     ; 527D
        mov    0x1B, c                               ; 527E
        mov    emo_continuous, c                     ; 5280
        mov    r0, #0x56                             ; 5282
        lcall  i24_clr_r0                            ; 5284
        mov    dptr, #x_emo_count                    ; 5287
        lcall  i24_st_r0_xdata                       ; 528A
        pop    sfr_ACC                               ; 528D
        anl    a, #0x1F                              ; 528F
        orl    a, #0x60                              ; 5291
        clr    c                                     ; 5293
        ret                                          ; 5294

; IE/TCON/SCON off, clear IRAM 08..5F, init state, LCD test pattern
system_init::
        clr    a                                     ; 5295
        mov    sfr_IE, a                             ; 5296
        mov    sfr_TCON, a                           ; 5298
        mov    sfr_SCON, a                           ; 529A
        mov    sfr_PSW, #0x00                        ; 529C
        clr    0x92                                  ; 529F
        setb   0x92                                  ; 52A1
        lcall  i2c_both_buses_stop                   ; 52A3
        clr    a                                     ; 52A6
        mov    r0, #0x08                             ; 52A7
        mov    r2, #0x58                             ; 52A9
        push   0x23                                  ; 52AB
L_52AD::
        mov    @r0, a                                ; 52AD
        inc    r0                                    ; 52AE
        djnz   r2, L_52AD                            ; 52AF
        pop    0x23                                  ; 52B1
        anl    0x23, #0x30                           ; 52B3
        mov    dptr, #x_emo_count                    ; 52B6
        lcall  xdata_clear3                          ; 52B9
        mov    meter_state, #0xA1                    ; 52BC
        mov    dptr, #x_speed_saved                  ; 52BF
        movx   a, @dptr                              ; 52C2
        cjne   a, #0x03, L_52C6                      ; 52C3
L_52C6::
        jc     L_52CB                                ; 52C6
        mov    a, #0x01                              ; 52C8
        movx   @dptr, a                              ; 52CA
L_52CB::
        mov    meter_mode, a                         ; 52CB
        mov    0x22, #0x08                           ; 52CD
        mov    r0, #0x43                             ; 52D0
        mov    dptr, #T_6FD0                         ; 52D2
        lcall  fp_ld_code_r0                         ; 52D5
        mov    dptr, #x_zero_reference               ; 52D8
        lcall  fp_st_r0_xdata                        ; 52DB
        mov    dptr, #T_6FDC                         ; 52DE
        lcall  fp_ld_code_r0                         ; 52E1
        mov    dptr, #x_dbm_reference                ; 52E4
        lcall  fp_st_r0_xdata                        ; 52E7
        lcall  min_reset                             ; 52EA
        lcall  max_reset                             ; 52ED
        mov    a, #0x08                              ; 52F0
        mov    dptr, #x_result_flags                 ; 52F2
        movx   @dptr, a                              ; 52F5
        lcall  iface_report_status                   ; 52F6
        lcall  result_record_clear                   ; 52F9
        lcall  menu_init                             ; 52FC
        lcall  reply_init                            ; 52FF
        lcall  display_timer_init                    ; 5302
        lcall  meas_init                             ; 5305
        lcall  trigger_clear                         ; 5308
        mov    dptr, #msg_table                      ; 530B
        lcall  lcd_show_message                      ; 530E
        lcall  lcd_refresh                           ; 5311
        clr    0x92                                  ; 5314
        setb   0x92                                  ; 5316
        mov    a, #0x70                              ; 5318
        lcall  i2cB_start_write                      ; 531A
        mov    r0, #0x19                             ; 531D
L_531F::
        mov    a, r0                                 ; 531F
        add    a, #0x07                              ; 5320
        movc   a, @a+pc                              ; 5322
        lcall  i2cB_send_byte                        ; 5323
        djnz   r0, L_531F                            ; 5326
        ljmp   i2cB_stop                             ; 5328
lcd_test_pattern::
        .db 0x3F, 0xFB, 0x3F, 0x7E, 0xF7, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF ; 532B ?.?~............
        .db 0xFF, 0xBF, 0x57, 0xC4, 0x70, 0xF8, 0xE0, 0x80, 0xC8                             ; 533B ..W.p....

; release both bit-banged I2C buses
i2c_both_buses_stop::
        anl    sfr_P3, #0xDB                         ; 5344
        lcall  i2cB_stop                             ; 5347
        ljmp   i2cA_stop                             ; 534A

; Timer 0 overflow
isr_timer0::
        jnb    0x3D, L_535C                          ; 534D
        clr    0x92                                  ; 5350
        setb   0x92                                  ; 5352
        djnz   0x1B, L_535B                          ; 5354
        clr    0x3D                                  ; 5357
        clr    sbit_TR0                              ; 5359
L_535B::
        reti                                         ; 535B
L_535C::
        jnb    0x29, L_5362                          ; 535C
        inc    adc_count_mid                         ; 535F
        reti                                         ; 5361
L_5362::
        push   sfr_ACC                               ; 5362
        push   sfr_PSW                               ; 5364
        mov    a, meter_state                        ; 5366
        anl    a, #0x0F                              ; 5368
        cjne   a, #0x08, L_5391                      ; 536A
        clr    sbit_TR0                              ; 536D
        jb     0x28, L_5386                          ; 536F
        setb   sbit_TR1                              ; 5372
        setb   0x28                                  ; 5374
        mov    c, time_stop_negslope                 ; 5376
        mov    sbit_TXD, c                           ; 5378
        mov    sfr_TL0, #0xFF                        ; 537A
        mov    sfr_TH0, #0xFF                        ; 537D
        setb   sbit_TR0                              ; 5380
        setb   time_started                          ; 5382
        sjmp   L_538C                                ; 5384
L_5386::
        clr    sbit_TR1                              ; 5386
        clr    sbit_TR0                              ; 5388
        clr    0x28                                  ; 538A
L_538C::
        pop    sfr_PSW                               ; 538C
        pop    sfr_ACC                               ; 538E
        reti                                         ; 5390
L_5391::
        cjne   a, #0x0A, L_5386                      ; 5391
        inc    adc_count_hi                          ; 5394
        sjmp   L_538C                                ; 5396

; INT1 edge: stop T0, start T1 with reload (time/frequency gate); not ADC READY
isr_int1_gate::
        clr    sbit_EX1                              ; 5398
        clr    sbit_TR0                              ; 539A
        jnb    0x29, L_53A2                          ; 539C
        clr    0x28                                  ; 539F
        reti                                         ; 53A1
L_53A2::
        mov    sfr_TL1, #0xE0                        ; 53A2
        mov    sfr_TH1, #0xB1                        ; 53A5
        jnb    mains_60hz, L_53B1                    ; 53A8
        mov    sfr_TL1, #0xE5                        ; 53AB
        mov    sfr_TH1, #0xBE                        ; 53AE
L_53B1::
        setb   sbit_TR1                              ; 53B1
        clr    time_started                          ; 53B3
        setb   0x38                                  ; 53B5
        reti                                         ; 53B7

; Timer 1 overflow
isr_timer1::
        jnb    0x18, L_53C1                          ; 53B8
        djnz   0x18, L_53C0                          ; 53BB
        clr    sbit_TR1                              ; 53BE
L_53C0::
        reti                                         ; 53C0
L_53C1::
        push   sfr_ACC                               ; 53C1
        push   sfr_PSW                               ; 53C3
        mov    a, meter_state                        ; 53C5
        anl    a, #0x0F                              ; 53C7
        cjne   a, #0x08, L_53E4                      ; 53C9
L_53CC::
        mov    a, adc_count_mid                      ; 53CC
        add    a, #0x01                              ; 53CE
        mov    adc_count_mid, a                      ; 53D0
        jnc    L_5437                                ; 53D2
        mov    a, adc_count_hi                       ; 53D4
        addc   a, #0x00                              ; 53D6
        mov    adc_count_hi, a                       ; 53D8
        jnc    L_5437                                ; 53DA
        mov    a, 0x11                               ; 53DC
        addc   a, #0x00                              ; 53DE
        mov    0x11, a                               ; 53E0
        sjmp   L_5437                                ; 53E2
L_53E4::
        cjne   a, #0x09, L_53EC                      ; 53E4
        jb     0x38, L_5435                          ; 53E7
        sjmp   L_53CC                                ; 53EA
L_53EC::
        djnz   0x15, L_5437                          ; 53EC
        jb     0x04, L_5430                          ; 53EF
        jb     0x06, L_5430                          ; 53F2
        jnb    speed_b0, L_5418                      ; 53F5
        mov    0x16, sfr_TL0                         ; 53F8
        mov    0x17, sfr_TH0                         ; 53FB
        mov    0x18, #0x00                           ; 53FE
        mov    a, sfr_TL0                            ; 5401
        mov    0x18, a                               ; 5403
        clr    c                                     ; 5405
        subb   a, 0x16                               ; 5406
        jnc    L_540D                                ; 5408
        mov    0x17, sfr_TH0                         ; 540A
L_540D::
        mov    0x16, 0x18                            ; 540D
        mov    0x18, #0x00                           ; 5410
        mov    0x15, #0x02                           ; 5413
        sjmp   L_542E                                ; 5416
L_5418::
        clr    sbit_TR0                              ; 5418
        mov    0x16, sfr_TL0                         ; 541A
        mov    0x17, sfr_TH0                         ; 541D
        mov    c, sbit_TF0                           ; 5420
        setb   sbit_TR0                              ; 5422
        mov    0x18, adc_count_hi                    ; 5424
        jnc    L_542B                                ; 5427
        inc    0x18                                  ; 5429
L_542B::
        mov    0x15, #0x10                           ; 542B
L_542E::
        setb   0x28                                  ; 542E
L_5430::
        djnz   0x14, L_5437                          ; 5430
        clr    sbit_TR0                              ; 5433
L_5435::
        clr    sbit_TR1                              ; 5435
L_5437::
        pop    sfr_PSW                               ; 5437
        pop    sfr_ACC                               ; 5439
        reti                                         ; 543B

; swap in parser context (XDATA 0x00DB, 13 bytes + float 0x01D1) and run one parser step
task_remote_parse::
        mov    dptr, #x_parser_ctx                   ; 543C
        mov    r0, #0x2A                             ; 543F
        mov    r2, #0x0D                             ; 5441
        lcall  xdata_to_iram                         ; 5443
        mov    dptr, #x_parser_number                ; 5446
        mov    r0, #0x5F                             ; 5449
        lcall  fp_ld_xdata_r0                        ; 544B
        lcall  parser_step                           ; 544E
L_5451::
        mov    dptr, #x_parser_number                ; 5451
        mov    r0, #0x5F                             ; 5454
        lcall  fp_st_r0_xdata                        ; 5456
        mov    dptr, #x_parser_ctx                   ; 5459
        mov    r0, #0x2A                             ; 545C
        mov    r2, #0x0D                             ; 545E
        ljmp   iram_to_xdata                         ; 5460

task_remote_parse_tail::
        lcall  parser_restart                        ; 5463
        sjmp   L_5451                                ; 5466

; uses P1.6
task_5468::
        lcall  func_is_time_or_cont                  ; 5468
        jnc    L_54A4                                ; 546B
        mov    dptr, #0x00EB                         ; 546D
        movx   a, @dptr                              ; 5470
        jnb    0xE4, L_5476                          ; 5471
        sjmp   L_549A                                ; 5474
L_5476::
        mov    a, meter_state                        ; 5476
        anl    a, #0x0F                              ; 5478
        cjne   a, #0x01, L_547F                      ; 547A
        sjmp   L_549A                                ; 547D
L_547F::
        cjne   a, #0x0A, L_5484                      ; 547F
        sjmp   L_549A                                ; 5482
L_5484::
        jnb    cal_mode, L_54A8                      ; 5484
        cjne   a, #0x01, L_548C                      ; 5487
        sjmp   L_5494                                ; 548A
L_548C::
        cjne   a, #0x0A, L_5491                      ; 548C
        sjmp   L_5494                                ; 548F
L_5491::
        cjne   a, #0x0B, L_549E                      ; 5491
L_5494::
        jb     speed_b0, L_549A                      ; 5494
        jnb    speed_b1, L_54A4                      ; 5497
L_549A::
        setb   0x12                                  ; 549A
        sjmp   L_54AD                                ; 549C
L_549E::
        jnb    speed_b0, L_549A                      ; 549E
        jb     speed_b1, L_549A                      ; 54A1
L_54A4::
        clr    0x12                                  ; 54A4
        sjmp   L_54AD                                ; 54A6
L_54A8::
        cjne   a, #0x0B, L_549E                      ; 54A8
        sjmp   L_5494                                ; 54AB
L_54AD::
        mov    r0, #0x00                             ; 54AD
        mov    a, meter_state                        ; 54AF
        anl    a, #0x0E                              ; 54B1
        jb     0x2E, L_54E1                          ; 54B3
        jb     0x96, L_54E0                          ; 54B6
L_54B9::
        djnz   r0, L_54B9                            ; 54B9
        jb     0x96, L_54E0                          ; 54BB
        setb   0x2E                                  ; 54BE
        cjne   a, #0x06, L_54D5                      ; 54C0
L_54C3::
        anl    meter_state, #0x8F                    ; 54C3
        orl    meter_state, #0x60                    ; 54C6
        lcall  meas_restart_from_ui                  ; 54C9
        lcall  trigger_clear                         ; 54CC
        lcall  cal_status_or_dashes                  ; 54CF
        ljmp   result_restart                        ; 54D2
L_54D5::
        setb   0x1E                                  ; 54D5

lcd_show_error::
        jb     0x31, L_54E0                          ; 54D7
        mov    dptr, #T_7111                         ; 54DA
        lcall  lcd_show_message                      ; 54DD
L_54E0::
        ret                                          ; 54E0
L_54E1::
        jnb    0x96, L_54F4                          ; 54E1
L_54E4::
        djnz   r0, L_54E4                            ; 54E4
        jnb    0x96, L_54F3                          ; 54E6
        clr    0x2E                                  ; 54E9
        cjne   a, #0x06, L_54F0                      ; 54EB
        sjmp   L_54C3                                ; 54EE
L_54F0::
        lcall  cal_status_or_dashes                  ; 54F0
L_54F3::
        ret                                          ; 54F3
L_54F4::
        cjne   a, #0x06, lcd_show_error              ; 54F4
        ret                                          ; 54F7

func_is_time_or_cont::
        mov    a, meter_state                        ; 54F8
        anl    a, #0x0F                              ; 54FA
        cjne   a, #0x08, L_5501                      ; 54FC
        sjmp   L_5506                                ; 54FF
L_5501::
        jz     L_5506                                ; 5501
        cjne   a, #0x0D, L_5508                      ; 5503
L_5506::
        clr    c                                     ; 5506
        ret                                          ; 5507
L_5508::
        setb   c                                     ; 5508
        ret                                          ; 5509
L_550A::
        ret                                          ; 550A
L_550B::
        ret                                          ; 550B

; dB: log10 wrapper with saved context (XDATA 0x01AA)
db_log10_value::
        mov    r6, a                                 ; 550C
        mov    a, r0                                 ; 550D
        mov    r4, a                                 ; 550E
        mov    a, sfr_SP                             ; 550F
        mov    dptr, #0x01AA                         ; 5511
        movx   @dptr, a                              ; 5514
        mov    r0, #0x60                             ; 5515
        mov    dptr, #0x01AB                         ; 5517
        clr    c                                     ; 551A
        subb   a, #0x60                              ; 551B
        inc    a                                     ; 551D
        mov    r2, a                                 ; 551E
        lcall  iram_to_xdata                         ; 551F
        mov    sfr_SP, #0x60                         ; 5522
        mov    a, r4                                 ; 5525
        mov    r0, a                                 ; 5526
        mov    a, r6                                 ; 5527
        lcall  fp_log10                              ; 5528
        mov    r7, sfr_PSW                           ; 552B
        mov    r6, a                                 ; 552D
        mov    a, r0                                 ; 552E
        mov    r4, a                                 ; 552F
        mov    dptr, #0x01AA                         ; 5530
        movx   a, @dptr                              ; 5533
        mov    sfr_SP, a                             ; 5534
        mov    r0, #0x60                             ; 5536
        mov    dptr, #0x01AB                         ; 5538
        clr    c                                     ; 553B
        subb   a, #0x60                              ; 553C
        inc    a                                     ; 553E
        mov    r2, a                                 ; 553F
        lcall  xdata_to_iram                         ; 5540
        mov    a, r4                                 ; 5543
        mov    r0, a                                 ; 5544
        mov    a, r6                                 ; 5545
        mov    sfr_PSW, r7                           ; 5546
        ret                                          ; 5548

; text buffer XDATA 0x0000 -> segments; header C8 86 E0 F8 70, 13 data bytes, annunciators
lcd_send_frame::
        mov    sfr_B, #0x00                          ; 5549
        mov    a, 0x1D                               ; 554C
        orl    a, 0x1E                               ; 554E
        jz     L_55B0                                ; 5550
        mov    dptr, #0x005A                         ; 5552
        movx   a, @dptr                              ; 5555
        mov    r0, a                                 ; 5556
        mov    sfr_DPH, 0x1D                         ; 5557
        mov    sfr_DPL, 0x1E                         ; 555A
        inc    dptr                                  ; 555D
        jz     L_5565                                ; 555E
        cjne   a, #0x05, L_5589                      ; 5560
        sjmp   L_55B0                                ; 5563
L_5565::
        movx   a, @dptr                              ; 5565
        anl    a, #0x38                              ; 5566
        cjne   a, #0x18, L_556F                      ; 5568
        setb   0xF5                                  ; 556B
        sjmp   L_5574                                ; 556D
L_556F::
        cjne   a, #0x38, L_5578                      ; 556F
        setb   0xF6                                  ; 5572
L_5574::
        setb   0xF7                                  ; 5574
        sjmp   L_55B0                                ; 5576
L_5578::
        jnb    0xE5, L_557D                          ; 5578
        setb   0xF4                                  ; 557B
L_557D::
        jnb    0xE4, L_5582                          ; 557D
        setb   0xF5                                  ; 5580
L_5582::
        jnb    0xE3, L_55B0                          ; 5582
        setb   0xF6                                  ; 5585
        sjmp   L_55B0                                ; 5587
L_5589::
        movx   a, @dptr                              ; 5589
        anl    a, #0x18                              ; 558A
        cjne   a, #0x10, L_5593                      ; 558C
        setb   0xF5                                  ; 558F
        sjmp   L_55B0                                ; 5591
L_5593::
        inc    dptr                                  ; 5593
        movx   a, @dptr                              ; 5594
        jb     0xE5, L_55A9                          ; 5595
        jb     emo_continuous, L_55A9                ; 5598
        mov    dptr, #x_emo_count                    ; 559B
        lcall  xdata_is_zero3                        ; 559E
        jnz    L_55A9                                ; 55A1
        mov    dptr, #x_reply_pending_cmd            ; 55A3
        movx   a, @dptr                              ; 55A6
        jz     L_55B0                                ; 55A7
L_55A9::
        setb   0xF6                                  ; 55A9
        jnb    0x1B, L_55B0                          ; 55AB
        setb   0xF7                                  ; 55AE
L_55B0::
        mov    r0, #0x36                             ; 55B0
        mov    dptr, #lcd_font_7seg                  ; 55B2
        mov    r5, sfr_DPH                           ; 55B5
        mov    r6, sfr_DPL                           ; 55B7
        mov    r4, #0x07                             ; 55B9
        mov    dptr, #x_lcd_text_buf                 ; 55BB
        movx   a, @dptr                              ; 55BE
        cjne   a, #0x2B, L_55C8                      ; 55BF
        setb   0xF2                                  ; 55C2
        setb   0xF1                                  ; 55C4
        sjmp   L_55CD                                ; 55C6
L_55C8::
        cjne   a, #0x2D, L_55CD                      ; 55C8
        setb   0xF1                                  ; 55CB
L_55CD::
        inc    dptr                                  ; 55CD
        movx   a, @dptr                              ; 55CE
L_55CF::
        cjne   a, #0x2E, L_55D8                      ; 55CF
        setb   0xF0                                  ; 55D2
        inc    dptr                                  ; 55D4
        movx   a, @dptr                              ; 55D5
        sjmp   L_55CF                                ; 55D6
L_55D8::
        mov    r3, sfr_B                             ; 55D8
        cjne   a, #0x51, L_55E3                      ; 55DA
        mov    @r0, #0xFE                            ; 55DD
        inc    r0                                    ; 55DF
        dec    r4                                    ; 55E0
        inc    dptr                                  ; 55E1
        movx   a, @dptr                              ; 55E2
L_55E3::
        clr    0xF0                                  ; 55E3
        clr    sbit_F0                               ; 55E5
        lcall  lcd_encode_chars                      ; 55E7
        jnb    0x70, L_55F5                          ; 55EA
        mov    @r0, 0x33                             ; 55ED
        inc    r0                                    ; 55EF
        mov    @r0, 0x34                             ; 55F0
        inc    r0                                    ; 55F2
        sjmp   L_55FA                                ; 55F3
L_55F5::
        clr    a                                     ; 55F5
        mov    @r0, a                                ; 55F6
        inc    r0                                    ; 55F7
        mov    @r0, a                                ; 55F8
        inc    r0                                    ; 55F9
L_55FA::
        mov    a, #0x60                              ; 55FA
        add    a, r6                                 ; 55FC
        mov    r6, a                                 ; 55FD
        jnc    L_5601                                ; 55FE
        inc    r5                                    ; 5600
L_5601::
        movx   a, @dptr                              ; 5601
        mov    r4, #0x02                             ; 5602
        setb   0xF0                                  ; 5604
        clr    sbit_F0                               ; 5606
        lcall  lcd_encode_chars                      ; 5608
        mov    a, #0x70                              ; 560B
        lcall  i2cB_start_write                      ; 560D
        mov    a, #0xC8                              ; 5610
        lcall  i2cB_send_byte                        ; 5612
        mov    a, #0x86                              ; 5615
        lcall  i2cB_send_byte                        ; 5617
        mov    a, #0xE0                              ; 561A
        lcall  i2cB_send_byte                        ; 561C
        mov    a, #0xF8                              ; 561F
        lcall  i2cB_send_byte                        ; 5621
        mov    a, #0x70                              ; 5624
        lcall  i2cB_send_byte                        ; 5626
        mov    r1, #0x0D                             ; 5629
L_562B::
        dec    r0                                    ; 562B
        mov    a, @r0                                ; 562C
        lcall  i2cB_send_byte                        ; 562D
        djnz   r1, L_562B                            ; 5630
        mov    sfr_B, #0x00                          ; 5632
        mov    a, r3                                 ; 5635
        jnb    0xE0, L_563B                          ; 5636
        setb   0xF7                                  ; 5639
L_563B::
        jnb    0xE1, L_5640                          ; 563B
        setb   0xF6                                  ; 563E
L_5640::
        jnb    0xE4, L_5645                          ; 5640
        setb   0xF5                                  ; 5643
L_5645::
        jnb    0x6D, L_564A                          ; 5645
        setb   0xF4                                  ; 5648
L_564A::
        jnb    0x72, L_564F                          ; 564A
        setb   0xF3                                  ; 564D
L_564F::
        jnb    0xE2, L_5654                          ; 564F
        setb   0xF2                                  ; 5652
L_5654::
        jnb    0x66, L_5659                          ; 5654
        setb   0xF1                                  ; 5657
L_5659::
        jnb    0x67, L_565E                          ; 5659
        setb   0xF0                                  ; 565C
L_565E::
        mov    a, sfr_B                              ; 565E
        lcall  i2cB_send_byte                        ; 5660
        mov    sfr_B, #0x00                          ; 5663
        mov    a, r3                                 ; 5666
        jnb    0x78, L_566C                          ; 5667
        setb   0xF5                                  ; 566A
L_566C::
        jnb    0x7B, L_5671                          ; 566C
        setb   0xF4                                  ; 566F
L_5671::
        jnb    0x5D, L_5676                          ; 5671
        setb   0xF3                                  ; 5674
L_5676::
        jnb    0x65, L_567B                          ; 5676
        setb   0xF2                                  ; 5679
L_567B::
        jnb    0xE5, L_5680                          ; 567B
        setb   0xF1                                  ; 567E
L_5680::
        jnb    0x5F, L_5685                          ; 5680
        setb   0xF0                                  ; 5683
L_5685::
        mov    a, sfr_B                              ; 5685
        lcall  i2cB_send_byte                        ; 5687
        mov    sfr_B, #0x00                          ; 568A
        mov    a, r3                                 ; 568D
        jnb    0x12, L_5693                          ; 568E
        setb   0xF7                                  ; 5691
L_5693::
        jnb    0x60, L_5698                          ; 5693
        setb   0xF6                                  ; 5696
L_5698::
        jnb    0xE6, L_569D                          ; 5698
        setb   0xF5                                  ; 569B
L_569D::
        jnb    0x61, L_56A2                          ; 569D
        setb   0xF4                                  ; 56A0
L_56A2::
        jnb    0x5C, L_56A7                          ; 56A2
        setb   0xF3                                  ; 56A5
L_56A7::
        jnb    0x67, L_56AC                          ; 56A7
        setb   0xF2                                  ; 56AA
L_56AC::
        jnb    0xE7, L_56B1                          ; 56AC
        setb   0xF1                                  ; 56AF
L_56B1::
        jnb    0x62, L_56B6                          ; 56B1
        setb   0xF0                                  ; 56B4
L_56B6::
        mov    a, sfr_B                              ; 56B6
        lcall  i2cB_send_byte                        ; 56B8
        mov    sfr_B, #0x00                          ; 56BB
        jnb    0x67, L_56C3                          ; 56BE
        setb   0xF7                                  ; 56C1
L_56C3::
        jnb    0x67, L_56C8                          ; 56C3
        setb   0xF6                                  ; 56C6
L_56C8::
        jnb    0x70, L_56CD                          ; 56C8
        setb   0xF5                                  ; 56CB
L_56CD::
        jnb    0x7C, L_56D2                          ; 56CD
        setb   0xF4                                  ; 56D0
L_56D2::
        jnb    0x7D, L_56D7                          ; 56D2
        setb   0xF3                                  ; 56D5
L_56D7::
        jnb    0x2F, L_56DC                          ; 56D7
        setb   0xF2                                  ; 56DA
L_56DC::
        jnb    0x5E, L_56E1                          ; 56DC
        setb   0xF1                                  ; 56DF
L_56E1::
        jnb    0x26, L_56E6                          ; 56E1
        setb   0xF0                                  ; 56E4
L_56E6::
        mov    a, sfr_B                              ; 56E6
        lcall  i2cB_send_byte                        ; 56E8
        lcall  i2cB_stop                             ; 56EB
        mov    a, #0x70                              ; 56EE
        lcall  i2cB_start_write                      ; 56F0
        mov    a, #0xC8                              ; 56F3
        lcall  i2cB_send_byte                        ; 56F5
        mov    a, #0x80                              ; 56F8
        lcall  i2cB_send_byte                        ; 56FA
        mov    a, #0xE0                              ; 56FD
        lcall  i2cB_send_byte                        ; 56FF
        mov    a, #0xF8                              ; 5702
        lcall  i2cB_send_byte                        ; 5704
        mov    a, #0x70                              ; 5707
        lcall  i2cB_send_byte                        ; 5709
        mov    sfr_B, #0x00                          ; 570C
        jnb    0x6A, L_5714                          ; 570F
        setb   0xF7                                  ; 5712
L_5714::
        jnb    0x6B, L_5719                          ; 5714
        setb   0xF6                                  ; 5717
L_5719::
        jnb    0x67, L_571E                          ; 5719
        setb   0xF5                                  ; 571C
L_571E::
        jnb    0x67, L_5723                          ; 571E
        setb   0xF4                                  ; 5721
L_5723::
        jnb    0x67, L_5728                          ; 5723
        setb   0xF3                                  ; 5726
L_5728::
        jnb    0x5A, L_572D                          ; 5728
        setb   0xF2                                  ; 572B
L_572D::
        jnb    0x67, L_5732                          ; 572D
        setb   0xF1                                  ; 5730
L_5732::
        jnb    0x67, L_5737                          ; 5732
        setb   0xF0                                  ; 5735
L_5737::
        mov    a, sfr_B                              ; 5737
        lcall  i2cB_send_byte                        ; 5739
        mov    sfr_B, #0x00                          ; 573C
        jnb    0x67, L_5744                          ; 573F
        setb   0xF7                                  ; 5742
L_5744::
        jnb    0x5B, L_5749                          ; 5744
        setb   0xF6                                  ; 5747
L_5749::
        jnb    0x67, L_574E                          ; 5749
        setb   0xF5                                  ; 574C
L_574E::
        jnb    cal_enable, L_5753                    ; 574E
        setb   0xF4                                  ; 5751
L_5753::
        jnb    0x69, L_5758                          ; 5753
        setb   0xF2                                  ; 5756
L_5758::
        jnb    0x6F, L_575D                          ; 5758
        setb   0xF1                                  ; 575B
L_575D::
        jnb    0x58, L_5762                          ; 575D
        setb   0xF0                                  ; 5760
L_5762::
        mov    a, sfr_B                              ; 5762
        lcall  i2cB_send_byte                        ; 5764
        mov    sfr_B, #0x00                          ; 5767
        mov    a, r3                                 ; 576A
        jnb    0x64, L_5770                          ; 576B
        setb   0xF7                                  ; 576E
L_5770::
        jnb    0x67, L_5775                          ; 5770
        setb   0xF6                                  ; 5773
L_5775::
        jnb    0x6E, L_577A                          ; 5775
        setb   0xF5                                  ; 5778
L_577A::
        jnb    0x68, L_577F                          ; 577A
        setb   0xF4                                  ; 577D
L_577F::
        jnb    0xE3, L_5784                          ; 577F
        setb   0xF3                                  ; 5782
L_5784::
        jnb    0x59, L_5789                          ; 5784
        setb   0xF2                                  ; 5787
L_5789::
        jnb    peak_mode_b0, L_5791                  ; 5789
        jb     0x22, L_5791                          ; 578C
        setb   0xF1                                  ; 578F
L_5791::
        jnb    peak_mode_b1, L_5799                  ; 5791
        jb     0x22, L_5799                          ; 5794
        setb   0xF0                                  ; 5797
L_5799::
        mov    a, sfr_B                              ; 5799
        lcall  i2cB_send_byte                        ; 579B
        lcall  i2cB_stop                             ; 579E
        ret                                          ; 57A1

; ASCII -> segment bytes via font, '.' merged into dp
lcd_encode_chars::
        cjne   a, #0x20, L_57A5                      ; 57A2
L_57A5::
        jc     L_57B4                                ; 57A5
        cjne   a, #0x84, L_57AA                      ; 57A7
L_57AA::
        jnb    0xF0, L_57AF                          ; 57AA
        jc     L_57B6                                ; 57AD
L_57AF::
        cjne   a, #0x80, L_57B2                      ; 57AF
L_57B2::
        jc     L_57B6                                ; 57B2
L_57B4::
        mov    a, #0x20                              ; 57B4
L_57B6::
        cjne   a, #0x2E, L_57BE                      ; 57B6
        setb   sbit_F0                               ; 57B9
        inc    r4                                    ; 57BB
        sjmp   L_5807                                ; 57BC
L_57BE::
        cjne   a, #0x83, L_57CA                      ; 57BE
        xch    a, r0                                 ; 57C1
        setb   sbit_F0                               ; 57C2
        cjne   a, #0x3F, L_57C9                      ; 57C4
        mov    r0, #0x20                             ; 57C7
L_57C9::
        xch    a, r0                                 ; 57C9
L_57CA::
        xch    a, r0                                 ; 57CA
        cjne   a, #0x3F, L_57D0                      ; 57CB
        clr    sbit_F0                               ; 57CE
L_57D0::
        xch    a, r0                                 ; 57D0
        xch    a, sfr_DPH                            ; 57D1
        xch    a, r5                                 ; 57D3
        xch    a, sfr_DPH                            ; 57D4
        xch    a, sfr_DPL                            ; 57D6
        xch    a, r6                                 ; 57D8
        xch    a, sfr_DPL                            ; 57D9
        add    a, #0xE0                              ; 57DB
        jnb    0xF0, L_57E3                          ; 57DD
        rl     a                                     ; 57E0
        inc    a                                     ; 57E1
        mov    r7, a                                 ; 57E2
L_57E3::
        movc   a, @a+dptr                            ; 57E3
        jnb    sbit_F0, L_57F1                       ; 57E4
        jnb    0xF0, L_57EB                          ; 57E7
        xch    a, r3                                 ; 57EA
L_57EB::
        setb   0xE3                                  ; 57EB
        jnb    0xF0, L_57F9                          ; 57ED
        xch    a, r3                                 ; 57F0
L_57F1::
        jnb    0xF0, L_57F9                          ; 57F1
        mov    @r0, a                                ; 57F4
        inc    r0                                    ; 57F5
        mov    a, r7                                 ; 57F6
        dec    a                                     ; 57F7
        movc   a, @a+dptr                            ; 57F8
L_57F9::
        mov    @r0, a                                ; 57F9
        inc    r0                                    ; 57FA
        xch    a, sfr_DPH                            ; 57FB
        xch    a, r5                                 ; 57FD
        xch    a, sfr_DPH                            ; 57FE
        xch    a, sfr_DPL                            ; 5800
        xch    a, r6                                 ; 5802
        xch    a, sfr_DPL                            ; 5803
        clr    sbit_F0                               ; 5805
L_5807::
        inc    dptr                                  ; 5807
        movx   a, @dptr                              ; 5808
        djnz   r4, lcd_encode_chars                  ; 5809
        ret                                          ; 580B
lcd_font_7seg::
        .db 0x00, 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00 ; 580C ................
        .db 0xF6, 0x50, 0xB5, 0xF1, 0x53, 0xE3, 0xE7, 0x70, 0xF7, 0xF3, 0x00, 0x00, 0x00, 0x81, 0x00, 0x35 ; 581C .P..S..p.......5
        .db 0xF5, 0x77, 0xC7, 0xA6, 0xD5, 0xA7, 0x27, 0xE6, 0x57, 0x50, 0xF4, 0x00, 0x86, 0x00, 0x76, 0xF6 ; 582C .w....'.WP....v.
        .db 0x37, 0x73, 0x26, 0xE3, 0x87, 0xD6, 0x00, 0x00, 0x00, 0xD3, 0x00, 0xA6, 0x00, 0xF0, 0x00, 0x80 ; 583C 7s&.............
        .db 0x02, 0xF5, 0xC7, 0x85, 0xD5, 0xB7, 0x27, 0xE6, 0x47, 0x40, 0xD0, 0x00, 0x84, 0x00, 0x45, 0xC5 ; 584C ......'.G@....E.
        .db 0x37, 0x73, 0x05, 0xE3, 0x87, 0xC4, 0x00, 0x00, 0x00, 0xD3, 0x00, 0xA6, 0x06, 0xF0, 0x00, 0x00 ; 585C 7s..............
lcd_font_aux::
        .db 0x00, 0x00, 0x90, 0x00, 0x12, 0x00, 0xD6, 0x98, 0xE6, 0x9B, 0xC7, 0xD3, 0xE9, 0x6A, 0x01, 0x00 ; 586C .............j..
        .db 0x0D, 0x00, 0x00, 0x70, 0x0F, 0xF0, 0x06, 0x90, 0x00, 0x40, 0x04, 0x10, 0x00, 0x00, 0x01, 0x40 ; 587C ...p.....@.....@
        .db 0xF1, 0x4F, 0x50, 0x00, 0xB4, 0x4A, 0xF4, 0x0A, 0x54, 0x11, 0xA8, 0x1B, 0xE4, 0x1F, 0x21, 0x42 ; 588C .OP..J..T.....!B
        .db 0xF4, 0x1F, 0xF4, 0x1B, 0x00, 0x0A, 0x00, 0x42, 0x09, 0x00, 0x84, 0x18, 0x00, 0x60, 0x34, 0x82 ; 589C .......B.....`4.
        .db 0xF0, 0x9E, 0x74, 0x17, 0xF6, 0x8A, 0xA0, 0x0F, 0xF2, 0x8A, 0xA0, 0x1F, 0x20, 0x17, 0xE4, 0x0F ; 58AC ..t......... ...
        .db 0x54, 0x15, 0xA2, 0x8A, 0x22, 0x8E, 0x09, 0x15, 0x80, 0x0D, 0x51, 0x25, 0x58, 0x25, 0xF0, 0x0F ; 58BC T...".....Q%X%..
        .db 0x34, 0x17, 0xF8, 0x0F, 0x3C, 0x17, 0xE4, 0x1B, 0x22, 0x82, 0xD0, 0x0D, 0x01, 0x45, 0x58, 0x45 ; 58CC 4...<..."....EXE
        .db 0x09, 0x60, 0x01, 0xA0, 0xA1, 0x4A, 0x00, 0x0F, 0x08, 0x20, 0xF0, 0x00, 0x08, 0x40, 0x80, 0x08 ; 58DC .`...J... ...@..
        .db 0x00, 0x20, 0x80, 0x9C, 0xC6, 0x80, 0x84, 0x80, 0xD4, 0x80, 0xB6, 0x80, 0x26, 0x80, 0xF6, 0x00 ; 58EC . ..........&...
        .db 0x46, 0x80, 0x40, 0x00, 0xD0, 0x00, 0x0E, 0x80, 0x82, 0x80, 0x44, 0x94, 0x44, 0x80, 0xC4, 0x80 ; 58FC F.@.......D.D...
        .db 0x02, 0x17, 0x76, 0x00, 0x04, 0x80, 0xE6, 0x00, 0x86, 0x80, 0xC0, 0x80, 0x48, 0x00, 0xC0, 0x8C ; 590C ..v.........H...
        .db 0x09, 0x60, 0xD6, 0x00, 0x00, 0x58, 0xA2, 0x90, 0x02, 0x80, 0x06, 0x8A, 0xC0, 0x94, 0x00, 0x00 ; 591C .`...X..........
        .db 0x36, 0x00, 0x22, 0x88, 0x82, 0x82, 0x70, 0x07                                   ; 592C 6."...p.

; debounced key number 0-15 -> 35h (FF = none)
key_scan::
        lcall  key_read_matrix                       ; 5934
        jc     L_596F                                ; 5937
        cjne   a, 0xFF, L_594D                       ; 5939
        jnb    0x5A, L_5972                          ; 593C
        lcall  key_debounce_delay                    ; 593F
        lcall  key_read_matrix                       ; 5942
        jc     L_596F                                ; 5945
        cpl    a                                     ; 5947
        jnz    L_5972                                ; 5948
        clr    0x5A                                  ; 594A
        ret                                          ; 594C
L_594D::
        mov    a, #0xFF                              ; 594D
        cjne   a, 0x35, L_5972                       ; 594F
        jb     0x5A, L_5972                          ; 5952
        lcall  key_debounce_delay                    ; 5955
        lcall  key_read_matrix                       ; 5958
        jc     L_596F                                ; 595B
        mov    r2, #0x10                             ; 595D
        mov    r3, a                                 ; 595F
L_5960::
        mov    a, r2                                 ; 5960
        dec    a                                     ; 5961
        mov    dptr, #key_code_table                 ; 5962
        movc   a, @a+dptr                            ; 5965
        cjne   a, 0x03, L_5970                       ; 5966
        dec    r2                                    ; 5969
        mov    0x35, r2                              ; 596A
        setb   0x5A                                  ; 596C
        clr    c                                     ; 596E
L_596F::
        ret                                          ; 596F
L_5970::
        djnz   r2, L_5960                            ; 5970
L_5972::
        clr    c                                     ; 5972
        ret                                          ; 5973
key_code_table::
        .db 0xEE, 0xDE, 0xBE, 0x7E, 0xED, 0xDD, 0xBD, 0x7D, 0xEB, 0xDB, 0xBB, 0x7B, 0xE7, 0xD7, 0xB7, 0x77 ; 5974 ...~...}...{...w

; PCF8574: write F0/read, write 0F/read, OR
key_read_matrix::
        mov    r3, #0xF0                             ; 5984
        mov    a, #0x48                              ; 5986
        lcall  i2cB_write1                           ; 5988
        jc     L_59A4                                ; 598B
        mov    a, #0x48                              ; 598D
        lcall  i2cB_read1_stop                       ; 598F
        jc     L_59A4                                ; 5992
        mov    r4, a                                 ; 5994
        mov    r3, #0x0F                             ; 5995
        mov    a, #0x48                              ; 5997
        lcall  i2cB_write1                           ; 5999
        jc     L_59A4                                ; 599C
        mov    a, #0x48                              ; 599E
        lcall  i2cB_read1_stop                       ; 59A0
        orl    a, r4                                 ; 59A3
L_59A4::
        ret                                          ; 59A4
T_59A5::
        .db 0x0B                                                                             ; 59A5 .
version_string::
        .db 0x50, 0x4D, 0x32, 0x35, 0x32, 0x35, 0x33, 0x20, 0x53                             ; 59A6 PM25253 S
T_59AF::
        .db 0x32, 0x35                                                                       ; 59AF 25
cmd_table::
        .db 0x56                                                                             ; 59B1 V
T_59B2::
        .db 0x50                                                                             ; 59B2 P
T_59B3::
        .db 0x55, 0x98, 0x00, 0x56, 0x50, 0x4C, 0x98, 0x01, 0x56, 0x50, 0x50, 0x98, 0x02, 0x56, 0x44, 0x43 ; 59B3 U..VPL..VPP..VDC
        .db 0x98, 0x03, 0x56, 0x41, 0x43, 0x98, 0x04, 0x56, 0x52, 0x4D, 0x98, 0x05, 0x52, 0x46, 0x57, 0x98 ; 59C3 ..VAC..VRM..RFW.
        .db 0x06, 0x52, 0x54, 0x57, 0x98, 0x07, 0x49, 0x44, 0x43, 0x98, 0x08, 0x49, 0x41, 0x43, 0x98, 0x09 ; 59D3 .RTW..IDC..IAC..
        .db 0x54, 0x50, 0x50, 0x98, 0x0A, 0x54, 0x50, 0x4E, 0x98, 0x0B, 0x54, 0x4E, 0x50, 0x98, 0x0C, 0x54 ; 59E3 TPP..TPN..TNP..T
        .db 0x4E, 0x4E, 0x98, 0x0D, 0x43, 0x41, 0x50, 0x98, 0x0E, 0x46, 0x52, 0x51, 0x98, 0x0F, 0x54, 0x44 ; 59F3 NN..CAP..FRQ..TD
        .db 0x43, 0x98, 0x10, 0x44, 0x49, 0x4F, 0x98, 0x11, 0x43, 0x4F, 0x4E, 0x98, 0x12, 0x46, 0x4E, 0x43 ; 5A03 C..DIO..CON..FNC
        .db 0x30, 0x13, 0x52, 0x4E, 0x47, 0x38, 0x14, 0x44, 0x42, 0x4D, 0x69, 0x15, 0x5A, 0x45, 0x52, 0x79 ; 5A13 0.RNG8.DBMi.ZERy
        .db 0x16, 0x4D, 0x49, 0x4E, 0xA0, 0x17, 0x4D, 0x41, 0x58, 0xA0, 0x18, 0x43, 0x4C, 0x4D, 0x00, 0x19 ; 5A23 .MIN..MAX..CLM..
        .db 0x4D, 0x53, 0x50, 0x22, 0x1A, 0x52, 0x53, 0x4C, 0x22, 0x1B, 0x54, 0x52, 0x47, 0x30, 0x1C, 0x58 ; 5A33 MSP".RSL".TRG0.X
        .db 0x20, 0x20, 0x82, 0x1D, 0x43, 0x41, 0x4C, 0x63, 0x1E, 0x4F, 0x55, 0x54, 0x30, 0x1F, 0x4A, 0x43 ; 5A43   ..CALc.OUT0.JC
        .db 0x56, 0xA4, 0x20, 0x44, 0x4D, 0x50, 0xA0, 0x21, 0x43, 0x44, 0x50, 0x7A, 0x22, 0x52, 0x4D, 0x53 ; 5A53 V. DMP.!CDPz"RMS
        .db 0x22, 0x23, 0x53, 0x49, 0x58, 0x21, 0x24, 0x43, 0x52, 0x20, 0x21, 0x25, 0x49, 0x45, 0x45, 0x22 ; 5A63 "#SIX!$CR !%IEE"
        .db 0x26, 0x4D, 0x54, 0x53, 0x20, 0x27, 0x45, 0x4D, 0x4F, 0x94, 0x28, 0x54, 0x4F, 0x4C, 0x01, 0x28 ; 5A73 &MTS 'EMO.(TOL.(
        .db 0x00                                                                             ; 5A83 .

key_debounce_delay::
        mov    r2, #0x71                             ; 5A84
        mov    r3, #0x14                             ; 5A86
L_5A88::
        djnz   r2, L_5A88                            ; 5A88
        djnz   r3, L_5A88                            ; 5A8A
        ret                                          ; 5A8C

; shift out IRAM 08h,09h on P1.7/T1, latch with P1.3. 09h.1 = switch-motor direction, 08h.4 strobe
shiftreg_write_analog::
        mov    r0, #0x08                             ; 5A8D
        clr    sbit_T1                               ; 5A8F
        lcall  shiftreg_out_byte                     ; 5A91
        inc    r0                                    ; 5A94
        lcall  shiftreg_out_byte                     ; 5A95
        setb   0x93                                  ; 5A98
        nop                                          ; 5A9A
        clr    0x93                                  ; 5A9B
        setb   sbit_T1                               ; 5A9D
        nop                                          ; 5A9F
        setb   0x97                                  ; 5AA0
        ret                                          ; 5AA2

shiftreg_out_byte::
        mov    a, @r0                                ; 5AA3
        mov    r2, #0x08                             ; 5AA4
L_5AA6::
        mov    c, 0xE7                               ; 5AA6
        mov    0x97, c                               ; 5AA8
        setb   sbit_T1                               ; 5AAA
        clr    sbit_T1                               ; 5AAC
        rl     a                                     ; 5AAE
        djnz   r2, L_5AA6                            ; 5AAF
        ret                                          ; 5AB1

; shift in 8 bits from P1.0 = function-switch position (motor-driven rotary switch)
funcswitch_read_pos::
        clr    sbit_T1                               ; 5AB2
        setb   0x90                                  ; 5AB4
        clr    0x97                                  ; 5AB6
        mov    r2, #0x08                             ; 5AB8
        setb   0x97                                  ; 5ABA
L_5ABC::
        mov    c, 0x90                               ; 5ABC
        mov    0xE7, c                               ; 5ABE
        setb   sbit_T1                               ; 5AC0
        rl     a                                     ; 5AC2
        clr    sbit_T1                               ; 5AC3
        djnz   r2, L_5ABC                            ; 5AC5
        setb   sbit_T1                               ; 5AC7
        nop                                          ; 5AC9
        setb   0x97                                  ; 5ACA
        anl    a, #0x7F                              ; 5ACC
        ret                                          ; 5ACE

; byte 1; invalid/31 -> 22 written back
nv_get_iface_config::
        mov    r2, #0x01                             ; 5ACF
        lcall  nv_setting_read                       ; 5AD1
        jb     sbit_F0, L_5AE1                       ; 5AD4
        mov    r2, a                                 ; 5AD7
        anl    a, #0x1F                              ; 5AD8
        xrl    a, #0x1F                              ; 5ADA
        jz     L_5AE1                                ; 5ADC
        mov    a, r2                                 ; 5ADE
        sjmp   L_5AE8                                ; 5ADF
L_5AE1::
        mov    a, #0x16                              ; 5AE1

nv_set_iface_config::
        mov    r2, #0x01                             ; 5AE3
        lcall  nv_setting_write                      ; 5AE5
L_5AE8::
        ret                                          ; 5AE8

; SIX ON
mains_set_60hz::
        mov    a, #0x55                              ; 5AE9
        sjmp   L_5AF6                                ; 5AEB

mains_load_setting::
        mov    r2, #0x02                             ; 5AED
        lcall  nv_setting_read                       ; 5AEF
        jnb    sbit_F0, L_5AFB                       ; 5AF2

; SIX OFF
mains_set_50hz::
        clr    a                                     ; 5AF5
L_5AF6::
        mov    r2, #0x02                             ; 5AF6
        lcall  nv_setting_write                      ; 5AF8
L_5AFB::
        clr    mains_60hz                            ; 5AFB
        jz     L_5B01                                ; 5AFD
        setb   mains_60hz                            ; 5AFF
L_5B01::
        ret                                          ; 5B01

; CR ON: append \r to output
cr_set_on::
        mov    a, #0x55                              ; 5B02
        sjmp   L_5B0F                                ; 5B04

cr_load_setting::
        mov    r2, #0x03                             ; 5B06
        lcall  nv_setting_read                       ; 5B08
        jnb    sbit_F0, L_5B14                       ; 5B0B

cr_set_off::
        clr    a                                     ; 5B0E
L_5B0F::
        mov    r2, #0x03                             ; 5B0F
        lcall  nv_setting_write                      ; 5B11
L_5B14::
        clr    cr_enabled                            ; 5B14
        jz     L_5B1A                                ; 5B16
        setb   cr_enabled                            ; 5B18
L_5B1A::
        ret                                          ; 5B1A

; R2 = byte no.: 2-of-3 vote, repair; F0 = 1 if all copies differ
nv_setting_read::
        clr    sbit_F0                               ; 5B1B
        lcall  nv_addr_copy3                         ; 5B1D
        movx   a, @dptr                              ; 5B20
        mov    r7, a                                 ; 5B21
        lcall  nv_addr_copy2                         ; 5B22
        movx   a, @dptr                              ; 5B25
        mov    r6, a                                 ; 5B26
        lcall  nv_addr_copy1                         ; 5B27
        movx   a, @dptr                              ; 5B2A
        mov    r5, a                                 ; 5B2B
        cjne   a, 0x06, L_5B38                       ; 5B2C
        cjne   a, 0x07, L_5B33                       ; 5B2F
        ret                                          ; 5B32
L_5B33::
        lcall  nv_addr_copy3                         ; 5B33
        movx   @dptr, a                              ; 5B36
        ret                                          ; 5B37
L_5B38::
        cjne   a, 0x07, L_5B40                       ; 5B38
        lcall  nv_addr_copy2                         ; 5B3B
        movx   @dptr, a                              ; 5B3E
        ret                                          ; 5B3F
L_5B40::
        mov    a, r7                                 ; 5B40
        cjne   a, 0x06, L_5B46                       ; 5B41
        movx   @dptr, a                              ; 5B44
        ret                                          ; 5B45
L_5B46::
        setb   sbit_F0                               ; 5B46
        ret                                          ; 5B48

; 0x03CA + n - 1
nv_addr_copy1::
        mov    sfr_DPH, #0x03                        ; 5B49
        mov    sfr_DPL, #0xCA                        ; 5B4C
        sjmp   L_5B5F                                ; 5B4F

; 0x0599 + n - 1
nv_addr_copy2::
        mov    sfr_DPH, #0x05                        ; 5B51
        mov    sfr_DPL, #0x99                        ; 5B54
        sjmp   L_5B5F                                ; 5B57

; 0x0768 + n - 1
nv_addr_copy3::
        mov    sfr_DPH, #0x07                        ; 5B59
        mov    sfr_DPL, #0x68                        ; 5B5C
L_5B5F::
        mov    r3, 0x02                              ; 5B5F
L_5B61::
        djnz   r3, L_5B64                            ; 5B61
        ret                                          ; 5B63
L_5B64::
        inc    dptr                                  ; 5B64
        sjmp   L_5B61                                ; 5B65

; write A to byte R2 in all three copies
nv_setting_write::
        lcall  nv_addr_copy1                         ; 5B67
        movx   @dptr, a                              ; 5B6A
        lcall  nv_addr_copy2                         ; 5B6B
        movx   @dptr, a                              ; 5B6E
        lcall  nv_addr_copy3                         ; 5B6F
        movx   @dptr, a                              ; 5B72
        ret                                          ; 5B73

; C=1 if seal byte = 'a' (cal data altered): ranges show NC, CDP? items flagged N
cal_seal_check::
        mov    r2, #0x04                             ; 5B74
        lcall  nv_setting_read                       ; 5B76
        jb     sbit_F0, cal_seal_normal              ; 5B79
        cjne   a, #0x61, L_5B81                      ; 5B7C
        setb   c                                     ; 5B7F
        ret                                          ; 5B80
L_5B81::
        cjne   a, #0x4E, cal_seal_normal             ; 5B81
        clr    c                                     ; 5B84
        ret                                          ; 5B85

; CDP R: seal byte = 'N'
cal_seal_normal::
        mov    a, #0x4E                              ; 5B86
        sjmp   L_5B8C                                ; 5B88

; CDP S: seal byte = 'a'
cal_seal_altered::
        mov    a, #0x61                              ; 5B8A
L_5B8C::
        mov    r2, #0x04                             ; 5B8C
        lcall  nv_setting_write                      ; 5B8E
        clr    c                                     ; 5B91
        ret                                          ; 5B92

; validate/repair, default 'A'
rms_get_byte::
        mov    dptr, #x_rms_byte                     ; 5B93
        movx   a, @dptr                              ; 5B96
        mov    r5, a                                 ; 5B97
        inc    dptr                                  ; 5B98
        movx   a, @dptr                              ; 5B99
        mov    r6, a                                 ; 5B9A
        inc    dptr                                  ; 5B9B
        movx   a, @dptr                              ; 5B9C
        clr    c                                     ; 5B9D
        subb   a, #0xAA                              ; 5B9E
        mov    r7, a                                 ; 5BA0
        mov    a, r6                                 ; 5BA1
        clr    c                                     ; 5BA2
        subb   a, #0x55                              ; 5BA3
        mov    r6, a                                 ; 5BA5
        mov    a, r5                                 ; 5BA6
        cjne   a, 0x06, L_5BAE                       ; 5BA7
        cjne   a, 0x07, rms_set_byte                 ; 5BAA
        ret                                          ; 5BAD
L_5BAE::
        cjne   a, 0x07, L_5BB3                       ; 5BAE
        sjmp   rms_set_byte                          ; 5BB1
L_5BB3::
        mov    a, r6                                 ; 5BB3
        cjne   a, 0x07, L_5BB9                       ; 5BB4
        sjmp   rms_set_byte                          ; 5BB7
L_5BB9::
        mov    a, #0x41                              ; 5BB9

; protected byte at 0x07FD (n, n+0x55, n-0x56)
rms_set_byte::
        mov    r5, a                                 ; 5BBB
        mov    dptr, #x_rms_byte                     ; 5BBC
        movx   @dptr, a                              ; 5BBF
        inc    dptr                                  ; 5BC0
        add    a, #0x55                              ; 5BC1
        movx   @dptr, a                              ; 5BC3
        inc    dptr                                  ; 5BC4
        mov    a, r5                                 ; 5BC5
        add    a, #0xAA                              ; 5BC6
        movx   @dptr, a                              ; 5BC8
        mov    a, r5                                 ; 5BC9
        ret                                          ; 5BCA

; XDATA 0x00CC / stabilizer = max
filter_init::
        mov    r0, #0x42                             ; 5BCB
        lcall  i24_ld_max_r0                         ; 5BCD
        inc    r0                                    ; 5BD0
        mov    @r0, #0x00                            ; 5BD1
        mov    dptr, #0x00CC                         ; 5BD3
        lcall  fp_st_r0_xdata                        ; 5BD6
        mov    dptr, #x_stabilize_counter            ; 5BD9
        ljmp   fp_st_r0_xdata                        ; 5BDC
L_5BDF::
        mov    dptr, #0x00CC                         ; 5BDF
        setb   0xF7                                  ; 5BE2
        mov    range_lim_overload, #0x05             ; 5BE4
        mov    0x49, #0x08                           ; 5BE7
        ljmp   L_5C15                                ; 5BEA

; (inferred) running filter on the count, state XDATA 0x00D3/0x00D7
meas_digital_filter::
        mov    a, meter_state                        ; 5BED
        anl    a, #0x0F                              ; 5BEF
        cjne   a, #0x01, L_5C0A                      ; 5BF1
        setb   0xF7                                  ; 5BF4
        mov    dptr, #0x00D7                         ; 5BF6
        mov    range_lim_overload, #0x0F             ; 5BF9
        mov    0x49, #0x14                           ; 5BFC
        ljmp   L_5C15                                ; 5BFF

; last-digit hysteresis against the previous count (XDATA 0x00D3/0x00D4)
display_stabilize::
        mov    a, meter_state                        ; 5C02
        anl    a, #0x0F                              ; 5C04
        cjne   a, #0x0B, L_5C0A                      ; 5C06
        ret                                          ; 5C09
L_5C0A::
        clr    0xF7                                  ; 5C0A
        mov    dptr, #x_stabilize_counter            ; 5C0C
        mov    range_lim_overload, #0x04             ; 5C0F
        mov    0x49, #0x06                           ; 5C12
L_5C15::
        push   sfr_DPH                               ; 5C15
        push   sfr_DPL                               ; 5C17
        movx   a, @dptr                              ; 5C19
        mov    0x4B, a                               ; 5C1A
        inc    dptr                                  ; 5C1C
        mov    r0, #0x42                             ; 5C1D
        lcall  i24_ld_xdata_r0                       ; 5C1F
        mov    r1, #0x4F                             ; 5C22
        mov    r0, #0x46                             ; 5C24
        lcall  i24_copy_r1_to_r0                     ; 5C26
        mov    r1, #0x42                             ; 5C29
        lcall  i24_sub                               ; 5C2B
        lcall  i24_abs_sign_f0                       ; 5C2E
        mov    a, @r0                                ; 5C31
        dec    r0                                    ; 5C32
        orl    a, @r0                                ; 5C33
        jnz    L_5C3D                                ; 5C34
        dec    r0                                    ; 5C36
        mov    a, @r0                                ; 5C37
        cjne   a, range_lim_overload, L_5C3B         ; 5C38
L_5C3B::
        jc     L_5C49                                ; 5C3B
L_5C3D::
        mov    0x4B, #0x00                           ; 5C3D
        mov    r0, #0x42                             ; 5C40
        mov    r1, #0x4F                             ; 5C42
        lcall  i24_copy_r1_to_r0                     ; 5C44
        sjmp   L_5C99                                ; 5C47
L_5C49::
        mov    a, 0x4B                               ; 5C49
        dec    0x4B                                  ; 5C4B
        jnb    0xE7, L_5C54                          ; 5C4D
        inc    0x4B                                  ; 5C50
        inc    0x4B                                  ; 5C52
L_5C54::
        mov    a, 0x44                               ; 5C54
        clr    0xF0                                  ; 5C56
        cjne   a, #0x0A, L_5C5B                      ; 5C58
L_5C5B::
        jc     L_5C62                                ; 5C5B
        jnb    0xF7, L_5C62                          ; 5C5D
        setb   0xF0                                  ; 5C60
L_5C62::
        rl     a                                     ; 5C62
        jnb    sbit_F0, L_5C68                       ; 5C63
        cpl    a                                     ; 5C66
        inc    a                                     ; 5C67
L_5C68::
        add    a, 0x4B                               ; 5C68
        mov    0x4B, a                               ; 5C6A
        jnb    sbit_F0, L_5C73                       ; 5C6C
        cpl    a                                     ; 5C6F
        inc    a                                     ; 5C70
        inc    0x49                                  ; 5C71
L_5C73::
        jb     0xE7, L_5C94                          ; 5C73
        cjne   a, 0x49, L_5C79                       ; 5C76
L_5C79::
        jc     L_5C94                                ; 5C79
        mov    r7, #0x01                             ; 5C7B
        jnb    0xF0, L_5C82                          ; 5C7D
        mov    r7, #0x03                             ; 5C80
L_5C82::
        mov    r1, #0x42                             ; 5C82
L_5C84::
        jb     sbit_F0, L_5C8C                       ; 5C84
        lcall  i24_inc_r1                            ; 5C87
        sjmp   L_5C8F                                ; 5C8A
L_5C8C::
        lcall  i24_dec_r1                            ; 5C8C
L_5C8F::
        djnz   r7, L_5C84                            ; 5C8F
        mov    0x4B, #0x00                           ; 5C91
L_5C94::
        mov    r0, #0x4F                             ; 5C94
        lcall  i24_copy_r1_to_r0                     ; 5C96
L_5C99::
        pop    sfr_DPL                               ; 5C99
        pop    sfr_DPH                               ; 5C9B
        mov    a, 0x4B                               ; 5C9D
        movx   @dptr, a                              ; 5C9F
        mov    r0, #0x42                             ; 5CA0
        inc    dptr                                  ; 5CA2
        lcall  i24_st_r0_xdata                       ; 5CA3
        ret                                          ; 5CA6

; DPTR -> message in table 0x70E4 ('#'-terminated, 11 chars)
lcd_show_message::
        setb   0x34                                  ; 5CA7
        setb   0x21                                  ; 5CA9
        push   sfr_DPL                               ; 5CAB
        push   sfr_DPH                               ; 5CAD
        mov    dptr, #0x009F                         ; 5CAF
        movx   a, @dptr                              ; 5CB2
        anl    a, #0xDF                              ; 5CB3
        movx   @dptr, a                              ; 5CB5
        pop    sfr_DPH                               ; 5CB6
        pop    sfr_DPL                               ; 5CB8

; '#'-terminated ROM string -> lcd_text_buf
lcd_copy_message::
        mov    sfr_B, #0x00                          ; 5CBA
        mov    r2, #0x00                             ; 5CBD
        mov    r3, #0x00                             ; 5CBF
L_5CC1::
        mov    a, sfr_B                              ; 5CC1
        movc   a, @a+dptr                            ; 5CC3
        xch    a, sfr_B                              ; 5CC4
        inc    a                                     ; 5CC6
        xch    a, sfr_B                              ; 5CC7
        xch    a, sfr_DPL                            ; 5CC9
        xch    a, r2                                 ; 5CCB
        xch    a, sfr_DPL                            ; 5CCC
        xch    a, sfr_DPH                            ; 5CCE
        xch    a, r3                                 ; 5CD0
        xch    a, sfr_DPH                            ; 5CD1
        movx   @dptr, a                              ; 5CD3
        inc    dptr                                  ; 5CD4
        xch    a, sfr_DPL                            ; 5CD5
        xch    a, r2                                 ; 5CD7
        xch    a, sfr_DPL                            ; 5CD8
        xch    a, sfr_DPH                            ; 5CDA
        xch    a, r3                                 ; 5CDC
        xch    a, sfr_DPH                            ; 5CDD
        cjne   a, #0x23, L_5CC1                      ; 5CDF
        ret                                          ; 5CE2
L_5CE3::
        mov    dptr, #x_iface_rx_buf                 ; 5CE3
        mov    a, sfr_DPL                            ; 5CE6
        add    a, 0x30                               ; 5CE8
        mov    sfr_DPL, a                            ; 5CEA
        mov    a, sfr_DPH                            ; 5CEC
        addc   a, #0x00                              ; 5CEE
        mov    sfr_DPH, a                            ; 5CF0
        movx   a, @dptr                              ; 5CF2
        inc    0x30                                  ; 5CF3
        ret                                          ; 5CF5

; F0 = sign, x = |x|
i24_abs_sign_f0::
        mov    a, @r0                                ; 5CF6
        mov    c, 0xE7                               ; 5CF7
        mov    sbit_F0, c                            ; 5CF9
        jnb    sbit_F0, L_5D01                       ; 5CFB
        lcall  i24_neg                               ; 5CFE
L_5D01::
        ret                                          ; 5D01

task_5D02::
        mov    a, 0x1D                               ; 5D02
        orl    a, 0x1E                               ; 5D04
        jnz    L_5D09                                ; 5D06
        ret                                          ; 5D08
L_5D09::
        mov    dptr, #x_result_flags                 ; 5D09
        movx   a, @dptr                              ; 5D0C
        mov    sfr_B, a                              ; 5D0D
        mov    a, #0x07                              ; 5D0F
        jbc    0xF0, L_5D16                          ; 5D11
        clr    0xE2                                  ; 5D14
L_5D16::
        jbc    0xF2, L_5D1B                          ; 5D16
        clr    0xE1                                  ; 5D19
L_5D1B::
        jbc    0x1E, L_5D20                          ; 5D1B
        clr    0xE0                                  ; 5D1E
L_5D20::
        xch    a, sfr_B                              ; 5D20
        movx   @dptr, a                              ; 5D22
        xch    a, sfr_B                              ; 5D23
        mov    c, 0xF3                               ; 5D25
        jnz    L_5D2F                                ; 5D27
        push   0x2E                                  ; 5D29
        push   0x2F                                  ; 5D2B
        sjmp   iface_status_compose                  ; 5D2D
L_5D2F::
        setb   0xE5                                  ; 5D2F
        mov    0xE4, c                               ; 5D31
        mov    dptr, #0x00EA                         ; 5D33
        movx   @dptr, a                              ; 5D36

iface_current_poll::
        mov    sfr_DPH, 0x1D                         ; 5D37
        mov    sfr_DPL, 0x1E                         ; 5D3A
        ljmp   iface_send_status_now                 ; 5D3D

; result/trigger state -> interface status byte
iface_report_status::
        mov    a, 0x1D                               ; 5D40
        orl    a, 0x1E                               ; 5D42
        jnz    L_5D47                                ; 5D44
        ret                                          ; 5D46
L_5D47::
        clr    0x20                                  ; 5D47
        mov    dptr, #x_result_flags                 ; 5D49
        movx   a, @dptr                              ; 5D4C
        mov    sfr_B, a                              ; 5D4D
        mov    dptr, #0x00EA                         ; 5D4F
        movx   a, @dptr                              ; 5D52
        push   0x2E                                  ; 5D53
        push   0x2F                                  ; 5D55
        mov    0x2E, a                               ; 5D57
        xrl    a, #0x80                              ; 5D59
        mov    c, 0x20                               ; 5D5B
        sjmp   L_5D72                                ; 5D5D

; status byte: b0 reading/reply pending, b1 24h.6, b4 result flag 3, b7 kept
iface_status_compose::
        mov    a, 0x0B                               ; 5D5F
        mov    c, 0x20                               ; 5D61
        orl    c, 0xE7                               ; 5D63
        mov    dptr, #x_reply_pending_cmd            ; 5D65
        movx   a, @dptr                              ; 5D68
        jz     L_5D6C                                ; 5D69
        setb   c                                     ; 5D6B
L_5D6C::
        mov    dptr, #0x00EA                         ; 5D6C
        movx   a, @dptr                              ; 5D6F
        mov    0x2E, a                               ; 5D70
L_5D72::
        mov    0xE0, c                               ; 5D72
        mov    c, 0xF3                               ; 5D74
        mov    0xE4, c                               ; 5D76
        mov    c, 0x26                               ; 5D78
        mov    0xE1, c                               ; 5D7A
        anl    a, #0x93                              ; 5D7C
        movx   @dptr, a                              ; 5D7E
        xch    a, 0x2E                               ; 5D7F
        cjne   a, 0x2E, L_5D86                       ; 5D81
        sjmp   L_5D89                                ; 5D84
L_5D86::
        lcall  iface_current_poll                    ; 5D86
L_5D89::
        pop    0x2F                                  ; 5D89
        pop    0x2E                                  ; 5D8B
        ret                                          ; 5D8D
L_5D8E::
        ret                                          ; 5D8E
L_5D8F::
        ret                                          ; 5D8F
L_5D90::
        ret                                          ; 5D90

trigger_clear::
        clr    0x24                                  ; 5D91
        clr    trigger_pending                       ; 5D93
        ret                                          ; 5D95

; ZERO key / TRG: sets trigger_pending
task_trigger::
        mov    a, 0x1D                               ; 5D96
        orl    a, 0x1E                               ; 5D98
        jz     L_5DA7                                ; 5D9A
        mov    dptr, #0x00E0                         ; 5D9C
        movx   a, @dptr                              ; 5D9F
        orl    a, rx_count                           ; 5DA0
        anl    a, #0x80                              ; 5DA2
        jz     L_5DA7                                ; 5DA4
        ret                                          ; 5DA6
L_5DA7::
        mov    dptr, #0x00AA                         ; 5DA7
        movx   a, @dptr                              ; 5DAA
        anl    a, #0x80                              ; 5DAB
        jz     L_5DB0                                ; 5DAD
        ret                                          ; 5DAF
L_5DB0::
        clr    0x2A                                  ; 5DB0
        mov    dptr, #0x00EB                         ; 5DB2
        movx   a, @dptr                              ; 5DB5
        rrc    a                                     ; 5DB6
        jnc    L_5DD5                                ; 5DB7
        jnb    cal_mode, L_5DC5                      ; 5DB9
        lcall  cal_step_allowed                      ; 5DBC
        jnc    L_5DC5                                ; 5DBF
        setb   0x1E                                  ; 5DC1
        sjmp   L_5DD3                                ; 5DC3
L_5DC5::
        setb   0x25                                  ; 5DC5
        lcall  trigger_restart_measure               ; 5DC7
        mov    dptr, #0x00EB                         ; 5DCA
        movx   a, @dptr                              ; 5DCD
        anl    a, #0xFE                              ; 5DCE
        movx   @dptr, a                              ; 5DD0
        setb   0x2A                                  ; 5DD1
L_5DD3::
        sjmp   L_5DE7                                ; 5DD3
L_5DD5::
        mov    c, 0x0B                               ; 5DD5
        jnb    0x0A, L_5DDB                          ; 5DD7
        cpl    c                                     ; 5DDA
L_5DDB::
        jnc    L_5DE3                                ; 5DDB
        mov    c, 0x24                               ; 5DDD
        mov    0x2A, c                               ; 5DDF
        sjmp   L_5DE7                                ; 5DE1
L_5DE3::
        mov    c, 0x2C                               ; 5DE3
        mov    0x2A, c                               ; 5DE5
L_5DE7::
        jnb    0x2A, L_5DF0                          ; 5DE7
        clr    0x2C                                  ; 5DEA
        clr    0x24                                  ; 5DEC
        setb   trigger_pending                       ; 5DEE
L_5DF0::
        ret                                          ; 5DF0
L_5DF1::
        ret                                          ; 5DF1

ret_clc::
        clr    c                                     ; 5DF2

ret_nop::
        ret                                          ; 5DF3

; XDATA 0x00EA -> 2Eh/2Fh
iface_ctx_load::
        mov    dptr, #0x00EA                         ; 5DF4
        movx   a, @dptr                              ; 5DF7
        mov    0x2E, a                               ; 5DF8
        inc    dptr                                  ; 5DFA
        movx   a, @dptr                              ; 5DFB
        mov    0x2F, a                               ; 5DFC
        ret                                          ; 5DFE

iface_ctx_save::
        mov    dptr, #0x00EA                         ; 5DFF
        mov    a, 0x2E                               ; 5E02
        movx   @dptr, a                              ; 5E04
        inc    dptr                                  ; 5E05
        mov    a, 0x2F                               ; 5E06
        movx   @dptr, a                              ; 5E08
        ret                                          ; 5E09

parse_number_xdata::
        mov    r6, #0x20                             ; 5E0A
L_5E0C::
        movx   a, @dptr                              ; 5E0C
        inc    dptr                                  ; 5E0D
        mov    r7, a                                 ; 5E0E
        lcall  parse_number_char                     ; 5E0F
        mov    r4, sfr_PSW                           ; 5E12
        cjne   r6, #0x12, L_5E0C                     ; 5E14
        mov    sfr_PSW, r4                           ; 5E17
        ret                                          ; 5E19

; decimal number accumulator used by the command parser
parse_number_char::
        cjne   r7, #0x20, L_5E1E                     ; 5E1A
        ret                                          ; 5E1D
L_5E1E::
        cjne   r6, #0x20, L_5E24                     ; 5E1E
        ljmp   L_5E39                                ; 5E21
L_5E24::
        cjne   r6, #0x21, L_5E2A                     ; 5E24
        ljmp   L_5E5A                                ; 5E27
L_5E2A::
        cjne   r6, #0x22, L_5E30                     ; 5E2A
        ljmp   L_5E5A                                ; 5E2D
L_5E30::
        cjne   r6, #0x23, L_5E36                     ; 5E30
        ljmp   L_5ECD                                ; 5E33
L_5E36::
        ljmp   L_5EE6                                ; 5E36
L_5E39::
        clr    a                                     ; 5E39
        mov    @r0, a                                ; 5E3A
        mov    r2, a                                 ; 5E3B
        mov    r3, a                                 ; 5E3C
        clr    sbit_F0                               ; 5E3D
        cjne   r7, #0x2B, L_5E45                     ; 5E3F
        ljmp   L_5E4A                                ; 5E42
L_5E45::
        cjne   r7, #0x2D, L_5E4D                     ; 5E45
        mov    r2, #0x80                             ; 5E48
L_5E4A::
        mov    r6, #0x21                             ; 5E4A
        ret                                          ; 5E4C
L_5E4D::
        cjne   r7, #0x2E, L_5E53                     ; 5E4D
        ljmp   L_5E58                                ; 5E50
L_5E53::
        lcall  is_digit_r7                           ; 5E53
        jc     L_5EC3                                ; 5E56
L_5E58::
        mov    r6, #0x21                             ; 5E58
L_5E5A::
        cjne   r7, #0x65, L_5E60                     ; 5E5A
        ljmp   L_5E63                                ; 5E5D
L_5E60::
        cjne   r7, #0x45, L_5E69                     ; 5E60
L_5E63::
        cjne   r6, #0x22, L_5EC3                     ; 5E63
        mov    r6, #0x23                             ; 5E66
        ret                                          ; 5E68
L_5E69::
        cjne   r7, #0x2E, L_5E72                     ; 5E69
        jb     sbit_F0, L_5EBB                       ; 5E6C
        setb   sbit_F0                               ; 5E6F
        ret                                          ; 5E71
L_5E72::
        lcall  is_digit_r7                           ; 5E72
        jc     L_5EBB                                ; 5E75
        mov    r7, a                                 ; 5E77
        jnb    sbit_F0, L_5E82                       ; 5E78
        cjne   r3, #0x26, L_5E81                     ; 5E7B
        ljmp   L_5EC3                                ; 5E7E
L_5E81::
        inc    r3                                    ; 5E81
L_5E82::
        mov    a, @r0                                ; 5E82
        jz     L_5E95                                ; 5E83
        mov    a, r3                                 ; 5E85
        push   sfr_ACC                               ; 5E86
        mov    a, #0x01                              ; 5E88
        lcall  fp_ld_pow10_r1                        ; 5E8A
        lcall  fp_mul                                ; 5E8D
        pop    sfr_ACC                               ; 5E90
        mov    r3, a                                 ; 5E92
        jc     L_5EC3                                ; 5E93
L_5E95::
        mov    a, r7                                 ; 5E95
        jz     L_5EB8                                ; 5E96
        dec    r1                                    ; 5E98
        clr    a                                     ; 5E99
        mov    @r1, a                                ; 5E9A
        dec    r1                                    ; 5E9B
        mov    @r1, a                                ; 5E9C
        dec    r1                                    ; 5E9D
        mov    a, r7                                 ; 5E9E
        mov    @r1, a                                ; 5E9F
        inc    r1                                    ; 5EA0
        inc    r1                                    ; 5EA1
        xch    a, r0                                 ; 5EA2
        xch    a, r1                                 ; 5EA3
        xch    a, r0                                 ; 5EA4
        lcall  i24_to_fp                             ; 5EA5
        xch    a, r0                                 ; 5EA8
        xch    a, r1                                 ; 5EA9
        xch    a, r0                                 ; 5EAA
        mov    a, @r0                                ; 5EAB
        jnz    L_5EAF                                ; 5EAC
        mov    a, r2                                 ; 5EAE
L_5EAF::
        anl    a, #0x80                              ; 5EAF
        orl    a, @r1                                ; 5EB1
        mov    @r1, a                                ; 5EB2
        lcall  fp_add                                ; 5EB3
        jc     L_5EC3                                ; 5EB6
L_5EB8::
        mov    r6, #0x22                             ; 5EB8
        ret                                          ; 5EBA
L_5EBB::
        cjne   r6, #0x22, L_5EC3                     ; 5EBB
        mov    @r1, #0x00                            ; 5EBE
        ljmp   L_5EFD                                ; 5EC0
L_5EC3::
        mov    a, #0xFF                              ; 5EC3
        clr    c                                     ; 5EC5
        mov    r6, #0x12                             ; 5EC6
        ret                                          ; 5EC8
L_5EC9::
        mov    a, @r0                                ; 5EC9
        mov    r6, #0x12                             ; 5ECA
        ret                                          ; 5ECC
L_5ECD::
        mov    @r1, #0x00                            ; 5ECD
        clr    sbit_F0                               ; 5ECF
        cjne   r7, #0x2B, L_5ED7                     ; 5ED1
        ljmp   L_5EDC                                ; 5ED4
L_5ED7::
        cjne   r7, #0x2D, L_5EDF                     ; 5ED7
        setb   sbit_F0                               ; 5EDA
L_5EDC::
        mov    r6, #0x24                             ; 5EDC
        ret                                          ; 5EDE
L_5EDF::
        lcall  is_digit_r7                           ; 5EDF
        jc     L_5EC3                                ; 5EE2
        mov    r6, #0x25                             ; 5EE4
L_5EE6::
        lcall  is_digit_r7                           ; 5EE6
        jc     L_5EFA                                ; 5EE9
        xch    a, @r1                                ; 5EEB
        mov    sfr_B, #0x0A                          ; 5EEC
        mul    ab                                    ; 5EEF
        add    a, @r1                                ; 5EF0
        mov    @r1, a                                ; 5EF1
        cjne   @r1, #0x14, L_5EF5                    ; 5EF2
L_5EF5::
        jnc    L_5EC3                                ; 5EF5
        mov    r6, #0x25                             ; 5EF7
        ret                                          ; 5EF9
L_5EFA::
        cjne   r6, #0x25, L_5EC3                     ; 5EFA
L_5EFD::
        mov    a, @r1                                ; 5EFD
        jnb    sbit_F0, L_5F03                       ; 5EFE
        cpl    a                                     ; 5F01
        inc    a                                     ; 5F02
L_5F03::
        clr    c                                     ; 5F03
        subb   a, r3                                 ; 5F04
        jnz    L_5F0D                                ; 5F05
        clr    c                                     ; 5F07
        clr    sbit_OV                               ; 5F08
        ljmp   L_5EC9                                ; 5F0A
L_5F0D::
        jb     0xE7, L_5F19                          ; 5F0D
        lcall  fp_ld_pow10_r1                        ; 5F10
        lcall  fp_mul                                ; 5F13
        ljmp   L_5EC9                                ; 5F16
L_5F19::
        cpl    a                                     ; 5F19
        inc    a                                     ; 5F1A
        cjne   a, #0x14, L_5F1E                      ; 5F1B
L_5F1E::
        jc     L_5F39                                ; 5F1E
        add    a, #0xED                              ; 5F20
        cjne   a, #0x14, L_5F25                      ; 5F22
L_5F25::
        jc     L_5F2F                                ; 5F25
        mov    @r0, #0x00                            ; 5F27
        setb   c                                     ; 5F29
        clr    sbit_OV                               ; 5F2A
        ljmp   L_5EC9                                ; 5F2C
L_5F2F::
        lcall  fp_ld_pow10_r1                        ; 5F2F
        lcall  fp_div                                ; 5F32
        jc     L_5EC9                                ; 5F35
        mov    a, #0x13                              ; 5F37
L_5F39::
        lcall  fp_ld_pow10_r1                        ; 5F39
        lcall  fp_div                                ; 5F3C
        ljmp   L_5EC9                                ; 5F3F

is_digit_r7::
        mov    a, r7                                 ; 5F42
        add    a, #0xC6                              ; 5F43
        jc     L_5F4A                                ; 5F45
        add    a, #0x0A                              ; 5F47
        cpl    c                                     ; 5F49
L_5F4A::
        ret                                          ; 5F4A

; float -> text (E-notation, digits/format in 2Fh/31h/35h)
fp_format::
        mov    r5, a                                 ; 5F4B
        mov    a, r6                                 ; 5F4C
        anl    a, #0x0F                              ; 5F4D
        cjne   a, #0x09, L_5F52                      ; 5F4F
L_5F52::
        jc     L_5F58                                ; 5F52
        mov    a, #0x08                              ; 5F54
        sjmp   L_5F72                                ; 5F56
L_5F58::
        cjne   a, #0x03, L_5F5B                      ; 5F58
L_5F5B::
        jnc    L_5F77                                ; 5F5B
        mov    a, r5                                 ; 5F5D
        jb     0xE4, L_5F6B                          ; 5F5E
        jb     0xE5, L_5F6B                          ; 5F61
        jnb    0xE3, L_5F6B                          ; 5F64
        mov    a, #0x03                              ; 5F67
        sjmp   L_5F72                                ; 5F69
L_5F6B::
        mov    a, r6                                 ; 5F6B
        anl    a, #0x0F                              ; 5F6C
        jnz    L_5F77                                ; 5F6E
        mov    a, #0x01                              ; 5F70
L_5F72::
        xch    a, r6                                 ; 5F72
        anl    a, #0xF0                              ; 5F73
        orl    a, r6                                 ; 5F75
        xch    a, r6                                 ; 5F76
L_5F77::
        add    a, #0x06                              ; 5F77
        mov    r4, a                                 ; 5F79
        mov    a, r6                                 ; 5F7A
        anl    a, #0x0F                              ; 5F7B
        xch    a, r6                                 ; 5F7D
        anl    a, #0xF0                              ; 5F7E
        swap   a                                     ; 5F80
        add    a, #0x07                              ; 5F81
        clr    c                                     ; 5F83
        subb   a, r4                                 ; 5F84
        jc     L_5F8D                                ; 5F85
        mov    r2, a                                 ; 5F87
        mov    a, #0x20                              ; 5F88
        lcall  put_char_repeat                       ; 5F8A
L_5F8D::
        mov    a, @r0                                ; 5F8D
        jnz    L_5F93                                ; 5F8E
        ljmp   L_621C                                ; 5F90
L_5F93::
        clr    0xE7                                  ; 5F93
        mov    r4, a                                 ; 5F95
        mov    sfr_B, #0x10                          ; 5F96
        mul    ab                                    ; 5F99
        mov    r2, a                                 ; 5F9A
        mov    r3, sfr_B                             ; 5F9B
        mov    a, r4                                 ; 5F9D
        mov    sfr_B, #0x4D                          ; 5F9E
        mul    ab                                    ; 5FA1
        add    a, r3                                 ; 5FA2
        mov    r3, a                                 ; 5FA3
        clr    a                                     ; 5FA4
        addc   a, sfr_B                              ; 5FA5
        mov    r4, a                                 ; 5FA7
        clr    c                                     ; 5FA8
        mov    a, r2                                 ; 5FA9
        subb   a, #0xF0                              ; 5FAA
        mov    a, r3                                 ; 5FAC
        subb   a, #0xF6                              ; 5FAD
        mov    a, r4                                 ; 5FAF
        subb   a, #0x12                              ; 5FB0
        mov    r4, a                                 ; 5FB2
        jnb    0xE7, L_5FB8                          ; 5FB3
        cpl    a                                     ; 5FB6
        inc    a                                     ; 5FB7
L_5FB8::
        lcall  fp_ld_pow10_r1                        ; 5FB8
        mov    a, r7                                 ; 5FBB
        push   sfr_ACC                               ; 5FBC
        mov    a, r6                                 ; 5FBE
        push   sfr_ACC                               ; 5FBF
        mov    a, r5                                 ; 5FC1
        push   sfr_ACC                               ; 5FC2
        mov    a, r4                                 ; 5FC4
        push   sfr_ACC                               ; 5FC5
        lcall  fp_push_r0                            ; 5FC7
        mov    a, r4                                 ; 5FCA
        jb     0xE7, L_5FD3                          ; 5FCB
        lcall  fp_div                                ; 5FCE
        sjmp   L_5FD6                                ; 5FD1
L_5FD3::
        lcall  fp_mul                                ; 5FD3
L_5FD6::
        mov    a, @r0                                ; 5FD6
        mov    r4, a                                 ; 5FD7
        clr    0xE7                                  ; 5FD8
        mov    @r0, a                                ; 5FDA
        mov    a, #0x01                              ; 5FDB
        lcall  fp_ld_pow10_r1                        ; 5FDD
        lcall  fp_cmp                                ; 5FE0
        mov    a, r4                                 ; 5FE3
        mov    @r0, a                                ; 5FE4
        jc     L_6007                                ; 5FE5
        lcall  fp_clr_r0                             ; 5FE7
        pop    sfr_ACC                               ; 5FEA
        inc    a                                     ; 5FEC
        push   sfr_ACC                               ; 5FED
        mov    r4, a                                 ; 5FEF
        mov    a, r4                                 ; 5FF0
        jnb    0xE7, L_5FF6                          ; 5FF1
        cpl    a                                     ; 5FF4
        inc    a                                     ; 5FF5
L_5FF6::
        lcall  fp_ld_pow10_r1                        ; 5FF6
        mov    a, r4                                 ; 5FF9
        jb     0xE7, L_6002                          ; 5FFA
        lcall  fp_div                                ; 5FFD
        sjmp   L_600A                                ; 6000
L_6002::
        lcall  fp_mul                                ; 6002
        sjmp   L_600A                                ; 6005
L_6007::
        lcall  fp_clr_r1                             ; 6007
L_600A::
        mov    a, r5                                 ; 600A
        mov    r3, a                                 ; 600B
        pop    sfr_ACC                               ; 600C
        mov    r4, a                                 ; 600E
        pop    sfr_ACC                               ; 600F
        mov    r5, a                                 ; 6011
        pop    sfr_ACC                               ; 6012
        mov    r6, a                                 ; 6014
        pop    sfr_ACC                               ; 6015
        mov    r7, a                                 ; 6017
        mov    a, r3                                 ; 6018
        push   sfr_ACC                               ; 6019
        mov    a, r5                                 ; 601B
        jnb    0xE4, L_6034                          ; 601C
        anl    a, #0x0F                              ; 601F
        mov    r2, a                                 ; 6021
        mov    a, r6                                 ; 6022
        clr    c                                     ; 6023
        subb   a, r2                                 ; 6024
        jnc    L_602E                                ; 6025
        mov    a, r5                                 ; 6027
        anl    a, #0xF0                              ; 6028
        orl    a, r6                                 ; 602A
        mov    r5, a                                 ; 602B
        clr    a                                     ; 602C
        clr    c                                     ; 602D
L_602E::
        mov    r3, a                                 ; 602E
        mov    a, r4                                 ; 602F
        subb   a, r3                                 ; 6030
        inc    a                                     ; 6031
        mov    r4, a                                 ; 6032
        mov    a, r5                                 ; 6033
L_6034::
        jb     0xE5, L_605F                          ; 6034
        jb     0xE4, L_6096                          ; 6037
        jnb    0xE3, L_605B                          ; 603A
        mov    a, r4                                 ; 603D
        jnb    0xE7, L_6043                          ; 603E
        cpl    a                                     ; 6041
        inc    a                                     ; 6042
L_6043::
        mov    sfr_B, #0x03                          ; 6043
        div    ab                                    ; 6046
        mov    a, sfr_B                              ; 6047
        jz     L_6054                                ; 6049
        mov    sfr_B, r4                             ; 604B
        jnb    0xF7, L_6054                          ; 604D
        mov    r2, #0x03                             ; 6050
        xch    a, r2                                 ; 6052
        subb   a, r2                                 ; 6053
L_6054::
        mov    r3, a                                 ; 6054
        inc    r3                                    ; 6055
        xch    a, r4                                 ; 6056
        subb   a, r4                                 ; 6057
        mov    r4, a                                 ; 6058
        sjmp   L_6096                                ; 6059
L_605B::
        mov    r3, #0x01                             ; 605B
        sjmp   L_6096                                ; 605D
L_605F::
        mov    a, r4                                 ; 605F
        clr    c                                     ; 6060
        subb   a, r7                                 ; 6061
        mov    r2, a                                 ; 6062
        mov    a, r5                                 ; 6063
        jb     0xE4, L_6092                          ; 6064
        mov    a, r2                                 ; 6067
        jnb    0xE7, L_607F                          ; 6068
        mov    r3, #0x00                             ; 606B
        inc    r4                                    ; 606D
        inc    a                                     ; 606E
L_606F::
        add    a, r6                                 ; 606F
        jnb    0xE7, L_6078                          ; 6070
        pop    sfr_ACC                               ; 6073
        ljmp   L_621C                                ; 6075
L_6078::
        swap   a                                     ; 6078
        orl    a, r6                                 ; 6079
        mov    r6, a                                 ; 607A
        mov    a, r7                                 ; 607B
        mov    r4, a                                 ; 607C
        sjmp   L_609A                                ; 607D
L_607F::
        subb   a, r6                                 ; 607F
        jnb    0xE7, L_608A                          ; 6080
        mov    a, r2                                 ; 6083
        inc    a                                     ; 6084
        mov    r3, a                                 ; 6085
        mov    a, r7                                 ; 6086
        mov    r4, a                                 ; 6087
        sjmp   L_6096                                ; 6088
L_608A::
        mov    a, r6                                 ; 608A
        mov    r3, a                                 ; 608B
        mov    a, r4                                 ; 608C
        subb   a, r6                                 ; 608D
        inc    a                                     ; 608E
        mov    r4, a                                 ; 608F
        sjmp   L_6096                                ; 6090
L_6092::
        mov    a, r2                                 ; 6092
        jb     0xE7, L_606F                          ; 6093
L_6096::
        mov    a, r6                                 ; 6096
        swap   a                                     ; 6097
        orl    a, r6                                 ; 6098
        mov    r6, a                                 ; 6099
L_609A::
        mov    a, r6                                 ; 609A
        anl    a, #0xF0                              ; 609B
        swap   a                                     ; 609D
        cpl    a                                     ; 609E
        add    a, #0x02                              ; 609F
        lcall  fp_ld_pow10_r1                        ; 60A1
        dec    @r1                                   ; 60A4
        pop    sfr_ACC                               ; 60A5
        xch    a, r5                                 ; 60A7
        push   sfr_ACC                               ; 60A8
        mov    a, @r0                                ; 60AA
        clr    c                                     ; 60AB
        subb   a, @r1                                ; 60AC
        xrl    a, #0x18                              ; 60AD
        jnz    L_612D                                ; 60AF
        mov    a, r4                                 ; 60B1
        push   sfr_ACC                               ; 60B2
        mov    a, r3                                 ; 60B4
        push   sfr_ACC                               ; 60B5
        lcall  fp_push_r0                            ; 60B7
        cjne   r5, #0x80, L_60BF                     ; 60BA
        mov    r5, #0x00                             ; 60BD
L_60BF::
        mov    a, r5                                 ; 60BF
        mov    r4, a                                 ; 60C0
        jc     L_60C7                                ; 60C1
        mov    a, r5                                 ; 60C3
        cpl    a                                     ; 60C4
        inc    a                                     ; 60C5
        mov    r5, a                                 ; 60C6
L_60C7::
        mov    a, #0x06                              ; 60C7
        lcall  fp_ld_pow10_r1                        ; 60C9
        dec    r1                                    ; 60CC
        mov    a, r5                                 ; 60CD
        mov    @r0, a                                ; 60CE
        xch    a, r0                                 ; 60CF
        xch    a, r1                                 ; 60D0
        xch    a, r0                                 ; 60D1
        lcall  i24_div10_rem                         ; 60D2
        lcall  i24_shr8_ins_a                        ; 60D5
        lcall  i24_shr1                              ; 60D8
        lcall  i24_shr1                              ; 60DB
        lcall  i24_shr1                              ; 60DE
        mov    a, @r0                                ; 60E1
        mov    r5, a                                 ; 60E2
        xch    a, r0                                 ; 60E3
        xch    a, r1                                 ; 60E4
        xch    a, r0                                 ; 60E5
        inc    r1                                    ; 60E6
        lcall  fp_clr_r0                             ; 60E7
        lcall  fp_push_r0                            ; 60EA
        mov    a, r4                                 ; 60ED
        push   sfr_ACC                               ; 60EE
        mov    a, r5                                 ; 60F0
        push   sfr_ACC                               ; 60F1
        mov    a, #0x06                              ; 60F3
        lcall  fp_ld_pow10_r1                        ; 60F5
        dec    r0                                    ; 60F8
        dec    r1                                    ; 60F9
        lcall  mant_mul24                            ; 60FA
        inc    r0                                    ; 60FD
        inc    r1                                    ; 60FE
        pop    sfr_ACC                               ; 60FF
        mov    sfr_B, a                              ; 6101
        pop    sfr_ACC                               ; 6103
        mov    r4, a                                 ; 6105
        lcall  fp_clr_r0                             ; 6106
        cjne   r4, #0x80, L_610C                     ; 6109
L_610C::
        jc     L_611D                                ; 610C
        mov    a, r5                                 ; 610E
        subb   a, sfr_B                              ; 610F
        jc     L_6124                                ; 6111
        jnb    0xE7, L_6124                          ; 6113
L_6116::
        dec    r0                                    ; 6116
        lcall  i24_inc_r0                            ; 6117
        inc    r0                                    ; 611A
        sjmp   L_6124                                ; 611B
L_611D::
        mov    a, r5                                 ; 611D
        add    a, sfr_B                              ; 611E
        orl    c, 0xE7                               ; 6120
        jc     L_6116                                ; 6122
L_6124::
        pop    sfr_ACC                               ; 6124
        mov    r3, a                                 ; 6126
        pop    sfr_ACC                               ; 6127
        mov    r4, a                                 ; 6129
        setb   c                                     ; 612A
        sjmp   L_6168                                ; 612B
L_612D::
        mov    a, @r0                                ; 612D
        mov    c, 0xE7                               ; 612E
        mov    0xF7, c                               ; 6130
        clr    0xE7                                  ; 6132
        mov    @r0, a                                ; 6134
        lcall  fp_add                                ; 6135
        mov    a, #0x01                              ; 6138
        lcall  fp_ld_pow10_r1                        ; 613A
        lcall  fp_cmp                                ; 613D
        mov    0xF0, c                               ; 6140
        mov    c, 0xF7                               ; 6142
        mov    a, @r0                                ; 6144
        mov    0xE7, c                               ; 6145
        mov    @r0, a                                ; 6147
        mov    c, 0xF0                               ; 6148
        jc     L_6168                                ; 614A
        mov    a, r7                                 ; 614C
        push   sfr_ACC                               ; 614D
        mov    a, r6                                 ; 614F
        push   sfr_ACC                               ; 6150
        mov    a, r4                                 ; 6152
        push   sfr_ACC                               ; 6153
        mov    a, r3                                 ; 6155
        push   sfr_ACC                               ; 6156
        lcall  fp_div                                ; 6158
        clr    c                                     ; 615B
        pop    sfr_ACC                               ; 615C
        mov    r3, a                                 ; 615E
        pop    sfr_ACC                               ; 615F
        mov    r4, a                                 ; 6161
        pop    sfr_ACC                               ; 6162
        mov    r6, a                                 ; 6164
        pop    sfr_ACC                               ; 6165
        mov    r7, a                                 ; 6167
L_6168::
        pop    sfr_ACC                               ; 6168
        mov    r5, a                                 ; 616A
        mov    a, r6                                 ; 616B
        anl    a, #0x0F                              ; 616C
        xch    a, r6                                 ; 616E
        anl    a, #0xF0                              ; 616F
        swap   a                                     ; 6171
        xch    a, r7                                 ; 6172
        mov    r2, a                                 ; 6173
        jc     L_61A9                                ; 6174
        mov    a, r5                                 ; 6176
        jb     0xE4, L_618D                          ; 6177
        jb     0xE5, L_618D                          ; 617A
        jnb    0xE3, L_61A8                          ; 617D
        cjne   r3, #0x03, L_618A                     ; 6180
        mov    r3, #0x01                             ; 6183
        inc    r4                                    ; 6185
        inc    r4                                    ; 6186
        inc    r4                                    ; 6187
        sjmp   L_61A9                                ; 6188
L_618A::
        inc    r3                                    ; 618A
        sjmp   L_61A9                                ; 618B
L_618D::
        jnb    0xE5, L_61A8                          ; 618D
        mov    a, r4                                 ; 6190
        xrl    a, r2                                 ; 6191
        jnz    L_61A8                                ; 6192
        mov    a, r5                                 ; 6194
        jb     0xE4, L_61A0                          ; 6195
        mov    a, r3                                 ; 6198
        clr    c                                     ; 6199
        subb   a, r6                                 ; 619A
        jnc    L_61A0                                ; 619B
        inc    r3                                    ; 619D
        sjmp   L_61A9                                ; 619E
L_61A0::
        mov    a, r7                                 ; 61A0
        clr    c                                     ; 61A1
        subb   a, r6                                 ; 61A2
        jnc    L_61A8                                ; 61A3
        inc    r7                                    ; 61A5
        sjmp   L_61A9                                ; 61A6
L_61A8::
        inc    r4                                    ; 61A8
L_61A9::
        mov    a, r7                                 ; 61A9
        jz     L_621A                                ; 61AA
        mov    @r1, #0x0A                            ; 61AC
        mov    a, @r0                                ; 61AE
        clr    0xE7                                  ; 61AF
        add    a, #0xC2                              ; 61B1
        mov    r2, a                                 ; 61B3
        clr    a                                     ; 61B4
        dec    r0                                    ; 61B5
L_61B6::
        lcall  clc_thunk                             ; 61B6
        rlc    a                                     ; 61B9
        djnz   r2, L_61B6                            ; 61BA
        inc    r0                                    ; 61BC
        add    a, #0x30                              ; 61BD
        mov    sfr_B, a                              ; 61BF
        mov    a, r7                                 ; 61C1
        add    a, r3                                 ; 61C2
        clr    c                                     ; 61C3
        subb   a, r6                                 ; 61C4
        jc     L_61F6                                ; 61C5
        jz     L_61F6                                ; 61C7
        mov    a, r6                                 ; 61C9
        subb   a, r7                                 ; 61CA
        mov    r2, a                                 ; 61CB
        lcall  put_pad                               ; 61CC
        mov    a, sfr_B                              ; 61CF
        lcall  put_char_dptr                         ; 61D1
        mov    a, r3                                 ; 61D4
        add    a, r7                                 ; 61D5
        clr    c                                     ; 61D6
        subb   a, r6                                 ; 61D7
        mov    r3, a                                 ; 61D8
        cjne   a, #0x01, L_61E1                      ; 61D9
        mov    a, #0x2E                              ; 61DC
        lcall  put_char_dptr                         ; 61DE
L_61E1::
        mov    r2, #0x01                             ; 61E1
L_61E3::
        mov    a, r7                                 ; 61E3
        xrl    a, r2                                 ; 61E4
        jz     L_6244                                ; 61E5
        inc    r2                                    ; 61E7
        lcall  put_digit                             ; 61E8
        mov    a, r3                                 ; 61EB
        xrl    a, r2                                 ; 61EC
        jnz    L_61E3                                ; 61ED
        mov    a, #0x2E                              ; 61EF
        lcall  put_char_dptr                         ; 61F1
        sjmp   L_61E3                                ; 61F4
L_61F6::
        mov    a, r3                                 ; 61F6
        mov    r2, a                                 ; 61F7
        lcall  put_pad                               ; 61F8
        mov    a, #0x2E                              ; 61FB
        lcall  put_char_dptr                         ; 61FD
        mov    a, r6                                 ; 6200
        clr    c                                     ; 6201
        subb   a, r3                                 ; 6202
        subb   a, r7                                 ; 6203
        mov    r2, a                                 ; 6204
        mov    a, #0x30                              ; 6205
        lcall  put_char_repeat                       ; 6207
        mov    a, sfr_B                              ; 620A
        lcall  put_char_dptr                         ; 620C
        dec    r7                                    ; 620F
        mov    a, r7                                 ; 6210
        jz     L_6244                                ; 6211
L_6213::
        lcall  put_digit                             ; 6213
        djnz   r7, L_6213                            ; 6216
        sjmp   L_6244                                ; 6218
L_621A::
        mov    a, r2                                 ; 621A
        mov    r7, a                                 ; 621B
L_621C::
        mov    a, r5                                 ; 621C
        jb     0xE4, L_6225                          ; 621D
        lcall  put_sign_char                         ; 6220
        sjmp   L_622E                                ; 6223
L_6225::
        anl    a, #0x0F                              ; 6225
        xch    a, r6                                 ; 6227
        clr    c                                     ; 6228
        subb   a, r6                                 ; 6229
        mov    r2, a                                 ; 622A
        lcall  put_pad                               ; 622B
L_622E::
        mov    a, #0x2E                              ; 622E
        lcall  put_char_dptr                         ; 6230
        mov    a, r6                                 ; 6233
        mov    r2, a                                 ; 6234
        mov    a, #0x30                              ; 6235
        lcall  put_char_repeat                       ; 6237
        mov    a, r5                                 ; 623A
        jnb    0xE5, L_6242                          ; 623B
        mov    a, r7                                 ; 623E
        mov    r4, a                                 ; 623F
        sjmp   L_6244                                ; 6240
L_6242::
        mov    r4, #0x00                             ; 6242
L_6244::
        mov    a, #0x45                              ; 6244
        lcall  put_char_dptr                         ; 6246
        mov    a, r4                                 ; 6249
        jb     0xE7, L_6254                          ; 624A
        mov    a, #0x2B                              ; 624D
        lcall  put_char_dptr                         ; 624F
        sjmp   L_6259                                ; 6252
L_6254::
        mov    a, #0x2D                              ; 6254
        lcall  put_char_dptr                         ; 6256
L_6259::
        mov    a, r4                                 ; 6259
        jnb    0xE7, L_625F                          ; 625A
        cpl    a                                     ; 625D
        inc    a                                     ; 625E
L_625F::
        mov    sfr_B, #0x0A                          ; 625F
        div    ab                                    ; 6262
        add    a, #0x30                              ; 6263
        lcall  put_char_dptr                         ; 6265
        mov    a, sfr_B                              ; 6268
        add    a, #0x30                              ; 626A
        lcall  put_char_dptr                         ; 626C
        ret                                          ; 626F

; '-' or '+' (R5.6)
put_sign_char::
        mov    a, @r0                                ; 6270
        jnb    0xE7, L_6278                          ; 6271
        mov    a, #0x2D                              ; 6274
        sjmp   put_char_dptr                         ; 6276
L_6278::
        mov    a, r5                                 ; 6278
        jnb    0xE6, L_6280                          ; 6279
        mov    a, #0x2B                              ; 627C
        sjmp   put_char_dptr                         ; 627E
L_6280::
        mov    a, #0x20                              ; 6280
        sjmp   put_char_dptr                         ; 6282

put_digit::
        dec    r0                                    ; 6284
        lcall  i24_div10_rem                         ; 6285
        inc    r0                                    ; 6288
        add    a, #0x30                              ; 6289

; MOVX @DPTR,A; INC DPTR
put_char_dptr::
        movx   @dptr, a                              ; 628B
        inc    dptr                                  ; 628C
        ret                                          ; 628D
L_628E::
        xch    a, sfr_DPL                            ; 628E
        jnz    L_6294                                ; 6290
        dec    sfr_DPH                               ; 6292
L_6294::
        dec    a                                     ; 6294
        xch    a, sfr_DPL                            ; 6295
        movx   a, @dptr                              ; 6297
        ret                                          ; 6298

put_pad::
        mov    a, r5                                 ; 6299
        jb     0xE7, L_62A4                          ; 629A
        mov    a, #0x20                              ; 629D
        lcall  put_char_repeat                       ; 629F
        sjmp   put_sign_char                         ; 62A2
L_62A4::
        lcall  put_sign_char                         ; 62A4
        mov    a, #0x30                              ; 62A7

put_char_repeat::
        xch    a, r2                                 ; 62A9
        jz     L_62B2                                ; 62AA
        xch    a, r2                                 ; 62AC
L_62AD::
        lcall  put_char_dptr                         ; 62AD
        djnz   r2, L_62AD                            ; 62B0
L_62B2::
        ret                                          ; 62B2

; round half away from zero, C=1 if result 0
fp_to_i24_round::
        clr    c                                     ; 62B3
        mov    a, @r0                                ; 62B4
        dec    r0                                    ; 62B5
        jnz    L_62BC                                ; 62B6
L_62B8::
        lcall  i24_clr_r0                            ; 62B8
        ret                                          ; 62BB
L_62BC::
        clr    0xE7                                  ; 62BC
        subb   a, #0x3E                              ; 62BE
        jnc    L_62C6                                ; 62C0
        clr    sbit_OV                               ; 62C2
        sjmp   L_62B8                                ; 62C4
L_62C6::
        subb   a, #0x18                              ; 62C6
        jc     L_62DA                                ; 62C8
        lcall  i24_ld_max_r0                         ; 62CA
        inc    r0                                    ; 62CD
        mov    a, @r0                                ; 62CE
        dec    r0                                    ; 62CF
        jnb    0xE7, L_62D6                          ; 62D0
        lcall  i24_neg                               ; 62D3
L_62D6::
        setb   c                                     ; 62D6
        setb   sbit_OV                               ; 62D7
        ret                                          ; 62D9
L_62DA::
        cpl    a                                     ; 62DA
        inc    a                                     ; 62DB
        mov    r5, #0x00                             ; 62DC
L_62DE::
        add    a, #0xF8                              ; 62DE
        jnc    L_62F0                                ; 62E0
        lcall  i24_shr8_ins_a                        ; 62E2
        xch    a, r5                                 ; 62E5
        jz     L_62ED                                ; 62E6
        mov    a, #0x01                              ; 62E8
        orl    a, r5                                 ; 62EA
        mov    r5, a                                 ; 62EB
        clr    a                                     ; 62EC
L_62ED::
        xch    a, @r0                                ; 62ED
        sjmp   L_62DE                                ; 62EE
L_62F0::
        add    a, #0x08                              ; 62F0
        jz     L_6301                                ; 62F2
L_62F4::
        lcall  i24_shr1                              ; 62F4
        xch    a, r5                                 ; 62F7
        rrc    a                                     ; 62F8
        orl    c, 0xE0                               ; 62F9
        mov    0xE0, c                               ; 62FB
        xch    a, r5                                 ; 62FD
        dec    a                                     ; 62FE
        jnz    L_62F4                                ; 62FF
L_6301::
        lcall  i24_round_r5                          ; 6301
        mov    a, @r0                                ; 6304
        jnb    0xE7, L_630D                          ; 6305
        lcall  i24_ld_max_r0                         ; 6308
        sjmp   L_6312                                ; 630B
L_630D::
        lcall  i24_test_r0                           ; 630D
        jz     L_631B                                ; 6310
L_6312::
        inc    r0                                    ; 6312
        mov    a, @r0                                ; 6313
        dec    r0                                    ; 6314
        jnb    0xE7, L_631B                          ; 6315
        lcall  i24_neg                               ; 6318
L_631B::
        clr    c                                     ; 631B
        ret                                          ; 631C

; in place, result 1 byte longer (R0 + 1)
i24_to_fp::
        lcall  i24_test_r0                           ; 631D
        jnz    L_6327                                ; 6320
        mov    @r0, #0x80                            ; 6322
        inc    r0                                    ; 6324
        mov    @r0, a                                ; 6325
        ret                                          ; 6326
L_6327::
        mov    a, @r0                                ; 6327
        rlc    a                                     ; 6328
        jnc    L_632F                                ; 6329
        lcall  i24_neg                               ; 632B
        setb   c                                     ; 632E
L_632F::
        clr    a                                     ; 632F
        rrc    a                                     ; 6330
        add    a, #0x56                              ; 6331
        inc    r0                                    ; 6333
        mov    @r0, a                                ; 6334
        dec    r0                                    ; 6335
L_6336::
        mov    a, @r0                                ; 6336
        jnz    L_6345                                ; 6337
        lcall  i24_shl8_ins_a                        ; 6339
        inc    r0                                    ; 633C
        clr    c                                     ; 633D
        mov    a, @r0                                ; 633E
        subb   a, #0x08                              ; 633F
        mov    @r0, a                                ; 6341
        dec    r0                                    ; 6342
        sjmp   L_6336                                ; 6343
L_6345::
        jb     0xE7, L_6351                          ; 6345
        lcall  clc_thunk                             ; 6348
        inc    r0                                    ; 634B
        dec    @r0                                   ; 634C
        dec    r0                                    ; 634D
        mov    a, @r0                                ; 634E
        sjmp   L_6345                                ; 634F
L_6351::
        inc    r0                                    ; 6351
        mov    a, @r0                                ; 6352
        ret                                          ; 6353

; A=addr: start+addr(R), read 1 byte w/ NACK, stop. C=1 on no-ack
i2cA_read1::
        lcall  i2cA_start_read                       ; 6354
        jc     L_6360                                ; 6357

i2cA_recv_nack_stop::
        lcall  i2cA_recv_byte                        ; 6359

i2cA_nack_stop::
        lcall  i2cA_read_ack_bit                     ; 635C
        clr    c                                     ; 635F
L_6360::
        ljmp   i2cA_stop                             ; 6360

; A=addr, R3=data: start+addr(W), send, stop
i2cA_write1::
        lcall  i2cA_start_write                      ; 6363
        jc     L_636C                                ; 6366
        mov    a, r3                                 ; 6368

; send A then stop
i2cA_send_stop::
        lcall  i2cA_send_byte                        ; 6369
L_636C::
        ljmp   i2cA_stop                             ; 636C
L_636F::
        nop                                          ; 636F
        setb   sbit_INT0                             ; 6370
        nop                                          ; 6372
        nop                                          ; 6373
L_6374::
        jnb    sbit_INT0, L_6374                     ; 6374

; start + addr (R/W=0); C=1 if NACK
i2cA_start_write::
        clr    0xE0                                  ; 6377
        ljmp   L_638A                                ; 6379
L_637C::
        nop                                          ; 637C
        setb   0x91                                  ; 637D
        nop                                          ; 637F
        setb   sbit_INT0                             ; 6380
        nop                                          ; 6382
        nop                                          ; 6383
L_6384::
        jnb    sbit_INT0, L_6384                     ; 6384
        nop                                          ; 6387

; start + addr (R/W=1); C=1 if NACK
i2cA_start_read::
        setb   0xE0                                  ; 6388
L_638A::
        clr    0x91                                  ; 638A
        nop                                          ; 638C
        nop                                          ; 638D
        nop                                          ; 638E
        nop                                          ; 638F
        clr    sbit_INT0                             ; 6390
        nop                                          ; 6392
        ljmp   i2cA_send_byte                        ; 6393
L_6396::
        mov    a, @r0                                ; 6396

; 8 bits MSB first, waits for clock stretching, returns ACK in C
i2cA_send_byte::
        mov    r2, #0x08                             ; 6397
L_6399::
        rlc    a                                     ; 6399
        mov    0x91, c                               ; 639A
        nop                                          ; 639C
        setb   sbit_INT0                             ; 639D
        nop                                          ; 639F
        nop                                          ; 63A0
L_63A1::
        jnb    sbit_INT0, L_63A1                     ; 63A1
        nop                                          ; 63A4
        nop                                          ; 63A5
        clr    sbit_INT0                             ; 63A6
        nop                                          ; 63A8
        djnz   r2, L_6399                            ; 63A9
        rlc    a                                     ; 63AB
        nop                                          ; 63AC

i2cA_read_ack_bit::
        setb   0x91                                  ; 63AD
        ljmp   L_63B2                                ; 63AF
L_63B2::
        ljmp   L_63B5                                ; 63B2
L_63B5::
        ljmp   L_63B8                                ; 63B5
L_63B8::
        nop                                          ; 63B8
        setb   sbit_INT0                             ; 63B9
        nop                                          ; 63BB
        nop                                          ; 63BC
L_63BD::
        jnb    sbit_INT0, L_63BD                     ; 63BD
        nop                                          ; 63C0
        nop                                          ; 63C1
        mov    c, 0x91                               ; 63C2
        clr    sbit_INT0                             ; 63C4
        nop                                          ; 63C6
        ret                                          ; 63C7

i2cA_stop::
        clr    0x91                                  ; 63C8
        nop                                          ; 63CA
        setb   sbit_INT0                             ; 63CB
        nop                                          ; 63CD
        nop                                          ; 63CE
L_63CF::
        jnb    sbit_INT0, L_63CF                     ; 63CF
        nop                                          ; 63D2
        nop                                          ; 63D3
        setb   0x91                                  ; 63D4
        nop                                          ; 63D6
        ret                                          ; 63D7
L_63D8::
        lcall  i2cA_start_read                       ; 63D8
        jc     L_63F9                                ; 63DB

; receive byte then send ACK
i2cA_recv_ack::
        lcall  i2cA_recv_byte                        ; 63DD
        clr    c                                     ; 63E0

i2cA_send_ack::
        clr    0x91                                  ; 63E1
        ljmp   L_63E6                                ; 63E3
L_63E6::
        ljmp   L_63E9                                ; 63E6
L_63E9::
        ljmp   L_63EC                                ; 63E9
L_63EC::
        nop                                          ; 63EC
        setb   sbit_INT0                             ; 63ED
        nop                                          ; 63EF
        nop                                          ; 63F0
L_63F1::
        jnb    sbit_INT0, L_63F1                     ; 63F1
        nop                                          ; 63F4
        nop                                          ; 63F5
        clr    sbit_INT0                             ; 63F6
        nop                                          ; 63F8
L_63F9::
        ret                                          ; 63F9

i2cA_recv_byte::
        mov    r2, #0x08                             ; 63FA
        setb   0x91                                  ; 63FC
        ljmp   L_6401                                ; 63FE
L_6401::
        ljmp   L_6404                                ; 6401
L_6404::
        nop                                          ; 6404
        nop                                          ; 6405
        setb   sbit_INT0                             ; 6406
        nop                                          ; 6408
        nop                                          ; 6409
L_640A::
        jnb    sbit_INT0, L_640A                     ; 640A
        nop                                          ; 640D
        mov    c, 0x91                               ; 640E
        clr    sbit_INT0                             ; 6410
        nop                                          ; 6412
        rlc    a                                     ; 6413
        djnz   r2, L_6404                            ; 6414
        ret                                          ; 6416

; verified: 10 -> 3.162278, 2 -> 1.414214
fp_sqrt::
        mov    sfr_B, a                              ; 6417
        clr    c                                     ; 6419
        mov    a, @r0                                ; 641A
        jz     L_645C                                ; 641B
        clr    0xE7                                  ; 641D
        mov    @r0, a                                ; 641F
        add    a, #0xC1                              ; 6420
        clr    0xE0                                  ; 6422
        push   sfr_ACC                               ; 6424
        cpl    a                                     ; 6426
        inc    a                                     ; 6427
        add    a, @r0                                ; 6428
        mov    @r0, a                                ; 6429
        mov    @r1, #0x3F                            ; 642A
        dec    r1                                    ; 642C
        mov    @r1, #0xB5                            ; 642D
        dec    r1                                    ; 642F
        mov    @r1, #0x04                            ; 6430
        dec    r1                                    ; 6432
        mov    @r1, #0xF3                            ; 6433
        inc    r1                                    ; 6435
        inc    r1                                    ; 6436
        inc    r1                                    ; 6437
        lcall  fp_push_r0                            ; 6438
L_643B::
        lcall  fp_clr_r0                             ; 643B
        lcall  fp_push_r0                            ; 643E
        lcall  fp_div                                ; 6441
        lcall  fp_add                                ; 6444
        dec    @r0                                   ; 6447
        lcall  fp_swap                               ; 6448
        djnz   sfr_B, L_643B                         ; 644B
        lcall  fp_clr_r0                             ; 644E
        lcall  fp_swap                               ; 6451
        pop    sfr_ACC                               ; 6454
        mov    c, 0xE7                               ; 6456
        rrc    a                                     ; 6458
        add    a, @r0                                ; 6459
        mov    @r0, a                                ; 645A
        clr    c                                     ; 645B
L_645C::
        ret                                          ; 645C

; ln(x) * 0.4342945
fp_log10::
        lcall  fp_ln                                 ; 645D
        mov    dptr, #T_6547                         ; 6460
        lcall  fp_ld_code_r1                         ; 6463
        lcall  fp_mul                                ; 6466
        ret                                          ; 6469

fp_ln::
        mov    sfr_B, a                              ; 646A
        mov    a, @r0                                ; 646C
        clr    0xE7                                  ; 646D
        jnz    L_647C                                ; 646F
        lcall  fp_ld_max_r0                          ; 6471
        mov    a, @r0                                ; 6474
        setb   0xE7                                  ; 6475
        mov    @r0, a                                ; 6477
        setb   c                                     ; 6478
        setb   sbit_OV                               ; 6479
        ret                                          ; 647B
L_647C::
        add    a, #0xC1                              ; 647C
        push   sfr_ACC                               ; 647E
        mov    @r0, #0x3F                            ; 6480
        dec    r0                                    ; 6482
        mov    a, @r0                                ; 6483
        clr    c                                     ; 6484
        subb   a, #0xA1                              ; 6485
        jnc    L_648C                                ; 6487
        clr    a                                     ; 6489
        sjmp   L_6496                                ; 648A
L_648C::
        subb   a, #0x2A                              ; 648C
        jnc    L_6494                                ; 648E
        mov    a, #0x01                              ; 6490
        sjmp   L_6496                                ; 6492
L_6494::
        mov    a, #0x02                              ; 6494
L_6496::
        mov    dptr, #T_654B                         ; 6496
        rl     a                                     ; 6499
        rl     a                                     ; 649A
        push   sfr_ACC                               ; 649B
        lcall  dptr_add_a_b                          ; 649D
        lcall  fp_ld_code_r1                         ; 64A0
        inc    r0                                    ; 64A3
        lcall  fp_push_r0                            ; 64A4
        lcall  fp_add                                ; 64A7
        lcall  fp_clr_r1                             ; 64AA
        inc    @r1                                   ; 64AD
        lcall  fp_push_r0                            ; 64AE
        lcall  fp_sub                                ; 64B1
        lcall  fp_clr_r1                             ; 64B4
        push   sfr_B                                 ; 64B7
        lcall  fp_div                                ; 64B9
        pop    sfr_B                                 ; 64BC
        mov    a, sfr_B                              ; 64BE
        dec    a                                     ; 64C0
        jz     L_6503                                ; 64C1
        mov    r7, sfr_B                             ; 64C3
        lcall  fp_push_r0                            ; 64C5
        lcall  fp_copy_r0_to_r1                      ; 64C8
        lcall  fp_mul                                ; 64CB
        cjne   r7, #0x03, L_64D4                     ; 64CE
        lcall  fp_push_r0                            ; 64D1
L_64D4::
        mov    dptr, #T_6563                         ; 64D4
        mov    a, #0x03                              ; 64D7
        clr    c                                     ; 64D9
        subb   a, r7                                 ; 64DA
        mov    sfr_B, #0x04                          ; 64DB
        mul    ab                                    ; 64DE
        lcall  dptr_add_a_b                          ; 64DF
        lcall  fp_ld_code_r1                         ; 64E2
        lcall  fp_mul                                ; 64E5
        lcall  fp_ld_code_r1                         ; 64E8
        lcall  fp_add                                ; 64EB
        cjne   r7, #0x03, L_64FD                     ; 64EE
        lcall  fp_clr_r1                             ; 64F1
        lcall  fp_mul                                ; 64F4
        lcall  fp_ld_code_r1                         ; 64F7
        lcall  fp_add                                ; 64FA
L_64FD::
        lcall  fp_clr_r1                             ; 64FD
        lcall  fp_mul                                ; 6500
L_6503::
        mov    a, @r0                                ; 6503
        inc    a                                     ; 6504
        xrl    a, #0x80                              ; 6505
        mov    @r0, a                                ; 6507
        mov    dptr, #T_6557                         ; 6508
        pop    sfr_ACC                               ; 650B
        lcall  dptr_add_a_b                          ; 650D
        lcall  fp_ld_code_r1                         ; 6510
        lcall  fp_add                                ; 6513
        pop    sfr_ACC                               ; 6516
        mov    r7, a                                 ; 6518
        lcall  fp_push_r0                            ; 6519
        mov    a, r7                                 ; 651C
        mov    sfr_B, #0x00                          ; 651D
        jnb    0xE7, L_6526                          ; 6520
        mov    sfr_B, #0xFF                          ; 6523
L_6526::
        dec    r0                                    ; 6526
        mov    @r0, sfr_B                            ; 6527
        dec    r0                                    ; 6529
        mov    @r0, sfr_B                            ; 652A
        dec    r0                                    ; 652C
        mov    @r0, a                                ; 652D
        inc    r0                                    ; 652E
        inc    r0                                    ; 652F
        lcall  i24_to_fp                             ; 6530
        mov    dptr, #T_6543                         ; 6533
        lcall  fp_ld_code_r1                         ; 6536
        lcall  fp_mul                                ; 6539
        lcall  fp_clr_r1                             ; 653C
        lcall  fp_add                                ; 653F
        ret                                          ; 6542
T_6543::
        .db 0x3E, 0xB1, 0x72, 0x18                                                           ; 6543 >.r.
T_6547::
        .db 0x3D, 0xDE, 0x5B, 0xD9                                                           ; 6547 =.[.
T_654B::
        .db 0x3F, 0x8F, 0xAC, 0xD6, 0x3F, 0xB5, 0x04, 0xF3, 0x3F, 0xE4, 0x11, 0xF0           ; 654B ?...?...?...
T_6557::
        .db 0x3B, 0xEC, 0x98, 0x20, 0x3D, 0xB1, 0x72, 0x18, 0x3E, 0x93, 0xDF, 0x14           ; 6557 ;.. =.r.>...
T_6563::
        .db 0x3C, 0xCC, 0xCC, 0xCD, 0x3D, 0xAA, 0xAA, 0xAB, 0x3F, 0x80, 0x00, 0x00           ; 6563 <...=...?...

; @R0 -= @R1 (negate R1, add)
fp_sub::
        mov    a, @r1                                ; 656F
        jz     fp_add                                ; 6570
        cpl    0xE7                                  ; 6572
        mov    @r1, a                                ; 6574
        sjmp   fp_add                                ; 6575

; @R0 = @R1 - @R0
fp_rsub::
        mov    a, @r0                                ; 6577
        jz     fp_add                                ; 6578
        cpl    0xE7                                  ; 657A
        mov    @r0, a                                ; 657C

; @R0 += @R1
fp_add::
        mov    a, @r1                                ; 657D
        jz     L_6586                                ; 657E
        mov    a, @r0                                ; 6580
        jnz    L_6589                                ; 6581
        lcall  fp_copy_r1_to_r0                      ; 6583
L_6586::
        mov    a, @r0                                ; 6586
        clr    c                                     ; 6587
        ret                                          ; 6588
L_6589::
        mov    a, @r1                                ; 6589
        clr    0xE7                                  ; 658A
        mov    r5, a                                 ; 658C
        mov    a, @r0                                ; 658D
        clr    0xE7                                  ; 658E
        clr    c                                     ; 6590
        subb   a, r5                                 ; 6591
        mov    r5, #0x00                             ; 6592
        jz     L_65CA                                ; 6594
        jnc    L_659D                                ; 6596
        lcall  fp_swap                               ; 6598
        cpl    a                                     ; 659B
        inc    a                                     ; 659C
L_659D::
        add    a, #0xE7                              ; 659D
        jc     L_6586                                ; 659F
        add    a, #0x19                              ; 65A1
        dec    r0                                    ; 65A3
        dec    r1                                    ; 65A4
L_65A5::
        add    a, #0xF8                              ; 65A5
        jnc    L_65B7                                ; 65A7
        lcall  i24_shr8_ins_a_r1                     ; 65A9
        xch    a, r5                                 ; 65AC
        jz     L_65B4                                ; 65AD
        mov    a, #0x01                              ; 65AF
        orl    a, r5                                 ; 65B1
        mov    r5, a                                 ; 65B2
        clr    a                                     ; 65B3
L_65B4::
        xch    a, @r1                                ; 65B4
        sjmp   L_65A5                                ; 65B5
L_65B7::
        add    a, #0x08                              ; 65B7
        jz     L_65C8                                ; 65B9
        mov    r2, a                                 ; 65BB
L_65BC::
        lcall  i24_shr1_r1                           ; 65BC
        mov    a, r5                                 ; 65BF
        rrc    a                                     ; 65C0
        orl    c, 0xE0                               ; 65C1
        mov    0xE0, c                               ; 65C3
        mov    r5, a                                 ; 65C5
        djnz   r2, L_65BC                            ; 65C6
L_65C8::
        inc    r0                                    ; 65C8
        inc    r1                                    ; 65C9
L_65CA::
        mov    a, @r0                                ; 65CA
        clr    c                                     ; 65CB
        rlc    a                                     ; 65CC
        rr     a                                     ; 65CD
        mov    r2, a                                 ; 65CE
        rrc    a                                     ; 65CF
        xrl    a, @r1                                ; 65D0
        dec    r0                                    ; 65D1
        dec    r1                                    ; 65D2
        jb     0xE7, L_65F7                          ; 65D3
        lcall  i24_add                               ; 65D6
        jnc    L_6639                                ; 65D9
        lcall  i24_rrc                               ; 65DB
        mov    a, r5                                 ; 65DE
        rrc    a                                     ; 65DF
        orl    c, 0xE0                               ; 65E0
        mov    0xE0, c                               ; 65E2
        mov    r5, a                                 ; 65E4
        inc    r2                                    ; 65E5
        cjne   r2, #0x7F, L_6639                     ; 65E6
        inc    r0                                    ; 65E9
        inc    r1                                    ; 65EA
        mov    a, @r0                                ; 65EB
        anl    a, #0x80                              ; 65EC
        setb   c                                     ; 65EE
        setb   sbit_OV                               ; 65EF
        lcall  fp_ld_max_r0                          ; 65F1
        orl    a, @r0                                ; 65F4
        mov    @r0, a                                ; 65F5
        ret                                          ; 65F6
L_65F7::
        clr    c                                     ; 65F7
        clr    a                                     ; 65F8
        subb   a, r5                                 ; 65F9
        mov    r5, a                                 ; 65FA
        lcall  i24_sub_core                          ; 65FB
        orl    a, r5                                 ; 65FE
        jnz    L_6605                                ; 65FF
        mov    @r0, #0x80                            ; 6601
        sjmp   L_6645                                ; 6603
L_6605::
        jnc    L_6614                                ; 6605
        inc    r0                                    ; 6607
        mov    a, @r0                                ; 6608
        cpl    0xE7                                  ; 6609
        mov    @r0, a                                ; 660B
        clr    c                                     ; 660C
        clr    a                                     ; 660D
        subb   a, r5                                 ; 660E
        mov    r5, a                                 ; 660F
        dec    r0                                    ; 6610
        lcall  i24_neg_c                             ; 6611
L_6614::
        jnz    L_6629                                ; 6614
        mov    a, r2                                 ; 6616
        add    a, #0xF7                              ; 6617
        jnc    L_6629                                ; 6619
        inc    a                                     ; 661B
        mov    r2, a                                 ; 661C
        clr    a                                     ; 661D
        xch    a, r5                                 ; 661E
        jnb    0xE0, L_6623                          ; 661F
        dec    r5                                    ; 6622
L_6623::
        lcall  i24_shl8_ins_a                        ; 6623
        mov    a, @r0                                ; 6626
        sjmp   L_6614                                ; 6627
L_6629::
        mov    a, @r0                                ; 6629
        jb     0xE7, L_6639                          ; 662A
        mov    a, r5                                 ; 662D
        mov    c, 0xE0                               ; 662E
        rlc    a                                     ; 6630
        mov    r5, a                                 ; 6631
        lcall  i24_shl1                              ; 6632
        djnz   r2, L_6629                            ; 6635
        sjmp   L_6644                                ; 6637
L_6639::
        inc    r0                                    ; 6639
        inc    r1                                    ; 663A
        mov    a, @r0                                ; 663B
        anl    a, #0x80                              ; 663C
        orl    a, r2                                 ; 663E
        mov    @r0, a                                ; 663F
        lcall  fp_round_normalize                    ; 6640
        ret                                          ; 6643
L_6644::
        setb   c                                     ; 6644
L_6645::
        clr    sbit_OV                               ; 6645
        inc    r0                                    ; 6647
        inc    r1                                    ; 6648
        clr    a                                     ; 6649
        mov    @r0, a                                ; 664A
        ret                                          ; 664B

; @R0 /= @R1; C=1,OV=1 on divide by zero
fp_div::
        clr    c                                     ; 664C
        mov    a, @r1                                ; 664D
        jnz    L_6655                                ; 664E
        setb   c                                     ; 6650
        setb   sbit_OV                               ; 6651
        mov    a, @r0                                ; 6653
L_6654::
        ret                                          ; 6654
L_6655::
        mov    a, @r0                                ; 6655
        jz     L_6654                                ; 6656
        clr    a                                     ; 6658
        mov    r6, a                                 ; 6659
        mov    r5, a                                 ; 665A
        mov    r4, a                                 ; 665B
        mov    r3, a                                 ; 665C
        xch    a, @r0                                ; 665D
        xch    a, r6                                 ; 665E
        dec    r0                                    ; 665F
        xch    a, @r0                                ; 6660
        xch    a, r5                                 ; 6661
        dec    r0                                    ; 6662
        xch    a, @r0                                ; 6663
        xch    a, r4                                 ; 6664
        dec    r0                                    ; 6665
        xch    a, @r0                                ; 6666
        xch    a, r3                                 ; 6667
        inc    r0                                    ; 6668
        inc    r0                                    ; 6669
        inc    r0                                    ; 666A
        mov    r2, #0x1F                             ; 666B
        mov    r7, #0x80                             ; 666D
        dec    r1                                    ; 666F
L_6670::
        dec    r1                                    ; 6670
        dec    r1                                    ; 6671
        clr    c                                     ; 6672
        mov    a, r3                                 ; 6673
        subb   a, @r1                                ; 6674
        inc    r1                                    ; 6675
        mov    a, r4                                 ; 6676
        subb   a, @r1                                ; 6677
        inc    r1                                    ; 6678
        mov    a, r5                                 ; 6679
        subb   a, @r1                                ; 667A
        jc     L_668D                                ; 667B
L_667D::
        dec    r1                                    ; 667D
        dec    r1                                    ; 667E
        mov    a, r3                                 ; 667F
        subb   a, @r1                                ; 6680
        mov    r3, a                                 ; 6681
        inc    r1                                    ; 6682
        mov    a, r4                                 ; 6683
        subb   a, @r1                                ; 6684
        mov    r4, a                                 ; 6685
        inc    r1                                    ; 6686
        mov    a, r5                                 ; 6687
        subb   a, @r1                                ; 6688
        mov    r5, a                                 ; 6689
        xch    a, @r0                                ; 668A
        orl    a, r7                                 ; 668B
        xch    a, @r0                                ; 668C
L_668D::
        djnz   r2, L_6691                            ; 668D
        sjmp   L_66AB                                ; 668F
L_6691::
        mov    a, r7                                 ; 6691
        rr     a                                     ; 6692
        mov    r7, a                                 ; 6693
        jnb    0xE7, L_6698                          ; 6694
        dec    r0                                    ; 6697
L_6698::
        clr    c                                     ; 6698
        mov    a, r3                                 ; 6699
        rlc    a                                     ; 669A
        mov    r3, a                                 ; 669B
        mov    a, r4                                 ; 669C
        rlc    a                                     ; 669D
        mov    r4, a                                 ; 669E
        mov    a, r5                                 ; 669F
        rlc    a                                     ; 66A0
        mov    r5, a                                 ; 66A1
        jbc    sbit_CY, L_667D                       ; 66A2
        mov    a, r5                                 ; 66A5
        jnb    0xE7, L_668D                          ; 66A6
        sjmp   L_6670                                ; 66A9
L_66AB::
        mov    a, r5                                 ; 66AB
        orl    a, r4                                 ; 66AC
        orl    a, r3                                 ; 66AD
        jz     L_66B4                                ; 66AE
        mov    a, @r0                                ; 66B0
        setb   0xE0                                  ; 66B1
        mov    @r0, a                                ; 66B3
L_66B4::
        rrc    a                                     ; 66B4
        inc    r0                                    ; 66B5
        inc    r0                                    ; 66B6
        inc    r0                                    ; 66B7
        mov    a, @r0                                ; 66B8
        jb     0xE7, L_66C5                          ; 66B9
        dec    r0                                    ; 66BC
        lcall  i24_shl1                              ; 66BD
        inc    r0                                    ; 66C0
        mov    a, @r0                                ; 66C1
        rlc    a                                     ; 66C2
        mov    @r0, a                                ; 66C3
        dec    r6                                    ; 66C4
L_66C5::
        mov    a, r6                                 ; 66C5
        xch    a, @r0                                ; 66C6
        dec    r0                                    ; 66C7
        lcall  i24_shr8_ins_a                        ; 66C8
        mov    r5, a                                 ; 66CB
        inc    r0                                    ; 66CC
        inc    r1                                    ; 66CD
        mov    a, @r1                                ; 66CE
        mov    r6, a                                 ; 66CF
        clr    c                                     ; 66D0
        rlc    a                                     ; 66D1
        mov    sbit_F0, c                            ; 66D2
        rr     a                                     ; 66D4
        cpl    a                                     ; 66D5
        inc    a                                     ; 66D6
        add    a, #0x7E                              ; 66D7
        mov    c, sbit_F0                            ; 66D9
        mov    0xE7, c                               ; 66DB
        mov    @r1, a                                ; 66DD
        lcall  fp_exp_add                            ; 66DE
        mov    a, r6                                 ; 66E1
        mov    @r1, a                                ; 66E2
        jc     L_66E8                                ; 66E3
        lcall  fp_round_normalize                    ; 66E5
L_66E8::
        mov    a, @r0                                ; 66E8
        ret                                          ; 66E9

; @R0 *= @R1
fp_mul::
        clr    c                                     ; 66EA
        mov    a, @r0                                ; 66EB
        jz     L_66F3                                ; 66EC
        mov    a, @r1                                ; 66EE
        jnz    L_66F4                                ; 66EF
        clr    a                                     ; 66F1
        mov    @r0, a                                ; 66F2
L_66F3::
        ret                                          ; 66F3
L_66F4::
        dec    r0                                    ; 66F4
        dec    r1                                    ; 66F5
        lcall  mant_mul24                            ; 66F6
        mov    a, r4                                 ; 66F9
        orl    a, r3                                 ; 66FA
        jz     L_6701                                ; 66FB
        mov    a, r5                                 ; 66FD
        setb   0xE0                                  ; 66FE
        mov    r5, a                                 ; 6700
L_6701::
        mov    a, @r0                                ; 6701
        jnb    0xE7, L_6709                          ; 6702
        inc    r0                                    ; 6705
        inc    @r0                                   ; 6706
        sjmp   L_6712                                ; 6707
L_6709::
        mov    a, r5                                 ; 6709
        mov    c, 0xE0                               ; 670A
        rlc    a                                     ; 670C
        mov    r5, a                                 ; 670D
        lcall  i24_shl1                              ; 670E
        inc    r0                                    ; 6711
L_6712::
        inc    r1                                    ; 6712
        lcall  fp_exp_add                            ; 6713
        jc     L_671B                                ; 6716
        lcall  fp_round_normalize                    ; 6718
L_671B::
        ret                                          ; 671B

; exponent arithmetic for mul/div, over/underflow
fp_exp_add::
        mov    a, @r1                                ; 671C
        xrl    a, @r0                                ; 671D
        anl    a, #0x80                              ; 671E
        mov    r2, a                                 ; 6720
        mov    a, @r0                                ; 6721
        clr    0xE7                                  ; 6722
        mov    @r0, a                                ; 6724
        mov    a, @r1                                ; 6725
        clr    0xE7                                  ; 6726
        add    a, @r0                                ; 6728
        cjne   a, #0x40, L_672C                      ; 6729
L_672C::
        jnc    L_6733                                ; 672C
        clr    sbit_OV                               ; 672E
        clr    a                                     ; 6730
        mov    @r0, a                                ; 6731
        ret                                          ; 6732
L_6733::
        cjne   a, #0xBE, L_6736                      ; 6733
L_6736::
        jc     L_6740                                ; 6736
        setb   c                                     ; 6738
        setb   sbit_OV                               ; 6739
        lcall  fp_ld_max_r0                          ; 673B
        sjmp   L_6744                                ; 673E
L_6740::
        add    a, #0xC1                              ; 6740
        mov    @r0, a                                ; 6742
        clr    c                                     ; 6743
L_6744::
        mov    a, @r0                                ; 6744
        xrl    a, r2                                 ; 6745
        mov    @r0, a                                ; 6746
        ret                                          ; 6747

fp_round_normalize::
        dec    r0                                    ; 6748
        lcall  i24_round_r5                          ; 6749
        inc    r0                                    ; 674C
        jnc    L_6764                                ; 674D
        mov    a, #0x81                              ; 674F
        orl    a, @r0                                ; 6751
        inc    a                                     ; 6752
        jz     L_675C                                ; 6753
        inc    @r0                                   ; 6755
        dec    r0                                    ; 6756
        mov    @r0, #0x80                            ; 6757
        inc    r0                                    ; 6759
        sjmp   L_6764                                ; 675A
L_675C::
        mov    a, @r0                                ; 675C
        anl    a, #0x80                              ; 675D
        lcall  fp_ld_max_r0                          ; 675F
        orl    a, @r0                                ; 6762
        mov    @r0, a                                ; 6763
L_6764::
        mov    a, @r0                                ; 6764
        clr    c                                     ; 6765
        ret                                          ; 6766

; compare @R0 with @R1 -> C
fp_cmp::
        mov    a, @r0                                ; 6767
        mov    c, 0xE7                               ; 6768
        mov    sbit_F0, c                            ; 676A
        xrl    a, @r1                                ; 676C
        jnb    0xE7, L_6775                          ; 676D
L_6770::
        mov    c, sbit_F0                            ; 6770
        mov    a, #0xFF                              ; 6772
L_6774::
        ret                                          ; 6774
L_6775::
        mov    a, @r0                                ; 6775
        clr    0xE7                                  ; 6776
        mov    r2, a                                 ; 6778
        mov    a, @r1                                ; 6779
        clr    0xE7                                  ; 677A
        clr    c                                     ; 677C
        subb   a, r2                                 ; 677D
        jc     L_6770                                ; 677E
        jz     L_6786                                ; 6780
L_6782::
        cpl    sbit_F0                               ; 6782
        sjmp   L_6770                                ; 6784
L_6786::
        mov    a, @r0                                ; 6786
        jz     L_6774                                ; 6787
        dec    r0                                    ; 6789
        dec    r1                                    ; 678A
        lcall  i24_cmp                               ; 678B
        inc    r0                                    ; 678E
        inc    r1                                    ; 678F
        jz     L_6774                                ; 6790
        jnc    L_6770                                ; 6792
        sjmp   L_6782                                ; 6794

fp_copy_r0_to_r1::
        dec    r1                                    ; 6796
        dec    r1                                    ; 6797
        dec    r1                                    ; 6798
        dec    r0                                    ; 6799
        dec    r0                                    ; 679A
        dec    r0                                    ; 679B
        mov    a, @r0                                ; 679C
        mov    @r1, a                                ; 679D
        inc    r0                                    ; 679E
        inc    r1                                    ; 679F
        mov    a, @r0                                ; 67A0
        mov    @r1, a                                ; 67A1
        inc    r0                                    ; 67A2
        inc    r1                                    ; 67A3
        mov    a, @r0                                ; 67A4
        mov    @r1, a                                ; 67A5
        inc    r0                                    ; 67A6
        inc    r1                                    ; 67A7
        mov    a, @r0                                ; 67A8
        mov    @r1, a                                ; 67A9
        ret                                          ; 67AA

fp_copy_r1_to_r0::
        dec    r0                                    ; 67AB
        dec    r0                                    ; 67AC
        dec    r0                                    ; 67AD
        dec    r1                                    ; 67AE
        dec    r1                                    ; 67AF
        dec    r1                                    ; 67B0
        mov    a, @r1                                ; 67B1
        mov    @r0, a                                ; 67B2
        inc    r0                                    ; 67B3
        inc    r1                                    ; 67B4
        mov    a, @r1                                ; 67B5
        mov    @r0, a                                ; 67B6
        inc    r0                                    ; 67B7
        inc    r1                                    ; 67B8
        mov    a, @r1                                ; 67B9
        mov    @r0, a                                ; 67BA
        inc    r0                                    ; 67BB
        inc    r1                                    ; 67BC
        mov    a, @r1                                ; 67BD
        mov    @r0, a                                ; 67BE
        ret                                          ; 67BF

; @R0 = float from code @DPTR
fp_ld_code_r0::
        mov    a, #0x04                              ; 67C0
L_67C2::
        mov    @r0, a                                ; 67C2
        clr    a                                     ; 67C3
        movc   a, @a+dptr                            ; 67C4
        xch    a, @r0                                ; 67C5
        dec    r0                                    ; 67C6
        inc    dptr                                  ; 67C7
        djnz   sfr_ACC, L_67C2                       ; 67C8
        inc    r0                                    ; 67CB
        inc    r0                                    ; 67CC
        inc    r0                                    ; 67CD
        inc    r0                                    ; 67CE
        ret                                          ; 67CF

fp_ld_code_r1::
        mov    a, #0x04                              ; 67D0
L_67D2::
        mov    @r1, a                                ; 67D2
        clr    a                                     ; 67D3
        movc   a, @a+dptr                            ; 67D4
        xch    a, @r1                                ; 67D5
        dec    r1                                    ; 67D6
        inc    dptr                                  ; 67D7
        djnz   sfr_ACC, L_67D2                       ; 67D8
        inc    r1                                    ; 67DB
        inc    r1                                    ; 67DC
        inc    r1                                    ; 67DD
        inc    r1                                    ; 67DE
        ret                                          ; 67DF

; 7F FFFFFF
fp_ld_max_r0::
        dec    r0                                    ; 67E0
        dec    r0                                    ; 67E1
        dec    r0                                    ; 67E2
        mov    @r0, #0xFF                            ; 67E3
        inc    r0                                    ; 67E5
        mov    @r0, #0xFF                            ; 67E6
        inc    r0                                    ; 67E8
        mov    @r0, #0xFF                            ; 67E9
        inc    r0                                    ; 67EB
        mov    @r0, #0x7E                            ; 67EC
        ret                                          ; 67EE

fp_clr_r0::
        pop    sfr_ACC                               ; 67EF
        mov    r2, a                                 ; 67F1
        pop    sfr_ACC                               ; 67F2
        mov    r3, a                                 ; 67F4
        dec    r0                                    ; 67F5
        dec    r0                                    ; 67F6
        dec    r0                                    ; 67F7
        pop    sfr_ACC                               ; 67F8
        mov    @r0, a                                ; 67FA
        inc    r0                                    ; 67FB
        pop    sfr_ACC                               ; 67FC
        mov    @r0, a                                ; 67FE
        inc    r0                                    ; 67FF
        pop    sfr_ACC                               ; 6800
        mov    @r0, a                                ; 6802
        inc    r0                                    ; 6803
        pop    sfr_ACC                               ; 6804
        mov    @r0, a                                ; 6806
        mov    a, r3                                 ; 6807
        push   sfr_ACC                               ; 6808
        mov    a, r2                                 ; 680A
        push   sfr_ACC                               ; 680B
        ret                                          ; 680D

fp_clr_r1::
        pop    sfr_ACC                               ; 680E
        mov    r2, a                                 ; 6810
        pop    sfr_ACC                               ; 6811
        mov    r3, a                                 ; 6813
        dec    r1                                    ; 6814
        dec    r1                                    ; 6815
        dec    r1                                    ; 6816
        pop    sfr_ACC                               ; 6817
        mov    @r1, a                                ; 6819
        inc    r1                                    ; 681A
        pop    sfr_ACC                               ; 681B
        mov    @r1, a                                ; 681D
        inc    r1                                    ; 681E
        pop    sfr_ACC                               ; 681F
        mov    @r1, a                                ; 6821
        inc    r1                                    ; 6822
        pop    sfr_ACC                               ; 6823
        mov    @r1, a                                ; 6825
        mov    a, r3                                 ; 6826
        push   sfr_ACC                               ; 6827
        mov    a, r2                                 ; 6829
        push   sfr_ACC                               ; 682A
        ret                                          ; 682C

; push float @R0 on the stack (keeps return address)
fp_push_r0::
        pop    sfr_ACC                               ; 682D
        mov    r2, a                                 ; 682F
        pop    sfr_ACC                               ; 6830
        mov    r3, a                                 ; 6832
        mov    a, @r0                                ; 6833
        push   sfr_ACC                               ; 6834
        dec    r0                                    ; 6836
        mov    a, @r0                                ; 6837
        push   sfr_ACC                               ; 6838
        dec    r0                                    ; 683A
        mov    a, @r0                                ; 683B
        push   sfr_ACC                               ; 683C
        dec    r0                                    ; 683E
        mov    a, @r0                                ; 683F
        push   sfr_ACC                               ; 6840
        inc    r0                                    ; 6842
        inc    r0                                    ; 6843
        inc    r0                                    ; 6844
        mov    a, r3                                 ; 6845
        push   sfr_ACC                               ; 6846
        mov    a, r2                                 ; 6848
        push   sfr_ACC                               ; 6849
        ret                                          ; 684B

fp_push_r1::
        pop    sfr_ACC                               ; 684C
        mov    r2, a                                 ; 684E
        pop    sfr_ACC                               ; 684F
        mov    r3, a                                 ; 6851
        mov    a, @r1                                ; 6852
        push   sfr_ACC                               ; 6853
        dec    r1                                    ; 6855
        mov    a, @r1                                ; 6856
        push   sfr_ACC                               ; 6857
        dec    r1                                    ; 6859
        mov    a, @r1                                ; 685A
        push   sfr_ACC                               ; 685B
        dec    r1                                    ; 685D
        mov    a, @r1                                ; 685E
        push   sfr_ACC                               ; 685F
        inc    r1                                    ; 6861
        inc    r1                                    ; 6862
        inc    r1                                    ; 6863
        mov    a, r3                                 ; 6864
        push   sfr_ACC                               ; 6865
        mov    a, r2                                 ; 6867
        push   sfr_ACC                               ; 6868
        ret                                          ; 686A

fp_swap::
        dec    r0                                    ; 686B
        dec    r0                                    ; 686C
        dec    r0                                    ; 686D
        dec    r1                                    ; 686E
        dec    r1                                    ; 686F
        dec    r1                                    ; 6870
        xch    a, @r1                                ; 6871
        xch    a, @r0                                ; 6872
        xch    a, @r1                                ; 6873
        inc    r0                                    ; 6874
        inc    r1                                    ; 6875
        xch    a, @r1                                ; 6876
        xch    a, @r0                                ; 6877
        xch    a, @r1                                ; 6878
        inc    r0                                    ; 6879
        inc    r1                                    ; 687A
        xch    a, @r1                                ; 687B
        xch    a, @r0                                ; 687C
        xch    a, @r1                                ; 687D
        inc    r0                                    ; 687E
        inc    r1                                    ; 687F
        xch    a, @r1                                ; 6880
        xch    a, @r0                                ; 6881
        xch    a, @r1                                ; 6882
        ret                                          ; 6883

fp_ld_xdata_r0::
        mov    a, #0x04                              ; 6884
L_6886::
        mov    @r0, a                                ; 6886
        movx   a, @dptr                              ; 6887
        xch    a, @r0                                ; 6888
        dec    r0                                    ; 6889
        inc    dptr                                  ; 688A
        djnz   sfr_ACC, L_6886                       ; 688B
        inc    r0                                    ; 688E
        inc    r0                                    ; 688F
        inc    r0                                    ; 6890
        inc    r0                                    ; 6891
        ret                                          ; 6892

fp_ld_xdata_r1::
        mov    a, #0x04                              ; 6893
L_6895::
        mov    @r1, a                                ; 6895
        movx   a, @dptr                              ; 6896
        xch    a, @r1                                ; 6897
        dec    r1                                    ; 6898
        inc    dptr                                  ; 6899
        djnz   sfr_ACC, L_6895                       ; 689A
        inc    r1                                    ; 689D
        inc    r1                                    ; 689E
        inc    r1                                    ; 689F
        inc    r1                                    ; 68A0
        ret                                          ; 68A1

fp_st_r0_xdata::
        mov    a, #0x04                              ; 68A2
L_68A4::
        xch    a, @r0                                ; 68A4
        movx   @dptr, a                              ; 68A5
        xch    a, @r0                                ; 68A6
        dec    r0                                    ; 68A7
        inc    dptr                                  ; 68A8
        djnz   sfr_ACC, L_68A4                       ; 68A9
        inc    r0                                    ; 68AC
        inc    r0                                    ; 68AD
        inc    r0                                    ; 68AE
        inc    r0                                    ; 68AF
        ret                                          ; 68B0

fp_st_r1_xdata::
        mov    a, #0x04                              ; 68B1
L_68B3::
        xch    a, @r1                                ; 68B3
        movx   @dptr, a                              ; 68B4
        xch    a, @r1                                ; 68B5
        dec    r1                                    ; 68B6
        inc    dptr                                  ; 68B7
        djnz   sfr_ACC, L_68B3                       ; 68B8
        inc    r1                                    ; 68BB
        inc    r1                                    ; 68BC
        inc    r1                                    ; 68BD
        inc    r1                                    ; 68BE
        ret                                          ; 68BF

; DPTR += A
dptr_add_a_b::
        xch    a, sfr_DPL                            ; 68C0
        add    a, sfr_DPL                            ; 68C2
        xch    a, sfr_DPL                            ; 68C4
        jnc    L_68CA                                ; 68C6
        inc    sfr_DPH                               ; 68C8
L_68CA::
        ret                                          ; 68CA

; @R1 = 10^A, A = -18..19 (table 0x68DF)
fp_ld_pow10_r1::
        add    a, #0x12                              ; 68CB
        rl     a                                     ; 68CD
        rl     a                                     ; 68CE
        add    a, #0x0A                              ; 68CF
        mov    r2, #0x04                             ; 68D1
L_68D3::
        mov    @r1, a                                ; 68D3
        movc   a, @a+pc                              ; 68D4
        xch    a, @r1                                ; 68D5
        dec    r1                                    ; 68D6
        inc    a                                     ; 68D7
        djnz   r2, L_68D3                            ; 68D8
        inc    r1                                    ; 68DA
        inc    r1                                    ; 68DB
        inc    r1                                    ; 68DC
        inc    r1                                    ; 68DD
        ret                                          ; 68DE
pow10_table::
        .db 0x03, 0x93, 0x92, 0xEF, 0x06, 0xB8, 0x77, 0xAB, 0x09, 0xE6, 0x95, 0x95, 0x0D, 0x90, 0x1D, 0x7D ; 68DF ......w........}
        .db 0x10, 0xB4, 0x24, 0xDC, 0x13, 0xE1, 0x2E, 0x13, 0x17, 0x8C, 0xBC, 0xCC, 0x1A, 0xAF, 0xEB, 0xFF ; 68EF ..$.............
        .db 0x1D, 0xDB, 0xE6, 0xFF, 0x21, 0x89, 0x70, 0x5F, 0x24, 0xAB, 0xCC, 0x77, 0x27, 0xD6, 0xBF, 0x95 ; 68FF ....!.p_$..w'...
        .db 0x2B, 0x86, 0x37, 0xBD, 0x2E, 0xA7, 0xC5, 0xAC, 0x31, 0xD1, 0xB7, 0x17           ; 690F +.7.....1...
T_691B::
        .db 0x35, 0x83, 0x12, 0x6F                                                           ; 691B 5..o
T_691F::
        .db 0x38, 0xA3, 0xD7, 0x0A, 0x3B, 0xCC, 0xCC, 0xCD                                   ; 691F 8...;...
T_6927::
        .db 0x3F, 0x80, 0x00, 0x00                                                           ; 6927 ?...
T_692B::
        .db 0x42, 0xA0, 0x00, 0x00                                                           ; 692B B...
T_692F::
        .db 0x45, 0xC8, 0x00, 0x00                                                           ; 692F E...
T_6933::
        .db 0x48, 0xFA, 0x00, 0x00                                                           ; 6933 H...
T_6937::
        .db 0x4C, 0x9C, 0x40, 0x00                                                           ; 6937 L.@.
T_693B::
        .db 0x4F, 0xC3, 0x50, 0x00, 0x52, 0xF4, 0x24, 0x00, 0x56, 0x98, 0x96, 0x80, 0x59, 0xBE, 0xBC, 0x20 ; 693B O.P.R.$.V...Y.. 
        .db 0x5C, 0xEE, 0x6B, 0x28, 0x60, 0x95, 0x02, 0xF9, 0x63, 0xBA, 0x43, 0xB7, 0x66, 0xE8, 0xD4, 0xA5 ; 694B \.k(`...c.C.f...
        .db 0x6A, 0x91, 0x84, 0xE7, 0x6D, 0xB5, 0xE6, 0x21, 0x70, 0xE3, 0x5F, 0xA9, 0x74, 0x8E, 0x1B, 0xCA ; 695B j...m..!p._.t...
        .db 0x77, 0xB1, 0xA2, 0xBC, 0x7A, 0xDE, 0x0B, 0x6B, 0x7E, 0x8A, 0xC7, 0x23           ; 696B w...z..k~..#

i24_round_r5::
        mov    a, #0x80                              ; 6977
        add    a, r5                                 ; 6979
        jnc    L_6989                                ; 697A
        lcall  i24_inc_r0                            ; 697C
        jnz    L_6989                                ; 697F
        dec    r0                                    ; 6981
        dec    r0                                    ; 6982
        mov    a, @r0                                ; 6983
        clr    0xE0                                  ; 6984
        mov    @r0, a                                ; 6986
        inc    r0                                    ; 6987
        inc    r0                                    ; 6988
L_6989::
        ret                                          ; 6989

i24_div_signed::
        mov    a, @r1                                ; 698A
        jb     0xE7, L_69AC                          ; 698B

i24_div_signed_core::
        mov    a, @r0                                ; 698E
        jb     0xE7, L_6995                          ; 698F
        ljmp   i24_div                               ; 6992
L_6995::
        lcall  i24_neg                               ; 6995
        lcall  i24_div                               ; 6998
        jc     L_69BD                                ; 699B
        mov    r2, a                                 ; 699D
        clr    a                                     ; 699E
        subb   a, r3                                 ; 699F
        mov    r3, a                                 ; 69A0
        clr    a                                     ; 69A1
        subb   a, r4                                 ; 69A2
        mov    r4, a                                 ; 69A3
        clr    a                                     ; 69A4
        subb   a, r5                                 ; 69A5
        mov    r5, a                                 ; 69A6
        lcall  i24_neg                               ; 69A7
        sjmp   L_69BB                                ; 69AA
L_69AC::
        lcall  i24_neg                               ; 69AC
        lcall  i24_neg_r1                            ; 69AF
        lcall  i24_div_signed_core                   ; 69B2
        jc     L_69BD                                ; 69B5
        mov    r2, a                                 ; 69B7
        lcall  i24_neg_r1                            ; 69B8
L_69BB::
        clr    c                                     ; 69BB
        mov    a, r2                                 ; 69BC
L_69BD::
        ret                                          ; 69BD

; 24-bit restoring division
i24_div::
        clr    a                                     ; 69BE
        mov    r5, a                                 ; 69BF
        mov    r4, a                                 ; 69C0
        mov    r3, a                                 ; 69C1
        lcall  i24_test_r1                           ; 69C2
        jnz    L_69C9                                ; 69C5
        setb   c                                     ; 69C7
        ret                                          ; 69C8
L_69C9::
        lcall  i24_test_r0                           ; 69C9
        jz     L_6A32                                ; 69CC
        mov    r2, #0x18                             ; 69CE
        clr    c                                     ; 69D0
L_69D1::
        dec    r0                                    ; 69D1
        dec    r0                                    ; 69D2
        mov    a, @r0                                ; 69D3
        rlc    a                                     ; 69D4
        mov    @r0, a                                ; 69D5
        inc    r0                                    ; 69D6
        mov    a, @r0                                ; 69D7
        rlc    a                                     ; 69D8
        mov    @r0, a                                ; 69D9
        inc    r0                                    ; 69DA
        mov    a, @r0                                ; 69DB
        rlc    a                                     ; 69DC
        mov    @r0, a                                ; 69DD
        mov    a, r3                                 ; 69DE
        rlc    a                                     ; 69DF
        mov    r3, a                                 ; 69E0
        mov    a, r4                                 ; 69E1
        rlc    a                                     ; 69E2
        mov    r4, a                                 ; 69E3
        mov    a, r5                                 ; 69E4
        rlc    a                                     ; 69E5
        mov    r5, a                                 ; 69E6
        dec    r1                                    ; 69E7
        dec    r1                                    ; 69E8
        mov    a, r3                                 ; 69E9
        subb   a, @r1                                ; 69EA
        mov    r3, a                                 ; 69EB
        inc    r1                                    ; 69EC
        mov    a, r4                                 ; 69ED
        subb   a, @r1                                ; 69EE
        mov    r4, a                                 ; 69EF
        inc    r1                                    ; 69F0
        mov    a, r5                                 ; 69F1
        subb   a, @r1                                ; 69F2
        mov    r5, a                                 ; 69F3
        cpl    c                                     ; 69F4
        jnc    L_6A26                                ; 69F5
L_69F7::
        djnz   r2, L_69D1                            ; 69F7
        sjmp   L_6A2C                                ; 69F9
L_69FB::
        dec    r0                                    ; 69FB
        dec    r0                                    ; 69FC
        mov    a, @r0                                ; 69FD
        rlc    a                                     ; 69FE
        mov    @r0, a                                ; 69FF
        inc    r0                                    ; 6A00
        mov    a, @r0                                ; 6A01
        rlc    a                                     ; 6A02
        mov    @r0, a                                ; 6A03
        inc    r0                                    ; 6A04
        mov    a, @r0                                ; 6A05
        rlc    a                                     ; 6A06
        mov    @r0, a                                ; 6A07
        mov    a, r3                                 ; 6A08
        rlc    a                                     ; 6A09
        mov    r3, a                                 ; 6A0A
        mov    a, r4                                 ; 6A0B
        rlc    a                                     ; 6A0C
        mov    r4, a                                 ; 6A0D
        mov    a, r5                                 ; 6A0E
        rlc    a                                     ; 6A0F
        mov    r5, a                                 ; 6A10
        mov    sbit_F0, c                            ; 6A11
        dec    r1                                    ; 6A13
        dec    r1                                    ; 6A14
        mov    a, r3                                 ; 6A15
        add    a, @r1                                ; 6A16
        mov    r3, a                                 ; 6A17
        inc    r1                                    ; 6A18
        mov    a, r4                                 ; 6A19
        addc   a, @r1                                ; 6A1A
        mov    r4, a                                 ; 6A1B
        inc    r1                                    ; 6A1C
        mov    a, r5                                 ; 6A1D
        addc   a, @r1                                ; 6A1E
        mov    r5, a                                 ; 6A1F
        jnb    sbit_F0, L_6A25                       ; 6A20
        jc     L_69F7                                ; 6A23
L_6A25::
        clr    c                                     ; 6A25
L_6A26::
        djnz   r2, L_69FB                            ; 6A26
        lcall  i24_add_r345                          ; 6A28
        clr    c                                     ; 6A2B
L_6A2C::
        lcall  i24_shl1                              ; 6A2C
        lcall  i24_test_r0                           ; 6A2F
L_6A32::
        clr    c                                     ; 6A32
        ret                                          ; 6A33

; verified 1000 + 7
i24_add::
        clr    c                                     ; 6A34
        dec    r0                                    ; 6A35
        dec    r0                                    ; 6A36
        dec    r1                                    ; 6A37
        dec    r1                                    ; 6A38
        mov    a, @r0                                ; 6A39
        addc   a, @r1                                ; 6A3A
        mov    @r0, a                                ; 6A3B
        inc    r0                                    ; 6A3C
        inc    r1                                    ; 6A3D
        xch    a, @r0                                ; 6A3E
        addc   a, @r1                                ; 6A3F
        xch    a, @r0                                ; 6A40
        orl    a, @r0                                ; 6A41
        inc    r0                                    ; 6A42
        inc    r1                                    ; 6A43
        xch    a, @r0                                ; 6A44
        addc   a, @r1                                ; 6A45
        xch    a, @r0                                ; 6A46
        orl    a, @r0                                ; 6A47
        ret                                          ; 6A48

i24_add_r345::
        dec    r1                                    ; 6A49
        dec    r1                                    ; 6A4A
        mov    a, r3                                 ; 6A4B
        add    a, @r1                                ; 6A4C
        mov    r3, a                                 ; 6A4D
        inc    r1                                    ; 6A4E
        xch    a, r4                                 ; 6A4F
        addc   a, @r1                                ; 6A50
        xch    a, r4                                 ; 6A51
        orl    a, r4                                 ; 6A52
        inc    r1                                    ; 6A53
        xch    a, r5                                 ; 6A54
        addc   a, @r1                                ; 6A55
        xch    a, r5                                 ; 6A56
        orl    a, r5                                 ; 6A57
        ret                                          ; 6A58

; 24x24 signed multiply (mant_mul24 + sign fix)
i24_mul_signed::
        mov    sfr_B, #0x00                          ; 6A59
        mov    a, @r0                                ; 6A5C
        jnb    0xE7, L_6A65                          ; 6A5D
        setb   0xF7                                  ; 6A60
        lcall  i24_neg                               ; 6A62
L_6A65::
        mov    a, @r1                                ; 6A65
        jnb    0xE7, L_6A6E                          ; 6A66
        setb   0xF6                                  ; 6A69
        lcall  i24_neg_r1                            ; 6A6B
L_6A6E::
        mov    r6, sfr_B                             ; 6A6E
        lcall  mant_mul24                            ; 6A70
        mov    sfr_B, a                              ; 6A73
        mov    a, r6                                 ; 6A75
        jnb    0xE6, L_6A7C                          ; 6A76
        lcall  i24_neg_r1                            ; 6A79
L_6A7C::
        mov    a, r6                                 ; 6A7C
        rr     a                                     ; 6A7D
        xrl    a, r6                                 ; 6A7E
        jb     0xE6, L_6A85                          ; 6A7F
        mov    a, sfr_B                              ; 6A82
        ret                                          ; 6A84
L_6A85::
        clr    c                                     ; 6A85
        clr    a                                     ; 6A86
        subb   a, r3                                 ; 6A87
        orl    sfr_B, a                              ; 6A88
        mov    r3, a                                 ; 6A8A
        clr    a                                     ; 6A8B
        subb   a, r4                                 ; 6A8C
        orl    sfr_B, a                              ; 6A8D
        mov    r4, a                                 ; 6A8F
        clr    a                                     ; 6A90
        subb   a, r5                                 ; 6A91
        orl    sfr_B, a                              ; 6A92
        mov    r5, a                                 ; 6A94
        lcall  i24_neg_c                             ; 6A95
        mov    a, sfr_B                              ; 6A98
        ret                                          ; 6A9A

i24_abs::
        mov    a, @r0                                ; 6A9B
        jb     0xE7, i24_neg                         ; 6A9C
        ret                                          ; 6A9F

; 0 - x
i24_neg::
        clr    c                                     ; 6AA0

i24_neg_c::
        dec    r0                                    ; 6AA1
        dec    r0                                    ; 6AA2
        clr    a                                     ; 6AA3
        subb   a, @r0                                ; 6AA4
        mov    @r0, a                                ; 6AA5
        inc    r0                                    ; 6AA6
        clr    a                                     ; 6AA7
        subb   a, @r0                                ; 6AA8
        mov    @r0, a                                ; 6AA9
        inc    r0                                    ; 6AAA
        clr    a                                     ; 6AAB
        subb   a, @r0                                ; 6AAC
        mov    @r0, a                                ; 6AAD
        ret                                          ; 6AAE

i24_shl8_ins_a::
        dec    r0                                    ; 6AAF
        dec    r0                                    ; 6AB0
        xch    a, @r0                                ; 6AB1
        inc    r0                                    ; 6AB2
        xch    a, @r0                                ; 6AB3
        inc    r0                                    ; 6AB4
        xch    a, @r0                                ; 6AB5
        ret                                          ; 6AB6

; shift right one byte, A in at the top
i24_shr8_ins_a::
        xch    a, @r0                                ; 6AB7
        dec    r0                                    ; 6AB8
        xch    a, @r0                                ; 6AB9
        dec    r0                                    ; 6ABA
        xch    a, @r0                                ; 6ABB
        inc    r0                                    ; 6ABC
        inc    r0                                    ; 6ABD
        ret                                          ; 6ABE

i24_shr8_ins_a_r1::
        xch    a, @r1                                ; 6ABF
        dec    r1                                    ; 6AC0
        xch    a, @r1                                ; 6AC1
        dec    r1                                    ; 6AC2
        xch    a, @r1                                ; 6AC3
        inc    r1                                    ; 6AC4
        inc    r1                                    ; 6AC5
        ret                                          ; 6AC6

i24_neg_r1::
        xch    a, r1                                 ; 6AC7
        xch    a, r0                                 ; 6AC8
        xch    a, r1                                 ; 6AC9
        lcall  i24_neg                               ; 6ACA
        xch    a, r1                                 ; 6ACD
        xch    a, r0                                 ; 6ACE
        xch    a, r1                                 ; 6ACF
        ret                                          ; 6AD0

i24_clr_r0::
        mov    @r0, #0x00                            ; 6AD1
        dec    r0                                    ; 6AD3
        mov    @r0, #0x00                            ; 6AD4
        dec    r0                                    ; 6AD6
        mov    @r0, #0x00                            ; 6AD7
        inc    r0                                    ; 6AD9
        inc    r0                                    ; 6ADA
        ret                                          ; 6ADB

i24_clr_r1::
        mov    @r1, #0x00                            ; 6ADC
        dec    r1                                    ; 6ADE
        mov    @r1, #0x00                            ; 6ADF
        dec    r1                                    ; 6AE1
        mov    @r1, #0x00                            ; 6AE2
        inc    r1                                    ; 6AE4
        inc    r1                                    ; 6AE5
        ret                                          ; 6AE6

i24_cmp_signed::
        mov    a, @r0                                ; 6AE7
        xrl    a, @r1                                ; 6AE8
        jnb    0xE7, i24_cmp                         ; 6AE9
        mov    a, @r0                                ; 6AEC
        rlc    a                                     ; 6AED
        mov    a, #0x01                              ; 6AEE
        ret                                          ; 6AF0

; @R0 - @R1 -> C (and zero test)
i24_cmp::
        clr    c                                     ; 6AF1
        dec    r0                                    ; 6AF2
        dec    r0                                    ; 6AF3
        dec    r1                                    ; 6AF4
        dec    r1                                    ; 6AF5
        mov    a, @r0                                ; 6AF6
        subb   a, @r1                                ; 6AF7
        mov    r2, a                                 ; 6AF8
        inc    r0                                    ; 6AF9
        inc    r1                                    ; 6AFA
        mov    a, @r0                                ; 6AFB
        subb   a, @r1                                ; 6AFC
        orl    a, r2                                 ; 6AFD
        mov    r2, a                                 ; 6AFE
        inc    r0                                    ; 6AFF
        inc    r1                                    ; 6B00
        mov    a, @r0                                ; 6B01
        subb   a, @r1                                ; 6B02
        orl    a, r2                                 ; 6B03
        ret                                          ; 6B04

i24_copy_r1_to_r0::
        xch    a, @r1                                ; 6B05
        mov    @r0, a                                ; 6B06
        xch    a, @r1                                ; 6B07
        dec    r0                                    ; 6B08
        dec    r1                                    ; 6B09
        xch    a, @r1                                ; 6B0A
        mov    @r0, a                                ; 6B0B
        xch    a, @r1                                ; 6B0C
        dec    r0                                    ; 6B0D
        dec    r1                                    ; 6B0E
        xch    a, @r1                                ; 6B0F
        mov    @r0, a                                ; 6B10
        xch    a, @r1                                ; 6B11
        inc    r0                                    ; 6B12
        inc    r0                                    ; 6B13
        inc    r1                                    ; 6B14
        inc    r1                                    ; 6B15
        ret                                          ; 6B16

i24_ld_code_r0::
        mov    a, #0x03                              ; 6B17
L_6B19::
        mov    @r0, a                                ; 6B19
        clr    a                                     ; 6B1A
        movc   a, @a+dptr                            ; 6B1B
        xch    a, @r0                                ; 6B1C
        dec    r0                                    ; 6B1D
        inc    dptr                                  ; 6B1E
        djnz   sfr_ACC, L_6B19                       ; 6B1F
        inc    r0                                    ; 6B22
        inc    r0                                    ; 6B23
        inc    r0                                    ; 6B24
        ret                                          ; 6B25

i24_ld_code_r1::
        mov    a, #0x03                              ; 6B26
L_6B28::
        mov    @r1, a                                ; 6B28
        clr    a                                     ; 6B29
        movc   a, @a+dptr                            ; 6B2A
        xch    a, @r1                                ; 6B2B
        dec    r1                                    ; 6B2C
        inc    dptr                                  ; 6B2D
        djnz   sfr_ACC, L_6B28                       ; 6B2E
        inc    r1                                    ; 6B31
        inc    r1                                    ; 6B32
        inc    r1                                    ; 6B33
        ret                                          ; 6B34

; complete one-byte read (keyboard PCF8574)
i2cB_read1_stop::
        lcall  i2cB_start_read                       ; 6B35
        jc     L_6B41                                ; 6B38

i2cB_recv_nack_stop::
        lcall  i2cB_recv_byte                        ; 6B3A
        lcall  i2cB_read_ack_bit                     ; 6B3D
        clr    c                                     ; 6B40
L_6B41::
        ljmp   i2cB_stop                             ; 6B41

; A=addr, R3=data
i2cB_write1::
        lcall  i2cB_start_write                      ; 6B44
        jc     L_6B4D                                ; 6B47
        mov    a, r3                                 ; 6B49

i2cB_send_stop::
        lcall  i2cB_send_byte                        ; 6B4A
L_6B4D::
        ljmp   i2cB_stop                             ; 6B4D
L_6B50::
        setb   sbit_T1                               ; 6B50
L_6B52::
        jnb    sbit_T1, L_6B52                       ; 6B52

i2cB_start_write::
        clr    0xE0                                  ; 6B55
        ljmp   i2cB_start                            ; 6B57
L_6B5A::
        setb   0x97                                  ; 6B5A
        setb   sbit_T1                               ; 6B5C
L_6B5E::
        jnb    sbit_T1, L_6B5E                       ; 6B5E
        nop                                          ; 6B61

i2cB_start_read::
        setb   0xE0                                  ; 6B62

; start condition + address byte (ACC.0 = R/W)
i2cB_start::
        clr    0x97                                  ; 6B64
        nop                                          ; 6B66
        nop                                          ; 6B67
        nop                                          ; 6B68
        clr    sbit_T1                               ; 6B69
        ljmp   i2cB_send_byte                        ; 6B6B
L_6B6E::
        mov    a, @r0                                ; 6B6E

i2cB_send_byte::
        mov    r2, #0x08                             ; 6B6F
L_6B71::
        rlc    a                                     ; 6B71
        mov    0x97, c                               ; 6B72
        setb   sbit_T1                               ; 6B74
L_6B76::
        jnb    sbit_T1, L_6B76                       ; 6B76
        nop                                          ; 6B79
        nop                                          ; 6B7A
        clr    sbit_T1                               ; 6B7B
        djnz   r2, L_6B71                            ; 6B7D
        rlc    a                                     ; 6B7F
        nop                                          ; 6B80

i2cB_read_ack_bit::
        setb   0x97                                  ; 6B81
        setb   sbit_T1                               ; 6B83
L_6B85::
        jnb    sbit_T1, L_6B85                       ; 6B85
        nop                                          ; 6B88
        nop                                          ; 6B89
        mov    c, 0x97                               ; 6B8A
        clr    sbit_T1                               ; 6B8C
        ret                                          ; 6B8E

i2cB_stop::
        clr    0x97                                  ; 6B8F
        setb   sbit_T1                               ; 6B91
L_6B93::
        jnb    sbit_T1, L_6B93                       ; 6B93
        nop                                          ; 6B96
        nop                                          ; 6B97
        setb   0x97                                  ; 6B98
        ret                                          ; 6B9A

i2cB_read1::
        lcall  i2cB_start_read                       ; 6B9B
        jc     L_6BAF                                ; 6B9E
        lcall  i2cB_recv_byte                        ; 6BA0
        clr    c                                     ; 6BA3
        clr    0x97                                  ; 6BA4
        setb   sbit_T1                               ; 6BA6
L_6BA8::
        jnb    sbit_T1, L_6BA8                       ; 6BA8
        nop                                          ; 6BAB
        nop                                          ; 6BAC
        clr    sbit_T1                               ; 6BAD
L_6BAF::
        ret                                          ; 6BAF

i2cB_recv_byte::
        mov    r2, #0x08                             ; 6BB0
        setb   0x97                                  ; 6BB2
L_6BB4::
        nop                                          ; 6BB4
        setb   sbit_T1                               ; 6BB5
L_6BB7::
        jnb    sbit_T1, L_6BB7                       ; 6BB7
        nop                                          ; 6BBA
        mov    c, 0x97                               ; 6BBB
        clr    sbit_T1                               ; 6BBD
        rlc    a                                     ; 6BBF
        djnz   r2, L_6BB4                            ; 6BC0
        ret                                          ; 6BC2

i24_ld_max_r0::
        mov    @r0, #0x7F                            ; 6BC3
        dec    r0                                    ; 6BC5
        mov    @r0, #0xFF                            ; 6BC6
        dec    r0                                    ; 6BC8
        mov    @r0, #0xFF                            ; 6BC9
        inc    r0                                    ; 6BCB
        inc    r0                                    ; 6BCC
        ret                                          ; 6BCD

i24_st_r0_xdata::
        mov    a, @r0                                ; 6BCE
        movx   @dptr, a                              ; 6BCF
        dec    r0                                    ; 6BD0
        inc    dptr                                  ; 6BD1
        mov    a, @r0                                ; 6BD2
        movx   @dptr, a                              ; 6BD3
        dec    r0                                    ; 6BD4
        inc    dptr                                  ; 6BD5
        mov    a, @r0                                ; 6BD6
        movx   @dptr, a                              ; 6BD7
        inc    r0                                    ; 6BD8
        inc    r0                                    ; 6BD9
        ret                                          ; 6BDA

i24_st_r1_xdata::
        mov    a, @r1                                ; 6BDB
        movx   @dptr, a                              ; 6BDC
        dec    r1                                    ; 6BDD
        inc    dptr                                  ; 6BDE
        mov    a, @r1                                ; 6BDF
        movx   @dptr, a                              ; 6BE0
        dec    r1                                    ; 6BE1
        inc    dptr                                  ; 6BE2
        mov    a, @r1                                ; 6BE3
        movx   @dptr, a                              ; 6BE4
        inc    r1                                    ; 6BE5
        inc    r1                                    ; 6BE6
        ret                                          ; 6BE7

i24_ld_xdata_r0::
        movx   a, @dptr                              ; 6BE8
        mov    @r0, a                                ; 6BE9
        dec    r0                                    ; 6BEA
        inc    dptr                                  ; 6BEB
        movx   a, @dptr                              ; 6BEC
        mov    @r0, a                                ; 6BED
        dec    r0                                    ; 6BEE
        inc    dptr                                  ; 6BEF
        movx   a, @dptr                              ; 6BF0
        mov    @r0, a                                ; 6BF1
        inc    r0                                    ; 6BF2
        inc    r0                                    ; 6BF3
        ret                                          ; 6BF4

i24_ld_xdata_r1::
        movx   a, @dptr                              ; 6BF5
        mov    @r1, a                                ; 6BF6
        dec    r1                                    ; 6BF7
        inc    dptr                                  ; 6BF8
        movx   a, @dptr                              ; 6BF9
        mov    @r1, a                                ; 6BFA
        dec    r1                                    ; 6BFB
        inc    dptr                                  ; 6BFC
        movx   a, @dptr                              ; 6BFD
        mov    @r1, a                                ; 6BFE
        inc    r1                                    ; 6BFF
        inc    r1                                    ; 6C00
        ret                                          ; 6C01

; 24x24 mantissa multiply (used by fp_mul)
mant_mul24::
        clr    a                                     ; 6C02
        mov    r3, a                                 ; 6C03
        mov    r4, a                                 ; 6C04
        mov    r5, a                                 ; 6C05
        dec    r0                                    ; 6C06
        dec    r0                                    ; 6C07
        mov    a, #0xC0                              ; 6C08
L_6C0A::
        mov    r2, a                                 ; 6C0A
        dec    r1                                    ; 6C0B
        dec    r1                                    ; 6C0C
        mov    a, @r0                                ; 6C0D
        mov    sfr_B, @r1                            ; 6C0E
        mul    ab                                    ; 6C10
        add    a, r3                                 ; 6C11
        mov    r3, a                                 ; 6C12
        mov    a, r4                                 ; 6C13
        addc   a, sfr_B                              ; 6C14
        mov    r4, a                                 ; 6C16
        jnc    L_6C1E                                ; 6C17
        inc    r5                                    ; 6C19
        mov    a, r5                                 ; 6C1A
        jnz    L_6C1E                                ; 6C1B
        inc    r2                                    ; 6C1D
L_6C1E::
        mov    a, @r0                                ; 6C1E
        inc    r1                                    ; 6C1F
        mov    sfr_B, @r1                            ; 6C20
        mul    ab                                    ; 6C22
        add    a, r4                                 ; 6C23
        mov    r4, a                                 ; 6C24
        mov    a, r5                                 ; 6C25
        addc   a, sfr_B                              ; 6C26
        mov    r5, a                                 ; 6C28
        mov    a, @r0                                ; 6C29
        inc    r1                                    ; 6C2A
        mov    sfr_B, @r1                            ; 6C2B
        jnc    L_6C30                                ; 6C2D
        inc    r2                                    ; 6C2F
L_6C30::
        mul    ab                                    ; 6C30
        add    a, r5                                 ; 6C31
        mov    r5, a                                 ; 6C32
        mov    a, r2                                 ; 6C33
        anl    a, #0x0F                              ; 6C34
        addc   a, sfr_B                              ; 6C36
        xch    a, r5                                 ; 6C38
        xch    a, r4                                 ; 6C39
        xch    a, r3                                 ; 6C3A
        mov    @r0, a                                ; 6C3B
        inc    r0                                    ; 6C3C
        mov    a, r2                                 ; 6C3D
        anl    a, #0xF0                              ; 6C3E
        rlc    a                                     ; 6C40
        jc     L_6C0A                                ; 6C41
        dec    r0                                    ; 6C43
        mov    a, r5                                 ; 6C44
        xch    a, @r0                                ; 6C45
        xch    a, r5                                 ; 6C46
        dec    r0                                    ; 6C47
        orl    a, r4                                 ; 6C48
        xch    a, r4                                 ; 6C49
        xch    a, @r0                                ; 6C4A
        xch    a, r4                                 ; 6C4B
        dec    r0                                    ; 6C4C
        orl    a, r3                                 ; 6C4D
        xch    a, r3                                 ; 6C4E
        xch    a, @r0                                ; 6C4F
        xch    a, r3                                 ; 6C50
        inc    r0                                    ; 6C51
        inc    r0                                    ; 6C52
        ret                                          ; 6C53

; remainder in A (used by put_digit)
i24_div10_rem::
        dec    r0                                    ; 6C54
        dec    r0                                    ; 6C55
        mov    a, @r0                                ; 6C56
        mov    sfr_B, @r1                            ; 6C57
        mul    ab                                    ; 6C59
        mov    @r0, a                                ; 6C5A
        inc    r0                                    ; 6C5B
        mov    a, @r0                                ; 6C5C
        mov    @r0, sfr_B                            ; 6C5D
        mov    sfr_B, @r1                            ; 6C5F
        mul    ab                                    ; 6C61
        add    a, @r0                                ; 6C62
        mov    @r0, a                                ; 6C63
        inc    r0                                    ; 6C64
        clr    a                                     ; 6C65
        addc   a, sfr_B                              ; 6C66
        xch    a, @r0                                ; 6C68
        mov    sfr_B, @r1                            ; 6C69
        mul    ab                                    ; 6C6B
        add    a, @r0                                ; 6C6C
        mov    @r0, a                                ; 6C6D
        clr    a                                     ; 6C6E
        addc   a, sfr_B                              ; 6C6F
        ret                                          ; 6C71

clc_thunk::
        clr    c                                     ; 6C72

; verified 1000 -> 2000
i24_shl1::
        dec    r0                                    ; 6C73
        dec    r0                                    ; 6C74
        xch    a, @r0                                ; 6C75
        rlc    a                                     ; 6C76
        xch    a, @r0                                ; 6C77
        inc    r0                                    ; 6C78
        xch    a, @r0                                ; 6C79
        rlc    a                                     ; 6C7A
        xch    a, @r0                                ; 6C7B
        inc    r0                                    ; 6C7C
        xch    a, @r0                                ; 6C7D
        rlc    a                                     ; 6C7E
        xch    a, @r0                                ; 6C7F
        ret                                          ; 6C80

i24_sar1::
        xch    a, @r0                                ; 6C81
        mov    c, 0xE7                               ; 6C82
        sjmp   L_6C88                                ; 6C84

i24_shr1::
        clr    c                                     ; 6C86

i24_rrc::
        xch    a, @r0                                ; 6C87
L_6C88::
        rrc    a                                     ; 6C88
        xch    a, @r0                                ; 6C89
        dec    r0                                    ; 6C8A
        xch    a, @r0                                ; 6C8B
        rrc    a                                     ; 6C8C
        xch    a, @r0                                ; 6C8D
        dec    r0                                    ; 6C8E
        xch    a, @r0                                ; 6C8F
        rrc    a                                     ; 6C90
        xch    a, @r0                                ; 6C91
        inc    r0                                    ; 6C92
        inc    r0                                    ; 6C93
        ret                                          ; 6C94
L_6C95::
        xch    a, @r1                                ; 6C95
        mov    c, 0xE7                               ; 6C96
        sjmp   L_6C9C                                ; 6C98

i24_shr1_r1::
        clr    c                                     ; 6C9A
        xch    a, @r1                                ; 6C9B
L_6C9C::
        rrc    a                                     ; 6C9C
        xch    a, @r1                                ; 6C9D
        dec    r1                                    ; 6C9E
        xch    a, @r1                                ; 6C9F
        rrc    a                                     ; 6CA0
        xch    a, @r1                                ; 6CA1
        dec    r1                                    ; 6CA2
        xch    a, @r1                                ; 6CA3
        rrc    a                                     ; 6CA4
        xch    a, @r1                                ; 6CA5
        inc    r1                                    ; 6CA6
        inc    r1                                    ; 6CA7
        ret                                          ; 6CA8

; verified 1000 - 7
i24_sub::
        clr    c                                     ; 6CA9

i24_sub_core::
        dec    r0                                    ; 6CAA
        dec    r0                                    ; 6CAB
        dec    r1                                    ; 6CAC
        dec    r1                                    ; 6CAD
        mov    a, @r0                                ; 6CAE
        subb   a, @r1                                ; 6CAF
        mov    @r0, a                                ; 6CB0
        inc    r0                                    ; 6CB1
        inc    r1                                    ; 6CB2
        xch    a, @r0                                ; 6CB3
        subb   a, @r1                                ; 6CB4
        xch    a, @r0                                ; 6CB5
        orl    a, @r0                                ; 6CB6
        inc    r0                                    ; 6CB7
        inc    r1                                    ; 6CB8
        xch    a, @r0                                ; 6CB9
        subb   a, @r1                                ; 6CBA
        xch    a, @r0                                ; 6CBB
        orl    a, @r0                                ; 6CBC
        ret                                          ; 6CBD

; A = OR of bytes (Z if zero)
i24_test_r0::
        dec    r0                                    ; 6CBE
        dec    r0                                    ; 6CBF
        mov    a, @r0                                ; 6CC0
        inc    r0                                    ; 6CC1
        orl    a, @r0                                ; 6CC2
        inc    r0                                    ; 6CC3
        orl    a, @r0                                ; 6CC4
        ret                                          ; 6CC5

i24_test_r1::
        dec    r1                                    ; 6CC6
        dec    r1                                    ; 6CC7
        mov    a, @r1                                ; 6CC8
        inc    r1                                    ; 6CC9
        orl    a, @r1                                ; 6CCA
        inc    r1                                    ; 6CCB
        orl    a, @r1                                ; 6CCC
        ret                                          ; 6CCD

i24_dec_r0::
        dec    r0                                    ; 6CCE
        dec    r0                                    ; 6CCF
        dec    @r0                                   ; 6CD0
        cjne   @r0, #0xFF, L_6CE0                    ; 6CD1
        inc    r0                                    ; 6CD4
        dec    @r0                                   ; 6CD5
        cjne   @r0, #0xFF, L_6CE1                    ; 6CD6
        inc    r0                                    ; 6CD9
        dec    @r0                                   ; 6CDA
        cjne   @r0, #0xFF, L_6CE2                    ; 6CDB
        setb   c                                     ; 6CDE
        ret                                          ; 6CDF
L_6CE0::
        inc    r0                                    ; 6CE0
L_6CE1::
        inc    r0                                    ; 6CE1
L_6CE2::
        clr    c                                     ; 6CE2
        ret                                          ; 6CE3

i24_dec_r1::
        dec    r1                                    ; 6CE4
        dec    r1                                    ; 6CE5
        dec    @r1                                   ; 6CE6
        cjne   @r1, #0xFF, L_6CF6                    ; 6CE7
        inc    r1                                    ; 6CEA
        dec    @r1                                   ; 6CEB
        cjne   @r1, #0xFF, L_6CF7                    ; 6CEC
        inc    r1                                    ; 6CEF
        dec    @r1                                   ; 6CF0
        cjne   @r1, #0xFF, L_6CF8                    ; 6CF1
        setb   c                                     ; 6CF4
        ret                                          ; 6CF5
L_6CF6::
        inc    r1                                    ; 6CF6
L_6CF7::
        inc    r1                                    ; 6CF7
L_6CF8::
        clr    c                                     ; 6CF8
        ret                                          ; 6CF9

i24_inc_r0::
        dec    r0                                    ; 6CFA
        dec    r0                                    ; 6CFB
        inc    @r0                                   ; 6CFC
        cjne   @r0, #0x00, L_6CE0                    ; 6CFD
        inc    r0                                    ; 6D00
        inc    @r0                                   ; 6D01
        cjne   @r0, #0x00, L_6CE1                    ; 6D02
        inc    r0                                    ; 6D05
        inc    @r0                                   ; 6D06
        cjne   @r0, #0x00, L_6CE2                    ; 6D07
        setb   c                                     ; 6D0A
        ret                                          ; 6D0B

i24_inc_r1::
        dec    r1                                    ; 6D0C
        dec    r1                                    ; 6D0D
        inc    @r1                                   ; 6D0E
        cjne   @r1, #0x00, L_6CF6                    ; 6D0F
        inc    r1                                    ; 6D12
        inc    @r1                                   ; 6D13
        cjne   @r1, #0x00, L_6CF7                    ; 6D14
        inc    r1                                    ; 6D17
        inc    @r1                                   ; 6D18
        cjne   @r1, #0x00, L_6CF8                    ; 6D19
        setb   c                                     ; 6D1C
        ret                                          ; 6D1D

xdata_clear3::
        clr    a                                     ; 6D1E
        movx   @dptr, a                              ; 6D1F
        inc    dptr                                  ; 6D20
        movx   @dptr, a                              ; 6D21
        inc    dptr                                  ; 6D22
        movx   @dptr, a                              ; 6D23
        ret                                          ; 6D24

; C=1 if 3 bytes at DPTR are zero
xdata_is_zero3::
        movx   a, @dptr                              ; 6D25
        jnz    L_6D32                                ; 6D26
        inc    dptr                                  ; 6D28
        movx   a, @dptr                              ; 6D29
        jnz    L_6D32                                ; 6D2A
        inc    dptr                                  ; 6D2C
        movx   a, @dptr                              ; 6D2D
        jnz    L_6D32                                ; 6D2E
        setb   c                                     ; 6D30
        ret                                          ; 6D31
L_6D32::
        clr    c                                     ; 6D32
        ret                                          ; 6D33

; copy R2 bytes XDATA@DPTR -> IRAM@R0
xdata_to_iram::
        movx   a, @dptr                              ; 6D34
        mov    @r0, a                                ; 6D35
        inc    r0                                    ; 6D36
        inc    dptr                                  ; 6D37
        djnz   r2, xdata_to_iram                     ; 6D38
        ret                                          ; 6D3A

; copy R2 bytes IRAM@R0 -> XDATA@DPTR
iram_to_xdata::
        mov    a, @r0                                ; 6D3B
        movx   @dptr, a                              ; 6D3C
        inc    r0                                    ; 6D3D
        inc    dptr                                  ; 6D3E
        djnz   r2, iram_to_xdata                     ; 6D3F
        ret                                          ; 6D41

; exchange R2 bytes
xdata_swap_iram::
        movx   a, @dptr                              ; 6D42
        xch    a, @r0                                ; 6D43
        movx   @dptr, a                              ; 6D44
        inc    r0                                    ; 6D45
        inc    dptr                                  ; 6D46
        djnz   r2, xdata_swap_iram                   ; 6D47
        ret                                          ; 6D49

xdata_block_xfer::
        inc    r1                                    ; 6D4A
L_6D4B::
        movx   a, @dptr                              ; 6D4B
        xch    a, sfr_DPL                            ; 6D4C
        xch    a, r2                                 ; 6D4E
        xch    a, sfr_DPL                            ; 6D4F
        xch    a, sfr_DPH                            ; 6D51
        xch    a, r3                                 ; 6D53
        xch    a, sfr_DPH                            ; 6D54
        jnc    L_6D5B                                ; 6D56
        xch    a, r4                                 ; 6D58
        movx   a, @dptr                              ; 6D59
        xch    a, r4                                 ; 6D5A
L_6D5B::
        movx   @dptr, a                              ; 6D5B
        inc    dptr                                  ; 6D5C
        xch    a, sfr_DPL                            ; 6D5D
        xch    a, r2                                 ; 6D5F
        xch    a, sfr_DPL                            ; 6D60
        xch    a, sfr_DPH                            ; 6D62
        xch    a, r3                                 ; 6D64
        xch    a, sfr_DPH                            ; 6D65
        jnc    L_6D6B                                ; 6D67
        xch    a, r4                                 ; 6D69
        movx   @dptr, a                              ; 6D6A
L_6D6B::
        inc    dptr                                  ; 6D6B
        djnz   r0, L_6D4B                            ; 6D6C
        djnz   r1, L_6D4B                            ; 6D6E
        ret                                          ; 6D70

add16_r6r7_r4r5::
        mov    a, r5                                 ; 6D71
        add    a, r7                                 ; 6D72
        mov    r7, a                                 ; 6D73
        mov    a, r4                                 ; 6D74
        addc   a, r6                                 ; 6D75
        mov    r6, a                                 ; 6D76
        ret                                          ; 6D77

; DPTR += A
dptr_add_a::
        add    a, sfr_DPL                            ; 6D78
        mov    sfr_DPL, a                            ; 6D7A
        jnc    L_6D80                                ; 6D7C
        inc    sfr_DPH                               ; 6D7E
L_6D80::
        ret                                          ; 6D80

; DPTR += R6:R7
dptr_add_r6r7::
        mov    a, r7                                 ; 6D81
        add    a, sfr_DPL                            ; 6D82
        mov    sfr_DPL, a                            ; 6D84
        mov    a, r6                                 ; 6D86
        addc   a, sfr_DPH                            ; 6D87
        mov    sfr_DPH, a                            ; 6D89
        ret                                          ; 6D8B

; DPTR += A*B (table index)
dptr_add_a_mul_b::
        mul    ab                                    ; 6D8C
        add    a, sfr_DPL                            ; 6D8D
        mov    sfr_DPL, a                            ; 6D8F
        mov    a, sfr_DPH                            ; 6D91
        addc   a, sfr_B                              ; 6D93
        mov    sfr_DPH, a                            ; 6D95
        ret                                          ; 6D97

shl16_r6r7::
        jz     L_6DAA                                ; 6D98
        push   sfr_B                                 ; 6D9A
        mov    sfr_B, a                              ; 6D9C
L_6D9E::
        clr    c                                     ; 6D9E
        mov    a, r7                                 ; 6D9F
        rlc    a                                     ; 6DA0
        mov    r7, a                                 ; 6DA1
        mov    a, r6                                 ; 6DA2
        rlc    a                                     ; 6DA3
        mov    r6, a                                 ; 6DA4
        djnz   sfr_B, L_6D9E                         ; 6DA5
        pop    sfr_B                                 ; 6DA8
L_6DAA::
        ret                                          ; 6DAA

        .area   PINNED  (ABS,CODE)
        .org    0x6DAB
reply_strings::
        .db 0x13, 0x14, 0x15, 0x16, 0x1A, 0x1B, 0x1C, 0x1E, 0x1F, 0x25, 0x24, 0x4F, 0x46, 0x46, 0x2C, 0x23 ; 6DAB .........%$OFF,#
        .db 0x20, 0x4F, 0x4E, 0x2C, 0x23                                                     ; 6DBB  ON,#
range_decimal_table::
        .db 0x00, 0x01, 0x02, 0x03, 0x04, 0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03, 0x04, 0x00, 0x00, 0x00 ; 6DC0 ................
        .db 0x03, 0x01, 0x02, 0x03, 0x04, 0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03, 0x04, 0x00, 0x00, 0x00 ; 6DD0 ................
        .db 0x03, 0x01, 0x02, 0x03, 0x01, 0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03, 0x01, 0x02, 0x03, 0x00 ; 6DE0 ................
        .db 0x00, 0x01, 0x02, 0x03, 0x01, 0x02, 0x03, 0x00, 0x00, 0x01, 0x02, 0x03, 0x01, 0x02, 0x03, 0x00 ; 6DF0 ................
        .db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00, 0x00, 0x00, 0x02, 0x03, 0x01, 0x02, 0x03, 0x04 ; 6E00 ................
        .db 0x00, 0x00, 0x02, 0x03, 0x01, 0x02, 0x03, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 6E10 ................
        .db 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 6E20 ................
        .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 6E30 ................
resolution_table::
        .db 0x00, 0x04, 0x00, 0x00, 0x04, 0x00, 0x00, 0x04, 0x00, 0x06, 0x05, 0x04, 0x00, 0x05, 0x04, 0x00 ; 6E40 ................
        .db 0x05, 0x04, 0x00, 0x05, 0x04, 0x00, 0x05, 0x04, 0x00, 0x05, 0x04, 0x00, 0x05, 0x04, 0x00, 0x06 ; 6E50 ................
        .db 0x00, 0x00, 0x06, 0x00, 0x00, 0x06, 0x00, 0x00, 0x06, 0x00, 0x00, 0x05, 0x04, 0x06, 0x05, 0x00 ; 6E60 ................
        .db 0x04, 0x03, 0x00, 0x00, 0x05, 0x04, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20 ; 6E70 ............... 
        .db 0x43, 0x4C, 0x4F, 0x53, 0x45, 0x44, 0x23, 0x20, 0x20, 0x20, 0x4F, 0x50, 0x45, 0x4E, 0x23, 0x20 ; 6E80 CLOSED#   OPEN# 
        .db 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x45, 0x2B, 0x30, 0x39, 0x23, 0x20, 0x20, 0x20 ; 6E90 99999999E+09#   
        .db 0x20, 0x41, 0x55, 0x54, 0x4F, 0x23, 0x20, 0x32, 0x30, 0x2E, 0x45, 0x2B, 0x30, 0x36, 0x23, 0x2C ; 6EA0  AUTO# 20.E+06#,
        .db 0x23, 0x2C, 0x23, 0x49, 0x23, 0x42, 0x23, 0x45, 0x23, 0x3F, 0x23, 0x4F, 0x4E, 0x2C, 0x31, 0x23 ; 6EB0 #,#I#B#E#?#ON,1#
        .db 0x4F, 0x4E, 0x2C, 0x30, 0x23, 0x20, 0x4F, 0x46, 0x46, 0x23, 0x4E, 0x23, 0x53, 0x23, 0x4E, 0x23 ; 6EC0 ON,0# OFF#N#S#N#
        .db 0x45, 0x23, 0x20, 0x23                                                           ; 6ED0 E# #
valid_range_masks::
        .db 0x00, 0x1E, 0x00, 0x1F, 0x1F, 0x1F, 0x00, 0x1F, 0x1F, 0x00, 0x1F, 0x1F, 0x00, 0x1F, 0x1F, 0x00 ; 6ED4 ................
        .db 0x7F, 0x7F, 0x00, 0x7E, 0x7E, 0x00, 0x7E, 0x7E, 0x00, 0x7E, 0x00, 0x00, 0xFC, 0x3C, 0x7C, 0x7C ; 6EE4 ...~~.~~.~...<||
        .db 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 6EF4 ................
T_6F04::
        .db 0x1E, 0x1F, 0x1F, 0x1F, 0x1F, 0x7F, 0x7E, 0x7E, 0x7E, 0xFC, 0x7C, 0x01, 0x01, 0x01, 0x60, 0x00 ; 6F04 ......~~~.|...`.
T_6F14::
        .db 0x29, 0x28, 0x28, 0x28, 0x2B, 0x2B, 0x03, 0x03, 0x09, 0x21, 0x0D, 0x2C, 0x29, 0x2B, 0x09, 0x00 ; 6F14 )(((++...!.,)+..
T_6F24::
        .db 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF ; 6F24 ................
        .db 0xDF, 0xDF, 0xDF, 0x00, 0x41, 0xC9, 0xC9, 0x00, 0x00, 0x08, 0xC9, 0xC9, 0x41, 0x00, 0xD1, 0x00 ; 6F34 ....A.......A...
        .db 0x00, 0x00, 0x00, 0x41, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x41, 0x41, 0x00, 0x00, 0x00 ; 6F44 ...A......AAA...
        .db 0x00, 0xBB, 0xCC, 0xCC, 0xCC                                                     ; 6F54 .....
T_6F59::
        .db 0x00, 0x80, 0x00, 0x00, 0x3A, 0xCC, 0xCC, 0xCC                                   ; 6F59 ....:...
T_6F61::
        .db 0x3B, 0xCA, 0xC0, 0x83, 0x3C, 0x99, 0x99, 0x99                                   ; 6F61 ;...<...
T_6F69::
        .db 0x3C, 0xCC, 0xCC, 0xCC, 0x3D, 0x80, 0x00, 0x00                                   ; 6F69 <...=...
T_6F71::
        .db 0x3E, 0x80, 0x00, 0x00                                                           ; 6F71 >...
T_6F75::
        .db 0x3E, 0xAE, 0x14, 0x7A                                                           ; 6F75 >..z
T_6F79::
        .db 0x3E, 0xC0, 0x00, 0x00                                                           ; 6F79 >...
T_6F7D::
        .db 0x3E, 0xCC, 0xCC, 0xCC                                                           ; 6F7D >...
T_6F81::
        .db 0x3E, 0xCF, 0x5C, 0x28                                                           ; 6F81 >.\(
T_6F85::
        .db 0x3E, 0xE6, 0x66, 0x66                                                           ; 6F85 >.ff
T_6F89::
        .db 0x3E, 0xFD, 0x70, 0xA3                                                           ; 6F89 >.p.
T_6F8D::
        .db 0x3F, 0x81, 0x47, 0xAE                                                           ; 6F8D ?.G.
T_6F91::
        .db 0x3F, 0x8C, 0xCC, 0xCC                                                           ; 6F91 ?...
T_6F95::
        .db 0x3F, 0x98, 0x51, 0xEB                                                           ; 6F95 ?.Q.
T_6F99::
        .db 0x3F, 0x99, 0x99, 0x99, 0x3F, 0xA0, 0x00, 0x00                                   ; 6F99 ?...?...
T_6FA1::
        .db 0x3F, 0xA8, 0xF5, 0xC2, 0x3F, 0xC0, 0x00, 0x00                                   ; 6FA1 ?...?...
T_6FA9::
        .db 0x41, 0xA0, 0x00, 0x00, 0x44, 0xC8, 0x00, 0x00                                   ; 6FA9 A...D...
T_6FB1::
        .db 0x48, 0x96, 0x00, 0x00, 0x57, 0xE4, 0xE1, 0xC0                                   ; 6FB1 H...W...
T_6FB9::
        .db 0x72, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00                                         ; 6FB9 r......
const_fp_table::
        .db 0x7F, 0xFF, 0xFF, 0xFF                                                           ; 6FC0 ....
T_6FC4::
        .db 0xFF, 0xFF, 0xFF, 0xFF                                                           ; 6FC4 ....
T_6FC8::
        .db 0xE6, 0xE8, 0xD4, 0xA4                                                           ; 6FC8 ....
T_6FCC::
        .db 0x66, 0xE8, 0xD4, 0xA4                                                           ; 6FCC f...
T_6FD0::
        .db 0x00, 0x80, 0x00, 0x00                                                           ; 6FD0 ....
T_6FD4::
        .db 0x31, 0xD1, 0xB7, 0x17                                                           ; 6FD4 1...
T_6FD8::
        .db 0x4C, 0x9C, 0x3C, 0x00                                                           ; 6FD8 L.<.
T_6FDC::
        .db 0x48, 0x96, 0x00, 0x00, 0x00, 0x00, 0x01                                         ; 6FDC H......
T_6FE3::
        .db 0x00, 0x00, 0x0A                                                                 ; 6FE3 ...
T_6FE6::
        .db 0x00, 0x00, 0x64                                                                 ; 6FE6 ..d
range_count_limits::
        .db 0x00, 0x03, 0xE8                                                                 ; 6FE9 ...
T_6FEC::
        .db 0x00, 0x00, 0x03                                                                 ; 6FEC ...
T_6FEF::
        .db 0x00, 0x00, 0x08                                                                 ; 6FEF ...
T_6FF2::
        .db 0x00, 0x00, 0x32                                                                 ; 6FF2 ..2
T_6FF5::
        .db 0x00, 0x00, 0x5A                                                                 ; 6FF5 ..Z
T_6FF8::
        .db 0x00, 0x00, 0x67                                                                 ; 6FF8 ..g
T_6FFB::
        .db 0x00, 0x00, 0xB4                                                                 ; 6FFB ...
T_6FFE::
        .db 0x00, 0x00, 0xC8                                                                 ; 6FFE ...
T_7001::
        .db 0x00, 0x03, 0x84                                                                 ; 7001 ...
T_7004::
        .db 0x00, 0x03, 0xEB                                                                 ; 7004 ...
T_7007::
        .db 0x00, 0x04, 0x4C                                                                 ; 7007 ..L
T_700A::
        .db 0x00, 0x07, 0x08                                                                 ; 700A ...
T_700D::
        .db 0x00, 0x07, 0xD0                                                                 ; 700D ...
T_7010::
        .db 0x00, 0x08, 0x34                                                                 ; 7010 ..4
T_7013::
        .db 0x00, 0x0F, 0xA0                                                                 ; 7013 ...
T_7016::
        .db 0x00, 0x23, 0x28                                                                 ; 7016 .#(
T_7019::
        .db 0x00, 0x27, 0x10                                                                 ; 7019 .'.
T_701C::
        .db 0x00, 0x2A, 0xF8, 0x00, 0x46, 0x50                                               ; 701C .*..FP
T_7022::
        .db 0x00, 0x4E, 0x20                                                                 ; 7022 .N 
T_7025::
        .db 0x00, 0x52, 0x08                                                                 ; 7025 .R.
T_7028::
        .db 0x01, 0x86, 0xA0                                                                 ; 7028 ...
T_702B::
        .db 0x01, 0xAD, 0xB0                                                                 ; 702B ...
T_702E::
        .db 0x03, 0x0D, 0x40                                                                 ; 702E ..@
T_7031::
        .db 0x03, 0x34, 0x50                                                                 ; 7031 .4P
T_7034::
        .db 0x00, 0x00, 0x0A                                                                 ; 7034 ...
T_7037::
        .db 0x00, 0x00, 0x0A                                                                 ; 7037 ...
T_703A::
        .db 0x00, 0x03, 0xE8, 0x00, 0x00, 0x10                                               ; 703A ......
T_7040::
        .db 0x00, 0x00, 0x64                                                                 ; 7040 ..d
adc_count_time_norm::
        .db 0x00, 0x72, 0xB0                                                                 ; 7043 .r.
adc_count_time_fast::
        .db 0x00, 0x0B, 0x78                                                                 ; 7046 ..x
freq_corr_latency::
        .db 0x3E, 0xC3, 0x4E, 0x17                                                           ; 7049 >.N.
T_704D::
        .db 0x3E, 0xF4, 0x22, 0x82                                                           ; 704D >.".
T_7051::
        .db 0x3E, 0xC3, 0x46, 0x77                                                           ; 7051 >.Fw
freq_corr_1s::
        .db 0x3E, 0xF4, 0x24, 0x00                                                           ; 7055 >.$.
freq_corr_131ms::
        .db 0x3E, 0xC3, 0x45, 0xFF                                                           ; 7059 >.E.
T_705D::
        .db 0x3C, 0x87, 0xB7, 0x40                                                           ; 705D <..@
T_7061::
        .db 0x3F, 0xAB, 0x2B, 0xED                                                           ; 7061 ?.+.
T_7065::
        .db 0x49, 0xFA, 0x00, 0x00                                                           ; 7065 I...
T_7069::
        .db 0x4F, 0x80, 0x00, 0x00                                                           ; 7069 O...
T_706D::
        .db 0x45, 0xDC, 0x00, 0x00                                                           ; 706D E...
T_7071::
        .db 0x4D, 0x86, 0xA7, 0x2B                                                           ; 7071 M..+
T_7075::
        .db 0x56, 0xC7, 0x5E, 0xF7                                                           ; 7075 V.^.
T_7079::
        .db 0x4A, 0xD2, 0x7D, 0x9B                                                           ; 7079 J.}.
T_707D::
        .db 0x50, 0xC3, 0x50, 0x00                                                           ; 707D P.P.
T_7081::
        .db 0x3E, 0xFC, 0xAC, 0x08                                                           ; 7081 >...
T_7085::
        .db 0x3F, 0x81, 0xA9, 0xFB                                                           ; 7085 ?...
T_7089::
        .db 0x4D, 0xF1, 0x36, 0x00                                                           ; 7089 M.6.
T_708D::
        .db 0x4D, 0xF3, 0x54, 0x00                                                           ; 708D M.T.
T_7091::
        .db 0x4B, 0x98, 0x58, 0x00                                                           ; 7091 K.X.
T_7095::
        .db 0x4A, 0xFD, 0xF0, 0x00, 0x4B, 0xFD, 0xE8, 0x00, 0x4C, 0x94, 0x1C, 0x00           ; 7095 J...K...L...
T_70A1::
        .db 0x4A, 0xB1, 0xBC, 0x00                                                           ; 70A1 J...
T_70A5::
        .db 0x4A, 0x94, 0x1C, 0x7A                                                           ; 70A5 J..z
T_70A9::
        .db 0x4C, 0xDE, 0x2B, 0x00                                                           ; 70A9 L.+.
T_70AD::
        .db 0x4C, 0xD8, 0xE0, 0xE1                                                           ; 70AD L...
T_70B1::
        .db 0x4C, 0xC4, 0xC7, 0x00                                                           ; 70B1 L...
T_70B5::
        .db 0x4C, 0xC3, 0xB8, 0x1E                                                           ; 70B5 L...
T_70B9::
        .db 0x3F, 0xC0, 0x00, 0x00                                                           ; 70B9 ?...
T_70BD::
        .db 0x3D, 0x99, 0x99, 0x99                                                           ; 70BD =...
T_70C1::
        .db 0x3E, 0xB3, 0x33, 0x33                                                           ; 70C1 >.33
T_70C5::
        .db 0x3D, 0x9E, 0xB8, 0x51                                                           ; 70C5 =..Q
T_70C9::
        .db 0x3E, 0xB0, 0xA3, 0xD7, 0x45, 0xC8, 0x00, 0x00, 0x4A, 0xC8, 0x00, 0x00           ; 70C9 >...E...J...
T_70D5::
        .db 0x00, 0x00, 0x56, 0x56, 0x98, 0x96, 0x76                                         ; 70D5 ..VV..v
T_70DC::
        .db 0x66, 0xE8, 0xD0, 0x2D, 0x6A, 0x91, 0x82, 0x1C                                   ; 70DC f..-j...
msg_table::
        .db 0x20, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x23                             ; 70E4  -------#
T_70ED::
        .db 0x20, 0x2D, 0x4F, 0x4C, 0x2D, 0x2D, 0x2D, 0x2D, 0x23                             ; 70ED  -OL----#
T_70F6::
        .db 0x20, 0x2D, 0x55, 0x4C, 0x2D, 0x2D, 0x2D, 0x2D, 0x23                             ; 70F6  -UL----#
T_70FF::
        .db 0x20, 0x46, 0x41, 0x49, 0x4C, 0x20, 0x20, 0x20, 0x23                             ; 70FF  FAIL   #
T_7108::
        .db 0x20, 0x2D, 0x4F, 0x46, 0x4C, 0x2D, 0x2D, 0x2D, 0x23                             ; 7108  -OFL---#
T_7111::
        .db 0x20, 0x45, 0x72, 0x72, 0x6F, 0x72, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 7111  Error      #
T_711E::
        .db 0x20, 0x41, 0x44, 0x44, 0x72, 0x20, 0x2D, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 711E  ADDr -     #
T_712B::
        .db 0x20, 0x72, 0x54, 0x4C, 0x20, 0x30, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 712B  rTL 0      #
T_7138::
        .db 0x20, 0x54, 0x2E, 0x4F, 0x4E, 0x4C, 0x59, 0x20, 0x30, 0x20, 0x20, 0x20, 0x23     ; 7138  T.ONLY 0   #
T_7145::
        .db 0x20, 0x20, 0x43, 0x72, 0x20, 0x20, 0x30, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 7145   Cr  0     #
T_7152::
        .db 0x20, 0x4F, 0x50, 0x45, 0x4E, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 7152  OPEN       #
T_715F::
        .db 0x20, 0x43, 0x4C, 0x4F, 0x53, 0x45, 0x44, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 715F  CLOSED     #
T_716C::
        .db 0x20, 0x36, 0x30, 0x48, 0x20, 0x20, 0x30, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 716C  60H  0     #
T_7179::
        .db 0x20, 0x53, 0x4F, 0x46, 0x54, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 7179  SOFT       #
T_7186::
        .db 0x20, 0x20, 0x20                                                                 ; 7186    
T_7189::
        .db 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23                       ; 7189          #
T_7193::
        .db 0x20, 0x43, 0x41, 0x4C, 0x20, 0x30, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x23     ; 7193  CAL 0      #
T_71A0::
        .db 0x20, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x43, 0x23                             ; 71A0  000000C#
T_71A9::
        .db 0x20, 0x31, 0x30, 0x30, 0x30, 0x30, 0x30, 0x43, 0x23                             ; 71A9  100000C#
T_71B2::
        .db 0x20, 0x32, 0x30, 0x30, 0x30, 0x30, 0x30, 0x43, 0x23                             ; 71B2  200000C#
T_71BB::
        .db 0x20, 0x20, 0x33, 0x30, 0x30, 0x30, 0x30, 0x43, 0x23                             ; 71BB   30000C#
T_71C4::
        .db 0x20, 0x20, 0x36, 0x30, 0x30, 0x30, 0x30, 0x43, 0x23                             ; 71C4   60000C#
T_71CD::
        .db 0x01, 0xD8, 0xF0                                                                 ; 71CD ...
T_71D0::
        .db 0x01, 0xB1, 0xE0                                                                 ; 71D0 ...
T_71D3::
        .db 0x01, 0x63, 0xC0                                                                 ; 71D3 .c.
T_71D6::
        .db 0x01, 0x3C, 0xB0                                                                 ; 71D6 .<.
T_71D9::
        .db 0x02, 0x79, 0x60                                                                 ; 71D9 .y`
T_71DC::
        .db 0x03, 0xDD, 0x20                                                                 ; 71DC .. 
T_71DF::
        .db 0x03, 0xB6, 0x10                                                                 ; 71DF ...
T_71E2::
        .db 0x04, 0xF2, 0xC0                                                                 ; 71E2 ...
T_71E5::
        .db 0x06, 0xF6, 0xF0                                                                 ; 71E5 ...
T_71E8::
        .db 0x08, 0x5E, 0xE0                                                                 ; 71E8 .^.
T_71EB::
        .db 0x12, 0x9A, 0xE0, 0x08, 0x08, 0x02, 0x00, 0x02, 0x04, 0x02, 0x08, 0x02, 0x0C, 0x02, 0x10, 0x02 ; 71EB ................
        .db 0x14, 0x08, 0x08, 0x02, 0x18, 0x02, 0x1C, 0x02, 0x20, 0x02, 0x24, 0x02, 0x28, 0x02, 0x2C, 0x5B ; 71FB ........ .$.(.,[
        .db 0x08                                                                             ; 720B .
        .dw T_692B                                                                           ; 720C pointer
        .db 0x02, 0x00, 0x02, 0x64, 0x02, 0x04, 0x02, 0x4C, 0x02, 0x08, 0x02, 0x0C           ; 720E ...d...L....
        .dw T_692B                                                                           ; 721A pointer
        .db 0x02, 0x10, 0x02, 0x14, 0x5B, 0x08                                               ; 721C ....[.
        .dw T_692B                                                                           ; 7222 pointer
        .db 0x02, 0x18, 0x02, 0x64, 0x02, 0x1C, 0x02, 0x4C, 0x02, 0x20, 0x02, 0x24           ; 7224 ...d...L. .$
        .dw T_692B                                                                           ; 7230 pointer
        .db 0x02, 0x28, 0x02, 0x2C, 0x5B, 0x08                                               ; 7232 .(.,[.
        .dw T_692F                                                                           ; 7238 pointer
        .db 0x02, 0x00, 0x02, 0x84, 0x02, 0x04, 0x02, 0x4C, 0x02, 0x08, 0x02, 0x0C           ; 723A .......L....
        .dw T_692F                                                                           ; 7246 pointer
        .db 0x02, 0x10, 0x02, 0x14, 0x5B, 0x08                                               ; 7248 ....[.
        .dw T_692F                                                                           ; 724E pointer
        .db 0x02, 0x18, 0x02, 0x84, 0x02, 0x1C, 0x02, 0x4C, 0x02, 0x20, 0x02, 0x24           ; 7250 .......L. .$
        .dw T_692F                                                                           ; 725C pointer
        .db 0x02, 0x28, 0x02, 0x2C, 0x5B, 0x08                                               ; 725E .(.,[.
        .dw T_6933                                                                           ; 7264 pointer
        .db 0x02, 0x00, 0x02, 0x94, 0x02, 0x04, 0x02, 0x4C, 0x02, 0x08, 0x02, 0x0C           ; 7266 .......L....
        .dw T_6933                                                                           ; 7272 pointer
        .db 0x02, 0x10, 0x02, 0x14, 0x5B, 0x08                                               ; 7274 ....[.
        .dw T_6933                                                                           ; 727A pointer
        .db 0x02, 0x18, 0x02, 0x94, 0x02, 0x1C, 0x02, 0x4C, 0x02, 0x20, 0x02, 0x24           ; 727C .......L. .$
        .dw T_6933                                                                           ; 7288 pointer
        .db 0x02, 0x28, 0x02, 0x2C, 0x08, 0x08, 0x02, 0x30, 0x02, 0x34, 0x02, 0x38, 0x02, 0x3C, 0x02, 0x40 ; 728A .(.,...0.4.8.<.@
        .db 0x02, 0x44, 0x58, 0x08, 0x02, 0x30, 0x02, 0x78, 0x02, 0x34, 0x02, 0x64, 0x02, 0x38, 0x02, 0x3C ; 729A .DX..0.x.4.d.8.<
        .db 0x02, 0x40, 0x02, 0x44, 0x08, 0x08, 0x02, 0x48, 0x02, 0x4C, 0x02, 0x50, 0x02, 0x54, 0x02, 0x58 ; 72AA .@.D...H.L.P.T.X
        .db 0x02, 0x5C, 0x58, 0x08, 0x02, 0x48, 0x02, 0x78, 0x02, 0x4C, 0x02, 0x64, 0x02, 0x50, 0x02, 0x54 ; 72BA .\X..H.x.L.d.P.T
        .db 0x02, 0x58, 0x02, 0x5C, 0x08, 0x08, 0x02, 0x60, 0x02, 0x64, 0x02, 0x68, 0x02, 0x6C, 0x02, 0x70 ; 72CA .X.\...`.d.h.l.p
        .db 0x02, 0x74, 0x08, 0x08, 0x02, 0x60, 0x02, 0x78, 0x02, 0x68, 0x02, 0x7C, 0x02, 0x70, 0x02, 0x74 ; 72DA .t...`.x.h.|.p.t
        .db 0x08, 0x08, 0x02, 0x80, 0x02, 0x84, 0x02, 0x88, 0x02, 0x8C, 0x02, 0x90, 0x02, 0x74, 0x58, 0x08 ; 72EA .............tX.
        .db 0x02, 0x80, 0x02, 0x78, 0x02, 0x84, 0x02, 0x64, 0x02, 0x88, 0x02, 0x8C, 0x02, 0x90, 0x02, 0x74 ; 72FA ...x...d.......t
        .db 0x0B, 0x08                                                                       ; 730A ..
        .dw T_692B                                                                           ; 730C pointer
        .db 0x02, 0x80, 0x02, 0x94, 0x02, 0x88, 0x02, 0x98                                   ; 730E ........
        .dw T_692B                                                                           ; 7316 pointer
        .db 0x02, 0x90, 0x02, 0x74, 0x5B, 0x08                                               ; 7318 ...t[.
        .dw T_692B                                                                           ; 731E pointer
        .db 0x02, 0x80, 0x02, 0x78, 0x02, 0x94, 0x02, 0x64, 0x02, 0x88, 0x02, 0x98           ; 7320 ...x...d....
        .dw T_692B                                                                           ; 732C pointer
        .db 0x02, 0x90, 0x02, 0x74, 0x0A, 0x09, 0x6F, 0x59, 0x02, 0x9C, 0x6F, 0x71, 0x02, 0xA0, 0x6F, 0x59 ; 732E ...t..oY..oq..oY
        .db 0x02, 0xAC, 0x0A, 0x09, 0x6F, 0x59, 0x02, 0xA4, 0x6F, 0x71, 0x02, 0xA8, 0x6F, 0x59, 0x02, 0xAC ; 733E ....oY..oq..oY..
        .db 0x0A, 0x09, 0x6F, 0x59, 0x02, 0xB0, 0x6F, 0x71, 0x02, 0xB4, 0x6F, 0x59, 0x02, 0xAC, 0x0A, 0x09 ; 734E ..oY..oq..oY....
        .db 0x6F, 0x59, 0x02, 0xB8, 0x6F, 0x71, 0x02, 0xBC, 0x6F, 0x59, 0x02, 0xAC, 0x0A, 0x09, 0x6F, 0x59 ; 735E oY..oq..oY....oY
        .db 0x02, 0xC0, 0x6F, 0x71, 0x02, 0xC4, 0x6F, 0x59, 0x02, 0xAC, 0x0A, 0x09, 0x6F, 0x59, 0x02, 0x9C ; 736E ..oq..oY....oY..
        .db 0x6F, 0x71, 0x02, 0xA0, 0x6F, 0x59, 0x02, 0xAC, 0x0A, 0x09, 0x6F, 0x59, 0x02, 0xA4, 0x6F, 0x71 ; 737E oq..oY....oY..oq
        .db 0x02, 0xA8, 0x6F, 0x59, 0x02, 0xAC, 0x0A, 0x09, 0x6F, 0x59, 0x02, 0xB0, 0x6F, 0x71, 0x02, 0xB4 ; 738E ..oY....oY..oq..
        .db 0x6F, 0x59, 0x02, 0xAC, 0x0A, 0x09, 0x6F, 0x59, 0x02, 0xB8, 0x6F, 0x71, 0x02, 0xBC, 0x6F, 0x59 ; 739E oY....oY..oq..oY
        .db 0x02, 0xAC, 0x0A, 0x09, 0x6F, 0x59, 0x02, 0xC0, 0x6F, 0x71, 0x02, 0xC4, 0x6F, 0x59, 0x02, 0xAC ; 73AE ....oY..oq..oY..
        .db 0x58, 0x08, 0x02, 0xC8, 0x02, 0x34, 0x02, 0xD4, 0x02, 0x4C, 0x02, 0xCC, 0x02, 0xD8, 0x02, 0xD0 ; 73BE X....4...L......
        .db 0x02, 0xDC, 0x08, 0x08, 0x02, 0xC8, 0x02, 0xD4, 0x02, 0xCC, 0x02, 0xD8, 0x02, 0xD0, 0x02, 0xDC ; 73CE ................
        .db 0x0B, 0x08                                                                       ; 73DE ..
        .dw T_692B                                                                           ; 73E0 pointer
        .db 0x02, 0xC8, 0x02, 0xE0, 0x02, 0xCC, 0x02, 0xE4                                   ; 73E2 ........
        .dw T_692B                                                                           ; 73EA pointer
        .db 0x02, 0xD0, 0x02, 0xE8, 0x0B, 0x08                                               ; 73EC ......
        .dw T_692F                                                                           ; 73F2 pointer
        .db 0x02, 0xC8, 0x02, 0xEC, 0x02, 0xCC, 0x02, 0xF0                                   ; 73F4 ........
        .dw T_692F                                                                           ; 73FC pointer
        .db 0x02, 0xD0, 0x02, 0xF4, 0x0B, 0x08                                               ; 73FE ......
        .dw T_6933                                                                           ; 7404 pointer
        .db 0x02, 0xC8, 0x02, 0xF8, 0x02, 0xCC, 0x02, 0xFC                                   ; 7406 ........
        .dw T_6933                                                                           ; 740E pointer
        .db 0x02, 0xD0, 0x03, 0x00, 0x58, 0x08, 0x03, 0xA4, 0x02, 0x34, 0x02, 0xD4, 0x02, 0x4C, 0x03, 0xA8 ; 7410 ....X....4...L..
        .db 0x02, 0xD8, 0x03, 0xAC, 0x02, 0xDC, 0x08, 0x08, 0x03, 0xB0, 0x02, 0xD4, 0x03, 0xB4, 0x02, 0xD8 ; 7420 ................
        .db 0x03, 0xB8, 0x02, 0xDC, 0x0B, 0x08                                               ; 7430 ......
        .dw T_692B                                                                           ; 7436 pointer
        .db 0x02, 0xC8, 0x02, 0xE0, 0x02, 0xCC, 0x02, 0xE4                                   ; 7438 ........
        .dw T_692B                                                                           ; 7440 pointer
        .db 0x02, 0xD0, 0x02, 0xE8, 0x0B, 0x08                                               ; 7442 ......
        .dw T_692F                                                                           ; 7448 pointer
        .db 0x02, 0xC8, 0x02, 0xEC, 0x02, 0xCC, 0x02, 0xF0                                   ; 744A ........
        .dw T_692F                                                                           ; 7452 pointer
        .db 0x02, 0xD0, 0x02, 0xF4, 0x0B, 0x08                                               ; 7454 ......
        .dw T_6933                                                                           ; 745A pointer
        .db 0x02, 0xC8, 0x02, 0xF8, 0x02, 0xCC, 0x02, 0xFC                                   ; 745C ........
        .dw T_6933                                                                           ; 7464 pointer
        .db 0x02, 0xD0, 0x03, 0x00, 0x0B, 0x08                                               ; 7466 ......
        .dw T_6937                                                                           ; 746C pointer
        .db 0x02, 0xC8, 0x03, 0x04, 0x02, 0xCC, 0x03, 0x08                                   ; 746E ........
        .dw T_6937                                                                           ; 7476 pointer
        .db 0x02, 0xD0, 0x03, 0x0C, 0x0B, 0x08                                               ; 7478 ......
        .dw T_693B                                                                           ; 747E pointer
        .db 0x02, 0xC8, 0x03, 0x10, 0x02, 0xCC, 0x03, 0x14                                   ; 7480 ........
        .dw T_693B                                                                           ; 7488 pointer
        .db 0x02, 0xD0, 0x03, 0x18, 0x08, 0x08, 0x03, 0x1C, 0x03, 0x20, 0x03, 0x24, 0x03, 0x28, 0x03, 0x2C ; 748A ......... .$.(.,
        .db 0x03, 0x30, 0x08, 0x08, 0x03, 0x1C, 0x03, 0x34, 0x03, 0x24, 0x03, 0x38, 0x03, 0x2C, 0x03, 0x3C ; 749A .0.....4.$.8.,.<
        .db 0x58, 0x08, 0x03, 0x40, 0x03, 0x20, 0x03, 0x4C, 0x03, 0x34, 0x03, 0x44, 0x03, 0x50, 0x03, 0x48 ; 74AA X..@. .L.4.D.P.H
        .db 0x03, 0x54, 0x08, 0x08, 0x03, 0x40, 0x03, 0x4C, 0x03, 0x44, 0x03, 0x50, 0x03, 0x48, 0x03, 0x54 ; 74BA .T...@.L.D.P.H.T
        .db 0x5B, 0x08                                                                       ; 74CA [.
        .dw T_6937                                                                           ; 74CC pointer
        .db 0x03, 0x1C, 0x03, 0x20, 0x03, 0x58, 0x03, 0x34, 0x03, 0x24, 0x03, 0x5C           ; 74CE ... .X.4.$.\
        .dw T_6937                                                                           ; 74DA pointer
        .db 0x03, 0x2C, 0x03, 0x60, 0x0B, 0x08                                               ; 74DC .,.`..
        .dw T_6937                                                                           ; 74E2 pointer
        .db 0x03, 0x1C, 0x03, 0x58, 0x03, 0x24, 0x03, 0x5C                                   ; 74E4 ...X.$.\
        .dw T_6937                                                                           ; 74EC pointer
        .db 0x03, 0x2C, 0x03, 0x60, 0x08, 0x08, 0x03, 0xBC, 0x03, 0x64, 0x03, 0xC0, 0x03, 0x68, 0x03, 0xC4 ; 74EE .,.`.....d...h..
        .db 0x03, 0x6C, 0x58, 0x08, 0x03, 0xBC, 0x03, 0x34, 0x03, 0x64, 0x03, 0x20, 0x03, 0xC0, 0x03, 0x68 ; 74FE .lX....4.d. ...h
        .db 0x03, 0xC4, 0x03, 0x6C, 0x5A, 0x09, 0x6F, 0x59, 0x03, 0x20, 0x03, 0x70, 0x03, 0x4C, 0x6F, 0x71 ; 750E ...lZ.oY. .p.Loq
        .db 0x03, 0x74, 0x6F, 0x59, 0x03, 0x78, 0x5A, 0x09, 0x6F, 0x59, 0x03, 0x34, 0x03, 0x70, 0x03, 0x4C ; 751E .toY.xZ.oY.4.p.L
        .db 0x6F, 0x71, 0x03, 0x74, 0x6F, 0x59, 0x03, 0x78, 0x5A, 0x09, 0x6F, 0x59, 0x03, 0x20, 0x03, 0x70 ; 752E oq.toY.xZ.oY. .p
        .db 0x03, 0x34, 0x6F, 0x71, 0x03, 0x74, 0x6F, 0x59, 0x03, 0x78, 0x0A, 0x09, 0x6F, 0x59, 0x03, 0x70 ; 753E .4oq.toY.x..oY.p
        .db 0x6F, 0x71, 0x03, 0x74, 0x6F, 0x59, 0x03, 0x78, 0xAA, 0x09, 0x6F, 0x59, 0x03, 0x20, 0x03, 0x58 ; 754E oq.toY.x..oY. .X
        .db 0x03, 0x70, 0x03, 0x34, 0x03, 0x4C, 0x6F, 0x71, 0x03, 0x74, 0x6F, 0x59, 0x03, 0x78, 0x5A, 0x09 ; 755E .p.4.Loq.toY.xZ.
        .db 0x6F, 0x59, 0x03, 0x58, 0x03, 0x70, 0x03, 0x4C, 0x6F, 0x71, 0x03, 0x74, 0x6F, 0x59, 0x03, 0x78 ; 756E oY.X.p.Loq.toY.x
        .db 0x5A, 0x09, 0x6F, 0x59, 0x03, 0x64, 0x03, 0x70, 0x03, 0x4C, 0x6F, 0x71, 0x03, 0x74, 0x6F, 0x59 ; 757E Z.oY.d.p.Loq.toY
        .db 0x03, 0x78, 0xAA, 0x09, 0x6F, 0x59, 0x03, 0x34, 0x03, 0x64, 0x03, 0x70, 0x03, 0x20, 0x03, 0x4C ; 758E .x..oY.4.d.p. .L
        .db 0x6F, 0x71, 0x03, 0x74, 0x6F, 0x59, 0x03, 0x78, 0x10, 0x51, 0x03, 0x7C, 0x02, 0xD4, 0x03, 0x04 ; 759E oq.toY.x.Q.|....
        .db 0x6F, 0x71, 0x02, 0xD8, 0x03, 0x84, 0x02, 0xDC, 0x03, 0x0C, 0x10, 0x51, 0x03, 0x7C, 0x02, 0xD4 ; 75AE oq.........Q.|..
        .db 0x02, 0xF8, 0x6F, 0x71, 0x02, 0xD8, 0x03, 0x84, 0x02, 0xDC, 0x03, 0x00, 0x10, 0x51, 0x03, 0x7C ; 75BE ..oq.........Q.|
        .db 0x02, 0xD4, 0x02, 0xF8, 0x6F, 0x71, 0x02, 0xD8, 0x03, 0x84, 0x02, 0xDC, 0x03, 0x00, 0x10, 0x51 ; 75CE ....oq.........Q
        .db 0x03, 0x7C, 0x02, 0xD4, 0x02, 0xEC, 0x6F, 0x71, 0x02, 0xD8, 0x03, 0x84, 0x02, 0xDC, 0x02, 0xF4 ; 75DE .|....oq........
        .db 0x10, 0x51, 0x03, 0x7C, 0x02, 0xD4, 0x02, 0xEC, 0x6F, 0x71, 0x02, 0xD8, 0x03, 0x84, 0x02, 0xDC ; 75EE .Q.|....oq......
        .db 0x02, 0xF4, 0x12, 0x51, 0x6F, 0x59, 0x02, 0xD4, 0x02, 0xE0, 0x6F, 0x71, 0x02, 0xD8, 0x6F, 0x59 ; 75FE ...QoY....oq..oY
        .db 0x02, 0xDC, 0x02, 0xE8, 0x12, 0x51, 0x6F, 0x59, 0x02, 0xD4, 0x02, 0xE0, 0x6F, 0x71, 0x02, 0xD8 ; 760E .....QoY....oq..
        .db 0x6F, 0x59, 0x02, 0xDC, 0x02, 0xE8, 0x0E, 0x0F, 0x6F, 0x59                       ; 761E oY......oY
        .dw T_6927                                                                           ; 7628 pointer
        .db 0x6F, 0x71, 0x6F, 0x71, 0x6F, 0x59, 0x6F, 0x59, 0x0E, 0x0F, 0x6F, 0x59           ; 762A oqoqoYoY..oY
        .dw T_6927                                                                           ; 7636 pointer
        .db 0x6F, 0x71, 0x6F, 0x71, 0x6F, 0x59, 0x6F, 0x59, 0x12, 0x11, 0x6F, 0x59, 0x02, 0xE0, 0x02, 0xD4 ; 7638 oqoqoYoY..oY....
        .db 0x6F, 0x71, 0x02, 0xD8, 0x6F, 0x59, 0x02, 0xE8, 0x02, 0xDC, 0x16, 0x0F, 0x6F, 0x59 ; 7648 oq..oY......oY
        .dw T_6927                                                                           ; 7656 pointer
        .db 0x03, 0x88, 0x6F, 0x71, 0x6F, 0x71, 0x6F, 0x59, 0x6F, 0x59, 0x0A, 0x0F, 0x6F, 0x59, 0x03, 0x88 ; 7658 ..oqoqoYoY..oY..
        .db 0x6F, 0x71, 0x6F, 0x71, 0x6F, 0x59, 0x6F, 0x59, 0x08, 0x08, 0x03, 0x8C, 0x03, 0x90, 0x03, 0x94 ; 7668 oqoqoYoY........
        .db 0x03, 0x98, 0x03, 0x9C, 0x03, 0xA0, 0x0B, 0x08                                   ; 7678 ........
        .dw T_691B                                                                           ; 7680 pointer
        .db 0x03, 0xB0, 0x02, 0xD4, 0x03, 0xB4, 0x02, 0xD8                                   ; 7682 ........
        .dw T_691B                                                                           ; 768A pointer
        .db 0x03, 0xB8, 0x02, 0xDC, 0x58, 0x08, 0x03, 0xA4, 0x02, 0x34, 0x02, 0xD4, 0x02, 0x4C, 0x03, 0xA8 ; 768C ....X....4...L..
        .db 0x02, 0xD8, 0x03, 0xAC, 0x02, 0xDC                                               ; 769C ......
cal_recipe_table::
        .db 0x71, 0xEE, 0xBF, 0x3F, 0x72, 0x0A, 0x80, 0x00, 0x72, 0x36, 0x80, 0x00, 0x72, 0x62, 0x80, 0x00 ; 76A2 q..?r...r6..rb..
        .db 0x72, 0x8E, 0xBF, 0x00, 0x72, 0xAE, 0xBF, 0x00, 0x72, 0xCE, 0xBF, 0x0A, 0x72, 0xEA, 0x9F, 0x00 ; 76B2 r...r...r...r...
        .db 0x73, 0x0A, 0x8A, 0x00, 0x73, 0x32, 0x0A, 0x00, 0x73, 0x40, 0x2A, 0x00, 0x73, 0x4E, 0x0A, 0x00 ; 76C2 s...s2..s@*.sN..
        .db 0x73, 0x5C, 0x0A, 0x00, 0x73, 0x6A, 0x0A, 0x00, 0x73, 0x78, 0x00, 0x00, 0x73, 0x86, 0x00, 0x00 ; 76D2 s\..sj..sx..s...
        .db 0x73, 0x94, 0x00, 0x00, 0x73, 0xA2, 0x00, 0x00, 0x73, 0xB0, 0x00, 0x00, 0x73, 0xBE, 0x15, 0x00 ; 76E2 s...s...s...s...
        .db 0x73, 0xD0, 0x2A, 0x00, 0x73, 0xDE, 0x2A, 0x00, 0x73, 0xF0, 0x00, 0x00, 0x74, 0x02, 0x00, 0x00 ; 76F2 s.*.s.*.s...t...
        .db 0x74, 0x14, 0x15, 0x00, 0x74, 0x26, 0x15, 0x00, 0x74, 0x34, 0x00, 0x00, 0x74, 0x46, 0x2A, 0x00 ; 7702 t...t&..t4..tF*.
        .db 0x74, 0x58, 0x2A, 0x00, 0x74, 0x6A, 0x2A, 0x00, 0x74, 0x7C, 0x2A, 0x00, 0x74, 0x8E, 0x3F, 0x00 ; 7712 tX*.tj*.t|*.t.?.
        .db 0x74, 0x9C, 0x2A, 0x00, 0x74, 0xAA, 0x15, 0x00, 0x74, 0xBC, 0x2A, 0x00, 0x74, 0xCA, 0x00, 0x00 ; 7722 t.*.t...t.*.t...
        .db 0x74, 0xE0, 0x2A, 0x00, 0x74, 0xF2, 0x3F, 0x00, 0x75, 0x00, 0x00, 0x00, 0x75, 0x12, 0x00, 0x00 ; 7732 t.*.t.?.u...u...
        .db 0x75, 0x24, 0x00, 0x00, 0x75, 0x36, 0x00, 0x00, 0x75, 0x48, 0x2A, 0x00, 0x75, 0x56, 0x00, 0x00 ; 7742 u$..u6..uH*.uV..
        .db 0x75, 0x6C, 0x00, 0x00, 0x75, 0x7E, 0x00, 0x00, 0x75, 0x90, 0x00, 0x00, 0x76, 0x52, 0x00, 0x00 ; 7752 ul..u~..u...vR..
        .db 0x76, 0x52, 0x00, 0x00, 0x76, 0x52, 0x00, 0x00, 0x76, 0x52, 0x00, 0x00, 0x76, 0x52, 0x00, 0x00 ; 7762 vR..vR..vR..vR..
        .db 0x76, 0x52, 0x00, 0x00, 0x75, 0xA6, 0x81, 0x00, 0x75, 0xCA, 0x80, 0x00, 0x75, 0xEE, 0x80, 0x00 ; 7772 vR..u...u...u...
        .db 0x76, 0x12, 0x80, 0x00, 0x76, 0x32, 0x00, 0x00, 0x76, 0x40, 0x00, 0x00, 0x76, 0x62, 0x00, 0x00 ; 7782 v...v2..v@..vb..
        .db 0x76, 0x62, 0x00, 0x00, 0x76, 0x62, 0x02, 0x00, 0x76, 0x62, 0x00, 0x00, 0x76, 0x62, 0x00, 0x00 ; 7792 vb..vb..vb..vb..
        .db 0x76, 0x70, 0x3F, 0x00, 0x76, 0x7E, 0x00, 0x00, 0x76, 0x90, 0x00, 0x00           ; 77A2 vp?.v~..v...

parser_restart::
        clr    0x50                                  ; 77AE
        mov    0x2F, #0x00                           ; 77B0
        ljmp   parser_reset                          ; 77B3

        .area   CODE_B  (REL,CON,CODE)

parser_step::
        jb     0x50, L_77DD                          ; 77B6
        mov    sfr_B, 0x2F                           ; 77B9
        jb     0xF7, L_77DD                          ; 77BC
        mov    a, rx_count                           ; 77BF
        jnb    0xE7, L_77DD                          ; 77C1
        anl    a, #0x3F                              ; 77C4
        jnz    L_77F0                                ; 77C6
        mov    a, rx_count                           ; 77C8
        jb     0xE6, L_77DE                          ; 77CA
        mov    a, 0x34                               ; 77CD
        cjne   a, #0x10, rx_clear                    ; 77CF
        inc    0x34                                  ; 77D2
        lcall  parser_emit_token                     ; 77D4

rx_clear::
        mov    rx_index, #0x00                       ; 77D7
        mov    rx_count, #0x00                       ; 77DA
L_77DD::
        ret                                          ; 77DD
L_77DE::
        lcall  parser_end_token                      ; 77DE
        jb     0xF7, L_7819                          ; 77E1
        lcall  rx_clear                              ; 77E4
        mov    0x2E, #0x30                           ; 77E7
        mov    0x2F, #0xA5                           ; 77EA
        ljmp   parser_reset                          ; 77ED
L_77F0::
        lcall  parser_getc                           ; 77F0
        anl    a, #0x7F                              ; 77F3
        mov    r1, a                                 ; 77F5
        ljmp   L_781A                                ; 77F6
L_77F9::
        jb     0xF7, L_7819                          ; 77F9
        mov    0x2F, #0xA5                           ; 77FC
        mov    0x2E, a                               ; 77FF
L_7801::
        lcall  rx_consume_char                       ; 7801

parser_reset::
        mov    0x34, #0x00                           ; 7804
        mov    0x2D, #0x00                           ; 7807
        mov    dptr, #cmd_table                      ; 780A
        jnb    0x50, parser_set_table_ptr            ; 780D
        mov    dptr, #x_lcd_text_buf                 ; 7810

parser_set_table_ptr::
        mov    0x36, sfr_DPH                         ; 7813
        mov    0x35, sfr_DPL                         ; 7816
L_7819::
        ret                                          ; 7819
L_781A::
        ljmp   parser_dispatch_char                  ; 781A

; ';' and ',' handling, then per-state jump table 0x7867
parser_dispatch_char::
        cjne   r1, #0x3B, L_7823                     ; 781D
        ljmp   L_7826                                ; 7820
L_7823::
        cjne   r1, #0x2C, L_7842                     ; 7823
L_7826::
        lcall  parser_end_token                      ; 7826
        jb     0xF7, L_7819                          ; 7829
        jnb    0x6E, L_7801                          ; 782C
        mov    sfr_DPH, 0x36                         ; 782F
        mov    sfr_DPL, 0x35                         ; 7832
        mov    a, #0x03                              ; 7835
        movc   a, @a+dptr                            ; 7837
        mov    0x2D, a                               ; 7838
        clr    0x6C                                  ; 783A
        mov    0x34, #0x09                           ; 783C
        ljmp   rx_consume_char                       ; 783F
L_7842::
        mov    a, r1                                 ; 7842
        add    a, #0xE0                              ; 7843
        jnc    L_789D                                ; 7845
        mov    a, 0x34                               ; 7847
        jnb    0xE5, L_784F                          ; 7849
        ljmp   parser_number_accumulate              ; 784C
L_784F::
        mov    0x2B, #0x00                           ; 784F
        mov    0x2C, #0x00                           ; 7852
        jb     0xE4, L_785B                          ; 7855
        jnb    0xE3, L_788B                          ; 7858
L_785B::
        push   sfr_B                                 ; 785B
        mov    sfr_B, #0x03                          ; 785D
        mul    ab                                    ; 7860
        pop    sfr_B                                 ; 7861
        mov    dptr, #L_784F                         ; 7863
        jmp    @a+dptr                               ; 7866
L_7867::
        ljmp   parser_st_header                      ; 7867
L_786A::
        ljmp   parser_st_mnemonic                    ; 786A
L_786D::
        ljmp   parser_st_param_start                 ; 786D
L_7870::
        ljmp   parser_st_mnemonic_more               ; 7870
L_7873::
        ljmp   parser_st_on_off                      ; 7873
L_7876::
        ljmp   parser_st_number                      ; 7876
L_7879::
        ljmp   parser_st_digits                      ; 7879
L_787C::
        ljmp   parser_st_digits                      ; 787C
L_787F::
        ljmp   L_7AB8                                ; 787F
L_7882::
        ljmp   parser_st_query                       ; 7882
L_7885::
        ljmp   rx_consume_char                       ; 7885
L_7888::
        ljmp   rx_consume_char                       ; 7888
L_788B::
        lcall  parser_is_letter                      ; 788B
        mov    sfr_DPH, 0x36                         ; 788E
        mov    sfr_DPL, 0x35                         ; 7891
        jnc    L_78A3                                ; 7894
        mov    a, 0x34                               ; 7896
        jnz    L_78DB                                ; 7898
        cjne   r1, #0x20, L_78A0                     ; 789A
L_789D::
        ljmp   rx_consume_char                       ; 789D
L_78A0::
        ljmp   L_7989                                ; 78A0
L_78A3::
        mov    a, 0x34                               ; 78A3
        movc   a, @a+dptr                            ; 78A5
        jnz    L_78AB                                ; 78A6
        ljmp   L_7989                                ; 78A8
L_78AB::
        xrl    a, r2                                 ; 78AB
        jnz    L_78DB                                ; 78AC
        lcall  parser_set_table_ptr                  ; 78AE
        mov    a, 0x34                               ; 78B1
        cjne   a, #0x02, L_78D0                      ; 78B3
L_78B6::
        mov    a, #0x04                              ; 78B6
        movc   a, @a+dptr                            ; 78B8
        mov    0x2E, a                               ; 78B9
        mov    a, #0x03                              ; 78BB
        movc   a, @a+dptr                            ; 78BD
        mov    0x2D, a                               ; 78BE
        mov    0x2F, #0x20                           ; 78C0
        jnz    L_78CC                                ; 78C3
        mov    0x34, #0x12                           ; 78C5
        mov    0x2F, #0xA5                           ; 78C8
        ret                                          ; 78CB
L_78CC::
        mov    0x34, #0x08                           ; 78CC
        ret                                          ; 78CF
L_78D0::
        inc    0x34                                  ; 78D0
        mov    a, 0x34                               ; 78D2
        movc   a, @a+dptr                            ; 78D4
        cjne   a, #0x20, L_790D                      ; 78D5
        ljmp   L_78B6                                ; 78D8
L_78DB::
        mov    a, 0x34                               ; 78DB
        jz     L_78F5                                ; 78DD
        dec    a                                     ; 78DF
        movc   a, @a+dptr                            ; 78E0
        push   sfr_DPL                               ; 78E1
        push   sfr_DPH                               ; 78E3
        lcall  rx_insert_char                        ; 78E5
        pop    sfr_DPH                               ; 78E8
        pop    sfr_DPL                               ; 78EA
        djnz   0x34, L_78DB                          ; 78EC
        lcall  parser_next_entry                     ; 78EF
        ljmp   parser_set_table_ptr                  ; 78F2
L_78F5::
        lcall  parser_next_entry                     ; 78F5
        ljmp   L_78A3                                ; 78F8

; cmd_table entry = 5 bytes
parser_next_entry::
        mov    r3, #0x05                             ; 78FB
L_78FD::
        inc    dptr                                  ; 78FD
        djnz   r3, L_78FD                            ; 78FE
        ret                                          ; 7900

parser_st_header::
        lcall  parser_is_letter                      ; 7901
        jnc    L_790D                                ; 7904
        mov    0x34, #0x0A                           ; 7906
        ret                                          ; 7909

parser_st_param_start::
        cjne   r1, #0x20, L_7910                     ; 790A
L_790D::
        ljmp   rx_consume_char                       ; 790D
L_7910::
        jnb    0x69, L_7925                          ; 7910
        lcall  parser_is_digit                       ; 7913
        jc     L_7923                                ; 7916
        mov    0x30, #0x00                           ; 7918
        inc    0x2F                                  ; 791B
        inc    0x2F                                  ; 791D
        mov    0x34, #0x0D                           ; 791F
        ret                                          ; 7922
L_7923::
        clr    0x69                                  ; 7923
L_7925::
        jnb    0x6A, L_793C                          ; 7925
        mov    0x34, #0x0E                           ; 7928
        lcall  parser_sign_char                      ; 792B
        jc     L_793A                                ; 792E
        mov    r0, #0x32                             ; 7930
        lcall  i24_clr_r0                            ; 7932
L_7935::
        mov    a, #0x03                              ; 7935
        ljmp   parser_set_kind                       ; 7937
L_793A::
        clr    0x6A                                  ; 793A
L_793C::
        jnb    0x6B, L_795B                          ; 793C
        mov    a, r1                                 ; 793F
        add    a, #0xD2                              ; 7940
        jz     L_7951                                ; 7942
        add    a, #0x01                              ; 7944
        jz     L_7951                                ; 7946
        add    a, #0x02                              ; 7948
        jz     L_7951                                ; 794A
        lcall  parser_is_digit                       ; 794C
        jc     L_7959                                ; 794F
L_7951::
        mov    0x34, #0x20                           ; 7951

parser_flag_kind4::
        mov    a, #0x04                              ; 7954
        ljmp   parser_set_kind                       ; 7956
L_7959::
        clr    0x6B                                  ; 7959
L_795B::
        jnb    0x6D, L_7968                          ; 795B
        cjne   r1, #0x3F, L_7966                     ; 795E
        mov    a, #0x86                              ; 7961
        ljmp   L_7A12                                ; 7963
L_7966::
        clr    0x6D                                  ; 7966
L_7968::
        jnb    0x68, L_7979                          ; 7968
        mov    a, r1                                 ; 796B
        anl    a, #0x5F                              ; 796C
        cjne   a, #0x4F, L_7977                      ; 796E
        mov    0x34, #0x0B                           ; 7971
        ljmp   rx_consume_char                       ; 7974
L_7977::
        clr    0x68                                  ; 7977
L_7979::
        jnb    0x6C, L_7989                          ; 7979
        mov    0x2F, #0x60                           ; 797C
L_797F::
        mov    0x34, #0x10                           ; 797F
        mov    0x30, rx_index                        ; 7982
        mov    0x31, #0x00                           ; 7985
        ret                                          ; 7988
L_7989::
        setb   0x1E                                  ; 7989
        ljmp   L_7A15                                ; 798B

parser_st_mnemonic::
        cjne   r1, #0x20, L_7994                     ; 798E
        ljmp   rx_consume_char                       ; 7991
L_7994::
        lcall  parser_is_letter                      ; 7994
        jc     L_799C                                ; 7997
        ljmp   parser_reset                          ; 7999
L_799C::
        mov    0x2F, #0x00                           ; 799C
        mov    0x34, #0x0A                           ; 799F
        ret                                          ; 79A2

parser_st_mnemonic_more::
        mov    a, r1                                 ; 79A3
        anl    a, #0x5F                              ; 79A4
        cjne   a, #0x4E, L_79AE                      ; 79A6
        mov    a, #0x81                              ; 79A9
        ljmp   L_7A12                                ; 79AB
L_79AE::
        cjne   a, #0x46, L_79B7                      ; 79AE
        mov    0x34, #0x0C                           ; 79B1
        ljmp   rx_consume_char                       ; 79B4
L_79B7::
        mov    a, #0x4F                              ; 79B7
        lcall  rx_insert_char                        ; 79B9
        mov    0x34, #0x0A                           ; 79BC
        clr    0x68                                  ; 79BF
        ret                                          ; 79C1

parser_st_on_off::
        mov    a, r1                                 ; 79C2
        anl    a, #0x5F                              ; 79C3
        cjne   a, #0x46, L_79CD                      ; 79C5
        mov    a, #0x80                              ; 79C8
        ljmp   L_7A12                                ; 79CA
L_79CD::
        mov    a, #0x46                              ; 79CD
        lcall  rx_insert_char                        ; 79CF
        ljmp   L_79B7                                ; 79D2

parser_st_number::
        lcall  parser_is_digit                       ; 79D5
        jc     L_7A20                                ; 79D8
        mov    r2, a                                 ; 79DA
        mov    a, 0x30                               ; 79DB
        mov    sfr_B, #0x0A                          ; 79DD
        mul    ab                                    ; 79E0
        jb     sbit_OV, L_79E7                       ; 79E1
        add    a, r2                                 ; 79E4
        jnc    L_7A1B                                ; 79E5
L_79E7::
        jnb    0x6A, L_79F5                          ; 79E7
        mov    0x31, #0x00                           ; 79EA
        mov    0x32, #0x00                           ; 79ED
        inc    0x34                                  ; 79F0
        ljmp   L_7935                                ; 79F2
L_79F5::
        jnb    0x6B, L_7A0D                          ; 79F5
L_79F8::
        mov    0x31, #0x00                           ; 79F8
        mov    0x32, #0x00                           ; 79FB
L_79FE::
        mov    0x34, #0x22                           ; 79FE
        mov    r3, #0x00                             ; 7A01
        clr    sbit_F0                               ; 7A03
        lcall  parser_flag_kind4                     ; 7A05
        mov    r0, #0x32                             ; 7A08
        ljmp   i24_to_fp                             ; 7A0A
L_7A0D::
        mov    0x30, #0xFF                           ; 7A0D
L_7A10::
        mov    a, #0x82                              ; 7A10
L_7A12::
        lcall  parser_set_kind                       ; 7A12
L_7A15::
        mov    0x34, #0x12                           ; 7A15
        ljmp   rx_consume_char                       ; 7A18
L_7A1B::
        mov    0x30, a                               ; 7A1B
        ljmp   rx_consume_char                       ; 7A1D
L_7A20::
        cjne   r1, #0x2E, L_7A29                     ; 7A20
L_7A23::
        jb     0x6B, L_79F8                          ; 7A23
        ljmp   L_7A10                                ; 7A26
L_7A29::
        mov    a, r1                                 ; 7A29
        anl    a, #0x5F                              ; 7A2A
        cjne   a, #0x45, L_7A10                      ; 7A2C
        ljmp   L_7A23                                ; 7A2F

parser_st_digits::
        lcall  parser_is_digit                       ; 7A32
        jc     L_7A7C                                ; 7A35
        mov    r2, a                                 ; 7A37
        mov    r1, #0x32                             ; 7A38
        mov    r0, #0x5E                             ; 7A3A
        lcall  i24_copy_r1_to_r0                     ; 7A3C
        mov    a, #0x0A                              ; 7A3F
        xch    a, @r1                                ; 7A41
        mov    r3, a                                 ; 7A42
        lcall  i24_div10_rem                         ; 7A43
        mov    a, r3                                 ; 7A46
        mov    @r1, a                                ; 7A47
        jc     L_7A59                                ; 7A48
        dec    r0                                    ; 7A4A
        dec    r0                                    ; 7A4B
        mov    a, r2                                 ; 7A4C
        add    a, @r0                                ; 7A4D
        mov    @r0, a                                ; 7A4E
        inc    r0                                    ; 7A4F
        clr    a                                     ; 7A50
        addc   a, @r0                                ; 7A51
        mov    @r0, a                                ; 7A52
        inc    r0                                    ; 7A53
        clr    a                                     ; 7A54
        addc   a, @r0                                ; 7A55
        mov    @r0, a                                ; 7A56
        jnc    L_7A72                                ; 7A57
L_7A59::
        jnb    0x6B, L_7A67                          ; 7A59
L_7A5C::
        mov    a, 0x34                               ; 7A5C
        cjne   a, #0x0F, L_7A64                      ; 7A5E
        lcall  i24_neg                               ; 7A61
L_7A64::
        ljmp   L_79FE                                ; 7A64
L_7A67::
        mov    r0, #0x32                             ; 7A67
        lcall  i24_ld_max_r0                         ; 7A69
L_7A6C::
        lcall  parser_end_token                      ; 7A6C
        ljmp   L_7A15                                ; 7A6F
L_7A72::
        mov    r1, #0x5E                             ; 7A72
        mov    r0, #0x32                             ; 7A74
        lcall  i24_copy_r1_to_r0                     ; 7A76
        ljmp   rx_consume_char                       ; 7A79
L_7A7C::
        jnb    0x6B, L_7A6C                          ; 7A7C
        mov    r0, #0x32                             ; 7A7F
        lcall  i24_test_r0                           ; 7A81
        jnz    L_7A5C                                ; 7A84
        mov    r1, #0x2B                             ; 7A86
        mov    a, 0x34                               ; 7A88
        cjne   a, #0x0F, L_7A8F                      ; 7A8A
        mov    r1, #0x2D                             ; 7A8D
L_7A8F::
        mov    0x34, #0x20                           ; 7A8F
        ret                                          ; 7A92

parser_number_accumulate::
        mov    r6, 0x34                              ; 7A93
        mov    a, r1                                 ; 7A95
        mov    r7, a                                 ; 7A96
        mov    r0, #0x33                             ; 7A97
        mov    r1, #0x5F                             ; 7A99
        mov    c, 0x58                               ; 7A9B
        mov    sbit_F0, c                            ; 7A9D
        mov    r2, 0x2B                              ; 7A9F
        mov    r3, 0x2C                              ; 7AA1
        lcall  parse_number_char                     ; 7AA3
        mov    0x2B, r2                              ; 7AA6
        mov    c, sbit_F0                            ; 7AA8
        mov    0x58, c                               ; 7AAA
        mov    0x2C, r3                              ; 7AAC
        mov    0x34, r6                              ; 7AAE
        cjne   r6, #0x12, L_7AB5                     ; 7AB0
        setb   0x1E                                  ; 7AB3
L_7AB5::
        ljmp   rx_consume_char                       ; 7AB5
L_7AB8::
        inc    0x31                                  ; 7AB8
        ljmp   rx_consume_char                       ; 7ABA

parser_st_query::
        mov    0x2F, #0x40                           ; 7ABD
        ljmp   L_797F                                ; 7AC0

rx_consume_char::
        inc    rx_index                              ; 7AC3
        dec    rx_count                              ; 7AC5
        ret                                          ; 7AC7

rx_insert_char::
        mov    r4, a                                 ; 7AC8
        lcall  parser_getc                           ; 7AC9
        mov    a, rx_index                           ; 7ACC
        cjne   a, #0x00, L_7AE4                      ; 7ACE
        mov    a, rx_count                           ; 7AD1
        anl    a, #0x3F                              ; 7AD3
        jz     L_7ADF                                ; 7AD5
        mov    r3, a                                 ; 7AD7
        mov    a, r4                                 ; 7AD8
L_7AD9::
        movx   a, @dptr                              ; 7AD9
        xch    a, r4                                 ; 7ADA
        movx   @dptr, a                              ; 7ADB
        inc    dptr                                  ; 7ADC
        djnz   r3, L_7AD9                            ; 7ADD
L_7ADF::
        mov    a, r4                                 ; 7ADF
        movx   @dptr, a                              ; 7AE0
        inc    rx_count                              ; 7AE1
        ret                                          ; 7AE3
L_7AE4::
        dec    rx_index                              ; 7AE4
        inc    rx_count                              ; 7AE6
        ret                                          ; 7AE8

parser_end_token::
        mov    a, #0x12                              ; 7AE9
        xch    a, 0x34                               ; 7AEB
        jb     0xE5, L_7B32                          ; 7AED
        jb     0xE4, L_7AFA                          ; 7AF0
        jb     0xE3, L_7AFA                          ; 7AF3
        jz     L_7B4D                                ; 7AF6
        sjmp   L_7B69                                ; 7AF8
L_7AFA::
        push   sfr_B                                 ; 7AFA
        mov    sfr_B, #0x03                          ; 7AFC
        mul    ab                                    ; 7AFF
        pop    sfr_B                                 ; 7B00
        mov    dptr, #parser_end_token+5             ; 7B02
        jmp    @a+dptr                               ; 7B05
L_7B06::
        ljmp   parser_end_param                      ; 7B06
L_7B09::
        ljmp   L_7B4D                                ; 7B09
L_7B0C::
        ljmp   parser_end_param                      ; 7B0C
L_7B0F::
        ljmp   parser_end_param1                     ; 7B0F
L_7B12::
        ljmp   parser_end_param2                     ; 7B12
L_7B15::
        ljmp   parser_emit_token                     ; 7B15
L_7B18::
        ljmp   parser_emit_token                     ; 7B18
L_7B1B::
        ljmp   L_7B2A                                ; 7B1B
L_7B1E::
        ljmp   L_7B57                                ; 7B1E
L_7B21::
        ljmp   parser_end_reset                      ; 7B21
L_7B24::
        ljmp   L_7B4D                                ; 7B24
L_7B27::
        ljmp   L_7B69                                ; 7B27
L_7B2A::
        lcall  parser_emit_token                     ; 7B2A
        mov    r0, #0x32                             ; 7B2D
        ljmp   i24_neg                               ; 7B2F
L_7B32::
        mov    r6, a                                 ; 7B32
        mov    r7, #0x3B                             ; 7B33
        mov    r0, #0x33                             ; 7B35
        mov    r1, #0x5F                             ; 7B37
        mov    c, 0x58                               ; 7B39
        mov    sbit_F0, c                            ; 7B3B
        mov    r2, 0x2B                              ; 7B3D
        mov    r3, 0x2C                              ; 7B3F
        lcall  parse_number_char                     ; 7B41
        inc    a                                     ; 7B44
        jz     L_7B69                                ; 7B45

; 2Fh |= 0x80, wait for consumer
parser_emit_token::
        orl    0x2F, #0x80                           ; 7B47
        mov    0x34, #0x12                           ; 7B4A
L_7B4D::
        mov    sfr_B, 0x2F                           ; 7B4D
        ret                                          ; 7B50

parser_end_reset::
        mov    0x31, #0x00                           ; 7B51
        mov    0x2F, #0x00                           ; 7B54
L_7B57::
        mov    a, #0xD0                              ; 7B57
        ljmp   parser_set_kind                       ; 7B59

parser_end_param::
        jnb    0x6F, L_7B69                          ; 7B5C
        mov    a, #0x85                              ; 7B5F

parser_set_kind::
        anl    0x2F, #0xB8                           ; 7B61
        orl    0x2F, a                               ; 7B64
        ljmp   L_7B4D                                ; 7B66
L_7B69::
        setb   0x1E                                  ; 7B69
        ljmp   L_7B4D                                ; 7B6B

parser_end_param1::
        jnb    0x6C, L_7B69                          ; 7B6E
        mov    0x31, #0x01                           ; 7B71
        lcall  parser_insert_terminator              ; 7B74
L_7B77::
        lcall  rx_consume_char                       ; 7B77
        ljmp   L_7B57                                ; 7B7A

parser_end_param2::
        jnb    0x6C, L_7B69                          ; 7B7D
        mov    a, #0x46                              ; 7B80
        lcall  rx_insert_char                        ; 7B82
        mov    0x31, #0x02                           ; 7B85
        lcall  parser_insert_terminator              ; 7B88
        lcall  rx_consume_char                       ; 7B8B
        ljmp   L_7B77                                ; 7B8E

parser_insert_terminator::
        mov    a, #0x4F                              ; 7B91
        lcall  rx_insert_char                        ; 7B93
        mov    0x30, rx_index                        ; 7B96
        ret                                          ; 7B99

parser_is_letter::
        mov    a, r1                                 ; 7B9A
        anl    a, #0x5F                              ; 7B9B
        mov    r2, a                                 ; 7B9D
        add    a, #0xA5                              ; 7B9E
        jc     L_7BA5                                ; 7BA0
        add    a, #0x1A                              ; 7BA2
        cpl    c                                     ; 7BA4
L_7BA5::
        ret                                          ; 7BA5

parser_sign_char::
        clr    c                                     ; 7BA6
        cjne   r1, #0x2B, L_7BAD                     ; 7BA7
        ljmp   rx_consume_char                       ; 7BAA
L_7BAD::
        cjne   r1, #0x2D, parser_is_digit            ; 7BAD
        inc    0x34                                  ; 7BB0
        ljmp   rx_consume_char                       ; 7BB2

parser_is_digit::
        mov    a, r1                                 ; 7BB5
        add    a, #0xC6                              ; 7BB6
        jc     L_7BBD                                ; 7BB8
        add    a, #0x0A                              ; 7BBA
        cpl    c                                     ; 7BBC
L_7BBD::
        ret                                          ; 7BBD

; A = iface_rx_buf[rx_index]
parser_getc::
        mov    dptr, #x_iface_rx_buf                 ; 7BBE
        mov    a, rx_index                           ; 7BC1
        add    a, sfr_DPL                            ; 7BC3
        mov    sfr_DPL, a                            ; 7BC5
        jnc    L_7BCB                                ; 7BC7
        inc    sfr_DPH                               ; 7BC9
L_7BCB::
        movx   a, @dptr                              ; 7BCB
        ret                                          ; 7BCC
L_7BCD::
        lcall  iface_load_channel                    ; 7BCD
        mov    a, r3                                 ; 7BD0
        jb     0xE0, L_7BDD                          ; 7BD1
        jb     0x7B, L_7BDD                          ; 7BD4
        ljmp   iface_save_channel                    ; 7BD7

; DPTR=channel descriptor (xdata); service interface board
iface_poll_channel::
        lcall  iface_load_channel                    ; 7BDA
L_7BDD::
        mov    a, rx_count                           ; 7BDD
        jb     0xE7, L_7BEA                          ; 7BDF
        jnb    0x7A, L_7BEA                          ; 7BE2
        clr    0x7A                                  ; 7BE5
        mov    rx_count, #0xC0                       ; 7BE7
L_7BEA::
        lcall  iface_i2c_read_block                  ; 7BEA
        ljmp   iface_save_channel                    ; 7BED

iface_send_channel::
        lcall  iface_load_channel                    ; 7BF0
        mov    r4, a                                 ; 7BF3
        mov    a, r2                                 ; 7BF4
        jnc    L_7BFD                                ; 7BF5
        lcall  iface_send_f1                         ; 7BF7
        ljmp   L_7C07                                ; 7BFA
L_7BFD::
        mov    r3, #0xB8                             ; 7BFD
        jb     0xE7, L_7C09                          ; 7BFF
        mov    r3, #0x58                             ; 7C02
        jb     0xE6, L_7C09                          ; 7C04
L_7C07::
        mov    r3, #0x00                             ; 7C07
L_7C09::
        mov    sfr_B, #0x00                          ; 7C09
        lcall  iface_i2c_write_block                 ; 7C0C
        ljmp   L_7C91                                ; 7C0F

iface_send_status_now::
        lcall  iface_load_channel                    ; 7C12
        lcall  iface_send_status                     ; 7C15
        ljmp   iface_save_channel                    ; 7C18
L_7C1B::
        lcall  iface_load_channel                    ; 7C1B
        lcall  sub_7D45                              ; 7C1E
L_7C21::
        ljmp   iface_save_channel                    ; 7C21

; hand the reply buffer to the interface board
iface_send::
        lcall  iface_load_channel                    ; 7C24
        mov    a, 0x0B                               ; 7C27
        jnb    0xE7, L_7C21                          ; 7C29
        clr    0xF6                                  ; 7C2C
        setb   0xF4                                  ; 7C2E
        ljmp   iface_save_channel                    ; 7C30
L_7C33::
        lcall  iface_load_channel                    ; 7C33
        clr    0xF6                                  ; 7C36
        setb   0xF4                                  ; 7C38
        lcall  iface_set_resend                      ; 7C3A
        lcall  sub_7E10                              ; 7C3D
        ljmp   iface_save_channel                    ; 7C40

iface_clear_remote::
        lcall  iface_load_channel                    ; 7C43
        mov    a, 0x2F                               ; 7C46
        jb     0xE7, L_7C21                          ; 7C48
        clr    0xE4                                  ; 7C4B
        mov    0x2F, a                               ; 7C4D
        ljmp   iface_save_channel                    ; 7C4F

; F4 + C0|address to the interface board
iface_send_config_address::
        lcall  iface_load_channel                    ; 7C52
        mov    r7, a                                 ; 7C55
        anl    a, #0x1F                              ; 7C56
        xch    a, r7                                 ; 7C58
        anl    a, #0xC0                              ; 7C59
        xch    a, r3                                 ; 7C5B
        anl    a, #0x3F                              ; 7C5C
        xch    a, r3                                 ; 7C5E
        jz     L_7C6C                                ; 7C5F
        orl    a, #0x18                              ; 7C61
        mov    c, 0xE7                               ; 7C63
        mov    0xE5, c                               ; 7C65
        xch    a, r3                                 ; 7C67
        anl    a, #0xC7                              ; 7C68
        orl    a, r3                                 ; 7C6A
        mov    r3, a                                 ; 7C6B
L_7C6C::
        mov    r5, #0xF4                             ; 7C6C
        lcall  iface_write_ctrl                      ; 7C6E
        mov    a, r3                                 ; 7C71
        inc    r5                                    ; 7C72
        jb     0xE6, L_7C7A                          ; 7C73
        inc    r5                                    ; 7C76
        jnb    0xE7, L_7C7D                          ; 7C77
L_7C7A::
        lcall  iface_write_ctrl                      ; 7C7A
L_7C7D::
        mov    a, r4                                 ; 7C7D
        anl    a, #0xE0                              ; 7C7E
        orl    a, r7                                 ; 7C80
        mov    r4, a                                 ; 7C81
        lcall  iface_send_f4_address                 ; 7C82
        ljmp   iface_save_channel                    ; 7C85
L_7C88::
        lcall  iface_write_ctrl                      ; 7C88
        ljmp   iface_save_channel                    ; 7C8B

; returns C=1 when a byte/command arrived
iface_receive_channel::
        lcall  iface_load_channel                    ; 7C8E
L_7C91::
        mov    r5, #0xFA                             ; 7C91
        lcall  iface_write_ctrl                      ; 7C93
        lcall  iface_read_status                     ; 7C96
        jc     L_7C9F                                ; 7C99
        lcall  iface_handle_event                    ; 7C9B
        clr    c                                     ; 7C9E
L_7C9F::
        mov    a, r6                                 ; 7C9F
        ljmp   iface_save_channel                    ; 7CA0
L_7CA3::
        lcall  iface_load_channel                    ; 7CA3
        mov    r5, #0xFB                             ; 7CA6
        lcall  iface_write_ctrl                      ; 7CA8
        lcall  iface_start_read                      ; 7CAB
        lcall  i2cA_recv_nack_stop                   ; 7CAE
        push   sfr_ACC                               ; 7CB1
        lcall  iface_handle_event                    ; 7CB3
        pop    sfr_ACC                               ; 7CB6
        xrl    a, #0xDF                              ; 7CB8
        anl    a, #0xE0                              ; 7CBA
        clr    c                                     ; 7CBC
        jz     iface_save_channel                    ; 7CBD
        mov    a, r4                                 ; 7CBF
        cpl    c                                     ; 7CC0
        ljmp   iface_save_channel                    ; 7CC1
L_7CC4::
        lcall  iface_load_channel                    ; 7CC4
        lcall  iface_send_f1                         ; 7CC7
        ljmp   iface_save_channel                    ; 7CCA
L_7CCD::
        lcall  iface_load_channel                    ; 7CCD
        mov    r5, #0xF0                             ; 7CD0
        lcall  iface_write_ctrl                      ; 7CD2
        lcall  iface_start_read                      ; 7CD5
        lcall  i2cA_recv_byte                        ; 7CD8
        cjne   a, #0xF0, L_7CE8                      ; 7CDB
        lcall  i2cA_send_ack                         ; 7CDE
        lcall  i2cA_recv_nack_stop                   ; 7CE1
        cpl    c                                     ; 7CE4
        ljmp   iface_save_channel                    ; 7CE5
L_7CE8::
        lcall  sub_7D8B                              ; 7CE8
        clr    c                                     ; 7CEB

iface_save_channel::
        mov    r2, a                                 ; 7CEC
        lcall  iface_ctx_save                        ; 7CED
        mov    a, r0                                 ; 7CF0
        mov    sfr_DPL, a                            ; 7CF1
        mov    a, r1                                 ; 7CF3
        mov    sfr_DPH, a                            ; 7CF4
        mov    a, r4                                 ; 7CF6
        movx   @dptr, a                              ; 7CF7
        inc    dptr                                  ; 7CF8
        mov    a, r3                                 ; 7CF9
        movx   @dptr, a                              ; 7CFA
        inc    dptr                                  ; 7CFB
        mov    a, sfr_B                              ; 7CFC
        movx   @dptr, a                              ; 7CFE
        mov    a, r2                                 ; 7CFF
        ret                                          ; 7D00

iface_i2c_read_block::
        jnb    0xF7, iface_i2c_write_block           ; 7D01
        lcall  iface_start_read                      ; 7D04
        jnc    iface_read_message                    ; 7D07
        lcall  i2cA_stop                             ; 7D09
        lcall  iface_start_write                     ; 7D0C
        jnc    L_7D3F                                ; 7D0F
        jnb    0xF4, L_7D1C                          ; 7D11
        mov    a, 0x0B                               ; 7D14
        jnb    0xE7, L_7D1C                          ; 7D16
        lcall  iface_reply_done                      ; 7D19
L_7D1C::
        mov    a, r3                                 ; 7D1C
        anl    a, #0xF8                              ; 7D1D
        mov    r3, a                                 ; 7D1F
        mov    sfr_B, #0x00                          ; 7D20
        ljmp   L_7F09                                ; 7D23

iface_i2c_write_block::
        lcall  iface_start_write                     ; 7D26
        jnc    L_7D2E                                ; 7D29
        ljmp   i2cA_stop                             ; 7D2B
L_7D2E::
        setb   0xF7                                  ; 7D2E
        lcall  ret_clc                               ; 7D30
        jnc    L_7D3F                                ; 7D33
        mov    a, #0xFD                              ; 7D35
        lcall  i2cA_send_byte                        ; 7D37
        mov    a, #0x40                              ; 7D3A
        lcall  i2cA_send_byte                        ; 7D3C
L_7D3F::
        lcall  i2cA_stop                             ; 7D3F
        lcall  iface_send_status                     ; 7D42

sub_7D45::
        mov    r5, #0xF8                             ; 7D45
        lcall  iface_write_ctrl                      ; 7D47
        mov    a, r4                                 ; 7D4A
        jnb    0xE7, L_7D56                          ; 7D4B
        mov    r5, #0xF3                             ; 7D4E
        lcall  iface_write_ctrl                      ; 7D50
        lcall  iface_send_address                    ; 7D53
L_7D56::
        mov    a, r3                                 ; 7D56
        mov    r5, #0xF4                             ; 7D57
        anl    a, #0x18                              ; 7D59
        xrl    a, #0x18                              ; 7D5B
        jnz    L_7D6A                                ; 7D5D
        mov    a, r3                                 ; 7D5F
        inc    r5                                    ; 7D60
        jb     0xE6, L_7D6A                          ; 7D61
        inc    r5                                    ; 7D64
        jb     0xE7, L_7D6A                          ; 7D65
        mov    r5, #0xF4                             ; 7D68
L_7D6A::
        lcall  iface_write_ctrl                      ; 7D6A
        lcall  iface_addressed                       ; 7D6D
        jnc    L_7D7E                                ; 7D70
        mov    a, rx_count                           ; 7D72
        jb     0xE7, L_7D7E                          ; 7D74
        mov    r5, #0xFE                             ; 7D77
        clr    0xF3                                  ; 7D79
        lcall  iface_write_ctrl                      ; 7D7B
L_7D7E::
        mov    r5, #0xFA                             ; 7D7E
        lcall  iface_write_ctrl                      ; 7D80

iface_set_resend::
        xch    a, r3                                 ; 7D83
        setb   0xE0                                  ; 7D84
        xch    a, r3                                 ; 7D86
L_7D87::
        ret                                          ; 7D87

; header b7=0: n = b0-4 data bytes + checksum -> iface_rx_buf; b6 = END
iface_read_message::
        lcall  i2cA_recv_byte                        ; 7D88

sub_7D8B::
        jb     0xE7, L_7DE8                          ; 7D8B
        mov    r5, a                                 ; 7D8E
        anl    a, #0x1F                              ; 7D8F
        jz     L_7DE1                                ; 7D91
        mov    r6, a                                 ; 7D93
        lcall  iface_addressed                       ; 7D94
        jnc    L_7DDB                                ; 7D97
        mov    dptr, #x_iface_rx_buf                 ; 7D99
        mov    a, rx_count                           ; 7D9C
        jb     0xE7, L_7DDB                          ; 7D9E
        lcall  i2cA_send_ack                         ; 7DA1
        mov    r7, #0x00                             ; 7DA4

iface_rx_loop::
        lcall  i2cA_recv_ack                         ; 7DA6
        movx   @dptr, a                              ; 7DA9
        inc    dptr                                  ; 7DAA
        add    a, r7                                 ; 7DAB
        rr     a                                     ; 7DAC
        mov    r7, a                                 ; 7DAD
        djnz   r6, iface_rx_loop                     ; 7DAE
        lcall  i2cA_recv_nack_stop                   ; 7DB0
        xrl    a, r7                                 ; 7DB3
        jz     iface_rx_complete                     ; 7DB4

; read status; message -> iface_read_message, else iface_handle_event
iface_poll_once::
        lcall  iface_read_status                     ; 7DB6
        jc     L_7D87                                ; 7DB9
        ljmp   iface_handle_event                    ; 7DBB

; rx_index = 0, rx_count = header | 0x80
iface_rx_complete::
        mov    rx_index, #0x00                       ; 7DBE
        mov    a, r5                                 ; 7DC1
        setb   0xE7                                  ; 7DC2
        mov    rx_count, a                           ; 7DC4
        lcall  iface_write_ff                        ; 7DC6
L_7DC9::
        clr    0xF6                                  ; 7DC9
        jnb    0xF4, L_7DD8                          ; 7DCB
        clr    0xF4                                  ; 7DCE
        clr    a                                     ; 7DD0
        xch    a, 0x0B                               ; 7DD1
        anl    a, #0x1F                              ; 7DD3
        lcall  ret_nop                               ; 7DD5
L_7DD8::
        ljmp   reply_abort                           ; 7DD8
L_7DDB::
        lcall  i2cA_nack_stop                        ; 7DDB
        ljmp   L_7EA1                                ; 7DDE
L_7DE1::
        lcall  i2cA_nack_stop                        ; 7DE1
        mov    a, r5                                 ; 7DE4
        ljmp   iface_handle_event                    ; 7DE5
L_7DE8::
        lcall  iface_status_decode                   ; 7DE8
        jc     L_7E4E                                ; 7DEB
        cjne   a, #0xFF, L_7E01                      ; 7DED
        mov    a, sfr_B                              ; 7DF0
        anl    a, #0x07                              ; 7DF2
        jz     L_7DFB                                ; 7DF4
        dec    sfr_B                                 ; 7DF6
        ljmp   L_7EB7                                ; 7DF8
L_7DFB::
        orl    sfr_B, #0x07                          ; 7DFB
        ljmp   sub_7D45                              ; 7DFE
L_7E01::
        lcall  iface_set_resend                      ; 7E01
        cjne   a, #0xFE, iface_send_identity         ; 7E04
        jb     0xF3, L_7DFB                          ; 7E07
        jb     0xF5, L_7E57                          ; 7E0A
        jnb    0xF4, iface_handle_event              ; 7E0D

sub_7E10::
        mov    a, 0x0B                               ; 7E10
        jb     0xE7, iface_send_reply_block          ; 7E12
        setb   0xF6                                  ; 7E15
        ret                                          ; 7E17

; header 0x20|len (b6 END), reply_buf, checksum
iface_send_reply_block::
        lcall  iface_start_write                     ; 7E18
        mov    dptr, #x_reply_buf                    ; 7E1B
        mov    a, 0x0B                               ; 7E1E
        anl    a, #0x5F                              ; 7E20
        orl    a, #0x20                              ; 7E22
        mov    r5, a                                 ; 7E24
        lcall  i2cA_send_byte                        ; 7E25
        mov    a, r5                                 ; 7E28
        anl    a, #0x1F                              ; 7E29
        mov    r6, a                                 ; 7E2B
        mov    r7, #0x00                             ; 7E2C
        jnz    L_7E36                                ; 7E2E
        lcall  i2cA_stop                             ; 7E30
        ljmp   iface_reply_done                      ; 7E33
L_7E36::
        movx   a, @dptr                              ; 7E36
        inc    dptr                                  ; 7E37
        lcall  iface_send_byte_ck                    ; 7E38
        djnz   r6, L_7E36                            ; 7E3B
        mov    a, r7                                 ; 7E3D
        lcall  i2cA_send_stop                        ; 7E3E
        lcall  iface_read_status                     ; 7E41
        jnc    iface_handle_event                    ; 7E44
        jb     0xE0, L_7E4E                          ; 7E46

iface_reply_done::
        clr    0xF4                                  ; 7E49
        clr    a                                     ; 7E4B
        mov    0x0B, a                               ; 7E4C
L_7E4E::
        ret                                          ; 7E4E

; E1: 0x60|len + version string (0x59A5) + checksum
iface_send_identity::
        cjne   a, #0xE1, iface_handle_event          ; 7E4F
        setb   0xF5                                  ; 7E52
        jb     0xF3, L_7DFB                          ; 7E54
L_7E57::
        push   sfr_DPH                               ; 7E57
        push   sfr_DPL                               ; 7E59
        lcall  iface_start_write                     ; 7E5B
        mov    dptr, #T_59A5                         ; 7E5E
        clr    a                                     ; 7E61
        mov    r7, a                                 ; 7E62
        mov    r5, a                                 ; 7E63
        movc   a, @a+dptr                            ; 7E64
        mov    r6, a                                 ; 7E65
        orl    a, #0x60                              ; 7E66
        lcall  i2cA_send_byte                        ; 7E68
L_7E6B::
        inc    r5                                    ; 7E6B
        mov    a, r5                                 ; 7E6C
        movc   a, @a+dptr                            ; 7E6D
        lcall  iface_send_byte_ck                    ; 7E6E
        djnz   r6, L_7E6B                            ; 7E71
        mov    a, r7                                 ; 7E73
        lcall  i2cA_send_stop                        ; 7E74
        pop    sfr_DPL                               ; 7E77
        pop    sfr_DPH                               ; 7E79
        lcall  iface_read_status                     ; 7E7B
        jnc    iface_handle_event                    ; 7E7E
        jb     0xE0, L_7E4E                          ; 7E80
        clr    0xF5                                  ; 7E83
        ret                                          ; 7E85

; FE talk, E1 identity, FF countdown, F5-F8 remote/local, F9 GET, FA DCL, FB/FD resend
iface_handle_event::
        mov    r5, a                                 ; 7E86
        jb     0xE7, L_7EA2                          ; 7E87
        anl    a, #0x1F                              ; 7E8A
        jnz    L_7E4E                                ; 7E8C
        lcall  iface_addressed                       ; 7E8E
        jnc    L_7EA1                                ; 7E91
        mov    a, rx_count                           ; 7E93
        jb     0xE7, L_7E9B                          ; 7E95
        ljmp   iface_rx_complete                     ; 7E98
L_7E9B::
        mov    a, r5                                 ; 7E9B
        jnb    0xE6, L_7EA1                          ; 7E9C
        setb   0x7A                                  ; 7E9F
L_7EA1::
        ret                                          ; 7EA1
L_7EA2::
        cjne   a, #0xFE, L_7EAE                      ; 7EA2
        jb     0xF4, L_7E4E                          ; 7EA5
        jb     0xF3, L_7E4E                          ; 7EA8
        setb   0xF6                                  ; 7EAB
        ret                                          ; 7EAD
L_7EAE::
        cjne   a, #0xE1, L_7EB4                      ; 7EAE
        setb   0xF5                                  ; 7EB1
        ret                                          ; 7EB3
L_7EB4::
        cjne   a, #0xFF, L_7EBF                      ; 7EB4
L_7EB7::
        jb     0xF3, L_7EBE                          ; 7EB7
        xch    a, r3                                 ; 7EBA
        clr    0xE0                                  ; 7EBB
        xch    a, r3                                 ; 7EBD
L_7EBE::
        ret                                          ; 7EBE
L_7EBF::
        jb     0xE5, L_7ECB                          ; 7EBF
        anl    a, #0x1F                              ; 7EC2
        mov    r5, a                                 ; 7EC4
        mov    a, r4                                 ; 7EC5
        anl    a, #0xE0                              ; 7EC6
        orl    a, r5                                 ; 7EC8
        mov    r4, a                                 ; 7EC9
        ret                                          ; 7ECA
L_7ECB::
        cjne   a, #0xF9, L_7ED6                      ; 7ECB
        lcall  iface_addressed                       ; 7ECE
        jnc    L_7EE0                                ; 7ED1
        setb   0x78                                  ; 7ED3
        ret                                          ; 7ED5
L_7ED6::
        cjne   a, #0xFA, L_7EE1                      ; 7ED6
        lcall  iface_addressed                       ; 7ED9
        jnc    L_7EE0                                ; 7EDC
        setb   0x79                                  ; 7EDE
L_7EE0::
        ret                                          ; 7EE0
L_7EE1::
        cjne   a, #0xFB, L_7EE7                      ; 7EE1
        ljmp   iface_send_address                    ; 7EE4
L_7EE7::
        cjne   a, #0xFD, L_7EED                      ; 7EE7
        ljmp   iface_send_status                     ; 7EEA
L_7EED::
        cjne   a, #0xF5, L_7F06                      ; 7EED
        lcall  iface_addressed                       ; 7EF0
        jnc    L_7EE0                                ; 7EF3
        jb     0xE7, L_7EE0                          ; 7EF5
        setb   0xE7                                  ; 7EF8

iface_merge_mode_bits::
        anl    a, #0x9F                              ; 7EFA
        mov    0x2F, a                               ; 7EFC
        mov    a, r4                                 ; 7EFE
        anl    a, #0x60                              ; 7EFF
        orl    a, 0x2F                               ; 7F01
        mov    0x2F, a                               ; 7F03
        ret                                          ; 7F05
L_7F06::
        cjne   a, #0xF6, L_7F15                      ; 7F06
L_7F09::
        lcall  iface_mode_match                      ; 7F09
        jnc    L_7EE0                                ; 7F0C
        clr    0xE7                                  ; 7F0E
L_7F10::
        clr    0xE4                                  ; 7F10
        mov    0x2F, a                               ; 7F12
        ret                                          ; 7F14
L_7F15::
        cjne   a, #0xF7, L_7F1E                      ; 7F15
        lcall  iface_mode_match                      ; 7F18
        jc     L_7F10                                ; 7F1B
        ret                                          ; 7F1D
L_7F1E::
        cjne   a, #0xF8, iface_write_ff              ; 7F1E
        lcall  iface_mode_match                      ; 7F21
        jc     L_7F29                                ; 7F24
        jb     0xE7, L_7EE0                          ; 7F26
L_7F29::
        lcall  iface_merge_mode_bits                 ; 7F29
        setb   0xE4                                  ; 7F2C
        mov    0x2F, a                               ; 7F2E
        lcall  iface_poll_once                       ; 7F30
        lcall  iface_poll_once                       ; 7F33
        ljmp   L_7DC9                                ; 7F36

; FF = message received
iface_write_ff::
        mov    r5, #0xFF                             ; 7F39
        ljmp   iface_write_ctrl                      ; 7F3B

; address = 0x58 | ((R4>>4)&6)
iface_i2c_addr::
        mov    a, r4                                 ; 7F3E
        swap   a                                     ; 7F3F
        anl    a, #0x06                              ; 7F40
        orl    a, #0x58                              ; 7F42
        ret                                          ; 7F44

iface_start_write::
        lcall  iface_i2c_addr                        ; 7F45
        ljmp   i2cA_start_write                      ; 7F48

iface_start_read::
        lcall  iface_i2c_addr                        ; 7F4B
        ljmp   i2cA_start_read                       ; 7F4E

iface_send_f4_address::
        mov    r5, #0xF4                             ; 7F51
        lcall  iface_write_ctrl                      ; 7F53

; C0 | GPIB address
iface_send_address::
        mov    a, r4                                 ; 7F56
        anl    a, #0x1F                              ; 7F57
        orl    a, #0xC0                              ; 7F59
        mov    r5, a                                 ; 7F5B

; single control byte R5
iface_write_ctrl::
        lcall  iface_start_write                     ; 7F5C
        mov    a, r5                                 ; 7F5F
        ljmp   i2cA_send_stop                        ; 7F60

; read 1 (or 2 for 8x) status bytes
iface_read_status::
        lcall  iface_start_read                      ; 7F63
        lcall  i2cA_recv_byte                        ; 7F66

iface_status_decode::
        mov    r5, a                                 ; 7F69
        jnb    0xE7, L_7F70                          ; 7F6A
        jnb    0xE6, L_7F75                          ; 7F6D
L_7F70::
        lcall  i2cA_nack_stop                        ; 7F70
        clr    c                                     ; 7F73
        ret                                          ; 7F74
L_7F75::
        lcall  i2cA_send_ack                         ; 7F75
        lcall  i2cA_recv_byte                        ; 7F78
        mov    r6, a                                 ; 7F7B
        mov    a, r5                                 ; 7F7C
        lcall  i2cA_nack_stop                        ; 7F7D
        mov    a, r5                                 ; 7F80
        setb   c                                     ; 7F81
        mov    r5, a                                 ; 7F82
        anl    a, #0x3E                              ; 7F83
        xch    a, r3                                 ; 7F85
        anl    a, #0xC1                              ; 7F86
        orl    a, r3                                 ; 7F88
        mov    r3, a                                 ; 7F89
        mov    a, r5                                 ; 7F8A
        ret                                          ; 7F8B

; 0x80 | (2Eh & 0x3F)
iface_send_status::
        lcall  iface_start_write                     ; 7F8C
        mov    a, 0x2E                               ; 7F8F
        anl    a, #0x3F                              ; 7F91
        orl    a, #0x80                              ; 7F93
        mov    0x2E, a                               ; 7F95
        ljmp   i2cA_send_stop                        ; 7F97

; F1 xx
iface_send_f1::
        mov    r7, a                                 ; 7F9A
        lcall  iface_start_write                     ; 7F9B
        mov    a, #0xF1                              ; 7F9E
        lcall  i2cA_send_byte                        ; 7FA0
        mov    a, r7                                 ; 7FA3
        ljmp   i2cA_send_stop                        ; 7FA4

iface_addressed::
        mov    a, 0x2F                               ; 7FA7
        jb     0xE4, iface_mode_match                ; 7FA9
        setb   c                                     ; 7FAC
        ret                                          ; 7FAD

iface_mode_match::
        setb   c                                     ; 7FAE
        mov    a, 0x2F                               ; 7FAF
        xrl    a, r4                                 ; 7FB1
        anl    a, #0x60                              ; 7FB2
        jz     L_7FB7                                ; 7FB4
        clr    c                                     ; 7FB6
L_7FB7::
        mov    a, 0x2F                               ; 7FB7
        ret                                          ; 7FB9

; add + rotate-right checksum, then send
iface_send_byte_ck::
        xch    a, r7                                 ; 7FBA
        add    a, r7                                 ; 7FBB
        rr     a                                     ; 7FBC
        xch    a, r7                                 ; 7FBD
        ljmp   i2cA_send_byte                        ; 7FBE

; 3-byte channel descriptor (R4 config/address, R3 state, B flags) + context
iface_load_channel::
        push   sfr_ACC                               ; 7FC1
        mov    a, sfr_DPL                            ; 7FC3
        mov    r0, a                                 ; 7FC5
        mov    a, sfr_DPH                            ; 7FC6
        mov    r1, a                                 ; 7FC8
        movx   a, @dptr                              ; 7FC9
        mov    r4, a                                 ; 7FCA
        inc    dptr                                  ; 7FCB
        movx   a, @dptr                              ; 7FCC
        mov    r3, a                                 ; 7FCD
        inc    dptr                                  ; 7FCE
        movx   a, @dptr                              ; 7FCF
        mov    sfr_B, a                              ; 7FD0
        lcall  iface_ctx_load                        ; 7FD2
        pop    sfr_ACC                               ; 7FD5
        ret                                          ; 7FD7
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF ; 7FD8 FREE
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF ; 7FE8 FREE
        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF                                   ; 7FF8 FREE
