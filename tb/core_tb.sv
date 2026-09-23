`timescale 1ns / 1ps

module core_tb;
    
    logic clk;
    logic rst;

    core uut(
        .clk(clk),
        .rst(rst)
    );

    task automatic check_register(
        input logic [4:0] register_index,
        input logic [31:0] expected_value,
        input string test_name
    );
        if (uut.rf_inst.get_reg(register_index) !== expected_value) begin
            $fatal(1, "%s: expected %0d, got %0d", test_name, expected_value,
                   uut.rf_inst.get_reg(register_index));
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("core.vcd");
        $dumpvars(0, core_tb);
        clk = 0;
        rst = 1;
        #10;

        rst = 0;

        #300;

        $display("Execution Complete!");
        $display ("x1 (expected 5) : %0d", uut.rf_inst.get_reg(5'd1));
        $display ("x2 (expected 15) : %0d", uut.rf_inst.get_reg(5'd2));
        $display ("x3 (expected 15) : %0d", uut.rf_inst.get_reg(5'd3));
        $display ("x4 (expected 16) : %0d", uut.rf_inst.get_reg(5'd4));
        $display ("x5 (expected 0) : %0d (squashed branch delay)", uut.rf_inst.get_reg(5'd5));
        $display ("x6 (expected 42) : %0d", uut.rf_inst.get_reg(5'd6));

        check_register(5'd1, 32'd5, "x1");
        check_register(5'd2, 32'd15, "x2");
        check_register(5'd3, 32'd15, "x3");
        check_register(5'd4, 32'd16, "x4");
        check_register(5'd5, 32'd0, "x5 branch squash");
        check_register(5'd6, 32'd42, "x6");

        $finish;
    end

endmodule
