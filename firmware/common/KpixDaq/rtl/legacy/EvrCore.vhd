-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : EventReceiver.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-07-10
-- Last update: 2020-04-13
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

library kpix;
use kpix.EvrCorePkg.all;

entity EvrCore is

   generic (
      TPD_G : time := 1 ns);

   port (
      -- Interface to tranceiver
      evrRecClk : in sl;
      evrRst    : in sl;
      phyIn     : in EvrPhyType;

      -- Decoded EVR data
      evrOut : out EvrOutType;

      -- Register interface runs on separate system clock
      sysClk          : in  sl;
      sysRst          : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      sysEvrOut       : out EvrOutType);  -- Decoded EVR data sync'd to sysclk

end entity EvrCore;

architecture rtl of EvrCore is

   -------------------------------------------------------------------------------------------------
   -- Config Registers
   -------------------------------------------------------------------------------------------------
   type EvrConfigType is record
      enabled          : sl;
      triggerEventCode : slv(7 downto 0);
      triggerDelay     : slv(15 downto 0);
      triggerWidth     : slv(15 downto 0);
      resetErrors      : sl;
   end record EvrConfigType;

   constant EVR_CONFIG_INIT_C : EvrConfigType := (
      enabled          => '1',
      triggerEventCode => X"28",
      triggerDelay     => X"0004",
      triggerWidth     => X"0004",
      resetErrors      => '0');

   -------------------------------------------------------------------------------------------------
   -- SysClk Registers + Signals
   -------------------------------------------------------------------------------------------------
   type SysRegType is record
      resetErrorsHold  : slv(3 downto 0);
      evrConfig        : EvrConfigType;
      axilWriteSlave   : AxiLiteWriteSlaveType;
      axilReadSlave    : AxiLiteReadSlaveType;
   end record SysRegType;

   constant SYS_REG_INIT_C : SysRegType := (
      resetErrorsHold  => (others => '0'),
      evrConfig        => EVR_CONFIG_INIT_C,
      axilWriteSlave   => AXI_LITE_WRITE_SLAVE_INIT_C,
      axilReadSlave    => AXI_LITE_READ_SLAVE_INIT_C);

   signal sysR         : SysRegType := SYS_REG_INIT_C;
   signal sysRin       : SysRegType;
   signal sysEvrOutInt : EvrOutType;    -- Evr outputs sync'd to sysclk


   -------------------------------------------------------------------------------------------------
   -- Evr Clk Registers + Signals
   -------------------------------------------------------------------------------------------------
   type MainRegType is record
      secondsTmp  : slv(31 downto 0);
      counter     : slv(15 downto 0);
      trigDelayEn : sl;
      trigHoldEn  : sl;
      evrOut      : EvrOutType;
   end record MainRegType;

   constant MAIN_REG_INIT_C : MainRegType := (
      secondsTmp  => (others => '0'),
      counter     => (others => '0'),
      trigDelayEn => '0',
      trigHoldEn  => '0',
      evrOut      => EVR_OUT_INIT_C);

   signal mainR         : MainRegType := MAIN_REG_INIT_C;
   signal mainRin       : MainRegType;
   signal mainEvrConfig : EvrConfigType;  -- Evr intf refisters sync'd to evr clock


begin

   -------------------------------------------------------------------------------------------------
   -- Register Interface Logic (sysClk)
   -------------------------------------------------------------------------------------------------
   sysComb : process (axilReadMaster, axilWriteMaster, sysEvrOutInt, sysR) is
      variable v      : SysRegType;
      variable axilEp : AxiLiteEndpointType;

   begin
      v := sysR;

      v.evrConfig.resetErrors := sysR.resetErrorsHold(0);
      v.resetErrorsHold       := '0' & sysR.resetErrorsHold(3 downto 1);

      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"00", 0, v.evrConfig.enabled);
      axiSlaveRegister(axilEp, x"04", 0, v.evrConfig.triggerDelay);
      axiSlaveRegister(axilEp, x"08", 0, v.evrConfig.triggerWidth);
      axiSlaveRegister(axilEp, x"0C", 0, v.evrConfig.triggerEventCode);
      axiSlaveRegisterR(axilEp, x"10", 0, sysEvrOutInt.errors);
      axiSlaveRegister(axilEp, X"14", 0, v.resetErrorsHold);
      axiSlaveRegisterR(axilEp, x"18", 0, sysEvrOutInt.seconds);
      axiSlaveRegisterR(axilEp, x"1C", 0, sysEvrOutInt.offset);

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      sysRin <= v;

      axilReadSlave  <= sysR.axilReadSlave;
      axilWriteSlave <= sysR.axilWriteSlave;

   end process sysComb;

   sysSeq : process (sysClk) is
   begin
      if (rising_edge(sysClk)) then
         if (sysRst = '1') then
            sysR <= SYS_REG_INIT_C after TPD_G;
         else
            sysR <= sysRin after TPD_G;
         end if;
      end if;
   end process sysSeq;

   -------------------------------------------------------------------------------------------------
   -- Synchronize EVR config registers to EVR clock
   -------------------------------------------------------------------------------------------------
   SynchronizerFifo_EvrConfig : entity surf.SynchronizerFifo
      generic map (
         TPD_G         => TPD_G,
         MEMORY_TYPE_G => "distributed",
         DATA_WIDTH_G  => 42)
      port map (
         rst                => sysRst,
         wr_clk             => sysClk,
         din(41)            => sysR.evrConfig.resetErrors,
         din(40)            => sysR.evrConfig.enabled,
         din(39 downto 32)  => sysR.evrConfig.triggerEventCode,
         din(31 downto 16)  => sysR.evrConfig.triggerDelay,
         din(15 downto 0)   => sysR.evrConfig.triggerWidth,
         rd_clk             => evrRecClk,
         valid              => open,
         dout(41)           => mainEvrConfig.resetErrors,
         dout(40)           => mainEvrConfig.enabled,
         dout(39 downto 32) => mainEvrConfig.triggerEventCode,
         dout(31 downto 16) => mainEvrConfig.triggerDelay,
         dout(15 downto 0)  => mainEvrConfig.triggerWidth);


   -------------------------------------------------------------------------------------------------
   -- Synchronize EVR out to sysClk
   -------------------------------------------------------------------------------------------------
   SynchronizerFifo_EvrOut : entity surf.SynchronizerFifo
      generic map (
         TPD_G         => TPD_G,
         MEMORY_TYPE_G => "distributed",
         DATA_WIDTH_G  => 97)
      port map (
         rst                => evrRst,
         wr_clk             => evrRecClk,
         din(96)            => mainR.evrOut.trigger,
         din(95 downto 80)  => mainR.evrOut.errors,
         din(79 downto 48)  => mainR.evrOut.offset,
         din(47 downto 16)  => mainR.evrOut.seconds,
         din(15 downto 8)   => mainR.evrOut.dataStream,
         din(7 downto 0)    => mainR.evrOut.eventStream,
         rd_clk             => sysClk,
         valid              => open,
         dout(96)           => sysEvrOutInt.trigger,
         dout(95 downto 80) => sysEvrOutInt.errors,
         dout(79 downto 48) => sysEvrOutInt.offset,
         dout(47 downto 16) => sysEvrOutInt.seconds,
         dout(15 downto 8)  => sysEvrOutInt.dataStream,
         dout(7 downto 0)   => sysEvrOutInt.eventStream);

   sysEvrOut <= sysEvrOutInt;

   -------------------------------------------------------------------------------------------------
   -- EVR Event Decoding
   -------------------------------------------------------------------------------------------------
   evrComb : process (mainR, phyIn, mainEvrConfig) is
      variable v : MainRegType;
   begin
      v := mainR;


      -- Extract event and data streams
      v.evrOut.eventStream := phyIn.rxData(7 downto 0);
      v.evrOut.dataStream  := phyIn.rxData(15 downto 8);

      ----------------------------------------------------------------------------------------------
      -- Decode time from event stream
      -- Increment offset every cycle
      -- On receit of x7d, clear offset, move secondsTmp to output register
      -- On recept of x71, shift a 1 into secondsTmp
      -- On recept of x70, shift a 0 into secondsTmp
      ----------------------------------------------------------------------------------------------
      v.evrOut.offset := mainR.evrOut.offset + 1;
      if (mainR.evrOut.eventStream = X"7d") then
         v.secondsTmp     := (others => '0');
         v.evrOut.seconds := mainR.secondsTmp;
         v.evrOut.offset  := (others => '0');
      elsif (mainR.evrOut.eventStream = X"71") then
         v.secondsTmp := mainR.secondsTmp(30 downto 0) & '1';
      elsif (mainR.evrOut.eventStream = X"70") then
         v.secondsTmp := mainR.secondsTmp(30 downto 0) & '0';
      end if;


      ----------------------------------------------------------------------------------------------
      -- Look for trigger codes
      ----------------------------------------------------------------------------------------------
      if (mainEvrConfig.enabled = '1') then
         if (mainR.evrOut.eventStream = mainEvrConfig.triggerEventCode) then
            v.trigDelayEn := '1';
         end if;
      end if;

      if (mainR.trigDelayEn = '1' or mainR.trigHoldEn = '1') then
         v.counter := mainR.counter + 1;
      else
         v.counter := (others => '0');
      end if;

      if (mainR.counter = mainEvrConfig.triggerDelay and mainR.trigDelayEn = '1') then
         v.counter        := (others => '0');
         v.evrOut.trigger := '1';
         v.trigHoldEn     := '1';
         v.trigDelayEn    := '0';
      end if;

      if (mainR.counter = mainEvrConfig.triggerWidth and mainR.trigHoldEn = '1') then
         v.counter        := (others => '0');
         v.evrOut.trigger := '0';
         v.trigHoldEn     := '0';
         v.trigDelayEn    := '0';
      end if;

      ----------------------------------------------------------------------------------------------
      -- Count Errors
      ----------------------------------------------------------------------------------------------
      if ((uOr(phyIn.decErr) or uOr(phyIn.dispErr)) = '1') then
         v.evrOut.errors := mainR.evrOut.errors + 1;
      end if;
      if (mainEvrConfig.resetErrors = '1') then
         v.evrOut.errors := (others => '0');
      end if;

      mainRin <= v;
      evrOut  <= mainR.evrOut;

   end process evrComb;

   mainSeq : process (evrRecClk) is
   begin
      if (rising_edge(evrRecClk)) then
         if (evrRst = '1') then
            mainR <= MAIN_REG_INIT_C after TPD_G;
         else
            mainR <= mainRin after TPD_G;
         end if;
      end if;
   end process mainSeq;


end architecture rtl;
