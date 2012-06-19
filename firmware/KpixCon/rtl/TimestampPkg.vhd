-------------------------------------------------------------------------------
-- Title      : Timestamp Module Support Package
-------------------------------------------------------------------------------
-- File       : TimestampPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-06-14
-- Last update: 2012-06-14
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

package TimestampPkg is

  type TimestampRegsInType is record
    extTriggerSrc : slv(2 downto 0);
  end record TimestampRegsInType;

  type TimestampOutType is record
    data  : slv(12 downto 0);
    valid : sl;
  end record TimestampOutType;

  type TimestampInType is record
    rdEn : sl;
  end record TimestampInType;

end package TimestampPkg;
