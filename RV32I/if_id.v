`timescale 1ns / 1ps

module if_id(
input clk, rstn, ifid_flush, ifid_write,
input [31:0] inst_if,
input [31:0] pcadd4_if,
output reg [31:0] inst_id,
output reg [31:0] pcadd4_id
    );
    
    always@(posedge clk or negedge rstn)begin
        if(!rstn) begin
            pcadd4_id <= 32'b0;
            inst_id <= 32'b0;
        end 
        else begin
            if(ifid_flush) begin
                pcadd4_id <= 32'd0;
                inst_id <= 32'b0;
            end
            else if(ifid_write)begin
                pcadd4_id <= pcadd4_if;
                inst_id <= inst_if;
            end
        end
    end
    
endmodule
