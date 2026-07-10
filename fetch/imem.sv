module imem(
    input logic [31:0] a,
    output logic [31:0] rd
);

    logic [31:0] RAM [63:0];

    assign rd = RAM[a[31:2]];

    // Here the ROM is initialized with some test instructions
    // Later we will load a real program
    initial begin
        // Look for a file named "program.hex" which contains the code
        $readmemh("program.hex", RAM);
    end
endmodule