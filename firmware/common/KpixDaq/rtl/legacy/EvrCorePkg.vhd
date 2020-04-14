-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : EvrPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-09-26
-- Last update: 2020-04-13
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

library surf;
use surf.StdRtlPkg.all;

package EvrCorePkg is

   -- Evr Core Phy interface
   type EvrPhyType is record
      rxData  : slv(15 downto 0);
      rxDataK : slv(1 downto 0);
      decErr  : slv(1 downto 0);
      dispErr : slv(1 downto 0);
   end record EvrPhyType;

   type EvrOutType is record
      eventStream : slv(7 downto 0);
      dataStream  : slv(7 downto 0);
      trigger     : sl;
      seconds     : slv(31 downto 0);
      offset      : slv(31 downto 0);
      errors      : slv(15 downto 0);
   end record;

   constant EVR_OUT_INIT_C : EvrOutType := (
      eventStream => (others => '0'),
      dataStream  => (others => '0'),
      trigger     => '0',
      seconds     => (others => '0'),
      offset      => (others => '0'),
      errors      => (others => '0'));


end package EvrCorePkg;
