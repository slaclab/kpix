-------------------------------------------------------------------------------
-- Title      : Kpix Clock Generator
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Controls generation of the KPIX clock by dividing a 200MHz
-- reference clock. Can set a different clock rate for each state in the
-- KPIX acquisition cycle.
-------------------------------------------------------------------------------
-- This file is part of 'KPIX'
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
use surf.AxiLitePkg.all;


library kpix;
use kpix.KpixPkg.all;
use kpix.KpixLocalPkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity KpixClockGen is

   generic (
      TPD_G : time := 1 ns);

   port (
      clk200 : in sl;
      rst200 : in sl;

      -- AXI-Lite interface for registers
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      acqControl : in AcquisitionControlType;
      kpixState  : in KpixStateOutType;

      -- Generated Kpix clock and various enable strobes
      kpixClk        : out sl;
      kpixClkPreRise : out sl;
      kpixClkPreFall : out sl;
      kpixClkSample  : out sl;
      kpixClkOutput  : out sl);

end entity KpixClockGen;

architecture rtl of KpixClockGen is

   constant CLK_SEL_READOUT_DEFAULT_C   : slv(7 downto 0)  := X"20";
   constant CLK_SEL_DIGITIZE_DEFAULT_C  : slv(7 downto 0)  := X"21";
   constant CLK_SEL_ACQUIRE_DEFAULT_C   : slv(7 downto 0)  := X"22";
   constant CLK_SEL_IDLE_DEFAULT_C      : slv(7 downto 0)  := X"23";
   constant CLK_SEL_PRECHARGE_DEFAULT_C : slv(11 downto 0) := X"024";

   -- Kpix Clock registers run on 200 MHz clock
   type RegType is record
      -- Config registers
      clkSelReadout    : slv(7 downto 0);
      clkSelDigitize   : slv(7 downto 0);
      clkSelAcquire    : slv(7 downto 0);
      clkSelIdle       : slv(7 downto 0);
      clkSelPrecharge  : slv(11 downto 0);
      sampleDelay      : slv(7 downto 0);
      sampleOnRise     : sl;
      outputDelay      : slv(7 downto 0);
      outputOnRise     : sl;
      axilWriteSlave   : AxiLiteWriteSlaveType;
      axilReadSlave    : AxiLiteReadSlaveType;
      -- Logic registers
      startAcquireLast : sl;
      divCount         : slv(11 downto 0);
      clkSel           : slv(11 downto 0);
      clkDiv           : sl;
      preRise          : sl;
      preFall          : sl;
      sample           : sl;
      output           : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      clkSelReadout    => CLK_SEL_READOUT_DEFAULT_C,
      clkSelDigitize   => CLK_SEL_DIGITIZE_DEFAULT_C,
      clkSelAcquire    => CLK_SEL_ACQUIRE_DEFAULT_C,
      clkSelIdle       => CLK_SEL_IDLE_DEFAULT_C,
      clkSelPrecharge  => CLK_SEL_PRECHARGE_DEFAULT_C,
      sampleDelay      => X"00",
      sampleOnRise     => '0',
      outputDelay      => X"00",
      outputOnRise     => '0',
      axilWriteSlave   => AXI_LITE_WRITE_SLAVE_INIT_C,
      axilReadSlave    => AXI_LITE_READ_SLAVE_INIT_C,
      startAcquireLast => '0',
      divCount         => (others => '0'),
      clkSel           => (others => '0'),
      clkDiv           => '0',
      preRise          => '0',
      preFall          => '0',
      sample           => '0',
      output           => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;


begin

   seq : process (clk200) is
   begin
      if (rising_edge(clk200)) then
         r <= rin after TPD_G;
      end if;
   end process seq;


   comb : process (acqControl, axilReadMaster, axilWriteMaster, kpixState, r, rst200) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      v := r;

      ----------------------------------------------------------------------------------------------
      -- AXI Lite registers
      ----------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"00", 0, v.clkSelReadout);
      axiSlaveRegister(axilEp, x"04", 0, v.clkSelDigitize);
      axiSlaveRegister(axilEp, X"08", 0, v.clkSelAcquire);
      axiSlaveRegister(axilEp, X"0C", 0, v.clkSelIdle);
      axiSlaveRegister(axilEp, X"10", 0, v.clkSelPrecharge);
      axiSlaveRegister(axilEp, X"14", 0, v.sampleDelay);
      axiSlaveRegister(axilEp, X"14", 31, v.sampleOnRise);
      axiSlaveRegister(axilEp, X"18", 0, v.outputDelay);
      axiSlaveRegister(axilEp, X"18", 31, v.outputOnRise);

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);
      ----------------------------------------------------------------------------------------------
      -- Clock generation
      ----------------------------------------------------------------------------------------------
      v.startAcquireLast := acqControl.startAcquire;
      v.preRise          := '0';
      v.preFall          := '0';
      v.sample           := '0';
      v.output           := '0';

      v.divCount := r.divCount + 1;

      if (r.divCount = r.clkSel) then
         -- Invert clock every time divCount reaches clkSel
         v.divCount := (others => '0');
         v.clkDiv   := not r.clkDiv;

         -- Assign new clkSel dependant on kpixState
         if (kpixState.analogState = KPIX_ANALOG_DIG_STATE_C and kpixState.prechargeBus = '1') then
            v.clkSel := r.clkSelPrecharge;
         elsif (kpixState.analogState = KPIX_ANALOG_PRE_STATE_C or
                kpixState.analogState = KPIX_ANALOG_SAMP_STATE_C or
                kpixState.analogState = KPIX_ANALOG_PAUSE_STATE_C) then
            v.clkSel := "0000" & r.clkSelAcquire;
         elsif (kpixState.analogState = KPIX_ANALOG_DIG_STATE_C) then
            v.clkSel := "0000" & r.clkSelDigitize;
         elsif (kpixState.readoutState /= KPIX_READOUT_IDLE_STATE_C) then
            v.clkSel := "0000" & r.clkSelReadout;
         else
            v.clkSel := "0000" & r.clkSelIdle;
         end if;
      end if;

      -- Create preRise, preFall strobes
      -- pre-rise must come a bit early because kpix always samples on the rising edge
      if (r.divCount = r.clkSel - 3) then
         v.preRise := not r.clkDiv;
      end if;

      if (r.divCount = r.clkSel -1) then
         v.preFall := r.clkDiv;
      end if;

      -- Create sample point strobe
      if (r.divCount = r.sampleDelay) then
         v.sample := (r.sampleOnRise xnor r.clkDiv);
      end if;

      -- Create output strobe
      if (r.divCount = r.outputDelay) then
         v.output := (r.outputOnRise xnor r.clkDiv);
      end if;

      -- startAcquire effectively resets kpix clock to ensure fixed time between acquire pulse and command
      if (acqControl.startAcquire = '1' and r.startAcquireLast = '0') then
         v.divCount := (others => '0');
         v.clkDiv   := '0';
      end if;

      -- Synchronous Reset
      if (rst200 = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      -- Assign outputs
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;
      kpixClkPreRise <= r.preRise;
      kpixClkPreFall <= r.preFall;
      kpixClkSample  <= r.sample;
      kpixClkOutput  <= r.output;
   end process comb;

   -- Use BUFG for kpixClk
   KPIX_CLK_BUFG : BUFG
      port map (
         I => r.clkDiv,
         O => kpixClk);

end architecture rtl;
