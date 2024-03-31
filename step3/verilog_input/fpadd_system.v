/*
 -----------------------------------------------------------------------------
 -- File           : fpadd_system.v
 -----------------------------------------------------------------------------
 */ 
 module fpadd_system (input clk,
                      input rst, 
                      // input noisy_level, 
                      output [7:0] leds, 
                      output an0, output a0, output b0, output c0, output d0, output e0, output f0, output g0, output fp0,
                      output an1, output a1, output b1, output c1, output d1, output e1, output f1, output g1, output fp1);

   wire [31:0] fp_out;
   wire [7:0] char0, char1;

   // Try this addition of FP numbers 
   // 6b64b235 + 6ac49214 = 6ba37d9f 

   // Instantiate the FP adder 
   fpadd_pipelined fpadd_pipelined(.clk(clk), .reset(rst), .reg_A(32'b01101011010010110010001101010011), .reg_B(32'b01101010110001001001001000010100), .out(fp_out));

   assign leds = fp_out[7:0];
   assign char0 = fp_out[31:24];
   assign char1 = fp_out[23:16];

   // Anode driver
   anodeDriver anodeDriver(.clk(clk), .reset(rst), .an0(an0), .an1(an1));

   // Instantiate the 7segment display output 0 
   sevenSegDispDriver sevenSegDispDriver0(.char(char0), .an0(an0), .an1(an1), .LED({a0, b0, c0, d0, e0, f0, g0, fp0}));
   
   // Instantiate the 7segment display output 1
   sevenSegDispDriver sevenSegDispDriver1(.char(char1), .an0(an0), .an1(an1), .LED({a1, b1, c1, d1, e1, f1, g1, fp1}));
   
endmodule
