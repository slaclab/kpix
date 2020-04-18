-------------------------------------------------------------------------------
-- Title      : KpixEmtbEth
-------------------------------------------------------------------------------
-- File       : KpixEmtbEth.vhd
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
use kpix.EvrCorePkg.all;

entity KpixEmtbEth is

   generic (
      TPD_G              : time          := 1 ns;
      BUILD_INFO_G       : BuildInfoType := BUILD_INFO_DEFAULT_SLV_C;
      NUM_KPIX_MODULES_G : natural       := 12);
   port (
      -- System clock, reset
      fpgaRstL   : in std_logic;
      gtpRefClkP : in std_logic;
      gtpRefClkN : in std_logic;

      -- Ethernet Interface
      gtpTxP : out std_logic;
      gtpTxN : out std_logic;
      gtpRxP : in  std_logic;
      gtpRxN : in  std_logic;

      -- Evr clock and interface
      evrRefClkP : in sl;
      evrRefClkN : in sl;
--    evrTxP  : out sl;
--    evrTxN  : out sl;
      evrRxP     : in sl;
      evrRxN     : in sl;

      -- Internal Kpix debug
      debugOutA : out sl;
      debugOutB : out sl;

      -- External Trigger
      cmosIn : in sl;
      lemoIn : in sl;

      -- Interface to KPiX modules
      kpixClkOutP     : out slv(3 downto 0);
      kpixClkOutN     : out slv(3 downto 0);
      kpixRstOut      : out sl;
      kpixTriggerOutP : out slv(3 downto 0);
      kpixTriggerOutN : out slv(3 downto 0);
      kpixSerTxOut    : out slv(NUM_KPIX_MODULES_G-1 downto 0);
      kpixSerRxIn     : in  slv(NUM_KPIX_MODULES_G-1 downto 0));

end entity KpixEmtbEth;

architecture rtl of KpixEmtbEth is

   constant NUM_AXIL_MASTERS_C : integer := 3;
   constant AXIL_VERSION_C     : integer := 0;
   constant AXIL_KPIX_DAQ_C    : integer := 1;
   constant AXIL_EVR_C         : integer := 2;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      AXIL_VERSION_C  => (
         baseAddr     => X"00000000",
         addrBits     => 12,
         connectivity => X"FFFF"),
      AXIL_KPIX_DAQ_C => (
         baseAddr     => X"01000000",
         addrBits     => 24,
         connectivity => X"FFFF"),
      AXIL_EVR_C      => (
         baseAddr     => X"02000000",
         addrBits     => 8,
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



   -- EVR Signals
   signal evrClk           : sl;
   signal evrOut           : EvrOutType;            -- evrClk
   signal sysEvrOut        : EvrOutType;            -- sysClk

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
   signal kpixClkDdr     : slv(3 downto 0);
   signal kpixTriggerOut : sl;

   -- Internal Kpix signals
   signal intKpixSerTxOut : slv(NUM_KPIX_MODULES_G-1 downto 0);
   signal intKpixSerRxIn  : slv(NUM_KPIX_MODULES_G-1 downto 0);

   -- Stupid XST forces component declarations for generated cores
   component main_dcm is
      port (
         CLKIN_IN   : in  std_logic;
         RST_IN     : in  std_logic;
         CLKFX_OUT  : out std_logic;
         CLK0_OUT   : out std_logic;
         LOCKED_OUT : out std_logic);
   end component main_dcm;

begin

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
   -- KPIX IO BUffers
   -------------------------------------------------------------------------------------------------
   CLK_TRIG_OBUF_GEN : for i in 3 downto 0 generate

      ODDR_I : ODDR
         port map (
            C  => kpixClkOut,
            Q  => kpixClkDdr(i),
            CE => '1',
            D1 => '0',
            D2 => '1',
            R  => '0',
            S  => '0');
      OBUFDS_I : OBUFDS
         port map (
            I  => kpixClkDdr(i),
            O  => kpixClkOutP(i),
            OB => kpixClkOutN(i));


      OBUF_TRIG : OBUFDS
         port map (
            I  => kpixTriggerOut,
            O  => kpixTriggerOutP(i),
            OB => kpixTriggerOutN(i));

   end generate;

   -------------------------------------------------------------------------------------------------
   -- Assign extTriggers for KpixDaqCore
   -------------------------------------------------------------------------------------------------
   extTriggers(0) <= not lemoIn;
   extTriggers(1) <= '0';
   extTriggers(2) <= not cmosIn;
   extTriggers(3) <= '0';
   extTriggers(4) <= '0';
   extTriggers(5) <= evrOut.trigger;
   extTriggers(6) <= ethAcqCmd;
   extTriggers(7) <= ethStartCmd;

   -- Ethernet module
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
         axilClk          => clk200,           -- [in]
         axilRst          => rst200,           -- [in]
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

   -- EVR
   U_EvrGtp_1 : entity kpix.EvrGtp
      generic map (
         TPD_G => TPD_G)
      port map (
         gtpRefClkP      => evrRefClkP,                       -- [in]
         gtpRefClkN      => evrRefClkN,                       -- [in]
         gtpRxP          => evrRxP,                           -- [in]
         gtpRxN          => evrRxN,                           -- [in]
         evrOut          => evrOut,                           -- [out]
         sysClk          => clk200,                           -- [in]
         sysRst          => rst200,                           -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_EVR_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_EVR_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_EVR_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_EVR_C),   -- [out]
         sysEvrOut       => sysEvrOut);                       -- [out]


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
         axiClk         => clk200,                               -- [in]
         axiRst         => rst200,                               -- [in]
         axiReadMaster  => locAxilReadMasters(AXIL_VERSION_C),   -- [in]
         axiReadSlave   => locAxilReadSlaves(AXIL_VERSION_C),    -- [out]
         axiWriteMaster => locAxilWriteMasters(AXIL_VERSION_C),  -- [in]
         axiWriteSlave  => locAxilWriteSlaves(AXIL_VERSION_C));  -- [out]

   -------------------------------------------------------------------------------------------------
   -- Main KPIX DAQ Core
   -------------------------------------------------------------------------------------------------
   U_KpixDaqCore_1 : entity kpix.KpixDaqCore
      generic map (
         TPD_G              => TPD_G,
         AXIL_BASE_ADDR_G   => AXIL_XBAR_CONFIG_C(AXIL_KPIX_DAQ_C).baseAddr,
         NUM_KPIX_MODULES_G => NUM_KPIX_MODULES_G)
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
         kpixResetOut    => kpixRstOut,                            -- [out]
         kpixSerTxOut    => kpixSerTxOut,                          -- [out]
         kpixSerRxIn     => kpixSerRxIn);                          -- [in]


end architecture rtl;
