`timescale 1ns / 1ps

module dmem_tb;

    logic clk;
    logic we;
    logic [31:0] a;
    logic [31:0] wd;
    logic [31:0] rd;

    dmem uut(
        .clk(clk),
        .we(we),
        .a(a),
        .wd(wd),
        .rd(rd)
    );

    task automatic check_read(
        input logic [31:0] expected,
        input string test_name
    );
        if (rd !== expected) begin
            $fatal(1, "%s: expected read data %h, got %h", test_name, expected, rd);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dmem.vcd");
        $dumpvars(0, dmem_tb);

        clk = 0;
        we = 0;
        a = 0;
        wd = 0;
        #10;

        $display("Starting Data Memory sim");

        // Test 1: Write a value to memory address 4 (Index 1)
        we = 1;
        a = 32'd4;
        wd = 32'hBEEFCAFE;
        #10;
        check_read(32'hBEEFCAFE, "write address 4");

        // Test 2: Turn off Write Enable, check if we can read it
        we = 0;
        a = 32'd4;
        #10;
        check_read(32'hBEEFCAFE, "read address 4");

        // Test 3: Write another value to memory address 8 (Index 2)
        we = 1;
        a = 32'd8;
        wd = 32'h12345678;
        #10;
        check_read(32'h12345678, "write address 8");

        // Test 4: Verify Write Enable safety
        we = 0;
        a = 32'd8;
        wd = 32'hBADDBADD;
        #10;
        check_read(32'h12345678, "write-disabled address 8 protection");

        $display("Data Memory sim complete");
        $finish;

    end

endmodule

