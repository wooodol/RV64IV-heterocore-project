`timescale 1ns / 1ps

module L2_arbiter(
    input clk, rstn,
    input L1_HPi_req, L1_HPd_req, L1_HPd_we,
          L1_LPi_req, L1_LPd_req, L1_LPd_we,
          L2_ready,
    input [10:0] L1_HPd_addr, L1_HPi_addr, L1_LPd_addr, L1_LPi_addr,
    input [255:0] L1_HPd_wdata, L1_LPd_wdata, L2_rdata,
    output reg L1_HPi_ack, L1_LPi_ack, L1_HPd_ack, L1_LPd_ack,
           L1_HPi_ready_o, L1_LPi_ready_o, L1_HPd_ready_o, L1_LPd_ready_o,
           L2_we, L2_req,
    output reg [10:0] L2_addr,
    output reg [255:0] L1_HPd_rdata, L1_HPi_rdata, L1_LPd_rdata, L1_LPi_rdata, L2_wdata
    );
    
    reg [2:0] state;
    localparam IDLE = 3'b000;
    localparam Check_Req = 3'b001;
    localparam Wait_Resp_HPd = 3'b011;
    localparam Wait_Resp_HPi = 3'b100;
    localparam Wait_Resp_LPd = 3'b101;
    localparam Wait_Resp_LPi = 3'b110;
    
    always@(posedge clk)begin
        if(!rstn)begin
            state <= 3'b0;
            L1_HPi_ack <= 1'b0;
            L1_LPi_ack <= 1'b0; 
            L1_HPd_ack <= 1'b0;
            L1_LPd_ack <= 1'b0;
            L1_HPi_ready_o <= 1'b0;
            L1_LPi_ready_o <= 1'b0;
            L1_HPd_ready_o <= 1'b0; 
            L1_LPd_ready_o <= 1'b0;
            L2_we <= 1'b0;
            L2_req <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    state <= Check_Req;
                    L1_HPd_ready_o <= 1'b0;
                    L1_HPi_ready_o <= 1'b0;
                    L1_LPd_ready_o <= 1'b0;
                    L1_LPi_ready_o <= 1'b0;
                end
                Check_Req:begin//Check reqire-----------------------------------------------------------------
                    L1_HPd_ready_o <= 1'b0;
                    L1_HPi_ready_o <= 1'b0;
                    L1_LPd_ready_o <= 1'b0;
                    L1_LPi_ready_o <= 1'b0;
                    if(L1_HPd_req)begin
                        state <= Wait_Resp_HPd;
                        L2_req <= 1'b1;
                        L2_addr <= L1_HPd_addr;
                        L1_HPd_ack <= 1'b1;
                        if(L1_HPd_we)begin
                            L2_we <= 1'b1;
                            L2_wdata <= L1_HPd_wdata;
                        end
                        else begin
                            L2_we <= 1'b0;
                        end
                    end
                    else if(L1_HPi_req)begin
                        state <= Wait_Resp_HPi;
                        L2_req <= 1'b1;
                        L2_addr <= L1_HPi_addr;
                        L1_HPi_ack <= 1'b1;
                    end
                    else if(L1_LPd_req)begin
                        state <= Wait_Resp_LPd;
                        L2_req <= 1'b1;
                        L2_addr <= L1_LPd_addr;
                        L1_LPd_ack <= 1'b1;
                        if(L1_LPd_we)begin
                            L2_we <= 1'b1;
                            L2_wdata <= L1_LPd_wdata;
                        end
                        else begin
                            L2_we <= 1'b0;
                        end
                    end
                    else if(L1_LPi_req)begin
                        state <= Wait_Resp_LPi;
                        L2_req <= 1'b1;
                        L2_addr <= L1_LPi_addr;
                        L1_LPi_ack <= 1'b1;
                    end
                    else begin
                        state <= Check_Req;
                        L2_req <= 1'b0;
                        L2_addr <= 27'b0;
                        L2_we <= 1'b0;
                        L1_HPd_ack <= 1'b0;
                        L1_HPi_ack <= 1'b0;
                        L1_LPi_ack <= 1'b0;
                        L1_LPd_ack <= 1'b0;
                        L2_wdata <= 256'b0;
                    end
                end
                Wait_Resp_HPd:begin //Wait response-----------------------------------------------------------------
                    L1_HPd_ack <= 1'b0;
                    L1_HPi_ack <= 1'b0;
                    L1_LPi_ack <= 1'b0;
                    L1_LPd_ack <= 1'b0;
                    L2_req <= 1'b0;
                    L2_we <= 1'b0;
                    if(L2_ready)begin
                        state <= IDLE;
                        L1_HPd_rdata <= L2_rdata;
                        L1_HPd_ready_o <= 1'b1;
                        L2_req <= 1'b0;
                    end
                end
                Wait_Resp_HPi:begin
                    L1_HPd_ack <= 1'b0;
                    L1_HPi_ack <= 1'b0;
                    L1_LPi_ack <= 1'b0;
                    L1_LPd_ack <= 1'b0;
                    L2_req <= 1'b0;
                    if(L2_ready)begin
                        state <= IDLE;
                        L1_HPi_rdata <= L2_rdata;
                        L1_HPi_ready_o <= 1'b1;
                        L2_req <= 1'b0;
                    end
                end
                Wait_Resp_LPd:begin
                    L1_HPd_ack <= 1'b0;
                    L1_HPi_ack <= 1'b0;
                    L1_LPi_ack <= 1'b0;
                    L1_LPd_ack <= 1'b0;
                    L2_req <= 1'b0;
                    L2_we <= 1'b0;
                    if(L2_ready)begin
                        state <= IDLE;
                        L1_LPd_rdata <= L2_rdata;
                        L1_LPd_ready_o <= 1'b1;
                        L2_req <= 1'b0;
                    end
                end
                Wait_Resp_LPi:begin
                    L1_HPd_ack <= 1'b0;
                    L1_HPi_ack <= 1'b0;
                    L1_LPi_ack <= 1'b0;
                    L1_LPd_ack <= 1'b0;
                    L2_req <= 1'b0;
                    if(L2_ready)begin
                        state <= IDLE;
                        L1_LPi_rdata <= L2_rdata;
                        L1_LPi_ready_o <= 1'b1;
                        L2_req <= 1'b0;
                    end
                end
                default:begin //defualt----------------------------------------------------------------------------
                    L2_req <= 1'b0;
                    L2_addr <= 11'b0;
                    L2_we <= 1'b0;
                    L2_wdata <= 256'b0;
                    L1_HPd_ack <= 1'b0;
                    L1_HPi_ack <= 1'b0;
                    L1_LPi_ack <= 1'b0;
                    L1_LPd_ack <= 1'b0;
                    L1_HPd_ready_o <= 1'b0;
                    L1_HPi_ready_o <= 1'b0;
                    L1_LPd_ready_o <= 1'b0;
                    L1_LPi_ready_o <= 1'b0;
                end
            endcase
        end
    end
    
endmodule
