`timescale 1ns / 1ps

module data_mem(
input clk, memwrite_mem, memread_mem,
input [63:0] addr, wd,
output [63:0] rd
    );
    
    parameter mem_size = 512;
    
    reg [63:0] data_memory [0:mem_size-1]; //4KB
    
    integer i;
    initial begin
        for (i = 0; i < mem_size; i = i + 1)
            data_memory[i] = 64'b0;
    end
    
    always@(posedge clk)begin
        if(memwrite_mem) data_memory[addr >> 3] = wd;
    end
    
    assign rd = (memread_mem == 1)? data_memory[addr >> 3] : 64'b0;
            
    
endmodule
