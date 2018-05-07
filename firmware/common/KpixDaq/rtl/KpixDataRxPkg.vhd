-------------------------------------------------------------------------------
-- Title      : KPIX Data Receiver Support Package
-------------------------------------------------------------------------------
-- File       : KpixDataRxPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-10
-- Last update: 2013-07-31
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
      enabled                     : sl;
      resetHeaderParityErrorCount : sl;
      resetDataParityErrorCount   : sl;
      resetMarkerErrorCount       : sl;
      resetOverflowErrorCount     : sl;
   end record KpixDataRxRegsInType;

   constant KPIX_DATA_RX_REGS_IN_INIT_C : KpixDataRxRegsInType := (
      enabled                     => '0',
      resetHeaderParityErrorCount => '0',
      resetDataParityErrorCount   => '0',
      resetMarkerErrorCount       => '0',
      resetOverflowErrorCount     => '0');

   type KpixDataRxRegsInArray is array (natural range <>) of KpixDataRxRegsInType;

   type KpixDataRxRegsOutType is record
      headerParityErrorCount : slv(31 downto 0);
      dataParityErrorCount   : slv(31 downto 0);
      markerErrorCount       : slv(31 downto 0);
      overflowErrorCount     : slv(31 downto 0);
   end record KpixDataRxRegsOutType;

   constant KPIX_DATA_RX_REGS_OUT_INIT_C : KpixDataRxRegsOutType := (
      headerParityErrorCount => (others => '0'),
      dataParityErrorCount   => (others => '0'),
      markerErrorCount       => (others => '0'),
      overflowErrorCount     => (others => '0'));

   type KpixDataRxRegsOutArray is array (natural range <>) of KpixDataRxRegsOutType;

   --------------------------------------------------------------------------------------------------
   -- Data interface
   --------------------------------------------------------------------------------------------------
   type KpixDataRxInType is record
      ack : sl;
   end record KpixDataRxInType;

   type KpixDataRxInArray is array (natural range <>) of KpixDataRxInType;

   type KpixDataRxOutType is record
      data  : slv(63 downto 0);
      valid : sl;
      last  : sl;
      busy  : sl;
   end record KpixDataRxOutType;

   constant KPIX_DATA_RX_OUT_INIT_C : KpixDataRxOutType := (
      data  => (others => '0'),
      valid => '0',
      last  => '0',
      busy  => '0');

   type KpixDataRxOutArray is array (natural range <>) of KpixDataRxOutType;

end package KpixDataRxPkg;
