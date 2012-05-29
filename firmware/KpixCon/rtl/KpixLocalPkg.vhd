-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : KpixLocalPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-22
-- Last update: 2012-05-22
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

  type KpixLocalRegsInType is record
    debugASel : slv(4 downto 0);
    debugBsel : slv(4 downto 0);
  end record KpixLocalRegsInType;

  type KpixLocalOutType is record
    kpixState : slv(3 downto 0);
  end record KpixLocalOutType;

end package KpixLocalPkg;
