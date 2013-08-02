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
-- Copyright (c) 2012 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/03/2012: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.VcPkg.all;
use work.EthClientPackage.all;

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

      -- Special 200 MHz clock for commands
      clk200 : in sl;
      rst200 : in sl;

      -- Local command signal
      cmdSlaveOut : out VcCmdSlaveOutType;

      -- Local register control signals
      regSlaveIn  : in  VcRegSlaveInType;
      regSlaveOut : out VcRegSlaveOutType;

      -- Local data transfer signals
      usBuff64In  : in  VcUsBuff64InType;
      usBuff64Out : out VcUsBuff64OutType);
end EthFrontEnd;


-- Define architecture
architecture EthFrontEnd of EthFrontEnd is

   signal vcTx0In  : VcTxInType;
   signal vcTx0Out : VcTxOutType;

   signal vcTx1In  : VcTxInType;
   signal vcTx1Out : VcTxOutType;

   signal vcRxCommonOut : VcRxCommonOutType;
   signal vcRx0Out      : VcRxOutType;
   signal vcRx1Out      : VcRxOutType;

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

begin

   -- Ethernet block
   U_EthClientGtp : entity work.EthClientGtp
      generic map (
         UdpPort => 8192
         ) port map (
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
            gtpTxP      => gtpTxP
            );

   -- Ethernet framer
   U_EthFrame : entity work.EthUdpFrame
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
         udpRxCount  => udpRxCount
         );

   -- Demux
   vcRxCommonOut.sof     <= userRxSOF;
   vcRxCommonOut.eof     <= userRxEOF;
   vcRxCommonOut.eofe    <= userRxEOFE;
   vcRxCommonOut.data(0) <= userRxData;
   vcRxCommonOut.data(1) <= (others => '0');
   vcRxCommonOut.data(2) <= (others => '0');
   vcRxCommonOut.data(3) <= (others => '0');
   vcRx0Out.valid        <= userRxValid when userRxVc = "00" else '0';
   vcRx1Out.valid        <= userRxValid when userRxVc = "01" else '0';
   vcRx0Out.remBuffAFull <= '0';        -- EthClient doesn't drive these
   vcRx0Out.remBuffFull  <= '0';        -- EthClient doesn't drive these
   vcRx1Out.remBuffAFull <= '0';
   vcRx1Out.remBuffFull  <= '0';

   -- Arbiter
   U_EthArb : entity work.EthArbiter
      port map (
         gtpClk       => gtpClk,
         gtpClkRst    => gtpClkRst,
         userTxValid  => userTxValid,
         userTxReady  => userTxReady,
         userTxData   => userTxData,
         userTxSOF    => userTxSOF,
         userTxEOF    => userTxEOF,
         userTxVc     => userTxVc,
         user0TxValid => vcTx0In.valid,
         user0TxReady => vcTx0Out.ready,
         user0TxData  => vcTx0In.data(0),
         user0TxSOF   => vcTx0In.sof,
         user0TxEOF   => vcTx0In.eof,
         user1TxValid => vcTx1In.valid,
         user1TxReady => vcTx1Out.ready,
         user1TxData  => vcTx1In.data(0),
         user1TxSOF   => vcTx1In.sof,
         user1TxEOF   => vcTx1In.eof,
         user2TxValid => '0',
         user2TxReady => open,
         user2TxData  => (others => '0'),
         user2TxSOF   => '0',
         user2TxEOF   => '0',
         user3TxValid => '0',
         user3TxReady => open,
         user3TxData  => (others => '0'),
         user3TxSOF   => '0',
         user3TxEOF   => '0'
         );


   -- VC0 RX, External command processor
   VcCmdSlave_1 : entity work.VcCmdSlave
      generic map (
         TPD_G           => TPD_G,
         RX_LANE_G       => 0,
         DEST_ID_G       => 0,
         DEST_MASK_G     => 1,
         GEN_SYNC_FIFO_G => false,
         BRAM_EN_G       => true,
         ETH_MODE_G      => true)
      port map (
         vcRxOut             => vcRx0Out,
         vcRxCommonOut       => vcRxCommonOut,
         vcTxIn_locBuffAFull => vcTx0In.locBuffAFull,
         vcTxIn_locBuffFull  => vcTx0In.locBuffFull,
         cmdSlaveOut         => cmdSlaveOut,
         locClk              => clk200,
--         locAsyncRst         => rst200,
         locSyncRst => rst200,
         vcRxClk             => gtpClk,
--         vcRxAsyncRst        => gtpClkRst);
         vcRxSyncRst => gtpClkRst);

   -- VC0 Tx, Return data
   VcUsBuff64Kpix_1 : entity work.VcUsBuff64Kpix
      generic map (
         TPD_G             => TPD_G,
         GEN_SYNC_FIFO_G   => true,
         BRAM_EN_G         => true,
         FIFO_ADDR_WIDTH_G => 10)
      port map (
         vcTxIn               => vcTx0In,
         vcTxOut              => vcTx0Out,
         vcRxOut_remBuffAFull => vcRx0Out.remBuffAFull,
         vcRxOut_remBuffFull  => vcRx0Out.remBuffFull,
         usBuff64In           => usBuff64In,
         usBuff64Out          => usBuff64Out,
         locClk               => gtpClk,
--         locAsyncRst          => gtpClkRst,
         locSyncRst => gtpClkRst,
         vcTxClk              => gtpClk,
--         vcTxAsyncRst         => gtpClkRst);
         vcTxSyncRst => gtpClkRst);

   -- VC1, Register Slave
   VcRegSlave_1 : entity work.VcRegSlave
      generic map (
         RX_LANE_G      => 0,
         SYNC_RX_FIFO_G => true,
         BRAM_EN_RX_G   => true,
         TX_LANE_G      => 0,
         SYNC_TX_FIFO_G => true,
         BRAM_EN_TX_G   => true,
         TPD_G          => TPD_G,
         ETH_MODE_G      => true)
      port map (
         vcRxOut       => vcRx1Out,
         vcRxCommonOut => vcRxCommonOut,
         vcTxIn        => vcTx1In,
         vcTxOut       => vcTx1Out,
         regSlaveIn    => regSlaveIn,
         regSlaveOut   => regSlaveOut,
         locClk        => gtpClk,
--         locAsyncRst   => gtpClkRst,
         locSyncRst => gtpClkRst,
         vcTxClk       => gtpClk,
--         vcTxAsyncRst  => gtpClkRst,
         vcTxSyncRst => gtpClkRst,
         vcRxClk       => gtpClk,
--         vcRxAsyncRst  => gtpClkRst);
         vcRxSyncRst => gtpClkRst);

end EthFrontEnd;

