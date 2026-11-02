# Primary 100 MHz clock is automatically constrained by clk_wiz_0 IP (clk_wiz_0.xdc).
# Uncomment below only if synthesizing top-level without clk_wiz IP:
# create_clock -period 10.000 -name sys_clk [get_ports clk_100mhz]

# False path on asynchronous reset button
set_false_path -from [get_ports btn_rst]

# Output capacitive load models (5 pF) for timing and power analysis
# Note: Use the SDC command 'set_load' rather than 'set_property LOAD'
# so Vivado accepts it on pre-synthesized designs during synthesis.
set_load 5.000 [all_outputs]
