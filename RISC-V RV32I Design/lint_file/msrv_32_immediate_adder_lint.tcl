


#Liberty files are needed for logical and physical netlist designs
set search_path {../lib/}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

set_app_var enable_lint true

configure_lint_setup -goal lint_rtl

analyze -verbose -format verilog "../rtl/msrv32_immediate_adder.v"

waive_lint -tag  "CombLoop"  -add clock_waive 
 
elaborate msrv32_immediate_adder
check_lint

report_lint -verbose -file report_lint_immediate_adder.txt