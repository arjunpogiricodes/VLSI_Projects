
#Liberty files are needed for logical and physical netlist designs
set search_path {../lib/}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

set_app_var enable_lint true

configure_lint_setup -goal lint_rtl

analyze -verbose -format verilog "../rtl/msrv32_reg_block_1.v"

#waive_lint -tag  STARC05-2.5.1.2  -add clock_waive 
 
elaborate msrv32_reg_block
check_lint

report_lint -verbose -file report_lint_reg_block_1.txt

