-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixClockGen.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2013-05-10
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
use work.SynchronizePkg.all;
use work.KpixClockGenPkg.all;
use work.KpixLocalPkg.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity KpixClockGen is
  
  generic (
    DELAY_G : time := 1 ns);

  port (
    clk200       : in  sl;
    rst200       : in  sl;
    extRegsIn    : in  KpixClockGenRegsInType;
    analogState  : in  slv(2 downto 0);
    readoutState : in  slv(2 downto 0);
    prechargeBus : in  sl;
    kpixClk      : out sl;
    kpixClkRst   : out sl);

end entity KpixClockGen;

architecture rtl of KpixClockGen is

  -- Kpix Clock registers run on 200 MHz clock
  type RegType is record
    newValueSync : SynchronizerType;
    extRegsSync  : KpixClockGenRegsInType;
    divCount     : unsigned(11 downto 0);
    clkSel       : unsigned(11 downto 0);
    clkDiv       : sl;
  end record RegType;

  signal r, rin : RegType;
  signal kpixClkInt : sl;

begin

  seq : process (clk200, rst200) is
  begin
    if (rst200 = '1') then
      r.newValueSync                <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.extRegsSync.clkSelReadout   <= (others => '0')       after DELAY_G;
      r.extRegsSync.clkSelDigitize  <= (others => '0')       after DELAY_G;
      r.extRegsSync.clkSelAcquire   <= (others => '0')       after DELAY_G;
      r.extRegsSync.clkSelIdle      <= (others => '0')       after DELAY_G;
      r.extRegsSync.clkSelPrecharge <= (others => '0')       after DELAY_G;
      r.divCount                    <= (others => '0')       after DELAY_G;
      r.clkSel                      <= (others => '0')       after DELAY_G;
      r.clkDiv                      <= '0'                   after DELAY_G;
    elsif (rising_edge(clk200)) then
      r <= rin after DELAY_G;
    end if;
  end process seq;


  comb : process (r, analogState, readoutState, prechargeBus, extRegsIn) is
    variable rVar : RegType;
  begin
    rVar := r;

    -- Sychronize newValue signal from sysClk domain
    synchronize(extRegsIn.newValue, r.newValueSync, rVar.newValueSync);

    -- When new reg values are stable, clock them into their 200 MHz registers
    if (detectRisingEdge(r.newValueSync)) then
      rVar.extRegsSync := extRegsIn;
    end if;

    rVar.divCount := r.divCount + 1;

    if (r.divCount = r.clkSel) then
      -- Invert clock every time divCount reaches clkSel
      rVar.divCount := (others => '0');
      rVar.clkDiv   := not r.clkDiv;

      -- Assign new clkSel dependant on kpixState
      if (analogState = KPIX_ANALOG_DIG_STATE_C and prechargeBus = '1') then
        rVar.clkSel := unsigned(r.extRegsSync.clkSelPrecharge);
      elsif (analogState = KPIX_ANALOG_IDLE_STATE_C) then
        rVar.clkSel := unsigned(r.extRegsSync.clkSelIdle);
      elsif (analogState = KPIX_ANALOG_PRE_STATE_C or
             analogState = KPIX_ANALOG_SAMP_STATE_C or
             analogState = KPIX_ANALOG_PAUSE_STATE_C) then
        rVar.clkSel := unsigned(r.extRegsSync.clkSelAcquire);
      elsif (analogState = KPIX_ANALOG_DIG_STATE_C) then
        rVar.clkSel := unsigned(r.extRegsSync.clkSelDigitize);
      elsif (KPIX_READOUT_STATE_C /= KPIX_READOUT_IDLE_STATE_C) then
        rVar.clkSel := unsigned(r.extRegsSync.clkSelReadout);
      else
        rVar.clkSel := unsigned(r.extRegsSync.clkSelIdle);
      end if;
    end if;

    rin <= rVar;
  end process comb;

  -- Synchronize rst200 to KpixClk to create kpixClkRst
  RstSync_1 : entity work.RstSync
    generic map (
      DELAY_G        => DELAY_G,
      IN_POLARITY_G  => '1',
      OUT_POLARITY_G => '1')            -- Active high reset
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
