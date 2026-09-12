module hazard_unit (
    input logic [4:0] rs1_D,
    input logic [4:0] rs2_D,
    input logic [4:0] rd_E,
    input logic [1:0] result_src_E,
    input logic pc_src_E,
    output logic stall_F,
    output logic stall_D,
    output logic flush_D,
    output logic flush_E
);

    logic load_use_hazard;

    always_comb begin
        load_use_hazard = (result_src_E == 2'b01) && (rd_E != 5'd0) && ((rd_E == rs1_D) || (rd_E == rs2_D));
    
        if (pc_src_E) begin
            stall_F = 1'b0;
            stall_D = 1'b0;
            flush_D = 1'b1;
            flush_E = 1'b1;
        end else if (load_use_hazard) begin
            stall_F = 1'b1;
            stall_D = 1'b1;
            flush_D = 1'b0;
            flush_E = 1'b1;
        end else begin
            stall_F = 1'b0;
            stall_D = 1'b0;
            flush_D = 1'b0;
            flush_E = 1'b0;
        end
    end
    
endmodule

