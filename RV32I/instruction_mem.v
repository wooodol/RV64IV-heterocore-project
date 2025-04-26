`timescale 1ns / 1ps

module instruction_mem(
input clk, rstn, pcwrite, write_en,
input [31:0] pcin_if,
input [31:0] inst_rd,
output reg inst_access_fault,
output reg [31:0] inst_if
    );
    
    (* ram_style = "block" *)
    reg [31:0] inst_mem_L1 [0:127]; 
    
    initial begin
        $readmemh("C:/inst_ex/inst_3.hex", inst_mem_L1);
    end
    
    always@(posedge clk)begin
        if(!rstn)begin
            inst_if <= 32'b0;
            inst_access_fault <= 1'b0;
        end
        else begin
            if(pcin_if >= 64'd1000)begin   
                inst_if <= inst_if;
                inst_access_fault <= 1'b1;
            end
            else if(pcwrite) begin   
                if(write_en) inst_mem_L1[pcin_if>>2] <= inst_rd;     
                inst_if <= inst_mem_L1[pcin_if>>2];
                inst_access_fault <= 1'b0;
            end
            else begin
                inst_if <= inst_if;
                inst_access_fault <= 1'b0;
            end
        end
    end
    
endmodule
