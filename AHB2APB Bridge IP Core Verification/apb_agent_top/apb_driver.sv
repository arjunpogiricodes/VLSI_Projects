

//--------------- apb driver--------------------------//

class apb_driver extends uvm_driver#(apb_xtn);

// factory registration

           `uvm_component_utils(apb_driver)

// virtual interface

          virtual ahbtoapb_interface.APB_DRV vif;
          apb_config m_cfg;

// constructor new

          function new (string name = "apb_driver",uvm_component parent);

                      super.new(name,parent);

          endfunction
// build phase

         function void build_phase(uvm_phase phase);
                  super.build_phase(phase);
                  if(!uvm_config_db #(apb_config) :: get(this,"","apb_config",m_cfg))
                          `uvm_fatal(get_full_name(),"cannot get the m_cfg handle from apb_top in apb_driver")
                
         endfunction 
// connect phase 

         function void connect_phase(uvm_phase phase);
                
                  vif = m_cfg.vif;

         endfunction

// run phase

        task run_phase(uvm_phase phase);
                 super.run_phase(phase);
                 forever
                       begin
                           send_to_dut();
                            //req.print();
                       end
       endtask

// send to dut task driver logic

        task send_to_dut();

               while(vif.apb_drv.PSEL !==1)
             //  while(vif.apb_drv.PSEL !==(1|2|4|8))
                    @(vif.apb_drv);
                   // @(vif.apb_drv);

              if(vif.apb_drv.PWRITE ==0)
                   begin
                   while(vif.apb_drv.PENABLE !==1)
                   @(vif.apb_drv);
                   //vif.apb_drv.PRDATA <=32'h1234_5678;
                   vif.apb_drv.PRDATA <= $urandom;

                   end
                   @(vif.apb_drv); 
            
                   @(vif.apb_drv);  
                      
                
       endtask  


endclass

