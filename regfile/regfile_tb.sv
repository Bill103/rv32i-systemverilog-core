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

        // Test 3: Attempt to overwrite x0
        we = 1;
        rd = 5'd0;
        wd = 32'hFFFFFFFF;
        #10;

        // Test 4: Write to x10
        we = 1;
        rd = 5'd10;
        wd = 32'h12345678;
        #10;

        // Test 5: Verify Write Enable protection
        we = 0;
        rd = 5'd10;
        wd = 32'hBADBAD00;
        #10;

        // Test 6: Final read for confirmation
        rs1 = 5'd0;
        rs2 = 5'd10;
        #10;

        $display("sim complete");
        $finish;
    end
endmodule