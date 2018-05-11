-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixDaqCore.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-17
-- Last update: 2018-05-10
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
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

use work.EventBuilderFifoPkg.all;
use work.KpixPkg.all;
use work.KpixDataRxPkg.all;
use work.KpixRegRxPkg.all;
use work.TriggerPkg.all;
use work.KpixLocalPkg.all;
use work.KpixClockGenPkg.all;
use work.EvrCorePkg.all;

entity KpixDaqCore is

   generic (
      DELAY_G            : time    := 1 ns;
      NUM_KPIX_MODULES_G : natural := 4);
   port (
      sysClk : in sl;                   -- 125 MHz
      sysRst : in sl;

      clk200 : in sl;                   -- Used by KpixClockGen
      rst200 : in sl;

      -- AXI-Lite interface for registers
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- Acquired Data Streaming interface
      mAxisMaster : out AxiStreamMasterType;
      mAxisSlave  : in  AxiStreamSlaveType;
      mAxisCtrl   : in  AxiStreamCtrlType;


      -- Trigger interface
      triggerExtIn : in  TriggerExtInType;
      debugOutA    : out sl;
      debugOutB    : out sl;

      -- Interface to KPiX modules
      kpixClkOut     : out sl;
      kpixTriggerOut : out sl;
      kpixResetOut   : out sl;
      kpixSerTxOut   : out slv(NUM_KPIX_MODULES_G-1 downto 0);
      kpixSerRxIn    : in  slv(NUM_KPIX_MODULES_G-1 downto 0));


end entity KpixDaqCore;

architecture rtl of KpixDaqCore is

   constant AXIL_CROSSBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      SYS_INDEX_C     => (
         baseAddr     => SYS_ADDR_C,
         addrBits     => 20,
         connectivity => X"FFFF"),
      DAC_INDEX_C     => (
         baseAddr     => DAC_ADDR_C,
         addrBits     => 20,
         connectivity => X"FFFF"));

   signal locAxilWriteMaster : AxiLiteWriteMasterArray();


   -- Clock and reset for kpix clocked modules
   signal kpixClk    : sl;
   signal kpixClkRst : sl;


   -- Front end accessible registers
   signal kpixConfig : KpixConfigType;

   signal kpixDataRxRegsIn  : KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
   signal kpixDataRxRegsOut : KpixDataRxRegsOutArray(NUM_KPIX_MODULES_G-1 downto 0);
   signal kpixLocalRegsIn   : KpixLocalRegsInType;

   -- Triggers
   signal acqusitionControl : AcquisitionControlType;

   -- KPIX Rx Data Interface (with Event Builder)
   signal kpixDataRxOut : KpixDataRxOutArray(NUM_KPIX_MODULES_G-1 downto 0);
   signal kpixDataRxIn  : KpixDataRxInArray(NUM_KPIX_MODULES_G-1 downto 0);

   -- KPIX Rx Reg Interface
   -- One extra for the internal kpix
   signal kpixRegRxOut : KpixRegRxOutArray(NUM_KPIX_MODULES_G downto 0);

   -- KPIX Local signals
   signal kpixState : KpixStateOutType;

   -- Timestamp interface to EventBuilder
   signal timestampAxisMaster : AxiStreamMasterType;
   signal timestampAxisSlave  : AxiStreamSlaveType;

   -- Internal Kpix Signals
   -- One extra for internal kpix
   signal intKpixResetOut : sl;
   signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G downto 0);
   signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G downto 0);

begin

   kpixClkOut <= kpixClk;


   U_XBAR : entity work.AxiLiteCrossbar
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
   U_KpixConfig_1 : entity work.KpixConfig
      generic map (
         TPD_G => TPD_G)
      port map (
         clk200          => clk200,                              -- [in]
         rst200          => rst200,                              -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_CONFIG_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_CONFIG_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_CONFIG_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_CONFIG_C),   -- [out]
         kpixConfig      => kpixConfig);                         -- [out]


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
         startAcquire    => startAcquire,                           -- [in]
         kpixState       => kpixState,                              -- [in]
         kpixClk         => kpixClk,                                -- [out]
         kpixClkRst      => kpixClkRst,                             -- [out]
         kpixClkPreRise  => kpixClkPreRise,                         -- [out]
         kpixClkPreFall  => kpixClkPreFall,                         -- [out]
         kpixClkSample   => kpixClkSample);                         -- [out]

   --------------------------------------------------------------------------------------------------
   -- Trigger generator
   --------------------------------------------------------------------------------------------------
   U_Trigger_1 : entity work.Trigger
      generic map (
         TPD_G          => TPD_G,
         CLOCK_PERIOD_G => CLOCK_PERIOD_G)
      port map (
         clk200              => clk200,                               -- [in]
         rst200              => rst200,                               -- [in]
         axilReadMaster      => locAxilReadMasters(AXIL_TRIGGER_C),   -- [in]
         axilReadSlave       => locAxilReadSlaves(AXIL_TRIGGER_C),    -- [out]
         axilWriteMaster     => locAxilWriteMasters(AXIL_TRIGGER_C),  -- [in]
         axilWriteSlave      => locAxilWriteSlaves(AXIL_TRIGGER_C),   -- [out]
         kpixConfig          => kpixConfig,                           -- [in]
         extTriggers         => extTriggers,                          -- [in]
         opCode              => opCode,                               -- [in]
         opCodeEn            => opCodeEn,                             -- [in]
         kpixState           => kpixState,                            -- [in]
         triggerOut          => triggerOut,                           -- [out]
         timestampAxisMaster => timestampAxisMaster,                  -- [out]
         timestampAxisSlave  => timestampAxisSlave);                  -- [in]

   kpixTriggerOut <= triggerOut.trigger;

   --------------------------------------------------------------------------------------------------
   -- Event Builder
   --------------------------------------------------------------------------------------------------
   EventBuilder_1 : entity work.EventBuilder
      generic map (
         DELAY_G            => DELAY_G,
         NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
      port map (
         sysClk         => sysClk,
         sysRst         => sysRst,
         triggerOut     => triggerOut,
         timestampIn    => timestampIn,
         timestampOut   => timestampOut,
         evrOut         => sysEvrOut,
         sysKpixState   => sysKpixState,
         kpixDataRxOut  => kpixDataRxOut,
         kpixDataRxIn   => kpixDataRxIn,
         kpixClk        => kpixClk,
         kpixConfigRegs => kpixConfigRegs,
         triggerRegsIn  => triggerRegsIn,
         ebFifoIn       => ebFifoIn,
         ebFifoOut      => ebFifoOut,
         usBuff64Out    => usBuff64Out,
         usBuff64In     => usBuff64In);


   kpixSerTxOut                                  <= intKpixSerTxOut(NUM_KPIX_MODULES_G-1 downto 0);
   intKpixSerRxIn(NUM_KPIX_MODULES_G-1 downto 0) <= kpixSerRxIn;

   --------------------------------------------------------------------------------------------------
   -- KPIX Register Controller
   -- Handles reads and writes to KPIX registers through the FrontEnd interface
   --------------------------------------------------------------------------------------------------
   KpixRegCntl_1 : entity work.KpixRegCntl
      generic map (
         DELAY_G            => DELAY_G,
         NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
      port map (
         sysClk           => sysClk,
         sysRst           => sysRst,
         kpixRegCntlIn    => kpixRegCntlIn,
         kpixRegCntlOut   => kpixRegCntlOut,
         kpixConfigRegs   => kpixConfigRegs,
         kpixDataRxRegsIn => kpixDataRxRegsIn,
         kpixClk          => kpixClk,
         kpixClkRst       => kpixClkRst,
         kpixState        => kpixState,
         triggerOut       => triggerOut,
         kpixRegRxOut     => kpixRegRxOut,
         kpixSerTxOut     => intKpixSerTxOut,
         kpixResetOut     => intKpixResetOut);

   kpixResetOut <= intKpixResetOut;

   --------------------------------------------------------------------------------------------------
   -- KPIX Register Rx
   -- Deserializes data from a KPIX and presents it to KpixRegCntl
   -- when a register response is detected
   -- Must instantiate one for every connected KPIX including the local kpix
   --------------------------------------------------------------------------------------------------
   KpixRegRxGen : for i in NUM_KPIX_MODULES_G downto 0 generate
      KpixRegRxInst : entity work.KpixRegRx
         generic map (
            DELAY_G   => DELAY_G,
            KPIX_ID_G => i)
         port map (
            kpixClk            => kpixClk,
            kpixClkRst         => kpixClkRst,
            kpixConfigRegsKpix => kpixConfigRegsKpix,
            kpixSerRxIn        => intKpixSerRxIn(i),
            kpixRegRxOut       => kpixRegRxOut(i));
   end generate KpixRegRxGen;

   --------------------------------------------------------------------------------------------------
   -- KPIX Data Parser
   -- Parses incomming sample data into individual samples which are fed to the EventBuilder
   -- Must instantiate one for every connected KPIX including the local kpix
   --------------------------------------------------------------------------------------------------
   KpixDataRxGen : for i in NUM_KPIX_MODULES_G-1 downto 0 generate
      KpixDataRxInst : entity work.KpixDataRx
         generic map (
            DELAY_G   => DELAY_G,
            KPIX_ID_G => i)
         port map (
            kpixClk            => kpixClk,
            kpixClkRst         => kpixClkRst,
            kpixSerRxIn        => intKpixSerRxIn(i),
            kpixRegRxOut       => kpixRegRxOut(i),
            kpixConfigRegsKpix => kpixConfigRegsKpix,
            sysClk             => sysClk,
            sysRst             => sysRst,
            kpixConfigRegs     => kpixConfigRegs,
            extRegsIn          => kpixDataRxRegsIn(i),
            extRegsOut         => kpixDataRxRegsOut(i),
            kpixDataRxOut      => kpixDataRxOut(i),
            kpixDataRxIn       => kpixDataRxIn(i));
   end generate KpixDataRxGen;

   ----------------------------------------
   -- Local KPIX Device
   ----------------------------------------
   KpixLocalInst : entity work.KpixLocal
      port map (
         kpixClk      => kpixClk,
         kpixClkRst   => kpixClkRst,
         debugOutA    => debugOutA,
         debugOutB    => debugOutB,
         debugASel    => kpixLocalRegsIn.debugASel,
         debugBSel    => kpixLocalRegsIn.debugBSel,
         kpixReset    => intKpixResetOut,
         kpixCmd      => intKpixSerTxOut(NUM_KPIX_MODULES_G),
         kpixData     => intKpixSerRxIn(NUM_KPIX_MODULES_G),
         clk200       => clk200,
         rst200       => rst200,
         kpixState    => kpixState,
         calStrobeOut => open,
         sysClk       => sysClk,
         sysRst       => sysRst,
         sysKpixState => sysKpixState
         );

end architecture rtl;
