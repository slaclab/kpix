-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixClockGen.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2013-07-15
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
      clk200     : in  sl;
      rst200     : in  sl;
      triggerOut : in  TriggerOutType;
      extRegsIn  : in  KpixClockGenRegsInType;
      kpixState  : in  KpixStateOutType;
      kpixClk    : out sl;
      kpixClkRst : out sl);

end entity KpixClockGen;

architecture rtl of KpixClockGen is

   -- Kpix Clock registers run on 200 MHz clock
   type RegType is record
      startAcquireLast : sl;
      extRegsSync      : KpixClockGenRegsInType;
      divCount         : unsigned(11 downto 0);
      clkSel           : unsigned(11 downto 0);
      clkDiv           : sl;
   end record RegType;

   signal r, rin       : RegType;
   signal newValueRise : sl;
   signal kpixClkInt   : sl;

begin

   
   SynchronizerEdge_NewValue : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1',
         STAGES_G       => 3,
         INIT_G         => "000")
      port map (
         clk         => clk200,
         aRst        => rst200,
         dataIn      => extRegsIn.newValue,
         dataOut     => open,
         risingEdge  => newValueRise,
         fallingEdge => open);

   seq : process (clk200, rst200) is
   begin
      if (rst200 = '1') then
         r.startAcquireLast            <= '0'                         after DELAY_G;
         r.extRegsSync.clkSelReadout   <= CLK_SEL_READOUT_DEFAULT_C   after DELAY_G;
         r.extRegsSync.clkSelDigitize  <= CLK_SEL_DIGITIZE_DEFAULT_C  after DELAY_G;
         r.extRegsSync.clkSelAcquire   <= CLK_SEL_ACQUIRE_DEFAULT_C   after DELAY_G;
         r.extRegsSync.clkSelIdle      <= CLK_SEL_IDLE_DEFAULT_C      after DELAY_G;
         r.extRegsSync.clkSelPrecharge <= CLK_SEL_PRECHARGE_DEFAULT_C after DELAY_G;
         r.extRegsSync.newValue        <= '0'                         after DELAY_G;
         r.divCount                    <= (others => '0')             after DELAY_G;
         r.clkSel                      <= (others => '0')             after DELAY_G;
         r.clkDiv                      <= '0'                         after DELAY_G;
      elsif (rising_edge(clk200)) then
         r <= rin after DELAY_G;
      end if;
   end process seq;


   comb : process (r, kpixState, extRegsIn, newValueRise, triggerOut) is
      variable rVar : RegType;
   begin
      rVar := r;

      rVar.startAcquireLast := triggerOut.startAcquire;

      -- When new reg values are stable, clock them into their 200 MHz registers
      if (newValueRise = '1') then
         rVar.extRegsSync := extRegsIn;
      end if;

      rVar.divCount := r.divCount + 1;

      if (r.divCount = r.clkSel) then
         -- Invert clock every time divCount reaches clkSel
         rVar.divCount := (others => '0');
         rVar.clkDiv   := not r.clkDiv;

         -- Assign new clkSel dependant on kpixState
         if (kpixState.analogState = KPIX_ANALOG_DIG_STATE_C and kpixState.prechargeBus = '1') then
            rVar.clkSel := unsigned(r.extRegsSync.clkSelPrecharge);
         elsif (kpixState.analogState = KPIX_ANALOG_IDLE_STATE_C) then
            rVar.clkSel := "0000" & unsigned(r.extRegsSync.clkSelIdle);
         elsif (kpixState.analogState = KPIX_ANALOG_PRE_STATE_C or
                kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C or
                kpixState.analogState = KPIX_ANALOG_PAUSE_STATE_C) then
            rVar.clkSel := "0000" & unsigned(r.extRegsSync.clkSelAcquire);
         elsif (kpixState.analogState = KPIX_ANALOG_DIG_STATE_C) then
            rVar.clkSel := "0000" & unsigned(r.extRegsSync.clkSelDigitize);
         elsif (kpixState.readoutState /= KPIX_READOUT_IDLE_STATE_C) then
            rVar.clkSel := "0000" & unsigned(r.extRegsSync.clkSelReadout);
         else
            rVar.clkSel := "0000" & unsigned(r.extRegsSync.clkSelIdle);
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
