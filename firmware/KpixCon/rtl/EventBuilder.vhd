-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2012-05-25
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
use work.KpixPkg.all;
use work.KpixDataRxPkg.all;
use work.EthFrontEndPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;

entity EventBuilder is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 4);

  port (
    sysClk : in sl;
    sysRst : in sl;

    -- Trigger Interface
    triggerOut : in TriggerOutType;

    -- KPIX data interface
    kpixDataRxOut : in  KpixDataRxOutArray(0 to NUM_KPIX_MODULES_G-1);
    kpixDataRxIn  : out KpixDataRxInArray(0 to NUM_KPIX_MODULES_G-1);

    -- FIFO Interface
    ebFifoIn  : out EventBuilderFifoInType;
    ebFifoOut : in  EventBuilderFifoOutType;

    -- Eth US Buffer interface
    ethUsDataOut : in  EthUsDataOutType;
    ethUsDataIn  : out EthUsDataInType);

end entity EventBuilder;

architecture rtl of EventBuilder is

  constant SOF_BIT_C : natural := 64;
  constant EOF_BIT_C : natural := 65;

  type FlagType is (NONE_C, SOF_C, EOF_C);
  type StateType is (WAIT_TRIGGER_S, WRITE_HEADER_S, CHECK_BUSY_S, GATHER_DATA_S);

  type RegType is record
    timestampCount : unsigned(31 downto 0);
    timestamp      : unsigned(31 downto 0);
    eventNumber    : unsigned(31 downto 0);
    newTrigger     : sl;
    state          : StateType;
    counter        : unsigned(7 downto 0);  -- Generic counter for stalling in a state
    activeModules  : slv(NUM_KPIX_MODULES_G-1 downto 0);
    dataDone       : slv(NUM_KPIX_MODULES_G-1 downto 0);
    first          : unsigned(log2(NUM_KPIX_MODULES_G)-1 downto 0);
    kpixDataRxIn   : KpixDataRxInArray(0 to NUM_KPIX_MODULES_G-1);
    ebFifoIn       : EventBuilderFifoInType;
--    ethUsDataIn    : EthUsDataInType;
  end record;

  signal r, rin : RegType;

begin

  sync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      r.timestampCount  <= (others => '0');
      r.timestamp       <= (others => '0');
      r.eventNumber     <= (others => '1');  -- So first event is 0 (eventNumber + 1)
      r.newTrigger      <= '0';
      r.state           <= WAIT_TRIGGER_S;
      r.counter         <= (others => '0');
      r.activeModules   <= (others => '0');
      r.dataDone        <= (others => '0');
      r.first           <= (others => '0');
      r.kpixDataRxIn    <= (others => (ready => '0'));
      r.ebFifoIn.wrData <= (others => '0');
      r.ebFifoIn.wrEn   <= '0';
    elsif (rising_edge(sysClk)) then
      r <= rin;
    end if;
  end process sync;

  comb : process (r, triggerOut, kpixDataRxOut, ebFifoOut, ethUsDataOut) is
    variable rVar           : RegType;
    variable selectedUVar   : unsigned(r.first'range);
    variable selectedIntVar : natural;
    
    procedure writeFifo (
      data : in slv(63 downto 0);
      flag : in FlagType := NONE_C) is
    begin
      rVar.ebFifoIn.wrData              := (others => '0');
      rVar.ebFifoIn.wrData(63 downto 0) := data;
      if (flag = SOF_C) then
        rVar.ebFifoIn.wrData(SOF_BIT_C) := '1';
      elsif (flag = EOF_C) then
        rVar.ebFifoIn.wrData(EOF_BIT_C) := '1';
      end if;
      rVar.ebFifoIn.wrEn := '1';
    end procedure writeFifo;

  begin
    rVar := r;

    ------------------------------------------------------------------------------------------------
    -- FIFO WR Logic
    ------------------------------------------------------------------------------------------------
    -- Latch trigger
    rVar.timestampCount := r.timestampCount + 1;
    if (r.newTrigger = '0' and triggerOut.startAcquire = '1') then
      rVar.timestamp   := r.timestampCount;
      rVar.eventNumber := r.eventNumber + 1;
      rVar.newTrigger  := '1';
    end if;

    -- Registers that are 0 by default.
    rVar.ebFifoIn.wrEn := '0';
    for i in kpixDataRxIn'range loop
      rVar.kpixDataRxIn(i).ready := '0';
    end loop;
    rVar.counter       := (others => '0');
    rVar.dataDone      := (others => '0');
    rVar.first         := (others => '0');
    rVar.activeModules := (others => '0');

    case r.state is
      when WAIT_TRIGGER_S =>
        if (r.newTrigger = '1' and ebFifoOut.full = '0') then
          rVar.newTrigger := '0';
          rVar.state      := WRITE_HEADER_S;
          writeFifo(slv(r.eventNumber & r.timestamp), SOF_C);
        end if;

      when WRITE_HEADER_S =>
        if (ebFifoOut.full = '0') then
          rVar.counter := r.counter + 1;
          writeFifo(slvAll('0', 64));
          if (r.counter = 3) then
            rVar.state := CHECK_BUSY_S;
          end if;
        else
          rVar.counter := r.counter;
        end if;
        
      when CHECK_BUSY_S =>
        -- Wait X cycles for busy signals
        -- Tells which modules are active
        rVar.counter := r.counter + 1;
        if (r.counter = 100) then
          -- No busy signals detected at all
          rVar.state := WAIT_TRIGGER_S;
        end if;
        for i in 0 to NUM_KPIX_MODULES_G-1 loop
          if (kpixDataRxOut(i).busy = '1') then
            rVar.activeModules(i) := '1';
            rVar.state            := GATHER_DATA_S;
          end if;
        end loop;


      when GATHER_DATA_S =>
        rVar.dataDone      := r.dataDone;
        rVar.activeModules := r.activeModules;
        rVar.first         := r.first;

        if (ebFifoOut.full = '0') then  -- pause if fifo is full
          for i in 0 to NUM_KPIX_MODULES_G-1 loop
            selectedUVar   := i + r.first;
            selectedIntVar := to_integer(selectedUVar);
            if (kpixDataRxOut(selectedIntVar).valid = '1') then
              rVar.first                              := selectedUVar;
              rVar.kpixDataRxIn(selectedIntVar).ready := '1';
              writeFifo(kpixDataRxOut(selectedIntVar).data);
              if (kpixDataRxOut(selectedIntVar).last = '1') then
                rVar.dataDone(selectedIntVar) := '1';
              end if;
            end if;
          end loop;

          -- Check if done
          if (r.dataDone = r.activeModules) then
            writeFifo(slvAll('0', 64), EOF_C);  -- Write tail
            rVar.state := WAIT_TRIGGER_S;
          end if;
        end if;
    end case;

    -- NOT RIGHT!
    rVar.ebFifoIn.rdEn := not ebFifoOut.empty and not ethUsDataOut.frameTxAFull;

    -- Assign outputs to FIFO
    ebFifoIn     <= r.ebFifoIn;
    kpixDataRxIn <= r.kpixDataRxIn;


    rin <= rVar;
  end process comb;

  ------------------------------------------------------------------------------------------------
  -- FIFO Rd Logic
  ------------------------------------------------------------------------------------------------
  ethUsDataIn.frameTxEnable <= not ebFifoOut.empty and not ethUsDataOut.frameTxAFull;
  ethUsDataIn.frameTxData   <= ebFifoOut.rdData(63 downto 0);
  ethUsDataIn.frameTxSOF    <= ebFifoOut.rdData(SOF_BIT_C);
  ethUsDataIn.frameTxEOF    <= ebFifoOut.rdData(EOF_BIT_C);
  

end architecture rtl;
