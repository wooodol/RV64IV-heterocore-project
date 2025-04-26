// Cache Spec:
//   - Data capacity: 16kB (실제 데이터만, 메타데이터는 별도)
//   - 8-way set associative, 각 라인 32Byte (256bit)
//   - 총 16kB/32B = 512 라인, 512/8 = 64 set, 인덱스: 6bit, 태그: 5bit, 오프셋: 5bit
//   - 교체정책: Tree based Pseudo-LRU (각 set마다 7-bit)

module L2 (
    input  wire         clk,
    input  wire         rstn,
    //input  wire         flush,   
    // L2 arbiter 인터페이스
    input  wire         arb_w_rb,       // write/Read_bar -> 1이면 write, 0이면 read하겠다는 의미 
    input  wire [10:0]  addr_in,        // 32bit addr from Arbiter
    input  wire         arb_req,        // arbiter의 req
    input  wire [255:0] wdata2cache,    // 쓰기 데이터 32 Byte
    input  wire         flush_req,      // 외부에서 flush 요청이 들어옴 
    output reg  [255:0] rdata2arb,      // 읽기 데이터 32 Byte
    output reg          ready2arb,      // 요청한 Read 또는 Write가 끝났을 떄 1로 올라감
    output reg          flush_ing    // flush를 시작하면 1, 끝나면 0 
);


//--------------------Parameter & Localparam---------------------------
parameter CACHE_SIZE = 16384;                   // 16kB
parameter LINE_SIZE  = 32;                      // 32 byte per cache line
parameter NUM_LINES  = CACHE_SIZE / LINE_SIZE;  // 16384/32 = 512 lines
parameter NUM_WAYS   = 8;
parameter NUM_SETS   = NUM_LINES / NUM_WAYS;    // 512/8 = 64 sets
localparam IDLE = 3'b000;
localparam LOOKUP = 3'b001;
localparam MISS = 3'b010;
localparam WRBACK = 3'b011;
localparam UPDATE = 3'b100;
localparam FLUSH = 3'b101;
//----------------------------------------------------------------------


//-------------------------BRAM modeling--------------------------------
(* ram_style = "block" *)reg [255:0] main_memory [2047:0]; // Capacity : 256 bit (32 Byte) * 2048 (2K) = 64 KB 
reg [255:0] wdata2bram;           // BRAM에 써주는 데이터 
reg [10:0] addr2bram;            // BRAM에 접근할 주소 
wire [255:0] rdata2bram;          // BRAM에서 읽어오는 데이터 
assign rdata2bram = main_memory [addr2bram];
//-------------------------BRAM modeling--------------------------------
//-------------readmemeh로 Main Memory(BRAM) 초기화 필요------------------
`ifndef SYNTHESIS
initial begin
    $readmemh("memory_init.hex", main_memory);
end
`endif
//-------------readmemeh로 Main Memory(BRAM) 초기화 필요------------------


//------- Addr[16bit] = index[6bit] + tag[5bit] + offset[5bit]---------
wire [10:0] addr = addr_in[10:0];
wire [5:0]  index  = addr[10:5];
wire [4:0]  tag_in = addr[4:0];
//----------------------------------------------------------------------


//---------------------Cache Data Structures----------------------------
reg [255:0] data_array [0:NUM_SETS-1][0:NUM_WAYS-1];  // 데이터 배열: 각 cache line은 256bit (32 byte)
reg [4:0]  tag_array  [0:NUM_SETS-1][0:NUM_WAYS-1];   // 태그 배열: 각 entry 5bit
reg         valid_array  [0:NUM_SETS-1][0:NUM_WAYS-1]; // valid면 1, invalid면 0
reg         dirty_array  [0:NUM_SETS-1][0:NUM_WAYS-1]; // dirty면 1, clean이면 0
reg [6:0]   plru_bits   [0:NUM_SETS-1];                // Pseudo-LRU 비트: 각 set 당 3bit
//----------------------------------------------------------------------


//------------------------Cache Controller------------------------------
reg [2:0] current_state;    // 현재 State를 나타냄
reg [2:0] next_state;       // 다음 클락의 State를 나타냄
reg [6:0] next_lru;         // 다음 클락에 업데이트 될 LRU bits임
reg [255:0] read_data;      // 다음 클락에 출력할, 캐시로부터 읽어온 데이터
reg [2:0] sel_way;          // tag_comp를 이진수로 표현하여 선택된 way를 나타냄
reg [2:0] victim_way;       // Miss 시에 교체 당할 way를 나타냄 
reg [8:0] flush_cnt;        // set을 나타내는 6 bit + way를 나타내는 3 bit = 9bit 
reg [1:0] wb_mode;          // FLUSH에서 WRBACK으로 왔으면 1, MISS에서 WRBACK으로 왔으면 0
reg       ready2arb_soon;   // ready2arb 신호를 1로 올리기 전에 먼저 1로 올림.
wire [7:0] tag_comp;        // 각 way 중 match된 way를 one hot encoding으로 나타냄
wire HIT;           
wire [5:0] flush_set; // FLSUH 수행할 때 몇 번 set을 봐야 하는지 나타냄
wire [2:0] flush_way; // FLUSH 수행할 때 몇 번 Way를 봐야 하는지 나타냄
//----------------------------------------------------------------------


//-------------------CPU addr HIT 여부 체크 로직--------------------------
assign tag_comp[0] = ( (tag_array[index][0]==tag_in) && (valid_array[index][0] == 1'b1) )? 1'b1 : 1'b0;
assign tag_comp[1] = ( (tag_array[index][1]==tag_in) && (valid_array[index][1] == 1'b1) )? 1'b1 : 1'b0;
assign tag_comp[2] = ( (tag_array[index][2]==tag_in) && (valid_array[index][2] == 1'b1) )? 1'b1 : 1'b0;
assign tag_comp[3] = ( (tag_array[index][3]==tag_in) && (valid_array[index][3] == 1'b1) )? 1'b1 : 1'b0;
assign tag_comp[4] = ( (tag_array[index][4]==tag_in) && (valid_array[index][4] == 1'b1) )? 1'b1 : 1'b0;
assign tag_comp[5] = ( (tag_array[index][5]==tag_in) && (valid_array[index][5] == 1'b1) )? 1'b1 : 1'b0;
assign tag_comp[6] = ( (tag_array[index][6]==tag_in) && (valid_array[index][6] == 1'b1) )? 1'b1 : 1'b0;
assign tag_comp[7] = ( (tag_array[index][7]==tag_in) && (valid_array[index][7] == 1'b1) )? 1'b1 : 1'b0;
assign HIT = ((tag_comp!=8'b0000_0000)&&(valid_array[index][sel_way]==1))? 1'b1 : 1'b0 ;
//----------------------------------------------------------------------


//-------------------FLSUH에서 사용할 INDEX 할당--------------------------
assign flush_set = flush_cnt[8:3];
assign flush_way = flush_cnt[2:0];
//----------------------------------------------------------------------


//--------------------CPU addr HIT 된 Way 할당---------------------------
always @(*) begin
   case (tag_comp) // 어떤 Way가 매칭되었는지 알려줌
      8'b1000_0000 : sel_way = 3'b111;
      8'b0100_0000 : sel_way = 3'b110;
      8'b0010_0000 : sel_way = 3'b101;
      8'b0001_0000 : sel_way = 3'b100;
      8'b0000_1000 : sel_way = 3'b011;
      8'b0000_0100 : sel_way = 3'b010;
      8'b0000_0010 : sel_way = 3'b001;
      8'b0000_0001 : sel_way = 3'b000;
           default : sel_way = 3'b000;
   endcase
end
//----------------------------------------------------------------------


//-------------------Pseudo-LRU 업데이트를 위한 로직 ----------------------
always @(*) begin
   case(sel_way) 
      3'b000 : next_lru = {3'b111, plru_bits[index][3:0]};
      3'b001 : next_lru = {3'b110, plru_bits[index][3:0]};
      3'b010 : next_lru = {2'b10, plru_bits[index][4], 1'b1, plru_bits[index][2:0]};
      3'b011 : next_lru = {2'b10, plru_bits[index][4], 1'b0, plru_bits[index][2:0]};
      3'b100 : next_lru = {1'b0, plru_bits[index][5:3], 2'b11, plru_bits[index][0]};
      3'b101 : next_lru = {1'b0, plru_bits[index][5:3], 2'b10, plru_bits[index][0]};
      3'b110 : next_lru = {1'b0, plru_bits[index][5:3], 1'b0, plru_bits[index][1], 1'b1};
      3'b111 : next_lru = {1'b0, plru_bits[index][5:3], 1'b0, plru_bits[index][1], 1'b0};
      default : next_lru = {3'b111, plru_bits[index][3:0]};
   endcase
end
//----------------------------------------------------------------------


//-----------------------Victim Way 선정 로직----------------------------
always @(*) begin
    // top-level: bit6이 0이면 좌측(ways0-3), 1이면 우측(ways4-7)
    victim_way[2] = plru_bits[index][6];

    if (plru_bits[index][6] == 0) begin
        // 좌측 서브트리: bit5이 0→ways0-1, 1→ways2-3
        victim_way[1] = plru_bits[index][5];
        if (plru_bits[index][5] == 0)
            victim_way[0] = plru_bits[index][4];  // ways0 vs 1
        else
            victim_way[0] = plru_bits[index][3];  // ways2 vs 3
    end else begin
        // 우측 서브트리: bit2이 0→ways4-5, 1→ways6-7
        victim_way[1] = plru_bits[index][2];
        if (plru_bits[index][2] == 0)
            victim_way[0] = plru_bits[index][1];  // ways4 vs 5
        else
            victim_way[0] = plru_bits[index][0];  // ways6 vs 7
    end
end
//----------------------------------------------------------------------


//------------------BRAM에 보낼 주소와 데이터 할당 로직----------------------
always @(*) begin
   case(wb_mode)
      2'b00 : begin
                 addr2bram = { index, tag_in };//addr2bram = { index, tag_array[index][victim_way] };
                 wdata2bram = 256'b0; // Latch 방지용
              end
             
      2'b01 : begin 
                 addr2bram = { index, tag_array[index][victim_way] };
                 wdata2bram = data_array[index][victim_way];
              end
               
      2'b10 : begin 
                 addr2bram = { flush_set, tag_array[flush_set][flush_way] };
                 wdata2bram = data_array[flush_set][flush_way];
              end      
              
      default : begin
                   addr2bram = { index, tag_in };//addr2bram = { index, tag_array[index][victim_way] };
                   wdata2bram = 256'b0; // Latch 방지용
                end       
   endcase
end
//----------------------------------------------------------------------


//------------------------State 로직 수행--------------------------------
always @(*) begin
   case (current_state) 
      IDLE : begin
                if (flush_req == 1) begin
                   next_state = FLUSH;
                end else begin
                   if (arb_req == 1) begin
                      next_state = LOOKUP;
                   end else begin
                      next_state = IDLE;
                   end
                end
             end 
      
      
      LOOKUP :begin
                 if (HIT == 1) begin
                    next_state = IDLE;
                 end else if (HIT == 0) begin
                    next_state = MISS;
                 end
              end
     
                   
      MISS : begin
                if ((dirty_array[index][victim_way] == 1) && (valid_array[index][victim_way] == 1)) begin
                   next_state = WRBACK;
                end else begin 
                   next_state = UPDATE;
                end
             end
          
          
      WRBACK : begin
                  if (wb_mode == 2'b01) begin
                     next_state = UPDATE;
                     wb_mode <= 2'b00;
                  end else begin
                     next_state = FLUSH;
                  end
               end
            
            
      UPDATE : begin
                  next_state = LOOKUP;  
               end
                         
           
      FLUSH : begin
                 if (dirty_array[flush_set][flush_way] == 0) begin
                    if (flush_cnt != 0) begin
                       next_state = FLUSH;
                    end else if (flush_cnt == 0) begin
                       next_state = IDLE;
                    end
                 end else begin
                    next_state = WRBACK;
                 end 
              end
           
           
   default : begin
                next_state = IDLE;
             end
             
endcase
end
//----------------------------------------------------------------------       





integer i, j; // Reset을 위한 Internal Variables
always @(posedge clk or negedge rstn) begin
//--------------------Cache 초기화 및 동작 로직----------------------------
    if (!rstn) begin
        for (i = 0; i < NUM_SETS; i = i + 1) begin
            plru_bits[i] <= 7'b0000000;  // Pseudo-LRU 초기화
            for (j = 0; j < NUM_WAYS; j = j + 1) begin
                tag_array[i][j]  <= 5'b0;    // 모든 태그를 0으로 초기화
                valid_array[i][j]<=1'b0;      // 모든 V bit를 0으로 초기화 
                dirty_array[i][j]<=1'b0;      // 모든 V bit를 0으로 초기화 
                data_array[i][j] <= 256'b0;   // 굳이 할 필요는 없으나 디버깅을 위해 넣었음
            end
        end
        rdata2arb <= 256'b0;
        current_state <= IDLE;
        wb_mode <= 2'b00;
        ready2arb_soon <= 0;
        flush_cnt <= 9'b1_1111_1111;
        flush_ing <= 0;
 //----------------------------------------------------------------------       
    end else begin
        current_state <= next_state;
        
        if (ready2arb_soon == 1) begin
           ready2arb_soon <= 0;
        end
        
        case(current_state)
             IDLE : begin
                       ready2arb <= ready2arb_soon;
                       if (next_state == FLUSH) begin
                          wb_mode <= 2'b10;
                          flush_ing <= 1'b1;
                       end
                    end
             
             LOOKUP : begin
                         if (HIT == 1) begin  
                            plru_bits[index] <= next_lru; // LRU bits 업데이트 
                            ready2arb_soon <= 1;
                            if (arb_w_rb == 0) begin
                               rdata2arb <= data_array[index][sel_way]; // Read 였다면 읽은 Data 출력
                            end else if (arb_w_rb == 1) begin
                               data_array[index][sel_way] <= wdata2cache;
                               dirty_array[index][sel_way] <= 1'b1;                               
                            end                          
                         end
                      end  
                       
                    
              MISS : begin
                        if(next_state == WRBACK) begin
                           wb_mode <= 2'b01;
                        end 
                     end      
                     
                     
              WRBACK : begin
                          main_memory [addr2bram] <= wdata2bram;
                          if (wb_mode == 2'b01) begin
                             dirty_array[index][victim_way] <= 1'b0;
                          end else begin
                             dirty_array[flush_set][flush_way] <= 1'b0;   
                          end
                       end
              
              
              UPDATE : begin
                          data_array[index][victim_way] <= rdata2bram;
                          tag_array[index][victim_way] <= tag_in;
                          valid_array[index][victim_way] <= 1'b1;
                       end
            
            
              FLUSH : begin                      
                         if (next_state == FLUSH) begin
                            valid_array[flush_set][flush_way] <= 1'b0; // Tag 초기화는 굳이 안해도 됨 
                         end                        
           
                         if (flush_way == 3'b000) begin
                            plru_bits[flush_set] <= 7'b0000000; // LRU bits도 꼭 초기화할 필요는 없어서 나중에 자원 부족하면 없애도 됨 
                         end
                         
                         if ((flush_cnt != 0)&&(next_state != WRBACK)) begin
                            flush_cnt <= flush_cnt - 1;
                         end
                     
                         if (next_state == IDLE) begin
                             flush_cnt <= 9'b1_1111_1111;
                             flush_ing <= 0;
                             wb_mode <= 2'b00;
                         end
                      end           
                      
                      
              default : begin
                           // NO OPERATION
                        end
                        
                        
        endcase
    end
end


endmodule
