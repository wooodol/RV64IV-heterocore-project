`timescale 1ns / 1ps

module reg_file(
input clk, rstn, regwrite_wb,
input [4:0] rs_id, rt_id, dst_wb,
input [31:0] regwd_wb,
output [31:0] regrd1_id, regrd2_id
    );
    
    reg [31:0] register [0:31];
    
    always@(negedge clk or negedge rstn)begin
        if(!rstn)begin  //reset
            register[0] <= 32'b0;    //XZR
            register[1] <= 32'b0;    //Return Adress
            register[2] <= 32'd2048; //Stack Pointer (initial value: 256)
            register[3] <= 32'b0;    //Global Pointer
            register[4] <= 32'b0;    //Thread pointer
            register[5] <= 32'b0;    //t0
            register[6] <= 32'b0;    //t1
            register[7] <= 32'b0;    //t2
            register[8] <= 32'b0;    //s0, Frame Pointer
            register[9] <= 32'b0;    //s1
            register[10] <= 32'b0;   //a0, Retrun Values
            register[11] <= 32'b0;   //a1, Retrun Values
            register[12] <= 32'b0;   //a2
            register[13] <= 32'b0;   //a3
            register[14] <= 32'b0;   //a4
            register[15] <= 32'b0;   //a5
            register[16] <= 32'b0;   //a6
            register[17] <= 32'b0;   //a7
            register[18] <= 32'b0;   //s2
            register[19] <= 32'b0;   //s3
            register[20] <= 32'b0;   //s4
            register[21] <= 32'b0;   //s5
            register[22] <= 32'b0;   //s6
            register[23] <= 32'b0;   //s7
            register[24] <= 32'b0;   //s8
            register[25] <= 32'b0;   //s9
            register[26] <= 32'b0;   //s10
            register[27] <= 32'b0;   //s11
            register[28] <= 32'b0;   //t3
            register[29] <= 32'b0;   //t4
            register[30] <= 32'b0;   //t5
            register[31] <= 32'b0;   //t6
        end
        else begin
            if(regwrite_wb)begin
                if(dst_wb != 5'b0)begin // X0 == XZR
                    register[dst_wb] <= regwd_wb;
                end
            end
        end
    end
    
    assign regrd1_id = register[rs_id];
    assign regrd2_id = register[rt_id];
    
endmodule
