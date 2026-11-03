`timescale 1ns / 1ps

module rv32i_extended_tb;

    logic clk;
    logic rst;

    // Instantiate core with the extended test memory file
    core #(
        .INIT_FILE("programs/rv32i_extended_test.mem")
    ) uut (
        .clk(clk),
        .rst(rst)
    );

    task automatic check_reg(
        input logic [4:0]  idx,
        input logic [31:0] expected,
        input string       name
    );
        logic [31:0] actual;
        actual = uut.rf_inst.get_reg(idx);
        if (actual !== expected) begin
            $fatal(1, "[FAIL] %s (x%0d): expected 0x%08h, got 0x%08h", name, idx, expected, actual);
        end else begin
            $display("[PASS] %s (x%0d) = 0x%08h", name, idx, actual);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;

        // Run sufficient cycles for the test program to complete
        #400;

        $display("\n=======================================================");
        $display("   RV32I EXTENDED INSTRUCTION VALIDATION RESULTS");
        $display("=======================================================");

        // 1. Upper Immediates
        check_reg(5'd7,  32'h12345000, "LUI");
        check_reg(5'd8,  32'h00002004, "AUIPC");

        // 2. Sub-Word Loads
        check_reg(5'd9,  32'h0000005A, "LBU (byte 1)");
        check_reg(5'd10, 32'hFFFFFFFF, "LB (byte 0, sign-extended 0xFF)");
        check_reg(5'd11, 32'h000000FF, "LBU (byte 0, zero-extended 0xFF)");
        check_reg(5'd12, 32'hFFFFFFFE, "LH (half 1, sign-extended 0xFFFE)");
        check_reg(5'd13, 32'h0000FFFE, "LHU (half 1, zero-extended 0xFFFE)");

        // 3. Branch Operations & Squashing
        check_reg(5'd16, 32'd1,        "BNE (branch taken & squashed delay slot)");
        check_reg(5'd19, 32'd1,        "BLT (signed less-than taken)");
        check_reg(5'd20, 32'd1,        "BLTU (unsigned less-than taken)");

        $display("\n>> ALL RV32I EXTENDED INSTRUCTION TESTS PASSED! <<\n");
        $finish;
    end

endmodule
