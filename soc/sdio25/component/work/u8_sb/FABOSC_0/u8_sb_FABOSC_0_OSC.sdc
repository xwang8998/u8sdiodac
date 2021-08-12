set_component u8_sb_FABOSC_0_OSC
# Microsemi Corp.
# Date: 2021-Aug-10 15:34:35
#

create_clock -ignore_errors -period 20 [ get_pins { I_RCOSC_25_50MHZ/CLKOUT } ]
