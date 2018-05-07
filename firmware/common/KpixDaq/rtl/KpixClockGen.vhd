-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixClockGen.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2013-08-01
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;
use work.KpixClockGenPkg.all;
use work.TriggerPkg.all;
use work.KpixLocalPkg.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity KpixClockGen is
   
   generic (
      DELAY_G : time := 1 ns);

   port (
      sysClk    : in sl;
      sysRst    : in sl;
      extRegsIn : in KpixClockGenRegsInType;  -- sysClk

      clk200     : in sl;
      rst200     : in sl;
      triggerOut : in TriggerOutType;
      kpixState  : in KpixStateOutType;

      kpixClk    : out sl;
      kpixClkRst : out sl);

end entity KpixClockGen;

architecture rtl of KpixClockGen is

   -- Kpix Clock registers run on 200 MHz clock
   type RegType is record
      startAcquireLast : sl;
      divCount         : unsigned(11 downto 0);
      clkSel           : unsigned(11 downto 0);
      clkDiv           : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      startAcquireLast => '0',
      divCount         => (others => '0'),
      clkSel           => (others => '0'),
      clkDiv           => '0');

   signal r           : RegType := REG_INIT_C;
   signal rin         : RegType;
   signal extRegsSync : KpixClockGenRegsInType;
   signal kpixClkInt  : sl;

   constant FIFO_INIT_C : slv(43 downto 0) :=
      (CLK_SEL_PRECHARGE_DEFAULT_C &
       CLK_SEL_IDLE_DEFAULT_C &
       CLK_SEL_ACQUIRE_DEFAULT_C &
       CLK_SEL_DIGITIZE_DEFAULT_C &
       CLK_SEL_READOUT_DEFAULT_C);

begin

   SynchronizerFifo_1 : entity work.SynchronizerFifo
      generic map (
         TPD_G        => DELAY_G,
         BRAM_EN_G    => false,
         DATA_WIDTH_G => 44,
         ADDR_WIDTH_G => 4,
         INIT_G       => FIFO_INIT_C)
      port map (
         rst                => sysRst,
         wr_clk             => sysClk,
         din(7 downto 0)    => extRegsIn.clkSelReadout,
         din(15 downto 8)   => extRegsIn.clkSelDigitize,
         din(23 downto 16)  => extRegsIn.clkSelAcquire,
         din(31 downto 24)  => extRegsIn.clkSelIdle,
         din(43 downto 32)  => extRegsIn.clkSelPrecharge,
         rd_clk             => clk200,
         dout(7 downto 0)   => extRegsSync.clkSelReadout,
         dout(15 downto 8)  => extRegsSync.clkSelDigitize,
         dout(23 downto 16) => extRegsSync.clkSelAcquire,
         dout(31 downto 24) => extRegsSync.clkSelIdle,
         dout(43 downto 32) => extRegsSync.clkSelPrecharge);

   seq : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         if (rst200 = '1') then
            r <= REG_INIT_C after DELAY_G;
         else
            r <= rin after DELAY_G;
         end if;
      end if;
   end process seq;


   comb : process (r, kpixState, extRegsSync, triggerOut) is
      variable rVar : RegType;
   begin
      rVar := r;

      rVar.startAcquireLast := triggerOut.startAcquire;

      rVar.divCount := r.divCount + 1;

      if (r.divCount = r.clkSel) then
         -- Invert clock every time divCount reaches clkSel
         rVar.divCount := (others => '0');
         rVar.clkDiv   := not r.clkDiv;

         -- Assign new clkSel dependant on kpixState
         if (kpixState.analogState = KPIX_ANALOG_DIG_STATE_C and kpixState.prechargeBus = '1') then
            rVar.clkSel := unsigned(extRegsSync.clkSelPrecharge);
         elsif (kpixState.analogState = KPIX_ANALOG_IDLE_STATE_C) then
            rVar.clkSel := "0000" & unsigned(extRegsSync.clkSelIdle);
         elsif (kpixState.analogState = KPIX_ANALOG_PRE_STATE_C or
                kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C or
                kpixState.analogState = KPIX_ANALOG_PAUSE_STATE_C) then
            rVar.clkSel := "0000" & unsigned(extRegsSync.clkSelAcquire);
         elsif (kpixState.analogState = KPIX_ANALOG_DIG_STATE_C) then
            rVar.clkSel := "0000" & unsigned(extRegsSync.clkSelDigitize);
         elsif (kpixState.readoutState /= KPIX_READOUT_IDLE_STATE_C) then
            rVar.clkSel := "0000" & unsigned(extRegsSync.clkSelReadout);
         else
            rVar.clkSel := "0000" & unsigned(extRegsSync.clkSelIdle);
         end if;
      end if;

      -- StartAcquire effectively resets kpix clock to ensure fixed time between acquire pulse and command
      if (triggerOut.startAcquire = '1' and r.startAcquireLast = '0') then
         rVar.divCount := (others => '0');
         rVar.clkDiv   := '0';
      end if;

      rin <= rVar;
   end process comb;

   -- Synchronize rst200 to KpixClk to create kpixClkRst
   RstSync_1 : entity work.RstSync
      generic map (
         TPD_G          => DELAY_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1')         -- Active high reset
      port map (
         clk      => kpixClkInt,
         asyncRst => rst200,
         syncRst  => kpixClkRst);

   -- Use BUFG for output
   KPIX_CLK_BUFG : BUFG
      port map (
         I => r.clkDiv,
         O => kpixClkInt);

   kpixClk <= kpixClkInt;
   
end architecture rtl;
