# The generated clock is not available until after synthesis, this constraint
# is only applicable post-synthesis.

set_clock_groups -asynchronous -group [get_clocks TCK] -group [get_clocks clk_out1_clk_wiz_0]
