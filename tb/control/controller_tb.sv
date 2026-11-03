`timescale 1ns / 1ps

module tb_controller;

    // 1. Declare signals
    logic [6:0] op;
    logic [2:0] funct3;
    logic funct7b5;

    logic RegWrite;
    logic [2:0] ImmSrc;
    logic [1:0] ALUSrcA;
    logic ALUSrc;
    logic MemWrite;
    logic [1:0] ResultSrc;
    logic Branch;
    logic [1:0] Jump;
    logic [3:0] ALUControl;

    // 2. Instantiate the Controller
    controller uut (
        .op         (op),
        .funct3     (funct3),
        .funct7b5   (funct7b5),
        .RegWrite   (RegWrite),
        .ImmSrc     (ImmSrc),
        .ALUSrcA    (ALUSrcA),
        .ALUSrc     (ALUSrc),
        .MemWrite   (MemWrite),
        .ResultSrc  (ResultSrc),
        .Branch     (Branch),
        .Jump       (Jump),
        .ALUControl (ALUControl)
    );

    task automatic check_controls(
        input logic expected_reg_write,
        input logic [2:0] expected_imm_src,
        input logic [1:0] expected_alu_src_a,
        input logic expected_alu_src,
        input logic expected_mem_write,
        input logic [1:0] expected_result_src,
        input logic expected_branch,
        input logic [1:0] expected_jump,
        input logic [3:0] expected_alu_control,
        input string test_name
    );
        if (RegWrite !== expected_reg_write || ImmSrc !== expected_imm_src ||
            ALUSrcA !== expected_alu_src_a ||
            ALUSrc !== expected_alu_src || MemWrite !== expected_mem_write ||
            ResultSrc !== expected_result_src || Branch !== expected_branch ||
            Jump !== expected_jump || ALUControl !== expected_alu_control) begin
            $fatal(1, "%s: unexpected control outputs", test_name);
        end
    endtask

    // 3. Test Sequence
    initial begin
        $dumpfile("controller.vcd");
        $dumpvars(0, tb_controller);

        $display("Starting Control Unit tests...");

        // Test 1: R-Type ADD
        op = 7'b0110011; funct3 = 3'b000; funct7b5 = 1'b0;
        #10;
        check_controls(1'b1, 3'b000, 2'b00, 1'b0, 1'b0, 2'b00, 1'b0, 2'b00, 4'b0000, "R-type ADD");

        // Test 2: R-Type SUB
        op = 7'b0110011; funct3 = 3'b000; funct7b5 = 1'b1;
        #10;
        check_controls(1'b1, 3'b000, 2'b00, 1'b0, 1'b0, 2'b00, 1'b0, 2'b00, 4'b0001, "R-type SUB");

        // Test 3: Load Word (LW)
        op = 7'b0000011; funct3 = 3'b010; funct7b5 = 1'b0;
        #10;
        check_controls(1'b1, 3'b000, 2'b00, 1'b1, 1'b0, 2'b01, 1'b0, 2'b00, 4'b0000, "LW");

        // Test 4: Branch (BEQ)
        op = 7'b1100011; funct3 = 3'b000; funct7b5 = 1'b0;
        #10;
        check_controls(1'b0, 3'b010, 2'b00, 1'b0, 1'b0, 2'b00, 1'b1, 2'b00, 4'b0001, "BEQ");

        // Test 5: LUI
        op = 7'b0110111; funct3 = 3'b000; funct7b5 = 1'b0;
        #10;
        check_controls(1'b1, 3'b011, 2'b10, 1'b1, 1'b0, 2'b00, 1'b0, 2'b00, 4'b0000, "LUI");

        // Test 6: AUIPC
        op = 7'b0010111; funct3 = 3'b000; funct7b5 = 1'b0;
        #10;
        check_controls(1'b1, 3'b011, 2'b01, 1'b1, 1'b0, 2'b00, 1'b0, 2'b00, 4'b0000, "AUIPC");

        $display("Control Unit Simulation Complete!");
        $finish;
    end

endmodule
