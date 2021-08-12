set_component u8_sb_HPMS
# Microsemi Corp.
# Date: 2021-Aug-10 15:34:30
#

create_clock -period 81.3802 [ get_pins { MSS_ADLIB_INST/CLK_CONFIG_APB } ]
set_false_path -ignore_errors -through [ get_pins { MSS_ADLIB_INST/CONFIG_PRESET_N } ]
