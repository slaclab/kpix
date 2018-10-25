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
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
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
