-------------------------------------------------------------------------------
-- Title         : Upstream Data Buffer
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : UsBuff16.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 07/22/2013
-------------------------------------------------------------------------------
-- Description:
-- VHDL source file for buffer block for upstream data.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 07/22/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.VcPkg.all;

entity VcUsBuff64Kpix is
   generic (
      TPD_G              : time                       := 1 ns;
      GEN_SYNC_FIFO_G    : boolean                    := false;
      BRAM_EN_G          : boolean                    := true;
      FIFO_ADDR_WIDTH_G  : integer range 4 to 48      := 9;
      USE_DSP48_G        : string                     := "no";
      ALTERA_RAM_G       : string                     := "M-RAM";
      FIFO_SYNC_STAGES_G : integer range 2 to (2**24) := 2;
      FIFO_INIT_G        : slv                        := "0";
      FIFO_FULL_THRES_G  : integer range 1 to (2**24) := 1;
      FIFO_EMPTY_THRES_G : integer range 0 to (2**24) := 0);
   port (
      -- TX VC Signals (vcTxClk domain)
      vcTxIn               : out VcTxInType;
      vcTxOut              : in  VcTxOutType;
      vcRxOut_remBuffAFull : in  sl;
      vcRxOut_remBuffFull  : in  sl;
      -- UP signals  (locClk domain)
      usBuff64In           : in  VcUsBuff64InType;
      usBuff64Out          : out VcUsBuff64OutType;
      -- Local clock and resets
      locClk               : in  sl;
      locSyncRst           : in  sl := '0';
      locAsyncRst          : in  sl := '0';
      -- VC Tx Clock And Resets
      vcTxClk              : in  sl;
      vcTxSyncRst          : in  sl := '0';
      vcTxAsyncRst         : in  sl := '0');      
end VcUsBuff64Kpix;

architecture rtl of VcUsBuff64Kpix is

   constant RD_DATA_WIDTH_C : integer := 18;

   -- Local Signals
   signal fifoDin   : slv(71 downto 0);
   signal fifoDout  : slv(RD_DATA_WIDTH_C-1 downto 0);
   signal fifoRd    : sl;
   signal fifoValid : sl;
   signal fifoEmpty : sl;
   signal fifoOverflow : sl;

begin

   fifoDin(69 downto 54) <= usBuff64In.data(63 downto 48);
   fifoDin(51 downto 36) <= usBuff64In.data(47 downto 32);
   fifoDin(33 downto 18) <= usBuff64In.data(31 downto 16);
   fifoDin(15 downto 0)  <= usBuff64In.data(15 downto 0);

   -- Kpix software expects that the tail word is 32 bits long, so place EOF at second word.
   -- Final 2 words get special code so they get bled off without being output on VC
   fifoDin(71 downto 70) <= usBuff64In.sof & "0";
   fifoDin(53 downto 52) <= "0" & usBuff64In.eof;
   fifoDin(35 downto 34) <= usBuff64In.eof & usBuff64In.eof;
   fifoDin(17 downto 16) <= usBuff64In.eof & usBuff64In.eof;

   FifoMux_1 : entity work.FifoMux
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => GEN_SYNC_FIFO_G,
         BRAM_EN_G       => BRAM_EN_G,
         FWFT_EN_G       => true,
         USE_DSP48_G     => USE_DSP48_G,
         WR_DATA_WIDTH_G => 72,
         RD_DATA_WIDTH_G => RD_DATA_WIDTH_C,
         LITTLE_ENDIAN_G => false,
         ADDR_WIDTH_G    => FIFO_ADDR_WIDTH_G,
         INIT_G          => FIFO_INIT_G,
         FULL_THRES_G    => FIFO_FULL_THRES_G,
         EMPTY_THRES_G   => FIFO_EMPTY_THRES_G)
      port map (
         rst          => locAsyncRst,
         srst         => locSyncRst,
         wr_clk       => locClk,
         wr_en        => usBuff64In.valid,
         din          => fifoDin,
         wr_ack       => usBuff64Out.wrAck,
         overflow     => fifoOverflow,
         prog_full    => usBuff64Out.progFull,
         almost_full  => usBuff64Out.almostFull,
         full         => usBuff64Out.full,
         rd_clk       => vcTxClk,
         rd_en        => fifoRd,
         dout         => fifoDout,
         valid        => fifoValid,
         underflow    => open,
         prog_empty   => open,
         almost_empty => open,
         empty        => fifoEmpty);
   
   usBuff64Out.overflow <= fifoOverflow;

   -- Automatically read when data is valid and VC is ready to receive it and remote buffer is not full
   fifoRd <= fifoValid and vcTxOut.ready and not vcRxOut_remBuffFull and not vcRxOut_remBuffAFull and
             (fifoDout(17) nand fifoDout(16));  -- Blead out if both bits set

   vcTxIn.valid <= fifoValid and not vcRxOut_remBuffFull and not vcRxOut_remBuffAFull and
                   (fifoDout(17) nand fifoDout(16));

   vcTxIn.sof <= '1' when fifoDout(17 downto 16) = "10" else '0';
   vcTxIn.eof  <= '1' when fifoDout(17 downto 16) = "01" else '0';
   
   vcTxIn.eofe <= fifoOverflow;         -- This is crossing a clock boundary and probably doesn't
                                        -- even work

   -- Assign data based on lane generics
   vcTxIn.data(0) <= fifoDout(15 downto 0);

   zeroLoop : for i in 3 downto 1 generate
      vcTxIn.data(i) <= (others => '0');
   end generate zeroLoop;

end rtl;
