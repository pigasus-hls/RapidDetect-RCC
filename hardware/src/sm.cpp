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

#include <sm.h>

#include <utils/my_assert.h>
#include <utils/case_normalize.h>
#include <utils/compactor.h>

#include <ap_int.h>

void mspmHashCheckStage(hls::stream<MspmPayloadFlit> &PayloadInPipe, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe0,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe1, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe2,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe3, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe4,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe5, hls::stream<SmWideKeyMetaFlit> &HitsOutPipe6,
                        hls::stream<SmWideKeyMetaFlit> &HitsOutPipe7) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = HitsOutPipe0
#pragma HLS INTERFACE mode = axis port = HitsOutPipe1
#pragma HLS INTERFACE mode = axis port = HitsOutPipe2
#pragma HLS INTERFACE mode = axis port = HitsOutPipe3
#pragma HLS INTERFACE mode = axis port = HitsOutPipe4
#pragma HLS INTERFACE mode = axis port = HitsOutPipe5
#pragma HLS INTERFACE mode = axis port = HitsOutPipe6
#pragma HLS INTERFACE mode = axis port = HitsOutPipe7

  // State variables that carries over clock cycles
#if SM_SKIPREPEATS
  PAYLOAD_WORD maskIn = 0x00ffffffffffffff;  // Shift-or mask carried over.
#else
  PAYLOAD_WORD maskIn = MSPM_NOHISTORY_MASK;  // Shift-or mask carried over.
#endif
  PAYLOAD_WORD wordLast = 0xffffffffffffffff;  // Last 7 bytes as prefix to next scan
  [[maybe_unused]] USEQ sequence = 0;          // pkt sequence number
  USHORT wideWordOffset = 0;                   // position number within sequence

#if MSPM_FRWD_SUPER
  // Some states are needed when using forward-looking supercharacter, which requires you to have the first byte of next
  // word before starting on the current word.
  PAYLOAD_WORD words_1[MSPM_UNROLL];  // delay by 1
#if MSPM_CHECKFIELD
  FTAG ftags_1[MSPM_UNROLL];  // delay by 1
#endif
  BOOL valid_1 = false;     // delay by 1
  BOOL eop_1 = false;       // delay by 1
  BOOL sameflow_1 = false;  // delay by 1
#if SM_INPKT_SEQ
  USEQ inPktSeq_1 = 0;  // delay by 1
#endif
#endif

MAIN_LOOP:
  while (1) {
#pragma HLS PIPELINE II = 1
    PAYLOAD_WORD words[MSPM_UNROLL];  // primary input flit from pipe
#if MSPM_CHECKFIELD
    FTAG ftags[MSPM_UNROLL];  // primary input flit from pipe
#endif
    BOOL valid = false;     // is "current" flit valid
    BOOL eop = false;       // is "current" flit end-of-packet
    BOOL sameflow = false;  // if eop, is next packet same flow
#if SM_INPKT_SEQ
    USEQ inPktSeq = 0;  // packet carried sequence
#endif
    BOOL valid_0 = false;  // did pipe return valid flit

    MspmHashHit hits[MSPM_MASK_WIDTH][MSPM_MASK_WIDTH * MSPM_UNROLL];  // primary output

    {
      // Get word bundle from upstream pipe and prepare this cycle's input.
      // Forward-looking supercharacter really complicates things.

      MspmPayloadFlit wFlit_0;
      valid_0 = PayloadInPipe.read_nb(wFlit_0);

#if MSPM_FRWD_SUPER
      // To support forward-looking supercharacter, this logic waits for the first byte of the next flit before starting
      // on the current flit, unless the current flit is marked end-of-packet and switching flow.
      BOOL validTail_1 = valid_1 && eop_1 && !sameflow_1;

      // if forward-looking superchar, "current" is delayed-by-1 from the
      // pipe output
      if (valid_0) {
        valid = valid_1;
        valid_1 = true;
      } else if (validTail_1) {
        valid = true;
        valid_1 = false;
      }  // else valid_1 stays put waiting for superchar
#else
      // If past-looking superchar, upstream pipe input is immediately "current". This is much easier to work with, no?
      valid = valid_0;
#endif

#if MSPM_FRWD_SUPER
      if (valid_0 || validTail_1) {
        eop = eop_1;
        sameflow = sameflow_1;
#if SM_INPKT_SEQ
        inPktSeq = inPktSeq_1;
#endif
        eop_1 = wFlit_0.eop;
        sameflow_1 = wFlit_0.sameflow;
#if SM_INPKT_SEQ
        inPktSeq_1 = wFlit_0.seq;
#endif
      }
#else
      eop = wFlit_0.eop;
      sameflow = wFlit_0.sameflow;
#if SM_INPKT_SEQ
      inPktSeq = wFlit_0.seq;
#endif
#endif

    PREPARE_INPUT:
      for (UIDX i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
#if MSPM_FRWD_SUPER
        // if forward-looking superchar, "current" is delayed-by-1
        if (valid_0 || validTail_1) {
          words[i] = words_1[i];
          words_1[i] = normalize(wFlit_0.word[i]);
#if MSPM_CHECKFIELD
          ftags[i] = ftags_1[i];
          ftags_1[i] = wFlit_0.ftag[i];
#endif
        }
#else
        // if past-looking superchar, pipe output is immediately "current"
        words[i] = normalize(wFlit_0.word[i]);
        ftags[i] = wFlit_0.ftag[i];
#endif
      }
    }  // finish preparing this cycle's input

    {
      // This is the actual main action! Checking for possible hits
      PAYLOAD_WORD maskOut;
      mspmHashCheck(  // INPUTS
          words,      // current flitword
          maskIn,     // shiftor mask carried over from last check
          wordLast,   // last 8-bytes (only need 7) as prefix
#if MSPM_FRWD_SUPER
          words_1[0] & BYTEMASK,  // future byte is forward superchar
#endif
#if MSPM_CHECKFIELD
          ftags,
#endif
          // OUTPUTS
          maskOut,  // shiftor mask to carry into next check
          hits,     // potential patterns hits to lookup next

      // META info
#if SM_INPKT_SEQ
          inPktSeq,
#else
          sequence,  // optionally set a sequence number
#endif
          wideWordOffset  // optionally set a word position offset
      );

      if (valid) {
        // only advance shift-or scan state in a cycle with valid flit
        wordLast = words[MSPM_UNROLL - 1];
        if (eop) {
          sequence++;
          wideWordOffset = 0;
        } else {
          wideWordOffset++;
        }

        if (eop && !sameflow) {
#if SM_SKIPREPEATS
          maskIn = 0x00ffffffffffffff;
#else
          maskIn = MSPM_NOHISTORY_MASK;
#endif
          // first packet of new flow repeats last 7 bytes of its
          // previous packet
        } else {
          maskIn = maskOut;
        }
      }

      // Note: in Pigasus, first flit of each packet repeats the last 7 bytes from that flow. This allows for a
      // memory-less restart. Alternatively, instead of repeating, you could carryover the maskIn and wordLast from the
      // end of the previous flow to continue seamlessly.
    }

    {
      // send wide check results to next stage to be compacted
      SmWideKeyMetaFlit hitsFlit[MSPM_MASK_WIDTH];
      BOOL hasHits[MSPM_MASK_WIDTH] = {};

    PER_LENGTH:
      for (UIDX len = 0; len < MSPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      PER_POSITION:
        for (UIDX pos = 0; pos < MSPM_MASK_WIDTH * MSPM_UNROLL; pos++) {
#pragma HLS UNROLL
          hitsFlit[len].payload[pos] = hits[len][pos];
          hasHits[len] |= hits[len][pos].isHit;
        }
        hitsFlit[len].hasHits = hasHits[len];

        if (eop) {
          // mark end-of-packet and always sends.
          hasHits[len] = true;
          hitsFlit[len].eop = true;
        } else {
          hitsFlit[len].eop = false;
        }
      }

      // enqueue valid/non-empty flits to next stage
      if (valid) {
        // Removed check for timing optimization in Vivado for V80 (@200Gbps)
        // if (hasHits[0]) HitsOutPipe0.write(hitsFlit[0]);
        // if (hasHits[1]) HitsOutPipe1.write(hitsFlit[1]);
        // if (hasHits[2]) HitsOutPipe2.write(hitsFlit[2]);
        // if (hasHits[3]) HitsOutPipe3.write(hitsFlit[3]);
        // if (hasHits[4]) HitsOutPipe4.write(hitsFlit[4]);
        // if (hasHits[5]) HitsOutPipe5.write(hitsFlit[5]);
        // if (hasHits[6]) HitsOutPipe6.write(hitsFlit[6]);
        // if (hasHits[7]) HitsOutPipe7.write(hitsFlit[7]);
        HitsOutPipe0.write(hitsFlit[0]);
        HitsOutPipe1.write(hitsFlit[1]);
        HitsOutPipe2.write(hitsFlit[2]);
        HitsOutPipe3.write(hitsFlit[3]);
        HitsOutPipe4.write(hitsFlit[4]);
        HitsOutPipe5.write(hitsFlit[5]);
        HitsOutPipe6.write(hitsFlit[6]);
        HitsOutPipe7.write(hitsFlit[7]);
      }
    }
  }
}

bool getEmptyStatus(MspmHashHit &flit) { return !flit.isHit; }

void setEmptyStatus(MspmHashHit &flit, BOOL isEmpty) { flit.isHit = !isEmpty; }

void mspmRecombineWidth(
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe0, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe1,
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe2, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe3,
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe4, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe5,
    hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe6, hls::stream<SmLookupByLenResultMetaFlit> &RidMetaInPipe7,
    hls::stream<SmLookupAllResultMetaFlit> &RidMetaOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe0
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe1
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe2
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe3
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe4
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe5
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe6
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe7
#pragma HLS INTERFACE mode = axis port = RidMetaOutPipe

  BOOL eopWait[MSPM_MASK_WIDTH] = {false};
#pragma HLS ARRAY_PARTITION variable = eopWait dim = 1 type = complete

  while (1) {
#pragma HLS PIPELINE II = 1
    SmLookupAllResultMetaFlit outRidFlit;
    SmLookupByLenResultMetaFlit inRidFlitByLen[MSPM_MASK_WIDTH];
    BOOL valid[MSPM_MASK_WIDTH] = {false};
    BOOL hasHits = false;
    BOOL eopAll = true;

    // pipes that get to an eop marker first has to wait for all
    // other pipes. see later.
    if (!eopWait[0]) valid[0] = RidMetaInPipe0.read_nb(inRidFlitByLen[0]);
    if (!eopWait[1]) valid[1] = RidMetaInPipe1.read_nb(inRidFlitByLen[1]);
    if (!eopWait[2]) valid[2] = RidMetaInPipe2.read_nb(inRidFlitByLen[2]);
    if (!eopWait[3]) valid[3] = RidMetaInPipe3.read_nb(inRidFlitByLen[3]);
    if (!eopWait[4]) valid[4] = RidMetaInPipe4.read_nb(inRidFlitByLen[4]);
    if (!eopWait[5]) valid[5] = RidMetaInPipe5.read_nb(inRidFlitByLen[5]);
    if (!eopWait[6]) valid[6] = RidMetaInPipe6.read_nb(inRidFlitByLen[6]);
    if (!eopWait[7]) valid[7] = RidMetaInPipe7.read_nb(inRidFlitByLen[7]);

    for (UIDX len = 0; len < MSPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      for (UIDX which = 0; which < MSPM_LOOKUP_WIDTH; which++) {
#pragma HLS UNROLL
        if (valid[len]) {
          // register a flagged rule id;
          outRidFlit.payload[len * MSPM_LOOKUP_WIDTH + which] = inRidFlitByLen[len].payload[which];
          hasHits |= inRidFlitByLen[len].hasHits;
        } else {
          outRidFlit.payload[len * MSPM_LOOKUP_WIDTH + which].ridPlusOne = 0;
        }
      }
    }

    {
      // When one pipe hits an eop marker, wait for all other pipes to catch up to line up packet processing boundaries.

      for (UIDX len = 0; len < MSPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
        if (valid[len]) {
          if (inRidFlitByLen[len].eop) {
            eopWait[len] = true;
          }
        }
      }

      for (UIDX len = 0; len < MSPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
        eopAll &= eopWait[len];
      }

      if (eopAll) {
        for (UIDX len = 0; len < MSPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
          eopWait[len] = false;
        }
      }
    }

    if (eopAll || hasHits) {
      outRidFlit.eop = eopAll;
      outRidFlit.hasHits = hasHits;
      RidMetaOutPipe.write(outRidFlit);
    }
  }  // while(1)
}

bool getEmptyStatus(SmRidMeta &flit) { return (flit.ridPlusOne == 0); }

void setEmptyStatus(SmRidMeta &flit, BOOL isEmpty) {
  if (isEmpty) {
    flit.ridPlusOne = 0;
  }
}

void compactorShufflePayload(SmLookupAllResultMetaFlit &wideFlit, bool toggle) {
#if !SM_RESULT_TOGGLECOMPACT
  toggle = false;  // hardcode toggle to false if not toggling to save area
#endif

  SmLookupAllResultMetaFlit temp;
  UIDX RidMetaInNum = MSPM_LOOKUP_WIDTH * MSPM_MASK_WIDTH;
  for (UIDX which = 0; which < RidMetaInNum; which++) {
#pragma HLS UNROLL
    UIDX shuffle =
        toggle ? ((which >> 2) | ((which & 0x1) ? 0 : RidMetaInNum >> 1) | ((which & 0x2) ? 0 : RidMetaInNum >> 2))
               : ((which >> 2) | ((which & 0x1) ? RidMetaInNum >> 1 : 0) | ((which & 0x2) ? RidMetaInNum >> 2 : 0));
    temp.payload[shuffle] = wideFlit.payload[which];
  }

  // Copy back
  for (UIDX which = 0; which < RidMetaInNum; which++) {
#pragma HLS UNROLL
    wideFlit.payload[which] = temp.payload[which];
  }
}

// First stage in overload expansion forks flits into two paths: one for normal RIDs that can bypass the slow path, and
// the other for overloaded RIDs that needs to go through the slow path
void mspmExpandOverloadedRidFork(hls::stream<SmResultMetaFlit> &RidInPipe, hls::stream<SmResultExpBundle> &RidOutPipe,
                                 hls::stream<SmResultExpOvBundle> &RidToHelperPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
  BOOL pktHasORid = false;  // how many overloaded RIDs this pkt to expand in slow path

  while (1) {
#pragma HLS PIPELINE II = 1
    BOOL valid = false;
    SmResultMetaFlit inFlit;
    valid = RidInPipe.read_nb(inFlit);

    SmResultExpOvBundle ovBundle = {};  // flit with overloaded RIDs for slow path
    SmResultExpBundle outBundle = {};   // flit without overladed RIDs to byapass slow path
    UIDX ovFlitNumORid = 0;
    BOOL outBundleHasRid = false;

    ovBundle.flit = inFlit;   // note: eop copied here
    outBundle.flit = inFlit;  // note: eop copied here; outBundle.gotoSlow initialize to false

    // triage overloaded Rids out; this is entry by entry
    for (UIDX which = 0; which < SM_RESULT_WIDTH; which++) {
#pragma HLS UNROLL
      if (inFlit.payload[which].ridPlusOne & URID_CONFLICT_BIT) {
        pktHasORid |= valid;
        ovFlitNumORid++;
        outBundle.flit.payload[which].ridPlusOne = 0;  // cancel direct out
      } else {
        ovBundle.flit.payload[which].ridPlusOne = 0;  // cancel overflow check
      }
      if (inFlit.payload[which].ridPlusOne && !(inFlit.payload[which].ridPlusOne & URID_CONFLICT_BIT)) {
        outBundleHasRid |= true;
      }
#if MSPM_CHECKTAG && MSPM_RESOLVE_CONFLICT
      outBundle.flit.payload[which].tag = 0x0;  // hardcode 0; don't propgate
#endif
    }

    for (UIDX round = 0; round < SM_EXPAND_OVERLOADED_SHIFT; round++) {
#pragma HLS UNROLL
      BOOL hole = false;
      for (UIDX pos = 0; pos < (SM_RESULT_WIDTH - 1); pos++) {
#pragma HLS UNROLL
        hole |= (ovBundle.flit.payload[pos].ridPlusOne == 0);
        if (hole) {
          ovBundle.flit.payload[pos] = ovBundle.flit.payload[pos + 1];
        }
      }
      if (hole) {
        ovBundle.flit.payload[SM_RESULT_WIDTH - 1] = {};
      }
    }

    if (pktHasORid) {
      // if pktHasORid, slow path will send eop; safe to do always
      outBundle.flit.eop = false;
    }

    if (pktHasORid && inFlit.eop) {
      // join will wait for slow path to send expandsion and eop
      outBundle.gotoSlow = true;
    }

    if (valid) {
      if (outBundleHasRid || inFlit.eop) {
        // either eop or gotoSlow; must send
        RidOutPipe.write(outBundle);
      }

      if (ovFlitNumORid || (pktHasORid && inFlit.eop)) {
        ovBundle.numORid = ovFlitNumORid;
        RidToHelperPipe.write(ovBundle);
      }

      if (inFlit.eop) {
        // start a new round
        pktHasORid = false;
      }
    }
  }
}

// Merge the two paths back together after slow path expansion. Note that the order of flits from the two paths are not
// guaranteed, so this kernel needs to do some reordering and merging based on the eop and gotoSlow signals
void mspmExpandOverloadedRidJoin(hls::stream<SmResultExpBundle> &RidFromForkPipe,
                                 hls::stream<SmResultMetaFlit> &RidFromHelperPipe,
                                 hls::stream<SmResultMetaFlit> &RidOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
  BOOL onSlowpath = false;

  SmResultExpBundle inBundle_0;
  SmResultMetaFlit inBundle_1;
  BOOL valid_0 = false, valid_1 = false;

  while (1) {
#pragma HLS PIPELINE II = 1

    if (!valid_0) valid_0 = RidFromForkPipe.read_nb(inBundle_0);
    if (!valid_1) valid_1 = RidFromHelperPipe.read_nb(inBundle_1);

    SmResultMetaFlit outFlit = onSlowpath ? inBundle_1 : inBundle_0.flit;

    if ((valid_0 && !onSlowpath) || (valid_1 && onSlowpath)) {
      BOOL hasHits = false;
      for (UIDX which = 0; which < SM_RESULT_WIDTH; which++) {
#pragma HLS UNROLL
        hasHits |= outFlit.payload[which].ridPlusOne != 0;
      }
      if (hasHits || outFlit.eop) {
        outFlit.hasHits = hasHits;
        RidOutPipe.write(outFlit);
      }
    }

    if (!onSlowpath) {
      if (valid_0) onSlowpath = inBundle_0.gotoSlow;
      valid_0 = false;
    } else if (valid_1) {
      onSlowpath = !inBundle_1.eop;  // slow path will send eop when done with pkt
      valid_1 = false;
    }
  }
}

// Preprocesses to add metadata for overloaded RIDs to prepare for the actual expansion in the next kernel
// The number of iterations per flit is data dependent and this kernel precomputes the loop bound to make the scheduling
// of the next kernel easier.
void mspmExpandOverloadedRidHelperCount(hls::stream<SmResultExpOvBundle> &RidInPipe,
                                        hls::stream<SmResultExpOvCountBundle> &RidOutPipe) {
#pragma HLS PIPELINE II = 1 style = frp
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = RidInPipe
#pragma HLS INTERFACE mode = axis port = RidOutPipe

  // This kernel adds additional metadata to the flit to provide predetermined loopcount
  // when the actual overloaded rid expansion occurs in the next kernel
  SmResultExpOvBundle ovBundle;
  RidInPipe.read(ovBundle);

  SmResultExpOvCountBundle outBundle = {};
  outBundle.flit = ovBundle.flit;

  UIDX numORid = ovBundle.numORid;
  BOOL emptyEop = false;

  if (numORid == 0) {
    emptyEop = true;  // need to jam 1 path through the loopnest
    numORid = 1;
    MY_ASSERT(ovBundle.flit.eop);
  }

  outBundle.emptyEop = emptyEop;
  UIDX loopCount = 0;  // loop count for the next kernel
  for (UIDX which = 0; (which < SM_RESULT_WIDTH); which++) {
#pragma HLS UNROLL
    outBundle.howmany[which] = 0;
    if (numORid) {
      if (ovBundle.flit.payload[which].ridPlusOne || (emptyEop && (which == 0)) /* must go through once */
      ) {
        URID cidx = (ovBundle.flit.payload[which].ridPlusOne & (~URID_CONFLICT_BIT));
        UIDX offset;
        UIDX howmany;

        if (!emptyEop) {
          MY_ASSERT(ovBundle.flit.payload[which].ridPlusOne & URID_CONFLICT_BIT);
          MY_ASSERT(cidx < COLLISION_TABLE_SIZE);
          offset = collision_table_offset[cidx];
          howmany = collision_table_inc[cidx];
        } else {
          offset = 0;
          howmany = 1;
        }
        // Add ceil(howmany/SM_EXPAND_OVERLOADED_PACK) to loopCount
        loopCount += ((howmany + SM_EXPAND_OVERLOADED_PACK - 1) / SM_EXPAND_OVERLOADED_PACK);
        outBundle.howmany[which] = howmany;
        outBundle.offset[which] = offset;

        numORid--;
      }  // valid
      else {
        // Empty cycle to skip over empty entry
        loopCount++;
      }
    }
  }  // which position
  MY_ASSERT(numORid == 0);

  outBundle.loopCount = loopCount;
  RidOutPipe.write(outBundle);
}

// This kernel performs the actual expansion of the overloaded rid flit. It uses the metadata from the previous
// kernel to determine how many times to loop and how many rids to expand in each iteration
void mspmExpandOverloadedRidHelperWork(hls::stream<SmResultExpOvCountBundle> &RidInPipe,
                                       hls::stream<SmResultMetaFlit> &RidOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
  BOOL valid;
  ap_uint<10> loopCount = 0;

  uint8_t which = 0;
  ap_uint<10> k_ = 0;
  UIDX offset;
  ap_uint<10> howmany;

  SmResultExpOvCountBundle ovBundle;
  BOOL emptyEop;

#pragma HLS DISAGGREGATE variable = ovBundle
#pragma HLS ARRAY_PARTITION variable = ovBundle.howmany dim = 1 type = complete
#pragma HLS ARRAY_PARTITION variable = ovBundle.offset dim = 1 type = complete

  while (1) {
#if SM_EXPAND_OVERLOADED_SUBMODE == 1
#pragma HLS PIPELINE II = 1
#endif
    if ((loopCount == 0) || (SM_EXPAND_OVERLOADED_SUBMODE == 0)) {
      valid = false;

      valid = RidInPipe.read_nb(ovBundle);
      loopCount = valid ? ovBundle.loopCount : 0;

      // loopCount is optimized to be 10 bits int
      MY_ASSERT(loopCount <= ((1 << 10) - 1));

      emptyEop = ovBundle.emptyEop;

      which = 0;
      k_ = 0;
    }

    if (valid) {
      do {
#if SM_EXPAND_OVERLOADED_SUBMODE == 0
#pragma HLS PIPELINE II = 1
#endif
        offset = ovBundle.offset[which];
        howmany = ovBundle.howmany[which];

        SmResultMetaFlit outFlit = {};
        BOOL hasHits = false;
        for (UIDX i_ = 0; i_ < SM_EXPAND_OVERLOADED_PACK; i_++) {
#pragma HLS UNROLL
          UIDX idx = k_ * SM_EXPAND_OVERLOADED_PACK + i_;
          if ((idx < howmany) && (!emptyEop)) {
            URID rid = collision_table_ridlist[offset + idx];
            MY_ASSERT((offset + idx) < COLLISION_TABLE_NUMRULES);
            MY_ASSERT(rid < TABLE_NUM_RID);

            outFlit.payload[i_] = ovBundle.flit.payload[which];
#if MSPM_CHECKTAG && MSPM_RESOLVE_CONFLICT
            // check tag
            if (ovBundle.flit.payload[which].tag != collision_table_taglist[offset + idx]) {
              // cancel if tags don't match
              outFlit.payload[i_].ridPlusOne = 0;
            } else {
              outFlit.payload[i_].ridPlusOne = rid + 1;
              hasHits |= true;
            }
            outFlit.payload[i_].tag = 0x0;  // hardcode 0; don't propagate
#else
            // don't check tag
            outFlit.payload[i_].ridPlusOne = rid + 1;
            hasHits |= true;
#endif
          }
        }

        if (loopCount == 1) {
          // if ovFlit is eop, send eop with last expansion
          outFlit.eop = ovBundle.flit.eop;
        }
        if (outFlit.eop || hasHits) {
          RidOutPipe.write(outFlit);
        }
        k_++;

        if ((ap_uint<10>)(k_ * SM_EXPAND_OVERLOADED_PACK) >= howmany) {
          which = (which + 1) % SM_RESULT_WIDTH;
          k_ = 0;
        }

        loopCount--;
      } while ((loopCount > 0) && (SM_EXPAND_OVERLOADED_SUBMODE == 0));
    }
  }  // while(1)
}

void mspmExpandOverloadedRid(hls::stream<SmResultMetaFlit> &RidInPipe, hls::stream<SmResultMetaFlit> &RidOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = RidInPipe
#pragma HLS INTERFACE mode = axis port = RidOutPipe

  hls_thread_local hls::stream<SmResultExpOvBundle, EXPOV_PIPE_DEPTH> RidtoHelperPipe("RidtoHelperPipe");
  hls_thread_local hls::stream<SmResultExpBundle, EXPOV_PIPE_DEPTH> RidBypassPipe("RidBypassPipe");
  hls_thread_local hls::stream<SmResultExpOvCountBundle, EXPOV_PIPE_DEPTH> RidHelperCountPipe("RidHelperCountPipe");
  hls_thread_local hls::stream<SmResultMetaFlit, EXPOV_PIPE_DEPTH> RidfromHelperPipe("RidfromHelperPipe");

  hls_thread_local hls::task mspmExpandOverloadedRidForkTask(mspmExpandOverloadedRidFork, RidInPipe, RidBypassPipe,
                                                             RidtoHelperPipe);
  hls_thread_local hls::task mspmExpandOverloadedRidHelperCountTask(mspmExpandOverloadedRidHelperCount, RidtoHelperPipe,
                                                                    RidHelperCountPipe);
  hls_thread_local hls::task mspmExpandOverloadedRidHelperWorkTask(mspmExpandOverloadedRidHelperWork,
                                                                   RidHelperCountPipe, RidfromHelperPipe);
  hls_thread_local hls::task mspmExpandOverloadedRidJoinTask(mspmExpandOverloadedRidJoin, RidBypassPipe,
                                                             RidfromHelperPipe, RidOutPipe);
}

// A simpler version of overload expansion using a single stage which has a heavy penalty for switching in and out of
// the slow path, but saves the overhead of forking and joining and is easier to schedule. Useful when the number of
// overloaded RIDs to expand is small.
void mspmExpandOverloadedRidLite(hls::stream<SmResultMetaFlit> &RidInPipe, hls::stream<SmResultMetaFlit> &RidOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = RidInPipe
#pragma HLS INTERFACE mode = axis port = RidOutPipe

  // simpler but slower
  SmResultMetaFlit ovFlit;  // flit with overloaded RIDs for slow path
  UIDX numORid = 0;         // how many overloaded RIDs to expand in slow path

OUTER_LOOP:
  while (1) {
  // Fast Path
  FAST_PATH:
    do {
#pragma HLS PIPELINE II = 1
      SmResultMetaFlit inFlit = RidInPipe.read();
      SmResultMetaFlit outFlit;

      numORid = 0;  // numORid must be 0 at this point, but just in case
                    // compiler can't figure it out.

      outFlit = inFlit;  // note: eop copied here
      ovFlit = inFlit;   // note: eop copied here

      // copy input flit into output flit
      // triage overloaded Rids out; this is entry by entry
      for (UIDX which = 0; which < SM_RESULT_WIDTH; which++) {
#pragma HLS UNROLL
        if (inFlit.payload[which].ridPlusOne & URID_CONFLICT_BIT) {
          numORid += 1;
          outFlit.payload[which].ridPlusOne = 0;  // cancel direct out
        } else {
          ovFlit.payload[which].ridPlusOne = 0;  // cancel overflow check
        }
#if MSPM_CHECKTAG && MSPM_RESOLVE_CONFLICT
        outFlit.payload[which].tag = 0x0;  // hardcode 0; don't propgate
#endif
      }
      if (numORid != 0) {
        // if numORid!=0, slow path will send eop
        outFlit.eop = false;
      }
      // always push outFlit
      RidOutPipe.write(outFlit);
    } while (numORid == 0);

  // Slow Path: scan ovFlit for expansion
  SLOW_PATH:
    for (UIDX which = 0; which < SM_RESULT_WIDTH; which++) {
      if (ovFlit.payload[which].ridPlusOne) {
        URID cidx = (ovFlit.payload[which].ridPlusOne & (~URID_CONFLICT_BIT));
        MY_ASSERT(ovFlit.payload[which].ridPlusOne & URID_CONFLICT_BIT);
        MY_ASSERT(cidx < COLLISION_TABLE_SIZE);

        UIDX offset = collision_table_offset[cidx];
        UIDX howmany = collision_table_inc[cidx];

        for (UIDX k_ = 0; k_ < howmany; k_ += SM_EXPAND_OVERLOADED_PACK) {
          // sending one flit per expansion; kind of wasteful
          SmResultMetaFlit outFlit = {};
          BOOL hasHits = false;

          for (UIDX i_ = 0; i_ < SM_EXPAND_OVERLOADED_PACK; i_++) {
#pragma HLS UNROLL
            UIDX idx = k_ + i_;
            if (idx < howmany) {
              URID rid = collision_table_ridlist[offset + idx];
              MY_ASSERT((offset + idx) < COLLISION_TABLE_NUMRULES);
              MY_ASSERT(rid < TABLE_NUM_RID);

              outFlit.payload[i_] = ovFlit.payload[which];
#if MSPM_CHECKTAG && MSPM_RESOLVE_CONFLICT
              // check tag
              if (ovFlit.payload[which].tag != collision_table_taglist[offset + idx]) {
                // cancel if tags don't match
                outFlit.payload[i_].ridPlusOne = 0;
              } else {
                outFlit.payload[i_].ridPlusOne = rid + 1;
                hasHits |= true;
              }
              outFlit.payload[i_].tag = 0x0;  // hardcode 0; don't propagate
#else
              // don't check tag
              outFlit.payload[i_].ridPlusOne = rid + 1;
              hasHits |= true;
#endif
            }
          }

          if ((numORid == 1) && ((k_ + SM_EXPAND_OVERLOADED_PACK) > howmany)) {
            // if ovFlit is eop, send eop with last expansion
            outFlit.eop = ovFlit.eop;
          }
          if (outFlit.eop || hasHits) {
            outFlit.hasHits = hasHits;
            RidOutPipe.write(outFlit);
          }
        }
        numORid--;
      }
    }
    MY_ASSERT(numORid == 0);
  }
}
