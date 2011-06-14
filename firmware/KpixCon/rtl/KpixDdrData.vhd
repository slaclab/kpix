-------------------------------------------------------------------------------
-- Title         : KPIX Test FPGA SRAM Data Interface
-- Project       : W_SI, KPIX Test Board
-------------------------------------------------------------------------------
-- File          : KpixDdrData.vhd
-- Author        : Ryan Herbst, ausoori@slac.stanford.edu
-- Created       : 4/19/2011
-------------------------------------------------------------------------------
-- Description:
-- Core VHDL source file for the sram data interface.
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
use UNISIM.VCOMPONENTS.ALL;

entity KpixDdrData is 
   port (
      -- ddr clock, reset
      ddrClk       : in    std_logic;                       -- 125Mhz ddr clock
      ddrRst       : in    std_logic;                       -- ddr reset
      ddrRdNWr     : out   std_logic;                       -- ddr R/W
      ddrLdL       : out   std_logic;                       -- ddr active low Load
      ddrData      : inout std_logic_vector(17 downto 0);   -- ddr data bus
      ddrAddr      : out   std_logic_vector(21 downto 0);   -- ddr address bus

      -- System clock, reset
      sysClk       : in    std_logic;                       -- 125Mhz system clock
      sysRst       : in    std_logic;                       -- system reset  

      -- SRAM Interface, req/ack type interface
      sramReq      : out   std_logic;                       -- sram Write Request
      sramAck      : in    std_logic;                       -- sram Write Grant
      sramSOF      : out   std_logic;                       -- sram Word SOF
      sramEOF      : out   std_logic;                       -- sram Word EOF
      sramWr       : out   std_logic;                       -- sram Write Strobe
      sramData     : out   std_logic_vector(15 downto 0);   -- sram Word

      -- Train Data Interface, req/ack type interface
      trainReq     : in    std_logic_vector(3 downto 0);    -- train Write Request
      trainAck     : out   std_logic_vector(3 downto 0);    -- train Write Grant
      trainSOF     : in    std_logic_vector(3 downto 0);    -- train Word SOF
      trainEOF     : in    std_logic_vector(3 downto 0);    -- train Word EOF
      trainPad     : in    std_logic_vector(3 downto 0);    -- train Word EOF
      trainWr      : in    std_logic_vector(3 downto 0);    -- train Write Strobe
      trainData    : in    array4x32;                       -- train Word

      -- Debug
      csControl1   : inout std_logic_vector(35 downto 0);   -- Chip Scope Control
      csControl2   : inout std_logic_vector(35 downto 0);   -- Chip Scope Control
      csEnable     : in    std_logic_vector(15 downto 0)    -- Chip scope inputs
   );
end KpixDdrData;

-- Define architecture
architecture KpixDdrData of KpixDdrData is

   -- Local signals
   signal memWrA           : std_logic;
   signal memWrAddrA       : std_logic_vector(18 downto 0);
   signal memWrDataA       : std_logic_vector(31 downto 0);
   signal memWrSOFA        : std_logic;
   signal memWrEOFA        : std_logic;
   signal memWrPadA        : std_logic;
   signal memRdA           : std_logic;
   signal memRdAddrA       : std_logic_vector(18 downto 0);
   signal memRdLastA       : std_logic;
   signal memWrB           : std_logic;
   signal memWrAddrB       : std_logic_vector(18 downto 0);
   signal memWrDataB       : std_logic_vector(31 downto 0);
   signal memWrSOFB        : std_logic;
   signal memWrEOFB        : std_logic;
   signal memWrPadB        : std_logic;
   signal memRdB           : std_logic;
   signal memRdAddrB       : std_logic_vector(18 downto 0);
   signal memRdLastB       : std_logic;
   signal memWrC           : std_logic;
   signal memWrAddrC       : std_logic_vector(18 downto 0);
   signal memWrDataC       : std_logic_vector(31 downto 0);
   signal memWrSOFC        : std_logic;
   signal memWrEOFC        : std_logic;
   signal memWrPadC        : std_logic;
   signal memRdC           : std_logic;
   signal memRdAddrC       : std_logic_vector(18 downto 0);
   signal memRdLastC       : std_logic;
   signal memWrD           : std_logic;
   signal memWrAddrD       : std_logic_vector(18 downto 0);
   signal memWrDataD       : std_logic_vector(31 downto 0);
   signal memWrSOFD        : std_logic;
   signal memWrEOFD        : std_logic;
   signal memWrPadD        : std_logic;
   signal memRdD           : std_logic;
   signal memRdAddrD       : std_logic_vector(18 downto 0);
   signal memRdLastD       : std_logic;
   signal memCycle         : std_logic_vector(5  downto 0);
   signal memRdSelA        : std_logic;
   signal memRdSelB        : std_logic;
   signal memWrEnA         : std_logic;
   signal memWrEnB         : std_logic;
   signal memRdEnA         : std_logic;
   signal memRdEnB         : std_logic;
   signal memRdSelC        : std_logic;
   signal memRdSelD        : std_logic;
   signal memWrEnC         : std_logic;
   signal memWrEnD         : std_logic;
   signal memRdEnC         : std_logic;
   signal memRdEnD         : std_logic;
   signal tmpData          : std_logic_vector(35 downto 0);
   signal tmpDenL          : std_logic;
   signal tmpRdDen         : std_logic_vector(3  downto 0);
   signal memRdDen         : std_logic;
   signal dlyRdDen         : std_logic_vector(3  downto 0);
   signal dlyRdEn          : std_logic;
   signal outDenL          : std_logic;
   signal outData          : std_logic_vector(35 downto 0);
   signal locDenL          : std_logic_vector(17 downto 0);
   signal locDout          : std_logic_vector(17 downto 0);
   signal ddrRdData        : std_logic_vector(35 downto 0);
   signal readAFull        : std_logic;
   signal readAFullDly0    : std_logic;
   signal readAFullDly1    : std_logic;
   signal intLdL           : std_logic;
   signal intRdNWr         : std_logic;
   signal intAddr          : std_logic_vector(21 downto 0);
   signal fifoDin          : std_logic_vector(35 downto 0);
   signal intData          : std_logic_vector(31 downto 0);
   signal intSOF           : std_logic;
   signal intEOF           : std_logic;
   signal intPad           : std_logic;
   signal intRd            : std_logic;
   signal intWr            : std_logic;
   signal intFull          : std_logic;
   signal intEmpty         : std_logic;
   signal intValid         : std_logic;
   signal intCnt           : std_logic_vector(8 downto 0);
   signal lsbData          : std_logic;
   signal regData          : std_logic_vector(18 downto 0);
   signal curState         : std_logic_vector(1 downto 0);
   signal nxtState         : std_logic_vector(1 downto 0);
   signal counter          : std_logic_vector(1 downto 0);
   
   -- Chip Scope signals
   constant enChipScope    : integer := 1;
   signal   ddrDebug       : std_logic_vector(63 downto 0);
   signal   debug          : std_logic_vector(63 downto 0);
   signal   sysDebug       : array4x64;
   
   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Debug
   ddrDebug (63)           <= memRdDen;
   ddrDebug (62)           <= not intEmpty;
   ddrDebug (61)           <= regData(18);
   ddrDebug (60)           <= memWrEnB and memWrB;
   ddrDebug (59)           <= memWrEnA and memWrA;
   ddrDebug (58)           <= memRdEnB and memRdB;
   ddrDebug (57)           <= memRdEnA and memRdA;
   ddrDebug (56)           <= curState(1);
   ddrDebug (55)           <= curState(0);
   ddrDebug (54 downto 36) <= intAddr(19 downto 1);
   ddrDebug (35)           <= sramAck;
   ddrDebug (34)           <= intFull;
   ddrDebug (33 downto 32) <= counter;
   ddrDebug (31 downto  0) <= intData;-- when csEnable(4) = '1' else outData;
   
  debug <= sysDebug(0) when csEnable(5) = '0' else sysDebug(1);

   chipscope : if (enChipScope = 1) generate   
--       U_ddrRdData_ila : v5_ila port map (
--          CONTROL => csControl1,
--          CLK     => sysClk,
--          TRIG0   => debug
--       );
      U_ddrWrData_ila : v5_ila port map (
         CONTROL => csControl1,
         CLK     => ddrClk,
         TRIG0   => ddrDebug
      );
   end generate chipscope;  

   ---------------------------------------------------
   -- DDR Write Data Process
   ---------------------------------------------------
   ---------------------------------------------------
   -- Memory Cycle Controller
   ---------------------------------------------------
   -- Clock cycles are divided equally between reads and writes.
   -- Write cycles are divided equally between each of the four inputs.
   -- Memory is divided equally between the four inputs.

   ddrAddr  <= intAddr;
   ddrLdL   <= intLdL;
   ddrRdNWr <= intRdNWr;

   -- Register read/write commands for external memory
   process ( sysClk, sysRst ) begin
      if sysRst = '1' then
         readAFullDly0 <= '0'           after tpd;
         readAFullDly1 <= '0'           after tpd;
         memCycle      <= (others=>'0') after tpd;
         memRdSelA     <= '0'           after tpd;
         memRdSelB     <= '0'           after tpd;
         memRdSelC     <= '0'           after tpd;
         memRdSelD     <= '0'           after tpd;
         memWrEnA      <= '0'           after tpd;
         memWrEnB      <= '0'           after tpd;
         memWrEnC      <= '0'           after tpd;
         memWrEnD      <= '0'           after tpd;
         memRdEnA      <= '0'           after tpd;
         memRdEnB      <= '0'           after tpd;
         memRdEnC      <= '0'           after tpd;
         memRdEnD      <= '0'           after tpd;
         intAddr       <= (others=>'0') after tpd;
         intLdL        <= '1'           after tpd;
         intRdNWr      <= '1'           after tpd;
         tmpData       <= (others=>'0') after tpd;
         tmpDenL       <= '0'           after tpd;
         outData       <= (others=>'0') after tpd;
         outDenL       <= '0'           after tpd;
         memRdDen      <= '0'           after tpd;
         tmpRdDen      <= (others=>'0') after tpd;
      elsif rising_edge(sysClk) then

         -- Sample almost full
         readAFullDly0 <= readAFull     after tpd;
         readAFullDly1 <= readAFullDly0 after tpd;

         -- No one is reading
         if memRdSelA = '0' and memRdSelB = '0' and memRdSelC = '0' and memRdSelD = '0' then

            if memRdA = '1' then
               memRdSelA <= '1' after tpd;
            elsif memRdB = '1' then
               memRdSelB <= '1' after tpd;
            elsif memRdC = '1' then
               memRdSelC <= '1' after tpd;
            elsif memRdD = '1' then
               memRdSelD <= '1' after tpd;
            end if;

         -- Side A read is done
         elsif memRdA = '1' and memRdEnA = '1' and memRdLastA = '1' then
            memRdSelA   <= '0' after tpd;

            if memRdB = '1' then
               memRdSelB <= '1' after tpd;
            elsif memRdC = '1' then
               memRdSelC <= '1' after tpd;
            elsif memRdD = '1' then
               memRdSelD <= '1' after tpd;
            end if;

         -- Side B read is done
         elsif memRdB = '1' and memRdEnB = '1' and memRdLastB = '1' then
            memRdSelB   <= '0' after tpd;

            if memRdC = '1' then
               memRdSelC <= '1' after tpd;
            elsif memRdD = '1' then
               memRdSelD <= '1' after tpd;
            elsif memRdA = '1' then
               memRdSelA <= '1' after tpd;
            end if;

         -- Side C read is done
         elsif memRdC = '1' and memRdEnC = '1' and memRdLastC = '1' then
            memRdSelC   <= '0' after tpd;

            if memRdD = '1' then
               memRdSelD <= '1' after tpd;
            elsif memRdA = '1' then
               memRdSelA <= '1' after tpd;
            elsif memRdB = '1' then
               memRdSelB <= '1' after tpd;
            end if;

         -- Side D read is done
         elsif memRdD = '1' and memRdEnD = '1' and memRdLastD = '1' then
            memRdSelD   <= '0' after tpd;

            -- Side A is ready
            if memRdA = '1' then
               memRdSelA <= '1' after tpd;
            elsif memRdB = '1' then
               memRdSelB <= '1' after tpd;
            elsif memRdC = '1' then
               memRdSelC <= '1' after tpd;
            end if;
         end if;
            
         -- Free running counter
            memCycle <= memCycle + 1 after tpd;

         -- 31 reads out of 64 clock cycles = 96.9% read data occupancy at pgp interface
         -- each read at 32-bits = 2 clocks at 16-bits (62/64 = .969)
         if memCycle < 31 then
            memRdEnA <= memRdSelA and (not readAFullDly1) after tpd;
            memRdEnB <= memRdSelB and (not readAFullDly1) after tpd;
            memRdEnC <= memRdSelC and (not readAFullDly1) after tpd;
            memRdEnD <= memRdSelD and (not readAFullDly1) after tpd;
            memWrEnA <= '0'                               after tpd;
            memWrEnB <= '0'                               after tpd;
            memWrEnC <= '0'                               after tpd;
            memWrEnD <= '0'                               after tpd;
         
         -- 1 idle cycle between reads and writes
         elsif memCycle = 31 then
            memRdEnA <= '0' after tpd;
            memRdEnB <= '0' after tpd;
            memRdEnC <= '0' after tpd;
            memRdEnD <= '0' after tpd;
            memWrEnA <= '0' after tpd;
            memWrEnB <= '0' after tpd;
            memWrEnC <= '0' after tpd;
            memWrEnD <= '0' after tpd;

         -- 32 write cycles, alternating between side A, B, C & D
         else
            memRdEnA <= '0'                                 after tpd;
            memRdEnB <= '0'                                 after tpd;
            memRdEnC <= '0'                                 after tpd;
            memRdEnD <= '0'                                 after tpd;
            memWrEnA <= not memCycle(1) and not memCycle(0) after tpd; --00
            memWrEnB <= not memCycle(1) and     memCycle(0) after tpd; --01
            memWrEnC <=     memCycle(1) and not memCycle(0) after tpd; --10
            memWrEnD <=     memCycle(1) and     memCycle(0) after tpd; --11
            
         end if;

         -- WriteA operation
         if memWrEnA = '1' and memWrA = '1' then
            intAddr              <= "00" & memWrAddrA & '0' after tpd;
            intLdL               <= '0'                     after tpd;
            intRdNWr             <= '0'                     after tpd;
            tmpData(35)          <= '1'                     after tpd;
            tmpData(34)          <= memWrSOFA               after tpd;
            tmpData(33)          <= memWrEOFA               after tpd;
            tmpData(32)          <= memWrPadA               after tpd;
            tmpData(31 downto 0) <= memWrDataA              after tpd;
            tmpDenL              <= '0'                     after tpd;
            tmpRdDen(0)          <= '0'                     after tpd;

         -- WriteB operation
         elsif memWrEnB = '1' and memWrB = '1' then
            intAddr              <= "01" & memWrAddrB & '0' after tpd;
            intLdL               <= '0'                     after tpd;
            intRdNWr             <= '0'                     after tpd;
            tmpData(35)          <= '1'                     after tpd;
            tmpData(34)          <= memWrSOFB               after tpd;
            tmpData(33)          <= memWrEOFB               after tpd;
            tmpData(32)          <= memWrPadB               after tpd;
            tmpData(31 downto 0) <= memWrDataB              after tpd;
            tmpDenL              <= '0'                     after tpd;
            tmpRdDen(0)          <= '0'                     after tpd;

         -- WriteC operation
         elsif memWrEnC = '1' and memWrC = '1' then
            intAddr              <= "10" & memWrAddrC & '0' after tpd;
            intLdL               <= '0'                     after tpd;
            intRdNWr             <= '0'                     after tpd;
            tmpData(35)          <= '1'                     after tpd;
            tmpData(34)          <= memWrSOFC               after tpd;
            tmpData(33)          <= memWrEOFC               after tpd;
            tmpData(32)          <= memWrPadC               after tpd;
            tmpData(31 downto 0) <= memWrDataC              after tpd;
            tmpDenL              <= '0'                     after tpd;
            tmpRdDen(0)          <= '0'                     after tpd;

         -- WriteD operation
         elsif memWrEnD = '1' and memWrD = '1' then
            intAddr              <= "11" & memWrAddrD & '0' after tpd;
            intLdL               <= '0'                     after tpd;
            intRdNWr             <= '0'                     after tpd;
            tmpData(35)          <= '1'                     after tpd;
            tmpData(34)          <= memWrSOFD               after tpd;
            tmpData(33)          <= memWrEOFD               after tpd;
            tmpData(32)          <= memWrPadD               after tpd;
            tmpData(31 downto 0) <= memWrDataD              after tpd;
            tmpDenL              <= '0'                     after tpd;
            tmpRdDen(0)          <= '0'                     after tpd;

         -- ReadA operation
         elsif memRdEnA = '1' and memRdA = '1' then
            intAddr     <= "00" & memRdAddrA & '0' after tpd;
            intLdL      <= '0'                     after tpd;
            intRdNWr    <= '1'                     after tpd;
            tmpData     <= (others=>'0')           after tpd;
            tmpDenL     <= '1'                     after tpd;
            tmpRdDen(0) <= '1'                     after tpd;

         -- ReadB operation
         elsif memRdEnB = '1' and memRdB = '1' then
            intAddr     <= "01" & memRdAddrB & '0' after tpd;
            intLdL      <= '0'                     after tpd;
            intRdNWr    <= '1'                     after tpd;
            tmpData     <= (others=>'0')           after tpd;
            tmpDenL     <= '1'                     after tpd;
            tmpRdDen(0) <= '1'                     after tpd;

         -- ReadC operation
         elsif memRdEnC = '1' and memRdC = '1' then
            intAddr     <= "10" & memRdAddrC & '0' after tpd;
            intLdL      <= '0'                     after tpd;
            intRdNWr    <= '1'                     after tpd;
            tmpData     <= (others=>'0')           after tpd;
            tmpDenL     <= '1'                     after tpd;
            tmpRdDen(0) <= '1'                     after tpd;

         -- ReadD operation
         elsif memRdEnD = '1' and memRdD = '1' then
            intAddr     <= "11" & memRdAddrD & '0' after tpd;
            intLdL      <= '0'                     after tpd;
            intRdNWr    <= '1'                     after tpd;
            tmpData     <= (others=>'0')           after tpd;
            tmpDenL     <= '1'                     after tpd;
            tmpRdDen(0) <= '1'                     after tpd;

         -- No operation
         else
            intAddr     <= (others=>'0') after tpd;
            intLdL      <= '1'           after tpd;
            intRdNWr    <= '1'           after tpd;
            tmpData     <= (others=>'0') after tpd;
            tmpDenL     <= '1'           after tpd;
            tmpRdDen(0) <= '0'           after tpd;
         end if;

         -- Output Data
         outDenL <= tmpDenL after tpd;
         outData <= tmpData after tpd;

         -- Generate read data enable signal
         tmpRdDen(1) <= tmpRdDen(0) after tpd;
         tmpRdDen(2) <= tmpRdDen(1) after tpd;
         tmpRdDen(3) <= tmpRdDen(2) after tpd;
         memRdDen    <= tmpRdDen(3) after tpd;

      end if;
   end process;

   -- Connect write data through DDR Mux on IO pads
   DDRO: for i in 17 downto 0 generate

      -- Data output pads
      U_DO: ODDR port map (
         Q  => locDout(i),
         C  => sysClk,
         CE => '1',
         D1 => outData(18+i),
         D2 => outData(i),
         R  => '0',      
         S  => '0'
      );

      -- Output enable pads
      U_EO: ODDR port map (
         Q  => locDenL(i),
         C  => sysClk,
         CE => '1',
         D1 => outDenL,
         D2 => outDenL,
         R  => '0',      
         S  => '0'
      );

      -- Output
      ddrData(i) <= locDout(i) when locDenL(i) = '0' else 'Z';

   end generate;

   ---------------------------------------------------
   -- DDR Read Data Capture
   ---------------------------------------------------

   -- Generate incoming DDR flip flops
   DDRI: for i in 17 downto 0 generate

      -- Data input pads
      U_DI: IDDR generic map ( DDR_CLK_EDGE => "SAME_EDGE_PIPELINED" ) port map (
         Q1 => ddrRdData(i),
         Q2 => ddrRdData(18+i),
         C  => ddrClk,
         CE => '1',
         D  => ddrData(i),
         R  => '0',      
         S  => '0'
      );
   end generate;
   
   U_DdrFifo: afifo_35x512 port map(
      rd_clk             => sysClk,
      rd_en              => intRd,
      dout(34)           => intSOF,
      dout(33)           => intEOF,
      dout(32)           => intPad,
      dout(31 downto 0)  => intData,
      rst                => ddrRst,
      wr_clk             => ddrClk,
      wr_en              => intWr,
      din                => fifoDin(34 downto 0),
      empty              => intEmpty,
      full               => intFull,
      wr_data_count      => intCnt);

   sramReq  <= not intEmpty;
   sramWr   <= regData(18);
--    sramEOF  <= regData(17);
--    sramSOF  <= regData(16);
--    sramData <= regData(15 downto 0);

--    intRd    <= sramAck and not lsbData and not intEmpty;
   intValid <= sramAck and not intEmpty;
--    intWr    <= memRdDen and ddrRdData(35);

   -- Pipeline stage
   process ( ddrClk, ddrRst ) begin
      if ddrRst = '1' then
         fifoDin <= (OTHERS=>'0') after tpd;
         intWr   <= '0'           after tpd;
      elsif rising_edge(ddrClk) then
         intWr   <= memRdDen and ddrRdData(35) after tpd;
         fifoDin <= ddrRdData after tpd;
      end if;
   end process;
   
   -- 32-bit to 16-bit conversion
   process ( curState, intSOF, intEOF, intPad, intData, intEmpty, sramAck ) begin
      case curState is
         when "00" =>
            regData(18 downto 0) <= (others=>'0') after tpd;
            
            if sramAck = '1' and intEmpty = '0' then
               nxtState  <= "01"     after tpd;
               intRd     <= '1'      after tpd;
            else
               nxtState  <= "00"     after tpd;
               intRd     <= '0'      after tpd;
            end if;
         when "01" =>
            intRd        <= '0'      after tpd;
            regData(17)  <= intPad   after tpd;
            regData(16)  <= intSOF   after tpd;
            regData(15 downto 0) <= intData(15 downto 0)  after tpd;
            
            if sramAck = '0' then
               regData(18) <= '0'      after tpd;
               nxtState    <= "01"     after tpd;
            elsif intPad = '0' then
               regData(18) <= '1'      after tpd;
               nxtState    <= "10"     after tpd;
            else
               regData(18) <= '1'      after tpd;
               nxtState    <= "00"     after tpd;
            end if;
         when "10" =>
            regData(17)  <= intEOF   after tpd;
            regData(16)  <= '0'      after tpd;
            regData(15 downto 0) <= intData(31 downto 16) after tpd;
            
            if sramAck = '1' and intEOF = '1' then
               regData(18) <= '1'      after tpd;
               nxtState    <= "00"     after tpd;
               intRd       <= '0'      after tpd;
            elsif sramAck = '1' and intEmpty = '0' then
               regData(18) <= '1'      after tpd;
               nxtState    <= "01"     after tpd;
               intRd       <= '1'      after tpd;
            else
               regData(18) <= '0'      after tpd;
               nxtState    <= "10"     after tpd;
               intRd       <= '0'      after tpd;
            end if;

         when others =>
            regData  <= (others=>'0') after tpd;
            nxtState <= "00"          after tpd;
            intRd    <= '0'           after tpd;
      end case;
   end process;
   
   process ( sysClk, sysRst ) begin
      if sysRst = '1' then
         curState  <= "00"          after tpd;
         readAFull <= '0'           after tpd;
         sramEOF   <= '0'           after tpd;
         sramSOF   <= '0'           after tpd;
         sramData  <= (OTHERS=>'0') after tpd;
         counter   <= (OTHERS=>'0') after tpd;
      elsif rising_edge(sysClk) then
         curState  <= nxtState    after tpd; 
         sramEOF   <= regData(17) after tpd;
         sramSOF   <= regData(16) after tpd;
         sramData  <= regData(15 downto 0) after tpd;

         if intCnt > 450 then
            readAFull <= '1' after tpd;
         else
            readAFull <= '0' after tpd;
         end if;

         if intEOF = '1' then
            counter <= counter + 1 after tpd;
         end if;
      end if;
   end process;

   -- Handles SRAM partition A
   ddrDataRxA: KpixDdrDataRx port map (
      sysClk    => sysClk,           sysRst    => sysRst,
      trainReq  => trainReq(0),      trainAck  => trainAck(0),
      trainSOF  => trainSOF(0),      trainEOF  => trainEOF(0),
      trainPad  => trainPad(0),      trainWr   => trainWr(0),
      trainData => trainData(0),     memWr     => memWrA,
      memWrEn   => memWrEnA,         memWrAddr => memWrAddrA,
      memWrData => memWrDataA,       memWrSOF  => memWrSOFA,
      memWrEOF  => memWrEOFA,        memWrPad  => memWrPadA,
      memRd     => memRdA,           memRdEn   => memRdEnA,
      memRdAddr => memRdAddrA,       memRdLast => memRdLastA,
      sysDebug  => sysDebug(0)
   );
   
   -- Handles SRAM partition B
   ddrDataRxB: KpixDdrDataRx port map (
      sysClk    => sysClk,           sysRst    => sysRst,
      trainReq  => trainReq(1),      trainAck  => trainAck(1),
      trainSOF  => trainSOF(1),      trainEOF  => trainEOF(1),
      trainPad  => trainPad(1),      trainWr   => trainWr(1),
      trainData => trainData(1),     memWr     => memWrB,
      memWrEn   => memWrEnB,         memWrAddr => memWrAddrB,
      memWrData => memWrDataB,       memWrSOF  => memWrSOFB,
      memWrEOF  => memWrEOFB,        memWrPad  => memWrPadB,
      memRd     => memRdB,           memRdEn   => memRdEnB,
      memRdAddr => memRdAddrB,       memRdLast => memRdLastB,
      sysDebug  => sysDebug(1)
   );
   
   -- Handles SRAM partition C
   ddrDataRxC: KpixDdrDataRx port map (
      sysClk    => sysClk,           sysRst    => sysRst,
      trainReq  => trainReq(2),      trainAck  => trainAck(2),
      trainSOF  => trainSOF(2),      trainEOF  => trainEOF(2),
      trainPad  => trainPad(2),      trainWr   => trainWr(2),
      trainData => trainData(2),     memWr     => memWrC,
      memWrEn   => memWrEnC,         memWrAddr => memWrAddrC,
      memWrData => memWrDataC,       memWrSOF  => memWrSOFC,
      memWrEOF  => memWrEOFC,        memWrPad  => memWrPadC,
      memRd     => memRdC,           memRdEn   => memRdEnC,
      memRdAddr => memRdAddrC,       memRdLast => memRdLastC,
      sysDebug  => sysDebug(2)
   );
   
   -- Handles SRAM partition D
   ddrDataRxD: KpixDdrDataRx port map (
      sysClk    => sysClk,           sysRst    => sysRst,
      trainReq  => trainReq(3),      trainAck  => trainAck(3),
      trainSOF  => trainSOF(3),      trainEOF  => trainEOF(3),
      trainPad  => trainPad(3),      trainWr   => trainWr(3),
      trainData => trainData(3),     memWr     => memWrD,
      memWrEn   => memWrEnD,         memWrAddr => memWrAddrD,
      memWrData => memWrDataD,       memWrSOF  => memWrSOFD,
      memWrEOF  => memWrEOFD,        memWrPad  => memWrPadD,
      memRd     => memRdD,           memRdEn   => memRdEnD,
      memRdAddr => memRdAddrD,       memRdLast => memRdLastD,
      sysDebug  => sysDebug(3)
   );

end KpixDdrData;