-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : EventBuilderFifoPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-11
-- Last update: 2012-05-17
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

package EventBuilderFifoPkg is

  type EventBuilderFifoInType is record
    wrData : slv(71 downto 0);
    wrEn   : sl;
    rdEn   : sl;
  end record EventBuilderFifoInType;

  type EventBuilderFifoOutType is record
    rdData : slv(71 downto 0);
    full   : sl;
    empty  : sl;
    valid  : sl;
  end record EventBuilderFifoOutType;

end package EventBuilderFifoPkg;
