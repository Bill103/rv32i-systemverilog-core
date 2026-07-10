module pc(
    input logic clk,
    input logic rst,
    input logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'b0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule