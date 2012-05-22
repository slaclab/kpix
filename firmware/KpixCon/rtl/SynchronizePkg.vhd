-------------------------------------------------------------------------------
-- Title      : Synchronizer Package
-------------------------------------------------------------------------------
-- File       : SynchronizePkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-04-30
-- Last update: 2012-05-14
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Defines a data type and functions that act on which simplify
-- the creation of dual flip flop synchronization structures. The data type
-- also has a third stage that can be used to detect edges.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.StdRtlPkg.all;

package SynchronizePkg is

  type SynchronizerType is record
    tmp  : sl;
    sync : sl;
    last : sl;
  end record;

  type SynchronizerArray is array (natural range <>) of SynchronizerType;

  -- Constants for initializing a SynchronizerType
  constant SYNCHRONIZER_INIT_0_C : SynchronizerType := (tmp => '0', sync => '0', last => '0');
  constant SYNCHRONIZER_INIT_1_C : SynchronizerType := (tmp => '1', sync => '1', last => '1');

  procedure initSynchronizerArray (
    signal vec    : out SynchronizerArray;
    constant init : in  SynchronizerType);

  function synchronizerArrayInit (
    vec  : SynchronizerArray;
    init : SynchronizerType)
    return SynchronizerArray;

  procedure synchronize (
    input   : in  sl;
    current : in  SynchronizerType;
    nextOut : out SynchronizerType);

  procedure synchronize (
    input   : in  slv;
    current : in  SynchronizerArray;
    nextOut : out SynchronizerArray);

  function detectRisingEdge (
    synchronizer : SynchronizerType)
    return boolean;

  function detectFallingEdge (
    synchronizer : SynchronizerType)
    return boolean;

end package SynchronizePkg;

package body SynchronizePkg is

  procedure initSynchronizerArray (
    signal vec    : out SynchronizerArray;
    constant init : in  SynchronizerType) is
  begin
    for i in vec'range loop
      vec(i) <= init;
    end loop;
  end procedure initSynchronizerArray;

  function synchronizerArrayInit (
    vec  : SynchronizerArray;
    init : SynchronizerType)
    return SynchronizerArray is
    variable retVar : SynchronizerArray(vec'range);
  begin
    for i in retVar'range loop
      retVar(i) := init;
    end loop;
    return retVar;
  end function synchronizerArrayInit;
  
  procedure synchronize (
    input   : in  sl;
    current : in  SynchronizerType;
    nextOut : out SynchronizerType) is
  begin
    nextOut.tmp  := input;
    nextOut.sync := current.tmp;
    nextOut.last := current.sync;
  end procedure;

  procedure synchronize (
    input   : in  slv;
    current : in  SynchronizerArray;
    nextOut : out SynchronizerArray) is
  begin
    for i in input'range loop
      synchronize(input(i), current(i), nextOut(i));
    end loop;
  end procedure;
  
  function detectRisingEdge (
    synchronizer : SynchronizerType)
    return boolean is
  begin
    return synchronizer.sync = '1' and synchronizer.last = '0';
  end function;

  function detectFallingEdge (
    synchronizer : SynchronizerType)
    return boolean is
  begin
    return synchronizer.sync = '0' and synchronizer.last = '1';
  end function;

end package body SynchronizePkg;
