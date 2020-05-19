-------------------------------------------------------------------------------
-- Title      :  DesyTrackerEthCore
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Encapsulates ethernet stack, RSSI, SRP and IO buffers into a
-- single module.
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


library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.EthMacPkg.all;


library kpix;
use kpix.KpixPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DesyTrackerEthCore is
   generic (
      TPD_G            : time             := 1 ns;
      SIMULATION_G     : boolean          := false;
      SIM_PORT_NUM_G   : integer          := 9000;
      AXIL_BASE_ADDR_G : slv(31 downto 0) := X"00000000";
      DHCP_G           : boolean          := false;         -- true = DHCP, false = static address
      IP_ADDR_G        : slv(31 downto 0) := x"0A01A8C0");  -- 192.168.1.10 (before DHCP)
   port (
      refClkOut        : out sl;
      -- AXI-Lite Interface (clk200 domain)
      axilClk          : out sl;
      axilRst          : out sl;
      -- Master bus out
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType;
      -- Slave bus for local register access
      sAxilReadMaster  : in  AxiLiteReadMasterType;
      sAxilReadSlave   : out AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      sAxilWriteMaster : in  AxiLiteWriteMasterType;
      sAxilWriteSlave  : out AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;
      -- Eth/RSSI Status
      phyReady         : out sl;
      rssiStatus       : out slv(6 downto 0);
      -- Reference Clock and Reset
      ethClk200        : out sl;
      ethRst200        : out sl;
      -- Selected KPIX 200 MHz reference
      kpixClk200       : in  sl;
      kpixRst200       : in  sl;
      -- Event builder stream (kpixClk200 domain)
      ebAxisMaster     : in  AxiStreamMasterType;
      ebAxisSlave      : out AxiStreamSlaveType;
      ebAxisCtrl       : out AxiStreamCtrlType;
      -- Acq start from stream (kpixClk200 domain)
      acqCmd           : out sl;
      startCmd         : out sl;
      -- GbE Ports
      gtClkP           : in  sl;
      gtClkN           : in  sl;
      gtRxP            : in  sl;
      gtRxN            : in  sl;
      gtTxP            : out sl;
      gtTxN            : out sl);
end DesyTrackerEthCore;

architecture mapping of DesyTrackerEthCore is

   constant SERVER_SIZE_C  : positive                  := 1;
   constant SERVER_PORTS_C : PositiveArray(0 downto 0) := (0 => 8192);

   constant RSSI_SIZE_C   : positive            := 4;
   constant AXIS_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(8);
--   constant AXIS_CONFIG_C : AxiStreamConfigArray(RSSI_SIZE_C-1 downto 0) := (others => ssiAxiStreamConfig(8));

   constant AXIL_NUM_C     : integer := 5;
   constant AXIL_ETH_C     : integer := 0;
   constant AXIL_UDP_C     : integer := 1;
   constant AXIL_RSSI_C    : integer := 2;
   constant AXIL_PRBS_TX_C : integer := 3;
   constant AXIL_PRBS_RX_C : integer := 4;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(AXIL_NUM_C-1 downto 0) := (
      AXIL_ETH_C      => (
         baseAddr     => AXIL_BASE_ADDR_G + X"000000",
         addrBits     => 16,
         connectivity => X"FFFF"),
      AXIL_UDP_C      => (
         baseAddr     => AXIL_BASE_ADDR_G + X"010000",
         addrBits     => 12,
         connectivity => X"FFFF"),
      AXIL_RSSI_C     => (
         baseAddr     => AXIL_BASE_ADDR_G + X"011000",
         addrBits     => 12,
         connectivity => X"FFFF"),
      AXIL_PRBS_RX_C  => (
         baseAddr     => AXIL_BASE_ADDR_G + X"012000",
         addrBits     => 12,
         connectivity => X"FFFF"),
      AXIL_PRBS_TX_C  => (
         baseAddr     => AXIL_BASE_ADDR_G + X"013000",
         addrBits     => 8,
         connectivity => X"FFFF"));

   constant TDEST_SRP_C       : integer := 0;
   constant TDEST_TRIG_DATA_C : integer := 1;
   constant TDEST_PRBS_C      : integer := 2;
   constant TDEST_LOOPBACK_C  : integer := 3;

   signal gtClkDiv2  : sl;
   signal refClk     : sl;
   signal refRst     : sl;
   signal ethClk     : sl;
   signal ethRst     : sl;
   signal ethClkDiv2 : sl;
   signal ethRstDiv2 : sl;
   signal locClk200  : sl;
   signal locRst200  : sl;

   signal efuse    : slv(31 downto 0);
   signal localMac : slv(47 downto 0);

   signal rxMaster : AxiStreamMasterType;
   signal rxSlave  : AxiStreamSlaveType;
   signal txMaster : AxiStreamMasterType;
   signal txSlave  : AxiStreamSlaveType;

   signal ibServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0);
   signal obServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0);

   signal rssiIbMasters : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiIbSlaves  : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObMasters : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObSlaves  : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);

   signal locAxilReadMasters  : AxiLiteReadMasterArray(AXIL_NUM_C-1 downto 0);
   signal locAxilReadSlaves   : AxiLiteReadSlaveArray(AXIL_NUM_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   signal locAxilWriteMasters : AxiLiteWriteMasterArray(AXIL_NUM_C-1 downto 0);
   signal locAxilWriteSlaves  : AxiLiteWriteSlaveArray(AXIL_NUM_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   signal acqReqValid      : sl;
   signal startReqValid    : sl;
   signal acqReqValidReg   : sl;
   signal startReqValidReg : sl;
   signal ethCmd           : sl;
   signal cmdValid         : sl;
   signal acqCmdTmp        : sl;
   signal startCmdTmp      : sl;

begin

   axilClk <= ethClk;
   axilRst <= ethRst;

   ethClk200 <= locClk200;
   ethRst200 <= locRst200;

   refClkOut <= refClk;

   --------------------
   -- Local MAC Address
   --------------------
--    U_EFuse : EFUSE_USR
--       port map (
--          EFUSEUSR => efuse);

--    localMac(23 downto 0)  <= x"56_00_08";  -- 08:00:56:XX:XX:XX (big endian SLV)   
--    localMac(47 downto 24) <= efuse(31 downto 8);

   localMac(47 downto 0) <= x"00_00_16_56_00_08";

   ------------------
   -- Reference Clock
   ------------------
   U_IBUFDS_GTE2 : IBUFDS_GTE2
      port map (
         I     => gtClkP,
         IB    => gtClkN,
         CEB   => '0',
         ODIV2 => gtClkDiv2,
         O     => open);

   U_BUFG : BUFG
      port map (
         I => gtClkDiv2,
         O => refClk);

   -----------------
   -- Power Up Reset
   -----------------
   U_PwrUpRst : entity surf.PwrUpRst
      generic map (
         TPD_G         => TPD_G,
         SIM_SPEEDUP_G => SIMULATION_G)
      port map (
         clk    => refClk,
         rstOut => refRst);

   ----------------
   -- Clock Manager
   ----------------
   U_MMCM : entity surf.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,    -- Without this, will never lock in simulation
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 3,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,     -- 156.25 MHz
         DIVCLK_DIVIDE_G    => 5,       -- 31.25 MHz = 156.25 MHz/5
         CLKFBOUT_MULT_F_G  => 32.0,    -- 1.0GHz = 32 x 31.25 MHz
         CLKOUT0_DIVIDE_F_G => 8.0,     -- 125 MHz = 1.0GHz/8
         CLKOUT1_DIVIDE_G   => 16,      -- 62.5 MHz = 1.0GHz/16
         CLKOUT2_DIVIDE_G   => 5)       -- 200 MHz = 1.0GHz/5
      port map(
         clkIn     => refClk,
         rstIn     => refRst,
         clkOut(0) => ethClk,
         clkOut(1) => ethClkDiv2,
         clkOut(2) => locClk200,
         rstOut(0) => ethRst,
         rstOut(1) => ethRstDiv2,
         rstOut(2) => locRst200,
         locked    => open);

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => AXIL_NUM_C,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => ethClk,
         axiClkRst           => ethRst,
         sAxiWriteMasters(0) => sAxilWriteMaster,
         sAxiWriteSlaves(0)  => sAxilWriteSlave,
         sAxiReadMasters(0)  => sAxilReadMaster,
         sAxiReadSlaves(0)   => sAxilReadSlave,
         mAxiWriteMasters    => locAxilWriteMasters,
         mAxiWriteSlaves     => locAxilWriteSlaves,
         mAxiReadMasters     => locAxilReadMasters,
         mAxiReadSlaves      => locAxilReadSlaves);


   REAL_ETH_GEN : if (not SIMULATION_G) generate

      -------------------------
      -- GigE Core for KINTEX-7
      -------------------------
      U_ETH_PHY_MAC : entity surf.GigEthGtx7
         generic map (
            TPD_G                   => TPD_G,
            EN_AXI_REG_G            => true,
            AXIL_BASE_ADDR_G        => AXIL_XBAR_CONFIG_C(AXIL_ETH_C).baseAddr,
            AXIL_CLK_IS_SYSCLK125_G => true,
            AXIS_CONFIG_G           => EMAC_AXIS_CONFIG_C)
         port map (
            -- Local Configurations
            localMac           => localMac,
            -- Streaming DMA Interface 
            dmaClk             => ethClk,
            dmaRst             => ethRst,
            dmaIbMaster        => rxMaster,
            dmaIbSlave         => rxSlave,
            dmaObMaster        => txMaster,
            dmaObSlave         => txSlave,
            -- AXI Lite debug interface
            axiLiteClk         => ethClk,
            axiLiteRst         => ethRst,
            axiLiteReadMaster  => locAxilReadMasters(AXIL_ETH_C),
            axiLiteReadSlave   => locAxilReadSlaves(AXIL_ETH_C),
            axiLiteWriteMaster => locAxilWriteMasters(AXIL_ETH_C),
            axiLiteWriteSlave  => locAxilWriteSlaves(AXIL_ETH_C),
            -- PHY + MAC signals
            sysClk62           => ethClkDiv2,
            sysClk125          => ethClk,
            sysRst125          => ethRst,
            extRst             => refRst,
            phyReady           => phyReady,
            -- MGT Ports
            gtTxP              => gtTxP,
            gtTxN              => gtTxN,
            gtRxP              => gtRxP,
            gtRxN              => gtRxN);

      ----------------------
      -- IPv4/ARP/UDP Engine
      ----------------------
      U_UDP : entity surf.UdpEngineWrapper
         generic map (
            -- Simulation Generics
            TPD_G          => TPD_G,
            -- UDP Server Generics
            SERVER_EN_G    => true,
            SERVER_SIZE_G  => SERVER_SIZE_C,
            SERVER_PORTS_G => SERVER_PORTS_C,
            -- UDP Client Generics
            CLIENT_EN_G    => false,
            -- General IPv4/ARP/DHCP Generics
            DHCP_G         => DHCP_G,
            CLK_FREQ_G     => 125.0E+6,
            COMM_TIMEOUT_G => 30)
         port map (
            -- Local Configurations
            localMac        => localMac,
            localIp         => IP_ADDR_G,
            -- Interface to Ethernet Media Access Controller (MAC)
            obMacMaster     => rxMaster,
            obMacSlave      => rxSlave,
            ibMacMaster     => txMaster,
            ibMacSlave      => txSlave,
            -- Interface to UDP Server engine(s)
            obServerMasters => obServerMasters,
            obServerSlaves  => obServerSlaves,
            ibServerMasters => ibServerMasters,
            ibServerSlaves  => ibServerSlaves,
            -- AXI Lite debug interface
            axilReadMaster  => locAxilReadMasters(AXIL_UDP_C),
            axilReadSlave   => locAxilReadSlaves(AXIL_UDP_C),
            axilWriteMaster => locAxilWriteMasters(AXIL_UDP_C),
            axilWriteSlave  => locAxilWriteSlaves(AXIL_UDP_C),
            -- Clock and Reset
            clk             => ethClk,
            rst             => ethRst);

      ------------------------------------------
      -- Software's RSSI Server Interface @ 8192
      ------------------------------------------
      U_RssiServer : entity surf.RssiCoreWrapper
         generic map (
            TPD_G                => TPD_G,
            APP_ILEAVE_EN_G      => true,
            ILEAVE_ON_NOTVALID_G => true,
            MAX_SEG_SIZE_G       => 1024,
            SEGMENT_ADDR_SIZE_G  => 7,
            APP_STREAMS_G        => 4,
            APP_STREAM_ROUTES_G  => (
               0                 => X"00",
               1                 => X"01",
               2                 => X"02",
               3                 => X"03"),
            CLK_FREQUENCY_G      => 125.0E+6,
            TIMEOUT_UNIT_G       => 1.0E-3,  -- In units of seconds
            SERVER_G             => true,
            RETRANSMIT_ENABLE_G  => true,
            BYPASS_CHUNKER_G     => false,
            WINDOW_ADDR_SIZE_G   => 3,
            PIPE_STAGES_G        => 1,
            APP_AXIS_CONFIG_G    => (
               0                 => AXIS_CONFIG_C,
               1                 => AXIS_CONFIG_C,
               2                 => AXIS_CONFIG_C,
               3                 => AXIS_CONFIG_C),
            TSP_AXIS_CONFIG_G    => EMAC_AXIS_CONFIG_C,
            INIT_SEQ_N_G         => 16#80#)
         port map (
            clk_i             => ethClk,
            rst_i             => ethRst,
            openRq_i          => '1',
            -- Application Layer Interface
            sAppAxisMasters_i => rssiIbMasters,
            sAppAxisSlaves_o  => rssiIbSlaves,
            mAppAxisMasters_o => rssiObMasters,
            mAppAxisSlaves_i  => rssiObSlaves,
            -- Transport Layer Interface
            sTspAxisMaster_i  => obServerMasters(0),
            sTspAxisSlave_o   => obServerSlaves(0),
            mTspAxisMaster_o  => ibServerMasters(0),
            mTspAxisSlave_i   => ibServerSlaves(0),
            -- AXI-Lite Interface
            axiClk_i          => ethClk,
            axiRst_i          => ethRst,
            axilReadMaster    => locAxilReadMasters(AXIL_RSSI_C),
            axilReadSlave     => locAxilReadSlaves(AXIL_RSSI_C),
            axilWriteMaster   => locAxilWriteMasters(AXIL_RSSI_C),
            axilWriteSlave    => locAxilWriteSlaves(AXIL_RSSI_C),
            -- Internal statuses
            statusReg_o       => rssiStatus);

   end generate REAL_ETH_GEN;

   SIM_GEN : if (SIMULATION_G) generate
      DESTS : for i in 1 downto 0 generate
         U_RogueTcpStreamWrap_1 : entity surf.RogueTcpStreamWrap
            generic map (
               TPD_G         => TPD_G,
               PORT_NUM_G    => SIM_PORT_NUM_G + i*2,
               SSI_EN_G      => true,
               CHAN_COUNT_G  => 1,
               AXIS_CONFIG_G => AXIS_CONFIG_C)
            port map (
               axisClk     => ethClk,            -- [in]
               axisRst     => ethRst,            -- [in]
               sAxisMaster => rssiIbMasters(i),  -- [in]
               sAxisSlave  => rssiIbSlaves(i),   -- [out]
               mAxisMaster => rssiObMasters(i),  -- [out]
               mAxisSlave  => rssiObSlaves(i));  -- [in]
      end generate;
   end generate SIM_GEN;

   ---------------------------------------
   -- TDEST = 0x0: Register access control   
   ---------------------------------------
   U_SRPv3 : entity surf.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         AXIL_CLK_FREQ_G     => 125.0e6,
         AXI_STREAM_CONFIG_G => AXIS_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => ethClk,
         sAxisRst         => ethRst,
         sAxisMaster      => rssiObMasters(TDEST_SRP_C),
         sAxisSlave       => rssiObSlaves(TDEST_SRP_C),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => ethClk,
         mAxisRst         => ethRst,
         mAxisMaster      => rssiIbMasters(TDEST_SRP_C),
         mAxisSlave       => rssiIbSlaves(TDEST_SRP_C),
         -- AXI Lite Bus (axilClk domain)
         axilClk          => ethClk,
         axilRst          => ethRst,
         mAxilReadMaster  => mAxilReadMaster,
         mAxilReadSlave   => mAxilReadSlave,
         mAxilWriteMaster => mAxilWriteMaster,
         mAxilWriteSlave  => mAxilWriteSlave);

   -----------------------------------------------------
   -- TDEST = 0x1: Streaming Data
   -----------------------------------------------------
   U_AxiStreamFifoV2_1 : entity surf.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         VALID_BURST_MODE_G  => false,
         SYNTH_MODE_G        => "inferred",
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 12,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 2**12-32,
         SLAVE_AXI_CONFIG_G  => EB_DATA_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_C)
      port map (
         sAxisClk    => kpixClk200,                        -- [in]
         sAxisRst    => kpixRst200,                        -- [in]
         sAxisMaster => ebAxisMaster,                      -- [in]
         sAxisSlave  => ebAxisSlave,                       -- [out]
         sAxisCtrl   => ebAxisCtrl,                        -- [out]
         mAxisClk    => ethClk,                            -- [in]
         mAxisRst    => ethRst,                            -- [in]
         mAxisMaster => rssiIbMasters(TDEST_TRIG_DATA_C),  -- [out]
         mAxisSlave  => rssiIbSlaves(TDEST_TRIG_DATA_C));  -- [in]

   rssiObSlaves(TDEST_TRIG_DATA_C) <= AXI_STREAM_SLAVE_FORCE_C;  -- always ready

   acqReqValid <= rssiObMasters(TDEST_TRIG_DATA_C).tValid and
                  toSl(rssiObMasters(TDEST_TRIG_DATA_C).tData(7 downto 0) = X"AA") and
                  rssiObMasters(TDEST_TRIG_DATA_C).tLast;

   startReqValid <= rssiObMasters(TDEST_TRIG_DATA_C).tValid and
                    toSl(rssiObMasters(TDEST_TRIG_DATA_C).tData(7 downto 0) = X"55") and
                    rssiObMasters(TDEST_TRIG_DATA_C).tLast;

   U_RegisterVector_1 : entity surf.RegisterVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         clk      => ethClk,             -- [in]
         rst      => ethRst,             -- [in]
         sig_i(0) => acqReqValid,        -- [in]
         sig_i(1) => startReqValid,      -- [in]
         reg_o(0) => acqReqValidReg,     -- [out]
         reg_o(1) => startReqValidReg);  -- [out]

   U_SynchronizerOneShot_ACQUIRE : entity surf.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => kpixClk200,         -- [in]
         rst     => kpixRst200,         -- [in]
         dataIn  => acqReqValidReg,     -- [in]
         dataOut => acqCmd);            -- [out]

   U_SynchronizerOneShot_START : entity surf.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => kpixClk200,         -- [in]
         rst     => kpixRst200,         -- [in]
         dataIn  => startReqValidReg,   -- [in]
         dataOut => startCmd);          -- [out]


   -------------------------------------------------------------------------------------------------
   -- TDEST 0x2
   -- PRBS
   -------------------------------------------------------------------------------------------------
   U_SsiPrbsRx_1 : entity surf.SsiPrbsRx
      generic map (
         TPD_G                     => TPD_G,
         STATUS_CNT_WIDTH_G        => 32,
         SLAVE_READY_EN_G          => true,
         GEN_SYNC_FIFO_G           => true,
--          FIFO_ADDR_WIDTH_G         => FIFO_ADDR_WIDTH_G,
--          FIFO_PAUSE_THRESH_G       => FIFO_PAUSE_THRESH_G,
--          SYNTH_MODE_G              => SYNTH_MODE_G,
--          MEMORY_TYPE_G             => MEMORY_TYPE_G,
--          PRBS_SEED_SIZE_G          => PRBS_SEED_SIZE_G,
--          PRBS_TAPS_G               => PRBS_TAPS_G,
         SLAVE_AXI_STREAM_CONFIG_G => AXIS_CONFIG_C,
         SLAVE_AXI_PIPE_STAGES_G   => 1)
      port map (
         sAxisClk       => ethClk,                               -- [in]
         sAxisRst       => ethRst,                               -- [in]
         sAxisMaster    => rssiObMasters(TDEST_PRBS_C),          -- [in]
         sAxisSlave     => rssiObSlaves(TDEST_PRBS_C),           -- [out]
--         sAxisCtrl       => sAxisCtrl,        -- [out]
         axiClk         => ethClk,                               -- [in]
         axiRst         => ethRst,                               -- [in]
         axiReadMaster  => locAxilReadMasters(AXIL_PRBS_RX_C),   -- [in]
         axiReadSlave   => locAxilReadSlaves(AXIL_PRBS_RX_C),    -- [out]
         axiWriteMaster => locAxilWriteMasters(AXIL_PRBS_RX_C),  -- [in]
         axiWriteSlave  => locAxilWriteSlaves(AXIL_PRBS_RX_C));  -- [out]

   U_SsiPrbsTx_1 : entity surf.SsiPrbsTx
      generic map (
         TPD_G                      => TPD_G,
--          AXI_EN_G                   => AXI_EN_G,
--          AXI_DEFAULT_PKT_LEN_G      => AXI_DEFAULT_PKT_LEN_G,
--          AXI_DEFAULT_TRIG_DLY_G     => AXI_DEFAULT_TRIG_DLY_G,
--          VALID_THOLD_G              => VALID_THOLD_G,
--          VALID_BURST_MODE_G         => VALID_BURST_MODE_G,
--          SYNTH_MODE_G               => SYNTH_MODE_G,
--          MEMORY_TYPE_G              => MEMORY_TYPE_G,
         GEN_SYNC_FIFO_G            => true,
--          CASCADE_SIZE_G             => CASCADE_SIZE_G,
--          FIFO_ADDR_WIDTH_G          => FIFO_ADDR_WIDTH_G,
--          FIFO_PAUSE_THRESH_G        => FIFO_PAUSE_THRESH_G,
--          PRBS_SEED_SIZE_G           => PRBS_SEED_SIZE_G,
--          PRBS_TAPS_G                => PRBS_TAPS_G,
--          PRBS_INCREMENT_G           => PRBS_INCREMENT_G,
         MASTER_AXI_STREAM_CONFIG_G => AXIS_CONFIG_C,
         MASTER_AXI_PIPE_STAGES_G   => 1)
      port map (
         mAxisClk        => ethClk,                               -- [in]
         mAxisRst        => ethRst,                               -- [in]
         mAxisMaster     => rssiIbMasters(TDEST_PRBS_C),          -- [out]
         mAxisSlave      => rssiIbSlaves(TDEST_PRBS_C),           -- [in]
         locClk          => ethClk,                               -- [in]
         locRst          => ethRst,                               -- [in]
--          trig            => trig,             -- [in]
--          packetLength    => packetLength,     -- [in]
--          forceEofe       => forceEofe,        -- [in]
--          busy            => busy,             -- [out]
--          tDest           => tDest,            -- [in]
--          tId             => tId,              -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_PRBS_TX_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_PRBS_TX_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_PRBS_TX_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_PRBS_TX_C));  -- [out]

   -------------------------------------------------------------------------------------------------
   -- TDEST 0x3
   -- Loopback
   -------------------------------------------------------------------------------------------------
   U_AxiStreamFifoV2_LOOPBACK : entity surf.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         VALID_BURST_MODE_G  => false,
         SYNTH_MODE_G        => "inferred",
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
--         FIFO_PAUSE_THRESH_G => 2**12-32,
         SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_C)
      port map (
         sAxisClk    => ethClk,                           -- [in]
         sAxisRst    => ethRst,                           -- [in]
         sAxisMaster => rssiObMasters(TDEST_LOOPBACK_C),  -- [in]
         sAxisSlave  => rssiObSlaves(TDEST_LOOPBACK_C),   -- [out]
         mAxisClk    => ethClk,                           -- [in]
         mAxisRst    => ethRst,                           -- [in]
         mAxisMaster => rssiIbMasters(TDEST_LOOPBACK_C),  -- [out]
         mAxisSlave  => rssiIbSlaves(TDEST_LOOPBACK_C));  -- [in]



end mapping;
