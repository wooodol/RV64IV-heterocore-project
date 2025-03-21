`timescale 1ns / 1ps

module pc(
input clk, rstn, pcwrite,
input [63:0] pcin_if, 
output reg [63:0] pcout_if
    );
    
    wire enable;
    
    assign enable = pcwrite & rstn;
    
    always@(posedge clk or negedge rstn)begin
        if(!rstn) pcout_if <= 64'b0;
        else begin 
            if(enable) pcout_if <= pcin_if;
        end
    end
    
endmodule
