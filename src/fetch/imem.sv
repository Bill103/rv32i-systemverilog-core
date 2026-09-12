module imem #(parameter INIT_FILE = "programs/pipeline_test.hex")( 
    input logic [31:0] a,
    output logic [31:0] rd
);

    logic [31:0] RAM [0:63];

    assign rd = RAM[a[31:2]];

    // Here the ROM is initialized with some test instructions
    // Later we will load a real program
    initial begin
        for (int i=0; i<64; i++) RAM[i] = 32'h0000_0013;
        $readmemh(INIT_FILE, RAM);
    end
endmodule