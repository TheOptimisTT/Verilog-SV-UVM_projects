module Test_Bench_LU2();

	reg clk;
	reg rst;
	reg[7:0] ICODE;
	reg[7:0] dsgn_stm[0:15];
	reg[3:0] addr_index;
    integer i, ii;
	
	lu_processor lu_proc(
					.clk(clk),
		     	    .rst(rst),
                    .ICODE(ICODE)
						);

	//====== Clock related block ======
	initial begin
		clk = 0;
		forever begin
			#5;
			clk = ~clk;
		end
	end
	
	initial begin
		$readmemb("stimulus.txt", dsgn_stm, 0);
		$readmemb("mem_init.txt", lu_proc.SyncMEM2P_instance1.mem, 0);
		$display(dsgn_stm);
		$display(lu_proc.SyncMEM2P_instance1.mem);
		$finish();
	end
	
	initial begin
        $dumpfile("wave.vcd"); 
        $dumpvars(3, Test_Bench_LU2);
		addr_index = 0;
		rst = 1;    //CPU in reset
		ICODE = 0;
		#12;
		rst = 0;    //CPU active
      	#10;
		forever begin
			@(posedge clk);
			ICODE = dsgn_stm[addr_index];
			addr_index = addr_index+1;
		end
	end
endmodule