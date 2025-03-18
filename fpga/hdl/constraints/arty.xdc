## This file is for the ARTY
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## BSCANE2 related clock definitions

create_clock -period 20.000 -name DRCK -waveform {0.000 10.000} [get_pins jtag/BSCANE2_inst/DRCK]
create_clock -period 20.000 -name TCK -waveform {0.000 10.000} [get_pins jtag/BSCANE2_inst/TCK]

## Main clock
#create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_pins clk_gen/clk_out1]

# TCK and clk are unrelated, tell vivado that.
# set_clock_groups -asynchronous -group [get_clocks TCK] -group [get_clocks clk_out1_clk_wiz_0]
# create_clock -period 1.000 -name virtual_clock


## Clock signal 100 MHz

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sysclk]

# do not time async inputs
set_false_path -from [get_ports sw[0] ]
set_false_path -from [get_ports sw[1] ]
set_false_path -from [get_ports btn[0] ]
set_false_path -from [get_ports btn[1] ]
set_false_path -from [get_ports btn[2] ]
set_false_path -from [get_ports btn[3] ]

#set_false_path -to [get_ports rx]
#set_false_path -from [get_ports tx]

set_false_path -to [get_ports led_r[0] ]
set_false_path -to [get_ports led_r[1] ]
set_false_path -to [get_ports led_r[2] ]
set_false_path -to [get_ports led_r[3] ]
set_false_path -to [get_ports led_b[0] ]
set_false_path -to [get_ports led_b[1] ]
set_false_path -to [get_ports led_b[2] ]
set_false_path -to [get_ports led_b[3] ]

## Switches
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33}     [get_ports sw[0]]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33}    [get_ports sw[1]]

## Buttons
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports btn[0] ]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports btn[1] ]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports btn[2] ]
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33} [get_ports btn[3] ]

## LEDs 
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports led_r[0] ]
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports led_r[1] ]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports led_r[2] ]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports led_r[3] ]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports led_b[0] ]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports led_b[1] ]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports led_b[2] ]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports led_b[3] ]

## Debug LEDs
set_false_path -to [get_ports led[0] ]
set_false_path -to [get_ports led[1] ]
set_false_path -to [get_ports led[2] ]
set_false_path -to [get_ports led[3] ]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33}  [get_ports led[0] ]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33}  [get_ports led[1] ]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33}  [get_ports led[2] ]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports led[3] ]


set_property BITSTREAM.CONFIG.USERID 32'h00102030 [current_design]
