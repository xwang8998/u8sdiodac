set_device -family {IGLOO2} -die {M2GL025} -speed {-1}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\test.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\crc7.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\sound.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\mult28x32.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\tap_rom.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\fir.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\tap_rom2.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\fir2.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\bigfifo.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\ram.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\pipe_pcm.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\sdm.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\work\sd.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreResetP\7.1.100\rtl\vlog\core\coreresetp_pcie_hotreset.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreResetP\7.1.100\rtl\vlog\core\coreresetp.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\soc\sdio25\component\work\u8_sb\CCC_0\u8_sb_CCC_0_FCCC.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\soc\sdio25\component\work\u8_sb\FABOSC_0\u8_sb_FABOSC_0_OSC.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\soc\sdio25\component\work\u8_sb_HPMS\u8_sb_HPMS.v}
read_verilog -mode verilog_2k -lib COREAHBLITE_LIB {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_slavearbiter.v}
read_verilog -mode verilog_2k -lib COREAHBLITE_LIB {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_slavestage.v}
read_verilog -mode verilog_2k -lib COREAHBLITE_LIB {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_defaultslavesm.v}
read_verilog -mode verilog_2k -lib COREAHBLITE_LIB {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_addrdec.v}
read_verilog -mode verilog_2k -lib COREAHBLITE_LIB {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_masterstage.v}
read_verilog -mode verilog_2k -lib COREAHBLITE_LIB {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite_matrix4x16.v}
read_verilog -mode verilog_2k -lib COREAHBLITE_LIB {E:\DAC\igloo\soc\sdio25\component\Actel\DirectCore\CoreAHBLite\5.2.100\rtl\vlog\core\coreahblite.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\soc\sdio25\component\work\u8_sb\u8_sb.v}
read_verilog -mode verilog_2k {E:\DAC\igloo\soc\sdio25\component\work\u8\u8.v}
set_top_level {u8}
map_netlist
read_sdc {E:\DAC\igloo\work\test.sdc}
check_constraints {E:\DAC\igloo\soc\sdio25\constraint\synthesis_sdc_errors.log}
write_fdc {E:\DAC\igloo\soc\sdio25\designer\u8\synthesis.fdc}
