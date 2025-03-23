





// class source agent top

class source_agent_top extends uvm_env;

// factory registration

           `uvm_component_utils(source_agent_top)

// declare the source_agent handle

        source_agent agth[];
         
        router_env_config m_cfg; 
   

// funciton new constructor 

         function new(string name = "source_agent_top" , uvm_component parent = null);

                super.new(name,parent);
				 

         endfunction   

// build phase

         function void build_phase(uvm_phase phase);
                 super.build_phase(phase);
	       // `uvm_info(get_full_name(),"this is agt top soruce",UVM_LOW)
                if(!uvm_config_db#(router_env_config) :: get(this,"","router_env_config",m_cfg))
                  `uvm_fatal(get_full_name(),"cannot get() m_cfg from base test class data base object of router env config")
                   agth = new [m_cfg.no_of_source];   				  
                foreach(agth[i]) 
                       begin
                            uvm_config_db #(source_agent_config) :: set(this,$sformatf("agth[%0d]*",i),"source_agent_config",m_cfg.m_source_agth[i]);
                            agth[i] = source_agent :: type_id :: create ($sformatf("agth[%0d]",i),this);             
                       end
         endfunction

// run phase



// end of elaboration phase
/*
        function void end_of_elaboration_phase(uvm_phase phase);


               uvm_top.print_topology();


       endfunction
       
*/






endclass
