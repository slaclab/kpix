-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Trigger.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2013-07-31
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
use work.VcPkg.all;
use work.KpixLocalPkg.all;
use work.KpixPkg.all;
use work.EvrCorePkg.all;
use work.TriggerPkg.all;

entity Trigger is
   
   generic (
      DELAY_G        : time    := 1 ns;
      CLOCK_PERIOD_G : natural := 5);   -- In ns

   port (
      clk200       : in sl;
      rst200       : in sl;
      triggerExtIn : in TriggerExtInType;  -- noSync
      evrOut       : in EvrOutType;        -- evrClk

      kpixState   : in  KpixStateOutType;   -- kpixClk
      cmdSlaveOut : in  VcCmdSlaveOutType;  -- clk200
      triggerOut  : out TriggerOutType;     -- clk200

      sysClk         : in  sl;
      sysRst         : in  sl;
      triggerRegsIn  : in  TriggerRegsInType;   -- sysClk
      kpixConfigRegs : in  KpixConfigRegsType;  -- sysClk
      timestampIn    : in  TimestampInType;     -- sysClk
      timestampOut   : out TimestampOutType);   -- sysClk

end entity Trigger;

architecture rtl of Trigger is

   constant CLOCKS_PER_USEC_C : natural := 1000 / CLOCK_PERIOD_G;

   type RegType is record
      autoReadDisable    : sl;
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

   constant REG_INIT_C : RegType := (
      autoReadDisable    => '0',
      triggerCounter     => (others => '0'),
      triggerCountEnable => '0',
      startCounter       => (others => '0'),
      startCountEnable   => '0',
      timestampFifoWrEn  => '0',
      readoutPending     => '0',
      readoutCounter     => (others => '0'),
      readoutCountEnable => '0',
      triggerOut         => TRIGGER_OUT_INIT_C);

   signal r, rin              : RegType := REG_INIT_C;
   signal fifoFull            : sl;
   signal extTriggerRise      : slv(0 to 7);
   signal triggerRegsInSync   : TriggerRegsInType;
   signal autoReadDisableSync : sl;
   
begin

   -- Synchronize external inputs
   extTriggerRise(0) <= '0';

   Synchronizer_NimA : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => clk200,
         aRst        => rst200,
         dataIn      => triggerExtIn.nimA,
         dataOut     => open,
         risingEdge  => extTriggerRise(1),
         fallingEdge => open);

   Synchronizer_NimB : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => clk200,
         aRst        => rst200,
         dataIn      => triggerExtIn.nimB,
         dataOut     => open,
         risingEdge  => extTriggerRise(2),
         fallingEdge => open);

   Synchronizer_CmosA : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => clk200,
         aRst        => rst200,
         dataIn      => triggerExtIn.cmosA,
         dataOut     => open,
         risingEdge  => extTriggerRise(3),
         fallingEdge => open);

   Synchronizer_CmosB : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => clk200,
         aRst        => rst200,
         dataIn      => triggerExtIn.cmosB,
         dataOut     => open,
         risingEdge  => extTriggerRise(4),
         fallingEdge => open);

   extTriggerRise(5) <= '0';
   extTriggerRise(6) <= '0';

   Synchronizer_EVR : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => clk200,
         aRst        => rst200,
         dataIn      => evrOut.trigger,
         dataOut     => open,
         risingEdge  => extTriggerRise(7),
         fallingEdge => open);

   -------------------------------------------------------------------------------------------------
   -- Synchronize Trigger Config Registers
   -------------------------------------------------------------------------------------------------
   SynchronizerFifo_1 : entity work.SynchronizerFifo
      generic map (
         TPD_G        => DELAY_G,
         BRAM_EN_G    => false,
         DATA_WIDTH_G => 9,
         ADDR_WIDTH_G => 4)
      port map (
         rst              => sysRst,
         wr_clk           => sysClk,
         din(2 downto 0)  => triggerRegsIn.extTriggerSrc,
         din(5 downto 3)  => triggerRegsIn.extTimestampSrc,
         din(7 downto 6)  => triggerRegsIn.acquisitionSrc,
         din(8)           => triggerRegsIn.calibrate,
         rd_clk           => clk200,
         dout(2 downto 0) => triggerRegsInSync.extTriggerSrc,
         dout(5 downto 3) => triggerRegsInSync.extTimestampSrc,
         dout(7 downto 6) => triggerRegsInSync.acquisitionSrc,
         dout(8)          => triggerRegsInSync.calibrate);

   Synchronizer_autoReadDisable : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => clk200,
         aRst        => rst200,
         dataIn      => kpixConfigRegs.autoReadDisable,
         dataOut     => open,
         risingEdge  => autoReadDisableSync,
         fallingEdge => open);

   sync : process (clk200, rst200) is
   begin

      if (rising_edge(clk200)) then
         r <= rin after DELAY_G;
      end if;
      if (rst200 = '1') then
         r <= REG_INIT_C after DELAY_G;
      end if;
   end process sync;


   comb : process (r, cmdSlaveOut, triggerRegsInSync, autoReadDisableSync, extTriggerRise, kpixState, fifoFull) is
      variable v : RegType;
   begin
      v := r;

      ------------------------------------------------------------------------------------------------
      -- External Trigger
      ------------------------------------------------------------------------------------------------
      if (extTriggerRise(to_integer(unsigned(triggerRegsInSync.extTriggerSrc))) = '1' and
          kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C and
          kpixState.trigInhibit = '0') then
         v.triggerOut.trigger := '1';
         v.triggerCountEnable := '1';
         v.triggerCounter     := (others => '0');
      end if;

      if (r.triggerCountEnable = '1') then
         v.triggerCounter := r.triggerCounter + 1;
         if (r.triggerCounter = CLOCKS_PER_USEC_C) then
            v.triggerCounter     := (others => '0');
            v.triggerCountEnable := '0';
            v.triggerOut.trigger := '0';
         end if;
      end if;

      ------------------------------------------------------------------------------------------------
      -- Trigger timestamp
      ------------------------------------------------------------------------------------------------
      v.timestampFifoWrEn := '0';
      if (extTriggerRise(to_integer(unsigned(triggerRegsInSync.extTimestampSrc))) = '1' and
          kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C and
          kpixState.trigInhibit = '0' and
          fifoFull = '0') then
         v.timestampFifoWrEn := '1';
         if (autoReadDisableSync = '1') then
            v.readoutPending := '1';
         end if;
      end if;

      ------------------------------------------------------------------------------------------------
      -- Readout Trigger
      ------------------------------------------------------------------------------------------------
      if (kpixState.analogState = KPIX_ANALOG_IDLE_STATE_C and
          kpixState.readoutState = KPIX_READOUT_IDLE_STATE_C and
          r.readoutPending = '1') then
         v.readoutPending          := '0';
         v.triggerOut.startReadout := '1';
         v.readoutCountEnable      := '1';
         v.readoutCounter          := (others => '0');
      end if;

      if (r.readoutCountEnable = '1') then
         v.readoutCounter := r.readoutCounter + 1;
         if (uAnd(slv(r.readoutCounter)) = '1') then
            v.readoutCounter          := (others => '0');
            v.readoutCountEnable      := '0';
            v.triggerOut.startReadout := '0';
         end if;
      end if;

      ------------------------------------------------------------------------------------------------
      -- Acquire Command
      -- Source could be software (through FrontEndCmdCntl), EVR, or external input
      -- Selected by Front End Register triggerRegsIn.acquisitionSrc
      ------------------------------------------------------------------------------------------------
      if ((triggerRegsInSync.acquisitionSrc = TRIGGER_ACQ_SOFTWARE_C and
           cmdSlaveOut.valid = '1' and cmdSlaveOut.opCode = TRIGGER_OPCODE_C)
          or
          (triggerRegsInSync.acquisitionSrc = TRIGGER_ACQ_EVR_C and
           extTriggerRise(7) = '1')     -- EVR trigger routed through extTriggerSync(7)
          or
          (triggerRegsInSync.acquisitionSrc = TRIGGER_ACQ_CMOSA_C and
           extTriggerRise(3) = '1')     -- CMOSA trigger is extTriggerSync(3)
          or
          (triggerRegsInSync.acquisitionSrc = TRIGGER_ACQ_NIMA_C and
           extTriggerRise(1) = '1'))    -- NIMA trigger is extTriggerSync(1)
      then
         v.triggerOut.startAcquire   := '1';
         v.triggerOut.startCalibrate := triggerRegsInSync.calibrate;
         v.startCountEnable          := '1';
         v.startCounter              := (others => '0');
      end if;

      if (r.startCountEnable = '1') then
         v.startCounter := r.startCounter + 1;
         if (uAnd(slv(r.startCounter)) = '1') then
            v.startCounter              := (others => '0');
            v.startCountEnable          := '0';
            v.triggerOut.startAcquire   := '0';
            v.triggerOut.startCalibrate := '0';
         end if;
      end if;


      rin        <= v;
      triggerOut <= r.triggerOut;
   end process comb;

   FifoAsync_TimestampFifo : entity work.FifoAsync
      generic map (
         TPD_G        => DELAY_G,
         BRAM_EN_G    => true,
         FWFT_EN_G    => true,
         DATA_WIDTH_G => 16,
         ADDR_WIDTH_G => 10)
      port map (
         rst               => rst200,
         wr_clk            => clk200,
         wr_en             => r.timestampFifoWrEn,
         din(15 downto 3)  => kpixState.bunchCount,
         din(2 downto 0)   => kpixState.subCount,
         full              => fifoFull,
         rd_clk            => sysClk,
         rd_en             => timestampIn.rdEn,
         dout(15 downto 3) => timestampOut.bunchCount,
         dout(2 downto 0)  => timestampOut.subCount,
         valid             => timestampOut.valid,
         empty             => open);

end architecture rtl;
