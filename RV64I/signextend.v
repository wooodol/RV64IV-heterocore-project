`timescale 1ns / 1ps

module signextend(
input [15:0] in,
output [64:0] out
    );
    
    assign out = {{48{in[15]}},in};
    
endmodule
