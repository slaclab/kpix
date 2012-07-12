-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2012-07-11
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
use work.KpixPkg.all;
use work.KpixDataRxPkg.all;
use work.EthFrontEndPkg.all;
use work.EventBuilderFifoPkg.all;
use work.TriggerPkg.all;
use work.KpixLocalPkg.all;
--use work.TimestampPkg.all;
--use work.KpixRegCntlPkg.all;

entity EventBuilder is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 4);

  port (
    sysClk : in sl;
    sysRst : in sl;

    -- Trigger Interface
    triggerOut : in TriggerOutType;

    -- Trigger Timestamp Interface
    timestampOut : in  TimestampOutType;
    timestampIn  : out TimestampInType;

    -- Kpix Local Interface
    kpixLocalSysOut : in KpixLocalSysOutType;

    -- KPIX data interface
    kpixDataRxOut : in  KpixDataRxOutArray(NUM_KPIX_MODULES_G-1 downto 0);
    kpixDataRxIn  : out KpixDataRxInArray(NUM_KPIX_MODULES_G-1 downto 0);
    kpixClk       : in  sl;

    -- Eth Registers
    kpixConfigRegs : in KpixConfigRegsType;

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
  type StateType is (WAIT_ACQUIRE_S, WRITE_HEADER_S, WAIT_DIGITIZE_S, READ_TIMESTAMPS_S, WAIT_READOUT_S,
                     CHECK_BUSY_S, GATHER_DATA_S);

  type RegType is record
    timestampCount : unsigned(31 downto 0);
    timestamp      : unsigned(31 downto 0);
    eventNumber    : unsigned(31 downto 0);
    newAcquire     : sl;
    kpixClkSync    : SynchronizerType;
    state          : StateType;
    counter        : unsigned(15 downto 0);  -- Generic counter for stalling in a state
    activeModules  : slv(NUM_KPIX_MODULES_G-1 downto 0);
    dataDone       : slv(NUM_KPIX_MODULES_G-1 downto 0);
    first          : unsigned(log2(NUM_KPIX_MODULES_G)-1 downto 0);
    kpixDataRxIn   : KpixDataRxInArray(NUM_KPIX_MODULES_G-1 downto 0);
    timestampIn    : TimestampInType;
    ebFifoIn       : EventBuilderFifoInType;
--    ethUsDataIn    : EthUsDataInType;
  end record;

  signal r, rin : RegType;

begin

  sync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      r.timestampCount   <= (others => '0')            after DELAY_G;
      r.timestamp        <= (others => '0')            after DELAY_G;
      r.eventNumber      <= (others => '1')            after DELAY_G;  -- So first event is 0 (eventNumber + 1)
      r.newAcquire       <= '0'                        after DELAY_G;
      r.kpixClkSync      <= SYNCHRONIZER_INIT_0_C      after DELAY_G;
      r.state            <= WAIT_ACQUIRE_S             after DELAY_G;
      r.counter          <= (others => '0')            after DELAY_G;
      r.activeModules    <= (others => '0')            after DELAY_G;
      r.dataDone         <= (others => '0')            after DELAY_G;
      r.first            <= (others => '0')            after DELAY_G;
      r.kpixDataRxIn     <= (others => (ready => '0')) after DELAY_G;
      r.timestampIn.rdEn <= '0'                        after DELAY_G;
      r.ebFifoIn.wrData  <= (others => '0')            after DELAY_G;
      r.ebFifoIn.wrEn    <= '0'                        after DELAY_G;
    elsif (rising_edge(sysClk)) then
      r <= rin after DELAY_G;
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

    impure function formatTimestamp
      return slv is
      variable retVar : slv(63 downto 0) := (others => '0');
    begin
      retVar(63 downto 60) := "0010";
      retVar(60 downto 32) := (others => '0');
      retVar(31 downto 29) := "000";
      retVar(28 downto 16) := timestampOut.bunchCount;
      retVar(15 downto 3)  := (others => '0');
      retVar(2 downto 0)   := timestampOut.subCount;
      return retVar;
    end function formatTimestamp;

  begin
    rVar := r;

    synchronize(kpixClk, r.kpixClkSync, rVar.kpixClkSync);

    ------------------------------------------------------------------------------------------------
    -- FIFO WR Logic
    ------------------------------------------------------------------------------------------------
    -- Latch trigger
    rVar.timestampCount := r.timestampCount + 1;
    if (r.newAcquire = '0' and triggerOut.startAcquire = '1' and r.state = WAIT_ACQUIRE_S) then
      rVar.timestamp   := r.timestampCount;
      rVar.eventNumber := r.eventNumber + 1;
      rVar.newAcquire  := '1';
    end if;

    if (kpixConfigRegs.kpixReset = '1') then
      rVar.eventNumber := (others => '0');
    end if;

    -- Registers that are 0 by default.
    rVar.timestampIn.rdEn := '0';
    rVar.ebFifoIn.wrEn    := '0';
    rVar.counter          := (others => '0');
    rVar.dataDone         := (others => '0');
    rVar.first            := (others => '0');
    rVar.activeModules    := (others => '0');

    -- Reset ready when valid falls
    for i in NUM_KPIX_MODULES_G-1 downto 0 loop
      if (kpixDataRxOut(i).valid = '0') then
        rVar.kpixDataRxIn(i).ready := '0';
      end if;
    end loop;

    case r.state is
      when WAIT_ACQUIRE_S =>
        if (r.newAcquire = '1' and ebFifoOut.full = '0') then
          rVar.newAcquire := '0';
          rVar.state      := WRITE_HEADER_S;
          writeFifo(slv(r.eventNumber & r.timestamp), SOF_C);
        end if;

      when WRITE_HEADER_S =>
        if (ebFifoOut.full = '0') then
          rVar.counter := r.counter + 1;
          writeFifo(slvAll('0', 64));
          if (r.counter = 2) then
            rVar.state := WAIT_DIGITIZE_S;
          end if;
        else
          rVar.counter := r.counter;
        end if;

      when WAIT_DIGITIZE_S =>
        -- Must wait until acquire state is done before reading timestamps
        if (kpixLocalSysOut.analogState = KPIX_ANALOG_DIG_STATE_C) then
          if (kpixConfigRegs.autoReadDisable = '1' and timestampOut.valid = '0') then
            -- No data, Close frame
            writeFifo(slvAll('0', 64), EOF_C);
            rVar.state := WAIT_ACQUIRE_S;
          else
            rVar.state := READ_TIMESTAMPS_S;
          end if;
        end if;

      when READ_TIMESTAMPS_S =>
        if (timestampOut.valid = '1') then
          rVar.timestampIn.rdEn := '1';
          if (r.timestampIn.rdEn = '1') then
            writeFifo(formatTimestamp);
          end if;
        else
          rVar.state := WAIT_READOUT_S;
        end if;

      when WAIT_READOUT_S =>
        if (kpixLocalSysOut.readoutState = KPIX_READOUT_DATA_STATE_C) then
          rVar.state := CHECK_BUSY_S;
        end if;
        
      when CHECK_BUSY_S =>
        -- Wait X kpixClk cycles for busy signals
        -- Tells which modules are active
        rVar.counter := r.counter;
        if (detectRisingEdge(r.kpixClkSync)) then
          rVar.counter := r.counter + 1;
        end if;
        if (r.counter = 65532) then     -- Wait some amount of time for data to arrive
          -- No busy signals detected at all
          rVar.state := WAIT_ACQUIRE_S;
          writeFifo(X"0123456789abcdef", EOF_C);
        end if;
        for i in NUM_KPIX_MODULES_G-1 downto 0 loop
          if (kpixDataRxOut(i).busy = '1') then
            rVar.activeModules(i) := '1';
          end if;
          -- Due to clock crossing, busy signals may arrive 1 cycle appart
          -- Checking r.activeModules rather than busy inputs assures that
          -- any late arriving busy signals will set the corresponding activeModules
          -- signal correctly.
          if (r.activeModules(i) = '1') then
            rVar.state := GATHER_DATA_S;
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
            if (kpixDataRxOut(selectedIntVar).valid = '1' and r.kpixDataRxIn(selectedIntVar).ready = '0') then
              rVar.first                              := selectedUVar + 1;
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
            rVar.state := WAIT_ACQUIRE_S;
          end if;
        end if;


    end case;

    -- Unused. Output signal assigned below rather than from this register
    rVar.ebFifoIn.rdEn := '0';

    -- Assign outputs to FIFO
    ebFifoIn      <= r.ebFifoIn;
    ebFifoIn.rdEn <= not ebFifoOut.empty and not ethUsDataOut.frameTxAFull;
    kpixDataRxIn  <= r.kpixDataRxIn;
    timestampIn   <= r.timestampIn;

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
