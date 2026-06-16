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
xilinx.com:ip:hw_discovery:1.0\
xilinx.com:ip:shell_utils_uuid_rom:2.0\
xilinx.com:ip:smbus:1.1\
xilinx.com:ip:cmd_queue:2.0\
xilinx.com:ip:clk_wizard:1.0\
xilinx.com:hls:sm_kernel:1.0\
xilinx.com:hls:payloadSourceKernel:1.0\
xilinx.com:hls:payloadReadKernel:1.0\
xilinx.com:hls:resultSinkKernel:1.0\
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:hls:resultWriteKernel:1.0\
xilinx.com:hls:mergePipesKernel:1.0\
xilinx.com:hls:payloadWriteKernel:1.0\
xilinx.com:hls:fieldTaggerKernel:1.0\
xilinx.com:hls:sm2nfKernel:1.0\
xilinx.com:hls:nf2hostKernel:1.0\
xilinx.com:hls:nf_kernel:1.0\
xilinx.com:hls:convertToEthernetKernel:1.0\
xilinx.com:hls:fromEthernetKernel:1.0\
xilinx.com:inline_hdl:ilconstant:1.0\
xilinx.com:hls:payloadSinkKernel:1.0\
xilinx.com:ip:axis_dwidth_converter:1.1\
xilinx.com:inline_hdl:ilconcat:1.0\
xilinx.com:inline_hdl:ilreduced_logic:1.0\
xilinx.com:inline_hdl:ilvector_logic:1.0\
xilinx.com:inline_hdl:ilslice:1.0\
xilinx.com:ip:dcmac:3.0\
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:ip:gtwiz_versal:1.0\
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

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\
reset_registers\
dcmac_syncer_reset\
dcmac_syncer_reset\
dcmac_syncer_reset\
dcmac_syncer_reset\
axis_seg_to_unseg_converter\
axis_unseg_to_seg_converter\
dcmac_syncer_reset\
dcmac_syncer_reset\
dcmac_syncer_reset\
dcmac_syncer_reset\
axis_seg_to_unseg_converter\
axis_unseg_to_seg_converter\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
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


# Hierarchical cell: gtwiz_wrapper
proc create_hier_cell_gtwiz_wrapper_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gtwiz_wrapper_1() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 Quad0_AXI_LITE


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_tx_usr_clk_332MHz
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_rx_usr_clk_332MHz
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX0_ch_txdata
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX1_ch_txdata
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX2_ch_txdata
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX3_ch_txdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX0_ch_rxdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX1_ch_rxdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX2_ch_rxdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX3_ch_rxdata
  create_bd_pin -dir O INTF0_rst_tx_done_out
  create_bd_pin -dir O INTF0_rst_rx_done_out
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_tx_usr_clk_664MHz
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_rx_usr_clk_664MHz
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk gt_ref_clk_322MHz
  create_bd_pin -dir I -type clk gtwiz_freerun_clk
  create_bd_pin -dir I -from 31 -to 0 gt_control
  create_bd_pin -dir I -type rst QUAD0_s_axi_lite_resetn
  create_bd_pin -dir I -from 6 -to 0 gt_reset
  create_bd_pin -dir O gtpowergood

  # Create instance: gt_ref_clk, and set properties
  set gt_ref_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 gt_ref_clk ]
  set_property CONFIG.C_BUF_TYPE {IBUFDS_GTME5} $gt_ref_clk


  # Create instance: gtwiz_versal, and set properties
  set gtwiz_versal [ create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal:1.0 gtwiz_versal ]
  set_property -dict [list \
    CONFIG.ENABLE_REG_INTERFACE {true} \
    CONFIG.GT_TYPE {GTM} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {RXPROGDIV_FREQ_VAL 664.062 RX_REFCLK_FREQUENCY 322.265625 TXPROGDIV_FREQ_VAL 664.062 TX_REFCLK_FREQUENCY 322.265625} \
    CONFIG.INTF0_PARENTID {undef} \
    CONFIG.INTF0_PRESET {GTM-PAM4_Ethernet_53G} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_RX0 {{}} QUAD0_RX1 {{}} QUAD0_RX2 {{}} QUAD0_RX3 {{}} QUAD0_TX0 {{}} QUAD0_TX1 {{}} QUAD0_TX2 {{}} QUAD0_TX3 {{}}} \
    CONFIG.LOCATE_BUFG {EXAMPLE_DESIGN} \
    CONFIG.QUAD0_CH0_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH1_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH2_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH3_LOOPBACK_EN {true} \
    CONFIG.QUAD0_GT_GPIO_EN {false} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_322.265625183611_MHz_unique1} \
    CONFIG.QUAD0_TX1_OUTCLK_EN {false} \
    CONFIG.REG_CONF_INTF {AXI_LITE} \
  ] $gtwiz_versal

  set_property -dict [list \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
  ] $gtwiz_versal


  # Create instance: ilconstant_high, and set properties
  set ilconstant_high [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_high ]

  # Create instance: mbufg_gt_tx, and set properties
  set mbufg_gt_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 mbufg_gt_tx ]
  set_property CONFIG.C_BUF_TYPE {MBUFG_GT} $mbufg_gt_tx


  # Create instance: mbufg_gt_rx, and set properties
  set mbufg_gt_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 mbufg_gt_rx ]
  set_property CONFIG.C_BUF_TYPE {MBUFG_GT} $mbufg_gt_rx


  # Create instance: gt_ref_clk_usr, and set properties
  set gt_ref_clk_usr [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 gt_ref_clk_usr ]
  set_property CONFIG.C_BUF_TYPE {BUFG_GT} $gt_ref_clk_usr


  # Create instance: ilslice_gt_loopback, and set properties
  set ilslice_gt_loopback [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_loopback ]
  set_property -dict [list \
    CONFIG.DIN_FROM {11} \
    CONFIG.DIN_TO {9} \
  ] $ilslice_gt_loopback


  # Create instance: ilslice_gt_txmaincursor, and set properties
  set ilslice_gt_txmaincursor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_txmaincursor ]
  set_property -dict [list \
    CONFIG.DIN_FROM {30} \
    CONFIG.DIN_TO {24} \
  ] $ilslice_gt_txmaincursor


  # Create instance: ilslice_gt_line_rate, and set properties
  set ilslice_gt_line_rate [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_line_rate ]
  set_property -dict [list \
    CONFIG.DIN_FROM {8} \
    CONFIG.DIN_TO {1} \
  ] $ilslice_gt_line_rate


  # Create instance: ilslice_gt_txpostcursor, and set properties
  set ilslice_gt_txpostcursor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_txpostcursor ]
  set_property -dict [list \
    CONFIG.DIN_FROM {23} \
    CONFIG.DIN_TO {18} \
  ] $ilslice_gt_txpostcursor


  # Create instance: ilslice_gt_txprecursor, and set properties
  set ilslice_gt_txprecursor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_txprecursor ]
  set_property -dict [list \
    CONFIG.DIN_FROM {17} \
    CONFIG.DIN_TO {12} \
  ] $ilslice_gt_txprecursor


  # Create instance: ilslice_gt_rxcdrhold, and set properties
  set ilslice_gt_rxcdrhold [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rxcdrhold ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {31} \
  ] $ilslice_gt_rxcdrhold


  # Create instance: ilslice_gt_rst_all_in, and set properties
  set ilslice_gt_rst_all_in [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_all_in ]
  set_property CONFIG.DIN_WIDTH {7} $ilslice_gt_rst_all_in


  # Create instance: ilslice_gt_rst_tx_pll_and_datapath, and set properties
  set ilslice_gt_rst_tx_pll_and_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_tx_pll_and_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_tx_pll_and_datapath


  # Create instance: ilslice_gt_rst_rx_datapath, and set properties
  set ilslice_gt_rst_rx_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_rx_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {4} \
    CONFIG.DIN_TO {4} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_rx_datapath


  # Create instance: ilslice_gt_rst_tx_datapath, and set properties
  set ilslice_gt_rst_tx_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_tx_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_tx_datapath


  # Create instance: ilslice_gt_rst_rx_pll_and_datapath, and set properties
  set ilslice_gt_rst_rx_pll_and_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_rx_pll_and_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_rx_pll_and_datapath


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins gtwiz_versal/Quad0_AXI_LITE] [get_bd_intf_pins Quad0_AXI_LITE]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins GT_Serial] [get_bd_intf_pins gtwiz_versal/Quad0_GT_Serial]
  connect_bd_intf_net -intf_net qsfp0_322mhz_1 [get_bd_intf_pins qsfp0_322mhz] [get_bd_intf_pins gt_ref_clk/CLK_IN_D1]

  # Create port connections
  connect_bd_net -net Din1_1  [get_bd_pins gt_reset] \
  [get_bd_pins ilslice_gt_rst_rx_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_rx_pll_and_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_tx_pll_and_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_tx_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_all_in/Din]
  connect_bd_net -net Din_1  [get_bd_pins gt_control] \
  [get_bd_pins ilslice_gt_loopback/Din] \
  [get_bd_pins ilslice_gt_line_rate/Din] \
  [get_bd_pins ilslice_gt_rxcdrhold/Din] \
  [get_bd_pins ilslice_gt_txmaincursor/Din] \
  [get_bd_pins ilslice_gt_txpostcursor/Din] \
  [get_bd_pins ilslice_gt_txprecursor/Din]
  connect_bd_net -net QUAD0_s_axi_lite_resetn_1  [get_bd_pins QUAD0_s_axi_lite_resetn] \
  [get_bd_pins gtwiz_versal/QUAD0_s_axi_lite_resetn]
  connect_bd_net -net dcmac_0_txdata_out_0  [get_bd_pins INTF0_TX0_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_1  [get_bd_pins INTF0_TX1_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_2  [get_bd_pins INTF0_TX2_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_3  [get_bd_pins INTF0_TX3_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txdata]
  connect_bd_net -net gtwiz_freerun_clk_1  [get_bd_pins gtwiz_freerun_clk] \
  [get_bd_pins gtwiz_versal/gtwiz_freerun_clk]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX0_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX0_ch_rxdata] \
  [get_bd_pins INTF0_RX0_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX1_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX1_ch_rxdata] \
  [get_bd_pins INTF0_RX1_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX2_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX2_ch_rxdata] \
  [get_bd_pins INTF0_RX2_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX3_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX3_ch_rxdata] \
  [get_bd_pins INTF0_RX3_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_TX_clr_out  [get_bd_pins gtwiz_versal/INTF0_TX_clr_out] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_CLR]
  connect_bd_net -net gtwiz_versal_0_INTF0_TX_clrb_leaf_out  [get_bd_pins gtwiz_versal/INTF0_TX_clrb_leaf_out] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net gtwiz_versal_0_QUAD0_TX0_outclk  [get_bd_pins gtwiz_versal/QUAD0_TX0_outclk] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_I]
  connect_bd_net -net gtwiz_versal_INTF0_RX_clr_out  [get_bd_pins gtwiz_versal/INTF0_RX_clr_out] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_CLR]
  connect_bd_net -net gtwiz_versal_INTF0_RX_clrb_leaf_out  [get_bd_pins gtwiz_versal/INTF0_RX_clrb_leaf_out] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins gtwiz_versal/INTF0_rst_rx_done_out] \
  [get_bd_pins INTF0_rst_rx_done_out]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_versal/INTF0_rst_tx_done_out] \
  [get_bd_pins INTF0_rst_tx_done_out]
  connect_bd_net -net gtwiz_versal_QUAD0_RX0_outclk  [get_bd_pins gtwiz_versal/QUAD0_RX0_outclk] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_I]
  connect_bd_net -net gtwiz_versal_gtpowergood  [get_bd_pins gtwiz_versal/gtpowergood] \
  [get_bd_pins gtpowergood]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_high/dout] \
  [get_bd_pins gt_ref_clk_usr/BUFG_GT_CE] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_CE] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_CE]
  connect_bd_net -net ilslice_gt_line_rate_Dout  [get_bd_pins ilslice_gt_line_rate/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX0_ch_rxrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX1_ch_rxrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX2_ch_rxrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX3_ch_rxrate]
  connect_bd_net -net ilslice_gt_loopback_Dout  [get_bd_pins ilslice_gt_loopback/Dout] \
  [get_bd_pins gtwiz_versal/QUAD0_ch0_loopback] \
  [get_bd_pins gtwiz_versal/QUAD0_ch1_loopback] \
  [get_bd_pins gtwiz_versal/QUAD0_ch2_loopback] \
  [get_bd_pins gtwiz_versal/QUAD0_ch3_loopback]
  connect_bd_net -net ilslice_gt_rst_all_in_Dout  [get_bd_pins ilslice_gt_rst_all_in/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_all_in]
  connect_bd_net -net ilslice_gt_rst_rx_datapath_Dout  [get_bd_pins ilslice_gt_rst_rx_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_rx_datapath_in]
  connect_bd_net -net ilslice_gt_rst_rx_pll_and_datapath_Dout  [get_bd_pins ilslice_gt_rst_rx_pll_and_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_rx_pll_and_datapath_in]
  connect_bd_net -net ilslice_gt_rst_tx_datapath_Dout  [get_bd_pins ilslice_gt_rst_tx_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_datapath_in]
  connect_bd_net -net ilslice_gt_rst_tx_pll_and_datapath_Dout  [get_bd_pins ilslice_gt_rst_tx_pll_and_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_pll_and_datapath_in]
  connect_bd_net -net ilslice_gt_rxcdrhold_Dout  [get_bd_pins ilslice_gt_rxcdrhold/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_RX0_ch_rxcdrhold] \
  [get_bd_pins gtwiz_versal/INTF0_RX1_ch_rxcdrhold] \
  [get_bd_pins gtwiz_versal/INTF0_RX2_ch_rxcdrhold] \
  [get_bd_pins gtwiz_versal/INTF0_RX3_ch_rxcdrhold]
  connect_bd_net -net ilslice_gt_txmaincursor_Dout  [get_bd_pins ilslice_gt_txmaincursor/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txmaincursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txmaincursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txmaincursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txmaincursor]
  connect_bd_net -net ilslice_gt_txpostcursor_Dout  [get_bd_pins ilslice_gt_txpostcursor/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txpostcursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txpostcursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txpostcursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txpostcursor]
  connect_bd_net -net ilslice_gt_txprecursor_Dout  [get_bd_pins ilslice_gt_txprecursor/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txprecursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txprecursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txprecursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txprecursor]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins mbufg_gt_rx/MBUFG_GT_O1] \
  [get_bd_pins qsfp_rx_usr_clk_664MHz]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O2  [get_bd_pins mbufg_gt_rx/MBUFG_GT_O2] \
  [get_bd_pins qsfp_rx_usr_clk_332MHz] \
  [get_bd_pins gtwiz_versal/QUAD0_RX1_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX2_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX3_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX0_usrclk]
  connect_bd_net -net mbufg_gt_tx_0_MBUFG_GT_O1  [get_bd_pins mbufg_gt_tx/MBUFG_GT_O1] \
  [get_bd_pins qsfp_tx_usr_clk_664MHz]
  connect_bd_net -net util_ds_buf_0_IBUFDS_GTME5_O  [get_bd_pins gt_ref_clk/IBUFDS_GTME5_O] \
  [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK0]
  connect_bd_net -net util_ds_buf_0_IBUFDS_GTME5_ODIV2  [get_bd_pins gt_ref_clk/IBUFDS_GTME5_ODIV2] \
  [get_bd_pins gt_ref_clk_usr/BUFG_GT_I]
  connect_bd_net -net util_ds_buf_0_MBUFG_GT_O2  [get_bd_pins mbufg_gt_tx/MBUFG_GT_O2] \
  [get_bd_pins qsfp_tx_usr_clk_332MHz] \
  [get_bd_pins gtwiz_versal/QUAD0_TX1_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX2_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX3_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX0_usrclk]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins gt_ref_clk_usr/BUFG_GT_O] \
  [get_bd_pins gt_ref_clk_322MHz]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_rx_alt
proc create_hier_cell_clock_to_serdes_rx_alt_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_rx_alt_1() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dcmac200g_ctl_port
proc create_hier_cell_dcmac200g_ctl_port_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dcmac200g_ctl_port_1() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir O -from 15 -to 0 dout
  create_bd_pin -dir O -from 63 -to 0 dout1
  create_bd_pin -dir O -from 63 -to 0 dout2
  create_bd_pin -dir O -from 63 -to 0 dout3
  create_bd_pin -dir O -from 63 -to 0 dout4
  create_bd_pin -dir O -from 63 -to 0 dout5
  create_bd_pin -dir O -from 63 -to 0 dout6
  create_bd_pin -dir O -from 63 -to 0 dout7
  create_bd_pin -dir O -from 63 -to 0 dout8
  create_bd_pin -dir O -from 63 -to 0 dout9
  create_bd_pin -dir O -from 63 -to 0 dout10
  create_bd_pin -dir O -from 63 -to 0 dout11
  create_bd_pin -dir O -from 63 -to 0 dout12
  create_bd_pin -dir O -from 63 -to 0 dout13
  create_bd_pin -dir O -from 63 -to 0 dout14
  create_bd_pin -dir O -from 63 -to 0 dout15
  create_bd_pin -dir O -from 63 -to 0 dout16
  create_bd_pin -dir O -from 63 -to 0 dout17
  create_bd_pin -dir O -from 63 -to 0 dout18
  create_bd_pin -dir O -from 63 -to 0 dout19
  create_bd_pin -dir O -from 63 -to 0 dout20

  # Create instance: default_vl_length_200GE_or_400GE, and set properties
  set default_vl_length_200GE_or_400GE [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 default_vl_length_200GE_or_400GE ]
  set_property -dict [list \
    CONFIG.CONST_VAL {256} \
    CONFIG.CONST_WIDTH {16} \
  ] $default_vl_length_200GE_or_400GE


  # Create instance: ctl_tx_vl_marker_id0_100ge, and set properties
  set ctl_tx_vl_marker_id0_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id0_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xc16821003e97de00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id0_100ge


  # Create instance: ctl_tx_vl_marker_id1_100ge, and set properties
  set ctl_tx_vl_marker_id1_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id1_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x9d718e00628e7100} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id1_100ge


  # Create instance: ctl_tx_vl_marker_id2_100ge, and set properties
  set ctl_tx_vl_marker_id2_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id2_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x594be800a6b41700} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id2_100ge


  # Create instance: ctl_tx_vl_marker_id3_100ge, and set properties
  set ctl_tx_vl_marker_id3_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id3_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x4d957b00b26a8400} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id3_100ge


  # Create instance: ctl_tx_vl_marker_id4_100ge, and set properties
  set ctl_tx_vl_marker_id4_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id4_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xf50709000af8f600} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id4_100ge


  # Create instance: ctl_tx_vl_marker_id5_100ge, and set properties
  set ctl_tx_vl_marker_id5_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id5_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xdd14c20022eb3d00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id5_100ge


  # Create instance: ctl_tx_vl_marker_id6_100ge, and set properties
  set ctl_tx_vl_marker_id6_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id6_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x9a4a260065b5d900} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id6_100ge


  # Create instance: ctl_tx_vl_marker_id7_100ge, and set properties
  set ctl_tx_vl_marker_id7_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id7_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x7b45660084ba9900} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id7_100ge


  # Create instance: ctl_tx_vl_marker_id8_100ge, and set properties
  set ctl_tx_vl_marker_id8_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id8_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xa02476005fdb8900} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id8_100ge


  # Create instance: ctl_tx_vl_marker_id9_100ge, and set properties
  set ctl_tx_vl_marker_id9_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id9_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x68c9fb0097360400} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id9_100ge


  # Create instance: ctl_tx_vl_marker_id10_100ge, and set properties
  set ctl_tx_vl_marker_id10_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id10_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xfd6c990002936600} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id10_100ge


  # Create instance: ctl_tx_vl_marker_id11_100ge, and set properties
  set ctl_tx_vl_marker_id11_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id11_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xb9915500466eaa00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id11_100ge


  # Create instance: ctl_tx_vl_marker_id12_100ge, and set properties
  set ctl_tx_vl_marker_id12_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id12_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x5cb9b200a3464d00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id12_100ge


  # Create instance: ctl_tx_vl_marker_id13_100ge, and set properties
  set ctl_tx_vl_marker_id13_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id13_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x1af8bd00e5074200} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id13_100ge


  # Create instance: ctl_tx_vl_marker_id14_100ge, and set properties
  set ctl_tx_vl_marker_id14_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id14_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x83c7ca007c383500} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id14_100ge


  # Create instance: ctl_tx_vl_marker_id15_100ge, and set properties
  set ctl_tx_vl_marker_id15_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id15_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x3536cd00cac93200} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id15_100ge


  # Create instance: ctl_tx_vl_marker_id16_100ge, and set properties
  set ctl_tx_vl_marker_id16_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id16_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xc4314c003bceb300} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id16_100ge


  # Create instance: ctl_tx_vl_marker_id17_100ge, and set properties
  set ctl_tx_vl_marker_id17_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id17_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xadd6b70052294800} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id17_100ge


  # Create instance: ctl_tx_vl_marker_id18_100ge, and set properties
  set ctl_tx_vl_marker_id18_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id18_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x5f662a00a099d500} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id18_100ge


  # Create instance: ctl_tx_vl_marker_id19_100ge, and set properties
  set ctl_tx_vl_marker_id19_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id19_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xc0f0e5003f0f1a00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id19_100ge


  # Create port connections
  connect_bd_net -net ctl_tx_vl_marker_id0_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id0_100ge/dout] \
  [get_bd_pins dout1]
  connect_bd_net -net ctl_tx_vl_marker_id10_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id10_100ge/dout] \
  [get_bd_pins dout11]
  connect_bd_net -net ctl_tx_vl_marker_id11_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id11_100ge/dout] \
  [get_bd_pins dout12]
  connect_bd_net -net ctl_tx_vl_marker_id12_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id12_100ge/dout] \
  [get_bd_pins dout13]
  connect_bd_net -net ctl_tx_vl_marker_id13_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id13_100ge/dout] \
  [get_bd_pins dout14]
  connect_bd_net -net ctl_tx_vl_marker_id14_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id14_100ge/dout] \
  [get_bd_pins dout15]
  connect_bd_net -net ctl_tx_vl_marker_id15_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id15_100ge/dout] \
  [get_bd_pins dout16]
  connect_bd_net -net ctl_tx_vl_marker_id16_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id16_100ge/dout] \
  [get_bd_pins dout17]
  connect_bd_net -net ctl_tx_vl_marker_id17_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id17_100ge/dout] \
  [get_bd_pins dout18]
  connect_bd_net -net ctl_tx_vl_marker_id18_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id18_100ge/dout] \
  [get_bd_pins dout19]
  connect_bd_net -net ctl_tx_vl_marker_id19_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id19_100ge/dout] \
  [get_bd_pins dout20]
  connect_bd_net -net ctl_tx_vl_marker_id1_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id1_100ge/dout] \
  [get_bd_pins dout2]
  connect_bd_net -net ctl_tx_vl_marker_id2_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id2_100ge/dout] \
  [get_bd_pins dout3]
  connect_bd_net -net ctl_tx_vl_marker_id3_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id3_100ge/dout] \
  [get_bd_pins dout4]
  connect_bd_net -net ctl_tx_vl_marker_id4_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id4_100ge/dout] \
  [get_bd_pins dout5]
  connect_bd_net -net ctl_tx_vl_marker_id5_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id5_100ge/dout] \
  [get_bd_pins dout6]
  connect_bd_net -net ctl_tx_vl_marker_id6_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id6_100ge/dout] \
  [get_bd_pins dout7]
  connect_bd_net -net ctl_tx_vl_marker_id7_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id7_100ge/dout] \
  [get_bd_pins dout8]
  connect_bd_net -net ctl_tx_vl_marker_id8_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id8_100ge/dout] \
  [get_bd_pins dout9]
  connect_bd_net -net ctl_tx_vl_marker_id9_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id9_100ge/dout] \
  [get_bd_pins dout10]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins default_vl_length_200GE_or_400GE/dout] \
  [get_bd_pins dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_rx
proc create_hier_cell_clock_to_serdes_rx_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_rx_1() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_tx_alt
proc create_hier_cell_clock_to_serdes_tx_alt_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_tx_alt_1() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_tx
proc create_hier_cell_clock_to_serdes_tx_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_tx_1() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gtwiz_wrapper
proc create_hier_cell_gtwiz_wrapper { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gtwiz_wrapper() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 Quad0_AXI_LITE


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_tx_usr_clk_332MHz
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_rx_usr_clk_332MHz
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX0_ch_txdata
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX1_ch_txdata
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX2_ch_txdata
  create_bd_pin -dir I -from 255 -to 0 INTF0_TX3_ch_txdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX0_ch_rxdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX1_ch_rxdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX2_ch_rxdata
  create_bd_pin -dir O -from 255 -to 0 INTF0_RX3_ch_rxdata
  create_bd_pin -dir O INTF0_rst_tx_done_out
  create_bd_pin -dir O INTF0_rst_rx_done_out
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_tx_usr_clk_664MHz
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk qsfp_rx_usr_clk_664MHz
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk gt_ref_clk_322MHz
  create_bd_pin -dir I -type clk gtwiz_freerun_clk
  create_bd_pin -dir I -from 31 -to 0 gt_control
  create_bd_pin -dir I -type rst QUAD0_s_axi_lite_resetn
  create_bd_pin -dir I -from 6 -to 0 gt_reset
  create_bd_pin -dir O gtpowergood

  # Create instance: gt_ref_clk, and set properties
  set gt_ref_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 gt_ref_clk ]
  set_property CONFIG.C_BUF_TYPE {IBUFDS_GTME5} $gt_ref_clk


  # Create instance: gtwiz_versal, and set properties
  set gtwiz_versal [ create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal:1.0 gtwiz_versal ]
  set_property -dict [list \
    CONFIG.ENABLE_REG_INTERFACE {true} \
    CONFIG.GT_TYPE {GTM} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {RXPROGDIV_FREQ_VAL 664.062 RX_REFCLK_FREQUENCY 322.265625 TXPROGDIV_FREQ_VAL 664.062 TX_REFCLK_FREQUENCY 322.265625} \
    CONFIG.INTF0_PARENTID {undef} \
    CONFIG.INTF0_PRESET {GTM-PAM4_Ethernet_53G} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_RX0 {{}} QUAD0_RX1 {{}} QUAD0_RX2 {{}} QUAD0_RX3 {{}} QUAD0_TX0 {{}} QUAD0_TX1 {{}} QUAD0_TX2 {{}} QUAD0_TX3 {{}}} \
    CONFIG.LOCATE_BUFG {EXAMPLE_DESIGN} \
    CONFIG.QUAD0_CH0_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH1_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH2_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH3_LOOPBACK_EN {true} \
    CONFIG.QUAD0_GT_GPIO_EN {false} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_322.265625183611_MHz_unique1} \
    CONFIG.QUAD0_TX1_OUTCLK_EN {false} \
    CONFIG.REG_CONF_INTF {AXI_LITE} \
  ] $gtwiz_versal

  set_property -dict [list \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
  ] $gtwiz_versal


  # Create instance: ilconstant_high, and set properties
  set ilconstant_high [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_high ]

  # Create instance: mbufg_gt_tx, and set properties
  set mbufg_gt_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 mbufg_gt_tx ]
  set_property CONFIG.C_BUF_TYPE {MBUFG_GT} $mbufg_gt_tx


  # Create instance: mbufg_gt_rx, and set properties
  set mbufg_gt_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 mbufg_gt_rx ]
  set_property CONFIG.C_BUF_TYPE {MBUFG_GT} $mbufg_gt_rx


  # Create instance: gt_ref_clk_usr, and set properties
  set gt_ref_clk_usr [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 gt_ref_clk_usr ]
  set_property CONFIG.C_BUF_TYPE {BUFG_GT} $gt_ref_clk_usr


  # Create instance: ilslice_gt_loopback, and set properties
  set ilslice_gt_loopback [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_loopback ]
  set_property -dict [list \
    CONFIG.DIN_FROM {11} \
    CONFIG.DIN_TO {9} \
  ] $ilslice_gt_loopback


  # Create instance: ilslice_gt_txmaincursor, and set properties
  set ilslice_gt_txmaincursor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_txmaincursor ]
  set_property -dict [list \
    CONFIG.DIN_FROM {30} \
    CONFIG.DIN_TO {24} \
  ] $ilslice_gt_txmaincursor


  # Create instance: ilslice_gt_line_rate, and set properties
  set ilslice_gt_line_rate [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_line_rate ]
  set_property -dict [list \
    CONFIG.DIN_FROM {8} \
    CONFIG.DIN_TO {1} \
  ] $ilslice_gt_line_rate


  # Create instance: ilslice_gt_txpostcursor, and set properties
  set ilslice_gt_txpostcursor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_txpostcursor ]
  set_property -dict [list \
    CONFIG.DIN_FROM {23} \
    CONFIG.DIN_TO {18} \
  ] $ilslice_gt_txpostcursor


  # Create instance: ilslice_gt_txprecursor, and set properties
  set ilslice_gt_txprecursor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_txprecursor ]
  set_property -dict [list \
    CONFIG.DIN_FROM {17} \
    CONFIG.DIN_TO {12} \
  ] $ilslice_gt_txprecursor


  # Create instance: ilslice_gt_rxcdrhold, and set properties
  set ilslice_gt_rxcdrhold [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rxcdrhold ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {31} \
  ] $ilslice_gt_rxcdrhold


  # Create instance: ilslice_gt_rst_all_in, and set properties
  set ilslice_gt_rst_all_in [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_all_in ]
  set_property CONFIG.DIN_WIDTH {7} $ilslice_gt_rst_all_in


  # Create instance: ilslice_gt_rst_tx_pll_and_datapath, and set properties
  set ilslice_gt_rst_tx_pll_and_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_tx_pll_and_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_tx_pll_and_datapath


  # Create instance: ilslice_gt_rst_rx_datapath, and set properties
  set ilslice_gt_rst_rx_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_rx_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {4} \
    CONFIG.DIN_TO {4} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_rx_datapath


  # Create instance: ilslice_gt_rst_tx_datapath, and set properties
  set ilslice_gt_rst_tx_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_tx_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_tx_datapath


  # Create instance: ilslice_gt_rst_rx_pll_and_datapath, and set properties
  set ilslice_gt_rst_rx_pll_and_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_gt_rst_rx_pll_and_datapath ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_gt_rst_rx_pll_and_datapath


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins gtwiz_versal/Quad0_AXI_LITE] [get_bd_intf_pins Quad0_AXI_LITE]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins GT_Serial] [get_bd_intf_pins gtwiz_versal/Quad0_GT_Serial]
  connect_bd_intf_net -intf_net qsfp0_322mhz_1 [get_bd_intf_pins qsfp0_322mhz] [get_bd_intf_pins gt_ref_clk/CLK_IN_D1]

  # Create port connections
  connect_bd_net -net Din1_1  [get_bd_pins gt_reset] \
  [get_bd_pins ilslice_gt_rst_rx_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_rx_pll_and_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_tx_pll_and_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_tx_datapath/Din] \
  [get_bd_pins ilslice_gt_rst_all_in/Din]
  connect_bd_net -net Din_1  [get_bd_pins gt_control] \
  [get_bd_pins ilslice_gt_loopback/Din] \
  [get_bd_pins ilslice_gt_line_rate/Din] \
  [get_bd_pins ilslice_gt_rxcdrhold/Din] \
  [get_bd_pins ilslice_gt_txmaincursor/Din] \
  [get_bd_pins ilslice_gt_txpostcursor/Din] \
  [get_bd_pins ilslice_gt_txprecursor/Din]
  connect_bd_net -net QUAD0_s_axi_lite_resetn_1  [get_bd_pins QUAD0_s_axi_lite_resetn] \
  [get_bd_pins gtwiz_versal/QUAD0_s_axi_lite_resetn]
  connect_bd_net -net dcmac_0_txdata_out_0  [get_bd_pins INTF0_TX0_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_1  [get_bd_pins INTF0_TX1_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_2  [get_bd_pins INTF0_TX2_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_3  [get_bd_pins INTF0_TX3_ch_txdata] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txdata]
  connect_bd_net -net gtwiz_freerun_clk_1  [get_bd_pins gtwiz_freerun_clk] \
  [get_bd_pins gtwiz_versal/gtwiz_freerun_clk]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX0_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX0_ch_rxdata] \
  [get_bd_pins INTF0_RX0_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX1_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX1_ch_rxdata] \
  [get_bd_pins INTF0_RX1_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX2_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX2_ch_rxdata] \
  [get_bd_pins INTF0_RX2_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX3_ch_rxdata  [get_bd_pins gtwiz_versal/INTF0_RX3_ch_rxdata] \
  [get_bd_pins INTF0_RX3_ch_rxdata]
  connect_bd_net -net gtwiz_versal_0_INTF0_TX_clr_out  [get_bd_pins gtwiz_versal/INTF0_TX_clr_out] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_CLR]
  connect_bd_net -net gtwiz_versal_0_INTF0_TX_clrb_leaf_out  [get_bd_pins gtwiz_versal/INTF0_TX_clrb_leaf_out] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net gtwiz_versal_0_QUAD0_TX0_outclk  [get_bd_pins gtwiz_versal/QUAD0_TX0_outclk] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_I]
  connect_bd_net -net gtwiz_versal_INTF0_RX_clr_out  [get_bd_pins gtwiz_versal/INTF0_RX_clr_out] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_CLR]
  connect_bd_net -net gtwiz_versal_INTF0_RX_clrb_leaf_out  [get_bd_pins gtwiz_versal/INTF0_RX_clrb_leaf_out] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins gtwiz_versal/INTF0_rst_rx_done_out] \
  [get_bd_pins INTF0_rst_rx_done_out]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_versal/INTF0_rst_tx_done_out] \
  [get_bd_pins INTF0_rst_tx_done_out]
  connect_bd_net -net gtwiz_versal_QUAD0_RX0_outclk  [get_bd_pins gtwiz_versal/QUAD0_RX0_outclk] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_I]
  connect_bd_net -net gtwiz_versal_gtpowergood  [get_bd_pins gtwiz_versal/gtpowergood] \
  [get_bd_pins gtpowergood]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_high/dout] \
  [get_bd_pins gt_ref_clk_usr/BUFG_GT_CE] \
  [get_bd_pins mbufg_gt_tx/MBUFG_GT_CE] \
  [get_bd_pins mbufg_gt_rx/MBUFG_GT_CE]
  connect_bd_net -net ilslice_gt_line_rate_Dout  [get_bd_pins ilslice_gt_line_rate/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX0_ch_rxrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX1_ch_rxrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX2_ch_rxrate] \
  [get_bd_pins gtwiz_versal/INTF0_RX3_ch_rxrate]
  connect_bd_net -net ilslice_gt_loopback_Dout  [get_bd_pins ilslice_gt_loopback/Dout] \
  [get_bd_pins gtwiz_versal/QUAD0_ch0_loopback] \
  [get_bd_pins gtwiz_versal/QUAD0_ch1_loopback] \
  [get_bd_pins gtwiz_versal/QUAD0_ch2_loopback] \
  [get_bd_pins gtwiz_versal/QUAD0_ch3_loopback]
  connect_bd_net -net ilslice_gt_rst_all_in_Dout  [get_bd_pins ilslice_gt_rst_all_in/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_all_in]
  connect_bd_net -net ilslice_gt_rst_rx_datapath_Dout  [get_bd_pins ilslice_gt_rst_rx_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_rx_datapath_in]
  connect_bd_net -net ilslice_gt_rst_rx_pll_and_datapath_Dout  [get_bd_pins ilslice_gt_rst_rx_pll_and_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_rx_pll_and_datapath_in]
  connect_bd_net -net ilslice_gt_rst_tx_datapath_Dout  [get_bd_pins ilslice_gt_rst_tx_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_datapath_in]
  connect_bd_net -net ilslice_gt_rst_tx_pll_and_datapath_Dout  [get_bd_pins ilslice_gt_rst_tx_pll_and_datapath/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_pll_and_datapath_in]
  connect_bd_net -net ilslice_gt_rxcdrhold_Dout  [get_bd_pins ilslice_gt_rxcdrhold/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_RX0_ch_rxcdrhold] \
  [get_bd_pins gtwiz_versal/INTF0_RX1_ch_rxcdrhold] \
  [get_bd_pins gtwiz_versal/INTF0_RX2_ch_rxcdrhold] \
  [get_bd_pins gtwiz_versal/INTF0_RX3_ch_rxcdrhold]
  connect_bd_net -net ilslice_gt_txmaincursor_Dout  [get_bd_pins ilslice_gt_txmaincursor/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txmaincursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txmaincursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txmaincursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txmaincursor]
  connect_bd_net -net ilslice_gt_txpostcursor_Dout  [get_bd_pins ilslice_gt_txpostcursor/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txpostcursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txpostcursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txpostcursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txpostcursor]
  connect_bd_net -net ilslice_gt_txprecursor_Dout  [get_bd_pins ilslice_gt_txprecursor/Dout] \
  [get_bd_pins gtwiz_versal/INTF0_TX0_ch_txprecursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX1_ch_txprecursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX2_ch_txprecursor] \
  [get_bd_pins gtwiz_versal/INTF0_TX3_ch_txprecursor]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins mbufg_gt_rx/MBUFG_GT_O1] \
  [get_bd_pins qsfp_rx_usr_clk_664MHz]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O2  [get_bd_pins mbufg_gt_rx/MBUFG_GT_O2] \
  [get_bd_pins qsfp_rx_usr_clk_332MHz] \
  [get_bd_pins gtwiz_versal/QUAD0_RX1_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX2_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX3_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX0_usrclk]
  connect_bd_net -net mbufg_gt_tx_0_MBUFG_GT_O1  [get_bd_pins mbufg_gt_tx/MBUFG_GT_O1] \
  [get_bd_pins qsfp_tx_usr_clk_664MHz]
  connect_bd_net -net util_ds_buf_0_IBUFDS_GTME5_O  [get_bd_pins gt_ref_clk/IBUFDS_GTME5_O] \
  [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK0]
  connect_bd_net -net util_ds_buf_0_IBUFDS_GTME5_ODIV2  [get_bd_pins gt_ref_clk/IBUFDS_GTME5_ODIV2] \
  [get_bd_pins gt_ref_clk_usr/BUFG_GT_I]
  connect_bd_net -net util_ds_buf_0_MBUFG_GT_O2  [get_bd_pins mbufg_gt_tx/MBUFG_GT_O2] \
  [get_bd_pins qsfp_tx_usr_clk_332MHz] \
  [get_bd_pins gtwiz_versal/QUAD0_TX1_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX2_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX3_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX0_usrclk]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins gt_ref_clk_usr/BUFG_GT_O] \
  [get_bd_pins gt_ref_clk_322MHz]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_rx_alt
proc create_hier_cell_clock_to_serdes_rx_alt { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_rx_alt() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dcmac200g_ctl_port
proc create_hier_cell_dcmac200g_ctl_port { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dcmac200g_ctl_port() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir O -from 15 -to 0 dout
  create_bd_pin -dir O -from 63 -to 0 dout1
  create_bd_pin -dir O -from 63 -to 0 dout2
  create_bd_pin -dir O -from 63 -to 0 dout3
  create_bd_pin -dir O -from 63 -to 0 dout4
  create_bd_pin -dir O -from 63 -to 0 dout5
  create_bd_pin -dir O -from 63 -to 0 dout6
  create_bd_pin -dir O -from 63 -to 0 dout7
  create_bd_pin -dir O -from 63 -to 0 dout8
  create_bd_pin -dir O -from 63 -to 0 dout9
  create_bd_pin -dir O -from 63 -to 0 dout10
  create_bd_pin -dir O -from 63 -to 0 dout11
  create_bd_pin -dir O -from 63 -to 0 dout12
  create_bd_pin -dir O -from 63 -to 0 dout13
  create_bd_pin -dir O -from 63 -to 0 dout14
  create_bd_pin -dir O -from 63 -to 0 dout15
  create_bd_pin -dir O -from 63 -to 0 dout16
  create_bd_pin -dir O -from 63 -to 0 dout17
  create_bd_pin -dir O -from 63 -to 0 dout18
  create_bd_pin -dir O -from 63 -to 0 dout19
  create_bd_pin -dir O -from 63 -to 0 dout20

  # Create instance: default_vl_length_200GE_or_400GE, and set properties
  set default_vl_length_200GE_or_400GE [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 default_vl_length_200GE_or_400GE ]
  set_property -dict [list \
    CONFIG.CONST_VAL {256} \
    CONFIG.CONST_WIDTH {16} \
  ] $default_vl_length_200GE_or_400GE


  # Create instance: ctl_tx_vl_marker_id0_100ge, and set properties
  set ctl_tx_vl_marker_id0_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id0_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xc16821003e97de00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id0_100ge


  # Create instance: ctl_tx_vl_marker_id1_100ge, and set properties
  set ctl_tx_vl_marker_id1_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id1_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x9d718e00628e7100} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id1_100ge


  # Create instance: ctl_tx_vl_marker_id2_100ge, and set properties
  set ctl_tx_vl_marker_id2_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id2_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x594be800a6b41700} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id2_100ge


  # Create instance: ctl_tx_vl_marker_id3_100ge, and set properties
  set ctl_tx_vl_marker_id3_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id3_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x4d957b00b26a8400} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id3_100ge


  # Create instance: ctl_tx_vl_marker_id4_100ge, and set properties
  set ctl_tx_vl_marker_id4_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id4_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xf50709000af8f600} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id4_100ge


  # Create instance: ctl_tx_vl_marker_id5_100ge, and set properties
  set ctl_tx_vl_marker_id5_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id5_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xdd14c20022eb3d00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id5_100ge


  # Create instance: ctl_tx_vl_marker_id6_100ge, and set properties
  set ctl_tx_vl_marker_id6_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id6_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x9a4a260065b5d900} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id6_100ge


  # Create instance: ctl_tx_vl_marker_id7_100ge, and set properties
  set ctl_tx_vl_marker_id7_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id7_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x7b45660084ba9900} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id7_100ge


  # Create instance: ctl_tx_vl_marker_id8_100ge, and set properties
  set ctl_tx_vl_marker_id8_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id8_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xa02476005fdb8900} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id8_100ge


  # Create instance: ctl_tx_vl_marker_id9_100ge, and set properties
  set ctl_tx_vl_marker_id9_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id9_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x68c9fb0097360400} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id9_100ge


  # Create instance: ctl_tx_vl_marker_id10_100ge, and set properties
  set ctl_tx_vl_marker_id10_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id10_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xfd6c990002936600} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id10_100ge


  # Create instance: ctl_tx_vl_marker_id11_100ge, and set properties
  set ctl_tx_vl_marker_id11_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id11_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xb9915500466eaa00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id11_100ge


  # Create instance: ctl_tx_vl_marker_id12_100ge, and set properties
  set ctl_tx_vl_marker_id12_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id12_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x5cb9b200a3464d00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id12_100ge


  # Create instance: ctl_tx_vl_marker_id13_100ge, and set properties
  set ctl_tx_vl_marker_id13_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id13_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x1af8bd00e5074200} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id13_100ge


  # Create instance: ctl_tx_vl_marker_id14_100ge, and set properties
  set ctl_tx_vl_marker_id14_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id14_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x83c7ca007c383500} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id14_100ge


  # Create instance: ctl_tx_vl_marker_id15_100ge, and set properties
  set ctl_tx_vl_marker_id15_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id15_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x3536cd00cac93200} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id15_100ge


  # Create instance: ctl_tx_vl_marker_id16_100ge, and set properties
  set ctl_tx_vl_marker_id16_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id16_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xc4314c003bceb300} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id16_100ge


  # Create instance: ctl_tx_vl_marker_id17_100ge, and set properties
  set ctl_tx_vl_marker_id17_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id17_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xadd6b70052294800} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id17_100ge


  # Create instance: ctl_tx_vl_marker_id18_100ge, and set properties
  set ctl_tx_vl_marker_id18_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id18_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x5f662a00a099d500} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id18_100ge


  # Create instance: ctl_tx_vl_marker_id19_100ge, and set properties
  set ctl_tx_vl_marker_id19_100ge [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ctl_tx_vl_marker_id19_100ge ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0xc0f0e5003f0f1a00} \
    CONFIG.CONST_WIDTH {64} \
  ] $ctl_tx_vl_marker_id19_100ge


  # Create port connections
  connect_bd_net -net ctl_tx_vl_marker_id0_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id0_100ge/dout] \
  [get_bd_pins dout1]
  connect_bd_net -net ctl_tx_vl_marker_id10_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id10_100ge/dout] \
  [get_bd_pins dout11]
  connect_bd_net -net ctl_tx_vl_marker_id11_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id11_100ge/dout] \
  [get_bd_pins dout12]
  connect_bd_net -net ctl_tx_vl_marker_id12_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id12_100ge/dout] \
  [get_bd_pins dout13]
  connect_bd_net -net ctl_tx_vl_marker_id13_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id13_100ge/dout] \
  [get_bd_pins dout14]
  connect_bd_net -net ctl_tx_vl_marker_id14_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id14_100ge/dout] \
  [get_bd_pins dout15]
  connect_bd_net -net ctl_tx_vl_marker_id15_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id15_100ge/dout] \
  [get_bd_pins dout16]
  connect_bd_net -net ctl_tx_vl_marker_id16_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id16_100ge/dout] \
  [get_bd_pins dout17]
  connect_bd_net -net ctl_tx_vl_marker_id17_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id17_100ge/dout] \
  [get_bd_pins dout18]
  connect_bd_net -net ctl_tx_vl_marker_id18_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id18_100ge/dout] \
  [get_bd_pins dout19]
  connect_bd_net -net ctl_tx_vl_marker_id19_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id19_100ge/dout] \
  [get_bd_pins dout20]
  connect_bd_net -net ctl_tx_vl_marker_id1_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id1_100ge/dout] \
  [get_bd_pins dout2]
  connect_bd_net -net ctl_tx_vl_marker_id2_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id2_100ge/dout] \
  [get_bd_pins dout3]
  connect_bd_net -net ctl_tx_vl_marker_id3_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id3_100ge/dout] \
  [get_bd_pins dout4]
  connect_bd_net -net ctl_tx_vl_marker_id4_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id4_100ge/dout] \
  [get_bd_pins dout5]
  connect_bd_net -net ctl_tx_vl_marker_id5_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id5_100ge/dout] \
  [get_bd_pins dout6]
  connect_bd_net -net ctl_tx_vl_marker_id6_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id6_100ge/dout] \
  [get_bd_pins dout7]
  connect_bd_net -net ctl_tx_vl_marker_id7_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id7_100ge/dout] \
  [get_bd_pins dout8]
  connect_bd_net -net ctl_tx_vl_marker_id8_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id8_100ge/dout] \
  [get_bd_pins dout9]
  connect_bd_net -net ctl_tx_vl_marker_id9_100ge_dout  [get_bd_pins ctl_tx_vl_marker_id9_100ge/dout] \
  [get_bd_pins dout10]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins default_vl_length_200GE_or_400GE/dout] \
  [get_bd_pins dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_rx
proc create_hier_cell_clock_to_serdes_rx { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_rx() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_tx_alt
proc create_hier_cell_clock_to_serdes_tx_alt { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_tx_alt() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_to_serdes_tx
proc create_hier_cell_clock_to_serdes_tx { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_to_serdes_tx() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In1
  create_bd_pin -dir O -from 5 -to 0 dout

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_0


  # Create port connections
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net ilconstant_0_dout1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O1  [get_bd_pins In1] \
  [get_bd_pins ilconcat_0/In1] \
  [get_bd_pins ilconcat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: control_interface
proc create_hier_cell_control_interface_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_control_interface_1() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 dcmac_m_axi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 gt_m_axi


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir O -from 6 -to 0 usr_reset
  create_bd_pin -dir O -from 31 -to 0 gt_control
  create_bd_pin -dir I -from 0 -to 0 gtpowergood
  create_bd_pin -dir I -from 0 -to 0 gt_tx_reset_done
  create_bd_pin -dir I -from 0 -to 0 gt_rx_reset_done

  # Create instance: axi_gpio_resets, and set properties
  set axi_gpio_resets [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_resets ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {7} \
  ] $axi_gpio_resets


  # Create instance: smartconnect_ctrl_if, and set properties
  set smartconnect_ctrl_if [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_ctrl_if ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_ctrl_if


  # Create instance: axi_gpio_gt_monitor, and set properties
  set axi_gpio_gt_monitor [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gt_monitor ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_GPIO_WIDTH {3} \
  ] $axi_gpio_gt_monitor


  # Create instance: axi_gpio_gt_control, and set properties
  set axi_gpio_gt_control [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gt_control ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x34186000} \
  ] $axi_gpio_gt_control


  # Create instance: ilconcat_gt_monitor, and set properties
  set ilconcat_gt_monitor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_gt_monitor ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_gt_monitor


  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_cips_M01_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_ctrl_if/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins dcmac_m_axi] [get_bd_intf_pins smartconnect_ctrl_if/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins gt_m_axi] [get_bd_intf_pins smartconnect_ctrl_if/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_ctrl_if/M02_AXI] [get_bd_intf_pins axi_gpio_gt_control/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_ctrl_if/M03_AXI] [get_bd_intf_pins axi_gpio_resets/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins smartconnect_ctrl_if/M04_AXI] [get_bd_intf_pins axi_gpio_gt_monitor/S_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_resets/gpio_io_o] \
  [get_bd_pins usr_reset]
  connect_bd_net -net axi_gpio_gt_control_gpio_io_o  [get_bd_pins axi_gpio_gt_control/gpio_io_o] \
  [get_bd_pins gt_control]
  connect_bd_net -net clock_reset_clk_usr_0  [get_bd_pins aclk] \
  [get_bd_pins smartconnect_ctrl_if/aclk] \
  [get_bd_pins axi_gpio_gt_control/s_axi_aclk] \
  [get_bd_pins axi_gpio_gt_monitor/s_axi_aclk] \
  [get_bd_pins axi_gpio_resets/s_axi_aclk]
  connect_bd_net -net clock_reset_resetn_usr_0_periph  [get_bd_pins aresetn] \
  [get_bd_pins smartconnect_ctrl_if/aresetn] \
  [get_bd_pins axi_gpio_gt_control/s_axi_aresetn] \
  [get_bd_pins axi_gpio_gt_monitor/s_axi_aresetn] \
  [get_bd_pins axi_gpio_resets/s_axi_aresetn]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins gt_rx_reset_done] \
  [get_bd_pins ilconcat_gt_monitor/In2]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins gt_tx_reset_done] \
  [get_bd_pins ilconcat_gt_monitor/In1]
  connect_bd_net -net gtwiz_wrapper_gtpowergood  [get_bd_pins gtpowergood] \
  [get_bd_pins ilconcat_gt_monitor/In0]
  connect_bd_net -net ilconcat_0_dout2  [get_bd_pins ilconcat_gt_monitor/dout] \
  [get_bd_pins axi_gpio_gt_monitor/gpio_io_i]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dcmac_wrapper
proc create_hier_cell_dcmac_wrapper_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dcmac_wrapper_1() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis0_pkt_out

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis0_pkt_in

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_4x

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 Quad0_AXI_LITE


  # Create pins
  create_bd_pin -dir I -type clk tx_axi_clk
  create_bd_pin -dir I -type rst aresetn_axis_seg_in
  create_bd_pin -dir I -type clk s_axi_clk
  create_bd_pin -dir I -type rst s_axi_resetn
  create_bd_pin -dir I -type clk tx_core_clk
  create_bd_pin -dir I -type rst rx_core_reset
  create_bd_pin -dir I -type rst tx_core_reset
  create_bd_pin -dir I -type rst aresetn_axis_seg_in1
  create_bd_pin -dir I -from 0 -to 0 ts_clk
  create_bd_pin -dir O INTF0_rst_tx_done_out
  create_bd_pin -dir O INTF0_rst_rx_done_out
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk gt_ref_clk_322MHz
  create_bd_pin -dir I -from 31 -to 0 gt_control
  create_bd_pin -dir I -from 6 -to 0 gt_reseet
  create_bd_pin -dir O gtpowergood

  # Create instance: axis_seg_to_unseg_rx, and set properties
  set block_name axis_seg_to_unseg_converter
  set block_cell_name axis_seg_to_unseg_rx
  if { [catch {set axis_seg_to_unseg_rx [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_seg_to_unseg_rx eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: dcmac, and set properties
  set dcmac [ create_bd_cell -type ip -vlnv xilinx.com:ip:dcmac:3.0 dcmac ]
  set_property -dict [list \
    CONFIG.DCMAC_LOCATION_C0 {DCMAC_X0Y2} \
    CONFIG.GT_PIPELINE_STAGES {7} \
    CONFIG.GT_REF_CLK_FREQ_C0 {322.265625} \
    CONFIG.IS_GT_WIZ_OLD {0} \
    CONFIG.MAC_PORT0_CONFIG_C0 {200GAUI-4} \
    CONFIG.MAC_PORT0_RX_STRIP_C0 {1} \
    CONFIG.MAC_PORT1_RX_STRIP_C0 {1} \
    CONFIG.MAC_PORT2_ENABLE_C0 {0} \
    CONFIG.MAC_PORT3_ENABLE_C0 {0} \
    CONFIG.MAC_PORT4_ENABLE_C0 {0} \
    CONFIG.MAC_PORT5_ENABLE_C0 {0} \
  ] $dcmac


  # Create instance: axis_unseg_to_seg_tx, and set properties
  set block_name axis_unseg_to_seg_converter
  set block_cell_name axis_unseg_to_seg_tx
  if { [catch {set axis_unseg_to_seg_tx [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_unseg_to_seg_tx eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: flexif_clk, and set properties
  set flexif_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 flexif_clk ]
  set_property CONFIG.NUM_PORTS {6} $flexif_clk


  # Create instance: ts_clk, and set properties
  set ts_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ts_clk ]
  set_property CONFIG.NUM_PORTS {6} $ts_clk


  # Create instance: clock_to_serdes_tx
  create_hier_cell_clock_to_serdes_tx_1 $hier_obj clock_to_serdes_tx

  # Create instance: clock_to_serdes_tx_alt
  create_hier_cell_clock_to_serdes_tx_alt_1 $hier_obj clock_to_serdes_tx_alt

  # Create instance: clock_to_serdes_rx
  create_hier_cell_clock_to_serdes_rx_1 $hier_obj clock_to_serdes_rx

  # Create instance: dcmac200g_ctl_port
  create_hier_cell_dcmac200g_ctl_port_1 $hier_obj dcmac200g_ctl_port

  # Create instance: clock_to_serdes_rx_alt
  create_hier_cell_clock_to_serdes_rx_alt_1 $hier_obj clock_to_serdes_rx_alt

  # Create instance: gtwiz_wrapper
  create_hier_cell_gtwiz_wrapper_1 $hier_obj gtwiz_wrapper

  # Create interface connections
  connect_bd_intf_net -intf_net axis_dwidth_converter_tx_M_AXIS [get_bd_intf_pins s_axis0_pkt_in] [get_bd_intf_pins axis_unseg_to_seg_tx/s_axis0_pkt_in]
  connect_bd_intf_net -intf_net axis_seg_to_unseg_co_0_m_axis0_pkt_out [get_bd_intf_pins m_axis0_pkt_out] [get_bd_intf_pins axis_seg_to_unseg_rx/m_axis0_pkt_out]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins qsfp0_4x] [get_bd_intf_pins gtwiz_wrapper/GT_Serial]
  connect_bd_intf_net -intf_net qsfp0_322mhz_1 [get_bd_intf_pins qsfp0_322mhz] [get_bd_intf_pins gtwiz_wrapper/qsfp0_322mhz]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins dcmac/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins Quad0_AXI_LITE] [get_bd_intf_pins gtwiz_wrapper/Quad0_AXI_LITE]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins gt_reseet] \
  [get_bd_pins gtwiz_wrapper/gt_reset]
  connect_bd_net -net axi_gpio_gt_control_gpio_io_o  [get_bd_pins gt_control] \
  [get_bd_pins gtwiz_wrapper/gt_control]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat0_out] \
  [get_bd_pins dcmac/tx_axis_tdata0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat1_out] \
  [get_bd_pins dcmac/tx_axis_tdata1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat2_out] \
  [get_bd_pins dcmac/tx_axis_tdata2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat3_out] \
  [get_bd_pins dcmac/tx_axis_tdata3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop3]
  connect_bd_net -net axis_unseg_to_seg_co_0_tx_axis_tvalid_out  [get_bd_pins axis_unseg_to_seg_tx/tx_axis_tvalid_out] \
  [get_bd_pins dcmac/tx_axis_tvalid_0]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins tx_core_clk] \
  [get_bd_pins dcmac/tx_core_clk] \
  [get_bd_pins dcmac/rx_core_clk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins tx_axi_clk] \
  [get_bd_pins dcmac/tx_axi_clk] \
  [get_bd_pins dcmac/rx_axi_clk] \
  [get_bd_pins dcmac/rx_macif_clk] \
  [get_bd_pins dcmac/tx_macif_clk] \
  [get_bd_pins flexif_clk/In0] \
  [get_bd_pins flexif_clk/In1] \
  [get_bd_pins flexif_clk/In2] \
  [get_bd_pins flexif_clk/In3] \
  [get_bd_pins flexif_clk/In4] \
  [get_bd_pins flexif_clk/In5] \
  [get_bd_pins axis_seg_to_unseg_rx/aclk_axis_seg_in] \
  [get_bd_pins axis_unseg_to_seg_tx/aclk_axis_seg_in]
  connect_bd_net -net clk_wizard_0_clk_out3  [get_bd_pins ts_clk] \
  [get_bd_pins ts_clk/In1] \
  [get_bd_pins ts_clk/In2] \
  [get_bd_pins ts_clk/In3] \
  [get_bd_pins ts_clk/In4] \
  [get_bd_pins ts_clk/In5] \
  [get_bd_pins ts_clk/In0]
  connect_bd_net -net clock_reset_clk_usr_0  [get_bd_pins s_axi_clk] \
  [get_bd_pins dcmac/s_axi_aclk] \
  [get_bd_pins gtwiz_wrapper/gtwiz_freerun_clk]
  connect_bd_net -net clock_reset_resetn_usr_0_periph  [get_bd_pins s_axi_resetn] \
  [get_bd_pins dcmac/s_axi_aresetn] \
  [get_bd_pins gtwiz_wrapper/QUAD0_s_axi_lite_resetn]
  connect_bd_net -net clock_to_serdes_rx_alt_dout  [get_bd_pins clock_to_serdes_rx_alt/dout] \
  [get_bd_pins dcmac/rx_alt_serdes_clk]
  connect_bd_net -net clock_to_serdes_tx_alt_dout  [get_bd_pins clock_to_serdes_tx_alt/dout] \
  [get_bd_pins dcmac/tx_alt_serdes_clk]
  connect_bd_net -net clock_to_serdes_tx_dout  [get_bd_pins clock_to_serdes_tx/dout] \
  [get_bd_pins dcmac/tx_serdes_clk]
  connect_bd_net -net dcmac200g_ctl_port_dout1  [get_bd_pins dcmac200g_ctl_port/dout1] \
  [get_bd_pins dcmac/ctl_vl_marker_id0]
  connect_bd_net -net dcmac200g_ctl_port_dout2  [get_bd_pins dcmac200g_ctl_port/dout2] \
  [get_bd_pins dcmac/ctl_vl_marker_id1]
  connect_bd_net -net dcmac200g_ctl_port_dout3  [get_bd_pins dcmac200g_ctl_port/dout3] \
  [get_bd_pins dcmac/ctl_vl_marker_id2]
  connect_bd_net -net dcmac200g_ctl_port_dout4  [get_bd_pins dcmac200g_ctl_port/dout4] \
  [get_bd_pins dcmac/ctl_vl_marker_id3]
  connect_bd_net -net dcmac200g_ctl_port_dout5  [get_bd_pins dcmac200g_ctl_port/dout5] \
  [get_bd_pins dcmac/ctl_vl_marker_id4]
  connect_bd_net -net dcmac200g_ctl_port_dout6  [get_bd_pins dcmac200g_ctl_port/dout6] \
  [get_bd_pins dcmac/ctl_vl_marker_id5]
  connect_bd_net -net dcmac200g_ctl_port_dout7  [get_bd_pins dcmac200g_ctl_port/dout7] \
  [get_bd_pins dcmac/ctl_vl_marker_id6]
  connect_bd_net -net dcmac200g_ctl_port_dout8  [get_bd_pins dcmac200g_ctl_port/dout8] \
  [get_bd_pins dcmac/ctl_vl_marker_id7]
  connect_bd_net -net dcmac200g_ctl_port_dout9  [get_bd_pins dcmac200g_ctl_port/dout9] \
  [get_bd_pins dcmac/ctl_vl_marker_id8]
  connect_bd_net -net dcmac200g_ctl_port_dout10  [get_bd_pins dcmac200g_ctl_port/dout10] \
  [get_bd_pins dcmac/ctl_vl_marker_id9]
  connect_bd_net -net dcmac200g_ctl_port_dout11  [get_bd_pins dcmac200g_ctl_port/dout11] \
  [get_bd_pins dcmac/ctl_vl_marker_id10]
  connect_bd_net -net dcmac200g_ctl_port_dout12  [get_bd_pins dcmac200g_ctl_port/dout12] \
  [get_bd_pins dcmac/ctl_vl_marker_id11]
  connect_bd_net -net dcmac200g_ctl_port_dout13  [get_bd_pins dcmac200g_ctl_port/dout13] \
  [get_bd_pins dcmac/ctl_vl_marker_id12]
  connect_bd_net -net dcmac200g_ctl_port_dout14  [get_bd_pins dcmac200g_ctl_port/dout14] \
  [get_bd_pins dcmac/ctl_vl_marker_id13]
  connect_bd_net -net dcmac200g_ctl_port_dout15  [get_bd_pins dcmac200g_ctl_port/dout15] \
  [get_bd_pins dcmac/ctl_vl_marker_id14]
  connect_bd_net -net dcmac200g_ctl_port_dout16  [get_bd_pins dcmac200g_ctl_port/dout16] \
  [get_bd_pins dcmac/ctl_vl_marker_id15]
  connect_bd_net -net dcmac200g_ctl_port_dout17  [get_bd_pins dcmac200g_ctl_port/dout17] \
  [get_bd_pins dcmac/ctl_vl_marker_id16]
  connect_bd_net -net dcmac200g_ctl_port_dout18  [get_bd_pins dcmac200g_ctl_port/dout18] \
  [get_bd_pins dcmac/ctl_vl_marker_id17]
  connect_bd_net -net dcmac200g_ctl_port_dout19  [get_bd_pins dcmac200g_ctl_port/dout19] \
  [get_bd_pins dcmac/ctl_vl_marker_id18]
  connect_bd_net -net dcmac200g_ctl_port_dout20  [get_bd_pins dcmac200g_ctl_port/dout20] \
  [get_bd_pins dcmac/ctl_vl_marker_id19]
  connect_bd_net -net dcmac_0_txdata_out_0  [get_bd_pins dcmac/txdata_out_0] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX0_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_1  [get_bd_pins dcmac/txdata_out_1] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX1_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_2  [get_bd_pins dcmac/txdata_out_2] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX2_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_3  [get_bd_pins dcmac/txdata_out_3] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX3_ch_txdata]
  connect_bd_net -net dcmac_gt_rx_reset_done_core_clk_syncer_reset  [get_bd_pins rx_core_reset] \
  [get_bd_pins dcmac/rx_core_reset]
  connect_bd_net -net dcmac_gt_tx_reset_done_core_clk_syncer_reset  [get_bd_pins tx_core_reset] \
  [get_bd_pins dcmac/tx_core_reset]
  connect_bd_net -net dcmac_rx_axis_tdata0  [get_bd_pins dcmac/rx_axis_tdata0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat0_in]
  connect_bd_net -net dcmac_rx_axis_tdata1  [get_bd_pins dcmac/rx_axis_tdata1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat1_in]
  connect_bd_net -net dcmac_rx_axis_tdata2  [get_bd_pins dcmac/rx_axis_tdata2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat2_in]
  connect_bd_net -net dcmac_rx_axis_tdata3  [get_bd_pins dcmac/rx_axis_tdata3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena0  [get_bd_pins dcmac/rx_axis_tuser_ena0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena1  [get_bd_pins dcmac/rx_axis_tuser_ena1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena2  [get_bd_pins dcmac/rx_axis_tuser_ena2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena3  [get_bd_pins dcmac/rx_axis_tuser_ena3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop0  [get_bd_pins dcmac/rx_axis_tuser_eop0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop1  [get_bd_pins dcmac/rx_axis_tuser_eop1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop2  [get_bd_pins dcmac/rx_axis_tuser_eop2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop3  [get_bd_pins dcmac/rx_axis_tuser_eop3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err0  [get_bd_pins dcmac/rx_axis_tuser_err0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err1  [get_bd_pins dcmac/rx_axis_tuser_err1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err2  [get_bd_pins dcmac/rx_axis_tuser_err2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err3  [get_bd_pins dcmac/rx_axis_tuser_err3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty0  [get_bd_pins dcmac/rx_axis_tuser_mty0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty1  [get_bd_pins dcmac/rx_axis_tuser_mty1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty2  [get_bd_pins dcmac/rx_axis_tuser_mty2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty3  [get_bd_pins dcmac/rx_axis_tuser_mty3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop0  [get_bd_pins dcmac/rx_axis_tuser_sop0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop1  [get_bd_pins dcmac/rx_axis_tuser_sop1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop2  [get_bd_pins dcmac/rx_axis_tuser_sop2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop3  [get_bd_pins dcmac/rx_axis_tuser_sop3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop3_in]
  connect_bd_net -net dcmac_rx_axis_tvalid_0  [get_bd_pins dcmac/rx_axis_tvalid_0] \
  [get_bd_pins axis_seg_to_unseg_rx/rx_axis_tvalid_i]
  connect_bd_net -net dcmac_tx_axis_tready_0  [get_bd_pins dcmac/tx_axis_tready_0] \
  [get_bd_pins axis_unseg_to_seg_tx/tx_axis_tready_in]
  connect_bd_net -net flexif_clk_dout  [get_bd_pins flexif_clk/dout] \
  [get_bd_pins dcmac/rx_flexif_clk] \
  [get_bd_pins dcmac/tx_flexif_clk]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX0_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX0_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_0]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX1_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX1_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_1]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX2_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX2_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_2]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX3_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX3_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_3]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins gtwiz_wrapper/INTF0_rst_rx_done_out] \
  [get_bd_pins INTF0_rst_rx_done_out]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_wrapper/INTF0_rst_tx_done_out] \
  [get_bd_pins INTF0_rst_tx_done_out]
  connect_bd_net -net gtwiz_wrapper_gtpowergood  [get_bd_pins gtwiz_wrapper/gtpowergood] \
  [get_bd_pins gtpowergood]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins clock_to_serdes_rx/dout] \
  [get_bd_pins dcmac/rx_serdes_clk]
  connect_bd_net -net ilconcat_0_dout1  [get_bd_pins ts_clk/dout] \
  [get_bd_pins dcmac/ts_clk]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins dcmac200g_ctl_port/dout] \
  [get_bd_pins dcmac/ctl_rx_custom_vl_length_minus1] \
  [get_bd_pins dcmac/ctl_tx_custom_vl_length_minus1]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O2  [get_bd_pins gtwiz_wrapper/qsfp_rx_usr_clk_332MHz] \
  [get_bd_pins clock_to_serdes_rx_alt/In1]
  connect_bd_net -net mbufg_gt_tx_0_MBUFG_GT_O1  [get_bd_pins gtwiz_wrapper/qsfp_tx_usr_clk_664MHz] \
  [get_bd_pins clock_to_serdes_tx/In1]
  connect_bd_net -net qsfp_rx_usr_clk_664MHz  [get_bd_pins gtwiz_wrapper/qsfp_rx_usr_clk_664MHz] \
  [get_bd_pins clock_to_serdes_rx/In1]
  connect_bd_net -net sys_reset_rx_peripheral_aresetn  [get_bd_pins aresetn_axis_seg_in] \
  [get_bd_pins axis_seg_to_unseg_rx/aresetn_axis_seg_in]
  connect_bd_net -net sys_reset_tx_peripheral_aresetn  [get_bd_pins aresetn_axis_seg_in1] \
  [get_bd_pins axis_unseg_to_seg_tx/aresetn_axis_seg_in]
  connect_bd_net -net util_ds_buf_0_MBUFG_GT_O2  [get_bd_pins gtwiz_wrapper/qsfp_tx_usr_clk_332MHz] \
  [get_bd_pins clock_to_serdes_tx_alt/In1]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins gtwiz_wrapper/gt_ref_clk_322MHz] \
  [get_bd_pins gt_ref_clk_322MHz]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_reset
proc create_hier_cell_clock_reset_2 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_reset_2() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir O -type clk clk_out_390MHz
  create_bd_pin -dir I -type rst gt_tx_reset_done
  create_bd_pin -dir I -type rst gt_rx_reset_done
  create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_tx_390MHz
  create_bd_pin -dir O -type clk clk_out_782MHz
  create_bd_pin -dir O -type rst reset_rx_790MHz
  create_bd_pin -dir O -type rst reset_tx_790MHz
  create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_rx_390MHz
  create_bd_pin -dir I -type clk gt_ref_clk_322MHz
  create_bd_pin -dir O -type clk clk_out_350MHz
  create_bd_pin -dir I -from 6 -to 0 reset_usr_txrx_path
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn

  # Create instance: dcmac_gt_tx_reset_done_axis_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_tx_reset_done_axis_clk_syncer
  if { [catch {set dcmac_gt_tx_reset_done_axis_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_tx_reset_done_axis_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: dcmac_gt_rx_reset_done_axis_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_rx_reset_done_axis_clk_syncer
  if { [catch {set dcmac_gt_rx_reset_done_axis_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_rx_reset_done_axis_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: sys_reset_tx, and set properties
  set sys_reset_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset_tx ]

  # Create instance: dcmac_gt_rx_reset_done_core_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_rx_reset_done_core_clk_syncer
  if { [catch {set dcmac_gt_rx_reset_done_core_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_rx_reset_done_core_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: dcmac_gt_tx_reset_done_core_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_tx_reset_done_core_clk_syncer
  if { [catch {set dcmac_gt_tx_reset_done_core_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_tx_reset_done_core_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: sys_reset_rx, and set properties
  set sys_reset_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset_rx ]

  # Create instance: clk_wizard, and set properties
  set clk_wizard [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {782,390.625,350,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,true,true,false,false,false,false} \
    CONFIG.OVERRIDE_PRIMITIVE {false} \
    CONFIG.PRIM_IN_FREQ {322.265625} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {false} \
  ] $clk_wizard


  # Create instance: ilslice_reset_tx, and set properties
  set ilslice_reset_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_reset_tx ]
  set_property -dict [list \
    CONFIG.DIN_FROM {5} \
    CONFIG.DIN_TO {5} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_reset_tx


  # Create instance: ilslice_reset_rx, and set properties
  set ilslice_reset_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_reset_rx ]
  set_property -dict [list \
    CONFIG.DIN_FROM {6} \
    CONFIG.DIN_TO {6} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_reset_rx


  # Create instance: ilreduced_logic_or_reset_tx, and set properties
  set ilreduced_logic_or_reset_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic:1.0 ilreduced_logic_or_reset_tx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {2} \
  ] $ilreduced_logic_or_reset_tx


  # Create instance: ilconcat_reset_tx, and set properties
  set ilconcat_reset_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_reset_tx ]

  # Create instance: ilreduced_logic_or_reset_rx, and set properties
  set ilreduced_logic_or_reset_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic:1.0 ilreduced_logic_or_reset_rx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {2} \
  ] $ilreduced_logic_or_reset_rx


  # Create instance: ilconcat_reset_rx, and set properties
  set ilconcat_reset_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_reset_rx ]

  # Create instance: sys_reset_axi, and set properties
  set sys_reset_axi [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset_axi ]

  # Create instance: ilvector_logic_rx, and set properties
  set ilvector_logic_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic:1.0 ilvector_logic_rx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_rx


  # Create instance: ilvector_logic_tx, and set properties
  set ilvector_logic_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic:1.0 ilvector_logic_tx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_tx


  # Create port connections
  connect_bd_net -net Din_1  [get_bd_pins reset_usr_txrx_path] \
  [get_bd_pins ilslice_reset_tx/Din] \
  [get_bd_pins ilslice_reset_rx/Din]
  connect_bd_net -net aclk_1  [get_bd_pins aclk] \
  [get_bd_pins sys_reset_axi/slowest_sync_clk]
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins sys_reset_axi/ext_reset_in]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins clk_wizard/clk_out1] \
  [get_bd_pins clk_out_782MHz] \
  [get_bd_pins dcmac_gt_rx_reset_done_core_clk_syncer/clk] \
  [get_bd_pins dcmac_gt_tx_reset_done_core_clk_syncer/clk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins clk_wizard/clk_out2] \
  [get_bd_pins clk_out_390MHz] \
  [get_bd_pins sys_reset_rx/slowest_sync_clk] \
  [get_bd_pins sys_reset_tx/slowest_sync_clk] \
  [get_bd_pins dcmac_gt_rx_reset_done_axis_clk_syncer/clk] \
  [get_bd_pins dcmac_gt_tx_reset_done_axis_clk_syncer/clk]
  connect_bd_net -net clk_wizard_0_clk_out3  [get_bd_pins clk_wizard/clk_out3] \
  [get_bd_pins clk_out_350MHz]
  connect_bd_net -net clk_wizard_0_locked  [get_bd_pins clk_wizard/locked] \
  [get_bd_pins sys_reset_tx/dcm_locked] \
  [get_bd_pins sys_reset_rx/dcm_locked]
  connect_bd_net -net dcmac_gt_rx_reset_done_axis_clk_syncer_resetn  [get_bd_pins dcmac_gt_rx_reset_done_axis_clk_syncer/resetn] \
  [get_bd_pins sys_reset_rx/ext_reset_in]
  connect_bd_net -net dcmac_gt_rx_reset_done_core_clk_syncer_reset  [get_bd_pins dcmac_gt_rx_reset_done_core_clk_syncer/reset] \
  [get_bd_pins reset_rx_790MHz]
  connect_bd_net -net dcmac_gt_tx_reset_done_axis_clk_syncer_resetn  [get_bd_pins dcmac_gt_tx_reset_done_axis_clk_syncer/resetn] \
  [get_bd_pins sys_reset_tx/ext_reset_in]
  connect_bd_net -net dcmac_gt_tx_reset_done_core_clk_syncer_reset  [get_bd_pins dcmac_gt_tx_reset_done_core_clk_syncer/reset] \
  [get_bd_pins reset_tx_790MHz]
  connect_bd_net -net gt_rx_reset_done_1  [get_bd_pins gt_rx_reset_done] \
  [get_bd_pins ilvector_logic_rx/Op1]
  connect_bd_net -net gt_tx_reset_done_1  [get_bd_pins gt_tx_reset_done] \
  [get_bd_pins ilvector_logic_tx/Op1]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_reset_tx/dout] \
  [get_bd_pins ilreduced_logic_or_reset_tx/Op1]
  connect_bd_net -net ilconcat_reset_rx_dout  [get_bd_pins ilconcat_reset_rx/dout] \
  [get_bd_pins ilreduced_logic_or_reset_rx/Op1]
  connect_bd_net -net ilreduced_logic_0_Res  [get_bd_pins ilreduced_logic_or_reset_tx/Res] \
  [get_bd_pins dcmac_gt_tx_reset_done_axis_clk_syncer/reset_async]
  connect_bd_net -net ilreduced_logic_or_reset_rx_Res  [get_bd_pins ilreduced_logic_or_reset_rx/Res] \
  [get_bd_pins dcmac_gt_rx_reset_done_axis_clk_syncer/reset_async]
  connect_bd_net -net ilslice_reset_rx_Dout  [get_bd_pins ilslice_reset_rx/Dout] \
  [get_bd_pins ilconcat_reset_rx/In1]
  connect_bd_net -net ilslice_reset_tx_Dout  [get_bd_pins ilslice_reset_tx/Dout] \
  [get_bd_pins ilconcat_reset_tx/In1]
  connect_bd_net -net ilvector_logic_0_Res  [get_bd_pins ilvector_logic_rx/Res] \
  [get_bd_pins ilconcat_reset_rx/In0] \
  [get_bd_pins dcmac_gt_rx_reset_done_core_clk_syncer/reset_async]
  connect_bd_net -net ilvector_logic_tx_Res  [get_bd_pins ilvector_logic_tx/Res] \
  [get_bd_pins ilconcat_reset_tx/In0] \
  [get_bd_pins dcmac_gt_tx_reset_done_core_clk_syncer/reset_async]
  connect_bd_net -net sys_reset_axi_peripheral_aresetn  [get_bd_pins sys_reset_axi/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn]
  connect_bd_net -net sys_reset_rx_peripheral_aresetn  [get_bd_pins sys_reset_rx/peripheral_aresetn] \
  [get_bd_pins aresetn_rx_390MHz]
  connect_bd_net -net sys_reset_tx_peripheral_aresetn  [get_bd_pins sys_reset_tx/peripheral_aresetn] \
  [get_bd_pins aresetn_tx_390MHz]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins gt_ref_clk_322MHz] \
  [get_bd_pins clk_wizard/clk_in1]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: control_interface
proc create_hier_cell_control_interface { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_control_interface() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 dcmac_m_axi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 gt_m_axi


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir O -from 6 -to 0 usr_reset
  create_bd_pin -dir O -from 31 -to 0 gt_control
  create_bd_pin -dir I -from 0 -to 0 gtpowergood
  create_bd_pin -dir I -from 0 -to 0 gt_tx_reset_done
  create_bd_pin -dir I -from 0 -to 0 gt_rx_reset_done

  # Create instance: axi_gpio_resets, and set properties
  set axi_gpio_resets [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_resets ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {7} \
  ] $axi_gpio_resets


  # Create instance: smartconnect_ctrl_if, and set properties
  set smartconnect_ctrl_if [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_ctrl_if ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_ctrl_if


  # Create instance: axi_gpio_gt_monitor, and set properties
  set axi_gpio_gt_monitor [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gt_monitor ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_GPIO_WIDTH {3} \
  ] $axi_gpio_gt_monitor


  # Create instance: axi_gpio_gt_control, and set properties
  set axi_gpio_gt_control [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gt_control ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x34186000} \
  ] $axi_gpio_gt_control


  # Create instance: ilconcat_gt_monitor, and set properties
  set ilconcat_gt_monitor [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_gt_monitor ]
  set_property CONFIG.NUM_PORTS {3} $ilconcat_gt_monitor


  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_cips_M01_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_ctrl_if/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins dcmac_m_axi] [get_bd_intf_pins smartconnect_ctrl_if/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins gt_m_axi] [get_bd_intf_pins smartconnect_ctrl_if/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_ctrl_if/M02_AXI] [get_bd_intf_pins axi_gpio_gt_control/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_ctrl_if/M03_AXI] [get_bd_intf_pins axi_gpio_resets/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins smartconnect_ctrl_if/M04_AXI] [get_bd_intf_pins axi_gpio_gt_monitor/S_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_resets/gpio_io_o] \
  [get_bd_pins usr_reset]
  connect_bd_net -net axi_gpio_gt_control_gpio_io_o  [get_bd_pins axi_gpio_gt_control/gpio_io_o] \
  [get_bd_pins gt_control]
  connect_bd_net -net clock_reset_clk_usr_0  [get_bd_pins aclk] \
  [get_bd_pins smartconnect_ctrl_if/aclk] \
  [get_bd_pins axi_gpio_gt_control/s_axi_aclk] \
  [get_bd_pins axi_gpio_gt_monitor/s_axi_aclk] \
  [get_bd_pins axi_gpio_resets/s_axi_aclk]
  connect_bd_net -net clock_reset_resetn_usr_0_periph  [get_bd_pins aresetn] \
  [get_bd_pins smartconnect_ctrl_if/aresetn] \
  [get_bd_pins axi_gpio_gt_control/s_axi_aresetn] \
  [get_bd_pins axi_gpio_gt_monitor/s_axi_aresetn] \
  [get_bd_pins axi_gpio_resets/s_axi_aresetn]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins gt_rx_reset_done] \
  [get_bd_pins ilconcat_gt_monitor/In2]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins gt_tx_reset_done] \
  [get_bd_pins ilconcat_gt_monitor/In1]
  connect_bd_net -net gtwiz_wrapper_gtpowergood  [get_bd_pins gtpowergood] \
  [get_bd_pins ilconcat_gt_monitor/In0]
  connect_bd_net -net ilconcat_0_dout2  [get_bd_pins ilconcat_gt_monitor/dout] \
  [get_bd_pins axi_gpio_gt_monitor/gpio_io_i]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dcmac_wrapper
proc create_hier_cell_dcmac_wrapper { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dcmac_wrapper() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis0_pkt_out

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis0_pkt_in

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_4x

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 Quad0_AXI_LITE


  # Create pins
  create_bd_pin -dir I -type clk tx_axi_clk
  create_bd_pin -dir I -type rst aresetn_axis_seg_in
  create_bd_pin -dir I -type clk s_axi_clk
  create_bd_pin -dir I -type rst s_axi_resetn
  create_bd_pin -dir I -type clk tx_core_clk
  create_bd_pin -dir I -type rst rx_core_reset
  create_bd_pin -dir I -type rst tx_core_reset
  create_bd_pin -dir I -type rst aresetn_axis_seg_in1
  create_bd_pin -dir I -from 0 -to 0 ts_clk
  create_bd_pin -dir O INTF0_rst_tx_done_out
  create_bd_pin -dir O INTF0_rst_rx_done_out
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk gt_ref_clk_322MHz
  create_bd_pin -dir I -from 31 -to 0 gt_control
  create_bd_pin -dir I -from 6 -to 0 gt_reseet
  create_bd_pin -dir O gtpowergood

  # Create instance: axis_seg_to_unseg_rx, and set properties
  set block_name axis_seg_to_unseg_converter
  set block_cell_name axis_seg_to_unseg_rx
  if { [catch {set axis_seg_to_unseg_rx [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_seg_to_unseg_rx eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: dcmac, and set properties
  set dcmac [ create_bd_cell -type ip -vlnv xilinx.com:ip:dcmac:3.0 dcmac ]
  set_property -dict [list \
    CONFIG.DCMAC_LOCATION_C0 {DCMAC_X1Y1} \
    CONFIG.GT_PIPELINE_STAGES {7} \
    CONFIG.GT_REF_CLK_FREQ_C0 {322.265625} \
    CONFIG.IS_GT_WIZ_OLD {0} \
    CONFIG.MAC_PORT0_CONFIG_C0 {200GAUI-4} \
    CONFIG.MAC_PORT0_RX_STRIP_C0 {1} \
    CONFIG.MAC_PORT1_RX_STRIP_C0 {1} \
    CONFIG.MAC_PORT2_ENABLE_C0 {0} \
    CONFIG.MAC_PORT3_ENABLE_C0 {0} \
    CONFIG.MAC_PORT4_ENABLE_C0 {0} \
    CONFIG.MAC_PORT5_ENABLE_C0 {0} \
  ] $dcmac


  # Create instance: axis_unseg_to_seg_tx, and set properties
  set block_name axis_unseg_to_seg_converter
  set block_cell_name axis_unseg_to_seg_tx
  if { [catch {set axis_unseg_to_seg_tx [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_unseg_to_seg_tx eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: flexif_clk, and set properties
  set flexif_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 flexif_clk ]
  set_property CONFIG.NUM_PORTS {6} $flexif_clk


  # Create instance: ts_clk, and set properties
  set ts_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ts_clk ]
  set_property CONFIG.NUM_PORTS {6} $ts_clk


  # Create instance: clock_to_serdes_tx
  create_hier_cell_clock_to_serdes_tx $hier_obj clock_to_serdes_tx

  # Create instance: clock_to_serdes_tx_alt
  create_hier_cell_clock_to_serdes_tx_alt $hier_obj clock_to_serdes_tx_alt

  # Create instance: clock_to_serdes_rx
  create_hier_cell_clock_to_serdes_rx $hier_obj clock_to_serdes_rx

  # Create instance: dcmac200g_ctl_port
  create_hier_cell_dcmac200g_ctl_port $hier_obj dcmac200g_ctl_port

  # Create instance: clock_to_serdes_rx_alt
  create_hier_cell_clock_to_serdes_rx_alt $hier_obj clock_to_serdes_rx_alt

  # Create instance: gtwiz_wrapper
  create_hier_cell_gtwiz_wrapper $hier_obj gtwiz_wrapper

  # Create interface connections
  connect_bd_intf_net -intf_net axis_dwidth_converter_tx_M_AXIS [get_bd_intf_pins s_axis0_pkt_in] [get_bd_intf_pins axis_unseg_to_seg_tx/s_axis0_pkt_in]
  connect_bd_intf_net -intf_net axis_seg_to_unseg_co_0_m_axis0_pkt_out [get_bd_intf_pins m_axis0_pkt_out] [get_bd_intf_pins axis_seg_to_unseg_rx/m_axis0_pkt_out]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins qsfp0_4x] [get_bd_intf_pins gtwiz_wrapper/GT_Serial]
  connect_bd_intf_net -intf_net qsfp0_322mhz_1 [get_bd_intf_pins qsfp0_322mhz] [get_bd_intf_pins gtwiz_wrapper/qsfp0_322mhz]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins dcmac/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins Quad0_AXI_LITE] [get_bd_intf_pins gtwiz_wrapper/Quad0_AXI_LITE]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins gt_reseet] \
  [get_bd_pins gtwiz_wrapper/gt_reset]
  connect_bd_net -net axi_gpio_gt_control_gpio_io_o  [get_bd_pins gt_control] \
  [get_bd_pins gtwiz_wrapper/gt_control]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat0_out] \
  [get_bd_pins dcmac/tx_axis_tdata0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat1_out] \
  [get_bd_pins dcmac/tx_axis_tdata1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat2_out] \
  [get_bd_pins dcmac/tx_axis_tdata2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegDat3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegDat3_out] \
  [get_bd_pins dcmac/tx_axis_tdata3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEna3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEna3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_ena3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegEop3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegEop3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_eop3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegErr3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegErr3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_err3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegMty3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegMty3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_mty3]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop0_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop0_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop0]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop1_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop1_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop1]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop2_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop2_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop2]
  connect_bd_net -net axis_unseg_to_seg_co_0_Unseg2SegSop3_out  [get_bd_pins axis_unseg_to_seg_tx/Unseg2SegSop3_out] \
  [get_bd_pins dcmac/tx_axis_tuser_sop3]
  connect_bd_net -net axis_unseg_to_seg_co_0_tx_axis_tvalid_out  [get_bd_pins axis_unseg_to_seg_tx/tx_axis_tvalid_out] \
  [get_bd_pins dcmac/tx_axis_tvalid_0]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins tx_core_clk] \
  [get_bd_pins dcmac/tx_core_clk] \
  [get_bd_pins dcmac/rx_core_clk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins tx_axi_clk] \
  [get_bd_pins dcmac/tx_axi_clk] \
  [get_bd_pins dcmac/rx_axi_clk] \
  [get_bd_pins dcmac/rx_macif_clk] \
  [get_bd_pins dcmac/tx_macif_clk] \
  [get_bd_pins flexif_clk/In0] \
  [get_bd_pins flexif_clk/In1] \
  [get_bd_pins flexif_clk/In2] \
  [get_bd_pins flexif_clk/In3] \
  [get_bd_pins flexif_clk/In4] \
  [get_bd_pins flexif_clk/In5] \
  [get_bd_pins axis_seg_to_unseg_rx/aclk_axis_seg_in] \
  [get_bd_pins axis_unseg_to_seg_tx/aclk_axis_seg_in]
  connect_bd_net -net clk_wizard_0_clk_out3  [get_bd_pins ts_clk] \
  [get_bd_pins ts_clk/In1] \
  [get_bd_pins ts_clk/In2] \
  [get_bd_pins ts_clk/In3] \
  [get_bd_pins ts_clk/In4] \
  [get_bd_pins ts_clk/In5] \
  [get_bd_pins ts_clk/In0]
  connect_bd_net -net clock_reset_clk_usr_0  [get_bd_pins s_axi_clk] \
  [get_bd_pins dcmac/s_axi_aclk] \
  [get_bd_pins gtwiz_wrapper/gtwiz_freerun_clk]
  connect_bd_net -net clock_reset_resetn_usr_0_periph  [get_bd_pins s_axi_resetn] \
  [get_bd_pins dcmac/s_axi_aresetn] \
  [get_bd_pins gtwiz_wrapper/QUAD0_s_axi_lite_resetn]
  connect_bd_net -net clock_to_serdes_rx_alt_dout  [get_bd_pins clock_to_serdes_rx_alt/dout] \
  [get_bd_pins dcmac/rx_alt_serdes_clk]
  connect_bd_net -net clock_to_serdes_tx_alt_dout  [get_bd_pins clock_to_serdes_tx_alt/dout] \
  [get_bd_pins dcmac/tx_alt_serdes_clk]
  connect_bd_net -net clock_to_serdes_tx_dout  [get_bd_pins clock_to_serdes_tx/dout] \
  [get_bd_pins dcmac/tx_serdes_clk]
  connect_bd_net -net dcmac200g_ctl_port_dout1  [get_bd_pins dcmac200g_ctl_port/dout1] \
  [get_bd_pins dcmac/ctl_vl_marker_id0]
  connect_bd_net -net dcmac200g_ctl_port_dout2  [get_bd_pins dcmac200g_ctl_port/dout2] \
  [get_bd_pins dcmac/ctl_vl_marker_id1]
  connect_bd_net -net dcmac200g_ctl_port_dout3  [get_bd_pins dcmac200g_ctl_port/dout3] \
  [get_bd_pins dcmac/ctl_vl_marker_id2]
  connect_bd_net -net dcmac200g_ctl_port_dout4  [get_bd_pins dcmac200g_ctl_port/dout4] \
  [get_bd_pins dcmac/ctl_vl_marker_id3]
  connect_bd_net -net dcmac200g_ctl_port_dout5  [get_bd_pins dcmac200g_ctl_port/dout5] \
  [get_bd_pins dcmac/ctl_vl_marker_id4]
  connect_bd_net -net dcmac200g_ctl_port_dout6  [get_bd_pins dcmac200g_ctl_port/dout6] \
  [get_bd_pins dcmac/ctl_vl_marker_id5]
  connect_bd_net -net dcmac200g_ctl_port_dout7  [get_bd_pins dcmac200g_ctl_port/dout7] \
  [get_bd_pins dcmac/ctl_vl_marker_id6]
  connect_bd_net -net dcmac200g_ctl_port_dout8  [get_bd_pins dcmac200g_ctl_port/dout8] \
  [get_bd_pins dcmac/ctl_vl_marker_id7]
  connect_bd_net -net dcmac200g_ctl_port_dout9  [get_bd_pins dcmac200g_ctl_port/dout9] \
  [get_bd_pins dcmac/ctl_vl_marker_id8]
  connect_bd_net -net dcmac200g_ctl_port_dout10  [get_bd_pins dcmac200g_ctl_port/dout10] \
  [get_bd_pins dcmac/ctl_vl_marker_id9]
  connect_bd_net -net dcmac200g_ctl_port_dout11  [get_bd_pins dcmac200g_ctl_port/dout11] \
  [get_bd_pins dcmac/ctl_vl_marker_id10]
  connect_bd_net -net dcmac200g_ctl_port_dout12  [get_bd_pins dcmac200g_ctl_port/dout12] \
  [get_bd_pins dcmac/ctl_vl_marker_id11]
  connect_bd_net -net dcmac200g_ctl_port_dout13  [get_bd_pins dcmac200g_ctl_port/dout13] \
  [get_bd_pins dcmac/ctl_vl_marker_id12]
  connect_bd_net -net dcmac200g_ctl_port_dout14  [get_bd_pins dcmac200g_ctl_port/dout14] \
  [get_bd_pins dcmac/ctl_vl_marker_id13]
  connect_bd_net -net dcmac200g_ctl_port_dout15  [get_bd_pins dcmac200g_ctl_port/dout15] \
  [get_bd_pins dcmac/ctl_vl_marker_id14]
  connect_bd_net -net dcmac200g_ctl_port_dout16  [get_bd_pins dcmac200g_ctl_port/dout16] \
  [get_bd_pins dcmac/ctl_vl_marker_id15]
  connect_bd_net -net dcmac200g_ctl_port_dout17  [get_bd_pins dcmac200g_ctl_port/dout17] \
  [get_bd_pins dcmac/ctl_vl_marker_id16]
  connect_bd_net -net dcmac200g_ctl_port_dout18  [get_bd_pins dcmac200g_ctl_port/dout18] \
  [get_bd_pins dcmac/ctl_vl_marker_id17]
  connect_bd_net -net dcmac200g_ctl_port_dout19  [get_bd_pins dcmac200g_ctl_port/dout19] \
  [get_bd_pins dcmac/ctl_vl_marker_id18]
  connect_bd_net -net dcmac200g_ctl_port_dout20  [get_bd_pins dcmac200g_ctl_port/dout20] \
  [get_bd_pins dcmac/ctl_vl_marker_id19]
  connect_bd_net -net dcmac_0_txdata_out_0  [get_bd_pins dcmac/txdata_out_0] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX0_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_1  [get_bd_pins dcmac/txdata_out_1] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX1_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_2  [get_bd_pins dcmac/txdata_out_2] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX2_ch_txdata]
  connect_bd_net -net dcmac_0_txdata_out_3  [get_bd_pins dcmac/txdata_out_3] \
  [get_bd_pins gtwiz_wrapper/INTF0_TX3_ch_txdata]
  connect_bd_net -net dcmac_gt_rx_reset_done_core_clk_syncer_reset  [get_bd_pins rx_core_reset] \
  [get_bd_pins dcmac/rx_core_reset]
  connect_bd_net -net dcmac_gt_tx_reset_done_core_clk_syncer_reset  [get_bd_pins tx_core_reset] \
  [get_bd_pins dcmac/tx_core_reset]
  connect_bd_net -net dcmac_rx_axis_tdata0  [get_bd_pins dcmac/rx_axis_tdata0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat0_in]
  connect_bd_net -net dcmac_rx_axis_tdata1  [get_bd_pins dcmac/rx_axis_tdata1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat1_in]
  connect_bd_net -net dcmac_rx_axis_tdata2  [get_bd_pins dcmac/rx_axis_tdata2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat2_in]
  connect_bd_net -net dcmac_rx_axis_tdata3  [get_bd_pins dcmac/rx_axis_tdata3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegDat3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena0  [get_bd_pins dcmac/rx_axis_tuser_ena0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena1  [get_bd_pins dcmac/rx_axis_tuser_ena1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena2  [get_bd_pins dcmac/rx_axis_tuser_ena2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_ena3  [get_bd_pins dcmac/rx_axis_tuser_ena3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEna3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop0  [get_bd_pins dcmac/rx_axis_tuser_eop0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop1  [get_bd_pins dcmac/rx_axis_tuser_eop1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop2  [get_bd_pins dcmac/rx_axis_tuser_eop2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_eop3  [get_bd_pins dcmac/rx_axis_tuser_eop3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegEop3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err0  [get_bd_pins dcmac/rx_axis_tuser_err0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err1  [get_bd_pins dcmac/rx_axis_tuser_err1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err2  [get_bd_pins dcmac/rx_axis_tuser_err2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_err3  [get_bd_pins dcmac/rx_axis_tuser_err3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegErr3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty0  [get_bd_pins dcmac/rx_axis_tuser_mty0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty1  [get_bd_pins dcmac/rx_axis_tuser_mty1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty2  [get_bd_pins dcmac/rx_axis_tuser_mty2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_mty3  [get_bd_pins dcmac/rx_axis_tuser_mty3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegMty3_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop0  [get_bd_pins dcmac/rx_axis_tuser_sop0] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop0_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop1  [get_bd_pins dcmac/rx_axis_tuser_sop1] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop1_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop2  [get_bd_pins dcmac/rx_axis_tuser_sop2] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop2_in]
  connect_bd_net -net dcmac_rx_axis_tuser_sop3  [get_bd_pins dcmac/rx_axis_tuser_sop3] \
  [get_bd_pins axis_seg_to_unseg_rx/Seg2UnSegSop3_in]
  connect_bd_net -net dcmac_rx_axis_tvalid_0  [get_bd_pins dcmac/rx_axis_tvalid_0] \
  [get_bd_pins axis_seg_to_unseg_rx/rx_axis_tvalid_i]
  connect_bd_net -net dcmac_tx_axis_tready_0  [get_bd_pins dcmac/tx_axis_tready_0] \
  [get_bd_pins axis_unseg_to_seg_tx/tx_axis_tready_in]
  connect_bd_net -net flexif_clk_dout  [get_bd_pins flexif_clk/dout] \
  [get_bd_pins dcmac/rx_flexif_clk] \
  [get_bd_pins dcmac/tx_flexif_clk]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX0_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX0_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_0]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX1_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX1_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_1]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX2_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX2_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_2]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX3_ch_rxdata  [get_bd_pins gtwiz_wrapper/INTF0_RX3_ch_rxdata] \
  [get_bd_pins dcmac/rxdata_in_3]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins gtwiz_wrapper/INTF0_rst_rx_done_out] \
  [get_bd_pins INTF0_rst_rx_done_out]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_wrapper/INTF0_rst_tx_done_out] \
  [get_bd_pins INTF0_rst_tx_done_out]
  connect_bd_net -net gtwiz_wrapper_gtpowergood  [get_bd_pins gtwiz_wrapper/gtpowergood] \
  [get_bd_pins gtpowergood]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins clock_to_serdes_rx/dout] \
  [get_bd_pins dcmac/rx_serdes_clk]
  connect_bd_net -net ilconcat_0_dout1  [get_bd_pins ts_clk/dout] \
  [get_bd_pins dcmac/ts_clk]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins dcmac200g_ctl_port/dout] \
  [get_bd_pins dcmac/ctl_rx_custom_vl_length_minus1] \
  [get_bd_pins dcmac/ctl_tx_custom_vl_length_minus1]
  connect_bd_net -net mbufg_gt_rx_0_MBUFG_GT_O2  [get_bd_pins gtwiz_wrapper/qsfp_rx_usr_clk_332MHz] \
  [get_bd_pins clock_to_serdes_rx_alt/In1]
  connect_bd_net -net mbufg_gt_tx_0_MBUFG_GT_O1  [get_bd_pins gtwiz_wrapper/qsfp_tx_usr_clk_664MHz] \
  [get_bd_pins clock_to_serdes_tx/In1]
  connect_bd_net -net qsfp_rx_usr_clk_664MHz  [get_bd_pins gtwiz_wrapper/qsfp_rx_usr_clk_664MHz] \
  [get_bd_pins clock_to_serdes_rx/In1]
  connect_bd_net -net sys_reset_rx_peripheral_aresetn  [get_bd_pins aresetn_axis_seg_in] \
  [get_bd_pins axis_seg_to_unseg_rx/aresetn_axis_seg_in]
  connect_bd_net -net sys_reset_tx_peripheral_aresetn  [get_bd_pins aresetn_axis_seg_in1] \
  [get_bd_pins axis_unseg_to_seg_tx/aresetn_axis_seg_in]
  connect_bd_net -net util_ds_buf_0_MBUFG_GT_O2  [get_bd_pins gtwiz_wrapper/qsfp_tx_usr_clk_332MHz] \
  [get_bd_pins clock_to_serdes_tx_alt/In1]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins gtwiz_wrapper/gt_ref_clk_322MHz] \
  [get_bd_pins gt_ref_clk_322MHz]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clock_reset
proc create_hier_cell_clock_reset_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clock_reset_1() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir O -type clk clk_out_390MHz
  create_bd_pin -dir I -type rst gt_tx_reset_done
  create_bd_pin -dir I -type rst gt_rx_reset_done
  create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_tx_390MHz
  create_bd_pin -dir O -type clk clk_out_782MHz
  create_bd_pin -dir O -type rst reset_rx_790MHz
  create_bd_pin -dir O -type rst reset_tx_790MHz
  create_bd_pin -dir O -from 0 -to 0 -type rst aresetn_rx_390MHz
  create_bd_pin -dir I -type clk gt_ref_clk_322MHz
  create_bd_pin -dir O -type clk clk_out_350MHz
  create_bd_pin -dir I -from 6 -to 0 reset_usr_txrx_path
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn

  # Create instance: dcmac_gt_tx_reset_done_axis_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_tx_reset_done_axis_clk_syncer
  if { [catch {set dcmac_gt_tx_reset_done_axis_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_tx_reset_done_axis_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: dcmac_gt_rx_reset_done_axis_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_rx_reset_done_axis_clk_syncer
  if { [catch {set dcmac_gt_rx_reset_done_axis_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_rx_reset_done_axis_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: sys_reset_tx, and set properties
  set sys_reset_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset_tx ]

  # Create instance: dcmac_gt_rx_reset_done_core_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_rx_reset_done_core_clk_syncer
  if { [catch {set dcmac_gt_rx_reset_done_core_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_rx_reset_done_core_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: dcmac_gt_tx_reset_done_core_clk_syncer, and set properties
  set block_name dcmac_syncer_reset
  set block_cell_name dcmac_gt_tx_reset_done_core_clk_syncer
  if { [catch {set dcmac_gt_tx_reset_done_core_clk_syncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dcmac_gt_tx_reset_done_core_clk_syncer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: sys_reset_rx, and set properties
  set sys_reset_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset_rx ]

  # Create instance: clk_wizard, and set properties
  set clk_wizard [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {782,390.625,350,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,true,true,false,false,false,false} \
    CONFIG.OVERRIDE_PRIMITIVE {false} \
    CONFIG.PRIM_IN_FREQ {322.265625} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {false} \
  ] $clk_wizard


  # Create instance: ilslice_reset_tx, and set properties
  set ilslice_reset_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_reset_tx ]
  set_property -dict [list \
    CONFIG.DIN_FROM {5} \
    CONFIG.DIN_TO {5} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_reset_tx


  # Create instance: ilslice_reset_rx, and set properties
  set ilslice_reset_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_reset_rx ]
  set_property -dict [list \
    CONFIG.DIN_FROM {6} \
    CONFIG.DIN_TO {6} \
    CONFIG.DIN_WIDTH {7} \
  ] $ilslice_reset_rx


  # Create instance: ilreduced_logic_or_reset_tx, and set properties
  set ilreduced_logic_or_reset_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic:1.0 ilreduced_logic_or_reset_tx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {2} \
  ] $ilreduced_logic_or_reset_tx


  # Create instance: ilconcat_reset_tx, and set properties
  set ilconcat_reset_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_reset_tx ]

  # Create instance: ilreduced_logic_or_reset_rx, and set properties
  set ilreduced_logic_or_reset_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic:1.0 ilreduced_logic_or_reset_rx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {2} \
  ] $ilreduced_logic_or_reset_rx


  # Create instance: ilconcat_reset_rx, and set properties
  set ilconcat_reset_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_reset_rx ]

  # Create instance: sys_reset_axi, and set properties
  set sys_reset_axi [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset_axi ]

  # Create instance: ilvector_logic_rx, and set properties
  set ilvector_logic_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic:1.0 ilvector_logic_rx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_rx


  # Create instance: ilvector_logic_tx, and set properties
  set ilvector_logic_tx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic:1.0 ilvector_logic_tx ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_tx


  # Create port connections
  connect_bd_net -net Din_1  [get_bd_pins reset_usr_txrx_path] \
  [get_bd_pins ilslice_reset_tx/Din] \
  [get_bd_pins ilslice_reset_rx/Din]
  connect_bd_net -net aclk_1  [get_bd_pins aclk] \
  [get_bd_pins sys_reset_axi/slowest_sync_clk]
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins sys_reset_axi/ext_reset_in]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins clk_wizard/clk_out1] \
  [get_bd_pins clk_out_782MHz] \
  [get_bd_pins dcmac_gt_rx_reset_done_core_clk_syncer/clk] \
  [get_bd_pins dcmac_gt_tx_reset_done_core_clk_syncer/clk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins clk_wizard/clk_out2] \
  [get_bd_pins clk_out_390MHz] \
  [get_bd_pins sys_reset_rx/slowest_sync_clk] \
  [get_bd_pins sys_reset_tx/slowest_sync_clk] \
  [get_bd_pins dcmac_gt_rx_reset_done_axis_clk_syncer/clk] \
  [get_bd_pins dcmac_gt_tx_reset_done_axis_clk_syncer/clk]
  connect_bd_net -net clk_wizard_0_clk_out3  [get_bd_pins clk_wizard/clk_out3] \
  [get_bd_pins clk_out_350MHz]
  connect_bd_net -net clk_wizard_0_locked  [get_bd_pins clk_wizard/locked] \
  [get_bd_pins sys_reset_tx/dcm_locked] \
  [get_bd_pins sys_reset_rx/dcm_locked]
  connect_bd_net -net dcmac_gt_rx_reset_done_axis_clk_syncer_resetn  [get_bd_pins dcmac_gt_rx_reset_done_axis_clk_syncer/resetn] \
  [get_bd_pins sys_reset_rx/ext_reset_in]
  connect_bd_net -net dcmac_gt_rx_reset_done_core_clk_syncer_reset  [get_bd_pins dcmac_gt_rx_reset_done_core_clk_syncer/reset] \
  [get_bd_pins reset_rx_790MHz]
  connect_bd_net -net dcmac_gt_tx_reset_done_axis_clk_syncer_resetn  [get_bd_pins dcmac_gt_tx_reset_done_axis_clk_syncer/resetn] \
  [get_bd_pins sys_reset_tx/ext_reset_in]
  connect_bd_net -net dcmac_gt_tx_reset_done_core_clk_syncer_reset  [get_bd_pins dcmac_gt_tx_reset_done_core_clk_syncer/reset] \
  [get_bd_pins reset_tx_790MHz]
  connect_bd_net -net gt_rx_reset_done_1  [get_bd_pins gt_rx_reset_done] \
  [get_bd_pins ilvector_logic_rx/Op1]
  connect_bd_net -net gt_tx_reset_done_1  [get_bd_pins gt_tx_reset_done] \
  [get_bd_pins ilvector_logic_tx/Op1]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_reset_tx/dout] \
  [get_bd_pins ilreduced_logic_or_reset_tx/Op1]
  connect_bd_net -net ilconcat_reset_rx_dout  [get_bd_pins ilconcat_reset_rx/dout] \
  [get_bd_pins ilreduced_logic_or_reset_rx/Op1]
  connect_bd_net -net ilreduced_logic_0_Res  [get_bd_pins ilreduced_logic_or_reset_tx/Res] \
  [get_bd_pins dcmac_gt_tx_reset_done_axis_clk_syncer/reset_async]
  connect_bd_net -net ilreduced_logic_or_reset_rx_Res  [get_bd_pins ilreduced_logic_or_reset_rx/Res] \
  [get_bd_pins dcmac_gt_rx_reset_done_axis_clk_syncer/reset_async]
  connect_bd_net -net ilslice_reset_rx_Dout  [get_bd_pins ilslice_reset_rx/Dout] \
  [get_bd_pins ilconcat_reset_rx/In1]
  connect_bd_net -net ilslice_reset_tx_Dout  [get_bd_pins ilslice_reset_tx/Dout] \
  [get_bd_pins ilconcat_reset_tx/In1]
  connect_bd_net -net ilvector_logic_0_Res  [get_bd_pins ilvector_logic_rx/Res] \
  [get_bd_pins ilconcat_reset_rx/In0] \
  [get_bd_pins dcmac_gt_rx_reset_done_core_clk_syncer/reset_async]
  connect_bd_net -net ilvector_logic_tx_Res  [get_bd_pins ilvector_logic_tx/Res] \
  [get_bd_pins ilconcat_reset_tx/In0] \
  [get_bd_pins dcmac_gt_tx_reset_done_core_clk_syncer/reset_async]
  connect_bd_net -net sys_reset_axi_peripheral_aresetn  [get_bd_pins sys_reset_axi/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn]
  connect_bd_net -net sys_reset_rx_peripheral_aresetn  [get_bd_pins sys_reset_rx/peripheral_aresetn] \
  [get_bd_pins aresetn_rx_390MHz]
  connect_bd_net -net sys_reset_tx_peripheral_aresetn  [get_bd_pins sys_reset_tx/peripheral_aresetn] \
  [get_bd_pins aresetn_tx_390MHz]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins gt_ref_clk_322MHz] \
  [get_bd_pins clk_wizard/clk_in1]

  # Restore current instance
  current_bd_instance $oldCurInst
}

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

# Hierarchical cell: qsfp1
proc create_hier_cell_qsfp1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_qsfp1() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_4x

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk axis_aclk
  create_bd_pin -dir I -type rst axis_aresetn

  # Create instance: axis_dwidth_converter_rx, and set properties
  set axis_dwidth_converter_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_rx ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {64} \
    CONFIG.S_TDATA_NUM_BYTES {128} \
    CONFIG.TUSER_BITS_PER_BYTE {1} \
  ] $axis_dwidth_converter_rx


  # Create instance: rx_packet_fifo_cdc, and set properties
  set rx_packet_fifo_cdc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 rx_packet_fifo_cdc ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.IS_ACLK_ASYNC {1} \
    CONFIG.TDATA_NUM_BYTES {64} \
  ] $rx_packet_fifo_cdc


  # Create instance: tx_packet_fifo_cdc, and set properties
  set tx_packet_fifo_cdc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 tx_packet_fifo_cdc ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.IS_ACLK_ASYNC {1} \
    CONFIG.TDATA_NUM_BYTES {64} \
  ] $tx_packet_fifo_cdc


  # Create instance: axis_dwidth_converter_tx, and set properties
  set axis_dwidth_converter_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_tx ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {128} \
    CONFIG.S_TDATA_NUM_BYTES {64} \
    CONFIG.TUSER_BITS_PER_BYTE {1} \
  ] $axis_dwidth_converter_tx


  # Create instance: clock_reset
  create_hier_cell_clock_reset_2 $hier_obj clock_reset

  # Create instance: dcmac_wrapper
  create_hier_cell_dcmac_wrapper_1 $hier_obj dcmac_wrapper

  # Create instance: control_interface
  create_hier_cell_control_interface_1 $hier_obj control_interface

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins tx_packet_fifo_cdc/S_AXIS]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins control_interface/S00_AXI]
  connect_bd_intf_net -intf_net axis_dwidth_converter_rx_M_AXIS [get_bd_intf_pins axis_dwidth_converter_rx/M_AXIS] [get_bd_intf_pins rx_packet_fifo_cdc/S_AXIS]
  connect_bd_intf_net -intf_net axis_dwidth_converter_tx_M_AXIS [get_bd_intf_pins axis_dwidth_converter_tx/M_AXIS] [get_bd_intf_pins dcmac_wrapper/s_axis0_pkt_in]
  connect_bd_intf_net -intf_net axis_seg_to_unseg_co_0_m_axis0_pkt_out [get_bd_intf_pins dcmac_wrapper/m_axis0_pkt_out] [get_bd_intf_pins axis_dwidth_converter_rx/S_AXIS]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins qsfp0_4x] [get_bd_intf_pins dcmac_wrapper/qsfp0_4x]
  connect_bd_intf_net -intf_net qsfp0_322mhz_1 [get_bd_intf_pins qsfp0_322mhz] [get_bd_intf_pins dcmac_wrapper/qsfp0_322mhz]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins control_interface/dcmac_m_axi] [get_bd_intf_pins dcmac_wrapper/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins control_interface/gt_m_axi] [get_bd_intf_pins dcmac_wrapper/Quad0_AXI_LITE]
  connect_bd_intf_net -intf_net tx_packet_fifo_cdc_1_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins rx_packet_fifo_cdc/M_AXIS]
  connect_bd_intf_net -intf_net tx_packet_fifo_cdc_M_AXIS [get_bd_intf_pins tx_packet_fifo_cdc/M_AXIS] [get_bd_intf_pins axis_dwidth_converter_tx/S_AXIS]

  # Create port connections
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins clock_reset/aresetn]
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins control_interface/usr_reset] \
  [get_bd_pins dcmac_wrapper/gt_reseet] \
  [get_bd_pins clock_reset/reset_usr_txrx_path]
  connect_bd_net -net axi_gpio_gt_control_gpio_io_o  [get_bd_pins control_interface/gt_control] \
  [get_bd_pins dcmac_wrapper/gt_control]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins clock_reset/clk_out_782MHz] \
  [get_bd_pins dcmac_wrapper/tx_core_clk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins clock_reset/clk_out_390MHz] \
  [get_bd_pins axis_dwidth_converter_rx/aclk] \
  [get_bd_pins axis_dwidth_converter_tx/aclk] \
  [get_bd_pins dcmac_wrapper/tx_axi_clk] \
  [get_bd_pins tx_packet_fifo_cdc/m_axis_aclk] \
  [get_bd_pins rx_packet_fifo_cdc/s_axis_aclk]
  connect_bd_net -net clk_wizard_0_clk_out3  [get_bd_pins clock_reset/clk_out_350MHz] \
  [get_bd_pins dcmac_wrapper/ts_clk]
  connect_bd_net -net clock_reset_clk_usr_0  [get_bd_pins aclk] \
  [get_bd_pins control_interface/aclk] \
  [get_bd_pins dcmac_wrapper/s_axi_clk] \
  [get_bd_pins clock_reset/aclk]
  connect_bd_net -net clock_reset_peripheral_aresetn  [get_bd_pins clock_reset/peripheral_aresetn] \
  [get_bd_pins control_interface/aresetn] \
  [get_bd_pins dcmac_wrapper/s_axi_resetn]
  connect_bd_net -net dcmac_gt_rx_reset_done_core_clk_syncer_reset  [get_bd_pins clock_reset/reset_rx_790MHz] \
  [get_bd_pins dcmac_wrapper/rx_core_reset]
  connect_bd_net -net dcmac_gt_tx_reset_done_core_clk_syncer_reset  [get_bd_pins clock_reset/reset_tx_790MHz] \
  [get_bd_pins dcmac_wrapper/tx_core_reset]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins dcmac_wrapper/INTF0_rst_rx_done_out] \
  [get_bd_pins control_interface/gt_rx_reset_done] \
  [get_bd_pins clock_reset/gt_rx_reset_done]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins dcmac_wrapper/INTF0_rst_tx_done_out] \
  [get_bd_pins control_interface/gt_tx_reset_done] \
  [get_bd_pins clock_reset/gt_tx_reset_done]
  connect_bd_net -net gtwiz_wrapper_gtpowergood  [get_bd_pins dcmac_wrapper/gtpowergood] \
  [get_bd_pins control_interface/gtpowergood]
  connect_bd_net -net s_axis_aclk_1  [get_bd_pins axis_aclk] \
  [get_bd_pins tx_packet_fifo_cdc/s_axis_aclk] \
  [get_bd_pins rx_packet_fifo_cdc/m_axis_aclk]
  connect_bd_net -net s_axis_aresetn_1  [get_bd_pins axis_aresetn] \
  [get_bd_pins tx_packet_fifo_cdc/s_axis_aresetn]
  connect_bd_net -net sys_reset_rx_peripheral_aresetn  [get_bd_pins clock_reset/aresetn_rx_390MHz] \
  [get_bd_pins axis_dwidth_converter_rx/aresetn] \
  [get_bd_pins dcmac_wrapper/aresetn_axis_seg_in] \
  [get_bd_pins rx_packet_fifo_cdc/s_axis_aresetn]
  connect_bd_net -net sys_reset_tx_peripheral_aresetn  [get_bd_pins clock_reset/aresetn_tx_390MHz] \
  [get_bd_pins axis_dwidth_converter_tx/aresetn] \
  [get_bd_pins dcmac_wrapper/aresetn_axis_seg_in1]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins dcmac_wrapper/gt_ref_clk_322MHz] \
  [get_bd_pins clock_reset/gt_ref_clk_322MHz]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: qsfp
proc create_hier_cell_qsfp { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_qsfp() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_4x

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk axis_aclk
  create_bd_pin -dir I -type rst axis_aresetn

  # Create instance: axis_dwidth_converter_rx, and set properties
  set axis_dwidth_converter_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_rx ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {64} \
    CONFIG.S_TDATA_NUM_BYTES {128} \
    CONFIG.TUSER_BITS_PER_BYTE {1} \
  ] $axis_dwidth_converter_rx


  # Create instance: rx_packet_fifo_cdc, and set properties
  set rx_packet_fifo_cdc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 rx_packet_fifo_cdc ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.IS_ACLK_ASYNC {1} \
    CONFIG.TDATA_NUM_BYTES {64} \
  ] $rx_packet_fifo_cdc


  # Create instance: tx_packet_fifo_cdc, and set properties
  set tx_packet_fifo_cdc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 tx_packet_fifo_cdc ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.IS_ACLK_ASYNC {1} \
    CONFIG.TDATA_NUM_BYTES {64} \
  ] $tx_packet_fifo_cdc


  # Create instance: axis_dwidth_converter_tx, and set properties
  set axis_dwidth_converter_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_tx ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {128} \
    CONFIG.S_TDATA_NUM_BYTES {64} \
    CONFIG.TUSER_BITS_PER_BYTE {1} \
  ] $axis_dwidth_converter_tx


  # Create instance: clock_reset
  create_hier_cell_clock_reset_1 $hier_obj clock_reset

  # Create instance: dcmac_wrapper
  create_hier_cell_dcmac_wrapper $hier_obj dcmac_wrapper

  # Create instance: control_interface
  create_hier_cell_control_interface $hier_obj control_interface

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins tx_packet_fifo_cdc/S_AXIS]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins control_interface/S00_AXI]
  connect_bd_intf_net -intf_net axis_dwidth_converter_rx_M_AXIS [get_bd_intf_pins axis_dwidth_converter_rx/M_AXIS] [get_bd_intf_pins rx_packet_fifo_cdc/S_AXIS]
  connect_bd_intf_net -intf_net axis_dwidth_converter_tx_M_AXIS [get_bd_intf_pins axis_dwidth_converter_tx/M_AXIS] [get_bd_intf_pins dcmac_wrapper/s_axis0_pkt_in]
  connect_bd_intf_net -intf_net axis_seg_to_unseg_co_0_m_axis0_pkt_out [get_bd_intf_pins dcmac_wrapper/m_axis0_pkt_out] [get_bd_intf_pins axis_dwidth_converter_rx/S_AXIS]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins qsfp0_4x] [get_bd_intf_pins dcmac_wrapper/qsfp0_4x]
  connect_bd_intf_net -intf_net qsfp0_322mhz_1 [get_bd_intf_pins qsfp0_322mhz] [get_bd_intf_pins dcmac_wrapper/qsfp0_322mhz]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins control_interface/dcmac_m_axi] [get_bd_intf_pins dcmac_wrapper/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins control_interface/gt_m_axi] [get_bd_intf_pins dcmac_wrapper/Quad0_AXI_LITE]
  connect_bd_intf_net -intf_net tx_packet_fifo_cdc_1_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins rx_packet_fifo_cdc/M_AXIS]
  connect_bd_intf_net -intf_net tx_packet_fifo_cdc_M_AXIS [get_bd_intf_pins tx_packet_fifo_cdc/M_AXIS] [get_bd_intf_pins axis_dwidth_converter_tx/S_AXIS]

  # Create port connections
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins clock_reset/aresetn]
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins control_interface/usr_reset] \
  [get_bd_pins dcmac_wrapper/gt_reseet] \
  [get_bd_pins clock_reset/reset_usr_txrx_path]
  connect_bd_net -net axi_gpio_gt_control_gpio_io_o  [get_bd_pins control_interface/gt_control] \
  [get_bd_pins dcmac_wrapper/gt_control]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins clock_reset/clk_out_782MHz] \
  [get_bd_pins dcmac_wrapper/tx_core_clk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins clock_reset/clk_out_390MHz] \
  [get_bd_pins axis_dwidth_converter_rx/aclk] \
  [get_bd_pins axis_dwidth_converter_tx/aclk] \
  [get_bd_pins dcmac_wrapper/tx_axi_clk] \
  [get_bd_pins tx_packet_fifo_cdc/m_axis_aclk] \
  [get_bd_pins rx_packet_fifo_cdc/s_axis_aclk]
  connect_bd_net -net clk_wizard_0_clk_out3  [get_bd_pins clock_reset/clk_out_350MHz] \
  [get_bd_pins dcmac_wrapper/ts_clk]
  connect_bd_net -net clock_reset_clk_usr_0  [get_bd_pins aclk] \
  [get_bd_pins control_interface/aclk] \
  [get_bd_pins dcmac_wrapper/s_axi_clk] \
  [get_bd_pins clock_reset/aclk]
  connect_bd_net -net clock_reset_peripheral_aresetn  [get_bd_pins clock_reset/peripheral_aresetn] \
  [get_bd_pins control_interface/aresetn] \
  [get_bd_pins dcmac_wrapper/s_axi_resetn]
  connect_bd_net -net dcmac_gt_rx_reset_done_core_clk_syncer_reset  [get_bd_pins clock_reset/reset_rx_790MHz] \
  [get_bd_pins dcmac_wrapper/rx_core_reset]
  connect_bd_net -net dcmac_gt_tx_reset_done_core_clk_syncer_reset  [get_bd_pins clock_reset/reset_tx_790MHz] \
  [get_bd_pins dcmac_wrapper/tx_core_reset]
  connect_bd_net -net gtwiz_versal_INTF0_rst_rx_done_out  [get_bd_pins dcmac_wrapper/INTF0_rst_rx_done_out] \
  [get_bd_pins control_interface/gt_rx_reset_done] \
  [get_bd_pins clock_reset/gt_rx_reset_done]
  connect_bd_net -net gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins dcmac_wrapper/INTF0_rst_tx_done_out] \
  [get_bd_pins control_interface/gt_tx_reset_done] \
  [get_bd_pins clock_reset/gt_tx_reset_done]
  connect_bd_net -net gtwiz_wrapper_gtpowergood  [get_bd_pins dcmac_wrapper/gtpowergood] \
  [get_bd_pins control_interface/gtpowergood]
  connect_bd_net -net s_axis_aclk_1  [get_bd_pins axis_aclk] \
  [get_bd_pins tx_packet_fifo_cdc/s_axis_aclk] \
  [get_bd_pins rx_packet_fifo_cdc/m_axis_aclk]
  connect_bd_net -net s_axis_aresetn_1  [get_bd_pins axis_aresetn] \
  [get_bd_pins tx_packet_fifo_cdc/s_axis_aresetn]
  connect_bd_net -net sys_reset_rx_peripheral_aresetn  [get_bd_pins clock_reset/aresetn_rx_390MHz] \
  [get_bd_pins axis_dwidth_converter_rx/aresetn] \
  [get_bd_pins dcmac_wrapper/aresetn_axis_seg_in] \
  [get_bd_pins rx_packet_fifo_cdc/s_axis_aresetn]
  connect_bd_net -net sys_reset_tx_peripheral_aresetn  [get_bd_pins clock_reset/aresetn_tx_390MHz] \
  [get_bd_pins axis_dwidth_converter_tx/aresetn] \
  [get_bd_pins dcmac_wrapper/aresetn_axis_seg_in1]
  connect_bd_net -net util_ds_buf_1_BUFG_GT_O  [get_bd_pins dcmac_wrapper/gt_ref_clk_322MHz] \
  [get_bd_pins clock_reset/gt_ref_clk_322MHz]

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

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem3

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_gmem1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 EthernetOutPipe

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 EthernetInPipe

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI


  # Create pins
  create_bd_pin -dir I -type clk ap_clk
  create_bd_pin -dir I -type rst ap_rst_n

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


  # Create instance: resultSinkKernel_0, and set properties
  set resultSinkKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:resultSinkKernel:1.0 resultSinkKernel_0 ]

  # Create instance: IoPayloadPipe, and set properties
  set IoPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {256} $IoPayloadPipe


  # Create instance: IoPayloadSplitPipe, and set properties
  set IoPayloadSplitPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadSplitPipe ]
  set_property CONFIG.FIFO_DEPTH {256} $IoPayloadSplitPipe


  # Create instance: SmInputPayloadPipe, and set properties
  set SmInputPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 SmInputPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $SmInputPayloadPipe


  # Create instance: SmMetaResultPipe, and set properties
  set SmMetaResultPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 SmMetaResultPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $SmMetaResultPipe


  # Create instance: IoBurstWritePipe, and set properties
  set IoBurstWritePipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoBurstWritePipe ]
  set_property CONFIG.FIFO_DEPTH {256} $IoBurstWritePipe


  # Create instance: resultWriteKernel_0, and set properties
  set resultWriteKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:resultWriteKernel:1.0 resultWriteKernel_0 ]

  # Create instance: mergePipesKernel_0, and set properties
  set mergePipesKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:mergePipesKernel:1.0 mergePipesKernel_0 ]

  # Create instance: IoPayloadMergedPipe, and set properties
  set IoPayloadMergedPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadMergedPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadMergedPipe


  # Create instance: IoPayloadFinalPipe, and set properties
  set IoPayloadFinalPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadFinalPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadFinalPipe


  # Create instance: payloadWriteKernel_0, and set properties
  set payloadWriteKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:payloadWriteKernel:1.0 payloadWriteKernel_0 ]
  set_property CONFIG.C_M_AXI_GMEM0_DATA_WIDTH {128} $payloadWriteKernel_0


  # Create instance: SmForwardPayloadPipe, and set properties
  set SmForwardPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 SmForwardPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {2048} $SmForwardPayloadPipe


  # Create instance: HostPayloadPipe, and set properties
  set HostPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 HostPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $HostPayloadPipe


  # Create instance: HostMetaPipe, and set properties
  set HostMetaPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 HostMetaPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $HostMetaPipe


  # Create instance: fieldTaggerKernel_0, and set properties
  set fieldTaggerKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:fieldTaggerKernel:1.0 fieldTaggerKernel_0 ]

  # Create instance: sm2nfKernel_0, and set properties
  set sm2nfKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:sm2nfKernel:1.0 sm2nfKernel_0 ]

  # Create instance: nf2hostKernel_0, and set properties
  set nf2hostKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:nf2hostKernel:1.0 nf2hostKernel_0 ]

  # Create instance: nf_kernel_0, and set properties
  set nf_kernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:nf_kernel:1.0 nf_kernel_0 ]

  # Create instance: NfForwardPayloadPipe, and set properties
  set NfForwardPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 NfForwardPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {2048} $NfForwardPayloadPipe


  # Create instance: NfMetaResultPipe, and set properties
  set NfMetaResultPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 NfMetaResultPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $NfMetaResultPipe


  # Create instance: NfInputPayloadPipe, and set properties
  set NfInputPayloadPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 NfInputPayloadPipe ]
  set_property CONFIG.FIFO_DEPTH {1024} $NfInputPayloadPipe


  # Create instance: NfInputMetaPipe, and set properties
  set NfInputMetaPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 NfInputMetaPipe ]
  set_property CONFIG.FIFO_DEPTH {1024} $NfInputMetaPipe


  # Create instance: IoPayloadEthernetOutPipe, and set properties
  set IoPayloadEthernetOutPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoPayloadEthernetOutPipe ]
  set_property CONFIG.FIFO_DEPTH {16} $IoPayloadEthernetOutPipe


  # Create instance: convertToEthernetKer_0, and set properties
  set convertToEthernetKer_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:convertToEthernetKernel:1.0 convertToEthernetKer_0 ]

  # Create instance: fromEthernetKernel_0, and set properties
  set fromEthernetKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:fromEthernetKernel:1.0 fromEthernetKernel_0 ]

  # Create instance: OverflowPipe, and set properties
  set OverflowPipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 OverflowPipe ]
  set_property CONFIG.FIFO_DEPTH {2048} $OverflowPipe


  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]

  # Create instance: payloadSinkKernel_0, and set properties
  set payloadSinkKernel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:payloadSinkKernel:1.0 payloadSinkKernel_0 ]

  # Create instance: IoBurstPayloadWritePipe, and set properties
  set IoBurstPayloadWritePipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 IoBurstPayloadWritePipe ]
  set_property CONFIG.FIFO_DEPTH {256} $IoBurstPayloadWritePipe


  # Create instance: axi_noc_1, and set properties
  set axi_noc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {9} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_1


  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M00_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M01_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M02_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M03_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M04_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M05_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M06_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M07_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/M08_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M03_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M08_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M04_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M01_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M02_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M05_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M06_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}} M07_AXI {read_bw {1} write_bw {1} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /RapidDetect/axi_noc_1/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:M01_AXI:M02_AXI:M03_AXI:M04_AXI:M05_AXI:M06_AXI:M07_AXI:M08_AXI} \
 ] [get_bd_pins /RapidDetect/axi_noc_1/aclk0]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_1


  # Create instance: smartconnect_2, and set properties
  set smartconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_2 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_2


  # Create instance: smartconnect_3, and set properties
  set smartconnect_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_3 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_3


  # Create instance: smartconnect_4, and set properties
  set smartconnect_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_4 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_4


  # Create instance: smartconnect_5, and set properties
  set smartconnect_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_5 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_5


  # Create instance: smartconnect_6, and set properties
  set smartconnect_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_6 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_6


  # Create instance: smartconnect_7, and set properties
  set smartconnect_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_7 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_7


  # Create instance: smartconnect_8, and set properties
  set smartconnect_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_8 ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_8


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins payloadReadKernel_0/m_axi_gmem0] [get_bd_intf_pins m_axi_gmem2]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins payloadReadKernel_0/m_axi_gmem1] [get_bd_intf_pins m_axi_gmem3]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axi_noc_1/S00_INI] [get_bd_intf_pins S00_INI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins payloadWriteKernel_0/m_axi_gmem0] [get_bd_intf_pins m_axi_gmem1]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins convertToEthernetKer_0/EthernetOutPipe] [get_bd_intf_pins EthernetOutPipe]
  connect_bd_intf_net -intf_net EthernetInPipe_1 [get_bd_intf_pins EthernetInPipe] [get_bd_intf_pins fromEthernetKernel_0/EthernetInPipe]
  connect_bd_intf_net -intf_net IoBurstPayloadWritePipe_M_AXIS [get_bd_intf_pins IoBurstPayloadWritePipe/M_AXIS] [get_bd_intf_pins payloadWriteKernel_0/IoBurstPayloadWritePipe]
  connect_bd_intf_net -intf_net IoBurstWritePipe_M_AXIS [get_bd_intf_pins IoBurstWritePipe/M_AXIS] [get_bd_intf_pins resultWriteKernel_0/IoBurstWritePipe]
  connect_bd_intf_net -intf_net IoPayloadEthernetOutPipe_M_AXIS [get_bd_intf_pins IoPayloadEthernetOutPipe/M_AXIS] [get_bd_intf_pins fieldTaggerKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadFinalPipe_M_AXIS [get_bd_intf_pins IoPayloadFinalPipe/M_AXIS] [get_bd_intf_pins payloadSourceKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadMergedPipe_M_AXIS [get_bd_intf_pins IoPayloadMergedPipe/M_AXIS] [get_bd_intf_pins convertToEthernetKer_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadPipe_M_AXIS [get_bd_intf_pins IoPayloadPipe/M_AXIS] [get_bd_intf_pins mergePipesKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net IoPayloadSplitPipe_M_AXIS [get_bd_intf_pins IoPayloadSplitPipe/M_AXIS] [get_bd_intf_pins mergePipesKernel_0/PayloadInSplitPipe]
  connect_bd_intf_net -intf_net MetaOutPipe_M_AXIS [get_bd_intf_pins HostMetaPipe/M_AXIS] [get_bd_intf_pins resultSinkKernel_0/RidMetaInPipe]
  connect_bd_intf_net -intf_net NfForwardPayloadPipe_M_AXIS [get_bd_intf_pins NfForwardPayloadPipe/M_AXIS] [get_bd_intf_pins nf2hostKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net NfInputMetaPipe_M_AXIS [get_bd_intf_pins NfInputMetaPipe/M_AXIS] [get_bd_intf_pins nf_kernel_0/RidMetaInPipe]
  connect_bd_intf_net -intf_net NfInputPayloadPipe_M_AXIS [get_bd_intf_pins NfInputPayloadPipe/M_AXIS] [get_bd_intf_pins nf_kernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net NfMetaResultPipe_M_AXIS [get_bd_intf_pins NfMetaResultPipe/M_AXIS] [get_bd_intf_pins nf2hostKernel_0/RidMetaInPipe]
  connect_bd_intf_net -intf_net OverflowPipe_M_AXIS [get_bd_intf_pins OverflowPipe/M_AXIS] [get_bd_intf_pins payloadSinkKernel_0/OverflowPipe]
  connect_bd_intf_net -intf_net PayloadSinkPipe_M_AXIS [get_bd_intf_pins HostPayloadPipe/M_AXIS] [get_bd_intf_pins payloadSinkKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net SmForwardPayloadPipe_M_AXIS [get_bd_intf_pins SmForwardPayloadPipe/M_AXIS] [get_bd_intf_pins sm2nfKernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net SmInputPayloadPipe_M_AXIS [get_bd_intf_pins SmInputPayloadPipe/M_AXIS] [get_bd_intf_pins sm_kernel_0/PayloadInPipe]
  connect_bd_intf_net -intf_net SmMetaResultPipe_M_AXIS [get_bd_intf_pins SmMetaResultPipe/M_AXIS] [get_bd_intf_pins sm2nfKernel_0/RidMetaInPipe]
  connect_bd_intf_net -intf_net axi_noc_1_M00_AXI [get_bd_intf_pins axi_noc_1/M00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M01_AXI [get_bd_intf_pins axi_noc_1/M01_AXI] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M02_AXI [get_bd_intf_pins axi_noc_1/M02_AXI] [get_bd_intf_pins smartconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M03_AXI [get_bd_intf_pins axi_noc_1/M03_AXI] [get_bd_intf_pins smartconnect_3/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M04_AXI [get_bd_intf_pins axi_noc_1/M04_AXI] [get_bd_intf_pins smartconnect_4/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M05_AXI [get_bd_intf_pins axi_noc_1/M05_AXI] [get_bd_intf_pins smartconnect_5/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M06_AXI [get_bd_intf_pins axi_noc_1/M06_AXI] [get_bd_intf_pins smartconnect_6/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M07_AXI [get_bd_intf_pins axi_noc_1/M07_AXI] [get_bd_intf_pins smartconnect_7/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_1_M08_AXI [get_bd_intf_pins axi_noc_1/M08_AXI] [get_bd_intf_pins smartconnect_8/S00_AXI]
  connect_bd_intf_net -intf_net fieldTaggerKernel_0_PayloadOutPipe [get_bd_intf_pins fieldTaggerKernel_0/PayloadOutPipe] [get_bd_intf_pins IoPayloadFinalPipe/S_AXIS]
  connect_bd_intf_net -intf_net fromEthernetKernel_0_EthernetOutPipe [get_bd_intf_pins fromEthernetKernel_0/EthernetOutPipe] [get_bd_intf_pins IoPayloadEthernetOutPipe/S_AXIS]
  connect_bd_intf_net -intf_net fromEthernetKernel_0_OverflowPipe [get_bd_intf_pins fromEthernetKernel_0/OverflowPipe] [get_bd_intf_pins OverflowPipe/S_AXIS]
  connect_bd_intf_net -intf_net mergePipesKernel_0_PayloadOutPipe [get_bd_intf_pins mergePipesKernel_0/PayloadOutPipe] [get_bd_intf_pins IoPayloadMergedPipe/S_AXIS]
  connect_bd_intf_net -intf_net nf2hostKernel_0_PayloadOutPipe [get_bd_intf_pins nf2hostKernel_0/PayloadOutPipe] [get_bd_intf_pins HostPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net nf2hostKernel_0_RidMetaOutPipe [get_bd_intf_pins nf2hostKernel_0/RidMetaOutPipe] [get_bd_intf_pins HostMetaPipe/S_AXIS]
  connect_bd_intf_net -intf_net nf_kernel_0_ResultOutPipe [get_bd_intf_pins nf_kernel_0/ResultOutPipe] [get_bd_intf_pins NfMetaResultPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadReadKernel_0_PayloadOutPipe [get_bd_intf_pins payloadReadKernel_0/PayloadOutPipe] [get_bd_intf_pins IoPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadReadKernel_0_PayloadOutSplitPipe [get_bd_intf_pins payloadReadKernel_0/PayloadOutSplitPipe] [get_bd_intf_pins IoPayloadSplitPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadSinkKernel_0_IoBurstPayloadWritePipe [get_bd_intf_pins payloadSinkKernel_0/IoBurstPayloadWritePipe] [get_bd_intf_pins IoBurstPayloadWritePipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadSourceKernel_0_PayloadForwardPipe [get_bd_intf_pins payloadSourceKernel_0/PayloadForwardPipe] [get_bd_intf_pins SmForwardPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net payloadSourceKernel_0_PayloadOutPipe [get_bd_intf_pins payloadSourceKernel_0/PayloadOutPipe] [get_bd_intf_pins SmInputPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net resultSinkKernel_0_IoBurstWritePipe [get_bd_intf_pins resultSinkKernel_0/IoBurstWritePipe] [get_bd_intf_pins IoBurstWritePipe/S_AXIS]
  connect_bd_intf_net -intf_net resultWriteKernel_0_m_axi_gmem0 [get_bd_intf_pins m_axi_gmem0] [get_bd_intf_pins resultWriteKernel_0/m_axi_gmem0]
  connect_bd_intf_net -intf_net sm2nfKernel_0_PayloadForwardPipe [get_bd_intf_pins sm2nfKernel_0/PayloadForwardPipe] [get_bd_intf_pins NfForwardPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net sm2nfKernel_0_PayloadOutPipe [get_bd_intf_pins sm2nfKernel_0/PayloadOutPipe] [get_bd_intf_pins NfInputPayloadPipe/S_AXIS]
  connect_bd_intf_net -intf_net sm2nfKernel_0_RidMetaOutPipe [get_bd_intf_pins sm2nfKernel_0/RidMetaOutPipe] [get_bd_intf_pins NfInputMetaPipe/S_AXIS]
  connect_bd_intf_net -intf_net sm_kernel_0_ResultOutPipe [get_bd_intf_pins sm_kernel_0/ResultOutPipe] [get_bd_intf_pins SmMetaResultPipe/S_AXIS]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins payloadReadKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins convertToEthernetKer_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_2_M00_AXI [get_bd_intf_pins smartconnect_2/M00_AXI] [get_bd_intf_pins fromEthernetKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_3_M00_AXI [get_bd_intf_pins smartconnect_3/M00_AXI] [get_bd_intf_pins sm2nfKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_4_M00_AXI [get_bd_intf_pins smartconnect_4/M00_AXI] [get_bd_intf_pins nf2hostKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_5_M00_AXI [get_bd_intf_pins smartconnect_5/M00_AXI] [get_bd_intf_pins payloadSinkKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_6_M00_AXI [get_bd_intf_pins smartconnect_6/M00_AXI] [get_bd_intf_pins resultSinkKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_7_M00_AXI [get_bd_intf_pins smartconnect_7/M00_AXI] [get_bd_intf_pins payloadWriteKernel_0/s_axi_control]
  connect_bd_intf_net -intf_net smartconnect_8_M00_AXI [get_bd_intf_pins smartconnect_8/M00_AXI] [get_bd_intf_pins resultWriteKernel_0/s_axi_control]

  # Create port connections
  connect_bd_net -net ap_clk_1  [get_bd_pins ap_clk] \
  [get_bd_pins IoBurstWritePipe/s_axis_aclk] \
  [get_bd_pins IoPayloadPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadSplitPipe/s_axis_aclk] \
  [get_bd_pins SmInputPayloadPipe/s_axis_aclk] \
  [get_bd_pins SmMetaResultPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadMergedPipe/s_axis_aclk] \
  [get_bd_pins IoPayloadFinalPipe/s_axis_aclk] \
  [get_bd_pins HostMetaPipe/s_axis_aclk] \
  [get_bd_pins HostPayloadPipe/s_axis_aclk] \
  [get_bd_pins SmForwardPayloadPipe/s_axis_aclk] \
  [get_bd_pins NfForwardPayloadPipe/s_axis_aclk] \
  [get_bd_pins NfMetaResultPipe/s_axis_aclk] \
  [get_bd_pins NfInputPayloadPipe/s_axis_aclk] \
  [get_bd_pins NfInputMetaPipe/s_axis_aclk] \
  [get_bd_pins fieldTaggerKernel_0/ap_clk] \
  [get_bd_pins mergePipesKernel_0/ap_clk] \
  [get_bd_pins nf_kernel_0/ap_clk] \
  [get_bd_pins payloadSourceKernel_0/ap_clk] \
  [get_bd_pins resultWriteKernel_0/ap_clk] \
  [get_bd_pins sm_kernel_0/ap_clk] \
  [get_bd_pins IoPayloadEthernetOutPipe/s_axis_aclk] \
  [get_bd_pins OverflowPipe/s_axis_aclk] \
  [get_bd_pins nf2hostKernel_0/ap_clk] \
  [get_bd_pins payloadReadKernel_0/ap_clk] \
  [get_bd_pins resultSinkKernel_0/ap_clk] \
  [get_bd_pins sm2nfKernel_0/ap_clk] \
  [get_bd_pins convertToEthernetKer_0/ap_clk] \
  [get_bd_pins IoBurstPayloadWritePipe/s_axis_aclk] \
  [get_bd_pins payloadWriteKernel_0/ap_clk] \
  [get_bd_pins axi_noc_1/aclk0] \
  [get_bd_pins smartconnect_2/aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins smartconnect_1/aclk] \
  [get_bd_pins smartconnect_3/aclk] \
  [get_bd_pins smartconnect_4/aclk] \
  [get_bd_pins smartconnect_5/aclk] \
  [get_bd_pins smartconnect_6/aclk] \
  [get_bd_pins smartconnect_7/aclk] \
  [get_bd_pins smartconnect_8/aclk] \
  [get_bd_pins payloadSinkKernel_0/ap_clk] \
  [get_bd_pins fromEthernetKernel_0/ap_clk]
  connect_bd_net -net ap_rst_n_1  [get_bd_pins ap_rst_n] \
  [get_bd_pins IoBurstWritePipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadSplitPipe/s_axis_aresetn] \
  [get_bd_pins SmInputPayloadPipe/s_axis_aresetn] \
  [get_bd_pins SmMetaResultPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadMergedPipe/s_axis_aresetn] \
  [get_bd_pins IoPayloadFinalPipe/s_axis_aresetn] \
  [get_bd_pins mergePipesKernel_0/ap_rst_n] \
  [get_bd_pins payloadSourceKernel_0/ap_rst_n] \
  [get_bd_pins resultWriteKernel_0/ap_rst_n] \
  [get_bd_pins sm_kernel_0/ap_rst_n] \
  [get_bd_pins HostMetaPipe/s_axis_aresetn] \
  [get_bd_pins HostPayloadPipe/s_axis_aresetn] \
  [get_bd_pins SmForwardPayloadPipe/s_axis_aresetn] \
  [get_bd_pins NfForwardPayloadPipe/s_axis_aresetn] \
  [get_bd_pins NfMetaResultPipe/s_axis_aresetn] \
  [get_bd_pins NfInputPayloadPipe/s_axis_aresetn] \
  [get_bd_pins NfInputMetaPipe/s_axis_aresetn] \
  [get_bd_pins fieldTaggerKernel_0/ap_rst_n] \
  [get_bd_pins nf_kernel_0/ap_rst_n] \
  [get_bd_pins IoPayloadEthernetOutPipe/s_axis_aresetn] \
  [get_bd_pins OverflowPipe/s_axis_aresetn] \
  [get_bd_pins nf2hostKernel_0/ap_rst_n] \
  [get_bd_pins payloadReadKernel_0/ap_rst_n] \
  [get_bd_pins resultSinkKernel_0/ap_rst_n] \
  [get_bd_pins sm2nfKernel_0/ap_rst_n] \
  [get_bd_pins convertToEthernetKer_0/ap_rst_n] \
  [get_bd_pins IoBurstPayloadWritePipe/s_axis_aresetn] \
  [get_bd_pins payloadWriteKernel_0/ap_rst_n] \
  [get_bd_pins payloadSinkKernel_0/ap_rst_n] \
  [get_bd_pins fromEthernetKernel_0/ap_rst_n]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins sm2nfKernel_0/PayloadSafePipe_TREADY] \
  [get_bd_pins nf2hostKernel_0/PayloadSafePipe_TREADY]

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
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {400,300} \
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

  set qsfp0_322mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {322265625} \
   ] $qsfp0_322mhz

  set qsfp2_322mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp2_322mhz ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {322265625} \
   ] $qsfp2_322mhz

  set qsfp0_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_4x ]

  set qsfp3_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp3_4x ]


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
      CPM_PCIE1_PF1_BAR2_QDMA_SCALE {Megabytes} \
      CPM_PCIE1_PF1_BAR2_QDMA_SIZE {256} \
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
    CONFIG.NUM_CLKS {7} \
    CONFIG.NUM_HBM_BLI {0} \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_NMI {7} \
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
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_cips/M02_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M06_INI {read_bw {10} write_bw {10} initial_boot {true}} M01_AXI {read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64}} M00_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}}} \
   CONFIG.DEST_IDS {M01_AXI:0x1c0:M02_AXI:0x280:M00_AXI:0x140} \
   CONFIG.REMAPS {M00_INI {{0x20108000000 0x00038000000 0x08000000}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins /axi_noc_cips/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M01_AXI {read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M03_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_AXI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64}}} \
   CONFIG.DEST_IDS {M01_AXI:0x1c0:M02_AXI:0x280:M00_AXI:0x140} \
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

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M02_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk6]

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
    CONFIG.HAS_ARESETN {0} \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {2} \
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

  # Create instance: qsfp
  create_hier_cell_qsfp [current_bd_instance .] qsfp

  # Create instance: qsfp1
  create_hier_cell_qsfp1 [current_bd_instance .] qsfp1

  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_1


  # Create instance: reset_registers_0, and set properties
  set block_name reset_registers
  set block_cell_name reset_registers_0
  if { [catch {set reset_registers_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $reset_registers_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.RESET_PIPE_LEN {8} $reset_registers_0


  # Create interface connections
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem0 [get_bd_intf_pins RapidDetect/m_axi_gmem0] [get_bd_intf_pins axi_noc_mc_ddr4_1/S00_AXI]
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem1 [get_bd_intf_pins axi_noc_mc_ddr4_1/S01_AXI] [get_bd_intf_pins RapidDetect/m_axi_gmem1]
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem2 [get_bd_intf_pins RapidDetect/m_axi_gmem2] [get_bd_intf_pins axi_noc_0/HBM00_AXI]
  connect_bd_intf_net -intf_net RapidDetect_m_axi_gmem3 [get_bd_intf_pins RapidDetect/m_axi_gmem3] [get_bd_intf_pins axi_noc_0/HBM01_AXI]
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins qsfp/S_AXIS] [get_bd_intf_pins RapidDetect/EthernetOutPipe]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_noc_cips_M00_AXI [get_bd_intf_pins axi_noc_cips/M00_AXI] [get_bd_intf_pins base_logic/s_axi_pcie_mgmt_slr0]
  connect_bd_intf_net -intf_net axi_noc_cips_M00_INI [get_bd_intf_pins axi_noc_cips/M00_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_INI [get_bd_intf_pins axi_noc_cips/M01_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M02_AXI [get_bd_intf_pins axi_noc_cips/M01_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_cips_M02_AXI1 [get_bd_intf_pins axi_noc_cips/M02_AXI] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_cips_M02_INI [get_bd_intf_pins axi_noc_cips/M02_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M03_INI [get_bd_intf_pins axi_noc_cips/M03_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M04_INI [get_bd_intf_pins axi_noc_cips/M04_INI] [get_bd_intf_pins axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M05_INI [get_bd_intf_pins axi_noc_cips/M05_INI] [get_bd_intf_pins axi_noc_0/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M06_INI [get_bd_intf_pins axi_noc_cips/M06_INI] [get_bd_intf_pins RapidDetect/S00_INI]
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
  connect_bd_intf_net -intf_net qsfp0_322mhz_1 [get_bd_intf_ports qsfp0_322mhz] [get_bd_intf_pins qsfp/qsfp0_322mhz]
  connect_bd_intf_net -intf_net qsfp1_M_AXIS [get_bd_intf_pins qsfp1/M_AXIS] [get_bd_intf_pins RapidDetect/EthernetInPipe]
  connect_bd_intf_net -intf_net qsfp1_qsfp0_4x [get_bd_intf_ports qsfp3_4x] [get_bd_intf_pins qsfp1/qsfp0_4x]
  connect_bd_intf_net -intf_net qsfp2_322mhz_1 [get_bd_intf_ports qsfp2_322mhz] [get_bd_intf_pins qsfp1/qsfp0_322mhz]
  connect_bd_intf_net -intf_net qsfp_qsfp0_4x [get_bd_intf_ports qsfp0_4x] [get_bd_intf_pins qsfp/qsfp0_4x]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins qsfp/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M01_AXI [get_bd_intf_pins smartconnect_1/M01_AXI] [get_bd_intf_pins qsfp1/S00_AXI]
  connect_bd_intf_net -intf_net sys_clk0_0_1 [get_bd_intf_ports sys_clk0_0] [get_bd_intf_pins axi_noc_mc_ddr4_0/sys_clk0]
  connect_bd_intf_net -intf_net sys_clk0_1_1 [get_bd_intf_ports sys_clk0_1] [get_bd_intf_pins axi_noc_mc_ddr4_1/sys_clk0]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_0/gpio_io_o] \
  [get_bd_pins reset_registers_0/reset_sync]
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
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins qsfp/axis_aclk] \
  [get_bd_pins qsfp1/axis_aclk] \
  [get_bd_pins reset_registers_0/clk]
  connect_bd_net -net clock_reset_clk_usr_1  [get_bd_pins clock_reset/clk_usr_1] \
  [get_bd_pins qsfp/aclk] \
  [get_bd_pins qsfp1/aclk] \
  [get_bd_pins smartconnect_1/aclk] \
  [get_bd_pins axi_noc_cips/aclk6]
  connect_bd_net -net clock_reset_resetn_pcie_ic  [get_bd_pins clock_reset/resetn_pcie_ic] \
  [get_bd_pins cips/dma1_intrfc_resetn]
  connect_bd_net -net clock_reset_resetn_pcie_periph  [get_bd_pins clock_reset/resetn_pcie_periph] \
  [get_bd_pins base_logic/resetn_pcie_periph]
  connect_bd_net -net clock_reset_resetn_pl_ic  [get_bd_pins clock_reset/resetn_pl_ic] \
  [get_bd_pins base_logic/resetn_pl_ic]
  connect_bd_net -net clock_reset_resetn_pl_periph  [get_bd_pins clock_reset/resetn_pl_periph] \
  [get_bd_pins base_logic/resetn_pl_periph]
  connect_bd_net -net clock_reset_resetn_usr_0_periph  [get_bd_pins clock_reset/resetn_usr_0_periph] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in] \
  [get_bd_pins qsfp/axis_aresetn] \
  [get_bd_pins qsfp1/axis_aresetn]
  connect_bd_net -net clock_reset_resetn_usr_1_periph  [get_bd_pins clock_reset/resetn_usr_1_periph] \
  [get_bd_pins qsfp/aresetn] \
  [get_bd_pins qsfp1/aresetn] \
  [get_bd_pins smartconnect_1/aresetn]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn  [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn]
  connect_bd_net -net reset_registers_0_resetn  [get_bd_pins reset_registers_0/resetn] \
  [get_bd_pins RapidDetect/ap_rst_n] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

  # Create address segments
  assign_bd_address -offset 0x020200000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x020200002C00 -range 0x00000080 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200470000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp/control_interface/axi_gpio_gt_control/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200570000 -range 0x00001000 -with_name SEG_axi_gpio_gt_control_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp1/control_interface/axi_gpio_gt_control/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200460000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp/control_interface/axi_gpio_gt_monitor/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200560000 -range 0x00001000 -with_name SEG_axi_gpio_gt_monitor_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp1/control_interface/axi_gpio_gt_monitor/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200450000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp/control_interface/axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200550000 -range 0x00001000 -with_name SEG_axi_gpio_resets_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp1/control_interface/axi_gpio_resets/S_AXI/Reg] -force
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
  assign_bd_address -offset 0x020201000000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/convertToEthernetKer_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020200440000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp/dcmac_wrapper/dcmac/s_axi/Reg] -force
  assign_bd_address -offset 0x020200540000 -range 0x00010000 -with_name SEG_dcmac_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp1/dcmac_wrapper/dcmac/s_axi/Reg] -force
  assign_bd_address -offset 0x020201010000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/fromEthernetKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020101010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs base_logic/gcq_m2r/S00_AXI/S00_AXI_Reg] -force
  assign_bd_address -offset 0x020200500000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp1/dcmac_wrapper/gtwiz_wrapper/gtwiz_versal/Quad0_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020200400000 -range 0x00040000 -with_name SEG_gtwiz_versal_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs qsfp/dcmac_wrapper/gtwiz_wrapper/gtwiz_versal/Quad0_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020101000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs base_logic/hw_discovery/s_axi_ctrl_pf0/reg0] -force
  assign_bd_address -offset 0x020201020000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/nf2hostKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020201030000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/payloadReadKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020201040000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/payloadSinkKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020201050000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/payloadWriteKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020101040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs clock_reset/pcie_mgmt_pdi_reset/pcie_mgmt_pdi_reset_gpio/S_AXI/Reg] -force
  assign_bd_address -offset 0x020201060000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/resultSinkKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020201070000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/resultWriteKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020201080000 -range 0x00000400 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RapidDetect/sm2nfKernel_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x020101001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs base_logic/uuid_rom/S_AXI/reg0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x020200002C00 -range 0x00000080 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200470000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp/control_interface/axi_gpio_gt_control/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200570000 -range 0x00001000 -with_name SEG_axi_gpio_gt_control_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp1/control_interface/axi_gpio_gt_control/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200460000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp/control_interface/axi_gpio_gt_monitor/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200560000 -range 0x00001000 -with_name SEG_axi_gpio_gt_monitor_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp1/control_interface/axi_gpio_gt_monitor/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200450000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp/control_interface/axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200550000 -range 0x00001000 -with_name SEG_axi_gpio_resets_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp1/control_interface/axi_gpio_resets/S_AXI/Reg] -force
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
  assign_bd_address -offset 0x020200440000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp/dcmac_wrapper/dcmac/s_axi/Reg] -force
  assign_bd_address -offset 0x020200540000 -range 0x00010000 -with_name SEG_dcmac_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp1/dcmac_wrapper/dcmac/s_axi/Reg] -force
  assign_bd_address -offset 0x020101010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs base_logic/gcq_m2r/S00_AXI/S00_AXI_Reg] -force
  assign_bd_address -offset 0x020200400000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp/dcmac_wrapper/gtwiz_wrapper/gtwiz_versal/Quad0_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020200500000 -range 0x00040000 -with_name SEG_gtwiz_versal_Reg_1 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs qsfp1/dcmac_wrapper/gtwiz_wrapper/gtwiz_versal/Quad0_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020101000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs base_logic/hw_discovery/s_axi_ctrl_pf0/reg0] -force
  assign_bd_address -offset 0x020101040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs clock_reset/pcie_mgmt_pdi_reset/pcie_mgmt_pdi_reset_gpio/S_AXI/Reg] -force
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
