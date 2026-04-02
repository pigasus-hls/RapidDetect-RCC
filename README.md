# RapidDetect (MSPM) on V80

This version of RapidDetect is a 200Gbps hardware-accelerated threat detection system for streaming, structured system logs using [Sigma](https://github.com/sigmahq/sigma) rules. This repository, prepared for the FCCM 2026 Reconfigurable Computing Challenge, contains the Vitis HLS based implementation of the MSPM-only component of the full RapidDetect FPGA pipeline. The system is built for the V80 using AVED as a starting point and QDMA to move data and control information between the host and the FPGA. 

RapidDetect is an ongoing collaboration between [Shashank Obla](https://github.com/shashankov) and [James C. Hoe](https://users.ece.cmu.edu/~jhoe/doku/doku.php) from Carnegie Mellon University with [Tommy Tracy II](https://github.com/tjt7a), Wajih Ul Hassan and Kevin Skadron from the University of Virginia.

Inspired by [Pigasus Intrustion Prevention/Detection System](https://www.usenix.org/conference/osdi20/presentation/zhao-zhipeng), RapidDetect opts for a heterogeneous FPGA and CPU architecture for high-throughput, low-latency threat detection in streaming system logs. At a high-level the following diagram captures the system implemented in this repository (integration with Hyperscan is WIP):

![Block diagram showing various components of the system including the FPGA kernels, memory (DRAM and HBM), CPU side software and the communication channels](./assets/system.png "RapidDetect on V80 System Diagram")

More details on the application and the system can be found in the [System Description](./SYSTEM.md).

## Requirements

> [!NOTE]
> Only Vivado/Vitis are required to run MSPM in C-Simulation mode. Requires Version > 2024.2 for Python scripting support

> [!TIP]
> Make sure the submodule(s) get(s) populated using `git submodule update --init --recursive` after you clone the repo

### System Requirements (from AVED)

- RHEL 9.4 with Kernel 5.14, and Ubuntu 24.04 with Kernel 6.8

### Software Pre-requisites

- Python 3.6.8 or later (for AVED)
- Cmake 3.5.0 or later (for AVED)
- Vivado and Vitis 2025.1
- [Alveo Versal Example Design (AVED)](https://xilinx.github.io/AVED/latest/How-to%2Binstall%2Band%2Brun%2Ba%2Bpre-built%2BAVED%2Bdesign%2Bon%2Ban%2BALVEO%2Bcard.html). Make sure you [flash the pre-built design on the V80](https://xilinx.github.io/AVED/latest/AVED+Updating+FPT+Image+in+Flash.html) and install the software side AMI tool using the instructions in the link.
- [QDMA Linux Drivers](./dma_ip_drivers/QDMA/linux-kernel/) is submoduled in this repo and needs to be built and installed using the [instructions from AVED](https://xilinx.github.io/AVED/latest/AVED%2BQDMA.html) and the [QDMA Documentation](https://xilinx.github.io/dma_ip_drivers/master/QDMA/linux-kernel/html/build.html)

> [!IMPORTANT]
> Before building the DMA drivers, add the PCIe identifier into table at end of PF section at src/pci_ids.h as described in the [Installing section](https://xilinx.github.io/AVED/latest/AVED%2BQDMA.html#installing)

### IPs for AVED

Download SMBus IP from the [Alveo V80 Accelerator Card Early Access Site](https://www.xilinx.com/member/v80.html). Copy the IP into the AVED hardware design as noted by an asterisk in the directory tree below. This step is required before building the design.

```generic
hardware
└── AVED
    └── hw
        └── amd_v80_gen5x8_25.1
            └── src
                └── iprepo
                    ├── cmd_queue_v2_0
                    ├── hw_discovery_v1_0
                    ├── shell_utils_uuid_rom_v2_0
                    └── smbus_v1_1*
```

> [!NOTE]
> You might have to request access to the site in order to get access to the SMBus IP

> [!IMPORTANT]
> Building with the SMBus IP also requires the SMBus license from the [Xilinx Product Licensing Site](https://www.xilinx.com/getlicense) once you have access to the Early Access Site

## How to run RapidDetect

Set up the desired version of Vitis in your environment by sourcing the settings64.(c)sh script from your Vitis install directory `source settings64.sh`

### Running C Simulation

Run the C Simulation testbench by navigating to the [`hardware`](./hardware) directory and executing the testbench python script in Vitis

```bash
cd hardware
vitis -s scripts/rapidd_testbench.py
```

This will create a `hls_workspace` folder with the Vitis workspace and the testbench. The output of the script should look like

```bash
****** Vitis Development Environment
****** Vitis v2025.1 (64-bit)
  **** SW Build 6137779 on 2025-05-21-18:10:04
    ** Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
    ** Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.

Vitis Server started on port 'XXXXX'.
This can take a few minutes...
C Simulation output matches the golden output. Test PASSED.
```

### Building the HLS Kernels

Similar to the C Simulation all the HLS kernels can be built using the Python [script](./hardware/scripts/rapidd_synthesis.py) as follows:

```bash
cd hardware
vitis -s scripts/rapidd_synthesis.py
```

This will create all the kernels as components in the `hls_workspace` folder as the Vitis workspace and the testbench. This might take a while. Parameterization for the kernels can be modified in the Python [script](./hardware/scripts/rapidd_synthesis.py) directly.

You can view the workspace by opening it in Vitis

```bash
vitis -w ./hls_workspace
```

### Building the AVED Design with RapidDetect

These instructions very closely follow the steps from the [AVED documentation](https://xilinx.github.io/AVED/latest/How-to%2BRebuild%2Ban%2BAVED%2BDesign%2Bfor%2BYourself.html). The scripts have been modified to point to the HLS workspace, create a block design with the RapidDetect IPs connected to AVED and appropriate changes to the build flow to allow for timing closure. 

Navigate to the hardware directory and run the build_all.sh script to build the RapidDetect hardware.

```bash
cd hardware/AVED/hw/amd_v80_gen5x8_25.1
./build_all.sh
```

The build directory should contain the Vivado project. You can open this project (with the following command) to explore the Vivado Block Design for this build.

```bash
cd hardware/AVED/hw/amd_v80_gen5x8_25.1
vivado build/prj.xpr &
```

After the Vivado IDE launches with the specified project, find IP INTEGRATOR in the Flow Navigator pane, and click on “Open Block Design”.

### Programming the Design

You will use the AMI cfgmem_program command, specifying the card BDF, path to the design PDI, and which flash partition to program. In this example, the BDF is 01:00.0 (You can find the BDF of your device using this command: `lspci -k | grep -i xilinx -A 2`)

```bash
cd hardware/AVED/hw/amd_v80_gen5x8_25.1
sudo ami_tool cfgmem_program -d 01:00.0 -t primary -i ./build/amd_v80_gen5x8_25.1_nofpt.pdi -p 0
```

Successful programming is indicated by the message “OK. Image has been programmed successfully.” A hot reset is automatically performed to boot the updated design in partition 0. You can reset the PCIe and the driver using the AMI tool, and check whether the `qdma-pf` driver is loaded for the QDMA physical function using the following commands.

```bash
sudo ami_tool reload -d 01:00.1 -t driver
lspci -k | grep -i xilinx -A 2
```

> [!NOTE]
> The QDMA physical function (PF) has the function set to 1 in the BB:DD.F number

### Building and Compiling the Host Code

> [!IMPORTANT]
> Modify the PCIe BDF for your card installation in [setup_queues.sh](./software/setup_queues.sh) and [host.cpp](./software/host.cpp) within the software folder. The QDMA physical function (PF) has the function set to 1 in the BB:DD.F number

Setup the QDMA queues using the setup_queues.sh script.

```bash
cd software
sudo ./setup_queues.sh
```

Build the host code using make and run it. This will run the built in test on the FPGA.

```bash
make
./host.x
```

To run a real trace, first unzip the traces in the [traces directory](./traces) and execute the host code as follows:

```bash
make -C ../traces
./host.x ../traces/E5_cadets-deduplicated.json.500k
```

Expected performance is ~172Gbps (which includes packetization overhead of finding and splitting the log events at newline).
