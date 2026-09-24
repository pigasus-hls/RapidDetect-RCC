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
 * Executes host side code to interact with the FPGA component of RapidDetect and communicate with Hyperscan
 *
 * This includes:
 * - Setting up shared memory and synchronization primitives to communicate with Hyperscan
 * - Setting up DMA transfers to send test patterns to the FPGA and read results back
 * - Writing to and reading from CSR registers to control the FPGA kernels and read status
 * - Reading FPGA output and writing it to the shared memory buffers for Hyperscan to consume
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

#include <utils/types.h>
#include <rapidd_params.h>
#include <test/testbench.h>
#include <test/testinit.h>

// Shared memory includes
#include <boost/interprocess/managed_shared_memory.hpp>
#include <thread>
#include <string>

#include <shm_config.h>
#include <host.h>
#include <qdma_helpers.h>
#include <rapidd_helpers.h>
#include <dcmac_common.h>

#undef SKIP_PAYLOAD_WRITE
#define SKIP_PAYLOAD_WRITE (0)

#undef SKIP_RULES_WRITE
#define SKIP_RULES_WRITE (1)

// Addresses for some DRAM locations
#define A_ADDRESS (0x600ULL)
#define C_ADDRESS (0x604ULL)
#define B_ADDRESS (0x607ULL)

char c2h_queue[] = C2H_QUEUE;
char h2c_queue[] = H2C_QUEUE;

// Using BUS, DEVICE, FUNCTION as hex strings
const unsigned int bus = strtoul(BUS, NULL, 16);
const unsigned int device = strtoul(DEVICE, NULL, 16);
const unsigned int function = strtoul(FUNCTION, NULL, 16);
const unsigned int pf = ((bus << 12) | (device << 4) | (function));

// Shared memory collaterals
using namespace boost::interprocess;

struct CmdArgs {
  double throttle = 1.0;
  char *trace_file = nullptr;
  int num_threads = THREAD_COUNT;
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
    } else if (arg == "-n" || arg == "--threads") {
      if (i + 1 < argc) {
        args.num_threads = std::stoi(argv[++i]);
      } else {
        std::cerr << "Error: " << arg << " requires an integer threads argument." << std::endl;
        exit(1);
      }
    } else {
      // Fallback: check if it's a double/float (throttle), integer (num_threads), or string (trace_file)
      char *endptr = nullptr;
      double val = std::strtod(argv[i], &endptr);
      if (endptr != argv[i] && *endptr == '\0') {
        std::string val_str = argv[i];
        if (val_str.find('.') == std::string::npos) {
          args.num_threads = (int)val;
        } else {
          args.throttle = val;
        }
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
  // Parse command line arguments using the helper function
  CmdArgs args = parse_arguments(argc, argv);
  double throttle = args.throttle;
  char *trace_file = args.trace_file;
  int num_threads = args.num_threads;

  BOOL traceInputMode = 0;
  if (trace_file != nullptr) {
    traceInputMode = 1;
  } else {
    std::cout << "Usage: " << argv[0] << " -f <trace.json> [-t throttle] [-n num_threads]" << std::endl;
    exit(1);
  }

  std::cout << "Using " << num_threads << " threads" << std::endl;

  // Setup shared memory

  // Remove shared memory on construction and destruction
  struct shm_remove {
    shm_remove() { shared_memory_object::remove("MySharedMemory"); }
    ~shm_remove() { shared_memory_object::remove("MySharedMemory"); }
  } remover;

  // Create a shared memory object.
  std::cout << "Creating shared memory object called \"MySharedMemory\"" << std::endl;
  size_t shm_size = sizeof(SharedMemoryLayout) + 1024 * 1024;
  managed_shared_memory segment(create_only, "MySharedMemory", shm_size);

  std::cout << "Setting up SharedMemoryLayout (Payload Ring: " << (PAYLOAD_RING_SIZE / (1024 * 1024))
            << " MB, Descriptor Ring: " << DESC_RING_SIZE << " slots)" << std::endl;
  SharedMemoryLayout *shm = segment.construct<SharedMemoryLayout>("SharedMemoryLayout")();
  if (!shm) {
    std::cerr << "Failed to construct SharedMemoryLayout in shared memory" << std::endl;
    exit(1);
  }

  // Initialize control block
  shm->ctrl.desc_tail = 0;
  shm->ctrl.payload_tail = 0;
  shm->ctrl.is_done = false;
  shm->ctrl.desc_head = 0;
  shm->ctrl.payload_head = 0;
  shm->ctrl.next_ticket = 0;
  shm->ctrl.retired_ticket = 0;
  for (size_t i = 0; i < MAX_INFLIGHT_CLAIMS; ++i) {
    shm->ctrl.retire_tracker[i].end_monotonic_offset = 0;
    shm->ctrl.retire_tracker[i].completed = false;
  }
  sleep(5);

  unsigned int read_val = 0;

  reset_procedure(0, pf);
  reset_procedure(1, pf);

  // Reset IPs by writing to the AXI GPIO generating the reset for the RapidDetect design
  reset_rapidd_design(pf);

  /////////////////////////////////////////////////////////////////////////////
  // Start RapidDetect
  /////////////////////////////////////////////////////////////////////////////

  // Allocate test pattern buffers
  StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> traceBuffer;
  UINT totalTraceSize = loadRawTraceInput(traceBuffer, trace_file);

  // Allocate host memory for trace results
  RidBcntPack *trace_host;
  posix_memalign((void **)&trace_host, 64, TRACE_SIZE / IO_WRITE_WIDTH * sizeof(RidBcntPack));
  if (trace_host == nullptr) {
    std::cerr << "Failed to allocate host memory for trace_host" << std::endl;
    exit(1);
  }



  // Send the test pattern to the FPGA for each HBM bundle being used (2 here) - in 0.25GB chunks
  std::cout << "\nTransferring test pattern to FPGA..." << std::endl;
  for (uint64_t offset = 0; offset < totalTraceSize * IO_READ_BURSTSZ / IO_HBM_NUM_CHANNELS; offset += (1ULL << 28)) {
    uint64_t chunkSize = std::min((1UL << 28), totalTraceSize * IO_READ_BURSTSZ / IO_HBM_NUM_CHANNELS - offset);
    send_data(h2c_queue, (HBM_BUNDLE0_ADDRESS << 32) + offset, chunkSize,
              (char *)traceBuffer.getChannelVector(0).data() + offset);
    send_data(h2c_queue, (HBM_BUNDLE1_ADDRESS << 32) + offset, chunkSize,
              (char *)traceBuffer.getChannelVector(1).data() + offset);
  }
  // send_data(h2c_queue, HBM_BUNDLE0_ADDRESS << 32, totalTraceSize * IO_READ_BURSTSZ / IO_HBM_NUM_CHANNELS,
  //           (char *)traceBuffer.getChannelVector(0).data());
  // send_data(h2c_queue, HBM_BUNDLE1_ADDRESS << 32, totalTraceSize * IO_READ_BURSTSZ / IO_HBM_NUM_CHANNELS,
  //           (char *)traceBuffer.getChannelVector(1).data());

  setup_source_kernel(pf, HBM_BUNDLE0_ADDRESS, HBM_BUNDLE1_ADDRESS, totalTraceSize);
  std::cout << "Using throttle fraction: " << throttle << " (" << (uint32_t)(throttle * THROTTLE_PERIOD_LENGTH) << "/"
            << THROTTLE_PERIOD_LENGTH << " cycles)" << std::endl;
  setup_eth_kernel(pf, (uint32_t)(throttle * THROTTLE_PERIOD_LENGTH));
  setup_rules_kernel(pf, B_ADDRESS, SKIP_RULES_WRITE, TRACE_SIZE);
  setup_payload_kernel(pf, A_ADDRESS, 4000000, SKIP_PAYLOAD_WRITE,
                       totalTraceSize * IO_READ_BURSTSZ / 10 / sizeof(PAYLOAD_WORD));

  /////////////////////////
  // Run all the kernels //
  /////////////////////////

  float max_input_throughput = 0, max_pipeline_throughput = 0;

  uint32_t read_val_source = 0, read_val_sink = 0, read_val_payload = 0;
  uint32_t eth_stats_dropped_count = 0, eth_stats_total_count = 0, eth_stats_in_busy_count = 0,
           eth_stats_out_busy_count = 0, smsafe_stats_payload_count = 0, nfsafe_stats_payload_count = 0,
           source_stats_payload_count = 0, sink_stats_payload_count = 0, sink_stats_result_count = 0;

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

  // std::ofstream output_logfile("payload_output.log", std::ios::out | std::ios::binary);
  // if (!output_logfile.is_open()) {
  //   std::cerr << "Failed to open payload_output.log for writing" << std::endl;
  //   exit(1);
  // }

  BOOL done = false;
  uint64_t total_bytes = 0;
  uint32_t event_index = 0;
  uint8_t currentPayloadBuffer = 0;
  uint64_t PAYLOAD_ADDRESS[] = {A_ADDRESS, C_ADDRESS};
  uint64_t leftover_words = 0;
  std::vector<PacketDesc> local_descs;
  local_descs.reserve(DESC_RING_SIZE);

  bool rules_stopped = false, payload_stopped = false;
  while (!rules_stopped || ((read_val_sink & 0b100) == 0) || !payload_stopped || ((read_val_payload & 0b100) == 0)) {
    // If payload write kernel is "done", wait for the other kernels to finish
    if (!done) {
      // Wait for payload sink to finish
      while ((read_val_payload & 0b100) == 0)
        read_val_payload = rapidd_read_reg(pf, PAYLOAD_WRITE_ADDRESS, AP_CTRL_OFFSET);

      // Read return status from kernel registers (num_words_written, overflow, done)
      uint32_t num_words_written = rapidd_read_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_RETURN_OFFSET);
      uint32_t return_flags = rapidd_read_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_RETURN_FLAGS_OFFSET);
      bool overflow = return_flags & 0x1;
      done = (return_flags >> 8) & 0x1;
      if (overflow) {
        std::cerr << "Payload write kernel overflow detected!" << std::endl;
      }

      currentPayloadBuffer = (currentPayloadBuffer + 1) % 2;

      // Immediately start next payload write kernel on the other buffer to overlap execution and data transfer
      if (!done) {
        rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_ADDR_H_OFFSET, PAYLOAD_ADDRESS[currentPayloadBuffer]);
        read_val_payload = rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, AP_CTRL_OFFSET, 0x1);
      }

      // Read the payload results directly into shared memory (zero-copy)
      if (num_words_written > 0) {
        uint64_t burst_bytes = num_words_written * sizeof(PAYLOAD_WORD);
        uint64_t max_descriptors = (burst_bytes + MIN_PACKET_SIZE - 1) / MIN_PACKET_SIZE;
        uint64_t leftover_bytes = leftover_words * sizeof(uint64_t);

        uint64_t write_offset = 0;
        uint32_t burst_monotonic_start = 0;

        // 1. Reserve slice under mutex (held only for microseconds!)
        {
          boost::unique_lock<boost::interprocess::interprocess_mutex> lock(shm->ctrl.mutex);
          shm->ctrl.not_full.wait(lock, [&]() {
            uint64_t in_flight_desc = shm->ctrl.desc_tail - shm->ctrl.desc_head;
            uint64_t in_flight_bytes = shm->ctrl.payload_tail - shm->ctrl.payload_head;
            uint64_t cur_offset = shm->ctrl.payload_tail % PAYLOAD_RING_SIZE;
            uint64_t pad = (cur_offset + burst_bytes > PAYLOAD_RING_SIZE)
                               ? (PAYLOAD_RING_SIZE - cur_offset + leftover_bytes)
                               : 0;
            return (in_flight_desc + max_descriptors <= DESC_RING_SIZE) &&
                   (in_flight_bytes + burst_bytes + pad <= PAYLOAD_RING_SIZE);
          });

          // Non-splitting ring wrap: if burst would cross PAYLOAD_RING_SIZE, pad and wrap to 0
          write_offset = shm->ctrl.payload_tail % PAYLOAD_RING_SIZE;
          if (write_offset + burst_bytes > PAYLOAD_RING_SIZE) {
            uint64_t pad_bytes = PAYLOAD_RING_SIZE - write_offset;
            if (leftover_words > 0) {
              uint64_t old_leftover_offset =
                  (write_offset + PAYLOAD_RING_SIZE - leftover_bytes) % PAYLOAD_RING_SIZE;
              std::memcpy(&shm->payload[0], &shm->payload[old_leftover_offset], leftover_bytes);
            }
            shm->ctrl.payload_tail += (pad_bytes + leftover_bytes);
            write_offset = leftover_bytes;
          }

          burst_monotonic_start = shm->ctrl.payload_tail;
          shm->ctrl.payload_tail += burst_bytes;
        } // Unlock mutex! Consumers can claim and retire concurrently during PCIe DMA!

        // 2. Direct DMA into shared memory ring buffer! (Lock-free PCIe DMA)
        read_data(c2h_queue, PAYLOAD_ADDRESS[1 - currentPayloadBuffer] << 32,
                  burst_bytes, (char *)&shm->payload[write_offset]);
        total_bytes += burst_bytes;

        // 3. Flit-stride boundary scan in-place directly on shm->payload (Lock-free)
        local_descs.clear();
        const uint64_t *burst_words = reinterpret_cast<const uint64_t *>(&shm->payload[write_offset]);
        uint64_t pkt_start_word = 0;
        for (uint64_t w = PAYLOAD_WRITE_WIDTH - 1; w < num_words_written; w += PAYLOAD_WRITE_WIDTH) {
          uint64_t word_val = burst_words[w];
          if (((word_val >> 56) & 0xFF) == '\n') {
            uint32_t pkt_len_words = (w + 1) - pkt_start_word + leftover_words;
            uint32_t pkt_len_bytes = pkt_len_words * sizeof(uint64_t);
            uint32_t pkt_offset = (write_offset + pkt_start_word * sizeof(uint64_t) + PAYLOAD_RING_SIZE -
                                   leftover_bytes) %
                                  PAYLOAD_RING_SIZE;
            uint32_t pkt_monotonic_end = burst_monotonic_start + (w + 1) * sizeof(uint64_t);

            local_descs.push_back({
                .offset = pkt_offset,
                .length = pkt_len_bytes,
                .event_index = event_index++,
                .monotonic_end = pkt_monotonic_end
            });
            pkt_start_word = w + 1;
            leftover_words = 0;
            leftover_bytes = 0;
          }
        }
        leftover_words += (num_words_written - pkt_start_word);

        // 4. Publish descriptors and notify consumers under mutex (brief microsecond critical section)
        if (!local_descs.empty()) {
          boost::unique_lock<boost::interprocess::interprocess_mutex> lock(shm->ctrl.mutex);
          for (const auto &d : local_descs) {
            shm->descriptors[shm->ctrl.desc_tail % DESC_RING_SIZE] = d;
            shm->ctrl.desc_tail++;
          }
          shm->ctrl.not_empty.notify_all();
        }
      }
    }

    // Read the status of the source,  rule result sink and payload write kernels to check if they are done
    read_val_source = rapidd_read_reg(pf, SOURCE_ADDRESS, AP_CTRL_OFFSET);
    read_val_sink = rapidd_read_reg(pf, RULES_ADDRESS, AP_CTRL_OFFSET);
    read_val_payload = rapidd_read_reg(pf, PAYLOAD_WRITE_ADDRESS, AP_CTRL_OFFSET);

    eth_stats_dropped_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_DROPPED_OFFSET);
    eth_stats_in_busy_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_IN_BUSY_OFFSET);
    eth_stats_out_busy_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_OUT_BUSY_OFFSET);
    uint32_t eth_stats_total_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_TOTAL_OFFSET);
    uint32_t overflow_error_count = rapidd_read_reg(pf, ETH_STATS_ADDRESS, ETH_STATS_ERROR_OFFSET);
    uint16_t overflow_error_local[2] = {overflow_error_count >> 16, overflow_error_count & 0xFFFF};

    if (overflow_error_count) {
      std::cerr << "\033[31m[ERROR] Overflow error detected in Ethernet kernel!\033[0m\n\033[31m[ERROR] Reduce "
                   "throttle rate for correctness.\033[0m"
                << std::endl;
      exit(1);
    }

    source_stats_payload_count = rapidd_read_reg(pf, SOURCE_ADDRESS, SOURCE_PAYLOAD_CNT_OFFSET);
    smsafe_stats_payload_count = rapidd_read_reg(pf, SMSAFE_STATS_ADDRESS, STATS_PAYLOAD_CNT_OFFSET);
    nfsafe_stats_payload_count = rapidd_read_reg(pf, NFSAFE_STATS_ADDRESS, STATS_PAYLOAD_CNT_OFFSET);
    sink_stats_result_count = rapidd_read_reg(pf, SINK_STATS_ADDRESS, SINK_RESULT_CNT_OFFSET);
    sink_stats_payload_count = rapidd_read_reg(pf, PAYLOAD_SINK_STATS_ADDRESS, PAYLOAD_SINK_STATS_OFFSET);

    max_input_throughput = std::max(max_input_throughput, (float)eth_stats_in_busy_count / BUSY_PERIOD_LENGTH);
    max_pipeline_throughput = std::max(max_pipeline_throughput, (float)eth_stats_out_busy_count / BUSY_PERIOD_LENGTH);

    // std::cout << "Source payload count: " << source_stats_payload_count << ", Eth dropped: " <<
    // eth_stats_dropped_count
    //           << ", Eth in busy: " << eth_stats_in_busy_count << ", Eth out busy: " << eth_stats_out_busy_count
    //           << ", Eth total: " << eth_stats_total_count
    //           << ", Eth overflow errors: [" << overflow_error_local[0] << ", " << overflow_error_local[1] << "]"
    //           << ", SmSafe payload count: " << smsafe_stats_payload_count
    //           << ", NfSafe payload count: " << nfsafe_stats_payload_count
    //           << ", Sink result count: " << sink_stats_result_count
    //           << ", Sink payload count: " << sink_stats_payload_count << std::endl;

    // Are all the packets that went into the system accounted for at the payload sink?
    // [BUG] Sometimes a fragment of a packet repeats into the overflow pipe, greater than lets the code complete
    if (!payload_stopped && ((read_val_source & 0b100) != 0) &&
        (source_stats_payload_count <=
         smsafe_stats_payload_count + nfsafe_stats_payload_count + sink_stats_payload_count)) {
      std::cout << "Stopping payload write kernel..." << std::endl;
      rapidd_write_reg(pf, PAYLOAD_SINK_STATS_ADDRESS, PAYLOAD_SINK_CTRL_OFFSET, 1);
      payload_stopped = true;
    }

    // Are all the packets that went into the system accounted for at the rules sink?
    if (!rules_stopped && ((read_val_source & 0b100) != 0) &&
        (source_stats_payload_count - eth_stats_dropped_count ==
         smsafe_stats_payload_count + nfsafe_stats_payload_count + sink_stats_result_count)) {
      std::cout << "Stopping rules kernel..." << std::endl;
      rapidd_write_reg(pf, SINK_STATS_ADDRESS, SINK_CTRL_OFFSET, 1);
      rules_stopped = true;
    }
  }
  auto endTime = std::chrono::high_resolution_clock::now();
  std::cout << "Kernels stopped.\n" << std::endl;

  // Signal termination to all consumer worker threads
  {
    boost::unique_lock<boost::interprocess::interprocess_mutex> lock(shm->ctrl.mutex);
    shm->ctrl.is_done = true;
    shm->ctrl.not_empty.notify_all();
  }

  // Get elapsed time in seconds
  double elapsedTime = std::chrono::duration<double>(endTime - startTime).count();

  // Print execution time and bandwidth in Gbps
  std::cout << "\nExecution time: " << elapsedTime * 1E3 << " ms" << std::endl;
  std::ios::fmtflags f(std::cout.flags());
  std::streamsize p = std::cout.precision();
  std::cout << std::fixed << std::setprecision(2);
  std::cout << std::left << std::setw(24) << "End-to-End Throughput:" << std::right << std::setw(8)
            << 8 * (totalTraceSize * IO_READ_BURSTSZ / 1E9) / (elapsedTime) << " Gbps" << std::endl;
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
            << (source_stats_payload_count > 0 ? 100.0f * eth_stats_dropped_count / source_stats_payload_count : 0.0f)
            << "%)" << std::endl;
  std::cout << std::left << std::setw(30) << "Packets Safe after MSPM:" << std::right << std::setw(10)
            << smsafe_stats_payload_count << " (" << std::right << std::setw(6)
            << (source_stats_payload_count > 0 ? 100.0f * smsafe_stats_payload_count / source_stats_payload_count
                                               : 0.0f)
            << "%)" << std::endl;
  std::cout << std::left << std::setw(30) << "Packets Safe after CPM:" << std::right << std::setw(10)
            << nfsafe_stats_payload_count << " (" << std::right << std::setw(6)
            << (source_stats_payload_count > 0 ? 100.0f * nfsafe_stats_payload_count / source_stats_payload_count
                                               : 0.0f)
            << "%)" << std::endl;
  std::cout << std::left << std::setw(30) << "Packets Sent to CPU:" << std::right << std::setw(10)
            << sink_stats_payload_count << " (" << std::right << std::setw(6)
            << (source_stats_payload_count > 0 ? 100.0f * sink_stats_payload_count / source_stats_payload_count : 0.0f)
            << "%)" << std::endl;
  std::cout.flags(f);
  std::cout.precision(p);

  return 0;
}
