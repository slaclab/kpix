-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2012-07-03
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

package KpixRegCntlPkg is

  -- I know, it's silly to define a whole package just for this.
  -- But it follows the same convention as the other ethernet registers.
  -- Also, it makes it easy to add more registers in the future.
--  type KpixRegCntlRegsInType is record
--    kpixReset : sl;
--  end record KpixRegCntlRegsInType;
  
end package KpixRegCntlPkg;

