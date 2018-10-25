------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------
LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.StdRtlPkg.all;
use work.KpixPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;

entity KpixSmallTb is end KpixSmallTb;

architecture KpixSmallTb of KpixSmallTb is

   -- Internal signals
   signal fpgaRstL      : std_logic;
   signal gtpRefClkP    : std_logic;
   signal gtpRefClkN    : std_logic;
   signal kpixSerTxOut  : std_logic_vector(3 downto 0);
   signal kpixSerRxIn   : std_logic_vector(3 downto 0);
   signal kpixClkOutP   : std_logic;
   signal kpixRstOut    : std_logic;
   signal trigIn        : TriggerExtInType;

begin

   ClkRst_1: entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 8 ns,
         CLK_DELAY_G       => 0 ns,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 500 ns,
         SYNC_RESET_G      => false)
      port map (
         clkP => gtpRefClkP,
         clkN => gtpRefClkN,
         rst  => open,
         rstL => fpgaRstL);
   
   -- FPGA
   U_KpixSmall : entity KpixSmall port map (
       fpgaRstL        => fpgaRstL,
       gtpRefClkP      => gtpRefClkP,
       gtpRefClkN      => gtpRefClkN,
       gtpTxP          => open,
       gtpTxN          => open,
       gtpRxP          => '0',
       gtpRxN          => '0',
       debugOutA       => open,
       debugOutB       => open,
       triggerExtIn    => trigIn,
       kpixClkOutP     => kpixClkOutP,
       kpixClkOutN     => open,
       kpixRstOut      => kpixRstOut,
       kpixTriggerOutP => open,
       kpixTriggerOutN => open,
       kpixSerTxOut    => kpixSerTxOut,
       kpixSerRxIn     => kpixSerRxIn
   );

   trigIn.nimA  <= '0';
   trigIn.nimB  <= '0';
   trigIn.cmosA <= '0';
   trigIn.cmosB <= '0';

   -- KPIX simulation
   KpixSim: for i in 0 to 3 generate
     U_AsicSim : entity AsicSim port map ( 
       sysclk    => kpixClkOutP,
       reset     => kpixRstOut,
       command   => kpixSerTxOut(i),
       data_out  => kpixSerRxIn(i)
   );
   end generate KpixSim;


end KpixSmallTb;

