`timescale 1ns / 1ps

module ex_mem(
input clk, rstn, memread_ex, memwrite_ex, memtoreg_ex, regwrite_ex, exmem_flush,
input [4:0] dst_ex,
input [63:0] aluresult_ex, forwardBout_ex, pcadd4_ex,
output reg memread_mem, memtoreg_mem, regwrite_mem, mem_access_fault,
output reg [4:0] dst_mem,
output reg [63:0] aluresult_mem, pcadd4_mem, dmemrd_mem
    );
    
    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            memread_mem <= 1'b0;
            memtoreg_mem <= 1'b0;
            regwrite_mem <= 1'b0;
            aluresult_mem = 64'b0;
            pcadd4_mem <= 64'b0;
            dst_mem <= 5'b0;
        end
        else if(exmem_flush)begin
            memread_mem <= 1'b0;
            memtoreg_mem <= 1'b0;
            regwrite_mem <= 1'b0;
            aluresult_mem <= aluresult_ex;
            dst_mem <= dst_ex;
            pcadd4_mem <= pcadd4_ex;
        end
        else begin
            memread_mem <= memread_ex;
            memtoreg_mem <= memtoreg_ex;
            regwrite_mem <= regwrite_ex;
            aluresult_mem <= aluresult_ex;
            dst_mem <= dst_ex;
            pcadd4_mem <= pcadd4_ex;
        end
    end
    
    (* ram_style = "block" *)
    reg [63:0] data_mem_L1 [0:511]; //4KB
    
    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1) data_mem_L1[i] = 64'b0;
    end
    
    always@(posedge clk)begin
        if(!rstn)begin
            mem_access_fault <= 1'b0;
            dmemrd_mem <= 64'd0;
        end
        else begin
            if (aluresult_ex == 64'd1000) begin
                dmemrd_mem <= 64'd0;
                mem_access_fault <= 1'b1;
            end
            else if(memwrite_ex) begin
                data_mem_L1[aluresult_ex >> 3] <= forwardBout_ex;
                mem_access_fault <= 1'b0;
            end
            else begin 
                dmemrd_mem <= (memread_ex == 1)? data_mem_L1[aluresult_ex >> 3] : 64'b0;
                mem_access_fault <= 1'b0;
            end
        end
    end     
    
endmodule
