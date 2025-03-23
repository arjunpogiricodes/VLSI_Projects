
//----------------- virtual sequencer --------------------------------//

class virtual_seqr extends uvm_sequencer#(uvm_sequence_item);

// factory registraion

         `uvm_component_utils(virtual_seqr)

// agent sequencer handles

          ahb_seqr h_seqr;
          tb_env_config  m_cfg;   

// constructor new

         function new(string name = "virtual_seqr" , uvm_component parent=null);

                   super.new(name,parent);

         endfunction

/*// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase); 
                 if(!uvm_config_db #(tb_env_config) :: get(this,"","tb_env_config",m_cfg))
                       `uvm_fatal(get_full_name()," cannot get the tb_env_config handle mcfg from tesdt class in virtual sequncerr") 
  
                 h_seqr = new[m_cfg.no_of_ahb]; 
         endfunction

*/

endclass
