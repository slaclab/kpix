##-----------------------------------------------------------------------------
## Title         : Optical Interface FPGA Synplicity Build Script
## Project       : W_SI KPIX ASIC
##-----------------------------------------------------------------------------
## File          : KpixConSyn.tcl
## Author        : Ryan Herbst, rherbst@slac.stanford.edu
## Created       : 12/12/2005
##-----------------------------------------------------------------------------
## Description:
## Created for Synplify Pro 7.3
##-----------------------------------------------------------------------------
## This file is part of 'kpix-dev'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'kpix-dev', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##-----------------------------------------------------------------------------
## Modification history:
## 12/12/2005: created.
##-----------------------------------------------------------------------------

## Set Project
project -new

## Compile In Syn Directory
impl -add "syn"

## Extract source directory from environment
set top_dir  $::env(TOP_DIR)
set core_dir $::env(CORE_DIR)

## Set Part, Packet & Speed
set_option -technology VIRTEX5
set_option -part XC5VLX50T
set_option -package FF1136
set_option -speed_grade -1
set_option -enable64bit 1

## Version Data
add_file $top_dir/rtl/KpixConVersion.vhd

## Core Source Files
add_file $core_dir/rtl/analog_control.vhd
add_file $core_dir/rtl/command_control.vhd
add_file $core_dir/rtl/memory_array_control.vhd
add_file $core_dir/rtl/readout_control.vhd
add_file $core_dir/rtl/reg_rw_32.vhd

## RTL Source Files
add_file $top_dir/eth_client/rtl/1g/EthClientPackage.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientUdp.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientArp.vhd
add_file $top_dir/eth_client/rtl/1g/EthClient.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientGtpTxRst.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientGtpRxRst.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientGtp.vhd
add_file $top_dir/eth_client/rtl/1g/EthRegSlave.vhd
add_file $top_dir/eth_client/rtl/1g/EthArbiter.vhd
add_file $top_dir/eth_client/rtl/1g/EthUdpFrame.vhd
add_file $top_dir/rtl/UsBuff.vhd
add_file $top_dir/rtl/EthFrontEnd.vhd
add_file $top_dir/rtl/KpixLocal.vhd
add_file $top_dir/rtl/KpixCore.vhd
add_file $top_dir/rtl/KpixCon.vhd

## Additional map options
set_option -frequency 20
set_option -disable_io_insertion 0

## Additional placeAndRoute options
set_option -write_apr_constraint 0

##--Set result format/file last
project -result_file KpixCon.edn
project -log_file    KpixCon.srr

##-- Constraint file
add_file -constraint $top_dir/rtl/KpixCon.sdc

## Compile The Project
project -run
