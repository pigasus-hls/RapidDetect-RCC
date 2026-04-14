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

void testbench_kernel(RawPayloadPack* testpattern_device_0, RawPayloadPack* testpattern_device_1,
                      RidBcntPack* trace_device, PayloadWritePack* payload_sink_device, UINT count, BOOL skipWrite,
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
  hls_thread_local hls::stream<NfResultMetaFlit, DFLT_PIPE_DEPTH> HostMetaPipe("HostMetaPipe");
  hls_thread_local hls::stream<RidBcntFlit, DFLT_PIPE_DEPTH> IoBurstWritePipe("IoBurstWritePipe");

  hls_thread_local hls::stream<BOOL, DFLT_PIPE_DEPTH> IoInCountPipe("IoInCountPipe");
  hls_thread_local hls::stream<BOOL, DFLT_PIPE_DEPTH> IoResultCountPipe("IoResultCountPipe");
  hls_thread_local hls::stream<BOOL, DFLT_PIPE_DEPTH> IoPayloadCountPipe("IoPayloadCountPipe");
  hls_thread_local hls::stream<BOOL, DFLT_PIPE_DEPTH> IoDoneCountPipe("IoDoneCountPipe");
  hls_thread_local hls::stream<BOOL, DFLT_PIPE_DEPTH> IoPayloadDoneCountPipe("IoPayloadDoneCountPipe");

  payloadReadKernel(testpattern_device_0, testpattern_device_1, IoBurstReadPayloadPipe, IoReadPayloadSplitPipe, count,
                    IoInCountPipe);

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

  hls_thread_local hls::task done_count_task(doneCountKernel, IoInCountPipe, IoResultCountPipe, IoPayloadCountPipe,
                                             SmPayloadSafePipe, NfPayloadSafePipe, IoDoneCountPipe,
                                             IoPayloadDoneCountPipe);
  hls_thread_local hls::task sm_task(sm_kernel, SmInputPayloadPipe, SmResultMetaPipe);

  hls_thread_local hls::task sm2nf_task(sm2nfKernel, SmForwardPayloadPipe, SmResultMetaPipe, NfInputPayloadPipe,
                                        NfInputMetaPipe, SmPayloadSafePipe, NfForwardPayloadPipe);

  hls_thread_local hls::task nf_task(nf_kernel, NfInputPayloadPipe, NfInputMetaPipe, NfResultMetaPipe);

  hls_thread_local hls::task nf2host_task(nf2hostKernel, NfForwardPayloadPipe, NfResultMetaPipe, HostPayloadPipe,
                                          HostMetaPipe, NfPayloadSafePipe);

  hls_thread_local hls::task result_sink_task(resultSinkKernel, HostMetaPipe, IoBurstWritePipe, IoDoneCountPipe,
                                              IoResultCountPipe);

  payloadWriteKernel(payload_sink_device, -1, true, -1, HostPayloadPipe, IoPayloadCountPipe, IoPayloadDoneCountPipe);

  resultWriteKernel(trace_device, skipWrite, buffer_size, IoBurstWritePipe);
}
