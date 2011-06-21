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

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixLocal is 
   port ( 

      -- Kpix clock, reset
      kpixClk       : in    std_logic;                       -- 20Mhz system clock
      kpixRst       : in    std_logic;                       -- System reset

      -- IO Ports
      bncOutA       : out   std_logic;                       -- BNC Interface A output
      bncOutB       : out   std_logic;                       -- BNC Interface B output
      nimInA        : in    std_logic;                       -- NIM Interface A input
      nimInB        : in    std_logic;                       -- NIM Interface B input
      bncInA        : in    std_logic;                       -- BNC Interface A input
      bncInB        : in    std_logic;                       -- BNC Interface B input

      -- Controls
      bncASel       : in    std_logic_vector(4 downto 0);    -- BNC Output A Select
      bncBSel       : in    std_logic_vector(4 downto 0);    -- BNC Output B Select

      -- Kpix Reset and force trigger
      reset         : in    std_logic;                       -- Kpix reset

      -- Kpix Serial Command Line 
      serData       : in    std_logic;                       -- Command data in

      -- Core state, Used for clock generation
      coreState     : out   std_logic_vector(2 downto 0);    -- Core state value

      -- Outgoing response line
      rspData       : out   std_logic;                       -- Response Data out

      -- Trigger force signal
      forceTrig     : out   std_logic;                       -- Force trigger signal

      -- Trigger control register
      trigControl   : in    std_logic_vector(31 downto 0);   -- Trigger control register

      -- kpix version
      kpixVer       : in    std_logic;                       -- Kpix Version 0=less than 8, 1=8+

      -- Bunch crossing
      kpixBunch     : out   std_logic_vector(12 downto 0);   -- Bunch count value

      -- Cal strobe out
      calStrobeOut  : out   std_logic
   );
end KpixLocal;


-- Define architecture
architecture KpixLocal of KpixLocal is

   -- Local copy of digital core, 8+ version
   component memory_array_control
      port (
         sysclk            : in  std_logic;
         reset             : in  std_logic;
         command           : in  std_logic;
         data_out          : out std_logic;
         temp_id0          : in  std_logic;
         temp_id1          : in  std_logic;
         temp_id2          : in  std_logic;
         temp_id3          : in  std_logic;
         temp_id4          : in  std_logic;
         temp_id5          : in  std_logic;
         temp_id6          : in  std_logic;
         temp_id7          : in  std_logic;
         temp_en           : out std_logic;
         out_reset_l       : out std_logic;
         int_reset_l       : in  std_logic;
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

   -- Local copy of digital core, 0-7 version
   component memory_array_control_v7
      port (
         sysclk            : in  std_logic;
         reset             : in  std_logic;
         command           : in  std_logic;
         data_out          : out std_logic;
         out_reset_l       : out std_logic;
         int_reset_l       : in  std_logic;
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
         analog_state0     : out std_logic;
         analog_state1     : out std_logic;
         read_state        : out std_logic;
         precharge_bus     : out std_logic;
         reg_data          : out std_logic;
         reg_wr_ena        : out std_logic;
         rdback            : in  std_logic
      );
   end component;


   -- Local signals
   signal v7_command         : std_logic;
   signal v7_data_out        : std_logic;
   signal v7_out_reset_l     : std_logic;
   signal v7_int_reset_l     : std_logic;
   signal v7_reg_clock       : std_logic;
   signal v7_reg_sel1        : std_logic;
   signal v7_reg_sel0        : std_logic;
   signal v7_pwr_up_acq      : std_logic;
   signal v7_reset_load      : std_logic;
   signal v7_leakage_null    : std_logic;
   signal v7_offset_null     : std_logic;
   signal v7_thresh_off      : std_logic;
   signal v7_trig_inh        : std_logic;
   signal v7_cal_strobe      : std_logic;
   signal v7_pwr_up_acq_dig  : std_logic;
   signal v7_sel_cell        : std_logic;
   signal v7_desel_all_cells : std_logic;
   signal v7_ramp_period     : std_logic;
   signal v7_precharge_bus   : std_logic;
   signal v7_reg_data        : std_logic;
   signal v7_reg_wr_ena      : std_logic;
   signal v7_analog_state0   : std_logic;
   signal v7_analog_state1   : std_logic;
   signal v7_read_state      : std_logic;
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
   signal trigEnable         : std_logic;
   signal trigCount          : std_logic_vector(2 downto 0);
   signal expandCount        : std_logic_vector(7 downto 0);
   signal intForceTrig       : std_logic;
   signal selForceTrig       : std_logic;
   signal edgeForceTrig      : std_logic;
   signal rstForceTrig       : std_logic;
   signal calStrobeDelay     : std_logic;
   signal calDelayShift      : std_logic_vector(255 downto 1);
   signal trigMask           : std_logic_vector(7 downto 0);
   signal bcPhase            : std_logic;
   signal bcReset            : std_logic;
   signal int_data_out       : std_logic;
   signal intBunchCount      : std_logic_vector(12 downto 0);
   signal intDiv             : std_logic;

begin

   -- Determine bunch clock phase
   process (reg_clock, reset_load) begin
      if reset_load = '1' then
         bcPhase <= '0' after tpd;
      elsif falling_edge(reg_clock) then
         if reg_sel0 = '0' and reg_sel1 = '1' then
            bcPhase <= not bcPhase after tpd;
         end if;
      end if;
   end process;

   calStrobeOut <= cal_strobe;

   -- Detect reset pulse
   bcReset <= reg_clock and (not bcPhase) and (not reg_sel0) and reg_sel1 after tpd;

   -- Local copy of core, v7
   U_DigCore_v7: memory_array_control_v7 port map (
      sysclk          => kpixClk,             reset           => reset,
      command         => v7_command,          data_out        => v7_data_out,
      out_reset_l     => v7_out_reset_l,      int_reset_l     => v7_int_reset_l,
      reg_clock       => v7_reg_clock,        reg_sel1        => v7_reg_sel1,
      reg_sel0        => v7_reg_sel0,         pwr_up_acq      => v7_pwr_up_acq,
      reset_load      => v7_reset_load,       leakage_null    => v7_leakage_null,
      offset_null     => v7_offset_null,      thresh_off      => v7_thresh_off,
      trig_inh        => v7_trig_inh,         cal_strobe      => v7_cal_strobe,
      pwr_up_acq_dig  => v7_pwr_up_acq_dig,   sel_cell        => v7_sel_cell,
      desel_all_cells => v7_desel_all_cells,  ramp_period     => v7_ramp_period,
      precharge_bus   => v7_precharge_bus,    reg_data        => v7_reg_data,
      reg_wr_ena      => v7_reg_wr_ena,       rdback          => '0',
      analog_state0   => v7_analog_state0,    analog_state1   => v7_analog_state1, 
      read_state      => v7_read_state
   );


   -- Local copy of core, v8
   U_DigCore_v8: memory_array_control port map (
      sysclk          => kpixClk,             reset           => reset,
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
      analog_state0   => v8_analog_state0,    analog_state1   => v8_analog_state1, 
      read_state      => v8_read_state,
      temp_id0        => '0',                 temp_id1        => '0',
      temp_id2        => '0',                 temp_id3        => '0',
      temp_id4        => '0',                 temp_id5        => '0',
      temp_id6        => '0',                 temp_id7        => '0',
      temp_en         => open
   );


   -- Reset loopback
   v7_int_reset_l <= v7_out_reset_l;
   v8_int_reset_l <= v8_out_reset_l;

   -- Enable inputs for active core
   v7_command <= serData and not kpixVer;
   v8_command <= serData and kpixVer;

   -- response data
   rspData <= int_data_out;

   -- Choose outputs from active core
   int_data_out    <= v7_data_out        when kpixVer = '0' else v8_data_out;
   reg_clock       <= v7_reg_clock       when kpixVer = '0' else v8_reg_clock;
   reg_sel1        <= v7_reg_sel1        when kpixVer = '0' else v8_reg_sel1;
   reg_sel0        <= v7_reg_sel0        when kpixVer = '0' else v8_reg_sel0;
   pwr_up_acq      <= v7_pwr_up_acq      when kpixVer = '0' else v8_pwr_up_acq;
   reset_load      <= v7_reset_load      when kpixVer = '0' else v8_reset_load;
   leakage_null    <= v7_leakage_null    when kpixVer = '0' else v8_leakage_null;
   offset_null     <= v7_offset_null     when kpixVer = '0' else v8_offset_null;
   thresh_off      <= v7_thresh_off      when kpixVer = '0' else v8_thresh_off;
   trig_inh        <= v7_trig_inh        when kpixVer = '0' else v8_trig_inh;
   cal_strobe      <= v7_cal_strobe      when kpixVer = '0' else v8_cal_strobe;
   pwr_up_acq_dig  <= v7_pwr_up_acq_dig  when kpixVer = '0' else v8_pwr_up_acq_dig;
   sel_cell        <= v7_sel_cell        when kpixVer = '0' else v8_sel_cell;
   desel_all_cells <= v7_desel_all_cells when kpixVer = '0' else v8_desel_all_cells;
   ramp_period     <= v7_ramp_period     when kpixVer = '0' else v8_ramp_period;
   precharge_bus   <= v7_precharge_bus   when kpixVer = '0' else v8_precharge_bus;
   reg_data        <= v7_reg_data        when kpixVer = '0' else v8_reg_data;
   reg_wr_ena      <= v7_reg_wr_ena      when kpixVer = '0' else v8_reg_wr_ena;
   coreState(0)    <= v7_analog_state0   when kpixVer = '0' else v8_analog_state0;
   coreState(1)    <= v7_analog_state1   when kpixVer = '0' else v8_analog_state1;
   coreState(2)    <= v7_read_state      when kpixVer = '0' else v8_read_state;



   -- Bunch clock counter
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         intBunchCount <= (others=>'0') after tpd;
         intDiv        <= '0'           after tpd;
      elsif falling_edge(kpixClk) then

         -- Bunch clock is running
         if reg_sel1 = '1' and reg_sel0 = '0' then
            if reg_clock = '1' then
               if intDiv = '1' then
                  intBunchCount <= intBunchCount + 1 after tpd;
               end if;
               intDiv <= not intDiv after tpd;
            end if;

         -- Otherwise reset
         else 
            intBunchCount <= (others=>'0') after tpd;
            intDiv        <= '0'           after tpd;
         end if;
      end if;
   end process;
   kpixBunch <= intBunchCount;


   -- Select forceTrig source
   process (trigControl, cal_strobe, nimInA, nimInB, bncInA, bncInB, calStrobeDelay ) begin
      case trigControl(27 downto 24) is
         when "0000"  => selForceTrig <= '0';
         when "0001"  => selForceTrig <= cal_strobe;
         when "0010"  => selForceTrig <= not nimInA;
         when "0011"  => selForceTrig <= not nimInB;
         when "0100"  => selForceTrig <= not bncInA;
         when "0101"  => selForceTrig <= not bncInB;
         when "0110"  => selForceTrig <= not nimInA; -- Gated below
         when "0111"  => selForceTrig <= not nimInB; -- Gated below
         when "1000"  => selForceTrig <= not bncInA; -- Gated below
         when "1001"  => selForceTrig <= not bncInB; -- Gated below
         when "1010"  => selForceTrig <= calStrobeDelay;
         when others  => selForceTrig <= '0';
      end case;
   end process;


   -- Detect rising edge of force trigger signal
   process (selForceTrig,rstForceTrig) begin
      if rstForceTrig = '1' then
         edgeForceTrig <= '0';
      elsif rising_edge(selForceTrig) then

         -- Gated version of inputs
         case trigControl(27 downto 24) is
            when "0110"  => edgeForceTrig <= trigEnable and not trig_inh after tpd;
            when "0111"  => edgeForceTrig <= trigEnable and not trig_inh after tpd;
            when "1000"  => edgeForceTrig <= trigEnable and not trig_inh after tpd;
            when "1001"  => edgeForceTrig <= trigEnable and not trig_inh after tpd;
            when others  => edgeForceTrig <= '1'        and not trig_inh after tpd;
         end case;
      end if;
   end process;


   -- Force trigger output
   forceTrig <= edgeForceTrig;

   -- Trigger strobe width control
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         rstForceTrig <= '0'           after tpd;
         intForceTrig <= '0'           after tpd;
         expandCount  <= (others=>'0') after tpd;
      elsif falling_edge(kpixClk) then

         -- Sync force trigger signal
         intForceTrig <= edgeForceTrig;

         -- Expand is not enabled
         if trigControl(15 downto 8) = 0 then
            rstForceTrig <= (not selForceTrig) and edgeForceTrig after tpd;

         -- Expand count is at max
         elsif expandCount = trigControl(15 downto 8) then
            expandCount  <= (others=>'0') after tpd;
            rstForceTrig <= '1'           after tpd;

         -- Run expand counter when trigger is asserted
         elsif intForceTrig = '1' then
            expandCount  <= expandCount + 1 after tpd;
            rstForceTrig <= '0'             after tpd;

         -- All other cases
         else
            rstForceTrig <= '0' after tpd;
         end if;
      end if;
   end process;


   -- Adjust window mask, Causes problem for first bunch clock
   trigMask(0) <= trigControl(1);
   trigMask(1) <= trigControl(2);
   trigMask(2) <= trigControl(3);
   trigMask(3) <= trigControl(4);
   trigMask(4) <= trigControl(5);
   trigMask(5) <= trigControl(6);
   trigMask(6) <= trigControl(7);
   trigMask(7) <= trigControl(0);

   -- Trigger enable window generation.
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         trigCount  <= (others=>'0') after tpd;
         trigEnable <= '1'           after tpd;
      elsif falling_edge(kpixClk) then

         -- Run counter while in bunch clock mode
         if reg_sel1 = '1' and reg_sel0 = '0' and pwr_up_acq = '1' then
            trigCount <= trigCount + 1 after tpd;

            -- Decode window
            if trigMask(conv_integer(trigCount)) = '1' then
               trigEnable <= '1' after tpd;
            else
               trigEnable <= '0' after tpd;
            end if;

         -- Otherwise reset counter
         else
            trigCount  <= (others=>'0') after tpd;
            trigenable <= '0'           after tpd;
         end if;
      end if;
   end process;


   -- Cal strobe delay generation
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         calStrobeDelay <= '0'           after tpd;
         calDelayShift  <= (others=>'0') after tpd;
      elsif falling_edge(kpixClk) then

         -- Shift register
         calDelayShift <= calDelayShift(254 downto 1) & cal_strobe after tpd;

         -- Shift tap
         if trigControl(23 downto 16) = 0 then
            calStrobeDelay <= cal_strobe;
         else
            calStrobeDelay <= calDelayShift(conv_integer(trigControl(23 downto 16))) after tpd;
         end if;
      end if;
   end process;


   -- Mux for BNC Output A
   process (bncASel, reg_clock, reg_sel1, reg_sel0, pwr_up_acq, reset_load,
            leakage_null, offset_null, thresh_off, trig_inh, cal_strobe,
            pwr_up_acq_dig, sel_cell, desel_all_cells, ramp_period,
            precharge_bus, reg_data, reg_wr_ena, kpixClk, bcPhase, edgeForceTrig,
            trigEnable, calStrobeDelay, nimInA, nimInB, bncInA, bncInB ) begin
      case bncASel is
         when "00000" => bncOutA <= not reg_clock;
         when "00001" => bncOutA <= not reg_sel1;
         when "00010" => bncOutA <= not reg_sel0;
         when "00011" => bncOutA <= not pwr_up_acq;
         when "00100" => bncOutA <= not reset_load;
         when "00101" => bncOutA <= not leakage_null;
         when "00110" => bncOutA <= not offset_null;
         when "00111" => bncOutA <= not thresh_off;
         when "01000" => bncOutA <= not trig_inh;
         when "01001" => bncOutA <= not cal_strobe;
         when "01010" => bncOutA <= not pwr_up_acq_dig;
         when "01011" => bncOutA <= not sel_cell;
         when "01100" => bncOutA <= not desel_all_cells;
         when "01101" => bncOutA <= not ramp_period;
         when "01110" => bncOutA <= not precharge_bus;
         when "01111" => bncOutA <= not reg_data;
         when "10000" => bncOutA <= not reg_wr_ena;
         when "10001" => bncOutA <= not kpixClk;
         when "10010" => bncOutA <= not edgeForceTrig;
         when "10011" => bncOutA <= not trigEnable;
         when "10100" => bncOutA <= not calStrobeDelay;
         when "10101" => bncOutA <= nimInA;
         when "10110" => bncOutA <= nimInB;
         when "10111" => bncOutA <= bncInA;
         when "11000" => bncOutA <= bncInB;
         when "11001" => bncOutA <= not bcPhase;
         when others  => bncOutA <= '1';
      end case;
   end process;


   -- Mux for BNC Output B
   process (bncBSel, reg_clock, reg_sel1, reg_sel0, pwr_up_acq, reset_load,
            leakage_null, offset_null, thresh_off, trig_inh, cal_strobe,
            pwr_up_acq_dig, sel_cell, desel_all_cells, ramp_period,
            precharge_bus, reg_data, reg_wr_ena, kpixClk, bcPhase, edgeForceTrig,
            trigEnable, calStrobeDelay, nimInA, nimInB, bncInA, bncInB ) begin
      case bncBSel is
         when "00000" => bncOutB <= not reg_clock;
         when "00001" => bncOutB <= not reg_sel1;
         when "00010" => bncOutB <= not reg_sel0;
         when "00011" => bncOutB <= not pwr_up_acq;
         when "00100" => bncOutB <= not reset_load;
         when "00101" => bncOutB <= not leakage_null;
         when "00110" => bncOutB <= not offset_null;
         when "00111" => bncOutB <= not thresh_off;
         when "01000" => bncOutB <= not trig_inh;
         when "01001" => bncOutB <= not cal_strobe;
         when "01010" => bncOutB <= not pwr_up_acq_dig;
         when "01011" => bncOutB <= not sel_cell;
         when "01100" => bncOutB <= not desel_all_cells;
         when "01101" => bncOutB <= not ramp_period;
         when "01110" => bncOutB <= not precharge_bus;
         when "01111" => bncOutB <= not reg_data;
         when "10000" => bncOutB <= not reg_wr_ena;
         when "10001" => bncOutB <= not kpixClk;
         when "10010" => bncOutB <= not edgeForceTrig;
         when "10011" => bncOutB <= not trigEnable;
         when "10100" => bncOutB <= not calStrobeDelay;
         when "10101" => bncOutB <= nimInA;
         when "10110" => bncOutB <= nimInB;
         when "10111" => bncOutB <= bncInA;
         when "11000" => bncOutB <= bncInB;
         when "11001" => bncOutB <= not bcPhase;
         when others  => bncOutB <= not '0';
      end case;
   end process;

end KpixLocal;

