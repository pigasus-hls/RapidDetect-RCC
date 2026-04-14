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

#include <nf.h>

#include <utils/types.h>
#include <utils/case_normalize.h>

#include <nfpm/nfpm.h>

void nfpmHashCheckStage(hls::stream<NfpmPayloadFlit> &PayloadInPipe, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe0,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe1, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe2,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe3, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe4,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe5, hls::stream<NfWideKeyMetaFlit> &HitsOutPipe6,
                        hls::stream<NfWideKeyMetaFlit> &HitsOutPipe7) {
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
#if NF_SKIPREPEATS
  PAYLOAD_WORD maskIn = 0x00ffffffffffffff;  // Shift-or mask carried over.
#else
  PAYLOAD_WORD maskIn = NFPM_NOHISTORY_MASK;  // Shift-or mask carried over.
#endif
  PAYLOAD_WORD wordLast = 0xffffffffffffffff;  // Last 7 bytes as prefix to next scan
  USHORT sequence = 0;                         // Dummy sequence number

#if NFPM_FRWD_SUPER
  // Some states are needed when using forward-looking supercharacter,
  // which requires you to have the first byte of next word before
  // starting on the current word.
  PAYLOAD_WORD words_1[NFPM_UNROLL];  // delay by 1
#if NFPM_CHECKFIELD
  FTAG ftags_1[NFPM_UNROLL];  // delay by 1
#endif
  BOOL valid_1 = false;     // delay by 1
  BOOL eop_1 = false;       // delay by 1
  BOOL sameflow_1 = false;  // delay by 1
#if NF_INPKT_SEQ
  USEQ inPktSeq_1 = 0;  // delay by 1
#endif
#endif

MAIN_LOOP:
  while (1) {
#pragma HLS PIPELINE II = 1
    PAYLOAD_WORD words[NFPM_UNROLL];  // primary input flit from pipe
#if NFPM_CHECKFIELD
    FTAG ftags[NFPM_UNROLL];  // primary input flit from pipe
#endif
    BOOL valid = false;     // is "current" flit valid
    BOOL eop = false;       // is "current" flit end-of-packet
    BOOL sameflow = false;  // if eop, is next packet same flow
#if NF_INPKT_SEQ
    USEQ inPktSeq = 0;  // packet carried sequence
#endif
    BOOL valid_0 = false;  // did pipe return valid flit

    NfpmHashHit hits[NFPM_MASK_WIDTH][NFPM_MASK_WIDTH * NFPM_UNROLL];  // primary output

    {
      // Get word bundle from upstream pipe and prepare this cycle's input.
      // Forward-looking supercharacter really complicates things.
      NfpmPayloadFlit wFlit_0;
      valid_0 = PayloadInPipe.read_nb(wFlit_0);

#if NFPM_FRWD_SUPER
      // To support forward-looking supercharacter, this logic waits for the first byte of the next flit before starting
      // on the current flit, unless the current flit is marked end-of-packet and switching flow.
      BOOL validTail_1 = valid_1 && eop_1 && !sameflow_1;

      // If forward-looking superchar, "current" is delayed-by-1 from the pipe output
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

#if NFPM_FRWD_SUPER
      if (valid_0 || validTail_1) {
        eop = eop_1;
        sameflow = sameflow_1;
#if NF_INPKT_SEQ
        inPktSeq = inPktSeq_1;
#endif
        eop_1 = wFlit_0.eop;
        sameflow_1 = wFlit_0.sameflow;
#if NF_INPKT_SEQ
        inPktSeq_1 = wFlit_0.seq;
#endif
      }
#else
      eop = wFlit_0.eop;
      sameflow = wFlit_0.sameflow;
#if NF_INPKT_SEQ
      inPktSeq = wFlit_0.seq;
#endif
#endif

    PREPARE_INPUT:
      for (UIDX i = 0; i < NFPM_UNROLL; i++) {
#pragma HLS UNROLL
#if NFPM_FRWD_SUPER
        // if forward-looking superchar, "current" is delayed-by-1
        if (valid_0 || validTail_1) {
          words[i] = words_1[i];
          words_1[i] = normalize(wFlit_0.word[i]);
#if NFPM_CHECKFIELD
          ftags[i] = ftags_1[i];
          ftags_1[i] = wFlit_0.ftag[i];
#endif
        }
#else
        // if past-looking superchar, pipe output is immediately "current"
        words[i] = normalize(wFlit_0.word[i]);
#if NFPM_CHECKFIELD
        ftags[i] = wFlit_0.ftag[i];
#endif
#endif
      }
    }  // finish preparing this cycle's input

    {
      // This is the actual main action! Checking for possible hits
      PAYLOAD_WORD maskOut;
      nfpmHashCheck(  // INPUTS
          words,      // current flitword
          maskIn,     // shiftor mask carried over from last check
          wordLast,   // last 8-bytes (only need 7) as prefix
#if NFPM_FRWD_SUPER
          words_1[0] & BYTEMASK,  // future byte is forward superchar
#endif
#if NFPM_CHECKFIELD
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
          0x0  // optionally set a word position offset
      );

      if (valid) {
        // only advance shift-or scan state in a cycle with valid flit
        wordLast = words[NFPM_UNROLL - 1];
        if (eop) {
          sequence++;
        }

        if (eop && !sameflow) {
#if NF_SKIPREPEATS
          maskIn = 0x00ffffffffffffff;
#else
          maskIn = NFPM_NOHISTORY_MASK;
#endif
          // first packet of new flow repeats last 7 bytes of its previous packet
        } else {
          maskIn = maskOut;
        }
      }

      // Note: in Pigasus, first flit of each packet repeats the last 7 bytes from that flow. This allows for a
      // memory-less restart. Alternatively, instead of repeating, you could carryover the maskIn and wordLast from the
      // end of the previous flow to continue seamlessly.
    }

    {
      // Send wide check results to next stage to be compacted
      NfWideKeyMetaFlit hitsFlit[NFPM_MASK_WIDTH];
      BOOL hasHits[NFPM_MASK_WIDTH] = {};

    PER_LENGTH:
      for (UIDX len = 0; len < NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      PER_POSITION:
        for (UIDX pos = 0; pos < NFPM_MASK_WIDTH * NFPM_UNROLL; pos++) {
#pragma HLS UNROLL
          hitsFlit[len].payload[pos] = hits[len][pos];
          hasHits[len] |= hits[len][pos].isHit;
        }

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
        if (hasHits[0]) HitsOutPipe0.write(hitsFlit[0]);
        if (hasHits[1]) HitsOutPipe1.write(hitsFlit[1]);
        if (hasHits[2]) HitsOutPipe2.write(hitsFlit[2]);
        if (hasHits[3]) HitsOutPipe3.write(hitsFlit[3]);
        if (hasHits[4]) HitsOutPipe4.write(hitsFlit[4]);
        if (hasHits[5]) HitsOutPipe5.write(hitsFlit[5]);
        if (hasHits[6]) HitsOutPipe6.write(hitsFlit[6]);
        if (hasHits[7]) HitsOutPipe7.write(hitsFlit[7]);
      }
    }
  }
}

void fpAccumulateStage(hls::stream<NfWideKeyMetaFlit> &HitsInPipe0, hls::stream<NfWideKeyMetaFlit> &HitsInPipe1,
                       hls::stream<NfWideKeyMetaFlit> &HitsInPipe2, hls::stream<NfWideKeyMetaFlit> &HitsInPipe3,
                       hls::stream<NfWideKeyMetaFlit> &HitsInPipe4, hls::stream<NfWideKeyMetaFlit> &HitsInPipe5,
                       hls::stream<NfWideKeyMetaFlit> &HitsInPipe6, hls::stream<NfWideKeyMetaFlit> &HitsInPipe7,
                       hls::stream<NfFingerprintFlit> &FprintOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = HitsInPipe0
#pragma HLS INTERFACE mode = axis port = HitsInPipe1
#pragma HLS INTERFACE mode = axis port = HitsInPipe2
#pragma HLS INTERFACE mode = axis port = HitsInPipe3
#pragma HLS INTERFACE mode = axis port = HitsInPipe4
#pragma HLS INTERFACE mode = axis port = HitsInPipe5
#pragma HLS INTERFACE mode = axis port = HitsInPipe6
#pragma HLS INTERFACE mode = axis port = HitsInPipe7
#pragma HLS INTERFACE mode = axis port = FprintOutPipe

  NfpmFingerprint fp[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH];
#if NFPM_CHECK_FPALT
  NfpmFingerprint fp_alt[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH];
#endif
  BOOL barrierWait[NFPM_MASK_WIDTH];

  for (UIDX i = 0; i < NFPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
    barrierWait[i] = false;
    for (UIDX j = 0; j < NFPM_LOOKUP_WIDTH; j++) {
#pragma HLS UNROLL
      fp[i][j] = 0;
#if NFPM_CHECK_FPALT
      fp_alt[i][j] = 0;
#endif
    }
  }

  while (1) {
#pragma HLS PIPELINE II = 1
    BOOL valid[NFPM_MASK_WIDTH] = {};
    NfWideKeyMetaFlit wideFlit[NFPM_MASK_WIDTH];
    NfpmHashHit hits[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH] = {};

    if (!barrierWait[0]) valid[0] = HitsInPipe0.read_nb(wideFlit[0]);
    if (!barrierWait[1]) valid[1] = HitsInPipe1.read_nb(wideFlit[1]);
    if (!barrierWait[2]) valid[2] = HitsInPipe2.read_nb(wideFlit[2]);
    if (!barrierWait[3]) valid[3] = HitsInPipe3.read_nb(wideFlit[3]);
    if (!barrierWait[4]) valid[4] = HitsInPipe4.read_nb(wideFlit[4]);
    if (!barrierWait[5]) valid[5] = HitsInPipe5.read_nb(wideFlit[5]);
    if (!barrierWait[6]) valid[6] = HitsInPipe6.read_nb(wideFlit[6]);
    if (!barrierWait[7]) valid[7] = HitsInPipe7.read_nb(wideFlit[7]);

    for (UIDX len = 0; len < NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      for (UIDX pos = 0; pos < NFPM_LOOKUP_WIDTH; pos++) {
#pragma HLS UNROLL
        if (valid[len]) {
          hits[len][pos] = wideFlit[len].payload[pos];
        }
      }
    }
#if NFPM_CHECK_FPALT
    nfpmAccumFP(hits, fp, fp_alt);
#else
    nfpmAccumFP(hits, fp);
#endif

    {
      // When one pipe hits an barrier marker, wait for all other pipes to catch up to line up packet processing
      // boundaries
      BOOL barrierAll = true;
      for (UIDX len = 0; len < NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
        if (valid[len]) {
          if (wideFlit[len].eop) {  // end of packet
            barrierWait[len] = true;
          }
        }
      }

      for (UIDX len = 0; len < NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
        barrierAll &= barrierWait[len];
      }
      if (barrierAll) {
        NfFingerprintFlit fpFlit;

        for (UIDX len = 0; len < NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
          barrierWait[len] = false;
        }

        for (UIDX i = 0; i < NFPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
          fpFlit.fp[i] = 0;
#if NFPM_CHECK_FPALT
          fpFlit.fp_alt[i] = 0;
#endif
          for (UIDX pos = 0; pos < NFPM_LOOKUP_WIDTH; pos++) {
#pragma HLS UNROLL
            fpFlit.fp[i] |= fp[i][pos];
            fp[i][pos] = 0;
#if NFPM_CHECK_FPALT
            fpFlit.fp_alt[i] |= fp_alt[i][pos];
            fp_alt[i][pos] = 0;
#endif
          }
        }
        FprintOutPipe.write(fpFlit);
      }
    }
  }
}

void fpMatchStage(hls::stream<NfFingerprintFlit> &FprintInPipe, hls::stream<NfInputMetaFlit> &RidInPipe,
                  hls::stream<NfInputMetaFlit> &RidOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = FprintInPipe
#pragma HLS INTERFACE mode = axis port = RidInPipe
#pragma HLS INTERFACE mode = axis port = RidOutPipe

  NfFingerprintFlit fpFlit;
  NfInputMetaFlit ridFlit;
  BOOL getNextFp = true;

  BOOL fpValid = false, ridValid = false;
  while (true) {
#pragma HLS PIPELINE II = 1
    BOOL fpMatched = false;

    if (getNextFp) {
      fpValid = FprintInPipe.read_nb(fpFlit);
      getNextFp = !fpValid;
    }

    if (!ridValid) ridValid = RidInPipe.read_nb(ridFlit);
    if (ridFlit.eop && ridValid && fpValid) {
      getNextFp = true;
    }

    NfInputMetaFlit flit;
    BOOL notEmpty = false;
    flit.eop = ridFlit.eop;
    {
      notEmpty = ridFlit.eop;

      for (UIDX which = 0; which < NF_METAIN_WIDTH; which++) {
#pragma HLS UNROLL
        // check whether rid is valid, no problem
        NFPM_FPhalf upper, lower;
        URID idxu = (ridFlit.payload[which].ridPlusOne - 1) & (NFPM_RULE_FP_DEPTH - 1);
        URID idxl = (ridFlit.payload[which].ridPlusOne - 1) & (NFPM_RULE_FP_DEPTH - 1);
#if NFPM_CHECK_FPDWIDE
        upper = NFPM_RULE_FP_DWIDEu[idxu];
        lower = NFPM_RULE_FP_DWIDEl[idxl];
#else
        upper = NFPM_RULE_FPu[idxu];
        lower = NFPM_RULE_FPl[idxl];
#endif
        NfpmFingerprint ruleFp[NFPM_MASK_WIDTH];

        nfpmSetFP(upper, lower, ruleFp);
        fpMatched = nfpmMatchFP(ruleFp, fpFlit.fp);

#if NFPM_CHECK_FPALT
        NFPM_FPhalf upper_alt, lower_alt;
        upper_alt = NFPM_RULE_FP_ALTu[idxu];
        lower_alt = NFPM_RULE_FP_ALTl[idxl];
        NfpmFingerprint ruleFp_alt[NFPM_MASK_WIDTH];

        nfpmSetFP(upper_alt, lower_alt, ruleFp_alt);
        BOOL fpMatched_alt = nfpmMatchFP(ruleFp_alt, fpFlit.fp_alt);
        fpMatched &= fpMatched_alt;
#endif

        if (fpMatched && (ridFlit.payload[which].ridPlusOne != 0)) {
          notEmpty = true;
        }

        flit.payload[which] = ridFlit.payload[which];
        if (!fpMatched) {
          flit.payload[which].ridPlusOne = 0;
        }
      }
    }

    if (notEmpty && fpValid && ridValid) RidOutPipe.write(flit);
    if (fpValid && ridValid) ridValid = false;
  }
}

bool getEmptyStatus(NfRidMeta &flit) { return (flit.ridPlusOne == 0); }

void setEmptyStatus(NfRidMeta &flit, BOOL isEmpty) {
  if (isEmpty) {
    flit.ridPlusOne = 0;
  }
}

void compactorShufflePayload(NfInputMetaFlit &wideFlit, bool toggle) {
#if !NF_RESULT_TOGGLECOMPACT
  toggle = false;  // hardcode toggle to false if not toggling to save area
#endif

  NfInputMetaFlit temp;
  UIDX RidMetaInNum = NF_METAIN_WIDTH;
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
