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

/**
 * NFPM Stages
 *
 * Stage 1: Detect contextual string tokens in a pkt
 * Stage 2: Compact line rate checking output to hit-rate lookup (optional)
 * Stage 3: Accumulate contextual strings as a fingerprint
 * Stage 4: Check for required contextual string matches for SM/PG reported fast pattern detections
 */

#include <hls_stream.h>

#include <nfpm/nfpm_params.h>
#include <nf_params.h>
#include <utils/types.h>
#include <utils/compactor.h>

#include <nfpm/nfpm.h>

// Primary input type:  payload flit to be scanned
using NfpmPayloadFlit = PayloadFlit<NFPM_UNROLL
#if NF_INPKT_SEQ
                                    ,
                                    PayloadSeqBase
#else
                                    ,
                                    PayloadSeqVoid
#endif
#if NFPM_CHECKFIELD
                                    ,
                                    PayloadFieldTagBase
#else
                                    ,
                                    PayloadFieldTagVoid
#endif
                                    >;

/// Primary NFPM Detection Result Type
struct NfRidMeta {
  URID ridPlusOne;
#if NFPM_TRACKSEQ
  USEQ seq;
#endif
#if NFPM_TRACKPOS
  UPOS pos;
#endif
};

// NFPM bundle of results
template <int NumHits>
struct NfMetaFlit {
  NfRidMeta payload[NumHits];
  BOOL hasHits;
  BOOL eop;
};
using NfInputMetaFlit = NfMetaFlit<NF_METAIN_WIDTH>;

// auxilary function for use with compactor
static inline BOOL isSamePayload(NfRidMeta a, NfRidMeta b) { return ((a).ridPlusOne == (b).ridPlusOne); }

static inline void copyMetaFlit(NfInputMetaFlit &dest, NfInputMetaFlit &src) { dest = src; }

// Output of Stage 1
template <int NumHits>
struct NfpmHitsFlit {
  BOOL eop;
  NfpmHashHit payload[NumHits];
};

using NfWideKeyMetaFlit = NfpmHitsFlit<NFPM_MASK_WIDTH * NFPM_UNROLL>;  // before compaction

// Output of Stage 2
struct NfFingerprintFlit {
  NfpmFingerprint fp[NFPM_MASK_WIDTH];
#if NFPM_CHECK_FPALT
  NfpmFingerprint fp_alt[NFPM_MASK_WIDTH];
#endif
};

// Output of Stage 4
using NfResultMetaFlit = NfMetaFlit<NF_RESULT_WIDTH>;

/**
 * NFPM Stage 1
 *
 * Check patterns concurrently against bytestream for hits are line rate. "NFPM_UNROLL * NFPM_MASK_WIDTH" number of
 * bytes are scanned for fast patterns per cycle. This finds all of the "contextual patterns" referred to by all rules.
 */
void nfpmHashCheckStage(hls::stream<NfpmPayloadFlit> &PayloadInPipe, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe0,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe1, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe2,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe3, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe4,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe5, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe6,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe7);

/**
 * NFPM Stage 2
 *
 * Combine detections from Stages 1 to form a fingerprint that reflects all of the contextual string patters include in
 * the packet.
 */
void fpAccumulateStage(hls::stream<NfWideKeyMetaFlit> &HitsInPipe0, hls::stream<NfWideKeyMetaFlit> &HitsInPipe1,
                       hls::stream<NfWideKeyMetaFlit> &HitsInPipe2, hls::stream<NfWideKeyMetaFlit> &HitsInPipe3,
                       hls::stream<NfWideKeyMetaFlit> &HitsInPipe4, hls::stream<NfWideKeyMetaFlit> &HitsInPipe5,
                       hls::stream<NfWideKeyMetaFlit> &HitsInPipe6, hls::stream<NfWideKeyMetaFlit> &HitsInPipe7,
                       hls::stream<NfFingerprintFlit> &FprintOutPipe);

/**
 * NFPM Stage 3
 *
 * For each RID detected by SM lookup the fingerprint corresponding to its required contextual string patterns. A hit is
 * reported only if the packet's fingerprint is a superset of the rule's.
 */
void fpMatchStage(hls::stream<NfFingerprintFlit> &FprintInPipe, hls::stream<NfInputMetaFlit> &RidInPipe,
                  hls::stream<NfInputMetaFlit> &RidOutPipe);

/**
 * NFPM Stage 4
 *
 * Reduce output width by breaking up a (NF_METAIN_WIDTH) NfInputMetaFlit down to multiple smaller (NF_RESULT_WIDTH)
 * NfResultMetaFlit. All 0 NfResultMetaFlits are not forwarded.
 */
bool getEmptyStatus(NfRidMeta &flit);
void setEmptyStatus(NfRidMeta &flit, BOOL isEmpty);
void compactorShufflePayload(NfInputMetaFlit &wideFlit, bool toggle);
const auto nfpmResultDownshift =
    compactor<NfInputMetaFlit, NfResultMetaFlit, NfRidMeta, NF_METAIN_WIDTH, NF_RESULT_WIDTH>;

#ifndef NF_METAIN_WIDTH
#error NF_METAIN_WIDTH must be defined
#endif
