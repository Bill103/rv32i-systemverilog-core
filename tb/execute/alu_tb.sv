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

initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0, tb_alu);

    //test1: add(5+10)
    a = 32'd5;
    b = 32'd10;
    alu_control = 4'b0000;
    #10;

    //test2: sub(15-15)
    a = 32'd15;
    b = 32'd15;
    alu_control = 4'b0001;
    #10;

    //test3: slt(-5<10)
    a = -32'd5;
    b = 32'd10;
    alu_control = 4'b0011;
    #10;

    //test4: sll(1<<4)
    a = 32'd1;
    b = 32'd4;
    alu_control = 4'b0010;
    #10;

    $display("sim complete");
    $finish;
end

endmodule