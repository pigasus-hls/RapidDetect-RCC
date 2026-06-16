# Copyright (c) 2024 - 2025 Advanced Micro Devices, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
############################################################

# don't care about the reset performance
# set_false_path -quiet -from [get_pins top_i/clock_reset/usr_?_psr/U0/ACTIVE_LOW_BSR_OUT_DFF[0].FDRE_BSR_N/C]
# set_false_path -quiet -from [get_pins top_i/clock_reset/usr_?_psr/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C]

# SLR2 pblock
create_pblock pblock_SLR2
resize_pblock [get_pblocks pblock_SLR2] -add {CLOCKREGION_X0Y8:CLOCKREGION_X9Y10}
resize_pblock [get_pblocks pblock_SLR2] -add {CLOCKREGION_X0Y11:CLOCKREGION_X8Y11}
add_cells_to_pblock [get_pblocks pblock_SLR2] [get_cells {top_i/RapidDetect top_i/smartconnect_0 top_io/axi_gpio_0}]

# SLR1 pblock
create_pblock pblock_SLR1
resize_pblock [get_pblocks pblock_SLR1] -add {CLOCKREGION_X0Y5:CLOCKREGION_X9Y7}

# SLR0 pblock
create_pblock pblock_SLR0
resize_pblock [get_pblocks pblock_SLR0] -add {CLOCKREGION_X0Y0:CLOCKREGION_X12Y0}
resize_pblock [get_pblocks pblock_SLR0] -add {CLOCKREGION_X0Y1:CLOCKREGION_X9Y4}
add_cells_to_pblock pblock_SLR0 [get_cells top_i/clock_reset]
add_cells_to_pblock pblock_SLR0 [get_cells -hierarchical -filter {PARENT =~ "top_i/base_logic" && NAME !~ "top_i/base_logic/pcie_slr*_sc"}]
add_cells_to_pblock pblock_SLR0 [get_cells top_i/base_logic/pcie_slr0_mgmt_sc]

# Indicate that SLR pblocks must strictly be obeyed.
set_property IS_SOFT FALSE [get_pblocks pblock_SLR*]

# BASE NSUs/NMUs
set_property LOC NOC_NSU512_X0Y0  [get_cells -filter {REF_NAME == NOC_NSU512} -of [get_pins -leaf -filter {DIRECTION == OUT} -of [get_nets -of [get_pins top_i/base_logic/pcie_slr0_mgmt_sc/S00_AXI_wvalid]]]]

create_clock -name qsfp0_322mhz_clk_p -period 3.103 [get_ports qsfp0_322mhz_clk_p]
create_clock -name qsfp2_322mhz_clk_p -period 3.103 [get_ports qsfp2_322mhz_clk_p]

# False path for GTQUAD asynchronous interfaces (derived from example design)
set_false_path -from [get_clocks clock_reset_clk_usr_1] -to [get_clocks -of_objects [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/clock_reset/clk_wiz*/inst/clock_primitive_inst/MMCME5_inst}] -filter {name =~ *CLKOUT*}]] -through [get_pins -hierarchical "*dcmac_wrapper*"]
set_false_path -from [get_clocks -of_objects [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/clock_reset/clk_wiz*/inst/clock_primitive_inst/MMCME5_inst}] -filter {name =~ *CLKOUT*}]] -to [get_clocks clock_reset_clk_usr_1] -through [get_pins -hierarchical "*dcmac_wrapper*"]
set_false_path -from [get_clocks clock_reset_clk_usr_1] -to [get_clocks -of_objects [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/clock_reset/clk_wiz*/inst/clock_primitive_inst/MMCME5_inst}] -filter {name =~ *CLKOUT*}]] -through [get_pins -hierarchical "*reset_done_axis_clk_syncer*" ]
set_false_path -from [get_clocks -of_objects [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/clock_reset/clk_wiz*/inst/clock_primitive_inst/MMCME5_inst}] -filter {name =~ *CLKOUT*}]] -to [get_clocks clock_reset_clk_usr_1] -through [get_pins -hierarchical "*reset_done_axis_clk_syncer*" ]

# Waivers for DCMAC subsystem (derived from example design)
create_waiver -quiet -type CDC -id {CDC-10} -user "dcmac" -desc "The CDC-10 warning is waived as it is a level signal in reset path. This is safe to ignore" -tags "1103070"\
-from [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/gpio_core*/*Dual.gpio_Data_Out_reg*}] -filter { name =~ *C }]\
-to [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/clock_reset/*reset_done_core_clk_syncer/inst/reset_pipe_retime_reg*}] -filter { name =~ *CLR }]

create_waiver -quiet -type CDC -id {CDC-13} -user "dcmac" -desc "The CDC-13 warning is waived as it is a level signal in reset path. This is safe to ignore" -tags "1103070"\
-from [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/gpio_core*/*Dual.gpio_Data_Out_reg*}] -filter { name =~ *C } ]\
-to [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/dcmac/inst*}] -filter { name =~ *_core_reset} ]

create_waiver -quiet -type CDC -id {CDC-10} -user "dcmac" -desc "The CDC-10 warning is waived as it is a level signal in reset path. This is safe to ignore" -tags "1103070"\
-from [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/*gtwiz_versal*_gtreset_inst_*/*master_reset_synchronizer_gtwiz_reset_all_inst_*/*syncstages_ff_reg*}] -filter { name =~ *C } ]\
-to [get_pins -of [get_cells -hier -filter {name =~ */qsfp*/clock_reset/*reset_done_*_clk_syncer/inst/reset_pipe_retime_reg*}] -filter { name =~ *CLR }]

create_waiver -quiet -type DRC -id {REQP-2057} -user "dcmac" -desc "REQP-2057 is waived as the MBUFG_GT CLR and CLRBLEAF pins are connected with the GT Reset IP" -tags "1138767" -objects [get_cells -hier -filter {REF_NAME==MBUFG_GT && NAME=~ */qsfp*/*}]
