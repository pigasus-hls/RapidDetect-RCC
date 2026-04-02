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

import vitis  # Import the Vitis library for High-Level Synthesis (HLS) functionalities
import os     # Import the os module for interacting with the operating system
import time   # Import the time module for adding delays
import sys

# Set design parameters for testbench
CFLAGS = '-DMSPM_TRACKPOS=1 -DMSPM_RESOLVE_CONFLICT=1 -DTEST_SAMEFLOW=0 -DTEST_PREPEND7=0 -DMSPM_UNROLL=2 -DMSPM_CHECKFIELD=0 -DIO_HBM_NUM_CHANNELS=2'

# Choose V80
FPGA = 'xcv80-lsva4737-2MHP-e-S'

FREQ = 500  # Target frequency for synthesis in MHz

SRC = 'src/io_stages.cpp src/sm.cpp src/mspm/mspm.cpp src/sm_kernel.cpp'
TESTBENCH_SRC = 'src/test/testbench_kernel.cpp'
TESTBENCH = 'src/test/testbench.cpp src/test/testinit.cpp src/test/main_hls.cpp'

# Set workspace for HLS components
WORKSPACE = './hls_workspace'

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))  # Get the absolute path of the current script

# Initialize a session with the Vitis library
client = vitis.create_client()  # Create a Vitis client to interact with the HLS tools
client.set_workspace(path=WORKSPACE)  # Set the workspace directory for managing HLS components

# Check if the component 'rapidd_testbench' exists and delete it if it does
if os.path.exists(WORKSPACE + '/rapidd_testbench'):  # Verify if the specified component directory exists
    client.delete_component(name='rapidd_testbench')  # Delete the existing component to avoid conflicts

# Create a new HLS component, specifying a configuration file and template
comp = client.create_hls_component(name='rapidd_testbench', cfg_file=['hls_config.cfg'], template='empty_hls_component')
cfg_file = client.get_config_file(path=WORKSPACE + '/rapidd_testbench/hls_config.cfg')  # Retrieve the configuration file for the component

cfg_file.set_value(key='part', value=FPGA) # Specify the target FPGA part for synthesis
cfg_file.set_value(section='hls', key='clock', value=str(1/FREQ * 1E3) + 'ns')
cfg_file.set_value(section='hls', key='vivado.clock', value=str(1/FREQ * 1E3) + 'ns')
cfg_file.set_value(section='hls', key='flow_target', value='vivado')
cfg_file.set_value(section='hls', key='package.output.format', value='ip_catalog')
cfg_file.set_value(section='hls', key='syn.interface.m_axi_alignment_byte_size', value='64')
cfg_file.set_value(section='hls', key='syn.interface.m_axi_max_widen_bitwidth', value='512')
cfg_file.set_value(section='hls', key='sim.O', value='1')
cfg_file.set_value(section='hls', key='csim.clean', value='1')

cfg_file.set_values(section='hls', key='syn.file', values=['../../' + file for file in (SRC + ' ' + TESTBENCH_SRC).split()])  # Set the source files for simulation in the configuration file
cfg_file.set_values(section='hls', key='tb.file', values=['../../' + file for file in TESTBENCH.split()])  # Set the testbench files for simulation in the configuration file

cfg_file.set_value(section='hls', key='tb.cflags', value='-I../../include -std=c++17 ' + CFLAGS)  # Set the Testbench flags in the configuration file
cfg_file.set_value(section='hls', key='syn.csimflags', value='-I../../include -std=c++17 ' + CFLAGS)  # Set the C simulation flags in the configuration file

cfg_file.set_value(section='hls', key='syn.top', value='testbench_kernel')  # Set the top-level function for simulation in the configuration file

comp = client.get_component(name='rapidd_testbench')   # Get a handle for the newly created HLS component

print("This can take a few minutes...")
sys.stdout = open(os.devnull, 'w')  # Redirect standard output to /dev/null to suppress it
comp.run(operation='C_SIMULATION')                  # Perform C simulation to verify functionality
vitis.dispose() # Clean up the Vitis client session

# Set standard output back to normal
sys.stdout = sys.__stdout__

# Diff the output of C simulation against a reference output to check for correctness
csim_log = WORKSPACE + '/rapidd_testbench/rapidd_testbench/logs/hls_run_csim.log'  # Path to the C simulation output log
golden_output = './golden/pigsmonly_cs.txt'  # Path to the reference output file for comparison

# Check if there was any error during C simulation by looking for "ERROR" in the log file
with open(csim_log, 'r') as log_file:
    log_contents = log_file.read()  # Read the contents of the C simulation log file
    if "ERROR" in log_contents:  # Check if the string "ERROR" is present in the log contents
        print(f"C Simulation encountered an error. Please check the log file ({csim_log}) for details.")
        sys.exit(1)  # Exit with a non-zero status to indicate failure

# Use the 'diff' command to compare the C simulation output with the filtered golden output
# For diff ignore lines that contain "HLS" and "INFO" since those are not relevant to the correctness of the output
diff_command = f'diff -I "HLS" -I "INFO" {csim_log} {golden_output}'  # Construct the diff command to compare outputs while ignoring specific lines
diff_result = os.system(diff_command)  # Execute the diff command and capture the result

# Check the result of the diff command to determine if the outputs match
if diff_result == 0:
    print("C Simulation output matches the golden output. Test PASSED.")
else:
    print("C Simulation output does NOT match the golden output. Test FAILED.")
