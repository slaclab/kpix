-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Trigger.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2018-05-09
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;

use work.KpixLocalPkg.all;
use work.KpixPkg.all;

entity Trigger is

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
      kpixConfig : in KpixConfigType;

      -- Triggering signals
      extTriggers : in slv(7 downto 0);
      opCode      : in slv(7 downto 0);
      opCodeEn    : in sl;

      kpixState : in KpixStateOutType;  -- kpixClk

      -- Outputs
      trigger        : out sl;
      startAcquire   : out sl;
      startCalibrate : out sl;
      startReadout   : out sl;

      -- Timestamp interface to event builder
      timestampAxisMaster : out AxiStreamMasterType;
      timestampAxisSlave  : in  AxiStreamSlaveType);

end entity Trigger;

architecture rtl of Trigger is

   constant CLOCKS_PER_USEC_C : natural := integer(100 / CLOCK_PERIOD_G);  -- 1000?

   type RegType is record
      -- Config regs
      extTriggerSrc      : slv(2 downto 0);
      extTimestampSrc    : slv(2 downto 0);
      extAcquisitionSrc  : slv(2 downto 0);
      acquisitionSw      : sl;
      calibrate          : sl;
      axilWriteSlave     : AxiLiteWriteSlaveType;
      axilReadSlave      : AxiLiteReadSlaveType;
      -- Logic Regs
      triggerCounter     : slv(log2(CLOCKS_PER_USEC_C)-1 downto 0);
      triggerCountEnable : sl;
      startCounter       : slv(7 downto 0);
      startCountEnable   : sl;
      timestampFifoWrEn  : sl;
      readoutPending     : sl;
      readoutCounter     : slv(7 downto 0);
      readoutCountEnable : sl;
      -- Outputs
      trigger            : sl;
      startAcquire       : sl;
      startCalibrate     : sl;
      startReadout       : sl;
   end record;

   constant REG_INIT_C : RegType := (
      extTriggerSrc      => (others => '0'),
      extTimestampSrc    => (others => '0'),
      extAcquisitionSrc  => (others => '0'),
      acquisitionSw      => '1',
      calibrate          => '0',
      axilWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C,
      axilReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      triggerCounter     => (others => '0'),
      triggerCountEnable => '0',
      startCounter       => (others => '0'),
      startCountEnable   => '0',
      timestampFifoWrEn  => '0',
      readoutPending     => '0',
      readoutCounter     => (others => '0'),
      readoutCountEnable => '0',
      trigger            => '0',
      startAcquire       => '0',
      startCalibrate     => '0',
      startReadout       => '0');


   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal extTriggerRise : slv(7 downto 0);
   signal axisMaster     : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal axisCtrl       : AxiStreamCtrlType;

begin

   EXT_SYNC_GEN : for i in 7 downto 0 generate
      Synchronizer : entity work.SynchronizerEdge
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


   sync : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after DELAY_G;
      end if;
   end process sync;


   comb : process (autoReadDisableSync, axilReadMaster, axilWriteMaster, axisCtrl, extTriggerRise,
                   kpixState, opCode, opCodeEn, r, rst200, triggerRegsInSync) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      v := r;

      ----------------------------------------------------------------------------------------------
      -- AXI Lite
      ----------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"00", 0, v.extTriggerSrc);
      axiSlaveRegister(axilEp, x"04", 0, v.extTimestampSrc);
      axiSlaveRegister(axilEp, X"08", 0, v.extAcquisitionSrc);
      axiSlaveRegister(axilEp, X"08", 31, v.acquisitionSw);
      axiSlaveRegister(axilEp, X"0C", 0, v.calibrate);

      axiSlaveDefault(axilEp, v.axiWriteSlave, v.axiReadSlave, AXI_RESP_DECERR_C);

      ------------------------------------------------------------------------------------------------
      -- External Trigger
      ------------------------------------------------------------------------------------------------
      if (extTriggerRise(conv_integer(triggerRegsInSync.extTriggerSrc)) = '1' and
          kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C and
          kpixState.trigInhibit = '0') then
         v.trigger            := '1';
         v.triggerCountEnable := '1';
         v.triggerCounter     := (others => '0');
      end if;

      if (r.triggerCountEnable = '1') then
         v.triggerCounter := r.triggerCounter + 1;
         if (r.triggerCounter = CLOCKS_PER_USEC_C) then
            v.triggerCounter     := (others => '0');
            v.triggerCountEnable := '0';
            v.trigger            := '0';
         end if;
      end if;

      ------------------------------------------------------------------------------------------------
      -- Trigger timestamp
      ------------------------------------------------------------------------------------------------
      v.timestampFifoWrEn := '0';
      if (extTriggerRise(conv_integer(triggerRegsInSync.extTimestampSrc)) = '1' and
          kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C and
          kpixState.trigInhibit = '0' and
          axisCtrl.full = '0') then
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
         v.readoutPending     := '0';
         v.startReadout       := '1';
         v.readoutCountEnable := '1';
         v.readoutCounter     := (others => '0');
      end if;

      if (r.readoutCountEnable = '1') then
         v.readoutCounter := r.readoutCounter + 1;
         if (uAnd(slv(r.readoutCounter)) = '1') then
            v.readoutCounter     := (others => '0');
            v.readoutCountEnable := '0';
            v.startReadout       := '0';
         end if;
      end if;

      ------------------------------------------------------------------------------------------------
      -- Acquire Command
      -- Source could be software (through FrontEndCmdCntl), EVR, or external input
      -- Selected by Front End Register triggerRegsIn.acquisitionSrc
      ------------------------------------------------------------------------------------------------
      if ((r.acquisitionSw = '1' and
           opCodeEn = '1' and opCode = TRIGGER_OPCODE_C)
          or
          (r.acquisitionSw = '0' and
           extTriggerRise(conv_integer(r.extAcquisitionSrc)) = '1'))
      then
         v.startAcquire     := '1';
         v.startCalibrate   := r.calibrate;
         v.startCountEnable := '1';
         v.startCounter     := (others => '0');
      end if;

      if (r.startCountEnable = '1') then
         v.startCounter := r.startCounter + 1;
         if (uAnd(slv(r.startCounter)) = '1') then
            v.startCounter     := (others => '0');
            v.startCountEnable := '0';
            v.startAcquire     := '0';
            v.startCalibrate   := '0';
         end if;
      end if;

      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      -- Outputs
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;
      trigger        <= r.trigger;
      startAcquire   <= r.startAcquire;
      startCalibrate <= r.startCalibrate;
      startReadout   <= r.startReadout;
   end process comb;

   axisMaster.tValid             <= r.timestampFifoWrEn;
   axisMaster.tData(15 downto 3) <= kpixState.bunchCount;
   axisMaster.tData(2 downto 0)  <= kpixState.subCount;
   axisMaster.tKeep              <= (others => '1');
   U_AxiStreamFifoV2_1 : entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => 10,
         FIFO_PAUSE_THRESH_G => 2**10-1,
         SLAVE_AXI_CONFIG_G  => TIMESTAMP_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => TIMESTAMP_AXIS_CONFIG_C)
      port map (
         sAxisClk    => clk200,               -- [in]
         sAxisRst    => rst200,               -- [in]
         sAxisMaster => axisMaster,           -- [in]
         sAxisCtrl   => axisCtrl,             -- [out]
         mAxisClk    => clk200,               -- [in]
         mAxisRst    => rst200,               -- [in]
         mAxisMaster => timestampAxisMaster,  -- [out]
         mAxisSlave  => timestampAxisSlave);  -- [in]

end architecture rtl;
