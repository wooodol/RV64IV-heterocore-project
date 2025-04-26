`timescale 1ns / 1ps

module mux(
input [1:0] select,
input [31:0] a,b,c,d,
output reg [31:0] o
    );
    
    always@(*)begin
        case(select)
            2'b00: o = a;
            2'b01: o = b;
            2'b10: o = c;
            2'b11: o = d;
            default: o = 31'b0;
        endcase
    end
    
endmodule
