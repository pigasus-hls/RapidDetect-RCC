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

/// HLS Simulation Testbench

#include <array>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <chrono>
#include <thread>

#include <utils/types.h>

#include <rapidd_params.h>

#include <test/testbench.h>
#include <test/testinit.h>

#include <test/testbench_kernel.h>

//////////////////////////////////////////////////////////////////////////////
// IO Size Definitions
//////////////////////////////////////////////////////////////////////////////

// a kludge to increase trace buffer size to avoid wrap around
#ifndef TRACE_SIZE_SCALE
#define TRACE_SIZE_SCALE (64)
#endif
#define TRACE_SIZE (((1 << 16 /*magic value*/) * MSPM_MASK_WIDTH * MSPM_LOOKUP_WIDTH) * TRACE_SIZE_SCALE)

int main([[maybe_unused]] int argc, [[maybe_unused]] char **argv) {
  BOOL traceInputMode = 0;

  // Check if trace has been provided, otherwise prepare the inbuilt test pattern
  if (argc == 1) {
    traceInputMode = false;
  } else if (argc >= 2) {
    traceInputMode = true;
  } else {
    std::cerr << "Usage: " << argv[0] << " <testpattern_trace.dat>" << std::endl;
    exit(1);
  }

  std::ifstream datfile;

  // Set test pattern length and number of packets
  UINT tpPaddedByteLen;
  UINT tpNumPkt;

  if (traceInputMode) {
    // Read the trace file
    datfile.open(argv[1], std::ios::binary);
    if (!datfile.is_open()) {
      std::cerr << "Error opening file: " << argv[1] << std::endl;
      exit(1);
    }

    {
      UINT len, numpkt;

      datfile.ignore(std::numeric_limits<std::streamsize>::max());
      len = datfile.gcount();
      datfile.clear();
      datfile.seekg(0, std::ios::beg);

      numpkt = len / (MSPM_UNROLL * MSPM_MASK_WIDTH);  // worst case number of packets

      tpPaddedByteLen = ((len + IO_READ_BURSTSZ - 1) / IO_READ_BURSTSZ) * IO_READ_BURSTSZ;
      tpNumPkt = numpkt;

      std::cout << "Test pattern length: " << len << " bytes, number of packets: " << numpkt << std::endl;
    }
  } else {
    // this is a little fragile, tpPaddedByteLen just needs to be big enough here
    tpPaddedByteLen = (((((long)TESTPATTLEN3) + (2 * ((long)TESTPKTNUM3) * (MSPM_UNROLL * MSPM_MASK_WIDTH)) +
                         TESTPKTNUM3 + TESTPKTNUM3 * TPINIT_EXTRA_PKTS * TPINIT_EXTRA_PKT_LEN) /
                        IO_READ_BURSTSZ) *
                           IO_READ_BURSTSZ +
                       IO_READ_BURSTSZ);
    tpNumPkt = TESTPKTNUM3;
  }

  // Allocate test pattern buffers
  StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> tpPaddedPack(
      tpPaddedByteLen / IO_READ_BURSTSZ);

  // This is used by the test pattern check function and is unrelated to the FPGA operation
  std::vector<UINT> tpPaddedPktOffset(tpPaddedByteLen / (MSPM_UNROLL * MSPM_MASK_WIDTH));
  for (UINT line = 0; line < tpPaddedByteLen / (MSPM_UNROLL * MSPM_MASK_WIDTH); line++) {
    tpPaddedPktOffset[line] = 0;
  }

  // Load the test pattern
  if (traceInputMode) {
    if (loadTraceTestInputBuffer(tpPaddedByteLen, tpPaddedPack, tpPaddedPktOffset, datfile, tpNumPkt)) {
      std::cout << "IO Buffers not large enough to hold the trace file." << std::endl;
      exit(1);
    }
  } else {
    tpNumPkt = loadDefaultTestInputBuffer(tpPaddedByteLen, tpPaddedPack, tpPaddedPktOffset);
  }

  // Allocate host memory for trace results
  RidBcntPack *trace_host;
  posix_memalign((void **)&trace_host, 64, TRACE_SIZE / IO_WRITE_WIDTH * sizeof(RidBcntPack));
  if (trace_host == nullptr) {
    std::cerr << "Failed to allocate host memory for trace_host" << std::endl;
    exit(1);
  }

  // Launch testbench kernel
  testbench_kernel(tpPaddedPack.getChannelVector(0).data(),
                   IO_HBM_NUM_CHANNELS > 1 ? tpPaddedPack.getChannelVector(1).data() : nullptr, trace_host,
                   tpPaddedByteLen / IO_READ_BURSTSZ, TEST_SKIP_WRITE, TRACE_SIZE / IO_WRITE_WIDTH);

  // Process test results
  for (UINT idx = 0; idx < trace_host[0].ridBcnt[0].bcntSeq; idx++) {
    RidBcnt ridbcnt = trace_host[idx / IO_WRITE_WIDTH + 1].ridBcnt[idx % IO_WRITE_WIDTH];

    // Summarize results
    if (!TEST_SKIP_WRITE) {
      testPatternCheck(ridbcnt, idx, tpPaddedPack, tpPaddedPktOffset);
    }
  }

  // Print summarized detection results
  if (TEST_SKIP_WRITE) {
    printf("\n\n*** NO RESULTS WRITE ON THIS TEST. ***\n\n");
  }
  testPatternFinish();

  return 0;
}
