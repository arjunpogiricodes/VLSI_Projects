

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

 `include "definitions.v"

interface ahbtoapb_interface(input bit clk);

           bit   HRESETn;
           logic [1:0] HTRANS;
           logic [2:0] HSIZE;
           bit   HREADYin;
           logic [`WIDTH-1:0]HWDATA; 
           logic [`WIDTH-1:0]HADDR;
           bit	 HWRITE;
           logic [`WIDTH-1:0]PRDATA;
           bit   [`WIDTH-1:0]HRDATA;
	   bit   [1:0]HRESP;
	   bit   HREADYout;
           bit   [`SLAVES-1:0]PSEL;
           bit   PWRITE;
           bit   PENABLE; 
	   bit   [`WIDTH-1:0] PADDR;
	   bit   [`WIDTH-1:0] PWDATA;

// ahb driver

         clocking ahb_drv @(posedge clk);
             default input #1 output #1;
                 output HRESETn;
                 output HREADYin;
                 output HWRITE;
                 output HTRANS;
                 output HSIZE;
                 output HWDATA;
                 output HADDR;
                 input HRDATA;
                 input HRESP;
                 input HREADYout;
 

        endclocking

// ahb monitor 

         clocking ahb_mon@(posedge clk);
              default input #1 output #1;
                 input HRESETn;
                 input HREADYin;
                 input HWRITE;
                 input HTRANS;
                 input HSIZE;
                 input HWDATA;
                 input HADDR; 
                 input HRDATA;
                 input HRESP;
                 input HREADYout;
         endclocking

// apb driver


         clocking apb_drv@(posedge clk);
               default input #1 output #1;
                  output PRDATA;
	          input  HRESP;
	          input  HREADYout;
                  input  PSEL;
                  input  PWRITE;
                  input  PENABLE;
	          input  PADDR;
	          input  PWDATA;
         endclocking 
//apb monitor

         clocking apb_mon @(posedge clk);
               default input #1 output #1;
                  input PRDATA;
	          input  HRESP;
	          input  HREADYout;
                  input  PSEL;
                  input  PWRITE;
                  input  PENABLE;
	          input  PADDR;
	          input  PWDATA;
  
         endclocking

// modport declaration

         modport AHB_DRV(clocking ahb_drv);
         modport AHB_MON(clocking ahb_mon);
         modport APB_DRV(clocking apb_drv);
         modport APB_MON(clocking apb_mon);


endinterface
