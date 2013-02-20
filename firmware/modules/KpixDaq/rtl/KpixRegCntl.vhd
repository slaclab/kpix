-------------------------------------------------------------------------------
-- Title      : KPIX Transmit Module
-------------------------------------------------------------------------------
-- File       : KpixTx.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2013-02-20
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Transmits Register and Command regests to a configurable
-- number of KPIX modules.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;
use work.SynchronizePkg.all;
use work.KpixPkg.all;
use work.KpixLocalPkg.all;
use work.KpixRegRxPkg.all;
use work.KpixDataRxPkg.all;
use work.FrontEndPkg.all;
use work.TriggerPkg.all;

entity KpixRegCntl is
  
  generic (
    DELAY_G            : time    := 1 ns;  -- Simulation register delay
    NUM_KPIX_MODULES_G : natural := 4);

  port (
    sysClk : in sl;
    sysRst : in sl;

    -- Interface to Reg Control (sysClk domain)
    kpixRegCntlIn  : in  FrontEndRegCntlOutType;
    kpixRegCntlOut : out FrontEndRegCntlInType;

    -- Interface with start/trigger module
    triggerOut : in TriggerOutType;

    -- Interface with local KPIX
    kpixAnalogState  : in slv(2 downto 0);
    kpixReadoutState : in slv(2 downto 0);

    -- Interface with internal registers
    kpixConfigRegs : in KpixConfigRegsType;

    ----------------------------------
    kpixClk    : in sl;
    kpixClkRst : in sl;

    -- Interface with kpix register rx modules
    kpixRegRxOut : in KpixRegRxOutArray(NUM_KPIX_MODULES_G downto 0);

    -- Serial outout to KPIX modules
    kpixSerTxOut   : out slv(NUM_KPIX_MODULES_G downto 0);
    kpixTriggerOut : out sl;
    kpixResetOut   : out sl
    );

end entity KpixRegCntl;

architecture rtl of KpixRegCntl is

  subtype REG_ADDR_RANGE_C is natural range 6 downto 0;
  subtype KPIX_ADDR_RANGE_C is natural range 15 downto 8;
  subtype VALID_KPIX_ADDR_RANGE_C is natural range 8+log2(NUM_KPIX_MODULES_G) downto 8;
  subtype INVALID_KPIX_ADDR_RANGE_C is natural range 15 downto VALID_KPIX_ADDR_RANGE_C'high+1;

  constant DATA_WAIT_CYCLES_C  : natural := 255;
  constant WRITE_WAIT_CYCLES_C : natural := 20;
  constant READ_WAIT_CYCLES_C  : natural := 63;

  -----------------------------------------------------------------------------
  -- kpixClk clocked registers
  -----------------------------------------------------------------------------
  type StateType is (IDLE_S, PARITY_S, TRANSMIT_S, DATA_WAIT_S, WRITE_WAIT_S, READ_WAIT_S, WAIT_RELEASE_S);

  type RegType is record
    -- Synchronizer for inputs from sysClock domain
    regReqSync         : SynchronizerType;
    startAcquireSync   : SynchronizerType;
    startCalibrateSync : SynchronizerType;
    startReadoutSync   : SynchronizerType;
    triggerSync        : SynchronizerType;
    kpixResetSync      : SynchronizerType;
    kpixDataRxBusySync : SynchronizerArray(NUM_KPIX_MODULES_G-1 downto 0);

    -- Internal registers
    state          : StateType;         -- State machine state
    txShiftReg     : slv(0 to KPIX_NUM_TX_BITS_C-1);  -- Range direction matches documentation
    txShiftCount   : unsigned(log2(KPIX_NUM_TX_BITS_C)+1 downto 0);  -- Counter for shifting
    txEnable       : slv(NUM_KPIX_MODULES_G downto 0);               -- Enables for each serial
                                                                     -- outpus
    -- Output Registers
    kpixRegCntlOut : FrontEndRegCntlInType;  -- outputs to FrontEndRegCntl (must still be sync'd)
    kpixSerTxOut   : slv(NUM_KPIX_MODULES_G downto 0);               -- serial data to each kpix
  end record RegType;

  signal r, rin           : RegType;
  signal kpixSerTxOutFall : slv(NUM_KPIX_MODULES_G downto 0);

  -----------------------------------------------------------------------------
  -- sysClk clocked registers
  -----------------------------------------------------------------------------
  type SysRegType is record
    kpixResetHold   : sl;
    kpixResetReSync : SynchronizerType;
    regAckSync      : SynchronizerType;
    regFailSync     : SynchronizerType;
  end record SysRegType;

  signal sysR, sysRin : SysRegType;

begin

  seq : process (kpixClk, kpixClkRst) is
  begin
    if (kpixClkRst = '1') then
      r.regReqSync               <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.startAcquireSync         <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.startCalibrateSync       <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.startReadoutSync         <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.triggerSync              <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.kpixResetSync            <= SYNCHRONIZER_INIT_1_C after DELAY_G;  
      r.state                    <= IDLE_S                after DELAY_G;
      r.txShiftReg               <= (others => '0')       after DELAY_G;
      r.txShiftCount             <= (others => '0')       after DELAY_G;
      r.txEnable                 <= (others => '0')       after DELAY_G;
      r.kpixRegCntlOut.regAck    <= '0'                   after DELAY_G;
      r.kpixRegCntlOut.regFail   <= '0'                   after DELAY_G;
      r.kpixRegCntlOut.regDataIn <= (others => '0')       after DELAY_G;
      r.kpixSerTxOut             <= (others => '0')       after DELAY_G;
    elsif (rising_edge(kpixClk)) then
      r <= rin after DELAY_G;
    end if;
  end process seq;

  comb : process (r, kpixRegCntlIn, triggerOut, kpixRegRxOut, sysR) is
    variable rVar             : RegType;
    variable addressedKpixVar : natural;
  begin
    rVar := r;

    rVar.kpixSerTxOut := (others => '0');

    -- Synchronize sysClk inputs to kpixClk
    synchronize(kpixRegCntlIn.regReq, r.regReqSync, rVar.regReqSync);
    synchronize(triggerOut.startAcquire, r.startAcquireSync, rVar.startAcquireSync);
    synchronize(triggerOut.startCalibrate, r.startCalibrateSync, rVar.startCalibrateSync);
    synchronize(triggerOut.startReadout, r.startReadoutSync, rVar.startReadoutSync);
    synchronize(triggerOut.trigger, r.triggerSync, rVar.triggerSync);
    synchronize(sysR.kpixResetHold, r.kpixResetSync, rVar.kpixResetSync);

    case (r.state) is
      when IDLE_S =>
        rVar.txShiftCount := (others => '0');
        rVar.txEnable     := (others => '0');
        -- Only start new reg access or data acquisition cycle if previous data acq cycle is done
        -- (indicated by all KpixDataRx modules being not busy
        -- if (isZero(toSlvSync(r.kpixDataRxBusySync))) then
        if (r.regReqSync.sync = '1' and uOr(kpixRegCntlIn.regAddr(INVALID_KPIX_ADDR_RANGE_C)) = '0') then
          -- Register access, format output word
          rVar.txShiftReg                               := (others => '0');  -- Simplifies parity calc
          rVar.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
          rVar.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
          rVar.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_REG_ACCESS_C;
          rVar.txShiftReg(KPIX_WRITE_INDEX_C)           := kpixRegCntlIn.regOp;  --r.regOpSync.sync;
          rVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := bitReverse(kpixRegCntlIn.regAddr(REG_ADDR_RANGE_C));
          rVar.txShiftReg(KPIX_DATA_RANGE_C)            := bitReverse(kpixRegCntlIn.regDataOut);
          if (kpixRegCntlIn.regOp = '0') then  -- Override data field with 0s of doing a read
            rVar.txShiftReg(KPIX_DATA_RANGE_C) := (others => '0');
          end if;
          rVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C) := '0';
          rVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)   := '0';
          rVar.txShiftCount                           := (others => '0');
          addressedKpixVar                            := to_integer(unsigned(kpixRegCntlIn.regAddr(VALID_KPIX_ADDR_RANGE_C)));
          rVar.txEnable                               := (others => '0');
          rVar.txEnable(addressedKpixVar)             := '1';
          rVar.state                                  := PARITY_S;

        elsif (r.startReadoutSync.sync = '1') then
          -- Start a readout (only used with autoReadDisable)
          rVar.txShiftReg                               := (others => '0');
          rVar.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
          rVar.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
          rVar.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_CMD_RSP_ACCESS_C;
          rVar.txShiftReg(KPIX_WRITE_INDEX_C)           := KPIX_WRITE_C;
          rVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_READOUT_CMD_ID_REV_C;
          rVar.txShiftReg(KPIX_DATA_RANGE_C)            := (others => '0');
          rVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C)   := '0';
          rVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)     := '0';
          rVar.txShiftCount                             := (others => '0');
          rVar.txEnable                                 := (others => '1');  -- Enable all
          rVar.state                                    := PARITY_S;

        elsif (r.startAcquireSync.sync = '1') then
          -- Start an acquisition
          rVar.txShiftReg                               := (others => '0');
          rVar.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
          rVar.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
          rVar.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_CMD_RSP_ACCESS_C;
          rVar.txShiftReg(KPIX_WRITE_INDEX_C)           := KPIX_WRITE_C;
          rVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_ACQUIRE_CMD_ID_REV_C;
          rVar.txShiftReg(KPIX_DATA_RANGE_C)            := (others => '0');
          rVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C)   := '0';
          rVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)     := '0';
          rVar.txShiftCount                             := (others => '0');
          rVar.txEnable                                 := (others => '1');  -- Enable all
          rVar.state                                    := PARITY_S;
          if (triggerOut.startCalibrate = '1') then
            rVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_CALIBRATE_CMD_ID_REV_C;
          end if;
        end if;
        -- end if;
        
      when PARITY_S =>
        rVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C) := not evenParity(r.txShiftReg(KPIX_FULL_HEADER_RANGE_C));
        rVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)   := not evenParity(r.txShiftReg(KPIX_FULL_DATA_RANGE_C));
        rVar.txShiftCount                           := (others => '0');
        rVar.kpixSerTxOut                           := r.txEnable;  -- Start bit
        rVar.state                                  := TRANSMIT_S;

      when TRANSMIT_S =>
        -- Shift (select) out each bit, gated by rxEnable
        rVar.txShiftCount := r.txShiftCount + 1;
        rVar.txShiftReg   := r.txShiftReg(1 to KPIX_NUM_TX_BITS_C-1) & '0';
        for i in r.txEnable'range loop
          rVar.kpixSerTxOut(i) := r.txShiftReg(0) and r.txEnable(i);
        end loop;
        if (r.txShiftCount = KPIX_NUM_TX_BITS_C) then  -- Check this
          rVar.txShiftCount := (others => '0');
          if (uAnd(r.txEnable) = '1') then
            -- All txEnable bits set indicates an acquire cmd being transmitted
            -- Don't need to wait for req to fall on CMD requests
            rVar.state := DATA_WAIT_S;
          else
            -- Register request
            if (kpixRegCntlIn.regOp = '1') then
              rVar.state := WRITE_WAIT_S;
            else
              rVar.state := READ_WAIT_S;
            end if;
          end if;
        end if;

      when DATA_WAIT_S =>
        -- Wait for kpix core state to be idle
        -- Having gone through acquire, digitize and (maybe) readout.
        if (kpixAnalogState = KPIX_ANALOG_IDLE_STATE_C and
            kpixReadoutState = KPIX_READOUT_IDLE_STATE_C) then
          rVar.state := IDLE_S;
        end if;

      when WRITE_WAIT_S =>
        -- Wait a defined number of cycles before acking write
        -- Keeps KPIX from being overwhelmed
        rVar.txShiftCount := r.txShiftCount + 1;
        if (r.txShiftCount = WRITE_WAIT_CYCLES_C) then
          rVar.kpixRegCntlOut.regAck := '1';
          rVar.state                 := WAIT_RELEASE_S;
        end if;

      when READ_WAIT_S =>
        -- Wait for read response
        -- Timeout and fail after defined number of cycles
        rVar.txShiftCount := r.txShiftCount + 1;
        addressedKpixVar  := to_integer(unsigned(kpixRegCntlIn.regAddr(VALID_KPIX_ADDR_RANGE_C)));  --VALID_KPIX_ADDR_RANGE_C
        if (kpixRegRxOut(addressedKpixVar).regValid = '1' and
            kpixRegRxOut(addressedKpixVar).regAddr = kpixRegCntlIn.regAddr(REG_ADDR_RANGE_C)) then  -- REG_ADDR_RANGE_C
          -- Only ack when kpix id and reg addr is the same as tx'd
          rVar.kpixRegCntlOut.regDataIn := kpixRegRxOut(addressedKpixVar).regData;
          rVar.kpixRegCntlOut.regAck    := '1';
          rVar.kpixRegCntlOut.regFail   := kpixRegRxOut(addressedKpixVar).regParityErr;
          rVar.state                    := WAIT_RELEASE_S;
        elsif (r.txShiftCount = READ_WAIT_CYCLES_C) then
          rVar.kpixRegCntlOut.regAck  := '1';
          rVar.kpixRegCntlOut.regFail := '1';
          rVar.state                  := WAIT_RELEASE_S;
        end if;

      when WAIT_RELEASE_S =>
        if (r.regReqSync.sync = '0') then
          -- Can't deassert ack until regReq is dropped
          rVar.kpixRegCntlOut.regAck  := '0';
          rVar.kpixRegCntlOut.regFail := '0';
          rVar.txEnable               := (others => '0');
          rVar.state                  := IDLE_S;
        end if;

    end case;

    -- Registers
    rin <= rVar;

    -- Outputs
    --kpixSerTxOut   <= r.kpixSerTxOut;
    kpixTriggerOut <= r.triggerSync.sync;
    kpixResetOut   <= r.kpixResetSync.sync;
    
  end process comb;

  -----------------------------------------------------------------------------
  -- kpixReset pulse must be caught and held so it can be sync'd to kpixClock
  -- KpixRegCntlIn signals must be synchronized back to sysClk
  -----------------------------------------------------------------------------
  sysSync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      sysR.kpixResetHold   <= '0'                   after DELAY_G;
      sysR.kpixResetReSync <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      sysR.regAckSync      <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      sysR.regFailSync     <= SYNCHRONIZER_INIT_0_C after DELAY_G;
    elsif (rising_edge(sysClk)) then
      sysR <= sysRin after DELAY_G;
    end if;
  end process sysSync;

  sysComb : process (sysR, r, kpixConfigRegs) is
    variable rVar : SysRegType;
  begin
    rVar := sysR;

    -- Latch in kpixReset pulse from front end register
    if (kpixConfigRegs.kpixReset = '1') then
      rVar.kpixResetHold := '1';
    end if;
    -- kpixResetHold goes to kpixClk logic where it is synced to kpixClk
    -- Resynchronize that back to sysClk and use that to reset kpixResetHold
    synchronize(r.kpixResetSync.sync, sysR.kpixResetReSync, rVar.kpixResetReSync);
    if (sysR.kpixResetReSync.sync = '1' and kpixConfigRegs.kpixReset = '0') then
      rVar.kpixResetHold := '0';
    end if;

    -- Sync front end control signals back to sysclk
    synchronize(r.kpixRegCntlOut.regAck, sysR.regAckSync, rVar.regAckSync);
    synchronize(r.kpixRegCntlOut.regFail, sysR.regFailSync, rVar.regFailSync);

    sysRin                   <= rVar;
    -- Outputs
    kpixRegCntlOut.regAck    <= sysR.regAckSync.sync;
    kpixRegCntlOut.regFail   <= sysR.regFailSync.sync;
    kpixRegCntlOut.regDataIn <= r.kpixRegCntlOut.regDataIn;
  end process sysComb;

  fallingClk : process (kpixClk, kpixClkRst) is
  begin
    if (kpixClkRst = '1') then
      kpixSerTxOutFall <= (others => '0') after DELAY_G;
    elsif (falling_edge(kpixClk)) then
      kpixSerTxOutFall <= r.kpixSerTxOut after DELAY_G;
    end if;
  end process fallingClk;

  kpixSerTxOut <= r.kpixSerTxOut when kpixConfigRegs.outputEdge = '0' else kpixSerTxOutFall;

end architecture rtl;
