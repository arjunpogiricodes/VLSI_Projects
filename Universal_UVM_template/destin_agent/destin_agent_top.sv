


// source agent top

class destin_agent_top extends uvm_env;

// factory registration

		`uvm_component_utils(destin_agent_top)
		
// creating handle

		destin_agent agent[];
		tb_env_config e_cfg;
		
// function new constructor

		function new(string name ="destin_agent_top",uvm_component parent);
		
			super.new(name,parent);
		
		endfunction
		
// build_phase

		function void build_phase(uvm_phase phase);
 
            super.build_phase(phase); 
			if(!uvm_config_db #(tb_env_config) :: get(this,"","tb_env_config",e_cfg))
		          `uvm_fatal(get_full_name(),"cannot get e_cfg handle from base test in destin_agent_top")            
            agent = new [e_cfg.no_of_destin_agent];
			foreach(agent[i])
				begin
					uvm_config_db #(destin_config) :: set(this,$sformatf("agent[%0d]*",i),"destin_config",e_cfg.d_cfg[i]);
					agent[i] = destin_agent :: type_id :: create($sformatf("agent[%0d]",i),this);
				end	
		endfunction	


endclass