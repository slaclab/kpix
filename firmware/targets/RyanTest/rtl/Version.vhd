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
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 07/07/2010: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package Version is

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"C000010B";  -- MAKE_VERSION

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 05/03/2012 (0xC0000100): Initial Version
-- 06/12/2012 (0xC0000101): Changed row order.
-- 07/12/2012 (0xC0000105): Added timestamp support. Bugfixes.
-- 07/13/2012 (0xC0000106): Trigger no longer sync'd to kpixClk.
-- 08/08/2012 (0xC0000107): Fixed temperature readout at end of data acquisition
-- 08/14/2012 (0xC0000108): Rebuilt with latest KpixCore (no actual changes)
-- 09/17/2012 (0xC0000109): Fixed temperature readback bug, kpix register access bug.
-- 10A - Removed grey decode for temperature
-------------------------------------------------------------------------------

