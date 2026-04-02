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

#include "types.h"

/**
 * Utility functions for case normalization of payload words.
 * This is used to support case-insensitive pattern matching in the MSPM.
 */

#define CAPITALIZE(a) ((((a) >= 'a') && ((a) <= 'z')) ? ((a) + ('A' - 'a')) : (a))

[[maybe_unused]] static PAYLOAD_WORD normalize(PAYLOAD_WORD in) {
#if NOCASE
  {
    PAYLOAD_WORD out = 0;

#pragma unroll
    for (UIDX i = 0; i < sizeof(PAYLOAD_WORD); i++) {
      UCHAR temp = (in >> (i * BITSINBYTE)) & BYTEMASK;
      temp = CAPITALIZE(temp);
      out |= ((PAYLOAD_WORD)temp) << (i * BITSINBYTE);
    }
    return out;
  }
#else
  return in;
#endif
}
