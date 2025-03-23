
remove_design -all
set search_path {../lib/}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/msrv32_imm_generator.v }
elaborate msrv32_imm_generator

link 

check_design

current_design  msrv32_imm_generator
compile_ultra -no_autoungroup

write_file -f verilog -hier -output msrv32_imm_generator_netlist.v