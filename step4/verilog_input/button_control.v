module button_control (clk, reset, button_in, button_out);

input clk, reset, button_in;
output reg button_out;

reg [1:0] next_state, current_state;
// reg q1, q2;
reg [23:0] counter;
reg l2p_in;

parameter [1:0] idle = 2'b00,
                pressed = 2'b01,
                pressed_2 = 2'b10;

always @(posedge clk or posedge reset) begin
    if (reset) counter <= 24'b0;        
    else if(button_in) begin
        if(counter == 24'd10000000)
            counter <= 24'd10000000;
        else
            counter <= counter + 1;
    end
    else
        counter <= 24'b0;
end

always @(counter) begin
    if(counter == 24'd10000000)
        l2p_in = 1'b1;
    else
        l2p_in = 1'b0;
end

// FSM type: Moore Machine
always @(posedge clk or posedge reset) begin
    if (reset) current_state <= idle;
    else current_state <= next_state;
end

always @(current_state or l2p_in) begin
    case (current_state)
    idle: begin
        button_out = 1'b0;
        if (l2p_in == 1'b1) next_state = pressed;
        else next_state = idle;
    end
    pressed: begin
        button_out = 1'b1;
        if (l2p_in == 1'b1) next_state = pressed_2;
        else next_state = idle;
    end
    pressed_2: begin 
        button_out = 1'b0;
        if (l2p_in == 1'b1) next_state = pressed_2;
        else next_state = idle;
    end
    2'b11: begin    //default case
        button_out = 1'b0;
        next_state = idle;
    end
    endcase
end



endmodule