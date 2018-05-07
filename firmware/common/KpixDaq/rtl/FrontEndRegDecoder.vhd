-------------------------------------------------------------------------------
-- Title      : Front End Register Interface Decoder
-------------------------------------------------------------------------------
-- File       : FrontEndRegDecoder.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2013-08-01
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
use work.VcPkg.all;
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
      regSlaveOut : in  VcRegSlaveOutType;
      regSlaveIn  : out VcRegSlaveInType;

      -- Allows firmware to be reset through FrontEnd
      softwareReset : out sl;

      -- Interface to KPIX reg controller (reuse VcRegSlave types)
      kpixRegCntlOut : in  VcRegSlaveInType;
      kpixRegCntlIn  : out VcRegSlaveOutType;

      -- Interface to local module registers
      triggerRegsIn      : out TriggerRegsInType;
      kpixConfigRegs     : out KpixConfigRegsType;
      kpixClockGenRegsIn : out KpixClockGenRegsInType;
      kpixLocalRegsIn    : out KpixLocalRegsInType;
      kpixDataRxRegsIn   : out KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
      kpixDataRxRegsOut  : in  KpixDataRxRegsOutArray(NUM_KPIX_MODULES_G-1 downto 0));

end entity FrontEndRegDecoder;

architecture rtl of FrontEndRegDecoder is

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
      kpixRegCntlOut     : VcRegSlaveInType;   -- pipeline delay
      regSlaveIn         : VcRegSlaveInType;   -- Outputs to FrontEnd module
      softwareReset      : sl;
      kpixRegCntlIn      : VcRegSlaveOutType;  -- Outputs to KpixRegCntl module
      triggerRegsIn      : TriggerRegsInType;
      kpixConfigRegs     : KpixConfigRegsType;
      kpixClockGenRegsIn : KpixClockGenRegsInType;
      kpixLocalRegsIn    : KpixLocalRegsInType;
      kpixDataRxRegsIn   : KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType := (
      kpixRegCntlOut     => VC_REG_SLAVE_IN_INIT_C,
      regSlaveIn         => VC_REG_SLAVE_IN_INIT_C,
      softwareReset      => '0',
      kpixRegCntlIn      => VC_REG_SLAVE_OUT_INIT_C,
      triggerRegsIn      => TRIGGER_REGS_IN_INIT_C,
      kpixConfigRegs     => KPIX_CONFIG_REGS_INIT_C,
      kpixClockGenRegsIn => KPIX_CLOCK_GEN_REGS_INIT_C,
      kpixLocalRegsIn    => KPIX_LOCAL_REGS_IN_INIT_C,
      kpixDataRxRegsIn   => (others => KPIX_DATA_RX_REGS_IN_INIT_C));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   sync : process (sysClk) is
   begin
      if (rising_edge(sysClk)) then
         if (sysRst = '1') then
            r <= REG_INIT_C after DELAY_G;
         else
            r <= rin after DELAY_G;
         end if;
      end if;
   end process sync;

   comb : process (r, regSlaveOut, kpixDataRxRegsOut, kpixRegCntlOut) is
      variable v            : RegType;
      variable addrIndexVar : integer;
      variable kpixIndexVar : integer;
   begin
      v := r;

      -- Pipeline 1 cycle to ease timing across boundary
      v.kpixRegCntlOut := kpixRegCntlOut;

      v.regSlaveIn.ack    := '0';
      v.regSlaveIn.rdData := (others => '0');
      v.regSlaveIn.fail   := '0';

      v.kpixRegCntlIn.inp    := '0';
      v.kpixRegCntlIn.req    := '0';
      v.kpixRegCntlIn.op     := '0';
      v.kpixRegCntlIn.addr   := (others => '0');  -- Not necessary
      v.kpixRegCntlIn.wrData := (others => '0');  -- Not necessary

      -- Pulse these for 1 cycle only when accessed
      v.kpixConfigRegs.kpixReset := '0';
      for i in NUM_KPIX_MODULES_G-1 downto 0 loop
         v.kpixDataRxRegsIn(i).resetHeaderParityErrorCount := '0';
         v.kpixDataRxRegsIn(i).resetDataParityErrorCount   := '0';
         v.kpixDataRxRegsIn(i).resetMarkerErrorCount       := '0';
         v.kpixDataRxRegsIn(i).resetOverflowErrorCount     := '0';
      end loop;

      if (regSlaveOut.addr(ADDR_BLOCK_RANGE_C) = KPIX_REGS_ADDR_C) then
         -- KPIX regs being accessed
         -- Pass FrontEndCntl io right though
         -- Will revert back when regSlaveOut.req falls
         v.kpixRegCntlIn := regSlaveOut;
         v.regSlaveIn    := r.kpixRegCntlOut;

      -- Wait for an access request
      elsif (regSlaveOut.addr(ADDR_BLOCK_RANGE_C) = LOCAL_REGS_ADDR_C and
             regSlaveOut.req = '1') then

         -- Local Regs being accessed

         -- Ack right away
         v.regSlaveIn.ack := '1';

         -- Peform register access
         if (regSlaveOut.addr(8) = '0') then
            -- Access general registers

            addrIndexVar := to_integer(unsigned(regSlaveOut.addr(3 downto 0)));
            case (addrIndexVar) is

               when VERSION_REG_ADDR_C =>
                  v.regSlaveIn.rdData := FPGA_VERSION_C;

               when CLOCK_SELECT_A_REG_ADDR_C =>
                  -- Only use 8 bits of these registers for legacy purposes
                  v.regSlaveIn.rdData(31 downto 24) := r.kpixClockGenRegsIn.clkSelReadout(7 downto 0);
                  v.regSlaveIn.rdData(23 downto 16) := r.kpixClockGenRegsIn.clkSelDigitize(7 downto 0);
                  v.regSlaveIn.rdData(15 downto 8)  := r.kpixClockGenRegsIn.clkSelAcquire(7 downto 0);
                  v.regSlaveIn.rdData(7 downto 0)   := r.kpixClockGenRegsIn.clkSelIdle(7 downto 0);
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixClockGenRegsIn.clkSelReadout(7 downto 0)  := regSlaveOut.wrData(31 downto 24);
                     v.kpixClockGenRegsIn.clkSelDigitize(7 downto 0) := regSlaveOut.wrData(23 downto 16);
                     v.kpixClockGenRegsIn.clkSelAcquire(7 downto 0)  := regSlaveOut.wrData(15 downto 8);
                     v.kpixClockGenRegsIn.clkSelIdle(7 downto 0)     := regSlaveOut.wrData(7 downto 0);
                  end if;

               when CLOCK_SELECT_B_REG_ADDR_C =>
                  -- Precharge is the only 12 bit clock register, others are 8.
                  v.regSlaveIn.rdData(11 downto 0) := r.kpixClockGenRegsIn.clkSelPrecharge;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixClockGenRegsIn.clkSelPrecharge := regSlaveOut.wrData(11 downto 0);
                  end if;

               when DEBUG_SELECT_REG_ADDR_C =>
                  v.regSlaveIn.rdData(4 downto 0)  := r.kpixLocalRegsIn.debugASel;
                  v.regSlaveIn.rdData(12 downto 8) := r.kpixLocalRegsIn.debugBsel;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixLocalRegsIn.debugASel := regSlaveOut.wrData(4 downto 0);
                     v.kpixLocalRegsIn.debugBsel := regSlaveOut.wrData(12 downto 8);
                  end if;

               when TRIGGER_CONTROL_REG_ADDR_C =>
                  v.regSlaveIn.rdData(2 downto 0) := r.triggerRegsIn.extTriggerSrc;
                  v.regSlaveIn.rdData(4)          := r.triggerRegsIn.calibrate;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.triggerRegsIn.extTriggerSrc := regSlaveOut.wrData(2 downto 0);
                     v.triggerRegsIn.calibrate     := regSlaveOut.wrData(4);
                  end if;

               when KPIX_RESET_REG_ADDR_C =>
                  v.regSlaveIn.rdData(0) := r.kpixConfigRegs.kpixReset;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixConfigRegs.kpixReset := regSlaveOut.wrData(0);
                  end if;

               when KPIX_CONFIG_REG_ADDR_C =>
                  v.regSlaveIn.rdData(0)           := r.kpixConfigRegs.inputEdge;
                  v.regSlaveIn.rdData(1)           := r.kpixConfigRegs.outputEdge;
                  v.regSlaveIn.rdData(4)           := r.kpixConfigRegs.rawDataMode;
                  v.regSlaveIn.rdData(12 downto 8) := r.kpixConfigRegs.numColumns;
                  v.regSlaveIn.rdData(16)          := r.kpixConfigRegs.autoReadDisable;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixConfigRegs.inputEdge       := regSlaveOut.wrData(0);
                     v.kpixConfigRegs.outputEdge      := regSlaveOut.wrData(1);
                     v.kpixConfigRegs.rawDataMode     := regSlaveOut.wrData(4);
                     v.kpixConfigRegs.numColumns      := regSlaveOut.wrData(12 downto 8);
                     v.kpixConfigRegs.autoReadDisable := regSlaveOut.wrData(16);
                  end if;

               when TIMESTAMP_CONTROL_REG_ADDR_C =>
                  v.regSlaveIn.rdData(2 downto 0) := r.triggerRegsIn.extTimestampSrc;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.triggerRegsIn.extTimestampSrc := regSlaveOut.wrData(2 downto 0);
                  end if;

               when ACQUISITION_CONTROL_REG_ADDR_C =>
                  v.regSlaveIn.rdData(1 downto 0) := r.triggerRegsIn.acquisitionSrc;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.triggerRegsIn.acquisitionSrc := regSlaveOut.wrData(1 downto 0);
                  end if;


               when SOFTWARE_RESET_REG_ADDR_C =>
                  v.regSlaveIn.rdData(0) := r.softwareReset;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.softwareReset := regSlaveOut.wrData(0);
                  end if;

               when others =>
                  null;
            end case;
         else                           -- (regSlaveOut.addr(8) = '1')
            -- Access per KpixDataRx registers
            kpixIndexVar := to_integer(unsigned(regSlaveOut.addr(7 downto 3)));
            addrIndexVar := to_integer(unsigned(regSlaveOut.addr(2 downto 0)));

            case addrIndexVar is
               when KPIX_DATA_RX_MODE_REG_ADDR_C =>
                  v.regSlaveIn.rdData(0) := r.kpixDataRxRegsIn(kpixIndexVar).enabled;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).enabled := regSlaveOut.wrData(0);
                  end if;

               when KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C =>
                  v.regSlaveIn.rdData := kpixDataRxRegsOut(kpixIndexVar).headerParityErrorCount;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetHeaderParityErrorCount := '1';
                  end if;

               when KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C =>
                  v.regSlaveIn.rdData := kpixDataRxRegsOut(kpixIndexVar).dataParityErrorCount;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetDataParityErrorCount := '1';
                  end if;

               when KPIX_MARKER_ERROR_COUNT_REG_ADDR_C =>
                  v.regSlaveIn.rdData := kpixDataRxRegsOut(kpixIndexVar).markerErrorCount;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetMarkerErrorCount := '1';
                  end if;

               when KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C =>
                  v.regSlaveIn.rdData := kpixDataRxRegsOut(kpixIndexVar).overflowErrorCount;
                  if (regSlaveOut.op = VC_REG_SLAVE_WR_OP_C) then
                     v.kpixDataRxRegsIn(kpixIndexVar).resetOverflowErrorCount := '1';
                  end if;


               when others => null;
            end case;
         end if;
      elsif (regSlaveOut.req = '1') then
         -- Ack non existant registers too so they don't fail
         v.regSlaveIn.ack := '1';
      end if;

      rin <= v;

      regSlaveIn         <= r.regSlaveIn;
      softwareReset      <= r.softwareReset;
      kpixRegCntlIn      <= r.kpixRegCntlIn;
      triggerRegsIn      <= r.triggerRegsIn;
      kpixConfigRegs     <= r.kpixConfigRegs;
      kpixClockGenRegsIn <= r.kpixClockGenRegsIn;
      kpixLocalRegsIn    <= r.kpixLocalRegsIn;
      kpixDataRxRegsIn   <= r.kpixDataRxRegsIn;
      
   end process comb;

end architecture rtl;
