`timescale 1ns / 1ps

module ALU(
input [63:0] aluin1_ex, aluin2_ex,
input [3:0] alu_control,
output sub_carryout,
output reg [63:0] result
    );
    
    wire [63:0] add_in1, add_in2, sub_in1, sub_in2;
    
    wire add_carryout;
    wire [63:0] add_out;
    wire [63:0] sub_out;
    
    always@(alu_control, aluin1_ex, aluin2_ex, add_out,sub_out)begin
        case(alu_control)
            4'b0000: begin //AND
                result = aluin1_ex & aluin2_ex; 
            end
            4'b0001: begin //OR
                result = aluin1_ex | aluin2_ex; 
            end
            4'b0010:begin //ADD  
                result = add_out;
            end
            4'b0110:begin //SUB
                result = sub_out;
            end
            4'b0111: result = (aluin1_ex < aluin2_ex)? 1:0; //SLT
            4'b1111: result = aluin1_ex ^ aluin2_ex; //XOR
            4'b1100: result = ~(aluin1_ex|aluin2_ex); //NOR
            default: begin
                result = 64'b0;
            end
            //MUL
            //DIV
        endcase
    end
    
    assign add_in1 = aluin1_ex;
    assign add_in2 = aluin2_ex;
    assign sub_in1 = aluin1_ex;
    assign sub_in2 = aluin2_ex;
    
    FA_alu add_alu(
    .in1(add_in1),
    .in2(add_in2),
    .result(add_out),
    .mod(0),
    .carry_out(add_carryout)
    );
    
    FA_alu sub_alu(
    .in1(sub_in1),
    .in2(sub_in2),
    .result(sub_out),
    .mod(1),
    .carry_out(sub_carryout)
    );
    
endmodule



//64bit FA
module FA_alu(
    input mod,
    input [63:0] in1, in2,
    output carry_out,
    output [63:0] result  
    );
    
    wire [63:0] B_comp;
    wire [63:0] carry;
    wire [63:0] sum;
    
    assign carry_out = carry[63];
    assign B_comp = in2^{64{mod}};
    assign result = sum;
    
    adder adder0(
    .a(in1[0]),
    .b(B_comp[0]),
    .cin(mod),
    .cout(carry[0]),
    .sum(sum[0])
    );
    
    genvar i;
    generate
        for(i=1; i<64; i = i+1)begin: FA_loop
            adder adder(
            .a(in1[i]),
            .b(B_comp[i]),
            .cin(carry[i-1]),
            .sum(sum[i]),
            .cout(carry[i])
            );
        end
    endgenerate
    
endmodule

//adder
module adder(
    input a, b, cin,
    output cout, sum
    );
    
    assign cout = (a&b) | (a&cin) | (b&cin);
    assign sum = cin^a^b;
    
endmodule
