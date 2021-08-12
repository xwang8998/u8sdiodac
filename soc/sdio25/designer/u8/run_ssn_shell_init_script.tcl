set_device \
    -family  IGLOO2 \
    -die     PA4MGL2500_N \
    -package fg484 \
    -speed   -1 \
    -tempr   {COM} \
    -voltr   {COM}
set_def {VOLTAGE} {1.2}
set_def {VCCI_1.2_VOLTR} {COM}
set_def {VCCI_1.5_VOLTR} {COM}
set_def {VCCI_1.8_VOLTR} {COM}
set_def {VCCI_2.5_VOLTR} {COM}
set_def {VCCI_3.3_VOLTR} {COM}
set_def {PLL_SUPPLY} {PLL_SUPPLY_25}
set_netlist -afl {E:\DAC\igloo\soc\sdio25\designer\u8\u8.afl} -adl {E:\DAC\igloo\soc\sdio25\designer\u8\u8.adl}
set_constraints   {E:\DAC\igloo\soc\sdio25\designer\u8\u8.tcml}
set_placement   {E:\DAC\igloo\soc\sdio25\designer\u8\u8.loc}
set_routing     {E:\DAC\igloo\soc\sdio25\designer\u8\u8.seg}
