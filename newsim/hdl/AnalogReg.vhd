use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity AnalogReg is port ( 

      -- Master reset
      reset             : in  std_logic;

      -- Multipurpose clock
      reg_clock         : in  std_logic;
      reg_sel1          : in  std_logic;
      reg_sel0          : in  std_logic;

      -- Configuration
      reg_data          : in  std_logic;
      reg_wr_ena        : in  std_logic;
      rdback            : out std_logic
   );

end AnalogReg;

-- Define architecture
architecture AnalogReg of AnalogReg is

   -- Local Signals
   signal resetL   : std_logic;
   signal addrReg  : std_logic_vector(6 downto 0);
   signal dacTmp   : std_logic_vector(9 downto 0);
   signal dacOut   : std_logic_vector(9 downto 0);
   signal dacSel   : std_logic_vector(9 downto 0);
   signal cntrlSel : std_logic;
   signal cntrlTmp : std_logic;
   signal cntrlOut : std_logic;
   signal modeTmp  : std_logic_vector(63 downto 0);
   signal modeOut  : std_logic_vector(63 downto 0);
   signal modeSel  : std_logic_vector(63 downto 0);

begin

   -- Reset
   resetL <= not reset;

   -- Address register
   process ( reg_clock, reset ) begin
      if ( reset = '1' ) then
         addrReg <= (others=>'0');
      elsif (rising_edge(reg_clock)) then
         if reg_sel0 = '0' and reg_sel1 = '0' then
            addrReg <= reg_data & addrReg(5 downto 0);
         end if;
      end if;
   end process;

   -- DAC registers
   GenDac : for i in 0 to 9 generate

      U_Dac : entity reg_rw_32 port map (
         sysclk      => reg_clock,
         int_reset_l => resetL,
         reg_sel     => dacSel(i),
         reg_wr_en   => reg_wr_ena,
         shift_in    => reg_data,
         shift_out   => dacTmp(i),
         data_out    => open
      );
      dacSel(i) <= '1'       when reg_sel0 = '1' and reg_sel1 = '0' and addrReg = (i + 32) else '0';
      dacOut(i) <= dacTmp(i) when reg_sel0 = '1' and reg_sel1 = '0' and addrReg = (i + 32) else '0';

   end generate;

   -- Control register
   U_Cntrl : entity reg_rw_32 port map (
      sysclk      => reg_clock,
      int_reset_l => resetL,
      reg_sel     => cntrlSel,
      reg_wr_en   => reg_wr_ena,
      shift_in    => reg_data,
      shift_out   => cntrlTmp,
      data_out    => open
   );
   cntrlSel <= '1'      when reg_sel0 = '1' and reg_sel1 = '0' and addrReg = 48 else '0';
   cntrlOut <= cntrlTmp when reg_sel0 = '1' and reg_sel1 = '0' and addrReg = 48 else '0';

   -- Mode Registers
   GenMode: for i in 0 to 63 generate

      U_Mode : entity reg_rw_32 port map (
         sysclk      => reg_clock,
         int_reset_l => resetL,
         reg_sel     => modeSel(i),
         reg_wr_en   => reg_wr_ena,
         shift_in    => reg_data,
         shift_out   => modeTmp(i),
         data_out    => open
      );
      modeSel(i) <= '1'        when reg_sel0 = '1' and reg_sel1 = '0' and addrReg = (i + 64) else '0';
      modeOut(i) <= modeTmp(i) when reg_sel0 = '1' and reg_sel1 = '0' and addrReg = (i + 64) else '0';

   end generate;

   -- Data output
   rdback <= '1' when dacOut /= 0 or cntrlOut = '1' or modeOut /= 0 else '0';

end AnalogReg;

