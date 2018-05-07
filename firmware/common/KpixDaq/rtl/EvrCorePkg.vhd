-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : EvrPkg.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2012-09-26
-- Last update: 2012-09-26
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

package EvrCorePkg is

   -- Evr Core Phy interface
   type EvrPhyType is record
      rxData  : slv(15 downto 0);
      rxDataK : slv(1 downto 0);
      decErr : slv(1 downto 0);
      dispErr : slv(1 downto 0);
   end record EvrPhyType;


   type EvrConfigIntfInType is record
      req    : sl;
      wrEna  : sl;
      dataIn : slv(31 downto 0);
      addr   : slv(7 downto 0);
   end record;
   constant EVR_CONIFG_INTF_IN_INIT_C : EvrConfigIntfInType :=
      (req    => '0',
       wrEna  => '0',
       dataIn => (others => '0'),
       addr   => (others => '0'));

   type EvrConfigIntfOutType is record
      dataOut : slv(31 downto 0);
      ack     : sl;
   end record;
   constant EVR_CONFIG_INTF_OUT_INIT_C : EvrConfigIntfOutType :=
      (dataOut => (others => '0'),
       ack     => '0');

   type EvrOutType is record
      eventStream : slv(7 downto 0);
      dataStream  : slv(7 downto 0);
      trigger     : sl;
      seconds     : slv(31 downto 0);
      offset      : slv(31 downto 0);
      errors      : slv(15 downto 0);
   end record;
   constant EVR_OUT_INIT_C : EvrOutType :=
      (eventStream => (others => '0'),
       dataStream  => (others => '0'),
       trigger     => '0',
       seconds     => (others => '0'),
       offset      => (others => '0'),
       errors      => (others => '0'));


end package EvrCorePkg;
