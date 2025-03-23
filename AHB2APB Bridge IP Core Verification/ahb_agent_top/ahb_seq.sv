

// ---------------ahb sequence--------------//

class ahb_seq extends uvm_sequence#(ahb_xtn);

// factory registration

           `uvm_object_utils(ahb_seq)

// varialbles 

          bit [2:0]  Hsize;
          bit [2:0]  Hburst;
          bit [31:0] Haddr;
          bit [9:0]  Hlen;
          bit Hwrite;

// constructor new

          function new (string name = "ahb_seq");

                      super.new(name);

          endfunction 
  

endclass


//-----------------  single trasfer sequence ----------------------//

class single_seq extends ahb_seq;

 
// factory registration

        `uvm_object_utils(single_seq)

// constructor new
 
        function new(string name ="single_seq");

                super.new(name);      

        endfunction

// task body


         task body();

                 req = ahb_xtn :: type_id :: create("req");
                 start_item(req);
                 assert(req.randomize() with {HTRANS == 2'b10;HBURST == 0;})
                    else
                      begin
                           `uvm_fatal(get_full_name(),"!!!!!!!!!!!!!!!!!!!!randomization not successfull!!!!!!!!!!!!!!!!!!!!!!")
                      end
                finish_item(req);

         endtask 
    
endclass


//------------------- incrment sequence ----------------------// 

class incr_seq extends ahb_seq;

 
// factory registration

        `uvm_object_utils(incr_seq)

// constructor new
 
        function new(string name ="small_seq");

                super.new(name);      

        endfunction

// task body


         task body();

                 req = ahb_xtn :: type_id :: create("req");
                 start_item(req);
                 assert(req.randomize() with { HBURST inside {3,5,7};
                                               HTRANS == 2'b10;
                                               HWRITE == 1;   })
                    else
                      begin
                           `uvm_fatal(get_full_name(),"!!!!!!!!!!!!!!!!!!!!randomization not successfull!!!!!!!!!!!!!!!!!!!!!!")
                      end
                 Haddr   = req.HADDR;
                 Hsize   = req.HSIZE;
                 Hburst  = req.HBURST;
                 Hwrite  = req.HWRITE;
                 Hlen    = req.length;
                 finish_item(req);
                 for(int i = 0; i < (Hlen-1) ; i++)
                      begin
                       start_item(req);
                          assert(req.randomize() with {HTRANS == 2'b11;
						       HSIZE  == Hsize;
	                                               HBURST == Hburst;
                                                       HWRITE == Hwrite; 
                                                       HADDR  == (Haddr + (2**Hsize)); 
                                                     })
                              else
                                  begin
                                       `uvm_fatal(get_full_name(),"!!!!!!!!!!!!!!!!!!!!randomization not successfull!!!!!!!!!!!!!!!!!!!!!!")
                                  end
                         Haddr = req.HADDR;
                         finish_item(req);
                     end

         endtask 
    
endclass

//------------------- wrapper sequence ----------------------// 

class wrap_seq extends ahb_seq;

// factory registration

        `uvm_object_utils(wrap_seq)
		
		bit [31:0] start_address,boundary_address;
		
		
// constructor new
 
         function new(string name = "wrap_seq");

                 super.new(name);
       
         endfunction	

// task body
      

       task body();

                 req = ahb_xtn :: type_id :: create("req");
                 start_item(req);
                 assert(req.randomize() with { HBURST inside {2,4,6};
                                               HTRANS == 2'b10;
                                               HWRITE == 0; })
                    else
                      begin
                           `uvm_fatal(get_full_name(),"!!!!!!!!!!!!!!!!!!!!randomization not successfull!!!!!!!!!!!!!!!!!!!!!!")
                      end
                 
                 Haddr   = req.HADDR;
                 Hsize   = req.HSIZE;
                 Hburst  = req.HBURST;
                 Hwrite  = req.HWRITE;
                 Hlen    = req.length;

	         start_address = ((Haddr)/((2**Hsize)*(Hlen)))*((2**Hsize)*(Hlen));
	         boundary_address = start_address + ((2**Hsize)*(Hlen));
	         Haddr  = ((req.HADDR)+(2**Hsize));

	         finish_item(req);
                   for(int i = 0; i < (Hlen-1) ; i++)
                      begin
                      start_item(req);
                         if(Haddr >= boundary_address)
			      begin
			          Haddr = start_address;
			      end	 
                          assert(req.randomize() with {HTRANS == 2'b11;
						       HSIZE  == Hsize;
	                                               HBURST == Hburst;
                                                       HWRITE == Hwrite; 
                                                       HADDR  == Haddr; })

                              else
                                  begin
                                       `uvm_fatal(get_full_name(),"!!!!!!!!!!!!!!!!!!!!randomization not successfull!!!!!!!!!!!!!!!!!!!!!!")
                                  end
                         Haddr  = (req.HADDR + (2**req.HSIZE));
                       finish_item(req);
                        
                     end	   
					 
        endtask	   


endclass


