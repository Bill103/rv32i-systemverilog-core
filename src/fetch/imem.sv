module imem #(
    parameter DEPTH = 4096,
    parameter INIT_FILE = "programs/pipeline_test.mem"
)( 
    input logic [31:0] a,
    output logic [31:0] rd
);

    logic [31:0] RAM [0:DEPTH-1];

    assign rd = RAM[a[13:2]];

    initial begin
        string hex_file;
        // Initialize entire RAM to default values
        for (int i=0; i<DEPTH; i++) RAM[i] = 32'h0000_0013;
        // Check if a runtime "+HEX.." argument was passed
        if ($value$plusargs("HEX=%s", hex_file)) begin
            $readmemh(hex_file, RAM);
        // Fallback if no argument is passed
        end else if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, RAM);
        end
    end
endmodule
