-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
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

package KpixRegRxPkg is

   type KpixRegRxOutType is record
      temperature  : slv(7 downto 0);
      tempCount    : slv(11 downto 0);
      regAddr      : slv(6 downto 0);
      regData      : slv(31 downto 0);
      regValid     : sl;
      regParityErr : sl;
   end record KpixRegRxOutType;

   constant KPIX_REG_RX_OUT_INIT_C : KpixRegRxOutType := (
      temperature  => (others => '0'),
      tempCount    => (others => '0'),
      regAddr      => (others => '0'),
      regData      => (others => '0'),
      regValid     => '0',
      regParityErr => '0');

   type KpixRegRxOutArray is array (natural range <>) of KpixRegRxOutType;

end package KpixRegRxPkg;
