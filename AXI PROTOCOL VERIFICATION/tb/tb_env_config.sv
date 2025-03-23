



// class environment configuaration


class tb_env_config  extends uvm_object;

// factory registration 

	`uvm_object_utils(tb_env_config)

	    int no_of_source_agent_top = 1;
        int no_of_source_agent     = 1;
        int no_of_destin_agent_top = 1;
        int no_of_destin_agent     = 1;

// handle of agent configs

	    source_config s_cfg[];
        destin_config d_cfg[];




// function new

		function new(string name = "tb_env_config");
		
			super.new(name);
		
		endfunction
		

endclass
