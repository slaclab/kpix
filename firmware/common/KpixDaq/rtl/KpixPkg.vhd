-------------------------------------------------------------------------------
-- Title      : KPIX Transmission Format Support Package
-------------------------------------------------------------------------------
-- File       : KpixPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-10
-- Last update: 2019-01-09
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'kpix-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'kpix-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

package KpixPkg is

   constant MAX_NUM_KPIX_C : natural := 2**12;
   subtype KpixNumberType is natural range 0 to MAX_NUM_KPIX_C;

   -- Frame indexes
   constant KPIX_NUM_TX_BITS_C         : natural := 48;
   subtype KPIX_MARKER_RANGE_C is natural range 0 to 3;
   constant KPIX_FRAME_TYPE_INDEX_C    : natural := 4;
   constant KPIX_ACCESS_TYPE_INDEX_C   : natural := 5;
   constant KPIX_WRITE_INDEX_C         : natural := 6;
   subtype KPIX_CMD_ID_REG_ADDR_RANGE_C is natural range 7 to 13;
   constant KPIX_HEADER_PARITY_INDEX_C : natural := 14;
   subtype KPIX_FULL_HEADER_RANGE_C is natural range 0 to 14;  -- Includes header parity
   subtype KPIX_DATA_RANGE_C is natural range 15 to 46;
   constant KPIX_DATA_PARITY_INDEX_C   : natural := 47;
   subtype KPIX_FULL_DATA_RANGE_C is natural range 15 to 47;

   -- Value constants
   constant KPIX_MARKER_C         : slv(0 to 3) := "0101";
   constant KPIX_CMD_RSP_FRAME_C  : sl          := '0';
   constant KPIX_DATA_FRAME_C     : sl          := '1';
   constant KPIX_CMD_RSP_ACCESS_C : sl          := '0';
   constant KPIX_REG_ACCESS_C     : sl          := '1';
   constant KPIX_WRITE_C          : sl          := '1';
   constant KPIX_READ_C           : sl          := '0';

   constant KPIX_TEMP_REG_ADDR_REV_C    : slv(0 to 6)     := "1110000";  -- Reversed
   constant KPIX_TEMP_REG_ADDR_C        : slv(6 downto 0) := "0000111";
   constant KPIX_ACQUIRE_CMD_ID_REV_C   : slv(0 to 6)     := "0100000";  -- Reversed
   constant KPIX_CALIBRATE_CMD_ID_REV_C : slv(0 to 6)     := "1100000";  -- Reversed
   constant KPIX_READOUT_CMD_ID_REV_C   : slv(0 to 6)     := "1000000";  -- Reversed

   -- Configuration Registers
   type SysConfigType is record
      kpixEnable      : slv(31 downto 0);
      kpixReset       : sl;
      inputEdge       : sl;
      outputEdge      : sl;
      rawDataMode     : sl;
      numColumns      : slv(4 downto 0);
      autoReadDisable : sl;
      debugASel       : slv(4 downto 0);
      debugBSel       : slv(4 downto 0);
   end record;

   constant SYS_CONFIG_INIT_C : SysConfigType := (
      kpixEnable      => (others => '0'),
      kpixReset       => '0',
      inputEdge       => '0',
      outputEdge      => '0',
      rawDataMode     => '0',
      numColumns      => "11111",
      autoReadDisable => '0',
      debugASel       => (others => '0'),
      debugBSel       => (others => '0'));

   type AcquisitionControlType is record
      trigger        : sl;
      startAcquire   : sl;
      startCalibrate : sl;
      startReadout   : sl;
      startRun       : sl;
      runTime : slv(63 downto 0);
   end record;

   constant ACQUISITION_CONTROL_INIT_C : AcquisitionControlType := (
      trigger        => '0',
      startAcquire   => '0',
      startCalibrate => '0',
      startReadout   => '0',
      startRun       => '0',
      runTime => (others => '0'));

   constant TIMESTAMP_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,
      TDEST_BITS_C  => 0,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_FIXED_C,
      TUSER_BITS_C  => 0,
      TUSER_MODE_C  => TUSER_NONE_C);

   constant RX_DATA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,
      TDEST_BITS_C  => 0,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_FIXED_C,
      TUSER_BITS_C  => 0,
      TUSER_MODE_C  => TUSER_NONE_C);

   constant EB_DATA_AXIS_CONFIG_C : AxiStreamConfigType :=
      ssiAxiStreamConfig(
         dataBytes => 8,
         tKeepMode => TKEEP_COMP_C,
         tDestBits => 0);

end package KpixPkg;
