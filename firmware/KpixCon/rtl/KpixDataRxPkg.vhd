-------------------------------------------------------------------------------
-- Title      : KPIX Data Receiver Support Package
-------------------------------------------------------------------------------
-- File       : KpixDataRxPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-10
-- Last update: 2012-05-24
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

  --------------------------------------------------------------------------------------------------
  -- Ethernet Registers
  --------------------------------------------------------------------------------------------------
  type KpixDataRxRegsInType is record
    enabled     : sl;
    rawDataMode : sl;
    resetHeaderParityErrorCount : sl;
    resetDataParityErrorCount : sl;
    resetMarkerErrorCount : sl;
    resetOverflowErrorCount : sl;
  end record KpixDataRxRegsInType;

  type KpixDataRxRegsInArray is array (natural range <>) of KpixDataRxRegsInType;

  type KpixDataRxRegsOutType is record
    headerParityErrorCount   : slv(31 downto 0);
    dataParityErrorCount     : slv(31 downto 0);
    markerErrorCount   : slv(31 downto 0);
    overflowErrorCount : slv(31 downto 0);
  end record KpixDataRxRegsOutType;

  type KpixDataRxRegsOutArray is array (natural range <>) of KpixDataRxRegsOutType;

  --------------------------------------------------------------------------------------------------
  -- Event Builder Interface
  --------------------------------------------------------------------------------------------------
  type KpixDataRxInType is record
    ready : sl;
  end record KpixDataRxInType;

  type KpixDataRxInArray is array (natural range <>) of KpixDataRxInType;

  type KpixDataRxOutType is record
    data  : slv(63 downto 0);
    valid : sl;
    last  : sl;
    busy  : sl;
  end record KpixDataRxOutType;

  type KpixDataRxOutArray is array (natural range <>) of KpixDataRxOutType;

end package KpixDataRxPkg;
