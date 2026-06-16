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
#include <string>

#include <utils/types.h>
#include <rapidd_params.h>
#include <test/testbench.h>
#include <test/testinit.h>

#include <host.h>
#include <qdma_helpers.h>
#include <dcmac_common.h>
#include <rapidd_helpers.h>

#undef SKIP_PAYLOAD_WRITE
#define SKIP_PAYLOAD_WRITE (1)

#undef SKIP_RULES_WRITE
#define SKIP_RULES_WRITE (0)

// Addresses for some DRAM locations
#define A_ADDRESS (0x600ULL)
#define B_ADDRESS (0x601ULL)
#define C_ADDRESS (0x602ULL)

char c2h_queue[] = C2H_QUEUE;
char h2c_queue[] = H2C_QUEUE;

// Using BUS, DEVICE, FUNCTION as hex strings
const unsigned int bus = strtoul(BUS, NULL, 16);
const unsigned int device = strtoul(DEVICE, NULL, 16);
const unsigned int function = strtoul(FUNCTION, NULL, 16);
const unsigned int pf = ((bus << 12) | (device << 4) | (function));

struct CmdArgs {
  double throttle = 1.0;
  char *trace_file = nullptr;
};

CmdArgs parse_arguments(int argc, char *argv[]) {
  CmdArgs args;
  for (int i = 1; i < argc; ++i) {
    std::string arg = argv[i];
    if (arg == "-f" || arg == "--file") {
      if (i + 1 < argc) {
        args.trace_file = argv[++i];
      } else {
        std::cerr << "Error: " << arg << " requires a file path argument." << std::endl;
        exit(1);
      }
    } else if (arg == "-t" || arg == "--throughput") {
      if (i + 1 < argc) {
        char *endptr = nullptr;
        args.throttle = std::strtod(argv[++i], &endptr);
        if (endptr == argv[i] || *endptr != '\0') {
          std::cerr << "Error: invalid throughput value: " << argv[i] << std::endl;
          exit(1);
        }
      } else {
        std::cerr << "Error: " << arg << " requires a fractional value argument." << std::endl;
        exit(1);
      }
    } else {
      // Fallback: check if it's a number (throttle) or string (trace_file)
      char *endptr = nullptr;
      double val = std::strtod(argv[i], &endptr);
      if (endptr != argv[i] && *endptr == '\0') {
        args.throttle = val;
      } else {
        args.trace_file = argv[i];
      }
    }
  }

  if (args.throttle < 0.0 || args.throttle > 1.0) {
    std::cerr << "Warning: throttle parameter must be between 0 and 1. Capping value." << std::endl;
    if (args.throttle < 0.0) args.throttle = 0.0;
    if (args.throttle > 1.0) args.throttle = 1.0;
  }

  return args;
}

int main(int argc, char *argv[]) {
  unsigned int read_val = 0;

  // Parse command line arguments using the helper function
  CmdArgs args = parse_arguments(argc, argv);
  double throttle = args.throttle;
  char *trace_file = args.trace_file;

  BOOL traceInputMode = 0;
  if (trace_file != nullptr) {
    traceInputMode = 1;
  }

  reset_procedure(0, pf);
  reset_procedure(1, pf);

  // Reset IPs by writing to the AXI GPIO generating the reset for the RapidDetect design
  reset_rapidd_design(pf);

  /////////////////////////////////////////////////////////////////////////////
  // Start RapidDetect
  /////////////////////////////////////////////////////////////////////////////
  std::ifstream datfile;

  // Set test pattern length and number of packets
  UINT tpPaddedByteLen;
  UINT tpNumPkt;

  if (traceInputMode) {
    // Read the trace file
    datfile.open(trace_file, std::ios::binary);
    if (!datfile.is_open()) {
      std::cerr << "Error opening file: " << trace_file << std::endl;
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

  setup_source_kernel(pf, HBM_BUNDLE0_ADDRESS, HBM_BUNDLE1_ADDRESS, tpPaddedByteLen / IO_READ_BURSTSZ);
  std::cout << "Using throttle fraction: " << throttle << " (" << (uint32_t)(throttle * THROTTLE_PERIOD_LENGTH) << "/"
            << THROTTLE_PERIOD_LENGTH << " cycles)" << std::endl;
  setup_eth_kernel(pf, (uint32_t)(throttle * THROTTLE_PERIOD_LENGTH));
  setup_rules_kernel(pf, A_ADDRESS, SKIP_RULES_WRITE, TRACE_SIZE);
  setup_payload_kernel(pf, C_ADDRESS, 400000000, SKIP_PAYLOAD_WRITE, 256);

  /////////////////////////
  // Run all the kernels //
  /////////////////////////

  float max_input_throughput = 0, max_pipeline_throughput = 0;

  uint32_t read_val_source = 0, read_val_sink = 0, read_val_payload = 0;
  uint32_t eth_stats_dropped_count = 0, eth_stats_total_count = 0, eth_stats_in_busy_count = 0,
           eth_stats_out_busy_count = 0, smsafe_stats_payload_count = 0, nfsafe_stats_payload_count = 0,
           source_stats_payload_count = 0, sink_stats_payload_count = 0, sink_stats_result_count = 0;

  uint32_t payload_done = 0, results_done = 0;

  // Set the done registers to 0 before starting the kernels
  rapidd_write_reg(pf, PAYLOAD_SINK_STATS_ADDRESS, PAYLOAD_SINK_CTRL_OFFSET, 0);
  rapidd_write_reg(pf, SINK_STATS_ADDRESS, SINK_CTRL_OFFSET, 0);

  read_val_source = rapidd_read_reg(pf, SOURCE_ADDRESS, AP_CTRL_OFFSET);
  read_val_sink = rapidd_read_reg(pf, RULES_ADDRESS, AP_CTRL_OFFSET);
  read_val_payload = rapidd_read_reg(pf, PAYLOAD_WRITE_ADDRESS, AP_CTRL_OFFSET);
  std::cout << "Kernel status before start - Source: 0x" << std::hex << read_val_source << ", Sink: 0x" << read_val_sink
            << ", Payload Write: 0x" << read_val_payload << std::dec << std::endl;

  // Start by writing to ap_start for source and sink
  read_val_source = rapidd_write_reg(pf, RULES_ADDRESS, AP_CTRL_OFFSET, 0x1);
  read_val_payload = rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, AP_CTRL_OFFSET, 0x1);

  // Use chrono to measure execution time
  auto startTime = std::chrono::high_resolution_clock::now();
  read_val_sink = rapidd_write_reg(pf, SOURCE_ADDRESS, AP_CTRL_OFFSET, 0x1);
  std::cout << "Kernel status after start - Source: 0x" << std::hex << read_val_source << ", Sink: 0x" << read_val_sink
            << ", Payload Write: 0x" << read_val_payload << std::dec << std::endl;

  // Check if ap_done is high for source and sink
  std::cout << "Waiting for kernels to finish..." << std::endl;
  while (
      // Is the source kernel running?
      ((read_val_source & 0b100) == 0) ||
      // Are all the packets that went into the system accounted for at the payload sink?
      // [BUG] Sometimes a fragment of a packet repeats into the overflow pipe, greater than lets the code complete
      (source_stats_payload_count >
       smsafe_stats_payload_count + nfsafe_stats_payload_count + sink_stats_payload_count) ||
      // Are all the packets that went into the system accounted for at the rules sink?
      (source_stats_payload_count - eth_stats_dropped_count !=
       smsafe_stats_payload_count + nfsafe_stats_payload_count + sink_stats_result_count)) {
    read_val_source = rapidd_read_reg(pf, SOURCE_ADDRESS, AP_CTRL_OFFSET);

    eth_stats_dropped_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_DROPPED_OFFSET);
    // eth_stats_total_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_TOTAL_OFFSET);
    eth_stats_in_busy_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_IN_BUSY_OFFSET);
    eth_stats_out_busy_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_OUT_BUSY_OFFSET);

    source_stats_payload_count = rapidd_read_reg(pf, SOURCE_ADDRESS, SOURCE_PAYLOAD_CNT_OFFSET);
    smsafe_stats_payload_count = rapidd_read_reg(pf, SMSAFE_STATS_ADDRESS, STATS_PAYLOAD_CNT_OFFSET);
    nfsafe_stats_payload_count = rapidd_read_reg(pf, NFSAFE_STATS_ADDRESS, STATS_PAYLOAD_CNT_OFFSET);
    sink_stats_result_count = rapidd_read_reg(pf, SINK_STATS_ADDRESS, SINK_RESULT_CNT_OFFSET);
    sink_stats_payload_count = rapidd_read_reg(pf, PAYLOAD_SINK_STATS_ADDRESS, PAYLOAD_SINK_STATS_OFFSET);

    max_input_throughput = std::max(max_input_throughput, (float)eth_stats_in_busy_count / BUSY_PERIOD_LENGTH);
    max_pipeline_throughput = std::max(max_pipeline_throughput, (float)eth_stats_out_busy_count / BUSY_PERIOD_LENGTH);

    // std::cout << "Source payload count: " << source_stats_payload_count << ", Eth dropped: " <<
    // eth_stats_dropped_count
    //           << ", Eth in busy: " << eth_stats_in_busy_count
    //           << ", Eth out busy: " << eth_stats_out_busy_count << ", SmSafe payload count: " <<
    //           smsafe_stats_payload_count
    //           << ", NfSafe payload count: " << nfsafe_stats_payload_count
    //           << ", Sink result count: " << sink_stats_result_count
    //           << ", Sink payload count: " << sink_stats_payload_count << std::endl;
  }
  auto endTime = std::chrono::high_resolution_clock::now();
  std::cout << "Stopping kernels..." << std::endl;

  // Set the done registers to 1 to stop the kernels
  rapidd_write_reg(pf, PAYLOAD_SINK_STATS_ADDRESS, PAYLOAD_SINK_CTRL_OFFSET, 1);
  rapidd_write_reg(pf, SINK_STATS_ADDRESS, SINK_CTRL_OFFSET, 1);

  // Wait for the kernels to acknowledge the stop signal and come to a halt
  while (((read_val_sink & 0b100) == 0) || ((read_val_payload & 0b100) == 0)) {
    read_val_sink = rapidd_read_reg(pf, RULES_ADDRESS, AP_CTRL_OFFSET);
    read_val_payload = rapidd_read_reg(pf, PAYLOAD_WRITE_ADDRESS, AP_CTRL_OFFSET);
  }
  std::cout << "Kernels stopped.\n" << std::endl;

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

  // Print execution time and bandwidth in Gbps
  std::cout << "\nExecution time: " << elapsedTime * 1E3 << " ms" << std::endl;
  std::ios::fmtflags f(std::cout.flags());
  std::streamsize p = std::cout.precision();
  std::cout << std::fixed << std::setprecision(2);
  std::cout << std::left << std::setw(24) << "End-to-End Throughput:" << std::right << std::setw(8)
            << 8 * (tpPaddedByteLen / 1E9) / (elapsedTime) << " Gbps" << std::endl;
  std::cout << std::left << std::setw(24) << "Ethernet Throughput:" << std::right << std::setw(8)
            << max_input_throughput * (MSPM_UNROLL * 8 * 8) * 400E6 / 1E9 << " Gbps" << std::endl;
  std::cout << std::left << std::setw(24) << "Pipeline Throughput:" << std::right << std::setw(8)
            << max_pipeline_throughput * (MSPM_UNROLL * 8 * 8) * 400E6 / 1E9 << " Gbps" << std::endl;
  std::cout << std::endl;

  // Print packet count stats
  std::cout << std::left << std::setw(30) << "Total Packets Sent:" << std::right << std::setw(10)
            << source_stats_payload_count << std::endl;
  std::cout << std::left << std::setw(30) << "Packets Dropped at Ethernet:" << std::right << std::setw(10)
            << eth_stats_dropped_count << " (" << std::right << std::setw(6)
            << 100.0f * eth_stats_dropped_count / source_stats_payload_count << "%)" << std::endl;
  std::cout << std::left << std::setw(30) << "Packets Safe after MSPM:" << std::right << std::setw(10)
            << smsafe_stats_payload_count << " (" << std::right << std::setw(6)
            << 100.0f * smsafe_stats_payload_count / source_stats_payload_count << "%)" << std::endl;
  std::cout << std::left << std::setw(30) << "Packets Safe after CPM:" << std::right << std::setw(10)
            << nfsafe_stats_payload_count << " (" << std::right << std::setw(6)
            << 100.0f * nfsafe_stats_payload_count / source_stats_payload_count << "%)" << std::endl;
  std::cout << std::left << std::setw(30) << "Packets Sent to CPU:" << std::right << std::setw(10)
            << sink_stats_payload_count << " (" << std::right << std::setw(6)
            << 100.0f * sink_stats_payload_count / source_stats_payload_count << "%)" << std::endl;
  std::cout.flags(f);
  std::cout.precision(p);

  return 0;
}
