module Three_port_sync_mem
                    #(
                        parameter WIDTH = 8,
                        parameter DEPTH = 16
                    )
                    (
                        input clk,
                        input rst,

                        //port0
                        input we0,
                        input [DEPTH] addr0,
                        input [WIDTH]wrData0,
                        output [WIDTH] rdData0,

                        //port1
                        input we1,
                        input [DEPTH] addr1,
                        input [WIDTH]wrData1,
                        output [WIDTH] rdData1,

                        //port0
                        input we2,
                        input [DEPTH] addr2,
                        input [WIDTH]wrData2,
                        output [WIDTH] rdData2,
                    );
//port priority: 0 > 1 > 2


localparam NDEPTH = 1<<DEPTH;
reg [WIDTH-1:0] local_mem [0 : NDEPTH - 1];

always@(posedge clk or negedge rst)begin
    if(we0)begin
        mem[addr0] <= wrData0;
    end
    else if(we1)begin
        mem[addr1] <= wrData1;
    end
    else if(we2)begin
        mem[addr2] <= wrData2;
    end
end
assign rdData0 = (~we0) ? mem[addr0] : 0;
assign rdData1 = (~we1) ? mem[addr1] : 0;
assign rdData2 = (~we2) ? mem[addr2] : 0; 

endmodule



module tb_3port();
localparam WIDTH = 8;
localparam DEPTH = 3;


Three_port_sync_mem #() mod1 ();


endmodule