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

/**
 * NFPM is almost the same as MSPM, especially in the frontend scanning logic. The main difference are
 *
 * (1) nfpm uses len=1~8 strings. Whereas len=1 strings are not in Pigasus fast patten matching and are hardcode removed
 * in the shift-or logic to save logic.
 * (2) MSPM uses 2 hash bucket for len=8 case. (Many len=8 patterns)
 * (3) In the backend, NFPM computes and checks a "bloom-filter-like" signature to affirm all of the patterns in a rule
 * are present. MSPM is only about checking the fast pattern.
 */

#include <stdio.h>
#include <stdlib.h>

#include <nfpm/nfpm_debug.h>
#include <nfpm/nfpm.h>

void nfpmDebugMsg([[maybe_unused]] char *s, [[maybe_unused]] UINT pos, [[maybe_unused]] UINT len,
                  [[maybe_unused]] NfpmHashHit e, [[maybe_unused]] BOOL doit) {
#if NFPM_DEBUG_BITMAP || NFPM_DEBUG_SHIFTOR || NFPM_DEBUG_FP
  if (doit) {
    printf("%s (pos=%d::len=%d) (key=%d", s, pos, len, e.payload.key);
#if NFPM_TRACKSEQ
    printf("::seq=%d", e.payload.seq);
#endif
#if NFPM_TRACKPOS
    printf("::pos=%d", e.payload.pos);
#endif
    printf(")\n");
  }
#endif
}

/**
 * This function performs "extend shift-or" scanning, ala Hyperscan. You have the option to form a "supercharacter" by
 * combining with 5 bits from the next younger byte (NFPM_FRWD_SUPER=1) or the preceeding older byte
 * (NFPM_FRWD_SUPER=0). The forward supercharacter method (used by Hyperscan and Pigasus) can be slightly more strict
 * (fewer false positives) depending on the strings collection and the input data stream. Depending on usage context,
 * forward supercharacter method might be more awkward.
 *
 * Forward super char is more important in Pigasus non-fast pattern matcher which has len=1 strings.
 */
void nfpmShiftOr(                              // INPUTS
    PAYLOAD_WORD flitWords[NFPM_UNROLL],       // older byte in smaller address
    PAYLOAD_WORD maskIn,                       // shiftOr mask to continue checking
    UBYTE byteIn,                              // need last byte for super character
                                               // OUTPUTS
    PAYLOAD_WORD &maskOut,                     // shiftOr mask to continue checking later
    PAYLOAD_WORD shiftOrMask[NFPM_UNROLL + 1]  // shift-or detection mask
) {
  MY_ASSERT(NFPM_MASK_WIDTH == sizeof(PAYLOAD_WORD));  // Hyperscan unit width can't be changed.
#if NFPM_FRWD_SUPER
  MY_ASSERT(NFPM_SHIFTORF_TABLE_LGDEPTH <= (2 * BITSINBYTE));  // This value can be 8~16
#else
  MY_ASSERT(NFPM_SHIFTORR_TABLE_LGDEPTH <= (2 * BITSINBYTE));  // This value can be 8~16
#endif
  MY_ASSERT((flitWords[0] & ((1 << BITSINBYTE) - 1)) == (*((UBYTE *)&flitWords[0])));  // sample check little endian

  PAYLOAD_WORD shiftOrAccum[NFPM_UNROLL + 1];  // Shift-or accumulator
  UBYTE super;
#if NFPM_FRWD_SUPER
  UBYTE nextWordBytel = byteIn;
#else
  super = byteIn;
#endif

  shiftOrAccum[0] = maskIn;

  for (UIDX scan = 1; scan <= NFPM_UNROLL; scan++) {
#pragma HLS UNROLL
    shiftOrAccum[scan] = NFPM_BLANK_MASK;  // anything is possible
  }

  for (UIDX scan = 0; scan < NFPM_UNROLL; scan++) {
#pragma HLS UNROLL
    // do NFPM_UNROLL hypercan nfpm checking

    PAYLOAD_WORD current = 0;  // current 8 byte being checked
    {
      // insist on little endian: older byte at smaller address
      UBYTE *byte = (UBYTE *)&(flitWords[scan]);
      for (UIDX i = 0; i < NFPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
        current |= ((PAYLOAD_WORD)byte[i]) << (i * BITSINBYTE);
      }
    }

    {
      for (UIDX i = 0; i < NFPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
        // scan byte-by-byte
        UIDX index;  // shiftOr table index
        UBYTE byte;
        PAYLOAD_WORD shiftOrMask;           // shift or mask
        PAYLOAD_WORD lowerMask, upperMask;  // shift by byte position

#if NFPM_DEBUG_SHIFTOR
        PAYLOAD_WORD oldMaskDebug = shiftOrAccum[scan];
#endif

        // compute supercharacter for indexing
        byte = (current >> ((i)*BITSINBYTE)) & BYTEMASK;
#if NFPM_FRWD_SUPER
        if ((scan == (NFPM_UNROLL - 1)) && (i == (NFPM_MASK_WIDTH - 1))) {
          super = nextWordBytel;
        } else if (i == (NFPM_MASK_WIDTH - 1)) {
          super = ((UBYTE *)&flitWords[scan + 1])[0];
        } else {
          super = (current >> ((i + 1) * BITSINBYTE)) & BYTEMASK;
        }
#endif
        index = byte;
        index |= super << BITSINBYTE;
#if NFPM_FRWD_SUPER
        index &= ((1 << NFPM_SHIFTORF_TABLE_LGDEPTH) - 1);
#else
        index &= ((1 << NFPM_SHIFTORR_TABLE_LGDEPTH) - 1);
#endif
#if !NFPM_FRWD_SUPER
        super = byte;  // for next word
#endif

        // lookup mask
#if NFPM_FRWD_SUPER
        shiftOrMask = NFPM_SHIFTORF_TABLE[index];  // NFPM_UNROLL*NFPM_MASK_WIDTH times total
#else
        shiftOrMask = NFPM_SHIFTORR_TABLE[index];  // NFPM_UNROLL*NFPM_MASK_WIDTH times total
#endif
        {
          UCHAR shiftl = (i * BITSINBYTE);
          UCHAR shiftr = ((sizeof(PAYLOAD_WORD) * BITSINBYTE) - (i * BITSINBYTE));
          lowerMask = shiftOrMask << shiftl;
          upperMask = shiftOrMask;
          if (shiftr >= 32) {
            // can't right shift by 64
            upperMask = upperMask >> 32;
            shiftr -= 32;
          }
          upperMask = upperMask >> shiftr;
        }
        // accumulate shiftOr
        shiftOrAccum[scan] |= lowerMask;
        shiftOrAccum[scan + 1] |= upperMask;

#if NFPM_DEBUG_SHIFTOR
        {
          printf("index%d=[%02x]%02x ", i, index >> BITSINBYTE, index & 255);
          // printf("%016lx ", shiftOrMask);
          printf("%016lx ", upperMask);
          printf("%016lx ", lowerMask);
          printf("%016lx::", shiftOrAccum[scan + 1]);
          printf("%016lx<-", shiftOrAccum[scan]);
          printf("%016lx\n", oldMaskDebug);
          if (i == (NFPM_MASK_WIDTH - 1)) {
            putchar('\n');
          }
        }
#endif
      }
    }
  }

  // Set output values
  maskOut = shiftOrAccum[NFPM_UNROLL];
  for (UIDX scan = 0; scan < NFPM_UNROLL; scan++) {
#pragma HLS UNROLL
    shiftOrMask[scan] = shiftOrAccum[scan];
  }

  return;
}

#define MAGIC_NUM ((ULONG)0x0b4e0ef37bc32127)
#include <utils/multlookup.h>

// Hyperscan multiply-based hash. We could do something better in HW.
static ULONG hsHashFxnSimOnly(ULONG lv, ULONG andmsk, ULONG nBits) {
  // we don't actually use this function in a code; the multiply is decomposed
  ULONG mult = MAGIC_NUM;

  lv &= andmsk;
  mult *= lv;
  mult >>= (64 - nBits);

  return mult;
}

/**
 * Like in Pigasus, hash table hit is checked first at full bandwidth requiring only the valid bit column to be
 * replicated for concurrent read. The full table lookup only happens for cases that hit, a much lower rate. Unlike
 * MSPM, there is no option to add a tag column to the hashtable which can have collisions in NFPM usage.
 */
void nfpmBitmap(                          // INPUTS
    PAYLOAD_WORD flitWords[NFPM_UNROLL],  // older byte in smaller address
    PAYLOAD_WORD pastWord,                // last word scanned, NFPM_MASK_WIDTH bytes

    // OUTPUTS
    NfpmHashHit hits[NFPM_MASK_WIDTH][NFPM_MASK_WIDTH * NFPM_UNROLL],
    // for each position check pattern length 2~8 with hits[0][bytepos] for len
    // 1) and with hits[7][bytepos] for len 8) smaller bytepos is older.

    // META INFO INPUT
    [[maybe_unused]] USEQ sequence,
    [[maybe_unused]] USEQ wordCount  // tag output with sequence metainfo
) {
  MY_ASSERT(NFPM_MASK_WIDTH == sizeof(PAYLOAD_WORD));  // Hyperscan unit width can't be changed.
  MY_ASSERT((flitWords[0] & ((1 << BITSINBYTE) - 1)) == (*((UBYTE *)&flitWords[0])));  // sample check little endian

  UBYTE bytes[(NFPM_UNROLL + 1) * NFPM_MASK_WIDTH];       // scan flitwords a one long byte sequence
  ULONG hashNibble[(NFPM_UNROLL + 1) * NFPM_MASK_WIDTH];  // bytes' contribution to hash

  // set prefix bytes from input
  for (UIDX pos = 0; pos < NFPM_MASK_WIDTH; pos++) {
#pragma HLS UNROLL
    bytes[pos] = (pastWord >> (pos * BITSINBYTE)) & BYTEMASK;
  }
  // set current flit bytes
  for (UIDX pos = 0; pos < (NFPM_MASK_WIDTH * NFPM_UNROLL); pos++) {
#pragma HLS UNROLL
    // force little endian
    bytes[NFPM_MASK_WIDTH + pos] = ((UBYTE *)(&(flitWords[0])))[pos];
  }

  for (UIDX pos = 0; pos < (NFPM_MASK_WIDTH * (NFPM_UNROLL + 1)); pos++) {
#pragma HLS UNROLL
    // It was discovered for 2023, multiplying by the Magic Constant directly produces incorrect prodcut. This will not
    // work correctly on FPGA.
    // hashNibble[pos] = bytes[pos] * MAGIC_NUM;
    hashNibble[pos] = lookupTable[bytes[pos]];
  }

  // Scan for each patterning ending by position
  for (UIDX pos = 0; pos < (NFPM_MASK_WIDTH * NFPM_UNROLL); pos++) {
#pragma HLS UNROLL
    // Initialized to zero since for loop starts from len=1 (different from mspm)
    PAYLOAD_WORD current = 0x0;
    ULONG hashIncremental = 0;

    // Scan for different length
    for (UIDX len = 1; len <= NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      current |= ((PAYLOAD_WORD)bytes[NFPM_MASK_WIDTH + pos - len + 1])
                 << ((NFPM_MASK_WIDTH - len) * BITSINBYTE);  // extend toward older bytes
      hashIncremental += ((hashNibble[NFPM_MASK_WIDTH + pos - len + 1]) << ((NFPM_MASK_WIDTH - len) * BITSINBYTE));

      // The bitmap table is like the valid column of the hash table,
      // packetd 8 bits to 1 bitmap table entry
      NFPM_KEY hashKey;   // hash key
      ULONG andMask;      // andMask
      UINT nBitsBmap;     // log (size of bitmap table in #entries)
      UBYTE packedHits8;  // packed hits, 8 to each entry.
                          // Inferred byte-wide memory is more efficient by bit-wide memory

      switch (len) {
        case 1:
          nBitsBmap = NFPM_BITMAP_TABLE7_LGDEPTH;
          break;
        case 2:
          nBitsBmap = NFPM_BITMAP_TABLE6_LGDEPTH;
          break;
        case 3:
          nBitsBmap = NFPM_BITMAP_TABLE5_LGDEPTH;
          break;
        case 4:
          nBitsBmap = NFPM_BITMAP_TABLE4_LGDEPTH;
          break;
        case 5:
          nBitsBmap = NFPM_BITMAP_TABLE3_LGDEPTH;
          break;
        case 6:
          nBitsBmap = NFPM_BITMAP_TABLE2_LGDEPTH;
          break;
        case 7:
          nBitsBmap = NFPM_BITMAP_TABLE1_LGDEPTH;
          break;
        case 8:
          nBitsBmap = NFPM_BITMAP_TABLE0_LGDEPTH;
          break;
      }

      MY_ASSERT(nBitsBmap <= NFPM_BITMAP_TABLE0_MAXLGDEPTH);

      andMask = 0xffffffffffffffff << ((NFPM_MASK_WIDTH - len) * BITSINBYTE);
      hashKey = hashIncremental >> (64 - (nBitsBmap + LGBITSINBYTE));

      MY_ASSERT(hashKey == hsHashFxnSimOnly(current, andMask, (nBitsBmap + LGBITSINBYTE)));

      {
        switch (len) {
          case 1:
            packedHits8 = NFPM_BITMAP_TABLE7[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE7_DEPTH - 1)];
            break;
          case 2:
            packedHits8 = NFPM_BITMAP_TABLE6[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE6_DEPTH - 1)];
            break;
          case 3:
            packedHits8 = NFPM_BITMAP_TABLE5[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE5_DEPTH - 1)];
            break;
          case 4:
            packedHits8 = NFPM_BITMAP_TABLE4[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE4_DEPTH - 1)];
            break;
          case 5:
            packedHits8 = NFPM_BITMAP_TABLE3[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE3_DEPTH - 1)];
            break;
          case 6:
            packedHits8 = NFPM_BITMAP_TABLE2[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE2_DEPTH - 1)];
            break;
          case 7:
            packedHits8 = NFPM_BITMAP_TABLE1[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE1_DEPTH - 1)];
            break;
          case 8:
            packedHits8 = NFPM_BITMAP_TABLE0[(hashKey / BITSINBYTE) & (NFPM_BITMAP_TABLE0_DEPTH - 1)];
            break;
        }
      }

      // Unpack and select bit
      packedHits8 &= (1 << (hashKey % BITSINBYTE));

      // Just checking
      MY_ASSERT(len >= 1);
      MY_ASSERT(len <= NFPM_MASK_WIDTH);

      // Set hit record
      hits[len - 1][pos].isHit = (packedHits8 != 0);

      // Hash table lookup
      hits[len - 1][pos].key = hashKey;

      // meta info
#if NFPM_TRACKSEQ
      hits[len - 1][pos].seq = sequence;
#endif
#if NFPM_TRACKPOS
      hits[len - 1][pos].pos = wordCount * NFPM_UNROLL * NFPM_MASK_WIDTH + pos;
#endif

#if NFPM_DEBUG_BITMAP
      {
        printf("Checking %016lx key=%d pos=%d len=%d\n", current, hashKey, pos, len);
        if (packedHits8) {
          printf("HIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          printf("Checking %016lx key=%d seq=%d pos=%d len=%d\n", current, hashKey, sequence,
                 wordCount * NFPM_UNROLL * NFPM_MASK_WIDTH + pos, len);
        }
      }
#endif
    }
  }
}

/**
 * Like in Pigasus, hash table hit is checked first at full bandwidth. Hash table lookup is a separate call that happens
 * much more rarely. False positive posible. Hit checking consults both an extended shift-or mask and a hash-table valid
 * bit to minimize false positive for the amount of SRAM used.
 */
void nfpmHashCheck(                       // INPUTS
    PAYLOAD_WORD flitWords[NFPM_UNROLL],  // older byte in smaller address
    PAYLOAD_WORD maskIn,                  // shiftOr mask to continue checking
    PAYLOAD_WORD wordLast,                // last word scanned, NFPM_MASK_WIDTH bytes
#if NFPM_FRWD_SUPER
    UCHAR nextWordByte,  // first byte next word for future supercharacter
#endif
#if NFPM_CHECKFIELD
    FTAG ftags[NFPM_UNROLL],
#endif

    // OUTPUTS
    PAYLOAD_WORD &maskOut,                                             // shiftOr mask to continue checking later
    NfpmHashHit hits[NFPM_MASK_WIDTH][NFPM_MASK_WIDTH * NFPM_UNROLL],  // hits returned
    // META INFO INPUT
    USEQ seq, UPOS wordCount) {
#if NFPM_DEBUG_SHIFTOR || NFPM_DEBUG_BITMAP
  printf("======== seq=%d =======\n", seq);
#endif

  PAYLOAD_WORD shiftOrMask[NFPM_UNROLL];  // Shift-or accumulator
#if NFPM_USE_SHIFTOR
  // check shift-or table
  nfpmShiftOr(flitWords, maskIn,
#if NFPM_FRWD_SUPER
              nextWordByte,
#else
              (wordLast >> ((NFPM_MASK_WIDTH - 1) * BITSINBYTE)) & BYTEMASK,
#endif
              maskOut, shiftOrMask);
#else
  for (UIDX i = 0; i < NFPM_UNROLL; i++) {
#pragma HLS UNROLL
    shiftOrMask[i] = 0;
  }
#endif

  // Check bitmap table
  nfpmBitmap(flitWords, wordLast, hits, seq, wordCount);

  // Corroborate 2 results
  for (UIDX pos = 0; pos < (NFPM_MASK_WIDTH * NFPM_UNROLL); pos++) {
#pragma HLS UNROLL
    PAYLOAD_WORD word = shiftOrMask[pos / NFPM_MASK_WIDTH];

#if NFPM_CHECKFIELD
    FTAG1 ftag = ((ftags[pos / NFPM_MASK_WIDTH] >> (FTAG_BITS_PER_BYTE * (pos % NFPM_MASK_WIDTH))) &
                  ((1 << FTAG_BITS_PER_BYTE) - 1));
#endif

    for (UIDX len = 1; len <= NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      // check each bit (combination of pattern length and ending position)
      BOOL bit = ((word >> ((pos % NFPM_MASK_WIDTH) * BITSINBYTE + (NFPM_MASK_WIDTH - len))) & 0x1) != 0;

#if NFPM_CHECKFIELD
      hits[len - 1][pos].ftag = ftag;
#endif

      if (bit) {
        // shift-or says NO
        if (hits[len - 1][pos].isHit != 0) {
          nfpmDebugMsg((char *)"shiftor cancelled bitmap", pos, len, hits[len - 1][pos], NFPM_DEBUG_BITMAP);
        }

        // then it is a NO regarless of what the bitmap tabled said
        hits[len - 1][pos].isHit = 0;
      } else {
        // shift-or says YES then whatever bitmap table says stands
        if (!(hits[len - 1][pos].isHit)) {
          nfpmDebugMsg((char *)"bitmap cancelled shiftor", pos, len, hits[len - 1][pos], NFPM_DEBUG_BITMAP);
        } else {
          nfpmDebugMsg((char *)"shiftor and bitmap agree", pos, len, hits[len - 1][pos], NFPM_DEBUG_BITMAP);
        }
      }
    }
  }
}

/*
 * Do table lookup on hits from nfpmHachCheck(). Lookup is a much lower bandwidth activity in comparison to checking.
 * Checking could produces NFPM_UNROLL x NFPM_MASK_WIDTH concurrent hits (32 in Pigasus). A compaction network can
 * narrow the outcome to FANOUT*NFPM_WIDTH_WIDTH. FANOUT copies of the full table is needed in HashLookup.
 */
void nfpmAccumFP(NfpmHashHit hits[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH],  // hits to look up
                 NfpmFingerprint fp[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH]
#if NFPM_CHECK_FPALT
                 ,
                 NfpmFingerprint fp_alt[NFPM_MASK_WIDTH][NFPM_LOOKUP_WIDTH]
#endif
) {
  // Hash table lookup
  for (UIDX pos = 0; pos < NFPM_LOOKUP_WIDTH; pos++) {
#pragma HLS UNROLL
    for (UIDX len = 1; len <= NFPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
#if NFPM_CHECKFIELD
      UCHAR ftag_bmap;

      switch (len) {
        case 1:
          ftag_bmap = NFPM_HASH_BMAPTABLE7[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE7_DEPTH - 1)];
          break;
        case 2:
          ftag_bmap = NFPM_HASH_BMAPTABLE6[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE6_DEPTH - 1)];
          break;
        case 3:
          ftag_bmap = NFPM_HASH_BMAPTABLE5[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE5_DEPTH - 1)];
          break;
        case 4:
          ftag_bmap = NFPM_HASH_BMAPTABLE4[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE4_DEPTH - 1)];
          break;
        case 5:
          ftag_bmap = NFPM_HASH_BMAPTABLE3[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE3_DEPTH - 1)];
          break;
        case 6:
          ftag_bmap = NFPM_HASH_BMAPTABLE2[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE2_DEPTH - 1)];
          break;
        case 7:
          ftag_bmap = NFPM_HASH_BMAPTABLE1[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE1_DEPTH - 1)];
          break;
        case 8:
          ftag_bmap = NFPM_HASH_BMAPTABLE0[hits[len - 1][pos].key & (NFPM_HASH_BMAPTABLE0_DEPTH - 1)];
          break;
      }
      ftag_bmap &= (1 << FTAG_HOWMANY) - 1;
#endif

      if ((hits[len - 1][pos].isHit)
#if NFPM_CHECKFIELD
          && (ftag_bmap & (1 << hits[len - 1][pos].ftag))
#endif
      ) {
        NFPM_KEY key = hits[len - 1][pos].key;
        UIDX trunc = key % NFPM_BUCKET_WIDTH;
#if NFPM_CHECK_FPALT
        UIDX trunc_alt = (key / NFPM_BUCKET_WIDTH) % NFPM_BUCKET_WIDTH;
#endif

#if NFPM_CHECK_FPDWIDE
        BOOL odd = (key & (NFPM_BUCKET_WIDTH)) != 0;
        UIDX bucket = NFPM_MASK_WIDTH - len;
        // twisting the index to match the fingerprint generator
        // (8:1)(7:2)(6:3)(5:4) share double-wide bucekts
        if (bucket >= 4) {
          bucket = 2 * (bucket - (NFPM_MASK_WIDTH / 2));
        } else {
          bucket = 2 * ((NFPM_MASK_WIDTH / 2) - bucket - 1);
        }
        if (odd) {
          fp[NFPM_MASK_WIDTH - (bucket + 1) - 1][pos] |= (1 << trunc);
        } else {
          fp[NFPM_MASK_WIDTH - bucket - 1][pos] |= (1 << trunc);
        }
#else
        fp[len - 1][pos] |= (1 << trunc);
#endif
#if NFPM_CHECK_FPALT
        fp_alt[len - 1][pos] |= (1 << trunc_alt);
#endif

        nfpmDebugMsg((char *)"nfpm hit", pos, len, hits[len - 1][pos], NFPM_DEBUG_FP);
#if NFPM_DEBUG_FP
        nfpmPrintFP((char *)"fp[pos] ", fp[pos]);
#endif
      } else {
        // printf("miss\n");
      }
    }
  }
}

void nfpmPrintFP(char *prefix, NfpmFingerprint fp[NFPM_MASK_WIDTH]) {
  MY_ASSERT((sizeof(NFPM_FPhalf) * 2) == (NFPM_FP_WIDTH / BITSINBYTE));
  MY_ASSERT(sizeof(NfpmFingerprint) == (NFPM_BUCKET_WIDTH / BITSINBYTE));

  printf("%s [", prefix);
  for (UIDX i = 0; i * (NFPM_BUCKET_WIDTH) < NFPM_FP_WIDTH; i++) {
    printf("%04x ", fp[i]);
  }
  printf("]\n");
}

BOOL nfpmMatchFP(NfpmFingerprint ref[NFPM_MASK_WIDTH], NfpmFingerprint check[NFPM_MASK_WIDTH]) {
  MY_ASSERT((sizeof(NFPM_FPhalf) * 2) == (NFPM_FP_WIDTH / BITSINBYTE));
  MY_ASSERT(sizeof(NfpmFingerprint) == (NFPM_BUCKET_WIDTH / BITSINBYTE));

  BOOL match = true;
  for (UIDX i = 0; i < (NFPM_FP_WIDTH / NFPM_BUCKET_WIDTH); i++) {
#pragma HLS UNROLL
    match &= ((ref[i] & check[i]) == ref[i]);
  }
#if NFPM_DEBUG_FP
  if (match) {
    nfpmPrintFP((char *)"matched", ref);
    nfpmPrintFP((char *)"check", check);
    printf("-----------------\n\n");
  } else {
    nfpmPrintFP((char *)"not yet", check);
    nfpmPrintFP((char *)"ref", ref);
  }
#endif
  return match;
}

void nfpmSetFP(NFPM_FPhalf fpu, NFPM_FPhalf fpl, NfpmFingerprint fp[NFPM_MASK_WIDTH]) {
  MY_ASSERT((sizeof(NFPM_FPhalf) * 2) == (NFPM_FP_WIDTH / BITSINBYTE));
  MY_ASSERT(sizeof(NfpmFingerprint) == (NFPM_BUCKET_WIDTH / BITSINBYTE));

  for (UIDX i = 0; i < NFPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
    fp[NFPM_MASK_WIDTH - 1 - i] =
        (i >= (NFPM_MASK_WIDTH / 2))
            ? (fpu >> ((i - NFPM_MASK_WIDTH / 2) * (NFPM_BUCKET_WIDTH))) % (1 << NFPM_BUCKET_WIDTH)
            : (fpl >> (i * (NFPM_BUCKET_WIDTH))) % (1 << NFPM_BUCKET_WIDTH);
  }
}
