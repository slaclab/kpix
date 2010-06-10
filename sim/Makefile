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

# Set SIM Source Directory
SIM_SRC=/u/ey/rherbst/projects/w_si/sim

# Set FGPA Directory
FPGA=/u/ey/rherbst/projects/w_si/fpgas

# Set Core Directory
CORES=/u/ey/rherbst/projects/w_si/cores

# Set Main Netlist Directory
NET_DIR=/u/ey/rherbst/projects/w_si/netlists

# Set Top Level
TOP=KpixTb

# Set Default Output, just in case make clean is typed before setup
ifndef SIM_DIR
SIM_DIR=/tmp/simdir/
endif

# Set 64-bit compile flags
ifeq ($(PLATFORM),lin64)
VARGS=-full64
else
VARGS=
endif

# Set Main Netlist, Include Netlists & Configure Files For Copy
#NET = kpix_8_256.cir
#NET = kpix_9.cir
#NET = kpix_9_32.cir
#NET = kpix_9_32_hier_P.cir
#NET = kpix_9_32_hier_split_P.cir
NET = kpix_9_136_hier_P.cir
INC = $(SIM_SRC)/olib_tsmc025.cir \
      $(SIM_SRC)/w_si_chip_driver.cir \
      $(SIM_SRC)/nanosim_cfg.txt \
      $(SIM_SRC)/resis_map.txt

# VHDL Source Files
VHDL = $(FPGA)/opto/cores/afifo_17x32.vhd \
       $(FPGA)/opto/cores/afifo_19x8k.vhd \
       $(FPGA)/opto/cores/fifo_13x1k.vhd \
       $(FPGA)/opto/cores/dpram_sync_1kx14 \
       $(CORES)/dig_core/rtl/analog_control.vhd \
       $(CORES)/dig_core/rtl/command_control.vhd \
       $(CORES)/dig_core/rtl/memory_array_control.vhd \
       $(CORES)/dig_core/rtl/readout_control.vhd \
       $(CORES)/dig_core/rtl/reg_rw_32.vhd \
       $(CORES)/dig_core/rtl_v7/analog_control_v7.vhd \
       $(CORES)/dig_core/rtl_v7/command_control_v7.vhd \
       $(CORES)/dig_core/rtl_v7/memory_array_control_v7.vhd \
       $(CORES)/dig_core/rtl_v7/readout_control_v7.vhd \
       $(CORES)/dig_core/rtl_v7/reg_rw_32_v7.vhd \
       $(FPGA)/opto/rtl/Usb.vhd \
       $(FPGA)/opto/rtl/GenAdc.vhd \
       $(FPGA)/opto/rtl/UsbWord.vhd \
       $(FPGA)/opto/rtl/KpixRspRx.vhd \
       $(FPGA)/opto/rtl/KpixDataRx.vhd \
       $(FPGA)/opto/rtl/KpixTrigRec.vhd \
       $(FPGA)/opto/rtl/DownstreamData.vhd \
       $(FPGA)/opto/rtl/KpixTrainData.vhd \
       $(FPGA)/opto/rtl/KpixLocal.vhd \
       $(FPGA)/opto/rtl/UpstreamData.vhd \
       $(FPGA)/opto/rtl/KpixCmdTx.vhd \
       $(FPGA)/opto/rtl/CmdControl.vhd \
       $(FPGA)/opto/rtl/KpixControl.vhd \
       $(FPGA)/opto/rtl/OptoCore.vhd \
       $(SIM_SRC)/OptoSim.vhd \
       $(SIM_SRC)/UsbChip.vhd \
       $(SIM_SRC)/RtlKpix.vhd \
       $(SIM_SRC)/KpixTb.vhd

# Verilog Source Files
VLOG = $(SIM_SRC)/Kpix.v 

# Top Level targets
all: pipe files partition pli syn_setup vcomp vlink simControl

# PLI Library
pli: VhpiGeneric.h VhpiGeneric.c UsbChip.c
	cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(SIM_SRC)/VhpiGeneric.c
	cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(SIM_SRC)/UsbChip.c
	cd $(SIM_DIR); gcc -Wall -shared -o libSimWsi_lib.so VhpiGeneric.o UsbChip.o

clean: 
	rm -rf ${SIM_DIR}/*

# Compile VHDL Files
vcomp:
	cd $(SIM_DIR); vhdlan $(VARGS) $(VHDL)
	cd $(SIM_DIR); vlogan $(VARGS) +v2k $(VLOG)

# Link Simulation Files
vlink:
	cd $(SIM_DIR); vcs $(VARGS) -nc -time "ns" -time_res "10ps" -debug $(TOP) +ad=${SIM_DIR}/partition.txt

# Make named pipe for sidApi link
pipe:
	rm -f $(SIM_DIR)/sim_link.*
	mknod --mode 666 $(SIM_DIR)/sim_link.rx p
	mknod --mode 666 $(SIM_DIR)/sim_link.tx p

# Create Synopsis Setup File
syn_setup:
	rm -f $(SIM_DIR)/.synopsys_vss.setup
	echo "UNISIM:$(XIL_SIMLIB)/unisim"                >  $(SIM_DIR)/.synopsys_vss.setup
	echo "XILINXCORELIB:$(XIL_SIMLIB)/xilinxcorelib"  >> $(SIM_DIR)/.synopsys_vss.setup
	echo "SIMPRIM:$(XIL_SIMLIB)/simprim"              >> $(SIM_DIR)/.synopsys_vss.setup

# Compile simulation control
simControl:
	cd $(SIM_DIR); \
	g++ -Wall -I $(KPIX_SW)/sidApi/offline \
	          -I $(KPIX_SW)/sidApi/online \
	          -L$(KPIX_SW)/bin -lsidapi \
	          -DOUT_DIR=\"$(SIM_DIR)\" \
	          -DONLINE_EN \
	          `root-config --cflags --libs` -lMinuit \
	           $(SIM_SRC)/simControl.cc -o simControl

# Copy simulation files
files:
	cp $(NET_DIR)/$(NET).gz  $(SIM_DIR)
	cp $(INC)                $(SIM_DIR)
	cp setup_env.csh         $(SIM_DIR)
	gzip -df $(SIM_DIR)/*.gz

# Create partition file
partition:
	rm -f $(SIM_DIR)/partition.txt
	echo "partition -cell Kpix;"                                    >  $(SIM_DIR)/partition.txt
	echo "choose nanosim -A -n $(NET) -C nanosim_cfg.txt -out wdb;" >> $(SIM_DIR)/partition.txt
	echo "set bus_format %d;"                                       >> $(SIM_DIR)/partition.txt
	echo "set rmap resis_map.txt;"                                  >> $(SIM_DIR)/partition.txt

