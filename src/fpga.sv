module fpga_top (
    input logic clk_100mhz,
    input logic btn_rst,
    output logic [7:0] led
);
    logic clk_50mhz;
    logic pll_locked;
    
    clk_wiz_0 u_clk_wiz (
        .clk_in1 (clk_100mhz),
        .clk_out1 (clk_50mhz),
        .reset(btn_rst),
        .locked(pll_locked)
    );
    
    logic rst_sync;
    assign rst_sync = btn_rst || !pll_locked;
    
    
    core u_core (
        .clk(clk_50mhz),
        .rst (rst_sync)
    );

    assign led = u_core.pc_current[7:0];

endmodule
