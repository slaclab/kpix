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
