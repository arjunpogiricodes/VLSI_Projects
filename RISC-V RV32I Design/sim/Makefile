


TCL_1 = ../lint_file/msrv_32_cp_mux_lint.tcl
TCL_2 = ../lint_file/msrv_32_reg1_lint.tcl
TCL_3 = ../lint_file/msrv_32_imm_generator_lint.tcl
TCL_4 = ../lint_file/msrv_32_immediate_adder_lint.tcl


help:
	-@echo "######################################################################"
	-@echo "make lint_pc_mux 	      => Run VC Static on current testcase pc_muc"
	-@echo "make lint_reg1   	      => Run VC Static on current testcase reg_block_1"
	-@echo "make lint_imm_generator   => Run VC Static on current testcase imm_generator"	
	-@echo "make lint_immediate_adder => Run VC Static on current testcase immediate_adder"
	-@echo "make clean  	          => Clean up current testcase directory"
	-@echo "make help   	          => Generate this help menu      "
	-@echo "######################################################################"

lint_pc_mux:
	$(VC_STATIC_HOME)/bin/vc_static_shell -mode64 -f $(TCL_1)
lint_reg1:	
	$(VC_STATIC_HOME)/bin/vc_static_shell -mode64 -f $(TCL_2)
lint_imm_generator:	
	$(VC_STATIC_HOME)/bin/vc_static_shell -mode64 -f $(TCL_3)
lint_immediate_adder:	
	$(VC_STATIC_HOME)/bin/vc_static_shell -mode64 -f $(TCL_4)	
	
clean:
	rm -rf modelsim.ini transcript cov* coincov csrc* *.conf simv* d* MS* ms* a* v* n* 
	rm -rf $(LIB) verdi* *.log urgReport* *.fsdb *.rc *.key vdCov*
	clear

