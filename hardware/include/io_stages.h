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
 * io_stages.h/cpp contains testbench plumbing to connect the streaming pipeline (constructed by declarations in
 * stages.h) on-ramp and off-ramp to external DRAM. main() running on the host prepares and consumes DRAM contents.
 */
#include <hls_stream.h>

#include <io_types.h>
#include <sm.h>

// Aligned read data struct; multiple words per flit; multiple flits per read.
struct PayloadWordPack {
  PAYLOAD_WORD word[MSPM_UNROLL];
  BOOL eop;
  BOOL switchPipe;
  FTAG ftag[MSPM_UNROLL];  // field tag for each word
  BOOL hasQuote;
};

// Kernel to read from memory, parse endlines to create packets and write to pipes to feed the streaming design
void payloadReadKernel(RawPayloadPack *testpattern_device_0, RawPayloadPack *testpattern_device_1,
                       hls::stream<PayloadWordPack> &PayloadOutPipe, hls::stream<PayloadWordPack> &PayloadOutSplitPipe,
                       UINT count, hls::stream<BOOL> &IoInCountPipe);

// Read kernel writes to two pipes to allow II=1 pipelining, this merge kernel merges the pipes and will produce the
// necessary stalling since the downstream kernels expect a single input stream.
void mergePipesKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadInSplitPipe,
                      hls::stream<PayloadWordPack> &PayloadOutPipe);

// Combine payload and mark streams into packet payload stream to feed MSPM injestion pipe
void payloadSourceKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<MspmPayloadFlit> &PayloadOutPipe);

// Parse JSON formatted input packets to tag the values with their corresponding field type
void fieldMatchKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe);

// One JSON entry might be larger than the maximum payload flit size, so this kernel progagtes the field tags across
// multiple flits
void fieldMatchFixOverflowKernel(hls::stream<PayloadWordPack> &PayloadInPipe,
                                 hls::stream<PayloadWordPack> &PayloadOutPipe);

// resultWriteKernel writes to DRAM trace buffer at a multiple of detection pipeline output width. 64/byte per cycle
// (costly) is optimal when bandwidth pressure demands it.
void resultWriteKernel(RidBcntPack *trace_device, BOOL skipWrite, UINT buffer_size,
                       hls::stream<RidBcntFlit> &IoBurstWritePipe);

// Format detection pipeline result for writing to DRAM
void resultSinkKernel(hls::stream<SmResultMetaFlit> &SmResultMetaPipe, hls::stream<RidBcntFlit> &IoBurstWritePipe,
                      hls::stream<BOOL> &IoDoneCountPipe, hls::stream<BOOL> &IoResultCountPipe);

// Done count kernel to detect end of processing
void doneCountKernel(hls::stream<BOOL> &IoInCountPipe, hls::stream<BOOL> &IoResultCountPipe,
                     hls::stream<BOOL> &IoDoneCountPipe);
