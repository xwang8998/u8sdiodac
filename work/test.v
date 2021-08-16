
// test verilog for machxo3 starter kit

`define NO_SELF_TEST 1

module test(
  input reset_n,

//to led
output wire led0, led1, led2, led3, led4, led5, led6, led7,

// to eSRAM controller
output FPGA_CLK,

// AHB Side Interfacing with FIC 
output           [31:0] HADDR,
output           [1:0]  HTRANS,
output                  HWRITE,
output     wire  [2:0]  HSIZE,
output     wire  [2:0]  HBURST,
output     wire  [3:0]  HPROT,
output     wire  [31:0] HWDATA,
output     wire         HMASTLOCK,

input      wire  [31:0] HRDATA,
input      wire         HREADY,
input      wire  [1:0]  HRESP, //don't check this part
input      pll_lock,
//input      wire         INIT_DONE,

  //sdio interface
  input  sdclk,
  inout  cmd,
  inout  sd_d0,
  inout  sd_d1,
  inout  sd_d2,
  inout  sd_d3,

  //I2S interface
  input  mclk,
  inout  obck,
  inout  olrck,
  inout  odata,

  // u8 2100 special
  output spdif_en,
  output spdif_tx,

  output en45,
  output en49,

  //1b DAC
  output dsd_lp0,
  output dsd_lp1,
  output dsd_lp2,
  output dsd_lp3,
  output dsd_lp4,
  output dsd_lp5,
  output dsd_lp6,
  output dsd_lp7,

  output dsd_ln0,
  output dsd_ln1,
  output dsd_ln2,
  output dsd_ln3,
  output dsd_ln4,
  output dsd_ln5,
  output dsd_ln6,
  output dsd_ln7,

  output dsd_rp0,
  output dsd_rp1,
  output dsd_rp2,
  output dsd_rp3,
  output dsd_rp4,
  output dsd_rp5,
  output dsd_rp6,
  output dsd_rp7,

  output dsd_rn0,
  output dsd_rn1,
  output dsd_rn2,
  output dsd_rn3,
  output dsd_rn4,
  output dsd_rn5,
  output dsd_rn6,
  output dsd_rn7,

//  input  dacmclk,   //unused!
  input  clock138_bck,
  input  clock138_lrck,
  output clock138_data
);

wire [7:0] led;
assign {led7, led6, led3, led2, led5, led0, led1, led4} = led;
wire i2s_bck, i2s_lrck, i2s_data;
//assign led0 = i2s_bck;
//assign led1 = i2s_lrck;
//assign led2 = i2s_data;

//wire [7:0] dsd_lp, dsd_rp;
//assign {dsd_lp0, dsd_lp1, dsd_lp2, dsd_lp3, dsd_lp4, dsd_lp5, dsd_lp6, dsd_lp7} = dsd_lp;
//assign {dsd_rp0, dsd_rp1, dsd_rp2, dsd_rp3, dsd_rp4, dsd_rp5, dsd_rp6, dsd_rp7} = dsd_rp;

//wire [7:0] dsd_ln, dsd_rn;
//assign {dsd_ln0, dsd_ln1, dsd_ln2, dsd_ln3, dsd_ln4, dsd_ln5, dsd_ln6, dsd_ln7} = dsd_ln;
//assign {dsd_rn0, dsd_rn1, dsd_rn2, dsd_rn3, dsd_rn4, dsd_rn5, dsd_rn6, dsd_rn7} = dsd_rn;



//assign HADDR = 32'h20000000;
//assign HTRANS = 0;        // will use 00 (IDLE) or 10 (Single) here
//assign HWRITE = 0;        // 1==> WRITE 0==> READ
assign HSIZE =  3'b010;   // 32bit word transfer
assign HBURST = 3'b000;   // Single burst
assign HMASTLOCK = 1'b1;  // don't lock it
assign HPROT  = 4'b0011;  // priviliged data access
//assign HWDATA = 32'h12345678;

reg mclk_d2;
always @(posedge mclk or negedge reset_n)
    if (0 == reset_n) mclk_d2 <= 0;
    else  mclk_d2 <= ~mclk_d2;

wire mclk4549;


//mem_controller uctrl(.sdclk(clk), .mclk(mclk), .reset_n(rst_n),
wire ns;
assign ns = ~sdclk;
wire sdclk_n;
CLKINT_PRESERVE UCK3 (.A(ns), .Y(sdclk_n));
CLKINT UCK4 (.A(sdclk), .Y(sdclk_p));


///DEBUG interface, using total phase aardvark i2s tool, read debug64 to PC so we can debug
///use scl/sda

//wire sda_in, sda_out, sda_out_enable;
//BB u800(
//.I(sda_out),
//.T(~sda_out_enable),
//.O(sda_in),
//.B(sda));
//wire [63:0]debug64;
////assign debug64 = {8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88};
//debug_core U810(.pclk(mclk), .preset_n(reset_n),
//    .debug(debug64),
//    .i2c_slave_addr(7'h0d),
//    .scl(scl),
//   .sda(sda_in),
//    .sda_out(sda_out),
//    .sda_out_en(sda_out_enable));

// LED debug interface, more easy to see!
wire [63:0] debug64;
wire [7:0] debug;
//assign {led0, led1, led2, led3, led4, led5, led6, led7} = debug;


//SDIO interface, in: sdio pins, out: i2s pins
wire cmd_out, cmd_out_en;
wire cmd_in;
wire sd_data_out_en;
wire [3:0] sd_data_in, sd_data_out;

BIBUF UBB (.PAD(cmd), .D(cmd_out), .Y(cmd_in), .E(cmd_out_en));
BIBUF UDAT0 (.PAD(sd_d0), .D(sd_data_out[0]), .Y(sd_data_in[0]), .E(sd_data_out_en));
BIBUF UDAT1 (.PAD(sd_d1), .D(sd_data_out[1]), .Y(sd_data_in[1]), .E(sd_data_out_en));
BIBUF UDAT2 (.PAD(sd_d2), .D(sd_data_out[2]), .Y(sd_data_in[2]), .E(sd_data_out_en));
BIBUF UDAT3 (.PAD(sd_d3), .D(sd_data_out[3]), .Y(sd_data_in[3]), .E(sd_data_out_en));

wire dac_mode;
wire obck_o,  obck_i;
wire olrck_o, olrck_i;
wire odata_o, odata_i;

BIBUF UDAT20 (.PAD(obck), .D(obck_o), .Y(obck_i), .E(dac_mode));
BIBUF UDAT21 (.PAD(olrck), .D(olrck_o), .Y(olrck_i), .E(dac_mode));
BIBUF UDAT22 (.PAD(odata), .D(odata_o), .Y(odata_i), .E(dac_mode));

//BIBUF UDAT20 (.PAD(obck), .D(1'b0), .Y(obck_i), .E(dac_mode));
//BIBUF UDAT21 (.PAD(olrck), .D(1'b0), .Y(olrck_i), .E(dac_mode));
//BIBUF UDAT22 (.PAD(odata), .D(1'b0), .Y(odata_i), .E(dac_mode));

/// adc test, debug only!
//  wire bck_g, lrck_g, data_g;
//  dsd_gen UGEN(.mclk(mclk4549), .reset_n(reset_n), .bck(bck_g), .dsd1(lrck_g), .dsd2(data_g));

CLKINT_PRESERVE UCK1 (.A(mclk_d2), .Y(mclk4549));
assign FPGA_CLK = ~mclk_d2;
//CLKINT UCK2 (.A(~mclk_d2), .Y(FPGA_CLK));
//wire spdif_enx;

sdtop u100(.sdclk_p(sdclk_p), .sdclk_n(sdclk_n), .rst_n(reset_n), .cmd(cmd_in), .led(debug), .db64(debug64),
    .en45(en45), .en49(en49),
    .cmd_out(cmd_out), .cmd_out_en(cmd_out_en),
    .HREADY(HREADY), .HRDATA(HRDATA), .HADDR(HADDR), .HWDATA(HWDATA), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .sd_data_in(sd_data_in), .sd_data_out(sd_data_out), .sd_data_out_en(sd_data_out_en),
    .spdif_en(spdif_en), .spdif_tx(spdif_tx),
    .i2s_bck(i2s_bck), .i2s_lrck(i2s_lrck), .i2s_data(i2s_data),
    .mclk(mclk4549), .obck(obck_o), .olrck(olrck_o), .odata(odata_o), .dac_mode(dac_mode),
    .bck_i(obck_i), .lrck_i(olrck_i), .data_i(odata_i)
    //.bck_i(bck_g), .lrck_i(lrck_g), .data_i(data_g)       /////DEBUG
    );


wire dem_clk;
reg [63:0] dsdlq, dsdrq;
//CLKINT UCK300 (.A(~mclk), .Y(dem_clk));
//CLKINT UCK300 (.A(mclk4549), .Y(dem_clk));
CLKINT UCK300 (.A(obck_o), .Y(dem_clk));

// pos and neg shift to different direction, better matching?
always @(posedge dem_clk or negedge reset_n) 
    if (1'b0 == reset_n) begin
	dsdlq <= 63'd0;
	dsdrq <= 63'd0;
        end
    else begin
	dsdlq <= {dsdlq[62:0], olrck_o};
        dsdrq <= {dsdrq[62:0], odata_o};
        end

reg [7:0] dsd_rpp, dsd_rnn, dsd_lpp, dsd_lnn;
always @(posedge mclk or negedge reset_n) 
    if (1'b0 == reset_n) begin
        dsd_rpp <= 8'd0;
        dsd_rnn <= 8'd0;
        dsd_lpp <= 8'd0;
        dsd_lnn <= 8'd0;
        end
    else begin
        dsd_lpp <= dsdlq[7:0];
        dsd_lnn <= dsdlq[7:0] ^ 8'hFF;
        dsd_rpp <= dsdrq[7:0];
        dsd_rnn <= dsdrq[7:0] ^ 8'hFF;
        end

//assign dsd_lp0 = dsdlq[0];
//assign dsd_ln7 = ~dsdlq[0];
//assign dsd_lp1 = dsdlq[1];
//assign dsd_ln6 = ~dsdlq[1];
//assign dsd_lp2 = dsdlq[2];
//assign dsd_ln5 = ~dsdlq[2];
//assign dsd_lp3 = dsdlq[3];
//assign dsd_ln4 = ~dsdlq[3];
//assign dsd_lp4 = dsdlq[4];
//assign dsd_ln3 = ~dsdlq[4];
//assign dsd_lp5 = dsdlq[5];
//assign dsd_ln2 = ~dsdlq[5];
//assign dsd_lp6 = dsdlq[6];
//assign dsd_ln1 = ~dsdlq[6];
//assign dsd_lp7 = dsdlq[7];
//assign dsd_ln0 = ~dsdlq[7];

//assign dsd_rp0 = dsdrq[0];
//assign dsd_rn7 = ~dsdrq[0];
//assign dsd_rp1 = dsdrq[1];
//assign dsd_rn6 = ~dsdrq[1];
//assign dsd_rp2 = dsdrq[2];
//assign dsd_rn5 = ~dsdrq[2];
//assign dsd_rp3 = dsdrq[3];
//assign dsd_rn4 = ~dsdrq[3];
//assign dsd_rp4 = dsdrq[4];
//assign dsd_rn3 = ~dsdrq[4];
//assign dsd_rp5 = dsdrq[5];
//assign dsd_rn2 = ~dsdrq[5];
//assign dsd_rp6 = dsdrq[6];
//assign dsd_rn1 = ~dsdrq[6];
//assign dsd_rp7 = dsdrq[7];
//assign dsd_rn0 = ~dsdrq[7];

//assign dsd_rp0 = dsd_rpp[0];
assign dsd_rp1 = dsd_rpp[1];
assign dsd_rp2 = dsd_rpp[2];
assign dsd_rp3 = dsd_rpp[3];
assign dsd_rp4 = dsd_rpp[4];
assign dsd_rp5 = dsd_rpp[5];
assign dsd_rp6 = dsd_rpp[6];
assign dsd_rp7 = dsd_rpp[7];

assign dsd_rn7 = dsd_rnn[0];
assign dsd_rn6 = dsd_rnn[1];
assign dsd_rn5 = dsd_rnn[2];
assign dsd_rn4 = dsd_rnn[3];
assign dsd_rn3 = dsd_rnn[4];
assign dsd_rn2 = dsd_rnn[5];
assign dsd_rn1 = dsd_rnn[6];
assign dsd_rn0 = dsd_rnn[7];

assign dsd_lp0 = dsd_lpp[0];
assign dsd_lp1 = dsd_lpp[1];
assign dsd_lp2 = dsd_lpp[2];
assign dsd_lp3 = dsd_lpp[3];
assign dsd_lp4 = dsd_lpp[4];
assign dsd_lp5 = dsd_lpp[5];
assign dsd_lp6 = dsd_lpp[6];
assign dsd_lp7 = dsd_lpp[7];

assign dsd_ln7 = dsd_lnn[0];
assign dsd_ln6 = dsd_lnn[1];
assign dsd_ln5 = dsd_lnn[2];
assign dsd_ln4 = dsd_lnn[3];
assign dsd_ln3 = dsd_lnn[4];
assign dsd_ln2 = dsd_lnn[5];
assign dsd_ln1 = dsd_lnn[6];
assign dsd_ln0 = dsd_lnn[7];

wire self_test;
wire [7:0] db138;

clock138master u200(
.preset_n(reset_n),
.en45(en45),
.en49(en49),
.mclk(mclk),
.self_test(self_test),
.debug(db138),
.clk138_bck(clock138_bck),
.clk138_lrck(clock138_lrck),
.clk138_data(clock138_data)
);

//assign spdif_en = clock138_lrck;
//assign led = db138;
assign led[7] = mclk;
assign led[6:0] = 7'b1010101;
assign dsd_rp0 = mclk_d2;
endmodule


//
// for ADC testing, signal generator
// for DSD128 input, BCK = 5644800, which is 1/8 of 45.1584MHz(mclk)
// however, since DSD source has 2 channels 
// we can't pack them back to 2channel i2s unless we have a 2x bit clock,
// so in dsd mode, only one channel is generated.
// 5644800 BCK is equal to the BCK of 88200 2 channel PCM32
//
// consider we are using 49.152MHz clock, to sample bck, bck should be <= 1/4 of MCLK
// that limit our max ADC sample rate to DSD256 or PCM192K/32
// good enough for our ADC design/testing...since we will be doing <= DSD256 rate
//
//

module dsd_gen(
input mclk,
input reset_n,
output bck,
output dsd1,
output dsd2);

reg clkd2;
always @(posedge mclk or negedge reset_n) if (1'b0 == reset_n) clkd2 <= 0; else clkd2 <= ~clkd2;

reg clkd4;
always @(posedge clkd2 or negedge reset_n) if (1'b0 == reset_n) clkd4 <= 0; else clkd4 <= ~clkd4;

reg clkd8;
always @(posedge clkd4 or negedge reset_n) if (1'b0 == reset_n) clkd8 <= 0; else clkd8 <= ~clkd8;

assign bck = ~clkd8;
reg d1, d2;
reg [4:0] i;

always @(posedge clkd8 or negedge reset_n) 
    if (1'b0 == reset_n) begin
        d1 <= 0;  d2 <= 0;   i<= 0;
        end
    else begin
        i <= i + 5'd1;
        d1 <= i[4]; /// act like lrck
        d2 <= i[0]; /// 1-0-1-0...
        end

assign dsd1 = d1;
assign dsd2 = d2;

endmodule

////// clock138 IC configure and testing /////
module clock138master(
input preset_n,
input en45,
input en49,
input mclk,
input clk138_bck,
input clk138_lrck,
output self_test,
output [7:0] debug,
output clk138_data
);

wire [67:0]config3s;
assign config3s  =  68'h0aa5aab5a55aaa50;// toggle 176.4

wire [63:0] key;
assign key = config3s[63:0];

reg reset_n;
always @*
    if (1'b0 == en45 && 1'b0 == en49) reset_n = 1'b0;
    else reset_n = preset_n;
reg data, n_data;
reg olrck;
reg [14:0] i, n_i;
reg work, n_work;
reg do_selftest, n_do_selftest;

assign clk138_data = data;

always @(posedge clk138_bck or negedge reset_n)
    if (1'b0 == reset_n) begin
        i<=0;
        olrck <= 0;
        data <= 0;
        work <= 0;
        do_selftest <= 0;
        end
    else begin
        i<= n_i;
        olrck <= clk138_lrck;
        data <= n_data;
        work <= n_work;
        do_selftest <= n_do_selftest;
        end
always @* begin
    n_i =i;
    n_data = data;
    n_work = work;
    n_do_selftest = do_selftest;
    if (clk138_lrck == 1'b0 && olrck == 1'b1) n_work = 1'b1;

    if (2'b11 != i[14:13]  && work) begin
        n_i = i + 15'd1;
        if (key[63 - i[12:7]]) n_data = 1'b1;
            else n_data = 1'b0;
        end
    else 
        if (work) n_do_selftest = 1'b1;
    end

`ifdef NO_SELF_TEST
assign self_test = 1'b0;
assign debug = 8'h0;
`else

reg ol;
reg [1:0] state, n_state;
reg [8:0] j, n_j;
reg test_good, n_test_good;

//assign debug = {state,  j[8:3]};
assign debug = {test_good, j[8:2]};


parameter IDLE = 2'd0;
parameter TEST = 2'd1;
parameter LATCH_RESULT = 2'd2;
parameter NOP = 2'd3;

always @(posedge mclk or negedge reset_n) 
    if (1'b0 == reset_n) begin
        ol <= 0;
        j <= 0;
        state <= 0;
        test_good <= 0;
        end
    else begin
        ol <= clk138_lrck;
        j <= n_j;
        state <= n_state;
        test_good <= n_test_good;
        end

always @* begin
    n_j = j;
    n_state = state;
    n_test_good = test_good;

    case(state)
IDLE: begin
    n_j = 0;
    n_test_good = 0;
    if (do_selftest && (ol==1'b1 && clk138_lrck ==1'b0)) n_state = TEST;
    end
TEST: begin
    if (j < 9'd511) n_j = j + 9'd1;
    if (ol==1'b0 && clk138_lrck ==1'b1) n_state = LATCH_RESULT;
    end

LATCH_RESULT: begin
    if (j[8:3] < 6'd24 ) 
         n_test_good = 1'b1;
    else 
         n_test_good = 1'b0;
    end
NOP: begin end

    endcase
    end


assign  self_test = test_good;

`endif


endmodule



//// DEM test ///



// a0.....a7
// .
// h0 
// each row has 1 "1" each colume has 1 "1"
//
// the trick is to generate random "n" below

module dem(
input dem_clk,
input reset_n,
input [7:0] x,
input [7:0] xbar,
output reg [7:0] ybar,
output reg [7:0] y);

wire x0,x1,x2,x3,x4,x5,x6,x7;
assign {x7,x6,x5,x4,x3,x2,x1,x0} = x;

wire a0,a1,a2,a3,a4,a5,a6,a7;
wire b0,b1,b2,b3,b4,b5,b6,b7;
wire c0,c1,c2,c3,c4,c5,c6,c7;
wire d0,d1,d2,d3,d4,d5,d6,d7;
wire e0,e1,e2,e3,e4,e5,e6,e7;
wire f0,f1,f2,f3,f4,f5,f6,f7;
wire g0,g1,g2,g3,g4,g5,g6,g7;
wire h0,h1,h2,h3,h4,h5,h6,h7;

wire [7:0] A,B,C,D,E,F,G,H;

assign {a7,a6,a5,a4,a3,a2,a1,a0} = A;
assign {b7,b6,b5,b4,b3,b2,b1,b0} = B;
assign {c7,c6,c5,c4,c3,c2,c1,c0} = C;
assign {d7,d6,d5,d4,d3,d2,d1,d0} = D;
assign {e7,e6,e5,e4,e3,e2,e1,e0} = E;
assign {f7,f6,f5,f4,f3,f2,f1,f0} = F;
assign {g7,g6,g5,g4,g3,g2,g1,g0} = G;
assign {h7,h6,h5,h4,h3,h2,h1,h0} = H;

reg [1:0] p0,p1,p2,p3;

assign A = (p0==2'b00) ? 8'h80 : (p0==2'b01) ? 8'h20: (p0==2'b10) ? 8'h08 : 8'h02;
assign B = (p0==2'b00) ? 8'h40 : (p0==2'b01) ? 8'h10: (p0==2'b10) ? 8'h04 : 8'h01;
assign C = (p1==2'b00) ? 8'h80 : (p1==2'b01) ? 8'h20: (p1==2'b10) ? 8'h08 : 8'h02;
assign D = (p1==2'b00) ? 8'h40 : (p1==2'b01) ? 8'h10: (p1==2'b10) ? 8'h04 : 8'h01;
assign E = (p2==2'b00) ? 8'h80 : (p2==2'b01) ? 8'h20: (p2==2'b10) ? 8'h08 : 8'h02;
assign F = (p2==2'b00) ? 8'h40 : (p2==2'b01) ? 8'h10: (p2==2'b10) ? 8'h04 : 8'h01;
assign G = (p3==2'b00) ? 8'h80 : (p3==2'b01) ? 8'h20: (p3==2'b10) ? 8'h08 : 8'h02;
assign H = (p3==2'b00) ? 8'h40 : (p3==2'b01) ? 8'h10: (p3==2'b10) ? 8'h04 : 8'h01;

reg [4:0] n;
always @(n) begin
    case(n)
5'd0:  begin  p0 = 0; p1 = 1; p2 = 2; p3 = 3; end
5'd1:  begin  p0 = 0; p1 = 1; p2 = 3; p3 = 2; end
5'd2:  begin  p0 = 0; p1 = 2; p2 = 1; p3 = 3; end
5'd3:  begin  p0 = 0; p1 = 2; p2 = 3; p3 = 1; end
5'd4:  begin  p0 = 0; p1 = 3; p2 = 1; p3 = 2; end
5'd5:  begin  p0 = 0; p1 = 3; p2 = 2; p3 = 1; end

5'd6:  begin  p0 = 1; p1 = 0; p2 = 2; p3 = 3; end
5'd7:  begin  p0 = 1; p1 = 0; p2 = 3; p3 = 2; end
5'd8:  begin  p0 = 1; p1 = 2; p2 = 3; p3 = 0; end
5'd9:  begin  p0 = 1; p1 = 2; p2 = 0; p3 = 3; end
5'd10:  begin  p0 = 1; p1 = 3; p2 = 0; p3 = 2; end
5'd11:  begin  p0 = 1; p1 = 3; p2 = 2; p3 = 0; end

5'd12:  begin  p0 = 2; p1 = 3; p2 = 0; p3 = 1; end
5'd13:  begin  p0 = 2; p1 = 3; p2 = 1; p3 = 0; end
5'd14:  begin  p0 = 2; p1 = 1; p2 = 3; p3 = 0; end
5'd15:  begin  p0 = 2; p1 = 1; p2 = 0; p3 = 3; end
5'd16:  begin  p0 = 2; p1 = 0; p2 = 1; p3 = 3; end
5'd17:  begin  p0 = 2; p1 = 0; p2 = 3; p3 = 1; end

5'd18:  begin  p0 = 3; p1 = 0; p2 = 2; p3 = 1; end
5'd19:  begin  p0 = 3; p1 = 0; p2 = 1; p3 = 2; end
5'd20:  begin  p0 = 3; p1 = 1; p2 = 0; p3 = 2; end
5'd21:  begin  p0 = 3; p1 = 1; p2 = 2; p3 = 0; end
5'd22:  begin  p0 = 3; p1 = 2; p2 = 0; p3 = 1; end
5'd23:  begin  p0 = 3; p1 = 2; p2 = 1; p3 = 0; end

//more
5'd24:  begin  p0 = 3; p1 = 2; p2 = 1; p3 = 0; end
5'd25:  begin  p0 = 2; p1 = 1; p2 = 3; p3 = 0; end
5'd26:  begin  p0 = 0; p1 = 2; p2 = 3; p3 = 1; end
5'd27:  begin  p0 = 1; p1 = 0; p2 = 2; p3 = 3; end

5'd28:  begin  p0 = 1; p1 = 3; p2 = 2; p3 = 0; end
5'd29:  begin  p0 = 0; p1 = 1; p2 = 2; p3 = 3; end
5'd30:  begin  p0 = 3; p1 = 0; p2 = 1; p3 = 2; end
5'd31:  begin  p0 = 2; p1 = 3; p2 = 1; p3 = 0; end
    endcase
    end


always @(posedge dem_clk or negedge reset_n)
    if (1'b0 == reset_n) begin
        y <= 8'd0;
        ybar <= 8'd255;
        n <= 0;
        end
    else begin
        n <= n+1;
        ybar <= xbar;
        y[0] <= (x0 & a0) | (x1 & a1) | (x2 & a2) | (x3 & a3) | (x4 & a4) | (x5 & a5) | (x6 & a6) | (x7 & a7);
        y[1] <= (x0 & b0) | (x1 & b1) | (x2 & b2) | (x3 & b3) | (x4 & b4) | (x5 & b5) | (x6 & b6) | (x7 & b7);
        y[2] <= (x0 & c0) | (x1 & c1) | (x2 & c2) | (x3 & c3) | (x4 & c4) | (x5 & c5) | (x6 & c6) | (x7 & c7);
        y[3] <= (x0 & d0) | (x1 & d1) | (x2 & d2) | (x3 & d3) | (x4 & d4) | (x5 & d5) | (x6 & d6) | (x7 & d7);
        y[4] <= (x0 & e0) | (x1 & e1) | (x2 & e2) | (x3 & e3) | (x4 & e4) | (x5 & e5) | (x6 & e6) | (x7 & e7);
        y[5] <= (x0 & f0) | (x1 & f1) | (x2 & f2) | (x3 & f3) | (x4 & f4) | (x5 & f5) | (x6 & f6) | (x7 & f7);
        y[6] <= (x0 & g0) | (x1 & g1) | (x2 & g2) | (x3 & g3) | (x4 & g4) | (x5 & g5) | (x6 & g6) | (x7 & g7);
        y[7] <= (x0 & h0) | (x1 & h1) | (x2 & h2) | (x3 & h3) | (x4 & h4) | (x5 & h5) | (x6 & h6) | (x7 & h7);
        end

endmodule


