-------------------------------------------------------------------------------
-- Title      : KPIX Transmit Module
-------------------------------------------------------------------------------
-- File       : KpixTx.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2013-07-15
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

      -- Interface with internal registers
      kpixConfigRegs   : in KpixConfigRegsType;
      kpixDataRxRegsIn : in KpixDataRxRegsInArray(NUM_KPIX_MODULES_G-1 downto 0);

      ----------------------------------
      kpixClk    : in sl;
      kpixClkRst : in sl;

      -- Interface with local KPIX
      kpixState : in KpixStateOutType;

      -- Interface with start/trigger module
      triggerOut : in TriggerOutType;   -- clk200

      -- Interface with kpix register rx modules
      kpixRegRxOut : in KpixRegRxOutArray(NUM_KPIX_MODULES_G downto 0);

      -- Serial outout to KPIX modules
      kpixSerTxOut : out slv(NUM_KPIX_MODULES_G downto 0);
      kpixResetOut : out sl
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
      -- Internal registers
      state        : StateType;         -- State machine state
      txShiftReg   : slv(0 to KPIX_NUM_TX_BITS_C-1);    -- Range direction matches documentation
      txShiftCount : unsigned(log2(KPIX_NUM_TX_BITS_C)+1 downto 0);  -- Counter for shifting
      txEnable     : slv(NUM_KPIX_MODULES_G downto 0);  -- Enables for each serial outpus
      isAcquire    : sl;

      -- kpixRegCntlIn inputs clocked onto kpixClk domain
      regAddr    : slv(23 downto 0);
      regDataOut : slv(31 downto 0);
      regOp      : sl;

      outputEdge : sl;

      -- Output Registers
      kpixRegCntlOut : FrontEndRegCntlInType;  -- outputs to FrontEndRegCntl (must still be sync'd)
      kpixSerTxOut   : slv(NUM_KPIX_MODULES_G downto 0);  -- serial data to each kpix
   end record RegType;

   signal r, rin             : RegType;
   signal kpixResetHoldSync  : sl;
   signal regReqSync         : sl;
   signal startAcquireSync   : sl;
   signal startCalibrateSync : sl;
   signal startReadoutSync   : sl;
   signal kpixSerTxOutFall   : slv(NUM_KPIX_MODULES_G downto 0);

   -----------------------------------------------------------------------------
   -- sysClk clocked registers
   -----------------------------------------------------------------------------
   type SysRegType is record
      kpixResetHold : sl;
   end record SysRegType;

   signal sysR, sysRin        : SysRegType;
   signal kpixResetHoldReSync : sl;
   signal regAckSync          : sl;
   signal regFailSync         : sl;
   

begin

   -----------------------------------------------------------------------------
   -- kpixReset pulse must be caught and held so it can be sync'd to kpixClock
   -- KpixRegCntlIn signals must be synchronized back to sysClk
   -----------------------------------------------------------------------------
   sysComb : process (sysR, r, kpixConfigRegs, kpixResetHoldReSync) is
      variable v : SysRegType;
   begin
      v := sysR;

      -- Latch in kpixReset pulse from front end register
      if (kpixConfigRegs.kpixReset = '1') then
         v.kpixResetHold := '1';
      end if;

      if (kpixResetHoldReSync = '1' and kpixConfigRegs.kpixReset = '0') then
         v.kpixResetHold := '0';
      end if;

      sysRin <= v;
   end process sysComb;

   sysSync : process (sysClk, sysRst) is
   begin
      if (sysRst = '1') then
         sysR.kpixResetHold <= '0' after DELAY_G;
      elsif (rising_edge(sysClk)) then
         sysR <= sysRin after DELAY_G;
      end if;
   end process sysSync;

   Synchronizer_KpixResetHold : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1',
         INIT_G         => "11")
      port map (
         clk     => kpixClk,
         aRst    => kpixClkRst,
         dataIn  => sysR.kpixResetHold,
         dataOut => kpixResetHoldSync);

   -- kpixResetHold goes to kpixClk logic where it is synced to kpixClk as kpixResetHoldSync
   -- Resynchronize that back to sysClk and use that to reset kpixResetHold
   Synchronizer_KpixResetHoldReSync : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk     => sysClk,
         aRst    => sysRst,
         dataIn  => kpixResetHoldSync,
         dataOut => kpixResetHoldReSync);

   kpixResetOut <= kpixResetHoldSync;

   -------------------------------------------------------------------------------------------------
   -- Kpix Clocked Logic
   -------------------------------------------------------------------------------------------------

   -- Synchronize regReq to kpixClk
   Synchronizer_RegReq : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1',
         STAGES_G       => 4,
         INIT_G         => "0000")
      port map (
         clk     => kpixClk,
         aRst    => kpixClkRst,
         dataIn  => kpixRegCntlIn.regReq,
         dataOut => regReqSync);

   Synchronizer_StartAcquire : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1',
         STAGES_G       => 4,
         INIT_G         => "0000")
      port map (
         clk     => kpixClk,
         aRst    => kpixClkRst,
         dataIn  => triggerOut.startAcquire,
         dataOut => startAcquireSync);

   Synchronizer_StartCalibrate : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1',
         STAGES_G       => 2,
         INIT_G         => "00")
      port map (
         clk     => kpixClk,
         aRst    => kpixClkRst,
         dataIn  => triggerOut.startCalibrate,
         dataOut => startCalibrateSync);

   Synchronizer_StartReadout : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1',
         STAGES_G       => 2,
         INIT_G         => "00")
      port map (
         clk     => kpixClk,
         aRst    => kpixClkRst,
         dataIn  => triggerOut.startReadout,
         dataOut => startReadoutSync);

   seq : process (kpixClk, kpixClkRst) is
   begin
      if (kpixClkRst = '1') then
         r.state                    <= IDLE_S          after DELAY_G;
         r.txShiftReg               <= (others => '0') after DELAY_G;
         r.txShiftCount             <= (others => '0') after DELAY_G;
         r.txEnable                 <= (others => '0') after DELAY_G;
         r.isAcquire                <= '0'             after DELAY_G;
         r.regAddr                  <= (others => '0') after DELAY_G;
         r.regDataOut               <= (others => '0') after DELAY_G;
         r.regOp                    <= '0'             after DELAY_G;
         r.outputEdge               <= '0'             after DELAY_G;
         r.kpixRegCntlOut.regAck    <= '0'             after DELAY_G;
         r.kpixRegCntlOut.regFail   <= '0'             after DELAY_G;
         r.kpixRegCntlOut.regDataIn <= (others => '0') after DELAY_G;
         r.kpixSerTxOut             <= (others => '0') after DELAY_G;
      elsif (rising_edge(kpixClk)) then
         r <= rin after DELAY_G;
      end if;
   end process seq;



   comb : process (r, regReqSync, startAcquireSync, startCalibrateSync, startReadoutSync, kpixResetHoldSync,
                   kpixRegRxOut, kpixRegCntlIn, kpixDataRxRegsIn, kpixState, kpixConfigRegs) is
      variable v                : RegType;
      variable addressedKpixVar : natural;
   begin
      v := r;

      -- Don't need to sync through 2 flops, always wait for regReq to go through 4 flops and then
      -- these should be stable
      v.regAddr    := kpixRegCntlIn.regAddr;
      v.regDataOut := kpixRegCntlIn.regDataOut;
      v.regOp      := kpixRegCntlIn.regOp;

      -- Set at start of run so don't need to fully sync
      v.outputEdge := kpixConfigRegs.outputEdge;

      v.kpixSerTxOut := (others => '0');

      case (r.state) is
         when IDLE_S =>
            v.txShiftCount := (others => '0');
            v.txEnable     := (others => '0');

            if (regReqSync = '1' and uOr(r.regAddr(INVALID_KPIX_ADDR_RANGE_C)) = '0') then
               -- Register access, format output word
               v.txShiftReg                               := (others => '0');  -- Simplifies parity calc
               v.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
               v.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
               v.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_REG_ACCESS_C;
               v.txShiftReg(KPIX_WRITE_INDEX_C)           := r.regOp;          --r.regOpSync.sync;
               v.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := bitReverse(r.regAddr(REG_ADDR_RANGE_C));
               v.txShiftReg(KPIX_DATA_RANGE_C)            := bitReverse(r.regDataOut);
               if (r.regOp = '0') then  -- Override data field with 0s of doing a read
                  v.txShiftReg(KPIX_DATA_RANGE_C) := (others => '0');
               end if;
               v.txShiftReg(KPIX_HEADER_PARITY_INDEX_C) := '0';
               v.txShiftReg(KPIX_DATA_PARITY_INDEX_C)   := '0';
               v.txShiftCount                           := (others => '0');
               addressedKpixVar                         := to_integer(unsigned(r.regAddr(VALID_KPIX_ADDR_RANGE_C)));
               v.txEnable                               := (others => '0');
               v.txEnable(addressedKpixVar)             := '1';
               v.isAcquire                              := '0';
               v.state                                  := PARITY_S;

            elsif (startReadoutSync = '1') then
               -- Start a readout (only used with autoReadDisable)
               v.txShiftReg                               := (others => '0');
               v.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
               v.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
               v.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_CMD_RSP_ACCESS_C;
               v.txShiftReg(KPIX_WRITE_INDEX_C)           := KPIX_WRITE_C;
               v.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_READOUT_CMD_ID_REV_C;
               v.txShiftReg(KPIX_DATA_RANGE_C)            := (others => '0');
               v.txShiftReg(KPIX_HEADER_PARITY_INDEX_C)   := '0';
               v.txShiftReg(KPIX_DATA_PARITY_INDEX_C)     := '0';
               v.txShiftCount                             := (others => '0');
               v.state                                    := PARITY_S;
               v.isAcquire                                := '1';
               v.txEnable(NUM_KPIX_MODULES_G)             := '1';  -- Always enable internal kpix
               for i in NUM_KPIX_MODULES_G-1 downto 0 loop
                  -- Send acquire only to enabled kpix asics.
                  v.txEnable(i) := kpixDataRxRegsIn(i).enabled;
               end loop;



            elsif (startAcquireSync = '1') then
               -- Start an acquisition
               v.txShiftReg                               := (others => '0');
               v.txShiftReg(KPIX_MARKER_RANGE_C)          := KPIX_MARKER_C;
               v.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)      := KPIX_CMD_RSP_FRAME_C;
               v.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C)     := KPIX_CMD_RSP_ACCESS_C;
               v.txShiftReg(KPIX_WRITE_INDEX_C)           := KPIX_WRITE_C;
               v.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_ACQUIRE_CMD_ID_REV_C;
               v.txShiftReg(KPIX_DATA_RANGE_C)            := (others => '0');
               v.txShiftReg(KPIX_HEADER_PARITY_INDEX_C)   := '0';
               v.txShiftReg(KPIX_DATA_PARITY_INDEX_C)     := '0';
               v.txShiftCount                             := (others => '0');
               v.state                                    := PARITY_S;
               v.isAcquire                                := '1';
               v.txEnable(NUM_KPIX_MODULES_G)             := '1';  -- Always enable internal kpix
               for i in NUM_KPIX_MODULES_G-1 downto 0 loop
                  -- Send acquire only to enabled kpix asics.
                  v.txEnable(i) := kpixDataRxRegsIn(i).enabled;
               end loop;
               if (startCalibrateSync = '1') then
                  v.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_CALIBRATE_CMD_ID_REV_C;
               end if;
            end if;
            -- end if;
            
         when PARITY_S =>
            v.txShiftReg(KPIX_HEADER_PARITY_INDEX_C) := not evenParity(r.txShiftReg(KPIX_FULL_HEADER_RANGE_C));
            v.txShiftReg(KPIX_DATA_PARITY_INDEX_C)   := not evenParity(r.txShiftReg(KPIX_FULL_DATA_RANGE_C));
            v.txShiftCount                           := (others => '0');
            v.kpixSerTxOut                           := r.txEnable;  -- Start bit
            v.state                                  := TRANSMIT_S;

         when TRANSMIT_S =>
            -- Shift (select) out each bit, gated by txEnable
            v.txShiftCount := r.txShiftCount + 1;
            v.txShiftReg   := r.txShiftReg(1 to KPIX_NUM_TX_BITS_C-1) & '0';
            for i in r.txEnable'range loop
               v.kpixSerTxOut(i) := r.txShiftReg(0) and r.txEnable(i);
            end loop;
            if (r.txShiftCount = KPIX_NUM_TX_BITS_C) then  -- Check this
               v.txShiftCount := (others => '0');
               if (r.isAcquire = '1') then
                  -- All txEnable bits set indicates an acquire cmd being transmitted
                  -- Don't need to wait for req to fall on CMD requests
                  v.state := DATA_WAIT_S;
               else
                  -- Register request
                  if (r.regOp = '1') then
                     v.state := WRITE_WAIT_S;
                  else
                     v.state := READ_WAIT_S;
                  end if;
               end if;
            end if;

         when DATA_WAIT_S =>
            -- Wait for kpix core state to be idle
            -- Having gone through acquire, digitize and (maybe) readout.
            if (kpixState.analogState = KPIX_ANALOG_IDLE_STATE_C and
                kpixState.readoutState = KPIX_READOUT_IDLE_STATE_C) then
               v.state := IDLE_S;
            end if;

         when WRITE_WAIT_S =>
            -- Wait a defined number of cycles before acking write
            -- Keeps KPIX from being overwhelmed
            v.txShiftCount := r.txShiftCount + 1;
            if (r.txShiftCount = WRITE_WAIT_CYCLES_C) then
               v.kpixRegCntlOut.regAck := '1';
               v.state                 := WAIT_RELEASE_S;
            end if;

         when READ_WAIT_S =>
            -- Wait for read response
            -- Timeout and fail after defined number of cycles
            v.txShiftCount   := r.txShiftCount + 1;
            addressedKpixVar := to_integer(unsigned(r.regAddr(VALID_KPIX_ADDR_RANGE_C)));  --VALID_KPIX_ADDR_RANGE_C
            if (kpixRegRxOut(addressedKpixVar).regValid = '1' and
                kpixRegRxOut(addressedKpixVar).regAddr = r.regAddr(REG_ADDR_RANGE_C)) then  -- REG_ADDR_RANGE_C
               -- Only ack when kpix id and reg addr is the same as tx'd
               v.kpixRegCntlOut.regDataIn := kpixRegRxOut(addressedKpixVar).regData;
               v.kpixRegCntlOut.regAck    := '1';
               v.kpixRegCntlOut.regFail   := kpixRegRxOut(addressedKpixVar).regParityErr;
               v.state                    := WAIT_RELEASE_S;
            elsif (r.txShiftCount = READ_WAIT_CYCLES_C) then
               v.kpixRegCntlOut.regAck  := '1';
               v.kpixRegCntlOut.regFail := '1';
               v.state                  := WAIT_RELEASE_S;
            end if;

         when WAIT_RELEASE_S =>
            if (regReqSync = '0') then
               -- Can't deassert ack until regReq is dropped
               v.kpixRegCntlOut.regAck  := '0';
               v.kpixRegCntlOut.regFail := '0';
               v.txEnable               := (others => '0');
               v.state                  := IDLE_S;
            end if;

      end case;

      -- Registers
      rin <= v;

   end process comb;


   -------------------------------------------------------------------------------------------------
   -- Sync front end control signals back to sysclk
   -------------------------------------------------------------------------------------------------
   Synchronizer_RegAckSync : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1',
         STAGES_G       => 4,
         INIT_G         => "0000")
      port map (
         clk     => sysClk,
         aRst    => sysRst,
         dataIn  => r.kpixRegCntlOut.regAck,
         dataOut => regAckSync);

   Synchronizer_RegFailSync : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk     => sysClk,
         aRst    => sysRst,
         dataIn  => r.kpixRegCntlOut.regFail,
         dataOut => regFailSync);

   kpixRegCntlOut.regAck    <= regAckSync;
   kpixRegCntlOut.regFail   <= regFailSync;
   kpixRegCntlOut.regDataIn <= r.kpixRegCntlOut.regDataIn;



   -------------------------------------------------------------------------------------------------
   -- Optional clocking of serial clock on falling edge
   -------------------------------------------------------------------------------------------------
   fallingClk : process (kpixClk, kpixClkRst) is
   begin
      if (kpixClkRst = '1') then
         kpixSerTxOutFall <= (others => '0') after DELAY_G;
      elsif (falling_edge(kpixClk)) then
         kpixSerTxOutFall <= r.kpixSerTxOut after DELAY_G;
      end if;
   end process fallingClk;

   kpixSerTxOut <= r.kpixSerTxOut when r.outputEdge = '0' else kpixSerTxOutFall;

end architecture rtl;
