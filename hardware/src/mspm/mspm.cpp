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

#include <stdio.h>
#include <stdlib.h>

#include <mspm/mspm_debug.h>

#include <mspm/mspm.h>

void mspmDebugMsg([[maybe_unused]] char *s, [[maybe_unused]] UINT pos, [[maybe_unused]] UINT len,
                  [[maybe_unused]] MspmHashHit e, [[maybe_unused]] BOOL doit) {
#if MSPM_DEBUG_BITMAP || MSPM_DEBUG_SHIFTOR || MSPM_DEBUG_RID
  if (doit) {
    printf("%s (pos=%d::len=%d) (key=%d", s, pos, len, e.key);
#if MSPM_CHECKTAG
    printf("::tag=%d", e.tag);
#endif
#if MSPM_TRACKSEQ
    printf("::seq=%d", e.seq);
#endif
#if MSPM_TRACKPOS
    printf("::pos=%d", e.pos);
#endif
    printf(")\n");
  }
#endif
}

/**
 * This function performs "extend shift-or" scanning, ala Hyperscan. You have the option to form a "supercharacter" by
 * combining with 5 bits from the next younger byte (MSPM_FRWD_SUPER=1) or the preceeding older byte
 * (MSPM_FRWD_SUPER=0). The forward supercharacter method (used by Hyperscan and Pigasus) can be slightly more strict
 * (fewer false positives) depending on the strings collection and the input data stream. Depending on usage context,
 * forward supercharacter method might be more awkward.
 */
void mspmShiftOr(                         // INPUTS
    PAYLOAD_WORD flitWords[MSPM_UNROLL],  // older byte in smaller address
    PAYLOAD_WORD maskIn,                  // shiftOr mask to continue checking
    UBYTE byteIn,                         // need last byte for super character

    // OUTPUTS
    PAYLOAD_WORD &maskOut,                     // shiftOr mask to continue checking later
    PAYLOAD_WORD shiftOrMask[MSPM_UNROLL + 1]  // shift-or detection mask
) {
  MY_ASSERT(MSPM_MASK_WIDTH == sizeof(PAYLOAD_WORD));  // Hyperscan unit width can't be changed.
#if MSPM_FRWD_SUPER
  MY_ASSERT(MSPM_SHIFTORF_TABLE_LGDEPTH <= (2 * BITSINBYTE));  // This value can be 8~16
#else
  MY_ASSERT(MSPM_SHIFTORR_TABLE_LGDEPTH <= (2 * BITSINBYTE));  // This value can be 8~16
#endif
  MY_ASSERT((flitWords[0] & ((1 << BITSINBYTE) - 1)) == (*((UBYTE *)&flitWords[0])));  // sample check little endian

  PAYLOAD_WORD shiftOrAccum[MSPM_UNROLL + 1];  // Shift-or accumulator
  UBYTE super;
#if MSPM_FRWD_SUPER
  UBYTE nextWordBytel = byteIn;
#else
  super = byteIn;
#endif

  shiftOrAccum[0] = maskIn;

SHIFTOR_INIT:
  for (UIDX scan = 1; scan <= MSPM_UNROLL; scan++) {
#pragma HLS UNROLL
    shiftOrAccum[scan] = MSPM_BLANK_MASK;  // anything is possible
  }

SHIFTOR_SCAN:
  for (UIDX scan = 0; scan < MSPM_UNROLL; scan++) {
#pragma HLS UNROLL
    // do MSPM_UNROLL hypercan mspm checking

    PAYLOAD_WORD current = 0;  // current 8 byte being checked
    {
      // insist on little endian: older byte at smaller address
      UBYTE *byte = (UBYTE *)&(flitWords[scan]);
    SHIFTOR_ENDIAN:
      for (UIDX i = 0; i < MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
        current |= ((PAYLOAD_WORD)byte[i]) << (i * BITSINBYTE);
      }
    }

    {
    SHIFTOR_SCAN_BYTES:
      for (UIDX i = 0; i < MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
        // scan byte-by-byte
        UIDX index;  // shiftOr table index
        UBYTE byte;
        PAYLOAD_WORD shiftOrMask;           // shift or mask
        PAYLOAD_WORD lowerMask, upperMask;  // shift by byte position

#if MSPM_DEBUG_SHIFTOR
        PAYLOAD_WORD oldMaskDebug = shiftOrAccum[scan];
#endif

        // compute supercharacter for indexing
        byte = (current >> ((i)*BITSINBYTE)) & BYTEMASK;
#if MSPM_FRWD_SUPER
        if ((scan == (MSPM_UNROLL - 1)) && (i == (MSPM_MASK_WIDTH - 1))) {
          super = nextWordBytel;
        } else if (i == (MSPM_MASK_WIDTH - 1)) {
          super = ((UBYTE *)&flitWords[scan + 1])[0];
        } else {
          super = (current >> ((i + 1) * BITSINBYTE)) & BYTEMASK;
        }
#endif
        index = byte;
        index |= super << BITSINBYTE;
#if MSPM_FRWD_SUPER
        index &= ((1 << MSPM_SHIFTORF_TABLE_LGDEPTH) - 1);
#else
        index &= ((1 << MSPM_SHIFTORR_TABLE_LGDEPTH) - 1);
#endif
#if !MSPM_FRWD_SUPER
        super = byte;  // for next word
#endif
        // lookup mask
#if MSPM_FRWD_SUPER
        shiftOrMask = MSPM_SHIFTORF_TABLE[index];  // MSPM_UNROLL*MSPM_MASK_WIDTH times total
#else
        shiftOrMask = MSPM_SHIFTORR_TABLE[index];  // MSPM_UNROLL*MSPM_MASK_WIDTH times total
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

#if MSPM_DEBUG_SHIFTOR
        {
          printf("index%d=[%02x]%02x ", i, index >> BITSINBYTE, index & 255);
          // printf("%016lx ", shiftOrMask);
          printf("%016lx ", upperMask);
          printf("%016lx ", lowerMask);
          printf("%016lx::", shiftOrAccum[scan + 1]);
          printf("%016lx<-", shiftOrAccum[scan]);
          printf("%016lx\n", oldMaskDebug);
          if (i == (MSPM_MASK_WIDTH - 1)) {
            putchar('\n');
          }
        }
#endif
      }
    }
  }

  // set output values
  maskOut = shiftOrAccum[MSPM_UNROLL];
SHIFTOR_MASK:
  for (UIDX scan = 0; scan < MSPM_UNROLL; scan++) {
#pragma HLS UNROLL
    shiftOrMask[scan] = shiftOrAccum[scan];
  }

  return;
}

#define MAGIC_NUM ((ULONG)0x0b4e0ef37bc32127)
#include <mspm/multlookup.h>

// Hyperscan multiply-based hash.  We could do something better in HW.
static ULONG hsHashFxnSimOnly(ULONG lv, ULONG andmsk, ULONG nBits) {
  // We don't actually use this function in a code; the multiply is decomposed
  ULONG mult = MAGIC_NUM;

  lv &= andmsk;
  mult *= lv;
  mult >>= (64 - nBits);

  return mult;
}

/**
 * Like in Pigasus, hash table hit is checked first at full bandwidth requiring only the valid bit column to be
 * replicated for concurrent read. The full table lookup only happens for cases that hit, a much lower rate. Unlike
 * Pigasus, there is the option to add a tag column that is the xor of all bytes (Tag is computed here and checked
 * later). False positive is still possible with tagging.
 */

void mspmBitmap(                          // INPUTS
    PAYLOAD_WORD flitWords[MSPM_UNROLL],  // older byte in smaller address
    PAYLOAD_WORD pastWord,                // last word scanned, MSPM_MASK_WIDTH bytes

    // OUTPUTS
    MspmHashHit hits[MSPM_MASK_WIDTH][MSPM_MASK_WIDTH * MSPM_UNROLL],
    // for each position check pattern length 2~8 with hits[0][bytepos] for len
    // 2) and with hits[6][bytepos] for len 8) smaller bytepos is older.
    // hits[7] is for 2nd way of len 8.

    // META INFO INPUT
    [[maybe_unused]] USEQ sequence,
    [[maybe_unused]] UPOS wordCount) {  // tag output with sequence metainfo

  MY_ASSERT(MSPM_MASK_WIDTH == sizeof(PAYLOAD_WORD));  // Hyperscan unit width can't be changed.
  MY_ASSERT((flitWords[0] & ((1 << BITSINBYTE) - 1)) == (*((UBYTE *)&flitWords[0])));  // sample check little endian

  UBYTE bytes[(MSPM_UNROLL + 1) * MSPM_MASK_WIDTH];       // scan flitwords a one long byte sequence
  ULONG hashNibble[(MSPM_UNROLL + 1) * MSPM_MASK_WIDTH];  // bytes' contribution to hash

// set prefix bytes from input
BITMAP_PREFIX_POS:
  for (UIDX pos = 0; pos < MSPM_MASK_WIDTH; pos++) {
#pragma HLS UNROLL
    bytes[pos] = (pastWord >> (pos * BITSINBYTE)) & BYTEMASK;
  }
// set current flit bytes
BITMAP_CURRENT_FLIT_POS:
  for (UIDX pos = 0; pos < (MSPM_MASK_WIDTH * MSPM_UNROLL); pos++) {
#pragma HLS UNROLL
    // force little endian
    bytes[MSPM_MASK_WIDTH + pos] = ((UBYTE *)(&(flitWords[0])))[pos];
  }

BITMAP_HASH_POS:
  for (UIDX pos = 0; pos < (MSPM_MASK_WIDTH * (MSPM_UNROLL + 1)); pos++) {
#pragma HLS UNROLL
    // It was discovered for 2023, multiplying by the Magic Constant directly produces incorrect prodcut. This will not
    // work correctly on FPGA: hashNibble[pos] = bytes[pos] * MAGIC_NUM;
    hashNibble[pos] = lookupTable[bytes[pos]];
  }

  // Scan for each patterning ending by position
BITMAP_SCAN_POS:
  for (UIDX pos = 0; pos < (MSPM_MASK_WIDTH * MSPM_UNROLL); pos++) {
#pragma HLS UNROLL
    // Set first byte since for loop starts from length 2 (different from nfpm)
    PAYLOAD_WORD current = ((PAYLOAD_WORD)bytes[MSPM_MASK_WIDTH + pos]) << ((MSPM_MASK_WIDTH - 1) * BITSINBYTE);

    ULONG hashIncremental = (hashNibble[MSPM_MASK_WIDTH + pos] << ((MSPM_MASK_WIDTH - 1) * BITSINBYTE));
#if MSPM_CHECKTAG
    MSPM_TAG tagIncremental = bytes[MSPM_MASK_WIDTH + pos];
#endif

  // Scan for different length
  HASH_CHECK_PER_LENGTH:
    for (UIDX len = 2; len <= MSPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      current |= ((PAYLOAD_WORD)bytes[MSPM_MASK_WIDTH + pos - len + 1])
                 << ((MSPM_MASK_WIDTH - len) * BITSINBYTE);  // extend toward older bytes
      hashIncremental += ((hashNibble[MSPM_MASK_WIDTH + pos - len + 1]) << ((MSPM_MASK_WIDTH - len) * BITSINBYTE));

      [[maybe_unused]] MSPM_TAG tag = 0;
#if MSPM_CHECKTAG
      {
        USHORT thisByte = bytes[MSPM_MASK_WIDTH + pos - len + 1];
        [[maybe_unused]] UCHAR thisByteAtLen = (((thisByte << 8) | thisByte) >> (len - 1)) & 0xff;
#if (1)
        tagIncremental ^= thisByte;
#else
        tagIncremental ^= thisByteAtLen;
#endif
      }
      MSPM_TAG tagOneshot = 0;
      {
      HASH_CHECK_TAG_ONESHOT:
        for (UIDX i = 0; i < MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
          USHORT thisByte = (current >> (i * BITSINBYTE)) & BYTEMASK;
          [[maybe_unused]] UCHAR thisByteAtLen = (((thisByte << 8) | thisByte) >> (7 - i)) & 0xff;
#if (1)
          tagOneshot ^= thisByte;
#else
          tagOneshot ^= thisByteAtLen;
#endif
        }
        MY_ASSERT(tagOneshot == tagIncremental);
      }
      tag = tagIncremental;
      // tag=tagOneshot;
#endif

      // The bitmap table is like the valid column of the hash table, packed 8 bits to 1 bitmap table entry
      MSPM_KEY hashKey;      // hash key
      ULONG andMask;         // andMask
      UINT nBitsBmap;        // log (size of bitmap table in #entries)
      UBYTE packedHits8;     // packed hits, 8 to each entry.
                             // Inferred byte-wide memory is more efficient by bit-wide memory
      UBYTE packedHits8Alt;  // 2nd way for lenth 8

      switch (len) {
        case 2:
          nBitsBmap = MSPM_BITMAP_TABLE7_LGDEPTH;
          MY_ASSERT((MSPM_BITMAP_TABLE7_LGDEPTH + 3) == MSPM_HASH_TABLE7_LGDEPTH);
          break;
        case 3:
          nBitsBmap = MSPM_BITMAP_TABLE6_LGDEPTH;
          MY_ASSERT((MSPM_BITMAP_TABLE6_LGDEPTH + 3) == MSPM_HASH_TABLE6_LGDEPTH);
          break;
        case 4:
          nBitsBmap = MSPM_BITMAP_TABLE5_LGDEPTH;
          MY_ASSERT((MSPM_BITMAP_TABLE5_LGDEPTH + 3) == MSPM_HASH_TABLE5_LGDEPTH);
          break;
        case 5:
          nBitsBmap = MSPM_BITMAP_TABLE4_LGDEPTH;
          MY_ASSERT((MSPM_BITMAP_TABLE4_LGDEPTH + 3) == MSPM_HASH_TABLE4_LGDEPTH);
          break;
        case 6:
          nBitsBmap = MSPM_BITMAP_TABLE3_LGDEPTH;
          MY_ASSERT((MSPM_BITMAP_TABLE3_LGDEPTH + 3) == MSPM_HASH_TABLE3_LGDEPTH);
          break;
        case 7:
          nBitsBmap = MSPM_BITMAP_TABLE2_LGDEPTH;
          MY_ASSERT((MSPM_BITMAP_TABLE2_LGDEPTH + 3) == MSPM_HASH_TABLE2_LGDEPTH);
          break;
        case 8:
          nBitsBmap = MSPM_BITMAP_TABLE1_LGDEPTH;
          MY_ASSERT((MSPM_BITMAP_TABLE1_LGDEPTH + 3) == MSPM_HASH_TABLE1_LGDEPTH);
          MY_ASSERT((MSPM_BITMAP_TABLE0_LGDEPTH + 3) == MSPM_HASH_TABLE0_LGDEPTH);
          MY_ASSERT(MSPM_BITMAP_TABLE1_LGDEPTH == MSPM_BITMAP_TABLE0_LGDEPTH);
          break;
      }

      MY_ASSERT(nBitsBmap <= (MSPM_HASH_TABLE0_MAXLGDEPTH - 3));

      andMask = 0xffffffffffffffff << ((MSPM_MASK_WIDTH - len) * BITSINBYTE);
      hashKey = hashIncremental >> (64 - (nBitsBmap + LGBITSINBYTE));

      MY_ASSERT(hashKey == hsHashFxnSimOnly(current, andMask, (nBitsBmap + LGBITSINBYTE)));

      {
        switch (len) {
          case 2:
            packedHits8 = MSPM_BITMAP_TABLE7[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE7_DEPTH - 1)];
            break;
          case 3:
            packedHits8 = MSPM_BITMAP_TABLE6[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE6_DEPTH - 1)];
            break;
          case 4:
            packedHits8 = MSPM_BITMAP_TABLE5[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE5_DEPTH - 1)];
            break;
          case 5:
            packedHits8 = MSPM_BITMAP_TABLE4[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE4_DEPTH - 1)];
            break;
          case 6:
            packedHits8 = MSPM_BITMAP_TABLE3[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE3_DEPTH - 1)];
            break;
          case 7:
            packedHits8 = MSPM_BITMAP_TABLE2[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE2_DEPTH - 1)];
            break;
          case 8:
            packedHits8 = MSPM_BITMAP_TABLE1[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE1_DEPTH - 1)];
            // Note: Hyperscan uses 2 bits in shift-mask to encode length 8 patterns and to choose table 0 vs table 1.
            // Our table generation script doesn't support this; we only have 1 bit for length 8 (Should think about
            // fixing)
            break;
        }

        // Only relevant if len==8
        packedHits8Alt = MSPM_BITMAP_TABLE0[(hashKey / BITSINBYTE) & (MSPM_BITMAP_TABLE0_DEPTH - 1)];
      }

      // Onpack and select bit
      packedHits8 &= (1 << (hashKey % BITSINBYTE));
      packedHits8Alt &= (1 << (hashKey % BITSINBYTE));

      // Just checking
      MY_ASSERT(len >= 2);
      MY_ASSERT(len <= MSPM_MASK_WIDTH);

      // Set hit record
      hits[len - 2][pos].isHit = (packedHits8 != 0);

      // Hash table lookup
      hits[len - 2][pos].key = hashKey;
#if MSPM_CHECKTAG
      hits[len - 2][pos].tag = tag;
#endif

      // meta info
#if MSPM_TRACKSEQ
      hits[len - 2][pos].seq = sequence;
#endif
#if MSPM_TRACKPOS
      hits[len - 2][pos].pos = wordCount * MSPM_UNROLL * MSPM_MASK_WIDTH + pos;
#endif

      if (len == MSPM_MASK_WIDTH) {
        hits[len - 1][pos].isHit = (packedHits8Alt != 0);

        hits[len - 1][pos].key = hashKey;
#if MSPM_CHECKTAG
        hits[len - 1][pos].tag = tag;
#endif

#if MSPM_TRACKSEQ
        hits[len - 1][pos].seq = sequence;
#endif
#if MSPM_TRACKPOS
        hits[len - 1][pos].pos = wordCount * MSPM_UNROLL * MSPM_MASK_WIDTH + pos;
#endif
      }

#if MSPM_DEBUG_BITMAP
      {
        printf("Checking %016lx key=%d tag=%d pos=%d len=%d\n", current, hashKey, tag, pos, len);
        if (packedHits8) {
          printf("HIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          printf("Checking %016lx key=%d tag=%d seq=%d pos=%d len=%d\n", current, hashKey, tag, sequence,
                 wordCount * MSPM_UNROLL * MSPM_MASK_WIDTH + pos, len);
        }
        if (packedHits8Alt && (len == MSPM_MASK_WIDTH)) {
          printf("HIT (Alt8)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          printf("Checking %016lx key=%d tag=%d seq=%d pos=%d len=%d\n", current, hashKey, tag, sequence,
                 wordCount * MSPM_UNROLL * MSPM_MASK_WIDTH + pos, len);
        }
      }
#endif
    }
  }
}

void mspmHashCheck(                       // INPUTS
    PAYLOAD_WORD flitWords[MSPM_UNROLL],  // older byte in smaller address
    PAYLOAD_WORD maskIn,                  // shiftOr mask to continue checking
    PAYLOAD_WORD wordLast,                // last word scanned, MSPM_MASK_WIDTH bytes
#if MSPM_FRWD_SUPER
    UCHAR nextWordByte,  // first byte next word for future supercharacter
#endif
#if MSPM_CHECKFIELD
    FTAG ftags[MSPM_UNROLL],
#endif

    // OUTPUTS
    PAYLOAD_WORD &maskOut,                                             // shiftOr mask to continue checking later
    MspmHashHit hits[MSPM_MASK_WIDTH][MSPM_MASK_WIDTH * MSPM_UNROLL],  // hits returned

    // META INFO INPUT
    USEQ seq, UPOS wordCount) {  // meta info
#if MSPM_DEBUG_SHIFTOR || MSPM_DEBUG_BITMAP
  printf("======== seq=%d =======\n", seq);
#endif

  PAYLOAD_WORD shiftOrMask[MSPM_UNROLL];  // Shift-or accumulator
#if MSPM_USE_SHIFTOR
  // Check shift-or table
  mspmShiftOr(flitWords, maskIn,
#if MSPM_FRWD_SUPER
              nextWordByte,
#else
              (wordLast >> ((MSPM_MASK_WIDTH - 1) * BITSINBYTE)) & BYTEMASK,
#endif
              maskOut, shiftOrMask);
#else
  for (UIDX i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
    shiftOrMask[i] = 0;
  }
#endif

  // Check bitmap table
  mspmBitmap(flitWords, wordLast, hits, seq, wordCount);

  // Corroborate 2 results
HASH_CHECK_CORROBORATE_POS:
  for (UIDX pos = 0; pos < (MSPM_MASK_WIDTH * MSPM_UNROLL); pos++) {
#pragma HLS UNROLL
    PAYLOAD_WORD word = shiftOrMask[pos / MSPM_MASK_WIDTH];

#if MSPM_CHECKFIELD
    FTAG1 ftag = ((ftags[pos / MSPM_MASK_WIDTH] >> (FTAG_BITS_PER_BYTE * (pos % MSPM_MASK_WIDTH))) &
                  ((1 << FTAG_BITS_PER_BYTE) - 1));
#endif

  HASH_CHECK_PER_LENGTH:
    for (UIDX len = 2; len <= MSPM_MASK_WIDTH; len++) {
#pragma HLS UNROLL
      // check each bit (combination of pattern length and ending position)
      BOOL bit = ((word >> ((pos % MSPM_MASK_WIDTH) * BITSINBYTE + (MSPM_MASK_WIDTH - len + 1))) & 0x1) != 0;

      // Hyperscan tables use all 8 bits. Bit 0 and 1 both encode length 8; it is suppose to be used to select which 2
      // ways of the length 8 hash table.
      BOOL bitAlt = (((word >> ((pos % MSPM_MASK_WIDTH) * BITSINBYTE + (MSPM_MASK_WIDTH - (MSPM_MASK_WIDTH) /*+ 1*/))) &
                      0x1) != 0);
#if MSPM_CHECKFIELD
      hits[len - 2][pos].ftag = ftag;
      if (len == MSPM_MASK_WIDTH) {
        hits[MSPM_MASK_WIDTH - 1][pos].ftag = ftag;
      }
#endif

      if (bit) {
        // Shift-or says NO
        if (hits[len - 2][pos].isHit != 0) {
          mspmDebugMsg((char *)"shiftor cancelled bitmap", pos, len, hits[len - 2][pos], MSPM_DEBUG_BITMAP);
        }

        // Then it is a NO regarless of what the bitmap tabled said
        hits[len - 2][pos].isHit = 0;
      } else {
        // shift-or says YES then whatever bitmap table says stands
        if (!(hits[len - 2][pos].isHit)) {
          mspmDebugMsg((char *)"bitmap cancelled shiftor", pos, len, hits[len - 2][pos], MSPM_DEBUG_BITMAP);
        } else {
          mspmDebugMsg((char *)"shiftor and bitmap agree", pos, len, hits[len - 2][pos], MSPM_DEBUG_BITMAP);
        }
      }

      // The shiftor table generated by ourscript only has 1 bit for len 8.
      // Hyperscan table has separate bits control len 8 way 0 and way 1.

      if (len == MSPM_MASK_WIDTH) {
        if (bitAlt) {
          // Shift-or says NO
          if (hits[(MSPM_MASK_WIDTH)-1][pos].isHit != 0) {
            mspmDebugMsg((char *)"shiftor cancelled bitmap (Alt)", pos, (MSPM_MASK_WIDTH),
                         hits[(MSPM_MASK_WIDTH)-1][pos], MSPM_DEBUG_BITMAP);
          }

          // Then it is a NO regarless of what the bitmap tabled said
          hits[(MSPM_MASK_WIDTH)-1][pos].isHit = 0;
        } else {
          // shift-or says YES then whatever bitmap table says stands
          if (!(hits[(MSPM_MASK_WIDTH)-1][pos].isHit)) {
            mspmDebugMsg((char *)"bitmap cancelled shiftor (Alt)", pos, (MSPM_MASK_WIDTH),
                         hits[(MSPM_MASK_WIDTH)-1][pos], MSPM_DEBUG_BITMAP);
          } else {
            mspmDebugMsg((char *)"shiftor and bitmap agree (Alt)", pos, (MSPM_MASK_WIDTH),
                         hits[(MSPM_MASK_WIDTH)-1][pos], MSPM_DEBUG_BITMAP);
          }
        }
      }
    }
  }
}

void mspmHashLookupByLen(const unsigned int whichLen,          // 2~8 only
                         MspmHashHit hits[MSPM_LOOKUP_WIDTH],  // hits to look up
                         URID ridPlusOne[MSPM_LOOKUP_WIDTH],   // rule id found, 0 means invalid
                         [[maybe_unused]] USEQ seqOut[MSPM_LOOKUP_WIDTH],
                         [[maybe_unused]] UPOS posOut[MSPM_LOOKUP_WIDTH],
                         [[maybe_unused]] MSPM_TAG tagOut[MSPM_LOOKUP_WIDTH]) {
  MY_ASSERT(whichLen >= 2);
  MY_ASSERT(whichLen <= 9);  // 9 is 2nd way of length

  for (UIDX which = 0; which < MSPM_LOOKUP_WIDTH; which++) {
#pragma HLS UNROLL
    URID ridplus1;
    [[maybe_unused]] MSPM_TAG tag;
#if MSPM_CHECKFIELD
    UCHAR ftag_bmap;
#endif

    switch (whichLen) {
      case 2:
        ridplus1 = MSPM_HASH_TABLE7[hits[which].key & (MSPM_HASH_TABLE7_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE7[hits[which].key & (MSPM_HASH_TAGTABLE7_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE7[hits[which].key & (MSPM_HASH_BMAPTABLE7_DEPTH - 1)];
#endif
        break;
      case 3:
        ridplus1 = MSPM_HASH_TABLE6[hits[which].key & (MSPM_HASH_TABLE6_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE6[hits[which].key & (MSPM_HASH_TAGTABLE6_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE6[hits[which].key & (MSPM_HASH_BMAPTABLE6_DEPTH - 1)];
#endif
        break;
      case 4:
        ridplus1 = MSPM_HASH_TABLE5[hits[which].key & (MSPM_HASH_TABLE5_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE5[hits[which].key & (MSPM_HASH_TAGTABLE5_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE5[hits[which].key & (MSPM_HASH_BMAPTABLE5_DEPTH - 1)];
#endif
        break;
      case 5:
        ridplus1 = MSPM_HASH_TABLE4[hits[which].key & (MSPM_HASH_TABLE4_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE4[hits[which].key & (MSPM_HASH_TAGTABLE4_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE4[hits[which].key & (MSPM_HASH_BMAPTABLE4_DEPTH - 1)];
#endif
        break;
      case 6:
        ridplus1 = MSPM_HASH_TABLE3[hits[which].key & (MSPM_HASH_TABLE3_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE3[hits[which].key & (MSPM_HASH_TAGTABLE3_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE3[hits[which].key & (MSPM_HASH_BMAPTABLE3_DEPTH - 1)];
#endif
        break;
      case 7:
        ridplus1 = MSPM_HASH_TABLE2[hits[which].key & (MSPM_HASH_TABLE2_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE2[hits[which].key & (MSPM_HASH_TAGTABLE2_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE2[hits[which].key & (MSPM_HASH_BMAPTABLE2_DEPTH - 1)];
#endif
        break;
      case 8:
        ridplus1 = MSPM_HASH_TABLE1[hits[which].key & (MSPM_HASH_TABLE1_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE1[hits[which].key & (MSPM_HASH_TAGTABLE1_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE1[hits[which].key & (MSPM_HASH_BMAPTABLE1_DEPTH - 1)];
#endif
        break;
      case 9:  // 2nd way of length 8
        ridplus1 = MSPM_HASH_TABLE0[hits[which].key & (MSPM_HASH_TABLE0_DEPTH - 1)];
#if MSPM_CHECKTAG
        tag = MSPM_HASH_TAGTABLE0[hits[which].key & (MSPM_HASH_TAGTABLE0_DEPTH - 1)];
#endif
#if MSPM_CHECKFIELD
        ftag_bmap = MSPM_HASH_BMAPTABLE0[hits[which].key & (MSPM_HASH_BMAPTABLE0_DEPTH - 1)];
#endif
        break;
    }

#if MSPM_CHECKFIELD
    ftag_bmap &= (1 << FTAG_HOWMANY) - 1;
#endif

    if ((hits[which].isHit)
#if MSPM_CHECKTAG
#if MSPM_RESOLVE_CONFLICT
        && ((tag == hits[which].tag) || (ridplus1 & URID_CONFLICT_BIT))
#else
        && (tag == hits[which].tag)
#endif
#endif
#if MSPM_CHECKFIELD
        && (ftag_bmap & (1 << hits[which].ftag))
#endif
    ) {
      ridPlusOne[which] = ridplus1;
    } else {
      // printf("%d %d\n", tag, hits[len-2][which].tag);
      ridPlusOne[which] = 0;
    }

#if MSPM_TRACKSEQ
    seqOut[which] = hits[which].seq;
#endif

#if MSPM_TRACKPOS
    posOut[which] = hits[which].pos;
#endif

#if MSPM_CHECKTAG
    tagOut[which] = hits[which].tag;
#endif

#if MSPM_DEBUG_RID
    if (ridPlusOne[which]) {
      printf("RID(%d): len=%d:, rid+1=%d, key=%d seq=%d pos=%d\n", which, whichLen, ridPlusOne[which], hits[which].key,
             seqOut[which], posOut[which]);
    }
#endif
  }
}
