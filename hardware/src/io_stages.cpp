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

/*************************************************************************
 * io_stages.h/cpp contains testbench plumbing to connect the
 * streaming pipeline (constructed by declarations in stages.h)
 * on-ramp and off-ramp to external DRAM. main() running on the host
 * prepares and consumes DRAM contents.
 **************************************************************************/

#include <utils/types.h>
#include <io_stages.h>
#include <test/testbench.h>

void payloadReadKernel(RawPayloadPack *testpattern_device_0, RawPayloadPack *testpattern_device_1,
                       hls::stream<PayloadWordPack> &PayloadOutPipe, hls::stream<PayloadWordPack> &PayloadOutSplitPipe,
                       UINT count, hls::stream<BOOL> &IoInCountPipe) {
#pragma HLS INTERFACE mode = m_axi port = testpattern_device_0 bundle = gmem0 depth = 8192
#pragma HLS INTERFACE mode = m_axi port = testpattern_device_1 bundle = gmem1 depth = 8192

#pragma HLS INTERFACE mode = s_axilite port = count
#pragma HLS INTERFACE mode = s_axilite port = return
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutSplitPipe
#pragma HLS INTERFACE mode = axis port = IoInCountPipe

  // read payload from DRAM to pipe
  RawPayloadPack *testpattern_device[] = {testpattern_device_0, testpattern_device_1};

BURST_LOOP:
  for (UINT bidx = 0; bidx < count; bidx++) {
  // Iterate through words in burst
  WORD_LOOP:
    for (UINT widx = 0; widx < IO_READ_BURST; widx += IO_READ_MULT) {
#pragma HLS PIPELINE II = IO_READ_MULT
      PayloadWordPack words[IO_READ_MULT];
    READ_MULT_LOOP:
      for (UINT midx = 0; midx < IO_READ_MULT; midx++) {
#pragma HLS UNROLL
      UNROLL_LOOP:
        for (UINT i = 0; i < MSPM_UNROLL / IO_HBM_NUM_CHANNELS; i++) {
#pragma HLS UNROLL
          for (UINT ch = 0; ch < IO_HBM_NUM_CHANNELS; ch++) {
#pragma HLS UNROLL
            words[midx].word[MSPM_UNROLL / IO_HBM_NUM_CHANNELS * ch + i] = 0;  // set all to 0
          MASK_WIDTH_LOOP:
            for (UINT j = 0; j < MSPM_MASK_WIDTH; j++) {
#pragma HLS UNROLL
              words[midx].word[MSPM_UNROLL / IO_HBM_NUM_CHANNELS * ch + i] |=
                  ((PAYLOAD_WORD)testpattern_device[ch][bidx]
                       .data[((widx + midx) * MSPM_UNROLL / IO_HBM_NUM_CHANNELS + i) * MSPM_MASK_WIDTH + j])
                  << (j * 8);
            }
          }
        }
      }

    PROCESS_MULT_LOOP:
      for (UINT midx = 0; midx < IO_READ_MULT; midx++) {
        // Find eop
        words[midx].eop = false;
        uint8_t eop_idx;
      FIND_EOP_LOOP:
        for (UINT byte_idx = 0; byte_idx < MSPM_UNROLL * MSPM_MASK_WIDTH; byte_idx++) {
#pragma HLS UNROLL
          uint8_t byte = (words[midx].word[byte_idx / 8] >> ((byte_idx % 8) * 8)) & 0xFF;
          if ((unsigned char)byte == '\n') {
            words[midx].eop = true;
            eop_idx = byte_idx;
          }
        }

        // If EOP is found, split the words into two parts: before and after EOP
        PayloadWordPack wordsWithEop;
        if (words[midx].eop) {
          PayloadWordPack wordsAfterEop;

          wordsWithEop.eop = true;
          wordsAfterEop.eop = false;
          wordsWithEop.switchPipe = false;
          // Set all to 0
          for (UINT i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
            wordsWithEop.word[i] = 0;
            wordsAfterEop.word[i] = 0;
          }

          // Copy words before eop and mark rest as FFs
        BEFORE_EOP_LOOP:
          for (UINT byte_idx = 0; byte_idx < MSPM_UNROLL * MSPM_MASK_WIDTH; byte_idx++) {
#pragma HLS UNROLL
            if (byte_idx < eop_idx) {
              wordsWithEop.word[byte_idx / 8] |= (words[midx].word[byte_idx / 8] & (0xFFUL << (8 * (byte_idx % 8))));
            } else {
              wordsWithEop.word[byte_idx / 8] |= (0xFFUL << (8 * (byte_idx % 8)));
            }
          }

          // Copy words after eop and mark rest as FFs
        AFTER_EOP_LOOP:
          for (UINT byte_idx = 0; byte_idx < MSPM_UNROLL * MSPM_MASK_WIDTH; byte_idx++) {
#pragma HLS UNROLL
            if (byte_idx > eop_idx) {
              wordsAfterEop.word[byte_idx / 8] |= (words[midx].word[byte_idx / 8] & (0xFFUL << (8 * (byte_idx % 8))));
            } else {
              wordsAfterEop.word[byte_idx / 8] |= (0xFFUL << (8 * (byte_idx % 8)));
            }
          }

          // If there are bytes after EOP, write them to a separate pipe
          if (eop_idx != MSPM_UNROLL * MSPM_MASK_WIDTH - 1) {
            PayloadOutSplitPipe.write(wordsAfterEop);
            wordsWithEop.switchPipe = true;  // indicate that the other pipe has data
          }

          // Write to main pipe
          IoInCountPipe.write(false);  // signal end of packet
        } else {
          // No EOP found, write the words directly to the pipe
          for (UINT i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
            wordsWithEop.word[i] = words[midx].word[i];
            wordsWithEop.eop = false;
            wordsWithEop.switchPipe = false;
          }
        }
        PayloadOutPipe.write(wordsWithEop);  // write to main pipe
      }
    }
  }

  // signal end of all packets
  IoInCountPipe.write(true);  // signal end of all packets
}

void mergePipesKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadInSplitPipe,
                      hls::stream<PayloadWordPack> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadInSplitPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe

  BOOL wasSwitchPipe = false;
  PayloadWordPack wPack_0, wPack_1;
  BOOL valid_0 = false, valid_1 = false;

  while (1) {
#pragma HLS PIPELINE II = 1

    if (!valid_0) valid_0 = PayloadInPipe.read_nb(wPack_0);
    if (!valid_1) valid_1 = PayloadInSplitPipe.read_nb(wPack_1);

    PayloadWordPack wPack = wasSwitchPipe ? wPack_1 : wPack_0;

    if ((valid_0 && !wasSwitchPipe) || (valid_1 && wasSwitchPipe)) {
      PayloadOutPipe.write(wPack);
    }

    if (wasSwitchPipe) {
      if (valid_1) wasSwitchPipe = false;
      valid_1 = false;
    } else if (valid_0) {
      wasSwitchPipe = wPack.switchPipe;
      valid_0 = false;
    }
  }
}

#define MAX_FIELD_LENGTH 11
#define NUM_FIELDS 3

// Hardcoded helper function to match fields of interest and tag them.
// Can be edited to match different fields or use a different matching logic as needed.
FTAG matchField(const char *data) {
  // match syscall
  const char matchFields[NUM_FIELDS][MAX_FIELD_LENGTH + 1] = {"\"syscall\": ", "****\"exe\": ", "***\"path\": "};

  FTAG ftag = 0;  // Default to MISC
  for (int i = 0; i < NUM_FIELDS; i++) {
#pragma HLS UNROLL
    BOOL match = true;
    for (int j = 0; j < MAX_FIELD_LENGTH; j++) {
#pragma HLS UNROLL
      if ((data[j] != matchFields[i][j]) && (matchFields[i][j] != '*')) {
        match = false;
      }
    }
    ftag |= (match ? ((i + 1) & 3) : 0);
  }

  return ftag;
}

void fieldMatchKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe

  char matchData[MAX_FIELD_LENGTH + MSPM_UNROLL * MSPM_MASK_WIDTH] = {0};

  while (1) {
#pragma HLS PIPELINE II = 1
    PayloadWordPack wPack;
    BOOL valid = PayloadInPipe.read_nb(wPack);

    // Copy payload into matchData
    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      matchData[i + MAX_FIELD_LENGTH] = (wPack.word[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 8)) & 0xFF;
    }

    FTAG ftag[MSPM_UNROLL] = {0};  // field tag for each word
    BOOL hasQuote = false;         // flag to indicate if a quote is found

    // Mark all locations where the field matches
    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      ftag[i / MSPM_MASK_WIDTH] |= ((matchField(&matchData[i]) & 3) << ((i % MSPM_MASK_WIDTH) * 2));
    }

    // Propagate field matches until next quotation
    FTAG prevFtag = 0;
    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      FTAG currentFtag = (ftag[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 2)) & 3;

      // Always update; if prevFtag is 0, it will not change the current ftag, this is guaranteed to not overwrite
      // the current ftag since it will become 0 before it hits a match (quotes in the field will reset it)
      ftag[i / MSPM_MASK_WIDTH] |= ((prevFtag & 3) << ((i % MSPM_MASK_WIDTH) * 2));
      prevFtag = (ftag[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 2)) & 3;  // Replace with new ftag
      if ((currentFtag & 3) == 0 && matchData[i + MAX_FIELD_LENGTH] == '"') {
        prevFtag = 0;     // reset ftag on quote
        hasQuote = true;  // mark that we have a quote
      }
    }

    // Copy last bytes to front of matchData for next iteration
    for (int i = 0; i < MAX_FIELD_LENGTH; i++) {
#pragma HLS UNROLL
      if (wPack.eop & 1) {
        matchData[i] = 0xFF;
      } else if (valid) {
        matchData[i] = matchData[i + MSPM_UNROLL * MSPM_MASK_WIDTH];
      }
    }

    for (int i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
      wPack.ftag[i] = ftag[i];  // copy field tag
    }
    wPack.hasQuote = hasQuote;  // mark if there was a quote
    if (valid) PayloadOutPipe.write(wPack);
  }
}

// Fix overflowing field tagging which is not handled in the previous kernel
void fieldMatchFixOverflowKernel(hls::stream<PayloadWordPack> &PayloadInPipe,
                                 hls::stream<PayloadWordPack> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe

  FTAG overflowFtag = 0;

  while (1) {
#pragma HLS PIPELINE II = 1
    PayloadWordPack wPack;
    BOOL valid = PayloadInPipe.read_nb(wPack);  // Check if the read was valid

    FTAG currentFtag = (wPack.ftag[MSPM_UNROLL - 1] >> ((MSPM_MASK_WIDTH - 1) * 2)) & 3;  // Get last ftag bit
    // Note: if the last byte is an end quote the overflow ftag should be 0 but it could also be a starting quote
    // which would require more checks. Without checking we will only tag commas and spaces until the next field
    // anyways so the extra taggings should be innocuous and I leave it as it is for now.

    FTAG overflowFtagCopy = overflowFtag;  // Copy overflow ftag to use in the loop

    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      // FTAG thisFtag = wPack.ftag[i / MSPM_MASK_WIDTH] >> (i % MSPM_MASK_WIDTH) & 1;
      // Shouldn't need this additional check since a quote would've reset it well before and at the beginning of
      // the flit if it's matched, the overflowFtag will be 0 since the field would have preceded this flit
      // if (overflowFtagCopy && !thisFtag) wPack.ftag[i / MSPM_MASK_WIDTH] |= (overflowFtagCopy << (i %
      // MSPM_MASK_WIDTH)); If there is an overflowing non misc ftag and this ftag is misc, overwrite

      if (overflowFtagCopy) {
        wPack.ftag[i / MSPM_MASK_WIDTH] |= ((overflowFtagCopy & 3) << ((i % MSPM_MASK_WIDTH) * 2));
      }
      if ((wPack.word[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 8) & 0xFF) == '"') {
        overflowFtagCopy = 0;  // reset overflow tag on quote
      }
    }

    if (valid) PayloadOutPipe.write(wPack);

    // If current flit has a quote, reset overflowFtag with current ftag else keep it from previous flit
    // This is the feedback path which needs to be able to run every cycle
    if (wPack.eop) {
      overflowFtag = 0;  // reset on end of packet
    } else if (valid) {
      overflowFtag = ((wPack.hasQuote || ((currentFtag & 3) != 0)) ? currentFtag : overflowFtag) & 3;
    }
  }
}

void payloadSourceKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<MspmPayloadFlit> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe

  // Source Stage: inject flits to SM pipeline
  USEQ seq = 0;

  while (1) {
#pragma HLS PIPELINE II = 1
    PayloadWordPack wPack;
    BOOL valid = PayloadInPipe.read_nb(wPack);

    MspmPayloadFlit flit;
    for (int i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
      flit.word[i] = wPack.word[i];
#if MSPM_CHECKFIELD
      flit.ftag[i] = wPack.ftag[i];
#endif
    }

    flit.sameflow = TEST_SAMEFLOW;  // only sampled at EOP
    flit.eop = wPack.eop;           // end of packet mark
#if SM_INPKT_SEQ
    flit.seq = seq;
#endif
    if (flit.eop && valid) {
      seq++;
    }

    // push a word flit to stage 1
    if (valid) PayloadOutPipe.write(flit);
    // SmForwardPayloadPipe::write(flit);
    // ProfileSmCountPipe::write(flit.eop);
  }
}

// Format detection pipeline result for writing to DRAM
void resultSinkKernel(hls::stream<SmResultMetaFlit> &SmResultMetaPipe, hls::stream<RidBcntFlit> &IoBurstWritePipe,
                      hls::stream<BOOL> &IoDoneCountPipe, hls::stream<BOOL> &IoResultCountPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = SmResultMetaPipe
#pragma HLS INTERFACE mode = axis port = IoBurstWritePipe
#pragma HLS INTERFACE mode = axis port = IoDoneCountPipe
#pragma HLS INTERFACE mode = axis port = IoResultCountPipe

  UINT bcnt = 0;
  UCHAR round = 0;
  RidBcntFlit wideFlit = {};
  BOOL done = false;

  while (1) {
#pragma HLS PIPELINE II = 1
    URID ridPlusOne[IO_RESULT_WIDTH] = {};
    BOOL valid = false;
    [[maybe_unused]] UINT now = bcnt;
    BOOL hasHits = false;

    // Done signal is routed through this kernel to make sure it appears in the correct order in the output stream after
    // all results are processed
    valid = IoDoneCountPipe.read_nb(done);
    done = done && valid;
    valid = false;

    SmResultMetaFlit ridFlit;
    valid = SmResultMetaPipe.read_nb(ridFlit);

    if (valid) {
      for (int which = 0; which < IO_RESULT_WIDTH; which++) {
#pragma HLS UNROLL
        // register a flagged rule id;
        ridPlusOne[which] = ridFlit.payload[which].ridPlusOne;
        hasHits |= (ridPlusOne[which] != 0);
      }
      if (ridFlit.eop) {
        IoResultCountPipe.write(true);  // signal end of packet
        bcnt++;
      }
    }  // if (valid)

    if (hasHits) {
      {
        for (int which = 0; which < IO_RESULT_WIDTH; which++) {
#pragma HLS UNROLL
          wideFlit.ridBcnt[round * IO_RESULT_WIDTH + which].ridPlusOne = ridPlusOne[which];
#if MSPM_TRACKSEQ
          wideFlit.ridBcnt[round * IO_RESULT_WIDTH + which].bcntSeq = ridFlit.payload[which].seq;
#else
          wideFlit.ridBcnt[round * IO_RESULT_WIDTH + which].bcntSeq = now;
#endif
#if MSPM_TRACKPOS
          wideFlit.ridBcnt[round * IO_RESULT_WIDTH + which].pos = ridFlit.payload[which].pos;
#endif
#if MSPM_CHECKTAG && MSPM_RESOLVE_CONFLICT && !SM_EXPAND_OVERLOADED
          wideFlit.ridBcnt[round * IO_RESULT_WIDTH + which].tag = ridFlit.payload[which].tag;
#endif
        }
        wideFlit.terminate = done;  // signal end of test
        if ((round == (IO_WRITE_MULT - 1)) || done) {
          IoBurstWritePipe.write(wideFlit);
          wideFlit = {};
          done = false;
          round = 0;
        } else {
          round++;
          round %= IO_WRITE_MULT;
        }
      }
    }  // if (hasHits)
    else if (done) {
      wideFlit.terminate = done;  // signal end of test
      IoBurstWritePipe.write(wideFlit);
      wideFlit = {};
      done = false;
      round = 0;
    }
  }  // while (1)
}

// Write wide result from pipe to DRAM
void resultWriteKernel(RidBcntPack *trace_device, BOOL skipWrite, UINT buffer_size,
                       hls::stream<RidBcntFlit> &IoBurstWritePipe) {
#pragma HLS INTERFACE mode = m_axi port = trace_device bundle = gmem0 depth = 8192
#pragma HLS INTERFACE mode = s_axilite port = skipWrite
#pragma HLS INTERFACE mode = s_axilite port = buffer_size
#pragma HLS INTERFACE mode = s_axilite port = return
#pragma HLS INTERFACE mode = axis port = IoBurstWritePipe

  UINT traceIdx = 0, numWritten = 0, traceIdxShift[4] = {0, 0, 0, 0};
  BOOL done = false, doneShift[2] = {false, false};

#pragma HLS ARRAY_PARTITION variable = traceIdxShift complete

  while (traceIdxShift[0] < (buffer_size / IO_WRITE_WIDTH - 8) && !doneShift[0]) {
#pragma HLS PIPELINE II = 1
    doneShift[0] = doneShift[1];
    for (int i = 0; i < 3; i++) {
#pragma HLS UNROLL
      traceIdxShift[i] = traceIdxShift[i + 1];
    }
    traceIdxShift[3] = traceIdx;
    doneShift[1] = done;

    RidBcntPack rbPack;
    RidBcntFlit flit;
    BOOL valid = false;
    if (!done) {
      valid = IoBurstWritePipe.read_nb(flit);
      done = flit.terminate && valid;
    }

    if (!skipWrite && valid) {
      for (UINT which = 0; which < IO_WRITE_WIDTH; which++) {
#pragma HLS UNROLL
        rbPack.ridBcnt[which] = flit.ridBcnt[which];
      }
      trace_device[traceIdx + 1] = rbPack;
      numWritten += IO_WRITE_WIDTH;
      traceIdx++;
    }
  }

  trace_device[0].ridBcnt[0].bcntSeq = numWritten;       // store number of words written in first word
  trace_device[0].ridBcnt[0].ridPlusOne = done ? 0 : 1;  // store done status in first word
}  // sink kernel

void doneCountKernel(hls::stream<BOOL> &IoInCountPipe, hls::stream<BOOL> &IoResultCountPipe,
                     hls::stream<BOOL> &IoDoneCountPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = IoInCountPipe
#pragma HLS INTERFACE mode = axis port = IoResultCountPipe
#pragma HLS INTERFACE mode = axis port = IoDoneCountPipe

  UINT inCountCurrent = 0, inCountOld = 0, outCount = 0;
  BOOL doneCondition = false, extraOutput = false;
  BOOL inDone = false;
  BOOL inEop = false;

  BOOL inValid = false, inDoneValid = false, resultValid = false;
  while (1) {
#pragma HLS PIPELINE II = 1
    if (doneCondition) {
      IoDoneCountPipe.write(true);  // signal done
      inDone = false;               // reset inDone for the next input
      inCountOld = 0;
      outCount = extraOutput ? 1 : 0;  // if there is an extra output after done condition, count it in the next round
    }
    doneCondition = (inCountOld == outCount) && inDone;

    if (!inEop) {
      BOOL temp;
      inValid = IoInCountPipe.read_nb(temp);
      inEop = temp && inValid;
    }

    if (inEop) {
      if (!inDone) {
        inEop = false;

        inDone = true;
        inCountOld = inCountCurrent;
        inCountCurrent = 0;
      }
    } else if (inValid && !inEop) {
      inCountCurrent++;
    }

    [[maybe_unused]] BOOL outEop;
    resultValid = IoResultCountPipe.read_nb(outEop);
    if (resultValid) {
      outCount++;
    }
    extraOutput = resultValid;
  }
}
