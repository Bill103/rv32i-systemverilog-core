module imem(
    input logic [31:0] a,
    output logic [31:0] rd
);

    logic [31:0] RAM [63:0];

    assign rd = RAM[a[31:2]];

    // Here the ROM is initialized with some test instructions
    // Later we will load a real program
    initial begin
        // ADDI x5, x0, 10 
        RAM[0] = 32'h00A00293;

        // ADDI x6, x5, 5,
        RAM[1] = 32'h00528313;

        // SUB x7, x6, x5
        RAM[2] = 32'h405303B3;

        for(int i = 3; i < 64; i++) begin
            RAM[i]=32'h00000013;
        end
    end
endmodule