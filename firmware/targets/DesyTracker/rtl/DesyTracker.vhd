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
use work.I2cPkg.all;

use work.KpixPkg.all;

library unisim;
use unisim.vcomponents.all;


entity DesyTracker is
   generic (
      TPD_G        : time             := 1 ns;
      SIMULATION_G : boolean          := false;
      BUILD_INFO_G : BuildInfoType;
      DHCP_G       : boolean          := false;
      IP_ADDR_G    : slv(31 downto 0) := x"0A02A8C0");
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
      cassetteScl : inout slv(3 downto 0) := (others => 'Z');
      cassetteSda : inout slv(3 downto 0) := (others => 'Z');

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
      red   : out slv(1 downto 0) := (others => '1');
      blue  : out slv(1 downto 0) := (others => '1');
      green : out slv(1 downto 0) := (others => '1'));
end DesyTracker;

architecture rtl of DesyTracker is


   constant NUM_AXIL_MASTERS_C : integer              := 11;
   constant AXIL_VERSION_C     : integer              := 0;
   constant AXIL_KPIX_DAQ_C    : integer              := 1;
--   constant AXIL_CASSETTE_I2C_0_C : integer := 2;
--   constant AXIL_CASSETTE_I2C_1_C : integer := 3;   
   constant AXIL_ETH_CORE_C    : integer              := 2;
   constant AXIL_XADC_C        : integer              := 3;
   constant AXIL_PWR_C         : integer              := 4;
   constant AXIL_BOOT_C        : integer              := 5;
   constant AXIL_TLU_MON_C     : integer              := 6;
   constant AXIL_CAS_I2C_C     : integerArray(0 to 3) := (7, 8, 9, 10);
   constant AXIL_CAS_I2C_0_C : integer := 7;
   constant AXIL_CAS_I2C_1_C : integer := 8;
   constant AXIL_CAS_I2C_2_C : integer := 9;
   constant AXIL_CAS_I2C_3_C : integer := 10;   

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      AXIL_VERSION_C    => (
         baseAddr       => X"00000000",
         addrBits       => 12,
         connectivity   => X"FFFF"),
      AXIL_KPIX_DAQ_C   => (
         baseAddr       => X"01000000",
         addrBits       => 24,
         connectivity   => X"FFFF"),
      AXIL_ETH_CORE_C   => (
         baseAddr       => X"02000000",
         addrBits       => 10,
         connectivity   => X"FFFF"),
      AXIL_XADC_C       => (
         baseAddr       => X"03000000",
         addrBits       => 12,
         connectivity   => X"FFFF"),
      AXIL_PWR_C        => (
         baseAddr       => X"04000000",
         addrBits       => 16,
         connectivity   => X"FFFF"),
      AXIL_BOOT_C       => (
         baseAddr       => X"05000000",
         addrBits       => 12,
         connectivity   => X"FFFF"),
      AXIL_TLU_MON_C    => (
         baseAddr       => X"06000000",
         addrBits       => 8,
         connectivity   => X"FFFF"),
      AXIL_CAS_I2C_0_C => (
         baseAddr       => X"07000000",
         addrBits       => 12,
         connectivity   => X"FFFF"),
      AXIL_CAS_I2C_1_C => (
         baseAddr       => X"07001000",
         addrBits       => 12,
         connectivity   => X"FFFF"),
      AXIL_CAS_I2C_2_C => (
         baseAddr       => X"07002000",
         addrBits       => 12,
         connectivity   => X"FFFF"),
      AXIL_CAS_I2C_3_C => (
         baseAddr       => X"07003000",
         addrBits       => 12,
         connectivity   => X"FFFF"));

   signal ethClk200 : sl;
   signal ethRst200 : sl;

   signal kpixClk200 : sl;
   signal kpixRst200 : sl;

   signal axilClk : sl;
   signal axilRst : sl;

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

   signal ebAxisMaster : AxiStreamMasterType;
   signal ebAxisSlave  : AxiStreamSlaveType;
   signal ebAxisCtrl   : AxiStreamCtrlType;

   signal ethAcqCmd   : sl;
   signal ethStartCmd : sl;

   signal tluClkClean : sl;
   signal tluClk      : sl;
   signal tluSpill    : sl;
   signal tluStart    : sl;
   signal tluTrigger  : sl;
   signal tluBusy     : sl;


   signal extTriggers : slv(7 downto 0);
   signal debugOutA   : sl;
   signal debugOutB   : sl;

   signal busy : sl;

   signal kpixResetOut   : sl;
   signal kpixClkOut     : sl;
   signal kpixTriggerOut : sl;
   signal kpixSerTxOut   : slv(23 downto 0);
   signal kpixSerRxIn    : slv(23 downto 0);

   signal rssiStatus : slv(6 downto 0);
   signal phyReady   : sl;

   signal refClk    : sl;
   signal pllLocked : sl;
   signal heartbeat : sl;

   signal bootSck : sl;

begin

   -------------------------------------------------------------------------------------------------
   -- Buffers for TLU signals
   -------------------------------------------------------------------------------------------------
   TLU_CLK_IBUF : IBUFGDS_DIFF_OUT
      port map (
         I  => tluClkP,
         IB => tluClkN,
         OB => tluClk);

   TLU_SPILL_IBUF : IBUFDS_DIFF_OUT
      port map (
         I  => tluSpillP,
         IB => tluSpillN,
         OB => tluSpill);

   TLU_START_IBUF : IBUFDS_DIFF_OUT
      port map (
         I  => tluStartP,
         IB => tluStartN,
         OB => tluStart);

   TLU_TRIGGER_IBUF : IBUFDS_DIFF_OUT
      port map (
         I  => tluTriggerP,
         IB => tluTriggerN,
         OB => tluTrigger);

   TLU_BUSY_OBUF : OBUFDS
      port map (
         I  => tluBusy,
         O  => tluBusyP,
         OB => tluBusyN);

   tluBusy <= '0';

   -------------------------------------------------------------------------------------------------
   -- Clock heartbeats and LED statuses
   -------------------------------------------------------------------------------------------------
   -- kpixClk200
   Heartbeat_kpixClk200 : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 5.0E-9,
         PERIOD_OUT_G => 0.5)
      port map (
         clk => kpixClk200,
         o   => heartbeat);

   led(0) <= heartbeat;


   Heartbeat_refClk : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 6.40E-9,
         PERIOD_OUT_G => 0.64)
      port map (
         clk => refClk,
         o   => led(1));


   Heartbeat_tluClk : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 25.0E-9,
         PERIOD_OUT_G => 2.5)
      port map (
         clk => tluClkClean,
         o   => led(2));

   Heartbeat_axilClk : entity work.Heartbeat
      generic map (
         TPD_G        => TPD_G,
         PERIOD_IN_G  => 8.0E-9,
         PERIOD_OUT_G => 0.8)
      port map (
         clk => axilClk,
         o   => led(3));

   green(0) <= not rssiStatus(0);
   red(0)   <= rssiStatus(0);

   green(1) <= not phyReady;
   red(1)   <= phyReady;

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
   extTriggers(6) <= ethAcqCmd;
   extTriggers(7) <= ethStartCmd;

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
         refClkOut        => refClk,                                -- [out]
         axilClk          => axilClk,                               -- [out]
         axilRst          => axilRst,                               -- [out]
         mAxilReadMaster  => axilReadMaster,                        -- [out]
         mAxilReadSlave   => axilReadSlave,                         -- [in]
         mAxilWriteMaster => axilWriteMaster,                       -- [out]
         mAxilWriteSlave  => axilWriteSlave,                        -- [in]
         sAxilReadMaster  => locAxilReadMasters(AXIL_ETH_CORE_C),   -- [in]
         sAxilReadSlave   => locAxilReadSlaves(AXIL_ETH_CORE_C),    -- [out]
         sAxilWriteMaster => locAxilWriteMasters(AXIL_ETH_CORE_C),  -- [in]
         sAxilWriteSlave  => locAxilWriteSlaves(AXIL_ETH_CORE_C),   -- [out]
         phyReady         => phyReady,                              -- [out]
         rssiStatus       => rssiStatus,                            -- [out]
         ethClk200        => ethClk200,                             -- [out]
         ethRst200        => ethRst200,                             -- [out]
         kpixClk200       => kpixClk200,                            -- [in]
         kpixRst200       => kpixRst200,                            -- [in]
         ebAxisMaster     => ebAxisMaster,                          -- [in]
         ebAxisSlave      => ebAxisSlave,                           -- [out]
         ebAxisCtrl       => ebAxisCtrl,                            -- [out]
         acqCmd           => ethAcqCmd,                             -- [out]
         startCmd         => ethStartCmd,                           -- [out]
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
   U_AxiVersion_1 : entity work.AxiVersion
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_PERIOD_G    => 8.0e-9,
         XIL_DEVICE_G    => "7SERIES",
         EN_DEVICE_DNA_G => true,
         EN_DS2411_G     => false,
         EN_ICAP_G       => true)
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
   U_AxiLiteAsync_1 : entity work.AxiLiteAsync
      generic map (
         TPD_G => TPD_G)
      port map (
         sAxiClk         => axilClk,                               -- [in]
         sAxiClkRst      => axilRst,                               -- [in]
         sAxiReadMaster  => locAxilReadMasters(AXIL_KPIX_DAQ_C),   -- [in]
         sAxiReadSlave   => locAxilReadSlaves(AXIL_KPIX_DAQ_C),    -- [out]
         sAxiWriteMaster => locAxilWriteMasters(AXIL_KPIX_DAQ_C),  -- [in]
         sAxiWriteSlave  => locAxilWriteSlaves(AXIL_KPIX_DAQ_C),   -- [out]
         mAxiClk         => kpixClk200,                            -- [in]
         mAxiClkRst      => kpixRst200,                            -- [in]
         mAxiReadMaster  => kpixDaqAxilReadMaster,                 -- [out]
         mAxiReadSlave   => kpixDaqAxilReadSlave,                  -- [in]
         mAxiWriteMaster => kpixDaqAxilWriteMaster,                -- [out]
         mAxiWriteSlave  => kpixDaqAxilWriteSlave);                -- [in]

   -------------------------------------------------------------------------------------------------
   -- Main KPIX DAQ Core
   -------------------------------------------------------------------------------------------------
   U_KpixDaqCore_1 : entity work.KpixDaqCore
      generic map (
         TPD_G              => TPD_G,
         AXIL_BASE_ADDR_G   => AXIL_XBAR_CONFIG_C(AXIL_KPIX_DAQ_C).baseAddr,
         NUM_KPIX_MODULES_G => 24)
      port map (
         clk200          => kpixClk200,              -- [in]
         rst200          => kpixRst200,              -- [in]
         axilReadMaster  => kpixDaqAxilReadMaster,   -- [in]
         axilReadSlave   => kpixDaqAxilReadSlave,    -- [out]
         axilWriteMaster => kpixDaqAxilWriteMaster,  -- [in]
         axilWriteSlave  => kpixDaqAxilWriteSlave,   -- [out]
         ebAxisMaster    => ebAxisMaster,            -- [out]
         ebAxisSlave     => ebAxisSlave,             -- [in]
         ebAxisCtrl      => ebAxisCtrl,              -- [in]
         extTriggers     => extTriggers,             -- [in]
         debugOutA       => debugOutA,               -- [out]
         debugOutB       => debugOutB,               -- [out]
         busy            => busy,                    --[out]
         kpixClkOut      => kpixClkOut,              -- [out]
         kpixTriggerOut  => kpixTriggerOut,          -- [out]
         kpixResetOut    => kpixResetOut,            -- [out]
         kpixSerTxOut    => kpixSerTxOut,            -- [out]
         kpixSerRxIn     => kpixSerRxIn);            -- [in]

--    U_ClkOutBufSingle_1 : entity work.ClkOutBufSingle
--       generic map (
--          TPD_G => TPD_G)
--       port map (
--          clkIn  => heartbeat,           -- [in]
--          clkOut => bncDebug);           -- [out]

--    bncBusy <= busy;
   bncDebug <= '0';
   bncBusy <= '0';


   -------------------------------------------------------------------------------------------------
   -- XADC
   -- Need to use ethClk on xadcClk and COMMON_CLK_G=false because DRP can't run at 200 MHz
   -------------------------------------------------------------------------------------------------
   U_XadcSimpleCore_1 : entity work.XadcSimpleCore
      generic map (
         TPD_G                    => TPD_G,
         COMMON_CLK_G             => true,
         SEQUENCER_MODE_G         => "CONTINUOUS",
         SAMPLING_MODE_G          => "CONTINUOUS",
         MUX_EN_G                 => false,
         ADCCLK_RATIO_G           => 5,
         SAMPLE_AVG_G             => "00",
         COEF_AVG_EN_G            => true,
         OVERTEMP_AUTO_SHDN_G     => true,
         OVERTEMP_ALM_EN_G        => true,
         OVERTEMP_LIMIT_G         => 80.0,
         OVERTEMP_RESET_G         => 30.0,
         TEMP_ALM_EN_G            => false,
         TEMP_UPPER_G             => 70.0,
         TEMP_LOWER_G             => 0.0,
         VCCINT_ALM_EN_G          => false,
         VCCAUX_ALM_EN_G          => false,
         VCCBRAM_ALM_EN_G         => false,
         ADC_OFFSET_CORR_EN_G     => false,
         ADC_GAIN_CORR_EN_G       => true,
         SUPPLY_OFFSET_CORR_EN_G  => false,
         SUPPLY_GAIN_CORR_EN_G    => true,
         SEQ_XADC_CAL_SEL_EN_G    => false,
         SEQ_TEMPERATURE_SEL_EN_G => true,
         SEQ_VCCINT_SEL_EN_G      => true,
         SEQ_VCCAUX_SEL_EN_G      => true,
         SEQ_VCCBRAM_SEL_EN_G     => true,
         SEQ_VAUX_SEL_EN_G        => (others => false))        -- All AUX voltages on
      port map (
         axilClk         => axilClk,                           -- [in]
         axilRst         => axilRst,                           -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_XADC_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_XADC_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_XADC_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_XADC_C),   -- [out]
         xadcClk         => axilClk,                           -- [in]
         xadcRst         => axilClk,                           -- [in]
         alm             => open,                              -- [out]
         ot              => open);                             -- [out]

   -------------------------------------------------------------------------------------------------
   -- Board temperature
   -------------------------------------------------------------------------------------------------
   U_AxiI2cRegMaster_1 : entity work.AxiI2cRegMaster
      generic map (
         TPD_G            => TPD_G,
         DEVICE_MAP_G     => (
            0             => MakeI2cAxiLiteDevType(
               i2cAddress => "1101111",
               dataSize   => 8,
               addrSize   => 8,
               endianness => '1'),
            1             => MakeI2cAxiLiteDevType(
               i2cAddress => "1001000",
               dataSize   => 8,
               addrSize   => 8,
               endianness => '1')),
         I2C_SCL_FREQ_G   => 100.0E+3,
         I2C_MIN_PULSE_G  => 100.0E-9,
         AXI_CLK_FREQ_G   => 125.0E+6)
      port map (
         axiClk         => axilClk,                          -- [in]
         axiRst         => axilRst,                          -- [in]
         axiReadMaster  => locAxilReadMasters(AXIL_PWR_C),   -- [in]
         axiReadSlave   => locAxilReadSlaves(AXIL_PWR_C),    -- [out]
         axiWriteMaster => locAxilWriteMasters(AXIL_PWR_C),  -- [in]
         axiWriteSlave  => locAxilWriteSlaves(AXIL_PWR_C),   -- [out]
         scl            => pwrScl,                           -- [inout]
         sda            => pwrSda);                          -- [inout]

   ----------------------
   -- AXI-Lite: Boot Prom
   ----------------------
   U_SpiProm : entity work.AxiMicronN25QCore
      generic map (
         TPD_G          => TPD_G,
         AXI_CLK_FREQ_G => 125.0E+6,
         SPI_CLK_FREQ_G => (125.0E+6/12.0))
      port map (
         -- FLASH Memory Ports
         csL            => bootCsL,
         sck            => bootSck,
         mosi           => bootMosi,
         miso           => bootMiso,
         -- AXI-Lite Register Interface
         axiReadMaster  => locAxilReadMasters(AXIL_BOOT_C),
         axiReadSlave   => locAxilReadSlaves(AXIL_BOOT_C),
         axiWriteMaster => locAxilWriteMasters(AXIL_BOOT_C),
         axiWriteSlave  => locAxilWriteSlaves(AXIL_BOOT_C),
         -- Clocks and Resets
         axiClk         => axilClk,
         axiRst         => axilRst);

   -----------------------------------------------------
   -- Using the STARTUPE2 to access the FPGA's CCLK port
   -----------------------------------------------------
   U_STARTUPE2 : STARTUPE2
      port map (
         CFGCLK    => open,             -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,             -- 1-bit output: PROGRAM request to fabric output
         CLK       => '0',              -- 1-bit input: User start-up clock input
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',              -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => bootSck,          -- 1-bit input: User CCLK input
         USRCCLKTS => '0',              -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => '1',              -- 1-bit input: User DONE pin output control
         USRDONETS => '1');             -- 1-bit input: User DONE 3-state enable output   

   ---------------------------------------
   -- TLU MON
   ---------------------------------------
   U_TluMonitor_1 : entity work.TluMonitor
      generic map (
         TPD_G => TPD_G)
      port map (
         axilClk         => axilClk,                              -- [in]
         axilRst         => axilRst,                              -- [in]
         axilReadMaster  => locAxilReadMasters(AXIL_TLU_MON_C),   -- [in]
         axilReadSlave   => locAxilReadSlaves(AXIL_TLU_MON_C),    -- [out]
         axilWriteMaster => locAxilWriteMasters(AXIL_TLU_MON_C),  -- [in]
         axilWriteSlave  => locAxilWriteSlaves(AXIL_TLU_MON_C),   -- [out]
         ethClk200       => ethClk200,                            -- [in]
         ethRst200       => ethRst200,                            -- [in]
         tluClk          => tluClk,                               -- [in]
         tluTrigger      => tluTrigger,                           -- [in]
         tluStart        => tluStart,                             -- [in]
         tluSpill        => tluSpill,                             -- [in]
         tluClkClean     => tluClkClean,                          -- [out]
         kpixClk200      => kpixClk200,                           -- [out]
         kpixRst200      => kpixRst200);                          -- [out]


   ----------------------------------------
   -- Cassette I2C
   ----------------------------------------
   CASSETTE_I2C_GEN : for i in 3 downto 0 generate
      U_AxiI2cRegMaster_2 : entity work.AxiI2cRegMaster
         generic map (
            TPD_G            => TPD_G,
            DEVICE_MAP_G     => (
               0             => MakeI2cAxiLiteDevType(
                  i2cAddress => "1000000",
                  dataSize   => 16,
                  addrSize   => 8,
                  endianness => '1')),
            I2C_SCL_FREQ_G   => 100.0E+3,
            I2C_MIN_PULSE_G  => 100.0E-9,
            AXI_CLK_FREQ_G   => 125.0E+6)
         port map (
            axiClk         => axilClk,                                 -- [in]
            axiRst         => axilRst,                                 -- [in]
            axiReadMaster  => locAxilReadMasters(AXIL_CAS_I2C_C(i)),   -- [in]
            axiReadSlave   => locAxilReadSlaves(AXIL_CAS_I2C_C(i)),    -- [out]
            axiWriteMaster => locAxilWriteMasters(AXIL_CAS_I2C_C(i)),  -- [in]
            axiWriteSlave  => locAxilWriteSlaves(AXIL_CAS_I2C_C(i)),   -- [out]
            scl            => cassetteScl(i),                          -- [inout]
            sda            => cassetteSda(i));                         -- [inout]
   end generate CASSETTE_I2C_GEN;

end architecture rtl;
