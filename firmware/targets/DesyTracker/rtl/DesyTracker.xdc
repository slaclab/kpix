##############################################################################
## This file is part of 'kpix-dev'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'kpix-dev', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################
create_clock -name gtRefClk -period 3.200 [get_ports {gtClkP}]

create_generated_clock -name ethClk [get_pins {U_DesyTrackerEthCore_1/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name ethClkDiv2 [get_pins {U_DesyTrackerEthCore_1/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name ethClk200 [get_pins {U_DesyTrackerEthCore_1/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2}]
create_generated_clock -name refClk156MHz    [get_pins {U_DesyTrackerEthCore_1/U_IBUFDS_GTE2/ODIV2}]

create_generated_clock -name dnaDivClk [get_pins U_AxiVersion_1/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O]
create_generated_clock -name icapClk [get_pins U_AxiVersion_1/GEN_ICAP.Iprog_1/GEN_7SERIES.Iprog7Series_Inst/DIVCLK_GEN.BUFR_ICPAPE2/O]

create_clock -name tluClk -period 25.000 [get_ports {tluClkP}]

create_generated_clock -name tluClk200 [get_pins {U_TluMonitor_1/U_MMCM/PllGen.U_Pll/CLKOUT0}]

#create_generated_clock -name clk200 [get_pins {CLKMUX/O}]
create_generated_clock -name muxEthClk200 -divide_by 1 -add -master_clock ethClk200 -source [get_pins {U_TluMonitor_1/CLKMUX/I0}] [get_pins {U_TluMonitor_1/CLKMUX/O}]
create_generated_clock -name muxTluClk200 -divide_by 1 -add -master_clock tluClk200 -source [get_pins {U_TluMonitor_1/CLKMUX/I1}] [get_pins {U_TluMonitor_1/CLKMUX/O}]

#set_clock_groups -logically_exclusive -group ethClk200 -group tluClk200

#set_case_analysis 1 [get_pins {CLKMUX/S}]
set_false_path -to [get_pins {U_TluMonitor_1/CLKMUX/S0}]

create_generated_clock -name ethKpixClk -divide_by 4 -add -master_clock muxEthClk200 -source [get_pins {U_TluMonitor_1/CLKMUX/O}]  \
    [get_pins {U_KpixDaqCore_1/U_KpixClockGen_1/KPIX_CLK_BUFG/O}]

create_generated_clock -name tluKpixClk -divide_by 4 -add -master_clock muxTluClk200 -source [get_pins {U_TluMonitor_1/CLKMUX/O}]  \
    [get_pins {U_KpixDaqCore_1/U_KpixClockGen_1/KPIX_CLK_BUFG/O}]

set_clock_groups -physically_exclusive \
    -group [get_clocks -include_generated_clocks muxEthClk200] \
    -group [get_clocks -include_generated_clocks muxTluClk200]
#set_clock_groups -logically_exclusive -group tluKpixClk -group ethKpixClk


#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {U_TluMonitor_1/U_MMCM/clkOut[0]}]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks ethClk200] \
    -group [get_clocks -include_generated_clocks ethClk]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks ethClk200] \
    -group [get_clocks -include_generated_clocks ethClkDiv2]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks gtRefClk] \
    -group [get_clocks -include_generated_clocks tluClk]


set_clock_groups -asynchronous \
    -group [get_clocks ethClk] \
    -group [get_clocks refClk156MHz]

set_clock_groups -asynchronous \
    -group [get_clocks ethClk] \
    -group [get_clocks -include_generated_clocks dnaDivClk] \
    -group [get_clocks icapClk]




# TLU
set_property -dict { PACKAGE_PIN E23 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluClkN }];
set_property -dict { PACKAGE_PIN F22 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluClkP }];
set_property -dict { PACKAGE_PIN F23 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluSpillN }];
set_property -dict { PACKAGE_PIN G22 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluSpillP }];
set_property -dict { PACKAGE_PIN B21 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluStartN }];
set_property -dict { PACKAGE_PIN C21 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluStartP }];
set_property -dict { PACKAGE_PIN D24 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluTriggerN }];
set_property -dict { PACKAGE_PIN D23 IOSTANDARD LVDS_25 DIFF_TERM TRUE } [get_ports { tluTriggerP }];
set_property -dict { PACKAGE_PIN G24 IOSTANDARD LVDS_25 } [get_ports { tluBusyP }];
set_property -dict { PACKAGE_PIN F24 IOSTANDARD LVDS_25 } [get_ports { tluBusyN }];

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {tluClkP}]

#set_input_delay -clock tluClk 10 [get_ports {tluSpillP}]
#set_input_delay -clock tluClk 10 [get_ports {tluStartP}]
#set_input_delay -clock tluClk 10 [get_ports {tluTriggerP}]


# KPIX IO
set_property -dict { PACKAGE_PIN M24  IOSTANDARD LVDS_25 } [get_ports { kpixClkP[0] }];
set_property -dict { PACKAGE_PIN L24  IOSTANDARD LVDS_25 } [get_ports { kpixClkN[0] }];
set_property -dict { PACKAGE_PIN U17  IOSTANDARD LVDS_25 } [get_ports { kpixClkP[1] }];
set_property -dict { PACKAGE_PIN T17  IOSTANDARD LVDS_25 } [get_ports { kpixClkN[1] }];
set_property -dict { PACKAGE_PIN W23  IOSTANDARD LVDS_25 } [get_ports { kpixClkP[2] }];
set_property -dict { PACKAGE_PIN W24  IOSTANDARD LVDS_25 } [get_ports { kpixClkN[2] }];
set_property -dict { PACKAGE_PIN AD25 IOSTANDARD LVDS_25 } [get_ports { kpixClkP[3] }];
set_property -dict { PACKAGE_PIN AE25 IOSTANDARD LVDS_25 } [get_ports { kpixClkN[3] }];

set_property -dict { PACKAGE_PIN P19  IOSTANDARD LVDS_25 } [get_ports { kpixTrigP[0] }];
set_property -dict { PACKAGE_PIN P20  IOSTANDARD LVDS_25 } [get_ports { kpixTrigN[0] }];
set_property -dict { PACKAGE_PIN R18  IOSTANDARD LVDS_25 } [get_ports { kpixTrigP[1] }];
set_property -dict { PACKAGE_PIN P18  IOSTANDARD LVDS_25 } [get_ports { kpixTrigN[1] }];
set_property -dict { PACKAGE_PIN AB26 IOSTANDARD LVDS_25 } [get_ports { kpixTrigP[2] }];
set_property -dict { PACKAGE_PIN AC26 IOSTANDARD LVDS_25 } [get_ports { kpixTrigN[2] }];
set_property -dict { PACKAGE_PIN AE22 IOSTANDARD LVDS_25 } [get_ports { kpixTrigP[3] }];
set_property -dict { PACKAGE_PIN AF22 IOSTANDARD LVDS_25 } [get_ports { kpixTrigN[3] }];

set_property -dict { PACKAGE_PIN M20  IOSTANDARD LVCMOS25 } [get_ports { kpixRst[0] }];
set_property -dict { PACKAGE_PIN M19  IOSTANDARD LVCMOS25 } [get_ports { kpixRst[1] }];
set_property -dict { PACKAGE_PIN AB25 IOSTANDARD LVCMOS25 } [get_ports { kpixRst[2] }];
set_property -dict { PACKAGE_PIN AF23 IOSTANDARD LVCMOS25 } [get_ports { kpixRst[3] }];

set_property -dict { PACKAGE_PIN K25  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[0][0] }];
set_property -dict { PACKAGE_PIN R26  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[0][1] }];
set_property -dict { PACKAGE_PIN M25  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[0][2] }];
set_property -dict { PACKAGE_PIN P24  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[0][3] }];
set_property -dict { PACKAGE_PIN N26  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[0][4] }];
set_property -dict { PACKAGE_PIN R25  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[0][5] }];
set_property -dict { PACKAGE_PIN T20  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[1][0] }];
set_property -dict { PACKAGE_PIN T22  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[1][1] }];
set_property -dict { PACKAGE_PIN U19  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[1][2] }];
set_property -dict { PACKAGE_PIN T18  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[1][3] }];
set_property -dict { PACKAGE_PIN P16  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[1][4] }];
set_property -dict { PACKAGE_PIN R16  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[1][5] }];
set_property -dict { PACKAGE_PIN U22  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[2][0] }];
set_property -dict { PACKAGE_PIN U24  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[2][1] }];
set_property -dict { PACKAGE_PIN V23  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[2][2] }];
set_property -dict { PACKAGE_PIN U26  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[2][3] }];
set_property -dict { PACKAGE_PIN W25  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[2][4] }];
set_property -dict { PACKAGE_PIN V21  IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[2][5] }];
set_property -dict { PACKAGE_PIN AD23 IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[3][0] }];
set_property -dict { PACKAGE_PIN AB22 IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[3][1] }];
set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[3][2] }];
set_property -dict { PACKAGE_PIN AD21 IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[3][3] }];
set_property -dict { PACKAGE_PIN AF24 IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[3][4] }];
set_property -dict { PACKAGE_PIN AD26 IOSTANDARD LVCMOS25 } [get_ports { kpixCmd[3][5] }];

set_property -dict { PACKAGE_PIN K26  IOSTANDARD LVCMOS25 } [get_ports { kpixData[0][0] }];
set_property -dict { PACKAGE_PIN P26  IOSTANDARD LVCMOS25 } [get_ports { kpixData[0][1] }];
set_property -dict { PACKAGE_PIN L25  IOSTANDARD LVCMOS25 } [get_ports { kpixData[0][2] }];
set_property -dict { PACKAGE_PIN N24  IOSTANDARD LVCMOS25 } [get_ports { kpixData[0][3] }];
set_property -dict { PACKAGE_PIN M26  IOSTANDARD LVCMOS25 } [get_ports { kpixData[0][4] }];
set_property -dict { PACKAGE_PIN P25  IOSTANDARD LVCMOS25 } [get_ports { kpixData[0][5] }];
set_property -dict { PACKAGE_PIN R20  IOSTANDARD LVCMOS25 } [get_ports { kpixData[1][0] }];
set_property -dict { PACKAGE_PIN T23  IOSTANDARD LVCMOS25 } [get_ports { kpixData[1][1] }];
set_property -dict { PACKAGE_PIN U20  IOSTANDARD LVCMOS25 } [get_ports { kpixData[1][2] }];
set_property -dict { PACKAGE_PIN T19  IOSTANDARD LVCMOS25 } [get_ports { kpixData[1][3] }];
set_property -dict { PACKAGE_PIN N17  IOSTANDARD LVCMOS25 } [get_ports { kpixData[1][4] }];
set_property -dict { PACKAGE_PIN R17  IOSTANDARD LVCMOS25 } [get_ports { kpixData[1][5] }];
set_property -dict { PACKAGE_PIN V22  IOSTANDARD LVCMOS25 } [get_ports { kpixData[2][0] }];
set_property -dict { PACKAGE_PIN U25  IOSTANDARD LVCMOS25 } [get_ports { kpixData[2][1] }];
set_property -dict { PACKAGE_PIN V24  IOSTANDARD LVCMOS25 } [get_ports { kpixData[2][2] }];
set_property -dict { PACKAGE_PIN V26  IOSTANDARD LVCMOS25 } [get_ports { kpixData[2][3] }];
set_property -dict { PACKAGE_PIN W26  IOSTANDARD LVCMOS25 } [get_ports { kpixData[2][4] }];
set_property -dict { PACKAGE_PIN W21  IOSTANDARD LVCMOS25 } [get_ports { kpixData[2][5] }];
set_property -dict { PACKAGE_PIN AD24 IOSTANDARD LVCMOS25 } [get_ports { kpixData[3][0] }];
set_property -dict { PACKAGE_PIN AC22 IOSTANDARD LVCMOS25 } [get_ports { kpixData[3][1] }];
set_property -dict { PACKAGE_PIN AC21 IOSTANDARD LVCMOS25 } [get_ports { kpixData[3][2] }];
set_property -dict { PACKAGE_PIN AE21 IOSTANDARD LVCMOS25 } [get_ports { kpixData[3][3] }];
set_property -dict { PACKAGE_PIN AF25 IOSTANDARD LVCMOS25 } [get_ports { kpixData[3][4] }];
set_property -dict { PACKAGE_PIN AE26 IOSTANDARD LVCMOS25 } [get_ports { kpixData[3][5] }];

set_input_delay  -clock muxEthClk200 6 [get_ports kpixData[*][*]];
#set_output_delay -clock muxEthClk200 6 [get_ports kpixCmd[*][*]];
set_output_delay -clock muxEthClk200 6 [get_ports kpixTrigP[*]];

set_input_delay  -clock muxTluClk200 6 [get_ports kpixData[*][*]] -add_delay;
#set_output_delay -clock muxTluClk200 6 [get_ports kpixCmd[*][*]] -add_delay;
set_output_delay -clock muxTluClk200 6 [get_ports kpixTrigP[*]] -add_delay;

#set_output_delay -clock kpixClk 4 [get_ports kpixClkP[*]];
set_property IOB TRUE [get_ports kpixCmd[*][*]]
set_property IOB TRUE [get_ports kpixData[*][*]]

# Cassette I2C
set_property -dict { PACKAGE_PIN M21 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteSda[0] }];
set_property -dict { PACKAGE_PIN M22 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteScl[0] }];
set_property -dict { PACKAGE_PIN T24 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteSda[1] }];
set_property -dict { PACKAGE_PIN T25 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteScl[1] }];
set_property -dict { PACKAGE_PIN Y25 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteSda[2] }];
set_property -dict { PACKAGE_PIN Y26 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteScl[2] }];
set_property -dict { PACKAGE_PIN W20 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteSda[3] }];
set_property -dict { PACKAGE_PIN Y21 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports { cassetteScl[3] }];


# External IO
set_property -dict { PACKAGE_PIN H23 IOSTANDARD LVCMOS25 } [get_ports { bncTrigL }];
set_property -dict { PACKAGE_PIN J26 IOSTANDARD LVCMOS25 } [get_ports { bncDebug }];
set_property -dict { PACKAGE_PIN H26 IOSTANDARD LVCMOS25 } [get_ports { bncBusy }];
set_property -dict { PACKAGE_PIN H21 IOSTANDARD LVCMOS25 } [get_ports { lemoIn[0] }];
set_property -dict { PACKAGE_PIN G21 IOSTANDARD LVCMOS25 } [get_ports { lemoIn[1] }];

# MGT Mapping
# PGP Port Mapping
set_property PACKAGE_PIN D6 [get_ports {gtClkP}]
set_property PACKAGE_PIN D5 [get_ports {gtClkN}]

set_property PACKAGE_PIN F2 [get_ports {gtTxP}]
set_property PACKAGE_PIN F1 [get_ports {gtTxN}]
set_property PACKAGE_PIN G4 [get_ports {gtRxP}]
set_property PACKAGE_PIN G3 [get_ports {gtRxN}]

# SLAC Timing Port Mapping
# set_property PACKAGE_PIN H6 [get_ports {evrClkP}]
# set_property PACKAGE_PIN H5 [get_ports {evrClkN}]

# set_property PACKAGE_PIN P2 [get_ports {evrTxP}]
# set_property PACKAGE_PIN P1 [get_ports {evrTxN}]
# set_property PACKAGE_PIN R4 [get_ports {evrRxP}]
# set_property PACKAGE_PIN R3 [get_ports {evrRxN}]

# Boot Memory Port Mapping
set_property -dict { PACKAGE_PIN C23 IOSTANDARD LVCMOS25 } [get_ports { bootCsL }];
set_property -dict { PACKAGE_PIN B24 IOSTANDARD LVCMOS25 } [get_ports { bootMosi }];
set_property -dict { PACKAGE_PIN A25 IOSTANDARD LVCMOS25 } [get_ports { bootMiso }];

# LEDs
set_property -dict { PACKAGE_PIN E25 IOSTANDARD LVCMOS25 } [get_ports { red[0] }];
set_property -dict { PACKAGE_PIN D25 IOSTANDARD LVCMOS25 } [get_ports { blue[0] }];
set_property -dict { PACKAGE_PIN G25 IOSTANDARD LVCMOS25 } [get_ports { green[0] }];
set_property -dict { PACKAGE_PIN G26 IOSTANDARD LVCMOS25 } [get_ports { red[1] }];
set_property -dict { PACKAGE_PIN F25 IOSTANDARD LVCMOS25 } [get_ports { blue[1] }];
set_property -dict { PACKAGE_PIN E26 IOSTANDARD LVCMOS25 } [get_ports { green[1] }];
set_property -dict { PACKAGE_PIN L22 IOSTANDARD LVCMOS25 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN K22 IOSTANDARD LVCMOS25 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN K23 IOSTANDARD LVCMOS25 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN J23 IOSTANDARD LVCMOS25 } [get_ports { led[3] }];

# I2C PROM
set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS25 } [get_ports { promScl }];
set_property -dict { PACKAGE_PIN E21 IOSTANDARD LVCMOS25 } [get_ports { promSda }];

# OSC EN
set_property -dict { PACKAGE_PIN J24 IOSTANDARD LVCMOS25 } [get_ports { oscOe[0] }];
set_property -dict { PACKAGE_PIN J25 IOSTANDARD LVCMOS25 } [get_ports { oscOe[1] }];

# Power sync (probably unused)
set_property -dict { PACKAGE_PIN C24 IOSTANDARD LVCMOS25 } [get_ports { pwrSyncSclk }];
set_property -dict { PACKAGE_PIN D21 IOSTANDARD LVCMOS25 } [get_ports { pwrSyncFclk }];

# Power status I2C
set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS25 } [get_ports { pwrScl }];
set_property -dict { PACKAGE_PIN B20 IOSTANDARD LVCMOS25 } [get_ports { pwrSda }];
set_property -dict { PACKAGE_PIN K21 IOSTANDARD LVCMOS25 } [get_ports { tempAlertL }];



set_property CFGBVS VCCO                     [current_design]
set_property CONFIG_VOLTAGE 2.5              [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33  [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]

