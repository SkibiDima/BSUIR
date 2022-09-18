create_clock -period 20 -waveform {0 10} [get_ports CLK]
create_generated_clock -name CLK_div2 -source [get_pins D0|clk] -divide_by 2 [get_pins D0|q]
create_generated_clock -name CLK_div4 -source [get_pins D1|clk] -divide_by 2 [get_pins D1|q]
create_generated_clock -name CLK_div8 -source [get_pins D2|clk] -divide_by 2 [get_pins D2|q]

