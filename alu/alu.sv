module alu(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_control,
    output logic [31:0] result,
    output logic        zero
);

    // Extract the bottom 5 bits for shift opearations
    logic [4:0] shamt;
    assign shamt = b[4:0];

    always_comb begin
        case(alu_control)
            4'b0000: result = a+b;                                      //add
            4'b0001: result = a-b;                                      //sub
            4'b0010: result = a<<shamt;                                 //sll
            4'b0011: result = $signed(a) < $signed(b) ? 32'd1 : 32'd0;  //slt
            4'b0100: result = a < b ? 32'd1 : 32'd0;                    //sltu
            4'b0101: result = a ^ b;                                    //xor
            4'b0110: result = a >> shamt;                               //srl
            4'b0111: result = $signed(a) >>> shamt;                     //sra
            4'b1000: result = a | b;                                    //or
            4'b1001: result = a & b;                                    //and
            default: result = 32'b0;                                    //fallback

        endcase
    end

    assign zero = (result == 32'b0);

endmodule