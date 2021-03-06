-------------------------------------------------------------------------------
-- Title      : KPIX Register Control
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Transmits Register and Command regests to a configurable
-- number of KPIX modules.
-------------------------------------------------------------------------------
-- This file is part of 'KPIX'
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'KPIX', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;


library kpix;
use kpix.KpixPkg.all;
use kpix.KpixLocalPkg.all;
use kpix.KpixRegRxPkg.all;

entity KpixRegCntl is

   generic (
      TPD_G              : time    := 1 ns;  -- Simulation register delay
      NUM_KPIX_MODULES_G : natural := 4);

   port (
      clk200         : in sl;
      rst200         : in sl;
      -- Kpix clock info
      kpixClkPreRise : in sl;
      kpixClkPreFall : in sl;
      kpixClkSample  : in sl;
      kpixClkOutput : in sl;

      -- AXI-Lite interface for registers
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- Interface with internal registers
      sysConfig : in SysConfigType;

      -- Interface with local KPIX
      kpixState : in KpixStateOutType;

      -- Interface with start/trigger module
      acqControl : in AcquisitionControlType;

      -- Serial outout to KPIX modules
      kpixSerTxOut : out slv(NUM_KPIX_MODULES_G downto 0);
      kpixSerRxIn  : in  slv(NUM_KPIX_MODULES_G downto 0);  -- This should be synchronized to clk200 externally
      kpixResetOut : out sl;

      temperature : out Slv8Array(NUM_KPIX_MODULES_G downto 0);
      tempCount   : out Slv12Array(NUM_KPIX_MODULES_G downto 0));

end entity KpixRegCntl;

architecture rtl of KpixRegCntl is

   subtype REG_ADDR_RANGE_C is natural range 8 downto 2;
   subtype KPIX_ADDR_RANGE_C is natural range 17 downto 12;
--   subtype VALID_KPIX_ADDR_RANGE_C is natural range 8+log2(NUM_KPIX_MODULES_G) downto 8;
--   subtype INVALID_KPIX_ADDR_RANGE_C is natural range 15 downto VALID_KPIX_ADDR_RANGE_C'high+1;

   constant DATA_WAIT_CYCLES_C  : natural := 255;
   constant WRITE_WAIT_CYCLES_C : natural := 20;
   constant READ_WAIT_CYCLES_C  : natural := 63;

   -----------------------------------------------------------------------------
   -- kpixClk clocked registers
   -----------------------------------------------------------------------------
   type StateType is (IDLE_S, PARITY_S, TRANSMIT_S, DATA_WAIT_S, WRITE_WAIT_S, READ_WAIT_S);

   type RegType is record
      -- Internal registers
      state          : StateType;       -- State machine state
      txShiftReg     : slv(0 to KPIX_NUM_TX_BITS_C-1);  -- Range direction matches documentation
      txShiftCount   : slv(log2(KPIX_NUM_TX_BITS_C)+1 downto 0);  -- Counter for shifting
      txEnable       : slv(NUM_KPIX_MODULES_G downto 0);          -- Enables for each serial outpus
      isAcquire      : sl;
      kpixResetLatch : sl;

      -- Output Registers
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
      kpixSerTxOut   : slv(NUM_KPIX_MODULES_G downto 0);  -- serial data to each kpix
      kpixResetOut   : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state          => IDLE_S,
      txShiftReg     => (others => '0'),
      txShiftCount   => (others => '0'),
      txEnable       => (others => '0'),
      isAcquire      => '0',
      kpixResetLatch => '0',
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C,
      kpixSerTxOut   => (others => '0'),
      kpixResetOut   => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal kpixRegRxOut : KpixRegRxOutArray(NUM_KPIX_MODULES_G downto 0);

begin


   -------------------------------------------------------------------------------------------------
   -- Main Logic
   -------------------------------------------------------------------------------------------------
   comb : process (acqControl, axilReadMaster, axilWriteMaster, kpixClkOutput, kpixRegRxOut,
                   kpixState, r, rst200, sysConfig) is
      variable v              : RegType;
      variable axiKpixAddrInt : natural;
      variable araddrInt      : natural;
      variable axiStatus      : AxiLiteStatusType;
      variable axiReq         : sl;
      variable axiAddr        : slv(31 downto 0);
   begin
      v := r;

      -- Catch and stretch kpix reset
      if (sysConfig.kpixReset = '1') then
         v.kpixResetLatch := '1';
      end if;


      -- Listen for AXIL transactions
      axiSlaveWaitTxn(axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave, axiStatus);
      axiReq := axiStatus.writeEnable or axiStatus.readEnable;
      axiAddr := ite(axiStatus.writeEnable = '1', axilWriteMaster.awaddr,
                     ite(axiStatus.readEnable = '1', axilReadMaster.araddr, X"00000000"));

      axiKpixAddrInt        := conv_integer(axiAddr(KPIX_ADDR_RANGE_C));
      araddrInt             := conv_integer(axilReadMaster.araddr(KPIX_ADDR_RANGE_C)) mod (NUM_KPIX_MODULES_G+1);
      -- Always assign to ease timing
      v.axilReadSlave.rdata := kpixRegRxOut(araddrInt).regData;

      -- Shift new output when output strobe seen
      -- Configured in KpixClkGen
      if (kpixClkOutput = '1') then

         -- Don't drive anything by defualt
         v.kpixSerTxOut := (others => '0');

         -- This holds the reset for 2 kpixClk cycles
         v.kpixResetOut := r.kpixResetLatch;
         if (r.kpixResetLatch = '1' and r.kpixResetOut = '1') then
            v.kpixResetLatch := '0';
         end if;


         case (r.state) is
            when IDLE_S =>
               v.txShiftCount := (others => '0');
               v.txEnable     := (others => '0');

               if (axiReq = '1') then
                  if (axiKpixAddrInt > NUM_KPIX_MODULES_G) then
                     if (axiStatus.writeEnable = '1') then
                        axiSlaveWriteResponse(v.axilWriteSlave, AXI_RESP_DECERR_C);
                     else
                        axiSlaveReadResponse(v.axilReadSlave, AXI_RESP_DECERR_C);
                     end if;

                  else
                     -- Register access, format output word
                     v.txShiftReg                           := (others => '0');  -- Simplifies parity calc
                     v.txShiftReg(KPIX_MARKER_RANGE_C)      := KPIX_MARKER_C;
                     v.txShiftReg(KPIX_FRAME_TYPE_INDEX_C)  := KPIX_CMD_RSP_FRAME_C;
                     v.txShiftReg(KPIX_ACCESS_TYPE_INDEX_C) := KPIX_REG_ACCESS_C;
                     v.txShiftReg(KPIX_WRITE_INDEX_C)       := axiStatus.writeEnable;
                     if (axiStatus.writeEnable = '1') then
                        v.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := bitReverse(axilWriteMaster.awaddr(REG_ADDR_RANGE_C));
                     else
                        v.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := bitReverse(axilReadMaster.araddr(REG_ADDR_RANGE_C));
                     end if;

                     v.txShiftReg(KPIX_DATA_RANGE_C) := bitReverse(axilWriteMaster.wdata);
                     if (axiStatus.readEnable = '1') then  -- Override data field with 0s if doing a read
                        v.txShiftReg(KPIX_DATA_RANGE_C) := (others => '0');
                     end if;
                     v.txShiftReg(KPIX_HEADER_PARITY_INDEX_C) := '0';
                     v.txShiftReg(KPIX_DATA_PARITY_INDEX_C)   := '0';
                     v.txShiftCount                           := (others => '0');

                     v.txEnable                 := (others => '0');
                     v.txEnable(axiKpixAddrInt) := '1';
                     v.isAcquire                := '0';
                     v.state                    := PARITY_S;
                  end if;

               elsif (acqControl.startReadout = '1') then
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
                  v.txEnable(NUM_KPIX_MODULES_G-1 downto 0)  := sysConfig.kpixEnable(NUM_KPIX_MODULES_G-1 downto 0);
                  v.txEnable(NUM_KPIX_MODULES_G)             := '1';  -- Always enable internal kpix

               elsif (acqControl.startAcquire = '1') then
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
                  -- Send acquire only to enabled kpix asics.
                  v.txEnable(NUM_KPIX_MODULES_G-1 downto 0)  := sysConfig.kpixEnable(NUM_KPIX_MODULES_G-1 downto 0);
                  v.txEnable(NUM_KPIX_MODULES_G)             := '1';  -- Always enable internal kpix
                  if (acqControl.startCalibrate = '1') then
                     v.txShiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) := KPIX_CALIBRATE_CMD_ID_REV_C;
                  end if;
               end if;
               -- end if;

            when PARITY_S =>
               -- Do parity calc in it's own state to ease timing
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
                     if (axiStatus.writeEnable = '1') then
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
                  axiSlaveWriteResponse(v.axilWriteSlave, AXI_RESP_OK_C);
                  v.state := IDLE_S;
               end if;

            when READ_WAIT_S =>
               -- Wait for read response
               -- Timeout and fail after defined number of cycles
               v.txShiftCount := r.txShiftCount + 1;

--               axiKpixAddrInt := conv_integer(axilReadMaster.araddr(VALID_KPIX_ADDR_RANGE_C));
               if (kpixRegRxOut(araddrInt).regValid = '1' and
                   kpixRegRxOut(araddrInt).regAddr = axilReadMaster.araddr(REG_ADDR_RANGE_C)) then  -- REG_ADDR_RANGE_C
                  -- Only ack when kpix id and reg addr is the same as tx'd

                  if (kpixRegRxOut(araddrInt).regParityErr = '1') then
                     axiSlaveReadResponse(v.axilReadSlave, AXI_RESP_SLVERR_C);
                  else
                     axiSlaveReadResponse(v.axilReadSlave, AXI_RESP_OK_C);
                  end if;
                  v.state := IDLE_S;

               elsif (r.txShiftCount = READ_WAIT_CYCLES_C) then
                  axiSlaveReadResponse(v.axilReadSlave, AXI_RESP_SLVERR_C);
                  v.state := IDLE_S;
               end if;

         end case;

      end if;

      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      -- Registers
      rin <= v;

      -- Outputs
      kpixResetOut   <= r.kpixResetOut;
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;
      kpixSerTxOut   <= r.kpixSerTxOut;

   end process comb;

   seq : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   RX_GEN : for i in NUM_KPIX_MODULES_G downto 0 generate
      U_KpixRegRx_1 : entity kpix.KpixRegRx
         generic map (
            TPD_G     => TPD_G,
            KPIX_ID_G => i)
         port map (
            clk200         => clk200,            -- [in]
            rst200         => rst200,            -- [in]
            sysConfig      => sysConfig,         -- [in]
            kpixClkPreRise => kpixClkPreRise,    -- [in]
            kpixClkPreFall => kpixClkPreFall,    -- [in]
            kpixClkSample  => kpixClkSample,     -- [in]
            kpixSerRxIn    => kpixSerRxIn(i),    -- [in]
            kpixRegRxOut   => kpixRegRxOut(i));  -- [out]
   end generate RX_GEN;

   TEMPERATURE_GEN : for i in NUM_KPIX_MODULES_G-1 downto 0 generate
      temperature(i) <= kpixRegRxOut(i).temperature;
      tempCount(i)   <= kpixRegRxOut(i).tempCount;
   end generate;
   temperature(NUM_KPIX_MODULES_G) <= (others => '0');
   tempCount(NUM_KPIX_MODULES_G)   <= (others => '0');


end architecture rtl;
