# RapidDetect Software & Shared Memory Architecture

Host software stack for RapidDetect threat detection on the AMD/Xilinx Versal V80. Coordinates FPGA PCIe transfers via QDMA and offloads candidate events to multi-threaded Intel Hyperscan regex engines.

---

## Overview

1. FPGA (Versal V80): Performs multi-string pattern matching at 200 Gbps line rate. Matches are streamed over PCIe via QDMA C2H queues.
2. CPU (Host Stack):
   - Producer (host_producer.x): Transfers raw log bursts directly from FPGA into shared memory and publishes packet descriptors.
   - Consumer (hyperscan_consumer.x): Multi-threaded Hyperscan workers claim descriptor batches, evaluate regexes lock-free, and log matches.
   - Shared Memory: POSIX/Boost shared memory segment containing the control block, descriptor ring, and payload ring.

Data Flow:
   Versal V80 FPGA (200G Ethernet -> Match Kernels -> QDMA C2H)
          |
          |  PCIe DMA (Direct zero-copy)
          v
   Shared Memory Segment ("MySharedMemory")
     - Control Block: Mutex, condition variables, head and tail pointers
     - Descriptor Ring: 64K slots for packet metadata
     - Payload Ring: 64 MB contiguous raw log buffer
          |
          |  Batch Claims (up to 64 packets per claim)
          v
   Hyperscan Worker Threads (parallel regex scanning -> match logs)

---

## Architecture & Improvements

The current design replaces the legacy per-thread bounded buffer model with a unified contiguous ring:

- True Zero-Copy DMA:
  DMA writes directly from FPGA into the shared payload ring, eliminating intermediate host buffers and per-word memory copies.

- Lock-Free PCIe Transfers:
  PCIe transfers are decoupled from the shared memory lock:
  1. Reserve space under mutex (microseconds).
  2. Perform DMA and delimiter boundary scanning lock-free (milliseconds).
  3. Commit descriptors under mutex (microseconds).
  Workers continue scanning and retiring concurrently without lock starvation.

- Non-Splitting Ring Wrap:
  Hyperscan requires contiguous memory pointers. If a DMA burst crosses the 64 MB ring boundary, leftover bytes from any incomplete packet are copied to offset 0, and the new burst writes directly after them. Packets never wrap around the physical edge.

- Flit-Stride Boundary Scanner:
  The FPGA packs logs into 64-byte flits (eight 64-bit words), where newline delimiters always land in the 8th word. The producer scans only the 8th word of each flit instead of checking every word, reducing scanning overhead by 8x.

- Batch Descriptor Claiming:
  Workers claim up to 64 descriptors at once under mutex, copy them to a local stack array, and release the lock immediately. This cuts lock contention by over 60x.

- Ticket-Based In-Order Retirement:
  Because workers process chunks in parallel with variable regex times, they finish out of order. Each chunk receives a monotonic ticket number. When a worker finishes, it marks its ticket complete, and a single retirement loop advances the payload head in strict ticket order.

- Cache-Line Isolation:
  Producer counters, consumer counters, and retirement tables reside on separate 64-byte hardware cache lines via explicit byte padding, eliminating false sharing on NUMA multi-core CPUs.

---

## Key Data Structures

- Packet Descriptor (PacketDesc):
  Stores byte offset in the payload ring, packet byte length, monotonic packet sequence ID, and monotonic retirement coordinate.

- Control Block (ShmControlBlock):
  Houses the shared mutex, condition variables (not_empty, not_full), producer state (desc_tail, payload_tail, is_done), consumer state (desc_head, payload_head, ticket counters), and the retirement tracking array. Explicit byte padding isolates producer and consumer fields onto separate 64-byte cache lines.

- Composite Shared Memory Layout:
  Contains the control block, the 64K-slot descriptor ring, and the 64 MB contiguous payload ring.

---

## Configuration Parameters (shm_config.h)

- THREAD_COUNT: 8 (default worker threads; override with -n)
- PAYLOAD_RING_SIZE: 64 MB (contiguous raw log ring buffer)
- DESC_RING_SIZE: 262,144 (packet descriptor circular slots, matches 64 MB ring at 256 B/packet)
- PACKETS_PER_CLAIM: 64 (packets claimed per lock acquisition)
- MAX_INFLIGHT_CLAIMS: 1024 (capacity of in-flight ticket array)

---

## Build & Run

1. Build Binaries:
   cd software
   make clean host_producer.x hyperscan_consumer.x

2. Configure QDMA Queues:
   sudo ./setup_queues.sh

3. Run Complete Pipeline:
   sudo ./run_pipeline.sh -f <trace.json> -n <threads> -t <throttle>
   Example:
   sudo ./run_pipeline.sh -f ../traces/E5_cadets-deduplicated.json.500k -n 16 -t 1.0

4. Run Binaries Separately (Debug Mode):
   Terminal 1 (Producer):
   sudo ./host_producer.x -f ../traces/E5_cadets-deduplicated.json.500k -n 16 -t 1.0

   Terminal 2 (Consumer):
   ./hyperscan_consumer.x patterns_full.db 16

5. Verification & Cleanup:
   Clean stale shared memory: sudo rm -f /dev/shm/MySharedMemory
   Compare match output:     diff <(sort all_detections.log) <(sort baseline_detections.log)

---

## Pitfalls & Bugs Encountered

1. Non-Splitting Ring Wrap: Monotonic Tail & Leftover Skew
   - Pitfall: Packets spanning ring boundaries cannot be split without breaking Hyperscan pointers. Leftover bytes from incomplete packets are copied to index 0.
   - Bug: Advancing payload_tail solely by burst_bytes ignored the copied leftover_bytes. The next burst's write offset landed at burst_bytes instead of burst_bytes + leftover_bytes, overwriting the leftover packet.
   - Fix: Account for leftover_bytes and padding in tail advancement (payload_tail += pad_bytes + leftover_bytes) and include padding in producer backpressure checks.

2. Descriptor Race Conditions: Premature desc_head Advancement
   - Pitfall: Advancing desc_head signals to the producer that descriptor slots are free to reuse.
   - Bug: Consumers held raw references into shared descriptors while scanning lock-free. At 200 Gbps, the producer wraps the 64K descriptor ring in milliseconds, overwriting descriptors mid-scan and causing torn reads and segmentation faults.
   - Fix: Workers copy their claimed batch into a thread-local stack array inside the claim mutex. Scanning uses the local copy, isolating workers from producer ring wraps.

3. Ticket Ring Aliasing in Retirement Tracker
   - Pitfall: Out-of-order workers need an in-order retirement tracker (1024 slots) to advance payload_head monotonically.
   - Bug: If a thread stalled on a heavy regex while other threads claimed more than 1024 chunks, ticket T + 1024 mapped to the same slot as ticket T, overwriting T's completed status. When T finished, it prematurely marked the new chunk complete, causing the retirement loop to skip unconsumed memory.
   - Fix: Enforce ticket capacity in the consumer wait condition so workers only claim when in-flight tickets are below the tracker limit.

4. Producer Deadlock from Missed not_full Notification
   - Pitfall: Producer sleeps on not_full when either descriptor or payload space is exhausted.
   - Bug: not_full notification was only called in the ticket retirement loop. If the descriptor ring filled up while retirement was blocked on an older ticket, workers claimed descriptors but never notified the producer, causing permanent deadlock.
   - Fix: Broadcast not_full notification immediately when desc_head is advanced during descriptor claiming.

5. Boost IPC Allocator Incompatibility with alignas(64)
   - Pitfall: Placing producer and consumer variables on separate cache lines prevents false sharing.
   - Bug: Adding alignas(64) to structs inside Boost managed_shared_memory caused runtime segmentation faults. Boost's segment allocator only guarantees standard alignment (8 to 16 bytes) and does not support over-aligned types.
   - Fix: Removed alignas(64) and used explicit byte padding arrays to isolate variables onto distinct 64-byte cache lines without violating allocator alignment rules.

6. Mutex Lock Contention Across PCIe DMA Transfers
   - Pitfall: Protecting shared memory with a coarse-grained mutex.
   - Bug: Holding the shared memory mutex across PCIe DMA and delimiter boundary scanning blocked all consumer threads from claiming work or retiring, serializing execution and collapsing throughput.
   - Fix: Decoupled into a 3-stage pipeline: reserve slice under mutex, perform PCIe DMA directly into shared memory and scan delimiters lock-free, and commit descriptors under mutex.

7. Log File Corruption with Embedded Newlines & 32-bit Index Overflow
   - Pitfall: Worker threads output per-thread match logs merged into a single sorted log.
   - Bug: Parsing alternating newline-separated lines failed with conversion exceptions whenever log payloads contained embedded newlines. Storing indices as 32-bit integers caused overflow and sort corruption on large datasets exceeding 2 billion events.
   - Fix: Format lines with tab delimiters (event_index followed by tab and payload), parse on tab characters, and store indices as 64-bit unsigned integers.
