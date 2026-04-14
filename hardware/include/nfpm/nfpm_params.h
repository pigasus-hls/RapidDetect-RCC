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

/// NFPM Configuration parameters

#define NFPM_MASK_WIDTH (8)  // Hyperscan native width 8 bytes. Do not chage.

#ifndef NFPM_USE_SHIFTOR
#define NFPM_USE_SHIFTOR (1)  // if 0, only hashtable is used to check
#endif

#ifndef NFPM_FRWD_SUPER
#define NFPM_FRWD_SUPER (1)  // if 1, shift-or superchar takes from the future
#endif

#ifndef NFPM_UNROLL
#define NFPM_UNROLL (2)  // unrolled scan per "cycle"
#endif

#ifndef NFPM_TRACKSEQ
#define NFPM_TRACKSEQ (0)  // set 1 to enable sequence numbering (not in Pigasus)
#endif
#ifndef NFPM_CHECKSEQ
#define NFPM_CHECKSEQ \
  (0)  // set to 1 if compactor should fold only records with the same sequence number;
       // leave as 0 for faster logic if barrier is applied in between sequence
#endif

#ifndef NFPM_TRACKPOS
#define NFPM_TRACKPOS (0)  // set 1 to track match position; typically used together with DOFOLDING=false compaction
#endif

#undef NFPM_LOOKUP_WIDTH
#define NFPM_LOOKUP_WIDTH (NFPM_UNROLL * NFPM_MASK_WIDTH)  // number of hashtable at each size

// Field Tagging for Rapid Detect
#ifndef NFPM_CHECKFIELD
#define NFPM_CHECKFIELD (0)  // set 1 to enable field tagging
#endif

// Use an alternate primary FP the fingerprint is 128-bit.
// len 8 and len 1 literals share a 32-bit bitmap.
// len 7 and len 2 literals share a 32-bit bitmap.  etc.
// This might be better when CPM conjuncts are very long.
//
// In contrast, the default primary FP gives each len its own 16-bit bitmap.
#ifndef NFPM_CHECK_FPDWIDE
#define NFPM_CHECK_FPDWIDE (0)
#endif

// Enable crosscheck with a 2nd alternate FP to improve strictness
// Same as baseline primary FP except ussing bit [7:4] of the hash key instead of [3:1].
#ifndef NFPM_CHECK_FPALT
#define NFPM_CHECK_FPALT (0)
#endif

#include <iostream>
[[maybe_unused]] static void nfpmPrintParameters() {
  std::cout << "NFPM_MASK_WIDTH = " << NFPM_MASK_WIDTH
            << "\n"
            // << "NFPM_BITMAP_TABLE0_MAXLGDEPTH=" << NFPM_BITMAP_TABLE0_MAXLGDEPTH << "\n"
            << "NFPM_USE_SHIFTOR = " << NFPM_USE_SHIFTOR << "\n"
            << "NFPM_FRWD_SUPER = " << NFPM_FRWD_SUPER << "\n"
            << "NFPM_UNROLL =" << NFPM_UNROLL << "\n"
            << "NFPM_TRACKSEQ = " << NFPM_TRACKSEQ << "\n"
            << "NFPM_CHECKSEQ = " << NFPM_CHECKSEQ << "\n"
            << "NFPM_TRACKPOS = " << NFPM_TRACKPOS
            << "\n"
            // << "NFPM_BUCKET_WIDTH=" << NFPM_BUCKET_WIDTH << "\n"
            << "NFPM_LOOKUP_WIDTH = " << NFPM_LOOKUP_WIDTH << "\n"
            << "NFPM_CHECKFIELD = " << NFPM_CHECKFIELD << "\n"
            << "NFPM_CHECK_FPDWIDE = " << NFPM_CHECK_FPDWIDE << "\n"
            << "NFPM_CHECK_FPALT = " << NFPM_CHECK_FPALT << "\n";
}
