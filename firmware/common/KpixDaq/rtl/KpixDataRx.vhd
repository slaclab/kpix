-------------------------------------------------------------------------------
-- Title      : KPIX Data Receive Module
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2018-05-18
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

use work.KpixPkg.all;

entity KpixDataRx is

   generic (
      TPD_G             : time    := 1 ns;  -- Simulation register delay
      KPIX_ID_G         : natural := 0;     -- 
      NUM_ROW_BUFFERS_G : natural := 4);    -- Number of row buffers (power of 2)

   port (
      clk200           : in  sl;                 -- Clock for Tx (EventBuilder interface)
      rst200           : in  sl;
      -- System config
      sysConfig        : in  SysConfigType;
      -- Serial input
      kpixClkPreFall   : in  sl;
      kpixSerRxIn      : in  sl;                 -- Serial Data from KPIX      
      -- AXI-Lite interface for registers
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType;
      -- Temperature from kpix register block
      temperature      : in  slv(7 downto 0);
      tempCount        : in  slv(11 downto 0);
      -- Stream interface to event builder
      kpixDataRxMaster : out AxiStreamMasterType;
      kpixDataRxSlave  : in  AxiStreamSlaveType  -- From EventBuilder

      );

end entity KpixDataRx;

architecture rtl of KpixDataRx is

   -----------------------------------------------------------------------------
   -- Constants
   -----------------------------------------------------------------------------
   constant RAM_DATA_WIDTH_C   : natural         := 14;
   constant COLUMN_SIZE_C      : natural         := 16;  -- 9 words/column + rowId
   constant NUM_COLUMNS_C      : natural         := 32;
   constant RAM_DEPTH_C        : natural         := COLUMN_SIZE_C * NUM_COLUMNS_C * NUM_ROW_BUFFERS_G;
   constant RAM_ADDR_WIDTH_C   : natural         := log2(RAM_DEPTH_C);
   constant SHIFT_REG_LENGTH_C : natural         := 15;
   constant DATA_SAMPLE_C      : slv(3 downto 0) := "0000";
   constant TEMP_SAMPLE_C      : slv(3 downto 0) := "0001";
   constant ROW_ID_ADDR_C      : slv(3 downto 0) := "1111";

   -----------------------------------------------------------------------------
   -- RAM
   -----------------------------------------------------------------------------
   signal txRamRdAddr : slv(RAM_ADDR_WIDTH_C-1 downto 0);
   signal txRamRdData : slv(RAM_DATA_WIDTH_C-1 downto 0);

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

   type RegType is record
      axilReadSlave          : AxiLiteReadSlaveType;
      axilWriteSlave         : AxiLiteWriteSlaveType;
      enabled                : sl;
      markerErrorCount       : slv(7 downto 0);
      headerParityErrorCount : slv(7 downto 0);
      dataParityErrorCount   : slv(7 downto 0);
      overflowErrorCount     : slv(7 downto 0);
      dataParityError : sl;
      resetCounters          : sl;
      -- RX
      rxShiftData            : slv(0 to SHIFT_REG_LENGTH_C-1);  -- Upward indexed to match documentation
      rxShiftCount           : slv(5 downto 0);                 -- Counts bits shifted in
      rxColumnCount          : slv(4 downto 0);                 -- 32 columns
      rxRowId                : slv(4 downto 0);
      rxWordId               : slv(3 downto 0);
      rxState                : RxStateType;
      rxRamWrAddr            : slv(RAM_ADDR_WIDTH_C-1 downto 0);
      rxRamWrData            : slv(RAM_DATA_WIDTH_C-1 downto 0);
      rxRamWrEn              : sl;
      rxRowBuffer            : slv(log2(NUM_ROW_BUFFERS_G)-1 downto 0);
      rxRowReq               : slv(NUM_ROW_BUFFERS_G-1 downto 0);
      rxBusy                 : sl;
      -- TX
      txRowBuffer            : slv(log2(NUM_ROW_BUFFERS_G)-1 downto 0);
      txSample               : SampleType;
      txState                : TxStateType;
      txColumnCount          : slv(4 downto 0);
      txBucketCount          : slv(2 downto 0);
      txColumnOffset         : slv(3 downto 0);
      txTriggers             : slv(3 downto 0);
      txValidBuckets         : slv(3 downto 0);
      txRanges               : slv(3 downto 0);
      txRowAck               : slv(NUM_ROW_BUFFERS_G-1 downto 0);
      -- Outstream
      kpixDataRxMaster       : AxiStreamMasterType;
   end record;

   constant REG_INIT_C : RegType := (
      axilReadSlave          => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave         => AXI_LITE_WRITE_SLAVE_INIT_C,
      enabled                => '0',
      markerErrorCount       => (others => '0'),
      headerParityErrorCount => (others => '0'),
      dataParityErrorCount   => (others => '0'),
      overflowErrorCount     => (others => '0'),
      dataParityError => '0',
      resetCounters          => '0',
      rxShiftData            => (others => '0'),
      rxShiftCount           => (others => '0'),
      rxColumnCount          => (others => '0'),
      rxRowId                => (others => '0'),
      rxWordId               => (others => '0'),
      rxState                => RX_IDLE_S,
      rxRamWrAddr            => (others => '0'),
      rxRamWrData            => (others => '0'),
      rxRamWrEn              => '0',
      rxRowBuffer            => (others => '0'),
      rxRowReq               => (others => '0'),
      rxBusy                 => '0',
      txRowBuffer            => (others => '0'),
      txSample               => SAMPLE_INIT_C,
      txState                => TX_CLEAR_S,
      txColumnCount          => (others => '0'),
      txBucketCount          => (others => '0'),
      txColumnOffset         => (others => '0'),
      txTriggers             => (others => '0'),
      txValidBuckets         => (others => '0'),
      txRanges               => (others => '0'),
      txRowAck               => (others => '0'),
      kpixDataRxMaster       => axiStreamMasterInit(RX_DATA_AXIS_CONFIG_C));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   -----------------------------------------------------------------------------
   -- Functions
   -----------------------------------------------------------------------------
   -- Format a data sample into a 64 bit slv for transmission
   function formatSample (sample : SampleType) return slv is
      variable retVar : slv(63 downto 0);
   begin
      retVar(63 downto 60) := DATA_SAMPLE_C;  -- Type Field
      retVar(59 downto 48) := toSlv(KPIX_ID_G, 12);
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

begin

   U_SimpleDualPortRam_1 : entity work.SimpleDualPortRam
      generic map (
         TPD_G        => TPD_G,
         BRAM_EN_G    => true,
         DOB_REG_G    => false,         -- I think
         DATA_WIDTH_G => RAM_DATA_WIDTH_C,
         ADDR_WIDTH_G => RAM_ADDR_WIDTH_C)
      port map (
         clka  => clk200,               -- [in]
         wea   => r.rxRamWrEn,          -- [in]
         addra => r.rxRamWrAddr,        -- [in]
         dina  => r.rxRamWrData,        -- [in]
         clkb  => clk200,               -- [in]
         rstb  => rst200,               -- [in]
         addrb => txRamRdAddr,          -- [in]
         doutb => txRamRdData);         -- [out]


   comb : process (axilReadMaster, axilWriteMaster, kpixClkPreFall, kpixDataRxSlave, kpixSerRxIn, r,
                   rst200, sysConfig, tempCount, temperature, txRamRdData) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;

   begin
      v := r;

      ----------------------------------------------------------------------------------------------
      -- AXI Lite registers
      ----------------------------------------------------------------------------------------------
      v.resetCounters := '0';
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

--      axiSlaveRegister(axilEp, X"00", 0, v.enabled);
      axiSlaveRegister(axilEp, x"00", 0, v.markerErrorCount);      
      axiSlaveRegister(axilEp, X"04", 0, v.overflowErrorCount);
      axiSlaveRegister(axilEp, x"08", 0, v.headerParityErrorCount);
      axiSlaveRegister(axilEp, X"0C", 0, v.dataParityErrorCount);
      axiSlaveRegister(axilEp, X"10", 0, v.resetCounters);

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;

      ----------------------------------------------------------------------------------------------
      -- RX Logic
      ----------------------------------------------------------------------------------------------
      -- Don't write to RAM unless overriden in rx state machine
      v.rxRamWrEn := '0';

      if (kpixClkPreFall = '1') then

         v.rxShiftData  := r.rxShiftData(1 to SHIFT_REG_LENGTH_C-1) & kpixSerRxIn;
         v.rxShiftCount := r.rxShiftCount + 1;

         -- RX State Machine
         case (r.rxState) is
            when RX_IDLE_S =>
               -- Wait for start bit
               if (r.rxShiftData(SHIFT_REG_LENGTH_C-1) = '1' and sysConfig.kpixEnable(KPIX_ID_G) = '1') then
                  v.rxShiftCount := (others => '0');
                  v.rxState      := RX_HEADER_S;
               end if;

            when RX_HEADER_S =>
               -- Wait for full header to arrive
               if (r.rxShiftCount = 14) then
                  -- Read header data
                  v.rxRowId       := bitReverse(r.rxShiftData(5 to 9));
                  v.rxWordId      := bitReverse(r.rxShiftData(10 to 13));
                  v.rxShiftCount  := (others => '0');
                  v.rxColumnCount := (others => '0');
                  v.rxState       := RX_ROW_ID_S;

                  if (r.rxShiftData(KPIX_MARKER_RANGE_C) /= KPIX_MARKER_C) then
                     -- Invalid Marker
                     v.markerErrorCount := r.markerErrorCount + 1;
                     v.rxState          := RX_DUMP_S;

                  elsif (r.rxShiftData(KPIX_FRAME_TYPE_INDEX_C) = KPIX_CMD_RSP_FRAME_C) then
                     -- Response frame, not data
                     v.rxState := RX_RESP_S;

                  elsif (evenParity(r.rxShiftData(KPIX_FULL_HEADER_RANGE_C)) = '0') then
                     -- Header Parity error
                     v.headerParityErrorCount := r.headerParityErrorCount + 1;
                     v.rxState                := RX_DUMP_S;

                  elsif (r.rxRowReq(conv_integer(r.rxRowBuffer)) = '1') then
                     -- All row buffers are full
                     v.overflowErrorCount := r.overflowErrorCount + 1;
                     v.rxState            := RX_DUMP_S;

                  end if;
               end if;


            when RX_ROW_ID_S =>
               -- Write Row ID for column into RAM
               v.rxRamWrAddr                  := r.rxRowBuffer & r.rxColumnCount & ROW_ID_ADDR_C;
               v.rxRamWrData                  := (others => '0');  -- Not necessary but makes things cleaner when debugging
               v.rxRamWrData(r.rxRowId'range) := r.rxRowId;
               v.rxRamWrEn                    := '1';
               v.rxState                      := RX_DATA_S;

            when RX_DATA_S =>
               -- Wait for next data to arrive
               if (r.rxShiftCount = 13) then
                  -- Write data to RAM (including parity bit)
                  v.rxRamWrAddr              := r.rxRowBuffer & r.rxColumnCount & r.rxWordId;
                  v.rxRamWrData(13 downto 0) := bitReverse(r.rxShiftData(1 to 14));
                  v.rxRamWrEn                := '1';
                  -- Increment Column count and reset shift count
                  v.rxColumnCount            := r.rxColumnCount + 1;
                  v.rxShiftCount             := (others => '0');
                  v.rxState                  := RX_ROW_ID_S;

                  -- numColumns is in sysClk domain but never changes during a run so no need to worry about
                  -- syncing it
                  if (r.rxColumnCount = sysConfig.numColumns) then
                     -- All Columns in row have been received
                     v.rxState := RX_FRAME_DONE_S;
                  end if;

               end if;

            when RX_FRAME_DONE_S =>
               -- Done with a frame
               v.rxState := RX_IDLE_S;

               -- If done with all wordIds for a row, increment the row buffer
               if (r.rxWordId = 8) then  -- replace with constant
                  v.rxRowReq(conv_integer(r.rxRowBuffer)) := '1';
                  v.rxRowBuffer                           := r.rxRowBuffer + 1;
               end if;

            when RX_DUMP_S =>
               -- Wait for a data frame of data to shift through
               if (r.rxShiftCount = 475) then
                  v.rxState := RX_IDLE_S;
               end if;

            when RX_RESP_S =>
               if (r.rxShiftCount = 59) then
                  v.rxState := RX_IDLE_S;
               end if;

         end case;

      end if;

      v.rxBusy := toSl(r.rxState /= RX_IDLE_S and r.rxState /= RX_HEADER_S and
                       r.rxState /= RX_DUMP_S and r.rxState /= RX_RESP_S);


      ----------------------------------------------------------------------------------------------
      -- TX Logic
      ----------------------------------------------------------------------------------------------
      v.kpixDataRxMaster.tvalid := '0';
      v.kpixDataRxMaster.tlast  := '0';
      -- BUSY?


      v.dataParityError := '0';
      -- Each run through the states and back to idle processes one "row"
      -- of pixels. Each pixel contains up to 4 buckets, resulting in up
      -- to 4 samples being transmitted for each pixel.
      -- Remember, when a ram address is asserted, the data isn't available on
      -- txRamRdData until 2 cycles later (pipelined).
      case (r.txState) is
         when TX_CLEAR_S =>
            -- Clear all registers back to state to begin a row
            v.txColumnCount  := (others => '0');
            v.txBucketCount  := (others => '0');
            v.txValidBuckets := (others => '0');
            v.txColumnOffset := ROW_ID_ADDR_C;  -- "1111"
            v.txState        := TX_IDLE_S;

         when TX_IDLE_S =>
            -- Prime txSample with known values
            v.txSample.badCountFlag := '0';

            -- Wait for current row buffer to be ready for Tx
            if (r.rxRowReq(conv_integer(r.txRowBuffer)) = '1') then
               -- Assert offset of Count
               v.txColumnOffset := r.txColumnOffset + 1;  -- "0000"
               --v.kpixDataRxOut.busy := '1';  -- Should already be busy from rxBusy trigger but whatever
               v.txState        := TX_ROW_ID_S;

               if (sysConfig.kpixEnable(KPIX_ID_G) = '0') then
                  -- If this kpix is not enabled, drop any data received
                  -- Clear the row request
                  v.rxRowReq(conv_integer(r.txRowBuffer)) := '0';
                  -- Increment the row buffer
                  v.txRowBuffer := r.txRowBuffer + 1;
                  -- Go back to start
                  v.txState := TX_CLEAR_S;
               end if;
            end if;

         when TX_ROW_ID_S =>
            -- Row ID available on txRamRdData
            v.txSample.row    := txRamRdData(4 downto 0) xor "11111";  -- Reverse row order
            v.txSample.column := r.txColumnCount;
            v.txColumnOffset  := r.txColumnOffset + 1;                 -- "0001" - timestamp 0
            v.txState         := TX_CNT_S;

         when TX_NXT_COL_S =>
            -- Just like TX_ROW_ID but don't assign row.
            -- Used when tranistioning to next column when row id is already known
            -- (and value of r.txRamRdData does not contain the row id)
            v.txBucketCount   := (others => '0');
            v.txSample.column := r.txColumnCount;
            v.txColumnOffset  := r.txColumnOffset + 1;  -- "0001"
            v.txState         := TX_CNT_S;

         when TX_CNT_S =>
            -- Count, trig and range data now available. Parse it out of r.txRamRdData
            v.txRanges              := txRamRdData(3 downto 0);
            v.txTriggers            := txRamRdData(10 downto 7);
            v.txSample.badCountFlag := '0';
            case (txRamRdData(6 downto 4)) is
               when "111" => v.txValidBuckets := "0000";
               when "110" => v.txValidBuckets := "0001";
               when "100" => v.txValidBuckets := "0011";
               when "101" => v.txValidBuckets := "0111";
               when "011" => v.txValidBuckets := "1111";
               when others =>
                  v.txValidBuckets        := "0000";
                  v.txSample.badCountFlag := '1';
            end case;

            if (oddParity(txRamRdData(13 downto 0)) = '1') then
               v.dataParityError := '1';
            end if;


            -- Assert addr of first ADC (current addr + 1)
            v.txColumnOffset := r.txColumnOffset + 1;
            v.txState        := TX_TIMESTAMP_S;

         when TX_TIMESTAMP_S =>
            -- Must decide here if there are any buckets left to process
            -- And if there are any columns left in the row buffer to process

            if ((r.txValidBuckets(conv_integer(r.txBucketCount(1 downto 0))) = '1' or
                 sysConfig.rawDataMode = '1') and
                r.txBucketCount(2) = '0') then  -- Bucket count hasn't rolled over

               -- Buckets remain
               -- Read timestamp from ram.
               -- Trigger, Range and other sample fields can be assigned here too
               -- This happens up to 4 times depending on txValidBuckets
               v.txSample.timestamp  := grayDecode(txRamRdData(12 downto 0));
               v.txSample.rangeBit   := r.txRanges(conv_integer(r.txBucketCount(1 downto 0)));
               v.txSample.triggerBit := r.txTriggers(conv_integer(r.txBucketCount(1 downto 0)));
               v.txSample.bucket     := r.txBucketCount(1 downto 0);
               v.txSample.emptyBit   := not r.txValidBuckets(conv_integer(r.txBucketCount(1 downto 0)));

               if (oddParity(txRamRdData(13 downto 0)) = '1') then
                  v.dataParityError := '1';
               end if;

               v.txState := TX_ADC_DATA_S;
            else
               -- Done with buckets, go to next column in row
               v.txColumnCount  := r.txColumnCount + 1;
               v.txColumnOffset := "0000";      -- Make this a constant
               v.txState        := TX_NXT_COL_S;
               if (r.txColumnCount = sysConfig.numColumns) then
                  -- Done with row, mark row buffer clear.
                  -- increment row buffer and go all the way back
                  v.rxRowReq(conv_integer(r.txRowBuffer)) := '0';
                  v.txRowBuffer                           := r.txRowBuffer + 1;
                  v.txState                               := TX_CLEAR_S;
                  if (r.txSample.row = 0) then  -- last row read out (31-0)
                     v.txState := TX_TEMP_S;
                  end if;
               end if;
            end if;

         when TX_ADC_DATA_S =>
            -- Read ADC value from ram
            -- This happens up to 4 times depending on txValidBuckets
            if (oddParity(txRamRdData(13 downto 0)) = '1') then
               v.dataParityError := '1';
            end if;
            v.txSample.adc  := grayDecode(txRamRdData(12 downto 0));
            v.txBucketCount := r.txBucketCount + 1;
            v.txState       := TX_SEND_SAMPLE_S;

         when TX_SEND_SAMPLE_S =>
            -- Put out sample and wait for ack
            v.kpixDataRxMaster.tdata(63 downto 0) := formatSample(r.txSample);
            v.kpixDataRxMaster.tvalid             := '1';
            if (r.kpixDataRxMaster.tValid = '1' and kpixDataRxSlave.tready = '1') then
               v.kpixDataRxMaster.tvalid := '0';
               v.kpixDataRxmaster.tlast  := '0';
               v.txColumnOffset          := r.txColumnOffset + 1;  -- Timestamp of next bucket
               v.txState                 := TX_WAIT_S;
            end if;

         when TX_WAIT_S =>
            -- Memory pipeline will run dry waiting for ready in TX_SEND_SAMPLE_S
            -- Must wait one cycle here for it to fill back up
            v.txColumnOffset := r.txColumnOffset + 1;  -- ADC of next bucket
            v.txState        := TX_TIMESTAMP_S;

         when TX_TEMP_S =>
            v.kpixDataRxMaster.tdata(63 downto 60) := TEMP_SAMPLE_C;
            v.kpixDataRxMaster.tdata(59 downto 48) := toSlv(KPIX_ID_G, 12);
            v.kpixDataRxMaster.tdata(31 downto 24) := tempCount(7 downto 0);
            v.kpixDataRxMaster.tdata(23 downto 16) := temperature;
            v.kpixDataRxMaster.tdata(7 downto 0)   := grayDecode(temperature);
            v.kpixDataRxMaster.tvalid              := '1';
            v.kpixDataRxMaster.tlast               := '1';
            if (r.kpixDataRxMaster.tvalid = '1' and kpixDataRxSlave.tready = '1') then
               v.kpixDataRxMaster.tvalid := '0';
               v.kpixDataRxMaster.tlast  := '0';
--               v.kpixDataRxMaster.busy   := '0';
               v.txState                 := TX_CLEAR_S;
            end if;
      end case;

      -- Counters Saturate
      if (r.headerParityErrorCount = X"FF") then
         v.headerParityErrorCount := r.headerParityErrorCount;
      end if;

      if (r.markerErrorCount = X"FF") then
         v.markerErrorCount := r.markerErrorCount;
      end if;

      if (r.overflowErrorCount = X"FF") then
         v.overflowErrorCount := r.overflowErrorCount;
      end if;

      if (r.dataParityError = '1') then
         v.dataParityErrorCount := r.dataParityErrorCount + 1;
      end if;
      
      if (r.dataParityErrorCount = X"FF") then
         v.dataParityErrorCount := r.dataParityErrorCount;
      end if;

      if (v.resetCounters = '1') then
         v.headerParityErrorCount := (others => '0');
         v.markerErrorCount       := (others => '0');
         v.overflowErrorCount     := (others => '0');
         v.dataParityErrorCount   := (others => '0');
      end if;


      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      -- Registers
      rin <= v;

      txRamRdAddr <= r.txRowBuffer & r.txColumnCount & r.txColumnOffset;

      -- Outputs
      kpixDataRxMaster <= r.kpixDataRxMaster;

   end process;

   seq : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end architecture rtl;
