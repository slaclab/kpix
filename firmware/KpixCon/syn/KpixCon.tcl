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
## Copyright (c) 2004 by Ryan Herbst. All rights reserved.
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
add_file $core_dir/rtl_v7/analog_control_v7.vhd
add_file $core_dir/rtl_v7/command_control_v7.vhd
add_file $core_dir/rtl_v7/memory_array_control_v7.vhd
add_file $core_dir/rtl_v7/readout_control_v7.vhd
add_file $core_dir/rtl_v7/reg_rw_32_v7.vhd

## RTL Source Files
add_file $top_dir/eth_client/rtl/1g/EthClientPackage.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientUdp.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientArp.vhd
add_file $top_dir/eth_client/rtl/1g/EthClient.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientGtpTxRst.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientGtpRxRst.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientLoop.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientTest.vhd
add_file $top_dir/eth_client/rtl/1g/EthClientGtp.vhd
add_file $top_dir/eth_client/rtl/1g/EthInterface.vhd
add_file $top_dir/rtl/KpixConPkg.vhd
add_file $top_dir/rtl/KpixRspRx.vhd
add_file $top_dir/rtl/KpixDataRx.vhd
add_file $top_dir/rtl/KpixTrigRec.vhd
add_file $top_dir/rtl/DownstreamData.vhd
add_file $top_dir/rtl/KpixRespData.vhd
add_file $top_dir/rtl/KpixTrainData.vhd
add_file $top_dir/rtl/KpixDdrDataRx.vhd
add_file $top_dir/rtl/KpixDdrData.vhd
add_file $top_dir/rtl/KpixLocal.vhd
add_file $top_dir/rtl/UpstreamData.vhd
add_file $top_dir/rtl/KpixCmdTx.vhd
add_file $top_dir/rtl/CmdControl.vhd
add_file $top_dir/rtl/KpixControl.vhd
add_file $top_dir/rtl/EthTestCounter.vhd
add_file $top_dir/rtl/KpixDataFrmtr.vhd
add_file $top_dir/rtl/KpixConCore.vhd
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
