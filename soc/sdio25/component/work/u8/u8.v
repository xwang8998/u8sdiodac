//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue Aug 10 17:39:20 2021
// Version: v12.6 12.900.20.24
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// u8
module u8(
    // Inputs
    DEVRST_N,
    clock138_bck,
    clock138_lrck,
    mclk,
    sdclk,
    // Outputs
    clock138_data,
    dsd_ln0,
    dsd_ln1,
    dsd_ln2,
    dsd_ln3,
    dsd_ln4,
    dsd_ln5,
    dsd_ln6,
    dsd_ln7,
    dsd_lp0,
    dsd_lp1,
    dsd_lp2,
    dsd_lp3,
    dsd_lp4,
    dsd_lp5,
    dsd_lp6,
    dsd_lp7,
    dsd_rn0,
    dsd_rn1,
    dsd_rn2,
    dsd_rn3,
    dsd_rn4,
    dsd_rn5,
    dsd_rn6,
    dsd_rn7,
    dsd_rp0,
    dsd_rp1,
    dsd_rp2,
    dsd_rp3,
    dsd_rp4,
    dsd_rp5,
    dsd_rp6,
    dsd_rp7,
    en45,
    en49,
    led0,
    led1,
    led2,
    led3,
    led4,
    led5,
    led6,
    led7,
    spdif_en,
    spdif_tx,
    // Inouts
    cmd,
    obck,
    odata,
    olrck,
    sd_d0,
    sd_d1,
    sd_d2,
    sd_d3
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  DEVRST_N;
input  clock138_bck;
input  clock138_lrck;
input  mclk;
input  sdclk;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output clock138_data;
output dsd_ln0;
output dsd_ln1;
output dsd_ln2;
output dsd_ln3;
output dsd_ln4;
output dsd_ln5;
output dsd_ln6;
output dsd_ln7;
output dsd_lp0;
output dsd_lp1;
output dsd_lp2;
output dsd_lp3;
output dsd_lp4;
output dsd_lp5;
output dsd_lp6;
output dsd_lp7;
output dsd_rn0;
output dsd_rn1;
output dsd_rn2;
output dsd_rn3;
output dsd_rn4;
output dsd_rn5;
output dsd_rn6;
output dsd_rn7;
output dsd_rp0;
output dsd_rp1;
output dsd_rp2;
output dsd_rp3;
output dsd_rp4;
output dsd_rp5;
output dsd_rp6;
output dsd_rp7;
output en45;
output en49;
output led0;
output led1;
output led2;
output led3;
output led4;
output led5;
output led6;
output led7;
output spdif_en;
output spdif_tx;
//--------------------------------------------------------------------
// Inout
//--------------------------------------------------------------------
inout  cmd;
inout  obck;
inout  odata;
inout  olrck;
inout  sd_d0;
inout  sd_d1;
inout  sd_d2;
inout  sd_d3;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          clock138_bck;
wire          clock138_data_net_0;
wire          clock138_lrck;
wire          cmd;
wire          DEVRST_N;
wire          dsd_ln1_net_0;
wire          dsd_ln1_1;
wire          dsd_ln2_net_0;
wire          dsd_ln3_net_0;
wire          dsd_ln4_net_0;
wire          dsd_ln5_net_0;
wire          dsd_ln6_net_0;
wire          dsd_ln7_net_0;
wire          dsd_lp0_net_0;
wire          dsd_lp1_net_0;
wire          dsd_lp2_net_0;
wire          dsd_lp3_net_0;
wire          dsd_lp4_net_0;
wire          dsd_lp5_net_0;
wire          dsd_lp6_net_0;
wire          dsd_lp7_net_0;
wire          dsd_rn0_net_0;
wire          dsd_rn1_net_0;
wire          dsd_rn2_net_0;
wire          dsd_rn3_net_0;
wire          dsd_rn4_net_0;
wire          dsd_rn5_0;
wire          dsd_rn6_net_0;
wire          dsd_rn7_net_0;
wire          dsd_rp0_net_0;
wire          dsd_rp1_net_0;
wire          dsd_rp2_net_0;
wire          dsd_rp3_net_0;
wire          dsd_rp4_net_0;
wire          dsd_rp5_net_0;
wire          dsd_rp6_net_0;
wire          dsd_rp7_net_0;
wire          en45_net_0;
wire          en49_net_0;
wire          led0_net_0;
wire          led1_net_0;
wire          led2_net_0;
wire          led3_net_0;
wire          led4_net_0;
wire          led5_net_0;
wire          led6_net_0;
wire          led7_net_0;
wire          mclk;
wire          obck;
wire          odata;
wire          olrck;
wire          sd_d0;
wire          sd_d1;
wire          sd_d2;
wire          sd_d3;
wire          sdclk;
wire          spdif_en_net_0;
wire          spdif_tx_net_0;
wire          test_0_FPGA_CLK;
wire   [31:0] test_0_HADDR;
wire   [2:0]  test_0_HBURST;
wire          test_0_HMASTLOCK;
wire   [3:0]  test_0_HPROT;
wire   [2:0]  test_0_HSIZE;
wire   [1:0]  test_0_HTRANS;
wire   [31:0] test_0_HWDATA;
wire          test_0_HWRITE;
wire          u8_sb_0_FIC_0_LOCK;
wire   [31:0] u8_sb_0_HPMS_FIC_0_USER_MASTER_HRDATA_M0;
wire          u8_sb_0_HPMS_FIC_0_USER_MASTER_HREADY_M0;
wire   [1:0]  u8_sb_0_HPMS_FIC_0_USER_MASTER_HRESP_M0;
wire          u8_sb_0_HPMS_READY;
wire          clock138_data_net_1;
wire          en49_net_1;
wire          en45_net_1;
wire          led0_net_1;
wire          led1_net_1;
wire          led2_net_1;
wire          led3_net_1;
wire          led4_net_1;
wire          led5_net_1;
wire          led6_net_1;
wire          led7_net_1;
wire          spdif_en_net_1;
wire          spdif_tx_net_1;
wire          dsd_ln1_net_1;
wire          dsd_ln1_1_net_0;
wire          dsd_ln2_net_1;
wire          dsd_ln3_net_1;
wire          dsd_ln4_net_1;
wire          dsd_ln5_net_1;
wire          dsd_ln6_net_1;
wire          dsd_ln7_net_1;
wire          dsd_lp0_net_1;
wire          dsd_lp1_net_1;
wire          dsd_lp2_net_1;
wire          dsd_lp3_net_1;
wire          dsd_lp4_net_1;
wire          dsd_lp5_net_1;
wire          dsd_lp6_net_1;
wire          dsd_lp7_net_1;
wire          dsd_rn0_net_1;
wire          dsd_rn1_net_1;
wire          dsd_rn2_net_1;
wire          dsd_rn3_net_1;
wire          dsd_rn4_net_1;
wire          dsd_rn5_0_net_0;
wire          dsd_rn6_net_1;
wire          dsd_rn7_net_1;
wire          dsd_rp0_net_1;
wire          dsd_rp1_net_1;
wire          dsd_rp2_net_1;
wire          dsd_rp3_net_1;
wire          dsd_rp4_net_1;
wire          dsd_rp5_net_1;
wire          dsd_rp6_net_1;
wire          dsd_rp7_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          VCC_net;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign VCC_net = 1'b1;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign clock138_data_net_1 = clock138_data_net_0;
assign clock138_data       = clock138_data_net_1;
assign en49_net_1          = en49_net_0;
assign en49                = en49_net_1;
assign en45_net_1          = en45_net_0;
assign en45                = en45_net_1;
assign led0_net_1          = led0_net_0;
assign led0                = led0_net_1;
assign led1_net_1          = led1_net_0;
assign led1                = led1_net_1;
assign led2_net_1          = led2_net_0;
assign led2                = led2_net_1;
assign led3_net_1          = led3_net_0;
assign led3                = led3_net_1;
assign led4_net_1          = led4_net_0;
assign led4                = led4_net_1;
assign led5_net_1          = led5_net_0;
assign led5                = led5_net_1;
assign led6_net_1          = led6_net_0;
assign led6                = led6_net_1;
assign led7_net_1          = led7_net_0;
assign led7                = led7_net_1;
assign spdif_en_net_1      = spdif_en_net_0;
assign spdif_en            = spdif_en_net_1;
assign spdif_tx_net_1      = spdif_tx_net_0;
assign spdif_tx            = spdif_tx_net_1;
assign dsd_ln1_net_1       = dsd_ln1_net_0;
assign dsd_ln0             = dsd_ln1_net_1;
assign dsd_ln1_1_net_0     = dsd_ln1_1;
assign dsd_ln1             = dsd_ln1_1_net_0;
assign dsd_ln2_net_1       = dsd_ln2_net_0;
assign dsd_ln2             = dsd_ln2_net_1;
assign dsd_ln3_net_1       = dsd_ln3_net_0;
assign dsd_ln3             = dsd_ln3_net_1;
assign dsd_ln4_net_1       = dsd_ln4_net_0;
assign dsd_ln4             = dsd_ln4_net_1;
assign dsd_ln5_net_1       = dsd_ln5_net_0;
assign dsd_ln5             = dsd_ln5_net_1;
assign dsd_ln6_net_1       = dsd_ln6_net_0;
assign dsd_ln6             = dsd_ln6_net_1;
assign dsd_ln7_net_1       = dsd_ln7_net_0;
assign dsd_ln7             = dsd_ln7_net_1;
assign dsd_lp0_net_1       = dsd_lp0_net_0;
assign dsd_lp0             = dsd_lp0_net_1;
assign dsd_lp1_net_1       = dsd_lp1_net_0;
assign dsd_lp1             = dsd_lp1_net_1;
assign dsd_lp2_net_1       = dsd_lp2_net_0;
assign dsd_lp2             = dsd_lp2_net_1;
assign dsd_lp3_net_1       = dsd_lp3_net_0;
assign dsd_lp3             = dsd_lp3_net_1;
assign dsd_lp4_net_1       = dsd_lp4_net_0;
assign dsd_lp4             = dsd_lp4_net_1;
assign dsd_lp5_net_1       = dsd_lp5_net_0;
assign dsd_lp5             = dsd_lp5_net_1;
assign dsd_lp6_net_1       = dsd_lp6_net_0;
assign dsd_lp6             = dsd_lp6_net_1;
assign dsd_lp7_net_1       = dsd_lp7_net_0;
assign dsd_lp7             = dsd_lp7_net_1;
assign dsd_rn0_net_1       = dsd_rn0_net_0;
assign dsd_rn0             = dsd_rn0_net_1;
assign dsd_rn1_net_1       = dsd_rn1_net_0;
assign dsd_rn1             = dsd_rn1_net_1;
assign dsd_rn2_net_1       = dsd_rn2_net_0;
assign dsd_rn2             = dsd_rn2_net_1;
assign dsd_rn3_net_1       = dsd_rn3_net_0;
assign dsd_rn3             = dsd_rn3_net_1;
assign dsd_rn4_net_1       = dsd_rn4_net_0;
assign dsd_rn4             = dsd_rn4_net_1;
assign dsd_rn5_0_net_0     = dsd_rn5_0;
assign dsd_rn5             = dsd_rn5_0_net_0;
assign dsd_rn6_net_1       = dsd_rn6_net_0;
assign dsd_rn6             = dsd_rn6_net_1;
assign dsd_rn7_net_1       = dsd_rn7_net_0;
assign dsd_rn7             = dsd_rn7_net_1;
assign dsd_rp0_net_1       = dsd_rp0_net_0;
assign dsd_rp0             = dsd_rp0_net_1;
assign dsd_rp1_net_1       = dsd_rp1_net_0;
assign dsd_rp1             = dsd_rp1_net_1;
assign dsd_rp2_net_1       = dsd_rp2_net_0;
assign dsd_rp2             = dsd_rp2_net_1;
assign dsd_rp3_net_1       = dsd_rp3_net_0;
assign dsd_rp3             = dsd_rp3_net_1;
assign dsd_rp4_net_1       = dsd_rp4_net_0;
assign dsd_rp4             = dsd_rp4_net_1;
assign dsd_rp5_net_1       = dsd_rp5_net_0;
assign dsd_rp5             = dsd_rp5_net_1;
assign dsd_rp6_net_1       = dsd_rp6_net_0;
assign dsd_rp6             = dsd_rp6_net_1;
assign dsd_rp7_net_1       = dsd_rp7_net_0;
assign dsd_rp7             = dsd_rp7_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------test
test test_0(
        // Inputs
        .reset_n       ( u8_sb_0_HPMS_READY ),
        .HREADY        ( u8_sb_0_HPMS_FIC_0_USER_MASTER_HREADY_M0 ),
        .pll_lock      ( u8_sb_0_FIC_0_LOCK ),
        .sdclk         ( sdclk ),
        .mclk          ( mclk ),
        .clock138_bck  ( clock138_bck ),
        .clock138_lrck ( clock138_lrck ),
        .HRDATA        ( u8_sb_0_HPMS_FIC_0_USER_MASTER_HRDATA_M0 ),
        .HRESP         ( u8_sb_0_HPMS_FIC_0_USER_MASTER_HRESP_M0 ),
        // Outputs
        .led0          ( led0_net_0 ),
        .led1          ( led1_net_0 ),
        .led2          ( led2_net_0 ),
        .led3          ( led3_net_0 ),
        .led4          ( led4_net_0 ),
        .led5          ( led5_net_0 ),
        .led6          ( led6_net_0 ),
        .led7          ( led7_net_0 ),
        .FPGA_CLK      ( test_0_FPGA_CLK ),
        .HWRITE        ( test_0_HWRITE ),
        .HMASTLOCK     ( test_0_HMASTLOCK ),
        .spdif_en      ( spdif_en_net_0 ),
        .spdif_tx      ( spdif_tx_net_0 ),
        .en45          ( en45_net_0 ),
        .en49          ( en49_net_0 ),
        .dsd_lp0       ( dsd_lp0_net_0 ),
        .dsd_lp1       ( dsd_lp1_net_0 ),
        .dsd_lp2       ( dsd_lp2_net_0 ),
        .dsd_lp3       ( dsd_lp3_net_0 ),
        .dsd_lp4       ( dsd_lp4_net_0 ),
        .dsd_lp5       ( dsd_lp5_net_0 ),
        .dsd_lp6       ( dsd_lp6_net_0 ),
        .dsd_lp7       ( dsd_lp7_net_0 ),
        .dsd_ln0       ( dsd_ln1_net_0 ),
        .dsd_ln1       ( dsd_ln1_1 ),
        .dsd_ln2       ( dsd_ln2_net_0 ),
        .dsd_ln3       ( dsd_ln3_net_0 ),
        .dsd_ln4       ( dsd_ln4_net_0 ),
        .dsd_ln5       ( dsd_ln5_net_0 ),
        .dsd_ln6       ( dsd_ln6_net_0 ),
        .dsd_ln7       ( dsd_ln7_net_0 ),
        .dsd_rp0       ( dsd_rp0_net_0 ),
        .dsd_rp1       ( dsd_rp1_net_0 ),
        .dsd_rp2       ( dsd_rp2_net_0 ),
        .dsd_rp3       ( dsd_rp3_net_0 ),
        .dsd_rp4       ( dsd_rp4_net_0 ),
        .dsd_rp5       ( dsd_rp5_net_0 ),
        .dsd_rp6       ( dsd_rp6_net_0 ),
        .dsd_rp7       ( dsd_rp7_net_0 ),
        .dsd_rn0       ( dsd_rn0_net_0 ),
        .dsd_rn1       ( dsd_rn1_net_0 ),
        .dsd_rn2       ( dsd_rn2_net_0 ),
        .dsd_rn3       ( dsd_rn3_net_0 ),
        .dsd_rn4       ( dsd_rn4_net_0 ),
        .dsd_rn5       ( dsd_rn5_0 ),
        .dsd_rn6       ( dsd_rn6_net_0 ),
        .dsd_rn7       ( dsd_rn7_net_0 ),
        .clock138_data ( clock138_data_net_0 ),
        .HADDR         ( test_0_HADDR ),
        .HTRANS        ( test_0_HTRANS ),
        .HSIZE         ( test_0_HSIZE ),
        .HBURST        ( test_0_HBURST ),
        .HPROT         ( test_0_HPROT ),
        .HWDATA        ( test_0_HWDATA ),
        // Inouts
        .cmd           ( cmd ),
        .sd_d0         ( sd_d0 ),
        .sd_d1         ( sd_d1 ),
        .sd_d2         ( sd_d2 ),
        .sd_d3         ( sd_d3 ),
        .obck          ( obck ),
        .olrck         ( olrck ),
        .odata         ( odata ) 
        );

//--------u8_sb
u8_sb u8_sb_0(
        // Inputs
        .FAB_RESET_N                         ( VCC_net ),
        .HPMS_FIC_0_USER_MASTER_HWRITE_M0    ( test_0_HWRITE ),
        .HPMS_FIC_0_USER_MASTER_HMASTLOCK_M0 ( test_0_HMASTLOCK ),
        .DEVRST_N                            ( DEVRST_N ),
        .CLK0                                ( test_0_FPGA_CLK ),
        .HPMS_FIC_0_USER_MASTER_HADDR_M0     ( test_0_HADDR ),
        .HPMS_FIC_0_USER_MASTER_HTRANS_M0    ( test_0_HTRANS ),
        .HPMS_FIC_0_USER_MASTER_HSIZE_M0     ( test_0_HSIZE ),
        .HPMS_FIC_0_USER_MASTER_HBURST_M0    ( test_0_HBURST ),
        .HPMS_FIC_0_USER_MASTER_HPROT_M0     ( test_0_HPROT ),
        .HPMS_FIC_0_USER_MASTER_HWDATA_M0    ( test_0_HWDATA ),
        // Outputs
        .POWER_ON_RESET_N                    (  ),
        .INIT_DONE                           (  ),
        .FIC_0_CLK                           (  ),
        .FIC_0_LOCK                          ( u8_sb_0_FIC_0_LOCK ),
        .HPMS_READY                          ( u8_sb_0_HPMS_READY ),
        .HPMS_FIC_0_USER_MASTER_HREADY_M0    ( u8_sb_0_HPMS_FIC_0_USER_MASTER_HREADY_M0 ),
        .COMM_BLK_INT                        (  ),
        .HPMS_FIC_0_USER_MASTER_HRDATA_M0    ( u8_sb_0_HPMS_FIC_0_USER_MASTER_HRDATA_M0 ),
        .HPMS_FIC_0_USER_MASTER_HRESP_M0     ( u8_sb_0_HPMS_FIC_0_USER_MASTER_HRESP_M0 ),
        .HPMS_INT_M2F                        (  ) 
        );


endmodule
