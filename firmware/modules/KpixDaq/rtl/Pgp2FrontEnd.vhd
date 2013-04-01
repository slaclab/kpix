-------------------------------------------------------------------------------
-- Title         : Pretty Good Protocol Applications, Front End Wrapper
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : PgpFrontEnd.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/29/2011
-------------------------------------------------------------------------------
-- Description:
-- Wrapper for front end logic connection to the PGP card.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/29/2011: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use work.Version.all;
--use work.Pgp2GtpPackage.all;
--use work.Pgp2AppPackage.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Pgp2FrontEnd is 
   port ( 
      
      -- Reference Clock, PGP Clock & Reset Signals
      pgpRefClk        : in  std_logic;
      pgpRefClkOut     : out std_logic;
      pgpClk           : in  std_logic;
      pgpClk2x         : in  std_logic;
      pgpReset         : in  std_logic;

      -- Local clock and reset - 125Mhz
      locClk           : in  std_logic;
      locReset         : in  std_logic;

      -- Local command signal
      cmdEn            : out std_logic;
      cmdOpCode        : out std_logic_vector(7  downto 0);
      cmdCtxOut        : out std_logic_vector(23 downto 0);

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
      frameTxEnable   : in  std_logic;
      frameTxSOF      : in  std_logic;
      frameTxEOF      : in  std_logic;
      frameTxEOFE     : in  std_logic;
      frameTxData     : in  std_logic_vector(63 downto 0);
      frameTxAFull    : out std_logic;

      -- MGT Serial Pins
      pgpRxN          : in  std_logic;
      pgpRxP          : in  std_logic;
      pgpTxN          : out std_logic;
      pgpTxP          : out std_logic
   );
end Pgp2FrontEnd;


-- Define architecture
architecture PgpFrontEnd of Pgp2FrontEnd is

   -- Local Signals
   signal vc00FrameTxValid   : std_logic;
   signal vc00FrameTxReady   : std_logic;
   signal vc00FrameTxSOF     : std_logic;
   signal vc00FrameTxEOF     : std_logic;
   signal vc00FrameTxEOFE    : std_logic;
   signal vc00FrameTxData    : std_logic_vector(15 downto 0);
   signal vc00RemBuffAFull   : std_logic;
   signal vc00RemBuffFull    : std_logic;
   signal vc01FrameTxValid   : std_logic;
   signal vc01FrameTxReady   : std_logic;
   signal vc01FrameTxSOF     : std_logic;
   signal vc01FrameTxEOF     : std_logic;
   signal vc01FrameTxEOFE    : std_logic;
   signal vc01FrameTxData    : std_logic_vector(15 downto 0);
   signal vc01RemBuffAFull   : std_logic;
   signal vc01RemBuffFull    : std_logic;
   signal vc02FrameTxValid   : std_logic;
   signal vc02FrameTxReady   : std_logic;
   signal vc02FrameTxSOF     : std_logic;
   signal vc02FrameTxEOF     : std_logic;
   signal vc02FrameTxEOFE    : std_logic;
   signal vc02FrameTxData    : std_logic_vector(15 downto 0);
   signal vc02RemBuffAFull   : std_logic;
   signal vc02RemBuffFull    : std_logic;
   signal vc03FrameTxValid   : std_logic;
   signal vc03FrameTxReady   : std_logic;
   signal vc03FrameTxSOF     : std_logic;
   signal vc03FrameTxEOF     : std_logic;
   signal vc03FrameTxEOFE    : std_logic;
   signal vc03FrameTxData    : std_logic_vector(15 downto 0);
   signal vc03RemBuffAFull   : std_logic;
   signal vc03RemBuffFull    : std_logic;
   signal vc0FrameRxSOF      : std_logic;
   signal vc0FrameRxEOF      : std_logic;
   signal vc0FrameRxEOFE     : std_logic;
   signal vc0FrameRxData     : std_logic_vector(15 downto 0);
   signal vc00FrameRxValid   : std_logic;
   signal vc00LocBuffAFull   : std_logic;
   signal vc00LocBuffFull    : std_logic;
   signal vc01FrameRxValid   : std_logic;
   signal vc01LocBuffAFull   : std_logic;
   signal vc01LocBuffFull    : std_logic;
   signal vc02FrameRxValid   : std_logic;
   signal vc02LocBuffAFull   : std_logic;
   signal vc02LocBuffFull    : std_logic;
   signal vc03FrameRxValid   : std_logic;
   signal vc03LocBuffAFull   : std_logic;
   signal vc03LocBuffFull    : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- PGP Wrap
   U_Pgp2Gtp16: entity work.Pgp2Gtp16
      generic map ( 
         EnShortCells => 1, 
         VcInterleave => 0
      )
      port map (
         pgpClk            => pgpClk,
         pgpClk2x          => pgpClk2x,
         pgpReset          => pgpReset,
         pgpFlush          => '0',
         pllTxRst          => '0',
         pllRxRst          => '0',
         pllRxReady        => open,
         pllTxReady        => open,
         pgpRemData        => open,
         pgpLocData        => (others=>'0'),
         pgpTxOpCodeEn     => '0',
         pgpTxOpCode       => (others=>'0'),
         pgpRxOpCodeEn     => open,
         pgpRxOpCode       => open,
         pgpLocLinkReady   => open,
         pgpRemLinkReady   => open,
         pgpRxCellError    => open,
         pgpRxLinkDown     => open,
         pgpRxLinkError    => open,
         vc0FrameTxValid   => vc00FrameTxValid,
         vc0FrameTxReady   => vc00FrameTxReady,
         vc0FrameTxSOF     => vc00FrameTxSOF,
         vc0FrameTxEOF     => vc00FrameTxEOF,
         vc0FrameTxEOFE    => vc00FrameTxEOFE,
         vc0FrameTxData    => vc00FrameTxData,
         vc0LocBuffAFull   => vc00LocBuffAFull,
         vc0LocBuffFull    => vc00LocBuffFull,
         vc1FrameTxValid   => vc01FrameTxValid,
         vc1FrameTxReady   => vc01FrameTxReady,
         vc1FrameTxSOF     => vc01FrameTxSOF,
         vc1FrameTxEOF     => vc01FrameTxEOF,
         vc1FrameTxEOFE    => vc01FrameTxEOFE,
         vc1FrameTxData    => vc01FrameTxData,
         vc1LocBuffAFull   => vc01LocBuffAFull,
         vc1LocBuffFull    => vc01LocBuffFull,
         vc2FrameTxValid   => vc02FrameTxValid,
         vc2FrameTxReady   => vc02FrameTxReady,
         vc2FrameTxSOF     => vc02FrameTxSOF,
         vc2FrameTxEOF     => vc02FrameTxEOF,
         vc2FrameTxEOFE    => vc02FrameTxEOFE,
         vc2FrameTxData    => vc02FrameTxData,
         vc2LocBuffAFull   => vc02LocBuffAFull,
         vc2LocBuffFull    => vc02LocBuffFull,
         vc3FrameTxValid   => vc03FrameTxValid,
         vc3FrameTxReady   => vc03FrameTxReady,
         vc3FrameTxSOF     => vc03FrameTxSOF,
         vc3FrameTxEOF     => vc03FrameTxEOF,
         vc3FrameTxEOFE    => vc03FrameTxEOFE,
         vc3FrameTxData    => vc03FrameTxData,
         vc3LocBuffAFull   => vc03LocBuffAFull,
         vc3LocBuffFull    => vc03LocBuffFull,
         vcFrameRxSOF      => vc0FrameRxSOF,
         vcFrameRxEOF      => vc0FrameRxEOF,
         vcFrameRxEOFE     => vc0FrameRxEOFE,
         vcFrameRxData     => vc0FrameRxData,
         vc0FrameRxValid   => vc00FrameRxValid,
         vc0RemBuffAFull   => vc00RemBuffAFull,
         vc0RemBuffFull    => vc00RemBuffFull,
         vc1FrameRxValid   => vc01FrameRxValid,
         vc1RemBuffAFull   => vc01RemBuffAFull,
         vc1RemBuffFull    => vc01RemBuffFull,
         vc2FrameRxValid   => vc02FrameRxValid,
         vc2RemBuffAFull   => vc02RemBuffAFull,
         vc2RemBuffFull    => vc02RemBuffFull,
         vc3FrameRxValid   => vc03FrameRxValid,
         vc3RemBuffAFull   => vc03RemBuffAFull,
         vc3RemBuffFull    => vc03RemBuffFull,
         gtpLoopback       => '0',
         gtpClkIn          => pgpRefClk,
         gtpRefClkOut      => pgpRefClkOut,
         gtpRxRecClk       => open,
         gtpRxN            => pgpRxN,
         gtpRxP            => pgpRxP,
         gtpTxN            => pgpTxN,
         gtpTxP            => pgpTxP,
         debug             => open
      );


   -- Lane 0, VC0, External command processor
   U_ExtCmd: entity work.Pgp2CmdSlave 
      generic map ( 
         DestId    => 0,
         DestMask  => 1,
         FifoType  => "V5"
      ) port map ( 
         pgpRxClk       => pgpClk,           pgpRxReset     => pgpReset,
         locClk         => locClk,           locReset       => locReset,
         vcFrameRxValid => vc00FrameRxValid, vcFrameRxSOF   => vc0FrameRxSOF,
         vcFrameRxEOF   => vc0FrameRxEOF,    vcFrameRxEOFE  => vc0FrameRxEOFE,
         vcFrameRxData  => vc0FrameRxData,   vcLocBuffAFull => vc00LocBuffAFull,
         vcLocBuffFull  => vc00LocBuffFull,  cmdEn          => cmdEn,
         cmdOpCode      => cmdOpCode,        cmdCtxOut      => cmdCtxOut
      );


   -- Return data, Lane 0, VC0
   U_DataBuff0: entity work.Pgp2UsBuff64
     port map ( 
      pgpClk           => pgpClk,
      pgpReset         => pgpReset,
      locClk           => locClk,
      locReset         => locReset,
      frameTxValid     => frameTxEnable,
      frameTxSOF       => frameTxSOF,
      frameTxEOF       => frameTxEOF,
      frameTxEOFE      => frameTxEOFE,
      frameTxData      => frameTxData,
      frameTxAFull     => frameTxAFull,
      vcFrameTxValid   => vc00FrameTxValid,
      vcFrameTxReady   => vc00FrameTxReady,
      vcFrameTxSOF     => vc00FrameTxSOF,
      vcFrameTxEOF     => vc00FrameTxEOF,
      vcFrameTxEOFE    => vc00FrameTxEOFE,
      vcFrameTxData    => vc00FrameTxData,
      vcRemBuffAFull   => vc00RemBuffAFull,
      vcRemBuffFull    => vc00RemBuffFull
   );


   -- Lane 0, VC1, External register access control
   U_ExtReg: entity work.Pgp2RegSlave generic map ( FifoType => "V5" ) port map (
      pgpRxClk        => pgpClk,           pgpRxReset      => pgpReset,
      pgpTxClk        => pgpClk,           pgpTxReset      => pgpReset,
      locClk          => locClk,           locReset        => locReset,
      vcFrameRxValid  => vc01FrameRxValid, vcFrameRxSOF    => vc0FrameRxSOF,
      vcFrameRxEOF    => vc0FrameRxEOF,    vcFrameRxEOFE   => vc0FrameRxEOFE,
      vcFrameRxData   => vc0FrameRxData,   vcLocBuffAFull  => vc01LocBuffAFull,
      vcLocBuffFull   => vc01LocBuffFull,  vcFrameTxValid  => vc01FrameTxValid,
      vcFrameTxReady  => vc01FrameTxReady, vcFrameTxSOF    => vc01FrameTxSOF,
      vcFrameTxEOF    => vc01FrameTxEOF,   vcFrameTxEOFE   => vc01FrameTxEOFE,
      vcFrameTxData   => vc01FrameTxData,  vcRemBuffAFull  => vc01RemBuffAFull,
      vcRemBuffFull   => vc01RemBuffFull,  regInp          => regInp,
      regReq          => regReq,           regOp           => regOp,
      regAck          => regAck,           regFail         => regFail,
      regAddr         => regAddr,          regDataOut      => regDataOut,
      regDataIn       => regDataIn
   );

   -- Lane0-VC2 is unused
   vc02LocBuffAFull <= '0';
   vc02LocBuffFull  <= '0';
   vc02FrameTxValid <= '0';
   vc02FrameTxEOFE  <= '0';
   vc02FrameTxEOF   <= '0';
   vc02FrameTxSOF   <= '0';
   vc02FrameTxData  <= (others=>'0');

   -- Lane0-VC3 is unused
   vc03LocBuffAFull <= '0';
   vc03LocBuffFull  <= '0';
   vc03FrameTxValid <= '0';
   vc03FrameTxEOFE  <= '0';
   vc03FrameTxEOF   <= '0';
   vc03FrameTxSOF   <= '0';
   vc03FrameTxData  <= (others=>'0');

end PgpFrontEnd;

