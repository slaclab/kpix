-------------------------------------------------------------------------------
-- Title         : W_Si Chip Generic 32-bit Read Write Register
-- Project       : W_Si Chip
-------------------------------------------------------------------------------
-- File          : reg_rw_32.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 08/03/2005
-------------------------------------------------------------------------------
-- Description:
-- This is a generic 32-bit serial read / write register. This module is used
-- in the command control block.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 by SLAC. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 08/03/2005: created.
-- 08/11/2005: Changed to async reset
-- 08/30/2005: Changed reset polarity
-- 02/23/2007: Modified registers to only clock when accessing.
-- 02/03/2009: Removed reset value to save logic.
-- 06/15/2009: Removed gated clock logic.
-------------------------------------------------------------------------------

use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity reg_rw_32 is port ( 

      -- Clock & Reset
      sysclk      : in  std_logic;
      int_reset_l : in  std_logic;

      -- Register control
      reg_sel     : in  std_logic;
      reg_wr_en   : in  std_logic;

      -- Data in & out
      shift_in    : in  std_logic;
      shift_out   : out std_logic;
      data_out    : out std_logic_vector(31 downto 0)
   );

end reg_rw_32;


-- Define architecture
architecture reg_rw_32 of reg_rw_32 is

   -- Local Signals
   signal reg_data : std_logic_vector(31 downto 0);

begin

   -- Connect data output
   data_out  <= reg_data;
   shift_out <= reg_data(0);

   -- Shift Configuration Registers
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         reg_data <= (others=>'0') after 1 ns;

      elsif (rising_edge(sysclk)) then

         -- Shift data when selected
         if ( reg_sel = '1' ) then
            reg_data(30 downto 0) <= reg_data(31 downto 1) after 1 ns;

            -- Read or write
            if ( reg_wr_en = '1' ) then
               reg_data(31) <= shift_in after 1 ns;
            else
               reg_data(31) <= reg_data(0) after 1 ns;
            end if;
         end if;

      end if;
   end process;

end reg_rw_32;
