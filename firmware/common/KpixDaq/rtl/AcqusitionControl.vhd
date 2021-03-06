-------------------------------------------------------------------------------
-- Title      : Acquisition Control
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Controls acquisition sequence for KPIX initiated from various
-- trigger sources.
-------------------------------------------------------------------------------
-- This file is part of 'KPIX'
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'KPIX', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;


library kpix;
use kpix.KpixLocalPkg.all;
use kpix.KpixPkg.all;

entity AcquisitionControl is

   generic (
      TPD_G          : time := 1 ns;
      CLOCK_PERIOD_G : real := 5.0);    -- In ns

   port (
      clk200 : in sl;
      rst200 : in sl;

      -- AXI-Lite interface for registers
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- System level configuration
      sysConfig : in SysConfigType;

      -- Triggering signals
      extTriggers : in slv(7 downto 0);

      -- Current Kpix state
      kpixState : in KpixStateOutType;  -- kpixClk

      -- Outputs
      acqControl : out AcquisitionControlType;

      -- Timestamp interface to event builder
      timestampAxisMaster : out AxiStreamMasterType;
      timestampAxisSlave  : in  AxiStreamSlaveType);

end entity AcquisitionControl;

architecture rtl of AcquisitionControl is

   constant CLOCKS_PER_USEC_C : natural := 20;  --integer(100 / CLOCK_PERIOD_G);  -- 1000?

   type RegType is record
      -- Config regs
      extTriggerSrc          : slv(2 downto 0);
      extTriggerEn           : sl;
      extTimestampSrc        : slv(2 downto 0);
      extTimestampEn         : sl;
      extAcquisitionSrc      : slv(2 downto 0);
      extAcquisitionEn       : sl;
      extStartSrc            : slv(2 downto 0);
      extStartEn             : sl;
      running                : sl;
      calibrate              : sl;
      axilWriteSlave         : AxiLiteWriteSlaveType;
      axilReadSlave          : AxiLiteReadSlaveType;
      -- Logic Regs
      triggerCounter         : slv(log2(CLOCKS_PER_USEC_C)-1 downto 0);
      triggerCountEnable     : sl;
      acquisitionCounter     : slv(7 downto 0);
      acquisitionCountEnable : sl;
      startCounter           : slv(7 downto 0);
      startCountEnable       : sl;
      timestampFifoWrEn      : sl;
      readoutPending         : sl;
      readoutCounter         : slv(7 downto 0);
      readoutCountEnable     : sl;
      extCounters            : slv31Array(7 downto 0);
      countReset             : sl;
      -- Outputs
      acqControl             : AcquisitionControlType;
   end record;

   constant REG_INIT_C : RegType := (
      extTriggerSrc          => (others => '0'),
      extTriggerEn           => '0',
      extTimestampSrc        => (others => '0'),
      extTimestampEn         => '0',
      extAcquisitionSrc      => (others => '0'),
      extAcquisitionEn       => '0',
      extStartSrc            => (others => '0'),
      extStartEn             => '0',
      running                => '0',
      calibrate              => '0',
      axilWriteSlave         => AXI_LITE_WRITE_SLAVE_INIT_C,
      axilReadSlave          => AXI_LITE_READ_SLAVE_INIT_C,
      triggerCounter         => (others => '0'),
      triggerCountEnable     => '0',
      acquisitionCounter     => (others => '0'),
      acquisitionCountEnable => '0',
      startCounter           => (others => '0'),
      startCountEnable       => '0',
      timestampFifoWrEn      => '0',
      readoutPending         => '0',
      readoutCounter         => (others => '0'),
      readoutCountEnable     => '0',
      extCounters            => (others => (others => '0')),
      countReset             => '0',
      acqControl             => ACQUISITION_CONTROL_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal extTriggerRise : slv(7 downto 0);
   signal axisMaster     : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal axisCtrl       : AxiStreamCtrlType;
   signal trigRateOut    : slv(31 downto 0);

begin

   EXT_SYNC_GEN : for i in 7 downto 0 generate
      Synchronizer : entity surf.SynchronizerEdge
         generic map (
            TPD_G => TPD_G)
         port map (
            clk         => clk200,
            rst         => rst200,
            dataIn      => extTriggers(i),
            dataOut     => open,
            risingEdge  => extTriggerRise(i),
            fallingEdge => open);
   end generate EXT_SYNC_GEN;

   U_SyncTrigRate_1 : entity surf.SyncTrigRate
      generic map (
         TPD_G          => TPD_G,
         COMMON_CLK_G   => true,
         ONE_SHOT_G     => false,
         IN_POLARITY_G  => '1',
         COUNT_EDGES_G  => true,
         REF_CLK_FREQ_G => 200.0E+6,
         REFRESH_RATE_G => 1.0,
         CNT_WIDTH_G    => 32)
      port map (
         trigIn      => r.acqControl.startAcquire,  -- [in]
         trigRateOut => trigRateOut,                -- [out]
         locClk      => clk200,                     -- [in]
         locRst      => rst200,                     -- [in]
         refClk      => clk200,                     -- [in]
         refRst      => rst200);                    -- [in]


   sync : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after TPD_G;
      end if;
   end process sync;


   comb : process (axilReadMaster, axilWriteMaster, axisCtrl, extTriggerRise, kpixState, r, rst200,
                   sysConfig, trigRateOut) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      v := r;

      v.countReset := '0';

      for i in 7 downto 0 loop
         if (extTriggerRise(i) = '1') then
            v.extCounters(i) := r.extCounters(i) + 1;
         end if;
      end loop;
      if (r.countReset = '1') then
         v.extCounters := (others => (others => '0'));
      end if;

      ----------------------------------------------------------------------------------------------
      -- AXI Lite
      ----------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"00", 0, v.extTriggerSrc);
      axiSlaveRegister(axilEp, X"00", 3, v.extTriggerEn);
      axiSlaveRegister(axilEp, x"04", 0, v.extTimestampSrc);
      axiSlaveRegister(axilEp, X"04", 3, v.extTimestampEn);
      axiSlaveRegister(axilEp, X"08", 0, v.extAcquisitionSrc);
      axiSlaveRegister(axilEp, X"08", 3, v.extAcquisitionEn);
      axiSlaveRegister(axilEp, X"0C", 0, v.extStartSrc);
      axiSlaveRegister(axilEp, X"0C", 3, v.extStartEn);
      axiSlaveRegister(axilEp, X"10", 0, v.running);

      axiSlaveRegisterR(axilEp, X"14", 0, r.acqControl.runTime);

      axiSlaveRegister(axilEp, X"20", 0, v.calibrate);


      axiSlaveRegister(axilEp, X"24", 0, v.countReset);
      for i in 7 downto 0 loop
         axiSlaveRegisterR(axilEp, X"30"+toSlv(i*4, 8), 0, r.extCounters(i));
      end loop;
      
      axiSlaveRegisterR(axilEp, X"50", 0, trigRateOut);

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      ------------------------------------------------------------------------------------------------
      -- External Trigger
      ------------------------------------------------------------------------------------------------
      if (r.running = '1' and r.extTriggerEn = '1' and
          extTriggerRise(conv_integer(r.extTriggerSrc)) = '1' and
          kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C and
          kpixState.trigInhibit = '0') then
         v.acqControl.trigger := '1';
         v.triggerCountEnable := '1';
         v.triggerCounter     := (others => '0');
      end if;

      if (r.triggerCountEnable = '1') then
         v.triggerCounter := r.triggerCounter + 1;
         if (r.triggerCounter = CLOCKS_PER_USEC_C) then
            v.triggerCounter     := (others => '0');
            v.triggerCountEnable := '0';
            v.acqControl.trigger := '0';
         end if;
      end if;

      ------------------------------------------------------------------------------------------------
      -- Trigger timestamp
      ------------------------------------------------------------------------------------------------
      v.timestampFifoWrEn := '0';
      if (r.running = '1' and r.extTimestampEn = '1' and
          extTriggerRise(conv_integer(r.extTimestampSrc)) = '1' and
          kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C and
          kpixState.trigInhibit = '0' and
          axisCtrl.pause = '0') then
         v.timestampFifoWrEn := '1';
         if (sysConfig.autoReadDisable = '1') then
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
         v.acqControl.startReadout := '1';
         v.readoutCountEnable      := '1';
         v.readoutCounter          := (others => '0');
      end if;

      if (r.readoutCountEnable = '1') then
         v.readoutCounter := r.readoutCounter + 1;
         if (uAnd(slv(r.readoutCounter)) = '1') then
            v.readoutCounter          := (others => '0');
            v.readoutCountEnable      := '0';
            v.acqControl.startReadout := '0';
         end if;
      end if;

      ------------------------------------------------------------------------------------------------
      -- Acquire Command
      ------------------------------------------------------------------------------------------------
      if (r.running = '1' and r.extAcquisitionEn = '1' and extTriggerRise(conv_integer(r.extAcquisitionSrc)) = '1') then
         v.acqControl.startAcquire   := '1';
         v.acqControl.startCalibrate := r.calibrate;
         v.acquisitionCountEnable    := '1';
         v.acquisitionCounter        := (others => '0');
      end if;

      if (r.acquisitionCountEnable = '1') then
         v.acquisitionCounter := r.acquisitionCounter + 1;
         if (uAnd(slv(r.acquisitionCounter)) = '1') then
            v.acquisitionCounter        := (others => '0');
            v.acquisitionCountEnable    := '0';
            v.acqControl.startAcquire   := '0';
            v.acqControl.startCalibrate := '0';
         end if;
      end if;

      ----------------------------------------------------------------------------------------------
      -- Start Command
      ----------------------------------------------------------------------------------------------
      v.acqControl.startRun := '0';
      v.acqControl.runTime  := r.acqControl.runTime + 1;
      if (r.running = '1' and r.extStartEn = '1' and extTriggerRise(conv_integer(r.extStartSrc)) = '1') then
         v.acqControl.startRun := '1';
         v.acqControl.runTime  := (others => '0');
      end if;

      ----------------------------------------------------------------------------------------------
      -- Reset and outputs
      ----------------------------------------------------------------------------------------------
      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      -- Outputs
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;
      acqControl     <= r.acqControl;
   end process comb;

   axisMaster.tValid              <= r.timestampFifoWrEn;
   axisMaster.tData(63 downto 32) <= r.acqControl.runTime(31 downto 0);  -- 48 bits is all that fits
   axisMaster.tData(15 downto 3)  <= kpixState.bunchCount;
   axisMaster.tData(2 downto 0)   <= kpixState.subCount;
   axisMaster.tKeep               <= (others => '1');
   U_AxiStreamFifoV2_1 : entity surf.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         MEMORY_TYPE_G       => "block",
         SYNTH_MODE_G        => "inferred",
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => 10,
         FIFO_PAUSE_THRESH_G => 2**10-1,
         SLAVE_AXI_CONFIG_G  => TIMESTAMP_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => TIMESTAMP_AXIS_CONFIG_C)
      port map (
         sAxisClk    => clk200,                                          -- [in]
         sAxisRst    => rst200,                                          -- [in]
         sAxisMaster => axisMaster,                                      -- [in]
         sAxisCtrl   => axisCtrl,                                        -- [out]
         mAxisClk    => clk200,                                          -- [in]
         mAxisRst    => rst200,                                          -- [in]
         mAxisMaster => timestampAxisMaster,                             -- [out]
         mAxisSlave  => timestampAxisSlave);                             -- [in]

end architecture rtl;
