-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Trigger.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-16
-- Last update: 2012-05-23
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
use work.KpixLocalPkg.all;
use work.TriggerPkg.all;

entity Trigger is
  
  generic (
    DELAY_G        : time    := 1 ns;
    CLOCK_PERIOD_G : natural := 8);     -- In ns

  port (
    sysClk        : in  sl;
    sysRst        : in  sl;
    ethCmdCntlOut : in  EthCmdCntlOutType;
    kpixLocalOut  : in  KpixLocalOutType;
    extRegsIn     : in  TriggerRegsInType;
    triggerIn     : in  TriggerInType;
    triggerOut    : out TriggerOutType);

end entity Trigger;

architecture rtl of Trigger is

  constant CLOCKS_PER_USEC_C : natural := 1000 / CLOCK_PERIOD_G;

  type RegType is record
    kpixStateSync      : SynchronizerArray(2 downto 0);
    kpixStateStable    : slv(3 downto 0);
    extTriggerSync     : SynchronizerType;
    triggerCounter     : unsigned(log2(CLOCKS_PER_USEC_C)-1 downto 0);
    triggerCountEnable : sl;
    startCounter       : unsigned(3 downto 0);
    startCountEnable   : sl;
    triggerOut         : TriggerOutType;
  end record;

  signal r, rin : RegType;

begin

  sync : process (sysClk, sysRst) is
  begin

    if (rising_edge(sysClk)) then
      r <= rin after DELAY_G;
    end if;
    if (sysRst = '1') then
      r.kpixStateSync             <= (others => SYNCHRONIZER_INIT_0_C) after DELAY_G;
      -- Don't init kpixStateStable so that a shift primative will be created
      r.extTriggerSync            <= SYNCHRONIZER_INIT_0_C             after DELAY_G;
      r.triggerCounter            <= (others => '0')                   after DELAY_G;
      r.triggerCountEnable        <= '0'                               after DELAY_G;
      r.startCounter              <= (others => '0')                   after DELAY_G;
      r.startCountEnable          <= '0'                               after DELAY_G;
      r.triggerOut.trigger        <= '0'                               after DELAY_G;
      r.triggerOut.startAcquire   <= '0'                               after DELAY_G;
      r.triggerOut.startCalibrate <= '0'                               after DELAY_G;
    end if;
  end process sync;

  comb : process (r, ethCmdCntlOut, extRegsIn, triggerIn, kpixLocalOut) is
    variable rVar           : RegType;
    variable acquireModeVar : boolean;
  begin
    rVar := r;

    ------------------------------------------------------------------------------------------------
    -- Synchronize KPIX State to sysClk
    ------------------------------------------------------------------------------------------------
    synchronize(kpixLocalOut.kpixState(2 downto 0), r.kpixStateSync, rVar.kpixStateSync);
    rVar.kpixStateStable := r.kpixStateStable(2 downto 0) & toSl(detectEdge(r.kpixStateSync));
    acquireModeVar       := isZero(rVar.kpixStateStable) and toSlvSync(r.kpixStateSync) = KPIX_ACQUISITION_STATE_C;

    ------------------------------------------------------------------------------------------------
    -- External Trigger
    ------------------------------------------------------------------------------------------------
    synchronize(triggerIn.extTrigger, r.extTriggerSync, rVar.extTriggerSync);
    if (detectRisingEdge(r.extTriggerSync) and extRegsIn.extTriggerEn = '1' and acquireModeVar) then
      rVar.triggerOut.trigger := '1';
      rVar.triggerCountEnable := '1';
      rVar.triggerCounter     := (others => '0');
    end if;

    if (r.triggerCountEnable = '1') then
      rVar.triggerCounter := r.triggerCounter + 1;
      if (r.triggerCounter = CLOCKS_PER_USEC_C) then
        rVar.triggerCounter     := (others => '0');
        rVar.triggerCountEnable := '0';
        rVar.triggerOut.trigger := '0';
      end if;
    end if;

    ------------------------------------------------------------------------------------------------
    -- Acquire Command
    ------------------------------------------------------------------------------------------------
    if (ethCmdCntlOut.cmdEn = '1') then
      if (ethCmdCntlOut.cmdOpCode = TRIGGER_OPCODE_C) then
        rVar.triggerOut.startAcquire   := '1';
        rVar.triggerOut.startCalibrate := extRegsIn.calibrate;
        rVar.startCountEnable          := '1';
        rVar.startCounter              := (others => '0');
      end if;
    end if;


    if (r.startCountEnable = '1') then
      rVar.startCounter := r.startCounter + 1;
      if (r.startCounter = "1111") then
        rVar.startCounter              := (others => '0');
        rVar.startCountEnable          := '0';
        rVar.triggerOut.startAcquire   := '0';
        rVar.triggerOut.startCalibrate := '0';
      end if;
    end if;



    rin        <= rVar;
    triggerOut <= r.triggerOut;
  end process comb;

end architecture rtl;
