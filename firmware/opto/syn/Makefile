# Project Name
PROJECT = Opto

# Prom Type
PROM_TYPE = xcf04s

# Top level directory
export TOP_DIR  = $(PWD)/../
export CORE_DIR = $(PWD)/../../../cores/dig_core

# Build Directory
TAR_DIR = /u1/w_si/build

# RTL Location
PRJ_RTL     = $(TOP_DIR)/rtl

# Generated Variables
PRJ_VERSION = $(shell grep MAKE_VERSION $(PRJ_RTL)/$(PROJECT)Version.vhd | cut -d ' ' -f 8 | cut -d'"' -f2)

# Top Level
all: dir syn tran map par trce bit prom

dir:
	test -d $(TAR_DIR)/$(PROJECT) || mkdir $(TAR_DIR)/$(PROJECT)

syn:
	@echo 
	@echo "========================================================="
	@echo "Synthesize, Project=$(PROJECT), Dir=$(TAR_DIR), Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TAR_DIR)/$(PROJECT); synplify_premier_dp -batch $(TOP_DIR)/syn/$(PROJECT).tcl

tran:
	@echo 
	@echo "========================================================="
	@echo "Translate, Project=$(PROJECT), Dir=$(TAR_DIR), Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TAR_DIR)/$(PROJECT); ngdbuild \
      -f $(TOP_DIR)/syn/ngdbuild_options.txt \
      -sd $(TOP_DIR)/cores \
      -dd $(TAR_DIR)/$(PROJECT)/bld \
      -uc $(PRJ_RTL)/$(PROJECT).ucf \
      $(TAR_DIR)/$(PROJECT)/syn/$(PROJECT).edn \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).ngd 

map:
	@echo 
	@echo "========================================================="
	@echo "Map, Project=$(PROJECT), Dir=$(TAR_DIR), Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TAR_DIR)/$(PROJECT); map -w \
      -f $(TOP_DIR)/syn/map_options.txt \
      -o $(TAR_DIR)/$(PROJECT)/$(PROJECT)_map.ncd \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).ngd \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).pcf 

par:
	@echo 
	@echo "========================================================="
	@echo "Place & Route, Project=$(PROJECT), Dir=$(TAR_DIR), Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TAR_DIR)/$(PROJECT); par \
      -f $(TOP_DIR)/syn/par_options.txt \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT)_map.ncd \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).ncd \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).pcf 

trce:
	@echo 
	@echo "========================================================="
	@echo "Trace, Project=$(PROJECT), Dir=$(TAR_DIR), Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TAR_DIR)/$(PROJECT); trce \
      -f $(TOP_DIR)/syn/trce_options.txt \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).ncd \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).pcf 

bit:
	@echo 
	@echo "========================================================="
	@echo "Bitgen, Project=$(PROJECT), Dir=$(TAR_DIR), Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TAR_DIR)/$(PROJECT); bitgen \
      -f $(TOP_DIR)/syn/bitgen_options.txt \
      $(TAR_DIR)/$(PROJECT)/$(PROJECT).ncd 

prom:
	@echo 
	@echo "========================================================="
	@echo "Prom Generate, Project=$(PROJECT), Dir=$(TAR_DIR), Ver=$(PRJ_VERSION)"
	@echo "========================================================="
	@echo 
	@cd $(TAR_DIR)/$(PROJECT); promgen \
      -f $(TOP_DIR)/syn/promgen_options.txt \
      -x $(PROM_TYPE) \
      -u 0 $(TAR_DIR)/$(PROJECT)/$(PROJECT).bit
		@cp $(TAR_DIR)/$(PROJECT)/$(PROJECT).mcs $(TOP_DIR)/images/$(PROJECT)_$(PRJ_VERSION).mcs
		@echo "Image copied to $(TOP_DIR)/images/$(PROJECT)_$(PRJ_VERSION).mcs"

clean:
	rm -rf $(TAR_DIR)/$(PROJECT)
