

// -----------------ahb agent----------------// 

class ahb_agent extends uvm_agent;

// factory registration

           `uvm_component_utils(ahb_agent)

// handle declaration

        ahb_driver drv;
        ahb_monitor mon;
        ahb_seqr seqr;

         ahb_config m_cfg;

// constructor new

          function new (string name = "ahb_agent",uvm_component parent);

                      super.new(name,parent);

          endfunction

// build_phase

          function void build_phase(uvm_phase phase);

                  super.build_phase(phase);
                   if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config",m_cfg))
                        begin
                             `uvm_fatal(get_full_name(),"cannot get the m_cfg ahb_config handle foirm ahb top in ahb agent") 
                        end
                   mon  = ahb_monitor  :: type_id :: create("mon",this);
                   if(m_cfg.is_active == UVM_ACTIVE)
                      begin
                          drv  = ahb_driver :: type_id :: create("drv",this);
                          seqr = ahb_seqr   :: type_id :: create("seqr",this);
                      end 
          endfunction

// connect phase

           function void connect_phase(uvm_phase phase);
               if(m_cfg.is_active == UVM_ACTIVE)
                      begin
                          drv.seq_item_port.connect(seqr.seq_item_export);
                          
                      end 
            endfunction
        


endclass

