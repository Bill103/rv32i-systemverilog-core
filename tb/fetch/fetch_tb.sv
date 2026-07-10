`timescale 1ns / 1ps

module fetch_tb;

    logic clk;
    logic rst;
    logic [31:0] next_pc;
    logic [31:0] current_pc;
    logic [31:0] instruction;

    // Instatiate the Program Counter (PC)
    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .pc(current_pc)
    );
    // Instantiatae the Instruction Memory (IMEM)
    imem imem_inst(
        .a(current_pc),
        .rd(instruction)
    );
    // Continuously take the current address, add 4 and feed it to next_pc
    assign next_pc = current_pc + 32'd4;

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fetch.vcd");
        $dumpvars(0,fetch_tb);

        // Start with Reset high
        clk = 0;
        rst = 1;
        $display("Resetting");

        #10;

        // Reset low, CPU runs
        rst = 0;
        $display("Fetching Instructions");
        // Let the clock tick for 40ns
        #40;

        $display("Fetch Simulation Complete!");
        $finish;
    end

endmodule