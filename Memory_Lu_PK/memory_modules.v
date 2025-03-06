// Code your design here
module aSync_mem #(parameter WIDTH = 8, parameter DEPTH = 16)
                  (
                    input we,
                    input  [DEPTH-1:0]  addr,
                    input  [WIDTH-1:0]  wrData,
                    output [WIDTH-1:0] rdData
                  );

    localparam NDEPTH = 1<<DEPTH;

    reg [WIDTH-1:0] local_mem [0 : NDEPTH - 1];

    always@(*)begin
        if(we)begin
            local_mem[addr] = wrData;
        end 
    end
    assign rdData =  (~we) ? local_mem[addr] : 0;
endmodule


module my_reg #(parameter WIDTH = 1)
              (
                input clk,
                input rst,
                input  [WIDTH-1:0] D,
                output reg [WIDTH-1:0] Q
              );
    always@(posedge clk or negedge rst)begin
        if(~rst)begin
            Q <= 1'b0;
        end else begin
            Q <= D;
        end
    end
endmodule

module Sync_mem_struct
                 #(parameter WIDTH = 8, parameter DEPTH = 16)
                  (
                    input we,
                    input clk,
                    input rst,
                    input  [DEPTH-1:0]  addr,
                    input  [WIDTH-1:0]  wrData,
                    output [WIDTH-1:0] rdData
                  );

    
    wire [DEPTH-1:0] wire_addr;
    wire [WIDTH-1:0] wire_wrData;
    wire             wire_we;

    my_reg #(.WIDTH(DEPTH)) my_addr1    (.clk(clk), .rst(rst), .D(addr), .Q(wire_addr));
    my_reg #(.WIDTH(WIDTH)) my_wrData   (.clk(clk), .rst(rst), .D(wrData), .Q(wire_wrData));
    my_reg #(.WIDTH(1))     my_addr2    (.clk(clk), .rst(rst), .D(we), .Q(wire_we));

    aSync_mem #(.WIDTH(WIDTH), .DEPTH(DEPTH)) mem1 (.we(wire_we),
                                                   .addr(wire_addr),
                                                   .wrData(wire_wrData),
                                                   .rdData(rdData)
                                                   );
endmodule

module Sync_mem_behav #(parameter WIDTH = 8, parameter DEPTH = 16)
                  (
                    input we,
                    input clk,
                    input  [DEPTH-1:0]  addr,
                    input  [WIDTH-1:0]  wrData,
                    output [WIDTH-1:0] rdData
                  ); 

    localparam NDEPTH = 1<<DEPTH;
    reg [WIDTH-1:0] local_mem [0 : NDEPTH - 1];
    always@(posedge clk)begin
        if(we)begin
            local_mem[addr] <= wrData;
        end
    end
    assign rdData = !we ? local_mem[addr] : 0;
endmodule