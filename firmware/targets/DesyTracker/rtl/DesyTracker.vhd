-------------------------------------------------------------------------------
-- Title      : DESY Tracker
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top level file for DESY Tracker
-------------------------------------------------------------------------------
-- This file is part of DESY Tracker. It is subject to
-- the license terms in the LICENSE.txt file found in the top-level directory
-- of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of DESY Tracker, including this file, may be
-- copied, modified, propagated, or distributed except according to the terms
-- contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;

entity DesyTracker is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- PGP/GbE Ports
      gtClkP : in  sl;
      gtClkN : in  sl;
      gtRxP  : in  sl;
      gtRxN  : in  sl;
      gtTxP  : out sl;
      gtTxN  : out sl;

      -- TLU Interface
      tluClkP     : in  sl;
      tluClkN     : in  sl;
      tluSpillP   : in  sl;
      tluSpillN   : in  sl;
      tluBusyP    : in  sl;
      tluBusyN    : in  sl;
      tluTriggerP : in  sl;
      tluTriggerN : in  sl;
      tluBusyP    : out sl;
      tluBusyN    : out sl;

      -- BNC/LEMO
      bncBusy : out sl;
      bncTrig : in  sl;
      lemoIn  : in  slv(1 downto 0);

      -- KPIX interfaces
      kpixRst   : out slv(3 downto 0);
      kpixClkP  : out slv(3 downto 0);
      kpixClkN  : out slv(3 downto 0);
      kpixTrigP : out slv(3 downto 0);
      kpixTrigN : out slv(3 downto 0);
      kpixCmd   : out slv(23 downto 0);
      kpixData  : in  slv(23 downto 0);

      -- Cassette I2C
      cassetteScl   : inout slv(3 downto 0);
      cassetteSda   : inout slv(3 downto 0);
      cassetteI2cEn : out   slv(3 downto 0) := (others => '0');

      -- Boot Memory Ports
      bootCsL  : out sl;
      bootMosi : out sl;
      bootMiso : in  sl;

      -- I2C PROM
      promScl : inout sl;
      promSda : inout sl;

      -- Debug LEDs
      led   : out slv(3 downto 0);
      red   : out slv(1 downto 0);
      blue  : out slv(1 downto 0);
      green : out slv(1 downto 0)      );
end DesyTracker;

architecture rtl of DesyTracker is

begin



end architecture rtl;
