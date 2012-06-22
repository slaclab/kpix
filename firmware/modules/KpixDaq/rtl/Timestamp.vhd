-------------------------------------------------------------------------------
-- Title      : Timestamp Module
-------------------------------------------------------------------------------
-- File       : Timestamp.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-06-14
-- Last update: 2012-06-21
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
use work.TimestampPkg.all;
use work.KpixLocalPkg.all;
use work.TriggerPkg.all;

entity Timestamp is
  
  generic (
    DELAY_G : time := 1 ns);

  port (
    sysClk          : in  sl;
    sysRst          : in  sl;
    triggerIn       : in  TriggerInType;
    kpixLocalSysOut : in KpixLocalSysOutType;
    timestampRegsIn : in  TimestampRegsInType;
    timestampIn     : in  TimestampInType;
    timestampOut    : out TimestampOutType);

end entity Timestamp;

architecture rtl of Timestamp is

  type RegType is record
    extTriggerSync : SynchronizerArray(0 to 7);
  end record RegType;

  signal r, rin   : RegType;
  signal fifoWrEn : sl;
  signal fifoFull : sl;

begin


  seq : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      r.extTriggerSync <=  (others => SYNCHRONIZER_INIT_0_C) after DELAY_G;
    elsif (rising_edge(sysClk)) then
      r <= rin after DELAY_G;
    end if;
  end process seq;

  comb : process (r, triggerIn, timestampRegsIn, timestampIn) is
    variable rVar : RegType;
  begin
    rVar := r;

    synchronize('0', r.extTriggerSync(0), rVar.extTriggerSync(0));  -- It makes the code cleaner
    synchronize(triggerIn.nimA, r.extTriggerSync(1), rVar.extTriggerSync(1));
    synchronize(triggerIn.nimB, r.extTriggerSync(2), rVar.extTriggerSync(2));
    synchronize(triggerIn.cmosA, r.extTriggerSync(3), rVar.extTriggerSync(3));
    synchronize(triggerIn.cmosB, r.extTriggerSync(4), rVar.extTriggerSync(4));
    synchronize('0', r.extTriggerSync(5), rVar.extTriggerSync(0));
    synchronize('0', r.extTriggerSync(6), rVar.extTriggerSync(0));
    synchronize('0', r.extTriggerSync(7), rVar.extTriggerSync(0));

    rin <= rVar;
  end process comb;

  fifoWrEn <= toSl(detectRisingEdge(r.extTriggerSync(to_integer(unsigned(timestampRegsIn.extTriggerSrc))))) and
              toSl(kpixLocalSysOut.coreState(2 downto 0) = KPIX_ACQUISITION_STATE_C) and
              not kpixLocalSysOut.trigInhibit and
              not fifoFull;

  timestamp_fifo_1 : entity work.timestamp_fifo
    port map (
      clk   => sysClk,
      rst   => sysRst,
      din   => kpixLocalSysOut.bunchCount,
      wr_en => fifoWrEn,
      rd_en => timestampIn.rdEn,
      dout  => timestampOut.data,
      full  => fifoFull,
      empty => open,
      valid => timestampOut.valid);

end architecture rtl;
