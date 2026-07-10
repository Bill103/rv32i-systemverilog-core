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
        for (int i = 0; i < 32; i++) begin
            $dumpvars(0, uut.rf_inst.registers[i]);
        end

        for (int i = 0; i< 10; i++) begin
            $dumpvars(0, uut.dmem_inst.RAM[i]);
        end

        clk = 0;
        rst = 1;
        #10;

        rst = 0;

        #1000;

        $display("Execution Complete!");
        $finish;
    end

endmodule
