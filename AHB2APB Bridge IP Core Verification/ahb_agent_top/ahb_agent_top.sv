

// ------------ ahb agent top--------------------//

class ahb_agent_top extends uvm_env;

// factory registration

           `uvm_component_utils(ahb_agent_top)

// handle declarataion

           ahb_agent agent_ahb[];

           tb_env_config m_cfg;

// constructor new

          function new (string name = "ahb_agent_top",uvm_component parent);

                      super.new(name,parent);

          endfunction

// build_phase

        function void build_phase(uvm_phase phase);

                  super.build_phase(phase);
                  if(! uvm_config_db #(tb_env_config) :: get(this,"","tb_env_config",m_cfg))
                        begin
                         `uvm_fatal(get_full_name()," cannot get the m_cfg handle from tb_env_config from test in ahp gent top")          
                        end

                   agent_ahb = new [m_cfg.no_of_ahb];
                 
                   foreach(agent_ahb[i])
                        begin
                            uvm_config_db #(ahb_config) :: set(this,$sformatf("agent_ahb[%0d]*",i),"ahb_config",m_cfg.ahb_cfg[i]);                             
                            agent_ahb[i] = ahb_agent :: type_id :: create($sformatf("agent_ahb[%0d]",i),this);
                        end

        
        endfunction



endclass

