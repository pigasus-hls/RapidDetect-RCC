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
#include <ap_axi_sdata.h>

#include <io_types.h>
#include <sm.h>
#include <nf.h>

using HostMetaFlit = NfResultMetaFlit;
using HostPayloadFlit = NfpmPayloadFlit;

using EthernetFlit = ap_axiu<512, 64, 0, 0>;

// Kernel to read from memory, parse endlines to create packets and write to pipes to feed the streaming design
void payloadReadKernel(RawPayloadPack *testpattern_device_0, RawPayloadPack *testpattern_device_1,
                       hls::stream<PayloadWordPack> &PayloadOutPipe, hls::stream<PayloadWordPack> &PayloadOutSplitPipe,
                       UINT count, count_directio_t &PayloadCount);

// Read kernel writes to two pipes to allow II=1 pipelining, this merge kernel merges the pipes and will produce the
// necessary stalling since the downstream kernels expect a single input stream.
void mergePipesKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadInSplitPipe,
                      hls::stream<PayloadWordPack> &PayloadOutPipe);

// Convert the payload stream to Ethernet flits and back to enable loopback
void convertToEthernetKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<EthernetFlit> &EthernetOutPipe);
void convertFromEthernetKernel(hls::stream<EthernetFlit> &EthernetInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe);
void fromEthernetKernel(hls::stream<EthernetFlit> &EthernetInPipe, hls::stream<PayloadWordPack> &EthernetOutPipe,
                        hls::stream<HostPayloadFlit> &OverflowPipe, hls::ap_none<uint32_t> &DroppedCount,
                        hls::ap_none<uint32_t> &TotalCount, hls::ap_none<uint32_t> &InBusyCount,
                        hls::ap_none<uint32_t> &OutBusyCount);

// Combine payload and mark streams into packet payload stream to feed MSPM injestion pipe
void payloadSourceKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<MspmPayloadFlit> &PayloadOutPipe,
                         hls::stream<MspmPayloadFlit> &PayloadForwardPipe);

// resultWriteKernel writes to DRAM trace buffer at a multiple of detection pipeline output width. 64/byte per cycle
// (costly) is optimal when bandwidth pressure demands it.
void resultWriteKernel(RidBcntPack *trace_device, BOOL skipWrite, UINT buffer_size,
                       hls::stream<RidBcntFlit> &IoBurstWritePipe);

// Format detection pipeline result for writing to DRAM
void resultSinkKernel(hls::stream<HostMetaFlit> &RidMetaInPipe, hls::stream<RidBcntFlit> &IoBurstWritePipe,
                      done_directio_t &Done, count_directio_t &ResultCount);

// Write payload output from the pipeline to DRAM to send to host
void payloadSinkKernel(hls::stream<HostPayloadFlit> &PayloadInPipe, hls::stream<HostPayloadFlit> &OverflowPipe,
                       hls::stream<PayloadWritePackFlit> &IoBurstPayloadWritePipe, count_directio_t &PayloadCount,
                       done_directio_t &Done);
void payloadWriteKernel(PayloadWritePack *payload_sink_device, UINT count, BOOL skipWrite, UINT max_size,
                        hls::stream<PayloadWritePackFlit> &IoBurstPayloadWritePipe);
