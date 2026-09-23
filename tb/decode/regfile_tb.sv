`timescale 1ns / 1ps

module tb_regfile;

    logic clk;
    logic we;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [31:0] wd;
    logic [31:0] rd1;
    logic [31:0] rd2;

    // Instantiate the register file
    regfile uut(
        .clk(clk),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    task automatic check_reads(
        input logic [31:0] expected_rd1,
        input logic [31:0] expected_rd2,
        input string test_name
    );
        if (rd1 !== expected_rd1) begin
            $fatal(1, "%s: expected rd1 %h, got %h", test_name, expected_rd1, rd1);
        end
        if (rd2 !== expected_rd2) begin
            $fatal(1, "%s: expected rd2 %h, got %h", test_name, expected_rd2, rd2);
        end
    endtask

    // Generate the clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(9, tb_regfile);

        // Initialize all inputs to zero
        clk = 0;
        we = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;

        // Wait for 10ns
        #10;

        // Test 1: Write a hex value to x5
        we = 1;
        rd = 5'd5;
        wd = 32'hDEADBEEF;
        #10;

        // Test 2: Read from x5 and x0
        we = 0;
        rs1 = 5'd5;
        rs2 = 5'd0;
        #10;
        check_reads(32'hDEADBEEF, 32'h00000000, "stored x5 and hardwired x0");

        // Test 3: Attempt to overwrite x0
        we = 1;
        rd = 5'd0;
        wd = 32'hFFFFFFFF;
        #10;
        check_reads(32'hDEADBEEF, 32'h00000000, "ignored write to x0");

        // Test 4: Write to x10
        we = 1;
        rd = 5'd10;
        wd = 32'h12345678;
        rs1 = 5'd10;
        rs2 = 5'd5;
        #10;
        check_reads(32'h12345678, 32'hDEADBEEF, "stored x10 with read forwarding");

        // Test 5: Verify Write Enable protection
        we = 0;
        rd = 5'd10;
        wd = 32'hBADBAD00;
        #10;
        check_reads(32'h12345678, 32'hDEADBEEF, "write-disabled x10 protection");

        // Test 6: Final read for confirmation
        rs1 = 5'd0;
        rs2 = 5'd10;
        #10;
        check_reads(32'h00000000, 32'h12345678, "final x0 and x10 read");

        $display("sim complete");
        $finish;
    end
endmodule