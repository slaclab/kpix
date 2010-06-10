-- File gray_bit.vhd
-- One bit block for the Gray Counter gray_counter.vhd
-- Jie Deng, March, 2005

-- qout: one bit output of the counter
-- zout: 1 if all the less significant bits are zero

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

package pkg_gray_bit is
	component gray_bit
		port(arst, clk, qin, zin : in std_logic;
		     qout                : inout std_logic;
		     zout                : out std_logic);
	end component;
end pkg_gray_bit;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity gray_bit is
	port(arst, clk, qin, zin : in std_logic;
		 qout                : inout std_logic;
		 zout                : out std_logic);
end gray_bit;

architecture arch_gray_bit of gray_bit is
begin
	process(arst, clk)
	begin
		if arst='1' then
			qout <= '0';
		elsif clk'event and clk='1' then
			qout <= qout XOR (qin AND zin);
		end if;
	end process;
	
	zout <= zin AND NOT qin;
end arch_gray_bit;
	
	
		
		