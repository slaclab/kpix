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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.EthMacPkg.all;

use work.KpixPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DesyTrackerEthCore is
   generic (
      TPD_G        : time             := 1 ns;
      SIMULATION_G : boolean          := false;
      DHCP_G       : boolean          := false;         -- true = DHCP, false = static address
      IP_ADDR_G    : slv(31 downto 0) := x"0A01A8C0");  -- 192.168.1.10 (before DHCP)
   port (
      refClkOut        : out sl;
      ethClkOut        : out sl;
      ethRstOut        : out sl;
      pllLocked        : out sl;
      -- Reference Clock and Reset
      clk200           : out sl;
      rst200           : out sl;
      -- AXI-Lite Interface (clk200 domain)
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType;
      -- Streaming Data (clk200 domain)
      ebAxisMaster     : in  AxiStreamMasterType;
      ebAxisSlave      : out AxiStreamSlaveType;
      ebAxisCtrl       : out AxiStreamCtrlType;
      -- Acq start from stream
      startAcq         : out sl;
      -- Eth/RSSI Status
      phyReady         : out sl;
      rssiStatus       : out slv(6 downto 0);
      sAxilReadMaster  : in  AxiLiteReadMasterType;
      sAxilReadSlave   : out AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      sAxilWriteMaster : in  AxiLiteWriteMasterType;
      sAxilWriteSlave  : out AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;
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

   constant RSSI_SIZE_C   : positive            := 2;
   constant AXIS_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(8);
--   constant AXIS_CONFIG_C : AxiStreamConfigArray(RSSI_SIZE_C-1 downto 0) := (others => ssiAxiStreamConfig(8));

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

   signal mAxilReadMasters  : AxiLiteReadMasterArray(SERVER_SIZE_C-1 downto 0);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray(SERVER_SIZE_C-1 downto 0);
   signal mAxilWriteMasters : AxiLiteWriteMasterArray(SERVER_SIZE_C-1 downto 0);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray(SERVER_SIZE_C-1 downto 0);

   signal acqReqValid : sl;

begin

   clk200 <= locClk200;
   rst200 <= locRst200;

   ethClkOut <= ethClk;
   ethRstOut <= ethRst;
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
   U_PwrUpRst : entity work.PwrUpRst
      generic map (
         TPD_G         => TPD_G,
         SIM_SPEEDUP_G => SIMULATION_G)
      port map (
         clk    => refClk,
         rstOut => refRst);

   ----------------
   -- Clock Manager
   ----------------
   U_MMCM : entity work.ClockManager7
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
         locked    => pllLocked);

   REAL_ETH_GEN : if (not SIMULATION_G) generate



      -------------------------
      -- GigE Core for KINTEX-7
      -------------------------
      U_ETH_PHY_MAC : entity work.GigEthGtx7
         generic map (
            TPD_G         => TPD_G,
            AXIS_CONFIG_G => EMAC_AXIS_CONFIG_C)
         port map (
            -- Local Configurations
            localMac    => localMac,
            -- Streaming DMA Interface 
            dmaClk      => ethClk,
            dmaRst      => ethRst,
            dmaIbMaster => rxMaster,
            dmaIbSlave  => rxSlave,
            dmaObMaster => txMaster,
            dmaObSlave  => txSlave,
            -- PHY + MAC signals
            sysClk62    => ethClkDiv2,
            sysClk125   => ethClk,
            sysRst125   => ethRst,
            extRst      => refRst,
            phyReady    => phyReady,
            -- MGT Ports
            gtTxP       => gtTxP,
            gtTxN       => gtTxN,
            gtRxP       => gtRxP,
            gtRxN       => gtRxN);

      ----------------------
      -- IPv4/ARP/UDP Engine
      ----------------------
      U_UDP : entity work.UdpEngineWrapper
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
            -- Clock and Reset
            clk             => ethClk,
            rst             => ethRst);

      ------------------------------------------
      -- Software's RSSI Server Interface @ 8192
      ------------------------------------------
      U_RssiServer : entity work.RssiCoreWrapper
         generic map (
            TPD_G                => TPD_G,
            APP_ILEAVE_EN_G      => true,
            ILEAVE_ON_NOTVALID_G => true,
            MAX_SEG_SIZE_G       => 1024,
            SEGMENT_ADDR_SIZE_G  => 7,
            APP_STREAMS_G        => 2,
            APP_STREAM_ROUTES_G  => (
               0                 => X"00",
               1                 => X"01"),
            CLK_FREQUENCY_G      => 125.0E+6,
            TIMEOUT_UNIT_G       => 1.0E-3,  -- In units of seconds
            SERVER_G             => true,
            RETRANSMIT_ENABLE_G  => true,
            BYPASS_CHUNKER_G     => false,
            WINDOW_ADDR_SIZE_G   => 3,
            PIPE_STAGES_G        => 1,
            APP_AXIS_CONFIG_G    => (0 => AXIS_CONFIG_C, 1 => AXIS_CONFIG_C),
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
            axiClk_i          => locClk200,
            axiRst_i          => locRst200,
            axilReadMaster    => sAxilReadMaster,
            axilReadSlave     => sAxilReadSlave,
            axilWriteMaster   => sAxilWriteMaster,
            axilWriteSlave    => sAxilWriteSlave,
            -- Internal statuses
            statusReg_o       => rssiStatus);

   end generate REAL_ETH_GEN;

   SIM_GEN : if (SIMULATION_G) generate
      DESTS : for i in 1 downto 0 generate
         U_RogueStreamSimWrap_1 : entity work.RogueStreamSimWrap
            generic map (
               TPD_G               => TPD_G,
               DEST_ID_G           => i,
               USER_ID_G           => 1,
               COMMON_MASTER_CLK_G => true,
               COMMON_SLAVE_CLK_G  => true,
               AXIS_CONFIG_G       => AXIS_CONFIG_C)
            port map (
               clk         => ethClk,            -- [in]
               rst         => ethRst,            -- [in]
               sAxisClk    => ethClk,            -- [in]
               sAxisRst    => ethRst,            -- [in]
               sAxisMaster => rssiIbMasters(i),  -- [in]
               sAxisSlave  => rssiIbSlaves(i),   -- [out]
               mAxisClk    => ethClk,            -- [in]
               mAxisRst    => ethRst,            -- [in]
               mAxisMaster => rssiObMasters(i),  -- [out]
               mAxisSlave  => rssiObSlaves(i));  -- [in]
      end generate;
   end generate SIM_GEN;

   ---------------------------------------
   -- TDEST = 0x0: Register access control   
   ---------------------------------------
   U_SRPv3 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => false,
         AXIL_CLK_FREQ_G     => 200.0e6,
         AXI_STREAM_CONFIG_G => AXIS_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => ethClk,
         sAxisRst         => ethRst,
         sAxisMaster      => rssiObMasters(0),
         sAxisSlave       => rssiObSlaves(0),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => ethClk,
         mAxisRst         => ethRst,
         mAxisMaster      => rssiIbMasters(0),
         mAxisSlave       => rssiIbSlaves(0),
         -- AXI Lite Bus (axilClk domain)
         axilClk          => locClk200,
         axilRst          => locRst200,
         mAxilReadMaster  => mAxilReadMaster,
         mAxilReadSlave   => mAxilReadSlave,
         mAxilWriteMaster => mAxilWriteMaster,
         mAxilWriteSlave  => mAxilWriteSlave);

   -----------------------------------------------------
   -- TDEST = 0x1: Streaming Data
   -- Will need FIFO here probably
   -----------------------------------------------------
   U_AxiStreamFifoV2_1 : entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         VALID_BURST_MODE_G  => false,
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 12,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 2**12-8,
         SLAVE_AXI_CONFIG_G  => EB_DATA_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_C)
      port map (
         sAxisClk    => locClk200,         -- [in]
         sAxisRst    => locRst200,         -- [in]
         sAxisMaster => ebAxisMaster,      -- [in]
         sAxisSlave  => ebAxisSlave,       -- [out]
         sAxisCtrl   => ebAxisCtrl,        -- [out]
         mAxisClk    => ethClk,            -- [in]
         mAxisRst    => ethRst,            -- [in]
         mAxisMaster => rssiIbMasters(1),  -- [out]
         mAxisSlave  => rssiIbSlaves(1));  -- [in]

   rssiObSlaves(1) <= AXI_STREAM_SLAVE_FORCE_C;  -- always ready

   acqReqValid <= rssiObMasters(1).tValid and toSl(rssiObMasters(1).tData(7 downto 0) = X"AA") and
                  rssiObMasters(1).tLast;  -- and ssiGetUserSof(AXIS_CONFIG_C, rssiObMasters(1));

   U_SynchronizerFifo_1 : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         COMMON_CLK_G => false,
         BRAM_EN_G    => false,
         DATA_WIDTH_G => 1,
         ADDR_WIDTH_G => 4)
      port map (
         rst    => ethRst,              -- [in]
         wr_clk => ethClk,              -- [in]
         wr_en  => acqReqValid,         -- [in]
         din    => (others => '0'),     -- [in]
         rd_clk => locClk200,           -- [in]
         rd_en  => '1',                 -- [in]
         valid  => startAcq,            -- [out]
         dout   => open);               -- [out]



end mapping;
