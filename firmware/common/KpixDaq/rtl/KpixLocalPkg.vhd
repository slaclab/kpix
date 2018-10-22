-------------------------------------------------------------------------------
-- Title      : KpixLocal Support Package
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Provides constants for KpixLocal module
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
use work.StdRtlPkg.all;

package KpixLocalPkg is

  constant KPIX_IDLE_STATE_C         : slv(2 downto 0) := "000";
  constant KPIX_ACQUISITION_STATE_C  : slv(2 downto 0) := "001";
  constant KPIX_DIGITIZATION_STATE_C : slv(2 downto 0) := "010";
  constant KPIX_READOUT_STATE_C      : slv(2 downto 0) := "100";
  constant KPIX_PRECHARGE_STATE_C    : slv(3 downto 0) := "1010";

  -- Analog States
  constant KPIX_ANALOG_IDLE_STATE_C  : slv(2 downto 0) := "000";  -- Idle time
  constant KPIX_ANALOG_PRE_STATE_C   : slv(2 downto 0) := "001";  -- Pre-Sample
  constant KPIX_ANALOG_SAMP_STATE_C  : slv(2 downto 0) := "011";  -- Sample
  constant KPIX_ANALOG_PAUSE_STATE_C : slv(2 downto 0) := "010";  -- Pause
  constant KPIX_ANALOG_DIG_STATE_C   : slv(2 downto 0) := "110";  -- Digitize
  constant KPIX_ANALOG_READ_STATE_C  : slv(2 downto 0) := "100";  -- Read

  -- Readout States
  constant KPIX_READOUT_IDLE_STATE_C      : slv(2 downto 0) := "000";  -- Idle Time
  constant KPIX_READOUT_PRECHARGE_STATE_C : slv(2 downto 0) := "001";  -- Precharge Bus
  constant KPIX_READOUT_HEADER_STATE_C    : slv(2 downto 0) := "011";  -- Send Header
  constant KPIX_READOUT_DATA_STATE_C      : slv(2 downto 0) := "010";  -- Send Data
  constant KPIX_READOUT_SHIFT_STATE_C     : slv(2 downto 0) := "110";  -- Shift row/word select
  constant KPIX_REAOUT_DONE_STATE_C       : slv(2 downto 0) := "111";  -- Done With Readout


  -- Kpix Local outputs that are synchronous with sysClk
  type KpixStateOutType is record
    analogState  : slv(2 downto 0);
    readoutState : slv(2 downto 0);
    prechargeBus : sl;
    bunchCount   : slv(12 downto 0);
    subCount     : slv(2 downto 0);
    trigInhibit  : sl;
  end record KpixStateOutType;

end package KpixLocalPkg;
