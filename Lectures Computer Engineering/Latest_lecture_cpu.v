module lu_processor#(parameter INTSR_SIZE = 27, parameter DATA_SIZE = 16) (
                        input clk,
                        input rst,
                        input VLD,
                        input [INTSR_SIZE-1:0] INSTR_WORD,
                        output LSVLD, 
                        output LREQ,
                        output SREQ,
                        output [...] LSADDR, //FIXME
                        output [...] SDATA, //FIXME
                        input [...] LDATA, //FIXME
                        input [...] LDRDY
                    );
    //==============================================
    //=============== STAGE 0 ======================
    //==============================================
    reg     [7:0] S0_ADDR0;         // GOES TO PIPELINE
    reg     [7:0] S0_ADDR1_MEM;     // GOES TO MEM
    reg     [7:0] S0_ADDR1;         // GOES TO PIPELINE
    reg     [7:0] S0_ADDR0_MEM;     // GOES TO MEM
    
    reg     [7:0] S0_RESULT_ADDR;
    reg     [7:0] S1_RESULT_ADDR;
    reg     [7:0] S2_RESULT_ADDR;
    reg     [7:0] S3_RESULT_ADDR;

    reg     [7:0]               S1_ADDR0;
    reg     [7:0]               S1_ADDR1;
    reg     [7:0]               S0_ADDR_MEM;
    reg     [DATA_SIZE - 1:0]   S4_WB_BYPASS_REGISTER;
    wire    [DATA_SIZE - 1:0]   RD_MEM0_OUT;
    wire    [DATA_SIZE - 1:0]   RD_MEM1_OUT;
    reg     [DATA_SIZE - 1:0]   S3_RESULT_REGISTER;
    reg                         S1_BYPASS_REG_CNTRL;
    wire    [DATA_SIZE - 1:0]   S3_S2S3DF_MUX;
    reg     [DATA_SIZE - 1:0]   S1_WB_BYPASS_RESULT;
    wire    [DATA_SIZE - 1:0]   S2_S0S3DF_MUX0;
    wire    [DATA_SIZE - 1:0]   S2_S0S3DF_MUX1;
    wire    [DATA_SIZE - 1:0]   S2_S1S3DF_MUX0;
    wire    [DATA_SIZE - 1:0]   S2_S1S3DF_MUX1;
    reg     [7:0]               S2_ADDR0;
    reg     [7:0]               S2_ADDR1;
    reg     [DATA_SIZE - 1:0]   S2_MEM0_OUT_REGISTER;
    reg     [DATA_SIZE - 1:0]   S2_MEM1_OUT_REGISTER;
    reg     [7:0]               S3_ADDR0;
    reg     [7:0]               S3_ADDR1;

    reg S0_VLD, S1_VLD, S2_VLD, S3_VLD; // Valid signal
    reg S0_CMD_ID, S1_CMD_ID, S2_CMD_ID; // if reset prob should be full rail aka 111
    wire [DATA_SIZE-1:0] S3_ALU_OUTPUT;

    //Extracting command fields
    wire [2:0] CMD_ID;
    wire [7:0] OPRND0_ADDR;
    wire [7:0] OPRND1_ADDR;
    wire [7:0] RESULT_ADDR;

    assign CMD_ID        = INSTR_WORD   [26:24];
    assign RESULT_ADDR   = INSTR_WORD   [23:16];
    assign OPRND0_ADDR   = INSTR_WORD   [7:0];
    assign OPRND1_ADDR   = INSTR_WORD   [15:8];


    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S0_ADDR0        <= 8'b0;
            S0_ADDR0_MEM    <= 8'b0;
            S0_ADDR1_MEM    <= 8'b0;
            S0_ADDR1        <= 8'b0;
            S0_RESULT_ADDR  <= 8'b0;
            S0_ADDR_MEM     <= 8'b0;
            S0_VLD          <= 1'b0;
            S0_CMD_ID       <= 3'b111;
        end
        else begin
            S0_ADDR0        <= OPRND0_ADDR;
            S0_ADDR0_MEM    <= OPRND0_ADDR;
            S0_ADDR1        <= OPRND1_ADDR;
            S0_ADDR1_MEM    <= OPRND1_ADDR;
            S0_RESULT_ADDR  <= RESULT_ADDR;
            S0_VLD          <= VLD;
            S0_CMD_ID       <= CMD_ID;
        end
    end
    //==============================================
    //=============== STAGE 1 ======================
    //==============================================
     always@(posedge clk or posedge rst)begin
        if(rst)begin
            S1_ADDR0 <= 8'b0;
            S1_ADDR1 <= 8'b0;
            S1_RESULT_ADDR <= 8'b0;

            S1_VLD <= 1'b0;
            S1_CMD_ID <= 3'b111;
        end
        else begin
            S1_ADDR0 <= S0_ADDR0;
            S1_ADDR1 <= S0_ADDR1;
            S1_RESULT_ADDR <= S0_RESULT_ADDR;

            S1_VLD <= S0_VLD
            S1_CMD_ID <= S0_CMD_ID;
        end
    end

    //Bypass register Control 0
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S1_BYPASS_REG0_CNTRL <= 1'b0;
        end
        else if(S0_ADDR0 == S3_RESULT_ADDR)begin
            S1_BYPASS_REG0_CNTRL <= 1'b1;
        end
        else begin
            S1_BYPASS_REG0_CNTRL <= 1'b0;
        end
    end
    //Bypass register Control 0
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S1_BYPASS_REG1_CNTRL <= 1'b0;
        end
        else if(S0_ADDR1 == S3_RESULT_ADDR)begin
            S1_BYPASS_REG1_CNTRL <= 1'b1;
        end
        else begin
            S1_BYPASS_REG1_CNTRL <= 1'b0;
        end
    end

    //Dual port memory instantion
    //syncMEM2P SyncMEM2P_instance1(
    syncMEM3P SyncMEM3P_instance1(      //Register FILE
        //Port 0
        .ADDR0(S0_ADDR0_MEM),
        .WD0(16'b0),
        .WE0(1'b0),
        .RD0(RD_MEM0_OUT),

        //Port 1
        .ADDR1(S3_RESULT_ADDR),
        .WD1(S3_RESULT_REGISTER),
        .WE1(S3_VLD),
        .RD1(),     //NO CONNECT

        //Port 2
        .ADDR2(S0_ADDR1_MEM),
        .WD2(16'b0),
        .WE2(1'b0),
        .RD2(RD_MEM1_OUT),

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
            S2_ADDR0        <= 8'b0;
            S2_ADDR1        <= 8'b0;
            S2_RESULT_ADDR  <= 8'b0;
            S2_VLD          <= 1'b0;
            S2_CMD_ID       <= 3'b111;
        end
        else begin
            S2_ADDR0        <= S1_ADDR0;
            S2_ADDR1        <= S1_ADDR1;
            S2_RESULT_ADDR  <= S1_RESULT_ADDR;
            S2_VLD          <= S1_VLD;
            S2_CMD_ID       <= S1_CMD_ID;
        end
    end

    //S0 - S3 data forwarding
    assign S2_S0S3DF_MUX0 = (S1_BYPASS_REG0_CNTRL) ? S4_WB_BYPASS_REGISTER : RD_MEM0_OUT;           //OP0
    assign S2_S0S3DF_MUX1 = (S1_BYPASS_REG1_CNTRL) ? S4_WB_BYPASS_REGISTER : RD_MEM1_OUT;           //OP1

    //S1 - S3 data forwarding
    assign S2_S1S3DF_MUX0 = (S1_ADDR0 == S3_RESULT_ADDR) ? S3_RESULT_REGISTER : S2_S0S3DF_MUX0;     //OP0
    assign S2_S1S3DF_MUX1 = (S1_ADDR1 == S3_RESULT_ADDR) ? S3_RESULT_REGISTER : S2_S0S3DF_MUX1;     //OP1

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S2_MEM0_OUT_REGISTER <= 16'b0;
            S2_MEM1_OUT_REGISTER <= 16'b0;
        end
        else begin
            S2_MEM0_OUT_REGISTER <= S2_S1S3DF_MUX0;
            S2_MEM1_OUT_REGISTER <= S2_S1S3DF_MUX1;
        end
    end
    //==============================================
    //=============== STAGE 3 ======================
    //==============================================
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S3_ADDR0        <= 8'b0;
            S3_ADDR1        <= 8'b0;
            S3_RESULT_ADDR  <= 8'b0;
            S3_VLD          <= 1'b0;
        end
        else begin
            S3_ADDR0        <= S2_ADDR0;
            S3_ADDR1        <= S2_ADDR1;
            S3_RESULT_ADDR  <= S2_RESULT_ADDR;
            S3_VLD          <= S2_VLD;
        end
    end

    //S2 - S3 data forwarding
    assign S3_S2S3DF_MUX0 = (S2_ADDR0 == S3_RESULT_ADDR) ? S3_RESULT_REGISTER : S2_MEM0_OUT_REGISTER;
    assign S3_S2S3DF_MUX1 = (S2_ADDR1 == S3_RESULT_ADDR) ? S3_RESULT_REGISTER : S2_MEM1_OUT_REGISTER;

   ALU ALU_instance1(
                .ALU_IN0(S3_S2S3DF_MUX0),
                .ALU_IN1(S3_S2S3DF_MUX1),
                .ALU_OUT(S3_RESULT_REGISTER),
                .CMD_IN (S3_ALU_OUTPUT)
            );

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            S3_RESULT_REGISTER <= 16'b0;
        end
        else begin
            S3_RESULT_REGISTER <= S3_ALU_OUTPUT;
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

