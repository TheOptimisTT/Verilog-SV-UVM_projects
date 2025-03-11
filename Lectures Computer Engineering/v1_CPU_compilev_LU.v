module lu_processor (
                        input clk,
                        input rst,
                        input [7:0] ICODE
                    );
    //==============================================
    //=============== STAGE 0 ======================
    //==============================================
    reg [7:0] S0_ADDR;

    reg [7:0] S1_ADDR;
    reg [7:0] S0_ADDR_MEM;
    reg [15:0] S4_WB_BYPASS_REGISTER;
    wire [15:0] RD_MEM_OUT;
    reg [15:0] S3_RESULT_REGISTER;
    reg S1_BYPASS_REG_CNTRL;
    wire [15:0] S3_S2S3DF_MUX;
    reg [15:0] S1_WB_BYPASS_RESULT;
    wire [15:0] S2_S0S3DF_MUX;
    wire [15:0] S2_S1S3DF_MUX;
    reg [7:0] S2_ADDR;
    reg [15:0] S2_MEM_OUT_REGISTER;
    reg [7:0] S3_ADDR;


    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S0_ADDR <=8'b0;
            S0_ADDR_MEM <= 8'b0;
        end
        else begin
            S0_ADDR <= ICODE;
            S0_ADDR_MEM <= ICODE;
        end
    end
    //==============================================
    //=============== STAGE 1 ======================
    //==============================================
     always@(posedge clk or posedge rst)begin
        if(rst)begin
            S1_ADDR <=8'b0;
        end
        else begin
            S1_ADDR <= S0_ADDR;
        end
    end

    //Bypass register Control
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S1_BYPASS_REG_CNTRL <= 1'b0;
        end
        else if(S0_ADDR == S3_ADDR)begin
            S1_BYPASS_REG_CNTRL <= 1'b1;
        end
        else begin
            S1_BYPASS_REG_CNTRL <= S1_BYPASS_REG_CNTRL;
        end
    end

    //Dual port memory instantion
    syncMEM2P SyncMEM2P_instance1(
        //Port 0
        .ADDR0(S0_ADDR_MEM),
        .WD0(16'b0),
        .WE0(1'b0),
        .RD0(RD_MEM_OUT),

        //Port 1
        .ADDR1(S3_ADDR),
        .WD1(S3_RESULT_REGISTER),
        .WE1(1'b1),
        .RD1(),     //NO CONNECT

        //Common
        .CLK(clk)
    );
    //Write Back BYPASS REG
      always@(posedge clk or posedge rst)begin
        if(rst)begin
            S1_WB_BYPASS_RESULT <= 16'b0;
        end
        else begin
            S1_WB_BYPASS_RESULT <= S3_RESULT_REGISTER;
        end
    end
    //==============================================
    //=============== STAGE 2 ======================
    //==============================================
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S2_ADDR <= 8'b0;
        end
        else begin
            S2_ADDR <= S1_ADDR;
        end
    end

    //S0 - S3 data forwarding
    assign S2_S0S3DF_MUX = (S1_BYPASS_REG_CNTRL) ? S4_WB_BYPASS_REGISTER : RD_MEM_OUT;

    //S1 - S3 data forwarding
    assign S2_S1S3DF_MUX = (S1_ADDR == S3_ADDR) ? S3_RESULT_REGISTER : S2_S0S3DF_MUX;

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S2_MEM_OUT_REGISTER <= 16'b0;
        end
        else begin
            S2_MEM_OUT_REGISTER <= S2_S1S3DF_MUX;
        end
    end
    //==============================================
    //=============== STAGE 3 ======================
    //==============================================
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S3_ADDR <= 8'b0;
        end
        else begin
            S3_ADDR <= S2_ADDR;
        end
    end

    //S2 - S3 data forwarding
    assign S2_S2S3DF_MUX = (S2_ADDR == S3_ADDR) ? S3_RESULT_REGISTER : S2_MEM_OUT_REGISTER;

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S3_RESULT_REGISTER <= 16'b0;
        end
        else begin
            S3_RESULT_REGISTER <= S3_S2S3DF_MUX + 1'b1;
        end
    end
    //==============================================
    //=============== STAGE 4 ======================
    //==============================================
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S4_WB_BYPASS_REGISTER <= 1'b0;
        end
        else begin
            S4_WB_BYPASS_REGISTER <= S3_RESULT_REGISTER;
        end
    end
    //write back port is also S4 stage but instatiated in S1

endmodule

module syncMEM2P(
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
    
    initial begin
        #1000;
        i=0;
        for(i = 0; i< 256; i++)begin
            $display("%0d", mem[i]);
        end
    end 
endmodule