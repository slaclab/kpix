-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Trigger.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2012-07-05
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
use work.EthFrontEndPkg.all;
use work.KpixLocalPkg.all;
use work.KpixPkg.all;
use work.TriggerPkg.all;

entity Trigger is
  
  generic (
    DELAY_G        : time    := 1 ns;
    CLOCK_PERIOD_G : natural := 8);     -- In ns

  port (
    sysClk          : in  sl;
    sysRst          : in  sl;
    ethCmdCntlOut   : in  EthCmdCntlOutType;
    kpixLocalSysOut : in  KpixLocalSysOutType;
    triggerRegsIn   : in  TriggerRegsInType;
    kpixConfigRegs : in KpixConfigRegsType;
    triggerExtIn    : in  TriggerExtInType;
    triggerOut      : out TriggerOutType;
    timestampIn     : in  TimestampInType;
    timestampOut    : out TimestampOutType);

end entity Trigger;

architecture rtl of Trigger is

  constant CLOCKS_PER_USEC_C : natural := 1000 / CLOCK_PERIOD_G;

  type RegType is record
    extTriggerSync     : SynchronizerArray(0 to 7);
    triggerCounter     : unsigned(log2(CLOCKS_PER_USEC_C)-1 downto 0);
    triggerCountEnable : sl;
    startCounter       : unsigned(7 downto 0);
    startCountEnable   : sl;
    timestampFifoWrEn  : sl;
    readoutPending     : sl;
    readoutCounter     : unsigned(7 downto 0);
    readoutCountEnable : sl;
    triggerOut         : TriggerOutType;
  end record;

  signal r, rin : RegType;
  signal fifoFull : sl;

begin

  sync : process (sysClk, sysRst) is
  begin

    if (rising_edge(sysClk)) then
      r <= rin after DELAY_G;
    end if;
    if (sysRst = '1') then
      r.extTriggerSync            <= (others => SYNCHRONIZER_INIT_0_C) after DELAY_G;
      r.triggerCounter            <= (others => '0')                   after DELAY_G;
      r.triggerCountEnable        <= '0'                               after DELAY_G;
      r.startCounter              <= (others => '0')                   after DELAY_G;
      r.startCountEnable          <= '0'                               after DELAY_G;
      r.timestampFifoWrEn         <= '0'                               after DELAY_G;
      r.readoutPending            <= '0'                               after DELAY_G;
      r.readoutCounter            <= (others => '0')                   after DELAY_G;
      r.readoutCountEnable        <= '0'                               after DELAY_G;
      r.triggerOut.trigger        <= '0'                               after DELAY_G;
      r.triggerOut.startAcquire   <= '0'                               after DELAY_G;
      r.triggerOut.startCalibrate <= '0'                               after DELAY_G;
    end if;
  end process sync;

  comb : process (r, ethCmdCntlOut, triggerRegsIn, triggerExtIn, kpixLocalSysOut, fifoFull) is
    variable rVar : RegType;
  begin
    rVar := r;

    ------------------------------------------------------------------------------------------------
    -- Synchronize external signals to sysClk
    ------------------------------------------------------------------------------------------------
    synchronize('0', r.extTriggerSync(0), rVar.extTriggerSync(0));  -- It makes the code cleaner
    synchronize(triggerExtIn.nimA, r.extTriggerSync(1), rVar.extTriggerSync(1));
    synchronize(triggerExtIn.nimB, r.extTriggerSync(2), rVar.extTriggerSync(2));
    synchronize(triggerExtIn.cmosB, r.extTriggerSync(3), rVar.extTriggerSync(3));
    synchronize(triggerExtIn.cmosA, r.extTriggerSync(4), rVar.extTriggerSync(4));
    synchronize('0', r.extTriggerSync(5), rVar.extTriggerSync(0));
    synchronize('0', r.extTriggerSync(6), rVar.extTriggerSync(0));
    synchronize('0', r.extTriggerSync(7), rVar.extTriggerSync(0));

    ------------------------------------------------------------------------------------------------
    -- External Trigger
    ------------------------------------------------------------------------------------------------
    if (detectRisingEdge(r.extTriggerSync(to_integer(unsigned(triggerRegsIn.extTriggerSrc)))) and
        kpixLocalSysOut.analogState = KPIX_ANALOG_SAMP_STATE_C and
        kpixLocalSysOut.trigInhibit = '0') then
      rVar.triggerOut.trigger := '1';
      rVar.triggerCountEnable := '1';
      rVar.triggerCounter     := (others => '0');
    end if;

    if (r.triggerCountEnable = '1') then
      rVar.triggerCounter := r.triggerCounter + 1;
      if (r.triggerCounter = CLOCKS_PER_USEC_C) then
        rVar.triggerCounter     := (others => '0');
        rVar.triggerCountEnable := '0';
        rVar.triggerOut.trigger := '0';
      end if;
    end if;

    ------------------------------------------------------------------------------------------------
    -- Trigger timestamp
    ------------------------------------------------------------------------------------------------
    rVar.timestampFifoWrEn := '0';
    if (detectRisingEdge(r.extTriggerSync(to_integer(unsigned(triggerRegsIn.extTimestampSrc)))) and
        kpixLocalSysOut.analogState = KPIX_ANALOG_SAMP_STATE_C and
        kpixLocalSysOut.trigInhibit = '0' and
        fifoFull = '0') then
      rVar.timestampFifoWrEn := '1';
      if (kpixConfigRegs.autoReadDisable = '1') then
        rVar.readoutPending := '1';
      end if;
    end if;

    ------------------------------------------------------------------------------------------------
    -- Readout Trigger
    ------------------------------------------------------------------------------------------------
    if (kpixLocalSysOut.analogState = KPIX_ANALOG_IDLE_STATE_C and
        kpixLocalSysOut.readoutState = KPIX_READOUT_IDLE_STATE_C and
        r.readoutPending = '1') then
      rVar.readoutPending          := '0';
      rVar.triggerOut.startReadout := '1';
      rVar.readoutCountEnable      := '1';
      rVar.readoutCounter          := (others => '0');
    end if;

    if (r.readoutCountEnable = '1') then
      rVar.readoutCounter := r.readoutCounter + 1;
      if (isAll(r.readoutCounter, '1')) then
        rVar.readoutCounter          := (others => '0');
        rVar.readoutCountEnable      := '0';
        rVar.triggerOut.startReadout := '0';
      end if;
    end if;

    ------------------------------------------------------------------------------------------------
    -- Acquire Command
    ------------------------------------------------------------------------------------------------
    if (ethCmdCntlOut.cmdEn = '1') then
      if (ethCmdCntlOut.cmdOpCode = TRIGGER_OPCODE_C) then
        rVar.triggerOut.startAcquire   := '1';
        rVar.triggerOut.startCalibrate := triggerRegsIn.calibrate;
        rVar.startCountEnable          := '1';
        rVar.startCounter              := (others => '0');
      end if;
    end if;


    if (r.startCountEnable = '1') then
      rVar.startCounter := r.startCounter + 1;
      if (isAll(r.startCounter, '1')) then
        rVar.startCounter              := (others => '0');
        rVar.startCountEnable          := '0';
        rVar.triggerOut.startAcquire   := '0';
        rVar.triggerOut.startCalibrate := '0';
      end if;
    end if;


    rin        <= rVar;
    triggerOut <= r.triggerOut;
  end process comb;



  timestamp_fifo_1 : entity work.timestamp_fifo
    port map (
      clk   => sysClk,
      rst   => sysRst,
      din   => kpixLocalSysOut.bunchCount,
      wr_en => r.timestampFifoWrEn,
      rd_en => timestampIn.rdEn,
      dout  => timestampOut.data,
      full  => fifoFull,
      empty => open,
      valid => timestampOut.valid);

end architecture rtl;
