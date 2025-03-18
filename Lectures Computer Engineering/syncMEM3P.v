module syncMEM3P(
        //Port 0
        input   [7:0]  ADDR0,
        input   [15:0] WD0,
        input          WE0,
        output   [15:0] RD0,
        //Port 1
        input   [7:0]  ADDR1,
        input   [15:0] WD1,
        input          WE1,
        output   [15:0] RD1,
        //Port 2
        input   [7:0]  ADDR2,
        input   [15:0] WD2,
        input          WE2,
        output   [15:0] RD2,
        //Common
        input CLK
    );
    reg [15:0] mem [0:255];
    integer i;
    //port 0
    reg [7:0] ADDR0_REG;
    always@(posedge CLK)begin
        if(WE0) mem[ADDR0] <= WD0;
        ADDR0_REG <= ADDR0;
    end
    assign RD0 = mem[ADDR0_REG];
    
    //port 1
    reg [7:0] ADDR1_REG;
    always@(posedge CLK)begin
        if(WE1) mem[ADDR1] <= WD1;
        ADDR1_REG <= ADDR1;
    end
    assign RD1 = mem[ADDR1_REG];
    
    //port 2
    reg [7:0] ADDR2_REG;
    always@(posedge CLK)begin
        if(WE2) mem[ADDR2] <= WD2;
        ADDR2_REG <= ADDR2;
    end
    assign RD2 = mem[ADDR2_REG];

    initial begin
        #1000;
        i=0;
        $display("========%0t [3PortMem] Mem DBG =========",$time);
        for(i = 0; i< 256; i++)begin
            $display("%0d", mem[i]);
        end
    end 
endmodule