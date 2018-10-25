------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------
library ieee;
library unisim;
use work.VcPkg;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use unisim.vcomponents.all;

entity EthFrontEnd is
   generic (
      TPD_G : time := 1 ns);
   port (

      -- System clock, reset & control
      gtpClk       : in  std_logic;
      gtpClkRst    : in  std_logic;
      gtpRefClk    : in  std_logic;
      gtpRefClkOut : out std_logic;

      -- GTP Signals
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

end EthFrontEnd;


-- Define architecture
architecture EthFrontEnd of EthFrontEnd is

   -- Receiver
   component SimLinkRx port (
      rxClk           : in  std_logic;
      rxReset         : in  std_logic;
      vcFrameRxSOF    : out std_logic;
      vcFrameRxEOF    : out std_logic;
      vcFrameRxEOFE   : out std_logic;
      vcFrameRxData   : out std_logic_vector(15 downto 0);
      vc0FrameRxValid : out std_logic;
      vc0LocBuffAFull : in  std_logic;
      vc1FrameRxValid : out std_logic;
      vc1LocBuffAFull : in  std_logic;
      vc2FrameRxValid : out std_logic;
      vc2LocBuffAFull : in  std_logic;
      vc3FrameRxValid : out std_logic;
      vc3LocBuffAFull : in  std_logic;
      ethMode         : in  std_logic
      ); end component;

   -- Transmitter
   component SimLinkTx port (
      txClk           : in  std_logic;
      txReset         : in  std_logic;
      vc0FrameTxValid : in  std_logic;
      vc0FrameTxReady : out std_logic;
      vc0FrameTxSOF   : in  std_logic;
      vc0FrameTxEOF   : in  std_logic;
      vc0FrameTxEOFE  : in  std_logic;
      vc0FrameTxData  : in  std_logic_vector(15 downto 0);
      vc1FrameTxValid : in  std_logic;
      vc1FrameTxReady : out std_logic;
      vc1FrameTxSOF   : in  std_logic;
      vc1FrameTxEOF   : in  std_logic;
      vc1FrameTxEOFE  : in  std_logic;
      vc1FrameTxData  : in  std_logic_vector(15 downto 0);
      vc2FrameTxValid : in  std_logic;
      vc2FrameTxReady : out std_logic;
      vc2FrameTxSOF   : in  std_logic;
      vc2FrameTxEOF   : in  std_logic;
      vc2FrameTxEOFE  : in  std_logic;
      vc2FrameTxData  : in  std_logic_vector(15 downto 0);
      vc3FrameTxValid : in  std_logic;
      vc3FrameTxReady : out std_logic;
      vc3FrameTxSOF   : in  std_logic;
      vc3FrameTxEOF   : in  std_logic;
      vc3FrameTxEOFE  : in  std_logic;
      vc3FrameTxData  : in  std_logic_vector(15 downto 0);
      ethMode         : in  std_logic
      ); end component;

   
   signal vcTx0In  : VcTxInType;
   signal vcTx0Out : VcTxOutType;

   signal vcTx1In  : VcTxInType;
   signal vcTx1Out : VcTxOutType;

   signal vcRxCommonOut : VcRxCommonOutType;
   signal vcRx0Out      : VcRxOutType;
   signal vcRx1Out      : VcRxOutType;

   -- Local Signals
   signal vc0FrameTxValid : std_logic;
   signal vc0FrameTxReady : std_logic;
   signal vc0FrameTxSOF   : std_logic;
   signal vc0FrameTxEOF   : std_logic;
   signal vc0FrameTxData  : std_logic_vector(15 downto 0);
   signal vc1FrameTxValid : std_logic;
   signal vc1FrameTxReady : std_logic;
   signal vc1FrameTxSOF   : std_logic;
   signal vc1FrameTxEOF   : std_logic;
   signal vc1FrameTxData  : std_logic_vector(15 downto 0);
   signal vcFrameRxSOF    : std_logic;
   signal vcFrameRxEOF    : std_logic;
   signal vcFrameRxEOFE   : std_logic;
   signal vcFrameRxData   : std_logic_vector(15 downto 0);
   signal vc0FrameRxValid : std_logic;
   signal vc1FrameRxValid : std_logic;
   signal swapRegDataIn   : std_logic_vector(31 downto 0);
   signal vc0LocBuffAFull : std_logic;
   signal vc1LocBuffAFull : std_logic;

begin

   gtpRefClkOut <= gtpRefClk;
   gtpTxP       <= '0';
   gtpTxN       <= '1';

   -- Receiver
   U_SimLinkRx : SimLinkRx port map (
      rxClk           => gtpClk,
      rxReset         => gtpClkRst,
      vcFrameRxSOF    => vcRxCommonOut.sof,
      vcFrameRxEOF    => vcRxCommonOut.eof,
      vcFrameRxEOFE   => vcRxCommonOut.eofe,
      vcFrameRxData   => vcRxCommonOut.data(0),
      vc0FrameRxValid => vcRx0Out.valid,
      vc0LocBuffAFull => vcTx0In.locBuffAFull,
      vc1FrameRxValid => vcRx1Out.valid,
      vc1LocBuffAFull => vcTx0In.locBuffAFull,
      vc2FrameRxValid => open,
      vc2LocBuffAFull => '0',
      vc3FrameRxValid => open,
      vc3LocBuffAFull => '0',
      ethMode         => '1'
      );

   -- Transmitter
   U_SimLinkTx : SimLinkTx port map (
      txClk           => gtpClk,
      txReset         => gtpClkRst,
      vc0FrameTxValid => vcTx0In.valid,
      vc0FrameTxReady => vcTx0Out.ready,
      vc0FrameTxSOF   => vcTx0In.sof,
      vc0FrameTxEOF   => vcTx0In.eof,
      vc0FrameTxEOFE  => '0',
      vc0FrameTxData  => vcTx0In.data(0),
      vc1FrameTxValid => vcTx1In.valid,
      vc1FrameTxReady => vcTx1Out.ready,
      vc1FrameTxSOF   => vcTx1In.sof,
      vc1FrameTxEOF   => vcTx1In.eof,
      vc1FrameTxEOFE  => '0',
      vc1FrameTxData  => vcTx1In.data(0),
      vc2FrameTxValid => '0',
      vc2FrameTxReady => open,
      vc2FrameTxSOF   => '0',
      vc2FrameTxEOF   => '0',
      vc2FrameTxEOFE  => '0',
      vc2FrameTxData  => (others => '0'),
      vc3FrameTxValid => '0',
      vc3FrameTxReady => open,
      vc3FrameTxSOF   => '0',
      vc3FrameTxEOF   => '0',
      vc3FrameTxEOFE  => '0',
      vc3FrameTxData  => (others => '0'),
      ethMode         => '1'
      );

   vcRx0Out.remBuffAFull <= '0';
   vcRx0Out.remBuffFull  <= '0';
   vcRx1Out.remBuffAFull <= '0';
   vcRx1Out.remBuffFull  <= '0';

   -- Lane 0, VC0, External command processor
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
         vcRxOut             => vcRx0Out,
         vcRxCommonOut       => vcRxCommonOut,
         vcTxIn_locBuffAFull => vcTx0In.locBuffAFull,
         vcTxIn_locBuffFull  => vcTx0In.locBuffFull,
         cmdSlaveOut         => cmdSlaveOut,
         locClk              => clk200,
         locRst              => rst200,
         vcRxClk             => gtpClk,
         vcRxRst             => gtpClkRst);


   -- Return data, Lane 0, VC0
   VcUsBuff64Kpix_1 : entity work.VcUsBuff64Kpix
      generic map (
         TPD_G             => TPD_G,
         RST_ASYNC_G       => false,
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
         locRst               => gtpClkRst,
         vcTxClk              => gtpClk,
         vcTxRst              => gtpClkRst);

   -- Lane 0, VC1, External register access control
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
         vcRxOut                         => vcRx1Out,
         vcRxCommonOut                   => vcRxCommonOut,
         vcTxIn                          => vcTx1In,
         vcTxOut                         => vcTx1Out,
         regSlaveIn.rdData(15 downto 0)  => regSlaveIn.rdData(31 downto 16),
         regSlaveIn.rdData(31 downto 16) => regSlaveIn.rdData(15 downto 0),
         regSlaveIn.ack                  => regSlaveIn.ack,
         regSlaveIn.fail                 => regSlaveIn.fail,
         regSlaveOut                     => regSlaveOut,
         locClk                          => gtpClk,
         locRst                          => gtpClkRst,
         vcTxClk                         => gtpClk,
         vcTxRst                         => gtpClkRst,
         vcRxClk                         => gtpClk,
         vcRxRst                         => gtpClkRst);



end EthFrontEnd;

