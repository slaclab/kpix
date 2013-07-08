-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixClockGenPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-22
-- Last update: 2013-07-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.StdRtlPkg.all;
use work.KpixLocalPkg.all;

package KpixClockGenPkg is

   constant CLK_SEL_READOUT_DEFAULT_C   : slv(7 downto 0) := X"09";  -- 100 ns
   constant CLK_SEL_DIGITIZE_DEFAULT_C  : slv(7 downto 0) := X"04";  -- 50 ns
   constant CLK_SEL_ACQUIRE_DEFAULT_C   : slv(7 downto 0) := X"04";  -- 50 ns
   constant CLK_SEL_IDLE_DEFAULT_C      : slv(7 downto 0) := X"09";  -- 100 ns
   constant CLK_SEL_PRECHARGE_DEFAULT_C : slv(11 downto 0) := X"004";  -- 50 ns

   type KpixClockGenRegsInType is record
      newValue        : sl;
      clkSelReadout   : slv(7 downto 0);
      clkSelDigitize  : slv(7 downto 0);
      clkSelAcquire   : slv(7 downto 0);
      clkSelIdle      : slv(7 downto 0);
      clkSelPrecharge : slv(11 downto 0);
   end record KpixClockGenRegsInType;

end package KpixClockGenPkg;
