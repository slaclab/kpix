//
// Verilog description for cell memory_array_control, 
// Wed Oct 28 12:17:57 2009
//
// LeonardoSpectrum Level 3, 2008b.3 
//


module memory_array_control ( sysclk, reset, command, data_out, temp_id0, 
                              temp_id1, temp_id2, temp_id3, temp_id4, temp_id5, 
                              temp_id6, temp_id7, temp_en, out_reset_l, 
                              int_reset_l, reg_clock, reg_sel1, reg_sel0, 
                              pwr_up_acq, reset_load, leakage_null, offset_null, 
                              thresh_off, trig_inh, cal_strobe, pwr_up_acq_dig, 
                              sel_cell, desel_all_cells, ramp_period, 
                              precharge_bus, analog_state, read_state, reg_data, 
                              reg_wr_ena, rdback ) ;

    input sysclk ;
    input reset ;
    input command ;
    output data_out ;
    input temp_id0 ;
    input temp_id1 ;
    input temp_id2 ;
    input temp_id3 ;
    input temp_id4 ;
    input temp_id5 ;
    input temp_id6 ;
    input temp_id7 ;
    output temp_en ;
    output out_reset_l ;
    input int_reset_l ;
    output reg_clock ;
    output reg_sel1 ;
    output reg_sel0 ;
    output pwr_up_acq ;
    output reset_load ;
    output leakage_null ;
    output offset_null ;
    output thresh_off ;
    output trig_inh ;
    output cal_strobe ;
    output pwr_up_acq_dig ;
    output sel_cell ;
    output desel_all_cells ;
    output ramp_period ;
    output precharge_bus ;
    output analog_state ;
    output read_state ;
    output reg_data ;
    output reg_wr_ena ;
    input rdback ;

    wire U_analog_control_mst_state_0, U_analog_control_mst_state_2, 
         U_analog_control_mst_state_1, nx2827, U_analog_control_sub_cnt_14, 
         U_analog_control_sub_cnt_13, U_analog_control_sub_cnt_12, 
         U_analog_control_sub_cnt_11, U_analog_control_sub_cnt_10, 
         U_analog_control_sub_cnt_9, U_analog_control_sub_cnt_8, 
         U_analog_control_sub_cnt_7, U_analog_control_sub_cnt_6, 
         U_analog_control_sub_cnt_5, U_analog_control_sub_cnt_4, 
         U_analog_control_sub_cnt_3, U_analog_control_sub_cnt_2, 
         U_analog_control_sub_cnt_1, U_analog_control_sub_cnt_0, tc5_data_30, 
         U_command_control_int_hdr_data_10, U_command_control_send_status, 
         U_readout_control_rd_state_0, readout_cmd, 
         U_command_control_int_hdr_data_5, nx2829, 
         U_command_control_int_hdr_data_6, U_command_control_int_hdr_data_7, 
         U_command_control_int_hdr_data_8, U_command_control_int_hdr_data_9, 
         U_command_control_cmd_state_0, U_command_control_cmd_cnt_5, 
         U_command_control_cmd_cnt_4, U_command_control_cmd_cnt_3, 
         U_command_control_cmd_cnt_2, U_command_control_cmd_cnt_1, nx2831, 
         U_command_control_cmd_state_2, U_command_control_cmd_state_1, nx2, 
         U_command_control_cmd_cnt_0, nx2833, nx30, nx42, nx62, nx66, nx76, nx82, 
         nx2836, nx2837, nx90, nx106, nx114, nx116, nx126, nx134, nx154, nx174, 
         nx2843, nx190, nx2845, nx206, nx2846, nx222, nx234, nx244, nx270, nx280, 
         nx286, nx292, nx306, U_command_control_int_cmd_en, nx324, 
         U_command_control_int_par, nx2847, U_command_control_int_hdr_data_13, 
         U_command_control_int_hdr_data_12, int_rdback, NOT_sysclk, nx368, nx380, 
         nx390, nx392, U_command_control_int_hdr_data_11, nx426, nx444, nx462, 
         cd1_data_0, nx470, nx472, cd1_data_1, cd1_data_2, cd1_data_3, 
         cd1_data_4, cd1_data_5, cd1_data_6, cd1_data_7, cd1_data_8, cd1_data_9, 
         cd1_data_10, cd1_data_11, cd1_data_12, 
         U_command_control_CD1_data_out_13, U_command_control_CD1_data_out_14, 
         cd1_data_15, cd1_data_16, cd1_data_17, cd1_data_18, cd1_data_19, 
         cd1_data_20, cd1_data_21, cd1_data_22, cd1_data_23, cd1_data_24, 
         cd1_data_25, cd1_data_26, cd1_data_27, cd1_data_28, 
         U_command_control_CD1_data_out_29, U_command_control_CD1_data_out_30, 
         cd1_data_31, nx500, cd0_data_0, nx632, cd0_data_1, cd0_data_2, 
         cd0_data_3, cd0_data_4, cd0_data_5, cd0_data_6, cd0_data_7, cd0_data_8, 
         cd0_data_9, cd0_data_10, cd0_data_11, cd0_data_12, 
         U_command_control_CD0_data_out_13, U_command_control_CD0_data_out_14, 
         cd0_data_15, cd0_data_16, cd0_data_17, cd0_data_18, cd0_data_19, 
         cd0_data_20, cd0_data_21, cd0_data_22, cd0_data_23, cd0_data_24, 
         cd0_data_25, cd0_data_26, cd0_data_27, cd0_data_28, 
         U_command_control_CD0_data_out_29, U_command_control_CD0_data_out_30, 
         cd0_data_31, nx650, nx784, tc3_data_0, nx826, nx828, tc3_data_1, 
         tc3_data_2, tc3_data_3, tc3_data_4, tc3_data_5, tc3_data_6, tc3_data_7, 
         tc3_data_8, tc3_data_9, tc3_data_10, tc3_data_11, tc3_data_12, 
         tc3_data_13, tc3_data_14, tc3_data_15, tc3_data_16, tc3_data_17, 
         tc3_data_18, tc3_data_19, tc3_data_20, tc3_data_21, tc3_data_22, 
         tc3_data_23, tc3_data_24, tc3_data_25, tc3_data_26, tc3_data_27, 
         tc3_data_28, tc3_data_29, tc3_data_30, tc3_data_31, nx838, tc2_data_0, 
         tc2_data_1, tc2_data_2, tc2_data_3, tc2_data_4, tc2_data_5, tc2_data_6, 
         tc2_data_7, tc2_data_8, tc2_data_9, tc2_data_10, tc2_data_11, 
         tc2_data_12, tc2_data_13, tc2_data_14, tc2_data_15, tc2_data_16, 
         tc2_data_17, tc2_data_18, tc2_data_19, tc2_data_20, tc2_data_21, 
         tc2_data_22, tc2_data_23, tc2_data_24, tc2_data_25, tc2_data_26, 
         tc2_data_27, tc2_data_28, tc2_data_29, tc2_data_30, tc2_data_31, nx980, 
         nx1114, nx1116, nx2848, tc5_data_0, nx2849, tc5_data_1, tc5_data_2, 
         tc5_data_3, tc5_data_4, tc5_data_5, tc5_data_6, tc5_data_7, tc5_data_8, 
         tc5_data_9, tc5_data_10, tc5_data_11, tc5_data_12, tc5_data_13, 
         tc5_data_14, tc5_data_15, tc5_data_16, tc5_data_17, tc5_data_18, 
         tc5_data_19, tc5_data_20, tc5_data_21, tc5_data_22, tc5_data_23, 
         tc5_data_24, tc5_data_25, tc5_data_26, tc5_data_27, tc5_data_28, 
         tc5_data_29, tc4_data_0, nx1248, tc4_data_1, tc4_data_2, tc4_data_3, 
         tc4_data_4, tc4_data_5, tc4_data_6, tc4_data_7, tc4_data_8, tc4_data_9, 
         tc4_data_10, tc4_data_11, tc4_data_12, 
         U_command_control_TC4_data_out_13, U_command_control_TC4_data_out_14, 
         U_command_control_TC4_data_out_15, tc4_data_16, tc4_data_17, 
         tc4_data_18, tc4_data_19, tc4_data_20, tc4_data_21, tc4_data_22, 
         tc4_data_23, tc4_data_24, tc4_data_25, tc4_data_26, tc4_data_27, 
         tc4_data_28, tc4_data_29, tc4_data_30, tc4_data_31, nx1254, nx1388, 
         nx1394, tc1_data_0, tc1_data_1, tc1_data_2, tc1_data_3, tc1_data_4, 
         tc1_data_5, tc1_data_6, tc1_data_7, tc1_data_8, tc1_data_9, tc1_data_10, 
         tc1_data_11, tc1_data_12, tc1_data_13, tc1_data_14, tc1_data_15, 
         tc1_data_16, tc1_data_17, tc1_data_18, tc1_data_19, tc1_data_20, 
         tc1_data_21, tc1_data_22, tc1_data_23, tc1_data_24, tc1_data_25, 
         tc1_data_26, tc1_data_27, tc1_data_28, tc1_data_29, tc1_data_30, 
         tc1_data_31, nx1404, tc0_data_0, tc0_data_1, tc0_data_2, tc0_data_3, 
         tc0_data_4, tc0_data_5, tc0_data_6, tc0_data_7, tc0_data_8, tc0_data_9, 
         tc0_data_10, tc0_data_11, tc0_data_12, tc0_data_13, tc0_data_14, 
         tc0_data_15, tc0_data_16, tc0_data_17, tc0_data_18, tc0_data_19, 
         tc0_data_20, tc0_data_21, tc0_data_22, tc0_data_23, tc0_data_24, 
         tc0_data_25, tc0_data_26, tc0_data_27, tc0_data_28, tc0_data_29, 
         tc0_data_30, tc0_data_31, nx1544, nx1682, test_mode, nx1690, 
         U_command_control_CFG_data_out_1, no_auto_rd, 
         U_command_control_cfg_data_3, U_command_control_cfg_data_4, 
         U_command_control_cfg_data_5, U_command_control_CFG_data_out_6, 
         U_command_control_CFG_data_out_7, U_command_control_CFG_data_out_8, 
         U_command_control_CFG_data_out_9, U_command_control_CFG_data_out_10, 
         U_command_control_CFG_data_out_11, U_command_control_CFG_data_out_12, 
         U_command_control_CFG_data_out_13, U_command_control_CFG_data_out_14, 
         U_command_control_CFG_data_out_15, U_command_control_CFG_data_out_16, 
         U_command_control_CFG_data_out_17, U_command_control_CFG_data_out_18, 
         U_command_control_CFG_data_out_19, U_command_control_CFG_data_out_20, 
         U_command_control_CFG_data_out_21, U_command_control_CFG_data_out_22, 
         U_command_control_CFG_data_out_23, U_command_control_CFG_data_out_24, 
         U_command_control_CFG_data_out_25, U_command_control_CFG_data_out_26, 
         U_command_control_CFG_data_out_27, U_command_control_CFG_data_out_28, 
         U_command_control_CFG_data_out_29, U_command_control_CFG_data_out_30, 
         U_command_control_CFG_data_out_31, nx1696, nx1858, nx1882, 
         U_command_control_head_perr, U_command_control_data_perr, 
         start_sequence, nx2851, nx1924, nx1942, nx1948, nx1960, nx2022, nx2038, 
         nx2044, nx2054, U_readout_control_rd_state_2, nx2853, nx2855, 
         U_readout_control_rd_state_1, nx2068, U_readout_control_row_cnt_3, 
         nx2070, nx2076, U_readout_control_typ_cnt_3, nx2859, 
         U_readout_control_typ_cnt_2, U_readout_control_typ_cnt_1, 
         U_readout_control_typ_cnt_0, nx2090, nx2860, nx2104, nx2861, nx2120, 
         nx2140, U_readout_control_row_cnt_2, U_readout_control_row_cnt_1, 
         U_readout_control_row_cnt_0, nx2148, nx2863, nx2162, nx2864, nx2178, 
         nx2865, nx2194, U_readout_control_row_cnt_4, nx2206, nx2220, 
         U_readout_control_st_cnt_1, U_readout_control_st_cnt_5, 
         U_readout_control_st_cnt_4, U_readout_control_st_cnt_3, 
         U_readout_control_st_cnt_2, nx2866, nx2867, nx2869, nx2236, nx2870, 
         nx2252, nx2871, nx2268, nx2278, nx2286, U_readout_control_st_cnt_7, 
         U_readout_control_st_cnt_6, nx2873, nx2300, nx2310, nx2318, 
         U_readout_control_st_cnt_8, nx2332, U_readout_control_st_cnt_0, nx2350, 
         nx2356, nx2366, nx2372, nx2378, nx2390, nx2394, nx2875, nx2404, nx2877, 
         nx2410, nx2416, nx2436, nx2456, nx2468, nx2478, nx2482, 
         U_readout_control_col_cnt_4, nx2486, nx2488, 
         U_readout_control_col_cnt_3, U_readout_control_col_cnt_2, 
         U_readout_control_col_cnt_1, U_readout_control_col_cnt_0, nx2494, 
         nx2878, nx2508, nx2879, nx2524, nx2880, nx2540, nx2552, nx2570, nx2584, 
         nx2602, nx2622, tc5_data_31, nx2652, nx2662, nx2666, nx2668, nx2670, 
         nx2680, nx2714, nx2881, nx2740, nx2742, nx2744, nx2756, nx2882, nx2780, 
         nx2782, nx2792, nx2794, nx2885, nx2816, nx2834, nx2844, nx2850, nx2856, 
         nx2862, nx2886, nx2876, nx2892, nx2908, nx2889, nx2924, nx2940, nx2893, 
         nx2956, nx2894, nx2972, nx2895, nx2988, nx2896, nx3004, nx2897, nx3020, 
         nx3036, nx3052, nx3114, nx3128, nx3144, nx3158, 
         U_analog_control_int_cur_cell_3, U_analog_control_int_cur_cell_2, 
         U_analog_control_int_cur_cell_1, U_analog_control_int_cur_cell_0, 
         nx3172, nx3178, nx3188, nx3198, nx3208, nx3226, nx3242, nx3270, 
         sel_addr_reg, nx3282, nx3288, nx3300, nx3306, nx3308, nx3310, 
         U_analog_control_sft_desel_all_cells_16, 
         U_analog_control_sft_desel_all_cells_15, 
         U_analog_control_sft_desel_all_cells_14, 
         U_analog_control_sft_desel_all_cells_13, 
         U_analog_control_sft_desel_all_cells_12, 
         U_analog_control_sft_desel_all_cells_11, 
         U_analog_control_sft_desel_all_cells_10, 
         U_analog_control_sft_desel_all_cells_9, 
         U_analog_control_sft_desel_all_cells_8, 
         U_analog_control_sft_desel_all_cells_7, 
         U_analog_control_sft_desel_all_cells_6, 
         U_analog_control_sft_desel_all_cells_5, 
         U_analog_control_sft_desel_all_cells_4, 
         U_analog_control_sft_desel_all_cells_3, 
         U_analog_control_sft_desel_all_cells_2, 
         U_analog_control_sft_desel_all_cells_1, 
         U_analog_control_sft_desel_all_cells_0, nx3324, nx3340, nx3352, nx3376, 
         nx3378, nx3380, nx3392, nx3402, nx3478, nx3488, nx3492, nx3500, nx3516, 
         nx3522, bunch_clock, nx3532, nx3562, U_analog_control_cal_state_0, 
         U_analog_control_cal_state_1, U_analog_control_cal_cnt_12, nx2905, 
         nx3580, U_analog_control_cal_dly_12, U_analog_control_int_cal_pulse_3, 
         U_analog_control_int_cal_pulse_2, U_analog_control_int_cal_pulse_1, 
         nx2907, U_analog_control_int_cal_pulse_0, nx2909, nx3610, nx3620, 
         nx3630, nx3688, nx3694, U_analog_control_cal_cnt_11, 
         U_analog_control_cal_cnt_10, U_analog_control_cal_cnt_9, 
         U_analog_control_cal_cnt_8, U_analog_control_cal_cnt_7, 
         U_analog_control_cal_cnt_6, U_analog_control_cal_cnt_5, 
         U_analog_control_cal_cnt_4, U_analog_control_cal_cnt_3, 
         U_analog_control_cal_cnt_2, U_analog_control_cal_cnt_1, 
         U_analog_control_cal_cnt_0, nx2912, nx3714, nx2913, nx3730, nx3746, 
         nx2918, nx2919, nx3810, nx3826, U_analog_control_cal_dly_11, nx3902, 
         nx3908, U_analog_control_cal_dly_10, nx3938, U_analog_control_cal_dly_9, 
         nx3966, U_analog_control_cal_dly_8, nx4000, U_analog_control_cal_dly_7, 
         nx4028, U_analog_control_cal_dly_6, nx4066, U_analog_control_cal_dly_5, 
         nx4094, U_analog_control_cal_dly_0, nx4128, U_analog_control_cal_dly_4, 
         nx4156, U_analog_control_cal_dly_1, nx4192, U_analog_control_cal_dly_3, 
         nx4220, U_analog_control_cal_dly_2, nx4248, nx4284, start_calibrate, 
         nx4362, nx4374, nx4408, nx4418, nx4428, nx4434, nx4438, 
         U_analog_control_mst_cnt_14, U_analog_control_mst_cnt_13, 
         U_analog_control_mst_cnt_12, U_analog_control_mst_cnt_11, 
         U_analog_control_mst_cnt_10, U_analog_control_mst_cnt_9, 
         U_analog_control_mst_cnt_8, U_analog_control_mst_cnt_7, 
         U_analog_control_mst_cnt_6, U_analog_control_mst_cnt_5, 
         U_analog_control_mst_cnt_4, U_analog_control_mst_cnt_3, 
         U_analog_control_mst_cnt_2, U_analog_control_mst_cnt_1, nx4442, nx2926, 
         nx4454, nx2927, nx4468, nx4482, nx2929, nx4496, nx4510, nx4524, nx4538, 
         nx2934, nx4552, nx4566, nx2937, nx4580, nx4594, nx2941, nx4608, nx4622, 
         nx4632, nx4638, U_analog_control_mst_cnt_31, 
         U_analog_control_mst_cnt_30, U_analog_control_mst_cnt_29, 
         U_analog_control_mst_cnt_28, U_analog_control_mst_cnt_27, 
         U_analog_control_mst_cnt_26, U_analog_control_mst_cnt_25, 
         U_analog_control_mst_cnt_24, U_analog_control_mst_cnt_23, 
         U_analog_control_mst_cnt_22, U_analog_control_mst_cnt_21, 
         U_analog_control_mst_cnt_20, U_analog_control_mst_cnt_19, 
         U_analog_control_mst_cnt_18, U_analog_control_mst_cnt_17, 
         U_analog_control_mst_cnt_16, U_analog_control_mst_cnt_15, nx4652, 
         nx2944, nx4666, nx4680, nx2946, nx4694, nx4708, nx2949, nx4722, nx4736, 
         nx4750, nx4764, nx2958, nx4806, nx4834, nx2962, nx4862, nx4932, nx4934, 
         nx4942, nx4944, nx4956, nx4958, nx4966, nx4968, nx4978, nx4980, nx4988, 
         nx4990, nx5120, nx5126, nx5214, nx5224, nx5230, nx5318, nx5332, nx5338, 
         nx5426, nx5528, nx5622, nx5636, nx5642, nx5654, nx5690, nx5694, nx5706, 
         nx5712, nx5728, nx5742, nx5760, nx5772, nx5780, nx5790, nx5800, nx5808, 
         U_readout_control_int_par, nx5818, nx5824, nx5828, nx5832, nx5836, 
         nx5842, nx5848, nx5854, cmd_reset, nx5868, nx5878, analog_reset, nx5982, 
         nx5986, nx5992, nx6080, nx6108, nx6122, nx2969, nx2979, nx2989, nx2999, 
         nx3009, nx3019, nx3029, nx3039, nx3049, nx3059, nx3069, nx3079, nx3089, 
         nx3099, nx3109, nx3119, nx3129, nx3139, nx3149, nx3159, nx3169, nx3179, 
         nx3189, nx3199, nx3209, nx3219, nx3229, nx3239, nx3249, nx3259, nx3269, 
         nx3279, nx3289, nx3299, nx3309, nx3319, nx3329, nx3339, nx3349, nx3359, 
         nx3369, nx3379, nx3389, nx3399, nx3409, nx3419, nx3429, nx3439, nx3449, 
         nx3459, nx3469, nx3479, nx3489, nx3499, nx3509, nx3519, nx3529, nx3539, 
         nx3549, nx3559, nx3569, nx3579, nx3589, nx3599, nx3609, nx3619, nx3629, 
         nx3639, nx3649, nx3659, nx3669, nx3679, nx3689, nx3699, nx3709, nx3719, 
         nx3729, nx3739, nx3749, nx3759, nx3769, nx3779, nx3789, nx3799, nx3809, 
         nx3819, nx3829, nx3839, nx3849, nx3859, nx3869, nx3879, nx3889, nx3899, 
         nx3909, nx3919, nx3929, nx3939, nx3949, nx3959, nx3969, nx3979, nx3989, 
         nx3999, nx4009, nx4019, nx4029, nx4039, nx4049, nx4059, nx4069, nx4079, 
         nx4089, nx4099, nx4109, nx4119, nx4129, nx4139, nx4149, nx4159, nx4169, 
         nx4179, nx4189, nx4199, nx4209, nx4219, nx4229, nx4239, nx4249, nx4259, 
         nx4269, nx4279, nx4289, nx4299, nx4309, nx4319, nx4329, nx4339, nx4349, 
         nx4359, nx4369, nx4379, nx4389, nx4399, nx4409, nx4419, nx4429, nx4439, 
         nx4449, nx4459, nx4469, nx4479, nx4489, nx4499, nx4509, nx4519, nx4529, 
         nx4539, nx4549, nx4559, nx4569, nx4579, nx4589, nx4599, nx4609, nx4619, 
         nx4629, nx4639, nx4649, nx4659, nx4669, nx4679, nx4689, nx4699, nx4709, 
         nx4719, nx4729, nx4739, nx4749, nx4759, nx4769, nx4779, nx4789, nx4799, 
         nx4809, nx4819, nx4829, nx4839, nx4849, nx4859, nx4869, nx4879, nx4889, 
         nx4899, nx4909, nx4919, nx4929, nx4939, nx4949, nx4959, nx4969, nx4979, 
         nx4989, nx4999, nx5009, nx5019, nx5029, nx5039, nx5049, nx5059, nx5069, 
         nx5079, nx5089, nx5099, nx5109, nx5119, nx5129, nx5139, nx5149, nx5159, 
         nx5169, nx5179, nx5189, nx5199, nx5209, nx5219, nx5229, nx5239, nx5249, 
         nx5259, nx5269, nx5279, nx5289, nx5299, nx5309, nx5319, nx5329, nx5339, 
         nx5349, nx5359, nx5369, nx5379, nx5389, nx5399, nx5409, nx5419, nx5429, 
         nx5439, nx5449, nx5459, nx5469, nx5479, nx5489, nx5499, nx5509, nx5519, 
         nx5529, nx5539, nx5549, nx5559, nx5569, nx5579, nx5589, nx5599, nx5609, 
         nx5619, nx5629, nx5639, nx5649, nx5659, nx5669, nx5679, nx5689, nx5699, 
         nx5709, nx5719, nx5729, nx5739, nx5749, nx5759, nx5769, nx5779, nx5789, 
         nx5799, nx5809, nx5819, nx5829, nx5839, nx5849, nx5859, nx5869, nx5879, 
         nx5889, nx5899, nx5909, nx5919, nx5929, nx5939, nx5949, nx5959, nx5969, 
         nx5979, nx5989, nx5999, nx6009, nx6019, nx6029, nx6039, nx6049, nx6059, 
         nx6069, nx6079, nx6089, nx6099, nx6109, nx6119, nx6139, nx6149, nx6159, 
         nx6199, nx6209, nx6259, nx6289, nx6299, nx6309, nx6319, nx6329, nx6339, 
         nx6353, nx6358, nx6360, nx6362, nx6366, nx6370, nx6372, nx6376, nx6379, 
         nx6382, nx6385, nx6388, nx6391, nx6395, nx6400, nx6402, nx6405, nx6408, 
         nx6411, nx6417, nx6420, nx6423, nx6429, nx6431, nx6434, nx6435, nx6443, 
         nx6445, nx6448, nx6453, nx6455, nx6458, nx6461, nx6467, nx6471, nx6478, 
         nx6482, nx6484, nx6488, nx6492, nx6494, nx6497, nx6499, nx6504, nx6506, 
         nx6508, nx6513, nx6516, nx6518, nx6521, nx6526, nx6529, nx6533, nx6535, 
         nx6537, nx6541, nx6543, nx6545, nx6547, nx6550, nx6553, nx6558, nx6560, 
         nx6564, nx6567, nx6570, nx6573, nx6576, nx6580, nx6589, nx6592, nx6594, 
         nx6596, nx6599, nx6603, nx6606, nx6612, nx6614, nx6619, nx6622, nx6624, 
         nx6627, nx6632, nx6635, nx6637, nx6641, nx6650, nx6654, nx6658, nx6663, 
         nx6664, nx6671, nx6674, nx6680, nx6683, nx6686, nx6689, nx6692, nx6695, 
         nx6698, nx6701, nx6704, nx6707, nx6710, nx6716, nx6718, nx6720, nx6725, 
         nx6727, nx6731, nx6734, nx6737, nx6740, nx6743, nx6756, nx6759, nx6763, 
         nx6765, nx6768, nx6774, nx6777, nx6781, nx6785, nx6788, nx6799, nx6803, 
         nx6812, nx6820, nx6822, nx6825, nx6828, nx6879, nx6902, nx6903, nx6905, 
         nx6916, nx6920, nx6921, nx6948, nx6950, nx6953, nx6957, nx6959, nx6961, 
         nx6963, nx6966, nx6968, nx6970, nx6972, nx6975, nx6977, nx6979, nx6981, 
         nx6983, nx7032, nx7101, nx7103, nx7105, nx7107, nx7109, nx7123, nx7125, 
         nx7133, nx7136, nx7138, nx7140, nx7142, nx7151, nx7159, nx7162, nx7164, 
         nx7166, nx7168, nx7170, nx7179, nx7241, nx7250, nx7277, nx7279, nx7280, 
         nx7285, nx7287, nx7289, nx7291, nx7294, nx7297, nx7301, nx7304, nx7309, 
         nx7312, nx7317, nx7327, nx7329, nx7331, nx7333, nx7339, nx7342, nx7347, 
         nx7355, nx7358, nx7363, nx7368, nx7369, nx7373, nx7380, nx7383, nx7387, 
         nx7394, nx7397, nx7401, nx7408, nx7410, nx7412, nx7414, nx7418, nx7421, 
         nx7423, nx7427, nx7430, nx7450, nx7461, nx7466, nx7468, nx7473, nx7477, 
         nx7479, nx7482, nx7484, nx7488, nx7490, nx7496, nx7498, nx7502, nx7504, 
         nx7510, nx7512, nx7579, nx7581, nx7583, nx7617, nx7684, nx7686, nx7720, 
         nx7790, nx7792, nx7891, nx7893, nx8001, nx8003, nx8005, nx8007, nx8106, 
         nx8108, nx8143, nx8153, nx8159, nx8161, nx8164, nx8168, nx8186, nx8189, 
         nx8191, nx8193, nx8196, nx8199, nx8203, nx8206, nx8209, nx8212, nx8216, 
         nx8219, nx8241, nx8243, nx8246, nx8250, nx8252, nx8254, nx8256, nx8258, 
         nx8263, nx8274, nx8280, nx8282, nx8284, nx8286, nx8288, nx8307, nx8311, 
         nx8318, nx8323, nx8327, nx8332, nx8335, nx8337, nx8355, nx8358, nx8361, 
         nx8367, nx8370, nx8373, nx8379, nx8382, nx8385, nx8391, nx8394, nx8397, 
         nx8403, nx8406, nx8409, nx8415, nx8418, nx8421, nx8427, nx8430, nx8433, 
         nx8437, nx8484, nx8487, nx8490, nx8502, nx8505, nx8511, nx8520, nx8523, 
         nx8531, nx8540, nx8543, nx8549, nx8561, nx8581, nx8599, nx8607, nx8619, 
         nx8646, nx8648, nx8650, nx8652, nx8656, nx8658, nx8660, nx8662, nx8666, 
         nx8668, nx8670, nx8672, nx8681, nx8686, nx8689, nx8692, nx8712, nx8720, 
         nx8728, nx8736, nx8741, nx8744, nx8749, nx8752, nx8757, nx8760, nx8765, 
         nx8776, nx8781, nx8789, nx8792, nx8797, nx8805, nx8808, nx8817, nx8827, 
         nx8831, nx8833, nx8835, nx8839, nx8849, nx8861, nx8863, nx8866, nx8869, 
         nx8870, nx8872, nx8874, nx8876, nx8882, nx8884, nx8891, nx8893, nx8899, 
         nx8901, nx8907, nx8909, nx8915, nx8917, nx8926, nx8928, nx8935, nx8937, 
         nx8944, nx8946, nx8953, nx8955, nx8962, nx8964, nx8970, nx8972, nx8978, 
         nx8980, nx8997, nx8999, nx9001, nx9003, nx9005, nx9013, nx9017, nx9020, 
         nx9022, nx9024, nx9028, nx9030, nx9033, nx9035, nx9037, nx9039, nx9041, 
         nx9043, nx9045, nx9047, nx9049, nx9051, nx9053, nx9055, nx9057, nx9059, 
         nx9061, nx9063, nx9065, nx9067, nx9069, nx9071, nx9074, nx9076, nx9078, 
         nx9080, nx9082, nx9084, nx9086, nx9088, nx9090, nx9092, nx9094, nx9096, 
         nx9098, nx9100, nx9102, nx9104, nx9106, nx9108, nx9110, nx9112, nx9114, 
         nx9119, nx9121, nx9124, nx9126, nx9130, nx9132, nx9134, nx9136, nx9138, 
         nx9140, nx9142, nx9144, nx9146, nx9148, nx9150, nx9152, nx9154, nx9156, 
         nx9158, nx9160, nx9162, nx9167, nx9169, nx9172, nx9174, nx9178, nx9180, 
         nx9182, nx9184, nx9186, nx9188, nx9190, nx9192, nx9194, nx9196, nx9198, 
         nx9200, nx9202, nx9204, nx9206, nx9208, nx9210, nx9215, nx9217, nx9220, 
         nx9222, nx9226, nx9228, nx9230, nx9232, nx9234, nx9236, nx9238, nx9240, 
         nx9242, nx9244, nx9246, nx9248, nx9250, nx9252, nx9254, nx9256, nx9258, 
         nx9263, nx9270, nx9273, nx9276, nx9278, nx9292, nx9294, nx9296, nx9298, 
         nx9300, nx9302, nx9304, nx9306, nx9308, nx9310, nx9312, nx9314, nx9316, 
         nx9318, nx9320, nx9323, nx9326, nx9328, nx9332, nx9334, nx9336, nx9338, 
         nx9340, nx9342, nx9344, nx9346, nx9348, nx9350, nx9352, nx9354, nx9356, 
         nx9358, nx9360, nx9362, nx9364, nx9376, nx9378, nx9398, nx9409, nx9415, 
         nx9418, nx9423, nx9426, nx9430, nx9433, nx9437, nx9440, nx9443, nx9445, 
         nx9448, nx9455, nx9457, nx9460, nx9468, nx9470, nx9472, nx9474, nx9476, 
         nx9478, nx9480, nx9482, nx9484, nx9486, nx9488, nx9490, nx9492, nx9494, 
         nx9504, nx9506, nx9508, nx9514, nx9516, nx9518, nx9520, nx9522, nx9524, 
         nx9526, nx9528, nx9530, nx9532, nx9534, nx9536, nx9538, nx9540, nx9542, 
         nx9544, nx9546, nx9548, nx9550, nx9552, nx9554, nx9556, nx9558, nx9560, 
         nx9562, nx9566, nx9568, nx9570, nx9572, nx9574, nx9576, nx9578, nx9580, 
         nx9959, nx9960, nx9961, nx2939, nx9962, nx9963, nx9964, nx8465, nx9965, 
         nx9966, nx9967, nx9968, nx2935, nx8459, nx9969, nx9970, nx9971, nx9972, 
         nx9973, nx9974, nx9975, nx9976, nx9977, nx9978, nx9979, nx8453, nx2930, 
         nx9980, nx9981, nx9982, nx9983, nx9984, nx9985, nx9986, nx9987, nx9988, 
         nx9989, nx9990, nx9991, nx9992, nx4872, nx9993, nx9994, nx8636, nx9995, 
         nx9996, nx9997, nx9998, nx9999, nx10000, nx10001, nx10002, nx10003, 
         nx10004, nx10005, nx10006, nx10007, nx8601, nx10008, nx2961, nx4848, 
         nx8447, nx10009, nx10010, nx2928, nx9500, nx8441, nx10011, nx10012, 
         nx10013, nx10014, nx10015, nx10016, nx10017, nx10018, nx10019, nx10020, 
         nx10021, nx10022, nx10023, nx2960, nx8545, nx10024, nx10025, nx10026, 
         nx10027, nx10028, nx10029, nx10030, nx10031, nx10032, nx10033, nx10034, 
         nx10035, nx10036, nx10037, nx10038, nx10039, nx10040, nx10041, nx10042, 
         nx10043, nx10044, nx8471, nx2933, nx10045, nx10046, nx10047, nx10048, 
         nx10049, nx10050, nx10051, nx10052, nx10053, nx10054, nx10055, nx10056, 
         nx10057, nx6249, nx10058, nx10059, nx10060, nx10061, nx8625, nx10062, 
         nx10063, nx10064, nx6450, nx10065, nx10066, nx10067, nx10068, nx6415, 
         nx6398, nx10069, nx10070, nx36, nx6463, nx10071, nx10072, nx10073, 
         nx10074, nx10075, nx10076, nx10077, nx8931, nx10078, nx10079, nx10080, 
         nx10081, nx10082, nx8940, nx10083, nx10084, nx10085, nx8949, nx10086, 
         nx10087, nx10088, nx10089, nx10090, nx8922, nx10091, nx10092, nx10093, 
         nx10094, nx10095, nx10096, nx10097, nx10098, nx10099, nx10100, nx10101, 
         nx10102, nx10103, nx10104, nx10105, nx10106, nx10107, nx10108, nx10109, 
         nx10110, nx10111, nx10112, nx10113, nx10114, nx10115, nx10116, nx10117, 
         nx4778, nx10118, nx2953, nx10119, nx10120, nx10121, nx10122, nx10123, 
         nx10124, nx10125, nx10126, nx10127, nx8587, nx10128, nx10129, 
         NOT_nx2957, nx10130, nx10131, nx10132, nx2959, nx10133, nx10134, 
         nx10135, nx10136, nx10137, nx10138, nx10139, nx10140, nx10141, nx10142, 
         nx10143, nx10144, nx10145, nx10146, nx10147, nx10148, nx10149, nx10150, 
         nx10151, nx10152, nx10153, nx10154, nx10155, nx10156, nx10157, nx10158, 
         nx10159, nx10160, nx10161, nx10162, nx10163, nx10164, nx10165, nx10166, 
         nx10167, nx10168, nx10169, nx10170, nx10171, nx10172, nx10173, nx10174, 
         nx10175, nx10176, nx10177, nx10178, nx10179, nx10180, nx6169, nx2915, 
         nx4288, nx10181, nx10182, nx10183, nx10184, nx10185, nx10186, nx10187, 
         nx10188, nx10189, nx2947, nx10190, nx10191, nx10192, nx10193, nx10194, 
         nx10195, nx10196, nx2945, nx8507, nx10197, nx10198, nx14, nx10199, 
         nx10200, nx10201, nx10202, nx10203, nx10204, nx10205, nx10206, nx10207, 
         nx10208, nx10209, nx10210, nx10211, nx10212, nx10213, nx10214, nx10215, 
         nx10216, nx10217, nx10218, nx10219, nx10220, nx10221, nx10222, nx10223, 
         nx10224, nx10225, nx10226, nx10227, nx10228, nx10229, nx10230, nx10231, 
         nx10232, nx6229, nx10233, nx10234, nx10235, nx10236, nx10237, nx10238, 
         nx10239, nx10240, nx10241, nx7119, nx10242, nx10243, nx10244, nx2887, 
         nx7111, nx10245, nx10246, nx10247, nx10248, nx10249, nx10250, nx10251, 
         nx10252, nx10253, nx10254, nx10255, nx10256, nx10257, nx10258, nx10259, 
         nx10260, nx10261, nx10262, nx8677, nx2903, nx10263, nx10264, nx10265, 
         nx10266, nx10267, nx10268, nx10269, nx10270, nx10271, nx10272, nx10273, 
         nx10274, nx10275, nx10276, nx10277, nx6425, nx10278, nx10279, nx10280, 
         nx10281, nx10282, nx10283, nx796, nx7456, nx10284, nx10285, nx10286, 
         nx10287, nx10288, nx10289, nx10290, nx376, nx10291, nx10292, nx10293, 
         nx2841, nx10294, nx10295, nx10296, nx10297, nx10298, nx10299, nx10300, 
         nx10301, nx10302, nx10303, nx10304, nx10305, nx10306, nx10307, nx10308, 
         nx7930, nx10309, nx10310, nx10311, nx10312, nx10313, nx10314, nx10315, 
         nx10316, nx8821, nx10317, nx10318, nx10319, nx10320, nx6219, nx8802, 
         nx10321, nx10322, nx10323, nx10324, nx2923, nx2921, nx10325, nx10326, 
         nx10327, nx10328, nx10329, nx10330, nx10331, nx10332, nx10333, nx10334, 
         nx10335, nx7507, nx10336, nx10337, nx10338, nx10339, nx10340, nx10341, 
         nx10342, nx10343, nx10344, nx10345, nx10346, nx10347, nx10348, nx10349, 
         nx10350, nx10351, nx10352, nx10353, nx10354, nx10355, nx10356, nx10357, 
         nx10358, nx10359, nx10360, nx10361, nx10362, nx3260, nx10363, nx10364, 
         nx10365, nx10366, nx8642, nx10367, nx10368, nx10369, nx10370, nx10371, 
         nx10372, nx6279, nx10373, nx10374, nx10375, nx10376, nx10377, nx10378, 
         nx10379, nx10380, nx10381, nx10382, nx10383, nx10384, nx10385, nx10386, 
         nx10387, nx10388, nx10389, nx10390, nx10391, nx10392, nx10393, nx10394, 
         nx10395, nx10396, nx10397, nx10398, nx10399, nx10400, nx10401, nx10402, 
         nx10403, nx10404, nx10405, nx8841, nx10406, nx10407, nx10408, nx10409, 
         nx10410, nx10411, nx10412, nx10413, nx10414, nx10415, nx10416, nx10417, 
         nx10418, nx10419, nx10420, nx10421, nx6269, nx9265, nx10422, nx8701, 
         nx10423, nx4272, nx9510, nx10424, nx10425, nx10426, nx10427, nx10428, 
         nx10429, nx10430, nx10431, nx10432, nx10433, nx4792, nx10434, nx10435, 
         nx10436, nx10437, nx10438, nx3096, nx10439, nx10440, nx10441, nx10442, 
         nx10443, nx10444, nx8558, nx10445, nx10446, nx2951, nx10447, nx2950, 
         nx10448, nx10449, nx10450, nx10451, nx10452, nx8493, nx10453, nx10454, 
         nx2942, nx10455, nx10456, nx10457, nx2917, nx10458, nx10459, nx10460, 
         nx10461, nx8813, nx10462, nx10463, nx10464, nx2914, nx8809, nx10465, 
         nx10466, nx10467, nx10468, nx10469, nx9015, nx10470, nx10471, nx10472, 
         nx10473, nx10474, nx10475, nx10476, nx3084, nx10477, nx10478, nx10479, 
         nx10480, nx10481, nx10482, nx10483, nx10484, nx10485, nx3068, nx2899, 
         nx2898, nx10486, nx10487, nx10488, nx10489, nx10490, nx10491, nx10492, 
         nx10493, nx10494, nx10495, nx10496, nx10497, nx10498, nx10499, nx10500, 
         nx10501, nx10502, nx10503, nx10504, nx10505, nx10506, nx10507, nx10508, 
         nx10509, nx10510, nx9512, nx10511, nx10512, nx10513, nx10514, nx4820, 
         nx10515, nx10516, nx10517, nx10518, nx10519, nx10520, nx10521, nx10522, 
         nx10523, nx10524, nx10525, nx2943, nx10526, nx10527, nx10528, nx10529, 
         nx10530, nx10531, nx10532, nx10533, nx10534, nx10535, nx10536, nx10537, 
         nx10538, nx10539, nx10540, nx10541, nx10542, nx10543, nx10544, nx10545, 
         nx10546, nx10547, nx10548, nx10549, nx10550, nx8694, nx2911, nx10551, 
         nx10552, nx10553, nx10554, nx10555, nx6750, nx10556, nx2891, nx10557, 
         nx10558, nx6239, nx10559, nx10560, nx10561, nx10562, nx10563, nx10564, 
         nx8525, nx10565, nx10566, nx10567, nx10568, nx10569, nx10570, nx2006, 
         nx10571, nx10572, nx10573, nx10574, nx10575, nx10576, nx10577, nx10578, 
         NOT_nx8603, nx10579, nx10580, NOT_nx8565, nx10581, nx10582, nx10583, 
         nx10584, nx10585, nx10586, nx10587, nx10588, nx10589, nx10590, nx10591, 
         nx10592, nx10593, nx10594, nx10595, nx10596, nx10597, nx10598, nx10599, 
         nx10600, nx10601, nx10602, nx9282, NOT_nx8480, NOT_nx8527, nx10603, 
         nx4906, nx10604, nx10605, nx10606, nx10607, nx10608, nx10609, nx10610, 
         nx6129, nx1990, nx10611, nx10612, nx10613, nx10614, nx10615, nx10616, 
         nx10617, nx10618, nx10619, nx6179, nx10620, nx10621, nx10622, nx10623, 
         nx10624, nx9564, nx10625, nx10626, nx10627, nx6189, nx10628, nx10629, 
         nx10630, nx10631, nx10632, nx10633, nx10634, nx10635, nx10636, nx10637, 
         nx10638, nx10639, nx10640, nx10641, nx10642, nx10643, nx10644, nx10645, 
         nx10646, nx10647, nx10648, nx10649, nx10650, nx10651, nx10652, nx10653, 
         nx10654, nx10655, nx10656, nx10657, nx10658, nx10659, nx10660, nx10661, 
         nx10662, nx10663;
    wire [365:0] \$dummy ;




    Nor2 ix5665 (.OUT (reg_sel1), .A (nx3308), .B (nx8203)) ;
    Nand3 ix2023 (.OUT (nx2022), .A (nx6353), .B (nx8186), .C (nx8191)) ;
    Nand3 ix6354 (.OUT (nx6353), .A (nx82), .B (nx7430), .C (nx126)) ;
    Nand2 ix135 (.OUT (nx134), .A (nx6358), .B (nx6471)) ;
    AOI22 ix6359 (.OUT (nx6358), .A (nx6360), .B (nx82), .C (nx2837), .D (
          nx10210)) ;
    Nor2 ix6361 (.OUT (nx6360), .A (nx6362), .B (
         U_command_control_int_hdr_data_6)) ;
    Mux2 ix3010 (.OUT (nx3009), .A (nx306), .B (U_command_control_int_hdr_data_5
         ), .SEL (nx2829)) ;
    Nand2 ix307 (.OUT (nx306), .A (nx6366), .B (nx6920)) ;
    Nand3 ix107 (.OUT (nx106), .A (nx6370), .B (nx6471), .C (nx6478)) ;
    Nand4 ix6371 (.OUT (nx6370), .A (nx9504), .B (nx6372), .C (nx6425), .D (nx90
          )) ;
    Nor2 ix6373 (.OUT (nx6372), .A (U_command_control_cmd_cnt_4), .B (
         U_command_control_cmd_cnt_5)) ;
    Nor3 ix223 (.OUT (nx222), .A (nx6376), .B (nx2846), .C (nx2833)) ;
    Nor2 ix6377 (.OUT (nx6376), .A (nx2845), .B (U_command_control_cmd_cnt_4)) ;
    Nor2 ix213 (.OUT (nx2845), .A (nx6379), .B (nx6467)) ;
    Nor3 ix207 (.OUT (nx206), .A (nx6382), .B (nx2845), .C (nx2833)) ;
    Nor2 ix6383 (.OUT (nx6382), .A (nx2843), .B (U_command_control_cmd_cnt_3)) ;
    Nor3 ix191 (.OUT (nx190), .A (nx6388), .B (nx2843), .C (nx2833)) ;
    Nor2 ix6389 (.OUT (nx6388), .A (nx2831), .B (U_command_control_cmd_cnt_2)) ;
    Nor2 ix181 (.OUT (nx2831), .A (nx6391), .B (nx6411)) ;
    Nor3 ix175 (.OUT (nx174), .A (nx2831), .B (nx2833), .C (nx6463)) ;
    Nand4 ix167 (.OUT (nx2833), .A (nx6395), .B (nx6453), .C (nx6455), .D (
          nx6461)) ;
    Nand2 ix6396 (.OUT (nx6395), .A (nx42), .B (nx6415)) ;
    Nor3 ix43 (.OUT (nx42), .A (nx6398), .B (nx6402), .C (nx36)) ;
    DFFC reg_U_command_control_cmd_cnt_4 (.Q (U_command_control_cmd_cnt_4), .QB (
         nx6400), .D (nx222), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix235 (.OUT (nx234), .A (nx6405), .B (nx2833)) ;
    DFFC reg_U_command_control_cmd_cnt_5 (.Q (U_command_control_cmd_cnt_5), .QB (
         nx6402), .D (nx234), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix6409 (.OUT (nx6408), .A (U_command_control_cmd_cnt_4), .B (nx2845)
          ) ;
    Nor2 ix31 (.OUT (nx30), .A (U_command_control_cmd_cnt_0), .B (nx2833)) ;
    DFFC reg_U_command_control_cmd_cnt_0 (.Q (U_command_control_cmd_cnt_0), .QB (
         nx6411), .D (nx30), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix271 (.OUT (nx270), .A (nx6420), .B (nx2837), .C (nx6431)) ;
    Nand4 ix6421 (.OUT (nx6420), .A (U_command_control_cmd_state_1), .B (nx62), 
          .C (U_command_control_cmd_state_0), .D (U_command_control_cmd_state_2)
          ) ;
    Nand4 ix6424 (.OUT (nx6423), .A (nx6402), .B (U_command_control_cmd_cnt_4), 
          .C (nx6425), .D (nx2831)) ;
    DFFC U_command_control_reg_cmd_state_0 (.Q (U_command_control_cmd_state_0), 
         .QB (nx6417), .D (nx270), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix279 (.OUT (nx2837), .A (nx6429), .B (U_command_control_cmd_state_0)
          ) ;
    Nor2 ix6430 (.OUT (nx6429), .A (U_command_control_cmd_state_1), .B (
         U_command_control_cmd_state_2)) ;
    AOI22 ix6432 (.OUT (nx6431), .A (reg_data), .B (nx6429), .C (nx6435), .D (
          nx2836)) ;
    DFFC U_command_control_reg_int_command (.Q (reg_data), .QB (nx6434), .D (
         command), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_1 (.Q (U_command_control_cmd_cnt_1), .QB (
         nx6391), .D (nx174), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_2 (.Q (U_command_control_cmd_cnt_2), .QB (
         nx6385), .D (nx190), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_3 (.Q (U_command_control_cmd_cnt_3), .QB (
         nx6379), .D (nx206), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix121 (.OUT (nx2836), .A (nx6443), .B (nx6445)) ;
    DFFC U_command_control_reg_cmd_state_2 (.Q (U_command_control_cmd_state_2), 
         .QB (nx6443), .D (nx134), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix6446 (.OUT (nx6445), .A (nx116), .B (nx114)) ;
    Nor2 ix117 (.OUT (nx116), .A (nx6448), .B (nx6450)) ;
    DFFC U_command_control_reg_cmd_state_1 (.Q (U_command_control_cmd_state_1), 
         .QB (nx6448), .D (nx106), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix115 (.OUT (nx114), .A (nx6448), .B (U_command_control_cmd_state_0)) ;
    Nand2 ix6454 (.OUT (nx6453), .A (nx6443), .B (nx6415)) ;
    Nand2 ix6456 (.OUT (nx6455), .A (nx2837), .B (nx154)) ;
    Nand2 ix155 (.OUT (nx154), .A (nx6458), .B (nx2)) ;
    Nand2 ix6459 (.OUT (nx6458), .A (nx6443), .B (nx42)) ;
    Nand4 ix6462 (.OUT (nx6461), .A (U_command_control_cmd_state_2), .B (
          U_command_control_cmd_state_1), .C (nx6435), .D (nx6417)) ;
    Nand2 ix6468 (.OUT (nx6467), .A (U_command_control_cmd_cnt_2), .B (nx2831)
          ) ;
    Nor2 ix91 (.OUT (nx90), .A (U_command_control_cmd_cnt_1), .B (nx6411)) ;
    AOI22 ix6479 (.OUT (nx6478), .A (U_command_control_int_hdr_data_5), .B (nx82
          ), .C (nx6417), .D (nx66)) ;
    DFFC U_command_control_reg_int_hdr_data_5 (.Q (
         U_command_control_int_hdr_data_5), .QB (nx6362), .D (nx3009), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix67 (.OUT (nx66), .A (nx6482), .B (nx6484)) ;
    Nand2 ix6483 (.OUT (nx6482), .A (nx62), .B (U_command_control_cmd_state_1)
          ) ;
    Nand3 ix6485 (.OUT (nx6484), .A (nx6429), .B (U_command_control_send_status)
          , .C (nx6434)) ;
    Nor2 ix2623 (.OUT (nx2622), .A (nx6488), .B (nx7277)) ;
    DFFC U_readout_control_reg_readout_done (.Q (\$dummy [0]), .QB (nx6488), .D (
         nx2855), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix2617 (.OUT (nx2855), .A (nx2853), .B (nx2875)) ;
    Nand2 ix2611 (.OUT (nx2853), .A (nx6492), .B (U_readout_control_rd_state_0)
          ) ;
    Nor2 ix6493 (.OUT (nx6492), .A (nx6494), .B (nx6508)) ;
    Nand3 ix2469 (.OUT (nx2468), .A (nx6497), .B (nx2877), .C (nx7427)) ;
    Nand2 ix6498 (.OUT (nx6497), .A (nx6499), .B (nx7423)) ;
    DFFC U_readout_control_reg_rd_state_1 (.Q (U_readout_control_rd_state_1), .QB (
         nx6494), .D (nx2468), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix2571 (.OUT (nx2570), .A (nx6504), .B (nx7373), .C (nx7421)) ;
    Nand2 ix6505 (.OUT (nx6504), .A (nx6506), .B (nx7289)) ;
    DFFC U_readout_control_reg_rd_state_2 (.Q (U_readout_control_rd_state_2), .QB (
         nx6508), .D (nx2570), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix2603 (.OUT (nx2602), .A (nx2068), .B (nx2456), .C (nx6518), .D (
          nx6619)) ;
    Nand2 ix2069 (.OUT (nx2068), .A (nx6492), .B (nx6513)) ;
    DFFC U_readout_control_reg_rd_state_0 (.Q (U_readout_control_rd_state_0), .QB (
         nx6513), .D (nx2602), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix2457 (.OUT (nx2456), .A (nx6516), .B (U_readout_control_rd_state_0)
          ) ;
    Nor2 ix6517 (.OUT (nx6516), .A (U_readout_control_rd_state_1), .B (
         U_readout_control_rd_state_2)) ;
    AOI22 ix6519 (.OUT (nx6518), .A (nx2875), .B (nx6492), .C (nx2416), .D (
          nx2584)) ;
    Nor3 ix2237 (.OUT (nx2236), .A (nx6526), .B (nx2867), .C (nx2869)) ;
    Nor2 ix6527 (.OUT (nx6526), .A (nx2866), .B (U_readout_control_st_cnt_2)) ;
    Nor2 ix2443 (.OUT (nx2866), .A (nx6529), .B (nx6541)) ;
    Nor3 ix2437 (.OUT (nx2436), .A (nx2869), .B (nx2866), .C (nx6612)) ;
    Nand4 ix2433 (.OUT (nx2869), .A (nx6533), .B (nx2068), .C (nx2070), .D (
          nx6603)) ;
    Nand2 ix6534 (.OUT (nx6533), .A (nx6535), .B (nx6537)) ;
    Nor3 ix6538 (.OUT (nx6537), .A (U_readout_control_st_cnt_0), .B (nx6529), .C (
         nx2378)) ;
    DFFC reg_U_readout_control_st_cnt_0 (.Q (U_readout_control_st_cnt_0), .QB (
         nx6541), .D (nx2350), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix2351 (.OUT (nx2350), .A (U_readout_control_st_cnt_0), .B (nx2869)) ;
    Nand4 ix2379 (.OUT (nx2378), .A (nx6543), .B (nx6560), .C (nx6573), .D (
          nx6596)) ;
    Nor2 ix6544 (.OUT (nx6543), .A (nx6545), .B (nx6547)) ;
    DFFC reg_U_readout_control_st_cnt_2 (.Q (U_readout_control_st_cnt_2), .QB (
         nx6545), .D (nx2236), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2253 (.OUT (nx2252), .A (nx6550), .B (nx2870), .C (nx2869)) ;
    Nor2 ix6551 (.OUT (nx6550), .A (nx2867), .B (U_readout_control_st_cnt_3)) ;
    DFFC reg_U_readout_control_st_cnt_1 (.Q (U_readout_control_st_cnt_1), .QB (
         nx6529), .D (nx2436), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_st_cnt_3 (.Q (U_readout_control_st_cnt_3), .QB (
         nx6547), .D (nx2252), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix2259 (.OUT (nx2870), .A (nx6547), .B (nx6558)) ;
    Nand2 ix6559 (.OUT (nx6558), .A (U_readout_control_st_cnt_2), .B (nx2866)) ;
    Nor3 ix6561 (.OUT (nx6560), .A (U_readout_control_st_cnt_6), .B (
         U_readout_control_st_cnt_7), .C (U_readout_control_st_cnt_5)) ;
    Nor3 ix2301 (.OUT (nx2300), .A (nx6564), .B (nx2873), .C (nx2869)) ;
    Nor2 ix6565 (.OUT (nx6564), .A (nx2278), .B (U_readout_control_st_cnt_6)) ;
    Nor2 ix2279 (.OUT (nx2278), .A (nx6567), .B (nx6580)) ;
    Nor3 ix2287 (.OUT (nx2286), .A (nx6570), .B (nx2278), .C (nx2869)) ;
    Nor2 ix6571 (.OUT (nx6570), .A (nx2871), .B (U_readout_control_st_cnt_5)) ;
    Nor3 ix2269 (.OUT (nx2268), .A (nx6576), .B (nx2871), .C (nx2869)) ;
    Nor2 ix6577 (.OUT (nx6576), .A (nx2870), .B (U_readout_control_st_cnt_4)) ;
    DFFC reg_U_readout_control_st_cnt_4 (.Q (U_readout_control_st_cnt_4), .QB (
         nx6573), .D (nx2268), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_st_cnt_5 (.Q (U_readout_control_st_cnt_5), .QB (
         nx6567), .D (nx2286), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix6581 (.OUT (nx6580), .A (U_readout_control_st_cnt_4), .B (nx2870)) ;
    DFFC reg_U_readout_control_st_cnt_6 (.Q (U_readout_control_st_cnt_6), .QB (
         \$dummy [1]), .D (nx2300), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2319 (.OUT (nx2318), .A (nx6589), .B (nx2310), .C (nx2869)) ;
    Nor2 ix6590 (.OUT (nx6589), .A (nx2873), .B (U_readout_control_st_cnt_7)) ;
    Nor2 ix2311 (.OUT (nx2310), .A (nx6592), .B (nx6594)) ;
    DFFC reg_U_readout_control_st_cnt_7 (.Q (U_readout_control_st_cnt_7), .QB (
         nx6592), .D (nx2318), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix6595 (.OUT (nx6594), .A (U_readout_control_st_cnt_6), .B (nx2278)) ;
    Nor2 ix2333 (.OUT (nx2332), .A (nx6599), .B (nx2869)) ;
    DFFC reg_U_readout_control_st_cnt_8 (.Q (U_readout_control_st_cnt_8), .QB (
         nx6596), .D (nx2332), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix2071 (.OUT (nx2070), .A (nx6516), .B (nx6513)) ;
    Nor2 ix6604 (.OUT (nx6603), .A (nx2404), .B (nx2372)) ;
    AO22 ix2405 (.OUT (nx2404), .A (nx6606), .B (nx6492), .C (nx2390), .D (
         nx2394)) ;
    Nor2 ix6607 (.OUT (nx6606), .A (nx2378), .B (nx6553)) ;
    Nor3 ix2391 (.OUT (nx2390), .A (nx2378), .B (U_readout_control_st_cnt_1), .C (
         nx6541)) ;
    Nor2 ix2395 (.OUT (nx2394), .A (nx6494), .B (U_readout_control_rd_state_0)
         ) ;
    Nor3 ix2373 (.OUT (nx2372), .A (nx2366), .B (U_readout_control_rd_state_1), 
         .C (U_readout_control_rd_state_2)) ;
    Nand4 ix2367 (.OUT (nx2366), .A (nx6543), .B (nx6612), .C (nx6614), .D (
          nx6560)) ;
    Nor2 ix6613 (.OUT (nx6612), .A (U_readout_control_st_cnt_0), .B (
         U_readout_control_st_cnt_1)) ;
    Nor2 ix6615 (.OUT (nx6614), .A (nx6573), .B (nx6596)) ;
    Nor2 ix2585 (.OUT (nx2584), .A (U_readout_control_rd_state_2), .B (nx6513)
         ) ;
    Nand2 ix6620 (.OUT (nx6619), .A (nx2054), .B (nx6516)) ;
    Nand2 ix2055 (.OUT (nx2054), .A (nx6622), .B (nx7280)) ;
    Nand4 ix6623 (.OUT (nx6622), .A (nx6624), .B (nx6716), .C (
          U_analog_control_mst_state_2), .D (nx7179)) ;
    Nand2 ix3271 (.OUT (nx3270), .A (nx6627), .B (nx2827)) ;
    AOI22 ix6628 (.OUT (nx6627), .A (start_sequence), .B (nx9506), .C (nx6983), 
          .D (nx7159)) ;
    DFFC U_command_control_reg_int_sequence (.Q (start_sequence), .QB (nx6664), 
         .D (nx5929), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5930 (.OUT (nx5929), .A (nx2851), .B (start_sequence), .SEL (nx1924)
         ) ;
    Nor2 ix2031 (.OUT (nx2851), .A (U_command_control_int_hdr_data_5), .B (
         nx6632)) ;
    DFFC U_command_control_reg_int_cmd_en (.Q (U_command_control_int_cmd_en), .QB (
         nx6632), .D (nx2022), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix1925 (.OUT (nx1924), .A (nx6635), .B (nx2851)) ;
    Nand2 ix6636 (.OUT (nx6635), .A (nx6637), .B (
          U_command_control_int_hdr_data_8)) ;
    Mux2 ix2970 (.OUT (nx2969), .A (nx280), .B (U_command_control_int_hdr_data_9
         ), .SEL (nx2829)) ;
    Nand2 ix281 (.OUT (nx280), .A (nx9504), .B (nx6641)) ;
    AO22 ix6100 (.OUT (nx6099), .A (U_command_control_int_hdr_data_11), .B (
         nx9504), .C (U_command_control_int_hdr_data_10), .D (nx6650)) ;
    DFFC U_command_control_reg_int_hdr_data_11 (.Q (
         U_command_control_int_hdr_data_11), .QB (nx6654), .D (nx3039), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3040 (.OUT (nx3039), .A (U_command_control_int_hdr_data_12), .B (
         nx9504), .C (U_command_control_int_hdr_data_11), .D (nx6650)) ;
    DFFC U_command_control_reg_int_hdr_data_12 (.Q (
         U_command_control_int_hdr_data_12), .QB (\$dummy [2]), .D (nx3029), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3030 (.OUT (nx3029), .A (U_command_control_int_hdr_data_13), .B (
         nx9504), .C (U_command_control_int_hdr_data_12), .D (nx6650)) ;
    DFFC U_command_control_reg_int_hdr_data_13 (.Q (
         U_command_control_int_hdr_data_13), .QB (\$dummy [3]), .D (nx3019), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3020 (.OUT (nx3019), .A (nx9504), .B (reg_data), .C (
         U_command_control_int_hdr_data_13), .D (nx6650)) ;
    DFFC U_command_control_reg_int_hdr_data_10 (.Q (
         U_command_control_int_hdr_data_10), .QB (nx6641), .D (nx6099), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_9 (.Q (
         U_command_control_int_hdr_data_9), .QB (nx6637), .D (nx2969), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix2631 (.OUT (nx2829), .A (nx2837), .B (nx6658)) ;
    DFFC U_command_control_reg_send_status (.Q (U_command_control_send_status), 
         .QB (nx6658), .D (nx2622), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_8 (.Q (
         U_command_control_int_hdr_data_8), .QB (nx6663), .D (nx2979), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix2980 (.OUT (nx2979), .A (nx286), .B (U_command_control_int_hdr_data_8
         ), .SEL (nx2829)) ;
    Nand2 ix287 (.OUT (nx286), .A (nx9504), .B (nx6637)) ;
    DFFC U_analog_control_reg_mst_state_0 (.Q (U_analog_control_mst_state_0), .QB (
         nx6624), .D (nx3270), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix3227 (.OUT (nx3226), .A (nx2666), .B (nx7133), .C (nx7140)) ;
    Nand2 ix2667 (.OUT (nx2666), .A (U_analog_control_mst_state_1), .B (nx6671)
          ) ;
    Nand2 ix3243 (.OUT (nx3242), .A (nx6674), .B (nx2885)) ;
    Nand4 ix6675 (.OUT (nx6674), .A (nx2680), .B (nx7123), .C (nx7125), .D (
          nx2714)) ;
    Nor3 ix2681 (.OUT (nx2680), .A (nx2662), .B (nx2668), .C (nx2670)) ;
    Nor3 ix2957 (.OUT (nx2956), .A (nx6680), .B (nx2893), .C (nx9494)) ;
    Nor2 ix6681 (.OUT (nx6680), .A (nx2891), .B (U_analog_control_sub_cnt_6)) ;
    Nor3 ix2941 (.OUT (nx2940), .A (nx6686), .B (nx2891), .C (nx9494)) ;
    Nor2 ix6687 (.OUT (nx6686), .A (nx2889), .B (U_analog_control_sub_cnt_5)) ;
    Nor3 ix2925 (.OUT (nx2924), .A (nx6692), .B (nx2889), .C (nx9494)) ;
    Nor2 ix6693 (.OUT (nx6692), .A (nx2887), .B (U_analog_control_sub_cnt_4)) ;
    Nor3 ix2909 (.OUT (nx2908), .A (nx6698), .B (nx2887), .C (nx9494)) ;
    Nor2 ix6699 (.OUT (nx6698), .A (nx2882), .B (U_analog_control_sub_cnt_3)) ;
    Nor3 ix2893 (.OUT (nx2892), .A (nx6704), .B (nx2882), .C (nx9494)) ;
    Nor2 ix6705 (.OUT (nx6704), .A (nx2886), .B (U_analog_control_sub_cnt_2)) ;
    Nor2 ix2883 (.OUT (nx2886), .A (nx6707), .B (nx6727)) ;
    Nor3 ix2877 (.OUT (nx2876), .A (nx6710), .B (nx2886), .C (nx9494)) ;
    Nor2 ix6711 (.OUT (nx6710), .A (U_analog_control_sub_cnt_0), .B (
         U_analog_control_sub_cnt_1)) ;
    Nor2 ix2863 (.OUT (nx2862), .A (U_analog_control_sub_cnt_0), .B (nx9494)) ;
    Nand4 ix2857 (.OUT (nx2856), .A (nx2044), .B (nx6718), .C (nx6820), .D (
          nx6674)) ;
    DFFC U_analog_control_reg_mst_state_1 (.Q (U_analog_control_mst_state_1), .QB (
         nx6716), .D (nx3226), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix6726 (.OUT (nx6725), .A (nx6727), .B (U_analog_control_sub_cnt_1), .C (
         nx2834)) ;
    DFFC reg_U_analog_control_sub_cnt_0 (.Q (U_analog_control_sub_cnt_0), .QB (
         nx6727), .D (nx2862), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_1 (.Q (U_analog_control_sub_cnt_1), .QB (
         nx6707), .D (nx2876), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix2835 (.OUT (nx2834), .A (nx6731), .B (nx6756), .C (nx6765), .D (
          nx6774)) ;
    Nor3 ix2989 (.OUT (nx2988), .A (nx6734), .B (nx2895), .C (nx9492)) ;
    Nor2 ix6735 (.OUT (nx6734), .A (nx2894), .B (U_analog_control_sub_cnt_8)) ;
    Nor2 ix2979 (.OUT (nx2894), .A (nx6737), .B (nx6750)) ;
    Nor3 ix2973 (.OUT (nx2972), .A (nx6740), .B (nx2894), .C (nx9492)) ;
    Nor2 ix6741 (.OUT (nx6740), .A (nx2893), .B (U_analog_control_sub_cnt_7)) ;
    DFFC reg_U_analog_control_sub_cnt_6 (.Q (U_analog_control_sub_cnt_6), .QB (
         nx6743), .D (nx2956), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_5 (.Q (U_analog_control_sub_cnt_5), .QB (
         nx6683), .D (nx2940), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_4 (.Q (U_analog_control_sub_cnt_4), .QB (
         nx6689), .D (nx2924), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_7 (.Q (U_analog_control_sub_cnt_7), .QB (
         nx6737), .D (nx2972), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_8 (.Q (U_analog_control_sub_cnt_8), .QB (
         nx6731), .D (nx2988), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3005 (.OUT (nx3004), .A (nx6759), .B (nx2896), .C (nx9492)) ;
    Nor2 ix6760 (.OUT (nx6759), .A (nx2895), .B (U_analog_control_sub_cnt_9)) ;
    DFFC reg_U_analog_control_sub_cnt_9 (.Q (U_analog_control_sub_cnt_9), .QB (
         nx6756), .D (nx3004), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix3011 (.OUT (nx2896), .A (nx6756), .B (nx6763)) ;
    Nand2 ix6764 (.OUT (nx6763), .A (U_analog_control_sub_cnt_8), .B (nx2894)) ;
    Nor3 ix3021 (.OUT (nx3020), .A (nx6768), .B (nx2897), .C (nx9492)) ;
    Nor2 ix6769 (.OUT (nx6768), .A (nx2896), .B (U_analog_control_sub_cnt_10)) ;
    DFFC reg_U_analog_control_sub_cnt_10 (.Q (U_analog_control_sub_cnt_10), .QB (
         nx6765), .D (nx3020), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3037 (.OUT (nx3036), .A (nx6777), .B (nx2898), .C (nx9492)) ;
    Nor2 ix6778 (.OUT (nx6777), .A (nx2897), .B (U_analog_control_sub_cnt_11)) ;
    DFFC reg_U_analog_control_sub_cnt_11 (.Q (U_analog_control_sub_cnt_11), .QB (
         nx6774), .D (nx3036), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix6782 (.OUT (nx6781), .A (U_analog_control_sub_cnt_10), .B (nx2896)
          ) ;
    Nand4 ix2817 (.OUT (nx2816), .A (nx6785), .B (U_analog_control_sub_cnt_13), 
          .C (nx6803), .D (nx6812)) ;
    Nor3 ix3053 (.OUT (nx3052), .A (nx6788), .B (nx2899), .C (nx9492)) ;
    Nor2 ix6789 (.OUT (nx6788), .A (nx2898), .B (U_analog_control_sub_cnt_12)) ;
    DFFC reg_U_analog_control_sub_cnt_12 (.Q (U_analog_control_sub_cnt_12), .QB (
         nx6785), .D (nx3052), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_13 (.Q (U_analog_control_sub_cnt_13), .QB (
         nx6799), .D (nx3068), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_14 (.Q (U_analog_control_sub_cnt_14), .QB (
         nx6803), .D (nx3084), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_sub_cnt_15 (.Q (\$dummy [4]), .QB (nx6812), .D (nx3096
         ), .CLK (sysclk), .CLR (int_reset_l)) ;
    AOI22 ix6821 (.OUT (nx6820), .A (nx6822), .B (nx6825), .C (nx6983), .D (
          nx2794)) ;
    DFFC U_analog_control_reg_mst_state_2 (.Q (U_analog_control_mst_state_2), .QB (
         nx6671), .D (nx3242), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor4 ix6826 (.OUT (nx6825), .A (nx3158), .B (nx3144), .C (nx3128), .D (
         nx3114)) ;
    Nand4 ix3159 (.OUT (nx3158), .A (nx6828), .B (nx6948), .C (nx6950), .D (
          nx6953)) ;
    DFFC U_command_control_TC5_reg_reg_data_8 (.Q (tc5_data_8), .QB (\$dummy [5]
         ), .D (nx4539), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4540 (.OUT (nx4539), .A (tc5_data_9), .B (tc5_data_8), .SEL (nx9474)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_9 (.Q (tc5_data_9), .QB (\$dummy [6]
         ), .D (nx4529), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4530 (.OUT (nx4529), .A (tc5_data_10), .B (tc5_data_9), .SEL (nx9474)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_10 (.Q (tc5_data_10), .QB (
         \$dummy [7]), .D (nx4519), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4520 (.OUT (nx4519), .A (tc5_data_11), .B (tc5_data_10), .SEL (nx9474
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_11 (.Q (tc5_data_11), .QB (
         \$dummy [8]), .D (nx4509), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4510 (.OUT (nx4509), .A (tc5_data_12), .B (tc5_data_11), .SEL (nx9474
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_12 (.Q (tc5_data_12), .QB (
         \$dummy [9]), .D (nx4499), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4500 (.OUT (nx4499), .A (tc5_data_13), .B (tc5_data_12), .SEL (nx9474
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_13 (.Q (tc5_data_13), .QB (
         \$dummy [10]), .D (nx4489), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4490 (.OUT (nx4489), .A (tc5_data_14), .B (tc5_data_13), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_14 (.Q (tc5_data_14), .QB (
         \$dummy [11]), .D (nx4479), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4480 (.OUT (nx4479), .A (tc5_data_15), .B (tc5_data_14), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_15 (.Q (tc5_data_15), .QB (
         \$dummy [12]), .D (nx4469), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4470 (.OUT (nx4469), .A (tc5_data_16), .B (tc5_data_15), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_16 (.Q (tc5_data_16), .QB (
         \$dummy [13]), .D (nx4459), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4460 (.OUT (nx4459), .A (tc5_data_17), .B (tc5_data_16), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_17 (.Q (tc5_data_17), .QB (
         \$dummy [14]), .D (nx4449), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4450 (.OUT (nx4449), .A (tc5_data_18), .B (tc5_data_17), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_18 (.Q (tc5_data_18), .QB (
         \$dummy [15]), .D (nx4439), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4440 (.OUT (nx4439), .A (tc5_data_19), .B (tc5_data_18), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_19 (.Q (tc5_data_19), .QB (
         \$dummy [16]), .D (nx4429), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4430 (.OUT (nx4429), .A (tc5_data_20), .B (tc5_data_19), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_20 (.Q (tc5_data_20), .QB (
         \$dummy [17]), .D (nx4419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4420 (.OUT (nx4419), .A (tc5_data_21), .B (tc5_data_20), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_21 (.Q (tc5_data_21), .QB (
         \$dummy [18]), .D (nx4409), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4410 (.OUT (nx4409), .A (tc5_data_22), .B (tc5_data_21), .SEL (nx9472
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_22 (.Q (tc5_data_22), .QB (
         \$dummy [19]), .D (nx4399), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4400 (.OUT (nx4399), .A (tc5_data_23), .B (tc5_data_22), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_23 (.Q (tc5_data_23), .QB (
         \$dummy [20]), .D (nx4389), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4390 (.OUT (nx4389), .A (tc5_data_24), .B (tc5_data_23), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_24 (.Q (tc5_data_24), .QB (
         \$dummy [21]), .D (nx4379), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4380 (.OUT (nx4379), .A (tc5_data_25), .B (tc5_data_24), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_25 (.Q (tc5_data_25), .QB (
         \$dummy [22]), .D (nx4369), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4370 (.OUT (nx4369), .A (tc5_data_26), .B (tc5_data_25), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_26 (.Q (tc5_data_26), .QB (
         \$dummy [23]), .D (nx4359), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4360 (.OUT (nx4359), .A (tc5_data_27), .B (tc5_data_26), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_27 (.Q (tc5_data_27), .QB (
         \$dummy [24]), .D (nx4349), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4350 (.OUT (nx4349), .A (tc5_data_28), .B (tc5_data_27), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_28 (.Q (tc5_data_28), .QB (
         \$dummy [25]), .D (nx4339), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4340 (.OUT (nx4339), .A (tc5_data_29), .B (tc5_data_28), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_29 (.Q (tc5_data_29), .QB (
         \$dummy [26]), .D (nx4329), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4330 (.OUT (nx4329), .A (tc5_data_30), .B (tc5_data_29), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_30 (.Q (tc5_data_30), .QB (
         \$dummy [27]), .D (nx6119), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6120 (.OUT (nx6119), .A (tc5_data_31), .B (tc5_data_30), .SEL (nx9470
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_31 (.Q (tc5_data_31), .QB (
         \$dummy [28]), .D (nx6109), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6110 (.OUT (nx6109), .A (nx2652), .B (tc5_data_31), .SEL (nx9468)) ;
    Nand2 ix2653 (.OUT (nx2652), .A (nx6879), .B (nx6921)) ;
    Nand2 ix6880 (.OUT (nx6879), .A (tc5_data_0), .B (nx6916)) ;
    DFFC U_command_control_TC5_reg_reg_data_0 (.Q (tc5_data_0), .QB (
         \$dummy [29]), .D (nx4619), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4620 (.OUT (nx4619), .A (tc5_data_1), .B (tc5_data_0), .SEL (nx9468)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_1 (.Q (tc5_data_1), .QB (
         \$dummy [30]), .D (nx4609), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4610 (.OUT (nx4609), .A (tc5_data_2), .B (tc5_data_1), .SEL (nx9468)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_2 (.Q (tc5_data_2), .QB (
         \$dummy [31]), .D (nx4599), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4600 (.OUT (nx4599), .A (tc5_data_3), .B (tc5_data_2), .SEL (nx9468)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_3 (.Q (tc5_data_3), .QB (
         \$dummy [32]), .D (nx4589), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4590 (.OUT (nx4589), .A (tc5_data_4), .B (tc5_data_3), .SEL (nx9468)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_4 (.Q (tc5_data_4), .QB (
         \$dummy [33]), .D (nx4579), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4580 (.OUT (nx4579), .A (tc5_data_5), .B (tc5_data_4), .SEL (nx9468)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_5 (.Q (tc5_data_5), .QB (
         \$dummy [34]), .D (nx4569), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4570 (.OUT (nx4569), .A (tc5_data_6), .B (tc5_data_5), .SEL (nx9468)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_6 (.Q (tc5_data_6), .QB (
         \$dummy [35]), .D (nx4559), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4560 (.OUT (nx4559), .A (tc5_data_7), .B (tc5_data_6), .SEL (nx9468)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_7 (.Q (tc5_data_7), .QB (
         \$dummy [36]), .D (nx4549), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4550 (.OUT (nx4549), .A (tc5_data_8), .B (tc5_data_7), .SEL (nx9468)
         ) ;
    Nor4 ix2647 (.OUT (nx2849), .A (nx6641), .B (nx6637), .C (nx470), .D (nx6903
         )) ;
    DFFC U_command_control_reg_int_hdr_data_7 (.Q (
         U_command_control_int_hdr_data_7), .QB (nx6902), .D (nx2989), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix2990 (.OUT (nx2989), .A (nx292), .B (U_command_control_int_hdr_data_7
         ), .SEL (nx2829)) ;
    Nand2 ix293 (.OUT (nx292), .A (nx9504), .B (nx6663)) ;
    Nand3 ix6904 (.OUT (nx6903), .A (nx6905), .B (nx6654), .C (nx472)) ;
    Nor2 ix6906 (.OUT (nx6905), .A (U_command_control_int_hdr_data_12), .B (
         U_command_control_int_hdr_data_13)) ;
    Nor2 ix473 (.OUT (nx472), .A (nx6362), .B (nx6632)) ;
    DFFC U_command_control_reg_int_hdr_data_6 (.Q (
         U_command_control_int_hdr_data_6), .QB (nx6920), .D (nx2999), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3000 (.OUT (nx2999), .A (U_command_control_int_hdr_data_7), .B (
         nx9504), .C (U_command_control_int_hdr_data_6), .D (nx6650)) ;
    Nand2 ix6922 (.OUT (nx6921), .A (reg_wr_ena), .B (reg_data)) ;
    Nor2 ix493 (.OUT (reg_wr_ena), .A (nx6920), .B (nx6632)) ;
    DFFC reg_U_analog_control_sub_cnt_2 (.Q (U_analog_control_sub_cnt_2), .QB (
         nx6701), .D (nx2892), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_3 (.Q (U_analog_control_sub_cnt_3), .QB (
         nx6695), .D (nx2908), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix3145 (.OUT (nx3144), .A (nx6957), .B (nx6959), .C (nx6961), .D (
          nx6963)) ;
    Nand4 ix3129 (.OUT (nx3128), .A (nx6966), .B (nx6968), .C (nx6970), .D (
          nx6972)) ;
    Nand4 ix3115 (.OUT (nx3114), .A (nx6975), .B (nx6977), .C (nx6979), .D (
          nx6981)) ;
    Mux2 ix4820 (.OUT (nx4819), .A (U_command_control_TC4_data_out_13), .B (
         tc4_data_12), .SEL (nx9482)) ;
    DFFC U_command_control_TC4_reg_reg_data_13 (.Q (
         U_command_control_TC4_data_out_13), .QB (\$dummy [37]), .D (nx4809), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4810 (.OUT (nx4809), .A (U_command_control_TC4_data_out_14), .B (
         U_command_control_TC4_data_out_13), .SEL (nx9482)) ;
    DFFC U_command_control_TC4_reg_reg_data_14 (.Q (
         U_command_control_TC4_data_out_14), .QB (\$dummy [38]), .D (nx4799), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4800 (.OUT (nx4799), .A (U_command_control_TC4_data_out_15), .B (
         U_command_control_TC4_data_out_14), .SEL (nx9482)) ;
    DFFC U_command_control_TC4_reg_reg_data_15 (.Q (
         U_command_control_TC4_data_out_15), .QB (\$dummy [39]), .D (nx4789), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4790 (.OUT (nx4789), .A (tc4_data_16), .B (
         U_command_control_TC4_data_out_15), .SEL (nx9482)) ;
    DFFC U_command_control_TC4_reg_reg_data_16 (.Q (tc4_data_16), .QB (
         \$dummy [40]), .D (nx4779), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4780 (.OUT (nx4779), .A (tc4_data_17), .B (tc4_data_16), .SEL (nx9482
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_17 (.Q (tc4_data_17), .QB (
         \$dummy [41]), .D (nx4769), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4770 (.OUT (nx4769), .A (tc4_data_18), .B (tc4_data_17), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_18 (.Q (tc4_data_18), .QB (
         \$dummy [42]), .D (nx4759), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4760 (.OUT (nx4759), .A (tc4_data_19), .B (tc4_data_18), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_19 (.Q (tc4_data_19), .QB (
         \$dummy [43]), .D (nx4749), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4750 (.OUT (nx4749), .A (tc4_data_20), .B (tc4_data_19), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_20 (.Q (tc4_data_20), .QB (
         \$dummy [44]), .D (nx4739), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4740 (.OUT (nx4739), .A (tc4_data_21), .B (tc4_data_20), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_21 (.Q (tc4_data_21), .QB (
         \$dummy [45]), .D (nx4729), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4730 (.OUT (nx4729), .A (tc4_data_22), .B (tc4_data_21), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_22 (.Q (tc4_data_22), .QB (
         \$dummy [46]), .D (nx4719), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4720 (.OUT (nx4719), .A (tc4_data_23), .B (tc4_data_22), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_23 (.Q (tc4_data_23), .QB (
         \$dummy [47]), .D (nx4709), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4710 (.OUT (nx4709), .A (tc4_data_24), .B (tc4_data_23), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_24 (.Q (tc4_data_24), .QB (
         \$dummy [48]), .D (nx4699), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4700 (.OUT (nx4699), .A (tc4_data_25), .B (tc4_data_24), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_25 (.Q (tc4_data_25), .QB (
         \$dummy [49]), .D (nx4689), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4690 (.OUT (nx4689), .A (tc4_data_26), .B (tc4_data_25), .SEL (nx9480
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_26 (.Q (tc4_data_26), .QB (
         \$dummy [50]), .D (nx4679), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4680 (.OUT (nx4679), .A (tc4_data_27), .B (tc4_data_26), .SEL (nx9478
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_27 (.Q (tc4_data_27), .QB (
         \$dummy [51]), .D (nx4669), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4670 (.OUT (nx4669), .A (tc4_data_28), .B (tc4_data_27), .SEL (nx9478
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_28 (.Q (tc4_data_28), .QB (
         \$dummy [52]), .D (nx4659), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4660 (.OUT (nx4659), .A (tc4_data_29), .B (tc4_data_28), .SEL (nx9478
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_29 (.Q (tc4_data_29), .QB (
         \$dummy [53]), .D (nx4649), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4650 (.OUT (nx4649), .A (tc4_data_30), .B (tc4_data_29), .SEL (nx9478
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_30 (.Q (tc4_data_30), .QB (
         \$dummy [54]), .D (nx4639), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4640 (.OUT (nx4639), .A (tc4_data_31), .B (tc4_data_30), .SEL (nx9478
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_31 (.Q (tc4_data_31), .QB (
         \$dummy [55]), .D (nx4629), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4630 (.OUT (nx4629), .A (nx1254), .B (tc4_data_31), .SEL (nx9478)) ;
    Nand2 ix1255 (.OUT (nx1254), .A (nx7032), .B (nx6921)) ;
    Nand2 ix7033 (.OUT (nx7032), .A (tc4_data_0), .B (nx6916)) ;
    DFFC U_command_control_TC4_reg_reg_data_0 (.Q (tc4_data_0), .QB (
         \$dummy [56]), .D (nx4939), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4940 (.OUT (nx4939), .A (tc4_data_1), .B (tc4_data_0), .SEL (nx9478)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_1 (.Q (tc4_data_1), .QB (
         \$dummy [57]), .D (nx4929), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4930 (.OUT (nx4929), .A (tc4_data_2), .B (tc4_data_1), .SEL (nx9478)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_2 (.Q (tc4_data_2), .QB (
         \$dummy [58]), .D (nx4919), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4920 (.OUT (nx4919), .A (tc4_data_3), .B (tc4_data_2), .SEL (nx9478)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_3 (.Q (tc4_data_3), .QB (
         \$dummy [59]), .D (nx4909), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4910 (.OUT (nx4909), .A (tc4_data_4), .B (tc4_data_3), .SEL (nx9476)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_4 (.Q (tc4_data_4), .QB (
         \$dummy [60]), .D (nx4899), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4900 (.OUT (nx4899), .A (tc4_data_5), .B (tc4_data_4), .SEL (nx9476)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_5 (.Q (tc4_data_5), .QB (
         \$dummy [61]), .D (nx4889), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4890 (.OUT (nx4889), .A (tc4_data_6), .B (tc4_data_5), .SEL (nx9476)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_6 (.Q (tc4_data_6), .QB (
         \$dummy [62]), .D (nx4879), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4880 (.OUT (nx4879), .A (tc4_data_7), .B (tc4_data_6), .SEL (nx9476)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_7 (.Q (tc4_data_7), .QB (
         \$dummy [63]), .D (nx4869), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4870 (.OUT (nx4869), .A (tc4_data_8), .B (tc4_data_7), .SEL (nx9476)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_8 (.Q (tc4_data_8), .QB (
         \$dummy [64]), .D (nx4859), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4860 (.OUT (nx4859), .A (tc4_data_9), .B (tc4_data_8), .SEL (nx9476)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_9 (.Q (tc4_data_9), .QB (
         \$dummy [65]), .D (nx4849), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4850 (.OUT (nx4849), .A (tc4_data_10), .B (tc4_data_9), .SEL (nx9476)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_10 (.Q (tc4_data_10), .QB (
         \$dummy [66]), .D (nx4839), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4840 (.OUT (nx4839), .A (tc4_data_11), .B (tc4_data_10), .SEL (nx9476
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_11 (.Q (tc4_data_11), .QB (
         \$dummy [67]), .D (nx4829), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4830 (.OUT (nx4829), .A (tc4_data_12), .B (tc4_data_11), .SEL (nx9476
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_12 (.Q (tc4_data_12), .QB (
         \$dummy [68]), .D (nx4819), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor4 ix1249 (.OUT (nx1248), .A (nx6641), .B (nx6637), .C (nx632), .D (nx6903
         )) ;
    Nand4 ix7102 (.OUT (nx7101), .A (nx7103), .B (nx7105), .C (nx7107), .D (
          nx7109)) ;
    Nand3 ix2669 (.OUT (nx2668), .A (U_analog_control_mst_state_1), .B (nx6671)
          , .C (nx6624)) ;
    Nand3 ix3239 (.OUT (nx2885), .A (U_analog_control_mst_state_1), .B (
          U_analog_control_mst_state_2), .C (nx6624)) ;
    Nand2 ix7134 (.OUT (nx7133), .A (nx6720), .B (nx2844)) ;
    Nand3 ix2845 (.OUT (nx2844), .A (nx6725), .B (nx7136), .C (nx7138)) ;
    Nor3 ix7137 (.OUT (nx7136), .A (U_analog_control_sub_cnt_3), .B (nx6689), .C (
         U_analog_control_sub_cnt_2)) ;
    Nor4 ix7139 (.OUT (nx7138), .A (U_analog_control_sub_cnt_6), .B (
         U_analog_control_sub_cnt_7), .C (U_analog_control_sub_cnt_5), .D (
         nx2816)) ;
    AOI22 ix7141 (.OUT (nx7140), .A (nx7142), .B (nx6720), .C (nx6822), .D (
          nx6825)) ;
    AO22 ix3209 (.OUT (nx3208), .A (U_analog_control_int_cur_cell_2), .B (nx2850
         ), .C (U_analog_control_int_cur_cell_3), .D (nx3172)) ;
    DFFC U_analog_control_reg_int_cur_cell_2 (.Q (
         U_analog_control_int_cur_cell_2), .QB (\$dummy [69]), .D (nx3198), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3199 (.OUT (nx3198), .A (U_analog_control_int_cur_cell_1), .B (nx2850
         ), .C (U_analog_control_int_cur_cell_2), .D (nx3172)) ;
    DFFC U_analog_control_reg_int_cur_cell_1 (.Q (
         U_analog_control_int_cur_cell_1), .QB (\$dummy [70]), .D (nx3188), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3189 (.OUT (nx3188), .A (U_analog_control_int_cur_cell_0), .B (nx2850
         ), .C (U_analog_control_int_cur_cell_1), .D (nx3172)) ;
    DFFC U_analog_control_reg_int_cur_cell_0 (.Q (
         U_analog_control_int_cur_cell_0), .QB (\$dummy [71]), .D (nx3178), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3179 (.OUT (nx3178), .A (nx7151), .B (nx2668)) ;
    Nand2 ix7152 (.OUT (nx7151), .A (U_analog_control_int_cur_cell_0), .B (
          nx3172)) ;
    Nor2 ix2851 (.OUT (nx2850), .A (nx2885), .B (nx2844)) ;
    DFFC U_analog_control_reg_int_cur_cell_3 (.Q (
         U_analog_control_int_cur_cell_3), .QB (nx7142), .D (nx3208), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix7160 (.OUT (nx7159), .A (nx2756), .B (nx2792)) ;
    Nor4 ix2757 (.OUT (nx2756), .A (nx7162), .B (nx2740), .C (nx2742), .D (
         nx2744)) ;
    Nand4 ix7163 (.OUT (nx7162), .A (nx7164), .B (nx7166), .C (nx7168), .D (
          nx7170)) ;
    Nor4 ix2793 (.OUT (nx2792), .A (nx7101), .B (nx7111), .C (nx2780), .D (
         nx2782)) ;
    Nand3 ix3253 (.OUT (nx2827), .A (nx6716), .B (nx6671), .C (
          U_analog_control_mst_state_0)) ;
    Mux2 ix5880 (.OUT (nx5879), .A (U_command_control_cfg_data_3), .B (
         no_auto_rd), .SEL (nx9490)) ;
    DFFC U_command_control_CFG_reg_reg_data_3 (.Q (U_command_control_cfg_data_3)
         , .QB (nx7279), .D (nx5869), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5870 (.OUT (nx5869), .A (U_command_control_cfg_data_4), .B (
         U_command_control_cfg_data_3), .SEL (nx9490)) ;
    DFFC U_command_control_CFG_reg_reg_data_4 (.Q (U_command_control_cfg_data_4)
         , .QB (\$dummy [72]), .D (nx5859), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5860 (.OUT (nx5859), .A (U_command_control_cfg_data_5), .B (
         U_command_control_cfg_data_4), .SEL (nx9490)) ;
    DFFC U_command_control_CFG_reg_reg_data_5 (.Q (U_command_control_cfg_data_5)
         , .QB (nx7277), .D (nx5849), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5850 (.OUT (nx5849), .A (U_command_control_CFG_data_out_6), .B (
         U_command_control_cfg_data_5), .SEL (nx9490)) ;
    DFFC U_command_control_CFG_reg_reg_data_6 (.Q (
         U_command_control_CFG_data_out_6), .QB (\$dummy [73]), .D (nx5839), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5840 (.OUT (nx5839), .A (U_command_control_CFG_data_out_7), .B (
         U_command_control_CFG_data_out_6), .SEL (nx9490)) ;
    DFFC U_command_control_CFG_reg_reg_data_7 (.Q (
         U_command_control_CFG_data_out_7), .QB (\$dummy [74]), .D (nx5829), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5830 (.OUT (nx5829), .A (U_command_control_CFG_data_out_8), .B (
         U_command_control_CFG_data_out_7), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_8 (.Q (
         U_command_control_CFG_data_out_8), .QB (\$dummy [75]), .D (nx5819), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5820 (.OUT (nx5819), .A (U_command_control_CFG_data_out_9), .B (
         U_command_control_CFG_data_out_8), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_9 (.Q (
         U_command_control_CFG_data_out_9), .QB (\$dummy [76]), .D (nx5809), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5810 (.OUT (nx5809), .A (U_command_control_CFG_data_out_10), .B (
         U_command_control_CFG_data_out_9), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_10 (.Q (
         U_command_control_CFG_data_out_10), .QB (\$dummy [77]), .D (nx5799), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5800 (.OUT (nx5799), .A (U_command_control_CFG_data_out_11), .B (
         U_command_control_CFG_data_out_10), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_11 (.Q (
         U_command_control_CFG_data_out_11), .QB (\$dummy [78]), .D (nx5789), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5790 (.OUT (nx5789), .A (U_command_control_CFG_data_out_12), .B (
         U_command_control_CFG_data_out_11), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_12 (.Q (
         U_command_control_CFG_data_out_12), .QB (\$dummy [79]), .D (nx5779), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5780 (.OUT (nx5779), .A (U_command_control_CFG_data_out_13), .B (
         U_command_control_CFG_data_out_12), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_13 (.Q (
         U_command_control_CFG_data_out_13), .QB (\$dummy [80]), .D (nx5769), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5770 (.OUT (nx5769), .A (U_command_control_CFG_data_out_14), .B (
         U_command_control_CFG_data_out_13), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_14 (.Q (
         U_command_control_CFG_data_out_14), .QB (\$dummy [81]), .D (nx5759), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5760 (.OUT (nx5759), .A (U_command_control_CFG_data_out_15), .B (
         U_command_control_CFG_data_out_14), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_15 (.Q (
         U_command_control_CFG_data_out_15), .QB (\$dummy [82]), .D (nx5749), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5750 (.OUT (nx5749), .A (U_command_control_CFG_data_out_16), .B (
         U_command_control_CFG_data_out_15), .SEL (nx9488)) ;
    DFFC U_command_control_CFG_reg_reg_data_16 (.Q (
         U_command_control_CFG_data_out_16), .QB (\$dummy [83]), .D (nx5739), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5740 (.OUT (nx5739), .A (U_command_control_CFG_data_out_17), .B (
         U_command_control_CFG_data_out_16), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_17 (.Q (
         U_command_control_CFG_data_out_17), .QB (\$dummy [84]), .D (nx5729), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5730 (.OUT (nx5729), .A (U_command_control_CFG_data_out_18), .B (
         U_command_control_CFG_data_out_17), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_18 (.Q (
         U_command_control_CFG_data_out_18), .QB (\$dummy [85]), .D (nx5719), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5720 (.OUT (nx5719), .A (U_command_control_CFG_data_out_19), .B (
         U_command_control_CFG_data_out_18), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_19 (.Q (
         U_command_control_CFG_data_out_19), .QB (\$dummy [86]), .D (nx5709), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5710 (.OUT (nx5709), .A (U_command_control_CFG_data_out_20), .B (
         U_command_control_CFG_data_out_19), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_20 (.Q (
         U_command_control_CFG_data_out_20), .QB (\$dummy [87]), .D (nx5699), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5700 (.OUT (nx5699), .A (U_command_control_CFG_data_out_21), .B (
         U_command_control_CFG_data_out_20), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_21 (.Q (
         U_command_control_CFG_data_out_21), .QB (\$dummy [88]), .D (nx5689), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5690 (.OUT (nx5689), .A (U_command_control_CFG_data_out_22), .B (
         U_command_control_CFG_data_out_21), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_22 (.Q (
         U_command_control_CFG_data_out_22), .QB (\$dummy [89]), .D (nx5679), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5680 (.OUT (nx5679), .A (U_command_control_CFG_data_out_23), .B (
         U_command_control_CFG_data_out_22), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_23 (.Q (
         U_command_control_CFG_data_out_23), .QB (\$dummy [90]), .D (nx5669), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5670 (.OUT (nx5669), .A (U_command_control_CFG_data_out_24), .B (
         U_command_control_CFG_data_out_23), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_24 (.Q (
         U_command_control_CFG_data_out_24), .QB (\$dummy [91]), .D (nx5659), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5660 (.OUT (nx5659), .A (U_command_control_CFG_data_out_25), .B (
         U_command_control_CFG_data_out_24), .SEL (nx9486)) ;
    DFFC U_command_control_CFG_reg_reg_data_25 (.Q (
         U_command_control_CFG_data_out_25), .QB (\$dummy [92]), .D (nx5649), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5650 (.OUT (nx5649), .A (U_command_control_CFG_data_out_26), .B (
         U_command_control_CFG_data_out_25), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_26 (.Q (
         U_command_control_CFG_data_out_26), .QB (\$dummy [93]), .D (nx5639), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5640 (.OUT (nx5639), .A (U_command_control_CFG_data_out_27), .B (
         U_command_control_CFG_data_out_26), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_27 (.Q (
         U_command_control_CFG_data_out_27), .QB (\$dummy [94]), .D (nx5629), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5630 (.OUT (nx5629), .A (U_command_control_CFG_data_out_28), .B (
         U_command_control_CFG_data_out_27), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_28 (.Q (
         U_command_control_CFG_data_out_28), .QB (\$dummy [95]), .D (nx5619), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5620 (.OUT (nx5619), .A (U_command_control_CFG_data_out_29), .B (
         U_command_control_CFG_data_out_28), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_29 (.Q (
         U_command_control_CFG_data_out_29), .QB (\$dummy [96]), .D (nx5609), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5610 (.OUT (nx5609), .A (U_command_control_CFG_data_out_30), .B (
         U_command_control_CFG_data_out_29), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_30 (.Q (
         U_command_control_CFG_data_out_30), .QB (\$dummy [97]), .D (nx5599), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5600 (.OUT (nx5599), .A (U_command_control_CFG_data_out_31), .B (
         U_command_control_CFG_data_out_30), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_31 (.Q (
         U_command_control_CFG_data_out_31), .QB (\$dummy [98]), .D (nx5589), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5590 (.OUT (nx5589), .A (nx1696), .B (
         U_command_control_CFG_data_out_31), .SEL (nx9484)) ;
    Nand2 ix1697 (.OUT (nx1696), .A (nx7241), .B (nx6921)) ;
    Nand2 ix7242 (.OUT (nx7241), .A (test_mode), .B (nx6916)) ;
    DFFC U_command_control_CFG_reg_reg_data_0 (.Q (test_mode), .QB (nx7250), .D (
         nx5899), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5900 (.OUT (nx5899), .A (U_command_control_CFG_data_out_1), .B (
         test_mode), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_1 (.Q (
         U_command_control_CFG_data_out_1), .QB (\$dummy [99]), .D (nx5889), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5890 (.OUT (nx5889), .A (no_auto_rd), .B (
         U_command_control_CFG_data_out_1), .SEL (nx9484)) ;
    DFFC U_command_control_CFG_reg_reg_data_2 (.Q (no_auto_rd), .QB (nx7179), .D (
         nx5879), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor4 ix1691 (.OUT (nx1690), .A (nx6903), .B (nx470), .C (
         U_command_control_int_hdr_data_9), .D (
         U_command_control_int_hdr_data_10)) ;
    Mux2 ix5950 (.OUT (nx5949), .A (nx2851), .B (readout_cmd), .SEL (nx2038)) ;
    DFFC U_command_control_reg_readout_cmd (.Q (readout_cmd), .QB (nx7280), .D (
         nx5949), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix2039 (.OUT (nx2038), .A (nx7285), .B (nx2851)) ;
    Nand2 ix7286 (.OUT (nx7285), .A (U_command_control_int_hdr_data_9), .B (
          nx7287)) ;
    Nor2 ix7288 (.OUT (nx7287), .A (U_command_control_int_hdr_data_7), .B (
         U_command_control_int_hdr_data_8)) ;
    Nand2 ix5990 (.OUT (nx5989), .A (nx7294), .B (nx7301)) ;
    Nand2 ix7295 (.OUT (nx7294), .A (U_readout_control_typ_cnt_3), .B (nx7297)
          ) ;
    DFFC reg_U_readout_control_typ_cnt_3 (.Q (U_readout_control_typ_cnt_3), .QB (
         nx7291), .D (nx5989), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix7298 (.OUT (nx7297), .A (nx2140), .B (nx2076)) ;
    Nor2 ix2141 (.OUT (nx2140), .A (nx7291), .B (nx2068)) ;
    Nand2 ix2077 (.OUT (nx2076), .A (nx2853), .B (nx2070)) ;
    Nand4 ix7302 (.OUT (nx7301), .A (nx7297), .B (nx7291), .C (nx2861), .D (
          nx6506)) ;
    Nor3 ix2127 (.OUT (nx2861), .A (nx7304), .B (nx7312), .C (nx7333)) ;
    Mux2 ix5980 (.OUT (nx5979), .A (U_readout_control_typ_cnt_2), .B (nx2120), .SEL (
         nx7331)) ;
    DFFC reg_U_readout_control_typ_cnt_2 (.Q (U_readout_control_typ_cnt_2), .QB (
         nx7304), .D (nx5979), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2121 (.OUT (nx2120), .A (nx7309), .B (nx2859), .C (nx2861)) ;
    Nor2 ix7310 (.OUT (nx7309), .A (nx2860), .B (U_readout_control_typ_cnt_2)) ;
    Nor2 ix2111 (.OUT (nx2860), .A (nx7312), .B (nx7333)) ;
    Mux2 ix5970 (.OUT (nx5969), .A (U_readout_control_typ_cnt_1), .B (nx2104), .SEL (
         nx7331)) ;
    DFFC reg_U_readout_control_typ_cnt_1 (.Q (U_readout_control_typ_cnt_1), .QB (
         nx7312), .D (nx5969), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2105 (.OUT (nx2104), .A (nx7317), .B (nx2859), .C (nx2860)) ;
    Nor2 ix7318 (.OUT (nx7317), .A (U_readout_control_typ_cnt_0), .B (
         U_readout_control_typ_cnt_1)) ;
    DFFC reg_U_readout_control_typ_cnt_0 (.Q (U_readout_control_typ_cnt_0), .QB (
         nx7333), .D (nx5959), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5960 (.OUT (nx5959), .A (U_readout_control_typ_cnt_0), .B (nx2090), .SEL (
         nx7331)) ;
    Nor2 ix2091 (.OUT (nx2090), .A (U_readout_control_typ_cnt_0), .B (nx2859)) ;
    Nor2 ix7332 (.OUT (nx7331), .A (nx6506), .B (nx2076)) ;
    Mux2 ix6040 (.OUT (nx6039), .A (U_readout_control_row_cnt_4), .B (nx2206), .SEL (
         nx7297)) ;
    DFFC reg_U_readout_control_row_cnt_4 (.Q (U_readout_control_row_cnt_4), .QB (
         \$dummy [100]), .D (nx6039), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix2207 (.OUT (nx2206), .A (nx7339), .B (nx2076)) ;
    Xnor2 ix7340 (.out (nx7339), .A (U_readout_control_row_cnt_4), .B (nx2865)
          ) ;
    Nor2 ix2201 (.OUT (nx2865), .A (nx7342), .B (nx7369)) ;
    Mux2 ix6030 (.OUT (nx6029), .A (U_readout_control_row_cnt_3), .B (nx2194), .SEL (
         nx7297)) ;
    DFFC reg_U_readout_control_row_cnt_3 (.Q (U_readout_control_row_cnt_3), .QB (
         nx7342), .D (nx6029), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2195 (.OUT (nx2194), .A (nx7347), .B (nx2865), .C (nx2076)) ;
    Nor2 ix7348 (.OUT (nx7347), .A (nx2864), .B (U_readout_control_row_cnt_3)) ;
    Mux2 ix6020 (.OUT (nx6019), .A (U_readout_control_row_cnt_2), .B (nx2178), .SEL (
         nx7297)) ;
    DFFC reg_U_readout_control_row_cnt_2 (.Q (U_readout_control_row_cnt_2), .QB (
         \$dummy [101]), .D (nx6019), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2179 (.OUT (nx2178), .A (nx7355), .B (nx2864), .C (nx2076)) ;
    Nor2 ix7356 (.OUT (nx7355), .A (nx2863), .B (U_readout_control_row_cnt_2)) ;
    Nor2 ix2169 (.OUT (nx2863), .A (nx7358), .B (nx7368)) ;
    Mux2 ix6010 (.OUT (nx6009), .A (U_readout_control_row_cnt_1), .B (nx2162), .SEL (
         nx7297)) ;
    DFFC reg_U_readout_control_row_cnt_1 (.Q (U_readout_control_row_cnt_1), .QB (
         nx7358), .D (nx6009), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2163 (.OUT (nx2162), .A (nx7363), .B (nx2863), .C (nx2076)) ;
    Nor2 ix7364 (.OUT (nx7363), .A (U_readout_control_row_cnt_0), .B (
         U_readout_control_row_cnt_1)) ;
    DFFC reg_U_readout_control_row_cnt_0 (.Q (U_readout_control_row_cnt_0), .QB (
         nx7368), .D (nx5999), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6000 (.OUT (nx5999), .A (U_readout_control_row_cnt_0), .B (nx2148), .SEL (
         nx7297)) ;
    Nor2 ix2149 (.OUT (nx2148), .A (U_readout_control_row_cnt_0), .B (nx2076)) ;
    Nand3 ix7370 (.OUT (nx7369), .A (U_readout_control_row_cnt_2), .B (
          U_readout_control_row_cnt_1), .C (U_readout_control_row_cnt_0)) ;
    Nand3 ix7374 (.OUT (nx7373), .A (nx2482), .B (U_readout_control_col_cnt_4), 
          .C (nx2880)) ;
    Nand3 ix2479 (.OUT (nx2478), .A (U_readout_control_rd_state_1), .B (nx6508)
          , .C (nx6513)) ;
    DFFC reg_U_readout_control_col_cnt_4 (.Q (U_readout_control_col_cnt_4), .QB (
         \$dummy [102]), .D (nx6089), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6090 (.OUT (nx6089), .A (nx2552), .B (U_readout_control_col_cnt_4), .SEL (
         nx2488)) ;
    Nor2 ix2553 (.OUT (nx2552), .A (nx7380), .B (nx2486)) ;
    Xnor2 ix7381 (.out (nx7380), .A (U_readout_control_col_cnt_4), .B (nx2880)
          ) ;
    Nor2 ix2547 (.OUT (nx2880), .A (nx7383), .B (nx7418)) ;
    Mux2 ix6080 (.OUT (nx6079), .A (nx2540), .B (U_readout_control_col_cnt_3), .SEL (
         nx2488)) ;
    Nor3 ix2541 (.OUT (nx2540), .A (nx7387), .B (nx2880), .C (nx2486)) ;
    Nor2 ix7388 (.OUT (nx7387), .A (nx2879), .B (U_readout_control_col_cnt_3)) ;
    Mux2 ix6070 (.OUT (nx6069), .A (nx2524), .B (U_readout_control_col_cnt_2), .SEL (
         nx2488)) ;
    Nor3 ix2525 (.OUT (nx2524), .A (nx7394), .B (nx2879), .C (nx2486)) ;
    Nor2 ix7395 (.OUT (nx7394), .A (nx2878), .B (U_readout_control_col_cnt_2)) ;
    Nor2 ix2515 (.OUT (nx2878), .A (nx7397), .B (nx7414)) ;
    Mux2 ix6060 (.OUT (nx6059), .A (nx2508), .B (U_readout_control_col_cnt_1), .SEL (
         nx2488)) ;
    Nor3 ix2509 (.OUT (nx2508), .A (nx7401), .B (nx2878), .C (nx2486)) ;
    Nor2 ix7402 (.OUT (nx7401), .A (U_readout_control_col_cnt_0), .B (
         U_readout_control_col_cnt_1)) ;
    DFFC reg_U_readout_control_col_cnt_0 (.Q (U_readout_control_col_cnt_0), .QB (
         nx7414), .D (nx6049), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6050 (.OUT (nx6049), .A (nx2494), .B (U_readout_control_col_cnt_0), .SEL (
         nx2488)) ;
    Nor2 ix2495 (.OUT (nx2494), .A (U_readout_control_col_cnt_0), .B (nx2486)) ;
    Nand2 ix2489 (.OUT (nx2488), .A (nx7408), .B (nx7412)) ;
    Nand2 ix7409 (.OUT (nx7408), .A (nx7410), .B (nx2390)) ;
    Nor2 ix7413 (.OUT (nx7412), .A (nx2076), .B (nx6506)) ;
    DFFC reg_U_readout_control_col_cnt_1 (.Q (U_readout_control_col_cnt_1), .QB (
         nx7397), .D (nx6059), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_col_cnt_2 (.Q (U_readout_control_col_cnt_2), .QB (
         \$dummy [103]), .D (nx6069), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_col_cnt_3 (.Q (U_readout_control_col_cnt_3), .QB (
         nx7383), .D (nx6079), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix7419 (.OUT (nx7418), .A (U_readout_control_col_cnt_2), .B (
          U_readout_control_col_cnt_1), .C (U_readout_control_col_cnt_0)) ;
    Nand2 ix7422 (.OUT (nx7421), .A (nx7327), .B (nx2875)) ;
    Nand2 ix2477 (.OUT (nx2877), .A (U_readout_control_rd_state_1), .B (nx6508)
          ) ;
    AOI22 ix7428 (.OUT (nx7427), .A (nx7327), .B (nx2875), .C (nx6506), .D (
          nx7289)) ;
    Nand2 ix1961 (.OUT (nx1960), .A (nx7461), .B (nx7484)) ;
    AOI22 ix7462 (.OUT (nx7461), .A (temp_en), .B (nx7473), .C (
          U_command_control_data_perr), .D (nx90)) ;
    DFFC U_command_control_reg_int_temp_en (.Q (temp_en), .QB (\$dummy [104]), .D (
         nx5939), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5940 (.OUT (nx5939), .A (nx1942), .B (temp_en), .SEL (nx1948)) ;
    Nor2 ix1943 (.OUT (nx1942), .A (U_command_control_cfg_data_4), .B (nx7466)
         ) ;
    Nor4 ix7467 (.OUT (nx7466), .A (nx7456), .B (nx7468), .C (
         U_command_control_cfg_data_3), .D (start_sequence)) ;
    Nand3 ix1949 (.OUT (nx1948), .A (nx7279), .B (nx6664), .C (nx1942)) ;
    Nor2 ix7474 (.OUT (nx7473), .A (U_command_control_cmd_cnt_0), .B (nx6391)) ;
    Nand2 ix5920 (.OUT (nx5919), .A (nx7477), .B (nx7479)) ;
    DFFC U_command_control_reg_data_perr (.Q (U_command_control_data_perr), .QB (
         nx7477), .D (nx5919), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix7480 (.OUT (nx7479), .A (nx6443), .B (nx42), .C (nx2847), .D (nx114)
          ) ;
    DFFC U_command_control_reg_int_par (.Q (U_command_control_int_par), .QB (
         nx7482), .D (nx2006), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix7485 (.OUT (nx7484), .A (U_command_control_head_perr), .B (nx6463)
          ) ;
    Nand2 ix5910 (.OUT (nx5909), .A (nx7488), .B (nx7490)) ;
    DFFC U_command_control_reg_head_perr (.Q (U_command_control_head_perr), .QB (
         nx7488), .D (nx5909), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix7491 (.OUT (nx7490), .A (nx2847), .B (nx82)) ;
    Nand2 ix1859 (.OUT (nx1858), .A (nx7496), .B (nx7498)) ;
    AOI22 ix7497 (.OUT (nx7496), .A (temp_id0), .B (nx6463), .C (temp_id2), .D (
          nx7473)) ;
    AOI22 ix7499 (.OUT (nx7498), .A (temp_id1), .B (nx90), .C (temp_id3), .D (
          nx2831)) ;
    Nand2 ix1883 (.OUT (nx1882), .A (nx7502), .B (nx7504)) ;
    AOI22 ix7503 (.OUT (nx7502), .A (temp_id4), .B (nx6463), .C (temp_id6), .D (
          nx7473)) ;
    AOI22 ix7505 (.OUT (nx7504), .A (temp_id5), .B (nx90), .C (temp_id7), .D (
          nx2831)) ;
    Nor3 ix1683 (.OUT (nx1682), .A (nx7510), .B (nx6641), .C (nx7507)) ;
    Mux2 ix5260 (.OUT (nx5259), .A (tc1_data_0), .B (tc1_data_1), .SEL (nx9522)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_0 (.Q (tc1_data_0), .QB (nx7512), .D (
         nx5259), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_TC1_reg_reg_data_1 (.Q (tc1_data_1), .QB (
         \$dummy [105]), .D (nx5249), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5250 (.OUT (nx5249), .A (tc1_data_1), .B (tc1_data_2), .SEL (nx9522)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_2 (.Q (tc1_data_2), .QB (
         \$dummy [106]), .D (nx5239), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5240 (.OUT (nx5239), .A (tc1_data_2), .B (tc1_data_3), .SEL (nx9522)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_3 (.Q (tc1_data_3), .QB (
         \$dummy [107]), .D (nx5229), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5230 (.OUT (nx5229), .A (tc1_data_3), .B (tc1_data_4), .SEL (nx9522)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_4 (.Q (tc1_data_4), .QB (
         \$dummy [108]), .D (nx5219), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5220 (.OUT (nx5219), .A (tc1_data_4), .B (tc1_data_5), .SEL (nx9522)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_5 (.Q (tc1_data_5), .QB (
         \$dummy [109]), .D (nx5209), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5210 (.OUT (nx5209), .A (tc1_data_5), .B (tc1_data_6), .SEL (nx9520)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_6 (.Q (tc1_data_6), .QB (
         \$dummy [110]), .D (nx5199), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5200 (.OUT (nx5199), .A (tc1_data_6), .B (tc1_data_7), .SEL (nx9520)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_7 (.Q (tc1_data_7), .QB (
         \$dummy [111]), .D (nx5189), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5190 (.OUT (nx5189), .A (tc1_data_7), .B (tc1_data_8), .SEL (nx9520)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_8 (.Q (tc1_data_8), .QB (
         \$dummy [112]), .D (nx5179), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5180 (.OUT (nx5179), .A (tc1_data_8), .B (tc1_data_9), .SEL (nx9520)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_9 (.Q (tc1_data_9), .QB (
         \$dummy [113]), .D (nx5169), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5170 (.OUT (nx5169), .A (tc1_data_9), .B (tc1_data_10), .SEL (nx9520)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_10 (.Q (tc1_data_10), .QB (
         \$dummy [114]), .D (nx5159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5160 (.OUT (nx5159), .A (tc1_data_10), .B (tc1_data_11), .SEL (nx9520
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_11 (.Q (tc1_data_11), .QB (
         \$dummy [115]), .D (nx5149), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5150 (.OUT (nx5149), .A (tc1_data_11), .B (tc1_data_12), .SEL (nx9520
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_12 (.Q (tc1_data_12), .QB (
         \$dummy [116]), .D (nx5139), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5140 (.OUT (nx5139), .A (tc1_data_12), .B (tc1_data_13), .SEL (nx9520
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_13 (.Q (tc1_data_13), .QB (
         \$dummy [117]), .D (nx5129), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5130 (.OUT (nx5129), .A (tc1_data_13), .B (tc1_data_14), .SEL (nx9520
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_14 (.Q (tc1_data_14), .QB (
         \$dummy [118]), .D (nx5119), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5120 (.OUT (nx5119), .A (tc1_data_14), .B (tc1_data_15), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_15 (.Q (tc1_data_15), .QB (
         \$dummy [119]), .D (nx5109), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5110 (.OUT (nx5109), .A (tc1_data_15), .B (tc1_data_16), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_16 (.Q (tc1_data_16), .QB (
         \$dummy [120]), .D (nx5099), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5100 (.OUT (nx5099), .A (tc1_data_16), .B (tc1_data_17), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_17 (.Q (tc1_data_17), .QB (
         \$dummy [121]), .D (nx5089), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5090 (.OUT (nx5089), .A (tc1_data_17), .B (tc1_data_18), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_18 (.Q (tc1_data_18), .QB (
         \$dummy [122]), .D (nx5079), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5080 (.OUT (nx5079), .A (tc1_data_18), .B (tc1_data_19), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_19 (.Q (tc1_data_19), .QB (
         \$dummy [123]), .D (nx5069), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5070 (.OUT (nx5069), .A (tc1_data_19), .B (tc1_data_20), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_20 (.Q (tc1_data_20), .QB (
         \$dummy [124]), .D (nx5059), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5060 (.OUT (nx5059), .A (tc1_data_20), .B (tc1_data_21), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_21 (.Q (tc1_data_21), .QB (
         \$dummy [125]), .D (nx5049), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5050 (.OUT (nx5049), .A (tc1_data_21), .B (tc1_data_22), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_22 (.Q (tc1_data_22), .QB (
         \$dummy [126]), .D (nx5039), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5040 (.OUT (nx5039), .A (tc1_data_22), .B (tc1_data_23), .SEL (nx9518
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_23 (.Q (tc1_data_23), .QB (
         \$dummy [127]), .D (nx5029), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5030 (.OUT (nx5029), .A (tc1_data_23), .B (tc1_data_24), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_24 (.Q (tc1_data_24), .QB (
         \$dummy [128]), .D (nx5019), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5020 (.OUT (nx5019), .A (tc1_data_24), .B (tc1_data_25), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_25 (.Q (tc1_data_25), .QB (
         \$dummy [129]), .D (nx5009), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5010 (.OUT (nx5009), .A (tc1_data_25), .B (tc1_data_26), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_26 (.Q (tc1_data_26), .QB (
         \$dummy [130]), .D (nx4999), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5000 (.OUT (nx4999), .A (tc1_data_26), .B (tc1_data_27), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_27 (.Q (tc1_data_27), .QB (
         \$dummy [131]), .D (nx4989), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4990 (.OUT (nx4989), .A (tc1_data_27), .B (tc1_data_28), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_28 (.Q (tc1_data_28), .QB (
         \$dummy [132]), .D (nx4979), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4980 (.OUT (nx4979), .A (tc1_data_28), .B (tc1_data_29), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_29 (.Q (tc1_data_29), .QB (
         \$dummy [133]), .D (nx4969), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4970 (.OUT (nx4969), .A (tc1_data_29), .B (tc1_data_30), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_30 (.Q (tc1_data_30), .QB (
         \$dummy [134]), .D (nx4959), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4960 (.OUT (nx4959), .A (tc1_data_30), .B (tc1_data_31), .SEL (nx9516
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_31 (.Q (tc1_data_31), .QB (
         \$dummy [135]), .D (nx4949), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4950 (.OUT (nx4949), .A (tc1_data_31), .B (nx1404), .SEL (nx9516)) ;
    Nand2 ix1405 (.OUT (nx1404), .A (nx7579), .B (nx6921)) ;
    Nand2 ix7580 (.OUT (nx7579), .A (tc1_data_0), .B (nx6916)) ;
    Nand2 ix7582 (.OUT (nx7581), .A (nx7583), .B (nx828)) ;
    Nor2 ix7584 (.OUT (nx7583), .A (nx6902), .B (
         U_command_control_int_hdr_data_8)) ;
    Nor3 ix829 (.OUT (nx828), .A (nx6903), .B (nx6641), .C (
         U_command_control_int_hdr_data_9)) ;
    Mux2 ix5580 (.OUT (nx5579), .A (tc0_data_0), .B (tc0_data_1), .SEL (nx9530)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_0 (.Q (tc0_data_0), .QB (nx7617), .D (
         nx5579), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_TC0_reg_reg_data_1 (.Q (tc0_data_1), .QB (
         \$dummy [136]), .D (nx5569), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5570 (.OUT (nx5569), .A (tc0_data_1), .B (tc0_data_2), .SEL (nx9530)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_2 (.Q (tc0_data_2), .QB (
         \$dummy [137]), .D (nx5559), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5560 (.OUT (nx5559), .A (tc0_data_2), .B (tc0_data_3), .SEL (nx9530)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_3 (.Q (tc0_data_3), .QB (
         \$dummy [138]), .D (nx5549), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5550 (.OUT (nx5549), .A (tc0_data_3), .B (tc0_data_4), .SEL (nx9530)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_4 (.Q (tc0_data_4), .QB (
         \$dummy [139]), .D (nx5539), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5540 (.OUT (nx5539), .A (tc0_data_4), .B (tc0_data_5), .SEL (nx9530)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_5 (.Q (tc0_data_5), .QB (
         \$dummy [140]), .D (nx5529), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5530 (.OUT (nx5529), .A (tc0_data_5), .B (tc0_data_6), .SEL (nx9528)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_6 (.Q (tc0_data_6), .QB (
         \$dummy [141]), .D (nx5519), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5520 (.OUT (nx5519), .A (tc0_data_6), .B (tc0_data_7), .SEL (nx9528)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_7 (.Q (tc0_data_7), .QB (
         \$dummy [142]), .D (nx5509), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5510 (.OUT (nx5509), .A (tc0_data_7), .B (tc0_data_8), .SEL (nx9528)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_8 (.Q (tc0_data_8), .QB (
         \$dummy [143]), .D (nx5499), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5500 (.OUT (nx5499), .A (tc0_data_8), .B (tc0_data_9), .SEL (nx9528)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_9 (.Q (tc0_data_9), .QB (
         \$dummy [144]), .D (nx5489), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5490 (.OUT (nx5489), .A (tc0_data_9), .B (tc0_data_10), .SEL (nx9528)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_10 (.Q (tc0_data_10), .QB (
         \$dummy [145]), .D (nx5479), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5480 (.OUT (nx5479), .A (tc0_data_10), .B (tc0_data_11), .SEL (nx9528
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_11 (.Q (tc0_data_11), .QB (
         \$dummy [146]), .D (nx5469), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5470 (.OUT (nx5469), .A (tc0_data_11), .B (tc0_data_12), .SEL (nx9528
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_12 (.Q (tc0_data_12), .QB (
         \$dummy [147]), .D (nx5459), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5460 (.OUT (nx5459), .A (tc0_data_12), .B (tc0_data_13), .SEL (nx9528
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_13 (.Q (tc0_data_13), .QB (
         \$dummy [148]), .D (nx5449), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5450 (.OUT (nx5449), .A (tc0_data_13), .B (tc0_data_14), .SEL (nx9528
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_14 (.Q (tc0_data_14), .QB (
         \$dummy [149]), .D (nx5439), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5440 (.OUT (nx5439), .A (tc0_data_14), .B (tc0_data_15), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_15 (.Q (tc0_data_15), .QB (
         \$dummy [150]), .D (nx5429), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5430 (.OUT (nx5429), .A (tc0_data_15), .B (tc0_data_16), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_16 (.Q (tc0_data_16), .QB (
         \$dummy [151]), .D (nx5419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5420 (.OUT (nx5419), .A (tc0_data_16), .B (tc0_data_17), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_17 (.Q (tc0_data_17), .QB (
         \$dummy [152]), .D (nx5409), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5410 (.OUT (nx5409), .A (tc0_data_17), .B (tc0_data_18), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_18 (.Q (tc0_data_18), .QB (
         \$dummy [153]), .D (nx5399), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5400 (.OUT (nx5399), .A (tc0_data_18), .B (tc0_data_19), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_19 (.Q (tc0_data_19), .QB (
         \$dummy [154]), .D (nx5389), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5390 (.OUT (nx5389), .A (tc0_data_19), .B (tc0_data_20), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_20 (.Q (tc0_data_20), .QB (
         \$dummy [155]), .D (nx5379), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5380 (.OUT (nx5379), .A (tc0_data_20), .B (tc0_data_21), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_21 (.Q (tc0_data_21), .QB (
         \$dummy [156]), .D (nx5369), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5370 (.OUT (nx5369), .A (tc0_data_21), .B (tc0_data_22), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_22 (.Q (tc0_data_22), .QB (
         \$dummy [157]), .D (nx5359), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5360 (.OUT (nx5359), .A (tc0_data_22), .B (tc0_data_23), .SEL (nx9526
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_23 (.Q (tc0_data_23), .QB (
         \$dummy [158]), .D (nx5349), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5350 (.OUT (nx5349), .A (tc0_data_23), .B (tc0_data_24), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_24 (.Q (tc0_data_24), .QB (
         \$dummy [159]), .D (nx5339), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5340 (.OUT (nx5339), .A (tc0_data_24), .B (tc0_data_25), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_25 (.Q (tc0_data_25), .QB (
         \$dummy [160]), .D (nx5329), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5330 (.OUT (nx5329), .A (tc0_data_25), .B (tc0_data_26), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_26 (.Q (tc0_data_26), .QB (
         \$dummy [161]), .D (nx5319), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5320 (.OUT (nx5319), .A (tc0_data_26), .B (tc0_data_27), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_27 (.Q (tc0_data_27), .QB (
         \$dummy [162]), .D (nx5309), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5310 (.OUT (nx5309), .A (tc0_data_27), .B (tc0_data_28), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_28 (.Q (tc0_data_28), .QB (
         \$dummy [163]), .D (nx5299), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5300 (.OUT (nx5299), .A (tc0_data_28), .B (tc0_data_29), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_29 (.Q (tc0_data_29), .QB (
         \$dummy [164]), .D (nx5289), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5290 (.OUT (nx5289), .A (tc0_data_29), .B (tc0_data_30), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_30 (.Q (tc0_data_30), .QB (
         \$dummy [165]), .D (nx5279), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5280 (.OUT (nx5279), .A (tc0_data_30), .B (tc0_data_31), .SEL (nx9524
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_31 (.Q (tc0_data_31), .QB (
         \$dummy [166]), .D (nx5269), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5270 (.OUT (nx5269), .A (tc0_data_31), .B (nx1544), .SEL (nx9524)) ;
    Nand2 ix1545 (.OUT (nx1544), .A (nx7684), .B (nx6921)) ;
    Nand2 ix7685 (.OUT (nx7684), .A (tc0_data_0), .B (nx6916)) ;
    Nand2 ix7687 (.OUT (nx7686), .A (nx7287), .B (nx828)) ;
    Nor2 ix1395 (.OUT (nx1394), .A (nx7450), .B (nx7720)) ;
    AOI22 ix7721 (.OUT (nx7720), .A (nx2848), .B (nx1388), .C (nx1114), .D (
          nx1116)) ;
    Nor2 ix2641 (.OUT (nx2848), .A (nx6641), .B (nx6637)) ;
    AO22 ix1389 (.OUT (nx1388), .A (tc4_data_0), .B (nx7287), .C (tc5_data_0), .D (
         nx7583)) ;
    DFFC U_command_control_TC3_reg_reg_data_0 (.Q (tc3_data_0), .QB (
         \$dummy [167]), .D (nx3999), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4000 (.OUT (nx3999), .A (tc3_data_0), .B (tc3_data_1), .SEL (nx9538)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_1 (.Q (tc3_data_1), .QB (
         \$dummy [168]), .D (nx3989), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3990 (.OUT (nx3989), .A (tc3_data_1), .B (tc3_data_2), .SEL (nx9538)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_2 (.Q (tc3_data_2), .QB (
         \$dummy [169]), .D (nx3979), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3980 (.OUT (nx3979), .A (tc3_data_2), .B (tc3_data_3), .SEL (nx9538)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_3 (.Q (tc3_data_3), .QB (
         \$dummy [170]), .D (nx3969), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3970 (.OUT (nx3969), .A (tc3_data_3), .B (tc3_data_4), .SEL (nx9538)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_4 (.Q (tc3_data_4), .QB (
         \$dummy [171]), .D (nx3959), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3960 (.OUT (nx3959), .A (tc3_data_4), .B (tc3_data_5), .SEL (nx9538)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_5 (.Q (tc3_data_5), .QB (
         \$dummy [172]), .D (nx3949), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3950 (.OUT (nx3949), .A (tc3_data_5), .B (tc3_data_6), .SEL (nx9536)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_6 (.Q (tc3_data_6), .QB (
         \$dummy [173]), .D (nx3939), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3940 (.OUT (nx3939), .A (tc3_data_6), .B (tc3_data_7), .SEL (nx9536)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_7 (.Q (tc3_data_7), .QB (
         \$dummy [174]), .D (nx3929), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3930 (.OUT (nx3929), .A (tc3_data_7), .B (tc3_data_8), .SEL (nx9536)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_8 (.Q (tc3_data_8), .QB (
         \$dummy [175]), .D (nx3919), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3920 (.OUT (nx3919), .A (tc3_data_8), .B (tc3_data_9), .SEL (nx9536)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_9 (.Q (tc3_data_9), .QB (
         \$dummy [176]), .D (nx3909), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3910 (.OUT (nx3909), .A (tc3_data_9), .B (tc3_data_10), .SEL (nx9536)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_10 (.Q (tc3_data_10), .QB (
         \$dummy [177]), .D (nx3899), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3900 (.OUT (nx3899), .A (tc3_data_10), .B (tc3_data_11), .SEL (nx9536
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_11 (.Q (tc3_data_11), .QB (
         \$dummy [178]), .D (nx3889), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3890 (.OUT (nx3889), .A (tc3_data_11), .B (tc3_data_12), .SEL (nx9536
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_12 (.Q (tc3_data_12), .QB (
         \$dummy [179]), .D (nx3879), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3880 (.OUT (nx3879), .A (tc3_data_12), .B (tc3_data_13), .SEL (nx9536
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_13 (.Q (tc3_data_13), .QB (
         \$dummy [180]), .D (nx3869), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3870 (.OUT (nx3869), .A (tc3_data_13), .B (tc3_data_14), .SEL (nx9536
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_14 (.Q (tc3_data_14), .QB (
         \$dummy [181]), .D (nx3859), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3860 (.OUT (nx3859), .A (tc3_data_14), .B (tc3_data_15), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_15 (.Q (tc3_data_15), .QB (
         \$dummy [182]), .D (nx3849), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3850 (.OUT (nx3849), .A (tc3_data_15), .B (tc3_data_16), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_16 (.Q (tc3_data_16), .QB (
         \$dummy [183]), .D (nx3839), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3840 (.OUT (nx3839), .A (tc3_data_16), .B (tc3_data_17), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_17 (.Q (tc3_data_17), .QB (
         \$dummy [184]), .D (nx3829), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3830 (.OUT (nx3829), .A (tc3_data_17), .B (tc3_data_18), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_18 (.Q (tc3_data_18), .QB (
         \$dummy [185]), .D (nx3819), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3820 (.OUT (nx3819), .A (tc3_data_18), .B (tc3_data_19), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_19 (.Q (tc3_data_19), .QB (
         \$dummy [186]), .D (nx3809), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3810 (.OUT (nx3809), .A (tc3_data_19), .B (tc3_data_20), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_20 (.Q (tc3_data_20), .QB (
         \$dummy [187]), .D (nx3799), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3800 (.OUT (nx3799), .A (tc3_data_20), .B (tc3_data_21), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_21 (.Q (tc3_data_21), .QB (
         \$dummy [188]), .D (nx3789), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3790 (.OUT (nx3789), .A (tc3_data_21), .B (tc3_data_22), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_22 (.Q (tc3_data_22), .QB (
         \$dummy [189]), .D (nx3779), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3780 (.OUT (nx3779), .A (tc3_data_22), .B (tc3_data_23), .SEL (nx9534
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_23 (.Q (tc3_data_23), .QB (
         \$dummy [190]), .D (nx3769), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3770 (.OUT (nx3769), .A (tc3_data_23), .B (tc3_data_24), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_24 (.Q (tc3_data_24), .QB (
         \$dummy [191]), .D (nx3759), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3760 (.OUT (nx3759), .A (tc3_data_24), .B (tc3_data_25), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_25 (.Q (tc3_data_25), .QB (
         \$dummy [192]), .D (nx3749), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3750 (.OUT (nx3749), .A (tc3_data_25), .B (tc3_data_26), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_26 (.Q (tc3_data_26), .QB (
         \$dummy [193]), .D (nx3739), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3740 (.OUT (nx3739), .A (tc3_data_26), .B (tc3_data_27), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_27 (.Q (tc3_data_27), .QB (
         \$dummy [194]), .D (nx3729), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3730 (.OUT (nx3729), .A (tc3_data_27), .B (tc3_data_28), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_28 (.Q (tc3_data_28), .QB (
         \$dummy [195]), .D (nx3719), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3720 (.OUT (nx3719), .A (tc3_data_28), .B (tc3_data_29), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_29 (.Q (tc3_data_29), .QB (
         \$dummy [196]), .D (nx3709), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3710 (.OUT (nx3709), .A (tc3_data_29), .B (tc3_data_30), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_30 (.Q (tc3_data_30), .QB (
         \$dummy [197]), .D (nx3699), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3700 (.OUT (nx3699), .A (tc3_data_30), .B (tc3_data_31), .SEL (nx9532
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_31 (.Q (tc3_data_31), .QB (
         \$dummy [198]), .D (nx3689), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3690 (.OUT (nx3689), .A (tc3_data_31), .B (nx838), .SEL (nx9532)) ;
    Nand2 ix839 (.OUT (nx838), .A (nx7790), .B (nx6921)) ;
    Nand2 ix7791 (.OUT (nx7790), .A (tc3_data_0), .B (nx6916)) ;
    Nand3 ix7793 (.OUT (nx7792), .A (nx828), .B (
          U_command_control_int_hdr_data_8), .C (
          U_command_control_int_hdr_data_7)) ;
    DFFC U_command_control_TC2_reg_reg_data_0 (.Q (tc2_data_0), .QB (
         \$dummy [199]), .D (nx4319), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4320 (.OUT (nx4319), .A (tc2_data_0), .B (tc2_data_1), .SEL (nx9546)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_1 (.Q (tc2_data_1), .QB (
         \$dummy [200]), .D (nx4309), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4310 (.OUT (nx4309), .A (tc2_data_1), .B (tc2_data_2), .SEL (nx9546)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_2 (.Q (tc2_data_2), .QB (
         \$dummy [201]), .D (nx4299), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4300 (.OUT (nx4299), .A (tc2_data_2), .B (tc2_data_3), .SEL (nx9546)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_3 (.Q (tc2_data_3), .QB (
         \$dummy [202]), .D (nx4289), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4290 (.OUT (nx4289), .A (tc2_data_3), .B (tc2_data_4), .SEL (nx9546)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_4 (.Q (tc2_data_4), .QB (
         \$dummy [203]), .D (nx4279), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4280 (.OUT (nx4279), .A (tc2_data_4), .B (tc2_data_5), .SEL (nx9546)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_5 (.Q (tc2_data_5), .QB (
         \$dummy [204]), .D (nx4269), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4270 (.OUT (nx4269), .A (tc2_data_5), .B (tc2_data_6), .SEL (nx9544)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_6 (.Q (tc2_data_6), .QB (
         \$dummy [205]), .D (nx4259), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4260 (.OUT (nx4259), .A (tc2_data_6), .B (tc2_data_7), .SEL (nx9544)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_7 (.Q (tc2_data_7), .QB (
         \$dummy [206]), .D (nx4249), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4250 (.OUT (nx4249), .A (tc2_data_7), .B (tc2_data_8), .SEL (nx9544)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_8 (.Q (tc2_data_8), .QB (
         \$dummy [207]), .D (nx4239), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4240 (.OUT (nx4239), .A (tc2_data_8), .B (tc2_data_9), .SEL (nx9544)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_9 (.Q (tc2_data_9), .QB (
         \$dummy [208]), .D (nx4229), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4230 (.OUT (nx4229), .A (tc2_data_9), .B (tc2_data_10), .SEL (nx9544)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_10 (.Q (tc2_data_10), .QB (
         \$dummy [209]), .D (nx4219), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4220 (.OUT (nx4219), .A (tc2_data_10), .B (tc2_data_11), .SEL (nx9544
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_11 (.Q (tc2_data_11), .QB (
         \$dummy [210]), .D (nx4209), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4210 (.OUT (nx4209), .A (tc2_data_11), .B (tc2_data_12), .SEL (nx9544
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_12 (.Q (tc2_data_12), .QB (
         \$dummy [211]), .D (nx4199), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4200 (.OUT (nx4199), .A (tc2_data_12), .B (tc2_data_13), .SEL (nx9544
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_13 (.Q (tc2_data_13), .QB (
         \$dummy [212]), .D (nx4189), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4190 (.OUT (nx4189), .A (tc2_data_13), .B (tc2_data_14), .SEL (nx9544
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_14 (.Q (tc2_data_14), .QB (
         \$dummy [213]), .D (nx4179), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4180 (.OUT (nx4179), .A (tc2_data_14), .B (tc2_data_15), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_15 (.Q (tc2_data_15), .QB (
         \$dummy [214]), .D (nx4169), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4170 (.OUT (nx4169), .A (tc2_data_15), .B (tc2_data_16), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_16 (.Q (tc2_data_16), .QB (
         \$dummy [215]), .D (nx4159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4160 (.OUT (nx4159), .A (tc2_data_16), .B (tc2_data_17), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_17 (.Q (tc2_data_17), .QB (
         \$dummy [216]), .D (nx4149), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4150 (.OUT (nx4149), .A (tc2_data_17), .B (tc2_data_18), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_18 (.Q (tc2_data_18), .QB (
         \$dummy [217]), .D (nx4139), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4140 (.OUT (nx4139), .A (tc2_data_18), .B (tc2_data_19), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_19 (.Q (tc2_data_19), .QB (
         \$dummy [218]), .D (nx4129), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4130 (.OUT (nx4129), .A (tc2_data_19), .B (tc2_data_20), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_20 (.Q (tc2_data_20), .QB (
         \$dummy [219]), .D (nx4119), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4120 (.OUT (nx4119), .A (tc2_data_20), .B (tc2_data_21), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_21 (.Q (tc2_data_21), .QB (
         \$dummy [220]), .D (nx4109), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4110 (.OUT (nx4109), .A (tc2_data_21), .B (tc2_data_22), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_22 (.Q (tc2_data_22), .QB (
         \$dummy [221]), .D (nx4099), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4100 (.OUT (nx4099), .A (tc2_data_22), .B (tc2_data_23), .SEL (nx9542
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_23 (.Q (tc2_data_23), .QB (
         \$dummy [222]), .D (nx4089), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4090 (.OUT (nx4089), .A (tc2_data_23), .B (tc2_data_24), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_24 (.Q (tc2_data_24), .QB (
         \$dummy [223]), .D (nx4079), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4080 (.OUT (nx4079), .A (tc2_data_24), .B (tc2_data_25), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_25 (.Q (tc2_data_25), .QB (
         \$dummy [224]), .D (nx4069), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4070 (.OUT (nx4069), .A (tc2_data_25), .B (tc2_data_26), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_26 (.Q (tc2_data_26), .QB (
         \$dummy [225]), .D (nx4059), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4060 (.OUT (nx4059), .A (tc2_data_26), .B (tc2_data_27), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_27 (.Q (tc2_data_27), .QB (
         \$dummy [226]), .D (nx4049), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4050 (.OUT (nx4049), .A (tc2_data_27), .B (tc2_data_28), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_28 (.Q (tc2_data_28), .QB (
         \$dummy [227]), .D (nx4039), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4040 (.OUT (nx4039), .A (tc2_data_28), .B (tc2_data_29), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_29 (.Q (tc2_data_29), .QB (
         \$dummy [228]), .D (nx4029), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4030 (.OUT (nx4029), .A (tc2_data_29), .B (tc2_data_30), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_30 (.Q (tc2_data_30), .QB (
         \$dummy [229]), .D (nx4019), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4020 (.OUT (nx4019), .A (tc2_data_30), .B (tc2_data_31), .SEL (nx9540
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_31 (.Q (tc2_data_31), .QB (
         \$dummy [230]), .D (nx4009), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4010 (.OUT (nx4009), .A (tc2_data_31), .B (nx980), .SEL (nx9540)) ;
    Nand2 ix981 (.OUT (nx980), .A (nx7891), .B (nx6921)) ;
    Nand2 ix7892 (.OUT (nx7891), .A (tc2_data_0), .B (nx6916)) ;
    Nand3 ix7894 (.OUT (nx7893), .A (nx828), .B (
          U_command_control_int_hdr_data_8), .C (nx6902)) ;
    Nor3 ix1117 (.OUT (nx1116), .A (nx6663), .B (nx6641), .C (
         U_command_control_int_hdr_data_9)) ;
    DFFC U_command_control_CD1_reg_reg_data_0 (.Q (cd1_data_0), .QB (
         \$dummy [231]), .D (nx3359), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3360 (.OUT (nx3359), .A (cd1_data_0), .B (cd1_data_1), .SEL (nx9554)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_1 (.Q (cd1_data_1), .QB (
         \$dummy [232]), .D (nx3349), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3350 (.OUT (nx3349), .A (cd1_data_1), .B (cd1_data_2), .SEL (nx9554)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_2 (.Q (cd1_data_2), .QB (
         \$dummy [233]), .D (nx3339), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3340 (.OUT (nx3339), .A (cd1_data_2), .B (cd1_data_3), .SEL (nx9554)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_3 (.Q (cd1_data_3), .QB (
         \$dummy [234]), .D (nx3329), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3330 (.OUT (nx3329), .A (cd1_data_3), .B (cd1_data_4), .SEL (nx9554)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_4 (.Q (cd1_data_4), .QB (
         \$dummy [235]), .D (nx3319), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3320 (.OUT (nx3319), .A (cd1_data_4), .B (cd1_data_5), .SEL (nx9554)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_5 (.Q (cd1_data_5), .QB (
         \$dummy [236]), .D (nx3309), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3310 (.OUT (nx3309), .A (cd1_data_5), .B (cd1_data_6), .SEL (nx9552)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_6 (.Q (cd1_data_6), .QB (
         \$dummy [237]), .D (nx3299), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3300 (.OUT (nx3299), .A (cd1_data_6), .B (cd1_data_7), .SEL (nx9552)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_7 (.Q (cd1_data_7), .QB (
         \$dummy [238]), .D (nx3289), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3290 (.OUT (nx3289), .A (cd1_data_7), .B (cd1_data_8), .SEL (nx9552)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_8 (.Q (cd1_data_8), .QB (
         \$dummy [239]), .D (nx3279), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3280 (.OUT (nx3279), .A (cd1_data_8), .B (cd1_data_9), .SEL (nx9552)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_9 (.Q (cd1_data_9), .QB (
         \$dummy [240]), .D (nx3269), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3270 (.OUT (nx3269), .A (cd1_data_9), .B (cd1_data_10), .SEL (nx9552)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_10 (.Q (cd1_data_10), .QB (
         \$dummy [241]), .D (nx3259), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3260 (.OUT (nx3259), .A (cd1_data_10), .B (cd1_data_11), .SEL (nx9552
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_11 (.Q (cd1_data_11), .QB (
         \$dummy [242]), .D (nx3249), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3250 (.OUT (nx3249), .A (cd1_data_11), .B (cd1_data_12), .SEL (nx9552
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_12 (.Q (cd1_data_12), .QB (
         \$dummy [243]), .D (nx3239), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3240 (.OUT (nx3239), .A (cd1_data_12), .B (
         U_command_control_CD1_data_out_13), .SEL (nx9552)) ;
    DFFC U_command_control_CD1_reg_reg_data_13 (.Q (
         U_command_control_CD1_data_out_13), .QB (\$dummy [244]), .D (nx3229), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3230 (.OUT (nx3229), .A (U_command_control_CD1_data_out_13), .B (
         U_command_control_CD1_data_out_14), .SEL (nx9552)) ;
    DFFC U_command_control_CD1_reg_reg_data_14 (.Q (
         U_command_control_CD1_data_out_14), .QB (\$dummy [245]), .D (nx3219), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3220 (.OUT (nx3219), .A (U_command_control_CD1_data_out_14), .B (
         cd1_data_15), .SEL (nx9550)) ;
    DFFC U_command_control_CD1_reg_reg_data_15 (.Q (cd1_data_15), .QB (
         \$dummy [246]), .D (nx3209), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3210 (.OUT (nx3209), .A (cd1_data_15), .B (cd1_data_16), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_16 (.Q (cd1_data_16), .QB (
         \$dummy [247]), .D (nx3199), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3200 (.OUT (nx3199), .A (cd1_data_16), .B (cd1_data_17), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_17 (.Q (cd1_data_17), .QB (
         \$dummy [248]), .D (nx3189), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3190 (.OUT (nx3189), .A (cd1_data_17), .B (cd1_data_18), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_18 (.Q (cd1_data_18), .QB (
         \$dummy [249]), .D (nx3179), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3180 (.OUT (nx3179), .A (cd1_data_18), .B (cd1_data_19), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_19 (.Q (cd1_data_19), .QB (
         \$dummy [250]), .D (nx3169), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3170 (.OUT (nx3169), .A (cd1_data_19), .B (cd1_data_20), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_20 (.Q (cd1_data_20), .QB (
         \$dummy [251]), .D (nx3159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3160 (.OUT (nx3159), .A (cd1_data_20), .B (cd1_data_21), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_21 (.Q (cd1_data_21), .QB (
         \$dummy [252]), .D (nx3149), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3150 (.OUT (nx3149), .A (cd1_data_21), .B (cd1_data_22), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_22 (.Q (cd1_data_22), .QB (
         \$dummy [253]), .D (nx3139), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3140 (.OUT (nx3139), .A (cd1_data_22), .B (cd1_data_23), .SEL (nx9550
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_23 (.Q (cd1_data_23), .QB (
         \$dummy [254]), .D (nx3129), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3130 (.OUT (nx3129), .A (cd1_data_23), .B (cd1_data_24), .SEL (nx9548
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_24 (.Q (cd1_data_24), .QB (
         \$dummy [255]), .D (nx3119), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3120 (.OUT (nx3119), .A (cd1_data_24), .B (cd1_data_25), .SEL (nx9548
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_25 (.Q (cd1_data_25), .QB (
         \$dummy [256]), .D (nx3109), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3110 (.OUT (nx3109), .A (cd1_data_25), .B (cd1_data_26), .SEL (nx9548
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_26 (.Q (cd1_data_26), .QB (
         \$dummy [257]), .D (nx3099), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3100 (.OUT (nx3099), .A (cd1_data_26), .B (cd1_data_27), .SEL (nx9548
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_27 (.Q (cd1_data_27), .QB (
         \$dummy [258]), .D (nx3089), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3090 (.OUT (nx3089), .A (cd1_data_27), .B (cd1_data_28), .SEL (nx9548
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_28 (.Q (cd1_data_28), .QB (
         \$dummy [259]), .D (nx3079), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3080 (.OUT (nx3079), .A (cd1_data_28), .B (
         U_command_control_CD1_data_out_29), .SEL (nx9548)) ;
    DFFC U_command_control_CD1_reg_reg_data_29 (.Q (
         U_command_control_CD1_data_out_29), .QB (\$dummy [260]), .D (nx3069), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3070 (.OUT (nx3069), .A (U_command_control_CD1_data_out_29), .B (
         U_command_control_CD1_data_out_30), .SEL (nx9548)) ;
    DFFC U_command_control_CD1_reg_reg_data_30 (.Q (
         U_command_control_CD1_data_out_30), .QB (\$dummy [261]), .D (nx3059), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3060 (.OUT (nx3059), .A (U_command_control_CD1_data_out_30), .B (
         cd1_data_31), .SEL (nx9548)) ;
    DFFC U_command_control_CD1_reg_reg_data_31 (.Q (cd1_data_31), .QB (
         \$dummy [262]), .D (nx3049), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3050 (.OUT (nx3049), .A (cd1_data_31), .B (nx500), .SEL (nx9548)) ;
    Nand2 ix501 (.OUT (nx500), .A (nx8001), .B (nx6921)) ;
    Nand2 ix8002 (.OUT (nx8001), .A (cd1_data_0), .B (nx6916)) ;
    Nand4 ix8004 (.OUT (nx8003), .A (nx7583), .B (nx472), .C (nx8005), .D (
          nx8007)) ;
    Nor2 ix8006 (.OUT (nx8005), .A (U_command_control_int_hdr_data_9), .B (
         U_command_control_int_hdr_data_10)) ;
    Nor3 ix8008 (.OUT (nx8007), .A (U_command_control_int_hdr_data_12), .B (
         U_command_control_int_hdr_data_13), .C (nx6654)) ;
    DFFC U_command_control_CD0_reg_reg_data_0 (.Q (cd0_data_0), .QB (
         \$dummy [263]), .D (nx3679), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3680 (.OUT (nx3679), .A (cd0_data_0), .B (cd0_data_1), .SEL (nx9562)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_1 (.Q (cd0_data_1), .QB (
         \$dummy [264]), .D (nx3669), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3670 (.OUT (nx3669), .A (cd0_data_1), .B (cd0_data_2), .SEL (nx9562)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_2 (.Q (cd0_data_2), .QB (
         \$dummy [265]), .D (nx3659), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3660 (.OUT (nx3659), .A (cd0_data_2), .B (cd0_data_3), .SEL (nx9562)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_3 (.Q (cd0_data_3), .QB (
         \$dummy [266]), .D (nx3649), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3650 (.OUT (nx3649), .A (cd0_data_3), .B (cd0_data_4), .SEL (nx9562)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_4 (.Q (cd0_data_4), .QB (
         \$dummy [267]), .D (nx3639), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3640 (.OUT (nx3639), .A (cd0_data_4), .B (cd0_data_5), .SEL (nx9562)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_5 (.Q (cd0_data_5), .QB (
         \$dummy [268]), .D (nx3629), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3630 (.OUT (nx3629), .A (cd0_data_5), .B (cd0_data_6), .SEL (nx9560)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_6 (.Q (cd0_data_6), .QB (
         \$dummy [269]), .D (nx3619), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3620 (.OUT (nx3619), .A (cd0_data_6), .B (cd0_data_7), .SEL (nx9560)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_7 (.Q (cd0_data_7), .QB (
         \$dummy [270]), .D (nx3609), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3610 (.OUT (nx3609), .A (cd0_data_7), .B (cd0_data_8), .SEL (nx9560)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_8 (.Q (cd0_data_8), .QB (
         \$dummy [271]), .D (nx3599), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3600 (.OUT (nx3599), .A (cd0_data_8), .B (cd0_data_9), .SEL (nx9560)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_9 (.Q (cd0_data_9), .QB (
         \$dummy [272]), .D (nx3589), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3590 (.OUT (nx3589), .A (cd0_data_9), .B (cd0_data_10), .SEL (nx9560)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_10 (.Q (cd0_data_10), .QB (
         \$dummy [273]), .D (nx3579), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3580 (.OUT (nx3579), .A (cd0_data_10), .B (cd0_data_11), .SEL (nx9560
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_11 (.Q (cd0_data_11), .QB (
         \$dummy [274]), .D (nx3569), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3570 (.OUT (nx3569), .A (cd0_data_11), .B (cd0_data_12), .SEL (nx9560
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_12 (.Q (cd0_data_12), .QB (
         \$dummy [275]), .D (nx3559), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3560 (.OUT (nx3559), .A (cd0_data_12), .B (
         U_command_control_CD0_data_out_13), .SEL (nx9560)) ;
    DFFC U_command_control_CD0_reg_reg_data_13 (.Q (
         U_command_control_CD0_data_out_13), .QB (\$dummy [276]), .D (nx3549), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3550 (.OUT (nx3549), .A (U_command_control_CD0_data_out_13), .B (
         U_command_control_CD0_data_out_14), .SEL (nx9560)) ;
    DFFC U_command_control_CD0_reg_reg_data_14 (.Q (
         U_command_control_CD0_data_out_14), .QB (\$dummy [277]), .D (nx3539), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3540 (.OUT (nx3539), .A (U_command_control_CD0_data_out_14), .B (
         cd0_data_15), .SEL (nx9558)) ;
    DFFC U_command_control_CD0_reg_reg_data_15 (.Q (cd0_data_15), .QB (
         \$dummy [278]), .D (nx3529), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3530 (.OUT (nx3529), .A (cd0_data_15), .B (cd0_data_16), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_16 (.Q (cd0_data_16), .QB (
         \$dummy [279]), .D (nx3519), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3520 (.OUT (nx3519), .A (cd0_data_16), .B (cd0_data_17), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_17 (.Q (cd0_data_17), .QB (
         \$dummy [280]), .D (nx3509), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3510 (.OUT (nx3509), .A (cd0_data_17), .B (cd0_data_18), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_18 (.Q (cd0_data_18), .QB (
         \$dummy [281]), .D (nx3499), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3500 (.OUT (nx3499), .A (cd0_data_18), .B (cd0_data_19), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_19 (.Q (cd0_data_19), .QB (
         \$dummy [282]), .D (nx3489), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3490 (.OUT (nx3489), .A (cd0_data_19), .B (cd0_data_20), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_20 (.Q (cd0_data_20), .QB (
         \$dummy [283]), .D (nx3479), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3480 (.OUT (nx3479), .A (cd0_data_20), .B (cd0_data_21), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_21 (.Q (cd0_data_21), .QB (
         \$dummy [284]), .D (nx3469), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3470 (.OUT (nx3469), .A (cd0_data_21), .B (cd0_data_22), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_22 (.Q (cd0_data_22), .QB (
         \$dummy [285]), .D (nx3459), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3460 (.OUT (nx3459), .A (cd0_data_22), .B (cd0_data_23), .SEL (nx9558
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_23 (.Q (cd0_data_23), .QB (
         \$dummy [286]), .D (nx3449), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3450 (.OUT (nx3449), .A (cd0_data_23), .B (cd0_data_24), .SEL (nx9556
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_24 (.Q (cd0_data_24), .QB (
         \$dummy [287]), .D (nx3439), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3440 (.OUT (nx3439), .A (cd0_data_24), .B (cd0_data_25), .SEL (nx9556
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_25 (.Q (cd0_data_25), .QB (
         \$dummy [288]), .D (nx3429), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3430 (.OUT (nx3429), .A (cd0_data_25), .B (cd0_data_26), .SEL (nx9556
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_26 (.Q (cd0_data_26), .QB (
         \$dummy [289]), .D (nx3419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3420 (.OUT (nx3419), .A (cd0_data_26), .B (cd0_data_27), .SEL (nx9556
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_27 (.Q (cd0_data_27), .QB (
         \$dummy [290]), .D (nx3409), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3410 (.OUT (nx3409), .A (cd0_data_27), .B (cd0_data_28), .SEL (nx9556
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_28 (.Q (cd0_data_28), .QB (
         \$dummy [291]), .D (nx3399), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3400 (.OUT (nx3399), .A (cd0_data_28), .B (
         U_command_control_CD0_data_out_29), .SEL (nx9556)) ;
    DFFC U_command_control_CD0_reg_reg_data_29 (.Q (
         U_command_control_CD0_data_out_29), .QB (\$dummy [292]), .D (nx3389), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3390 (.OUT (nx3389), .A (U_command_control_CD0_data_out_29), .B (
         U_command_control_CD0_data_out_30), .SEL (nx9556)) ;
    DFFC U_command_control_CD0_reg_reg_data_30 (.Q (
         U_command_control_CD0_data_out_30), .QB (\$dummy [293]), .D (nx3379), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3380 (.OUT (nx3379), .A (U_command_control_CD0_data_out_30), .B (
         cd0_data_31), .SEL (nx9556)) ;
    DFFC U_command_control_CD0_reg_reg_data_31 (.Q (cd0_data_31), .QB (
         \$dummy [294]), .D (nx3369), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3370 (.OUT (nx3369), .A (cd0_data_31), .B (nx650), .SEL (nx9556)) ;
    Nand2 ix651 (.OUT (nx650), .A (nx8106), .B (nx6921)) ;
    Nand2 ix8107 (.OUT (nx8106), .A (cd0_data_0), .B (nx6916)) ;
    Nand4 ix8109 (.OUT (nx8108), .A (nx7287), .B (nx472), .C (nx8005), .D (
          nx8007)) ;
    Nor2 ix463 (.OUT (nx462), .A (nx8143), .B (nx6641)) ;
    DFFC reg_int_rdback (.Q (int_rdback), .QB (nx8143), .D (rdback), .CLK (
         NOT_sysclk), .CLR (int_reset_l)) ;
    Inv ix8146 (.OUT (NOT_sysclk), .A (sysclk)) ;
    Nor3 ix445 (.OUT (nx444), .A (nx6385), .B (nx6379), .C (nx8153)) ;
    AOI22 ix8154 (.OUT (nx8153), .A (U_command_control_int_hdr_data_12), .B (
          nx6463), .C (U_command_control_int_hdr_data_13), .D (nx90)) ;
    Nand2 ix427 (.OUT (nx426), .A (nx8159), .B (nx8161)) ;
    AOI22 ix8160 (.OUT (nx8159), .A (U_command_control_int_hdr_data_8), .B (
          nx6463), .C (U_command_control_int_hdr_data_10), .D (nx7473)) ;
    AOI22 ix8162 (.OUT (nx8161), .A (U_command_control_int_hdr_data_9), .B (nx90
          ), .C (U_command_control_int_hdr_data_11), .D (nx2831)) ;
    Nor3 ix8165 (.OUT (nx8164), .A (nx392), .B (nx390), .C (nx380)) ;
    Nor2 ix393 (.OUT (nx392), .A (nx6902), .B (nx6467)) ;
    Nor2 ix391 (.OUT (nx390), .A (nx6385), .B (nx8168)) ;
    AOI22 ix8169 (.OUT (nx8168), .A (U_command_control_int_hdr_data_6), .B (
          nx7473), .C (U_command_control_int_hdr_data_5), .D (nx90)) ;
    Nor2 ix381 (.OUT (nx380), .A (U_command_control_cmd_cnt_2), .B (nx6411)) ;
    Nor2 ix369 (.OUT (nx368), .A (nx8143), .B (nx6450)) ;
    Nand3 ix8187 (.OUT (nx8186), .A (nx324), .B (nx7468), .C (nx6423)) ;
    Nand2 ix325 (.OUT (nx324), .A (nx8189), .B (nx7456)) ;
    Nand3 ix8190 (.OUT (nx8189), .A (nx114), .B (U_command_control_int_cmd_en), 
          .C (nx6443)) ;
    Nand3 ix8192 (.OUT (nx8191), .A (nx114), .B (U_command_control_cmd_state_2)
          , .C (nx6435)) ;
    Nor2 ix3301 (.OUT (nx3300), .A (nx2837), .B (nx8196)) ;
    AOI22 ix8197 (.OUT (nx8196), .A (sel_addr_reg), .B (nx8199), .C (nx3282), .D (
          nx3288)) ;
    DFFC U_command_control_reg_int_sel_addr (.Q (sel_addr_reg), .QB (nx8193), .D (
         nx3300), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix8200 (.OUT (nx8199), .A (nx6372), .B (nx6425), .C (nx90)) ;
    Nor2 ix3283 (.OUT (nx3282), .A (U_command_control_cmd_cnt_3), .B (nx6385)) ;
    Nor3 ix3289 (.OUT (nx3288), .A (nx244), .B (U_command_control_cmd_cnt_4), .C (
         U_command_control_cmd_cnt_5)) ;
    Nor2 ix8204 (.OUT (nx8203), .A (nx3516), .B (nx3488)) ;
    Nand2 ix3517 (.OUT (nx3516), .A (nx8206), .B (nx8209)) ;
    Nand4 ix8207 (.OUT (nx8206), .A (U_command_control_int_cmd_en), .B (nx7287)
          , .C (nx8007), .D (nx826)) ;
    Nor2 ix827 (.OUT (nx826), .A (nx6641), .B (U_command_control_int_hdr_data_9)
         ) ;
    DFFC U_readout_control_reg_int_rd_clken (.Q (\$dummy [295]), .QB (nx8209), .D (
         nx3500), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix3501 (.OUT (nx3500), .A (nx8212), .B (nx6533), .C (nx6497)) ;
    Nand2 ix8213 (.OUT (nx8212), .A (nx7410), .B (nx3492)) ;
    Nand3 ix3493 (.OUT (nx3492), .A (nx6529), .B (nx6541), .C (nx6521)) ;
    Nand3 ix3489 (.OUT (nx3488), .A (nx8216), .B (nx2881), .C (nx8307)) ;
    Nor2 ix3479 (.OUT (nx3478), .A (nx7133), .B (nx8219)) ;
    Nor2 ix8220 (.OUT (nx8219), .A (ramp_period), .B (
         U_analog_control_sft_desel_all_cells_16)) ;
    DFFC U_analog_control_reg_int_ramp_period (.Q (ramp_period), .QB (nx8216), .D (
         nx3478), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_16 (.Q (
         U_analog_control_sft_desel_all_cells_16), .QB (\$dummy [296]), .D (
         U_analog_control_sft_desel_all_cells_15), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_15 (.Q (
         U_analog_control_sft_desel_all_cells_15), .QB (\$dummy [297]), .D (
         U_analog_control_sft_desel_all_cells_14), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_14 (.Q (
         U_analog_control_sft_desel_all_cells_14), .QB (\$dummy [298]), .D (
         U_analog_control_sft_desel_all_cells_13), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_13 (.Q (
         U_analog_control_sft_desel_all_cells_13), .QB (\$dummy [299]), .D (
         U_analog_control_sft_desel_all_cells_12), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_12 (.Q (
         U_analog_control_sft_desel_all_cells_12), .QB (\$dummy [300]), .D (
         U_analog_control_sft_desel_all_cells_11), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_11 (.Q (
         U_analog_control_sft_desel_all_cells_11), .QB (\$dummy [301]), .D (
         U_analog_control_sft_desel_all_cells_10), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_10 (.Q (
         U_analog_control_sft_desel_all_cells_10), .QB (\$dummy [302]), .D (
         U_analog_control_sft_desel_all_cells_9), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_9 (.Q (
         U_analog_control_sft_desel_all_cells_9), .QB (\$dummy [303]), .D (
         U_analog_control_sft_desel_all_cells_8), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_8 (.Q (
         U_analog_control_sft_desel_all_cells_8), .QB (\$dummy [304]), .D (
         U_analog_control_sft_desel_all_cells_7), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_7 (.Q (
         U_analog_control_sft_desel_all_cells_7), .QB (\$dummy [305]), .D (
         U_analog_control_sft_desel_all_cells_6), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_6 (.Q (
         U_analog_control_sft_desel_all_cells_6), .QB (\$dummy [306]), .D (
         U_analog_control_sft_desel_all_cells_5), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_5 (.Q (
         U_analog_control_sft_desel_all_cells_5), .QB (\$dummy [307]), .D (
         U_analog_control_sft_desel_all_cells_4), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_4 (.Q (
         U_analog_control_sft_desel_all_cells_4), .QB (\$dummy [308]), .D (
         U_analog_control_sft_desel_all_cells_3), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_3 (.Q (
         U_analog_control_sft_desel_all_cells_3), .QB (\$dummy [309]), .D (
         U_analog_control_sft_desel_all_cells_2), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_2 (.Q (
         U_analog_control_sft_desel_all_cells_2), .QB (\$dummy [310]), .D (
         U_analog_control_sft_desel_all_cells_1), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_1 (.Q (
         U_analog_control_sft_desel_all_cells_1), .QB (\$dummy [311]), .D (
         U_analog_control_sft_desel_all_cells_0), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    Nand2 ix3403 (.OUT (nx3402), .A (nx8241), .B (nx8263)) ;
    AOI22 ix8242 (.OUT (nx8241), .A (nx8243), .B (desel_all_cells), .C (nx3352)
          , .D (nx3392)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_0 (.Q (
         U_analog_control_sft_desel_all_cells_0), .QB (nx8243), .D (
         desel_all_cells), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor4 ix3353 (.OUT (nx3352), .A (nx8246), .B (nx3340), .C (nx2834), .D (
         nx2827)) ;
    Nand4 ix8247 (.OUT (nx8246), .A (nx6812), .B (nx6803), .C (nx6799), .D (
          nx6785)) ;
    Nor4 ix3393 (.OUT (nx3392), .A (nx8250), .B (nx3376), .C (nx3378), .D (
         nx3380)) ;
    Nand4 ix8251 (.OUT (nx8250), .A (nx8252), .B (nx8254), .C (nx8256), .D (
          nx8258)) ;
    DFFC U_analog_control_reg_int_desel_all_cells (.Q (desel_all_cells), .QB (
         \$dummy [312]), .D (nx3402), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix8281 (.OUT (nx8280), .A (nx8282), .B (nx8284), .C (nx8286), .D (
          nx8288)) ;
    Nand3 ix3279 (.OUT (nx2881), .A (U_analog_control_mst_state_1), .B (nx6671)
          , .C (U_analog_control_mst_state_0)) ;
    Nor2 ix8308 (.OUT (nx8307), .A (nx3306), .B (sel_addr_reg)) ;
    Nor2 ix3307 (.OUT (nx3306), .A (nx6632), .B (nx6905)) ;
    AO22 ix5675 (.OUT (reg_sel0), .A (nx8193), .B (nx3308), .C (nx8311), .D (
         nx3516)) ;
    DFFC U_readout_control_reg_read_state (.Q (read_state), .QB (\$dummy [313])
         , .D (nx3562), .CLK (sysclk), .CLR (int_reset_l)) ;
    AOI22 ix3563 (.OUT (nx3562), .A (nx6516), .B (nx6513), .C (nx6494), .D (
          nx2456)) ;
    DFFC U_analog_control_reg_analog_state (.Q (analog_state), .QB (
         \$dummy [314]), .D (nx5654), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix5655 (.OUT (nx5654), .A (nx8318), .B (nx2885)) ;
    Nand2 ix8319 (.OUT (nx8318), .A (nx8274), .B (nx4428)) ;
    Nand4 ix4429 (.OUT (nx4428), .A (nx6689), .B (nx6683), .C (nx6743), .D (
          nx6737)) ;
    Nand2 ix5719 (.OUT (precharge_bus), .A (nx8323), .B (nx8332)) ;
    DFFC U_readout_control_reg_int_pre_dig (.Q (\$dummy [315]), .QB (nx8323), .D (
         nx5712), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix5713 (.OUT (nx5712), .A (nx5690), .B (nx5694), .C (nx7250), .D (
         nx5706)) ;
    Nand4 ix5691 (.OUT (nx5690), .A (nx6560), .B (U_readout_control_st_cnt_2), .C (
          nx2866), .D (nx8327)) ;
    Nor3 ix8328 (.OUT (nx8327), .A (nx6573), .B (U_readout_control_st_cnt_8), .C (
         U_readout_control_st_cnt_3)) ;
    Nor2 ix5695 (.OUT (nx5694), .A (nx8323), .B (nx2456)) ;
    AO22 ix5707 (.OUT (nx5706), .A (nx7329), .B (nx2054), .C (nx6506), .D (
         nx2220)) ;
    Nand3 ix2221 (.OUT (nx2220), .A (U_readout_control_typ_cnt_3), .B (
          U_readout_control_row_cnt_4), .C (nx2865)) ;
    DFFC U_analog_control_reg_int_precharge_ana_bus (.Q (\$dummy [316]), .QB (
         nx8332), .D (nx3324), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix3325 (.OUT (nx3324), .A (nx8335), .B (nx8337), .C (nx6674)) ;
    Nand2 ix8336 (.OUT (nx8335), .A (nx7142), .B (nx2850)) ;
    DFFC U_analog_control_reg_int_sel_cell (.Q (sel_cell), .QB (\$dummy [317]), 
         .D (nx5642), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix5643 (.OUT (nx5642), .A (sel_cell), .B (nx3172), .C (
         U_analog_control_sft_desel_all_cells_12), .D (nx5636)) ;
    Nand2 ix5637 (.OUT (nx5636), .A (nx7133), .B (nx2827)) ;
    DFFC U_analog_control_reg_pwr_up_acq_dig (.Q (pwr_up_acq_dig), .QB (
         \$dummy [318]), .D (nx6279), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4639 (.OUT (nx4638), .A (nx8355), .B (nx9508), .C (nx4632)) ;
    Nor2 ix8356 (.OUT (nx8355), .A (nx2942), .B (nx10630)) ;
    Nor3 ix4623 (.OUT (nx4622), .A (nx8361), .B (nx9508), .C (nx2942)) ;
    Nor2 ix8362 (.OUT (nx8361), .A (nx2941), .B (U_analog_control_mst_cnt_13)) ;
    Nor3 ix4609 (.OUT (nx4608), .A (nx8367), .B (nx9508), .C (nx2941)) ;
    Nor2 ix8368 (.OUT (nx8367), .A (nx2939), .B (nx10636)) ;
    Nor3 ix4595 (.OUT (nx4594), .A (nx8373), .B (nx9508), .C (nx2939)) ;
    Nor2 ix8374 (.OUT (nx8373), .A (nx2937), .B (U_analog_control_mst_cnt_11)) ;
    Nor3 ix4581 (.OUT (nx4580), .A (nx8379), .B (nx9508), .C (nx2937)) ;
    Nor2 ix8380 (.OUT (nx8379), .A (nx2935), .B (nx10642)) ;
    Nor3 ix4567 (.OUT (nx4566), .A (nx8385), .B (nx9508), .C (nx2935)) ;
    Nor2 ix8386 (.OUT (nx8385), .A (nx2934), .B (U_analog_control_mst_cnt_9)) ;
    Nor3 ix4553 (.OUT (nx4552), .A (nx8391), .B (nx9508), .C (nx2934)) ;
    Nor2 ix8392 (.OUT (nx8391), .A (nx2933), .B (nx10644)) ;
    Nor3 ix4539 (.OUT (nx4538), .A (nx8397), .B (nx9506), .C (nx2933)) ;
    Nor2 ix8398 (.OUT (nx8397), .A (nx8453), .B (U_analog_control_mst_cnt_7)) ;
    Nor3 ix4525 (.OUT (nx4524), .A (nx8403), .B (nx9506), .C (nx8453)) ;
    Nor2 ix8404 (.OUT (nx8403), .A (nx2930), .B (nx10640)) ;
    Nor3 ix4511 (.OUT (nx4510), .A (nx8409), .B (nx9506), .C (nx2930)) ;
    Nor2 ix8410 (.OUT (nx8409), .A (nx2929), .B (U_analog_control_mst_cnt_5)) ;
    Nor3 ix4497 (.OUT (nx4496), .A (nx8415), .B (nx9506), .C (nx2929)) ;
    Nor2 ix8416 (.OUT (nx8415), .A (nx2928), .B (nx10650)) ;
    Nor3 ix4483 (.OUT (nx4482), .A (nx8421), .B (nx9506), .C (nx2928)) ;
    Nor2 ix8422 (.OUT (nx8421), .A (nx2927), .B (U_analog_control_mst_cnt_3)) ;
    Nor3 ix4469 (.OUT (nx4468), .A (nx8427), .B (nx9506), .C (nx2927)) ;
    Nor2 ix8428 (.OUT (nx8427), .A (nx2926), .B (nx10638)) ;
    Nor2 ix4461 (.OUT (nx2926), .A (nx8430), .B (nx10648)) ;
    Nor3 ix4455 (.OUT (nx4454), .A (nx8433), .B (nx9506), .C (nx2926)) ;
    Nor2 ix8434 (.OUT (nx8433), .A (nx10011), .B (U_analog_control_mst_cnt_1)) ;
    DFFC U_analog_control_mst_cnt_0 (.Q (\$dummy [319]), .QB (nx8437), .D (
         nx4442), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix4443 (.OUT (nx4442), .A (nx10011), .B (nx9506)) ;
    DFFC reg_U_analog_control_mst_cnt_1 (.Q (U_analog_control_mst_cnt_1), .QB (
         nx8430), .D (nx4454), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_2 (.Q (U_analog_control_mst_cnt_2), .QB (
         \$dummy [320]), .D (nx4468), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_3 (.Q (U_analog_control_mst_cnt_3), .QB (
         nx8418), .D (nx4482), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_4 (.Q (U_analog_control_mst_cnt_4), .QB (
         \$dummy [321]), .D (nx4496), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_5 (.Q (U_analog_control_mst_cnt_5), .QB (
         nx8406), .D (nx4510), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_6 (.Q (U_analog_control_mst_cnt_6), .QB (
         \$dummy [322]), .D (nx4524), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_7 (.Q (U_analog_control_mst_cnt_7), .QB (
         nx8394), .D (nx4538), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_8 (.Q (U_analog_control_mst_cnt_8), .QB (
         \$dummy [323]), .D (nx4552), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_9 (.Q (U_analog_control_mst_cnt_9), .QB (
         nx8382), .D (nx4566), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_10 (.Q (U_analog_control_mst_cnt_10), .QB (
         \$dummy [324]), .D (nx4580), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_11 (.Q (U_analog_control_mst_cnt_11), .QB (
         nx8370), .D (nx4594), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_12 (.Q (U_analog_control_mst_cnt_12), .QB (
         \$dummy [325]), .D (nx4608), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_13 (.Q (U_analog_control_mst_cnt_13), .QB (
         nx8358), .D (nx4622), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_14 (.Q (U_analog_control_mst_cnt_14), .QB (
         \$dummy [326]), .D (nx4638), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4667 (.OUT (nx4666), .A (nx8484), .B (nx9508), .C (nx2944)) ;
    Nor2 ix8485 (.OUT (nx8484), .A (nx2943), .B (U_analog_control_mst_cnt_16)) ;
    Nor3 ix4653 (.OUT (nx4652), .A (nx8490), .B (nx9508), .C (nx2943)) ;
    Nor2 ix8491 (.OUT (nx8490), .A (nx4632), .B (U_analog_control_mst_cnt_15)) ;
    DFFC reg_U_analog_control_mst_cnt_15 (.Q (U_analog_control_mst_cnt_15), .QB (
         nx8487), .D (nx4652), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_16 (.Q (U_analog_control_mst_cnt_16), .QB (
         \$dummy [327]), .D (nx4666), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4681 (.OUT (nx4680), .A (nx8502), .B (nx9510), .C (nx2945)) ;
    Nor2 ix8503 (.OUT (nx8502), .A (nx2944), .B (U_analog_control_mst_cnt_17)) ;
    DFFC reg_U_analog_control_mst_cnt_17 (.Q (U_analog_control_mst_cnt_17), .QB (
         nx8505), .D (nx4680), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4695 (.OUT (nx4694), .A (nx8511), .B (nx9510), .C (nx2946)) ;
    Nor2 ix8512 (.OUT (nx8511), .A (nx2945), .B (U_analog_control_mst_cnt_18)) ;
    DFFC reg_U_analog_control_mst_cnt_18 (.Q (U_analog_control_mst_cnt_18), .QB (
         \$dummy [328]), .D (nx4694), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4709 (.OUT (nx4708), .A (nx8520), .B (nx9510), .C (nx2947)) ;
    Nor2 ix8521 (.OUT (nx8520), .A (nx2946), .B (U_analog_control_mst_cnt_19)) ;
    DFFC reg_U_analog_control_mst_cnt_19 (.Q (U_analog_control_mst_cnt_19), .QB (
         nx8523), .D (nx4708), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4723 (.OUT (nx4722), .A (nx8531), .B (nx9510), .C (nx2949)) ;
    Nor2 ix8532 (.OUT (nx8531), .A (nx2947), .B (U_analog_control_mst_cnt_20)) ;
    DFFC reg_U_analog_control_mst_cnt_20 (.Q (U_analog_control_mst_cnt_20), .QB (
         \$dummy [329]), .D (nx4722), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4737 (.OUT (nx4736), .A (nx8540), .B (nx9510), .C (nx2950)) ;
    Nor2 ix8541 (.OUT (nx8540), .A (nx2949), .B (U_analog_control_mst_cnt_21)) ;
    DFFC reg_U_analog_control_mst_cnt_21 (.Q (U_analog_control_mst_cnt_21), .QB (
         nx8543), .D (nx4736), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4751 (.OUT (nx4750), .A (nx8549), .B (nx9510), .C (nx2951)) ;
    Nor2 ix8550 (.OUT (nx8549), .A (nx2950), .B (U_analog_control_mst_cnt_22)) ;
    DFFC reg_U_analog_control_mst_cnt_22 (.Q (U_analog_control_mst_cnt_22), .QB (
         \$dummy [330]), .D (nx4750), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4765 (.OUT (nx4764), .A (nx8558), .B (nx9510), .C (nx2953)) ;
    DFFC reg_U_analog_control_mst_cnt_23 (.Q (U_analog_control_mst_cnt_23), .QB (
         nx8561), .D (nx4764), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_24 (.Q (U_analog_control_mst_cnt_24), .QB (
         \$dummy [331]), .D (nx4778), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_25 (.Q (U_analog_control_mst_cnt_25), .QB (
         nx8581), .D (nx4792), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4807 (.OUT (nx4806), .A (nx8587), .B (nx9512), .C (nx2958)) ;
    DFFC reg_U_analog_control_mst_cnt_26 (.Q (U_analog_control_mst_cnt_26), .QB (
         \$dummy [332]), .D (nx4806), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_27 (.Q (U_analog_control_mst_cnt_27), .QB (
         nx8599), .D (nx4820), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4835 (.OUT (nx4834), .A (nx8607), .B (nx9512), .C (nx2960)) ;
    Nor2 ix8608 (.OUT (nx8607), .A (nx2959), .B (U_analog_control_mst_cnt_28)) ;
    DFFC reg_U_analog_control_mst_cnt_28 (.Q (U_analog_control_mst_cnt_28), .QB (
         \$dummy [333]), .D (nx4834), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_29 (.Q (U_analog_control_mst_cnt_29), .QB (
         nx8619), .D (nx4848), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4863 (.OUT (nx4862), .A (nx8625), .B (nx9512), .C (nx2962)) ;
    DFFC reg_U_analog_control_mst_cnt_30 (.Q (U_analog_control_mst_cnt_30), .QB (
         \$dummy [334]), .D (nx4862), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_mst_cnt_31 (.Q (U_analog_control_mst_cnt_31), .QB (
         \$dummy [335]), .D (nx4872), .CLK (sysclk), .CLR (int_reset_l)) ;
    Xnor2 ix8649 (.out (nx8648), .A (nx10642), .B (tc2_data_10)) ;
    Xnor2 ix8653 (.out (nx8652), .A (nx10644), .B (tc2_data_8)) ;
    Xnor2 ix8659 (.out (nx8658), .A (nx10640), .B (tc2_data_6)) ;
    Xnor2 ix8663 (.out (nx8662), .A (nx10650), .B (tc2_data_4)) ;
    Xnor2 ix8669 (.out (nx8668), .A (nx10638), .B (tc2_data_2)) ;
    Nor2 ix4419 (.OUT (nx4418), .A (nx8677), .B (nx9015)) ;
    Nand2 ix4375 (.OUT (nx4374), .A (nx8681), .B (nx8839)) ;
    AOI22 ix8682 (.OUT (nx8681), .A (start_calibrate), .B (nx10660), .C (
          U_analog_control_cal_state_0), .D (nx8869)) ;
    DFFC U_command_control_reg_start_calibrate (.Q (start_calibrate), .QB (
         \$dummy [336]), .D (nx6259), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6260 (.OUT (nx6259), .A (nx2851), .B (start_calibrate), .SEL (nx4362)
         ) ;
    Nand2 ix4363 (.OUT (nx4362), .A (nx8686), .B (nx2851)) ;
    Nand2 ix8687 (.OUT (nx8686), .A (U_command_control_int_hdr_data_7), .B (
          nx1924)) ;
    DFFC U_analog_control_reg_cal_state_0 (.Q (U_analog_control_cal_state_0), .QB (
         nx8692), .D (nx4374), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_reg_cal_state_1 (.Q (U_analog_control_cal_state_1), .QB (
         nx8689), .D (nx2903), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix3581 (.OUT (nx3580), .A (U_analog_control_sub_cnt_1), .B (
          U_analog_control_sub_cnt_2), .C (nx6727)) ;
    DFFC reg_U_analog_control_cal_cnt_12 (.Q (U_analog_control_cal_cnt_12), .QB (
         nx8827), .D (nx6249), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_cal_cnt_11 (.Q (U_analog_control_cal_cnt_11), .QB (
         nx8712), .D (nx6239), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_cal_cnt_10 (.Q (U_analog_control_cal_cnt_10), .QB (
         nx8720), .D (nx6229), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_cal_cnt_9 (.Q (U_analog_control_cal_cnt_9), .QB (
         nx8728), .D (nx6219), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6210 (.OUT (nx6209), .A (U_analog_control_cal_cnt_8), .B (nx3826), .SEL (
         nx9564)) ;
    DFFC reg_U_analog_control_cal_cnt_8 (.Q (U_analog_control_cal_cnt_8), .QB (
         nx8736), .D (nx6209), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3827 (.OUT (nx3826), .A (nx8741), .B (nx2921), .C (nx10662)) ;
    Nor2 ix8742 (.OUT (nx8741), .A (nx2919), .B (U_analog_control_cal_cnt_8)) ;
    Nor2 ix3817 (.OUT (nx2919), .A (nx8744), .B (nx8817)) ;
    Mux2 ix6200 (.OUT (nx6199), .A (U_analog_control_cal_cnt_7), .B (nx3810), .SEL (
         nx9564)) ;
    DFFC reg_U_analog_control_cal_cnt_7 (.Q (U_analog_control_cal_cnt_7), .QB (
         nx8744), .D (nx6199), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3811 (.OUT (nx3810), .A (nx8749), .B (nx2919), .C (nx10662)) ;
    Nor2 ix8750 (.OUT (nx8749), .A (nx2918), .B (U_analog_control_cal_cnt_7)) ;
    DFFC reg_U_analog_control_cal_cnt_6 (.Q (U_analog_control_cal_cnt_6), .QB (
         nx8752), .D (nx6189), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix8758 (.OUT (nx8757), .A (nx2917), .B (U_analog_control_cal_cnt_6)) ;
    DFFC reg_U_analog_control_cal_cnt_5 (.Q (U_analog_control_cal_cnt_5), .QB (
         nx8760), .D (nx6179), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix8766 (.OUT (nx8765), .A (nx2915), .B (U_analog_control_cal_cnt_5)) ;
    DFFC reg_U_analog_control_cal_cnt_4 (.Q (U_analog_control_cal_cnt_4), .QB (
         \$dummy [337]), .D (nx6169), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6160 (.OUT (nx6159), .A (U_analog_control_cal_cnt_3), .B (nx3746), .SEL (
         nx9564)) ;
    DFFC reg_U_analog_control_cal_cnt_3 (.Q (U_analog_control_cal_cnt_3), .QB (
         nx8776), .D (nx6159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3747 (.OUT (nx3746), .A (nx8781), .B (nx2914), .C (nx10662)) ;
    Nor2 ix8782 (.OUT (nx8781), .A (nx2913), .B (U_analog_control_cal_cnt_3)) ;
    Mux2 ix6150 (.OUT (nx6149), .A (U_analog_control_cal_cnt_2), .B (nx3730), .SEL (
         nx9564)) ;
    DFFC reg_U_analog_control_cal_cnt_2 (.Q (U_analog_control_cal_cnt_2), .QB (
         \$dummy [338]), .D (nx6149), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3731 (.OUT (nx3730), .A (nx8789), .B (nx2913), .C (nx10662)) ;
    Nor2 ix8790 (.OUT (nx8789), .A (nx2912), .B (U_analog_control_cal_cnt_2)) ;
    Nor2 ix3721 (.OUT (nx2912), .A (nx8792), .B (nx8808)) ;
    Mux2 ix6140 (.OUT (nx6139), .A (U_analog_control_cal_cnt_1), .B (nx3714), .SEL (
         nx9564)) ;
    DFFC reg_U_analog_control_cal_cnt_1 (.Q (U_analog_control_cal_cnt_1), .QB (
         nx8792), .D (nx6139), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3715 (.OUT (nx3714), .A (nx8797), .B (nx2912), .C (nx10662)) ;
    Nor2 ix8798 (.OUT (nx8797), .A (U_analog_control_cal_cnt_0), .B (
         U_analog_control_cal_cnt_1)) ;
    DFFC reg_U_analog_control_cal_cnt_0 (.Q (U_analog_control_cal_cnt_0), .QB (
         nx8808), .D (nx6129), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix8806 (.OUT (nx8805), .A (nx4284), .B (U_analog_control_cal_state_1)
         ) ;
    Nor2 ix4285 (.OUT (nx4284), .A (nx2881), .B (nx3580)) ;
    Nand2 ix8818 (.OUT (nx8817), .A (U_analog_control_cal_cnt_6), .B (nx2917)) ;
    DFFC U_analog_control_reg_cal_dly_12 (.Q (U_analog_control_cal_dly_12), .QB (
         \$dummy [339]), .D (nx3688), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3689 (.OUT (nx3688), .A (nx8831), .B (nx8872)) ;
    AOI22 ix8832 (.OUT (nx8831), .A (cd0_data_12), .B (nx9566), .C (cd1_data_28)
          , .D (nx9570)) ;
    Nor4 ix8834 (.OUT (nx8833), .A (nx8835), .B (
         U_analog_control_int_cal_pulse_1), .C (U_analog_control_int_cal_pulse_2
         ), .D (U_analog_control_int_cal_pulse_3)) ;
    Mux2 ix3601 (.OUT (nx2909), .A (nx10660), .B (
         U_analog_control_int_cal_pulse_0), .SEL (nx8839)) ;
    DFFC U_analog_control_reg_int_cal_pulse_0 (.Q (
         U_analog_control_int_cal_pulse_0), .QB (nx8835), .D (nx2909), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix8840 (.OUT (nx8839), .A (U_analog_control_cal_state_0), .B (nx8841)
          ) ;
    DFFC U_analog_control_reg_int_cal_pulse_1 (.Q (
         U_analog_control_int_cal_pulse_1), .QB (nx8863), .D (nx3610), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3611 (.OUT (nx3610), .A (nx8849), .B (nx8861)) ;
    Nand2 ix8850 (.OUT (nx8849), .A (U_analog_control_int_cal_pulse_1), .B (
          nx2907)) ;
    Nand4 ix8862 (.OUT (nx8861), .A (U_analog_control_int_cal_pulse_0), .B (
          nx8839), .C (U_analog_control_cal_state_1), .D (
          U_analog_control_cal_state_0)) ;
    DFFC U_analog_control_reg_int_cal_pulse_2 (.Q (
         U_analog_control_int_cal_pulse_2), .QB (nx8866), .D (nx3620), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3621 (.OUT (nx3620), .A (U_analog_control_int_cal_pulse_1), .B (
         nx2905), .C (U_analog_control_int_cal_pulse_2), .D (nx2907)) ;
    DFFC U_analog_control_reg_int_cal_pulse_3 (.Q (
         U_analog_control_int_cal_pulse_3), .QB (nx8869), .D (nx3630), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3631 (.OUT (nx3630), .A (U_analog_control_int_cal_pulse_2), .B (
         nx2905), .C (U_analog_control_int_cal_pulse_3), .D (nx2907)) ;
    Nor4 ix8871 (.OUT (nx8870), .A (U_analog_control_int_cal_pulse_0), .B (
         U_analog_control_int_cal_pulse_1), .C (U_analog_control_int_cal_pulse_2
         ), .D (nx8869)) ;
    AOI22 ix8873 (.OUT (nx8872), .A (cd1_data_12), .B (nx9574), .C (cd0_data_28)
          , .D (nx9578)) ;
    Nor4 ix8875 (.OUT (nx8874), .A (U_analog_control_int_cal_pulse_0), .B (
         U_analog_control_int_cal_pulse_1), .C (nx8866), .D (
         U_analog_control_int_cal_pulse_3)) ;
    Nor4 ix8877 (.OUT (nx8876), .A (U_analog_control_int_cal_pulse_0), .B (
         nx8863), .C (U_analog_control_int_cal_pulse_2), .D (
         U_analog_control_int_cal_pulse_3)) ;
    DFFC U_analog_control_reg_cal_dly_11 (.Q (U_analog_control_cal_dly_11), .QB (
         \$dummy [340]), .D (nx3902), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3903 (.OUT (nx3902), .A (nx8882), .B (nx8884)) ;
    AOI22 ix8883 (.OUT (nx8882), .A (cd0_data_11), .B (nx9566), .C (cd1_data_27)
          , .D (nx9570)) ;
    AOI22 ix8885 (.OUT (nx8884), .A (cd1_data_11), .B (nx9574), .C (cd0_data_27)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_10 (.Q (U_analog_control_cal_dly_10), .QB (
         \$dummy [341]), .D (nx3938), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3939 (.OUT (nx3938), .A (nx8891), .B (nx8893)) ;
    AOI22 ix8892 (.OUT (nx8891), .A (cd0_data_10), .B (nx9566), .C (cd1_data_26)
          , .D (nx9570)) ;
    AOI22 ix8894 (.OUT (nx8893), .A (cd1_data_10), .B (nx9574), .C (cd0_data_26)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_9 (.Q (U_analog_control_cal_dly_9), .QB (
         \$dummy [342]), .D (nx3966), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3967 (.OUT (nx3966), .A (nx8899), .B (nx8901)) ;
    AOI22 ix8900 (.OUT (nx8899), .A (cd0_data_9), .B (nx9566), .C (cd1_data_25)
          , .D (nx9570)) ;
    AOI22 ix8902 (.OUT (nx8901), .A (cd1_data_9), .B (nx9574), .C (cd0_data_25)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_8 (.Q (U_analog_control_cal_dly_8), .QB (
         \$dummy [343]), .D (nx4000), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4001 (.OUT (nx4000), .A (nx8907), .B (nx8909)) ;
    AOI22 ix8908 (.OUT (nx8907), .A (cd0_data_8), .B (nx9566), .C (cd1_data_24)
          , .D (nx9570)) ;
    AOI22 ix8910 (.OUT (nx8909), .A (cd1_data_8), .B (nx9574), .C (cd0_data_24)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_7 (.Q (U_analog_control_cal_dly_7), .QB (
         \$dummy [344]), .D (nx4028), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4029 (.OUT (nx4028), .A (nx8915), .B (nx8917)) ;
    AOI22 ix8916 (.OUT (nx8915), .A (cd0_data_7), .B (nx9566), .C (cd1_data_23)
          , .D (nx9570)) ;
    AOI22 ix8918 (.OUT (nx8917), .A (cd1_data_7), .B (nx9574), .C (cd0_data_23)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_6 (.Q (U_analog_control_cal_dly_6), .QB (
         \$dummy [345]), .D (nx4066), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4067 (.OUT (nx4066), .A (nx8926), .B (nx8928)) ;
    AOI22 ix8927 (.OUT (nx8926), .A (cd0_data_6), .B (nx9566), .C (cd1_data_22)
          , .D (nx9570)) ;
    AOI22 ix8929 (.OUT (nx8928), .A (cd1_data_6), .B (nx9574), .C (cd0_data_22)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_5 (.Q (U_analog_control_cal_dly_5), .QB (
         \$dummy [346]), .D (nx4094), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4095 (.OUT (nx4094), .A (nx8935), .B (nx8937)) ;
    AOI22 ix8936 (.OUT (nx8935), .A (cd0_data_5), .B (nx9566), .C (cd1_data_21)
          , .D (nx9570)) ;
    AOI22 ix8938 (.OUT (nx8937), .A (cd1_data_5), .B (nx9574), .C (cd0_data_21)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_0 (.Q (U_analog_control_cal_dly_0), .QB (
         \$dummy [347]), .D (nx4128), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4129 (.OUT (nx4128), .A (nx8944), .B (nx8946)) ;
    AOI22 ix8945 (.OUT (nx8944), .A (cd0_data_0), .B (nx9566), .C (cd1_data_16)
          , .D (nx9570)) ;
    AOI22 ix8947 (.OUT (nx8946), .A (cd1_data_0), .B (nx9574), .C (cd0_data_16)
          , .D (nx9578)) ;
    DFFC U_analog_control_reg_cal_dly_4 (.Q (U_analog_control_cal_dly_4), .QB (
         \$dummy [348]), .D (nx4156), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4157 (.OUT (nx4156), .A (nx8953), .B (nx8955)) ;
    AOI22 ix8954 (.OUT (nx8953), .A (cd0_data_4), .B (nx9568), .C (cd1_data_20)
          , .D (nx9572)) ;
    AOI22 ix8956 (.OUT (nx8955), .A (cd1_data_4), .B (nx9576), .C (cd0_data_20)
          , .D (nx9580)) ;
    DFFC U_analog_control_reg_cal_dly_1 (.Q (U_analog_control_cal_dly_1), .QB (
         \$dummy [349]), .D (nx4192), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4193 (.OUT (nx4192), .A (nx8962), .B (nx8964)) ;
    AOI22 ix8963 (.OUT (nx8962), .A (cd0_data_1), .B (nx9568), .C (cd1_data_17)
          , .D (nx9572)) ;
    AOI22 ix8965 (.OUT (nx8964), .A (cd1_data_1), .B (nx9576), .C (cd0_data_17)
          , .D (nx9580)) ;
    DFFC U_analog_control_reg_cal_dly_3 (.Q (U_analog_control_cal_dly_3), .QB (
         \$dummy [350]), .D (nx4220), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4221 (.OUT (nx4220), .A (nx8970), .B (nx8972)) ;
    AOI22 ix8971 (.OUT (nx8970), .A (cd0_data_3), .B (nx9568), .C (cd1_data_19)
          , .D (nx9572)) ;
    AOI22 ix8973 (.OUT (nx8972), .A (cd1_data_3), .B (nx9576), .C (cd0_data_19)
          , .D (nx9580)) ;
    DFFC U_analog_control_reg_cal_dly_2 (.Q (U_analog_control_cal_dly_2), .QB (
         \$dummy [351]), .D (nx4248), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4249 (.OUT (nx4248), .A (nx8978), .B (nx8980)) ;
    AOI22 ix8979 (.OUT (nx8978), .A (cd0_data_2), .B (nx9568), .C (cd1_data_18)
          , .D (nx9572)) ;
    AOI22 ix8981 (.OUT (nx8980), .A (cd1_data_2), .B (nx9576), .C (cd0_data_18)
          , .D (nx9580)) ;
    Nand4 ix8998 (.OUT (nx8997), .A (nx8999), .B (nx9001), .C (nx9003), .D (
          nx9005)) ;
    Xnor2 ix9014 (.out (nx9013), .A (U_analog_control_cal_cnt_2), .B (
          U_analog_control_cal_dly_2)) ;
    DFFC U_analog_control_reg_cal_en (.Q (\$dummy [352]), .QB (nx9017), .D (
         nx4408), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4409 (.OUT (nx4408), .A (nx9020), .B (nx9022)) ;
    AOI22 ix9021 (.OUT (nx9020), .A (cd0_data_15), .B (nx9568), .C (cd1_data_31)
          , .D (nx9572)) ;
    AOI22 ix9023 (.OUT (nx9022), .A (cd1_data_15), .B (nx9576), .C (cd0_data_31)
          , .D (nx9580)) ;
    DFFC U_analog_control_reg_int_cal_strobe (.Q (cal_strobe), .QB (nx9024), .D (
         nx4418), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFP U_analog_control_reg_trig_inh (.Q (trig_inh), .QB (\$dummy [353]), .D (
         nx6319), .CLK (sysclk), .PRB (int_reset_l)) ;
    Nand2 ix6320 (.OUT (nx6319), .A (nx9028), .B (nx10634)) ;
    Nand2 ix9029 (.OUT (nx9028), .A (trig_inh), .B (nx9030)) ;
    AOI22 ix9031 (.OUT (nx9030), .A (nx5528), .B (nx5622), .C (nx9114), .D (
          nx6671)) ;
    Nor4 ix5529 (.OUT (nx5528), .A (nx9033), .B (nx9043), .C (nx9053), .D (
         nx9063)) ;
    Nand4 ix9034 (.OUT (nx9033), .A (nx9035), .B (nx9037), .C (nx9039), .D (
          nx9041)) ;
    Xnor2 ix9036 (.out (nx9035), .A (U_analog_control_mst_cnt_31), .B (
          tc3_data_31)) ;
    Xnor2 ix9038 (.out (nx9037), .A (U_analog_control_mst_cnt_30), .B (
          tc3_data_30)) ;
    Xnor2 ix9042 (.out (nx9041), .A (U_analog_control_mst_cnt_28), .B (
          tc3_data_28)) ;
    Nand4 ix9044 (.OUT (nx9043), .A (nx9045), .B (nx9047), .C (nx9049), .D (
          nx9051)) ;
    Xnor2 ix9048 (.out (nx9047), .A (U_analog_control_mst_cnt_26), .B (
          tc3_data_26)) ;
    Xnor2 ix9052 (.out (nx9051), .A (U_analog_control_mst_cnt_24), .B (
          tc3_data_24)) ;
    Nand4 ix9054 (.OUT (nx9053), .A (nx9055), .B (nx9057), .C (nx9059), .D (
          nx9061)) ;
    Xnor2 ix9058 (.out (nx9057), .A (U_analog_control_mst_cnt_22), .B (
          tc3_data_22)) ;
    Xnor2 ix9062 (.out (nx9061), .A (U_analog_control_mst_cnt_20), .B (
          tc3_data_20)) ;
    Nand4 ix9064 (.OUT (nx9063), .A (nx9065), .B (nx9067), .C (nx9069), .D (
          nx9071)) ;
    Xnor2 ix9068 (.out (nx9067), .A (U_analog_control_mst_cnt_18), .B (
          tc3_data_18)) ;
    Xnor2 ix9072 (.out (nx9071), .A (U_analog_control_mst_cnt_16), .B (
          tc3_data_16)) ;
    Nor4 ix5623 (.OUT (nx5622), .A (nx9074), .B (nx9084), .C (nx9094), .D (
         nx9104)) ;
    Nand4 ix9075 (.OUT (nx9074), .A (nx9076), .B (nx9078), .C (nx9080), .D (
          nx9082)) ;
    Xnor2 ix9079 (.out (nx9078), .A (nx10630), .B (tc3_data_14)) ;
    Xnor2 ix9083 (.out (nx9082), .A (nx10636), .B (tc3_data_12)) ;
    Nand4 ix9085 (.OUT (nx9084), .A (nx9086), .B (nx9088), .C (nx9090), .D (
          nx9092)) ;
    Xnor2 ix9089 (.out (nx9088), .A (nx10642), .B (tc3_data_10)) ;
    Xnor2 ix9093 (.out (nx9092), .A (nx10644), .B (tc3_data_8)) ;
    Nand4 ix9095 (.OUT (nx9094), .A (nx9096), .B (nx9098), .C (nx9100), .D (
          nx9102)) ;
    Xnor2 ix9099 (.out (nx9098), .A (nx10640), .B (tc3_data_6)) ;
    Xnor2 ix9103 (.out (nx9102), .A (nx10650), .B (tc3_data_4)) ;
    Nand4 ix9105 (.OUT (nx9104), .A (nx9106), .B (nx9108), .C (nx9110), .D (
          nx9112)) ;
    Xnor2 ix9109 (.out (nx9108), .A (nx10638), .B (tc3_data_2)) ;
    Nor2 ix9115 (.OUT (nx9114), .A (U_analog_control_mst_state_0), .B (
         U_analog_control_mst_state_1)) ;
    DFFP U_analog_control_reg_thresh_off (.Q (thresh_off), .QB (\$dummy [354]), 
         .D (nx6309), .CLK (sysclk), .PRB (int_reset_l)) ;
    Nand2 ix6310 (.OUT (nx6309), .A (nx9119), .B (nx10634)) ;
    Nand2 ix9120 (.OUT (nx9119), .A (thresh_off), .B (nx9121)) ;
    Nor2 ix9122 (.OUT (nx9121), .A (nx5426), .B (nx9512)) ;
    Nor4 ix5427 (.OUT (nx5426), .A (nx9124), .B (nx9134), .C (nx9144), .D (
         nx9154)) ;
    Nand4 ix9125 (.OUT (nx9124), .A (nx9126), .B (nx5338), .C (nx9130), .D (
          nx9132)) ;
    Xnor2 ix9127 (.out (nx9126), .A (nx10630), .B (tc2_data_30)) ;
    Nor2 ix5339 (.OUT (nx5338), .A (nx4906), .B (nx5332)) ;
    Xnor2 ix9133 (.out (nx9132), .A (nx10636), .B (tc2_data_28)) ;
    Nand4 ix9135 (.OUT (nx9134), .A (nx9136), .B (nx9138), .C (nx9140), .D (
          nx9142)) ;
    Xnor2 ix9139 (.out (nx9138), .A (nx10642), .B (tc2_data_26)) ;
    Xnor2 ix9143 (.out (nx9142), .A (nx10644), .B (tc2_data_24)) ;
    Nand4 ix9145 (.OUT (nx9144), .A (nx9146), .B (nx9148), .C (nx9150), .D (
          nx9152)) ;
    Xnor2 ix9149 (.out (nx9148), .A (nx10640), .B (tc2_data_22)) ;
    Xnor2 ix9153 (.out (nx9152), .A (nx10650), .B (tc2_data_20)) ;
    Nand4 ix9155 (.OUT (nx9154), .A (nx9156), .B (nx9158), .C (nx9160), .D (
          nx9162)) ;
    Xnor2 ix9159 (.out (nx9158), .A (nx10638), .B (tc2_data_18)) ;
    DFFP U_analog_control_reg_offset_null (.Q (offset_null), .QB (\$dummy [355])
         , .D (nx6299), .CLK (sysclk), .PRB (int_reset_l)) ;
    Nand2 ix6300 (.OUT (nx6299), .A (nx9167), .B (nx10634)) ;
    Nand2 ix9168 (.OUT (nx9167), .A (offset_null), .B (nx9169)) ;
    Nor2 ix9170 (.OUT (nx9169), .A (nx5318), .B (nx9512)) ;
    Nor4 ix5319 (.OUT (nx5318), .A (nx9172), .B (nx9182), .C (nx9192), .D (
         nx9202)) ;
    Nand4 ix9173 (.OUT (nx9172), .A (nx9174), .B (nx5230), .C (nx9178), .D (
          nx9180)) ;
    Xnor2 ix9175 (.out (nx9174), .A (nx10630), .B (tc1_data_14)) ;
    Nor2 ix5231 (.OUT (nx5230), .A (nx4906), .B (nx5224)) ;
    Xnor2 ix9181 (.out (nx9180), .A (nx10636), .B (tc1_data_12)) ;
    Nand4 ix9183 (.OUT (nx9182), .A (nx9184), .B (nx9186), .C (nx9188), .D (
          nx9190)) ;
    Xnor2 ix9187 (.out (nx9186), .A (nx10642), .B (tc1_data_10)) ;
    Xnor2 ix9191 (.out (nx9190), .A (nx10644), .B (tc1_data_8)) ;
    Nand4 ix9193 (.OUT (nx9192), .A (nx9194), .B (nx9196), .C (nx9198), .D (
          nx9200)) ;
    Xnor2 ix9197 (.out (nx9196), .A (nx10640), .B (tc1_data_6)) ;
    Xnor2 ix9201 (.out (nx9200), .A (nx10650), .B (tc1_data_4)) ;
    Nand4 ix9203 (.OUT (nx9202), .A (nx9204), .B (nx9206), .C (nx9208), .D (
          nx9210)) ;
    Xnor2 ix9207 (.out (nx9206), .A (nx10638), .B (tc1_data_2)) ;
    DFFP U_analog_control_reg_leakage_null (.Q (leakage_null), .QB (
         \$dummy [356]), .D (nx6289), .CLK (sysclk), .PRB (int_reset_l)) ;
    Nand2 ix6290 (.OUT (nx6289), .A (nx9215), .B (nx9265)) ;
    Nand2 ix9216 (.OUT (nx9215), .A (leakage_null), .B (nx9217)) ;
    Nor2 ix9218 (.OUT (nx9217), .A (nx5214), .B (nx4438)) ;
    Nor4 ix5215 (.OUT (nx5214), .A (nx9220), .B (nx9230), .C (nx9240), .D (
         nx9250)) ;
    Nand4 ix9221 (.OUT (nx9220), .A (nx9222), .B (nx5126), .C (nx9226), .D (
          nx9228)) ;
    Xnor2 ix9223 (.out (nx9222), .A (nx10630), .B (tc1_data_30)) ;
    Nor2 ix5127 (.OUT (nx5126), .A (nx4906), .B (nx5120)) ;
    Xnor2 ix9229 (.out (nx9228), .A (nx10636), .B (tc1_data_28)) ;
    Nand4 ix9231 (.OUT (nx9230), .A (nx9232), .B (nx9234), .C (nx9236), .D (
          nx9238)) ;
    Xnor2 ix9235 (.out (nx9234), .A (nx10642), .B (tc1_data_26)) ;
    Xnor2 ix9239 (.out (nx9238), .A (nx10644), .B (tc1_data_24)) ;
    Nand4 ix9241 (.OUT (nx9240), .A (nx9242), .B (nx9244), .C (nx9246), .D (
          nx9248)) ;
    Xnor2 ix9245 (.out (nx9244), .A (nx10640), .B (tc1_data_22)) ;
    Xnor2 ix9249 (.out (nx9248), .A (nx10650), .B (tc1_data_20)) ;
    Nand4 ix9251 (.OUT (nx9250), .A (nx9252), .B (nx9254), .C (nx9256), .D (
          nx9258)) ;
    Xnor2 ix9255 (.out (nx9254), .A (nx10638), .B (tc1_data_18)) ;
    AOI22 ix4435 (.OUT (nx4434), .A (nx6671), .B (U_analog_control_mst_state_0)
          , .C (nx9263), .D (nx8274)) ;
    Nand2 ix6129 (.OUT (reset_load), .A (nx9270), .B (nx9278)) ;
    DFFC U_readout_control_reg_int_load_shift (.Q (\$dummy [357]), .QB (nx9270)
         , .D (nx6122), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix6123 (.OUT (nx6122), .A (nx2456), .B (nx9273)) ;
    Mux2 ix9274 (.OUT (nx9273), .A (nx9270), .B (test_mode), .SEL (nx6108)) ;
    Nand4 ix6109 (.OUT (nx6108), .A (nx2866), .B (nx6573), .C (nx6543), .D (
          nx9276)) ;
    Nor4 ix9277 (.OUT (nx9276), .A (nx6567), .B (U_readout_control_st_cnt_6), .C (
         U_readout_control_st_cnt_7), .D (U_readout_control_st_cnt_8)) ;
    AO22 ix6340 (.OUT (nx6339), .A (nx10634), .B (nx5982), .C (analog_reset), .D (
         nx9323)) ;
    Nor4 ix5983 (.OUT (nx5982), .A (nx9282), .B (nx9292), .C (nx9302), .D (
         nx9312)) ;
    Nand4 ix9293 (.OUT (nx9292), .A (nx9294), .B (nx9296), .C (nx9298), .D (
          nx9300)) ;
    Xnor2 ix9297 (.out (nx9296), .A (nx10643), .B (tc0_data_10)) ;
    Xnor2 ix9301 (.out (nx9300), .A (nx10645), .B (tc0_data_8)) ;
    Nand4 ix9303 (.OUT (nx9302), .A (nx9304), .B (nx9306), .C (nx9308), .D (
          nx9310)) ;
    Xnor2 ix9307 (.out (nx9306), .A (nx10641), .B (tc0_data_6)) ;
    Xnor2 ix9311 (.out (nx9310), .A (nx10651), .B (tc0_data_4)) ;
    Nand4 ix9313 (.OUT (nx9312), .A (nx9314), .B (nx9316), .C (nx9318), .D (
          nx9320)) ;
    Xnor2 ix9317 (.out (nx9316), .A (nx10639), .B (tc0_data_2)) ;
    DFFC U_analog_control_reg_analog_reset (.Q (analog_reset), .QB (nx9278), .D (
         nx6339), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix9324 (.OUT (nx9323), .A (nx6080), .B (nx5982), .C (nx9514)) ;
    Nor4 ix6081 (.OUT (nx6080), .A (nx9326), .B (nx9336), .C (nx9346), .D (
         nx9356)) ;
    Nand4 ix9327 (.OUT (nx9326), .A (nx9328), .B (nx5992), .C (nx9332), .D (
          nx9334)) ;
    Xnor2 ix9329 (.out (nx9328), .A (nx10630), .B (tc0_data_30)) ;
    Nor2 ix5993 (.OUT (nx5992), .A (nx4906), .B (nx5986)) ;
    Xnor2 ix9335 (.out (nx9334), .A (nx10637), .B (tc0_data_28)) ;
    Nand4 ix9337 (.OUT (nx9336), .A (nx9338), .B (nx9340), .C (nx9342), .D (
          nx9344)) ;
    Xnor2 ix9341 (.out (nx9340), .A (nx10643), .B (tc0_data_26)) ;
    Xnor2 ix9345 (.out (nx9344), .A (nx10645), .B (tc0_data_24)) ;
    Nand4 ix9347 (.OUT (nx9346), .A (nx9348), .B (nx9350), .C (nx9352), .D (
          nx9354)) ;
    Xnor2 ix9351 (.out (nx9350), .A (nx10641), .B (tc0_data_22)) ;
    Xnor2 ix9355 (.out (nx9354), .A (nx10651), .B (tc0_data_20)) ;
    Nand4 ix9357 (.OUT (nx9356), .A (nx9358), .B (nx9360), .C (nx9362), .D (
          nx9364)) ;
    Xnor2 ix9361 (.out (nx9360), .A (nx10639), .B (tc0_data_18)) ;
    DFFC U_analog_control_reg_pwr_up_acq (.Q (pwr_up_acq), .QB (\$dummy [358]), 
         .D (nx6269), .CLK (sysclk), .CLR (int_reset_l)) ;
    Xnor2 ix9379 (.out (nx9378), .A (nx10637), .B (tc4_data_28)) ;
    Mux2 ix3543 (.OUT (reg_clock), .A (nx3522), .B (bunch_clock), .SEL (nx3310)
         ) ;
    Nor2 ix3523 (.OUT (nx3522), .A (sysclk), .B (nx9398)) ;
    Nor2 ix9399 (.OUT (nx9398), .A (nx3516), .B (nx3488)) ;
    DFFC U_analog_control_reg_int_bunch_clock (.Q (bunch_clock), .QB (
         \$dummy [359]), .D (nx3532), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3533 (.OUT (nx3532), .A (nx2881), .B (nx6701), .C (
         U_analog_control_sub_cnt_0)) ;
    Nand2 ix3311 (.OUT (nx3310), .A (nx8307), .B (nx6983)) ;
    DFF reg_out_reset_l (.Q (out_reset_l), .QB (\$dummy [360]), .D (nx5878), .CLK (
        sysclk)) ;
    Nor2 ix5879 (.OUT (nx5878), .A (reset), .B (cmd_reset)) ;
    DFFC U_command_control_reg_cmd_reset (.Q (cmd_reset), .QB (\$dummy [361]), .D (
         nx6329), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6330 (.OUT (nx6329), .A (nx2851), .B (cmd_reset), .SEL (nx5868)) ;
    Nand2 ix5869 (.OUT (nx5868), .A (nx9409), .B (nx2851)) ;
    Nand2 ix9410 (.OUT (nx9409), .A (nx6637), .B (nx7583)) ;
    DFFC reg_data_out (.Q (data_out), .QB (\$dummy [362]), .D (nx5854), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix5855 (.OUT (nx5854), .A (nx9415), .B (nx9460)) ;
    DFFC U_readout_control_reg_sample_data_out (.Q (\$dummy [363]), .QB (nx9415)
         , .D (nx5848), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix5849 (.OUT (nx5848), .A (nx9418), .B (nx6497), .C (nx9455), .D (
          nx9457)) ;
    Nand2 ix9419 (.OUT (nx9418), .A (U_readout_control_int_par), .B (nx5842)) ;
    DFFC U_readout_control_reg_int_par (.Q (U_readout_control_int_par), .QB (
         \$dummy [364]), .D (nx5836), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix5837 (.OUT (nx5836), .A (nx5818), .B (nx5824), .C (nx5828), .D (
         nx5832)) ;
    Nand2 ix5819 (.OUT (nx5818), .A (nx6521), .B (nx9423)) ;
    Nor2 ix9424 (.OUT (nx9423), .A (nx6541), .B (U_readout_control_st_cnt_1)) ;
    Nor2 ix5825 (.OUT (nx5824), .A (nx2478), .B (nx9426)) ;
    Xor2 ix5829 (.out (nx5828), .A (U_readout_control_int_par), .B (nx5808)) ;
    Nand2 ix5809 (.OUT (nx5808), .A (nx9430), .B (nx9440)) ;
    AOI22 ix9431 (.OUT (nx9430), .A (nx6545), .B (nx5800), .C (nx6543), .D (
          nx5772)) ;
    Nand2 ix5801 (.OUT (nx5800), .A (nx9433), .B (nx9437)) ;
    AOI22 ix9434 (.OUT (nx9433), .A (U_readout_control_row_cnt_4), .B (nx9423), 
          .C (U_readout_control_st_cnt_3), .D (nx5790)) ;
    AO22 ix5791 (.OUT (nx5790), .A (U_readout_control_row_cnt_3), .B (nx6612), .C (
         nx6541), .D (nx5780)) ;
    Nor2 ix5781 (.OUT (nx5780), .A (nx7333), .B (nx6529)) ;
    Nand2 ix9438 (.OUT (nx9437), .A (U_readout_control_typ_cnt_1), .B (nx2866)
          ) ;
    Nand2 ix9441 (.OUT (nx9440), .A (nx6547), .B (nx5760)) ;
    Nand2 ix5761 (.OUT (nx5760), .A (nx9443), .B (nx9445)) ;
    AOI22 ix9444 (.OUT (nx9443), .A (nx6545), .B (U_readout_control_st_cnt_0), .C (
          U_readout_control_row_cnt_2), .D (nx2866)) ;
    AOI22 ix9446 (.OUT (nx9445), .A (U_readout_control_row_cnt_0), .B (nx9423), 
          .C (U_readout_control_st_cnt_2), .D (nx5742)) ;
    Nand2 ix5743 (.OUT (nx5742), .A (nx9448), .B (nx2356)) ;
    Nand2 ix9449 (.OUT (nx9448), .A (U_readout_control_row_cnt_1), .B (nx6541)
          ) ;
    Nor2 ix5833 (.OUT (nx5832), .A (nx2410), .B (nx6537)) ;
    Nand3 ix2411 (.OUT (nx2410), .A (U_readout_control_rd_state_1), .B (nx6508)
          , .C (U_readout_control_rd_state_0)) ;
    Nand2 ix5843 (.OUT (nx5842), .A (nx6533), .B (nx7408)) ;
    Nand3 ix9456 (.OUT (nx9455), .A (nx5808), .B (nx6535), .C (nx2416)) ;
    Nand3 ix9458 (.OUT (nx9457), .A (nx5728), .B (int_rdback), .C (nx7410)) ;
    Nand2 ix5729 (.OUT (nx5728), .A (nx6521), .B (nx9423)) ;
    DFFC U_command_control_reg_resp_data_out (.Q (\$dummy [365]), .QB (nx9460), 
         .D (nx1990), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix4869 (.OUT (nx2962), .A (nx8636)) ;
    Inv ix4813 (.OUT (nx2958), .A (nx8601)) ;
    Inv ix4729 (.OUT (nx2949), .A (nx8545)) ;
    Inv ix4701 (.OUT (nx2946), .A (nx8525)) ;
    Inv ix4673 (.OUT (nx2944), .A (nx8507)) ;
    Inv ix4633 (.OUT (nx4632), .A (nx8493)) ;
    Inv ix4615 (.OUT (nx2941), .A (nx8471)) ;
    Inv ix4587 (.OUT (nx2937), .A (nx8465)) ;
    Inv ix4559 (.OUT (nx2934), .A (nx8459)) ;
    Inv ix4503 (.OUT (nx2929), .A (nx8447)) ;
    Inv ix4475 (.OUT (nx2927), .A (nx8441)) ;
    Inv ix4439 (.OUT (nx4438), .A (nx9265)) ;
    Inv ix9264 (.OUT (nx9263), .A (nx4428)) ;
    Inv ix3801 (.OUT (nx2918), .A (nx8817)) ;
    Inv ix3737 (.OUT (nx2913), .A (nx8809)) ;
    Inv ix4353 (.OUT (nx2907), .A (nx8839)) ;
    Inv ix4349 (.OUT (nx2905), .A (nx8841)) ;
    Inv ix8312 (.OUT (nx8311), .A (nx3488)) ;
    Inv ix8264 (.OUT (nx8263), .A (nx3324)) ;
    Inv ix3309 (.OUT (nx3308), .A (nx8307)) ;
    Inv ix3173 (.OUT (nx3172), .A (nx7133)) ;
    Inv ix3027 (.OUT (nx2897), .A (nx6781)) ;
    Inv ix2995 (.OUT (nx2895), .A (nx6763)) ;
    Inv ix2963 (.OUT (nx2893), .A (nx6750)) ;
    Inv ix2931 (.OUT (nx2889), .A (nx7119)) ;
    Inv ix6719 (.OUT (nx6718), .A (nx2850)) ;
    Inv ix6721 (.OUT (nx6720), .A (nx2885)) ;
    Inv ix2795 (.OUT (nx2794), .A (nx7159)) ;
    Inv ix2899 (.OUT (nx2882), .A (nx7111)) ;
    Inv ix6984 (.OUT (nx6983), .A (nx2881)) ;
    Inv ix2715 (.OUT (nx2714), .A (nx8280)) ;
    Inv ix8275 (.OUT (nx8274), .A (nx2668)) ;
    Inv ix2531 (.OUT (nx2879), .A (nx7418)) ;
    Inv ix2487 (.OUT (nx2486), .A (nx7412)) ;
    Inv ix2483 (.OUT (nx2482), .A (nx7408)) ;
    Inv ix7411 (.OUT (nx7410), .A (nx2478)) ;
    Inv ix6500 (.OUT (nx6499), .A (nx2456)) ;
    Inv ix2417 (.OUT (nx2416), .A (nx6537)) ;
    Inv ix6536 (.OUT (nx6535), .A (nx2410)) ;
    Inv ix2447 (.OUT (nx2875), .A (nx6606)) ;
    Inv ix6522 (.OUT (nx6521), .A (nx2378)) ;
    Inv ix7424 (.OUT (nx7423), .A (nx2366)) ;
    Inv ix2357 (.OUT (nx2356), .A (nx6612)) ;
    Inv ix2307 (.OUT (nx2873), .A (nx6594)) ;
    Inv ix2275 (.OUT (nx2871), .A (nx6580)) ;
    Inv ix2243 (.OUT (nx2867), .A (nx6558)) ;
    Inv ix6554 (.OUT (nx6553), .A (nx2866)) ;
    Inv ix7290 (.OUT (nx7289), .A (nx2220)) ;
    Inv ix2185 (.OUT (nx2864), .A (nx7369)) ;
    Inv ix2143 (.OUT (nx2859), .A (nx7297)) ;
    Inv ix7330 (.OUT (nx7329), .A (nx2070)) ;
    Inv ix6507 (.OUT (nx6506), .A (nx2068)) ;
    Inv ix7328 (.OUT (nx7327), .A (nx2853)) ;
    Inv ix2045 (.OUT (nx2044), .A (nx9114)) ;
    Inv ix7451 (.OUT (nx7450), .A (nx796)) ;
    Inv ix633 (.OUT (nx632), .A (nx7287)) ;
    Inv ix471 (.OUT (nx470), .A (nx7583)) ;
    Inv ix2013 (.OUT (nx2847), .A (nx7430)) ;
    Inv ix245 (.OUT (nx244), .A (nx7473)) ;
    Inv ix229 (.OUT (nx2846), .A (nx6408)) ;
    Inv ix197 (.OUT (nx2843), .A (nx6467)) ;
    Inv ix6436 (.OUT (nx6435), .A (nx2841)) ;
    Inv ix127 (.OUT (nx126), .A (nx6360)) ;
    Inv ix6367 (.OUT (nx6366), .A (nx2837)) ;
    Inv ix6472 (.OUT (nx6471), .A (nx2836)) ;
    Inv ix83 (.OUT (nx82), .A (nx6453)) ;
    Inv ix77 (.OUT (nx76), .A (nx6415)) ;
    Inv ix63 (.OUT (nx62), .A (nx6450)) ;
    Inv ix7469 (.OUT (nx7468), .A (nx42)) ;
    Inv ix3 (.OUT (nx2), .A (nx6429)) ;
    Inv ix6651 (.OUT (nx6650), .A (nx2829)) ;
    Inv ix6823 (.OUT (nx6822), .A (nx2827)) ;
    Inv ix6917 (.OUT (nx6916), .A (reg_wr_ena)) ;
    Buf1 ix9467 (.OUT (nx9468), .A (nx2849)) ;
    Buf1 ix9469 (.OUT (nx9470), .A (nx2849)) ;
    Buf1 ix9471 (.OUT (nx9472), .A (nx2849)) ;
    Buf1 ix9473 (.OUT (nx9474), .A (nx2849)) ;
    Buf1 ix9475 (.OUT (nx9476), .A (nx1248)) ;
    Buf1 ix9477 (.OUT (nx9478), .A (nx1248)) ;
    Buf1 ix9479 (.OUT (nx9480), .A (nx1248)) ;
    Buf1 ix9481 (.OUT (nx9482), .A (nx1248)) ;
    Buf1 ix9483 (.OUT (nx9484), .A (nx1690)) ;
    Buf1 ix9485 (.OUT (nx9486), .A (nx1690)) ;
    Buf1 ix9487 (.OUT (nx9488), .A (nx1690)) ;
    Buf1 ix9489 (.OUT (nx9490), .A (nx1690)) ;
    Buf1 ix9491 (.OUT (nx9492), .A (nx2856)) ;
    Buf1 ix9493 (.OUT (nx9494), .A (nx2856)) ;
    Inv ix9503 (.OUT (nx9504), .A (nx2837)) ;
    Inv ix9505 (.OUT (nx9506), .A (nx10634)) ;
    Inv ix9507 (.OUT (nx9508), .A (nx10634)) ;
    Inv ix9513 (.OUT (nx9514), .A (nx10634)) ;
    Buf1 ix9515 (.OUT (nx9516), .A (nx7581)) ;
    Buf1 ix9517 (.OUT (nx9518), .A (nx7581)) ;
    Buf1 ix9519 (.OUT (nx9520), .A (nx7581)) ;
    Buf1 ix9521 (.OUT (nx9522), .A (nx7581)) ;
    Buf1 ix9523 (.OUT (nx9524), .A (nx7686)) ;
    Buf1 ix9525 (.OUT (nx9526), .A (nx7686)) ;
    Buf1 ix9527 (.OUT (nx9528), .A (nx7686)) ;
    Buf1 ix9529 (.OUT (nx9530), .A (nx7686)) ;
    Buf1 ix9531 (.OUT (nx9532), .A (nx7792)) ;
    Buf1 ix9533 (.OUT (nx9534), .A (nx7792)) ;
    Buf1 ix9535 (.OUT (nx9536), .A (nx7792)) ;
    Buf1 ix9537 (.OUT (nx9538), .A (nx7792)) ;
    Buf1 ix9539 (.OUT (nx9540), .A (nx7893)) ;
    Buf1 ix9541 (.OUT (nx9542), .A (nx7893)) ;
    Buf1 ix9543 (.OUT (nx9544), .A (nx7893)) ;
    Buf1 ix9545 (.OUT (nx9546), .A (nx7893)) ;
    Buf1 ix9547 (.OUT (nx9548), .A (nx8003)) ;
    Buf1 ix9549 (.OUT (nx9550), .A (nx8003)) ;
    Buf1 ix9551 (.OUT (nx9552), .A (nx8003)) ;
    Buf1 ix9553 (.OUT (nx9554), .A (nx8003)) ;
    Buf1 ix9555 (.OUT (nx9556), .A (nx8108)) ;
    Buf1 ix9557 (.OUT (nx9558), .A (nx8108)) ;
    Buf1 ix9559 (.OUT (nx9560), .A (nx8108)) ;
    Buf1 ix9561 (.OUT (nx9562), .A (nx8108)) ;
    Buf1 ix9565 (.OUT (nx9566), .A (nx8833)) ;
    Buf1 ix9567 (.OUT (nx9568), .A (nx8833)) ;
    Buf1 ix9569 (.OUT (nx9570), .A (nx8870)) ;
    Buf1 ix9571 (.OUT (nx9572), .A (nx8870)) ;
    Buf1 ix9573 (.OUT (nx9574), .A (nx8874)) ;
    Buf1 ix9575 (.OUT (nx9576), .A (nx8874)) ;
    Buf1 ix9577 (.OUT (nx9578), .A (nx8876)) ;
    Buf1 ix9579 (.OUT (nx9580), .A (nx8876)) ;
    Xnor2 ix6406 (.out (nx6405), .A (nx6402), .B (nx6408)) ;
    Xor2 ix6600 (.out (nx6599), .A (nx6596), .B (nx2310)) ;
    Xor2 ix6829 (.out (nx6828), .A (nx6727), .B (tc5_data_8)) ;
    Xor2 ix6949 (.out (nx6948), .A (nx6707), .B (tc5_data_9)) ;
    Xor2 ix6951 (.out (nx6950), .A (nx6701), .B (tc5_data_10)) ;
    Xor2 ix6954 (.out (nx6953), .A (nx6695), .B (tc5_data_11)) ;
    Xor2 ix6958 (.out (nx6957), .A (nx6689), .B (tc5_data_12)) ;
    Xor2 ix6960 (.out (nx6959), .A (nx6683), .B (tc5_data_13)) ;
    Xor2 ix6962 (.out (nx6961), .A (nx6743), .B (tc5_data_14)) ;
    Xor2 ix6964 (.out (nx6963), .A (nx6737), .B (tc5_data_15)) ;
    Xor2 ix6967 (.out (nx6966), .A (nx6731), .B (tc5_data_16)) ;
    Xor2 ix6969 (.out (nx6968), .A (nx6756), .B (tc5_data_17)) ;
    Xor2 ix6971 (.out (nx6970), .A (nx6765), .B (tc5_data_18)) ;
    Xor2 ix6973 (.out (nx6972), .A (nx6774), .B (tc5_data_19)) ;
    Xor2 ix6976 (.out (nx6975), .A (nx6785), .B (tc5_data_20)) ;
    Xor2 ix6978 (.out (nx6977), .A (nx6799), .B (tc5_data_21)) ;
    Xor2 ix6980 (.out (nx6979), .A (nx6803), .B (tc5_data_22)) ;
    Xor2 ix6982 (.out (nx6981), .A (nx6812), .B (tc5_data_23)) ;
    Xnor2 ix7096 (.out (nx2740), .A (nx6756), .B (tc4_data_6)) ;
    Xnor2 ix7098 (.out (nx2742), .A (nx6774), .B (tc4_data_8)) ;
    Xnor2 ix7100 (.out (nx2744), .A (nx6765), .B (tc4_data_7)) ;
    Xor2 ix7104 (.out (nx7103), .A (nx6731), .B (tc4_data_5)) ;
    Xor2 ix7106 (.out (nx7105), .A (nx6695), .B (tc4_data_0)) ;
    Xor2 ix7108 (.out (nx7107), .A (nx6737), .B (tc4_data_4)) ;
    Xor2 ix7110 (.out (nx7109), .A (nx6743), .B (tc4_data_3)) ;
    Xnor2 ix7116 (.out (nx2780), .A (nx6683), .B (tc4_data_2)) ;
    Xnor2 ix7118 (.out (nx2782), .A (nx6689), .B (tc4_data_1)) ;
    Xor2 ix7124 (.out (nx7123), .A (nx6683), .B (tc5_data_29)) ;
    Xor2 ix7126 (.out (nx7125), .A (nx6689), .B (tc5_data_28)) ;
    Xor2 ix7165 (.out (nx7164), .A (nx6812), .B (tc4_data_12)) ;
    Xor2 ix7167 (.out (nx7166), .A (nx6803), .B (tc4_data_11)) ;
    Xor2 ix7169 (.out (nx7168), .A (nx6799), .B (tc4_data_10)) ;
    Xor2 ix7171 (.out (nx7170), .A (nx6785), .B (tc4_data_9)) ;
    Xnor2 ix7431 (.out (nx7430), .A (nx6434), .B (nx7482)) ;
    Mux2 ix7511 (.OUT (nx7510), .A (nx7617), .B (nx7512), .SEL (nx6902)) ;
    Mux2 ix1115 (.OUT (nx1114), .A (tc2_data_0), .B (tc3_data_0), .SEL (nx6902)
         ) ;
    Mux2 ix785 (.OUT (nx784), .A (cd0_data_0), .B (cd1_data_0), .SEL (nx6902)) ;
    Xnor2 ix3341 (.out (nx3340), .A (nx6737), .B (tc5_data_7)) ;
    Xor2 ix8253 (.out (nx8252), .A (nx6743), .B (tc5_data_6)) ;
    Xor2 ix8255 (.out (nx8254), .A (nx6683), .B (tc5_data_5)) ;
    Xor2 ix8257 (.out (nx8256), .A (nx6689), .B (tc5_data_4)) ;
    Xor2 ix8259 (.out (nx8258), .A (nx6695), .B (tc5_data_3)) ;
    Xnor2 ix3377 (.out (nx3376), .A (nx6727), .B (tc5_data_0)) ;
    Xnor2 ix3379 (.out (nx3378), .A (nx6701), .B (tc5_data_2)) ;
    Xnor2 ix3381 (.out (nx3380), .A (nx6707), .B (tc5_data_1)) ;
    Nand3 ix3317 (.OUT (nx8337), .A (nx3172), .B (nx8243), .C (desel_all_cells)
          ) ;
    Xnor2 ix8273 (.out (nx2662), .A (nx6743), .B (tc5_data_30)) ;
    Xnor2 ix8277 (.out (nx2670), .A (nx6737), .B (tc5_data_31)) ;
    Xor2 ix8283 (.out (nx8282), .A (nx6695), .B (tc5_data_27)) ;
    Xor2 ix8285 (.out (nx8284), .A (nx6701), .B (tc5_data_26)) ;
    Xor2 ix8287 (.out (nx8286), .A (nx6707), .B (tc5_data_25)) ;
    Xor2 ix8289 (.out (nx8288), .A (nx6727), .B (tc5_data_24)) ;
    Xor2 ix8647 (.out (nx8646), .A (nx10658), .B (tc2_data_11)) ;
    Xor2 ix8651 (.out (nx8650), .A (nx10646), .B (tc2_data_9)) ;
    Xor2 ix8657 (.out (nx8656), .A (nx10652), .B (tc2_data_7)) ;
    Xor2 ix8661 (.out (nx8660), .A (nx10656), .B (tc2_data_5)) ;
    Xor2 ix8667 (.out (nx8666), .A (nx10654), .B (tc2_data_3)) ;
    Xor2 ix8671 (.out (nx8670), .A (nx8430), .B (tc2_data_1)) ;
    Xor2 ix8673 (.out (nx8672), .A (nx10648), .B (tc2_data_0)) ;
    Xnor2 ix8994 (.out (nx3694), .A (nx8827), .B (U_analog_control_cal_dly_12)
          ) ;
    Xnor2 ix8996 (.out (nx3908), .A (nx8712), .B (U_analog_control_cal_dly_11)
          ) ;
    Xor2 ix9000 (.out (nx8999), .A (nx8720), .B (U_analog_control_cal_dly_10)) ;
    Xor2 ix9002 (.out (nx9001), .A (nx8728), .B (U_analog_control_cal_dly_9)) ;
    Xor2 ix9004 (.out (nx9003), .A (nx8736), .B (U_analog_control_cal_dly_8)) ;
    Xor2 ix9006 (.out (nx9005), .A (nx8744), .B (U_analog_control_cal_dly_7)) ;
    Xor2 ix9040 (.out (nx9039), .A (nx8619), .B (tc3_data_29)) ;
    Xor2 ix9046 (.out (nx9045), .A (nx8599), .B (tc3_data_27)) ;
    Xor2 ix9050 (.out (nx9049), .A (nx8581), .B (tc3_data_25)) ;
    Xor2 ix9056 (.out (nx9055), .A (nx8561), .B (tc3_data_23)) ;
    Xor2 ix9060 (.out (nx9059), .A (nx8543), .B (tc3_data_21)) ;
    Xor2 ix9066 (.out (nx9065), .A (nx8523), .B (tc3_data_19)) ;
    Xor2 ix9070 (.out (nx9069), .A (nx8505), .B (tc3_data_17)) ;
    Xor2 ix9077 (.out (nx9076), .A (nx10632), .B (tc3_data_15)) ;
    Xor2 ix9081 (.out (nx9080), .A (nx10628), .B (tc3_data_13)) ;
    Xor2 ix9087 (.out (nx9086), .A (nx10658), .B (tc3_data_11)) ;
    Xor2 ix9091 (.out (nx9090), .A (nx10646), .B (tc3_data_9)) ;
    Xor2 ix9097 (.out (nx9096), .A (nx10652), .B (tc3_data_7)) ;
    Xor2 ix9101 (.out (nx9100), .A (nx10656), .B (tc3_data_5)) ;
    Xor2 ix9107 (.out (nx9106), .A (nx10654), .B (tc3_data_3)) ;
    Xor2 ix9111 (.out (nx9110), .A (nx8430), .B (tc3_data_1)) ;
    Xor2 ix9113 (.out (nx9112), .A (nx10648), .B (tc3_data_0)) ;
    Xnor2 ix5333 (.out (nx5332), .A (nx10632), .B (tc2_data_31)) ;
    Xor2 ix9131 (.out (nx9130), .A (nx10628), .B (tc2_data_29)) ;
    Xor2 ix9137 (.out (nx9136), .A (nx10658), .B (tc2_data_27)) ;
    Xor2 ix9141 (.out (nx9140), .A (nx10646), .B (tc2_data_25)) ;
    Xor2 ix9147 (.out (nx9146), .A (nx10652), .B (tc2_data_23)) ;
    Xor2 ix9151 (.out (nx9150), .A (nx10656), .B (tc2_data_21)) ;
    Xor2 ix9157 (.out (nx9156), .A (nx10654), .B (tc2_data_19)) ;
    Xor2 ix9161 (.out (nx9160), .A (nx8430), .B (tc2_data_17)) ;
    Xor2 ix9163 (.out (nx9162), .A (nx10648), .B (tc2_data_16)) ;
    Xnor2 ix5225 (.out (nx5224), .A (nx10632), .B (tc1_data_15)) ;
    Xor2 ix9179 (.out (nx9178), .A (nx10628), .B (tc1_data_13)) ;
    Xor2 ix9185 (.out (nx9184), .A (nx10658), .B (tc1_data_11)) ;
    Xor2 ix9189 (.out (nx9188), .A (nx10646), .B (tc1_data_9)) ;
    Xor2 ix9195 (.out (nx9194), .A (nx10652), .B (tc1_data_7)) ;
    Xor2 ix9199 (.out (nx9198), .A (nx10656), .B (tc1_data_5)) ;
    Xor2 ix9205 (.out (nx9204), .A (nx10654), .B (tc1_data_3)) ;
    Xor2 ix9209 (.out (nx9208), .A (nx8430), .B (tc1_data_1)) ;
    Xnor2 ix9211 (.out (nx9210), .A (nx10648), .B (nx7512)) ;
    Xnor2 ix5121 (.out (nx5120), .A (nx10632), .B (tc1_data_31)) ;
    Xor2 ix9227 (.out (nx9226), .A (nx10628), .B (tc1_data_29)) ;
    Xor2 ix9233 (.out (nx9232), .A (nx10659), .B (tc1_data_27)) ;
    Xor2 ix9237 (.out (nx9236), .A (nx10646), .B (tc1_data_25)) ;
    Xor2 ix9243 (.out (nx9242), .A (nx10653), .B (tc1_data_23)) ;
    Xor2 ix9247 (.out (nx9246), .A (nx10656), .B (tc1_data_21)) ;
    Xor2 ix9253 (.out (nx9252), .A (nx10655), .B (tc1_data_19)) ;
    Xor2 ix9257 (.out (nx9256), .A (nx8430), .B (tc1_data_17)) ;
    Xor2 ix9259 (.out (nx9258), .A (nx10648), .B (tc1_data_16)) ;
    Xor2 ix9295 (.out (nx9294), .A (nx10659), .B (tc0_data_11)) ;
    Xor2 ix9299 (.out (nx9298), .A (nx10646), .B (tc0_data_9)) ;
    Xor2 ix9305 (.out (nx9304), .A (nx10653), .B (tc0_data_7)) ;
    Xor2 ix9309 (.out (nx9308), .A (nx10657), .B (tc0_data_5)) ;
    Xor2 ix9315 (.out (nx9314), .A (nx10655), .B (tc0_data_3)) ;
    Xor2 ix9319 (.out (nx9318), .A (nx8430), .B (tc0_data_1)) ;
    Xnor2 ix9321 (.out (nx9320), .A (nx10648), .B (nx7617)) ;
    Xnor2 ix5987 (.out (nx5986), .A (nx10632), .B (tc0_data_31)) ;
    Xor2 ix9333 (.out (nx9332), .A (nx10628), .B (tc0_data_29)) ;
    Xor2 ix9339 (.out (nx9338), .A (nx10659), .B (tc0_data_27)) ;
    Xor2 ix9343 (.out (nx9342), .A (nx10647), .B (tc0_data_25)) ;
    Xor2 ix9349 (.out (nx9348), .A (nx10653), .B (tc0_data_23)) ;
    Xor2 ix9353 (.out (nx9352), .A (nx10657), .B (tc0_data_21)) ;
    Xor2 ix9359 (.out (nx9358), .A (nx10655), .B (tc0_data_19)) ;
    Xor2 ix9363 (.out (nx9362), .A (nx8430), .B (tc0_data_17)) ;
    Xor2 ix9365 (.out (nx9364), .A (nx10649), .B (tc0_data_16)) ;
    Xor2 ix9377 (.out (nx9376), .A (nx10628), .B (tc4_data_29)) ;
    Xnor2 ix4933 (.out (nx4932), .A (nx10659), .B (tc4_data_27)) ;
    Xor2 ix4935 (.out (nx4934), .A (nx10643), .B (tc4_data_26)) ;
    Xnor2 ix4943 (.out (nx4942), .A (nx10647), .B (tc4_data_25)) ;
    Xor2 ix4945 (.out (nx4944), .A (nx10645), .B (tc4_data_24)) ;
    Xnor2 ix4957 (.out (nx4956), .A (nx10653), .B (tc4_data_23)) ;
    Xor2 ix4959 (.out (nx4958), .A (nx10641), .B (tc4_data_22)) ;
    Xnor2 ix4967 (.out (nx4966), .A (nx10657), .B (tc4_data_21)) ;
    Xor2 ix4969 (.out (nx4968), .A (nx10651), .B (tc4_data_20)) ;
    Xnor2 ix4979 (.out (nx4978), .A (nx10655), .B (tc4_data_19)) ;
    Xor2 ix4981 (.out (nx4980), .A (nx10639), .B (tc4_data_18)) ;
    Xnor2 ix4989 (.out (nx4988), .A (nx8430), .B (tc4_data_17)) ;
    Xnor2 ix4991 (.out (nx4990), .A (nx10649), .B (tc4_data_16)) ;
    Xor2 ix9427 (.out (nx9426), .A (nx8143), .B (U_readout_control_int_par)) ;
    Mux2 ix5773 (.OUT (nx5772), .A (U_readout_control_typ_cnt_2), .B (
         U_readout_control_typ_cnt_3), .SEL (nx6541)) ;
    Nand3 ix10664 (.OUT (nx9959), .A (nx10645), .B (nx10643), .C (nx10042)) ;
    Inv ix10665 (.OUT (nx9960), .A (nx9959)) ;
    Nand2 ix10666 (.OUT (nx9961), .A (nx2933), .B (nx9960)) ;
    Inv reg_nx2939 (.OUT (nx2939), .A (nx9961)) ;
    BufI4 ix10667 (.OUT (nx9962), .A (nx10647)) ;
    Nand3 ix10668 (.OUT (nx9963), .A (nx10645), .B (nx10643), .C (nx9962)) ;
    Inv ix10669 (.OUT (nx9964), .A (nx9963)) ;
    Nand2 reg_nx8465 (.OUT (nx8465), .A (nx2933), .B (nx9964)) ;
    BufI4 ix10670 (.OUT (nx9965), .A (nx10647)) ;
    Nand2 ix10671 (.OUT (nx9966), .A (nx10645), .B (nx9965)) ;
    Inv ix10672 (.OUT (nx9967), .A (nx9966)) ;
    Nand2 ix10673 (.OUT (nx9968), .A (nx2933), .B (nx9967)) ;
    Inv reg_nx2935 (.OUT (nx2935), .A (nx9968)) ;
    Nand2 reg_nx8459 (.OUT (nx8459), .A (nx10645), .B (nx2933)) ;
    Nand2 ix10674 (.OUT (nx9969), .A (U_analog_control_mst_cnt_24), .B (
          U_analog_control_mst_cnt_22)) ;
    Nor2 ix10675 (.OUT (nx9970), .A (nx8581), .B (nx8561)) ;
    Nand2 ix10676 (.OUT (nx9971), .A (U_analog_control_mst_cnt_26), .B (nx9970)
          ) ;
    Nor2 ix10677 (.OUT (nx9972), .A (nx9969), .B (nx9971)) ;
    Nand3 ix10678 (.OUT (nx9973), .A (U_analog_control_mst_cnt_22), .B (
          U_analog_control_mst_cnt_24), .C (nx9970)) ;
    BufI4 ix10679 (.OUT (nx9974), .A (nx9973)) ;
    Inv ix10680 (.OUT (nx9975), .A (nx8561)) ;
    Nand3 ix10681 (.OUT (nx9976), .A (U_analog_control_mst_cnt_22), .B (
          U_analog_control_mst_cnt_24), .C (nx9975)) ;
    BufI4 ix10682 (.OUT (nx9977), .A (nx9976)) ;
    Inv ix10683 (.OUT (nx9978), .A (nx8561)) ;
    Nand2 ix10684 (.OUT (nx9979), .A (U_analog_control_mst_cnt_22), .B (nx9978)
          ) ;
    Nor3 reg_nx8453 (.OUT (nx8453), .A (nx8447), .B (nx10009), .C (nx10657)) ;
    Nor2 reg_nx2930 (.OUT (nx2930), .A (nx8447), .B (nx10657)) ;
    Inv ix10685 (.OUT (nx9980), .A (U_analog_control_mst_cnt_31)) ;
    Nand2 ix10686 (.OUT (nx9981), .A (U_analog_control_mst_cnt_28), .B (nx9980)
          ) ;
    Inv ix10687 (.OUT (nx9982), .A (U_analog_control_mst_cnt_30)) ;
    Inv ix10688 (.OUT (nx9983), .A (nx8619)) ;
    Nand2 ix10689 (.OUT (nx9984), .A (nx10635), .B (nx9983)) ;
    Nor3 ix10690 (.OUT (nx9985), .A (nx9981), .B (nx9982), .C (nx9984)) ;
    Nand2 ix10691 (.OUT (nx9986), .A (nx2959), .B (nx9985)) ;
    Nand2 ix10692 (.OUT (nx9987), .A (nx10635), .B (U_analog_control_mst_cnt_31)
          ) ;
    Inv ix10693 (.OUT (nx9988), .A (U_analog_control_mst_cnt_28)) ;
    Inv ix10694 (.OUT (nx9989), .A (nx8619)) ;
    Nand2 ix10695 (.OUT (nx9990), .A (U_analog_control_mst_cnt_30), .B (nx9989)
          ) ;
    AOI22 ix10696 (.OUT (nx9991), .A (U_analog_control_mst_cnt_31), .B (nx9988)
          , .C (U_analog_control_mst_cnt_31), .D (nx9990)) ;
    Nor2 ix10697 (.OUT (nx9992), .A (nx9512), .B (nx9991)) ;
    Nand2 reg_nx4872 (.OUT (nx4872), .A (nx9986), .B (nx10132)) ;
    Nand3 ix10698 (.OUT (nx9993), .A (U_analog_control_mst_cnt_28), .B (
          U_analog_control_mst_cnt_30), .C (nx9989)) ;
    Inv ix10699 (.OUT (nx9994), .A (nx9993)) ;
    Nand2 reg_nx8636 (.OUT (nx8636), .A (nx2959), .B (nx9994)) ;
    Inv ix10700 (.OUT (nx9995), .A (nx8619)) ;
    Nand2 ix10701 (.OUT (nx9996), .A (U_analog_control_mst_cnt_28), .B (nx9995)
          ) ;
    BufI4 ix10702 (.OUT (nx9997), .A (nx9996)) ;
    Inv ix10703 (.OUT (nx9998), .A (nx8599)) ;
    Nand3 ix10704 (.OUT (nx9999), .A (nx9972), .B (nx9997), .C (nx9998)) ;
    Inv ix10705 (.OUT (nx10000), .A (U_analog_control_mst_cnt_30)) ;
    Nand2 ix10706 (.OUT (nx10001), .A (nx9999), .B (nx10000)) ;
    Inv ix10707 (.OUT (nx10002), .A (nx10001)) ;
    BufI4 ix10708 (.OUT (nx10003), .A (nx9972)) ;
    BufI4 ix10709 (.OUT (nx10004), .A (nx9997)) ;
    Nor3 ix10710 (.OUT (nx10005), .A (nx10003), .B (nx10004), .C (nx8599)) ;
    Nand2 ix10711 (.OUT (nx10006), .A (nx2950), .B (nx10005)) ;
    Nor2 ix10712 (.OUT (nx10007), .A (nx10003), .B (nx8599)) ;
    Nand2 reg_nx8601 (.OUT (nx8601), .A (nx2950), .B (nx9972)) ;
    BufI4 ix10713 (.OUT (nx10008), .A (U_analog_control_mst_cnt_28)) ;
    Inv reg_nx2961 (.OUT (nx2961), .A (nx10006)) ;
    Nor3 reg_nx4848 (.OUT (nx4848), .A (nx10020), .B (nx9512), .C (nx2961)) ;
    Nand4 reg_nx8447 (.OUT (nx8447), .A (nx10651), .B (nx10036), .C (nx10639), .D (
          U_analog_control_mst_cnt_1)) ;
    BufI4 ix10714 (.OUT (nx10009), .A (nx10641)) ;
    Nand3 ix10715 (.OUT (nx10010), .A (U_analog_control_mst_cnt_1), .B (nx10639)
          , .C (nx10036)) ;
    Inv reg_nx2928 (.OUT (nx2928), .A (nx10010)) ;
    BufI4 reg_nx9500 (.OUT (nx9500), .A (nx10649)) ;
    Nand3 reg_nx8441 (.OUT (nx8441), .A (U_analog_control_mst_cnt_1), .B (
          nx10639), .C (nx9500)) ;
    BufI4 ix10716 (.OUT (nx10011), .A (nx10649)) ;
    Inv ix10717 (.OUT (nx10012), .A (nx8543)) ;
    Nand2 ix10718 (.OUT (nx10013), .A (U_analog_control_mst_cnt_20), .B (nx10012
          )) ;
    Nor2 ix10719 (.OUT (nx10014), .A (nx10008), .B (nx10013)) ;
    Nand2 ix10720 (.OUT (nx10015), .A (nx10007), .B (nx10014)) ;
    Inv ix10721 (.OUT (nx10016), .A (U_analog_control_mst_cnt_29)) ;
    Nand2 ix10722 (.OUT (nx10017), .A (nx10015), .B (nx10016)) ;
    Inv ix10723 (.OUT (nx10018), .A (nx10017)) ;
    Nor2 ix10724 (.OUT (nx10019), .A (nx10018), .B (nx10187)) ;
    Inv ix10725 (.OUT (nx10020), .A (nx10019)) ;
    BufI4 ix10726 (.OUT (nx10021), .A (U_analog_control_mst_cnt_20)) ;
    Nor4 ix10727 (.OUT (nx10022), .A (nx10570), .B (nx10008), .C (nx10021), .D (
         nx8543)) ;
    Nand2 ix10728 (.OUT (nx10023), .A (nx2947), .B (nx10022)) ;
    Inv reg_nx2960 (.OUT (nx2960), .A (nx10023)) ;
    Nand2 reg_nx8545 (.OUT (nx8545), .A (U_analog_control_mst_cnt_20), .B (
          nx2947)) ;
    Nand2 ix10729 (.OUT (nx10024), .A (U_command_control_cmd_state_1), .B (
          U_command_control_cmd_state_2)) ;
    Inv ix10730 (.OUT (nx10025), .A (nx10024)) ;
    Nand2 ix10731 (.OUT (nx10026), .A (nx2841), .B (nx10025)) ;
    Nand2 ix10732 (.OUT (nx10027), .A (nx7456), .B (nx10026)) ;
    Inv ix10733 (.OUT (nx10028), .A (nx10027)) ;
    Nor2 ix10734 (.OUT (nx10029), .A (nx10028), .B (nx7482)) ;
    Inv ix10735 (.OUT (nx10030), .A (nx7482)) ;
    Nor2 ix10736 (.OUT (nx10031), .A (nx10030), .B (nx10028)) ;
    Nand3 ix10737 (.OUT (nx10032), .A (nx2847), .B (nx76), .C (nx6443)) ;
    Inv ix10738 (.OUT (nx10033), .A (nx10032)) ;
    AOI22 ix10739 (.OUT (nx10034), .A (U_command_control_cmd_state_1), .B (
          nx10033), .C (nx6366), .D (nx2847)) ;
    Inv ix10740 (.OUT (nx10035), .A (nx10133)) ;
    Nor2 ix10741 (.OUT (nx10036), .A (nx10655), .B (nx10649)) ;
    Nor2 ix10742 (.OUT (nx10037), .A (nx10657), .B (nx10653)) ;
    Nand4 ix10743 (.OUT (nx10038), .A (nx10651), .B (nx10641), .C (nx10036), .D (
          nx10037)) ;
    Inv ix10744 (.OUT (nx10039), .A (nx10038)) ;
    Nand2 ix10745 (.OUT (nx10040), .A (nx10645), .B (nx10637)) ;
    Inv ix10746 (.OUT (nx10041), .A (nx10040)) ;
    Nor2 ix10747 (.OUT (nx10042), .A (nx10659), .B (nx10647)) ;
    Nand2 ix10748 (.OUT (nx10043), .A (nx10643), .B (nx10042)) ;
    Inv ix10749 (.OUT (nx10044), .A (nx10043)) ;
    Nand4 reg_nx8471 (.OUT (nx8471), .A (nx10035), .B (nx10039), .C (nx10041), .D (
          nx10044)) ;
    Nor2 reg_nx2933 (.OUT (nx2933), .A (nx10133), .B (nx10038)) ;
    Inv ix10750 (.OUT (nx10045), .A (nx8827)) ;
    Nor2 ix10751 (.OUT (nx10046), .A (nx10045), .B (nx8712)) ;
    Nand2 ix10752 (.OUT (nx10047), .A (U_analog_control_cal_cnt_10), .B (nx10046
          )) ;
    Inv ix10753 (.OUT (nx10048), .A (nx10047)) ;
    Nand2 ix10754 (.OUT (nx10049), .A (nx2923), .B (nx10048)) ;
    Inv ix10755 (.OUT (nx10050), .A (nx8712)) ;
    Nand2 ix10756 (.OUT (nx10051), .A (U_analog_control_cal_cnt_10), .B (nx10050
          )) ;
    Inv ix10757 (.OUT (nx10052), .A (nx10051)) ;
    Nor2 ix10758 (.OUT (nx10053), .A (nx10052), .B (nx8827)) ;
    Nor2 ix10759 (.OUT (nx10054), .A (nx2923), .B (nx8827)) ;
    Inv ix10760 (.OUT (nx10055), .A (U_analog_control_cal_cnt_12)) ;
    Nor3 ix10761 (.OUT (nx10056), .A (nx10055), .B (nx4288), .C (nx10662)) ;
    Inv ix10762 (.OUT (nx10057), .A (nx10056)) ;
    Nand2 reg_nx6249 (.OUT (nx6249), .A (nx10237), .B (nx10057)) ;
    BufI4 ix10763 (.OUT (nx10058), .A (nx10051)) ;
    Inv ix10764 (.OUT (nx10059), .A (nx10002)) ;
    Inv ix10765 (.OUT (nx10060), .A (nx8525)) ;
    Nor3 ix10766 (.OUT (nx10061), .A (nx10002), .B (nx10013), .C (nx8523)) ;
    AOI22 reg_nx8625 (.OUT (nx8625), .A (U_analog_control_mst_cnt_30), .B (
          nx10059), .C (nx10060), .D (nx10061)) ;
    Nand2 ix10767 (.OUT (nx10062), .A (nx6400), .B (nx6379)) ;
    Inv ix10768 (.OUT (nx10063), .A (nx6402)) ;
    Nand2 ix10769 (.OUT (nx10064), .A (nx6385), .B (nx10063)) ;
    Nor4 reg_nx6450 (.OUT (nx6450), .A (U_command_control_cmd_cnt_1), .B (
         U_command_control_cmd_cnt_0), .C (nx10062), .D (nx10064)) ;
    Inv ix10770 (.OUT (nx10065), .A (U_command_control_int_hdr_data_13)) ;
    Nand2 ix10771 (.OUT (nx10066), .A (U_command_control_cmd_state_2), .B (
          nx10065)) ;
    Nor3 ix10772 (.OUT (nx10067), .A (U_command_control_int_hdr_data_12), .B (
         nx6417), .C (nx6448)) ;
    Inv ix10773 (.OUT (nx10068), .A (nx10067)) ;
    Nor2 reg_nx6415 (.OUT (nx6415), .A (nx6417), .B (nx6448)) ;
    Nand3 reg_nx6398 (.OUT (nx6398), .A (nx6379), .B (nx6385), .C (nx6400)) ;
    Inv ix10774 (.OUT (nx10069), .A (U_command_control_cmd_cnt_1)) ;
    Inv ix10775 (.OUT (nx10070), .A (U_command_control_cmd_cnt_0)) ;
    Nand2 reg_nx36 (.OUT (nx36), .A (nx10069), .B (nx10070)) ;
    Nor2 reg_nx6463 (.OUT (nx6463), .A (U_command_control_cmd_cnt_1), .B (
         U_command_control_cmd_cnt_0)) ;
    BufI4 ix10776 (.OUT (nx10071), .A (nx8997)) ;
    BufI4 ix10777 (.OUT (nx10072), .A (nx9013)) ;
    Inv ix10778 (.OUT (nx10073), .A (nx8760)) ;
    Nor2 ix10779 (.OUT (nx10074), .A (nx10073), .B (U_analog_control_cal_dly_5)
         ) ;
    Inv ix10780 (.OUT (nx10075), .A (nx10074)) ;
    Inv ix10781 (.OUT (nx10076), .A (nx8760)) ;
    Nand2 ix10782 (.OUT (nx10077), .A (U_analog_control_cal_dly_5), .B (nx10076)
          ) ;
    Nand2 reg_nx8931 (.OUT (nx8931), .A (nx10075), .B (nx10077)) ;
    Inv ix10783 (.OUT (nx10078), .A (nx8808)) ;
    Nor2 ix10784 (.OUT (nx10079), .A (nx10078), .B (U_analog_control_cal_dly_0)
         ) ;
    Inv ix10785 (.OUT (nx10080), .A (nx10079)) ;
    Inv ix10786 (.OUT (nx10081), .A (nx8808)) ;
    Nand2 ix10787 (.OUT (nx10082), .A (U_analog_control_cal_dly_0), .B (nx10081)
          ) ;
    Nand2 reg_nx8940 (.OUT (nx8940), .A (nx10080), .B (nx10082)) ;
    Nor2 ix10788 (.OUT (nx10083), .A (U_analog_control_cal_cnt_4), .B (
         U_analog_control_cal_dly_4)) ;
    Inv ix10789 (.OUT (nx10084), .A (nx10083)) ;
    Nand2 ix10790 (.OUT (nx10085), .A (U_analog_control_cal_cnt_4), .B (
          U_analog_control_cal_dly_4)) ;
    Nand2 reg_nx8949 (.OUT (nx8949), .A (nx10084), .B (nx10085)) ;
    Inv ix10791 (.OUT (nx10086), .A (nx8752)) ;
    Nor2 ix10792 (.OUT (nx10087), .A (nx10086), .B (U_analog_control_cal_dly_6)
         ) ;
    Inv ix10793 (.OUT (nx10088), .A (nx10087)) ;
    Inv ix10794 (.OUT (nx10089), .A (nx8752)) ;
    Nand2 ix10795 (.OUT (nx10090), .A (U_analog_control_cal_dly_6), .B (nx10089)
          ) ;
    Nand2 reg_nx8922 (.OUT (nx8922), .A (nx10088), .B (nx10090)) ;
    Inv ix10796 (.OUT (nx10091), .A (nx8792)) ;
    Nor2 ix10797 (.OUT (nx10092), .A (nx10091), .B (U_analog_control_cal_dly_1)
         ) ;
    Inv ix10798 (.OUT (nx10093), .A (nx10092)) ;
    Inv ix10799 (.OUT (nx10094), .A (nx8792)) ;
    Nand2 ix10800 (.OUT (nx10095), .A (U_analog_control_cal_dly_1), .B (nx10094)
          ) ;
    Inv ix10801 (.OUT (nx10096), .A (nx8776)) ;
    Nor2 ix10802 (.OUT (nx10097), .A (nx10096), .B (U_analog_control_cal_dly_3)
         ) ;
    Inv ix10803 (.OUT (nx10098), .A (nx10097)) ;
    Inv ix10804 (.OUT (nx10099), .A (nx8776)) ;
    Nand2 ix10805 (.OUT (nx10100), .A (U_analog_control_cal_dly_3), .B (nx10099)
          ) ;
    AOI22 ix10806 (.OUT (nx10101), .A (nx10093), .B (nx10095), .C (nx10098), .D (
          nx10100)) ;
    BufI4 ix10807 (.OUT (nx10102), .A (nx3694)) ;
    BufI4 ix10808 (.OUT (nx10103), .A (nx3908)) ;
    Nand2 ix10809 (.OUT (nx10104), .A (nx10102), .B (nx10103)) ;
    Nor3 ix10810 (.OUT (nx10105), .A (nx3580), .B (nx2881), .C (nx10104)) ;
    Inv ix10811 (.OUT (nx10106), .A (nx8523)) ;
    Nand2 ix10812 (.OUT (nx10107), .A (nx10635), .B (nx10106)) ;
    Nor2 ix10813 (.OUT (nx10108), .A (nx10013), .B (nx10107)) ;
    Inv ix10814 (.OUT (nx10109), .A (nx10108)) ;
    Nor4 ix10815 (.OUT (nx10110), .A (nx8525), .B (nx9977), .C (nx9979), .D (
         nx10109)) ;
    Inv ix10816 (.OUT (nx10111), .A (nx10110)) ;
    Nand2 ix10817 (.OUT (nx10112), .A (U_analog_control_mst_cnt_24), .B (nx10635
          )) ;
    Inv ix10818 (.OUT (nx10113), .A (nx10112)) ;
    Nor2 ix10819 (.OUT (nx10114), .A (nx10013), .B (nx8523)) ;
    Nand2 ix10820 (.OUT (nx10115), .A (nx9977), .B (nx10114)) ;
    Inv ix10821 (.OUT (nx10116), .A (nx10112)) ;
    AOI22 ix10822 (.OUT (nx10117), .A (nx8525), .B (nx10113), .C (nx10115), .D (
          nx10116)) ;
    Nand2 reg_nx4778 (.OUT (nx4778), .A (nx10111), .B (nx10117)) ;
    BufI4 ix10823 (.OUT (nx10118), .A (nx9977)) ;
    Nor4 reg_nx2953 (.OUT (nx2953), .A (nx8525), .B (nx9979), .C (nx10013), .D (
         nx8523)) ;
    Inv ix10824 (.OUT (nx10119), .A (nx8523)) ;
    Nand2 ix10825 (.OUT (nx10120), .A (U_analog_control_mst_cnt_18), .B (nx10119
          )) ;
    Nor2 ix10826 (.OUT (nx10121), .A (nx10013), .B (nx10120)) ;
    Nand2 ix10827 (.OUT (nx10122), .A (nx9974), .B (nx10121)) ;
    Inv ix10828 (.OUT (nx10123), .A (U_analog_control_mst_cnt_26)) ;
    Nand2 ix10829 (.OUT (nx10124), .A (nx10122), .B (nx10123)) ;
    Inv ix10830 (.OUT (nx10125), .A (nx10124)) ;
    Nor2 ix10831 (.OUT (nx10126), .A (U_analog_control_mst_cnt_26), .B (nx2945)
         ) ;
    Nor2 ix10832 (.OUT (nx10127), .A (nx10125), .B (nx10126)) ;
    Inv reg_nx8587 (.OUT (nx8587), .A (nx10127)) ;
    BufI4 ix10833 (.OUT (nx10128), .A (nx9974)) ;
    Nor3 ix10834 (.OUT (nx10129), .A (nx10128), .B (nx10013), .C (nx10120)) ;
    Nand2 reg_NOT_nx2957 (.OUT (NOT_nx2957), .A (nx2945), .B (nx10129)) ;
    Inv ix10835 (.OUT (nx10130), .A (nx9987)) ;
    Nor2 ix10836 (.OUT (nx10131), .A (nx10130), .B (nx9992)) ;
    Inv ix10837 (.OUT (nx10132), .A (nx10567)) ;
    Nor3 reg_nx2959 (.OUT (nx2959), .A (nx8525), .B (nx10569), .C (nx8523)) ;
    Nand2 ix10838 (.OUT (nx10133), .A (nx10639), .B (U_analog_control_mst_cnt_1)
          ) ;
    Inv ix10839 (.OUT (nx10134), .A (nx4288)) ;
    Nand2 ix10840 (.OUT (nx10135), .A (U_analog_control_cal_cnt_11), .B (nx10134
          )) ;
    Nor2 ix10841 (.OUT (nx10136), .A (nx10662), .B (nx10135)) ;
    BufI4 ix10842 (.OUT (nx10137), .A (nx10058)) ;
    Nand2 ix10843 (.OUT (nx10138), .A (U_analog_control_cal_cnt_10), .B (nx10137
          )) ;
    Nor2 ix10844 (.OUT (nx10139), .A (nx10663), .B (nx10138)) ;
    Nand3 ix10845 (.OUT (nx10140), .A (nx10663), .B (nx2923), .C (nx10139)) ;
    BufI4 ix10846 (.OUT (nx10141), .A (nx10663)) ;
    Inv ix10847 (.OUT (nx10142), .A (U_analog_control_cal_cnt_10)) ;
    Nor2 ix10848 (.OUT (nx10143), .A (nx10142), .B (nx10058)) ;
    Nand4 ix10849 (.OUT (nx10144), .A (nx4288), .B (nx2923), .C (nx10141), .D (
          nx10143)) ;
    Nand2 ix10850 (.OUT (nx10145), .A (nx2923), .B (nx10058)) ;
    Nand3 ix10851 (.OUT (nx10146), .A (U_analog_control_cal_cnt_11), .B (nx10233
          ), .C (nx8841)) ;
    Inv ix10852 (.OUT (nx10147), .A (nx10146)) ;
    Nand2 ix10853 (.OUT (nx10148), .A (nx10145), .B (nx10147)) ;
    Nand2 ix10854 (.OUT (nx10149), .A (nx10144), .B (nx10148)) ;
    Inv ix10855 (.OUT (nx10150), .A (nx6812)) ;
    Nor2 ix10856 (.OUT (nx10151), .A (nx10150), .B (nx6799)) ;
    Nand3 ix10857 (.OUT (nx10152), .A (U_analog_control_sub_cnt_12), .B (
          U_analog_control_sub_cnt_14), .C (nx10151)) ;
    Inv ix10858 (.OUT (nx10153), .A (nx10152)) ;
    Inv ix10859 (.OUT (nx10154), .A (nx6799)) ;
    Nand3 ix10860 (.OUT (nx10155), .A (U_analog_control_sub_cnt_12), .B (
          U_analog_control_sub_cnt_14), .C (nx10154)) ;
    Inv ix10861 (.OUT (nx10156), .A (nx10155)) ;
    Nor2 ix10862 (.OUT (nx10157), .A (nx10156), .B (nx6812)) ;
    Inv ix10863 (.OUT (nx10158), .A (nx10155)) ;
    Inv ix10864 (.OUT (nx10159), .A (nx6799)) ;
    Nand2 ix10865 (.OUT (nx10160), .A (U_analog_control_sub_cnt_12), .B (nx10159
          )) ;
    Inv ix10866 (.OUT (nx10161), .A (nx8692)) ;
    Inv ix10867 (.OUT (nx10162), .A (nx8805)) ;
    Nand2 ix10868 (.OUT (nx10163), .A (nx10161), .B (nx10162)) ;
    Nand2 ix10869 (.OUT (nx10164), .A (nx8841), .B (nx10163)) ;
    BufI4 ix10870 (.OUT (nx10165), .A (nx10660)) ;
    BufI4 ix10871 (.OUT (nx10166), .A (nx10660)) ;
    AOI22 ix10872 (.OUT (nx10167), .A (nx8692), .B (nx10165), .C (nx8805), .D (
          nx10166)) ;
    Inv ix10873 (.OUT (nx10168), .A (nx10167)) ;
    Nand2 ix10874 (.OUT (nx10169), .A (nx8841), .B (nx10168)) ;
    Nand2 ix10875 (.OUT (nx10170), .A (nx2914), .B (nx8813)) ;
    Inv ix10876 (.OUT (nx10171), .A (nx10170)) ;
    Nand2 ix10877 (.OUT (nx10172), .A (nx8841), .B (nx10171)) ;
    Inv ix10878 (.OUT (nx10173), .A (nx10172)) ;
    Nand4 ix10879 (.OUT (nx10174), .A (nx10423), .B (nx10169), .C (nx10233), .D (
          nx10173)) ;
    Nand2 ix10880 (.OUT (nx10175), .A (U_analog_control_cal_cnt_4), .B (nx8813)
          ) ;
    Inv ix10881 (.OUT (nx10176), .A (nx10175)) ;
    Nand2 ix10882 (.OUT (nx10177), .A (nx8841), .B (nx10176)) ;
    Inv ix10883 (.OUT (nx10178), .A (nx10177)) ;
    Nand2 ix10884 (.OUT (nx10179), .A (nx10233), .B (nx10178)) ;
    Nand2 ix10885 (.OUT (nx10180), .A (U_analog_control_cal_cnt_4), .B (nx9564)
          ) ;
    Nand3 reg_nx6169 (.OUT (nx6169), .A (nx10174), .B (nx10179), .C (nx10180)) ;
    Inv reg_nx2915 (.OUT (nx2915), .A (nx8813)) ;
    Nor2 reg_nx4288 (.OUT (nx4288), .A (nx8692), .B (nx8805)) ;
    Nor2 ix10886 (.OUT (nx10181), .A (nx8523), .B (nx8505)) ;
    Nand3 ix10887 (.OUT (nx10182), .A (U_analog_control_mst_cnt_16), .B (
          U_analog_control_mst_cnt_18), .C (nx10181)) ;
    Inv ix10888 (.OUT (nx10183), .A (nx10182)) ;
    Nor2 ix10889 (.OUT (nx10184), .A (nx10183), .B (U_analog_control_mst_cnt_29)
         ) ;
    Nor2 ix10890 (.OUT (nx10185), .A (U_analog_control_mst_cnt_29), .B (nx2943)
         ) ;
    Nor2 ix10891 (.OUT (nx10186), .A (nx10184), .B (nx10185)) ;
    Inv ix10892 (.OUT (nx10187), .A (nx10186)) ;
    Inv ix10893 (.OUT (nx10188), .A (nx10182)) ;
    Nand2 ix10894 (.OUT (nx10189), .A (nx2943), .B (nx10188)) ;
    BufI4 reg_nx2947 (.OUT (nx2947), .A (nx10189)) ;
    Inv ix10895 (.OUT (nx10190), .A (nx8505)) ;
    Nand3 ix10896 (.OUT (nx10191), .A (U_analog_control_mst_cnt_16), .B (
          U_analog_control_mst_cnt_18), .C (nx10190)) ;
    BufI4 ix10897 (.OUT (nx10192), .A (nx10191)) ;
    Inv ix10898 (.OUT (nx10193), .A (nx8505)) ;
    Nand2 ix10899 (.OUT (nx10194), .A (U_analog_control_mst_cnt_16), .B (nx10193
          )) ;
    Inv ix10900 (.OUT (nx10195), .A (nx10194)) ;
    Nand2 ix10901 (.OUT (nx10196), .A (nx2943), .B (nx10195)) ;
    BufI4 reg_nx2945 (.OUT (nx2945), .A (nx10196)) ;
    Nand2 reg_nx8507 (.OUT (nx8507), .A (U_analog_control_mst_cnt_16), .B (
          nx2943)) ;
    BufI4 ix10902 (.OUT (nx10197), .A (nx6654)) ;
    Inv ix10903 (.OUT (nx10198), .A (nx10029)) ;
    Inv reg_nx14 (.OUT (nx14), .A (nx6484)) ;
    Nand2 ix10904 (.OUT (nx10199), .A (nx6417), .B (nx14)) ;
    Nand2 ix10905 (.OUT (nx10200), .A (U_command_control_int_hdr_data_5), .B (
          nx6920)) ;
    Inv ix10906 (.OUT (nx10201), .A (nx10200)) ;
    Nand2 ix10907 (.OUT (nx10202), .A (nx82), .B (nx10201)) ;
    Nand2 ix10908 (.OUT (nx10203), .A (nx10199), .B (nx10202)) ;
    Nor3 ix10909 (.OUT (nx10204), .A (nx10383), .B (nx10198), .C (nx10203)) ;
    Nand2 ix10910 (.OUT (nx10205), .A (nx7930), .B (nx10204)) ;
    Inv ix10911 (.OUT (nx10206), .A (nx6417)) ;
    Nor2 ix10912 (.OUT (nx10207), .A (nx10206), .B (nx6484)) ;
    Inv ix10913 (.OUT (nx10208), .A (nx10202)) ;
    Nor3 ix10914 (.OUT (nx10209), .A (nx10383), .B (nx10207), .C (nx10208)) ;
    Inv ix10915 (.OUT (nx10210), .A (nx6484)) ;
    BufI4 ix10916 (.OUT (nx10211), .A (nx10660)) ;
    Nor2 ix10917 (.OUT (nx10212), .A (nx10211), .B (U_analog_control_cal_state_0
         )) ;
    BufI4 ix10918 (.OUT (nx10213), .A (nx10390)) ;
    BufI4 ix10919 (.OUT (nx10214), .A (nx4288)) ;
    Nand4 ix10920 (.OUT (nx10215), .A (nx8701), .B (U_analog_control_cal_state_0
          ), .C (nx8841), .D (nx10214)) ;
    BufI4 ix10921 (.OUT (nx10216), .A (nx10661)) ;
    Nand3 ix10922 (.OUT (nx10217), .A (nx10216), .B (nx8841), .C (nx10214)) ;
    Inv ix10923 (.OUT (nx10218), .A (U_analog_control_cal_cnt_10)) ;
    Inv ix10924 (.OUT (nx10219), .A (nx8728)) ;
    Nand4 ix10925 (.OUT (nx10220), .A (nx10215), .B (nx10217), .C (nx10218), .D (
          nx10219)) ;
    Nor3 ix10926 (.OUT (nx10221), .A (nx8821), .B (nx10663), .C (nx10220)) ;
    Inv ix10927 (.OUT (nx10222), .A (nx10221)) ;
    Inv ix10928 (.OUT (nx10223), .A (U_analog_control_cal_cnt_10)) ;
    Nor3 ix10929 (.OUT (nx10224), .A (nx10223), .B (nx10257), .C (nx10390)) ;
    Nand2 ix10930 (.OUT (nx10225), .A (nx8821), .B (nx10224)) ;
    Inv ix10931 (.OUT (nx10226), .A (nx10225)) ;
    Nand2 ix10932 (.OUT (nx10227), .A (U_analog_control_cal_cnt_10), .B (nx8728)
          ) ;
    Inv ix10933 (.OUT (nx10228), .A (nx10227)) ;
    Nand4 ix10934 (.OUT (nx10229), .A (nx10228), .B (nx10311), .C (nx8841), .D (
          nx10391)) ;
    Nand2 ix10935 (.OUT (nx10230), .A (U_analog_control_cal_cnt_10), .B (nx8802)
          ) ;
    Nand2 ix10936 (.OUT (nx10231), .A (nx10229), .B (nx10230)) ;
    Nor2 ix10937 (.OUT (nx10232), .A (nx10226), .B (nx10231)) ;
    Nand2 reg_nx6229 (.OUT (nx6229), .A (nx10222), .B (nx10232)) ;
    Nand2 ix10938 (.OUT (nx10233), .A (nx10661), .B (nx4272)) ;
    Nor2 ix10939 (.OUT (nx10234), .A (nx10053), .B (nx10054)) ;
    Nand2 ix10940 (.OUT (nx10235), .A (nx10049), .B (nx10234)) ;
    Nor2 ix10941 (.OUT (nx10236), .A (nx8802), .B (nx10663)) ;
    Nand2 ix10942 (.OUT (nx10237), .A (nx10235), .B (nx10236)) ;
    Inv ix10943 (.OUT (nx10238), .A (nx10557)) ;
    Inv ix10944 (.OUT (nx10239), .A (nx6695)) ;
    Nand3 ix10945 (.OUT (nx10240), .A (U_analog_control_sub_cnt_0), .B (
          U_analog_control_sub_cnt_4), .C (nx10239)) ;
    Inv ix10946 (.OUT (nx10241), .A (nx10240)) ;
    Nand2 reg_nx7119 (.OUT (nx7119), .A (nx10238), .B (nx10241)) ;
    Nand2 ix10947 (.OUT (nx10242), .A (U_analog_control_sub_cnt_1), .B (
          U_analog_control_sub_cnt_0)) ;
    Inv ix10948 (.OUT (nx10243), .A (nx6695)) ;
    Nand2 ix10949 (.OUT (nx10244), .A (U_analog_control_sub_cnt_2), .B (nx10243)
          ) ;
    Nor2 reg_nx2887 (.OUT (nx2887), .A (nx10242), .B (nx10244)) ;
    Nand3 reg_nx7111 (.OUT (nx7111), .A (U_analog_control_sub_cnt_0), .B (
          U_analog_control_sub_cnt_2), .C (U_analog_control_sub_cnt_1)) ;
    BufI4 ix10950 (.OUT (nx10245), .A (nx10072)) ;
    Inv ix10951 (.OUT (nx10246), .A (nx10101)) ;
    Inv ix10952 (.OUT (nx10247), .A (nx8949)) ;
    BufI4 ix10953 (.OUT (nx10248), .A (nx10211)) ;
    Nand4 ix10954 (.OUT (nx10249), .A (nx8940), .B (nx8922), .C (nx8931), .D (
          nx10248)) ;
    Nor3 ix10955 (.OUT (nx10250), .A (nx10246), .B (nx10247), .C (nx10249)) ;
    BufI4 ix10956 (.OUT (nx10251), .A (nx10071)) ;
    Inv ix10957 (.OUT (nx10252), .A (nx10105)) ;
    Nand2 ix10958 (.OUT (nx10253), .A (nx8940), .B (nx8922)) ;
    Nand2 ix10959 (.OUT (nx10254), .A (nx8931), .B (nx10248)) ;
    Nor2 ix10960 (.OUT (nx10255), .A (nx10253), .B (nx10254)) ;
    Nand4 ix10961 (.OUT (nx10256), .A (nx10245), .B (nx10101), .C (nx8949), .D (
          nx10255)) ;
    Nor3 ix10962 (.OUT (nx10257), .A (nx10251), .B (nx10252), .C (nx10256)) ;
    Nand3 ix10963 (.OUT (nx10258), .A (nx10101), .B (nx8949), .C (nx8922)) ;
    Nand2 ix10964 (.OUT (nx10259), .A (nx8931), .B (nx8940)) ;
    Nor3 ix10965 (.OUT (nx10260), .A (nx10072), .B (nx10258), .C (nx10259)) ;
    Inv ix10966 (.OUT (nx10261), .A (nx8692)) ;
    Inv ix10967 (.OUT (nx10262), .A (nx8694)) ;
    Nand2 reg_nx8677 (.OUT (nx8677), .A (nx10261), .B (nx10262)) ;
    Nor2 reg_nx2903 (.OUT (nx2903), .A (nx8692), .B (nx8694)) ;
    Nor2 ix10968 (.OUT (nx10263), .A (nx6379), .B (U_command_control_cmd_cnt_2)
         ) ;
    Nand2 ix10969 (.OUT (nx10264), .A (U_command_control_cmd_cnt_4), .B (nx10263
          )) ;
    Inv ix10970 (.OUT (nx10265), .A (nx10264)) ;
    Inv ix10971 (.OUT (nx10266), .A (nx6450)) ;
    Nand3 ix10972 (.OUT (nx10267), .A (U_command_control_int_hdr_data_7), .B (
          U_command_control_int_hdr_data_9), .C (
          U_command_control_int_hdr_data_8)) ;
    Inv ix10973 (.OUT (nx10268), .A (nx10267)) ;
    Inv ix10974 (.OUT (nx10269), .A (nx6663)) ;
    Nand2 ix10975 (.OUT (nx10270), .A (nx6902), .B (nx6637)) ;
    Nor2 ix10976 (.OUT (nx10271), .A (nx10269), .B (nx10270)) ;
    Nor2 ix10977 (.OUT (nx10272), .A (nx10268), .B (nx10271)) ;
    Nor3 ix10978 (.OUT (nx10273), .A (nx10068), .B (nx10272), .C (nx10066)) ;
    Nand3 ix10979 (.OUT (nx10274), .A (nx6663), .B (nx6902), .C (nx6637)) ;
    Nand2 ix10980 (.OUT (nx10275), .A (nx10267), .B (nx10274)) ;
    Inv ix10981 (.OUT (nx10276), .A (nx10066)) ;
    Nand2 ix10982 (.OUT (nx10277), .A (nx10275), .B (nx10276)) ;
    Nor2 reg_nx6425 (.OUT (nx6425), .A (nx6379), .B (nx6385)) ;
    Nand2 ix10983 (.OUT (nx10278), .A (U_command_control_cmd_cnt_4), .B (nx6425)
          ) ;
    Nand3 ix10984 (.OUT (nx10279), .A (nx6379), .B (nx6385), .C (nx6400)) ;
    Inv ix10985 (.OUT (nx10280), .A (nx10279)) ;
    Inv ix10986 (.OUT (nx10281), .A (nx6450)) ;
    Nand2 ix10987 (.OUT (nx10282), .A (nx6637), .B (nx6663)) ;
    Nor3 ix10988 (.OUT (nx10283), .A (nx10068), .B (nx10066), .C (nx10282)) ;
    Nor3 reg_nx796 (.OUT (nx796), .A (nx6450), .B (nx10068), .C (nx10066)) ;
    Nand2 reg_nx7456 (.OUT (nx7456), .A (U_command_control_cmd_state_2), .B (
          nx6415)) ;
    Inv ix10989 (.OUT (nx10284), .A (nx7456)) ;
    Nand2 ix10990 (.OUT (nx10285), .A (U_command_control_int_par), .B (nx42)) ;
    Inv ix10991 (.OUT (nx10286), .A (nx10285)) ;
    Inv ix10992 (.OUT (nx10287), .A (U_command_control_cmd_state_2)) ;
    Inv ix10993 (.OUT (nx10288), .A (nx6415)) ;
    Nor3 ix10994 (.OUT (nx10289), .A (nx6905), .B (nx10287), .C (nx10288)) ;
    AOI22 ix10995 (.OUT (nx10290), .A (nx10284), .B (nx10286), .C (nx368), .D (
          nx10289)) ;
    Inv reg_nx376 (.OUT (nx376), .A (nx10290)) ;
    AOI22 ix10996 (.OUT (nx10291), .A (nx6641), .B (nx784), .C (nx6902), .D (
          nx462)) ;
    Nor3 ix10997 (.OUT (nx10292), .A (nx7507), .B (nx10291), .C (nx6654)) ;
    Inv ix10998 (.OUT (nx10293), .A (U_command_control_cmd_cnt_3)) ;
    Nand3 reg_nx2841 (.OUT (nx2841), .A (nx7473), .B (nx6372), .C (nx6425)) ;
    Nor3 ix10999 (.OUT (nx10294), .A (U_command_control_cmd_state_0), .B (nx6443
         ), .C (nx6448)) ;
    Nand3 ix11000 (.OUT (nx10295), .A (nx10293), .B (nx2841), .C (nx10294)) ;
    Nor2 ix11001 (.OUT (nx10296), .A (nx8164), .B (nx10295)) ;
    Nand2 ix11002 (.OUT (nx10297), .A (nx6372), .B (nx6425)) ;
    Inv ix11003 (.OUT (nx10298), .A (nx10297)) ;
    Inv ix11004 (.OUT (nx10299), .A (nx7482)) ;
    Nand4 ix11005 (.OUT (nx10300), .A (nx7473), .B (nx10298), .C (nx10294), .D (
          nx10299)) ;
    Nor2 ix11006 (.OUT (nx10301), .A (nx6379), .B (U_command_control_cmd_cnt_2)
         ) ;
    Nand2 ix11007 (.OUT (nx10302), .A (nx426), .B (nx10301)) ;
    Inv ix11008 (.OUT (nx10303), .A (nx444)) ;
    Nand2 ix11009 (.OUT (nx10304), .A (nx10302), .B (nx10303)) ;
    Nand2 ix11010 (.OUT (nx10305), .A (nx2841), .B (nx10294)) ;
    Inv ix11011 (.OUT (nx10306), .A (nx10305)) ;
    Nand2 ix11012 (.OUT (nx10307), .A (nx10304), .B (nx10306)) ;
    Nand2 ix11013 (.OUT (nx10308), .A (nx10300), .B (nx10307)) ;
    Nor4 reg_nx7930 (.OUT (nx7930), .A (nx376), .B (nx10292), .C (nx10296), .D (
         nx10308)) ;
    Inv ix11014 (.OUT (nx10309), .A (nx2919)) ;
    Inv ix11015 (.OUT (nx10310), .A (nx10217)) ;
    Nand4 ix11016 (.OUT (nx10311), .A (nx10071), .B (nx10250), .C (nx10105), .D (
          nx10245)) ;
    Nand4 ix11017 (.OUT (nx10312), .A (nx10213), .B (nx10311), .C (nx8728), .D (
          U_analog_control_cal_cnt_8)) ;
    Nor3 ix11018 (.OUT (nx10313), .A (nx10309), .B (nx10310), .C (nx10312)) ;
    Nand2 ix11019 (.OUT (nx10314), .A (nx10215), .B (nx10313)) ;
    Inv ix11020 (.OUT (nx10315), .A (nx10215)) ;
    Nand2 ix11021 (.OUT (nx10316), .A (U_analog_control_cal_cnt_9), .B (nx10315)
          ) ;
    Nand2 reg_nx8821 (.OUT (nx8821), .A (U_analog_control_cal_cnt_8), .B (nx2919
          )) ;
    Nand3 ix11022 (.OUT (nx10317), .A (U_analog_control_cal_cnt_9), .B (nx10213)
          , .C (nx10311)) ;
    Inv ix11023 (.OUT (nx10318), .A (nx10317)) ;
    Inv ix11024 (.OUT (nx10319), .A (nx10217)) ;
    AOI22 ix11025 (.OUT (nx10320), .A (nx8821), .B (nx10318), .C (
          U_analog_control_cal_cnt_9), .D (nx10319)) ;
    Nand3 reg_nx6219 (.OUT (nx6219), .A (nx10314), .B (nx10316), .C (nx10320)) ;
    Nand2 reg_nx8802 (.OUT (nx8802), .A (nx10215), .B (nx10217)) ;
    Inv ix11026 (.OUT (nx10321), .A (nx8728)) ;
    Nand2 ix11027 (.OUT (nx10322), .A (U_analog_control_cal_cnt_8), .B (nx10321)
          ) ;
    Inv ix11028 (.OUT (nx10323), .A (nx10322)) ;
    Nand2 ix11029 (.OUT (nx10324), .A (nx2919), .B (nx10323)) ;
    BufI4 reg_nx2923 (.OUT (nx2923), .A (nx10324)) ;
    Inv reg_nx2921 (.OUT (nx2921), .A (nx8821)) ;
    Inv ix11030 (.OUT (nx10325), .A (U_command_control_int_hdr_data_10)) ;
    Nor2 ix11031 (.OUT (nx10326), .A (nx6902), .B (nx7250)) ;
    Nand4 ix11032 (.OUT (nx10327), .A (nx10325), .B (nx10281), .C (nx10283), .D (
          nx10326)) ;
    Inv ix11033 (.OUT (nx10328), .A (nx10277)) ;
    Nor3 ix11034 (.OUT (nx10329), .A (nx10278), .B (nx6450), .C (nx10068)) ;
    Nand3 ix11035 (.OUT (nx10330), .A (nx10328), .B (nx1882), .C (nx10329)) ;
    Nand2 ix11036 (.OUT (nx10331), .A (nx1960), .B (nx10280)) ;
    Nand2 ix11037 (.OUT (nx10332), .A (nx1858), .B (nx10265)) ;
    Nand2 ix11038 (.OUT (nx10333), .A (nx10331), .B (nx10332)) ;
    Nand3 ix11039 (.OUT (nx10334), .A (nx10266), .B (nx10273), .C (nx10333)) ;
    Inv ix11040 (.OUT (nx10335), .A (U_command_control_int_hdr_data_10)) ;
    Nand2 reg_nx7507 (.OUT (nx7507), .A (nx10281), .B (nx10283)) ;
    Inv ix11041 (.OUT (nx10336), .A (nx4906)) ;
    BufI4 ix11042 (.OUT (nx10337), .A (nx8668)) ;
    BufI4 ix11043 (.OUT (nx10338), .A (nx8648)) ;
    BufI4 ix11044 (.OUT (nx10339), .A (nx8662)) ;
    Nand2 ix11045 (.OUT (nx10340), .A (nx8660), .B (nx8666)) ;
    Nand2 ix11046 (.OUT (nx10341), .A (nx8650), .B (nx8656)) ;
    Nor2 ix11047 (.OUT (nx10342), .A (nx10340), .B (nx10341)) ;
    BufI4 ix11048 (.OUT (nx10343), .A (nx8646)) ;
    Nor2 ix11049 (.OUT (nx10344), .A (tc2_data_14), .B (tc2_data_13)) ;
    BufI4 ix11050 (.OUT (nx10345), .A (nx10629)) ;
    Nor2 ix11051 (.OUT (nx10346), .A (nx10345), .B (nx10630)) ;
    Nand2 ix11052 (.OUT (nx10347), .A (nx10344), .B (nx10346)) ;
    Inv ix11053 (.OUT (nx10348), .A (tc2_data_13)) ;
    Nand4 ix11054 (.OUT (nx10349), .A (tc2_data_14), .B (nx10348), .C (nx10630)
          , .D (nx10629)) ;
    Nand2 ix11055 (.OUT (nx10350), .A (nx10347), .B (nx10349)) ;
    Inv ix11056 (.OUT (nx10351), .A (tc2_data_14)) ;
    BufI4 ix11057 (.OUT (nx10352), .A (nx10631)) ;
    BufI4 ix11058 (.OUT (nx10353), .A (nx10629)) ;
    Nand4 ix11059 (.OUT (nx10354), .A (tc2_data_13), .B (nx10351), .C (nx10352)
          , .D (nx10353)) ;
    BufI4 ix11060 (.OUT (nx10355), .A (nx10629)) ;
    Nand4 ix11061 (.OUT (nx10356), .A (tc2_data_14), .B (tc2_data_13), .C (
          nx10631), .D (nx10355)) ;
    Nand2 ix11062 (.OUT (nx10357), .A (nx10354), .B (nx10356)) ;
    Nor2 ix11063 (.OUT (nx10358), .A (nx10350), .B (nx10357)) ;
    Nor2 ix11064 (.OUT (nx10359), .A (nx10632), .B (tc2_data_15)) ;
    Nand2 ix11065 (.OUT (nx10360), .A (nx10632), .B (tc2_data_15)) ;
    Inv ix11066 (.OUT (nx10361), .A (nx10360)) ;
    Nor2 ix11067 (.OUT (nx10362), .A (nx10359), .B (nx10361)) ;
    Nand3 reg_nx3260 (.OUT (nx3260), .A (nx6671), .B (nx6624), .C (nx6716)) ;
    Nor2 ix11068 (.OUT (nx10363), .A (nx10637), .B (tc2_data_12)) ;
    Nand2 ix11069 (.OUT (nx10364), .A (nx10637), .B (tc2_data_12)) ;
    Inv ix11070 (.OUT (nx10365), .A (nx10364)) ;
    Nor2 ix11071 (.OUT (nx10366), .A (nx10363), .B (nx10365)) ;
    Inv reg_nx8642 (.OUT (nx8642), .A (nx10366)) ;
    Nand3 ix11072 (.OUT (nx10367), .A (nx10362), .B (nx10635), .C (nx8642)) ;
    Nor3 ix11073 (.OUT (nx10368), .A (nx10343), .B (nx10358), .C (nx10367)) ;
    Nand4 ix11074 (.OUT (nx10369), .A (nx8672), .B (nx10342), .C (nx8670), .D (
          nx10368)) ;
    Nor4 ix11075 (.OUT (nx10370), .A (nx10337), .B (nx10338), .C (nx10339), .D (
         nx10369)) ;
    Nand4 ix11076 (.OUT (nx10371), .A (nx10336), .B (nx8658), .C (nx8652), .D (
          nx10370)) ;
    Nand2 ix11077 (.OUT (nx10372), .A (pwr_up_acq_dig), .B (nx10635)) ;
    Nand2 reg_nx6279 (.OUT (nx6279), .A (nx10371), .B (nx10372)) ;
    BufI4 ix11078 (.OUT (nx10373), .A (nx10197)) ;
    Nand2 ix11079 (.OUT (nx10374), .A (nx1682), .B (nx10373)) ;
    Nand2 ix11080 (.OUT (nx10375), .A (nx10330), .B (nx10334)) ;
    BufI4 ix11081 (.OUT (nx10376), .A (nx10197)) ;
    Nand2 ix11082 (.OUT (nx10377), .A (nx10335), .B (nx10376)) ;
    Inv ix11083 (.OUT (nx10378), .A (nx10377)) ;
    Inv ix11084 (.OUT (nx10379), .A (nx1394)) ;
    Nand2 ix11085 (.OUT (nx10380), .A (nx10327), .B (nx10379)) ;
    BufI4 ix11086 (.OUT (nx10381), .A (nx10197)) ;
    AOI22 ix11087 (.OUT (nx10382), .A (nx10375), .B (nx10378), .C (nx10380), .D (
          nx10381)) ;
    Nand2 ix11088 (.OUT (nx10383), .A (nx10374), .B (nx10382)) ;
    Inv ix11089 (.OUT (nx10384), .A (nx10212)) ;
    Nor2 ix11090 (.OUT (nx10385), .A (U_analog_control_cal_cnt_8), .B (
         U_analog_control_cal_cnt_11)) ;
    Inv ix11091 (.OUT (nx10386), .A (U_analog_control_cal_cnt_9)) ;
    Nor2 ix11092 (.OUT (nx10387), .A (U_analog_control_cal_cnt_7), .B (
         U_analog_control_cal_cnt_6)) ;
    Nor2 ix11093 (.OUT (nx10388), .A (U_analog_control_cal_cnt_2), .B (
         U_analog_control_cal_cnt_1)) ;
    Nor2 ix11094 (.OUT (nx10389), .A (nx8776), .B (nx10661)) ;
    Nand2 ix11095 (.OUT (nx10390), .A (nx10384), .B (nx10415)) ;
    Inv ix11096 (.OUT (nx10391), .A (nx10212)) ;
    Nor2 ix11097 (.OUT (nx10392), .A (U_analog_control_cal_cnt_11), .B (
         U_analog_control_cal_cnt_10)) ;
    Nor2 ix11098 (.OUT (nx10393), .A (U_analog_control_cal_cnt_8), .B (
         U_analog_control_cal_cnt_9)) ;
    Nand2 ix11099 (.OUT (nx10394), .A (nx10392), .B (nx10393)) ;
    Inv ix11100 (.OUT (nx10395), .A (U_analog_control_cal_cnt_12)) ;
    Nor3 ix11101 (.OUT (nx10396), .A (U_analog_control_cal_cnt_7), .B (nx8692), 
         .C (nx10661)) ;
    Nand2 ix11102 (.OUT (nx10397), .A (nx10395), .B (nx10396)) ;
    Nor2 ix11103 (.OUT (nx10398), .A (nx10394), .B (nx10397)) ;
    Nor3 ix11104 (.OUT (nx10399), .A (U_analog_control_cal_cnt_1), .B (
         U_analog_control_cal_cnt_6), .C (nx8776)) ;
    Inv ix11105 (.OUT (nx10400), .A (nx10399)) ;
    Inv ix11106 (.OUT (nx10401), .A (U_analog_control_cal_cnt_5)) ;
    Nand2 ix11107 (.OUT (nx10402), .A (U_analog_control_cal_cnt_4), .B (nx10401)
          ) ;
    Nor2 ix11108 (.OUT (nx10403), .A (U_analog_control_cal_cnt_2), .B (
         U_analog_control_cal_cnt_0)) ;
    Inv ix11109 (.OUT (nx10404), .A (nx10403)) ;
    Nor3 ix11110 (.OUT (nx10405), .A (nx10400), .B (nx10402), .C (nx10404)) ;
    Nand2 reg_nx8841 (.OUT (nx8841), .A (nx10398), .B (nx10405)) ;
    Nand2 ix11111 (.OUT (nx10406), .A (nx10387), .B (nx10388)) ;
    Inv ix11112 (.OUT (nx10407), .A (nx10406)) ;
    Nand3 ix11113 (.OUT (nx10408), .A (nx10385), .B (U_analog_control_cal_cnt_4)
          , .C (nx10386)) ;
    Inv ix11114 (.OUT (nx10409), .A (nx10408)) ;
    Nor2 ix11115 (.OUT (nx10410), .A (nx8692), .B (U_analog_control_cal_cnt_0)
         ) ;
    Nand2 ix11116 (.OUT (nx10411), .A (nx10389), .B (nx10410)) ;
    Nor3 ix11117 (.OUT (nx10412), .A (U_analog_control_cal_cnt_5), .B (
         U_analog_control_cal_cnt_10), .C (U_analog_control_cal_cnt_12)) ;
    Inv ix11118 (.OUT (nx10413), .A (nx10412)) ;
    Nor2 ix11119 (.OUT (nx10414), .A (nx10411), .B (nx10413)) ;
    Nand3 ix11120 (.OUT (nx10415), .A (nx10407), .B (nx10409), .C (nx10414)) ;
    BufI4 ix11121 (.OUT (nx10416), .A (nx9378)) ;
    Inv ix11122 (.OUT (nx10417), .A (nx4944)) ;
    Nor2 ix11123 (.OUT (nx10418), .A (tc4_data_30), .B (tc4_data_31)) ;
    Inv ix11124 (.OUT (nx10419), .A (tc4_data_31)) ;
    BufI4 ix11125 (.OUT (nx10420), .A (nx10631)) ;
    BufI4 ix11126 (.OUT (nx10421), .A (nx10633)) ;
    Nor3 reg_nx6269 (.OUT (nx6269), .A (nx4434), .B (nx10544), .C (nx9514)) ;
    Nor2 reg_nx9265 (.OUT (nx9265), .A (nx4434), .B (nx9514)) ;
    Inv ix11127 (.OUT (nx10422), .A (nx10164)) ;
    Nand3 reg_nx8701 (.OUT (nx8701), .A (nx10260), .B (nx10071), .C (nx10105)) ;
    Nand3 ix11128 (.OUT (nx10423), .A (nx10422), .B (
          U_analog_control_cal_state_0), .C (nx8701)) ;
    Nand2 reg_nx4272 (.OUT (nx4272), .A (U_analog_control_cal_state_0), .B (
          nx8701)) ;
    BufI4 reg_nx9510 (.OUT (nx9510), .A (nx10635)) ;
    BufI4 ix11129 (.OUT (nx10424), .A (nx10192)) ;
    Nor2 ix11130 (.OUT (nx10425), .A (nx10013), .B (nx8523)) ;
    Inv ix11131 (.OUT (nx10426), .A (nx10425)) ;
    Nor3 ix11132 (.OUT (nx10427), .A (nx10118), .B (nx10424), .C (nx10426)) ;
    Nand2 ix11133 (.OUT (nx10428), .A (nx2943), .B (nx10427)) ;
    Inv ix11134 (.OUT (nx10429), .A (U_analog_control_mst_cnt_25)) ;
    Nand2 ix11135 (.OUT (nx10430), .A (nx10428), .B (nx10429)) ;
    Inv ix11136 (.OUT (nx10431), .A (nx10430)) ;
    Nor2 ix11137 (.OUT (nx10432), .A (nx9510), .B (nx10431)) ;
    Nand2 ix11138 (.OUT (nx10433), .A (NOT_nx2957), .B (nx10432)) ;
    Inv reg_nx4792 (.OUT (nx4792), .A (nx10433)) ;
    Inv ix11139 (.OUT (nx10434), .A (nx6812)) ;
    Nor2 ix11140 (.OUT (nx10435), .A (nx10434), .B (nx10157)) ;
    Inv ix11141 (.OUT (nx10436), .A (nx10435)) ;
    Nor2 ix11142 (.OUT (nx10437), .A (nx2898), .B (nx10436)) ;
    Nor4 ix11143 (.OUT (nx10438), .A (nx6781), .B (nx10157), .C (nx6774), .D (
         nx10153)) ;
    Nor3 reg_nx3096 (.OUT (nx3096), .A (nx9492), .B (nx10437), .C (nx10438)) ;
    Nand2 ix11144 (.OUT (nx10439), .A (U_analog_control_mst_cnt_22), .B (nx10121
          )) ;
    Inv ix11145 (.OUT (nx10440), .A (U_analog_control_mst_cnt_23)) ;
    Nand2 ix11146 (.OUT (nx10441), .A (nx10439), .B (nx10440)) ;
    Inv ix11147 (.OUT (nx10442), .A (nx10441)) ;
    Nor2 ix11148 (.OUT (nx10443), .A (U_analog_control_mst_cnt_23), .B (nx2945)
         ) ;
    Nor2 ix11149 (.OUT (nx10444), .A (nx10442), .B (nx10443)) ;
    Inv reg_nx8558 (.OUT (nx8558), .A (nx10444)) ;
    Inv ix11150 (.OUT (nx10445), .A (nx10439)) ;
    Nand2 ix11151 (.OUT (nx10446), .A (nx2945), .B (nx10445)) ;
    Inv reg_nx2951 (.OUT (nx2951), .A (nx10446)) ;
    Nand2 ix11152 (.OUT (nx10447), .A (nx2945), .B (nx10121)) ;
    BufI4 reg_nx2950 (.OUT (nx2950), .A (nx10447)) ;
    Inv ix11153 (.OUT (nx10448), .A (nx10526)) ;
    Nand2 ix11154 (.OUT (nx10449), .A (nx10631), .B (nx10651)) ;
    Nor2 ix11155 (.OUT (nx10450), .A (nx10532), .B (nx10449)) ;
    Inv ix11156 (.OUT (nx10451), .A (nx10450)) ;
    Nor3 ix11157 (.OUT (nx10452), .A (nx10527), .B (nx10529), .C (nx10451)) ;
    Nand2 reg_nx8493 (.OUT (nx8493), .A (nx10448), .B (nx10452)) ;
    Inv ix11158 (.OUT (nx10453), .A (nx10532)) ;
    Nand3 ix11159 (.OUT (nx10454), .A (nx10528), .B (nx10651), .C (nx10453)) ;
    Nor3 reg_nx2942 (.OUT (nx2942), .A (nx10526), .B (nx10527), .C (nx10454)) ;
    Nor2 ix11160 (.OUT (nx10455), .A (nx8760), .B (nx8776)) ;
    Nand3 ix11161 (.OUT (nx10456), .A (U_analog_control_cal_cnt_0), .B (
          U_analog_control_cal_cnt_4), .C (nx10455)) ;
    Nand2 ix11162 (.OUT (nx10457), .A (U_analog_control_cal_cnt_2), .B (
          U_analog_control_cal_cnt_1)) ;
    Nor2 reg_nx2917 (.OUT (nx2917), .A (nx10456), .B (nx10457)) ;
    Inv ix11163 (.OUT (nx10458), .A (nx10457)) ;
    Inv ix11164 (.OUT (nx10459), .A (nx8776)) ;
    Nand3 ix11165 (.OUT (nx10460), .A (U_analog_control_cal_cnt_0), .B (
          U_analog_control_cal_cnt_4), .C (nx10459)) ;
    Inv ix11166 (.OUT (nx10461), .A (nx10460)) ;
    Nand2 reg_nx8813 (.OUT (nx8813), .A (nx10458), .B (nx10461)) ;
    Nand2 ix11167 (.OUT (nx10462), .A (U_analog_control_cal_cnt_1), .B (
          U_analog_control_cal_cnt_0)) ;
    Inv ix11168 (.OUT (nx10463), .A (nx8776)) ;
    Nand2 ix11169 (.OUT (nx10464), .A (U_analog_control_cal_cnt_2), .B (nx10463)
          ) ;
    Nor2 reg_nx2914 (.OUT (nx2914), .A (nx10462), .B (nx10464)) ;
    Nand3 reg_nx8809 (.OUT (nx8809), .A (U_analog_control_cal_cnt_0), .B (
          U_analog_control_cal_cnt_2), .C (U_analog_control_cal_cnt_1)) ;
    Nand3 ix11170 (.OUT (nx10465), .A (nx10311), .B (nx9024), .C (nx10213)) ;
    Inv ix11171 (.OUT (nx10466), .A (nx9017)) ;
    Nor2 ix11172 (.OUT (nx10467), .A (nx10466), .B (nx10311)) ;
    Nor2 ix11173 (.OUT (nx10468), .A (nx10466), .B (nx10213)) ;
    Nor2 ix11174 (.OUT (nx10469), .A (nx10467), .B (nx10468)) ;
    Nand2 reg_nx9015 (.OUT (nx9015), .A (nx10465), .B (nx10469)) ;
    Nor4 ix11175 (.OUT (nx10470), .A (nx6781), .B (nx10158), .C (nx10160), .D (
         nx6774)) ;
    Inv ix11176 (.OUT (nx10471), .A (nx6774)) ;
    Nand2 ix11177 (.OUT (nx10472), .A (nx10158), .B (nx10471)) ;
    Nand2 ix11178 (.OUT (nx10473), .A (U_analog_control_sub_cnt_14), .B (nx10472
          )) ;
    Nand2 ix11179 (.OUT (nx10474), .A (U_analog_control_sub_cnt_14), .B (nx6781)
          ) ;
    Nand2 ix11180 (.OUT (nx10475), .A (nx10473), .B (nx10474)) ;
    Nor2 ix11181 (.OUT (nx10476), .A (nx10470), .B (nx10475)) ;
    Nor2 reg_nx3084 (.OUT (nx3084), .A (nx10476), .B (nx9492)) ;
    Inv ix11182 (.OUT (nx10477), .A (nx10160)) ;
    BufI4 ix11183 (.OUT (nx10478), .A (U_analog_control_sub_cnt_12)) ;
    Nor4 ix11184 (.OUT (nx10479), .A (nx6781), .B (nx10477), .C (nx10478), .D (
         nx6774)) ;
    Nor2 ix11185 (.OUT (nx10480), .A (nx10160), .B (nx6774)) ;
    Inv ix11186 (.OUT (nx10481), .A (nx10480)) ;
    Nand2 ix11187 (.OUT (nx10482), .A (U_analog_control_sub_cnt_13), .B (nx10481
          )) ;
    Nand2 ix11188 (.OUT (nx10483), .A (U_analog_control_sub_cnt_13), .B (nx6781)
          ) ;
    Nand2 ix11189 (.OUT (nx10484), .A (nx10482), .B (nx10483)) ;
    Nor2 ix11190 (.OUT (nx10485), .A (nx10479), .B (nx10484)) ;
    Nor2 reg_nx3068 (.OUT (nx3068), .A (nx10485), .B (nx9492)) ;
    Nor3 reg_nx2899 (.OUT (nx2899), .A (nx6781), .B (nx10478), .C (nx6774)) ;
    Nor2 reg_nx2898 (.OUT (nx2898), .A (nx6781), .B (nx6774)) ;
    Inv ix11191 (.OUT (nx10486), .A (tc4_data_31)) ;
    Nor3 ix11192 (.OUT (nx10487), .A (nx10633), .B (nx10486), .C (tc4_data_30)
         ) ;
    Inv ix11193 (.OUT (nx10488), .A (nx4990)) ;
    Inv ix11194 (.OUT (nx10489), .A (nx4978)) ;
    Inv ix11195 (.OUT (nx10490), .A (nx4956)) ;
    Inv ix11196 (.OUT (nx10491), .A (nx4932)) ;
    BufI4 ix11197 (.OUT (nx10492), .A (nx4988)) ;
    Nand4 ix11198 (.OUT (nx10493), .A (nx10489), .B (nx10490), .C (nx10491), .D (
          nx10492)) ;
    Nor3 ix11199 (.OUT (nx10494), .A (nx4942), .B (nx4966), .C (nx10493)) ;
    Nand4 ix11200 (.OUT (nx10495), .A (nx10420), .B (nx10487), .C (nx10488), .D (
          nx10494)) ;
    Nand2 ix11201 (.OUT (nx10496), .A (tc4_data_31), .B (nx10421)) ;
    Nand2 ix11202 (.OUT (nx10497), .A (nx10419), .B (nx10633)) ;
    Nand2 ix11203 (.OUT (nx10498), .A (nx10496), .B (nx10497)) ;
    Nand2 ix11204 (.OUT (nx10499), .A (tc4_data_30), .B (nx10631)) ;
    Inv ix11205 (.OUT (nx10500), .A (nx10499)) ;
    Nand2 ix11206 (.OUT (nx10501), .A (nx10498), .B (nx10500)) ;
    BufI4 ix11207 (.OUT (nx10502), .A (nx10631)) ;
    Nand3 ix11208 (.OUT (nx10503), .A (nx10418), .B (nx10502), .C (nx10633)) ;
    Nand2 ix11209 (.OUT (nx10504), .A (nx10501), .B (nx10503)) ;
    Inv ix11210 (.OUT (nx10505), .A (nx4942)) ;
    Nand3 ix11211 (.OUT (nx10506), .A (nx10490), .B (nx10491), .C (nx10492)) ;
    Nor3 ix11212 (.OUT (nx10507), .A (nx4966), .B (nx4978), .C (nx10506)) ;
    Nand4 ix11213 (.OUT (nx10508), .A (nx10504), .B (nx10488), .C (nx10505), .D (
          nx10507)) ;
    Nand2 ix11214 (.OUT (nx10509), .A (nx10495), .B (nx10508)) ;
    Inv ix11215 (.OUT (nx10510), .A (U_analog_control_mst_cnt_27)) ;
    BufI4 reg_nx9512 (.OUT (nx9512), .A (nx10635)) ;
    Nor3 ix11216 (.OUT (nx10511), .A (nx10510), .B (nx9512), .C (nx2959)) ;
    Inv ix11217 (.OUT (nx10512), .A (nx10511)) ;
    Nor2 ix11218 (.OUT (nx10513), .A (nx9512), .B (nx2959)) ;
    Nand2 ix11219 (.OUT (nx10514), .A (nx2958), .B (nx10513)) ;
    Nand2 reg_nx4820 (.OUT (nx4820), .A (nx10512), .B (nx10514)) ;
    Nand2 ix11220 (.OUT (nx10515), .A (U_analog_control_mst_cnt_1), .B (nx10643)
          ) ;
    Inv ix11221 (.OUT (nx10516), .A (nx10515)) ;
    Nor2 ix11222 (.OUT (nx10517), .A (nx10657), .B (nx10653)) ;
    Nor2 ix11223 (.OUT (nx10518), .A (nx10659), .B (nx10633)) ;
    Nand2 ix11224 (.OUT (nx10519), .A (nx10517), .B (nx10518)) ;
    Nor2 ix11225 (.OUT (nx10520), .A (nx10647), .B (nx10629)) ;
    Nor2 ix11226 (.OUT (nx10521), .A (nx10649), .B (nx10655)) ;
    Nand2 ix11227 (.OUT (nx10522), .A (nx10520), .B (nx10521)) ;
    Nor2 ix11228 (.OUT (nx10523), .A (nx10519), .B (nx10522)) ;
    Nand4 ix11229 (.OUT (nx10524), .A (nx10516), .B (nx10645), .C (nx10651), .D (
          nx10523)) ;
    Nand4 ix11230 (.OUT (nx10525), .A (nx10641), .B (nx10639), .C (nx10637), .D (
          nx10631)) ;
    Nor2 reg_nx2943 (.OUT (nx2943), .A (nx10524), .B (nx10525)) ;
    Nand4 ix11231 (.OUT (nx10526), .A (nx10639), .B (U_analog_control_mst_cnt_1)
          , .C (nx10637), .D (nx10641)) ;
    Nand2 ix11232 (.OUT (nx10527), .A (nx10643), .B (nx10645)) ;
    Nor3 ix11233 (.OUT (nx10528), .A (nx10629), .B (nx10647), .C (nx10649)) ;
    Inv ix11234 (.OUT (nx10529), .A (nx10528)) ;
    Nor2 ix11235 (.OUT (nx10530), .A (nx10653), .B (nx10655)) ;
    Nor2 ix11236 (.OUT (nx10531), .A (nx10657), .B (nx10659)) ;
    Nand2 ix11237 (.OUT (nx10532), .A (nx10530), .B (nx10531)) ;
    Inv ix11238 (.OUT (nx10533), .A (nx4958)) ;
    Nand2 ix11239 (.OUT (nx10534), .A (nx10417), .B (nx10533)) ;
    Nor3 ix11240 (.OUT (nx10535), .A (nx4906), .B (nx10416), .C (nx10534)) ;
    Nor2 ix11241 (.OUT (nx10536), .A (nx10535), .B (pwr_up_acq)) ;
    Inv ix11242 (.OUT (nx10537), .A (nx10536)) ;
    Inv ix11243 (.OUT (nx10538), .A (nx4934)) ;
    Nand2 ix11244 (.OUT (nx10539), .A (nx9376), .B (nx10538)) ;
    Nor3 ix11245 (.OUT (nx10540), .A (nx4980), .B (nx4968), .C (nx10539)) ;
    Nand2 ix11246 (.OUT (nx10541), .A (nx10509), .B (nx10540)) ;
    Inv ix11247 (.OUT (nx10542), .A (pwr_up_acq)) ;
    Nand2 ix11248 (.OUT (nx10543), .A (nx10541), .B (nx10542)) ;
    Nand2 ix11249 (.OUT (nx10544), .A (nx10537), .B (nx10543)) ;
    Nand3 ix11250 (.OUT (nx10545), .A (nx10311), .B (nx10661), .C (nx10213)) ;
    BufI4 ix11251 (.OUT (nx10546), .A (nx10661)) ;
    BufI4 ix11252 (.OUT (nx10547), .A (nx10213)) ;
    Inv ix11253 (.OUT (nx10548), .A (nx10311)) ;
    BufI4 ix11254 (.OUT (nx10549), .A (nx10661)) ;
    AOI22 ix11255 (.OUT (nx10550), .A (nx10546), .B (nx10547), .C (nx10548), .D (
          nx10549)) ;
    Nand2 reg_nx8694 (.OUT (nx8694), .A (nx10545), .B (nx10550)) ;
    Nand2 reg_nx2911 (.OUT (nx2911), .A (nx10213), .B (nx10311)) ;
    Nand2 ix11256 (.OUT (nx10551), .A (U_analog_control_sub_cnt_4), .B (
          U_analog_control_sub_cnt_2)) ;
    Inv ix11257 (.OUT (nx10552), .A (nx10551)) ;
    Nor2 ix11258 (.OUT (nx10553), .A (nx6683), .B (nx6695)) ;
    Nand2 ix11259 (.OUT (nx10554), .A (U_analog_control_sub_cnt_0), .B (nx10553)
          ) ;
    Inv ix11260 (.OUT (nx10555), .A (nx10554)) ;
    Nand4 reg_nx6750 (.OUT (nx6750), .A (U_analog_control_sub_cnt_6), .B (
          nx10552), .C (U_analog_control_sub_cnt_1), .D (nx10555)) ;
    Nand3 ix11261 (.OUT (nx10556), .A (U_analog_control_sub_cnt_1), .B (
          U_analog_control_sub_cnt_0), .C (nx10553)) ;
    Nor2 reg_nx2891 (.OUT (nx2891), .A (nx10551), .B (nx10556)) ;
    Nand2 ix11262 (.OUT (nx10557), .A (U_analog_control_sub_cnt_2), .B (
          U_analog_control_sub_cnt_1)) ;
    Nor2 ix11263 (.OUT (nx10558), .A (nx10136), .B (nx10149)) ;
    Nand2 reg_nx6239 (.OUT (nx6239), .A (nx10140), .B (nx10558)) ;
    Nor3 ix11264 (.OUT (nx10559), .A (nx10021), .B (nx8523), .C (nx8543)) ;
    Inv ix11265 (.OUT (nx10560), .A (nx10559)) ;
    Nor2 ix11266 (.OUT (nx10561), .A (nx9992), .B (nx10560)) ;
    Nand2 ix11267 (.OUT (nx10562), .A (nx10007), .B (nx10561)) ;
    Inv ix11268 (.OUT (nx10563), .A (nx10131)) ;
    Nand2 ix11269 (.OUT (nx10564), .A (nx10562), .B (nx10563)) ;
    Nand2 reg_nx8525 (.OUT (nx8525), .A (nx2943), .B (nx10192)) ;
    Inv ix11270 (.OUT (nx10565), .A (nx10131)) ;
    Nand2 ix11271 (.OUT (nx10566), .A (nx8525), .B (nx10565)) ;
    Nand2 ix11272 (.OUT (nx10567), .A (nx10564), .B (nx10566)) ;
    Nor2 ix11273 (.OUT (nx10568), .A (nx10021), .B (nx8543)) ;
    Nand2 ix11274 (.OUT (nx10569), .A (nx10007), .B (nx10568)) ;
    Inv ix11275 (.OUT (nx10570), .A (nx10007)) ;
    Nand3 reg_nx2006 (.OUT (nx2006), .A (nx10611), .B (nx10205), .C (nx10034)) ;
    BufI4 ix11276 (.OUT (nx10571), .A (nx10633)) ;
    Nor2 ix11277 (.OUT (nx10572), .A (nx10571), .B (tc0_data_15)) ;
    Inv ix11278 (.OUT (nx10573), .A (nx10572)) ;
    BufI4 ix11279 (.OUT (nx10574), .A (nx10633)) ;
    Nand2 ix11280 (.OUT (nx10575), .A (tc0_data_15), .B (nx10574)) ;
    Nand2 ix11281 (.OUT (nx10576), .A (nx10573), .B (nx10575)) ;
    Nor2 ix11282 (.OUT (nx10577), .A (U_analog_control_mst_cnt_30), .B (
         U_analog_control_mst_cnt_31)) ;
    Nor2 ix11283 (.OUT (nx10578), .A (U_analog_control_mst_cnt_28), .B (
         U_analog_control_mst_cnt_29)) ;
    Nand2 reg_NOT_nx8603 (.OUT (NOT_nx8603), .A (nx10577), .B (nx10578)) ;
    Nor2 ix11284 (.OUT (nx10579), .A (U_analog_control_mst_cnt_26), .B (
         U_analog_control_mst_cnt_27)) ;
    Nor2 ix11285 (.OUT (nx10580), .A (U_analog_control_mst_cnt_24), .B (
         U_analog_control_mst_cnt_25)) ;
    Nand2 reg_NOT_nx8565 (.OUT (NOT_nx8565), .A (nx10579), .B (nx10580)) ;
    Nor2 ix11286 (.OUT (nx10581), .A (NOT_nx8603), .B (NOT_nx8565)) ;
    Nand2 ix11287 (.OUT (nx10582), .A (nx10576), .B (nx10581)) ;
    Nor2 ix11288 (.OUT (nx10583), .A (U_analog_control_mst_cnt_18), .B (
         U_analog_control_mst_cnt_19)) ;
    Nor2 ix11289 (.OUT (nx10584), .A (U_analog_control_mst_cnt_16), .B (
         U_analog_control_mst_cnt_17)) ;
    Nor2 ix11290 (.OUT (nx10585), .A (U_analog_control_mst_cnt_22), .B (
         U_analog_control_mst_cnt_23)) ;
    Nor2 ix11291 (.OUT (nx10586), .A (U_analog_control_mst_cnt_20), .B (
         U_analog_control_mst_cnt_21)) ;
    Nand4 ix11292 (.OUT (nx10587), .A (nx10583), .B (nx10584), .C (nx10585), .D (
          nx10586)) ;
    Nor2 ix11293 (.OUT (nx10588), .A (nx10582), .B (nx10587)) ;
    Nor2 ix11294 (.OUT (nx10589), .A (nx10637), .B (tc0_data_12)) ;
    Nand2 ix11295 (.OUT (nx10590), .A (nx10637), .B (tc0_data_12)) ;
    Inv ix11296 (.OUT (nx10591), .A (nx10590)) ;
    Nor2 ix11297 (.OUT (nx10592), .A (nx10589), .B (nx10591)) ;
    Nor2 ix11298 (.OUT (nx10593), .A (nx10629), .B (tc0_data_13)) ;
    Inv ix11299 (.OUT (nx10594), .A (nx10593)) ;
    Nand2 ix11300 (.OUT (nx10595), .A (nx10629), .B (tc0_data_13)) ;
    Nand2 ix11301 (.OUT (nx10596), .A (nx10594), .B (nx10595)) ;
    Inv ix11302 (.OUT (nx10597), .A (tc0_data_14)) ;
    Nand2 ix11303 (.OUT (nx10598), .A (nx10631), .B (nx10597)) ;
    BufI4 ix11304 (.OUT (nx10599), .A (nx10631)) ;
    Nand2 ix11305 (.OUT (nx10600), .A (tc0_data_14), .B (nx10599)) ;
    Nand2 ix11306 (.OUT (nx10601), .A (nx10598), .B (nx10600)) ;
    Nor3 ix11307 (.OUT (nx10602), .A (nx10592), .B (nx10596), .C (nx10601)) ;
    Nand2 reg_nx9282 (.OUT (nx9282), .A (nx10588), .B (nx10602)) ;
    Nand2 reg_NOT_nx8480 (.OUT (NOT_nx8480), .A (nx10583), .B (nx10584)) ;
    Nand2 reg_NOT_nx8527 (.OUT (NOT_nx8527), .A (nx10585), .B (nx10586)) ;
    Nor2 ix11308 (.OUT (nx10603), .A (NOT_nx8480), .B (NOT_nx8527)) ;
    Nand2 reg_nx4906 (.OUT (nx4906), .A (nx10581), .B (nx10603)) ;
    Inv ix11309 (.OUT (nx10604), .A (nx10169)) ;
    Nor2 ix11310 (.OUT (nx10605), .A (nx10604), .B (U_analog_control_cal_cnt_0)
         ) ;
    Nand2 ix11311 (.OUT (nx10606), .A (nx10423), .B (nx10605)) ;
    Nor2 ix11312 (.OUT (nx10607), .A (nx10663), .B (nx10606)) ;
    Nand2 ix11313 (.OUT (nx10608), .A (U_analog_control_cal_cnt_0), .B (nx9564)
          ) ;
    Inv ix11314 (.OUT (nx10609), .A (nx10608)) ;
    Nor2 ix11315 (.OUT (nx10610), .A (nx10607), .B (nx10609)) ;
    Inv reg_nx6129 (.OUT (nx6129), .A (nx10610)) ;
    Nand2 reg_nx1990 (.OUT (nx1990), .A (nx7930), .B (nx10209)) ;
    Nand2 ix11316 (.OUT (nx10611), .A (nx10031), .B (nx1990)) ;
    Nor2 ix11317 (.OUT (nx10612), .A (nx8765), .B (nx2917)) ;
    Nand2 ix11318 (.OUT (nx10613), .A (nx10169), .B (nx10612)) ;
    Inv ix11319 (.OUT (nx10614), .A (nx10613)) ;
    Nand2 ix11320 (.OUT (nx10615), .A (nx10423), .B (nx10614)) ;
    Nor2 ix11321 (.OUT (nx10616), .A (nx10663), .B (nx10615)) ;
    Nand2 ix11322 (.OUT (nx10617), .A (U_analog_control_cal_cnt_5), .B (nx9564)
          ) ;
    Inv ix11323 (.OUT (nx10618), .A (nx10617)) ;
    Nor2 ix11324 (.OUT (nx10619), .A (nx10616), .B (nx10618)) ;
    Inv reg_nx6179 (.OUT (nx6179), .A (nx10619)) ;
    Nor2 ix11325 (.OUT (nx10620), .A (nx8757), .B (nx2918)) ;
    Nand2 ix11326 (.OUT (nx10621), .A (nx10169), .B (nx10620)) ;
    Inv ix11327 (.OUT (nx10622), .A (nx10621)) ;
    Nand2 ix11328 (.OUT (nx10623), .A (nx10423), .B (nx10622)) ;
    Nor2 ix11329 (.OUT (nx10624), .A (nx10663), .B (nx10623)) ;
    Nand2 reg_nx9564 (.OUT (nx9564), .A (nx10169), .B (nx10423)) ;
    Nand2 ix11330 (.OUT (nx10625), .A (U_analog_control_cal_cnt_6), .B (nx9564)
          ) ;
    Inv ix11331 (.OUT (nx10626), .A (nx10625)) ;
    Nor2 ix11332 (.OUT (nx10627), .A (nx10624), .B (nx10626)) ;
    Inv reg_nx6189 (.OUT (nx6189), .A (nx10627)) ;
    Buf4 ix11333 (.OUT (nx10628), .A (nx8358)) ;
    Buf4 ix11334 (.OUT (nx10629), .A (nx8358)) ;
    Buf4 ix11335 (.OUT (nx10630), .A (U_analog_control_mst_cnt_14)) ;
    Buf4 ix11336 (.OUT (nx10631), .A (U_analog_control_mst_cnt_14)) ;
    Buf4 ix11337 (.OUT (nx10632), .A (nx8487)) ;
    Buf4 ix11338 (.OUT (nx10633), .A (nx8487)) ;
    Buf4 ix11339 (.OUT (nx10634), .A (nx3260)) ;
    Buf4 ix11340 (.OUT (nx10635), .A (nx3260)) ;
    Buf4 ix11341 (.OUT (nx10636), .A (U_analog_control_mst_cnt_12)) ;
    Buf4 ix11342 (.OUT (nx10637), .A (U_analog_control_mst_cnt_12)) ;
    Buf4 ix11343 (.OUT (nx10638), .A (U_analog_control_mst_cnt_2)) ;
    Buf4 ix11344 (.OUT (nx10639), .A (U_analog_control_mst_cnt_2)) ;
    Buf4 ix11345 (.OUT (nx10640), .A (U_analog_control_mst_cnt_6)) ;
    Buf4 ix11346 (.OUT (nx10641), .A (U_analog_control_mst_cnt_6)) ;
    Buf4 ix11347 (.OUT (nx10642), .A (U_analog_control_mst_cnt_10)) ;
    Buf4 ix11348 (.OUT (nx10643), .A (U_analog_control_mst_cnt_10)) ;
    Buf4 ix11349 (.OUT (nx10644), .A (U_analog_control_mst_cnt_8)) ;
    Buf4 ix11350 (.OUT (nx10645), .A (U_analog_control_mst_cnt_8)) ;
    Buf4 ix11351 (.OUT (nx10646), .A (nx8382)) ;
    Buf4 ix11352 (.OUT (nx10647), .A (nx8382)) ;
    Buf4 ix11353 (.OUT (nx10648), .A (nx8437)) ;
    Buf4 ix11354 (.OUT (nx10649), .A (nx8437)) ;
    Buf4 ix11355 (.OUT (nx10650), .A (U_analog_control_mst_cnt_4)) ;
    Buf4 ix11356 (.OUT (nx10651), .A (U_analog_control_mst_cnt_4)) ;
    Buf4 ix11357 (.OUT (nx10652), .A (nx8394)) ;
    Buf4 ix11358 (.OUT (nx10653), .A (nx8394)) ;
    Buf4 ix11359 (.OUT (nx10654), .A (nx8418)) ;
    Buf4 ix11360 (.OUT (nx10655), .A (nx8418)) ;
    Buf4 ix11361 (.OUT (nx10656), .A (nx8406)) ;
    Buf4 ix11362 (.OUT (nx10657), .A (nx8406)) ;
    Buf4 ix11363 (.OUT (nx10658), .A (nx8370)) ;
    Buf4 ix11364 (.OUT (nx10659), .A (nx8370)) ;
    Buf4 ix11365 (.OUT (nx10660), .A (nx8689)) ;
    Buf4 ix11366 (.OUT (nx10661), .A (nx8689)) ;
    Buf4 ix11367 (.OUT (nx10662), .A (nx2911)) ;
    Buf4 ix11368 (.OUT (nx10663), .A (nx2911)) ;
endmodule

