module controller (
    input logic [6:0] op,               // 7-bit opcode from inst
    input logic [2:0] funct3,           // 3-bit funct3 from inst
    input logic funct7b5,               // 1-bit funct7b5 from inst

    output logic RegWrite,              // High if regfile is written
    output logic [2:0] ImmSrc,          // Immediate format
    output logic ALUSrc,                // 0=Reg 1=Imm
    output logic MemWrite,              // High if memory is written
    output logic [1:0] ResultSrc,       // 00 = ALU, 01 = RAM, 10 = PC+4
    output logic Branch,                // High if the inst is branch
    output logic [1:0] Jump,            // 00 = No jump, 01 = JAL, 10 = JALR
    output logic [3:0] ALUControl       // Final 4-bit ALU control signal
);

    logic [1:0] ALUOp;

    maindec md(
        .op(op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    aludec ad(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

endmodule