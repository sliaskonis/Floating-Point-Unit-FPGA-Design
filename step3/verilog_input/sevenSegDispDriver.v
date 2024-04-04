`timescale 1ns/1ps

//LED Decoder: 4-bit LED decoder used to decode each digit to 
//8 signals controlling each segment of the display (+ the decimal point)
module LEDdecoder(char, LED);

input [3:0] char;
output reg [6:0] LED;

always @(char)
begin
    case (char)        
        4'b0000: LED = 7'b1111110;     // 0
        4'b0001: LED = 7'b0110000;     // 1
        4'b0010: LED = 7'b1101101;     // 2   
        4'b0011: LED = 7'b1111001;     // 3
        4'b0100: LED = 7'b0110011;     // 4
        4'b0101: LED = 7'b1011011;     // 5
        4'b0110: LED = 7'b1011111;     // 6
        4'b0111: LED = 7'b1110000;     // 7
        4'b1000: LED = 7'b1111111;     // 8
        4'b1001: LED = 7'b1111011;     // 9
        4'b1010: LED = 7'b1110111;     // A
        4'b1011: LED = 7'b0011111;     // b
        4'b1100: LED = 7'b1001110;     // C
        4'b1101: LED = 7'b0111101;     // d
        4'b1110: LED = 7'b1001111;     // E
        4'b1111: LED = 7'b1000111;     // F
    endcase
end
endmodule

module sevenSegDispDriver(clk, rst, char, anode, LED);

input clk, rst;
input [7:0] char;
output reg anode;
output reg [6:0] LED;

reg [4:0] count;

wire [6:0] digit0, digit1;
wire [3:0] char0, char1;
wire [4:0] countNext;                      

assign char0 = char[7:4];
assign char1 = char[3:0];
assign countNext = count - 5'b00001;

// Decode each digit
LEDdecoder LEDdecoder0(char0, digit0);
LEDdecoder LEDdecoder1(char1, digit1);

// Control counter's value
always @(posedge clk or posedge rst) 
begin 
    if (rst)
        count <= 5'b11111;                   // When Reset is set to 1 initialize counter to value 4'b1111
    else 
        count <= countNext;                  // Assign counter its next value               
end

always @(count)                                
begin                                           
    if (count[4] == 1'b1)
        anode = 1'b0;
    else
        anode = 1'b1;
end

always @(anode or digit0 or digit1)
begin
    if (anode == 1'b1)
        LED = digit0;
    else
        LED = digit1;
end
endmodule

