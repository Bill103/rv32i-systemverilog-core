`timescale 1ns / 1ps
`include "alu.sv"
module tb_alu;

logic [31:0] a;
logic [31:0] b;
logic [3:0] alu_control;
logic [31:0] result;
logic zero;

alu uut(
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .result(result),
    .zero(zero)
);

task automatic check_alu(
    input logic [31:0] expected_result,
    input logic expected_zero,
    input string test_name
);
    if (result !== expected_result) begin
        $fatal(1, "%s: expected result %h, got %h", test_name, expected_result, result);
    end
    if (zero !== expected_zero) begin
        $fatal(1, "%s: expected zero=%b, got %b", test_name, expected_zero, zero);
    end
endtask

initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0, tb_alu);

    //test1: add(5+10)
    a = 32'd5;
    b = 32'd10;
    alu_control = 4'b0000;
    #10;
    check_alu(32'd15, 1'b0, "ADD");

    //test2: sub(15-15)
    a = 32'd15;
    b = 32'd15;
    alu_control = 4'b0001;
    #10;
    check_alu(32'd0, 1'b1, "SUB");

    //test3: slt(-5<10)
    a = -32'd5;
    b = 32'd10;
    alu_control = 4'b0011;
    #10;
    check_alu(32'd1, 1'b0, "SLT");

    //test4: sll(1<<4)
    a = 32'd1;
    b = 32'd4;
    alu_control = 4'b0010;
    #10;
    check_alu(32'd16, 1'b0, "SLL");

    $display("sim complete");
    $finish;
end

endmodule