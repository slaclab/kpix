-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixClockGen.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2012-05-21
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
use work.EthRegDecoderPkg.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity KpixClockGen is
  
  generic (
    DELAY_G        : time    := 1 ns;
    COUNTER_SIZE_G : natural := 5);

  port (
    sysClk           : in  sl;
    sysRst           : in  sl;
    clk200           : in  sl;
    rst200           : in  sl;
    ethRegDecoderOut : in  EthRegDecoderOutType;
    ethRegDecoderIn  : out EthRegDecoderInType;
    kpixState        : in  slv(3 downto 0);
    kpixClk          : out sl;
    kpixRst          : out sl);

end entity KpixClockGen;

architecture rtl of KpixClockGen is

  constant KPIX_IDLE_C         : slv(2 downto 0) := "000";
  constant KPIX_ACQUISITION_C  : slv(2 downto 0) := "001";
  constant KPIX_DIGITIZATION_C : slv(2 downto 0) := "010";
  constant KPIX_READOUT_C      : slv(2 downto 0) := "100";
  constant KPIX_PRECHARGE_C    : slv(3 downto 0) := "1010";

  -- Ethernet registers run on 125 MHz Sys Clock
  type SysRegType is record
    newRegVal       : sl;
    clkSelReadout   : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelDigitize  : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelAcquire   : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelIdle      : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelPrecharge : unsigned(COUNTER_SIZE_G-1 downto 0);
  end record SysRegType;

  signal sysR, sysRin : SysRegType;


  -- Kpix Clock registers run on 200 MHz clock
  type RegType is record
    newRegValSync   : SynchronizerType;
    clkSelReadout   : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelDigitize  : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelAcquire   : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelIdle      : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSelPrecharge : unsigned(COUNTER_SIZE_G-1 downto 0);
    divCount        : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkSel          : unsigned(COUNTER_SIZE_G-1 downto 0);
    clkDiv          : sl;
  end record RegType;

  signal r, rin : RegType;

begin

  sysSeq : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      sysR.newRegVal       <= '0';
      sysR.clkSelReadout   <= (others => '0');
      sysR.clkSelDigitize  <= (others => '0');
      sysR.clkSelAcquire   <= (others => '0');
      sysR.clkSelIdle      <= (others => '0');
      sysR.clkSelPrecharge <= (others => '0');
    elsif (rising_edge(sysClk)) then
      sysR <= sysRin;
    end if;
  end process sysSeq;

  sysComb : process (sysR, r, ethRegDecoderOut) is
    variable rVar : SysRegType;
  begin
    rVar := sysR;

    rVar.newRegVal := '0';

    if (ethRegDecoderOut.regOp = ETH_REG_WRITE_C) then
      if (ethRegDecoderOut.regSelect(CLOCK_SELECT_A_REG_ADDR_C) = '1') then
        rVar.clkSelReadout  := unsigned(ethRegDecoderOut.dataOut(28 downto 24));
        rVar.clkSelDigitize := unsigned(ethRegDecoderOut.dataOut(20 downto 16));
        rVar.clkSelAcquire  := unsigned(ethRegDecoderOut.dataOut(12 downto 8));
        rVar.clkSelIdle     := unsigned(ethRegDecoderOut.dataOut(4 downto 0));
        rVar.newRegVal      := '1';
      end if;
      if (ethRegDecoderOut.regSelect(CLOCK_SELECT_B_REG_ADDR_C) = '1') then
        rVar.clkSelPrecharge := unsigned(ethRegDecoderOut.dataOut(4 downto 0));
        rVar.newRegVal       := '1';
      end if;
    end if;

    ethRegDecoderIn.dataIn                                          <= (others => slvAll('Z', 32));
    ethRegDecoderIn.dataIn(CLOCK_SELECT_A_REG_ADDR_C)               <= (others => '0');
    ethRegDecoderIn.dataIn(CLOCK_SELECT_A_REG_ADDR_C)(28 downto 24) <= slv(r.clkSelReadout);
    ethRegDecoderIn.dataIn(CLOCK_SELECT_A_REG_ADDR_C)(20 downto 16) <= slv(r.clkSelDigitize);
    ethRegDecoderIn.dataIn(CLOCK_SELECT_A_REG_ADDR_C)(12 downto 8)  <= slv(r.clkSelAcquire);
    ethRegDecoderIn.dataIn(CLOCK_SELECT_A_REG_ADDR_C) (4 downto 0)  <= slv(r.clkSelIdle);
    ethRegDecoderIn.dataIn(CLOCK_SELECT_B_REG_ADDR_C)               <= (others => '0');
    ethRegDecoderIn.dataIn(CLOCK_SELECT_B_REG_ADDR_C)(4 downto 0)   <= slv(r.clkSelPrecharge);

  end process sysComb;

  --------------------------------------------------------------------------------------------------
  -- KPiX clock generation runs on 200 MHz Clock
  --------------------------------------------------------------------------------------------------
  seq : process (clk200, rst200) is
  begin
    if (rst200 = '1') then
      r.newRegValSync   <= SYNCHRONIZER_INIT_0_C;
      r.clkSelReadout   <= (others => '0');
      r.clkSelDigitize  <= (others => '0');
      r.clkSelAcquire   <= (others => '0');
      r.clkSelIdle      <= (others => '0');
      r.clkSelPrecharge <= (others => '0');
      r.divCount        <= (others => '0');
      r.clkSel          <= (others => '0');
      r.clkDiv          <= '0';
    elsif (rising_edge(clk200)) then
      r <= rin;
    end if;
  end process seq;

  comb : process (r, sysR, kpixState) is
    variable rVar : RegType;
  begin
    rVar := r;

    -- Sychronize newRegVal signal from sysClk domain
    synchronize(sysR.newRegVal, r.newRegValSync, rVar.newRegValSync);

    -- When new reg values are stable, clock them into their 200 MHz registers
    if (detectRisingEdge(r.newRegValSync)) then
      rVar.clkSelReadout   := sysR.clkSelReadout;
      rVar.clkSelDigitize  := sysR.clkSelDigitize;
      rVar.clkSelAcquire   := sysR.clkSelAcquire;
      rVar.clkSelIdle      := sysR.clkSelIdle;
      rVar.clkSelPrecharge := sysR.clkSelPrecharge;
    end if;

    rVar.divCount := r.divCount + 1;

    if (r.divCount = r.clkSel) then
      -- Invert clock every time divCount reacheck clkSel
      rVar.divCount := (others => '0');
      rVar.clkDiv   := not r.clkDiv;

      -- Assign new clkSel dependant on kpixState
      if (kpixState = KPIX_PRECHARGE_C) then
        rVar.clkSel := r.clkSelPrecharge;
      else
        case kpixState(2 downto 0) is
          when KPIX_IDLE_C =>
            rVar.clkSel := r.clkSelIdle;
          when KPIX_ACQUISITION_C =>
            rVar.clkSel := r.clkSelAcquire;
          when KPIX_DIGITIZATION_C =>
            rVar.clkSel := r.clkSelDigitize;
          when KPIX_READOUT_C =>
            rVar.clkSel := r.clkSelReadout;
          when others =>
            rVar.clkSel := r.clkSelIdle;
        end case;
      end if;
    end if;

    rin <= rVar;
  end process comb;

  -- Synchronize rst200 to KpixClk to create kpixRst
  RstSync_1 : entity work.RstSync
    generic map (
      DELAY_G    => DELAY_G,
      POLARITY_G => '1')                -- Active high reset
    port map (
      clk      => r.clkDiv,
      asyncRst => rst200,
      syncRst  => kpixRst);

  -- Use BUFG for output
  KPIX_CLK_BUFG : BUFG
    port map (
      I => r.clkDiv,
      O => kpixClk);

end architecture rtl;
