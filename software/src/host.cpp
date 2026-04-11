/******************************************************************************
MIT License

Copyright (c) 2026 Shashank Obla, Carnegie Mellon University

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
 * Executes host side code to interact with the FPGA component of RapidDetect
 *
 * This includes:
 * - Setting up DMA transfers to send test patterns to the FPGA and read results back
 * - Writing to and reading from CSR registers to control the FPGA kernels and read status
 * - Processing the results read back from the FPGA and summarizing detection results
 * - Measuring and reporting execution time and throughput of the design
 */

#include <ctime>
#include <chrono>
#include <array>
#include <fstream>
#include <iostream>
#include <vector>
#include <iomanip>
#include <limits>
#include <unistd.h>

#include <utils/types.h>
#include <rapidd_params.h>
#include <test/testbench.h>
#include <test/testinit.h>

#include <host.h>
#include <qdma_helpers.h>

#undef SKIP_PAYLOAD_WRITE
#define SKIP_PAYLOAD_WRITE (1)

#undef SKIP_RULES_WRITE
#define SKIP_RULES_WRITE (0)

// Addresses for some DRAM locations
#define A_ADDRESS (0x600ULL)
#define B_ADDRESS (0x601ULL)
#define C_ADDRESS (0x602ULL)

int main(int argc, char *argv[]) {
  unsigned int read_val = 0;

  char c2h_queue[] = C2H_QUEUE;
  char h2c_queue[] = H2C_QUEUE;
  // Using BUS, DEVICE, FUNCTION as hex strings
  unsigned int bus = strtoul(BUS, NULL, 16);
  unsigned int device = strtoul(DEVICE, NULL, 16);
  unsigned int function = strtoul(FUNCTION, NULL, 16);
  unsigned int pf = ((bus << 12) | (device << 4) | (function));

  // Reset IPs by writing to the AXI GPIO generating the reset for the RapidDetect design
  qdma_register_read(0, pf, 2, RESET_GPIO_ADDRESS, &read_val);
  std::cout << "Resetting RapidDetect..." << std::endl;
  qdma_register_write(0, pf, 2, RESET_GPIO_ADDRESS, 0x0, &read_val);
  std::cout << "After writing 0x0 to CSR 0x" << std::hex << RESET_GPIO_ADDRESS << ", CSR 0x" << RESET_GPIO_ADDRESS
            << " = 0x" << read_val << std::dec << std::endl;
  sleep(1);
  qdma_register_write(0, pf, 2, RESET_GPIO_ADDRESS, 0x1, &read_val);
  std::cout << "After writing 0x1 to CSR 0x" << std::hex << RESET_GPIO_ADDRESS << ", CSR 0x" << RESET_GPIO_ADDRESS
            << " = 0x" << read_val << std::dec << std::endl;
  std::cout << "Reset Complete" << std::endl;

  /////////////////////////////////////////////////////////////////////////////
  // Start RapidDetect
  /////////////////////////////////////////////////////////////////////////////
  std::ifstream datfile;

  // Check if trace has been provided, otherwise prepare the inbuilt test pattern
  BOOL traceInputMode = 0;
  if (argc > 1) {
    traceInputMode = 1;
  }

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
  std::cout << "\nLoading test pattern..." << std::endl;
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

  // Allocate host memory for payload results
  PayloadWritePack *payload_host;
  posix_memalign((void **)&payload_host, 64, 1024);
  if (payload_host == nullptr) {
    std::cerr << "Failed to allocate host memory for payload_host" << std::endl;
    exit(1);
  }

  // Send the test pattern to the FPGA for each HBM bundle being used (2 here)
  std::cout << "\nTransferring test pattern to FPGA..." << std::endl;
  send_data(h2c_queue, HBM_BUNDLE0_ADDRESS << 32, tpPaddedByteLen / IO_HBM_NUM_CHANNELS,
            (char *)tpPaddedPack.getChannelVector(0).data());
  send_data(h2c_queue, HBM_BUNDLE1_ADDRESS << 32, tpPaddedByteLen / IO_HBM_NUM_CHANNELS,
            (char *)tpPaddedPack.getChannelVector(1).data());

  /////////////////////////////
  // Setup the source kernel //
  /////////////////////////////

  // Write first testpattern memory address to CSR registers (HBM_BUNDLE0_ADDRESS)
  std::cout << "\nSetting up payload source kernel..." << std::endl;
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS + 0x10, 0x0, &read_val);
  std::cout << "Wrote lower 32 bits of input memory address (channel 0) to CSR 0x" << std::hex
            << (SOURCE_ADDRESS + 0x10) << " = 0x" << read_val << std::dec << std::endl;
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS + 0x14, HBM_BUNDLE0_ADDRESS, &read_val);
  std::cout << "Wrote upper 32 bits of input memory address (channel 0) to CSR 0x" << std::hex
            << (SOURCE_ADDRESS + 0x14) << " = 0x" << read_val << std::dec << std::endl;

  // Write second testpattern memory address to CSR registers (HBM_BUNDLE1_ADDRESS)
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS + 0x1C, 0x0, &read_val);
  std::cout << "Wrote lower 32 bits of input memory address (channel 1) to CSR 0x" << std::hex
            << (SOURCE_ADDRESS + 0x1C) << " = 0x" << read_val << std::dec << std::endl;
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS + 0x20, HBM_BUNDLE1_ADDRESS, &read_val);
  std::cout << "Wrote upper 32 bits of input memory address (channel 1) to CSR 0x" << std::hex
            << (SOURCE_ADDRESS + 0x20) << " = 0x" << read_val << std::dec << std::endl;

  // Write tpPaddedByteLen (count) parameter to CSR register
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS + 0x28, tpPaddedByteLen / IO_READ_BURSTSZ, &read_val);
  std::cout << "Wrote test pattern length to CSR 0x" << std::hex << (SOURCE_ADDRESS + 0x28) << " = 0x" << read_val
            << std::dec << std::endl;

  //////////////////////////////////
  // Setup the rules write kernel //
  //////////////////////////////////

  // Write trace_device memory address to CSR registers (A_ADDRESS)
  std::cout << "\nSetting up result sink kernel..." << std::endl;
  qdma_register_write(0, pf, 2, RULES_ADDRESS + 0x10, 0x0, &read_val);
  std::cout << "Wrote lower 32 bits of rule results memory address to CSR 0x" << std::hex << (RULES_ADDRESS + 0x10)
            << " = 0x" << read_val << std::dec << std::endl;
  qdma_register_write(0, pf, 2, RULES_ADDRESS + 0x14, A_ADDRESS, &read_val);
  std::cout << "Wrote upper 32 bits of rule results memory address to CSR 0x" << std::hex << (RULES_ADDRESS + 0x14)
            << " = 0x" << read_val << std::dec << std::endl;

  // Set skipWrite based on SKIP_RULES_WRITE macro
  qdma_register_write(0, pf, 2, RULES_ADDRESS + 0x1C, SKIP_RULES_WRITE ? 1 : 0, &read_val);
  std::cout << "Wrote skip flag to CSR 0x" << std::hex << (RULES_ADDRESS + 0x1C) << " = 0x" << read_val << std::dec
            << std::endl;

  // Write buffer_size parameter to CSR register
  qdma_register_write(0, pf, 2, RULES_ADDRESS + 0x24, TRACE_SIZE, &read_val);
  std::cout << "Wrote rule results size cap to CSR 0x" << std::hex << (RULES_ADDRESS + 0x24) << " = 0x" << read_val
            << std::dec << std::endl;

  ////////////////////////////////////
  // Setup the payload write kernel //
  ////////////////////////////////////

  // Write payload_sink_device memory address to CSR registers (C_ADDRESS)
  std::cout << "\nSetting up payload write kernel..." << std::endl;
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x10, 0x0, &read_val);
  std::cout << "Wrote lower 32 bits of payload sink memory address to CSR 0x" << std::hex
            << (PAYLOAD_WRITE_ADDRESS + 0x10) << " = 0x" << read_val << std::dec << std::endl;
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x14, C_ADDRESS, &read_val);
  std::cout << "Wrote upper 32 bits of payload sink memory address to CSR 0x" << std::hex
            << (PAYLOAD_WRITE_ADDRESS + 0x14) << " = 0x" << read_val << std::dec << std::endl;

  // Write count (tick counter - 1 second) parameter to CSR register
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x1C, 400000000, &read_val);
  std::cout << "Wrote tick counter limit to CSR 0x" << std::hex << (PAYLOAD_WRITE_ADDRESS + 0x1C) << " = 0x" << read_val
            << std::dec << std::endl;

  // Set skipWrite based on SKIP_PAYLOAD_WRITE macro
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x24, SKIP_PAYLOAD_WRITE ? 1 : 0, &read_val);
  std::cout << "Wrote skip flag to CSR 0x" << std::hex << (PAYLOAD_WRITE_ADDRESS + 0x24) << " = 0x" << read_val
            << std::dec << std::endl;

  // Write max_size parameter to CSR register
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x2C, 256, &read_val);
  std::cout << "Wrote payload output size cap to CSR 0x" << std::hex << (PAYLOAD_WRITE_ADDRESS + 0x2C) << " = 0x"
            << read_val << std::dec << std::endl;

  /////////////////////////
  // Run all the kernels //
  /////////////////////////

  unsigned int read_val_source = 0, read_val_sink = 0, read_val_payload = 0;
  qdma_register_read(0, pf, 2, SOURCE_ADDRESS, &read_val_source);
  qdma_register_read(0, pf, 2, RULES_ADDRESS, &read_val_sink);
  qdma_register_read(0, pf, 2, PAYLOAD_WRITE_ADDRESS, &read_val_payload);
  std::cout << "CSR 0x" << std::hex << SOURCE_ADDRESS << " = 0x" << read_val_source << ", CSR 0x" << RULES_ADDRESS
            << " = 0x" << read_val_sink << ", CSR 0x" << PAYLOAD_WRITE_ADDRESS << " = 0x" << read_val_payload
            << std::dec << std::endl;

  // Start by writing to ap_start for source and sink
  qdma_register_write(0, pf, 2, RULES_ADDRESS, 0x1, &read_val_source);
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS, 0x1, &read_val_payload);

  // Use chrono to measure execution time
  auto startTime = std::chrono::high_resolution_clock::now();
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS, 0x1, &read_val_sink);
  std::cout << "CSR 0x" << std::hex << SOURCE_ADDRESS << " = 0x" << read_val_source << ", CSR 0x" << RULES_ADDRESS
            << " = 0x" << read_val_sink << ", CSR 0x" << PAYLOAD_WRITE_ADDRESS << " = 0x" << read_val_payload
            << std::dec << std::endl;

  // Check if ap_done is high for source and sink
  std::cout << "Waiting for kernels to finish..." << std::endl;
  while (((read_val_source & 0b100) == 0) || ((read_val_sink & 0b100) == 0) || ((read_val_payload & 0b100) == 0)) {
    qdma_register_read(0, pf, 2, SOURCE_ADDRESS, &read_val_source);
    qdma_register_read(0, pf, 2, RULES_ADDRESS, &read_val_sink);
    qdma_register_read(0, pf, 2, PAYLOAD_WRITE_ADDRESS, &read_val_payload);
    // printf("CSR 0x%llx = 0x%x, CSR 0x%llx = 0x%x, CSR 0x%llx = 0x%x\n", SOURCE_ADDRESS, read_val_source,
    // RULES_ADDRESS,
    //        read_val_sink, PAYLOAD_WRITE_ADDRESS, read_val_payload);
  }
  auto endTime = std::chrono::high_resolution_clock::now();
  std::cout << std::endl;

  // Read the trace results back from the FPGA to the host
  read_data(c2h_queue, A_ADDRESS << 32, TRACE_SIZE / IO_WRITE_WIDTH * sizeof(RidBcntPack), (char *)trace_host);

  // Process test results
  std::cout << "Processing " << trace_host[0].ridBcnt[0].bcntSeq << " results..." << std::endl;
  for (UINT idx = 0; idx < trace_host[0].ridBcnt[0].bcntSeq; idx++) {
    RidBcnt ridbcnt = trace_host[idx / IO_WRITE_WIDTH + 1].ridBcnt[idx % IO_WRITE_WIDTH];

    // summarize results
    if (!SKIP_RULES_WRITE) {
      testPatternCheck(ridbcnt, idx, tpPaddedPack, tpPaddedPktOffset);
    }
  }

  // Print summarized detection results
  if (SKIP_RULES_WRITE) {
    std::cout << "\n*** NO RESULTS WRITE ON THIS TEST. ***" << std::endl;
  }
  testPatternFinish();

  // Get elapsed time in seconds
  double elapsedTime = std::chrono::duration<double>(endTime - startTime).count();
  // print execution time and read bandwidth in Gbps
  std::cout << "Execution time: " << elapsedTime * 1E3 << " ms" << std::endl;
  std::cout << "Throughput: " << 8 * (tpPaddedByteLen / 1E9) / (elapsedTime) << " Gbps" << std::endl;

  return 0;
}
