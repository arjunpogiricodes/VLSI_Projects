


// class source monmitor

class destin_monitor extends uvm_monitor;


// factory registration

		`uvm_component_utils(destin_monitor)
		
// virtual interface 

		destin_config m_cfg;
        virtual axi_if.S_MON vif;		
		
// fuction constructor

		function new(string name = "destin_monitor",uvm_component parent);
		
		      super.new(name,parent);
		
		endfunction

// build phase

		 function void build_phase(uvm_phase phase);
				super.build_phase(phase);
				if(!uvm_config_db #(destin_config)::get(this,"","destin_config",m_cfg))
                     `uvm_fatal(get_full_name(),"cannot get the m_cfg from destin agent in destin monitor")
	     endfunction	
		 
// connect phase

		 function void connect_phase(uvm_phase phase);
               vif = m_cfg.vif;
         endfunction		

endclass


