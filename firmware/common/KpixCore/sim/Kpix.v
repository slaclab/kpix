//////////////////////////////////////////////////////////////////////////////
// This file is part of 'kpix-dev'.
// It is subject to the license terms in the LICENSE.txt file found in the 
// top-level directory of this distribution and at: 
//    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
// No part of 'kpix-dev', including this file, 
// may be copied, modified, propagated, or distributed except according to 
// the terms contained in the LICENSE.txt file.
//////////////////////////////////////////////////////////////////////////////
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
