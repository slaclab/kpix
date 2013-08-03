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

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.VcPkg.all;
use work.Pgp2CoreTypesPkg.all;

entity Pgp2FrontEnd is
   generic (
      TPD_G : time := 1 ns);
   port (

      -- Reference Clock, PGP Clock & Reset Signals
      pgpRefClk    : in  std_logic;
      pgpRefClkOut : out std_logic;
      pgpClk       : in  std_logic;
      pgpClk2x     : in  std_logic;
      pgpReset     : in  std_logic;

      -- MGT Serial Pins
      gtpRxN : in  std_logic;
      gtpRxP : in  std_logic;
      gtpTxN : out std_logic;
      gtpTxP : out std_logic;

      -- Special 200 MHz clock for commands
      clk200 : in std_logic;
      rst200 : in std_logic;

      -- Local command signal
      cmdSlaveOut : out VcCmdSlaveOutType;

      -- Local register control signals
      regSlaveIn  : in  VcRegSlaveInType;
      regSlaveOut : out VcRegSlaveOutType;

      -- Local data transfer signals
      usBuff64In  : in  VcUsBuff64InType;
      usBuff64Out : out VcUsBuff64OutType);

end Pgp2FrontEnd;


-- Define architecture
architecture PgpFrontEnd of Pgp2FrontEnd is

   signal pgpRxIn  : PgpRxInType;
   signal pgpRxOut : PgpRxOutType;

   signal pgpTxIn  : PgpTxInType;
   signal pgpTxOut : PgpTxOutType;

   signal vcTxQuadIn  : VcTxQuadInType;
   signal vcTxQuadOut : VcTxQuadOutType;

   signal vcRxCommonOut : VcRxCommonOutType;
   signal vcRxQuadOut   : VcRxQuadOutType;

   signal pgpRxRecClk    : sl;
   signal pgpRxRecClkRst : sl;
   
begin

   pgpRxIn <= (flush   => '0',
               resetRx => '0');
   pgpTxIn <= (flush        => '0',
               opCodeEn     => '0',
               opCode       => (others => '0'),
               locLinkReady => '0',
               locData      => (others => '0'));

   -- Use fixed latency version of Pgp2 because I'm too lazy to make a wrapper for Pgp2Gtp16, and
   -- this module isn't currently being used anyway.
   Pgp2Gtp16FixedLat_1 : entity work.Pgp2Gtp16FixedLat
      generic map (
         TPD_G        => TPD_G,
         EnShortCells => 1,
         VcInterleave => 0)
      port map (
         pgpReset         => pgpReset,
         pgpTxClk         => pgpClk,
         pgpTxClk2x       => pgpClk2x,
         pgpRxRecClk      => pgpRxRecClk,
         pgpRxRecClk2x    => open,
         pgpRxRecClkRst   => pgpRxRecClkRst,
         pgpRxIn          => pgpRxIn,
         pgpRxOut         => pgpRxOut,
         pgpTxIn          => pgpTxIn,
         pgpTxOut         => pgpTxOut,
         pgpVcTxQuadIn    => vcTxQuadIn,
         pgpVcTxQuadOut   => vcTxQuadOut,
         pgpVcRxCommonOut => vcRxCommonOut,
         pgpVcRxQuadOut   => vcRxQuadOut,
         gtpLoopback      => '0',
         gtpClkIn         => pgpRefClk,
         gtpRefClkOut     => pgpRefClkOut,
         gtpRxN           => gtpRxN,
         gtpRxP           => gtpRxP,
         gtpTxN           => gtpTxN,
         gtpTxP           => gtpTxP,
         debug            => open);


   -- VC0 RX, External command processor
   VcCmdSlave_1 : entity work.VcCmdSlave
      generic map (
         TPD_G           => TPD_G,
         RST_ASYNC_G     => false,
         RX_LANE_G       => 0,
         DEST_ID_G       => 0,
         DEST_MASK_G     => 1,
         GEN_SYNC_FIFO_G => false,
         BRAM_EN_G       => true,
         ETH_MODE_G      => true)
      port map (
         vcRxOut             => vcRxQuadOut(0),
         vcRxCommonOut       => vcRxCommonOut,
         vcTxIn_locBuffAFull => vcTxQuadIn(0).locBuffAFull,
         vcTxIn_locBuffFull  => vcTxQuadIn(0).locBuffFull,
         cmdSlaveOut         => cmdSlaveOut,
         locClk              => clk200,
         locRst              => rst200,
         vcRxClk             => pgpRxRecClk,
         vcRxRst             => pgpRxRecClkRst);

   -- VC0 Tx, Return data
   VcUsBuff64Kpix_1 : entity work.VcUsBuff64Kpix
      generic map (
         TPD_G             => TPD_G,
         RST_ASYNC_G       => false,
         GEN_SYNC_FIFO_G   => true,
         BRAM_EN_G         => true,
         FIFO_ADDR_WIDTH_G => 10)
      port map (
         vcTxIn               => vcTxQuadIn(0),
         vcTxOut              => vcTxQuadOut(0),
         vcRxOut_remBuffAFull => vcRxQuadOut(0).remBuffAFull,
         vcRxOut_remBuffFull  => vcRxQuadOut(0).remBuffFull,
         usBuff64In           => usBuff64In,
         usBuff64Out          => usBuff64Out,
         locClk               => pgpClk,
         locRst               => pgpReset,
         vcTxClk              => pgpClk,
         vcTxRst              => pgpReset);

   -- VC1, Register Slave
   VcRegSlave_1 : entity work.VcRegSlave
      generic map (
         RX_LANE_G      => 0,
         RST_ASYNC_G    => false,
         SYNC_RX_FIFO_G => true,
         BRAM_EN_RX_G   => true,
         TX_LANE_G      => 0,
         SYNC_TX_FIFO_G => true,
         BRAM_EN_TX_G   => true,
         TPD_G          => TPD_G,
         ETH_MODE_G     => true)
      port map (
         vcRxOut       => vcRxQuadOut(1),
         vcRxCommonOut => vcRxCommonOut,
         vcTxIn        => vcTxQuadIn(1),
         vcTxOut       => vcTxQuadOut(1),
         regSlaveIn    => regSlaveIn,
         regSlaveOut   => regSlaveOut,
         locClk        => pgpClk,
         locRst        => pgpReset,
         vcTxClk       => pgpClk,
         vcTxRst       => pgpReset,
         vcRxClk       => pgpRxRecClk,
         vcRxRst       => pgpRxRecClkRst);


end PgpFrontEnd;

