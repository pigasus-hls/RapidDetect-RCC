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

void payloadSourceKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<MspmPayloadFlit> &PayloadOutPipe,
                         hls::stream<MspmPayloadFlit> &PayloadForwardPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe
#pragma HLS INTERFACE mode = axis port = PayloadForwardPipe

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
    if (valid) {
      PayloadOutPipe.write(flit);
      PayloadForwardPipe.write(flit);
    }
  }
}

// Format detection pipeline result for writing to DRAM
void resultSinkKernel(hls::stream<HostMetaFlit> &RidMetaInPipe, hls::stream<RidBcntFlit> &IoBurstWritePipe,
                      hls::stream<BOOL> &IoDoneCountPipe, hls::stream<BOOL> &IoResultCountPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe
#pragma HLS INTERFACE mode = axis port = IoBurstWritePipe
#pragma HLS INTERFACE mode = axis port = IoDoneCountPipe
#pragma HLS INTERFACE mode = axis port = IoResultCountPipe

  UINT bcnt = 0;
  UCHAR round = 0;
  RidBcntFlit wideFlit = {};
  BOOL done = false;

  while (1) {
#pragma HLS PIPELINE II = 1
    URID ridPlusOne[HOST_RESULT_WIDTH] = {};
    BOOL valid = false;
    [[maybe_unused]] UINT now = bcnt;
    BOOL hasHits = false;

    // Done signal is routed through this kernel to make sure it appears in the correct order in the output stream after
    // all results are processed
    valid = IoDoneCountPipe.read_nb(done);
    done = done && valid;
    valid = false;

    HostMetaFlit ridFlit;
    valid = RidMetaInPipe.read_nb(ridFlit);

    if (valid) {
      for (int which = 0; which < HOST_RESULT_WIDTH; which++) {
#pragma HLS UNROLL
        // register a flagged rule id;
        ridPlusOne[which] = ridFlit.payload[which].ridPlusOne;

        // hasHits check is performed in the flagger before the results reach this sink kernel
        // hasHits |= (ridPlusOne[which] != 0);
      }
      if (ridFlit.eop) {
        IoResultCountPipe.write(true);  // signal end of packet
        bcnt++;
      }
    }  // if (valid)

    if (valid) {
      {
        for (int which = 0; which < HOST_RESULT_WIDTH; which++) {
#pragma HLS UNROLL
          wideFlit.ridBcnt[round * HOST_RESULT_WIDTH + which].ridPlusOne = ridPlusOne[which];
#if MSPM_TRACKSEQ && NFPM_TRACKSEQ
          wideFlit.ridBcnt[round * HOST_RESULT_WIDTH + which].bcntSeq = ridFlit.payload[which].seq;
#else
          wideFlit.ridBcnt[round * HOST_RESULT_WIDTH + which].bcntSeq = now;
#endif
#if MSPM_TRACKPOS && NFPM_TRACKPOS
          wideFlit.ridBcnt[round * HOST_RESULT_WIDTH + which].pos = ridFlit.payload[which].pos;
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

void payloadWriteKernel(PayloadWritePack *payload_sink_device, UINT count, BOOL skipWrite, UINT max_size,
                        hls::stream<HostPayloadFlit> &PayloadInPipe, hls::stream<BOOL> &IoPayloadCountPipe,
                        hls::stream<BOOL> &IoPayloadDoneCountPipe) {
#pragma HLS INTERFACE mode = m_axi port = payload_sink_device bundle = gmem0 depth = 8192
#pragma HLS INTERFACE mode = s_axilite port = count
#pragma HLS INTERFACE mode = s_axilite port = skipWrite
#pragma HLS INTERFACE mode = s_axilite port = max_size
#pragma HLS INTERFACE mode = s_axilite port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = IoPayloadCountPipe
#pragma HLS INTERFACE mode = axis port = IoPayloadDoneCountPipe

  UINT num_words_written = 0;
  BOOL done = false, overflow = false;

  uint8_t index = 0;
  PayloadWritePack pack;

  // Run the loop until count number of cycles or until done signal is received
  for (UINT i = 0; ((i < count) || skipWrite) && !done; i++) {
#pragma HLS PIPELINE II = 1
    BOOL flit_valid = false, valid = false;

    // Read flit from pipe
    HostPayloadFlit flit;
    flit_valid = PayloadInPipe.read_nb(flit);
    if (flit_valid) {
      for (uint8_t j = 0; j < HOST_PAYLOAD_WIDTH; j++) {
#pragma HLS UNROLL
        pack.words[index * HOST_PAYLOAD_WIDTH + j] = flit.word[j];
      }
      if (flit.eop) {
        // Signal eop to count pipe
        IoPayloadCountPipe.write(true);
      }
    }

    // Is the pipeline done?
    valid = IoPayloadDoneCountPipe.read_nb(done);
    if (valid) done = true;

    if ((flit.eop || ((index + 1) * HOST_PAYLOAD_WIDTH == PAYLOAD_WRITE_WIDTH)) && flit_valid) {
      index = 0;
      for (uint8_t j = 0; j < PAYLOAD_WRITE_WIDTH; j++) {
#pragma HLS UNROLL
        if (flit.eop && (j == ((uint8_t)PAYLOAD_WRITE_WIDTH - 1))) {
          // If it's the last word and EOP is set MSB to newline
          pack.words[j] = (pack.words[j] & (~(PAYLOAD_WORD)0xFF00000000000000)) | ((PAYLOAD_WORD)'\n' << 56);
        }
      }

      // Write flit words to DRAM
      if (skipWrite || !flit_valid) {
        continue;  // Skip writing this flit
      } else if (num_words_written >= max_size) {
        overflow = true;
        continue;  // No more space to write
      }

      payload_sink_device[num_words_written / PAYLOAD_WRITE_WIDTH + 1] = pack;
      for (uint8_t j = 0; j < PAYLOAD_WRITE_WIDTH; j++) {
#pragma HLS UNROLL
        pack.words[j] = (PAYLOAD_WORD)(0xFFFFFFFFFFFFFFFF);  // Reset word to all FFs
      }
      num_words_written += PAYLOAD_WRITE_WIDTH;
    } else if (flit_valid) {
      index++;
    }
  }

  // Write the number of words written
  if (!skipWrite) {
    // Store the number of words written at the start of the buffer
    // Store the done status so that this kernel is not called again
    // Store the overflow status
    pack.words[0] = (((PAYLOAD_WORD)num_words_written) << 32) + (done ? 0b010 : 0) + (overflow ? 0b001 : 0);
  }
  payload_sink_device[0] = pack;
}

void doneCountKernel(hls::stream<BOOL> &IoInCountPipe, hls::stream<BOOL> &IoResultCountPipe,
                     hls::stream<BOOL> &IoPayloadCountPipe, hls::stream<MspmPayloadFlit> &SmPayloadSafePipe,
                     hls::stream<NfpmPayloadFlit> &NfpmPayloadSafePipe, hls::stream<BOOL> &IoDoneCountPipe,
                     hls::stream<BOOL> &IoPayloadDoneCountPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = IoInCountPipe
#pragma HLS INTERFACE mode = axis port = IoResultCountPipe
#pragma HLS INTERFACE mode = axis port = IoPayloadCountPipe
#pragma HLS INTERFACE mode = axis port = SmPayloadSafePipe
#pragma HLS INTERFACE mode = axis port = NfpmPayloadSafePipe
#pragma HLS INTERFACE mode = axis port = IoDoneCountPipe
#pragma HLS INTERFACE mode = axis port = IoPayloadDoneCountPipe

  UINT inCountCurrent = 0, inCountOld = 0, outCount = 0;
  UINT inPayloadCountCurrent = 0, inPayloadCountOld = 0, outPayloadCount = 0;

  BOOL doneCondition = false, extraOutput = false, payloadDoneCondition = false, payloadExtraOutput = false;
  BOOL inDone = false, inPayloadDone = false;
  BOOL inEop = false;

  BOOL inValid = false, inDoneValid = false, resultValid = false, payloadMatchValid = false, smPayloadSafeValid = false,
       nfPayloadSafeValid = false;
  while (1) {
#pragma HLS PIPELINE II = 1
    if (doneCondition) {
      IoDoneCountPipe.write(true);  // signal done
      inDone = false;               // reset inDone for the next input
      inCountOld = 0;
      // if there is an extra output after done condition, count it in the next round
      outCount = extraOutput ? 1 : 0;
    }

    if (payloadDoneCondition) {
      IoPayloadDoneCountPipe.write(true);  // signal payload done
      inPayloadDone = false;               // reset inPayloadDone for the next input
      inPayloadCountOld = 0;
      // if there is an extra output after payload done condition, count it in the next round
      outPayloadCount = payloadExtraOutput ? 1 : 0;
    }

    doneCondition = (inCountOld == outCount) && inDone;
    payloadDoneCondition = (inPayloadCountOld == outPayloadCount) && inPayloadDone;

    if (!inEop) {
      BOOL temp;
      inValid = IoInCountPipe.read_nb(temp);
      inEop = temp && inValid;
    }

    if (inEop) {
      if (!inDone && !inPayloadDone) {
        inEop = false;

        inDone = true;
        inCountOld = inCountCurrent;
        inCountCurrent = 0;

        inPayloadDone = true;
        inPayloadCountOld = inPayloadCountCurrent;
        inPayloadCountCurrent = 0;
      }
    } else if (inValid && !inEop) {
      inCountCurrent++;
      inPayloadCountCurrent++;
    }

    BOOL outEop;
    MspmPayloadFlit smSafeFlit;
    NfpmPayloadFlit nfSafeFlit;
    resultValid = IoResultCountPipe.read_nb(outEop);
    payloadMatchValid = IoPayloadCountPipe.read_nb(outEop);
    smPayloadSafeValid = SmPayloadSafePipe.read_nb(smSafeFlit);
    nfPayloadSafeValid = NfpmPayloadSafePipe.read_nb(nfSafeFlit);

    // only count payloads that have completed processing in the pipeline
    smPayloadSafeValid = smPayloadSafeValid && smSafeFlit.eop;
    nfPayloadSafeValid = nfPayloadSafeValid && nfSafeFlit.eop;

    outCount += resultValid + smPayloadSafeValid + nfPayloadSafeValid;
    outPayloadCount += payloadMatchValid + smPayloadSafeValid + nfPayloadSafeValid;

    extraOutput = resultValid + smPayloadSafeValid + nfPayloadSafeValid;
    payloadExtraOutput = payloadMatchValid + smPayloadSafeValid + nfPayloadSafeValid;

    // if (resultValid || smPayloadSafeValid || nfPayloadSafeValid || payloadMatchValid || inValid) {
    //   std::cout << "Current input count: " << inCountCurrent
    //             << ", Current payload input count: " << inPayloadCountCurrent << ", Current output count: " <<
    //             outCount
    //             << ", Current payload output count: " << outPayloadCount << std::endl;
    // }
  }
}
