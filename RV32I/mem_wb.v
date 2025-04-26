`timescale 1ns / 1ps

module mem_wb(
input clk, rstn, memtoreg_mem, regwrite_mem, memwb_flush,
input [4:0] dst_mem,
input [31:0] dmemrd_mem, aluresult_mem,
output reg memtoreg_wb, regwrite_wb,
output reg [4:0] dst_wb,
output reg [31:0] dmemrd_wb, ALUresult_wb
    );
    
    
    always@(posedge clk)begin
        if(!rstn)begin 
            memtoreg_wb = 1'b0;
            regwrite_wb = 1'b0;
            dmemrd_wb = 32'b0;
            ALUresult_wb = 32'b0;
            dst_wb = 5'b0;
        end
        else if(memwb_flush)begin
            memtoreg_wb = 1'b0;
            regwrite_wb = 1'b0;
            dmemrd_wb    <= dmemrd_mem;
            dst_wb       <= dst_mem;
            ALUresult_wb <= aluresult_mem;
        end
        else begin
            memtoreg_wb  <= memtoreg_mem;
            regwrite_wb  <= regwrite_mem;
            dmemrd_wb    <= dmemrd_mem;
            dst_wb       <= dst_mem;
            ALUresult_wb <= aluresult_mem;
        end
    end
    
endmodule
