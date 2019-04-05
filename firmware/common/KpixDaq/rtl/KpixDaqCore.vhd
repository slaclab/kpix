-------------------------------------------------------------------------------
-- Title      : Kpix DAQ Core
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Integrates all of the modules that every KPIX firmware target
-- will need.
-------------------------------------------------------------------------------
-- This file is part of 'KPIX'
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'KPIX', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

use work.KpixPkg.all;
use work.KpixLocalPkg.all;

entity KpixDaqCore is

   generic (
      TPD_G              : time             := 1 ns;
      AXIL_BASE_ADDR_G   : slv(31 downto 0) := (others => '0');
      NUM_KPIX_MODULES_G : natural          := 4);
   port (
      clk200 : in sl;                   -- Used by KpixClockGen
      rst200 : in sl;

      -- AXI-Lite interface for registers
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- Acquired Data Streaming interface
      ebAxisMaster : out AxiStreamMasterType;
      ebAxisSlave  : in  AxiStreamSlaveType;
      ebAxisCtrl   : in  AxiStreamCtrlType;

      -- Trigger interface
      extTriggers : in  slv(7 downto 0);
      debugOutA   : out sl;
      debugOutB   : out sl;

      -- Interface to KPiX modules
      kpixClkOut     : out sl;
      kpixTriggerOut : out sl;
      kpixResetOut   : out sl;
      kpixSerTxOut   : out slv(NUM_KPIX_MODULES_G-1 downto 0);
      kpixSerRxIn    : in  slv(NUM_KPIX_MODULES_G-1 downto 0));

end entity KpixDaqCore;

architecture rtl of KpixDaqCore is

   constant AXIL_SYS_CONFIG_C   : integer := 0;
   constant AXIL_CLOCK_GEN_C    : integer := 1;
   constant AXIL_ACQ_CTRL_C     : integer := 2;
   constant AXIL_KPIX_REGS_C    : integer := 3;
   constant AXIL_KPIX_RX_DATA_C : integer := 4;

   constant NUM_AXIL_MASTERS_C : integer := 5;

   constant AXIL_CROSSBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      AXIL_SYS_CONFIG_C   => (
         baseAddr         => AXIL_BASE_ADDR_G + X"0000",
         addrBits         => 8,
         connectivity     => X"FFFF"),
      AXIL_CLOCK_GEN_C    => (
         baseAddr         => AXIL_BASE_ADDR_G + X"100",
         addrBits         => 8,
         connectivity     => X"FFFF"),
      AXIL_ACQ_CTRL_C     => (
         baseAddr         => AXIL_BASE_ADDR_G + X"200",
         addrBits         => 8,
         connectivity     => X"FFFF"),
      AXIL_KPIX_REGS_C    => (
         baseAddr         => AXIL_BASE_ADDR_G + X"100000",
         addrBits         => 18,        -- 33 kpixes, 7 addr bits per kpix, spacing
         connectivity     => X"FFFF"),
      AXIL_KPIX_RX_DATA_C => (
         baseAddr         => AXIL_BASE_ADDR_G + X"200000",
         addrBits         => 16,
         connectivity     => X"FFFF"));

   signal locAxilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   constant AXIL_DATA_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_KPIX_MODULES_G-1 downto 0) :=
      genAxiLiteConfig(NUM_KPIX_MODULES_G, AXIL_BASE_ADDR_G+X"200000", 20, 8);

   signal rxDataAxilReadMasters  : AxiLiteReadMasterArray(NUM_KPIX_MODULES_G-1 downto 0);
   signal rxDataAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_KPIX_MODULES_G-1 downto 0);
   signal rxDataAxilWriteMasters : AxiLiteWriteMasterArray(NUM_KPIX_MODULES_G-1 downto 0);
   signal rxDataAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_KPIX_MODULES_G-1 downto 0);

   -- Clock and reset for kpix clocked modules
   signal kpixClk        : sl;
   signal kpixClkPreRise : sl;
   signal kpixClkPreFall : sl;

   -- Front end accessible registers
   signal sysConfig : SysConfigType;

   -- Triggers
   signal acqControl : AcquisitionControlType;

   -- KPIX Rx Data Interface (with Event Builder)
   signal kpixDataRxMasters : AxiStreamMasterArray(NUM_KPIX_MODULES_G-1 downto 0);
   signal kpixDataRxSlaves  : AxiStreamSlaveArray(NUM_KPIX_MODULES_G-1 downto 0);

   -- Temperatures
   signal temperature : slv8Array(NUM_KPIX_MODULES_G-1 downto 0);
   signal tempCount   : slv12Array(NUM_KPIX_MODULES_G-1 downto 0);

   -- Timestamp interface to EventBuilder
   signal timestampAxisMaster : AxiStreamMasterType;
   signal timestampAxisSlave  : AxiStreamSlaveType;

   -- KPIX Local signals
   signal kpixState : KpixStateOutType;

   -- Internal Kpix Signals
   -- One extra for internal kpix
   signal intKpixResetOut : sl;
   signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G downto 0);
   signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G downto 0);

begin

   kpixClkOut <= kpixClk;


   U_MAIN_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CROSSBAR_CONFIG_C)
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
   -- System level configuration registers
   -------------------------------------------------------------------------------------------------
   U_SysConfig_1 : entity work.SysConfig
      generic map (
         TPD_G => TPD_G)
      port map (
         clk200          => clk200,                                  -- [in]
         rst200          => rst200,                                  -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_SYS_CONFIG_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_SYS_CONFIG_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_SYS_CONFIG_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_SYS_CONFIG_C),   -- [out]
         config          => sysConfig);                              -- [out]


   --------------------------------------------------------------------------------------------------
   -- Generate the KPIX Clock
   --------------------------------------------------------------------------------------------------
   U_KpixClockGen_1 : entity work.KpixClockGen
      generic map (
         TPD_G => TPD_G)
      port map (
         clk200          => clk200,                                 -- [in]
         rst200          => rst200,                                 -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_CLOCK_GEN_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_CLOCK_GEN_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_CLOCK_GEN_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_CLOCK_GEN_C),   -- [out]
         acqControl      => acqControl,                             -- [in]
         kpixState       => kpixState,                              -- [in]
         kpixClk         => kpixClk,                                -- [out]
         kpixClkPreRise  => kpixClkPreRise,                         -- [out]
         kpixClkPreFall  => kpixClkPreFall,                         -- [out]
         kpixClkSample   => open);                                  -- [out]

   --------------------------------------------------------------------------------------------------
   -- Acquisition Control
   --------------------------------------------------------------------------------------------------
   U_AcquisitionControl_1 : entity work.AcquisitionControl
      generic map (
         TPD_G          => TPD_G,
         CLOCK_PERIOD_G => 5.0e-9)
      port map (
         clk200              => clk200,                                -- [in]
         rst200              => rst200,                                -- [in]
         axilReadMaster      => locAxilReadMasters(AXIL_ACQ_CTRL_C),   -- [in]
         axilReadSlave       => locAxilReadSlaves(AXIL_ACQ_CTRL_C),    -- [out]
         axilWriteMaster     => locAxilWriteMasters(AXIL_ACQ_CTRL_C),  -- [in]
         axilWriteSlave      => locAxilWriteSlaves(AXIL_ACQ_CTRL_C),   -- [out]
         sysConfig           => sysConfig,                             -- [in]
         extTriggers         => extTriggers,                           -- [in]
         kpixState           => kpixState,                             -- [in]
         acqControl          => acqControl,                            -- [out]
         timestampAxisMaster => timestampAxisMaster,                   -- [out]
         timestampAxisSlave  => timestampAxisSlave);                   -- [in]

   kpixTriggerOut <= acqControl.trigger;

   --------------------------------------------------------------------------------------------------
   -- KPIX Register Control
   -- Handles reads and writes to KPIX registers via AXI-Lite interface
   --------------------------------------------------------------------------------------------------
   U_KpixRegCntl_1 : entity work.KpixRegCntl
      generic map (
         TPD_G              => TPD_G,
         NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
      port map (
         clk200          => clk200,                                 -- [in]
         rst200          => rst200,                                 -- [in]
         kpixClkPreRise  => kpixClkPreRise,                         -- [in]
         kpixClkPreFall  => kpixClkPreFall,                         -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_KPIX_REGS_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_KPIX_REGS_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_KPIX_REGS_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_KPIX_REGS_C),   -- [out]
         sysConfig       => sysConfig,                              -- [in]
         kpixState       => kpixState,                              -- [in]
         acqControl      => acqControl,                             -- [in]
         kpixSerTxOut    => intKpixSerTxOut,                        -- [out]
         kpixSerRxIn     => intKpixSerRxIn,                         -- [in]
         kpixResetOut    => intKpixResetOut,                        -- [out]
         temperature     => temperature,                            -- [out]
         tempCount       => tempCount);                             -- [out]

   kpixResetOut <= intKpixResetOut;

   --------------------------------------------------------------------------------------------------
   -- KPIX Data Parser
   -- Parses incomming seiral data stream into individual samples which are fed to the EventBuilder
   -- Must instantiate one for every connected KPIX (including the local kpix?)
   --------------------------------------------------------------------------------------------------
   U_RX_DATA_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_KPIX_MODULES_G,
         MASTERS_CONFIG_G   => AXIL_DATA_XBAR_CONFIG_C)
      port map (
         axiClk              => clk200,
         axiClkRst           => rst200,
         sAxiWriteMasters(0) => locAxilWriteMasters(AXIL_KPIX_RX_DATA_C),
         sAxiWriteSlaves(0)  => locAxilWriteSlaves(AXIL_KPIX_RX_DATA_C),
         sAxiReadMasters(0)  => locAxilReadMasters(AXIL_KPIX_RX_DATA_C),
         sAxiReadSlaves(0)   => locAxilReadSlaves(AXIL_KPIX_RX_DATA_C),
         mAxiWriteMasters    => rxDataAxilWriteMasters,
         mAxiWriteSlaves     => rxDataAxilWriteSlaves,
         mAxiReadMasters     => rxDataAxilReadMasters,
         mAxiReadSlaves      => rxDataAxilReadSlaves);

   KpixDataRxGen : for i in NUM_KPIX_MODULES_G-1 downto 0 generate
      U_KpixDataRx_1 : entity work.KpixDataRx
         generic map (
            TPD_G             => TPD_G,
            KPIX_ID_G         => i,
            NUM_ROW_BUFFERS_G => 4)
         port map (
            clk200           => clk200,                     -- [in]
            rst200           => rst200,                     -- [in]
            sysConfig        => sysConfig,                  -- [in]
            acqControl       => acqControl,                 -- [in]
            kpixClkPreFall   => kpixClkPreFall,             -- [in]
            kpixSerRxIn      => kpixSerRxIn(i),             -- [in]
            axilReadMaster   => rxDataAxilReadMasters(i),   -- [in]
            axilReadSlave    => rxDataAxilReadSlaves(i),    -- [out]
            axilWriteMaster  => rxDataAxilWriteMasters(i),  -- [in]
            axilWriteSlave   => rxDataAxilWriteSlaves(i),   -- [out]
            temperature      => temperature(i),             -- [in]
            tempCount        => tempCount(i),               -- [in]
            kpixDataRxMaster => kpixDataRxMasters(i),       -- [out]
            kpixDataRxSlave  => kpixDataRxSlaves(i));       -- [in]
   end generate;

   kpixSerTxOut                                  <= intKpixSerTxOut(NUM_KPIX_MODULES_G-1 downto 0);
   intKpixSerRxIn(NUM_KPIX_MODULES_G-1 downto 0) <= kpixSerRxIn;

   --------------------------------------------------------------------------------------------------
   -- Event Builder
   --------------------------------------------------------------------------------------------------
   U_EventBuilder_1 : entity work.EventBuilder
      generic map (
         TPD_G              => TPD_G,
         NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
      port map (
         clk200              => clk200,               -- [in]
         rst200              => rst200,               -- [in]
         sysConfig           => sysConfig,            -- [in]
         acqControl          => acqControl,           -- [in]
         kpixState           => kpixState,            -- [in]
         kpixClkPreRise      => kpixClkPreRise,       -- [in]
         timestampAxisMaster => timestampAxisMaster,  -- [in]
         timestampAxisSlave  => timestampAxisSlave,   -- [out]
         kpixDataRxMasters   => kpixDataRxMasters,    -- [in]
         kpixDataRxSlaves    => kpixDataRxSlaves,     -- [out]
         ebAxisMaster        => ebAxisMaster,         -- [out]
         ebAxisCtrl          => ebAxisCtrl);          -- [in]


   ----------------------------------------
   -- Local KPIX Device
   ----------------------------------------
   KpixLocalInst : entity work.KpixLocal
      port map (
         kpixClk        => kpixClk,
         debugOutA      => debugOutA,
         debugOutB      => open,
         debugASel      => sysConfig.debugASel,
         debugBSel      => sysConfig.debugBSel,
         kpixReset      => intKpixResetOut,
         kpixCmd        => intKpixSerTxOut(NUM_KPIX_MODULES_G),
         kpixData       => intKpixSerRxIn(NUM_KPIX_MODULES_G),
         clk200         => clk200,
         rst200         => rst200,
         kpixClkPreRise => kpixClkPreRise,
         kpixState      => kpixState,
         calStrobeOut   => open);
   debugOutB <= intKpixSerRxIn(NUM_KPIX_MODULES_G);

end architecture rtl;
