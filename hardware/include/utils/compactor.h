/******************************************************************************
MIT License

Copyright (c) 2024-2026 Shashank Obla, Carnegie Mellon University

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

#include <hls_stream.h>
#include <hls_task.h>
#include "types.h"

/**
 * Compactor Kernel
 *
 * Takes multi-word flits and compacts down to narrower flits by removing empty words.
 * The micro-architecture is a tree of 2-to-1 compactors, which can be configured based on the FanIn and FanOut.
 *
 * Uses recursion with template specialization to construct a tree of 2-to-1 compactors
 * Launching tasks in a loop does not sit well with Vitis HLS simulation
 */

// Depth of internal compactor pipes
#ifndef COMPACTOR_PIPE_DEPTH
#define COMPACTOR_PIPE_DEPTH (8)
#endif

// User must provide a "bool getEmptyStatus(TPayload &payload)" and "void setEmptyStatus(TPayload &payload, BOOL
// isEmpty)" functions to populate the isEmpty information from the payload into the compactor payload, which is used by
// the compactor to determine whether a flit is empty and can be dropped.
template <typename TPayload>
struct CompactorPayload {
  BOOL eop;
  BOOL isEmpty;
  TPayload payload;
};

// Optional shuffle function to shuffle the wide payload for better compacting. Provided default does not shuffle.
// Toggle provides an option to change the shuffle pattern for consecutive flits, which can help with certain patterns
// that produce the same compactor input pattern often.
template <typename TWidePayload>
void compactorShufflePayload(TWidePayload &wideFlit, bool toggle) {}

// Core 2-to-1 compaction unit, takes two input streams and compacts into one output stream
template <typename TPayload>
void compact_2to1(hls::stream<CompactorPayload<TPayload>> &PayloadInPipe0,
                  hls::stream<CompactorPayload<TPayload>> &PayloadInPipe1,
                  hls::stream<CompactorPayload<TPayload>> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
  BOOL seenEop_0 = false, seenEop_1 = false;
  while (1) {
#pragma HLS PIPELINE II = 1

    CompactorPayload<TPayload> inFlit;
    BOOL valid_0 = false, valid_1 = false;  // is the input flit valid?

    // Without loss of generality we give higher priority to PayloadInPipe0 when both pipes have valid data
    if (!seenEop_0) valid_0 = PayloadInPipe0.read_nb(inFlit);
    if (!valid_0 && !seenEop_1) valid_1 = PayloadInPipe1.read_nb(inFlit);

    // If valid check if the flit is empty and if it is eop
    if (valid_0) {
      seenEop_0 = inFlit.eop;
      if (inFlit.isEmpty) valid_0 = false;  // if empty, mark as invalid to drop the flit
    }
    if (valid_1) {
      seenEop_1 = inFlit.eop;
      if (inFlit.isEmpty) valid_1 = false;  // if empty, mark as valid to drop the flit
    }

    // Synchronize on eops
    if (seenEop_0 && seenEop_1) {
      // If eops came with empty flits
      if (!(valid_0 || valid_1)) {
        valid_0 = true;
        inFlit.eop = true;
        inFlit.isEmpty = true;
      }
      seenEop_0 = false;
      seenEop_1 = false;
    } else {
      inFlit.eop = false;
    }

    // If valid, write to output pipe
    if (valid_0 || valid_1) {
      PayloadOutPipe.write(inFlit);
    }
  }
}

// General case - creates separate units per output FanOut first
template <int FanIn, int FanOut>
struct compactor_core_t {
  template <typename TPayload>
  static void compactor_core(hls::stream<CompactorPayload<TPayload>> *PayloadInPipes,
                             hls::stream<CompactorPayload<TPayload>> *PayloadOutPipes) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return

    hls_thread_local hls::task core_task_0(
        compactor_core_t<FanIn - FanIn / FanOut, FanOut - 1>::template compactor_core<TPayload>, PayloadInPipes,
        PayloadOutPipes);
    hls_thread_local hls::task core_task_1(compactor_core_t<FanIn / FanOut, 1>::template compactor_core<TPayload>,
                                           &PayloadInPipes[FanIn - FanIn / FanOut], &PayloadOutPipes[FanOut - 1]);
  }
};

// Per output pipe, create the tree of compactors
template <int FanIn>
struct compactor_core_t<FanIn, 1> {
  template <typename TPayload>
  static void compactor_core(hls::stream<CompactorPayload<TPayload>> *PayloadInPipes,
                             hls::stream<CompactorPayload<TPayload>> *PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
    hls_thread_local hls::stream<CompactorPayload<TPayload>, COMPACTOR_PIPE_DEPTH> inter_pipes_0, inter_pipes_1;

    hls_thread_local hls::task core_task_0(compactor_core_t<FanIn / 2, 1>::template compactor_core<TPayload>,
                                           PayloadInPipes, &inter_pipes_0);
    hls_thread_local hls::task core_task_1(compactor_core_t<FanIn / 2, 1>::template compactor_core<TPayload>,
                                           &PayloadInPipes[FanIn / 2], &inter_pipes_1);
    hls_thread_local hls::task merge_task(compact_2to1<TPayload>, inter_pipes_0, inter_pipes_1, PayloadOutPipe[0]);
  }
};

// Base case - 2 input pipes, 1 output pipe, use a single compactor unit
template <>
struct compactor_core_t<2, 1> {
  template <typename TPayload>
  static void compactor_core(hls::stream<CompactorPayload<TPayload>> *PayloadInPipes,
                             hls::stream<CompactorPayload<TPayload>> *PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
    hls_thread_local hls::task merge_task(compact_2to1<TPayload>, PayloadInPipes[0], PayloadInPipes[1],
                                          PayloadOutPipe[0]);
  }
};

// Takes a single pipe with a wide payload and fans out into multiple pipes, this also checks for empty flits and only
// sends valid flits to the compactor cores. Also contains an optional toggle shuffle to shuffle the input payload for
// better compacting.
template <typename TWidePayload, typename TPayload, int FanIn>
void split_pipes(hls::stream<TWidePayload> &WidePayloadInPipe,
                 hls::stream<CompactorPayload<TPayload>> *PayloadInPipes) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
  BOOL toggle = false;

SPLIT_PIPES:
  while (1) {
#pragma HLS PIPELINE II = 1
    toggle = !toggle;  // toggle for optional shuffle
    BOOL valid = false;

    TWidePayload wideFlit;
    valid = WidePayloadInPipe.read_nb(wideFlit);
    compactorShufflePayload(wideFlit, toggle);  // optional shuffle for better compacting

    if (valid) {
      for (int i = 0; i < FanIn; i++) {
#pragma HLS UNROLL
        CompactorPayload<TPayload> inFlit;
        inFlit.eop = wideFlit.eop;
        inFlit.payload = wideFlit.payload[i];
        inFlit.isEmpty = getEmptyStatus(wideFlit.payload[i]);
        if (!inFlit.isEmpty || inFlit.eop) PayloadInPipes[i].write(inFlit);
        // std::cout << "Writing to compactor split pipe idx " << i << ": " << inFlit.payload.data << ", " <<
        // (inFlit.eop ? "EOP" : "DATA") << ", " << (inFlit.isEmpty ? "EMPTY" : "VALID") << std::endl;
      }
    }
  }
}

// Merge the output pipes from the compactor cores back into a single pipe. This also populates the isEmpty information
// into the narrow flit so that downstream modules can know which flits are empty and drop them if needed.
template <typename TNarrowPayload, typename TPayload, int FanOut>
void merge_pipes(hls::stream<CompactorPayload<TPayload>> *PayloadOutPipes,
                 hls::stream<TNarrowPayload> &NarrowPayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
  BOOL eop[FanOut] = {false};
#pragma HLS ARRAY_PARTITION variable = eop complete

  while (1) {
#pragma HLS PIPELINE II = 1
    // Output Flit
    TNarrowPayload narrowFlit;
    CompactorPayload<TPayload> outFlit[FanOut];
    BOOL valid[FanOut] = {false};

    for (int i = 0; i < FanOut; i++) {
#pragma HLS UNROLL
      // Synchronize on eop, stop until all pipexs have seen eop
      if (!eop[i]) valid[i] = PayloadOutPipes[i].read_nb(outFlit[i]);
    }

    BOOL validFlit = false;
    for (int i = 0; i < FanOut; i++) {
#pragma HLS UNROLL
      if (valid[i]) {
        validFlit |= true;  // Check if any pipe has valid data to write to output
        narrowFlit.payload[i] = outFlit[i].payload;
        setEmptyStatus(narrowFlit.payload[i], outFlit[i].isEmpty);  // populate isEmpty information into the narrow flit
      } else {
        setEmptyStatus(narrowFlit.payload[i], true);  // set isEmpty to true for empty flit
      }
    }

    // Set eops
    for (int i = 0; i < FanOut; i++) {
#pragma HLS UNROLL
      if (valid[i] && outFlit[i].eop) {
        eop[i] = true;
      }
    }

    // Check if all pipes have seen eop
    BOOL eopAll = true;
    for (int i = 0; i < FanOut; i++) {
#pragma HLS UNROLL
      eopAll &= eop[i];
    }

    // If all pipes have seen eop, reset eop status for all pipes
    if (eopAll) {
      for (int i = 0; i < FanOut; i++) {
#pragma HLS UNROLL
        eop[i] = false;
      }
    }

    // Write to output and mark eop
    narrowFlit.eop = eopAll;
    if (validFlit) NarrowPayloadOutPipe.write(narrowFlit);
  }
}

// Wrapper function to instantiate the split, tree and merge tasks
template <typename TWidePayload, typename TNarrowPayload, typename TPayload, int FanIn, int FanOut>
void compactor(hls::stream<TWidePayload> &WidePayloadInPipe, hls::stream<TNarrowPayload> &NarrowPayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = WidePayloadInPipe
#pragma HLS INTERFACE mode = axis port = NarrowPayloadOutPipe
#pragma HLS DATAFLOW

  hls_thread_local hls::stream<CompactorPayload<TPayload>, COMPACTOR_PIPE_DEPTH> in_pipes[FanIn];
  hls_thread_local hls::stream<CompactorPayload<TPayload>, COMPACTOR_PIPE_DEPTH> out_pipes[FanOut];

  hls_thread_local hls::task split_task(split_pipes<TWidePayload, TPayload, FanIn>, WidePayloadInPipe, in_pipes);

  hls_thread_local hls::task core_task(compactor_core_t<FanIn, FanOut>::template compactor_core<TPayload>, in_pipes,
                                       out_pipes);

  hls_thread_local hls::task merge_task(merge_pipes<TNarrowPayload, TPayload, FanOut>, out_pipes, NarrowPayloadOutPipe);
}
