--- File: Gray Counter.vhd
--- Gray counter with variable width and one auxiliary (parity) bit
--- Jie Deng, March, 2005


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity gray_counter is generic (width: integer:=13);
	port(a_reset, ck  : in std_logic;
	     q            : inout std_logic_vector(width downto 0));
end gray_counter;

architecture arch_gray_counter of gray_counter is

	component gray_bit port( arst, clk, qin, zin : in std_logic;
				 qout                : inout std_logic;
				 zout                : out std_logic);
	end component;

	-- inner carry signal, z[k]=1 : q[k-1:0]=0 
	signal z : std_logic_vector(width downto 0);
	-- input signal for MSB
	signal q_msb : std_logic;

begin
	-- (width-1) less significant bits
	gray_lsb : for i in 1 to width-1 
		generate
			creatbit : gray_bit port map( a_reset, ck, q(i-1),
		                             				     z(i-1), q(i), z(i));
		end generate;
		       
    -- most significant bit
    gray_msb : gray_bit port map( a_reset, ck, q_msb, z(width-1), 
                                  q(width), z(width));
                                 
    -- input signal for MSB
    q_msb <= q(width-1) or q(width);
      
    -- parity bit generation
    process (a_reset, ck)
    begin
        if a_reset='1' then
        	   q(0) <= '1';
        elsif ck'event and ck='1' then
        	  q(0) <= not q(0);
        end if;
    end process;
        
    -- LSB parity bit is always '1'
    z(0) <= '1';
end arch_gray_counter;                      	 	    