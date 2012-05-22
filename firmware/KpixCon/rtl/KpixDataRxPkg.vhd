-------------------------------------------------------------------------------
-- Title      : KPIX Data Receiver Support Package
-------------------------------------------------------------------------------
-- File       : KpixDataRxPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-10
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

package KpixDataRxPkg is

  type KpixDataRxOutType is record
    data  : slv(63 downto 0);
    valid : sl;
    last  : sl;
    busy  : sl;
  end record KpixDataRxOutType;

  type KpixDataRxOutArray is array (natural range <>) of KpixDataRxOutType;

  type KpixDataRxInType is record
    ready : sl;
  end record KpixDataRxInType;

  type KpixDataRxInArray is array (natural range <>) of KpixDataRxInType;

end package KpixDataRxPkg;
