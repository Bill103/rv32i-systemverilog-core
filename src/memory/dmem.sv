module dmem (
    input  logic        clk,            // System Clock
    input  logic [3:0]  we,             // 4-bit Byte Write Enable
    input  logic [31:0] a,              // Memory address
    input  logic [31:0] wd,             // Write data
    output logic [31:0] rd              // Read data
);

    // Create a memory array of 64 words (256B RAM)
    logic [31:0] RAM [0:63];

    initial begin
        for (int i = 0; i < 64; i++) RAM[i] = 32'h0;
    end

    // Instantly output the word at the requested address
    assign rd = RAM[a[31:2]];

    // Byte-enabled synchronous write
    always_ff @(posedge clk) begin
        if (we[0]) RAM[a[31:2]][7:0]   <= wd[7:0];
        if (we[1]) RAM[a[31:2]][15:8]  <= wd[15:8];
        if (we[2]) RAM[a[31:2]][23:16] <= wd[23:16];
        if (we[3]) RAM[a[31:2]][31:24] <= wd[31:24];
    end

endmodule
