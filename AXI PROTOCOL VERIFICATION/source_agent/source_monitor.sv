


// class source monmitor

class source_monitor extends uvm_monitor;


// factory registration

		`uvm_component_utils(source_monitor)
// virtual interfaqce

         source_config m_cfg;		
		 virtual axi_if.M_DRV vif;
		 
// fuction constructor

		function new(string name = "source_monitor",uvm_component parent);
		
		      super.new(name,parent);
		
		endfunction
		
// build phase

		 function void build_phase(uvm_phase phase);
				super.build_phase(phase);
				if(!uvm_config_db #(source_config)::get(this,"","source_config",m_cfg))
                     `uvm_fatal(get_full_name(),"cannot get the m_cfg from source agent in source monitor")
					 
	     endfunction	
		 
// connect phase

		 function void connect_phase(uvm_phase phase);
               vif = m_cfg.vif;
         endfunction		

endclass


