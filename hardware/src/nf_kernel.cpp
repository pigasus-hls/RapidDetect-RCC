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

#include <nf_kernel.h>
#include <utils/pipes.h>

void nf_kernel(hls::stream<NfpmPayloadFlit> &PayloadInPipe, hls::stream<NfInputMetaFlit> &RidMetaInPipe,
               hls::stream<NfResultMetaFlit> &ResultOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe
#pragma HLS INTERFACE mode = axis port = ResultOutPipe

#if SM_ONLY

#if NF_RESULT_WIDTH != NF_METAIN_WIDTH
#error "SM_ONLY is only supported when NF_RESULT_WIDTH == NF_METAIN_WIDTH to avoid unnecessary downshifting logic"
#endif

  // Designed as pass through
  while (true) {
#pragma HLS PIPELINE II = 1
    NfpmPayloadFlit flit;
    PayloadInPipe.read_nb(flit);

    NfResultMetaFlit meta;
    BOOL valid = RidMetaInPipe.read_nb(meta);
    if (valid) ResultOutPipe.write(meta);
  }

#else
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe0("NfWideKeyMetaPipe0");
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe1("NfWideKeyMetaPipe1");
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe2("NfWideKeyMetaPipe2");
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe3("NfWideKeyMetaPipe3");
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe4("NfWideKeyMetaPipe4");
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe5("NfWideKeyMetaPipe5");
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe6("NfWideKeyMetaPipe6");
  hls_thread_local hls::stream<NfWideKeyMetaFlit, DFLT_PIPE_DEPTH> NfWideKeyMetaPipe7("NfWideKeyMetaPipe7");

  hls_thread_local hls::stream<NfFingerprintFlit, DFLT_PIPE_DEPTH> NfFprintMetaPipe("NfFprintMetaPipe");

#if NF_RESULT_WIDTH == NF_METAIN_WIDTH
  auto &NfResultMetaPipe = ResultOutPipe;
#else
  hls_thread_local hls::stream<NfInputMetaFlit, DFLT_PIPE_DEPTH> NfResultMetaPipe("NfResultMetaPipe");
#endif

  hls_thread_local hls::task nfpm_hash_check_task(
      nfpmHashCheckStage, PayloadInPipe, NfWideKeyMetaPipe0, NfWideKeyMetaPipe1, NfWideKeyMetaPipe2, NfWideKeyMetaPipe3,
      NfWideKeyMetaPipe4, NfWideKeyMetaPipe5, NfWideKeyMetaPipe6, NfWideKeyMetaPipe7);

  hls_thread_local hls::task fp_accumulate_task(
      fpAccumulateStage, NfWideKeyMetaPipe0, NfWideKeyMetaPipe1, NfWideKeyMetaPipe2, NfWideKeyMetaPipe3,
      NfWideKeyMetaPipe4, NfWideKeyMetaPipe5, NfWideKeyMetaPipe6, NfWideKeyMetaPipe7, NfFprintMetaPipe);

  hls_thread_local hls::task fp_match_task(fpMatchStage, NfFprintMetaPipe, RidMetaInPipe, NfResultMetaPipe);

#if NF_RESULT_WIDTH != NF_METAIN_WIDTH
  hls_thread_local hls::task nfpm_result_downshift_task(nfpmResultDownshift, NfResultMetaPipe, ResultOutPipe);
#endif
#endif
}
