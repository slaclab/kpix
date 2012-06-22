-------------------------------------------------------------------------------
-- Title      : KPIX Transmit Module
-------------------------------------------------------------------------------
-- File       : KpixTx.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2012-06-22
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
use work.KpixRegRxPkg.all;
use work.KpixDataRxPkg.all;
use work.EthFrontEndPkg.all;
use work.TriggerPkg.all;
use work.KpixRegCntlPkg.all;

entity KpixRegCntl is
  
  generic (
    DELAY_G            : time    := 1 ns;  -- Simulation register delay
    NUM_KPIX_MODULES_G : natural := 4);

  port (
    sysClk : in sl;
    sysRst : in sl;

    -- Interface to Reg Control (sysClk domain)
    ethRegCntlOut : in  EthRegCntlOutType;
    ethRegCntlIn  : out EthRegCntlInType;

    -- Interface with start/trigger module
    triggerOut : in TriggerOutType;

    -- Interface with kpix data rx modules (for busy signal)
    kpixDataRxOut : in KpixDataRxOutArray(NUM_KPIX_MODULES_G-1 downto 0);

    -- Interface with internal registers
    kpixConfigRegs : in KpixConfigRegsType;
    extRegsIn      : in KpixRegCntlRegsInType;

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

  constant DATA_WAIT_CYCLES_C : natural := 255;
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
    triggerSync        : SynchronizerType;
    kpixResetSync      : SynchronizerType;
    kpixDataRxBusySync : SynchronizerArray(NUM_KPIX_MODULES_G-1 downto 0);

    -- Internal registers
    state        : StateType;           -- State machine state
    txShiftReg   : slv(0 to KPIX_NUM_TX_BITS_C-1);  -- Range direction matches documentation
    txShiftCount : unsigned(log2(KPIX_NUM_TX_BITS_C)+1 downto 0);  -- Counter for shifting
    txEnable     : slv(NUM_KPIX_MODULES_G downto 0);               -- Enables for each serial
                                                                   -- outpus
    -- Output Registers
    ethRegCntlIn : EthRegCntlInType;    -- outputs to EthRegCntl (must still be sync'd)
    kpixSerTxOut : slv(NUM_KPIX_MODULES_G downto 0);               -- serial data to each kpix
  end record RegType;

  signal r, rin           : RegType;
  signal kpixSerTxOutFall : slv(NUM_KPIX_MODULES_G downto 0);

  -----------------------------------------------------------------------------
  -- sysClk clocked registers
  -----------------------------------------------------------------------------
  type SysRegType is record
    regAckSync  : SynchronizerType;
    regFailSync : SynchronizerType;
  end record SysRegType;

  signal sysR, sysRin : SysRegType;

begin

  seq : process (kpixClk, kpixClkRst) is
  begin
    if (kpixClkRst = '1') then
      r.regReqSync             <= SYNCHRONIZER_INIT_0_C             after DELAY_G;
      r.startAcquireSync       <= SYNCHRONIZER_INIT_0_C             after DELAY_G;
      r.startCalibrateSync     <= SYNCHRONIZER_INIT_0_C             after DELAY_G;
      r.triggerSync            <= SYNCHRONIZER_INIT_0_C             after DELAY_G;
      r.kpixResetSync          <= SYNCHRONIZER_INIT_0_C             after DELAY_G;
      r.kpixDataRxBusySync     <= (others => SYNCHRONIZER_INIT_0_C) after DELAY_G;
      r.state                  <= IDLE_S                            after DELAY_G;
      r.txShiftReg             <= (others => '0')                   after DELAY_G;
      r.txShiftCount           <= (others => '0')                   after DELAY_G;
      r.txEnable               <= (others => '0')                   after DELAY_G;
      r.ethRegCntlIn.regAck    <= '0'                               after DELAY_G;
      r.ethRegCntlIn.regFail   <= '0'                               after DELAY_G;
      r.ethRegCntlIn.regDataIn <= (others => '0')                   after DELAY_G;
      r.kpixSerTxOut           <= (others => '0')                   after DELAY_G;
    elsif (rising_edge(kpixClk)) then
      r <= rin after DELAY_G;
    end if;
  end process seq;

  comb : process (r, ethRegCntlOut, triggerOut, kpixRegRxOut) is
    variable rVar             : RegType;
    variable addressedKpixVar : natural;
  begin
    rVar := r;

    rVar.kpixSerTxOut := (others => '0');

    -- Synchronize sysClk inputs to kpixClk
    synchronize(ethRegCntlOut.regReq, r.regReqSync, rVar.regReqSync);
    synchronize(triggerOut.startAcquire, r.startAcquireSync, rVar.startAcquireSync);
    synchronize(triggerOut.startCalibrate, r.startCalibrateSync, rVar.startCalibrateSync);
    synchronize(triggerOut.trigger, r.triggerSync, rVar.triggerSync);
    synchronize(extRegsIn.kpixReset, r.kpixResetSync, rVar.kpixResetSync);

    -- Synchronize dataRx busy signals to kpixClk
    -- Reset txEnable upon the falling edge of each
    -- New register accesses or data rx cycles will not be processed here until all txEnable signals
    -- from the previous cycle are 0.
    for i in NUM_KPIX_MODULES_G-1 downto 0 loop
      synchronize(kpixDataRxOut(i).busy, r.kpixDataRxBusySync(i), rVar.kpixDataRxBusySync(i));
    end loop;

    case (r.state) is
      when IDLE_S =>
        rVar.txShiftCount := (others => '0');
        rVar.txEnable := (others => '0');
        -- Only start new reg access or data acquisition cycle if previous data acq cycle is done
        -- (indicated by all KpixDataRx modules being not busy
        if (isZero(toSlvSync(r.kpixDataRxBusySync))) then
          if (r.regReqSync.sync = '1' and isZero(ethRegCntlOut.regAddr(INVALID_KPIX_ADDR_RANGE_C))) then
            -- Register access, format output word
            rVar.txShiftReg                               := (others => '0');  -- Simplifies parity calc
            rVar.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
            rVar.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
            rVar.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_REG_ACCESS_C;
            rVar.txShiftReg(KPIX_WRITE_INDEX_C)           := ethRegCntlOut.regOp;  --r.regOpSync.sync;
            rVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := bitReverse(ethRegCntlOut.regAddr(REG_ADDR_RANGE_C));
            rVar.txShiftReg(KPIX_DATA_RANGE_C)            := bitReverse(ethRegCntlOut.regDataOut);
            if (ethRegCntlOut.regOp = '0') then  -- Override data field with 0s of doing a read
              rVar.txShiftReg(KPIX_DATA_RANGE_C) := (others => '0');
            end if;
            rVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C) := '0';
            rVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)   := '0';
            rVar.txShiftCount                           := (others => '0');
            addressedKpixVar                            := to_integer(unsigned(ethRegCntlOut.regAddr(VALID_KPIX_ADDR_RANGE_C)));
            rVar.txEnable                               := (others => '0');
            rVar.txEnable(addressedKpixVar)             := '1';
            rVar.state                                  := PARITY_S;

          elsif (r.startAcquireSync.sync = '1') then
            -- Cmd access
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
            if (r.startCalibrateSync.sync = '1') then
              rVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_CALIBRATE_CMD_ID_REV_C;
            end if;
          end if;
        end if;
        
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
          if (isAll(r.txEnable, '1')) then
            -- All txEnable bits set indicates an acquire cmd being transmitted
            -- Don't need to wait for req to fall on CMD requests
            rVar.state := DATA_WAIT_S;
          else
            -- Register request
            if (ethRegCntlOut.regOp = '1') then
              rVar.state := WRITE_WAIT_S;
            else
              rVar.state := READ_WAIT_S;
            end if;
          end if;
        end if;

      when DATA_WAIT_S =>
        -- Wait for KpixDataRx modules to start getting data and assert busy
        rVar.txShiftCount := r.txShiftCount + 1;
        if (r.txShiftCount = DATA_WAIT_CYCLES_C) then
          rVar.state := IDLE_S;
        end if;

      when WRITE_WAIT_S =>
        -- Wait a defined number of cycles before acking write
        -- Keeps KPIX from being overwhelmed
        rVar.txShiftCount := r.txShiftCount + 1;
        if (r.txShiftCount = WRITE_WAIT_CYCLES_C) then
          rVar.ethRegCntlIn.regAck := '1';
          rVar.state               := WAIT_RELEASE_S;
        end if;

      when READ_WAIT_S =>
        -- Wait for read response
        -- Timeout and fail after defined number of cycles
        rVar.txShiftCount := r.txShiftCount + 1;
        addressedKpixVar  := to_integer(unsigned(ethRegCntlOut.regAddr(VALID_KPIX_ADDR_RANGE_C)));  --VALID_KPIX_ADDR_RANGE_C
        if (kpixRegRxOut(addressedKpixVar).regValid = '1' and
            kpixRegRxOut(addressedKpixVar).regAddr = ethRegCntlOut.regAddr(REG_ADDR_RANGE_C)) then  -- REG_ADDR_RANGE_C
          -- Only ack when kpix id and reg addr is the same as tx'd
          rVar.ethRegCntlIn.regDataIn := kpixRegRxOut(addressedKpixVar).regData;
          rVar.ethRegCntlIn.regAck    := '1';
          rVar.ethRegCntlIn.regFail   := kpixRegRxOut(addressedKpixVar).regParityErr;
          rVar.state                  := WAIT_RELEASE_S;
        elsif (r.txShiftCount = READ_WAIT_CYCLES_C) then
          rVar.ethRegCntlIn.regAck  := '1';
          rVar.ethRegCntlIn.regFail := '1';
          rVar.state                := WAIT_RELEASE_S;
        end if;

      when WAIT_RELEASE_S =>
        if (r.regReqSync.sync = '0') then
          -- Can't deassert ack until regReq is dropped
          rVar.ethRegCntlIn.regAck  := '0';
          rVar.ethRegCntlIn.regFail := '0';
          rVar.txEnable             := (others => '0');
          rVar.state                := IDLE_S;
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
  -- EthRegCntlIn signals must be synchronized back to sysClk
  -----------------------------------------------------------------------------
  sysSync : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
      sysR.regAckSync  <= SYNCHRONIZER_INIT_0_C;
      sysR.regFailSync <= SYNCHRONIZER_INIT_0_C;
    elsif (rising_edge(sysClk)) then
      sysR <= sysRin;
    end if;
  end process sysSync;

  sysComb : process (sysR, r) is
    variable rVar : SysRegType;
  begin
    rVar                   := sysR;
    synchronize(r.ethRegCntlIn.regAck, sysR.regAckSync, rVar.regAckSync);
    synchronize(r.ethRegCntlIn.regFail, sysR.regFailSync, rVar.regFailSync);
    sysRin                 <= rVar;
    -- Outputs
    ethRegCntlIn.regAck    <= sysR.regAckSync.sync;
    ethRegCntlIn.regFail   <= sysR.regFailSync.sync;
    ethRegCntlIn.regDataIn <= r.ethRegCntlIn.regDataIn;
  end process sysComb;

  fallingClk : process (kpixClk, kpixClkRst) is
  begin
    if (kpixClkRst = '1') then
      kpixSerTxOutFall <= (others => '0');
    elsif (falling_edge(kpixClk)) then
      kpixSerTxOutFall <= r.kpixSerTxOut;
    end if;
  end process fallingClk;

  kpixSerTxOut <= r.kpixSerTxOut when kpixConfigRegs.outputEdge = '0' else kpixSerTxOutFall;

end architecture rtl;
