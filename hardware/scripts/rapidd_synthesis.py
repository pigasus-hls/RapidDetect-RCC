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

# Set design parameters for synthesis of 200Gbps design
CFLAGS = '-DNO_MY_ASSERT=1 -DMSPM_TRACKPOS=1 -DMSPM_RESOLVE_CONFLICT=1 -DTEST_SAMEFLOW=0 -DTEST_PREPEND7=0 -DMSPM_UNROLL=8 -DMSPM_CHECKFIELD=1 -DIO_HBM_NUM_CHANNELS=2'

# Choose V80
FPGA = 'xcv80-lsva4737-2MHP-e-S'

FREQ = 550  # Target frequency for synthesis in MHz

SRC = 'src/io_stages.cpp src/sm.cpp src/mspm/mspm.cpp src/sm_kernel.cpp'
TESTBENCH_SRC = 'src/test/testbench_kernel.cpp'
TESTBENCH = 'src/test/testbench.cpp src/test/testinit.cpp src/test/main_hls.cpp'

# Set workspace for HLS components
WORKSPACE = './hls_workspace'

# Set HLS Synthesis configuration parameters for all the kernels
def set_common_config(cfg_file):
    cfg_file.set_value(key='part', value=FPGA) # Specify the target FPGA part for synthesis
    cfg_file.set_value(section='hls', key='clock', value=str(1/FREQ * 1E3) + 'ns')
    cfg_file.set_value(section='hls', key='vivado.clock', value=str(1/FREQ * 1E3) + 'ns')
    cfg_file.set_value(section='hls', key='flow_target', value='vivado')
    cfg_file.set_value(section='hls', key='package.output.format', value='ip_catalog')
    cfg_file.set_value(section='hls', key='syn.interface.m_axi_alignment_byte_size', value='64')
    cfg_file.set_value(section='hls', key='syn.interface.m_axi_max_widen_bitwidth', value='512')
    cfg_file.set_value(section='hls', key='syn.interface.m_axi_max_read_burst_length', value='256')
    cfg_file.set_value(section='hls', key='syn.interface.m_axi_max_write_burst_length', value='8')
    cfg_file.set_value(section='hls', key='syn.interface.m_axi_num_write_outstanding', value='32')
    cfg_file.set_value(section='hls', key='syn.interface.m_axi_latency', value='32')
    cfg_file.set_value(section='hls', key='sim.O', value='0')
    cfg_file.set_value(section='hls', key='csim.clean', value='1')

    cfg_file.set_values(section='hls', key='syn.file', values=['../../' + file for file in SRC.split()])  # Set the source files for synthesis in the configuration file

    cfg_file.set_value(section='hls', key='syn.cflags', value='-I../../include ' + CFLAGS)  # Set the C synthesis flags in the configuration file

def synthesize_kernel(client, kernel_name):
    comp = client.get_component(name=kernel_name)  # Get a handle for the specified HLS component
    comp.run(operation='SYNTHESIS')  # Run the synthesis operation on the component

def create_kernels(client, kernel_name):
    # Check if the component 'sm_kernel' exists and delete it if it does
    if os.path.exists(WORKSPACE + '/' + kernel_name):  # Verify if the specified component directory exists
        client.delete_component(name=kernel_name)  # Delete the existing component to avoid conflicts

    # Create a new HLS component, specifying a configuration file and template
    comp = client.create_hls_component(name=kernel_name, cfg_file=['hls_config.cfg'], template='empty_hls_component')
    cfg_file = client.get_config_file(path=WORKSPACE + '/' + kernel_name + '/hls_config.cfg')  # Retrieve the configuration file for the component
    set_common_config(cfg_file)  # Apply common configuration settings to the configuration file
    cfg_file.set_value(section='hls', key='syn.top', value=kernel_name)  # Set the top-level function for synthesis in the configuration file

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))  # Get the absolute path of the current script

# Initialize a session with the Vitis library
client = vitis.create_client()  # Create a Vitis client to interact with the HLS tools
client.set_workspace(path=WORKSPACE)  # Set the workspace directory to './hls_workspace' for managing HLS components

kernels = ['fieldMatchKernel', 'fieldMatchFixOverflowKernel', 'mergePipesKernel', 'sm_kernel', 'payloadSourceKernel', 'payloadReadKernel', 'resultWriteKernel', 'resultSinkKernel', 'doneCountKernel']
for kernel in kernels:
    create_kernels(client, kernel)  # Create HLS components for each kernel specified in the list
    synthesize_kernel(client, kernel)  # Synthesize each kernel to generate the corresponding hardware description

vitis.dispose() # Clean up the Vitis client session
