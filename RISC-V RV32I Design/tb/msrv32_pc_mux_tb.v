

// msrv32_pc_mux_tb

module msrv_pc_mux_tb();

	    reg rst_in;
		reg [1:0]pc_src_in;
		reg [31:0]epc_in;
		reg [31:0]trap_address_in;
		reg branch_taken_in;
		reg [30:0]iaddr_in;
		reg ahb_ready_in;
		reg [31:0]pc_in;
		wire [31:0]iaddr_out,pc_plus_4_out;
		wire misaligned_instr_logic_out;
		wire [31:0]pc_mux_out;

// instantiation

		msrv_pc_mux DUT(rst_in,pc_src_in,epc_in,trap_address_in,branch_taken_in,iaddr_in,ahb_ready_in,pc_in,iaddr_out,pc_plus_4_out,misaligned_instr_logic_out,pc_mux_out);

		task initialize;
			begin
				rst_in = 1;
				pc_src_in = 0;
				epc_in = 0;
				trap_address_in = 0;
				branch_taken_in = 0;
				iaddr_in = 0;
				ahb_ready_in = 0;
				pc_in = 0;			
			end
		endtask	
		task set;
			begin
				rst_in = 0;
				pc_src_in = 2'b11;
				epc_in = 32'hffff;
				trap_address_in = 32'hffff;
				branch_taken_in = 1;
				iaddr_in = 31'hffff;
				ahb_ready_in = 1;
				pc_in = 32'hffff;			
			end
		endtask			
		
		task stim(input [1:0]a,
		input [31:0]b,
		input [31:0]c,
		input d,
		input [30:0]e,
		input f,
		input [31:0]g);
			begin
				pc_src_in = a;
				epc_in = b;
				trap_address_in = c;
				branch_taken_in = d;
				iaddr_in = e;
				ahb_ready_in = f;
				pc_in = g;			
			end
		endtask
		
// initial begin

		initial begin
			initialize;
			#5;
			stim({$random}%4,{$random}%164053,{$random}%164053,{$random}%2,{$random}%164053,{$random}%2,{$random}%164053);
			#10;
			stim({$random}%4,{$random}%164053,{$random}%164053,{$random}%2,{$random}%164053,{$random}%2,{$random}%164053);
			#10;
			stim({$random}%4,{$random}%164053,{$random}%164053,{$random}%2,{$random}%164053,{$random}%2,{$random}%164053);
			#10;
			stim({$random}%4,{$random}%164053,{$random}%164053,{$random}%2,{$random}%164053,{$random}%2,{$random}%164053);
			#10;
			stim({$random}%4,{$random}%164053,{$random}%164053,{$random}%2,{$random}%164053,{$random}%2,{$random}%164053);
			#10;
			stim({$random}%4,{$random}%164053,{$random}%164053,{$random}%2,{$random}%164053,{$random}%2,{$random}%164053);
			#10;
			stim({$random}%4,{$random}%164053,{$random}%164053,{$random}%2,{$random}%164053,{$random}%2,{$random}%164053);
			#10
			set;
			#10;
			$finish;
			
			
			end
endmodule