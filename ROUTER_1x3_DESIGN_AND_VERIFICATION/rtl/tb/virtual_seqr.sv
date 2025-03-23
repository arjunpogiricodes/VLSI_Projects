




// virtual sequncer class

class virtual_seqr extends uvm_sequencer #(uvm_sequence_item);

// factory registration 
   
        `uvm_component_utils(virtual_seqr)


// declaring the handle for source and destination sequencer
         router_env_config m_cfg;
         source_seqr s_seqr[];


// fuunction new construction 

         function new(string name= "virtual_seqr" , uvm_component parent = null);
 
                          super.new(name,parent);

        endfunction

// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase); 
                 if(!uvm_config_db #(router_env_config) :: get(this,"","router_env_config",m_cfg))
                       `uvm_fatal(get_full_name()," cannot get the router_env_config handle mcfg from tesdt class in virtual sequncerr") 
  
                 s_seqr = new[m_cfg.no_of_source]; 
         endfunction




endclass:virtual_seqr
