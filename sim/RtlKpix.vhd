-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA, KPIX Core RTL Simlulation
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : RtlKpix.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Simulation wrapper for KPIX RTL Digital Core
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;

entity RtlKpix is 
   port ( 
      ext_clk           : in  std_logic;
      reset_c           : in  std_logic;
      trig              : in  std_logic;
      command_c         : in  std_logic;
      rdback_p          : out std_logic
   );
end RtlKpix;


-- Define architecture
architecture RtlKpix of RtlKpix is

   -- Local copy of digital core, 8+ version
   component memory_array_control
      port (
         sysclk            : in  std_logic;
         reset             : in  std_logic;
         command           : in  std_logic;
         data_out          : out std_logic;
         out_reset_l       : out std_logic;
         int_reset_l       : in  std_logic;
         temp_id0          : in  std_logic;
         temp_id1          : in  std_logic;
         temp_id2          : in  std_logic;
         temp_id3          : in  std_logic;
         temp_id4          : in  std_logic;
         temp_id5          : in  std_logic;
         temp_id6          : in  std_logic;
         temp_id7          : in  std_logic;
         temp_en           : out std_logic;
         reg_clock         : out std_logic;
         reg_sel1          : out std_logic;
         reg_sel0          : out std_logic;
         pwr_up_acq        : out std_logic;
         reset_load        : out std_logic;
         leakage_null      : out std_logic;
         offset_null       : out std_logic;
         thresh_off        : out std_logic;
         trig_inh          : out std_logic;
         cal_strobe        : out std_logic;
         pwr_up_acq_dig    : out std_logic;
         sel_cell          : out std_logic;
         desel_all_cells   : out std_logic;
         ramp_period       : out std_logic;
         precharge_bus     : out std_logic;
         analog_state0     : out std_logic;
         analog_state1     : out std_logic;
         read_state        : out std_logic;
         reg_data          : out std_logic;
         reg_wr_ena        : out std_logic;
         rdback            : in  std_logic
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
   signal v8_analog_state0   : std_logic;
   signal v8_analog_state1   : std_logic;
   signal v8_read_state      : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Local copy of core, v8
   U_DigCore_v8: memory_array_control port map (
      sysclk          => ext_clk,             reset           => reset_c,
      command         => v8_command,          data_out        => v8_data_out,
      out_reset_l     => v8_out_reset_l,      int_reset_l     => v8_int_reset_l,
      reg_clock       => v8_reg_clock,        reg_sel1        => v8_reg_sel1,
      reg_sel0        => v8_reg_sel0,         pwr_up_acq      => v8_pwr_up_acq,
      reset_load      => v8_reset_load,       leakage_null    => v8_leakage_null,
      offset_null     => v8_offset_null,      thresh_off      => v8_thresh_off,
      trig_inh        => v8_trig_inh,         cal_strobe      => v8_cal_strobe,
      pwr_up_acq_dig  => v8_pwr_up_acq_dig,   sel_cell        => v8_sel_cell,
      desel_all_cells => v8_desel_all_cells,  ramp_period     => v8_ramp_period,
      precharge_bus   => v8_precharge_bus,    reg_data        => v8_reg_data,
      reg_wr_ena      => v8_reg_wr_ena,       rdback          => '0',
      analog_state0   => v8_analog_state0,
      analog_state1   => v8_analog_state1,
      read_state      => v8_read_state,
      temp_id0        => '0',                 temp_id1        => '0',
      temp_id2        => '0',                 temp_id3        => '0',
      temp_id4        => '0',                 temp_id5        => '0',
      temp_id6        => '0',                 temp_id7        => '0',
      temp_en         => open
   );

   -- Reset loopback
   v8_int_reset_l <= v8_out_reset_l;

   -- Enable inputs for active core
   v8_command <= command_c;

   -- response data
   rdback_p <= v8_data_out;

end RtlKpix;

