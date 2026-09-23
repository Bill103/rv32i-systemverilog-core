`timescale 1ns / 1ps

module tb_immgen;

    // Declare signals
    logic [31:0] inst;
    logic [2:0] imm_src;
    logic [31:0] imm;

    // Instantiate the ImmGen
    immgen uut(
        .inst(inst),
        .imm_src(imm_src),
        .imm(imm)
    );

    task automatic check_immediate(
        input logic [31:0] expected,
        input string test_name
    );
        if (imm !== expected) begin
            $fatal(1, "%s: expected immediate %h, got %h", test_name, expected, imm);
        end
    endtask

    initial begin
        $dumpfile("immgen.vcd");
        $dumpvars(0, tb_immgen);

        $display("Starting tests");
        
        // Test 1: I-type
        // inst[31:20] = 12'h8A5
        // Expected output 0xFFFFF8A5
        inst = 32'h8A500000;
        imm_src = 3'b000;
        #10;
        check_immediate(32'hFFFFF8A5, "I-type");

        // Test 2: S-type
        // imm is split: inst[31:25] and inst[11:7]
        // inst[31:25] = 7'b0000101, inst[11:7] = 5'b10101
        // Expected output 0xB5
        inst = 32'h0A000A80;
        imm_src = 3'b001;
        #10;
        check_immediate(32'h000000B5, "S-type");

        // Test 3: B-type
        // For inst = 32'hFE000F80, the bits unpack as:
        // bit 31 = 1, bit 7 = 1, bits[30:25]=111111, bits[11:8]=1111
        // Expected output 0xFFFFFFFE
        inst = 32'hFE000F80;
        imm_src = 3'b010;
        #10;
        check_immediate(32'hFFFFFFFE, "B-type");

        // Test 4: U-type
        // Grabs the top 20 bits and pads the rest with zeros
        // 0xABCDE as input
        // Expected output 0xABCDE000
        inst = 32'hABCDE000;
        imm_src = 3'b011;
        #10;
        check_immediate(32'hABCDE000, "U-type");

        // Test 5: J-type
        // We scramble the value +8 onto the inst fields
        // Expected result: 0x00000008
        inst = 32'h00800000;
        imm_src = 3'b100;
        #10;
        check_immediate(32'h00000008, "J-type");

        $display("end of sim");
        $finish;
    end

endmodule