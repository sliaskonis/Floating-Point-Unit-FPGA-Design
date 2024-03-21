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
     
   // Try this addition of FP numbers 
   // 6b64b235 + 6ac49214 = 6ba37d9f 
   
   // Instantiate the FP adder 
        
   assign leds = fp_out[7:0];
   
   // Instantiate the 7segment display output 0 
  
   
   // Instantiate the 7segment display output 1


endmodule
