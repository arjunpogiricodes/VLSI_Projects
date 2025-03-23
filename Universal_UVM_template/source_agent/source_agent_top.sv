


// source agent top

class source_agent_top extends uvm_env;

// factory registration

		`uvm_component_utils(source_agent_top)
		
// creating handle

		source_agent agent[];
		tb_env_config e_cfg;
		

// function new constructor

		function new(string name ="source_agent_top",uvm_component parent);
		
			super.new(name,parent);
		
		endfunction
		
// build_phase

		function void build_phase(uvm_phase phase);
 
            super.build_phase(phase); 
			if(!uvm_config_db #(tb_env_config) :: get(this,"","tb_env_config",e_cfg))
		          `uvm_fatal(get_full_name(),"cannot get e_cfg handle from base test in source_agent_top")            
            agent = new [e_cfg.no_of_source_agent];
			foreach(agent[i])
				begin
					uvm_config_db #(source_config) :: set(this,$sformatf("agent[%0d]*",i),"source_config",e_cfg.s_cfg[i]);
					agent[i] = source_agent :: type_id :: create($sformatf("agent[%0d]",i),this);
				end	
		endfunction	



endclass