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

#include <mspm/mspm_params.h>

/// String Matcher (SM) Parameterization

// Payload flit carry its own sequence num
#ifndef SM_INPKT_SEQ
#define SM_INPKT_SEQ (0)
#endif

#ifndef SM_SKIPREPEATS
// Suppress detection in the first 7 bytes which are repeats from the
// previous packet, serving as pretext only. Disabled by default.
// This should be disabled in Pigasus because UDP needs to be scanned
// from byte 0. Easier to just rescan the 7 repeated bytes in TCP.
#define SM_SKIPREPEATS (0)
#endif

// Number of detection results to output per cycle
#ifndef SM_RESULT_WIDTH
#define SM_RESULT_WIDTH ((MSPM_LOOKUP_WIDTH * MSPM_MASK_WIDTH) / 2)
#endif
#if SM_RESULT_WIDTH > (MSPM_LOOKUP_WIDTH * MSPM_MASK_WIDTH)
#error SM_RESULT_WIDTH cannot be greater than (MSPM_LOOKUP_WIDTH * MSPM_MASK_WIDTH)
#endif

// Use compactor to reduce final width
#ifndef SM_RESULT_BYCOMPACT
#define SM_RESULT_BYCOMPACT (1)
#endif

// Toggle compaction ordering to load balance
#ifndef SM_RESULT_TOGGLECOMPACT
#define SM_RESULT_TOGGLECOMPACT (1)
#endif

// Expand overloaded RIDs in hardware
#ifndef SM_EXPAND_OVERLOADED
#define SM_EXPAND_OVERLOADED (2)
// 0: pass overloaded rid to software to expand - only allowed without MSPM_RESOLVE_CONFLICT
// 1: expand in hardware; frequent overloaded RIDs will slow down throughput a lot
// 2: a streamlined version by decomposing loops into kernels
#endif
#if MSPM_RESOLVE_CONFLICT && !SM_EXPAND_OVERLOADED
#error SM_EXPAND_OVERLOADED must be enabled if MSPM_RESOLVE_CONFLICT is enabled
#endif

// Expand overloaded RIDs in hardware
#ifndef SM_EXPAND_OVERLOADED_PACK
#define SM_EXPAND_OVERLOADED_PACK (SM_RESULT_WIDTH)
#endif
#if SM_EXPAND_OVERLOADED_PACK > SM_RESULT_WIDTH
#error SM_EXPAND_OVERLOADED_PACK cannot be greater than SM_RESULT_WIDTH
#endif
#if SM_EXPAND_OVERLOADED_PACK == 0
#error SM_EXPAND_OVERLOADED_PACK must be at least 1
#endif

// Choose expansion mode high frequency vs no bubbles
#ifndef SM_EXPAND_OVERLOADED_SUBMODE
#define SM_EXPAND_OVERLOADED_SUBMODE (1)
// 0: high frequency, but with bubbles between reads
// 1: no bubbles, but lower frequency (~440 MHz vs ~480 MHz)
#endif

// Pack RIDs in Flit to improve scan efficiency
#ifndef SM_EXPAND_OVERLOADED_SHIFT
#define SM_EXPAND_OVERLOADED_SHIFT (SM_RESULT_WIDTH / 2)
#endif
#if SM_EXPAND_OVERLOADED_SHIFT > (SM_RESULT_WIDTH - 1)
#error SM_EXPAND_OVERLOADED_PACK cannot be greater than (SM_RESULT_WIDTH-1)
#endif

// Pipe depth for the overloaded RID expansion kernel (can cause deadlocks if sized down)
#ifndef EXPOV_PIPE_DEPTH
#define EXPOV_PIPE_DEPTH (512)
#endif

#include <iostream>
[[maybe_unused]] static void smPrintParameters() {
  std::cout << "SM_RESULT_WIDTH = " << SM_RESULT_WIDTH << "\n"
            << "SM_RESULT_BYCOMPACT = " << SM_RESULT_BYCOMPACT << "\n"
            << "SM_RESULT_TOGGLECOMPACT = " << SM_RESULT_TOGGLECOMPACT << "\n"
            << "SM_EXPAND_OVERLOADED = " << SM_EXPAND_OVERLOADED << "\n"
            << "SM_EXPAND_OVERLOADED_PACK = " << SM_EXPAND_OVERLOADED_PACK << "\n"
            << "SM_EXPAND_OVERLOADED_SUBMODE = " << SM_EXPAND_OVERLOADED_SUBMODE << "\n"
            << "SM_EXPAND_OVERLOADED_SHIFT = " << SM_EXPAND_OVERLOADED_SHIFT << "\n"
            << "EXPOV_PIPE_DEPTH = " << EXPOV_PIPE_DEPTH << "\n"
            << "SM_SKIPREPEATS = " << SM_SKIPREPEATS << "\n"
            << "SM_INPKT_SEQ = " << SM_INPKT_SEQ << "\n";
}
