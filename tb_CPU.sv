`timescale 1ns / 1ps

module tb_CPU( );

    integer i = 1;
    integer j = 0;
    
    
    reg clk, rstn, cnt_start;
    
    CPU_top uut(clk,rstn);
    
    always@(posedge clk)
        if(cnt_start) j <= j + 1;
    
    initial begin 
        uut.instruction_cache_mem.memory_8[0:79] = 
        {
            8'b00000000, 8'b00010000, 8'b10000000, 8'b10010011, //     addi x1, x1, #1
            8'b00000000, 8'b00100011, 8'b00000011, 8'b00010011, //     addi x6, x6, #2
            8'b00000000, 8'b01100000, 8'b11100010, 8'b01100011, //     bltu x1,x6,jmp
            8'b00010000, 8'b00010001, 8'b10000001, 8'b10010011, //     addi x3, x3, #101
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, //
            8'b00010000, 8'b00010010, 8'b00000010, 8'b00010011, // jmp:addi x4, x4, #101
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000,
            8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000  //       NOP


            };
        for(i = 80; i<400; i = i + 1) begin
            uut.instruction_cache_mem.memory_8[i] = 8'b0;
        end
    end
    
    initial begin
        for(i = 0; i<100; i = i+1)begin
            uut.instruction_cache_mem.memory[i] = 
                {uut.instruction_cache_mem.memory_8[4*i], 
                uut.instruction_cache_mem.memory_8[4*i+1], 
                uut.instruction_cache_mem.memory_8[4*i+2],
                uut.instruction_cache_mem.memory_8[4*i+3]};
        end
    end
    
    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        cnt_start = 0;
        rstn = 0;
        
        #25
        rstn = 1;
        cnt_start = 1;
    end
    
    initial #1000 $finish;

endmodule
