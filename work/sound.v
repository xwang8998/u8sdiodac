//
// the plan is
// SDIO front + DR-RAM I2S engine +DSD138(in master mode)
//
//


// PCM32+DSD driver
// inclock: 45M/49M pair or 90M/98M pair for portable players
// the control bits needed here
// max clock needed:
// for PCM32/384K: bit clock = 24.576MHz, can be DFF buffered at 49.152MHz
// for PCM32/768K: bit clock = 49.152MHz, can be DFF buffered at 98.304MHz
// for PCM32/1536K: bit clock = 98.304MGz, can be DFF buffered at 196.608MHz
// for DSD512: bit clock = 24.576MHz, can be DFF buffered at 49.152MHz
//     DSD512x2 channel needs 49.152M bps, data is feed on 2xDSD clock
// for DSD1024:bit clock = 49.152MHz, can be DFF buffered at 98.304MHz
// so for a 49.152MHz sdio sound card, we can do
// PCM32-384 and DSD512x2channel
// for a 98.304MHz sdio, we can do PCM32-768/dsd1024x2channel
//

`define NO_DSD138_OUT  


`define START_FLAG  8'b10000000
`define PCM_DSD_FLAG 8'b0100000
`define BCLK_DIVIDER_MASK 8'b00000111
`define BCLK_DIV_32  3'b000
`define BCLK_DIV_16  3'b001
`define BCLK_DIV_8  3'b010
`define BCLK_DIV_4  3'b011
`define BCLK_DIV_2  3'b100
`define BCLK_DIV_1  3'b101


// clock divider
module clock_divider(
input  in_clk,
input  preset_n,
input  [2:0] bck_div,
output reg bcko,
output reg bckox2,
output reg bckox4
);


// generate divided bck
reg clk1;
reg clk2, clk4, clk8, clk16, clk32;
reg iclk, iclk2, iclk4,iclk8, iclk16;

always @* clk1 = in_clk;

always @* iclk = in_clk;
always @(posedge iclk or negedge preset_n) if (preset_n == 0) clk2 <= 0; else clk2 <= ~clk2;

always @* iclk2 = clk2;
always @(posedge iclk2 or negedge preset_n) if (preset_n == 0) clk4 <= 0; else clk4 <= ~clk4;

always @* iclk4 = clk4;
always @(posedge iclk4 or negedge preset_n) if (preset_n == 0) clk8 <= 0; else clk8 <= ~clk8;

always @* iclk8 = clk8;
always @(posedge iclk8 or negedge preset_n) if (preset_n == 0) clk16 <= 0; else clk16 <= ~clk16;

always @* iclk16 = clk16;
always @(posedge iclk16 or negedge preset_n) if (preset_n == 0) clk32 <= 0; else clk32 <= ~clk32;

always @* begin
    bcko = 1'b0;
    bckox2 = 1'b0;
    bckox4 = 1'b0;
    if (bck_div == `BCLK_DIV_1) bcko = clk1;
    else if (bck_div == `BCLK_DIV_2) begin
        bcko = clk2;
        bckox2 = clk1;
        end 
    else if (bck_div == `BCLK_DIV_4) begin
        bcko = clk4;
        bckox2 = clk2;
        bckox4 = clk1;
        end
    else if (bck_div == `BCLK_DIV_8) begin
        bcko = clk8;
        bckox2 = clk4;
        bckox4 = clk2;
        end
    else if (bck_div == `BCLK_DIV_16) begin
        bcko = clk16;
        bckox2 = clk8;
        bckox4 = clk4;
        end
    else begin
        bcko = clk32;
        bckox2 = clk16;
        bckox4 = clk8;
        end
    end

endmodule



module outctrl(
input use_dsd,
input clk,
input preset_n,
input [31:0] pcm_l1,
input [31:0] pcm_r1,
input [31:0] pcm_l2,
input [31:0] pcm_r2,

input start,
input stop,
output reg bcko_dsdk,
output reg olrck_dsd1,
output reg odata_dsd2,
input [1:0] index,
input in_bck_pcm,
input in_bck_dsd,
input in_lrck,
input in_data
);

wire use_pcm32; assign use_pcm32 = 1;   //constant setting


// clock for DSD
//reg reset_n1;
//always @* begin
//    reset_n1 = 1;
//    if (use_dsd == 0) reset_n1 = 0;
//    if (preset_n == 0) reset_n1 = 0;
//    end

reg reset_n;
always @* if (stop == 1) reset_n = 0; else reset_n = preset_n;


//use this to lock into a fixed state until stop
reg dsd_mode;
always @(posedge in_bck_pcm or negedge reset_n)
    if (1'b0 == reset_n) dsd_mode <= 0;
    else 
       if (start && use_dsd) dsd_mode <= 1;
       else dsd_mode <= dsd_mode;


reg in_bck_div2;
//reg in_bck_div4;

always @(posedge in_bck_dsd or negedge reset_n)
    if (reset_n == 0) in_bck_div2 <= 0;
    else in_bck_div2 <= ~in_bck_div2;

//always @(posedge in_bck_div2 or negedge reset_n)
//    if (reset_n == 0) in_bck_div4 <= 0;
//    else in_bck_div4 <= ~in_bck_div4;

reg clk_src; always @* clk_src = clk;


reg bck_dsd1;
reg start_dsd1;


always @* begin
   //bck_dsd1 = 0;

   //if (use_pcm32)  bck_dsd1 = in_bck_div2;
   //else bck_dsd1 = in_bck_div4;
   bck_dsd1 = in_bck_div2;
   start_dsd1 = dsd_mode;

   //start_dsd1 = 0;
   //if (use_dsd == 1) begin
   //    start_dsd1 = start;
   //    end
   end


wire dsd_oclk1, dsd_l1, dsd_r1;
dsdout U300(
.use_dsd(dsd_mode),
.use_pcm32(use_pcm32),
.pcm_l1(pcm_l1), .pcm_r1(pcm_r1),
.pcm_l2(pcm_l2), .pcm_r2(pcm_r2),
.dsd_clk(bck_dsd1), .preset_n(preset_n),
.start(start_dsd1), .stop(stop),
.dsd_clk_out(dsd_oclk1), .dsd_l(dsd_l1), .dsd_r(dsd_r1), .index(index));


//it appears that the data was 1 clock earlier, we delay it by 1
reg in_data_delay;
always @(posedge in_bck_pcm or negedge reset_n)
    if (1'b0 == reset_n) in_data_delay <= 0;
    else in_data_delay <= in_data;


always @* begin
    bcko_dsdk =0;
    olrck_dsd1 = 0;
    odata_dsd2 = 0;
    if (dsd_mode == 1)
        begin bcko_dsdk = dsd_oclk1 & start ; olrck_dsd1 = dsd_l1; odata_dsd2 = dsd_r1; end
    else //PCM pass through
        //begin bcko_dsdk = (~in_bck_pcm) & start; olrck_dsd1 = in_lrck; odata_dsd2 = in_data; end
        begin bcko_dsdk = (~in_bck_pcm) & start; olrck_dsd1 = in_lrck; odata_dsd2 = in_data_delay; end
    end

endmodule

///DSDOPCM/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module dsdout(
input use_dsd,
input use_pcm32,
input [31:0] pcm_l1,
input [31:0] pcm_r1,
input [31:0] pcm_l2,
input [31:0] pcm_r2,
input dsd_clk,
input preset_n,
input start,
input stop,
output reg dsd_clk_out,
output reg dsd_l,
output reg dsd_r,
input [1:0] index
);

always @* dsd_clk_out = dsd_clk;

reg dsd_clk_n;
always @* dsd_clk_n = ~dsd_clk;

reg reset_n;
always @* if (stop == 1) reset_n = 0; else reset_n = preset_n;

reg new_sample;
reg [1:0] old_index;
always @(posedge dsd_clk_n or negedge reset_n)
    if (0 == reset_n)
          old_index <= 0;
    else
          old_index <= index;

always @* if (old_index[0] == index[0]) new_sample = 0; else new_sample = 1;


reg state, n_state;
reg n_dsd_l, n_dsd_r;

reg [6:0] i, n_i;
reg [4:0] j;
reg [1:0] k;
reg bit_il, bit_ir;

always @* begin
    k = i[6:5];
    if (use_pcm32 == 1) begin
       j = 5'd31 - i[4:0];
       end
    else begin
       j = 5'd31 - {1'b0,i[3:0]};
       end

    if (k[0] == 0) begin  bit_il = pcm_l1[j[4:0]]; bit_ir = pcm_r1[j[4:0]]; end
    else begin  bit_il = pcm_l2[j[4:0]]; bit_ir = pcm_r2[j[4:0]]; end


    end

always @(posedge dsd_clk_n or negedge reset_n)
   if (reset_n == 0) begin
       i <= 0;
       state <= 0;
       dsd_l <= 0; dsd_r <= 0;
       end
   else begin
       i <= n_i;
       state <= n_state;
       dsd_l <= n_dsd_l; dsd_r <= n_dsd_r;
       end

parameter DSD_IDLE = 0;
parameter DSD_LOOP = 1;

always @* begin
   n_i = i;
   n_state = state;
   n_dsd_l = dsd_l; n_dsd_r = dsd_r;
   case(state)
       DSD_IDLE: begin
          n_i = 0;
          n_dsd_l = 0;
          n_dsd_r = 0;
          if  (start==1 && use_dsd == 1) n_state = DSD_LOOP;
          end
       DSD_LOOP: begin
          if (new_sample) begin
              n_i[4:0] = 0;
              n_i[6:5] = old_index;
              end
          else
              n_i[4:0] = i[4:0] + 5'd1;

          n_dsd_l = bit_il;
          n_dsd_r = bit_ir;
          n_state = DSD_LOOP;

          //if (use_dsd == 0)  n_state = DSD_IDLE;
          end
       default: begin n_state = DSD_IDLE; end
   endcase
   end

endmodule



////////////////////PCM input I2S module////////////////////////////////////////
module pcmin(
output [1:0] dbg,
input bck,
input lrck,
input sdata,
output lrck1,
output data1,
input preset_n,
input start,
input stop,
input use_pcm32,
input use_dsd,
output reg started,

output reg [31:0] pcm_l1,
output reg [31:0] pcm_r1,
output reg [31:0] pcm_l2,
output reg [31:0] pcm_r2,

output reg [1:0] k
);

reg [4:0] j;


reg reset_n;
always @* if (stop == 1) reset_n = 0; else reset_n = preset_n;


reg olrck1, olrck0;
reg d0,dx;

always @(posedge bck or negedge reset_n)
   if (reset_n == 0) begin
       olrck0 <= 1;
       olrck1 <= 1;
       dx <= 0; 
       end
   else begin
       olrck0 <= lrck;
       olrck1 <= olrck0;
       dx <= sdata;
//       d1 <= dx;
       end

// qcom 810 slave mode, lrck is 1 cycle earlier than data, so we correct
// this by putting lrck1 one cycle behind, so PCM pass thru will work
// assign lrck1 = olrck0;
// assign data1 = d0;
assign lrck1 = olrck1;
assign data1 = dx;

// qcom 810 slave mode, we choose to let d0 == sdata so d0 is 1cycle ahead of lrck
always @* d0 = dx;
//always @* d0 = sdata;

reg n_started;
reg [31:0] n_pcm_l1, n_pcm_r1, n_pcm_l2, n_pcm_r2;
reg [31:0] pcmf, n_pcmf;

reg [4:0] i, n_i;
reg [1:0] index, n_index;

always @* j = 5'd31 - {k[0], i[4:1]};

reg [1:0] state, n_state;

reg new_sample;
always @* if (olrck0 == olrck1) new_sample = 0; else new_sample = 1;


always @(posedge bck or negedge reset_n)
     if (0==reset_n) pcm_l1 <= 32'h00005555; else pcm_l1 <= n_pcm_l1;
always @(posedge bck or negedge reset_n)
     if (0==reset_n) pcm_l2 <= 32'h00005555; else pcm_l2 <= n_pcm_l2;

always @(posedge bck or negedge reset_n)
     if (0==reset_n) pcm_r1 <= 32'h00005555; else pcm_r1 <= n_pcm_r1;
always @(posedge bck or negedge reset_n)
     if (0==reset_n) pcm_r2 <= 32'h00005555; else pcm_r2 <= n_pcm_r2;

always @(posedge bck or negedge reset_n)
     if (reset_n == 0) begin
         pcmf <= 0;
         started <= 0;
         i<= 0; state <= 0;
         index <= 0;
         end
     else begin
         i <= n_i; state <= n_state;
         pcmf <= n_pcmf;
         started <= n_started;
         index <= n_index;
         end

always @* k = index;

parameter IDLE =  2'b00;
parameter START = 2'b01;
parameter WORK =  2'b10;

always @* begin
   n_i = i;
   n_index = index;
   n_state = state;
   n_pcmf = pcmf;
   n_started = started;
   n_pcm_l1 = pcm_l1; n_pcm_r1 = pcm_r1;
   n_pcm_l2 = pcm_l2; n_pcm_r2 = pcm_r2;
   case (state)
        IDLE: begin
           n_index = 0;
           n_i = 0;
           n_pcmf = 0;
           n_started = 0;
           if (start == 1) n_state = START;
           else n_state = IDLE;
           end

        START: begin
           //  left_channel 
           n_state = START;
           if (olrck1==1 && olrck0 == 0) begin   // I2S
              n_started = 1;
              n_i = 0;
              n_index = 0;
              n_state = WORK;
              end
           end

        WORK: begin
           n_state = WORK;
           n_pcmf[31 - i[4:0]] = d0;

           if (olrck1 == 1 && olrck0 == 0) begin //left begin, next clk would be msb of left
               n_i[4:0] = 0;
               n_index = index + 2'd1;


               if (k[0] == 0) begin n_pcm_r1[31:1] = pcmf[31:1]; end
               else begin n_pcm_r2[31:1] = pcmf[31:1]; end
               if (k[0] == 0) begin n_pcm_r1[0] = d0; end
               else begin n_pcm_r2[0] = d0; end


               end
           else if (olrck1 == 0 && olrck0 == 1) begin
               n_i[4:0] = 0;


               if (k[0] == 0) begin n_pcm_l1[31:1] = pcmf[31:1]; end
               else begin n_pcm_l2[31:1] = pcmf[31:1]; end
               if (k[0] == 0) begin n_pcm_l1[0] = d0; end
               else begin n_pcm_l2[0] = d0; end

               end
           else
               n_i[4:0] = i[4:0] + 5'd1;
           end

        default: begin n_state = IDLE; end

   endcase
   end

assign dbg[0] = reset_n;
assign dbg[1] = started;

endmodule



module inctrl(
output [1:0] dbg,
input use_dsd,
input [7:0] ictrl,     //coming from i2c
input clk,
input preset_n,
input in_lrck,
input in_bck,
input in_data,
output lrck1,
output data1,
output reg bck_pcm,
output reg bck_dsd,
input  master_mode,
output reg master_bck,
output reg master_lrck,
output reg master_en,
output dop_clock  /* synthesis syn_keep = 1 */,
output spdif_clock  /* synthesis syn_keep = 1 */,
output started,
output [31:0] pcm_l1,
output [31:0] pcm_r1,
output [31:0] pcm_l2,
output [31:0] pcm_r2,
output [1:0] k
);

wire use_pcm32; assign use_pcm32 = 1;
wire stop; assign stop = (ictrl[7]==1'b0);
wire [2:0] bck_divider; assign bck_divider = ictrl[2:0];

reg clk_src; always @* clk_src = clk;

reg reset_n;
always @* if (stop == 1) reset_n = 0; else reset_n = preset_n;

reg bck_pcm1, lrck_pcm1, start_pcm1, data_pcm1;

wire bcko;
// clock divider ,@@@@@ updated by Yi 4/29/2017
// need to modify this for S/PDIF tx
// in PCM mode, SPDIF_CLOCK = 2 x bcko
// in DSD mode, dsdclock = 0.5 * bcko, DoP clock = 2 x bcko, SPDIF_CLOCK = 4 x bcko
// 

wire bckox4, bckox2;
clock_divider UCK0( .in_clk(clk_src), .preset_n(reset_n), .bck_div(bck_divider), .bcko(bcko),
    .bckox2(bckox2), .bckox4(bckox4));

//assign dop_clock = use_dsd ? bckox2 : 1'b0;
//assign spdif_clock = use_dsd ? bckox4 : bckox2;

wire master_bck32;
CLKINT UCK10 (.A(bcko), .Y(master_bck32));   //only 10 fanouts
CLKINT UCK12 (.A(use_dsd ? bckox4 : bckox2), .Y(spdif_clock));   //70 fanouts
CLKINT UCK14 (.A(use_dsd ? bckox2 : 1'b0), .Y(dop_clock));  //102 fanouts

wire imaster_bck32 = ~master_bck32;

reg [5:0] cnt;
always@ *begin
    master_en = 0;
    master_lrck = 0;
    if (stop == 0) begin master_en = master_mode; master_lrck = ~cnt[5]; end
    end

reg internal_master_lrck;
always @* internal_master_lrck = master_lrck;

always @(posedge master_bck32 or negedge reset_n)
    if (reset_n == 0) begin
          cnt <= 0;
          //internal_master_lrck <= 0;
          end
    else  begin
          cnt <= cnt + 6'd1;
          //internal_master_lrck <= master_lrck;
          end

reg x,y;


// this code will generate 8 fat clocks at the end of lrck
// for 24bit 24s

always @* begin
   x = 0;
   if (cnt[4]==1 && cnt[0] == 0) x = 1;
   y = x | master_bck32;
end

//always @*
//    if (use_pcm32) master_bck = master_bck32;
//    else master_bck = y;
//
// use 32 bit clock in PCM24bit mode for Qualcomm CPUs

always @* master_bck = master_bck32;


always @*
    if (master_mode==1) begin
         bck_pcm1 =  ~master_bck;
         lrck_pcm1 = internal_master_lrck;
         data_pcm1 = in_data;
         bck_pcm = bck_pcm1;
         bck_dsd = ~master_bck32;
         start_pcm1 = ictrl[7];  end
    else begin
         bck_pcm1 = in_bck;
         bck_pcm = in_bck;
         bck_dsd = in_bck;
         lrck_pcm1 = in_lrck;
         data_pcm1 = in_data;
         start_pcm1 = ictrl[7];
    end

`ifdef NO_DSD138_OUT
assign dbg = 2'd0;
assign lrck1 = 1'd0;
assign data1 = 1'd0;
assign started = 1'd0;
assign pcm_l1 = 32'd0;
assign pcm_l2 = 32'd0;
assign pcm_r1 = 32'd0;
assign pcm_r2 = 32'd0;
assign k = 2'd0;
`else
pcmin U100(
.dbg(dbg),
.bck(bck_pcm1), .lrck(lrck_pcm1),
.sdata(data_pcm1),
.lrck1(lrck1) , .data1(data1),
.preset_n(preset_n),
.start(start_pcm1), .stop(stop), .use_pcm32(use_pcm32), .use_dsd(use_dsd),
.started(started),
.pcm_l1(pcm_l1), .pcm_r1(pcm_r1),
.pcm_l2(pcm_l2), .pcm_r2(pcm_r2),
.k(k));

`endif

endmodule

// will force to run under master mode!!!
module pcm2dsd(
input in_mclk,
input preset_n,

input [7:0] ctrl,

//debug
output debugs,
output debugt,

//input i2s
input sdata,
input in_lrck,
input in_bck,
output master_lrck,
output master_bck,
output master_en,            //  for bi-directional
output dop_clock,            //  sould be 2x bck, for example, playing dsd128 should use dsd256 bck
output spdif_clock,

//output i2s
output bck_dsd_clk,           // PCM BitClock or DSD Clock
output olrck_dsd1,            // PCM L/R clock or DSD channel 1
output odata_dsd2             // PCM data or DSD channel 2
);

wire master_mode; assign  master_mode = 1;   //constant setting

wire started;
wire [31:0] pcm_l1, pcm_r1, pcm_l2, pcm_r2;
wire [1:0] k;

wire lrck1, data1;
wire in_bck_pcm, in_bck_dsd;
wire use_dsd;
assign use_dsd = ctrl[6];

wire [1:0] dbg;

assign debugs = dbg[0];
assign debugt = dbg[1];

inctrl UIN100(
.dbg(dbg),
.use_dsd(use_dsd),
.ictrl(ctrl), .clk(in_mclk), .preset_n(preset_n),
.in_lrck(in_lrck), .in_bck(in_bck), .in_data(sdata),
.lrck1(lrck1), .data1(data1),
.bck_pcm(in_bck_pcm), .bck_dsd(in_bck_dsd),
.master_mode(master_mode),
.master_bck(master_bck), .master_lrck(master_lrck), .master_en(master_en),
.dop_clock(dop_clock),
.spdif_clock(spdif_clock),
.started(started),
.pcm_l1(pcm_l1), .pcm_r1(pcm_r1),
.pcm_l2(pcm_l2), .pcm_r2(pcm_r2),
.k(k));

wire stop; assign stop = (ctrl[7] == 1'b0);

`ifdef NO_DSD138_OUT
assign bck_dsd_clk = 1'b0;
assign olrck_dsd1 =  1'b0;
assign odata_dsd2 =  1'b0;
`else

outctrl UOUT200(
.use_dsd(use_dsd),
.clk(in_mclk), .preset_n(preset_n),
.pcm_l1(pcm_l1), .pcm_r1(pcm_r1),
.pcm_l2(pcm_l2), .pcm_r2(pcm_r2),
.start(started), .stop(stop),
.bcko_dsdk(bck_dsd_clk), .olrck_dsd1(olrck_dsd1), .odata_dsd2(odata_dsd2),
.index(k),
.in_bck_pcm(in_bck_pcm),   //drive clk in pcm mode
.in_bck_dsd(in_bck_dsd),   //drive clk in dsd mode
.in_lrck(lrck1),
.in_data(data1)
);

`endif

endmodule


// pack 32bit DSD stream into 16bit DoP stream
// so DoP clock has to be 2x DSD32 clock
// for 49.152MHz MCLK, the max DSD32 rate is DSD512, so the max DoP rate is DSD 256
// for S/PDIF output, the max DoP rate is DSD128

module dop_gear(
input dop_clock /* synthesis syn_keep = 1 */,   //DoP bit clock , must be 2x of DSD clock
input rst_n,
input start,
input [31:0] source_left, 
input [31:0] source_right,
output reg [15:0]dop_left,
output reg [15:0]dop_right
);

reg state, n_state;
parameter IDLE = 1'b0;
parameter WORK = 1'b1;

reg [15:0] n_dop_left, n_dop_right;
reg [31:0] tmp_left, n_tmp_left, tmp_right, n_tmp_right;
reg [3:0] i, n_i;
reg flag, n_flag;

wire reset_n = start ? rst_n: 1'b0;

always @(posedge dop_clock or negedge reset_n)
    if (1'b0 == reset_n) begin
        state <= 0;
        dop_left <= 0; dop_right <= 0;
        tmp_left <= 0; tmp_right <= 0;
        i <= 0; flag <= 0;
        end
    else begin
        state <= n_state;
        dop_left <= n_dop_left; dop_right <= n_dop_right;
        tmp_left <= n_tmp_left; tmp_right <= n_tmp_right;
        i <= n_i; flag <= n_flag;
        end

always @* begin
    n_state = state;
    n_dop_left = dop_left; n_dop_right = dop_right;
    n_tmp_left = tmp_left; n_tmp_right = tmp_right;
    n_i = i; n_flag = flag;

    case(state) 
IDLE: begin
        n_dop_left = 16'h5555;
        n_dop_right = 16'h5555;
        n_i = 0; 
        n_flag = 0;
        if (start) n_state = WORK;
        end
WORK: begin
        n_i = i + 4'd1;
        if (i == 4'd7) begin
            n_flag = ~flag;
            if (flag) n_dop_left = tmp_left[15:0]; else n_dop_left = tmp_left[31:16];
            if (flag) n_dop_right = tmp_right[15:0]; else n_dop_right = tmp_right[31:16];
            if (flag) n_tmp_left = source_left;
            if (flag) n_tmp_right = source_right;
            end
        end
    endcase
    end
endmodule


// spdif tx, send SPDIF with PCM or DoP
module spdif_tx(
input spdif_clock /* synthesis syn_keep = 1 */,
input rst_n,
input start,
input use_dsd,
input [31:0] source_left,
input [31:0] source_right,
input [15:0] dop_left,
input [15:0] dop_right,
output spdif_out);

parameter PREAMBLE_X = 8'b10010011; // preamble x, for left channel
parameter PREAMBLE_Y = 8'b10010110; // preamble y, for right channel
parameter PREAMBLE_Z = 8'b10011100; // preamble z, audio block start
parameter VDD = 1'b1;

wire reset_n = start ? rst_n : 1'b0;


reg [23:0] channel_status_shift;
parameter channel_status = 24'b001000000000000001000000;

reg xsel_lr;
reg parity;
reg [23:0] din;
reg [8:0] frame_counter;
reg [5:0] bit_counter;
reg [7:0] dop_fill;

always @(posedge spdif_clock or negedge reset_n)
    if (reset_n == 1'b0) begin
        xsel_lr <= 0;
        parity <= 0;
        din <= 0;
        frame_counter <= 0;
        bit_counter <= 0;
        dop_fill <= 0;
        end
    else begin
        bit_counter <= bit_counter + 6'd1;
        parity <= din[23]^din[22]^din[21]^din[20]^din[19]^din[18]^din[17]^din[16]^din[15]^din[14]^din[13]
                 ^din[12]^din[11]^din[10]^din[9]^din[8]^din[7]^din[6]^din[5]^din[4]^din[3]^din[2]^din[1]
                 ^din[0] ^ channel_status_shift[23]; 

        if (bit_counter == 6'b000001) 
            if (xsel_lr==0) 
                if (dop_fill == 8'hFA) dop_fill <= 8'h05; else dop_fill <= 8'hFA;

        if (bit_counter == 6'b000010) xsel_lr <= ~ xsel_lr;
        if (bit_counter == 6'b000010) 
            if (xsel_lr)
                if (use_dsd) din <= {dop_fill, dop_right};
                else din <= source_right[31:8];
            else
                if (use_dsd) din <= {dop_fill, dop_left};
                else din <= source_left[31:8];
        if (bit_counter == 6'b111111)
            if (frame_counter == 9'h17F) frame_counter <= 9'd0;
            else frame_counter <= frame_counter + 9'd1;
        end


reg [7:0] data_out_buffer;
reg address_out;
always @(posedge spdif_clock or negedge reset_n)
    if (1'b0 == reset_n) begin
        data_out_buffer <= 0;
        address_out <= 0;
        channel_status_shift <= 0;
        end
    else begin
        if (bit_counter == 6'h3f) begin
            if (frame_counter == 9'h17F) begin //next frame is 0, load preamble Z
                address_out <= 0;
                channel_status_shift <= channel_status;
                data_out_buffer <= PREAMBLE_Z;
                end
            else begin
                if (1'b1 == frame_counter[0]) begin //next frame is even, load preamble X, left channel
                    channel_status_shift <= {channel_status_shift[22:0], 1'b0};
                    data_out_buffer <= PREAMBLE_X;
                    address_out <= 0;
                    end
                else begin //next frame is odd, load preable Y, right channel
                    data_out_buffer <= PREAMBLE_Y;
                    end
                end
            end
        else begin
            if (bit_counter[2:0] == 3'b111)  // load new part of data into buffer
                case (bit_counter[5:3])
                    3'b000: data_out_buffer <= {VDD, din[0], VDD, din[1], VDD, din[2], VDD, din[3]};
                    3'b001: data_out_buffer <= {VDD, din[4], VDD, din[5], VDD, din[6], VDD, din[7]};
                    3'b010: data_out_buffer <= {VDD, din[8], VDD, din[9], VDD, din[10], VDD, din[11]};
                    3'b011: data_out_buffer <= {VDD, din[12], VDD, din[13], VDD, din[14], VDD, din[15]};
                    3'b100: data_out_buffer <= {VDD, din[16], VDD, din[17], VDD, din[18], VDD, din[19]};
                    3'b101: data_out_buffer <= {VDD, din[20], VDD, din[21], VDD, din[22], VDD, din[23]};
                    3'b110: data_out_buffer <= {5'b10101, channel_status_shift[23], VDD, parity};
                endcase
            else
                data_out_buffer <= {data_out_buffer[6:0], 1'b0};
            end       
       end

reg data_biphase;
always @(posedge spdif_clock or negedge reset_n)
    if (1'b0 == reset_n)
        data_biphase <= 0;
    else
        if (data_out_buffer[7]) data_biphase <= ~ data_biphase;
        else data_biphase <= data_biphase;

assign spdif_out = data_biphase;

endmodule



/////////////////////////// ADC PCM gears //////////////////////////////
module adc_pcm_gear(
input bck,
input reset_n,
input lrck,
input data,
input [7:0] ctrl,
output is_right,
output pcm_ready,
output [31:0] pcm32,
output [7:0] debug
);

wire start = ctrl[7];
wire use_dsd = ctrl[6];

wire [31:0] source_left, source_right;

wire [31:0] dsd32_l, dsd32_r;
dsd_input_gear UDSD(.dsd_clk(bck), .rst_n(reset_n & use_dsd),
    .start(start), .dsd_l(lrck), .dsd_r(data), .dsd32_l(dsd32_l), .dsd32_r(dsd32_r));

wire [31:0] pcm_left, pcm_right;
wire [7:0]  dbg;
//i2s32_input_gear UI2S(.bck(bck), .rst_n(reset_n & (!use_dsd)), 
i2s32_input_gear UI2S(.bck(bck), .rst_n(reset_n), .debug(dbg),
    .start(start), .lrck(lrck), .data(data), .pcm_left(pcm_left), .pcm_right(pcm_right));

//assign debug[0] = data;
//assign debug[7] = start;
//assign debug[6] = use_dsd;
assign debug = dbg;

assign source_left = use_dsd ? dsd32_l : pcm_left;
assign source_right = use_dsd ? dsd32_r : pcm_right;

reg state, n_state;
reg [4:0] i, n_i;
reg [31:0] din, n_din;
reg flag, n_flag;
reg ready, n_ready;

assign is_right = flag;


assign pcm_ready = ready;
assign pcm32 = din;

always @(posedge bck or negedge reset_n) 
    if (1'b0 == reset_n) begin
        state <= 0;
        i <= 0;
        din <= 0;
        flag <= 0;
        ready <= 0;
        end 
    else begin
        state <= n_state;
        i <= n_i;
        din <= n_din;
        flag <= n_flag;
        ready <= n_ready;
        end

parameter IDLE = 1'b0;
parameter WORK = 1'b1;

always @* begin
    n_state = state;
    n_i = i;
    n_din = din;
    n_flag = flag;
    n_ready = ready;
    case(state)

IDLE: begin
    n_ready = 1'b0;
    n_i = i + 5'd1;
    if (start && i == 5'd20) begin
        n_state = WORK;
        n_din = source_left;
        n_i = 0;
        n_flag = 0;
        end
    end

WORK: begin
    n_ready = 1'b0;
    n_i = i + 5'd1;
    if (i == 5'd31) n_ready = 1'b1;
    if (i == 5'd31) begin
        if (flag) n_din = source_left; else n_din = source_right;
        n_flag = ~flag;
        end
    end
    endcase
    end
endmodule

// input dsd source
// since DSD has 2 datalines for 2channles, unlike i2s, so
// in order to capture DSD with the dsd bit clock, we can only do one channels here
// here we only do dsd_r (data)
// in the next design, we could use mclk(high freq) to sample this dsd_clk
// so we could do 2 channels
module dsd_input_gear(
input dsd_clk /* synthesis syn_keep = 1 */,    //dsd bit clock
input rst_n,
input start,
input dsd_l,
input dsd_r,
output reg [31:0] dsd32_l,
output reg [31:0] dsd32_r);

wire reset_n = start ? rst_n : 1'b0;

reg [4:0] i, n_i;
reg flag, n_flag;
reg [31:0] tmp, n_tmp, left, n_left, n_dsd32_l, n_dsd32_r;

always @(posedge dsd_clk or negedge reset_n)
    if (1'b0 == reset_n) begin
        dsd32_l <= 0;
        dsd32_r <= 0;
        left <= 0;
        tmp <= 0;
        i <= 0;
        flag <= 0;
        end

    else begin
        dsd32_l <= n_dsd32_l;
        dsd32_r <= n_dsd32_r;
        left <= n_left;
        tmp <= n_tmp;
        i <= n_i;
        flag <= n_flag;
        end

always @* begin
    n_dsd32_l = dsd32_l;
    n_dsd32_r = dsd32_r;
    n_left = left;
    n_flag = flag;
   
    n_i = i + 5'd1;
    n_tmp = {tmp[30:0], dsd_r};
    if (i == 5'd31) begin
        n_flag = ~flag;
        if (flag) begin
            n_dsd32_l = left;
            n_dsd32_r = tmp;
            end
        else
            n_left = tmp;
        end
    end
endmodule

//input i2s source, pcm32 , 64bit per frame
module i2s32_input_gear(
input bck,
input lrck,
input data,
input rst_n,
input start,
output [7:0] debug,
output reg [31:0] pcm_left,
output reg [31:0] pcm_right);

wire reset_n = start ? rst_n : 1'b0;

reg olrck;
always @(posedge bck or negedge reset_n) 
    if (1'b0 == reset_n) olrck <= 0;
    else olrck <= lrck;

wire left_trigger = (olrck == 1'b1 && lrck == 1'b0);
wire right_trigger =  (olrck == 1'b0 && lrck == 1'b1);
reg [4:0] i, n_i;
reg state, n_state;
reg flag, n_flag;
reg [31:0] tmp, n_tmp, left, n_left, n_pcm_left, n_pcm_right;
reg [31:0] x, n_x;

parameter IDLE = 1'b0;
parameter WORK = 1'b1;

assign debug = {bck, lrck, data, start, reset_n, 3'd0};

always @(posedge bck or negedge reset_n)
    if (1'b0 == reset_n) begin
        state <= 0;
        pcm_left <= 0;
        pcm_right <= 0;
        left <= 0;
        tmp <= 0;
        i <= 0;
        flag <= 0;
        x <= 0;
        end
    else begin
        state <= n_state;
        pcm_left <= n_pcm_left;
        pcm_right <= n_pcm_right;
        left <= n_left;
        tmp <= n_tmp;
        i <= n_i;
        flag <= n_flag;
        x <= n_x;
        end

always @* begin
    n_state = state;
    n_pcm_left = pcm_left;
    n_pcm_right = pcm_right;
    n_left = left;
    n_tmp = tmp;
    n_i = i;
    n_flag = flag;
    n_x = x;
    case (state)

IDLE: begin
    n_tmp = 32'h0;
    n_left = 32'h0;
    n_i = 5'h0;
    n_pcm_left = 32'h0;
    n_pcm_right = 32'h0;
    n_flag = 1'b0;
    if (left_trigger) begin
        n_state = WORK;
        end
    end

WORK: begin
    n_i = i + 5'd1;
    n_tmp = {tmp[30:0], data};
    if (i == 5'd31) begin
        n_x = x + 1;
        n_flag = ~flag;
        if (flag) begin
            n_pcm_left = left;
            n_pcm_right = tmp;
            /////DEBUG
            //n_pcm_left = left;
            //n_pcm_right = x;
            end 
        else 
            n_left = tmp;
            //n_left = x;    ///DEBUG
        end
    end

    endcase
    end

endmodule


//////////////////////////////////////////////
module pcm_tx(
input in_bck /* synthesis syn_keep = 1 */,
input rst_n,
input start,
input [31:0] source_left,
input [31:0] source_right,
output obck,
output olrck,
output odata);

wire reset_n = start ? rst_n : 1'b0;

reg [63:0] t1;
reg [63:0] word;
reg [5:0] i;

always @(posedge in_bck or negedge reset_n)
    if (1'b0 == reset_n) begin
        t1 <= 32'h0;
        i <= 0;
        end
    else begin
        i <= i + 6'd1;
        if (i == 6'd63) 
            t1 <= {source_left, source_right};
        else 
            t1 <= {t1[62:0], 1'b0};
        end

reg d1;
always @(posedge in_bck) d1 <= t1[63];

assign odata = d1;
assign olrck =  i[5];
assign obck = ~in_bck;

endmodule



module dsd_tx(
input dsd_clk /* synthesis syn_keep = 1 */,
input rst_n,
input start,
input [31:0] source_left,
input [31:0] source_right,
output odsd_clk,
output dsd_l,
output dsd_r);

wire reset_n = start ? rst_n : 1'b0;
reg [31:0] t1, t2;
reg [4:0] i;
always @(posedge dsd_clk or negedge reset_n) 
    if (1'b0 == reset_n) begin
        t1 <= 32'haaaaaaaa;
        t2 <= 32'haaaaaaaa;
        i <= 0;
        end
    else begin
        i <= i + 5'd1;
        if (i == 5'd31) t1 <= source_left; else t1 <= {t1[30:0], 1'd0};
        if (i == 5'd31) t2 <= source_right; else t2 <= {t2[30:0], 1'd0};
        end

assign dsd_l = t1[31];
assign dsd_r = t2[31];
assign odsd_clk = ~dsd_clk;

endmodule










