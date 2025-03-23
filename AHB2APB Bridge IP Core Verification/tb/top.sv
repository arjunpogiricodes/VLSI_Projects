

// ---------------top-----------------------//

module top;
      import uvm_pkg::*;
      import ahbtoapb_pkg::*;

//clcok genration
      bit clk = 1'b1;
      always #5 clk =~clk;
 

// interface 

       ahbtoapb_interface VIF(clk);

// dut

/*
   module rtl_top (input  Hclk,
                   input  Hresetn,
                   input  [1:0] Htrans,
		   input 	[2:0]Hsize, 
		   input 	Hreadyin,
		   input 	[`WIDTH-1:0]Hwdata, 
		   input 	[`WIDTH-1:0]Haddr,
		   input 		Hwrite,
                   input 	[`WIDTH-1:0]Prdata,
		   output 	[`WIDTH-1:0]Hrdata,
		   output 	[1:0]Hresp,
		   output 	Hreadyout,
		   output 	[`SLAVES-1:0]Pselx,
		   output  	Pwrite,
		   output  	Penable, 
		   output  [`WIDTH-1:0] Paddr,
		   output  [`WIDTH-1:0] Pwdata
		    ) ;	
*/
    rtl_top  DUT(.Hclk(clk),
                 .Hresetn(VIF.HRESETn),
                 .Htrans(VIF.HTRANS),
		 .Hsize(VIF.HSIZE), 
		 .Hreadyin(VIF.HREADYin),
		 .Hwdata(VIF.HWDATA), 
		 .Haddr(VIF.HADDR),
		 .Hwrite(VIF.HWRITE),
                 .Prdata(VIF.PRDATA),
		 .Hrdata(VIF.HRDATA),
		 .Hresp(VIF.HRESP),
		 .Hreadyout(VIF.HREADYout),
		 .Pselx(VIF.PSEL),
		 .Pwrite(VIF.PWRITE),
		 .Penable(VIF.PENABLE), 
		 .Paddr(VIF.PADDR),
		 .Pwdata(VIF.PWDATA)
		    ) ;	

           initial 
                   begin
                      `ifdef VCS
                       $fsdbDumpvars(0,top);
                      `endif 
                      uvm_config_db #(virtual ahbtoapb_interface) :: set(null,"*","IN",VIF);

                      run_test("base_test");

                   end   






endmodule
