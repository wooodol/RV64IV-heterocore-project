`timescale 1ns / 1ps

module branch_detection(
input branch, equal, hazard, jmp, jalr_id, jalr_ex, branch_ex, msb, msb2, 
input [2:0] funct3, funct3_ex,
output reg isbranch, if_flush, branch_select, pcwrite
    );
    
    always@(*)begin
        if(hazard)begin
            isbranch = 1'b0;
            if_flush = 1'b0;
            branch_select = 1'b0;
            pcwrite = 1'b1;
        end
        else if(jmp | jalr_id | jalr_ex)begin //jal flush (back flush)-----------------------------------------------------
            isbranch = 1'b0;
            if_flush = 1'b1;
            branch_select = 1'b0;
            pcwrite = 1'b1;
        end 
        else if(branch) begin //branch id----------------------------------------------------------------------------------
            if(equal == 1'b1 && funct3 == 3'b000)begin //beq id flush and branch 
                isbranch = 1'b1;
                if_flush = 1'b1;
                branch_select = 1'b0;
                pcwrite = 1'b1;
            end
            else if(equal == 1'b0 && funct3 == 3'b001) begin //bne id flush and branch
                isbranch = 1'b1;
                if_flush = 1'b1;
                branch_select = 1'b0;
                pcwrite = 1'b1;
            end
            else if(funct3 == 3'b100 || funct3 == 3'b101 ||
                    funct3 == 3'b110 || funct3 == 3'b111) begin //blt,bge,bltu,bgeu id flush
                isbranch = 1'b0;
                if_flush = 1'b1;
                branch_select = 1'b0;
                pcwrite = 1'b0;
            end
            else begin 
                isbranch = 1'b0;
                if_flush = 1'b0;
                branch_select = 1'b0;
                pcwrite = 1'b1;
            end
        end
        else if(branch_ex) begin //branch ex-------------------------------------------------------------------------------
            if(msb == 1'b1 && funct3_ex == 3'b100)begin //blt ex flush and branch
                isbranch = 1'b1;
                if_flush = 1'b1;
                branch_select = 1'b1;
                pcwrite = 1'b1;
            end 
            else if(msb == 1'b0 && funct3_ex == 3'b101)begin //bge ex flush and branch
                isbranch = 1'b1;
                if_flush = 1'b1;
                branch_select = 1'b1;
                pcwrite = 1'b1;
            end 
            else if(msb2 == 1'b0 && funct3_ex == 3'b110)begin //bltu ex flush and branch
                isbranch = 1'b1;
                if_flush = 1'b1;
                branch_select = 1'b1;
                pcwrite = 1'b1;
            end 
            else if(msb2 == 1'b1 && funct3_ex == 3'b111)begin //bgeu ex flush and branch
                isbranch = 1'b1;
                if_flush = 1'b1;
                branch_select = 1'b1;
                pcwrite = 1'b1;
            end 
            else begin
                isbranch = 1'b0;
                if_flush = 1'b0;
                branch_select = 1'b0;
                pcwrite = 1'b1;
            end
        end
        else begin //NOP---------------------------------------------------------------------------------------------------
            isbranch = 1'b0;
            if_flush = 1'b0;
            branch_select = 1'b0;
            pcwrite = 1'b1;
        end
    end
    
endmodule


module branch_mux (
input regwrite_ex, regwrite_mem, branch,
input [4:0] rs_id, rt_id, dst_ex, dst_mem,
output reg [1:0] forwardA_id, forwardB_id);
    always@*begin
        if(branch)begin
            if(regwrite_ex && dst_ex && dst_ex == rt_id)begin //front flush
                forwardB_id = 2'b01;
            end
            else if(regwrite_mem && dst_mem && dst_mem == rt_id)begin 
                forwardB_id = 2'b10;
            end
            else begin 
                forwardB_id = 2'b00;
            end
            if(regwrite_ex && dst_ex && dst_ex == rs_id)begin //front flush
                forwardA_id = 2'b01;
            end
            else if(regwrite_mem && dst_mem && dst_mem == rs_id)begin 
                forwardA_id = 2'b10;
            end
            else begin 
                forwardA_id = 2'b00;
            end
        end
        else begin 
            forwardA_id = 2'b00;
            forwardB_id = 2'b00;
        end
    end  

endmodule
