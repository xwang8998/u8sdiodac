### open synthesis/test.v, find all the SLE's clock section, collect the clock nets ######

create_clock -name {mclk} -period 8 -waveform {0 4 } [ get_ports { mclk } ]
create_clock -name {gl0} -period 16 -waveform {0 8 } [ get_pins { u8_sb_0/CCC_0/GL0_INST/Y } ]
create_clock -name {sdclk_n} -period 16 -waveform {0 8 } [ get_pins { test_0/UCK3/Y } ]

create_clock -name {clock138_bck} -period 16 -waveform {0 8 } [ get_ports { clock138_bck } ]
create_clock -name {mclk4549} -period 16 -waveform {0 8 } [ get_pins { test_0/UCK1/Y } ]
create_clock -name {dsd_clk} -period 32 -waveform {0 16 } [ get_pins { test_0/u100/UDSDCLK/Y } ]
#create_clock -name {sdm_clk} -period 64 -waveform {0 32 } [ get_pins { test_0/u100/USDMCLK/Y } ]
#create_clock -name {dac_clock} -period 32 -waveform {0 16 } [ get_pins { *DACCLK*/Y } ]
create_clock -name {spdif_clock} -period 16 -waveform {0 8 } [ get_pins { *spdif_clock* } ]
create_clock -name {dop_clock} -period 16 -waveform {0 8 } [ get_pins { *dop_clock* } ]
create_clock -name {dem_clk} -period 32 -waveform {0 16 } [ get_pins { test_0/UCK300/Y } ]

#set_output_delay 3.5 -clock {dem_clk} [ get_ports { *dsd_l* } ]
set_output_delay 3.7 -clock {mclk} [ get_ports { *dsd_* } ]

set_output_delay 0.5 -clock {sdclk_n} [ get_ports { cmd sd_d0 sd_d1 sd_d2 sd_d3 } ]

#set_output_delay 0.5 -clock {sdm_clk} [ get_ports { obck odata olrck } ]
#set_output_delay -max 0.5 -clock {dsd_clk} [ get_ports { obck odata olrck } ]

#set_clock_groups -name {u8grps} -asynchronous -group [get_clocks { dem_clk }] -group [get_clocks { dac_clock }] -group [get_clocks { clock138_bck }] -group [get_clocks { dsd_clk }] -group [get_clocks { gl0 }] -group [get_clocks { mclk }] -group [get_clocks { mclk4549 }] -group [get_clocks { sdclk_n }] -group [get_clocks { sdm_clk }] -group [get_clocks { spdif_clock }] -group [get_clocks { dop_clock }]

### check smartTime result, and fix these false paths ############
set_false_path -from [get_ports DEVRST_N*]
set_false_path -to [get_ports en45*]
set_false_path -to [get_ports en49*]
set_false_path -to [get_ports led*]
set_false_path -to [get_ports spdif_en*]
set_false_path -from [get_clocks {gl0}] -to test_0*
set_false_path -from [get_clocks {mclk4549}] -to u8_sb*
set_false_path -from [get_clocks {mclk4549}] -to *USPDIF_TX*
set_false_path -from [get_clocks {mclk}] -to test_0/u100*
set_false_path -from [get_clocks {sdclk_n}] -to test_0/u200*
set_false_path -from [get_clocks {mclk4549}] -to test_0/mclk_d2*
set_false_path -from [get_clocks {sdclk_n}] -to *usync*
set_false_path -from [get_clocks {sdclk_n}] -to *usync*
set_false_path -from [get_clocks {sdclk_n}] -to *ufifo*
set_false_path -from test_0/u100/uctrl/sound_card_start*
set_false_path -from test_0/u100/uctrl/use_dsd*

set_false_path -from [get_clocks {sdclk_n}] -to u8_sb*
set_false_path -from [get_clocks {clock138_bck}] -to test_0/u200*
set_false_path -from [get_clocks {mclk}] -to test_0/u200*

set_false_path -from [get_clocks {sdclk_n}] -to *uctrl*
set_false_path -from [get_clocks {mclk4549}] -to *UDOP*
set_false_path -from [get_clocks {dop_clock}] -to *USPDIF_TX*

set_false_path -from [get_clocks {dsd_clk}] -to *dsd_lp*
set_false_path -from [get_clocks {dsd_clk}] -to *dsd_rp*
set_false_path -from [get_clocks {dsd_clk}] -to *dsd_ln*
set_false_path -from [get_clocks {dsd_clk}] -to *dsd_rn*
