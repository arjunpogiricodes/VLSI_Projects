







// destination transaction class

class destin_xtn extends uvm_sequence_item;


// factory registration

       `uvm_object_utils(destin_xtn)

// declare the rand feilds

    bit [7:0] header_byte;
    bit [7:0] payload[];
    bit [7:0] parity_byte;

    bit read_enb;
    bit valid_out;

    rand bit [6]delay;

// declare the constructions
// fcuntion new constructor


        function new(string name = "destin_xtn");

                 super.new(name);


        endfunction 


// function do copy overridden 

       function void do_copy(uvm_object rhs);

              destin_xtn rhs_;
              if($cast(rhs_,rhs))
                    begin
                        `uvm_fatal(get_full_name(),"cannot perform the cast properly check in destination transaction")
                     end
               super.do_copy(rhs);
               this.header_byte      = rhs_.header_byte;
               this.payload          = rhs_.payload;
               this.parity_byte      = rhs_.parity_byte; 
               this.read_enb         = rhs_.read_enb;
               this.valid_out        = rhs_.valid_out;
               this.delay            = rhs_.delay;
  
       endfunction


// printing method 

       function void do_print(uvm_printer printer);

            printer.print_field("des_address",this.header_byte[1:0],2,UVM_DEC);
            printer.print_field("pay_lenth",this.header_byte[7:2],6,UVM_DEC);
			printer.print_field("header_byte",this.header_byte,8,UVM_DEC);
            foreach(this.payload[i])
                 begin
                      printer.print_field( $sformatf("payload[%0d]",i) , this.payload[i] , 8 , UVM_DEC);
                 end
            printer.print_field("parity_byte" , this.parity_byte , 8 , UVM_DEC);
 
            printer.print_field( "delay" , this.delay , 6 , UVM_DEC );
          
       endfunction 
endclass
