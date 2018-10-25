-------------------------------------------------------------------------------
-- Title         : W_Si Chip Command Controller
-- Project       : W_Si Chip
-------------------------------------------------------------------------------
-- File          : command_control_v7.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/27/2005
-------------------------------------------------------------------------------
-- Description:
-- This logic controls the register access
-------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/27/2005: created.
-- 05/11/2005: Added enable signals for each of the 4 calibration pulses
-- 05/25/2005: Changed logic to support external address register in analog logic
-- 05/27/2005: Removed tTL & tTI times, removed 1 timing register.
-- 06/02/2005: Changed for multiplex register clocking, moved incoming sample
--             to falling edge of clock.
-- 06/10/2005: Changed signal names to match top level.
-- 06/17/2005: Fixed test data register readback
-- 06/17/2005: Fixed reg_wr_en idle state
-- 06/21/2005: Added timing defaults.
-- 08/03/2005: Changed structure & number of timing control registers
-- 08/10/2005: Fixed local register access decoder.
-- 08/11/2005: Changed to async reset
-- 08/30/2005: Changed int_reset polarity
-- 08/30/2005: Moved register of incoming read data to top level
-------------------------------------------------------------------------------

use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity command_control_v7 is port ( 

      -- Clock & Reset
      sysclk            : in  std_logic;  -- 23.74Mhz Clock
      int_reset_l       : in  std_logic;  -- Master reset
      command           : in  std_logic;
      resp_data_out     : out std_logic;
      chip_address      : in  std_logic_vector(6 downto 0);

      -- Command decode signals
      start_sequence    : out std_logic;  
      start_calibrate   : out std_logic;  
      cmd_reset         : out std_logic;

      -- Timing configuration
      tc0_data          : out std_logic_vector(31 downto 0);
      tc1_data          : out std_logic_vector(31 downto 0);
      tc2_data          : out std_logic_vector(31 downto 0);
      tc3_data          : out std_logic_vector(31 downto 0);
      tc4_data          : out std_logic_vector(31 downto 0);
      tc5_data          : out std_logic_vector(31 downto 0);
      tc6_data          : out std_logic_vector(31 downto 0);
      tc7_data          : out std_logic_vector(31 downto 0);

      -- Calibration configuration
      cd0_data          : out std_logic_vector(31 downto 0);
      cd1_data          : out std_logic_vector(31 downto 0);

      -- DC Configurations
      sparse_en         : out std_logic;
      test_mode         : out std_logic;

      -- Access to data registers
      test_data_clk_en  : out std_logic;

      -- External configuration registers
      reg_data          : out std_logic;
      reg_clk_en        : out std_logic;
      reg_wr_ena        : out std_logic;
      sel_addr_reg      : out std_logic;
      int_rdback        : in  std_logic
   );

end command_control_v7;


-- Define architecture
architecture command_control_v7 of command_control_v7 is

   -- Local Signals
   signal cmd_cnt             : std_logic_vector(5  downto 0);  -- Reg
   signal cmd_cnt_rst         : std_logic;                      -- Sig
   signal int_command         : std_logic;                      -- Reg
   signal int_hdr_data        : std_logic_vector(20 downto 0);  -- Reg
   signal hdr_shift_en        : std_logic;                      -- Sig
   signal addr_match          : std_logic;                      -- Sig
   signal int_par             : std_logic;                      -- Reg
   signal nxt_par             : std_logic;                      -- Sig
   signal int_cmd_en          : std_logic;                      -- Reg
   signal nxt_cmd_en          : std_logic;                      -- Sig
   signal head_perr           : std_logic;                      -- Reg
   signal set_head_perr       : std_logic;                      -- Sig
   signal data_perr           : std_logic;                      -- Reg
   signal set_data_perr       : std_logic;                      -- Sig
   signal tx_start_en         : std_logic;                      -- Sig
   signal tx_head_en          : std_logic;                      -- Sig
   signal tx_data_en          : std_logic;                      -- Sig
   signal tx_par_en           : std_logic;                      -- Sig
   signal head_data           : std_logic_vector(21 downto 0);  -- Sig
   signal stat_reg            : std_logic;                      -- Sig
   signal loc_reg_data        : std_logic;                      -- Sig
   signal resp_data_mux       : std_logic;                      -- Sig
   signal int_sel_addr        : std_logic;                      -- Reg
   signal nxt_sel_addr        : std_logic;                      -- Sig
   signal int_wr_ena          : std_logic;                      -- Sig
   signal tc0_sel             : std_logic;                      -- Sig
   signal tc0_rd              : std_logic;                      -- Sig
   signal tc1_sel             : std_logic;                      -- Sig
   signal tc1_rd              : std_logic;                      -- Sig
   signal tc2_sel             : std_logic;                      -- Sig
   signal tc2_rd              : std_logic;                      -- Sig
   signal tc3_sel             : std_logic;                      -- Sig
   signal tc3_rd              : std_logic;                      -- Sig
   signal tc4_sel             : std_logic;                      -- Sig
   signal tc4_rd              : std_logic;                      -- Sig
   signal tc5_sel             : std_logic;                      -- Sig
   signal tc5_rd              : std_logic;                      -- Sig
   signal tc6_sel             : std_logic;                      -- Sig
   signal tc6_rd              : std_logic;                      -- Sig
   signal tc7_sel             : std_logic;                      -- Sig
   signal tc7_rd              : std_logic;                      -- Sig
   signal cd0_sel             : std_logic;                      -- Sig
   signal cd0_rd              : std_logic;                      -- Sig
   signal cd1_sel             : std_logic;                      -- Sig
   signal cd1_rd              : std_logic;                      -- Sig
   signal cfg_sel             : std_logic;                      -- Sig
   signal cfg_rd              : std_logic;                      -- Sig
   signal cfg_data            : std_logic_vector(31 downto 0);  -- Sig

   -- Master state
   signal cmd_state     : std_logic_vector(2 downto 0);  -- Reg: Master state
   signal nxt_cmd_state : std_logic_vector(2 downto 0);  -- Sig: Next master state

   -- Master State constants
   constant CMD_IDLE    : std_logic_vector(2 downto 0) := "000";  -- Idle time
   constant CMD_RX_HEAD : std_logic_vector(2 downto 0) := "001";  -- Reset state
   constant CMD_RX_PAR  : std_logic_vector(2 downto 0) := "011";  -- Pre-Sample
   constant CMD_RX_DATA : std_logic_vector(2 downto 0) := "010";  -- Sample
   constant CMD_TX_HEAD : std_logic_vector(2 downto 0) := "110";  -- Pause
   constant CMD_TX_DATA : std_logic_vector(2 downto 0) := "111";  -- Digitize

   -- 32-bit serial register
   component reg_rw_32_v7
      port (
         sysclk      : in  std_logic;
         int_reset_l : in  std_logic;
         reg_sel     : in  std_logic;
         reg_wr_en   : in  std_logic;
         shift_in    : in  std_logic;
         shift_out   : out std_logic;
         data_out    : out std_logic_vector(31 downto 0);
         reset_val   : in  std_logic_vector(31 downto 0)
      );
   end component;

   ---------------------------
   -- Register reset values
   ---------------------------

   -- Config Register
   -- Bit 0 = test_mode
   -- Bit 1 = sparse_en
   constant CFG_VAL : std_logic_vector(31 downto 0) := X"00000000";

   -- ANALOG_RESET Timing
   -- Bits 15-0  - On  at 337ns
   -- Bits 31-16 - Off at 10,0025.75ns
   constant TC0_VAL : std_logic_vector(31 downto 0) := X"00ED0007";

   -- LEAKAGE_NULL Timing
   -- Bits 15-0  - Off at 126.375ns
   -- Bits 31-16 - On  at 994,950.375ns
   constant TC1_VAL : std_logic_vector(31 downto 0) := X"5C420002";

   -- OFFSET_NULL Timing
   -- Bits 15-0  - Off at 15,038.625ns
   -- Bits 31-16 - On  at 994,950.375ns
   constant TC2_VAL : std_logic_vector(31 downto 0) := X"5C420164";

   -- THRESHOLD_OFF Timing
   -- Bits 15-0  - Off at 15,333.5ns
   -- Bits 31-16 - On  at 994,950.375ns
   constant TC3_VAL : std_logic_vector(31 downto 0) := X"5C42016B";

   -- TRIGGER_INH Timing
   -- Bits 15-0  - Off at 16,344.5ns
   -- Bits 31-16 - On  at 994,950.375ns
   constant TC4_VAL : std_logic_vector(31 downto 0) := X"5C420183";

   -- Power Up Acq Timing
   -- Bits 15-0  - On  at 421.25ns
   -- Bits 31-16 - Off at 994,950.375ns
   constant TC5_VAL : std_logic_vector(31 downto 0) := X"5C420009";

   -- Power Up Acq Dig Timing
   -- Bits 15-0  - On  at 421.25ns
   -- Bits 31-16 - Off at 2,383,390.375ns
   constant TC6_VAL : std_logic_vector(31 downto 0) := X"DD020009";

   -- State Timing
   -- Bits 7-0   - Start init amp delay, 3,033ns
   -- Bits 23-8  - Bunch Clock Start delay, 16,007.5ns
   -- Bits 31-24 - Last bunch clock to dig delay, 10,025.75ns
   constant TC7_VAL : std_logic_vector(31 downto 0) := X"ED017B47";

   -- Cal Delay 0
   -- Bits 11-0  - Cal strobe 0 delay  = Clock 31
   -- Bits 12-0  - Cal strobe 0 enable = True
   -- Bits 27-16 - Cal strobe 1 delay  = Clock 31
   -- Bits 28    - Cal strobe 1 enable = True
   constant CD0_VAL : std_logic_vector(31 downto 0) := X"101F101F";

   -- Cal Delay 1
   -- Bits 11-0  - Cal strobe 2 delay  = Clock 31
   -- Bits 12-0  - Cal strobe 2 enable = True
   -- Bits 27-16 - Cal strobe 3 delay  = Clock 31
   -- Bits 28    - Cal strobe 3 enable = True
   constant CD1_VAL : std_logic_vector(31 downto 0) := X"101F101F";

begin

   -- Command counter
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         cmd_cnt      <= (others=>'0') after 1 ns;
         int_hdr_data <= (others=>'0') after 1 ns;

      elsif rising_edge(sysclk) then

         -- Command counter
         if ( cmd_cnt_rst = '1' ) then
            cmd_cnt <= (others=>'0') after 1 ns;
         else
            cmd_cnt <= cmd_cnt + 1 after 1 ns;
         end if;

         -- Header shift register
         if ( hdr_shift_en = '1' ) then
            int_hdr_data <= int_command & int_hdr_data(20 downto 1) after 1 ns;
         end if;
      end if;
   end process;

   -- Decode address, check for local match or broadcast
   -- It may be decided that this chip does not know its address. In that case
   -- upstream logic will handlie the update/checking of this field. The
   -- chip address field will always be contained in the header.
   addr_match <= '1' when ( int_hdr_data(11 downto 5) = "1111111" or 
                            int_hdr_data(11 downto 5) = chip_address )  else '0';


   -- State transition logic
   process ( sysclk, int_reset_l ) begin
      if (int_reset_l = '0') then
         cmd_state    <= CMD_IDLE       after 1 ns;
         int_par      <= '0'            after 1 ns;
         int_command  <= '0'            after 1 ns;
         int_cmd_en   <= '0'            after 1 ns;
         head_perr    <= '0'            after 1 ns;
         data_perr    <= '0'            after 1 ns;
         int_sel_addr <= '0'            after 1 ns;

      elsif rising_edge(sysclk) then
         cmd_state    <= nxt_cmd_state  after 1 ns;
         int_par      <= nxt_par        after 1 ns;
         int_command  <= command        after 1 ns;
         int_cmd_en   <= nxt_cmd_en     after 1 ns;
         int_sel_addr <= nxt_sel_addr   after 1 ns;

         -- Set parity errors
         if ( set_head_perr = '1' ) then head_perr <= '1' after 1 ns; end if;
         if ( set_data_perr = '1' ) then data_perr <= '1' after 1 ns; end if;
      end if;
   end process;


   -- Command state machine
   process ( cmd_state, cmd_cnt, int_par, int_command, addr_match, 
             int_cmd_en, int_hdr_data, resp_data_mux, int_sel_addr ) begin

      case cmd_state is

         -- Idle, wait for start bit
         when CMD_IDLE =>

            -- Drive all signals to idle state
            nxt_cmd_en    <= '0';
            nxt_par       <= '0';
            set_head_perr <= '0';
            set_data_perr <= '0';
            cmd_cnt_rst   <= '1';
            hdr_shift_en  <= '0';
            tx_start_en   <= '0';
            tx_head_en    <= '0';
            tx_data_en    <= '0';
            tx_par_en     <= '0';
            nxt_sel_addr  <= '0';

            -- Sequence start
            if ( int_command = '1' ) then
               nxt_cmd_state <= CMD_RX_HEAD;
            else
               nxt_cmd_state <= cmd_state;
            end if;


         -- Shift in header data
         when CMD_RX_HEAD =>

            -- Unused signals
            nxt_cmd_en    <= '0';
            set_head_perr <= '0';
            set_data_perr <= '0';
            tx_start_en   <= '0';
            tx_head_en    <= '0';
            tx_data_en    <= '0';
            tx_par_en     <= '0';

            -- Enable command counter, calculate parity
            hdr_shift_en <= '1';
            cmd_cnt_rst  <= '0';
            nxt_par      <= int_par xor int_command;

            -- Determine when to start shifting data into the external address register
            if ( cmd_cnt = 13 ) then
               nxt_sel_addr  <= '1';
               nxt_cmd_state <= cmd_state;

            -- Last bit received
            elsif ( cmd_cnt = 20 ) then
               nxt_sel_addr  <= '0';
               nxt_cmd_state <= CMD_RX_PAR;
            else
               nxt_sel_addr  <= int_sel_addr;
               nxt_cmd_state <= cmd_state;
            end if;


         -- Header parity received
         when CMD_RX_PAR =>

            -- Unused signals
            hdr_shift_en  <= '0';
            set_data_perr <= '0';
            cmd_cnt_rst   <= '1';
            nxt_par       <= '0';
            tx_head_en    <= '0';
            tx_data_en    <= '0';
            tx_par_en     <= '0';
            nxt_sel_addr  <= '0';

            -- Check parity
            set_head_perr <= int_command xor int_par;

            -- Command? No payload or response
            if ( int_hdr_data(12) = '0' ) then
               nxt_cmd_en    <= addr_match and not (int_command xor int_par);
               nxt_cmd_state <= CMD_IDLE;
               tx_start_en   <= '0';

            -- Register write
            elsif ( int_hdr_data(13) = '1' ) then
               nxt_cmd_en    <= addr_match and not (int_command xor int_par);
               nxt_cmd_state <= CMD_RX_DATA;
               tx_start_en   <= '0';

            -- Register read with address match
            -- Transmit start bit
            elsif ( addr_match = '1' ) then
               nxt_cmd_en    <= '0';
               nxt_cmd_state <= CMD_TX_HEAD;
               tx_start_en   <= '1';

            -- Read with no address match
            else
               nxt_cmd_en    <= '0';
               nxt_cmd_state <= CMD_IDLE;
               tx_start_en   <= '0';
            end if;


         -- Wait for 32 data bits + parity bit
         when CMD_RX_DATA =>

            -- Unused signals
            set_head_perr <= '0';
            set_data_perr <= '0';
            hdr_shift_en  <= '0';
            tx_start_en   <= '0';
            tx_head_en    <= '0';
            tx_data_en    <= '0';
            tx_par_en     <= '0';
            nxt_sel_addr  <= '0';

            -- Generate parity
            nxt_par       <= int_par xor int_command;

            -- Last data bit received
            if ( cmd_cnt = 31 ) then
               nxt_cmd_en    <= '0';
               nxt_cmd_state <= cmd_state;
               set_data_perr <= '0';
               cmd_cnt_rst   <= '0';

            -- Parity bit received
            elsif ( cmd_cnt = 32 ) then
               nxt_cmd_state <= CMD_IDLE;
               nxt_cmd_en    <= '0';
               set_data_perr <= int_par xor int_command;
               cmd_cnt_rst   <= '1';

            -- Still shifting data
            else
               nxt_cmd_state <= cmd_state;
               nxt_cmd_en    <= int_cmd_en;
               set_data_perr <= '0';
               cmd_cnt_rst   <= '0';
            end if;


         -- Shift out header data
         when CMD_TX_HEAD =>

            -- Unused signals
            set_head_perr <= '0';
            set_data_perr <= '0';
            hdr_shift_en  <= '0';
            tx_data_en    <= '0';
            set_data_perr <= '0';
            tx_start_en   <= '0';
            nxt_sel_addr  <= '0';

            -- Parity bit transmitted
            if ( cmd_cnt = 21 ) then
               nxt_cmd_en    <= '1';
               nxt_par       <= '0';
               nxt_cmd_state <= CMD_TX_DATA;
               cmd_cnt_rst   <= '1';
               tx_head_en    <= '0';
               tx_par_en     <= '1';

            -- Still shifting data
            else
               nxt_cmd_en    <= '0';
               nxt_par       <= int_par xor resp_data_mux;
               nxt_cmd_state <= cmd_state;
               cmd_cnt_rst   <= '0';
               tx_head_en    <= '1';
               tx_par_en     <= '0';
            end if;


         -- Shift out data
         when CMD_TX_DATA =>

            -- Unused signals
            set_head_perr <= '0';
            set_data_perr <= '0';
            hdr_shift_en  <= '0';
            tx_start_en   <= '0';
            tx_head_en    <= '0';
            set_data_perr <= '0';
            nxt_sel_addr  <= '0';

            -- Generate parity
            nxt_par <= int_par xor resp_data_mux;

            -- Last data bit transmitted
            if ( cmd_cnt = 31 ) then
               nxt_cmd_en    <= '0';
               nxt_cmd_state <= cmd_state;
               cmd_cnt_rst   <= '0';
               tx_data_en    <= '1';
               tx_par_en     <= '0';


            -- Parity bit transmitted
            elsif ( cmd_cnt = 32 ) then
               nxt_cmd_en    <= '0';
               nxt_cmd_state <= CMD_IDLE;
               cmd_cnt_rst   <= '1';
               tx_data_en    <= '0';
               tx_par_en     <= '1';

            -- Still shifting data
            else
               nxt_cmd_en    <= '1';
               nxt_cmd_state <= cmd_state;
               cmd_cnt_rst   <= '0';
               tx_data_en    <= '1';
               tx_par_en     <= '0';
            end if;


         -- Just in case
         when others =>
            set_head_perr <= '0';
            set_data_perr <= '0';
            hdr_shift_en  <= '0';
            tx_start_en   <= '0';
            tx_head_en    <= '0';
            nxt_cmd_en    <= '0';
            set_data_perr <= '0';
            nxt_par       <= '0';
            cmd_cnt_rst   <= '0';
            tx_data_en    <= '0';
            tx_par_en     <= '0';
            nxt_sel_addr  <= '0';
            nxt_cmd_state <= CMD_IDLE;

      end case;
   end process;

   
   -- Command decoder
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         start_sequence  <= '0' after 1 ns;
         start_calibrate <= '0' after 1 ns;
         cmd_reset       <= '0' after 1 ns;

      elsif ( rising_edge(sysclk)) then

         -- Check for received command
         if ( int_cmd_en = '1' and int_hdr_data(12) = '0' ) then

            -- Reset
            if ( int_hdr_data(15 downto 14) = "01" ) then
               cmd_reset <= '1' after 1 ns;
            end if;

            -- Start sequence
            if ( int_hdr_data(15 downto 14) = "10" ) then
               start_sequence  <= '1' after 1 ns;

            -- Start calibration
            elsif ( int_hdr_data(15 downto 14) = "11" ) then
               start_sequence    <= '1' after 1 ns;
               start_calibrate   <= '1' after 1 ns;
            end if;

         -- No command
         else
            start_sequence  <= '0' after 1 ns;
            start_calibrate <= '0' after 1 ns;
            cmd_reset       <= '0' after 1 ns;
         end if;
      end if;
   end process;


   -- The format of the header for command / data frames are shown below.
   -- The first bit received is a active high start bit. This bit is not
   -- included in the sequence below
   -- Bits 0-3   = Fixed Maker = 0101
   -- Bit  4     = Type = 1 for command traffic
   -- Bits 5-11  = Chip address [0-6]
   -- Bit  12    = CR, 0=Command, 1=Register Access
   -- Bit  13    = W, 0=Read, 1=Write
   -- Bit  14-20 = CMD ID, Register Address
   -- Bit  21    = Parity
   head_data(3  downto  0) <= "1010";                     -- Flag after start
   head_data(4)            <= '0';                        -- Response flag
   head_data(11 downto  5) <= chip_address;               -- Chip address, Set to zeros if not used
   head_data(20 downto 12) <= int_hdr_data(20 downto 12); -- Register address, W, CR
   head_data(21)           <= '0';                        -- For simulation


   -- Register response data
   process ( sysclk, int_reset_l ) begin
      if ( int_reset_l = '0' ) then
         resp_data_out <= '0' after 1 ns;

      elsif rising_edge(sysclk) then
         resp_data_out <= resp_data_mux   after 1 ns;
      end if;
   end process;


   -- Mux response data
   process (tx_start_en, tx_head_en, tx_par_en, tx_data_en, 
            cmd_cnt, head_data, int_par, int_hdr_data, 
            loc_reg_data, int_rdback ) begin

      -- Start bit
      if ( tx_start_en = '1' ) then
         resp_data_mux <= '1';

      -- Header
      elsif ( tx_head_en = '1' ) then
         resp_data_mux <= head_data(conv_integer(cmd_cnt));

      -- Parity
      elsif ( tx_par_en = '1' ) then
         resp_data_mux <= int_par;

      -- Data
      elsif ( tx_data_en = '1' ) then
         case (int_hdr_data(20 downto 19)) is
            when "00"   => resp_data_mux <= loc_reg_data;
            when "01"   => resp_data_mux <= int_rdback;
            when "10"   => resp_data_mux <= int_rdback;
            when "11"   => resp_data_mux <= int_rdback;
            when others => resp_data_mux <= '0';
         end case;
      else
         resp_data_mux <= '0';
      end if;
   end process;


   -- Drive external shift register controls
   reg_data     <= int_command;
   reg_wr_ena   <= int_cmd_en and int_hdr_data(13);
   sel_addr_reg <= int_sel_addr;

   -- Drive clock to external shift/addr registers, 
   -- clock multiplexed at top level
   reg_clk_en <= '1' 
      when (int_cmd_en = '1' and int_hdr_data(20 downto 19) /= "00") else '0';

   -- Drive test data load clock
   -- clock multiplexed at top level
   test_data_clk_en <= '1'
      when (int_cmd_en = '1' and int_hdr_data(20 downto 14) = "0011000") else '0';


   -- Decode read from local registers
   process (int_hdr_data, stat_reg, cfg_rd, tc0_rd, tc1_rd, tc2_rd, tc3_rd,
            tc4_rd, tc5_rd, tc6_rd, tc7_rd, cd0_rd, cd1_rd, int_rdback ) begin
      case (int_hdr_data(18 downto 14)) is
         when "00000" => loc_reg_data <= stat_reg;
         when "00001" => loc_reg_data <= cfg_rd;
         when "01000" => loc_reg_data <= tc0_rd;
         when "01001" => loc_reg_data <= tc1_rd;
         when "01010" => loc_reg_data <= tc2_rd;
         when "01011" => loc_reg_data <= tc3_rd;
         when "01100" => loc_reg_data <= tc4_rd;
         when "01101" => loc_reg_data <= tc5_rd;
         when "01110" => loc_reg_data <= tc6_rd;
         when "01111" => loc_reg_data <= tc7_rd;
         when "10000" => loc_reg_data <= cd0_rd;
         when "10001" => loc_reg_data <= cd1_rd;
         when "11000" => loc_reg_data <= int_rdback;
         when others  => loc_reg_data <= '0';
      end case;
   end process;


   -- Status register read
   process (cmd_cnt, head_perr, data_perr ) begin
      case (cmd_cnt(0)) is
         when '0'    => stat_reg <= head_perr;
         when '1'    => stat_reg <= data_perr;
         when others => stat_reg <= '0';
      end case;
   end process;


   -- Decode access to internal registers
   int_wr_ena <= int_cmd_en and int_hdr_data(13);
   cfg_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0000001" else '0';
   tc0_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001000" else '0';
   tc1_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001001" else '0';
   tc2_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001010" else '0';
   tc3_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001011" else '0';
   tc4_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001100" else '0';
   tc5_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001101" else '0';
   tc6_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001110" else '0';
   tc7_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0001111" else '0';
   cd0_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0010000" else '0';
   cd1_sel    <= '1' when int_cmd_en = '1' and int_hdr_data(12) = '1' and 
                          int_hdr_data(20 downto 14) = "0010001" else '0';

   -- Configuration Register
   CFG: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => cfg_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => cfg_rd,
      data_out  => cfg_data,    reset_val   => CFG_VAL
   );

   -- Connect configuration signals
   test_mode <= cfg_data(0);
   sparse_en <= cfg_data(1);

   -- Timing Control 0
   TC0: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc0_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc0_rd,
      data_out  => tc0_data,    reset_val   => TC0_VAL
   );

   -- Timing Control 1
   TC1: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc1_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc1_rd,
      data_out  => tc1_data,    reset_val   => TC1_VAL
   );

   -- Timing Control 2
   TC2: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc2_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc2_rd,
      data_out  => tc2_data,    reset_val   => TC2_VAL
   );

   -- Timing Control 3
   TC3: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc3_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc3_rd,
      data_out  => tc3_data,    reset_val   => TC3_VAL
   );

   -- Timing Control 4
   TC4: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc4_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc4_rd,
      data_out  => tc4_data,    reset_val   => TC4_VAL
   );

   -- Timing Control 5
   TC5: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc5_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc5_rd,
      data_out  => tc5_data,    reset_val   => TC5_VAL
   );

   -- Timing Control 6
   TC6: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc6_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc6_rd,
      data_out  => tc6_data,    reset_val   => TC6_VAL
   );

   -- Timing Control 7
   TC7: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => tc7_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => tc7_rd,
      data_out  => tc7_data,    reset_val   => TC7_VAL
   );

   -- Cal Delay 0
   CD0: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => cd0_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => cd0_rd,
      data_out  => cd0_data,    reset_val   => CD0_VAL
   );

   -- Cal Delay 1
   CD1: reg_rw_32_v7 port map (
      sysclk    => sysclk,      int_reset_l => int_reset_l,
      reg_sel   => cd1_sel,     reg_wr_en   => int_wr_ena,
      shift_in  => int_command, shift_out   => cd1_rd,
      data_out  => cd1_data,    reset_val   => CD1_VAL
   );

end command_control_v7;
