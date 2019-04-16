-------------------------------------------------------------------------------
-- Title      : Event Builder
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Builds data stream from multiple KPIXes into event frames
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
      kpixDataRxMasters : in  AxiStreamMasterArray(NUM_KPIX_MODULES_G downto 0);
      kpixDataRxSlaves  : out AxiStreamSlaveArray(NUM_KPIX_MODULES_G downto 0);

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
      timestamp          : slv(63 downto 0);
      eventNumber        : slv(31 downto 0);
      newAcquire         : sl;
      burn               : sl;
      state              : StateType;
      counter            : slv(15 downto 0);  -- Generic counter for stalling in a state
      dataDone           : slv(NUM_KPIX_MODULES_G downto 0);
      kpixIndex          : integer range 0 to NUM_KPIX_MODULES_G;
      kpixDataRxSlaves   : AxiStreamSlaveArray(NUM_KPIX_MODULES_G downto 0);
      timestampAxisSlave : AxiStreamSlaveType;
      ebAxisMaster       : AxiStreamMasterType;
   end record;

   constant REG_INIT_C : RegType := (
      timestamp          => (others => '0'),
      eventNumber        => (others => '1'),
      newAcquire         => '0',
      burn               => '0',
      state              => WAIT_ACQUIRE_S,
      counter            => (others => '0'),
      dataDone           => (others => '0'),
      kpixIndex          => 0,
      kpixDataRxSlaves   => (others => AXI_STREAM_SLAVE_INIT_C),
      timestampAxisSlave => AXI_STREAM_SLAVE_INIT_C,
      ebAxisMaster       => axiStreamMasterInit(EB_DATA_AXIS_CONFIG_C));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (acqControl, ebAxisCtrl, kpixDataRxMasters, kpixState, r, rst200, sysConfig,
                   timestampAxisMaster) is
      variable v : RegType;

   begin
      v := r;


      ------------------------------------------------------------------------------------------------
      -- FIFO WR Logic
      ------------------------------------------------------------------------------------------------
      -- Latch trigger
      if (r.newAcquire = '0' and acqControl.startAcquire = '1' and r.state = WAIT_ACQUIRE_S) then
         v.timestamp   := acqControl.runTime;
         v.eventNumber := r.eventNumber + 1;
         v.newAcquire  := '1';
      end if;

      -- Reset event number to 0 at start of run
      if (acqControl.startRun = '1') then
         v.eventNumber := (others => '0');
      end if;

      -- Registers that are 0 by default.
      v.ebAxisMaster              := axiStreamMasterInit(EB_DATA_AXIS_CONFIG_C);
      v.kpixDataRxSlaves          := (others => AXI_STREAM_SLAVE_INIT_C);
      v.timestampAxisSlave.tready := '0';
      v.counter                   := (others => '0');
      v.dataDone                  := (others => '0');

      -- Determines which kpix to look for data from.
      -- Increments every cycle so that kpixes are read in round robin fashion.
      v.kpixIndex := r.kpixIndex + 1;
      if (r.kpixIndex = NUM_KPIX_MODULES_G) then
         v.kpixIndex := 0;
      end if;

      case r.state is
         when WAIT_ACQUIRE_S =>
            v.burn := '0';
            if (r.newAcquire = '1') then
               v.burn                            := ebAxisCtrl.pause;
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
            if (r.counter = 1) then
               v.ebAxisMaster.tData(0) := r.burn;
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
               v.ebAxisMaster.tValid              := not r.burn;
               v.ebAxisMaster.tData(63 downto 60) := "0010";
               -- bunchcount and subcount
               v.ebAxisMaster.tData(59 downto 32) := timestampAxisMaster.tData(27 downto 0);
               -- runTime
               v.ebAxisMaster.tData(31 downto 0)  := timestampAxisMaster.tData(63 downto 32);
               -- Flip it because everything is expected this way
               v.ebAxisMaster.tData(63 downto 0)  := v.ebAxisMaster.tData(31 downto 0) & v.ebAxisMaster.tData(63 downto 32);
            else
               v.state := WAIT_READOUT_S;
            end if;

         when WAIT_READOUT_S =>
            if (kpixState.readoutState = KPIX_READOUT_DATA_STATE_C) then
               v.state := GATHER_DATA_S;  -- was CHECK_BUSY_S
            end if;

         when GATHER_DATA_S =>
            v.dataDone := r.dataDone;

            -- kpixCounter increments every clock.
            -- Check to see if the KpixDataRx module selected by kpixCounter has data.
            if (kpixDataRxMasters(r.kpixIndex).tvalid = '1') then
               v.kpixDataRxSlaves(r.kpixIndex).tReady := '1';
               v.ebAxisMaster.tValid                  := not r.burn;
               v.ebAxisMaster.tData(63 downto 0)      := kpixDataRxMasters(r.kpixIndex).tdata(63 downto 0);

               -- Ignore data and temperature samples from the local kpix
               -- Only send the runtime samples through
               if (r.kpixIndex = NUM_KPIX_MODULES_G and v.ebAxisMaster.tData(63 downto 60) = "0000") then
                  v.ebAxisMaster.tValid := '0';
               end if;

               if (kpixDataRxMasters(r.kpixIndex).tLast = '1') then
                  v.dataDone(r.kpixIndex) := '1';
               end if;
            end if;

            -- Check if done
            if (r.dataDone(NUM_KPIX_MODULES_G-1 downto 0) = sysConfig.kpixEnable(NUM_KPIX_MODULES_G-1 downto 0) and
                (r.dataDone(NUM_KPIX_MODULES_G) = '1')) then
               v.ebAxisMaster.tLast              := '1';
               v.ebAxisMaster.tValid             := '1';
               v.ebAxisMaster.tKeep(15 downto 0) := X"000F";  -- Last word has only 4 bytes
               v.state                           := WAIT_ACQUIRE_S;
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
