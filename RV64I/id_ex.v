`timescale 1ns / 1ps

module id_ex(
input clk, idex_flush, rstn, alusrc_id, memread_id, memwrite_id,
      memtoreg_id, regwrite_id, regdst_id,jalr_id, jmp, branch,
input [1:0] aluop_id,
input [2:0] funct3_id,
input [4:0] rs_id, rt_id, rd_id,
input [6:0] funct7_id,
input [63:0] bmuxA, bmuxB, signextend_id, pcadd4_id, branch_addr,

output reg alusrc_ex, memread_ex, memwrite_ex, memtoreg_ex,
           regwrite_ex, regdst_ex, jalr_ex, jmp_ex, branch_ex,
output reg [1:0] aluop_ex,
output reg [2:0] funct3_ex,
output reg [4:0] rs_ex, rt_ex, rd_ex,
output reg [6:0] funct7_ex,
output reg [63:0] regrd1_ex, regrd2_ex, signextend_ex, pcadd4_ex, branch_addr_ex
    );
    
    always@(posedge clk or negedge rstn)begin
        if(!rstn) begin
            funct3_ex <= 3'b0;
            funct7_ex <= 7'b0;
            regdst_ex   <= 1'b0;
            alusrc_ex   <= 1'b0;
            memread_ex  <= 1'b0;
            memwrite_ex <= 1'b0;
            memtoreg_ex <= 1'b0;
            regwrite_ex <= 1'b0;
            jalr_ex     <= 1'b0;
            jmp_ex      <= 1'b0;
            branch_ex      <= 1'b0;
            aluop_ex <= 2'b00;
            rs_ex <= 5'b0;
            rt_ex <= 5'b0;
            rd_ex <= 5'b0;
            regrd1_ex <= 64'b0;
            regrd2_ex <= 64'b0;
            signextend_ex <= 64'b0;
            pcadd4_ex <= 64'b0;
            branch_addr_ex <= 64'b0;
        end
        else begin
            if(idex_flush)begin
                funct3_ex   <= 3'b0;
                funct7_ex   <= 7'b0;
                regdst_ex   <= 1'b0;
                alusrc_ex   <= 1'b0;
                memread_ex  <= 1'b0;
                memwrite_ex <= 1'b0;
                memtoreg_ex <= 1'b0;
                regwrite_ex <= 1'b0;
                jalr_ex     <= 1'b0;
                jmp_ex      <= 1'b0;
                branch_ex      <= 1'b0;
                aluop_ex <= 2'b00;
                rs_ex <= rs_id;
                rt_ex <= rt_id;
                rd_ex <= rd_id;
                regrd1_ex <= bmuxA;
                regrd2_ex <= bmuxB;
                signextend_ex <= signextend_id;
                pcadd4_ex <= pcadd4_id;
                branch_addr_ex <= branch_addr;
            end
            else begin
                funct3_ex <= funct3_id;
                funct7_ex <= funct7_id;
                regdst_ex   <= regdst_id;
                alusrc_ex   <= alusrc_id;
                memread_ex  <= memread_id;
                memwrite_ex <= memwrite_id;
                memtoreg_ex <= memtoreg_id;
                regwrite_ex <= regwrite_id;
                jalr_ex     <= jalr_id;
                jmp_ex      <= jmp;
                branch_ex      <= branch;
                aluop_ex <= aluop_id;
                rs_ex <= rs_id;
                rt_ex <= rt_id;
                rd_ex <= rd_id;
                regrd1_ex <= bmuxA;
                regrd2_ex <= bmuxB;
                signextend_ex <= signextend_id;
                pcadd4_ex <= pcadd4_id;
                branch_addr_ex <= branch_addr;
            end
        end
    end
    
endmodule
