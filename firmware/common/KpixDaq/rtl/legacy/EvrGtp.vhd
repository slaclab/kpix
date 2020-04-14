-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : EvrGtp.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-07-12
-- Last update: 2020-04-13
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

library kpix;
use kpix.EvrCorePkg.all;

entity EvrGtp is

   generic (
      TPD_G : time := 1 ns);

   port (
      gtpRefClkP : in  sl;
      gtpRefClkN : in  sl;
      gtpRxP     : in  sl;
      gtpRxN     : in  sl;
      evrOut     : out EvrOutType;

      sysClk          : in  sl;
      sysRst          : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

--       evrConfigIntfIn  : in  EvrConfigIntfInType;
--       evrConfigIntfOut : out EvrConfigIntfOutType;
      sysEvrOut : out EvrOutType        -- Decoded EVR data sync'd to sysclk
      );

end entity EvrGtp;

architecture rtl of EvrGtp is

   signal gtpRefClkIn  : sl;
   signal evrRecClk    : sl;
   signal evrRst       : sl;
   signal phy          : EvrPhyType;
   signal gtpRxAligned : sl;

begin

   IBUFDS_EVR_REF_CLK : IBUFDS
      port map (
         I  => gtpRefClkP,
         IB => gtpRefClkN,
         O  => gtpRefClkIn);

   Gtp16FixedLatCore_1 : entity surf.Gtp16FixedLatCore
      generic map (
         TPD_G           => TPD_G,
         SIM_PLL_PERDIV2 => X"0C8",
         CLK25_DIVIDER   => 10,
         PLL_DIVSEL_FB   => 2,
         PLL_DIVSEL_REF  => 2,
         REC_CLK_PERIOD  => 4.202,
         REC_PLL_MULT    => 4,
         REC_PLL_DIV     => 1)
      port map (
         gtpClkIn         => gtpRefClkIn,
         gtpRefClkOut     => open,
         gtpRxN           => gtpRxN,
         gtpRxP           => gtpRxP,
         gtpTxN           => open,
         gtpTxP           => open,
         gtpReset         => sysRst,    -- I think this will work
         gtpResetDone     => open,
         gtpPllLockDet    => open,
         gtpLoopback      => '0',
         gtpRxReset       => '0',
         gtpRxCdrReset    => '0',
         gtpRxElecIdle    => open,
         gtpRxElecIdleRst => '0',
         gtpRxUsrClk      => open,
         gtpRxUsrClk2     => evrRecClk,
         gtpRxUsrClkRst   => open,
         gtpRxData        => phy.rxData,
         gtpRxDataK       => phy.rxDataK,
         gtpRxDecErr      => phy.decErr,
         gtpRxDispErr     => phy.dispErr,
         gtpRxPolarity    => '0',
         gtpRxAligned     => gtpRxAligned,
         gtpTxReset       => sysRst,
         gtpTxUsrClk      => '0',
         gtpTxUsrClk2     => '0',
         gtpTxAligned     => open,
         gtpTxData        => (others => '0'),
         gtpTxDataK       => (others => '0'));

   -- Use aligned signal as reset for evrRecClk logic
   RstSync_1 : entity surf.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => evrRecClk,
         asyncRst => gtpRxAligned,
         syncRst  => evrRst);

   EvrCore_1 : entity kpix.EvrCore
      generic map (
         TPD_G => TPD_G)
      port map (
         evrRecClk       => evrRecClk,
         evrRst          => evrRst,
         phyIn           => phy,
         evrOut          => evrOut,
         sysClk          => sysClk,
         sysRst          => sysRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         sysEvrOut       => sysEvrOut);

end architecture rtl;
