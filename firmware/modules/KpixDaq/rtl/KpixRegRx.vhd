-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-03
-- Last update: 2013-08-01
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
use work.KpixPkg.all;
use work.KpixRegRxPkg.all;

entity KpixRegRx is
   
   generic (
      DELAY_G   : time    := 1 ns;      -- Simulation register delay
      KPIX_ID_G : natural := 0);
   port (
      kpixClk    : in sl;
      kpixClkRst : in sl;

      kpixConfigRegsKpix : in KpixConfigRegsType;
      kpixSerRxIn        : in sl;       -- Serial Data from KPIX

      kpixRegRxOut : out KpixRegRxOutType
      );

end entity KpixRegRx;

architecture rtl of KpixRegRx is

   type StateType is (IDLE_S, CHECK_TYPE_S, REG_RSP_S, BURN_CMD_RSP_FRAME_S, BURN_DATA_FRAME_S);

   type RegType is record
      shiftReg     : slv(0 to KPIX_NUM_TX_BITS_C);
      shiftCount   : unsigned(log2(463)-1 downto 0);
      state        : StateType;
      kpixRegRxOut : KpixRegRxOutType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      shiftReg     => (others => '0'),
      shiftCount   => (others => '0'),
      state        => IDLE_S,
      kpixRegRxOut => KPIX_REG_RX_OUT_INIT_C);

   signal r               : RegType := REG_INIT_C;
   signal rin             : RegType;
   signal kpixSerRxInFall : sl      := '0';

begin

   -- Clock serial input on the falling edge to assure clean signal
   fall : process (kpixClk) is
   begin
      if (falling_edge(kpixClk)) then
         if (kpixClkRst = '1') then
            kpixSerRxInFall <= '0' after DELAY_G;
         else
            kpixSerRxInFall <= kpixSerRxIn after DELAY_G;
         end if;
      end if;
   end process fall;

   seq : process (kpixClk) is
   begin
      if (rising_edge(kpixClk)) then
         if (kpixClkRst = '1') then
            r <= REG_INIT_C after DELAY_G;
         else
            r <= rin after DELAY_G;
         end if;
      end if;
   end process seq;

   comb : process (r, kpixConfigRegsKpix, kpixSerRxInFall, kpixSerRxIn)is
      variable rVar : RegType;
   begin
      rVar := r;

      if (kpixConfigRegsKpix.inputEdge = '0') then
         rVar.shiftReg := r.shiftReg(1 to KPIX_NUM_TX_BITS_C) & kpixSerRxIn;
      else
         rVar.shiftReg := r.shiftReg(1 to KPIX_NUM_TX_BITS_C) & kpixSerRxInFall;
      end if;

      rVar.shiftCount := r.shiftCount + 1;

      rVar.kpixRegRxOut.regValid := '0';


      case (r.state) is
         when IDLE_S =>
            rVar.shiftCount := (others => '0');
            if (r.shiftReg(KPIX_NUM_TX_BITS_C) = '1') then
               -- Got start bit
               rVar.state := CHECK_TYPE_S;
            end if;

         when CHECK_TYPE_S =>
            -- Wait for marker and header.
            -- Determine if data frame or register access
            if (r.shiftCount = 7) then
               -- Valid frame
               if (r.shiftReg(41 to 44) = KPIX_MARKER_C) then
                  -- Command/Rsp Frame
                  if (r.shiftReg(45) = KPIX_CMD_RSP_FRAME_C) then
                     -- Register access
                     if (r.shiftReg(46) = KPIX_REG_ACCESS_C and
                         r.shiftReg(47) = KPIX_READ_C) then
                        -- This is what we are looking for
                        rVar.state := REG_RSP_S;
                     else
                        rVar.state := BURN_CMD_RSP_FRAME_S;
                     end if;
                  else
                     -- Data frame
                     rVar.state := BURN_DATA_FRAME_S;
                  end if;
               else
                  -- Invalid frame, just burn a whole data frame
                  rVar.state := BURN_DATA_FRAME_S;
               end if;
            end if;
            
         when REG_RSP_S =>
            if (r.shiftCount = KPIX_NUM_TX_BITS_C) then
               rVar.state := IDLE_S;
--          if (r.shiftReg(KPIX_MARKER_RANGE_C) = KPIX_MARKER_C and
--              r.shiftReg(KPIX_FRAME_TYPE_INDEX_C) = KPIX_CMD_RSP_FRAME_C and
--              r.shiftReg(KPIX_ACCESS_TYPE_INDEX_C) = KPIX_REG_ACCESS_C and
--              r.shiftReg(KPIX_WRITE_INDEX_C) = KPIX_READ_C) then

               if (bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C)) = KPIX_TEMP_REG_ADDR_C and
                   rVar.kpixRegRxOut.regParityErr = '0') then
                  -- Output Temperature, temp is last 8 bits (reversed and gray encoded.)
                  rVar.kpixRegRxOut.temperature := bitReverse(r.shiftReg(39 to 46));
--            rVar.kpixRegRxOut.temperature := grayDecode(rVar.kpixRegRxOut.temperature);
                  rVar.kpixRegRxOut.tempCount   := slv(unsigned(r.kpixRegRxOut.tempCount) + 1);
               else
                  -- Valid register read response received
                  rVar.kpixRegRxOut.regValid := '1';
               end if;
--          end if;
            end if;

         when BURN_CMD_RSP_FRAME_S =>
            if (r.shiftCount = KPIX_NUM_TX_BITS_C) then
               rVar.state := IDLE_S;
            end if;

         when BURN_DATA_FRAME_S =>
            if (r.shiftCount = 463) then
               rVar.state := IDLE_S;
            end if;
            
      end case;

      if (rVar.kpixRegRxOut.regValid = '1') then
         rVar.kpixRegRxOut.regData      := bitReverse(r.shiftReg(KPIX_DATA_RANGE_C));
         rVar.kpixRegRxOut.regAddr      := bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C));
         -- Parity should be even so oddParity = error
         rVar.kpixRegRxOut.regParityErr := oddParity(r.shiftReg(KPIX_FULL_HEADER_RANGE_C)) or
                                           oddParity(r.shiftReg(KPIX_FULL_DATA_RANGE_C));
      end if;

      rin          <= rVar;
      kpixRegRxOut <= r.kpixRegRxOut;
   end process comb;

end architecture rtl;
