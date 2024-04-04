/*
 -----------------------------------------------------------------------------
 -- File           : fpadd_system.v
 -----------------------------------------------------------------------------
 */ 
 module fpadd_system (input clk,
                      input rst, 
                      // input noisy_level, 
                      output [7:0] leds, 
                      output an0, output a0, output b0, output c0, output d0, output e0, output f0, output g0,
                      output an1, output a1, output b1, output c1, output d1, output e1, output f1, output g1);

   wire [31:0] fp_out;
   wire [7:0] char0, char1;

   // Instantiate the FP adder 
   fpadd_pipelined fpadd_pipelined(.clk(clk), .reset(rst), .reg_A(32'h2ac49214), .reg_B(32'h6ac49214), .out(fp_out));
                                                                                                             
   assign leds = fp_out[7:0];
   assign char0 = fp_out[31:24];
   assign char1 = fp_out[23:16];

   // Instantiate the 7segment display output 0 
   sevenSegDispDriver sevenSegDispDriver0(.char(char0), .anode(an0), .LED({a0, b0, c0, d0, e0, f0, g0}));

   // Instantiate the 7segment display output 1
   sevenSegDispDriver sevenSegDispDriver1(.char(char1), .anode(an1), .LED({a1, b1, c1, d1, e1, f1, g1}));
   
endmodule
