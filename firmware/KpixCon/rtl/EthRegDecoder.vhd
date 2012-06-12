-------------------------------------------------------------------------------
-- Title      : Ethernet Register Interface Decoder
-------------------------------------------------------------------------------
-- File       : EthRegDecoder.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2012-06-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Decodes register addresses from the Ethernet RegCntl interface.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;
use work.Version.all;
use work.EthFrontEndPkg.all;
use work.KpixRegRxPkg.all;
use work.KpixRegCntlPkg.all;
use work.KpixPkg.all;
use work.TriggerPkg.all;
use work.KpixClockGenPkg.all;
use work.KpixLocalPkg.all;
use work.KpixDataRxPkg.all;


entity EthRegDecoder is
  
  generic (
    DELAY_G            : time    := 1 ns;
    NUM_KPIX_MODULES_G : natural := 5);

  port (
    sysClk : in sl;
    sysRst : in sl;

    -- Interface to Ethernet core 
    ethRegCntlOut : in  EthRegCntlOutType;
    ethRegCntlIn  : out EthRegCntlInType;

    -- Interface to KPIX reg controller (reuse EthRegCntl types)
    kpixRegCntlOut : in  EthRegCntlInType;
    kpixRegCntlIn  : out EthRegCntlOutType;

    -- Interface to local module registers
    triggerRegsIn      : out TriggerRegsInType;
    kpixConfigRegs     : out KpixConfigRegsType;
    kpixClockGenRegsIn : out KpixClockGenRegsInType;
    kpixLocalRegsIn    : out KpixLocalRegsInType;
    kpixRegCntlRegsIn  : out KpixRegCntlRegsInType;
    kpixDataRxRegsIn   : out KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
    kpixDataRxRegsOut  : in  KpixDataRxRegsOutArray(NUM_KPIX_MODULES_G-1 downto 0));

end entity EthRegDecoder;

architecture rtl of EthRegDecoder is

  constant ETH_REG_WRITE_C : sl := '1';
  constant ETH_REG_READ_C  : sl := '0';

  -- Define local registers addresses
  constant VERSION_REG_ADDR_C         : natural := 0;
  constant CLOCK_SELECT_A_REG_ADDR_C  : natural := 1;
  constant CLOCK_SELECT_B_REG_ADDR_C  : natural := 2;
  constant DEBUG_SELECT_REG_ADDR_C    : natural := 3;
  constant TRIGGER_CONTROL_REG_ADDR_C : natural := 4;
  constant KPIX_RESET_REG_ADDR_C      : natural := 5;
  constant KPIX_CONFIG_REG_ADDR_C     : natural := 6;

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
    ethRegCntlIn       : EthRegCntlInType;
    kpixRegCntlIn      : EthRegCntlOutType;
    triggerRegsIn      : TriggerRegsInType;
    kpixConfigRegs     : KpixConfigRegsType;
    kpixClockGenRegsIn : KpixClockGenRegsInType;
    kpixLocalRegsIn    : KpixLocalRegsInType;
    kpixRegCntlRegsIn  : KpixRegCntlRegsInType;
    kpixDataRxRegsIn   : KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
  end record RegType;

  signal r, rin : RegType;

begin

  sync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      r.ethRegCntlIn.regAck    <= '0';
      r.ethRegCntlIn.regDataIn <= (others => '0');
      r.ethRegCntlIn.regFail   <= '0';

      r.kpixRegCntlIn.regInp     <= '0';
      r.kpixRegCntlIn.regReq     <= '0';
      r.kpixRegCntlIn.regOp      <= '0';
      r.kpixRegCntlIn.regAddr    <= (others => '0');
      r.kpixRegCntlIn.regDataOut <= (others => '0');

      r.triggerRegsIn.extTriggerEn         <= '0';
      r.triggerRegsIn.calibrate            <= '0';
      r.kpixConfigRegs.inputEdge           <= '0';      -- Rising Edge
      r.kpixConfigRegs.outputEdge          <= '0';      -- Rising Edge
      r.kpixClockGenRegsIn.clkSelReadout   <= "01001";  -- 100 ns
      r.kpixClockGenRegsIn.clkSelDigitize  <= "00100";  -- 50 ns
      r.kpixClockGenRegsIn.clkSelAcquire   <= "00100";  -- 50 ns
      r.kpixClockGenRegsIn.clkSelIdle      <= "01001";  -- 100 ns
      r.kpixClockGenRegsIn.clkSelPrecharge <= "00100";  -- 50 ns
      r.kpixClockGenRegsIn.newValue        <= '0';

      r.kpixRegCntlRegsIn.kpixReset <= '0';
      r.kpixLocalRegsIn.debugASel   <= (others => '0');
      r.kpixLocalRegsIn.debugBsel   <= (others => '0');
      r.kpixDataRxRegsIn <= (others =>
                             (enabled                     => '0',
                              rawDataMode                 => '0',
                              resetHeaderParityErrorCount => '0',
                              resetDataParityErrorCount   => '0',
                              resetMarkerErrorCount       => '0',
                              resetOverflowErrorCount     => '0'));

    elsif (rising_edge(sysClk)) then
      r <= rin;
    end if;
  end process sync;

  comb : process (r, ethRegCntlOut, kpixDataRxRegsOut, kpixRegCntlOut) is
    variable rVar         : RegType;
    variable addrIndexVar : integer;
  begin
    rVar := r;

    rVar.ethRegCntlIn.regAck    := '0';
    rVar.ethRegCntlIn.regDataIn := (others => '0');
    rVar.ethRegCntlIn.regFail   := '0';

    rVar.kpixRegCntlIn.regInp     := '0';
    rVar.kpixRegCntlIn.regReq     := '0';
    rVar.kpixRegCntlIn.regOp      := '0';
    rVar.kpixRegCntlIn.regAddr    := (others => '0');  -- Not necessary
    rVar.kpixRegCntlIn.regDataOut := (others => '0');  -- Not necessary

    -- Pulse these for 1 cycle only when accessed
    rVar.kpixClockGenRegsIn.newValue := '0';
    for i in NUM_KPIX_MODULES_G-1 downto 0 loop
      rVar.kpixDataRxRegsIn(i).resetHeaderParityErrorCount := '0';
      rVar.kpixDataRxRegsIn(i).resetDataParityErrorCount   := '0';
      rVar.kpixDataRxRegsIn(i).resetMarkerErrorCount       := '0';
      rVar.kpixDataRxRegsIn(i).resetOverflowErrorCount     := '0';
    end loop;


    -- Wait for an access request
    if (ethRegCntlOut.regReq = '1') then
      if (ethRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = LOCAL_REGS_ADDR_C) then
        -- Local Regs being accessed

        -- Ack right away
        rVar.ethRegCntlIn.regAck := '1';

        -- Error if addressing reg that doesnt exist
--        if (not isZero(ethRegCntlOut.regAddr(NOT_LOCAL_REGS_ADDR_RANGE_C))) then
--          rVar.ethRegCntlIn.regFail := '1';
--        end if;

        -- Peform register access
        addrIndexVar := to_integer(unsigned(ethRegCntlOut.regAddr(LOCAL_REGS_ADDR_RANGE_C)));
        case (addrIndexVar) is

          when VERSION_REG_ADDR_C =>
            rVar.ethRegCntlIn.regDataIn := FPGA_VERSION_C;

          when CLOCK_SELECT_A_REG_ADDR_C =>
            rVar.ethRegCntlIn.regDataIn(28 downto 24) := r.kpixClockGenRegsIn.clkSelReadout;
            rVar.ethRegCntlIn.regDataIn(20 downto 16) := r.kpixClockGenRegsIn.clkSelDigitize;
            rVar.ethRegCntlIn.regDataIn(12 downto 8)  := r.kpixClockGenRegsIn.clkSelAcquire;
            rVar.ethRegCntlIn.regDataIn(4 downto 0)   := r.kpixClockGenRegsIn.clkSelIdle;
            if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
              rVar.kpixClockGenRegsIn.clkSelReadout  := ethRegCntlOut.regDataOut(28 downto 24);
              rVar.kpixClockGenRegsIn.clkSelDigitize := ethRegCntlOut.regDataOut(20 downto 16);
              rVar.kpixClockGenRegsIn.clkSelAcquire  := ethRegCntlOut.regDataOut(12 downto 8);
              rVar.kpixClockGenRegsIn.clkSelIdle     := ethRegCntlOut.regDataOut(4 downto 0);
              rVar.kpixClockGenRegsIn.newValue       := '1';  -- Let ClockGen know to resync
            end if;

          when CLOCK_SELECT_B_REG_ADDR_C =>
            rVar.ethRegCntlIn.regDataIn(4 downto 0) := r.kpixClockGenRegsIn.clkSelPrecharge;
            if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
              rVar.kpixClockGenRegsIn.clkSelPrecharge := ethRegCntlOut.regDataOut(4 downto 0);
            end if;

          when DEBUG_SELECT_REG_ADDR_C =>
            rVar.ethRegCntlIn.regDataIn(4 downto 0)  := r.kpixLocalRegsIn.debugASel;
            rVar.ethRegCntlIn.regDataIn(12 downto 8) := r.kpixLocalRegsIn.debugBsel;
            if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
              rVar.kpixLocalRegsIn.debugASel := ethRegCntlOut.regDataOut(4 downto 0);
              rVar.kpixLocalRegsIn.debugBsel := ethRegCntlOut.regDataOut(12 downto 8);
            end if;

          when TRIGGER_CONTROL_REG_ADDR_C =>
            rVar.ethRegCntlIn.regDataIn(0) := r.triggerRegsIn.extTriggerEn;
            rVar.ethRegCntlIn.regDataIn(4) := r.triggerRegsIn.calibrate;
            if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
              rVar.triggerRegsIn.extTriggerEn := ethRegCntlOut.regDataOut(0);
              rVar.triggerRegsIn.calibrate    := ethRegCntlOut.regDataOut(4);
            end if;

          when KPIX_RESET_REG_ADDR_C =>
            rVar.ethRegCntlIn.regDataIn(0) := r.kpixRegCntlRegsIn.kpixReset;
            if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
              rVar.kpixRegCntlRegsIn.kpixReset := ethRegCntlOut.regDataOut(0);
            end if;

          when KPIX_CONFIG_REG_ADDR_C =>
            rVar.ethRegCntlIn.regDataIn(0) := r.kpixConfigRegs.inputEdge;
            rVar.ethRegCntlIn.regDataIn(1) := r.kpixConfigRegs.outputEdge;
            if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
              rVar.kpixConfigRegs.inputEdge  := ethRegCntlOut.regDataOut(0);
              rVar.kpixConfigRegs.outputEdge := ethRegCntlOut.regDataOut(1);
            end if;


          when others =>
            for i in NUM_KPIX_MODULES_G-1 downto 0 loop
              if (addrIndexVar = KPIX_DATA_RX_MODE_REG_ADDR_C(i)) then
                rVar.ethRegCntlIn.regDataIn(0) := r.kpixDataRxRegsIn(i).enabled;
                rVar.ethRegCntlIn.regDataIn(1) := r.kpixDataRxRegsIn(i).rawDataMode;
                if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
                  rVar.kpixDataRxRegsIn(i).enabled     := ethRegCntlOut.regDataOut(0);
                  rVar.kpixDataRxRegsIn(i).rawDataMode := ethRegCntlOut.regDataOut(1);
                end if;
              end if;
            end loop;

            for i in NUM_KPIX_MODULES_G-1 downto 0 loop
              if (addrIndexVar = KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C(i)) then
                rVar.ethRegCntlIn.regDataIn := kpixDataRxRegsOut(i).headerParityErrorCount;
                if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
                  rVar.kpixDataRxRegsIn(i).resetHeaderParityErrorCount := '1';
                end if;
              end if;
            end loop;

            for i in NUM_KPIX_MODULES_G-1 downto 0 loop
              if (addrIndexVar = KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C(i)) then
                rVar.ethRegCntlIn.regDataIn := kpixDataRxRegsOut(i).dataParityErrorCount;
                if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
                  rVar.kpixDataRxRegsIn(i).resetDataParityErrorCount := '1';
                end if;
              end if;
            end loop;

            for i in NUM_KPIX_MODULES_G-1 downto 0 loop
              if (addrIndexVar = KPIX_MARKER_ERROR_COUNT_REG_ADDR_C(i)) then
                rVar.ethRegCntlIn.regDataIn := kpixDataRxRegsOut(i).markerErrorCount;
                if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
                  rVar.kpixDataRxRegsIn(i).resetMarkerErrorCount := '1';
                end if;
              end if;
            end loop;

            for i in NUM_KPIX_MODULES_G-1 downto 0 loop
              if (addrIndexVar = KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C(i)) then
                rVar.ethRegCntlIn.regDataIn := kpixDataRxRegsOut(i).overflowErrorCount;
                if (ethRegCntlOut.regOp = ETH_REG_WRITE_C) then
                  rVar.kpixDataRxRegsIn(i).resetOverflowErrorCount := '1';
                end if;
              end if;
            end loop;
        end case;



      elsif (ethRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = KPIX_REGS_ADDR_C) then
        -- KPIX regs being accessed
        -- Pass EthCntl io right though
        -- Will revert back when ethRegCntlOut.regReq falls
        rVar.kpixRegCntlIn := ethRegCntlOut;
        rVar.ethRegCntlIn  := kpixRegCntlOut;

      else
        -- Not valid address block
        rVar.ethRegCntlIn.regFail := '1';
        rVar.ethRegCntlIn.regAck  := '1';

      end if;
    end if;

    rin <= rVar;

    ethRegCntlIn       <= r.ethRegCntlIn;
    kpixRegCntlIn      <= r.kpixRegCntlIn;
    triggerRegsIn      <= r.triggerRegsIn;
    kpixConfigRegs     <= r.kpixConfigRegs;
    kpixRegCntlRegsIn  <= r.kpixRegCntlRegsIn;
    kpixClockGenRegsIn <= r.kpixClockGenRegsIn;
    kpixLocalRegsIn    <= r.kpixLocalRegsIn;
    kpixDataRxRegsIn   <= r.kpixDataRxRegsIn;
    
  end process comb;

end architecture rtl;
