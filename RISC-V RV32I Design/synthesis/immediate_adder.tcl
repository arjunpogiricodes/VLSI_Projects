
remove_design -all
set search_path {../lib/}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/msrv32_immediate_adder.v }
elaborate msrv32_immediate_adder

link 

check_design

current_design  msrv32_immediate_adder
compile_ultra -no_autoungroup

write_file -f verilog -hier -output msrv32_immediate_adder_netlist.v