module regfile(
    input logic clk,
    input logic we,

    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] wd,

    output logic [31:0] rd1,
    output logic [31:0] rd2
);

logic [31:0] registers [31:0];

always_ff @(posedge clk) begin
    if(we && rd != 5'd0) begin
        registers[rd] <= wd;
    end
end

assign rd1 = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
assign rd2 = (rs2 == 5'd0) ? 32'b0 : registers[rs2];

endmodule
