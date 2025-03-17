# The generated clock is not available until after synthesis, this constraint
# is only applicable post-synthesis.

set_clock_groups -asynchronous -group [get_clocks TCK] -group [get_clocks -of_objects [get_pins clk_gen/inst/mmcm_adv_inst/CLKOUT0]]
