-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA SRAM Data processor
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixDdrData.vhd
-- Author        : Ryan Herbst, ausoori@slac.stanford.edu
-- Created       : 4/19/2011
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the sram data processor.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 4/19/2011: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.KpixConPkg.all;

entity KpixDdrDataRx is 
   port (
      -- ddr clock, reset
      sysClk            : in  std_logic;                      -- 125Mhz system clock
      sysRst            : in  std_logic;                      -- system reset

      -- Train Data Interface, req/ack type interface
      trainReq          : in  std_logic;                      -- train Write Request
      trainAck          : out std_logic;                      -- train Write Grant
      trainSOF          : in  std_logic;                      -- train Word SOF
      trainEOF          : in  std_logic;                      -- train Word EOF
      trainPad          : in  std_logic;                      -- train Word Padding
      trainWr           : in  std_logic;                      -- train Write Strobe
      trainData         : in  std_logic_vector(31 downto 0);  -- train Word

      -- Write signals
      memWr             : out std_logic;
      memWrEn           : in  std_logic;
      memWrAddr         : out std_logic_vector(18 downto 0);
      memWrData         : out std_logic_vector(31 downto 0);
      memWrSOF          : out std_logic;
      memWrEOF          : out std_logic;
      memWrPad          : out std_logic;

      -- Read signals
      memRd             : out std_logic;
      memRdEn           : in  std_logic;
      memRdAddr         : out std_logic_vector(18 downto 0);
      memRdLast         : out std_logic;

      -- Debug
      sysDebug          : out std_logic_vector(63 downto 0)
   );
end KpixDdrDataRx;


-- Define architecture
architecture KpixDdrDataRx of KpixDdrDataRx is

   -- Local Signals
   signal wrCounter    : std_logic_vector(18 downto 0);
   signal rdCounter    : std_logic_vector(18 downto 0);
   signal frFifoWr     : std_logic;
   signal frFifoRd     : std_logic;
   signal frFifoValid  : std_logic;
   signal frFifoEmpty  : std_logic;
   signal frFifoDin    : std_logic_vector(34 downto 0);
   signal frFifoDout   : std_logic_vector(34 downto 0);
   signal intRd        : std_logic;
   signal intWr        : std_logic;
   signal intRdAddr    : std_logic_vector(18 downto 0);
   signal intWrAddr    : std_logic_vector(18 downto 0);
   signal intCounter   : std_logic_vector(18 downto 0);
   signal intAFull     : std_logic;
   signal regSOF       : std_logic;
   signal regEOF       : std_logic;
   signal regPad       : std_logic;
   signal regValid     : std_logic;
   signal regData      : std_logic_vector(31 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Debug
   sysDebug (63)            <= trainReq;
   sysDebug (62)            <= memRdEn;
   sysDebug (61)            <= memWrEn;
   sysDebug (60)            <= frFifoValid;
   sysDebug (59)            <= frFifoEmpty;
   sysDebug (58)            <= frFifoWr;
   sysDebug (57)            <= intRd;
   sysDebug (56 downto 38)  <= wrCounter;
   sysDebug (36)            <= regValid;
   sysDebug (35)            <= trainWr;
   sysDebug (34)            <= trainPad;
   sysDebug (33)            <= trainEOF;
   sysDebug (32)            <= trainSOF;
   sysDebug (31 downto  0)  <= trainData;

   ----------------------------------
   -- Write Controller
   ----------------------------------
   trainAck <= trainReq and memWrEn;

   -- Track write data
   process ( sysClk, sysRst ) begin
      if sysRst = '1' then
         wrCounter <= (others=>'0') after tpd;
         intWr     <= '1'           after tpd;
         regData   <= (others=>'0') after tpd;
         regSOF    <= '0'           after tpd;
         regEOF    <= '0'           after tpd;
         regPad    <= '0'           after tpd;
         regValid  <= '0'           after tpd;
      elsif rising_edge(sysClk) then

         -- Counter
         if trainWr = '1' then
            wrCounter <= wrCounter + 1 after tpd;
         elsif trainEOF = '1' then
            wrCounter <= (others=>'0') after tpd;
         end if;
         
         -- Registered Train Data
         if trainWr = '1' then
            regData  <= trainData after tpd;
            regSOF   <= trainSOF  after tpd;
            regEOF   <= trainEOF  after tpd;
            regPad   <= trainPad  after tpd;
            regValid <= '1'       after tpd;
         elsif memWrEn = '1' then
            regValid <= '0'       after tpd;
         end if;
         
         -- Latch counter value
         intWr <= not trainEOF after tpd;

      end if;
   end process;

   -- Output Data
   memWrData <= regData;
   memWrSOF  <= regSOF;
   memWrEOF  <= regEOF;
   memWrPad  <= regPad;
   memWr     <= regValid and memWrEn;
   memWrAddr <= intWrAddr;
   
   ----------------------------------
   -- Read Controller
   ----------------------------------

   -- Post frame
   frFifoWr                <= intWr and trainEOF;
   frFifoDin(34 downto 19) <= (others=>'0');
   frFifoDin(18 downto  0) <= wrCounter;

   -- FIFO for pending reads
   U_FrFifo : afifo_35x512 port map (
      rd_clk  => sysClk,
      wr_clk  => sysClk,
      rst     => sysRst,
      din     => frFifoDin,
      wr_en   => frFifoWr,
      rd_en   => frFifoRd,
      dout    => frFifoDout,
      full    => open,
      empty   => frFifoEmpty
   );

   -- Control reads
   frFifoRd <= (not frFifoEmpty) and (not frFifoValid);

   -- Read control
   process ( sysClk, sysRst ) begin
      if sysRst = '1' then
         frFifoValid <= '0'           after tpd;
         rdCounter   <= (others=>'0') after tpd;
         intRd       <= '0'           after tpd;
         memRdLast   <= '0'           after tpd;
      elsif rising_edge(sysClk) then

         -- FIFO entry valid
         if frFifoRd = '1' then
            frFifoValid <= '1' after tpd;
         elsif intRd = '0' then
            frFifoValid <= '0' after tpd;
         end if;

         -- Read is starting
         if intRd = '0' and frFifoValid = '1' then
            rdCounter  <= frFifoDout(18 downto 0) after tpd;
            intRd      <= '1'                     after tpd;
            memRdLast  <= '0'                     after tpd;

         -- Read is active
         elsif intRd = '1' and memRdEn = '1' then

            -- Read is done
            if rdCounter = 0 then
               intRd <= '0' after tpd;
            else
               rdCounter <= rdCounter - 1 after tpd;
            end if;

            -- Next word is last
            if rdCounter = 1 then
               memRdLast <= '1' after tpd;
            end if;
         end if;
      end if;
   end process;


   ----------------------------------
   -- FIFO Counter & Address Tracker
   ----------------------------------
   process ( sysClk, sysRst ) begin
      if sysRst = '1' then
         intCounter <= (others=>'0') after tpd;
         intAFull   <= '0'           after tpd;
         intWrAddr  <= (others=>'0') after tpd;
         intRdAddr  <= (others=>'0') after tpd;
      elsif rising_edge(sysClk) then

         -- Counter
         if trainWr = '1' and memWrEn = '1' then
            intCounter <= intCounter + 1 after tpd;
         elsif intRd = '1' and memRdEn = '1' then
            intCounter <= intCounter - 1 after tpd;
         end if;

         -- Almost full
         if intCounter > 524000 then
            intAFull <= '1' after tpd;
         else
            intAFull <= '0' after tpd;
         end if;

         -- Write address
         if regValid = '1' and memWrEn = '1' then
            intWrAddr <= intWrAddr + 1 after tpd;
         end if;

         -- Read address
         if intRd = '1' and memRdEn = '1' then
            intRdAddr <= intRdAddr + 1 after tpd;
         end if;
      end if;
   end process;

   -- Output addresses and read enable
   memRdAddr <= intRdAddr;
   memRd     <= intRd;

end KpixDdrDataRx;
