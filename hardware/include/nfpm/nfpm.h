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

#include "nfpm_params.h"
#include <utils/types.h>
#include "nf_tables.h"  // shift-or, bitmap, hash tables
#include <ap_int.h>

/**
 * NFPM core pattern matching logic functions
 *
 * These functions are called by streaming kernels that supply the data to these functions.
 * Functions include Hash Check (that performs the actual pattern matching) and the Fingerprint related functions (that
 * translate the matches into the actual rule ids and also perform optional crosscheck with a 2nd alternate FP to
 * improve strictness).
 */

using NFPM_KEY = ap_uint<NFPM_BITMAP_TABLE0_MAXLGDEPTH + LGBITSINBYTE>;

using NFPM_FPhalf = unsigned long;  // hash table key 64k is enough

#define NFPM_BLANK_MASK (0x0000000000000000)  // length 2~8 encoded only
#if 0
// This is incorrect but included here to match Pigasus RTL's bug.
// This bug could allow false negative on first 7 bytes of a packet.
#define NFPM_NOHISTORY_MASK (0x0003070f1f3f7fff)  // "no history" mask
#else
#define NFPM_NOHISTORY_MASK (0x000103070f1f3f7f)  // "no history" mask
#endif
/*
 * The meaning of NO HISTORY MASK
 *
 * Each byte from LSB to MSB corresponds to a position.
 *
 * In each byte, each bit corresponds to whether hit at given length is NOT possible. NFPM is different from MSPM in
 * that it encodes len=1 to len=8 patterns. (MSb is for len=1.)
 *
 * Starting without any history (count from 1 in the below) -
 * 7f: only len=1 hit possible in 1st position
 * 3f: len=2 hit also become possible starting in 2nd position
 * 1f: len=3 hit also become possible starting in 3rd position
 * ...
 * 01: len=2~7 hits are possible in 7th position;
 * 00: len=2~8 hits are possible in 8th position;
 *
 * In original Pigasus release, NFPM used an incorrect no history mask (carried over from MSPM). The incorrect mask can
 * lead to false negatives in the first 7 bytes of a packet.
 *
 * NFPM SHIFTOR current track len=1 patterns. This is does not add info to improve bitmap accuracy.  We should convert
 * it to work like MSMP (i.e. use 2 buckets for length 8).
 */

#define NFPM_FP_WIDTH (128)  // hard coded, donn't change
#define NFPM_BUCKET_WIDTH (NFPM_FP_WIDTH / NFPM_MASK_WIDTH)
using NfpmFingerprint = USHORT;  // must be > bucket_width

// Record of a hash table hit passed from nfpmHashCheck to nfpmHashLookup
struct NfpmHashHit {
  BOOL isHit;    // is hashtable hit
  NFPM_KEY key;  // key used for hashtable looking up
#if NFPM_TRACKSEQ
  USEQ seq;  // only reserve 2-byte for this
#endif
#if NFPM_TRACKPOS
  UPOS pos;  // only reserve 2-byte for this
#endif
#if NFPM_CHECKFIELD
  FTAG1 ftag;
#endif
};

// Return is don't care if either is invalid
static inline BOOL isSamePayload(NfpmHashHit a, NfpmHashHit b) {
  return (((a).key == (b).key)
#if NFPM_TRACKSEQ && NFPM_CHECKSEQ
          && ((a).seq == (b).seq)
#endif
  );
}

void nfpmHashCheck(                       // INPUTS
    PAYLOAD_WORD flitWords[NFPM_UNROLL],  // older byte in smaller address
    PAYLOAD_WORD maskIn,                  // shiftOr mask to continue checking
    PAYLOAD_WORD wordLast,                // last word scanned, NFPM_MASK_WIDTH bytes
#if NFPM_FRWD_SUPER
    UCHAR nextWordByte,  // first byte next word
#endif
#if NFPM_CHECKFIELD
    FTAG ftags[NFPM_UNROLL],
#endif

    // OUTPUTS
    PAYLOAD_WORD &maskOut,                                             // shiftOr mask to continue checking later
    NfpmHashHit hits[NFPM_MASK_WIDTH][NFPM_MASK_WIDTH * NFPM_UNROLL],  // hits returned
                                                                       // META INFO INPUTS
    USEQ seq, UPOS wordCount);                                         // meta info

#ifdef SYCLBUILD
SYCL_EXTERNAL
#endif
void nfpmAccumFP(NfpmHashHit hits[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH],  // hits to look up
                 NfpmFingerprint fp[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH]
#if NFPM_CHECK_FPALT
                 ,
                 NfpmFingerprint fp_alt[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH]
#endif
);

BOOL nfpmMatchFP(NfpmFingerprint ref[NFPM_MASK_WIDTH], NfpmFingerprint check[NFPM_MASK_WIDTH]);
void nfpmSetFP(NFPM_FPhalf fpu, NFPM_FPhalf fpl, NfpmFingerprint fp[NFPM_MASK_WIDTH]);

void nfpmPrintFP(char *prefix, NfpmFingerprint fp[NFPM_MASK_WIDTH]);
