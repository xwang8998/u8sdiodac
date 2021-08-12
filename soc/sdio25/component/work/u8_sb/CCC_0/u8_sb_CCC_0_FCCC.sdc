set_component u8_sb_CCC_0_FCCC
# Microsemi Corp.
# Date: 2021-Aug-10 15:34:33
#

create_clock -period 20.3451 [ get_pins { CCC_INST/CLK0 } ]
create_generated_clock -multiply_by 2 -divide_by 2 -source [ get_pins { CCC_INST/CLK0 } ] -phase 0 [ get_pins { CCC_INST/GL0 } ]
