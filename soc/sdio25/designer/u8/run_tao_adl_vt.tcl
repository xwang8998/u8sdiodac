set_family {IGLOO2}
read_adl {D:\820\igloo\soc\sdio25\designer\u8\u8.adl}
map_netlist
read_sdc {D:\820\igloo\work\test.sdc}
check_constraints {D:\820\igloo\soc\sdio25\constraint\timing_sdc_errors.log}
write_sdc -strict {D:\820\igloo\soc\sdio25\designer\u8\timing_analysis.sdc}
