-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : EventReceiver.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-07-10
-- Last update: 2013-07-31
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.StdRtlPkg.all;
use work.EvrCorePkg.all;

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
      sysClk           : in  sl;
      sysRst           : in  sl;
      evrConfigIntfIn  : in  EvrConfigIntfInType;
      evrConfigIntfOut : out EvrConfigIntfOutType;
      sysEvrOut        : out EvrOutType  -- Decoded EVR data sync'd to sysclk
      );

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
   constant EVR_CONFIG_INIT_C : EvrConfigType :=
      (enabled          => '1',
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
      evrConfigIntfOut : EvrConfigIntfOutType;
   end record SysRegType;
   constant SYS_REG_INIT_C : SysRegType :=
      (resetErrorsHold  => (others => '0'),
       evrConfig        => EVR_CONFIG_INIT_C,
       evrConfigIntfOut => EVR_CONFIG_INTF_OUT_INIT_C);

   signal sysR, sysRin : SysRegType := SYS_REG_INIT_C;
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
   constant MAIN_REG_INIT_C : MainRegType :=
      (secondsTmp  => (others => '0'),
       counter     => (others => '0'),
       trigDelayEn => '0',
       trigHoldEn  => '0',
       evrOut      => EVR_OUT_INIT_C);

   signal mainR, mainRin : MainRegType := MAIN_REG_INIT_C;
   signal mainEvrConfig  : EvrConfigType;  -- Evr intf refisters sync'd to evr clock


begin

   -------------------------------------------------------------------------------------------------
   -- Register Interface Logic (sysClk)
   -------------------------------------------------------------------------------------------------
   sysComb : process (sysR, evrConfigIntfIn, sysEvrOutInt) is
      variable v : SysRegType;
   begin
      v := sysR;

      v.evrConfigIntfOut.ack     := '0';
      v.evrConfigIntfOut.dataOut := (others => '0');

      v.evrConfig.resetErrors := sysR.resetErrorsHold(0);
      v.resetErrorsHold       := '0' & sysR.resetErrorsHold(3 downto 1);

      if (evrConfigIntfIn.req = '1') then
         v.evrConfigIntfOut.ack := '1';
         case (evrConfigIntfIn.addr) is

            when X"00" =>
               v.evrConfigIntfOut.dataOut(0) := sysR.evrConfig.enabled;
               if (evrConfigIntfIn.wrEna = '1') then
                  v.evrConfig.enabled := evrConfigIntfIn.dataIn(0);
               end if;

            when X"01" =>
               v.evrConfigIntfOut.dataOut(15 downto 0) := sysR.evrConfig.triggerDelay;
               if (evrConfigIntfIn.wrEna = '1') then
                  v.evrConfig.triggerDelay := evrConfigIntfIn.dataIn(15 downto 0);
               end if;
               
            when X"02" =>
               v.evrConfigIntfOut.dataOut(15 downto 0) := sysR.evrConfig.triggerWidth;
               if (evrConfigIntfIn.wrEna = '1') then
                  v.evrConfig.triggerWidth := evrConfigIntfIn.dataIn(15 downto 0);
               end if;

            when X"03" =>
               v.evrConfigIntfOut.dataOut(7 downto 0) := sysR.evrConfig.triggerEventCode;
               if (evrConfigIntfIn.wrEna = '1') then
                  v.evrConfig.triggerEventCode := evrConfigIntfIn.dataIn(7 downto 0);
               end if;

            when X"04" =>
               v.evrConfigIntfOut.dataOut(15 downto 0) := sysEvrOutInt.errors;
               if (evrConfigIntfIn.wrEna = '1') then
                  v.resetErrorsHold := (others => '1');
               end if;

            when X"05" =>
               v.evrConfigIntfOut.dataOut := sysEvrOutInt.seconds;

            when X"06" =>
               v.evrConfigIntfOut.dataOut := sysEvrOutInt.offset;
               
            when others =>
               null;
         end case;

      end if;

      sysRin           <= v;
      evrConfigIntfOut <= sysR.evrConfigIntfOut;
   end process sysComb;

   sysSeq : process (sysClk, sysRst) is
   begin
      if (sysRst = '1') then
         sysR <= SYS_REG_INIT_C after TPD_G;
      elsif (rising_edge(sysClk)) then
         sysR <= sysRin after TPD_G;
      end if;
   end process sysSeq;

   -------------------------------------------------------------------------------------------------
   -- Synchronize EVR config registers to EVR clock
   -------------------------------------------------------------------------------------------------
   SynchronizerFifo_EvrConfig : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         BRAM_EN_G    => false,
         DATA_WIDTH_G => 42)
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
   SynchronizerFifo_EvrOut : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         BRAM_EN_G    => false,
         DATA_WIDTH_G => 97)
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
      variable v     : MainRegType;
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

   mainSeq : process (evrRecClk, evrRst) is
   begin
      if (evrRst = '1') then
         mainR <= MAIN_REG_INIT_C after TPD_G;
      elsif (rising_edge(evrRecClk)) then
         mainR <= mainRin after TPD_G;
      end if;
   end process mainSeq;
   

end architecture rtl;
