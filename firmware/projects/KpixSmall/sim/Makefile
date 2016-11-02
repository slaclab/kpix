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

# Set Default Output
SIM_DIR=/dev/shm/bareese/build/KpixSmallTb

# Analog netlist
ANA_NET = kpix_c.cir

# Shared memory id. Changed this if you need to run multiple instances
# Resulting shared memory file is simlink_username_id
SHM_ID=1
SHM_NAME="kpix"

# Set Top Level
DIG_TOP=KpixSmallTb
ANA_TOP=KpixSmallAnalogTb

# Set 64-bit mode
EN64=-full64

# NS Support files
ANA_INC = $(PWD)/../../../modules/KpixCore/analog/olib_tsmc025.cir \
          $(PWD)/../../../modules/KpixCore/analog/w_si_chip_driver.cir \
          $(PWD)/../../../modules/KpixCore/analog/nanosim_cfg.txt \
          $(PWD)/../../../modules/KpixCore/analog/resis_map.txt

# HDL Source Files
HDL_SRC= $(PWD)/../../../modules/StdLib/rtl/StdRtlPkg.vhd \
         $(PWD)/../../../modules/StdLib/rtl/Synchronizer.vhd \
         $(PWD)/../../../modules/StdLib/rtl/SynchronizerEdge.vhd \
         $(PWD)/../../../modules/StdLib/rtl/SynchronizerVector.vhd \
         $(PWD)/../../../modules/StdLib/rtl/RstSync.vhd \
         $(PWD)/../../../modules/StdLib/rtl/ClkOutBufDiff.vhd \
         $(PWD)/../../../modules/StdLib/rtl/SimpleDualPortRam.vhd \
         $(PWD)/../../../modules/StdLib/rtl/FifoAsync.vhd \
         $(PWD)/../../../modules/StdLib/rtl/SynchronizerFifo.vhd \
         $(PWD)/../../../modules/8b10bCore/rtl/Code8b10bPkg.vhd \
         $(PWD)/../../../modules/8b10bCore/rtl/Decoder8b10b.vhd \
         $(PWD)/../../../modules/Pgp2Core/rtl/gtp/GtpRxCommaAligner.vhd \
         $(PWD)/../../../modules/Pgp2Core/rtl/gtp/GtpTxPhaseAligner.vhd \
         $(PWD)/../../../modules/Pgp2Core/rtl/gtp/Gtp16LowLatCore.vhd \
	 $(PWD)/../rtl/Version.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixPkg.vhd \
	 $(PWD)/../../../modules/KpixCore/rtl/reg_rw_32.vhd \
	 $(PWD)/../../../modules/KpixCore/rtl/command_control.vhd \
	 $(PWD)/../../../modules/KpixCore/rtl/analog_control.vhd \
	 $(PWD)/../../../modules/KpixCore/rtl/readout_control.vhd \
	 $(PWD)/../../../modules/KpixCore/rtl/memory_array_control.vhd \
	 $(PWD)/../../../modules/eth_client/xil_cores/*.vhd \
	 $(PWD)/../../../modules/eth_client/rtl/1g/EthRegSlave.vhd \
	 $(PWD)/../../../modules/eth_client/rtl/1g/EthCmdSlave.vhd \
	 $(PWD)/../../../modules/KpixDaq/xil_cores/*.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/TriggerPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixLocalPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/FrontEndPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixRegCntlPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixClockGenPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/EventBuilderFifoPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/EthUsBuff64.vhd \
         $(PWD)/../../../modules/KpixDaq/sim/EthFrontEndSim.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/EvrCorePkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/EvrCore.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/EvrGtp.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixRegRxPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixRegRx.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixDataRxPkg.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixDataRx.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixLocal.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixClockGen.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/Trigger.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/FrontEndRegDecoder.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/EventBuilder.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixRegCntl.vhd \
         $(PWD)/../../../modules/KpixDaq/rtl/KpixDaqCore.vhd \
	 $(PWD)/../xil_cores/*.vhd \
	 $(PWD)/../rtl/KpixSmall.vhd \
	 $(PWD)/../../../modules/KpixCore/sim/AnalogReg.vhd \
	 $(PWD)/../../../modules/KpixCore/sim/DataRead.vhd \
	 $(PWD)/../../../modules/KpixCore/sim/AsicSim.vhd \
	 $(PWD)/../../../modules/gen_daq/simlink/SimLinkRx.vhd \
	 $(PWD)/../../../modules/gen_daq/simlink/SimLinkTx.vhd \
         $(PWD)/../../../modules/StdLib/tb/ClkRst.vhd \
	 $(PWD)/KpixSmallTb.vhd \
	 $(PWD)/KpixSmallAnalogTb.vhd

# Verilog Source Files
VLOG = $(PWD)/../../../modules/KpixCore/sim/Kpix.v 

# Targets
all:    dir env syn_setup rtl_src vhpi_src sim_dig
analog: dir env syn_setup rtl_src vhpi_src ana_files ana_partition sim_ana

# Directory
dir:
	@mkdir -p $(SIM_DIR)

# RTL Files
rtl_src:
	@cd $(SIM_DIR); vhdlan $(EN64) $(HDL_SRC)
	@cd $(SIM_DIR); vlogan +v2k $(EN64) $(VLOG)

# VHPI Library
vhpi_src:
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -DSHM_ID=$(SHM_ID) -DSHM_NAME=\"$(SHM_NAME)\" -I$(VCS_HOME)/include/ $(PWD)/../../../modules/gen_daq/simlink/VhpiGeneric.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -DSHM_ID=$(SHM_ID) -DSHM_NAME=\"$(SHM_NAME)\" -I$(VCS_HOME)/include/ $(PWD)/../../../modules/gen_daq/simlink/SimLinkRx.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -DSHM_ID=$(SHM_ID) -DSHM_NAME=\"$(SHM_NAME)\" -I$(VCS_HOME)/include/ $(PWD)/../../../modules/gen_daq/simlink/SimLinkTx.c
	@cd $(SIM_DIR); gcc -Wall -shared -o libSimSw_lib.so VhpiGeneric.o SimLinkRx.o SimLinkTx.o

sim_dig:
	@cd $(SIM_DIR); vcs $(EN64) $(DIG_TOP) -parallel -cpp g++ -cc gcc -lrt -debug -time "ns" -time_res "1ps"

sim_ana:
	@cd $(SIM_DIR); vcs $(EN64) $(ANA_TOP) -parallel -cpp g++ -cc gcc -lrt -debug -time "ns" -time_res "1ps" -nc +ad=$(SIM_DIR)/partition.txt -notice

clean: 
	@rm -rf $(SIM_DIR)/*
	@rm -rf $(SIM_DIR)/.synopsys_vss.setup

# Create Synopsis Setup File
syn_setup:
	@rm -f $(SIM_DIR)/.synopsys_vss.setup
	@echo "UNISIM:$(XIL_SIMLIB)/unisim"                >  $(SIM_DIR)/.synopsys_vss.setup
	@echo "XILINXCORELIB:$(XIL_SIMLIB)/xilinxcorelib"  >> $(SIM_DIR)/.synopsys_vss.setup
	@echo "SIMPRIM:$(XIL_SIMLIB)/simprim"              >> $(SIM_DIR)/.synopsys_vss.setup

# Analog simulation files
ana_files:
	@rm -f $(SIM_DIR)/sim_src
	@cp $(PWD)/../../../../netlists/$(ANA_NET).gz  $(SIM_DIR)
	@cp $(ANA_INC)                        $(SIM_DIR)
	@gzip -df $(SIM_DIR)/*.gz

# Analog partition file
ana_partition:
	@rm -f $(SIM_DIR)/partition.txt
	@echo "partition -cell Kpix;"                                        >  $(SIM_DIR)/partition.txt
	@echo "choose nanosim -A -n $(ANA_NET) -C nanosim_cfg.txt -out wdb;" >> $(SIM_DIR)/partition.txt
	@echo "set bus_format %d;"                                           >> $(SIM_DIR)/partition.txt
	@echo "set rmap resis_map.txt;"                                      >> $(SIM_DIR)/partition.txt

# Create setup env script
env:
	@rm -f $(SIM_DIR)/setup_env.csh
	@echo "limit stacksize 60000"                                 >> $(SIM_DIR)/setup_env.csh
	@echo "setenv LD_LIBRARY_PATH $(SIM_DIR):${LD_LIBRARY_PATH}"  >> $(SIM_DIR)/setup_env.csh

