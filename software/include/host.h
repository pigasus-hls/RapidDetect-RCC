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
