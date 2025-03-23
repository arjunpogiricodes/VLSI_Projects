



// test classs

class base_test extends uvm_test;

// factory registration

		`uvm_component_utils(base_test)

// handles declaring

	    tb_env env;
        tb_env_config e_cfg;
	    source_config s_cfg[];
        destin_config d_cfg[];

		int no_of_source_agent_top = 1;
        int no_of_source_agent     = 1;
        int no_of_destin_agent_top = 1;
        int no_of_destin_agent     = 1;

// constructor new

	function new(string name = "base_test" , uvm_component parent = null);
		 
		super.new(name,parent);
		
	endfunction
	

// tb_config

	function void  tb_config();

		s_cfg = new [no_of_source_agent];
        d_cfg = new [no_of_destin_agent];

		e_cfg.s_cfg = new [no_of_source_agent];
        e_cfg.d_cfg = new [no_of_destin_agent];

        foreach(s_cfg[i])
            begin
		        s_cfg[i] = source_config :: type_id ::create ($sformatf("s_cfg[%0d]",i));
                s_cfg[i].is_active = UVM_ACTIVE;
				if(! uvm_config_db #(virtual axi_if) :: get(this,"","VIF",s_cfg[i].vif))
				    begin   
				      `uvm_fatal(get_full_name(),"cannot get the virtual interface in baseclass at source config")
					 end
                e_cfg.s_cfg[i] = s_cfg[i];					 
            end
        foreach(d_cfg[i])
            begin
		        d_cfg[i] = destin_config :: type_id ::create ($sformatf("d_cfg[%0d]",i));
                d_cfg[i].is_active = UVM_ACTIVE;
			    if(!uvm_config_db #(virtual axi_if) :: get(this,"","VIF",d_cfg[i].vif))
				     begin
					     `uvm_fatal(get_full_name(),"cannot get the virtual interface in baseclass at destin config")
				     end
                e_cfg.d_cfg[i] = d_cfg[i];					 
            end

	endfunction	
// build phase 
	
	function void build_phase(uvm_phase phase);
		
				super.build_phase(phase);	
		        e_cfg = tb_env_config ::type_id ::create("e_cfg");
				e_cfg.no_of_source_agent_top = no_of_source_agent_top;
				e_cfg.no_of_source_agent     = no_of_source_agent;
				e_cfg.no_of_destin_agent_top = no_of_destin_agent_top;
				e_cfg.no_of_destin_agent     = no_of_destin_agent;				
                tb_config();
                uvm_config_db #(tb_env_config) :: set (this,"*","tb_env_config",e_cfg); 
                env = tb_env :: type_id ::create("env",this);

    endfunction

	
	function void end_of_elaboration_phase(uvm_phase phase);
	
			uvm_top.print_topology();
	
	endfunction
             


	

endclass
