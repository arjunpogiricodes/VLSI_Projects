



// source agent

class destin_agent extends uvm_agent;

/// factory registration

		`uvm_component_utils(destin_agent)
		
// handle declaration

		destin_config   m_cfg;
        destin_driver   drv;
        destin_monitor  mon;		
		destin_seqr     seqr;		

// function new 
 
       function new(string name = "destin_agent",uvm_component parent);
	   
			super.new(name,parent);
	   
	   endfunction
// build phase

		function void build_phase(uvm_phase phase);
		
			super.build_phase(phase);
		    if(!uvm_config_db #(destin_config) :: get(this,"","destin_config",m_cfg))
		         `uvm_fatal(get_full_name(),"cannot get m_cfg handle from destin_agent_top in destin agent")
			mon = destin_monitor :: type_id :: create("mon",this);
            if(m_cfg.is_active == UVM_ACTIVE)
                begin
                    drv  = destin_driver :: type_id :: create("drv",this);
					seqr = destin_seqr   :: type_id :: create("seqr",this);
				end		
		
		endfunction
// connect phase		

		function void connect_phase(uvm_phase phase);
		
		    if(m_cfg.is_active == UVM_ACTIVE)
                begin
                    //drv.seq_item_port.connect(seqr.seq_item_export);
				end			
	
		endfunction	   



endclass