`timescale 1ns / 1ps

module instruction_mem(
input [63:0] pcout_if,
output reg [31:0] inst_if
    );
    
    reg [7:0] memory_8 [0:400];
    reg [31:0] memory [0:127]; //512B
    
    always@(pcout_if)
        inst_if <= memory[pcout_if >> 2];
    
endmodule
