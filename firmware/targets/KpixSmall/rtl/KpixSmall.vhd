-------------------------------------------------------------------------------
-- Title      : KpixSmall
-------------------------------------------------------------------------------
-- File       : KpixSmall.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-21
-- Last update: 2020-04-14
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

library unisim;
use unisim.vcomponents.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library kpix;

entity KpixSmall is

   generic (
      TPD_G              : time          := 1 ns;
      BUILD_INFO_G       : BuildInfoType := BUILD_INFO_DEFAULT_SLV_C;
      NUM_KPIX_MODULES_G : natural       := 4);
   port (
      -- System clock, reset
      fpgaRstL   : in sl;
      gtpRefClkP : in sl;
      gtpRefClkN : in sl;

      -- Ethernet Interface
      gtpTxP : out sl;
      gtpTxN : out sl;
      gtpRxP : in  sl;
      gtpRxN : in  sl;

      -- Internal Kpix debug
      debugOutA : out sl;
      debugOutB : out sl;

      -- External Trigger
      nimA  : in sl;
      nimB  : in sl;
      cmosA : in sl;
      cmosB : in sl;

      -- Interface to KPiX modules
      kpixClkOutP     : out sl;
      kpixClkOutN     : out sl;
      kpixResetOut    : out sl;
      kpixTriggerOutP : out sl;
      kpixTriggerOutN : out sl;
      kpixSerTxOut    : out slv(NUM_KPIX_MODULES_G-1 downto 0);
      kpixSerRxIn     : in  slv(NUM_KPIX_MODULES_G-1 downto 0));

end entity KpixSmall;

architecture rtl of KpixSmall is

   constant NUM_AXIL_MASTERS_C : integer := 2;
   constant AXIL_VERSION_C     : integer := 0;
   constant AXIL_KPIX_DAQ_C    : integer := 1;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      AXIL_VERSION_C  => (
         baseAddr     => X"00000000",
         addrBits     => 12,
         connectivity => X"FFFF"),
      AXIL_KPIX_DAQ_C => (
         baseAddr     => X"01000000",
         addrBits     => 24,
         connectivity => X"FFFF"));


   -------------------------------------------------------------------------------------------------
   -- Clocks and resets
   -------------------------------------------------------------------------------------------------
   signal fpgaRst       : sl;
   signal fpgaRstHold   : sl;
   signal gtpRefClk     : sl;
   signal gtpRefClkOut  : sl;
   signal gtpRefClkBufg : sl;
   signal sysClk125     : sl;
   signal sysRst125     : sl;
   signal clk200        : sl;
   signal rst200        : sl;
   signal dcmLocked     : sl;
   signal axilClk       : sl;
   signal axilRst       : sl;
   signal softwareReset : sl;

   -------------------------------------------------------------------------------------------------
   -- AXI LITE signals
   -------------------------------------------------------------------------------------------------
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal locAxilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal locAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal kpixDaqAxilReadMaster  : AxiLiteReadMasterType;
   signal kpixDaqAxilReadSlave   : AxiLiteReadSlaveType;
   signal kpixDaqAxilWriteMaster : AxiLiteWriteMasterType;
   signal kpixDaqAxilWriteSlave  : AxiLiteWriteSlaveType;

   -------------------------------------------------------------------------------------------------
   -- Streams and commands
   -------------------------------------------------------------------------------------------------
   signal ebAxisMaster : AxiStreamMasterType;
   signal ebAxisSlave  : AxiStreamSlaveType;
   signal ebAxisCtrl   : AxiStreamCtrlType;

   signal ethAcqCmd   : sl;
   signal ethStartCmd : sl;

   -------------------------------------------------------------------------------------------------
   -- External signals
   -------------------------------------------------------------------------------------------------
   signal extTriggers : slv(7 downto 0);

   -------------------------------------------------------------------------------------------------
   -- KPIX signals
   -------------------------------------------------------------------------------------------------
   signal kpixClkOut     : sl;
   signal kpixClkDdr     : sl;
   signal kpixTriggerOut : sl;

   -------------------------------------------------------------------------------------------------
   -- DCM component
   -------------------------------------------------------------------------------------------------
   component main_dcm is
      port (
         CLKIN_IN   : in  sl;
         RST_IN     : in  sl;
         CLKFX_OUT  : out sl;
         CLK0_OUT   : out sl;
         LOCKED_OUT : out sl);
   end component main_dcm;

begin

   axilClk <= clk200;                   --sysClk125;
   axilRst <= rst200;                   --sysRst125;

   -- Input clock buffer
   GtpRefClkIbufds : IBUFDS
      port map (
         I  => gtpRefClkP,
         IB => gtpRefClkN,
         O  => gtpRefClk);

   GtpRefClkOutBufg : BUFG
      port map (
         I => gtpRefClkOut,
         O => gtpRefClkBufg);

   fpgaRst <= not fpgaRstL or softwareReset;

   -- Must hold reset for at least 3 clocks
   RstSync_FpgaRstHold : entity surf.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 10)
      port map (
         clk      => gtpRefClkBufg,
         asyncRst => fpgaRst,
         syncRst  => fpgaRstHold);

   -- Generate clocks
   main_dcm_1 : main_dcm
      port map (
         CLKIN_IN   => gtpRefClkBufg,
         RST_IN     => fpgaRstHold,
         CLKFX_OUT  => clk200,
         CLK0_OUT   => sysClk125,
         LOCKED_OUT => dcmLocked);

   -- Synchronize sysRst125
   SysRstSyncInst : entity surf.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '0',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 5)
      port map (
         clk      => sysClk125,
         asyncRst => dcmLocked,
         syncRst  => sysRst125);

   -- Synchronize rst200
   Clk200RstSyncInst : entity surf.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '0',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 8)
      port map (
         clk      => clk200,
         asyncRst => dcmLocked,
         syncRst  => rst200);

   -------------------------------------------------------------------------------------------------
   -- KPIX IO Buffers
   -------------------------------------------------------------------------------------------------
   ODDR_I : ODDR
      port map (
         C  => kpixClkOut,
         Q  => kpixClkDdr,
         CE => '1',
         D1 => '0',
         D2 => '1',
         R  => '0',
         S  => '0');
   OBUFDS_I : OBUFDS
      port map (
         I  => kpixClkDdr,
         O  => kpixClkOutP,
         OB => kpixClkOutN);

   -- Trigger
   TRIGGER_OBUF : OBUFDS
      port map (
         I  => kpixTriggerOut,
         O  => kpixTriggerOutP,
         OB => kpixTriggerOutN);

   -------------------------------------------------------------------------------------------------
   -- Assign extTriggers for KpixDaqCore
   -------------------------------------------------------------------------------------------------
   extTriggers(0) <= not nimA;
   extTriggers(1) <= not nimB;
   extTriggers(2) <= not cmosA;
   extTriggers(3) <= not cmosB;
   extTriggers(4) <= '0';
   extTriggers(5) <= '0';
   extTriggers(6) <= ethAcqCmd;
   extTriggers(7) <= ethStartCmd;


   -------------------------------------------------------------------------------------------------
   -- Ethernet core with SRPv3 and data fifo
   -------------------------------------------------------------------------------------------------
   U_EthFrontEnd_1 : entity kpix.EthFrontEnd
      generic map (
         TPD_G => TPD_G)
      port map (
         gtpClk           => sysClk125,        -- [in]
         gtpClkRst        => sysRst125,        -- [in]
         gtpRefClk        => gtpRefClk,        -- [in]
         gtpRefClkOut     => gtpRefClkOut,     -- [out]
         gtpRxN           => gtpRxN,           -- [in]
         gtpRxP           => gtpRxP,           -- [in]
         gtpTxN           => gtpTxN,           -- [out]
         gtpTxP           => gtpTxP,           -- [out]
         axilClk          => axilClk,          -- [in]
         axilRst          => axilRst,          -- [in]
         mAxilReadMaster  => axilReadMaster,   -- [out]
         mAxilReadSlave   => axilReadSlave,    -- [in]
         mAxilWriteMaster => axilWriteMaster,  -- [out]
         mAxilWriteSlave  => axilWriteSlave,   -- [in]
         clk200           => clk200,           -- [in]
         rst200           => rst200,           -- [in]
         ebAxisMaster     => ebAxisMaster,     -- [in]
         ebAxisSlave      => ebAxisSlave,      -- [out]
         ebAxisCtrl       => ebAxisCtrl,       -- [out]
         acqCmd           => ethAcqCmd,        -- [out]
         startCmd         => ethStartCmd);     -- [out]

   -------------------------------------------------------------------------------------------------
   -- Top level crossbar
   -------------------------------------------------------------------------------------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
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
   U_AxiVersion_1 : entity surf.AxiVersion
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_PERIOD_G    => 5.0e-9,
         XIL_DEVICE_G    => "7SERIES",
         EN_DEVICE_DNA_G => false,
         EN_DS2411_G     => false,
         EN_ICAP_G       => false)
      port map (
         axiClk         => axilClk,                              -- [in]
         axiRst         => axilRst,                              -- [in]
         axiReadMaster  => locAxilReadMasters(AXIL_VERSION_C),   -- [in]
         axiReadSlave   => locAxilReadSlaves(AXIL_VERSION_C),    -- [out]
         axiWriteMaster => locAxilWriteMasters(AXIL_VERSION_C),  -- [in]
         axiWriteSlave  => locAxilWriteSlaves(AXIL_VERSION_C));  -- [out]

   -------------------------------------------------------------------------------------------------
   -- Synchronize the AXI-Lite bus to selected 200Mhz clock that is sent to KpixDaqCore
   -------------------------------------------------------------------------------------------------
--    U_AxiLiteAsync_1 : entity surf.AxiLiteAsync
--       generic map (
--          TPD_G => TPD_G)
--       port map (
--          sAxiClk         => axilClk,                               -- [in]
--          sAxiClkRst      => axilRst,                               -- [in]
--          sAxiReadMaster  => locAxilReadMasters(AXIL_KPIX_DAQ_C),   -- [in]
--          sAxiReadSlave   => locAxilReadSlaves(AXIL_KPIX_DAQ_C),    -- [out]
--          sAxiWriteMaster => locAxilWriteMasters(AXIL_KPIX_DAQ_C),  -- [in]
--          sAxiWriteSlave  => locAxilWriteSlaves(AXIL_KPIX_DAQ_C),   -- [out]
--          mAxiClk         => clk200,                                -- [in]
--          mAxiClkRst      => rst200,                                -- [in]
--          mAxiReadMaster  => kpixDaqAxilReadMaster,                 -- [out]
--          mAxiReadSlave   => kpixDaqAxilReadSlave,                  -- [in]
--          mAxiWriteMaster => kpixDaqAxilWriteMaster,                -- [out]
--          mAxiWriteSlave  => kpixDaqAxilWriteSlave);                -- [in]

   -------------------------------------------------------------------------------------------------
   -- Main KPIX DAQ Core
   -------------------------------------------------------------------------------------------------
   U_KpixDaqCore_1 : entity kpix.KpixDaqCore
      generic map (
         TPD_G              => TPD_G,
         AXIL_BASE_ADDR_G   => AXIL_XBAR_CONFIG_C(AXIL_KPIX_DAQ_C).baseAddr,
         NUM_KPIX_MODULES_G => 4)
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
         busy            => open,                                  --[out]
         kpixClkOut      => kpixClkOut,                            -- [out]
         kpixTriggerOut  => kpixTriggerOut,                        -- [out]
         kpixResetOut    => kpixResetOut,                          -- [out]
         kpixSerTxOut    => kpixSerTxOut,                          -- [out]
         kpixSerRxIn     => kpixSerRxIn);                          -- [in]



end architecture rtl;
