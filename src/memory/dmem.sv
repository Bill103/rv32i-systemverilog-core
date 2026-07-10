module dmem(
    input logic clk,            // System Clock
    input logic we,             // Write Enable signal
    input logic [31:0] a,       // Memory address
    input logic [31:0] wd,      // Write data
    output logic [31:0] rd      // Read data
);

    // Create a memory array of 64 words
    // 256B RAM
    logic [31:0] RAM [63:0];

    // Instantly output the data at the requested address
    assign rd = RAM[a[31:2]];

    // Only save data on the positive edge of the system clock if we is high
    always_ff @(posedge clk) begin
        if (we) begin
            RAM[a[31:2]] <= wd;
        end
    end

endmodule
