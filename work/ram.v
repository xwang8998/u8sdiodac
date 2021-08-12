
// ctrl format:
// ctrl[7:0] = {start_controller, start_i2s, use_dsd, 2'b00,  bck_divider}
// status format:
// {almost_full, almost_empty, empty, 5'h00};

`define BCLK_DIV_32  3'b000
`define BCLK_DIV_16  3'b001
`define BCLK_DIV_8   3'b010
`define BCLK_DIV_4   3'b011
`define BCLK_DIV_2   3'b100
`define BCLK_DIV_1   3'b101


// for DAC
module mem_controller(
input sdclk_n,   // from SDIO host
input mclk,    // Audio Master Clock
input reset_n,

//AHB master interface
input  HREADY,
input  [31:0] HRDATA,
output [31:0] HADDR,
output [31:0] HWDATA,
output [1:0] HTRANS,
output HWRITE,

// from SDIO host
input [7:0] ctrl,    // command from sdio host
input [31:0] din,    // data received from sdio host
input wen,           // data write enable
input is_last_data,  // last data from the block

// to SDIO host
output [7:0] status,

// to DAC , put out pcm data periodically, like gears
output reg [31:0] pcm_left,
output reg [31:0] pcm_right,

// from DSD138
input bck,
input lrck,
// to DSD138
output [7:0] dsd138_ctrl,
output sdata,
output [7:0]dbm     //debug
);


wire start_controller;
assign start_controller = ctrl[7];

wire sdctrl_start_i2s;
wire sdctrl_use_dsd;
wire [2:0] sdctrl_bck_divider;

sync_logic  #(.c_DATA_WIDTH (1)) usync100(
   .rstn(reset_n), .wr_clk(sdclk_n), .wr_data(ctrl[6] & ctrl[7]), .rd_clk(mclk), .rd_data (sdctrl_start_i2s));

sync_logic  #(.c_DATA_WIDTH (1)) usync101(
   .rstn(reset_n), .wr_clk(sdclk_n), .wr_data(ctrl[5]), .rd_clk(mclk), .rd_data (sdctrl_use_dsd));

sync_logic  #(.c_DATA_WIDTH (3)) usync102(
   .rstn(reset_n), .wr_clk(sdclk_n), .wr_data(ctrl[2:0]), .rd_clk(mclk), .rd_data (sdctrl_bck_divider));


//////FIFO////////////////////////////////////////////////////////////////////////////////

wire almost_full, almost_empty;
wire [31:0] dout;
reg read_en; //controlled by i2s

bigfifo  ufifo(.mclk(mclk), .reset_n(reset_n & start_controller), .sdclk_n(sdclk_n), .wen(wen), .din(din),
.is_last_data(is_last_data),
.ren(read_en), .dout(dout),  //i2s
.debug(dbm),
.HREADY(HREADY), .HRDATA(HRDATA), .HADDR(HADDR), .HWDATA(HWDATA), .HTRANS(HTRANS), .HWRITE(HWRITE),
.almost_full(almost_full), .almost_empty(almost_empty));


wire almost_full_sync;
sync_logic  #(.c_DATA_WIDTH (1)) usync600(
   .rstn(reset_n & start_controller), .wr_clk(sdclk_n), .wr_data(almost_full), .rd_clk(mclk), .rd_data (almost_full_sync));


/////////////// i2s ctrl ////////////////////
// need to consider 2 situations:
// 1) max speed mode, MCLK==BCK, no clock divider, 
//    this is the case when bck_divider = 3'b000
//    only need to sample LRCK
// 2) BCK <= 1/2 of MCLK, bck is 1/2, 1/4, 1/8 of MCLK
//    we need to sample bck

reg [1:0] state, n_state;
reg n_read_en;
reg fifo_clear_i2s;
reg n_fifo_clear_i2s;
reg sound_card_start, n_sound_card_start;
reg use_dsd, n_use_dsd;
reg [2:0] bck_divider, n_bck_divider;
reg data, n_data;  //pcm/dsd data
reg [4:0] k, n_k;
reg [31:0] pcm, n_pcm;
reg bit;

reg [31:0] n_pcm_left, n_pcm_right, n_left, left;
reg flag, n_flag;


always @* bit =  pcm[5'd31 - k];

reg old_lrck;
reg old_bck;
always @(posedge mclk or negedge reset_n)
    if (0==reset_n) begin
        state <= 0;
        read_en <= 0;
        fifo_clear_i2s <= 0;
        sound_card_start <= 0;
        use_dsd <= 0;
        bck_divider <= 0;
        data <= 0;
        old_lrck <= 0;
        old_bck <= 0;
        pcm <= 0;
        k <= 0;
        pcm_left <= 0;
        pcm_right <= 0;
        left <= 0;
        flag <= 0;
        end
    else begin
        state <= n_state;
        read_en <= n_read_en;
        fifo_clear_i2s <= n_fifo_clear_i2s;
        sound_card_start <= n_sound_card_start;
        use_dsd <= n_use_dsd;
        bck_divider <= n_bck_divider;
        data <= n_data;
        old_lrck <= lrck;
        old_bck <= bck; 
        pcm <= n_pcm;
        k <= n_k;
        pcm_left <= n_pcm_left;
        pcm_right <= n_pcm_right;
        left <= n_left;
        flag <= n_flag;
        end

parameter I2S_IDLE = 0;
//parameter I2S_START = 1;
parameter I2S_WAIT = 1;
parameter I2S_LOOP = 2;
parameter I2S_LOOP2 = 3;


reg is_max_bck;
always @* if (`BCLK_DIV_1  == sdctrl_bck_divider) is_max_bck = 1; else is_max_bck = 0;


always @* begin
    n_state = state;
    n_read_en = read_en;
    n_fifo_clear_i2s = fifo_clear_i2s;
    n_sound_card_start = sound_card_start;
    n_use_dsd = use_dsd;
    n_bck_divider = bck_divider;
    n_data = data;
    n_pcm = pcm;
    n_k = k;
    n_pcm_left = pcm_left;
    n_pcm_right = pcm_right;
    n_left = left;
    n_flag = flag;

    case (state)

I2S_IDLE: begin
    n_fifo_clear_i2s = 1'b1; //keep fifo @ zero offset
    n_sound_card_start = 1'b0;
    n_read_en = 1'b0;
    n_use_dsd = sdctrl_use_dsd;
    n_bck_divider = sdctrl_bck_divider;
    if (use_dsd) n_pcm_left = 32'h55555555; else n_pcm_left = 32'h0;
    if (use_dsd) n_pcm_right = 32'h55555555; else n_pcm_right = 32'h0;
    n_flag = 1'b0;

    //if (sdctrl_start_i2s) begin
    if (sdctrl_start_i2s && almost_full_sync) begin
    //if (sdctrl_start_i2s && write_addr[9]) begin
       n_state = I2S_WAIT;
       n_fifo_clear_i2s = 1'b0;
       n_sound_card_start = 1'b1;
       n_read_en = 1'b1;
       n_pcm = dout;
       end
    end

//I2S_START: begin
//    n_fifo_clear_i2s = 0;
//    n_sound_card_start = 1;
//    n_read_en = 1;
//    n_pcm = dout;    
//    n_state = I2S_WAIT;  
//    end

I2S_WAIT:begin
    n_read_en = 1'b0;
    n_data = 1'b0;
    if (old_lrck == 1'b1 && lrck == 1'b0) begin      //I2S left
        n_k = 5'd1;
        n_data = bit;
        if (is_max_bck) begin;
             n_state = I2S_LOOP;
             n_pcm = dout;
             n_left = dout;
             n_flag = ~flag;
             n_read_en = 1'b1;
             n_k = 5'd1;
             end
        else begin
             n_state = I2S_LOOP2;
             n_pcm = dout;
             n_left = dout;
             n_flag = ~flag;
             n_read_en = 1'b1;
             n_k = 5'd0;
             end
        end
    end

I2S_LOOP: begin
    n_read_en = 1'b0;
    n_k = k + 5'd1;
    n_data = bit;
    n_state = I2S_LOOP;
    
    if (k == 5'd31) begin
        n_pcm = dout;
        n_read_en = 1'b1;
        n_flag = ~flag;
        if (flag) begin
            n_pcm_left = left;
            n_pcm_right = dout;
            end
        else begin
            n_left = dout;
            end
        end

    //start/stop ctrl
    if (0 == sdctrl_start_i2s) begin
        n_state = I2S_IDLE;
        n_sound_card_start = 1'b0;
        n_fifo_clear_i2s = 1'b1;
        n_read_en = 1'b0;
        end

    end
// bck is divided from mclk
I2S_LOOP2: begin
    n_read_en =1'b0;
    n_state = I2S_LOOP2;

    if (old_bck == 1'b0 && bck == 1'b1) begin
        n_k = k + 5'd1;
        n_data = bit;
        n_state = I2S_LOOP2;

        if (k == 5'd30) begin
            n_read_en = 1'b1;
            end
        if (k == 5'd31) begin
            //n_data = dout[31];
            n_pcm = dout;

            n_flag = ~flag;
            if (flag) begin
                n_pcm_left = left;
                n_pcm_right = dout;
                end
            else begin
                n_left = dout;
                end

            //n_read_en = 1'b1;
            end
        end

    //start/stop ctrl
    //if ((0 == sdctrl_start_i2s) || almost_empty) begin
    if (1'b0 == sdctrl_start_i2s) begin
        n_state = I2S_IDLE;
        n_sound_card_start = 1'b0;
        n_fifo_clear_i2s = 1'b1;
        n_read_en = 1'b0;
        end
    end

default: n_state = I2S_IDLE;

    endcase
    end

//output ports
assign status = {almost_full, almost_empty, 6'd0};
assign sdata = data;
assign dsd138_ctrl = {sound_card_start, use_dsd, 3'b000, bck_divider};
//assign dsd138_ctrl = {sound_card_start, 1'b1, 3'b000, bck_divider};

//assign dbm = {1'b1, sound_card_start, bck_divider, ctrl[7], ctrl[6], 1'b0};
//assign dbm = 8'b10110011;
//assign dbm = {1'b1, sound_card_start, bck_divider, ctrl[7], ctrl[6], reset_n&sdctrl_start_i2s};
//assign dbm = pcm[31:24];
//assign dbm = {6'd0, state};

endmodule

// use 2 port ram, sdio 1 block = 512 bytes, 
// we are doing it on 2 FPGAs: 
// MachXO3L-2100, which has 74kbit EBR SRAM
// Microsemi igloo2 M2GL005, has LSRAM blocks 10x1Kx18=180Kbit
// we will use 16bit data width here, with 1 unit, 
// use 2 units in parallel, we get a 32bit data width word
// so machxo3 can hold 2K words, igloo2 can hold 5k 32bit-words
// we choose 2k words here, so the memory can hold 16 SDIO blocks
// we will use 16-SDIO block buffer!!

module ram_2p(
input wclk,
input wrst,
input wce,
input we,
input [11:0] waddr,
input [31:0] di,

input rclk,
input rrst,
input rce,
input oe,
input [11:0] raddr,
output [31:0] dout
);

wire [31:0] dout0, dout1, dout2, dout3;
reg [31:0] out;
reg we0, we1, we2, we3;

wire [31:0] di2;

assign di2 = di;
assign  dout = out;

//reg [31:0] bx;
//always @(posedge wclk or negedge wrst)
//   if (0 == wrst) begin
//       bx <= 0;
//       end
//   else begin
//       if (we) bx <= di2; else bx <= bx;
//       end
//assign  dout = bx;


always @* begin
    we0 = 0;
    we1 = 0;
    we2 = 0;
    we3 = 0;
    if (waddr[11:10] == 2'b00) we0 = we;
    else if (waddr[11:10] == 2'b01) we1 = we;
    else if (waddr[11:10] == 2'b10) we2 = we;
    else we3 = we;
    end

always @* begin
    out = 0;
    if (raddr[11:10] == 2'b00) out = dout0;
    else if (raddr[11:10] == 2'b01) out = dout1;
    else if (raddr[11:10] == 2'b10) out = dout2;
    else out = dout3;
    end


ram_2p_igloo2 U100 (.wclk(wclk), .wrst(wrst), .wce(wce), .we(we0), .waddr(waddr[9:0]),
     .di(di2), .rclk(rclk), .rrst(rrst), .rce(rce), .oe(oe), .raddr(raddr[9:0]), .dout(dout0));

ram_2p_igloo2 U101 (.wclk(wclk), .wrst(wrst), .wce(wce), .we(we1), .waddr(waddr[9:0]),
     .di(di2), .rclk(rclk), .rrst(rrst), .rce(rce), .oe(oe), .raddr(raddr[9:0]), .dout(dout1));

ram_2p_igloo2 U102 (.wclk(wclk), .wrst(wrst), .wce(wce), .we(we2), .waddr(waddr[9:0]),
     .di(di2), .rclk(rclk), .rrst(rrst), .rce(rce), .oe(oe), .raddr(raddr[9:0]), .dout(dout2));

ram_2p_igloo2 U103 (.wclk(wclk), .wrst(wrst), .wce(wce), .we(we3), .waddr(waddr[9:0]),
     .di(di2), .rclk(rclk), .rrst(rrst), .rce(rce), .oe(oe), .raddr(raddr[9:0]), .dout(dout3));


endmodule

module sync_logic #(
parameter c_DATA_WIDTH = 10
)
(
rstn,
wr_clk,
wr_data,
rd_clk,
rd_data
);
input rstn;
input wr_clk;
input [c_DATA_WIDTH-1:0] wr_data;
input rd_clk;
output [c_DATA_WIDTH-1:0] rd_data;

//registers driven by wr_clk               
reg [1:0] update_ack_dly;
reg update_strobe;
reg [c_DATA_WIDTH-1:0]  data_buf/* synthesis syn_preserve=1 */;
//registers driven by rd_clk
reg update_ack;                      
reg [3:0] update_strobe_dly;         
reg [c_DATA_WIDTH-1:0] data_buf_sync/* synthesis syn_preserve=1 */;

//************************************************************************************
always @(posedge wr_clk or negedge rstn)
   if (!rstn) begin
      update_ack_dly <= 0;
      update_strobe  <= 0;
      data_buf       <= 0;
   end
   else begin
      update_ack_dly <= {update_ack_dly[0], update_ack};
      if (update_strobe == update_ack_dly[1]) begin
         //latch new data 
         data_buf <= wr_data;
         update_strobe <= ~ update_strobe;
      end
   end   

//************************************************************************************
always @(posedge rd_clk or negedge rstn)
   if (!rstn) begin
      update_ack        <= 0;
      update_strobe_dly <= 0;
      data_buf_sync     <= 0;
   end
   else begin
      update_strobe_dly <= {update_strobe_dly[2:0], update_strobe};
      if (update_strobe_dly[3] != update_ack) begin
         data_buf_sync <= data_buf;
         update_ack    <= update_strobe_dly[3];
      end
   end

assign rd_data = data_buf_sync;
endmodule



//adc mem controller
module adc_controller(
input sdclk_n,   // from SDIO host
input mclk,    // Audio Master Clock
input reset_n,

//AHB master interface
input  HREADY,
input  [31:0] HRDATA,
output [31:0] HADDR,
output reg [31:0] HWDATA,
output reg [1:0] HTRANS,
output reg HWRITE,

// from SDIO host
input [7:0] ctrl,    // command from sdio host
input read_en,       // request data from fifo     

// to SDIO host
output [7:0] status,
output [31:0] card_to_host,

// to PCM gears
output [7:0] in_pcm_ctrl,

// from PCM gears
input bck,
input pcm_ready,
input [31:0] pcm32,
input is_right,

//debug
output [7:0]dbm     //debug
);

assign dbm = 8'h00;

parameter IDLE = 3'd0;
parameter WRITE_AHB = 3'd1;
parameter READ_AHB = 3'd2;
parameter READ_10 = 3'd3;
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

parameter ALMOST_FULL_LEVEL = 14'd16380;
parameter ALMOST_EMPTY_LEVEL = 14'd580;

reg full, empty;
always @(posedge mclk or negedge reset_n)
    if (1'b0 == reset_n) begin
        full <= 0;
        empty <= 1'b1;
        end
    else begin
        full <= (fifo_level > ALMOST_FULL_LEVEL);
        empty <= (fifo_level < ALMOST_EMPTY_LEVEL);
        end

reg [3:0] a_full, a_empty;
always @(posedge sdclk_n) a_full <= {a_full[2:0], full};
always @(posedge sdclk_n or negedge reset_n)
    if (1'b0 == reset_n) a_empty <= 4'b1111;
    else a_empty <= {a_empty[2:0], empty};

assign almost_full = a_full[3];
assign almost_empty = gear_ok ? a_empty[3] : 1'b1;

assign status[7] = almost_empty;
assign status[6] = almost_full;
assign status[5:0] = 0;

reg start, n_start;
assign in_pcm_ctrl = {start, ctrl[5], 6'd0};

reg pipeline_cmd, n_pipeline_cmd;
assign HADDR = pipeline_cmd ? 32'h40038080 : {16'h2000, addr, 2'b00};

reg gear_ok, n_gear_ok;
assign next_write_addr = gear_ok ? write_addr + 14'd1 : write_addr;
assign next_read_addr = read_addr + 14'd1;

reg ren_toggle;
always @(posedge sdclk_n or negedge reset_n)
    if (1'b0 == reset_n) begin
          ren_toggle <= 0;
          end
    else  begin
          ren_toggle <= (read_en ^ ren_toggle);
          end

parameter sync_width = 3;
reg [sync_width-1:0] sync_ren; //for clock domain crossing
always @(posedge mclk or negedge reset_n)
    if (1'b0 == reset_n) sync_ren <= 0; else sync_ren <= {sync_ren [sync_width-2:0], ren_toggle};

wire en = (sync_ren[sync_width-1] ^ sync_ren[sync_width-2]);

reg [31:0] d0 ;
reg [31:0] n_d0;

reg [31:0] c0, c1, c2;
always @(posedge sdclk_n) c0 <= d0;
always @(posedge sdclk_n) c1 <= c0;
always @(posedge sdclk_n) c2 <= c1;

assign card_to_host = c2;

//wire [31:0] read_data = 32'h12345678;
//assign  card_to_host = read_data;

reg [2:0] state, n_state;

//AHBLite IF
reg n_HWRITE;
reg [1:0] n_HTRANS;
reg [31:0] n_HWDATA;

reg [7:0] i, n_i;
reg [7:0] j, n_j;
reg ready, n_ready;


////////bck clock domain crossing////////
reg pcm_rdy;
reg [2:0] sync_bck; //for clock domain crossing
always @(posedge mclk or negedge reset_n)
    if (1'b0 == reset_n) sync_bck <= 0; else sync_bck <= {sync_bck [1:0], bck};

always @(posedge mclk) 
    if (sync_bck[2] == 1'b0 && sync_bck[1] == 1'b1) pcm_rdy <= pcm_ready; else pcm_rdy <= 1'b0;


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
        start <= 0;
        gear_ok <= 0;
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
        start <= n_start;
        gear_ok <= n_gear_ok;
        end


always @* begin
    n_state = state;
    n_addr = addr;
    n_write_addr = write_addr;
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
    n_start = start;
    n_gear_ok = gear_ok;

    case(state)

IDLE: begin
    n_start = 1'b0;
    n_gear_ok = 1'b0;
    n_HWRITE = 1'b0;
    n_HTRANS = 2'b00;  //IDLE
    n_i = i + 8'd1;
    n_j = 2'd0;
    n_HWDATA = 32'd0;
    n_addr = 0;
    n_write_addr = 1;
    n_read_addr = 0;
    n_d0 = 32'h55aa6699;
    if (8'd100 == i && HREADY) begin
        n_addr = write_addr;
        n_HWRITE = 1'b1;  //write
        n_HTRANS = 2'b10; //start 
        n_state = WRITE_AHB;
        n_i = 8'd0;
//        n_db = 8'h99;
       
        n_HWDATA = 0;  //disable pipeline
        n_HWRITE = 1'b1;
        n_pipeline_cmd = 1'b1;
        n_state = CONFIG;
        n_start = 1'b1;
        end

    end

WRITE_AHB: begin
    if (pcm_rdy) n_write_addr = next_write_addr;
    if (pcm_rdy) n_i = 8'd0;  else if (i< 8'd31) n_i = i + 8'd1;
    if (pcm_rdy & is_right) n_gear_ok = 1'b1;

    n_HWRITE = 1'b0;  //READ
    n_HTRANS = 2'b10; //NONSEQ
    n_addr = write_addr; 
    n_HWDATA = pcm32;  
    
    if (j < 8'd15) n_j = j+ 8'd1;
    if (pcm_ready) n_j = 0;

    n_ready = HREADY;

    if (i>8'd6 && i < 8'd50 && HREADY && j > 8'd2) begin
        //save pcm32, just once
        n_HWRITE = 1'b1;
        n_i = 8'd55;
        n_j = 0;
        end
   
    if (en) n_state =  READ_AHB;   //SDIO asks for data
    end

READ_AHB:  begin 
    if (pcm_rdy) n_write_addr = next_write_addr;
    if (pcm_rdy) n_i = 8'd0;  else if (i< 8'd31) n_i = i + 8'd1;
    n_j = 8'd0;
   
    n_addr = read_addr; 
    if (HREADY) begin
        n_addr = read_addr; 
        n_read_addr = next_read_addr;
        n_HWRITE = 1'b0;           //addr phase
        n_HTRANS = 2'b10;  
        n_state =  READ_10;   
        end

    end

READ_10:  begin 
    if (pcm_rdy) n_write_addr = next_write_addr;
    if (pcm_rdy) n_i = 8'd0;  else if (i< 8'd31) n_i = i + 8'd1;

    if (HREADY) begin   //data phase
        n_d0 = HRDATA;
        n_HWRITE = 1'b0;   //read
        n_HTRANS = 2'b10;  
        n_addr = write_addr; 
        n_state = WRITE_AHB;
        end
    end

CONFIG: begin
   if (HREADY) begin
       n_state = WRITE_AHB;
       n_HWRITE = 1'b0;
       n_addr = write_addr;
       n_pipeline_cmd = 1'b0;
       end
   end

L5: begin end
L6: begin end
L7: begin end

    endcase
    end
endmodule


