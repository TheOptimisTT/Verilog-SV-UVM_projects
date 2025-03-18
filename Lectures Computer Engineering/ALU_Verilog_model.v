module ALU  (
                input   [15:0] ALU_IN0,
                input   [15:0] ALU_IN1,
                input   [15:0] ALU_OUT,
                output  [2:0]  CMD_IN
            );
    `define INC     3'b000
    `define DEC     3'b001
    `define INV     3'b010
    `define REDAND  3'b011
    `define REDOR   3'b100
    `define ADD     3'b101
    `define SUB     3'b110
    `define NOP     3'b111

    always(*)begin
        case (CMD_IN):
            `INC:       ALU_OUT = ALU_IN0 + 1'b1;
            `DEC:       ALU_OUT = ALU_IN0 - 1'b1;
            `INV:       ALU_OUT = ~ ALU_IN0;
            `REDAND:    ALU_OUT = & ALU_IN0;
            `REDOR:     ALU_OUT = | ALU_IN0;
            `ADD:       ALU_OUT = ALU_IN0 + ALU_IN1;
            `SUB:       ALU_OUT = ALU_IN0 - ALU_IN1; // No Operation aka buffer
            `NOP:       ALU_OUT = ALU_IN0;
        endcase
    end
endmodule