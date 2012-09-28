-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : EvrPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-09-26
-- Last update: 2012-09-26
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

package EvrPkg is

  type EvrRegInType is record
    wrEna   : sl;
    ena     : sl;
    dataIn : slv(31 downto 0);
    addr   : slv(7 downto 0);
  end record EvrRegInType;

  type EvrRegOutType is record
    dataOut : slv(31 downto 0);
  end record EvrRegOutType;

  type EvrOutType is record
    eventStream : slv(7 downto 0);
    dataStream  : slv(7 downto 0);
    trigger     : sl;
    debug       : slv(63 downto 0);
    seconds     : slv(31 downto 0);
    offset      : slv(31 downto 0);
    errors      : slv(15 downto 0);
  end record EvrOutType;

  type EvrInType is record
    countReset : sl;
  end record EvrInType;

end package EvrPkg;
