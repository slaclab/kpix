-------------------------------------------------------------------------------
-- Title      : Front End Register Interface Decoder
-------------------------------------------------------------------------------
-- File       : FrontEndRegDecoder.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2012-10-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Decodes register addresses from the Front End interface.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;
use work.Version.all;
use work.FrontEndPkg.all;
use work.KpixRegRxPkg.all;
use work.KpixPkg.all;
use work.TriggerPkg.all;
use work.KpixClockGenPkg.all;
use work.KpixLocalPkg.all;
use work.KpixDataRxPkg.all;
use work.EvrPkg.all;

entity FrontEndRegDecoder is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 5);

  port (
    sysClk : in sl;
    sysRst : in sl;

    -- Interface to front end
    frontEndRegCntlOut : in  FrontEndRegCntlOutType;
    frontEndRegCntlIn  : out FrontEndRegCntlInType;

    -- Interface to KPIX reg controller (reuse FrontEndRegCntl types)
    kpixRegCntlOut : in  FrontEndRegCntlInType;
    kpixRegCntlIn  : out FrontEndRegCntlOutType;

    -- Interface to EVR module
    evrIn  : out EvrInType;
    evrOut : in  EvrOutType;

    -- Interface to local module registers
    triggerRegsIn      : out TriggerRegsInType;
    kpixConfigRegs     : out KpixConfigRegsType;
    kpixClockGenRegsIn : out KpixClockGenRegsInType;
    kpixLocalRegsIn    : out KpixLocalRegsInType;
    kpixDataRxRegsIn   : out KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
    kpixDataRxRegsOut  : in  KpixDataRxRegsOutArray(NUM_KPIX_MODULES_G-1 downto 0));

end entity FrontEndRegDecoder;

architecture rtl of FrontEndRegDecoder is

  constant FRONT_END_REG_WRITE_C : sl := '1';
  constant FRONT_END_REG_READ_C  : sl := '0';

  -- Define local registers addresses
  constant VERSION_REG_ADDR_C             : natural := 0;
  constant CLOCK_SELECT_A_REG_ADDR_C      : natural := 1;
  constant CLOCK_SELECT_B_REG_ADDR_C      : natural := 2;
  constant DEBUG_SELECT_REG_ADDR_C        : natural := 3;
  constant TRIGGER_CONTROL_REG_ADDR_C     : natural := 4;
  constant KPIX_RESET_REG_ADDR_C          : natural := 5;
  constant KPIX_CONFIG_REG_ADDR_C         : natural := 6;
  constant TIMESTAMP_CONTROL_REG_ADDR_C   : natural := 7;
  constant ACQUISITION_CONTROL_REG_ADDR_C : natural := 8;
  constant EVR_ERROR_COUNT_REG_ADDR_C     : natural := 9;

  constant KPIX_DATA_RX_MODE_REG_ADDR_C              : IntegerArray := list(256, NUM_KPIX_MODULES_G, 5);  --
  constant KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C : IntegerArray := list(257, NUM_KPIX_MODULES_G, 5);
  constant KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C   : IntegerArray := list(258, NUM_KPIX_MODULES_G, 5);
  constant KPIX_MARKER_ERROR_COUNT_REG_ADDR_C        : IntegerArray := list(259, NUM_KPIX_MODULES_G, 5);
  constant KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C      : IntegerArray := list(260, NUM_KPIX_MODULES_G, 5);

  -- Address block constants
  subtype ADDR_BLOCK_RANGE_C is natural range 23 downto 20;
  constant LOCAL_REGS_ADDR_C : slv(3 downto 0) := "0000";
  constant KPIX_REGS_ADDR_C  : slv(3 downto 0) := "0001";
  constant NUM_LOCAL_REGS_C  : natural         := 512;
  subtype LOCAL_REGS_ADDR_RANGE_C is natural range 19 downto 0;  --log2(NUM_LOCAL_REGS_C)-1 downto 0;
  subtype NOT_LOCAL_REGS_ADDR_RANGE_C is natural range 19 downto (log2(NUM_LOCAL_REGS_C));


  type RegType is record
    frontEndRegCntlIn  : FrontEndRegCntlInType;   -- Outputs to FrontEnd module
    evrIn              : EvrInType;
    kpixRegCntlIn      : FrontEndRegCntlOutType;  -- Outputs to KpixRegCntl module
    triggerRegsIn      : TriggerRegsInType;
    kpixConfigRegs     : KpixConfigRegsType;
    kpixClockGenRegsIn : KpixClockGenRegsInType;
    kpixLocalRegsIn    : KpixLocalRegsInType;
    kpixDataRxRegsIn   : KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
  end record RegType;

  signal r, rin : RegType;

begin

  sync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      r.frontEndRegCntlIn.regAck    <= '0'             after DELAY_G;
      r.frontEndRegCntlIn.regDataIn <= (others => '0') after DELAY_G;
      r.frontEndRegCntlIn.regFail   <= '0'             after DELAY_G;

      r.kpixRegCntlIn.regInp     <= '0'             after DELAY_G;
      r.kpixRegCntlIn.regReq     <= '0'             after DELAY_G;
      r.kpixRegCntlIn.regOp      <= '0'             after DELAY_G;
      r.kpixRegCntlIn.regAddr    <= (others => '0') after DELAY_G;
      r.kpixRegCntlIn.regDataOut <= (others => '0') after DELAY_G;

      r.evrIn.countReset <= '0' after DELAY_G;

      r.triggerRegsIn.extTriggerSrc        <= (others => '0') after DELAY_G;
      r.triggerRegsIn.calibrate            <= '0'             after DELAY_G;
      r.triggerRegsIn.extTimestampSrc      <= (others => '0') after DELAY_G;
      r.triggerRegsIn.acquisitionSrc       <= (others => '0') after DELAY_G;
      r.KpixConfigRegs.kpixReset           <= '0'             after DELAY_G;
      r.kpixConfigRegs.inputEdge           <= '0'             after DELAY_G;  -- Rising Edge
      r.kpixConfigRegs.outputEdge          <= '0'             after DELAY_G;  -- Rising Edge
      r.kpixConfigRegs.rawDataMode         <= '0'             after DELAY_G;
      r.kpixConfigRegs.numColumns          <= "11111"         after DELAY_G;  -- 32 columns
      r.kpixConfigRegs.autoReadDisable     <= '0'             after DELAY_G;
      r.kpixClockGenRegsIn.clkSelReadout   <= "00001001"      after DELAY_G;  -- 100 ns
      r.kpixClockGenRegsIn.clkSelDigitize  <= "00000100"      after DELAY_G;  -- 50 ns
      r.kpixClockGenRegsIn.clkSelAcquire   <= "00000100"      after DELAY_G;  -- 50 ns
      r.kpixClockGenRegsIn.clkSelIdle      <= "00001001"      after DELAY_G;  -- 100 ns
      r.kpixClockGenRegsIn.clkSelPrecharge <= "00000100"      after DELAY_G;  -- 50 ns
      r.kpixClockGenRegsIn.newValue        <= '0'             after DELAY_G;

      r.kpixLocalRegsIn.debugASel <= (others => '0') after DELAY_G;
      r.kpixLocalRegsIn.debugBsel <= (others => '0') after DELAY_G;
      r.kpixDataRxRegsIn <= (others =>
                             (enabled                     => '0',
                              resetHeaderParityErrorCount => '0',
                              resetDataParityErrorCount   => '0',
                              resetMarkerErrorCount       => '0',
                              resetOverflowErrorCount     => '0')) after DELAY_G;

    elsif (rising_edge(sysClk)) then
      r <= rin after DELAY_G;
    end if;
  end process sync;

  comb : process (r, frontEndRegCntlOut, kpixDataRxRegsOut, kpixRegCntlOut) is
    variable rVar         : RegType;
    variable addrIndexVar : integer;
  begin
    rVar := r;

    rVar.frontEndRegCntlIn.regAck    := '0';
    rVar.frontEndRegCntlIn.regDataIn := (others => '0');
    rVar.frontEndRegCntlIn.regFail   := '0';

    rVar.kpixRegCntlIn.regInp     := '0';
    rVar.kpixRegCntlIn.regReq     := '0';
    rVar.kpixRegCntlIn.regOp      := '0';
    rVar.kpixRegCntlIn.regAddr    := (others => '0');  -- Not necessary
    rVar.kpixRegCntlIn.regDataOut := (others => '0');  -- Not necessary

    -- Pulse these for 1 cycle only when accessed
    rVar.kpixClockGenRegsIn.newValue := '0';
    rVar.kpixConfigRegs.kpixReset    := '0';
    rVar.evrIn.countReset            := '0';
    for i in NUM_KPIX_MODULES_G-1 downto 0 loop
      rVar.kpixDataRxRegsIn(i).resetHeaderParityErrorCount := '0';
      rVar.kpixDataRxRegsIn(i).resetDataParityErrorCount   := '0';
      rVar.kpixDataRxRegsIn(i).resetMarkerErrorCount       := '0';
      rVar.kpixDataRxRegsIn(i).resetOverflowErrorCount     := '0';
    end loop;

    if (frontEndRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = KPIX_REGS_ADDR_C) then
      -- KPIX regs being accessed
      -- Pass FrontEndCntl io right though
      -- Will revert back when frontEndRegCntlOut.regReq falls
      rVar.kpixRegCntlIn     := frontEndRegCntlOut;
      rVar.frontEndRegCntlIn := kpixRegCntlOut;

    -- Wait for an access request
    elsif (frontEndRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = LOCAL_REGS_ADDR_C and
           frontEndRegCntlOut.regReq = '1') then

      -- Local Regs being accessed

      -- Ack right away
      rVar.frontEndRegCntlIn.regAck := '1';

      -- Peform register access
      addrIndexVar := to_integer(unsigned(frontEndRegCntlOut.regAddr(LOCAL_REGS_ADDR_RANGE_C)));
      case (addrIndexVar) is

        when VERSION_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn := FPGA_VERSION_C;

        when CLOCK_SELECT_A_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(31 downto 24) := r.kpixClockGenRegsIn.clkSelReadout;
          rVar.frontEndRegCntlIn.regDataIn(23 downto 16) := r.kpixClockGenRegsIn.clkSelDigitize;
          rVar.frontEndRegCntlIn.regDataIn(15 downto 8)  := r.kpixClockGenRegsIn.clkSelAcquire;
          rVar.frontEndRegCntlIn.regDataIn(7 downto 0)   := r.kpixClockGenRegsIn.clkSelIdle;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.kpixClockGenRegsIn.clkSelReadout  := frontEndRegCntlOut.regDataOut(31 downto 24);
            rVar.kpixClockGenRegsIn.clkSelDigitize := frontEndRegCntlOut.regDataOut(23 downto 16);
            rVar.kpixClockGenRegsIn.clkSelAcquire  := frontEndRegCntlOut.regDataOut(15 downto 8);
            rVar.kpixClockGenRegsIn.clkSelIdle     := frontEndRegCntlOut.regDataOut(7 downto 0);
            rVar.kpixClockGenRegsIn.newValue       := '1';  -- Let ClockGen know to resync
          end if;

        when CLOCK_SELECT_B_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(7 downto 0) := r.kpixClockGenRegsIn.clkSelPrecharge;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.kpixClockGenRegsIn.clkSelPrecharge := frontEndRegCntlOut.regDataOut(7 downto 0);
          end if;

        when DEBUG_SELECT_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(4 downto 0)  := r.kpixLocalRegsIn.debugASel;
          rVar.frontEndRegCntlIn.regDataIn(12 downto 8) := r.kpixLocalRegsIn.debugBsel;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.kpixLocalRegsIn.debugASel := frontEndRegCntlOut.regDataOut(4 downto 0);
            rVar.kpixLocalRegsIn.debugBsel := frontEndRegCntlOut.regDataOut(12 downto 8);
          end if;

        when TRIGGER_CONTROL_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(2 downto 0) := r.triggerRegsIn.extTriggerSrc;
          rVar.frontEndRegCntlIn.regDataIn(4)          := r.triggerRegsIn.calibrate;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.triggerRegsIn.extTriggerSrc := frontEndRegCntlOut.regDataOut(2 downto 0);
            rVar.triggerRegsIn.calibrate     := frontEndRegCntlOut.regDataOut(4);
          end if;

        when KPIX_RESET_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(0) := r.kpixConfigRegs.kpixReset;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.kpixConfigRegs.kpixReset := frontEndRegCntlOut.regDataOut(0);
          end if;

        when KPIX_CONFIG_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(0)           := r.kpixConfigRegs.inputEdge;
          rVar.frontEndRegCntlIn.regDataIn(1)           := r.kpixConfigRegs.outputEdge;
          rVar.frontEndRegCntlIn.regDataIn(4)           := r.kpixConfigRegs.rawDataMode;
          rVar.frontEndRegCntlIn.regDataIn(12 downto 8) := r.kpixConfigRegs.numColumns;
          rVar.frontEndRegCntlIn.regDataIn(16)          := r.kpixConfigRegs.autoReadDisable;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.kpixConfigRegs.inputEdge       := frontEndRegCntlOut.regDataOut(0);
            rVar.kpixConfigRegs.outputEdge      := frontEndRegCntlOut.regDataOut(1);
            rVar.kpixConfigRegs.rawDataMode     := frontEndRegCntlOut.regDataOut(4);
            rVar.kpixConfigRegs.numColumns      := frontEndRegCntlOut.regDataOut(12 downto 8);
            rVar.kpixConfigRegs.autoReadDisable := frontEndRegCntlOut.regDataOut(16);
          end if;

        when TIMESTAMP_CONTROL_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(2 downto 0) := r.triggerRegsIn.extTimestampSrc;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.triggerRegsIn.extTimestampSrc := frontEndRegCntlOut.regDataOut(2 downto 0);
          end if;

        when ACQUISITION_CONTROL_REG_ADDR_C =>
          rVar.frontEndRegCntlIn.regDataIn(1 downto 0) := r.triggerRegsIn.acquisitionSrc;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.triggerRegsIn.acquisitionSrc := frontEndRegCntlOut.regDataOut(1 downto 0);
          end if;

        when EVR_ERROR_COUNT_REG_ADDR_C =>
          -- Need to sychronize this!!!
          rVar.frontEndRegCntlIn.regDataIn(15 downto 0) := evrOut.errors;
          if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
            rVar.evrIn.countReset := '1';
          end if;


        when others =>
          for i in NUM_KPIX_MODULES_G-1 downto 0 loop
            if (addrIndexVar = KPIX_DATA_RX_MODE_REG_ADDR_C(i)) then
              rVar.frontEndRegCntlIn.regDataIn(0) := r.kpixDataRxRegsIn(i).enabled;
              if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                rVar.kpixDataRxRegsIn(i).enabled := frontEndRegCntlOut.regDataOut(0);
              end if;
            end if;
          end loop;

          for i in NUM_KPIX_MODULES_G-1 downto 0 loop
            if (addrIndexVar = KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C(i)) then
              rVar.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(i).headerParityErrorCount;
              if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                rVar.kpixDataRxRegsIn(i).resetHeaderParityErrorCount := '1';
              end if;
            end if;
          end loop;

          for i in NUM_KPIX_MODULES_G-1 downto 0 loop
            if (addrIndexVar = KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C(i)) then
              rVar.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(i).dataParityErrorCount;
              if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                rVar.kpixDataRxRegsIn(i).resetDataParityErrorCount := '1';
              end if;
            end if;
          end loop;

          for i in NUM_KPIX_MODULES_G-1 downto 0 loop
            if (addrIndexVar = KPIX_MARKER_ERROR_COUNT_REG_ADDR_C(i)) then
              rVar.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(i).markerErrorCount;
              if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                rVar.kpixDataRxRegsIn(i).resetMarkerErrorCount := '1';
              end if;
            end if;
          end loop;

          for i in NUM_KPIX_MODULES_G-1 downto 0 loop
            if (addrIndexVar = KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C(i)) then
              rVar.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(i).overflowErrorCount;
              if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                rVar.kpixDataRxRegsIn(i).resetOverflowErrorCount := '1';
              end if;
            end if;
          end loop;
          
      end case;
    elsif (frontEndRegCntlOut.regReq = '1') then
      -- Ack non existant registers too so they don't fail
      rVar.frontEndRegCntlIn.regAck := '1';
    end if;

    rin <= rVar;

    frontEndRegCntlIn  <= r.frontEndRegCntlIn;
    kpixRegCntlIn      <= r.kpixRegCntlIn;
    triggerRegsIn      <= r.triggerRegsIn;
    kpixConfigRegs     <= r.kpixConfigRegs;
    kpixClockGenRegsIn <= r.kpixClockGenRegsIn;
    kpixLocalRegsIn    <= r.kpixLocalRegsIn;
    kpixDataRxRegsIn   <= r.kpixDataRxRegsIn;
    
  end process comb;

end architecture rtl;
