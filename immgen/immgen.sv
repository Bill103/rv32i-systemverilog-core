module immgen(
    input logic [31:0] inst,
    input logic [2:0] imm_src,
    output logic [31:0] imm
);

    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

    assign imm_i = {{20{inst[31]}}, inst[31:20]};
    assign imm_s = {{20{inst[31]}}, inst[31:25], inst[11:7]};
    assign imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    assign imm_u = {inst[31:12], 12'b0};
    assign imm_j = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

    always_comb begin
        case (imm_src)
            3'b000: imm = imm_i;    // I-type
            3'b001: imm = imm_s;    // S-type
            3'b010: imm = imm_b;    // B-type
            3'b011: imm = imm_u;    // U-type
            3'b100: imm = imm_j;    // J-type
            default: imm = 32'b0;
        endcase
    end
endmodule
