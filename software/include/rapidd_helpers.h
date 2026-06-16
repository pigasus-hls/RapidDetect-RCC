/******************************************************************************
MIT License

Copyright (c) 2026 Shashank Obla, Carnegie Mellon University

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************************/

#pragma once

#include <cstdint>

// Register Offsets
#define AP_CTRL_OFFSET                 0x00ULL

// Source Kernel offsets
#define SOURCE_CH0_ADDR_L_OFFSET       0x10ULL
#define SOURCE_CH0_ADDR_H_OFFSET       0x14ULL
#define SOURCE_CH1_ADDR_L_OFFSET       0x1CULL
#define SOURCE_CH1_ADDR_H_OFFSET       0x20ULL
#define SOURCE_LEN_OFFSET              0x28ULL
#define SOURCE_PAYLOAD_CNT_OFFSET      0x30ULL

// Ethernet IO offsets
#define ETH_THROTTLE_OFFSET            0x10ULL
#define ETH_STATS_DROPPED_OFFSET       0x10ULL
#define ETH_STATS_TOTAL_OFFSET         0x20ULL
#define ETH_STATS_IN_BUSY_OFFSET       0x30ULL
#define ETH_STATS_OUT_BUSY_OFFSET      0x40ULL

// Rules Kernel offsets
#define RULES_ADDR_L_OFFSET            0x10ULL
#define RULES_ADDR_H_OFFSET            0x14ULL
#define RULES_SKIP_OFFSET              0x1CULL
#define RULES_BUF_SIZE_OFFSET          0x24ULL

// Payload Kernel offsets
#define PAYLOAD_ADDR_L_OFFSET          0x10ULL
#define PAYLOAD_ADDR_H_OFFSET          0x14ULL
#define PAYLOAD_LIMIT_OFFSET           0x1CULL
#define PAYLOAD_SKIP_OFFSET            0x24ULL
#define PAYLOAD_MAX_SIZE_OFFSET        0x2CULL

// Stats Kernel offsets
#define STATS_PAYLOAD_CNT_OFFSET       0x10ULL
#define SINK_RESULT_CNT_OFFSET         0x18ULL
#define SINK_CTRL_OFFSET               0x10ULL
#define PAYLOAD_SINK_STATS_OFFSET      0x10ULL
#define PAYLOAD_SINK_CTRL_OFFSET       0x20ULL

// Unified Register API
uint32_t rapidd_read_reg(unsigned int pf, uint64_t base_addr, uint64_t offset);
uint32_t rapidd_write_reg(unsigned int pf, uint64_t base_addr, uint64_t offset, uint32_t val);

// Refactored setup functions
void setup_source_kernel(unsigned int pf, uint64_t input_addr_ch0, uint64_t input_addr_ch1, uint32_t trace_len);
void setup_eth_kernel(unsigned int pf, uint32_t throttle_period);
void setup_rules_kernel(unsigned int pf, uint64_t results_addr, bool skip_write, uint32_t buffer_size);
void setup_payload_kernel(unsigned int pf, uint64_t sink_addr, uint32_t tick_counter_limit, bool skip_write,
                          uint32_t max_size);
void reset_rapidd_design(unsigned int pf);
