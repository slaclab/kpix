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

# Set 64-bit compile flags
ifeq ($(PLATFORM),lin64)
VARGS=-full64
else
VARGS=
endif

# Set Main Netlist, Include Netlists & Configure Files For Copy
NET = kpix_9_136_hier_P.cir
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
	@cd $(PWD)/../sim_dir/; gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/VhpiGeneric.c
	@cd $(PWD)/../sim_dir/; gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/UsbChip.c
	@cd $(PWD)/../sim_dir/; gcc -Wall -shared -o libSimWsi_lib.so VhpiGeneric.o UsbChip.o

clean: 
	@rm $(PWD)/../sim_dir/sim_src
	@rm -rf $(PWD)/../sim_dir/*

# Compile VHDL Files
vcomp:
	@cd $(PWD)/../sim_dir/; vhdlan $(VARGS) $(VHDL)
	@cd $(PWD)/../sim_dir/; vlogan $(VARGS) +v2k $(VLOG)

# Link Simulation Files
vlink:
	@cd $(PWD)/../sim_dir/; vcs $(VARGS) -nc -time "ns" -time_res "10ps" -debug $(TOP) +ad=$(PWD)/../sim_dir/partition.txt

# Make named pipe for sidApi link
pipe:
	@rm -f $(PWD)/../sim_dir/sim_link.*
	@mknod --mode 666 $(PWD)/../sim_dir/sim_link.rx p
	@mknod --mode 666 $(PWD)/../sim_dir/sim_link.tx p

# Create Synopsis Setup File
syn_setup:
	@rm -f $(PWD)/../sim_dir/.synopsys_vss.setup
	@echo "UNISIM:$(XIL_SIMLIB)/unisim"                >  $(PWD)/../sim_dir/.synopsys_vss.setup
	@echo "XILINXCORELIB:$(XIL_SIMLIB)/xilinxcorelib"  >> $(PWD)/../sim_dir/.synopsys_vss.setup
	@echo "SIMPRIM:$(XIL_SIMLIB)/simprim"              >> $(PWD)/../sim_dir/.synopsys_vss.setup

# Compile simulation control
simControl:
	@cd $(PWD)/../sim_dir; \
	g++ -Wall -I $(PWD)/../software/kpixSw/sidApi/offline \
	          -I $(PWD)/../software/kpixSw/sidApi/online \
	          -L$(PWD)/../software/bin -lsidapi \
	          -DOUT_DIR=\"$(PWD)/../sim_dir\" \
	          -DONLINE_EN \
	          `root-config --cflags --libs` -m32 -lMinuit \
	           $(PWD)/simControl.cc -o simControl

# Copy simulation files
files:
	@rm -f $(PWD)/../sim_dir/sim_src
	@ln -s $(PWD) $(PWD)/../sim_dir/sim_src
	@cp $(PWD)/../netlists/$(NET).gz  $(PWD)/../sim_dir
	@cp $(INC)                        $(PWD)/../sim_dir
	@gzip -df $(PWD)/../sim_dir/*.gz

# Create partition file
partition:
	@rm -f $(PWD)/../sim_dir/partition.txt
	@echo "partition -cell Kpix;"                                    >  $(PWD)/../sim_dir/partition.txt
	@echo "choose nanosim -A -n $(NET) -C nanosim_cfg.txt -out wdb;" >> $(PWD)/../sim_dir/partition.txt
	@echo "set bus_format %d;"                                       >> $(PWD)/../sim_dir/partition.txt
	@echo "set rmap resis_map.txt;"                                  >> $(PWD)/../sim_dir/partition.txt

# Create setup env script
env:
	@rm -f $(PWD)/../sim_dir/setup_env.csh
	@echo "source $(PWD)/../software/bin/setup_env.csh"                                          >  $(PWD)/../sim_dir/setup_env.csh
	@echo "limit stacksize 60000"                                                                >> $(PWD)/../sim_dir/setup_env.csh
	@echo "setenv LD_LIBRARY_PATH $(PWD)/../sim_dir:$(PWD)/../software/bin:$${LD_LIBRARY_PATH}"  >> $(PWD)/../sim_dir/setup_env.csh

