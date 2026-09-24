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

#pragma once

#include <cstdint>
#include <cstddef>
#include <array>
#include <boost/interprocess/sync/interprocess_mutex.hpp>
#include <boost/interprocess/sync/interprocess_condition.hpp>
#include <boost/interprocess/sync/scoped_lock.hpp>
#include <boost/thread/locks.hpp>

// Shared configuration for producer and consumer
#ifndef THREAD_COUNT
#define THREAD_COUNT 8                         // Default thread count, can be overridden at runtime
#endif

#ifndef PAYLOAD_RING_SIZE
#define PAYLOAD_RING_SIZE (64 * 1024 * 1024)   // 64 MB contiguous payload ring
#endif

#ifndef MIN_PACKET_SIZE
#define MIN_PACKET_SIZE 256                        // Minimum packet size assumption in bytes
#endif

#ifndef DESC_RING_SIZE
#define DESC_RING_SIZE (PAYLOAD_RING_SIZE / MIN_PACKET_SIZE)   // 262,144 slots (matches 64 MB payload ring with 256 B/packet)
#endif

#ifndef PACKETS_PER_CLAIM
#define PACKETS_PER_CLAIM 64                   // Max packets claimed per thread in one atomic claim
#endif

#ifndef MAX_INFLIGHT_CLAIMS
#define MAX_INFLIGHT_CLAIMS 1024               // Capacity of in-order retirement tracker
#endif

// Packet descriptor storing separate metadata (compact 16-byte layout)
struct PacketDesc {
  uint32_t offset;        // 0 .. PAYLOAD_RING_SIZE - 1 (direct pointer offset in payload ring)
  uint32_t length;        // Byte length of the packet
  uint32_t event_index;   // Global monotonic packet sequence ID (up to 4.29B packets)
  uint32_t monotonic_end; // Absolute monotonic byte offset (modulo 2^32, for in-order retirement)
};

// Chunk retirement entry: entire claimed chunk of packets retires together
struct ClaimRetireEntry {
  uint32_t end_monotonic_offset; // Absolute monotonic end offset of this chunk (modulo 2^32)
  bool completed;                // True when all packets in this claim are scanned
};

// Shared synchronization control block with cache line isolation
struct ShmControlBlock {
  boost::interprocess::interprocess_mutex mutex;
  boost::interprocess::interprocess_condition not_empty;
  boost::interprocess::interprocess_condition not_full;

  // Producer-owned variables
  uint64_t desc_tail;       // Next descriptor index to write
  uint32_t payload_tail;    // Next payload byte offset to write (monotonic modulo 2^32)
  bool is_done;             // True when producer has finished all transfers

  // Consumer-owned variables
  uint64_t desc_head;       // Oldest unconsumed descriptor index
  uint32_t payload_head;    // Oldest unconsumed payload byte offset (monotonic modulo 2^32)
  uint64_t next_ticket;     // Next ticket to assign to a worker claim
  uint64_t retired_ticket;  // Oldest unretired ticket

  // In-order retirement tracker: retires chunks of PACKETS_PER_CLAIM at once
  ClaimRetireEntry retire_tracker[MAX_INFLIGHT_CLAIMS];
};

// Unified shared memory layout
struct SharedMemoryLayout {
  ShmControlBlock ctrl;
  std::array<PacketDesc, DESC_RING_SIZE> descriptors;
  std::array<uint8_t, PAYLOAD_RING_SIZE + 4096> payload;
};
