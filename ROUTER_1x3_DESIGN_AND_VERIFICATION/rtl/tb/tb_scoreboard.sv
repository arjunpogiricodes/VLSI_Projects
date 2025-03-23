


class tb_scoreboard extends uvm_scoreboard;


// factory registration
 
          `uvm_component_utils(tb_scoreboard)

// declaring the  handle for env_config 
 
          router_env_config m_cfg;
		  
// declaring the handle for tlm ports

         uvm_tlm_analysis_fifo #(source_xtn) source_fifo[];
         uvm_tlm_analysis_fifo #(destin_xtn) destin_fifo[];	

// declaring the source and destination transaction class

        source_xtn s_xtn;
        source_xtn source_cov_xtn;

        destin_xtn d_xtn;
        destin_xtn destin_cov_xtn;
 		

// addrs geting variable

         bit[2] addr;

// write fucntion covrage cover group

      covergroup source_cg;
	  
	    ADDER:   coverpoint s_xtn.header_byte[1:0]{
                                                             
                                                            bins b1 = {2'b00};
						       	    bins b2 = {2'b01};
                                                            bins b3 = {2'b10};															

                                                          }	
        DATA_IN: coverpoint s_xtn.header_byte[7:2]{

                                                           bins b1 = {[1:21]};
							   bins b2 = {[22:41]};
							   bins b3 = {[42:63]}; 
		
	                                                        }   
        ERROR: 	 coverpoint s_xtn.error {
          
                                                           bins b1 = { 1'b1 };
                                                           bins b2 = { 1'b0 };

                                                  } 

       /* BUSY:     coverpoint s_xtn.busy {

                                                           bins b1 = { 1'b1 };
                                                           bins b2 = { 1'b0	};													   
	  
	                                             } */
												 
	   // CROSS_ALL: cross ADDER,DATA_IN,ERROR,BUSY;											 
												 
	  endgroup
	  
	  covergroup destin_cg;
	  
	     /*  VALID_OUT: coverpoint d_xtn.valid_out{
		   
		                                                    bins b1 = {1'b1};
															bins b2 = {1'b0};
															
														  }*/
           DATA_OUT: coverpoint d_xtn.header_byte[7:2]{

                                                           bins b1 = {[1:21]};
							   bins b2 = {[22:41]};
							   bins b3 = {[42:63]}; 
		
	                                                        }														  
	  
	  endgroup


// we have to implement check method  for comparing the data 


// function new constructor

          function new(string name = "tb_scoreboard",uvm_component parent= null );

                super.new(name,parent);
                source_cg = new();
                destin_cg = new(); 				
                
          endfunction:new
 

// build_phase

         function void build_phase(uvm_phase phase);

                    super.build_phase(phase);
					
				    if(!uvm_config_db #(router_env_config) :: get (this,"","router_env_config",m_cfg))
					     begin
				                  `uvm_fatal(get_full_name(),"cannot get he router_env_config handle m_cg in scoreboard ")
                                             end 
				    if(!uvm_config_db #(bit[2]) :: get (this,"","bit",addr))
					     begin
				                  `uvm_fatal(get_full_name(),"cannot get the addr from test class are yout set that  in scoreboard ")
                                             end 
                                     
	
					source_fifo = new [m_cfg.no_of_source];
					
					foreach(source_fifo[i])
					      begin
                               source_fifo[i] = new ("source_fifo",this);
						   end	
						   
                    destin_fifo = new[m_cfg.no_of_destin];
				
					foreach(destin_fifo[i]) 
					      begin
						      destin_fifo[i] = new($sformatf("destin_fifo[%0d]",i),this);
						  end 
         endfunction		 

       task run_phase(uvm_phase phase);
              super.run_phase(phase);
              forever
	                begin
			      fork
                                  begin
							 
			                    source_fifo[0].get(s_xtn);
				            source_cg.sample();
								  
				   end 
                             
                                 begin
								 
					   destin_fifo[addr].get(d_xtn);
				           destin_cg.sample();

				 end
                             join
       		         compare(s_xtn,d_xtn); 
                         $display("\n=========================================================================\n");
		         $display("\n source  side functional coverage = %.3f \n",source_cg.get_coverage);
		         $display("\n destin  side functional coverage = %.3f \n",destin_cg.get_coverage);	
                         $display("\n=========================================================================\n");						  
                     end

        endtask:run_phase  
 

/*       task run_phase(uvm_phase phase);
              super.run_phase(phase);
              forever
			         begin
					      fork
                             begin
							 
			                      source_fifo[0].get(s_xtn);
				                  source_cg.sample();
								  
							 end 
                             fork
                                 begin
								 
								      destin_fifo[0].get(d_xtn);
				                      destin_cg.sample();

								 end
                                 begin
								 
								      destin_fifo[1].get(d_xtn);
				                      destin_cg.sample();
									  
								 end
                                 begin
								 
								      destin_fifo[2].get(d_xtn);
				                      destin_cg.sample();
		  
								 end
                             join_any
                             disable fork;							                   
                          join
						  compare(s_xtn,d_xtn); 
                   $display("\n=========================================================================\n");
		           $display("\n source  side functional coverage = %.3f \n",source_cg.get_coverage);
				   $display("\n destin  side functional coverage = %.3f \n",destin_cg.get_coverage);	
                   $display("\n=========================================================================\n");						  
                     end

        endtask:run_phase  
*/

// task for comparing the source and destination packets

        task compare(source_xtn s_xtn,destin_xtn d_xtn);
		
		       bit check;
			   
		       if(s_xtn.header_byte == d_xtn.header_byte)
			        begin 
					     $display("\n===================== Header_Byte Matched SuccessFull =====================\n");
						 check  = 1'b1;
				    end
               else
                    begin
					     $display("\n===================== Header_Byte Not Matched =====================\n");
						 check  = 1'b0;
					end	
					
                if(s_xtn.payload == d_xtn.payload)
			        begin 
					     $display("\n===================== Payload Matched SuccessFull =====================\n");
						 check  = 1'b1;
				    end
               else
                    begin
					     $display("\n===================== Payload Not Matched =====================\n");
						 check  = 1'b0;
					end	
                if(s_xtn.parity_byte == d_xtn.parity_byte)
			        begin 
					     $display("\n===================== Parity_Byte Matched SuccessFull =====================\n");
						 check  = 1'b1;
				    end
               else
                    begin
					     $display("\n===================== Parity_Byte Not Matched =====================\n");
						 check  = 1'b0;
					end	
					
				if(check == 1'b1)
                     begin
					 
                        $display("\n=========================================================================\n");
                        $display("\n     SUCCESSFULLY MATCHED    \n");
						$display("\n=========================================================================\n");
 						
                     end	
                else
                    begin
					 
                        $display("\n=========================================================================\n");
                        $display("\n     PACKETS NOT MATCHED    \n");
						$display("\n=========================================================================\n");
 	                end	

				   
							
		endtask




endclass:tb_scoreboard
