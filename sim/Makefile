##-----------------------------------------------------------------------------
## File          : sim/Makefile
## Author        : Ryan Herbst  <rherbst@slac.stanford.edu>
## Created       : 05/11/2007
##-----------------------------------------------------------------------------
## Description :
## Makefile for simulation
##-----------------------------------------------------------------------------
## Copyright (c) 2007 by SLAC. All rights reserved.
## Proprietary and confidential to SLAC.
##-----------------------------------------------------------------------------
## Modification history :
## 05/11/2007: created
##-----------------------------------------------------------------------------

# Set Top Level
TOP=KpixTb

# Sim directory
#SIM_DIR=$(PWD)/../run_0x40
#SIM_DIR=$(PWD)/../run_0x80
#SIM_DIR=$(PWD)/../run_0x40_high
SIM_DIR=$(PWD)/../run_0x80_high

# Set 64-bit compile flags
ifeq ($(PLATFORM),lin64)
VARGS=-full64
else
VARGS=
endif

# Set Main Netlist, Include Netlists & Configure Files For Copy
#NET = kpix_9_136_hier_P.cir
#NET = kpix_a_02.cir
#NET = kpix_a_64_submit9.cir
NET = kpix_a_64_submit11.cir

INC = $(PWD)/olib_tsmc025.cir \
      $(PWD)/w_si_chip_driver.cir \
      $(PWD)/nanosim_cfg.txt \
      $(PWD)/resis_map.txt

# VHDL Source Files
VHDL = $(PWD)/../firmware/opto/cores/afifo_17x32.vhd \
       $(PWD)/../firmware/opto/cores/afifo_19x8k.vhd \
       $(PWD)/../firmware/opto/cores/fifo_13x1k.vhd \
       $(PWD)/../firmware/opto/cores/dpram_sync_1kx14 \
       $(PWD)/../cores/dig_core/rtl/analog_control.vhd \
       $(PWD)/../cores/dig_core/rtl/command_control.vhd \
       $(PWD)/../cores/dig_core/rtl/memory_array_control.vhd \
       $(PWD)/../cores/dig_core/rtl/readout_control.vhd \
       $(PWD)/../cores/dig_core/rtl/reg_rw_32.vhd \
       $(PWD)/../cores/dig_core/rtl_v7/analog_control_v7.vhd \
       $(PWD)/../cores/dig_core/rtl_v7/command_control_v7.vhd \
       $(PWD)/../cores/dig_core/rtl_v7/memory_array_control_v7.vhd \
       $(PWD)/../cores/dig_core/rtl_v7/readout_control_v7.vhd \
       $(PWD)/../cores/dig_core/rtl_v7/reg_rw_32_v7.vhd \
       $(PWD)/../firmware/opto/rtl/OptoVersion.vhd \
       $(PWD)/../firmware/opto/rtl/Usb.vhd \
       $(PWD)/../firmware/opto/rtl/GenAdc.vhd \
       $(PWD)/../firmware/opto/rtl/UsbWord.vhd \
       $(PWD)/../firmware/opto/rtl/KpixRspRx.vhd \
       $(PWD)/../firmware/opto/rtl/KpixDataRx.vhd \
       $(PWD)/../firmware/opto/rtl/KpixTrigRec.vhd \
       $(PWD)/../firmware/opto/rtl/DownstreamData.vhd \
       $(PWD)/../firmware/opto/rtl/KpixTrainData.vhd \
       $(PWD)/../firmware/opto/rtl/KpixLocal.vhd \
       $(PWD)/../firmware/opto/rtl/UpstreamData.vhd \
       $(PWD)/../firmware/opto/rtl/KpixCmdTx.vhd \
       $(PWD)/../firmware/opto/rtl/CmdControl.vhd \
       $(PWD)/../firmware/opto/rtl/KpixControl.vhd \
       $(PWD)/../firmware/opto/rtl/OptoCore.vhd \
       $(PWD)/OptoSim.vhd \
       $(PWD)/UsbChip.vhd \
       $(PWD)/RtlKpix.vhd \
       $(PWD)/KpixTb.vhd

# Verilog Source Files
VLOG = $(PWD)/Kpix.v 

# Top Level targets
all: pipe files partition env pli syn_setup vcomp vlink simControl

# PLI Library
pli: VhpiGeneric.h VhpiGeneric.c UsbChip.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/VhpiGeneric.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/UsbChip.c
	@cd $(SIM_DIR); gcc -Wall -shared -o libSimWsi_lib.so VhpiGeneric.o UsbChip.o

clean: 
	@echo "Cleaning $(SIM_DIR)"
	@rm $(SIM_DIR)/sim_src
	@rm -rf $(SIM_DIR)/*

# Compile VHDL Files
vcomp:
	@cd $(SIM_DIR); vhdlan $(VARGS) $(VHDL)
	@cd $(SIM_DIR); vlogan $(VARGS) +v2k $(VLOG)

# Link Simulation Files
vlink:
	@cd $(SIM_DIR); vcs $(VARGS) -nc -time "ns" -time_res "10ps" -debug $(TOP) +ad=$(SIM_DIR)/partition.txt

# Make named pipe for sidApi link
pipe:
	@echo "Using directory $(SIM_DIR)"
	@rm -f $(SIM_DIR)/sim_link.*
	@mknod --mode 666 $(SIM_DIR)/sim_link.rx p
	@mknod --mode 666 $(SIM_DIR)/sim_link.tx p

# Create Synopsis Setup File
syn_setup:
	@rm -f $(SIM_DIR)/.synopsys_vss.setup
	@echo "UNISIM:$(XIL_SIMLIB)/unisim"                >  $(SIM_DIR)/.synopsys_vss.setup
	@echo "XILINXCORELIB:$(XIL_SIMLIB)/xilinxcorelib"  >> $(SIM_DIR)/.synopsys_vss.setup
	@echo "SIMPRIM:$(XIL_SIMLIB)/simprim"              >> $(SIM_DIR)/.synopsys_vss.setup

# Compile simulation control
simControl:
	@cd $(SIM_DIR); \
	g++ -Wall -I $(PWD)/../software/kpixSw/sidApi/offline \
	          -I $(PWD)/../software/kpixSw/sidApi/online \
	          -L$(PWD)/../software/bin -lsidapi \
	          -DOUT_DIR=\"$(SIM_DIR)\" \
	          -DONLINE_EN \
	          `root-config --cflags --libs` -m32 -lMinuit \
	           $(PWD)/simControl.cc -o simControl

# Copy simulation files
files:
	@rm -f $(SIM_DIR)/sim_src
	@ln -s $(PWD) $(SIM_DIR)/sim_src
	@cp $(PWD)/../netlists/$(NET).gz  $(SIM_DIR)
	@cp $(INC)                        $(SIM_DIR)
	@gzip -df $(SIM_DIR)/*.gz

# Create partition file
partition:
	@rm -f $(SIM_DIR)/partition.txt
	@echo "partition -cell Kpix;"                                    >  $(SIM_DIR)/partition.txt
	@echo "choose nanosim -A -n $(NET) -C nanosim_cfg.txt -out wdb;" >> $(SIM_DIR)/partition.txt
	@echo "set bus_format %d;"                                       >> $(SIM_DIR)/partition.txt
	@echo "set rmap resis_map.txt;"                                  >> $(SIM_DIR)/partition.txt

# Create setup env script
env:
	@rm -f $(SIM_DIR)/setup_env.csh
	@echo "source $(PWD)/../software/bin/setup_env.csh"                                   >  $(SIM_DIR)/setup_env.csh
	@echo "limit stacksize 60000"                                                         >> $(SIM_DIR)/setup_env.csh
	@echo "setenv LD_LIBRARY_PATH $(SIM_DIR):$(PWD)/../software/bin:$${LD_LIBRARY_PATH}"  >> $(SIM_DIR)/setup_env.csh

