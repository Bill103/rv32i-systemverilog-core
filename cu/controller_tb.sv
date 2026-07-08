`timescale 1ns / 1ps

module tb_controller;

    // 1. Declare signals
    logic [6:0] op;
    logic [2:0] funct3;
    logic funct7b5;

    logic RegWrite;
    logic [2:0] ImmSrc;
    logic ALUSrc;
    logic MemWrite;
    logic [1:0] ResultSrc;
    logic Branch;
    logic [1:0] Jump;
    logic [3:0] ALUControl;

    // 2. Instantiate the Controller
    controller uut (
        .op(op),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUControl(ALUControl)
    );

    // 3. Test Sequence
    initial begin
        $dumpfile("controller.vcd");
        $dumpvars(0, tb_controller);

        $display("Starting Control Unit tests...");

        // Test 1: R-Type ADD
        // Opcode: 0110011, funct3: 000, bit30: 0
        // Expected: RegWrite=1, ALUSrc=0, ALUControl=0000 (ADD)
        op = 7'b0110011; funct3 = 3'b000; funct7b5 = 1'b0;
        #10;

        // Test 2: R-Type SUB
        // Opcode: 0110011, funct3: 000, bit30: 1
        // Expected: RegWrite=1, ALUSrc=0, ALUControl=0001 (SUB)
        op = 7'b0110011; funct3 = 3'b000; funct7b5 = 1'b1;
        #10;

        // Test 3: Load Word (LW)
        // Opcode: 0000011, funct3: 010, bit30: X (doesn't matter)
        // Expected: RegWrite=1, ALUSrc=1 (Imm), ResultSrc=01 (RAM), ALUControl=0000 (ADD)
        op = 7'b0000011; funct3 = 3'b010; funct7b5 = 1'b0;
        #10;

        // Test 4: Branch if Equal (BEQ)
        // Opcode: 1100011, funct3: 000, bit30: X
        // Expected: Branch=1, ALUSrc=0 (Reg), ALUControl=0001 (SUB)
        op = 7'b1100011; funct3 = 3'b000; funct7b5 = 1'b0;
        #10;

        $display("Control Unit Simulation Complete!");
        $finish;
    end

endmodule