-------------------------------------------------------------------------------
-- Title         : W_Si Chip Analog Controller
-- Project       : W_Si Chip
-------------------------------------------------------------------------------
-- File          : analog_control.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/26/2005
-------------------------------------------------------------------------------
-- Description:
-- This state machine controls the signals used for sampling and digitization.
-------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/26/2005: created.
-- 05/11/2005: Added enable signals for each of the 4 calibration pulses
-- 05/12/2005: Moved OFFSET_NULL et all assertion to pause state
-- 05/27/2005: Removed threshod lock and trigger inhibit signals
-- 05/27/2005: Removed dac_current_on & power_up_acquisition signals.
-- 06/02/2005: Multiplexed counter_clock & bunch_clock_early
-- 06/03/2005: Mutliplexed bunch_clock signals into a single signal
-- 06/09/2005: Combined sel_cell(3:0) into single net sel_cell.
-- 06/10/2005: Changed sel_cell to sel_cell and made it a wider pulse.
-- 06/13/2005: Added pwr_up_acq back in
-- 06/18/2005: Fixed timing of mst_cnt_rst during digitization
-- 07/06/2005: Adjusted calibration strobe timing
-- 07/21/2005: Put back trigger_inhibit & threshold_lock
-- 08/08/2005: Changed logic for more control over on/off timing signals.
-- 08/09/2005: Modified handshake between master & cal state machines.
-- 08/09/2005: Registered cal control signals for better timing.
-- 08/11/2005: Changed to async reset / preset
-- 08/16/2005: Changed thresh_off and trig_inh signal names
-- 08/30/2005: Changed reset polarity
-- 08/30/2005: Changed delay between deselect_all_cells and select_cell to ~500ns
-- 02/03/2009: Changed width of some counters. trig_inh, thresh_off & off_null
--             now turn on at the end. pwr_up_dig now turns off at the end.
--             added variable number of bunch crossings, up to 8192.
-- 02/05/2009: Added analog state tracking for FPGA core.
-- 03/16/2009: Fixed desel generation bug.
-- 04/22/2010: Added more detail in state tracking for FPGA core.
-------------------------------------------------------------------------------

use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity analog_control is port ( 

      -- Clock & Reset
      sysclk            : in  std_logic;
      int_reset_l       : in  std_logic;

      -- Incoming control signals
      start_sequence    : in  std_logic;  
      start_calibrate   : in  std_logic;  

      -- Initialization signals
      pwr_up_acq        : out std_logic;
      analog_reset      : out std_logic;  
      leakage_null      : out std_logic;  
      offset_null       : out std_logic;
      thresh_off        : out std_logic;
      trig_inh          : out std_logic;
 
      -- Acquisition signals
      bunch_clock       : out std_logic;
      counter_clock_en  : out std_logic;
      bunch_clock_en    : out std_logic;

      -- Digitization signals
      pwr_up_acq_dig    : out std_logic;
      sel_cell          : out std_logic;
      desel_all_cells   : out std_logic;
      ramp_period       : out std_logic;
      precharge_ana_bus : out std_logic;

      -- Calibration signal
      cal_strobe        : out std_logic;

      -- Timing configuration
      tc0_data          : in  std_logic_vector(31 downto 0);
      tc1_data          : in  std_logic_vector(31 downto 0);
      tc2_data          : in  std_logic_vector(31 downto 0);
      tc3_data          : in  std_logic_vector(31 downto 0);
      tc4_data          : in  std_logic_vector(31 downto 0);
      tc5_data          : in  std_logic_vector(31 downto 0);

      -- Calibration configuration
      cd0_data          : in  std_logic_vector(31 downto 0);
      cd1_data          : in  std_logic_vector(31 downto 0);

      -- Readout signals
      readout_start     : out std_logic;

      -- State output
      analog_state      : out std_logic_vector(1 downto 0)

   );

end analog_control;


-- Define architecture
architecture analog_control of analog_control is

   -- Local Signals
   signal mst_cnt               : std_logic_vector(31 downto 0); -- Reg: Master counter
   signal mst_cnt_rst           : std_logic;                     -- Sig: Master counter reset
   signal sub_cnt               : std_logic_vector(15 downto 0); -- Reg: Sub state counter
   signal sub_cnt_rst           : std_logic;                     -- Sig: Sub state counter reset
   signal nxt_sel_cell          : std_logic;                     -- Sig:
   signal int_sel_cell          : std_logic;                     -- Reg:
   signal nxt_desel_all_cells   : std_logic;                     -- Sig:
   signal int_desel_all_cells   : std_logic;                     -- Reg:
   signal sft_desel_all_cells   : std_logic_vector(16 downto 0); -- Reg:
   signal nxt_ramp_period       : std_logic;                     -- Sig:
   signal int_ramp_period       : std_logic;                     -- Reg:
   signal nxt_bunch_clock       : std_logic;                     -- Sig:
   signal int_bunch_clock       : std_logic;                     -- Reg:
   signal nxt_cur_cell          : std_logic_vector(3 downto 0);  -- Sig:
   signal int_cur_cell          : std_logic_vector(3 downto 0);  -- Reg:
   signal nxt_precharge_ana_bus : std_logic;                     -- Sig:
   signal int_precharge_ana_bus : std_logic;                     -- Reg:
   signal nxt_cal_strobe        : std_logic;                     -- Sig:
   signal int_cal_strobe        : std_logic;                     -- Reg:
   signal cal_cnt               : std_logic_vector(12 downto 0); -- Reg: Calib state counter
   signal cal_cnt_rst           : std_logic;                     -- Sig: Calib counter reset
   signal cal_cnt_en            : std_logic;                     -- Sig: Calib counter enable
   signal nxt_cal_pulse         : std_logic_vector(3  downto 0); -- Sig:
   signal int_cal_pulse         : std_logic_vector(3  downto 0); -- Reg:
   signal cal_dly               : std_logic_vector(12 downto 0); -- Reg: 
   signal cal_en                : std_logic;                     -- Reg: 
   signal cal_assert_en         : std_logic;                     -- Sig: 
   signal analog_on             : std_logic;                     -- Sig;
   signal nxt_analog_state      : std_logic_vector(1  downto 0); -- Sig;


   -- Master state
   signal mst_state     : std_logic_vector(2 downto 0);  -- Reg: Master state
   signal nxt_mst_state : std_logic_vector(2 downto 0);  -- Sig: Next master state

   -- Master State constants
   constant MS_IDLE   : std_logic_vector(2 downto 0) := "000";  -- Idle time
   constant MS_PRE    : std_logic_vector(2 downto 0) := "001";  -- Pre-Sample
   constant MS_SAMP   : std_logic_vector(2 downto 0) := "011";  -- Sample
   constant MS_PAUSE  : std_logic_vector(2 downto 0) := "010";  -- Pause
   constant MS_DIG    : std_logic_vector(2 downto 0) := "110";  -- Digitize
   constant MS_READ   : std_logic_vector(2 downto 0) := "100";  -- Read

   -- Calibration state
   signal cal_state     : std_logic_vector(1 downto 0);  -- Reg: Calibration state
   signal nxt_cal_state : std_logic_vector(1 downto 0);  -- Sig: Next calibration state

   -- Calibration State constants
   constant CAL_IDLE  : std_logic_vector(1 downto 0) := "00";  -- Idle time
   constant CAL_ARM   : std_logic_vector(1 downto 0) := "01";  -- Reset state
   constant CAL_PULSE : std_logic_vector(1 downto 0) := "11";  -- Pre-Sample

begin

   -- Connect Outputs
   bunch_clock       <= int_bunch_clock;
   sel_cell          <= int_sel_cell;
   desel_all_cells   <= int_desel_all_cells;
   ramp_period       <= int_ramp_period;
   precharge_ana_bus <= int_precharge_ana_bus;
   cal_strobe        <= int_cal_strobe;
   counter_clock_en  <= int_ramp_period;


   -- Master & sub counters
   process ( sysclk, int_reset_l ) begin
      if (int_reset_l = '0' ) then
         mst_cnt <= (others=>'0') after 1 ns;
         sub_cnt <= (others=>'0') after 1 ns;

      elsif rising_edge(sysclk) then

         -- Master counter
         if ( mst_cnt_rst = '1' ) then
            mst_cnt <= (others=>'0') after 1 ns;
         else
            mst_cnt <= mst_cnt + 1 after 1 ns;
         end if;

         -- Sub counter
         if ( sub_cnt_rst = '1' ) then
            sub_cnt <= (others=>'0') after 1 ns;
         else
            sub_cnt <= sub_cnt + 1 after 1 ns;
         end if;
      end if;
   end process;


   -- State transition logic
   process ( sysclk, int_reset_l ) begin
      if (int_reset_l = '0') then
         mst_state             <= MS_IDLE       after 1 ns;
         int_sel_cell          <= '0'           after 1 ns;
         int_ramp_period       <= '0'           after 1 ns;
         int_precharge_ana_bus <= '0'           after 1 ns;
         int_desel_all_cells   <= '0'           after 1 ns;
         sft_desel_all_cells   <= (others=>'0') after 1 ns;
         int_bunch_clock       <= '0'           after 1 ns;
         int_cur_cell          <= "0000"        after 1 ns;
         analog_state          <= "00"          after 1 ns;

      elsif rising_edge(sysclk) then
         mst_state             <= nxt_mst_state         after 1 ns;
         int_sel_cell          <= nxt_sel_cell          after 1 ns;
         int_ramp_period       <= nxt_ramp_period       after 1 ns;
         int_precharge_ana_bus <= nxt_precharge_ana_bus after 1 ns;
         int_bunch_clock       <= nxt_bunch_clock       after 1 ns;
         int_cur_cell          <= nxt_cur_cell          after 1 ns;
         analog_state          <= nxt_analog_state      after 1 ns;

         -- De-Select all amp is always ~84.25ns wide
         int_desel_all_cells  <=  
            nxt_desel_all_cells or 
               (int_desel_all_cells and not sft_desel_all_cells(0)) after 1 ns;

         -- Shift register for deselect signal
         sft_desel_all_cells(16 downto 1) <= sft_desel_all_cells(15 downto 0) after 1 ns;
         sft_desel_all_cells(0)           <= int_desel_all_cells              after 1 ns;

      end if;
   end process;


   -- State machine
   process ( mst_state, start_sequence, tc5_data, tc4_data, sft_desel_all_cells, int_sel_cell, 
             sub_cnt, int_cur_cell, int_desel_all_cells, int_ramp_period ) begin

      case mst_state is

         -- Idle, wait for sequence start
         when MS_IDLE =>

            -- Drive all signals to idle state
            nxt_sel_cell          <= '0';
            nxt_desel_all_cells   <= '0';
            nxt_ramp_period       <= '0';
            nxt_bunch_clock       <= '0';
            nxt_cur_cell          <= "0000";
            readout_start         <= '0';
            mst_cnt_rst           <= '1';
            sub_cnt_rst           <= '1';
            bunch_clock_en        <= '0';
            nxt_precharge_ana_bus <= '0';
            cal_assert_en         <= '0';
            analog_on             <= '0';
            nxt_analog_state      <= "00";

            -- Sequence start
            if ( start_sequence = '1' ) then
               nxt_mst_state      <= MS_PRE;
            else
               nxt_mst_state      <= mst_state;
            end if;


         -- Pre-Sampling preparations
         when MS_PRE =>

            -- Signals with no change in this state
            nxt_ramp_period       <= '0';
            nxt_bunch_clock       <= '0';
            nxt_cur_cell          <= "0000";
            readout_start         <= '0';
            mst_cnt_rst           <= '0';
            bunch_clock_en        <= '0';
            nxt_precharge_ana_bus <= '0';
            cal_assert_en         <= '0';
            analog_on             <= '1';
            nxt_analog_state      <= "01";

            -- Assert de-select all cells after a defined delay            
            -- Signal stays asserted for 100ns.
            if ( sub_cnt = tc5_data(7 downto 0) ) then
               nxt_desel_all_cells <= '1';
            else
               nxt_desel_all_cells <= '0';
            end if;

            -- Select follows desel_all_cells by ~168ns and is ~84.25ns wide
            nxt_sel_cell <= sft_desel_all_cells(12);

            -- End of state, configured delay 
            if ( sub_cnt = tc5_data(23 downto 8) ) then
               nxt_mst_state <= MS_SAMP;
               sub_cnt_rst   <= '1';
            else
               nxt_mst_state <= mst_state;
               sub_cnt_rst   <= '0';
            end if;


         -- Sampling
         when MS_SAMP =>

            -- Signals with no change in this state
            nxt_ramp_period       <= '0';
            nxt_cur_cell          <= "0000";
            readout_start         <= '0';
            mst_cnt_rst           <= '0';
            bunch_clock_en        <= '1';
            nxt_precharge_ana_bus <= '0';
            nxt_desel_all_cells   <= '0';
            nxt_sel_cell          <= '0';
            cal_assert_en         <= '1';
            analog_on             <= '1';
            nxt_analog_state      <= "01";

            -- Control early bunch clock
            if ( sub_cnt(2 downto 0) = "100" ) then
               nxt_bunch_clock <= '1';

            -- Control late bunch clock
            elsif ( sub_cnt(2 downto 0) = "110" ) then
               nxt_bunch_clock <= '1';
            else
               nxt_bunch_clock <= '0';
            end if;

            -- End of state config * 8 cycles
            if ( sub_cnt(15 downto 3) = tc4_data(12 downto 0) and sub_cnt(2 downto 0) = "111" ) then
               nxt_mst_state <= MS_PAUSE;
               sub_cnt_rst   <= '1';
            else
               nxt_mst_state <= mst_state;
               sub_cnt_rst   <= '0';
            end if;


         -- Pause before digitization
         when MS_PAUSE =>

            -- Signals with no change in this state
            nxt_ramp_period       <= '0';
            nxt_cur_cell          <= "0001";
            readout_start         <= '0';
            mst_cnt_rst           <= '0';
            bunch_clock_en        <= '0';
            nxt_sel_cell          <= '0';
            nxt_bunch_clock       <= '0';
            cal_assert_en         <= '0';

            -- Turn off analog signals after a few clocks
            if ( sub_cnt(7 downto 4) = 0 ) then
               analog_on          <= '1';
               nxt_analog_state   <= "01";
            else
               analog_on          <= '0';
               nxt_analog_state   <= "10";
            end if;

            -- End of state at define delay
            if ( sub_cnt(7 downto 0) = tc5_data(31 downto 24) ) then
               nxt_mst_state         <= MS_DIG;
               sub_cnt_rst           <= '1';
               nxt_desel_all_cells   <= '1';
               nxt_precharge_ana_bus <= '1';
            else
               nxt_mst_state         <= mst_state;
               sub_cnt_rst           <= '0';
               nxt_desel_all_cells   <= '0';
               nxt_precharge_ana_bus <= '0';
            end if;


         -- Digitize
         when MS_DIG =>

            -- Signals with no change in this state
            readout_start         <= '0';
            mst_cnt_rst           <= '0';
            bunch_clock_en        <= '0';
            nxt_bunch_clock       <= '0';
            cal_assert_en         <= '0';
            analog_on             <= '0';
            nxt_analog_state      <= "10";

            -- End of cycle, 8192 + 18
            if ( sub_cnt = X"2011" ) then

               -- Reset amp and ramp, shift selection
               sub_cnt_rst              <= '1';
               nxt_sel_cell             <= '0';
               nxt_ramp_period          <= '0';
               nxt_cur_cell(3 downto 1) <= int_cur_cell(2 downto 0);
               nxt_cur_cell(0)          <= '0';

               -- All channels have been read
               if ( int_cur_cell(3) = '1' ) then
                  nxt_desel_all_cells   <= '0';
                  nxt_precharge_ana_bus <= '0';
                  nxt_mst_state         <= MS_READ;

               -- Start next cycle
               else 
                  nxt_desel_all_cells   <= '1';
                  nxt_precharge_ana_bus <= '1';
                  nxt_mst_state         <= mst_state;
               end if;
            else 

               -- Unchanging signals
               sub_cnt_rst         <= '0';
               nxt_desel_all_cells <= '0';
               nxt_cur_cell        <= int_cur_cell;
               nxt_mst_state       <= mst_state;

               -- precharge analog bus matches deselect all cells
               nxt_precharge_ana_bus <= int_desel_all_cells and not sft_desel_all_cells(0);

               -- Select cell
               if ( sft_desel_all_cells(12) = '1' ) then
                  nxt_sel_cell <= '1';
               else
                  nxt_sel_cell <= int_sel_cell;
               end if;

               -- Assert ramp period signal
               if ( sft_desel_all_cells(16) = '1' ) then
                  nxt_ramp_period <= '1';
               else
                  nxt_ramp_period <= int_ramp_period;
               end if;
            end if;


         -- Start read
         when MS_READ =>
            nxt_ramp_period       <= '0';
            nxt_cur_cell          <= "0000";
            mst_cnt_rst           <= '0';
            bunch_clock_en        <= '0';
            nxt_sel_cell          <= '0';
            nxt_bunch_clock       <= '0';
            sub_cnt_rst           <= '1';
            nxt_desel_all_cells   <= '0';
            nxt_precharge_ana_bus <= '0';
            cal_assert_en         <= '0';
            readout_start         <= '1';
            analog_on             <= '0';
            nxt_analog_state      <= "00";
            nxt_mst_state         <= MS_IDLE;


         -- Catch errors
         when others =>
            nxt_ramp_period       <= '0';
            nxt_cur_cell          <= "0000";
            mst_cnt_rst           <= '0';
            bunch_clock_en        <= '0';
            nxt_sel_cell          <= '0';
            nxt_bunch_clock       <= '0';
            sub_cnt_rst           <= '0';
            nxt_desel_all_cells   <= '0';
            nxt_precharge_ana_bus <= '0';
            cal_assert_en         <= '0';
            readout_start         <= '0';
            analog_on             <= '0';
            nxt_analog_state      <= "00";
            nxt_mst_state         <= MS_IDLE;

      end case;
   end process;


   ------------------------------------------------
   -- Analog Signal On/Off Control
   ------------------------------------------------

   -- Use master counter for on/off control
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0') then
         pwr_up_acq      <= '0' after 1 ns;
         pwr_up_acq_dig  <= '0' after 1 ns;
         analog_reset    <= '0' after 1 ns;
         leakage_null    <= '1' after 1 ns;
         offset_null     <= '1' after 1 ns;
         thresh_off      <= '1' after 1 ns;
         trig_inh        <= '1' after 1 ns;

      elsif rising_edge(sysclk) then

         if ( mst_cnt_rst = '1' ) then
            pwr_up_acq      <= '0' after 1 ns;
            pwr_up_acq_dig  <= '0' after 1 ns;
            analog_reset    <= '0' after 1 ns;
            leakage_null    <= '1' after 1 ns;
            offset_null     <= '1' after 1 ns;
            thresh_off      <= '1' after 1 ns;
            trig_inh        <= '1' after 1 ns;
         else

            -- Power up acq off
            if ( analog_on = '0' ) then
               pwr_up_acq     <= '0' after 1 ns;

            -- Power up acq on
            elsif ( mst_cnt = tc4_data(31 downto 16) ) then
               pwr_up_acq     <= '1' after 1 ns;
            end if;

            -- Power up acq dig on
            if ( mst_cnt = tc2_data(15 downto 0) ) then
               pwr_up_acq_dig <= '1' after 1 ns;
            end if;

            -- Analog rst on
            if ( mst_cnt = tc0_data(15 downto 0) ) then
               analog_reset <= '1' after 1 ns;

            -- Analog rst off
            elsif ( mst_cnt = tc0_data(31 downto 16) ) then
               analog_reset <= '0' after 1 ns;
            end if;

            -- leakage_null on
            if ( analog_on = '0') then
               leakage_null <= '1' after 1 ns;

            -- leakage_null off
            elsif ( mst_cnt = tc1_data(31 downto 16) ) then
               leakage_null <= '0' after 1 ns;
            end if;

            -- offset_null off
            if ( mst_cnt = tc1_data(15 downto 0) ) then
               offset_null <= '0' after 1 ns;
            end if;

            -- thresh_off off
            if ( mst_cnt = tc2_data(31 downto 16) ) then
               thresh_off <= '0' after 1 ns;
            end if;

            -- trig_inh off
            if ( mst_cnt = tc3_data ) then
               trig_inh <= '0' after 1 ns;
            end if;

         end if;
      end if;
   end process;


   ------------------------------------------------
   -- Calibration Logic
   ------------------------------------------------

   -- Calibration Strobe Counters and sync state logic
   process ( sysclk, int_reset_l ) begin
      if (int_reset_l = '0' ) then
         cal_cnt         <= (others=>'0') after 1 ns;
         int_cal_pulse   <= "0000"        after 1 ns;
         cal_state       <= CAL_IDLE      after 1 ns;
         int_cal_strobe  <= '0'           after 1 ns;
         cal_dly         <= (others=>'0') after 1 ns; 
         cal_en          <= '0'           after 1 ns;

      elsif rising_edge(sysclk) then

         -- Calibration counter
         if ( cal_cnt_rst = '1' ) then
            cal_cnt <= (others=>'0') after 1 ns;
         elsif ( cal_cnt_en  = '1' ) then
            cal_cnt <= cal_cnt + 1 after 1 ns;
         end if;

         -- State transition logic
         cal_state       <= nxt_cal_state  after 1 ns;
         int_cal_strobe  <= nxt_cal_strobe after 1 ns;
         int_cal_pulse   <= nxt_cal_pulse  after 1 ns;

         -- Determine next delay value and next enable
         case int_cal_pulse is
            when "0001" => 
               cal_dly <= cd0_data(12 downto  0) after 1 ns; 
               cal_en  <= cd0_data(15) after 1 ns;
            when "0010" => 
               cal_dly <= cd0_data(28 downto 16) after 1 ns; 
               cal_en  <= cd0_data(31) after 1 ns;
            when "0100" => 
               cal_dly <= cd1_data(12 downto  0) after 1 ns; 
               cal_en  <= cd1_data(15) after 1 ns;
            when "1000" => 
               cal_dly <= cd1_data(28 downto 16) after 1 ns; 
               cal_en  <= cd1_data(31) after 1 ns;
            when others => 
               cal_dly <= (others=>'0'); 
               cal_en  <= '0';
         end case;
      end if;
   end process;


   -- State machine
   process ( cal_state, start_calibrate, int_cal_pulse, int_cal_strobe, 
             sub_cnt, cal_cnt, cal_dly, cal_en, cal_assert_en ) begin

      case cal_state is

         -- Idle, wait for sequence start
         when CAL_IDLE =>

            -- Drive all signals to idle state
            nxt_cal_strobe  <= '0';
            cal_cnt_rst     <= '1';
            cal_cnt_en      <= '0';
            nxt_cal_pulse   <= "0001";

            -- Sequence start
            if ( start_calibrate = '1' ) then
               nxt_cal_state  <= CAL_ARM;
            else
               nxt_cal_state  <= cal_state;
            end if;


         -- Wait here until it is time to fire the calibration strobe
         when CAL_ARM =>

            -- No change in currentpulse selection
            nxt_cal_pulse <= int_cal_pulse;

            -- Take action after early bunch clock is asserted
            if ( cal_assert_en = '1' and sub_cnt(2 downto 0) = "110" ) then

               -- Enable count
               cal_cnt_en <= '1';

               -- Delay match, assert pulse, go to pulse state
               -- Only assert pulse if it is enabled
               if ( cal_cnt = cal_dly ) then
                  nxt_cal_strobe  <= cal_en;
                  cal_cnt_rst     <= '1';
                  nxt_cal_state   <= CAL_PULSE;
               else
                  nxt_cal_strobe  <= '0';
                  cal_cnt_rst     <= '0';
                  nxt_cal_state   <= cal_state;
               end if;
            else
               cal_cnt_en      <= '0';
               nxt_cal_strobe  <= '0';
               cal_cnt_rst     <= '0';
               nxt_cal_state   <= cal_state;
            end if;


         -- Assert 1us pulse
         when CAL_PULSE =>

            -- Always increment counter
            cal_cnt_en <= '1';

            -- Wait for 1us, actual time is 1053.125
            if ( cal_cnt = 24 ) then

               -- Shift cal pulse, reset counter
               nxt_cal_pulse <= int_cal_pulse(2 downto 0) & '0';
               cal_cnt_rst   <= '1';

               -- De-assert pulse
               nxt_cal_strobe <= '0';

               -- Are we done?
               if ( int_cal_pulse(3) = '1' ) then
                  nxt_cal_state <= CAL_IDLE;
               else
                  nxt_cal_state <= CAL_ARM;
               end if;
            else
               nxt_cal_pulse   <= int_cal_pulse;
               cal_cnt_rst     <= '0';
               nxt_cal_strobe  <= int_cal_strobe;
               nxt_cal_state   <= cal_state;
            end if;


         -- Just in case
         when others =>
            cal_cnt_en      <= '0';
            nxt_cal_pulse   <= "0000";
            cal_cnt_rst     <= '0';
            nxt_cal_strobe  <= '0';
            nxt_cal_state   <= CAL_IDLE;

      end case;
   end process;

end analog_control;
