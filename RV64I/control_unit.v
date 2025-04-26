`timescale 1ns / 1ps

module control_unit(
input [6:0] opcode,
output reg jmp, branch, memread, memtoreg, memwrite, alusrc, regwrite, regdst_id, jalr_id,
           illegal_opcode, exception_ret,
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
            end
            
            7'b1110011:begin //mret
                sign_select <= 3'b000;
                jmp <= 1'b0;
                branch <= 1'b0;
                memread <= 1'b0;
                regdst_id <= 1'b0;
                memtoreg <= 1'b0;
                memwrite <= 1'b0;
                alusrc <= 1'b0;
                regwrite <= 1'b0;
                aluop <= 2'b00;
                jalr_id <= 1'b0;
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b1;
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
            end
            
            //U-type------------------------------------------------

            
            //NOP---------------------------------------------------
            7'b0000000: begin 
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
                illegal_opcode <= 1'b0;
                exception_ret <= 1'b0;
            end
            
            //Exception----------------------------------------------
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
                illegal_opcode <= 1'b1;
                exception_ret <= 1'b0;
            end
            
        endcase
    end
    
endmodule



module flush_control (
    input branch_flush, hazard, exception_ret,
    input [2:0] trap_type,
    output reg ifid_flush, idex_flush, exmem_flush, memwb_flush, exception_handled
    );
    
    always @(*) begin
        ifid_flush = 1'b0;
        idex_flush = 1'b0;
        exmem_flush = 1'b0;
        memwb_flush = 1'b0;
        exception_handled = 1'b0;
    
    
        if(exception_ret) begin
            ifid_flush = 1'b1;
            exception_handled = 1'b1;
        end
        else if(branch_flush) begin
            ifid_flush = 1'b1;
        end
        else if(hazard) begin
            idex_flush = 1'b1;
        end
    
        case (trap_type)
            3'b011: begin
                ifid_flush = 1'b1;
            end
            3'b010: begin
                ifid_flush = 1'b1;
                idex_flush = 1'b1;
            end
            3'b001: begin
                ifid_flush = 1'b1;
                idex_flush = 1'b1;
                exmem_flush = 1'b1;
                memwb_flush = 1'b1;
            end
        default: ;
    endcase
end
    
endmodule



module exception_pc_ctrl(
    input [2:0] trap_type,
    output reg exception_mod
    );
    
    always@(*)begin
        case(trap_type)
            3'b001: exception_mod = 1;
            3'b011: exception_mod = 1;
            3'b010: exception_mod = 1;
            default: exception_mod = 0;
        endcase
    end
    
endmodule
