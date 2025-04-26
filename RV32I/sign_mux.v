`timescale 1ns / 1ps

module sign_mux(
input [31:0] a,b,c,d,e,
input [2:0] select,
output reg [31:0] o
    );
    
    always@*
        case(select)
            3'b000: o = a;
            3'b001: o = b;
            3'b010: o = c; 
            3'b011: o = d;
            3'b100: o = e;
            default: o = 3'b000;
        endcase
    
endmodule
