

RTL = ../rtl/*.v
LIB = risc_v
COVOP = -coveropt 3 +cover +acc
TB = ../tb/*.v
VSIMOPT = -coverage -vopt alu.tb_alu
VSIMCOV = coverage save -onexit -codeAll risc_v_mux 
VSIMBATCH = -c -do "$(VSIMCOV); run -all; exit" 

help:
	-@echo "######################################################################"
	-@echo "make run 	        => Run code coverage"
	-@echo "make clean  	        => Clean up current testcase directory"
	-@echo "make help   	        => Generate this help menu      "
	-@echo "######################################################################"

run_tb:
	vlog -work alu $(COVOP) $(RTL) $(TB)
	vsim $(VSIMOPT) $(VSIMBATCH) 
	
report:
	vcover report  -details -codeAll -html risc_v_mux

html:
	firefox covhtmlreport/index.html&
clean:
	rm -rf modelsim.ini transcript cov* coincov csrc* *.conf simv* 
	rm -rf $(LIB) verdi* *.log urgReport* *.fsdb *.rc *.key vdCov* 
	clear
run: clean lib run_tb report  html
	
	

