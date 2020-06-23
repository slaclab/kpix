-------------------------------------------------------------------------------
-- Title      : KPIX Register Response Deserializer
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Deserializes KPIX register response serial stream.
-------------------------------------------------------------------------------
-- This file is part of 'KPIX'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'KPIX', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library surf;
use surf.StdRtlPkg.all;


library kpix;
use kpix.KpixPkg.all;
use kpix.KpixRegRxPkg.all;

entity KpixRegRx is

   generic (
      TPD_G     : time    := 1 ns;      -- Simulation register delay
      KPIX_ID_G : natural := 0);
   port (
      clk200         : in  sl;
      rst200         : in  sl;
      sysConfig      : in  SysConfigType;
      -- Kpix clock info
      kpixClkPreRise : in  sl;
      kpixClkPreFall : in  sl;
      kpixClkSample  : in  sl;
      kpixSerRxIn    : in  sl;          -- Serial Data from KPIX      
      kpixRegRxOut   : out KpixRegRxOutType
      );

end entity KpixRegRx;

architecture rtl of KpixRegRx is

   type StateType is (IDLE_S, CHECK_TYPE_S, REG_RSP_S, BURN_CMD_RSP_FRAME_S, BURN_DATA_FRAME_S);

   type RegType is record
      shiftReg     : slv(0 to KPIX_NUM_TX_BITS_C);
      shiftCount   : slv(log2(463)-1 downto 0);
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

   comb : process (kpixClkSample, kpixSerRxIn, r, rst200)is
      variable v : RegType;
   begin
      v := r;

      if (kpixClkSample = '1') then

         v.shiftReg              := r.shiftReg(1 to KPIX_NUM_TX_BITS_C) & kpixSerRxIn;
         v.shiftCount            := r.shiftCount + 1;
         v.kpixRegRxOut.regValid := '0';

         case (r.state) is
            when IDLE_S =>
               v.shiftCount := (others => '0');
               if (r.shiftReg(KPIX_NUM_TX_BITS_C) = '1') then
                  -- Got start bit
                  v.state := CHECK_TYPE_S;
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
                           v.state := REG_RSP_S;
                        else
                           v.state := BURN_CMD_RSP_FRAME_S;
                        end if;
                     else
                        -- Data frame
                        v.state := BURN_DATA_FRAME_S;
                     end if;
                  else
                     -- Invalid frame, just burn a whole data frame
                     v.state := BURN_DATA_FRAME_S;
                  end if;
               end if;

            when REG_RSP_S =>
               if (r.shiftCount = KPIX_NUM_TX_BITS_C) then
                  v.state := IDLE_S;
                  if (bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C)) = KPIX_TEMP_REG_ADDR_C and
                      v.kpixRegRxOut.regParityErr = '0') then
                     -- Output Temperature, temp is last 8 bits (reversed and gray encoded.)
                     v.kpixRegRxOut.temperature := bitReverse(r.shiftReg(39 to 46));
                     v.kpixRegRxOut.tempCount   := r.kpixRegRxOut.tempCount + 1;
                  else
                     -- Valid register read response received
                     v.kpixRegRxOut.regValid := '1';
                  end if;
               end if;

            when BURN_CMD_RSP_FRAME_S =>
               if (r.shiftCount = KPIX_NUM_TX_BITS_C) then
                  v.state := IDLE_S;
               end if;

            when BURN_DATA_FRAME_S =>
               if (r.shiftCount = 463) then
                  v.state := IDLE_S;
               end if;

         end case;

         if (v.kpixRegRxOut.regValid = '1') then
            v.kpixRegRxOut.regData      := bitReverse(r.shiftReg(KPIX_DATA_RANGE_C));
            v.kpixRegRxOut.regAddr      := bitReverse(r.shiftReg(KPIX_CMD_ID_REG_ADDR_RANGE_C));
            -- Parity should be even so oddParity = error
            v.kpixRegRxOut.regParityErr := oddParity(r.shiftReg(KPIX_FULL_HEADER_RANGE_C)) or
                                           oddParity(r.shiftReg(KPIX_FULL_DATA_RANGE_C));
         end if;
      end if;

      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      rin          <= v;
      kpixRegRxOut <= r.kpixRegRxOut;

   end process comb;

   seq : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end architecture rtl;
