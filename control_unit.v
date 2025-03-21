`timescale 1ns / 1ps

module control_unit(
input [6:0] opcode,
output reg jmp, branch, memread, memtoreg, memwrite, alusrc, regwrite, regdst_id, jalr_id,
output reg [1:0] aluop,
output reg [2:0] sign_select
    );
    
    always@(opcode)begin
        case(opcode)
            //R-type------------------------------------------------
            7'b0110011:begin //add, and, or, slt....
                sign_select <= 3'b000;
                regdst_id <= 1'b0;
                jmp <= 1'b0;
                regdst_id <= 1'b0;
                branch <= 1'b0;
                memread <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b0;
                alusrc <= 1'b0;
                regwrite <= 1'b1;
                aluop <= 2'b10;
                jalr_id <= 1'b0;
            end
            
            //I-type------------------------------------------------
            7'b0010011:begin //addi, andi, subi....
                sign_select <= 3'b000;
                jmp <= 1'b0;
                regdst_id <= 1'b0;
                branch <= 1'b0;
                memread <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b0;
                alusrc <= 1'b1;
                regwrite <= 1'b1;
                aluop <= 2'b11;
                jalr_id <= 1'b0;
            end
            
            7'b0000011:begin //lw
                sign_select <= 3'b000;
                jmp <= 1'b0;
                branch <= 1'b0;
                regdst_id <= 1'b0;
                memread <= 1'b1;
                memtoreg <= 1'b1;
                memwrite <= 1'b0;
                alusrc <= 1'b1;
                regwrite <= 1'b1;
                aluop <= 2'b00;
                jalr_id <= 1'b0;
            end
            
            7'b1100111:begin //jalr
                sign_select <= 3'b000;
                jmp <= 1'b0;
                branch <= 1'b0;
                memread <= 1'b0;
                regdst_id <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b0;
                alusrc <= 1'b1;
                regwrite <= 1'b1;
                aluop <= 2'b00;
                jalr_id <= 1'b1;
            end
            
            //B-type------------------------------------------------
            7'b1100011:begin //b
                sign_select <= 3'b011;
                jmp <= 1'b0;
                branch <= 1'b1;
                regdst_id <= 1'b0;
                memread <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b0;
                alusrc <= 1'b0;
                regwrite <= 1'b0;
                aluop <= 2'b01;
                jalr_id <= 1'b0;
            end
            
            //S-type------------------------------------------------
            7'b0100011:begin //sw
                sign_select <= 3'b001;
                jmp <= 1'b0;
                branch <= 1'b0;
                regdst_id <= 1'b1;
                memread <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b1;
                alusrc <= 1'b1;
                regwrite <= 1'b0;
                aluop <= 2'b00;
                jalr_id <= 1'b0;
            end
            //J-type----------------------------------------------
            7'b1101111:begin //jal
                sign_select <= 3'b000;
                jmp <= 1'b1;
                branch <= 1'b0;
                memread <= 1'b0;
                regdst_id <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b0;
                alusrc <= 1'b0;
                regwrite <= 1'b1;
                aluop <= 2'b00;
                jalr_id <= 1'b0;
            end
            
            //U-type------------------------------------------------
            
            //NOP
            default: begin 
                sign_select <= 3'b000;
                jmp <= 1'b0;
                branch <= 1'b0;
                regdst_id <= 1'b0;
                memread <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b0;
                alusrc <= 1'b0;
                regwrite <= 1'b0;
                aluop <= 2'b00;
                jalr_id <= 1'b0;
            end
        endcase
    end
    
endmodule
