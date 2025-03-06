Instructions for using Icarus Compiler on MAC
1. Create a .v File
    nano test.v

2. Edit the test.v
    module test;
        initial begin
            $dumpfile("wave.vcd"); // Name of VCD file
            $dumpvars(0, test);    // Dump all signals in 'test' module
            $display("Hello, Verilog!");
            $finish;
        end
    endmodule

3. Compile the test.v file
    - single file
        iverilog -o test.out test.v
    - multiple files
        iverilog -o simulation.out design.v testbench.v


4. Run the compiled file
    vvp test.out

5. Expected output
    Hello, Verilog!

6. Wave View
    https://vc.drom.io/