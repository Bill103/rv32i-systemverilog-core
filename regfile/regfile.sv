module regfile(
    input logic clk,            // System Clock
    input logic we,             // Write-Enable flag

    input logic [4:0] rs1,      // Read Register 1 address
    input logic [4:0] rs2,      // Read Register 2 address
    input logic [4:0] rd,       // Write Register address
    input logic [31:0] wd,      // Data to be written

    output logic [31:0] rd1,    // Read Data 1 output
    output logic [31:0] rd2     // Read Data 2 output
);

    // An array of 32 registers, each 32 bits wide
    logic [31:0] registers [31:0];

    always_ff @(posedge clk) begin
        // Only write if we is high and the register to be written isn't x0
        if(we && rd != 5'd0) begin
            registers[rd] <= wd;
        end
    end

    // If the address is 0, output 0. Else output the registers contents
    assign rd1 = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'b0 : registers[rs2];

endmodule
