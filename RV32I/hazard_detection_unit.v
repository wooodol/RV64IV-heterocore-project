`timescale 1ns / 1ps

module hazard_detection_unit(
input branch, memread_ex, regwrite_ex, regwrite_mem, 
input [4:0] rs_id, rt_id, rt_ex, dst_ex, dst_mem, rd_ex,
output reg ifid_write, hazard, pcwrite
    );
    
    always@(*)begin
        //load data hazard
        if(memread_ex && rd_ex && (dst_ex == rs_id || dst_ex == rt_id))begin
            ifid_write = 1'b0;
            hazard = 1'b1;
            pcwrite = 1'b0;
        end
        else begin 
            ifid_write = 1'b1;
            hazard = 1'b0;
            pcwrite = 1'b1;
        end
    end  
    
endmodule
