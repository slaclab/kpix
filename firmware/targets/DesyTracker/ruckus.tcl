############################
# DO NOT EDIT THE CODE BELOW
############################

# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load submodules' code and constraints
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/common/KpixDaq
loadRuckusTcl $::env(TOP_DIR)/common/KpixCore

# Load target's source code and constraints
loadSource      -dir  "$::DIR_PATH/rtl/"
loadSource      -sim_only -dir "$::DIR_PATH/sim/"
loadConstraints -dir  "$::DIR_PATH/rtl/"

