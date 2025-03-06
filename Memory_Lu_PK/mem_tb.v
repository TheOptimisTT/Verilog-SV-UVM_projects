// Code your testbench here
// or browse Examples
module mem_tb();

localparam WIDTH = 8;
localparam DEPTH = 4;
localparam NDEPTH = 1<<DEPTH;


reg clk,rst;
reg [31:0] i;
integer seed;
reg we;
reg [DEPTH-1:0] addr;
reg [WIDTH-1:0] wrData;
wire [WIDTH-1:0] rdData_sync;
wire [WIDTH-1:0] rdData_Async;

aSync_mem #(.WIDTH(WIDTH), .DEPTH(DEPTH)) my_ASYNC_mem1
                  (
                    .we(we),
                    .addr(addr),
                    .wrData(wrData),
                    .rdData(rdData_Async)
                  );
Sync_mem_struct #(.WIDTH(WIDTH), .DEPTH(DEPTH)) my_SYNC_mem1
                  (
                    .we(we),
                    .clk(clk),
                    .rst(rst),
                    .addr(addr),
                    .wrData(wrData),
                    .rdData(rdData_sync)
                  );



initial begin
    $dumpfile("wave.vcd"); // Name of VCD file
    $dumpvars(0, mem_tb);    // Dump all signals in 'test' module
    clk = 0; rst = 0; we = 0; addr = 0; wrData = 0;
    #5;
    rst = 1'b1;
    we = 1'b1;
    i = 32'b0;
  	wrData = 1'b1;
    front_sweep_Write();
    $display("Width param: %0d", WIDTH);
    $display("DEPTH param: %0d", DEPTH);
    $display("NDEPTH param: %0d", NDEPTH);
    #5;

  $display("ASYNC:");
  $display(my_ASYNC_mem1.local_mem); // all Wrdata values are expected to be in the local_mem

  $display("SYNC:");
  $display(my_SYNC_mem1.mem1.local_mem); // every other data value is expected to be in the local_mem

  $finish();
end
always #5 clk = ~clk;

task front_sweep_Write();
    while(i < NDEPTH)begin
      wrData = 1 + ($random % 15);
        addr = i;
        i = i+1'b1;
        #5; 
    end
endtask
endmodule