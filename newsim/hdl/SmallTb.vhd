LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.StdRtlPkg.all;
use work.KpixPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;

entity SmallTb is end SmallTb;

architecture SmallTb of SmallTb is

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

   -- Reset generation
   process 
   begin
      fpgaRstL <= '1';
      wait for (8 ns);
      fpgaRstL <= '0';
      wait for (8 ns * 20);
      fpgaRstL <= '1';
      wait;
   end process;

   -- 125Mhz clock
   process 
   begin
      gtpRefClkP <= '0';
      gtpRefClkN <= '1';
      wait for (4 ns);
      gtpRefClkP <= '1';
      gtpRefClkN <= '0';
      wait for (4 ns);
   end process;

   -- FPGA
   U_KpixSmall : entity KpixSmall port map (
       fpgaRstL        => fpgaRstL,
       gtpRefClkP      => gtpRefClkP,
       gtpRefClkN      => gtpRefClkN,
       udpTxP          => open,
       udpTxN          => open,
       udpRxP          => '0',
       udpRxN          => '0',
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
   U_AsicSim : entity AsicSim port map ( 
      sysclk    => kpixClkOutP,
      reset     => kpixRstOut,
      command   => kpixSerTxOut(0),
      data_out  => kpixSerRxIn(0)
   );

end SmallTb;

