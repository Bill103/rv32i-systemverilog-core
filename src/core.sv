module core(
    input logic clk,
    input logic rst
);
    // 1. Internal Wires

    // Fetch Stage Wires
    logic [31:0] pc_reg, pc_next, pc_plus_4, pc_target;
    logic [31:0] inst;

    // Decode/Control Wires
    logic RegWrite, ALUSrc, MemWrite, Branch;
    logic [1:0] ResultSrc, Jump;
    logic [2:0] ImmSrc;
    logic [3:0] ALUControl;
    logic [31:0] imm_ext;

    // Execute Stage Wires
    logic [31:0] rd1, rd2, srcB;
    logic [31:0] alu_result;
    logic zero;

    // Memory / Writeback Wires
    logic [31:0] read_data, result;
    logic take_branch;

    // 2. Fetch Stage

    // Program Counter
    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .next_pc(pc_next),
        .pc(pc_reg)
    );

    // Default next instruction
    assign pc_plus_4 = pc_reg + 32'd4;

    // Branch adder
    assign pc_target = pc_reg + imm_ext;

    // Instruction Memory (ROM)
    imem imem_inst(
        .a(pc_reg),
        .rd(inst)
    );

    // 3. Decode Stage

    // Control Unit
    controller ctrl_inst(
        .op(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7b5(inst[30]),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUControl(ALUControl)
    );

    // Register File
    regfile rf_inst(
        .clk(clk),
        .we(RegWrite),
        .rs1(inst[19:15]),
        .rs2(inst[24:20]),
        .rd(inst[11:7]),
        .wd(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Immediate Generator
    immgen immgen_inst(
        .inst(inst),
        .imm_src(ImmSrc),
        .imm(imm_ext)
    );

    // 4. Execute Stage

    // ALU Source Multiplexer
    assign srcB = ALUSrc ? imm_ext : rd2;

    alu alu_inst(
        .a(rd1),
        .b(srcB),
        .alu_control(ALUControl),
        .result(alu_result)
    );

    // Zero flag
    assign zero = (alu_result == 32'b0);

    // 5. Memory Stage

    // Data Memory
    dmem dmem_inst(
        .clk(clk),
        .we(MemWrite),
        .a(alu_result),
        .wd(rd2),
        .rd(read_data)
    );

    // 6. Writeback and PC next logic

    // Final Result Multiplexer
    always_comb begin
        case (ResultSrc)
            2'b00: result = alu_result;
            2'b01: result = read_data;
            2'b10: result = pc_plus_4;
            default: result = 32'b0;
        endcase
    end

    // PC Next Multiplexer
    assign take_branch = Branch & zero;

    always_comb begin
        if (Jump == 2'b10) begin
            // JALR: Target is calculated by the ALU and the LSB is always 0
            pc_next = alu_result & 32'hFFFFFFFE;
        end
        else if ((Jump == 2'b01) || take_branch) begin
            pc_next = pc_target;
        end
        else begin
            pc_next = pc_plus_4;
        end
    end

endmodule
