-------------------------------------------------------------------------------
-- Title         : Ethernet Front End Support
-- Project       : W_SI
-------------------------------------------------------------------------------
-- File          : EthFrontEnd.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/03/2012
-------------------------------------------------------------------------------
-- Description:
-- Wrapper for front end logic connection.
-------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/03/2012: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library v5_eth_core;
use v5_eth_core.EthClientPackage.all;

library kpix;
use kpix.KpixPkg.all;

entity EthFrontEnd is
   generic (
      TPD_G      : time        := 1 ns;
      IP_ADDR_G  : IPAddrType  := (X"C0", X"A8", X"01", X"10");  -- 192.168.1.16
      MAC_ADDR_G : MacAddrType := (X"00", X"44", X"56", X"00", X"03", X"01"));
   port (
      -- System clock, reset & control
      gtpClk       : in  sl;
      gtpClkRst    : in  sl;
      gtpRefClk    : in  sl;
      gtpRefClkOut : out sl;

      -- GTP Signals
      gtpRxN : in  sl;
      gtpRxP : in  sl;
      gtpTxN : out sl;
      gtpTxP : out sl;

      -- Master bus out
      axilClk          : in  sl;
      axilRst          : in  sl;
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- Kpix 200 MHz reference
      clk200 : in sl;
      rst200 : in sl;

      -- Event builder stream (kpixClk200 domain)
      ebAxisMaster : in  AxiStreamMasterType;
      ebAxisSlave  : out AxiStreamSlaveType;
      ebAxisCtrl   : out AxiStreamCtrlType;

      acqCmd   : out sl;
      startCmd : out sl);
end EthFrontEnd;


-- Define architecture
architecture rtl of EthFrontEnd is

   constant AXIS_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(2);


   -- Ethernet signals (Should cleanup Eth Client someday)
   signal udpTxValid   : sl;
   signal udpTxFast    : sl;
   signal udpTxFastOut : sl;
   signal udpTxReady   : sl;
   signal udpTxData    : slv(7 downto 0);
   signal udpTxLength  : slv(15 downto 0);
   signal udpRxValid   : sl;
   signal udpRxData    : slv(7 downto 0);
   signal udpRxGood    : sl;
   signal udpRxError   : sl;
   signal udpRxCount   : slv(15 downto 0);
   signal userTxValid  : sl;
   signal userTxReady  : sl;
   signal userTxData   : slv(15 downto 0);
   signal userTxSOF    : sl;
   signal userTxEOF    : sl;
   signal userTxVc     : slv(1 downto 0);
   signal userRxValid  : sl;
   signal userRxData   : slv(15 downto 0);
   signal userRxSOF    : sl;
   signal userRxEOF    : sl;
   signal userRxEOFE   : sl;
   signal userRxVc     : slv(1 downto 0);
   signal user0TxValid : sl;
   signal user0TxReady : sl;
   signal user0TxData  : slv(15 downto 0);
   signal user0TxSOF   : sl;
   signal user0TxEOF   : sl;
   signal user1TxValid : sl;
   signal user1TxReady : sl;
   signal user1TxData  : slv(15 downto 0);
   signal user1TxSOF   : sl;
   signal user1TxEOF   : sl;

   -- Axi Stream
   signal srpTxAxisMaster : AxiStreamMasterType;
   signal srpTxAxisSlave  : AxiStreamSlaveType;
   signal srpRxAxisMaster : AxiStreamMasterType;
   signal srpRxAxisSlave  : AxiStreamSlaveType;
   signal srpRxAxisCtrl   : AxiStreamCtrlType;

   signal dataTxAxisMaster : AxiStreamMasterType;
   signal dataTxAxisSlave  : AxiStreamSlaveType;
   signal dataRxAxisMaster : AxiStreamMasterType;
   signal dataRxAxisSlave  : AxiStreamSlaveType;
   signal dataRxAxisCtrl   : AxiStreamCtrlType;

   signal acqReqValid      : sl;
   signal startReqValid    : sl;
   signal acqReqValidReg   : sl;
   signal startReqValidReg : sl;
   signal ethCmd           : sl;
   signal cmdValid         : sl;
   signal acqCmdTmp        : sl;
   signal startCmdTmp      : sl;


begin

   -- Ethernet block
   U_EthClientGtp : entity v5_eth_core.EthClientGtp
      generic map (
         UdpPort => 8192)
      port map (
         gtpClk      => gtpClk,
         gtpClkOut   => gtpRefClkOut,
         gtpClkRef   => gtpRefClk,
         gtpClkRst   => gtpClkRst,
         ipAddr      => IP_ADDR_G,
         macAddr     => MAC_ADDR_G,
         udpTxValid  => udpTxValid,
         udpTxFast   => '0',
         udpTxReady  => udpTxReady,
         udpTxData   => udpTxData,
         udpTxLength => udpTxLength,
         udpRxValid  => udpRxValid,
         udpRxData   => udpRxData,
         udpRxGood   => udpRxGood,
         udpRxError  => udpRxError,
         udpRxCount  => udpRxCount,
         gtpRxN      => gtpRxN,
         gtpRxP      => gtpRxP,
         gtpTxN      => gtpTxN,
         gtpTxP      => gtpTxP);

   -- Ethernet framer
   U_EthFrame : entity v5_eth_core.EthUdpFrame
      port map (
         gtpClk      => gtpClk,
         gtpClkRst   => gtpClkRst,
         userTxValid => userTxValid,
         userTxReady => userTxReady,
         userTxData  => userTxData,
         userTxSOF   => userTxSOF,
         userTxEOF   => userTxEOF,
         userTxVc    => userTxVc,
         userRxValid => userRxValid,
         userRxData  => userRxData,
         userRxSOF   => userRxSOF,
         userRxEOF   => userRxEOF,
         userRxEOFE  => userRxEOFE,
         userRxVc    => userRxVc,
         udpTxValid  => udpTxValid,
         udpTxFast   => open,
         udpTxJumbo  => '0',
         udpTxReady  => udpTxReady,
         udpTxData   => udpTxData,
         udpTxLength => udpTxLength,
         udpRxValid  => udpRxValid,
         udpRxData   => udpRxData,
         udpRxGood   => udpRxGood,
         udpRxError  => udpRxError,
         udpRxCount  => udpRxCount);

   -- Demux
--    vcRxCommonOut.sof     <= userRxSOF;
--    vcRxCommonOut.eof     <= userRxEOF;
--    vcRxCommonOut.eofe    <= userRxEOFE;
--    vcRxCommonOut.data(0) <= userRxData;
--    vcRxCommonOut.data(1) <= (others => '0');
--    vcRxCommonOut.data(2) <= (others => '0');
--    vcRxCommonOut.data(3) <= (others => '0');
--    vcRx0Out.valid        <= userRxValid when userRxVc = "00" else '0';
--    vcRx1Out.valid        <= userRxValid when userRxVc = "01" else '0';
--    vcRx0Out.remBuffAFull <= '0';        -- EthClient doesn't drive these
--    vcRx0Out.remBuffFull  <= '0';        -- EthClient doesn't drive these
--    vcRx1Out.remBuffAFull <= '0';
--    vcRx1Out.remBuffFull  <= '0';

   -- Arbiter
   U_EthArb : entity v5_eth_core.EthArbiter
      port map (
         gtpClk       => gtpClk,
         gtpClkRst    => gtpClkRst,
         userTxValid  => userTxValid,
         userTxReady  => userTxReady,
         userTxData   => userTxData,
         userTxSOF    => userTxSOF,
         userTxEOF    => userTxEOF,
         userTxVc     => userTxVc,
         user0TxValid => user0TxValid,
         user0TxReady => user0TxReady,
         user0TxData  => user0TxData,
         user0TxSOF   => user0TxSOF,
         user0TxEOF   => user0TxEOF,
         user1TxValid => user1TxValid,
         user1TxReady => user1TxReady,
         user1TxData  => user1TxData,
         user1TxSOF   => user1TxSOF,
         user1TxEOF   => user1TxEOF,
         user2TxValid => '0',
         user2TxReady => open,
         user2TxData  => (others => '0'),
         user2TxSOF   => '0',
         user2TxEOF   => '0',
         user3TxValid => '0',
         user3TxReady => open,
         user3TxData  => (others => '0'),
         user3TxSOF   => '0',
         user3TxEOF   => '0');

   -- Translate to AxiStream
   user0TxValid   <= srpTxAxisMaster.tValid;
   user0TxData    <= srpTxAxisMaster.tData(15 downto 0);
   user0TxEOF     <= srpTxAxisMaster.tLast;
   user0TxSOF     <= srpTxAxisMaster.tUser(1);
   srpTxAxisSlave <= (tready => user0TxReady);

   srpRxAxisMaster.tValid             <= userRxValid when userRxVc = "00" else '0';
   srpRxAxisMaster.tData(15 downto 0) <= userRxData;
   srpRxAxisMaster.tLast              <= userRxEOF;
   srpRxAxisMaster.tUser(1)           <= userRxSOF;
   srpRxAxisMaster.tUser(0)           <= userRxEOFE;

   user1TxValid    <= dataTxAxisMaster.tValid;
   user1TxData     <= dataTxAxisMaster.tData(15 downto 0);
   user1TxEOF      <= dataTxAxisMaster.tLast;
   user1TxSOF      <= dataTxAxisMaster.tUser(1);
   dataTxAxisSlave <= (tReady => user1TxReady);

   dataRxAxisMaster.tValid             <= userRxValid when userRxVc = "01" else '0';
   dataRxAxisMaster.tData(15 downto 0) <= userRxData;
   dataRxAxisMaster.tLast              <= userRxEOF;
   dataRxAxisMaster.tUser(1)           <= userRxSOF;
   dataRxAxisMaster.tUser(0)           <= userRxEOFE;

   U_SRPv3 : entity surf.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => false,
         GEN_SYNC_FIFO_G     => false,
         AXIL_CLK_FREQ_G     => 125.0e6,
         AXI_STREAM_CONFIG_G => AXIS_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => gtpClk,
         sAxisRst         => gtpClkRst,
         sAxisMaster      => srpRxAxisMaster,
         sAxisSlave       => srpRxAxisSlave,
         sAxisCtrl        => srpRxAxisCtrl,
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => gtpClk,
         mAxisRst         => gtpClkRst,
         mAxisMaster      => srpTxAxisMaster,
         mAxisSlave       => srpTxAxisSlave,
         -- AXI Lite Bus (axilClk domain)
         axilClk          => clk200,
         axilRst          => rst200,
         mAxilReadMaster  => mAxilReadMaster,
         mAxilReadSlave   => mAxilReadSlave,
         mAxilWriteMaster => mAxilWriteMaster,
         mAxilWriteSlave  => mAxilWriteSlave);

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
         sAxisClk    => clk200,            -- [in]
         sAxisRst    => rst200,            -- [in]
         sAxisMaster => ebAxisMaster,      -- [in]
         sAxisSlave  => ebAxisSlave,       -- [out]
         sAxisCtrl   => ebAxisCtrl,        -- [out]
         mAxisClk    => gtpClk,            -- [in]
         mAxisRst    => gtpClkRst,         -- [in]
         mAxisMaster => dataTxAxisMaster,  -- [out]
         mAxisSlave  => dataTxAxisSlave);  -- [in]

   dataRxAxisSlave <= AXI_STREAM_SLAVE_FORCE_C;  -- always ready

   acqReqValid <= dataRxAxisMaster.tValid and toSl(dataRxAxisMaster.tData(7 downto 0) = X"AA") and
                  dataRxAxisMaster.tLast;

   startReqValid <= dataRxAxisMaster.tValid and toSl(dataRxAxisMaster.tData(7 downto 0) = X"55") and
                    dataRxAxisMaster.tLast;

   U_RegisterVector_1 : entity surf.RegisterVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         clk      => gtpClk,             -- [in]
         rst      => gtpClkRst,          -- [in]
         sig_i(0) => acqReqValid,        -- [in]
         sig_i(1) => startReqValid,      -- [in]
         reg_o(0) => acqReqValidReg,     -- [out]
         reg_o(1) => startReqValidReg);  -- [out]

   U_SynchronizerOneShot_ACQUIRE : entity surf.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk200,             -- [in]
         rst     => rst200,             -- [in]
         dataIn  => acqReqValidReg,     -- [in]
         dataOut => acqCmd);            -- [out]

   U_SynchronizerOneShot_START : entity surf.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk200,             -- [in]
         rst     => rst200,             -- [in]
         dataIn  => startReqValidReg,   -- [in]
         dataOut => startCmd);          -- [out]

end rtl;

