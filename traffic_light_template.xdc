# XDC TEMPLATE ONLY — replace placeholders using the official master XDC
# for your exact FPGA board. Do not use these placeholder values as pins.
#
# Example for a 100 MHz clock (10 ns period):
# set_property PACKAGE_PIN <CLOCK_PIN> [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]
# create_clock -period 10.000 -name sys_clk [get_ports clk]
#
# set_property PACKAGE_PIN <RESET_BUTTON_PIN> [get_ports reset]
# set_property IOSTANDARD LVCMOS33 [get_ports reset]
#
# set_property PACKAGE_PIN <ENABLE_SWITCH_PIN> [get_ports enable]
# set_property IOSTANDARD LVCMOS33 [get_ports enable]
#
# set_property PACKAGE_PIN <RED_LED_PIN> [get_ports red_out]
# set_property IOSTANDARD LVCMOS33 [get_ports red_out]
#
# set_property PACKAGE_PIN <GREEN_LED_PIN> [get_ports green_out]
# set_property IOSTANDARD LVCMOS33 [get_ports green_out]
#
# set_property PACKAGE_PIN <YELLOW_LED_PIN> [get_ports yellow_out]
# set_property IOSTANDARD LVCMOS33 [get_ports yellow_out]
