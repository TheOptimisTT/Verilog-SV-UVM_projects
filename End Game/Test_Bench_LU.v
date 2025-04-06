module Test_Bench_LU();
	reg clk;
  	reg rst;
  	reg[7:0] ICODE;
  	reg[7:0] dsgn_stm[0:15];
  	reg[3:0] addr_index;
  	integer i, ii, clk_counter;
  	reg mux1_chk, mux2_chk, mux3_chk;

    lu_processor lu_proc(
      .clk(clk),
      .rst(rst),
      .ICODE(ICODE)
    );

    initial begin
      	$dumpfile("dump.vcd"); $dumpvars;
    	clk = 0;
      	clk_counter = 0; //DBG
      	ICODE = 0;
      	addr_index = 0;
      for(int i=0; i<23; i++)begin
          	#5;
        	clk = ~clk;
       end
      $display("======== Simulation END ========");
      $display(lu_proc.SyncMEM2P_instance1.mem);
      $display("Clks = %0d", clk_counter);
      $finish();
    end
    initial begin
      //$readmemb("stim.txt", dsgn_stm, 0);
      $readmemb("custom_stim.txt", dsgn_stm, 0);
      $readmemb("mem_init.txt", lu_proc.SyncMEM2P_instance1.mem, 0);
      $display(dsgn_stm);
      $display(lu_proc.SyncMEM2P_instance1.mem);
    end

    initial begin
      	rst = 1;
      	#1;
      	rst = 0;
      	#1;
      	forever begin
       		@(posedge clk);
          	clk_counter++;
        	ICODE = dsgn_stm[addr_index];
        	addr_index = addr_index+1;
      	end
    end

  initial begin
    //Used for longer sims or if there is an infinite loop
    #300;
    $display("======== Simulation FAIL>300ps END ========");
    $display(lu_proc.SyncMEM2P_instance1.mem);
    $display("Clks=%0d", clk_counter);
    $finish();
  end
    /*
  initial begin
  	//infinite clk if needed
      	forever begin
        	#5;
     z   	clk = ~clk;
        	
      	end
   end
  */
  //checkers
  initial begin
    mux1_chk = 1'b0;
    mux2_chk = 1'b0;
    mux3_chk = 1'b0;
    #2;//reset signals
    mux1_chk = 1'b0;
    mux2_chk = 1'b0;
    mux3_chk = 1'b0;
  end
  
  always@(lu_proc.S1_BYPASS_REG_CNTRL)begin
    if(mux1_chk)begin
    	if(lu_proc.S1_BYPASS_REG_CNTRL)
      		$display("[MUX_1 HIT]T=%0t S2_S0S3DF_MUX = %b",$time, lu_proc.S1_BYPASS_REG_CNTRL);
    	else
      		$display("[MUX_1 HIT]T=%0t S2_S0S3DF_MUX = %b",$time,lu_proc.S1_BYPASS_REG_CNTRL);
    end
  end
  
  always@(lu_proc.S1_ADDR or lu_proc.S3_ADDR)begin
    if(mux2_chk)begin
      reg cond;
      assign cond = lu_proc.S1_ADDR == lu_proc.S3_ADDR;
      if(cond)
        $display("[MUX_2 HIT]T=%0t S2_S1S3DF_MUX = %b",$time, cond);
      else
        $display("[MUX_2 HIT]T=%0t S2_S1S3DF_MUX = %b",$time, cond);
    end
  end
  
   always@(lu_proc.S2_ADDR or lu_proc.S3_ADDR)begin
     if(mux3_chk)begin
      reg cond;
      assign cond = lu_proc.S2_ADDR == lu_proc.S3_ADDR;
      if(cond)
        $display("[MUX_2 HIT]T=%0t S2_S1S3DF_MUX = %b",$time, cond);
      else
        $display("[MUX_2 HIT]T=%0t S2_S1S3DF_MUX = %b",$time, cond);
    end
  end
endmodule