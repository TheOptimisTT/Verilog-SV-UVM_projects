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
    `define TEMP0   3'b101
    `define TEMP1   3'b110
    `define NOP     3'b111

    always(*)begin
        case (CMD_IN):
            `INC:       ALU_OUT = ALU_IN + 1'b1;
            `DEC:       ALU_OUT = ALU_IN - 1'b1;
            `INV:       ALU_OUT = ~ALU_IN;
            `REDAND:    ALU_OUT = &ALU_IN;
            `REDOR:     ALU_OUT = |ALU_IN;
            `NOP:       ALU_OUT = ALU_IN; // No Operation aka buffer
            default:    ALU_OUT = ALU_IN; // Nop Buffer
        endcase
    end
endmodule