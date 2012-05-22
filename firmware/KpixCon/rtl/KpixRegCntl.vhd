-------------------------------------------------------------------------------
-- Title      : KPIX Transmit Module
-------------------------------------------------------------------------------
-- File       : KpixTx.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2012-05-21
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
use work.EthFrontEndPkg.all;
use work.TriggerPkg.all;

entity KpixRegCntl is
  
  generic (
    DELAY_G            : time           := 1 ns;  -- Simulation register delay
    NUM_KPIX_MODULES_G : KpixNumberType := 4);

  port (
    sysClk  : in sl;
    sysRst  : in sl;
    kpixClk : in sl;
    kpixRst : in sl;

    -- Interface to Reg Control (sysClk domain)
    ethRegCntlOut : in  EthRegCntlOutType;
    ethRegCntlIn  : out EthRegCntlInType;

    -- Interface with start/trigger module
    triggerOut : in TriggerOutType;

    -- Interface with kpix register rx modules
    kpixRegRxOut : in KpixRegRxOutArray(NUM_KPIX_MODULES_G-1 downto 0);

    -- Interface with KpixTx module
    kpixSerTxOut : out slv(NUM_KPIX_MODULES_G-1 downto 0)
    );

end entity KpixRegCntl;

architecture rtl of KpixRegCntl is

  subtype REG_ADDR_RANGE_C is natural range 6 downto 0;
  subtype KPIX_ADDR_RANGE_C is natural range 17 downto 7;
  subtype VALID_KPIX_ADDR_RANGE_C is natural range 7+log2(NUM_KPIX_MODULES_G) downto 7;
  subtype INVALID_KPIX_ADDR_RANGE_C is natural range 17 downto 11-log2(NUM_KPIX_MODULES_G);

  constant WRITE_WAIT_CYCLES_C : natural := 20;
  constant READ_WAIT_CYCLES_C  : natural := 20;

  -----------------------------------------------------------------------------
  -- kpixClk clocked registers
  -----------------------------------------------------------------------------
  type StateType is (IDLE_S, PARITY_S, TRANSMIT_S, WRITE_WAIT_S, READ_WAIT_S, WAIT_RELEASE_S);

  type RegType is record
    -- Synchronizer for inputs from sysClock domain
    regInpSync         : SynchronizerType;
    regReqSync         : SynchronizerType;
    regOpSync          : SynchronizerType;
    startAcquireSync   : SynchronizerType;
    startCalibrateSync : SynchronizerType;

    -- Internal registers
    state        : StateType;           -- State machine state
    txShiftReg   : slv(0 to KPIX_NUM_TX_BITS_C-1);  -- Range direction matches documentation
    txShiftCount : unsigned(log2(KPIX_NUM_TX_BITS_C)-1 downto 0);  -- Counter for shifting
    txEnable     : slv(NUM_KPIX_MODULES_G-1 downto 0);             -- Enables for each serial
                                                                   -- outpus
    -- Output Registers
    ethRegCntlIn : EthRegCntlInType;    -- outputs to EthRegCntl (must still be sync'd)
    kpixSerTxOut : slv(NUM_KPIX_MODULES_G-1 downto 0);             -- serial data to each kpix
  end record RegType;

  signal r, rin : RegType;

  -----------------------------------------------------------------------------
  -- sysClk clocked registers
  -----------------------------------------------------------------------------
  type SysRegType is record
    regAckSync  : SynchronizerType;
    regFailSync : SynchronizerType;
  end record SysRegType;

  signal sysR, sysRin : SysRegType;

begin

  seq : process (kpixClk, kpixRst) is
  begin
    if (kpixRst = '1') then
      r.regInpSync             <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.regReqSync             <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.regOpSync              <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.startAcquireSync       <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.startCalibrateSync     <= SYNCHRONIZER_INIT_0_C after DELAY_G;
      r.state                  <= IDLE_S                after DELAY_G;
      r.txShiftReg             <= (others => '0')       after DELAY_G;
      r.txShiftCount           <= (others => '0')       after DELAY_G;
      r.txEnable               <= (others => '0')       after DELAY_G;
      r.ethRegCntlIn.regAck    <= '0'                   after DELAY_G;
      r.ethRegCntlIn.regFail   <= '0'                   after DELAY_G;
      r.ethRegCntlIn.regDataIn <= (others => '0')       after DELAY_G;
      r.kpixSerTxOut           <= (others => '0')       after DELAY_G;
    elsif (rising_edge(kpixClk)) then
      r <= rin after DELAY_G;
    end if;
  end process seq;

  comb : process (r, ethRegCntlOut, triggerOut, kpixRegRxOut) is
    variable tmpVar           : RegType;
    variable addressedKpixVar : natural;
  begin
    tmpVar := r;

    tmpVar.kpixSerTxOut         := (others => '0');
    tmpVar.ethRegCntlIn.regAck  := '0';
    tmpVar.ethRegCntlIn.regFail := '0';

    -- Synchronize sysClk inputs to kpixClk
    synchronize(ethRegCntlOut.regInp, r.regInpSync, tmpVar.regInpSync);
    synchronize(ethRegCntlOut.regReq, r.regReqSync, tmpVar.regReqSync);
    synchronize(ethRegCntlOut.regOp, r.regOpSync, tmpVar.regOpSync);
    synchronize(triggerOut.startAcquire, r.startAcquireSync, tmpVar.startAcquireSync);
    synchronize(triggerOut.startCalibrate, r.startCalibrateSync, tmpVar.startCalibrateSync);

    case (r.state) is
      when IDLE_S =>
        tmpVar.txShiftCount := (others => '0');
        -- Does register access take precidence over commands?
        -- Maybe pipeline parity calc to simplify logic.
        if (r.regReqSync.sync = '1' and isZero(ethRegCntlOut.regAddr(INVALID_KPIX_ADDR_RANGE_C))) then
          -- Register access, format output word
          tmpVar.txShiftReg                               := (others => '0');  -- Simplifies parity calc
          tmpVar.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
          tmpVar.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
          tmpVar.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_REG_ACCESS_C;
          tmpVar.txShiftReg(KPIX_WRITE_INDEX_C)           := r.regOpSync.sync;
          tmpVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := bitReverse(ethRegCntlOut.regAddr(REG_ADDR_RANGE_C));
          tmpVar.txShiftReg(KPIX_DATA_RANGE_C)            := bitReverse(ethRegCntlOut.regDataOut);
          tmpVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C)   := '0';
          tmpVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)     := '0';
          tmpVar.txShiftCount                             := (others => '0');
          addressedKpixVar                                := to_integer(unsigned(ethRegCntlOut.regAddr(VALID_KPIX_ADDR_RANGE_C)));
          tmpVar.txEnable(addressedKpixVar)               := '1';
          tmpVar.state                                    := PARITY_S;

        elsif (r.startAcquireSync.sync = '1') then
          -- Cmd access
          tmpVar.txShiftReg                               := (others => '0');
          tmpVar.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
          tmpVar.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
          tmpVar.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_CMD_RSP_ACCESS_C;
          tmpVar.txShiftReg(KPIX_WRITE_INDEX_C)           := KPIX_WRITE_C;
          tmpVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_ACQUIRE_CMD_ID_REV_C;
          tmpVar.txShiftReg(KPIX_DATA_RANGE_C)            := (others => '0');
          tmpVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C)   := '0';
          tmpVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)     := '0';
          tmpVar.txShiftCount                             := (others => '0');
          tmpVar.txEnable                                 := (others => '1');  -- Enable all
          tmpVar.state                                    := PARITY_S;
          if (r.startCalibrateSync.sync = '1') then
            tmpVar.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_CALIBRATE_CMD_ID_REV_C;
          end if;
        end if;
        
      when PARITY_S =>
        tmpVar.txShiftReg(KPIX_HEADER_PARITY_INDEX_C) := not evenParity(r.txShiftReg(KPIX_FULL_HEADER_RANGE_C));
        tmpVar.txShiftReg(KPIX_DATA_PARITY_INDEX_C)   := not evenParity(r.txShiftReg(KPIX_FULL_DATA_RANGE_C));
        tmpVar.txShiftCount                           := (others => '0');
        tmpVar.kpixSerTxOut                           := r.txEnable;  -- Start bit
        tmpVar.state                                  := TRANSMIT_S;

      when TRANSMIT_S =>
        -- Shift (select) out each bit, gated by rxEnable
        tmpVar.txShiftCount := r.txShiftCount + 1;
        for i in r.txEnable'range loop
          tmpVar.kpixSerTxOut(i) := r.txShiftReg(to_integer(r.txShiftCount)) and r.txEnable(i);
        end loop;
        if (r.txShiftCount = KPIX_NUM_TX_BITS_C) then  -- Check this
          tmpVar.txShiftCount := (others => '0');
          if (r.txShiftReg(KPIX_WRITE_INDEX_C) = '1') then
            if (r.regReqSync.sync = '1') then
              tmpVar.state := WRITE_WAIT_S;
            else
              -- Don't need to wait for req to fall on CMD requests
              tmpVar.state := IDLE_S;
            end if;
          else
            tmpVar.state := READ_WAIT_S;
          end if;
        end if;

      when WRITE_WAIT_S =>
        -- Wait a defined number of cycles before acking write
        -- Keeps KPIX from being overwhelmed
        tmpVar.txShiftCount := r.txShiftCount + 1;
        if (r.txShiftCount = WRITE_WAIT_CYCLES_C) then
          tmpVar.ethRegCntlIn.regAck := '1';  -- THIS NEEDS TO BE SYNC'd to sysclk
                                              -- ALSO, DON'T ACK a command
          tmpVar.state               := WAIT_RELEASE_S;
        end if;

      when READ_WAIT_S =>
        -- Wait for read response
        -- Timeout and fail after defined number of cycles
        tmpVar.txShiftCount := r.txShiftCount + 1;
        addressedKpixVar    := to_integer(unsigned(ethRegCntlOut.regAddr(VALID_KPIX_ADDR_RANGE_C)));  --VALID_KPIX_ADDR_RANGE_C
        if (kpixRegRxOut(addressedKpixVar).regValid = '1' and
            kpixRegRxOut(addressedKpixVar).regAddr = ethRegCntlOut.regAddr(REG_ADDR_RANGE_C)) then  -- REG_ADDR_RANGE_C
          -- Only ack when kpix id and reg addr is the same as tx'd
          tmpVar.ethRegCntlIn.regDataIn := kpixRegRxOut(addressedKpixVar).regData;
          tmpVar.ethRegCntlIn.regAck    := '1';
          tmpVar.ethRegCntlIn.regFail   := kpixRegRxOut(addressedKpixVar).regParityErr;
          tmpVar.state                  := WAIT_RELEASE_S;
        elsif (r.txShiftCount = READ_WAIT_CYCLES_C) then
          tmpVar.ethRegCntlIn.regAck  := '1';  
          tmpVar.ethRegCntlIn.regFail := '1';  
          tmpVar.state                := WAIT_RELEASE_S;
        end if;

      when WAIT_RELEASE_S =>
        if (r.regReqSync.sync = '0') then
          -- Can't deassert ack until regReq is dropped
          tmpVar.ethRegCntlIn.regAck  := '0';
          tmpVar.ethRegCntlIn.regFail := '0';
          tmpVar.state                := IDLE_S;
        end if;

    end case;

    -- Registers
    rin <= tmpVar;

    -- Outputs
    kpixSerTxOut <= r.kpixSerTxOut;

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

end architecture rtl;
