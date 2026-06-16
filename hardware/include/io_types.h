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

#pragma once

/// IO Types abstracted from the IO Kernels needed for host side code as well as FPGA kernels

#include <io_params.h>
#include <utils/types.h>
#include <vector>

// Read payload (prepared in DRAM by main()) into MSPM injestion pipe.
struct RawPayloadPack {
  uint8_t data[IO_READ_BURSTSZ / IO_HBM_NUM_CHANNELS];
};

// Struct to stripe across HBM channels to get increased bandwidth and capacity
template <typename T, int NUM_CHANNELS, int STRIPE_SIZE>
class StripedVector {
  std::vector<T> vectors[NUM_CHANNELS];

 public:
  StripedVector() = default;

  StripedVector(size_t size) {
    for (int i = 0; i < NUM_CHANNELS; i++) {
      vectors[i].resize(size);
    }
  }

  // Provide std::vector like functions: reserve
  void reserve(size_t size) {
    for (int i = 0; i < NUM_CHANNELS; i++) {
      vectors[i].reserve(size);
    }
  }

  // Provide std::vector like functions: resize
  void resize(size_t size) {
    for (int i = 0; i < NUM_CHANNELS; i++) {
      vectors[i].resize(size);
    }
  }

  const size_t size() const { return vectors[0].size(); }

  // Access function to get/set byte at a global byte index across the striped channels so that users don't have to
  // worry about how the data is laid out in memory
  const uint8_t &get(size_t idx, size_t byte_idx) const {
    size_t channel = (byte_idx / STRIPE_SIZE) % NUM_CHANNELS;
    size_t localIdx = ((byte_idx / STRIPE_SIZE) / NUM_CHANNELS) * STRIPE_SIZE + byte_idx % STRIPE_SIZE;
    return vectors[channel][idx].data[localIdx];
  }

  void set(size_t idx, size_t byte_idx, uint8_t value) {
    size_t channel = (byte_idx / STRIPE_SIZE) % NUM_CHANNELS;
    size_t localIdx = ((byte_idx / STRIPE_SIZE) / NUM_CHANNELS) * STRIPE_SIZE + byte_idx % STRIPE_SIZE;
    vectors[channel][idx].data[localIdx] = value;
  }

  // Get the individual channel vector for direct access when needed (e.g. for DMA)
  std::vector<T> &getChannelVector(int channel) { return vectors[channel]; }
};

// Aligned read data struct; multiple words per flit; multiple flits per read.
struct PayloadWordPack {
  PAYLOAD_WORD word[MSPM_UNROLL];
  BOOL eop;
  BOOL switchPipe;
  FTAG ftag[MSPM_UNROLL];  // field tag for each word
  BOOL hasQuote;
};

// Aligned write data struct; multiple words per flit; possibly multiple flits per write.
struct PayloadWritePack {
  PAYLOAD_WORD words[HOST_PAYLOAD_WIDTH];
};

struct PayloadWritePackFlit {
  PayloadWritePack pack;
  BOOL done;
};

// Trace buffer detection entry format; need to be kept in 2-power sized
struct RidBcnt {
  UINT bcntSeq;     // barrier cnt or mspm packet sequence
  URID ridPlusOne;  // RID+1; 0 means invalid
#if MSPM_TRACKPOS && NFPM_TRACKPOS
  USHORT pos;  // optional: detection position
  USHORT pad;  // padding to align to two power
#endif
};

// Widen results flit output to the write stage
struct RidBcntFlit {
  RidBcnt ridBcnt[IO_WRITE_WIDTH];
  BOOL terminate;  // signal end of test after detection "magic" pattern
};

// Aligned wide data struct for DRAM write
struct RidBcntPack {
  RidBcnt ridBcnt[IO_WRITE_WIDTH];
};
