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

/// MSPM Configuration parameters

#define MSPM_MASK_WIDTH (8)  // Hyperscan native width 8 bytes. Do not change.

// Flag to enable overload expansion
#ifndef MSPM_RESOLVE_CONFLICT
#define MSPM_RESOLVE_CONFLICT \
  (0)  // if 1, rid>=0x8000 points to an overloaded RID
       // rid&0x7fff points into the conflict_table
#endif

#ifndef MSPM_USE_SHIFTOR
#define MSPM_USE_SHIFTOR (1)  // if 0, only hashtable is used to check
#endif

#ifndef MSPM_FRWD_SUPER
#define MSPM_FRWD_SUPER (1)  // if 1, shift-or superchar takes from the future
#endif

#ifndef MSPM_UNROLL
#define MSPM_UNROLL (4)  // unrolled scan per "cycle"
#endif

#ifndef MSPM_CHECKTAG
#define MSPM_CHECKTAG (1)  // set 1 to enable tag checking option (not in Pigasus)
#endif

#ifndef MSPM_TRACKSEQ
#define MSPM_TRACKSEQ (0)  // set 1 to enable sequence numbering (not in Pigasus)
#endif
#ifndef MSPM_CHECKSEQ
#define MSPM_CHECKSEQ \
  (0)  // set to 1 if compactor should fold only
       // records with the same sequence number;
       // leave as 0 for faster logic if barrier
       // is applied in between sequence
#endif

#ifndef MSPM_TRACKPOS
#define MSPM_TRACKPOS \
  (0)  // set 1 to track match position; used with DOFOLDING=false
       // compaction to not lose track
#endif

#ifndef MSPM_LOOKUP_WIDTH
#define MSPM_LOOKUP_WIDTH (1)  // number of hashtable at each size
#endif

// Field Tagging for Rapid Detect
#ifndef MSPM_CHECKFIELD
#define MSPM_CHECKFIELD (0)  // set 1 to enable field tagging
#endif

#include <iostream>
[[maybe_unused]] static void mspmPrintParameters() {
  std::cout << "MSPM_MASK_WIDTH = " << MSPM_MASK_WIDTH << "\n"
            << "MSPM_RESOLVE_CONFLICT = " << MSPM_RESOLVE_CONFLICT << "\n"
            << "MSPM_USE_SHIFTOR = " << MSPM_USE_SHIFTOR << "\n"
            << "MSPM_FRWD_SUPER = " << MSPM_FRWD_SUPER << "\n"
            << "MSPM_UNROLL = " << MSPM_UNROLL << "\n"
            << "MSPM_CHECKTAG = " << MSPM_CHECKTAG << "\n"
            << "MSPM_TRACKSEQ = " << MSPM_TRACKSEQ << "\n"
            << "MSPM_CHECKSEQ = " << MSPM_CHECKSEQ << "\n"
            << "MSPM_TRACKPOS = " << MSPM_TRACKPOS << "\n"
            << "MSPM_LOOKUP_WIDTH = " << MSPM_LOOKUP_WIDTH << "\n";
}
