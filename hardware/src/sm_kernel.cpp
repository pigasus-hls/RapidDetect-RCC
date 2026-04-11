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

#include "sm_kernel.h"

void sm_kernel(hls::stream<MspmPayloadFlit> &PayloadInPipe, hls::stream<SmResultMetaFlit> &ResultOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = ResultOutPipe

  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe0("SmWideKeyMetaPipe0");
  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe1("SmWideKeyMetaPipe1");
  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe2("SmWideKeyMetaPipe2");
  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe3("SmWideKeyMetaPipe3");
  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe4("SmWideKeyMetaPipe4");
  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe5("SmWideKeyMetaPipe5");
  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe6("SmWideKeyMetaPipe6");
  hls_thread_local hls::stream<SmWideKeyMetaFlit, DFLT_PIPE_DEPTH> SmWideKeyMetaPipe7("SmWideKeyMetaPipe7");

  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe0("SmNarrowKeyMetaPipe0");
  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe1("SmNarrowKeyMetaPipe1");
  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe2("SmNarrowKeyMetaPipe2");
  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe3("SmNarrowKeyMetaPipe3");
  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe4("SmNarrowKeyMetaPipe4");
  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe5("SmNarrowKeyMetaPipe5");
  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe6("SmNarrowKeyMetaPipe6");
  hls_thread_local hls::stream<SmNarrowKeyMetaFlit, DFLT_PIPE_DEPTH> SmNarrowKeyMetaPipe7("SmNarrowKeyMetaPipe7");

  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe0(
      "SmLookupByLenResultMetaPipe0");
  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe1(
      "SmLookupByLenResultMetaPipe1");
  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe2(
      "SmLookupByLenResultMetaPipe2");
  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe3(
      "SmLookupByLenResultMetaPipe3");
  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe4(
      "SmLookupByLenResultMetaPipe4");
  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe5(
      "SmLookupByLenResultMetaPipe5");
  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe6(
      "SmLookupByLenResultMetaPipe6");
  hls_thread_local hls::stream<SmLookupByLenResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupByLenResultMetaPipe7(
      "SmLookupByLenResultMetaPipe7");

  hls_thread_local hls::stream<SmLookupAllResultMetaFlit, DFLT_PIPE_DEPTH> SmLookupAllResultMetaPipe(
      "SmLookupAllResultMetaPipe");

#if SM_EXPAND_OVERLOADED
  hls_thread_local hls::stream<SmResultMetaFlit, DFLT_PIPE_DEPTH> SmResultMetaPipe("SmResultMetaPipe");
#else
  using SmResultMetaPipe = ResultOutPipe;  // directly write to output if not expanding overloaded RIDs
#endif

  hls_thread_local hls::task mspm_hash_check_task(
      mspmHashCheckStage, PayloadInPipe, SmWideKeyMetaPipe0, SmWideKeyMetaPipe1, SmWideKeyMetaPipe2, SmWideKeyMetaPipe3,
      SmWideKeyMetaPipe4, SmWideKeyMetaPipe5, SmWideKeyMetaPipe6, SmWideKeyMetaPipe7);

  hls_thread_local hls::task mspm_compactor_task0(mspmCompactorStageByLen, SmWideKeyMetaPipe0, SmNarrowKeyMetaPipe0);
  hls_thread_local hls::task mspm_compactor_task1(mspmCompactorStageByLen, SmWideKeyMetaPipe1, SmNarrowKeyMetaPipe1);
  hls_thread_local hls::task mspm_compactor_task2(mspmCompactorStageByLen, SmWideKeyMetaPipe2, SmNarrowKeyMetaPipe2);
  hls_thread_local hls::task mspm_compactor_task3(mspmCompactorStageByLen, SmWideKeyMetaPipe3, SmNarrowKeyMetaPipe3);
  hls_thread_local hls::task mspm_compactor_task4(mspmCompactorStageByLen, SmWideKeyMetaPipe4, SmNarrowKeyMetaPipe4);
  hls_thread_local hls::task mspm_compactor_task5(mspmCompactorStageByLen, SmWideKeyMetaPipe5, SmNarrowKeyMetaPipe5);
  hls_thread_local hls::task mspm_compactor_task6(mspmCompactorStageByLen, SmWideKeyMetaPipe6, SmNarrowKeyMetaPipe6);
  hls_thread_local hls::task mspm_compactor_task7(mspmCompactorStageByLen, SmWideKeyMetaPipe7, SmNarrowKeyMetaPipe7);

  hls_thread_local hls::task mspm_lookup_task0(mspmHashLookupStageByLen<2>, SmNarrowKeyMetaPipe0,
                                               SmLookupByLenResultMetaPipe0);
  hls_thread_local hls::task mspm_lookup_task1(mspmHashLookupStageByLen<3>, SmNarrowKeyMetaPipe1,
                                               SmLookupByLenResultMetaPipe1);
  hls_thread_local hls::task mspm_lookup_task2(mspmHashLookupStageByLen<4>, SmNarrowKeyMetaPipe2,
                                               SmLookupByLenResultMetaPipe2);
  hls_thread_local hls::task mspm_lookup_task3(mspmHashLookupStageByLen<5>, SmNarrowKeyMetaPipe3,
                                               SmLookupByLenResultMetaPipe3);
  hls_thread_local hls::task mspm_lookup_task4(mspmHashLookupStageByLen<6>, SmNarrowKeyMetaPipe4,
                                               SmLookupByLenResultMetaPipe4);
  hls_thread_local hls::task mspm_lookup_task5(mspmHashLookupStageByLen<7>, SmNarrowKeyMetaPipe5,
                                               SmLookupByLenResultMetaPipe5);
  hls_thread_local hls::task mspm_lookup_task6(mspmHashLookupStageByLen<8>, SmNarrowKeyMetaPipe6,
                                               SmLookupByLenResultMetaPipe6);
  hls_thread_local hls::task mspm_lookup_task7(mspmHashLookupStageByLen<9>, SmNarrowKeyMetaPipe7,
                                               SmLookupByLenResultMetaPipe7);

  hls_thread_local hls::task mspm_recombine_task(
      mspmRecombineWidth, SmLookupByLenResultMetaPipe0, SmLookupByLenResultMetaPipe1, SmLookupByLenResultMetaPipe2,
      SmLookupByLenResultMetaPipe3, SmLookupByLenResultMetaPipe4, SmLookupByLenResultMetaPipe5,
      SmLookupByLenResultMetaPipe6, SmLookupByLenResultMetaPipe7, SmLookupAllResultMetaPipe);
  hls_thread_local hls::task mspm_result_downshift_task(mspmResultDownshift, SmLookupAllResultMetaPipe,
                                                        SmResultMetaPipe);

#if SM_EXPAND_OVERLOADED == 1
  hls_thread_local hls::task mspm_expand_overloaded_rid_lite_task(mspmExpandOverloadedRidLite, SmResultMetaPipe,
                                                                  ResultOutPipe);
#elif SM_EXPAND_OVERLOADED == 2
  hls_thread_local hls::task mspm_expand_overloaded_rid_task(mspmExpandOverloadedRid, SmResultMetaPipe, ResultOutPipe);
#endif
}
