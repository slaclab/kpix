-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixClockGenPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-22
-- Last update: 2012-05-23
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

  type KpixClockGenRegsInType is record
    newValue        : sl;
    clkSelReadout   : slv(4 downto 0);
    clkSelDigitize  : slv(4 downto 0);
    clkSelAcquire   : slv(4 downto 0);
    clkSelIdle      : slv(4 downto 0);
    clkSelPrecharge : slv(4 downto 0);
  end record KpixClockGenRegsInType;

end package KpixClockGenPkg;
