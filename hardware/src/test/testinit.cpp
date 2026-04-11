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

#include <test/testinit.h>
#include <test/testbench.h>

#include <filesystem>
#include <chrono>

UINT loadDefaultTestInputBuffer(UINT tpPaddedByteLen,
                                StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS,
                                              MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &tpPaddedCharPtr,
                                std::vector<UINT> &tpPaddedPktOffset) {
  // use trace in testpattern.h files for small traces
  UINT tpNumPkt = 0;

#if TEST_PREPEND7
#error "TEST_PREPEND7 is not supported in RapidDetectRaw mode"
#endif

  UINT roffset = TESTPATTOFFSET3;
  UINT woffset = 0;

  UINT realPktIdx = 0;  // Note: realPktIdx is pkt index in memory; filePktIdx is pkt idex in testpattern.h
                        // Extra packets are insert by setting TPINIT_EXTRA_PKTS
  tpPaddedPktOffset[realPktIdx] = woffset;

  for (UINT filePktIdx = 0; filePktIdx < (TESTPKTNUM3); filePktIdx++) {  // filePktIdx loop
    UIDX idx;
    for (idx = 0; idx < (testpattlen3[filePktIdx]); idx++) {
      tpPaddedCharPtr.set((woffset + idx) / IO_READ_BURSTSZ, (woffset + idx) % IO_READ_BURSTSZ,
                          testpattern3[roffset + idx]);
    }

    // packet must not be smaller than a flit (endline based splitting assumes no more than one per flit)
    for (; idx < (MSPM_UNROLL * MSPM_MASK_WIDTH); idx++) {
      // pad trailing bytes to fill flit
      tpPaddedCharPtr.set((woffset + idx) / IO_READ_BURSTSZ, (woffset + idx) % IO_READ_BURSTSZ, (uint8_t)0xFF);
    }

    tpPaddedCharPtr.set((woffset + idx) / IO_READ_BURSTSZ, (woffset + idx) % IO_READ_BURSTSZ, (uint8_t)'\n');
    tpNumPkt++;
    roffset += testpattlen3[filePktIdx];
    woffset += idx + 1;

    realPktIdx++;
    tpPaddedPktOffset[realPktIdx] = woffset;

    if (woffset >= tpPaddedByteLen) {
      printf("something is wrong.\n");
      exit(1);
    }

    if ((filePktIdx + 1) != TESTPKTNUM3) {
      for (ULONG pkt = 0; pkt < TPINIT_EXTRA_PKTS; pkt++) {
        for (ULONG idx = 0; idx < TPINIT_EXTRA_PKT_LEN; idx += MSPM_MASK_WIDTH) {
          for (ULONG widx = 0; widx < MSPM_MASK_WIDTH; widx++) {
            tpPaddedCharPtr.set((woffset + idx + widx) / IO_READ_BURSTSZ, (woffset + idx + widx) % IO_READ_BURSTSZ,
                                (TPINIT_EXTRA_PKT_PAT >> (widx * 8)) & 0xFF);
          }
        }
        tpPaddedCharPtr.set((woffset + TPINIT_EXTRA_PKT_LEN - 1) / IO_READ_BURSTSZ,
                            (woffset + TPINIT_EXTRA_PKT_LEN - 1) % IO_READ_BURSTSZ, (uint8_t)'\n');  // mark eop
        tpNumPkt++;
        woffset += TPINIT_EXTRA_PKT_LEN;

        realPktIdx++;
        tpPaddedPktOffset[realPktIdx] = woffset;
      }
    }
  }

  while (woffset % (MSPM_UNROLL * MSPM_MASK_WIDTH) != 0) {
    // pad with 0xFF
    tpPaddedCharPtr.set(woffset / IO_READ_BURSTSZ, woffset % IO_READ_BURSTSZ, (uint8_t)0xFF);
    woffset++;
  }

  for (UINT idx = woffset; idx < tpPaddedByteLen; idx += (MSPM_UNROLL * MSPM_MASK_WIDTH)) {
    for (UINT widx = 0; widx < (MSPM_UNROLL * MSPM_MASK_WIDTH); widx += MSPM_MASK_WIDTH) {
      for (UINT bidx = 0; bidx < MSPM_MASK_WIDTH; bidx++) {
        tpPaddedCharPtr.set((idx + widx + bidx) / IO_READ_BURSTSZ, (idx + widx + bidx) % IO_READ_BURSTSZ,
                            (TPINIT_EXTRA_PKT_PAT >> (bidx * 8)) & 0xFF);
      }
    }
    tpPaddedCharPtr.set((idx + MSPM_UNROLL * MSPM_MASK_WIDTH - 1) / IO_READ_BURSTSZ,
                        (idx + MSPM_UNROLL * MSPM_MASK_WIDTH - 1) % IO_READ_BURSTSZ, (uint8_t)'\n');

    tpNumPkt++;
  }

  if (TPINIT_EXTRA_PKTS) {
    printf("******** test length is %d bytes\n", woffset);
  }

  return tpNumPkt;
}

bool loadTraceTestInputBuffer(UINT &tpPaddedByteLen,
                              StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS,
                                            MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &tpPaddedCharPtr,
                              [[maybe_unused]] std::vector<UINT> &tpPaddedPktOffset, std::ifstream &datfile,
                              UINT &tpNumPkt) {
  UINT maxLen = tpPaddedByteLen;
  [[maybe_unused]] UINT maxPktNum = tpNumPkt;

  tpPaddedByteLen = 0;
  tpNumPkt = 0;

  // use file I/O for large captured input traces
  UINT woffset = 0;

  [[maybe_unused]] UINT pktNum = 0;
#if TEST_FALSE_POSITIVES
  tpPaddedPktOffset[0] = woffset;
#endif

  // datfile.read((char *)&numpkt, sizeof(numpkt));
  while (!datfile.eof() && (woffset < maxLen)) {
    std::string line;
    std::getline(datfile, line);

    for (size_t i = 0; i < line.length(); i++) {
      tpPaddedCharPtr.set(woffset / IO_READ_BURSTSZ, woffset % IO_READ_BURSTSZ, (uint8_t)line[i]);  // store as char
      woffset++;
    }
    tpPaddedCharPtr.set(woffset / IO_READ_BURSTSZ, woffset % IO_READ_BURSTSZ, (uint8_t)'\n');  // store as char
    woffset++;

    tpPaddedByteLen += line.length() + 1;  // +1 for the newline character

    tpNumPkt++;
#if TEST_FALSE_POSITIVES
    tpPaddedPktOffset[pktNum + 1] = woffset;
#endif
    pktNum++;
  }

  // Pad to fill the payload upto burst size
  tpPaddedByteLen = ((tpPaddedByteLen + IO_READ_BURSTSZ - 1) / IO_READ_BURSTSZ) * IO_READ_BURSTSZ;

  for (UINT idx = woffset; idx < tpPaddedByteLen; idx++) {
    tpPaddedCharPtr.set(idx / IO_READ_BURSTSZ, idx % IO_READ_BURSTSZ, (uint8_t)0xff);  // pad with 0xff
  }
  tpPaddedCharPtr.set((tpPaddedByteLen - 1) / IO_READ_BURSTSZ, (tpPaddedByteLen - 1) % IO_READ_BURSTSZ,
                      (uint8_t)'\n');  // mark eop
  tpNumPkt++;

  if (datfile.eof()) {
    return false;
  } else {
    return true;
  }
}

UINT loadRawTraceInput(StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS,
                                     MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> &traceBuffer,
                       std::string filename) {
  std::ifstream datfile(filename, std::ios::binary);
  if (!datfile.is_open()) {
    std::cerr << "Error opening file: " << filename << std::endl;
    return 0;
  }

  // Get file size using filesystem
  // uintmax_t fileSize = std::filesystem::file_size(filename);
  // Use traditional methods
  datfile.seekg(0, std::ios::end);
  uintmax_t fileSize = datfile.tellg();
  datfile.clear();
  datfile.seekg(0);

  traceBuffer.reserve(fileSize / IO_READ_BURSTSZ + 1024);  // Reserve space for the expected number of packets

  auto start = std::chrono::high_resolution_clock::now();

  // Read the raw trace data from the file
  size_t chars_read;
  int idx = 0;
  char *tempBuffer = new char[1024 * IO_READ_BURSTSZ];
  while (!datfile.eof()) {
    traceBuffer.resize(traceBuffer.size() + 1024);
    chars_read = datfile.read(tempBuffer, 1024 * IO_READ_BURSTSZ).gcount();

    for (size_t i = 0; i < chars_read; i++) {
      traceBuffer.set(idx + i / IO_READ_BURSTSZ, i % IO_READ_BURSTSZ, (uint8_t)tempBuffer[i]);  // store as char
    }

    idx += chars_read / IO_READ_BURSTSZ;
  }
  delete[] tempBuffer;
  chars_read = chars_read % IO_READ_BURSTSZ;  // Remaining bytes that do not form a complete RawPayloadPack

  for (size_t i = chars_read; i < IO_READ_BURSTSZ; i++) {
    traceBuffer.set(idx, i, 0xff);  // Pad remaining bytes with 0xff
  }

  traceBuffer.resize((chars_read == 0) ? idx : idx + 1);  // Resize to actual number of packets

  // If less than a flit is remaining we need to add an extra burst pack
  if (chars_read > (IO_READ_BURSTSZ - (MSPM_UNROLL * MSPM_MASK_WIDTH))) {
    traceBuffer.resize(traceBuffer.size() + 1);
    idx++;
    for (size_t i = 0; i < IO_READ_BURSTSZ; i++) {
      traceBuffer.set(idx, i, 0xff);  // Fill with 0xff
    }
  }

  traceBuffer.set(idx, IO_READ_BURSTSZ - 1, '\n');  // Mark end of packet

  datfile.close();

  auto end = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

  std::cout << "Loaded " << traceBuffer.size() * sizeof(RawPayloadPack) / 1E9 << " GB from " << filename << std::endl;
  std::cout << "Bandwidth: " << (traceBuffer.size() * sizeof(RawPayloadPack) / 1E9) / (duration.count() / 1000.0)
            << " GB/s" << std::endl;
  return traceBuffer.size();
}
