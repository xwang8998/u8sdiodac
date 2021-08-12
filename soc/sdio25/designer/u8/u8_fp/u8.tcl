open_project -project {E:\DAC\igloo\soc\sdio25\designer\u8\u8_fp\u8.pro}\
         -connect_programmers {FALSE}
load_programming_data \
    -name {M2GL025} \
    -fpga {E:\DAC\igloo\soc\sdio25\designer\u8\u8.map} \
    -header {E:\DAC\igloo\soc\sdio25\designer\u8\u8.hdr} \
    -spm {E:\DAC\igloo\soc\sdio25\designer\u8\u8.spm} \
    -dca {E:\DAC\igloo\soc\sdio25\designer\u8\u8.dca}
export_single_stapl \
    -name {M2GL025} \
    -file {E:\DAC\igloo\soc\sdio25\designer\u8\export\u8pcm32-1ch.stp} \
    -secured


save_project
close_project
