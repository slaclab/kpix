##-----------------------------------------------------------------------------
## Title         : ADC Test FPGA Synplicity Build Script
##-----------------------------------------------------------------------------
## File          : AdcTestSyn.tcl
## Author        : Ryan Herbst, rherbst@slac.stanford.edu
## Created       : 07/06/2009
##-----------------------------------------------------------------------------
## Description:
## Created for Synplify Pro 7.3
##-----------------------------------------------------------------------------
## Copyright (c) 2004 by Ryan Herbst. All rights reserved.
##-----------------------------------------------------------------------------
## Modification history:
## 07/06/2006: created.
##-----------------------------------------------------------------------------

## Set Project
project -new

## Compile In Syn Directory
impl -add "syn"

## Extract source directory from environment
set srcdir $::env(SRCDIR);

## Set Part, Packet & Speed
set_option -technology SPARTAN3
set_option -part xc3S400
set_option -package PQ208
set_option -speed_grade -4

## Master Specific Files
add_file $srcdir/rtl/DacCntrl.vhd
add_file $srcdir/rtl/Usb.vhd
add_file $srcdir/rtl/UsbWord.vhd
add_file $srcdir/rtl/CmdControl.vhd
add_file $srcdir/rtl/AdcTest.vhd

## Additional compile options
set_option -symbolic_fsm_compiler 1
set_option -resource_sharing 1
set_option -default_enum_encoding default
set_option -top_module AdcTest
set_option -use_fsm_explorer 1

## Additional map options
set_option -frequency 30
set_option -fanout_limit 100
set_option -disable_io_insertion 0
set_option -pipe 1
set_option -modular 0
set_option -retiming 0

## Additional simulation options
set_option -write_verilog 0
set_option -write_vhdl 0

## Additional placeAndRoute options
set_option -write_apr_constraint 0

## Additional implAttr options
set_option -num_critical_paths 0
set_option -num_startend_points 0
set_option -compiler_compatible 0

##--Set result format/file last
project -result_file adctest.edn
project -log_file    adctest.srr

##-- Constraint file
add_file -constraint $srcdir/rtl/AdcTest.sdc

## Compile The Project
project -run
