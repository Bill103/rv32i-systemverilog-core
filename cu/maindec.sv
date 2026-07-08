module maindec (
    input logic [6:0] op,           // 7-bit instruction opcode
    output logic RegWrite,          // Write to RegFile
    output logic [2:0] ImmSrc,      // Immediate format
    output logic ALUSrc,            // 0 = Reg, 1 = Imm
    output logic MemWrite,          // Write to memory
    output logic [1:0] ResultSrc,   // 00 = ALU, 01 = Memory, 10 = PC+4
    output logic Branch,            // High if instruction is branch
    output logic [1:0] Jump,        // 00 = None, 01 = JAL, 10 = JALR
    output logic [1:0] ALUOp        // 00 = ADD, 01 = SUB, 10 = Delegate to ALU Dec
);

    always_comb begin
        // Default all signals to zero
        RegWrite = 1'b0;
        ImmSrc = 3'b000;
        ALUSrc = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        ALUOp = 2'b00;

        case(op)
            // R-Type instructions
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b0;      // Read from rs2
                ALUOp = 2'b10;      // Tell ALU decoder to look at the inst bits
            end
            // I-Type ALU
            7'b0010011: begin
                RegWrite = 1'b1;
                ImmSrc = 3'b000;    // I-Type immediate
                ALUSrc = 1'b1;      // Read from immediate
                ALUOp = 2'b10;      // Tell ALU decoder to look at the inst bits
            end

            // Load instructions
            7'b0000011: begin
                RegWrite = 1'b1;    // Write result to register
                ImmSrc = 3'b000;    // I-Type immediate
                ALUSrc = 1'b1;      // Read from immediate
                ResultSrc = 2'b01;  // Final result comes from data memory
                ALUOp = 2'b00;      // Force ALU to ADD
            end

            // Store instructions
            7'b0100011: begin
                ImmSrc = 3'b001;    // S-Type immediate
                ALUSrc = 1'b1;      // Read from immediate
                MemWrite = 1'b1;    // Write to memory
                ALUOp = 2'b00;      // Force ALU to Add
            end

            // Branch
            7'b1100011: begin
                ImmSrc = 3'b010;    // B-Type immediate
                ALUSrc = 1'b0;      // Read rs2 to compare
                Branch = 1'b1;      // Flag as branch instruction
                ALUOp = 2'b01;      // Force SUB for comparison
            end

            // Jump and Link (JAL)
            7'b1101111: begin
                RegWrite = 1'b1;    // Save return address
                ImmSrc = 3'b100;    // J-Type immediate
                ResultSrc = 2'b10;  // Save PC+4 into the register
                Jump = 2'b01;       // PC-relative jump
            end

            // Jump and Link Register (JALR)
            7'b1100111: begin
                RegWrite = 1'b1;    // Save return address
                ImmSrc = 3'b000;    // I-Type immediate
                ALUSrc = 1'b1;      // Read from immediate
                ALUOp = 2'b00;      // Force ALU to ADD
                ResultSrc = 2'b10;  // Save PC+4 into the register
                Jump = 2'b10;       // Register-relave jump
            end

            default: ;
        endcase
    end
endmodule