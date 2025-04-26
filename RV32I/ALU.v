`timescale 1ns / 1ps

module ALU(
input [31:0] aluin1_ex, aluin2_ex,
input [3:0] alu_control,
output sub_carryout,
output reg [31:0] result
    );
    
    wire [31:0] sub_in1, sub_in2;
    wire [31:0] sub_out;
    
    /*
    wire [63:0] add_in1, add_in2, sub_in1, sub_in2;
    wire signed [63:0] mul_in1, mul_in2, div_in1, div_in2;
    wire add_carryout;
    wire [63:0] add_out;
    wire [63:0] MULW_out;
    wire [63:0] DIVW_out;
    wire [63:0] REMW_out;
    */
    
    always@(alu_control, aluin1_ex, aluin2_ex ,sub_out)begin
        case(alu_control)
            4'b0000: begin //AND
                result = aluin1_ex & aluin2_ex; 
            end
            
            4'b0001: begin //OR
                result = aluin1_ex | aluin2_ex; 
            end
            
            4'b0010:begin //ADD  
                result = aluin1_ex + aluin2_ex;
            end
            
            4'b0110:begin //SUB
                result = aluin1_ex - aluin2_ex;
            end
            
            4'b1011: begin//SLT
                if (aluin1_ex[31] == 1'b1 && aluin2_ex[31] == 1'b0) result = 1; 
                else if (aluin1_ex[31] == 1'b0 && aluin2_ex[31] == 1'b1) result = 0;  
                else if (aluin1_ex[31] == 1'b0 && aluin2_ex[31] == 1'b0 && aluin1_ex < aluin2_ex) result = 1;  
                else if (aluin1_ex[31] == 1'b1 && aluin2_ex[31] == 1'b1 && aluin1_ex > aluin2_ex) result = 1;  
                else result = 0;  
            end
               
            4'b1111: result = aluin1_ex ^ aluin2_ex; //XOR
            4'b1100: result = ~(aluin1_ex|aluin2_ex); //NOR
           
            /*
            4'b1001: begin//MULW
                result = MULW_out; //result = MULH_out;
            end
            4'b1101: begin//DIVW
                if(aluin2_ex == 0) result = -1;
                else result = DIVW_out;
            end
            4'b1110: begin//REMW 
                if(aluin2_ex == 0) result = -1;
                else result = REMW_out;
            end
            */
            
            4'b0101 : begin//sll
                result = aluin1_ex << aluin2_ex[5:0];//max 32 shift
            end
            4'b1010 : begin//sltu/
                result = (aluin1_ex < aluin2_ex) ? 1 : 0;
            end
            4'b0111 : begin //srl
                result = aluin1_ex >> aluin2_ex[5:0];//max 32 shift
            end
            4'b1000: begin //sra
                result = $signed(aluin1_ex) >>> aluin2_ex[5:0];
            end
            default: begin
                result = 32'b0;
            end
           
        endcase
    end
    
    assign sub_in1 = aluin1_ex;
    assign sub_in2 = aluin2_ex;
    
    FA_alu sub_alu(
    .in1(sub_in1),
    .in2(sub_in2),
    .result(sub_out),
    .mod(1),
    .carry_out(sub_carryout)
    );
    
    /*
    assign add_in1 = aluin1_ex;
    assign add_in2 = aluin2_ex;
    
    assign mul_in1 = aluin1_ex; 
    assign mul_in2 = aluin2_ex; 
    assign div_in1 = aluin1_ex; 
    assign div_in2 = aluin2_ex;
   
    
    FA_alu add_alu(
    .in1(add_in1),
    .in2(add_in2),
    .result(add_out),
    .mod(0),
    .carry_out(add_carryout)
    );
    

    multiplier_128 mul_alu (
    .multiplier(mul_in1),
    .multiplicand(mul_in2),
   // .mulh_result(),
    .mulw_result(MULW_out)
    );
    
    DIV div_alu(
    .quotient(div_in1),
    .dividend(div_in2),
    .alu_control(alu_control),
    .signed_result(DIVW_out)
    );*/
    
endmodule



//64bit FA
module FA_alu(
    input mod,
    input [31:0] in1, in2,
    output carry_out,
    output [31:0] result  
    );
    
    wire [31:0] B_comp;
    wire [31:0] carry;
    wire [31:0] sum;
    
    assign carry_out = carry[31];
    assign B_comp = in2^{32{mod}};
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
        for(i=1; i<32; i = i+1)begin: FA_loop
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

/*
//divider
module DIV(
    input signed [63:0] quotient,
    input signed [63:0] dividend,
    input [3:0] alu_control,
    output signed [63:0] signed_result
);

    assign signed_result = (alu_control == 4'b0000) ? ($signed(quotient) / $signed(dividend)) : 
                           (alu_control == 4'b0010) ? ($signed(quotient) % $signed(dividend)) : 64'b0;

endmodule

//multiplier
module multiplier_128(
    input signed [63:0] multiplier,
    input signed [63:0] multiplicand,
    output signed [63:0] mulh_result,
    output signed [63:0] mulw_result,
    output signed [127:0] result
);

    assign result = multiplier * multiplicand;

    assign mulh_result = (result[127] == 0 && |result[126:64] == 1) || (result[127] == 1 && result[126:64] == 0) ? result[127:64] : 64'b0;
    assign mulw_result = result[63:0];

endmodule
*/





