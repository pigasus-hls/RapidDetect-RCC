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

// a kludge to increase trace buffer size to avoid wrap around
#ifndef TRACE_SIZE_SCALE
#define TRACE_SIZE_SCALE (64)
#endif
#define TRACE_SIZE (((1 << 16 /*magic value*/) * MSPM_MASK_WIDTH * MSPM_LOOKUP_WIDTH) * TRACE_SIZE_SCALE)

////////////////////////////////////////////////////////////////////////////////////////////////////
// Modify bus:device.function to your output of lspci | grep Xilinx (function must be 1 for QDMA) //
#define BUS "01"
#define DEVICE "00"
#define FUNCTION "1"
////////////////////////////////////////////////////////////////////////////////////////////////////

#define H2C_QUEUE "/dev/qdma" BUS DEVICE FUNCTION "-MM-0"
#define C2H_QUEUE "/dev/qdma" BUS DEVICE FUNCTION "-MM-1"
// Addresses for the two HBM memory bundles
#define HBM_BUNDLE0_ADDRESS (0x40ULL)
#define HBM_BUNDLE1_ADDRESS (0x44ULL)

// Address for kernel control axilite interfaces
#define SOURCE_ADDRESS (0x2400ULL)
#define RULES_ADDRESS (0x2800ULL)
#define PAYLOAD_WRITE_ADDRESS (0x3000ULL)
#define RESET_GPIO_ADDRESS (0x2C00ULL)
