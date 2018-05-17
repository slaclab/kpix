create_clock -name gtRefClk -period 3.200 [get_ports {gtClkP}]

create_generated_clock -name ethClk [get_pins {U_DesyTrackerEthCore_1/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name ethClkDiv2 [get_pins {U_DesyTrackerEthCore_1/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name clk200 [get_pins {U_DesyTrackerEthCore_1/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2}]
create_generated_clock -name refClk156MHz    [get_pins {U_DesyTrackerEthCore_1/U_IBUFDS_GTE2/ODIV2}]  

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks clk200] \
    -group [get_clocks -include_generated_clocks ethClk]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks clk200] \
    -group [get_clocks -include_generated_clocks ethClkDiv2]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks clk200] \
    -group [get_clocks -include_generated_clocks refClk156MHz]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks ethClk] \
    -group [get_clocks -include_generated_clocks refClk156MHz]


# TLU
set_property -dict { PACKAGE_PIN AC9  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluClkP }];
set_property -dict { PACKAGE_PIN AD9  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluClkN }];
set_property -dict { PACKAGE_PIN AA9  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluSpillP }];
set_property -dict { PACKAGE_PIN AB9  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluSpillN }];
set_property -dict { PACKAGE_PIN AB7  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluStartP }];
set_property -dict { PACKAGE_PIN AC7  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluStartN }];
set_property -dict { PACKAGE_PIN AC8  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluTriggerP }];
set_property -dict { PACKAGE_PIN AD8  IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { tluTriggerN }];
set_property -dict { PACKAGE_PIN AB11 IOSTANDARD LVDS } [get_ports { tluBusyP }];
set_property -dict { PACKAGE_PIN AC11 IOSTANDARD LVDS } [get_ports { tluBusyN }];

# KPIX IO
set_property -dict { PACKAGE_PIN AE7  IOSTANDARD LVDS } [get_ports { kpixClkP[0] }];
set_property -dict { PACKAGE_PIN AF7  IOSTANDARD LVDS } [get_ports { kpixClkN[0] }];
set_property -dict { PACKAGE_PIN AE8  IOSTANDARD LVDS } [get_ports { kpixClkP[1] }];
set_property -dict { PACKAGE_PIN AF8  IOSTANDARD LVDS } [get_ports { kpixClkN[1] }];
set_property -dict { PACKAGE_PIN Y3   IOSTANDARD LVDS } [get_ports { kpixClkP[2] }];
set_property -dict { PACKAGE_PIN Y2   IOSTANDARD LVDS } [get_ports { kpixClkN[2] }];
set_property -dict { PACKAGE_PIN AE3  IOSTANDARD LVDS } [get_ports { kpixClkP[3] }];
set_property -dict { PACKAGE_PIN AE2  IOSTANDARD LVDS } [get_ports { kpixClkN[3] }];

set_property -dict { PACKAGE_PIN AA8  IOSTANDARD LVDS } [get_ports { kpixTrigP[0] }];
set_property -dict { PACKAGE_PIN AA7  IOSTANDARD LVDS } [get_ports { kpixTrigN[0] }];
set_property -dict { PACKAGE_PIN AE13 IOSTANDARD LVDS } [get_ports { kpixTrigP[1] }];
set_property -dict { PACKAGE_PIN AF13 IOSTANDARD LVDS } [get_ports { kpixTrigN[1] }];
set_property -dict { PACKAGE_PIN V2   IOSTANDARD LVDS } [get_ports { kpixTrigP[2] }];
set_property -dict { PACKAGE_PIN v1   IOSTANDARD LVDS } [get_ports { kpixTrigN[2] }];
set_property -dict { PACKAGE_PIN AE6  IOSTANDARD LVDS } [get_ports { kpixTrigP[3] }];
set_property -dict { PACKAGE_PIN AE5  IOSTANDARD LVDS } [get_ports { kpixTrigN[3] }];

set_property -dict { PACKAGE_PIN U9   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[0][0] }];
set_property -dict { PACKAGE_PIN W11  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[0][1] }];
set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[0][2] }];
set_property -dict { PACKAGE_PIN W9   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[0][3] }];
set_property -dict { PACKAGE_PIN Y7   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[0][4] }];
set_property -dict { PACKAGE_PIN Y10  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[0][5] }];
set_property -dict { PACKAGE_PIN AB12 IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[1][0] }];
set_property -dict { PACKAGE_PIN AA13 IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[1][1] }];
set_property -dict { PACKAGE_PIN AC13 IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[1][2] }];
set_property -dict { PACKAGE_PIN Y13  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[1][3] }];
set_property -dict { PACKAGE_PIN AD11 IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[1][4] }];
set_property -dict { PACKAGE_PIN AD10 IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[1][5] }];
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[2][0] }];
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[2][1] }];
set_property -dict { PACKAGE_PIN U1   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[2][2] }];
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[2][3] }];
set_property -dict { PACKAGE_PIN W3   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[2][4] }];
set_property -dict { PACKAGE_PIN V6   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[2][5] }];
set_property -dict { PACKAGE_PIN AA5  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[3][0] }];
set_property -dict { PACKAGE_PIN AB6  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[3][1] }];
set_property -dict { PACKAGE_PIN Y6   IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[3][2] }];
set_property -dict { PACKAGE_PIN AD6  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[3][3] }];
set_property -dict { PACKAGE_PIN AD4  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[3][4] }];
set_property -dict { PACKAGE_PIN AD1  IOSTANDARD LVCMOS18 } [get_ports { kpixCmd[3][5] }];

set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS18 } [get_ports { kpixData[0][0] }];
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS18 } [get_ports { kpixData[0][1] }];
set_property -dict { PACKAGE_PIN W10  IOSTANDARD LVCMOS18 } [get_ports { kpixData[0][2] }];
set_property -dict { PACKAGE_PIN Y8   IOSTANDARD LVCMOS18 } [get_ports { kpixData[0][3] }];
set_property -dict { PACKAGE_PIN Y11  IOSTANDARD LVCMOS18 } [get_ports { kpixData[0][4] }];
set_property -dict { PACKAGE_PIN V9   IOSTANDARD LVCMOS18 } [get_ports { kpixData[0][5] }];
set_property -dict { PACKAGE_PIN AC12 IOSTANDARD LVCMOS18 } [get_ports { kpixData[1][0] }];
set_property -dict { PACKAGE_PIN AA12 IOSTANDARD LVCMOS18 } [get_ports { kpixData[1][1] }];
set_property -dict { PACKAGE_PIN AD13 IOSTANDARD LVCMOS18 } [get_ports { kpixData[1][2] }];
set_property -dict { PACKAGE_PIN Y12  IOSTANDARD LVCMOS18 } [get_ports { kpixData[1][3] }];
set_property -dict { PACKAGE_PIN AE11 IOSTANDARD LVCMOS18 } [get_ports { kpixData[1][4] }];
set_property -dict { PACKAGE_PIN AE10 IOSTANDARD LVCMOS18 } [get_ports { kpixData[1][5] }];
set_property -dict { PACKAGE_PIN U6   IOSTANDARD LVCMOS18 } [get_ports { kpixData[2][0] }];
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS18 } [get_ports { kpixData[2][1] }];
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS18 } [get_ports { kpixData[2][2] }];
set_property -dict { PACKAGE_PIN V3   IOSTANDARD LVCMOS18 } [get_ports { kpixData[2][3] }];
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS18 } [get_ports { kpixData[2][4] }];
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS18 } [get_ports { kpixData[2][5] }];
set_property -dict { PACKAGE_PIN AB5  IOSTANDARD LVCMOS18 } [get_ports { kpixData[3][0] }];
set_property -dict { PACKAGE_PIN AC6  IOSTANDARD LVCMOS18 } [get_ports { kpixData[3][1] }];
set_property -dict { PACKAGE_PIN Y5   IOSTANDARD LVCMOS18 } [get_ports { kpixData[3][2] }];
set_property -dict { PACKAGE_PIN AD5  IOSTANDARD LVCMOS18 } [get_ports { kpixData[3][3] }];
set_property -dict { PACKAGE_PIN AD3  IOSTANDARD LVCMOS18 } [get_ports { kpixData[3][4] }];
set_property -dict { PACKAGE_PIN AE1  IOSTANDARD LVCMOS18 } [get_ports { kpixData[3][5] }];

# Cassette I2C
set_property -dict { PACKAGE_PIN AB1 IOSTANDARD LVCMOS18 } [get_ports { cassetteSda[0] }];
set_property -dict { PACKAGE_PIN AC1 IOSTANDARD LVCMOS18 } [get_ports { cassetteScl[0] }];
set_property -dict { PACKAGE_PIN W1  IOSTANDARD LVCMOS18 } [get_ports { cassetteSda[1] }];
set_property -dict { PACKAGE_PIN Y1  IOSTANDARD LVCMOS18 } [get_ports { cassetteScl[1] }];
set_property -dict { PACKAGE_PIN AB2 IOSTANDARD LVCMOS18 } [get_ports { cassetteSda[2] }];
set_property -dict { PACKAGE_PIN AC2 IOSTANDARD LVCMOS18 } [get_ports { cassetteScl[2] }];
set_property -dict { PACKAGE_PIN AA3 IOSTANDARD LVCMOS18 } [get_ports { cassetteSda[3] }];
set_property -dict { PACKAGE_PIN AA2 IOSTANDARD LVCMOS18 } [get_ports { cassetteScl[3] }];
set_property -dict { PACKAGE_PIN AA4 IOSTANDARD LVCMOS18 } [get_ports { cassetteI2cEn[0] }];
set_property -dict { PACKAGE_PIN AB4 IOSTANDARD LVCMOS18 } [get_ports { cassetteI2cEn[1] }];
set_property -dict { PACKAGE_PIN AC4 IOSTANDARD LVCMOS18 } [get_ports { cassetteI2cEn[2] }];
set_property -dict { PACKAGE_PIN AC3 IOSTANDARD LVCMOS18 } [get_ports { cassetteI2cEn[3] }];


# External IO
set_property -dict { PACKAGE_PIN F23 IOSTANDARD LVCMOS33 } [get_ports { bncTrigL }];
set_property -dict { PACKAGE_PIN J26 IOSTANDARD LVCMOS33 } [get_ports { bncDebug }];
set_property -dict { PACKAGE_PIN H26 IOSTANDARD LVCMOS33 } [get_ports { bncBusy }];
set_property -dict { PACKAGE_PIN H21 IOSTANDARD LVCMOS33 } [get_ports { lemoIn[0] }];
set_property -dict { PACKAGE_PIN G21 IOSTANDARD LVCMOS33 } [get_ports { lemoIn[1] }];

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
set_property -dict { PACKAGE_PIN C23 IOSTANDARD LVCMOS33 } [get_ports { bootCsL }];
set_property -dict { PACKAGE_PIN B24 IOSTANDARD LVCMOS33 } [get_ports { bootMosi }];
set_property -dict { PACKAGE_PIN A25 IOSTANDARD LVCMOS33 } [get_ports { bootMiso }];

# LEDs
set_property -dict { PACKAGE_PIN E25 IOSTANDARD LVCMOS33 } [get_ports { red[0] }];
set_property -dict { PACKAGE_PIN D25 IOSTANDARD LVCMOS33 } [get_ports { blue[0] }];
set_property -dict { PACKAGE_PIN G25 IOSTANDARD LVCMOS33 } [get_ports { green[0] }];
set_property -dict { PACKAGE_PIN G26 IOSTANDARD LVCMOS33 } [get_ports { red[1] }];
set_property -dict { PACKAGE_PIN F25 IOSTANDARD LVCMOS33 } [get_ports { blue[1] }];
set_property -dict { PACKAGE_PIN E26 IOSTANDARD LVCMOS33 } [get_ports { green[1] }];
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS25 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS25 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN D11 IOSTANDARD LVCMOS25 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS25 } [get_ports { led[3] }];

# I2C PROM
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { promScl }];
set_property -dict { PACKAGE_PIN H18 IOSTANDARD LVCMOS33 } [get_ports { promSda }];

# OSC EN
set_property -dict { PACKAGE_PIN J24 IOSTANDARD LVCMOS33 } [get_ports { oscOe[0] }];
set_property -dict { PACKAGE_PIN J25 IOSTANDARD LVCMOS33 } [get_ports { oscOe[1] }];

# Power sync (probably unused)
set_property -dict { PACKAGE_PIN C24 IOSTANDARD LVCMOS33 } [get_ports { pwrSyncSclk }];
set_property -dict { PACKAGE_PIN D21 IOSTANDARD LVCMOS33 } [get_ports { pwrSyncFclk }];

# Power status I2C
set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS33 } [get_ports { pwrScl }];
set_property -dict { PACKAGE_PIN B20 IOSTANDARD LVCMOS33 } [get_ports { pwrSda }];
set_property -dict { PACKAGE_PIN K21 IOSTANDARD LVCMOS33 } [get_ports { tempAlertL }];



