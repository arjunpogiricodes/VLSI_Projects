



// test class 

class base_test extends uvm_test;

// factory registration 
 
         `uvm_component_utils(base_test)

// declaring the test bench env class handle and env_config handles

           tb_env envh;
           router_env_config m_cfg;

           source_agent_config  m_source_agth[];
           destin_agent_config  m_destin_agth[];

            int no_of_source = 1;
            int no_of_destin = 3;

// header byte destination address setting 
 
           bit [2]addr;

// funciton new constructor 

          function new(string name = "base_test",uvm_component parent = null );

                   super.new(name,parent);

          endfunction
// config function

               function void config_data();

                            m_source_agth = new[no_of_source];
                            m_destin_agth = new[no_of_destin];

                            foreach(m_source_agth[i]) 
                                   begin
                                        m_source_agth[i] = source_agent_config :: type_id :: create($sformatf("m_source_agth[%0d]",i));
                                        m_source_agth[i].is_active = UVM_ACTIVE;
                                        if(!uvm_config_db #(virtual router_source_if) :: get(this,"","vif",m_source_agth[i].vif))
                                             `uvm_fatal(get_full_name(),"cannot get the interface handle from source are set in top")

                                   end
                            foreach(m_destin_agth[i])
                                   begin
                                        m_destin_agth[i] = destin_agent_config :: type_id :: create($sformatf("m_destin_agth[%0d]",i));
                                        m_destin_agth[i].is_active = UVM_ACTIVE;
                                        if(!uvm_config_db #(virtual router_destin_if) :: get(this,"",$sformatf("vif%0d",i),m_destin_agth[i].vif))
                                             `uvm_fatal(get_full_name(),"cannot get the interface handle from destination are set in top")

                                   end
                            m_cfg.no_of_source = no_of_source;
                            m_cfg.no_of_destin = no_of_destin;
                

               endfunction                  

// fucniton build_phase


         function void build_phase(uvm_phase phase);
                      
               super.build_phase(phase);
               m_cfg = router_env_config :: type_id :: create("m_cfg");

               m_cfg.m_source_agth = new[no_of_source];
               m_cfg.m_destin_agth = new[no_of_destin];
               
               config_data();
   
               foreach(m_source_agth[i])
                          m_cfg.m_source_agth[i] = m_source_agth[i]; 

               foreach(m_destin_agth[i])
                          m_cfg.m_destin_agth[i] = m_destin_agth[i]; 
               
                uvm_config_db #(router_env_config) :: set(this,"*","router_env_config",m_cfg);
                envh = tb_env :: type_id :: create("envh",this);


         endfunction:build_phase
		 
// function void end o elaboration 		 

        function void end_of_elaboration_phase(uvm_phase phase);


               uvm_top.print_topology();
			   


       endfunction 
	   
	   

endclass

//-------------Extended base test class to small test class ---------------//

class small_seq_test extends base_test;

// factory regisdtration

          `uvm_component_utils(small_seq_test)

// declaring the virtual smal_seq class handle

              //small_seq seqh;
       virtual_small_seq s_seqh;
       destin_seq  dseq;
// function new constructor

       function new(string name = "small_seq_test",uvm_component parent);

              super.new(name,parent);
              addr = 2'd0;

              uvm_config_db #(bit[2])::set(this,"*","bit",addr);

       endfunction 

// build phase

         function void build_phase(uvm_phase phase);

                super.build_phase(phase);
         
         endfunction

// run phase of small test seq

// task run phase

           task run_phase(uvm_phase phase);
                  phase.raise_objection(this);
                         super.run_phase(phase);
		         s_seqh = virtual_small_seq :: type_id :: create("s_seqh");
                        dseq  = destin_seq        :: type_id :: create("dseq");
                        repeat(10)
                        begin 
                        fork
                        s_seqh.start(envh.v_seqr);
                        dseq.start(envh.destin_agth.agth[addr].seqr);
                        join
                        end  
		  phase.drop_objection(this);

           endtask	

endclass

//----------Extended base test class to medium test class -------------//

class medium_seq_test extends base_test;

// factory registration

      `uvm_component_utils(medium_seq_test)


// declaring the handle for medum sdeq generater

         // medium_seq seqh;

       virtual_medium_seq m_seqh;
       destin_seq  dseq;

      
// build phase

         function void build_phase(uvm_phase phase);

                super.build_phase(phase);
         
         endfunction

// function new constructor

       function new(string name = "medium_seq_test", uvm_component parent );

                  super.new(name,parent);
              addr = 2'd1;

              uvm_config_db #(bit[2])::set(this,"*","bit",addr);


       endfunction

// run phase of medium test seq


          task run_phase(uvm_phase phase);
                  phase.raise_objection(this);
                         super.run_phase(phase);
                         m_seqh = virtual_medium_seq :: type_id :: create("m_seqh");
                         dseq  = destin_seq        :: type_id :: create("dseq");
                         repeat(5)
                         begin
                        fork
                        m_seqh.start(envh.v_seqr);
                        dseq.start(envh.destin_agth.agth[addr].seqr);
                        join
                        end
                  phase.drop_objection(this);
          endtask

endclass


// --------------- Extended base test class to Large test class ---------//

class large_seq_test extends base_test;

// factory registration

       `uvm_component_utils(large_seq_test)

// declare the handle of large seq

         //large_seq seqh;

          virtual_large_seq l_seqh;
          destin_seq  dseq;


// build phase

         function void build_phase(uvm_phase phase);

                super.build_phase(phase);
         
         endfunction


// function new constructor

         function new(string name = "large_seq_test" , uvm_component parent);

                 super.new(name,parent);  
              addr = 2'd2;

              uvm_config_db #(bit[2])::set(this,"*","bit",addr);
  

         endfunction     

// run_phase of large test seq


         task run_phase(uvm_phase phase);
                     phase.raise_objection(this);
                          super.run_phase(phase);
                          l_seqh = virtual_large_seq :: type_id :: create("l_seqh");
                          dseq  = destin_seq        :: type_id :: create("dseq");
                         repeat(5)
                          begin
                        fork
                        l_seqh.start(envh.v_seqr);
                        dseq.start(envh.destin_agth.agth[addr].seqr);
                        join
                         end

                    phase.drop_objection(this);                
         endtask



endclass
