
-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : TriggerPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-14
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

package TriggerPkg is

   constant TRIGGER_OPCODE_C : slv(7 downto 0) := "00000000";

   constant TRIGGER_ACQUIRE_C   : sl := '0';
   constant TRIGGER_CALIBRATE_C : sl := '1';

   constant TRIGGER_ACQ_SOFTWARE_C : slv(1 downto 0) := "00";
   constant TRIGGER_ACQ_EVR_C      : slv(1 downto 0) := "01";
   constant TRIGGER_ACQ_CMOSA_C    : slv(1 downto 0) := "10";
   constant TRIGGER_ACQ_NIMA_C     : slv(1 downto 0) := "11";

   type TriggerRegsInType is record
      extTriggerSrc   : slv(2 downto 0);
      extTimestampSrc : slv(2 downto 0);
      acquisitionSrc  : slv(1 downto 0);
      calibrate       : sl;
   end record TriggerRegsInType;

   constant TRIGGER_REGS_IN_INIT_C : TriggerRegsInType := (
      extTriggerSrc   => (others => '0'),
      extTimestampSrc => (others => '0'),
      acquisitionSrc  => (others => '0'),
      calibrate       => '0');

   type TriggerExtInType is record
      nimA  : sl;
      nimB  : sl;
      cmosA : sl;
      cmosB : sl;
   end record TriggerExtInType;

   type TriggerOutType is record
      trigger        : sl;
      startAcquire   : sl;
      startCalibrate : sl;
      startReadout   : sl;
   end record TriggerOutType;

   constant TRIGGER_OUT_INIT_C : TriggerOutType := (
      trigger        => '0',
      startAcquire   => '0',
      startCalibrate => '0',
      startReadout   => '0');

   type TimestampOutType is record
      bunchCount : slv(12 downto 0);
      subCount   : slv(2 downto 0);
      valid      : sl;
   end record TimestampOutType;

   type TimestampInType is record
      rdEn : sl;
   end record TimestampInType;

end package TriggerPkg;
