



// source agent

class source_agent extends uvm_agent;

/// factory registration

		`uvm_component_utils(source_agent)
		
// handle declaration

		source_config   m_cfg;
        source_driver   drv;
        source_monitor  mon;		
		source_seqr     seqr;

// function new 
 
       function new(string name = "source_agent",uvm_component parent);
	   
			super.new(name,parent);
	   
	   endfunction
	   
// build phase

		function void build_phase(uvm_phase phase);
		
			super.build_phase(phase);
		    if(!uvm_config_db #(source_config) :: get(this,"","source_config",m_cfg))
		         `uvm_fatal(get_full_name(),"cannot get m_cfg handle from souorce agent top in source agent")
			mon = source_monitor :: type_id :: create("mon",this);
            if(m_cfg.is_active == UVM_ACTIVE)
                begin
                    drv  = source_driver :: type_id :: create("drv",this);
					seqr = source_seqr   :: type_id :: create("seqr",this);
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