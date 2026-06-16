/******************************************************************************
MIT License

Copyright (c) 2024-2026 Shashank Obla, Carnegie Mellon University

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

#include <io_stages.h>
#include <rapidd_stages.h>
#include <sm_kernel.h>
#include <nf_kernel.h>
#include <test/testbench_kernel.h>
#include <hls_stream.h>
#include <hls_task.h>

#include <iostream>

#include <unistd.h>

void testbench_control(count_directio_t &sourcePayloadCount, count_directio_t &sinkPayloadCount,
                       count_directio_t &resultCount, done_directio_t &resultDone, done_directio_t &payloadDone,
                       count_directio_t &SmSafePayloadCount, count_directio_t &NfSafePayloadCount) {
  resultDone.write(false);
  payloadDone.write(false);

  uint32_t source_count = 0, sink_count = 0, result_count = 0, sm_safe_count = 0, nf_safe_count = 0;

  while (true) {
    usleep(1000);
    uint32_t new_source_count = sourcePayloadCount.read();
    uint32_t new_sink_count = sinkPayloadCount.read();
    uint32_t new_result_count = resultCount.read();
    uint32_t new_sm_safe_count = SmSafePayloadCount.read();
    uint32_t new_nf_safe_count = NfSafePayloadCount.read();

    if (new_source_count != source_count || new_sink_count != sink_count || new_result_count != result_count ||
        new_sm_safe_count != sm_safe_count || new_nf_safe_count != nf_safe_count) {
      source_count = new_source_count;
      sink_count = new_sink_count;
      result_count = new_result_count;
      sm_safe_count = new_sm_safe_count;
      nf_safe_count = new_nf_safe_count;
      // std::cout << "Source count: " << source_count << ", Sink count: " << sink_count
      //       << ", Result count: " << result_count << ", SM safe count: " << sm_safe_count
      //       << ", NF safe count: " << nf_safe_count << std::endl;
    }

    if (new_sm_safe_count + new_nf_safe_count + new_sink_count == new_source_count) {
      payloadDone.write(true);
    }

    if (new_sm_safe_count + new_nf_safe_count + new_result_count == new_source_count) {
      resultDone.write(true);
    }
  }
}

void testbench_kernel(RawPayloadPack *testpattern_device_0, RawPayloadPack *testpattern_device_1,
                      RidBcntPack *trace_device, PayloadWritePack *payload_sink_device, UINT count, BOOL skipWrite,
                      UINT buffer_size) {
#pragma HLS INTERFACE mode = m_axi depth = 8192 port = testpattern_device_0 bundle = gmem0
#pragma HLS INTERFACE mode = m_axi depth = 8192 port = testpattern_device_1 bundle = gmem1
#pragma HLS INTERFACE mode = m_axi depth = 8192 port = trace_device bundle = gmem3
#pragma HLS INTERFACE mode = m_axi depth = 8192 port = payload_sink_device bundle = gmem4
#pragma HLS INTERFACE mode = s_axilite port = count
#pragma HLS INTERFACE mode = s_axilite port = skipWrite
#pragma HLS INTERFACE mode = s_axilite port = buffer_size
#pragma HLS INTERFACE mode = s_axilite port = return
#pragma HLS DATAFLOW

  // Stream from payload source to sm
  hls_thread_local hls::stream<PayloadWordPack, DFLT_PIPE_DEPTH> IoBurstReadPayloadPipe("IoBurstReadPayloadPipe");
  hls_thread_local hls::stream<PayloadWordPack, DFLT_PIPE_DEPTH> IoReadPayloadSplitPipe("IoReadPayloadSplitPipe");
  hls_thread_local hls::stream<PayloadWordPack, DFLT_PIPE_DEPTH> IoReadPayloadMergedPipe("IoReadPayloadMergedPipe");
  hls_thread_local hls::stream<PayloadWordPack, DFLT_PIPE_DEPTH> IoReadPayloadFinalPipe("IoReadPayloadFinalPipe");

  hls_thread_local hls::stream<MspmPayloadFlit, DFLT_PIPE_DEPTH> SmInputPayloadPipe("SmInputPayloadPipe");
  hls_thread_local hls::stream<MspmPayloadFlit, DFLT_PIPE_DEPTH> SmForwardPayloadPipe("SmForwardPayloadPipe");
  hls_thread_local hls::stream<SmResultMetaFlit, DFLT_PIPE_DEPTH> SmResultMetaPipe("SmResultMetaPipe");
  hls_thread_local hls::stream<MspmPayloadFlit, DFLT_PIPE_DEPTH> SmPayloadSafePipe("SmPayloadSafePipe");

  hls_thread_local hls::stream<NfpmPayloadFlit, DFLT_PIPE_DEPTH> NfInputPayloadPipe("NfInputPayloadPipe");
  hls_thread_local hls::stream<NfpmPayloadFlit, DFLT_PIPE_DEPTH> NfForwardPayloadPipe("NfForwardPayloadPipe");
  hls_thread_local hls::stream<NfInputMetaFlit, DFLT_PIPE_DEPTH> NfInputMetaPipe("NfInputMetaPipe");
  hls_thread_local hls::stream<NfResultMetaFlit, DFLT_PIPE_DEPTH> NfResultMetaPipe("NfResultMetaPipe");
  hls_thread_local hls::stream<NfpmPayloadFlit, DFLT_PIPE_DEPTH> NfPayloadSafePipe("NfPayloadSafePipe");

  hls_thread_local hls::stream<NfpmPayloadFlit, DFLT_PIPE_DEPTH> HostPayloadPipe("HostPayloadPipe");
  hls_thread_local hls::stream<NfpmPayloadFlit, DFLT_PIPE_DEPTH> OverflowPipe("OverflowPipe");
  hls_thread_local hls::stream<NfResultMetaFlit, DFLT_PIPE_DEPTH> HostMetaPipe("HostMetaPipe");
  hls_thread_local hls::stream<RidBcntFlit, DFLT_PIPE_DEPTH> IoBurstWritePipe("IoBurstWritePipe");
  hls_thread_local hls::stream<PayloadWritePack, DFLT_PIPE_DEPTH> IoBurstPayloadWritePipe("IoBurstPayloadWritePipe");

  hls_thread_local count_directio_t sourcePayloadCount;
  hls_thread_local count_directio_t sinkPayloadCount;
  hls_thread_local count_directio_t resultCount;
  hls_thread_local done_directio_t resultDone;
  hls_thread_local done_directio_t payloadDone;
  hls_thread_local count_directio_t SmSafePayloadCount;
  hls_thread_local count_directio_t NfSafePayloadCount;

  hls_thread_local hls::task testbench_control_task(testbench_control, sourcePayloadCount, sinkPayloadCount,
                                                    resultCount, resultDone, payloadDone, SmSafePayloadCount,
                                                    NfSafePayloadCount);

  payloadReadKernel(testpattern_device_0, testpattern_device_1, IoBurstReadPayloadPipe, IoReadPayloadSplitPipe, count,
                    sourcePayloadCount);

  hls_thread_local hls::task payload_merge_task(mergePipesKernel, IoBurstReadPayloadPipe, IoReadPayloadSplitPipe,
                                                IoReadPayloadMergedPipe);

#if MSPM_CHECKFIELD
  hls_thread_local hls::task field_tagger_task(fieldTaggerKernel, IoReadPayloadMergedPipe, IoReadPayloadFinalPipe);
  hls_thread_local hls::task payload_source_task(payloadSourceKernel, IoReadPayloadFinalPipe, SmInputPayloadPipe,
                                                 SmForwardPayloadPipe);
#else
  hls_thread_local hls::task payload_source_task(payloadSourceKernel, IoReadPayloadMergedPipe, SmInputPayloadPipe,
                                                 SmForwardPayloadPipe);
#endif

  hls_thread_local hls::task sm_task(sm_kernel, SmInputPayloadPipe, SmResultMetaPipe);

  hls_thread_local hls::task sm2nf_task(sm2nfKernel, SmForwardPayloadPipe, SmResultMetaPipe, NfInputPayloadPipe,
                                        NfInputMetaPipe, SmPayloadSafePipe, NfForwardPayloadPipe, SmSafePayloadCount);

  hls_thread_local hls::task nf_task(nf_kernel, NfInputPayloadPipe, NfInputMetaPipe, NfResultMetaPipe);

  hls_thread_local hls::task nf2host_task(nf2hostKernel, NfForwardPayloadPipe, NfResultMetaPipe, HostPayloadPipe,
                                          HostMetaPipe, NfPayloadSafePipe, NfSafePayloadCount);

  hls_thread_local hls::task result_sink_task(resultSinkKernel, HostMetaPipe, IoBurstWritePipe, resultDone,
                                              resultCount);

  hls_thread_local hls::task payload_sink_task(payloadSinkKernel, HostPayloadPipe, OverflowPipe,
                                               IoBurstPayloadWritePipe, sinkPayloadCount, payloadDone);

  payloadWriteKernel(payload_sink_device, -1, true, -1, IoBurstPayloadWritePipe);
  resultWriteKernel(trace_device, skipWrite, buffer_size, IoBurstWritePipe);
}
