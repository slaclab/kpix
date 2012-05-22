-------------------------------------------------------------------------------
-- Title      : Ethernet Register Interface Decoder Interface Package
-------------------------------------------------------------------------------
-- File       : EthRegDecoder.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-05-07
-- Last update: 2012-05-22
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

package EthRegDecoderPkg is

  constant NUM_KPIX_MODULES_C : natural := 4;  -- Ugg, fix this somehow

  constant ETH_REG_WRITE_C : sl := '1';
  constant ETH_REG_READ_C  : sl := '0';

  subtype ADDR_BLOCK_RANGE_C is natural range 23 downto 20;
  constant LOCAL_REGS_ADDR_C : slv(3 downto 0) := "0000";
  constant KPIX_REGS_ADDR_C  : slv(3 downto 0) := "0001";



  -- Define local registers here
  constant VERSION_REG_ADDR_C         : natural := 0;
  constant CLOCK_SELECT_A_REG_ADDR_C  : natural := 1;
  constant CLOCK_SELECT_B_REG_ADDR_C  : natural := 2;
  constant DEBUG_SELECT_REG_ADDR_C    : natural := 3;

  type NaturalArray is array (natural range <>) of natural;
  function assignKpixRegs (start : natural; spacing : natural) return NaturalArray;

  constant KPIX_DATA_RX_MODE_REG_ADDR_C              : NaturalArray(0 to NUM_KPIX_MODULES_C-1) := assignKpixRegs(5, 5);
  constant KPIX_HEADER_PARITY_ERROR_COUNT_REG_ADDR_C : NaturalArray(0 to NUM_KPIX_MODULES_C-1) := assignKpixRegs(6, 5);
  constant KPIX_DATA_PARITY_ERROR_COUNT_REG_ADDR_C   : NaturalArray(0 to NUM_KPIX_MODULES_C-1) := assignKpixRegs(7, 5);
  constant KPIX_MARKER_ERROR_COUNT_REG_ADDR_C        : NaturalArray(0 to NUM_KPIX_MODULES_C-1) := assignKpixRegs(8, 5);
  constant KPIX_OVERFLOW_ERROR_COUNT_REG_ADDR_C      : NaturalArray(0 to NUM_KPIX_MODULES_C-1) := assignKpixRegs(9, 5);

  constant NUM_LOCAL_REGS_C : natural := 5 + (5 * NUM_KPIX_MODULES_C);
  subtype LOCAL_REGS_ADDR_RANGE_C is natural range log2(NUM_LOCAL_REGS_C)-1 downto 0;
  subtype NOT_LOCAL_REGS_ADDR_RANGE_C is natural range 20 downto (log2(NUM_LOCAL_REGS_C));

  
  type Slv32Array is array (natural range <>) of slv(31 downto 0);

  type EthRegDecoderInType is record
    dataIn : Slv32Array(0 to NUM_LOCAL_REGS_C-1);
  end record;

  type EthRegDecoderOutType is record
    regSelect : slv(0 to NUM_LOCAL_REGS_C-1);
    regOp     : sl;
    dataOut   : slv(31 downto 0);
  end record EthRegDecoderOutType;

end package EthRegDecoderPkg;

package body EthRegDecoderPkg is

  function assignKpixRegs (
    start   : natural;
    spacing : natural)
    return NaturalArray
  is
    variable retVar : NaturalArray(0 to NUM_KPIX_MODULES_C-1);
  begin
    for i in retVar'range loop
      retVar(i) := start + i*spacing;
    end loop;
    return retVar;
  end function assignKpixRegs;

end package body EthRegDecoderPkg;
