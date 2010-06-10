//------------------------------------------------------------------------------
// Title         : Simulation wrapper for KPIX
// Project       : WSI ASIC
//------------------------------------------------------------------------------
// File          : Kpix.v
// Author        : Ryan Herbst, rherbst@slac.stanford.edu
// Created       : 05/30/2007
//------------------------------------------------------------------------------
// Description:
// This is the simulation wrapper.
//------------------------------------------------------------------------------
// Copyright (c) 2007 by Ryan Herbst. All rights reserved.
//------------------------------------------------------------------------------
// Modification history:
// 05/30/2007: created.
//------------------------------------------------------------------------------
//`timescale 1ns/10ps

// Edge Module Definition
module Kpix ( ext_clk, reset_c, trig, command_c, rdback_p );

   // Master Reset and Clock Signals
   input  wire  ext_clk;
   input  wire  reset_c;
   input  wire  trig;
   input  wire  command_c;
   output wire  rdback_p;

   assign rdback_p = 1'b1;

endmodule 
