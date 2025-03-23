

//----------------- score board --------------//

class tb_scoreboard extends uvm_scoreboard;

// factory registration

           `uvm_component_utils(tb_scoreboard)

// analysis export declaration

          uvm_tlm_analysis_fifo #(ahb_xtn) ahb_fifo;
          uvm_tlm_analysis_fifo #(apb_xtn) apb_fifo;

// declarastion of transaction
 
          ahb_xtn h_xtn;
          apb_xtn p_xtn;                                                                                                                                                                   

// cover group 

          covergroup ahb_cg;
               
                  coverpoint h_xtn.HADDR {

                                            bins a1 = {[32'h8000_0000:32'h8000_03ff]};   
                                            bins a2 = {[32'h8400_0000:32'h8400_03ff]};
                                            bins a3 = {[32'h8800_0000:32'h8800_03ff]};
                                            bins a4 = {[32'h8c00_0000:32'h8c00_03ff]};

                                           }
                  coverpoint h_xtn.HSIZE {

                                           bins b1 = {0};
                                           bins b2 = {1};
                                           bins b3 = {2};

                                           } 

                /*  coverpoint h_xtn.HBURST {

                                           bins c1 = {0};
                                           bins c2 = {3,5,7};
                                           bins c3 = {2,4,6};

                                            }*/
                   coverpoint h_xtn.HTRANS {

                                           bins non_seq = {2'b10};
                                           bins seq = {2'b11};
                                          
                                           } 
                 coverpoint h_xtn.HWRITE {

                                           bins wr = {1'b1};
                                           bins rd = {1'b0};

                                           } 




          endgroup


          covergroup apb_cg;
               
                  coverpoint p_xtn.PADDR {

                                            bins a1 = {[32'h8000_0000:32'h8000_03ff]};   
                                            bins a2 = {[32'h8400_0000:32'h8400_03ff]};
                                            bins a3 = {[32'h8800_0000:32'h8800_03ff]};
                                            bins a4 = {[32'h8c00_0000:32'h8c00_03ff]};

                                           }
                  coverpoint p_xtn.PSEL {

                                           bins b1 = {4'b0001};
                                           bins b2 = {4'b0010};
                                           bins b3 = {4'b0100};
                                           bins b4 = {4'b1000};

                                           } 

                 coverpoint p_xtn.PWRITE {

                                           bins wr = {1'b1};
                                           bins rd = {1'b0};

                                           }
                 coverpoint p_xtn.PENABLE {

                                           bins wr = {1'b1};
                                           bins rd = {1'b0};

                                           }  




          endgroup


// constructor new

          function new (string name = "tb_scoreboard",uvm_component parent);

                      super.new(name,parent);
                      ahb_fifo = new("ahb_fifo",this);
                      apb_fifo = new("apb_fifo",this);
                      ahb_cg = new();
                      apb_cg = new();

          endfunction

// task run_phaase


          task run_phase(uvm_phase phase);

                 super.run_phase(phase);
                 forever 
                        begin
                            fork
                                begin
                                    ahb_fifo.get(h_xtn);
                                    ahb_cg.sample();
                                    h_xtn.print(); 
                                end
                                begin
                                    apb_fifo.get(p_xtn);
                                    apb_cg.sample();
                                    p_xtn.print();
                                end
                             join
                                check_data();
                        end
          endtask

// task comper task

           task comper(int H_addr,P_addr,H_data,P_data);

                    if(H_addr == P_addr) 
                        begin
                           $display("\n==========================================================\n");
                           $display(" ------------- Successfully Address MATCHED ------------- ");
                           $display("\n==========================================================\n");
                        end
                    else
                        begin
                           $display("\n==========================================================\n");
                           $display(" --------------- Address Matched FAILED ----------------- ");
                           $display("\n==========================================================\n");
                       end
                    if(H_data == P_data)
                        begin
                           $display("\n==========================================================\n");
                           $display(" -------------- Successfully DATA MATCHED --------------- ");
                           $display("\n==========================================================\n");
                        end
                    else
                        begin
                             $display("\n==========================================================\n");
                             $display(" ------------- Data Matched FAILED --------------------");
                             $display("\n==========================================================\n");
                        end
          endtask

// task check

         task check_data();

               if(h_xtn.HWRITE == 1)
                   begin
                      if(h_xtn.HSIZE == 0)
                          begin
                              if(h_xtn.HADDR[1:0] == 2'b00)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HWDATA[7:0],p_xtn.PWDATA);
                              if(h_xtn.HADDR[1:0] == 2'b01)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HWDATA[15:8],p_xtn.PWDATA);
                              if(h_xtn.HADDR[1:0] == 2'b10)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HWDATA[23:16],p_xtn.PWDATA);
                              if(h_xtn.HADDR[1:0] == 2'b00)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HWDATA[31:24],p_xtn.PWDATA);
                              // address will increment 1 every new address came so 
                          end 
                      if(h_xtn.HSIZE == 1)
                          begin
                              if(h_xtn.HADDR[1:0] == 2'b00)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HWDATA[15:0],p_xtn.PWDATA);
                              if(h_xtn.HADDR[1:0] == 2'b10)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HWDATA[31:16],p_xtn.PWDATA);
                             // address will increment 2 so only even                           
                          end
                     if(h_xtn.HSIZE == 2)
                          begin
                              comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HWDATA,p_xtn.PWDATA);
                             // address will increment 2 so only even                           
                          end 
                   end
              if(h_xtn.HWRITE == 0)
                   begin
                      if(h_xtn.HSIZE == 0)
                          begin
                              if(h_xtn.HADDR[1:0] == 2'b00)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HRDATA,p_xtn.PRDATA[7:0]);
                              if(h_xtn.HADDR[1:0] == 2'b01)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HRDATA,p_xtn.PRDATA[15:8]);
                              if(h_xtn.HADDR[1:0] == 2'b10)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HRDATA,p_xtn.PRDATA[23:16]);
                              if(h_xtn.HADDR[1:0] == 2'b00)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HRDATA,p_xtn.PRDATA[31:24]);
                              // address will increment 1 every new address came so 
                          end 
                      if(h_xtn.HSIZE == 1)
                          begin
                              if(h_xtn.HADDR[1:0] == 2'b00)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HRDATA,p_xtn.PRDATA[15:0]);
                              if(h_xtn.HADDR[1:0] == 2'b10)
                                 comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HRDATA,p_xtn.PRDATA[31:16]);
                             // address will increment 2 so only even                           
                          end
                     if(h_xtn.HSIZE == 2)
                          begin
                              comper(h_xtn.HADDR,p_xtn.PADDR,h_xtn.HRDATA,p_xtn.PRDATA);
                             // address will increment 2 so only even                           
                          end 

                    $display("\n==========================================================\n");
                    $display(" AHB_COVERAGE = %0.2f  APB_COVERAGE = %0.2f ",ahb_cg.get_coverage(),apb_cg.get_coverage());
                    $display("\n==========================================================\n"); 
                   end
        
         endtask             
           
endclass

