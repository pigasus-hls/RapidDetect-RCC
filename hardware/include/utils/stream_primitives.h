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

#include <hls_stream.h>
#include <hls_task.h>
#include "types.h"

/**
 * Stream Primitives
 *
 * This file contains some basic stream processing primitives that are used in the streaming pipeline of RapidDetect to
 * connect between different stages and convert or transform the rule and payload flits as needed.
 *
 */

// Detects if the input packet has any hits, gobbles empty packets and sends a steering bit per packet for another
// kernel to steer the payloads to a "match" or "safe" path based on whether there were hits or not
template <typename TFlit, int numRid, BOOL hasHitsValid>
void flagger(hls::stream<TFlit> &InPipe, hls::stream<TFlit> &OutPipe, hls::stream<BOOL> &SteerPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = InPipe
#pragma HLS INTERFACE mode = axis port = OutPipe
#pragma HLS INTERFACE mode = axis port = SteerPipe

  BOOL eop = false;
  BOOL steeringSent = false;

  while (true) {
#pragma HLS PIPELINE II = 1
    TFlit inFlit;
    BOOL valid = InPipe.read_nb(inFlit);

    eop = inFlit.eop && valid;
    BOOL hasRid = false;

    if (valid) {
      if (hasHitsValid) {
        hasRid = inFlit.hasHits;
      } else {
        for (int i = 0; i < numRid; i++) {
#pragma HLS UNROLL
          if (inFlit.payload[i].ridPlusOne != 0) {
            hasRid = true;
          }
        }
      }
    }

    if (hasRid || (eop && steeringSent)) OutPipe.write(inFlit);
    if ((hasRid || eop) && !steeringSent) SteerPipe.write(hasRid);

    steeringSent = eop ? false : (steeringSent || hasRid);
  }
}

// Steers payload flits to a "match" or "safe" path based on the steering bit sent by the flagger
template <typename TPayload>
void steerPayload(hls::stream<BOOL> &SteerPipe, hls::stream<TPayload> &InPipe, hls::stream<TPayload> &MatchPipe,
                  hls::stream<TPayload> &SafePipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = SteerPipe
#pragma HLS INTERFACE mode = axis port = InPipe
#pragma HLS INTERFACE mode = axis port = MatchPipe
#pragma HLS INTERFACE mode = axis port = SafePipe

  BOOL eop = false;
  BOOL flagged = false;
  BOOL first = true;

  while (true) {
#pragma HLS PIPELINE II = 1
    if (first) {
      BOOL valid = SteerPipe.read_nb(flagged);
      first = !valid;
    }

    if (!first) {
      TPayload inPayload;
      BOOL valid = InPipe.read_nb(inPayload);
      if (valid) {
        if (flagged) {
          MatchPipe.write(inPayload);
        } else {
          SafePipe.write(inPayload);
        }
      }
      eop = inPayload.eop && valid;
      if (eop) {
        first = true;
      }
    }
  }
}
