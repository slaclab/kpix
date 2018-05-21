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
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

use work.KpixPkg.all;

library unisim;
use unisim.vcomponents.all;


entity DesyTracker is
   generic (
      TPD_G        : time             := 1 ns;
      SIMULATION_G : boolean          := false;
      BUILD_INFO_G : BuildInfoType;
      DHCP_G       : boolean          := true;
      IP_ADDR_G    : slv(31 downto 0) := x"0A01A8C0");
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
      tluStartP   : in  sl;
      tluStartN   : in  sl;
      tluTriggerP : in  sl;
      tluTriggerN : in  sl;
      tluBusyP    : out sl;
      tluBusyN    : out sl;

      -- BNC/LEMO
      bncBusy  : out sl;
      bncDebug : out sl;
      bncTrigL : in  sl;
      lemoIn   : in  slv(1 downto 0);

      -- KPIX interfaces
      kpixRst   : out slv(3 downto 0);
      kpixClkP  : out slv(3 downto 0);
      kpixClkN  : out slv(3 downto 0);
      kpixTrigP : out slv(3 downto 0);
      kpixTrigN : out slv(3 downto 0);
      kpixCmd   : out slv6Array(3 downto 0);
      kpixData  : in  slv6Array(3 downto 0);

      -- Cassette I2C
      cassetteScl   : inout slv(3 downto 0) := (others => 'Z');
      cassetteSda   : inout slv(3 downto 0) := (others => 'Z');
      cassetteI2cEn : out   slv(3 downto 0) := (others => '0');

      -- Boot Memory Ports
      bootCsL  : out sl;
      bootMosi : out sl;
      bootMiso : in  sl;

      -- I2C PROM
      promScl : inout sl;
      promSda : inout sl;

      -- Misc crap
      oscOe       : out   slv(1 downto 0) := (others => '1');
      pwrSyncSclk : out   sl              := '0';
      pwrSyncFclk : out   sl              := '0';
      pwrScl      : inout sl              := 'Z';
      pwrSda      : inout sl              := 'Z';
      tempAlertL  : in    sl;


      -- Debug LEDs
      led   : out slv(3 downto 0) := (others => '0');
      red   : out slv(1 downto 0) := (others => '0');
      blue  : out slv(1 downto 0) := (others => '0');
      green : out slv(1 downto 0) := (others => '0'));
end DesyTracker;

architecture rtl of DesyTracker is

   signal clk200 : sl;
   signal rst200 : sl;

   constant NUM_AXIL_MASTERS_C : integer := 3;
   constant AXIL_VERSION_C     : integer := 0;
   constant AXIL_KPIX_DAQ_C    : integer := 1;
--   constant AXIL_CASSETTE_I2C_0_C : integer := 2;
--   constant AXIL_CASSETTE_I2C_1_C : integer := 3;   
   constant AXIL_ETH_CORE_C    : integer := 2;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      AXIL_VERSION_C  => (
         baseAddr     => X"00000000",
         addrBits     => 12,
         connectivity => X"FFFF"),
      AXIL_KPIX_DAQ_C => (
         baseAddr     => X"01000000",
         addrBits     => 24,
         connectivity => X"FFFF"),
      AXIL_ETH_CORE_C => (
         baseAddr     => X"02000000",
         addrBits     => 10,
         connectivity => X"FFFF"));

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal locAxilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal ebAxisMaster : AxiStreamMasterType;
   signal ebAxisSlave  : AxiStreamSlaveType;
   signal ebAxisCtrl   : AxiStreamCtrlType;

   signal ethStartAcq : sl;

   signal tluClk     : sl;
   signal tluSpill   : sl;
   signal tluStart   : sl;
   signal tluTrigger : sl;
   signal tluBusy    : sl;

   signal extTriggers : slv(7 downto 0);
   signal debugOutA   : sl;
   signal debugOutB   : sl;

   signal kpixResetOut   : sl;
   signal kpixClkOut     : sl;
   signal kpixTriggerOut : sl;
   signal kpixSerTxOut   : slv(23 downto 0);
   signal kpixSerRxIn    : slv(23 downto 0);

   signal rssiStatus : slv(6 downto 0);
   signal phyReady   : sl;

begin

   -------------------------------------------------------------------------------------------------
   -- Buffers for TLU signals
   -------------------------------------------------------------------------------------------------
   TLU_CLK_IBUF : IBUFGDS
      port map (
         I  => tluClkP,
         IB => tluClkN,
         O  => tluClk);

   TLU_SPILL_IBUF : IBUFDS
      port map (
         I  => tluSpillP,
         IB => tluSpillN,
         O  => tluSpill);

   TLU_START_IBUF : IBUFDS
      port map (
         I  => tluStartP,
         IB => tluStartN,
         O  => tluStart);

   TLU_TRIGGER_IBUF : IBUFDS
      port map (
         I  => tluTriggerP,
         IB => tluTriggerN,
         O  => tluTrigger);

   TLU_BUSY_OBUF : OBUFDS
      port map (
         I  => tluBusy,
         O  => tluBusyP,
         OB => tluBusyN);

   -------------------------------------------------------------------------------------------------
   -- Clock heartbeats and LED statuses
   -------------------------------------------------------------------------------------------------
   -- clk200
   Heartbeat_clk200 : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 5.0E-9,
         PERIOD_OUT_G => 0.5)
      port map (
         clk => clk200,
         o   => led(0));

   -- tluClk
   Heartbeat_tluClk : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 6.25E-9,
         PERIOD_OUT_G => 0.625)
      port map (
         clk => tluClk,
         o   => led(1));

   green(0) <= rssiStatus(0);
   red(0)   <= not rssiStatus(0);

   green(1) <= phyReady;
   red(1)   <= not phyReady;

   -------------------------------------------------------------------------------------------------
   -- Assign KPIX IO
   -- Clock, rigger and reset fanned out to each of the 4 cassettes
   -------------------------------------------------------------------------------------------------
   KPIX_CAS_GEN : for i in 3 downto 0 generate
      -- Reset
      kpixRst(i) <= kpixResetOut;

      -- Clock
      U_ClkOutBufDiff_CLK : entity work.ClkOutBufDiff
         generic map (
            TPD_G        => TPD_G,
            XIL_DEVICE_G => "7SERIES")
         port map (
            clkIn   => kpixClkOut,      -- [in]
            clkOutP => kpixClkP(i),     -- [out]
            clkOutN => kpixClkN(i));    -- [out]

      -- Trigger
      TRIGGER_OBUF : OBUFDS
         port map (
            I  => kpixTriggerOut,
            O  => kpixTrigP(i),
            OB => kpixTrigN(i));

      KPIX_GEN : for j in 5 downto 0 generate
         kpixCmd(i)(j)      <= kpixSerTxOut(i*6+j);
         kpixSerRxIn(i*6+j) <= kpixData(i)(j);
      end generate KPIX_GEN;

   end generate KPIX_CAS_GEN;



   -------------------------------------------------------------------------------------------------
   -- Assign extTriggers for KpixDaqCore
   -------------------------------------------------------------------------------------------------
   extTriggers(0) <= not bncTrigL;
   extTriggers(1) <= lemoIn(0);
   extTriggers(2) <= lemoIn(1);
   extTriggers(3) <= tluSpill;
   extTriggers(4) <= tluStart;
   extTriggers(5) <= tluTrigger;
   extTriggers(6) <= ethStartAcq;
   extTriggers(7) <= '0';

   -------------------------------------------------------------------------------------------------
   -- Ethernet core with SRPv3-AxiLite and Data FIFO
   -------------------------------------------------------------------------------------------------
   U_DesyTrackerEthCore_1 : entity work.DesyTrackerEthCore
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         DHCP_G       => DHCP_G,
         IP_ADDR_G    => IP_ADDR_G)
      port map (
         clk200           => clk200,                                -- [out]
         rst200           => rst200,                                -- [out]
         mAxilReadMaster  => axilReadMaster,                        -- [out]
         mAxilReadSlave   => axilReadSlave,                         -- [in]
         mAxilWriteMaster => axilWriteMaster,                       -- [out]
         mAxilWriteSlave  => axilWriteSlave,                        -- [in]
         ebAxisMaster     => ebAxisMaster,                          -- [in]
         ebAxisSlave      => ebAxisSlave,                           -- [out]
         ebAxisCtrl       => ebAxisCtrl,                            -- [out]
         startAcq         => ethStartAcq,                           -- [out]
         phyReady         => phyReady,                              -- [out]
         rssiStatus       => rssiStatus,                            -- [out]
         sAxilReadMaster  => locAxilReadMasters(AXIL_ETH_CORE_C),   -- [in]
         sAxilReadSlave   => locAxilReadSlaves(AXIL_ETH_CORE_C),    -- [out]
         sAxilWriteMaster => locAxilWriteMasters(AXIL_ETH_CORE_C),  -- [in]
         sAxilWriteSlave  => locAxilWriteSlaves(AXIL_ETH_CORE_C),   -- [out]
         gtClkP           => gtClkP,                                -- [in]
         gtClkN           => gtClkN,                                -- [in]
         gtRxP            => gtRxP,                                 -- [in]
         gtRxN            => gtRxN,                                 -- [in]
         gtTxP            => gtTxP,                                 -- [out]
         gtTxN            => gtTxN);                                -- [out]

   -------------------------------------------------------------------------------------------------
   -- Top level crossbar
   -------------------------------------------------------------------------------------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => clk200,
         axiClkRst           => rst200,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => locAxilWriteMasters,
         mAxiWriteSlaves     => locAxilWriteSlaves,
         mAxiReadMasters     => locAxilReadMasters,
         mAxiReadSlaves      => locAxilReadSlaves);

   -------------------------------------------------------------------------------------------------
   -- AxiVersion
   -------------------------------------------------------------------------------------------------
   U_AxiVersion_1 : entity work.AxiVersion
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_PERIOD_G    => 5.0e-9,
         XIL_DEVICE_G    => "7SERIES",
         EN_DEVICE_DNA_G => true,
         EN_DS2411_G     => false,
         EN_ICAP_G       => true)
      port map (
         axiClk         => clk200,                               -- [in]
         axiRst         => rst200,                               -- [in]
         axiReadMaster  => locAxilReadMasters(AXIL_VERSION_C),   -- [in]
         axiReadSlave   => locAxilReadSlaves(AXIL_VERSION_C),    -- [out]
         axiWriteMaster => locAxilWriteMasters(AXIL_VERSION_C),  -- [in]
         axiWriteSlave  => locAxilWriteSlaves(AXIL_VERSION_C));  -- [out]

   -------------------------------------------------------------------------------------------------
   -- Main KPIX DAQ Core
   -------------------------------------------------------------------------------------------------
   U_KpixDaqCore_1 : entity work.KpixDaqCore
      generic map (
         TPD_G              => TPD_G,
         AXIL_BASE_ADDR_G   => AXIL_XBAR_CONFIG_C(AXIL_KPIX_DAQ_C).baseAddr,
         NUM_KPIX_MODULES_G => 24)
      port map (
         clk200          => clk200,                                -- [in]
         rst200          => rst200,                                -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_KPIX_DAQ_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_KPIX_DAQ_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_KPIX_DAQ_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_KPIX_DAQ_C),   -- [out]
         ebAxisMaster    => ebAxisMaster,                          -- [out]
         ebAxisSlave     => ebAxisSlave,                           -- [in]
         ebAxisCtrl      => ebAxisCtrl,                            -- [in]
         extTriggers     => extTriggers,                           -- [in]
         debugOutA       => debugOutA,                             -- [out]
         debugOutB       => debugOutB,                             -- [out]
         kpixClkOut      => kpixClkOut,                            -- [out]
         kpixTriggerOut  => kpixTriggerOut,                        -- [out]
         kpixResetOut    => kpixResetOut,                          -- [out]
         kpixSerTxOut    => kpixSerTxOut,                          -- [out]
         kpixSerRxIn     => kpixSerRxIn);                          -- [in]

end architecture rtl;
