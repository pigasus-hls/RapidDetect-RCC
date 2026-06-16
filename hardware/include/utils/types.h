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

#include <cstdint>

#ifdef __SYNTHESIS__
#include <ap_int.h>
#endif

/**
 * Common type definitions used across the design.
 *
 * These are mostly fixed width types and structs that are shared across multiple modules, so they are defined in a
 * common header to avoid circular dependencies.
 *
 * Also includes some utility types like VoidPipe for producing and consuming dummy data, which can be useful for
 * testing and profiling individual modules in isolation and field tagging types
 */

#define BITSINBYTE (8)
#define BYTEMASK ((1 << BITSINBYTE) - 1)
#define LGBITSINBYTE (3)

typedef uint8_t UBYTE;  // a byte
typedef bool BOOL;      // stand-in for boolean
typedef uint16_t URID;  // rule id
#define URID_CONFLICT_BIT ((URID)0x8000)
typedef uint16_t USEQ;  // 2=byte frame sequenece
typedef uint16_t UPOS;  // 2=byte position in frame

typedef uint16_t UIDX;  // small index 64k is enough

typedef uint64_t ULONG;   // 8-byte generic
typedef uint16_t USHORT;  // 2-byte generic
typedef uint8_t UCHAR;    // 1-byte generic

typedef int32_t INT;
typedef uint32_t UINT;

#define FTAG_BITS_PER_BYTE (2)
#define FTAG_BYTES_PER_FTAG (8)
typedef uint16_t FTAG;  // Field tag for Rapid Detect; 2 bits per byte

#ifdef __SYNTHESIS__
typedef ap_uint<2> FTAG1;  // smallest
#else
typedef uint8_t FTAG1;  // smallest
#endif

// MISC must be 0; cross-reference rest with io_stages.cpp
#define FTAG_MISC 0
#define FTAG_SYSCALL 1
#define FTAG_EXE 2
#define FTAG_PATH 3
#define FTAG_HOWMANY 4

///////////////////////////////////////////////////////////////////////////////
// Payload type
///////////////////////////////////////////////////////////////////////////////
typedef ULONG PAYLOAD_WORD;  // a 8-byte hyerscan word and mask

template <int NumWords>
struct PayloadFieldTagBase {
  FTAG ftag[NumWords];
};

struct PayloadSeqBase {
  USEQ seq;
};

template <int NumWords>
class PayloadFieldTagVoid {};
class PayloadSeqVoid {};

template <int NumWords, typename TSEQ = PayloadSeqVoid,
          template <int NumFieldWords> typename TFTAG = PayloadFieldTagVoid>
struct PayloadFlit : public TSEQ, public TFTAG<NumWords> {
  BOOL eop;                     // end of packet mark
  BOOL sameflow;                // next packet from same flow, only sampled with EOP
  PAYLOAD_WORD word[NumWords];  // payload words
};

// Statistics DirectIO types
template <typename T>
class simulation_directio {
  T* data;

 public:
  simulation_directio(const simulation_directio& other) { this->data = other.data; }
  // simulation_directio& operator=(const simulation_directio&) = delete;
  simulation_directio() {
    data = new T();
    *data = 0;
  }

  T read() { return *data; }

  void write(const T& value) { *data = value; }
};

#ifdef __SYNTHESIS__
#include <hls_directio.h>
using count_directio_t = hls::ap_none<uint32_t>;
using done_directio_t = hls::ap_none<bool>;
#else
using count_directio_t = simulation_directio<uint32_t>;
using done_directio_t = simulation_directio<bool>;
#endif
