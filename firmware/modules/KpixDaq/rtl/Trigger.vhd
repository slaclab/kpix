-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Trigger.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2013-07-24
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
use work.FrontEndPkg.all;
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

      kpixState          : in  KpixStateOutType;        -- kpixClk
      frontEndCmdCntlOut : in  FrontEndCmdCntlOutType;  -- clk200
      triggerOut         : out TriggerOutType;          -- clk200

      sysClk         : in  sl;
      triggerRegsIn  : in  TriggerRegsInType;   -- sysClk
      kpixConfigRegs : in  KpixConfigRegsType;  -- sysClk
      timestampIn    : in  TimestampInType;     -- sysClk
      timestampOut   : out TimestampOutType);   -- sysClk

end entity Trigger;

architecture rtl of Trigger is

   constant CLOCKS_PER_USEC_C : natural := 1000 / CLOCK_PERIOD_G;

   type RegType is record
      triggerRegsIn      : TriggerRegsInType;
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

   signal r, rin         : RegType;
   signal fifoFull       : sl;
   signal extTriggerRise : slv(0 to 7);

   component timestamp_fifo
      port (
         rst    : in  std_logic;
         wr_clk : in  std_logic;
         rd_clk : in  std_logic;
         din    : in  std_logic_vector(15 downto 0);
         wr_en  : in  std_logic;
         rd_en  : in  std_logic;
         dout   : out std_logic_vector(15 downto 0);
         full   : out std_logic;
         empty  : out std_logic;
         valid  : out std_logic
         );
   end component;

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
   
   sync : process (clk200, rst200) is
   begin

      if (rising_edge(clk200)) then
         r <= rin after DELAY_G;
      end if;
      if (rst200 = '1') then
         r.triggerRegsIn.extTriggerSrc   <= (others => '0') after DELAY_G;
         r.triggerRegsIn.extTimestampSrc <= (others => '0') after DELAY_G;
         r.triggerRegsIn.acquisitionSrc  <= (others => '0') after DELAY_G;
         r.triggerRegsIn.calibrate       <= '0'             after DELAY_G;
         r.autoReadDisable               <= '0'             after DELAY_G;
         r.triggerCounter                <= (others => '0') after DELAY_G;
         r.triggerCountEnable            <= '0'             after DELAY_G;
         r.startCounter                  <= (others => '0') after DELAY_G;
         r.startCountEnable              <= '0'             after DELAY_G;
         r.timestampFifoWrEn             <= '0'             after DELAY_G;
         r.readoutPending                <= '0'             after DELAY_G;
         r.readoutCounter                <= (others => '0') after DELAY_G;
         r.readoutCountEnable            <= '0'             after DELAY_G;
         r.triggerOut.trigger            <= '0'             after DELAY_G;
         r.triggerOut.startAcquire       <= '0'             after DELAY_G;
         r.triggerOut.startCalibrate     <= '0'             after DELAY_G;
         r.triggerOut.startReadout       <= '0'             after DELAY_G;
      end if;
   end process sync;



   
   comb : process (r, frontEndCmdCntlOut, triggerRegsIn, kpixConfigRegs, extTriggerRise, kpixState, fifoFull) is
      variable v : RegType;
   begin
      v := r;

      -- triggerRegsIn and kpixConfigRegs come from sysClk
      -- Only set once before run begins. Don't need to worry about syncing them to clk200
      v.triggerRegsIn   := triggerRegsIn;
      v.autoReadDisable := kpixConfigRegs.autoReadDisable;

      ------------------------------------------------------------------------------------------------
      -- External Trigger
      ------------------------------------------------------------------------------------------------
      if (extTriggerRise(to_integer(unsigned(r.triggerRegsIn.extTriggerSrc))) = '1' and
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
      if (extTriggerRise(to_integer(unsigned(r.triggerRegsIn.extTimestampSrc))) = '1' and
          kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C and
          kpixState.trigInhibit = '0' and
          fifoFull = '0') then
         v.timestampFifoWrEn := '1';
         if (r.autoReadDisable = '1') then
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
      if ((r.triggerRegsIn.acquisitionSrc = TRIGGER_ACQ_SOFTWARE_C and
           frontEndCmdCntlOut.cmdEn = '1' and frontEndCmdCntlOut.cmdOpCode = TRIGGER_OPCODE_C)
          or
          (r.triggerRegsIn.acquisitionSrc = TRIGGER_ACQ_EVR_C and
           extTriggerRise(7) = '1')     -- EVR trigger routed through extTriggerSync(7)
          or
          (r.triggerRegsIn.acquisitionSrc = TRIGGER_ACQ_CMOSA_C and
           extTriggerRise(3) = '1')    -- CMOSA trigger is extTriggerSync(3)
          or
          (r.triggerRegsIn.acquisitionSrc = TRIGGER_ACQ_NIMA_C and
           extTriggerRise(1) = '1'))    -- NIMA trigger is extTriggerSync(1)
      then
         v.triggerOut.startAcquire   := '1';
         v.triggerOut.startCalibrate := r.triggerRegsIn.calibrate;
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

   timestamp_fifo_1 : timestamp_fifo
      port map (
         rd_clk            => sysClk,
         wr_clk            => clk200,
         rst               => rst200,
         din(15 downto 3)  => kpixState.bunchCount,
         din(2 downto 0)   => kpixState.subCount,
         wr_en             => r.timestampFifoWrEn,
         rd_en             => timestampIn.rdEn,
         dout(15 downto 3) => timestampOut.bunchCount,
         dout(2 downto 0)  => timestampOut.subCount,
         full              => fifoFull,
         empty             => open,
         valid             => timestampOut.valid);

end architecture rtl;
