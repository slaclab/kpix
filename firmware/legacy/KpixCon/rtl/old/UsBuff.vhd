-------------------------------------------------------------------------------
-- Title         : Upstream Data Buffer
-- Project       : Heavy Photon Tracker
-------------------------------------------------------------------------------
-- File          : UsBuff.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 01/11/2010
-------------------------------------------------------------------------------
-- Description:
-- VHDL source file for buffer block for upstream data.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 01/11/2010: created.
-------------------------------------------------------------------------------
LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UsBuff is
   port ( 

      -- Clock and reset     
      sysClk           : in  std_logic;
      sysClkRst        : in  std_logic;

      -- Local data transfer signals
      frameTxValid     : in  std_logic;
      frameTxSOF       : in  std_logic;
      frameTxEOF       : in  std_logic;
      frameTxEOFE      : in  std_logic;
      frameTxData      : in  std_logic_vector(31 downto 0);
      frameTxAFull     : out std_logic;

      -- PGP Transmit Signals
      vcFrameTxValid   : out std_logic;
      vcFrameTxReady   : in  std_logic;
      vcFrameTxSOF     : out std_logic;
      vcFrameTxEOF     : out std_logic;
      vcFrameTxEOFE    : out std_logic;
      vcFrameTxData    : out std_logic_vector(15 downto 0);
      vcRemBuffAFull   : in  std_logic;
      vcRemBuffFull    : in  std_logic
   );
end UsBuff;


-- Define architecture
architecture UsBuff of UsBuff is

   -- V5 Async FIFO
   component fifo_36x1024_fwft port (
      clk        : IN  STD_LOGIC;
      rst        : IN  STD_LOGIC;
      din        : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);
      wr_en      : IN  STD_LOGIC;
      rd_en      : IN  STD_LOGIC;
      dout       : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
      full       : OUT STD_LOGIC;
      empty      : OUT STD_LOGIC;
      valid      : OUT STD_LOGIC;
      data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0));
   end component;

   -- Local Signals
   signal txFifoDin      : std_logic_vector(35 downto 0);
   signal txFifoDout     : std_logic_vector(35 downto 0);
   signal txFifoRd       : std_logic;
   signal txFifoCount    : std_logic_vector(10 downto 0);
   signal txFifoEmpty    : std_logic;
   signal txFifoFull     : std_logic;
   signal txFifoValid    : std_logic;
   signal txFifoSel      : std_logic;
   signal fifoErr        : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

   -- Black Box Attributes
   attribute syn_black_box : boolean;
   attribute syn_noprune   : boolean;
   attribute syn_black_box of fifo_36x1024_fwft : component is TRUE;
   attribute syn_noprune   of fifo_36x1024_fwft : component is TRUE;

begin

   -- Data going into Tx FIFO
   txFifoDin(35)           <= '0';
   txFifoDin(34)           <= frameTxEOFE or fifoErr;
   txFifoDin(33)           <= frameTxEOF;
   txFifoDin(32)           <= frameTxSOF;
   txFifoDin(31 downto  0) <= frameTxData; 

   -- Generate fifo error signal
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         fifoErr      <= '0' after tpd;
         frameTxAFull <= '0' after tpd;
      elsif rising_edge(sysClk) then

         -- Generate full error
         if txFifoCount >= 1020 or txFifoFull = '1' then
            fifoErr <= '1' after tpd;
         else
            fifoErr <= '0' after tpd;
         end if;

         -- Almost full
         if txFifoCount > 1000 or txFifoFull = '1' then
            frameTxAFull <= '1' after tpd;
         else
            frameTxAFull <= '0' after tpd;
         end if;

      end if;
   end process;

   -- V5 Receive FIFO
   U_Fifo: fifo_36x1024_fwft port map (
      clk        => sysClk,
      rst        => sysClkRst,
      din        => txFifoDin,
      wr_en      => frameTxValid,
      rd_en      => txFifoRd,
      dout       => txFifoDout,
      full       => txFifoFull,
      empty      => open,
      valid      => txFifoValid,
      data_count => txFifoCount
   );

   -- Control reads
   txFifoRd <= txFifoValid and txFifoSel and vcFrameTxReady;

   -- Data valid
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         txFifoSel   <= '0' after tpd;
      elsif rising_edge(sysClk) then
         if txFifoRd = '1' or txFifoValid = '0' then
            txFifoSel <= '0' after tpd;
         elsif vcFrameTxReady = '1' then
            txFifoSel <= not txFifoSel after tpd;
         end if;
      end if;
   end process;

   -- MUX Data
   vcFrameTxValid <= txFifoValid;
   vcFrameTxSOF   <= txFifoDout(32) when txFifoSel = '0' else '0';
   vcFrameTxEOF   <= txFifoDout(33) when txFifoSel = '1' else '0';
   vcFrameTxEOFE  <= txFifoDout(34) when txFifoSel = '1' else '0';
   vcFrameTxData  <= txFifoDout(15 downto 0) when txFifoSel = '0' else txFifoDout(31 downto 16);

end UsBuff;

