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

set src_dir        [file dirname [file normalize [info script]]]
set cwd            [pwd]
set design_name     "amd_v80_gen5x8_25.1"
set bd_name         "top"

proc do_aved_create_design { } {
  global bd_name
  global src_dir
  global design_name
  # Create the project targeting its part
  create_project prj "[pwd]/build" -part xcv80-lsva4737-2MHP-e-S -force


  # Set project IP repositories
  set_property ip_repo_paths "${src_dir}/iprepo/ ${src_dir}/../../../../hls_workspace/" [current_project]
  update_ip_catalog

  # Create block diagram
  create_bd_design  ${bd_name}
  current_bd_design ${bd_name}

  # Set NoC Phases for HBM access
  set_property NOC_PHASES "load_HBM, HBM0, HBM1, HBM2, HBM3, HBM4, HBM5, HBM6, HBM7, HBM8, HBM9, HBM10, HBM11, HBM12, HBM13, HBM14, HBM15" [current_project]

  # Add RTL files
  import_files -fileset sources_1 -norecurse "$src_dir/sources/axis_seg_to_unseg_converter.v"
  import_files -fileset sources_1 -norecurse "$src_dir/sources/dcmac_syncer_reset.v"
  import_files -fileset sources_1 -norecurse "$src_dir/sources/reset_registers.v"

  # Add base to block diagram
  source "$src_dir/bd/create_bd_design.tcl"
  create_root_design ""

  # Write the block diagram wrapper and set it as design top
  add_files -norecurse [make_wrapper -files [get_files "${bd_name}.bd"] -top]
  update_compile_order -fileset sources_1
  update_compile_order -fileset sim_1
  set_property top top_wrapper [current_fileset]

  # Add constraint and hook files
  import_files -fileset constrs_1 -norecurse "$src_dir/constraints/impl.xdc"
  import_files -fileset constrs_1 -norecurse "$src_dir/constraints/impl.pins.xdc"
  import_files -fileset utils_1   -norecurse "$src_dir/constraints/opt.post.tcl"
  import_files -fileset utils_1   -norecurse "$src_dir/constraints/place.pre.tcl"
  import_files -fileset utils_1   -norecurse "$src_dir/constraints/write_device_image.pre.tcl"

  set_property -dict { used_in_synthesis false    processing_order NORMAL } [get_files *impl.xdc]
  set_property -dict { used_in_synthesis false    processing_order NORMAL } [get_files *impl.pins.xdc]

  set_property STEPS.OPT_DESIGN.TCL.POST         [get_files *opt.post.tcl]                [get_runs impl_1]
  set_property STEPS.PLACE_DESIGN.TCL.PRE        [get_files *place.pre.tcl]               [get_runs impl_1]
  set_property STEPS.WRITE_DEVICE_IMAGE.TCL.PRE  [get_files *write_device_image.pre.tcl]  [get_runs impl_1]

  # Set Explore directives to impl_1
  set_property STEPS.OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
  set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
  set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
  set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
  set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
  set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
  set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
  set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AddRetime [get_runs impl_1]
}

do_aved_create_design
