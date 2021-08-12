# Microsemi Tcl Script
# libero
# Date: Tue Aug  1 05:38:29 2017
# Directory /home/yizhou/igloowork
# File /home/yizhou/igloowork/createprj.tcl


new_project -location {./x} -name {x} -project_description {} -block_mode 0 -standalone_peripheral_initialization 0 -use_enhanced_constraint_flow 1 -hdl {VERILOG} -family {IGLOO2} -die {M2GL005} -package {256 VF} -speed {STD} -die_voltage {1.2} -part_range {COM} -adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} -adv_options {IO_DEFT_STD:LVCMOS 3.3V} -adv_options {PLL_SUPPLY:PLL_SUPPLY_25} -adv_options {RESTRICTPROBEPINS:0} -adv_options {RESTRICTSPIPINS:0} -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:COM} -adv_options {VCCI_1.2_VOLTR:COM} -adv_options {VCCI_1.5_VOLTR:COM} -adv_options {VCCI_1.8_VOLTR:COM} -adv_options {VCCI_2.5_VOLTR:COM} -adv_options {VCCI_3.3_VOLTR:COM} -adv_options {VOLTR:COM} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./sound.v} \
         -hdl_source {./sd.v} \
         -hdl_source {./ram.v} \
         -hdl_source {./crc7.v} \
         -hdl_source {./test.v}
create_links \
         -convert_EDN_to_HDL 0 
import_files \
         -convert_EDN_to_HDL 0 \
         -io_pdc {./test.pdc} \
         -sdc {./test.sdc} 
create_links \
         -convert_EDN_to_HDL 0 
save_project 
run_tool -name {CONSTRAINT_MANAGEMENT} 
organize_tool_files -tool {PLACEROUTE} -file {./x/constraint/io/test.pdc} -module {test::work} -input_type {constraint} 
organize_tool_files -tool {SYNTHESIZE} -file {./x/constraint/test.sdc} -module {test::work} -input_type {constraint} 
organize_tool_files -tool {PLACEROUTE} -file {./x/constraint/io/test.pdc} -file {./x/constraint/test.sdc} -module {test::work} -input_type {constraint} 
organize_tool_files -tool {VERIFYTIMING} -file {./x/constraint/test.sdc} -module {test::work} -input_type {constraint} 
save_project 
set_root -module {test::work}
save_project


