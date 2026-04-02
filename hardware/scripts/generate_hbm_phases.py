# /******************************************************************************
# MIT License

# Copyright (c) 2026 Shashank Obla, Carnegie Mellon University

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ******************************************************************************/

# This script generates a TCL script that when executed in Vivado will set the HBM phases bandwidth in the NoC IP

first_line = "set_property -dict [list CONFIG.CONNECTIONS {"
second_line = "{ read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} }"
last_line = "} read_avg_burst {256} write_avg_burst {4} multi_phase {true}}"

def create_one_port(index):
    output_string = ""
    output_string += second_line + " \\\n"
    for i in range(0, 16):
        output_string += "\tHBM" + str(i) + " { read_bw {" + str(12800 if ((index % 16) == i) else 0) + "} write_bw {0} read_avg_burst {256} write_avg_burst {4} } \\\n"
    return output_string + last_line + " \\\n"

main_string = "startgroup\n"
main_string += first_line + " \\\n"
for i in range(0, 16):
    main_string += "HBM" + str(i // 2) + "_PORT" + str(0 if i % 2 == 0 else 2) + " "
    main_string += create_one_port(i)

main_string += " }] [get_bd_intf_pins /axi_noc_0/HBM00_AXI]\n"

main_string += first_line + " \\\n"
for i in range(16, 32):
    main_string += "HBM" + str(i // 2) + "_PORT" + str(0 if i % 2 == 0 else 2) + " "
    main_string += create_one_port(i)

main_string += "}] [get_bd_intf_pins /axi_noc_0/HBM01_AXI]\n"
main_string += "endgroup\n"

print(main_string)
