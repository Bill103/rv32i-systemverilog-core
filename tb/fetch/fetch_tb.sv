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

    task automatic check_fetch(
        input logic [31:0] expected_pc,
        input logic [31:0] expected_instruction,
        input string test_name
    );
        if (current_pc !== expected_pc) begin
            $fatal(1, "%s: expected PC %h, got %h", test_name, expected_pc, current_pc);
        end
        if (instruction !== expected_instruction) begin
            $fatal(1, "%s: expected instruction %h, got %h", test_name, expected_instruction, instruction);
        end
    endtask

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
        check_fetch(32'h00000000, 32'h00500093, "reset state");

        // Reset low, CPU runs
        rst = 0;
        $display("Fetching Instructions");
        @(posedge clk);
        #1;
        check_fetch(32'h00000004, 32'h00A08113, "instruction 1");
        @(posedge clk);
        #1;
        check_fetch(32'h00000008, 32'h00202023, "instruction 2");
        @(posedge clk);
        #1;
        check_fetch(32'h0000000C, 32'h00002183, "instruction 3");
        @(posedge clk);
        #1;
        check_fetch(32'h00000010, 32'h00118213, "instruction 4");

        $display("Fetch Simulation Complete!");
        $finish;
    end

endmodule