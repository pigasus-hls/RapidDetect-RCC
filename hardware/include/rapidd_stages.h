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

#pragma once

/**
 * Field Tagging and Plumbing Stages for RapidDetect
 */
#include <hls_stream.h>
#include <io_types.h>
#include <sm.h>
#include <nf.h>

///////////////////////////////////////////////////////////////////////////////
// Ensure compatibility
///////////////////////////////////////////////////////////////////////////////

#if NFPM_TRACKPOS && !MSPM_TRACKPOS
#error NFPM_TRACKPOS cannot be on if MSPM_TRACKPOS is off
#endif

#if NFPM_TRACKSEQ && !MSPM_TRACKSEQ
#error NFPM_TRACKSEQ cannot be on if MSPM_TRACKSEQ is off
#endif

#if NFPM_CHECKFIELD && !MSPM_CHECKFIELD
#error NFPM_CHECKFIELD cannot be on if MSPM_CHECKFIELD is off
#endif

#if NF_INPKT_SEQ && !SM_INPKT_SEQ
#error NF_INPKT_SEQ cannot be on SM_INPKT_SEQ is off
#endif

#if NF_METAIN_WIDTH != SM_RESULT_WIDTH
#error NF_METAIN_WIDTH must be the same as SM_RESULT_WIDTH
#endif

#if NFPM_UNROLL > MSPM_UNROLL
#error NFPM_UNROLL cannot be greater than MSPM_UNROLL
#endif

#if SM_ONLY
#if NFPM_TRACKPOS != MSPM_TRACKPOS
#warning NFPM_TRACKPOS should be the same as MSPM_TRACKPOS when SM_ONLY is set for consistent tracking and debugging
#endif

#if NFPM_TRACKSEQ != MSPM_TRACKSEQ
#warning NFPM_TRACKSEQ should be the same as MSPM_TRACKSEQ when SM_ONLY is set for consistent tracking and debugging
#endif

#if NF_INPKT_SEQ != SM_INPKT_SEQ
#warning NF_INPKT_SEQ should be the same as SM_INPKT_SEQ when SM_ONLY is set for consistent tracking and debugging
#endif
#endif

// Parse JSON formatted input packets to tag the values with their corresponding field type
void fieldTaggerKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe);

// Connect the outputs of SM to the NF kernel, converting the SM result format to NFPM input format
void sm2nfKernel(hls::stream<MspmPayloadFlit> &PayloadInPipe, hls::stream<SmResultMetaFlit> &RidMetaInPipe,
                 hls::stream<NfpmPayloadFlit> &PayloadOutPipe, hls::stream<NfInputMetaFlit> &RidMetaOutPipe,
                 hls::stream<MspmPayloadFlit> &PayloadSafePipe, hls::stream<NfpmPayloadFlit> &PayloadForwardPipe,
                 count_directio_t &SafePayloadCount);

void nf2hostKernel(hls::stream<NfpmPayloadFlit> &PayloadInPipe, hls::stream<NfResultMetaFlit> &RidMetaInPipe,
                   hls::stream<NfpmPayloadFlit> &PayloadOutPipe, hls::stream<NfResultMetaFlit> &RidMetaOutPipe,
                   hls::stream<NfpmPayloadFlit> &PayloadSafePipe, count_directio_t &SafePayloadCount);

// Steer payloads based on SM matching results
void smSteerPayloadKernel(hls::stream<MspmPayloadFlit> &PayloadInPipe, hls::stream<SmResultMetaFlit> &RidMetaInPipe,
                          hls::stream<MspmPayloadFlit> &PayloadMatchPipe, hls::stream<MspmPayloadFlit> &PayloadSafePipe,
                          hls::stream<SmResultMetaFlit> &RidMetaOutPipe, count_directio_t &SafePayloadCount);
