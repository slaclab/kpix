--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.58f
--  \   \         Application: netgen
--  /   /         Filename: timestamp_fifo.vhd
-- /___/   /\     Timestamp: Wed Jul 10 13:41:25 2013
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/modules/KpixDaq/xil_cores/tmp/_cg/timestamp_fifo.ngc /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/modules/KpixDaq/xil_cores/tmp/_cg/timestamp_fifo.vhd 
-- Device	: 5vlx50tff665-1
-- Input file	: /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/modules/KpixDaq/xil_cores/tmp/_cg/timestamp_fifo.ngc
-- Output file	: /afs/slac.stanford.edu/u/re/bareese/projects/kpix/trunk/firmware/modules/KpixDaq/xil_cores/tmp/_cg/timestamp_fifo.vhd
-- # of Entities	: 2
-- Design Name	: timestamp_fifo
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
  signal rd_rst_reg_22 : STD_LOGIC; 
  signal wr_rst_reg_28 : STD_LOGIC; 
  signal NlwRenamedSig_OI_INT_RST_I : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal NlwRenamedSignal_RD_RST_I : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal power_on_rd_rst : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal power_on_wr_rst : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal rd_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal wr_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
begin
  RD_RST_I(1) <= NlwRenamedSignal_RD_RST_I(0);
  RD_RST_I(0) <= NlwRenamedSignal_RD_RST_I(0);
  INT_RST_I(1) <= NlwRenamedSig_OI_INT_RST_I(0);
  INT_RST_I(0) <= NlwRenamedSig_OI_INT_RST_I(0);
  XST_GND : GND
    port map (
      G => NlwRenamedSig_OI_INT_RST_I(0)
    );
  rd_rst_reg : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      CE => rd_rst_fb(0),
      D => NlwRenamedSig_OI_INT_RST_I(0),
      PRE => RST,
      Q => rd_rst_reg_22
    );
  wr_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(1),
      Q => wr_rst_fb(0)
    );
  wr_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(2),
      Q => wr_rst_fb(1)
    );
  wr_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(3),
      Q => wr_rst_fb(2)
    );
  wr_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_fb(4),
      Q => wr_rst_fb(3)
    );
  wr_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      D => wr_rst_reg_28,
      Q => wr_rst_fb(4)
    );
  power_on_rd_rst_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(1),
      Q => power_on_rd_rst(0)
    );
  power_on_rd_rst_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(2),
      Q => power_on_rd_rst(1)
    );
  power_on_rd_rst_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(3),
      Q => power_on_rd_rst(2)
    );
  power_on_rd_rst_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(4),
      Q => power_on_rd_rst(3)
    );
  power_on_rd_rst_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => power_on_rd_rst(5),
      Q => power_on_rd_rst(4)
    );
  power_on_rd_rst_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => RD_CLK,
      D => NlwRenamedSig_OI_INT_RST_I(0),
      Q => power_on_rd_rst(5)
    );
  power_on_wr_rst_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(1),
      Q => power_on_wr_rst(0)
    );
  power_on_wr_rst_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(2),
      Q => power_on_wr_rst(1)
    );
  power_on_wr_rst_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(3),
      Q => power_on_wr_rst(2)
    );
  power_on_wr_rst_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(4),
      Q => power_on_wr_rst(3)
    );
  power_on_wr_rst_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => power_on_wr_rst(5),
      Q => power_on_wr_rst(4)
    );
  power_on_wr_rst_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => WR_CLK,
      D => NlwRenamedSig_OI_INT_RST_I(0),
      Q => power_on_wr_rst(5)
    );
  wr_rst_reg : FDPE
    generic map(
      INIT => '0'
    )
    port map (
      C => WR_CLK,
      CE => wr_rst_fb(0),
      D => NlwRenamedSig_OI_INT_RST_I(0),
      PRE => RST,
      Q => wr_rst_reg_28
    );
  rd_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(1),
      Q => rd_rst_fb(0)
    );
  rd_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(2),
      Q => rd_rst_fb(1)
    );
  rd_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(3),
      Q => rd_rst_fb(2)
    );
  rd_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_fb(4),
      Q => rd_rst_fb(3)
    );
  rd_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => RD_CLK,
      D => rd_rst_reg_22,
      Q => rd_rst_fb(4)
    );
  RD_RST_I_1_1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => rd_rst_reg_22,
      I1 => power_on_rd_rst(0),
      O => NlwRenamedSignal_RD_RST_I(0)
    );

end STRUCTURE;

-- synthesis translate_on

-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity timestamp_fifo is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    empty : out STD_LOGIC; 
    wr_en : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    valid : out STD_LOGIC; 
    full : out STD_LOGIC; 
    wr_clk : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( 15 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( 15 downto 0 ) 
  );
end timestamp_fifo;

architecture STRUCTURE of timestamp_fifo is
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
  signal NlwRenamedSig_OI_empty : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDERR_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRERR_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_DOP_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_DOP_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rd_rst_i : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  empty <= NlwRenamedSig_OI_empty;
  XST_GND : GND
    port map (
      G => N0
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt : reset_builtin
    port map (
      CLK => N0,
      RST => rst,
      RD_CLK => rd_clk,
      INT_CLK => N0,
      WR_CLK => wr_clk,
      RD_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_RD_RST_I_1_UNCONNECTED,
      RD_RST_I(0) => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rd_rst_i(0),
      WR_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_UNCONNECTED,
      WR_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_0_UNCONNECTED,
      INT_RST_I(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_1_UNCONNECTED,
      INT_RST_I(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_INT_RST_I_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18 : FIFO18
    generic map(
      ALMOST_FULL_OFFSET => X"004",
      SIM_MODE => "SAFE",
      DATA_WIDTH => 18,
      DO_REG => 1,
      EN_SYN => FALSE,
      FIRST_WORD_FALL_THROUGH => TRUE,
      ALMOST_EMPTY_OFFSET => X"008"
    )
    port map (
      RDEN => rd_en,
      WREN => wr_en,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rd_rst_i(0),
      RDCLK => rd_clk,
      WRCLK => wr_clk,
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_ALMOSTFULL_UNCONNECTED,
      EMPTY => NlwRenamedSig_OI_empty,
      FULL => full,
      RDERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDERR_UNCONNECTED,
      WRERR => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRERR_UNCONNECTED,
      DI(15) => din(15),
      DI(14) => din(14),
      DI(13) => din(13),
      DI(12) => din(12),
      DI(11) => din(11),
      DI(10) => din(10),
      DI(9) => din(9),
      DI(8) => din(8),
      DI(7) => din(7),
      DI(6) => din(6),
      DI(5) => din(5),
      DI(4) => din(4),
      DI(3) => din(3),
      DI(2) => din(2),
      DI(1) => din(1),
      DI(0) => din(0),
      DIP(1) => N0,
      DIP(0) => N0,
      DO(15) => dout(15),
      DO(14) => dout(14),
      DO(13) => dout(13),
      DO(12) => dout(12),
      DO(11) => dout(11),
      DO(10) => dout(10),
      DO(9) => dout(9),
      DO(8) => dout(8),
      DO(7) => dout(7),
      DO(6) => dout(6),
      DO(5) => dout(5),
      DO(4) => dout(4),
      DO(3) => dout(3),
      DO(2) => dout(2),
      DO(1) => dout(1),
      DO(0) => dout(0),
      DOP(1) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_DOP_1_UNCONNECTED,
      DOP(0) => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_DOP_0_UNCONNECTED,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_11_UNCONNECTED,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_10_UNCONNECTED,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_9_UNCONNECTED,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_8_UNCONNECTED,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_7_UNCONNECTED,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_6_UNCONNECTED,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_5_UNCONNECTED,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_4_UNCONNECTED,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_3_UNCONNECTED,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_2_UNCONNECTED,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_1_UNCONNECTED,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_RDCOUNT_0_UNCONNECTED,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_11_UNCONNECTED,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_10_UNCONNECTED,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_9_UNCONNECTED,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_8_UNCONNECTED,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_7_UNCONNECTED,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_6_UNCONNECTED,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_5_UNCONNECTED,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_4_UNCONNECTED,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_3_UNCONNECTED,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_2_UNCONNECTED,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_1_UNCONNECTED,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_gextw_1_inst_extd_gonep_inst_prim_gf18_sngfifo18_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v5_fifo_fblk_VALID1_INV_0 : INV
    port map (
      I => NlwRenamedSig_OI_empty,
      O => valid
    );

end STRUCTURE;

-- synthesis translate_on
