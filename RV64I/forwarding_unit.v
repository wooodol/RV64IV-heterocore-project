`timescale 1ns / 1ps

module forwarding_unit(
input regwrite_mem, regwrite_wb,
input [4:0] rs_id, rt_id, rs_ex, rt_ex, dst_mem, dst_wb,
output reg [1:0] forwardA, forwardB
    );
    
    always@(*)begin
        if(regwrite_mem && dst_mem && dst_mem == rs_ex)
            forwardA = 2'b10;
        else if(regwrite_wb && dst_wb && dst_wb == rs_ex)
            forwardA = 2'b01;
        else 
            forwardA = 2'b00;
        
        if(regwrite_mem && dst_mem && dst_mem == rt_ex)
            forwardB = 2'b10;
        else if(regwrite_wb && dst_wb && dst_wb == rt_ex)
            forwardB = 2'b01;
        else 
            forwardB = 2'b00;
    end
    
endmodule
