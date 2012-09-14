-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2012-09-10
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
use work.KpixPkg.all;
use work.KpixRegRxPkg.all;

entity KpixRegRx is
  
  generic (
    DELAY_G   : time    := 1 ns;        -- Simulation register delay
    KPIX_ID_G : natural := 0);
  port (
    kpixClk : in sl;
    kpixRst : in sl;

    kpixConfigRegs : in KpixConfigRegsType;
    kpixSerRxIn    : in sl;             -- Serial Data from KPIX

    kpixRegRxOut : out KpixRegRxOutType
    );

end entity KpixRegRx;

architecture rtl of KpixRegRx is

  type StateType is (IDLE_S, OUTPUT_S);

  type RegType is record
    shiftReg     : slv(0 to KPIX_NUM_TX_BITS_C);
    shiftCount   : unsigned(log2(KPIX_NUM_TX_BITS_C)-1 downto 0);
    state        : StateType;
    kpixRegRxOut : KpixRegRxOutType;
  end record RegType;

  signal r, rin          : RegType;
  signal kpixSerRxInFall : sl;

begin

  -- Clock serial input on the falling edge to assure clean signal
  fall : process (kpixClk, kpixRst) is
  begin
    if (kpixRst = '1') then
      kpixSerRxInFall <= '0';
    elsif (falling_edge(kpixClk)) then
      kpixSerRxInFall <= kpixSerRxIn;
    end if;
  end process fall;

  seq : process (kpixClk, kpixRst) is
  begin
    if (kpixRst = '1') then
      r.shiftReg                  <= (others => '0');
      r.shiftCount                <= (others => '0');
      r.state                     <= IDLE_S;
      r.kpixRegRxOut.temperature  <= (others => '0');
      r.kpixRegRxOut.tempCount    <= (others => '0');
      r.kpixRegRxOut.regAddr      <= (others => '0');
      r.kpixRegRxOut.regData      <= (others => '0');
      r.kpixRegRxOut.regValid     <= '0';
      r.kpixRegRxOut.regParityErr <= '0';
    elsif (rising_edge(kpixClk)) then
      r <= rin;

    end if;
  end process seq;

  comb : process (r, kpixConfigRegs, kpixSerRxInFall, kpixSerRxIn)is
    variable rVar : RegType;
  begin
    rVar := r;

    if (kpixConfigRegs.inputEdge = '0') then
      rVar.shiftReg := r.shiftReg(1 to KPIX_NUM_TX_BITS_C) & kpixSerRxIn;
    else
      rVar.shiftReg := r.shiftReg(1 to KPIX_NUM_TX_BITS_C) & kpixSerRxInFall;
    end if;

    rVar.shiftCount := r.shiftCount + 1;

    rVar.kpixRegRxOut.regValid     := '0';
    rVar.kpixRegRxOut.regData      := bitReverse(r.shiftReg(KPIX_DATA_RANGE_C));
    rVar.kpixRegRxOut.regAddr      := bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C));
    -- Parity should be even so oddParity = error
    rVar.kpixRegRxOut.regParityErr := oddParity(r.shiftReg(KPIX_FULL_HEADER_RANGE_C)) or
                                      oddParity(r.shiftReg(KPIX_FULL_DATA_RANGE_C));

    case (r.state) is
      when IDLE_S =>
        rVar.shiftCount := (others => '0');
        if (r.shiftReg(KPIX_NUM_TX_BITS_C) = '1') then
          -- Got start bit
          rVar.state := OUTPUT_S;
        end if;
      when OUTPUT_S =>
        if (r.shiftCount = KPIX_NUM_TX_BITS_C) then
          rVar.state := IDLE_S;
          if (r.shiftReg(KPIX_MARKER_RANGE_C) = KPIX_MARKER_C and
              r.shiftReg(KPIX_FRAME_TYPE_INDEX_C) = KPIX_CMD_RSP_FRAME_C and
              r.shiftReg(KPIX_ACCESS_TYPE_INDEX_C) = KPIX_REG_ACCESS_C and
              r.shiftReg(KPIX_WRITE_INDEX_C) = KPIX_READ_C) then

            if (bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C)) = KPIX_TEMP_REG_ADDR_C and
                rVar.kpixRegRxOut.regParityErr = '0') then
              -- Output Temperature, temp is last 8 bits (reversed and gray encoded.)
              rVar.kpixRegRxOut.temperature := bitReverse(r.shiftReg(39 to 46));  
              rVar.kpixRegRxOut.temperature := grayDecode(rVar.kpixRegRxOut.temperature);
              rVar.kpixRegRxOut.tempCount   := slv(unsigned(r.kpixRegRxOut.tempCount) + 1);
            else
              -- Valid register read response received
              rVar.kpixRegRxOut.regValid := '1';
            end if;
          end if;
        end if;
        
    end case;

    rin          <= rVar;
    kpixRegRxOut <= r.kpixRegRxOut;
  end process comb;

end architecture rtl;
