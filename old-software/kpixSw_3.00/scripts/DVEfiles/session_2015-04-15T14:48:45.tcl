# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Apr 15 14:48:45 2015
# Designs open: 1
#   V1: /u/ey/rherbst/projects/w_si/drf/inter.vpd
# Toplevel windows open: 1
# 	TopLevel.1
#   Source.1: /KPIXSMALLTB
#   Group count = 5
#   Group Group1 signal count = 0
#   Group Group2 signal count = 0
#   Group Group3 signal count = 0
#   Group Group4 signal count = 0
#   Group U_ASICSIM signal count = 29
# End_DVE_Session_Save_Info

# DVE version: G-2012.09
# DVE build date: Aug 24 2012 00:30:46


#<Session mode="Full" path="/afs/slac.stanford.edu/u/ey/rherbst/projects/w_si/drf/kpixSw_3.00/scripts/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE Topleve session: 


# Create and position top-level windows :TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{16 36} {1271 911}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_set_toolbar_attributes -toolbar {&File} -dock_state top
gui_set_toolbar_attributes -toolbar {&File} -offset 0
gui_show_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_set_toolbar_attributes -toolbar {BackTrace} -dock_state top
gui_set_toolbar_attributes -toolbar {BackTrace} -offset 0
gui_show_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 441]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 441
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 440} {height 514} {dock_state left} {dock_on_new_line true} {child_hier_colhier 349} {child_hier_coltype 123} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 489]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 489
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 514
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 488} {height 514} {dock_state left} {dock_on_new_line true} {child_data_colvariable 216} {child_data_colvalue 176} {child_data_coltype 116} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 239]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1220
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 239
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1255} {height 238} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { ![gui_is_db_opened -db {/u/ey/rherbst/projects/w_si/drf/inter.vpd}] } {
	gui_open_db -design V1 -file /u/ey/rherbst/projects/w_si/drf/inter.vpd -nosource
}
gui_set_precision 1ps
gui_set_time_units 1ps
#</Database>

# DVE Global setting session: 


# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {/KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM}


set _session_group_1 Group1
gui_sg_create "$_session_group_1"
set Group1 "$_session_group_1"


set _session_group_2 Group2
gui_sg_create "$_session_group_2"
set Group2 "$_session_group_2"


set _session_group_3 Group3
gui_sg_create "$_session_group_3"
set Group3 "$_session_group_3"


set _session_group_4 Group4
gui_sg_create "$_session_group_4"
set Group4 "$_session_group_4"


set _session_group_5 U_ASICSIM
gui_sg_create "$_session_group_5"
set U_ASICSIM "$_session_group_5"

gui_sg_addsignal -group "$_session_group_5" { /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/OFFSET_NULL /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/ANA_RDBACK /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/ANALOG_STATE /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/PWR_UP_ACQ /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/RESET_LOAD /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/RESET_L /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/REG_WR_ENA /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/LEAKAGE_NULL /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/RESET /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/RDBACK /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/REG_CLOCK /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/DATA_OUT /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/THRESH_OFF /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/PRECHARGE_BUS /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/DESEL_ALL_CELLS /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/TRIG_INH /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/COMMAND /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/SYSCLK /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/RAMP_PERIOD /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/PWR_UP_ACQ_DIG /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/REG_SEL0 /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/REG_SEL1 /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/REG_DATA /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/READ_STATE /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/TEMP_EN /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/SEL_CELL /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/DATA_RDBACK /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/CAL_STROBE /KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM/TEMP_ID }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 6474094592



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {UnnamedProcess 1} {Function 1} {Block 1} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {PowSwitch 0} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {IsoCell 0} {ClassDef 1} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} /KPIXSMALLTB}
catch {gui_list_expand -id ${Hier.1} /KPIXSMALLTB/KPIXSIM(0)}
catch {gui_list_select -id ${Hier.1} {/KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM}}
gui_view_scroll -id ${Hier.1} -vertical -set 136
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {/KPIXSMALLTB/KPIXSIM(0)/U_ASICSIM}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 136
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active /KPIXSMALLTB /u/re/bareese/projects/kpix/trunk/firmware/projects/KpixSmall/sim/KpixSmallTb.vhd
gui_view_scroll -id ${Source.1} -vertical -set 180
gui_src_set_reusable -id ${Source.1}
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
#</Session>

