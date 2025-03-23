



// environment class 

class tb_env extends uvm_env;

// factory registration

           `uvm_component_utils(tb_env)

// declaring the handle for vritual seqr and source agent top and destin agent top i dont know 

         source_agent_top  source_agth;
         destin_agent_top  destin_agth;
         tb_scoreboard     sb;


// declaring the int varialbles for no of wr agent and  no of read agent - idont know


// declaring for the scoreboard and virtual sequencer no  i dont know

         virtual_seqr  v_seqr;
 
// declaring the  handle for the env_config class to get and 

       router_env_config m_cfg;

// construction new function
 
         function new(string name = "tb_env", uvm_component parent = null);

                       super.new(name,parent);

         endfunction:new
        
// build phase 

        function void build_phase(uvm_phase phase);
              super.build_phase(phase);
               if(! uvm_config_db #(router_env_config) :: get(this,"","router_env_config",m_cfg))
                     `uvm_fatal(get_full_name(),"cannot get the router_env_config handle m_cfg from test in env_tb ")
               source_agth = source_agent_top :: type_id :: create("source_agth",this);
               destin_agth = destin_agent_top :: type_id :: create("destin_agth",this);
               sb          = tb_scoreboard    :: type_id :: create("sb",this); 
               v_seqr      = virtual_seqr     :: type_id :: create("v_seqr",this);      

        endfunction
         

// connect phase

       function void connect_phase(uvm_phase phase);

              foreach(v_seqr.s_seqr[i])
                    begin
                       v_seqr.s_seqr[i] = source_agth.agth[i].seqr;
                    end
					
			  for(int j = 0; j < m_cfg.no_of_source;j++)
                    begin			  
			             source_agth.agth[j].monh.smon_port.connect(sb.source_fifo[j].analysis_export);
			        end
					
              for(int i = 0; i < m_cfg.no_of_destin ; i++)
                    begin
                         destin_agth.agth[i].monh.dmon_port.connect(sb.destin_fifo[i].analysis_export);
                    end						 

       endfunction:connect_phase



endclass:tb_env


/*

UVM_INFO @ 0: reporter [RNTST] Running test small_seq_test...
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
----------------------------------------------------------------
Name                         Type                    Size  Value
----------------------------------------------------------------
uvm_test_top                 small_seq_test          -     @474 
  envh                       tb_env                  -     @499 
    destin_agth              destin_agent_top        -     @516 
      agth[0]                destin_agent            -     @660 
        drvh                 destin_driver           -     @699 
          rsp_port           uvm_analysis_port       -     @716 
          seq_item_port      uvm_seq_item_pull_port  -     @707 
        monh                 destin_monitor          -     @691 
        seqr                 destin_seqr             -     @725 
          rsp_export         uvm_analysis_export     -     @733 
          seq_item_export    uvm_seq_item_pull_imp   -     @839 
          arbitration_queue  array                   0     -    
          lock_queue         array                   0     -    
          num_last_reqs      integral                32    'd1  
          num_last_rsps      integral                32    'd1  
      agth[1]                destin_agent            -     @669 
        drvh                 destin_driver           -     @868 
          rsp_port           uvm_analysis_port       -     @885 
          seq_item_port      uvm_seq_item_pull_port  -     @876 
        monh                 destin_monitor          -     @860 
        seqr                 destin_seqr             -     @894 
          rsp_export         uvm_analysis_export     -     @902 
          seq_item_export    uvm_seq_item_pull_imp   -     @1008
          arbitration_queue  array                   0     -    
          lock_queue         array                   0     -    
          num_last_reqs      integral                32    'd1  
          num_last_rsps      integral                32    'd1  
      agth[2]                destin_agent            -     @678 
        drvh                 destin_driver           -     @1037
          rsp_port           uvm_analysis_port       -     @1054
          seq_item_port      uvm_seq_item_pull_port  -     @1045
        monh                 destin_monitor          -     @1029
        seqr                 destin_seqr             -     @1063
          rsp_export         uvm_analysis_export     -     @1071
          seq_item_export    uvm_seq_item_pull_imp   -     @1177
          arbitration_queue  array                   0     -    
          lock_queue         array                   0     -    
          num_last_reqs      integral                32    'd1  
          num_last_rsps      integral                32    'd1  
    sb                       tb_scoreboard           -     @524 
    source_agth              source_agent_top        -     @508 
      agth[0]                source_agent            -     @1198
        drvh                 source_driver           -     @1219
          rsp_port           uvm_analysis_port       -     @1236
          seq_item_port      uvm_seq_item_pull_port  -     @1227
        monh                 source_monitor          -     @1211
        seqr                 source_seqr             -     @1245
          rsp_export         uvm_analysis_export     -     @1253
          seq_item_export    uvm_seq_item_pull_imp   -     @1359
          arbitration_queue  array                   0     -    
          lock_queue         array                   0     -    
          num_last_reqs      integral                32    'd1  
          num_last_rsps      integral                32    'd1  
    v_seqr                   virtual_seqr            -     @532 
      rsp_export             uvm_analysis_export     -     @540 
      seq_item_export        uvm_seq_item_pull_imp   -     @646 
      arbitration_queue      array                   0     -    
      lock_queue             array                   0     -    
      num_last_reqs          integral                32    'd1  
      num_last_rsps          integral                32    'd1  
----------------------------------------------------------------

-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
smon              source_xtn  -     @1399
  destin_address  integral    2     'd1  
  pay_lenth       integral    6     'd6  
  header_byte     integral    8     'd25 
  payload[0]      integral    8     'd126
  payload[1]      integral    8     215  
  payload[2]      integral    8     'd15 
  payload[3]      integral    8     195  
  payload[4]      integral    8     'd79 
  payload[5]      integral    8     168  
  parity_byte     integral    8     154  
-----------------------------------------
-------------------------------------------------------------------------------------------------
Name                           Type        Size  Value                                           
-------------------------------------------------------------------------------------------------
req                            source_xtn  -     @1428                                           
  begin_time                   time        64    30000                                           
  depth                        int         32    'd2                                             
  parent sequence (name)       string      5     s_seq                                           
  parent sequence (full name)  string      48    uvm_test_top.envh.source_agth.agth[0].seqr.s_seq
  sequencer                    string      42    uvm_test_top.envh.source_agth.agth[0].seqr      
  destin_address               integral    2     'd1                                             
  pay_lenth                    integral    6     'd6                                             
  header_byte                  integral    8     'd25                                            
  payload[0]                   integral    8     'd126                                           
  payload[1]                   integral    8     215                                             
  payload[2]                   integral    8     'd15                                            
  payload[3]                   integral    8     195                                             
  payload[4]                   integral    8     'd79                                            
  payload[5]                   integral    8     168                                             
  parity_byte                  integral    8     154                                             
-------------------------------------------------------------------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
dmon           destin_xtn  -     @1387
  des_address  integral    2     'd1  
  pay_lenth    integral    6     'd6  
  header_byte  integral    8     'd25 
  payload[0]   integral    8     'd126
  payload[1]   integral    8     215  
  payload[2]   integral    8     'd15 
  payload[3]   integral    8     195  
  payload[4]   integral    8     'd79 
  payload[5]   integral    8     168  
  parity_byte  integral    8     154  
  delay        integral    6     'd0  
--------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
req            destin_xtn  -     @1423
  des_address  integral    2     'd0  
  pay_lenth    integral    6     'd0  
  header_byte  integral    8     'd0  
  parity_byte  integral    8     'd0  
  delay        integral    6     'd4  
--------------------------------------
UVM_INFO /home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_objection.svh(1274) @ 390000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase

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
$finish at simulation time               390000
           V C S   S i m u l a t i o n   R e p o r t 
Time: 390000 ps

*/

