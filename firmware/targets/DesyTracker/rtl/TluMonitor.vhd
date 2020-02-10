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


library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;


library unisim;
use unisim.vcomponents.all;

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

      ethClk200 : in sl;
      ethRst200 : in sl;

      tluClk     : in sl;
      tluTrigger : in sl;
      tluStart   : in sl;
      tluSpill   : in sl;

      tluClkClean : out sl;

      kpixClk200 : out sl;
      kpixRst200 : out sl);

end entity TluMonitor;

architecture rtl of TluMonitor is

   type RegType is record
      rstCounts      : sl;
      tluClkSel      : sl;
      mmcmResetRise  : sl;
      mmcmReset      : slv(7 downto 0);
      axilWriteSlave : AxiLiteWriteSlaveType;
      axilReadSlave  : AxiLiteReadSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      rstCounts      => '0',
      tluClkSel      => '0',
      mmcmResetRise  => '0',
      mmcmReset      => (others => '0'),
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C,
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal tluClkFreq   : slv(31 downto 0);
   signal triggerCount : slv(31 downto 0);
   signal spillCount   : slv(31 downto 0);
   signal startCount   : slv(31 downto 0);

   signal iTluClkClean  : sl;
   signal tluClk200     : sl;
   signal kpixClk200Loc : sl;
   signal kpixRst200Raw : sl;
   signal mmcmLocked    : sl;

begin

   tluClkClean <= iTluClkClean;

   U_MMCM : entity surf.ClockManager7
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         OUTPUT_BUFG_G     => false,
         FB_BUFG_G         => true,     
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 2,
         -- MMCM attributes
         BANDWIDTH_G       => "OPTIMIZED",
         CLKIN_PERIOD_G    => 25.000,
         DIVCLK_DIVIDE_G   => 1,
         CLKFBOUT_MULT_G   => 25,
         CLKOUT0_DIVIDE_G  => 5,
         CLKOUT1_DIVIDE_G  => 25)
      port map(
         clkIn     => tluClk,
         rstIn     => r.mmcmReset(0),
         locked    => mmcmLocked,
         clkOut(0) => tluClk200,
         clkOut(1) => iTluClkClean);

   CLKMUX : BUFGMUX_CTRL
      port map (
         I0 => ethClk200,
         I1 => tluClk200,
         S  => r.tluClkSel,
         O  => kpixClk200Loc);

   kpixClk200 <= kpixClk200Loc;

   kpixRst200Raw <= axilRst when r.tluClkSel = '0' else not mmcmLocked;

   RstSync_1 : entity surf.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1',
         BYPASS_SYNC_G  => false)
      port map (
         clk      => kpixClk200Loc,
         asyncRst => kpixRst200Raw,
         syncRst  => kpixRst200);

   U_SyncClockFreq_1 : entity surf.SyncClockFreq
      generic map (
         TPD_G          => TPD_G,
         REF_CLK_FREQ_G => 125.0E+6,
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
         clkIn       => iTluClkClean,   -- [in]
         locClk      => axilClk,        -- [in]
         refClk      => axilClk);       -- [in]

   U_SynchronizerOneShotCnt_Trigger : entity surf.SynchronizerOneShotCnt
      generic map (
         TPD_G         => TPD_G,
         COMMON_CLK_G  => false,
--         RELEASE_DELAY_G => RELEASE_DELAY_G,
         IN_POLARITY_G => '1',
         CNT_WIDTH_G   => 32)
      port map (
         dataIn     => tluTrigger,      -- [in]
         rollOverEn => '1',             -- [in]
         cntRst     => r.rstCounts,     -- [in]
         cntOut     => triggerCount,    -- [out]
         wrClk      => iTluClkClean,    -- [in]
         wrRst      => '0',             -- [in]
         rdClk      => axilClk,         -- [in]
         rdRst      => axilRst);        -- [in]

   U_SynchronizerOneShotCnt_Start : entity surf.SynchronizerOneShotCnt
      generic map (
         TPD_G         => TPD_G,
         COMMON_CLK_G  => false,
--         RELEASE_DELAY_G => RELEASE_DELAY_G,
         IN_POLARITY_G => '1',
         CNT_WIDTH_G   => 32)
      port map (
         dataIn     => tluStart,        -- [in]
         rollOverEn => '1',             -- [in]
         cntRst     => r.rstCounts,     -- [in]
         cntOut     => startCount,      -- [out]
         wrClk      => iTluClkClean,    -- [in]
         wrRst      => '0',             -- [in]
         rdClk      => axilClk,         -- [in]
         rdRst      => axilRst);        -- [in]

   U_SynchronizerOneShotCnt_Spill : entity surf.SynchronizerOneShotCnt
      generic map (
         TPD_G         => TPD_G,
         COMMON_CLK_G  => false,
--         RELEASE_DELAY_G => RELEASE_DELAY_G,
         IN_POLARITY_G => '1',
         CNT_WIDTH_G   => 32)
      port map (
         dataIn     => tluSpill,        -- [in]
         rollOverEn => '1',             -- [in]
         cntRst     => r.rstCounts,     -- [in]
         cntOut     => spillCount,      -- [out]
         wrClk      => iTluClkClean,    -- [in]
         wrRst      => '0',             -- [in]
         rdClk      => axilClk,         -- [in]
         rdRst      => axilRst);        -- [in]

   comb : process (axilReadMaster, axilRst, axilWriteMaster, r, spillCount, startCount, tluClkFreq,
                   triggerCount) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      v := r;

      v.mmcmResetRise := '0';
      v.mmcmReset     := '0' & r.mmcmReset(7 downto 1);

      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegisterR(axilEp, x"00", 0, tluClkFreq);
      axiSlaveRegisterR(axilEp, x"04", 0, triggerCount);
      axiSlaveRegisterR(axilEp, x"08", 0, spillCount);
      axiSlaveRegisterR(axilEp, x"0C", 0, startCount);
      axiSlaveRegister(axilEp, X"10", 0, v.rstCounts);
      axiSlaveRegister(axilEp, X"20", 0, v.tluClkSel);
      axiSlaveRegister(axilEp, X"20", 1, v.mmcmResetRise);

      -- Hold mmcmReset for 7 clocks (need at least 3)
      if (v.mmcmResetRise = '1') then
         v.mmcmReset := (others => '1');
      end if;

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
