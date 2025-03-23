// msrv32_reg_block_1

module msrv32_reg_block (input [31:0]pc_mux_in,input clk_in,rst_in,output reg [31:0] pc_out);

	always@(posedge clk_in)
		begin
			if(rst_in)
				pc_out <= 32'd0;
			else
				pc_out <= pc_mux_in;
		end		
endmodule