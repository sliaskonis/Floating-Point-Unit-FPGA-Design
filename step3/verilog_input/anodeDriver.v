`timescale 1ns/1ps

// 4-Bit Rotational Counter: Counters value 
// decreased by one at each posedge clock signal
module anodeDriver(reset, clk, an0, an1, count);

input clk, reset;
output reg an0, an1;
output reg [4:0]count;

wire [4:0] countNext;                       // countNext -> counter's next value

assign countNext = count - 5'b00001;

// Control counter's value
always @(posedge clk or posedge reset) 
begin 
    if (reset)
        count <= 5'b11111;                   // When Reset is set to 1 initialize counter to value 4'b1111
    else 
        count <= countNext;                  // Assign counter its next value               
end

always @(count)                                
begin                                           
    if (count[4] == 1'b1)begin
        an0 = 0;
        an1 = 1;
    end
    else begin//if (count[4] == 1'b0)begin
        an0 = 1;
        an1 = 0;
    end
    //else begin
    //    an0 = 1;
    //    an1 = 1;
    //end
end

endmodule