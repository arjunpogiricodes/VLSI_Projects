



// source driver


class source_driver extends uvm_driver;

// facory registration

		`uvm_component_utils(source_driver)
		
// virtual interface

		 virtual axi_if.M_DRV vif;
		 
		 source_config m_cfg;
		 

// function new 

		function new(string name="source_driver",uvm_component parent);
		
			super.new(name,parent);
		
		endfunction
		
// build phase

		 function void build_phase(uvm_phase phase);
				super.build_phase(phase);
				if(!uvm_config_db #(source_config) :: get(this,"","source_config",m_cfg))
		         `uvm_fatal(get_full_name(),"cannot get m_cfg handle from souorce agent top in source driver")
	     endfunction	
		 
// connect phase

		 function void connect_phase(uvm_phase phase);
               vif = m_cfg.vif;
         endfunction 			   




endclass 