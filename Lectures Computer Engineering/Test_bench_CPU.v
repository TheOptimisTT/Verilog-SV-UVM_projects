module Test_Bench_LU();

	reg clk;
	reg rst;
	reg[7:0] ICODE;
	reg[7:0] dsgn_stm[0:15];
	reg[3:0] addr_index;
    integer i;
    integer ii;
	
	lu_processor lu_proc(.clk(clk),
		     	     .rst(rst),
		     	     .ICODE(ICODE));

	initial begin
		clk = 0;
		forever begin
			#5;
			clk = ~clk;
		end
	end
	
	initial begin
		//$readmemb("stimulus.psj", dsgn_stm, 0);
		//$readmemb("mem_init.psj", lu_proc.SyncMEM2P_instance1.mem, 0);
        for(i = 0; i<16; i=i+1)begin
            dsgn_stm[i] = i;
        end
        for(ii = 0; ii<256; ii=ii+1)begin
            $display("ii=%0d",ii);
            lu_proc.SyncMEM2P_instance1.mem[ii] = 16'b0;
        end
		#1000;
		$finish();
	end
	
	initial begin
        $dumpfile("wave.vcd"); // Name of VCD file
        $dumpvars(3, Test_Bench_LU);    // Dump all signals in 'test' module
		addr_index = 0;
		rst = 1;//CPU in reset
		#12;
		rst = 0; //CPU active
		ICODE = 0;
		forever begin
			@(posedge clk);
			ICODE = dsgn_stm[addr_index];
			addr_index = addr_index+1;
		end
	end

	
endmodule