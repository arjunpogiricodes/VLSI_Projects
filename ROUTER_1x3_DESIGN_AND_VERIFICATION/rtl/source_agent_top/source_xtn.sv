


// transaction class

class source_xtn extends uvm_sequence_item;

// factory registors

       `uvm_object_utils(source_xtn)     

// declare the rand fields

         rand bit [7:0]header_byte;
         rand bit [7:0]payload[];
              bit [7:0]parity_byte;
              bit reset;
              bit pkt_valid;
              bit error;
              bit busy;

// contrants for address 11 not occuring and payload lent must be in between 1 to 63 

         constraint c1{
                        header_byte[1:0] != 2'b11;
                      }
         constraint c2{
                        header_byte[7:2] != 0;
                      }
         constraint c3{
                        payload.size() == header_byte[7:2];
                      } 



// function new constructor

        function new(string name = "source_xtn");

              super.new(name);

         endfunction

// override the inbiult mmethods

//----------------- do copy method   -----------------//

         function void do_copy(uvm_object rhs);

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

//--------------- do compare ---------------------//

        function bit do_compare(uvm_object rhs,uvm_comparer comparer);
               
               source_xtn rhs_;
               if(!$cast(rhs_,rhs))
                   begin
                       `uvm_fatal("do_compare","fatal because casting for do comapre cast not working properly in source xtn") 
                        return 0;
                   end
               return super.do_compare(rhs,comparer) &&(header_byte == rhs_.header_byte) && ( payload == rhs_.payload) && (parity_byte == rhs_.parity_byte); 
   
        endfunction
 

//-----------------  do_print method  -------------------//
//Use printer.print_field for integral variables
//Use printer.print_generic for enum variables

/*
    printer.print_field( "xtn_delay", 		this.xtn_delay,     65,		 UVM_DEC		);
   
    //  	         variable name		xtn_type		$bits(variable name) 	variable name.name
    printer.print_generic( "xtn_type", 		"addr_t",		$bits(xtn_type),		xtn_type.name);

*/

        function void do_print(uvm_printer printer);

                super.do_print(printer);
                printer.print_field( "destin_address" , this.header_byte[1:0] , 2, UVM_DEC);
                printer.print_field( "pay_lenth" , this.header_byte[7:2] , 6 , UVM_DEC);
                printer.print_field( "header_byte" , this.header_byte , 8 , UVM_DEC);
                foreach(payload[i])
                        printer.print_field($sformatf("payload[%0d]",i),this.payload[i] , 8 , UVM_DEC);

                printer.print_field( "parity_byte" , this.parity_byte , 8 , UVM_DEC );

        endfunction

// post randomize function

          function void post_randomize();
                
               parity_byte = header_byte;
               foreach(payload[i])
                        parity_byte = parity_byte ^ payload[i];

          endfunction


endclass  
