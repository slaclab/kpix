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

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"C0000105";  -- MAKE_VERSION

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 05/03/2012 (0xC0000100): Initial Version
-- 06/12/2012 (0xC0000101): Changed row order.
-- 0xC0000105 - Auto Read Disable feature added.
-------------------------------------------------------------------------------

