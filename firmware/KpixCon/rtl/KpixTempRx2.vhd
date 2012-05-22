-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2012-05-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;

entity KpixTempRx2 is
  port (
    kpixClk     : in  sl;
    kpixRst     : in  sl;
    kpixSerRxIn : in  sl;               -- Serial Data from KPIX
    temperature : out slv(31 downto 0);
    tempCount   : out slv(9 downto 0)
    );

end entity KpixTempRx2;

architecture rtl of KpixTempRx2 is

  signal state        : sl;
  signal shiftReg     : slv(0 to 47);
  signal shiftCount   : unsigned(5 downto 0);
  signal tempCountInt : unsigned(9 downto 0);

begin

  tempCount <= slv(tempCountInt);

  seq : process (kpixClk, kpixRst) is
  begin
    if (kpixRst = '1') then
      shiftReg     <= (others => '0');
      shiftCount   <= (others => '0');
      state        <= '0';
      temperature  <= (others => '0');
      tempCountInt <= (others => '0');
    elsif (rising_edge(kpixClk)) then
--      temperature  <= temperature;
--      tempCountInt <= tempCountInt;
--      state        <= state;
      
      if (state = '0') then
        shiftCount <= (others => '0');
        if (shiftReg(47) = '1') then
          state <= '1';
        end if;
      else
        if (shiftCount = 47) then
          state <= '0';
          if (shiftReg(0 to 14) = "010101011100000") then
            temperature  <= bitReverse(shiftReg(15 to 46));
            tempCountInt <= tempCountInt + 1;
          end if;
        end if;
        shiftCount <= shiftCount + 1;
      end if;
      shiftReg <= shiftReg(1 to 47) & kpixSerRxIn;
    end if;
  end process seq;

end architecture rtl;
