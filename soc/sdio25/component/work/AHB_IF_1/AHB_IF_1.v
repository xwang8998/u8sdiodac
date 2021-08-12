//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Wed Aug 23 16:41:21 2017
// Version: v11.8 11.8.0.26
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// AHB_IF_1
module AHB_IF_1(
    // Inputs
    HADDR_M0,
    HBURST_M0,
    HCLK,
    HMASTLOCK_M0,
    HPROT_M0,
    HRDATA_S0,
    HRDATA_S1,
    HRDATA_S2,
    HRDATA_S3,
    HRDATA_S4,
    HRDATA_S5,
    HRDATA_S6,
    HRDATA_S7,
    HREADYOUT_S0,
    HREADYOUT_S1,
    HREADYOUT_S2,
    HREADYOUT_S3,
    HREADYOUT_S4,
    HREADYOUT_S5,
    HREADYOUT_S6,
    HREADYOUT_S7,
    HRESETN,
    HRESP_S0,
    HRESP_S1,
    HRESP_S2,
    HRESP_S3,
    HRESP_S4,
    HRESP_S5,
    HRESP_S6,
    HRESP_S7,
    HSIZE_M0,
    HTRANS_M0,
    HWDATA_M0,
    HWRITE_M0,
    REMAP_M0,
    // Outputs
    HADDR_S0,
    HADDR_S1,
    HADDR_S2,
    HADDR_S3,
    HADDR_S4,
    HADDR_S5,
    HADDR_S6,
    HADDR_S7,
    HBURST_S0,
    HBURST_S1,
    HBURST_S2,
    HBURST_S3,
    HBURST_S4,
    HBURST_S5,
    HBURST_S6,
    HBURST_S7,
    HMASTLOCK_S0,
    HMASTLOCK_S1,
    HMASTLOCK_S2,
    HMASTLOCK_S3,
    HMASTLOCK_S4,
    HMASTLOCK_S5,
    HMASTLOCK_S6,
    HMASTLOCK_S7,
    HPROT_S0,
    HPROT_S1,
    HPROT_S2,
    HPROT_S3,
    HPROT_S4,
    HPROT_S5,
    HPROT_S6,
    HPROT_S7,
    HRDATA_M0,
    HREADY_M0,
    HREADY_S0,
    HREADY_S1,
    HREADY_S2,
    HREADY_S3,
    HREADY_S4,
    HREADY_S5,
    HREADY_S6,
    HREADY_S7,
    HRESP_M0,
    HSEL_S0,
    HSEL_S1,
    HSEL_S2,
    HSEL_S3,
    HSEL_S4,
    HSEL_S5,
    HSEL_S6,
    HSEL_S7,
    HSIZE_S0,
    HSIZE_S1,
    HSIZE_S2,
    HSIZE_S3,
    HSIZE_S4,
    HSIZE_S5,
    HSIZE_S6,
    HSIZE_S7,
    HTRANS_S0,
    HTRANS_S1,
    HTRANS_S2,
    HTRANS_S3,
    HTRANS_S4,
    HTRANS_S5,
    HTRANS_S6,
    HTRANS_S7,
    HWDATA_S0,
    HWDATA_S1,
    HWDATA_S2,
    HWDATA_S3,
    HWDATA_S4,
    HWDATA_S5,
    HWDATA_S6,
    HWDATA_S7,
    HWRITE_S0,
    HWRITE_S1,
    HWRITE_S2,
    HWRITE_S3,
    HWRITE_S4,
    HWRITE_S5,
    HWRITE_S6,
    HWRITE_S7
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [31:0] HADDR_M0;
input  [2:0]  HBURST_M0;
input         HCLK;
input         HMASTLOCK_M0;
input  [3:0]  HPROT_M0;
input  [31:0] HRDATA_S0;
input  [31:0] HRDATA_S1;
input  [31:0] HRDATA_S2;
input  [31:0] HRDATA_S3;
input  [31:0] HRDATA_S4;
input  [31:0] HRDATA_S5;
input  [31:0] HRDATA_S6;
input  [31:0] HRDATA_S7;
input         HREADYOUT_S0;
input         HREADYOUT_S1;
input         HREADYOUT_S2;
input         HREADYOUT_S3;
input         HREADYOUT_S4;
input         HREADYOUT_S5;
input         HREADYOUT_S6;
input         HREADYOUT_S7;
input         HRESETN;
input  [1:0]  HRESP_S0;
input  [1:0]  HRESP_S1;
input  [1:0]  HRESP_S2;
input  [1:0]  HRESP_S3;
input  [1:0]  HRESP_S4;
input  [1:0]  HRESP_S5;
input  [1:0]  HRESP_S6;
input  [1:0]  HRESP_S7;
input  [2:0]  HSIZE_M0;
input  [1:0]  HTRANS_M0;
input  [31:0] HWDATA_M0;
input         HWRITE_M0;
input         REMAP_M0;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] HADDR_S0;
output [31:0] HADDR_S1;
output [31:0] HADDR_S2;
output [31:0] HADDR_S3;
output [31:0] HADDR_S4;
output [31:0] HADDR_S5;
output [31:0] HADDR_S6;
output [31:0] HADDR_S7;
output [2:0]  HBURST_S0;
output [2:0]  HBURST_S1;
output [2:0]  HBURST_S2;
output [2:0]  HBURST_S3;
output [2:0]  HBURST_S4;
output [2:0]  HBURST_S5;
output [2:0]  HBURST_S6;
output [2:0]  HBURST_S7;
output        HMASTLOCK_S0;
output        HMASTLOCK_S1;
output        HMASTLOCK_S2;
output        HMASTLOCK_S3;
output        HMASTLOCK_S4;
output        HMASTLOCK_S5;
output        HMASTLOCK_S6;
output        HMASTLOCK_S7;
output [3:0]  HPROT_S0;
output [3:0]  HPROT_S1;
output [3:0]  HPROT_S2;
output [3:0]  HPROT_S3;
output [3:0]  HPROT_S4;
output [3:0]  HPROT_S5;
output [3:0]  HPROT_S6;
output [3:0]  HPROT_S7;
output [31:0] HRDATA_M0;
output        HREADY_M0;
output        HREADY_S0;
output        HREADY_S1;
output        HREADY_S2;
output        HREADY_S3;
output        HREADY_S4;
output        HREADY_S5;
output        HREADY_S6;
output        HREADY_S7;
output [1:0]  HRESP_M0;
output        HSEL_S0;
output        HSEL_S1;
output        HSEL_S2;
output        HSEL_S3;
output        HSEL_S4;
output        HSEL_S5;
output        HSEL_S6;
output        HSEL_S7;
output [2:0]  HSIZE_S0;
output [2:0]  HSIZE_S1;
output [2:0]  HSIZE_S2;
output [2:0]  HSIZE_S3;
output [2:0]  HSIZE_S4;
output [2:0]  HSIZE_S5;
output [2:0]  HSIZE_S6;
output [2:0]  HSIZE_S7;
output [1:0]  HTRANS_S0;
output [1:0]  HTRANS_S1;
output [1:0]  HTRANS_S2;
output [1:0]  HTRANS_S3;
output [1:0]  HTRANS_S4;
output [1:0]  HTRANS_S5;
output [1:0]  HTRANS_S6;
output [1:0]  HTRANS_S7;
output [31:0] HWDATA_S0;
output [31:0] HWDATA_S1;
output [31:0] HWDATA_S2;
output [31:0] HWDATA_S3;
output [31:0] HWDATA_S4;
output [31:0] HWDATA_S5;
output [31:0] HWDATA_S6;
output [31:0] HWDATA_S7;
output        HWRITE_S0;
output        HWRITE_S1;
output        HWRITE_S2;
output        HWRITE_S3;
output        HWRITE_S4;
output        HWRITE_S5;
output        HWRITE_S6;
output        HWRITE_S7;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [31:0] HADDR_M0;
wire   [2:0]  HBURST_M0;
wire          HMASTLOCK_M0;
wire   [3:0]  HPROT_M0;
wire   [31:0] AHBmmaster0_HRDATA;
wire          AHBmmaster0_HREADY;
wire   [1:0]  AHBmmaster0_HRESP;
wire   [2:0]  HSIZE_M0;
wire   [1:0]  HTRANS_M0;
wire   [31:0] HWDATA_M0;
wire          HWRITE_M0;
wire   [31:0] AHBmslave0_HADDR;
wire   [2:0]  AHBmslave0_HBURST;
wire          AHBmslave0_HMASTLOCK;
wire   [3:0]  AHBmslave0_HPROT;
wire   [31:0] HRDATA_S0;
wire          AHBmslave0_HREADY;
wire          HREADYOUT_S0;
wire   [1:0]  HRESP_S0;
wire          AHBmslave0_HSELx;
wire   [2:0]  AHBmslave0_HSIZE;
wire   [1:0]  AHBmslave0_HTRANS;
wire   [31:0] AHBmslave0_HWDATA;
wire          AHBmslave0_HWRITE;
wire   [31:0] AHBmslave1_HADDR;
wire   [2:0]  AHBmslave1_HBURST;
wire          AHBmslave1_HMASTLOCK;
wire   [3:0]  AHBmslave1_HPROT;
wire   [31:0] HRDATA_S1;
wire          AHBmslave1_HREADY;
wire          HREADYOUT_S1;
wire   [1:0]  HRESP_S1;
wire          AHBmslave1_HSELx;
wire   [2:0]  AHBmslave1_HSIZE;
wire   [1:0]  AHBmslave1_HTRANS;
wire   [31:0] AHBmslave1_HWDATA;
wire          AHBmslave1_HWRITE;
wire   [31:0] AHBmslave2_HADDR;
wire   [2:0]  AHBmslave2_HBURST;
wire          AHBmslave2_HMASTLOCK;
wire   [3:0]  AHBmslave2_HPROT;
wire   [31:0] HRDATA_S2;
wire          AHBmslave2_HREADY;
wire          HREADYOUT_S2;
wire   [1:0]  HRESP_S2;
wire          AHBmslave2_HSELx;
wire   [2:0]  AHBmslave2_HSIZE;
wire   [1:0]  AHBmslave2_HTRANS;
wire   [31:0] AHBmslave2_HWDATA;
wire          AHBmslave2_HWRITE;
wire   [31:0] AHBmslave3_HADDR;
wire   [2:0]  AHBmslave3_HBURST;
wire          AHBmslave3_HMASTLOCK;
wire   [3:0]  AHBmslave3_HPROT;
wire   [31:0] HRDATA_S3;
wire          AHBmslave3_HREADY;
wire          HREADYOUT_S3;
wire   [1:0]  HRESP_S3;
wire          AHBmslave3_HSELx;
wire   [2:0]  AHBmslave3_HSIZE;
wire   [1:0]  AHBmslave3_HTRANS;
wire   [31:0] AHBmslave3_HWDATA;
wire          AHBmslave3_HWRITE;
wire   [31:0] AHBmslave4_HADDR;
wire   [2:0]  AHBmslave4_HBURST;
wire          AHBmslave4_HMASTLOCK;
wire   [3:0]  AHBmslave4_HPROT;
wire   [31:0] HRDATA_S4;
wire          AHBmslave4_HREADY;
wire          HREADYOUT_S4;
wire   [1:0]  HRESP_S4;
wire          AHBmslave4_HSELx;
wire   [2:0]  AHBmslave4_HSIZE;
wire   [1:0]  AHBmslave4_HTRANS;
wire   [31:0] AHBmslave4_HWDATA;
wire          AHBmslave4_HWRITE;
wire   [31:0] AHBmslave5_HADDR;
wire   [2:0]  AHBmslave5_HBURST;
wire          AHBmslave5_HMASTLOCK;
wire   [3:0]  AHBmslave5_HPROT;
wire   [31:0] HRDATA_S5;
wire          AHBmslave5_HREADY;
wire          HREADYOUT_S5;
wire   [1:0]  HRESP_S5;
wire          AHBmslave5_HSELx;
wire   [2:0]  AHBmslave5_HSIZE;
wire   [1:0]  AHBmslave5_HTRANS;
wire   [31:0] AHBmslave5_HWDATA;
wire          AHBmslave5_HWRITE;
wire   [31:0] AHBmslave6_HADDR;
wire   [2:0]  AHBmslave6_HBURST;
wire          AHBmslave6_HMASTLOCK;
wire   [3:0]  AHBmslave6_HPROT;
wire   [31:0] HRDATA_S6;
wire          AHBmslave6_HREADY;
wire          HREADYOUT_S6;
wire   [1:0]  HRESP_S6;
wire          AHBmslave6_HSELx;
wire   [2:0]  AHBmslave6_HSIZE;
wire   [1:0]  AHBmslave6_HTRANS;
wire   [31:0] AHBmslave6_HWDATA;
wire          AHBmslave6_HWRITE;
wire   [31:0] AHBmslave7_HADDR;
wire   [2:0]  AHBmslave7_HBURST;
wire          AHBmslave7_HMASTLOCK;
wire   [3:0]  AHBmslave7_HPROT;
wire   [31:0] HRDATA_S7;
wire          AHBmslave7_HREADY;
wire          HREADYOUT_S7;
wire   [1:0]  HRESP_S7;
wire          AHBmslave7_HSELx;
wire   [2:0]  AHBmslave7_HSIZE;
wire   [1:0]  AHBmslave7_HTRANS;
wire   [31:0] AHBmslave7_HWDATA;
wire          AHBmslave7_HWRITE;
wire          HCLK;
wire          HRESETN;
wire          REMAP_M0;
wire   [31:0] AHBmmaster0_HRDATA_net_0;
wire          AHBmmaster0_HREADY_net_0;
wire   [1:0]  AHBmmaster0_HRESP_net_0;
wire   [31:0] AHBmslave0_HADDR_net_0;
wire   [1:0]  AHBmslave0_HTRANS_net_0;
wire          AHBmslave0_HWRITE_net_0;
wire   [2:0]  AHBmslave0_HSIZE_net_0;
wire   [31:0] AHBmslave0_HWDATA_net_0;
wire          AHBmslave0_HSELx_net_0;
wire          AHBmslave0_HREADY_net_0;
wire          AHBmslave0_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave0_HBURST_net_0;
wire   [3:0]  AHBmslave0_HPROT_net_0;
wire   [31:0] AHBmslave1_HADDR_net_0;
wire   [1:0]  AHBmslave1_HTRANS_net_0;
wire          AHBmslave1_HWRITE_net_0;
wire   [2:0]  AHBmslave1_HSIZE_net_0;
wire   [31:0] AHBmslave1_HWDATA_net_0;
wire          AHBmslave1_HSELx_net_0;
wire          AHBmslave1_HREADY_net_0;
wire          AHBmslave1_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave1_HBURST_net_0;
wire   [3:0]  AHBmslave1_HPROT_net_0;
wire   [31:0] AHBmslave2_HADDR_net_0;
wire   [1:0]  AHBmslave2_HTRANS_net_0;
wire          AHBmslave2_HWRITE_net_0;
wire   [2:0]  AHBmslave2_HSIZE_net_0;
wire   [31:0] AHBmslave2_HWDATA_net_0;
wire          AHBmslave2_HSELx_net_0;
wire          AHBmslave2_HREADY_net_0;
wire          AHBmslave2_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave2_HBURST_net_0;
wire   [3:0]  AHBmslave2_HPROT_net_0;
wire   [31:0] AHBmslave3_HADDR_net_0;
wire   [1:0]  AHBmslave3_HTRANS_net_0;
wire          AHBmslave3_HWRITE_net_0;
wire   [2:0]  AHBmslave3_HSIZE_net_0;
wire   [31:0] AHBmslave3_HWDATA_net_0;
wire          AHBmslave3_HSELx_net_0;
wire          AHBmslave3_HREADY_net_0;
wire          AHBmslave3_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave3_HBURST_net_0;
wire   [3:0]  AHBmslave3_HPROT_net_0;
wire   [31:0] AHBmslave4_HADDR_net_0;
wire   [1:0]  AHBmslave4_HTRANS_net_0;
wire          AHBmslave4_HWRITE_net_0;
wire   [2:0]  AHBmslave4_HSIZE_net_0;
wire   [31:0] AHBmslave4_HWDATA_net_0;
wire          AHBmslave4_HSELx_net_0;
wire          AHBmslave4_HREADY_net_0;
wire          AHBmslave4_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave4_HBURST_net_0;
wire   [3:0]  AHBmslave4_HPROT_net_0;
wire   [31:0] AHBmslave5_HADDR_net_0;
wire   [1:0]  AHBmslave5_HTRANS_net_0;
wire          AHBmslave5_HWRITE_net_0;
wire   [2:0]  AHBmslave5_HSIZE_net_0;
wire   [31:0] AHBmslave5_HWDATA_net_0;
wire          AHBmslave5_HSELx_net_0;
wire          AHBmslave5_HREADY_net_0;
wire          AHBmslave5_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave5_HBURST_net_0;
wire   [3:0]  AHBmslave5_HPROT_net_0;
wire   [31:0] AHBmslave6_HADDR_net_0;
wire   [1:0]  AHBmslave6_HTRANS_net_0;
wire          AHBmslave6_HWRITE_net_0;
wire   [2:0]  AHBmslave6_HSIZE_net_0;
wire   [31:0] AHBmslave6_HWDATA_net_0;
wire          AHBmslave6_HSELx_net_0;
wire          AHBmslave6_HREADY_net_0;
wire          AHBmslave6_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave6_HBURST_net_0;
wire   [3:0]  AHBmslave6_HPROT_net_0;
wire   [31:0] AHBmslave7_HADDR_net_0;
wire   [1:0]  AHBmslave7_HTRANS_net_0;
wire          AHBmslave7_HWRITE_net_0;
wire   [2:0]  AHBmslave7_HSIZE_net_0;
wire   [31:0] AHBmslave7_HWDATA_net_0;
wire          AHBmslave7_HSELx_net_0;
wire          AHBmslave7_HREADY_net_0;
wire          AHBmslave7_HMASTLOCK_net_0;
wire   [2:0]  AHBmslave7_HBURST_net_0;
wire   [3:0]  AHBmslave7_HPROT_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire   [31:0] HADDR_M1_const_net_0;
wire   [1:0]  HTRANS_M1_const_net_0;
wire          GND_net;
wire   [2:0]  HSIZE_M1_const_net_0;
wire   [2:0]  HBURST_M1_const_net_0;
wire   [3:0]  HPROT_M1_const_net_0;
wire   [31:0] HWDATA_M1_const_net_0;
wire   [31:0] HADDR_M2_const_net_0;
wire   [1:0]  HTRANS_M2_const_net_0;
wire   [2:0]  HSIZE_M2_const_net_0;
wire   [2:0]  HBURST_M2_const_net_0;
wire   [3:0]  HPROT_M2_const_net_0;
wire   [31:0] HWDATA_M2_const_net_0;
wire   [31:0] HADDR_M3_const_net_0;
wire   [1:0]  HTRANS_M3_const_net_0;
wire   [2:0]  HSIZE_M3_const_net_0;
wire   [2:0]  HBURST_M3_const_net_0;
wire   [3:0]  HPROT_M3_const_net_0;
wire   [31:0] HWDATA_M3_const_net_0;
wire   [31:0] HRDATA_S8_const_net_0;
wire          VCC_net;
wire   [1:0]  HRESP_S8_const_net_0;
wire   [31:0] HRDATA_S9_const_net_0;
wire   [1:0]  HRESP_S9_const_net_0;
wire   [31:0] HRDATA_S10_const_net_0;
wire   [1:0]  HRESP_S10_const_net_0;
wire   [31:0] HRDATA_S11_const_net_0;
wire   [1:0]  HRESP_S11_const_net_0;
wire   [31:0] HRDATA_S12_const_net_0;
wire   [1:0]  HRESP_S12_const_net_0;
wire   [31:0] HRDATA_S13_const_net_0;
wire   [1:0]  HRESP_S13_const_net_0;
wire   [31:0] HRDATA_S14_const_net_0;
wire   [1:0]  HRESP_S14_const_net_0;
wire   [31:0] HRDATA_S15_const_net_0;
wire   [1:0]  HRESP_S15_const_net_0;
wire   [31:0] HRDATA_S16_const_net_0;
wire   [1:0]  HRESP_S16_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign HADDR_M1_const_net_0   = 32'h00000000;
assign HTRANS_M1_const_net_0  = 2'h0;
assign GND_net                = 1'b0;
assign HSIZE_M1_const_net_0   = 3'h0;
assign HBURST_M1_const_net_0  = 3'h0;
assign HPROT_M1_const_net_0   = 4'h0;
assign HWDATA_M1_const_net_0  = 32'h00000000;
assign HADDR_M2_const_net_0   = 32'h00000000;
assign HTRANS_M2_const_net_0  = 2'h0;
assign HSIZE_M2_const_net_0   = 3'h0;
assign HBURST_M2_const_net_0  = 3'h0;
assign HPROT_M2_const_net_0   = 4'h0;
assign HWDATA_M2_const_net_0  = 32'h00000000;
assign HADDR_M3_const_net_0   = 32'h00000000;
assign HTRANS_M3_const_net_0  = 2'h0;
assign HSIZE_M3_const_net_0   = 3'h0;
assign HBURST_M3_const_net_0  = 3'h0;
assign HPROT_M3_const_net_0   = 4'h0;
assign HWDATA_M3_const_net_0  = 32'h00000000;
assign HRDATA_S8_const_net_0  = 32'h00000000;
assign VCC_net                = 1'b1;
assign HRESP_S8_const_net_0   = 2'h0;
assign HRDATA_S9_const_net_0  = 32'h00000000;
assign HRESP_S9_const_net_0   = 2'h0;
assign HRDATA_S10_const_net_0 = 32'h00000000;
assign HRESP_S10_const_net_0  = 2'h0;
assign HRDATA_S11_const_net_0 = 32'h00000000;
assign HRESP_S11_const_net_0  = 2'h0;
assign HRDATA_S12_const_net_0 = 32'h00000000;
assign HRESP_S12_const_net_0  = 2'h0;
assign HRDATA_S13_const_net_0 = 32'h00000000;
assign HRESP_S13_const_net_0  = 2'h0;
assign HRDATA_S14_const_net_0 = 32'h00000000;
assign HRESP_S14_const_net_0  = 2'h0;
assign HRDATA_S15_const_net_0 = 32'h00000000;
assign HRESP_S15_const_net_0  = 2'h0;
assign HRDATA_S16_const_net_0 = 32'h00000000;
assign HRESP_S16_const_net_0  = 2'h0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign AHBmmaster0_HRDATA_net_0   = AHBmmaster0_HRDATA;
assign HRDATA_M0[31:0]            = AHBmmaster0_HRDATA_net_0;
assign AHBmmaster0_HREADY_net_0   = AHBmmaster0_HREADY;
assign HREADY_M0                  = AHBmmaster0_HREADY_net_0;
assign AHBmmaster0_HRESP_net_0    = AHBmmaster0_HRESP;
assign HRESP_M0[1:0]              = AHBmmaster0_HRESP_net_0;
assign AHBmslave0_HADDR_net_0     = AHBmslave0_HADDR;
assign HADDR_S0[31:0]             = AHBmslave0_HADDR_net_0;
assign AHBmslave0_HTRANS_net_0    = AHBmslave0_HTRANS;
assign HTRANS_S0[1:0]             = AHBmslave0_HTRANS_net_0;
assign AHBmslave0_HWRITE_net_0    = AHBmslave0_HWRITE;
assign HWRITE_S0                  = AHBmslave0_HWRITE_net_0;
assign AHBmslave0_HSIZE_net_0     = AHBmslave0_HSIZE;
assign HSIZE_S0[2:0]              = AHBmslave0_HSIZE_net_0;
assign AHBmslave0_HWDATA_net_0    = AHBmslave0_HWDATA;
assign HWDATA_S0[31:0]            = AHBmslave0_HWDATA_net_0;
assign AHBmslave0_HSELx_net_0     = AHBmslave0_HSELx;
assign HSEL_S0                    = AHBmslave0_HSELx_net_0;
assign AHBmslave0_HREADY_net_0    = AHBmslave0_HREADY;
assign HREADY_S0                  = AHBmslave0_HREADY_net_0;
assign AHBmslave0_HMASTLOCK_net_0 = AHBmslave0_HMASTLOCK;
assign HMASTLOCK_S0               = AHBmslave0_HMASTLOCK_net_0;
assign AHBmslave0_HBURST_net_0    = AHBmslave0_HBURST;
assign HBURST_S0[2:0]             = AHBmslave0_HBURST_net_0;
assign AHBmslave0_HPROT_net_0     = AHBmslave0_HPROT;
assign HPROT_S0[3:0]              = AHBmslave0_HPROT_net_0;
assign AHBmslave1_HADDR_net_0     = AHBmslave1_HADDR;
assign HADDR_S1[31:0]             = AHBmslave1_HADDR_net_0;
assign AHBmslave1_HTRANS_net_0    = AHBmslave1_HTRANS;
assign HTRANS_S1[1:0]             = AHBmslave1_HTRANS_net_0;
assign AHBmslave1_HWRITE_net_0    = AHBmslave1_HWRITE;
assign HWRITE_S1                  = AHBmslave1_HWRITE_net_0;
assign AHBmslave1_HSIZE_net_0     = AHBmslave1_HSIZE;
assign HSIZE_S1[2:0]              = AHBmslave1_HSIZE_net_0;
assign AHBmslave1_HWDATA_net_0    = AHBmslave1_HWDATA;
assign HWDATA_S1[31:0]            = AHBmslave1_HWDATA_net_0;
assign AHBmslave1_HSELx_net_0     = AHBmslave1_HSELx;
assign HSEL_S1                    = AHBmslave1_HSELx_net_0;
assign AHBmslave1_HREADY_net_0    = AHBmslave1_HREADY;
assign HREADY_S1                  = AHBmslave1_HREADY_net_0;
assign AHBmslave1_HMASTLOCK_net_0 = AHBmslave1_HMASTLOCK;
assign HMASTLOCK_S1               = AHBmslave1_HMASTLOCK_net_0;
assign AHBmslave1_HBURST_net_0    = AHBmslave1_HBURST;
assign HBURST_S1[2:0]             = AHBmslave1_HBURST_net_0;
assign AHBmslave1_HPROT_net_0     = AHBmslave1_HPROT;
assign HPROT_S1[3:0]              = AHBmslave1_HPROT_net_0;
assign AHBmslave2_HADDR_net_0     = AHBmslave2_HADDR;
assign HADDR_S2[31:0]             = AHBmslave2_HADDR_net_0;
assign AHBmslave2_HTRANS_net_0    = AHBmslave2_HTRANS;
assign HTRANS_S2[1:0]             = AHBmslave2_HTRANS_net_0;
assign AHBmslave2_HWRITE_net_0    = AHBmslave2_HWRITE;
assign HWRITE_S2                  = AHBmslave2_HWRITE_net_0;
assign AHBmslave2_HSIZE_net_0     = AHBmslave2_HSIZE;
assign HSIZE_S2[2:0]              = AHBmslave2_HSIZE_net_0;
assign AHBmslave2_HWDATA_net_0    = AHBmslave2_HWDATA;
assign HWDATA_S2[31:0]            = AHBmslave2_HWDATA_net_0;
assign AHBmslave2_HSELx_net_0     = AHBmslave2_HSELx;
assign HSEL_S2                    = AHBmslave2_HSELx_net_0;
assign AHBmslave2_HREADY_net_0    = AHBmslave2_HREADY;
assign HREADY_S2                  = AHBmslave2_HREADY_net_0;
assign AHBmslave2_HMASTLOCK_net_0 = AHBmslave2_HMASTLOCK;
assign HMASTLOCK_S2               = AHBmslave2_HMASTLOCK_net_0;
assign AHBmslave2_HBURST_net_0    = AHBmslave2_HBURST;
assign HBURST_S2[2:0]             = AHBmslave2_HBURST_net_0;
assign AHBmslave2_HPROT_net_0     = AHBmslave2_HPROT;
assign HPROT_S2[3:0]              = AHBmslave2_HPROT_net_0;
assign AHBmslave3_HADDR_net_0     = AHBmslave3_HADDR;
assign HADDR_S3[31:0]             = AHBmslave3_HADDR_net_0;
assign AHBmslave3_HTRANS_net_0    = AHBmslave3_HTRANS;
assign HTRANS_S3[1:0]             = AHBmslave3_HTRANS_net_0;
assign AHBmslave3_HWRITE_net_0    = AHBmslave3_HWRITE;
assign HWRITE_S3                  = AHBmslave3_HWRITE_net_0;
assign AHBmslave3_HSIZE_net_0     = AHBmslave3_HSIZE;
assign HSIZE_S3[2:0]              = AHBmslave3_HSIZE_net_0;
assign AHBmslave3_HWDATA_net_0    = AHBmslave3_HWDATA;
assign HWDATA_S3[31:0]            = AHBmslave3_HWDATA_net_0;
assign AHBmslave3_HSELx_net_0     = AHBmslave3_HSELx;
assign HSEL_S3                    = AHBmslave3_HSELx_net_0;
assign AHBmslave3_HREADY_net_0    = AHBmslave3_HREADY;
assign HREADY_S3                  = AHBmslave3_HREADY_net_0;
assign AHBmslave3_HMASTLOCK_net_0 = AHBmslave3_HMASTLOCK;
assign HMASTLOCK_S3               = AHBmslave3_HMASTLOCK_net_0;
assign AHBmslave3_HBURST_net_0    = AHBmslave3_HBURST;
assign HBURST_S3[2:0]             = AHBmslave3_HBURST_net_0;
assign AHBmslave3_HPROT_net_0     = AHBmslave3_HPROT;
assign HPROT_S3[3:0]              = AHBmslave3_HPROT_net_0;
assign AHBmslave4_HADDR_net_0     = AHBmslave4_HADDR;
assign HADDR_S4[31:0]             = AHBmslave4_HADDR_net_0;
assign AHBmslave4_HTRANS_net_0    = AHBmslave4_HTRANS;
assign HTRANS_S4[1:0]             = AHBmslave4_HTRANS_net_0;
assign AHBmslave4_HWRITE_net_0    = AHBmslave4_HWRITE;
assign HWRITE_S4                  = AHBmslave4_HWRITE_net_0;
assign AHBmslave4_HSIZE_net_0     = AHBmslave4_HSIZE;
assign HSIZE_S4[2:0]              = AHBmslave4_HSIZE_net_0;
assign AHBmslave4_HWDATA_net_0    = AHBmslave4_HWDATA;
assign HWDATA_S4[31:0]            = AHBmslave4_HWDATA_net_0;
assign AHBmslave4_HSELx_net_0     = AHBmslave4_HSELx;
assign HSEL_S4                    = AHBmslave4_HSELx_net_0;
assign AHBmslave4_HREADY_net_0    = AHBmslave4_HREADY;
assign HREADY_S4                  = AHBmslave4_HREADY_net_0;
assign AHBmslave4_HMASTLOCK_net_0 = AHBmslave4_HMASTLOCK;
assign HMASTLOCK_S4               = AHBmslave4_HMASTLOCK_net_0;
assign AHBmslave4_HBURST_net_0    = AHBmslave4_HBURST;
assign HBURST_S4[2:0]             = AHBmslave4_HBURST_net_0;
assign AHBmslave4_HPROT_net_0     = AHBmslave4_HPROT;
assign HPROT_S4[3:0]              = AHBmslave4_HPROT_net_0;
assign AHBmslave5_HADDR_net_0     = AHBmslave5_HADDR;
assign HADDR_S5[31:0]             = AHBmslave5_HADDR_net_0;
assign AHBmslave5_HTRANS_net_0    = AHBmslave5_HTRANS;
assign HTRANS_S5[1:0]             = AHBmslave5_HTRANS_net_0;
assign AHBmslave5_HWRITE_net_0    = AHBmslave5_HWRITE;
assign HWRITE_S5                  = AHBmslave5_HWRITE_net_0;
assign AHBmslave5_HSIZE_net_0     = AHBmslave5_HSIZE;
assign HSIZE_S5[2:0]              = AHBmslave5_HSIZE_net_0;
assign AHBmslave5_HWDATA_net_0    = AHBmslave5_HWDATA;
assign HWDATA_S5[31:0]            = AHBmslave5_HWDATA_net_0;
assign AHBmslave5_HSELx_net_0     = AHBmslave5_HSELx;
assign HSEL_S5                    = AHBmslave5_HSELx_net_0;
assign AHBmslave5_HREADY_net_0    = AHBmslave5_HREADY;
assign HREADY_S5                  = AHBmslave5_HREADY_net_0;
assign AHBmslave5_HMASTLOCK_net_0 = AHBmslave5_HMASTLOCK;
assign HMASTLOCK_S5               = AHBmslave5_HMASTLOCK_net_0;
assign AHBmslave5_HBURST_net_0    = AHBmslave5_HBURST;
assign HBURST_S5[2:0]             = AHBmslave5_HBURST_net_0;
assign AHBmslave5_HPROT_net_0     = AHBmslave5_HPROT;
assign HPROT_S5[3:0]              = AHBmslave5_HPROT_net_0;
assign AHBmslave6_HADDR_net_0     = AHBmslave6_HADDR;
assign HADDR_S6[31:0]             = AHBmslave6_HADDR_net_0;
assign AHBmslave6_HTRANS_net_0    = AHBmslave6_HTRANS;
assign HTRANS_S6[1:0]             = AHBmslave6_HTRANS_net_0;
assign AHBmslave6_HWRITE_net_0    = AHBmslave6_HWRITE;
assign HWRITE_S6                  = AHBmslave6_HWRITE_net_0;
assign AHBmslave6_HSIZE_net_0     = AHBmslave6_HSIZE;
assign HSIZE_S6[2:0]              = AHBmslave6_HSIZE_net_0;
assign AHBmslave6_HWDATA_net_0    = AHBmslave6_HWDATA;
assign HWDATA_S6[31:0]            = AHBmslave6_HWDATA_net_0;
assign AHBmslave6_HSELx_net_0     = AHBmslave6_HSELx;
assign HSEL_S6                    = AHBmslave6_HSELx_net_0;
assign AHBmslave6_HREADY_net_0    = AHBmslave6_HREADY;
assign HREADY_S6                  = AHBmslave6_HREADY_net_0;
assign AHBmslave6_HMASTLOCK_net_0 = AHBmslave6_HMASTLOCK;
assign HMASTLOCK_S6               = AHBmslave6_HMASTLOCK_net_0;
assign AHBmslave6_HBURST_net_0    = AHBmslave6_HBURST;
assign HBURST_S6[2:0]             = AHBmslave6_HBURST_net_0;
assign AHBmslave6_HPROT_net_0     = AHBmslave6_HPROT;
assign HPROT_S6[3:0]              = AHBmslave6_HPROT_net_0;
assign AHBmslave7_HADDR_net_0     = AHBmslave7_HADDR;
assign HADDR_S7[31:0]             = AHBmslave7_HADDR_net_0;
assign AHBmslave7_HTRANS_net_0    = AHBmslave7_HTRANS;
assign HTRANS_S7[1:0]             = AHBmslave7_HTRANS_net_0;
assign AHBmslave7_HWRITE_net_0    = AHBmslave7_HWRITE;
assign HWRITE_S7                  = AHBmslave7_HWRITE_net_0;
assign AHBmslave7_HSIZE_net_0     = AHBmslave7_HSIZE;
assign HSIZE_S7[2:0]              = AHBmslave7_HSIZE_net_0;
assign AHBmslave7_HWDATA_net_0    = AHBmslave7_HWDATA;
assign HWDATA_S7[31:0]            = AHBmslave7_HWDATA_net_0;
assign AHBmslave7_HSELx_net_0     = AHBmslave7_HSELx;
assign HSEL_S7                    = AHBmslave7_HSELx_net_0;
assign AHBmslave7_HREADY_net_0    = AHBmslave7_HREADY;
assign HREADY_S7                  = AHBmslave7_HREADY_net_0;
assign AHBmslave7_HMASTLOCK_net_0 = AHBmslave7_HMASTLOCK;
assign HMASTLOCK_S7               = AHBmslave7_HMASTLOCK_net_0;
assign AHBmslave7_HBURST_net_0    = AHBmslave7_HBURST;
assign HBURST_S7[2:0]             = AHBmslave7_HBURST_net_0;
assign AHBmslave7_HPROT_net_0     = AHBmslave7_HPROT;
assign HPROT_S7[3:0]              = AHBmslave7_HPROT_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------AHB_IF_1_AHB_IF_1_0_CoreAHBLite   -   Actel:DirectCore:CoreAHBLite:5.3.101
AHB_IF_1_AHB_IF_1_0_CoreAHBLite #( 
        .FAMILY             ( 24 ),
        .HADDR_SHG_CFG      ( 1 ),
        .M0_AHBSLOT0ENABLE  ( 1 ),
        .M0_AHBSLOT1ENABLE  ( 1 ),
        .M0_AHBSLOT2ENABLE  ( 1 ),
        .M0_AHBSLOT3ENABLE  ( 1 ),
        .M0_AHBSLOT4ENABLE  ( 1 ),
        .M0_AHBSLOT5ENABLE  ( 1 ),
        .M0_AHBSLOT6ENABLE  ( 1 ),
        .M0_AHBSLOT7ENABLE  ( 1 ),
        .M0_AHBSLOT8ENABLE  ( 0 ),
        .M0_AHBSLOT9ENABLE  ( 0 ),
        .M0_AHBSLOT10ENABLE ( 0 ),
        .M0_AHBSLOT11ENABLE ( 0 ),
        .M0_AHBSLOT12ENABLE ( 0 ),
        .M0_AHBSLOT13ENABLE ( 0 ),
        .M0_AHBSLOT14ENABLE ( 0 ),
        .M0_AHBSLOT15ENABLE ( 0 ),
        .M0_AHBSLOT16ENABLE ( 0 ),
        .M1_AHBSLOT0ENABLE  ( 0 ),
        .M1_AHBSLOT1ENABLE  ( 0 ),
        .M1_AHBSLOT2ENABLE  ( 0 ),
        .M1_AHBSLOT3ENABLE  ( 0 ),
        .M1_AHBSLOT4ENABLE  ( 0 ),
        .M1_AHBSLOT5ENABLE  ( 0 ),
        .M1_AHBSLOT6ENABLE  ( 0 ),
        .M1_AHBSLOT7ENABLE  ( 0 ),
        .M1_AHBSLOT8ENABLE  ( 0 ),
        .M1_AHBSLOT9ENABLE  ( 0 ),
        .M1_AHBSLOT10ENABLE ( 0 ),
        .M1_AHBSLOT11ENABLE ( 0 ),
        .M1_AHBSLOT12ENABLE ( 0 ),
        .M1_AHBSLOT13ENABLE ( 0 ),
        .M1_AHBSLOT14ENABLE ( 0 ),
        .M1_AHBSLOT15ENABLE ( 0 ),
        .M1_AHBSLOT16ENABLE ( 0 ),
        .M2_AHBSLOT0ENABLE  ( 0 ),
        .M2_AHBSLOT1ENABLE  ( 0 ),
        .M2_AHBSLOT2ENABLE  ( 0 ),
        .M2_AHBSLOT3ENABLE  ( 0 ),
        .M2_AHBSLOT4ENABLE  ( 0 ),
        .M2_AHBSLOT5ENABLE  ( 0 ),
        .M2_AHBSLOT6ENABLE  ( 0 ),
        .M2_AHBSLOT7ENABLE  ( 0 ),
        .M2_AHBSLOT8ENABLE  ( 0 ),
        .M2_AHBSLOT9ENABLE  ( 0 ),
        .M2_AHBSLOT10ENABLE ( 0 ),
        .M2_AHBSLOT11ENABLE ( 0 ),
        .M2_AHBSLOT12ENABLE ( 0 ),
        .M2_AHBSLOT13ENABLE ( 0 ),
        .M2_AHBSLOT14ENABLE ( 0 ),
        .M2_AHBSLOT15ENABLE ( 0 ),
        .M2_AHBSLOT16ENABLE ( 0 ),
        .M3_AHBSLOT0ENABLE  ( 0 ),
        .M3_AHBSLOT1ENABLE  ( 0 ),
        .M3_AHBSLOT2ENABLE  ( 0 ),
        .M3_AHBSLOT3ENABLE  ( 0 ),
        .M3_AHBSLOT4ENABLE  ( 0 ),
        .M3_AHBSLOT5ENABLE  ( 0 ),
        .M3_AHBSLOT6ENABLE  ( 0 ),
        .M3_AHBSLOT7ENABLE  ( 0 ),
        .M3_AHBSLOT8ENABLE  ( 0 ),
        .M3_AHBSLOT9ENABLE  ( 0 ),
        .M3_AHBSLOT10ENABLE ( 0 ),
        .M3_AHBSLOT11ENABLE ( 0 ),
        .M3_AHBSLOT12ENABLE ( 0 ),
        .M3_AHBSLOT13ENABLE ( 0 ),
        .M3_AHBSLOT14ENABLE ( 0 ),
        .M3_AHBSLOT15ENABLE ( 0 ),
        .M3_AHBSLOT16ENABLE ( 0 ),
        .MEMSPACE           ( 1 ),
        .SC_0               ( 0 ),
        .SC_1               ( 0 ),
        .SC_2               ( 0 ),
        .SC_3               ( 0 ),
        .SC_4               ( 0 ),
        .SC_5               ( 0 ),
        .SC_6               ( 0 ),
        .SC_7               ( 0 ),
        .SC_8               ( 0 ),
        .SC_9               ( 0 ),
        .SC_10              ( 0 ),
        .SC_11              ( 0 ),
        .SC_12              ( 0 ),
        .SC_13              ( 0 ),
        .SC_14              ( 0 ),
        .SC_15              ( 0 ) )
AHB_IF_1_0(
        // Inputs
        .HCLK          ( HCLK ),
        .HRESETN       ( HRESETN ),
        .REMAP_M0      ( REMAP_M0 ),
        .HADDR_M0      ( HADDR_M0 ),
        .HMASTLOCK_M0  ( HMASTLOCK_M0 ),
        .HSIZE_M0      ( HSIZE_M0 ),
        .HTRANS_M0     ( HTRANS_M0 ),
        .HWRITE_M0     ( HWRITE_M0 ),
        .HWDATA_M0     ( HWDATA_M0 ),
        .HBURST_M0     ( HBURST_M0 ),
        .HPROT_M0      ( HPROT_M0 ),
        .HADDR_M1      ( HADDR_M1_const_net_0 ), // tied to 32'h00000000 from definition
        .HMASTLOCK_M1  ( GND_net ), // tied to 1'b0 from definition
        .HSIZE_M1      ( HSIZE_M1_const_net_0 ), // tied to 3'h0 from definition
        .HTRANS_M1     ( HTRANS_M1_const_net_0 ), // tied to 2'h0 from definition
        .HWRITE_M1     ( GND_net ), // tied to 1'b0 from definition
        .HWDATA_M1     ( HWDATA_M1_const_net_0 ), // tied to 32'h00000000 from definition
        .HBURST_M1     ( HBURST_M1_const_net_0 ), // tied to 3'h0 from definition
        .HPROT_M1      ( HPROT_M1_const_net_0 ), // tied to 4'h0 from definition
        .HADDR_M2      ( HADDR_M2_const_net_0 ), // tied to 32'h00000000 from definition
        .HMASTLOCK_M2  ( GND_net ), // tied to 1'b0 from definition
        .HSIZE_M2      ( HSIZE_M2_const_net_0 ), // tied to 3'h0 from definition
        .HTRANS_M2     ( HTRANS_M2_const_net_0 ), // tied to 2'h0 from definition
        .HWRITE_M2     ( GND_net ), // tied to 1'b0 from definition
        .HWDATA_M2     ( HWDATA_M2_const_net_0 ), // tied to 32'h00000000 from definition
        .HBURST_M2     ( HBURST_M2_const_net_0 ), // tied to 3'h0 from definition
        .HPROT_M2      ( HPROT_M2_const_net_0 ), // tied to 4'h0 from definition
        .HADDR_M3      ( HADDR_M3_const_net_0 ), // tied to 32'h00000000 from definition
        .HMASTLOCK_M3  ( GND_net ), // tied to 1'b0 from definition
        .HSIZE_M3      ( HSIZE_M3_const_net_0 ), // tied to 3'h0 from definition
        .HTRANS_M3     ( HTRANS_M3_const_net_0 ), // tied to 2'h0 from definition
        .HWRITE_M3     ( GND_net ), // tied to 1'b0 from definition
        .HWDATA_M3     ( HWDATA_M3_const_net_0 ), // tied to 32'h00000000 from definition
        .HBURST_M3     ( HBURST_M3_const_net_0 ), // tied to 3'h0 from definition
        .HPROT_M3      ( HPROT_M3_const_net_0 ), // tied to 4'h0 from definition
        .HRDATA_S0     ( HRDATA_S0 ),
        .HREADYOUT_S0  ( HREADYOUT_S0 ),
        .HRESP_S0      ( HRESP_S0 ),
        .HRDATA_S1     ( HRDATA_S1 ),
        .HREADYOUT_S1  ( HREADYOUT_S1 ),
        .HRESP_S1      ( HRESP_S1 ),
        .HRDATA_S2     ( HRDATA_S2 ),
        .HREADYOUT_S2  ( HREADYOUT_S2 ),
        .HRESP_S2      ( HRESP_S2 ),
        .HRDATA_S3     ( HRDATA_S3 ),
        .HREADYOUT_S3  ( HREADYOUT_S3 ),
        .HRESP_S3      ( HRESP_S3 ),
        .HRDATA_S4     ( HRDATA_S4 ),
        .HREADYOUT_S4  ( HREADYOUT_S4 ),
        .HRESP_S4      ( HRESP_S4 ),
        .HRDATA_S5     ( HRDATA_S5 ),
        .HREADYOUT_S5  ( HREADYOUT_S5 ),
        .HRESP_S5      ( HRESP_S5 ),
        .HRDATA_S6     ( HRDATA_S6 ),
        .HREADYOUT_S6  ( HREADYOUT_S6 ),
        .HRESP_S6      ( HRESP_S6 ),
        .HRDATA_S7     ( HRDATA_S7 ),
        .HREADYOUT_S7  ( HREADYOUT_S7 ),
        .HRESP_S7      ( HRESP_S7 ),
        .HRDATA_S8     ( HRDATA_S8_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S8  ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S8      ( HRESP_S8_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S9     ( HRDATA_S9_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S9  ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S9      ( HRESP_S9_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S10    ( HRDATA_S10_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S10 ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S10     ( HRESP_S10_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S11    ( HRDATA_S11_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S11 ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S11     ( HRESP_S11_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S12    ( HRDATA_S12_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S12 ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S12     ( HRESP_S12_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S13    ( HRDATA_S13_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S13 ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S13     ( HRESP_S13_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S14    ( HRDATA_S14_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S14 ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S14     ( HRESP_S14_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S15    ( HRDATA_S15_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S15 ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S15     ( HRESP_S15_const_net_0 ), // tied to 2'h0 from definition
        .HRDATA_S16    ( HRDATA_S16_const_net_0 ), // tied to 32'h00000000 from definition
        .HREADYOUT_S16 ( VCC_net ), // tied to 1'b1 from definition
        .HRESP_S16     ( HRESP_S16_const_net_0 ), // tied to 2'h0 from definition
        // Outputs
        .HRESP_M0      ( AHBmmaster0_HRESP ),
        .HRDATA_M0     ( AHBmmaster0_HRDATA ),
        .HREADY_M0     ( AHBmmaster0_HREADY ),
        .HRESP_M1      (  ),
        .HRDATA_M1     (  ),
        .HREADY_M1     (  ),
        .HRESP_M2      (  ),
        .HRDATA_M2     (  ),
        .HREADY_M2     (  ),
        .HRESP_M3      (  ),
        .HRDATA_M3     (  ),
        .HREADY_M3     (  ),
        .HSEL_S0       ( AHBmslave0_HSELx ),
        .HADDR_S0      ( AHBmslave0_HADDR ),
        .HSIZE_S0      ( AHBmslave0_HSIZE ),
        .HTRANS_S0     ( AHBmslave0_HTRANS ),
        .HWRITE_S0     ( AHBmslave0_HWRITE ),
        .HWDATA_S0     ( AHBmslave0_HWDATA ),
        .HREADY_S0     ( AHBmslave0_HREADY ),
        .HMASTLOCK_S0  ( AHBmslave0_HMASTLOCK ),
        .HBURST_S0     ( AHBmslave0_HBURST ),
        .HPROT_S0      ( AHBmslave0_HPROT ),
        .HSEL_S1       ( AHBmslave1_HSELx ),
        .HADDR_S1      ( AHBmslave1_HADDR ),
        .HSIZE_S1      ( AHBmslave1_HSIZE ),
        .HTRANS_S1     ( AHBmslave1_HTRANS ),
        .HWRITE_S1     ( AHBmslave1_HWRITE ),
        .HWDATA_S1     ( AHBmslave1_HWDATA ),
        .HREADY_S1     ( AHBmslave1_HREADY ),
        .HMASTLOCK_S1  ( AHBmslave1_HMASTLOCK ),
        .HBURST_S1     ( AHBmslave1_HBURST ),
        .HPROT_S1      ( AHBmslave1_HPROT ),
        .HSEL_S2       ( AHBmslave2_HSELx ),
        .HADDR_S2      ( AHBmslave2_HADDR ),
        .HSIZE_S2      ( AHBmslave2_HSIZE ),
        .HTRANS_S2     ( AHBmslave2_HTRANS ),
        .HWRITE_S2     ( AHBmslave2_HWRITE ),
        .HWDATA_S2     ( AHBmslave2_HWDATA ),
        .HREADY_S2     ( AHBmslave2_HREADY ),
        .HMASTLOCK_S2  ( AHBmslave2_HMASTLOCK ),
        .HBURST_S2     ( AHBmslave2_HBURST ),
        .HPROT_S2      ( AHBmslave2_HPROT ),
        .HSEL_S3       ( AHBmslave3_HSELx ),
        .HADDR_S3      ( AHBmslave3_HADDR ),
        .HSIZE_S3      ( AHBmslave3_HSIZE ),
        .HTRANS_S3     ( AHBmslave3_HTRANS ),
        .HWRITE_S3     ( AHBmslave3_HWRITE ),
        .HWDATA_S3     ( AHBmslave3_HWDATA ),
        .HREADY_S3     ( AHBmslave3_HREADY ),
        .HMASTLOCK_S3  ( AHBmslave3_HMASTLOCK ),
        .HBURST_S3     ( AHBmslave3_HBURST ),
        .HPROT_S3      ( AHBmslave3_HPROT ),
        .HSEL_S4       ( AHBmslave4_HSELx ),
        .HADDR_S4      ( AHBmslave4_HADDR ),
        .HSIZE_S4      ( AHBmslave4_HSIZE ),
        .HTRANS_S4     ( AHBmslave4_HTRANS ),
        .HWRITE_S4     ( AHBmslave4_HWRITE ),
        .HWDATA_S4     ( AHBmslave4_HWDATA ),
        .HREADY_S4     ( AHBmslave4_HREADY ),
        .HMASTLOCK_S4  ( AHBmslave4_HMASTLOCK ),
        .HBURST_S4     ( AHBmslave4_HBURST ),
        .HPROT_S4      ( AHBmslave4_HPROT ),
        .HSEL_S5       ( AHBmslave5_HSELx ),
        .HADDR_S5      ( AHBmslave5_HADDR ),
        .HSIZE_S5      ( AHBmslave5_HSIZE ),
        .HTRANS_S5     ( AHBmslave5_HTRANS ),
        .HWRITE_S5     ( AHBmslave5_HWRITE ),
        .HWDATA_S5     ( AHBmslave5_HWDATA ),
        .HREADY_S5     ( AHBmslave5_HREADY ),
        .HMASTLOCK_S5  ( AHBmslave5_HMASTLOCK ),
        .HBURST_S5     ( AHBmslave5_HBURST ),
        .HPROT_S5      ( AHBmslave5_HPROT ),
        .HSEL_S6       ( AHBmslave6_HSELx ),
        .HADDR_S6      ( AHBmslave6_HADDR ),
        .HSIZE_S6      ( AHBmslave6_HSIZE ),
        .HTRANS_S6     ( AHBmslave6_HTRANS ),
        .HWRITE_S6     ( AHBmslave6_HWRITE ),
        .HWDATA_S6     ( AHBmslave6_HWDATA ),
        .HREADY_S6     ( AHBmslave6_HREADY ),
        .HMASTLOCK_S6  ( AHBmslave6_HMASTLOCK ),
        .HBURST_S6     ( AHBmslave6_HBURST ),
        .HPROT_S6      ( AHBmslave6_HPROT ),
        .HSEL_S7       ( AHBmslave7_HSELx ),
        .HADDR_S7      ( AHBmslave7_HADDR ),
        .HSIZE_S7      ( AHBmslave7_HSIZE ),
        .HTRANS_S7     ( AHBmslave7_HTRANS ),
        .HWRITE_S7     ( AHBmslave7_HWRITE ),
        .HWDATA_S7     ( AHBmslave7_HWDATA ),
        .HREADY_S7     ( AHBmslave7_HREADY ),
        .HMASTLOCK_S7  ( AHBmslave7_HMASTLOCK ),
        .HBURST_S7     ( AHBmslave7_HBURST ),
        .HPROT_S7      ( AHBmslave7_HPROT ),
        .HSEL_S8       (  ),
        .HADDR_S8      (  ),
        .HSIZE_S8      (  ),
        .HTRANS_S8     (  ),
        .HWRITE_S8     (  ),
        .HWDATA_S8     (  ),
        .HREADY_S8     (  ),
        .HMASTLOCK_S8  (  ),
        .HBURST_S8     (  ),
        .HPROT_S8      (  ),
        .HSEL_S9       (  ),
        .HADDR_S9      (  ),
        .HSIZE_S9      (  ),
        .HTRANS_S9     (  ),
        .HWRITE_S9     (  ),
        .HWDATA_S9     (  ),
        .HREADY_S9     (  ),
        .HMASTLOCK_S9  (  ),
        .HBURST_S9     (  ),
        .HPROT_S9      (  ),
        .HSEL_S10      (  ),
        .HADDR_S10     (  ),
        .HSIZE_S10     (  ),
        .HTRANS_S10    (  ),
        .HWRITE_S10    (  ),
        .HWDATA_S10    (  ),
        .HREADY_S10    (  ),
        .HMASTLOCK_S10 (  ),
        .HBURST_S10    (  ),
        .HPROT_S10     (  ),
        .HSEL_S11      (  ),
        .HADDR_S11     (  ),
        .HSIZE_S11     (  ),
        .HTRANS_S11    (  ),
        .HWRITE_S11    (  ),
        .HWDATA_S11    (  ),
        .HREADY_S11    (  ),
        .HMASTLOCK_S11 (  ),
        .HBURST_S11    (  ),
        .HPROT_S11     (  ),
        .HSEL_S12      (  ),
        .HADDR_S12     (  ),
        .HSIZE_S12     (  ),
        .HTRANS_S12    (  ),
        .HWRITE_S12    (  ),
        .HWDATA_S12    (  ),
        .HREADY_S12    (  ),
        .HMASTLOCK_S12 (  ),
        .HBURST_S12    (  ),
        .HPROT_S12     (  ),
        .HSEL_S13      (  ),
        .HADDR_S13     (  ),
        .HSIZE_S13     (  ),
        .HTRANS_S13    (  ),
        .HWRITE_S13    (  ),
        .HWDATA_S13    (  ),
        .HREADY_S13    (  ),
        .HMASTLOCK_S13 (  ),
        .HBURST_S13    (  ),
        .HPROT_S13     (  ),
        .HSEL_S14      (  ),
        .HADDR_S14     (  ),
        .HSIZE_S14     (  ),
        .HTRANS_S14    (  ),
        .HWRITE_S14    (  ),
        .HWDATA_S14    (  ),
        .HREADY_S14    (  ),
        .HMASTLOCK_S14 (  ),
        .HBURST_S14    (  ),
        .HPROT_S14     (  ),
        .HSEL_S15      (  ),
        .HADDR_S15     (  ),
        .HSIZE_S15     (  ),
        .HTRANS_S15    (  ),
        .HWRITE_S15    (  ),
        .HWDATA_S15    (  ),
        .HREADY_S15    (  ),
        .HMASTLOCK_S15 (  ),
        .HBURST_S15    (  ),
        .HPROT_S15     (  ),
        .HSEL_S16      (  ),
        .HADDR_S16     (  ),
        .HSIZE_S16     (  ),
        .HTRANS_S16    (  ),
        .HWRITE_S16    (  ),
        .HWDATA_S16    (  ),
        .HREADY_S16    (  ),
        .HMASTLOCK_S16 (  ),
        .HBURST_S16    (  ),
        .HPROT_S16     (  ) 
        );


endmodule
