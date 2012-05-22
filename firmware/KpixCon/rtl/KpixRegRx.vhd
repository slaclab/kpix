-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2012-05-21
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
use work.KpixRegRxPkg.all;

entity KpixRegRx is
  
  generic (
    DELAY_G   : time           := 1 ns;  -- Simulation register delay
    KPIX_ID_G : KpixNumberType := 0);
  port (
    kpixClk : in sl;
    kpixRst : in sl;

    kpixSerRxIn : in sl;                -- Serial Data from KPIX

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

  signal r, rin : RegType;

begin

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

  comb : process (r, kpixSerRxIn) is
    variable tmpVar : RegType;
  begin
    tmpVar := r;

    tmpVar.shiftReg                  := r.shiftReg(1 to KPIX_NUM_TX_BITS_C) & kpixSerRxIn;
    tmpVar.shiftCount                := r.shiftCount + 1;
    
    tmpVar.kpixRegRxOut.regValid     := '0';
    tmpVar.kpixRegRxOut.regData      := bitReverse(r.shiftReg(KPIX_DATA_RANGE_C));
    tmpVar.kpixRegRxOut.regAddr      := bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C));
    -- Parity should be even so oddParity = error
    tmpVar.kpixRegRxOut.regParityErr := oddParity(r.shiftReg(KPIX_FULL_HEADER_RANGE_C)) or
                                        oddParity(r.shiftReg(KPIX_FULL_DATA_RANGE_C));

    case (r.state) is
      when IDLE_S =>
          tmpVar.shiftCount := (others => '0');
        if (r.shiftReg(KPIX_NUM_TX_BITS_C) = '1') then
          -- Got start bit
          tmpVar.state      := OUTPUT_S;
        end if;
      when OUTPUT_S =>
        if (r.shiftCount = KPIX_NUM_TX_BITS_C) then
          tmpVar.state := IDLE_S;
          if (r.shiftReg(KPIX_MARKER_RANGE_C) = KPIX_MARKER_C and
              r.shiftReg(KPIX_FRAME_TYPE_INDEX_C) = KPIX_CMD_RSP_FRAME_C and
              r.shiftReg(KPIX_ACCESS_TYPE_INDEX_C) = KPIX_REG_ACCESS_C and
              r.shiftReg(KPIX_WRITE_INDEX_C) = KPIX_READ_C) then

            if (tmpVar.kpixRegRxOut.regAddr = KPIX_TEMP_REG_ADDR_C and
                tmpVar.kpixRegRxOut.regParityErr = '0') then
              -- Output Temperature
              tmpVar.kpixRegRxOut.temperature := tmpVar.kpixRegRxOut.regData;
              tmpVar.kpixRegRxOut.tempCount   := slv(unsigned(r.kpixRegRxOut.tempCount) + 1);
            else
              -- Valid register read response received
--              tmpVar.kpixRegRxOut.regAddr    := bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C));
--              tmpVar.kpixRegRxOut.regData    := bitReverse(r.shiftReg(15 to 46));
              tmpVar.kpixRegRxOut.regValid := '1';
            end if;
          end if;
        end if;
        
    end case;

    rin                         <= tmpVar;
    kpixRegRxOut                <= r.kpixRegRxOut;
  end process comb;

end architecture rtl;
