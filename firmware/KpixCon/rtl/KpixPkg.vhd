-------------------------------------------------------------------------------
-- Title      : KPIX Transmission Format Support Package
-------------------------------------------------------------------------------
-- File       : KpixPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-10
-- Last update: 2012-05-21
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
  constant KPIX_TEMP_REG_ADDR_C    : slv(6 downto 0) := "0000111";
  constant KPIX_ACQUIRE_CMD_ID_REV_C   : slv(0 to 6)     := "0100000";  -- Reversed
  constant KPIX_CALIBRATE_CMD_ID_REV_C : slv(0 to 6)     := "1100000";  -- Reversed

  
end package KpixPkg;
