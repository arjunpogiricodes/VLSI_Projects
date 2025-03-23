



// Top module 

module top();

// including the  uvm file  

       import uvm_pkg :: *;
      // include "uvm_macros.svh"
 
// importing  the tb files 

       import router_pkg :: *; 

      
// generating clock
  
       bit clk = 1'b0;
       always #10 clk = ~clk;          
      
// instantiating interace

        router_source_if VIF(clk);
        router_destin_if VIF0(clk);
        router_destin_if VIF1(clk);
        router_destin_if VIF2(clk);



 // instantiating DUT
// top module
//module router_top(clk,reset,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,error,busy);


     router_top DUT(
                    .clk(clk),
                    .reset(VIF.reset),
                    .read_enb_0(VIF0.read_enb),
                    .read_enb_1(VIF1.read_enb),
                    .read_enb_2(VIF2.read_enb),
                    .data_in(VIF.data_in),
                    .pkt_valid(VIF.pkt_valid),
                    .data_out_0(VIF0.data_out),
                    .data_out_1(VIF1.data_out),
                    .data_out_2(VIF2.data_out),
                    .valid_out_0(VIF0.valid_out),
                    .valid_out_1(VIF1.valid_out),
                    .valid_out_2(VIF2.valid_out),
                    .error(VIF.error),
                    .busy(VIF.busy)

                     );


        initial begin

                 `ifdef VCS
                  $fsdbDumpvars(0,top);
                 `endif 

// setting the virtual interface  for source agent and 3 destination agents	
                 uvm_config_db #(virtual router_source_if) :: set(null,"*","vif",VIF);
                 uvm_config_db #(virtual router_destin_if) :: set(null,"*","vif0",VIF0);
                 uvm_config_db #(virtual router_destin_if) :: set(null,"*","vif1",VIF1);
                 uvm_config_db #(virtual router_destin_if) :: set(null,"*","vif2",VIF2);
// calling the runtest()

                  run_test();
            end   

	property pkt_vld;
		@(posedge clk) VIF.busy |=> !(VIF.pkt_valid);
	endproperty

	property stable; 
		@(posedge clk) VIF.busy |-> $stable(VIF.data_in); 
	endproperty 

	property rd_enb1; 
		@(posedge clk) $rose(VIF0.valid_out) |=> ##[0:29] (VIF0.read_enb);
	endproperty 

	property rd_enb2; 
		@(posedge clk) $rose(VIF1.valid_out) |=> ##[0:29] (VIF1.read_enb);
	endproperty 	

	property rd_enb3; 
		@(posedge clk) $rose(VIF2.valid_out) |=> ##[0:29] (VIF2.read_enb);
	endproperty 	


	property valid ; 
		@(posedge clk)
        	$rose(VIF.pkt_valid) |-> ##3 VIF0.valid_out| VIF1.valid_out| VIF2.valid_out;
	endproperty 

	property read_1;
        	@(posedge clk)
        	$fell(VIF0.valid_out) |=> $fell(VIF0.read_enb);
	endproperty

	property read_2;
        	@(posedge clk)
       		 $fell(VIF1.valid_out) |=> $fell(VIF1.read_enb);
	endproperty

	property read_3;
      		  @(posedge clk)
        	$fell(VIF2.valid_out) |=> $fell(VIF2.read_enb);
	endproperty

/*
	PKT_V: cover property(pkt_vld); 
	STAVEL: cover property(stable); 
	READ_EN0: cover property (rd_enb1); 
	READ_EN1: cover property (rd_enb2); 
	READ_EN2: cover property (rd_enb3); 
	VALID_O: cover property (valid); 	
	READ0: cover property(read_1); 
	READ1: cover property(read_2); 
	READ2: cover property(read_3); 
*/

	PKT_V: assert property(pkt_vld); 
	STAVEL: assert property(stable); 
	READ_EN0: assert property (rd_enb1); 
	READ_EN1: assert property (rd_enb2); 
	READ_EN2: assert property (rd_enb3); 
	VALID_O: assert property (valid); 	
	READ0: assert property(read_1); 
	READ1: assert property(read_2); 
	READ2: assert property(read_3); 

	

/*

sv_cmp_VCS:
	vcs -l vcs.log -timescale=1ns/1ps -sverilog -ntb_opts uvm -debug_access+all -full64 -cm assert -kdb -assert enable_diag -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1)
		      
run_test1_VCS:	clean  sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave1.fsdb asser_enable_coverage=1 -cm_dir ./mem_cov1 +ntb_random_seed=674903168 +UVM_TESTNAME=rout_small_pkt_test 
	urg -dir mem_cov1.vdb -format both -report urgReport1
												
run_test2_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave2.fsdb asser_enable_coverage=1 -cm_dir ./mem_cov2 +ntb_random_seed=4016129046 +UVM_TESTNAME=rout_medium_pkt_test 
	urg -dir mem_cov2.vdb -format both -report urgReport2
	
run_test3_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave3.fsdb asser_enable_coverage=1 -cm_dir ./mem_cov3 +ntb_random_seed=352477780 +UVM_TESTNAME=rout_large_pkt_test 
	urg -dir mem_cov3.vdb -format both -report urgReport3
	
run_test4_VCS:	sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave4.fsdb asser_enable_coverage=1 -cm_dir ./mem_cov4 +ntb_random_seed=2122935111 +UVM_TESTNAME=rout_random_pkt_test 
	urg -dir mem_cov4.vdb -format both -report urgReport4

run_test5_VCS: sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave5.fsdb asser_enable_coverage=1 -cm_dir ./mem_cov5 +ntb_random_seed=2324921991 +UVM_TESTNAME=rout_soft_reset_pkt_test 
	urg -dir mem_cov5.vdb -format both -report urgReport5
        
run_test6_VCS:  sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave6.fsdb asser_enable_coverage=1 -cm_dir ./mem_cov6 +ntb_random_seed_automatic +UVM_TESTNAME=rout_error_pkt_test 
	urg -dir mem_cov6.vdb -format both -report urgReport6


view_wave1_VCS: 
	verdi -ssf wave1.fsdb
	
view_wave2_VCS: 
	verdi -ssf wave2.fsdb

view_wave3_VCS: 
	verdi -ssf wave3.fsdb

view_wave4_VCS: 
	verdi -ssf wave4.fsdb		
	
view_wave5_VCS: 
	verdi -ssf wave5.fsdb

view_wave6_VCS:
	verdi -ssf wave6.fsdb

report_VCS:
	urg -dir mem_cov1.vdb mem_cov2.vdb mem_cov3.vdb mem_cov4.vdb mem_cov5.vdb mem_cov6.vdb -dbname merged_dir/merged_test -format both -report urgReport

regress_VCS: clean_VCS sv_cmp_VCS run_test1_VCS run_test2_VCS run_test3_VCS run_test4_VCS run_test6_VCS report_VCS

covhtml_VCS:
	firefox urgReport/grp*.html &

covtxt_VCS:
	vi urgReport/grp*.txt


cov_VCS:
	verdi -cov -covdir merged_dir.vdb

clean_VCS:
	rm -rf simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h urgReport* *.fsdb novas* verdi*
	clear
*/


//qUESTA

/*
sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1) 	
	
run_test1_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf wave_file1.wlf -l test1.log  -sv_seed random  work.top +UVM_TESTNAME=rout_small_pkt_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1
	
run_test2_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2)  -wlf wave_file2.wlf -l test2.log  -sv_seed random  work.top +UVM_TESTNAME=rout_medium_pkt_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2
	
run_test3_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3)  -wlf wave_file3.wlf -l test3.log  -sv_seed random  work.top +UVM_TESTNAME=rout_large_pkt_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov3
	
run_test4_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave_file4.wlf -l test4.log  -sv_seed random  work.top +UVM_TESTNAME=rout_random_pkt_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov4
	
run_test5_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave_file5.wlf -l test5.log  -sv_seed random  work.top +UVM_TESTNAME=rout_soft_reset_pkt_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov5
	
run_test6_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave_file6.wlf -l test6.log  -sv_seed random  work.top +UVM_TESTNAME=rout_error_pkt_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov6
	
view_wave1_Questa:
	vsim -view wave_file1.wlf
	
view_wave2_Questa:
	vsim -view wave_file2.wlf
	
view_wave3_Questa:
	vsim -view wave_file3.wlf
	
view_wave4_Questa:
	vsim -view wave_file4.wlf

view_wave5_Questa:
	vsim -view wave_file5.wlf

view_wave6_Questa:
	vsim -view wave_file6.wlf

report_Questa:
	vcover merge mem_cov1 mem_cov2 mem_cov3 mem_cov4 mem_cov5 mem_cov6
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov

regress_Questa: clean_Questa run_test1_Questa run_test2_Questa run_test3_Questa run_test4_Questa run_test6_Questa report_Questa cov_Questa

cov_Questa:
	firefox covhtmlreport/index.html&
	
clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear

*/
endmodule



/*


output  PACKETS:

UVM_INFO @ 0: reporter [RNTST] Running test large_seq_test...
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
--------------------------------------------------------------------
Name                         Type                        Size  Value
--------------------------------------------------------------------
uvm_test_top                 large_seq_test              -     @474 
  envh                       tb_env                      -     @499 
    destin_agth              destin_agent_top            -     @516 
      agth[0]                destin_agent                -     @660 
        drvh                 destin_driver               -     @708 
          rsp_port           uvm_analysis_port           -     @725 
          seq_item_port      uvm_seq_item_pull_port      -     @716 
        monh                 destin_monitor              -     @691 
          dmon_port          uvm_analysis_port           -     @699 
        seqr                 destin_seqr                 -     @734 
          rsp_export         uvm_analysis_export         -     @742 
          seq_item_export    uvm_seq_item_pull_imp       -     @848 
          arbitration_queue  array                       0     -    
          lock_queue         array                       0     -    
          num_last_reqs      integral                    32    'd1  
          num_last_rsps      integral                    32    'd1  
      agth[1]                destin_agent                -     @669 
        drvh                 destin_driver               -     @886 
          rsp_port           uvm_analysis_port           -     @903 
          seq_item_port      uvm_seq_item_pull_port      -     @894 
        monh                 destin_monitor              -     @869 
          dmon_port          uvm_analysis_port           -     @877 
        seqr                 destin_seqr                 -     @912 
          rsp_export         uvm_analysis_export         -     @920 
          seq_item_export    uvm_seq_item_pull_imp       -     @1026
          arbitration_queue  array                       0     -    
          lock_queue         array                       0     -    
          num_last_reqs      integral                    32    'd1  
          num_last_rsps      integral                    32    'd1  
      agth[2]                destin_agent                -     @678 
        drvh                 destin_driver               -     @1064
          rsp_port           uvm_analysis_port           -     @1081
          seq_item_port      uvm_seq_item_pull_port      -     @1072
        monh                 destin_monitor              -     @1047
          dmon_port          uvm_analysis_port           -     @1055
        seqr                 destin_seqr                 -     @1090
          rsp_export         uvm_analysis_export         -     @1098
          seq_item_export    uvm_seq_item_pull_imp       -     @1204
          arbitration_queue  array                       0     -    
          lock_queue         array                       0     -    
          num_last_reqs      integral                    32    'd1  
          num_last_rsps      integral                    32    'd1  
    sb                       tb_scoreboard               -     @524 
      destin_fifo[0]         uvm_tlm_analysis_fifo #(T)  -     @1275
        analysis_export      uvm_analysis_imp            -     @1319
        get_ap               uvm_analysis_port           -     @1310
        get_peek_export      uvm_get_peek_imp            -     @1292
        put_ap               uvm_analysis_port           -     @1301
        put_export           uvm_put_imp                 -     @1283
      destin_fifo[1]         uvm_tlm_analysis_fifo #(T)  -     @1328
        analysis_export      uvm_analysis_imp            -     @1372
        get_ap               uvm_analysis_port           -     @1363
        get_peek_export      uvm_get_peek_imp            -     @1345
        put_ap               uvm_analysis_port           -     @1354
        put_export           uvm_put_imp                 -     @1336
      destin_fifo[2]         uvm_tlm_analysis_fifo #(T)  -     @1381
        analysis_export      uvm_analysis_imp            -     @1425
        get_ap               uvm_analysis_port           -     @1416
        get_peek_export      uvm_get_peek_imp            -     @1398
        put_ap               uvm_analysis_port           -     @1407
        put_export           uvm_put_imp                 -     @1389
      source_fifo            uvm_tlm_analysis_fifo #(T)  -     @1222
        analysis_export      uvm_analysis_imp            -     @1266
        get_ap               uvm_analysis_port           -     @1257
        get_peek_export      uvm_get_peek_imp            -     @1239
        put_ap               uvm_analysis_port           -     @1248
        put_export           uvm_put_imp                 -     @1230
    source_agth              source_agent_top            -     @508 
      agth[0]                source_agent                -     @1439
        drvh                 source_driver               -     @1469
          rsp_port           uvm_analysis_port           -     @1486
          seq_item_port      uvm_seq_item_pull_port      -     @1477
        monh                 source_monitor              -     @1452
          smon_port          uvm_analysis_port           -     @1460
        seqr                 source_seqr                 -     @1495
          rsp_export         uvm_analysis_export         -     @1503
          seq_item_export    uvm_seq_item_pull_imp       -     @1609
          arbitration_queue  array                       0     -    
          lock_queue         array                       0     -    
          num_last_reqs      integral                    32    'd1  
          num_last_rsps      integral                    32    'd1  
    v_seqr                   virtual_seqr                -     @532 
      rsp_export             uvm_analysis_export         -     @540 
      seq_item_export        uvm_seq_item_pull_imp       -     @646 
      arbitration_queue      array                       0     -    
      lock_queue             array                       0     -    
      num_last_reqs          integral                    32    'd1  
      num_last_rsps          integral                    32    'd1  
--------------------------------------------------------------------

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1649
  destin_address  integral    2     2    
  pay_lenth       integral    6     43   
  header_byte     integral    8     174  
  payload[0]      integral    8     'd35 
  payload[1]      integral    8     'd59 
  payload[2]      integral    8     247  
  payload[3]      integral    8     'd40 
  payload[4]      integral    8     249  
  payload[5]      integral    8     'd38 
  payload[6]      integral    8     'd7  
  payload[7]      integral    8     183  
  payload[8]      integral    8     'd56 
  payload[9]      integral    8     251  
  payload[10]     integral    8     207  
  payload[11]     integral    8     175  
  payload[12]     integral    8     'd54 
  payload[13]     integral    8     'd21 
  payload[14]     integral    8     181  
  payload[15]     integral    8     164  
  payload[16]     integral    8     'd108
  payload[17]     integral    8     134  
  payload[18]     integral    8     'd60 
  payload[19]     integral    8     230  
  payload[20]     integral    8     199  
  payload[21]     integral    8     166  
  payload[22]     integral    8     'd1  
  payload[23]     integral    8     204  
  payload[24]     integral    8     'd91 
  payload[25]     integral    8     'd107
  payload[26]     integral    8     215  
  payload[27]     integral    8     'd25 
  payload[28]     integral    8     225  
  payload[29]     integral    8     'd80 
  payload[30]     integral    8     230  
  payload[31]     integral    8     'd61 
  payload[32]     integral    8     178  
  payload[33]     integral    8     214  
  payload[34]     integral    8     'd65 
  payload[35]     integral    8     173  
  payload[36]     integral    8     'd13 
  payload[37]     integral    8     'd100
  payload[38]     integral    8     'd103
  payload[39]     integral    8     226  
  payload[40]     integral    8     'd72 
  payload[41]     integral    8     'd38 
  payload[42]     integral    8     'd73 
  parity_byte     integral    8     220  
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1643
  des_address  integral    2     2    
  pay_lenth    integral    6     43   
  header_byte  integral    8     174  
  payload[0]   integral    8     'd35 
  payload[1]   integral    8     'd59 
  payload[2]   integral    8     247  
  payload[3]   integral    8     'd40 
  payload[4]   integral    8     249  
  payload[5]   integral    8     'd38 
  payload[6]   integral    8     'd7  
  payload[7]   integral    8     183  
  payload[8]   integral    8     'd56 
  payload[9]   integral    8     251  
  payload[10]  integral    8     207  
  payload[11]  integral    8     175  
  payload[12]  integral    8     'd54 
  payload[13]  integral    8     'd21 
  payload[14]  integral    8     181  
  payload[15]  integral    8     164  
  payload[16]  integral    8     'd108
  payload[17]  integral    8     134  
  payload[18]  integral    8     'd60 
  payload[19]  integral    8     230  
  payload[20]  integral    8     199  
  payload[21]  integral    8     166  
  payload[22]  integral    8     'd1  
  payload[23]  integral    8     204  
  payload[24]  integral    8     'd91 
  payload[25]  integral    8     'd107
  payload[26]  integral    8     215  
  payload[27]  integral    8     'd25 
  payload[28]  integral    8     225  
  payload[29]  integral    8     'd80 
  payload[30]  integral    8     230  
  payload[31]  integral    8     'd61 
  payload[32]  integral    8     178  
  payload[33]  integral    8     214  
  payload[34]  integral    8     'd65 
  payload[35]  integral    8     173  
  payload[36]  integral    8     'd13 
  payload[37]  integral    8     'd100
  payload[38]  integral    8     'd103
  payload[39]  integral    8     226  
  payload[40]  integral    8     'd72 
  payload[41]  integral    8     'd38 
  payload[42]  integral    8     'd73 
  parity_byte  integral    8     220  
  delay        integral    6     'd0  
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED    


=========================================================================


=========================================================================


 source  side functional coverage = 38.889 


 destin  side functional coverage = 33.333 


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1804
  destin_address  integral    2     2    
  pay_lenth       integral    6     46   
  header_byte     integral    8     186  
  payload[0]      integral    8     'd81 
  payload[1]      integral    8     199  
  payload[2]      integral    8     185  
  payload[3]      integral    8     'd92 
  payload[4]      integral    8     'd83 
  payload[5]      integral    8     'd15 
  payload[6]      integral    8     188  
  payload[7]      integral    8     142  
  payload[8]      integral    8     170  
  payload[9]      integral    8     206  
  payload[10]     integral    8     148  
  payload[11]     integral    8     192  
  payload[12]     integral    8     215  
  payload[13]     integral    8     197  
  payload[14]     integral    8     'd35 
  payload[15]     integral    8     172  
  payload[16]     integral    8     250  
  payload[17]     integral    8     208  
  payload[18]     integral    8     'd111
  payload[19]     integral    8     'd127
  payload[20]     integral    8     194  
  payload[21]     integral    8     'd46 
  payload[22]     integral    8     160  
  payload[23]     integral    8     'd28 
  payload[24]     integral    8     180  
  payload[25]     integral    8     133  
  payload[26]     integral    8     222  
  payload[27]     integral    8     'd105
  payload[28]     integral    8     'd56 
  payload[29]     integral    8     130  
  payload[30]     integral    8     224  
  payload[31]     integral    8     231  
  payload[32]     integral    8     133  
  payload[33]     integral    8     145  
  payload[34]     integral    8     'd16 
  payload[35]     integral    8     'd107
  payload[36]     integral    8     129  
  payload[37]     integral    8     'd77 
  payload[38]     integral    8     187  
  payload[39]     integral    8     'd123
  payload[40]     integral    8     191  
  payload[41]     integral    8     'd98 
  payload[42]     integral    8     235  
  payload[43]     integral    8     'd51 
  payload[44]     integral    8     174  
  payload[45]     integral    8     'd54 
  parity_byte     integral    8     165  
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1808
  des_address  integral    2     2    
  pay_lenth    integral    6     46   
  header_byte  integral    8     186  
  payload[0]   integral    8     'd81 
  payload[1]   integral    8     199  
  payload[2]   integral    8     185  
  payload[3]   integral    8     'd92 
  payload[4]   integral    8     'd83 
  payload[5]   integral    8     'd15 
  payload[6]   integral    8     188  
  payload[7]   integral    8     142  
  payload[8]   integral    8     170  
  payload[9]   integral    8     206  
  payload[10]  integral    8     148  
  payload[11]  integral    8     192  
  payload[12]  integral    8     215  
  payload[13]  integral    8     197  
  payload[14]  integral    8     'd35 
  payload[15]  integral    8     172  
  payload[16]  integral    8     250  
  payload[17]  integral    8     208  
  payload[18]  integral    8     'd111
  payload[19]  integral    8     'd127
  payload[20]  integral    8     194  
  payload[21]  integral    8     'd46 
  payload[22]  integral    8     160  
  payload[23]  integral    8     'd28 
  payload[24]  integral    8     180  
  payload[25]  integral    8     133  
  payload[26]  integral    8     222  
  payload[27]  integral    8     'd105
  payload[28]  integral    8     'd56 
  payload[29]  integral    8     130  
  payload[30]  integral    8     224  
  payload[31]  integral    8     231  
  payload[32]  integral    8     133  
  payload[33]  integral    8     145  
  payload[34]  integral    8     'd16 
  payload[35]  integral    8     'd107
  payload[36]  integral    8     129  
  payload[37]  integral    8     'd77 
  payload[38]  integral    8     187  
  payload[39]  integral    8     'd123
  payload[40]  integral    8     191  
  payload[41]  integral    8     'd98 
  payload[42]  integral    8     235  
  payload[43]  integral    8     'd51 
  payload[44]  integral    8     174  
  payload[45]  integral    8     'd54 
  parity_byte  integral    8     165  
  delay        integral    6     'd0  
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED    


=========================================================================


=========================================================================


 source  side functional coverage = 38.889 


 destin  side functional coverage = 33.333 


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1827
  destin_address  integral    2     2    
  pay_lenth       integral    6     46   
  header_byte     integral    8     186  
  payload[0]      integral    8     'd20 
  payload[1]      integral    8     160  
  payload[2]      integral    8     177  
  payload[3]      integral    8     'd72 
  payload[4]      integral    8     158  
  payload[5]      integral    8     'd93 
  payload[6]      integral    8     193  
  payload[7]      integral    8     'd61 
  payload[8]      integral    8     'd104
  payload[9]      integral    8     'd112
  payload[10]     integral    8     239  
  payload[11]     integral    8     'd112
  payload[12]     integral    8     'd72 
  payload[13]     integral    8     149  
  payload[14]     integral    8     'd17 
  payload[15]     integral    8     'd95 
  payload[16]     integral    8     'd86 
  payload[17]     integral    8     190  
  payload[18]     integral    8     'd48 
  payload[19]     integral    8     137  
  payload[20]     integral    8     193  
  payload[21]     integral    8     166  
  payload[22]     integral    8     'd6  
  payload[23]     integral    8     154  
  payload[24]     integral    8     'd106
  payload[25]     integral    8     'd4  
  payload[26]     integral    8     'd74 
  payload[27]     integral    8     'd2  
  payload[28]     integral    8     220  
  payload[29]     integral    8     'd96 
  payload[30]     integral    8     'd66 
  payload[31]     integral    8     'd49 
  payload[32]     integral    8     150  
  payload[33]     integral    8     'd32 
  payload[34]     integral    8     148  
  payload[35]     integral    8     200  
  payload[36]     integral    8     'd87 
  payload[37]     integral    8     199  
  payload[38]     integral    8     157  
  payload[39]     integral    8     'd66 
  payload[40]     integral    8     'd72 
  payload[41]     integral    8     'd104
  payload[42]     integral    8     157  
  payload[43]     integral    8     158  
  payload[44]     integral    8     'd89 
  payload[45]     integral    8     'd97 
  parity_byte     integral    8     'd33 
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1831
  des_address  integral    2     2    
  pay_lenth    integral    6     46   
  header_byte  integral    8     186  
  payload[0]   integral    8     'd20 
  payload[1]   integral    8     160  
  payload[2]   integral    8     177  
  payload[3]   integral    8     'd72 
  payload[4]   integral    8     158  
  payload[5]   integral    8     'd93 
  payload[6]   integral    8     193  
  payload[7]   integral    8     'd61 
  payload[8]   integral    8     'd104
  payload[9]   integral    8     'd112
  payload[10]  integral    8     239  
  payload[11]  integral    8     'd112
  payload[12]  integral    8     'd72 
  payload[13]  integral    8     149  
  payload[14]  integral    8     'd17 
  payload[15]  integral    8     'd95 
  payload[16]  integral    8     'd86 
  payload[17]  integral    8     190  
  payload[18]  integral    8     'd48 
  payload[19]  integral    8     137  
  payload[20]  integral    8     193  
  payload[21]  integral    8     166  
  payload[22]  integral    8     'd6  
  payload[23]  integral    8     154  
  payload[24]  integral    8     'd106
  payload[25]  integral    8     'd4  
  payload[26]  integral    8     'd74 
  payload[27]  integral    8     'd2  
  payload[28]  integral    8     220  
  payload[29]  integral    8     'd96 
  payload[30]  integral    8     'd66 
  payload[31]  integral    8     'd49 
  payload[32]  integral    8     150  
  payload[33]  integral    8     'd32 
  payload[34]  integral    8     148  
  payload[35]  integral    8     200  
  payload[36]  integral    8     'd87 
  payload[37]  integral    8     199  
  payload[38]  integral    8     157  
  payload[39]  integral    8     'd66 
  payload[40]  integral    8     'd72 
  payload[41]  integral    8     'd104
  payload[42]  integral    8     157  
  payload[43]  integral    8     158  
  payload[44]  integral    8     'd89 
  payload[45]  integral    8     'd97 
  parity_byte  integral    8     'd33 
  delay        integral    6     'd0  
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED    


=========================================================================


=========================================================================


 source  side functional coverage = 38.889 


 destin  side functional coverage = 33.333 


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1849
  destin_address  integral    2     2    
  pay_lenth       integral    6     42   
  header_byte     integral    8     170  
  payload[0]      integral    8     'd124
  payload[1]      integral    8     'd8  
  payload[2]      integral    8     'd24 
  payload[3]      integral    8     'd48 
  payload[4]      integral    8     247  
  payload[5]      integral    8     156  
  payload[6]      integral    8     'd75 
  payload[7]      integral    8     'd11 
  payload[8]      integral    8     'd18 
  payload[9]      integral    8     161  
  payload[10]     integral    8     'd37 
  payload[11]     integral    8     'd39 
  payload[12]     integral    8     195  
  payload[13]     integral    8     162  
  payload[14]     integral    8     'd73 
  payload[15]     integral    8     197  
  payload[16]     integral    8     'd82 
  payload[17]     integral    8     'd27 
  payload[18]     integral    8     'd49 
  payload[19]     integral    8     190  
  payload[20]     integral    8     'd67 
  payload[21]     integral    8     218  
  payload[22]     integral    8     'd37 
  payload[23]     integral    8     175  
  payload[24]     integral    8     199  
  payload[25]     integral    8     159  
  payload[26]     integral    8     'd37 
  payload[27]     integral    8     'd59 
  payload[28]     integral    8     130  
  payload[29]     integral    8     171  
  payload[30]     integral    8     'd78 
  payload[31]     integral    8     134  
  payload[32]     integral    8     'd103
  payload[33]     integral    8     128  
  payload[34]     integral    8     'd20 
  payload[35]     integral    8     'd45 
  payload[36]     integral    8     'd25 
  payload[37]     integral    8     'd79 
  payload[38]     integral    8     'd39 
  payload[39]     integral    8     'd116
  payload[40]     integral    8     'd29 
  payload[41]     integral    8     193  
  parity_byte     integral    8     244  
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1853
  des_address  integral    2     2    
  pay_lenth    integral    6     42   
  header_byte  integral    8     170  
  payload[0]   integral    8     'd124
  payload[1]   integral    8     'd8  
  payload[2]   integral    8     'd24 
  payload[3]   integral    8     'd48 
  payload[4]   integral    8     247  
  payload[5]   integral    8     156  
  payload[6]   integral    8     'd75 
  payload[7]   integral    8     'd11 
  payload[8]   integral    8     'd18 
  payload[9]   integral    8     161  
  payload[10]  integral    8     'd37 
  payload[11]  integral    8     'd39 
  payload[12]  integral    8     195  
  payload[13]  integral    8     162  
  payload[14]  integral    8     'd73 
  payload[15]  integral    8     197  
  payload[16]  integral    8     'd82 
  payload[17]  integral    8     'd27 
  payload[18]  integral    8     'd49 
  payload[19]  integral    8     190  
  payload[20]  integral    8     'd67 
  payload[21]  integral    8     218  
  payload[22]  integral    8     'd37 
  payload[23]  integral    8     175  
  payload[24]  integral    8     199  
  payload[25]  integral    8     159  
  payload[26]  integral    8     'd37 
  payload[27]  integral    8     'd59 
  payload[28]  integral    8     130  
  payload[29]  integral    8     171  
  payload[30]  integral    8     'd78 
  payload[31]  integral    8     134  
  payload[32]  integral    8     'd103
  payload[33]  integral    8     128  
  payload[34]  integral    8     'd20 
  payload[35]  integral    8     'd45 
  payload[36]  integral    8     'd25 
  payload[37]  integral    8     'd79 
  payload[38]  integral    8     'd39 
  payload[39]  integral    8     'd116
  payload[40]  integral    8     'd29 
  payload[41]  integral    8     193  
  parity_byte  integral    8     244  
  delay        integral    6     'd0  
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED    


=========================================================================


=========================================================================


 source  side functional coverage = 38.889 


 destin  side functional coverage = 33.333 


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1871
  destin_address  integral    2     2    
  pay_lenth       integral    6     44   
  header_byte     integral    8     178  
  payload[0]      integral    8     'd58 
  payload[1]      integral    8     'd45 
  payload[2]      integral    8     'd56 
  payload[3]      integral    8     247  
  payload[4]      integral    8     'd12 
  payload[5]      integral    8     159  
  payload[6]      integral    8     203  
  payload[7]      integral    8     'd122
  payload[8]      integral    8     'd33 
  payload[9]      integral    8     'd8  
  payload[10]     integral    8     'd118
  payload[11]     integral    8     'd15 
  payload[12]     integral    8     'd24 
  payload[13]     integral    8     'd70 
  payload[14]     integral    8     'd119
  payload[15]     integral    8     'd67 
  payload[16]     integral    8     132  
  payload[17]     integral    8     'd19 
  payload[18]     integral    8     164  
  payload[19]     integral    8     'd39 
  payload[20]     integral    8     'd84 
  payload[21]     integral    8     'd10 
  payload[22]     integral    8     'd44 
  payload[23]     integral    8     'd74 
  payload[24]     integral    8     173  
  payload[25]     integral    8     'd62 
  payload[26]     integral    8     239  
  payload[27]     integral    8     'd12 
  payload[28]     integral    8     254  
  payload[29]     integral    8     'd3  
  payload[30]     integral    8     'd27 
  payload[31]     integral    8     138  
  payload[32]     integral    8     'd66 
  payload[33]     integral    8     250  
  payload[34]     integral    8     138  
  payload[35]     integral    8     'd0  
  payload[36]     integral    8     'd67 
  payload[37]     integral    8     191  
  payload[38]     integral    8     159  
  payload[39]     integral    8     248  
  payload[40]     integral    8     230  
  payload[41]     integral    8     186  
  payload[42]     integral    8     'd83 
  payload[43]     integral    8     'd47 
  parity_byte     integral    8     203  
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1875
  des_address  integral    2     2    
  pay_lenth    integral    6     44   
  header_byte  integral    8     178  
  payload[0]   integral    8     'd58 
  payload[1]   integral    8     'd45 
  payload[2]   integral    8     'd56 
  payload[3]   integral    8     247  
  payload[4]   integral    8     'd12 
  payload[5]   integral    8     159  
  payload[6]   integral    8     203  
  payload[7]   integral    8     'd122
  payload[8]   integral    8     'd33 
  payload[9]   integral    8     'd8  
  payload[10]  integral    8     'd118
  payload[11]  integral    8     'd15 
  payload[12]  integral    8     'd24 
  payload[13]  integral    8     'd70 
  payload[14]  integral    8     'd119
  payload[15]  integral    8     'd67 
  payload[16]  integral    8     132  
  payload[17]  integral    8     'd19 
  payload[18]  integral    8     164  
  payload[19]  integral    8     'd39 
  payload[20]  integral    8     'd84 
  payload[21]  integral    8     'd10 
  payload[22]  integral    8     'd44 
  payload[23]  integral    8     'd74 
  payload[24]  integral    8     173  
  payload[25]  integral    8     'd62 
  payload[26]  integral    8     239  
  payload[27]  integral    8     'd12 
  payload[28]  integral    8     254  
  payload[29]  integral    8     'd3  
  payload[30]  integral    8     'd27 
  payload[31]  integral    8     138  
  payload[32]  integral    8     'd66 
  payload[33]  integral    8     250  
  payload[34]  integral    8     138  
  payload[35]  integral    8     'd0  
  payload[36]  integral    8     'd67 
  payload[37]  integral    8     191  
  payload[38]  integral    8     159  
  payload[39]  integral    8     248  
  payload[40]  integral    8     230  
  payload[41]  integral    8     186  
  payload[42]  integral    8     'd83 
  payload[43]  integral    8     'd47 
  parity_byte  integral    8     203  
  delay        integral    6     'd0  
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED    


=========================================================================


=========================================================================


 source  side functional coverage = 38.889 


 destin  side functional coverage = 33.333 


=========================================================================

UVM_INFO /home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_objection.svh(1274) @ 6910000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase

--- UVM Report Summary ---

** Report counts by severity
UVM_INFO :    3
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
** Report counts by id
[RNTST]     1
[TEST_DONE]     1
[UVMTOP]     1
$finish called from file "/home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_root.svh", line 437.
$finish at simulation time              6910000
           V C S   S i m u l a t i o n   R e p o r t 
Time: 6910000 ps


*/

