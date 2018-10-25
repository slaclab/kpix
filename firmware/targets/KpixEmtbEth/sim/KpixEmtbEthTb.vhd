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
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.StdRtlPkg.all;
use work.KpixPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;

entity KpixEmtbEthTb is end KpixEmtbEthTb;

architecture KpixEmtbEthTb of KpixEmtbEthTb is

   -- Internal signals
   signal fpgaRstL     : std_logic;
   signal gtpRefClkP   : std_logic;
   signal gtpRefClkN   : std_logic;
   signal evrRefClkP   : std_logic;
   signal evrRefClkN   : std_logic;
   signal kpixSerTxOut : std_logic_vector(30 downto 0);
   signal kpixSerRxIn  : std_logic_vector(30 downto 0);
   signal kpixClkOutP  : std_logic_vector(3 downto 0);
   signal kpixRstOut   : std_logic;

begin

   ClkRst_1 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 8 ns,
         CLK_DELAY_G       => 0 ns,
         RST_START_DELAY_G => 8 ns,
         RST_HOLD_TIME_G   => 8 ns * 20,
         SYNC_RESET_G      => false)
      port map (
         clkP => gtpRefClkP,
         clkN => gtpRefClkN,
         rst  => open,
         rstL => fpgaRstL);

   EvrClk_1 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G => 4.202 ns,
         CLK_DELAY_G  => 0 ns)
      port map (
         clkP => evrRefClkP,
         clkN => evrRefClkN,
         rst  => open,
         rstL => open);

   -- FPGA
   U_KpixEmtbEth : entity KpixEmtbEth
      port map (
         fpgaRstL        => fpgaRstL,
         gtpRefClkP      => gtpRefClkP,
         gtpRefClkN      => gtpRefClkN,
         udpTxP          => open,
         udpTxN          => open,
         udpRxP          => '0',
         udpRxN          => '0',
         evrRefClkP      => evrRefClkP,
         evrRefClkN      => evrRefClkN,
         evrRxP          => '0',
         evrRxN          => '0',
         debugOutA       => open,
         debugOutB       => open,
         cmosIn          => '0',
         lemoIn          => '0',
         kpixClkOutP     => kpixClkOutP,
         kpixClkOutN     => open,
         kpixRstOut      => kpixRstOut,
         kpixTriggerOutP => open,
         kpixTriggerOutN => open,
         kpixSerTxOut    => kpixSerTxOut,
         kpixSerRxIn     => kpixSerRxIn
         );

   -- KPIX simulation
   KpixSim : for i in 30 downto 0 generate
      U_AsicSim : entity AsicSim port map (
         sysclk   => kpixClkOutP(i/10),
         reset    => kpixRstOut,
         command  => kpixSerTxOut(i),
         data_out => kpixSerRxIn(i)
         );
   end generate KpixSim;


end KpixEmtbEthTb;

