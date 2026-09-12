module forwarding_unit (
    input logic [4:0] rs1_E,
    input logic [4:0] rs2_E,
    input logic [4:0] rd_M,
    input logic reg_write_M,
    input logic [4:0] rd_W,
    input logic reg_write_W,
    output logic [1:0] forward_a_E,
    output logic [1:0] forward_b_E
);

    always_comb begin
        // Forwarding for Opearand A (rs1)
        if (reg_write_M && (rd_M != 5'd0) && (rd_M == rs1_E)) begin
            forward_a_E = 2'b10; // EX hazard (MEM stage)
        end else if (reg_write_W && (rd_W != 5'd0) && (rd_W == rs1_E)) begin
            forward_a_E = 2'b01; // MEM hazard (WB stage)            
        end else begin
            forward_a_E = 2'b00;
        end

        // Forwarding for Operand B (rs2)
        if (reg_write_M && (rd_M != 5'd0) && (rd_M == rs2_E)) begin
            forward_b_E = 2'b10; // EX hazard (MEM stage)
        end else if (reg_write_W && (rd_W != 5'd0) && (rd_W == rs2_E)) begin
            forward_b_E = 2'b01; // MEM hazard (WB stage)
        end else begin
            forward_b_E = 2'b00;
        end
    end

endmodule
