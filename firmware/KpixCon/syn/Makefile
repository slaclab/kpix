# Project Name
PROJECT = KpixCon

# Prom Type
PROM_TYPE = xcf32p

# Top level directory
export TOP_DIR  = $(PWD)/../
export CORE_DIR = $(PWD)/../../../cores/dig_core

# Generated Variables
PRJ_VERSION = $(shell grep MAKE_VERSION $(TOP_DIR)/rtl/$(PROJECT)Version.vhd | cut -d ' ' -f 8 | cut -d'"' -f2)

# Top Level
all: dir syn tran map par trce bit prom

dir:
	test -d $(TOP_DIR)/build/$(PROJECT) || mkdir $(TOP_DIR)/build/$(PROJECT)

syn:
	@echo 
	@echo "========================================================="
	@echo "Synthesize, Project=$(PROJECT), Dir=$(TOP_DIR)/build, Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TOP_DIR)/build/$(PROJECT); synplify_premier_dp -batch $(TOP_DIR)/syn/$(PROJECT).tcl

tran:
	@echo 
	@echo "========================================================="
	@echo "Translate, Project=$(PROJECT), Dir=$(TOP_DIR)/build, Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TOP_DIR)/build/$(PROJECT); ngdbuild \
      -f $(TOP_DIR)/syn/ngdbuild_options.txt \
      -sd $(TOP_DIR)/cores \
      -dd $(TOP_DIR)/build/$(PROJECT)/bld \
      -uc $(TOP_DIR)/rtl/$(PROJECT).ucf \
      $(TOP_DIR)/build/$(PROJECT)/syn/$(PROJECT).edn \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).ngd 

map:
	@echo 
	@echo "========================================================="
	@echo "Map, Project=$(PROJECT), Dir=$(TOP_DIR)/build, Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TOP_DIR)/build/$(PROJECT); map -w \
      -f $(TOP_DIR)/syn/map_options.txt \
      -o $(TOP_DIR)/build/$(PROJECT)/$(PROJECT)_map.ncd \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).ngd \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).pcf 

par:
	@echo 
	@echo "========================================================="
	@echo "Place & Route, Project=$(PROJECT), Dir=$(TOP_DIR)/build, Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TOP_DIR)/build/$(PROJECT); par \
      -f $(TOP_DIR)/syn/par_options.txt \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT)_map.ncd \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).ncd \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).pcf 

trce:
	@echo 
	@echo "========================================================="
	@echo "Trace, Project=$(PROJECT), Dir=$(TOP_DIR)/build, Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TOP_DIR)/build/$(PROJECT); trce \
      -f $(TOP_DIR)/syn/trce_options.txt \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).ncd \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).pcf 

bit:
	@echo 
	@echo "========================================================="
	@echo "Bitgen, Project=$(PROJECT), Dir=$(TOP_DIR)/build, Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TOP_DIR)/build/$(PROJECT); bitgen \
      -f $(TOP_DIR)/syn/bitgen_options.txt \
      $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).ncd 

prom:
	@echo 
	@echo "========================================================="
	@echo "Prom Generate, Project=$(PROJECT), Dir=$(TOP_DIR)/build, Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TOP_DIR)/build/$(PROJECT); promgen \
      -f $(TOP_DIR)/syn/promgen_options.txt \
      -x $(PROM_TYPE) \
      -u 0 $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).bit
		@cp $(TOP_DIR)/build/$(PROJECT)/$(PROJECT).mcs $(TOP_DIR)/images/$(PROJECT)_$(PRJ_VERSION).mcs
		@echo "Image copied to $(TOP_DIR)/images/$(PROJECT)_$(PRJ_VERSION).mcs"

clean:
	rm -rf $(TOP_DIR)/build/$(PROJECT)
