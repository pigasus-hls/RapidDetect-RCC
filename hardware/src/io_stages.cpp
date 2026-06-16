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
#include <utils/stream_primitives.h>
#include <io_stages.h>
#include <test/testbench.h>

void payloadReadKernel(RawPayloadPack *testpattern_device_0, RawPayloadPack *testpattern_device_1,
                       hls::stream<PayloadWordPack> &PayloadOutPipe, hls::stream<PayloadWordPack> &PayloadOutSplitPipe,
                       UINT count, count_directio_t &PayloadCount) {
#pragma HLS INTERFACE mode = m_axi port = testpattern_device_0 bundle = gmem0 depth = 8192
#pragma HLS INTERFACE mode = m_axi port = testpattern_device_1 bundle = gmem1 depth = 8192

#pragma HLS INTERFACE mode = s_axilite port = count
#pragma HLS INTERFACE mode = s_axilite port = return
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutSplitPipe
#pragma HLS INTERFACE mode = s_axilite port = PayloadCount

  uint32_t payload_count_local = 0;
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
        wordsWithEop.hasQuote = false;
        if (words[midx].eop) {
          PayloadWordPack wordsAfterEop;
          wordsAfterEop.hasQuote = false;

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
            if (byte_idx <= eop_idx) {
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
          payload_count_local++;
        } else {
          // No EOP found, write the words directly to the pipe
          for (UINT i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
            wordsWithEop.word[i] = words[midx].word[i];
            wordsWithEop.eop = false;
            wordsWithEop.switchPipe = false;
          }
        }
        if (bidx == (count - 1)) wordsWithEop.hasQuote = true;
        PayloadOutPipe.write(wordsWithEop);  // write to main pipe

        PayloadCount.write(payload_count_local);
      }
    }
  }
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

void convertToEthernetKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<EthernetFlit> &EthernetOutPipe,
                             hls::ap_none<uint32_t> &ThrottleCount) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = EthernetOutPipe
#pragma HLS INTERFACE mode = s_axilite port = ThrottleCount

  uint8_t count = 0;

  uint32_t throttle_period = 0;
  uint16_t sent_count = 0, throttle_count_local = THROTTLE_PERIOD_LENGTH;

  BOOL valid = false;
  PayloadWordPack wPack;
  while (true) {
#pragma HLS PIPELINE II = 1
    throttle_period = (throttle_period + 1) % THROTTLE_PERIOD_LENGTH;

    if (!valid) valid = PayloadInPipe.read_nb(wPack);

    EthernetFlit flit;
    flit.set_keep(~((ap_uint<512 / 8>)0));
    flit.set_strb(~((ap_uint<512 / 8>)0));
    // flit.set_last(wPack.eop);
    flit.data = 0;
    for (int i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
      flit.data |= (((ap_uint<512>)wPack.word[i]) << (i * 64));
    }

    if (valid && (sent_count < throttle_count_local)) {
      uint8_t count_temp = (count + 1) % ETH_BURST_SIZE;
      flit.set_last((count_temp == 0) || wPack.hasQuote);
      // flit.set_last(wPack.eop);
      valid = EthernetOutPipe.write_nb(flit);
      if (valid) {
        sent_count++;
        count = count_temp;
      }

      valid = !valid;
    }

    if (throttle_period == 0) {
      sent_count = 0;
    }
    throttle_count_local = ThrottleCount.read();
  }
}

void convertFromEthernetKernel(hls::stream<EthernetFlit> &EthernetInPipe,
                               hls::stream<PayloadWordPack> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = EthernetInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe
#pragma HLS PIPELINE II = 1

  EthernetFlit flit = EthernetInPipe.read();
  PayloadWordPack wPack;

  wPack.eop = false;
  for (int i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
    wPack.word[i] = (flit.data >> (i * 64)) & 0xFFFFFFFFFFFFFFFFULL;
    for (int j = 0; j < 8; j++) {
#pragma HLS UNROLL
      if (!((flit.keep >> (i * 8 + j)) & 0x1)) {
        wPack.word[i] |= (0xFFUL << (j * 8));
      }

      // Search for newline to determine end of packet
      if (((wPack.word[i] >> (j * 8)) & 0xFF) == '\n') {
        wPack.word[i] |= (0xFFUL << (j * 8));  // set to FFs
        wPack.eop = true;
      }
    }
  }

  PayloadOutPipe.write(wPack);
}

void dropPacketKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe,
                      hls::stream<PayloadWordPack> &OverflowPipe, hls::stream<bool> &CreditPipe,
                      hls::ap_none<uint32_t> &DroppedCount, hls::ap_none<uint32_t> &TotalCount,
                      hls::ap_none<uint32_t> &InBusyCount, hls::ap_none<uint32_t> &OutBusyCount) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe
#pragma HLS INTERFACE mode = axis port = OverflowPipe
#pragma HLS INTERFACE mode = axis port = CreditPipe
#pragma HLS INTERFACE mode = s_axilite port = DroppedCount
#pragma HLS INTERFACE mode = s_axilite port = TotalCount
#pragma HLS INTERFACE mode = s_axilite port = InBusyCount
#pragma HLS INTERFACE mode = s_axilite port = OutBusyCount

  uint32_t dropped_count_local = 0;
  uint32_t total_count_local = 0;

  // Measure bandwidth by counting how many cycles we have valid input and output
  uint32_t busy_period = 0;
  uint32_t in_busy_count_local = 0;
  uint32_t out_busy_count_local = 0;

  bool drop = false, next_drop = false, new_packet = true;
  uint16_t credits, total_capacity = PayloadOutPipe.capacity();
  credits = total_capacity;

  while (true) {
#pragma HLS PIPELINE II = 1
    bool wrote = false, read = false;
    busy_period = (busy_period + 1) % BUSY_PERIOD_LENGTH;

    PayloadWordPack wPack;
    bool valid = false;

    wPack.eop = false;
    valid = PayloadInPipe.read_nb(wPack);

    if (valid) {
      in_busy_count_local++;
      // At the start of a new packet, check if we have enough credits to send it. If not, mark to drop the packet
      if (new_packet) {
        drop = next_drop;
      }

      // If not dropping, write to output pipe and decrement credits. If dropping, write to overflow pipe instead
      if (!drop) {
        PayloadOutPipe.write_nb(wPack);
        out_busy_count_local++;
        wrote = true;
      } else {
        // If overflow pipe is backpressured we can't do much (numbers will not match so we will be able to detect it)
        OverflowPipe.write_nb(wPack);
      }

      // If this flit is end of packet, update counts and reset for next packet
      if (wPack.eop) {
        total_count_local++;
        if (drop) dropped_count_local++;
        new_packet = true;
      } else {
        new_packet = false;
      }
    }
    next_drop = (credits < ETH_BURST_SIZE * 4);

    // Read credits from downstream to update available credits
    bool credit_read;
    read = CreditPipe.read_nb(credit_read);
    credits = credits - wrote + read;

    // Write dropped and total counts to AXI registers
    DroppedCount.write(dropped_count_local);
    TotalCount.write(total_count_local);

    if (busy_period == 0) {
      InBusyCount.write(in_busy_count_local);
      OutBusyCount.write(out_busy_count_local);
      in_busy_count_local = 0;
      out_busy_count_local = 0;
    }
  }
}

void passthroughKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe,
                       hls::stream<bool> &CreditPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe
#pragma HLS INTERFACE mode = axis port = CreditPipe

  while (true) {
#pragma HLS PIPELINE II = 1
    PayloadWordPack flit;
    bool valid = PayloadInPipe.read_nb(flit);

    if (valid) {
      PayloadOutPipe.write(flit);
      CreditPipe.write(true);  // send credit back immediately
    }
  }
}

void copyPayloadFlit(NfpmPayloadFlit &dest, PayloadWordPack &src, uint8_t offset) {
  for (UINT j = 0; j < NFPM_UNROLL; j++) {
#pragma HLS UNROLL
    dest.word[j] = src.word[j + offset];
  }
}

void fromEthernetKernel(hls::stream<EthernetFlit> &EthernetInPipe, hls::stream<PayloadWordPack> &EthernetOutPipe,
                        hls::stream<HostPayloadFlit> &OverflowPipe, hls::ap_none<uint32_t> &DroppedCount,
                        hls::ap_none<uint32_t> &TotalCount, hls::ap_none<uint32_t> &InBusyCount,
                        hls::ap_none<uint32_t> &OutBusyCount) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = EthernetInPipe
#pragma HLS INTERFACE mode = axis port = EthernetOutPipe
#pragma HLS INTERFACE mode = axis port = OverflowPipe
#pragma HLS INTERFACE mode = s_axilite port = DroppedCount
#pragma HLS INTERFACE mode = s_axilite port = TotalCount
#pragma HLS INTERFACE mode = s_axilite port = InBusyCount
#pragma HLS INTERFACE mode = s_axilite port = OutBusyCount

  hls_thread_local hls::stream<PayloadWordPack, DFLT_PIPE_DEPTH> intermediate_parsed("intermediate_parsed");
  hls_thread_local hls::stream<PayloadWordPack, 2048> intermediate_buffer("intermediate_buffer");
  hls_thread_local hls::stream<bool, DFLT_PIPE_DEPTH> credit_pipe("credit_pipe");
  hls_thread_local hls::stream<PayloadWordPack, 2048> intermediate_overflow_pipe("intermediate_overflow_pipe");

  hls_thread_local hls::task shim_task(convertFromEthernetKernel, EthernetInPipe, intermediate_parsed);
  hls_thread_local hls::task drop_task(dropPacketKernel, intermediate_parsed, intermediate_buffer,
                                       intermediate_overflow_pipe, credit_pipe, DroppedCount, TotalCount, InBusyCount,
                                       OutBusyCount);
  hls_thread_local hls::task passthrough_task(passthroughKernel, intermediate_buffer, EthernetOutPipe, credit_pipe);
  hls_thread_local hls::task payload_downshift_task(
      payloadDownshift<PayloadWordPack, MSPM_UNROLL, HostPayloadFlit, NFPM_UNROLL>, intermediate_overflow_pipe,
      OverflowPipe);
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
                      done_directio_t &Done, count_directio_t &ResultCount) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe
#pragma HLS INTERFACE mode = axis port = IoBurstWritePipe
#pragma HLS INTERFACE mode = s_axilite port = Done
#pragma HLS INTERFACE mode = s_axilite port = ResultCount

  UINT bcnt = 0;
  UCHAR round = 0;
  RidBcntFlit wideFlit = {};

  uint32_t result_count_local = 0;
  bool done_local = false, done_seen = false;

  while (1) {
#pragma HLS PIPELINE II = 1
    done_local = Done.read();
    done_seen = done_seen && done_local;

    URID ridPlusOne[HOST_RESULT_WIDTH] = {};
    BOOL valid = false;
    [[maybe_unused]] UINT now = bcnt;
    BOOL hasHits = false;

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
        result_count_local++;
        bcnt++;
      }
    }  // if (valid)

    if (valid) {
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
      wideFlit.terminate = done_local;  // signal end of test
      if ((round == (IO_WRITE_MULT - 1)) || done_local) {
        IoBurstWritePipe.write(wideFlit);
        wideFlit = {};
        round = 0;
      } else {
        round++;
        round %= IO_WRITE_MULT;
      }
    }  // if (hasHits)
    else if (done_local && !done_seen) {
      wideFlit.terminate = done_local;  // signal end of test
      IoBurstWritePipe.write(wideFlit);
      wideFlit = {};
      done_seen = true;
      round = 0;
    }

    ResultCount.write(result_count_local);
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

void payloadSinkKernel(hls::stream<HostPayloadFlit> &PayloadInPipe, hls::stream<HostPayloadFlit> &OverflowPipe,
                       hls::stream<PayloadWritePackFlit> &IoBurstPayloadWritePipe, count_directio_t &PayloadCount,
                       done_directio_t &Done) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = OverflowPipe
#pragma HLS INTERFACE mode = axis port = IoBurstPayloadWritePipe
#pragma HLS INTERFACE mode = s_axilite port = PayloadCount
#pragma HLS INTERFACE mode = s_axilite port = Done

  uint32_t payload_count_local = 0;

  uint8_t index = 0;
  PayloadWritePackFlit pack_flit;

  bool new_packet = true, which_pipe = false;
  bool done_local = false, done_seen = false;

  while (true) {
#pragma HLS PIPELINE II = 1
    BOOL flit_valid = false;

    // Read flit from pipe
    HostPayloadFlit flit;
    if (new_packet || !which_pipe) {
      flit_valid = PayloadInPipe.read_nb(flit);
      which_pipe = false;
    }
    if ((new_packet && !flit_valid) || which_pipe) {
      flit_valid = OverflowPipe.read_nb(flit);
      which_pipe = which_pipe ? which_pipe : flit_valid;
    }

    if (flit_valid) {
      new_packet = false;
      for (uint8_t j = 0; j < HOST_PAYLOAD_WIDTH; j++) {
#pragma HLS UNROLL
        pack_flit.pack.words[index * HOST_PAYLOAD_WIDTH + j] = flit.word[j];
      }
      if (flit.eop) {
        // Signal eop to count pipe
        new_packet = true;
        payload_count_local++;

        pack_flit.pack.words[PAYLOAD_WRITE_WIDTH - 1] =
            (pack_flit.pack.words[PAYLOAD_WRITE_WIDTH - 1] & (~(PAYLOAD_WORD)0xFF00000000000000)) | ((PAYLOAD_WORD)'\n'
                                                                                                     << 56);
      }
    }

    if ((flit_valid && (flit.eop || ((index + 1) * HOST_PAYLOAD_WIDTH == PAYLOAD_WRITE_WIDTH))) ||
        (done_local && !done_seen)) {
      index = 0;

      pack_flit.done = done_local;
      IoBurstPayloadWritePipe.write(pack_flit);

      for (uint8_t j = 0; j < PAYLOAD_WRITE_WIDTH; j++) {
#pragma HLS UNROLL
        pack_flit.pack.words[j] = (PAYLOAD_WORD)(0xFFFFFFFFFFFFFFFF);  // Reset word to all FFs
      }

      done_seen = done_local;
    } else if (flit_valid) {
      index++;
    }

    PayloadCount.write(payload_count_local);
    done_local = Done.read();
    done_seen = done_local ? done_seen : false;
  }
}

void payloadWriteKernel(PayloadWritePack *payload_sink_device, UINT count, BOOL skipWrite, UINT max_size,
                        hls::stream<PayloadWritePackFlit> &IoBurstPayloadWritePipe) {
#pragma HLS INTERFACE mode = m_axi port = payload_sink_device bundle = gmem0 depth = 8192
#pragma HLS INTERFACE mode = s_axilite port = count
#pragma HLS INTERFACE mode = s_axilite port = skipWrite
#pragma HLS INTERFACE mode = s_axilite port = max_size
#pragma HLS INTERFACE mode = s_axilite port = return
#pragma HLS INTERFACE mode = axis port = IoBurstPayloadWritePipe

  UINT num_words_written = 0;
  BOOL done = false, overflow = false;

  // Run the loop until count number of cycles or until done signal is received
  for (UINT i = 0; ((i < count) || skipWrite) && !done; i++) {
#pragma HLS PIPELINE II = 1
    PayloadWritePackFlit pack_flit;
    BOOL valid = IoBurstPayloadWritePipe.read_nb(pack_flit);
    done = done || (pack_flit.done && valid);

    // Write flit words to DRAM
    if (skipWrite) {
      // Don't need to do anything
    } else if (num_words_written >= max_size) {
      overflow = true;
    } else if (valid && !done) {
      payload_sink_device[num_words_written / PAYLOAD_WRITE_WIDTH + 1] = pack_flit.pack;
      num_words_written += PAYLOAD_WRITE_WIDTH;
    }
  }

  PayloadWritePack pack;
  for (uint8_t j = 0; j < PAYLOAD_WRITE_WIDTH; j++) {
#pragma HLS UNROLL
    pack.words[j] = (PAYLOAD_WORD)(0xFFFFFFFFFFFFFFFF);  // Reset word to all FFs
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
