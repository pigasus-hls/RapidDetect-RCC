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

#include <utils/types.h>
#include <utils/my_assert.h>
#include <mspm/sm_tables.h>

#include <mspm/mspm_params.h>
#include <sm_params.h>

#include <test/testbench.h>

#include <iostream>

// Summary results counters
UINT seenNumTimes[TABLE_NUM_RID] = {};
UINT bcntLastSeen[TABLE_NUM_RID] = {};
UINT cntByLen[MSPM_MASK_WIDTH] = {};
UINT falseCntByLen[MSPM_MASK_WIDTH] = {};

UINT rawRid = 0;
UINT overloadedRid = 0;
UINT expandedRid = 0;
UINT matchedRid = 0;

char get_byte(
    StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &pktBuff,
    UINT idx) {
  return pktBuff.get(idx / IO_READ_BURSTSZ, idx % IO_READ_BURSTSZ);
}

// Check detection against orginal source buffer for false positives.
// Requires detection position to be tracked (MSMP_TRACKPOS=1).
template <typename T>
void checkFalsePositives(URID rid,     // rid of detection
                         USHORT bcnt,  // which packet
                         UPOS pos,     // position in packet
                         StripedVector<T, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS>
                             &pktBuff,                 // packet buffer
                         std::vector<UINT> &pktOffset  // packet offsets
) {
  [[maybe_unused]] unsigned int sid = rid2sid_table[rid];
  unsigned long long fp = rid2fp_table[rid];
  unsigned int len = rid2fplen_table[rid];

  BOOL falsePositive = false;

  if ((((signed int)pktOffset[bcnt]) - (signed int)len + pos + 1) >= 0) {
    // printf("rid=%d sid=%d bcnt=%d pos=%d len=%d offset=%d", rid, sid, bcnt, pos, len, pktOffset[bcnt]-len+pos+1);

    for (UINT i = 0; i < len; i++) {
      char thisChar = ((char)(fp >> (8 * (len - i - 1))) & 0xff);
      char srcChar = get_byte(pktBuff, pktOffset[bcnt] + pos + 1 - len + i);

#if NOCASE
      if ((srcChar >= 'a') && (srcChar <= 'z')) {
        srcChar += ('A' - 'a');
      }
#endif

      // printf("(%2x|%2x|%2x)", thisChar, srcChar, patt[i]);
      if (thisChar != srcChar) {
        falsePositive = true;
      }
    }
  } else {
    // hashtable-only MSPM can generate absurd matches
    falsePositive = true;
  }

  if (falsePositive) {
    // printf(" -- false positive");
    falseCntByLen[len - 2]++;
  }
}

// Print to screen full details for detections for debugging
void testPatternPrintFull(RidBcnt ridBcnt, [[maybe_unused]] UINT tidx) {
  // display result trace
  if (ridBcnt.ridPlusOne) {
    std::cout << "Detected rid+1=" << ridBcnt.ridPlusOne;
#if MSPM_TRACKSEQ
    std::cout << " seq=" << ridBcnt.bcntSeq;
#else
    std::cout << " bcnt=" << ridBcnt.bcntSeq;
#endif
#if MSPM_TRACKPOS
    std::cout << " pos=" << ridBcnt.pos - (TEST_PREPEND7 ? (MSPM_MASK_WIDTH - 1) : 0);
#endif

    // display extra details
    {
      URID ridPlusOne = ridBcnt.ridPlusOne;
      URID rid = ridPlusOne - 1;
#if MSPM_RESOLVE_CONFLICT
      if (ridPlusOne & URID_CONFLICT_BIT) {
        URID cidx = (ridPlusOne & (~URID_CONFLICT_BIT));
        rid = collision_table_ridlist[collision_table_offset[cidx]];  // first one
        std::cout << " *";
      }
#endif
      std::cout << " len=" << rid2fplen_table[rid];

#if TEST_SHOW_IOX
      std::cout << " slot=" << tidx % IO_WRITE_WIDTH;
      std::cout << " batch=" << tidx / IO_WRITE_WIDTH;
      std::cout << " idx=" << tidx;
#endif
    }
    std::cout << "\n";
  }
}

// Register detection result in trace buffer
template <typename T>
void testPatternCheck(RidBcnt ridBcnt,             // detection entry
                                                   // data accumulation
                      [[maybe_unused]] UINT tidx,  // position in trace buffer
                                                   // data accumulation for fales positive
                      // checking; only works if positions are
                      // tracked
                      [[maybe_unused]] StripedVector<T, IO_HBM_NUM_CHANNELS,
                                                     MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &pktBuff,
                      [[maybe_unused]] std::vector<UINT> &pktOffset) {
#if TEST_FULL_TRACE
  testPatternPrintFull(ridBcnt, tidx);
#endif

  if (ridBcnt.ridPlusOne) {  // if valid entry

#if MSPM_RESOLVE_CONFLICT
    // conflict list ID and mode enabled
    rawRid++;

    if (ridBcnt.ridPlusOne & URID_CONFLICT_BIT) {  // if an overloaded RID
      URID cidx = (ridBcnt.ridPlusOne & (~URID_CONFLICT_BIT));
      assert(cidx < COLLISION_TABLE_SIZE);
      UIDX offset = collision_table_offset[cidx];

      overloadedRid++;

      // scan through possible corresponding rules
      for (UIDX k = 0; k < collision_table_inc[cidx]; k++) {
        URID rid = collision_table_ridlist[offset + k];
        assert((offset + k) < COLLISION_TABLE_NUMRULES);
        assert(rid < TABLE_NUM_RID);

        expandedRid++;

        if (1
#if MSPM_CHECKTAG && !SM_EXPAND_OVERLOADED
            && (ridBcnt.tag == collision_table_taglist[offset + k])
#endif
        ) {
          // if match found
          seenNumTimes[rid]++;
          bcntLastSeen[rid] = ridBcnt.bcntSeq;
          cntByLen[rid2fplen_table[rid] - 2]++;
          matchedRid++;
#if MSPM_TRACKPOS && TEST_FALSE_POSITIVES
          checkFalsePositives(rid, ridBcnt.bcntSeq, ridBcnt.pos, pktBuff, pktOffset);
#endif
        }
      }
    }  // if an overloaded RID
    else
#endif
    {  // normal RID
      MY_ASSERT(ridBcnt.ridPlusOne <= TABLE_NUM_RID);
      seenNumTimes[ridBcnt.ridPlusOne - 1]++;
      bcntLastSeen[ridBcnt.ridPlusOne - 1] = ridBcnt.bcntSeq;
      cntByLen[rid2fplen_table[ridBcnt.ridPlusOne - 1] - 2]++;
#if MSPM_TRACKPOS && TEST_FALSE_POSITIVES
      checkFalsePositives(ridBcnt.ridPlusOne - 1, ridBcnt.bcntSeq, ridBcnt.pos, pktBuff, pktOffset);
#endif
    }  // normal RID
  }
}  // if valid entry

// Instantiate template for RawPayloadPack
template void testPatternCheck<RawPayloadPack>(
    RidBcnt ridBcnt, UINT tidx,
    StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &pktBuff,
    std::vector<UINT> &pktOffset);

// Dump test results
void testPatternFinish() {
  UINT i;

  mspmPrintParameters();
  smPrintParameters();

  // sm2nfPrintParameters();

  // nfpmPrintParameters();
  // nfPrintParameters();

  // nf2hostPrintParameters();

  ioPrintParameters();
  rapiddPrintParameters();

  std::cout << "NOCASE = " << NOCASE << "\n"
            << "TEST_PREPEND7 = " << TEST_PREPEND7 << "\n"
            << "TEST_SAMEFLOW = " << TEST_SAMEFLOW << "\n";

  std::cout << "DFLT_PIPE_DEPTH = " << DFLT_PIPE_DEPTH << "\n";

#if !SKIP_RULES_WRITE
  {
    int total = 0;
    [[maybe_unused]] int falseTotal = 0;
    for (int len = 2; len <= MSPM_MASK_WIDTH; len++) {
#if MSPM_TRACKPOS
      printf("Rules Encountered len%d: %d (false %d, %f percent)\n", len, cntByLen[len - 2], falseCntByLen[len - 2],
             100.0 * falseCntByLen[len - 2] / cntByLen[len - 2]);
#else
      printf("Rules Encountered len%d: %d\n", len, cntByLen[len - 2]);
#endif
      total += cntByLen[len - 2];
      falseTotal += falseCntByLen[len - 2];
    }
    printf("Rules Encountered: %d\n", total);
#if MSPM_TRACKPOS
    printf("False %d, %f percent\n", falseTotal, 100.0 * falseTotal / total);
#endif
#if MSPM_RESOLVE_CONFLICT && !SM_EXPAND_OVERLOADED
    printf("Num of Overloaded Rid: %d\n", overloadedRid);
    printf("Num of Expanded Rid: %d\n", expandedRid);
    printf("Num of Matched Rid: %d\n", matchedRid);
    printf("Num of Raw Rid: %d\n", rawRid);
    printf("%d\n", rawRid - overloadedRid + matchedRid);
#endif
  }

  printf("missing [");
  for (i = 0; i < TABLE_NUM_RID; i++) {
    if (!seenNumTimes[i]) {
      printf("%d, ", i);
    }
  }
  printf("]\n");

  for (i = 0; i < TABLE_NUM_RID; i++) {
    if (!seenNumTimes[i]) {
      printf("missing %d\n", i);
    }
  }

  for (i = 0; i < TABLE_NUM_RID; i++) {
    // printf("seen rule %d pattern %d times\n", i, seenNumTimes[i]);
  }

  for (i = 0; i < TABLE_NUM_RID; i++) {
    // printf("seen rid=%d::sid=%d pattern [%4d] times at block [%4d]\n", i, rid2sid_table[i], seenNumTimes[i],
    // bcntLastSeen[i]);
    printf("seen rid=%d::sid=%d (len=%d) pattern [%4d] times at block [%4d]\n", i, rid2sid_table[i], rid2fplen_table[i],
           seenNumTimes[i], bcntLastSeen[i]);
  }
#endif
}
