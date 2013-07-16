--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.58f
--  \   \         Application: netgen
--  /   /         Filename: EventBuilderFifo.vhd
-- /___/   /\     Timestamp: Tue Jul  9 13:14:06 2013
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/projects/KpixSmall/xil_cores/tmp/_cg/EventBuilderFifo.ngc /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/projects/KpixSmall/xil_cores/tmp/_cg/EventBuilderFifo.vhd 
-- Device	: 5vlx30tff323-2
-- Input file	: /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/projects/KpixSmall/xil_cores/tmp/_cg/EventBuilderFifo.ngc
-- Output file	: /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/projects/KpixSmall/xil_cores/tmp/_cg/EventBuilderFifo.vhd
-- # of Entities	: 2
-- Design Name	: EventBuilderFifo
-- Xilinx	: /afs/slac.stanford.edu/g/reseng/vol15/Xilinx/14.5/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity reset_builtin is
  port (
    CLK : in STD_LOGIC := 'X'; 
    RST : in STD_LOGIC := 'X'; 
    RD_CLK : in STD_LOGIC := 'X'; 
    INT_CLK : in STD_LOGIC := 'X'; 
    WR_CLK : in STD_LOGIC := 'X'; 
    RD_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
    WR_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
    INT_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ) 
  );
end reset_builtin;

architecture STRUCTURE of reset_builtin is
  signal wr_rst_reg_15 : STD_LOGIC; 
  signal NlwRenamedSig_OI_INT_RST_I : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal NlwRenamedSignal_WR_RST_I : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal power_on_wr_rst : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal wr_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
begin
  RD_RST_I(1) <= NlwRenamedSignal_WR_RST_I(0);
  RD_RST_I(0) <= NlwRenamedSignal_WR_RST_I(0);
  WR_RST_I(1) <= NlwRenamedSignal_WR_RST_I(0);
  WR_RST_I(0) <= NlwRenamedSignal_WR_RST_I(0);
  INT_RST_I(1) <= NlwRenamedSig_OI_INT_RST_I(0);
  INT_RST_I(0) <= NlwRenamedSig_OI_INT_RST_I(0);
  XST_GND : GND
    port map (
      G => NlwRenamedSig_OI_INT_RST_I(0)
    );
  wr_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => CLK,
      D => wr_rst_fb(1),
      Q => wr_rst_fb(0)
    );
  wr_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => CLK,
      D => wr_rst_fb(2),
      Q => wr_rst_fb(1)
    );
  wr_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => CLK,
      D => wr_rst_fb(3),
      Q => wr_rst_fb(2)
    );
  wr_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => CLK,
      D => wr_rst_fb(4),
      Q => wr_rst_fb(3)
    );
  wr_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => CLK,
      D => wr_rst_reg_15,
      Q => wr_rst_fb(4)
    );
  power_on_wr_rst_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => CLK,
      D => power_on_wr_rst(1),
      Q => power_on_wr_rst(0)
    );
  power_on_wr_rst_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => CLK,
      D => power_on_wr_rst(2),
      Q => power_on_wr_rst(1)
    );
  power_on_wr_rst_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => CLK,
      D => power_on_wr_rst(3),
      Q => power_on_wr_rst(2)
    );
  power_on_wr_rst_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => CLK,
      D => power_on_wr_rst(4),
      Q => power_on_wr_rst(3)
    );
  power_on_wr_rst_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => CLK,
      D => power_on_wr_rst(5),
      Q => power_on_wr_rst(4)
    );
  power_on_wr_rst_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => CLK,
      D => NlwRenamedSig_OI_INT_RST_I(0),
      Q => power_on_wr_rst(5)
    );
  wr_rst_reg : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => CLK,
      CE => wr_rst_fb(0),
      D => NlwRenamedSig_OI_INT_RST_I(0),
      PRE => RST,
      Q => wr_rst_reg_15
    );
  RD_RST_I_1_1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => wr_rst_reg_15,
      I1 => power_on_wr_rst(0),
      O => NlwRenamedSignal_WR_RST_I(0)
    );

end STRUCTURE;

-- synthesis translate_on

-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity EventBuilderFifo is
  port (
    clk : in STD_LOGIC := 'X'; 
    rd_en : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    empty : out STD_LOGIC; 
    wr_en : in STD_LOGIC := 'X'; 
    valid : out STD_LOGIC; 
    full : out STD_LOGIC; 
    dout : out STD_LOGIC_VECTOR ( 71 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( 71 downto 0 ) 
  );
end EventBuilderFifo;

architecture STRUCTURE of EventBuilderFifo is
  component reset_builtin
    port (
      CLK : in STD_LOGIC := 'X'; 
      RST : in STD_LOGIC := 'X'; 
      RD_CLK : in STD_LOGIC := 'X'; 
      INT_CLK : in STD_LOGIC := 'X'; 
      WR_CLK : in STD_LOGIC := 'X'; 
      RD_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
      WR_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ); 
      INT_RST_I : out STD_LOGIC_VECTOR ( 1 downto 0 ) 
    );
  end component;
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal N10 : STD_LOGIC; 
  signal N12 : STD_LOGIC; 
  signal N16 : STD_LOGIC; 
  signal N2 : STD_LOGIC; 
  signal N20 : STD_LOGIC; 
  signal N22 : STD_LOGIC; 
  signal N4 : STD_LOGIC; 
  signal N6 : STD_LOGIC; 
  signal N8 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_q_36 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_rstpot_38 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_q_41 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_rstpot_43 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_q_46 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_47 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_rstpot_48 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_q_51 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_rstpot_53 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_q_56 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_57 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_rstpot_58 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_q_61 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_62 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_rstpot_63 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_q_66 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_rstpot_68 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_q_71 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_rstpot_73 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_rden_fifo : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i : STD_LOGIC; 
  signal NlwRenamedSig_OI_empty : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful : STD_LOGIC_VECTOR ( 8 downto 1 ); 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  empty <= NlwRenamedSig_OI_empty;
  XST_GND : GND
    port map (
      G => N0
    );
  XST_VCC : VCC
    port map (
      P => N1
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt : reset_builtin
    port map (
      CLK => clk,
      RST => rst,
      RD_CLK => N0,
      INT_CLK => N0,
      WR_CLK => N0,
      RD_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED,
      RD_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_0_UNCONNECTED,
      WR_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED,
      WR_RST_I(0) => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      INT_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED,
      INT_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_q_71
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(8),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(70),
      DI(6) => din(69),
      DI(5) => din(68),
      DI(4) => din(67),
      DI(3) => din(66),
      DI(2) => din(65),
      DI(1) => din(64),
      DI(0) => din(63),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(71),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(70),
      DO(6) => dout(69),
      DO(5) => dout(68),
      DO(4) => dout(67),
      DO(3) => dout(66),
      DO(2) => dout(65),
      DO(1) => dout(64),
      DO(0) => dout(63),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(71),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_q_66
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(7),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(61),
      DI(6) => din(60),
      DI(5) => din(59),
      DI(4) => din(58),
      DI(3) => din(57),
      DI(2) => din(56),
      DI(1) => din(55),
      DI(0) => din(54),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(62),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(61),
      DO(6) => dout(60),
      DO(5) => dout(59),
      DO(4) => dout(58),
      DO(3) => dout(57),
      DO(2) => dout(56),
      DO(1) => dout(55),
      DO(0) => dout(54),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(62),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_q_61
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(6),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(52),
      DI(6) => din(51),
      DI(5) => din(50),
      DI(4) => din(49),
      DI(3) => din(48),
      DI(2) => din(47),
      DI(1) => din(46),
      DI(0) => din(45),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(53),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(52),
      DO(6) => dout(51),
      DO(5) => dout(50),
      DO(4) => dout(49),
      DO(3) => dout(48),
      DO(2) => dout(47),
      DO(1) => dout(46),
      DO(0) => dout(45),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(53),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_q_56
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(5),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(43),
      DI(6) => din(42),
      DI(5) => din(41),
      DI(4) => din(40),
      DI(3) => din(39),
      DI(2) => din(38),
      DI(1) => din(37),
      DI(0) => din(36),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(44),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(43),
      DO(6) => dout(42),
      DO(5) => dout(41),
      DO(4) => dout(40),
      DO(3) => dout(39),
      DO(2) => dout(38),
      DO(1) => dout(37),
      DO(0) => dout(36),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(44),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_q_51
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(4),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(34),
      DI(6) => din(33),
      DI(5) => din(32),
      DI(4) => din(31),
      DI(3) => din(30),
      DI(2) => din(29),
      DI(1) => din(28),
      DI(0) => din(27),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(35),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(34),
      DO(6) => dout(33),
      DO(5) => dout(32),
      DO(4) => dout(31),
      DO(3) => dout(30),
      DO(2) => dout(29),
      DO(1) => dout(28),
      DO(0) => dout(27),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(35),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_q_46
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(3),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(25),
      DI(6) => din(24),
      DI(5) => din(23),
      DI(4) => din(22),
      DI(3) => din(21),
      DI(2) => din(20),
      DI(1) => din(19),
      DI(0) => din(18),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(26),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(25),
      DO(6) => dout(24),
      DO(5) => dout(23),
      DO(4) => dout(22),
      DO(3) => dout(21),
      DO(2) => dout(20),
      DO(1) => dout(19),
      DO(0) => dout(18),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(26),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_q_41
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(2),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(16),
      DI(6) => din(15),
      DI(5) => din(14),
      DI(4) => din(13),
      DI(3) => din(12),
      DI(2) => din(11),
      DI(1) => din(10),
      DI(0) => din(9),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(17),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(16),
      DO(6) => dout(15),
      DO(5) => dout(14),
      DO(4) => dout(13),
      DO(3) => dout(12),
      DO(2) => dout(11),
      DO(1) => dout(10),
      DO(0) => dout(9),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(17),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_q : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_fifo,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_q_36
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36 : FIFO36_EXP
    generic map(
      ALMOST_FULL_OFFSET => X"0001",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 9,
      DO_REG => 0,
      EN_SYN => TRUE,
      FIRST_WORD_FALL_THROUGH => FALSE,
      ALMOST_EMPTY_OFFSET => X"0003"
    )
    port map (
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_rden_fifo,
      WREN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RDCLKU => clk,
      RDCLKL => clk,
      WRCLKU => clk,
      WRCLKL => clk,
      RDRCLKU => clk,
      RDRCLKL => clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_ALMOSTFULL_UNCONNECTED,
      EMPTY => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_fifo,
      FULL => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(1),
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRERR_UNCONNECTED,
      DI(31) => N0,
      DI(30) => N0,
      DI(29) => N0,
      DI(28) => N0,
      DI(27) => N0,
      DI(26) => N0,
      DI(25) => N0,
      DI(24) => N0,
      DI(23) => N0,
      DI(22) => N0,
      DI(21) => N0,
      DI(20) => N0,
      DI(19) => N0,
      DI(18) => N0,
      DI(17) => N0,
      DI(16) => N0,
      DI(15) => N0,
      DI(14) => N0,
      DI(13) => N0,
      DI(12) => N0,
      DI(11) => N0,
      DI(10) => N0,
      DI(9) => N0,
      DI(8) => N0,
      DI(7) => din(7),
      DI(6) => din(6),
      DI(5) => din(5),
      DI(4) => din(4),
      DI(3) => din(3),
      DI(2) => din(2),
      DI(1) => din(1),
      DI(0) => din(0),
      DIP(3) => N0,
      DIP(2) => N0,
      DIP(1) => N0,
      DIP(0) => din(8),
      DO(31) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_31_UNCONNECTED,
      DO(30) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_30_UNCONNECTED,
      DO(29) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_29_UNCONNECTED,
      DO(28) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_28_UNCONNECTED,
      DO(27) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_27_UNCONNECTED,
      DO(26) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_26_UNCONNECTED,
      DO(25) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_25_UNCONNECTED,
      DO(24) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_24_UNCONNECTED,
      DO(23) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_23_UNCONNECTED,
      DO(22) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_22_UNCONNECTED,
      DO(21) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_21_UNCONNECTED,
      DO(20) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_20_UNCONNECTED,
      DO(19) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_19_UNCONNECTED,
      DO(18) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_18_UNCONNECTED,
      DO(17) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_17_UNCONNECTED,
      DO(16) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_16_UNCONNECTED,
      DO(15) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_15_UNCONNECTED,
      DO(14) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_14_UNCONNECTED,
      DO(13) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_13_UNCONNECTED,
      DO(12) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_12_UNCONNECTED,
      DO(11) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_11_UNCONNECTED,
      DO(10) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_10_UNCONNECTED,
      DO(9) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_9_UNCONNECTED,
      DO(8) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DO_8_UNCONNECTED,
      DO(7) => dout(7),
      DO(6) => dout(6),
      DO(5) => dout(5),
      DO(4) => dout(4),
      DO(3) => dout(3),
      DO(2) => dout(2),
      DO(1) => dout(1),
      DO(0) => dout(0),
      DOP(3) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_3_UNCONNECTED,
      DOP(2) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_2_UNCONNECTED,
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_DOP_1_UNCONNECTED,
      DOP(0) => dout(8),
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_12_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_12_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gfn72_sngfifo36_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i_SW0 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_47,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_62,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_57,
      O => N2
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I5 => N2,
      O => NlwRenamedSig_OI_empty
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_full_i_SW0 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(3),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(6),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(5),
      O => N4
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_full_i : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(8),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(7),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(2),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(1),
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(4),
      I5 => N4,
      O => full
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_rstpot_73,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_rstpot_68,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_rstpot_63,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_62
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_rstpot_58,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_57
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_rstpot_53,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_rstpot_48,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_47
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_rstpot_43,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_rstpot_38,
      PRE => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_q_71,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_rstpot_73
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_q_66,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_rstpot_68
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_q_61,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_62,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_rstpot_63
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_q_56,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_57,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_rstpot_58
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_q_51,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_rstpot_53
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_q_46,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_47,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_rstpot_48
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_q_41,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_rstpot_43
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_rstpot : LUT5
    generic map(
      INIT => X"F050FC10"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_q_36,
      I1 => rd_en,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => NlwRenamedSig_OI_empty,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_rstpot_38
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_full_i_SW1 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => wr_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(1),
      O => N6
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i1 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(2),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(4),
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(7),
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_ful(8),
      I4 => N6,
      I5 => N4,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_wr_ack_i
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i_SW1 : LUT4
    generic map(
      INIT => X"FFFD"
    )
    port map (
      I0 => rd_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      O => N8
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"00A000A000A003A3"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_q_71,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => N2,
      I5 => N8,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i_SW2 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => rd_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      O => N10
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"0088038B00880088"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_q_66,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => N2,
      I5 => N10,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i_SW3 : LUT5
    generic map(
      INIT => X"FFFFFFFD"
    )
    port map (
      I0 => rd_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      O => N12
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"40404040404040FF"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_fifo,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_q_61,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_empty_user_62,
      I3 => N2,
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I5 => N12,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_6_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"40404040404040FF"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_fifo,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_q_56,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_empty_user_57,
      I3 => N2,
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I5 => N12,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_5_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i_SW5 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => rd_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      O => N16
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"0088038B00880088"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_q_51,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => N2,
      I5 => N16,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"40404040404040FF"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_fifo,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_q_46,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_empty_user_47,
      I3 => N2,
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I5 => N12,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_3_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i_SW7 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => rd_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      O => N20
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"0088038B00880088"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_q_41,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => N2,
      I5 => N20,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_empty_i_SW8 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => rd_en,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      O => N22
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_rden_fifo1 : LUT6
    generic map(
      INIT => X"0088038B00880088"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_q_36,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_fifo,
      I4 => N2,
      I5 => N22,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_rden_fifo
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_VALID1 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_8_inst_extd_gonep_inst_prim_empty_user_72,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_7_inst_extd_gonep_inst_prim_empty_user_67,
      I2 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_2_inst_extd_gonep_inst_prim_empty_user_42,
      I3 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_empty_user_37,
      I4 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_4_inst_extd_gonep_inst_prim_empty_user_52,
      I5 => N2,
      O => valid
    );

end STRUCTURE;

-- synthesis translate_on
