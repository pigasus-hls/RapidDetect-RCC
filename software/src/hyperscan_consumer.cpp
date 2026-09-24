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
#include <memory>
#include <cstdint>
#include <atomic>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
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
  detections[ctx->tid] << ctx->event_index << "\t" << std::string(ctx->data, ctx->length);
  // std::cout << "Pattern " << id << " matched \"" << matched << "\" at offset "
  //    << from << "-" << to << std::endl;
  return 0;
}



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
  SharedMemoryLayout* shm = segment.find<SharedMemoryLayout>("SharedMemoryLayout").first;
  if (!shm) {
    std::cerr << "Failed to find SharedMemoryLayout in shared memory" << std::endl;
    hs_free_database(db);
    return 1;
  }

  std::atomic<std::int64_t> number_popped(0);
  std::atomic<size_t> total_bytes_processed(0);

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

    PacketDesc local_descs[PACKETS_PER_CLAIM];

    while (true) {
      uint64_t start_desc = 0;
      uint64_t count = 0;
      uint64_t my_ticket = 0;

      // Claim up to PACKETS_PER_CLAIM descriptors under mutex
      {
        boost::unique_lock<boost::interprocess::interprocess_mutex> lock(shm->ctrl.mutex);
        shm->ctrl.not_empty.wait(lock, [&]() {
          return (shm->ctrl.desc_head < shm->ctrl.desc_tail) || shm->ctrl.is_done;
        });

        if (shm->ctrl.desc_head == shm->ctrl.desc_tail && shm->ctrl.is_done) {
          shm->ctrl.not_empty.notify_all();
          break; // All packets consumed, exit thread
        }

        count = std::min((uint64_t)PACKETS_PER_CLAIM, shm->ctrl.desc_tail - shm->ctrl.desc_head);
        start_desc = shm->ctrl.desc_head;
        shm->ctrl.desc_head += count;

        // Copy claimed descriptors to local thread stack inside mutex (prevents race condition)
        for (uint64_t i = 0; i < count; ++i) {
          local_descs[i] = shm->descriptors[(start_desc + i) % DESC_RING_SIZE];
        }

        // Notify producer that descriptor slots were freed
        shm->ctrl.not_full.notify_all();

        my_ticket = shm->ctrl.next_ticket++;
        uint32_t chunk_monotonic_end = local_descs[count - 1].monotonic_end;
        shm->ctrl.retire_tracker[my_ticket % MAX_INFLIGHT_CLAIMS] = {chunk_monotonic_end, false};
      }

      // Scan claimed packets lock-free using local descriptors
      for (uint64_t i = 0; i < count; ++i) {
        const PacketDesc& desc = local_descs[i];
        const char* data = reinterpret_cast<const char*>(&shm->payload[desc.offset]);
        MatchContext ctx = {data, desc.length, desc.event_index, static_cast<uint64_t>(tid)};

        err = hs_scan(db, data, desc.length, 0, scratch, onMatch, &ctx);
        if (err != HS_SUCCESS) {
          std::cerr << "Thread " << tid << ": Error scanning data" << std::endl;
        }
        total_bytes_processed.fetch_add(desc.length);
        number_popped.fetch_add(1);
      }

      // In-order retirement under mutex
      {
        boost::unique_lock<boost::interprocess::interprocess_mutex> lock(shm->ctrl.mutex);
        shm->ctrl.retire_tracker[my_ticket % MAX_INFLIGHT_CLAIMS].completed = true;
        bool retired_any = false;
        while (shm->ctrl.retired_ticket < shm->ctrl.next_ticket &&
               shm->ctrl.retire_tracker[shm->ctrl.retired_ticket % MAX_INFLIGHT_CLAIMS].completed) {
          uint64_t slot = shm->ctrl.retired_ticket % MAX_INFLIGHT_CLAIMS;
          shm->ctrl.payload_head = shm->ctrl.retire_tracker[slot].end_monotonic_offset;
          shm->ctrl.retire_tracker[slot].completed = false; // Reset for next epoch
          shm->ctrl.retired_ticket++;
          retired_any = true;
        }
        if (retired_any) {
          shm->ctrl.not_full.notify_all();
        }
      }
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
  segment.destroy<SharedMemoryLayout>("SharedMemoryLayout");
  std::cout << "Child process done." << std::endl;

  // Combine all detection logs into a single file

  std::vector<std::ifstream> detection_inputs;
  std::vector<std::pair<uint64_t, std::string>> all_detections;
  std::ofstream detection_output("all_detections.log");
  detection_inputs.resize(num_threads);
  for (int i = 0; i < num_threads; ++i) {
    detections[i].close();
    detection_inputs[i].open("detections_thread_" + std::to_string(i) + ".log");
    std::string line;
    while (std::getline(detection_inputs[i], line)) {
      if (line.empty()) continue;
      size_t tab_pos = line.find('\t');
      if (tab_pos != std::string::npos) {
        uint64_t index = std::stoull(line.substr(0, tab_pos));
        std::string payload = line.substr(tab_pos + 1);
        all_detections.emplace_back(index, payload);
      }
    }
    detection_inputs[i].close();
    // Remove the individual detection log file
    std::string filename = "detections_thread_" + std::to_string(i) + ".log";
    std::remove(filename.c_str());
  }

  // Sort all detections by global event index (64-bit uint64_t)
  std::sort(
      all_detections.begin(), all_detections.end(),
      [](const std::pair<uint64_t, std::string>& a, const std::pair<uint64_t, std::string>& b) { return a.first < b.first; });

  for (const auto& detection : all_detections) {
    // Strip FFs from detection.second
    std::string stripped = detection.second;
    stripped.erase(std::remove(stripped.begin(), stripped.end(), (char)0xFF), stripped.end());
    detection_output << stripped << "\n";
  }
  detection_output.close();

  return 0;
}
