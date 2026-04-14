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
 * MSPM Stages
 *
 * Stage 1: Hash Check - Concurrent detection of fast pattern occurences in payload
 * Stage 2: Compactors - Compact line-rate detections to hit-rate RID lookup processing
 * Stage 3: Hash Lookup - Lookup RID (separated by pattern length) for detected fast patterns
 * Stage 4: Recombine Width - Combine by-len pipes into a single pipe
 * Stage 5 Optional: Result Downshift - Produce narrower output flit from length-separate streams
 * Stage 6 Optional: Overload Expansion - Expand Overloaded RID when  hashtable conflicts are enabled
 */

#include <hls_stream.h>

#include <mspm/mspm_params.h>
#include <sm_params.h>
#include <utils/types.h>
#include <utils/compactor.h>

#include <mspm/mspm.h>

/////////////////////////////////////////////////////////////////////////////////////////////
// Interstage data types
/////////////////////////////////////////////////////////////////////////////////////////////

// Primary input type: Payload flit to be scanned
using MspmPayloadFlit = PayloadFlit<MSPM_UNROLL
#if SM_INPKT_SEQ
                                    ,
                                    PayloadSeqBase
#else
                                    ,
                                    PayloadSeqVoid
#endif
#if MSPM_CHECKFIELD
                                    ,
                                    PayloadFieldTagBase
#else
                                    ,
                                    PayloadFieldTagVoid
#endif
                                    >;

// Output of Stage 1

// Hits identification; payload contains hash key to lookup RID
template <int NumHits>
struct MspmHitsFlit {
  BOOL eop;
  BOOL hasHits;
  MspmHashHit payload[NumHits];
};

// SmWideKeyMetaFlit is the wide, per-len results coming out of the shift-or stage.  MSPM_UNROLL * MSPM_MASK_WIDTH per
// cycle per len (2~8, 8 twice) per cycle.
using SmWideKeyMetaFlit = MspmHitsFlit<MSPM_MASK_WIDTH * MSPM_UNROLL>;

// Output of Stage 2

// SmNarrowKeyMetaFlit ais the compatacted, per-len result, zero removed and duplicates folded (optional).
#if (MSPM_LOOKUP_WIDTH == (MSPM_MASK_WIDTH * MSPM_UNROLL))
using SmNarrowKeyMetaFlit = SmWideKeyMetaFlit;  // if no compaction
#else
// LOOKUP_WIDTH per len (2~8, 8 twice) per cycle after compaction (usually 1)
using SmNarrowKeyMetaFlit = MspmHitsFlit<MSPM_LOOKUP_WIDTH>;
#endif

// Output of Stage 3

/// Primary MSPM Detection Result Type
struct SmRidMeta {
  URID ridPlusOne;
#if MSPM_TRACKSEQ
  USEQ seq;
#endif
#if MSPM_TRACKPOS
  UPOS pos;
#endif
#if MSPM_CHECKTAG && MSPM_RESOLVE_CONFLICT
  // check tag during overload expansion to reduce false positives
  MSPM_TAG tag;
#endif
};

// Auxiliary function for use with compactor
static inline BOOL isSamePayload(SmRidMeta a, SmRidMeta b) { return ((a).ridPlusOne == (b).ridPlusOne); }

// MSPM output bundle of results
template <int NumHits>
struct SmMetaFlit {
  SmRidMeta payload[NumHits];
  BOOL hasHits;
  BOOL eop;
};

// After hash lookup by pattern len in stage 3 (this is still per-len)
using SmLookupByLenResultMetaFlit = SmMetaFlit<MSPM_LOOKUP_WIDTH>;

// Output of Stage 4
// After joining all pattern len and aligning of EOP in stage 4
using SmLookupAllResultMetaFlit = SmMetaFlit<MSPM_LOOKUP_WIDTH * MSPM_MASK_WIDTH>;

// Output of Stage 5
// Narrower results  after optional compaction in stage 5
using SmResultMetaFlit_ = SmLookupAllResultMetaFlit;
#if SM_RESULT_WIDTH == (MSPM_LOOKUP_WIDTH * MSPM_MASK_WIDTH)
using SmResultMetaFlit = SmLookupAllResultMetaFlit;
#else
using SmResultMetaFlit = SmMetaFlit<SM_RESULT_WIDTH>;
#endif

// Output of Stage 6: uses same type as Stage 5
// For helper in stage 6
struct SmResultExpBundle {
  SmResultMetaFlit flit;
  BOOL gotoSlow;
};

struct SmResultExpOvBundle {
  SmResultMetaFlit flit;
  UIDX numORid;
};

struct SmResultExpOvCountBundle {
  SmResultMetaFlit flit;
  UIDX howmany[SM_RESULT_WIDTH];
  UIDX offset[SM_RESULT_WIDTH];
  UIDX loopCount;
  BOOL emptyEop;
};

/**
 * MSPM Stage 1
 *
 * Check patterns concurrently against bytestream for hits at line rate.  "MSPM_UNROLL * MSPM_MASK_WIDTH" number of
 * bytes are scanned for fast patterns per cycle.
 */
void mspmHashCheckStage(hls::stream<MspmPayloadFlit> &PayloadInPipe, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe0,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe1, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe2,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe3, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe4,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe5, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe6,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe7);

/**
 * MSPM Stage 2
 *
 * Separate for each pattern length, reduce from **upto** "MSPM_MASK_WIDTH * MSPM_MASK_WIDTH" number of hits per cycle
 * downto "MSPM_LOOKUP_WIDTH" number of hits per cycle. Hit rate is expected to be much lower than linerate. Downstream
 * hash table lookup just need to keep up with hashtable hit rate)
 */
bool getEmptyStatus(MspmHashHit &flit);
void setEmptyStatus(MspmHashHit &flit, BOOL isEmpty);
const auto mspmCompactorStageByLen =
    compactor<SmWideKeyMetaFlit, SmNarrowKeyMetaFlit, MspmHashHit, MSPM_MASK_WIDTH * MSPM_UNROLL, MSPM_LOOKUP_WIDTH>;

/**
 * MSPM Stage 3
 *
 * Lookup rule ids of hash table hits from the check stage. The stage has a much lower rate capacity relative to the
 * hashtable check stage.
 */
template <int WhichLen>
void mspmHashLookupStageByLen(hls::stream<SmNarrowKeyMetaFlit> &HitsNarrowInPipe,
                              hls::stream<SmLookupByLenResultMetaFlit> &RidOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = HitsNarrowInPipe
#pragma HLS INTERFACE mode = axis port = RidOutPipe
#pragma HLS PIPELINE II = 1 style = frp

  // whichLen 2~9; 9 is 2nd way of len 8
  MspmHashHit hits[MSPM_LOOKUP_WIDTH];
  BOOL eop = false;
  URID ridPlusOne[MSPM_LOOKUP_WIDTH];
  USEQ seqNum[MSPM_LOOKUP_WIDTH];
  UPOS posNum[MSPM_LOOKUP_WIDTH];
  MSPM_TAG tagNum[MSPM_LOOKUP_WIDTH];

  SmNarrowKeyMetaFlit narrowFlit;
  HitsNarrowInPipe.read(narrowFlit);

  for (UIDX pos = 0; pos < MSPM_LOOKUP_WIDTH; pos++) {
#pragma HLS UNROLL
    hits[pos] = narrowFlit.payload[pos];
  }

  // should be aligned across all pos, so just check first if multiple
  eop = narrowFlit.eop;

  // This is the main action!
  mspmHashLookupByLen(WhichLen, hits, ridPlusOne, seqNum, posNum, tagNum);

  {
    SmLookupByLenResultMetaFlit ridFlit;
    BOOL hasHits = false;

    ridFlit.eop = eop;
    for (UIDX which = 0; which < MSPM_LOOKUP_WIDTH; which++) {
#pragma HLS UNROLL
      ridFlit.payload[which].ridPlusOne = ridPlusOne[which];
#if MSPM_TRACKSEQ
      ridFlit.payload[which].seq = seqNum[which];
#endif
#if MSPM_TRACKPOS
      ridFlit.payload[which].pos = posNum[which];
#endif
#if MSPM_CHECKTAG && MSPM_RESOLVE_CONFLICT
      ridFlit.payload[which].tag = tagNum[which];
#endif
      hasHits |= (ridPlusOne[which] != 0);
    }

    if (hasHits || eop) {
      ridFlit.hasHits = hasHits;
      RidOutPipe.write(ridFlit);
    }
  }
}

/**
 * MSPM Stage 4
 *
 * Combine hit results from different width
 */
void mspmRecombineWidth(
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe0, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe1,
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe2, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe3,
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe4, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe5,
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe6, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe7,
    hls::stream<SmLookupAllResultMetaFlit> &RidMetaOutPipe);

/**
 * MSPM Stage 5
 *
 * Reduce output width by breaking up a lookup-width MetaFlit (MSPM_MASK_WIDTH*MSPM_LOOKUP_WIDTH, min 8) down to
 * multiple smaller (SM_RESULT_WIDTH) SmResultMetaFlit. All 0 SmResultMetaFlits are not forwarded.
 */
bool getEmptyStatus(SmRidMeta &flit);
void setEmptyStatus(SmRidMeta &flit, BOOL isEmpty);
void compactorShufflePayload(SmLookupAllResultMetaFlit &wideFlit, bool toggle);
const auto mspmResultDownshift = compactor<SmLookupAllResultMetaFlit, SmResultMetaFlit, SmRidMeta,
                                           MSPM_MASK_WIDTH * MSPM_LOOKUP_WIDTH, SM_RESULT_WIDTH>;

/**
 * MSPM Stage 6
 *
 * Expand overloaded RIDs (with MSPM_CONFLICT_BIT set) to individual RIDs by looking up in the collision table.
 */
void mspmExpandOverloadedRid(hls::stream<SmResultMetaFlit> &RidInPipe, hls::stream<SmResultMetaFlit> &RidOutPipe);
void mspmExpandOverloadedRidLite(hls::stream<SmResultMetaFlit> &RidInPipe, hls::stream<SmResultMetaFlit> &RidOutPipe);
