-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : W-SI
-------------------------------------------------------------------------------
-- File          : OptoVersion.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/10/2010
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module
-------------------------------------------------------------------------------
-- Copyright (c) 2008 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/10/2010: created.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is

constant FpgaVersion : std_logic_vector(31 downto 0) := x"C000002A"; -- MAKE_VERSION

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 03/10/2010 (0xC0000027): Initial Version
-- 04/22/2010 (0xC0000029): Added seperate clock rate for idle.
-------------------------------------------------------------------------------

