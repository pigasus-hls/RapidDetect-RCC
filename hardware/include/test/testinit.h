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

#include <vector>
#include <fstream>

#include <utils/types.h>
#include <io_types.h>

/**
 * Prepare test inputs into "packets" of "flits" for scanning.
 *
 * Each flit is PAYLOAD_WORD * MSPM_UNROLL bytes wide, which MSPM consumes in a single cycle. A packet is made up of 1
 * ore more flits.
 *
 * The hardcode test input for regression comprises variable length packet payloads in an array. Processing will pack a
 * packet's payload into a number of "flit", padding the last flit with 0xff. The last flit of a packet is marked EOP.
 *
 * Trace mode takes inputs ready to be consumed by the MSPM stage. Originally in Pigasus, the MSPM scanned each packet
 * independently. For a packet that is a part of a TCP flow, the TCP reassembly data mover would prepend a packet's
 * payload with the last 7 bytes of the previous packet in the same flow to detect patterns that straddle packets. A
 * mask prevents errant detection within the first 7 bytes belong to the previous packet (The regression test packets
 * are prepended with 7 0xff junk bytes).
 */

// Pad default pattern with gap packets to space out detection rate
#define TPINIT_EXTRA_PKTS (0)
#define TPINIT_EXTRA_PKT_LEN (1 * 64)
#define TPINIT_EXTRA_PKT_PAT (0xdeadbeeffeedface)

// Minimum payload size of a packet when initialializing from testpattern.h
#define TPINIT_PWRAP (256)

/// Load test pattern from testpattern.h into the input buffer
UINT loadDefaultTestInputBuffer(UINT tpPaddedByteLen,
                                StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS,
                                              MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &tpPaddedCharPtr,
                                std::vector<UINT> &tpPaddedPktOffset);

/**
 * Load test pattern from trace file into the input buffer
 *
 * This function also pre-processes the input and stores the offsets for verification by the testbench.
 * Superseded by the loadRawTraceInput function that directly loads the raw trace without pre-processing
 */
bool loadTraceTestInputBuffer(UINT &tpPaddedByteLen,
                              StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS,
                                            MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &tpPaddedCharPtr,
                              std::vector<UINT> &tpPaddedPktOffset, std::ifstream &datfile, UINT &tpNumPkt);

/**
 * Load raw trace test pattern from trace file into the input buffer without pre-processing.
 *
 * @return Total vector length of the loaded trace.
 */
UINT loadRawTraceInput(StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS,
                                     MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &traceBuffer,
                       std::string filename);
