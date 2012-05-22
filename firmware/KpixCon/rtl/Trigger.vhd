-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Trigger.vhd
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
use work.EthFrontEndPkg.all;
use work.TriggerPkg.all;

entity Trigger is
  
  generic (
    DELAY_G        : time := 1 ns;
    CLOCK_PERIOD_G : natural := 8);     -- In ns

  port (
    sysClk        : in  sl;
    sysRst        : in  sl;
    ethCmdCntlOut : in  EthCmdCntlOutType;
    triggerOut    : out TriggerOutType);

end entity Trigger;

architecture rtl of Trigger is

  constant CLOCKS_PER_USEC_C : natural := 1000 / CLOCK_PERIOD_G;

  type RegType is record
    pulseCounter : unsigned(log2(CLOCKS_PER_USEC_C)-1 downto 0);
    countEnable  : sl;
    triggerOut   : TriggerOutType;
  end record;

  signal r, rin : RegType;

begin

  sync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      r.pulseCounter              <= (others => '0') after DELAY_G;
      r.countEnable               <= '0'             after DELAY_G;
      r.triggerOut.startAcquire   <= '0'             after DELAY_G;
      r.triggerOut.startCalibrate <= '0'             after DELAY_G;
    elsif (rising_edge(sysClk)) then
      r <= rin after DELAY_G;
    end if;
  end process sync;

  comb : process (r, ethCmdCntlOut) is
    variable rVar : RegType;
  begin
    rVar := r;
    if (ethCmdCntlOut.cmdEn = '1') then
      if (ethCmdCntlOut.cmdOpCode = TRIGGER_ACQUIRE_OPCODE_C) then
        rVar.triggerOut.startAcquire := '1';
        rVar.pulseCounter            := (others => '0');
        rVar.countEnable             := '1';
      elsif (ethCmdCntlOut.cmdOpCode = TRIGGER_CALIBRATE_OPCODE_C) then
        rVar.triggerOut.startAcquire   := '1';
        rVar.triggerOut.startCalibrate := '1';
        rVar.pulseCounter              := (others => '0');
        rVar.countEnable               := '1';
      end if;
    end if;

    if (r.countEnable = '1') then
      rVar.pulseCounter := r.pulseCounter + 1;
      if (r.pulseCounter = CLOCKS_PER_USEC_C) then
        rVar.pulseCounter              := (others => '0');
        rVar.countEnable               := '0';
        rVar.triggerOut.startAcquire   := '0';
        rVar.triggerOut.startCalibrate := '0';
      end if;
    end if;

    rin        <= rVar;
    triggerOut <= r.triggerOut;
  end process comb;

end architecture rtl;
