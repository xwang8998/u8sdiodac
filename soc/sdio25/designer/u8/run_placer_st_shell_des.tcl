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
set_def {RTG4_MITIGATION_ON} {0}
set_def USE_CONSTRAINTS_FLOW 1
set_def NETLIST_TYPE EDIF
set_name u8
set_workdir {E:\DAC\igloo\soc\sdio25\designer\u8}
set_log     {E:\DAC\igloo\soc\sdio25\designer\u8\u8_sdc.log}
set_design_state pre_layout
