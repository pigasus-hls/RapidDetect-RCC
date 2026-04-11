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

################################################################
# This is a generated script based on design: top
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_gid_msg -ssname BD::TCL -id 2040 -severity "WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been major IP version changes between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the parameter settings of the IPs."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source top_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:versal_cips:3.4\
xilinx.com:ip:axi_noc:1.1\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:emb_mem_gen:1.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:inline_hdl:ilconstant:1.0\
xilinx.com:ip:hw_discovery:1.0\
xilinx.com:ip:shell_utils_uuid_rom:2.0\
xilinx.com:ip:smbus:1.1\
xilinx.com:ip:cmd_queue:2.0\
xilinx.com:ip:clk_wizard:1.0\
xilinx.com:hls:sm_kernel:1.0\
xilinx.com:hls:payloadSourceKernel:1.0\
xilinx.com:hls:payloadReadKernel:1.0\
xilinx.com:hls:doneCountKernel:1.0\
xilinx.com:hls:resultSinkKernel:1.0\
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:hls:resultWriteKernel:1.0\
xilinx.com:hls:mergePipesKernel:1.0\
xilinx.com:hls:fieldMatchKernel:1.0\
xilinx.com:hls:fieldMatchFixOverflowKernel:1.0\
xilinx.com:hls:payloadWriteKernel:1.0\
xilinx.com:hls:smSteerPayloadKernel:1.0\
xilinx.com:inline_hdl:ilconcat:1.0\
xilinx.com:inline_hdl:ilreduced_logic:1.0\
xilinx.com:inline_hdl:ilvector_logic:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: pcie_mgmt_pdi_reset
proc create_hier_cell_pcie_mgmt_pdi_reset { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_pcie_mgmt_pdi_reset() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type rst resetn
  create_bd_pin -dir I -type rst resetn_in

  # Create instance: pcie_mgmt_pdi_reset_gpio, and set properties
  set pcie_mgmt_pdi_reset_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio pcie_mgmt_pdi_reset_gpio ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x00000000} \
    CONFIG.C_GPIO2_WIDTH {1} \
    CONFIG.C_GPIO_WIDTH {1} \
    CONFIG.C_IS_DUAL {1} \
  ] $pcie_mgmt_pdi_reset_gpio


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_0 ]

  # Create instance: ilreduced_logic_0, and set properties
  set ilreduced_logic_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic ilreduced_logic_0 ]
  set_property CONFIG.C_SIZE {2} $ilreduced_logic_0

  # Create instance: ilvector_logic_0, and set properties
  set ilvector_logic_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic ilvector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_0


  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins pcie_mgmt_pdi_reset_gpio/S_AXI]

  # Create port connections
  connect_bd_net -net clk_1  [get_bd_pins clk] \
  [get_bd_pins pcie_mgmt_pdi_reset_gpio/s_axi_aclk]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins ilreduced_logic_0/Op1]
  connect_bd_net -net ilreduced_logic_0_Res  [get_bd_pins ilreduced_logic_0/Res] \
  [get_bd_pins pcie_mgmt_pdi_reset_gpio/gpio2_io_i]
  connect_bd_net -net ilvector_logic_0_Res  [get_bd_pins ilvector_logic_0/Res] \
  [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net pcie_mgmt_pdi_reset_gpio_gpio_io_o  [get_bd_pins pcie_mgmt_pdi_reset_gpio/gpio_io_o] \
  [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net resetn_1  [get_bd_pins resetn] \
  [get_bd_pins pcie_mgmt_pdi_reset_gpio/s_axi_aresetn]
  connect_bd_net -net resetn_in_1  [get_bd_pins resetn_in] \
  [get_bd_pins ilvector_logic_0/Op1]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: RapidDetect
proc create_hier_cell_RapidDetect { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RapidDetect() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_control

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_control1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_control2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem1


  # Create pins
  create_bd_pin -dir I -type clk ap_clk
  create_bd_pin -dir I -type rst ap_rst_n
  create_bd_pin -dir I -type rst s_axis_aresetn

  # Create instance: sm_kernel_0, and set properties
  set sm_kernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:sm_kernel:1.0 sm_kernel_0 ]

  # Create instance: payloadSourceKernel_0, and set properties
  set payloadSourceKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:payloadSourceKernel:1.0 payloadSourceKernel_0 ]

  # Create instance: payloadReadKernel_0, and set properties
  set payloadReadKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:payloadReadKernel:1.0 payloadReadKernel_0 ]
  set_property -dict [list \
    CONFIG.C_M_AXI_GMEM0_DATA_WIDTH {256} \
    CONFIG.C_M_AXI_GMEM0_ENABLE_ID_PORTS {false} \
  ] $payloadReadKernel_0


  # Create instance: doneCountKernel_0, and set properties
  set doneCountKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:doneCountKernel:1.0 doneCountKernel_0 ]

  # Create instance: resultSinkKernel_0, and set properties
  set resultSinkKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:resultSinkKernel:1.0 resultSinkKernel_0 ]

  # Create instance: IoPayloadPipe, and set properties
  set IoPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {256} $IoPayloadPipe


  # Create instance: IoPayloadSplitPipe, and set properties
  set IoPayloadSplitPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadSplitPipe ]
  set_property CONFIG.FIFO_DEPTH {256} $IoPayloadSplitPipe


  # Create instance: IoDoneCountPipe, and set properties
  set IoDoneCountPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoDoneCountPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoDoneCountPipe


  # Create instance: SmInputPayloadPipe, and set properties
  set SmInputPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 SmInputPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $SmInputPayloadPipe


  # Create instance: SmMetaResultPipe, and set properties
  set SmMetaResultPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 SmMetaResultPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $SmMetaResultPipe


  # Create instance: IoBurstWritePipe, and set properties
  set IoBurstWritePipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoBurstWritePipe ]
  set_property CONFIG.FIFO_DEPTH {256} $IoBurstWritePipe


  # Create instance: IoResultCountPipe, and set properties
  set IoResultCountPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoResultCountPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoResultCountPipe


  # Create instance: IoInCountPipe, and set properties
  set IoInCountPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoInCountPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoInCountPipe


  # Create instance: resultWriteKernel_0, and set properties
  set resultWriteKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:resultWriteKernel:1.0 resultWriteKernel_0 ]

  # Create instance: mergePipesKernel_0, and set properties
  set mergePipesKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:mergePipesKernel:1.0 mergePipesKernel_0 ]

  # Create instance: IoPayloadMergedPipe, and set properties
  set IoPayloadMergedPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadMergedPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadMergedPipe


  # Create instance: fieldMatchKernel_0, and set properties
  set fieldMatchKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:fieldMatchKernel:1.0 fieldMatchKernel_0 ]

  # Create instance: fieldMatchFixOverflo_0, and set properties
  set fieldMatchFixOverflo_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:fieldMatchFixOverflowKernel:1.0 fieldMatchFixOverflo_0 ]

  # Create instance: IoPayloadFinalPipe, and set properties
  set IoPayloadFinalPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadFinalPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadFinalPipe


  # Create instance: IoPayloadFieldPipe, and set properties
  set IoPayloadFieldPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadFieldPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadFieldPipe


  # Create instance: payloadWriteKernel_0, and set properties
  set payloadWriteKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:payloadWriteKernel:1.0 payloadWriteKernel_0 ]

  # Create instance: smSteerPayloadKernel_0, and set properties
  set smSteerPayloadKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:smSteerPayloadKernel:1.0 smSteerPayloadKernel_0 ]

  # Create instance: SmForwardPayloadPipe, and set properties
  set SmForwardPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 SmForwardPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {2048} $SmForwardPayloadPipe


  # Create instance: HostPayloadPipe, and set properties
  set HostPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 HostPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $HostPayloadPipe


  # Create instance: HostMetaPipe, and set properties
  set HostMetaPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 HostMetaPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $HostMetaPipe


  # Create instance: IoPayloadCountPipe, and set properties
  set IoPayloadCountPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadCountPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadCountPipe


  # Create instance: IoPayloadDoneCountPipe, and set properties
  set IoPayloadDoneCountPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadDoneCountPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadDoneCountPipe


  # Create instance: SmSafePayloadPipe, and set properties
  set SmSafePayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 SmSafePayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $SmSafePayloadPipe


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins payloadReadKernel_0/m_axi_gmem0] [get_bd_intf_pins m_axi_gmem2]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins payloadReadKernel_0/m_axi_gmem1] [get_bd_intf_pins m_axi_gmem3]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins payloadReadKernel_0/s_axi_control] [get_bd_intf_pins s_axi_control]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins payloadWriteKernel_0/s_axi_control] [get_bd_intf_pins s_axi_control2]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins payloadWriteKernel_0/m_axi_gmem0] [get_bd_intf_pins m_axi_gmem1]
  connect_bd_intf_net -intf_net IoBurstWritePipe_M_AXIS [get_bd_intf_pins IoBurstWritePipe/M_AXIS] [get_bd_intf_pins resultWriteKernel_0/IoBurstWritePipe]
  connect_bd_intf_net -intf_net IoDoneCountPipe_M_AXIS [get_bd_intf_pins IoDoneCountPipe/M_AXIS] [get_bd_intf_pins resultSinkKernel_0/IoDoneCountPipe]
  connect_bd_intf_net -intf_net IoInCountPipe_M_AXIS [get_bd_intf_pins IoInCountPipe/M_AXIS] [get_bd_intf_pins doneCountKernel_0/IoInCountPipe]
  connect_bd_intf_net -intf_net IoPayloadCountPipe_M_AXIS [get_bd_intf_pins IoPayloadCountPipe/M_AXIS] [get_bd_intf_pins doneCountKernel_0/IoPayloadCountPipe]
  connect_bd_intf_net -intf_net IoPayloadDoneCountPipe_M_AXIS [get_bd_intf_pins IoPayloadDoneCountPipe/M_AXIS] [get_bd_intf_pins payloadWriteKernel_0/IoPayloadDoneCountPipe]
  connect_bd_intf_net -intf_net IoPayloadFieldPipe_M_AXIS [get_bd_intf_pins IoPayloadFieldPipe/M_AXIS] [get_bd_intf_pins fieldMatchFixOverflo_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadFinalPipe_M_AXIS [get_bd_intf_pins IoPayloadFinalPipe/M_AXIS] [get_bd_intf_pins payloadSourceKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadMergedPipe_M_AXIS [get_bd_intf_pins IoPayloadMergedPipe/M_AXIS] [get_bd_intf_pins fieldMatchKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadPipe_M_AXIS [get_bd_intf_pins IoPayloadPipe/M_AXIS] [get_bd_intf_pins mergePipesKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadSplitPipe_M_AXIS [get_bd_intf_pins IoPayloadSplitPipe/M_AXIS] [get_bd_intf_pins mergePipesKernel_0/PayloadInSplitPipe]
  connect_bd_intf_net -intf_net IoResultCountPipe_M_AXIS [get_bd_intf_pins IoResultCountPipe/M_AXIS] [get_bd_intf_pins doneCountKernel_0/IoResultCountPipe]
  connect_bd_intf_net -intf_net MetaOutPipe_M_AXIS [get_bd_intf_pins HostMetaPipe/M_AXIS] [get_bd_intf_pins resultSinkKernel_0/RidMetaInPipe]
  connect_bd_intf_net -intf_net PayloadSinkPipe_M_AXIS [get_bd_intf_pins HostPayloadPipe/M_AXIS] [get_bd_intf_pins payloadWriteKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net SmForwardPayloadPipe_M_AXIS [get_bd_intf_pins SmForwardPayloadPipe/M_AXIS] [get_bd_intf_pins smSteerPayloadKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net SmInputPayloadPipe_M_AXIS [get_bd_intf_pins SmInputPayloadPipe/M_AXIS] [get_bd_intf_pins sm_kernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net SmMetaResultPipe_M_AXIS [get_bd_intf_pins SmMetaResultPipe/M_AXIS] [get_bd_intf_pins smSteerPayloadKernel_0/RidMetaInPipe]
  connect_bd_intf_net -intf_net SmSafePayloadPipe_M_AXIS [get_bd_intf_pins SmSafePayloadPipe/M_AXIS] [get_bd_intf_pins doneCountKernel_0/SmPayloadSafePipe]
  connect_bd_intf_net -intf_net doneCountKernel_0_IoDoneCountPipe [get_bd_intf_pins doneCountKernel_0/IoDoneCountPipe] [get_bd_intf_pins IoDoneCountPipe/S_AXIS]
  connect_bd_intf_net -intf_net doneCountKernel_0_IoPayloadDoneCountPipe [get_bd_intf_pins doneCountKernel_0/IoPayloadDoneCountPipe] [get_bd_intf_pins IoPayloadDoneCountPipe/S_AXIS]
  connect_bd_intf_net -intf_net fieldMatchFixOverflo_0_PayloadOutPipe [get_bd_intf_pins fieldMatchFixOverflo_0/PayloadOutPipe] [get_bd_intf_pins IoPayloadFinalPipe/S_AXIS]
  connect_bd_intf_net -intf_net fieldMatchKernel_0_PayloadOutPipe [get_bd_intf_pins fieldMatchKernel_0/PayloadOutPipe] [get_bd_intf_pins IoPayloadFieldPipe/S_AXIS]
  connect_bd_intf_net -intf_net mergePipesKernel_0_PayloadOutPipe [get_bd_intf_pins mergePipesKernel_0/PayloadOutPipe] [get_bd_intf_pins IoPayloadMergedPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadReadKernel_0_IoInCountPipe [get_bd_intf_pins payloadReadKernel_0/IoInCountPipe] [get_bd_intf_pins IoInCountPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadReadKernel_0_PayloadOutPipe [get_bd_intf_pins payloadReadKernel_0/PayloadOutPipe] [get_bd_intf_pins IoPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadReadKernel_0_PayloadOutSplitPipe [get_bd_intf_pins payloadReadKernel_0/PayloadOutSplitPipe] [get_bd_intf_pins IoPayloadSplitPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadSourceKernel_0_PayloadForwardPipe [get_bd_intf_pins payloadSourceKernel_0/PayloadForwardPipe] [get_bd_intf_pins SmForwardPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadSourceKernel_0_PayloadOutPipe [get_bd_intf_pins payloadSourceKernel_0/PayloadOutPipe] [get_bd_intf_pins SmInputPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadWriteKernel_0_IoPayloadCountPipe [get_bd_intf_pins payloadWriteKernel_0/IoPayloadCountPipe] [get_bd_intf_pins IoPayloadCountPipe/S_AXIS]
  connect_bd_intf_net -intf_net resultSinkKernel_0_IoBurstWritePipe [get_bd_intf_pins resultSinkKernel_0/IoBurstWritePipe] [get_bd_intf_pins IoBurstWritePipe/S_AXIS]
  connect_bd_intf_net -intf_net resultSinkKernel_0_IoResultCountPipe [get_bd_intf_pins resultSinkKernel_0/IoResultCountPipe] [get_bd_intf_pins IoResultCountPipe/S_AXIS]
  connect_bd_intf_net -intf_net resultWriteKernel_0_m_axi_gmem0 [get_bd_intf_pins m_axi_gmem0] [get_bd_intf_pins resultWriteKernel_0/m_axi_gmem0]
  connect_bd_intf_net -intf_net s_axi_control1_1 [get_bd_intf_pins s_axi_control1] [get_bd_intf_pins resultWriteKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smSteerPayloadKernel_0_PayloadMatchPipe [get_bd_intf_pins smSteerPayloadKernel_0/PayloadMatchPipe] [get_bd_intf_pins PayloadSinkPipe/S_AXIS]
  connect_bd_intf_net -intf_net smSteerPayloadKernel_0_PayloadSafePipe [get_bd_intf_pins smSteerPayloadKernel_0/PayloadSafePipe] [get_bd_intf_pins SmSafePayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net smSteerPayloadKernel_0_RidMetaOutPipe [get_bd_intf_pins smSteerPayloadKernel_0/RidMetaOutPipe] [get_bd_intf_pins MetaOutPipe/S_AXIS]
  connect_bd_intf_net -intf_net sm_kernel_0_ResultOutPipe [get_bd_intf_pins sm_kernel_0/ResultOutPipe] [get_bd_intf_pins SmMetaResultPipe/S_AXIS]

  # Create port connections
  connect_bd_net -net ap_clk_1  [get_bd_pins ap_clk] \
  [get_bd_pins IoInCountPipe/s_axis_aclk] \
  [get_bd_pins IoResultCountPipe/s_axis_aclk] \
  [get_bd_pins IoDoneCountPipe/s_axis_aclk] \
  [get_bd_pins IoBurstWritePipe/s_axis_aclk] \
  [get_bd_pins IoPayloadPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadSplitPipe/s_axis_aclk] \
  [get_bd_pins SmInputPayloadPipe/s_axis_aclk] \
  [get_bd_pins SmMetaResultPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadMergedPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadFieldPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadFinalPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadCountPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadDoneCountPipe/s_axis_aclk] \
  [get_bd_pins HostMetaPipe/s_axis_aclk] \
  [get_bd_pins HostPayloadPipe/s_axis_aclk] \
  [get_bd_pins SmForwardPayloadPipe/s_axis_aclk] \
  [get_bd_pins SmSafePayloadPipe/s_axis_aclk] \
  [get_bd_pins doneCountKernel_0/ap_clk] \
  [get_bd_pins fieldMatchFixOverflo_0/ap_clk] \
  [get_bd_pins fieldMatchKernel_0/ap_clk] \
  [get_bd_pins mergePipesKernel_0/ap_clk] \
  [get_bd_pins payloadReadKernel_0/ap_clk] \
  [get_bd_pins payloadSourceKernel_0/ap_clk] \
  [get_bd_pins payloadWriteKernel_0/ap_clk] \
  [get_bd_pins resultSinkKernel_0/ap_clk] \
  [get_bd_pins resultWriteKernel_0/ap_clk] \
  [get_bd_pins smSteerPayloadKernel_0/ap_clk] \
  [get_bd_pins sm_kernel_0/ap_clk]
  connect_bd_net -net ap_rst_n_1  [get_bd_pins ap_rst_n] \
  [get_bd_pins IoInCountPipe/s_axis_aresetn] \
  [get_bd_pins IoResultCountPipe/s_axis_aresetn] \
  [get_bd_pins IoDoneCountPipe/s_axis_aresetn] \
  [get_bd_pins IoBurstWritePipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadSplitPipe/s_axis_aresetn] \
  [get_bd_pins SmInputPayloadPipe/s_axis_aresetn] \
  [get_bd_pins SmMetaResultPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadMergedPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadFieldPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadFinalPipe/s_axis_aresetn] \
  [get_bd_pins doneCountKernel_0/ap_rst_n] \
  [get_bd_pins fieldMatchFixOverflo_0/ap_rst_n] \
  [get_bd_pins fieldMatchKernel_0/ap_rst_n] \
  [get_bd_pins mergePipesKernel_0/ap_rst_n] \
  [get_bd_pins payloadReadKernel_0/ap_rst_n] \
  [get_bd_pins payloadSourceKernel_0/ap_rst_n] \
  [get_bd_pins resultSinkKernel_0/ap_rst_n] \
  [get_bd_pins resultWriteKernel_0/ap_rst_n] \
  [get_bd_pins sm_kernel_0/ap_rst_n]
  connect_bd_net -net s_axis_aresetn_1  [get_bd_pins s_axis_aresetn] \
  [get_bd_pins IoPayloadCountPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadDoneCountPipe/s_axis_aresetn] \
  [get_bd_pins HostMetaPipe/s_axis_aresetn] \
  [get_bd_pins HostPayloadPipe/s_axis_aresetn] \
  [get_bd_pins SmForwardPayloadPipe/s_axis_aresetn] \
  [get_bd_pins SmSafePayloadPipe/s_axis_aresetn] \
  [get_bd_pins payloadWriteKernel_0/ap_rst_n] \
  [get_bd_pins smSteerPayloadKernel_0/ap_rst_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_reset
proc create_hier_cell_clock_reset { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_reset() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pcie_mgmt_pdi_reset


  # Create pins
  create_bd_pin -dir I -type clk clk_pl
  create_bd_pin -dir I -type clk clk_freerun
  create_bd_pin -dir I -type clk clk_pcie
  create_bd_pin -dir I -type rst dma_axi_aresetn
  create_bd_pin -dir I -type rst resetn_pl_axi
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pcie_ic
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pcie_periph
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_ic
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_periph
  create_bd_pin -dir O -type clk clk_usr_0
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_usr_0_ic
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_usr_0_periph
  create_bd_pin -dir O -type clk clk_usr_1
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_usr_1_ic
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_usr_1_periph

  # Create instance: pcie_psr, and set properties
  set pcie_psr [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pcie_psr ]
  set_property CONFIG.C_EXT_RST_WIDTH {1} $pcie_psr


  # Create instance: pl_psr, and set properties
  set pl_psr [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pl_psr ]
  set_property CONFIG.C_EXT_RST_WIDTH {1} $pl_psr


  # Create instance: usr_clk_wiz, and set properties
  set usr_clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard usr_clk_wiz ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {No_buffer,No_buffer} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {400,500} \
    CONFIG.CLKOUT_USED {true,true} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.USE_DYN_RECONFIG {false} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_POWER_DOWN {false} \
    CONFIG.USE_RESET {false} \
  ] $usr_clk_wiz


  # Create instance: usr_0_psr, and set properties
  set usr_0_psr [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset usr_0_psr ]
  set_property CONFIG.C_EXT_RST_WIDTH {1} $usr_0_psr


  # Create instance: usr_1_psr, and set properties
  set usr_1_psr [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset usr_1_psr ]
  set_property CONFIG.C_EXT_RST_WIDTH {1} $usr_1_psr


  # Create instance: pcie_mgmt_pdi_reset
  create_hier_cell_pcie_mgmt_pdi_reset $hier_obj pcie_mgmt_pdi_reset

  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_pcie_mgmt_pdi_reset_1 [get_bd_intf_pins s_axi_pcie_mgmt_pdi_reset] [get_bd_intf_pins pcie_mgmt_pdi_reset/s_axi]

  # Create port connections
  connect_bd_net -net clk_freerun_1  [get_bd_pins clk_freerun] \
  [get_bd_pins usr_clk_wiz/clk_in1]
  connect_bd_net -net clk_pcie_1  [get_bd_pins clk_pcie] \
  [get_bd_pins pcie_psr/slowest_sync_clk]
  connect_bd_net -net clk_pl_1  [get_bd_pins clk_pl] \
  [get_bd_pins pl_psr/slowest_sync_clk] \
  [get_bd_pins pcie_mgmt_pdi_reset/clk]
  connect_bd_net -net dma_axi_aresetn_1  [get_bd_pins dma_axi_aresetn] \
  [get_bd_pins pcie_mgmt_pdi_reset/resetn_in]
  connect_bd_net -net pcie_psr_interconnect_aresetn  [get_bd_pins pcie_psr/interconnect_aresetn] \
  [get_bd_pins resetn_pcie_ic]
  connect_bd_net -net pcie_psr_peripheral_aresetn  [get_bd_pins pcie_psr/peripheral_aresetn] \
  [get_bd_pins resetn_pcie_periph]
  connect_bd_net -net pl_psr_interconnect_aresetn  [get_bd_pins pl_psr/interconnect_aresetn] \
  [get_bd_pins resetn_pl_ic] \
  [get_bd_pins pcie_psr/ext_reset_in] \
  [get_bd_pins usr_0_psr/ext_reset_in] \
  [get_bd_pins usr_1_psr/ext_reset_in]
  connect_bd_net -net pl_psr_peripheral_aresetn  [get_bd_pins pl_psr/peripheral_aresetn] \
  [get_bd_pins resetn_pl_periph] \
  [get_bd_pins pcie_mgmt_pdi_reset/resetn]
  connect_bd_net -net resetn_pl_axi_1  [get_bd_pins resetn_pl_axi] \
  [get_bd_pins pl_psr/ext_reset_in]
  connect_bd_net -net usr_0_psr_interconnect_aresetn  [get_bd_pins usr_0_psr/interconnect_aresetn] \
  [get_bd_pins resetn_usr_0_ic]
  connect_bd_net -net usr_0_psr_peripheral_aresetn  [get_bd_pins usr_0_psr/peripheral_aresetn] \
  [get_bd_pins resetn_usr_0_periph]
  connect_bd_net -net usr_1_psr_interconnect_aresetn  [get_bd_pins usr_1_psr/interconnect_aresetn] \
  [get_bd_pins resetn_usr_1_ic]
  connect_bd_net -net usr_1_psr_peripheral_aresetn  [get_bd_pins usr_1_psr/peripheral_aresetn] \
  [get_bd_pins resetn_usr_1_periph]
  connect_bd_net -net usr_clk_wiz_clk_out1  [get_bd_pins usr_clk_wiz/clk_out1] \
  [get_bd_pins clk_usr_0] \
  [get_bd_pins usr_0_psr/slowest_sync_clk]
  connect_bd_net -net usr_clk_wiz_clk_out2  [get_bd_pins usr_clk_wiz/clk_out2] \
  [get_bd_pins clk_usr_1] \
  [get_bd_pins usr_1_psr/slowest_sync_clk]
  connect_bd_net -net usr_clk_wiz_locked  [get_bd_pins usr_clk_wiz/locked] \
  [get_bd_pins usr_0_psr/dcm_locked] \
  [get_bd_pins usr_1_psr/dcm_locked]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: base_logic
proc create_hier_cell_base_logic { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_base_logic() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pcie_mgmt_slr0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_rpu

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie3_cfg_ext_rtl:1.0 pcie_cfg_ext

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 smbus_rpu

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_pcie_mgmt_pdi_reset


  # Create pins
  create_bd_pin -dir I -type clk clk_pcie
  create_bd_pin -dir I -type clk clk_pl
  create_bd_pin -dir I -type rst resetn_pcie_periph
  create_bd_pin -dir I -type rst resetn_pl_periph
  create_bd_pin -dir I -type rst resetn_pl_ic
  create_bd_pin -dir O -type intr irq_gcq_m2r
  create_bd_pin -dir O -type intr irq_axi_smbus_rpu

  # Create instance: pcie_slr0_mgmt_sc, and set properties
  set pcie_slr0_mgmt_sc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect pcie_slr0_mgmt_sc ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
  ] $pcie_slr0_mgmt_sc


  # Create instance: rpu_sc, and set properties
  set rpu_sc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect rpu_sc ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $rpu_sc


  # Create instance: hw_discovery, and set properties
  set hw_discovery [ create_bd_cell -type ip -vlnv xilinx.com:ip:hw_discovery:1.0 hw_discovery ]
  set_property -dict [list \
    CONFIG.C_CAP_BASE_ADDR {0x600} \
    CONFIG.C_INJECT_ENDPOINTS {0} \
    CONFIG.C_MANUAL {1} \
    CONFIG.C_NEXT_CAP_ADDR {0x000} \
    CONFIG.C_NUM_PFS {1} \
    CONFIG.C_PF0_BAR_INDEX {0} \
    CONFIG.C_PF0_ENDPOINT_NAMES {0} \
    CONFIG.C_PF0_ENTRY_ADDR_0 {0x000001001000} \
    CONFIG.C_PF0_ENTRY_ADDR_1 {0x000001010000} \
    CONFIG.C_PF0_ENTRY_ADDR_2 {0x000008000000} \
    CONFIG.C_PF0_ENTRY_BAR_0 {0} \
    CONFIG.C_PF0_ENTRY_BAR_1 {0} \
    CONFIG.C_PF0_ENTRY_BAR_2 {0} \
    CONFIG.C_PF0_ENTRY_MAJOR_VERSION_0 {1} \
    CONFIG.C_PF0_ENTRY_MAJOR_VERSION_1 {1} \
    CONFIG.C_PF0_ENTRY_MAJOR_VERSION_2 {1} \
    CONFIG.C_PF0_ENTRY_MINOR_VERSION_0 {0} \
    CONFIG.C_PF0_ENTRY_MINOR_VERSION_1 {2} \
    CONFIG.C_PF0_ENTRY_MINOR_VERSION_2 {0} \
    CONFIG.C_PF0_ENTRY_RSVD0_0 {0x0} \
    CONFIG.C_PF0_ENTRY_RSVD0_1 {0x0} \
    CONFIG.C_PF0_ENTRY_RSVD0_2 {0x0} \
    CONFIG.C_PF0_ENTRY_TYPE_0 {0x50} \
    CONFIG.C_PF0_ENTRY_TYPE_1 {0x54} \
    CONFIG.C_PF0_ENTRY_TYPE_2 {0x55} \
    CONFIG.C_PF0_ENTRY_VERSION_TYPE_0 {0x01} \
    CONFIG.C_PF0_ENTRY_VERSION_TYPE_1 {0x01} \
    CONFIG.C_PF0_ENTRY_VERSION_TYPE_2 {0x01} \
    CONFIG.C_PF0_HIGH_OFFSET {0x00000000} \
    CONFIG.C_PF0_LOW_OFFSET {0x0100000} \
    CONFIG.C_PF0_NUM_SLOTS_BAR_LAYOUT_TABLE {3} \
    CONFIG.C_PF0_S_AXI_ADDR_WIDTH {32} \
  ] $hw_discovery


  # Create instance: uuid_rom, and set properties
  set uuid_rom [ create_bd_cell -type ip -vlnv xilinx.com:ip:shell_utils_uuid_rom uuid_rom ]
  set_property CONFIG.C_INITIAL_UUID {00000000000000000000000000000000} $uuid_rom


  # Create instance: axi_smbus_rpu, and set properties
  set axi_smbus_rpu [ create_bd_cell -type ip -vlnv xilinx.com:ip:smbus axi_smbus_rpu ]
  set_property -dict [list \
    CONFIG.NUM_TARGET_DEVICES {8} \
    CONFIG.SMBUS_DEV_CLASS {0} \
  ] $axi_smbus_rpu


  # Create instance: gcq_m2r, and set properties
  set gcq_m2r [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmd_queue gcq_m2r ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_smbus_rpu_SMBUS [get_bd_intf_pins axi_smbus_rpu/SMBUS] [get_bd_intf_pins smbus_rpu]
  connect_bd_intf_net -intf_net pcie_cfg_ext_1 [get_bd_intf_pins pcie_cfg_ext] [get_bd_intf_pins hw_discovery/s_pcie4_cfg_ext]
  connect_bd_intf_net -intf_net pcie_slr0_mgmt_sc_M00_AXI [get_bd_intf_pins pcie_slr0_mgmt_sc/M00_AXI] [get_bd_intf_pins hw_discovery/s_axi_ctrl_pf0]
  connect_bd_intf_net -intf_net pcie_slr0_mgmt_sc_M01_AXI [get_bd_intf_pins pcie_slr0_mgmt_sc/M01_AXI] [get_bd_intf_pins uuid_rom/S_AXI]
  connect_bd_intf_net -intf_net pcie_slr0_mgmt_sc_M02_AXI [get_bd_intf_pins pcie_slr0_mgmt_sc/M02_AXI] [get_bd_intf_pins gcq_m2r/S00_AXI]
  connect_bd_intf_net -intf_net pcie_slr0_mgmt_sc_M03_AXI [get_bd_intf_pins pcie_slr0_mgmt_sc/M03_AXI] [get_bd_intf_pins m_axi_pcie_mgmt_pdi_reset]
  connect_bd_intf_net -intf_net rpu_sc_M00_AXI [get_bd_intf_pins rpu_sc/M00_AXI] [get_bd_intf_pins gcq_m2r/S01_AXI]
  connect_bd_intf_net -intf_net rpu_sc_M01_AXI [get_bd_intf_pins axi_smbus_rpu/S_AXI] [get_bd_intf_pins rpu_sc/M01_AXI]
  connect_bd_intf_net -intf_net s_axi_pcie_mgmt_slr0_1 [get_bd_intf_pins s_axi_pcie_mgmt_slr0] [get_bd_intf_pins pcie_slr0_mgmt_sc/S00_AXI]
  connect_bd_intf_net -intf_net s_axi_rpu_1 [get_bd_intf_pins s_axi_rpu] [get_bd_intf_pins rpu_sc/S00_AXI]

  # Create port connections
  connect_bd_net -net axi_smbus_rpu_ip2intc_irpt  [get_bd_pins axi_smbus_rpu/ip2intc_irpt] \
  [get_bd_pins irq_axi_smbus_rpu]
  connect_bd_net -net clk_pcie_1  [get_bd_pins clk_pcie] \
  [get_bd_pins hw_discovery/aclk_pcie]
  connect_bd_net -net clk_pl_1  [get_bd_pins clk_pl] \
  [get_bd_pins pcie_slr0_mgmt_sc/aclk] \
  [get_bd_pins rpu_sc/aclk] \
  [get_bd_pins axi_smbus_rpu/s_axi_aclk] \
  [get_bd_pins gcq_m2r/aclk] \
  [get_bd_pins hw_discovery/aclk_ctrl] \
  [get_bd_pins uuid_rom/S_AXI_ACLK]
  connect_bd_net -net gcq_m2r_irq_sq  [get_bd_pins gcq_m2r/irq_sq] \
  [get_bd_pins irq_gcq_m2r]
  connect_bd_net -net resetn_pcie_periph_1  [get_bd_pins resetn_pcie_periph] \
  [get_bd_pins hw_discovery/aresetn_pcie]
  connect_bd_net -net resetn_pl_ic_1  [get_bd_pins resetn_pl_ic] \
  [get_bd_pins pcie_slr0_mgmt_sc/aresetn] \
  [get_bd_pins rpu_sc/aresetn]
  connect_bd_net -net resetn_pl_periph_1  [get_bd_pins resetn_pl_periph] \
  [get_bd_pins axi_smbus_rpu/s_axi_aresetn] \
  [get_bd_pins gcq_m2r/aresetn] \
  [get_bd_pins hw_discovery/aresetn_ctrl] \
  [get_bd_pins uuid_rom/S_AXI_ARESETN]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set CH0_DDR4_0_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_0 ]

  set sys_clk0_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $sys_clk0_0

  set CH0_DDR4_0_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_1 ]

  set sys_clk0_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $sys_clk0_1

  set hbm_ref_clk_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $hbm_ref_clk_0

  set hbm_ref_clk_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $hbm_ref_clk_1

# Uncomment qsfp and mcio ports as required by design
#  set qsfp0_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_4x ]
#
#  set qsfp1_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp1_4x ]
#
#  set qsfp2_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp2_4x ]
#
#  set qsfp3_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp3_4x ]
#
#  set qsfp0_322mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {322265625} \
#   ] $qsfp0_322mhz
#
#  set qsfp2_322mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp2_322mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {322265625} \
#   ] $qsfp2_322mhz
#
#  set mcio0_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio0_4x ]
#
#  set mcio1_a_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio1_a_4x ]
#
#  set mcio1_b_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio1_b_4x ]
#
#  set mcio2_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio2_4x ]
#
#  set mcio0_100mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 mcio0_100mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {100000000} \
#   ] $mcio0_100mhz
#
#  set mcio1_100mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 mcio1_100mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {100000000} \
#   ] $mcio1_100mhz
#
#  set mcio2_100mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 mcio2_100mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {100000000} \
#   ] $mcio2_100mhz

  set gt_pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_pcie_refclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $gt_pcie_refclk

  set gt_pciea1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_pciea1 ]

  set smbus_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 smbus_0 ]


  # Create ports

  # Create instance: cips, and set properties
  set cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips cips ]
  set_property -dict [list \
    CONFIG.CPM_CONFIG { \
      CPM_PCIE0_MODES {None} \
      CPM_PCIE1_ACS_CAP_ON {0} \
      CPM_PCIE1_ARI_CAP_ENABLED {1} \
      CPM_PCIE1_CFG_EXT_IF {1} \
      CPM_PCIE1_CFG_VEND_ID {10ee} \
      CPM_PCIE1_COPY_PF0_QDMA_ENABLED {0} \
      CPM_PCIE1_DMA_INTF {AXI4} \
      CPM_PCIE1_EXT_PCIE_CFG_SPACE_ENABLED {Extended_Large} \
      CPM_PCIE1_FUNCTIONAL_MODE {QDMA} \
      CPM_PCIE1_MAX_LINK_SPEED {32.0_GT/s} \
      CPM_PCIE1_MODES {DMA} \
      CPM_PCIE1_MODE_SELECTION {Advanced} \
      CPM_PCIE1_MSI_X_OPTIONS {MSI-X_Internal} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_0 {0x0000008000000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_1 {0x0000008040000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_2 {0x0000008080000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_3 {0x00000080C0000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_4 {0x0000008100000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_5 {0x0000008140000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_0 {0x000000803FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_1 {0x000000807FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_2 {0x00000080BFFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_3 {0x00000080FFFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_4 {0x000000813FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_5 {0x000000817FFFFFFFF} \
      CPM_PCIE1_PF0_BAR0_QDMA_64BIT {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_ENABLED {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_PREFETCHABLE {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_SCALE {Megabytes} \
      CPM_PCIE1_PF0_BAR0_QDMA_SIZE {256} \
      CPM_PCIE1_PF0_BAR0_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF0_BAR2_QDMA_64BIT {0} \
      CPM_PCIE1_PF0_BAR2_QDMA_ENABLED {0} \
      CPM_PCIE1_PF0_BAR2_QDMA_PREFETCHABLE {0} \
      CPM_PCIE1_PF0_BAR2_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF0_BAR2_QDMA_SIZE {4} \
      CPM_PCIE1_PF0_BAR2_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF0_BASE_CLASS_VALUE {12} \
      CPM_PCIE1_PF0_CFG_DEV_ID {50b4} \
      CPM_PCIE1_PF0_CFG_SUBSYS_ID {000e} \
      CPM_PCIE1_PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE {0} \
      CPM_PCIE1_PF0_MSIX_CAP_TABLE_OFFSET {40} \
      CPM_PCIE1_PF0_MSIX_CAP_TABLE_SIZE {1} \
      CPM_PCIE1_PF0_MSIX_ENABLED {0} \
      CPM_PCIE1_PF0_PCIEBAR2AXIBAR_QDMA_0 {0x0000020100000000} \
      CPM_PCIE1_PF0_SUB_CLASS_VALUE {00} \
      CPM_PCIE1_PF1_BAR0_QDMA_64BIT {1} \
      CPM_PCIE1_PF1_BAR0_QDMA_ENABLED {1} \
      CPM_PCIE1_PF1_BAR0_QDMA_PREFETCHABLE {1} \
      CPM_PCIE1_PF1_BAR0_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF1_BAR0_QDMA_SIZE {512} \
      CPM_PCIE1_PF1_BAR0_QDMA_TYPE {DMA} \
      CPM_PCIE1_PF1_BAR2_QDMA_64BIT {0} \
      CPM_PCIE1_PF1_BAR2_QDMA_ENABLED {1} \
      CPM_PCIE1_PF1_BAR2_QDMA_PREFETCHABLE {0} \
      CPM_PCIE1_PF1_BAR2_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF1_BAR2_QDMA_SIZE {16} \
      CPM_PCIE1_PF1_BAR2_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF1_BASE_CLASS_VALUE {12} \
      CPM_PCIE1_PF1_CFG_DEV_ID {50b5} \
      CPM_PCIE1_PF1_CFG_SUBSYS_ID {000e} \
      CPM_PCIE1_PF1_CFG_SUBSYS_VEND_ID {10EE} \
      CPM_PCIE1_PF1_MSIX_CAP_TABLE_OFFSET {50000} \
      CPM_PCIE1_PF1_MSIX_CAP_TABLE_SIZE {8} \
      CPM_PCIE1_PF1_MSIX_ENABLED {1} \
      CPM_PCIE1_PF1_PCIEBAR2AXIBAR_QDMA_2 {0x0000020200000000} \
      CPM_PCIE1_PF1_SUB_CLASS_VALUE {00} \
      CPM_PCIE1_PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
      CPM_PCIE1_TL_PF_ENABLE_REG {2} \
    } \
    CONFIG.PS_PMC_CONFIG { \
      BOOT_MODE {Custom} \
      CLOCK_MODE {Custom} \
      DDR_MEMORY_MODE {Custom} \
      DESIGN_MODE {1} \
      DEVICE_INTEGRITY_MODE {Custom} \
      IO_CONFIG_MODE {Custom} \
      PCIE_APERTURES_DUAL_ENABLE {0} \
      PCIE_APERTURES_SINGLE_ENABLE {1} \
      PMC_BANK_1_IO_STANDARD {LVCMOS3.3} \
      PMC_CRP_OSPI_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
      PMC_CRP_PL1_REF_CTRL_FREQMHZ {33.3333333} \
      PMC_CRP_PL2_REF_CTRL_FREQMHZ {250} \
      PMC_GLITCH_CONFIG {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_1 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_2 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
      PMC_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO12 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO13 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO17 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO26 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO27 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO28 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO29 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO30 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO31 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO32 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO33 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO34 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO35 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO36 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO37 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO38 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO39 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO40 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO41 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO42 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO43 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO44 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO48 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO49 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO50 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO51 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO_EN_FOR_PL_PCIE {0} \
      PMC_OSPI_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 0 .. 11}} {MODE Single}} \
      PMC_REF_CLK_FREQMHZ {33.333333} \
      PMC_SD0_DATA_TRANSFER_MODE {8Bit} \
      PMC_SD0_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x2} {CLK_50_DDR_ITAP_DLY 0x1E} {CLK_50_DDR_OTAP_DLY 0x5} {CLK_50_SDR_ITAP_DLY 0x2C} {CLK_50_SDR_OTAP_DLY 0x5} {ENABLE 1} {IO\
{PMC_MIO 13 .. 25}}} \
      PMC_SD0_SLOT_TYPE {eMMC} \
      PMC_USE_PMC_NOC_AXI0 {1} \
      PS_BANK_2_IO_STANDARD {LVCMOS3.3} \
      PS_BOARD_INTERFACE {Custom} \
      PS_CRL_CPM_TOPSW_REF_CTRL_FREQMHZ {1000} \
      PS_GEN_IPI0_ENABLE {0} \
      PS_GEN_IPI1_ENABLE {0} \
      PS_GEN_IPI2_ENABLE {0} \
      PS_GEN_IPI3_ENABLE {1} \
      PS_GEN_IPI3_MASTER {R5_0} \
      PS_GEN_IPI4_ENABLE {1} \
      PS_GEN_IPI4_MASTER {R5_0} \
      PS_GEN_IPI5_ENABLE {1} \
      PS_GEN_IPI5_MASTER {R5_1} \
      PS_GEN_IPI6_ENABLE {1} \
      PS_GEN_IPI6_MASTER {R5_1} \
      PS_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
      PS_I2C0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 2 .. 3}}} \
      PS_I2C1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 0 .. 1}}} \
      PS_IRQ_USAGE {{CH0 1} {CH1 1} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}} \
      PS_KAT_ENABLE {0} \
      PS_KAT_ENABLE_1 {0} \
      PS_KAT_ENABLE_2 {0} \
      PS_MIO10 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO12 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO13 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO14 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO18 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO19 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO22 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO23 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO24 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO25 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO4 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO5 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO6 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO7 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO8 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO9 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PS_M_AXI_LPD_DATA_WIDTH {32} \
      PS_NUM_FABRIC_RESETS {1} \
      PS_PCIE1_PERIPHERAL_ENABLE {0} \
      PS_PCIE2_PERIPHERAL_ENABLE {1} \
      PS_PCIE_EP_RESET1_IO {PMC_MIO 24} \
      PS_PCIE_EP_RESET2_IO {PMC_MIO 25} \
      PS_PCIE_RESET {{ENABLE 1}} \
      PS_PL_CONNECTIVITY_MODE {Custom} \
      PS_SPI0 {{GRP_SS0_ENABLE 1} {GRP_SS0_IO {PS_MIO 15}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PMC_MIO 14}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PMC_MIO 13}} {PERIPHERAL_ENABLE 1} {PERIPHERAL_IO {PS_MIO 12 .. 17}}}\
\
      PS_SPI1 {{GRP_SS0_ENABLE 0} {GRP_SS0_IO {PS_MIO 9}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PS_MIO 8}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PS_MIO 7}} {PERIPHERAL_ENABLE 0} {PERIPHERAL_IO {PS_MIO 6 .. 11}}} \
      PS_TTC0_PERIPHERAL_ENABLE {1} \
      PS_TTC1_PERIPHERAL_ENABLE {1} \
      PS_TTC2_PERIPHERAL_ENABLE {1} \
      PS_TTC3_PERIPHERAL_ENABLE {1} \
      PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 8 .. 9}}} \
      PS_UART1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 20 .. 21}}} \
      PS_USE_FPD_CCI_NOC {0} \
      PS_USE_M_AXI_FPD {0} \
      PS_USE_M_AXI_LPD {1} \
      PS_USE_NOC_LPD_AXI0 {1} \
      PS_USE_PMCPL_CLK0 {1} \
      PS_USE_PMCPL_CLK1 {1} \
      PS_USE_PMCPL_CLK2 {1} \
      PS_USE_S_AXI_LPD {0} \
      SMON_ALARMS {Set_Alarms_On} \
      SMON_ENABLE_TEMP_AVERAGING {0} \
      SMON_MEAS100 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_500} {SUPPLY_NUM 9}} \
      SMON_MEAS101 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_501} {SUPPLY_NUM 10}} \
      SMON_MEAS102 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_502} {SUPPLY_NUM 11}} \
      SMON_MEAS103 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_503} {SUPPLY_NUM 12}} \
      SMON_MEAS104 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_700} {SUPPLY_NUM 13}} \
      SMON_MEAS105 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_701} {SUPPLY_NUM 14}} \
      SMON_MEAS106 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_702} {SUPPLY_NUM 15}} \
      SMON_MEAS118 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PMC} {SUPPLY_NUM 0}} \
      SMON_MEAS119 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSFP} {SUPPLY_NUM 1}} \
      SMON_MEAS120 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSLP} {SUPPLY_NUM 2}} \
      SMON_MEAS121 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_RAM} {SUPPLY_NUM 3}} \
      SMON_MEAS122 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_SOC} {SUPPLY_NUM 4}} \
      SMON_MEAS47 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_104} {SUPPLY_NUM 20}} \
      SMON_MEAS48 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_105} {SUPPLY_NUM 21}} \
      SMON_MEAS64 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_104} {SUPPLY_NUM 18}} \
      SMON_MEAS65 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_105} {SUPPLY_NUM 19}} \
      SMON_MEAS81 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_104} {SUPPLY_NUM 22}} \
      SMON_MEAS82 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_105} {SUPPLY_NUM 23}} \
      SMON_MEAS96 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX} {SUPPLY_NUM 6}} \
      SMON_MEAS97 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_PMC} {SUPPLY_NUM 7}} \
      SMON_MEAS98 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_SMON} {SUPPLY_NUM 8}} \
      SMON_MEAS99 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCINT} {SUPPLY_NUM 5}} \
      SMON_TEMP_AVERAGING_SAMPLES {0} \
      SMON_VOLTAGE_AVERAGING_SAMPLES {8} \
    } \
    CONFIG.PS_PMC_CONFIG_APPLIED {1} \
  ] $cips


  # Create instance: axi_noc_cips, and set properties
  set axi_noc_cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_cips ]
  set_property -dict [list \
    CONFIG.HBM_NUM_CHNL {0} \
    CONFIG.HBM_REF_CLK_FREQ0 {100.000} \
    CONFIG.HBM_REF_CLK_FREQ1 {100.000} \
    CONFIG.MI_SIDEBAND_PINS { ,0} \
    CONFIG.NUM_CLKS {6} \
    CONFIG.NUM_HBM_BLI {0} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_NMI {6} \
    CONFIG.NUM_NSI {0} \
    CONFIG.NUM_SI {4} \
  ] $axi_noc_cips


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.APERTURES {{0x201_0000_0000 0x200_0000}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_cips/M00_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_cips/M01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M01_AXI {read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_AXI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64}} M00_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}}} \
   CONFIG.DEST_IDS {M01_AXI:0x40:M00_AXI:0x80} \
   CONFIG.REMAPS {M00_INI {{0x20108000000 0x00038000000 0x08000000}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins /axi_noc_cips/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M01_AXI {read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M03_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_AXI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64}}} \
   CONFIG.DEST_IDS {M01_AXI:0x40:M00_AXI:0x80} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins /axi_noc_cips/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {false}} M00_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {false}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /axi_noc_cips/S02_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {false}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /axi_noc_cips/S03_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M01_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk5]

  # Create instance: axi_noc_mc_ddr4_0, and set properties
  set axi_noc_mc_ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_mc_ddr4_0 ]
  set_property -dict [list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.MC_CHAN_REGION1 {DDR_CH1} \
    CONFIG.MC_COMPONENT_WIDTH {x16} \
    CONFIG.MC_DATAWIDTH {72} \
    CONFIG.MC_DM_WIDTH {9} \
    CONFIG.MC_DQS_WIDTH {9} \
    CONFIG.MC_DQ_WIDTH {72} \
    CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {true} \
    CONFIG.MC_INPUTCLK0_PERIOD {5000} \
    CONFIG.MC_MEMORY_DEVICETYPE {Components} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_NO_CHANNELS {Single} \
    CONFIG.MC_RANK {1} \
    CONFIG.MC_ROWADDRESSWIDTH {16} \
    CONFIG.MC_STACKHEIGHT {1} \
    CONFIG.MC_SYSTEM_CLOCK {Differential} \
    CONFIG.NUM_CLKS {0} \
    CONFIG.NUM_MC {1} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_mc_ddr4_0


  set_property -dict [ list \
   CONFIG.CONNECTIONS { MC_0 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} } } \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_0/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS { MC_1 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} } } \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_0/S01_INI]

  # Create instance: axi_noc_mc_ddr4_1, and set properties
  set axi_noc_mc_ddr4_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_mc_ddr4_1 ]
  set_property -dict [list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.MC0_CONFIG_NUM {config21} \
    CONFIG.MC0_FLIPPED_PINOUT {false} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH2} \
    CONFIG.MC_COMPONENT_WIDTH {x4} \
    CONFIG.MC_DATAWIDTH {72} \
    CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {true} \
    CONFIG.MC_INPUTCLK0_PERIOD {5000} \
    CONFIG.MC_MEMORY_DEVICETYPE {RDIMMs} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_NO_CHANNELS {Single} \
    CONFIG.MC_PARITY {true} \
    CONFIG.MC_RANK {1} \
    CONFIG.MC_ROWADDRESSWIDTH {18} \
    CONFIG.MC_STACKHEIGHT {1} \
    CONFIG.MC_SYSTEM_CLOCK {Differential} \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MC {1} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {2} \
  ] $axi_noc_mc_ddr4_1


  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_1/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {false}}} \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_1/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_3 {read_bw {1} write_bw {8000} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_1/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_1 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {false}}} \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_1/S01_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI} \
 ] [get_bd_pins /axi_noc_mc_ddr4_1/aclk0]

  # Create instance: base_logic
  create_hier_cell_base_logic [current_bd_instance .] base_logic

  # Create instance: clock_reset
  create_hier_cell_clock_reset [current_bd_instance .] clock_reset

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]

  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:emb_mem_gen:1.0 axi_bram_ctrl_0_bram ]
  set_property CONFIG.MEMORY_TYPE {True_Dual_Port_RAM} $axi_bram_ctrl_0_bram


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: RapidDetect
  create_hier_cell_RapidDetect [current_bd_instance .] RapidDetect

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_0 ]
  set_property -dict [list \
    CONFIG.HBM_NUM_CHNL {16} \
    CONFIG.HBM_REF_CLK_FREQ0 {200.000} \
    CONFIG.HBM_REF_CLK_FREQ1 {200.000} \
    CONFIG.HBM_REF_CLK_SELECTION {External} \
    CONFIG.NUM_HBM_BLI {2} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_0


  set_property -dict [ list \
   CONFIG.CONNECTIONS {HBM4_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM4_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM2_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM5_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM5_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM1_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM7_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM1_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM7_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM6_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM0_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM6_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM2_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM0_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM3_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM3_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl_hbm} \
 ] [get_bd_intf_pins /axi_noc_0/HBM00_AXI]

  set_property -dict [ list \
   CONFIG.R_TRAFFIC_CLASS {BEST_EFFORT} \
   CONFIG.CONNECTIONS {HBM10_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM15_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM9_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM10_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM11_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM15_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM9_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM11_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM13_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM13_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM12_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM14_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM12_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM8_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM8_PORT2 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}} HBM14_PORT0 {read_bw {12800} write_bw {1} phases { load_HBM { read_bw {0} write_bw {1} read_avg_burst {4} write_avg_burst {4} } HBM0 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM1 {read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM2 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM3 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM4 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM5 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM6 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM7 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM8 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM9 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM10 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM11 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM12 { read_bw {12800} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM13 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM14 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } HBM15 { read_bw {0} write_bw {0} read_avg_burst {256} write_avg_burst {4} } } read_avg_burst {256} write_avg_burst {4} multi_phase {true}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl_hbm} \
 ] [get_bd_intf_pins /axi_noc_0/HBM01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {HBM10_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM10_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM0_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM1_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM1_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM0_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins /axi_noc_0/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {HBM10_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM10_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM0_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM1_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM1_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM0_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins /axi_noc_0/S01_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {HBM00_AXI:HBM01_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk0]

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {1} \
  ] $axi_gpio_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem0 [get_bd_intf_pins RapidDetect/m_axi_gmem0] [get_bd_intf_pins axi_noc_mc_ddr4_1/S00_AXI]
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem1 [get_bd_intf_pins axi_noc_mc_ddr4_1/S01_AXI] [get_bd_intf_pins RapidDetect/m_axi_gmem1]
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem2 [get_bd_intf_pins RapidDetect/m_axi_gmem2] [get_bd_intf_pins axi_noc_0/HBM00_AXI]
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem3 [get_bd_intf_pins RapidDetect/m_axi_gmem3] [get_bd_intf_pins axi_noc_0/HBM01_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_noc_cips_M00_AXI [get_bd_intf_pins axi_noc_cips/M00_AXI] [get_bd_intf_pins base_logic/s_axi_pcie_mgmt_slr0]
  connect_bd_intf_net -intf_net axi_noc_cips_M00_INI [get_bd_intf_pins axi_noc_cips/M00_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_INI [get_bd_intf_pins axi_noc_cips/M01_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M02_AXI [get_bd_intf_pins axi_noc_cips/M01_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_cips_M02_INI [get_bd_intf_pins axi_noc_cips/M02_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M03_INI [get_bd_intf_pins axi_noc_cips/M03_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M04_INI [get_bd_intf_pins axi_noc_cips/M04_INI] [get_bd_intf_pins axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M05_INI [get_bd_intf_pins axi_noc_cips/M05_INI] [get_bd_intf_pins axi_noc_0/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_0_CH0_DDR4_0 [get_bd_intf_pins axi_noc_mc_ddr4_0/CH0_DDR4_0] [get_bd_intf_ports CH0_DDR4_0_0]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_1_CH0_DDR4_0 [get_bd_intf_pins axi_noc_mc_ddr4_1/CH0_DDR4_0] [get_bd_intf_ports CH0_DDR4_0_1]
  connect_bd_intf_net -intf_net base_logic_m_axi_pcie_mgmt_pdi_reset [get_bd_intf_pins base_logic/m_axi_pcie_mgmt_pdi_reset] [get_bd_intf_pins clock_reset/s_axi_pcie_mgmt_pdi_reset]
  connect_bd_intf_net -intf_net base_logic_smbus_rpu [get_bd_intf_pins base_logic/smbus_rpu] [get_bd_intf_ports smbus_0]
  connect_bd_intf_net -intf_net cips_CPM_PCIE_NOC_0 [get_bd_intf_pins cips/CPM_PCIE_NOC_0] [get_bd_intf_pins axi_noc_cips/S00_AXI]
  connect_bd_intf_net -intf_net cips_CPM_PCIE_NOC_1 [get_bd_intf_pins cips/CPM_PCIE_NOC_1] [get_bd_intf_pins axi_noc_cips/S01_AXI]
  connect_bd_intf_net -intf_net cips_LPD_AXI_NOC_0 [get_bd_intf_pins cips/LPD_AXI_NOC_0] [get_bd_intf_pins axi_noc_cips/S03_AXI]
  connect_bd_intf_net -intf_net cips_M_AXI_LPD [get_bd_intf_pins cips/M_AXI_LPD] [get_bd_intf_pins base_logic/s_axi_rpu]
  connect_bd_intf_net -intf_net cips_PCIE1_GT [get_bd_intf_pins cips/PCIE1_GT] [get_bd_intf_ports gt_pciea1]
  connect_bd_intf_net -intf_net cips_PMC_NOC_AXI_0 [get_bd_intf_pins cips/PMC_NOC_AXI_0] [get_bd_intf_pins axi_noc_cips/S02_AXI]
  connect_bd_intf_net -intf_net cips_pcie1_cfg_ext [get_bd_intf_pins cips/pcie1_cfg_ext] [get_bd_intf_pins base_logic/pcie_cfg_ext]
  connect_bd_intf_net -intf_net gt_pcie_refclk_1 [get_bd_intf_ports gt_pcie_refclk] [get_bd_intf_pins cips/gt_refclk1]
  connect_bd_intf_net -intf_net hbm_ref_clk_0_1 [get_bd_intf_ports hbm_ref_clk_0] [get_bd_intf_pins axi_noc_0/hbm_ref_clk0]
  connect_bd_intf_net -intf_net hbm_ref_clk_1_1 [get_bd_intf_ports hbm_ref_clk_1] [get_bd_intf_pins axi_noc_0/hbm_ref_clk1]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins RapidDetect/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins RapidDetect/s_axi_control1]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins smartconnect_0/M04_AXI] [get_bd_intf_pins RapidDetect/s_axi_control2]
  connect_bd_intf_net -intf_net sys_clk0_0_1 [get_bd_intf_ports sys_clk0_0] [get_bd_intf_pins axi_noc_mc_ddr4_0/sys_clk0]
  connect_bd_intf_net -intf_net sys_clk0_1_1 [get_bd_intf_ports sys_clk0_1] [get_bd_intf_pins axi_noc_mc_ddr4_1/sys_clk0]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_0/gpio_io_o] \
  [get_bd_pins RapidDetect/ap_rst_n] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
  connect_bd_net -net base_logic_irq_axi_smbus_rpu  [get_bd_pins base_logic/irq_axi_smbus_rpu] \
  [get_bd_pins cips/pl_ps_irq1]
  connect_bd_net -net base_logic_irq_gcq_m2r  [get_bd_pins base_logic/irq_gcq_m2r] \
  [get_bd_pins cips/pl_ps_irq0]
  connect_bd_net -net cips_cpm_pcie_noc_axi0_clk  [get_bd_pins cips/cpm_pcie_noc_axi0_clk] \
  [get_bd_pins axi_noc_cips/aclk0]
  connect_bd_net -net cips_cpm_pcie_noc_axi1_clk  [get_bd_pins cips/cpm_pcie_noc_axi1_clk] \
  [get_bd_pins axi_noc_cips/aclk1]
  connect_bd_net -net cips_dma1_axi_aresetn  [get_bd_pins cips/dma1_axi_aresetn] \
  [get_bd_pins clock_reset/dma_axi_aresetn]
  connect_bd_net -net cips_lpd_axi_noc_clk  [get_bd_pins cips/lpd_axi_noc_clk] \
  [get_bd_pins axi_noc_cips/aclk3]
  connect_bd_net -net cips_pl0_ref_clk  [get_bd_pins cips/pl0_ref_clk] \
  [get_bd_pins cips/m_axi_lpd_aclk] \
  [get_bd_pins axi_noc_cips/aclk4] \
  [get_bd_pins base_logic/clk_pl] \
  [get_bd_pins clock_reset/clk_pl]
  connect_bd_net -net cips_pl0_resetn  [get_bd_pins cips/pl0_resetn] \
  [get_bd_pins clock_reset/resetn_pl_axi]
  connect_bd_net -net cips_pl1_ref_clk  [get_bd_pins cips/pl1_ref_clk] \
  [get_bd_pins clock_reset/clk_freerun]
  connect_bd_net -net cips_pl2_ref_clk  [get_bd_pins cips/pl2_ref_clk] \
  [get_bd_pins cips/dma1_intrfc_clk] \
  [get_bd_pins base_logic/clk_pcie] \
  [get_bd_pins clock_reset/clk_pcie]
  connect_bd_net -net cips_pmc_axi_noc_axi0_clk  [get_bd_pins cips/pmc_axi_noc_axi0_clk] \
  [get_bd_pins axi_noc_cips/aclk2]
  connect_bd_net -net clock_reset_clk_usr_0  [get_bd_pins clock_reset/clk_usr_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] \
  [get_bd_pins axi_noc_cips/aclk5] \
  [get_bd_pins axi_noc_mc_ddr4_1/aclk0] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins RapidDetect/ap_clk] \
  [get_bd_pins axi_noc_0/aclk0] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins axi_gpio_0/s_axi_aclk]
  connect_bd_net -net clock_reset_resetn_pcie_ic  [get_bd_pins clock_reset/resetn_pcie_ic] \
  [get_bd_pins cips/dma1_intrfc_resetn]
  connect_bd_net -net clock_reset_resetn_pcie_periph  [get_bd_pins clock_reset/resetn_pcie_periph] \
  [get_bd_pins base_logic/resetn_pcie_periph]
  connect_bd_net -net clock_reset_resetn_pl_ic  [get_bd_pins clock_reset/resetn_pl_ic] \
  [get_bd_pins base_logic/resetn_pl_ic]
  connect_bd_net -net clock_reset_resetn_pl_periph  [get_bd_pins clock_reset/resetn_pl_periph] \
  [get_bd_pins base_logic/resetn_pl_periph]
  connect_bd_net -net clock_reset_resetn_usr_0_periph  [get_bd_pins clock_reset/resetn_usr_0_periph] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn  [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins RapidDetect/s_axis_aresetn]

  # Create address segments
  assign_bd_address -offset 0x020200000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x020200002C00 -range 0x00000080 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x004000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM0_PC0] -force
  assign_bd_address -offset 0x004040000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM0_PC1] -force
  assign_bd_address -offset 0x004500000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM10_PC0] -force
  assign_bd_address -offset 0x004540000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM10_PC1] -force
  assign_bd_address -offset 0x004580000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM11_PC0] -force
  assign_bd_address -offset 0x0045C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM11_PC1] -force
  assign_bd_address -offset 0x004600000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM12_PC0] -force
  assign_bd_address -offset 0x004640000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM12_PC1] -force
  assign_bd_address -offset 0x004680000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM13_PC0] -force
  assign_bd_address -offset 0x0046C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM13_PC1] -force
  assign_bd_address -offset 0x004700000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM14_PC0] -force
  assign_bd_address -offset 0x004740000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM14_PC1] -force
  assign_bd_address -offset 0x004780000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM15_PC0] -force
  assign_bd_address -offset 0x0047C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM15_PC1] -force
  assign_bd_address -offset 0x004080000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM1_PC0] -force
  assign_bd_address -offset 0x0040C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM1_PC1] -force
  assign_bd_address -offset 0x004100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM2_PC0] -force
  assign_bd_address -offset 0x004140000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM2_PC1] -force
  assign_bd_address -offset 0x004180000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM3_PC0] -force
  assign_bd_address -offset 0x0041C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM3_PC1] -force
  assign_bd_address -offset 0x004200000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM4_PC0] -force
  assign_bd_address -offset 0x004240000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM4_PC1] -force
  assign_bd_address -offset 0x004280000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM5_PC0] -force
  assign_bd_address -offset 0x0042C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM5_PC1] -force
  assign_bd_address -offset 0x004300000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM6_PC0] -force
  assign_bd_address -offset 0x004340000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM6_PC1] -force
  assign_bd_address -offset 0x004380000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM7_PC0] -force
  assign_bd_address -offset 0x0043C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM7_PC1] -force
  assign_bd_address -offset 0x004400000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM8_PC0] -force
  assign_bd_address -offset 0x004440000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM8_PC1] -force
  assign_bd_address -offset 0x004480000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM9_PC0] -force
  assign_bd_address -offset 0x0044C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_0/S00_INI/HBM9_PC1] -force
  assign_bd_address -offset 0x020108000000 -range 0x08000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force
  assign_bd_address -offset 0x020101010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs base_logic/gcq_m2r/S00_AXI/S00_AXI_Reg] -force
  assign_bd_address -offset 0x020101000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs base_logic/hw_discovery/s_axi_ctrl_pf0/reg0] -force
  assign_bd_address -offset 0x020200002400 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/payloadReadKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020200003000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/payloadWriteKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020101040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs clock_reset/pcie_mgmt_pdi_reset/pcie_mgmt_pdi_reset_gpio/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200002800 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/resultWriteKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020101001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs base_logic/uuid_rom/S_AXI/reg0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x020200002C00 -range 0x00000080 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x004000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM0_PC0] -force
  assign_bd_address -offset 0x004040000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM0_PC1] -force
  assign_bd_address -offset 0x004500000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM10_PC0] -force
  assign_bd_address -offset 0x004540000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM10_PC1] -force
  assign_bd_address -offset 0x004580000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM11_PC0] -force
  assign_bd_address -offset 0x0045C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM11_PC1] -force
  assign_bd_address -offset 0x004600000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM12_PC0] -force
  assign_bd_address -offset 0x004640000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM12_PC1] -force
  assign_bd_address -offset 0x004680000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM13_PC0] -force
  assign_bd_address -offset 0x0046C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM13_PC1] -force
  assign_bd_address -offset 0x004700000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM14_PC0] -force
  assign_bd_address -offset 0x004740000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM14_PC1] -force
  assign_bd_address -offset 0x004780000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM15_PC0] -force
  assign_bd_address -offset 0x0047C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM15_PC1] -force
  assign_bd_address -offset 0x004080000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM1_PC0] -force
  assign_bd_address -offset 0x0040C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM1_PC1] -force
  assign_bd_address -offset 0x004100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM2_PC0] -force
  assign_bd_address -offset 0x004140000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM2_PC1] -force
  assign_bd_address -offset 0x004180000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM3_PC0] -force
  assign_bd_address -offset 0x0041C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM3_PC1] -force
  assign_bd_address -offset 0x004200000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM4_PC0] -force
  assign_bd_address -offset 0x004240000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM4_PC1] -force
  assign_bd_address -offset 0x004280000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM5_PC0] -force
  assign_bd_address -offset 0x0042C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM5_PC1] -force
  assign_bd_address -offset 0x004300000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM6_PC0] -force
  assign_bd_address -offset 0x004340000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM6_PC1] -force
  assign_bd_address -offset 0x004380000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM7_PC0] -force
  assign_bd_address -offset 0x0043C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM7_PC1] -force
  assign_bd_address -offset 0x004400000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM8_PC0] -force
  assign_bd_address -offset 0x004440000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM8_PC1] -force
  assign_bd_address -offset 0x004480000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM9_PC0] -force
  assign_bd_address -offset 0x0044C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_0/S01_INI/HBM9_PC1] -force
  assign_bd_address -offset 0x050080000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_mc_ddr4_0/S01_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_mc_ddr4_0/S01_INI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_mc_ddr4_1/S01_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x020101010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs base_logic/gcq_m2r/S00_AXI/S00_AXI_Reg] -force
  assign_bd_address -offset 0x020101000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs base_logic/hw_discovery/s_axi_ctrl_pf0/reg0] -force
  assign_bd_address -offset 0x020200002400 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs RapidDetect/payloadReadKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020200003000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs RapidDetect/payloadWriteKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020101040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs clock_reset/pcie_mgmt_pdi_reset/pcie_mgmt_pdi_reset_gpio/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200002800 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs RapidDetect/resultWriteKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020101001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs base_logic/uuid_rom/S_AXI/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x80044000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/M_AXI_LPD] [get_bd_addr_segs base_logic/axi_smbus_rpu/S_AXI/Reg] -force
  assign_bd_address -offset 0x80010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/M_AXI_LPD] [get_bd_addr_segs base_logic/gcq_m2r/S01_AXI/S01_AXI_Reg] -force
  assign_bd_address -offset 0x050080000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force
  assign_bd_address -offset 0x004000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM0_PC0] -force
  assign_bd_address -offset 0x004040000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM0_PC1] -force
  assign_bd_address -offset 0x004080000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM1_PC0] -force
  assign_bd_address -offset 0x0040C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM1_PC1] -force
  assign_bd_address -offset 0x004100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM2_PC0] -force
  assign_bd_address -offset 0x004140000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM2_PC1] -force
  assign_bd_address -offset 0x004180000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM3_PC0] -force
  assign_bd_address -offset 0x0041C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM3_PC1] -force
  assign_bd_address -offset 0x004200000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM4_PC0] -force
  assign_bd_address -offset 0x004240000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM4_PC1] -force
  assign_bd_address -offset 0x004280000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM5_PC0] -force
  assign_bd_address -offset 0x0042C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM5_PC1] -force
  assign_bd_address -offset 0x004300000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM6_PC0] -force
  assign_bd_address -offset 0x004340000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM6_PC1] -force
  assign_bd_address -offset 0x004380000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM7_PC0] -force
  assign_bd_address -offset 0x0043C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_0/HBM00_AXI/HBM7_PC1] -force
  assign_bd_address -offset 0x004500000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM10_PC0] -force
  assign_bd_address -offset 0x004540000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM10_PC1] -force
  assign_bd_address -offset 0x004580000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM11_PC0] -force
  assign_bd_address -offset 0x0045C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM11_PC1] -force
  assign_bd_address -offset 0x004600000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM12_PC0] -force
  assign_bd_address -offset 0x004640000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM12_PC1] -force
  assign_bd_address -offset 0x004680000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM13_PC0] -force
  assign_bd_address -offset 0x0046C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM13_PC1] -force
  assign_bd_address -offset 0x004700000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM14_PC0] -force
  assign_bd_address -offset 0x004740000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM14_PC1] -force
  assign_bd_address -offset 0x004780000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM15_PC0] -force
  assign_bd_address -offset 0x0047C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM15_PC1] -force
  assign_bd_address -offset 0x004400000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM8_PC0] -force
  assign_bd_address -offset 0x004440000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM8_PC1] -force
  assign_bd_address -offset 0x004480000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM9_PC0] -force
  assign_bd_address -offset 0x0044C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadReadKernel_0/Data_m_axi_gmem1] [get_bd_addr_segs axi_noc_0/HBM01_AXI/HBM9_PC1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces RapidDetect/resultWriteKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_mc_ddr4_1/S00_AXI/C2_DDR_CH2] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces RapidDetect/payloadWriteKernel_0/Data_m_axi_gmem0] [get_bd_addr_segs axi_noc_mc_ddr4_1/S01_AXI/C3_DDR_CH2] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1]
  exclude_bd_addr_seg -offset 0x050080000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1]


  # Restore current instance
  current_bd_instance $oldCurInst

}
# End of create_root_design()




proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_base_logic parentCell nameHier"
   puts "#    create_hier_cell_clock_reset parentCell nameHier"
   puts "#    create_hier_cell_pcie_mgmt_pdi_reset parentCell nameHier"
   puts "#    create_root_design"
   puts "#"
   puts "#"
   puts "# The following procedures will create hiearchical blocks with addressing "
   puts "# for IPs within those blocks and their sub-hierarchical blocks. Addressing "
   puts "# will not be handled outside those blocks:"
   puts "#"
   puts "#    create_root_design"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs
