//
// SDIO
//

`define NO_ADC 1


// uncomment the following to debug state machine
//`define DEBUG_FSM    1

//uncomment the following to use 50MHz sdio instead of 25MHz
`define HIGH_SPEED_50  1   

//`define DEMO 1

// VID/PID
// vendor ID = 0x574 Product ID = 0x8020 , first debug version
`define VENDOR_ID_HI 8'h05
`define VENDOR_ID_LO 8'h74
`define PRODUCT_ID_HI 8'h80
`define PRODUCT_ID_LO 8'h20

// version control  //0.06
`define VERSION_HI 8'd0
`define VERSION_LO 8'd6 
`define SDIO_ADDR 10'd103

// magic number = 59, 5A  "YZ"
`define MAGIC_0 8'h59
`define MAGIC_1 8'h5A

// SDIO byte address
`define ADDR_MAGIC_0  4'd0
`define ADDR_MAGIC_1  4'd1
`define ADDR_VERSION_HI 4'd2
`define ADDR_VERSION_LO 4'd3
`define ADDR_FIFO 4'd4
`define ADDR_CTRL 4'd5
`define ADDR_SETTING 4'd6
`define ADDR_SPDIF 4'd7


module sdtop(
input sdclk_p,
input sdclk_n,
input rst_n,
input cmd,

//command interface
output reg cmd_out,
output reg cmd_out_en,

//data interface
input [3:0] sd_data_in,
output [3:0] sd_data_out,
output sd_data_out_en,

//i2s interface
output i2s_bck,
output i2s_lrck,
output i2s_data,
input mclk,
output obck,
output olrck,
output odata,
output dac_mode,
input bck_i,
input lrck_i,
input data_i,
output reg spdif_en,
output spdif_tx,

//AHB master interface
input  HREADY,
input  [31:0] HRDATA,
output [31:0] HADDR,
output [31:0] HWDATA,
output [1:0] HTRANS,
output HWRITE,

//dual xo ctrl
output en45,
output en49,

output [63:0] db64,
output [7:0] led
);

//
// inorder to support both ADC and DAC, we need a MUX here for AHB
//
reg  use_adc_mode;
reg  n_use_adc_mode;

`ifdef NO_ADC
assign dac_mode = 1'b1;
`else
assign dac_mode = use_adc_mode ?  1'b0 : 1'b1;
`endif
 
wire HREADY_DAC, HREADY_ADC;
wire [31:0] HRDATA_DAC, HRDATA_ADC;
wire [31:0] HADDR_DAC, HADDR_ADC;
wire [31:0] HWDATA_DAC, HWDATA_ADC;
wire [1:0] HTRANS_DAC, HTRANS_ADC;
wire HWRITE_DAC, HWRITE_ADC;

`ifdef NO_ADC
assign HWRITE = HWRITE_DAC;
assign HTRANS = HTRANS_DAC;
assign HWDATA = HWDATA_DAC;
assign HADDR =  HADDR_DAC;
assign HREADY_DAC = HREADY;
assign HREADY_ADC = 1'b0;
assign HRDATA_DAC = HRDATA;
assign HRDATA_ADC = 32'd0;

`else
assign HWRITE = use_adc_mode? HWRITE_ADC : HWRITE_DAC;
assign HTRANS = use_adc_mode? HTRANS_ADC : HTRANS_DAC;
assign HWDATA = use_adc_mode? HWDATA_ADC : HWDATA_DAC;
assign HADDR = use_adc_mode? HADDR_ADC : HADDR_DAC;
assign HREADY_DAC = use_adc_mode? 1'b0 : HREADY;
assign HREADY_ADC = use_adc_mode? HREADY : 1'b0;
assign HRDATA_DAC = use_adc_mode? 32'd0 : HRDATA;
assign HRDATA_ADC = use_adc_mode? HRDATA : 32'd0;
`endif

reg [7:0] sound_card_ctrl, n_sound_card_ctrl;
wire reset_n;
assign reset_n = sound_card_ctrl[7]? rst_n : 1'b0;

////data line receiver ctrl
reg [3:0] total_blocks, n_total_blocks;
reg sd_write_start, n_sd_write_start;
reg sd_read_start, n_sd_read_start;
reg in_cmd, n_in_cmd;  //flag for sdio reading, data reading must happen after response
reg [1:0] xo, n_xo;
assign en45 = xo[0];
assign en49 = xo[1];  // audio clock control

// for fifo
wire [31:0] din;     //data to push into fifo
wire wen;            //write enable
wire is_last_data;
wire data_bus_busy;  //tell sd controller the data bus is busy
wire [7:0]dbd;       //data controller debugger
wire read_en;
//wire [31:0] read_data = 32'haaaaaaaa;  //ADC data, fake one
//wire [31:0] read_data = 32'h12345678;    //ADC data, fake one
//wire [31:0] read_data = 32'hffffffff;    //ADC data, fake one
wire [31:0] read_data;

wire almost_full;
reg [17:0] limit;
reg [17:0] demo, n_demo;   //used to limit song playing length
reg demo_mute, n_demo_mute;

wire adc_fifo_is_empty;


// DATA controller
sd_data UD100(
    .db(dbd),
    .demo_mute(demo_mute),
    .data_bus_busy(data_bus_busy),
    .almost_full(almost_full),
    .fifo_is_empty(adc_fifo_is_empty),
    .total_blocks(total_blocks),
    .sdclk_p(sdclk_p), .sdclk_n(sdclk_n), .rst_n(rst_n), 
    .write_start(sd_write_start),
    .read_start(sd_read_start),
    .in_command(in_cmd),
    .data_in(sd_data_in), 
    .data_out_en(sd_data_out_en), .data_out(sd_data_out),
    .read_en(read_en), .read_data(read_data),
    .din(din), .wen(wen), .is_last_data(is_last_data));


///////////////////////////////////////////////////////////////////////////////////////////
/// DAC, S/PDIF, DoP interface uses gear type: pcm_left/pcm_right on periodically loop ////
/// just pick one sample off the gear and process it
// ==================DAC interface ========================================================
wire [31:0] source_left, source_right;
reg [31:0] wsource_left, wsource_right;
//dsd138, pick data from fifo, convert to i2s or dsd
wire [7:0] dsd138_ctrl;
wire in_data;
wire master_lrck, master_bck, master_en;
wire debugs;
wire debugt;
wire dop_clock;
wire spdif_clock;

//pcm2dsd DSD138(.in_mclk(mclk), .preset_n(rst_n), .ctrl(dsd138_ctrl),
wire obckx, olrckx, odatax;
pcm2dsd DSD138(.in_mclk(mclk), .preset_n(reset_n), .ctrl(dsd138_ctrl),
    .sdata(in_data), .in_lrck(1'b0), .in_bck(1'b0), 
    .debugs(debugs),
    .debugt(debugt),
    .dop_clock(dop_clock),
    .spdif_clock(spdif_clock),
    .master_lrck(master_lrck), .master_bck(master_bck), .master_en(master_en),
    .bck_dsd_clk(obckx), .olrck_dsd1(olrckx), .odata_dsd2(odatax)
);

wire obck1, olrck1, odata1;
wire obck2, olrck2, odata2;

reg dsd_clkr;
always @(posedge master_bck) dsd_clkr <= ~dsd_clkr;
wire dsd_clk;
CLKINT UDSDCLK (.A(dsd_clkr), .Y(dsd_clk));  //71 fanouts

reg start_dsd_tx;
always @(posedge dsd_clk) start_dsd_tx <= dsd138_ctrl[7] & dsd138_ctrl[6];
dsd_tx UDSDTX( .dsd_clk(dsd_clk), .rst_n(reset_n), .start(start_dsd_tx),
    .source_left(wsource_left), .source_right(wsource_right),
    .odsd_clk(obck1), .dsd_l(olrck1), .dsd_r(odata1));

reg start_pcm_tx;
always @(posedge master_bck) start_pcm_tx <= dsd138_ctrl[7] & (!dsd138_ctrl[6]);
pcm_tx UPCMTX(.in_bck(master_bck), .rst_n(reset_n), .start(start_pcm_tx),
    .source_left(wsource_left), .source_right(wsource_right),
    .obck(obck2), .olrck(olrck2), .odata(odata2));

////1bit DAC ////////////////////////////////////////
wire [1:0]oversampling_y;
wire [2:0] divx = dsd138_ctrl[2:0];
//assign oversampling_x = 0;
assign oversampling_y = (divx == 3'd1) ? 2'd3 :   // 8x 44.1K
                        (divx == 3'd2) ? 2'd2 :   // 4x 88.2K
                        (divx == 3'd3) ? 2'd1 :   // 2x 176.4K
                        0;                        // 1x 352.8K or Up
reg [1:0] oversampling_x;


reg clk_d2, clk_d4, clk_d8;
always @(posedge mclk or negedge reset_n) if (1'b0==reset_n) clk_d2 <= 0; else clk_d2 <= ~clk_d2;
always @(posedge clk_d2 or negedge reset_n) if (1'b0==reset_n) clk_d4 <=0; else clk_d4 <= ~clk_d4;
always @(posedge clk_d4 or negedge reset_n) if (1'b0==reset_n) clk_d8 <=0; else clk_d8 <= ~clk_d8;

wire dac_clk;
wire sdm_clk;

CLKINT_PRESERVE UDACCLK (.A(mclk), .Y(dac_clk));
always @(dac_clk) oversampling_x <= oversampling_y;

//CLKINT_PRESERVE USDMCLK(.A(mclk), .Y(sdm_clk)); //dsd512
//CLKINT_PRESERVE UCK12(.A(clk_d2), .Y(sdm_clk));    //dsd256
//CLKINT_PRESERVE USDMCLK(.A(clk_d4), .Y(sdm_clk));   //dsd128
CLKINT_PRESERVE UCK12(.A(clk_d8), .Y(sdm_clk));   //dsd64

wire signed [31:0] fir1;
wire signed [31:0] fir2;
wire fir1_started;
//input: 1x sample: gain: 0.5
fir_stage_1 DUT200(
.pclk(dac_clk), .preset_n(reset_n),
.start(start_pcm_tx),
.oversampling_x(oversampling_x),
.x_0(wsource_left),
.x_1(wsource_left),
.started(fir1_started),
.fir_out_0(fir1),
.fir_out_1(fir2)
);

wire signed [31:0] fir3;
wire signed [31:0] fir4;
wire fir2_started;
//input: 1x sample, gain: 0.5
fir_stage_2 DUT300(
.pclk(dac_clk), .preset_n(reset_n),
.start(fir1_started),
.x_0(fir1),
.x_1(fir2),
.started(fir2_started),
.fir_out_0(fir3),
.fir_out_1(fir4)
);

wire signed [27:0] xl0, xl1;
wire signed [35:0] yl0, yl1;
wire signed [27:0] xr0, xr1;
wire signed [35:0] yr0, yr1;
wire pipe_pcm_started;
wire pipe_pcm_started_r;

pipe_pcm DUT400(
.pclk(sdm_clk), .preset_n(reset_n),
.start(fir2_started),
.started(pipe_pcm_started),
.pcm(fir3),
.x0(xl0), .x1(xl1), .y0(yl0), .y1(yl1)
);

pipe_pcm DUT401(
.pclk(sdm_clk), .preset_n(reset_n),
.start(fir2_started),
.started(pipe_pcm_started_r),
.pcm(fir4),
.x0(xr0), .x1(xr1), .y0(yr0), .y1(yr1)
);

wire of_l, of_r;

wire dsd_l_clk, dsdlp, dsdlm;

//pipe_sdm #(.A1(36'ha100000), .A2(36'h3d00000), .A3(36'hb7a000), .A4(36'hd4000), .A5(36'h16000), .B6(36'd0))
pipe_sdm DUT500(
.pclk(sdm_clk), .preset_n(reset_n),
.start(pipe_pcm_started), .mute(1'b0),
.overflow(of_l),
.x0(xl0), .x1(xl1), .y0(yl0), .y1(yl1),
.dsd_clk(dsd_l_clk),
.sdm_out(dsdlp),
.sdm_out_n(dsdlm)
);

wire dsd_r_clk, dsdrp, dsdrm;
pipe_sdm DUT501(
.pclk(sdm_clk), .preset_n(reset_n),
.start(pipe_pcm_started), .mute(1'b0),
.overflow(of_r),
.x0(xr0), .x1(xr1), .y0(yr0), .y1(yr1),
.dsd_clk(dsd_r_clk),
.sdm_out(dsdrp),
.sdm_out_n(dsdrm)
);

//////////////////////////////////////////////////////

assign i2s_bck = dsd138_ctrl[6] ? obck1 : obck2;
assign i2s_lrck = dsd138_ctrl[6] ? olrck1 : olrck2;
assign i2s_data = dsd138_ctrl[6] ? odata1 : odata2;
assign obck = dsd138_ctrl[6] ? obck1 : obck2;
assign olrck = dsd138_ctrl[6] ? olrck1 : olrck2;
assign odata = dsd138_ctrl[6] ? odata1 : odata2;
//assign obck = dsd138_ctrl[6] ? obck1 : dsd_l_clk;
//assign olrck = dsd138_ctrl[6] ? olrck1 : dsdlp;
//assign odata = dsd138_ctrl[6] ? odata1 : dsdrp;


//// dop gear, for s/pdif
// pack 32bit DSD stream into 16bit DoP stream
// so DoP clock has to be 2x DSD32 clock
// for 49.152MHz MCLK, the max DSD32 rate is DSD512, so the max DoP rate is DSD 256
// for S/PDIF output, the max DoP rate is DSD128
wire  use_dsd = dsd138_ctrl[6];
wire  i2s_start = dsd138_ctrl[7];
wire  dop_start = i2s_start & use_dsd;
wire [15:0] dop_left, dop_right;

dop_gear UDOP (.dop_clock(dop_clock), .rst_n(reset_n), .start(dop_start), 
  .source_left(source_left), .source_right(source_right),
  .dop_left(dop_left), .dop_right(dop_right));

////SPDIF out/////
wire spdif_out;
reg n_spdif_en;

spdif_tx USPDIF_TX(.spdif_clock(spdif_clock), .rst_n(reset_n), .start(i2s_start),
    .use_dsd(use_dsd),
    .source_left(source_left), .source_right(source_right),
    .dop_left(dop_left), .dop_right(dop_right),
    .spdif_out(spdif_out));

//assign led[0] = spdif_out;
//assign odata = spdif_out;
assign spdif_tx = spdif_out;

// mem controller, the fifo, this one is for DAC, means data from host CPU to device (DAC)
wire [7:0] sd_ctrl;
wire [7:0] status;
assign sd_ctrl = sound_card_ctrl;
wire [7:0] dbm;  //debug

// DEMO SOUND LIMIT = 3 minutes
// about 2^18 2048 blocks in 384000
always @* begin
    limit = 18'd32700;
    if (3'b100 == sound_card_ctrl[2:0]) limit = 18'd262100;    //384K
    else if (3'b011 == sound_card_ctrl[2:0]) limit = 18'd131000; //192K
    else if (3'b010 == sound_card_ctrl[2:0]) limit = 18'd65500;  //96K
    else limit = 18'd32700;   //44K1
    end
reg master_bckd2;
always @(posedge master_bck or negedge reset_n) if (0 == reset_n) master_bckd2 <= 0; else master_bckd2 <= ~master_bckd2;

reg master_bckd4;
always @(posedge master_bckd2 or negedge reset_n) if (0 == reset_n) master_bckd4 <= 0; else master_bckd4 <= ~master_bckd4;
reg master_lrckd2;
always @(posedge master_lrck or negedge reset_n) if (0 == reset_n) master_lrckd2 <= 0; else master_lrckd2 <= ~master_lrckd2;

reg master_lrckd4;
always @(posedge master_lrckd2 or negedge reset_n) if (0 == reset_n) master_lrckd4 <= 0; else master_lrckd4 <= ~master_lrckd4;
//mem_controller uctrl(.sdclk(clk), .mclk(mclk), .reset_n(rst_n),
mem_controller uctrl(.sdclk_n(sdclk_n), .mclk(mclk), .reset_n(reset_n),
    .HREADY(HREADY_DAC), .HRDATA(HRDATA_DAC), 
    .HADDR(HADDR_DAC), .HWDATA(HWDATA_DAC), .HTRANS(HTRANS_DAC), .HWRITE(HWRITE_DAC),
    .ctrl(sd_ctrl), .din(din), .wen(wen), .is_last_data(is_last_data),
    .status(status),
    .bck(master_bckd2), .lrck(master_lrckd2), .dsd138_ctrl(dsd138_ctrl),
    .pcm_left(source_left), .pcm_right(source_right),
    .sdata(in_data),
    .dbm(dbm)
);
reg [6:0]wi;

always @(posedge master_bck or negedge reset_n)begin
    if(!reset_n)
        wi <= 0;
    else if(wi ==7'd63)begin
         wsource_left <=source_right;
         wi <= wi +7'd1;
    end
    else if(wi == 7'd127)begin
        wsource_left <=  source_left;
         wi <= 0;
    end
   
    
    else  begin
        wi <= wi +7'd1;
        wsource_left <= wsource_left;
        end
end
//assign led = dbm;
//assign led = dbd;
//assign led = 8'h77;
assign led = {of_l, 6'h04, of_r};


wire almost_empty; assign almost_empty = status[6];
assign almost_full = status[7];
reg [7:0] buffer_under_run, n_buffer_under_run;

`ifdef NO_ADC
assign adc_fifo_is_empty = 1'b0;
wire adc_fifo_full = 1'b0;
`else
////////////////////////ADC card-->host interface////////////////////////////////////////////////

//adc mem controller
wire adc_clock = bck_i;
wire [7:0] adc_status;
wire [7:0] adc_ctrl;
wire [7:0] adc_dbm;
wire adc_pcm_ready;
wire [31:0]adc_pcm32;
wire is_right;

adc_controller UADC(.sdclk_n(sdclk_n), .mclk(mclk), .bck(adc_clock), .reset_n(reset_n & use_adc_mode),
    .HREADY(HREADY_ADC), .HRDATA(HRDATA_ADC), 
    .HADDR(HADDR_ADC), .HWDATA(HWDATA_ADC), .HTRANS(HTRANS_ADC), .HWRITE(HWRITE_ADC),
    .ctrl(sd_ctrl), .read_en(read_en), .status(adc_status), .card_to_host(read_data),
    // to PCM gears
    .in_pcm_ctrl(adc_ctrl),
    // from PCM gears
    .pcm_ready(adc_pcm_ready),
    .pcm32(adc_pcm32),
    .is_right(is_right),
    .dbm(adc_dbm));

assign adc_fifo_is_empty = adc_status[7];
wire adc_fifo_full = adc_status[6];

wire [7:0] adc_debug;
//assign led = adc_debug;

adc_pcm_gear UADC_GEAR(.bck(adc_clock), .reset_n(reset_n & use_adc_mode),
    .lrck(lrck_i),
    .data(data_i),
    .ctrl(adc_ctrl),
    //output
    .debug(adc_debug),
    .is_right(is_right),
    .pcm_ready(adc_pcm_ready),
    .pcm32(adc_pcm32));

`endif

/////////////////////SDIO protocol////////////////////////////////////////////////////////////////


/// CCCR registers
reg cccr_cd_disable, n_cccr_cd_disable;  //DAT[3]'s pull up resistor switch
//reg cccr_busy, n_cccr_busy;    //no suspend/resume, no need this variable
reg [3:0] cccr_func_sel, n_cccr_func_sel; //only used in suspend/resume, not used in this card
reg cccr_reset, n_cccr_reset;


reg [3:0] state, n_state;
reg [2:0] bus_state, n_bus_state;
reg [39:0] response, n_response;
reg n_cmd_out, n_cmd_out_en;
reg no_crc, n_no_crc;   //R4 response need NO crc, only R5 response here need CRC, R4 uses 6'h3f instead

//assign led = demo[7:0];

//BUS STATE, page 58 of partE1_300
parameter INI = 3'd0;
parameter STB = 3'd1;
parameter TRN = 3'd2;
parameter CMD = 3'd3;
parameter INACTIVE = 3'd4;


//CRC7 ctrls
reg  bit, n_bit, crc_en, n_crc_en, crc_clr, n_crc_clr;
wire [6:0] crc;
crc7 UCRC (.BITVAL(bit), .ENABLE(crc_en), .BITSTRB(sdclk_n), 
   .rst_n(~crc_clr), .CRC(crc));

reg [7:0] i, n_i;  //counter

reg cmd_q, n_cmd_q; //buffered cmd by 1 clk
reg cmd_q2, n_cmd_q2; //buffered cmd by 2 clks
reg [31:0] arg, n_arg;  //command argument
reg [5:0] ind, n_ind;   //command index

parameter INIT = 4'd0;
parameter READ_CMD = 4'd1;
parameter HANDLE_CMD = 4'd2;
parameter SEND_RESP = 4'd3;
parameter SEND_RESP_20 = 4'd4;
parameter HANDLE_CMD357 = 4'd5;
parameter HANDLE_CMD52=4'd6;
parameter HANDLE_CCCR = 4'd7;
parameter HANDLE_FBR = 4'd8;
parameter HANDLE_CIS = 4'd9;
parameter HANDLE_CMD53 = 4'd10;
parameter CARD_RESET = 4'd11;
parameter HANDLE_USER = 4'd12;

`ifdef DEBUG_FSM
parameter HANDLE_CMD_DEBUG = 4'd13;
`endif


//assign led = ~dbd;
//assign led = ~dbm;

assign db64[63:56] = {4'h0, state};
assign db64[55:48] = {8'd0};
assign db64[47:40] = {2'h0, ind};
assign db64[39:32] = {arg[16:9]};
assign db64[31:24] = {arg[31:24]};
assign db64[23:16] = {arg[23:16]};
assign db64[15:8] = {arg[15:8]};
assign db64[7:0] = {arg[7:0]};


reg cmdo, cmden;

always @* cmd_out = cmdo;
always @* cmd_out_en = cmden;

//wire clkn;   
//assign clkn = ~clk;

wire cmd_delay;

//@@ HOPE we can delay more!, here's 3ns delay
//DELAYE #(.DEL_VALUE ("DELAY31")) UD1(.A(cmd), .Z(cmd_delay));

reg cmd0;
always @(posedge sdclk_p or negedge rst_n) 
    if (0==rst_n) cmd0 <= 0;
    else cmd0 <= cmd;
assign cmd_delay = cmd0;


always @(posedge sdclk_n or negedge rst_n)
    if (0==rst_n) begin
        state <= 0;
        bus_state <= 0;
        i <= 0;
        cmd_q <= 0;
        cmd_q2 <= 0;
        arg <= 0;
        ind <= 0;
        response <= 0;
        bit <= 0; crc_en <=0; crc_clr <= 0;        
        cmdo <= 0; cmden <= 0;
        no_crc <= 0;
        in_cmd <= 0;
        // CCCR
        cccr_cd_disable <= 0;
        //cccr_busy <= 0;
        cccr_func_sel <=0;
        cccr_reset <= 0;

        //data ctrl
        sd_write_start <= 0;
        sd_read_start <= 0;
        total_blocks <= 0;

        // sound card control
        sound_card_ctrl <= 0;
        xo <= 0;
        buffer_under_run <= 0;
        spdif_en <= 0;

        //for demo version
        demo <= 0; demo_mute <= 0;

        //for adc/dac switching
        use_adc_mode <= 0;

    end else begin
        state <= n_state;
        bus_state <= n_bus_state;
        i <= n_i;
        cmd_q <= n_cmd_q;
        cmd_q2 <= n_cmd_q2;
        arg <= n_arg;
        ind <= n_ind;
        response <= n_response;
        bit <= n_bit; crc_en <= n_crc_en; crc_clr <= n_crc_clr;
        cmdo <= n_cmd_out; cmden <= n_cmd_out_en;
        no_crc <= n_no_crc;
        in_cmd <= n_in_cmd;

        // CCCR registers
        cccr_cd_disable <= n_cccr_cd_disable;
        //cccr_busy <= n_cccr_busy;
        cccr_func_sel <= n_cccr_func_sel;
        cccr_reset <= n_cccr_reset;

        //data ctrl
        sd_write_start <= n_sd_write_start;
        sd_read_start <= n_sd_read_start;
        total_blocks <= n_total_blocks;

        // sound card control
        sound_card_ctrl <= n_sound_card_ctrl;
        xo <= n_xo;
        buffer_under_run <= n_buffer_under_run;
        spdif_en <= n_spdif_en;

        demo <= n_demo; demo_mute <= n_demo_mute;

        use_adc_mode <= n_use_adc_mode;
    end

always @* begin
    n_state = state;
    n_bus_state =  bus_state;
    n_i = i;
    n_arg = arg;
    n_ind = ind;
    n_response = response;
    n_bit = bit; n_crc_en = crc_en; n_crc_clr = crc_clr;
    n_cmd_out = cmdo; n_cmd_out_en = cmden;
    n_no_crc = no_crc;
    n_in_cmd = in_cmd;
    n_sound_card_ctrl = sound_card_ctrl;
    n_xo = xo;
    n_buffer_under_run = buffer_under_run;
    n_spdif_en = spdif_en;

    n_cccr_cd_disable = cccr_cd_disable;
    //n_cccr_busy = cccr_busy;
    n_cccr_func_sel = cccr_func_sel;
    n_cccr_reset = cccr_reset;

    n_cmd_q = cmd_q;
    n_cmd_q2 = cmd_q2;

    n_sd_write_start = sd_write_start;
    n_sd_read_start = sd_read_start;
    n_total_blocks = total_blocks;

    n_demo = demo; n_demo_mute = demo_mute;

    n_use_adc_mode = use_adc_mode;
    case(state)


CARD_RESET: begin
   // do the reset things.... ???XXX
   n_sound_card_ctrl = 0;
   n_cccr_reset = 0;   // clear bit
   //n_cccr_busy = 0;
   n_cccr_func_sel = 0;
   n_bus_state = INI;
   n_sd_write_start = 0;
   n_sd_read_start = 0;
   n_state = INIT;  //waiting for incoming command
   n_i = 0;
   end

SEND_RESP: begin
    //n_response = 40'b0001000100000000000000000000100100000000;
    //n_response = 40'b0101000100000000000000000000000000000000;
    //n_response = 40'b0100000000000000000000000000000000000000; 
    n_i = 8'd0;
    n_crc_clr = 1'b0;
    n_sd_write_start = 1'b0;
    n_sd_read_start = 1'b0;

    n_state = SEND_RESP_20;  
    end

SEND_RESP_20: begin
    if (i < 8'd54) begin
        if (i < 8'd10 && crc_en == 1'b0) begin
            n_cmd_out = 1'b1;       // STRONG PULL UP
            n_cmd_out_en = 1'b1;
            end
        else begin
            n_cmd_out = bit;
            n_cmd_out_en = crc_en;
            end
        if (!no_crc) begin   //R5
            if (i==8'd41) n_cmd_out = crc[6];
            if (i==8'd42) n_cmd_out = crc[5];
            if (i==8'd43) n_cmd_out = crc[4];
            if (i==8'd44) n_cmd_out = crc[3];
            if (i==8'd45) n_cmd_out = crc[2];
            if (i==8'd46) n_cmd_out = crc[1];
            if (i==8'd47) n_cmd_out = crc[0];
        end 
        else begin //R4
            if (i==8'd41) n_cmd_out = 1'b1;
            if (i==8'd42) n_cmd_out = 1'b1;
            if (i==8'd43) n_cmd_out = 1'b1;
            if (i==8'd44) n_cmd_out = 1'b1;
            if (i==8'd45) n_cmd_out = 1'b1;
            if (i==8'd46) n_cmd_out = 1'b1;
        end
        if (i>=8'd48) n_cmd_out = 1'b1;       //end bit

        if (i>8'd40) n_cmd_out_en = 1'b1;

        n_crc_clr = 1'b0;
        n_crc_en = 1'b1;
        n_bit = response[39];
        n_response = {response[38:0], 1'b0};
        n_i = i + 8'b1;
        if (i>=8'd40) n_crc_en = 1'b0;
        end
    else begin
        n_crc_en = 1'b0;
        n_cmd_out_en = 1'b0;
        n_cmd_q = 1'b1;
        n_cmd_q2 = 1'b1;
        n_in_cmd = 1'b0;   //command mode over
        if (cccr_reset == 1'b1) 
            n_state = CARD_RESET;
        else
            n_state = INIT;    // wait next cmd
        end
    end

INIT:  begin
    n_response = 40'd0;
    n_arg = 32'd0;
    n_ind = 6'd0;
    n_i = 8'h02;
    n_sd_read_start = 1'b0;

    n_cmd_q = cmd_delay;
    n_cmd_q2 = cmd_q;

    n_cmd_out = 1'b1;       // STRONG PULL UP before response
    n_cmd_out_en = 1'b0;    // free the CMD bus

    n_no_crc = 1'b0;
    n_in_cmd = 1'b0;

    if ((data_bus_busy == 1'b0) && (bus_state == TRN))
        n_bus_state = CMD;

    if (cmd_q == 1'b1 && cmd_q2 == 1'b0) begin
        n_state = READ_CMD;    //command start
        end
    end

READ_CMD:  begin
    n_cmd_q = cmd_delay;
    n_cmd_q2 = cmd_q;
    n_in_cmd = 1'b1;   //in command mode

    n_i[5:0] = i[5:0] + 6'd1;

    if (i[5:0] < 6'd8) n_ind = {ind[4:0], cmd_q };

    if ((i[5:0] > 6'd7) && (i[5:0] < 6'd40)) begin
        n_arg = { arg[30:0], cmd_q }; 
        if (ind >= 6'd60) n_state = INIT;  //max command <60
        end

    if (i[5:0] == 6'd47) begin  //47
       n_state = HANDLE_CMD;

`ifdef DEBUG_FSM
       n_state = HANDLE_CMD_DEBUG;
`endif
       n_cmd_out = 1'b1;       // STRONG PULL UP before response
       n_cmd_out_en = 1'b1;
       end
    end

HANDLE_CMD: begin
    n_cmd_q = 1'b1;
    n_cmd_q2 = 1'b1;

    n_crc_clr = 1'b1;  //clear CRC
    n_crc_en = 1'b0;


    // for all other unsupported commands, ignore them
    n_state = INIT;

    if (bus_state == INACTIVE) 
        n_state = INIT;  //inactive, do nothing, no command accepted?
    else if (bus_state == INI) begin
        // bus state == INI, only CMD5, CMD3 and CMD15 are accepted

        if (ind == 6'd5) n_state = HANDLE_CMD357;
        if (ind == 6'd3) n_state = HANDLE_CMD357;
        if (ind == 6'd15) begin
            n_state = INIT;
            n_bus_state = INACTIVE;
            end     
        end
    else if (bus_state == STB) begin
        // bus state == STB, only cmd 3, 7, 15 are supported
        if (ind == 6'd3) n_state = HANDLE_CMD357;
        if (ind == 6'd7) n_state = HANDLE_CMD357;
        if (ind == 6'd15) begin
            n_state = INIT;
            n_bus_state = INACTIVE;
            end     
        end

    else if (bus_state == TRN) begin
        // NO CMD52 allowed here!!! not supported  DAT bus active, BS == 1
        if (ind == 6'd52) n_state = HANDLE_CMD52;
        //n_demo = 8'h66;
        end

    else if (bus_state == CMD) begin
        // bus state == CMD, handle CMD7, CMD52, CMD53, CMD15 here
        if (ind == 6'd7) n_state = HANDLE_CMD357;
        if (ind == 6'd52) n_state = HANDLE_CMD52;
        if (ind == 6'd53) n_state = HANDLE_CMD53;
        if (ind == 6'd15) begin
            n_state = INIT;
            n_bus_state = INACTIVE;
            end     
        end
    else begin //something is wrong, set bus state to INI, redo
        n_bus_state = INI;
        n_state = INIT;
        end
    end

`ifdef DEBUG_FSM
HANDLE_CMD_DEBUG: begin
    n_cmd_q = 1'b1;
    n_cmd_q2 = 1'b1;

    n_crc_clr = 1'b1;  //clear CRC
    n_crc_en = 1'b0;

    n_state = HANDLE_CMD_DEBUG;
        
        //1st cmd is 63, didn't respond
        //2nd cmd is 52, read CCCR #6, should ignore
        //3rd cmd is 52, write CCCR #6, RESET, should ignore
        //4th cmd is 0, RESET SD MEM, should ignore
        //5th cmd is CMD8,  offered 2.7V-3.6V operating range, check high
        //    capacity SD mem cards, ignore here
        //6th cmd is CMD5 (ARG0), if ignored, will issue CMD55+ACMD41 to check
        //    memory card, we should not ignore here, should respond R4
        //7th cmd is CMD3, will send back 0x6969 as our addr
        //8th cmd is CMD7, asking for 0x6969 card!
        //9th cmd is CMD52, read CCCR reg #0 , ask SDIO version and CCCR version
        //10th CMD52, read CCCR reg#8, READ SDC etc, card capability
        //11th CMD52, read CCCR reg#18, READ  power ctrl data
        //12th CMD52, read CCCR reg#19, READ SPEED setting
        //13th CMD52, read CCCR reg#9, READ CIS ADDR
        //14th CMD52, read CCCR reg#10, READ CIS ADDR
        //15th CMD52, read CCCR reg#11, READ CIS ADDR
        //16th CMD52, READ CIS, 0x10000 total 19 bytes
        //35th CMD52, READ CCCR reg#7 check bus width
        //36th CMD52, WRITE CCCR reg#7 set bus width = 4bit
        //37th CMD52, READ FBR reg@0x100
        //38,39,40th CMD52, READ FBR reg@0x109,A,B CIS addr
        //41th CMD52 READ CIS for func1
        if (ind == 6'd63) n_state = INIT;
//        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h06)  n_state = INIT;
//        if (ind == 52 && arg[31:24] == 128 && arg[25:9] == 17'h06)  n_state = INIT;
        if (ind == 6'd0) n_state = INIT;
        if (ind == 6'd8) n_state = INIT;
        if (ind == 6'd5) n_state = HANDLE_CMD357;
        if (ind == 6'd3) n_state = HANDLE_CMD357;
        if (ind == 6'd7) n_state = HANDLE_CMD357;
/*
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h0)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h8)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h12)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h13)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h9)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'hA)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'hB)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] >= 17'h1000)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h7)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:24] == 128 && arg[25:9] == 17'h7)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h100)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h109)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h10A)  n_state = HANDLE_CMD52;
        if (ind == 52 && arg[31:28] == 0 && arg[25:9] == 17'h10B)  n_state = HANDLE_CMD52;
*/
        if (ind == 6'd52 && j <8'd40) n_state = HANDLE_CMD52;

//        end
//    else if (bus_state == STB) begin
//        // bus state == STB, only cmd 3, 7, 15 are supported
//        if (ind == 3) n_state = HANDLE_CMD3;
//        if (ind == 7) n_state = HANDLE_CMD7;
//        if (ind == 15) begin
//            n_state = INIT;
//            n_bus_state = INACTIVE;
//            end     
//        end
//    else if (bus_state == TRN) begin
//        // bus state == TRN, only CMD52 are OK, DAT bus active, BS == 1
//        if (ind == 52) n_state = HANDLE_CMD52;
//        end
//    else if (bus_state == CMD) begin
        //  bus state == CMD, handle CMD7, CMD52, CMD53, CMD15 here
//        if (ind == 7) n_state = HANDLE_CMD7;
//        if (ind == 52) n_state = HANDLE_CMD52;
//        if (ind == 53) n_state = HANDLE_CMD53;
//        if (ind == 15) begin
//            n_state = INIT;
//            n_bus_state = INACTIVE;
//            end     
//        end
//    else begin //something is wrong, set bus state to INI, redo
//        n_bus_state = INI;
//        n_state = INIT;
//        end
    end

`endif

HANDLE_CMD357: begin   //handle CMD3, CMD5, CMD7
    if (ind == 6'd5) begin
        //Response with R4, NO CRC in R4
        n_response[39:38] = 2'b00;      // S=0 D=0
        n_response[37:32] = 6'b111111;  // reserved all 1
        n_response[31] = 1'b1;          // card I/O ready!     IORDY = 1;
        n_response[30:28] = 3'b001;       // 1 I/O function  F == 1;
        n_response[27] = 1'b0;          // NO SD memory MP == 0;
        n_response[26:24] = 3'b000;     // stuff, even S18A==0, so no 1.8V supported here
        n_response[23:0] = 24'hff8000;   // 2.7V-3.6V, reserved bits all 0
        n_no_crc = 1'b1;
        n_state = SEND_RESP;  //send R4
        end
    else if (ind == 6'd3) begin
        // respond with R6, provide RCA (relative card address)
        n_no_crc = 1'b0; //need CRC here!
        n_response[39:38] = 2'b00;      // S=0 D=0
        n_response[37:32] = 6'b000011;  // CMD3
        n_response[31:16] = 16'h6969;   // our RCA is 0x6969!
        n_response[15:0] = {1'b0, 1'b0, 1'b0,  // NO_CRC_ERR, NOT illegal command, NO err,
                            13'h00};           // should be 0 for SDIO only cards 
        n_bus_state = STB;  //bus state machine
        n_state = SEND_RESP;
        end
    else begin   // CMD7
        if (arg[31:16] == 16'h6969) begin   // RCA match, CARD selected!
            // respond with R1b, select / deselect card
            n_no_crc = 1'b0; //need CRC here!
            n_response[39:38] = 2'b00;      // S=0 D=0
            n_response[37:32] = 6'b000111;  // CMD7
            n_response[31:0] = 32'd0;
            n_response[12:9] = 4'b1111;     // for I/O card , this must be 1111
            n_bus_state = CMD;   // RCA correct! mode => CMD
            n_state = SEND_RESP;
            end
        else begin
            //selected other card instead, continue wait for the next command
            n_state = INIT;
            n_bus_state = STB;     //incorrect RCA
            end
        end
    end

HANDLE_CMD52: begin
    n_i = 8'd2;
    n_no_crc = 1'b0;      //R5 need CRC
    n_response[39:0] = 40'd0;  //clear all
    n_response[39:38] = 2'b00;      // S=0 D=0
    n_response[37:32] = 6'b110100;  //CMD52
    n_response[31:16] = 16'b0;      //stuff bits
    n_response[15:8] = 8'b0;        //NO error!
    n_state = SEND_RESP;

    // validate command ..., CMD52 not allowed in TRN state
    //if (bus_state == CMD) begin
    begin
        n_response [13:12] = 2'b01;  //CMD = DAT line free
        //if (arg[30:28] == 3'b000) begin   //function =  0, CIA info, CCCR, FBR ...
        if (arg[28] == 1'b0) begin   //function =  0, CIA info, CCCR, FBR ...
           // Common I/O area, CIA
           if (arg[31] == 1'b1)  //Write command
               n_response[7:0] = arg[7:0];  
           else  //READ command
               n_response[7:0] = 8'd0;
           
           if (arg[21:9] >= 13'd0 && arg[21:9] <= 13'hff)   //CCCR
               n_state = HANDLE_CCCR;
           else if ((arg[21:9] >= 13'h100) && (arg[21:9] <= 13'h1FF) && arg[31] == 1'b0) //FBR of function 1
               n_state = HANDLE_FBR;
           else if (arg[21:9] >= 13'h1000 && arg[31] == 1'b0)   //CIS 
               n_state = HANDLE_CIS;
           end

        else begin   // function = 1, access SDIO device function, all functions direct to here
           n_state = HANDLE_USER;
           end
        end
    end

HANDLE_USER: begin
    n_state = SEND_RESP;
    if (arg[31] == 1'b0) begin //READ operation
        n_response[7:0] = 8'd0;
        //if (arg[12:9] == `ADDR_MAGIC_0) n_response[7:0] = `MAGIC_0;
        if (arg[12:9] == `ADDR_MAGIC_0) n_response[7:0] = buffer_under_run;
        if (arg[12:9] == `ADDR_MAGIC_1) n_response[7:0] = `MAGIC_1;
        if (arg[12:9] == `ADDR_VERSION_HI) n_response[7:0] = `VERSION_HI;
        if (arg[12:9] == `ADDR_VERSION_LO) n_response[7:0] = `VERSION_LO;
        if (arg[12:9] == `ADDR_FIFO) n_response[7:0] = status;
        if (arg[12:9] == `ADDR_SPDIF) n_response[0] = spdif_en;
        if (arg[12:9] == `ADDR_CTRL) begin
            n_response[7:6] = sound_card_ctrl[7:6];  //start bits
            n_response[1:0] = xo; //clocks
            end
        if (arg[12:9] == `ADDR_SETTING) begin
            n_response[3] = sound_card_ctrl[5]; //dsd flag
            n_response[2:0] = sound_card_ctrl[2:0];  //div flag
            end
        end
    else begin  //write operation
        if (arg[12:9] == `ADDR_CTRL) begin
            n_sound_card_ctrl[7:6] =arg[7:6];  //start bits
            if (2'b11 == arg[7:6]) begin
                n_buffer_under_run = 8'd0;
                n_demo = 18'd0;
                n_demo_mute = 1'b0;
                end
            n_xo = arg[1:0];  //clocks
            end
        else if (arg[12:9] == `ADDR_SETTING)
            begin
            n_sound_card_ctrl[5] = arg[3];  //dsd/pcm flag
            n_sound_card_ctrl[2:0] = arg[2:0]; //div flag
            end
        else if (arg[12:9] == `ADDR_SPDIF) 
            n_spdif_en = arg[0];
        end
    end


HANDLE_CCCR: begin  
    if (i[3:0] == 4'd0)
        n_state = SEND_RESP;
    else
        n_state = state;
    n_i[3:0] = i[3:0] - 4'd1;

    if (arg[31]==1'b0) begin  //READ CCCR
       if (arg[16:9] == 8'h00) n_response[7:0] = 8'h32; // SDIO 2.0 CCCR 2.0
       if (arg[16:9] == 8'h01) n_response[7:0] = 8'h02; // SDIO PHY version 2.0
       if (arg[16:9] == 8'h02) n_response[7:0] = 8'h02; // Function 1 always enabled ???XXX
       if (arg[16:9] == 8'h03) n_response[7:0] = 8'h02; // Function 1 always READY ???XXX
       if (arg[16:9] == 8'h04) n_response[7:0] = 8'h00; // NO interrupt is allowed ???XXX
       if (arg[16:9] == 8'h05) n_response[7:0] = 8'h00; // NO pending interrupt
       if (arg[16:9] == 8'h06) n_response[7:0] = 8'h00; // I/O abort, this is Write ONLY

           //SCSI = 0, ECSI = 0, S8B = 0, 4bit BUS ONLY ???XXX
       if (arg[16:9] == 8'h07) n_response[7:0] 
          = {cccr_cd_disable, 1'b0, 1'b0, 2'b00, 1'b0, 2'b10};

          //4BLS=LSC=0; E4MI=S4MI=0; SBS=0(No suspend, resume),
          //SRW = 0 (No read wait); SMB = 0 (No Block mode)
          //SDC = 0, NO CMD52 during data transfer!
       //if (arg[16:9] == 8'h08) n_response[7:0]  = {2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0};
       if (arg[16:9] == 8'h08) n_response[7:0]  = {2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b1};   //SMB=SDC=1
       //if (arg[16:9] == 8'h08) n_response[7:0]  = {2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0};   //SMB=1 SDC=0

       if (arg[16:9] == 8'h09) n_response[7:0] = 8'h00; // CIS addr = 0x1000
       if (arg[16:9] == 8'h0A) n_response[7:0] = 8'h10; //
       if (arg[16:9] == 8'h0B) n_response[7:0] = 8'h00; //
       
       // no suspend/resume, so BS always = 0
       if (arg[16:9] == 8'h0C) n_response[7:0] = {7'h00, 1'b0}; //ignore BR part

           //DF = 0; 
       if (arg[16:9] == 8'h0D) n_response[7:0] 
           = {1'b0, 3'b000, cccr_func_sel};
       
       if (arg[16:9] == 8'h0E)  n_response[7:0] = 8'h00; //since SBS==0, this part return 0
       if (arg[16:9] == 8'h0F)  n_response[7:0] = 8'h00; //since SBS==0, this part return 0
       
       if (arg[16:9] == 8'h10) n_response[7:0] = 8'h00; //since SMB==0, this part is 0
       if (arg[16:9] == 8'h11) n_response[7:0] = 8'h02; //block size = 512
       
       if (arg[16:9] == 8'h12) n_response[7:0] = 8'h00; //EMPC=SMPC=0; power doesn't matter
       
           // BUS speed = 25MHz fixed here  SHS = 0, no high speed
           // in this version
       if (arg[16:9] == 8'h13) n_response[7:0]  = {4'b0, 3'b000, 1'b0};

`ifdef HIGH_SPEED_50
       if (arg[16:9] == 8'h13) n_response[7:0]  = {4'b0, 3'b001, 1'b1};   //always running @50MHz
`endif
       
       if (arg[16:9] == 8'h14) n_response[7:0] = 8'h00; // UHS-I not supported here
       if (arg[16:9] == 8'h15) n_response[7:0] = 8'h00; // Only Drive Strength Type B OK
       if (arg[16:9] == 8'h16) n_response[7:0] = 8'h00; // SAI = EAI = 0;
       
       end
    else begin  //WRITE CCCR
       if (arg[16:9] == 8'h07) n_cccr_cd_disable = arg[7]; 
       if (arg[16:9] == 8'h0D) n_cccr_func_sel = arg[3:0]; 
       if (arg[16:9] == 8'h06) n_cccr_reset = arg[3];
       end
    end

HANDLE_FBR: begin  //READ ONLY
    //n_state = SEND_RESP;
    if (i[3:0]==4'd0)
        n_state = SEND_RESP;
    else
        n_state = state;
    n_i[3:0] = i[3:0] - 4'd1;


    if (arg[16:9] == 8'h00) n_response[7:0] = {8'b00000000}; //No SDIO standard interface supported by this function; NO CSA here
    if (arg[16:9] == 8'h01) n_response[7:0] = 8'h00; // no func extention
    if (arg[16:9] == 8'h02) n_response[7:0] = 8'h00; // No power selection.
    if (arg[16:9] == 8'h04) n_response[7:0] = `VENDOR_ID_LO; 
    if (arg[16:9] == 8'h05) n_response[7:0] = `VENDOR_ID_HI; // vendor ID = 0x574, testing
    if (arg[16:9] == 8'h06) n_response[7:0] = `PRODUCT_ID_LO;
    if (arg[16:9] == 8'h07) n_response[7:0] = `PRODUCT_ID_HI; // pid = 0x8020;
    if (arg[16:9] == 8'h09) n_response[7:0] = 8'h11; // CIS addr = 0x1011 0xff
    if (arg[16:9] == 8'h0A) n_response[7:0] = 8'h10; // 
    if (arg[16:9] == 8'h0B) n_response[7:0] = 8'h00; // 
    if (arg[16:9] == 8'h10) n_response[7:0] = 8'h00; // 
    if (arg[16:9] == 8'h11) n_response[7:0] = 8'h02; // block size = 512??
    
    end


HANDLE_CIS: begin  //READ ONLY
    //n_state = SEND_RESP;
    if (i==8'd0)
        n_state = SEND_RESP;
    else
        n_state = state;
    n_i = i - 8'd1;

        if (arg[16:9] == 8'h00) n_response[7:0] = 8'h20;   // vendor id / product id
        if (arg[16:9] == 8'h01) n_response[7:0] = 8'h04;   // 4 bytes
        if (arg[16:9] == 8'h02) n_response[7:0] = `VENDOR_ID_LO;
        if (arg[16:9] == 8'h03) n_response[7:0] = `VENDOR_ID_HI;   // vendor ID = 0x574, testing
        if (arg[16:9] == 8'h04) n_response[7:0] = `PRODUCT_ID_LO;   
        if (arg[16:9] == 8'h05) n_response[7:0] = `PRODUCT_ID_HI;   // pid = 0x8020
    
        if (arg[16:9] == 8'h06) n_response[7:0] = 8'h21;   // funcID = SDIO class
        if (arg[16:9] == 8'h07) n_response[7:0] = 8'h02;   
        if (arg[16:9] == 8'h08) n_response[7:0] = 8'h0C;   
        if (arg[16:9] == 8'h09) n_response[7:0] = 8'h00;   

        if (arg[16:9] == 8'h0A) n_response[7:0] = 8'h22;   // Function Extention
        if (arg[16:9] == 8'h0B) n_response[7:0] = 8'h04;   
        if (arg[16:9] == 8'h0C) n_response[7:0] = 8'h00;   // Function 0
        if (arg[16:9] == 8'h0D) n_response[7:0] = 8'h08;   // max block size for Func 0
        if (arg[16:9] == 8'h0E) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h0F) n_response[7:0] = 8'h32;   // SPEED=25MHz (full speed)

`ifdef HIGH_SPEED_50
        if (arg[16:9] == 8'h0F) n_response[7:0] = 8'h5A;   // SPEED=50MHz (full speed)
`endif

        if (arg[16:9] == 8'h10) n_response[7:0] = 8'hFF;   // End of Function 0
        if (arg[16:9] == 8'h11) n_response[7:0] = 8'h21;   // Function 1
        if (arg[16:9] == 8'h12) n_response[7:0] = 8'h02;   //
        if (arg[16:9] == 8'h13) n_response[7:0] = 8'h0C;   //
        if (arg[16:9] == 8'h14) n_response[7:0] = 8'h00;   // ID = SDIO
        if (arg[16:9] == 8'h15) n_response[7:0] = 8'h22;   //
        if (arg[16:9] == 8'h16) n_response[7:0] = 8'h2A;   //
        if (arg[16:9] == 8'h17) n_response[7:0] = 8'h01;   //
        if (arg[16:9] == 8'h18) n_response[7:0] = 8'h00;   // NO Wake-up support
        if (arg[16:9] == 8'h19) n_response[7:0] = 8'h00;   // Not SDIO standard function
        if (arg[16:9] == 8'h1A) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h1B) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h1C) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h1D) n_response[7:0] = 8'h00;   // NO serial number  --8
        if (arg[16:9] == 8'h1E) n_response[7:0] = 8'h00;   // 
        if (arg[16:9] == 8'h1F) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h20) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h21) n_response[7:0] = 8'h00;   // CSA size=0  --C
        if (arg[16:9] == 8'h22) n_response[7:0] = 8'h00;   // CSA property = 0
        if (arg[16:9] == 8'h23) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h24) n_response[7:0] = 8'h02;   // Max Block size=512
        if (arg[16:9] == 8'h25) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h26) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h27) n_response[7:0] = 8'hFF;   //
        if (arg[16:9] == 8'h28) n_response[7:0] = 8'hFF;   // OCR register, card not busy --13
        if (arg[16:9] == 8'h29) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h2A) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h2B) n_response[7:0] = 8'h00;   // OP power
        if (arg[16:9] == 8'h2C) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h2D) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h2E) n_response[7:0] = 8'h00;   // STB power  --19
        if (arg[16:9] == 8'h2F) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h30) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h31) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h32) n_response[7:0] = 8'h00;   // BW--->0, no minimum
        if (arg[16:9] == 8'h33) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h34) n_response[7:0] = 8'h00;   // No timeout needed to get ready --1F
        if (arg[16:9] == 8'h35) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h36) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h37) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h38) n_response[7:0] = 8'h00;   // SP  PWR
        if (arg[16:9] == 8'h39) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h3A) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h3B) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h3C) n_response[7:0] = 8'h00;   // HP  PWR --27
        if (arg[16:9] == 8'h3D) n_response[7:0] = 8'h00;   // 
        if (arg[16:9] == 8'h3E) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h3F) n_response[7:0] = 8'h00;   //
        if (arg[16:9] == 8'h40) n_response[7:0] = 8'h00;   // LP PWR
        if (arg[16:9] == 8'h41) n_response[7:0] = 8'hFF;   // END
    end

HANDLE_CMD53: begin
    n_no_crc = 1'b0;      //R5 need CRC
    n_response[39:0] = 40'd0;  //clear all
    n_response[39:38] = 2'b00;      // S=0 D=0
    n_response[37:32] = 6'b110101;  // CMD53
    n_response[31:16] = 16'b0;      // stuff bits
    n_response[15:8] = 8'b0;        // NO error by default
    n_response[7:0] = 8'b0;         // stuff bits
    n_state = SEND_RESP;  

    if (bus_state != CMD) n_response[14] = 1'b1; //Command not legal for the card State.
    if (bus_state == INI || bus_state == STB || bus_state == INACTIVE)
        n_response [13:12] = 2'b00; //DIS = disabled
    if (bus_state == TRN) n_response [13:12] = 2'b10;  //TRANSFER in progress
    if (bus_state == CMD) n_response [13:12] = 2'b01;  //CMD = DAT line free
    if (bus_state != CMD) n_response [11] = 1'b1;      //if bus state is not CMD, return error

    // we use 25MHz bus speed here, so for 4bit data, it's about 100Mbps
    // 768K i2s 2channel 32bit PCM need 768e3*64 = 49.152 Mbps, about half of
    // 100Mbps
    // DSD512 2channel (48k) also need 49.152Mbps, so well under 100Mbps
    // here we simplify the design to only accept 512 byte transfer, no multi
    // block transfer,
    // so the total overhead could be:
    // total_bits = 48 (cmd) + (512*8/4+7) (data on 1 line) + 48 (response)
    // = 48*2 +1024 +7 =1127, 1024/1027 = 90% so we have about 10% overhead,
    // enough to cover 49.152Mbps audio transfer
    // n_buffer_under_run = arg[7:0];    

    //if (arg[31] == 1'b0)  n_response [11] = 1'b1;  //READ is not supported
    if (arg[30:28] != 1) begin
        n_response [11] = 1'b1;
        n_response [9]  = 1'b1;   //only func1 is allowed here
        end
    if (arg[27] == 1'b1) begin
        n_response [11] = 1'b1;
        n_response [0]  = 1'b1;   //no block write is allowed
        end

    if (arg[26] == 1'b1)  n_response [11] = 1'b1; //OP code == 1 Multi byte R/W to incrementing address not allowed
    if (arg[8:0] != 9'd0) begin
        n_response [11] = 1'b1;
        n_response [0]  = 1'b1;   //only 512 byte write is allowed
        end

    if (arg[18:9] != `SDIO_ADDR) begin
        n_response [11] = 1'b1;
        n_response [0]  = 1'b1;   //only register addr==SDIO_ADDR allowed
        end 



    if (arg[31:0] == {6'b100100, 7'd0, `SDIO_ADDR, 9'd0} && bus_state == CMD) begin
        n_use_adc_mode = 0;
        n_bus_state = TRN;
//        n_cccr_busy = 1;
        n_i = 8'd0;
        n_sd_write_start = 1'b1;    //ready for some data!
        n_state = SEND_RESP;
        n_response [11:8] = 4'h0;
        n_total_blocks = 4'd1;
        if (almost_empty && buffer_under_run<8'd199) n_buffer_under_run = buffer_under_run + 8'd1; //@@DEBUG
        if (demo < limit) n_demo = demo + 18'd1;
        if (demo == limit && (sound_card_ctrl[5] == 1'b0)) n_demo_mute = 1'b1;
        end

    // send blocks
    if (arg[31:4] == {6'b100110, 7'd0, `SDIO_ADDR, 5'd0} && bus_state == CMD) begin
        n_use_adc_mode = 0;
        n_bus_state = TRN;
//        n_cccr_busy = 1;
        n_i = 8'd0;
        n_sd_write_start = 1'b1;    //ready for some data!
        n_state = SEND_RESP;
        n_response [11:8] = 4'h0;
        n_total_blocks = arg[3:0];
        if (almost_empty && buffer_under_run<199) n_buffer_under_run = buffer_under_run + 8'd1; //@@DEBUG
        if (demo < limit) n_demo = demo + 18'd1;
        if (demo == limit && (sound_card_ctrl[5]==0)) n_demo_mute = 1'b1;
        end

    // read blocks
    if (arg[31:0] == {6'b000100, 7'd0, `SDIO_ADDR, 9'd0} && bus_state == CMD) begin
        n_use_adc_mode = 1'b1;
        n_bus_state = TRN;
        n_i = 8'd0;
        n_sd_write_start = 1'b0;    //ready for some data!
        n_sd_read_start = 1'b1;    //ready for some data!
        n_state = SEND_RESP;
        n_response[15:8] = 8'd0;   //no err
        n_response [13:12] = 2'b10; 
        n_total_blocks = 4'd1;
        if (adc_fifo_full && buffer_under_run<199) n_buffer_under_run = buffer_under_run + 8'd1; 
        end

    if (arg[31:4] == {6'b000110, 7'd0, `SDIO_ADDR, 5'd0} && bus_state == CMD) begin
        n_use_adc_mode = 1;
        n_bus_state = TRN;
        n_i = 8'd0;
        n_sd_write_start = 1'b0;    //ready for some data!
        n_sd_read_start = 1'b1;    //ready for some data!
        n_state = SEND_RESP;
        n_response[15:8] = 8'd0;   //no err
        n_response [13:12] = 2'b10; 
        n_total_blocks = arg[3:0];
        if (adc_fifo_full && buffer_under_run<199) n_buffer_under_run = buffer_under_run + 8'd1; 
        end
    end

default: n_state = INIT;

    endcase
    end

endmodule


// handling data, this one will receive 512 bytes at a time
module sd_data(
input sdclk_p,
input sdclk_n,
input rst_n,
input write_start,
input read_start,
input in_command,
input [3:0] total_blocks,
input almost_full,
input fifo_is_empty,
input [3:0] data_in,
output reg data_out_en,
output reg [3:0] data_out,

// for the FIFO
output [31:0] din,          // host output, to DAC
output reg wen,             // write_enable signal
output reg is_last_data,
output reg data_bus_busy,   //telling others the data bus us free now or not
output reg read_en,         //for reading, from ADC or other input source
input [31:0] read_data,

input  demo_mute,   //DEMO version
output reg [7:0] db
);

reg [31:0] odin;
reg [31:0] AX, n_AX;
assign din = AX;
 
reg [7:0] n_db;

reg n_data_bus_busy;
reg [31:0] n_din;
reg n_wen;
reg n_is_last_data;


reg [3:0] state, n_state;
reg [9:0] i, n_i;
reg n_data_out_en;
reg [3:0] n_data_out;

reg [3:0] dq, n_dq;
wire [3:0] data_delay;

reg [3:0]blkn, n_blkn;
reg [17:0] demo, n_demo;


//CRC16 ctrls
reg  crc_en, n_crc_en, crc_clr, n_crc_clr;
reg [3:0] bits, n_bits;
wire [15:0] crc0, crc1, crc2, crc3;
wire [15:0] crcx0, crcx1, crcx2, crcx3;
reg n_read_en;

crc16 UCRC0 (.BITVAL(bits[0]), .ENABLE(crc_en), .BITSTRB(sdclk_n), .rst_n(~crc_clr), .CRC(crc0), .CRCX(crcx0));
crc16 UCRC1 (.BITVAL(bits[1]), .ENABLE(crc_en), .BITSTRB(sdclk_n), .rst_n(~crc_clr), .CRC(crc1), .CRCX(crcx1));
crc16 UCRC2 (.BITVAL(bits[2]), .ENABLE(crc_en), .BITSTRB(sdclk_n), .rst_n(~crc_clr), .CRC(crc2), .CRCX(crcx2));
crc16 UCRC3 (.BITVAL(bits[3]), .ENABLE(crc_en), .BITSTRB(sdclk_n), .rst_n(~crc_clr), .CRC(crc3), .CRCX(crcx3));

//DELAYE #(.DEL_VALUE ("DELAY31")) UD1(.A(data_in[0]), .Z(data_delay[0]));
//DELAYE #(.DEL_VALUE ("DELAY31")) UD2(.A(data_in[1]), .Z(data_delay[1]));
//DELAYE #(.DEL_VALUE ("DELAY31")) UD3(.A(data_in[2]), .Z(data_delay[2]));
//DELAYE #(.DEL_VALUE ("DELAY31")) UD4(.A(data_in[3]), .Z(data_delay[3]));

//wire clkn;
//assign clkn = ~clk;

reg [3:0]data0;
always @(posedge sdclk_p or negedge rst_n)
    if (0==rst_n) data0 <= 0;
    else data0 <= data_in;
assign data_delay = data0;

always @(posedge sdclk_n or negedge rst_n)
    if (0==rst_n) begin
        db <= 0;
        state <= 0;
        i <= 0;
        data_out_en <= 0;
        data_out <= 0;
        dq <= 0;
        data_bus_busy <= 0;
        blkn <= 0;
       
        //FIFO
        odin <= 0; AX <= 0;
        wen <= 0;
        is_last_data <= 0;
        
        demo <= 0;
        //crc
        bits <= 0;
        crc_en <= 0;
        crc_clr <= 0;
        read_en <= 0;

        end
    else begin
        db <= n_db;
        state <= n_state;
        i <= n_i;
        data_out_en <= n_data_out_en;
        data_out <= n_data_out;
        dq <= n_dq;
        data_bus_busy <= n_data_bus_busy;
        blkn <= n_blkn;
        //FIFO
        odin <= n_din; AX <= n_AX;
        wen <= n_wen;
        is_last_data <= n_is_last_data;

        demo <= n_demo;
        //crc
        bits <= n_bits;
        crc_en <= n_crc_en;
        crc_clr <= n_crc_clr;
        read_en <= n_read_en;
        end

parameter IDLE = 4'd0;
parameter WAIT_DATA = 4'd1;
parameter READ_DATA = 4'd2;
parameter CRC_AND_RESPONSE=4'd3;
parameter DATA_BUSY = 4'd4;
parameter SD_READ = 4'd5;
parameter SD_READ_20 = 4'd6;
parameter SD_READ_30 = 4'd7;

always @(*) begin
    n_db = db;
    n_state = state;
    n_i = i;
    n_data_out_en = data_out_en;
    n_data_out = data_out;
    n_blkn = blkn;
    n_dq = dq;
    n_data_bus_busy = data_bus_busy;
    n_din = odin; n_AX = AX;
    n_wen = wen;
    n_is_last_data = is_last_data;
    n_demo = demo;

    n_bits = bits;
    n_crc_en = crc_en;
    n_crc_clr = crc_clr;
    n_read_en = read_en;
       

    case (state)

IDLE: begin
    //n_db = 8'hf0;
    n_data_bus_busy = 1'b0;
    n_i = 10'd0;
    n_data_out_en = 1'b0;  //NO output
    n_data_out = 4'b1111; //pull high
    n_dq = 4'b1111;
    n_demo = 18'd0;
  
    n_din = 32'd0;
    n_wen = 1'b0;
    n_is_last_data = 1'b0;

    n_crc_clr = 1'b1;   //reset CRC;
    n_crc_en = 1'b0;

    n_blkn = 4'd0;
    if (write_start) n_state = WAIT_DATA;
    else if (read_start) n_state = SD_READ;
    end

//==========WRITING DATA from HOST to DAC==================//

WAIT_DATA: begin
    n_dq = data_delay;
    n_data_out_en = 1'b0;  //NO output
    n_state = WAIT_DATA;

    n_data_bus_busy = 1'b1;
    if (dq == 4'b0000) begin
        n_state = READ_DATA;    //data start
        n_i = 10'd0;
        n_blkn = blkn + 4'd1;
       
        // 1st data passed!
        // begin n_db[7] = 1; n_db[3:0] = data_delay; end
        end
    end

READ_DATA: begin
    n_wen = 1'b0;
    n_is_last_data = 1'b0;

    n_dq = data_delay;
    n_i = i + 10'b1;
    // data format: S|data bits|CRC|E|ZZ, 512 bytes = 512x8 = 4096 bits 
    // each data line will receive 1024 bits

    // if (i == 10'd1022) begin n_db[7:4] = dq; n_db[3:0] = data_delay; end
    //if (i == 10'd10) begin n_db[7:4] = dq; n_db[3:0] = data_delay; end
  
    n_din = {odin[27:0], dq};

`ifdef DEMO
    if (demo_mute) n_din = 32'd0;
`endif
    if (i[2:0] == 3'b111) n_wen = 1'b1; else n_wen = 1'b0;
    if (i[2:0] == 3'b111) n_AX =  {odin[27:0], dq};
    //if (i[2:0] == 3'b111) n_AX =  32'h12345678;
     
    //if (i[2:0] == 3'b100) n_AX = 32'hff00ff00;
    //else n_AX = 32'haaaaaaaa;
    
    if (i == 10'd1023) begin
       //last bit, handle it
       // ToDo...
       //begin n_db[7] = 1; n_db[3:0] = data_delay; end
       n_is_last_data = 1'b1;
       n_state = CRC_AND_RESPONSE;
       n_i = 10'd0;
       end
    end

CRC_AND_RESPONSE: begin   //16bit CRC + 1 bit E + 2 bit Z, then SEND S+STATUS(010)+E
    n_wen = 1'b0;
    n_is_last_data = 1'b1;
    n_dq = data_delay;
    //if (i==11) n_db = {4'h0, dq};
    


    // i==16 data_delay STOP bit E
    // i==17 Z
    // i==18 Z
    // i==19 send S
    // i==20 status '0'
    // i==21 status '1'
    // i==22 status '0'
    // i==23 send E

    // i==24, 25, 26  optional?  'S0E', seems OK without this
    
    //if (i[4:0] == 5'd16) begin n_db[7] = 1'd1; n_db[3:0] = data_delay; end

    n_i[4:0] = i[4:0] + 5'd1;

    if (i[4:0] == 5'd16) begin
        n_data_out = 4'b1111;
        n_data_out_en = 1'b1;
        end
    if (i[4:0] == 5'd18) begin
        // END of CRC/E/Z/Z, ready to output response!
        n_data_out_en = 1'b1;
        n_data_out = 4'b0000; //S
        end
    if (i[4:0]==5'd19) n_data_out = 4'b0000; //0
    if (i[4:0]==5'd20) n_data_out = 4'b1111; //1
    if (i[4:0]==5'd21) n_data_out = 4'b0000; //0
    if (i[4:0]==5'd22) n_data_out = 4'b1111; //E

//    if (i[4:0]==5'd23) n_data_out_en = 0;    //free the bus
//    if (i[4:0]==5'd23) n_state = IDLE;  //back to waiting

    //try busy line
    if (i[4:0] == 5'd22) begin
        if (blkn < total_blocks) begin
            n_dq = 4'b1111;
            n_is_last_data = 1'b0;
            n_state = WAIT_DATA;
            end
        else begin
            n_state = DATA_BUSY;
            end
        n_i = 10'd0;
        //n_state = DATA_BUSY;
        end
    end

DATA_BUSY: begin
//    n_i = i+10'd1;
//    n_data_out = 4'b0000; //BUSY
//    if (n_i == 10'd1022) n_data_out = 4'b1111;  //END of BUSY
//    if (n_i == 10'd1023) n_data_out_en = 0;
//    if (n_i == 10'd1023) n_state = IDLE;
    if (almost_full) begin
        n_data_out = 4'b0000; //BUSY, wait until FIFO has more space
        end   
    else begin   // has space now!
        n_data_out = 4'b1111;
        n_i[1:0] = i[1:0] + 2'd1;
        if (i[1:0]==2'd1) n_data_out_en = 1'b0;
        if (i[1:0]==2'd1) n_state = IDLE;
        end
    end






//=================READING DATA from ADC to HOST=======================//

SD_READ: begin   // read data from ADC to host
    //n_db = 8'h0f;
    n_data_bus_busy = 1'b1;
    n_data_out = 4'b1111; //pull up data line
    n_data_out_en = 1'b1;  // send 'P'
    n_AX = read_data;
    if (fifo_is_empty || in_command) n_state = state; //wait until transfer is OK to start
    else n_i = i + 10'd1;
    if (i > 10'd3) begin
    //else begin
        n_i = 10'd0;  
        n_crc_clr = 1'b0;
        n_data_out = 4'b1111;  // 'P'
        n_bits = 4'b0000;      // 'S'
        n_data_out_en = 1'b1; 
        n_state = SD_READ_20;
        n_read_en = 1'b1;
        end
    end

SD_READ_20: begin  //send 512 bytes back to host
    n_crc_clr = 1'b0;
    n_crc_en = 1'b1;
    n_data_out = bits;
    n_data_out_en = 1'b1;
    n_bits = AX[31:28];
    n_AX = {AX[27:0], 4'd0};

    n_i = i + 10'd1;

    if (i == 10'd1023) begin
        n_i = 10'd0;
        n_blkn = blkn + 4'd1;
        n_state = SD_READ_30;
        end

    if (i[2:0] == 3'b111) begin
        n_AX = read_data;
        n_read_en = 1'b1;
        end
    else
        n_read_en = 1'b0;
    end

SD_READ_30: begin // send CRC16 back to host
    n_i[5:0] = i[5:0] + 6'd1;
    n_crc_en = 1'b0;
    n_read_en = 1'b0;

    if (i[5:0] < 6'd16) begin   //send CRC16
        n_data_out = bits;
        n_data_out_en = 1'b1;

        if (i[5:0]==6'd0) n_bits = {crcx3[15], crcx2[15], crcx1[15], crcx0[15]};
        if (i[5:0]==6'd1) n_bits = {crc3[14], crc2[14], crc1[14], crc0[14]};
        if (i[5:0]==6'd2) n_bits = {crc3[13], crc2[13], crc1[13], crc0[13]};
        if (i[5:0]==6'd3) n_bits = {crc3[12], crc2[12], crc1[12], crc0[12]};
        if (i[5:0]==6'd4) n_bits = {crc3[11], crc2[11], crc1[11], crc0[11]};
        if (i[5:0]==6'd5) n_bits = {crc3[10], crc2[10], crc1[10], crc0[10]};
        if (i[5:0]==6'd6) n_bits = {crc3[9], crc2[9], crc1[9], crc0[9]};
        if (i[5:0]==6'd7) n_bits = {crc3[8], crc2[8], crc1[8], crc0[8]};
        if (i[5:0]==6'd8) n_bits = {crc3[7], crc2[7], crc1[7], crc0[7]};
        if (i[5:0]==6'd9) n_bits = {crc3[6], crc2[6], crc1[6], crc0[6]};
        if (i[5:0]==6'd10) n_bits = {crc3[5], crc2[5], crc1[5], crc0[5]};
        if (i[5:0]==6'd11) n_bits = {crc3[4], crc2[4], crc1[4], crc0[4]};
        if (i[5:0]==6'd12) n_bits = {crc3[3], crc2[3], crc1[3], crc0[3]};
        if (i[5:0]==6'd13) n_bits = {crc3[2], crc2[2], crc1[2], crc0[2]};
        if (i[5:0]==6'd14) n_bits = {crc3[1], crc2[1], crc1[1], crc0[1]};
        if (i[5:0]==6'd15) n_bits = {crc3[0], crc2[0], crc1[0], crc0[0]};

        //n_db = crc3[15:8];
        end

    else if (i[5:0] < 6'd20) begin  //done!
        n_bits = 4'b1111;   // 'E' and 'P'
        n_data_out = bits;
        n_data_out_en = 1'b1;
        n_crc_clr = 1'b1;       // clear CRC
        n_crc_en = 1'b0;
        end
    else begin   //done with 512 bytes
        if (blkn < total_blocks) begin
            n_i = 10'd0;
            n_crc_clr = 1'b0;
            n_data_out = 4'b1111;  // 'P'
            n_bits = 4'b0000;      // 'S'
            n_data_out_en = 1'b1;
            n_state = SD_READ_20;
            // n_read_en = 1'b1;
            end
        else begin  //all blocks are read, back to idle
            n_i = 10'd0;
            n_data_out_en = 1'b0;
            n_data_out = 4'b1111;  // 'P'
            n_crc_clr = 1'b1;
            n_crc_en = 1'b0;
            n_state = IDLE;
            end
        end
    end

//default: n_state = IDLE;

    endcase
    end

endmodule





