
remove_design -all
set search_path {../lib/}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/msrv32_pc_mux.v }
elaborate msrv_pc_mux

link 

check_design

current_design  msrv_pc_mux
compile_ultra -no_autoungroup

write_file -f verilog -hier -output msrv32_pc_mux_netlist.v