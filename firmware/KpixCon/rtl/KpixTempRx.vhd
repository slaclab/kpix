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
use work.SynchronizePkg.all;
use work.EthFrontEndPkg.all;
use work.KpixPkg.all;
use work.KpixTempRxPkg.all;

entity KpixTempRx is
  
  generic (
    DELAY_G   : time           := 1 ns;  -- Simulation register delay
    KPIX_ID_G : KpixNumberType := 0);    -- Not reall needed
  port (
    kpixClk       : in  sl;
    kpixRst       : in  sl;
    kpixSerRxIn   : in  sl;              -- Serial Data from KPIX
    kpixTempRxOut : out KpixTempRxOutType
    );

end entity KpixTempRx;

architecture rtl of KpixTempRx is

  type StateType is (IDLE_S, OUTPUT_S);

  type RegType is record
    shiftReg      : slv(0 to 48);
    shiftCount    : unsigned(5 downto 0);
    state         : StateType;
    kpixTempRxOut : KpixTempRxOutType;
  end record RegType;

  signal r, rin : RegType;

begin

  seq : process (kpixClk, kpixRst) is
  begin
    if (kpixRst = '1') then
      r.shiftReg                  <= (others => '0');
      r.shiftCount                <= (others => '0');
      r.state                     <= IDLE_S;
      r.kpixTempRxOut.temperature <= (others => '0');
      r.kpixTempRxOut.tempCount   <= (others => '0');
    elsif (rising_edge(kpixClk)) then
      r <= rin;
    end if;
  end process seq;

  comb : process (r, kpixSerRxIn) is
    variable rVar : RegType;
  begin
    rVar := r;

    rVar.shiftReg   := r.shiftReg(1 to 48) & kpixSerRxIn;
    rVar.shiftCount := r.shiftCount + 1;

    case (r.state) is
      when IDLE_S =>
        rVar.shiftCount := (others => '0');
        if (r.shiftReg(47) = '1') then
          -- Got start bit
          rVar.state := OUTPUT_S;
        end if;
      when OUTPUT_S =>
        if (r.shiftCount = 47) then
          rVar.state := IDLE_S;
--          if (r.shiftReg(KPIX_MARKER_RANGE_C) = KPIX_MARKER_C and
--              r.shiftReg(KPIX_FRAME_TYPE_INDEX_C) = KPIX_CMD_RSP_FRAME_C and
--              r.shiftReg(KPIX_ACCESS_TYPE_INDEX_C) = KPIX_REG_ACCESS_C and
--              r.shiftReg(KPIX_WRITE_INDEX_C) = KPIX_READ_C and
--              r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C) = bitReverse(KPIX_TEMP_REG_ADDR_C) and
--              evenParity(r.shiftReg(KPIX_FULL_HEADER_RANGE_C)) = '1' and
--              evenParity(r.shiftReg(KPIX_FULL_DATA_RANGE_C)) = '1') then
          if (r.shiftReg(0 to 14) = "010101011100000") then


            -- Output Temperature
            rVar.kpixTempRxOut.temperature := bitReverse(r.shiftReg(15 to 46));
--            rVar.kpixTempRxOut.temperature := r.shiftReg(KPIX_DATA_RANGE_C);
            rVar.kpixTempRxOut.tempCount   := slv(unsigned(r.kpixTempRxOut.tempCount) + 1);
          end if;
        end if;
    end case;

    rin <= rVar;

    kpixTempRxOut <= r.kpixTempRxOut;

  end process comb;



end architecture rtl;
