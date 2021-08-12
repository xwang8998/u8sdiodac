set_device -family {IGLOO2} -die {M2GL025} -speed {-1}
read_adl {E:\DAC\igloo\soc\sdio25\designer\u8\u8.adl}
read_afl {E:\DAC\igloo\soc\sdio25\designer\u8\u8.afl}
map_netlist
read_sdc {E:\DAC\igloo\work\test.sdc}
check_constraints {E:\DAC\igloo\soc\sdio25\constraint\placer_sdc_errors.log}
write_sdc -mode layout {E:\DAC\igloo\soc\sdio25\designer\u8\place_route.sdc}
