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

    always #5 clk = ~clk;

    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(9, tb_regfile);

        clk = 0;
        we = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;

        #10;

        // test 1:
        we = 1;
        rd = 5'd5;
        wd = 32'hDEADBEEF;
        #10;

        // test 2
        we = 0;
        rs1 = 5'd5;
        rs2 = 5'd0;
        #10;

        //test 3
        we = 1;
        rd = 5'd0;
        wd = 32'hFFFFFFFF;
        #10;

        //test 4
        we = 1;
        rd = 5'd10;
        wd = 32'h12345678;
        #10;

        //test 5
        we = 0;
        rd = 5'd10;
        wd = 32'hBADBAD00;
        #10;

        rs1 = 5'd0;
        rs2 = 5'd10;
        #10;

        $display("sim complete");
        $finish;
    end
endmodule