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

#include <boost/interprocess/managed_shared_memory.hpp>
#include <chrono>
#include <thread>
#include <cstdint>
#include <atomic>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <bounded_buffer.h>
#include <shm_config.h>
#include <array>
#include <hs.h>

struct MatchContext {
  const char* data;
  size_t length;
  size_t event_index;
  uint64_t tid;
};

std::vector<std::ofstream> detections;

// Callback function for pattern matches
static int onMatch(unsigned int id, unsigned long long from, unsigned long long to, unsigned int flags, void* context) {
  MatchContext* ctx = (MatchContext*)context;
  std::string matched(ctx->data + from, ctx->data + to);
  detections[ctx->tid] << ctx->event_index << "\n" << std::string(ctx->data, ctx->length);
  // std::cout << "Pattern " << id << " matched \"" << matched << "\" at offset "
  //    << from << "-" << to << std::endl;
  return 0;
}

// Define the array type to be stored in shared memory (raw bytes)
typedef std::array<std::uint64_t, BUFFER_SIZE> array;

typedef bounded_buffer<array, QUEUE_SIZE> BoundedBuffer;

int main(int argc, char* argv[]) {
  if (argc < 2 || argc > 3) {
    std::cerr << "Usage: " << argv[0] << " <database_file> [num_threads]" << std::endl;
    return 1;
  }

  int num_threads = THREAD_COUNT;
  if (argc == 3) {
    num_threads = std::stoi(argv[2]);
    if (num_threads < 1) num_threads = 1;
  }

  // Load the serialized database
  FILE* f = std::fopen(argv[1], "rb");
  if (!f) {
    std::cerr << "Failed to open database file" << std::endl;
    return 1;
  }
  std::fseek(f, 0, SEEK_END);
  size_t size = std::ftell(f);
  std::fseek(f, 0, SEEK_SET);
  char* bytes = new char[size];
  if (std::fread(bytes, 1, size, f) != size) {
    std::cerr << "Failed to read database file" << std::endl;
    std::fclose(f);
    delete[] bytes;
    return 1;
  }
  std::fclose(f);

  hs_database_t* db;
  hs_error_t err = hs_deserialize_database(bytes, size, &db);
  delete[] bytes;
  if (err != HS_SUCCESS) {
    std::cerr << "Failed to deserialize database" << std::endl;
    return 1;
  }

  using clock = std::chrono::steady_clock;
  clock::time_point t1, t2;

  std::cout << "Opening shared memory object \"MySharedMemory\"" << std::endl;
  boost::interprocess::managed_shared_memory segment(boost::interprocess::open_only, "MySharedMemory");
  std::vector<BoundedBuffer*> buffers;
  for (int i = 0; i < num_threads; ++i) {
    std::string buf_name = "BoundedBuffer" + std::to_string(i);
    BoundedBuffer* bb = segment.find<BoundedBuffer>(buf_name.c_str()).first;
    if (!bb) {
      std::cerr << "Failed to find " << buf_name << " in shared memory" << std::endl;
      return 1;
    }
    buffers.push_back(bb);
  }

  std::atomic<std::int64_t> number_popped(0);
  std::atomic<size_t> total_bytes_processed(0);
  std::atomic<int> sentinels_seen(0);

  detections.resize(num_threads);
  for (int i = 0; i < num_threads; ++i) {
    std::string filename = "detections_thread_" + std::to_string(i) + ".log";
    detections[i].open(filename, std::ios::out);
    if (!detections[i].is_open()) {
      std::cerr << "Failed to open detection log file: " << filename << std::endl;
      hs_free_database(db);
      return 1;
    }
  }

  t1 = clock::now();
  auto worker = [&](int tid) {
    hs_scratch_t* scratch = nullptr;
    hs_error_t err = hs_alloc_scratch(db, &scratch);
    if (err != HS_SUCCESS) {
      std::cerr << "Thread " << tid << ": Failed to allocate scratch space" << std::endl;
      return;
    }
    BoundedBuffer* my_buffer = buffers[tid];

    while (true) {
      auto buffer = my_buffer->peek_back();

      // Print all data in the buffer as characters
      // for (size_t i = 0; i < BUFFER_SIZE; ++i) {
      //     uint64_t temp = (*buffer)[i];
      //     for (size_t j = 0; j < 8; ++j) {
      //         std::cout << (char) (temp & 0xFF);
      //         temp >>= 8;
      //     }
      // }
      // std::cout << std::endl;

      // Check for sentinel (empty buffer)
      if ((*buffer)[0] == 0) {
        // Only process up to this point in the batch
        break;
      }

      int current_index = 0;
      while (true) {
        if (current_index >= BUFFER_SIZE) {
          break;
        }

        uint64_t metadata = (*buffer)[current_index];
        uint64_t event_index = (metadata >> 32) & 0xFFFFFFFFULL;

        // Get string length
        size_t str_len = ((*buffer)[current_index] & 0xFFFFFFFFULL) * 8;
        if (str_len == 0) {
          break;  // No more strings in this buffer
        }

        const char* data = reinterpret_cast<const char*>(&(*buffer)[current_index + 1]);
        MatchContext ctx = {data, str_len, event_index, static_cast<uint64_t>(tid)};

        err = hs_scan(db, data, str_len, 0, scratch, onMatch, &ctx);
        if (err != HS_SUCCESS) {
          std::cerr << "Thread " << tid << ": Error scanning data" << std::endl;
        }
        total_bytes_processed.fetch_add(str_len);
        number_popped.fetch_add(1);

        current_index += 1 + str_len / 8;  // Move to next string
      }
      // Pop the processed items
      my_buffer->pop_back();
    }
    hs_free_scratch(scratch);
  };

  std::vector<std::thread> threads;
  for (int i = 0; i < num_threads; ++i) {
    threads.emplace_back(worker, i);
  }
  for (auto& t : threads) {
    t.join();
  }

  t2 = clock::now();
  std::chrono::duration<double> elapsed = t2 - t1;
  double seconds = elapsed.count();

  std::cout << "Processed items: " << number_popped.load() << std::endl;
  std::cout << "Total bytes processed: " << total_bytes_processed.load() << std::endl;
  std::cout << "Elapsed: " << (seconds * 1000.0) << " ms" << std::endl;
  if (seconds > 0.0) {
    double mib_per_sec = (static_cast<double>(total_bytes_processed.load()) / (1024.0 * 1024.0)) / seconds;
    std::cout << "Effective throughput: " << mib_per_sec << " MiB/s" << std::endl;
  } else {
    std::cout << "Effective throughput: <inf> (duration too small)" << std::endl;
  }

  hs_free_database(db);
  // Destroy all BoundedBuffers
  for (int i = 0; i < num_threads; ++i) {
    std::string buf_name = "BoundedBuffer" + std::to_string(i);
    segment.destroy<BoundedBuffer>(buf_name.c_str());
  }
  std::cout << "Child process done." << std::endl;

  // Combine all detection logs into a single file

  std::vector<std::ifstream> detection_inputs;
  std::vector<std::pair<int, std::string>> all_detections;
  std::ofstream detection_output("all_detections.log");
  detection_inputs.resize(num_threads);
  for (int i = 0; i < num_threads; ++i) {
    detections[i].close();
    detection_inputs[i].open("detections_thread_" + std::to_string(i) + ".log");
    bool is_index = true;
    uint64_t index = 0;
    while (!detection_inputs[i].eof()) {
      std::string line;
      std::getline(detection_inputs[i], line);
      // Skip empty lines
      if (line.empty()) continue;

      if (is_index) {
        index = std::stoull(line);
      } else {
        all_detections.emplace_back(index, line);
      }
      is_index = !is_index;
    }
    detection_inputs[i].close();
    // Remove the individual detection log file
    std::string filename = "detections_thread_" + std::to_string(i) + ".log";
    std::remove(filename.c_str());
  }

  // Sort all detections by global event index
  std::sort(
      all_detections.begin(), all_detections.end(),
      [](const std::pair<int, std::string>& a, const std::pair<int, std::string>& b) { return a.first < b.first; });

  for (const auto& detection : all_detections) {
    // Strip FFs from detection.second
    std::string stripped = detection.second;
    stripped.erase(std::remove(stripped.begin(), stripped.end(), (char)0xFF), stripped.end());
    detection_output << stripped << "\n";
  }
  detection_output.close();

  return 0;
}
