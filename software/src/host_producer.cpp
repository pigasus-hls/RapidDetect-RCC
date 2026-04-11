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

#include <utils/types.h>
#include <rapidd_params.h>
#include <test/testbench.h>
#include <test/testinit.h>

// Shared memory includes
#include <boost/interprocess/managed_shared_memory.hpp>
#include <thread>
#include <string>

#include <bounded_buffer.h>
#include <shm_config.h>
#include <host.h>
#include <qdma_helpers.h>

#undef SKIP_PAYLOAD_WRITE
#define SKIP_PAYLOAD_WRITE (0)

#undef SKIP_RULES_WRITE
#define SKIP_RULES_WRITE (1)

// Addresses for some DRAM locations
#define A_ADDRESS (0x600ULL)
#define C_ADDRESS (0x604ULL)
#define B_ADDRESS (0x607ULL)

// Shared memory collaterals
using namespace boost::interprocess;

// Define the array type to be stored in shared memory (raw bytes)
typedef std::array<std::uint64_t, BUFFER_SIZE> array;

// Alias a bounded_buffer that uses the STL-like allocator so that allocates
// its values from the shared_memory segment
typedef bounded_buffer<array, QUEUE_SIZE> BoundedBuffer;

int main(int argc, char *argv[]) {
  // Check if trace has been provided, error out if not since this version requires a trace input to run
  BOOL traceInputMode = 0;
  if (argc > 1) {
    traceInputMode = 1;
  } else {
    std::cout << "Usage: " << argv[0] << " <trace.json> [num_threads]" << std::endl;
    exit(1);
  }

  int num_threads = THREAD_COUNT;
  if (argc == 3) {
    num_threads = std::stoi(argv[2]);
    std::cout << "Using the user provided " << num_threads << " threads" << std::endl;
  }

  // Setup shared memory

  // Remove shared memory on construction and destruction
  struct shm_remove {
    shm_remove() { shared_memory_object::remove("MySharedMemory"); }
    ~shm_remove() { shared_memory_object::remove("MySharedMemory"); }
  } remover;

  // Create a shared memory object.
  std::cout << "Creating shared memory object called \"MySharedMemory\"" << std::endl;
  managed_shared_memory segment(create_only, "MySharedMemory", (QUEUE_SIZE * sizeof(array) + 2048) * num_threads);

  // Set size
  std::cout << "Setting up " << num_threads << " BoundedBuffers, each with size " << QUEUE_SIZE << std::endl;
  std::vector<BoundedBuffer *> buffers;
  for (int i = 0; i < num_threads; ++i) {
    std::string buf_name = "BoundedBuffer" + std::to_string(i);
    BoundedBuffer *bb = segment.construct<BoundedBuffer>(buf_name.c_str())();
    buffers.push_back(bb);
  }
  sleep(5);

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

  // Allocate test pattern buffers
  StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> traceBuffer;
  UINT totalTraceSize = loadRawTraceInput(traceBuffer, argv[1]);

  // Allocate host memory for trace results
  RidBcntPack *trace_host;
  posix_memalign((void **)&trace_host, 64, TRACE_SIZE / IO_WRITE_WIDTH * sizeof(RidBcntPack));
  if (trace_host == nullptr) {
    std::cerr << "Failed to allocate host memory for trace_host" << std::endl;
    exit(1);
  }

  // Allocate host memory for payload results
  PayloadWritePack *payload_host;
  // Assume 10x reduction in total bits sent by MSPM
  posix_memalign((void **)&payload_host, 64, totalTraceSize * IO_READ_BURSTSZ / 10);
  if (payload_host == nullptr) {
    std::cerr << "Failed to allocate host memory for payload_host" << std::endl;
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

  // Write totalTraceSize (count) parameter to CSR register
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS + 0x28, totalTraceSize, &read_val);
  std::cout << "Wrote trace length to CSR 0x" << std::hex << (SOURCE_ADDRESS + 0x28) << " = 0x" << read_val << std::dec
            << std::endl;

  //////////////////////////////////
  // Setup the rules write kernel //
  //////////////////////////////////

  // Write trace_device memory address to CSR registers (A_ADDRESS)
  std::cout << "\nSetting up result sink kernel..." << std::endl;
  qdma_register_write(0, pf, 2, RULES_ADDRESS + 0x10, 0x0, &read_val);
  std::cout << "Wrote lower 32 bits of rule results memory address to CSR 0x" << std::hex << (RULES_ADDRESS + 0x10)
            << " = 0x" << read_val << std::dec << std::endl;
  qdma_register_write(0, pf, 2, RULES_ADDRESS + 0x14, B_ADDRESS, &read_val);
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

  // Write payload_sink_device memory address to CSR registers (A_ADDRESS)
  std::cout << "\nSetting up payload write kernel..." << std::endl;
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x10, 0x0, &read_val);
  std::cout << "Wrote lower 32 bits of payload sink memory address to CSR 0x" << std::hex
            << (PAYLOAD_WRITE_ADDRESS + 0x10) << " = 0x" << read_val << std::dec << std::endl;
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x14, A_ADDRESS, &read_val);
  std::cout << "Wrote upper 32 bits of payload sink memory address to CSR 0x" << std::hex
            << (PAYLOAD_WRITE_ADDRESS + 0x14) << " = 0x" << read_val << std::dec << std::endl;

  // Write count (tick counter - 10 millisecond @ 400MHz) parameter to CSR register
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x1C, 4000000, &read_val);
  std::cout << "Wrote tick counter limit to CSR 0x" << std::hex << (PAYLOAD_WRITE_ADDRESS + 0x1C) << " = 0x" << read_val
            << std::dec << std::endl;

  // Set skipWrite based on SKIP_PAYLOAD_WRITE macro
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x24, SKIP_PAYLOAD_WRITE ? 1 : 0, &read_val);
  std::cout << "Wrote skip flag to CSR 0x" << std::hex << (PAYLOAD_WRITE_ADDRESS + 0x24) << " = 0x" << read_val
            << std::dec << std::endl;

  // Write max_size parameter to CSR register
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x2C,
                      totalTraceSize * IO_READ_BURSTSZ / 10 / sizeof(PAYLOAD_WORD), &read_val);
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

  // Use chrono to measure execution time
  auto startTime = std::chrono::high_resolution_clock::now();
  // Start by writing to ap_start for source and sink
  qdma_register_write(0, pf, 2, SOURCE_ADDRESS, 0x1, &read_val_sink);
  qdma_register_write(0, pf, 2, RULES_ADDRESS, 0x1, &read_val_source);
  qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS, 0x1, &read_val_payload);

  std::cout << "CSR 0x" << std::hex << SOURCE_ADDRESS << " = 0x" << read_val_source << ", CSR 0x" << RULES_ADDRESS
            << " = 0x" << read_val_sink << ", CSR 0x" << PAYLOAD_WRITE_ADDRESS << " = 0x" << read_val_payload
            << std::dec << std::endl;

  // Check if ap_done is high for source and sink
  std::cout << "Waiting for kernels to finish..." << std::endl;

  // std::ofstream output_logfile("payload_output.log", std::ios::out | std::ios::binary);
  // if (!output_logfile.is_open()) {
  //   std::cerr << "Failed to open payload_output.log for writing" << std::endl;
  //   exit(1);
  // }

  BOOL done = false;
  int buf_idx = 0;
  uint64_t line_length = 0;
  uint64_t start_index = 0, current_index = 1;
  auto current_buffer = buffers[buf_idx]->peek_front();
  uint64_t total_bytes = 0;
  uint64_t event_index = 0;
  uint8_t currentPayloadBuffer = 0;
  uint64_t PAYLOAD_ADDRESS[] = {A_ADDRESS, C_ADDRESS};

  while (((read_val_source & 0b100) == 0) || ((read_val_sink & 0b100) == 0) || !done) {
    // If payload write kernel is "done", wait for the other kernels to finish
    if (!done) {
      // Wait for payload sink to finish
      while ((read_val_payload & 0b100) == 0) qdma_register_read(0, pf, 2, PAYLOAD_WRITE_ADDRESS, &read_val_payload);
      currentPayloadBuffer = (currentPayloadBuffer + 1) % 2;

      // Immediately start next payload write kernel on the other buffer to overlap execution and data transfer
      qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS + 0x14, PAYLOAD_ADDRESS[currentPayloadBuffer], &read_val);
      qdma_register_write(0, pf, 2, PAYLOAD_WRITE_ADDRESS, 0x1, &read_val_payload);

      // Read how many bytes were written by the payload write kernel and the done flag
      read_data(c2h_queue, PAYLOAD_ADDRESS[1 - currentPayloadBuffer] << 32, sizeof(PayloadWritePack),
                (char *)payload_host);
      done = (payload_host[0].words[0] & 0b10) >> 1;
      // Read the payload results back from the FPGA to the host
      read_data(c2h_queue, PAYLOAD_ADDRESS[1 - currentPayloadBuffer] << 32,
                (payload_host[0].words[0] >> 32) * sizeof(PAYLOAD_WORD) + 1024, (char *)payload_host);

      uint64_t payload_index = PAYLOAD_WRITE_WIDTH;
      // Transfer the data into the shared memory buffers
      while (payload_index - PAYLOAD_WRITE_WIDTH < (payload_host[0].words[0] >> 32)) {
        // If current_index exceeds buffer size, push the buffer to the queue and move to the next buffer
        if (current_index > BUFFER_SIZE - 1) {
          total_bytes += BUFFER_SIZE * sizeof(uint64_t);

          // Write line length at start index
          if (start_index < BUFFER_SIZE) {
            (*current_buffer)[start_index] = 0;
          }
          buffers[buf_idx]->push_front();
          // Move to next buffer
          buf_idx = (buf_idx + 1) % num_threads;

          // Reset reading indices to beginning of last read line
          payload_index -= line_length;

          // Reset indices for new buffer
          line_length = 0;
          start_index = 0;
          current_index = 1;
          current_buffer = buffers[buf_idx]->peek_front();
        }

        // Write payload data to current buffer and increment indices
        (*current_buffer)[current_index] =
            payload_host[payload_index / PAYLOAD_WRITE_WIDTH].words[payload_index % PAYLOAD_WRITE_WIDTH];
        line_length++;
        current_index++;
        payload_index++;

        // Print to log file character by character
        // for (int byte_idx = 0; byte_idx < 8; ++byte_idx) {
        //   char byte = (payload_host[(payload_index - 1) / PAYLOAD_WRITE_WIDTH]
        //                    .words[(payload_index - 1) % PAYLOAD_WRITE_WIDTH] >>
        //                (byte_idx * 8)) &
        //               0xFF;
        //   output_logfile << byte;
        // }

        // Check for end of line ('\n') at the MSB of the uint64_t
        if ((((*current_buffer)[current_index - 1] >> 56) & 0xFF) == '\n') {
          // Write line length at start index
          (*current_buffer)[start_index] = ((event_index & 0xFFFFFFFFULL) << 32) | (line_length & 0xFFFFFFFFULL);
          line_length = 0;
          start_index = current_index;
          current_index++;
          event_index++;
        }

        if (done && (payload_index - PAYLOAD_WRITE_WIDTH >= (payload_host[0].words[0] >> 32))) {
          // End of file reached, write final line length and break
          total_bytes += BUFFER_SIZE * sizeof(uint64_t);
          if (start_index < BUFFER_SIZE) {
            (*current_buffer)[start_index] = 0;
          }
          buffers[buf_idx]->push_front();
          break;
        }
      }
    }

    // Read the status of the source and rule result sink kernels to check if they are done
    qdma_register_read(0, pf, 2, SOURCE_ADDRESS, &read_val_source);
    qdma_register_read(0, pf, 2, RULES_ADDRESS, &read_val_sink);
  }
  auto endTime = std::chrono::high_resolution_clock::now();
  std::cout << std::endl;

  // Send sentinel (empty buffer) to each buffer to signal end
  for (int i = 0; i < num_threads; ++i) {
    auto buffer = buffers[i]->peek_front();
    (*buffer)[0] = 0;
    buffers[i]->push_front();
  }

  // Get elapsed time in seconds
  double elapsedTime = std::chrono::duration<double>(endTime - startTime).count();
  // print execution time and read bandwidth in Gbps
  std::cout << "Execution time: " << elapsedTime * 1E3 << " ms" << std::endl;
  std::cout << "Throughput: " << 8 * (totalTraceSize * IO_READ_BURSTSZ / 1E9) / (elapsedTime) << " Gbps" << std::endl;

  return 0;
}
