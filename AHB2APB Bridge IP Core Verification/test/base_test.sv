

// ------------------base test-----------------------//


class base_test extends uvm_test;

// factory registration

           `uvm_component_utils(base_test)

// virtual interface


// handle declarations

            tb_env env;
            tb_env_config m_cfg;
            
            ahb_config ahb_cfg[];
            apb_config apb_cfg[];

            int no_of_ahb=1;
            int no_of_apb=1;
            ahb_seq seq;
           
// constructor new

          function new (string name = "base_test",uvm_component parent = null);

                      super.new(name,parent);

          endfunction

// config function

          function void configure();

                 ahb_cfg = new [no_of_ahb];
                 apb_cfg = new [no_of_apb]; 
                 

               
                 m_cfg.no_of_ahb = no_of_ahb;
                 m_cfg.no_of_apb = no_of_apb;

                 m_cfg.ahb_cfg = new [m_cfg.no_of_ahb];
                 m_cfg.apb_cfg = new [m_cfg.no_of_apb]; 
        
                 foreach(ahb_cfg[i])
                       begin
                            ahb_cfg[i] = ahb_config :: type_id :: create($sformatf("ahb_cfg[%0d]",i));
                            ahb_cfg[i].is_active = UVM_ACTIVE; 
                             if(!uvm_config_db #(virtual ahbtoapb_interface) :: get(this,"","IN",ahb_cfg[i].vif))
                                   `uvm_fatal(get_full_name(),"cannot get the interface handle from IN are set in top")
                            m_cfg.ahb_cfg[i] = ahb_cfg[i];     
                        end

                 foreach(apb_cfg[i])
                       begin
                            apb_cfg[i] = apb_config :: type_id :: create($sformatf("apb_cfg[%0d]",i));
                            apb_cfg[i].is_active = UVM_ACTIVE; 
                             if(!uvm_config_db #(virtual ahbtoapb_interface) :: get(this,"","IN",apb_cfg[i].vif))
                                   `uvm_fatal(get_full_name(),"cannot get the interface handle from IN are set in top")
                            m_cfg.apb_cfg[i] = apb_cfg[i];     
                        end

          endfunction

// build phase

         function void build_phase(uvm_phase phase);

                   super.build_phase(phase);
   
                   m_cfg = tb_env_config :: type_id :: create ("m_cfg");
                   configure();
                   uvm_config_db #(tb_env_config) :: set(this,"*","tb_env_config",m_cfg);
                   env = tb_env :: type_id :: create("env",this); 

         endfunction

// end_of_elaboraqtion phase

           function void end_of_elaboration_phase(uvm_phase phase);


                   uvm_top.print_topology();

           endfunction

            
endclass

//--------------------------- single trans test ------------------------//


class single_test extends base_test;

// factory registration

         `uvm_component_utils(single_test)

// handle declarations

         single_seq s_seq;
         virtual_s_seq v_seq;

// function constructor

         function new(string name="single_test",uvm_component parent);

                   super.new(name,parent);

         endfunction

// run phase

         task run_phase(uvm_phase phase);

                     phase.raise_objection(this);
                      super.run_phase(phase);
                      s_seq = single_seq    :: type_id :: create("s_seq");
                      v_seq = virtual_s_seq :: type_id :: create("v_seq"); 
                     // s_seq.start(env.ahb_top.agent_ahb[0].seqr); 
                      v_seq.start(env.v_seqr);
	              #50;
                     phase.drop_objection(this);

        endtask
endclass


//---------------------- increment test -----------------------------//

class incr_test extends base_test;

// factory registration

         `uvm_component_utils(incr_test)

// handle declaration

         incr_seq i_seq;
         virtual_i_seq v_seq;

// function new constructor

        function new(string name = "incr_test",uvm_component parent);
 
                 super.new(name,parent);
 
        endfunction


// run phase

         task run_phase(uvm_phase phase);

                phase.raise_objection(this);
                   super.run_phase(phase);
                      v_seq = virtual_i_seq :: type_id :: create("v_seq"); 
                      v_seq.start(env.v_seqr); 
           	 #50;
                phase.drop_objection(this);
                
         endtask 
     
endclass

// -------------------- wrap test--------------------------//

class wrap_test extends base_test;

// factory registration

          `uvm_component_utils(wrap_test)
		  
// handle declaration

         wrap_seq w_seq;		  
         virtual_w_seq v_seq;	  
// function constructor

          function new(string name= "wrap_test",uvm_component parent);

                   super.new(name,parent);

          endfunction		  

// run test

          task run_phase(uvm_phase phase);
		            
                phase.raise_objection(this);
		    super.run_phase(phase);
                      v_seq = virtual_w_seq :: type_id :: create("v_seq"); 
                      v_seq.start(env.v_seqr); 
		      #50;
                phase.drop_objection(this);						 
						 		  
		  endtask


endclass


/*-------------------output-----------------------------*/

/*

UVM_INFO @ 0: reporter [RNTST] Running test incr_test...
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
--------------------------------------------------------------------
Name                         Type                        Size  Value
--------------------------------------------------------------------
uvm_test_top                 incr_test                   -     @464 
  env                        tb_env                      -     @481 
    ahb_top                  ahb_agent_top               -     @489 
      agent_ahb[0]           ahb_agent                   -     @747 
        drv                  ahb_driver                  -     @777 
          rsp_port           uvm_analysis_port           -     @794 
          seq_item_port      uvm_seq_item_pull_port      -     @785 
        mon                  ahb_monitor                 -     @760 
          m_port             uvm_analysis_port           -     @768 
        seqr                 ahb_seqr                    -     @803 
          rsp_export         uvm_analysis_export         -     @811 
          seq_item_export    uvm_seq_item_pull_imp       -     @917 
          arbitration_queue  array                       0     -    
          lock_queue         array                       0     -    
          num_last_reqs      integral                    32    'd1  
          num_last_rsps      integral                    32    'd1  
    apb_top                  apb_agent_top               -     @497 
      agent_apb[0]           apb_agent                   -     @938 
        drv                  apb_driver                  -     @968 
          rsp_port           uvm_analysis_port           -     @985 
          seq_item_port      uvm_seq_item_pull_port      -     @976 
        mon                  apb_monitor                 -     @951 
          p_port             uvm_analysis_port           -     @959 
        seqr                 apb_seqr                    -     @994 
          rsp_export         uvm_analysis_export         -     @1002
          seq_item_export    uvm_seq_item_pull_imp       -     @1108
          arbitration_queue  array                       0     -    
          lock_queue         array                       0     -    
          num_last_reqs      integral                    32    'd1  
          num_last_rsps      integral                    32    'd1  
    sb                       tb_scoreboard               -     @505 
      ahb_fifo               uvm_tlm_analysis_fifo #(T)  -     @513 
        analysis_export      uvm_analysis_imp            -     @557 
        get_ap               uvm_analysis_port           -     @548 
        get_peek_export      uvm_get_peek_imp            -     @530 
        put_ap               uvm_analysis_port           -     @539 
        put_export           uvm_put_imp                 -     @521 
      apb_fifo               uvm_tlm_analysis_fifo #(T)  -     @566 
        analysis_export      uvm_analysis_imp            -     @610 
        get_ap               uvm_analysis_port           -     @601 
        get_peek_export      uvm_get_peek_imp            -     @583 
        put_ap               uvm_analysis_port           -     @592 
        put_export           uvm_put_imp                 -     @574 
    v_seqr                   virtual_seqr                -     @619 
      rsp_export             uvm_analysis_export         -     @627 
      seq_item_export        uvm_seq_item_pull_imp       -     @733 
      arbitration_queue      array                       0     -    
      lock_queue             array                       0     -    
      num_last_reqs          integral                    32    'd1  
      num_last_rsps          integral                    32    'd1  
--------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
Name                           Type      Size  Value                                           
-----------------------------------------------------------------------------------------------
req                            ahb_xtn   -     @1153                                           
  begin_time                   time      64    10000                                           
  depth                        int       32    'd2                                             
  parent sequence (name)       string    5     i_seq                                           
  parent sequence (full name)  string    48    uvm_test_top.env.ahb_top.agent_ahb[0].seqr.i_seq
  sequencer                    string    42    uvm_test_top.env.ahb_top.agent_ahb[0].seqr      
  HADDR                        integral  32    'h80000250                                      
  HTRANS                       integral  2     2                                               
  HWRITE                       integral  1     'b1                                             
  HSIZE                        integral  3     'd1                                             
  HBURST                       integral  3     'd3                                             
  HWDATA                       integral  32    'h3727edfd                                      
  HREADYin                     integral  1     'b0                                             
  HRESP                        integral  2     'd0                                             
  HREADYout                    integral  1     'd0                                             
  HRDATA                       integral  32    'h0                                             
  length                       integral  10    'd4                                             
-----------------------------------------------------------------------------------------------
Width = 32, size 8 bits
-----------------------------------------------------------------------------------------------
Name                           Type      Size  Value                                           
-----------------------------------------------------------------------------------------------
req                            ahb_xtn   -     @1153                                           
  begin_time                   time      64    20000                                           
  end_time                     time      64    20000                                           
  depth                        int       32    'd2                                             
  parent sequence (name)       string    5     i_seq                                           
  parent sequence (full name)  string    48    uvm_test_top.env.ahb_top.agent_ahb[0].seqr.i_seq
  sequencer                    string    42    uvm_test_top.env.ahb_top.agent_ahb[0].seqr      
  HADDR                        integral  32    'h80000252                                      
  HTRANS                       integral  2     3                                               
  HWRITE                       integral  1     'b1                                             
  HSIZE                        integral  3     'd1                                             
  HBURST                       integral  3     'd3                                             
  HWDATA                       integral  32    'h66cd28b0                                      
  HREADYin                     integral  1     'b1                                             
  HRESP                        integral  2     'd0                                             
  HREADYout                    integral  1     'd0                                             
  HRDATA                       integral  32    'h0                                             
  length                       integral  10    'd4                                             
-----------------------------------------------------------------------------------------------
---------------------------------------
Name         Type      Size  Value     
---------------------------------------
h_mon        ahb_xtn   -     @1129     
  HADDR      integral  32    'h80000250
  HTRANS     integral  2     2         
  HWRITE     integral  1     'b1       
  HSIZE      integral  3     'd1       
  HBURST     integral  3     'd0       
  HWDATA     integral  32    'h3727edfd
  HREADYin   integral  1     'b1       
  HRESP      integral  2     'd0       
  HREADYout  integral  1     'd0       
  HRDATA     integral  32    'h0       
  length     integral  10    'd0       
---------------------------------------
Width = 32, size 16 bits
-----------------------------------------------------------------------------------------------
Name                           Type      Size  Value                                           
-----------------------------------------------------------------------------------------------
req                            ahb_xtn   -     @1153                                           
  begin_time                   time      64    30000                                           
  end_time                     time      64    30000                                           
  depth                        int       32    'd2                                             
  parent sequence (name)       string    5     i_seq                                           
  parent sequence (full name)  string    48    uvm_test_top.env.ahb_top.agent_ahb[0].seqr.i_seq
  sequencer                    string    42    uvm_test_top.env.ahb_top.agent_ahb[0].seqr      
  HADDR                        integral  32    'h80000254                                      
  HTRANS                       integral  2     3                                               
  HWRITE                       integral  1     'b1                                             
  HSIZE                        integral  3     'd1                                             
  HBURST                       integral  3     'd3                                             
  HWDATA                       integral  32    'hf009c5b3                                      
  HREADYin                     integral  1     'b1                                             
  HRESP                        integral  2     'd0                                             
  HREADYout                    integral  1     'd0                                             
  HRDATA                       integral  32    'h0                                             
  length                       integral  10    'd4                                             
-----------------------------------------------------------------------------------------------
Width = 32, size 16 bits
-----------------------------------------------------------------------------------------------
Name                           Type      Size  Value                                           
-----------------------------------------------------------------------------------------------
req                            ahb_xtn   -     @1153                                           
  begin_time                   time      64    50000                                           
  end_time                     time      64    50000                                           
  depth                        int       32    'd2                                             
  parent sequence (name)       string    5     i_seq                                           
  parent sequence (full name)  string    48    uvm_test_top.env.ahb_top.agent_ahb[0].seqr.i_seq
  sequencer                    string    42    uvm_test_top.env.ahb_top.agent_ahb[0].seqr      
  HADDR                        integral  32    'h80000256                                      
  HTRANS                       integral  2     3                                               
  HWRITE                       integral  1     'b1                                             
  HSIZE                        integral  3     'd1                                             
  HBURST                       integral  3     'd3                                             
  HWDATA                       integral  32    'h768fbefe                                      
  HREADYin                     integral  1     'b0                                             
  HRESP                        integral  2     'd0                                             
  HREADYout                    integral  1     'd0                                             
  HRDATA                       integral  32    'h0                                             
  length                       integral  10    'd4                                             
-----------------------------------------------------------------------------------------------
-------------------------------------
Name       Type      Size  Value     
-------------------------------------
p_mon      apb_xtn   -     @1135     
  PENABLE  integral  1     'b1       
  PWRITE   integral  1     'b1       
  PWDATA   integral  32    'hedfd    
  PRDATA   integral  32    'hxxxxxxxx
  PADDR    integral  32    'h80000250
  PSEL     integral  4     'b1       
-------------------------------------

==========================================================

 ------------- Successfully Address MATCHED ------------- 

==========================================================


==========================================================

 -------------- Successfully DATA MATCHED --------------- 

==========================================================

---------------------------------------
Name         Type      Size  Value     
---------------------------------------
h_mon        ahb_xtn   -     @1230     
  HADDR      integral  32    'h80000252
  HTRANS     integral  2     3         
  HWRITE     integral  1     'b1       
  HSIZE      integral  3     'd1       
  HBURST     integral  3     'd0       
  HWDATA     integral  32    'h66cd28b0
  HREADYin   integral  1     'b1       
  HRESP      integral  2     'd0       
  HREADYout  integral  1     'd0       
  HRDATA     integral  32    'h0       
  length     integral  10    'd0       
---------------------------------------
Width = 32, size 16 bits
-------------------------------------
Name       Type      Size  Value     
-------------------------------------
p_mon      apb_xtn   -     @1242     
  PENABLE  integral  1     'b1       
  PWRITE   integral  1     'b1       
  PWDATA   integral  32    'h66cd    
  PRDATA   integral  32    'hxxxxxxxx
  PADDR    integral  32    'h80000252
  PSEL     integral  4     'b1       
-------------------------------------

==========================================================

 ------------- Successfully Address MATCHED ------------- 

==========================================================


==========================================================

 -------------- Successfully DATA MATCHED --------------- 

==========================================================

---------------------------------------
Name         Type      Size  Value     
---------------------------------------
h_mon        ahb_xtn   -     @1234     
  HADDR      integral  32    'h80000254
  HTRANS     integral  2     3         
  HWRITE     integral  1     'b1       
  HSIZE      integral  3     'd1       
  HBURST     integral  3     'd0       
  HWDATA     integral  32    'hf009c5b3
  HREADYin   integral  1     'b1       
  HRESP      integral  2     'd0       
  HREADYout  integral  1     'd0       
  HRDATA     integral  32    'h0       
  length     integral  10    'd0       
---------------------------------------
Width = 32, size 16 bits
-------------------------------------
Name       Type      Size  Value     
-------------------------------------
p_mon      apb_xtn   -     @1251     
  PENABLE  integral  1     'b1       
  PWRITE   integral  1     'b1       
  PWDATA   integral  32    'hc5b3    
  PRDATA   integral  32    'hxxxxxxxx
  PADDR    integral  32    'h80000254
  PSEL     integral  4     'b1       
-------------------------------------

==========================================================

 ------------- Successfully Address MATCHED ------------- 

==========================================================


==========================================================

 -------------- Successfully DATA MATCHED --------------- 

==========================================================

---------------------------------------
Name         Type      Size  Value     
---------------------------------------
h_mon        ahb_xtn   -     @1238     
  HADDR      integral  32    'h80000256
  HTRANS     integral  2     3         
  HWRITE     integral  1     'b1       
  HSIZE      integral  3     'd1       
  HBURST     integral  3     'd0       
  HWDATA     integral  32    'h768fbefe
  HREADYin   integral  1     'b1       
  HRESP      integral  2     'd0       
  HREADYout  integral  1     'd0       
  HRDATA     integral  32    'h0       
  length     integral  10    'd0       
---------------------------------------
UVM_INFO /home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_objection.svh(1274) @ 120000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase

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
$finish at simulation time               120000
           V C S   S i m u l a t i o n   R e p o r t 
Time: 120000 ps

*/

