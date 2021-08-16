# Written by Synplify Pro version map202003act, Build 160R. Synopsys Run ID: sid1628829945 
# Top Level Design Parameters 

# Clocks 
create_clock -period 16.000 -waveform {0.000 8.000} -name {clock138_bck} [get_ports {clock138_bck}] 
create_clock -period 8.000 -waveform {0.000 4.000} -name {mclk} [get_ports {mclk}] 
create_clock -period 16.000 -waveform {0.000 8.000} -name {mclk4549} [get_pins {test_0/UCK1/Y}] 
create_clock -period 16.000 -waveform {0.000 8.000} -name {sdclk_n} [get_pins {test_0/UCK3/Y}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {sdtop|dsd_clkr_inferred_clock} [get_pins {test_0/u100/dsd_clkr/Q}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {clock_divider|clk2_inferred_clock} [get_pins {test_0/u100/DSD138/UIN100/UCK0/clk2/Q}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {clock_divider|clk4_inferred_clock} [get_pins {test_0/u100/DSD138/UIN100/UCK0/clk4/Q}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {clock_divider|clk8_inferred_clock} [get_pins {test_0/u100/DSD138/UIN100/UCK0/clk8/Q}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {u8_sb_CCC_0_FCCC|GL0_net_inferred_clock} [get_pins {u8_sb_0/CCC_0/CCC_INST/GL0}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {u8|sdclk} [get_ports {sdclk}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {clock_divider|clk16_inferred_clock} [get_pins {test_0/u100/DSD138/UIN100/UCK0/clk16/Q}] 

# Virtual Clocks 

# Generated Clocks 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 
set_false_path -to [get_ports {en45}] 
set_false_path -to [get_ports {en49}] 
set_false_path -to [get_ports {led0 led1 led2 led3 led4 led5 led6 led7}] 
set_false_path -to [get_ports {spdif_en}] 
set_false_path -from [get_cells {test_0/u100/uctrl/sound_card_start}] 
set_false_path -from [get_cells {test_0/u100/uctrl/use_dsd}] 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln0}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln1}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln2}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln3}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln4}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln5}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln6}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_ln7}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp0}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp1}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp2}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp3}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp4}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp5}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp6}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_lp7}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn0}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn1}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn2}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn3}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn4}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn5}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn6}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rn7}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp0}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp1}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp2}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp3}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp4}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp5}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp6}]
set_output_delay {3.7} -clock [get_clocks {mclk}] [get_ports {dsd_rp7}]
set_output_delay {0.5} -clock [get_clocks {sdclk_n}] [get_ports {cmd}]
set_output_delay {0.5} -clock [get_clocks {sdclk_n}] [get_ports {sd_d0}]
set_output_delay {0.5} -clock [get_clocks {sdclk_n}] [get_ports {sd_d1}]
set_output_delay {0.5} -clock [get_clocks {sdclk_n}] [get_ports {sd_d2}]
set_output_delay {0.5} -clock [get_clocks {sdclk_n}] [get_ports {sd_d3}]

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 
set_clock_groups -asynchronous -group [get_clocks {sdtop|dsd_clkr_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {clock_divider|clk2_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {clock_divider|clk4_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {clock_divider|clk8_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {u8_sb_CCC_0_FCCC|GL0_net_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {u8|sdclk}]
set_clock_groups -asynchronous -group [get_clocks {clock_divider|clk16_inferred_clock}]

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 
# set_false_path -from [get_ports { DEVRST_N* }]
# set_false_path -from [get_clocks { gl0 }] -to test_0*
# set_false_path -from [get_clocks { mclk4549 }] -to u8_sb*
# set_false_path -from [get_clocks { mclk4549 }] -to *USPDIF_TX*
# set_false_path -from [get_clocks { mclk }] -to test_0.u100*
# set_false_path -from [get_clocks { sdclk_n }] -to test_0.u200*
# set_false_path -from [get_clocks { mclk4549 }] -to test_0.mclk_d2*
# set_false_path -from [get_clocks { sdclk_n }] -to *usync*
# set_false_path -from [get_clocks { sdclk_n }] -to *usync*
# set_false_path -from [get_clocks { sdclk_n }] -to *ufifo*
# set_false_path -from [get_clocks { sdclk_n }] -to u8_sb*
# set_false_path -from [get_clocks { clock138_bck }] -to test_0.u200*
# set_false_path -from [get_clocks { mclk }] -to test_0.u200*
# set_false_path -from [get_clocks { sdclk_n }] -to *uctrl*
# set_false_path -from [get_clocks { mclk4549 }] -to *UDOP*
# set_false_path -from [get_clocks { dop_clock }] -to *USPDIF_TX*
# set_false_path -from [get_clocks { dsd_clk }] -to *dsd_lp*
# set_false_path -from [get_clocks { dsd_clk }] -to *dsd_rp*
# set_false_path -from [get_clocks { dsd_clk }] -to *dsd_ln*
# set_false_path -from [get_clocks { dsd_clk }] -to *dsd_rn*


# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

