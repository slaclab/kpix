-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-10
-- Last update: 2012-05-18
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

package KpixRegRxPkg is

  type KpixRegRxOutType is record
    temperature  : slv(31 downto 0);
    tempCount    : slv(9 downto 0);
    regAddr      : slv(6 downto 0);     
    regData      : slv(31 downto 0);
    regValid     : sl;
    regParityErr : sl;
  end record KpixRegRxOutType;

  type KpixRegRxOutArray is array (natural range <>) of KpixRegRxOutType;

end package KpixRegRxPkg;
