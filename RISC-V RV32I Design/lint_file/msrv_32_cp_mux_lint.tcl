
#Liberty files are needed for logical and physical netlist designs
set search_path {../lib/}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

set_app_var enable_lint true

configure_lint_setup -goal lint_rtl

analyze -verbose -format verilog "../rtl/msrv32_pc_mux.v"

waive_lint -tag  "CombLoop"  -add clock_waive 
 
elaborate msrv_pc_mux
check_lint

report_lint -verbose -file report_lint_pc_mux.txt

