-------------------------------------------------------------------------------
-- Title         : W_Si Chip Readout Controller
-- Project       : W_Si Chip
-------------------------------------------------------------------------------
-- File          : readout_control_v7.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/27/2005
-------------------------------------------------------------------------------
-- Description:
-- This state machine controls the readout of sample data from the W_SI chip.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 by SLAC. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/27/2005: created.
-- 06/02/2005: Changed logic to accomodate multiplexed clocks
-- 06/09/2005: Removed clear_row_shift, will now be reset by analog_rst.
-- 06/13/2005: Removed incr_cell_value, using load_shift_reg to increment.
-- 06/21/2005: Adjusted location of event count in count/range word.
-- 08/11/2005: Changed to async reset
-- 08/24/2005: Adjusted precharge delays.
-- 08/30/2005: Changed reset polarity
-- 08/30/2005: Moved register of incoming read data to top level
-- 10/20/2005: Fixed pipeline error in readout data, changed location of gap
--             of readout data for parity insertion.
-- 02/05/2009: Added read state tracking for FPGA core. Not in real ASIC.
-------------------------------------------------------------------------------

use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity readout_control_v7 is port ( 

      -- Clock & Reset
      sysclk              : in  std_logic;  -- 23.74Mhz Clock
      int_reset_l         : in  std_logic;  -- Master reset
  
      -- Incoming control signals
      chip_address        : in  std_logic_vector(6 downto 0);
      readout_start       : in  std_logic;
      sparse_en           : in  std_logic;
      test_mode           : in  std_logic;

      -- Readout state
      read_state          : out std_logic;

      -- Readout control signals
      precharge_dig_bus   : out std_logic;
      load_shift_reg      : out std_logic;
      read_shift_clock_en : out std_logic;
      int_rdback          : in  std_logic;

      -- Outgoing data stream
      sample_data_out     : out std_logic
   );

end readout_control_v7;


-- Define architecture
architecture readout_control_v7 of readout_control_v7 is

   -- Local Signals
   signal int_head_en    : std_logic;                     -- Sig: 
   signal int_start_en   : std_logic;                     -- Sig: 
   signal int_par_en     : std_logic;                     -- Sig: 
   signal int_data_en    : std_logic;                     -- Sig: 
   signal nxt_evt_cnt    : std_logic_vector(2  downto 0); -- Sig:
   signal int_evt_cnt    : std_logic_vector(2  downto 0); -- Reg:
   signal nxt_par        : std_logic;                     -- Sig: 
   signal int_par        : std_logic;                     -- Reg: 
   signal typ_cnt        : std_logic_vector(3  downto 0); -- Reg:
   signal typ_cnt_inc    : std_logic;                     -- Sig: 
   signal typ_cnt_rst    : std_logic;                     -- Sig: 
   signal row_cnt        : std_logic_vector(4  downto 0); -- Reg:
   signal row_cnt_rst    : std_logic;                     -- Sig: 
   signal row_cnt_inc    : std_logic;                     -- Sig: 
   signal col_cnt        : std_logic_vector(4  downto 0); -- Reg:
   signal col_cnt_rst    : std_logic;                     -- Sig: 
   signal col_cnt_inc    : std_logic;                     -- Sig: 
   signal st_cnt         : std_logic_vector(8  downto 0); -- Reg:
   signal st_cnt_rst     : std_logic;                     -- Sig: 
   signal nxt_pre_dig    : std_logic;                     -- Sig: 
   signal int_pre_dig    : std_logic;                     -- Reg: 
   signal nxt_load_shift : std_logic;                     -- Sig: 
   signal int_load_shift : std_logic;                     -- Reg: 
   signal nxt_rd_clken   : std_logic;                     -- Sig: 
   signal int_rd_clken   : std_logic;                     -- Reg: 
   signal int_data_sft   : std_logic_vector(12 downto 0); -- Reg:
   signal head_data      : std_logic_vector(20 downto 0); -- Sig:
   signal nxt_read_state : std_logic;                     -- Sig: 

   -- Master state
   signal rd_state    : std_logic_vector(2 downto 0);  -- Read state
   signal nxt_state   : std_logic_vector(2 downto 0);  -- Next read state

   -- State constants
   constant RD_IDLE   : std_logic_vector(2 downto 0) := "000";  -- Idle time
   constant RD_PRE    : std_logic_vector(2 downto 0) := "001";  -- Precharge Bus
   constant RD_HEAD   : std_logic_vector(2 downto 0) := "011";  -- Send Header
   constant RD_DATA   : std_logic_vector(2 downto 0) := "010";  -- Send Data
   constant RD_SHIFT  : std_logic_vector(2 downto 0) := "110";  -- Shift row/word select
   constant RD_SKIP   : std_logic_vector(2 downto 0) := "111";  -- Skip empty channels

begin

   -- Connect Outputs From State Machine
   precharge_dig_bus   <= int_pre_dig;
   load_shift_reg      <= int_load_shift;
   read_shift_clock_en <= int_rd_clken;


   -- Create 13 bit shift register containing the last 13 bits
   -- sent out. This is used to find the event count in each row.
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         int_data_sft <= (others=>'0')  after 1 ns;

      elsif rising_edge(sysclk) then
         if ( int_data_en = '1' ) then
            int_data_sft <= int_data_sft(11 downto 0) & int_rdback after 1 ns;
         end if;
      end if;
   end process;


   -- Generate header word, bit 0 transmitted first
   head_data(3  downto  0) <= "1010";       -- Start of frame marker, follows start bit
   head_data(4)            <= '1';          -- Denotes sample data
   head_data(11 downto  5) <= chip_address; -- Contains chip address
   head_data(16 downto 12) <= row_cnt;      -- Contains row number
   head_data(20 downto 17) <= typ_cnt;      -- Contains data type value
                                            -- 0=Count, 1=Time0, 2=Data0, 3=Time1, 4=Data1, etc
   
   -- Select output stream data
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         sample_data_out <= '0' after 1 ns;

      elsif rising_edge(sysclk) then

         -- Start bit
         if ( int_start_en = '1' ) then
            sample_data_out <= '1' after 1 ns;

         -- Parity bit
         elsif ( int_par_en = '1' ) then
            sample_data_out <= int_par after 1 ns;

         -- Header word
         elsif ( int_head_en = '1' ) then
            sample_data_out <= head_data(conv_integer(st_cnt)) after 1 ns;

         -- Shift register data
         elsif ( int_data_en = '1' ) then
            sample_data_out <= int_rdback after 1 ns;

         -- IDLE
         else
            sample_data_out <= '0' after 1 ns;
         end if;
      end if;
   end process;


   -- Counters used by state machine
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         row_cnt <= "00000" after 1 ns;
         col_cnt <= "00000" after 1 ns;
         typ_cnt <= "0000" after 1 ns;
         st_cnt  <= "000000000" after 1 ns;

      elsif rising_edge(sysclk) then

         -- Row counter
         if (row_cnt_rst = '1') then
            row_cnt <= "00000" after 1 ns;
         elsif (row_cnt_inc = '1') then
            row_cnt <= row_cnt + 1 after 1 ns;
         end if;

         -- Col counter
         if (col_cnt_rst = '1') then
            col_cnt <= "00000" after 1 ns;
         elsif (col_cnt_inc = '1') then
            col_cnt <= col_cnt + 1 after 1 ns;
         end if;

         -- Outgoing Type Counter
         if (typ_cnt_rst = '1') then
            typ_cnt <= "0000" after 1 ns;
         elsif (typ_cnt_inc = '1') then
            typ_cnt <= typ_cnt + 1 after 1 ns;
         end if;

         -- State counter
         if (st_cnt_rst = '1') then
            st_cnt <= "000000000" after 1 ns;
         else
            st_cnt <= st_cnt + 1 after 1 ns;
         end if;
      end if;
   end process;


   -- State transition logic
   process ( sysclk, int_reset_l ) begin
      if (int_reset_l = '0') then
         rd_state       <= RD_IDLE        after 1 ns;
         int_load_shift <= '0'            after 1 ns;
         int_evt_cnt    <= "000"          after 1 ns;
         int_rd_clken   <= '0'            after 1 ns;
         int_par        <= '0'            after 1 ns;
         int_pre_dig    <= '0'            after 1 ns;
         read_state     <= '0'            after 1 ns;

      elsif rising_edge(sysclk) then
         rd_state       <= nxt_state      after 1 ns;
         int_load_shift <= nxt_load_shift after 1 ns;
         int_evt_cnt    <= nxt_evt_cnt    after 1 ns;
         int_rd_clken   <= nxt_rd_clken   after 1 ns;
         int_par        <= nxt_par        after 1 ns;
         int_pre_dig    <= nxt_pre_dig    after 1 ns;
         read_state     <= nxt_read_state after 1 ns;
      end if;
   end process;


   -- State machine
   process ( rd_state, st_cnt, readout_start, sparse_en, int_evt_cnt,
             int_par, typ_cnt, row_cnt, col_cnt, int_pre_dig, int_load_shift,
             int_rdback, int_data_sft, test_mode, head_data ) begin

      case rd_state is

         -- Idle, wait for readout start
         when RD_IDLE =>

            -- Drive all signals to idle state
            int_head_en    <= '0';
            int_start_en   <= '0';
            int_par_en     <= '0';
            int_data_en    <= '0';
            nxt_load_shift <= '0';
            nxt_evt_cnt    <= "000";
            nxt_rd_clken   <= '0';
            nxt_par        <= '0';
            row_cnt_rst    <= '1';
            row_cnt_inc    <= '0';
            col_cnt_rst    <= '1';
            col_cnt_inc    <= '0';
            typ_cnt_rst    <= '1';
            typ_cnt_inc    <= '0';
            st_cnt_rst     <= '1';
            nxt_read_state <= '0';

            -- Sequence start, reset row/reg select shift register
            -- Go to precharge dig bus state
            if ( readout_start = '1' ) then
               nxt_state      <= RD_PRE;
               nxt_pre_dig    <= '1';
            else
               nxt_state      <= rd_state;
               nxt_pre_dig    <= '0';
            end if;


         -- Precharge digital bus & shift register data from memory cells
         when RD_PRE =>

            -- Unused signals
            int_head_en    <= '0';
            int_par_en     <= '0';
            int_data_en    <= '0';
            nxt_evt_cnt    <= "000";
            nxt_par        <= '0';
            row_cnt_rst    <= '0';
            row_cnt_inc    <= '0';
            col_cnt_rst    <= '0';
            col_cnt_inc    <= '0';
            typ_cnt_rst    <= '0';
            typ_cnt_inc    <= '0';
            nxt_read_state <= '1';

            -- Precharge digital bus goes away at ~1us
            if ( st_cnt = 23 ) then
               nxt_pre_dig <= '0';
            else
               nxt_pre_dig <= int_pre_dig;
            end if;

            -- Load shift register comes on at ~2us and stays asserted until end of state
            -- Don't shift data in test mode
            if ( st_cnt = 47 ) then
               nxt_load_shift <= not test_mode;
            else
               nxt_load_shift <= int_load_shift;
            end if;

            -- State ends at ~12us and shift clock is enabled to load in memory data
            -- Start bit is also enabled here to prepare for header
            -- being shifted out in the next state
            if ( st_cnt = 284 ) then
               int_start_en  <= '1';
               nxt_rd_clken  <= '1';
               st_cnt_rst    <= '1';
               nxt_state     <= RD_HEAD;
            else
               int_start_en  <= '0';
               nxt_rd_clken  <= '0';
               st_cnt_rst    <= '0';
               nxt_state     <= rd_state;
            end if;


         -- Shift out header data
         when RD_HEAD =>

            -- Unused signals
            int_start_en   <= '0';
            int_data_en    <= '0';
            nxt_evt_cnt    <= "000";
            row_cnt_rst    <= '0';
            row_cnt_inc    <= '0';
            col_cnt_rst    <= '0';
            col_cnt_inc    <= '0';
            typ_cnt_rst    <= '0';
            typ_cnt_inc    <= '0';
            nxt_pre_dig    <= '0';
            nxt_load_shift <= '0';
            nxt_read_state <= '1';

            -- Bit 21 is parity bit and end of state
            -- Preshift to prepare for outgoing data
            if (st_cnt = 21) then
               int_head_en   <= '0';
               nxt_rd_clken  <= '1';
               int_par_en    <= '1';
               nxt_par       <= '0';
               nxt_state     <= RD_DATA;
               st_cnt_rst    <= '1';

            -- Run bit counter and enable header data to be output
            else
               int_head_en   <= '1';
               nxt_rd_clken  <= '0';
               int_par_en    <= '0';
               nxt_par       <= head_data(conv_integer(st_cnt)) xor int_par;
               nxt_state     <= rd_state;
               st_cnt_rst    <= '0';
            end if;


         -- Shift out row data
         when RD_DATA =>

            -- Unused signals
            int_head_en    <= '0';
            int_start_en   <= '0';
            nxt_load_shift <= '0';
            row_cnt_rst    <= '0';
            row_cnt_inc    <= '0';
            col_cnt_rst    <= '0';
            typ_cnt_rst    <= '0';
            nxt_pre_dig    <= '0';
            typ_cnt_inc    <= '0';
            nxt_read_state <= '1';

            -- Bit 13 is the parity bit
            if ( st_cnt = 13 ) then

               -- Output parity and increment col counter
               int_data_en  <= '0';
               int_par_en   <= '1';
               nxt_rd_clken <= '1';
               nxt_par      <= '0';
               st_cnt_rst   <= '1';
               col_cnt_inc  <= '1';

               -- Register column event count value if output data is count
               -- and current column has a larger event count then the stored value
               if ( typ_cnt = 0 and int_data_sft(7 downto 5) > int_evt_cnt ) then
                  nxt_evt_cnt <= int_data_sft(7 downto 5);
               else
                  nxt_evt_cnt <= int_evt_cnt;
               end if;

               -- Are we done with column data?
               if ( col_cnt = 31 ) then
                  nxt_state   <= RD_SHIFT;
               else
                  nxt_state   <= rd_state;
               end if;

            -- Normal data output
            else
            
               -- Skip shift register clock at bit 12
               if ( st_cnt = 12 ) then
                  nxt_rd_clken <= '0';
               else
                  nxt_rd_clken <= '1';
               end if;

               int_data_en  <= '1';
               int_par_en   <= '0';
               nxt_par      <= int_rdback xor int_par;
               st_cnt_rst   <= '0';
               col_cnt_inc  <= '0';
               nxt_evt_cnt  <= int_evt_cnt;
               nxt_state    <= rd_state;
            end if;


         -- Set increment row/reg select shift register
         when RD_SHIFT =>

            -- Unused signals
            int_head_en    <= '0';
            int_start_en   <= '0';
            row_cnt_rst    <= '0';
            int_data_en    <= '0';
            int_par_en     <= '0';
            nxt_rd_clken   <= '0';
            nxt_par        <= '0';
            st_cnt_rst     <= '0';
            col_cnt_inc    <= '0';
            nxt_evt_cnt    <= "000";
            nxt_load_shift <= '0';
            nxt_read_state <= '1';

            -- Clear column counter
            -- One position was shifted earlier when load occured
            col_cnt_rst    <= '1';

            -- We are done with the row. Check if we read last word or if we just
            -- read the data word from the last detected event for the column
            -- only use event count comparison if sparse is enabled
            if ( typ_cnt(3) = '1' or 
                 ((typ_cnt(3 downto 1) = int_evt_cnt) and sparse_en = '1' )) then

               -- Increment row count
               row_cnt_inc <= '1';

               -- Are we done with chip
               if ( row_cnt = 31 ) then
                  typ_cnt_rst   <= '1';
                  typ_cnt_inc   <= '0';
                  nxt_state     <= RD_IDLE;
                  nxt_pre_dig   <= '0';

               -- Single shift is required
               elsif ( typ_cnt(3) = '1' ) then
                  nxt_pre_dig   <= '1';
                  typ_cnt_rst   <= '1';
                  typ_cnt_inc   <= '0';
                  nxt_state     <= RD_PRE;

               -- We need to skip some words, increment type counter to match
               -- shift that will always occur here
               else
                  nxt_pre_dig   <= '0';
                  typ_cnt_rst   <= '0';
                  typ_cnt_inc   <= '1';
                  nxt_state     <= RD_SKIP;
               end if;

            -- Shift once and go to precharge state
            -- increment type count
            else
               row_cnt_inc   <= '0';
               nxt_pre_dig   <= '1';
               typ_cnt_rst   <= '0';
               typ_cnt_inc   <= '1';
               nxt_state     <= RD_PRE;
            end if;


         -- Skip data words that are known to contain no data
         -- We will only reach this state if sparse_en is set
         -- In this state we keep shifting until we get to count value of next row
         when RD_SKIP =>

            -- Unused signals
            int_head_en    <= '0';
            int_start_en   <= '0';
            int_par_en     <= '0';
            int_data_en    <= '0';
            nxt_evt_cnt    <= "000";
            nxt_rd_clken   <= '0';
            nxt_par        <= '0';
            row_cnt_rst    <= '0';
            row_cnt_inc    <= '0';
            col_cnt_rst    <= '0';
            col_cnt_inc    <= '0';
            st_cnt_rst     <= '0';
            nxt_pre_dig    <= '0';
            nxt_read_state <= '1';

            -- Always shift one position
            nxt_load_shift <= '1';

            -- Are we done?
            if ( typ_cnt(3) = '1' ) then
               nxt_state    <= RD_PRE;
               typ_cnt_inc  <= '0';
               typ_cnt_rst  <= '1';
            else
               nxt_state    <= rd_state;
               typ_cnt_inc  <= '1';
               typ_cnt_rst  <= '0';
            end if;


         -- Catch errors
         when others =>
            int_head_en    <= '0';
            int_start_en   <= '0';
            int_par_en     <= '0';
            int_data_en    <= '0';
            nxt_load_shift <= '0';
            nxt_evt_cnt    <= "000";
            nxt_rd_clken   <= '0';
            nxt_par        <= '0';
            row_cnt_rst    <= '0';
            row_cnt_inc    <= '0';
            col_cnt_rst    <= '0';
            col_cnt_inc    <= '0';
            st_cnt_rst     <= '0';
            nxt_pre_dig    <= '0';
            typ_cnt_inc    <= '0';
            typ_cnt_rst    <= '1';
            nxt_read_state <= '0';
            nxt_state      <= RD_IDLE;

      end case;
   end process;
end readout_control_v7;
