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

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"D0000005";  -- MAKE_VERSION

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 09/28/2012 (0xC000010A): Initial version. Removed grey decode for temperature
-- 03/19/2013 (0xC000010C): Updated for latest board schematic. Added software reset function.
-- 03/28/2013 (0xC000010D): Acquire command no longer sent to disabled kpixes.
-- 05/03/2013 (0xC000010E): Fixed kpixClk BUFG.
-- 05/10/2013 (0xC000010F): Extended precharge clock period register to 12 bits
-- 05/14/2013 (0xC0000110): Fixed precharge clock period bug
-- 05/14/2013 (0xC0000111): Use updated StdLib
-- 07/15/2013 (0xD0000000): Fixed multiple StartAcquire bug, renumbered KpixDataRx register
-- addresses, added EVR
-- 07/16/2013 (0xD0000001): Added EVR Seconds and Offset status registers
-- 07/18/2013 (0xD0000002): Updated with newer StdLib components.
-- 07/24/2013 (0xD0000003): Fixed bunchCount bug. Was not being generated properly.
-- 08/05/2013 (0xD0000004): Switched most modules to synchronous resets.
-- 09/19/2016 (0xD0000005): External trigger now 100 ns
-------------------------------------------------------------------------------

