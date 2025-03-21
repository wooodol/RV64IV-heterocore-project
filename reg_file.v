`timescale 1ns / 1ps

module reg_file(
input clk, rstn, regwrite_wb,
input [4:0] rs_id, rt_id, dst_wb,
input [63:0] regwd_wb,
output [63:0] regrd1_id, regrd2_id
    );
    
    reg [63:0] register [0:31];
    
    always@(negedge clk or negedge rstn)begin
        if(!rstn)begin  //reset
            register[0] <= 64'b0;    //XZR
            register[1] <= 64'b0;    //Return Adress
            register[2] <= 64'd2048; //Stack Pointer (initial value: 256)
            register[3] <= 64'b0;    //Global Pointer
            register[4] <= 64'b0;    //Thread pointer
            register[5] <= 64'b0;    //t0
            register[6] <= 64'b0;    //t1
            register[7] <= 64'b0;    //t2
            register[8] <= 64'b0;    //s0, Frame Pointer
            register[9] <= 64'b0;    //s1
            register[10] <= 64'b0;   //a0, Retrun Values
            register[11] <= 64'b0;   //a1, Retrun Values
            register[12] <= 64'b0;   //a2
            register[13] <= 64'b0;   //a3
            register[14] <= 64'b0;   //a4
            register[15] <= 64'b0;   //a5
            register[16] <= 64'b0;   //a6
            register[17] <= 64'b0;   //a7
            register[18] <= 64'b0;   //s2
            register[19] <= 64'b0;   //s3
            register[20] <= 64'b0;   //s4
            register[21] <= 64'b0;   //s5
            register[22] <= 64'b0;   //s6
            register[23] <= 64'b0;   //s7
            register[24] <= 64'b0;   //s8
            register[25] <= 64'b0;   //s9
            register[26] <= 64'b0;   //s10
            register[27] <= 64'b0;   //s11
            register[28] <= 64'b0;   //t3
            register[29] <= 64'b0;   //t4
            register[30] <= 64'b0;   //t5
            register[31] <= 64'b0;   //t6
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
