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

#include <utils/types.h>
#include <io_types.h>

#include <vector>

#ifndef NOCASE
#define NOCASE (0)
#endif

#ifndef TEST_PREPEND7
#define TEST_PREPEND7 (0)
#endif

#ifndef TEST_SAMEFLOW
#define TEST_SAMEFLOW (0)
#endif

#ifndef TEST_SKIP_WRITE
#define TEST_SKIP_WRITE (0)
#endif

#ifndef TEST_FALSE_POSITIVES
#define TEST_FALSE_POSITIVES (1)
#endif

#if NOCASE
#include "testpattern3_nocase.h"
#else
#include "testpattern3.h"
#endif

/// Check test pattern results against expected results and accumulate data for summary statistics
template <typename T>
void testPatternCheck(
    RidBcnt ridBcnt,  // detection entry
                      // data accumulation
    UINT tidx,        // position in trace buffer
                      // data accumulation for false positive
                      // checking; only works if positions are tracked
    StripedVector<T, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &pktBuff,
    std::vector<UINT> &pktOffset);

/// Dump test results
void testPatternFinish();
