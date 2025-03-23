/*
// msrv_pc mux 
// adder pc_in + 32'h0000_0004 this will pc_phase_out => 1 
// concat iaddr_in and 1'b0                           => 2
// mux selecting any of input(1,2) using branch_taken_in output next_pc
// mux 4:1 inputs BOOTADDRESS,epc_in, trap_address_in,next_pc selection lines
// as pc_src_in give s output pc_mux_out              => 3
//  another 2:1 (3,i_addres_out) selextion line as ahb_ready_in 
//                                            output  => 4 
// another 2:1 mux (4,BOOT ADDDRESS) selectionline  rst_in output i_addr_out
// assign to and gate inputs next_pc & branch_tasken_in output misaligned_instr_out
*/

module msrv_pc_mux (rst_in,pc_src_in,epc_in,trap_address_in,branch_taken_in,iaddr_in,ahb_ready_in,pc_in,iaddr_out,pc_plus_4_out,misaligned_instr_logic_out,pc_mux_out);

		input rst_in;
		input [1:0]pc_src_in;
		input [31:0]epc_in;
		input [31:0]trap_address_in;
		input branch_taken_in;
		input [30:0]iaddr_in;
		input ahb_ready_in;
		input [31:0]pc_in;
		output reg [31:0]iaddr_out,pc_plus_4_out;
		output reg misaligned_instr_logic_out;
		output reg [31:0]pc_mux_out;

		reg [31:0] next_pc;

		parameter  BOOT_ADDRESS = 32'b0;

		reg [31:0] temp;

		always@(*)
			begin
				
				
				pc_plus_4_out = pc_in + 32'h0000_0004;		
				
				begin		
					if(branch_taken_in)
						 next_pc = {iaddr_in[30:0],1'b0};
					else
						 next_pc = pc_plus_4_out;
				end

				begin
					case(pc_src_in)
						2'b00: pc_mux_out = BOOT_ADDRESS;    	  
						2'b01: pc_mux_out = epc_in;
						2'b10: pc_mux_out = trap_address_in;
						2'b11: pc_mux_out = next_pc;
						default: pc_mux_out = 32'd0;
					endcase	
				end 
                
				begin
					if(rst_in)
						iaddr_out = BOOT_ADDRESS;
					else
					  begin
					  if(ahb_ready_in)
							temp = pc_mux_out;
					  else
							temp = iaddr_out;					   
	                         iaddr_out = temp;
				      end				
				

				end

				
				misaligned_instr_logic_out = next_pc[0] & branch_taken_in;

		   end


endmodule
