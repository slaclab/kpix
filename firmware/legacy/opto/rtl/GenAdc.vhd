-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Kpix Controller
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : GenAdc.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 11/24/2004
-------------------------------------------------------------------------------
-- Description:
-- Generic module for control of the ADC for power and temperature monitoring.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/24/2004: Created
-------------------------------------------------------------------------------

use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity GenAdc is 
   port ( 

      -- Input clocks & reset
      sysClk20     : in     std_logic;                      -- 20Mhz system clock
      sysClk1      : in     std_logic;                      -- 1Mhz system clock
      syncRst      : in     std_logic;                      -- Synchronous Reset

      -- Interface to the ADC
      adcCsL       : out    std_logic;                      -- Chip selects to ADC
      adcSData     : in     std_logic;                      -- Serial data from ADC

      -- Output value for readback
      adcValue     : out    std_logic_vector(11 downto 0)   -- Current ADC value
   );

   -- Keep from combinging chip selects
   attribute syn_preserve : boolean;
   attribute syn_preserve of adcCsL: signal is true;

end GenAdc;


-- Define architecture for core level module
architecture GenAdc of GenAdc is

   -- Local signals
   signal adcCnt      : std_logic_vector(3  downto 0);   -- ADC chip select counter
   signal adcCs       : std_logic;                       -- Internal ADC chip select
   signal tmpSData    : std_logic;                       -- Temp copy of ADC data at IO pads
   signal intSData    : std_logic;                       -- Internal copy of ADC data
   signal shiftCnt    : std_logic_vector(3  downto 0);   -- ADC shift counter
   signal shiftEn     : std_logic;                       -- ADC shift enable
   signal shiftEnDly  : std_logic;                       -- Delayed shift enable
   signal adcHold     : std_logic_vector(11 downto 0);   -- ADC value hold

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin


   -- ADC cycle control count & chip select
   -- Drive external chip selects on IO pad flip flops
   process ( sysClk20, syncRst ) begin

      if syncRst = '1' then
         adcCnt  <= (others => '0') after tpd;
         adcCs   <= '0'             after tpd;
         adcCsL  <= '1'             after tpd;

      elsif rising_edge(sysClk20) then

         -- Drive external chip selects
         adcCsL <= not adcCs after tpd;

         -- Reset to zero on 1Mhz pulse
         if sysClk1 = '1' then
            adcCs   <= '1'             after tpd;
            adcCnt  <= (others => '0') after tpd;
         else

            -- Check for a count of 15 to de-assert chip select, otherwise
            -- increment counter
            if adcCnt = 15 then
               adcCs <= '0' after tpd;
            else
               adcCnt <= adcCnt + 1 after tpd;
            end if;
         end if;
      end if;
   end process;


   -- Sample incoming data with falling edge of system clock
   process ( sysClk20, syncRst ) begin
      if syncRst = '1' then
         tmpSData <= '0';
      elsif falling_edge(sysClk20) then
         tmpSData <= adcSData;
      end if;
   end process;


   -- Sample incoming data with rising edge and control 'bit enable' shift register
   -- Shift incoming serial data into parrallel registers
   process ( sysClk20, syncRst ) begin

      if syncRst = '1' then
         intSData   <= '0';
         shiftCnt   <= (others => '0');
         shiftEn    <= '0';
         shiftEnDly <= '0';
         adcHold    <= (others => '0');
         adcValue   <= (others => '0');

      elsif rising_edge(sysClk20) then


         -- Reset shift counter when ADC counter is equal to 5
         -- Let counter saturate at 0 and disable shift
         if adcCnt = 5 and adcCs = '1' then
            shiftCnt <= X"B";
            shiftEn  <= '1';
         elsif shiftCnt /= 0 then
            shiftCnt <= shiftCnt - 1;
         else
            shiftEn  <= '0';
         end if;


         -- Register incoming data to rising edge of clock
         intSData <= tmpSData;

         -- Register each data bit at the correct time
         if shiftEn = '1' then
            adcHold(conv_integer(shiftCnt)) <= intSData;
         end if;

         -- One clock delay before shift
         if shiftEn = '1' and shiftCnt = 0 then
            shiftEnDly <= '1';
         else
            shiftEnDly <= '0';
         end if;   

         -- Transfer the data to output register after last shift
         if shiftEnDly = '1' then

            -- Always pass temp through
            adcValue <= adcHold;

         end if;
      end if;
   end process;

end GenAdc;

