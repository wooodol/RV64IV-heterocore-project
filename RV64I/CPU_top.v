`timescale 1ns / 1ps

module CPU_top(
input clk, rstn
    );

    //IF
    wire [31:0] inst_if;
    wire [63:0] pcadd4_if, pcin_if, pcout_if, branch_if, pc_exception, pc_ex_if;
    
    //ID
    wire pcwrite_en, ifid_write, branch, equal, hazard, jmp, isbranch, branch_flush,
         alusrc_id, memread_id, memwrite_id, memtoreg_id, regwrite_id, regdst_id, jalr_id, branch_select
         ,pcwrite_bu, illegal_opcode, inst_access_fault, exception_mod, exception_handled,
         ifid_flush, idex_flush, exmem_flush, memwb_flush, exception_ret;
    wire [1:0] aluop_id, forwardA_id, forwardB_id;
    wire [2:0] funct3_id,sign_select_id;
    wire [4:0] rs1_id, rs2_id, rd_id;
    wire [6:0] opcode, funct7_id;
    wire [31:0] inst_id;
    wire [63:0] pcadd4_id, signextend_id, branch_addr, jmp_addr,
                regrd1_id, regrd2_id, bmuxA, bmuxB, signextend_itype, signextend_stype, 
                signextend_utype, signextend_btype, signextend_jtype;
    
    //ex
    wire memread_ex, regwrite_ex, alusrc_ex, regdst_ex,
         memwrite_ex, memtoreg_ex, jalr_ex, jmp_ex, branch_ex, msb2;
    wire [1:0] aluop_ex, forwardA, forwardB;
    wire [2:0] funct3_ex, trap_type;
    wire [3:0] alucontrol_ex;
    wire [4:0] rs_ex, rt_ex, rd_ex, dst_ex;
    wire [6:0] funct7_ex;
    wire [63:0] signextend_ex, aluresult_ex, regrd1_ex, regrd2_ex, forwardBout_ex,
                aluin1_ex, aluin2_ex, aluresult_exx, pcadd4_ex, branch_addr_ex, mepc_addr, mtvec_addr;
    
    //mem
    wire regwrite_mem, memread_mem, memwrite_mem, memtoreg_mem, mem_access_fault;
    wire [4:0] dst_mem;
    wire [63:0] aluresult_mem, forwardBout_mem, dmemrd_mem, pcadd4_mem;
    
    //wb
    wire memtoreg_wb, regwrite_wb;
    wire [4:0] dst_wb;
    wire [63:0] dmemrd_wb, regwd_wb, ALUresult_wb;
    
    //IF----------------------------------------------------------------------
    
    //pc mux
    (* DONT_TOUCH = "true" *) mux pc_mux(
    .a(pcadd4_if),//in
    .b(jmp_addr),
    .c(branch_if),
    .select({isbranch,jmp}),
    .o(pcin_if)//out
    );
    
    
    //pc
    (* DONT_TOUCH = "true" *) pc pc(
    .clk(clk),//in
    .rstn(rstn),
    .pcin_if(pcin_if),
    .pcwrite(pcwrite_en),
    .pcout_if(pcout_if)//out
    );
    
    
    //pc+4
    assign pc_exception = exception_handled? mepc_addr : mtvec_addr;
    assign pcwrite_en = pcwrite & pcwrite_bu;
    assign pcadd4_if =  (exception_mod|exception_handled)? pc_exception: jalr_ex? aluresult_ex : (pcout_if + 4);
    assign branch_if = branch_select? branch_addr_ex : branch_addr;
    assign pc_ex_if = pcout_if + 4;
    
    
    //instruction cache memory
    (* DONT_TOUCH = "true" *) instruction_mem instruction_cache_mem(
    .clk(clk),//in
    .rstn(rstn),
    .pcwrite(pcwrite_en),
    .pcin_if(pcin_if),
    .inst_if(inst_if),//out
    .inst_access_fault(inst_access_fault)
    );
    
    
    //if_id
    (* DONT_TOUCH = "true" *) if_id if_id(
    .clk(clk),//in
    .rstn(rstn),
    .ifid_flush(ifid_flush),
    .ifid_write(ifid_write),
    .inst_if(inst_if),
    .pcadd4_if(pcadd4_if),
    .pcadd4_id(pcadd4_id),//out
    .inst_id(inst_id)
    );
    
    
    //ID----------------------------------------------------------------------
    assign opcode = inst_id[6:0];
    assign rd_id = inst_id[11:7];
    assign funct3_id = inst_id[14:12];
    assign rs1_id = inst_id[19:15];
    assign rs2_id = inst_id[24:20];
    assign funct7_id = inst_id[31:25];
    
    
    //register file
    (* DONT_TOUCH = "true" *) reg_file register_file(
    .clk(clk),//in
    .rstn(rstn),
    .rs_id(rs1_id),
    .rt_id(rs2_id),
    .dst_wb(dst_wb),
    .regwd_wb(regwd_wb),
    .regwrite_wb(regwrite_wb),
    .regrd1_id(regrd1_id),//out
    .regrd2_id(regrd2_id)
    );
    
    
    //signexted
    assign signextend_itype = {{52{inst_id[31]}},inst_id[31:20]};
    assign signextend_stype = {{52{inst_id[31]}},{inst_id[31:25],inst_id[11:7]}};
    assign signextend_utype = {{44{inst_id[31]}},inst_id[31:12]};
    assign signextend_btype = {{51{inst_id[31]}},{inst_id[31],inst_id[7],inst_id[30:25],inst_id[11:8]}, 1'b0};
    assign signextend_jtype = {{43{inst_id[31]}}, inst_id[31], inst_id[19:12], inst_id[20], inst_id[30:21], 1'b0};
    
    
    (* DONT_TOUCH = "true" *) sign_mux sign_mux(
    .a(signextend_itype),//in
    .b(signextend_stype),
    .c(signextend_utype),
    .d(signextend_btype),
    .select(sign_select_id),
    .o(signextend_id)//out
    );
    
    
    //branch_addr, jump_addr, equal
    assign branch_addr = pcadd4_id - 64'd4 + (signextend_id << 1);
    assign jmp_addr = pcadd4_id - 64'd4 + (signextend_jtype << 1);
    assign equal = (bmuxA == bmuxB);
    
    
    //hazard detection unit
   (* DONT_TOUCH = "true" *) hazard_detection_unit hazard_detection_unit(
    .branch(branch),//in
    .memread_ex(memread_ex),
    .regwrite_mem(regwrite_mem),
    .regwrite_ex(regwrite_ex),
    .memread_mem(memread_mem),
    .rs_id(rs1_id),
    .rt_id(rs2_id),
    .rt_ex(rt_ex),
    .rd_ex(rd_ex),
    .dst_ex(dst_ex),
    .dst_mem(dst_mem),
    .ifid_write(ifid_write),//out
    .hazard(hazard),
    .pcwrite(pcwrite)
    );
    
    
    //control unit
    (* DONT_TOUCH = "true" *) control_unit control_unit(
    .opcode(opcode),//in
    .sign_select(sign_select_id),//out
    .jmp(jmp),
    .branch(branch),
    .memread(memread_id),
    .memtoreg(memtoreg_id),
    .memwrite(memwrite_id),
    .alusrc(alusrc_id),
    .regwrite(regwrite_id),
    .aluop(aluop_id),
    .regdst_id(regdst_id),
    .jalr_id(jalr_id),
    .illegal_opcode(illegal_opcode),
    .exception_ret(exception_ret)
    );
    
    
    //branch detection unit
    (* DONT_TOUCH = "true" *) branch_detection branch_detection(
    .branch(branch),//in
    .branch_ex(branch_ex),
    .equal(equal),
    .hazard(hazard),
    .msb2(msb2),
    .jmp(jmp),
    .msb(aluresult_ex[63]),
    .jalr_id(jalr_id),
    .jalr_ex(jalr_ex),
    .funct3(funct3_id),
    .funct3_ex(funct3_ex),
    .isbranch(isbranch),//out
    .if_flush(branch_flush),
    .branch_select(branch_select),
    .pcwrite(pcwrite_bu)
    );
    
    branch_mux branch_mux(
    .regwrite_ex(regwrite_ex),
    .regwrite_mem(regwrite_mem),
    .rs_id(rs1_id),
    .rt_id(rs2_id),
    .dst_ex(dst_ex),
    .dst_mem(dst_mem),
    .forwardA_id(forwardA_id),
    .forwardB_id(forwardB_id),
    .branch(branch)
    );
    
    //branch forwarding mux
    (* DONT_TOUCH = "true" *) mux branch_muxA(
    .a(regrd1_id),//in
    .b(aluresult_exx),
    .c(aluresult_mem),
    .select(forwardA_id),
    .o(bmuxA)//out
    );
    
    (* DONT_TOUCH = "true" *) mux branch_muxB(
    .a(regrd2_id),//in
    .b(aluresult_exx),
    .c(aluresult_mem),
    .select(forwardB_id),
    .o(bmuxB)//out
    );
    
    //flush control
    (* DONT_TOUCH = "true" *) flush_control flush_control(
    .trap_type(trap_type), //in
    .branch_flush(branch_flush),
    .hazard(hazard),
    .exception_ret(exception_ret),
    .ifid_flush(ifid_flush), //out
    .idex_flush(idex_flush),
    .exmem_flush(exmem_flush),
    .memwb_flush(memwb_flush),
    .exception_handled(exception_handled)
    );
    
    //exception pc control
    (* DONT_TOUCH = "true" *) exception_pc_ctrl exception_pc_ctrl(
    .trap_type(trap_type),
    .exception_mod(exception_mod)
    );
    
    //id_ex
    (* DONT_TOUCH = "true" *) id_ex id_ex(
    .clk(clk),//in
    .idex_flush(idex_flush),
    .funct3_id(funct3_id),
    .funct7_id(funct7_id),
    .rstn(rstn),
    .alusrc_id(alusrc_id),
    .memread_id(memread_id),
    .memwrite_id(memwrite_id),
    .memtoreg_id(memtoreg_id),
    .regwrite_id(regwrite_id),
    .aluop_id(aluop_id),
    .rs_id(rs1_id),
    .rt_id(rs2_id),
    .branch(branch),
    .regdst_id(regdst_id),
    .rd_id(rd_id),
    .bmuxA(bmuxA),
    .bmuxB(bmuxB),
    .signextend_id(signextend_id), 
    .jalr_id(jalr_id),
    .pcadd4_id(pcadd4_id),
    .jmp(jmp),
    .branch_addr(branch_addr),
    
    .alusrc_ex(alusrc_ex),//out
    .memread_ex(memread_ex),
    .memwrite_ex(memwrite_ex),
    .memtoreg_ex(memtoreg_ex),
    .regwrite_ex(regwrite_ex),
    .aluop_ex(aluop_ex),
    .funct3_ex(funct3_ex),
    .funct7_ex(funct7_ex),
    .rs_ex(rs_ex),
    .rt_ex(rt_ex),
    .rd_ex(rd_ex),
    .branch_ex(branch_ex),
    .regrd1_ex(regrd1_ex),
    .regrd2_ex(regrd2_ex),
    .signextend_ex(signextend_ex),
    .regdst_ex(regdst_ex),
    .jalr_ex(jalr_ex),
    .pcadd4_ex(pcadd4_ex),
    .jmp_ex(jmp_ex),
    .branch_addr_ex(branch_addr_ex)
    );
    
    
    //EX--------------------------------------------------------------------
    //alu control unit
    (* DONT_TOUCH = "true" *) alu_ctrl clu_ctrl(
    .aluop_ex(aluop_ex),//in
    .funct7(funct7_ex),
    .funct3(funct3_ex),
    .alu_control(alucontrol_ex)//out
    );
    
    
    //ALU
    (* DONT_TOUCH = "true" *) ALU ALU(
    .aluin1_ex(aluin1_ex),//in
    .aluin2_ex(aluin2_ex),
    .alu_control(alucontrol_ex),
    .result(aluresult_ex),//out
    .sub_carryout(msb2)
    );
    
    assign aluresult_exx = (jalr_ex | jmp_ex)? pcadd4_ex : aluresult_ex;
    
    
    //alu mux
    (* DONT_TOUCH = "true" *) mux forwardAmux(
    .a(regrd1_ex),//in
    .b(regwd_wb),
    .c(aluresult_mem),
    .select(forwardA),
    .o(aluin1_ex)//out
    );
    
    (* DONT_TOUCH = "true" *) mux forwardBmux(
    .a(regrd2_ex),//in
    .b(regwd_wb),
    .c(aluresult_mem),
    .select(forwardB),
    .o(forwardBout_ex)//out
    );
    
    assign aluin2_ex = alusrc_ex? signextend_ex : forwardBout_ex;
    
    
    //forwarding unit
    (* DONT_TOUCH = "true" *) forwarding_unit forwarding_unit(
    .regwrite_mem(regwrite_mem),//in
    .regwrite_wb(regwrite_wb),
    .rs_id(rs1_id),
    .rt_id(rs2_id),
    .rs_ex(rs_ex),
    .rt_ex(rt_ex),
    .dst_mem(dst_mem),
    .dst_wb(dst_wb),
    .forwardA(forwardA),//out
    .forwardB(forwardB)
    );
    
    
    //dst
    assign dst_ex = regdst_ex? rt_ex : rd_ex;
    
    
    //trap detector
    (* DONT_TOUCH = "true" *) trap_detection trap_detection(
    .rstn(rstn), //in
    .clk(clk),
    .illegal_opcode(illegal_opcode),
    .inst_access_fault(inst_access_fault),
    .mem_access_fault(mem_access_fault),
    .pc_ex_if(pc_ex_if),
    .pcadd4_id(pcadd4_id),
    .pcadd4_ex(pcadd4_ex),
    .pcadd4_mem(pcadd4_mem),
    .trap_type(trap_type), //out
    .mepc(mepc_addr),
    .mtvec_addr(mtvec_addr)
    );
    
    //ex_mem & data_mem
    (* DONT_TOUCH = "true" *) ex_mem ex_mem(
    .clk(clk),//in
    .rstn(rstn),
    .memread_ex(memread_ex),
    .memwrite_ex(memwrite_ex),
    .memtoreg_ex(memtoreg_ex),
    .regwrite_ex(regwrite_ex),
    .dst_ex(dst_ex),
    .aluresult_ex(aluresult_exx),
    .forwardBout_ex(forwardBout_ex),
    .exmem_flush(exmem_flush),
    .pcadd4_ex(pcadd4_ex),
    .memread_mem(memread_mem), //out
    .memtoreg_mem(memtoreg_mem),
    .regwrite_mem(regwrite_mem),
    .dmemrd_mem(dmemrd_mem),
    .mem_access_fault(mem_access_fault),
    .dst_mem(dst_mem),
    .aluresult_mem(aluresult_mem),
    .pcadd4_mem(pcadd4_mem)
    );
    
    
    //MEM-------------------------------------------------------------------
    
    //mem_wb
    (* DONT_TOUCH = "true" *) mem_wb mem_wb(
    .clk(clk),//in
    .rstn(rstn),
    .memtoreg_mem(memtoreg_mem),
    .regwrite_mem(regwrite_mem),
    .dst_mem(dst_mem),
    .dmemrd_mem(dmemrd_mem),
    .aluresult_mem(aluresult_mem),
    .memwb_flush(memwb_flush),
    .memtoreg_wb(memtoreg_wb),//out
    .regwrite_wb(regwrite_wb),
    .dst_wb(dst_wb),
    .dmemrd_wb(dmemrd_wb),
    .ALUresult_wb(ALUresult_wb)
    );
    
    //WB--------------------------------------------------------------------
    assign regwd_wb = memtoreg_wb? dmemrd_wb : ALUresult_wb;
    
endmodule
