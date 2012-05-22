-------------------------------------------------------------------------------
-- Title      : KPIX Data Receive Module
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2012-05-21
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
use work.SynchronizePkg.all;
use work.KpixPkg.all;
use work.KpixDataRxPkg.all;
use work.KpixRegRxPkg.all;
use work.EthFrontEndPkg.all;
use work.EthRegDecoderPkg.all;


entity KpixDataRx is
  
  generic (
    DELAY_G           : time           := 1 ns;  -- Simulation register delay
    KPIX_ID_G         : KpixNumberType := 0;     -- 
    NUM_ROW_BUFFERS_G : natural        := 4;     -- Number of row buffers (power of 2)
    RAM_WIDTH_G       : natural        := 14);   -- Adjust as necessary to infer block ram
  port (
    sysClk           : in  sl;                   -- Clock for Tx (EventBuilder interface)
    sysRst           : in  sl;
    kpixClk          : in  sl;                   -- Clock for RX (KPIX interface)
    kpixRst          : in  sl;
    kpixSerRxIn      : in  sl;                   -- Serial Data from KPIX
    kpixRegRxOut     : in  KpixRegRxOutType;     -- For Temperature
    kpixDataRxOut    : out KpixDataRxOutType;    -- To EventBuilder
    kpixDataRxIn     : in  KpixDataRxInType;     -- From EventBuilder
    ethRegDecoderOut : in  EthRegDecoderOutType;
    ethRegDecoderIn  : out EthRegDecoderInType

    );

end entity KpixDataRx;

architecture rtl of KpixDataRx is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
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
  type RamType is array (0 to RAM_DEPTH_C-1) of slv(RAM_WIDTH_G-1 downto 0);
  signal ram         : RamType;
  signal txRamRdData : slv(RAM_WIDTH_G-1 downto 0);

  ---------------------------------------------------------------------------
  -- Rx controlled Registers
  ---------------------------------------------------------------------------
  type RxStateType is (RX_IDLE_S, RX_HEADER_S, RX_ROW_S, RX_DATA_S, RX_FRAME_DONE_S, RX_DUMP_S, RX_RESP_S);

  type RxRegType is record
    rxShiftData     : slv(0 to SHIFT_REG_LENGTH_C-1);  -- Upward indexed to match documentation
    rxShiftCount    : unsigned(5 downto 0);            -- Counts bits shifted in
    rxColumnCount   : unsigned(4 downto 0);            -- 32 columns
    rxRowId         : unsigned(4 downto 0);
    rxWordId        : unsigned(3 downto 0);
    rxState         : RxStateType;
    rxRamWrAddr     : unsigned(log2(RAM_DEPTH_C)-1 downto 0);
    rxRamWrData     : slv(RAM_WIDTH_G-1 downto 0);
    rxRamWrEn       : sl;
    rxRowBuffer     : unsigned(log2(NUM_ROW_BUFFERS_G)-1 downto 0);
    rxRowReq        : slv(NUM_ROW_BUFFERS_G-1 downto 0);
    rxRowAck        : SynchronizerArray(NUM_ROW_BUFFERS_G-1 downto 0);
    markerErr       : sl;
    headerParityErr : sl;
    overflowErr     : sl;
    rxBusy          : sl;
    
  end record;

  signal rxRegs, rxRegsIn : RxRegType;

  ---------------------------------------------------------------------------
  -- Tx controlled Registers
  ---------------------------------------------------------------------------
  type TxStateType is (TX_CLEAR_S, TX_IDLE_S, TX_ROW_ID_S, TX_NXT_COL_S, TX_CNT_S, TX_TIMESTAMP_S,
                       TX_ADC_DATA_S, TX_SEND_SAMPLE_S, TX_WAIT_S, TX_TEMP_S);

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

  type TxRegType is record
--    txRamRdData          : slv(RAM_WIDTH_G-1 downto 0);
    txRowBuffer          : unsigned(log2(NUM_ROW_BUFFERS_G)-1 downto 0);
    txSample             : SampleType;
    txState              : TxStateType;
    txColumnCount        : unsigned(4 downto 0);
    txBucketCount        : unsigned(2 downto 0);
    txColumnOffset       : unsigned(3 downto 0);
    txTriggers           : slv(3 downto 0);
    txValidBuckets       : unsigned(3 downto 0);
    txBucketDecErr       : sl;
    txRanges             : slv(3 downto 0);
    txRowReq             : SynchronizerArray(NUM_ROW_BUFFERS_G-1 downto 0);
    txRowAck             : slv(NUM_ROW_BUFFERS_G-1 downto 0);
    kpixDataRxOut        : KpixDataRxOutType;  -- Output
    markerErrSync        : SynchronizerType;
    markerErrCount       : unsigned(31 downto 0);
    headerParityErrSync  : SynchronizerType;
    headerParityErrCount : unsigned(31 downto 0);
    overflowErrSync      : SynchronizerType;
    overflowErrCount     : unsigned(31 downto 0);
    dataParityErr        : sl;
    dataParityErrCount   : unsigned(31 downto 0);
    txBusyTmp            : sl;
    enabled              : sl;
    rawDataMode          : sl;
  end record;

  signal txRegs, txRegsIn : TxRegType;

  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  -- Find the nth index in shift register given number of shifts that have occured
  function rxIndex (
    n          : natural;
    shiftCount : natural)
    return natural is
  begin
    return SHIFT_REG_LENGTH_C - shiftCount + n - 1;
  end function rxIndex;

  -- Format a data sample for transmission
  function formatSample (
    sample : SampleType)
    return slv
  is
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

  -- Format a temperature sample for transmission.
  function formatTemperature (
    temp : KpixRegRxOutType)
    return slv
  is
    variable retVar : slv(63 downto 0);
  begin
    retVar(63 downto 60) := TEMP_SAMPLE_C;
    retVar(59 downto 48) := slv(to_unsigned(KPIX_ID_G, 12));
    retVar(47 downto 42) := "000000";
    retVar(41 downto 32) := temp.tempCount;
    retVar(31 downto 0)  := temp.temperature;
    return retVar;
  end function formatTemperature;

begin



  -----------------------------------------------------------------------------
  -- Rx Logic
  -- Runs on kpixClk
  -----------------------------------------------------------------------------
  rxSeq : process (kpixClk, kpixRst) is
  begin
    if (kpixRst = '1') then
      rxRegs.rxShiftData     <= (others => '0');
      rxRegs.rxShiftCount    <= (others => '0');
      rxRegs.rxColumnCount   <= (others => '0');
      rxRegs.rxRowId         <= (others => '0');
      rxRegs.rxWordId        <= (others => '0');
      rxRegs.rxState         <= RX_IDLE_S;
      rxRegs.rxRamWrAddr     <= (others => '0');
      rxRegs.rxRamWrData     <= (others => '0');
      rxRegs.rxRamWrEn       <= '0';
      rxRegs.rxRowBuffer     <= (others => '0');
      rxRegs.rxRowReq        <= (others => '0');
      initSynchronizerArray(rxRegs.rxRowAck, SYNCHRONIZER_INIT_0_C);
      rxRegs.markerErr       <= '0';
      rxRegs.headerParityErr <= '0';
      rxRegs.overflowErr     <= '0';
      rxRegs.rxBusy          <= '0';
    elsif (rising_edge(kpixClk)) then
      rxRegs <= rxRegsIn;
      if (rxRegs.rxRamWrEn = '1') then
        ram(to_integer(rxRegs.rxRamWrAddr)) <= rxRegs.rxRamWrData;
      end if;
    end if;
  end process rxSeq;

  rxComb : process (rxRegs, txRegs, kpixSerRxIn) is
    variable rxRegsVar : RxRegType;
  begin
    rxRegsVar := rxRegs;

    -- Shift in new bit and increment counter every clock
    rxRegsVar.rxShiftData  := rxRegs.rxShiftData(1 to SHIFT_REG_LENGTH_C-1) & kpixSerRxIn;
    rxRegsVar.rxShiftCount := rxRegs.rxShiftCount + 1;

    -- Don't write to RAM unless overriden in rx state machine
    rxRegsVar.rxRamWrEn := '0';

    -- Error signals asserted for 1 cycle only
    rxRegsVar.markerErr       := '0';
    rxRegsVar.headerParityErr := '0';
    rxRegsVar.overflowErr     := '0';

    -- Synchronize signals from Tx Logic
    synchronize(txRegs.txRowAck, rxRegs.rxRowAck, rxRegsVar.rxRowAck);

    -- Reset rxRowReq signal upon txRowAck
    for i in rxRegs.rxRowReq'range loop
      if (rxRegs.rxRowAck(i).sync = '1') then
        rxRegsVar.rxRowReq(i) := '0';
      end if;
    end loop;

    -- RX State Machine
    case (rxRegs.rxState) is
      when RX_IDLE_S =>
        -- Wait for start bit
        -- Should synchronize enabled
        if (rxRegs.rxShiftData(SHIFT_REG_LENGTH_C-1) = '1' and txRegs.enabled = '1') then
          rxRegsVar.rxShiftCount := (others => '0');
          rxRegsVar.rxState      := RX_HEADER_S;
        end if;
        
      when RX_HEADER_S =>
        -- Wait for full header to arrive
        if (rxRegs.rxShiftCount = 14) then
          -- Read header data
          rxRegsVar.rxRowId       := unsigned(bitReverse(rxRegs.rxShiftData(5 to 9)));
          rxRegsVar.rxWordId      := unsigned(bitReverse(rxRegs.rxShiftData(10 to 13)));
          rxRegsVar.rxShiftCount  := (others => '0');
          rxRegsVar.rxColumnCount := (others => '0');
          rxRegsVar.rxState       := RX_ROW_S;

          if (rxRegs.rxShiftData(rxindex(0, 14) to rxIndex(3, 14)) /= "0101") then  -- 7 to 10
            -- Invalid Marker
            rxRegsVar.markerErr := '1';
            rxRegsVar.rxState   := RX_DUMP_S;

          elsif (rxRegs.rxShiftData(KPIX_FRAME_TYPE_INDEX_C) = KPIX_CMD_RSP_FRAME_C) then  --index 10
            -- Response frame, not data
            rxRegsVar.rxState := RX_RESP_S;

          elsif (evenParity(rxRegs.rxShiftData(0 to 14)) = '0') then  -- 7 to 21
            -- Header Parity error
            rxRegsVar.headerParityErr := '1';
            rxRegsVar.rxState         := RX_DUMP_S;

          elsif (rxRegs.rxRowReq(to_integer(rxRegs.rxRowBuffer)) = '1' or
                 rxRegs.rxRowAck(to_integer(rxRegs.rxRowBuffer)).sync = '1') then  
            -- All row buffers are full
            rxRegsVar.overflowErr := '1';
            rxRegsVar.rxState     := RX_DUMP_S;

          end if;
        end if;


      when RX_ROW_S =>
        -- Write Row ID for column into RAM
        rxRegsVar.rxRamWrAddr                       := rxRegs.rxRowBuffer & rxRegs.rxColumnCount & ROW_ID_ADDR_C;
        rxRegsVar.rxRamWrData(rxRegs.rxRowId'range) := slv(rxRegs.rxRowId);
        rxRegsVar.rxRamWrEn                         := '1';
        rxRegsVar.rxState                           := RX_DATA_S;

      when RX_DATA_S =>
        -- Wait for next data to arrive
        if (rxRegs.rxShiftCount = 13) then
          -- Write data to RAM
          rxRegsVar.rxRamWrAddr              := rxRegs.rxRowBuffer & rxRegs.rxColumnCount & rxRegs.rxWordId;
          rxRegsVar.rxRamWrData(13 downto 0) := bitReverse(rxRegs.rxShiftData(1 to 14));
          rxRegsVar.rxRamWrEn                := '1';
          -- Increment Column count and reset shift count
          rxRegsVar.rxColumnCount            := rxRegs.rxColumnCount + 1;
          rxRegsVar.rxShiftCount             := (others => '0');
          rxRegsVar.rxState                  := RX_ROW_S;

          if (rxRegs.rxColumnCount = 31) then
            -- All Columns in row have been received
            rxRegsVar.rxState := RX_FRAME_DONE_S;
          end if;
          
        end if;

      when RX_FRAME_DONE_S =>
        -- Done with a frame
        rxRegsVar.rxState := RX_IDLE_S;

        -- If done with all wordIds for a row, increment the row buffer
        if (rxRegs.rxWordId = 8) then   -- replace with constant
          rxRegsVar.rxRowReq(to_integer(rxRegs.rxRowBuffer)) := '1';
          rxRegsVar.rxRowBuffer                              := rxRegs.rxRowBuffer + 1;
        end if;

      when RX_DUMP_S =>
        -- Wait for a data frame of data to shift through
        if (rxRegs.rxShiftCount = 475) then
          rxRegsVar.rxState := RX_IDLE_S;
        end if;

      when RX_RESP_S =>
        if (rxRegs.rxShiftCount = 59) then
          rxRegsVar.rxState := RX_IDLE_S;
        end if;
        
      when others =>                    -- Necessary?
        rxRegsVar.rxShiftCount  := (others => '0');
        rxRegsVar.rxColumnCount := (others => '0');
        rxRegsVar.rxRowId       := (others => '0');
        rxRegsVar.rxWordId      := (others => '0');
        rxRegsVar.rxState       := RX_IDLE_S;
        rxRegsVar.rxRamWrAddr   := (others => '0');
        rxRegsVar.rxRamWrData   := (others => '0');
        rxRegsVar.rxRamWrEn     := '0';
    end case;

    rxRegsVar.rxBusy := toSl(rxRegs.rxState /= RX_IDLE_S);

    rxRegsIn <= rxRegsVar;
  end process;

  -----------------------------------------------------------------------------
  -- Tx logic, runs on sysClk
  -----------------------------------------------------------------------------
  txSeq : process (sysClk, sysRst) is
  begin
    if (sysRst = '1') then
--      txRegs.txRamRdData           <= (others => '0');
      txRegs.txRowBuffer           <= (others => '0');
      txRegs.txSample.emptyBit     <= '0';
      txRegs.txSample.badCountFlag <= '0';
      txRegs.txSample.rangeBit     <= '0';
      txRegs.txSample.triggerBit   <= '0';
      txRegs.txSample.bucket       <= (others => '0');
      txRegs.txSample.row          <= (others => '0');
      txRegs.txSample.column       <= (others => '0');
      txRegs.txSample.timestamp    <= (others => '0');
      txRegs.txSample.adc          <= (others => '0');
      txRegs.txState               <= TX_CLEAR_S;
      txRegs.txColumnCount         <= (others => '0');
      txRegs.txBucketCount         <= (others => '0');
      txRegs.txColumnOffset        <= (others => '0');
      txRegs.txTriggers            <= (others => '0');
      txRegs.txValidBuckets        <= (others => '0');
      txRegs.txBucketDecErr        <= '0';
      txRegs.txRanges              <= (others => '0');
      initSynchronizerArray(txRegs.txRowReq, SYNCHRONIZER_INIT_0_C);
      txRegs.txRowAck              <= (others => '0');
      txRegs.kpixDataRxOut.data    <= (others => '0');
      txRegs.kpixDataRxOut.valid   <= '0';
      txRegs.kpixDataRxOut.last    <= '0';
      txRegs.kpixDataRxOut.busy    <= '0';
      txRegs.markerErrSync         <= SYNCHRONIZER_INIT_0_C;
      txRegs.markerErrCount        <= (others => '0');
      txRegs.headerParityErrSync   <= SYNCHRONIZER_INIT_0_C;
      txRegs.headerParityErrCount  <= (others => '0');
      txRegs.overflowErrSync       <= SYNCHRONIZER_INIT_0_C;
      txRegs.overflowErrCount      <= (others => '0');
      txRegs.dataParityErr         <= '0';
      txRegs.dataParityErrCount    <= (others => '0');
      txRegs.txBusyTmp             <= '0';
      txRegs.enabled               <= '1';
      txRegs.rawDataMode           <= '0';

    elsif (rising_edge(sysClk)) then
      if (sysRst = '1') then
        txRamRdData <= (others => '0');
      else
        txRegs      <= txRegsIn;
        txRamRdData <= ram(to_integer(txRegs.txRowBuffer & txRegs.txColumnCount & txRegs.txColumnOffset));  -- Might need it's own process      
      end if;
    end if;
  end process;

  txComb : process (txRegs, rxRegs, txRamRdData, kpixDataRxIn, kpixRegRxOut, ethRegDecoderOut) is
    variable txRegsVar : txRegType;
  begin
    txRegsVar := txRegs;

    txRegsVar.kpixDataRxOut.valid := '0';
    txRegsVar.kpixDataRxOut.last  := '0';

    txRegsVar.dataParityErr := '0';

    -- Synchronize signals from rx
    synchronize(rxRegs.rxRowReq, txRegs.txRowReq, txRegsVar.txRowReq);


    -- Reset row ack when req falls
    for i in txRegs.txRowAck'range loop
      if (txRegs.txRowReq(i).sync = '0') then
        txRegsVar.txRowAck(i) := '0';
      end if;
    end loop;


    -- Each run through the states and back to idle processes one "row"
    -- of 32 pixels. Each pixel contains up to 4 buckets, resulting in up
    -- to 4 samples being transmitted for each pixel.
    -- Remember, when a ram address is asserted, the data isn't available on
    -- txRamRdData until 2 cycles later (pipelined).
    case (txRegs.txState) is
      when TX_CLEAR_S =>
        -- Clear all registers back to state to begin a row
        txRegsVar.txColumnCount  := (others => '0');
        txRegsVar.txBucketCount  := (others => '0');
        txRegsVar.txValidBuckets := (others => '0');
        txRegsVar.txColumnOffset := ROW_ID_ADDR_C;  -- "1111"
        txRegsVar.txState        := TX_IDLE_S;
        
      when TX_IDLE_S =>
        -- Prime txSample with known values
        txRegsVar.txSample.badCountFlag := '0';

        -- Wait for current row buffer to be ready for Tx
        if (txRegs.txRowReq(to_integer(txRegs.txRowBuffer)).sync = '1' and
            txRegs.txRowAck(to_integer(txRegs.txRowBuffer)) = '0') then
          -- Assert offset of Count
          txRegsVar.txColumnOffset := txRegs.txColumnOffset + 1;  -- "0000"
          txRegsVar.txState        := TX_ROW_ID_S;
        end if;

      when TX_ROW_ID_S =>
        -- Row ID available on txRamRdData
        txRegsVar.txSample.row    := txRamRdData(4 downto 0);
        txRegsVar.txSample.column := slv(txRegs.txColumnCount);
        txRegsVar.txColumnOffset  := txRegs.txColumnOffset + 1;  -- "0001" - timestamp 0
        txRegsVar.txState         := TX_CNT_S;

      when TX_NXT_COL_S =>
        -- Just like TX_ROW_ID but don't assign row.
        -- Used when tranistioning to next column when row id is already known
        -- (and value of r.txRamRdData does not contain the row id)
        txRegsVar.txSample.column := slv(txRegs.txColumnCount);
        txRegsVar.txColumnOffset  := txRegs.txColumnOffset + 1;  -- "0001"
        txRegsVar.txState         := TX_CNT_S;

      when TX_CNT_S =>
        -- Count, trig and range data now available. Parse it out of r.txRamRdData
        txRegsVar.txRanges   := txRamRdData(3 downto 0);
        txRegsVar.txTriggers := txRamRdData(10 downto 7);
        case (txRamRdData(6 downto 4)) is
          when "111" => txRegsVar.txValidBuckets := "0000";
          when "110" => txRegsVar.txValidBuckets := "0001";
          when "100" => txRegsVar.txValidBuckets := "0011";
          when "101" => txRegsVar.txValidBuckets := "0111";
          when "011" => txRegsVar.txValidBuckets := "1111";
          when others =>
            txRegsVar.txValidBuckets        := "0000";
            txRegsVar.txSample.badCountFlag := '1';
        end case;

        txRegsVar.dataParityErr := evenParity(txRamRdData(13 downto 0));

        -- Assert addr of first ADC (current addr + 1)
        txRegsVar.txColumnOffset := txRegs.txColumnOffset + 1;
        txRegsVar.txState        := TX_TIMESTAMP_S;

      when TX_TIMESTAMP_S =>
        -- Must decide here if there are any buckets left to process
        -- And if there are any columns left in the row buffer to process

        if ((txRegs.txValidBuckets(to_integer(txRegs.txBucketCount(1 downto 0))) = '1' or txRegs.rawDataMode = '1') and
            txRegs.txBucketCount(2) = '0') then  -- Bucket count hasn't rolled over

          -- Buckets remain
          -- Read timestamp from ram.
          -- Trigger, Range and other sample fields can be assigned here too
          -- This happens up to 4 times depending on txValidBuckets
          txRegsVar.txSample.timestamp  := grayDecode(txRamRdData(12 downto 0));
          txRegsVar.txSample.rangeBit   := txRegs.txRanges(to_integer(txRegs.txBucketCount(1 downto 0)));
          txRegsVar.txSample.triggerBit := txRegs.txTriggers(to_integer(txRegs.txBucketCount(1 downto 0)));
          txRegsVar.txSample.bucket     := slv(txRegs.txBucketCount(1 downto 0));
          txRegsVar.txSample.emptyBit   := not txRegs.txValidBuckets(to_integer(txRegs.txBucketCount(1 downto 0)));
          txRegsVar.dataParityErr       := evenParity(txRamRdData(13 downto 0));

          -- Assert addr of next timestamp
--          txRegsVar.txColumnOffset := r.txColumnOffset + 1;  -- not necessary
          txRegsVar.txState := TX_ADC_DATA_S;
        else
          -- Done with buckets, go to next column in row
          txRegsVar.txColumnCount  := txRegs.txColumnCount + 1;
          txRegsVar.txColumnOffset := "0000";  -- Make this a constant
          txRegsVar.txState        := TX_NXT_COL_S;
          if (txRegs.txColumnCount = 31) then
            -- Done with row, mark row buffer clear.
            -- increment row buffer and go all the way back
            txRegsVar.txRowAck(to_integer(txRegs.txRowBuffer)) := '1';
            txRegsVar.txRowBuffer                              := txRegs.txRowBuffer + 1;
            txRegsVar.txState                                  := TX_CLEAR_S;
            if (unsigned(txRegs.txSample.row) = 31) then
              txRegsVar.txState := TX_TEMP_S;
            end if;
          end if;
        end if;


      when TX_ADC_DATA_S =>
        -- Read ADC value from ram
        -- This happens up to 4 times depending on txValidBuckets
        txRegsVar.txSample.adc  := grayDecode(txRamRdData(12 downto 0));
        txRegsVar.dataParityErr := evenParity(txRamRdData(13 downto 0));
--        txRegsVar.txColumnOffset := r.txColumnOffset + 1;  -- not necessary
        txRegsVar.txBucketCount := txRegs.txBucketCount + 1;
        txRegsVar.txState       := TX_SEND_SAMPLE_S;

      when TX_SEND_SAMPLE_S =>
        -- Put out sample and wait for ack
        txRegsVar.kpixDataRxOut.data  := formatSample(txRegs.txSample);
        txRegsVar.kpixDataRxOut.valid := '1';
        if (kpixDataRxIn.ready = '1') then
          txRegsVar.kpixDataRxOut.valid := '0';
          txRegsVar.kpixDataRxOut.last  := '0';
          txRegsVar.txColumnOffset      := txRegs.txColumnOffset + 1;  -- Timestamp of next bucket
          txRegsVar.txState             := TX_WAIT_S;
        end if;

      when TX_WAIT_S =>
        -- Memory pipeline will run dry waiting for ready in TX_SEND_SAMPLE_S
        -- Must wait one cycle here for it to fill back up
        txRegsVar.txColumnOffset := txRegs.txColumnOffset + 1;  -- ADC of next bucket
        txRegsVar.txState        := TX_TIMESTAMP_S;

      when TX_TEMP_S =>
        txRegsVar.kpixDataRxOut.data  := formatTemperature(kpixRegRxOut);
        txRegsVar.kpixDataRxOut.valid := '1';
        txRegsVar.kpixDataRxOut.last  := '1';
        if (kpixDataRxIn.ready = '1') then
          txRegsVar.kpixDataRxOut.valid := '0';
          txRegsVar.kpixDataRxOut.last  := '0';
          txRegsVar.txState             := TX_CLEAR_S;
        end if;
    end case;

    -- Error Counts
    synchronize(rxRegs.headerParityErr, txRegs.headerParityErrSync, txRegsVar.headerParityErrSync);
    if (detectRisingEdge(txRegs.headerParityErrSync)) then
      txRegsVar.headerParityErrCount := txRegs.headerParityErrCount + 1;
    end if;
    synchronize(rxRegs.markerErr, txRegs.markerErrSync, txRegsVar.markerErrSync);
    if(detectRisingEdge(txRegs.markerErrSync)) then
      txRegsVar.markerErrCount := txRegs.markerErrCount + 1;
    end if;
    synchronize(rxRegs.overflowErr, txRegs.overflowErrSync, txRegsVar.overflowErrSync);
    if (detectRisingEdge(txRegs.overflowErrSync)) then
      txRegsVar.overflowErrCount := txRegs.overflowErrCount + 1;
    end if;
    if (txRegs.dataParityErr = '1') then
      txRegsVar.dataParityErrCount := txRegs.dataParityErrCount + 1;
    end if;

    -- Eth Registers Interface
    -- Clear error counter if written to
    if (ethRegDecoderOut.regOp = ETH_REG_WRITE_C) then
      if (ethRegDecoderOut.regSelect(KPIX_DATA_RX_MODE_REG_ADDR_C(KPIX_ID_G)) = '1') then
        txRegsVar.enabled     := ethRegDecoderOut.dataOut(0);
        txRegsVar.rawDataMode := ethRegDecoderOut.dataOut(1);
      end if;
      if (ethRegDecoderOut.regSelect(KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G)) = '1') then
        txRegsVar.headerParityErrCount := (others => '0');
      end if;
      if (ethRegDecoderOut.regSelect(KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G)) = '1') then
        txRegsVar.dataParityErrCount := (others => '0');
      end if;
      if (ethRegDecoderOut.regSelect(KPIX_MARKER_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G)) = '1') then
        txRegsVar.markerErrCount := (others => '0');
      end if;
      if (ethRegDecoderOut.regSelect(KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G)) = '1') then
        txRegsVar.overflowErrCount := (others => '0');
      end if;

    end if;
    ethRegDecoderIn.dataIn                                                       <= (others => slvAll('Z', 32));  -- don't think this will work
    ethRegDecoderIn.dataIn(KPIX_DATA_RX_MODE_REG_ADDR_C(KPIX_ID_G))              <= (0      => txRegs.enabled, 1 => txRegs.rawDataMode, others => '0');
    ethRegDecoderIn.dataIn(KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G)) <= slv(txRegs.headerParityErrCount);
    ethRegDecoderIn.dataIn(KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G))   <= slv(txRegs.dataParityErrCount);
    ethRegDecoderIn.dataIn(KPIX_MARKER_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G))        <= slv(txRegs.markerErrCount);
    ethRegDecoderIn.dataIn(KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C(KPIX_ID_G))      <= slv(txRegs.overflowErrCount);

    -- Syncrhonize rxBusy to sysClk.
    txRegsVar.txBusyTmp          := toSl(rxRegs.rxState /= RX_IDLE_S);
    txRegsVar.kpixDataRxOut.busy := txRegs.txBusyTmp;  -- 

    -- Registers
    txRegsIn <= txRegsVar;

    -- Outputs
    kpixDataRxOut <= txRegs.kpixDataRxOut;

  end process;

end architecture rtl;
