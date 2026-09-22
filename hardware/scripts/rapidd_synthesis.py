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
import sys
import shutil
import argparse
import subprocess
from concurrent.futures import ProcessPoolExecutor, as_completed

# Set design parameters for synthesis of 200Gbps design
CFLAGS = '-DNO_MY_ASSERT=1 -DMSPM_TRACKPOS=1 -DNFPM_TRACKPOS=1 -DMSPM_RESOLVE_CONFLICT=1 -DTEST_SAMEFLOW=0 -DTEST_PREPEND7=0 -DMSPM_UNROLL=8 -DMSPM_CHECKFIELD=1 -DIO_HBM_NUM_CHANNELS=2 -DNFPM_UNROLL=2 -DNFPM_CHECKFIELD=1'

# Choose V80
FPGA = 'xcv80-lsva4737-2MHP-e-S'

FREQ = 550  # Target frequency for synthesis in MHz

SRC = 'src/io_stages.cpp src/sm.cpp src/nf.cpp src/mspm/mspm.cpp src/nfpm/nfpm.cpp src/sm_kernel.cpp src/nf_kernel.cpp src/rapidd_stages.cpp'
TESTBENCH_SRC = 'src/test/testbench_kernel.cpp'
TESTBENCH = 'src/test/testbench.cpp src/test/testinit.cpp src/test/main_hls.cpp'

# Base directory for HLS workspaces
WORKSPACE_BASE = './hls_workspace'

# Directory paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
HARDWARE_DIR = os.path.dirname(SCRIPT_DIR)

ALL_KERNELS = [
    # 'payloadSourceKernel',
    # 'payloadReadKernel',
    # 'mergePipesKernel',
    # 'resultWriteKernel',
    # 'resultSinkKernel',
    # 'payloadSinkKernel',
    'payloadWriteKernel',
    # 'convertToEthernetKernel',
    'fromEthernetKernel',
    # 'fieldTaggerKernel',
    # 'sm_kernel',
    # 'nf_kernel',
    # 'sm2nfKernel',
    # 'nf2hostKernel'
]

# Set HLS Synthesis configuration parameters for a kernel
def set_common_config(cfg_file, kernel_name):
    comp_dir = os.path.abspath(f"{WORKSPACE_BASE}/{kernel_name}/{kernel_name}")

    # Dynamically compute relative paths from component directory to source files and include dir
    rel_src_files = [
        os.path.relpath(os.path.join(HARDWARE_DIR, f), comp_dir)
        for f in SRC.split()
    ]
    rel_include_dir = os.path.relpath(os.path.join(HARDWARE_DIR, "include"), comp_dir)

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

    cfg_file.set_values(section='hls', key='syn.file', values=rel_src_files)
    cfg_file.set_value(section='hls', key='syn.cflags', value=f'-I{rel_include_dir} ' + CFLAGS)

def build_single_kernel_worker(kernel_name):
    """Executes inside its own vitis process using the pure Vitis Python API."""
    kernel_ws = os.path.abspath(f"{WORKSPACE_BASE}/{kernel_name}")
    # Remove existing directory to ensure Vitis initializes a clean, fresh workspace
    # (prevents 'cannot recognize the workspace version' if stale files exist from previous single-workspace runs)
    if os.path.exists(kernel_ws):
        shutil.rmtree(kernel_ws, ignore_errors=True)
    os.makedirs(kernel_ws, exist_ok=True)

    client = vitis.create_client()
    client.set_workspace(path=kernel_ws)

    comp_dir = os.path.join(kernel_ws, kernel_name)
    if os.path.exists(comp_dir):
        try:
            client.delete_component(name=kernel_name)
        except Exception:
            pass

    # Create component within this kernel's workspace
    comp = client.create_hls_component(name=kernel_name, cfg_file=['hls_config.cfg'], template='empty_hls_component')
    cfg_file = client.get_config_file(path=os.path.join(comp_dir, 'hls_config.cfg'))
    set_common_config(cfg_file, kernel_name)
    cfg_file.set_value(section='hls', key='syn.top', value=kernel_name)

    print(f"[{kernel_name}] Starting synthesis in {kernel_ws}...")
    comp = client.get_component(name=kernel_name)
    comp.run(operation='SYNTHESIS')
    print(f"[{kernel_name}] Synthesis completed successfully!")

    vitis.dispose()

def launch_kernel_process(kernel_name):
    """Spawns an independent vitis -s worker process for a single kernel."""
    script_path = os.path.abspath(__file__)
    cmd = ["vitis", "-s", script_path, "--worker", kernel_name]
    print(f"[{kernel_name}] Dispatching worker process...")
    res = subprocess.run(cmd)
    return kernel_name, (res.returncode == 0)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parallel HLS kernel synthesis for RapidDetect")
    parser.add_argument("--worker", type=str, default=None, help="Internal: build a single kernel in this process")
    parser.add_argument("--kernel", type=str, default=None, help="Build only the specified kernel")
    parser.add_argument("--jobs", type=int, default=None, help="Number of parallel synthesis jobs")
    args = parser.parse_args()

    # WORKER MODE: Called as a sub-process for a single kernel
    if args.worker:
        build_single_kernel_worker(args.worker)
        sys.exit(0)

    # ORCHESTRATOR MODE:
    os.makedirs(WORKSPACE_BASE, exist_ok=True)

    if args.kernel:
        target_kernels = [args.kernel]
    else:
        target_kernels = ALL_KERNELS

    # Concurrency limit (3-4 workers avoids OOM on 64GB machine with sm_kernel/nf_kernel)
    max_workers = args.jobs or int(os.environ.get("HLS_JOBS", min(4, os.cpu_count() or 4)))
    # Cap workers to number of targets
    max_workers = min(max_workers, len(target_kernels))

    print(f"============================================================")
    print(f" RapidDetect HLS Synthesis")
    print(f" Target Kernels ({len(target_kernels)}): {', '.join(target_kernels)}")
    print(f" Parallel Jobs: {max_workers}")
    print(f" Workspaces: {WORKSPACE_BASE}/<kernel_name>/")
    print(f"============================================================\n")

    failed = []
    if max_workers == 1:
        for k in target_kernels:
            _, success = launch_kernel_process(k)
            if not success:
                failed.append(k)
    else:
        with ProcessPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(launch_kernel_process, k): k for k in target_kernels}
            for future in as_completed(futures):
                kernel_name, success = future.result()
                if not success:
                    failed.append(kernel_name)

    if failed:
        print(f"\n[ERROR] Synthesis finished with failures in: {failed}")
        sys.exit(1)
    else:
        print(f"\n[SUCCESS] All {len(target_kernels)} kernels synthesized successfully under {WORKSPACE_BASE}/!")
        sys.exit(0)
