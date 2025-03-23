

// environ class

class tb_env extends uvm_env;


// factory registration

		`uvm_component_utils(tb_env)
// handle declartions

		source_agent_top source_top[];	
		destin_agent_top destin_top[];	
		tb_env_config    e_cfg;
		score_board      sb;
// function new		

		function new(string name = "tb_env",uvm_component parent);
		
			super.new(name,parent);
		
		endfunction

// build phase

		function void build_phase(uvm_phase phase);
				super.build_phase(phase);		
				if(!uvm_config_db #(tb_env_config) :: get(this,"","tb_env_config",e_cfg))
		             `uvm_fatal(get_full_name(),"cannot get e_cfg handle from base test in tb_env")
				source_top = new[e_cfg.no_of_source_agent_top];
                destin_top = new[e_cfg.no_of_destin_agent_top];	
				foreach(source_top[i])
				    begin
					    source_top[i]=source_agent_top::type_id::create($sformatf("source_top[%0d]",i),this);
                    end 
				foreach(destin_top[i])
				    begin
					    destin_top[i]=destin_agent_top::type_id::create($sformatf("destin_top[%0d]",i),this);
                    end	
				 sb = score_board :: type_id :: create("sb",this);	
					
		endfunction



endclass 
