

//
// big fifo using igloo2's esram
//
module bigfifo(
input mclk /* synthesis syn_keep = 1 */,    // sync to i2s
input reset_n,

//sdio interface
input sdclk_n /* synthesis syn_keep = 1 */,
input wen,
input [31:0] din,
input is_last_data,

//i2s interface
input ren,
output [31:0] dout,

output [7:0] debug,

//AHB master interface
input  HREADY,
input  [31:0] HRDATA,
output [31:0] HADDR,
output reg [31:0] HWDATA,
output reg [1:0] HTRANS,
output reg HWRITE,

//FIFO status
output almost_empty,
output almost_full
);


parameter IDLE = 3'd0;
parameter READ_AHB = 3'd1;
parameter WRITE_AHB = 3'd2;
parameter WRITE_10 = 3'd3;
parameter CONFIG = 3'd4;
parameter L5 = 3'd5;
parameter L6 = 3'd6;
parameter L7 = 3'd7;


// Igloo2's eSRAM has 64KB, the address is from 0x20000000 to 0x2000FFFF
// since we always do 32bit transfer, we only need 14bit address space
// for WRITING eSRAM, 50MHz every 8 cycles we have a write command
// read clock min is 45MHz, has a read every 32cycles min, so better finish read+write <5 cycles 
// so the speed is fast enough 

parameter ADDWID = 14;
reg  [ADDWID - 1:0] addr, n_addr;
reg  [ADDWID - 1:0] write_addr, n_write_addr;
reg  [ADDWID - 1:0] write_block_addr, n_write_block_addr;
reg  [ADDWID - 1:0] read_addr, n_read_addr;
wire [ADDWID - 1:0] next_write_addr, next_read_addr;
wire [ADDWID - 1:0] read_addr_inc;
wire [ADDWID - 1:0] fifo_level;
assign fifo_level = write_addr - read_addr;

parameter ALMOST_FULL_LEVEL = 14'd1580;
parameter ALMOST_EMPTY_LEVEL = 14'd5;

//parameter ALMOST_FULL_LEVEL = 14'd7000;
//parameter ALMOST_FULL_LEVEL = 14'd14000;
//parameter ALMOST_EMPTY_LEVEL = 14'd5;

reg full, empty;
always @(posedge mclk or negedge reset_n) 
    if (1'b0 == reset_n) begin
        full <= 0;
        empty <= 0;
        end
    else begin
        full <= (fifo_level > ALMOST_FULL_LEVEL);
        empty <= (fifo_level < ALMOST_EMPTY_LEVEL);
        end

reg [3:0] a_full, a_empty;
always @(posedge sdclk_n) a_full <= {a_full[2:0], full};
always @(posedge sdclk_n) a_empty <= {a_empty[2:0], empty};
assign almost_full = a_full[3];
assign almost_empty = a_empty[3];

reg pipeline_cmd, n_pipeline_cmd;

assign HADDR = pipeline_cmd ? 32'h40038080 : {16'h2000, addr, 2'b00};
//assign HADDR = pipeline_cmd ? 32'h40038080 : {16'h2000, 1'b0, addr, 2'b00};
//assign HADDR = {16'h2000, 1'b1, addr, 2'b00};
//assign HADDR = 32'h20001000;

assign next_write_addr = write_addr + 14'd1;
assign read_addr_inc = read_addr + 14'd1;
assign next_read_addr = (read_addr_inc == write_block_addr) ? read_addr : read_addr_inc;

reg wen_toggle;
always @(posedge sdclk_n or negedge reset_n) 
    if (1'b0 == reset_n) begin
          wen_toggle <= 0;
          end
    else  begin 
          wen_toggle <= (wen ^ wen_toggle);
          end

reg [31:0] c0, c1, c2, c3;
always @(posedge mclk) c0 <= din;
always @(posedge mclk) c1 <= c0;
always @(posedge mclk) c2 <= c1;
always @(posedge mclk) c3 <= c2;

parameter isl_width = 2;
reg [isl_width - 1 : 0] isl;
always @(posedge mclk) isl = {isl[isl_width-2: 0], is_last_data};

parameter sync_width = 3;
reg [sync_width-1:0] sync_wen; //for clock domain crossing
always @(posedge mclk or negedge reset_n)
    if (1'b0 == reset_n) sync_wen <= 0; else sync_wen <= {sync_wen [sync_width-2:0], wen_toggle};

wire en = (sync_wen[sync_width-1] ^ sync_wen[sync_width-2]);

reg [31:0] d0 ;
reg [31:0] n_d0;
assign dout = d0;


reg [2:0] state, n_state;

//AHBLite IF
reg n_HWRITE;
reg [1:0] n_HTRANS; 
reg [31:0] n_HWDATA;

//reg [7:0] db, n_db;
assign debug = 8'h99;

reg [7:0] i, n_i;
reg [7:0] j, n_j;
reg ready, n_ready;

always @(posedge mclk or negedge reset_n)
    if (1'b0 == reset_n) begin
        state <= 0;
        addr <= 0;
        write_addr <= 0;
        write_block_addr <= 0;
        read_addr <= 0;
        d0 <= 0;
        HWRITE <= 0; HTRANS <= 0; HWDATA <= 0;
        i <= 0;
        j <= 0; 
//        db <= 0;
        ready <= 0;
        pipeline_cmd <= 0;
        end
    else begin
        state <= n_state;
        addr <= n_addr;
        write_addr <= n_write_addr;
        write_block_addr <= n_write_block_addr;
        read_addr <= n_read_addr;
        d0 <= n_d0;
        HWRITE <= n_HWRITE; HTRANS <= n_HTRANS; HWDATA <= n_HWDATA;
        i <= n_i;
        j <= n_j; 
//        db <= n_db;
        ready <= n_ready;
        pipeline_cmd <= n_pipeline_cmd;
        end


always @* begin
    n_state = state;
    n_addr = addr;
    n_write_addr = write_addr;
    n_write_block_addr = write_block_addr;
    n_read_addr = read_addr;
    n_d0 = d0;
    n_HWRITE = HWRITE;
    n_HTRANS = HTRANS;
    n_HWDATA = HWDATA;
    n_i = i;
    n_j = j; 
//    n_db = db;
    n_ready = ready;
    n_pipeline_cmd = pipeline_cmd;

    case(state)

IDLE: begin
    n_HWRITE = 1'b0;
    n_HTRANS = 2'b00;  //IDLE
    n_i = i + 8'd1;
    n_j = 2'd0;
    n_HWDATA = 32'd0;
    n_addr = 0;
    if (8'd100 == i && HREADY) begin
        n_addr = read_addr;
        n_HWRITE = 1'b0;  //read
        n_HTRANS = 2'b10; //start reading
        n_state = READ_AHB;
        n_i = 8'd0;
//        n_db = 8'h99;
       
        n_HWDATA = 0;  //disable pipeline
        n_pipeline_cmd = 1'b1;
        n_HWRITE = 1'b1;
        n_state = CONFIG;
        end

    end

READ_AHB: begin
    if (ren) n_read_addr = (read_addr_inc == write_block_addr) ? read_addr : (read_addr_inc);
    if (ren) n_i = 8'd0;  else if (i< 8'd31) n_i = i + 8'd1;

    n_HWRITE = 1'b0;  //READ
    n_HTRANS = 2'b10; //NONSEQ
    n_addr = read_addr; 

    if (j < 8'd15) n_j = j+ 8'd1;
    if (ren) n_j = 0;

    n_ready = HREADY;

    if (i>8'd6 && i < 8'd50 && ready && j > 8'd2) begin
        n_d0 = HRDATA;
        n_i = 8'd55;
        n_j = 0;
        end
   
    if (en) n_state =  WRITE_AHB;
    if (en) n_HWDATA = c1;
    end

WRITE_AHB:  begin 

    if (ren) n_read_addr = (read_addr_inc == write_block_addr) ? read_addr : (read_addr_inc);
    if (ren) n_i = 8'd0; else if (i< 8'd31) n_i = i + 8'd1;
    n_j = 8'd0;
   
    n_addr = write_addr; 
    if (HREADY) begin
        n_addr = write_addr; 
        n_write_addr = next_write_addr;
        if (isl[isl_width-1]) n_write_block_addr = next_write_addr;
        n_HWRITE = 1'b1;           //addr phase
        n_HTRANS = 2'b10;  
        //n_HWDATA = c1;
        n_state =  WRITE_10;   
        end

    end

WRITE_10:  begin 
    if (ren) n_read_addr = (read_addr_inc == write_block_addr) ? read_addr : (read_addr_inc);
    if (ren) n_i = 8'd0; else if (i< 8'd31) n_i = i + 8'd1;

    if (HREADY) begin   //data phase
        n_HWDATA = HWDATA;
        n_HWRITE = 1'b0;   //read
        n_HTRANS = 2'b10;  
        n_addr = read_addr; 
        n_state = READ_AHB;
        end
    end

CONFIG: begin
   if (HREADY) begin
       n_state = READ_AHB;
       n_HWRITE = 1'b0;
       n_addr = read_addr;
       n_pipeline_cmd = 0;
       end
   end

L5: begin end
L6: begin end
L7: begin end

    endcase
    end
endmodule




