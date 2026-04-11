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

// Parse JSON formatted input packets to tag the values with their corresponding field type
void fieldMatchKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe);

// One JSON entry might be larger than the maximum payload flit size, so this kernel progagtes the field tags across
// multiple flits
void fieldMatchFixOverflowKernel(hls::stream<PayloadWordPack> &PayloadInPipe,
                                 hls::stream<PayloadWordPack> &PayloadOutPipe);

// Steer payloads based on SM matching results
void smSteerPayloadKernel(hls::stream<MspmPayloadFlit> &PayloadInPipe, hls::stream<SmResultMetaFlit> &RidMetaInPipe,
                          hls::stream<MspmPayloadFlit> &PayloadMatchPipe, hls::stream<MspmPayloadFlit> &PayloadSafePipe,
                          hls::stream<SmResultMetaFlit> &RidMetaOutPipe);
