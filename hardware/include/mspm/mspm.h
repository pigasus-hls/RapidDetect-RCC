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

#include <utils/types.h>

#include "mspm_params.h"
#include "sm_tables.h"  // shift-or, bitmap, hash and tag tables
#include <ap_int.h>

/**
 * MSPM core pattern matching logic functions
 *
 * These functions are called by streaming kernels that supply the data to these functions.
 * Functions include Hash Check (that performs the actual pattern matching) and Hash Lookup (which translates the
 * matches into the actual rule ids).
 */

using MSPM_TAG = unsigned char;  // 1-byte hash tag

using MSPM_KEY = ap_uint<MSPM_HASH_TABLE0_MAXLGDEPTH>;

#define MSPM_BLANK_MASK (0x0000000000000000)      // length 2~8 encoded only (8 twice)
#define MSPM_NOHISTORY_MASK (0x0003070f1f3f7fff)  // "no history" mask
/*
 * The meaning of NO HISTORY MASK
 *
 * Each byte from LSB to MSB corresponds to a position.
 *
 * In each byte, each bit corresponds to whether hit at given length is NOT possible. (MSb is for len=2.)
 *
 * Starting without any history (count from 1 in the below) -
 * ff: 1st position can't hit since min patt len=2
 * 7f: len=2 hit become possible starting in 2nd position
 * 3f: len=3 hit also become possible starting in 3rd position
 * ...
 * 03: len=2~7 hits are possible in 7th position; note that 1st and 2nd bits in mask are both used for len=8 which is
 * encoded in 2 buckets because there many more len=8 patterns 00: len=2~8 hits are possible in 8th position;
 *
 * MSPM does not check for len=1 patterns; it you want to, you can check for it with a hashtable. ShiftOR does not add
 * more information for len=1.
 */

using PAYLOAD_WORD = ULONG;  // a 8-byte hyerscan word and mask

// Record of a hash table hit passed from mspmHashCheck to mspmHashLookup
struct MspmHashHit {
  BOOL isHit;    // is hashtable hit
  MSPM_KEY key;  // key used for hashtable looking up
#if MSPM_CHECKTAG
  MSPM_TAG tag;  // optional tag used for hashtable looking up
#endif
#if MSPM_TRACKSEQ
  USEQ seq;  // only reserve 2-byte for this
#endif
#if MSPM_TRACKPOS
  UPOS pos;  // only reserve 2-byte for this
#endif
#if MSPM_CHECKFIELD
  FTAG1 ftag;
#endif
};

// Return is don't care if either is invalid
static inline BOOL isSamePayload(MspmHashHit a, MspmHashHit b) {
  return (((a).key == (b).key)
#if MSPM_TRACKSEQ && MSPM_CHECKSEQ
          && ((a).seq == (b).seq)
#endif
#if MSPM_CHECKTAG
          && ((a).tag == (b).tag)
#endif
#if MSPM_CHECKFIELD
          && ((a).ftag % (1 << FTAG_BITS_PER_BYTE) == (b).ftag % (1 << FTAG_BITS_PER_BYTE))
#endif
  );
}

/*
 * Like in Pigasus, hash table hit is checked first at full bandwidth. Hash table lookup is a separate call that happens
 * much more rarely. False positive posible. Hit checking consults both an extended shift-or mask and a hash-table valid
 * bit to minimize false positive for the amount of SRAM used.
 */
void mspmHashCheck(                       // INPUTS
    PAYLOAD_WORD flitWords[MSPM_UNROLL],  // older byte in smaller address
    PAYLOAD_WORD maskIn,                  // shiftOr mask to continue checking
    PAYLOAD_WORD wordLast,                // last word scanned, MSPM_MASK_WIDTH bytes
#if MSPM_FRWD_SUPER
    UCHAR nextWordByte,  // first byte next word
#endif
#if MSPM_CHECKFIELD
    FTAG ftags[MSPM_UNROLL],
#endif

    // OUTPUTS
    PAYLOAD_WORD &maskOut,                                             // shiftOr mask to continue checking later
    MspmHashHit hits[MSPM_MASK_WIDTH][MSPM_MASK_WIDTH * MSPM_UNROLL],  // hits returned

    // META INFO INPUTS
    USEQ seq, UPOS wordCount);  // meta info

void mspmHashLookupByLen(const unsigned int whichLen,          // 2~9 only (8 twice)
                         MspmHashHit hits[MSPM_LOOKUP_WIDTH],  // hits to look up
                         URID ridPlusOne[MSPM_LOOKUP_WIDTH],   // rule id found, 0 means invalid
                         USEQ seq[MSPM_LOOKUP_WIDTH],          // corresponding seq number
                         UPOS pos[MSPM_LOOKUP_WIDTH],          // corresponding pos number
                         MSPM_TAG tag[MSPM_LOOKUP_WIDTH]       // corresponding tag number
);
