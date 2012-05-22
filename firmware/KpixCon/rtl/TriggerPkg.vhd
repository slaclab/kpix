
-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : TriggerPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-14
-- Last update: 2012-05-21
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
  
  constant TRIGGER_ACQUIRE_OPCODE_C   : slv(7 downto 0) := "00000001";
  constant TRIGGER_CALIBRATE_OPCODE_C : slv(7 downto 0) := "00000011";

  type TriggerOutType is record
    startAcquire   : sl;
    startCalibrate : sl;
  end record TriggerOutType;

end package TriggerPkg;
