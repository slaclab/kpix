# Synplicity, Inc. constraint file
# H:\fpga\ExoFpgas\rtl\Master\Master.sdc
# Written on Mon Sep 19 17:11:36 2005
# by Synplify Pro, 7.3.3      Scope Editor

#
# Clocks
#
define_clock            -name {n:sysClk125}  -freq 125.000 -clockgroup default_clkgroup
define_clock            -name {n:sysClk200}  -freq 200.000 -clockgroup default_clkgroup
define_clock            -name {n:kpixClk}    -freq  60.000 -clockgroup default_clkgroup
define_clock            -name {n:ddrClk}     -freq 125.000 -clockgroup default_clkgroup
define_clock            -name {n:gtpClk}     -freq 125.000 -clockgroup default_clkgroup
define_clock            -name {n:gtpClkOut}  -freq 125.000 -clockgroup default_clkgroup

# Inter-Clock Delays
define_clock_delay -rise {n:sysClk125} -rise {n:kpixClkIn} 8ns
define_clock_delay -rise {n:sysClk125} -rise {n:kpixClk}   8ns
define_clock_delay -rise {n:kpixClk}   -rise {n:sysClk20}  8ns
define_clock_delay -rise {n:kpixClk}   -rise {n:sysClk200} 8ns

