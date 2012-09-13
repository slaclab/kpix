use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity DataRead is port ( 

      -- Master reset
      reset             : in  std_logic;

      -- Control signals
      reset_load        : in  std_logic;
      pwr_up_acq_dig    : in  std_logic;

      -- Multipurpose clock
      reg_clock         : in  std_logic;
      reg_sel1          : in  std_logic;
      reg_sel0          : in  std_logic;

      -- Data out
      rdback            : out std_logic
   );

end DataRead;

-- Define architecture
architecture DataRead of DataRead is

   -- Local Signals
   signal rowCnt    : std_logic_vector(4   downto 0);
   signal wordCnt   : std_logic_vector(3   downto 0);
   signal shiftReg  : std_logic_vector(415 downto 0);
   signal shiftData : std_logic_vector(415 downto 0);

begin

   -- Control output data
   rdBack <= shiftReg(0) when reg_sel0 = '1' and reg_sel1 = '1' else '0';

   -- Row/Col tracking
   process ( reg_clock, reset ) begin
      if ( reset = '1' or (reset_load = '1' and pwr_up_acq_dig = '1') ) then
         rowCnt   <= (others=>'0') after tpd;
         wordCnt  <= (others=>'0') after tpd;
         shiftReg <= (others=>'0') after tpd;
      elsif (rising_edge(reg_clock)) then
         if reg_sel0 = '1' and reg_sel1 = '1' then

           -- Load data and increment count
           if reset_load = '1' then
              if wordCnt = 8 then
                 wordCnt <= (others=>'0') after tpd;
                 rowCnt  <= rowCnt + 1    after tpd;
              else
                 wordCnt <= wordCnt + 1 after tpd;
              end if;

              shiftReg <= shiftData;

           -- Shift data
           else
              shiftReg <= '0' & shiftData(414 downto 1);
           end if;
         end if;
      end if;
   end process;

   -- Each channel   
   for i in 0 to 31 generate
      process ( wordCnt, rowCnt ) begin
         case wordCnt is

            -- Cntrl word
            when "0000" =>
               shiftData((i*13)+12 downto (i*13)+11) <= "00";   -- Unused
               shiftData((i*13)+10 downto (i*13)+7 ) <= "0000"; -- Trig bits = 0
               shiftData((i*13)+6  downto (i*13)+4 ) <= "011";  -- 4 buckets of data
               shiftData((i*13)+3  downto (i*13)+0 ) <= "0000"; -- Range bits = 0

            -- Bucket 0 Timestamp, pass bucket and channel #
            when "0001" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "000" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            -- Bucket 0 Data, pass bucket and channel #
            when "0010" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "000" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            -- Bucket 1 Timestamp, pass bucket and channel #
            when "0011" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "001" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            -- Bucket 1 Data, pass bucket and channel #
            when "0100" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "001" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            -- Bucket 2 Timestamp, pass bucket and channel #
            when "0101" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "010" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            -- Bucket 2 Data, pass bucket and channel #
            when "0110" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "010" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            -- Bucket 3 Timestamp, pass bucket and channel #
            when "0111" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "011" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            -- Bucket 3 Data, pass bucket and channel #
            when "1000" =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= "011" & conv_std_logic_vector((i*32)+conv_integer(31-rowCnt),10);

            when others =>
               shiftData((i*13)+12 downto (i*13)+0 ) <= (others=>'0');
         end case;
      end process;
   end generate;

end DataRead;

