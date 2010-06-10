-------------------------------------------------------------------------------
-- Title         : W_Si Chip Memory Array Controller
-- Project       : W_Si Chip
-------------------------------------------------------------------------------
-- File          : memory_array_control_v7.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/22/2005
-------------------------------------------------------------------------------
-- Description:
-- Top level module for VHDL portion of W_Si chip. This module is responsible
-- for controlling data sampling, digitization and readout.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 by SLAC. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/22/2005: created.
-- 05/11/2005: Added enable signals for each of the 4 calibration pulses
-- 05/25/2005: Changed logic to support external address register in analog logic
-- 05/27/2005: Removed threshod lock and trigger inhibit signals
-- 05/27/2005: Removed dac_current_on & power_up_acquisition signals.
-- 05/27/2005: Multiplexed precharge_ana_bus & precharge_dig_bus.
-- 06/02/2005: Multiplexed register, bunch, counter & readout clocks
-- 06/03/2005: Removed bunch_clock_late since it will now be multiplexed
-- 06/09/2005: Combined select_amp(3:0) into single net select_amp.
-- 06/09/2005: Removed clear_row_shift, will now be reset by analog_rst.
-- 06/10/2005: Changed names of signals to match analog netlist
-- 06/13/2005: Added pwr_up_acq back, removed incr_cell_value (load used to incr)
-- 07/21/2005: Put back trigger_inhibit & threshold_lock
-- 08/08/2005: Changed timing control signals
-- 08/11/2005: Changed to async reset
-- 08/16/2005: Changed thresh_off and trig_inh signal names
-- 08/23/2005: Changed reg_sel[1:0] to reg_sel1 & reg_sel0.
-- 08/30/2005: Created external reset loopback for proper synthesis
-- 08/30/2005: Changed reset polarity
-- 08/30/2005: Moved register of incoming read data to top level
-- 02/05/2009: Added read state tracking for FPGA core. Not in real asic.
-------------------------------------------------------------------------------

use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity memory_array_control_v7 is port ( 

      -- Signals to external IO pads
      sysclk            : in  std_logic;
      reset             : in  std_logic;
      command           : in  std_logic;
      data_out          : out std_logic;

      -- Reset loopback
      out_reset_l       : out std_logic;
      int_reset_l       : in  std_logic;

      -- Multipurpose clock
      reg_clock         : out std_logic;
      reg_sel1          : out std_logic;
      reg_sel0          : out std_logic;

      -- Initialization signals
      pwr_up_acq        : out std_logic;
      reset_load        : out std_logic;
      leakage_null      : out std_logic;
      offset_null       : out std_logic;
      thresh_off        : out std_logic;
      trig_inh          : out std_logic;
 
      -- Calibration Signal
      cal_strobe        : out std_logic;

      -- Digitization signals
      pwr_up_acq_dig    : out std_logic;
      sel_cell          : out std_logic;
      desel_all_cells   : out std_logic;
      ramp_period       : out std_logic;
      precharge_bus     : out std_logic;

      -- State Outputs
      analog_state      : out std_logic;
      read_state        : out std_logic;

      -- Configuration
      reg_data          : out std_logic;
      reg_wr_ena        : out std_logic;
      rdback            : in  std_logic
   );

end memory_array_control_v7;


architecture memory_array_control_v7 of memory_array_control_v7 is

   -- Command controller
   component command_control_v7
      port (
         sysclk            : in  std_logic;
         int_reset_l       : in  std_logic;
         command           : in  std_logic;
         chip_address      : in  std_logic_vector(6 downto 0);
         resp_data_out     : out std_logic;
         start_sequence    : out std_logic;
         start_calibrate   : out std_logic;
         cmd_reset         : out std_logic;
         tc0_data          : out std_logic_vector(31 downto 0);
         tc1_data          : out std_logic_vector(31 downto 0);
         tc2_data          : out std_logic_vector(31 downto 0);
         tc3_data          : out std_logic_vector(31 downto 0);
         tc4_data          : out std_logic_vector(31 downto 0);
         tc5_data          : out std_logic_vector(31 downto 0);
         tc6_data          : out std_logic_vector(31 downto 0);
         tc7_data          : out std_logic_vector(31 downto 0);
         cd0_data          : out std_logic_vector(31 downto 0);
         cd1_data          : out std_logic_vector(31 downto 0);
         sparse_en         : out std_logic;
         test_mode         : out std_logic;
         test_data_clk_en  : out std_logic;
         reg_data          : out std_logic;
         reg_clk_en        : out std_logic;
         reg_wr_ena        : out std_logic;
         sel_addr_reg      : out std_logic;
         int_rdback        : in  std_logic 
      );
   end component;

   -- Analog controller
   component analog_control_v7
      port (
         sysclk            : in  std_logic;  -- 23.74Mhz Clock
         int_reset_l       : in  std_logic;  -- Master reset
         start_sequence    : in  std_logic;
         start_calibrate   : in  std_logic;
         pwr_up_acq        : out std_logic;
         analog_reset      : out std_logic;
         leakage_null      : out std_logic;
         offset_null       : out std_logic;
         thresh_off        : out std_logic;
         trig_inh          : out std_logic;
         bunch_clock       : out std_logic;
         counter_clock_en  : out std_logic;
         bunch_clock_en    : out std_logic;
         pwr_up_acq_dig    : out std_logic;
         sel_cell          : out std_logic;
         desel_all_cells   : out std_logic;
         ramp_period       : out std_logic;
         precharge_ana_bus : out std_logic;
         cal_strobe        : out std_logic;
         tc0_data          : in  std_logic_vector(31 downto 0);
         tc1_data          : in  std_logic_vector(31 downto 0);
         tc2_data          : in  std_logic_vector(31 downto 0);
         tc3_data          : in  std_logic_vector(31 downto 0);
         tc4_data          : in  std_logic_vector(31 downto 0);
         tc5_data          : in  std_logic_vector(31 downto 0);
         tc6_data          : in  std_logic_vector(31 downto 0);
         tc7_data          : in  std_logic_vector(31 downto 0);
         cd0_data          : in  std_logic_vector(31 downto 0);
         cd1_data          : in  std_logic_vector(31 downto 0);
         readout_start     : out std_logic;
         analog_state      : out std_logic
      );
   end component;

   -- Readout controller
   component readout_control_v7
      port (
         sysclk              : in  std_logic;  -- 23.74Mhz Clock
         int_reset_l         : in  std_logic;  -- Master reset
         chip_address        : in  std_logic_vector(6 downto 0);
         readout_start       : in  std_logic;
         sparse_en           : in  std_logic;
         test_mode           : in  std_logic;
         read_state          : out std_logic;
         precharge_dig_bus   : out std_logic;
         load_shift_reg      : out std_logic;
         read_shift_clock_en : out std_logic;
         int_rdback          : in  std_logic;
         sample_data_out     : out std_logic
      );
   end component;

   -- Local Signals
   signal start_sequence      : std_logic;
   signal start_calibrate     : std_logic;
   signal cmd_reset           : std_logic;
   signal tc0_data            : std_logic_vector(31 downto 0);
   signal tc1_data            : std_logic_vector(31 downto 0);
   signal tc2_data            : std_logic_vector(31 downto 0);
   signal tc3_data            : std_logic_vector(31 downto 0);
   signal tc4_data            : std_logic_vector(31 downto 0);
   signal tc5_data            : std_logic_vector(31 downto 0);
   signal tc6_data            : std_logic_vector(31 downto 0);
   signal tc7_data            : std_logic_vector(31 downto 0);
   signal cd0_data            : std_logic_vector(31 downto 0);
   signal cd1_data            : std_logic_vector(31 downto 0);
   signal sparse_en           : std_logic;
   signal test_mode           : std_logic;
   signal readout_start       : std_logic;
   signal sample_data_out     : std_logic;
   signal resp_data_out       : std_logic;
   signal precharge_ana_bus   : std_logic;
   signal precharge_dig_bus   : std_logic;
   signal bunch_clock         : std_logic;
   signal bunch_clock_en      : std_logic;
   signal counter_clock_en    : std_logic;
   signal sel_addr_reg        : std_logic;
   signal reg_clk_en          : std_logic;
   signal read_shift_clock_en : std_logic;
   signal test_data_clk_en    : std_logic;
   signal analog_reset        : std_logic;
   signal load_shift_reg      : std_logic;
   signal int_rdback          : std_logic;
   signal chip_address        : std_logic_vector(6 downto 0);

begin

   -- Fake out chip address
   chip_address <= "0000000";

   -- Reset is a multiplexed signal
   reset_load <= analog_reset or load_shift_reg;

   -- Register reset signal before distribution, combine with
   -- reset from command controller
   -- This signal will exit the block and re-enter as an
   -- infinite drive signal
   process (sysclk) begin
      if ( rising_edge(sysclk) ) then
         out_reset_l <= not (reset or cmd_reset) after 1 ns;
      end if;
   end process;


   -- Register incoming data from registers
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         int_rdback <= '0' after 1 ns;
      elsif falling_edge(sysclk) then
         int_rdback <= rdback after 1 ns;
      end if;
   end process;


   -- Connect output serial data stream
   process (sysclk, int_reset_l) begin
      if ( int_reset_l = '0' ) then
         data_out <= '0' after 1 ns;

      elsif ( rising_edge(sysclk) ) then
         data_out <= sample_data_out or resp_data_out after 1 ns;
      end if;
   end process;

   -- Multiplex precharge signals. These signals are de-multiplexed in the analog
   -- logic using the power_up_acquisit(leakage_null) signal
   precharge_bus <= precharge_ana_bus or precharge_dig_bus;


   -- Multiplex clock signals
   process ( sel_addr_reg, reg_clk_en, bunch_clock_en, bunch_clock, 
             counter_clock_en, read_shift_clock_en, test_data_clk_en, sysclk  ) begin

      -- Address register shift
      if ( sel_addr_reg = '1' ) then
         reg_sel1  <= '0';
         reg_sel0  <= '0';
         reg_clock <= not sysclk;

      -- Configuration shift clock
      elsif ( reg_clk_en = '1' ) then
         reg_sel1  <= '0';
         reg_sel0  <= '1';
         reg_clock <= not sysclk;

      -- Bunch clock during acquisition
      elsif ( bunch_clock_en = '1' ) then
         reg_sel1  <= '1';
         reg_sel0  <= '0';
         reg_clock <= bunch_clock;

      -- Counter clock during digitization
      elsif ( counter_clock_en = '1' ) then
         reg_sel1  <= '1';
         reg_sel0  <= '0';
         reg_clock <= not sysclk;

      -- Shift data clock
      elsif ( test_data_clk_en = '1' or read_shift_clock_en = '1' ) then
         reg_sel1  <= '1';
         reg_sel0  <= '1';
         reg_clock <= not sysclk;

      -- Idle
      else
         reg_sel1  <= '0';
         reg_sel0  <= '0';
         reg_clock <= '0';
      end if;
   end process;


   -- Command controller
   U_command_control: command_control_v7 port map (
      sysclk            => sysclk,            int_reset_l       => int_reset_l,
      command           => command,           chip_address      => chip_address,
      resp_data_out     => resp_data_out,     start_sequence    => start_sequence,
      start_calibrate   => start_calibrate,   cmd_reset         => cmd_reset,
      tc0_data          => tc0_data,          tc1_data          => tc1_data,
      tc2_data          => tc2_data,          tc3_data          => tc3_data,
      tc4_data          => tc4_data,          tc5_data          => tc5_data,
      tc6_data          => tc6_data,          tc7_data          => tc7_data,
      cd0_data          => cd0_data,          cd1_data          => cd1_data,
      sparse_en         => sparse_en,         test_mode         => test_mode,
      test_data_clk_en  => test_data_clk_en,  reg_data          => reg_data,
      reg_clk_en        => reg_clk_en,        reg_wr_ena        => reg_wr_ena,
      sel_addr_reg      => sel_addr_reg,      int_rdback        => int_rdback
   );

   -- Analog logic controller
   U_analog_control: analog_control_v7 port map (
      sysclk            => sysclk,             int_reset_l       => int_reset_l,
      start_sequence    => start_sequence,     start_calibrate   => start_calibrate,
      pwr_up_acq        => pwr_up_acq,         analog_reset      => analog_reset,
      leakage_null      => leakage_null,       offset_null       => offset_null,
      trig_inh          => trig_inh,           thresh_off        => thresh_off,
      bunch_clock       => bunch_clock,        counter_clock_en  => counter_clock_en,
      readout_start     => readout_start,      bunch_clock_en    => bunch_clock_en,
      pwr_up_acq_dig    => pwr_up_acq_dig,     sel_cell          => sel_cell,
      desel_all_cells   => desel_all_cells,    ramp_period       => ramp_period,
      precharge_ana_bus => precharge_ana_bus,  cal_strobe        => cal_strobe,
      tc0_data          => tc0_data,           tc1_data          => tc1_data,
      tc2_data          => tc2_data,           tc3_data          => tc3_data,
      tc4_data          => tc4_data,           tc5_data          => tc5_data,
      tc6_data          => tc6_data,           tc7_data          => tc7_data,
      cd0_data          => cd0_data,           cd1_data          => cd1_data,
      analog_state      => analog_state
   );

   -- Readout controller
   U_readout_control: readout_control_v7 port map (
      sysclk              => sysclk,                int_reset_l     => int_reset_l,
      chip_address        => chip_address,          readout_start   => readout_start,
      sparse_en           => sparse_en,             test_mode       => test_mode,
      precharge_dig_bus   => precharge_dig_bus,     load_shift_reg  => load_shift_reg,
      read_shift_clock_en => read_shift_clock_en,   int_rdback      => int_rdback,
      sample_data_out     => sample_data_out,       read_state      => read_state
   );


end memory_array_control_v7;
