`timescale 1ns / 1ps

module mux(
input [1:0] select,
input [63:0] a,b,c,d,
output reg [63:0] o
    );
    
    always@(*)begin
        case(select)
            2'b00: o = a;
            2'b01: o = b;
            2'b10: o = c;
            2'b11: o = d;
            default: o = 64'b0;
        endcase
    end
    
endmodule
