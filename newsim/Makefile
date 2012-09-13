##-----------------------------------------------------------------------------
## File          : sim/Makefile
## Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
## Created       : 04/16/2009
##-----------------------------------------------------------------------------
## Description :
## Makefile for simulation.
##-----------------------------------------------------------------------------
## Copyright (c) 2009 by SLAC. All rights reserved.
## Proprietary and confidential to SLAC.
##-----------------------------------------------------------------------------
## Modification history :
## 04/16/2009: created
##-----------------------------------------------------------------------------

# Set Top Level
TOP=SmallTb

# Set Default Output
SIM_DIR=${PWD}/out

# Set 64-bit mode
EN64=-full64

# HDL Source Files
HDL_SRC= $(PWD)/../firmware/modules/StdLib/rtl/*.vhd \
	      $(PWD)/../firmware/modules/KpixCore/rtl/*.vhd \
	      $(PWD)/../firmware/modules/KpixDaq/xil_cores/*.vhd \
	      $(PWD)/../firmware/modules/KpixDaq/rtl/EthFrontEndPkg.vhd \
	      $(PWD)/../firmware/modules/KpixDaq/rtl/EthRegDecoder.vhd \
	      $(PWD)/../firmware/modules/KpixDaq/rtl/Event*.vhd \
	      $(PWD)/../firmware/modules/KpixDaq/rtl/Kpix*.vhd \
	      $(PWD)/../firmware/modules/KpixDaq/rtl/Trigger*.vhd \
	      $(PWD)/../firmware/modules/KpixDaq/rtl/UsBuff64.vhd \
	      $(PWD)/../firmware/modules/eth_client/xil_cores/*.vhd \
	      $(PWD)/../firmware/modules/eth_client/rtl/1g/EthRegSlave.vhd \
	      $(PWD)/../firmware/modules/eth_client/rtl/1g/EthCmdSlave.vhd \
	      $(PWD)/../firmware/projects/KpixSmall/xil_cores/*.vhd \
	      $(PWD)/../firmware/projects/KpixSmall/rtl/*.vhd \
	      $(PWD)/hdl/*.vhd

all: dir syn_setup rtl_src sysc_src sim_gen

# Directory
dir:
	mkdir -p $(SIM_DIR)

# RTL Files
rtl_src:
	cd $(SIM_DIR); vhdlan $(EN64) $(HDL_SRC)

# System C Files
sysc_src:
	cd $(SIM_DIR); syscan $(EN64) -cpp g++ -port $(PWD)/sysc/SimLinkRx.map $(PWD)/sysc/SimLinkRx.cpp:SimLinkRx
	cd $(SIM_DIR); syscan $(EN64) -cpp g++ -port $(PWD)/sysc/SimLinkTx.map $(PWD)/sysc/SimLinkTx.cpp:SimLinkTx

sim_gen:
	cd $(SIM_DIR); vcs $(EN64) -sysc $(TOP) -cpp g++ -cc gcc -lrt -debug -timescale=1ns/1ps 

clean: 
	rm -rf $(SIM_DIR)/*
	rm -rf $(SIM_DIR)/.synopsys_vss.setup

# Create Synopsis Setup File
syn_setup:
	rm -f $(SIM_DIR)/.synopsys_vss.setup
	echo "UNISIM:$(XIL_SIMLIB)/unisim"                >  $(SIM_DIR)/.synopsys_vss.setup
	echo "XILINXCORELIB:$(XIL_SIMLIB)/xilinxcorelib"  >> $(SIM_DIR)/.synopsys_vss.setup
	echo "SIMPRIM:$(XIL_SIMLIB)/simprim"              >> $(SIM_DIR)/.synopsys_vss.setup
