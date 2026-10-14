module f03_lock_scaffold_explicit (clk,
    digit_valid,
    locked,
    rst_n,
    unlock,
    digit);
 input clk;
 input digit_valid;
 output locked;
 input rst_n;
 output unlock;
 input [3:0] digit;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire _050_;
 wire _051_;
 wire _052_;
 wire _053_;
 wire _054_;
 wire _055_;
 wire _056_;
 wire _057_;
 wire _058_;
 wire _059_;
 wire _060_;
 wire _061_;
 wire _062_;
 wire _063_;
 wire _064_;
 wire _065_;
 wire _066_;
 wire _067_;
 wire _068_;
 wire _069_;
 wire _070_;
 wire _071_;
 wire \d0[0] ;
 wire \d0[1] ;
 wire \d0[2] ;
 wire \d0[3] ;
 wire \d1[0] ;
 wire \d1[1] ;
 wire \d1[2] ;
 wire \d1[3] ;
 wire \d2[0] ;
 wire \d2[1] ;
 wire \d2[2] ;
 wire \d2[3] ;
 wire \d3[0] ;
 wire \d3[1] ;
 wire \d3[2] ;
 wire \d3[3] ;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire \fails[0] ;
 wire \fails[1] ;
 wire net7;
 wire \pos[0] ;
 wire \pos[1] ;
 wire \pos[2] ;
 wire \pos[3] ;
 wire net6;
 wire \state[0] ;
 wire \state[2] ;
 wire net8;
 wire net9;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;

 sky130_fd_sc_hd__decap_3 FILLER_0_101 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_104 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_107 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_110 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_40 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_43 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_46 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_49 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_52 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_69 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_72 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_9 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_98 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_39 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_10_88 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_101 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_104 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_107 ();
 sky130_fd_sc_hd__fill_2 FILLER_11_110 ();
 sky130_fd_sc_hd__fill_1 FILLER_11_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_63 ();
 sky130_fd_sc_hd__fill_1 FILLER_11_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_100 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_103 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_11 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_23 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_53 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_56 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_62 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_73 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_76 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_79 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_82 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_97 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_100 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_103 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_109 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_11 ();
 sky130_fd_sc_hd__fill_1 FILLER_13_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_14 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_20 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_23 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_69 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_72 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_75 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_84 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_87 ();
 sky130_fd_sc_hd__fill_2 FILLER_13_90 ();
 sky130_fd_sc_hd__decap_3 FILLER_13_97 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_23 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_32 ();
 sky130_fd_sc_hd__fill_2 FILLER_14_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_45 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_48 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_51 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_54 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_80 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_83 ();
 sky130_fd_sc_hd__decap_3 FILLER_14_85 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_88 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_102 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_105 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_108 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_111 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_32 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_60 ();
 sky130_fd_sc_hd__fill_2 FILLER_15_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_96 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_99 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_111 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_53 ();
 sky130_fd_sc_hd__fill_2 FILLER_16_56 ();
 sky130_fd_sc_hd__decap_3 FILLER_16_6 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_83 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_85 ();
 sky130_fd_sc_hd__fill_1 FILLER_16_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_102 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_105 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_108 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_111 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_28 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_31 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_34 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_37 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_55 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_63 ();
 sky130_fd_sc_hd__fill_1 FILLER_17_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_84 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_87 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_90 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_93 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_96 ();
 sky130_fd_sc_hd__decap_3 FILLER_17_99 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_100 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_103 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_109 ();
 sky130_fd_sc_hd__fill_1 FILLER_18_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_25 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_50 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_69 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_72 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_75 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_78 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_81 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_18_97 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_105 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_108 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_111 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_20 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_31 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_34 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_37 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_80 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_83 ();
 sky130_fd_sc_hd__fill_2 FILLER_1_86 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_111 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_3 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_42 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_6 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_67 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_82 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_88 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_109 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_19 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_22 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_33 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_36 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_45 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_63 ();
 sky130_fd_sc_hd__fill_2 FILLER_3_66 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_76 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_79 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_82 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_85 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_35 ();
 sky130_fd_sc_hd__fill_2 FILLER_4_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_64 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_101 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_104 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_107 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_110 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_14 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_23 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_26 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_44 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_47 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_54 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_77 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_80 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_83 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_86 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_89 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_92 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_95 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_98 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_102 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_105 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_108 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_111 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_72 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_75 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_83 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_91 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_39 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_42 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_55 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_57 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_64 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_67 ();
 sky130_fd_sc_hd__fill_2 FILLER_7_70 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_89 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_100 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_103 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_106 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_109 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_112 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_12 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_15 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_32 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_35 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_38 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_44 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_56 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_59 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_62 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_65 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_68 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_71 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_74 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_77 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_80 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_83 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_85 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_88 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_9 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_91 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_94 ();
 sky130_fd_sc_hd__decap_3 FILLER_8_97 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_104 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_107 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_110 ();
 sky130_fd_sc_hd__fill_1 FILLER_9_113 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_18 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_21 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_24 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_30 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_33 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_36 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_42 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_45 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_48 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_57 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_60 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_63 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_71 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_74 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_77 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_80 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_83 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_86 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_9 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_29 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_30 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_31 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Left_32 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Right_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Left_33 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Right_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Left_34 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Right_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Left_35 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_16_Right_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Left_36 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_17_Right_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_18_Left_37 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_18_Right_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_25 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_26 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_27 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_28 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_38 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_39 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_40 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_41 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_60 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_61 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_62 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_63 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_64 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_65 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_66 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_67 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_68 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_69 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_70 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_71 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_72 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_16_73 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_74 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_17_75 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_76 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_77 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_78 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_18_79 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_42 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_43 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_44 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_45 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_46 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_47 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_48 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_49 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_50 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_51 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_52 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_53 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_54 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_55 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_56 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_57 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_58 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_59 ();
 sky130_fd_sc_hd__inv_2 _072_ (.A(\state[2] ),
    .Y(_041_));
 sky130_fd_sc_hd__inv_2 _073_ (.A(net5),
    .Y(_042_));
 sky130_fd_sc_hd__inv_2 _074_ (.A(net6),
    .Y(_043_));
 sky130_fd_sc_hd__inv_2 _075_ (.A(\state[0] ),
    .Y(_044_));
 sky130_fd_sc_hd__nand2_2 _076_ (.A(net5),
    .B(\pos[3] ),
    .Y(_045_));
 sky130_fd_sc_hd__and2_2 _077_ (.A(net5),
    .B(\state[0] ),
    .X(_046_));
 sky130_fd_sc_hd__and3_2 _078_ (.A(net5),
    .B(\pos[3] ),
    .C(\state[0] ),
    .X(_047_));
 sky130_fd_sc_hd__nand2_2 _079_ (.A(\pos[3] ),
    .B(_046_),
    .Y(_048_));
 sky130_fd_sc_hd__nor2_2 _080_ (.A(_043_),
    .B(_048_),
    .Y(_001_));
 sky130_fd_sc_hd__or4bb_2 _081_ (.A(\d2[3] ),
    .B(\d2[2] ),
    .C_N(\d2[1] ),
    .D_N(\d2[0] ),
    .X(_049_));
 sky130_fd_sc_hd__or4b_2 _082_ (.A(\d3[3] ),
    .B(\d3[1] ),
    .C(\d3[0] ),
    .D_N(\d3[2] ),
    .X(_050_));
 sky130_fd_sc_hd__or4b_2 _083_ (.A(\d0[3] ),
    .B(\d0[2] ),
    .C(\d0[1] ),
    .D_N(\d0[0] ),
    .X(_051_));
 sky130_fd_sc_hd__or4b_2 _084_ (.A(\d1[3] ),
    .B(\d1[2] ),
    .C(\d1[0] ),
    .D_N(\d1[1] ),
    .X(_052_));
 sky130_fd_sc_hd__or4_2 _085_ (.A(_049_),
    .B(_050_),
    .C(_051_),
    .D(_052_),
    .X(_053_));
 sky130_fd_sc_hd__nor3_2 _086_ (.A(_041_),
    .B(_043_),
    .C(_053_),
    .Y(_000_));
 sky130_fd_sc_hd__and2b_2 _087_ (.A_N(\fails[0] ),
    .B(\fails[1] ),
    .X(_054_));
 sky130_fd_sc_hd__o41a_2 _088_ (.A1(_049_),
    .A2(_050_),
    .A3(_051_),
    .A4(_052_),
    .B1(net9),
    .X(_055_));
 sky130_fd_sc_hd__or4_2 _089_ (.A(_049_),
    .B(_050_),
    .C(_051_),
    .D(_052_),
    .X(_056_));
 sky130_fd_sc_hd__a32o_2 _090_ (.A1(\state[2] ),
    .A2(_054_),
    .A3(_055_),
    .B1(net9),
    .B2(net7),
    .X(_007_));
 sky130_fd_sc_hd__nor2_2 _091_ (.A(_041_),
    .B(_054_),
    .Y(_057_));
 sky130_fd_sc_hd__a211o_2 _092_ (.A1(\state[0] ),
    .A2(_045_),
    .B1(net8),
    .C1(_043_),
    .X(_058_));
 sky130_fd_sc_hd__a21o_2 _093_ (.A1(_055_),
    .A2(_057_),
    .B1(_058_),
    .X(_006_));
 sky130_fd_sc_hd__and3_2 _094_ (.A(net5),
    .B(\state[0] ),
    .C(\pos[1] ),
    .X(_059_));
 sky130_fd_sc_hd__nand2_2 _095_ (.A(\pos[1] ),
    .B(_046_),
    .Y(_060_));
 sky130_fd_sc_hd__a211oi_2 _096_ (.A1(_044_),
    .A2(net8),
    .B1(_046_),
    .C1(_043_),
    .Y(_061_));
 sky130_fd_sc_hd__a22o_2 _097_ (.A1(net9),
    .A2(_059_),
    .B1(_061_),
    .B2(\pos[3] ),
    .X(_005_));
 sky130_fd_sc_hd__a21o_2 _098_ (.A1(\state[0] ),
    .A2(\pos[0] ),
    .B1(net8),
    .X(_062_));
 sky130_fd_sc_hd__a32o_2 _099_ (.A1(net5),
    .A2(net6),
    .A3(_062_),
    .B1(_061_),
    .B2(\pos[2] ),
    .X(_004_));
 sky130_fd_sc_hd__and3_2 _100_ (.A(net5),
    .B(\state[0] ),
    .C(\pos[2] ),
    .X(_063_));
 sky130_fd_sc_hd__nand2_2 _101_ (.A(\pos[2] ),
    .B(_046_),
    .Y(_064_));
 sky130_fd_sc_hd__a22o_2 _102_ (.A1(\pos[1] ),
    .A2(_061_),
    .B1(_063_),
    .B2(net9),
    .X(_003_));
 sky130_fd_sc_hd__a21o_2 _103_ (.A1(_042_),
    .A2(net8),
    .B1(_043_),
    .X(_065_));
 sky130_fd_sc_hd__a211o_2 _104_ (.A1(\pos[0] ),
    .A2(_061_),
    .B1(_065_),
    .C1(_047_),
    .X(_002_));
 sky130_fd_sc_hd__nand2_2 _105_ (.A(\state[2] ),
    .B(\fails[0] ),
    .Y(_066_));
 sky130_fd_sc_hd__or2_2 _106_ (.A(\state[2] ),
    .B(\fails[0] ),
    .X(_067_));
 sky130_fd_sc_hd__o2111a_2 _107_ (.A1(_041_),
    .A2(_056_),
    .B1(_066_),
    .C1(_067_),
    .D1(net9),
    .X(_008_));
 sky130_fd_sc_hd__xnor2_2 _108_ (.A(\fails[1] ),
    .B(_066_),
    .Y(_068_));
 sky130_fd_sc_hd__o211a_2 _109_ (.A1(_041_),
    .A2(_056_),
    .B1(_068_),
    .C1(net9),
    .X(_009_));
 sky130_fd_sc_hd__mux2_1 _110_ (.A0(net8),
    .A1(\pos[0] ),
    .S(\state[0] ),
    .X(_069_));
 sky130_fd_sc_hd__nand2_2 _111_ (.A(net5),
    .B(_069_),
    .Y(_070_));
 sky130_fd_sc_hd__a21o_2 _112_ (.A1(net5),
    .A2(_069_),
    .B1(\d0[0] ),
    .X(_071_));
 sky130_fd_sc_hd__o211a_2 _113_ (.A1(net1),
    .A2(_070_),
    .B1(_071_),
    .C1(net6),
    .X(_010_));
 sky130_fd_sc_hd__a21o_2 _114_ (.A1(net5),
    .A2(_069_),
    .B1(\d0[1] ),
    .X(_026_));
 sky130_fd_sc_hd__o211a_2 _115_ (.A1(net2),
    .A2(_070_),
    .B1(_026_),
    .C1(net6),
    .X(_011_));
 sky130_fd_sc_hd__a21o_2 _116_ (.A1(net5),
    .A2(_069_),
    .B1(\d0[2] ),
    .X(_027_));
 sky130_fd_sc_hd__o211a_2 _117_ (.A1(net3),
    .A2(_070_),
    .B1(_027_),
    .C1(net6),
    .X(_012_));
 sky130_fd_sc_hd__a21o_2 _118_ (.A1(net5),
    .A2(_069_),
    .B1(\d0[3] ),
    .X(_028_));
 sky130_fd_sc_hd__o211a_2 _119_ (.A1(net4),
    .A2(_070_),
    .B1(_028_),
    .C1(net6),
    .X(_013_));
 sky130_fd_sc_hd__or2_2 _120_ (.A(\d1[0] ),
    .B(_063_),
    .X(_029_));
 sky130_fd_sc_hd__o211a_2 _121_ (.A1(net1),
    .A2(_064_),
    .B1(_029_),
    .C1(net9),
    .X(_014_));
 sky130_fd_sc_hd__or2_2 _122_ (.A(\d1[1] ),
    .B(_063_),
    .X(_030_));
 sky130_fd_sc_hd__o211a_2 _123_ (.A1(net2),
    .A2(_064_),
    .B1(_030_),
    .C1(net9),
    .X(_015_));
 sky130_fd_sc_hd__or2_2 _124_ (.A(\d1[2] ),
    .B(_063_),
    .X(_031_));
 sky130_fd_sc_hd__o211a_2 _125_ (.A1(net3),
    .A2(_064_),
    .B1(_031_),
    .C1(net9),
    .X(_016_));
 sky130_fd_sc_hd__or2_2 _126_ (.A(\d1[3] ),
    .B(_063_),
    .X(_032_));
 sky130_fd_sc_hd__o211a_2 _127_ (.A1(net4),
    .A2(_064_),
    .B1(_032_),
    .C1(net9),
    .X(_017_));
 sky130_fd_sc_hd__or2_2 _128_ (.A(\d2[0] ),
    .B(_059_),
    .X(_033_));
 sky130_fd_sc_hd__o211a_2 _129_ (.A1(net1),
    .A2(_060_),
    .B1(_033_),
    .C1(net9),
    .X(_018_));
 sky130_fd_sc_hd__or2_2 _130_ (.A(\d2[1] ),
    .B(_059_),
    .X(_034_));
 sky130_fd_sc_hd__o211a_2 _131_ (.A1(net2),
    .A2(_060_),
    .B1(_034_),
    .C1(net9),
    .X(_019_));
 sky130_fd_sc_hd__or2_2 _132_ (.A(\d2[2] ),
    .B(_059_),
    .X(_035_));
 sky130_fd_sc_hd__o211a_2 _133_ (.A1(net3),
    .A2(_060_),
    .B1(_035_),
    .C1(net9),
    .X(_020_));
 sky130_fd_sc_hd__or2_2 _134_ (.A(\d2[3] ),
    .B(_059_),
    .X(_036_));
 sky130_fd_sc_hd__o211a_2 _135_ (.A1(net4),
    .A2(_060_),
    .B1(_036_),
    .C1(net9),
    .X(_021_));
 sky130_fd_sc_hd__or2_2 _136_ (.A(\d3[0] ),
    .B(_047_),
    .X(_037_));
 sky130_fd_sc_hd__o211a_2 _137_ (.A1(net1),
    .A2(_048_),
    .B1(_037_),
    .C1(net9),
    .X(_022_));
 sky130_fd_sc_hd__or2_2 _138_ (.A(\d3[1] ),
    .B(_047_),
    .X(_038_));
 sky130_fd_sc_hd__o211a_2 _139_ (.A1(net2),
    .A2(_048_),
    .B1(_038_),
    .C1(net9),
    .X(_023_));
 sky130_fd_sc_hd__or2_2 _140_ (.A(\d3[2] ),
    .B(_047_),
    .X(_039_));
 sky130_fd_sc_hd__o211a_2 _141_ (.A1(net3),
    .A2(_048_),
    .B1(_039_),
    .C1(net9),
    .X(_024_));
 sky130_fd_sc_hd__or2_2 _142_ (.A(\d3[3] ),
    .B(_047_),
    .X(_040_));
 sky130_fd_sc_hd__o211a_2 _143_ (.A1(net4),
    .A2(_048_),
    .B1(_040_),
    .C1(net9),
    .X(_025_));
 sky130_fd_sc_hd__dfxtp_2 _144_ (.CLK(clknet_1_0__leaf_clk),
    .D(_008_),
    .Q(\fails[0] ));
 sky130_fd_sc_hd__dfxtp_2 _145_ (.CLK(clknet_1_0__leaf_clk),
    .D(_009_),
    .Q(\fails[1] ));
 sky130_fd_sc_hd__dfxtp_2 _146_ (.CLK(clknet_1_0__leaf_clk),
    .D(_010_),
    .Q(\d0[0] ));
 sky130_fd_sc_hd__dfxtp_2 _147_ (.CLK(clknet_1_1__leaf_clk),
    .D(_011_),
    .Q(\d0[1] ));
 sky130_fd_sc_hd__dfxtp_2 _148_ (.CLK(clknet_1_1__leaf_clk),
    .D(_012_),
    .Q(\d0[2] ));
 sky130_fd_sc_hd__dfxtp_2 _149_ (.CLK(clknet_1_0__leaf_clk),
    .D(_013_),
    .Q(\d0[3] ));
 sky130_fd_sc_hd__dfxtp_2 _150_ (.CLK(clknet_1_1__leaf_clk),
    .D(_014_),
    .Q(\d1[0] ));
 sky130_fd_sc_hd__dfxtp_2 _151_ (.CLK(clknet_1_1__leaf_clk),
    .D(_015_),
    .Q(\d1[1] ));
 sky130_fd_sc_hd__dfxtp_2 _152_ (.CLK(clknet_1_1__leaf_clk),
    .D(_016_),
    .Q(\d1[2] ));
 sky130_fd_sc_hd__dfxtp_2 _153_ (.CLK(clknet_1_1__leaf_clk),
    .D(_017_),
    .Q(\d1[3] ));
 sky130_fd_sc_hd__dfxtp_2 _154_ (.CLK(clknet_1_1__leaf_clk),
    .D(_018_),
    .Q(\d2[0] ));
 sky130_fd_sc_hd__dfxtp_2 _155_ (.CLK(clknet_1_1__leaf_clk),
    .D(_019_),
    .Q(\d2[1] ));
 sky130_fd_sc_hd__dfxtp_2 _156_ (.CLK(clknet_1_1__leaf_clk),
    .D(_020_),
    .Q(\d2[2] ));
 sky130_fd_sc_hd__dfxtp_2 _157_ (.CLK(clknet_1_1__leaf_clk),
    .D(_021_),
    .Q(\d2[3] ));
 sky130_fd_sc_hd__dfxtp_2 _158_ (.CLK(clknet_1_0__leaf_clk),
    .D(_022_),
    .Q(\d3[0] ));
 sky130_fd_sc_hd__dfxtp_2 _159_ (.CLK(clknet_1_1__leaf_clk),
    .D(_023_),
    .Q(\d3[1] ));
 sky130_fd_sc_hd__dfxtp_2 _160_ (.CLK(clknet_1_1__leaf_clk),
    .D(_024_),
    .Q(\d3[2] ));
 sky130_fd_sc_hd__dfxtp_2 _161_ (.CLK(clknet_1_1__leaf_clk),
    .D(_025_),
    .Q(\d3[3] ));
 sky130_fd_sc_hd__dfxtp_2 _162_ (.CLK(clknet_1_0__leaf_clk),
    .D(_006_),
    .Q(\state[0] ));
 sky130_fd_sc_hd__dfxtp_2 _163_ (.CLK(clknet_1_0__leaf_clk),
    .D(_000_),
    .Q(net8));
 sky130_fd_sc_hd__dfxtp_2 _164_ (.CLK(clknet_1_0__leaf_clk),
    .D(_001_),
    .Q(\state[2] ));
 sky130_fd_sc_hd__dfxtp_2 _165_ (.CLK(clknet_1_0__leaf_clk),
    .D(_007_),
    .Q(net7));
 sky130_fd_sc_hd__dfxtp_2 _166_ (.CLK(clknet_1_0__leaf_clk),
    .D(_002_),
    .Q(\pos[0] ));
 sky130_fd_sc_hd__dfxtp_2 _167_ (.CLK(clknet_1_1__leaf_clk),
    .D(_003_),
    .Q(\pos[1] ));
 sky130_fd_sc_hd__dfxtp_2 _168_ (.CLK(clknet_1_0__leaf_clk),
    .D(_004_),
    .Q(\pos[2] ));
 sky130_fd_sc_hd__dfxtp_2 _169_ (.CLK(clknet_1_0__leaf_clk),
    .D(_005_),
    .Q(\pos[3] ));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .X(clknet_1_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .X(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__clkbuf_8 clkload0 (.A(clknet_1_0__leaf_clk));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input1 (.A(digit[0]),
    .X(net1));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input2 (.A(digit[1]),
    .X(net2));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input3 (.A(digit[2]),
    .X(net3));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input4 (.A(digit[3]),
    .X(net4));
 sky130_fd_sc_hd__clkdlybuf4s25_1 input5 (.A(digit_valid),
    .X(net5));
 sky130_fd_sc_hd__buf_1 input6 (.A(rst_n),
    .X(net6));
 sky130_fd_sc_hd__buf_6 max_cap9 (.A(net6),
    .X(net9));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output7 (.A(net7),
    .X(locked));
 sky130_fd_sc_hd__clkdlybuf4s25_1 output8 (.A(net8),
    .X(unlock));
endmodule
