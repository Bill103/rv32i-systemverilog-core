module dmem #(
    parameter DEPTH = 4096,
    parameter INIT_FILE = ""
)(
    input  logic        clk,            // System Clock
    input  logic [3:0]  we,             // 4-bit Byte Write Enable
    input  logic [31:0] a,              // Memory address
    input  logic [31:0] wd,             // Write data
    output logic [31:0] rd              // Read data
);

    logic [31:0] RAM [0:DEPTH-1];

    initial begin
        string hex_file;
        for (int i = 0; i < DEPTH; i++) RAM[i] = 32'h0;
        if ($value$plusargs("HEX=%s", hex_file)) begin
            $readmemh(hex_file, RAM);
        end else if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, RAM);
        end
    end

    // Instantly output the word at the requested address
    assign rd = RAM[a[13:2]];

    // Byte-enabled synchronous write
    always_ff @(posedge clk) begin
        if (we[0]) RAM[a[13:2]][7:0]   <= wd[7:0];
        if (we[1]) RAM[a[13:2]][15:8]  <= wd[15:8];
        if (we[2]) RAM[a[13:2]][23:16] <= wd[23:16];
        if (we[3]) RAM[a[13:2]][31:24] <= wd[31:24];
    end

endmodule
