-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : W-SI
-------------------------------------------------------------------------------
-- File          : KpixConVersion.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 07/07/2010
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 07/07/2010: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package Version is

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"C000010D";  -- MAKE_VERSION

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 09/28/2012 (0xC000010A): Initial version. Removed grey decode for temperature
-- 03/19/2013 (0xC000010C): Updated for latest board schematic. Added software reset function.
-- 03/28/2013 (0xC000010D): Acquire command no longer sent to disabled kpixes.
-------------------------------------------------------------------------------

