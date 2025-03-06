module tb_3port_mem();

localparam WIDTH = 8;
localparam DEPTH = 4;
localparam NDEPTH = 1<<DEPTH;


  reg clk, rst;
  reg [31:0] i;
  reg [2:0] time_dly;
  
  reg 				we0, we1, we2;
  reg [DEPTH-1:0] 	addr0, addr1, addr2;
  reg [WIDTH-1:0] 	wrData0, wrData1, wrData2;
  wire [WIDTH-1:0] 	rdData0, rdData1, rdData2;

  Three_port_sync_mem #(.WIDTH(WIDTH), .DEPTH(DEPTH))
  						my_3port_mem(
                        .clk,
                        .rst,
                        //port0
                        .we0,
                        .addr0,
                        .wrData0,
                        .rdData0,
                        //port1
                        .we1,
                        .addr1,
                        .wrData1,
                        .rdData1,
                        //port2
                        .we2,
                        .addr2,
                        .wrData2,
                        .rdData2
                        			);

initial begin
  $dumpfile("wave.vcd"); 
  $dumpvars(0, tb_3port_mem); 
  $display("=========================Sim Start=========================");
  $display("Width param: %0d", WIDTH);
  $display("DEPTH param: %0d", DEPTH);
  $display("NDEPTH param: %0d", NDEPTH); 
  clk = 0; rst = 0; i = 0; time_dly = 0;
  we0 = 0; we1 = 0; we2 = 0;
  addr0 = 0; addr1 = 0; addr2 = 0;
  wrData0 = 0; wrData1 = 0; wrData2 = 0;
  #2;
  rst = 1'b1;
  
  $display("========================= Fill with Zeros =========================");
  fill_with_Zero();
  $display("Memory::");
  $display(my_3port_mem.mem);
  #2;
  $display("========================= Write through port 1 =========================");
  port_write_select(1,1);
  $display("Memory::");
  $display(my_3port_mem.mem);
  #2;
  $display("========================= Write through port 2 =========================");
  port_write_select(2,2);
  $display("Memory::");
  $display(my_3port_mem.mem);
  #2;
  $display("========================= Random Write With clk  =========================");
  random_Write();
  $display("Memory::");
  $display(my_3port_mem.mem);
  #2;
  $display("========================= Random Write without CLK =========================");
  random_Write_no_clk();
  $display("Memory::");
  $display(my_3port_mem.mem);
  #2;
  $finish();
end
  
always #2 clk = ~clk;
   task fill_with_Zero();
    $display(i);
    i = 0;
     while(i < NDEPTH + 1)begin
      we0 = 1;
      wrData0 = 0;
      addr0 = i;
      i = i+1'b1;
      @(posedge clk);
    end
  endtask
  
  task port_write_select(reg [1:0] port, reg [WIDTH-1:0] data);
    $display(i);
    i = 0;
    while(i < NDEPTH + 1)begin
      if(port == 0)begin
        we0 = 1; we1 = 0; we2 = 0;
        wrData0 = data;
        addr0 = i;
        i = i+1'b1;
      end
      else if(port == 1)begin
        we0 = 0; we1 = 1; we2 = 0;
        wrData1 = data;
        addr1 = i;
        i = i+1'b1;
      end
      else if(port == 2)begin
        we0 = 0; we1 = 0; we2 = 1;
        wrData2 = data;
        addr2 = i;
        i = i+1'b1;
      end
      else begin
        $display("This value is not allowed %0d",port);
      end
      @(posedge clk);
    end
  endtask
  
  task random_Write();
    i = 0;
    while(i < NDEPTH + 1)begin
      we0 = $random % 2;
      we1 = $random % 2;
      we2 = $random % 2;
      wrData0 = $random % NDEPTH;
      wrData1 = $random % NDEPTH;
      wrData2 = $random % NDEPTH;
      addr0 = i;
      addr1 = i + 1'b1;
      addr2 = addr1 + 1'b1;
      i = i+1'b1;
      @(posedge clk); 
    end
  endtask
  
  task random_Write_no_clk();
    i = 0;
    while(i < NDEPTH + 1)begin
      we0 = $random % 2;
      we1 = $random % 2;
      we2 = $random % 2;
      wrData0 = $random % NDEPTH;
      wrData1 = $random % NDEPTH;
      wrData2 = $random % NDEPTH;
      addr0 = i;
      addr1 = i + 1'b1;
      addr2 = addr1 + 1'b1;
      i = i+1'b1;
      time_dly = ($random % 7) + 1;
      #(time_dly);
    end
  endtask
endmodule