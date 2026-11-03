module maindec (
    input  logic [6:0] op,           // 7-bit instruction opcode
    output logic       RegWrite,     // Write to RegFile
    output logic [2:0] ImmSrc,       // Immediate format
    output logic [1:0] ALUSrcA,      // 00 = rs1, 01 = PC, 10 = 0
    output logic       ALUSrc,       // 0 = Reg, 1 = Imm
    output logic       MemWrite,     // Write to memory
    output logic [1:0] ResultSrc,    // 00 = ALU, 01 = Memory, 10 = PC+4
    output logic       Branch,       // High if instruction is branch
    output logic [1:0] Jump,         // 00 = None, 01 = JAL, 10 = JALR
    output logic [1:0] ALUOp         // 00 = ADD, 01 = SUB, 10 = Delegate to ALU Dec
);

    always_comb begin
        // Default all signals to zero
        RegWrite  = 1'b0;
        ImmSrc    = 3'b000;
        ALUSrcA   = 2'b00;
        ALUSrc    = 1'b0;
        MemWrite  = 1'b0;
        ResultSrc = 2'b00;
        Branch    = 1'b0;
        Jump      = 2'b00;
        ALUOp     = 2'b00;

        case(op)
            // R-Type instructions
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrcA  = 2'b00;    // Read from rs1
                ALUSrc   = 1'b0;     // Read from rs2
                ALUOp    = 2'b10;    // Tell ALU decoder to look at the inst bits
            end

            // I-Type ALU
            7'b0010011: begin
                RegWrite = 1'b1;
                ImmSrc   = 3'b000;   // I-Type immediate
                ALUSrcA  = 2'b00;    // Read from rs1
                ALUSrc   = 1'b1;     // Read from immediate
                ALUOp    = 2'b10;    // Tell ALU decoder to look at the inst bits
            end

            // Load instructions (LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                RegWrite  = 1'b1;    // Write result to register
                ImmSrc    = 3'b000;   // I-Type immediate
                ALUSrcA   = 2'b00;    // Base address from rs1
                ALUSrc    = 1'b1;     // Read from immediate
                ResultSrc = 2'b01;    // Final result comes from data memory
                ALUOp     = 2'b00;    // Force ALU to ADD (rs1 + offset)
            end

            // Store instructions (SB, SH, SW)
            7'b0100011: begin
                ImmSrc   = 3'b001;   // S-Type immediate
                ALUSrcA  = 2'b00;    // Base address from rs1
                ALUSrc   = 1'b1;     // Read from immediate
                MemWrite = 1'b1;     // Write to memory
                ALUOp    = 2'b00;    // Force ALU to ADD (rs1 + offset)
            end

            // Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            7'b1100011: begin
                ImmSrc  = 3'b010;    // B-Type immediate
                ALUSrcA = 2'b00;     // Read rs1
                ALUSrc  = 1'b0;      // Read rs2 to compare
                Branch  = 1'b1;      // Flag as branch instruction
                ALUOp   = 2'b01;     // SUB for comparison
            end

            // Jump and Link (JAL)
            7'b1101111: begin
                RegWrite  = 1'b1;    // Save return address
                ImmSrc    = 3'b100;  // J-Type immediate
                ResultSrc = 2'b10;   // Save PC+4 into the register
                Jump      = 2'b01;   // PC-relative jump
            end

            // Jump and Link Register (JALR)
            7'b1100111: begin
                RegWrite  = 1'b1;    // Save return address
                ImmSrc    = 3'b000;  // I-Type immediate
                ALUSrcA   = 2'b00;    // Read rs1
                ALUSrc    = 1'b1;    // Read from immediate
                ALUOp     = 2'b00;   // Force ALU to ADD (rs1 + offset)
                ResultSrc = 2'b10;   // Save PC+4 into the register
                Jump      = 2'b10;   // Register-relative jump
            end

            // Load Upper Immediate (LUI)
            7'b0110111: begin
                RegWrite  = 1'b1;    // Save result into register
                ImmSrc    = 3'b011;  // U-Type immediate
                ALUSrcA   = 2'b10;   // Force 0 for operand A
                ALUSrc    = 1'b1;    // Immediate for operand B
                ALUOp     = 2'b00;   // ADD (0 + imm_u = imm_u)
                ResultSrc = 2'b00;   // Result from ALU
            end

            // Add Upper Immediate to PC (AUIPC)
            7'b0010111: begin
                RegWrite  = 1'b1;    // Save result into register
                ImmSrc    = 3'b011;  // U-Type immediate
                ALUSrcA   = 2'b01;   // PC for operand A
                ALUSrc    = 1'b1;    // Immediate for operand B
                ALUOp     = 2'b00;   // ADD (pc + imm_u)
                ResultSrc = 2'b00;   // Result from ALU
            end

            // FENCE instruction (NOP in single-core in-order pipeline)
            7'b0001111: begin
                // All control lines default to 0 (NOP)
            end

            default: ;
        endcase
    end
endmodule
