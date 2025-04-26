`timescale 1ns / 1ps

module tb_CacheHierarchy();

    reg clk, rstn;
    reg L1_HPi_req, L1_HPd_req, L1_HPd_we,
          L1_LPi_req, L1_LPd_req, L1_LPd_we;
    reg [10:0] L1_HPd_addr, L1_HPi_addr, L1_LPd_addr, L1_LPi_addr;
    reg [255:0] L1_HPd_wdata, L1_LPd_wdata;
    wire L1_HPi_ack, L1_LPi_ack, L1_HPd_ack, L1_LPd_ack,
           L1_HPi_ready_o, L1_LPi_ready_o, L1_HPd_ready_o, L1_LPd_ready_o;
    wire [255:0] L1_HPd_rdata, L1_HPi_rdata, L1_LPd_rdata, L1_LPi_rdata;
    
    
    cache_hierarchy u1(
    .clk(clk),  
    .rstn(rstn),
    .L1_HPi_req(L1_HPi_req),
    .L1_HPd_req(L1_HPd_req),
    .L1_HPd_we(L1_HPd_we),
    .L1_LPi_req(L1_LPi_req),
    .L1_LPd_req(L1_LPd_req),
    .L1_LPd_we(L1_LPd_we),
    .L1_HPd_addr(L1_HPd_addr),
    .L1_HPi_addr(L1_HPi_addr),
    .L1_LPd_addr(L1_LPd_addr),
    .L1_LPi_addr(L1_LPi_addr),
    .L1_HPd_wdata(L1_HPd_wdata),
    .L1_LPd_wdata(L1_LPd_wdata),
    .L1_HPi_ack(L1_HPi_ack),
    .L1_LPi_ack(L1_LPi_ack),
    .L1_HPd_ack(L1_HPd_ack),
    .L1_LPd_ack(L1_LPd_ack),
    .L1_HPi_ready_o(L1_HPi_ready_o),
    .L1_LPi_ready_o(L1_LPi_ready_o),
    .L1_HPd_ready_o(L1_HPd_ready_o),
    .L1_LPd_ready_o(L1_LPd_ready_o),
    .L1_HPd_rdata(L1_HPd_rdata),
    .L1_HPi_rdata(L1_HPi_rdata),
    .L1_LPd_rdata(L1_LPd_rdata),
    .L1_LPi_rdata(L1_LPi_rdata)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end
    
    always@(posedge clk)begin
        if(L1_HPd_ack)begin
            L1_HPd_req <= 0;
            L1_HPd_we <= 0;
        end
        
        if(L1_HPi_ack)begin
            L1_HPi_req <= 0;
        end
        
        if(L1_LPd_ack)begin
            L1_LPd_req <= 0;
            L1_LPd_we <= 0;
        end
        
        if(L1_LPi_ack)begin
            L1_LPi_req <= 0;
        end
    end
    
    initial begin
        rstn = 0;
        //HPi
        L1_HPi_req = 0;
        L1_HPi_addr = 11'b0;
        //HPd
        L1_HPd_req = 0;
        L1_HPd_addr = 11'b0;
        L1_HPd_wdata = 256'b0;
        L1_HPd_we = 0;
        //LPi
        L1_LPi_req = 0;
        L1_LPi_addr = 11'b0;
        //LPd
        L1_LPd_req = 0;
        L1_LPd_addr = 11'b0;
        L1_LPd_wdata = 256'b0;
        L1_LPd_we = 0;
        
        #25
        rstn = 1;
        //HPi
        L1_HPi_req = 1;
        L1_HPi_addr = 11'd0;
        //HPd
        L1_HPd_req = 1;
        L1_HPd_addr = 11'd400;
        L1_HPd_wdata = 256'h101;
        L1_HPd_we = 1;
        //LPi
        L1_LPi_req = 1;
        L1_LPi_addr = 11'd1;
        //LPd
        L1_LPd_req = 1;
        L1_LPd_addr = 11'd401;
        L1_LPd_wdata = 256'h202;
        L1_LPd_we = 1;
        
    end
    
    
endmodule
