

// ------------ apb agent top--------------------//

class apb_agent_top extends uvm_env;

// factory registration

           `uvm_component_utils(apb_agent_top)

// handle declarataion

           apb_agent agent_apb[];

           tb_env_config m_cfg;


// constructor new

          function new (string name = "apb_agent_top",uvm_component parent);

                      super.new(name,parent);

          endfunction
// build_phase

        function void build_phase(uvm_phase phase);

                  super.build_phase(phase);
                  if(! uvm_config_db #(tb_env_config) :: get(this,"","tb_env_config",m_cfg))
                        begin
                         `uvm_fatal(get_full_name()," cannot get the m_cfg handle from tb_env_config from test in ahp gent top")          
                        end

                   agent_apb = new [m_cfg.no_of_apb];

                   foreach(agent_apb[i])
                        begin
                             uvm_config_db #(apb_config) :: set(this,$sformatf("agent_apb[%0d]*",i),"apb_config",m_cfg.apb_cfg[i]);
                             agent_apb[i] = apb_agent :: type_id :: create($sformatf("agent_apb[%0d]",i),this);
                        end

        
        endfunction




endclass

