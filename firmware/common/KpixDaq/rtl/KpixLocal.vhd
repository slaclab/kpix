-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA, Local KPIX Core
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixLocal.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the control of the KPIX devices
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-------------------------------------------------------------------------------

library ieee;
library Unisim;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;
use work.KpixLocalPkg.all;


entity KpixLocal is
   generic (
      DELAY_G : time := 1 ns);
   port (

      -- Kpix clock, reset
      kpixClk    : in std_logic;        -- 20Mhz system clock
      kpixClkRst : in std_logic;        -- System reset

      -- IO Ports
      debugOutA : out std_logic;        -- BNC Interface A output
      debugOutB : out std_logic;        -- BNC Interface B output

      -- Controls
      debugASel : in std_logic_vector(4 downto 0);  -- BNC Output A Select
      debugBSel : in std_logic_vector(4 downto 0);  -- BNC Output B Select

      -- Kpix signals
      kpixReset : in  std_logic;        -- Kpix reset
      kpixCmd   : in  std_logic;        -- Command data in
      kpixData  : out std_logic;        -- Response Data out

      -- KPIX State (output on clk200)
      clk200    : in  sl;
      rst200    : in  sl;
      kpixState : out KpixStateOutType;

      -- Cal strobe out
      calStrobeOut : out std_logic;

      -- KPIX State (output on sysClk)
      sysClk       : in  std_logic;
      sysRst       : in  std_logic;
      sysKpixState : out KpixStateOutType  -- Outputs on sysClk
      );
end KpixLocal;


-- Define architecture
architecture KpixLocal of KpixLocal is

   -- Local copy of digital core, 8+ version
   component memory_array_control
      port (
         sysclk          : in  std_logic;
         reset           : in  std_logic;
         command         : in  std_logic;
         data_out        : out std_logic;
         temp_id0        : in  std_logic;
         temp_id1        : in  std_logic;
         temp_id2        : in  std_logic;
         temp_id3        : in  std_logic;
         temp_id4        : in  std_logic;
         temp_id5        : in  std_logic;
         temp_id6        : in  std_logic;
         temp_id7        : in  std_logic;
         temp_en         : out std_logic;
         out_reset_l     : out std_logic;
         int_reset_l     : in  std_logic;
         reg_clock       : out std_logic;
         reg_sel1        : out std_logic;
         reg_sel0        : out std_logic;
         pwr_up_acq      : out std_logic;
         reset_load      : out std_logic;
         leakage_null    : out std_logic;
         offset_null     : out std_logic;
         thresh_off      : out std_logic;
         trig_inh        : out std_logic;
         cal_strobe      : out std_logic;
         pwr_up_acq_dig  : out std_logic;
         sel_cell        : out std_logic;
         desel_all_cells : out std_logic;
         ramp_period     : out std_logic;
         precharge_bus   : out std_logic;
         analog_state    : out std_logic_vector(2 downto 0);
         read_state      : out std_logic_vector(2 downto 0);
         reg_data        : out std_logic;
         reg_wr_ena      : out std_logic;
         rdback          : in  std_logic
         );
   end component;



   -- Local signals
   signal v8_command         : std_logic;
   signal v8_data_out        : std_logic;
   signal v8_out_reset_l     : std_logic;
   signal v8_int_reset_l     : std_logic;
   signal v8_reg_clock       : std_logic;
   signal v8_reg_sel1        : std_logic;
   signal v8_reg_sel0        : std_logic;
   signal v8_pwr_up_acq      : std_logic;
   signal v8_reset_load      : std_logic;
   signal v8_leakage_null    : std_logic;
   signal v8_offset_null     : std_logic;
   signal v8_thresh_off      : std_logic;
   signal v8_trig_inh        : std_logic;
   signal v8_cal_strobe      : std_logic;
   signal v8_pwr_up_acq_dig  : std_logic;
   signal v8_sel_cell        : std_logic;
   signal v8_desel_all_cells : std_logic;
   signal v8_ramp_period     : std_logic;
   signal v8_precharge_bus   : std_logic;
   signal v8_reg_data        : std_logic;
   signal v8_reg_wr_ena      : std_logic;
   signal v8_analog_state    : std_logic_vector(2 downto 0);
   signal v8_read_state      : std_logic_vector(2 downto 0);
   signal reg_clock          : std_logic;
   signal reg_sel1           : std_logic;
   signal reg_sel0           : std_logic;
   signal pwr_up_acq         : std_logic;
   signal reset_load         : std_logic;
   signal leakage_null       : std_logic;
   signal offset_null        : std_logic;
   signal thresh_off         : std_logic;
   signal trig_inh           : std_logic;
   signal cal_strobe         : std_logic;
   signal pwr_up_acq_dig     : std_logic;
   signal sel_cell           : std_logic;
   signal desel_all_cells    : std_logic;
   signal ramp_period        : std_logic;
   signal precharge_bus      : std_logic;
   signal reg_data           : std_logic;
   signal reg_wr_ena         : std_logic;
   signal int_data_out       : std_logic;


   type RegType is record
      div        : sl;
      bunchCount : unsigned(12 downto 0);
      subCount   : unsigned(2 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType := (
      div        => '0',
      bunchCount => (others => '0'),
      subCount   => (others => '0'));

   signal r           : RegType := REG_INIT_C;
   signal rin         : RegType;
   signal regClkRise  : sl;
   signal kpixClkRise : sl;

begin

   calStrobeOut <= cal_strobe;

   -- Local copy of core, v8
   U_DigCore_v8 : memory_array_control port map (
      sysclk          => kpixClk,
      reset           => kpixReset,
      command         => v8_command,
      data_out        => v8_data_out,
      out_reset_l     => v8_out_reset_l,
      int_reset_l     => v8_int_reset_l,
      reg_clock       => v8_reg_clock,
      reg_sel1        => v8_reg_sel1,
      reg_sel0        => v8_reg_sel0,
      pwr_up_acq      => v8_pwr_up_acq,
      reset_load      => v8_reset_load,
      leakage_null    => v8_leakage_null,
      offset_null     => v8_offset_null,
      thresh_off      => v8_thresh_off,
      trig_inh        => v8_trig_inh,
      cal_strobe      => v8_cal_strobe,
      pwr_up_acq_dig  => v8_pwr_up_acq_dig,
      sel_cell        => v8_sel_cell,
      desel_all_cells => v8_desel_all_cells,
      ramp_period     => v8_ramp_period,
      precharge_bus   => v8_precharge_bus,
      reg_data        => v8_reg_data,
      reg_wr_ena      => v8_reg_wr_ena,
      rdback          => '0',
      analog_state    => v8_analog_state,
      read_state      => v8_read_state,
      temp_id0        => '0',
      temp_id1        => '0',
      temp_id2        => '0',
      temp_id3        => '0',
      temp_id4        => '0',
      temp_id5        => '0',
      temp_id6        => '0',
      temp_id7        => '0',
      temp_en         => open
      );

   -- Reset loopback
   v8_int_reset_l <= v8_out_reset_l;

   -- Enable inputs for active core
   v8_command <= kpixCmd;

   -- response data
   kpixData <= int_data_out;

   -- Choose outputs from active core
   int_data_out    <= v8_data_out;
   reg_clock       <= v8_reg_clock;
   reg_sel1        <= v8_reg_sel1;
   reg_sel0        <= v8_reg_sel0;
   pwr_up_acq      <= v8_pwr_up_acq;
   reset_load      <= v8_reset_load;
   leakage_null    <= v8_leakage_null;
   offset_null     <= v8_offset_null;
   thresh_off      <= v8_thresh_off;
   trig_inh        <= v8_trig_inh;
   cal_strobe      <= v8_cal_strobe;
   pwr_up_acq_dig  <= v8_pwr_up_acq_dig;
   sel_cell        <= v8_sel_cell;
   desel_all_cells <= v8_desel_all_cells;
   ramp_period     <= v8_ramp_period;
   precharge_bus   <= v8_precharge_bus;
   reg_data        <= v8_reg_data;
   reg_wr_ena      <= v8_reg_wr_ena;


   -------------------------------------------------------------------------------------------------
   -- Synchronize kpix signals to clk200
   -- Not really necessary since clk200 and kpixClk have synchronous edges,
   -- but it's easy to do edge detection this way.
   -------------------------------------------------------------------------------------------------
   SynchronizerEdge_KpixClk : entity work.SynchronizerEdge
      generic map (
         TPD_G => DELAY_G)
      port map (
         clk         => clk200,
         rst         => rst200,
         dataIn      => kpixClk,
         dataOut     => open,
         risingEdge  => kpixClkRise,
         fallingEdge => open);

   SynchronizerEdge_RegClk : entity work.SynchronizerEdge
      generic map (
         TPD_G => DELAY_G)
      port map (
         clk         => clk200,
         rst         => rst200,
         dataIn      => reg_clock,
         dataOut     => open,
         risingEdge  => regClkRise,
         fallingEdge => open);

   --------------------------------------------------------------------------------------------------
   -- Generate subCount and bunchCount
   --------------------------------------------------------------------------------------------------
   process (clk200) is
   begin
      if rising_edge(clk200) then
         if (rst200 = '1') then
            r <= REG_INIT_C after DELAY_G;
         else
            r <= rin after DELAY_G;
         end if;
      end if;
   end process;

   comb : process (r, v8_analog_state, regClkRise, kpixClkRise) is
      variable v : RegType;
   begin
      v := r;

      if (kpixClkRise = '1') then
         v.subCount := r.subCount + 1;
      end if;

      -- v8_analog_state clock boundary crossing
      -- Ok for now but maybe there's a better way to do this
      if (v8_analog_state = KPIX_ANALOG_SAMP_STATE_C) then
         if (regClkRise = '1') then
            v.div := not r.div;
            if (r.div = '1') then
               v.bunchCount := r.bunchCount + 1;
               v.subCount   := (others => '0');
            end if;
         end if;
      else
         v.bunchCount := (others => '0');
      end if;

      rin <= v;
      
   end process comb;

   kpixState.analogState  <= v8_analog_state;
   kpixState.readoutState <= v8_read_state;
   kpixState.prechargeBus <= v8_precharge_bus;
   kpixState.trigInhibit  <= trig_inh;
   kpixState.bunchCount   <= slv(r.bunchCount);
   kpixState.subCount     <= slv(r.subCount);

   --------------------------------------------------------------------------------------------------
   -- Synchronize kpix core outputs to sysclk
   --------------------------------------------------------------------------------------------------

   SynchronizerFifo_KpixLocal : entity work.SynchronizerFifo
      generic map (
         TPD_G        => DELAY_G,
         BRAM_EN_G    => false,
         DATA_WIDTH_G => 24)
      port map (
         rst                => kpixClkRst,
         wr_clk             => kpixClk,
         din(23)            => trig_inh,
         din(22 downto 20)  => slv(r.subCount),
         din(19 downto 7)   => slv(r.bunchCount),
         din(6)             => v8_precharge_bus,
         din(5 downto 3)    => v8_read_state,
         din(2 downto 0)    => v8_analog_state,
         rd_clk             => sysClk,
         valid              => open,
         dout(23)           => sysKpixState.trigInhibit,
         dout(22 downto 20) => sysKpixState.subCount,
         dout(19 downto 7)  => sysKpixState.bunchCount,
         dout(6)            => sysKpixState.prechargeBus,
         dout(5 downto 3)   => sysKpixState.readoutState,
         dout(2 downto 0)   => sysKpixState.analogState);

   --------------------------------------------------------------------------------------------------

   -- Mux for Debug Output A
   process (debugASel, reg_clock, reg_sel1, reg_sel0, pwr_up_acq, reset_load,
            leakage_null, offset_null, thresh_off, v8_trig_inh, cal_strobe,
            pwr_up_acq_dig, sel_cell, desel_all_cells, ramp_period,
            precharge_bus, reg_data, reg_wr_ena, kpixClk)
   begin
      case debugASel is
         when "00000" => debugOutA <= not reg_clock;
         when "00001" => debugOutA <= not reg_sel1;
         when "00010" => debugOutA <= not reg_sel0;
         when "00011" => debugOutA <= not pwr_up_acq;
         when "00100" => debugOutA <= not reset_load;
         when "00101" => debugOutA <= not leakage_null;
         when "00110" => debugOutA <= not offset_null;
         when "00111" => debugOutA <= not thresh_off;
         when "01000" => debugOutA <= not v8_trig_inh;
         when "01001" => debugOutA <= not cal_strobe;
         when "01010" => debugOutA <= not pwr_up_acq_dig;
         when "01011" => debugOutA <= not sel_cell;
         when "01100" => debugOutA <= not desel_all_cells;
         when "01101" => debugOutA <= not ramp_period;
         when "01110" => debugOutA <= not precharge_bus;
         when "01111" => debugOutA <= not reg_data;
         when "10000" => debugOutA <= not reg_wr_ena;
         when "10001" => debugOutA <= not kpixClk;
         when others  => debugOutA <= '1';
      end case;
   end process;


                                        -- Mux for BNC Output B
   process (debugBSel, reg_clock, reg_sel1, reg_sel0, pwr_up_acq, reset_load,
            leakage_null, offset_null, thresh_off, v8_trig_inh, cal_strobe,
            pwr_up_acq_dig, sel_cell, desel_all_cells, ramp_period,
            precharge_bus, reg_data, reg_wr_ena, kpixClk)
   begin
      case debugBSel is
         when "00000" => debugOutB <= not reg_clock;
         when "00001" => debugOutB <= not reg_sel1;
         when "00010" => debugOutB <= not reg_sel0;
         when "00011" => debugOutB <= not pwr_up_acq;
         when "00100" => debugOutB <= not reset_load;
         when "00101" => debugOutB <= not leakage_null;
         when "00110" => debugOutB <= not offset_null;
         when "00111" => debugOutB <= not thresh_off;
         when "01000" => debugOutB <= not v8_trig_inh;
         when "01001" => debugOutB <= not cal_strobe;
         when "01010" => debugOutB <= not pwr_up_acq_dig;
         when "01011" => debugOutB <= not sel_cell;
         when "01100" => debugOutB <= not desel_all_cells;
         when "01101" => debugOutB <= not ramp_period;
         when "01110" => debugOutB <= not precharge_bus;
         when "01111" => debugOutB <= not reg_data;
         when "10000" => debugOutB <= not reg_wr_ena;
         when "10001" => debugOutB <= not kpixClk;
         when others  => debugOutB <= not '0';
      end case;
   end process;

end KpixLocal;
