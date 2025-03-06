/*module test;
        initial begin
            //$dumpfile("wave.vcd"); // Name of VCD file
            //$dumpvars(0, test);    // Dump all signals in 'test' module
            $display("Hello, Verilog!");
            $finish;
        end
endmodule
*/
module test2;
  reg clk;
  reg [3:0] counter;

  // Generate a clock signal
  always #5 clk = ~clk;

  initial begin
    // Enable VCD dump
    $dumpfile("wave.vcd"); // Name of VCD file
    $dumpvars(0, test2);    // Dump all signals in 'test' module

    // Initialize signals
    clk = 0;
    counter = 0;

    // Run for 10 clock cycles
    repeat (10) begin
      #10 counter = counter + 1;
    end

    $finish; // End simulation
  end
endmodule
