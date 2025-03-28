
`timescale 1ns / 1ps

module trap_detection(
    input rstn, illegal_opcode, inst_access_fault, mem_access_fault,clk,
    input [63:0] pc_ex_if, pcadd4_id, pcadd4_ex, pcadd4_mem,
    output [2:0] trap_type,
    output reg [63:0] mepc, mtvec_addr
    );
    
    reg mem_access_fault_d, illegal_opcode_d, inst_access_fault_d;
    reg [2:0] mcause;
    reg [63:0] mtval = 64'd0;
    reg [63:0] mtvec [0:4];
    
    assign trap_type = mcause;
    
    always @(posedge clk) begin
        mem_access_fault_d     <= mem_access_fault;
        illegal_opcode_d       <= illegal_opcode;
        inst_access_fault_d    <= inst_access_fault;
    end
    
    wire mem_access_fault_edge  = mem_access_fault & ~mem_access_fault_d;
    wire illegal_opcode_edge    = illegal_opcode & ~illegal_opcode_d;
    wire inst_access_fault_edge = inst_access_fault & ~inst_access_fault_d;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            mtvec[0] <= 64'd472;   //load/store access fault
            mtvec[1] <= 64'd480;   //illegal instruction
            mtvec[2] <= 64'd488;   //instruction access fault
            mtvec[3] <= 64'd496;
            mtvec[4] <= 64'd504;
            mcause <= 3'b0;
            mepc <= 0;
        end
        else begin
            if (mem_access_fault_edge) mepc <= pcadd4_mem;
            else if (illegal_opcode_edge) mepc <= pcadd4_id;
            else if (inst_access_fault_edge) mepc <= pc_ex_if;
        end
    end
    
    
    always@(*) begin 
        if(mem_access_fault) begin       //load/store access fault
            mcause = 3'b001; 
            mtvec_addr = mtvec[0];
        end
        else if(illegal_opcode) begin    //illegal instruction
            mcause = 3'b010;
            mtvec_addr = mtvec[1];
        end
        else if(inst_access_fault) begin   //instruction access fault
            mcause = 3'b011;
            mtvec_addr = mtvec[2];
        end
        /*
        else if(inst_align_fault) mcause = 3'b100;
        else if(mem_align_fault) mcause = 3'b101;
        */
        else mcause = 3'b000;       //no trap
    end
    
    
endmodule
