-------------------------------------------------------------------------------
-- Title      : Front End Register Interface Decoder
-------------------------------------------------------------------------------
-- File       : FrontEndRegDecoder.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2013-07-12
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

      -- Allows firmware to be reset through FrontEnd
      softwareReset : out sl;

      -- Interface to KPIX reg controller (reuse FrontEndRegCntl types)
      kpixRegCntlOut : in  FrontEndRegCntlInType;
      kpixRegCntlIn  : out FrontEndRegCntlOutType;

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
   constant SOFTWARE_RESET_REG_ADDR_C      : natural := 10;

   constant KPIX_DATA_RX_MODE_REG_ADDR_C              : natural := 0;  --IntegerArray := list(256, NUM_KPIX_MODULES_G, 8);  --
   constant KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C : natural := 1;  -- IntegerArray := list(257, NUM_KPIX_MODULES_G, 8);
   constant KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C   : natural := 2;  -- IntegerArray := list(258, NUM_KPIX_MODULES_G, 8);
   constant KPIX_MARKER_ERROR_COUNT_REG_ADDR_C        : natural := 3;  -- IntegerArray := list(259, NUM_KPIX_MODULES_G, 8);
   constant KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C      : natural := 4;  -- IntegerArray := list(260, NUM_KPIX_MODULES_G, 8);

   -- Address block constants
   subtype ADDR_BLOCK_RANGE_C is natural range 23 downto 20;
   constant LOCAL_REGS_ADDR_C : slv(3 downto 0) := "0000";
   constant KPIX_REGS_ADDR_C  : slv(3 downto 0) := "0001";
   constant NUM_LOCAL_REGS_C  : natural         := 512;
   subtype LOCAL_REGS_ADDR_RANGE_C is natural range 19 downto 0;  --log2(NUM_LOCAL_REGS_C)-1 downto 0;
--   subtype NOT_LOCAL_REGS_ADDR_RANGE_C is natural range 19 downto (log2(NUM_LOCAL_REGS_C));


   type RegType is record
      kpixRegCntlOut     : FrontEndRegCntlInType;   -- pipeline delay
      frontEndRegCntlIn  : FrontEndRegCntlInType;   -- Outputs to FrontEnd module
      softwareReset      : sl;
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
         r.kpixRegCntlOut.regAck    <= '0'             after DELAY_G;
         r.kpixRegCntlOut.regDataIn <= (others => '0') after DELAY_G;
         r.kpixRegCntlOut.regFail   <= '0'             after DELAY_G;

         r.frontEndRegCntlIn.regAck    <= '0'             after DELAY_G;
         r.frontEndRegCntlIn.regDataIn <= (others => '0') after DELAY_G;
         r.frontEndRegCntlIn.regFail   <= '0'             after DELAY_G;

         r.softwareReset <= '0' after DELAY_G;

         r.kpixRegCntlIn.regInp     <= '0'             after DELAY_G;
         r.kpixRegCntlIn.regReq     <= '0'             after DELAY_G;
         r.kpixRegCntlIn.regOp      <= '0'             after DELAY_G;
         r.kpixRegCntlIn.regAddr    <= (others => '0') after DELAY_G;
         r.kpixRegCntlIn.regDataOut <= (others => '0') after DELAY_G;

         r.triggerRegsIn.extTriggerSrc        <= (others => '0')             after DELAY_G;
         r.triggerRegsIn.calibrate            <= '0'                         after DELAY_G;
         r.triggerRegsIn.extTimestampSrc      <= (others => '0')             after DELAY_G;
         r.triggerRegsIn.acquisitionSrc       <= (others => '0')             after DELAY_G;  -- 
         r.KpixConfigRegs.kpixReset           <= '0'                         after DELAY_G;  -- 
         r.kpixConfigRegs.inputEdge           <= '0'                         after DELAY_G;  -- Rising Edge
         r.kpixConfigRegs.outputEdge          <= '0'                         after DELAY_G;  -- Rising Edge
         r.kpixConfigRegs.rawDataMode         <= '0'                         after DELAY_G;
         r.kpixConfigRegs.numColumns          <= "11111"                     after DELAY_G;  -- 32 columns
         r.kpixConfigRegs.autoReadDisable     <= '0'                         after DELAY_G;
         r.kpixClockGenRegsIn.clkSelReadout   <= CLK_SEL_READOUT_DEFAULT_C   after DELAY_G;  -- 100 ns
         r.kpixClockGenRegsIn.clkSelDigitize  <= CLK_SEL_DIGITIZE_DEFAULT_C  after DELAY_G;  -- 50 ns
         r.kpixClockGenRegsIn.clkSelAcquire   <= CLK_SEL_ACQUIRE_DEFAULT_C   after DELAY_G;  -- 50 ns
         r.kpixClockGenRegsIn.clkSelIdle      <= CLK_SEL_IDLE_DEFAULT_C      after DELAY_G;  -- 100 ns
         r.kpixClockGenRegsIn.clkSelPrecharge <= CLK_SEL_PRECHARGE_DEFAULT_C after DELAY_G;  -- 50 ns
         r.kpixClockGenRegsIn.newValue        <= '0'                         after DELAY_G;

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
      variable v            : RegType;
      variable addrIndexVar : integer;
      variable kpixIndexVar : integer;
   begin
      v := r;

      -- Pipeline 1 cycle to ease timing across boundary
      v.kpixRegCntlOut := kpixRegCntlOut;

      v.frontEndRegCntlIn.regAck    := '0';
      v.frontEndRegCntlIn.regDataIn := (others => '0');
      v.frontEndRegCntlIn.regFail   := '0';

      v.kpixRegCntlIn.regInp     := '0';
      v.kpixRegCntlIn.regReq     := '0';
      v.kpixRegCntlIn.regOp      := '0';
      v.kpixRegCntlIn.regAddr    := (others => '0');  -- Not necessary
      v.kpixRegCntlIn.regDataOut := (others => '0');  -- Not necessary

      -- Pulse these for 1 cycle only when accessed
      v.kpixClockGenRegsIn.newValue := '0';
      v.kpixConfigRegs.kpixReset    := '0';
      for i in NUM_KPIX_MODULES_G-1 downto 0 loop
         v.kpixDataRxRegsIn(i).resetHeaderParityErrorCount := '0';
         v.kpixDataRxRegsIn(i).resetDataParityErrorCount   := '0';
         v.kpixDataRxRegsIn(i).resetMarkerErrorCount       := '0';
         v.kpixDataRxRegsIn(i).resetOverflowErrorCount     := '0';
      end loop;

      if (frontEndRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = KPIX_REGS_ADDR_C) then
         -- KPIX regs being accessed
         -- Pass FrontEndCntl io right though
         -- Will revert back when frontEndRegCntlOut.regReq falls
         v.kpixRegCntlIn     := frontEndRegCntlOut;
         v.frontEndRegCntlIn := r.kpixRegCntlOut;

      -- Wait for an access request
      elsif (frontEndRegCntlOut.regAddr(ADDR_BLOCK_RANGE_C) = LOCAL_REGS_ADDR_C and
             frontEndRegCntlOut.regReq = '1') then

         -- Local Regs being accessed

         -- Ack right away
         v.frontEndRegCntlIn.regAck := '1';

         -- Peform register access
         if (frontEndRegCntlOut.regAddr(8) = '0') then
            -- Access general registers

            addrIndexVar := to_integer(unsigned(frontEndRegCntlOut.regAddr(3 downto 0)));
            case (addrIndexVar) is

               when VERSION_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn := FPGA_VERSION_C;

               when CLOCK_SELECT_A_REG_ADDR_C =>
                  -- Only use 8 bits of these registers for legacy purposes
                  v.frontEndRegCntlIn.regDataIn(31 downto 24) := r.kpixClockGenRegsIn.clkSelReadout(7 downto 0);
                  v.frontEndRegCntlIn.regDataIn(23 downto 16) := r.kpixClockGenRegsIn.clkSelDigitize(7 downto 0);
                  v.frontEndRegCntlIn.regDataIn(15 downto 8)  := r.kpixClockGenRegsIn.clkSelAcquire(7 downto 0);
                  v.frontEndRegCntlIn.regDataIn(7 downto 0)   := r.kpixClockGenRegsIn.clkSelIdle(7 downto 0);
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixClockGenRegsIn.clkSelReadout(7 downto 0)  := frontEndRegCntlOut.regDataOut(31 downto 24);
                     v.kpixClockGenRegsIn.clkSelDigitize(7 downto 0) := frontEndRegCntlOut.regDataOut(23 downto 16);
                     v.kpixClockGenRegsIn.clkSelAcquire(7 downto 0)  := frontEndRegCntlOut.regDataOut(15 downto 8);
                     v.kpixClockGenRegsIn.clkSelIdle(7 downto 0)     := frontEndRegCntlOut.regDataOut(7 downto 0);
                     v.kpixClockGenRegsIn.newValue                   := '1';  -- Let ClockGen know to resync
                  end if;

               when CLOCK_SELECT_B_REG_ADDR_C =>
                  -- Precharge is the only 12 bit clock register, others are 8.
                  v.frontEndRegCntlIn.regDataIn(11 downto 0) := r.kpixClockGenRegsIn.clkSelPrecharge;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixClockGenRegsIn.clkSelPrecharge := frontEndRegCntlOut.regDataOut(11 downto 0);
                     v.kpixClockGenRegsIn.newValue        := '1';
                  end if;

               when DEBUG_SELECT_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(4 downto 0)  := r.kpixLocalRegsIn.debugASel;
                  v.frontEndRegCntlIn.regDataIn(12 downto 8) := r.kpixLocalRegsIn.debugBsel;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixLocalRegsIn.debugASel := frontEndRegCntlOut.regDataOut(4 downto 0);
                     v.kpixLocalRegsIn.debugBsel := frontEndRegCntlOut.regDataOut(12 downto 8);
                  end if;

               when TRIGGER_CONTROL_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(2 downto 0) := r.triggerRegsIn.extTriggerSrc;
                  v.frontEndRegCntlIn.regDataIn(4)          := r.triggerRegsIn.calibrate;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.triggerRegsIn.extTriggerSrc := frontEndRegCntlOut.regDataOut(2 downto 0);
                     v.triggerRegsIn.calibrate     := frontEndRegCntlOut.regDataOut(4);
                  end if;

               when KPIX_RESET_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(0) := r.kpixConfigRegs.kpixReset;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixConfigRegs.kpixReset := frontEndRegCntlOut.regDataOut(0);
                  end if;

               when KPIX_CONFIG_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(0)           := r.kpixConfigRegs.inputEdge;
                  v.frontEndRegCntlIn.regDataIn(1)           := r.kpixConfigRegs.outputEdge;
                  v.frontEndRegCntlIn.regDataIn(4)           := r.kpixConfigRegs.rawDataMode;
                  v.frontEndRegCntlIn.regDataIn(12 downto 8) := r.kpixConfigRegs.numColumns;
                  v.frontEndRegCntlIn.regDataIn(16)          := r.kpixConfigRegs.autoReadDisable;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixConfigRegs.inputEdge       := frontEndRegCntlOut.regDataOut(0);
                     v.kpixConfigRegs.outputEdge      := frontEndRegCntlOut.regDataOut(1);
                     v.kpixConfigRegs.rawDataMode     := frontEndRegCntlOut.regDataOut(4);
                     v.kpixConfigRegs.numColumns      := frontEndRegCntlOut.regDataOut(12 downto 8);
                     v.kpixConfigRegs.autoReadDisable := frontEndRegCntlOut.regDataOut(16);
                  end if;

               when TIMESTAMP_CONTROL_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(2 downto 0) := r.triggerRegsIn.extTimestampSrc;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.triggerRegsIn.extTimestampSrc := frontEndRegCntlOut.regDataOut(2 downto 0);
                  end if;

               when ACQUISITION_CONTROL_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(1 downto 0) := r.triggerRegsIn.acquisitionSrc;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.triggerRegsIn.acquisitionSrc := frontEndRegCntlOut.regDataOut(1 downto 0);
                  end if;


               when SOFTWARE_RESET_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(0) := r.softwareReset;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.softwareReset := frontEndRegCntlOut.regDataOut(0);
                  end if;

               when others =>
                  null;
            end case;
         else                           -- (frontEndRegCntlOut.regAddr(8) = '1')
            -- Access per KpixDataRx registers
            kpixIndexVar := to_integer(unsigned(frontEndRegCntlOut.regAddr(7 downto 3)));
            addrIndexVar := to_integer(unsigned(frontEndRegCntlOut.regAddr(2 downto 0)));

            case addrIndexVar is
               when KPIX_DATA_RX_MODE_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn(0) := r.kpixDataRxRegsIn(kpixIndexVar).enabled;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).enabled := frontEndRegCntlOut.regDataOut(0);
                  end if;

               when KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(kpixIndexVar).headerParityErrorCount;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetHeaderParityErrorCount := '1';
                  end if;

               when KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(kpixIndexVar).dataParityErrorCount;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetDataParityErrorCount := '1';
                  end if;

               when KPIX_MARKER_ERROR_COUNT_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(kpixIndexVar).markerErrorCount;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetMarkerErrorCount := '1';
                  end if;

               when KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C =>
                  v.frontEndRegCntlIn.regDataIn := kpixDataRxRegsOut(kpixIndexVar).overflowErrorCount;
                  if (frontEndRegCntlOut.regOp = FRONT_END_REG_WRITE_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetOverflowErrorCount := '1';
                  end if;


               when others => null;
            end case;
         end if;
      elsif (frontEndRegCntlOut.regReq = '1') then
         -- Ack non existant registers too so they don't fail
         v.frontEndRegCntlIn.regAck := '1';
      end if;

      rin <= v;

      frontEndRegCntlIn  <= r.frontEndRegCntlIn;
      softwareReset      <= r.softwareReset;
      kpixRegCntlIn      <= r.kpixRegCntlIn;
      triggerRegsIn      <= r.triggerRegsIn;
      kpixConfigRegs     <= r.kpixConfigRegs;
      kpixClockGenRegsIn <= r.kpixClockGenRegsIn;
      kpixLocalRegsIn    <= r.kpixLocalRegsIn;
      kpixDataRxRegsIn   <= r.kpixDataRxRegsIn;
      
   end process comb;

end architecture rtl;
