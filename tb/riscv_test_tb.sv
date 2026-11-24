`timescale 1ns / 1ps

module riscv_test_tb;

    logic clk;
    logic rst;

    core #(
        .INIT_FILE("")
    ) uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generator: 100MHz (10ns period)
    always #5 clk = ~clk;

    int cycle_count;
    logic [31:0] prev_pc;
    int loop_count;
    string test_name;

    initial begin
        clk = 0;
        rst = 1;
        cycle_count = 0;
        prev_pc = 32'hFFFF_FFFF;
        loop_count = 0;

        if (!$value$plusargs("TESTNAME=%s", test_name)) begin
            test_name = "test";
        end

        #20;
        rst = 0;
    end

    always @(posedge clk) begin
        if (!rst) begin
            cycle_count <= cycle_count + 1;

            // Detect spin loop (j 1b where pc jumps to self in EX stage)
            if (uut.pc_src_E && (uut.pc_target_E == uut.id_ex_q.pc)) begin
                loop_count <= loop_count + 1;
            end

            if (loop_count >= 5) begin
                logic [31:0] gp;
                gp = uut.rf_inst.get_reg(5'd3); // x3 is gp (TESTNUM)

                if (gp == 32'd1) begin
                    $display("[PASS] %-15s passed in %0d cycles", test_name, cycle_count);
                    $finish(0);
                end else begin
                    $display("[FAIL] %-15s failed at subtest %0d (gp=0x%08h, cycle=%0d, pc=0x%08h)", 
                             test_name, gp >> 1, gp, cycle_count, uut.pc_current);
                    $finish(1);
                end
            end

            // Timeout watchdog
            if (cycle_count > 20000) begin
                $display("[TIMEOUT] %-15s timed out after %0d cycles (pc=0x%08h, gp=%0d)",
                         test_name, cycle_count, uut.pc_current, uut.rf_inst.get_reg(5'd3));
                $finish(2);
            end
        end
    end

endmodule
