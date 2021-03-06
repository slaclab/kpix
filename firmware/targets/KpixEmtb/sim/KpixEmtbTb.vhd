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

entity KpixEmtbTb is end KpixEmtbTb;

architecture KpixEmtbTb of KpixEmtbTb is

  -- Internal signals
  signal fpgaRstL     : std_logic;
  signal gtpRefClkP   : std_logic;
  signal gtpRefClkN   : std_logic;
  signal evrClkP      : std_logic;
  signal evrClkN      : std_logic;
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
      CLK_PERIOD_G      => 4.2 ns,
      CLK_DELAY_G       => 0 ns)
    port map (
      clkP => evrClkP,
      clkN => evrClkN,
      rst  => open,
      rstL => open);

  -- FPGA
  U_KpixEmtb : entity KpixEmtb
    port map (
    fpgaRstL        => fpgaRstL,
    pgpRefClkP      => gtpRefClkP,
    pgpRefClkN      => gtpRefClkN,
    pgpTxP          => open,
    pgpTxN          => open,
    pgpRxP          => '0',
    pgpRxN          => '0',
    evrClkP         => evrClkP,
    evrClkN         => evrClkN,
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


end KpixEmtbTb;

