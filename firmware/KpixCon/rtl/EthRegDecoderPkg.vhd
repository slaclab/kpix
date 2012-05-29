-------------------------------------------------------------------------------
-- Title      : Ethernet Register Interface Decoder Interface Package
-------------------------------------------------------------------------------
-- File       : EthRegDecoder.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2012-05-24
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

package EthRegDecoderPkg is

  constant NUM_KPIX_MODULES_C : natural := 5;  -- Ugg, fix this somehow



  function assignRegAddrs (start : natural; spacing : natural) return NaturalArray;



end package EthRegDecoderPkg;

package body EthRegDecoderPkg is

  function assignRegAddrs (
    start   : natural;
    spacing : natural)
    return NaturalArray
  is
    variable retVar : NaturalArray(0 to NUM_KPIX_MODULES_C-1);
  begin
    for i in retVar'range loop
      retVar(i) := start + i*spacing;
    end loop;
    return retVar;
  end function assignRegAddrs;

end package body EthRegDecoderPkg;
