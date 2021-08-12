module deci32_rom(
input x0,
input x1,
input x2,
input x3,
input x4,
input x5,
input x6,
input x7,
input x8,
input x9,
input y0,
input y1,
input y2,
input y3,
input y4,
input y5,
input y6,
input y7,
input y8,
input y9,
output signed [31:0] tap_left0,
output signed [31:0] tap_left1,
output signed [31:0] tap_left2,
output signed [31:0] tap_left3,
output signed [31:0] tap_left4,
output signed [31:0] tap_left5,
output signed [31:0] tap_left6,
output signed [31:0] tap_left7,
output signed [31:0] tap_left8,
output signed [31:0] tap_left9,
output signed [31:0] tap_right0,
output signed [31:0] tap_right1,
output signed [31:0] tap_right2,
output signed [31:0] tap_right3,
output signed [31:0] tap_right4,
output signed [31:0] tap_right5,
output signed [31:0] tap_right6,
output signed [31:0] tap_right7,
output signed [31:0] tap_right8,
output signed [31:0] tap_right9,
input [3:0] addr
);

wire signed [31:0] TAP128_MAP0[0:31];
wire signed [31:0] TAP128_MAP1[0:31];
wire signed [31:0] TAP128_MAP2[0:31];
wire signed [31:0] TAP128_MAP3[0:31];
wire signed [31:0] TAP128_MAP4[0:31];
wire signed [31:0] TAP128_MAP5[0:31];
wire signed [31:0] TAP128_MAP6[0:31];
wire signed [31:0] TAP128_MAP7[0:31];
wire signed [31:0] TAP128_MAP8[0:31];
wire signed [31:0] TAP128_MAP9[0:31];

assign TAP128_MAP0[0] = -131;
assign TAP128_MAP1[0] = -332;
assign TAP128_MAP2[0] = -732;
assign TAP128_MAP3[0] = -1425;
assign TAP128_MAP4[0] = -2545;
assign TAP128_MAP5[0] = -4260;
assign TAP128_MAP6[0] = -6769;
assign TAP128_MAP7[0] = -10299;
assign TAP128_MAP8[0] = -15096;
assign TAP128_MAP9[0] = -21405;
assign TAP128_MAP0[1] = -29455;
assign TAP128_MAP1[1] = -39426;
assign TAP128_MAP2[1] = -51416;
assign TAP128_MAP3[1] = -65402;
assign TAP128_MAP4[1] = -81196;
assign TAP128_MAP5[1] = -98399;
assign TAP128_MAP6[1] = -116360;
assign TAP128_MAP7[1] = -134137;
assign TAP128_MAP8[1] = -150472;
assign TAP128_MAP9[1] = -163777;
assign TAP128_MAP0[2] = -172143;
assign TAP128_MAP1[2] = -173378;
assign TAP128_MAP2[2] = -165064;
assign TAP128_MAP3[2] = -144658;
assign TAP128_MAP4[2] = -109622;
assign TAP128_MAP5[2] = -57582;
assign TAP128_MAP6[2] = 13472;
assign TAP128_MAP7[2] = 104973;
assign TAP128_MAP8[2] = 217538;
assign TAP128_MAP9[2] = 350726;
assign TAP128_MAP0[3] = 502814;
assign TAP128_MAP1[3] = 670584;
assign TAP128_MAP2[3] = 849165;
assign TAP128_MAP3[3] = 1031934;
assign TAP128_MAP4[3] = 1210494;
assign TAP128_MAP5[3] = 1374753;
assign TAP128_MAP6[3] = 1513112;
assign TAP128_MAP7[3] = 1612776;
assign TAP128_MAP8[3] = 1660189;
assign TAP128_MAP9[3] = 1641596;
assign TAP128_MAP0[4] = 1543714;
assign TAP128_MAP1[4] = 1354506;
assign TAP128_MAP2[4] = 1064026;
assign TAP128_MAP3[4] = 665303;
assign TAP128_MAP4[4] = 155232;
assign TAP128_MAP5[4] = -464585;
assign TAP128_MAP6[4] = -1187092;
assign TAP128_MAP7[4] = -1999159;
assign TAP128_MAP8[4] = -2881169;
assign TAP128_MAP9[4] = -3806833;
assign TAP128_MAP0[5] = -4743275;
assign TAP128_MAP1[5] = -5651429;
assign TAP128_MAP2[5] = -6486749;
assign TAP128_MAP3[5] = -7200243;
assign TAP128_MAP4[5] = -7739819;
assign TAP128_MAP5[5] = -8051914;
assign TAP128_MAP6[5] = -8083362;
assign TAP128_MAP7[5] = -7783439;
assign TAP128_MAP8[5] = -7106010;
assign TAP128_MAP9[5] = -6011703;
assign TAP128_MAP0[6] = -4470003;
assign TAP128_MAP1[6] = -2461189;
assign TAP128_MAP2[6] = 22004;
assign TAP128_MAP3[6] = 2973065;
assign TAP128_MAP4[6] = 6370824;
assign TAP128_MAP5[6] = 10179063;
assign TAP128_MAP6[6] = 14346668;
assign TAP128_MAP7[6] = 18808355;
assign TAP128_MAP8[6] = 23485957;
assign TAP128_MAP9[6] = 28290258;
assign TAP128_MAP0[7] = 33123321;
assign TAP128_MAP1[7] = 37881243;
assign TAP128_MAP2[7] = 42457229;
assign TAP128_MAP3[7] = 46744893;
assign TAP128_MAP4[7] = 50641647;
assign TAP128_MAP5[7] = 54052053;
assign TAP128_MAP6[7] = 56891001;
assign TAP128_MAP7[7] = 59086595;
assign TAP128_MAP8[7] = 60582611;
assign TAP128_MAP9[7] = 61340442;
assign TAP128_MAP0[8] = 61340442;
assign TAP128_MAP1[8] = 60582611;
assign TAP128_MAP2[8] = 59086595;
assign TAP128_MAP3[8] = 56891001;
assign TAP128_MAP4[8] = 54052053;
assign TAP128_MAP5[8] = 50641647;
assign TAP128_MAP6[8] = 46744893;
assign TAP128_MAP7[8] = 42457229;
assign TAP128_MAP8[8] = 37881243;
assign TAP128_MAP9[8] = 33123321;
assign TAP128_MAP0[9] = 28290258;
assign TAP128_MAP1[9] = 23485957;
assign TAP128_MAP2[9] = 18808355;
assign TAP128_MAP3[9] = 14346668;
assign TAP128_MAP4[9] = 10179063;
assign TAP128_MAP5[9] = 6370824;
assign TAP128_MAP6[9] = 2973065;
assign TAP128_MAP7[9] = 22004;
assign TAP128_MAP8[9] = -2461189;
assign TAP128_MAP9[9] = -4470003;
assign TAP128_MAP0[10] = -6011703;
assign TAP128_MAP1[10] = -7106010;
assign TAP128_MAP2[10] = -7783439;
assign TAP128_MAP3[10] = -8083362;
assign TAP128_MAP4[10] = -8051914;
assign TAP128_MAP5[10] = -7739819;
assign TAP128_MAP6[10] = -7200243;
assign TAP128_MAP7[10] = -6486749;
assign TAP128_MAP8[10] = -5651429;
assign TAP128_MAP9[10] = -4743275;
assign TAP128_MAP0[11] = -3806833;
assign TAP128_MAP1[11] = -2881169;
assign TAP128_MAP2[11] = -1999159;
assign TAP128_MAP3[11] = -1187092;
assign TAP128_MAP4[11] = -464585;
assign TAP128_MAP5[11] = 155232;
assign TAP128_MAP6[11] = 665303;
assign TAP128_MAP7[11] = 1064026;
assign TAP128_MAP8[11] = 1354506;
assign TAP128_MAP9[11] = 1543714;
assign TAP128_MAP0[12] = 1641596;
assign TAP128_MAP1[12] = 1660189;
assign TAP128_MAP2[12] = 1612776;
assign TAP128_MAP3[12] = 1513112;
assign TAP128_MAP4[12] = 1374753;
assign TAP128_MAP5[12] = 1210494;
assign TAP128_MAP6[12] = 1031934;
assign TAP128_MAP7[12] = 849165;
assign TAP128_MAP8[12] = 670584;
assign TAP128_MAP9[12] = 502814;
assign TAP128_MAP0[13] = 350726;
assign TAP128_MAP1[13] = 217538;
assign TAP128_MAP2[13] = 104973;
assign TAP128_MAP3[13] = 13472;
assign TAP128_MAP4[13] = -57582;
assign TAP128_MAP5[13] = -109622;
assign TAP128_MAP6[13] = -144658;
assign TAP128_MAP7[13] = -165064;
assign TAP128_MAP8[13] = -173378;
assign TAP128_MAP9[13] = -172143;
assign TAP128_MAP0[14] = -163777;
assign TAP128_MAP1[14] = -150472;
assign TAP128_MAP2[14] = -134137;
assign TAP128_MAP3[14] = -116360;
assign TAP128_MAP4[14] = -98399;
assign TAP128_MAP5[14] = -81196;
assign TAP128_MAP6[14] = -65402;
assign TAP128_MAP7[14] = -51416;
assign TAP128_MAP8[14] = -39426;
assign TAP128_MAP9[14] = -29455;
assign TAP128_MAP0[15] = -21405;
assign TAP128_MAP1[15] = -15096;
assign TAP128_MAP2[15] = -10299;
assign TAP128_MAP3[15] = -6769;
assign TAP128_MAP4[15] = -4260;
assign TAP128_MAP5[15] = -2545;
assign TAP128_MAP6[15] = -1425;
assign TAP128_MAP7[15] = -732;
assign TAP128_MAP8[15] = -332;
assign TAP128_MAP9[15] = -131;

wire signed [31:0]l128_0 = x0 ? TAP128_MAP0[addr] : (32'd0 - TAP128_MAP0[addr]);
wire signed [31:0]r128_0 = y0 ? TAP128_MAP0[addr] : (32'd0 - TAP128_MAP0[addr]);
assign tap_left0 = l128_0;
assign tap_right0 = r128_0;
wire signed [31:0]l128_1 = x1 ? TAP128_MAP1[addr] : (32'd0 - TAP128_MAP1[addr]);
wire signed [31:0]r128_1 = y1 ? TAP128_MAP1[addr] : (32'd0 - TAP128_MAP1[addr]);
assign tap_left1 = l128_1;
assign tap_right1 = r128_1;
wire signed [31:0]l128_2 = x2 ? TAP128_MAP2[addr] : (32'd0 - TAP128_MAP2[addr]);
wire signed [31:0]r128_2 = y2 ? TAP128_MAP2[addr] : (32'd0 - TAP128_MAP2[addr]);
assign tap_left2 = l128_2;
assign tap_right2 = r128_2;
wire signed [31:0]l128_3 = x3 ? TAP128_MAP3[addr] : (32'd0 - TAP128_MAP3[addr]);
wire signed [31:0]r128_3 = y3 ? TAP128_MAP3[addr] : (32'd0 - TAP128_MAP3[addr]);
assign tap_left3 = l128_3;
assign tap_right3 = r128_3;
wire signed [31:0]l128_4 = x4 ? TAP128_MAP4[addr] : (32'd0 - TAP128_MAP4[addr]);
wire signed [31:0]r128_4 = y4 ? TAP128_MAP4[addr] : (32'd0 - TAP128_MAP4[addr]);
assign tap_left4 = l128_4;
assign tap_right4 = r128_4;
wire signed [31:0]l128_5 = x5 ? TAP128_MAP5[addr] : (32'd0 - TAP128_MAP5[addr]);
wire signed [31:0]r128_5 = y5 ? TAP128_MAP5[addr] : (32'd0 - TAP128_MAP5[addr]);
assign tap_left5 = l128_5;
assign tap_right5 = r128_5;
wire signed [31:0]l128_6 = x6 ? TAP128_MAP6[addr] : (32'd0 - TAP128_MAP6[addr]);
wire signed [31:0]r128_6 = y6 ? TAP128_MAP6[addr] : (32'd0 - TAP128_MAP6[addr]);
assign tap_left6 = l128_6;
assign tap_right6 = r128_6;
wire signed [31:0]l128_7 = x7 ? TAP128_MAP7[addr] : (32'd0 - TAP128_MAP7[addr]);
wire signed [31:0]r128_7 = y7 ? TAP128_MAP7[addr] : (32'd0 - TAP128_MAP7[addr]);
assign tap_left7 = l128_7;
assign tap_right7 = r128_7;
wire signed [31:0]l128_8 = x8 ? TAP128_MAP8[addr] : (32'd0 - TAP128_MAP8[addr]);
wire signed [31:0]r128_8 = y8 ? TAP128_MAP8[addr] : (32'd0 - TAP128_MAP8[addr]);
assign tap_left8 = l128_8;
assign tap_right8 = r128_8;
wire signed [31:0]l128_9 = x9 ? TAP128_MAP9[addr] : (32'd0 - TAP128_MAP9[addr]);
wire signed [31:0]r128_9 = y9 ? TAP128_MAP9[addr] : (32'd0 - TAP128_MAP9[addr]);
assign tap_left9 = l128_9;
assign tap_right9 = r128_9;

endmodule

