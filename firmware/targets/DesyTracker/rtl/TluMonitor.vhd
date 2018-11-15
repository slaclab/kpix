-------------------------------------------------------------------------------
-- Title      : TLU Interface Monitor
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Monitor for a DESY TLU interface
-------------------------------------------------------------------------------
-- This file is part of KPIX. It is subject to
-- the license terms in the LICENSE.txt file found in the top-level directory
-- of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of KPIX, including this file, may be
-- copied, modified, propagated, or distributed except according to the terms
-- contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity TluMonitor is

   generic (
      TPD_G : time := 1 ns);

   port (
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      tluClk     : in sl;
      tluTrigger : in sl;
      tluStart   : in sl;
      tluSpill   : in sl
      );

end entity TluMonitor;

architecture rtl of TluMonitor is



begin


   U_SyncClockFreq_1 : entity work.SyncClockFreq
      generic map (
         TPD_G          => TPD_G,
         REF_CLK_FREQ_G => 200.0E+6,
         REFRESH_RATE_G => 1.0E+3,
--          CLK_LOWER_LIMIT_G => CLK_LOWER_LIMIT_G,
--          CLK_UPPER_LIMIT_G => CLK_UPPER_LIMIT_G,
         COMMON_CLK_G   => true,
         CNT_WIDTH_G    => 32)
      port map (
         freqOut     => tluClkFreq,     -- [out]
         freqUpdated => open,           -- [out]
         locked      => open,           -- [out]
         tooFast     => open,           -- [out]
         tooSlow     => open,           -- [out]
         clkIn       => tluClk,         -- [in]
         locClk      => axilClk,        -- [in]
         refClk      => axilClk);       -- [in]

   U_SynchronizerOneShotCnt_Trigger : entity work.SynchronizerOneShotCnt
      generic map (
         TPD_G         => TPD_G,
         COMMON_CLK_G  => false,
--         RELEASE_DELAY_G => RELEASE_DELAY_G,
         IN_POLARITY_G => '1',
         CNT_WIDTH_G   => 32)
      port map (
         dataIn     => tluTrigger,      -- [in]
         rollOverEn => true,            -- [in]
         cntRst     => r.rstCounts,     -- [in]
         cntOut     => triggerCount,    -- [out]
         wrClk      => tluClk,          -- [in]
         wrRst      => '0',             -- [in]
         rdClk      => axilClk,         -- [in]
         rdRst      => axilRst);        -- [in]

   U_SynchronizerOneShotCnt_Start : entity work.SynchronizerOneShotCnt
      generic map (
         TPD_G         => TPD_G,
         COMMON_CLK_G  => false,
--         RELEASE_DELAY_G => RELEASE_DELAY_G,
         IN_POLARITY_G => '1',
         CNT_WIDTH_G   => 32)
      port map (
         dataIn     => tluStart,        -- [in]
         rollOverEn => true,            -- [in]
         cntRst     => r.rstCounts,     -- [in]
         cntOut     => startCount,      -- [out]
         wrClk      => tluClk,          -- [in]
         wrRst      => '0',             -- [in]
         rdClk      => axilClk,         -- [in]
         rdRst      => axilRst);        -- [in]

   U_SynchronizerOneShotCnt_Spill : entity work.SynchronizerOneShotCnt
      generic map (
         TPD_G         => TPD_G,
         COMMON_CLK_G  => false,
--         RELEASE_DELAY_G => RELEASE_DELAY_G,
         IN_POLARITY_G => '1',
         CNT_WIDTH_G   => 32)
      port map (
         dataIn     => tluSpill,        -- [in]
         rollOverEn => true,            -- [in]
         cntRst     => r.rstCounts,     -- [in]
         cntOut     => startCount,      -- [out]
         wrClk      => tluClk,          -- [in]
         wrRst      => '0',             -- [in]
         rdClk      => axilClk,         -- [in]
         rdRst      => axilRst);        -- [in]

   comb : process (r) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      v := r;

      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegisterR(axilEp, x"00", 0, tluClkFreq);
      axiSlaveRegister(axilEp, x"04", 0, triggerCount);
      axiSlaveRegisterR(axilEp, x"08", 0, spillCount);
      axiSlaveRegisterR(axilEp, x"0C", 0, startCount);
      axiSlaveRegister(axilEp, X"10", 0, v.rstCounts);

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);


      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;


end architecture rtl;
