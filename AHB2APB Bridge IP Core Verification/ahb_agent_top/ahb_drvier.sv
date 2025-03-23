

//--------------- ahb_driver--------------------------//

class ahb_driver extends uvm_driver#(ahb_xtn);

// factory registration

           `uvm_component_utils(ahb_driver)

// virtual interface

          virtual ahbtoapb_interface.AHB_DRV vif;
          ahb_config m_cfg;

// constructor new

          function new (string name = "ahb_driver",uvm_component parent);

                      super.new(name,parent);

          endfunction
// build phase

         function void build_phase(uvm_phase phase);
                  super.build_phase(phase);
                  if(!uvm_config_db #(ahb_config) :: get(this,"","ahb_config",m_cfg))
                          `uvm_fatal(get_full_name(),"cannot get the m_cfg handle from ahb_top in ahb_driver")
                
         endfunction 
// connect phase 

         function void connect_phase(uvm_phase phase);
                
                  vif = m_cfg.vif;

         endfunction
// task runphase

         task run_phase(uvm_phase phase);
 
                   super.run_phase(phase);
                   @(vif.ahb_drv);
                   vif.ahb_drv.HRESETn <= 1'b0;
                   @(vif.ahb_drv);
                   vif.ahb_drv.HRESETn <= 1'b1;
                 forever
                   begin
                   seq_item_port.get_next_item(req);
                   send_to_dut();
                   req.print();
                   seq_item_port.item_done();                              
                   end
         endtask

// send to dut task

         task send_to_dut();

              while(vif.ahb_drv.HREADYout !== 1)
                  @(vif.ahb_drv);
                 vif.ahb_drv.HREADYin <= 1;
                 vif.ahb_drv.HWRITE   <= req.HWRITE;
                 vif.ahb_drv.HTRANS   <= req.HTRANS;
                 vif.ahb_drv.HSIZE    <= req.HSIZE;
                 vif.ahb_drv.HADDR    <= req.HADDR;
                
                 @(vif.ahb_drv);

              while(vif.ahb_drv.HREADYout !== 1)
                  @(vif.ahb_drv);
                  if(req.HWRITE === 1)
                      vif.ahb_drv.HWDATA   <= req.HWDATA;
                  else
                      vif.ahb_drv.HWDATA   <= 0;
                                                            
         endtask
       


endclass

