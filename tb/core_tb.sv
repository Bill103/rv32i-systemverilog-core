`timescale 1ns / 1ps

module core_tb;
    
    logic clk;
    logic rst;

    core uut(
        .clk(clk),
        .rst(rst)
    );

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
        
        

        $finish;
    end

endmodule
