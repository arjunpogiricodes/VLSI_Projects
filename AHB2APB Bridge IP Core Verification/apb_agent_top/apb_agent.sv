

// -----------------apb agent----------------// 

class apb_agent extends uvm_agent;

// factory registration

           `uvm_component_utils(apb_agent)

// handle declaration

        apb_driver drv;
        apb_monitor mon;
        apb_seqr seqr;

         apb_config m_cfg;


// constructor new

          function new (string name = "apb_agent",uvm_component parent);

                      super.new(name,parent);

          endfunction
// build_phase

          function void build_phase(uvm_phase phase);

                  super.build_phase(phase);
                   if(!uvm_config_db #(apb_config)::get(this,"","apb_config",m_cfg))
                        begin
                             `uvm_fatal(get_full_name(),"cannot get the m_cfg ahb_config handle foirm apb top in apb agent") 
                        end
                   mon  = apb_monitor  :: type_id :: create("mon",this);
                   if(m_cfg.is_active == UVM_ACTIVE)
                      begin
                          drv  = apb_driver :: type_id :: create("drv",this);
                          seqr = apb_seqr   :: type_id :: create("seqr",this);
                      end 
          endfunction

// connect phase

          /* function void connect_phase(uvm_phase phase);
               if(m_cfg.is_active == UVM_ACTIVE)
                      begin
                          drv.seq_item_port.connect(seqr.seq_item_export);
                          
                      end 
            endfunction
          */




endclass

