-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2018-10-11
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
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

use work.KpixPkg.all;
use work.KpixLocalPkg.all;

entity EventBuilder is

   generic (
      TPD_G              : time    := 1 ns;
      NUM_KPIX_MODULES_G : natural := 4);

   port (
      clk200 : in sl;
      rst200 : in sl;

      -- Front End Registers
      sysConfig : in SysConfigType;

      -- Trigger Interface
      acqControl : in AcquisitionControlType;

      -- Kpix Local Interface
      kpixState : in KpixStateOutType;

      -- Kpix clock info
      kpixClkPreRise : in sl;

      -- Trigger Timestamp Interface
      timestampAxisMaster : in  AxiStreamMasterType;
      timestampAxisSlave  : out AxiStreamSlaveType;


      -- KPIX data interface
      kpixDataRxMasters : in  AxiStreamMasterArray(NUM_KPIX_MODULES_G-1 downto 0);
      kpixDataRxSlaves  : out AxiStreamSlaveArray(NUM_KPIX_MODULES_G-1 downto 0);

      -- Event stream out
      ebAxisMaster : out AxiStreamMasterType;
      ebAxisCtrl   : in  AxiStreamCtrlType);


end entity EventBuilder;

architecture rtl of EventBuilder is


   type StateType is (
      WAIT_ACQUIRE_S,
      WRITE_HEADER_S,
      WAIT_DIGITIZE_S,
      READ_TIMESTAMPS_S,
      WAIT_READOUT_S,
      GATHER_DATA_S);

   type RegType is record
      timestampCount     : slv(63 downto 0);
      timestamp          : slv(63 downto 0);
      eventNumber        : slv(31 downto 0);
      newAcquire         : sl;
      state              : StateType;
      counter            : slv(15 downto 0);  -- Generic counter for stalling in a state
      activeModules      : slv(NUM_KPIX_MODULES_G-1 downto 0);
      dataDone           : slv(NUM_KPIX_MODULES_G-1 downto 0);
      kpixCounter        : slv(log2(NUM_KPIX_MODULES_G)-1 downto 0);
      kpixDataRxSlaves   : AxiStreamSlaveArray(NUM_KPIX_MODULES_G-1 downto 0);
      timestampAxisSlave : AxiStreamSlaveType;
      ebAxisMaster       : AxiStreamMasterType;
   end record;

   constant REG_INIT_C : RegType := (
      timestampCount     => (others => '0'),
      timestamp          => (others => '0'),
      eventNumber        => (others => '1'),
      newAcquire         => '0',
      state              => WAIT_ACQUIRE_S,
      counter            => (others => '0'),
      activeModules      => (others => '0'),
      dataDone           => (others => '0'),
      kpixCounter        => (others => '0'),
      kpixDataRxSlaves   => (others => AXI_STREAM_SLAVE_INIT_C),
      timestampAxisSlave => AXI_STREAM_SLAVE_INIT_C,
      ebAxisMaster       => axiStreamMasterInit(EB_DATA_AXIS_CONFIG_C));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (acqControl, ebAxisCtrl, kpixDataRxMasters, kpixState, r, rst200, sysConfig,
                   timestampAxisMaster) is
      variable v              : RegType;
      variable kpixCounterInt : integer;

   begin
      v := r;


      ------------------------------------------------------------------------------------------------
      -- FIFO WR Logic
      ------------------------------------------------------------------------------------------------
      -- Latch trigger
      v.timestampCount := r.timestampCount + 1;
      if (r.newAcquire = '0' and acqControl.startAcquire = '1' and r.state = WAIT_ACQUIRE_S) then
         v.timestamp   := r.timestampCount;
         v.eventNumber := r.eventNumber + 1;
         v.newAcquire  := '1';
      end if;

      if (sysConfig.kpixReset = '1') then
         v.eventNumber := (others => '0');
      end if;

      -- Registers that are 0 by default.
      v.ebAxisMaster              := axiStreamMasterInit(EB_DATA_AXIS_CONFIG_C);
      v.kpixDataRxSlaves          := (others => AXI_STREAM_SLAVE_INIT_C);
      v.timestampAxisSlave.tready := '0';
      v.counter                   := (others => '0');
      v.dataDone                  := (others => '0');
      v.activeModules             := (others => '0');

      -- Determines which kpix to look for data from.
      -- Increments every cycle so that kpixes are read in round robin fashion.
      v.kpixCounter := r.kpixCounter + 1;
      if (r.kpixCounter = NUM_KPIX_MODULES_G-1) then
         v.kpixCounter := (others => '0');
      end if;
      kpixCounterInt := conv_integer(r.kpixCounter);

      -- Reset ack when valid falls
--       for i in NUM_KPIX_MODULES_G-1 downto 0 loop
--          if (kpixDataRxOut(i).valid = '0') then
--             v.kpixDataRxIn(i).ack := '0';
--          end if;
--       end loop;

      case r.state is
         when WAIT_ACQUIRE_S =>
            if (r.newAcquire = '1' and ebAxisCtrl.pause = '0') then
               v.newAcquire                      := '0';
               v.state                           := WRITE_HEADER_S;
               -- Write Event number and timestamp in SOF
               v.ebAxisMaster.tValid             := '1';
               v.ebAxisMaster.tData(63 downto 0) := r.timestamp(31 downto 0) & r.eventNumber;
               ssiSetUserSof(EB_DATA_AXIS_CONFIG_C, v.ebAxisMaster, '1');
            end if;

         when WRITE_HEADER_S =>
            v.counter             := r.counter + 1;
            v.ebAxisMaster.tValid := '1';
            -- Place EVR data in header if it is the acqusition trigger source
--               if (triggerRegsIn.acquisitionSrc = TRIGGER_ACQ_EVR_C and r.counter = 0) then
--                  writeFifo(evrOut.offset & evrOut.seconds);
--               else

--               end if;
            if (r.counter = 0) then
               v.ebAxisMaster.tData(31 downto 0) := r.timestamp(63 downto 32);
            end if;
            if (r.counter = 2) then
               v.state := WAIT_DIGITIZE_S;
            end if;


         when WAIT_DIGITIZE_S =>
            -- Must wait until acquire state is done before reading timestamps
            if (kpixState.analogState = KPIX_ANALOG_DIG_STATE_C) then
               if (sysConfig.autoReadDisable = '1' and timestampAxisMaster.tvalid = '0') then
                  -- No data, Close frame
                  v.ebAxisMaster.tvalid := '1';
                  v.ebAxisMaster.tLast  := '1';
                  v.state               := WAIT_ACQUIRE_S;
               else
                  v.state := READ_TIMESTAMPS_S;
               end if;
            end if;

         when READ_TIMESTAMPS_S =>
            if (timestampAxisMaster.tvalid = '1') then
               v.timestampAxisSlave.tReady        := '1';
               v.ebAxisMaster.tValid              := '1';
               v.ebAxisMaster.tData(63 downto 60) := "0010";
               v.ebAxisMaster.tData(60 downto 32) := (others => '0');
               v.ebAxisMaster.tData(31 downto 29) := "000";
               v.ebAxisMaster.tData(28 downto 16) := timestampAxisMaster.tData(15 downto 3);  -- bunch count
               v.ebAxisMaster.tData(15 downto 3)  := (others => '0');
               v.ebAxisMaster.tData(2 downto 0)   := timestampAxisMaster.tData(2 downto 0);  -- subCount writeFifo(formatTimestamp);
               -- Flip it because everything is expected this way
               v.ebAxisMaster.tData(63 downto 0)  := v.ebAxisMaster.tData(31 downto 0) & v.ebAxisMaster.tData(63 downto 32);
            else
               v.state := WAIT_READOUT_S;
            end if;

         when WAIT_READOUT_S =>
            if (kpixState.readoutState = KPIX_READOUT_DATA_STATE_C) then
               v.state := GATHER_DATA_S;  -- was CHECK_BUSY_S
            end if;

--          when CHECK_BUSY_S =>
--             -- Wait X kpixClk cycles for busy signals
--             -- Tells which modules are active
--             v.counter := r.counter;
--             if (kpixClkRise = '1') then
--                v.counter := r.counter + 1;
--             end if;
--             if (r.counter = 65532) then  -- Wait some amount of time for data to arrive
--                -- No busy signals detected at all
--                v.state := WAIT_ACQUIRE_S;
--                writeFifo(X"0123456789abcdef", EOF_C);
--             end if;
--             for i in NUM_KPIX_MODULES_G-1 downto 0 loop
--                if (kpixDataRxOut(i).busy = '1') then
--                   v.activeModules(i) := '1';
--                end if;
--                -- Due to clock crossing, busy signals may arrive 1 cycle appart
--                -- Checking r.activeModules rather than busy inputs assures that
--                -- any late arriving busy signals will set the corresponding activeModules
--                -- signal correctly.
--                if (r.activeModules(i) = '1') then
--                   v.state := GATHER_DATA_S;
--                end if;
--             end loop;

         when GATHER_DATA_S =>
            v.dataDone := r.dataDone;

            -- kpixCounter increments every clock.
            -- Check to see if the KpixDataRx module selected by kpixCounter has data.
            if (kpixDataRxMasters(kpixCounterInt).tvalid = '1') then
               v.kpixDataRxSlaves(kpixCounterInt).tReady := '1';
               v.ebAxisMaster.tValid                     := '1';
               v.ebAxisMaster.tData(63 downto 0)         := kpixDataRxMasters(kpixCounterInt).tdata(63 downto 0);

               if (kpixDataRxMasters(kpixCounterInt).tLast = '1') then
                  v.dataDone(kpixCounterInt) := '1';
               end if;
            end if;

            -- Check if done
            if (r.dataDone = sysConfig.kpixEnable(NUM_KPIX_MODULES_G-1 downto 0)) then
               v.ebAxisMaster.tLast  := '1';
               v.ebAxisMaster.tValid := '1';
               v.ebAxisMaster.tKeep  := X"000F";  -- Last word has only 4 bytes
               v.state               := WAIT_ACQUIRE_S;
            end if;

      end case;

      timestampAxisSlave <= v.timestampAxisSlave;
      kpixDataRxSlaves   <= v.kpixDataRxSlaves;

      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      ebAxisMaster <= r.ebAxisMaster;

   end process comb;

   sync : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after TPD_G;
      end if;
   end process sync;


end architecture rtl;
