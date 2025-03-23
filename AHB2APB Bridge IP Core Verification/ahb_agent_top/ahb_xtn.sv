

//--------------------ahb transaction-----------------//

class ahb_xtn extends uvm_sequence_item;

// factory registration

           `uvm_object_utils(ahb_xtn)

// PROPERTIES

         rand bit[31:0]   HADDR;
         rand bit[1:0]    HTRANS;
         rand bit         HWRITE;
         rand bit[2:0]    HSIZE;
         rand bit[2:0]    HBURST;
         rand bit[31:0]   HWDATA;
              bit         HRESETn;
         rand bit         HREADYin;
              bit         HREADYout;
              bit[1:0]    HRESP;
              bit[31:0]   HRDATA;
         
// loacal propertyh

        rand bit[9:0] length;
// Constraints 

         constraint addr{ 
                          HADDR inside{ 
                                        [32'h8000_0000:32'h8000_03ff],
                                        [32'h8400_0000:32'h8400_03ff],
                                        [32'h8800_0000:32'h8800_03ff],
                                        [32'h8c00_0000:32'h8c00_03ff]
                                        };
                          }
      
         constraint boundary{
                             (HADDR%1024) + (length*(2**HSIZE)) <= 1023;
                           }
  
         constraint hsize{
                            HSIZE inside {[0:2]};
                          }
 
         constraint align_addr{
                                 (HSIZE == 1) -> HADDR%2 == 0;
                                 (HSIZE == 2) -> HADDR%4 == 0;
                                }

         constraint len {
                          (HBURST == 0) -> length == 1;
			  (HBURST == 1) -> (length == 1|| length == 4 || length == 8 || length == 16);
                          (HBURST == 2) -> length == 4;
                          (HBURST == 3) -> length == 4;
                          (HBURST == 4) -> length == 8;
                          (HBURST == 5) -> length == 8;
                          (HBURST == 6) -> length == 16;
                          (HBURST == 7) -> length == 16;
                        } 
          constraint bru {HBURST != 1;}                            

                                       
// constructor new

          function new (string name = "ahb_xtn");

                      super.new(name);

          endfunction

// OVERRIDDING DO METHODS

//---------------------- PRINT METHOD -----------------------//

          function void do_print(uvm_printer printer);

                 super.do_print(printer); 
                 printer.print_field("HADDR",this.HADDR,32,UVM_HEX);
                 printer.print_field("HTRANS",this.HTRANS,2,UVM_DEC);
                 printer.print_field("HWRITE",this.HWRITE,1,UVM_BIN);
                 printer.print_field("HSIZE",this.HSIZE,3,UVM_DEC);
                 printer.print_field("HBURST",this.HBURST,3,UVM_DEC);
                 printer.print_field("HWDATA",this.HWDATA,32,UVM_HEX);
                 printer.print_field("HREADYin",this.HREADYin,1,UVM_BIN);
                 printer.print_field("HRESP",this.HRESP,2,UVM_DEC);
                 printer.print_field("HREADYout",this.HREADYout,1,UVM_DEC);
                 printer.print_field("HRDATA",this.HRDATA,32,UVM_HEX);
                 printer.print_field("length",this.length,10,UVM_DEC);
         
          endfunction

// ------------------ do copy ---------------------------//

  /*       function void do_copy(uvm_object rhs);

                source_xtn rhs_;
                if(!$cast(rhs_,rhs)) 
                   begin
                        `uvm_fatal("do_copy"," error because casting for do copy not working properly in source xtn")
                   end
                super.do_copy(rhs);
                header_byte = rhs_.header_byte;
                payload     = rhs_.payload;
                parity_byte = rhs_.parity_byte;   

         endfunction

     */   
    
         

endclass

