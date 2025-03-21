`timescale 1ns / 1ps

module ex_mem(
input clk, rstn, memread_ex, memwrite_ex, memtoreg_ex, regwrite_ex,
input [4:0] dst_ex,
input [63:0] aluresult_ex, forwardBout_ex,
output reg memread_mem, memwrite_mem, memtoreg_mem, regwrite_mem,
output reg [4:0] dst_mem,
output reg [63:0] aluresult_mem, forwardBout_mem
    );
    
    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            memread_mem <= 1'b0;
            memwrite_mem <= 1'b0;
            memtoreg_mem <= 1'b0;
            regwrite_mem <= 1'b0;
            aluresult_mem = 64'b0;
            forwardBout_mem <= 64'b0;
            dst_mem <= 5'b0;
        end
        else begin
            memread_mem <= memread_ex;
            memwrite_mem <= memwrite_ex;
            memtoreg_mem <= memtoreg_ex;
            regwrite_mem <= regwrite_ex;
            aluresult_mem <= aluresult_ex;
            forwardBout_mem <= forwardBout_ex;
            dst_mem <= dst_ex;
        end
    end
        
    
endmodule
