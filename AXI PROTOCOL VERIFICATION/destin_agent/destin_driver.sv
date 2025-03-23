



// source driver


class destin_driver extends uvm_driver;

// facory registration

		`uvm_component_utils(destin_driver)
		
// virtual interface 

		destin_config m_cfg;
        virtual axi_if.S_DRV vif;		

// function new 

		function new(string name="destin_driver",uvm_component parent);
		
			super.new(name,parent);
		
		endfunction

// build phase

		 function void build_phase(uvm_phase phase);
				super.build_phase(phase);
				if(!uvm_config_db #(destin_config) :: get(this,"","destin_config",m_cfg))
		         `uvm_fatal(get_full_name(),"cannot get m_cfg handle from destin_agent_top in destin driver")	 
	     endfunction	
		 
// connect phase

		 function void connect_phase(uvm_phase phase);
               vif = m_cfg.vif;
         endfunction		
		




endclass 