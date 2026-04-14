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

#include <nfpm/nfpm_params.h>

/// "Non-Fast-Pattern" Matcher (NFPM) Parameterization

#ifndef NF_INPKT_SEQ
#define NF_INPKT_SEQ (0)
#endif

#ifndef NF_SKIPREPEATS
// Suppress detection in the first 7 bytes which are repeats from the
// previous packet, serving as pretext only. Disabled by default.
// This should be disabled in Pigasus because UDP needs to be scanned
// from byte 0. Easier to just rescan the 7 repeated bytes in TCP.
#define NF_SKIPREPEATS (0)
#endif

// Input RID meta flit width
#ifndef NF_METAIN_WIDTH
#define NF_METAIN_WIDTH (4)
#endif

// Number of detection results to output per cycle
#ifndef NF_RESULT_WIDTH
#define NF_RESULT_WIDTH (NF_METAIN_WIDTH / 2)
#endif

// Toggle compaction ordering to load balance
#ifndef NF_RESULT_TOGGLECOMPACT
#define NF_RESULT_TOGGLECOMPACT (1)
#endif

// Use compactor to reduce final width
#ifndef NF_RESULT_BYCOMPACT
#define NF_RESULT_BYCOMPACT (1)
#endif

#include <iostream>
[[maybe_unused]] static void nfPrintParameters() {
  std::cout << "NF_RESULT_WIDTH = " << NF_RESULT_WIDTH << "\n"
            << "NF_RESULT_BYCOMPACT = " << NF_RESULT_BYCOMPACT << "\n"
            << "NF_RESULT_TOGGLECOMPACT = " << NF_RESULT_TOGGLECOMPACT << "\n"
            << "NF_METAIN_WIDTH = " << NF_METAIN_WIDTH << "\n"
            << "NF_INPKT_SEQ = " << NF_INPKT_SEQ << "\n"
            << "NF_SKIPREPEATS = " << NF_SKIPREPEATS << "\n";
}
