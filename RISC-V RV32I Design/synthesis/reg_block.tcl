
remove_design -all
set search_path {../lib/}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/msrv32_reg_block_1.v }
elaborate msrv32_reg_block

link 

check_design

current_design  msrv32_reg_block
compile_ultra -no_autoungroup

write_file -f verilog -hier -output msrv32_reg_block_netlist.v