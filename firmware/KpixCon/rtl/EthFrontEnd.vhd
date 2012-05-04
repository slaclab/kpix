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

LIBRARY ieee;
LIBRARY unisim;
use work.all;
use work.EthClientPackage.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use unisim.vcomponents.all;

entity EthFrontEnd is 
   port ( 
     
      -- System clock, reset & control
      gtpClk           : in  std_logic;
      gtpClkRst        : in  std_logic;
      gtpRefClk        : in  std_logic;
      gtpRefClkOut     : out std_logic;

      -- Local command signal
      cmdEn            : out std_logic;
      cmdOpCode        : out std_logic_vector(7  downto 0);

      -- Local register control signals
      regReq           : out std_logic;
      regOp            : out std_logic;
      regInp           : out std_logic;
      regAck           : in  std_logic;
      regFail          : in  std_logic;
      regAddr          : out std_logic_vector(23 downto 0);
      regDataOut       : out std_logic_vector(31 downto 0);
      regDataIn        : in  std_logic_vector(31 downto 0);

      -- Local data transfer signals
      frameTxEnable    : in  std_logic;
      frameTxSOF       : in  std_logic;
      frameTxEOF       : in  std_logic;
      frameTxAfull     : out std_logic;
      frameTxData      : in  std_logic_vector(31 downto 0);

      -- GTP Signals
      gtpRxN           : in  std_logic;
      gtpRxP           : in  std_logic;
      gtpTxN           : out std_logic;
      gtpTxP           : out std_logic
   );
end EthFrontEnd;


-- Define architecture
architecture EthFrontEnd of EthFrontEnd is

   -- Buffer
   component UsBuff 
      port ( 
         sysClk           : in  std_logic;
         sysClkRst        : in  std_logic;
         frameTxValid     : in  std_logic;
         frameTxSOF       : in  std_logic;
         frameTxEOF       : in  std_logic;
         frameTxEOFE      : in  std_logic;
         frameTxData      : in  std_logic_vector(31 downto 0);
         frameTxAFull     : out std_logic;
         vcFrameTxValid   : out std_logic;
         vcFrameTxReady   : in  std_logic;
         vcFrameTxSOF     : out std_logic;
         vcFrameTxEOF     : out std_logic;
         vcFrameTxEOFE    : out std_logic;
         vcFrameTxData    : out std_logic_vector(15 downto 0);
         vcRemBuffAFull   : in  std_logic;
         vcRemBuffFull    : in  std_logic
      );
   end component;

   -- Local Signals
   signal vc0FrameTxValid   : std_logic;
   signal vc0FrameTxReady   : std_logic;
   signal vc0FrameTxSOF     : std_logic;
   signal vc0FrameTxEOF     : std_logic;
   signal vc0FrameTxData    : std_logic_vector(15 downto 0);
   signal vc1FrameTxValid   : std_logic;
   signal vc1FrameTxReady   : std_logic;
   signal vc1FrameTxSOF     : std_logic;
   signal vc1FrameTxEOF     : std_logic;
   signal vc1FrameTxData    : std_logic_vector(15 downto 0);
   signal vcFrameRxSOF      : std_logic;
   signal vcFrameRxEOF      : std_logic;
   signal vcFrameRxEOFE     : std_logic;
   signal vcFrameRxData     : std_logic_vector(15 downto 0);
   signal vc0FrameRxValid   : std_logic;
   signal vc1FrameRxValid   : std_logic;
   signal udpTxValid        : std_logic;
   signal udpTxFast         : std_logic;
   signal udpTxFastOut      : std_logic;
   signal udpTxReady        : std_logic;
   signal udpTxData         : std_logic_vector(7  downto 0);
   signal udpTxLength       : std_logic_vector(15 downto 0);
   signal udpRxValid        : std_logic;
   signal udpRxData         : std_logic_vector(7 downto 0);
   signal udpRxGood         : std_logic;
   signal udpRxError        : std_logic;
   signal udpRxCount        : std_logic_vector(15 downto 0);
   signal userTxValid       : std_logic;
   signal userTxReady       : std_logic;
   signal userTxData        : std_logic_vector(15 downto 0);
   signal userTxSOF         : std_logic;
   signal userTxEOF         : std_logic;
   signal userTxVc          : std_logic_vector(1  downto 0);
   signal userRxValid       : std_logic;
   signal userRxData        : std_logic_vector(15 downto 0);
   signal userRxSOF         : std_logic;
   signal userRxEOF         : std_logic;
   signal userRxEOFE        : std_logic;
   signal userRxVc          : std_logic_vector(1  downto 0);
   signal swapRegDataIn     : std_logic_vector(31 downto 0);
   signal ipAddr            : IPAddrType;
   signal macAddr           : MacAddrType;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Ethernet block
   U_EthClientGtp: EthClientGtp 
      generic map (
         UdpPort => 8192
      ) port map (
         gtpClk       => gtpClk,
         gtpClkOut    => gtpRefClkOut,
         gtpClkRef    => gtpRefClk,
         gtpClkRst    => gtpClkRst,
         ipAddr       => ipAddr,
         macAddr      => macAddr,
         udpTxValid   => udpTxValid,
         udpTxFast    => '0',
         udpTxReady   => udpTxReady,
         udpTxData    => udpTxData,
         udpTxLength  => udpTxLength,
         udpRxValid   => udpRxValid,
         udpRxData    => udpRxData,
         udpRxGood    => udpRxGood,
         udpRxError   => udpRxError,
         udpRxCount   => udpRxCount,
         gtpRxN       => gtpRxN,
         gtpRxP       => gtpRxP,
         gtpTxN       => gtpTxN,
         gtpTxP       => gtpTxP
      );

   -- Ethernet framer
   U_EthFrame : EthUdpFrame 
      port map ( 
         gtpClk       => gtpClk,
         gtpClkRst    => gtpClkRst,
         userTxValid  => userTxValid,
         userTxReady  => userTxReady,
         userTxData   => userTxData,
         userTxSOF    => userTxSOF,
         userTxEOF    => userTxEOF,
         userTxVc     => userTxVc,
         userRxValid  => userRxValid,
         userRxData   => userRxData,
         userRxSOF    => userRxSOF,
         userRxEOF    => userRxEOF,
         userRxEOFE   => userRxEOFE,
         userRxVc     => userRxVc,
         udpTxValid   => udpTxValid,
         udpTxFast    => open,
         udpTxJumbo   => '1',
         udpTxReady   => udpTxReady,
         udpTxData    => udpTxData,
         udpTxLength  => udpTxLength,
         udpRxValid   => udpRxValid,
         udpRxData    => udpRxData,
         udpRxGood    => udpRxGood,
         udpRxError   => udpRxError,
         udpRxCount   => udpRxCount
      );

   -- Demux
   vcFrameRxSOF      <= userRxSOF;
   vcFrameRxEOF      <= userRxEOF;
   vcFrameRxEOFE     <= userRxEOFE;
   vcFrameRxData     <= userRxData;
   vc0FrameRxValid   <= userRxValid when userRxVc = 0 else '0';
   vc1FrameRxValid   <= userRxValid when userRxVc = 1 else '0';

   -- Arbiter
   U_EthArb: EthArbiter 
      port map ( 
         gtpClk         => gtpClk,
         gtpClkRst      => gtpClkRst,
         userTxValid    => userTxValid,
         userTxReady    => userTxReady,
         userTxData     => userTxData,
         userTxSOF      => userTxSOF,
         userTxEOF      => userTxEOF,
         userTxVc       => userTxVc,
         user0TxValid   => vc0FrameTxValid,
         user0TxReady   => vc0FrameTxReady,
         user0TxData    => vc0FrameTxData,
         user0TxSOF     => vc0FrameTxSOF,
         user0TxEOF     => vc0FrameTxEOF,
         user1TxValid   => vc1FrameTxValid,
         user1TxReady   => vc1FrameTxReady,
         user1TxData    => vc1FrameTxData,
         user1TxSOF     => vc1FrameTxSOF,
         user1TxEOF     => vc1FrameTxEOF,
         user2TxValid   => '0',
         user2TxReady   => open,
         user2TxData    => (others=>'0'),
         user2TxSOF     => '0',
         user2TxEOF     => '0',
         user3TxValid   => '0',
         user3TxReady   => open,
         user3TxData    => (others=>'0'),
         user3TxSOF     => '0',
         user3TxEOF     => '0'
      );

   -- Lane 0, VC0, External command processor
   U_ExtCmd: EthCmdSlave 
      generic map ( 
         DestId    => 0,
         DestMask  => 1,
         FifoType  => "V5"
      ) port map ( 
         pgpRxClk       => gtpClk,           pgpRxReset     => gtpClkRst,
         locClk         => gtpClk,           locReset       => gtpClkRst,
         vcFrameRxValid => vc0FrameRxValid,  vcFrameRxSOF   => vcFrameRxSOF,
         vcFrameRxEOF   => vcFrameRxEOF,     vcFrameRxEOFE  => vcFrameRxEOFE,
         vcFrameRxData  => vcFrameRxData,    vcLocBuffAFull => open,
         vcLocBuffFull  => open,             cmdEn          => cmdEn,
         cmdOpCode      => cmdOpCode,        cmdCtxOut      => open
      );

   -- Return data, Lane 0, VC0
   U_DataBuff0: UsBuff port map ( 
      sysClk           => gtpClk,
      sysClkRst        => gtpClkRst,
      frameTxValid     => frameTxEnable,
      frameTxSOF       => frameTxSOF,
      frameTxEOF       => frameTxEOF,
      frameTxEOFE      => '0',
      frameTxData      => frameTxData,
      frameTxAFull     => frameTxAfull,
      vcFrameTxValid   => vc0FrameTxValid,
      vcFrameTxReady   => vc0FrameTxReady,
      vcFrameTxSOF     => vc0FrameTxSOF,
      vcFrameTxEOF     => vc0FrameTxEOF,
      vcFrameTxEOFE    => open,
      vcFrameTxData    => vc0FrameTxData,
      vcRemBuffAFull   => '0',
      vcRemBuffFull    => '0'
   );

   -- Lane 0, VC1, External register access control
   U_ExtReg: EthRegSlave generic map ( FifoType => "V5" ) port map (
      pgpRxClk        => gtpClk,           pgpRxReset      => gtpClkRst,
      pgpTxClk        => gtpClk,           pgpTxReset      => gtpClkRst,
      locClk          => gtpClk,           locReset        => gtpClkRst,
      vcFrameRxValid  => vc1FrameRxValid,  vcFrameRxSOF    => vcFrameRxSOF,
      vcFrameRxEOF    => vcFrameRxEOF,     vcFrameRxEOFE   => vcFrameRxEOFE,
      vcFrameRxData   => vcFrameRxData,    vcLocBuffAFull  => open,
      vcLocBuffFull   => open,             vcFrameTxValid  => vc1FrameTxValid,
      vcFrameTxReady  => vc1FrameTxReady,  vcFrameTxSOF    => vc1FrameTxSOF,
      vcFrameTxEOF    => vc1FrameTxEOF,    vcFrameTxEOFE   => open,
      vcFrameTxData   => vc1FrameTxData,   vcRemBuffAFull  => '0',
      vcRemBuffFull   => '0',              regInp          => regInp,
      regReq          => regReq,           regOp           => regOp,
      regAck          => regAck,           regFail         => regFail,
      regAddr         => regAddr,          regDataOut      => regDataOut,
      regDataIn       => swapRegDataIn
   );

   swapRegDataIn(15 downto  0) <= regDataIn(31 downto 16);
   swapRegDataIn(31 downto 16) <= regDataIn(15 downto  0);

   -- IP Address
   ipAddr(3) <= x"c0"; -- 192
   ipAddr(2) <= x"A8"; -- 168
   ipAddr(1) <= x"01"; -- 1
   ipAddr(0) <= x"10"; -- 16

   -- MAC Address
   macAddr(0) <= x"00";
   macAddr(1) <= x"44";
   macAddr(2) <= x"56";
   macAddr(3) <= x"00";
   macAddr(4) <= x"03";
   macAddr(5) <= x"01";

end EthFrontEnd;

