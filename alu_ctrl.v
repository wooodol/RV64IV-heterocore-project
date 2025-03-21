`timescale 1ns / 1ps

module alu_ctrl(
input [1:0] aluop_ex,
input [6:0] funct7,
input [2:0] funct3,
output reg [3:0] alu_control
    );
    
    always@(*)begin
        case(aluop_ex)
            2'b00: alu_control = 4'b0010; //add
            2'b01: alu_control = 4'b0110; //subtract
            2'b10: begin //R-type
                case(funct3)
                    3'b000:
                        case(funct7)
                            7'b0000000: alu_control = 4'b0010; //add
                            7'b0100000: alu_control = 4'b0110; //sub
                            default: alu_control = 4'b0000; //and
                        endcase 
                    3'b001: alu_control = 4'b0101; // sll(shift left)
                    3'b010: alu_control = 4'b1011; //slt(set less than)
                    3'b011: alu_control = 4'b1010; //sltu
                    3'b100: alu_control = 4'b1111; //xor
                    3'b110: alu_control = 4'b0001; //or
                    3'b111: alu_control = 4'b0000; //and
                    3'b101:
                        case(funct7)
                            7'b0000000: alu_control = 4'b0000; //srl(shift right logical)
                            7'b0100000: alu_control = 4'b0000; //sra(sguft right arithmetic)
                            default: alu_control = 4'b0000;
                        endcase
                    default: alu_control = 4'b0000;
                endcase
            end
            2'b11: begin //I-type
                case(funct3)
                    3'b000: alu_control = 4'b0010; //addi
                    3'b100: alu_control = 4'b1111; //xori
                    3'b111: alu_control = 4'b0000; //andi
                    3'b110: alu_control = 4'b0001; //ori
                    3'b010: alu_control = 4'b0111; //slti
                    3'b011: alu_control = 4'b1010; //sltiu
                    default: alu_control = 4'b0000; //andi
                endcase
            end
            default: alu_control = 4'b0000; //and
        endcase
    end
    
endmodule
