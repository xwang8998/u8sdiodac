new_project \
         -name {u8} \
         -location {D:\820\igloo\soc\sdio25\designer\u8\u8_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2GL025} \
         -name {M2GL025}
enable_device \
         -name {M2GL025} \
         -enable {TRUE}
save_project
close_project
