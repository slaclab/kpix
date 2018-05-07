-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixLocalPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-22
-- Last update: 2013-07-31
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
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


  -- External Configuration registers
  type KpixLocalRegsInType is record
    debugASel : slv(4 downto 0);
    debugBsel : slv(4 downto 0);
  end record KpixLocalRegsInType;

  constant KPIX_LOCAL_REGS_IN_INIT_C : KpixLocalRegsInType := (
     debugASel => (others => '0'),
     debugBsel => (others => '0'));

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
