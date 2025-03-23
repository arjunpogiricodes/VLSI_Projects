

// msrv32_reg_block

module msrv32_reg_block_tb();

		reg [31:0]pc_mux_in;
		reg clk_in,rst_in;
		wire [31:0] pc_out;

// instantiation

		msrv32_reg_block DUT(pc_mux_in,clk_in,rst_in,pc_out);
// clcok generation

	    always #10 clk_in = ~clk_in;
		
		task initialize;
			begin
				pc_mux_in = 0;
				{clk_in,rst_in} = 0;
		    end
		endtask		
		task res;
			begin
				@(negedge clk_in)
				rst_in = 1'b1;
				@(negedge clk_in)
				rst_in = 1'b0;				
		    end
		endtask		
		
		task stim;
			begin
				@(negedge clk_in)
				pc_mux_in = {$random}%165430;
		    end
		endtask	

		task set;
			begin
				@(negedge clk_in)
				pc_mux_in = 32'hffff;
		    end
		endtask
// stim

		initial begin

			initialize;
			res;
			stim;
			stim;
			stim;
			stim;
			stim;stim;stim;
			stim;stim;stim;
			stim;
			stim;
			stim;
			stim;stim;stim;stim;stim;stim;stim;stim;stim;stim;
			stim;
			stim;
		    stim;
            set;
			#10 $finish;
		  end			
			
endmodule