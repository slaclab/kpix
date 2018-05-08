//
// Verilog description for cell memory_array_control, 
// Fri Jan 23 17:27:47 2009
//
// LeonardoSpectrum Level 3, 2008b.3 
//


module memory_array_control ( sysclk, reset, command, data_out, out_reset_l, 
                              int_reset_l, reg_clock, reg_sel1, reg_sel0, 
                              pwr_up_acq, reset_load, leakage_null, offset_null, 
                              thresh_off, trig_inh, cal_strobe, pwr_up_acq_dig, 
                              sel_cell, desel_all_cells, ramp_period, 
                              precharge_bus, reg_data, reg_wr_ena, rdback ) ;

    input sysclk ;
    input reset ;
    input command ;
    output data_out ;
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
    output reg_data ;
    output reg_wr_ena ;
    input rdback ;

    wire U_analog_control_int_cur_cell_3, U_analog_control_int_cur_cell_2, 
         U_analog_control_int_cur_cell_1, U_analog_control_int_cur_cell_0, 
         nx3179, U_analog_control_sub_cnt_15, U_analog_control_sub_cnt_14, 
         U_analog_control_sub_cnt_13, U_analog_control_sub_cnt_12, 
         U_analog_control_sub_cnt_11, U_analog_control_sub_cnt_10, 
         U_analog_control_sub_cnt_9, U_analog_control_sub_cnt_8, 
         U_analog_control_sub_cnt_7, U_analog_control_sub_cnt_6, 
         U_analog_control_sub_cnt_5, U_analog_control_sub_cnt_4, 
         U_analog_control_sub_cnt_3, nx3181, nx10, nx32, nx44, nx3185, 
         tc7_data_23, U_command_control_cmd_state_0, 
         U_command_control_int_hdr_data_13, U_command_control_int_hdr_data_11, 
         U_command_control_int_hdr_data_10, U_command_control_int_hdr_data_9, 
         U_command_control_int_hdr_data_8, nx90, 
         U_command_control_int_hdr_data_5, U_command_control_int_hdr_data_6, 
         U_command_control_int_hdr_data_7, nx112, nx120, nx124, nx130, nx3188, 
         nx3189, nx148, nx152, U_command_control_cmd_cnt_5, 
         U_command_control_cmd_cnt_4, nx3191, nx154, nx3193, nx164, nx176, nx184, 
         nx196, nx3199, nx210, nx214, nx240, nx256, nx284, nx288, nx300, nx358, 
         nx380, U_command_control_int_hdr_data_18, 
         U_command_control_int_hdr_data_19, U_command_control_int_hdr_data_20, 
         nx424, U_command_control_int_cmd_en, U_command_control_int_par, nx426, 
         nx454, nx462, nx466, nx474, nx478, nx488, nx498, nx506, nx514, nx520, 
         int_rdback, NOT_sysclk, nx532, cd1_data_0, nx540, nx3201, cd1_data_1, 
         cd1_data_2, cd1_data_3, cd1_data_4, cd1_data_5, cd1_data_6, cd1_data_7, 
         cd1_data_8, cd1_data_9, cd1_data_10, cd1_data_11, cd1_data_12, 
         U_command_control_CD1_data_out_13, U_command_control_CD1_data_out_14, 
         U_command_control_CD1_data_out_15, cd1_data_16, cd1_data_17, 
         cd1_data_18, cd1_data_19, cd1_data_20, cd1_data_21, cd1_data_22, 
         cd1_data_23, cd1_data_24, cd1_data_25, cd1_data_26, cd1_data_27, 
         cd1_data_28, U_command_control_CD1_data_out_29, 
         U_command_control_CD1_data_out_30, U_command_control_CD1_data_out_31, 
         nx564, cd0_data_0, cd0_data_1, cd0_data_2, cd0_data_3, cd0_data_4, 
         cd0_data_5, cd0_data_6, cd0_data_7, cd0_data_8, cd0_data_9, cd0_data_10, 
         cd0_data_11, cd0_data_12, U_command_control_CD0_data_out_13, 
         U_command_control_CD0_data_out_14, U_command_control_CD0_data_out_15, 
         cd0_data_16, cd0_data_17, cd0_data_18, cd0_data_19, cd0_data_20, 
         cd0_data_21, cd0_data_22, cd0_data_23, cd0_data_24, cd0_data_25, 
         cd0_data_26, cd0_data_27, cd0_data_28, 
         U_command_control_CD0_data_out_29, U_command_control_CD0_data_out_30, 
         U_command_control_CD0_data_out_31, nx714, nx848, 
         U_command_control_head_perr, U_command_control_data_perr, nx890, 
         test_mode, nx902, sparse_en, U_command_control_CFG_data_out_2, 
         U_command_control_CFG_data_out_3, U_command_control_CFG_data_out_4, 
         U_command_control_CFG_data_out_5, U_command_control_CFG_data_out_6, 
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
         U_command_control_CFG_data_out_31, nx908, nx1040, tc6_data_0, nx3206, 
         nx1050, tc6_data_1, tc6_data_2, tc6_data_3, tc6_data_4, tc6_data_5, 
         tc6_data_6, tc6_data_7, tc6_data_8, tc6_data_9, tc6_data_10, 
         tc6_data_11, tc6_data_12, tc6_data_13, tc6_data_14, tc6_data_15, 
         tc6_data_16, tc6_data_17, tc6_data_18, tc6_data_19, tc6_data_20, 
         tc6_data_21, tc6_data_22, tc6_data_23, tc6_data_24, tc6_data_25, 
         tc6_data_26, tc6_data_27, tc6_data_28, tc6_data_29, tc6_data_30, 
         tc6_data_31, nx1058, tc7_data_0, tc7_data_1, tc7_data_2, tc7_data_3, 
         tc7_data_4, tc7_data_5, tc7_data_6, tc7_data_7, tc7_data_8, tc7_data_9, 
         tc7_data_10, tc7_data_11, tc7_data_12, tc7_data_13, tc7_data_14, 
         tc7_data_15, tc7_data_16, tc7_data_17, tc7_data_18, tc7_data_19, 
         tc7_data_20, tc7_data_21, tc7_data_22, tc4_data_0, tc4_data_1, 
         tc4_data_2, tc4_data_3, tc4_data_4, tc4_data_5, tc4_data_6, tc4_data_7, 
         tc4_data_8, tc4_data_9, tc4_data_10, tc4_data_11, tc4_data_12, 
         tc4_data_13, tc4_data_14, tc4_data_15, tc4_data_16, tc4_data_17, 
         tc4_data_18, tc4_data_19, tc4_data_20, tc4_data_21, tc4_data_22, 
         tc4_data_23, tc4_data_24, tc4_data_25, tc4_data_26, tc4_data_27, 
         tc4_data_28, tc4_data_29, tc4_data_30, tc4_data_31, nx1294, tc5_data_0, 
         tc5_data_1, tc5_data_2, tc5_data_3, tc5_data_4, tc5_data_5, tc5_data_6, 
         tc5_data_7, tc5_data_8, tc5_data_9, tc5_data_10, tc5_data_11, 
         tc5_data_12, tc5_data_13, tc5_data_14, tc5_data_15, tc5_data_16, 
         tc5_data_17, tc5_data_18, tc5_data_19, tc5_data_20, tc5_data_21, 
         tc5_data_22, tc5_data_23, tc5_data_24, tc5_data_25, tc5_data_26, 
         tc5_data_27, tc5_data_28, tc5_data_29, tc5_data_30, tc5_data_31, nx1436, 
         nx1572, tc1_data_0, nx1580, tc1_data_1, tc1_data_2, tc1_data_3, 
         tc1_data_4, tc1_data_5, tc1_data_6, tc1_data_7, tc1_data_8, tc1_data_9, 
         tc1_data_10, tc1_data_11, tc1_data_12, tc1_data_13, tc1_data_14, 
         tc1_data_15, tc1_data_16, tc1_data_17, tc1_data_18, tc1_data_19, 
         tc1_data_20, tc1_data_21, tc1_data_22, tc1_data_23, tc1_data_24, 
         tc1_data_25, tc1_data_26, tc1_data_27, tc1_data_28, tc1_data_29, 
         tc1_data_30, tc1_data_31, nx1590, tc0_data_0, tc0_data_1, tc0_data_2, 
         tc0_data_3, tc0_data_4, tc0_data_5, tc0_data_6, tc0_data_7, tc0_data_8, 
         tc0_data_9, tc0_data_10, tc0_data_11, tc0_data_12, tc0_data_13, 
         tc0_data_14, tc0_data_15, tc0_data_16, tc0_data_17, tc0_data_18, 
         tc0_data_19, tc0_data_20, tc0_data_21, tc0_data_22, tc0_data_23, 
         tc0_data_24, tc0_data_25, tc0_data_26, tc0_data_27, tc0_data_28, 
         tc0_data_29, tc0_data_30, tc0_data_31, nx1730, nx1864, tc2_data_0, 
         tc2_data_1, tc2_data_2, tc2_data_3, tc2_data_4, tc2_data_5, tc2_data_6, 
         tc2_data_7, tc2_data_8, tc2_data_9, tc2_data_10, tc2_data_11, 
         tc2_data_12, tc2_data_13, tc2_data_14, tc2_data_15, tc2_data_16, 
         tc2_data_17, tc2_data_18, tc2_data_19, tc2_data_20, tc2_data_21, 
         tc2_data_22, tc2_data_23, tc2_data_24, tc2_data_25, tc2_data_26, 
         tc2_data_27, tc2_data_28, tc2_data_29, tc2_data_30, tc2_data_31, nx1874, 
         tc3_data_0, tc3_data_1, tc3_data_2, tc3_data_3, tc3_data_4, tc3_data_5, 
         tc3_data_6, tc3_data_7, tc3_data_8, tc3_data_9, tc3_data_10, 
         tc3_data_11, tc3_data_12, tc3_data_13, tc3_data_14, tc3_data_15, 
         tc3_data_16, tc3_data_17, tc3_data_18, tc3_data_19, tc3_data_20, 
         tc3_data_21, tc3_data_22, tc3_data_23, tc3_data_24, tc3_data_25, 
         tc3_data_26, tc3_data_27, tc3_data_28, tc3_data_29, tc3_data_30, 
         tc3_data_31, nx2012, nx2174, nx2208, nx2220, nx2224, tc7_data_24, 
         tc7_data_25, tc7_data_26, tc7_data_27, tc7_data_28, tc7_data_29, 
         tc7_data_30, tc7_data_31, nx2248, nx2298, nx2312, nx2328, nx2342, 
         nx2360, nx2366, nx2382, nx2384, nx2386, nx2396, nx2416, nx2418, nx2428, 
         nx2430, nx2436, nx2442, nx3209, nx3210, nx2488, nx3211, nx2504, nx2520, 
         nx3213, nx2536, nx3214, nx2552, nx3215, nx2568, nx3216, nx2584, nx3217, 
         nx2600, nx2616, nx3219, nx2632, nx2648, nx3221, nx2664, nx2714, nx2724, 
         nx2734, nx2744, nx2754, nx2762, nx2776, nx2792, start_sequence, nx2812, 
         nx2816, nx2832, sel_addr_reg, nx2850, nx2854, nx2864, nx2870, nx2872, 
         nx2874, U_analog_control_sft_desel_all_cells_16, 
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
         U_analog_control_sft_desel_all_cells_0, nx2880, nx2884, nx2888, nx2902, 
         nx2904, nx2912, nx2930, nx2932, nx2940, nx2950, nx3026, nx3036, 
         U_readout_control_st_cnt_1, U_readout_control_st_cnt_5, 
         U_readout_control_st_cnt_4, nx3222, nx3042, nx3048, nx3223, nx3224, 
         nx3225, nx3090, nx3100, nx3108, U_readout_control_st_cnt_7, 
         U_readout_control_st_cnt_6, nx3226, nx3122, nx3132, nx3140, 
         U_readout_control_st_cnt_8, nx3160, nx3168, nx3172, 
         U_readout_control_rd_state_1, nx3192, U_readout_control_int_evt_cnt_2, 
         U_readout_control_int_data_sft_7, U_readout_control_int_data_sft_6, 
         U_readout_control_int_data_sft_5, U_readout_control_int_data_sft_4, 
         U_readout_control_int_data_sft_3, U_readout_control_int_data_sft_2, 
         U_readout_control_int_data_sft_1, U_readout_control_int_data_sft_0, 
         U_readout_control_int_evt_cnt_1, nx3229, nx3230, nx3248, nx3252, 
         U_readout_control_int_evt_cnt_0, nx3264, nx3276, nx3286, 
         U_readout_control_typ_cnt_0, U_readout_control_typ_cnt_2, 
         U_readout_control_typ_cnt_1, nx3330, nx3338, nx3360, nx3388, nx3233, 
         nx3392, nx3398, U_readout_control_row_cnt_4, 
         U_readout_control_row_cnt_3, U_readout_control_row_cnt_2, 
         U_readout_control_row_cnt_1, U_readout_control_row_cnt_0, nx3418, 
         nx3234, nx3430, nx3235, nx3444, nx3236, nx3458, nx3468, nx3478, nx3494, 
         U_readout_control_col_cnt_4, U_readout_control_col_cnt_3, 
         U_readout_control_col_cnt_2, U_readout_control_col_cnt_1, 
         U_readout_control_col_cnt_0, nx3556, nx3237, nx3570, nx3238, nx3586, 
         nx3239, nx3602, nx3614, nx3642, nx3650, nx3654, nx3660, nx3664, nx3240, 
         nx3670, nx3680, nx3706, nx3708, nx3714, nx3748, nx3762, nx3770, nx3782, 
         nx3788, bunch_clock, nx3798, U_analog_control_cal_state_1, 
         U_analog_control_cal_cnt_11, nx3243, U_analog_control_int_cal_pulse_3, 
         U_analog_control_int_cal_pulse_2, U_analog_control_int_cal_pulse_1, 
         nx3245, U_analog_control_int_cal_pulse_0, nx3247, nx3852, nx3862, 
         nx3872, nx3930, U_analog_control_cal_cnt_10, U_analog_control_cal_cnt_9, 
         U_analog_control_cal_cnt_8, U_analog_control_cal_cnt_7, 
         U_analog_control_cal_cnt_6, U_analog_control_cal_cnt_5, 
         U_analog_control_cal_cnt_4, U_analog_control_cal_cnt_3, 
         U_analog_control_cal_cnt_2, U_analog_control_cal_cnt_1, 
         U_analog_control_cal_cnt_0, nx3254, nx3972, nx3988, nx3256, nx4020, 
         nx3259, nx3261, nx4052, nx3263, nx4068, nx4084, nx4128, 
         U_analog_control_cal_dly_7, nx4164, U_analog_control_cal_dly_9, nx4192, 
         U_analog_control_cal_dly_8, nx4220, U_analog_control_cal_dly_6, nx4260, 
         U_analog_control_cal_dly_5, nx4288, U_analog_control_cal_dly_4, nx4322, 
         U_analog_control_cal_dly_3, nx4350, U_analog_control_cal_dly_0, nx4386, 
         U_analog_control_cal_dly_2, nx4414, U_analog_control_cal_dly_1, nx4442, 
         nx4478, start_calibrate, nx4596, nx4606, nx4614, nx3266, nx4626, nx3267, 
         nx4640, nx4654, nx3269, nx4668, nx4682, nx3272, nx4696, nx4710, nx3274, 
         nx4724, nx3275, nx4738, nx3277, nx4752, nx4766, nx4780, nx4836, nx4850, 
         nx4866, nx4880, nx4978, nx5008, nx5022, nx5038, nx5052, nx5150, nx5352, 
         nx5366, nx5382, nx5396, nx5494, nx5858, nx5864, precharge_dig_bus, 
         nx5894, nx5908, nx5926, nx5984, nx6000, nx6028, 
         U_readout_control_int_par, nx6056, nx6066, nx6072, cmd_reset, nx6092, 
         analog_reset, nx6112, nx6126, nx6142, nx6156, nx6254, load_shift_reg, 
         nx6276, nx6292, nx6300, nx3289, nx3299, nx3309, nx3319, nx3329, nx3339, 
         nx3349, nx3359, nx3369, nx3379, nx3389, nx3399, nx3409, nx3419, nx3429, 
         nx3439, nx3449, nx3459, nx3469, nx3479, nx3489, nx3499, nx3509, nx3519, 
         nx3529, nx3539, nx3549, nx3559, nx3569, nx3579, nx3589, nx3599, nx3609, 
         nx3619, nx3629, nx3639, nx3649, nx3659, nx3669, nx3679, nx3689, nx3699, 
         nx3709, nx3719, nx3729, nx3739, nx3749, nx3759, nx3769, nx3779, nx3789, 
         nx3799, nx3809, nx3819, nx3829, nx3839, nx3849, nx3859, nx3869, nx3879, 
         nx3889, nx3899, nx3909, nx3919, nx3929, nx3939, nx3949, nx3959, nx3969, 
         nx3979, nx3989, nx3999, nx4009, nx4019, nx4029, nx4039, nx4049, nx4059, 
         nx4069, nx4079, nx4089, nx4099, nx4109, nx4119, nx4129, nx4139, nx4149, 
         nx4159, nx4169, nx4179, nx4189, nx4199, nx4209, nx4219, nx4229, nx4239, 
         nx4249, nx4259, nx4269, nx4279, nx4289, nx4299, nx4309, nx4319, nx4329, 
         nx4339, nx4349, nx4359, nx4369, nx4379, nx4389, nx4399, nx4409, nx4419, 
         nx4429, nx4439, nx4449, nx4459, nx4469, nx4479, nx4489, nx4499, nx4509, 
         nx4519, nx4529, nx4539, nx4549, nx4559, nx4569, nx4579, nx4589, nx4599, 
         nx4609, nx4619, nx4629, nx4639, nx4649, nx4659, nx4669, nx4679, nx4689, 
         nx4699, nx4709, nx4719, nx4729, nx4739, nx4749, nx4759, nx4769, nx4779, 
         nx4789, nx4799, nx4809, nx4819, nx4829, nx4839, nx4849, nx4859, nx4869, 
         nx4879, nx4889, nx4899, nx4909, nx4919, nx4929, nx4939, nx4949, nx4959, 
         nx4969, nx4979, nx4989, nx4999, nx5009, nx5019, nx5029, nx5039, nx5049, 
         nx5059, nx5069, nx5079, nx5089, nx5099, nx5109, nx5119, nx5129, nx5139, 
         nx5149, nx5159, nx5169, nx5179, nx5189, nx5199, nx5209, nx5219, nx5229, 
         nx5239, nx5249, nx5259, nx5269, nx5279, nx5289, nx5299, nx5309, nx5319, 
         nx5329, nx5339, nx5349, nx5359, nx5369, nx5379, nx5389, nx5399, nx5409, 
         nx5419, nx5429, nx5439, nx5449, nx5459, nx5469, nx5479, nx5489, nx5499, 
         nx5509, nx5519, nx5529, nx5539, nx5549, nx5559, nx5569, nx5579, nx5589, 
         nx5599, nx5609, nx5619, nx5629, nx5639, nx5649, nx5659, nx5669, nx5679, 
         nx5689, nx5699, nx5709, nx5719, nx5729, nx5739, nx5749, nx5759, nx5769, 
         nx5779, nx5789, nx5799, nx5809, nx5819, nx5829, nx5839, nx5849, nx5859, 
         nx5869, nx5879, nx5889, nx5899, nx5909, nx5919, nx5929, nx5939, nx5949, 
         nx5959, nx5969, nx5979, nx5989, nx5999, nx6009, nx6019, nx6029, nx6039, 
         nx6049, nx6059, nx6069, nx6079, nx6089, nx6099, nx6109, nx6119, nx6129, 
         nx6139, nx6149, nx6159, nx6169, nx6179, nx6189, nx6199, nx6209, nx6219, 
         nx6229, nx6239, nx6249, nx6259, nx6269, nx6279, nx6289, nx6299, nx6309, 
         nx6319, nx6329, nx6339, nx6349, nx6359, nx6369, nx6379, nx6389, nx6399, 
         nx6409, nx6419, nx6429, nx6439, nx6449, nx6459, nx6469, nx6479, nx6489, 
         nx6499, nx6509, nx6519, nx6529, nx6539, nx6549, nx6559, nx6569, nx6579, 
         nx6589, nx6599, nx6609, nx6619, nx6629, nx6639, nx6649, nx6659, nx6669, 
         nx6679, nx6689, nx6699, nx6709, nx6719, nx6729, nx6739, nx6749, nx6759, 
         nx6769, nx6779, nx6789, nx6799, nx6809, nx6819, nx6829, nx6839, nx6849, 
         nx6859, nx6869, nx6879, nx6889, nx6899, nx6909, nx6919, nx6929, nx6939, 
         nx6949, nx6959, nx6969, nx6979, nx6989, nx6999, nx7009, nx7019, nx7029, 
         nx7039, nx7049, nx7059, nx7069, nx7099, nx7109, nx7119, nx7129, nx7139, 
         nx7149, nx7169, nx7179, nx7189, nx7199, nx7209, nx7239, nx7249, nx7269, 
         nx7289, nx7299, nx7309, nx7339, nx7349, nx7359, nx7409, nx7419, nx7433, 
         nx7436, nx7446, nx7455, nx7463, nx7469, nx7475, nx7481, nx7490, nx7493, 
         nx7496, nx7501, nx7517, nx7520, nx7522, nx7525, nx7529, nx7532, nx7535, 
         nx7559, nx7561, nx7566, nx7568, nx7572, nx7576, nx7581, nx7589, nx7590, 
         nx7594, nx7597, nx7604, nx7606, nx7611, nx7694, nx7696, nx7698, nx7701, 
         nx7703, nx7707, nx7709, nx7809, nx7811, nx7913, nx7915, nx7917, nx8016, 
         nx8018, nx8020, nx8057, nx8124, nx8126, nx8226, nx8228, nx8262, nx8329, 
         nx8331, nx8430, nx8432, nx8532, nx8567, nx8571, nx8573, nx8577, nx8579, 
         nx8583, nx8651, nx8653, nx8655, nx8657, nx8756, nx8758, nx8793, nx8800, 
         nx8806, nx8809, nx8814, nx8818, nx8825, nx8828, nx8830, nx8832, nx8836, 
         nx8838, nx8841, nx8844, nx8847, nx8851, nx8854, nx8857, nx8860, nx8862, 
         nx8871, nx8883, nx8888, nx8891, nx8905, nx8910, nx8912, nx8914, nx8921, 
         nx8928, nx8931, nx8935, nx8979, nx8984, nx8991, nx8994, nx8997, nx8999, 
         nx9006, nx9009, nx9012, nx9015, nx9018, nx9021, nx9027, nx9030, nx9034, 
         nx9040, nx9043, nx9047, nx9049, nx9052, nx9057, nx9059, nx9061, nx9066, 
         nx9075, nx9076, nx9080, nx9083, nx9088, nx9090, nx9092, nx9098, nx9102, 
         nx9105, nx9115, nx9117, nx9121, nx9123, nx9129, nx9140, nx9146, nx9149, 
         nx9154, nx9162, nx9165, nx9170, nx9178, nx9179, nx9182, nx9198, nx9201, 
         nx9203, nx9205, nx9208, nx9214, nx9219, nx9222, nx9225, nx9228, nx9231, 
         nx9234, nx9237, nx9240, nx9243, nx9246, nx9249, nx9252, nx9255, nx9261, 
         nx9267, nx9276, nx9288, nx9290, nx9293, nx9296, nx9298, nx9301, nx9304, 
         nx9308, nx9311, nx9314, nx9317, nx9321, nx9324, nx9328, nx9334, nx9336, 
         nx9338, nx9342, nx9345, nx9349, nx9353, nx9356, nx9358, nx9361, nx9365, 
         nx9368, nx9372, nx9376, nx9379, nx9383, nx9387, nx9390, nx9394, nx9402, 
         nx9403, nx9408, nx9411, nx9430, nx9432, nx9434, nx9439, nx9441, nx9443, 
         nx9446, nx9451, nx9454, nx9456, nx9458, nx9468, nx9484, nx9486, nx9491, 
         nx9494, nx9496, nx9518, nx9520, nx9523, nx9525, nx9530, nx9532, nx9534, 
         nx9536, nx9540, nx9544, nx9547, nx9550, nx9552, nx9554, nx9556, nx9577, 
         nx9581, nx9584, nx9587, nx9589, nx9591, nx9594, nx9597, nx9600, nx9602, 
         nx9616, nx9619, nx9624, nx9628, nx9633, nx9637, nx9642, nx9646, nx9649, 
         nx9654, nx9658, nx9665, nx9669, nx9672, nx9676, nx9680, nx9687, nx9691, 
         nx9694, nx9699, nx9703, nx9710, nx9714, nx9717, nx9719, nx9721, nx9725, 
         nx9732, nx9736, nx9739, nx9741, nx9744, nx9748, nx9755, nx9762, nx9766, 
         nx9777, nx9786, nx9789, nx9791, nx9793, nx9795, nx9797, nx9799, nx9801, 
         nx9803, nx9805, nx9807, nx9809, nx9811, nx9813, nx9815, nx9817, nx9819, 
         nx9821, nx9823, nx9825, nx9827, nx9836, nx9840, nx9842, nx9845, nx9875, 
         nx9880, nx9888, nx9891, nx9896, nx9899, nx9907, nx9912, nx9920, nx9923, 
         nx9928, nx9936, nx9939, nx9952, nx9955, nx9964, nx9968, nx9971, nx9975, 
         nx9976, nx9979, nx9981, nx9983, nx9987, nx9997, nx10009, nx10011, 
         nx10014, nx10017, nx10018, nx10020, nx10022, nx10024, nx10027, nx10030, 
         nx10032, nx10038, nx10040, nx10048, nx10050, nx10056, nx10058, nx10063, 
         nx10067, nx10069, nx10076, nx10078, nx10081, nx10085, nx10087, nx10094, 
         nx10096, nx10103, nx10105, nx10111, nx10113, nx10119, nx10121, nx10138, 
         nx10140, nx10142, nx10146, nx10149, nx10151, nx10153, nx10161, nx10163, 
         nx10165, nx10167, nx10170, nx10174, nx10179, nx10183, nx10188, nx10194, 
         nx10201, nx10203, nx10207, nx10213, nx10217, nx10221, nx10223, nx10225, 
         nx10227, nx10231, nx10233, nx10235, nx10237, nx10250, nx10255, nx10259, 
         nx10264, nx10268, nx10273, nx10286, nx10288, nx10292, nx10298, nx10302, 
         nx10308, nx10312, nx10316, nx10318, nx10320, nx10322, nx10328, nx10331, 
         nx10333, nx10335, nx10337, nx10340, nx10342, nx10344, nx10346, nx10349, 
         nx10351, nx10353, nx10355, nx10358, nx10360, nx10362, nx10364, nx10369, 
         nx10371, nx10373, nx10375, nx10377, nx10379, nx10381, nx10383, nx10385, 
         nx10387, nx10389, nx10391, nx10393, nx10395, nx10397, nx10399, nx10401, 
         nx10403, nx10405, nx10407, nx10420, nx10425, nx10429, nx10434, nx10438, 
         nx10443, nx10445, nx10447, nx10449, nx10456, nx10458, nx10462, nx10466, 
         nx10468, nx10470, nx10472, nx10478, nx10482, nx10486, nx10488, nx10490, 
         nx10492, nx10496, nx10499, nx10503, nx10506, nx10509, nx10512, nx10514, 
         nx10516, nx10518, nx10521, nx10523, nx10525, nx10527, nx10530, nx10532, 
         nx10534, nx10536, nx10539, nx10541, nx10543, nx10545, nx10548, nx10551, 
         nx10553, nx10555, nx10557, nx10559, nx10561, nx10563, nx10565, nx10567, 
         nx10569, nx10571, nx10573, nx10575, nx10577, nx10579, nx10581, nx10583, 
         nx10585, nx10587, nx10589, nx10593, nx10596, nx10598, nx10600, nx10602, 
         nx10605, nx10607, nx10609, nx10611, nx10614, nx10616, nx10618, nx10620, 
         nx10623, nx10625, nx10627, nx10629, nx10631, nx10634, nx10636, nx10638, 
         nx10640, nx10642, nx10644, nx10646, nx10648, nx10650, nx10652, nx10654, 
         nx10656, nx10658, nx10660, nx10662, nx10664, nx10666, nx10668, nx10670, 
         nx10672, nx10677, nx10687, nx10693, nx10696, nx10699, nx10704, nx10710, 
         nx10712, nx10714, nx10719, nx10722, nx10731, nx10733, nx10736, nx10747, 
         nx10749, nx10751, nx10753, nx10755, nx10757, nx10759, nx10781, nx10789, 
         nx10797, nx10803, nx10805, nx10811, nx10819, nx10831, nx10833, nx10835, 
         nx10837, nx10839, nx10841, nx10843, nx10845, nx10847, nx10849, nx10851, 
         nx10853, nx10855, nx10857, nx10859, nx10861, nx10863, nx10865, nx10867, 
         nx10869, nx10871, nx10873, nx10875, nx10877, nx10879, nx10881, nx10883, 
         nx10885, nx10887, nx10889, nx10891, nx10893, nx10895, nx10897, nx10899, 
         nx10901, nx10903, nx10905, nx10907, nx10909, nx10911, nx10913, nx10915, 
         nx10917, nx10919, nx10921, nx10927, nx10929, nx10931, nx10933, nx10935, 
         nx10937, nx10939, nx10941, nx10947, nx10957, nx10961, nx10965, nx10969, 
         nx10973, nx10977, nx10979, nx10981, nx10985, nx10989, 
         U_command_control_int_hdr_data_14, nx7565, 
         U_command_control_int_hdr_data_15, nx7564, nx3182, 
         U_analog_control_mst_state_1, nx9405, U_analog_control_mst_state_2, 
         nx9211, U_analog_control_mst_state_0, U_command_control_cmd_cnt_2, 
         nx7472, nx330, U_command_control_cmd_cnt_2__XX0_XREP21, 
         nx7472_XX0_XREP21, U_command_control_cmd_cnt_3, nx7466, nx346, 
         U_command_control_cmd_cnt_3__XX0_XREP23, nx7466_XX0_XREP23, 
         U_command_control_cmd_cnt_1, nx7478, nx314, 
         U_command_control_cmd_cnt_1__XX0_XREP25, nx7478_XX0_XREP25, 
         U_command_control_cmd_cnt_0, nx7511, 
         U_command_control_cmd_cnt_0__XX0_XREP27, nx7511_XX0_XREP27, nx10953, 
         nx10953_XX0_XREP31, U_command_control_int_hdr_data_12, nx7567, 
         U_command_control_int_hdr_data_12__XX0_XREP33, nx7567_XX0_XREP33, 
         nx3195, nx7486, nx7504, nx3195_XX0_XREP35, nx10745, nx7563, 
         nx10745_XX0_XREP37, U_command_control_int_hdr_data_17, nx7562, 
         U_command_control_int_hdr_data_17__XX0_XREP39, nx7562_XX0_XREP39, 
         nx10955, nx10955_XX0_XREP41, nx418, 
         U_command_control_int_hdr_data_15__XX0_XREP3, nx7564_XX0_XREP3, 
         U_command_control_int_hdr_data_14__XX0_XREP1, nx7565_XX0_XREP1, 
         nx418_XX0_XREP45, U_readout_control_st_cnt_3, nx9024, nx3074, 
         U_readout_control_st_cnt_3__XX0_XREP79, nx9024_XX0_XREP79, 
         U_readout_control_st_cnt_2, nx8988, nx3058, 
         U_readout_control_st_cnt_2__XX0_XREP83, nx8988_XX0_XREP83, 
         U_readout_control_st_cnt_0, nx8986, 
         U_readout_control_st_cnt_0__XX0_XREP85, nx8986_XX0_XREP85, 
         U_readout_control_typ_cnt_3, nx8876, nx8940, nx8940_XX0_XREP111, nx3414, 
         nx3410, nx3414_XX0_XREP113, nx8971, nx8973, nx3204, nx8971_XX0_XREP121, 
         nx9176, nx3548, nx9176_XX0_XREP133, U_analog_control_sub_cnt_2, nx9258, 
         nx2472, U_analog_control_sub_cnt_2__XX0_XREP143, nx9258_XX0_XREP143, 
         U_analog_control_sub_cnt_1, nx9264, nx2456, 
         U_analog_control_sub_cnt_1__XX0_XREP145, nx9264_XX0_XREP145, 
         U_analog_control_sub_cnt_0, nx9413, 
         U_analog_control_sub_cnt_0__XX0_XREP147, nx9413_XX0_XREP147, nx10825, 
         nx9623, nx10821, nx9631, nx10817, nx10809, nx10801, nx10793, 
         nx10793_XX0_XREP167, nx10785, nx10785_XX0_XREP169, nx10777_XX0_XREP171, 
         nx10769_XX0_XREP173, nx10765_XX0_XREP175, U_analog_control_cal_state_0, 
         nx9848, nx4562, U_analog_control_cal_state_0__XX0_XREP179, 
         nx9848_XX0_XREP179, nx9989, nx4502, nx4512, nx4534, nx10771, 
         U_analog_control_mst_cnt_14, nx10771_XX0_XREP217, nx10779, 
         U_analog_control_mst_cnt_12, nx10779_XX0_XREP219, nx10787, 
         U_analog_control_mst_cnt_10, nx10787_XX0_XREP221, nx10795, 
         U_analog_control_mst_cnt_8, nx10795_XX0_XREP223, nx10767, 
         U_analog_control_mst_cnt_15, nx10767_XX0_XREP231, nx10829, nx3187, 
         nx10829_XX0_XREP249, U_readout_control_rd_state_0, nx8864, nx3730, 
         U_readout_control_rd_state_0__XX0_XREP291, nx8864_XX0_XREP291, 
         U_readout_control_rd_state_2, nx8907, nx3630, 
         U_readout_control_rd_state_2__XX0_XREP297, nx8907_XX0_XREP297, 
         U_readout_control_typ_cnt_3__XX0_XREP89, nx8876_XX0_XREP89, nx3384, 
         U_readout_control_typ_cnt_3__XX0_XREP89_XX0_XREP303, 
         nx8876_XX0_XREP89_XX0_XREP303, nx3542, nx3198, nx9064, 
         nx3542_XX0_XREP323, nx10817_XX0_XREP161, U_analog_control_mst_cnt_2, 
         nx10809_XX0_XREP163, U_analog_control_mst_cnt_4, nx10801_XX0_XREP165, 
         U_analog_control_mst_cnt_6, U_command_control_cmd_state_2, nx7444, 
         nx220, U_command_control_cmd_state_2__XX0_XREP465, nx7444_XX0_XREP465, 
         U_command_control_cmd_state_1, nx7452, nx262, 
         U_command_control_cmd_state_1__XX0_XREP471, nx7452_XX0_XREP471, nx8944, 
         nx11435, nx11436, nx11437, nx11438, nx11439, nx11440, nx11441, nx11442, 
         nx11443, nx11444, nx11445, nx11446, nx11447, nx11448, nx11449, nx4818, 
         nx11450, nx11451, nx11452, nx10987, nx11453, nx11454, nx11455, nx11456, 
         nx11457, nx11458, nx11459, nx11460, nx11461, nx11462, nx11463, nx11464, 
         nx11465, nx11466, nx11467, nx11468, nx11469, nx11470, nx11471, nx11472, 
         nx11473, nx11474, nx11475, nx11476, nx11477, nx3182_XX0_XREP11, nx3822, 
         nx11478, nx11479, nx11480, nx11481, nx11482, nx11483, nx11484, nx11485, 
         nx11486, nx11487, nx11488, nx11489, nx9832, nx3241, nx11490, nx11491, 
         nx11492, nx11493, nx11494, nx11495, nx11496, nx11497, nx4808, nx10983, 
         nx11498, nx11499, NOT_nx530, nx11500, nx11501, nx11502, nx11503, 
         nx11504, nx11505, nx11506, nx11507, nx142, nx11508, nx11509, nx11510, 
         nx11511, nx11512, nx7441, nx11513, nx11514, nx7617, nx11515, nx11516, 
         nx11517, nx11518, nx11519, nx11520, nx11521, nx11522, nx11523, nx3203, 
         nx11524, nx11525, nx11526, nx11527, nx11528, nx11529, nx2190, nx11530, 
         nx11531, nx11532, nx11533, nx11534, nx11535, nx11536, nx11537, nx11538, 
         nx11539, nx11540, nx11541, nx11542, nx11543, nx11544, nx11545, nx11546, 
         nx11547, nx11548, nx7279, nx10923, nx11549, nx11550, nx11551, nx11552, 
         nx11553, nx10773, nx11554, nx11555, nx11556, nx11557, nx11558, nx11559, 
         nx11560, nx11561, nx4794, nx11562, nx3279, nx11563, nx3278, nx11564, 
         nx11565, nx11566, nx11567, nx11568, nx11569, nx11570, nx11571, nx11572, 
         nx9400, nx11573, nx11574, nx11575, nx11576, nx3220, nx9381, nx11577, 
         nx11578, nx11579, nx11580, nx11581, nx11582, nx11583, nx11584, nx11585, 
         nx11586, nx11587, nx3268, nx10967, nx9651, nx11588, nx11589, nx11590, 
         nx11591, nx11592, nx11593, nx9854, nx11594, nx4482, nx11595, nx11596, 
         nx11597, nx11598, nx11599, nx11600, nx11601, nx10949, nx11602, nx11603, 
         nx11604, nx11605, nx11606, nx11607, nx11608, nx11609, nx11610, nx11611, 
         nx11612, nx11613, nx7329, nx11614, nx11615, nx11616, nx11617, nx11618, 
         nx11619, nx11620, nx11621, nx11622, nx11623, nx11624, nx11625, nx11626, 
         nx11627, nx11628, nx11629, nx4524, nx11630, nx11631, nx11632, nx3212, 
         nx11633, nx11634, nx11635, nx11636, nx9464, nx11637, nx11638, nx11639, 
         nx3183, nx9460, nx11640, nx11641, nx11642, nx11643, nx11644, nx11645, 
         nx11646, nx11647, nx11648, nx11649, nx11650, nx11651, nx11652, nx11653, 
         nx11654, nx9949, nx11655, nx7319, nx3265, nx11656, nx11657, nx9867, 
         nx11658, nx11659, nx11660, nx11661, nx11662, nx11663, nx11664, nx11665, 
         nx11666, nx11667, nx11668, nx11669, nx11670, nx11671, nx11672, nx11673, 
         nx11674, nx11675, nx11676, nx11677, nx11678, nx11679, nx11680, nx11681, 
         nx2164, nx11682, nx11683, nx11684, nx3257, nx11685, nx11686, nx11687, 
         nx11688, nx9960, nx11689, nx11690, nx11691, nx3255, nx9956, nx3482, 
         nx11692, nx11693, nx11694, nx11695, nx8903, nx11696, nx11697, nx11698, 
         nx11699, nx11700, nx11701, nx11702, nx3231_XX0_XREP109, nx11703, 
         nx11704, nx11705, nx11706, nx11707, nx11708, nx11709, nx11710, nx11711, 
         nx11712, nx11713, nx7159, nx11714, nx11715, nx9190, nx11716, nx11717, 
         nx11718, nx11719, nx11720, nx11721, nx11722, nx11723, nx11724, nx11725, 
         nx11726, nx11727, nx11728, nx11729, nx11730, nx11731, nx11732, nx11733, 
         nx11734, nx11735, nx11736, nx11737, nx11738, nx11739, nx11740, nx11741, 
         nx11742, nx11743, nx11744, nx11745, nx11746, nx11747, nx11748, nx11749, 
         nx11750, nx11751, NOT_nx10413, nx11752, nx11753, nx11754, nx11755, 
         nx11756, nx11757, nx11758, nx11759, nx11760, nx10460, nx11761, nx11762, 
         nx11763, nx11764, nx11765, nx11766, nx11767, nx11768, nx11769, nx11770, 
         nx11771, nx11772, nx11773, nx11774, nx11775, nx11776, nx11777, nx11778, 
         nx11779, nx11780, nx7369, nx11781, nx11782, nx11783, nx11784, nx11785, 
         nx11786, nx11787, nx11788, nx11789, nx7379, nx11790, nx11791, nx11792, 
         nx11793, nx11794, nx8901, nx9186, nx11795, nx11796, nx11797, nx11798, 
         nx11799, nx11800, nx11801, nx7079, nx11802, nx11803, nx11804, nx11805, 
         nx11806, nx8873, nx11807, nx11808, nx11809, nx11810, nx11811, nx3273, 
         nx10975, nx11812, nx11813, nx11814, nx9696, nx11815, nx3271, nx10971, 
         nx9674, nx10813, nx11816, nx11817, nx11818, nx11819, nx11820, nx11821, 
         nx11822, nx11823, nx11824, nx11825, nx11826, nx11827, nx10190, nx11828, 
         nx11829, nx11830, nx11831, nx11832, nx11833, nx11834, nx11835, nx11836, 
         nx11837, nx11838, nx11839, nx11840, nx11841, nx11842, nx11843, nx11844, 
         nx11845, nx11846, nx11847, nx11848, nx11849, NOT_nx10158, nx11850, 
         nx11851, nx11852, nx11853, nx11854, nx11855, nx11856, nx11857, nx10205, 
         nx11858, nx11859, nx11860, nx11861, nx11862, nx11863, nx11864, nx11865, 
         nx11866, nx11867, nx11868, nx11869, nx11870, nx11871, nx11872, nx11873, 
         nx11874, nx11875, nx7399, nx11876, nx11877, nx11878, nx11879, nx11880, 
         nx10277, nx11881, nx11882, nx11883, nx11884, nx10275, nx11885, nx11886, 
         nx11887, nx11888, nx10266, nx11889, nx11890, nx11891, nx11892, nx10270, 
         nx11893, nx11894, nx11895, nx11896, nx11897, nx11898, nx11899, nx11900, 
         nx11901, nx10261, nx11902, nx11903, nx11904, nx11905, nx11906, nx10257, 
         nx11907, nx11908, nx11909, nx11910, nx10252, nx11911, nx11912, nx11913, 
         nx11914, nx11915, nx11916, nx11917, nx11918, nx11919, nx11920, nx11921, 
         nx11922, nx11923, nx11924, nx11925, nx11926, NOT_nx10243, nx11927, 
         nx11928, nx11929, nx11930, nx11931, nx11932, nx11933, nx11934, nx10290, 
         nx11935, nx11936, nx11937, nx11938, nx11939, nx11940, nx11941, nx11942, 
         nx11943, nx11944, nx11945, nx11946, nx11947, nx11948, nx11949, nx11950, 
         nx11951, nx11952, nx11953, nx11954, nx11955, nx11956, nx11957, nx11958, 
         nx11959, nx11960, nx11961, nx11962, nx11963, nx11964, nx2822, nx7389, 
         nx9283, nx3218, nx11965, nx11966, nx11967, nx11968, nx11969, nx2676, 
         nx11970, nx11971, nx11972, nx11973, nx11974, nx10144, nx3251, nx8946, 
         nx11975, nx11976, nx11977, nx11978, nx11979, nx11980, nx11981, nx11982, 
         nx11983, nx11984, nx11985, nx11986, nx11987, nx11988, nx11989, 
         nx3384_XX0_XREP311, nx8944_XX0_XREP531, nx11990, nx11991, nx11992, 
         nx11993, nx9112, nx11994, nx11995, nx11996, nx11997, nx11998, nx11999, 
         nx12000, nx12001, nx8949, nx12002, nx12003, nx12004, nx12005, nx12006, 
         nx12007, nx12008, nx12009, nx12010, nx12011, nx12012, nx12013, nx12014, 
         nx12015, nx12016, nx12017, nx12018, nx12019, nx12020, nx12021, nx12022, 
         nx12023, nx12024, nx12025, nx3253, nx12026, nx12027, nx12028, nx12029, 
         nx12030, nx12031, nx12032, nx7229, nx12033, nx12034, nx12035, nx7219, 
         nx10925, nx12036, nx12037, nx12038, nx12039, nx12040, nx7509, nx12041, 
         nx12042, nx12043, nx7507, nx12044, nx12045, nx8803, nx7514, nx204, 
         nx12046, nx10925_XX0_XREP193, nx3208, nx12047, nx12048, nx12049, 
         nx12050, nx12051, nx12052, nx12053, nx12054, nx12055, nx12056, nx12057, 
         nx12058, nx12059, nx12060, nx12061, nx12062, nx12063, nx12064, nx5960, 
         nx12065, nx12066, nx12067, nx12068, nx12069, nx12070, nx12071, nx6024, 
         nx12072, nx12073, nx12074, nx12075, nx6044, nx12076, nx12077, nx12078, 
         nx12079, nx12080, nx12081, nx12082, nx7259, nx10925_XX0_XREP397, 
         nx12083, nx12084, nx3231, nx12085, nx3232, nx3228, nx12086, nx12087, 
         nx12088, nx12089, nx12090, nx12091, nx12092, nx7089, nx12093, nx12094, 
         nx12095, nx12096, nx12097, nx12098, nx12099, nx12100, nx12101, nx12102, 
         nx12103, nx12104, nx12105, nx12106, nx12107, nx12108, nx12109, nx12110, 
         nx12111, nx12112, nx12113, nx12114, nx12115, nx12116;
    wire [436:0] \$dummy ;




    Nor2 ix5875 (.OUT (reg_sel1), .A (nx2872), .B (nx8851)) ;
    Nand2 ix2225 (.OUT (nx2224), .A (nx7433), .B (nx7507)) ;
    Nor2 ix7434 (.OUT (nx7433), .A (nx2220), .B (nx2208)) ;
    Nor3 ix2221 (.OUT (nx2220), .A (nx7436), .B (nx196), .C (nx210)) ;
    AOI22 ix7437 (.OUT (nx7436), .A (U_command_control_int_cmd_en), .B (nx284), 
          .C (U_command_control_cmd_state_2), .D (nx7606)) ;
    Nand4 ix381 (.OUT (nx380), .A (nx7441), .B (nx10831), .C (nx7594), .D (
          nx7507)) ;
    DFFC U_command_control_reg_cmd_state_0 (.Q (U_command_control_cmd_state_0), 
         .QB (nx7446), .D (nx380), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix7456 (.OUT (nx7455), .A (nx10953), .B (nx256)) ;
    Nor4 ix257 (.OUT (nx256), .A (nx204), .B (
         U_command_control_cmd_cnt_3__XX0_XREP23), .C (
         U_command_control_cmd_cnt_0__XX0_XREP27), .D (
         U_command_control_cmd_cnt_1__XX0_XREP25)) ;
    Nor3 ix165 (.OUT (nx164), .A (nx7463), .B (nx3193), .C (nx3195)) ;
    Nor2 ix7464 (.OUT (nx7463), .A (nx154), .B (U_command_control_cmd_cnt_4)) ;
    Nor2 ix155 (.OUT (nx154), .A (nx7466_XX0_XREP23), .B (nx7517)) ;
    Nor2 ix7470 (.OUT (nx7469), .A (nx3191), .B (U_command_control_cmd_cnt_3)) ;
    Nor2 ix7476 (.OUT (nx7475), .A (nx3199), .B (U_command_control_cmd_cnt_2)) ;
    Nor2 ix321 (.OUT (nx3199), .A (nx7478_XX0_XREP25), .B (nx7511_XX0_XREP27)) ;
    Nor2 ix7482 (.OUT (nx7481), .A (U_command_control_cmd_cnt_0__XX0_XREP27), .B (
         U_command_control_cmd_cnt_1__XX0_XREP25)) ;
    Nor2 ix301 (.OUT (nx300), .A (U_command_control_cmd_cnt_0), .B (nx3195)) ;
    Nor2 ix177 (.OUT (nx176), .A (nx7493), .B (nx3195)) ;
    DFFC reg_U_command_control_cmd_cnt_5 (.Q (U_command_control_cmd_cnt_5), .QB (
         nx7490), .D (nx176), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix7497 (.OUT (nx7496), .A (U_command_control_cmd_cnt_4), .B (nx154)) ;
    Nand2 ix289 (.OUT (nx288), .A (nx7501), .B (nx148)) ;
    Nand3 ix7502 (.OUT (nx7501), .A (nx7444_XX0_XREP465), .B (nx7446), .C (
          U_command_control_cmd_state_1__XX0_XREP471)) ;
    Nand2 ix7518 (.OUT (nx7517), .A (U_command_control_cmd_cnt_2__XX0_XREP21), .B (
          nx3199)) ;
    DFFC reg_U_command_control_cmd_cnt_4 (.Q (U_command_control_cmd_cnt_4), .QB (
         nx7520), .D (nx164), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix7523 (.OUT (nx7522), .A (nx240), .B (U_command_control_cmd_state_1)
          , .C (nx7446)) ;
    Nand3 ix241 (.OUT (nx240), .A (nx196), .B (nx7444_XX0_XREP465), .C (nx7525)
          ) ;
    Nand3 ix7530 (.OUT (nx7529), .A (nx130), .B (
          U_command_control_int_hdr_data_12), .C (nx3189)) ;
    Nand2 ix131 (.OUT (nx130), .A (nx7532), .B (nx7566)) ;
    AOI22 ix7533 (.OUT (nx7532), .A (nx120), .B (nx124), .C (nx90), .D (nx112)
          ) ;
    Nor4 ix121 (.OUT (nx120), .A (nx7535), .B (nx7568), .C (nx7572), .D (nx7576)
         ) ;
    DFFC U_command_control_reg_int_hdr_data_11 (.Q (
         U_command_control_int_hdr_data_11), .QB (nx7535), .D (nx3319), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_13 (.Q (
         U_command_control_int_hdr_data_13), .QB (nx7566), .D (nx3299), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_18 (.Q (
         U_command_control_int_hdr_data_18), .QB (nx7561), .D (nx3409), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_19 (.Q (
         U_command_control_int_hdr_data_19), .QB (\$dummy [0]), .D (nx3399), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_20 (.Q (
         U_command_control_int_hdr_data_20), .QB (nx7559), .D (nx3389), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_command (.Q (reg_data), .QB (\$dummy [1]), .D (
         command), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_10 (.Q (
         U_command_control_int_hdr_data_10), .QB (nx7568), .D (nx3329), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_9 (.Q (
         U_command_control_int_hdr_data_9), .QB (nx7572), .D (nx3339), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_8 (.Q (
         U_command_control_int_hdr_data_8), .QB (nx7576), .D (nx3349), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nor3 ix125 (.OUT (nx124), .A (nx7581), .B (nx7589), .C (nx7590)) ;
    DFFC U_command_control_reg_int_hdr_data_5 (.Q (
         U_command_control_int_hdr_data_5), .QB (nx7581), .D (nx3379), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_6 (.Q (
         U_command_control_int_hdr_data_6), .QB (nx7590), .D (nx3369), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_7 (.Q (
         U_command_control_int_hdr_data_7), .QB (nx7589), .D (nx3359), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nor4 ix91 (.OUT (nx90), .A (U_command_control_int_hdr_data_11), .B (
         U_command_control_int_hdr_data_10), .C (
         U_command_control_int_hdr_data_9), .D (U_command_control_int_hdr_data_8
         )) ;
    Nor3 ix113 (.OUT (nx112), .A (U_command_control_int_hdr_data_5), .B (
         U_command_control_int_hdr_data_7), .C (U_command_control_int_hdr_data_6
         )) ;
    Nand3 ix7595 (.OUT (nx7594), .A (reg_data), .B (nx7444), .C (nx7452)) ;
    Nand2 ix215 (.OUT (nx214), .A (nx7525), .B (nx196)) ;
    Nand3 ix7605 (.OUT (nx7604), .A (U_command_control_cmd_state_2__XX0_XREP465)
          , .B (nx7446), .C (U_command_control_cmd_state_1__XX0_XREP471)) ;
    Nor2 ix7607 (.OUT (nx7606), .A (nx7446), .B (nx7452_XX0_XREP471)) ;
    Nor4 ix211 (.OUT (nx210), .A (nx204), .B (nx7466_XX0_XREP23), .C (
         nx7478_XX0_XREP25), .D (nx7511)) ;
    Nor4 ix2209 (.OUT (nx2208), .A (nx3203), .B (nx7532), .C (nx8800), .D (
         nx8838)) ;
    DFFC U_command_control_reg_int_par (.Q (U_command_control_int_par), .QB (
         nx7611), .D (nx2190), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFP U_command_control_TC3_reg_reg_data_0 (.Q (tc3_data_0), .QB (\$dummy [2]
         ), .D (nx6889), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6890 (.OUT (nx6889), .A (tc3_data_0), .B (tc3_data_1), .SEL (nx10847)
         ) ;
    DFFP U_command_control_TC3_reg_reg_data_1 (.Q (tc3_data_1), .QB (\$dummy [3]
         ), .D (nx6879), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6880 (.OUT (nx6879), .A (tc3_data_1), .B (tc3_data_2), .SEL (nx10847)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_2 (.Q (tc3_data_2), .QB (\$dummy [4]
         ), .D (nx6869), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6870 (.OUT (nx6869), .A (tc3_data_2), .B (tc3_data_3), .SEL (nx10847)
         ) ;
    DFFP U_command_control_TC3_reg_reg_data_3 (.Q (tc3_data_3), .QB (\$dummy [5]
         ), .D (nx6859), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6860 (.OUT (nx6859), .A (tc3_data_3), .B (tc3_data_4), .SEL (nx10847)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_4 (.Q (tc3_data_4), .QB (\$dummy [6]
         ), .D (nx6849), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6850 (.OUT (nx6849), .A (tc3_data_4), .B (tc3_data_5), .SEL (nx10847)
         ) ;
    DFFP U_command_control_TC3_reg_reg_data_5 (.Q (tc3_data_5), .QB (\$dummy [7]
         ), .D (nx6839), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6840 (.OUT (nx6839), .A (tc3_data_5), .B (tc3_data_6), .SEL (nx10845)
         ) ;
    DFFP U_command_control_TC3_reg_reg_data_6 (.Q (tc3_data_6), .QB (\$dummy [8]
         ), .D (nx6829), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6830 (.OUT (nx6829), .A (tc3_data_6), .B (tc3_data_7), .SEL (nx10845)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_7 (.Q (tc3_data_7), .QB (\$dummy [9]
         ), .D (nx6819), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6820 (.OUT (nx6819), .A (tc3_data_7), .B (tc3_data_8), .SEL (nx10845)
         ) ;
    DFFP U_command_control_TC3_reg_reg_data_8 (.Q (tc3_data_8), .QB (
         \$dummy [10]), .D (nx6809), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6810 (.OUT (nx6809), .A (tc3_data_8), .B (tc3_data_9), .SEL (nx10845)
         ) ;
    DFFC U_command_control_TC3_reg_reg_data_9 (.Q (tc3_data_9), .QB (
         \$dummy [11]), .D (nx6799), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6800 (.OUT (nx6799), .A (tc3_data_9), .B (tc3_data_10), .SEL (nx10845
         )) ;
    DFFC U_command_control_TC3_reg_reg_data_10 (.Q (tc3_data_10), .QB (
         \$dummy [12]), .D (nx6789), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6790 (.OUT (nx6789), .A (tc3_data_10), .B (tc3_data_11), .SEL (
         nx10845)) ;
    DFFC U_command_control_TC3_reg_reg_data_11 (.Q (tc3_data_11), .QB (
         \$dummy [13]), .D (nx6779), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6780 (.OUT (nx6779), .A (tc3_data_11), .B (tc3_data_12), .SEL (
         nx10845)) ;
    DFFC U_command_control_TC3_reg_reg_data_12 (.Q (tc3_data_12), .QB (
         \$dummy [14]), .D (nx6769), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6770 (.OUT (nx6769), .A (tc3_data_12), .B (tc3_data_13), .SEL (
         nx10845)) ;
    DFFC U_command_control_TC3_reg_reg_data_13 (.Q (tc3_data_13), .QB (
         \$dummy [15]), .D (nx6759), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6760 (.OUT (nx6759), .A (tc3_data_13), .B (tc3_data_14), .SEL (
         nx10845)) ;
    DFFC U_command_control_TC3_reg_reg_data_14 (.Q (tc3_data_14), .QB (
         \$dummy [16]), .D (nx6749), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6750 (.OUT (nx6749), .A (tc3_data_14), .B (tc3_data_15), .SEL (
         nx10843)) ;
    DFFC U_command_control_TC3_reg_reg_data_15 (.Q (tc3_data_15), .QB (
         \$dummy [17]), .D (nx6739), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6740 (.OUT (nx6739), .A (tc3_data_15), .B (tc3_data_16), .SEL (
         nx10843)) ;
    DFFC U_command_control_TC3_reg_reg_data_16 (.Q (tc3_data_16), .QB (
         \$dummy [18]), .D (nx6729), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6730 (.OUT (nx6729), .A (tc3_data_16), .B (tc3_data_17), .SEL (
         nx10843)) ;
    DFFP U_command_control_TC3_reg_reg_data_17 (.Q (tc3_data_17), .QB (
         \$dummy [19]), .D (nx6719), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6720 (.OUT (nx6719), .A (tc3_data_17), .B (tc3_data_18), .SEL (
         nx10843)) ;
    DFFC U_command_control_TC3_reg_reg_data_18 (.Q (tc3_data_18), .QB (
         \$dummy [20]), .D (nx6709), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6710 (.OUT (nx6709), .A (tc3_data_18), .B (tc3_data_19), .SEL (
         nx10843)) ;
    DFFC U_command_control_TC3_reg_reg_data_19 (.Q (tc3_data_19), .QB (
         \$dummy [21]), .D (nx6699), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6700 (.OUT (nx6699), .A (tc3_data_19), .B (tc3_data_20), .SEL (
         nx10843)) ;
    DFFC U_command_control_TC3_reg_reg_data_20 (.Q (tc3_data_20), .QB (
         \$dummy [22]), .D (nx6689), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6690 (.OUT (nx6689), .A (tc3_data_20), .B (tc3_data_21), .SEL (
         nx10843)) ;
    DFFC U_command_control_TC3_reg_reg_data_21 (.Q (tc3_data_21), .QB (
         \$dummy [23]), .D (nx6679), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6680 (.OUT (nx6679), .A (tc3_data_21), .B (tc3_data_22), .SEL (
         nx10843)) ;
    DFFP U_command_control_TC3_reg_reg_data_22 (.Q (tc3_data_22), .QB (
         \$dummy [24]), .D (nx6669), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6670 (.OUT (nx6669), .A (tc3_data_22), .B (tc3_data_23), .SEL (
         nx10843)) ;
    DFFC U_command_control_TC3_reg_reg_data_23 (.Q (tc3_data_23), .QB (
         \$dummy [25]), .D (nx6659), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6660 (.OUT (nx6659), .A (tc3_data_23), .B (tc3_data_24), .SEL (
         nx10841)) ;
    DFFC U_command_control_TC3_reg_reg_data_24 (.Q (tc3_data_24), .QB (
         \$dummy [26]), .D (nx6649), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6650 (.OUT (nx6649), .A (tc3_data_24), .B (tc3_data_25), .SEL (
         nx10841)) ;
    DFFC U_command_control_TC3_reg_reg_data_25 (.Q (tc3_data_25), .QB (
         \$dummy [27]), .D (nx6639), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6640 (.OUT (nx6639), .A (tc3_data_25), .B (tc3_data_26), .SEL (
         nx10841)) ;
    DFFP U_command_control_TC3_reg_reg_data_26 (.Q (tc3_data_26), .QB (
         \$dummy [28]), .D (nx6629), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6630 (.OUT (nx6629), .A (tc3_data_26), .B (tc3_data_27), .SEL (
         nx10841)) ;
    DFFP U_command_control_TC3_reg_reg_data_27 (.Q (tc3_data_27), .QB (
         \$dummy [29]), .D (nx6619), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6620 (.OUT (nx6619), .A (tc3_data_27), .B (tc3_data_28), .SEL (
         nx10841)) ;
    DFFP U_command_control_TC3_reg_reg_data_28 (.Q (tc3_data_28), .QB (
         \$dummy [30]), .D (nx6609), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6610 (.OUT (nx6609), .A (tc3_data_28), .B (tc3_data_29), .SEL (
         nx10841)) ;
    DFFC U_command_control_TC3_reg_reg_data_29 (.Q (tc3_data_29), .QB (
         \$dummy [31]), .D (nx6599), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6600 (.OUT (nx6599), .A (tc3_data_29), .B (tc3_data_30), .SEL (
         nx10841)) ;
    DFFP U_command_control_TC3_reg_reg_data_30 (.Q (tc3_data_30), .QB (
         \$dummy [32]), .D (nx6589), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6590 (.OUT (nx6589), .A (tc3_data_30), .B (tc3_data_31), .SEL (
         nx10841)) ;
    DFFC U_command_control_TC3_reg_reg_data_31 (.Q (tc3_data_31), .QB (
         \$dummy [33]), .D (nx6579), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6580 (.OUT (nx6579), .A (tc3_data_31), .B (nx2012), .SEL (nx10841)) ;
    Nand2 ix2013 (.OUT (nx2012), .A (nx7694), .B (nx10837)) ;
    Nand2 ix7695 (.OUT (nx7694), .A (tc3_data_0), .B (nx10835)) ;
    Nand2 ix7699 (.OUT (nx7698), .A (reg_wr_ena), .B (reg_data)) ;
    Nor2 ix557 (.OUT (reg_wr_ena), .A (nx7566), .B (nx7701)) ;
    DFFC U_command_control_reg_int_cmd_en (.Q (U_command_control_int_cmd_en), .QB (
         nx7701), .D (nx2224), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix7704 (.OUT (nx7703), .A (nx418_XX0_XREP45), .B (nx1580)) ;
    Nor3 ix1581 (.OUT (nx1580), .A (nx7707), .B (nx7562), .C (nx10745)) ;
    Nand3 ix7708 (.OUT (nx7707), .A (nx7709), .B (nx7561), .C (nx3201)) ;
    Nor2 ix7710 (.OUT (nx7709), .A (U_command_control_int_hdr_data_19), .B (
         U_command_control_int_hdr_data_20)) ;
    Nor2 ix2231 (.OUT (nx3201), .A (nx7567_XX0_XREP33), .B (nx7701)) ;
    DFFC U_command_control_TC2_reg_reg_data_0 (.Q (tc2_data_0), .QB (
         \$dummy [34]), .D (nx6569), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6570 (.OUT (nx6569), .A (tc2_data_0), .B (tc2_data_1), .SEL (nx10855)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_1 (.Q (tc2_data_1), .QB (
         \$dummy [35]), .D (nx6559), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6560 (.OUT (nx6559), .A (tc2_data_1), .B (tc2_data_2), .SEL (nx10855)
         ) ;
    DFFP U_command_control_TC2_reg_reg_data_2 (.Q (tc2_data_2), .QB (
         \$dummy [36]), .D (nx6549), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6550 (.OUT (nx6549), .A (tc2_data_2), .B (tc2_data_3), .SEL (nx10855)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_3 (.Q (tc2_data_3), .QB (
         \$dummy [37]), .D (nx6539), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6540 (.OUT (nx6539), .A (tc2_data_3), .B (tc2_data_4), .SEL (nx10855)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_4 (.Q (tc2_data_4), .QB (
         \$dummy [38]), .D (nx6529), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6530 (.OUT (nx6529), .A (tc2_data_4), .B (tc2_data_5), .SEL (nx10855)
         ) ;
    DFFP U_command_control_TC2_reg_reg_data_5 (.Q (tc2_data_5), .QB (
         \$dummy [39]), .D (nx6519), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6520 (.OUT (nx6519), .A (tc2_data_5), .B (tc2_data_6), .SEL (nx10853)
         ) ;
    DFFP U_command_control_TC2_reg_reg_data_6 (.Q (tc2_data_6), .QB (
         \$dummy [40]), .D (nx6509), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6510 (.OUT (nx6509), .A (tc2_data_6), .B (tc2_data_7), .SEL (nx10853)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_7 (.Q (tc2_data_7), .QB (
         \$dummy [41]), .D (nx6499), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6500 (.OUT (nx6499), .A (tc2_data_7), .B (tc2_data_8), .SEL (nx10853)
         ) ;
    DFFP U_command_control_TC2_reg_reg_data_8 (.Q (tc2_data_8), .QB (
         \$dummy [42]), .D (nx6489), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6490 (.OUT (nx6489), .A (tc2_data_8), .B (tc2_data_9), .SEL (nx10853)
         ) ;
    DFFC U_command_control_TC2_reg_reg_data_9 (.Q (tc2_data_9), .QB (
         \$dummy [43]), .D (nx6479), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6480 (.OUT (nx6479), .A (tc2_data_9), .B (tc2_data_10), .SEL (nx10853
         )) ;
    DFFC U_command_control_TC2_reg_reg_data_10 (.Q (tc2_data_10), .QB (
         \$dummy [44]), .D (nx6469), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6470 (.OUT (nx6469), .A (tc2_data_10), .B (tc2_data_11), .SEL (
         nx10853)) ;
    DFFC U_command_control_TC2_reg_reg_data_11 (.Q (tc2_data_11), .QB (
         \$dummy [45]), .D (nx6459), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6460 (.OUT (nx6459), .A (tc2_data_11), .B (tc2_data_12), .SEL (
         nx10853)) ;
    DFFC U_command_control_TC2_reg_reg_data_12 (.Q (tc2_data_12), .QB (
         \$dummy [46]), .D (nx6449), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6450 (.OUT (nx6449), .A (tc2_data_12), .B (tc2_data_13), .SEL (
         nx10853)) ;
    DFFC U_command_control_TC2_reg_reg_data_13 (.Q (tc2_data_13), .QB (
         \$dummy [47]), .D (nx6439), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6440 (.OUT (nx6439), .A (tc2_data_13), .B (tc2_data_14), .SEL (
         nx10853)) ;
    DFFC U_command_control_TC2_reg_reg_data_14 (.Q (tc2_data_14), .QB (
         \$dummy [48]), .D (nx6429), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6430 (.OUT (nx6429), .A (tc2_data_14), .B (tc2_data_15), .SEL (
         nx10851)) ;
    DFFC U_command_control_TC2_reg_reg_data_15 (.Q (tc2_data_15), .QB (
         \$dummy [49]), .D (nx6419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6420 (.OUT (nx6419), .A (tc2_data_15), .B (tc2_data_16), .SEL (
         nx10851)) ;
    DFFC U_command_control_TC2_reg_reg_data_16 (.Q (tc2_data_16), .QB (
         \$dummy [50]), .D (nx6409), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6410 (.OUT (nx6409), .A (tc2_data_16), .B (tc2_data_17), .SEL (
         nx10851)) ;
    DFFP U_command_control_TC2_reg_reg_data_17 (.Q (tc2_data_17), .QB (
         \$dummy [51]), .D (nx6399), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6400 (.OUT (nx6399), .A (tc2_data_17), .B (tc2_data_18), .SEL (
         nx10851)) ;
    DFFC U_command_control_TC2_reg_reg_data_18 (.Q (tc2_data_18), .QB (
         \$dummy [52]), .D (nx6389), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6390 (.OUT (nx6389), .A (tc2_data_18), .B (tc2_data_19), .SEL (
         nx10851)) ;
    DFFC U_command_control_TC2_reg_reg_data_19 (.Q (tc2_data_19), .QB (
         \$dummy [53]), .D (nx6379), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6380 (.OUT (nx6379), .A (tc2_data_19), .B (tc2_data_20), .SEL (
         nx10851)) ;
    DFFC U_command_control_TC2_reg_reg_data_20 (.Q (tc2_data_20), .QB (
         \$dummy [54]), .D (nx6369), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6370 (.OUT (nx6369), .A (tc2_data_20), .B (tc2_data_21), .SEL (
         nx10851)) ;
    DFFC U_command_control_TC2_reg_reg_data_21 (.Q (tc2_data_21), .QB (
         \$dummy [55]), .D (nx6359), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6360 (.OUT (nx6359), .A (tc2_data_21), .B (tc2_data_22), .SEL (
         nx10851)) ;
    DFFP U_command_control_TC2_reg_reg_data_22 (.Q (tc2_data_22), .QB (
         \$dummy [56]), .D (nx6349), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6350 (.OUT (nx6349), .A (tc2_data_22), .B (tc2_data_23), .SEL (
         nx10851)) ;
    DFFC U_command_control_TC2_reg_reg_data_23 (.Q (tc2_data_23), .QB (
         \$dummy [57]), .D (nx6339), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6340 (.OUT (nx6339), .A (tc2_data_23), .B (tc2_data_24), .SEL (
         nx10849)) ;
    DFFC U_command_control_TC2_reg_reg_data_24 (.Q (tc2_data_24), .QB (
         \$dummy [58]), .D (nx6329), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6330 (.OUT (nx6329), .A (tc2_data_24), .B (tc2_data_25), .SEL (
         nx10849)) ;
    DFFC U_command_control_TC2_reg_reg_data_25 (.Q (tc2_data_25), .QB (
         \$dummy [59]), .D (nx6319), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6320 (.OUT (nx6319), .A (tc2_data_25), .B (tc2_data_26), .SEL (
         nx10849)) ;
    DFFP U_command_control_TC2_reg_reg_data_26 (.Q (tc2_data_26), .QB (
         \$dummy [60]), .D (nx6309), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6310 (.OUT (nx6309), .A (tc2_data_26), .B (tc2_data_27), .SEL (
         nx10849)) ;
    DFFP U_command_control_TC2_reg_reg_data_27 (.Q (tc2_data_27), .QB (
         \$dummy [61]), .D (nx6299), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6300 (.OUT (nx6299), .A (tc2_data_27), .B (tc2_data_28), .SEL (
         nx10849)) ;
    DFFP U_command_control_TC2_reg_reg_data_28 (.Q (tc2_data_28), .QB (
         \$dummy [62]), .D (nx6289), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6290 (.OUT (nx6289), .A (tc2_data_28), .B (tc2_data_29), .SEL (
         nx10849)) ;
    DFFC U_command_control_TC2_reg_reg_data_29 (.Q (tc2_data_29), .QB (
         \$dummy [63]), .D (nx6279), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6280 (.OUT (nx6279), .A (tc2_data_29), .B (tc2_data_30), .SEL (
         nx10849)) ;
    DFFP U_command_control_TC2_reg_reg_data_30 (.Q (tc2_data_30), .QB (
         \$dummy [64]), .D (nx6269), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6270 (.OUT (nx6269), .A (tc2_data_30), .B (tc2_data_31), .SEL (
         nx10849)) ;
    DFFC U_command_control_TC2_reg_reg_data_31 (.Q (tc2_data_31), .QB (
         \$dummy [65]), .D (nx6259), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6260 (.OUT (nx6259), .A (tc2_data_31), .B (nx1874), .SEL (nx10849)) ;
    Nand2 ix1875 (.OUT (nx1874), .A (nx7809), .B (nx10837)) ;
    Nand2 ix7810 (.OUT (nx7809), .A (tc2_data_0), .B (nx10835)) ;
    Nand2 ix7812 (.OUT (nx7811), .A (nx1580), .B (nx1050)) ;
    Nor2 ix1051 (.OUT (nx1050), .A (nx7564_XX0_XREP3), .B (
         U_command_control_int_hdr_data_14__XX0_XREP1)) ;
    DFFC U_command_control_TC1_reg_reg_data_0 (.Q (tc1_data_0), .QB (
         \$dummy [66]), .D (nx5929), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5930 (.OUT (nx5929), .A (tc1_data_0), .B (tc1_data_1), .SEL (nx10863)
         ) ;
    DFFP U_command_control_TC1_reg_reg_data_1 (.Q (tc1_data_1), .QB (
         \$dummy [67]), .D (nx5919), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5920 (.OUT (nx5919), .A (tc1_data_1), .B (tc1_data_2), .SEL (nx10863)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_2 (.Q (tc1_data_2), .QB (
         \$dummy [68]), .D (nx5909), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5910 (.OUT (nx5909), .A (tc1_data_2), .B (tc1_data_3), .SEL (nx10863)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_3 (.Q (tc1_data_3), .QB (
         \$dummy [69]), .D (nx5899), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5900 (.OUT (nx5899), .A (tc1_data_3), .B (tc1_data_4), .SEL (nx10863)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_4 (.Q (tc1_data_4), .QB (
         \$dummy [70]), .D (nx5889), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5890 (.OUT (nx5889), .A (tc1_data_4), .B (tc1_data_5), .SEL (nx10863)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_5 (.Q (tc1_data_5), .QB (
         \$dummy [71]), .D (nx5879), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5880 (.OUT (nx5879), .A (tc1_data_5), .B (tc1_data_6), .SEL (nx10861)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_6 (.Q (tc1_data_6), .QB (
         \$dummy [72]), .D (nx5869), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5870 (.OUT (nx5869), .A (tc1_data_6), .B (tc1_data_7), .SEL (nx10861)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_7 (.Q (tc1_data_7), .QB (
         \$dummy [73]), .D (nx5859), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5860 (.OUT (nx5859), .A (tc1_data_7), .B (tc1_data_8), .SEL (nx10861)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_8 (.Q (tc1_data_8), .QB (
         \$dummy [74]), .D (nx5849), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5850 (.OUT (nx5849), .A (tc1_data_8), .B (tc1_data_9), .SEL (nx10861)
         ) ;
    DFFC U_command_control_TC1_reg_reg_data_9 (.Q (tc1_data_9), .QB (
         \$dummy [75]), .D (nx5839), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5840 (.OUT (nx5839), .A (tc1_data_9), .B (tc1_data_10), .SEL (nx10861
         )) ;
    DFFC U_command_control_TC1_reg_reg_data_10 (.Q (tc1_data_10), .QB (
         \$dummy [76]), .D (nx5829), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5830 (.OUT (nx5829), .A (tc1_data_10), .B (tc1_data_11), .SEL (
         nx10861)) ;
    DFFC U_command_control_TC1_reg_reg_data_11 (.Q (tc1_data_11), .QB (
         \$dummy [77]), .D (nx5819), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5820 (.OUT (nx5819), .A (tc1_data_11), .B (tc1_data_12), .SEL (
         nx10861)) ;
    DFFC U_command_control_TC1_reg_reg_data_12 (.Q (tc1_data_12), .QB (
         \$dummy [78]), .D (nx5809), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5810 (.OUT (nx5809), .A (tc1_data_12), .B (tc1_data_13), .SEL (
         nx10861)) ;
    DFFC U_command_control_TC1_reg_reg_data_13 (.Q (tc1_data_13), .QB (
         \$dummy [79]), .D (nx5799), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5800 (.OUT (nx5799), .A (tc1_data_13), .B (tc1_data_14), .SEL (
         nx10861)) ;
    DFFC U_command_control_TC1_reg_reg_data_14 (.Q (tc1_data_14), .QB (
         \$dummy [80]), .D (nx5789), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5790 (.OUT (nx5789), .A (tc1_data_14), .B (tc1_data_15), .SEL (
         nx10859)) ;
    DFFC U_command_control_TC1_reg_reg_data_15 (.Q (tc1_data_15), .QB (
         \$dummy [81]), .D (nx5779), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5780 (.OUT (nx5779), .A (tc1_data_15), .B (tc1_data_16), .SEL (
         nx10859)) ;
    DFFC U_command_control_TC1_reg_reg_data_16 (.Q (tc1_data_16), .QB (
         \$dummy [82]), .D (nx5769), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5770 (.OUT (nx5769), .A (tc1_data_16), .B (tc1_data_17), .SEL (
         nx10859)) ;
    DFFP U_command_control_TC1_reg_reg_data_17 (.Q (tc1_data_17), .QB (
         \$dummy [83]), .D (nx5759), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5760 (.OUT (nx5759), .A (tc1_data_17), .B (tc1_data_18), .SEL (
         nx10859)) ;
    DFFC U_command_control_TC1_reg_reg_data_18 (.Q (tc1_data_18), .QB (
         \$dummy [84]), .D (nx5749), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5750 (.OUT (nx5749), .A (tc1_data_18), .B (tc1_data_19), .SEL (
         nx10859)) ;
    DFFC U_command_control_TC1_reg_reg_data_19 (.Q (tc1_data_19), .QB (
         \$dummy [85]), .D (nx5739), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5740 (.OUT (nx5739), .A (tc1_data_19), .B (tc1_data_20), .SEL (
         nx10859)) ;
    DFFC U_command_control_TC1_reg_reg_data_20 (.Q (tc1_data_20), .QB (
         \$dummy [86]), .D (nx5729), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5730 (.OUT (nx5729), .A (tc1_data_20), .B (tc1_data_21), .SEL (
         nx10859)) ;
    DFFC U_command_control_TC1_reg_reg_data_21 (.Q (tc1_data_21), .QB (
         \$dummy [87]), .D (nx5719), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5720 (.OUT (nx5719), .A (tc1_data_21), .B (tc1_data_22), .SEL (
         nx10859)) ;
    DFFP U_command_control_TC1_reg_reg_data_22 (.Q (tc1_data_22), .QB (
         \$dummy [88]), .D (nx5709), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5710 (.OUT (nx5709), .A (tc1_data_22), .B (tc1_data_23), .SEL (
         nx10859)) ;
    DFFC U_command_control_TC1_reg_reg_data_23 (.Q (tc1_data_23), .QB (
         \$dummy [89]), .D (nx5699), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5700 (.OUT (nx5699), .A (tc1_data_23), .B (tc1_data_24), .SEL (
         nx10857)) ;
    DFFC U_command_control_TC1_reg_reg_data_24 (.Q (tc1_data_24), .QB (
         \$dummy [90]), .D (nx5689), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5690 (.OUT (nx5689), .A (tc1_data_24), .B (tc1_data_25), .SEL (
         nx10857)) ;
    DFFC U_command_control_TC1_reg_reg_data_25 (.Q (tc1_data_25), .QB (
         \$dummy [91]), .D (nx5679), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5680 (.OUT (nx5679), .A (tc1_data_25), .B (tc1_data_26), .SEL (
         nx10857)) ;
    DFFP U_command_control_TC1_reg_reg_data_26 (.Q (tc1_data_26), .QB (
         \$dummy [92]), .D (nx5669), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5670 (.OUT (nx5669), .A (tc1_data_26), .B (tc1_data_27), .SEL (
         nx10857)) ;
    DFFP U_command_control_TC1_reg_reg_data_27 (.Q (tc1_data_27), .QB (
         \$dummy [93]), .D (nx5659), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5660 (.OUT (nx5659), .A (tc1_data_27), .B (tc1_data_28), .SEL (
         nx10857)) ;
    DFFP U_command_control_TC1_reg_reg_data_28 (.Q (tc1_data_28), .QB (
         \$dummy [94]), .D (nx5649), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5650 (.OUT (nx5649), .A (tc1_data_28), .B (tc1_data_29), .SEL (
         nx10857)) ;
    DFFC U_command_control_TC1_reg_reg_data_29 (.Q (tc1_data_29), .QB (
         \$dummy [95]), .D (nx5639), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5640 (.OUT (nx5639), .A (tc1_data_29), .B (tc1_data_30), .SEL (
         nx10857)) ;
    DFFP U_command_control_TC1_reg_reg_data_30 (.Q (tc1_data_30), .QB (
         \$dummy [96]), .D (nx5629), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5630 (.OUT (nx5629), .A (tc1_data_30), .B (tc1_data_31), .SEL (
         nx10857)) ;
    DFFC U_command_control_TC1_reg_reg_data_31 (.Q (tc1_data_31), .QB (
         \$dummy [97]), .D (nx5619), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5620 (.OUT (nx5619), .A (tc1_data_31), .B (nx1590), .SEL (nx10857)) ;
    Nand2 ix1591 (.OUT (nx1590), .A (nx7913), .B (nx10837)) ;
    Nand2 ix7914 (.OUT (nx7913), .A (tc1_data_0), .B (nx10835)) ;
    Nand2 ix7916 (.OUT (nx7915), .A (nx7917), .B (nx1580)) ;
    Nor2 ix7918 (.OUT (nx7917), .A (nx7565_XX0_XREP1), .B (
         U_command_control_int_hdr_data_15__XX0_XREP3)) ;
    DFFP U_command_control_TC0_reg_reg_data_0 (.Q (tc0_data_0), .QB (
         \$dummy [98]), .D (nx6249), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6250 (.OUT (nx6249), .A (tc0_data_0), .B (tc0_data_1), .SEL (nx10871)
         ) ;
    DFFP U_command_control_TC0_reg_reg_data_1 (.Q (tc0_data_1), .QB (
         \$dummy [99]), .D (nx6239), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6240 (.OUT (nx6239), .A (tc0_data_1), .B (tc0_data_2), .SEL (nx10871)
         ) ;
    DFFP U_command_control_TC0_reg_reg_data_2 (.Q (tc0_data_2), .QB (
         \$dummy [100]), .D (nx6229), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6230 (.OUT (nx6229), .A (tc0_data_2), .B (tc0_data_3), .SEL (nx10871)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_3 (.Q (tc0_data_3), .QB (
         \$dummy [101]), .D (nx6219), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6220 (.OUT (nx6219), .A (tc0_data_3), .B (tc0_data_4), .SEL (nx10871)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_4 (.Q (tc0_data_4), .QB (
         \$dummy [102]), .D (nx6209), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6210 (.OUT (nx6209), .A (tc0_data_4), .B (tc0_data_5), .SEL (nx10871)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_5 (.Q (tc0_data_5), .QB (
         \$dummy [103]), .D (nx6199), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6200 (.OUT (nx6199), .A (tc0_data_5), .B (tc0_data_6), .SEL (nx10869)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_6 (.Q (tc0_data_6), .QB (
         \$dummy [104]), .D (nx6189), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6190 (.OUT (nx6189), .A (tc0_data_6), .B (tc0_data_7), .SEL (nx10869)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_7 (.Q (tc0_data_7), .QB (
         \$dummy [105]), .D (nx6179), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6180 (.OUT (nx6179), .A (tc0_data_7), .B (tc0_data_8), .SEL (nx10869)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_8 (.Q (tc0_data_8), .QB (
         \$dummy [106]), .D (nx6169), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6170 (.OUT (nx6169), .A (tc0_data_8), .B (tc0_data_9), .SEL (nx10869)
         ) ;
    DFFC U_command_control_TC0_reg_reg_data_9 (.Q (tc0_data_9), .QB (
         \$dummy [107]), .D (nx6159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6160 (.OUT (nx6159), .A (tc0_data_9), .B (tc0_data_10), .SEL (nx10869
         )) ;
    DFFC U_command_control_TC0_reg_reg_data_10 (.Q (tc0_data_10), .QB (
         \$dummy [108]), .D (nx6149), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6150 (.OUT (nx6149), .A (tc0_data_10), .B (tc0_data_11), .SEL (
         nx10869)) ;
    DFFC U_command_control_TC0_reg_reg_data_11 (.Q (tc0_data_11), .QB (
         \$dummy [109]), .D (nx6139), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6140 (.OUT (nx6139), .A (tc0_data_11), .B (tc0_data_12), .SEL (
         nx10869)) ;
    DFFC U_command_control_TC0_reg_reg_data_12 (.Q (tc0_data_12), .QB (
         \$dummy [110]), .D (nx6129), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6130 (.OUT (nx6129), .A (tc0_data_12), .B (tc0_data_13), .SEL (
         nx10869)) ;
    DFFC U_command_control_TC0_reg_reg_data_13 (.Q (tc0_data_13), .QB (
         \$dummy [111]), .D (nx6119), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6120 (.OUT (nx6119), .A (tc0_data_13), .B (tc0_data_14), .SEL (
         nx10869)) ;
    DFFC U_command_control_TC0_reg_reg_data_14 (.Q (tc0_data_14), .QB (
         \$dummy [112]), .D (nx6109), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6110 (.OUT (nx6109), .A (tc0_data_14), .B (tc0_data_15), .SEL (
         nx10867)) ;
    DFFC U_command_control_TC0_reg_reg_data_15 (.Q (tc0_data_15), .QB (
         \$dummy [113]), .D (nx6099), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6100 (.OUT (nx6099), .A (tc0_data_15), .B (tc0_data_16), .SEL (
         nx10867)) ;
    DFFP U_command_control_TC0_reg_reg_data_16 (.Q (tc0_data_16), .QB (
         \$dummy [114]), .D (nx6089), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6090 (.OUT (nx6089), .A (tc0_data_16), .B (tc0_data_17), .SEL (
         nx10867)) ;
    DFFC U_command_control_TC0_reg_reg_data_17 (.Q (tc0_data_17), .QB (
         \$dummy [115]), .D (nx6079), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6080 (.OUT (nx6079), .A (tc0_data_17), .B (tc0_data_18), .SEL (
         nx10867)) ;
    DFFP U_command_control_TC0_reg_reg_data_18 (.Q (tc0_data_18), .QB (
         \$dummy [116]), .D (nx6069), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6070 (.OUT (nx6069), .A (tc0_data_18), .B (tc0_data_19), .SEL (
         nx10867)) ;
    DFFP U_command_control_TC0_reg_reg_data_19 (.Q (tc0_data_19), .QB (
         \$dummy [117]), .D (nx6059), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6060 (.OUT (nx6059), .A (tc0_data_19), .B (tc0_data_20), .SEL (
         nx10867)) ;
    DFFC U_command_control_TC0_reg_reg_data_20 (.Q (tc0_data_20), .QB (
         \$dummy [118]), .D (nx6049), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6050 (.OUT (nx6049), .A (tc0_data_20), .B (tc0_data_21), .SEL (
         nx10867)) ;
    DFFP U_command_control_TC0_reg_reg_data_21 (.Q (tc0_data_21), .QB (
         \$dummy [119]), .D (nx6039), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6040 (.OUT (nx6039), .A (tc0_data_21), .B (tc0_data_22), .SEL (
         nx10867)) ;
    DFFP U_command_control_TC0_reg_reg_data_22 (.Q (tc0_data_22), .QB (
         \$dummy [120]), .D (nx6029), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6030 (.OUT (nx6029), .A (tc0_data_22), .B (tc0_data_23), .SEL (
         nx10867)) ;
    DFFP U_command_control_TC0_reg_reg_data_23 (.Q (tc0_data_23), .QB (
         \$dummy [121]), .D (nx6019), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6020 (.OUT (nx6019), .A (tc0_data_23), .B (tc0_data_24), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_24 (.Q (tc0_data_24), .QB (
         \$dummy [122]), .D (nx6009), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6010 (.OUT (nx6009), .A (tc0_data_24), .B (tc0_data_25), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_25 (.Q (tc0_data_25), .QB (
         \$dummy [123]), .D (nx5999), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6000 (.OUT (nx5999), .A (tc0_data_25), .B (tc0_data_26), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_26 (.Q (tc0_data_26), .QB (
         \$dummy [124]), .D (nx5989), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5990 (.OUT (nx5989), .A (tc0_data_26), .B (tc0_data_27), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_27 (.Q (tc0_data_27), .QB (
         \$dummy [125]), .D (nx5979), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5980 (.OUT (nx5979), .A (tc0_data_27), .B (tc0_data_28), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_28 (.Q (tc0_data_28), .QB (
         \$dummy [126]), .D (nx5969), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5970 (.OUT (nx5969), .A (tc0_data_28), .B (tc0_data_29), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_29 (.Q (tc0_data_29), .QB (
         \$dummy [127]), .D (nx5959), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5960 (.OUT (nx5959), .A (tc0_data_29), .B (tc0_data_30), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_30 (.Q (tc0_data_30), .QB (
         \$dummy [128]), .D (nx5949), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5950 (.OUT (nx5949), .A (tc0_data_30), .B (tc0_data_31), .SEL (
         nx10865)) ;
    DFFC U_command_control_TC0_reg_reg_data_31 (.Q (tc0_data_31), .QB (
         \$dummy [129]), .D (nx5939), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5940 (.OUT (nx5939), .A (tc0_data_31), .B (nx1730), .SEL (nx10865)) ;
    Nand2 ix1731 (.OUT (nx1730), .A (nx8016), .B (nx10837)) ;
    Nand2 ix8017 (.OUT (nx8016), .A (tc0_data_0), .B (nx10835)) ;
    Nand2 ix8019 (.OUT (nx8018), .A (nx8020), .B (nx1580)) ;
    Nor2 ix8021 (.OUT (nx8020), .A (U_command_control_int_hdr_data_14__XX0_XREP1
         ), .B (U_command_control_int_hdr_data_15__XX0_XREP3)) ;
    Nand2 ix1573 (.OUT (nx1572), .A (nx8057), .B (nx8262)) ;
    AOI22 ix8058 (.OUT (nx8057), .A (tc5_data_0), .B (nx7917), .C (tc4_data_0), 
          .D (nx8020)) ;
    DFFP U_command_control_TC5_reg_reg_data_0 (.Q (tc5_data_0), .QB (
         \$dummy [130]), .D (nx5609), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5610 (.OUT (nx5609), .A (tc5_data_0), .B (tc5_data_1), .SEL (nx10879)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_1 (.Q (tc5_data_1), .QB (
         \$dummy [131]), .D (nx5599), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5600 (.OUT (nx5599), .A (tc5_data_1), .B (tc5_data_2), .SEL (nx10879)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_2 (.Q (tc5_data_2), .QB (
         \$dummy [132]), .D (nx5589), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5590 (.OUT (nx5589), .A (tc5_data_2), .B (tc5_data_3), .SEL (nx10879)
         ) ;
    DFFP U_command_control_TC5_reg_reg_data_3 (.Q (tc5_data_3), .QB (
         \$dummy [133]), .D (nx5579), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5580 (.OUT (nx5579), .A (tc5_data_3), .B (tc5_data_4), .SEL (nx10879)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_4 (.Q (tc5_data_4), .QB (
         \$dummy [134]), .D (nx5569), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5570 (.OUT (nx5569), .A (tc5_data_4), .B (tc5_data_5), .SEL (nx10879)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_5 (.Q (tc5_data_5), .QB (
         \$dummy [135]), .D (nx5559), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5560 (.OUT (nx5559), .A (tc5_data_5), .B (tc5_data_6), .SEL (nx10877)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_6 (.Q (tc5_data_6), .QB (
         \$dummy [136]), .D (nx5549), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5550 (.OUT (nx5549), .A (tc5_data_6), .B (tc5_data_7), .SEL (nx10877)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_7 (.Q (tc5_data_7), .QB (
         \$dummy [137]), .D (nx5539), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5540 (.OUT (nx5539), .A (tc5_data_7), .B (tc5_data_8), .SEL (nx10877)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_8 (.Q (tc5_data_8), .QB (
         \$dummy [138]), .D (nx5529), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5530 (.OUT (nx5529), .A (tc5_data_8), .B (tc5_data_9), .SEL (nx10877)
         ) ;
    DFFC U_command_control_TC5_reg_reg_data_9 (.Q (tc5_data_9), .QB (
         \$dummy [139]), .D (nx5519), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5520 (.OUT (nx5519), .A (tc5_data_9), .B (tc5_data_10), .SEL (nx10877
         )) ;
    DFFC U_command_control_TC5_reg_reg_data_10 (.Q (tc5_data_10), .QB (
         \$dummy [140]), .D (nx5509), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5510 (.OUT (nx5509), .A (tc5_data_10), .B (tc5_data_11), .SEL (
         nx10877)) ;
    DFFC U_command_control_TC5_reg_reg_data_11 (.Q (tc5_data_11), .QB (
         \$dummy [141]), .D (nx5499), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5500 (.OUT (nx5499), .A (tc5_data_11), .B (tc5_data_12), .SEL (
         nx10877)) ;
    DFFC U_command_control_TC5_reg_reg_data_12 (.Q (tc5_data_12), .QB (
         \$dummy [142]), .D (nx5489), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5490 (.OUT (nx5489), .A (tc5_data_12), .B (tc5_data_13), .SEL (
         nx10877)) ;
    DFFC U_command_control_TC5_reg_reg_data_13 (.Q (tc5_data_13), .QB (
         \$dummy [143]), .D (nx5479), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5480 (.OUT (nx5479), .A (tc5_data_13), .B (tc5_data_14), .SEL (
         nx10877)) ;
    DFFC U_command_control_TC5_reg_reg_data_14 (.Q (tc5_data_14), .QB (
         \$dummy [144]), .D (nx5469), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5470 (.OUT (nx5469), .A (tc5_data_14), .B (tc5_data_15), .SEL (
         nx10875)) ;
    DFFC U_command_control_TC5_reg_reg_data_15 (.Q (tc5_data_15), .QB (
         \$dummy [145]), .D (nx5459), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5460 (.OUT (nx5459), .A (tc5_data_15), .B (tc5_data_16), .SEL (
         nx10875)) ;
    DFFC U_command_control_TC5_reg_reg_data_16 (.Q (tc5_data_16), .QB (
         \$dummy [146]), .D (nx5449), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5450 (.OUT (nx5449), .A (tc5_data_16), .B (tc5_data_17), .SEL (
         nx10875)) ;
    DFFP U_command_control_TC5_reg_reg_data_17 (.Q (tc5_data_17), .QB (
         \$dummy [147]), .D (nx5439), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5440 (.OUT (nx5439), .A (tc5_data_17), .B (tc5_data_18), .SEL (
         nx10875)) ;
    DFFC U_command_control_TC5_reg_reg_data_18 (.Q (tc5_data_18), .QB (
         \$dummy [148]), .D (nx5429), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5430 (.OUT (nx5429), .A (tc5_data_18), .B (tc5_data_19), .SEL (
         nx10875)) ;
    DFFC U_command_control_TC5_reg_reg_data_19 (.Q (tc5_data_19), .QB (
         \$dummy [149]), .D (nx5419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5420 (.OUT (nx5419), .A (tc5_data_19), .B (tc5_data_20), .SEL (
         nx10875)) ;
    DFFC U_command_control_TC5_reg_reg_data_20 (.Q (tc5_data_20), .QB (
         \$dummy [150]), .D (nx5409), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5410 (.OUT (nx5409), .A (tc5_data_20), .B (tc5_data_21), .SEL (
         nx10875)) ;
    DFFC U_command_control_TC5_reg_reg_data_21 (.Q (tc5_data_21), .QB (
         \$dummy [151]), .D (nx5399), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5400 (.OUT (nx5399), .A (tc5_data_21), .B (tc5_data_22), .SEL (
         nx10875)) ;
    DFFP U_command_control_TC5_reg_reg_data_22 (.Q (tc5_data_22), .QB (
         \$dummy [152]), .D (nx5389), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5390 (.OUT (nx5389), .A (tc5_data_22), .B (tc5_data_23), .SEL (
         nx10875)) ;
    DFFC U_command_control_TC5_reg_reg_data_23 (.Q (tc5_data_23), .QB (
         \$dummy [153]), .D (nx5379), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5380 (.OUT (nx5379), .A (tc5_data_23), .B (tc5_data_24), .SEL (
         nx10873)) ;
    DFFC U_command_control_TC5_reg_reg_data_24 (.Q (tc5_data_24), .QB (
         \$dummy [154]), .D (nx5369), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5370 (.OUT (nx5369), .A (tc5_data_24), .B (tc5_data_25), .SEL (
         nx10873)) ;
    DFFC U_command_control_TC5_reg_reg_data_25 (.Q (tc5_data_25), .QB (
         \$dummy [155]), .D (nx5359), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5360 (.OUT (nx5359), .A (tc5_data_25), .B (tc5_data_26), .SEL (
         nx10873)) ;
    DFFP U_command_control_TC5_reg_reg_data_26 (.Q (tc5_data_26), .QB (
         \$dummy [156]), .D (nx5349), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5350 (.OUT (nx5349), .A (tc5_data_26), .B (tc5_data_27), .SEL (
         nx10873)) ;
    DFFP U_command_control_TC5_reg_reg_data_27 (.Q (tc5_data_27), .QB (
         \$dummy [157]), .D (nx5339), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5340 (.OUT (nx5339), .A (tc5_data_27), .B (tc5_data_28), .SEL (
         nx10873)) ;
    DFFP U_command_control_TC5_reg_reg_data_28 (.Q (tc5_data_28), .QB (
         \$dummy [158]), .D (nx5329), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5330 (.OUT (nx5329), .A (tc5_data_28), .B (tc5_data_29), .SEL (
         nx10873)) ;
    DFFC U_command_control_TC5_reg_reg_data_29 (.Q (tc5_data_29), .QB (
         \$dummy [159]), .D (nx5319), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5320 (.OUT (nx5319), .A (tc5_data_29), .B (tc5_data_30), .SEL (
         nx10873)) ;
    DFFP U_command_control_TC5_reg_reg_data_30 (.Q (tc5_data_30), .QB (
         \$dummy [160]), .D (nx5309), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5310 (.OUT (nx5309), .A (tc5_data_30), .B (tc5_data_31), .SEL (
         nx10873)) ;
    DFFC U_command_control_TC5_reg_reg_data_31 (.Q (tc5_data_31), .QB (
         \$dummy [161]), .D (nx5299), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5300 (.OUT (nx5299), .A (tc5_data_31), .B (nx1436), .SEL (nx10873)) ;
    Nand2 ix1437 (.OUT (nx1436), .A (nx8124), .B (nx10837)) ;
    Nand2 ix8125 (.OUT (nx8124), .A (tc5_data_0), .B (nx10835)) ;
    Nand2 ix8127 (.OUT (nx8126), .A (nx7917), .B (nx3206)) ;
    Nor3 ix2241 (.OUT (nx3206), .A (nx7707), .B (nx7562), .C (nx7563)) ;
    DFFP U_command_control_TC4_reg_reg_data_0 (.Q (tc4_data_0), .QB (
         \$dummy [162]), .D (nx5289), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5290 (.OUT (nx5289), .A (tc4_data_0), .B (tc4_data_1), .SEL (nx10887)
         ) ;
    DFFP U_command_control_TC4_reg_reg_data_1 (.Q (tc4_data_1), .QB (
         \$dummy [163]), .D (nx5279), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5280 (.OUT (nx5279), .A (tc4_data_1), .B (tc4_data_2), .SEL (nx10887)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_2 (.Q (tc4_data_2), .QB (
         \$dummy [164]), .D (nx5269), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5270 (.OUT (nx5269), .A (tc4_data_2), .B (tc4_data_3), .SEL (nx10887)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_3 (.Q (tc4_data_3), .QB (
         \$dummy [165]), .D (nx5259), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5260 (.OUT (nx5259), .A (tc4_data_3), .B (tc4_data_4), .SEL (nx10887)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_4 (.Q (tc4_data_4), .QB (
         \$dummy [166]), .D (nx5249), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5250 (.OUT (nx5249), .A (tc4_data_4), .B (tc4_data_5), .SEL (nx10887)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_5 (.Q (tc4_data_5), .QB (
         \$dummy [167]), .D (nx5239), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5240 (.OUT (nx5239), .A (tc4_data_5), .B (tc4_data_6), .SEL (nx10885)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_6 (.Q (tc4_data_6), .QB (
         \$dummy [168]), .D (nx5229), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5230 (.OUT (nx5229), .A (tc4_data_6), .B (tc4_data_7), .SEL (nx10885)
         ) ;
    DFFP U_command_control_TC4_reg_reg_data_7 (.Q (tc4_data_7), .QB (
         \$dummy [169]), .D (nx5219), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5220 (.OUT (nx5219), .A (tc4_data_7), .B (tc4_data_8), .SEL (nx10885)
         ) ;
    DFFP U_command_control_TC4_reg_reg_data_8 (.Q (tc4_data_8), .QB (
         \$dummy [170]), .D (nx5209), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5210 (.OUT (nx5209), .A (tc4_data_8), .B (tc4_data_9), .SEL (nx10885)
         ) ;
    DFFC U_command_control_TC4_reg_reg_data_9 (.Q (tc4_data_9), .QB (
         \$dummy [171]), .D (nx5199), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5200 (.OUT (nx5199), .A (tc4_data_9), .B (tc4_data_10), .SEL (nx10885
         )) ;
    DFFC U_command_control_TC4_reg_reg_data_10 (.Q (tc4_data_10), .QB (
         \$dummy [172]), .D (nx5189), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5190 (.OUT (nx5189), .A (tc4_data_10), .B (tc4_data_11), .SEL (
         nx10885)) ;
    DFFC U_command_control_TC4_reg_reg_data_11 (.Q (tc4_data_11), .QB (
         \$dummy [173]), .D (nx5179), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5180 (.OUT (nx5179), .A (tc4_data_11), .B (tc4_data_12), .SEL (
         nx10885)) ;
    DFFC U_command_control_TC4_reg_reg_data_12 (.Q (tc4_data_12), .QB (
         \$dummy [174]), .D (nx5169), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5170 (.OUT (nx5169), .A (tc4_data_12), .B (tc4_data_13), .SEL (
         nx10885)) ;
    DFFC U_command_control_TC4_reg_reg_data_13 (.Q (tc4_data_13), .QB (
         \$dummy [175]), .D (nx5159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5160 (.OUT (nx5159), .A (tc4_data_13), .B (tc4_data_14), .SEL (
         nx10885)) ;
    DFFC U_command_control_TC4_reg_reg_data_14 (.Q (tc4_data_14), .QB (
         \$dummy [176]), .D (nx5149), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5150 (.OUT (nx5149), .A (tc4_data_14), .B (tc4_data_15), .SEL (
         nx10883)) ;
    DFFC U_command_control_TC4_reg_reg_data_15 (.Q (tc4_data_15), .QB (
         \$dummy [177]), .D (nx5139), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5140 (.OUT (nx5139), .A (tc4_data_15), .B (tc4_data_16), .SEL (
         nx10883)) ;
    DFFC U_command_control_TC4_reg_reg_data_16 (.Q (tc4_data_16), .QB (
         \$dummy [178]), .D (nx5129), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5130 (.OUT (nx5129), .A (tc4_data_16), .B (tc4_data_17), .SEL (
         nx10883)) ;
    DFFP U_command_control_TC4_reg_reg_data_17 (.Q (tc4_data_17), .QB (
         \$dummy [179]), .D (nx5119), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5120 (.OUT (nx5119), .A (tc4_data_17), .B (tc4_data_18), .SEL (
         nx10883)) ;
    DFFC U_command_control_TC4_reg_reg_data_18 (.Q (tc4_data_18), .QB (
         \$dummy [180]), .D (nx5109), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5110 (.OUT (nx5109), .A (tc4_data_18), .B (tc4_data_19), .SEL (
         nx10883)) ;
    DFFC U_command_control_TC4_reg_reg_data_19 (.Q (tc4_data_19), .QB (
         \$dummy [181]), .D (nx5099), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5100 (.OUT (nx5099), .A (tc4_data_19), .B (tc4_data_20), .SEL (
         nx10883)) ;
    DFFC U_command_control_TC4_reg_reg_data_20 (.Q (tc4_data_20), .QB (
         \$dummy [182]), .D (nx5089), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5090 (.OUT (nx5089), .A (tc4_data_20), .B (tc4_data_21), .SEL (
         nx10883)) ;
    DFFC U_command_control_TC4_reg_reg_data_21 (.Q (tc4_data_21), .QB (
         \$dummy [183]), .D (nx5079), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5080 (.OUT (nx5079), .A (tc4_data_21), .B (tc4_data_22), .SEL (
         nx10883)) ;
    DFFP U_command_control_TC4_reg_reg_data_22 (.Q (tc4_data_22), .QB (
         \$dummy [184]), .D (nx5069), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5070 (.OUT (nx5069), .A (tc4_data_22), .B (tc4_data_23), .SEL (
         nx10883)) ;
    DFFC U_command_control_TC4_reg_reg_data_23 (.Q (tc4_data_23), .QB (
         \$dummy [185]), .D (nx5059), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5060 (.OUT (nx5059), .A (tc4_data_23), .B (tc4_data_24), .SEL (
         nx10881)) ;
    DFFC U_command_control_TC4_reg_reg_data_24 (.Q (tc4_data_24), .QB (
         \$dummy [186]), .D (nx5049), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5050 (.OUT (nx5049), .A (tc4_data_24), .B (tc4_data_25), .SEL (
         nx10881)) ;
    DFFC U_command_control_TC4_reg_reg_data_25 (.Q (tc4_data_25), .QB (
         \$dummy [187]), .D (nx5039), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5040 (.OUT (nx5039), .A (tc4_data_25), .B (tc4_data_26), .SEL (
         nx10881)) ;
    DFFP U_command_control_TC4_reg_reg_data_26 (.Q (tc4_data_26), .QB (
         \$dummy [188]), .D (nx5029), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5030 (.OUT (nx5029), .A (tc4_data_26), .B (tc4_data_27), .SEL (
         nx10881)) ;
    DFFP U_command_control_TC4_reg_reg_data_27 (.Q (tc4_data_27), .QB (
         \$dummy [189]), .D (nx5019), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5020 (.OUT (nx5019), .A (tc4_data_27), .B (tc4_data_28), .SEL (
         nx10881)) ;
    DFFP U_command_control_TC4_reg_reg_data_28 (.Q (tc4_data_28), .QB (
         \$dummy [190]), .D (nx5009), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix5010 (.OUT (nx5009), .A (tc4_data_28), .B (tc4_data_29), .SEL (
         nx10881)) ;
    DFFC U_command_control_TC4_reg_reg_data_29 (.Q (tc4_data_29), .QB (
         \$dummy [191]), .D (nx4999), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix5000 (.OUT (nx4999), .A (tc4_data_29), .B (tc4_data_30), .SEL (
         nx10881)) ;
    DFFP U_command_control_TC4_reg_reg_data_30 (.Q (tc4_data_30), .QB (
         \$dummy [192]), .D (nx4989), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4990 (.OUT (nx4989), .A (tc4_data_30), .B (tc4_data_31), .SEL (
         nx10881)) ;
    DFFC U_command_control_TC4_reg_reg_data_31 (.Q (tc4_data_31), .QB (
         \$dummy [193]), .D (nx4979), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4980 (.OUT (nx4979), .A (tc4_data_31), .B (nx1294), .SEL (nx10881)) ;
    Nand2 ix1295 (.OUT (nx1294), .A (nx8226), .B (nx10837)) ;
    Nand2 ix8227 (.OUT (nx8226), .A (tc4_data_0), .B (nx10835)) ;
    Nand2 ix8229 (.OUT (nx8228), .A (nx8020), .B (nx3206)) ;
    AOI22 ix8263 (.OUT (nx8262), .A (tc7_data_0), .B (nx418_XX0_XREP45), .C (
          tc6_data_0), .D (nx1050)) ;
    DFFP U_command_control_TC7_reg_reg_data_0 (.Q (tc7_data_0), .QB (
         \$dummy [194]), .D (nx4969), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4970 (.OUT (nx4969), .A (tc7_data_0), .B (tc7_data_1), .SEL (nx10895)
         ) ;
    DFFP U_command_control_TC7_reg_reg_data_1 (.Q (tc7_data_1), .QB (
         \$dummy [195]), .D (nx4959), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4960 (.OUT (nx4959), .A (tc7_data_1), .B (tc7_data_2), .SEL (nx10895)
         ) ;
    DFFP U_command_control_TC7_reg_reg_data_2 (.Q (tc7_data_2), .QB (
         \$dummy [196]), .D (nx4949), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4950 (.OUT (nx4949), .A (tc7_data_2), .B (tc7_data_3), .SEL (nx10895)
         ) ;
    DFFC U_command_control_TC7_reg_reg_data_3 (.Q (tc7_data_3), .QB (
         \$dummy [197]), .D (nx4939), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4940 (.OUT (nx4939), .A (tc7_data_3), .B (tc7_data_4), .SEL (nx10895)
         ) ;
    DFFC U_command_control_TC7_reg_reg_data_4 (.Q (tc7_data_4), .QB (
         \$dummy [198]), .D (nx4929), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4930 (.OUT (nx4929), .A (tc7_data_4), .B (tc7_data_5), .SEL (nx10895)
         ) ;
    DFFC U_command_control_TC7_reg_reg_data_5 (.Q (tc7_data_5), .QB (
         \$dummy [199]), .D (nx4919), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4920 (.OUT (nx4919), .A (tc7_data_5), .B (tc7_data_6), .SEL (nx10893)
         ) ;
    DFFP U_command_control_TC7_reg_reg_data_6 (.Q (tc7_data_6), .QB (
         \$dummy [200]), .D (nx4909), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4910 (.OUT (nx4909), .A (tc7_data_6), .B (tc7_data_7), .SEL (nx10893)
         ) ;
    DFFC U_command_control_TC7_reg_reg_data_7 (.Q (tc7_data_7), .QB (
         \$dummy [201]), .D (nx4899), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4900 (.OUT (nx4899), .A (tc7_data_7), .B (tc7_data_8), .SEL (nx10893)
         ) ;
    DFFP U_command_control_TC7_reg_reg_data_8 (.Q (tc7_data_8), .QB (
         \$dummy [202]), .D (nx4889), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4890 (.OUT (nx4889), .A (tc7_data_8), .B (tc7_data_9), .SEL (nx10893)
         ) ;
    DFFP U_command_control_TC7_reg_reg_data_9 (.Q (tc7_data_9), .QB (
         \$dummy [203]), .D (nx4879), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4880 (.OUT (nx4879), .A (tc7_data_9), .B (tc7_data_10), .SEL (nx10893
         )) ;
    DFFC U_command_control_TC7_reg_reg_data_10 (.Q (tc7_data_10), .QB (
         \$dummy [204]), .D (nx4869), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4870 (.OUT (nx4869), .A (tc7_data_10), .B (tc7_data_11), .SEL (
         nx10893)) ;
    DFFP U_command_control_TC7_reg_reg_data_11 (.Q (tc7_data_11), .QB (
         \$dummy [205]), .D (nx4859), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4860 (.OUT (nx4859), .A (tc7_data_11), .B (tc7_data_12), .SEL (
         nx10893)) ;
    DFFP U_command_control_TC7_reg_reg_data_12 (.Q (tc7_data_12), .QB (
         \$dummy [206]), .D (nx4849), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4850 (.OUT (nx4849), .A (tc7_data_12), .B (tc7_data_13), .SEL (
         nx10893)) ;
    DFFP U_command_control_TC7_reg_reg_data_13 (.Q (tc7_data_13), .QB (
         \$dummy [207]), .D (nx4839), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4840 (.OUT (nx4839), .A (tc7_data_13), .B (tc7_data_14), .SEL (
         nx10893)) ;
    DFFP U_command_control_TC7_reg_reg_data_14 (.Q (tc7_data_14), .QB (
         \$dummy [208]), .D (nx4829), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4830 (.OUT (nx4829), .A (tc7_data_14), .B (tc7_data_15), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_15 (.Q (tc7_data_15), .QB (
         \$dummy [209]), .D (nx4819), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4820 (.OUT (nx4819), .A (tc7_data_15), .B (tc7_data_16), .SEL (
         nx10891)) ;
    DFFP U_command_control_TC7_reg_reg_data_16 (.Q (tc7_data_16), .QB (
         \$dummy [210]), .D (nx4809), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4810 (.OUT (nx4809), .A (tc7_data_16), .B (tc7_data_17), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_17 (.Q (tc7_data_17), .QB (
         \$dummy [211]), .D (nx4799), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4800 (.OUT (nx4799), .A (tc7_data_17), .B (tc7_data_18), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_18 (.Q (tc7_data_18), .QB (
         \$dummy [212]), .D (nx4789), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4790 (.OUT (nx4789), .A (tc7_data_18), .B (tc7_data_19), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_19 (.Q (tc7_data_19), .QB (
         \$dummy [213]), .D (nx4779), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4780 (.OUT (nx4779), .A (tc7_data_19), .B (tc7_data_20), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_20 (.Q (tc7_data_20), .QB (
         \$dummy [214]), .D (nx4769), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4770 (.OUT (nx4769), .A (tc7_data_20), .B (tc7_data_21), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_21 (.Q (tc7_data_21), .QB (
         \$dummy [215]), .D (nx4759), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4760 (.OUT (nx4759), .A (tc7_data_21), .B (tc7_data_22), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_22 (.Q (tc7_data_22), .QB (
         \$dummy [216]), .D (nx4749), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4750 (.OUT (nx4749), .A (tc7_data_22), .B (tc7_data_23), .SEL (
         nx10891)) ;
    DFFC U_command_control_TC7_reg_reg_data_23 (.Q (tc7_data_23), .QB (
         \$dummy [217]), .D (nx6979), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6980 (.OUT (nx6979), .A (tc7_data_23), .B (tc7_data_24), .SEL (
         nx10889)) ;
    DFFP U_command_control_TC7_reg_reg_data_24 (.Q (tc7_data_24), .QB (
         \$dummy [218]), .D (nx6969), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6970 (.OUT (nx6969), .A (tc7_data_24), .B (tc7_data_25), .SEL (
         nx10889)) ;
    DFFC U_command_control_TC7_reg_reg_data_25 (.Q (tc7_data_25), .QB (
         \$dummy [219]), .D (nx6959), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6960 (.OUT (nx6959), .A (tc7_data_25), .B (tc7_data_26), .SEL (
         nx10889)) ;
    DFFP U_command_control_TC7_reg_reg_data_26 (.Q (tc7_data_26), .QB (
         \$dummy [220]), .D (nx6949), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6950 (.OUT (nx6949), .A (tc7_data_26), .B (tc7_data_27), .SEL (
         nx10889)) ;
    DFFP U_command_control_TC7_reg_reg_data_27 (.Q (tc7_data_27), .QB (
         \$dummy [221]), .D (nx6939), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6940 (.OUT (nx6939), .A (tc7_data_27), .B (tc7_data_28), .SEL (
         nx10889)) ;
    DFFC U_command_control_TC7_reg_reg_data_28 (.Q (tc7_data_28), .QB (
         \$dummy [222]), .D (nx6929), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6930 (.OUT (nx6929), .A (tc7_data_28), .B (tc7_data_29), .SEL (
         nx10889)) ;
    DFFP U_command_control_TC7_reg_reg_data_29 (.Q (tc7_data_29), .QB (
         \$dummy [223]), .D (nx6919), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6920 (.OUT (nx6919), .A (tc7_data_29), .B (tc7_data_30), .SEL (
         nx10889)) ;
    DFFP U_command_control_TC7_reg_reg_data_30 (.Q (tc7_data_30), .QB (
         \$dummy [224]), .D (nx6909), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6910 (.OUT (nx6909), .A (tc7_data_30), .B (tc7_data_31), .SEL (
         nx10889)) ;
    DFFP U_command_control_TC7_reg_reg_data_31 (.Q (tc7_data_31), .QB (
         \$dummy [225]), .D (nx6899), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix6900 (.OUT (nx6899), .A (tc7_data_31), .B (nx2248), .SEL (nx10889)) ;
    Nand2 ix2249 (.OUT (nx2248), .A (nx8329), .B (nx10837)) ;
    Nand2 ix8330 (.OUT (nx8329), .A (tc7_data_0), .B (nx10835)) ;
    Nand2 ix8332 (.OUT (nx8331), .A (nx418), .B (nx3206)) ;
    DFFP U_command_control_TC6_reg_reg_data_0 (.Q (tc6_data_0), .QB (
         \$dummy [226]), .D (nx4739), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4740 (.OUT (nx4739), .A (tc6_data_0), .B (tc6_data_1), .SEL (nx10903)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_1 (.Q (tc6_data_1), .QB (
         \$dummy [227]), .D (nx4729), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4730 (.OUT (nx4729), .A (tc6_data_1), .B (tc6_data_2), .SEL (nx10903)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_2 (.Q (tc6_data_2), .QB (
         \$dummy [228]), .D (nx4719), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4720 (.OUT (nx4719), .A (tc6_data_2), .B (tc6_data_3), .SEL (nx10903)
         ) ;
    DFFP U_command_control_TC6_reg_reg_data_3 (.Q (tc6_data_3), .QB (
         \$dummy [229]), .D (nx4709), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4710 (.OUT (nx4709), .A (tc6_data_3), .B (tc6_data_4), .SEL (nx10903)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_4 (.Q (tc6_data_4), .QB (
         \$dummy [230]), .D (nx4699), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4700 (.OUT (nx4699), .A (tc6_data_4), .B (tc6_data_5), .SEL (nx10903)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_5 (.Q (tc6_data_5), .QB (
         \$dummy [231]), .D (nx4689), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4690 (.OUT (nx4689), .A (tc6_data_5), .B (tc6_data_6), .SEL (nx10901)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_6 (.Q (tc6_data_6), .QB (
         \$dummy [232]), .D (nx4679), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4680 (.OUT (nx4679), .A (tc6_data_6), .B (tc6_data_7), .SEL (nx10901)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_7 (.Q (tc6_data_7), .QB (
         \$dummy [233]), .D (nx4669), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4670 (.OUT (nx4669), .A (tc6_data_7), .B (tc6_data_8), .SEL (nx10901)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_8 (.Q (tc6_data_8), .QB (
         \$dummy [234]), .D (nx4659), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4660 (.OUT (nx4659), .A (tc6_data_8), .B (tc6_data_9), .SEL (nx10901)
         ) ;
    DFFC U_command_control_TC6_reg_reg_data_9 (.Q (tc6_data_9), .QB (
         \$dummy [235]), .D (nx4649), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4650 (.OUT (nx4649), .A (tc6_data_9), .B (tc6_data_10), .SEL (nx10901
         )) ;
    DFFC U_command_control_TC6_reg_reg_data_10 (.Q (tc6_data_10), .QB (
         \$dummy [236]), .D (nx4639), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4640 (.OUT (nx4639), .A (tc6_data_10), .B (tc6_data_11), .SEL (
         nx10901)) ;
    DFFC U_command_control_TC6_reg_reg_data_11 (.Q (tc6_data_11), .QB (
         \$dummy [237]), .D (nx4629), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4630 (.OUT (nx4629), .A (tc6_data_11), .B (tc6_data_12), .SEL (
         nx10901)) ;
    DFFC U_command_control_TC6_reg_reg_data_12 (.Q (tc6_data_12), .QB (
         \$dummy [238]), .D (nx4619), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4620 (.OUT (nx4619), .A (tc6_data_12), .B (tc6_data_13), .SEL (
         nx10901)) ;
    DFFC U_command_control_TC6_reg_reg_data_13 (.Q (tc6_data_13), .QB (
         \$dummy [239]), .D (nx4609), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4610 (.OUT (nx4609), .A (tc6_data_13), .B (tc6_data_14), .SEL (
         nx10901)) ;
    DFFC U_command_control_TC6_reg_reg_data_14 (.Q (tc6_data_14), .QB (
         \$dummy [240]), .D (nx4599), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4600 (.OUT (nx4599), .A (tc6_data_14), .B (tc6_data_15), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_15 (.Q (tc6_data_15), .QB (
         \$dummy [241]), .D (nx4589), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4590 (.OUT (nx4589), .A (tc6_data_15), .B (tc6_data_16), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_16 (.Q (tc6_data_16), .QB (
         \$dummy [242]), .D (nx4579), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4580 (.OUT (nx4579), .A (tc6_data_16), .B (tc6_data_17), .SEL (
         nx10899)) ;
    DFFP U_command_control_TC6_reg_reg_data_17 (.Q (tc6_data_17), .QB (
         \$dummy [243]), .D (nx4569), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4570 (.OUT (nx4569), .A (tc6_data_17), .B (tc6_data_18), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_18 (.Q (tc6_data_18), .QB (
         \$dummy [244]), .D (nx4559), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4560 (.OUT (nx4559), .A (tc6_data_18), .B (tc6_data_19), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_19 (.Q (tc6_data_19), .QB (
         \$dummy [245]), .D (nx4549), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4550 (.OUT (nx4549), .A (tc6_data_19), .B (tc6_data_20), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_20 (.Q (tc6_data_20), .QB (
         \$dummy [246]), .D (nx4539), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4540 (.OUT (nx4539), .A (tc6_data_20), .B (tc6_data_21), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_21 (.Q (tc6_data_21), .QB (
         \$dummy [247]), .D (nx4529), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4530 (.OUT (nx4529), .A (tc6_data_21), .B (tc6_data_22), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_22 (.Q (tc6_data_22), .QB (
         \$dummy [248]), .D (nx4519), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4520 (.OUT (nx4519), .A (tc6_data_22), .B (tc6_data_23), .SEL (
         nx10899)) ;
    DFFC U_command_control_TC6_reg_reg_data_23 (.Q (tc6_data_23), .QB (
         \$dummy [249]), .D (nx4509), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4510 (.OUT (nx4509), .A (tc6_data_23), .B (tc6_data_24), .SEL (
         nx10897)) ;
    DFFP U_command_control_TC6_reg_reg_data_24 (.Q (tc6_data_24), .QB (
         \$dummy [250]), .D (nx4499), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4500 (.OUT (nx4499), .A (tc6_data_24), .B (tc6_data_25), .SEL (
         nx10897)) ;
    DFFC U_command_control_TC6_reg_reg_data_25 (.Q (tc6_data_25), .QB (
         \$dummy [251]), .D (nx4489), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4490 (.OUT (nx4489), .A (tc6_data_25), .B (tc6_data_26), .SEL (
         nx10897)) ;
    DFFP U_command_control_TC6_reg_reg_data_26 (.Q (tc6_data_26), .QB (
         \$dummy [252]), .D (nx4479), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4480 (.OUT (nx4479), .A (tc6_data_26), .B (tc6_data_27), .SEL (
         nx10897)) ;
    DFFP U_command_control_TC6_reg_reg_data_27 (.Q (tc6_data_27), .QB (
         \$dummy [253]), .D (nx4469), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4470 (.OUT (nx4469), .A (tc6_data_27), .B (tc6_data_28), .SEL (
         nx10897)) ;
    DFFP U_command_control_TC6_reg_reg_data_28 (.Q (tc6_data_28), .QB (
         \$dummy [254]), .D (nx4459), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4460 (.OUT (nx4459), .A (tc6_data_28), .B (tc6_data_29), .SEL (
         nx10897)) ;
    DFFC U_command_control_TC6_reg_reg_data_29 (.Q (tc6_data_29), .QB (
         \$dummy [255]), .D (nx4449), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4450 (.OUT (nx4449), .A (tc6_data_29), .B (tc6_data_30), .SEL (
         nx10897)) ;
    DFFP U_command_control_TC6_reg_reg_data_30 (.Q (tc6_data_30), .QB (
         \$dummy [256]), .D (nx4439), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4440 (.OUT (nx4439), .A (tc6_data_30), .B (tc6_data_31), .SEL (
         nx10897)) ;
    DFFP U_command_control_TC6_reg_reg_data_31 (.Q (tc6_data_31), .QB (
         \$dummy [257]), .D (nx4429), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4430 (.OUT (nx4429), .A (tc6_data_31), .B (nx1058), .SEL (nx10897)) ;
    Nand2 ix1059 (.OUT (nx1058), .A (nx8430), .B (nx10837)) ;
    Nand2 ix8431 (.OUT (nx8430), .A (tc6_data_0), .B (nx10835)) ;
    Nand2 ix8433 (.OUT (nx8432), .A (nx3206), .B (nx1050)) ;
    DFFC U_command_control_CFG_reg_reg_data_0 (.Q (test_mode), .QB (nx8567), .D (
         nx4419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4420 (.OUT (nx4419), .A (sparse_en), .B (test_mode), .SEL (nx10755)
         ) ;
    DFFC U_command_control_CFG_reg_reg_data_1 (.Q (sparse_en), .QB (
         \$dummy [258]), .D (nx4409), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4410 (.OUT (nx4409), .A (U_command_control_CFG_data_out_2), .B (
         sparse_en), .SEL (nx10755)) ;
    DFFC U_command_control_CFG_reg_reg_data_2 (.Q (
         U_command_control_CFG_data_out_2), .QB (\$dummy [259]), .D (nx4399), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4400 (.OUT (nx4399), .A (U_command_control_CFG_data_out_3), .B (
         U_command_control_CFG_data_out_2), .SEL (nx10755)) ;
    DFFC U_command_control_CFG_reg_reg_data_3 (.Q (
         U_command_control_CFG_data_out_3), .QB (\$dummy [260]), .D (nx4389), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4390 (.OUT (nx4389), .A (U_command_control_CFG_data_out_4), .B (
         U_command_control_CFG_data_out_3), .SEL (nx10755)) ;
    DFFC U_command_control_CFG_reg_reg_data_4 (.Q (
         U_command_control_CFG_data_out_4), .QB (\$dummy [261]), .D (nx4379), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4380 (.OUT (nx4379), .A (U_command_control_CFG_data_out_5), .B (
         U_command_control_CFG_data_out_4), .SEL (nx10755)) ;
    DFFC U_command_control_CFG_reg_reg_data_5 (.Q (
         U_command_control_CFG_data_out_5), .QB (\$dummy [262]), .D (nx4369), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4370 (.OUT (nx4369), .A (U_command_control_CFG_data_out_6), .B (
         U_command_control_CFG_data_out_5), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_6 (.Q (
         U_command_control_CFG_data_out_6), .QB (\$dummy [263]), .D (nx4359), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4360 (.OUT (nx4359), .A (U_command_control_CFG_data_out_7), .B (
         U_command_control_CFG_data_out_6), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_7 (.Q (
         U_command_control_CFG_data_out_7), .QB (\$dummy [264]), .D (nx4349), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4350 (.OUT (nx4349), .A (U_command_control_CFG_data_out_8), .B (
         U_command_control_CFG_data_out_7), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_8 (.Q (
         U_command_control_CFG_data_out_8), .QB (\$dummy [265]), .D (nx4339), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4340 (.OUT (nx4339), .A (U_command_control_CFG_data_out_9), .B (
         U_command_control_CFG_data_out_8), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_9 (.Q (
         U_command_control_CFG_data_out_9), .QB (\$dummy [266]), .D (nx4329), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4330 (.OUT (nx4329), .A (U_command_control_CFG_data_out_10), .B (
         U_command_control_CFG_data_out_9), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_10 (.Q (
         U_command_control_CFG_data_out_10), .QB (\$dummy [267]), .D (nx4319), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4320 (.OUT (nx4319), .A (U_command_control_CFG_data_out_11), .B (
         U_command_control_CFG_data_out_10), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_11 (.Q (
         U_command_control_CFG_data_out_11), .QB (\$dummy [268]), .D (nx4309), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4310 (.OUT (nx4309), .A (U_command_control_CFG_data_out_12), .B (
         U_command_control_CFG_data_out_11), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_12 (.Q (
         U_command_control_CFG_data_out_12), .QB (\$dummy [269]), .D (nx4299), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4300 (.OUT (nx4299), .A (U_command_control_CFG_data_out_13), .B (
         U_command_control_CFG_data_out_12), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_13 (.Q (
         U_command_control_CFG_data_out_13), .QB (\$dummy [270]), .D (nx4289), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4290 (.OUT (nx4289), .A (U_command_control_CFG_data_out_14), .B (
         U_command_control_CFG_data_out_13), .SEL (nx10753)) ;
    DFFC U_command_control_CFG_reg_reg_data_14 (.Q (
         U_command_control_CFG_data_out_14), .QB (\$dummy [271]), .D (nx4279), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4280 (.OUT (nx4279), .A (U_command_control_CFG_data_out_15), .B (
         U_command_control_CFG_data_out_14), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_15 (.Q (
         U_command_control_CFG_data_out_15), .QB (\$dummy [272]), .D (nx4269), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4270 (.OUT (nx4269), .A (U_command_control_CFG_data_out_16), .B (
         U_command_control_CFG_data_out_15), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_16 (.Q (
         U_command_control_CFG_data_out_16), .QB (\$dummy [273]), .D (nx4259), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4260 (.OUT (nx4259), .A (U_command_control_CFG_data_out_17), .B (
         U_command_control_CFG_data_out_16), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_17 (.Q (
         U_command_control_CFG_data_out_17), .QB (\$dummy [274]), .D (nx4249), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4250 (.OUT (nx4249), .A (U_command_control_CFG_data_out_18), .B (
         U_command_control_CFG_data_out_17), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_18 (.Q (
         U_command_control_CFG_data_out_18), .QB (\$dummy [275]), .D (nx4239), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4240 (.OUT (nx4239), .A (U_command_control_CFG_data_out_19), .B (
         U_command_control_CFG_data_out_18), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_19 (.Q (
         U_command_control_CFG_data_out_19), .QB (\$dummy [276]), .D (nx4229), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4230 (.OUT (nx4229), .A (U_command_control_CFG_data_out_20), .B (
         U_command_control_CFG_data_out_19), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_20 (.Q (
         U_command_control_CFG_data_out_20), .QB (\$dummy [277]), .D (nx4219), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4220 (.OUT (nx4219), .A (U_command_control_CFG_data_out_21), .B (
         U_command_control_CFG_data_out_20), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_21 (.Q (
         U_command_control_CFG_data_out_21), .QB (\$dummy [278]), .D (nx4209), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4210 (.OUT (nx4209), .A (U_command_control_CFG_data_out_22), .B (
         U_command_control_CFG_data_out_21), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_22 (.Q (
         U_command_control_CFG_data_out_22), .QB (\$dummy [279]), .D (nx4199), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4200 (.OUT (nx4199), .A (U_command_control_CFG_data_out_23), .B (
         U_command_control_CFG_data_out_22), .SEL (nx10751)) ;
    DFFC U_command_control_CFG_reg_reg_data_23 (.Q (
         U_command_control_CFG_data_out_23), .QB (\$dummy [280]), .D (nx4189), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4190 (.OUT (nx4189), .A (U_command_control_CFG_data_out_24), .B (
         U_command_control_CFG_data_out_23), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_24 (.Q (
         U_command_control_CFG_data_out_24), .QB (\$dummy [281]), .D (nx4179), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4180 (.OUT (nx4179), .A (U_command_control_CFG_data_out_25), .B (
         U_command_control_CFG_data_out_24), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_25 (.Q (
         U_command_control_CFG_data_out_25), .QB (\$dummy [282]), .D (nx4169), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4170 (.OUT (nx4169), .A (U_command_control_CFG_data_out_26), .B (
         U_command_control_CFG_data_out_25), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_26 (.Q (
         U_command_control_CFG_data_out_26), .QB (\$dummy [283]), .D (nx4159), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4160 (.OUT (nx4159), .A (U_command_control_CFG_data_out_27), .B (
         U_command_control_CFG_data_out_26), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_27 (.Q (
         U_command_control_CFG_data_out_27), .QB (\$dummy [284]), .D (nx4149), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4150 (.OUT (nx4149), .A (U_command_control_CFG_data_out_28), .B (
         U_command_control_CFG_data_out_27), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_28 (.Q (
         U_command_control_CFG_data_out_28), .QB (\$dummy [285]), .D (nx4139), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4140 (.OUT (nx4139), .A (U_command_control_CFG_data_out_29), .B (
         U_command_control_CFG_data_out_28), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_29 (.Q (
         U_command_control_CFG_data_out_29), .QB (\$dummy [286]), .D (nx4129), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4130 (.OUT (nx4129), .A (U_command_control_CFG_data_out_30), .B (
         U_command_control_CFG_data_out_29), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_30 (.Q (
         U_command_control_CFG_data_out_30), .QB (\$dummy [287]), .D (nx4119), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4120 (.OUT (nx4119), .A (U_command_control_CFG_data_out_31), .B (
         U_command_control_CFG_data_out_30), .SEL (nx10749)) ;
    DFFC U_command_control_CFG_reg_reg_data_31 (.Q (
         U_command_control_CFG_data_out_31), .QB (\$dummy [288]), .D (nx4109), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4110 (.OUT (nx4109), .A (nx908), .B (
         U_command_control_CFG_data_out_31), .SEL (nx10749)) ;
    Nand2 ix909 (.OUT (nx908), .A (nx8532), .B (nx10837)) ;
    Nand2 ix8533 (.OUT (nx8532), .A (test_mode), .B (nx10835)) ;
    Nor4 ix903 (.OUT (nx902), .A (nx7707), .B (nx540), .C (nx10745), .D (
         U_command_control_int_hdr_data_17__XX0_XREP39)) ;
    Nand2 ix4100 (.OUT (nx4099), .A (nx8571), .B (nx8573)) ;
    DFFC U_command_control_reg_data_perr (.Q (U_command_control_data_perr), .QB (
         nx8571), .D (nx4099), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix8574 (.OUT (nx8573), .A (nx284), .B (nx196), .C (nx3203)) ;
    Nand2 ix4090 (.OUT (nx4089), .A (nx8577), .B (nx8579)) ;
    DFFC U_command_control_reg_head_perr (.Q (U_command_control_head_perr), .QB (
         nx8577), .D (nx4089), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix8580 (.OUT (nx8579), .A (nx3203), .B (nx3189)) ;
    AOI22 ix8584 (.OUT (nx8583), .A (nx7562_XX0_XREP39), .B (nx848), .C (nx7565)
          , .D (nx532)) ;
    DFFP U_command_control_CD1_reg_reg_data_0 (.Q (cd1_data_0), .QB (
         \$dummy [289]), .D (nx3759), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3760 (.OUT (nx3759), .A (cd1_data_0), .B (cd1_data_1), .SEL (nx10911)
         ) ;
    DFFP U_command_control_CD1_reg_reg_data_1 (.Q (cd1_data_1), .QB (
         \$dummy [290]), .D (nx3749), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3750 (.OUT (nx3749), .A (cd1_data_1), .B (cd1_data_2), .SEL (nx10911)
         ) ;
    DFFP U_command_control_CD1_reg_reg_data_2 (.Q (cd1_data_2), .QB (
         \$dummy [291]), .D (nx3739), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3740 (.OUT (nx3739), .A (cd1_data_2), .B (cd1_data_3), .SEL (nx10911)
         ) ;
    DFFP U_command_control_CD1_reg_reg_data_3 (.Q (cd1_data_3), .QB (
         \$dummy [292]), .D (nx3729), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3730 (.OUT (nx3729), .A (cd1_data_3), .B (cd1_data_4), .SEL (nx10911)
         ) ;
    DFFP U_command_control_CD1_reg_reg_data_4 (.Q (cd1_data_4), .QB (
         \$dummy [293]), .D (nx3719), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3720 (.OUT (nx3719), .A (cd1_data_4), .B (cd1_data_5), .SEL (nx10911)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_5 (.Q (cd1_data_5), .QB (
         \$dummy [294]), .D (nx3709), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3710 (.OUT (nx3709), .A (cd1_data_5), .B (cd1_data_6), .SEL (nx10909)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_6 (.Q (cd1_data_6), .QB (
         \$dummy [295]), .D (nx3699), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3700 (.OUT (nx3699), .A (cd1_data_6), .B (cd1_data_7), .SEL (nx10909)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_7 (.Q (cd1_data_7), .QB (
         \$dummy [296]), .D (nx3689), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3690 (.OUT (nx3689), .A (cd1_data_7), .B (cd1_data_8), .SEL (nx10909)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_8 (.Q (cd1_data_8), .QB (
         \$dummy [297]), .D (nx3679), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3680 (.OUT (nx3679), .A (cd1_data_8), .B (cd1_data_9), .SEL (nx10909)
         ) ;
    DFFC U_command_control_CD1_reg_reg_data_9 (.Q (cd1_data_9), .QB (
         \$dummy [298]), .D (nx3669), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3670 (.OUT (nx3669), .A (cd1_data_9), .B (cd1_data_10), .SEL (nx10909
         )) ;
    DFFC U_command_control_CD1_reg_reg_data_10 (.Q (cd1_data_10), .QB (
         \$dummy [299]), .D (nx3659), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3660 (.OUT (nx3659), .A (cd1_data_10), .B (cd1_data_11), .SEL (
         nx10909)) ;
    DFFC U_command_control_CD1_reg_reg_data_11 (.Q (cd1_data_11), .QB (
         \$dummy [300]), .D (nx3649), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3650 (.OUT (nx3649), .A (cd1_data_11), .B (cd1_data_12), .SEL (
         nx10909)) ;
    DFFP U_command_control_CD1_reg_reg_data_12 (.Q (cd1_data_12), .QB (
         \$dummy [301]), .D (nx3639), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3640 (.OUT (nx3639), .A (cd1_data_12), .B (
         U_command_control_CD1_data_out_13), .SEL (nx10909)) ;
    DFFC U_command_control_CD1_reg_reg_data_13 (.Q (
         U_command_control_CD1_data_out_13), .QB (\$dummy [302]), .D (nx3629), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3630 (.OUT (nx3629), .A (U_command_control_CD1_data_out_13), .B (
         U_command_control_CD1_data_out_14), .SEL (nx10909)) ;
    DFFC U_command_control_CD1_reg_reg_data_14 (.Q (
         U_command_control_CD1_data_out_14), .QB (\$dummy [303]), .D (nx3619), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3620 (.OUT (nx3619), .A (U_command_control_CD1_data_out_14), .B (
         U_command_control_CD1_data_out_15), .SEL (nx10907)) ;
    DFFC U_command_control_CD1_reg_reg_data_15 (.Q (
         U_command_control_CD1_data_out_15), .QB (\$dummy [304]), .D (nx3609), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3610 (.OUT (nx3609), .A (U_command_control_CD1_data_out_15), .B (
         cd1_data_16), .SEL (nx10907)) ;
    DFFP U_command_control_CD1_reg_reg_data_16 (.Q (cd1_data_16), .QB (
         \$dummy [305]), .D (nx3599), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3600 (.OUT (nx3599), .A (cd1_data_16), .B (cd1_data_17), .SEL (
         nx10907)) ;
    DFFP U_command_control_CD1_reg_reg_data_17 (.Q (cd1_data_17), .QB (
         \$dummy [306]), .D (nx3589), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3590 (.OUT (nx3589), .A (cd1_data_17), .B (cd1_data_18), .SEL (
         nx10907)) ;
    DFFP U_command_control_CD1_reg_reg_data_18 (.Q (cd1_data_18), .QB (
         \$dummy [307]), .D (nx3579), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3580 (.OUT (nx3579), .A (cd1_data_18), .B (cd1_data_19), .SEL (
         nx10907)) ;
    DFFP U_command_control_CD1_reg_reg_data_19 (.Q (cd1_data_19), .QB (
         \$dummy [308]), .D (nx3569), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3570 (.OUT (nx3569), .A (cd1_data_19), .B (cd1_data_20), .SEL (
         nx10907)) ;
    DFFP U_command_control_CD1_reg_reg_data_20 (.Q (cd1_data_20), .QB (
         \$dummy [309]), .D (nx3559), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3560 (.OUT (nx3559), .A (cd1_data_20), .B (cd1_data_21), .SEL (
         nx10907)) ;
    DFFC U_command_control_CD1_reg_reg_data_21 (.Q (cd1_data_21), .QB (
         \$dummy [310]), .D (nx3549), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3550 (.OUT (nx3549), .A (cd1_data_21), .B (cd1_data_22), .SEL (
         nx10907)) ;
    DFFC U_command_control_CD1_reg_reg_data_22 (.Q (cd1_data_22), .QB (
         \$dummy [311]), .D (nx3539), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3540 (.OUT (nx3539), .A (cd1_data_22), .B (cd1_data_23), .SEL (
         nx10907)) ;
    DFFC U_command_control_CD1_reg_reg_data_23 (.Q (cd1_data_23), .QB (
         \$dummy [312]), .D (nx3529), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3530 (.OUT (nx3529), .A (cd1_data_23), .B (cd1_data_24), .SEL (
         nx10905)) ;
    DFFC U_command_control_CD1_reg_reg_data_24 (.Q (cd1_data_24), .QB (
         \$dummy [313]), .D (nx3519), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3520 (.OUT (nx3519), .A (cd1_data_24), .B (cd1_data_25), .SEL (
         nx10905)) ;
    DFFC U_command_control_CD1_reg_reg_data_25 (.Q (cd1_data_25), .QB (
         \$dummy [314]), .D (nx3509), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3510 (.OUT (nx3509), .A (cd1_data_25), .B (cd1_data_26), .SEL (
         nx10905)) ;
    DFFC U_command_control_CD1_reg_reg_data_26 (.Q (cd1_data_26), .QB (
         \$dummy [315]), .D (nx3499), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3500 (.OUT (nx3499), .A (cd1_data_26), .B (cd1_data_27), .SEL (
         nx10905)) ;
    DFFC U_command_control_CD1_reg_reg_data_27 (.Q (cd1_data_27), .QB (
         \$dummy [316]), .D (nx3489), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3490 (.OUT (nx3489), .A (cd1_data_27), .B (cd1_data_28), .SEL (
         nx10905)) ;
    DFFP U_command_control_CD1_reg_reg_data_28 (.Q (cd1_data_28), .QB (
         \$dummy [317]), .D (nx3479), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3480 (.OUT (nx3479), .A (cd1_data_28), .B (
         U_command_control_CD1_data_out_29), .SEL (nx10905)) ;
    DFFC U_command_control_CD1_reg_reg_data_29 (.Q (
         U_command_control_CD1_data_out_29), .QB (\$dummy [318]), .D (nx3469), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3470 (.OUT (nx3469), .A (U_command_control_CD1_data_out_29), .B (
         U_command_control_CD1_data_out_30), .SEL (nx10905)) ;
    DFFC U_command_control_CD1_reg_reg_data_30 (.Q (
         U_command_control_CD1_data_out_30), .QB (\$dummy [319]), .D (nx3459), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3460 (.OUT (nx3459), .A (U_command_control_CD1_data_out_30), .B (
         U_command_control_CD1_data_out_31), .SEL (nx10905)) ;
    DFFC U_command_control_CD1_reg_reg_data_31 (.Q (
         U_command_control_CD1_data_out_31), .QB (\$dummy [320]), .D (nx3449), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3450 (.OUT (nx3449), .A (U_command_control_CD1_data_out_31), .B (
         nx564), .SEL (nx10905)) ;
    Nand2 ix565 (.OUT (nx564), .A (nx8651), .B (nx10839)) ;
    Nand2 ix8652 (.OUT (nx8651), .A (cd1_data_0), .B (nx7696)) ;
    Nand4 ix8654 (.OUT (nx8653), .A (nx7917), .B (nx3201), .C (nx8655), .D (
          nx8657)) ;
    Nor2 ix8656 (.OUT (nx8655), .A (nx10745), .B (
         U_command_control_int_hdr_data_17__XX0_XREP39)) ;
    DFFP U_command_control_CD0_reg_reg_data_0 (.Q (cd0_data_0), .QB (
         \$dummy [321]), .D (nx4079), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4080 (.OUT (nx4079), .A (cd0_data_0), .B (cd0_data_1), .SEL (nx10919)
         ) ;
    DFFP U_command_control_CD0_reg_reg_data_1 (.Q (cd0_data_1), .QB (
         \$dummy [322]), .D (nx4069), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4070 (.OUT (nx4069), .A (cd0_data_1), .B (cd0_data_2), .SEL (nx10919)
         ) ;
    DFFP U_command_control_CD0_reg_reg_data_2 (.Q (cd0_data_2), .QB (
         \$dummy [323]), .D (nx4059), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4060 (.OUT (nx4059), .A (cd0_data_2), .B (cd0_data_3), .SEL (nx10919)
         ) ;
    DFFP U_command_control_CD0_reg_reg_data_3 (.Q (cd0_data_3), .QB (
         \$dummy [324]), .D (nx4049), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4050 (.OUT (nx4049), .A (cd0_data_3), .B (cd0_data_4), .SEL (nx10919)
         ) ;
    DFFP U_command_control_CD0_reg_reg_data_4 (.Q (cd0_data_4), .QB (
         \$dummy [325]), .D (nx4039), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix4040 (.OUT (nx4039), .A (cd0_data_4), .B (cd0_data_5), .SEL (nx10919)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_5 (.Q (cd0_data_5), .QB (
         \$dummy [326]), .D (nx4029), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4030 (.OUT (nx4029), .A (cd0_data_5), .B (cd0_data_6), .SEL (nx10917)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_6 (.Q (cd0_data_6), .QB (
         \$dummy [327]), .D (nx4019), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4020 (.OUT (nx4019), .A (cd0_data_6), .B (cd0_data_7), .SEL (nx10917)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_7 (.Q (cd0_data_7), .QB (
         \$dummy [328]), .D (nx4009), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4010 (.OUT (nx4009), .A (cd0_data_7), .B (cd0_data_8), .SEL (nx10917)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_8 (.Q (cd0_data_8), .QB (
         \$dummy [329]), .D (nx3999), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix4000 (.OUT (nx3999), .A (cd0_data_8), .B (cd0_data_9), .SEL (nx10917)
         ) ;
    DFFC U_command_control_CD0_reg_reg_data_9 (.Q (cd0_data_9), .QB (
         \$dummy [330]), .D (nx3989), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3990 (.OUT (nx3989), .A (cd0_data_9), .B (cd0_data_10), .SEL (nx10917
         )) ;
    DFFC U_command_control_CD0_reg_reg_data_10 (.Q (cd0_data_10), .QB (
         \$dummy [331]), .D (nx3979), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3980 (.OUT (nx3979), .A (cd0_data_10), .B (cd0_data_11), .SEL (
         nx10917)) ;
    DFFC U_command_control_CD0_reg_reg_data_11 (.Q (cd0_data_11), .QB (
         \$dummy [332]), .D (nx3969), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3970 (.OUT (nx3969), .A (cd0_data_11), .B (cd0_data_12), .SEL (
         nx10917)) ;
    DFFP U_command_control_CD0_reg_reg_data_12 (.Q (cd0_data_12), .QB (
         \$dummy [333]), .D (nx3959), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3960 (.OUT (nx3959), .A (cd0_data_12), .B (
         U_command_control_CD0_data_out_13), .SEL (nx10917)) ;
    DFFC U_command_control_CD0_reg_reg_data_13 (.Q (
         U_command_control_CD0_data_out_13), .QB (\$dummy [334]), .D (nx3949), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3950 (.OUT (nx3949), .A (U_command_control_CD0_data_out_13), .B (
         U_command_control_CD0_data_out_14), .SEL (nx10917)) ;
    DFFC U_command_control_CD0_reg_reg_data_14 (.Q (
         U_command_control_CD0_data_out_14), .QB (\$dummy [335]), .D (nx3939), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3940 (.OUT (nx3939), .A (U_command_control_CD0_data_out_14), .B (
         U_command_control_CD0_data_out_15), .SEL (nx10915)) ;
    DFFC U_command_control_CD0_reg_reg_data_15 (.Q (
         U_command_control_CD0_data_out_15), .QB (\$dummy [336]), .D (nx3929), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3930 (.OUT (nx3929), .A (U_command_control_CD0_data_out_15), .B (
         cd0_data_16), .SEL (nx10915)) ;
    DFFP U_command_control_CD0_reg_reg_data_16 (.Q (cd0_data_16), .QB (
         \$dummy [337]), .D (nx3919), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3920 (.OUT (nx3919), .A (cd0_data_16), .B (cd0_data_17), .SEL (
         nx10915)) ;
    DFFP U_command_control_CD0_reg_reg_data_17 (.Q (cd0_data_17), .QB (
         \$dummy [338]), .D (nx3909), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3910 (.OUT (nx3909), .A (cd0_data_17), .B (cd0_data_18), .SEL (
         nx10915)) ;
    DFFP U_command_control_CD0_reg_reg_data_18 (.Q (cd0_data_18), .QB (
         \$dummy [339]), .D (nx3899), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3900 (.OUT (nx3899), .A (cd0_data_18), .B (cd0_data_19), .SEL (
         nx10915)) ;
    DFFP U_command_control_CD0_reg_reg_data_19 (.Q (cd0_data_19), .QB (
         \$dummy [340]), .D (nx3889), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3890 (.OUT (nx3889), .A (cd0_data_19), .B (cd0_data_20), .SEL (
         nx10915)) ;
    DFFP U_command_control_CD0_reg_reg_data_20 (.Q (cd0_data_20), .QB (
         \$dummy [341]), .D (nx3879), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3880 (.OUT (nx3879), .A (cd0_data_20), .B (cd0_data_21), .SEL (
         nx10915)) ;
    DFFC U_command_control_CD0_reg_reg_data_21 (.Q (cd0_data_21), .QB (
         \$dummy [342]), .D (nx3869), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3870 (.OUT (nx3869), .A (cd0_data_21), .B (cd0_data_22), .SEL (
         nx10915)) ;
    DFFC U_command_control_CD0_reg_reg_data_22 (.Q (cd0_data_22), .QB (
         \$dummy [343]), .D (nx3859), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3860 (.OUT (nx3859), .A (cd0_data_22), .B (cd0_data_23), .SEL (
         nx10915)) ;
    DFFC U_command_control_CD0_reg_reg_data_23 (.Q (cd0_data_23), .QB (
         \$dummy [344]), .D (nx3849), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3850 (.OUT (nx3849), .A (cd0_data_23), .B (cd0_data_24), .SEL (
         nx10913)) ;
    DFFC U_command_control_CD0_reg_reg_data_24 (.Q (cd0_data_24), .QB (
         \$dummy [345]), .D (nx3839), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3840 (.OUT (nx3839), .A (cd0_data_24), .B (cd0_data_25), .SEL (
         nx10913)) ;
    DFFC U_command_control_CD0_reg_reg_data_25 (.Q (cd0_data_25), .QB (
         \$dummy [346]), .D (nx3829), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3830 (.OUT (nx3829), .A (cd0_data_25), .B (cd0_data_26), .SEL (
         nx10913)) ;
    DFFC U_command_control_CD0_reg_reg_data_26 (.Q (cd0_data_26), .QB (
         \$dummy [347]), .D (nx3819), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3820 (.OUT (nx3819), .A (cd0_data_26), .B (cd0_data_27), .SEL (
         nx10913)) ;
    DFFC U_command_control_CD0_reg_reg_data_27 (.Q (cd0_data_27), .QB (
         \$dummy [348]), .D (nx3809), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3810 (.OUT (nx3809), .A (cd0_data_27), .B (cd0_data_28), .SEL (
         nx10913)) ;
    DFFP U_command_control_CD0_reg_reg_data_28 (.Q (cd0_data_28), .QB (
         \$dummy [349]), .D (nx3799), .CLK (sysclk), .PRB (int_reset_l)) ;
    Mux2 ix3800 (.OUT (nx3799), .A (cd0_data_28), .B (
         U_command_control_CD0_data_out_29), .SEL (nx10913)) ;
    DFFC U_command_control_CD0_reg_reg_data_29 (.Q (
         U_command_control_CD0_data_out_29), .QB (\$dummy [350]), .D (nx3789), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3790 (.OUT (nx3789), .A (U_command_control_CD0_data_out_29), .B (
         U_command_control_CD0_data_out_30), .SEL (nx10913)) ;
    DFFC U_command_control_CD0_reg_reg_data_30 (.Q (
         U_command_control_CD0_data_out_30), .QB (\$dummy [351]), .D (nx3779), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3780 (.OUT (nx3779), .A (U_command_control_CD0_data_out_30), .B (
         U_command_control_CD0_data_out_31), .SEL (nx10913)) ;
    DFFC U_command_control_CD0_reg_reg_data_31 (.Q (
         U_command_control_CD0_data_out_31), .QB (\$dummy [352]), .D (nx3769), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix3770 (.OUT (nx3769), .A (U_command_control_CD0_data_out_31), .B (
         nx714), .SEL (nx10913)) ;
    Nand2 ix715 (.OUT (nx714), .A (nx8756), .B (nx10839)) ;
    Nand2 ix8757 (.OUT (nx8756), .A (cd0_data_0), .B (nx7696)) ;
    Nand4 ix8759 (.OUT (nx8758), .A (nx3201), .B (nx8655), .C (nx8020), .D (
          nx8657)) ;
    Nor2 ix533 (.OUT (nx532), .A (nx8793), .B (nx7562_XX0_XREP39)) ;
    DFFC reg_int_rdback (.Q (int_rdback), .QB (nx8793), .D (rdback), .CLK (
         NOT_sysclk), .CLR (int_reset_l)) ;
    Inv ix8796 (.OUT (NOT_sysclk), .A (sysclk)) ;
    Nand2 ix425 (.OUT (nx424), .A (nx7709), .B (
          U_command_control_int_hdr_data_18)) ;
    Nand2 ix8801 (.OUT (nx8800), .A (nx7444_XX0_XREP465), .B (nx7606)) ;
    Nor2 ix521 (.OUT (nx520), .A (nx7611), .B (nx8803)) ;
    Nand4 ix8807 (.OUT (nx8806), .A (nx7466_XX0_XREP23), .B (nx184), .C (
          nx7472_XX0_XREP21), .D (nx7481)) ;
    Nor2 ix185 (.OUT (nx184), .A (nx7490), .B (U_command_control_cmd_cnt_4)) ;
    Nand2 ix8810 (.OUT (nx8809), .A (U_command_control_cmd_state_2__XX0_XREP465)
          , .B (nx7606)) ;
    Nor3 ix515 (.OUT (nx514), .A (nx8814), .B (nx7509), .C (nx7604)) ;
    Nor3 ix8815 (.OUT (nx8814), .A (nx506), .B (nx498), .C (nx462)) ;
    Nor4 ix507 (.OUT (nx506), .A (U_command_control_cmd_cnt_4), .B (nx7511), .C (
         U_command_control_cmd_cnt_3__XX0_XREP23), .D (
         U_command_control_cmd_cnt_2__XX0_XREP21)) ;
    Nor3 ix499 (.OUT (nx498), .A (nx8818), .B (nx7466_XX0_XREP23), .C (
         nx7472_XX0_XREP21)) ;
    AOI22 ix8819 (.OUT (nx8818), .A (nx7520), .B (nx488), .C (nx466), .D (nx474)
          ) ;
    AO22 ix489 (.OUT (nx488), .A (U_command_control_int_hdr_data_12__XX0_XREP33)
         , .B (nx7481), .C (nx7511_XX0_XREP27), .D (nx478)) ;
    Nor2 ix479 (.OUT (nx478), .A (nx7565_XX0_XREP1), .B (nx7478_XX0_XREP25)) ;
    Nor2 ix467 (.OUT (nx466), .A (U_command_control_cmd_cnt_4), .B (nx7511)) ;
    Nor2 ix463 (.OUT (nx462), .A (nx7520), .B (nx8825)) ;
    AOI22 ix8826 (.OUT (nx8825), .A (nx7472_XX0_XREP21), .B (nx454), .C (nx7511)
          , .D (nx426)) ;
    Nand3 ix455 (.OUT (nx454), .A (nx8828), .B (nx8830), .C (nx8832)) ;
    AOI22 ix8829 (.OUT (nx8828), .A (U_command_control_int_hdr_data_19), .B (
          nx3199), .C (nx10747), .D (nx7481)) ;
    Nand3 ix8831 (.OUT (nx8830), .A (U_command_control_cmd_cnt_0__XX0_XREP27), .B (
          U_command_control_int_hdr_data_17__XX0_XREP39), .C (nx7478)) ;
    Nand3 ix8833 (.OUT (nx8832), .A (nx7511_XX0_XREP27), .B (
          U_command_control_int_hdr_data_18), .C (
          U_command_control_cmd_cnt_1__XX0_XREP25)) ;
    Nor2 ix427 (.OUT (nx426), .A (nx7559), .B (nx7472_XX0_XREP21)) ;
    Nand3 ix8837 (.OUT (nx8836), .A (nx358), .B (U_command_control_cmd_state_2)
          , .C (U_command_control_cmd_state_1__XX0_XREP471)) ;
    Nor2 ix8839 (.OUT (nx8838), .A (nx7567), .B (
         U_command_control_int_hdr_data_13)) ;
    Nor2 ix2865 (.OUT (nx2864), .A (nx10833), .B (nx8844)) ;
    AOI22 ix8845 (.OUT (nx8844), .A (sel_addr_reg), .B (nx8847), .C (nx2850), .D (
          nx2854)) ;
    DFFC U_command_control_reg_int_sel_addr (.Q (sel_addr_reg), .QB (nx8841), .D (
         nx2864), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2851 (.OUT (nx2850), .A (nx7472), .B (U_command_control_cmd_cnt_5), .C (
         nx7466)) ;
    Nor3 ix2855 (.OUT (nx2854), .A (U_command_control_cmd_cnt_1), .B (
         U_command_control_cmd_cnt_4), .C (nx7511)) ;
    Nor2 ix8852 (.OUT (nx8851), .A (nx3782), .B (nx3036)) ;
    Nand2 ix3783 (.OUT (nx3782), .A (nx8854), .B (nx8857)) ;
    Nand4 ix8855 (.OUT (nx8854), .A (U_command_control_int_cmd_en), .B (nx3770)
          , .C (nx8020), .D (nx8657)) ;
    Nor2 ix3771 (.OUT (nx3770), .A (nx7562), .B (nx10747)) ;
    DFFC U_readout_control_reg_int_rd_clken (.Q (\$dummy [353]), .QB (nx8857), .D (
         nx3762), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3763 (.OUT (nx3762), .A (nx8860), .B (nx9203)) ;
    AOI22 ix8861 (.OUT (nx8860), .A (nx8862), .B (nx9486), .C (nx8973), .D (
          nx3748)) ;
    Nand3 ix3495 (.OUT (nx3494), .A (U_readout_control_rd_state_0__XX0_XREP291)
          , .B (U_readout_control_rd_state_1), .C (
          U_readout_control_rd_state_2__XX0_XREP297)) ;
    Nand2 ix3399 (.OUT (nx3398), .A (nx8871), .B (nx9203)) ;
    Nand2 ix8872 (.OUT (nx8871), .A (nx8873), .B (nx3392)) ;
    Nand3 ix8884 (.OUT (nx8883), .A (U_readout_control_typ_cnt_2), .B (
          U_readout_control_typ_cnt_1), .C (U_readout_control_typ_cnt_0)) ;
    Mux2 ix7100 (.OUT (nx7099), .A (nx3338), .B (U_readout_control_typ_cnt_2), .SEL (
         nx3231_XX0_XREP109)) ;
    Nor3 ix3339 (.OUT (nx3338), .A (nx8888), .B (nx3330), .C (nx3228)) ;
    Nor2 ix8889 (.OUT (nx8888), .A (nx3232), .B (U_readout_control_typ_cnt_2)) ;
    DFFC U_readout_control_reg_rd_state_1 (.Q (U_readout_control_rd_state_1), .QB (
         nx8905), .D (nx3398), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix8911 (.OUT (nx8910), .A (nx8912), .B (nx3388)) ;
    Mux2 ix7140 (.OUT (nx7139), .A (nx3458), .B (U_readout_control_row_cnt_3), .SEL (
         nx3414_XX0_XREP113)) ;
    Nor3 ix3459 (.OUT (nx3458), .A (nx8921), .B (nx8940_XX0_XREP111), .C (nx3236
         )) ;
    Nor2 ix8922 (.OUT (nx8921), .A (nx3235), .B (U_readout_control_row_cnt_3)) ;
    Mux2 ix7130 (.OUT (nx7129), .A (nx3444), .B (U_readout_control_row_cnt_2), .SEL (
         nx3414_XX0_XREP113)) ;
    Nor3 ix3445 (.OUT (nx3444), .A (nx8928), .B (nx8940_XX0_XREP111), .C (nx3235
         )) ;
    Nor2 ix8929 (.OUT (nx8928), .A (nx3234), .B (U_readout_control_row_cnt_2)) ;
    Nor2 ix3437 (.OUT (nx3234), .A (nx8931), .B (nx9117)) ;
    Mux2 ix7120 (.OUT (nx7119), .A (nx3430), .B (U_readout_control_row_cnt_1), .SEL (
         nx3414)) ;
    Nor3 ix3431 (.OUT (nx3430), .A (nx8935), .B (nx8940), .C (nx3234)) ;
    Nor2 ix8936 (.OUT (nx8935), .A (U_readout_control_row_cnt_0), .B (
         U_readout_control_row_cnt_1)) ;
    DFFC reg_U_readout_control_row_cnt_0 (.Q (U_readout_control_row_cnt_0), .QB (
         nx9117), .D (nx7109), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7110 (.OUT (nx7109), .A (nx3418), .B (U_readout_control_row_cnt_0), .SEL (
         nx3414)) ;
    Nor2 ix3419 (.OUT (nx3418), .A (U_readout_control_row_cnt_0), .B (nx8940)) ;
    DFFC U_readout_control_reg_int_evt_cnt_2 (.Q (
         U_readout_control_int_evt_cnt_2), .QB (\$dummy [354]), .D (nx3360), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3361 (.OUT (nx3360), .A (U_readout_control_int_data_sft_7), .B (
         nx3229), .C (U_readout_control_int_evt_cnt_2), .D (nx3248)) ;
    DFFC U_readout_control_reg_int_data_sft_7 (.Q (
         U_readout_control_int_data_sft_7), .QB (nx9076), .D (nx7069), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7070 (.OUT (nx7069), .A (U_readout_control_int_data_sft_7), .B (
         U_readout_control_int_data_sft_6), .SEL (nx8971_XX0_XREP121)) ;
    DFFC U_readout_control_reg_int_data_sft_6 (.Q (
         U_readout_control_int_data_sft_6), .QB (nx9075), .D (nx7059), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7060 (.OUT (nx7059), .A (U_readout_control_int_data_sft_6), .B (
         U_readout_control_int_data_sft_5), .SEL (nx8971_XX0_XREP121)) ;
    DFFC U_readout_control_reg_int_data_sft_5 (.Q (
         U_readout_control_int_data_sft_5), .QB (\$dummy [355]), .D (nx7049), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7050 (.OUT (nx7049), .A (U_readout_control_int_data_sft_5), .B (
         U_readout_control_int_data_sft_4), .SEL (nx8971_XX0_XREP121)) ;
    DFFC U_readout_control_reg_int_data_sft_4 (.Q (
         U_readout_control_int_data_sft_4), .QB (\$dummy [356]), .D (nx7039), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7040 (.OUT (nx7039), .A (U_readout_control_int_data_sft_4), .B (
         U_readout_control_int_data_sft_3), .SEL (nx8971_XX0_XREP121)) ;
    DFFC U_readout_control_reg_int_data_sft_3 (.Q (
         U_readout_control_int_data_sft_3), .QB (\$dummy [357]), .D (nx7029), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7030 (.OUT (nx7029), .A (U_readout_control_int_data_sft_3), .B (
         U_readout_control_int_data_sft_2), .SEL (nx8971)) ;
    DFFC U_readout_control_reg_int_data_sft_2 (.Q (
         U_readout_control_int_data_sft_2), .QB (\$dummy [358]), .D (nx7019), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7020 (.OUT (nx7019), .A (U_readout_control_int_data_sft_2), .B (
         U_readout_control_int_data_sft_1), .SEL (nx8971)) ;
    DFFC U_readout_control_reg_int_data_sft_1 (.Q (
         U_readout_control_int_data_sft_1), .QB (\$dummy [359]), .D (nx7009), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7010 (.OUT (nx7009), .A (U_readout_control_int_data_sft_1), .B (
         U_readout_control_int_data_sft_0), .SEL (nx8971)) ;
    DFFC U_readout_control_reg_int_data_sft_0 (.Q (
         U_readout_control_int_data_sft_0), .QB (\$dummy [360]), .D (nx6999), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7000 (.OUT (nx6999), .A (U_readout_control_int_data_sft_0), .B (
         int_rdback), .SEL (nx8971)) ;
    Nor2 ix3043 (.OUT (nx3042), .A (U_readout_control_st_cnt_0), .B (nx3222)) ;
    Inv ix3677 (.OUT (nx3222), .A (nx8979)) ;
    Nor4 ix8980 (.OUT (nx8979), .A (nx3670), .B (nx8940), .C (nx3660), .D (
         nx3642)) ;
    Nor2 ix3671 (.OUT (nx3670), .A (nx3664), .B (nx3240)) ;
    Nand3 ix3665 (.OUT (nx3664), .A (U_readout_control_rd_state_0__XX0_XREP291)
          , .B (U_readout_control_rd_state_1), .C (nx8907_XX0_XREP297)) ;
    Nand4 ix3699 (.OUT (nx3240), .A (nx8984), .B (nx9024_XX0_XREP79), .C (nx9049
          ), .D (nx8994)) ;
    Nor3 ix8985 (.OUT (nx8984), .A (nx8986_XX0_XREP85), .B (nx8988_XX0_XREP83), 
         .C (nx3650)) ;
    Nor2 ix8992 (.OUT (nx8991), .A (nx3048), .B (U_readout_control_st_cnt_2)) ;
    Nor2 ix3049 (.OUT (nx3048), .A (nx8994), .B (nx8986_XX0_XREP85)) ;
    Nor2 ix3681 (.OUT (nx3680), .A (nx3222), .B (nx8997)) ;
    Nand2 ix8998 (.OUT (nx8997), .A (nx8999), .B (nx3172)) ;
    DFFC reg_U_readout_control_st_cnt_1 (.Q (U_readout_control_st_cnt_1), .QB (
         nx8994), .D (nx3680), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix3651 (.OUT (nx3650), .A (nx9006), .B (nx9040), .C (nx9012), .D (
          U_readout_control_st_cnt_4)) ;
    Nor3 ix3123 (.OUT (nx3122), .A (nx9009), .B (nx3226), .C (nx3222)) ;
    Nor2 ix9010 (.OUT (nx9009), .A (nx3100), .B (U_readout_control_st_cnt_6)) ;
    Nor2 ix3101 (.OUT (nx3100), .A (nx9012), .B (nx9034)) ;
    Nor3 ix3109 (.OUT (nx3108), .A (nx9015), .B (nx3100), .C (nx3222)) ;
    Nor2 ix9016 (.OUT (nx9015), .A (nx3225), .B (U_readout_control_st_cnt_5)) ;
    Nor3 ix3091 (.OUT (nx3090), .A (nx9021), .B (nx3225), .C (nx3222)) ;
    Nor2 ix9022 (.OUT (nx9021), .A (nx3224), .B (U_readout_control_st_cnt_4)) ;
    Nor2 ix3081 (.OUT (nx3224), .A (nx9024_XX0_XREP79), .B (nx9030)) ;
    Nor2 ix9028 (.OUT (nx9027), .A (nx3223), .B (U_readout_control_st_cnt_3)) ;
    Nand2 ix9031 (.OUT (nx9030), .A (U_readout_control_st_cnt_2__XX0_XREP83), .B (
          nx3048)) ;
    DFFC reg_U_readout_control_st_cnt_4 (.Q (U_readout_control_st_cnt_4), .QB (
         nx9018), .D (nx3090), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_st_cnt_5 (.Q (U_readout_control_st_cnt_5), .QB (
         nx9012), .D (nx3108), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix9035 (.OUT (nx9034), .A (U_readout_control_st_cnt_4), .B (nx3224)) ;
    DFFC reg_U_readout_control_st_cnt_6 (.Q (U_readout_control_st_cnt_6), .QB (
         nx9006), .D (nx3122), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3141 (.OUT (nx3140), .A (nx9043), .B (nx3132), .C (nx3222)) ;
    Nor2 ix9044 (.OUT (nx9043), .A (nx3226), .B (U_readout_control_st_cnt_7)) ;
    DFFC reg_U_readout_control_st_cnt_7 (.Q (U_readout_control_st_cnt_7), .QB (
         nx9040), .D (nx3140), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix3133 (.OUT (nx3132), .A (nx9040), .B (nx9047)) ;
    Nand2 ix9048 (.OUT (nx9047), .A (U_readout_control_st_cnt_6), .B (nx3100)) ;
    Nor2 ix3161 (.OUT (nx3160), .A (nx9052), .B (nx3222)) ;
    DFFC reg_U_readout_control_st_cnt_8 (.Q (U_readout_control_st_cnt_8), .QB (
         nx9049), .D (nx3160), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3661 (.OUT (nx3660), .A (nx3654), .B (U_readout_control_rd_state_1), 
         .C (U_readout_control_rd_state_2__XX0_XREP297)) ;
    Nand4 ix3655 (.OUT (nx3654), .A (nx9057), .B (nx9059), .C (nx9061), .D (
          U_readout_control_st_cnt_8)) ;
    Nor2 ix9058 (.OUT (nx9057), .A (U_readout_control_st_cnt_0__XX0_XREP85), .B (
         U_readout_control_st_cnt_1)) ;
    Nor2 ix9062 (.OUT (nx9061), .A (nx8988_XX0_XREP83), .B (nx9024_XX0_XREP79)
         ) ;
    Nor3 ix3643 (.OUT (nx3642), .A (nx9064), .B (U_readout_control_rd_state_2), 
         .C (U_readout_control_rd_state_0__XX0_XREP291)) ;
    Nor4 ix9067 (.OUT (nx9066), .A (nx3168), .B (U_readout_control_st_cnt_6), .C (
         U_readout_control_st_cnt_7), .D (U_readout_control_st_cnt_5)) ;
    Nand4 ix3169 (.OUT (nx3168), .A (nx9018), .B (nx9049), .C (
          U_readout_control_st_cnt_2__XX0_XREP83), .D (
          U_readout_control_st_cnt_3__XX0_XREP79)) ;
    Nor2 ix3355 (.OUT (nx3229), .A (nx3198), .B (nx3230)) ;
    Nand4 ix3349 (.OUT (nx3230), .A (nx9080), .B (nx9083), .C (nx9088), .D (
          nx9090)) ;
    Nor3 ix9081 (.OUT (nx9080), .A (U_readout_control_typ_cnt_1), .B (
         U_readout_control_typ_cnt_2), .C (
         U_readout_control_typ_cnt_3__XX0_XREP89_XX0_XREP303)) ;
    DFFC reg_U_readout_control_typ_cnt_1 (.Q (U_readout_control_typ_cnt_1), .QB (
         nx8891), .D (nx7089), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_typ_cnt_0 (.Q (U_readout_control_typ_cnt_0), .QB (
         nx9088), .D (nx7079), .CLK (sysclk), .CLR (int_reset_l)) ;
    AOI22 ix9091 (.OUT (nx9090), .A (nx9076), .B (
          U_readout_control_int_evt_cnt_2), .C (nx9092), .D (nx3286)) ;
    AO22 ix3287 (.OUT (nx3286), .A (nx9075), .B (U_readout_control_int_evt_cnt_1
         ), .C (nx9102), .D (nx3276)) ;
    DFFC U_readout_control_reg_int_evt_cnt_1 (.Q (
         U_readout_control_int_evt_cnt_1), .QB (\$dummy [361]), .D (nx3252), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3253 (.OUT (nx3252), .A (U_readout_control_int_data_sft_6), .B (
         nx3229), .C (U_readout_control_int_evt_cnt_1), .D (nx3248)) ;
    Nor2 ix3249 (.OUT (nx3248), .A (nx3198), .B (nx9098)) ;
    Nand2 ix3277 (.OUT (nx3276), .A (U_readout_control_int_data_sft_5), .B (
          nx9105)) ;
    AO22 ix3265 (.OUT (nx3264), .A (U_readout_control_int_data_sft_5), .B (
         nx3229), .C (U_readout_control_int_evt_cnt_0), .D (nx3248)) ;
    DFFC U_readout_control_reg_int_evt_cnt_0 (.Q (
         U_readout_control_int_evt_cnt_0), .QB (nx9105), .D (nx3264), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nor2 ix9116 (.OUT (nx9115), .A (U_readout_control_rd_state_1), .B (
         U_readout_control_rd_state_2__XX0_XREP297)) ;
    DFFC reg_U_readout_control_row_cnt_1 (.Q (U_readout_control_row_cnt_1), .QB (
         nx8931), .D (nx7119), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_row_cnt_2 (.Q (U_readout_control_row_cnt_2), .QB (
         \$dummy [362]), .D (nx7129), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix3465 (.OUT (nx3236), .A (nx9121), .B (nx9123)) ;
    DFFC reg_U_readout_control_row_cnt_3 (.Q (U_readout_control_row_cnt_3), .QB (
         nx9121), .D (nx7139), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix9124 (.OUT (nx9123), .A (U_readout_control_row_cnt_2), .B (
          U_readout_control_row_cnt_1), .C (U_readout_control_row_cnt_0)) ;
    Mux2 ix7150 (.OUT (nx7149), .A (nx3468), .B (U_readout_control_row_cnt_4), .SEL (
         nx3414)) ;
    Nor2 ix3469 (.OUT (nx3468), .A (nx8940_XX0_XREP111), .B (nx9129)) ;
    Xnor2 ix9130 (.out (nx9129), .A (U_readout_control_row_cnt_4), .B (nx3236)
          ) ;
    DFFC reg_U_readout_control_row_cnt_4 (.Q (U_readout_control_row_cnt_4), .QB (
         \$dummy [363]), .D (nx7149), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix3193 (.OUT (nx3192), .A (U_readout_control_rd_state_1), .B (
          U_readout_control_rd_state_2__XX0_XREP297), .C (nx8864_XX0_XREP291)) ;
    Nand3 ix9141 (.OUT (nx9140), .A (nx3542), .B (U_readout_control_col_cnt_4), 
          .C (nx3239)) ;
    DFFC reg_U_readout_control_col_cnt_4 (.Q (U_readout_control_col_cnt_4), .QB (
         \$dummy [364]), .D (nx7209), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7210 (.OUT (nx7209), .A (U_readout_control_col_cnt_4), .B (nx3614), .SEL (
         nx9176_XX0_XREP133)) ;
    Nor2 ix3615 (.OUT (nx3614), .A (nx9146), .B (nx3548)) ;
    Xnor2 ix9147 (.out (nx9146), .A (U_readout_control_col_cnt_4), .B (nx3239)
          ) ;
    Nor2 ix3609 (.OUT (nx3239), .A (nx9149), .B (nx9179)) ;
    Mux2 ix7200 (.OUT (nx7199), .A (U_readout_control_col_cnt_3), .B (nx3602), .SEL (
         nx9176_XX0_XREP133)) ;
    DFFC reg_U_readout_control_col_cnt_3 (.Q (U_readout_control_col_cnt_3), .QB (
         nx9149), .D (nx7199), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3603 (.OUT (nx3602), .A (nx9154), .B (nx3239), .C (nx3548)) ;
    Nor2 ix9155 (.OUT (nx9154), .A (nx3238), .B (U_readout_control_col_cnt_3)) ;
    Mux2 ix7190 (.OUT (nx7189), .A (U_readout_control_col_cnt_2), .B (nx3586), .SEL (
         nx9176)) ;
    DFFC reg_U_readout_control_col_cnt_2 (.Q (U_readout_control_col_cnt_2), .QB (
         \$dummy [365]), .D (nx7189), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3587 (.OUT (nx3586), .A (nx9162), .B (nx3238), .C (nx3548)) ;
    Nor2 ix9163 (.OUT (nx9162), .A (nx3237), .B (U_readout_control_col_cnt_2)) ;
    Nor2 ix3577 (.OUT (nx3237), .A (nx9165), .B (nx9178)) ;
    Mux2 ix7180 (.OUT (nx7179), .A (U_readout_control_col_cnt_1), .B (nx3570), .SEL (
         nx9176)) ;
    DFFC reg_U_readout_control_col_cnt_1 (.Q (U_readout_control_col_cnt_1), .QB (
         nx9165), .D (nx7179), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3571 (.OUT (nx3570), .A (nx9170), .B (nx3237), .C (nx3548)) ;
    Nor2 ix9171 (.OUT (nx9170), .A (U_readout_control_col_cnt_0), .B (
         U_readout_control_col_cnt_1)) ;
    DFFC reg_U_readout_control_col_cnt_0 (.Q (U_readout_control_col_cnt_0), .QB (
         nx9178), .D (nx7169), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7170 (.OUT (nx7169), .A (U_readout_control_col_cnt_0), .B (nx3556), .SEL (
         nx9176)) ;
    Nor2 ix3557 (.OUT (nx3556), .A (U_readout_control_col_cnt_0), .B (nx3548)) ;
    Nand3 ix9180 (.OUT (nx9179), .A (U_readout_control_col_cnt_2), .B (
          U_readout_control_col_cnt_1), .C (U_readout_control_col_cnt_0)) ;
    Nand2 ix9183 (.OUT (nx9182), .A (nx8876), .B (nx11716)) ;
    Nand2 ix3479 (.OUT (nx3478), .A (nx3236), .B (U_readout_control_row_cnt_4)
          ) ;
    Nand2 ix3739 (.OUT (nx3233), .A (nx9115), .B (
          U_readout_control_rd_state_0__XX0_XREP291)) ;
    DFFC reg_U_readout_control_typ_cnt_2 (.Q (U_readout_control_typ_cnt_2), .QB (
         \$dummy [366]), .D (nx7099), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3393 (.OUT (nx3392), .A (nx9201), .B (nx8944)) ;
    Nand2 ix9202 (.OUT (nx9201), .A (nx3233), .B (nx3192)) ;
    Nand2 ix9204 (.OUT (nx9203), .A (nx9198), .B (nx9205)) ;
    AOI22 ix9209 (.OUT (nx9208), .A (nx9115), .B (nx3714), .C (nx3706), .D (
          nx3708)) ;
    Nor3 ix3715 (.OUT (nx3714), .A (nx9211), .B (U_analog_control_mst_state_0), 
         .C (U_analog_control_mst_state_1)) ;
    Nand2 ix2793 (.OUT (nx2792), .A (nx9214), .B (nx3179)) ;
    Nor3 ix9220 (.OUT (nx9219), .A (nx2366), .B (U_analog_control_sub_cnt_12), .C (
         nx2360)) ;
    Nand4 ix2367 (.OUT (nx2366), .A (nx9222), .B (nx9334), .C (nx9345), .D (
          nx9356)) ;
    Nor3 ix2569 (.OUT (nx2568), .A (nx9225), .B (nx3215), .C (nx10759)) ;
    Nor2 ix9226 (.OUT (nx9225), .A (nx3214), .B (U_analog_control_sub_cnt_8)) ;
    Nor2 ix2559 (.OUT (nx3214), .A (nx9228), .B (nx9468)) ;
    Nor3 ix2553 (.OUT (nx2552), .A (nx9231), .B (nx3214), .C (nx10759)) ;
    Nor2 ix9232 (.OUT (nx9231), .A (nx3213), .B (U_analog_control_sub_cnt_7)) ;
    Nor3 ix2537 (.OUT (nx2536), .A (nx9237), .B (nx3213), .C (nx10759)) ;
    Nor2 ix9238 (.OUT (nx9237), .A (nx3212), .B (U_analog_control_sub_cnt_6)) ;
    Nor3 ix2521 (.OUT (nx2520), .A (nx9243), .B (nx3212), .C (nx10759)) ;
    Nor2 ix9244 (.OUT (nx9243), .A (nx3211), .B (U_analog_control_sub_cnt_5)) ;
    Nor3 ix2505 (.OUT (nx2504), .A (nx9249), .B (nx3211), .C (nx10759)) ;
    Nor2 ix9250 (.OUT (nx9249), .A (nx3183), .B (U_analog_control_sub_cnt_4)) ;
    Nor3 ix2489 (.OUT (nx2488), .A (nx9255), .B (nx3183), .C (nx10759)) ;
    Nor2 ix9256 (.OUT (nx9255), .A (nx3210), .B (U_analog_control_sub_cnt_3)) ;
    Nor2 ix9262 (.OUT (nx9261), .A (nx3209), .B (U_analog_control_sub_cnt_2)) ;
    Nor2 ix2463 (.OUT (nx3209), .A (nx9264), .B (nx9413)) ;
    Nor2 ix9268 (.OUT (nx9267), .A (U_analog_control_sub_cnt_0__XX0_XREP147), .B (
         U_analog_control_sub_cnt_1)) ;
    Nor2 ix2443 (.OUT (nx2442), .A (U_analog_control_sub_cnt_0), .B (nx10757)) ;
    Nand4 ix2437 (.OUT (nx2436), .A (nx2430), .B (nx9214), .C (nx9451), .D (
          nx9458)) ;
    Nand2 ix2833 (.OUT (nx2832), .A (nx9276), .B (nx3185)) ;
    AOI22 ix9277 (.OUT (nx9276), .A (start_sequence), .B (nx10921), .C (nx9441)
          , .D (nx9443)) ;
    DFFC U_command_control_reg_start_sequence (.Q (start_sequence), .QB (
         \$dummy [367]), .D (nx6989), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix6990 (.OUT (nx6989), .A (nx2812), .B (start_sequence), .SEL (nx2816)
         ) ;
    Nor2 ix2813 (.OUT (nx2812), .A (
         U_command_control_int_hdr_data_12__XX0_XREP33), .B (nx7701)) ;
    Nand2 ix2817 (.OUT (nx2816), .A (nx2812), .B (nx7564)) ;
    Nand2 ix2777 (.OUT (nx2776), .A (nx9288), .B (nx9439)) ;
    AOI22 ix9289 (.OUT (nx9288), .A (nx9290), .B (nx9293), .C (nx9403), .D (
          nx2762)) ;
    Nor4 ix9294 (.OUT (nx9293), .A (nx2342), .B (nx2328), .C (nx2312), .D (
         nx2298)) ;
    Nand4 ix2343 (.OUT (nx2342), .A (nx9296), .B (nx9298), .C (nx9301), .D (
          nx9304)) ;
    DFFC reg_U_analog_control_sub_cnt_3 (.Q (U_analog_control_sub_cnt_3), .QB (
         nx9252), .D (nx2488), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix2329 (.OUT (nx2328), .A (nx9308), .B (nx9311), .C (nx9314), .D (
          nx9317)) ;
    DFFC reg_U_analog_control_sub_cnt_4 (.Q (U_analog_control_sub_cnt_4), .QB (
         nx9246), .D (nx2504), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_5 (.Q (U_analog_control_sub_cnt_5), .QB (
         nx9240), .D (nx2520), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_6 (.Q (U_analog_control_sub_cnt_6), .QB (
         nx9234), .D (nx2536), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_7 (.Q (U_analog_control_sub_cnt_7), .QB (
         nx9228), .D (nx2552), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix2313 (.OUT (nx2312), .A (nx9321), .B (nx9324), .C (nx9338), .D (
          nx9349)) ;
    DFFC reg_U_analog_control_sub_cnt_8 (.Q (U_analog_control_sub_cnt_8), .QB (
         nx9222), .D (nx2568), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2585 (.OUT (nx2584), .A (nx9328), .B (nx3216), .C (nx10757)) ;
    Nor2 ix9329 (.OUT (nx9328), .A (nx3215), .B (U_analog_control_sub_cnt_9)) ;
    Nor2 ix2591 (.OUT (nx3216), .A (nx9334), .B (nx9336)) ;
    DFFC reg_U_analog_control_sub_cnt_9 (.Q (U_analog_control_sub_cnt_9), .QB (
         nx9334), .D (nx2584), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix9337 (.OUT (nx9336), .A (U_analog_control_sub_cnt_8), .B (nx3214)) ;
    Nor3 ix2601 (.OUT (nx2600), .A (nx9342), .B (nx3217), .C (nx10757)) ;
    Nor2 ix9343 (.OUT (nx9342), .A (nx3216), .B (U_analog_control_sub_cnt_10)) ;
    DFFC reg_U_analog_control_sub_cnt_10 (.Q (U_analog_control_sub_cnt_10), .QB (
         nx9345), .D (nx2600), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2617 (.OUT (nx2616), .A (nx9353), .B (nx3218), .C (nx10757)) ;
    Nor2 ix9354 (.OUT (nx9353), .A (nx3217), .B (U_analog_control_sub_cnt_11)) ;
    DFFC reg_U_analog_control_sub_cnt_11 (.Q (U_analog_control_sub_cnt_11), .QB (
         nx9356), .D (nx2616), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix9359 (.OUT (nx9358), .A (U_analog_control_sub_cnt_10), .B (nx3216)
          ) ;
    Nand4 ix2299 (.OUT (nx2298), .A (nx9361), .B (nx9372), .C (nx9383), .D (
          nx9394)) ;
    Nor3 ix2633 (.OUT (nx2632), .A (nx9365), .B (nx3219), .C (nx10757)) ;
    Nor2 ix9366 (.OUT (nx9365), .A (nx3218), .B (U_analog_control_sub_cnt_12)) ;
    DFFC reg_U_analog_control_sub_cnt_12 (.Q (U_analog_control_sub_cnt_12), .QB (
         nx9368), .D (nx2632), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2649 (.OUT (nx2648), .A (nx9376), .B (nx3220), .C (nx10757)) ;
    Nor2 ix9377 (.OUT (nx9376), .A (nx3219), .B (U_analog_control_sub_cnt_13)) ;
    DFFC reg_U_analog_control_sub_cnt_13 (.Q (U_analog_control_sub_cnt_13), .QB (
         nx9379), .D (nx2648), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2665 (.OUT (nx2664), .A (nx9387), .B (nx3221), .C (nx10757)) ;
    Nor2 ix9388 (.OUT (nx9387), .A (nx3220), .B (U_analog_control_sub_cnt_14)) ;
    DFFC reg_U_analog_control_sub_cnt_14 (.Q (U_analog_control_sub_cnt_14), .QB (
         nx9390), .D (nx2664), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_15 (.Q (U_analog_control_sub_cnt_15), .QB (
         nx9402), .D (nx2676), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix9404 (.OUT (nx9403), .A (U_analog_control_mst_state_0), .B (nx9405)
         ) ;
    Nand2 ix2763 (.OUT (nx2762), .A (nx9408), .B (
          U_analog_control_int_cur_cell_3)) ;
    Nor3 ix9412 (.OUT (nx9411), .A (nx9413_XX0_XREP147), .B (
         U_analog_control_sub_cnt_1__XX0_XREP145), .C (nx2366)) ;
    DFFC U_analog_control_reg_int_cur_cell_3 (.Q (
         U_analog_control_int_cur_cell_3), .QB (\$dummy [368]), .D (nx2754), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix2755 (.OUT (nx2754), .A (U_analog_control_int_cur_cell_3), .B (nx2714
         ), .C (U_analog_control_int_cur_cell_2), .D (nx10)) ;
    Nand2 ix2789 (.OUT (nx3179), .A (nx9403), .B (U_analog_control_mst_state_2)
          ) ;
    DFFC U_analog_control_reg_int_cur_cell_2 (.Q (
         U_analog_control_int_cur_cell_2), .QB (\$dummy [369]), .D (nx2744), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix2745 (.OUT (nx2744), .A (U_analog_control_int_cur_cell_2), .B (nx2714
         ), .C (U_analog_control_int_cur_cell_1), .D (nx10)) ;
    DFFC U_analog_control_reg_int_cur_cell_1 (.Q (
         U_analog_control_int_cur_cell_1), .QB (\$dummy [370]), .D (nx2734), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix2735 (.OUT (nx2734), .A (U_analog_control_int_cur_cell_1), .B (nx2714
         ), .C (U_analog_control_int_cur_cell_0), .D (nx10)) ;
    DFFC U_analog_control_reg_int_cur_cell_0 (.Q (
         U_analog_control_int_cur_cell_0), .QB (\$dummy [371]), .D (nx2724), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix2725 (.OUT (nx2724), .A (nx9211), .B (nx9403), .C (
         U_analog_control_int_cur_cell_0), .D (nx2714)) ;
    Nor2 ix11 (.OUT (nx10), .A (nx3179), .B (nx3181)) ;
    Nand4 ix2711 (.OUT (nx3181), .A (nx9411), .B (nx9430), .C (nx9432), .D (
          nx9434)) ;
    Nor3 ix9431 (.OUT (nx9430), .A (U_analog_control_sub_cnt_3), .B (nx9246), .C (
         U_analog_control_sub_cnt_2__XX0_XREP143)) ;
    Nand2 ix9440 (.OUT (nx9439), .A (nx9211), .B (U_analog_control_mst_state_1)
          ) ;
    Nand3 ix9447 (.OUT (nx9446), .A (U_analog_control_sub_cnt_9), .B (
          U_analog_control_sub_cnt_11), .C (nx9345)) ;
    Nor3 ix33 (.OUT (nx32), .A (nx9234), .B (U_analog_control_sub_cnt_8), .C (
         U_analog_control_sub_cnt_7)) ;
    Nand3 ix2803 (.OUT (nx3185), .A (nx9405), .B (nx9211), .C (
          U_analog_control_mst_state_0)) ;
    AOI22 ix9452 (.OUT (nx9451), .A (nx9290), .B (nx9293), .C (nx9441), .D (nx44
          )) ;
    Nor3 ix45 (.OUT (nx44), .A (nx9454), .B (nx9446), .C (nx9456)) ;
    Nand3 ix9455 (.OUT (nx9454), .A (U_analog_control_sub_cnt_12), .B (
          U_analog_control_sub_cnt_14), .C (nx9379)) ;
    Nand4 ix9457 (.OUT (nx9456), .A (nx32), .B (nx3183), .C (nx9240), .D (nx9246
          )) ;
    Nand2 ix9469 (.OUT (nx9468), .A (U_analog_control_sub_cnt_6), .B (nx3212)) ;
    Nand3 ix2361 (.OUT (nx2360), .A (nx9390), .B (nx9402), .C (nx9379)) ;
    Nand2 ix3707 (.OUT (nx3706), .A (nx3384), .B (nx8914)) ;
    Nor2 ix3709 (.OUT (nx3708), .A (nx8907), .B (nx8905)) ;
    Nand3 ix9485 (.OUT (nx9484), .A (nx3240), .B (U_readout_control_rd_state_0)
          , .C (U_readout_control_rd_state_1)) ;
    Nand3 ix3749 (.OUT (nx3748), .A (nx8994), .B (nx8986), .C (nx9066)) ;
    Nand3 ix3037 (.OUT (nx3036), .A (nx9491), .B (nx3182), .C (nx9577)) ;
    Nor2 ix3027 (.OUT (nx3026), .A (nx9494), .B (nx9496)) ;
    Nand3 ix9495 (.OUT (nx9494), .A (nx9403), .B (U_analog_control_mst_state_2)
          , .C (nx3181)) ;
    Nor2 ix9497 (.OUT (nx9496), .A (ramp_period), .B (
         U_analog_control_sft_desel_all_cells_16)) ;
    DFFC U_analog_control_reg_int_ramp_period (.Q (ramp_period), .QB (nx9491), .D (
         nx3026), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_16 (.Q (
         U_analog_control_sft_desel_all_cells_16), .QB (\$dummy [372]), .D (
         U_analog_control_sft_desel_all_cells_15), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_15 (.Q (
         U_analog_control_sft_desel_all_cells_15), .QB (\$dummy [373]), .D (
         U_analog_control_sft_desel_all_cells_14), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_14 (.Q (
         U_analog_control_sft_desel_all_cells_14), .QB (\$dummy [374]), .D (
         U_analog_control_sft_desel_all_cells_13), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_13 (.Q (
         U_analog_control_sft_desel_all_cells_13), .QB (\$dummy [375]), .D (
         U_analog_control_sft_desel_all_cells_12), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_12 (.Q (
         U_analog_control_sft_desel_all_cells_12), .QB (\$dummy [376]), .D (
         U_analog_control_sft_desel_all_cells_11), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_11 (.Q (
         U_analog_control_sft_desel_all_cells_11), .QB (\$dummy [377]), .D (
         U_analog_control_sft_desel_all_cells_10), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_10 (.Q (
         U_analog_control_sft_desel_all_cells_10), .QB (\$dummy [378]), .D (
         U_analog_control_sft_desel_all_cells_9), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_9 (.Q (
         U_analog_control_sft_desel_all_cells_9), .QB (\$dummy [379]), .D (
         U_analog_control_sft_desel_all_cells_8), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_8 (.Q (
         U_analog_control_sft_desel_all_cells_8), .QB (\$dummy [380]), .D (
         U_analog_control_sft_desel_all_cells_7), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_7 (.Q (
         U_analog_control_sft_desel_all_cells_7), .QB (\$dummy [381]), .D (
         U_analog_control_sft_desel_all_cells_6), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_6 (.Q (
         U_analog_control_sft_desel_all_cells_6), .QB (\$dummy [382]), .D (
         U_analog_control_sft_desel_all_cells_5), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_5 (.Q (
         U_analog_control_sft_desel_all_cells_5), .QB (\$dummy [383]), .D (
         U_analog_control_sft_desel_all_cells_4), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_4 (.Q (
         U_analog_control_sft_desel_all_cells_4), .QB (\$dummy [384]), .D (
         U_analog_control_sft_desel_all_cells_3), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_3 (.Q (
         U_analog_control_sft_desel_all_cells_3), .QB (\$dummy [385]), .D (
         U_analog_control_sft_desel_all_cells_2), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_2 (.Q (
         U_analog_control_sft_desel_all_cells_2), .QB (\$dummy [386]), .D (
         U_analog_control_sft_desel_all_cells_1), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_1 (.Q (
         U_analog_control_sft_desel_all_cells_1), .QB (\$dummy [387]), .D (
         U_analog_control_sft_desel_all_cells_0), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    Nand2 ix2951 (.OUT (nx2950), .A (nx9518), .B (nx9540)) ;
    AOI22 ix9519 (.OUT (nx9518), .A (nx9520), .B (desel_all_cells), .C (nx2912)
          , .D (nx2940)) ;
    DFFC U_analog_control_reg_sft_desel_all_cells_0 (.Q (
         U_analog_control_sft_desel_all_cells_0), .QB (nx9520), .D (
         desel_all_cells), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2913 (.OUT (nx2912), .A (nx9523), .B (nx2902), .C (nx2904)) ;
    Nand3 ix9524 (.OUT (nx9523), .A (nx9525), .B (nx9290), .C (nx9219)) ;
    Nor3 ix2941 (.OUT (nx2940), .A (nx9530), .B (nx2930), .C (nx2932)) ;
    Nand3 ix9531 (.OUT (nx9530), .A (nx9532), .B (nx9534), .C (nx9536)) ;
    Nor3 ix9541 (.OUT (nx9540), .A (nx2884), .B (nx2880), .C (nx2428)) ;
    Nor3 ix2881 (.OUT (nx2880), .A (nx9494), .B (
         U_analog_control_sft_desel_all_cells_0), .C (nx9544)) ;
    DFFC U_analog_control_reg_int_desel_all_cells (.Q (desel_all_cells), .QB (
         nx9544), .D (nx2950), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor4 ix2429 (.OUT (nx2428), .A (nx9547), .B (nx9550), .C (nx2416), .D (
         nx2418)) ;
    Nand4 ix9548 (.OUT (nx9547), .A (nx9219), .B (nx9211), .C (nx9403), .D (
          nx2396)) ;
    Nor3 ix2397 (.OUT (nx2396), .A (nx2382), .B (nx2384), .C (nx2386)) ;
    Nand3 ix9551 (.OUT (nx9550), .A (nx9552), .B (nx9554), .C (nx9556)) ;
    Nor2 ix9578 (.OUT (nx9577), .A (nx2870), .B (sel_addr_reg)) ;
    Nor2 ix2871 (.OUT (nx2870), .A (nx7701), .B (nx7709)) ;
    AO22 ix5885 (.OUT (reg_sel0), .A (nx8841), .B (nx2872), .C (nx9581), .D (
         nx3782)) ;
    Nand2 ix5933 (.OUT (precharge_bus), .A (nx9584), .B (nx9602)) ;
    Nand3 ix5927 (.OUT (nx5926), .A (nx9587), .B (nx9591), .C (nx9597)) ;
    Nand3 ix9588 (.OUT (nx9587), .A (nx8940), .B (U_analog_control_mst_state_2)
          , .C (nx9589)) ;
    Nor2 ix9590 (.OUT (nx9589), .A (U_analog_control_mst_state_0), .B (
         U_analog_control_mst_state_1)) ;
    Nand3 ix9592 (.OUT (nx9591), .A (nx5908), .B (precharge_dig_bus), .C (nx9198
          )) ;
    Nand4 ix5909 (.OUT (nx5908), .A (nx9594), .B (nx9024), .C (nx9049), .D (
          U_readout_control_st_cnt_1)) ;
    Nor3 ix9595 (.OUT (nx9594), .A (nx8986_XX0_XREP85), .B (nx8988), .C (nx3650)
         ) ;
    DFFC U_readout_control_reg_int_pre_dig (.Q (precharge_dig_bus), .QB (nx9584)
         , .D (nx5926), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix9598 (.OUT (nx9597), .A (nx11990), .B (nx5894)) ;
    Nand2 ix5895 (.OUT (nx5894), .A (nx9600), .B (nx3384)) ;
    Nand2 ix9601 (.OUT (nx9600), .A (U_readout_control_typ_cnt_3), .B (nx3478)
          ) ;
    DFFC U_analog_control_reg_int_precharge_ana_bus (.Q (\$dummy [388]), .QB (
         nx9602), .D (nx2888), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_reg_int_sel_cell (.Q (sel_cell), .QB (\$dummy [389]), 
         .D (nx5864), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix5865 (.OUT (nx5864), .A (sel_cell), .B (nx2714), .C (
         U_analog_control_sft_desel_all_cells_12), .D (nx5858)) ;
    Nand2 ix5859 (.OUT (nx5858), .A (nx9494), .B (nx3185)) ;
    DFFC U_analog_control_reg_pwr_up_acq_dig (.Q (pwr_up_acq_dig), .QB (
         \$dummy [390]), .D (nx7359), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix7360 (.OUT (nx7359), .A (nx12093), .B (nx9616), .C (pwr_up_acq_dig), 
         .D (nx9786)) ;
    Nor4 ix9617 (.OUT (nx9616), .A (nx5052), .B (nx5038), .C (nx5022), .D (
         nx5008)) ;
    Nand4 ix5053 (.OUT (nx5052), .A (nx9619), .B (nx9624), .C (nx9633), .D (
          nx9642)) ;
    Nor2 ix4615 (.OUT (nx4614), .A (nx10825), .B (nx10921)) ;
    Nor3 ix4627 (.OUT (nx4626), .A (nx9628), .B (nx10921), .C (nx3266)) ;
    Nor2 ix9629 (.OUT (nx9628), .A (nx10825), .B (nx10821)) ;
    Nor2 ix4633 (.OUT (nx3266), .A (nx12095), .B (nx12097)) ;
    Xnor2 ix9634 (.out (nx9633), .A (nx10817), .B (tc6_data_2)) ;
    Nor3 ix4641 (.OUT (nx4640), .A (nx9637), .B (nx10921), .C (nx3267)) ;
    Nor2 ix9638 (.OUT (nx9637), .A (nx3266), .B (nx10817)) ;
    Nor3 ix4655 (.OUT (nx4654), .A (nx9646), .B (nx10921), .C (nx3268)) ;
    Nor2 ix9647 (.OUT (nx9646), .A (nx3267), .B (nx10813)) ;
    DFFC U_analog_control_mst_cnt_3 (.Q (\$dummy [391]), .QB (nx9649), .D (
         nx4654), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix5039 (.OUT (nx5038), .A (nx9654), .B (nx9665), .C (nx9676), .D (
          nx9687)) ;
    Xnor2 ix9655 (.out (nx9654), .A (nx10809), .B (tc6_data_4)) ;
    Nor3 ix4669 (.OUT (nx4668), .A (nx9658), .B (nx10921), .C (nx3269)) ;
    Nor2 ix9659 (.OUT (nx9658), .A (nx3268), .B (nx10809)) ;
    Nor3 ix4683 (.OUT (nx4682), .A (nx9669), .B (nx10921), .C (nx3271)) ;
    Nor2 ix9670 (.OUT (nx9669), .A (nx3269), .B (nx10805)) ;
    DFFC U_analog_control_mst_cnt_5 (.Q (\$dummy [392]), .QB (nx9672), .D (
         nx4682), .CLK (sysclk), .CLR (int_reset_l)) ;
    Xnor2 ix9677 (.out (nx9676), .A (nx10801), .B (tc6_data_6)) ;
    Nor3 ix4697 (.OUT (nx4696), .A (nx9680), .B (nx10921), .C (nx3272)) ;
    Nor2 ix9681 (.OUT (nx9680), .A (nx3271), .B (nx10801)) ;
    Nor3 ix4711 (.OUT (nx4710), .A (nx9691), .B (nx10921), .C (nx3273)) ;
    Nor2 ix9692 (.OUT (nx9691), .A (nx3272), .B (nx10797)) ;
    DFFC U_analog_control_mst_cnt_7 (.Q (\$dummy [393]), .QB (nx9694), .D (
         nx4710), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix5023 (.OUT (nx5022), .A (nx9699), .B (nx9710), .C (nx9721), .D (
          nx9732)) ;
    Xnor2 ix9700 (.out (nx9699), .A (nx10793), .B (tc6_data_8)) ;
    Nor3 ix4725 (.OUT (nx4724), .A (nx9703), .B (nx10923), .C (nx3274)) ;
    Nor2 ix9704 (.OUT (nx9703), .A (nx3273), .B (nx10793)) ;
    Nor3 ix4739 (.OUT (nx4738), .A (nx9714), .B (nx10923), .C (nx3275)) ;
    Nor2 ix9715 (.OUT (nx9714), .A (nx3274), .B (nx10789)) ;
    Nor2 ix4745 (.OUT (nx3275), .A (nx12099), .B (nx9719)) ;
    DFFC U_analog_control_mst_cnt_9 (.Q (\$dummy [394]), .QB (nx9717), .D (
         nx4738), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix9720 (.OUT (nx9719), .A (nx10793_XX0_XREP167), .B (nx3273)) ;
    Xnor2 ix9722 (.out (nx9721), .A (nx10785), .B (tc6_data_10)) ;
    Nor3 ix4753 (.OUT (nx4752), .A (nx9725), .B (nx10923), .C (nx3277)) ;
    Nor2 ix9726 (.OUT (nx9725), .A (nx3275), .B (nx10785)) ;
    Nor3 ix4767 (.OUT (nx4766), .A (nx9736), .B (nx10923), .C (nx3278)) ;
    Nor2 ix9737 (.OUT (nx9736), .A (nx3277), .B (nx10781)) ;
    DFFC U_analog_control_mst_cnt_11 (.Q (\$dummy [395]), .QB (nx9739), .D (
         nx4766), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix9742 (.OUT (nx9741), .A (nx10785), .B (nx3275)) ;
    Nand4 ix5009 (.OUT (nx5008), .A (nx9744), .B (nx9755), .C (nx9766), .D (
          nx9777)) ;
    Xnor2 ix9745 (.out (nx9744), .A (nx12103), .B (tc6_data_12)) ;
    Nor3 ix4781 (.OUT (nx4780), .A (nx9748), .B (nx10923), .C (nx3279)) ;
    Nor2 ix9749 (.OUT (nx9748), .A (nx3278), .B (nx12103)) ;
    DFFC U_analog_control_mst_cnt_13 (.Q (\$dummy [396]), .QB (nx9762), .D (
         nx4794), .CLK (sysclk), .CLR (int_reset_l)) ;
    Xnor2 ix9767 (.out (nx9766), .A (U_analog_control_mst_cnt_14), .B (
          tc6_data_14)) ;
    Xnor2 ix9778 (.out (nx9777), .A (nx12105), .B (tc6_data_15)) ;
    Nor3 ix9787 (.OUT (nx9786), .A (nx5150), .B (nx9616), .C (nx10923)) ;
    Nor4 ix5151 (.OUT (nx5150), .A (nx9789), .B (nx9799), .C (nx9809), .D (
         nx9819)) ;
    Nand4 ix9790 (.OUT (nx9789), .A (nx9791), .B (nx9793), .C (nx9795), .D (
          nx9797)) ;
    Xnor2 ix9792 (.out (nx9791), .A (nx12105), .B (tc6_data_31)) ;
    Xnor2 ix9794 (.out (nx9793), .A (U_analog_control_mst_cnt_14), .B (
          tc6_data_30)) ;
    Xnor2 ix9798 (.out (nx9797), .A (nx12103), .B (tc6_data_28)) ;
    Nand4 ix9800 (.OUT (nx9799), .A (nx9801), .B (nx9803), .C (nx9805), .D (
          nx9807)) ;
    Xnor2 ix9804 (.out (nx9803), .A (nx10785), .B (tc6_data_26)) ;
    Xnor2 ix9808 (.out (nx9807), .A (nx10793), .B (tc6_data_24)) ;
    Nand4 ix9810 (.OUT (nx9809), .A (nx9811), .B (nx9813), .C (nx9815), .D (
          nx9817)) ;
    Xnor2 ix9814 (.out (nx9813), .A (nx10801), .B (tc6_data_22)) ;
    Xnor2 ix9818 (.out (nx9817), .A (nx10809), .B (tc6_data_20)) ;
    Nand4 ix9820 (.OUT (nx9819), .A (nx9821), .B (nx9823), .C (nx9825), .D (
          nx9827)) ;
    Xnor2 ix9824 (.out (nx9823), .A (nx10817), .B (tc6_data_18)) ;
    Nor2 ix4607 (.OUT (nx4606), .A (nx9832), .B (nx10144)) ;
    AOI22 ix9837 (.OUT (nx9836), .A (start_calibrate), .B (nx12107), .C (
          U_analog_control_cal_state_0), .D (nx10017)) ;
    DFFC U_command_control_reg_start_calibrate (.Q (start_calibrate), .QB (
         \$dummy [397]), .D (nx7339), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix7340 (.OUT (nx7339), .A (nx2812), .B (nx418), .C (start_calibrate), .D (
         nx9840)) ;
    Nor2 ix9841 (.OUT (nx9840), .A (nx418), .B (nx9842)) ;
    DFFC U_analog_control_reg_cal_state_1 (.Q (U_analog_control_cal_state_1), .QB (
         nx9845), .D (nx3241), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_cal_cnt_11 (.Q (U_analog_control_cal_cnt_11), .QB (
         nx9975), .D (nx7329), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7310 (.OUT (nx7309), .A (U_analog_control_cal_cnt_9), .B (nx4084), .SEL (
         nx9949)) ;
    DFFC reg_U_analog_control_cal_cnt_9 (.Q (U_analog_control_cal_cnt_9), .QB (
         nx9875), .D (nx7309), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4085 (.OUT (nx4084), .A (nx9880), .B (nx3265), .C (nx12109)) ;
    Nor2 ix9881 (.OUT (nx9880), .A (nx3263), .B (U_analog_control_cal_cnt_9)) ;
    Mux2 ix7300 (.OUT (nx7299), .A (U_analog_control_cal_cnt_8), .B (nx4068), .SEL (
         nx10925_XX0_XREP193)) ;
    DFFC reg_U_analog_control_cal_cnt_8 (.Q (U_analog_control_cal_cnt_8), .QB (
         \$dummy [398]), .D (nx7299), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4069 (.OUT (nx4068), .A (nx9888), .B (nx3263), .C (nx12109)) ;
    Nor2 ix9889 (.OUT (nx9888), .A (nx3261), .B (U_analog_control_cal_cnt_8)) ;
    Nor2 ix4059 (.OUT (nx3261), .A (nx9891), .B (nx9964)) ;
    Mux2 ix7290 (.OUT (nx7289), .A (U_analog_control_cal_cnt_7), .B (nx4052), .SEL (
         nx10925_XX0_XREP193)) ;
    DFFC reg_U_analog_control_cal_cnt_7 (.Q (U_analog_control_cal_cnt_7), .QB (
         nx9891), .D (nx7289), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4053 (.OUT (nx4052), .A (nx9896), .B (nx3261), .C (nx12109)) ;
    Nor2 ix9897 (.OUT (nx9896), .A (nx3259), .B (U_analog_control_cal_cnt_7)) ;
    DFFC reg_U_analog_control_cal_cnt_6 (.Q (U_analog_control_cal_cnt_6), .QB (
         nx9899), .D (nx7279), .CLK (sysclk), .CLR (int_reset_l)) ;
    Mux2 ix7270 (.OUT (nx7269), .A (U_analog_control_cal_cnt_5), .B (nx4020), .SEL (
         nx10925_XX0_XREP193)) ;
    DFFC reg_U_analog_control_cal_cnt_5 (.Q (U_analog_control_cal_cnt_5), .QB (
         nx9907), .D (nx7269), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix4021 (.OUT (nx4020), .A (nx9912), .B (nx3257), .C (nx12109)) ;
    Nor2 ix9913 (.OUT (nx9912), .A (nx3256), .B (U_analog_control_cal_cnt_5)) ;
    DFFC reg_U_analog_control_cal_cnt_4 (.Q (U_analog_control_cal_cnt_4), .QB (
         \$dummy [399]), .D (nx7259), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix9921 (.OUT (nx9920), .A (nx3255), .B (U_analog_control_cal_cnt_4)) ;
    Mux2 ix7250 (.OUT (nx7249), .A (U_analog_control_cal_cnt_3), .B (nx3988), .SEL (
         nx10925_XX0_XREP397)) ;
    DFFC reg_U_analog_control_cal_cnt_3 (.Q (U_analog_control_cal_cnt_3), .QB (
         nx9923), .D (nx7249), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3989 (.OUT (nx3988), .A (nx9928), .B (nx3255), .C (nx12109)) ;
    Nor2 ix9929 (.OUT (nx9928), .A (nx3254), .B (U_analog_control_cal_cnt_3)) ;
    Mux2 ix7240 (.OUT (nx7239), .A (U_analog_control_cal_cnt_2), .B (nx3972), .SEL (
         nx10925)) ;
    DFFC reg_U_analog_control_cal_cnt_2 (.Q (U_analog_control_cal_cnt_2), .QB (
         \$dummy [400]), .D (nx7239), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3973 (.OUT (nx3972), .A (nx9936), .B (nx3254), .C (nx12109)) ;
    Nor2 ix9937 (.OUT (nx9936), .A (nx3253), .B (U_analog_control_cal_cnt_2)) ;
    DFFC reg_U_analog_control_cal_cnt_1 (.Q (U_analog_control_cal_cnt_1), .QB (
         nx9939), .D (nx7229), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_cal_cnt_0 (.Q (U_analog_control_cal_cnt_0), .QB (
         nx9955), .D (nx7219), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix9953 (.OUT (nx9952), .A (nx4478), .B (U_analog_control_cal_state_1)
         ) ;
    Nor2 ix4479 (.OUT (nx4478), .A (nx3182_XX0_XREP11), .B (nx3822)) ;
    Nand2 ix9965 (.OUT (nx9964), .A (U_analog_control_cal_cnt_6), .B (nx3257)) ;
    Nand2 ix9969 (.OUT (nx9968), .A (U_analog_control_cal_cnt_8), .B (nx3261)) ;
    DFFC reg_U_analog_control_cal_cnt_10 (.Q (U_analog_control_cal_cnt_10), .QB (
         nx9971), .D (nx7319), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_reg_cal_dly_11 (.Q (\$dummy [401]), .QB (nx9976), .D (
         nx3930), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3931 (.OUT (nx3930), .A (nx9979), .B (nx10020)) ;
    AOI22 ix9980 (.OUT (nx9979), .A (cd0_data_11), .B (nx10927), .C (cd1_data_27
          ), .D (nx10931)) ;
    Nor4 ix9982 (.OUT (nx9981), .A (nx9983), .B (
         U_analog_control_int_cal_pulse_1), .C (U_analog_control_int_cal_pulse_2
         ), .D (U_analog_control_int_cal_pulse_3)) ;
    Mux2 ix3843 (.OUT (nx3247), .A (nx12107), .B (
         U_analog_control_int_cal_pulse_0), .SEL (nx9987)) ;
    DFFC U_analog_control_reg_int_cal_pulse_0 (.Q (
         U_analog_control_int_cal_pulse_0), .QB (nx9983), .D (nx3247), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix9988 (.OUT (nx9987), .A (U_analog_control_cal_state_0__XX0_XREP179)
          , .B (nx9989)) ;
    DFFC U_analog_control_reg_int_cal_pulse_1 (.Q (
         U_analog_control_int_cal_pulse_1), .QB (nx10011), .D (nx3852), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3853 (.OUT (nx3852), .A (nx9997), .B (nx10009)) ;
    Nand2 ix9998 (.OUT (nx9997), .A (U_analog_control_int_cal_pulse_1), .B (
          nx3245)) ;
    Nand4 ix10010 (.OUT (nx10009), .A (U_analog_control_int_cal_pulse_0), .B (
          nx9987), .C (U_analog_control_cal_state_1), .D (
          U_analog_control_cal_state_0__XX0_XREP179)) ;
    DFFC U_analog_control_reg_int_cal_pulse_2 (.Q (
         U_analog_control_int_cal_pulse_2), .QB (nx10014), .D (nx3862), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3863 (.OUT (nx3862), .A (U_analog_control_int_cal_pulse_1), .B (
         nx3243), .C (U_analog_control_int_cal_pulse_2), .D (nx3245)) ;
    DFFC U_analog_control_reg_int_cal_pulse_3 (.Q (
         U_analog_control_int_cal_pulse_3), .QB (nx10017), .D (nx3872), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    AO22 ix3873 (.OUT (nx3872), .A (U_analog_control_int_cal_pulse_2), .B (
         nx3243), .C (U_analog_control_int_cal_pulse_3), .D (nx3245)) ;
    Nor4 ix10019 (.OUT (nx10018), .A (U_analog_control_int_cal_pulse_0), .B (
         U_analog_control_int_cal_pulse_1), .C (U_analog_control_int_cal_pulse_2
         ), .D (nx10017)) ;
    AOI22 ix10021 (.OUT (nx10020), .A (cd1_data_11), .B (nx10935), .C (
          cd0_data_27), .D (nx10939)) ;
    Nor4 ix10023 (.OUT (nx10022), .A (U_analog_control_int_cal_pulse_0), .B (
         U_analog_control_int_cal_pulse_1), .C (nx10014), .D (
         U_analog_control_int_cal_pulse_3)) ;
    Nor4 ix10025 (.OUT (nx10024), .A (U_analog_control_int_cal_pulse_0), .B (
         nx10011), .C (U_analog_control_int_cal_pulse_2), .D (
         U_analog_control_int_cal_pulse_3)) ;
    DFFC U_analog_control_reg_cal_dly_10 (.Q (\$dummy [402]), .QB (nx10027), .D (
         nx4128), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4129 (.OUT (nx4128), .A (nx10030), .B (nx10032)) ;
    AOI22 ix10031 (.OUT (nx10030), .A (cd0_data_10), .B (nx10927), .C (
          cd1_data_26), .D (nx10931)) ;
    AOI22 ix10033 (.OUT (nx10032), .A (cd1_data_10), .B (nx10935), .C (
          cd0_data_26), .D (nx10939)) ;
    DFFC U_analog_control_reg_cal_dly_7 (.Q (U_analog_control_cal_dly_7), .QB (
         \$dummy [403]), .D (nx4164), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4165 (.OUT (nx4164), .A (nx10038), .B (nx10040)) ;
    AOI22 ix10039 (.OUT (nx10038), .A (cd0_data_7), .B (nx10927), .C (
          cd1_data_23), .D (nx10931)) ;
    AOI22 ix10041 (.OUT (nx10040), .A (cd1_data_7), .B (nx10935), .C (
          cd0_data_23), .D (nx10939)) ;
    DFFC U_analog_control_reg_cal_dly_9 (.Q (U_analog_control_cal_dly_9), .QB (
         \$dummy [404]), .D (nx4192), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4193 (.OUT (nx4192), .A (nx10048), .B (nx10050)) ;
    AOI22 ix10049 (.OUT (nx10048), .A (cd0_data_9), .B (nx10927), .C (
          cd1_data_25), .D (nx10931)) ;
    AOI22 ix10051 (.OUT (nx10050), .A (cd1_data_9), .B (nx10935), .C (
          cd0_data_25), .D (nx10939)) ;
    DFFC U_analog_control_reg_cal_dly_8 (.Q (U_analog_control_cal_dly_8), .QB (
         \$dummy [405]), .D (nx4220), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4221 (.OUT (nx4220), .A (nx10056), .B (nx10058)) ;
    AOI22 ix10057 (.OUT (nx10056), .A (cd0_data_8), .B (nx10927), .C (
          cd1_data_24), .D (nx10931)) ;
    AOI22 ix10059 (.OUT (nx10058), .A (cd1_data_8), .B (nx10935), .C (
          cd0_data_24), .D (nx10939)) ;
    DFFC U_analog_control_reg_cal_dly_6 (.Q (U_analog_control_cal_dly_6), .QB (
         \$dummy [406]), .D (nx4260), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4261 (.OUT (nx4260), .A (nx10067), .B (nx10069)) ;
    AOI22 ix10068 (.OUT (nx10067), .A (cd0_data_6), .B (nx10927), .C (
          cd1_data_22), .D (nx10931)) ;
    AOI22 ix10070 (.OUT (nx10069), .A (cd1_data_6), .B (nx10935), .C (
          cd0_data_22), .D (nx10939)) ;
    DFFC U_analog_control_reg_cal_dly_5 (.Q (U_analog_control_cal_dly_5), .QB (
         \$dummy [407]), .D (nx4288), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4289 (.OUT (nx4288), .A (nx10076), .B (nx10078)) ;
    AOI22 ix10077 (.OUT (nx10076), .A (cd0_data_5), .B (nx10927), .C (
          cd1_data_21), .D (nx10931)) ;
    AOI22 ix10079 (.OUT (nx10078), .A (cd1_data_5), .B (nx10935), .C (
          cd0_data_21), .D (nx10939)) ;
    Xnor2 ix10082 (.out (nx10081), .A (U_analog_control_cal_cnt_4), .B (
          U_analog_control_cal_dly_4)) ;
    DFFC U_analog_control_reg_cal_dly_4 (.Q (U_analog_control_cal_dly_4), .QB (
         \$dummy [408]), .D (nx4322), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4323 (.OUT (nx4322), .A (nx10085), .B (nx10087)) ;
    AOI22 ix10086 (.OUT (nx10085), .A (cd0_data_4), .B (nx10927), .C (
          cd1_data_20), .D (nx10931)) ;
    AOI22 ix10088 (.OUT (nx10087), .A (cd1_data_4), .B (nx10935), .C (
          cd0_data_20), .D (nx10939)) ;
    DFFC U_analog_control_reg_cal_dly_3 (.Q (U_analog_control_cal_dly_3), .QB (
         \$dummy [409]), .D (nx4350), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4351 (.OUT (nx4350), .A (nx10094), .B (nx10096)) ;
    AOI22 ix10095 (.OUT (nx10094), .A (cd0_data_3), .B (nx10927), .C (
          cd1_data_19), .D (nx10931)) ;
    AOI22 ix10097 (.OUT (nx10096), .A (cd1_data_3), .B (nx10935), .C (
          cd0_data_19), .D (nx10939)) ;
    DFFC U_analog_control_reg_cal_dly_0 (.Q (U_analog_control_cal_dly_0), .QB (
         \$dummy [410]), .D (nx4386), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4387 (.OUT (nx4386), .A (nx10103), .B (nx10105)) ;
    AOI22 ix10104 (.OUT (nx10103), .A (cd0_data_0), .B (nx10929), .C (
          cd1_data_16), .D (nx10933)) ;
    AOI22 ix10106 (.OUT (nx10105), .A (cd1_data_0), .B (nx10937), .C (
          cd0_data_16), .D (nx10941)) ;
    DFFC U_analog_control_reg_cal_dly_2 (.Q (U_analog_control_cal_dly_2), .QB (
         \$dummy [411]), .D (nx4414), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4415 (.OUT (nx4414), .A (nx10111), .B (nx10113)) ;
    AOI22 ix10112 (.OUT (nx10111), .A (cd0_data_2), .B (nx10929), .C (
          cd1_data_18), .D (nx10933)) ;
    AOI22 ix10114 (.OUT (nx10113), .A (cd1_data_2), .B (nx10937), .C (
          cd0_data_18), .D (nx10941)) ;
    DFFC U_analog_control_reg_cal_dly_1 (.Q (U_analog_control_cal_dly_1), .QB (
         \$dummy [412]), .D (nx4442), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4443 (.OUT (nx4442), .A (nx10119), .B (nx10121)) ;
    AOI22 ix10120 (.OUT (nx10119), .A (cd0_data_1), .B (nx10929), .C (
          cd1_data_17), .D (nx10933)) ;
    AOI22 ix10122 (.OUT (nx10121), .A (cd1_data_1), .B (nx10937), .C (
          cd0_data_17), .D (nx10941)) ;
    Xnor2 ix10141 (.out (nx10140), .A (U_analog_control_cal_cnt_2), .B (
          U_analog_control_cal_dly_2)) ;
    DFFC U_analog_control_reg_cal_en (.Q (\$dummy [413]), .QB (nx10146), .D (
         nx4596), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4597 (.OUT (nx4596), .A (nx10149), .B (nx10151)) ;
    AOI22 ix10150 (.OUT (nx10149), .A (cd0_data_12), .B (nx10929), .C (
          cd1_data_28), .D (nx10933)) ;
    AOI22 ix10152 (.OUT (nx10151), .A (cd1_data_12), .B (nx10937), .C (
          cd0_data_28), .D (nx10941)) ;
    DFFC U_analog_control_reg_int_cal_strobe (.Q (cal_strobe), .QB (nx10153), .D (
         nx4606), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFP U_analog_control_reg_trig_inh (.Q (trig_inh), .QB (\$dummy [414]), .D (
         nx7399), .CLK (sysclk), .PRB (int_reset_l)) ;
    Xnor2 ix10166 (.out (nx10165), .A (U_analog_control_mst_cnt_2), .B (
          tc4_data_2)) ;
    Xnor2 ix10171 (.out (nx10170), .A (nx10809_XX0_XREP163), .B (tc4_data_4)) ;
    Xnor2 ix10175 (.out (nx10174), .A (nx10801_XX0_XREP165), .B (tc4_data_6)) ;
    Xnor2 ix10180 (.out (nx10179), .A (nx10793_XX0_XREP167), .B (tc4_data_8)) ;
    Xnor2 ix10184 (.out (nx10183), .A (nx10785_XX0_XREP169), .B (tc4_data_10)) ;
    Xnor2 ix10189 (.out (nx10188), .A (nx10777_XX0_XREP171), .B (tc4_data_12)) ;
    Xnor2 ix10195 (.out (nx10194), .A (nx10765_XX0_XREP175), .B (tc4_data_15)) ;
    Xnor2 ix10202 (.out (nx10201), .A (nx10765_XX0_XREP175), .B (tc4_data_31)) ;
    Xnor2 ix10204 (.out (nx10203), .A (nx10769_XX0_XREP173), .B (tc4_data_30)) ;
    Xnor2 ix10208 (.out (nx10207), .A (nx10777_XX0_XREP171), .B (tc4_data_28)) ;
    Xnor2 ix10214 (.out (nx10213), .A (nx10785_XX0_XREP169), .B (tc4_data_26)) ;
    Xnor2 ix10218 (.out (nx10217), .A (nx10793), .B (tc4_data_24)) ;
    Xnor2 ix10224 (.out (nx10223), .A (U_analog_control_mst_cnt_6), .B (
          tc4_data_22)) ;
    Xnor2 ix10228 (.out (nx10227), .A (U_analog_control_mst_cnt_4), .B (
          tc4_data_20)) ;
    Xnor2 ix10234 (.out (nx10233), .A (nx10817), .B (tc4_data_18)) ;
    DFFP U_analog_control_reg_thresh_off (.Q (thresh_off), .QB (\$dummy [415]), 
         .D (nx7389), .CLK (sysclk), .PRB (int_reset_l)) ;
    Xnor2 ix10251 (.out (nx10250), .A (nx10817_XX0_XREP161), .B (tc3_data_2)) ;
    Xnor2 ix10256 (.out (nx10255), .A (nx10809), .B (tc3_data_4)) ;
    Xnor2 ix10260 (.out (nx10259), .A (nx10801), .B (tc3_data_6)) ;
    Xnor2 ix10265 (.out (nx10264), .A (nx10793_XX0_XREP167), .B (tc3_data_8)) ;
    Xnor2 ix10269 (.out (nx10268), .A (nx10785_XX0_XREP169), .B (tc3_data_10)) ;
    Xnor2 ix10274 (.out (nx10273), .A (nx10777_XX0_XREP171), .B (tc3_data_12)) ;
    Xnor2 ix10287 (.out (nx10286), .A (nx10765_XX0_XREP175), .B (tc3_data_31)) ;
    Xnor2 ix10289 (.out (nx10288), .A (nx10769_XX0_XREP173), .B (tc3_data_30)) ;
    Xnor2 ix10293 (.out (nx10292), .A (nx10777_XX0_XREP171), .B (tc3_data_28)) ;
    Xnor2 ix10299 (.out (nx10298), .A (nx10785), .B (tc3_data_26)) ;
    Xnor2 ix10303 (.out (nx10302), .A (nx10793), .B (tc3_data_24)) ;
    Xnor2 ix10309 (.out (nx10308), .A (nx10801_XX0_XREP165), .B (tc3_data_22)) ;
    Xnor2 ix10313 (.out (nx10312), .A (nx10809_XX0_XREP163), .B (tc3_data_20)) ;
    Xnor2 ix10319 (.out (nx10318), .A (nx10817), .B (tc3_data_18)) ;
    DFFP U_analog_control_reg_offset_null (.Q (offset_null), .QB (\$dummy [416])
         , .D (nx7379), .CLK (sysclk), .PRB (int_reset_l)) ;
    Nor4 ix10329 (.OUT (nx10328), .A (nx5396), .B (nx5382), .C (nx5366), .D (
         nx5352)) ;
    Nand4 ix5397 (.OUT (nx5396), .A (nx10331), .B (nx10333), .C (nx10335), .D (
          nx10337)) ;
    Xnor2 ix10336 (.out (nx10335), .A (nx10817_XX0_XREP161), .B (tc2_data_2)) ;
    Nand4 ix5383 (.OUT (nx5382), .A (nx10340), .B (nx10342), .C (nx10344), .D (
          nx10346)) ;
    Xnor2 ix10341 (.out (nx10340), .A (nx10809), .B (tc2_data_4)) ;
    Xnor2 ix10345 (.out (nx10344), .A (nx10801), .B (tc2_data_6)) ;
    Nand4 ix5367 (.OUT (nx5366), .A (nx10349), .B (nx10351), .C (nx10353), .D (
          nx10355)) ;
    Xnor2 ix10350 (.out (nx10349), .A (nx10793_XX0_XREP167), .B (tc2_data_8)) ;
    Xnor2 ix10354 (.out (nx10353), .A (nx10785_XX0_XREP169), .B (tc2_data_10)) ;
    Nand4 ix5353 (.OUT (nx5352), .A (nx10358), .B (nx10360), .C (nx10362), .D (
          nx10364)) ;
    Xnor2 ix10359 (.out (nx10358), .A (nx12103), .B (tc2_data_12)) ;
    Xnor2 ix10363 (.out (nx10362), .A (U_analog_control_mst_cnt_14), .B (
          tc2_data_14)) ;
    Xnor2 ix10365 (.out (nx10364), .A (nx12105), .B (tc2_data_15)) ;
    Nor4 ix5495 (.OUT (nx5494), .A (nx10369), .B (nx10379), .C (nx10389), .D (
         nx10399)) ;
    Nand4 ix10370 (.OUT (nx10369), .A (nx10371), .B (nx10373), .C (nx10375), .D (
          nx10377)) ;
    Xnor2 ix10372 (.out (nx10371), .A (nx10765_XX0_XREP175), .B (tc2_data_31)) ;
    Xnor2 ix10374 (.out (nx10373), .A (nx10771_XX0_XREP217), .B (tc2_data_30)) ;
    Xnor2 ix10378 (.out (nx10377), .A (nx10779_XX0_XREP219), .B (tc2_data_28)) ;
    Nand4 ix10380 (.OUT (nx10379), .A (nx10381), .B (nx10383), .C (nx10385), .D (
          nx10387)) ;
    Xnor2 ix10384 (.out (nx10383), .A (nx10787_XX0_XREP221), .B (tc2_data_26)) ;
    Xnor2 ix10388 (.out (nx10387), .A (nx10795_XX0_XREP223), .B (tc2_data_24)) ;
    Nand4 ix10390 (.OUT (nx10389), .A (nx10391), .B (nx10393), .C (nx10395), .D (
          nx10397)) ;
    Xnor2 ix10394 (.out (nx10393), .A (nx10803), .B (tc2_data_22)) ;
    Xnor2 ix10398 (.out (nx10397), .A (nx10811), .B (tc2_data_20)) ;
    Nand4 ix10400 (.OUT (nx10399), .A (nx10401), .B (nx10403), .C (nx10405), .D (
          nx10407)) ;
    Xnor2 ix10404 (.out (nx10403), .A (nx10819), .B (tc2_data_18)) ;
    DFFP U_analog_control_reg_leakage_null (.Q (leakage_null), .QB (
         \$dummy [417]), .D (nx7369), .CLK (sysclk), .PRB (int_reset_l)) ;
    Xnor2 ix10421 (.out (nx10420), .A (nx10819), .B (tc1_data_2)) ;
    Xnor2 ix10426 (.out (nx10425), .A (nx10811), .B (tc1_data_4)) ;
    Xnor2 ix10430 (.out (nx10429), .A (nx10803), .B (tc1_data_6)) ;
    Xnor2 ix10435 (.out (nx10434), .A (nx10795_XX0_XREP223), .B (tc1_data_8)) ;
    Xnor2 ix10439 (.out (nx10438), .A (nx10787_XX0_XREP221), .B (tc1_data_10)) ;
    Xnor2 ix10444 (.out (nx10443), .A (nx10779_XX0_XREP219), .B (tc1_data_12)) ;
    Xnor2 ix10448 (.out (nx10447), .A (nx10771_XX0_XREP217), .B (tc1_data_14)) ;
    Xnor2 ix10450 (.out (nx10449), .A (nx10767_XX0_XREP231), .B (tc1_data_15)) ;
    Xnor2 ix10457 (.out (nx10456), .A (nx10767_XX0_XREP231), .B (tc1_data_31)) ;
    Xnor2 ix10459 (.out (nx10458), .A (nx10771_XX0_XREP217), .B (tc1_data_30)) ;
    Xnor2 ix10463 (.out (nx10462), .A (nx10779_XX0_XREP219), .B (tc1_data_28)) ;
    Xnor2 ix10469 (.out (nx10468), .A (nx10787_XX0_XREP221), .B (tc1_data_26)) ;
    Xnor2 ix10473 (.out (nx10472), .A (nx10795_XX0_XREP223), .B (tc1_data_24)) ;
    Xnor2 ix10479 (.out (nx10478), .A (nx10803), .B (tc1_data_22)) ;
    Xnor2 ix10483 (.out (nx10482), .A (nx10811), .B (tc1_data_20)) ;
    Xnor2 ix10489 (.out (nx10488), .A (nx10819), .B (tc1_data_18)) ;
    Nand2 ix6307 (.OUT (reset_load), .A (nx10496), .B (nx10506)) ;
    Nand2 ix6301 (.OUT (nx6300), .A (nx10499), .B (nx3494)) ;
    Nand2 ix10500 (.OUT (nx10499), .A (nx9198), .B (nx6292)) ;
    Mux2 ix6293 (.OUT (nx6292), .A (nx8567), .B (load_shift_reg), .SEL (nx10503)
         ) ;
    DFFC U_readout_control_reg_int_load_shift (.Q (load_shift_reg), .QB (nx10496
         ), .D (nx6300), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix10504 (.OUT (nx10503), .A (nx3168), .B (nx8999), .C (nx6276)) ;
    Nand3 ix6277 (.OUT (nx6276), .A (nx9006), .B (nx9040), .C (
          U_readout_control_st_cnt_5)) ;
    AO22 ix7420 (.OUT (nx7419), .A (nx12093), .B (nx10509), .C (analog_reset), .D (
         nx10548)) ;
    Nor4 ix10510 (.OUT (nx10509), .A (nx6156), .B (nx6142), .C (nx6126), .D (
         nx6112)) ;
    Nand4 ix6157 (.OUT (nx6156), .A (nx10512), .B (nx10514), .C (nx10516), .D (
          nx10518)) ;
    Xnor2 ix10517 (.out (nx10516), .A (nx10819), .B (tc0_data_2)) ;
    Nand4 ix6143 (.OUT (nx6142), .A (nx10521), .B (nx10523), .C (nx10525), .D (
          nx10527)) ;
    Xnor2 ix10522 (.out (nx10521), .A (nx10811), .B (tc0_data_4)) ;
    Xnor2 ix10526 (.out (nx10525), .A (nx10803), .B (tc0_data_6)) ;
    Nand4 ix6127 (.OUT (nx6126), .A (nx10530), .B (nx10532), .C (nx10534), .D (
          nx10536)) ;
    Xnor2 ix10531 (.out (nx10530), .A (nx10795), .B (tc0_data_8)) ;
    Xnor2 ix10535 (.out (nx10534), .A (nx10787), .B (tc0_data_10)) ;
    Nand4 ix6113 (.OUT (nx6112), .A (nx10539), .B (nx10541), .C (nx10543), .D (
          nx10545)) ;
    Xnor2 ix10540 (.out (nx10539), .A (nx10779), .B (tc0_data_12)) ;
    Xnor2 ix10544 (.out (nx10543), .A (nx10771), .B (tc0_data_14)) ;
    Xnor2 ix10546 (.out (nx10545), .A (nx10767), .B (tc0_data_15)) ;
    DFFC U_analog_control_reg_analog_reset (.Q (analog_reset), .QB (nx10506), .D (
         nx7419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix10549 (.OUT (nx10548), .A (nx6254), .B (nx10509), .C (nx9283)) ;
    Nor4 ix6255 (.OUT (nx6254), .A (nx10551), .B (nx10561), .C (nx10571), .D (
         nx10581)) ;
    Nand4 ix10552 (.OUT (nx10551), .A (nx10553), .B (nx10555), .C (nx10557), .D (
          nx10559)) ;
    Xnor2 ix10554 (.out (nx10553), .A (nx10767_XX0_XREP231), .B (tc0_data_31)) ;
    Xnor2 ix10556 (.out (nx10555), .A (nx10771), .B (tc0_data_30)) ;
    Xnor2 ix10560 (.out (nx10559), .A (nx10779), .B (tc0_data_28)) ;
    Nand4 ix10562 (.OUT (nx10561), .A (nx10563), .B (nx10565), .C (nx10567), .D (
          nx10569)) ;
    Xnor2 ix10566 (.out (nx10565), .A (nx10787), .B (tc0_data_26)) ;
    Xnor2 ix10570 (.out (nx10569), .A (nx10795), .B (tc0_data_24)) ;
    Nand4 ix10572 (.OUT (nx10571), .A (nx10573), .B (nx10575), .C (nx10577), .D (
          nx10579)) ;
    Xnor2 ix10576 (.out (nx10575), .A (nx10803), .B (tc0_data_22)) ;
    Xnor2 ix10580 (.out (nx10579), .A (nx10811), .B (tc0_data_20)) ;
    Nand4 ix10582 (.OUT (nx10581), .A (nx10583), .B (nx10585), .C (nx10587), .D (
          nx10589)) ;
    Xnor2 ix10586 (.out (nx10585), .A (nx10819), .B (tc0_data_18)) ;
    DFFC U_analog_control_reg_pwr_up_acq (.Q (pwr_up_acq), .QB (\$dummy [418]), 
         .D (nx7349), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix7350 (.OUT (nx7349), .A (nx12093), .B (nx10593), .C (pwr_up_acq), .D (
         nx10631)) ;
    Nor4 ix10594 (.OUT (nx10593), .A (nx4880), .B (nx4866), .C (nx4850), .D (
         nx4836)) ;
    Nand4 ix4881 (.OUT (nx4880), .A (nx10596), .B (nx10598), .C (nx10600), .D (
          nx10602)) ;
    Xnor2 ix10601 (.out (nx10600), .A (nx10819), .B (tc5_data_2)) ;
    Nand4 ix4867 (.OUT (nx4866), .A (nx10605), .B (nx10607), .C (nx10609), .D (
          nx10611)) ;
    Xnor2 ix10606 (.out (nx10605), .A (nx10811), .B (tc5_data_4)) ;
    Xnor2 ix10610 (.out (nx10609), .A (nx10803), .B (tc5_data_6)) ;
    Nand4 ix4851 (.OUT (nx4850), .A (nx10614), .B (nx10616), .C (nx10618), .D (
          nx10620)) ;
    Xnor2 ix10615 (.out (nx10614), .A (nx10795), .B (tc5_data_8)) ;
    Xnor2 ix10619 (.out (nx10618), .A (nx10787), .B (tc5_data_10)) ;
    Nand4 ix4837 (.OUT (nx4836), .A (nx10623), .B (nx10625), .C (nx10627), .D (
          nx10629)) ;
    Xnor2 ix10624 (.out (nx10623), .A (nx10779), .B (tc5_data_12)) ;
    Xnor2 ix10628 (.out (nx10627), .A (nx10771), .B (tc5_data_14)) ;
    Xnor2 ix10630 (.out (nx10629), .A (nx10767), .B (tc5_data_15)) ;
    Nor3 ix10632 (.OUT (nx10631), .A (nx4978), .B (nx10593), .C (nx9283)) ;
    Nor4 ix4979 (.OUT (nx4978), .A (nx10634), .B (nx10644), .C (nx10654), .D (
         nx10664)) ;
    Nand4 ix10635 (.OUT (nx10634), .A (nx10636), .B (nx10638), .C (nx10640), .D (
          nx10642)) ;
    Xnor2 ix10637 (.out (nx10636), .A (nx10767), .B (tc5_data_31)) ;
    Xnor2 ix10639 (.out (nx10638), .A (nx10771), .B (tc5_data_30)) ;
    Xnor2 ix10643 (.out (nx10642), .A (nx10779), .B (tc5_data_28)) ;
    Nand4 ix10645 (.OUT (nx10644), .A (nx10646), .B (nx10648), .C (nx10650), .D (
          nx10652)) ;
    Xnor2 ix10649 (.out (nx10648), .A (nx10787), .B (tc5_data_26)) ;
    Xnor2 ix10653 (.out (nx10652), .A (nx10795), .B (tc5_data_24)) ;
    Nand4 ix10655 (.OUT (nx10654), .A (nx10656), .B (nx10658), .C (nx10660), .D (
          nx10662)) ;
    Xnor2 ix10659 (.out (nx10658), .A (nx10803), .B (tc5_data_22)) ;
    Xnor2 ix10663 (.out (nx10662), .A (nx10811), .B (tc5_data_20)) ;
    Nand4 ix10665 (.OUT (nx10664), .A (nx10666), .B (nx10668), .C (nx10670), .D (
          nx10672)) ;
    Xnor2 ix10669 (.out (nx10668), .A (nx10819), .B (tc5_data_18)) ;
    Mux2 ix3809 (.OUT (reg_clock), .A (nx3788), .B (bunch_clock), .SEL (nx2874)
         ) ;
    Nor2 ix3789 (.OUT (nx3788), .A (sysclk), .B (nx10677)) ;
    Nor2 ix10678 (.OUT (nx10677), .A (nx3782), .B (nx3036)) ;
    DFFC U_analog_control_reg_int_bunch_clock (.Q (bunch_clock), .QB (
         \$dummy [419]), .D (nx3798), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3799 (.OUT (nx3798), .A (nx3182), .B (nx9258), .C (
         U_analog_control_sub_cnt_0)) ;
    Nand2 ix2875 (.OUT (nx2874), .A (nx9577), .B (nx9441)) ;
    DFF reg_out_reset_l (.Q (out_reset_l), .QB (\$dummy [420]), .D (nx6092), .CLK (
        sysclk)) ;
    Nor2 ix6093 (.OUT (nx6092), .A (reset), .B (cmd_reset)) ;
    DFFC U_command_control_reg_cmd_reset (.Q (cmd_reset), .QB (\$dummy [421]), .D (
         nx7409), .CLK (sysclk), .CLR (int_reset_l)) ;
    AO22 ix7410 (.OUT (nx7409), .A (nx2812), .B (nx7917), .C (cmd_reset), .D (
         nx10687)) ;
    Nor2 ix10688 (.OUT (nx10687), .A (nx7917), .B (nx9842)) ;
    DFFC reg_data_out (.Q (data_out), .QB (\$dummy [422]), .D (nx6072), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand2 ix6073 (.OUT (nx6072), .A (nx10693), .B (nx10736)) ;
    DFFC U_readout_control_reg_sample_data_out (.Q (\$dummy [423]), .QB (nx10693
         ), .D (nx6066), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix6067 (.OUT (nx6066), .A (nx10696), .B (nx9203), .C (nx10699)) ;
    Nand2 ix10697 (.OUT (nx10696), .A (int_rdback), .B (nx12076)) ;
    AOI22 ix10700 (.OUT (nx10699), .A (U_readout_control_int_par), .B (nx6056), 
          .C (nx6024), .D (nx6028)) ;
    DFFC U_readout_control_reg_int_par (.Q (U_readout_control_int_par), .QB (
         nx10704), .D (nx6044), .CLK (sysclk), .CLR (int_reset_l)) ;
    AOI22 ix10711 (.OUT (nx10710), .A (U_readout_control_typ_cnt_2), .B (nx3048)
          , .C (U_readout_control_row_cnt_4), .D (nx9057)) ;
    Nand3 ix10713 (.OUT (nx10712), .A (U_readout_control_st_cnt_0__XX0_XREP85), 
          .B (U_readout_control_typ_cnt_0), .C (nx8994)) ;
    Nand3 ix10715 (.OUT (nx10714), .A (nx8986_XX0_XREP85), .B (
          U_readout_control_typ_cnt_1), .C (U_readout_control_st_cnt_1)) ;
    Nand3 ix10720 (.OUT (nx10719), .A (nx6000), .B (
          U_readout_control_st_cnt_3__XX0_XREP79), .C (nx10722)) ;
    Nor2 ix10723 (.OUT (nx10722), .A (nx8986_XX0_XREP85), .B (nx8988_XX0_XREP83)
         ) ;
    Nand2 ix5985 (.OUT (nx5984), .A (U_readout_control_st_cnt_3__XX0_XREP79), .B (
          nx9117)) ;
    Nand2 ix6057 (.OUT (nx6056), .A (nx10731), .B (nx10733)) ;
    Nand2 ix10732 (.OUT (nx10731), .A (nx8862), .B (nx9486)) ;
    Nor2 ix6029 (.OUT (nx6028), .A (nx3664), .B (nx9486)) ;
    DFFC U_command_control_reg_resp_data_out (.Q (\$dummy [424]), .QB (nx10736)
         , .D (nx2174), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix2175 (.OUT (nx2174), .A (nx7617)) ;
    Inv ix4759 (.OUT (nx3277), .A (nx9741)) ;
    Inv ix4731 (.OUT (nx3274), .A (nx9719)) ;
    Inv ix4703 (.OUT (nx3272), .A (nx9696)) ;
    Inv ix4675 (.OUT (nx3269), .A (nx9674)) ;
    Inv ix4647 (.OUT (nx3267), .A (nx9651)) ;
    Inv ix4075 (.OUT (nx3263), .A (nx9968)) ;
    Inv ix4043 (.OUT (nx3259), .A (nx9964)) ;
    Inv ix4011 (.OUT (nx3256), .A (nx9960)) ;
    Inv ix3979 (.OUT (nx3254), .A (nx9956)) ;
    Inv ix4543 (.OUT (nx3245), .A (nx9987)) ;
    Inv ix4539 (.OUT (nx3243), .A (nx9989)) ;
    Inv ix9487 (.OUT (nx9486), .A (nx3240)) ;
    Inv ix8863 (.OUT (nx8862), .A (nx3664)) ;
    Inv ix9206 (.OUT (nx9205), .A (nx3654)) ;
    Inv ix9060 (.OUT (nx9059), .A (nx3650)) ;
    Inv ix3593 (.OUT (nx3238), .A (nx9179)) ;
    Inv ix10734 (.OUT (nx10733), .A (nx3542)) ;
    Inv ix8913 (.OUT (nx8912), .A (nx3482)) ;
    Inv ix8915 (.OUT (nx8914), .A (nx3478)) ;
    Inv ix3451 (.OUT (nx3235), .A (nx9123)) ;
    Inv ix9199 (.OUT (nx9198), .A (nx3233)) ;
    Inv ix3389 (.OUT (nx3388), .A (nx8944_XX0_XREP531)) ;
    Inv ix3331 (.OUT (nx3330), .A (nx8883)) ;
    Inv ix9099 (.OUT (nx9098), .A (nx3230)) ;
    Inv ix9084 (.OUT (nx9083), .A (nx3204)) ;
    Inv ix3173 (.OUT (nx3172), .A (nx9057)) ;
    Inv ix3129 (.OUT (nx3226), .A (nx9047)) ;
    Inv ix3097 (.OUT (nx3225), .A (nx9034)) ;
    Inv ix3065 (.OUT (nx3223), .A (nx9030)) ;
    Inv ix9000 (.OUT (nx8999), .A (nx3048)) ;
    Inv ix9582 (.OUT (nx9581), .A (nx3036)) ;
    Inv ix2889 (.OUT (nx2888), .A (nx9540)) ;
    Inv ix2873 (.OUT (nx2872), .A (nx9577)) ;
    Inv ix9843 (.OUT (nx9842), .A (nx2812)) ;
    Inv ix2715 (.OUT (nx2714), .A (nx9494)) ;
    Inv ix2671 (.OUT (nx3221), .A (nx9400)) ;
    Inv ix2639 (.OUT (nx3219), .A (nx9381)) ;
    Inv ix2607 (.OUT (nx3217), .A (nx9358)) ;
    Inv ix2575 (.OUT (nx3215), .A (nx9336)) ;
    Inv ix2543 (.OUT (nx3213), .A (nx9468)) ;
    Inv ix2511 (.OUT (nx3211), .A (nx9464)) ;
    Inv ix2479 (.OUT (nx3210), .A (nx9460)) ;
    Inv ix2431 (.OUT (nx2430), .A (nx9589)) ;
    Inv ix9215 (.OUT (nx9214), .A (nx2428)) ;
    Inv ix541 (.OUT (nx540), .A (nx7917)) ;
    Inv ix8658 (.OUT (nx8657), .A (nx424)) ;
    Inv ix359 (.OUT (nx358), .A (nx7509)) ;
    Inv ix285 (.OUT (nx284), .A (nx7501)) ;
    Inv ix8848 (.OUT (nx8847), .A (nx256)) ;
    Inv ix7526 (.OUT (nx7525), .A (nx210)) ;
    Inv ix197 (.OUT (nx196), .A (nx8806)) ;
    Inv ix171 (.OUT (nx3193), .A (nx7496)) ;
    Inv ix337 (.OUT (nx3191), .A (nx7517)) ;
    Inv ix153 (.OUT (nx152), .A (nx8809)) ;
    Inv ix149 (.OUT (nx148), .A (nx7606)) ;
    Inv ix7598 (.OUT (nx7597), .A (nx142)) ;
    Inv ix231 (.OUT (nx3189), .A (nx8800)) ;
    Inv ix271 (.OUT (nx3188), .A (nx7514)) ;
    Inv ix9291 (.OUT (nx9290), .A (nx3185)) ;
    Inv ix9444 (.OUT (nx9443), .A (nx44)) ;
    Inv ix9442 (.OUT (nx9441), .A (nx3182)) ;
    Inv ix9459 (.OUT (nx9458), .A (nx10)) ;
    Inv ix9409 (.OUT (nx9408), .A (nx3181)) ;
    Inv ix7697 (.OUT (nx7696), .A (reg_wr_ena)) ;
    Inv ix10746 (.OUT (nx10747), .A (nx7563)) ;
    Buf1 ix10748 (.OUT (nx10749), .A (nx902)) ;
    Buf1 ix10750 (.OUT (nx10751), .A (nx902)) ;
    Buf1 ix10752 (.OUT (nx10753), .A (nx902)) ;
    Buf1 ix10754 (.OUT (nx10755), .A (nx902)) ;
    Buf1 ix10756 (.OUT (nx10757), .A (nx2436)) ;
    Buf1 ix10758 (.OUT (nx10759), .A (nx2436)) ;
    Inv ix10780 (.OUT (nx10781), .A (nx9739)) ;
    Inv ix10788 (.OUT (nx10789), .A (nx9717)) ;
    Inv ix10796 (.OUT (nx10797), .A (nx9694)) ;
    Buf1 ix10802 (.OUT (nx10803), .A (U_analog_control_mst_cnt_6)) ;
    Inv ix10804 (.OUT (nx10805), .A (nx9672)) ;
    Buf1 ix10810 (.OUT (nx10811), .A (U_analog_control_mst_cnt_4)) ;
    Buf1 ix10818 (.OUT (nx10819), .A (U_analog_control_mst_cnt_2)) ;
    Inv ix10830 (.OUT (nx10831), .A (nx10953)) ;
    Inv ix10832 (.OUT (nx10833), .A (nx10953)) ;
    Inv ix10834 (.OUT (nx10835), .A (reg_wr_ena)) ;
    Buf1 ix10836 (.OUT (nx10837), .A (nx7698)) ;
    Buf1 ix10838 (.OUT (nx10839), .A (nx7698)) ;
    Buf1 ix10840 (.OUT (nx10841), .A (nx7703)) ;
    Buf1 ix10842 (.OUT (nx10843), .A (nx7703)) ;
    Buf1 ix10844 (.OUT (nx10845), .A (nx7703)) ;
    Buf1 ix10846 (.OUT (nx10847), .A (nx7703)) ;
    Buf1 ix10848 (.OUT (nx10849), .A (nx7811)) ;
    Buf1 ix10850 (.OUT (nx10851), .A (nx7811)) ;
    Buf1 ix10852 (.OUT (nx10853), .A (nx7811)) ;
    Buf1 ix10854 (.OUT (nx10855), .A (nx7811)) ;
    Buf1 ix10856 (.OUT (nx10857), .A (nx7915)) ;
    Buf1 ix10858 (.OUT (nx10859), .A (nx7915)) ;
    Buf1 ix10860 (.OUT (nx10861), .A (nx7915)) ;
    Buf1 ix10862 (.OUT (nx10863), .A (nx7915)) ;
    Buf1 ix10864 (.OUT (nx10865), .A (nx8018)) ;
    Buf1 ix10866 (.OUT (nx10867), .A (nx8018)) ;
    Buf1 ix10868 (.OUT (nx10869), .A (nx8018)) ;
    Buf1 ix10870 (.OUT (nx10871), .A (nx8018)) ;
    Buf1 ix10872 (.OUT (nx10873), .A (nx8126)) ;
    Buf1 ix10874 (.OUT (nx10875), .A (nx8126)) ;
    Buf1 ix10876 (.OUT (nx10877), .A (nx8126)) ;
    Buf1 ix10878 (.OUT (nx10879), .A (nx8126)) ;
    Buf1 ix10880 (.OUT (nx10881), .A (nx8228)) ;
    Buf1 ix10882 (.OUT (nx10883), .A (nx8228)) ;
    Buf1 ix10884 (.OUT (nx10885), .A (nx8228)) ;
    Buf1 ix10886 (.OUT (nx10887), .A (nx8228)) ;
    Buf1 ix10888 (.OUT (nx10889), .A (nx8331)) ;
    Buf1 ix10890 (.OUT (nx10891), .A (nx8331)) ;
    Buf1 ix10892 (.OUT (nx10893), .A (nx8331)) ;
    Buf1 ix10894 (.OUT (nx10895), .A (nx8331)) ;
    Buf1 ix10896 (.OUT (nx10897), .A (nx8432)) ;
    Buf1 ix10898 (.OUT (nx10899), .A (nx8432)) ;
    Buf1 ix10900 (.OUT (nx10901), .A (nx8432)) ;
    Buf1 ix10902 (.OUT (nx10903), .A (nx8432)) ;
    Buf1 ix10904 (.OUT (nx10905), .A (nx8653)) ;
    Buf1 ix10906 (.OUT (nx10907), .A (nx8653)) ;
    Buf1 ix10908 (.OUT (nx10909), .A (nx8653)) ;
    Buf1 ix10910 (.OUT (nx10911), .A (nx8653)) ;
    Buf1 ix10912 (.OUT (nx10913), .A (nx8758)) ;
    Buf1 ix10914 (.OUT (nx10915), .A (nx8758)) ;
    Buf1 ix10916 (.OUT (nx10917), .A (nx8758)) ;
    Buf1 ix10918 (.OUT (nx10919), .A (nx8758)) ;
    Inv ix10920 (.OUT (nx10921), .A (nx12093)) ;
    Buf1 ix10926 (.OUT (nx10927), .A (nx9981)) ;
    Buf1 ix10928 (.OUT (nx10929), .A (nx9981)) ;
    Buf1 ix10930 (.OUT (nx10931), .A (nx10018)) ;
    Buf1 ix10932 (.OUT (nx10933), .A (nx10018)) ;
    Buf1 ix10934 (.OUT (nx10935), .A (nx10022)) ;
    Buf1 ix10936 (.OUT (nx10937), .A (nx10022)) ;
    Buf1 ix10938 (.OUT (nx10939), .A (nx10024)) ;
    Buf1 ix10940 (.OUT (nx10941), .A (nx10024)) ;
    Xnor2 ix7494 (.out (nx7493), .A (nx7490), .B (nx7496)) ;
    Mux2 ix3320 (.OUT (nx3319), .A (
         U_command_control_int_hdr_data_12__XX0_XREP33), .B (
         U_command_control_int_hdr_data_11), .SEL (nx10953_XX0_XREP31)) ;
    Mux2 ix3310 (.OUT (nx3309), .A (U_command_control_int_hdr_data_13), .B (
         U_command_control_int_hdr_data_12__XX0_XREP33), .SEL (
         nx10953_XX0_XREP31)) ;
    Mux2 ix3300 (.OUT (nx3299), .A (U_command_control_int_hdr_data_14), .B (
         U_command_control_int_hdr_data_13), .SEL (nx10953_XX0_XREP31)) ;
    Mux2 ix3290 (.OUT (nx3289), .A (U_command_control_int_hdr_data_15), .B (
         U_command_control_int_hdr_data_14), .SEL (nx10953)) ;
    Mux2 ix3440 (.OUT (nx3439), .A (nx10745), .B (
         U_command_control_int_hdr_data_15), .SEL (nx10953)) ;
    Mux2 ix3430 (.OUT (nx3429), .A (U_command_control_int_hdr_data_17), .B (
         nx10745), .SEL (nx10953_XX0_XREP31)) ;
    Mux2 ix3420 (.OUT (nx3419), .A (U_command_control_int_hdr_data_18), .B (
         U_command_control_int_hdr_data_17), .SEL (nx10955_XX0_XREP41)) ;
    Mux2 ix3410 (.OUT (nx3409), .A (U_command_control_int_hdr_data_19), .B (
         U_command_control_int_hdr_data_18), .SEL (nx10955_XX0_XREP41)) ;
    Mux2 ix3400 (.OUT (nx3399), .A (U_command_control_int_hdr_data_20), .B (
         U_command_control_int_hdr_data_19), .SEL (nx10955_XX0_XREP41)) ;
    Mux2 ix3390 (.OUT (nx3389), .A (reg_data), .B (
         U_command_control_int_hdr_data_20), .SEL (nx10955_XX0_XREP41)) ;
    Mux2 ix3330 (.OUT (nx3329), .A (U_command_control_int_hdr_data_11), .B (
         U_command_control_int_hdr_data_10), .SEL (nx10955)) ;
    Mux2 ix3340 (.OUT (nx3339), .A (U_command_control_int_hdr_data_10), .B (
         U_command_control_int_hdr_data_9), .SEL (nx10955)) ;
    Mux2 ix3350 (.OUT (nx3349), .A (U_command_control_int_hdr_data_9), .B (
         U_command_control_int_hdr_data_8), .SEL (nx10955)) ;
    Mux2 ix3380 (.OUT (nx3379), .A (U_command_control_int_hdr_data_6), .B (
         U_command_control_int_hdr_data_5), .SEL (nx10955)) ;
    Mux2 ix3370 (.OUT (nx3369), .A (U_command_control_int_hdr_data_7), .B (
         U_command_control_int_hdr_data_6), .SEL (nx10955)) ;
    Mux2 ix3360 (.OUT (nx3359), .A (U_command_control_int_hdr_data_8), .B (
         U_command_control_int_hdr_data_7), .SEL (nx10957)) ;
    Mux2 ix1865 (.OUT (nx1864), .A (tc0_data_0), .B (tc1_data_0), .SEL (
         nx7565_XX0_XREP1)) ;
    Mux2 ix1041 (.OUT (nx1040), .A (nx890), .B (test_mode), .SEL (
         nx7565_XX0_XREP1)) ;
    Mux2 ix891 (.OUT (nx890), .A (U_command_control_head_perr), .B (
         U_command_control_data_perr), .SEL (nx7511_XX0_XREP27)) ;
    Mux2 ix849 (.OUT (nx848), .A (cd0_data_0), .B (cd1_data_0), .SEL (
         nx7565_XX0_XREP1)) ;
    Mux2 ix475 (.OUT (nx474), .A (U_command_control_int_hdr_data_13), .B (
         U_command_control_int_hdr_data_15__XX0_XREP3), .SEL (nx7478_XX0_XREP25)
         ) ;
    Xor2 ix9053 (.out (nx9052), .A (nx9049), .B (nx3132)) ;
    Xor2 ix9093 (.out (nx9092), .A (nx9076), .B (U_readout_control_int_evt_cnt_2
         )) ;
    Xor2 ix9103 (.out (nx9102), .A (nx9075), .B (U_readout_control_int_evt_cnt_1
         )) ;
    Xor2 ix9297 (.out (nx9296), .A (nx9413_XX0_XREP147), .B (tc7_data_8)) ;
    Xor2 ix9299 (.out (nx9298), .A (nx9264_XX0_XREP145), .B (tc7_data_9)) ;
    Xor2 ix9302 (.out (nx9301), .A (nx9258_XX0_XREP143), .B (tc7_data_10)) ;
    Xor2 ix9305 (.out (nx9304), .A (nx9252), .B (tc7_data_11)) ;
    Xor2 ix9309 (.out (nx9308), .A (nx9246), .B (tc7_data_12)) ;
    Xor2 ix9312 (.out (nx9311), .A (nx9240), .B (tc7_data_13)) ;
    Xor2 ix9315 (.out (nx9314), .A (nx9234), .B (tc7_data_14)) ;
    Xor2 ix9318 (.out (nx9317), .A (nx9228), .B (tc7_data_15)) ;
    Xor2 ix9322 (.out (nx9321), .A (nx9222), .B (tc7_data_16)) ;
    Xor2 ix9325 (.out (nx9324), .A (nx9334), .B (tc7_data_17)) ;
    Xor2 ix9339 (.out (nx9338), .A (nx9345), .B (tc7_data_18)) ;
    Xor2 ix9350 (.out (nx9349), .A (nx9356), .B (tc7_data_19)) ;
    Xor2 ix9362 (.out (nx9361), .A (nx9368), .B (tc7_data_20)) ;
    Xor2 ix9373 (.out (nx9372), .A (nx9379), .B (tc7_data_21)) ;
    Xor2 ix9384 (.out (nx9383), .A (nx9390), .B (tc7_data_22)) ;
    Xor2 ix9395 (.out (nx9394), .A (nx9402), .B (tc7_data_23)) ;
    Nor3 ix2693 (.OUT (nx9432), .A (U_analog_control_sub_cnt_6), .B (
         U_analog_control_sub_cnt_7), .C (U_analog_control_sub_cnt_5)) ;
    Nor4 ix2689 (.OUT (nx9434), .A (U_analog_control_sub_cnt_12), .B (nx9379), .C (
         U_analog_control_sub_cnt_14), .D (U_analog_control_sub_cnt_15)) ;
    Xnor2 ix2383 (.out (nx2382), .A (nx9240), .B (tc7_data_29)) ;
    Xnor2 ix2385 (.out (nx2384), .A (nx9228), .B (tc7_data_31)) ;
    Xnor2 ix2387 (.out (nx2386), .A (nx9234), .B (tc7_data_30)) ;
    Xnor2 ix9479 (.out (nx2416), .A (nx9264_XX0_XREP145), .B (tc7_data_25)) ;
    Xnor2 ix9481 (.out (nx2418), .A (nx9413_XX0_XREP147), .B (tc7_data_24)) ;
    Xor2 ix9526 (.out (nx9525), .A (nx9228), .B (tc7_data_7)) ;
    Xnor2 ix2903 (.out (nx2902), .A (nx9234), .B (tc7_data_6)) ;
    Xnor2 ix2905 (.out (nx2904), .A (nx9240), .B (tc7_data_5)) ;
    Xor2 ix9533 (.out (nx9532), .A (nx9258_XX0_XREP143), .B (tc7_data_2)) ;
    Xor2 ix9535 (.out (nx9534), .A (nx9246), .B (tc7_data_4)) ;
    Xor2 ix9537 (.out (nx9536), .A (nx9252), .B (tc7_data_3)) ;
    Xnor2 ix2931 (.out (nx2930), .A (nx9264_XX0_XREP145), .B (tc7_data_1)) ;
    Xnor2 ix2933 (.out (nx2932), .A (nx9413_XX0_XREP147), .B (tc7_data_0)) ;
    Xor2 ix9553 (.out (nx9552), .A (nx9258_XX0_XREP143), .B (tc7_data_26)) ;
    Xor2 ix9555 (.out (nx9554), .A (nx9246), .B (tc7_data_28)) ;
    Xor2 ix9557 (.out (nx9556), .A (nx9252), .B (tc7_data_27)) ;
    Nor2 ix9606 (.OUT (nx2884), .A (U_analog_control_int_cur_cell_3), .B (nx9458
         )) ;
    Xor2 ix9620 (.out (nx9619), .A (nx12097), .B (tc6_data_0)) ;
    Xor2 ix9625 (.out (nx9624), .A (nx12095), .B (tc6_data_1)) ;
    Xor2 ix9643 (.out (nx9642), .A (nx10967), .B (tc6_data_3)) ;
    Xor2 ix9666 (.out (nx9665), .A (nx12115), .B (tc6_data_5)) ;
    Xor2 ix9688 (.out (nx9687), .A (nx12113), .B (tc6_data_7)) ;
    Xor2 ix9711 (.out (nx9710), .A (nx12099), .B (tc6_data_9)) ;
    Xor2 ix9733 (.out (nx9732), .A (nx12101), .B (tc6_data_11)) ;
    Xor2 ix9756 (.out (nx9755), .A (nx12111), .B (tc6_data_13)) ;
    Xor2 ix9796 (.out (nx9795), .A (nx12111), .B (tc6_data_29)) ;
    Xor2 ix9802 (.out (nx9801), .A (nx12101), .B (tc6_data_27)) ;
    Xor2 ix9806 (.out (nx9805), .A (nx12099), .B (tc6_data_25)) ;
    Xor2 ix9812 (.out (nx9811), .A (nx12113), .B (tc6_data_23)) ;
    Xor2 ix9816 (.out (nx9815), .A (nx12115), .B (tc6_data_21)) ;
    Xor2 ix9822 (.out (nx9821), .A (nx10967), .B (tc6_data_19)) ;
    Xor2 ix9826 (.out (nx9825), .A (nx12095), .B (tc6_data_17)) ;
    Xor2 ix9828 (.out (nx9827), .A (nx12097), .B (tc6_data_16)) ;
    Inv ix10946 (.OUT (nx10947), .A (U_analog_control_cal_cnt_4)) ;
    Xor2 ix10064 (.out (nx10063), .A (nx9899), .B (U_analog_control_cal_dly_6)
         ) ;
    Xor2 ix10139 (.out (nx10138), .A (nx9955), .B (U_analog_control_cal_dly_0)
         ) ;
    Xor2 ix10143 (.out (nx10142), .A (nx9939), .B (U_analog_control_cal_dly_1)
         ) ;
    Xor2 ix10162 (.out (nx10161), .A (nx12097), .B (tc4_data_0)) ;
    Xor2 ix10164 (.out (nx10163), .A (nx12095), .B (tc4_data_1)) ;
    Xor2 ix10168 (.out (nx10167), .A (nx10967), .B (tc4_data_3)) ;
    Xor2 ix10222 (.out (nx10221), .A (nx12113), .B (tc4_data_23)) ;
    Xor2 ix10226 (.out (nx10225), .A (nx12115), .B (tc4_data_21)) ;
    Xor2 ix10232 (.out (nx10231), .A (nx10967), .B (tc4_data_19)) ;
    Xor2 ix10236 (.out (nx10235), .A (nx12095), .B (tc4_data_17)) ;
    Xor2 ix10238 (.out (nx10237), .A (nx12097), .B (tc4_data_16)) ;
    Xor2 ix10317 (.out (nx10316), .A (nx10967), .B (tc3_data_19)) ;
    Xor2 ix10321 (.out (nx10320), .A (nx12095), .B (tc3_data_17)) ;
    Xor2 ix10323 (.out (nx10322), .A (nx12097), .B (tc3_data_16)) ;
    Xor2 ix10332 (.out (nx10331), .A (nx12097), .B (tc2_data_0)) ;
    Xor2 ix10334 (.out (nx10333), .A (nx12096), .B (tc2_data_1)) ;
    Xor2 ix10338 (.out (nx10337), .A (nx10967), .B (tc2_data_3)) ;
    Xor2 ix10343 (.out (nx10342), .A (nx12115), .B (tc2_data_5)) ;
    Xor2 ix10347 (.out (nx10346), .A (nx12113), .B (tc2_data_7)) ;
    Xor2 ix10352 (.out (nx10351), .A (nx12099), .B (tc2_data_9)) ;
    Xor2 ix10356 (.out (nx10355), .A (nx12101), .B (tc2_data_11)) ;
    Xor2 ix10361 (.out (nx10360), .A (nx12111), .B (tc2_data_13)) ;
    Xor2 ix10376 (.out (nx10375), .A (nx12111), .B (tc2_data_29)) ;
    Xor2 ix10382 (.out (nx10381), .A (nx12101), .B (tc2_data_27)) ;
    Xor2 ix10386 (.out (nx10385), .A (nx12099), .B (tc2_data_25)) ;
    Xor2 ix10392 (.out (nx10391), .A (nx12113), .B (tc2_data_23)) ;
    Xor2 ix10396 (.out (nx10395), .A (nx12115), .B (tc2_data_21)) ;
    Xor2 ix10402 (.out (nx10401), .A (nx10967), .B (tc2_data_19)) ;
    Xor2 ix10406 (.out (nx10405), .A (nx12096), .B (tc2_data_17)) ;
    Xor2 ix10408 (.out (nx10407), .A (nx12097), .B (tc2_data_16)) ;
    Xor2 ix10446 (.out (nx10445), .A (nx10989), .B (tc1_data_13)) ;
    Xor2 ix10467 (.out (nx10466), .A (nx10985), .B (tc1_data_27)) ;
    Xor2 ix10471 (.out (nx10470), .A (nx10981), .B (tc1_data_25)) ;
    Xor2 ix10487 (.out (nx10486), .A (nx10969), .B (tc1_data_19)) ;
    Xor2 ix10491 (.out (nx10490), .A (nx10965), .B (tc1_data_17)) ;
    Xor2 ix10493 (.out (nx10492), .A (nx10961), .B (tc1_data_16)) ;
    Xor2 ix10513 (.out (nx10512), .A (nx10961), .B (tc0_data_0)) ;
    Xor2 ix10515 (.out (nx10514), .A (nx10965), .B (tc0_data_1)) ;
    Xor2 ix10519 (.out (nx10518), .A (nx10969), .B (tc0_data_3)) ;
    Xor2 ix10524 (.out (nx10523), .A (nx10973), .B (tc0_data_5)) ;
    Xor2 ix10528 (.out (nx10527), .A (nx10977), .B (tc0_data_7)) ;
    Xor2 ix10533 (.out (nx10532), .A (nx10981), .B (tc0_data_9)) ;
    Xor2 ix10537 (.out (nx10536), .A (nx10985), .B (tc0_data_11)) ;
    Xor2 ix10542 (.out (nx10541), .A (nx10989), .B (tc0_data_13)) ;
    Xor2 ix10558 (.out (nx10557), .A (nx10989), .B (tc0_data_29)) ;
    Xor2 ix10564 (.out (nx10563), .A (nx10985), .B (tc0_data_27)) ;
    Xor2 ix10568 (.out (nx10567), .A (nx10981), .B (tc0_data_25)) ;
    Xor2 ix10574 (.out (nx10573), .A (nx10977), .B (tc0_data_23)) ;
    Xor2 ix10578 (.out (nx10577), .A (nx10973), .B (tc0_data_21)) ;
    Xor2 ix10584 (.out (nx10583), .A (nx10969), .B (tc0_data_19)) ;
    Xor2 ix10588 (.out (nx10587), .A (nx10965), .B (tc0_data_17)) ;
    Xor2 ix10590 (.out (nx10589), .A (nx10961), .B (tc0_data_16)) ;
    Xor2 ix10597 (.out (nx10596), .A (nx10961), .B (tc5_data_0)) ;
    Xor2 ix10599 (.out (nx10598), .A (nx10965), .B (tc5_data_1)) ;
    Xor2 ix10603 (.out (nx10602), .A (nx10969), .B (tc5_data_3)) ;
    Xor2 ix10608 (.out (nx10607), .A (nx10973), .B (tc5_data_5)) ;
    Xor2 ix10612 (.out (nx10611), .A (nx10977), .B (tc5_data_7)) ;
    Xor2 ix10617 (.out (nx10616), .A (nx10981), .B (tc5_data_9)) ;
    Xor2 ix10621 (.out (nx10620), .A (nx10985), .B (tc5_data_11)) ;
    Xor2 ix10626 (.out (nx10625), .A (nx10989), .B (tc5_data_13)) ;
    Xor2 ix10641 (.out (nx10640), .A (nx10989), .B (tc5_data_29)) ;
    Xor2 ix10647 (.out (nx10646), .A (nx10985), .B (tc5_data_27)) ;
    Xor2 ix10651 (.out (nx10650), .A (nx10981), .B (tc5_data_25)) ;
    Xor2 ix10657 (.out (nx10656), .A (nx10977), .B (tc5_data_23)) ;
    Xor2 ix10661 (.out (nx10660), .A (nx10973), .B (tc5_data_21)) ;
    Xor2 ix10667 (.out (nx10666), .A (nx10969), .B (tc5_data_19)) ;
    Xor2 ix10671 (.out (nx10670), .A (nx10965), .B (tc5_data_17)) ;
    Xor2 ix10673 (.out (nx10672), .A (nx10961), .B (tc5_data_16)) ;
    Mux2 ix6001 (.OUT (nx6000), .A (U_readout_control_row_cnt_1), .B (
         U_readout_control_row_cnt_3), .SEL (nx8994)) ;
    Inv ix10956 (.OUT (nx10957), .A (nx10829)) ;
    Inv ix10960 (.OUT (nx10961), .A (nx10825)) ;
    Inv ix10964 (.OUT (nx10965), .A (nx10821)) ;
    Inv ix10968 (.OUT (nx10969), .A (nx10813)) ;
    Inv ix10972 (.OUT (nx10973), .A (nx10805)) ;
    Inv ix10976 (.OUT (nx10977), .A (nx10797)) ;
    Inv ix10978 (.OUT (nx10979), .A (nx10789)) ;
    Inv ix10980 (.OUT (nx10981), .A (nx10789)) ;
    Inv ix10984 (.OUT (nx10985), .A (nx10781)) ;
    Inv ix10988 (.OUT (nx10989), .A (nx11563)) ;
    DFFC U_command_control_reg_int_hdr_data_14 (.Q (
         U_command_control_int_hdr_data_14), .QB (nx7565), .D (nx3289), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_15 (.Q (
         U_command_control_int_hdr_data_15), .QB (nx7564), .D (nx3439), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    Nand3 ix2845 (.OUT (nx3182), .A (U_analog_control_mst_state_1), .B (nx9211)
          , .C (U_analog_control_mst_state_0)) ;
    DFFC U_analog_control_reg_mst_state_1 (.Q (U_analog_control_mst_state_1), .QB (
         nx9405), .D (nx2776), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_reg_mst_state_2 (.Q (U_analog_control_mst_state_2), .QB (
         nx9211), .D (nx2792), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_analog_control_reg_mst_state_0 (.Q (U_analog_control_mst_state_0), .QB (
         \$dummy [425]), .D (nx2832), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_2 (.Q (U_command_control_cmd_cnt_2), .QB (
         nx7472), .D (nx330), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix331 (.OUT (nx330), .A (nx7475), .B (nx3191), .C (nx3195_XX0_XREP35)
         ) ;
    DFFC reg_U_command_control_cmd_cnt_2__0_XREP21 (.Q (
         U_command_control_cmd_cnt_2__XX0_XREP21), .QB (nx7472_XX0_XREP21), .D (
         nx330), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_3 (.Q (U_command_control_cmd_cnt_3), .QB (
         nx7466), .D (nx346), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix347 (.OUT (nx346), .A (nx7469), .B (nx154), .C (nx3195_XX0_XREP35)) ;
    DFFC reg_U_command_control_cmd_cnt_3__0_XREP23 (.Q (
         U_command_control_cmd_cnt_3__XX0_XREP23), .QB (nx7466_XX0_XREP23), .D (
         nx346), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_1 (.Q (U_command_control_cmd_cnt_1), .QB (
         nx7478), .D (nx314), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix315 (.OUT (nx314), .A (nx7481), .B (nx3199), .C (nx3195_XX0_XREP35)
         ) ;
    DFFC reg_U_command_control_cmd_cnt_1__0_XREP25 (.Q (
         U_command_control_cmd_cnt_1__XX0_XREP25), .QB (nx7478_XX0_XREP25), .D (
         nx314), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_0 (.Q (U_command_control_cmd_cnt_0), .QB (
         nx7511), .D (nx300), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_command_control_cmd_cnt_0__0_XREP27 (.Q (
         U_command_control_cmd_cnt_0__XX0_XREP27), .QB (nx7511_XX0_XREP27), .D (
         nx300), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix10952 (.OUT (nx10953), .A (nx10829_XX0_XREP249)) ;
    Inv ix10952_0_XREP31 (.OUT (nx10953_XX0_XREP31), .A (nx10829)) ;
    DFFC U_command_control_reg_int_hdr_data_12 (.Q (
         U_command_control_int_hdr_data_12), .QB (nx7567), .D (nx3309), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_12__0_XREP33 (.Q (
         U_command_control_int_hdr_data_12__XX0_XREP33), .QB (nx7567_XX0_XREP33)
         , .D (nx3309), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix295 (.OUT (nx3195), .A (nx7486), .B (nx7504), .C (nx7507)) ;
    Nand2 ix7487 (.OUT (nx7486), .A (nx196), .B (nx288)) ;
    Nand3 ix7505 (.OUT (nx7504), .A (nx3188), .B (nx7444_XX0_XREP465), .C (
          nx10829)) ;
    Nand3 ix295_0_XREP35 (.OUT (nx3195_XX0_XREP35), .A (nx7486), .B (nx7504), .C (
          nx7507)) ;
    Inv ix10744 (.OUT (nx10745), .A (nx7563)) ;
    DFFC U_command_control_reg_int_hdr_data_16 (.Q (\$dummy [426]), .QB (nx7563)
         , .D (nx3429), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix10744_0_XREP37 (.OUT (nx10745_XX0_XREP37), .A (nx7563)) ;
    DFFC U_command_control_reg_int_hdr_data_17 (.Q (
         U_command_control_int_hdr_data_17), .QB (nx7562), .D (nx3419), .CLK (
         sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_17__0_XREP39 (.Q (
         U_command_control_int_hdr_data_17__XX0_XREP39), .QB (nx7562_XX0_XREP39)
         , .D (nx3419), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix10954 (.OUT (nx10955), .A (nx10829_XX0_XREP249)) ;
    Inv ix10954_0_XREP41 (.OUT (nx10955_XX0_XREP41), .A (nx10829_XX0_XREP249)) ;
    Nor2 ix419 (.OUT (nx418), .A (nx7564_XX0_XREP3), .B (nx7565_XX0_XREP1)) ;
    DFFC U_command_control_reg_int_hdr_data_15__0_XREP3 (.Q (
         U_command_control_int_hdr_data_15__XX0_XREP3), .QB (nx7564_XX0_XREP3), 
         .D (nx3439), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_int_hdr_data_14__0_XREP1 (.Q (
         U_command_control_int_hdr_data_14__XX0_XREP1), .QB (nx7565_XX0_XREP1), 
         .D (nx3289), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor2 ix419_0_XREP45 (.OUT (nx418_XX0_XREP45), .A (nx7564_XX0_XREP3), .B (
         nx7565_XX0_XREP1)) ;
    DFFC reg_U_readout_control_st_cnt_3 (.Q (U_readout_control_st_cnt_3), .QB (
         nx9024), .D (nx3074), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3075 (.OUT (nx3074), .A (nx9027), .B (nx3224), .C (nx3222)) ;
    DFFC reg_U_readout_control_st_cnt_3__0_XREP79 (.Q (
         U_readout_control_st_cnt_3__XX0_XREP79), .QB (nx9024_XX0_XREP79), .D (
         nx3074), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_st_cnt_2 (.Q (U_readout_control_st_cnt_2), .QB (
         nx8988), .D (nx3058), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix3059 (.OUT (nx3058), .A (nx8991), .B (nx3223), .C (nx3222)) ;
    DFFC reg_U_readout_control_st_cnt_2__0_XREP83 (.Q (
         U_readout_control_st_cnt_2__XX0_XREP83), .QB (nx8988_XX0_XREP83), .D (
         nx3058), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_st_cnt_0 (.Q (U_readout_control_st_cnt_0), .QB (
         nx8986), .D (nx3042), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_st_cnt_0__0_XREP85 (.Q (
         U_readout_control_st_cnt_0__XX0_XREP85), .QB (nx8986_XX0_XREP85), .D (
         nx3042), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_typ_cnt_3 (.Q (U_readout_control_typ_cnt_3), .QB (
         nx8876), .D (nx7159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix8941 (.OUT (nx8940), .A (nx3410)) ;
    Inv ix8941_0_XREP111 (.OUT (nx8940_XX0_XREP111), .A (nx3410)) ;
    Nand2 ix3415 (.OUT (nx3414), .A (nx8944_XX0_XREP531), .B (nx3410)) ;
    Nand2 ix3411 (.OUT (nx3410), .A (nx9115), .B (nx8864_XX0_XREP291)) ;
    Nand2 ix3415_0_XREP113 (.OUT (nx3414_XX0_XREP113), .A (nx8944), .B (nx3410)
          ) ;
    Nand2 ix8972 (.OUT (nx8971), .A (nx8973), .B (nx3204)) ;
    Inv ix8974 (.OUT (nx8973), .A (nx3198)) ;
    Nand3 ix3205 (.OUT (nx3204), .A (U_readout_control_st_cnt_0__XX0_XREP85), .B (
          nx8994), .C (nx9066)) ;
    Nand2 ix8972_0_XREP121 (.OUT (nx8971_XX0_XREP121), .A (nx8973), .B (nx3204)
          ) ;
    Nor2 ix9177 (.OUT (nx9176), .A (nx3542_XX0_XREP323), .B (nx3548)) ;
    Nand2 ix3549 (.OUT (nx3548), .A (nx3192), .B (nx3410)) ;
    Nor2 ix9177_0_XREP133 (.OUT (nx9176_XX0_XREP133), .A (nx3542), .B (nx3548)
         ) ;
    DFFC reg_U_analog_control_sub_cnt_2 (.Q (U_analog_control_sub_cnt_2), .QB (
         nx9258), .D (nx2472), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2473 (.OUT (nx2472), .A (nx9261), .B (nx3210), .C (nx10759)) ;
    DFFC reg_U_analog_control_sub_cnt_2__0_XREP143 (.Q (
         U_analog_control_sub_cnt_2__XX0_XREP143), .QB (nx9258_XX0_XREP143), .D (
         nx2472), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_1 (.Q (U_analog_control_sub_cnt_1), .QB (
         nx9264), .D (nx2456), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nor3 ix2457 (.OUT (nx2456), .A (nx9267), .B (nx3209), .C (nx10757)) ;
    DFFC reg_U_analog_control_sub_cnt_1__0_XREP145 (.Q (
         U_analog_control_sub_cnt_1__XX0_XREP145), .QB (nx9264_XX0_XREP145), .D (
         nx2456), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_0 (.Q (U_analog_control_sub_cnt_0), .QB (
         nx9413), .D (nx2442), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_analog_control_sub_cnt_0__0_XREP147 (.Q (
         U_analog_control_sub_cnt_0__XX0_XREP147), .QB (nx9413_XX0_XREP147), .D (
         nx2442), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix10824 (.OUT (nx10825), .A (nx12098)) ;
    DFFC U_analog_control_mst_cnt_0 (.Q (\$dummy [427]), .QB (nx9623), .D (
         nx4614), .CLK (sysclk), .CLR (int_reset_l)) ;
    Inv ix10820 (.OUT (nx10821), .A (nx12096)) ;
    DFFC U_analog_control_mst_cnt_1 (.Q (\$dummy [428]), .QB (nx9631), .D (
         nx4626), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10816 (.OUT (nx10817), .A (U_analog_control_mst_cnt_2)) ;
    Buf1 ix10808 (.OUT (nx10809), .A (U_analog_control_mst_cnt_4)) ;
    Buf1 ix10800 (.OUT (nx10801), .A (U_analog_control_mst_cnt_6)) ;
    Buf1 ix10792 (.OUT (nx10793), .A (U_analog_control_mst_cnt_8)) ;
    Buf1 ix10792_0_XREP167 (.OUT (nx10793_XX0_XREP167), .A (
         U_analog_control_mst_cnt_8)) ;
    Buf1 ix10784 (.OUT (nx10785), .A (U_analog_control_mst_cnt_10)) ;
    Buf1 ix10784_0_XREP169 (.OUT (nx10785_XX0_XREP169), .A (
         U_analog_control_mst_cnt_10)) ;
    Buf1 ix10776_0_XREP171 (.OUT (nx10777_XX0_XREP171), .A (nx12103)) ;
    Buf1 ix10768_0_XREP173 (.OUT (nx10769_XX0_XREP173), .A (
         U_analog_control_mst_cnt_14)) ;
    Buf1 ix10764_0_XREP175 (.OUT (nx10765_XX0_XREP175), .A (nx12105)) ;
    DFFC U_analog_control_reg_cal_state_0 (.Q (U_analog_control_cal_state_0), .QB (
         nx9848), .D (nx4562), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix4563 (.OUT (nx4562), .A (nx9836), .B (nx9987)) ;
    DFFC U_analog_control_reg_cal_state_0__0_XREP179 (.Q (
         U_analog_control_cal_state_0__XX0_XREP179), .QB (nx9848_XX0_XREP179), .D (
         nx4562), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix9990 (.OUT (nx9989), .A (nx4502), .B (nx4512), .C (nx4524), .D (
          nx4534)) ;
    Nor4 ix10002 (.OUT (nx4502), .A (nx12107), .B (nx9848_XX0_XREP179), .C (
         U_analog_control_cal_cnt_11), .D (U_analog_control_cal_cnt_10)) ;
    Nor3 ix4513 (.OUT (nx4512), .A (U_analog_control_cal_cnt_7), .B (
         U_analog_control_cal_cnt_9), .C (U_analog_control_cal_cnt_8)) ;
    Nor3 ix4535 (.OUT (nx4534), .A (U_analog_control_cal_cnt_0), .B (
         U_analog_control_cal_cnt_2), .C (U_analog_control_cal_cnt_1)) ;
    Buf1 ix10770 (.OUT (nx10771), .A (U_analog_control_mst_cnt_14)) ;
    DFFC reg_U_analog_control_mst_cnt_14 (.Q (U_analog_control_mst_cnt_14), .QB (
         \$dummy [429]), .D (nx4808), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10770_0_XREP217 (.OUT (nx10771_XX0_XREP217), .A (
         U_analog_control_mst_cnt_14)) ;
    Buf1 ix10778 (.OUT (nx10779), .A (nx12103)) ;
    DFFC reg_U_analog_control_mst_cnt_12 (.Q (U_analog_control_mst_cnt_12), .QB (
         \$dummy [430]), .D (nx4780), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10778_0_XREP219 (.OUT (nx10779_XX0_XREP219), .A (nx12104)) ;
    Buf1 ix10786 (.OUT (nx10787), .A (U_analog_control_mst_cnt_10)) ;
    DFFC reg_U_analog_control_mst_cnt_10 (.Q (U_analog_control_mst_cnt_10), .QB (
         \$dummy [431]), .D (nx4752), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10786_0_XREP221 (.OUT (nx10787_XX0_XREP221), .A (
         U_analog_control_mst_cnt_10)) ;
    Buf1 ix10794 (.OUT (nx10795), .A (U_analog_control_mst_cnt_8)) ;
    DFFC reg_U_analog_control_mst_cnt_8 (.Q (U_analog_control_mst_cnt_8), .QB (
         \$dummy [432]), .D (nx4724), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10794_0_XREP223 (.OUT (nx10795_XX0_XREP223), .A (
         U_analog_control_mst_cnt_8)) ;
    Buf1 ix10766 (.OUT (nx10767), .A (nx12105)) ;
    DFFC reg_U_analog_control_mst_cnt_15 (.Q (U_analog_control_mst_cnt_15), .QB (
         \$dummy [433]), .D (nx4818), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10766_0_XREP231 (.OUT (nx10767_XX0_XREP231), .A (nx12105)) ;
    Inv ix10828 (.OUT (nx10829), .A (nx3187)) ;
    Nor3 ix7450 (.OUT (nx3187), .A (nx7446), .B (
         U_command_control_cmd_state_2__XX0_XREP465), .C (
         U_command_control_cmd_state_1__XX0_XREP471)) ;
    Inv ix10828_0_XREP249 (.OUT (nx10829_XX0_XREP249), .A (nx3187)) ;
    DFFC U_readout_control_reg_rd_state_0 (.Q (U_readout_control_rd_state_0), .QB (
         nx8864), .D (nx3730), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix3731 (.OUT (nx3730), .A (nx3494), .B (nx3233), .C (nx9208), .D (
          nx9484)) ;
    DFFC U_readout_control_reg_rd_state_0__0_XREP291 (.Q (
         U_readout_control_rd_state_0__XX0_XREP291), .QB (nx8864_XX0_XREP291), .D (
         nx3730), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_readout_control_reg_rd_state_2 (.Q (U_readout_control_rd_state_2), .QB (
         nx8907), .D (nx3630), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix3631 (.OUT (nx3630), .A (nx8910), .B (nx9140), .C (nx9182)) ;
    DFFC U_readout_control_reg_rd_state_2__0_XREP297 (.Q (
         U_readout_control_rd_state_2__XX0_XREP297), .QB (nx8907_XX0_XREP297), .D (
         nx3630), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC reg_U_readout_control_typ_cnt_3__0_XREP89 (.Q (
         U_readout_control_typ_cnt_3__XX0_XREP89), .QB (nx8876_XX0_XREP89), .D (
         nx7159), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix3385 (.OUT (nx3384), .A (nx8949), .B (nx8876_XX0_XREP89_XX0_XREP303)
          ) ;
    DFFC reg_U_readout_control_typ_cnt_3__0_XREP89_0_XREP303 (.Q (
         U_readout_control_typ_cnt_3__XX0_XREP89_XX0_XREP303), .QB (
         nx8876_XX0_XREP89_XX0_XREP303), .D (nx7159), .CLK (sysclk), .CLR (
         int_reset_l)) ;
    Nor2 ix3543 (.OUT (nx3542), .A (nx3198), .B (nx9064)) ;
    Nand3 ix3199 (.OUT (nx3198), .A (U_readout_control_rd_state_1), .B (
          nx8907_XX0_XREP297), .C (nx8864)) ;
    Nand3 ix9065 (.OUT (nx9064), .A (nx9066), .B (nx8994), .C (
          U_readout_control_st_cnt_0__XX0_XREP85)) ;
    Nor2 ix3543_0_XREP323 (.OUT (nx3542_XX0_XREP323), .A (nx3198), .B (nx9064)
         ) ;
    Buf1 ix10816_0_XREP161 (.OUT (nx10817_XX0_XREP161), .A (
         U_analog_control_mst_cnt_2)) ;
    DFFC reg_U_analog_control_mst_cnt_2 (.Q (U_analog_control_mst_cnt_2), .QB (
         \$dummy [434]), .D (nx4640), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10808_0_XREP163 (.OUT (nx10809_XX0_XREP163), .A (
         U_analog_control_mst_cnt_4)) ;
    DFFC reg_U_analog_control_mst_cnt_4 (.Q (U_analog_control_mst_cnt_4), .QB (
         \$dummy [435]), .D (nx4668), .CLK (sysclk), .CLR (int_reset_l)) ;
    Buf1 ix10800_0_XREP165 (.OUT (nx10801_XX0_XREP165), .A (
         U_analog_control_mst_cnt_6)) ;
    DFFC reg_U_analog_control_mst_cnt_6 (.Q (U_analog_control_mst_cnt_6), .QB (
         \$dummy [436]), .D (nx4696), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_cmd_state_2 (.Q (U_command_control_cmd_state_2), 
         .QB (nx7444), .D (nx220), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand3 ix221 (.OUT (nx220), .A (nx7441), .B (nx7597), .C (nx7604)) ;
    DFFC U_command_control_reg_cmd_state_2__0_XREP465 (.Q (
         U_command_control_cmd_state_2__XX0_XREP465), .QB (nx7444_XX0_XREP465), 
         .D (nx220), .CLK (sysclk), .CLR (int_reset_l)) ;
    DFFC U_command_control_reg_cmd_state_1 (.Q (U_command_control_cmd_state_1), 
         .QB (nx7452), .D (nx262), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand4 ix263 (.OUT (nx262), .A (nx7455), .B (nx7441), .C (nx7522), .D (nx7529
          )) ;
    DFFC U_command_control_reg_cmd_state_1__0_XREP471 (.Q (
         U_command_control_cmd_state_1__XX0_XREP471), .QB (nx7452_XX0_XREP471), 
         .D (nx262), .CLK (sysclk), .CLR (int_reset_l)) ;
    Nand2 ix8945 (.OUT (nx8944), .A (nx11990), .B (nx3384_XX0_XREP311)) ;
    Nand2 ix12117 (.OUT (nx11435), .A (U_analog_control_mst_cnt_14), .B (nx11563
          )) ;
    BufI4 ix12118 (.OUT (nx11436), .A (nx12106)) ;
    Nand2 ix12119 (.OUT (nx11437), .A (nx12104), .B (nx11436)) ;
    Nor2 ix12120 (.OUT (nx11438), .A (nx11435), .B (nx11437)) ;
    Nand2 ix12121 (.OUT (nx11439), .A (nx12093), .B (nx11438)) ;
    Inv ix12122 (.OUT (nx11440), .A (nx11439)) ;
    Nand2 ix12123 (.OUT (nx11441), .A (nx3278), .B (nx11440)) ;
    Nand2 ix12124 (.OUT (nx11442), .A (nx12106), .B (nx11435)) ;
    BufI4 ix12125 (.OUT (nx11443), .A (nx12104)) ;
    Nand2 ix12126 (.OUT (nx11444), .A (nx12106), .B (nx11443)) ;
    Nand2 ix12127 (.OUT (nx11445), .A (nx11442), .B (nx11444)) ;
    Inv ix12128 (.OUT (nx11446), .A (nx3278)) ;
    Nand2 ix12129 (.OUT (nx11447), .A (nx12093), .B (nx12106)) ;
    Inv ix12130 (.OUT (nx11448), .A (nx11447)) ;
    AOI22 ix12131 (.OUT (nx11449), .A (nx12093), .B (nx11445), .C (nx11446), .D (
          nx11448)) ;
    Nand2 reg_nx4818 (.OUT (nx4818), .A (nx11441), .B (nx11449)) ;
    Nand3 ix12132 (.OUT (nx11450), .A (nx12104), .B (U_analog_control_mst_cnt_14
          ), .C (nx11563)) ;
    Inv ix12133 (.OUT (nx11451), .A (nx11450)) ;
    Nand2 ix12134 (.OUT (nx11452), .A (nx11563), .B (nx12104)) ;
    BufI4 reg_nx10987 (.OUT (nx10987), .A (nx11563)) ;
    BufI4 ix12135 (.OUT (nx11453), .A (nx10140)) ;
    BufI4 ix12136 (.OUT (nx11454), .A (nx10081)) ;
    Nand2 ix12137 (.OUT (nx11455), .A (nx10138), .B (nx10142)) ;
    Nand2 ix12138 (.OUT (nx11456), .A (nx9891), .B (nx9875)) ;
    Nor3 ix12139 (.OUT (nx11457), .A (U_analog_control_cal_dly_9), .B (
         U_analog_control_cal_dly_7), .C (nx11456)) ;
    Inv ix12140 (.OUT (nx11458), .A (U_analog_control_cal_dly_9)) ;
    Inv ix12141 (.OUT (nx11459), .A (nx9875)) ;
    Nor2 ix12142 (.OUT (nx11460), .A (nx11459), .B (nx9891)) ;
    Inv ix12143 (.OUT (nx11461), .A (nx9891)) ;
    Nor3 ix12144 (.OUT (nx11462), .A (U_analog_control_cal_dly_7), .B (nx11461)
         , .C (nx9875)) ;
    Nor2 ix12145 (.OUT (nx11463), .A (nx9891), .B (nx9875)) ;
    Nand3 ix12146 (.OUT (nx11464), .A (U_analog_control_cal_dly_9), .B (
          U_analog_control_cal_dly_7), .C (nx11463)) ;
    Nor2 ix12147 (.OUT (nx11465), .A (U_analog_control_cal_cnt_8), .B (
         U_analog_control_cal_dly_8)) ;
    Inv ix12148 (.OUT (nx11466), .A (nx11465)) ;
    Nand2 ix12149 (.OUT (nx11467), .A (U_analog_control_cal_cnt_8), .B (
          U_analog_control_cal_dly_8)) ;
    Nand2 ix12150 (.OUT (nx11468), .A (U_analog_control_mst_state_0), .B (
          U_analog_control_sub_cnt_1__XX0_XREP145)) ;
    Inv ix12151 (.OUT (nx11469), .A (U_analog_control_sub_cnt_2__XX0_XREP143)) ;
    Inv ix12152 (.OUT (nx11470), .A (nx9971)) ;
    Inv ix12153 (.OUT (nx11471), .A (nx10027)) ;
    AOI22 ix12154 (.OUT (nx11472), .A (nx10027), .B (nx11470), .C (nx9971), .D (
          nx11471)) ;
    Inv ix12155 (.OUT (nx11473), .A (nx9975)) ;
    Inv ix12156 (.OUT (nx11474), .A (nx9976)) ;
    AOI22 ix12157 (.OUT (nx11475), .A (nx9976), .B (nx11473), .C (nx9975), .D (
          nx11474)) ;
    Nand2 ix12158 (.OUT (nx11476), .A (nx9211), .B (nx9413_XX0_XREP147)) ;
    Inv ix12159 (.OUT (nx11477), .A (nx11476)) ;
    Nand3 reg_nx3182_XX0_XREP11 (.OUT (nx3182_XX0_XREP11), .A (
          U_analog_control_mst_state_0), .B (U_analog_control_mst_state_1), .C (
          nx9211)) ;
    Nand3 reg_nx3822 (.OUT (nx3822), .A (U_analog_control_sub_cnt_2__XX0_XREP143
          ), .B (U_analog_control_sub_cnt_1__XX0_XREP145), .C (
          nx9413_XX0_XREP147)) ;
    Nor2 ix12160 (.OUT (nx11478), .A (nx9848), .B (nx12107)) ;
    Nand2 ix12161 (.OUT (nx11479), .A (nx11628), .B (nx11478)) ;
    Inv ix12162 (.OUT (nx11480), .A (nx11479)) ;
    Nand2 ix12163 (.OUT (nx11481), .A (nx9854), .B (nx11480)) ;
    Inv ix12164 (.OUT (nx11482), .A (nx11481)) ;
    Inv ix12165 (.OUT (nx11483), .A (nx4524)) ;
    Nand2 ix12166 (.OUT (nx11484), .A (nx4512), .B (nx4534)) ;
    Inv ix12167 (.OUT (nx11485), .A (nx11484)) ;
    Nand2 ix12168 (.OUT (nx11486), .A (nx4502), .B (nx11485)) ;
    BufI4 ix12169 (.OUT (nx11487), .A (nx12107)) ;
    Nor4 ix12170 (.OUT (nx11488), .A (nx11483), .B (nx11486), .C (nx11487), .D (
         nx9848)) ;
    Nor3 ix12171 (.OUT (nx11489), .A (nx9854), .B (nx11487), .C (nx9848)) ;
    Nor3 reg_nx9832 (.OUT (nx9832), .A (nx11482), .B (nx11488), .C (nx11489)) ;
    Inv reg_nx3241 (.OUT (nx3241), .A (nx9832)) ;
    Nand2 ix12172 (.OUT (nx11490), .A (nx12093), .B (nx10781)) ;
    Nor4 ix12173 (.OUT (nx11491), .A (nx9741), .B (nx11451), .C (nx11452), .D (
         nx11490)) ;
    Inv ix12174 (.OUT (nx11492), .A (nx11491)) ;
    Nand2 ix12175 (.OUT (nx11493), .A (U_analog_control_mst_cnt_14), .B (nx12094
          )) ;
    Inv ix12176 (.OUT (nx11494), .A (nx11493)) ;
    Nand2 ix12177 (.OUT (nx11495), .A (nx11451), .B (nx10781)) ;
    Inv ix12178 (.OUT (nx11496), .A (nx11493)) ;
    AOI22 ix12179 (.OUT (nx11497), .A (nx9741), .B (nx11494), .C (nx11495), .D (
          nx11496)) ;
    Nand2 reg_nx4808 (.OUT (nx4808), .A (nx11492), .B (nx11497)) ;
    BufI4 reg_nx10983 (.OUT (nx10983), .A (nx10781)) ;
    Inv ix12180 (.OUT (nx11498), .A (nx2164)) ;
    Nor2 ix12181 (.OUT (nx11499), .A (nx8793), .B (nx7709)) ;
    Inv reg_NOT_nx530 (.OUT (NOT_nx530), .A (nx11499)) ;
    Inv ix12182 (.OUT (nx11500), .A (nx8583)) ;
    Nor2 ix12183 (.OUT (nx11501), .A (nx10745_XX0_XREP37), .B (
         U_command_control_int_hdr_data_15__XX0_XREP3)) ;
    Inv ix12184 (.OUT (nx11502), .A (nx11501)) ;
    Nor2 ix12185 (.OUT (nx11503), .A (nx424), .B (nx11502)) ;
    Nand2 ix12186 (.OUT (nx11504), .A (nx11500), .B (nx11503)) ;
    Nand2 ix12187 (.OUT (nx11505), .A (NOT_nx530), .B (nx11504)) ;
    Nor3 ix12188 (.OUT (nx11506), .A (nx8800), .B (
         U_command_control_int_hdr_data_13), .C (nx7567_XX0_XREP33)) ;
    Inv ix12189 (.OUT (nx11507), .A (nx11506)) ;
    Nor2 reg_nx142 (.OUT (nx142), .A (nx7532), .B (nx11507)) ;
    BufI4 ix12190 (.OUT (nx11508), .A (nx142)) ;
    BufI4 ix12191 (.OUT (nx11509), .A (nx520)) ;
    Nand2 ix12192 (.OUT (nx11510), .A (nx11508), .B (nx11509)) ;
    Nor3 ix12193 (.OUT (nx11511), .A (nx11505), .B (nx514), .C (nx11510)) ;
    Nand2 ix12194 (.OUT (nx11512), .A (nx11498), .B (nx11511)) ;
    Nand2 reg_nx7441 (.OUT (nx7441), .A (nx152), .B (nx214)) ;
    Inv ix12195 (.OUT (nx11513), .A (nx514)) ;
    Nand4 ix12196 (.OUT (nx11514), .A (nx7441), .B (nx11513), .C (nx11508), .D (
          nx11509)) ;
    Nand2 reg_nx7617 (.OUT (nx7617), .A (nx11512), .B (nx11514)) ;
    Nand2 ix12197 (.OUT (nx11515), .A (nx8836), .B (nx8809)) ;
    Inv ix12198 (.OUT (nx11516), .A (nx7611)) ;
    Nand2 ix12199 (.OUT (nx11517), .A (nx11515), .B (nx11516)) ;
    Inv ix12200 (.OUT (nx11518), .A (nx11517)) ;
    Nand2 ix12201 (.OUT (nx11519), .A (nx7617), .B (nx11518)) ;
    Inv ix12202 (.OUT (nx11520), .A (U_command_control_int_par)) ;
    Nand2 ix12203 (.OUT (nx11521), .A (reg_data), .B (nx11520)) ;
    Inv ix12204 (.OUT (nx11522), .A (reg_data)) ;
    Nand2 ix12205 (.OUT (nx11523), .A (U_command_control_int_par), .B (nx11522)
          ) ;
    Nand2 reg_nx3203 (.OUT (nx3203), .A (nx11521), .B (nx11523)) ;
    Nand2 ix12206 (.OUT (nx11524), .A (nx7501), .B (nx10833)) ;
    Nor3 ix12207 (.OUT (nx11525), .A (nx514), .B (nx142), .C (nx520)) ;
    AOI22 ix12208 (.OUT (nx11526), .A (nx7441), .B (nx11525), .C (nx11498), .D (
          nx11511)) ;
    Nand2 ix12209 (.OUT (nx11527), .A (nx7611), .B (nx11515)) ;
    Inv ix12210 (.OUT (nx11528), .A (nx11527)) ;
    AOI22 ix12211 (.OUT (nx11529), .A (nx3203), .B (nx11524), .C (nx11526), .D (
          nx11528)) ;
    Nand2 reg_nx2190 (.OUT (nx2190), .A (nx11519), .B (nx11529)) ;
    BufI4 ix12212 (.OUT (nx11530), .A (nx12107)) ;
    BufI4 ix12213 (.OUT (nx11531), .A (nx12108)) ;
    AOI22 ix12214 (.OUT (nx11532), .A (nx9848_XX0_XREP179), .B (nx11530), .C (
          nx9952), .D (nx11531)) ;
    Inv ix12215 (.OUT (nx11533), .A (nx11532)) ;
    Inv ix12216 (.OUT (nx11534), .A (nx10949)) ;
    Inv ix12217 (.OUT (nx11535), .A (nx4482)) ;
    Nand2 ix12218 (.OUT (nx11536), .A (nx11628), .B (nx11535)) ;
    Inv ix12219 (.OUT (nx11537), .A (nx11536)) ;
    AOI22 ix12220 (.OUT (nx11538), .A (nx11628), .B (nx11533), .C (nx11534), .D (
          nx11537)) ;
    Nand2 ix12221 (.OUT (nx11539), .A (nx3257), .B (nx11628)) ;
    Nor2 ix12222 (.OUT (nx11540), .A (nx3259), .B (nx11539)) ;
    Nand2 ix12223 (.OUT (nx11541), .A (nx9854), .B (nx11540)) ;
    Inv ix12224 (.OUT (nx11542), .A (nx11541)) ;
    Nand2 ix12225 (.OUT (nx11543), .A (nx11538), .B (nx11542)) ;
    Nand2 ix12226 (.OUT (nx11544), .A (U_analog_control_cal_cnt_6), .B (nx11628)
          ) ;
    Nor2 ix12227 (.OUT (nx11545), .A (nx3259), .B (nx11544)) ;
    Nand2 ix12228 (.OUT (nx11546), .A (nx9854), .B (nx11545)) ;
    Nand2 ix12229 (.OUT (nx11547), .A (nx11628), .B (nx11533)) ;
    Nand2 ix12230 (.OUT (nx11548), .A (U_analog_control_cal_cnt_6), .B (
          nx10925_XX0_XREP193)) ;
    Nand3 reg_nx7279 (.OUT (nx7279), .A (nx11543), .B (nx11546), .C (nx11548)) ;
    BufI4 reg_nx10923 (.OUT (nx10923), .A (nx12094)) ;
    Inv ix12231 (.OUT (nx11549), .A (nx11452)) ;
    BufI4 ix12232 (.OUT (nx11550), .A (nx12101)) ;
    Nand2 ix12233 (.OUT (nx11551), .A (nx12104), .B (nx11550)) ;
    Nor4 ix12234 (.OUT (nx11552), .A (nx9741), .B (nx10923), .C (nx11549), .D (
         nx11551)) ;
    Inv ix12235 (.OUT (nx11553), .A (nx11552)) ;
    Inv reg_nx10773 (.OUT (nx10773), .A (nx9762)) ;
    Nand2 ix12236 (.OUT (nx11554), .A (nx12101), .B (nx10773)) ;
    Inv ix12237 (.OUT (nx11555), .A (nx9762)) ;
    Nand2 ix12238 (.OUT (nx11556), .A (nx11452), .B (nx11555)) ;
    Nand2 ix12239 (.OUT (nx11557), .A (nx11554), .B (nx11556)) ;
    Inv ix12240 (.OUT (nx11558), .A (nx9762)) ;
    Nand2 ix12241 (.OUT (nx11559), .A (nx12094), .B (nx11558)) ;
    Inv ix12242 (.OUT (nx11560), .A (nx11559)) ;
    AOI22 ix12243 (.OUT (nx11561), .A (nx12094), .B (nx11557), .C (nx9741), .D (
          nx11560)) ;
    Nand2 reg_nx4794 (.OUT (nx4794), .A (nx11553), .B (nx11561)) ;
    BufI4 ix12244 (.OUT (nx11562), .A (nx12104)) ;
    Nor3 reg_nx3279 (.OUT (nx3279), .A (nx9741), .B (nx11562), .C (nx12101)) ;
    BufI4 ix12245 (.OUT (nx11563), .A (nx9762)) ;
    Nor2 reg_nx3278 (.OUT (nx3278), .A (nx9741), .B (nx12102)) ;
    Inv ix12246 (.OUT (nx11564), .A (nx9402)) ;
    Nor2 ix12247 (.OUT (nx11565), .A (nx11564), .B (nx9379)) ;
    Nand3 ix12248 (.OUT (nx11566), .A (U_analog_control_sub_cnt_12), .B (
          U_analog_control_sub_cnt_14), .C (nx11565)) ;
    Inv ix12249 (.OUT (nx11567), .A (nx11566)) ;
    Inv ix12250 (.OUT (nx11568), .A (nx9379)) ;
    Nand3 ix12251 (.OUT (nx11569), .A (U_analog_control_sub_cnt_12), .B (
          U_analog_control_sub_cnt_14), .C (nx11568)) ;
    Inv ix12252 (.OUT (nx11570), .A (nx11569)) ;
    Nor2 ix12253 (.OUT (nx11571), .A (nx11570), .B (nx9402)) ;
    Inv ix12254 (.OUT (nx11572), .A (nx11569)) ;
    Nand2 reg_nx9400 (.OUT (nx9400), .A (nx3218), .B (nx11572)) ;
    Inv ix12255 (.OUT (nx11573), .A (nx9379)) ;
    Nand2 ix12256 (.OUT (nx11574), .A (U_analog_control_sub_cnt_12), .B (nx11573
          )) ;
    Inv ix12257 (.OUT (nx11575), .A (nx11574)) ;
    Nand2 ix12258 (.OUT (nx11576), .A (nx3218), .B (nx11575)) ;
    Inv reg_nx3220 (.OUT (nx3220), .A (nx11576)) ;
    Nand2 reg_nx9381 (.OUT (nx9381), .A (U_analog_control_sub_cnt_12), .B (
          nx3218)) ;
    BufI4 ix12259 (.OUT (nx11577), .A (nx10063)) ;
    Nand2 ix12260 (.OUT (nx11578), .A (nx11466), .B (nx11467)) ;
    Inv ix12261 (.OUT (nx11579), .A (nx11457)) ;
    Nand3 ix12262 (.OUT (nx11580), .A (nx11458), .B (U_analog_control_cal_dly_7)
          , .C (nx11460)) ;
    Nand2 ix12263 (.OUT (nx11581), .A (U_analog_control_cal_dly_9), .B (nx11462)
          ) ;
    Nand4 ix12264 (.OUT (nx11582), .A (nx11464), .B (nx11579), .C (nx11580), .D (
          nx11581)) ;
    Nand4 ix12265 (.OUT (nx11583), .A (nx11475), .B (nx11472), .C (
          U_analog_control_mst_state_1), .D (nx11477)) ;
    Nor3 ix12266 (.OUT (nx11584), .A (nx11468), .B (nx11469), .C (nx11583)) ;
    Nand3 ix12267 (.OUT (nx11585), .A (nx11578), .B (nx11582), .C (nx11584)) ;
    Nor3 ix12268 (.OUT (nx11586), .A (nx11455), .B (nx11577), .C (nx11585)) ;
    Nand3 ix12269 (.OUT (nx11587), .A (U_analog_control_mst_cnt_2), .B (nx10813)
          , .C (nx11816)) ;
    Inv reg_nx3268 (.OUT (nx3268), .A (nx11587)) ;
    BufI4 reg_nx10967 (.OUT (nx10967), .A (nx10813)) ;
    Nand2 reg_nx9651 (.OUT (nx9651), .A (U_analog_control_mst_cnt_2), .B (
          nx11816)) ;
    Nor2 ix12270 (.OUT (nx11588), .A (nx11453), .B (nx11454)) ;
    Nand2 ix12271 (.OUT (nx11589), .A (U_analog_control_cal_state_0__XX0_XREP179
          ), .B (nx11643)) ;
    BufI4 ix12272 (.OUT (nx11590), .A (nx12108)) ;
    Inv ix12273 (.OUT (nx11591), .A (U_analog_control_cal_state_0__XX0_XREP179)
        ) ;
    Nor2 ix12274 (.OUT (nx11592), .A (nx11591), .B (nx11588)) ;
    Nor2 ix12275 (.OUT (nx11593), .A (nx11590), .B (nx11592)) ;
    Nand2 reg_nx9854 (.OUT (nx9854), .A (nx11589), .B (nx11593)) ;
    Inv ix12276 (.OUT (nx11594), .A (U_analog_control_cal_state_0__XX0_XREP179)
        ) ;
    Nor2 reg_nx4482 (.OUT (nx4482), .A (nx9848_XX0_XREP179), .B (nx9952)) ;
    Nor2 ix12277 (.OUT (nx11595), .A (nx11594), .B (nx4482)) ;
    Nand3 ix12278 (.OUT (nx11596), .A (nx11642), .B (nx11628), .C (nx11595)) ;
    BufI4 ix12279 (.OUT (nx11597), .A (nx12108)) ;
    BufI4 ix12280 (.OUT (nx11598), .A (nx12108)) ;
    AOI22 ix12281 (.OUT (nx11599), .A (nx9848_XX0_XREP179), .B (nx11597), .C (
          nx9952), .D (nx11598)) ;
    Inv ix12282 (.OUT (nx11600), .A (nx11599)) ;
    Nand2 ix12283 (.OUT (nx11601), .A (nx11628), .B (nx11600)) ;
    Nand2 reg_nx10949 (.OUT (nx10949), .A (
          U_analog_control_cal_state_0__XX0_XREP179), .B (nx11642)) ;
    Nand2 ix12284 (.OUT (nx11602), .A (nx12108), .B (nx10949)) ;
    Nand2 ix12285 (.OUT (nx11603), .A (nx9975), .B (nx11628)) ;
    Inv ix12286 (.OUT (nx11604), .A (nx11603)) ;
    Nand2 ix12287 (.OUT (nx11605), .A (nx11602), .B (nx11604)) ;
    Nor3 ix12288 (.OUT (nx11606), .A (nx9867), .B (nx9949), .C (nx11605)) ;
    Inv ix12289 (.OUT (nx11607), .A (nx11606)) ;
    Inv ix12290 (.OUT (nx11608), .A (nx9975)) ;
    Nand2 ix12291 (.OUT (nx11609), .A (nx11628), .B (nx11608)) ;
    Inv ix12292 (.OUT (nx11610), .A (nx11609)) ;
    Nand2 ix12293 (.OUT (nx11611), .A (nx11602), .B (nx11610)) ;
    Nor2 ix12294 (.OUT (nx11612), .A (nx9949), .B (nx11611)) ;
    AOI22 ix12295 (.OUT (nx11613), .A (U_analog_control_cal_cnt_11), .B (nx9949)
          , .C (nx11658), .D (nx11612)) ;
    Nand2 reg_nx7329 (.OUT (nx7329), .A (nx11607), .B (nx11613)) ;
    BufI4 ix12296 (.OUT (nx11614), .A (nx12108)) ;
    Nor2 ix12297 (.OUT (nx11615), .A (nx11614), .B (
         U_analog_control_cal_state_0__XX0_XREP179)) ;
    Nor2 ix12298 (.OUT (nx11616), .A (nx11615), .B (nx4502)) ;
    Inv ix12299 (.OUT (nx11617), .A (nx10947)) ;
    Nor3 ix12300 (.OUT (nx11618), .A (U_analog_control_cal_cnt_5), .B (
         U_analog_control_cal_cnt_6), .C (nx9923)) ;
    Nand4 ix12301 (.OUT (nx11619), .A (nx11617), .B (nx11618), .C (nx4512), .D (
          nx4534)) ;
    Inv ix12302 (.OUT (nx11620), .A (nx11615)) ;
    Nand2 ix12303 (.OUT (nx11621), .A (nx11619), .B (nx11620)) ;
    Inv ix12304 (.OUT (nx11622), .A (nx11621)) ;
    Nor2 ix12305 (.OUT (nx11623), .A (nx11616), .B (nx11622)) ;
    BufI4 ix12306 (.OUT (nx11624), .A (nx11623)) ;
    Nand2 ix12307 (.OUT (nx11625), .A (nx11617), .B (nx11618)) ;
    Nand2 ix12308 (.OUT (nx11626), .A (nx4512), .B (nx4534)) ;
    Nor2 ix12309 (.OUT (nx11627), .A (nx11625), .B (nx11626)) ;
    Nand2 ix12310 (.OUT (nx11628), .A (nx4502), .B (nx11627)) ;
    Inv ix12311 (.OUT (nx11629), .A (nx11618)) ;
    Nor2 reg_nx4524 (.OUT (nx4524), .A (nx10947), .B (nx11629)) ;
    Nor2 ix12312 (.OUT (nx11630), .A (nx9240), .B (nx9252)) ;
    Nand3 ix12313 (.OUT (nx11631), .A (U_analog_control_sub_cnt_0__XX0_XREP147)
          , .B (U_analog_control_sub_cnt_4), .C (nx11630)) ;
    Nand2 ix12314 (.OUT (nx11632), .A (U_analog_control_sub_cnt_2__XX0_XREP143)
          , .B (U_analog_control_sub_cnt_1__XX0_XREP145)) ;
    Nor2 reg_nx3212 (.OUT (nx3212), .A (nx11631), .B (nx11632)) ;
    Inv ix12315 (.OUT (nx11633), .A (nx11632)) ;
    Inv ix12316 (.OUT (nx11634), .A (nx9252)) ;
    Nand3 ix12317 (.OUT (nx11635), .A (U_analog_control_sub_cnt_0__XX0_XREP147)
          , .B (U_analog_control_sub_cnt_4), .C (nx11634)) ;
    Inv ix12318 (.OUT (nx11636), .A (nx11635)) ;
    Nand2 reg_nx9464 (.OUT (nx9464), .A (nx11633), .B (nx11636)) ;
    Nand2 ix12319 (.OUT (nx11637), .A (U_analog_control_sub_cnt_1__XX0_XREP145)
          , .B (U_analog_control_sub_cnt_0__XX0_XREP147)) ;
    Inv ix12320 (.OUT (nx11638), .A (nx9252)) ;
    Nand2 ix12321 (.OUT (nx11639), .A (U_analog_control_sub_cnt_2__XX0_XREP143)
          , .B (nx11638)) ;
    Nor2 reg_nx3183 (.OUT (nx3183), .A (nx11637), .B (nx11639)) ;
    Nand3 reg_nx9460 (.OUT (nx9460), .A (U_analog_control_sub_cnt_0__XX0_XREP147
          ), .B (U_analog_control_sub_cnt_2__XX0_XREP143), .C (
          U_analog_control_sub_cnt_1__XX0_XREP145)) ;
    Inv ix12322 (.OUT (nx11640), .A (nx12010)) ;
    Nand3 ix12323 (.OUT (nx11641), .A (nx11586), .B (nx11588), .C (nx11640)) ;
    Nand3 ix12324 (.OUT (nx11642), .A (nx11586), .B (nx11588), .C (nx12025)) ;
    Nand2 ix12325 (.OUT (nx11643), .A (nx12025), .B (nx11586)) ;
    Inv ix12326 (.OUT (nx11644), .A (nx11596)) ;
    Nor2 ix12327 (.OUT (nx11645), .A (U_analog_control_cal_cnt_10), .B (nx9875)
         ) ;
    Nand4 ix12328 (.OUT (nx11646), .A (nx11601), .B (nx11645), .C (nx11641), .D (
          nx11624)) ;
    Nor3 ix12329 (.OUT (nx11647), .A (nx9968), .B (nx11644), .C (nx11646)) ;
    Inv ix12330 (.OUT (nx11648), .A (nx11647)) ;
    Nand3 ix12331 (.OUT (nx11649), .A (U_analog_control_cal_cnt_10), .B (nx11641
          ), .C (nx11624)) ;
    Inv ix12332 (.OUT (nx11650), .A (nx11649)) ;
    Nand2 ix12333 (.OUT (nx11651), .A (nx9968), .B (nx11650)) ;
    BufI4 ix12334 (.OUT (nx11652), .A (nx12110)) ;
    Nand2 ix12335 (.OUT (nx11653), .A (U_analog_control_cal_cnt_10), .B (nx9875)
          ) ;
    Inv ix12336 (.OUT (nx11654), .A (nx11653)) ;
    Nand2 reg_nx9949 (.OUT (nx9949), .A (nx11596), .B (nx11601)) ;
    AOI22 ix12337 (.OUT (nx11655), .A (nx11652), .B (nx11654), .C (
          U_analog_control_cal_cnt_10), .D (nx9949)) ;
    Nand3 reg_nx7319 (.OUT (nx7319), .A (nx11648), .B (nx11651), .C (nx11655)) ;
    Nor2 reg_nx3265 (.OUT (nx3265), .A (nx9968), .B (nx9875)) ;
    Inv ix12338 (.OUT (nx11656), .A (U_analog_control_cal_cnt_10)) ;
    Nor3 ix12339 (.OUT (nx11657), .A (nx9968), .B (nx11656), .C (nx9875)) ;
    Inv reg_nx9867 (.OUT (nx9867), .A (nx11657)) ;
    Inv ix12340 (.OUT (nx11658), .A (nx11657)) ;
    Nor3 ix12341 (.OUT (nx11659), .A (U_command_control_int_hdr_data_20), .B (
         nx10745_XX0_XREP37), .C (U_command_control_int_hdr_data_15__XX0_XREP3)
         ) ;
    Nor2 ix12342 (.OUT (nx11660), .A (U_command_control_int_hdr_data_18), .B (
         U_command_control_int_hdr_data_19)) ;
    Nand2 ix12343 (.OUT (nx11661), .A (nx11659), .B (nx11660)) ;
    Nor2 ix12344 (.OUT (nx11662), .A (
         U_command_control_int_hdr_data_17__XX0_XREP39), .B (nx11661)) ;
    Nand2 ix12345 (.OUT (nx11663), .A (nx1040), .B (nx11662)) ;
    Nand2 ix12346 (.OUT (nx11664), .A (tc2_data_0), .B (nx1050)) ;
    Nand2 ix12347 (.OUT (nx11665), .A (tc3_data_0), .B (nx418_XX0_XREP45)) ;
    Nand2 ix12348 (.OUT (nx11666), .A (nx11664), .B (nx11665)) ;
    Nor2 ix12349 (.OUT (nx11667), .A (U_command_control_int_hdr_data_20), .B (
         U_command_control_int_hdr_data_19)) ;
    Inv ix12350 (.OUT (nx11668), .A (nx11667)) ;
    Inv ix12351 (.OUT (nx11669), .A (nx7563)) ;
    Nor2 ix12352 (.OUT (nx11670), .A (nx11669), .B (
         U_command_control_int_hdr_data_18)) ;
    Nand2 ix12353 (.OUT (nx11671), .A (
          U_command_control_int_hdr_data_17__XX0_XREP39), .B (nx11670)) ;
    Nor2 ix12354 (.OUT (nx11672), .A (nx11668), .B (nx11671)) ;
    BufI4 ix12355 (.OUT (nx11673), .A (nx10745_XX0_XREP37)) ;
    Nor2 ix12356 (.OUT (nx11674), .A (nx11673), .B (
         U_command_control_int_hdr_data_18)) ;
    Nand2 ix12357 (.OUT (nx11675), .A (nx11667), .B (nx11674)) ;
    Inv ix12358 (.OUT (nx11676), .A (nx11675)) ;
    Nand2 ix12359 (.OUT (nx11677), .A (nx1572), .B (nx11676)) ;
    Inv ix12360 (.OUT (nx11678), .A (nx11661)) ;
    Nand2 ix12361 (.OUT (nx11679), .A (nx1864), .B (nx11678)) ;
    Nand2 ix12362 (.OUT (nx11680), .A (nx11677), .B (nx11679)) ;
    AOI22 ix12363 (.OUT (nx11681), .A (nx11666), .B (nx11672), .C (
          U_command_control_int_hdr_data_17__XX0_XREP39), .D (nx11680)) ;
    Nand2 reg_nx2164 (.OUT (nx2164), .A (nx11663), .B (nx11681)) ;
    Nor2 ix12364 (.OUT (nx11682), .A (nx9907), .B (nx9923)) ;
    Nand3 ix12365 (.OUT (nx11683), .A (U_analog_control_cal_cnt_0), .B (
          U_analog_control_cal_cnt_4), .C (nx11682)) ;
    Nand2 ix12366 (.OUT (nx11684), .A (U_analog_control_cal_cnt_2), .B (
          U_analog_control_cal_cnt_1)) ;
    Nor2 reg_nx3257 (.OUT (nx3257), .A (nx11683), .B (nx11684)) ;
    Inv ix12367 (.OUT (nx11685), .A (nx11684)) ;
    Inv ix12368 (.OUT (nx11686), .A (nx9923)) ;
    Nand3 ix12369 (.OUT (nx11687), .A (U_analog_control_cal_cnt_0), .B (
          U_analog_control_cal_cnt_4), .C (nx11686)) ;
    Inv ix12370 (.OUT (nx11688), .A (nx11687)) ;
    Nand2 reg_nx9960 (.OUT (nx9960), .A (nx11685), .B (nx11688)) ;
    Nand2 ix12371 (.OUT (nx11689), .A (U_analog_control_cal_cnt_1), .B (
          U_analog_control_cal_cnt_0)) ;
    Inv ix12372 (.OUT (nx11690), .A (nx9923)) ;
    Nand2 ix12373 (.OUT (nx11691), .A (U_analog_control_cal_cnt_2), .B (nx11690)
          ) ;
    Nor2 reg_nx3255 (.OUT (nx3255), .A (nx11689), .B (nx11691)) ;
    Nand3 reg_nx9956 (.OUT (nx9956), .A (U_analog_control_cal_cnt_0), .B (
          U_analog_control_cal_cnt_2), .C (U_analog_control_cal_cnt_1)) ;
    Nand2 reg_nx3482 (.OUT (nx3482), .A (nx3478), .B (
          nx8876_XX0_XREP89_XX0_XREP303)) ;
    Nand2 ix12374 (.OUT (nx11692), .A (nx3388), .B (nx3482)) ;
    Inv ix12375 (.OUT (nx11693), .A (nx8876_XX0_XREP89)) ;
    Nor2 ix12376 (.OUT (nx11694), .A (nx11693), .B (nx3494)) ;
    BufI4 ix12377 (.OUT (nx11695), .A (nx11694)) ;
    Inv reg_nx8903 (.OUT (nx8903), .A (nx3494)) ;
    AOI22 ix12378 (.OUT (nx11696), .A (nx3478), .B (
          nx8876_XX0_XREP89_XX0_XREP303), .C (nx8876_XX0_XREP89), .D (nx8903)) ;
    AOI22 ix12379 (.OUT (nx11697), .A (nx3192), .B (nx11695), .C (nx3384), .D (
          nx11696)) ;
    Inv ix12380 (.OUT (nx11698), .A (
        U_readout_control_typ_cnt_3__XX0_XREP89_XX0_XREP303)) ;
    Nor2 ix12381 (.OUT (nx11699), .A (nx11698), .B (nx3494)) ;
    Inv ix12382 (.OUT (nx11700), .A (nx11699)) ;
    Nand2 ix12383 (.OUT (nx11701), .A (nx11700), .B (nx9186)) ;
    Nor2 ix12384 (.OUT (nx11702), .A (nx11697), .B (nx11701)) ;
    Nand2 reg_nx3231_XX0_XREP109 (.OUT (nx3231_XX0_XREP109), .A (nx11692), .B (
          nx11702)) ;
    Inv ix12385 (.OUT (nx11703), .A (nx11699)) ;
    Nand3 ix12386 (.OUT (nx11704), .A (nx11703), .B (nx3478), .C (
          nx8876_XX0_XREP89_XX0_XREP303)) ;
    BufI4 ix12387 (.OUT (nx11705), .A (nx11699)) ;
    BufI4 ix12388 (.OUT (nx11706), .A (nx3388)) ;
    Nor2 ix12389 (.OUT (nx11707), .A (nx11693), .B (nx8883)) ;
    Inv ix12390 (.OUT (nx11708), .A (nx11707)) ;
    Inv ix12391 (.OUT (nx11709), .A (nx8876_XX0_XREP89)) ;
    Nand2 ix12392 (.OUT (nx11710), .A (nx8883), .B (nx11709)) ;
    AOI22 ix12393 (.OUT (nx11711), .A (nx8905), .B (nx3233), .C (nx11708), .D (
          nx11710)) ;
    Nand3 ix12394 (.OUT (nx11712), .A (nx3231_XX0_XREP109), .B (nx8901), .C (
          nx11711)) ;
    Nand3 ix12395 (.OUT (nx11713), .A (U_readout_control_typ_cnt_3__XX0_XREP89)
          , .B (nx11692), .C (nx11702)) ;
    Nand2 reg_nx7159 (.OUT (nx7159), .A (nx11712), .B (nx11713)) ;
    Nand2 ix12396 (.OUT (nx11714), .A (nx3384), .B (nx11696)) ;
    Nand2 ix12397 (.OUT (nx11715), .A (nx3192), .B (nx11695)) ;
    Nand2 reg_nx9190 (.OUT (nx9190), .A (nx11714), .B (nx11715)) ;
    Inv ix12398 (.OUT (nx11716), .A (nx3494)) ;
    BufI4 ix12399 (.OUT (nx11717), .A (nx10425)) ;
    BufI4 ix12400 (.OUT (nx11718), .A (nx10447)) ;
    Inv ix12401 (.OUT (nx11719), .A (nx10445)) ;
    Inv ix12402 (.OUT (nx11720), .A (nx10961)) ;
    Inv ix12403 (.OUT (nx11721), .A (tc1_data_0)) ;
    AOI22 ix12404 (.OUT (nx11722), .A (tc1_data_0), .B (nx11720), .C (nx10961), 
          .D (nx11721)) ;
    Inv ix12405 (.OUT (nx11723), .A (tc1_data_1)) ;
    Nand2 ix12406 (.OUT (nx11724), .A (nx10965), .B (nx11723)) ;
    Inv ix12407 (.OUT (nx11725), .A (tc1_data_1)) ;
    Nor2 ix12408 (.OUT (nx11726), .A (nx11725), .B (nx10965)) ;
    Inv ix12409 (.OUT (nx11727), .A (nx11726)) ;
    Nand2 ix12410 (.OUT (nx11728), .A (nx11724), .B (nx11727)) ;
    Inv ix12411 (.OUT (nx11729), .A (tc1_data_9)) ;
    Nand2 ix12412 (.OUT (nx11730), .A (nx10981), .B (nx11729)) ;
    Inv ix12413 (.OUT (nx11731), .A (nx10981)) ;
    Nand2 ix12414 (.OUT (nx11732), .A (tc1_data_9), .B (nx11731)) ;
    Inv ix12415 (.OUT (nx11733), .A (tc1_data_7)) ;
    Nand2 ix12416 (.OUT (nx11734), .A (nx10977), .B (nx11733)) ;
    Inv ix12417 (.OUT (nx11735), .A (nx10977)) ;
    Nand2 ix12418 (.OUT (nx11736), .A (tc1_data_7), .B (nx11735)) ;
    AOI22 ix12419 (.OUT (nx11737), .A (nx11730), .B (nx11732), .C (nx11734), .D (
          nx11736)) ;
    Inv ix12420 (.OUT (nx11738), .A (nx10985)) ;
    Inv ix12421 (.OUT (nx11739), .A (tc1_data_11)) ;
    AOI22 ix12422 (.OUT (nx11740), .A (tc1_data_11), .B (nx11738), .C (nx10985)
          , .D (nx11739)) ;
    Inv ix12423 (.OUT (nx11741), .A (nx10969)) ;
    Inv ix12424 (.OUT (nx11742), .A (tc1_data_3)) ;
    AOI22 ix12425 (.OUT (nx11743), .A (tc1_data_3), .B (nx11741), .C (nx10969), 
          .D (nx11742)) ;
    Inv ix12426 (.OUT (nx11744), .A (nx10973)) ;
    Inv ix12427 (.OUT (nx11745), .A (tc1_data_5)) ;
    AOI22 ix12428 (.OUT (nx11746), .A (tc1_data_5), .B (nx11744), .C (nx10973), 
          .D (nx11745)) ;
    Nor3 ix12429 (.OUT (nx11747), .A (nx11740), .B (nx11743), .C (nx11746)) ;
    Nand3 ix12430 (.OUT (nx11748), .A (nx11728), .B (nx11737), .C (nx11747)) ;
    Nor3 ix12431 (.OUT (nx11749), .A (nx11719), .B (nx11722), .C (nx11748)) ;
    Nand4 ix12432 (.OUT (nx11750), .A (nx10429), .B (nx10438), .C (nx10434), .D (
          nx11749)) ;
    Nor3 ix12433 (.OUT (nx11751), .A (nx11717), .B (nx11718), .C (nx11750)) ;
    Nand4 reg_NOT_nx10413 (.OUT (NOT_nx10413), .A (nx10443), .B (nx10449), .C (
          nx10420), .D (nx11751)) ;
    BufI4 ix12434 (.OUT (nx11752), .A (nx10482)) ;
    BufI4 ix12435 (.OUT (nx11753), .A (nx10458)) ;
    BufI4 ix12436 (.OUT (nx11754), .A (nx10478)) ;
    BufI4 ix12437 (.OUT (nx11755), .A (nx10470)) ;
    BufI4 ix12438 (.OUT (nx11756), .A (nx10486)) ;
    Inv ix12439 (.OUT (nx11757), .A (tc1_data_29)) ;
    Nand2 ix12440 (.OUT (nx11758), .A (nx10989), .B (nx11757)) ;
    Inv ix12441 (.OUT (nx11759), .A (nx10989)) ;
    Nand2 ix12442 (.OUT (nx11760), .A (tc1_data_29), .B (nx11759)) ;
    Nand2 reg_nx10460 (.OUT (nx10460), .A (nx11758), .B (nx11760)) ;
    Nand2 ix12443 (.OUT (nx11761), .A (nx10973), .B (nx10977)) ;
    Nor3 ix12444 (.OUT (nx11762), .A (tc1_data_21), .B (tc1_data_23), .C (
         nx11761)) ;
    Inv ix12445 (.OUT (nx11763), .A (nx11762)) ;
    Inv ix12446 (.OUT (nx11764), .A (tc1_data_21)) ;
    Inv ix12447 (.OUT (nx11765), .A (nx10977)) ;
    Nand4 ix12448 (.OUT (nx11766), .A (nx11764), .B (tc1_data_23), .C (nx10973)
          , .D (nx11765)) ;
    Inv ix12449 (.OUT (nx11767), .A (tc1_data_23)) ;
    Inv ix12450 (.OUT (nx11768), .A (nx10973)) ;
    Nand4 ix12451 (.OUT (nx11769), .A (tc1_data_21), .B (nx11767), .C (nx10977)
          , .D (nx11768)) ;
    Nor2 ix12452 (.OUT (nx11770), .A (nx10977), .B (nx10973)) ;
    Nand3 ix12453 (.OUT (nx11771), .A (tc1_data_21), .B (tc1_data_23), .C (
          nx11770)) ;
    Nand4 ix12454 (.OUT (nx11772), .A (nx11763), .B (nx11766), .C (nx11769), .D (
          nx11771)) ;
    Nand4 ix12455 (.OUT (nx11773), .A (nx10490), .B (nx10466), .C (nx10460), .D (
          nx11772)) ;
    Nor3 ix12456 (.OUT (nx11774), .A (nx11755), .B (nx11756), .C (nx11773)) ;
    Nand4 ix12457 (.OUT (nx11775), .A (nx10472), .B (nx10468), .C (nx10492), .D (
          nx11774)) ;
    Nor4 ix12458 (.OUT (nx11776), .A (nx11752), .B (nx11753), .C (nx11754), .D (
         nx11775)) ;
    Nand4 ix12459 (.OUT (nx11777), .A (nx10462), .B (nx10456), .C (nx10488), .D (
          nx11776)) ;
    Inv ix12460 (.OUT (nx11778), .A (leakage_null)) ;
    Nand2 ix12461 (.OUT (nx11779), .A (nx11777), .B (nx11778)) ;
    Nand2 ix12462 (.OUT (nx11780), .A (NOT_nx10413), .B (nx11779)) ;
    Nand2 reg_nx7369 (.OUT (nx7369), .A (nx11780), .B (nx12094)) ;
    Inv ix12463 (.OUT (nx11781), .A (nx10328)) ;
    Nand2 ix12464 (.OUT (nx11782), .A (nx5494), .B (nx11781)) ;
    BufI4 ix12465 (.OUT (nx11783), .A (nx12094)) ;
    Nand2 ix12466 (.OUT (nx11784), .A (nx10328), .B (nx11783)) ;
    Inv ix12467 (.OUT (nx11785), .A (offset_null)) ;
    BufI4 ix12468 (.OUT (nx11786), .A (nx9283)) ;
    Nand2 ix12469 (.OUT (nx11787), .A (nx11785), .B (nx11786)) ;
    Inv ix12470 (.OUT (nx11788), .A (nx10328)) ;
    Nand2 ix12471 (.OUT (nx11789), .A (nx11787), .B (nx11788)) ;
    Nand3 reg_nx7379 (.OUT (nx7379), .A (nx11782), .B (nx11784), .C (nx11789)) ;
    BufI4 ix12472 (.OUT (nx11790), .A (nx11705)) ;
    AOI22 ix12473 (.OUT (nx11791), .A (nx8905), .B (nx3233), .C (nx11704), .D (
          nx11790)) ;
    Nand2 ix12474 (.OUT (nx11792), .A (nx9190), .B (nx11791)) ;
    Inv ix12475 (.OUT (nx11793), .A (nx11792)) ;
    Nand2 ix12476 (.OUT (nx11794), .A (nx11705), .B (nx11706)) ;
    Nand2 reg_nx8901 (.OUT (nx8901), .A (nx11704), .B (nx11794)) ;
    Nand2 reg_nx9186 (.OUT (nx9186), .A (nx8905), .B (nx3233)) ;
    Inv ix12477 (.OUT (nx11795), .A (U_readout_control_typ_cnt_0)) ;
    Nand2 ix12478 (.OUT (nx11796), .A (nx9186), .B (nx11795)) ;
    Inv ix12479 (.OUT (nx11797), .A (nx11796)) ;
    Nand2 ix12480 (.OUT (nx11798), .A (nx8901), .B (nx11797)) ;
    Inv ix12481 (.OUT (nx11799), .A (nx11798)) ;
    Nand2 ix12482 (.OUT (nx11800), .A (nx3231), .B (nx11799)) ;
    Nand4 ix12483 (.OUT (nx11801), .A (U_readout_control_typ_cnt_0), .B (nx12084
          ), .C (nx9190), .D (nx11791)) ;
    Nand2 reg_nx7079 (.OUT (nx7079), .A (nx11800), .B (nx11801)) ;
    Nand2 ix12484 (.OUT (nx11802), .A (nx11705), .B (nx9186)) ;
    Inv ix12485 (.OUT (nx11803), .A (nx11802)) ;
    Nand2 ix12486 (.OUT (nx11804), .A (nx11706), .B (nx11803)) ;
    Inv ix12487 (.OUT (nx11805), .A (nx11704)) ;
    Nand2 ix12488 (.OUT (nx11806), .A (nx9186), .B (nx11805)) ;
    Nand2 reg_nx8873 (.OUT (nx8873), .A (nx11804), .B (nx11806)) ;
    Nand2 ix12489 (.OUT (nx11807), .A (U_analog_control_mst_cnt_2), .B (
          U_analog_control_mst_cnt_4)) ;
    Inv ix12490 (.OUT (nx11808), .A (U_analog_control_mst_cnt_6)) ;
    BufI4 ix12491 (.OUT (nx11809), .A (nx12098)) ;
    Nor2 ix12492 (.OUT (nx11810), .A (nx9649), .B (nx12096)) ;
    Nand4 ix12493 (.OUT (nx11811), .A (nx10805), .B (nx10797), .C (nx11809), .D (
          nx11810)) ;
    Nor3 reg_nx3273 (.OUT (nx3273), .A (nx11807), .B (nx11808), .C (nx11811)) ;
    BufI4 reg_nx10975 (.OUT (nx10975), .A (nx10797)) ;
    Nor3 ix12494 (.OUT (nx11812), .A (nx12098), .B (nx9649), .C (nx12096)) ;
    Nand2 ix12495 (.OUT (nx11813), .A (nx10805), .B (nx11812)) ;
    Inv ix12496 (.OUT (nx11814), .A (nx11813)) ;
    Nand4 reg_nx9696 (.OUT (nx9696), .A (U_analog_control_mst_cnt_6), .B (
          U_analog_control_mst_cnt_4), .C (U_analog_control_mst_cnt_2), .D (
          nx11814)) ;
    Nand4 ix12497 (.OUT (nx11815), .A (U_analog_control_mst_cnt_4), .B (
          U_analog_control_mst_cnt_2), .C (nx10805), .D (nx11812)) ;
    Inv reg_nx3271 (.OUT (nx3271), .A (nx11815)) ;
    BufI4 reg_nx10971 (.OUT (nx10971), .A (nx10805)) ;
    Nand3 reg_nx9674 (.OUT (nx9674), .A (U_analog_control_mst_cnt_4), .B (
          U_analog_control_mst_cnt_2), .C (nx11812)) ;
    BufI4 reg_nx10813 (.OUT (nx10813), .A (nx9649)) ;
    Nor2 ix12498 (.OUT (nx11816), .A (nx12098), .B (nx12096)) ;
    BufI4 ix12499 (.OUT (nx11817), .A (nx10194)) ;
    BufI4 ix12500 (.OUT (nx11818), .A (nx10174)) ;
    BufI4 ix12501 (.OUT (nx11819), .A (nx10170)) ;
    BufI4 ix12502 (.OUT (nx11820), .A (nx10167)) ;
    BufI4 ix12503 (.OUT (nx11821), .A (nx10769_XX0_XREP173)) ;
    Inv ix12504 (.OUT (nx11822), .A (tc4_data_14)) ;
    AOI22 ix12505 (.OUT (nx11823), .A (nx10769_XX0_XREP173), .B (tc4_data_14), .C (
          nx11821), .D (nx11822)) ;
    Inv ix12506 (.OUT (nx11824), .A (tc4_data_13)) ;
    Nand2 ix12507 (.OUT (nx11825), .A (nx12111), .B (nx11824)) ;
    BufI4 ix12508 (.OUT (nx11826), .A (nx12111)) ;
    Nand2 ix12509 (.OUT (nx11827), .A (tc4_data_13), .B (nx11826)) ;
    Nand2 reg_nx10190 (.OUT (nx10190), .A (nx11825), .B (nx11827)) ;
    BufI4 ix12510 (.OUT (nx11828), .A (nx12102)) ;
    Inv ix12511 (.OUT (nx11829), .A (tc4_data_11)) ;
    AOI22 ix12512 (.OUT (nx11830), .A (tc4_data_11), .B (nx11828), .C (nx12102)
          , .D (nx11829)) ;
    BufI4 ix12513 (.OUT (nx11831), .A (nx12099)) ;
    Inv ix12514 (.OUT (nx11832), .A (tc4_data_9)) ;
    AOI22 ix12515 (.OUT (nx11833), .A (tc4_data_9), .B (nx11831), .C (nx12100), 
          .D (nx11832)) ;
    Inv ix12516 (.OUT (nx11834), .A (tc4_data_7)) ;
    Nand2 ix12517 (.OUT (nx11835), .A (nx12113), .B (nx11834)) ;
    BufI4 ix12518 (.OUT (nx11836), .A (nx12114)) ;
    Nand2 ix12519 (.OUT (nx11837), .A (tc4_data_7), .B (nx11836)) ;
    Nand2 ix12520 (.OUT (nx11838), .A (nx11835), .B (nx11837)) ;
    Inv ix12521 (.OUT (nx11839), .A (tc4_data_5)) ;
    Nand2 ix12522 (.OUT (nx11840), .A (nx12115), .B (nx11839)) ;
    BufI4 ix12523 (.OUT (nx11841), .A (nx12116)) ;
    Nand2 ix12524 (.OUT (nx11842), .A (tc4_data_5), .B (nx11841)) ;
    Nand2 ix12525 (.OUT (nx11843), .A (nx11840), .B (nx11842)) ;
    Nand2 ix12526 (.OUT (nx11844), .A (nx11838), .B (nx11843)) ;
    Nor3 ix12527 (.OUT (nx11845), .A (nx11830), .B (nx11833), .C (nx11844)) ;
    Nand4 ix12528 (.OUT (nx11846), .A (nx10161), .B (nx10163), .C (nx10190), .D (
          nx11845)) ;
    Nor3 ix12529 (.OUT (nx11847), .A (nx11820), .B (nx11823), .C (nx11846)) ;
    Nand4 ix12530 (.OUT (nx11848), .A (nx10183), .B (nx10179), .C (nx10165), .D (
          nx11847)) ;
    Nor4 ix12531 (.OUT (nx11849), .A (nx11817), .B (nx11818), .C (nx11819), .D (
         nx11848)) ;
    Nand2 reg_NOT_nx10158 (.OUT (NOT_nx10158), .A (nx10188), .B (nx11849)) ;
    BufI4 ix12532 (.OUT (nx11850), .A (nx10233)) ;
    BufI4 ix12533 (.OUT (nx11851), .A (nx10217)) ;
    Nand2 ix12534 (.OUT (nx11852), .A (nx10225), .B (nx10231)) ;
    BufI4 ix12535 (.OUT (nx11853), .A (nx10237)) ;
    Inv ix12536 (.OUT (nx11854), .A (tc4_data_29)) ;
    Nand2 ix12537 (.OUT (nx11855), .A (nx12112), .B (nx11854)) ;
    BufI4 ix12538 (.OUT (nx11856), .A (nx12112)) ;
    Nand2 ix12539 (.OUT (nx11857), .A (tc4_data_29), .B (nx11856)) ;
    Nand2 reg_nx10205 (.OUT (nx10205), .A (nx11855), .B (nx11857)) ;
    Inv ix12540 (.OUT (nx11858), .A (tc4_data_27)) ;
    Nand2 ix12541 (.OUT (nx11859), .A (nx12102), .B (nx11858)) ;
    Inv ix12542 (.OUT (nx11860), .A (nx11859)) ;
    Inv ix12543 (.OUT (nx11861), .A (tc4_data_27)) ;
    Nor2 ix12544 (.OUT (nx11862), .A (nx11861), .B (nx12102)) ;
    Nor2 ix12545 (.OUT (nx11863), .A (nx11860), .B (nx11862)) ;
    BufI4 ix12546 (.OUT (nx11864), .A (nx12100)) ;
    Inv ix12547 (.OUT (nx11865), .A (tc4_data_25)) ;
    AOI22 ix12548 (.OUT (nx11866), .A (tc4_data_25), .B (nx11864), .C (nx12100)
          , .D (nx11865)) ;
    Nor2 ix12549 (.OUT (nx11867), .A (nx11863), .B (nx11866)) ;
    Nand4 ix12550 (.OUT (nx11868), .A (nx10221), .B (nx10235), .C (nx10205), .D (
          nx11867)) ;
    Nor3 ix12551 (.OUT (nx11869), .A (nx11852), .B (nx11853), .C (nx11868)) ;
    Nand4 ix12552 (.OUT (nx11870), .A (nx10213), .B (nx10223), .C (nx10227), .D (
          nx11869)) ;
    Nor3 ix12553 (.OUT (nx11871), .A (nx11850), .B (nx11851), .C (nx11870)) ;
    Nand4 ix12554 (.OUT (nx11872), .A (nx10207), .B (nx10201), .C (nx10203), .D (
          nx11871)) ;
    Inv ix12555 (.OUT (nx11873), .A (trig_inh)) ;
    Nand2 ix12556 (.OUT (nx11874), .A (nx11872), .B (nx11873)) ;
    Nand2 ix12557 (.OUT (nx11875), .A (NOT_nx10158), .B (nx11874)) ;
    Nand2 reg_nx7399 (.OUT (nx7399), .A (nx11875), .B (nx12094)) ;
    BufI4 ix12558 (.OUT (nx11876), .A (nx10250)) ;
    BufI4 ix12559 (.OUT (nx11877), .A (nx10268)) ;
    BufI4 ix12560 (.OUT (nx11878), .A (nx10769_XX0_XREP173)) ;
    Inv ix12561 (.OUT (nx11879), .A (tc3_data_14)) ;
    AOI22 ix12562 (.OUT (nx11880), .A (nx10769_XX0_XREP173), .B (tc3_data_14), .C (
          nx11878), .D (nx11879)) ;
    Inv reg_nx10277 (.OUT (nx10277), .A (nx11880)) ;
    Inv ix12563 (.OUT (nx11881), .A (tc3_data_13)) ;
    Nand2 ix12564 (.OUT (nx11882), .A (nx12112), .B (nx11881)) ;
    BufI4 ix12565 (.OUT (nx11883), .A (nx12112)) ;
    Nand2 ix12566 (.OUT (nx11884), .A (tc3_data_13), .B (nx11883)) ;
    Nand2 reg_nx10275 (.OUT (nx10275), .A (nx11882), .B (nx11884)) ;
    Inv ix12567 (.OUT (nx11885), .A (tc3_data_9)) ;
    Nand2 ix12568 (.OUT (nx11886), .A (nx12100), .B (nx11885)) ;
    BufI4 ix12569 (.OUT (nx11887), .A (nx12100)) ;
    Nand2 ix12570 (.OUT (nx11888), .A (tc3_data_9), .B (nx11887)) ;
    Nand2 reg_nx10266 (.OUT (nx10266), .A (nx11886), .B (nx11888)) ;
    Inv ix12571 (.OUT (nx11889), .A (tc3_data_11)) ;
    Nand2 ix12572 (.OUT (nx11890), .A (nx12102), .B (nx11889)) ;
    BufI4 ix12573 (.OUT (nx11891), .A (nx12102)) ;
    Nand2 ix12574 (.OUT (nx11892), .A (tc3_data_11), .B (nx11891)) ;
    Nand2 reg_nx10270 (.OUT (nx10270), .A (nx11890), .B (nx11892)) ;
    Nand2 ix12575 (.OUT (nx11893), .A (nx10266), .B (nx10270)) ;
    Nor2 ix12576 (.OUT (nx11894), .A (nx12106), .B (tc3_data_15)) ;
    Nand2 ix12577 (.OUT (nx11895), .A (nx12106), .B (tc3_data_15)) ;
    Inv ix12578 (.OUT (nx11896), .A (nx11895)) ;
    Nor2 ix12579 (.OUT (nx11897), .A (nx11894), .B (nx11896)) ;
    Inv ix12580 (.OUT (nx11898), .A (tc3_data_7)) ;
    Nand2 ix12581 (.OUT (nx11899), .A (nx12114), .B (nx11898)) ;
    BufI4 ix12582 (.OUT (nx11900), .A (nx12114)) ;
    Nand2 ix12583 (.OUT (nx11901), .A (tc3_data_7), .B (nx11900)) ;
    Nand2 reg_nx10261 (.OUT (nx10261), .A (nx11899), .B (nx11901)) ;
    Inv ix12584 (.OUT (nx11902), .A (tc3_data_5)) ;
    Nand2 ix12585 (.OUT (nx11903), .A (nx12116), .B (nx11902)) ;
    Inv ix12586 (.OUT (nx11904), .A (tc3_data_5)) ;
    Nor2 ix12587 (.OUT (nx11905), .A (nx11904), .B (nx12116)) ;
    Inv ix12588 (.OUT (nx11906), .A (nx11905)) ;
    Nand2 reg_nx10257 (.OUT (nx10257), .A (nx11903), .B (nx11906)) ;
    Inv ix12589 (.OUT (nx11907), .A (tc3_data_3)) ;
    Nand2 ix12590 (.OUT (nx11908), .A (nx10967), .B (nx11907)) ;
    BufI4 ix12591 (.OUT (nx11909), .A (nx10967)) ;
    Nand2 ix12592 (.OUT (nx11910), .A (tc3_data_3), .B (nx11909)) ;
    Nand2 reg_nx10252 (.OUT (nx10252), .A (nx11908), .B (nx11910)) ;
    Nand2 ix12593 (.OUT (nx11911), .A (nx12098), .B (nx12096)) ;
    Nor3 ix12594 (.OUT (nx11912), .A (tc3_data_1), .B (tc3_data_0), .C (nx11911)
         ) ;
    Inv ix12595 (.OUT (nx11913), .A (nx11912)) ;
    Inv ix12596 (.OUT (nx11914), .A (tc3_data_1)) ;
    BufI4 ix12597 (.OUT (nx11915), .A (nx12098)) ;
    Nand4 ix12598 (.OUT (nx11916), .A (nx11914), .B (tc3_data_0), .C (nx12096), 
          .D (nx11915)) ;
    BufI4 ix12599 (.OUT (nx11917), .A (nx12098)) ;
    Nor3 ix12600 (.OUT (nx11918), .A (tc3_data_0), .B (nx11917), .C (nx12096)) ;
    Nand2 ix12601 (.OUT (nx11919), .A (tc3_data_1), .B (nx11918)) ;
    Nor2 ix12602 (.OUT (nx11920), .A (nx12098), .B (nx12096)) ;
    Nand3 ix12603 (.OUT (nx11921), .A (tc3_data_1), .B (tc3_data_0), .C (nx11920
          )) ;
    Nand4 ix12604 (.OUT (nx11922), .A (nx11913), .B (nx11916), .C (nx11919), .D (
          nx11921)) ;
    Nand4 ix12605 (.OUT (nx11923), .A (nx10261), .B (nx10257), .C (nx10252), .D (
          nx11922)) ;
    Nor3 ix12606 (.OUT (nx11924), .A (nx11893), .B (nx11897), .C (nx11923)) ;
    Nand4 ix12607 (.OUT (nx11925), .A (nx10264), .B (nx10277), .C (nx10275), .D (
          nx11924)) ;
    Nor3 ix12608 (.OUT (nx11926), .A (nx11876), .B (nx11877), .C (nx11925)) ;
    Nand4 reg_NOT_nx10243 (.OUT (NOT_nx10243), .A (nx10273), .B (nx10259), .C (
          nx10255), .D (nx11926)) ;
    BufI4 ix12609 (.OUT (nx11927), .A (nx10318)) ;
    BufI4 ix12610 (.OUT (nx11928), .A (nx10308)) ;
    BufI4 ix12611 (.OUT (nx11929), .A (nx10322)) ;
    BufI4 ix12612 (.OUT (nx11930), .A (nx10316)) ;
    Inv ix12613 (.OUT (nx11931), .A (tc3_data_29)) ;
    Nand2 ix12614 (.OUT (nx11932), .A (nx12112), .B (nx11931)) ;
    BufI4 ix12615 (.OUT (nx11933), .A (nx12112)) ;
    Nand2 ix12616 (.OUT (nx11934), .A (tc3_data_29), .B (nx11933)) ;
    Nand2 reg_nx10290 (.OUT (nx10290), .A (nx11932), .B (nx11934)) ;
    Nand2 ix12617 (.OUT (nx11935), .A (nx12116), .B (nx12114)) ;
    Nor3 ix12618 (.OUT (nx11936), .A (tc3_data_21), .B (tc3_data_23), .C (
         nx11935)) ;
    Inv ix12619 (.OUT (nx11937), .A (nx11936)) ;
    Inv ix12620 (.OUT (nx11938), .A (tc3_data_21)) ;
    BufI4 ix12621 (.OUT (nx11939), .A (nx12114)) ;
    Nand4 ix12622 (.OUT (nx11940), .A (nx11938), .B (tc3_data_23), .C (nx12116)
          , .D (nx11939)) ;
    Inv ix12623 (.OUT (nx11941), .A (tc3_data_23)) ;
    BufI4 ix12624 (.OUT (nx11942), .A (nx12116)) ;
    Nand4 ix12625 (.OUT (nx11943), .A (tc3_data_21), .B (nx11941), .C (nx12114)
          , .D (nx11942)) ;
    Nor2 ix12626 (.OUT (nx11944), .A (nx12114), .B (nx12116)) ;
    Nand3 ix12627 (.OUT (nx11945), .A (tc3_data_21), .B (tc3_data_23), .C (
          nx11944)) ;
    Nand4 ix12628 (.OUT (nx11946), .A (nx11937), .B (nx11940), .C (nx11943), .D (
          nx11945)) ;
    Inv ix12629 (.OUT (nx11947), .A (tc3_data_27)) ;
    Nand2 ix12630 (.OUT (nx11948), .A (nx12102), .B (nx11947)) ;
    Inv ix12631 (.OUT (nx11949), .A (nx11948)) ;
    Inv ix12632 (.OUT (nx11950), .A (tc3_data_27)) ;
    Nor2 ix12633 (.OUT (nx11951), .A (nx11950), .B (nx12102)) ;
    Nor2 ix12634 (.OUT (nx11952), .A (nx11949), .B (nx11951)) ;
    BufI4 ix12635 (.OUT (nx11953), .A (nx12100)) ;
    Inv ix12636 (.OUT (nx11954), .A (tc3_data_25)) ;
    AOI22 ix12637 (.OUT (nx11955), .A (tc3_data_25), .B (nx11953), .C (nx12100)
          , .D (nx11954)) ;
    Nor2 ix12638 (.OUT (nx11956), .A (nx11952), .B (nx11955)) ;
    Nand4 ix12639 (.OUT (nx11957), .A (nx10320), .B (nx10290), .C (nx11946), .D (
          nx11956)) ;
    Nor3 ix12640 (.OUT (nx11958), .A (nx11929), .B (nx11930), .C (nx11957)) ;
    Nand4 ix12641 (.OUT (nx11959), .A (nx10312), .B (nx10302), .C (nx10298), .D (
          nx11958)) ;
    Nor3 ix12642 (.OUT (nx11960), .A (nx11927), .B (nx11928), .C (nx11959)) ;
    Nand4 ix12643 (.OUT (nx11961), .A (nx10292), .B (nx10286), .C (nx10288), .D (
          nx11960)) ;
    Inv ix12644 (.OUT (nx11962), .A (thresh_off)) ;
    Nand2 ix12645 (.OUT (nx11963), .A (nx11961), .B (nx11962)) ;
    Nand2 ix12646 (.OUT (nx11964), .A (NOT_nx10243), .B (nx11963)) ;
    Nand2 reg_nx2822 (.OUT (nx2822), .A (nx9589), .B (nx9211)) ;
    Nand2 reg_nx7389 (.OUT (nx7389), .A (nx11964), .B (nx12094)) ;
    BufI4 reg_nx9283 (.OUT (nx9283), .A (nx12094)) ;
    Nor2 reg_nx3218 (.OUT (nx3218), .A (nx9356), .B (nx9358)) ;
    Inv ix12647 (.OUT (nx11965), .A (nx9402)) ;
    Nor2 ix12648 (.OUT (nx11966), .A (nx11965), .B (nx11571)) ;
    Inv ix12649 (.OUT (nx11967), .A (nx11966)) ;
    Nor2 ix12650 (.OUT (nx11968), .A (nx3218), .B (nx11967)) ;
    Nor4 ix12651 (.OUT (nx11969), .A (nx9358), .B (nx11571), .C (nx9356), .D (
         nx11567)) ;
    Nor3 reg_nx2676 (.OUT (nx2676), .A (nx10757), .B (nx11968), .C (nx11969)) ;
    Nand3 ix12652 (.OUT (nx11970), .A (nx11624), .B (nx10153), .C (nx11641)) ;
    Inv ix12653 (.OUT (nx11971), .A (nx10146)) ;
    Nor2 ix12654 (.OUT (nx11972), .A (nx11971), .B (nx11624)) ;
    Nor2 ix12655 (.OUT (nx11973), .A (nx11971), .B (nx11641)) ;
    Nor2 ix12656 (.OUT (nx11974), .A (nx11972), .B (nx11973)) ;
    Nand2 reg_nx10144 (.OUT (nx10144), .A (nx11970), .B (nx11974)) ;
    Nand2 reg_nx3251 (.OUT (nx3251), .A (nx11641), .B (nx11624)) ;
    Inv reg_nx8946 (.OUT (nx8946), .A (nx3192)) ;
    Nor2 ix12657 (.OUT (nx11975), .A (U_readout_control_int_evt_cnt_2), .B (
         U_readout_control_typ_cnt_2)) ;
    Inv ix12658 (.OUT (nx11976), .A (U_readout_control_int_evt_cnt_1)) ;
    Inv ix12659 (.OUT (nx11977), .A (nx8891)) ;
    Inv ix12660 (.OUT (nx11978), .A (nx9105)) ;
    Nand2 ix12661 (.OUT (nx11979), .A (nx11977), .B (nx11978)) ;
    Nand2 ix12662 (.OUT (nx11980), .A (nx8891), .B (nx9105)) ;
    Nand2 ix12663 (.OUT (nx11981), .A (nx11979), .B (nx11980)) ;
    Nand4 ix12664 (.OUT (nx11982), .A (nx11975), .B (nx11976), .C (sparse_en), .D (
          nx11981)) ;
    Inv ix12665 (.OUT (nx11983), .A (nx8876_XX0_XREP89_XX0_XREP303)) ;
    Inv ix12666 (.OUT (nx11984), .A (U_readout_control_int_evt_cnt_2)) ;
    Nand2 ix12667 (.OUT (nx11985), .A (U_readout_control_typ_cnt_2), .B (nx11984
          )) ;
    Inv ix12668 (.OUT (nx11986), .A (U_readout_control_int_evt_cnt_1)) ;
    Nand2 ix12669 (.OUT (nx11987), .A (sparse_en), .B (nx11981)) ;
    Nor3 ix12670 (.OUT (nx11988), .A (nx11985), .B (nx11986), .C (nx11987)) ;
    Nor2 ix12671 (.OUT (nx11989), .A (nx11983), .B (nx11988)) ;
    Nand2 reg_nx3384_XX0_XREP311 (.OUT (nx3384_XX0_XREP311), .A (nx11982), .B (
          nx11989)) ;
    Nand2 reg_nx8944_XX0_XREP531 (.OUT (nx8944_XX0_XREP531), .A (nx8946), .B (
          nx3384_XX0_XREP311)) ;
    Inv ix12672 (.OUT (nx11990), .A (nx3192)) ;
    Nor2 ix12673 (.OUT (nx11991), .A (U_readout_control_typ_cnt_2), .B (
         U_readout_control_int_evt_cnt_1)) ;
    Inv ix12674 (.OUT (nx11992), .A (nx11991)) ;
    Nand2 ix12675 (.OUT (nx11993), .A (U_readout_control_typ_cnt_2), .B (
          U_readout_control_int_evt_cnt_1)) ;
    Nand2 reg_nx9112 (.OUT (nx9112), .A (nx11992), .B (nx11993)) ;
    Nor2 ix12676 (.OUT (nx11994), .A (U_readout_control_int_evt_cnt_2), .B (
         nx8876_XX0_XREP89_XX0_XREP303)) ;
    Nand2 ix12677 (.OUT (nx11995), .A (nx8876_XX0_XREP89_XX0_XREP303), .B (
          U_readout_control_int_evt_cnt_2)) ;
    Inv ix12678 (.OUT (nx11996), .A (nx11995)) ;
    Inv ix12679 (.OUT (nx11997), .A (nx8891)) ;
    Inv ix12680 (.OUT (nx11998), .A (nx9105)) ;
    AOI22 ix12681 (.OUT (nx11999), .A (nx9105), .B (nx11997), .C (nx8891), .D (
          nx11998)) ;
    Nand2 ix12682 (.OUT (nx12000), .A (sparse_en), .B (nx11999)) ;
    Nor3 ix12683 (.OUT (nx12001), .A (nx11994), .B (nx11996), .C (nx12000)) ;
    Nand2 reg_nx8949 (.OUT (nx8949), .A (nx9112), .B (nx12001)) ;
    Nand2 ix12684 (.OUT (nx12002), .A (nx9923), .B (U_analog_control_cal_dly_3)
          ) ;
    Inv ix12685 (.OUT (nx12003), .A (nx12002)) ;
    Nor2 ix12686 (.OUT (nx12004), .A (nx9907), .B (U_analog_control_cal_dly_5)
         ) ;
    Nor2 ix12687 (.OUT (nx12005), .A (nx12003), .B (nx12004)) ;
    Nor2 ix12688 (.OUT (nx12006), .A (nx9923), .B (U_analog_control_cal_dly_3)
         ) ;
    Nand2 ix12689 (.OUT (nx12007), .A (nx9907), .B (U_analog_control_cal_dly_5)
          ) ;
    Nand2 ix12690 (.OUT (nx12008), .A (nx12108), .B (nx12007)) ;
    Nor2 ix12691 (.OUT (nx12009), .A (nx12006), .B (nx12008)) ;
    Nand2 ix12692 (.OUT (nx12010), .A (nx12005), .B (nx12009)) ;
    Nand2 ix12693 (.OUT (nx12011), .A (nx9907), .B (nx9923)) ;
    Nor3 ix12694 (.OUT (nx12012), .A (U_analog_control_cal_dly_3), .B (
         U_analog_control_cal_dly_5), .C (nx12011)) ;
    Inv ix12695 (.OUT (nx12013), .A (nx9923)) ;
    Nor2 ix12696 (.OUT (nx12014), .A (nx12013), .B (nx9907)) ;
    Nand2 ix12697 (.OUT (nx12015), .A (U_analog_control_cal_dly_5), .B (nx12014)
          ) ;
    Nor2 ix12698 (.OUT (nx12016), .A (U_analog_control_cal_dly_3), .B (nx12015)
         ) ;
    Nor2 ix12699 (.OUT (nx12017), .A (nx12012), .B (nx12016)) ;
    Inv ix12700 (.OUT (nx12018), .A (nx9907)) ;
    Nor3 ix12701 (.OUT (nx12019), .A (U_analog_control_cal_dly_5), .B (nx12018)
         , .C (nx9923)) ;
    Nand2 ix12702 (.OUT (nx12020), .A (U_analog_control_cal_dly_3), .B (nx12019)
          ) ;
    Nor2 ix12703 (.OUT (nx12021), .A (nx9923), .B (nx9907)) ;
    Nand3 ix12704 (.OUT (nx12022), .A (U_analog_control_cal_dly_3), .B (
          U_analog_control_cal_dly_5), .C (nx12021)) ;
    Nand2 ix12705 (.OUT (nx12023), .A (nx12020), .B (nx12022)) ;
    Inv ix12706 (.OUT (nx12024), .A (nx12023)) ;
    Nand2 ix12707 (.OUT (nx12025), .A (nx12017), .B (nx12024)) ;
    Nor2 reg_nx3253 (.OUT (nx3253), .A (nx9939), .B (nx9955)) ;
    Nand2 ix12708 (.OUT (nx12026), .A (nx4482), .B (nx3253)) ;
    Inv ix12709 (.OUT (nx12027), .A (nx9939)) ;
    Inv ix12710 (.OUT (nx12028), .A (nx9955)) ;
    Nand2 ix12711 (.OUT (nx12029), .A (nx12027), .B (nx12028)) ;
    Nand2 ix12712 (.OUT (nx12030), .A (U_analog_control_cal_cnt_0), .B (nx12029)
          ) ;
    Inv ix12713 (.OUT (nx12031), .A (nx12030)) ;
    AOI22 ix12714 (.OUT (nx12032), .A (U_analog_control_cal_cnt_1), .B (nx12026)
          , .C (nx4482), .D (nx12031)) ;
    Nor2 reg_nx7229 (.OUT (nx7229), .A (nx12032), .B (nx12110)) ;
    Inv ix12715 (.OUT (nx12033), .A (U_analog_control_cal_cnt_0)) ;
    Inv ix12716 (.OUT (nx12034), .A (nx4482)) ;
    AOI22 ix12717 (.OUT (nx12035), .A (nx4482), .B (nx12033), .C (
          U_analog_control_cal_cnt_0), .D (nx12034)) ;
    Nor2 reg_nx7219 (.OUT (nx7219), .A (nx12035), .B (nx12110)) ;
    Nor2 reg_nx10925 (.OUT (nx10925), .A (nx12110), .B (nx4482)) ;
    Inv ix12718 (.OUT (nx12036), .A (U_command_control_cmd_cnt_3__XX0_XREP23)) ;
    Nand2 ix12719 (.OUT (nx12037), .A (U_command_control_cmd_cnt_4), .B (nx12036
          )) ;
    Inv ix12720 (.OUT (nx12038), .A (nx7490)) ;
    Nor3 ix12721 (.OUT (nx12039), .A (U_command_control_cmd_cnt_1__XX0_XREP25), 
         .B (nx12038), .C (nx7511_XX0_XREP27)) ;
    Nand2 ix12722 (.OUT (nx12040), .A (U_command_control_cmd_cnt_2__XX0_XREP21)
          , .B (nx12039)) ;
    Nor2 reg_nx7509 (.OUT (nx7509), .A (nx12037), .B (nx12040)) ;
    Inv ix12723 (.OUT (nx12041), .A (nx7452_XX0_XREP471)) ;
    Nand2 ix12724 (.OUT (nx12042), .A (
          U_command_control_cmd_state_2__XX0_XREP465), .B (nx12041)) ;
    Nor2 ix12725 (.OUT (nx12043), .A (U_command_control_cmd_state_0), .B (
         nx12042)) ;
    Nand2 reg_nx7507 (.OUT (nx7507), .A (nx7509), .B (nx12043)) ;
    Nand2 ix12726 (.OUT (nx12044), .A (nx8809), .B (nx7507)) ;
    Nand2 ix12727 (.OUT (nx12045), .A (nx8806), .B (nx7507)) ;
    Nand2 reg_nx8803 (.OUT (nx8803), .A (nx12044), .B (nx12045)) ;
    Nor2 reg_nx7514 (.OUT (nx7514), .A (U_command_control_cmd_state_0), .B (
         nx7452_XX0_XREP471)) ;
    Nand3 reg_nx204 (.OUT (nx204), .A (U_command_control_cmd_cnt_2__XX0_XREP21)
          , .B (U_command_control_cmd_cnt_4), .C (nx7490)) ;
    Nand2 ix12728 (.OUT (nx12046), .A (nx11534), .B (nx11537)) ;
    Nand2 reg_nx10925_XX0_XREP193 (.OUT (nx10925_XX0_XREP193), .A (nx11547), .B (
          nx12046)) ;
    Inv reg_nx3208 (.OUT (nx3208), .A (nx8971)) ;
    Nor2 ix12729 (.OUT (nx12047), .A (nx8793), .B (U_readout_control_int_par)) ;
    Inv ix12730 (.OUT (nx12048), .A (nx12047)) ;
    Nand2 ix12731 (.OUT (nx12049), .A (nx8793), .B (U_readout_control_int_par)
          ) ;
    Nand2 ix12732 (.OUT (nx12050), .A (nx12048), .B (nx12049)) ;
    Nand2 ix12733 (.OUT (nx12051), .A (nx3208), .B (nx12050)) ;
    BufI4 ix12734 (.OUT (nx12052), .A (nx9486)) ;
    Inv ix12735 (.OUT (nx12053), .A (nx10704)) ;
    Inv ix12736 (.OUT (nx12054), .A (nx9018)) ;
    Nor2 ix12737 (.OUT (nx12055), .A (nx12054), .B (nx10719)) ;
    BufI4 ix12738 (.OUT (nx12056), .A (nx12055)) ;
    Nand3 ix12739 (.OUT (nx12057), .A (nx9057), .B (nx5984), .C (
          U_readout_control_st_cnt_2__XX0_XREP83)) ;
    Nand4 ix12740 (.OUT (nx12058), .A (U_readout_control_st_cnt_1), .B (
          U_readout_control_row_cnt_2), .C (nx8986_XX0_XREP85), .D (nx9061)) ;
    Nand2 ix12741 (.OUT (nx12059), .A (nx8988_XX0_XREP83), .B (nx9024_XX0_XREP79
          )) ;
    Inv ix12742 (.OUT (nx12060), .A (nx12059)) ;
    Nand2 ix12743 (.OUT (nx12061), .A (U_readout_control_st_cnt_0__XX0_XREP85), 
          .B (nx12060)) ;
    Nand3 ix12744 (.OUT (nx12062), .A (nx12057), .B (nx12058), .C (nx12061)) ;
    Nand2 ix12745 (.OUT (nx12063), .A (nx10712), .B (nx10714)) ;
    Inv ix12746 (.OUT (nx12064), .A (nx12063)) ;
    Nand2 reg_nx5960 (.OUT (nx5960), .A (nx10710), .B (nx12064)) ;
    Nand2 ix12747 (.OUT (nx12065), .A (nx8988_XX0_XREP83), .B (nx5960)) ;
    Inv ix12748 (.OUT (nx12066), .A (nx8988_XX0_XREP83)) ;
    Nand2 ix12749 (.OUT (nx12067), .A (
          U_readout_control_typ_cnt_3__XX0_XREP89_XX0_XREP303), .B (nx12066)) ;
    Nand2 ix12750 (.OUT (nx12068), .A (nx12065), .B (nx12067)) ;
    Inv ix12751 (.OUT (nx12069), .A (nx9018)) ;
    AOI22 ix12752 (.OUT (nx12070), .A (nx9018), .B (nx12062), .C (nx12068), .D (
          nx12069)) ;
    Nand3 ix12753 (.OUT (nx12071), .A (nx12053), .B (nx12056), .C (nx12070)) ;
    Nand2 reg_nx6024 (.OUT (nx6024), .A (nx12056), .B (nx12070)) ;
    Nand2 ix12754 (.OUT (nx12072), .A (nx10704), .B (nx6024)) ;
    Nand2 ix12755 (.OUT (nx12073), .A (nx12071), .B (nx12072)) ;
    Inv ix12756 (.OUT (nx12074), .A (nx3664)) ;
    Nand3 ix12757 (.OUT (nx12075), .A (nx12052), .B (nx12073), .C (nx12074)) ;
    Nand2 reg_nx6044 (.OUT (nx6044), .A (nx12051), .B (nx12075)) ;
    Inv ix12758 (.OUT (nx12076), .A (nx8971)) ;
    Nor2 ix12759 (.OUT (nx12077), .A (nx9920), .B (nx3256)) ;
    Nand2 ix12760 (.OUT (nx12078), .A (nx4482), .B (nx12077)) ;
    Inv ix12761 (.OUT (nx12079), .A (nx12078)) ;
    Inv ix12762 (.OUT (nx12080), .A (U_analog_control_cal_cnt_4)) ;
    Nor2 ix12763 (.OUT (nx12081), .A (nx12080), .B (nx4482)) ;
    Nor2 ix12764 (.OUT (nx12082), .A (nx12079), .B (nx12081)) ;
    Nor2 reg_nx7259 (.OUT (nx7259), .A (nx12082), .B (nx12110)) ;
    Nor2 reg_nx10925_XX0_XREP397 (.OUT (nx10925_XX0_XREP397), .A (nx12110), .B (
         nx4482)) ;
    BufI4 ix12765 (.OUT (nx12083), .A (nx11706)) ;
    Nand2 ix12766 (.OUT (nx12084), .A (nx11704), .B (nx12083)) ;
    Nand2 reg_nx3231 (.OUT (nx3231), .A (nx11793), .B (nx12084)) ;
    Inv ix12767 (.OUT (nx12085), .A (U_readout_control_typ_cnt_0)) ;
    Nor2 reg_nx3232 (.OUT (nx3232), .A (nx8891), .B (nx9088)) ;
    Nand2 reg_nx3228 (.OUT (nx3228), .A (nx11791), .B (nx12084)) ;
    Nor3 ix12768 (.OUT (nx12086), .A (nx12085), .B (nx3232), .C (nx3228)) ;
    Nand2 ix12769 (.OUT (nx12087), .A (nx3231), .B (nx12086)) ;
    Inv ix12770 (.OUT (nx12088), .A (nx8891)) ;
    Inv ix12771 (.OUT (nx12089), .A (nx9088)) ;
    Nand2 ix12772 (.OUT (nx12090), .A (nx12088), .B (nx12089)) ;
    Nand4 ix12773 (.OUT (nx12091), .A (U_readout_control_typ_cnt_1), .B (nx12090
          ), .C (nx11791), .D (nx12084)) ;
    Nand3 ix12774 (.OUT (nx12092), .A (U_readout_control_typ_cnt_1), .B (nx11793
          ), .C (nx12084)) ;
    Nand3 reg_nx7089 (.OUT (nx7089), .A (nx12087), .B (nx12091), .C (nx12092)) ;
    Buf4 ix12775 (.OUT (nx12093), .A (nx2822)) ;
    Buf4 ix12776 (.OUT (nx12094), .A (nx2822)) ;
    Buf4 ix12777 (.OUT (nx12095), .A (nx9631)) ;
    Buf4 ix12778 (.OUT (nx12096), .A (nx9631)) ;
    Buf4 ix12779 (.OUT (nx12097), .A (nx9623)) ;
    Buf4 ix12780 (.OUT (nx12098), .A (nx9623)) ;
    Buf4 ix12781 (.OUT (nx12099), .A (nx10979)) ;
    Buf4 ix12782 (.OUT (nx12100), .A (nx10979)) ;
    Buf4 ix12783 (.OUT (nx12101), .A (nx10983)) ;
    Buf4 ix12784 (.OUT (nx12102), .A (nx10983)) ;
    Buf4 ix12785 (.OUT (nx12103), .A (U_analog_control_mst_cnt_12)) ;
    Buf4 ix12786 (.OUT (nx12104), .A (U_analog_control_mst_cnt_12)) ;
    Buf4 ix12787 (.OUT (nx12105), .A (U_analog_control_mst_cnt_15)) ;
    Buf4 ix12788 (.OUT (nx12106), .A (U_analog_control_mst_cnt_15)) ;
    Buf4 ix12789 (.OUT (nx12107), .A (nx9845)) ;
    Buf4 ix12790 (.OUT (nx12108), .A (nx9845)) ;
    Buf4 ix12791 (.OUT (nx12109), .A (nx3251)) ;
    Buf4 ix12792 (.OUT (nx12110), .A (nx3251)) ;
    Buf4 ix12793 (.OUT (nx12111), .A (nx10987)) ;
    Buf4 ix12794 (.OUT (nx12112), .A (nx10987)) ;
    Buf4 ix12795 (.OUT (nx12113), .A (nx10975)) ;
    Buf4 ix12796 (.OUT (nx12114), .A (nx10975)) ;
    Buf4 ix12797 (.OUT (nx12115), .A (nx10971)) ;
    Buf4 ix12798 (.OUT (nx12116), .A (nx10971)) ;
endmodule

