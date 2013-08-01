-------------------------------------------------------------------------------
-- Title      : KPIX Data Receive Module
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2013-07-31
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Receives sample data from a KPIX device and formats it for
-- output to the EventBuilder.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;
use work.KpixPkg.all;
use work.KpixDataRxPkg.all;
use work.KpixRegRxPkg.all;

entity KpixDataRx is
   
   generic (
      DELAY_G           : time    := 1 ns;  -- Simulation register delay
      KPIX_ID_G         : natural := 0;     -- 
      NUM_ROW_BUFFERS_G : natural := 4);    -- Number of row buffers (power of 2)

   port (
      kpixClk            : in sl;                -- Clock for RX (KPIX interface)
      kpixClkRst         : in sl;
      kpixSerRxIn        : in sl;                -- Serial Data from KPIX
      kpixRegRxOut       : in KpixRegRxOutType;  -- For Temperature
      kpixConfigRegsKpix : in KpixConfigRegsType;

      sysClk         : in  sl;                 -- Clock for Tx (EventBuilder interface)
      sysRst         : in  sl;
      kpixConfigRegs : in  KpixConfigRegsType;
      extRegsIn      : in  KpixDataRxRegsInType;
      extRegsOut     : out kpixDataRxRegsOutType;
      kpixDataRxOut  : out KpixDataRxOutType;  -- To EventBuilder
      kpixDataRxIn   : in  KpixDataRxInType    -- From EventBuilder

      );

end entity KpixDataRx;

architecture rtl of KpixDataRx is

   -----------------------------------------------------------------------------
   -- Constants
   -----------------------------------------------------------------------------
   constant RAM_WIDTH_C        : natural              := 14;
   constant COLUMN_SIZE_C      : natural              := 16;  -- 9 words/column + rowId
   constant NUM_COLUMNS_C      : natural              := 32;
   constant RAM_DEPTH_C        : natural              := COLUMN_SIZE_C * NUM_COLUMNS_C * NUM_ROW_BUFFERS_G;
   constant SHIFT_REG_LENGTH_C : natural              := 15;
   constant DATA_SAMPLE_C      : slv(3 downto 0)      := "0000";
   constant TEMP_SAMPLE_C      : slv(3 downto 0)      := "0001";
   constant ROW_ID_ADDR_C      : unsigned(3 downto 0) := "1111";

   -----------------------------------------------------------------------------
   -- RAM
   -----------------------------------------------------------------------------
   -- Infer a RAM for storage of incomming data
   type RamType is array (0 to RAM_DEPTH_C-1) of slv(RAM_WIDTH_C-1 downto 0);
   signal ram         : RamType;
   signal txRamRdData : slv(RAM_WIDTH_C-1 downto 0);

   ---------------------------------------------------------------------------
   -- Rx controlled Registers
   ---------------------------------------------------------------------------
   type RxStateType is (
      RX_IDLE_S,
      RX_HEADER_S,
      RX_ROW_ID_S,
      RX_DATA_S,
      RX_FRAME_DONE_S,
      RX_DUMP_S,
      RX_RESP_S);

   type RxRegType is record
      rxShiftData       : slv(0 to SHIFT_REG_LENGTH_C-1);  -- Upward indexed to match documentation
      rxShiftCount      : unsigned(5 downto 0);            -- Counts bits shifted in
      rxColumnCount     : unsigned(4 downto 0);            -- 32 columns
      rxRowId           : unsigned(4 downto 0);
      rxWordId          : unsigned(3 downto 0);
      rxState           : RxStateType;
      rxRamWrAddr       : unsigned(log2(RAM_DEPTH_C)-1 downto 0);
      rxRamWrData       : slv(RAM_WIDTH_C-1 downto 0);
      rxRamWrEn         : sl;
      rxRowBuffer       : unsigned(log2(NUM_ROW_BUFFERS_G)-1 downto 0);
      rxRowReq          : slv(NUM_ROW_BUFFERS_G-1 downto 0);
      rxBusy            : sl;
      markerError       : sl;
      headerParityError : sl;
      overflowError     : sl;
   end record;

   constant RX_REG_INIT_C : RxRegType := (
      rxShiftData       => (others => '0'),
      rxShiftCount      => (others => '0'),
      rxColumnCount     => (others => '0'),
      rxRowId           => (others => '0'),
      rxWordId          => (others => '0'),
      rxState           => RX_IDLE_S,
      rxRamWrAddr       => (others => '0'),
      rxRamWrData       => (others => '0'),
      rxRamWrEn         => '0',
      rxRowBuffer       => (others => '0'),
      rxRowReq          => (others => '0'),
      rxBusy            => '0',
      markerError       => '0',
      headerParityError => '0',
      overflowError     => '0');

   signal rxRowAckSync     : slv(NUM_ROW_BUFFERS_G-1 downto 0);
   signal enabledSync      : sl;
   signal rxRegs, rxRegsIn : RxRegType := RX_REG_INIT_C;

   ---------------------------------------------------------------------------
   -- Tx controlled Registers
   ---------------------------------------------------------------------------
   type TxStateType is (
      TX_CLEAR_S,
      TX_IDLE_S,
      TX_ROW_ID_S,
      TX_NXT_COL_S,
      TX_CNT_S,
      TX_TIMESTAMP_S,
      TX_ADC_DATA_S,
      TX_SEND_SAMPLE_S,
      TX_WAIT_S,
      TX_TEMP_S);

   type SampleType is record
      emptyBit     : sl;
      badCountFlag : sl;
      rangeBit     : sl;
      triggerBit   : sl;
      bucket       : slv(1 downto 0);
      row          : slv(4 downto 0);
      column       : slv(4 downto 0);
      timestamp    : slv(12 downto 0);
      adc          : slv(12 downto 0);
   end record SampleType;

   constant SAMPLE_INIT_C : SampleType := (
      emptyBit     => '0',
      badCountFlag => '0',
      rangeBit     => '0',
      triggerBit   => '0',
      bucket       => (others => '0'),
      row          => (others => '0'),
      column       => (others => '0'),
      timestamp    => (others => '0'),
      adc          => (others => '0'));

   type TxRegType is record
      txRowBuffer     : unsigned(log2(NUM_ROW_BUFFERS_G)-1 downto 0);
      txSample        : SampleType;
      txState         : TxStateType;
      txColumnCount   : unsigned(4 downto 0);
      txBucketCount   : unsigned(2 downto 0);
      txColumnOffset  : unsigned(3 downto 0);
      txTriggers      : slv(3 downto 0);
      txValidBuckets  : unsigned(3 downto 0);
      txRanges        : slv(3 downto 0);
      txRowAck        : slv(NUM_ROW_BUFFERS_G-1 downto 0);
      dataParityError : sl;
      extRegsOut      : kpixDataRxRegsOutType;  -- Output
      kpixDataRxOut   : KpixDataRxOutType;      -- Output
   end record;

   constant TX_REG_INIT_C : TxRegType := (
      txRowBuffer     => (others => '0'),
      txSample        => SAMPLE_INIT_C,
      txState         => TX_CLEAR_S,
      txColumnCount   => (others => '0'),
      txBucketCount   => (others => '0'),
      txColumnOffset  => (others => '0'),
      txTriggers      => (others => '0'),
      txValidBuckets  => (others => '0'),
      txRanges        => (others => '0'),
      txRowAck        => (others => '0'),
      dataParityError => '0',
      kpixDataRxOut   => KPIX_DATA_RX_OUT_INIT_C,
      extRegsOut      => KPIX_DATA_RX_REGS_OUT_INIT_C);

   signal txRowReqSync          : slv(NUM_ROW_BUFFERS_G-1 downto 0);
   signal txRxBusyRise          : sl;   -- Sync rx busy to tx clock
   signal markerErrorRise       : sl;
   signal headerParityErrorRise : sl;
   signal overflowErrorRise     : sl;
   signal kpixRegRxOutSys       : KpixRegRxOutType;

   signal txRegs, txRegsIn : TxRegType := TX_REG_INIT_C;
   signal kpixSerRxInFall  : sl;

   -----------------------------------------------------------------------------
   -- Functions
   -----------------------------------------------------------------------------
   -- Format a data sample into a 64 bit slv for transmission
   function formatSample (sample : SampleType) return slv is
      variable retVar : slv(63 downto 0);
   begin
      retVar(63 downto 60) := DATA_SAMPLE_C;  -- Type Field
      retVar(59 downto 48) := slv(to_unsigned(KPIX_ID_G, 12));
      retVar(47)           := sample.emptyBit;
      retVar(46)           := sample.badCountFlag;
      retVar(45)           := sample.rangeBit;
      retVar(44)           := sample.triggerBit;
      retVar(43 downto 42) := sample.bucket;
      retVar(41 downto 37) := sample.column;
      retVar(36 downto 32) := sample.row;
      retVar(31 downto 29) := "000";
      retVar(28 downto 16) := sample.timestamp;
      retVar(15 downto 13) := "000";
      retVar(12 downto 0)  := sample.adc;
      return retVar;
   end function formatSample;

   -- Format a temperature sample into a 64 bit slv for transmission.
   function formatTemperature (temp : KpixRegRxOutType) return slv is
      variable retVar : slv(63 downto 0) := (others => '0');
   begin
      retVar(63 downto 60) := TEMP_SAMPLE_C;
      retVar(59 downto 48) := slv(to_unsigned(KPIX_ID_G, 12));
      retVar(31 downto 24) := temp.tempCount(7 downto 0);
      retVar(23 downto 16) := temp.temperature;
      retVar(7 downto 0)   := grayDecode(temp.temperature);
      return retVar;
   end function formatTemperature;

begin

   --------------------------------------------------------------------------------------------------
   -- Falling Edge logic
   -- Optionally clock in serial input on falling edge of clock
   --------------------------------------------------------------------------------------------------
   rxFall : process (kpixClk, kpixClkRst) is
   begin
      if (kpixClkRst = '1') then
         kpixSerRxInFall <= '0' after DELAY_G;
      elsif (falling_edge(kpixClk)) then
         kpixSerRxInFall <= kpixSerRxIn after DELAY_G;
      end if;
   end process rxFall;

   -------------------------------------------------------------------------------------------------
   -- Synchronize signals to kpixClk that need it
   -------------------------------------------------------------------------------------------------
   GEN_RX_ROW_ACK_SYNC : for i in NUM_ROW_BUFFERS_G-1 downto 0 generate
      Synchronizer_txAck : entity work.Synchronizer
         generic map (
            TPD_G          => DELAY_G,
            RST_POLARITY_G => '1')
         port map (
            clk     => kpixClk,
            aRst    => kpixClkRst,
            dataIn  => txRegs.txRowAck(i),
            dataOut => rxRowAckSync(i));
   end generate GEN_RX_ROW_ACK_SYNC;

   Synchronizer_enabled : entity work.Synchronizer
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk     => kpixClk,
         aRst    => kpixClkRst,
         dataIn  => extRegsIn.enabled,
         dataOut => enabledSync);

   -----------------------------------------------------------------------------
   -- Rx Logic
   -- Runs on kpixClk
   -----------------------------------------------------------------------------
   rxSeq : process (kpixClk, kpixClkRst) is
   begin
      if (kpixClkRst = '1') then
         rxRegs <= RX_REG_INIT_C after DELAY_G;
      elsif (rising_edge(kpixClk)) then
         rxRegs <= rxRegsIn after DELAY_G;
         if (rxRegs.rxRamWrEn = '1') then
            ram(to_integer(rxRegs.rxRamWrAddr)) <= rxRegs.rxRamWrData after DELAY_G;
         end if;
      end if;
   end process rxSeq;



   rxComb : process (enabledSync, kpixConfigRegsKpix, kpixSerRxIn, kpixSerRxInFall, rxRegs, rxRowAckSync) is
      variable rVar : RxRegType;
   begin
      rVar := rxRegs;

      -- Shift in new bit and increment counter every clock
      if (kpixConfigRegsKpix.inputEdge = '0') then
         rVar.rxShiftData := rxRegs.rxShiftData(1 to SHIFT_REG_LENGTH_C-1) & kpixSerRxIn;
      else
         rVar.rxShiftData := rxRegs.rxShiftData(1 to SHIFT_REG_LENGTH_C-1) & kpixSerRxInFall;
      end if;

      rVar.rxShiftCount := rxRegs.rxShiftCount + 1;

      -- Don't write to RAM unless overriden in rx state machine
      rVar.rxRamWrEn := '0';

      -- Error signals asserted for 1 cycle only
      rVar.markerError       := '0';
      rVar.headerParityError := '0';
      rVar.overflowError     := '0';

      -- Reset rxRowReq signal upon txRowAck
      for i in rxRegs.rxRowReq'range loop
         if (rxRowAckSync(i) = '1') then
            rVar.rxRowReq(i) := '0';
         end if;
      end loop;

      -- RX State Machine
      case (rxRegs.rxState) is
         when RX_IDLE_S =>
            -- Wait for start bit
            if (rxRegs.rxShiftData(SHIFT_REG_LENGTH_C-1) = '1' and enabledSync = '1') then
               rVar.rxShiftCount := (others => '0');
               rVar.rxState      := RX_HEADER_S;
            end if;
            
         when RX_HEADER_S =>
            -- Wait for full header to arrive
            if (rxRegs.rxShiftCount = 14) then
               -- Read header data
               rVar.rxRowId       := unsigned(bitReverse(rxRegs.rxShiftData(5 to 9)));
               rVar.rxWordId      := unsigned(bitReverse(rxRegs.rxShiftData(10 to 13)));
               rVar.rxShiftCount  := (others => '0');
               rVar.rxColumnCount := (others => '0');
               rVar.rxState       := RX_ROW_ID_S;

               if (rxRegs.rxShiftData(KPIX_MARKER_RANGE_C) /= KPIX_MARKER_C) then
                  -- Invalid Marker
                  rVar.markerError := '1';
                  rVar.rxState     := RX_DUMP_S;

               elsif (rxRegs.rxShiftData(KPIX_FRAME_TYPE_INDEX_C) = KPIX_CMD_RSP_FRAME_C) then
                  -- Response frame, not data
                  rVar.rxState := RX_RESP_S;

               elsif (evenParity(rxRegs.rxShiftData(KPIX_FULL_HEADER_RANGE_C)) = '0') then
                  -- Header Parity error
                  rVar.headerParityError := '1';
                  rVar.rxState           := RX_DUMP_S;

               elsif (rxRegs.rxRowReq(to_integer(rxRegs.rxRowBuffer)) = '1' or
                      rxRowAckSync(to_integer(rxRegs.rxRowBuffer)) = '1') then  
                  -- All row buffers are full
                  rVar.overflowError := '1';
                  rVar.rxState       := RX_DUMP_S;

               end if;
            end if;


         when RX_ROW_ID_S =>
            -- Write Row ID for column into RAM
            rVar.rxRamWrAddr                       := rxRegs.rxRowBuffer & rxRegs.rxColumnCount & ROW_ID_ADDR_C;
            rVar.rxRamWrData                       := (others => '0');  -- Not necessary but makes things cleaner when debugging
            rVar.rxRamWrData(rxRegs.rxRowId'range) := slv(rxRegs.rxRowId);
            rVar.rxRamWrEn                         := '1';
            rVar.rxState                           := RX_DATA_S;

         when RX_DATA_S =>
            -- Wait for next data to arrive
            if (rxRegs.rxShiftCount = 13) then
               -- Write data to RAM (including parity bit)
               rVar.rxRamWrAddr              := rxRegs.rxRowBuffer & rxRegs.rxColumnCount & rxRegs.rxWordId;
               rVar.rxRamWrData(13 downto 0) := bitReverse(rxRegs.rxShiftData(1 to 14));
               rVar.rxRamWrEn                := '1';
               -- Increment Column count and reset shift count
               rVar.rxColumnCount            := rxRegs.rxColumnCount + 1;
               rVar.rxShiftCount             := (others => '0');
               rVar.rxState                  := RX_ROW_ID_S;

               -- numColumns is in sysClk domain but never changes during a run so no need to worry about
               -- syncing it
               if (rxRegs.rxColumnCount = unsigned(kpixConfigRegsKpix.numColumns)) then
                  -- All Columns in row have been received
                  rVar.rxState := RX_FRAME_DONE_S;
               end if;
               
            end if;

         when RX_FRAME_DONE_S =>
            -- Done with a frame
            rVar.rxState := RX_IDLE_S;

            -- If done with all wordIds for a row, increment the row buffer
            if (rxRegs.rxWordId = 8) then  -- replace with constant
               rVar.rxRowReq(to_integer(rxRegs.rxRowBuffer)) := '1';
               rVar.rxRowBuffer                              := rxRegs.rxRowBuffer + 1;
            end if;

         when RX_DUMP_S =>
            -- Wait for a data frame of data to shift through
            if (rxRegs.rxShiftCount = 475) then
               rVar.rxState := RX_IDLE_S;
            end if;

         when RX_RESP_S =>
            if (rxRegs.rxShiftCount = 59) then
               rVar.rxState := RX_IDLE_S;
            end if;

      end case;

      rVar.rxBusy := toSl(rxRegs.rxState /= RX_IDLE_S and rxRegs.rxState /= RX_HEADER_S and
                          rxRegs.rxState /= RX_DUMP_S and rxRegs.rxState /= RX_RESP_S);

      rxRegsIn <= rVar;
   end process;

   -------------------------------------------------------------------------------------------------
   -- Synchronize signals to sysClk
   -------------------------------------------------------------------------------------------------
   TX_ROW_REQ_SYNC : for i in NUM_ROW_BUFFERS_G-1 downto 0 generate
      Synchronizer_2 : entity work.Synchronizer
         generic map (
            TPD_G          => DELAY_G,
            RST_POLARITY_G => '1')
         port map (
            clk     => sysClk,
            aRst    => sysRst,
            dataIn  => rxRegs.rxRowReq(i),
            dataOut => txRowReqSync(i));
   end generate TX_ROW_REQ_SYNC;

   SynchronizerEdge_3 : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => sysClk,
         aRst        => sysRst,
         dataIn      => rxRegs.rxBusy,
         dataOut     => open,
         risingEdge  => txRxBusyRise,
         fallingEdge => open);

   SynchronizerEdge_4 : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => sysClk,
         aRst        => sysRst,
         dataIn      => rxRegs.headerParityError,
         dataOut     => open,
         risingEdge  => headerParityErrorRise,
         fallingEdge => open);

   SynchronizerEdge_5 : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => sysClk,
         aRst        => sysRst,
         dataIn      => rxRegs.markerError,
         dataOut     => open,
         risingEdge  => markerErrorRise,
         fallingEdge => open);

   SynchronizerEdge_6 : entity work.SynchronizerEdge
      generic map (
         TPD_G          => DELAY_G,
         RST_POLARITY_G => '1')
      port map (
         clk         => sysClk,
         aRst        => sysRst,
         dataIn      => rxRegs.overflowError,
         dataOut     => open,
         risingEdge  => overflowErrorRise,
         fallingEdge => open);

   -- Synchronize kpix temp data to sysclk
   SynchronizerFifo_Temperature : entity work.SynchronizerFifo
      generic map (
         TPD_G        => DELAY_G,
         BRAM_EN_G    => false,
         DATA_WIDTH_G => 20)
      port map (
         rst                => kpixClkRst,
         wr_clk             => kpixClk,
         din(19 downto 12)  => kpixRegRxOut.temperature,
         din(11 downto 0)   => kpixRegRxOut.tempCount,
         rd_clk             => sysClk,
         valid              => open,
         dout(19 downto 12) => kpixRegRxOutSys.temperature,
         dout(11 downto 0)  => kpixRegRxOutSys.tempCount);
   kpixRegRxOutSys.regAddr      <= (others => '0');
   kpixRegRxOutSys.regData      <= (others => '0');
   kpixRegRxOutSys.regValid     <= '0';
   kpixRegRxOutSys.regParityErr <= '0';

   -----------------------------------------------------------------------------
   -- Tx logic, runs on sysClk
   -----------------------------------------------------------------------------
   txSeq : process (sysClk, sysRst) is
   begin
      if (sysRst = '1') then
         txRegs <= TX_REG_INIT_C after DELAY_G;
      elsif (rising_edge(sysClk)) then
         if (sysRst = '1') then
            -- Needs synchronous reset to infer block ram
            txRamRdData <= (others => '0') after DELAY_G;
         else
            txRegs      <= txRegsIn                                                                           after DELAY_G;
            txRamRdData <= ram(to_integer(txRegs.txRowBuffer & txRegs.txColumnCount & txRegs.txColumnOffset)) after DELAY_G;  -- Might need it's own process      
         end if;
      end if;
   end process;

   txComb : process (txRegs, rxRegs, txRamRdData, kpixDataRxIn, kpixRegRxOutSys, extRegsIn, kpixConfigRegs,
                     txRowReqSync, txRxBusyRise, headerParityErrorRise, markerErrorRise, overflowErrorRise) is
      variable rVar : txRegType;
   begin
      rVar := txRegs;

      rVar.kpixDataRxOut.valid := '0';
      rVar.kpixDataRxOut.last  := '0';

      rVar.dataParityError := '0';

      -- Reset row ack when req falls
      for i in txRegs.txRowAck'range loop
         if (txRowReqSync(i) = '0') then
            rVar.txRowAck(i) := '0';
         end if;
      end loop;

      -- Trip busy output high whenever rxBusy rises
      -- Will be left high until last sample from kpix is processed
      -- (in TX_TEMP_S state)
      if (txRxBusyRise = '1') then
         rVar.kpixDataRxOut.busy := '1';
      end if;


      -- Each run through the states and back to idle processes one "row"
      -- of pixels. Each pixel contains up to 4 buckets, resulting in up
      -- to 4 samples being transmitted for each pixel.
      -- Remember, when a ram address is asserted, the data isn't available on
      -- txRamRdData until 2 cycles later (pipelined).
      case (txRegs.txState) is
         when TX_CLEAR_S =>
            -- Clear all registers back to state to begin a row
            rVar.txColumnCount  := (others => '0');
            rVar.txBucketCount  := (others => '0');
            rVar.txValidBuckets := (others => '0');
            rVar.txColumnOffset := ROW_ID_ADDR_C;  -- "1111"
            rVar.txState        := TX_IDLE_S;
            
         when TX_IDLE_S =>
            -- Prime txSample with known values
            rVar.txSample.badCountFlag := '0';

            -- Wait for current row buffer to be ready for Tx
            if (txRowReqSync(to_integer(txRegs.txRowBuffer)) = '1' and
                txRegs.txRowAck(to_integer(txRegs.txRowBuffer)) = '0') then
               -- Assert offset of Count
               rVar.txColumnOffset     := txRegs.txColumnOffset + 1;  -- "0000"
               rVar.kpixDataRxOut.busy := '1';  -- Should already be busy from rxBusy trigger but whatever
               rVar.txState            := TX_ROW_ID_S;
            end if;

         when TX_ROW_ID_S =>
            -- Row ID available on txRamRdData
            rVar.txSample.row    := txRamRdData(4 downto 0) xor "11111";  -- Reverse row order
            rVar.txSample.column := slv(txRegs.txColumnCount);
            rVar.txColumnOffset  := txRegs.txColumnOffset + 1;            -- "0001" - timestamp 0
            rVar.txState         := TX_CNT_S;

         when TX_NXT_COL_S =>
            -- Just like TX_ROW_ID but don't assign row.
            -- Used when tranistioning to next column when row id is already known
            -- (and value of r.txRamRdData does not contain the row id)
            rVar.txBucketCount   := (others => '0');
            rVar.txSample.column := slv(txRegs.txColumnCount);
            rVar.txColumnOffset  := txRegs.txColumnOffset + 1;  -- "0001"
            rVar.txState         := TX_CNT_S;

         when TX_CNT_S =>
            -- Count, trig and range data now available. Parse it out of r.txRamRdData
            rVar.txRanges              := txRamRdData(3 downto 0);
            rVar.txTriggers            := txRamRdData(10 downto 7);
            rVar.txSample.badCountFlag := '0';
            case (txRamRdData(6 downto 4)) is
               when "111" => rVar.txValidBuckets := "0000";
               when "110" => rVar.txValidBuckets := "0001";
               when "100" => rVar.txValidBuckets := "0011";
               when "101" => rVar.txValidBuckets := "0111";
               when "011" => rVar.txValidBuckets := "1111";
               when others =>
                  rVar.txValidBuckets        := "0000";
                  rVar.txSample.badCountFlag := '1';
            end case;

            rVar.dataParityError := oddParity(txRamRdData(13 downto 0));

            -- Assert addr of first ADC (current addr + 1)
            rVar.txColumnOffset := txRegs.txColumnOffset + 1;
            rVar.txState        := TX_TIMESTAMP_S;

         when TX_TIMESTAMP_S =>
            -- Must decide here if there are any buckets left to process
            -- And if there are any columns left in the row buffer to process

            if ((txRegs.txValidBuckets(to_integer(txRegs.txBucketCount(1 downto 0))) = '1' or
                 kpixConfigRegs.rawDataMode = '1') and
                txRegs.txBucketCount(2) = '0') then  -- Bucket count hasn't rolled over

               -- Buckets remain
               -- Read timestamp from ram.
               -- Trigger, Range and other sample fields can be assigned here too
               -- This happens up to 4 times depending on txValidBuckets
               rVar.txSample.timestamp  := grayDecode(txRamRdData(12 downto 0));
               rVar.txSample.rangeBit   := txRegs.txRanges(to_integer(txRegs.txBucketCount(1 downto 0)));
               rVar.txSample.triggerBit := txRegs.txTriggers(to_integer(txRegs.txBucketCount(1 downto 0)));
               rVar.txSample.bucket     := slv(txRegs.txBucketCount(1 downto 0));
               rVar.txSample.emptyBit   := not txRegs.txValidBuckets(to_integer(txRegs.txBucketCount(1 downto 0)));
               rVar.dataParityError     := oddParity(txRamRdData(13 downto 0));

               -- Assert addr of next timestamp
--          rVar.txColumnOffset := r.txColumnOffset + 1;  -- not necessary
               rVar.txState := TX_ADC_DATA_S;
            else
               -- Done with buckets, go to next column in row
               rVar.txColumnCount  := txRegs.txColumnCount + 1;
               rVar.txColumnOffset := "0000";                  -- Make this a constant
               rVar.txState        := TX_NXT_COL_S;
               if (txRegs.txColumnCount = unsigned(kpixConfigRegs.numColumns)) then
                  -- Done with row, mark row buffer clear.
                  -- increment row buffer and go all the way back
                  rVar.txRowAck(to_integer(txRegs.txRowBuffer)) := '1';
                  rVar.txRowBuffer                              := txRegs.txRowBuffer + 1;
                  rVar.txState                                  := TX_CLEAR_S;
                  if (unsigned(txRegs.txSample.row) = 0) then  -- last row read out (31-0)
                     rVar.txState := TX_TEMP_S;
                  end if;
               end if;
            end if;


         when TX_ADC_DATA_S =>
            -- Read ADC value from ram
            -- This happens up to 4 times depending on txValidBuckets
            rVar.txSample.adc    := grayDecode(txRamRdData(12 downto 0));
            rVar.dataParityError := oddParity(txRamRdData(13 downto 0));
--        rVar.txColumnOffset := r.txColumnOffset + 1;  -- not necessary
            rVar.txBucketCount   := txRegs.txBucketCount + 1;
            rVar.txState         := TX_SEND_SAMPLE_S;

         when TX_SEND_SAMPLE_S =>
            -- Put out sample and wait for ack
            rVar.kpixDataRxOut.data  := formatSample(txRegs.txSample);
            rVar.kpixDataRxOut.valid := '1';
            if (kpixDataRxIn.ack = '1') then
               rVar.kpixDataRxOut.valid := '0';
               rVar.kpixDataRxOut.last  := '0';
               rVar.txColumnOffset      := txRegs.txColumnOffset + 1;  -- Timestamp of next bucket
               rVar.txState             := TX_WAIT_S;
            end if;

         when TX_WAIT_S =>
            -- Memory pipeline will run dry waiting for ready in TX_SEND_SAMPLE_S
            -- Must wait one cycle here for it to fill back up
            rVar.txColumnOffset := txRegs.txColumnOffset + 1;  -- ADC of next bucket
            rVar.txState        := TX_TIMESTAMP_S;

         when TX_TEMP_S =>
            rVar.kpixDataRxOut.data  := formatTemperature(kpixRegRxOutSys);
            rVar.kpixDataRxOut.valid := '1';
            rVar.kpixDataRxOut.last  := '1';
            if (kpixDataRxIn.ack = '1') then
               rVar.kpixDataRxOut.valid := '0';
               rVar.kpixDataRxOut.last  := '0';
               rVar.kpixDataRxOut.busy  := '0';
               rVar.txState             := TX_CLEAR_S;
            end if;
      end case;

      -- Error Counts

      -- Increment counts whenever rising edge detected in error signals
      if (headerParityErrorRise = '1') then
         rVar.extRegsOut.headerParityErrorCount := slv(unsigned(txRegs.extRegsOut.headerParityErrorCount) + 1);
      end if;
      if (markerErrorRise = '1') then
         rVar.extRegsOut.markerErrorCount := slv(unsigned(txRegs.extRegsOut.markerErrorCount) + 1);
      end if;
      if (overflowErrorRise = '1') then
         rVar.extRegsOut.overflowErrorCount := slv(unsigned(txRegs.extRegsOut.overflowErrorCount) + 1);
      end if;
      if (txRegs.dataParityError = '1') then
         rVar.extRegsOut.dataParityErrorCount := slv(unsigned(txRegs.extRegsOut.dataParityErrorCount) + 1);
      end if;

      -- Reset counts when requested by software
      if (extRegsIn.resetHeaderParityErrorCount = '1') then
         rVar.extRegsOut.headerParityErrorCount := (others => '0');
      end if;
      if(extRegsIn.resetMarkerErrorCount = '1') then
         rVar.extRegsOut.markerErrorCount := (others => '0');
      end if;
      if (extRegsIn.resetOverflowErrorCount = '1') then
         rVar.extRegsOut.overflowErrorCount := (others => '0');
      end if;
      if (extRegsIn.resetDataParityErrorCount = '1') then
         rVar.extRegsOut.dataParityErrorCount := (others => '0');
      end if;

      -- Registers
      txRegsIn <= rVar;

      -- Outputs
      extRegsOut    <= txRegs.extRegsOut;
      kpixDataRxOut <= txRegs.kpixDataRxOut;

   end process;

end architecture rtl;
