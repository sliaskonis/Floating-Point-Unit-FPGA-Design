module button_control (clk, button_in, button_out);

input clk, button_in;
output wire button_out;

reg q1, q2;

always @(posedge clk) begin
    q1 <= button_in;
end

always @(posedge clk) begin
    q2 <= q1;
end

assign button_out = q1 & q2;

endmodule