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

        // Test 2: Turn off Write Enable, check if we can read it
        we = 0;
        a = 32'd4;
        #10;

        // Test 3: Write another value to memory address 8 (Index 2)
        we = 1;
        a = 32'd8;
        wd = 32'h12345678;
        #10;

        // Test 4: Verify Write Enable safety
        we = 0;
        a = 32'd8;
        wd = 32'hBADDBADD;
        #10;

        $display("Data Memory sim complete");
        $finish;

    end

endmodule

