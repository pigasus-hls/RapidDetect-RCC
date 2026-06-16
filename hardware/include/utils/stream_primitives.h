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

// Provide default implementation for copying RID metadata
template <typename T>
void copyRidMeta(T &out, const T &in) {
#pragma HLS INLINE
  out = in;
}

// Detects if the input packet has any hits, gobbles empty packets and sends a steering bit per packet for another
// kernel to steer the payloads to a "match" or "safe" path based on whether there were hits or not
template <typename TRidInFlit, typename TRidOutFlit, int numRid, BOOL hasHitsValid>
void flagger(hls::stream<TRidInFlit> &InPipe, hls::stream<TRidOutFlit> &OutPipe, hls::stream<BOOL> &SteerPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = InPipe
#pragma HLS INTERFACE mode = axis port = OutPipe
#pragma HLS INTERFACE mode = axis port = SteerPipe

  BOOL eop = false;
  BOOL steeringSent = false;

  while (true) {
#pragma HLS PIPELINE II = 1
    TRidInFlit inFlit;
    TRidOutFlit outFlit;
    BOOL valid = InPipe.read_nb(inFlit);
    for (int i = 0; i < numRid; i++) {
#pragma HLS UNROLL
      copyRidMeta(outFlit.payload[i], inFlit.payload[i]);
    }

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
    outFlit.eop = eop;
    outFlit.hasHits = hasRid;

    if (hasRid || (eop && steeringSent)) OutPipe.write(outFlit);
    if ((hasRid || eop) && !steeringSent) SteerPipe.write(hasRid);

    steeringSent = eop ? false : (steeringSent || hasRid);
  }
}

// Steers payload flits to a "match" or "safe" path based on the steering bit sent by the flagger
template <typename TPayload>
void steerPayload(hls::stream<BOOL> &SteerPipe, hls::stream<TPayload> &InPipe, hls::stream<TPayload> &MatchPipe,
                  hls::stream<TPayload> &SafePipe, count_directio_t &SafePayloadCount) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = SteerPipe
#pragma HLS INTERFACE mode = axis port = InPipe
#pragma HLS INTERFACE mode = axis port = MatchPipe
#pragma HLS INTERFACE mode = axis port = SafePipe
#pragma HLS INTERFACE mode = s_axilite port = SafePayloadCount

  BOOL eop = false;
  BOOL flagged = false;
  BOOL first = true;

  uint32_t safe_payload_count = 0;

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
          safe_payload_count += inPayload.eop;
        }
      }
      eop = inPayload.eop && valid;
      if (eop) {
        first = true;
      }
    }

    SafePayloadCount.write(safe_payload_count);
  }
}

// Downshifts a wide payload flit into narrower flits, adjusting the eop signal accordingly
// User must provide the copyPayloadFlit function to specify how the payload should be copied between the types
template <typename TPayloadInFlit, int TPayloadInUnroll, typename TPayloadOutFlit, int TPayloadOutUnroll>
void payloadDownshift(hls::stream<TPayloadInFlit> &InPipe, hls::stream<TPayloadOutFlit> &OutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = InPipe
#pragma HLS INTERFACE mode = axis port = OutPipe

  uint8_t index = 0;
  TPayloadInFlit inFlit;
  BOOL valid = false;

  while (1) {
#pragma HLS PIPELINE II = 1
    if (!valid) valid = InPipe.read_nb(inFlit);

    if (valid) {
      BOOL paddingFlit = true;
      for (int i = 0; i < TPayloadOutUnroll; i++) {
#pragma HLS UNROLL
        for (int j = 0; j < sizeof(PAYLOAD_WORD); j++) {
#pragma HLS UNROLL
          // If all bytes in the flit are 0xFF, we consider it as padding and do not send it to output
          if (((inFlit.word[index * TPayloadOutUnroll + i] >> (j * 8)) & 0xFF) != 0xFF) {
            paddingFlit = false;
          }
        }
      }

      TPayloadOutFlit outFlit;
      copyPayloadFlit(outFlit, inFlit, index * TPayloadOutUnroll);
      index = (index + 1) % (TPayloadInUnroll / TPayloadOutUnroll);

      outFlit.eop = (inFlit.eop && (index == 0));
      if (!paddingFlit || outFlit.eop) OutPipe.write(outFlit);

      if (index == 0) valid = false;
    }
  }
}

template <typename T>
void fork(hls::stream<T> &InPipe, hls::stream<T> &OutPipe1, hls::stream<T> &OutPipe2) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = InPipe
#pragma HLS INTERFACE mode = axis port = OutPipe1
#pragma HLS INTERFACE mode = axis port = OutPipe2

  while (true) {
#pragma HLS PIPELINE II = 1
    T inData;
    BOOL valid = InPipe.read_nb(inData);
    if (valid) {
      OutPipe1.write(inData);
      OutPipe2.write(inData);
    }
  }
}
