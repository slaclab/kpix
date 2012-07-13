#!/usr/local/bin/perl
#-----------------------------------------------------------------------------
# Title         : ADC Test FPGA Build Script
#-----------------------------------------------------------------------------
# File          : buildAdcTest.tcl
# Author        : Ryan Herbst, rherbst@slac.stanford.edu
# Created       : -7/06/2009
#-----------------------------------------------------------------------------
# Description:
# This script is called in the following manner:
# perl buildOpto.pl proj_top_dir output_dir [syn tran map par time bit prom]
# 
# Include the following optional suffixes, if none are passed the default set
# is assumed.
# syn  = Execute synthesis step. (default) 
# tran = Execute translate step. (default) 
# map  = Execute map step. (default) 
# par  = Execute plac & route step. (default) 
# time = Execute timing report step. (default) 
# bit  = Execute bit file generation step. (default)
# prom = Execute prom file generation step. (default) 
#-----------------------------------------------------------------------------
# Copyright (c) 2004 by Ryan Herbst. All rights reserved.
#-----------------------------------------------------------------------------
# Modification history:
# 07/06/2009: created.
#-----------------------------------------------------------------------------

# Source Directory
$SrcDir = "/u/ey/rherbst/projects/w_si/fpgas/AdcTest";
$OutDir = "/u1/w_si/build/adc_test";

# Project name, used for input/output file names. $Project.edn must match the 
# file name set for the output EDIF file in MasterSyn.tcl
$Project = "adctest";

# Synplicity Batch File
$SynScript = "scripts/AdcTestSyn.tcl";

# Core directory
$CoreDir = "cores";

#
# Translate Options
#

# UCF FIle, set in reference to top level directory.
$UcfFile  = "rtl/AdcTest.ucf";

# Set Target Device
$Target = "xc3s400-pq208-4";

#
# Map Options
#

# Cover Mode: area, speed or balanced
$MapCover = "balanced";

# Pack FF Mode: i, o or b
$MapPack = "b";

# Function Size: 4,5,6,7 or 8
$MapFunc = "4";

# Pack Factor: 0 - 100
$MapFactor = "100";

# Tristate Tranformation Mode: on, off, agressive or limit
$MapTristate = "off";

# Effort Level: std, med or high
$MapEffort = "high";

#
# Place & Route Options
#

# Overall Place & Route Level: std, med, high
$ParLevel = "high";

# Place & Route Start Table Entry
$ParTable = "1";

# Number of Place & Route Iterations to run
$ParCount = "1";

# Number of Place & Route Iterations to save
$ParSave = "1";

#
# Timing report options
#

# Timing Report Type: e or v (error or verbose)
$TwrType = "v";

# Timing Report Error/Verbose Count
$TwrCount = "10";

# Timing Report Limit
$TwrLimit = "10";

#
# Prom File Genreation Options
#

# Prom Type For Generation
$PromType = "xcf04s";


#################### END CONFIG SECTION ####################
use Cwd;

# Get build directory
$dstdir = $OutDir;

# Process the remaining compile flags
if ( @ARGV > 0 ) {
   $doSyn  = 0; $doTran = 0; $doMap  = 0; $doPar  = 0;
   $doTime = 0; $doBit  = 0; $doProm = 0; $doSim  = 0;
   $doZip  = 0;

   foreach $arg ( @ARGV ) {
      if ( $arg =~ /syn/  ) { $doSyn  = 1; }
      if ( $arg =~ /tran/ ) { $doTran = 1; }
      if ( $arg =~ /map/  ) { $doMap  = 1; }
      if ( $arg =~ /par/  ) { $doPar  = 1; }
      if ( $arg =~ /time/ ) { $doTime = 1; }
      if ( $arg =~ /bit/  ) { $doBit  = 1; }
      if ( $arg =~ /prom/ ) { $doProm = 1; }
   }
}

# Use defaults
else {
   $doSyn  = 1; $doTran = 1; $doMap  = 1;
   $doPar  = 1; $doTime = 1; $doBit  = 1;
   $doProm = 1; $doSim  = 0; $doZip  = 1;
}


# Attempt to create build directory, change to build directory
mkdir $dstdir || dir ("Could Not Create Build Directory: $dstdir");
chdir($dstdir);

# Set source directory in environment, needed by synplify script
$ENV{'SRCDIR'} = $SrcDir;

# Print Header String
print "\n===== Build Script Started\n";
print "      Src=$SrcDir, Dest=$dstdir\n\n";

# Do we synthesize?
if ($doSyn == 1) {

   # Synthesize using synplicity
   print "\n===== Starting Synthesis.\n\n";
   system ("synplify_pro","-batch","$SrcDir/$SynScript") == 0 or
      die ("Synthesis Failed.\n\n");
   print "===== Synthesis Complete.\n\n";
}


# Do we translate?
if ($doTran == 1) {

   print "\n===== Starting Translate.\n\n";
   system ("ngdbuild","-p","$Target","-sd","$SrcDir/$CoreDir","-dd","_ngo",
           "-nt","timestamp","-uc","$SrcDir/$UcfFile","-intstyle","ise",
           "syn/$Project.edn","$Project.ngd") == 0 
           or die ("\n===== Translate Failed.\n\n");
   print "\n===== Translate Complete.\n\n";
}


# Do we map?
if ($doMap == 1) {

   $map_file = $Project . "_map.ncd";
   print "\n===== Starting Map.\n\n";
   system ("map","-intstyle","ise","-p","$Target","-cm","$MapCover",
           "-detail","-pr","$MapPack","-k","$MapFunc","-c","$MapFactor","-tx","$MapTristate",
           "-ol","$MapEffort","-o","$map_file","$Project.ngd","$Project.pcf") == 0
           or die ("\n===== Map Failed.\n\n");
   print "\n===== Map Complete.\n\n";
}


# Do we place & route
if ($doPar) {

   $map_file = $Project . "_map.ncd";
   print "\n===== Starting Place & Route.\n";
   system ("par","-w","-intstyle","ise", "-ol","$ParLevel","-t","$ParTable",
           "-s","$ParSave","-n","$ParCount","$map_file","$Project.ncd",
           "$Project.pcf") == 0 or die ("\n===== Place & Route Failed.\n\n");
   print "\n===== Place & Route Complete.\n\n";
}


# Do we generate timing report?
if ($doTime) {

   # Create Timing Report Type
   $twropt = "-"."$TwrType";

   # Execute Command
   print "\n===== Starting Timing Report.\n";
   system ("trce","-intstyle","ise","$twropt","$TwrCount","-l","$TwrLimit",
           "$Project.ncd","-o","$Project.twr","$Project.pcf")
           == 0 or die ("\n===== Timing Report Failed.\n\n");
   print "\n===== Timing Report Complete.\n\n";
}


# Do we generate bit file
if ($doBit) {

   # Execute Command
   print "\n===== Starting Bitgen.\n";
   system ("bitgen","-w","-intstyle","ise","$Project.ncd") == 0
           or die ("\n===== Bitgen Failed.\n\n");
   print "\n===== Bitgen Complete.\n\n";
}


# Do we generate prom file
if ($doProm) {
   print "\n===== Starting Prom Gen.\n";
   system ("promgen","-w","-p","mcs","-c","FF","-u","0","$Project.bit",
           "-x","$PromType") == 0
           or die ("\n===== Prom Build Failed.\n\n");
   print "\n===== Prom Gen Complete.\n\n";
}


