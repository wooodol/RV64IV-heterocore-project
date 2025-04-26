`timescale 1ns / 1ps

module cache_hierarchy(
    input clk, rstn,
    input L1_HPi_req, L1_HPd_req, L1_HPd_we,
          L1_LPi_req, L1_LPd_req, L1_LPd_we,
    input [10:0] L1_HPd_addr, L1_HPi_addr, L1_LPd_addr, L1_LPi_addr,
    input [255:0] L1_HPd_wdata, L1_LPd_wdata, 
    output wire L1_HPi_ack, L1_LPi_ack, L1_HPd_ack, L1_LPd_ack,
           L1_HPi_ready_o, L1_LPi_ready_o, L1_HPd_ready_o, L1_LPd_ready_o,
    output wire [255:0] L1_HPd_rdata, L1_HPi_rdata, L1_LPd_rdata, L1_LPi_rdata
    );
    
    
    wire L2_we, L2_req, ready2arb;
    wire [10:0] L2_addr;
    wire [255:0] L2_wdata, rdata2arb;
    
    L2_arbiter L2_arbiter(
    .clk(clk),   //input
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
    .L2_rdata(rdata2arb), //input(output of L2)
    .L2_ready(ready2arb),
    .L1_HPi_ack(L1_HPi_ack), //output
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
    .L1_LPi_rdata(L1_LPi_rdata),
    .L2_we(L2_we), //output(input of L2)
    .L2_req(L2_req),
    .L2_addr(L2_addr),
    .L2_wdata(L2_wdata)
    );
   
    
    L2 L2(
    .clk(clk), //input
    .rstn(rstn),
    .arb_w_rb(L2_we),     
    .addr_in(L2_addr),          
    .arb_req(L2_req),      
    .wdata2cache(L2_wdata),      
    .rdata2arb(rdata2arb),      //output
    .ready2arb(ready2arb) 
    );
    
endmodule
