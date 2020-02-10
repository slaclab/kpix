-------------------------------------------------------------------------------
-- Title      : Testbench for design "DesyTracker"
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of KPIX. It is subject to
-- the license terms in the LICENSE.txt file found in the top-level directory
-- of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of KPIX, including this file, may be
-- copied, modified, propagated, or distributed except according to the terms
-- contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


library surf;
use surf.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;
----------------------------------------------------------------------------------------------------

entity DesyTrackerTb is

end entity DesyTrackerTb;

----------------------------------------------------------------------------------------------------

architecture sim of DesyTrackerTb is

   -- component generics
   constant TPD_G        : time             := 1 ns;
   constant SIMULATION_G : boolean          := true;
   constant BUILD_INFO_G : BuildInfoType    := BUILD_INFO_DEFAULT_SLV_C;
   constant DHCP_G       : boolean          := true;
   constant IP_ADDR_G    : slv(31 downto 0) := x"0A01A8C0";

   -- component ports
   signal gtClkP      : sl;                                  -- [in]
   signal gtClkN      : sl;                                  -- [in]
   signal tluClkP     : sl;                                  -- [in]
   signal tluClkN     : sl;                                  -- [in]
   signal tluSpillP   : sl;                                  -- [in]
   signal tluSpillN   : sl;                                  -- [in]
   signal tluStartP   : sl;                                  -- [in]
   signal tluStartN   : sl;                                  -- [in]
   signal tluTriggerP : sl;                                  -- [in]
   signal tluTriggerN : sl;                                  -- [in]
   signal tluBusyP    : sl;                                  -- [out]
   signal tluBusyN    : sl;                                  -- [out]
   signal bncBusy     : sl;                                  -- [out]
   signal bncDebug    : sl;                                  -- [out]
   signal bncTrigL    : sl;                                  -- [in]
   signal lemoIn      : slv(1 downto 0);                     -- [in]
   signal kpixRst     : slv(3 downto 0);                     -- [out]
   signal kpixClkP    : slv(3 downto 0);                     -- [out]
   signal kpixClkN    : slv(3 downto 0);                     -- [out]
   signal kpixTrigP   : slv(3 downto 0);                     -- [out]
   signal kpixTrigN   : slv(3 downto 0);                     -- [out]
   signal kpixCmd     : slv6Array(3 downto 0);               -- [out]
   signal kpixData    : slv6Array(3 downto 0);               -- [in]
   signal cassetteScl : slv(3 downto 0) := (others => 'Z');  -- [inout]
   signal cassetteSda : slv(3 downto 0) := (others => 'Z');  -- [inout]
   signal bootCsL     : sl;                                  -- [out]
   signal bootMosi    : sl;                                  -- [out]
   signal bootMiso    : sl;                                  -- [in]
   signal promScl     : sl;                                  -- [inout]
   signal promSda     : sl;                                  -- [inout]
   signal oscOe       : slv(1 downto 0) := (others => '1');  -- [out]
   signal pwrSyncSclk : sl              := '0';              -- [out]
   signal pwrSyncFclk : sl              := '0';              -- [out]
   signal pwrScl      : sl              := 'Z';              -- [inout]
   signal pwrSda      : sl              := 'Z';              -- [inout]
   signal tempAlertL  : sl;                                  -- [in]
   signal led         : slv(3 downto 0) := (others => '0');  -- [out]
   signal red         : slv(1 downto 0);                     -- [out]
   signal blue        : slv(1 downto 0);                     -- [out]
   signal green       : slv(1 downto 0);                     -- [out]

   signal kpixClk : slv(3 downto 0);

   signal kpixCmdBuf  : slv6Array(3 downto 0);  -- [out]
   signal kpixDataBuf : slv6Array(3 downto 0);  -- [in]
   signal kpixClkBuf  : slv(3 downto 0);


begin

   -- component instantiation
   U_DesyTracker : entity work.DesyTracker
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => true,
         BUILD_INFO_G => BUILD_INFO_G,
         DHCP_G       => false)
--         IP_ADDR_G    => IP_ADDR_G)
      port map (
         gtClkP      => gtClkP,         -- [in]
         gtClkN      => gtClkN,         -- [in]
         gtRxP       => '0',            -- [in]
         gtRxN       => '0',            -- [in]
         gtTxP       => open,           -- [out]
         gtTxN       => open,           -- [out]
         tluClkP     => tluClkP,        -- [in]
         tluClkN     => tluClkN,        -- [in]
         tluSpillP   => '0',            -- [in]
         tluSpillN   => '1',            -- [in]
         tluStartP   => '0',            -- [in]
         tluStartN   => '1',            -- [in]
         tluTriggerP => '0',            -- [in]
         tluTriggerN => '1',            -- [in]
         tluBusyP    => open,           -- [out]
         tluBusyN    => open,           -- [out]
         bncBusy     => open,           -- [out]
         bncDebug    => open,           -- [out]
         bncTrigL    => '1',            -- [in]
         lemoIn      => "00",           -- [in]
         kpixRst     => kpixRst,        -- [out]
         kpixClkP    => kpixClkP,       -- [out]
         kpixClkN    => kpixClkN,       -- [out]
         kpixTrigP   => kpixTrigP,      -- [out]
         kpixTrigN   => kpixTrigN,      -- [out]
         kpixCmd     => kpixCmd,        -- [out]
         kpixData    => kpixData,       -- [in]
         cassetteScl => open,           -- [inout]
         cassetteSda => open,           -- [inout]
         bootCsL     => open,           -- [out]
         bootMosi    => open,           -- [out]
         bootMiso    => '0',            -- [in]
         promScl     => open,           -- [inout]
         promSda     => open,           -- [inout]
         oscOe       => open,           -- [out]
         pwrSyncSclk => open,           -- [out]
         pwrSyncFclk => open,           -- [out]
         pwrScl      => open,           -- [inout]
         pwrSda      => open,           -- [inout]
         tempAlertL  => '1',            -- [in]
         led         => led,            -- [out]
         red         => red,            -- [out]
         blue        => blue,           -- [out]
         green       => green);         -- [out]


   U_ClkRst_gtClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => 3.2 ns,
         CLK_DELAY_G       => 1 ns,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 5 us,
         SYNC_RESET_G      => true)
      port map (
         clkP => gtClkP,
         clkN => gtClkN);

   U_ClkRst_tluClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => 25 ns,
         CLK_DELAY_G       => 1 ns,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 5 us,
         SYNC_RESET_G      => true)
      port map (
         clkP => tluClkP,
         clkN => tluClkN);

   KPIX_CAS_GEN : for i in 3 downto 0 generate

      CLK_BUFF : IBUFDS
         port map (
            I  => kpixClkP(i),
            IB => kpixClkN(i),
            O  => kpixClk(i));

      kpixClkBuf(i) <= transport kpixClk(i) after 5.5 ns;


      KPIX_ASIC_GEN : for j in 5 downto 0 generate
         kpixCmdBuf(i)(j) <= transport kpixCmd(i)(j)     after 7.2 ns;
         kpixData(i)(j)   <= transport kpixDataBuf(i)(j) after 7.2 ns;

         U_KpixLocal_1 : entity work.KpixLocal
            generic map (
               TPD_G => TPD_G)
            port map (
               kpixClk        => kpixClkBuf(i),      -- [in]
               debugOutA      => open,               -- [out]
               debugOutB      => open,               -- [out]
               debugASel      => (others => '0'),    -- [in]
               debugBSel      => (others => '0'),    -- [in]
               kpixReset      => kpixRst(i),         -- [in]
               kpixCmd        => kpixCmdBuf(i)(j),   -- [in]
               kpixData       => kpixDataBuf(i)(j),  -- [out]
               clk200         => '0',                -- [in]
               rst200         => '0',                -- [in]
               kpixClkPreRise => '0',                -- [in]
               kpixState      => open,               -- [out]
               calStrobeOut   => open);              -- [out]

      end generate;
   end generate;


end architecture sim;

----------------------------------------------------------------------------------------------------
