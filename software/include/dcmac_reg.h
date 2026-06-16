#pragma once

#include <cstdint>
#include <unordered_map>
#include <string>

enum access_type_t {
  RO,  // Read-Only
  RW   // Read-Write
};

struct field_info_t {
  uint8_t start;
  uint8_t length;
  uint32_t default_value;
  access_type_t type;
};

struct register_info_t {
  uint64_t offset;
  access_type_t type;
  std::unordered_map<std::string, field_info_t> fields;
};

const std::unordered_map<std::string, register_info_t> dcmac_registers = {
    {"CONFIGURATION_REVISION",             {0x0000, RO, {}}},
    {"GLOBAL_MODE",                        {
        0x0004, RW,
        {
            {"ctl_tx_independent_tsmac_and_phy_mode", { 0,  1,     0, RW}},
            {"ctl_tx_all_ch_tick_reg_mode_sel",       { 1,  1,     0, RW}},
            {"ctl_rx_independent_tsmac_and_phy_mode", { 4,  1,     0, RW}},
            {"ctl_rx_all_ch_tick_reg_mode_sel",       { 5,  1,     0, RW}},
            {"ctl_tx_axis_cfg",                       { 8,  1,     0, RW}},
            {"ctl_rx_axis_cfg",                       {12,  1,     0, RW}},
            {"ctl_tx_pcs_active_ports",               {16,  3,     5, RW}},
            {"ctl_rx_pcs_active_ports",               {20,  3,     5, RW}},
            {"ctl_rx_fec_errind_mode",                {24,  1,     1, RW}},
            {"ctl_tx_fec_ck_unique_flip",             {25,  1,     1, RW}},
            {"ctl_rx_fec_ck_unique_flip",             {26,  1,     1, RW}}
        }
    }},
    {"TEST_DEBUG",                         {
        0x0008, RW,
        {
            {"ctl_test_mode_pin_char",     { 0,  1,     0, RW}},
            {"ctl_test_mode_memcel",       { 4,  4,     0, RW}},
            {"ctl_rx_phy_debug_select",    { 8,  5,     0, RW}},
            {"ctl_rx_mac_debug_select",    {13,  4,     0, RW}},
            {"ctl_tx_phy_debug_select",    {17,  4,     0, RW}},
            {"ctl_tx_mac_debug_select",    {21,  4,     0, RW}},
            {"ctl_rx_ecc_err_clear",       {25,  1,     0, RW}},
            {"ctl_tx_ecc_err_clear",       {26,  1,     0, RW}},
            {"ctl_tx_ecc_err_count_tick",  {27,  1,     0, RW}},
            {"ctl_axi_af_thresh_override", {28,  4,     8, RW}}
        }
    }},
    {"EMA_CONFIGURATION",                  {
        0x000C, RW,
        {
            {"ctl_mem_ctrl",       { 0, 10, 0x11b, RW}},
            {"emaa",               { 0,  3,   0x3, RW}},
            {"emab",               { 3,  3,   0x3, RW}},
            {"emasa",              { 6,  1,   0x0, RW}},
            {"stov",               { 7,  1,   0x0, RW}},
            {"mc_mem_ctrl_enable", { 8,  1,   0x1, RW}}
        }
    }},
    {"CLOCK_DISABLE",                      {
        0x0010, RW,
        {
            {"ctl_mem_disable_rx_axi_clk",    { 0,  1,     0, RW}},
            {"ctl_mem_disable_tx_axi_clk",    { 1,  1,     0, RW}},
            {"ctl_mem_disable_rx_macif_clk",  { 2,  1,     0, RW}},
            {"ctl_mem_disable_tx_macif_clk",  { 3,  1,     0, RW}},
            {"ctl_mem_disable_rx_core_clk",   { 4,  1,     0, RW}},
            {"ctl_mem_disable_tx_core_clk",   { 5,  1,     0, RW}},
            {"ctl_mem_disable_rx_flexif_clk", { 6,  6,     0, RW}},
            {"ctl_mem_disable_tx_flexif_clk", {12,  6,     0, RW}},
            {"ctl_mem_disable_rx_serdes_clk", {18,  6,     0, RW}},
            {"ctl_mem_disable_tx_serdes_clk", {24,  6,     0, RW}}
        }
    }},
    {"BLOCK_DISABLE",                      {
        0x0014, RW,
        {
            {"ctl_mem_disable_rx_pcs_cpcs",         { 0,  6,     0, RW}},
            {"ctl_mem_disable_rx_pcs_align_buffer", { 6,  6,     0, RW}},
            {"ctl_mem_disable_rx_pcs_decoder",      {12,  1,     0, RW}},
            {"ctl_mem_disable_tx_pcs_cpcs",         {16,  6,     0, RW}},
            {"ctl_mem_disable_tx_ts2phy",           {22,  1,     0, RW}},
            {"ctl_mem_disable_tx_pcs_encoder",      {23,  1,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY0",               {
        0x0018, RW,
        {
            {"ctl_rsvd0", { 0, 32,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY1",               {
        0x001C, RW,
        {
            {"ctl_rsvd1", { 0, 32,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY2",               {
        0x0020, RW,
        {
            {"ctl_rsvd2", { 0, 32,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY3",               {
        0x0024, RW,
        {
            {"ctl_rsvd3", { 0, 32,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY4",               {
        0x0028, RW,
        {
            {"ctl_rsvd4", { 0, 32,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY5",               {
        0x002C, RW,
        {
            {"ctl_rsvd5", { 0, 32,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY6",               {
        0x0030, RW,
        {
            {"ctl_rsvd6", { 0, 32,     0, RW}}
        }
    }},
    {"CONFIGURATION_EMPTY7",               {
        0x0034, RW,
        {
            {"ctl_rsvd7", { 0, 32,     0, RW}}
        }
    }},
    {"MAC_CONFIG_REG_TX_WR",               {
        0x0038, RW,
        {
            {"mac_tx_cfg_data",    { 0,  8,     0, RW}},
            {"mac_tx_cfg_index",   { 8,  5,     0, RW}},
            {"mac_tx_cfg_channel", {16,  6,     0, RW}},
            {"mac_tx_cfg_wr",      {24,  1,     0, RW}},
            {"mac_tx_cfg_enable",  {28,  1,     0, RW}}
        }
    }},
    {"MAC_CONFIG_REG_TX_RD",               {
        0x003C, RW,
        {
            {"mac_tx_cfg_data_rd", { 0,  8,     0, RW}}
        }
    }},
    {"GLOBAL_CONTROL_REG_RX",              {
        0x00F0, RW,
        {
            {"soft_rx_core_reset",  { 0,  1,     0, RW}},
            {"soft_rx_macif_reset", { 1,  1,     0, RW}},
            {"soft_rx_axi_reset",   { 2,  1,     0, RW}}
        }
    }},
    {"ALL_CHANNEL_MAC_TICK_REG_RX",        {
        0x00F4, RW,
        {
            {"rx_all_channel_mac_soft_pm_tick", { 0,  1,     0, RW}}
        }
    }},
    {"GLOBAL_CONTROL_REG_TX",              {
        0x00F8, RW,
        {
            {"soft_tx_core_reset",  { 0,  1,     0, RW}},
            {"soft_tx_macif_reset", { 1,  1,     0, RW}},
            {"soft_tx_axi_reset",   { 2,  1,     0, RW}}
        }
    }},
    {"ALL_CHANNEL_MAC_TICK_REG_TX",        {
        0x00FC, RW,
        {
            {"rx_all_channel_mac_soft_pm_tick", { 0,  1,     0, RW}}
        }
    }},
    {"STAT_TX_ECC_ERR_REG",                {
        0x01B0, RO,
        {
            {"stat_tx_ecc0_err0", { 0,  1,     0, RO}},
            {"stat_tx_ecc0_err1", { 1,  1,     0, RO}},
            {"stat_tx_ecc1_err0", { 2,  1,     0, RO}},
            {"stat_tx_ecc1_err1", { 3,  1,     0, RO}},
            {"stat_tx_ecc2_err0", { 4,  1,     0, RO}},
            {"stat_tx_ecc2_err1", { 5,  1,     0, RO}}
        }
    }},
    {"C0_CHANNEL_CONFIGURATION_TX",        {
        0x1000, RW,
        {
            {"c0_ctl_tx_fcs_ins_enable",         { 0,  1,     1, RW}},
            {"c0_ctl_tx_ignore_fcs",             { 1,  1,     1, RW}},
            {"c0_ctl_tx_send_lfi",               { 2,  1,     0, RW}},
            {"c0_ctl_tx_send_rfi",               { 3,  1,     0, RW}},
            {"c0_ctl_tx_send_idle",              { 4,  1,     0, RW}},
            {"c0_ctl_tx_custom_preamble_enable", { 5,  1,     0, RW}},
            {"c0_ctl_tx_ipg_value",              { 8,  4,   0xC, RW}},
            {"c0_ctl_tx_corrupt_fcs_on_err",     {16,  2,     0, RW}}
        }
    }},
    {"C0_CHANNEL_CONFIGURATION_RX",        {
        0x1004, RW,
        {
            {"c0_ctl_rx_is_clause_49",   { 0,  1,     1, RW}},
            {"c0_ctl_rx_delete_fcs",     { 1,  1,     1, RW}},
            {"c0_ctl_rx_ignore_fcs",     { 2,  1,     0, RW}},
            {"c0_ctl_rx_process_lfi",    { 3,  1,     0, RW}},
            {"c0_ctl_rx_check_sfd",      { 4,  1,     0, RW}},
            {"c0_ctl_rx_check_preamble", { 5,  1,     0, RW}},
            {"c0_ctl_rx_ignore_inrange", { 6,  1,     0, RW}},
            {"c0_ctl_rx_max_packet_len", {16, 14, 0x2580, RW}}
        }
    }},
    {"C0_CHANNEL_CONTROL_REG_RX",          {
        0x1030, RW,
        {
            {"c0_soft_rx_mac_channel_flush", { 0,  1,     0, RW}}
        }
    }},
    {"C0_CHANNEL_CONTROL_REG_TX",          {
        0x1038, RW,
        {
            {"c0_soft_tx_mac_channel_flush", { 0,  1,     0, RW}}
        }
    }},
    {"C0_TX_MODE_REG",                     {
        0x1040, RW,
        {
            {"c0_ctl_tx_data_rate",                   { 0,  2,     0, RW}},
            {"c0_ctl_tx_use_custom_vl_length_minus1", { 2,  1,     0, RW}},
            {"c0_ctl_tx_use_custom_vl_marker_ids",    { 3,  1,     0, RW}},
            {"c0_ctl_tx_tick_reg_mode_sel",           { 4,  1,     0, RW}},
            {"c0_ctl_tx_flexif_select",               { 5,  2,     1, RW}},
            {"c0_ctl_tx_flexif_am_mode",              { 7,  1,     0, RW}},
            {"c0_ctl_tx_flexif_pcs_wide_mode",        { 8,  1,     0, RW}},
            {"c0_ctl_tx_pma_lane_mux",                { 9,  2,     1, RW}},
            {"c0_ctl_tx_alt_serdes_clk_mux_disable",  {11,  1,     0, RW}},
            {"c0_ctl_tx_fec_mode",                    {16,  5,     4, RW}},
            {"c0_ctl_tx_fec_transcode_bypass",        {21,  1,     0, RW}},
            {"c0_ctl_tx_fec_four_lane_pmd",           {22,  1,     0, RW}}
        }
    }},
    {"C0_RX_MODE_REG",                     {
        0x1044, RW,
        {
            {"c0_ctl_rx_data_rate",                   { 0,  2,     0, RW}},
            {"c0_ctl_pcs_rx_ts_en",                   { 4,  1,     0, RW}},
            {"c0_ctl_rx_test_pattern",                { 8,  1,     0, RW}},
            {"c0_ctl_rx_use_custom_vl_length_minus1", { 9,  1,     0, RW}},
            {"c0_ctl_rx_use_custom_vl_marker_ids",    {10,  2,     1, RW}},
            {"c0_ctl_rx_tick_reg_mode_sel",           {11,  1,     0, RW}},
            {"c0_ctl_rx_pma_lane_mux",                {12,  2,     1, RW}},
            {"c0_ctl_rx_fec_mode",                    {16,  4,     4, RW}},
            {"c0_ctl_rx_fec_bypass_indication",       {21,  1,     0, RW}},
            {"c0_ctl_rx_fec_bypass_correction",       {22,  1,     0, RW}},
            {"c0_ctl_rx_fec_transcode_clause49",      {23,  1,     0, RW}},
            {"c0_ctl_rx_fec_alignment_bypass",        {24,  1,     0, RW}},
            {"c0_ctl_rx_fec_transcode_bypass",        {25,  1,     0, RW}},
            {"c0_ctl_rx_degrade_enable",              {26,  1,     0, RW}},
            {"c0_ctl_rx_fec_ext_align_buff_enable",   {27,  1,     0, RW}}
        }
    }},
    {"C0_RX_FEC_SLICE_CONFIGURATION1",     {
        0x1048, RW,
        {
            {"c0_ctl_rx_degrade_interval", { 0, 32,     0, RW}}
        }
    }},
    {"C0_RX_FEC_SLICE_CONFIGURATION2",     {
        0x104C, RW,
        {
            {"c0_ctl_rx_degrade_act_thresh", { 0, 32,     0, RW}}
        }
    }},
    {"C0_RX_FEC_SLICE_CONFIGURATION3",     {
        0x1050, RW,
        {
            {"c0_ctl_rx_degrade_deact_thresh", { 0, 32,     0, RW}}
        }
    }},
    {"C0_CONFIGURATION_RX",                {
        0x10A0, RW,
        {
            {"c0_ctl_rx_flexif_select",        { 0,  2,     1, RW}},
            {"c0_ctl_rx_flexif_pcs_wide_mode", { 2,  1,     0, RW}}
        }
    }},
    {"C0_PORT_CONTROL_REG_RX",             {
        0x10F0, RW,
        {
            {"c0_soft_rx_flexif_reset", { 0,  1,     0, RW}},
            {"c0_soft_rx_serdes_reset", { 1,  1,     0, RW}}
        }
    }},
    {"C0_PORT_TICK_REG_RX",                {
        0x10F4, RW,
        {
            {"c0_rx_port_soft_pm_tick", { 0,  1,     1, RW}}
        }
    }},
    {"C0_PORT_CONTROL_REG_TX",             {
        0x10F8, RW,
        {
            {"c0_soft_tx_flexif_reset", { 0,  1,     1, RW}},
            {"c0_soft_tx_serdes_reset", { 1,  1,     0, RW}}
        }
    }},
    {"C0_PORT_TICK_REG_TX",                {
        0x10FC, RW,
        {
            {"c0_tx_port_soft_pm_tick", { 0,  1,     1, RW}}
        }
    }},
    {"C0_STAT_CHAN_TX_MAC_STATUS_REG",     {
        0x1100, RO,
        {
            {"c0_stat_tx_local_fault",  { 0,  1,     0, RO}},
            {"c0_stat_tx_tsmac_ovf",    { 1,  1,     0, RO}},
            {"c0_stat_tx_tsmac_unf",    { 2,  1,     0, RO}},
            {"c0_stat_tx_packet_small", { 3,  1,     0, RO}},
            {"c0_stat_tx_sic_overflow", { 4,  1,     0, RO}}
        }
    }},
    {"C0_STAT_CHAN_TX_MAC_RT_STATUS_REG",  {
        0x1104, RO,
        {
            {"c0_stat_tx_local_fault",  { 0,  1,     0, RO}},
            {"c0_stat_tx_tsmac_ovf",    { 1,  1,     0, RO}},
            {"c0_stat_tx_tsmac_unf",    { 2,  1,     0, RO}},
            {"c0_stat_tx_packet_small", { 3,  1,     0, RO}},
            {"c0_stat_tx_sic_overflow", { 4,  1,     0, RO}}
        }
    }},
    {"C0_STAT_CHAN_TX_STATISTICS_READY",   {
        0x1108, RO,
        {
            {"c0_stat_tx_channel_mac_statistics_ready", { 0,  1,     1, RO}}
        }
    }},
    {"C0_STAT_CHAN_RX_MAC_STATUS_REG",     {
        0x1140, RO,
        {
            {"c0_stat_rx_remote_fault",         { 0,  1,     0, RO}},
            {"c0_stat_rx_local_fault",          { 1,  1,     0, RO}},
            {"c0_stat_rx_internal_local_fault", { 2,  1,     0, RO}},
            {"c0_stat_rx_received_local_fault", { 3,  1,     0, RO}},
            {"c0_stat_rx_bad_preamble",         { 4,  1,     0, RO}},
            {"c0_stat_rx_bad_sfd",              { 5,  1,     0, RO}},
            {"c0_stat_rx_got_signal_os",        { 6,  1,     0, RO}},
            {"c0_stat_rx_invalid_start",        { 7,  1,     0, RO}},
            {"c0_stat_rx_bad_code",             { 8,  1,     0, RO}}
        }
    }},
    {"C0_STAT_CHAN_RX_MAC_RT_STATUS_REG",  {
        0x1144, RO,
        {
            {"c0_stat_rx_remote_fault",         { 0,  1,     0, RO}},
            {"c0_stat_rx_local_fault",          { 1,  1,     0, RO}},
            {"c0_stat_rx_internal_local_fault", { 2,  1,     0, RO}},
            {"c0_stat_rx_received_local_fault", { 3,  1,     0, RO}},
            {"c0_stat_rx_bad_preamble",         { 4,  1,     0, RO}},
            {"c0_stat_rx_bad_sfd",              { 5,  1,     0, RO}},
            {"c0_stat_rx_got_signal_os",        { 6,  1,     0, RO}},
            {"c0_stat_rx_invalid_start",        { 7,  1,     0, RO}},
            {"c0_stat_rx_bad_code",             { 8,  1,     0, RO}}
        }
    }},
    {"C0_STAT_CHAN_RX_STATISTICS_READY",   {
        0x1148, RO,
        {
            {"c0_stat_tx_channel_mac_statistics_ready", { 0,  1,     1, RO}}
        }
    }},
    {"C0_STAT_PORT_TX_MAC_STATUS_REG",     {
        0x1180, RO,
        {
            {"c0_stat_tx_axis_unf", { 0,  1,     0, RO}},
            {"c0_stat_tx_axis_err", { 0,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_TX_MAC_RT_STATUS_REG",  {
        0x1184, RO,
        {
            {"c0_stat_tx_axis_unf", { 0,  1,     0, RO}},
            {"c0_stat_tx_axis_err", { 0,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_RX_MAC_STATUS_REG",     {
        0x11C0, RO,
        {
            {"c0_stat_rx_axis_fifo_overflow", { 0,  1,     0, RO}},
            {"c0_stat_rx_axis_err",           { 1,  1,     0, RO}},
            {"c0_stat_rx_phy2ts_buf_err",     { 2,  1,     0, RO}},
            {"c0_stat_rx_macif_fifo_ovf",     { 3,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_RX_MAC_RT_STATUS_REG",  {
        0x11C4, RO,
        {
            {"c0_stat_rx_axis_fifo_overflow", { 0,  1,     0, RO}},
            {"c0_stat_rx_axis_err",           { 1,  1,     0, RO}},
            {"c0_stat_rx_phy2ts_buf_err",     { 2,  1,     0, RO}},
            {"c0_stat_rx_macif_fifo_ovf",     { 3,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_TX_PHY_STATUS_REG",     {
        0x1800, RO,
        {
            {"c0_stat_tx_pcs_bad_code",  { 0,  1,     0, RO}},
            {"c0_stat_tx_flex_fifo_err", { 1,  1,     0, RO}},
            {"c0_stat_tx_flex_coa",      { 2,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_TX_PHY_RT_STATUS_REG",  {
        0x1804, RO,
        {
            {"c0_stat_tx_pcs_bad_code",  { 0,  1,     0, RO}},
            {"c0_stat_tx_flex_fifo_err", { 1,  1,     0, RO}},
            {"c0_stat_tx_flex_coa",      { 2,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_TX_STATISTICS_READY",   {0x1808, RO, {}}},
    {"C0_STAT_PORT_TX_FEC_STATUS_REG",     {
        0x180C, RO,
        {
            {"c0_stat_tx_fec_pcs_lane_align", { 0,  1,     1, RO}},
            {"c0_stat_tx_fec_pcs_block_lock", { 1,  1,     1, RO}},
            {"c0_stat_tx_fec_pcs_am_lock",    { 2,  1,     1, RO}}
        }
    }},
    {"C0_STAT_PORT_TX_FEC_RT_STATUS_REG",  {
        0x1810, RO,
        {
            {"c0_stat_tx_fec_pcs_lane_align", { 0,  1,     1, RO}},
            {"c0_stat_tx_fec_pcs_block_lock", { 1,  1,     1, RO}},
            {"c0_stat_tx_fec_pcs_am_lock",    { 2,  1,     1, RO}}
        }
    }},
    {"C0_STAT_PORT_RX_PHY_STATUS_REG",     {
        0x1C00, RO,
        {
            {"c0_stat_rx_status",        { 0,  1,     1, RO}},
            {"c0_stat_rx_block_lock",    { 1,  1,     0, RO}},
            {"c0_stat_rx_aligned",       { 2,  1,     1, RO}},
            {"c0_stat_rx_misaligned",    { 3,  1,     0, RO}},
            {"c0_stat_rx_aligned_err",   { 4,  1,     0, RO}},
            {"c0_stat_rx_hi_ber",        { 5,  1,     0, RO}},
            {"c0_stat_rx_framing_err",   { 6,  1,     0, RO}},
            {"c0_stat_rx_pcs_bad_code",  { 7,  1,     0, RO}},
            {"c0_stat_rx_synced",        { 8,  1,     0, RO}},
            {"c0_stat_rx_synced_err",    { 9,  1,     0, RO}},
            {"c0_stat_rx_bip_err",       {10,  1,     0, RO}},
            {"c0_stat_rx_flex_fifo_err", {11,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_RX_PHY_RT_STATUS_REG",  {
        0x1C04, RO,
        {
            {"c0_stat_rx_status",        { 0,  1,     1, RO}},
            {"c0_stat_rx_block_lock",    { 1,  1,     0, RO}},
            {"c0_stat_rx_aligned",       { 2,  1,     1, RO}},
            {"c0_stat_rx_misaligned",    { 3,  1,     0, RO}},
            {"c0_stat_rx_aligned_err",   { 4,  1,     0, RO}},
            {"c0_stat_rx_hi_ber",        { 5,  1,     0, RO}},
            {"c0_stat_rx_framing_err",   { 6,  1,     0, RO}},
            {"c0_stat_rx_pcs_bad_code",  { 7,  1,     0, RO}},
            {"c0_stat_rx_synced",        { 8,  1,     0, RO}},
            {"c0_stat_rx_synced_err",    { 9,  1,     0, RO}},
            {"c0_stat_rx_bip_err",       {10,  1,     0, RO}},
            {"c0_stat_rx_flex_fifo_err", {11,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_RX_STATISTICS_READY",   {0x1C08, RO, {}}},
    {"C0_STAT_PORT_RX_BLOCK_LOCK_REG",     {0x1C0C, RO, {}}},
    {"C0_STAT_PORT_RX_LANE_SYNC_REG",      {0x1C10, RO, {}}},
    {"C0_STAT_PORT_RX_LANE_SYNC_ERR_REG",  {0x1C14, RO, {}}},
    {"C0_STAT_PORT_RX_FEC_STATUS_REG",     {
        0x1C34, RO,
        {
            {"c0_stat_rx_fec_aligned",      { 0,  1,     1, RO}},
            {"c0_stat_rx_fec_hi_ser",       { 1,  1,     0, RO}},
            {"c0_stat_rx_fec_lane_lock",    { 2,  4,    15, RO}},
            {"c0_stat_rx_fec_degraded_ser", { 6,  1,     0, RO}},
            {"c0_stat_rx_fec_rm_degraded",  { 7,  1,     0, RO}}
        }
    }},
    {"C0_STAT_PORT_RX_FEC_RT_STATUS_REG",  {
        0x1C38, RO,
        {
            {"c0_stat_rx_fec_aligned",      { 0,  1,     1, RO}},
            {"c0_stat_rx_fec_hi_ser",       { 1,  1,     0, RO}},
            {"c0_stat_rx_fec_lane_lock",    { 2,  4,     0, RO}},
            {"c0_stat_rx_fec_degraded_ser", { 6,  1,     0, RO}},
            {"c0_stat_rx_fec_rm_degraded",  { 7,  1,     0, RO}}
        }
    }}
};

// Helper function to extract field value from a register value
inline uint32_t extract_field(uint32_t reg_value, const field_info_t &field_info) {
  return (reg_value >> field_info.start) & ((1 << field_info.length) - 1);
}
