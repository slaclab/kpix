LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.StdRtlPkg.all;
use work.KpixPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;

entity AnalogTb is end AnalogTb;

architecture AnalogTb of AnalogTb is

   -- Kpix simulation, analog
   component Kpix
      port (
         ext_clk        : in    std_logic;
         reset_c        : in    std_logic;
         trig           : in    std_logic;
         command_c      : in    std_logic;
         rdback_p       : out   std_logic
      );
   end component;

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
   U_Kpix : Kpix port map ( 
      ext_clk   => kpixClkOutP,
      reset_c   => kpixRstOut,
      trig      => '0',
      command_c => kpixSerTxOut(0),
      rdback_p  => kpixSerRxIn(0)
   );

   kpixSerRxIn(1) <= '0';
   kpixSerRxIn(2) <= '0';
   kpixSerRxIn(3) <= '0';

end AnalogTb;

