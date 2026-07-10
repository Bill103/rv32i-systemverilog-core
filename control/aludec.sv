module aludec(
    input logic opb5,               // bit 5 of inst opcode
    input logic [2:0] funct3,       // inst[14:12]
    input logic funct7b5,           // inst[30]
    input logic [1:0] ALUOp,        // 2-bit hint from main decoder

    output logic [3:0] ALUControl   // Final ALU control signal
);

    logic RtypeSub;
    // We only want to subtract if it's an R-Type instruction and bit 30 is high
    assign RtypeSub = funct7b5 & opb5;

    always_comb begin
        case(ALUOp)
            2'b00: ALUControl = 4'b0000; // Load/Store -> Force ADD
            
            2'b01: ALUControl = 4'b0001; // Branch -> Force SUB for comparison

            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if(RtypeSub)
                            ALUControl = 4'b0001;   // SUB
                        else
                            ALUControl = 4'b0000;   // ADD or ADDI
                    end
                    3'b001: ALUControl = 4'b0010;   // SLL, SLLI
                    3'b010: ALUControl = 4'b0011;   // SLT, SLTI
                    3'b011: ALUControl = 4'b0100;   // SLTU, SLTIU
                    3'b100: ALUControl = 4'b0101;   // XOR, XORI
                    3'b101: begin
                        if (funct7b5)
                            ALUControl = 4'b0111;   // SRA, SRAI
                        else
                            ALUControl = 4'b0110;   // SRL, SRLI
                    end
                    3'b110: ALUControl = 4'b1000;   // OR, ORI
                    3'b111: ALUControl = 4'b1001;   // AND, ANDI
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule

