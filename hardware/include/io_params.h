/******************************************************************************
MIT License

Copyright (c) 2024-2026 Shashank Obla, Carnegie Mellon University
Copyright (c) 2024-2025 James C. Hoe, Carnegie Mellon University

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

#include <utils/pipes.h>
#include <mspm/mspm_params.h>
#include <sm_params.h>
#include <nf_params.h>
#include <rapidd_params.h>

// Number of payload flits must come in multiples of TBBURST which
// forms the pipelined inner loop of payloadWordReadKernel();
#define IO_READ_BURST (256)
#ifndef IO_READ_MULT
#define IO_READ_MULT (1)
#endif

// Number of parallel HBM channels to read from to get increased bandwidth and capacity. Must be <= MSPM_UNROLL since we
// read a contiguous chunk of payload flits and distribute across the channels.
#ifndef IO_HBM_NUM_CHANNELS
#define IO_HBM_NUM_CHANNELS (2)
#endif
#if IO_HBM_NUM_CHANNELS > MSPM_UNROLL
#error "IO_HBM_NUM_CHANNELS must be <= MSPM_UNROLL"
#endif

// Total number of bytes read per cycle by the payload read kernel
#define IO_READ_BURSTSZ (IO_READ_BURST * MSPM_UNROLL * MSPM_MASK_WIDTH)

#define HOST_RESULT_WIDTH NF_RESULT_WIDTH
#define HOST_PAYLOAD_WIDTH NFPM_UNROLL

// Width of DRAM write for improved bandwidth
#ifndef IO_WRITE_MULT
#define IO_WRITE_MULT (1)
#endif
#define IO_WRITE_WIDTH (HOST_RESULT_WIDTH * IO_WRITE_MULT)

// Width of Payload DRAM write for improved bandwidth
#ifndef PAYLOAD_WRITE_MULT
#define PAYLOAD_WRITE_MULT (1)
#endif
#define PAYLOAD_WRITE_WIDTH (HOST_PAYLOAD_WIDTH * PAYLOAD_WRITE_MULT)

// Ethernet packet size in number of flits
#ifndef ETH_BURST_SIZE
#define ETH_BURST_SIZE (32)
#endif

// Bandwidth measurement period in number of cycles
#ifndef BUSY_PERIOD_LENGTH
#define BUSY_PERIOD_LENGTH (1 << 14)
#endif

// Ethernet output bandwidth throttling period in number of cycles
#ifndef THROTTLE_PERIOD_LENGTH
#define THROTTLE_PERIOD_LENGTH (512)
#endif

#include <iostream>
[[maybe_unused]] static void ioPrintParameters() {
  const size_t sizeof_ridBcnt = 4 + 2 + ((MSPM_TRACKPOS && NFPM_TRACKPOS) ? 4 : 0);
  std::cout << "IO_READ_BURST=" << IO_READ_BURST << "\n"
            << "IO_READ_MULT=" << IO_READ_MULT << " (" << (IO_READ_MULT * MSPM_UNROLL * MSPM_MASK_WIDTH) << ")\n"
            << "IO_WRITE_MULT=" << IO_WRITE_MULT << " (" << IO_WRITE_WIDTH * sizeof_ridBcnt << ")\n"
            << "ETH_BURST_SIZE=" << ETH_BURST_SIZE << "\n"
            << "BUSY_PERIOD_LENGTH=" << BUSY_PERIOD_LENGTH << "\n";
}
