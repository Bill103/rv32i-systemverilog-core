module core(
    input logic clk,
    input logic rst
);

    // =========================================
    // 1. PIPELINE REGISTERS DEFINITIONS
    // =========================================
    
    // Control Bundles
    typedef struct packed {
        logic RegWrite;
        logic [1:0] ResultSrc;
        logic MemWrite;
        logic Branch;
        logic [1:0] Jump;
        logic [3:0] ALUControl;
        logic ALUSrc;
    } ctrl_ex_t;

    typedef struct packed {
        logic RegWrite;
        logic [1:0] ResultSrc;
        logic MemWrite;
        logic Branch;
        logic [1:0] Jump;
    } ctrl_mem_t;

    typedef struct packed {
        logic RegWrite;
        logic [1:0] ResultSrc;
    } ctrl_wb_t;

    typedef struct packed {
        logic [31:0] pc;
        logic [31:0] pc_plus_4;
        logic [31:0] inst;
    } if_id_reg_t;

    typedef struct packed {
        ctrl_ex_t ctrl;
        logic [31:0] pc;
        logic [31:0] pc_plus_4;
        logic [31:0] rd1;
        logic [31:0] rd2;
        logic [31:0] imm_ext;
        logic [4:0] rs1;
        logic [4:0] rs2;
        logic [4:0] rd;
    } id_ex_reg_t;

    typedef struct packed {
        ctrl_mem_t ctrl;
        logic [31:0] pc_target;
        logic [31:0] pc_plus_4;
        logic [31:0] alu_result;
        logic [31:0] write_data;
        logic [4:0] rd;
        logic zero;
    } ex_mem_reg_t;

    typedef struct packed {
        ctrl_wb_t ctrl;
        logic [31:0] alu_result;
        logic [31:0] read_data;
        logic [31:0] pc_plus_4;
        logic [4:0] rd;
    } mem_wb_reg_t;

    // ===================================================
    // 2. Pipeline Register Declarations & Control Signals
    // ===================================================

    if_id_reg_t if_id_in, if_id_q;
    id_ex_reg_t id_ex_in, id_ex_q;
    ex_mem_reg_t ex_mem_in, ex_mem_q;
    mem_wb_reg_t mem_wb_in, mem_wb_q;

    logic stall_F, stall_D;
    logic flush_D, flush_E;
    logic [1:0] forward_a_E, forward_b_E;
    logic pc_src_E;

    // ===================================================
    // 3. FETCH STAGE (IF)
    // ===================================================
    logic [31:0] pc_current, pc_next, pc_target_or_plus_4, pc_plus_4_F;
    logic [31:0] inst_F;
    logic [31:0] pc_target_E;

    // PC Next selection
    assign pc_plus_4_F = pc_current + 32'd4;
    assign pc_target_or_plus_4 = pc_src_E ? pc_target_E : pc_plus_4_F;
    assign pc_next = stall_F ? pc_current : pc_target_or_plus_4;

    pc pc_inst(
        .clk (clk),
        .rst (rst),
        .next_pc (pc_next),
        .pc (pc_current)
    );

    imem imem_inst(
        .a (pc_current),
        .rd (inst_F)
    );

    // IF/ID Pipeline Register Pack
    assign if_id_in.pc = pc_current;
    assign if_id_in.pc_plus_4 = pc_plus_4_F;
    assign if_id_in.inst = inst_F;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            if_id_q <= '0;
        end else if (flush_D) begin
        // NOP
        if_id_q.pc <= '0;
        if_id_q.pc_plus_4 <= '0;
        if_id_q.inst <= 32'h0000_0013;
        end else if(!stall_D) begin
        if_id_q <= if_id_in;
        end
    end

    // ===================================================
    // 4. DECODE STAGE (ID)
    // ===================================================
    logic [31:0] rd1_D, rd2_D, imm_ext_D;
    ctrl_ex_t ctrl_D;
    logic [2:0] ImmSrc_D;
    logic [31:0] result_W; //Driven from WB stage

    controller ctrl_inst (
        .op         (if_id_q.inst[6:0]),
        .funct3     (if_id_q.inst[14:12]),
        .funct7b5   (if_id_q.inst[30]),
        .RegWrite   (ctrl_D.RegWrite),
        .ImmSrc     (ImmSrc_D),
        .ALUSrc     (ctrl_D.ALUSrc),
        .MemWrite   (ctrl_D.MemWrite),
        .ResultSrc  (ctrl_D.ResultSrc),
        .Branch     (ctrl_D.Branch),
        .Jump       (ctrl_D.Jump),
        .ALUControl (ctrl_D.ALUControl)
    );

    regfile rf_inst (
        .clk (clk),
        .we (mem_wb_q.ctrl.RegWrite),
        .rs1 (if_id_q.inst[19:15]),
        .rs2 (if_id_q.inst[24:20]),
        .rd (mem_wb_q.rd),
        .wd (result_W),
        .rd1 (rd1_D),
        .rd2 (rd2_D)
    );

    immgen immgen_inst (
        .inst (if_id_q.inst),
        .imm_src (ImmSrc_D),
        .imm (imm_ext_D)
    );

    // ID/EX Pipeline Register Pack
    assign id_ex_in.ctrl = ctrl_D;
    assign id_ex_in.pc = if_id_q.pc;
    assign id_ex_in.pc_plus_4 = if_id_q.pc_plus_4;
    assign id_ex_in.rd1 = rd1_D;
    assign id_ex_in.rd2 = rd2_D;
    assign id_ex_in.imm_ext = imm_ext_D;
    assign id_ex_in.rs1 = if_id_q.inst[19:15];
    assign id_ex_in.rs2 = if_id_q.inst[24:20];
    assign id_ex_in.rd = if_id_q.inst[11:7];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            id_ex_q <= '0;
        end else if (flush_E) begin
            id_ex_q <= '0;
        end else begin
            id_ex_q <= id_ex_in;
        end
    end

    // ===================================================
    // 5. EXECUTE STAGE (EX)
    // ===================================================
    logic [31:0] srcA_E, srcB_forwarded_E, srcB_E, alu_result_E;
    logic zero_E, take_branch_E;

    // Forwarding MUX for ALU srcA
    always_comb begin
        case (forward_a_E)
            2'b10: srcA_E = ex_mem_q.alu_result;
            2'b01: srcA_E = result_W;
            default: srcA_E = id_ex_q.rd1;
        endcase
    end

    // Forwardig MUX for ALU srcB / store data
    always_comb begin
        case (forward_b_E)
            2'b10:  srcB_forwarded_E = ex_mem_q.alu_result;
            2'b01:  srcB_forwarded_E = result_W;
            default: srcB_forwarded_E = id_ex_q.rd2;
        endcase
    end

    // Immediate vs Register source select
    assign srcB_E = id_ex_q.ctrl.ALUSrc ? id_ex_q.imm_ext : srcB_forwarded_E;
    
    alu alu_inst (
        .a (srcA_E),
        .b (srcB_E),
        .alu_control(id_ex_q.ctrl.ALUControl),
        .result (alu_result_E)
    );

    assign zero_E = (alu_result_E == 32'b0);

    //Branch / Jump Resolution
    assign take_branch_E = id_ex_q.ctrl.Branch & zero_E;
    assign pc_src_E = (id_ex_q.ctrl.Jump != 2'b00) || take_branch_E;

    always_comb begin
        if (id_ex_q.ctrl.Jump == 2'b10) begin
            // JALR: Target from ALU (rs1 + imm), clear LSB
            pc_target_E = alu_result_E & 32'hFFFF_FFFE;
        end else begin
            // Branch or JAL: Target from PC + Imm
            pc_target_E = id_ex_q.pc + id_ex_q.imm_ext;
        end
    end

    // EX/MEM Pipeline Register Pack
    assign ex_mem_in.ctrl.RegWrite = id_ex_q.ctrl.RegWrite;
    assign ex_mem_in.ctrl.ResultSrc = id_ex_q.ctrl.ResultSrc;
    assign ex_mem_in.ctrl.MemWrite = id_ex_q.ctrl.MemWrite;
    assign ex_mem_in.alu_result = alu_result_E;
    assign ex_mem_in.write_data = srcB_forwarded_E;
    assign ex_mem_in.pc_plus_4 = id_ex_q.pc_plus_4;
    assign ex_mem_in.rd = id_ex_q.rd;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_mem_q <= '0;
        end else begin
            ex_mem_q <= ex_mem_in;
        end
    end

    //====================================================
    // 6. MEMORY STAGE (MEM)
    // ===================================================
    logic [31:0] read_data_M;

    dmem dmem_inst (
        .clk (clk),
        .we (ex_mem_q.ctrl.MemWrite),
        .a (ex_mem_q.alu_result),
        .wd (ex_mem_q.write_data),
        .rd (read_data_M)
    );

    // MEM/WB Pipeline Register Pack
    assign mem_wb_in.ctrl.RegWrite = ex_mem_q.ctrl.RegWrite;
    assign mem_wb_in.ctrl.ResultSrc = ex_mem_q.ctrl.ResultSrc;
    assign mem_wb_in.alu_result = ex_mem_q.alu_result;
    assign mem_wb_in.read_data = read_data_M;
    assign mem_wb_in.pc_plus_4 = ex_mem_q.pc_plus_4;
    assign mem_wb_in.rd = ex_mem_q.rd;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_wb_q <= '0;
        end else begin
            mem_wb_q <= mem_wb_in;
        end
    end

    // ===================================================
    // 7. WRITEBACK STAGE (WB)
    // ===================================================
    always_comb begin
        case (mem_wb_q.ctrl.ResultSrc)
            2'b00: result_W = mem_wb_q.alu_result;
            2'b01: result_W = mem_wb_q.read_data;
            2'b10: result_W = mem_wb_q.pc_plus_4;
            default: result_W = 32'b0;
        endcase
    end

    // ===================================================
    // 8. HAZARD & FORWARDING INSTANTIATIONS
    // ===================================================

    forwarding_unit fwd_u (
        .rs1_E (id_ex_q.rs1),
        .rs2_E (id_ex_q.rs2),
        .rd_M (ex_mem_q.rd),
        .reg_write_M (ex_mem_q.ctrl.RegWrite),
        .rd_W (mem_wb_q.rd),
        .reg_write_W (mem_wb_q.ctrl.RegWrite),
        .forward_a_E (forward_a_E),
        .forward_b_E (forward_b_E)
    );

    hazard_unit hzd_u (
        .rs1_D (if_id_q.inst[19:15]),
        .rs2_D (if_id_q.inst[24:20]),
        .rd_E (id_ex_q.rd),
        .result_src_E (id_ex_q.ctrl.ResultSrc),
        .pc_src_E (pc_src_E),
        .stall_F (stall_F),
        .stall_D (stall_D),
        .flush_D (flush_D),
        .flush_E (flush_E)
    );
endmodule