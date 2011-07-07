-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA Data Frame Receiver
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixDataRx.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2004
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the data frame receiver.
-- Word 0 = Count
--          Bits[3:0]   = Range bits
--          Bits[6:4]   = Gray code event count F,C,8,9,3 = 0,1,2,3,4
--          Bits[10:7]  = Trigger bits
--          Bits[12:11] = Unused
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2004: created.
-- 05/07/2007: Modified start and end bit generation to check for proper frame
--             integrity
-- 09/19/2007: Added ability to shift up all data in raw data mode.
-- 06/12/2009: Changed storage mechanism to support greater number of channels.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;
USE work.ALL;

entity KpixDataRx is 
   generic (
      CsEnable : integer := 0    -- Enable chipscope core
   ); port ( 

      -- System clock, reset
      kpixClk       : in    std_logic;                       -- 20Mhz system clock
      kpixRst       : in    std_logic;                       -- System reset

      -- FIFO Interface, req/ack type interface
      fifoReq       : out   std_logic;                       -- FIFO Write Request
      fifoAck       : in    std_logic;                       -- FIFO Write Grant
      fifoWr        : out   std_logic;                       -- FIFO Write Strobe
      fifoData      : out   std_logic_vector(15 downto 0);   -- FIFO Word

      -- Parity error output
      rawData       : in    std_logic;                       -- Raw data enable
      dataError     : out   std_logic;                       -- Parity error detected

      -- KPIX Address, enable, & col count
      kpixAddr      : in    std_logic_vector(1  downto 0);   -- Kpix address
      kpixColCnt    : in    std_logic_vector(4  downto 0);   -- Kpix column count
      kpixEnable    : in    std_logic;                       -- Kpix Enable

      -- Readout state
      inReadout     : out   std_logic;                       -- Readout active

      -- Incoming serial data
      rspData       : in    std_logic                        -- Incoming serial data
   );
end KpixDataRx;


-- Define architecture
architecture KpixDataRx of KpixDataRx is

   component icon_single PORT (
      CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
   end component;

   component ila_32d_8t_512 PORT (
      CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
      CLK : IN STD_LOGIC;
      DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));
   end component;

   -- Chipscope attributes
   attribute syn_black_box : boolean;
   attribute syn_noprune   : boolean;
   attribute syn_black_box of icon_single    : component is TRUE;
   attribute syn_noprune   of icon_single    : component is TRUE;
   attribute syn_black_box of ila_32d_8t_512 : component is TRUE;
   attribute syn_noprune   of ila_32d_8t_512 : component is TRUE;

   -- Data buffer
   component dpram_sync_1kx14 port (
      clka  : IN  std_logic;
      dina  : IN  std_logic_VECTOR(13 downto 0);
      addra : IN  std_logic_VECTOR(9 downto 0);
      wea   : IN  std_logic_VECTOR(0 downto 0);
      clkb  : IN  std_logic;
      addrb : IN  std_logic_VECTOR(9 downto 0);
      doutb : OUT std_logic_VECTOR(13 downto 0));
   end component;

   -- Local signals
   signal intData        : std_logic;
   signal serData        : std_logic_vector(21 downto 0);
   signal rxBitCntRst    : std_logic;
   signal rxBitCnt       : std_logic_vector(8  downto 0);
   signal rxColCntRst    : std_logic;
   signal rxColCntEn     : std_logic;
   signal rxColCnt       : std_logic_vector(4  downto 0);
   signal nxtRxRow       : std_logic_vector(4  downto 0);
   signal curRxRow       : std_logic_vector(4  downto 0);
   signal nxtRxWord      : std_logic_vector(3  downto 0);
   signal curRxWord      : std_logic_vector(3  downto 0);
   signal nxtMemWrEn     : std_logic;
   signal curMemWrEn     : std_logic;
   signal nxtMemWrAddr   : std_logic_vector(8  downto 0);
   signal curMemWrAddr   : std_logic_vector(8  downto 0);
   signal nxtMemWrData   : std_logic_vector(13 downto 0);
   signal curMemWrData   : std_logic_vector(13 downto 0);
   signal nxtWriteErr    : std_logic;
   signal curWriteErr    : std_logic;
   signal memWrSel       : std_logic;
   signal memWrReady     : std_logic;
   signal memRdSel       : std_logic;
   signal memRdReady     : std_logic;
   signal memWrDone      : std_logic;
   signal memRdDone      : std_logic;
   signal memRdAddr      : std_logic_vector(8  downto 0);
   signal memRdData      : std_logic_vector(13 downto 0);
   signal memCount       : std_logic_vector(1  downto 0);
   signal headParErr     : std_logic;
   signal dataParErr     : std_logic;
   signal nxtReadout     : std_logic;
   signal curReadout     : std_logic;
   signal rowRdEn        : std_logic;
   signal txRow          : std_logic_vector(4 downto 0);
   signal txColCnt       : std_logic_vector(4 downto 0);
   signal txColCntRst    : std_logic;
   signal txColCntEn     : std_logic;
   signal txBuckCntRst   : std_logic;
   signal txBuckCntEn    : std_logic;
   signal txBuckCnt      : std_logic_vector(1 downto 0);
   signal nxtTxReq       : std_logic;
   signal curTxReq       : std_logic;
   signal nxtTxWr        : std_logic;
   signal curTxWr        : std_logic;
   signal nxtTxData      : std_logic_vector(15 downto 0);
   signal curTxData      : std_logic_vector(15 downto 0);
   signal nxtReadErr     : std_logic;
   signal curReadErr     : std_logic;
   signal bucketRdEn     : std_logic;
   signal txWordSel      : std_logic_vector(1  downto 0);
   signal bucketEnDecErr : std_logic;
   signal bucketEnDec    : std_logic_vector(3  downto 0);
   signal txRange        : std_logic_vector(3  downto 0);
   signal txTrig         : std_logic_vector(3  downto 0);
   signal dataDecode     : std_logic_vector(12 downto 0);
   signal txWord         : std_logic_vector(3  downto 0);
   signal txWordCase     : std_logic_vector(3  downto 0);
   signal csControl      : STD_LOGIC_VECTOR(35 DOWNTO 0);
   signal csData         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   signal csTrig         : STD_LOGIC_VECTOR(7  DOWNTO 0);

   -- State machine, receiver
   constant RX_IDLE    : std_logic_vector(2 downto 0) := "001";
   constant RX_HEAD    : std_logic_vector(2 downto 0) := "010";
   constant RX_ROW     : std_logic_vector(2 downto 0) := "011";
   constant RX_DATA    : std_logic_vector(2 downto 0) := "100";
   constant RX_DONE    : std_logic_vector(2 downto 0) := "101";
   constant RX_DUMP    : std_logic_vector(2 downto 0) := "110";
   constant RX_RESP    : std_logic_vector(2 downto 0) := "111";
   signal   curRxState : std_logic_vector(2 downto 0);
   signal   nxtRxState : std_logic_vector(2 downto 0);

   -- State machine, transmitter
   constant TX_IDLE    : std_logic_vector(2 downto 0) := "001";
   constant TX_REQ     : std_logic_vector(2 downto 0) := "010";
   constant TX_NXT     : std_logic_vector(2 downto 0) := "011";
   constant TX_CNT     : std_logic_vector(2 downto 0) := "100";
   constant TX_W0      : std_logic_vector(2 downto 0) := "101";
   constant TX_W1      : std_logic_vector(2 downto 0) := "110";
   constant TX_W2      : std_logic_vector(2 downto 0) := "111";
   signal   curTxState : std_logic_vector(2 downto 0);
   signal   nxtTxState : std_logic_vector(2 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Read error flag
   dataError <= curReadErr or curWriteErr;

   -- Readout active flag
   inReadout <= curReadout;

   -- FIFO flags
   fifoReq  <= curTxReq;
   fifoWr   <= curTxWr;
   fifoData <= curTxData;


   -- Receive data, input pad FF
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         intData <= '0' after tpd;
      elsif rising_edge(kpixClk) then
         intData <= rspData after tpd;
      end if;
   end process;


   -- Serial data receiver
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         serData <= (others=>'0') after tpd;
      elsif rising_edge(kpixClk) then
         serData <= (intData and kpixEnable) & serData(21 downto 1) after tpd;
      end if;
   end process;


   -- Sync state machine logic
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         curRxState   <= RX_IDLE after tpd;
         rxBitCnt     <= (others=>'0') after tpd;
         rxColCnt     <= (others=>'0') after tpd;
         curRxRow     <= (others=>'0') after tpd;
         curRxWord    <= (others=>'0') after tpd;
         curMemWrEn   <= '0'           after tpd;
         curMemWrAddr <= (others=>'0') after tpd;
         curMemWrData <= (others=>'0') after tpd;
         curWriteErr  <= '0'           after tpd;
      elsif rising_edge(kpixClk) then

         -- State transition
         curRxState <= nxtRxState after tpd;

         -- Tracking values
         curRxRow  <= nxtRxRow  after tpd;
         curRxWord <= nxtRxWord after tpd;

         -- Bit tracking counter
         if rxBitCntRst = '1' then
            rxBitCnt <= (others=>'0') after tpd;
         else 
            rxBitCnt <= rxBitCnt + 1 after tpd;
         end if;

         -- Col tracking counter
         if rxColCntRst = '1' then
            rxColCnt <= (others=>'0') after tpd;
         elsif rxColCntEn = '1' then
            rxColCnt <= rxColCnt + 1 after tpd;
         end if;

         -- DPRAM Write Data
         curMemWrEn   <= nxtMemWrEn   after tpd;
         curMemWrData <= nxtMemWrData after tpd;
         curMemWrAddr <= nxtMemWrAddr after tpd;

         -- Error flag
         curWriteErr <= nxtWriteErr after tpd;
      end if;
   end process;


   -- Async state machine
   process ( curRxState, intData, rxBitCnt, serData, 
             headParErr, memWrReady, rxColCnt, curRxRow, curRxWord ) begin
      case curRxState is 

         -- Waiting for data
         when RX_IDLE =>
            rxBitCntRst  <= '1';
            rxColCntRst  <= '1';
            rxColCntEn   <= '0';
            nxtRxRow     <= (others=>'0');
            nxtRxWord    <= (others=>'0');
            nxtMemWrEn   <= '0';
            nxtMemWrAddr <= (others=>'0');
            nxtMemWrData <= (others=>'0');
            memWrDone    <= '0';
            nxtWriteErr  <= '0';

            -- Start bit detected
            if intData = '1' then
               nxtRxState <= RX_HEAD;
            else
               nxtRxState <= curRxState;
            end if;


         -- Shifting in head data
         when RX_HEAD =>
            rxColCntRst  <= '1';
            rxColCntEn   <= '0';
            nxtMemWrEn   <= '0';
            nxtMemWrAddr <= (others=>'0');
            nxtMemWrData <= (others=>'0');
            memWrDone    <= '0';

            -- Header data shift is done
            if rxBitCnt = 15 then

               -- Marker is in error
               if serData(10 downto 7) /= "1010" then
                  nxtRxState   <= RX_DUMP;
                  rxBitCntRst  <= '0';
                  nxtWriteErr  <= '0';
                  nxtRxRow     <= (others=>'0');
                  nxtRxWord    <= (others=>'0');

               -- Header is a command response type
               elsif serData(11) = '0' then
                  nxtRxState   <= RX_RESP;
                  rxBitCntRst  <= '0';
                  nxtRxRow     <= (others=>'0');
                  nxtRxWord    <= (others=>'0');
                  nxtWriteErr  <= '0';

               -- Header parity error
               elsif headParErr = '1' then
                  nxtRxState   <= RX_DUMP;
                  rxBitCntRst  <= '0';
                  nxtWriteErr  <= '1';
                  nxtRxRow     <= (others=>'0');
                  nxtRxWord    <= (others=>'0');

               -- Avoid memory overflows
               elsif memWrReady = '0' then
                  nxtRxState   <= RX_DUMP;
                  rxBitCntRst  <= '0';
                  nxtWriteErr  <= '1';
                  nxtRxRow     <= (others=>'0');
                  nxtRxWord    <= (others=>'0');

               -- Store header information
               else
                  nxtRxRow    <= serData(16 downto 12);
                  nxtRxWord   <= serData(20 downto 17);
                  nxtRxState  <= RX_ROW;
                  rxBitCntRst <= '1';
                  nxtWriteErr <= '0';
               end if;
            else
               nxtRxState   <= curRxState;
               rxBitCntRst  <= '0';
               nxtRxRow     <= (others=>'0');
               nxtRxWord    <= (others=>'0');
               nxtWriteErr  <= '0';
            end if;


         -- Write row address for column
         when RX_ROW =>
            rxColCntRst  <= '0';
            rxColCntEn   <= '0';
            nxtMemWrEn   <= '1';
            nxtMemWrAddr <= rxColCnt & "1111";
            nxtMemWrData <= "111111111" & curRxRow;
            nxtRxState   <= RX_DATA;
            rxBitCntRst  <= '0';
            nxtRxRow     <= curRxRow;
            nxtRxWord    <= curRxWord;
            memWrDone    <= '0';
            nxtWriteErr  <= '0';


         -- Write data for column
         when RX_DATA =>
            nxtMemWrAddr <= rxColCnt & curRxWord;
            nxtMemWrData <= serData(21 downto 8);
            nxtRxRow     <= curRxRow;
            nxtRxWord    <= curRxWord;
            memWrDone    <= '0';
            nxtWriteErr  <= '0';

            -- Last bit of column data
            if rxBitCnt = 13 then
               nxtMemWrEn  <= '1';
               rxBitCntRst <= '1';

               -- All columns received
               if rxColCnt = 31 then
                  rxColCntRst <= '1';
                  rxColCntEn  <= '0';
                  nxtRxState  <= RX_DONE;
               else
                  rxColCntRst <= '0';
                  rxColCntEn  <= '1';
                  nxtRxState  <= RX_ROW;
               end if;
            else
               nxtMemWrEn  <= '0';
               rxBitCntRst <= '0';
               rxColCntRst <= '0';
               rxColCntEn  <= '0';
               nxtRxState  <= curRxState;
            end if;


         -- Receive is done
         when RX_DONE =>
            rxColCntRst  <= '1';
            rxColCntEn   <= '0';
            nxtMemWrEn   <= '0';
            nxtMemWrAddr <= (others=>'0');
            nxtMemWrData <= (others=>'0');
            rxBitCntRst  <= '0';
            nxtRxRow     <= (others=>'0');
            nxtRxWord    <= (others=>'0');
            nxtWriteErr  <= '0';
            nxtRxState   <= RX_IDLE;

            -- Mark memory as done when last frame for the row received
            if curRxWord = 8 then
               memWrDone <= '1';
            else
               memWrDone <= '0';
            end if;


         -- Dump a data frame
         when RX_DUMP =>
            rxColCntRst  <= '1';
            rxColCntEn   <= '0';
            nxtMemWrEn   <= '0';
            nxtMemWrAddr <= (others=>'0');
            nxtMemWrData <= (others=>'0');
            nxtRxRow     <= (others=>'0');
            nxtRxWord    <= (others=>'0');
            memWrDone    <= '0';
            nxtWriteErr  <= '0';

            -- Dump data
            if rxBitCnt = 475 then
               rxBitCntRst <= '1';
               nxtRxState  <= RX_IDLE;
            else
               rxBitCntRst <= '0';
               nxtRxState  <= curRxState;
            end if;


         -- Dump a response frame
         when RX_RESP =>
            rxColCntRst  <= '1';
            rxColCntEn   <= '0';
            nxtMemWrEn   <= '0';
            nxtMemWrAddr <= (others=>'0');
            nxtMemWrData <= (others=>'0');
            nxtRxRow     <= (others=>'0');
            nxtRxWord    <= (others=>'0');
            memWrDone    <= '0';
            nxtWriteErr  <= '0';

            -- Dump response
            if rxBitCnt = 59 then
               rxBitCntRst <= '1';
               nxtRxState  <= RX_IDLE;
            else
               rxBitCntRst <= '0';
               nxtRxState  <= curRxState;
            end if;


         when others =>
            rxColCntRst  <= '0';
            rxColCntEn   <= '0';
            nxtMemWrEn   <= '0';
            nxtMemWrAddr <= (others=>'0');
            nxtMemWrData <= (others=>'0');
            nxtRxState   <= RX_IDLE;
            rxBitCntRst  <= '0';
            nxtRxRow     <= (others=>'0');
            nxtRxWord    <= (others=>'0');
            memWrDone    <= '0';
            nxtWriteErr  <= '0';
      end case;
   end process;


   -- Data buffer
   U_DataMem: dpram_sync_1kx14 port map (
      clka              => kpixClk,
      dina              => curMemWrData,
      addra(9)          => memWrSel,
      addra(8 downto 0) => curMemWrAddr,
      wea(0)            => curMemWrEn,
      clkb              => kpixClk,
      addrb(9)          => memRdSel,
      addrb(8 downto 0) => memRdAddr,
      doutb             => memRdData
   );


   -- Ensure there are never any address collisions
   memRdSel <= not memWrSel;


   -- Memory control logic
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         memWrSel     <= '0'  after tpd;
         memWrReady   <= '0'  after tpd;
         memRdReady   <= '0'  after tpd;
         memCount     <= "00" after tpd;
      elsif rising_edge(kpixClk) then

         -- Contents counter
         if memWrDone = '1' and memRdDone = '0' then
            memCount <= memCount + 1 after tpd;
         elsif memRdDone = '1' and memWrDone = '0' then
            memCount <= memCount - 1 after tpd;
         end if;

         -- Memory is ready for read whenever data is in buffer
         if memCount = 0 or memRdDone = '1' then
            memRdReady <= '0' after tpd;
         else
            memRdReady <= '1' after tpd;
         end if;

         -- Memory is ready for write whenever there is 1 or less entries in the memory
         if memCount(1) = '1' or memWrDone = '1' then
            memWrReady <= '0' after tpd;
         else
            memWrReady <= '1' after tpd;
         end if;

         -- Switch memory buffers when write is done and memory is empty or when read is
         -- done and memory had two entries or if both write and read are done at the same time
         if (memWrDone = '1' and memCount = 0) or 
            (memRdDone = '1' and memCount = 2) or
            (memWrDone = '1' and memRdDone = '1') then
            memWrSel <= not memWrSel after tpd;
         end if;
      end if;
   end process;


   -- Sync read state machine logic
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         curTxState   <= TX_IDLE       after tpd;
         curReadout   <= '0'           after tpd;
         txRow        <= (others=>'0') after tpd;
         txColCnt     <= (others=>'0') after tpd;
         txBuckCnt    <= (others=>'0') after tpd;
         curTxReq     <= '0'           after tpd;
         curTxWr      <= '0'           after tpd;
         curTxData    <= (others=>'0') after tpd;
         curReadErr   <= '0'           after tpd;
      elsif rising_edge(kpixClk) then

         -- State transition
         curTxState <= nxtTxState after tpd;

         -- Readout state
         curReadout <= nxtReadout after tpd;

         -- Parity errors
         curReadErr <= nxtReadErr after tpd;

         -- FIFO signals
         curTxReq   <= nxtTxReq   after tpd;
         curTxWr    <= nxtTxWr    after tpd;
         curTxData  <= nxtTxData  after tpd;

         -- Store row value
         if rowRdEn = '1' then
            txRow <= memRdData(4 downto 0) after tpd;
         end if;

         -- Column Counter
         if txColCntRst = '1' then
            txColCnt <= (others=>'0') after tpd;
         elsif txColCntEn = '1' then
            txColCnt <= txColCnt + 1 after tpd;
         end if;

         -- Bucket Counter
         if txBuckCntRst = '1' then
            txBuckCnt <= (others=>'0') after tpd;
         elsif txBuckCntEn = '1' then
            txBuckCnt <= txBuckCnt + 1 after tpd;
         end if;
      end if;
   end process;


   -- Async state machine
   process ( curTxState, memRdReady, curReadout, fifoAck, txColCnt, txWord, bucketEnDec, 
             rawData, txBuckCnt, kpixAddr, txColCnt, txRow, dataDecode, txRange, dataParErr,
             txTrig, kpixColCnt, bucketEnDecErr ) begin
      case curTxState is 

         -- IDLE Wait For Start
         when TX_IDLE =>
            nxtTxWr       <= '0';
            nxtTxData     <= (others=>'0');
            txColCntRst   <= '1';
            txColCntEn    <= '0';
            txBuckCntRst  <= '1';
            txBuckCntEn   <= '0';
            memRdAddr     <= "000001111"; -- Row Value
            bucketRdEn    <= '0';
            rowRdEn       <= '0';
            txWordSel     <= "00";
            memRdDone     <= '0';
            nxtReadErr    <= '0';

            -- Frame is ready, request FIFO, mark readout as active
            if memRdReady = '1' then
               nxtReadout <= '1';
               nxtTxState <= TX_REQ;
               nxtTxReq   <= '1';
            else
               nxtReadout <= curReadout;
               nxtTxState <= curTxState;
               nxtTxReq   <= '0';
            end if;


         -- FIFO is being requested, read row information.
         when TX_REQ =>
            nxtTxWr       <= '0';
            nxtTxData     <= (others=>'0');
            txColCntRst   <= '1';
            txColCntEn    <= '0';
            txBuckCntRst  <= '1';
            txBuckCntEn   <= '0';
            nxtTxReq      <= '1';
            nxtReadout    <= curReadout;
            bucketRdEn    <= '0';
            rowRdEn       <= '1';
            txWordSel     <= "00";
            memRdDone     <= '0';
            nxtReadErr    <= '0';
            memRdAddr     <= "000001111"; -- Row Value

            -- We have grant
            if fifoAck = '1' then
               nxtTxState <= TX_NXT;
            else
               nxtTxState <= curTxState;
            end if;


         -- Present address to memory for next pixel to read
         when TX_NXT =>
            nxtTxWr       <= '0';
            nxtTxData     <= (others=>'0');
            txColCntRst   <= '0';
            txColCntEn    <= '0';
            txBuckCntRst  <= '1';
            txBuckCntEn   <= '0';
            nxtTxReq      <= '1';
            nxtReadout    <= curReadout;
            bucketRdEn    <= '0';
            rowRdEn       <= '0';
            txWordSel     <= "00";
            memRdAddr     <= txColCnt & "0000";
            memRdDone     <= '0';
            nxtReadErr    <= '0';
            nxtTxState    <= TX_CNT;


         -- Reading count value
         when TX_CNT =>
            nxtTxWr       <= '0';
            nxtTxData     <= (others=>'0');
            txColCntRst   <= '0';
            txColCntEn    <= '0';
            txBuckCntRst  <= '1';
            txBuckCntEn   <= '0';
            nxtTxReq      <= '1';
            nxtReadout    <= curReadout;
            bucketRdEn    <= '1';
            rowRdEn       <= '0';
            txWordSel     <= "00";
            memRdAddr     <= txColCnt & "0000";
            nxtTxState    <= TX_W0;
            memRdDone     <= '0';
            nxtReadErr    <= dataParErr;


         -- Write sample word 0 to FIFO
         when TX_W0 =>
            txColCntRst   <= '0';
            txColCntEn    <= '0';
            txBuckCntRst  <= '0';
            txBuckCntEn   <= '0';
            nxtTxReq      <= '1';
            nxtReadout    <= curReadout;
            bucketRdEn    <= '0';
            rowRdEn       <= '0';
            txWordSel     <= "00";
            memRdAddr     <= txColCnt & txWord;
            nxtTxState    <= TX_W1;
            memRdDone     <= '0';
            nxtReadErr    <= '0';

            -- Write sample data to FIFO, Word 0
            nxtTxWr                 <= bucketEnDec(conv_integer(txBuckCnt)) or rawData;
            nxtTxData(15)           <= '0';
            nxtTxData(14)           <= '1';
            nxtTxData(13 downto 12) <= txBuckCnt;
            nxtTxData(11 downto 10) <= kpixAddr;
            nxtTxData(9  downto  5) <= txColCnt;
            nxtTxData(4  downto  0) <= txRow xor "11111"; -- Convert row serial to row address

         -- Write sample word 1 to FIFO
         when TX_W1 =>
            txColCntRst   <= '0';
            txColCntEn    <= '0';
            txBuckCntRst  <= '0';
            txBuckCntEn   <= '0';
            nxtTxReq      <= '1';
            nxtReadout    <= curReadout;
            bucketRdEn    <= '0';
            rowRdEn       <= '0';
            txWordSel     <= "01";
            memRdAddr     <= txColCnt & txWord;
            nxtTxState    <= TX_W2;
            memRdDone     <= '0';
            nxtReadErr    <= dataParErr;

            -- Write sample data to FIFO, Word 1
            nxtTxWr                 <= bucketEnDec(conv_integer(txBuckCnt)) or rawData;
            nxtTxData(15)           <= '0'; -- Special Flag
            nxtTxData(14)           <= dataDecode(12);
            nxtTxData(13)           <= txRange(conv_integer(txBuckCnt));
            nxtTxData(12)           <= not bucketEnDec(conv_integer(txBuckCnt));
            nxtTxData(11 downto  0) <= dataDecode(11 downto 0);


         -- Write sample word 2 to FIFO
         when TX_W2 =>
            txColCntRst   <= '0';
            bucketRdEn    <= '0';
            rowRdEn       <= '0';
            txWordSel     <= "10";
            memRdAddr     <= txColCnt & txWord;
            nxtReadErr    <= dataParErr;

            -- Write sample data to FIFO, Word 2
            nxtTxWr                 <= bucketEnDec(conv_integer(txBuckCnt)) or rawData;
            nxtTxData(15)           <= '0'; -- Future Flag
            nxtTxData(14)           <= txTrig(conv_integer(txBuckCnt));
            nxtTxData(13)           <= bucketEnDecErr;
            nxtTxData(12 downto  0) <= dataDecode;

            -- Last bucket has been processed
            if txBuckCnt = 3 then
               txBuckCntRst  <= '1';
               txBuckCntEn   <= '0';

               -- Last column is done
               if txColCnt = kpixColCnt then
                  txColCntEn <= '0';
                  nxtTxState <= TX_IDLE;
                  nxtTxReq   <= '0';
                  memRdDone  <= '1';

                  -- Last row was read, mark readout done
                  if txRow = 31 then
                     nxtReadout <= '0';
                  else
                     nxtReadout <= curReadout;
                  end if;
               else
                  nxtReadout <= curReadout;
                  txColCntEn <= '1';
                  nxtTxState <= TX_NXT;
                  nxtTxReq   <= '1';
                  memRdDone  <= '0';
               end if;
            else
               txBuckCntRst  <= '0';
               txBuckCntEn   <= '1';
               nxtReadout    <= curReadout;
               txColCntEn    <= '0';
               nxtTxState    <= TX_W0;
               nxtTxReq      <= '1';
               memRdDone     <= '0';
            end if;


         -- Default
         when others =>
            nxtTxWr       <= '0';
            nxtTxData     <= (others=>'0');
            txColCntRst   <= '0';
            txColCntEn    <= '0';
            txBuckCntRst  <= '0';
            txBuckCntEn   <= '0';
            nxtTxReq      <= '0';
            nxtReadout    <= '0';
            bucketRdEn    <= '0';
            rowRdEn       <= '0';
            txWordSel     <= "00";
            memRdAddr     <= (others=>'0');
            memRdDone     <= '0';
            nxtReadErr    <= '0';
            nxtTxState    <= TX_IDLE;
      end case;
   end process;


   -- Logic to convert event count value to bucket en
   process (kpixClk, kpixRst ) begin
      if kpixRst = '1' then
         bucketEnDecErr <= '0'           after tpd; 
         bucketEnDec    <= (others=>'0') after tpd;
         txRange        <= (others=>'0') after tpd;
         txTrig         <= (others=>'0') after tpd;
      elsif rising_edge(kpixClk) then
         if bucketRdEn = '1' then
            case memRdData(6 downto 4) is
               when "111"  => bucketEnDecErr <= '0' after tpd; bucketEnDec <= "0000" after tpd;
               when "110"  => bucketEnDecErr <= '0' after tpd; bucketEnDec <= "0001" after tpd;
               when "100"  => bucketEnDecErr <= '0' after tpd; bucketEnDec <= "0011" after tpd;
               when "101"  => bucketEnDecErr <= '0' after tpd; bucketEnDec <= "0111" after tpd;
               when "011"  => bucketEnDecErr <= '0' after tpd; bucketEnDec <= "1111" after tpd;
               when others => bucketEnDecErr <= '1' after tpd; bucketEnDec <= "0000" after tpd;
            end case;
            txRange <= memRdData(3 downto 0)  after tpd;
            txTrig  <= memRdData(10 downto 7) after tpd;
         end if;
      end if;
   end process;


   -- Convert time & ADC data
   process ( memRdData, dataDecode ) begin
      dataDecode(12) <= memRdData(12);
      dataDecode(11) <= memRdData(11) xor dataDecode(12);
      dataDecode(10) <= memRdData(10) xor dataDecode(11);
      dataDecode(9)  <= memRdData(9)  xor dataDecode(10);
      dataDecode(8)  <= memRdData(8)  xor dataDecode(9);
      dataDecode(7)  <= memRdData(7)  xor dataDecode(8);
      dataDecode(6)  <= memRdData(6)  xor dataDecode(7);
      dataDecode(5)  <= memRdData(5)  xor dataDecode(6);
      dataDecode(4)  <= memRdData(4)  xor dataDecode(5);
      dataDecode(3)  <= memRdData(3)  xor dataDecode(4);
      dataDecode(2)  <= memRdData(2)  xor dataDecode(3);
      dataDecode(1)  <= memRdData(1)  xor dataDecode(2);
      dataDecode(0)  <= memRdData(0)  xor dataDecode(1);
   end process;


   -- Vector for lookup
   txWordCase <= txBuckCnt & txWordSel;

   -- Decode word count from bucket count and current state
   process ( txWordCase ) begin
      case txWordCase is
         when "0000" => txWord <= "0001"; -- St=W0,  Buck=0
         when "0001" => txWord <= "0010"; -- St=W1,  Buck=0
         when "0010" => txWord <= "0010"; -- St=W2,  Buck=0
         when "0011" => txWord <= "0010"; -- ST=NA,  Buck=0
         when "0100" => txWord <= "0011"; -- St=W0,  Buck=1
         when "0101" => txWord <= "0100"; -- St=W1,  Buck=1
         when "0110" => txWord <= "0100"; -- St=W2,  Buck=1
         when "0111" => txWord <= "0100"; -- ST=NA,  Buck=1
         when "1000" => txWord <= "0101"; -- St=W0,  Buck=2
         when "1001" => txWord <= "0110"; -- St=W1,  Buck=2
         when "1010" => txWord <= "0110"; -- St=W2,  Buck=2
         when "1011" => txWord <= "0110"; -- ST=NA,  Buck=2
         when "1100" => txWord <= "0111"; -- St=W0,  Buck=3
         when "1101" => txWord <= "1000"; -- St=W1,  Buck=3
         when "1110" => txWord <= "0000"; -- St=W2,  Buck=3
         when "1111" => txWord <= "0000"; -- ST=NA,  Buck=3
         when others => txWord <= "0000";
      end case;
   end process;


   -- Header parity calculation
   headParErr <= serData(7)  xor serData(8)  xor serData(9)  xor serData(10) xor 
                 serData(11) xor serData(12) xor serData(13) xor serData(14) xor 
                 serData(15) xor serData(16) xor serData(17) xor serData(18) xor 
                 serData(19) xor serData(20) xor serData(21);


   -- Data parity error
   dataParErr <= memRdData(0)  xor memRdData(1)  xor memRdData(2)  xor memRdData(3)  xor 
                 memRdData(4)  xor memRdData(5)  xor memRdData(6)  xor memRdData(7)  xor 
                 memRdData(8)  xor memRdData(9)  xor memRdData(10) xor memRdData(11) xor 
                 memRdData(12) xor memRdData(13);


   -- Debug
   CsGen: if CsEnable = 1 generate
      U_Icon : icon_single port map (
         CONTROL0 => csControl
      );

      U_Ila : ila_32d_8t_512 port map (
         CONTROL => csControl,
         CLK     => kpixClk,
         DATA    => csData,
         TRIG0   => csTrig
      );
   end generate;

   csTrig(7  downto 0) <= csData(7 downto 0);

   csData(31 downto 29) <= rxColCnt(2 downto 0);
   csData(28 downto 24) <= curRxRow;
   csData(23 downto 19) <= txRow;
   csData(18 downto 14) <= txColCnt;
   csData(13 downto 11) <= curTxState;
   csData(10 downto  8) <= curRxState;
   csData(7)            <= curWriteErr;
   csData(6)            <= fifoAck;
   csData(5)            <= curTxWr;
   csData(4)            <= curTxReq;
   csData(3 downto 2)   <= memCount;
   csData(1)            <= memRdDone;
   csData(0)            <= memWrDone;

end KpixDataRx;

