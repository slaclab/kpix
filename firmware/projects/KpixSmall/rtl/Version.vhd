-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : 
-------------------------------------------------------------------------------
-- File          : Version.vhd
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

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"D0000000";  -- MAKE_VERSION

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
-- 10/11/2012 (0xC000010A): Removed grey decode for temperature
-- 02/12/2013 (0xC000010B): Added chipscope on EthFrontEnd
-- 02/20/2013 (0xC000010C): Added Software Reset function.
-- 05/10/2013 (0xC000010F): Extended precharge clock period register to 12 bits
-- 05/14/2013 (0xC0000110): Fixed precharge clock period bug
-- 05/14/2013 (0xC0000111): Use updated StdLib
-- 07/03/2013 (0xC0000112): Fixed multiple StartAcquire bug, renumbered KpixDataRx register addresses
-- 07/08/2013 (0xC0000113): Moved Trigger module to 200 MHz clock
-- 07/15/2013 (0xD0000000): Fixed multiple StartAcquire bug, renumbered KpixDataRx register addresses
-------------------------------------------------------------------------------

