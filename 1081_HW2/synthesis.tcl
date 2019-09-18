set cycle  10  ;#clock period defined by designer

create_clock -period $cycle        [get_ports  clk]
set_dont_touch_network             [get_clocks clk]
set_fix_hold                       [get_clocks clk]
set_clock_uncertainty       0.1    [get_clocks clk]
set_clock_latency   -source 0      [get_clocks clk]
set_clock_latency           1      [get_clocks clk]
set_input_transition        0.5    [all_inputs]
set_clock_transition        0.5    [all_clocks]

set_operating_conditions -min fast  -max slow

set_input_delay   -max 1    -clock clk   [all_inputs]
set_input_delay   -min 0.2  -clock clk   [all_inputs]
set_output_delay  -max 1    -clock clk   [all_outputs]
set_output_delay  -min 0.1  -clock clk   [all_outputs]
set_wire_load_model -name tsmc13_wl10 -library slow