


// inter face 

interface axi_if(input bit ACLK,ARESET_n);


// Write_adress_channel

			logic [31:0] AWADDR;
			logic AWVALID,AWREADY;
			logic [3:0] AWID;
			logic [3:0] AWLEN;
			logic [2:0] AWSIZE;
			logic [1:0] AWBURST;

// write_data_chennel

		    logic [3:0] WID;
			logic [31:0] WDATA; 	
			logic [3:0] WSTRB;
			logic WREADY,WLAST,WVALID;

// write response channel

			logic [3:0] BID;
			logic [31:0] BRESP;
			logic [3:0] BVALID,BREADY;
			
// read address channel

			logic [3:0] ARID;
            logic [31:0] ARADDR;
            logic [3:0] ARLEN;
            logic [2:0] ARSIZE;
            logic [1:0] ARBURST;
            logic  ARVALID,ARREADY;

// read data/response channel

			logic [3:0] RID;
			logic [31:0]RDATA;
			logic [1:0] RRESP;
			logic RREADY,RLAST,RVALID;

//---------CLOCKING BLOCK FOR MASTER-----------//

           clocking m_drv@(posedge ACLK);
				default input #1 output #1;
				
// write address channel

				output AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
				input AWREADY;
			
// write data channel	

				output WID,WDATA,WLAST,WVALID,WSTRB;
				input WREADY;

// write response channel

				input BID,BRESP,BVALID;
				output BREADY;

// read address channel	

				output ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
				input ARREADY;
			
// read data/response channel

				input RID,RDATA,RRESP,RVALID;
				output RREADY;

            endclocking
			
			clocking m_mon @(posedge ACLK);
				default input #1 output #1;
		// write address channel

				input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
				input AWREADY;
			
// write data channel	

				input WID,WDATA,WLAST,WVALID,WSTRB;
				input WREADY;

// write response channel

				input BID,BRESP,BVALID;
				input BREADY;

// read address channel	

				input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
				input ARREADY;
			
// read data/response channel

				input RID,RDATA,RRESP,RVALID;
				input RREADY;
            endclocking	
//---------- CLOCKING BLOCK SLAVE -----------//

			clocking s_drv@(posedge ACLK);
                default input #1 output #1;
                
// write address channel

				input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
				output AWREADY;

// write data channel

				input WID,WDATA,WSTRB,WLAST,WVALID;
                output WREADY;

// write response channel

				output BID,BVALID,BRESP;
				input BREADY;

// read address channel				
				
			    input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
				output ARREADY;

// read data/response channel

				output RID,RDATA,RLAST,RVALID;
				input RREADY;
				
            endclocking		

			clocking s_mon@(posedge ACLK);
                default input #1 output #1;
                
// write address channel

				input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
				output AWREADY;

// write data channel

				input WID,WDATA,WSTRB,WLAST,WVALID;
                output WREADY;

// write response channel

				output BID,BVALID,BRESP;
				input BREADY;

// read address channel				
				
			    input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
				output ARREADY;

// read data/response channel

				output RID,RDATA,RLAST,RVALID;
				input RREADY;
				
            endclocking	

// MODPORTS DECLARATION

			modport M_DRV(clocking m_drv);
            modport M_MON(clocking m_mon);
			modport S_DRV(clocking s_drv);
            modport S_MON(clocking s_mon);
			
            				

endinterface