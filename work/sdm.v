
//
//max i1-i6: 2 6 2B 15C C46 7347
//max cost: 12
// a1=7b, a2=33, a3=869, a4=169, a5=15; 
////THD=-187.573323
//b1=0x4F; b2=0x2C; b3=0x713; b4=0x156; b5=0x13;
//b6=0x2; f1=0x0; f2=0x0; f3=0xd;

//`define A1 36'h7B00000
//`define A2 36'h3300000
//`define A3 36'h869000
//`define A4 36'h169000
//`define A5 36'h15000
//`define B6 36'h2000

module pipe_sdm(
input pclk,   //45.1584MHz
input preset_n,

input signed [27:0]x0, 
input signed [27:0]x1, 
input signed [35:0]y0,
input signed [35:0]y1,

input start,
input mute,
output overflow,
output reg dsd_clk,    //for debugging, can combine dsd_clk and sdm_out to drive a DSD DAC chip
output reg sdm_out,
output reg sdm_out_n
);

parameter A1 = 36'h7B00000;
parameter A2 = 36'h3300000;
parameter A3 = 36'h869000;
parameter A4 = 36'h169000;
parameter A5 = 36'h15000;
parameter B6 = 36'h2000; 

reg reset_n;
always @* if (start == 0) reset_n = 0; else reset_n = preset_n;

reg of;
reg [27:0] buffer;
always @(posedge dsd_clk or negedge reset_n)
    if (1'b0==reset_n) begin
        buffer <= 28'hAAAAAAA;
        of <= 1'b0;
        end
    else begin
        buffer <= {sdm_out, buffer[27:1]};
        if (1'b0 == of) of <= (buffer == 28'h0 || buffer == 28'hfffffff);
        end 


//integrators
//SDM 0
reg signed [27:0] i1_0, n_i1_0;
reg signed [29:0] i2_0, n_i2_0;
reg signed [31:0] i3_0, n_i3_0;
reg signed [34:0] i4_0, n_i4_0;
reg signed [38:0] i5_0, n_i5_0;
reg signed [41:0] i6_0, n_i6_0;
//SDM 1
reg signed [27:0] i1_1, n_i1_1;
reg signed [29:0] i2_1, n_i2_1;
reg signed [31:0] i3_1, n_i3_1;
reg signed [34:0] i4_1, n_i4_1;
reg signed [38:0] i5_1, n_i5_1;
reg signed [41:0] i6_1, n_i6_1;

wire signed [29:0] i1x_0, i1x_1;
ext_i1 Uxi1_0(.i1(i1_0), .i1x(i1x_0));
ext_i1 Uxi1_1(.i1(i1_1), .i1x(i1x_1));

wire signed [31:0] i2x_0, i2x_1;
ext_i2 Uxi2_0(.i2(i2_0), .i2x(i2x_0));
ext_i2 Uxi2_1(.i2(i2_1), .i2x(i2x_1));

wire signed [34:0] i3x_0, i3x_1;
ext_i3 Uxi3_0(.i3(i3_0), .i3x(i3x_0));
ext_i3 Uxi3_1(.i3(i3_1), .i3x(i3x_1));

wire signed [38:0] i4x_0, i4x_1;
ext_i4 Uxi4_0(.i4(i4_0), .i4x(i4x_0));
ext_i4 Uxi4_1(.i4(i4_1), .i4x(i4x_1));

wire signed [41:0] i5x_0, i5x_1;
ext_i5 Uxi5_0(.i5(i5_0), .i5x(i5x_0));
ext_i5 Uxi5_1(.i5(i5_1), .i5x(i5x_1));

//costs
reg signed [35:0] cost_0, n_cost_0; // SDM 0
reg signed [35:0] cost_1, n_cost_1; // SDM 1
//reg signed [35:0] db;

reg state, n_state;
reg [1:0] i, n_i;
reg symbol_out, n_symbol_out;
reg dsdck, n_dsdck;

// jitter reduction, use master_clk to buffer sdm_out
always @(posedge pclk or negedge reset_n)
    if (reset_n == 0) begin
        sdm_out <= 0;
        sdm_out_n <= 0;
        dsd_clk <= 0;
        end
    else begin
        sdm_out <= symbol_out;
        sdm_out_n <= ~sdm_out;
        dsd_clk <= dsdck;
        end

//multipliers:
wire signed [35:0] mul_i1_a1_0, mul_i1_a1_1;
mi1a1 Um1a1(.a1(A1), .i1_0(i1_0[27:12]), .i1_1(i1_1[27:12]), .o1(mul_i1_a1_0), .o2(mul_i1_a1_1));

wire signed [35:0] mul_i2_a2_0, mul_i2_a2_1;
mi2a2 Um2a2(.a2(A2), .i2_0(i2_0[29:12]), .i2_1(i2_1[29:12]), .o1(mul_i2_a2_0), .o2(mul_i2_a2_1));

wire signed [35:0] mul_i3_a3_0, mul_i3_a3_1;
mi3a3 Um3a3(.a3(A3), .i3_0(i3_0[31:12]), .i3_1(i3_1[31:12]), .o1(mul_i3_a3_0), .o2(mul_i3_a3_1));

wire signed [35:0] mul_i4_a4_0, mul_i4_a4_1;
mi4a4 Um4a4(.a4(A4), .i4_0(i4_0[34:12]), .i4_1(i4_1[34:12]), .o1(mul_i4_a4_0), .o2(mul_i4_a4_1));

wire signed [35:0] mul_i5_a5_0, mul_i5_a5_1;
mi5a5 Um5a5(.a5(A5), .i5_0(i5_0[38:12]), .i5_1(i5_1[38:12]), .o1(mul_i5_a5_0), .o2(mul_i5_a5_1));

wire signed [35:0] mul_i6_b6_0, mul_i6_b6_1;
mi6b6 Um6b6(.b6(B6), .i6_0(i6_0[41:12]), .i6_1(i6_1[41:12]), .o1(mul_i6_b6_0), .o2(mul_i6_b6_1));

// abs(cost)
wire signed [11:0] abs_cost_0, abs_cost_1;
abs_cost Uabs1(.cost(cost_0), .ocost(abs_cost_0));
abs_cost Uabs2(.cost(cost_1), .ocost(abs_cost_1));


/////// SDM512 FSM ////////
always @(posedge pclk or negedge reset_n)
    if (reset_n == 0) begin
        state <= 0;
        i <= 0;
        i1_0 <= 0; i1_1 <= 0;
        i2_0 <= 0; i2_1 <= 0;
        i3_0 <= 0; i3_1 <= 0;
        i4_0 <= 0; i4_1 <= 0;
        i5_0 <= 0; i5_1 <= 0;
        i6_0 <= 0; i6_1 <= 0;
        cost_0 <= 0; cost_1 <= 0;
        symbol_out <= 0;
        dsdck <= 0;
        end
    else begin
        state <= n_state;
        i <= n_i;
        i1_0 <= n_i1_0;  i1_1 <= n_i1_1;
        i2_0 <= n_i2_0;  i2_1 <= n_i2_1;
        i3_0 <= n_i3_0;  i3_1 <= n_i3_1;
        i4_0 <= n_i4_0;  i4_1 <= n_i4_1;
        i5_0 <= n_i5_0;  i5_1 <= n_i5_1;
        i6_0 <= n_i6_0;  i6_1 <= n_i6_1;
        cost_0 <= n_cost_0;   cost_1 <= n_cost_1;
        symbol_out <= n_symbol_out;
        dsdck <= n_dsdck;
        end

parameter PIPE_SDM_00 = 1'b0;
parameter PIPE_SDM_10 = 1'b1;

always @* begin
    n_state = state;
    n_i = i;
    n_dsdck = ~dsdck;
    n_symbol_out = symbol_out; 
    n_i1_0 = i1_0; n_i1_1 = i1_1;
    n_i2_0 = i2_0; n_i2_1 = i2_1;
    n_i3_0 = i3_0; n_i3_1 = i3_1;
    n_i4_0 = i4_0; n_i4_1 = i4_1;
    n_i5_0 = i5_0; n_i5_1 = i5_1;
    n_i6_0 = i6_0; n_i6_1 = i6_1;
    n_cost_0 = cost_0; n_cost_1 = cost_1;
    case(state)
PIPE_SDM_00: begin
    #1 if (start == 0 || mute == 1) begin
        #1 n_i[1:0] = i[1:0] + 2'h1;
        #1 n_symbol_out = i[1];             //sending mute
        #1 n_i1_0 = 0;  n_i1_1 = 0;
        #1 n_i2_0 = 0;  n_i2_1 = 0;
        #1 n_i3_0 = 0;  n_i3_1 = 0;
        #1 n_i4_0 = 0;  n_i4_1 = 0;
        #1 n_i5_0 = 0;  n_i5_1 = 0;
        #1 n_i6_0 = 0;  n_i6_1 = 0;
        #1 n_cost_0 = 0; n_cost_1 = 0;
        end
    else begin
        #1 n_i1_0 = i1_0 + x1;
        #1 n_i1_1 = i1_1 + x0;
        #1 n_i2_0 = i2_0 + i1x_0;
        #1 n_i2_1 = i2_1 + i1x_1;
        #1 n_i3_0 = i3_0 + i2x_0;
        #1 n_i3_1 = i3_1 + i2x_1;
        #1 n_i4_0 = i4_0 + i3x_0;
        #1 n_i4_1 = i4_1 + i3x_1;
        #1 n_i5_0 = i5_0 + i4x_0;
        #1 n_i5_1 = i5_1 + i4x_1;
        #1 n_i6_0 = i6_0 + i5x_0;
        #1 n_i6_1 = i6_1 + i5x_1;

        #1 n_cost_0 = mul_i1_a1_0 + mul_i2_a2_0 + mul_i3_a3_0 + mul_i4_a4_0 + mul_i5_a5_0 + mul_i6_b6_0 + y1;
        #1 n_cost_1 = mul_i1_a1_1 + mul_i2_a2_1 + mul_i3_a3_1 + mul_i4_a4_1 + mul_i5_a5_1 + mul_i6_b6_1 + y0;

        #1 n_state = PIPE_SDM_10;

        //#1 db = mul_i1_a1_1;
        //#10 $display("@@@@= 111 %d %d %d %d", x0, x1, y0, y1);  
        //#100 $display("#1  I1=%d I2=%d I3=%d I4=%d I5=%d I6=%d",
        //    n_i1_0, n_i2_0,n_i3_0,n_i4_0,n_i5_0,n_i6_0);  
        //#10 $display("#2  I1=%d I2=%d I3=%d I4=%d I5=%d I6=%d",
        //    n_i1_1, n_i2_1,n_i3_1,n_i4_1,n_i5_1,n_i6_1);  
        //#10 $display("NCOST %d %d %d %d", n_cost_0, n_cost_1, y1, y0);
        //#10 $display("MUL1: i1 %d m1 %d i2 %d m2 %d", i1_0, mul_i1_a1_0, i2_0,  mul_i2_a2_0);
        //#10 $display("MUL2: i1 %d m1 %d i2 %d m2 %d", i1_1, mul_i1_a1_1, i2_1,  mul_i2_a2_0);
        //#10 $display("db: %d ", db);

//        #100 if (symbol_out) 
//                 $display("@@@@=%d",  32000);   //must delay to allow logic settle
//            else
//                 $display("@@@@=%d",  -32000);   //must delay to allow logic settle
        end

    end

PIPE_SDM_10: begin
    #1 n_state = PIPE_SDM_00;
//    #10 $display("COST=%d %d", abs_cost_0, abs_cost_1);  
    #1 if (abs_cost_0 <= abs_cost_1) begin
        #1 n_i1_1 = i1_0;
        #1 n_i2_1 = i2_0;
        #1 n_i3_1 = i3_0;
        #1 n_i4_1 = i4_0;
        #1 n_i5_1 = i5_0;
        #1 n_i6_1 = i6_0;
        #1 n_symbol_out = 1;
        end
    else begin
        #1 n_i1_0 = i1_1;
        #1 n_i2_0 = i2_1;
        #1 n_i3_0 = i3_1;
        #1 n_i4_0 = i4_1;
        #1 n_i5_0 = i5_1;
        #1 n_i6_0 = i6_1;
        #1 n_symbol_out = 0;
        end
    end
    endcase
    end

endmodule


//calculate abs(cost)

module abs_cost(
input signed [35:0] cost,
output signed [11:0] ocost
);

wire signed [35:0] y;
assign y = cost[35] ?   36'h0 - cost : cost;
assign ocost = y[35:24];

endmodule


//a1=7b, a2=33, a3=869, a4=169, a5=15;

// MUL(i1,a1)
module mi1a1(
input signed[35:0] a1,
input signed[27:12] i1_0,
input signed[27:12] i1_1,
output signed [35:0] o1,
output signed [35:0] o2
);

reg signed [35:0] mul_i1_0_a1; /* synthesis syn_multstyle="logic" */
reg signed [35:0] mul_i1_1_a1; /* synthesis syn_multstyle="logic" */
reg signed [15:0] t100, t101;
reg signed [19:0] ta1;
always @* begin
    ta1 =  {a1[31:12]};
    t100 = {i1_0[27:12]};
    t101 = {i1_1[27:12]};
    #1 mul_i1_0_a1 = t100 * ta1;
    #1 mul_i1_1_a1 = t101 * ta1;
    end

assign o1 = mul_i1_0_a1;
assign o2 = mul_i1_1_a1;
endmodule


//MUL(i2, a2)
module mi2a2(
input signed[35:0] a2,
input signed[29:12] i2_0,
input signed[29:12] i2_1,
output signed [35:0] o1,
output signed [35:0] o2
);

reg signed [35:0] mul_i2_0_a2; /* synthesis syn_multstyle="logic" */
reg signed [35:0] mul_i2_1_a2; /* synthesis syn_multstyle="logic" */
reg signed [17:0] t200, t201;
reg signed [17:0] ta2;
always @* begin
    ta2 =  {a2[29:12]};
    t200 = {i2_0[29:12]};
    t201 = {i2_1[29:12]};
    #1 mul_i2_0_a2 = t200 * ta2;
    #1 mul_i2_1_a2 = t201 * ta2;
    end

assign o1 = mul_i2_0_a2;
assign o2 = mul_i2_1_a2;
endmodule


//MUL(i3, a3)
module mi3a3(
input signed [35:0] a3,
input signed[31:12] i3_0,
input signed[31:12] i3_1,
output signed [35:0] o1,
output signed [35:0] o2
);

reg signed [35:0] mul_i3_0_a3; /* synthesis syn_multstyle="logic" */
reg signed [35:0] mul_i3_1_a3; /* synthesis syn_multstyle="logic" */
reg signed [19:0] t300, t301;
reg signed [15:0] ta3;
always @* begin
    ta3 =  {a3[27:12]};
    t300 = {i3_0[31:12]};
    t301 = {i3_1[31:12]};
    #1 mul_i3_0_a3 = t300 * ta3;
    #1 mul_i3_1_a3 = t301 * ta3;
    end

assign o1 = mul_i3_0_a3;
assign o2 = mul_i3_1_a3;
endmodule

//MUL(i4, a4)
module mi4a4(
input signed [35:0] a4,
input signed[34:12] i4_0,
input signed[34:12] i4_1,
output signed [35:0] o1,
output signed [35:0] o2
);


reg signed [35:0] mul_i4_0_a4; /* synthesis syn_multstyle="logic" */
reg signed [35:0] mul_i4_1_a4; /* synthesis syn_multstyle="logic" */
reg signed [22:0] t400, t401;
reg signed [12:0] ta4;
always @* begin
    ta4 =  {a4[24:12]};
    t400 = {i4_0[34:12]};
    t401 = {i4_1[34:12]};
    #1 mul_i4_0_a4 = t400 * ta4;
    #1 mul_i4_1_a4 = t401 * ta4;
    end

assign o1 = mul_i4_0_a4;
assign o2 = mul_i4_1_a4;
endmodule

//MUL(i5, a5)
module mi5a5(
input signed [35:0] a5,
input signed[38:12] i5_0,
input signed[38:12] i5_1,
output signed [35:0] o1,
output signed [35:0] o2
);

reg signed [35:0] mul_i5_0_a5; /* synthesis syn_multstyle="logic" */
reg signed [35:0] mul_i5_1_a5; /* synthesis syn_multstyle="logic" */
reg signed [26:0] t500, t501;
reg signed [8:0] ta5;
always @* begin
    ta5 =  {a5[20:12]};
    t500 = {i5_0[38:12]};
    t501 = {i5_1[38:12]};
    #1 mul_i5_0_a5 = t500 * ta5;
    #1 mul_i5_1_a5 = t501 * ta5;
    end

assign o1 = mul_i5_0_a5;
assign o2 = mul_i5_1_a5;
endmodule


//MUL(i6, b6)
module mi6b6(
input signed [35:0] b6, 
input signed[41:12] i6_0,
input signed[41:12] i6_1,
output signed [35:0] o1,
output signed [35:0] o2
);

reg signed [35:0] mul_i6_0_b6; /* synthesis syn_multstyle="logic" */
reg signed [35:0] mul_i6_1_b6; /* synthesis syn_multstyle="logic" */

reg signed [29:0] t600, t601;
reg signed [5:0] tb6;
always @* begin
    tb6 =  {b6[17:12]};
    t600 = {i6_0[41:12]};
    t601 = {i6_1[41:12]};
    #1 mul_i6_0_b6 = t600 * tb6;
    #1 mul_i6_1_b6 = t601 * tb6;
    end

assign o1 = mul_i6_0_b6;
assign o2 = mul_i6_1_b6;
endmodule


////bit extensions...../////
module ext_i1(input signed [27:0]i1, output signed [29:0] i1x);
   assign i1x = i1[27]? {2'b11, i1}: {2'b00, i1};
endmodule

module ext_i2(input signed [29:0]i2, output signed [31:0] i2x);
   assign i2x = i2[29]? {2'b11, i2}: {2'b00, i2};
endmodule

module ext_i3(input signed [31:0]i3, output signed [34:0] i3x);
   assign i3x = i3[31]? {3'b111, i3}: {3'b000, i3};
endmodule

module ext_i4(input signed [34:0]i4, output signed [38:0] i4x);
   assign i4x = i4[34]? {4'b1111, i4}: {4'b0000, i4};
endmodule

module ext_i5(input signed [38:0]i5, output signed [41:0] i5x);
   assign i5x = i5[38]? {3'b111, i5}: {3'b000, i5};
endmodule

















