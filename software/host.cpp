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

#define _DEFAULT_SOURCE
#define _XOPEN_SOURCE 500
#include <cassert>
#include <fcntl.h>
#include <getopt.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <cerrno>
#include <ctime>
#include <chrono>

#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>

#include <array>
#include <fstream>
#include <iostream>
#include <vector>
#include <iomanip>
#include <limits>

extern "C" {
#include "dmautils.h"
#include "qdma_nl.h"
}
#include "dma_xfer_utils.c"

#include <utils/types.h>
#include <rapidd_params.h>
#include <test/testbench.h>
#include <test/testinit.h>

#include "host.h"

//////////////////////////////////////////////////////////////////////////////
// IO Size Definitions
//////////////////////////////////////////////////////////////////////////////

// a kludge to increase trace buffer size to avoid wrap around
#ifndef TRACE_SIZE_SCALE
#define TRACE_SIZE_SCALE (64)
#endif
#define TRACE_SIZE (((1 << 16 /*magic value*/) * MSPM_MASK_WIDTH * MSPM_LOOKUP_WIDTH) * TRACE_SIZE_SCALE)

// Modify bus:device.function to your output of lspci | grep Xilinx (function must be 1 for QDMA)
#define BUS "01"
#define DEVICE "00"
#define FUNCTION "1"

#define H2C_QUEUE "/dev/qdma" BUS DEVICE FUNCTION "-MM-0"
#define C2H_QUEUE "/dev/qdma" BUS DEVICE FUNCTION "-MM-1"

// QDMA functions copied over from the QDMA apps provided in the GitHub repo
static int send_data(char *devname, uint64_t addr, uint64_t size, char *indata);
static int read_data(char *devname, uint64_t addr, uint64_t size, char *outdata);
static int qdma_register_write(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned long value,
                               unsigned int *reg_val);
static int qdma_register_read(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned int *reg_val);

// Addresses for some DRAM locations
#define A_ADDRESS (0x600ULL)
#define B_ADDRESS (0x601ULL)
#define C_ADDRESS (0x602ULL)

// Addresses for the two HBM memory bundles
#define HBM_BUNDLE0_ADDRESS (0x40ULL)
#define HBM_BUNDLE1_ADDRESS (0x44ULL)

int main(int argc, char *argv[]) {
  unsigned int read_val = 0;

  char c2h_queue[] = C2H_QUEUE;
  char h2c_queue[] = H2C_QUEUE;
  // Using BUS, DEVICE, FUNCTION as hex strings
  unsigned int bus = strtoul(BUS, NULL, 16);
  unsigned int device = strtoul(DEVICE, NULL, 16);
  unsigned int function = strtoul(FUNCTION, NULL, 16);
  unsigned int pf = ((bus << 12) | (device << 4) | (function));

  // Reset IPs by writing to the AXI GPIO generating the reset for the RapidDetect design
  qdma_register_read(0, pf, 2, 0x2C00, &read_val);
  printf("Before reset, CSR 0x2C00 = 0x%x\n", read_val);
  qdma_register_write(0, pf, 2, 0x2C00, 0x0, &read_val);
  printf("After writing 0x0 to CSR 0x2C00, CSR 0x2C00 = 0x%x\n", read_val);
  qdma_register_write(0, pf, 2, 0x2C00, 0x1, &read_val);
  printf("After writing 0x1 to CSR 0x2C00, CSR 0x2C00 = 0x%x\n", read_val);

  /////////////////////////////////////////////////////////////////////////////
  // Start RapidDetect
  /////////////////////////////////////////////////////////////////////////////
  std::ifstream datfile;

  // Check if trace has been provided, otherwise prepare the inbuilt test pattern
  BOOL traceInputMode = 0;
  if (argc > 1) {
    traceInputMode = 1;
  }

  // Set test pattern length and number of packets
  UINT tpPaddedByteLen;
  UINT tpNumPkt;

  if (traceInputMode) {
    // Read the trace file
    datfile.open(argv[1], std::ios::binary);
    if (!datfile.is_open()) {
      std::cerr << "Error opening file: " << argv[1] << std::endl;
      exit(1);
    }

    {
      UINT len, numpkt;

      datfile.ignore(std::numeric_limits<std::streamsize>::max());
      len = datfile.gcount();
      datfile.clear();
      datfile.seekg(0, std::ios::beg);

      numpkt = len / (MSPM_UNROLL * MSPM_MASK_WIDTH);  // worst case number of packets

      tpPaddedByteLen = ((len + IO_READ_BURSTSZ - 1) / IO_READ_BURSTSZ) * IO_READ_BURSTSZ;
      tpNumPkt = numpkt;

      std::cout << "Test pattern length: " << len << " bytes, number of packets: " << numpkt << std::endl;
    }
  } else {
    // this is a little fragile, tpPaddedByteLen just needs to be big enough here
    tpPaddedByteLen = (((((long)TESTPATTLEN3) + (2 * ((long)TESTPKTNUM3) * (MSPM_UNROLL * MSPM_MASK_WIDTH)) +
                         TESTPKTNUM3 + TESTPKTNUM3 * TPINIT_EXTRA_PKTS * TPINIT_EXTRA_PKT_LEN) /
                        IO_READ_BURSTSZ) *
                           IO_READ_BURSTSZ +
                       IO_READ_BURSTSZ);
    tpNumPkt = TESTPKTNUM3;
  }

  // Allocate test pattern buffers
  StripedVector<RawPayloadPack, IO_HBM_NUM_CHANNELS, MSPM_MASK_WIDTH * MSPM_UNROLL / IO_HBM_NUM_CHANNELS> tpPaddedPack(
      tpPaddedByteLen / IO_READ_BURSTSZ);

  // This is used by the test pattern check function and is unrelated to the FPGA operation
  std::vector<UINT> tpPaddedPktOffset(tpPaddedByteLen / (MSPM_UNROLL * MSPM_MASK_WIDTH));
  for (UINT line = 0; line < tpPaddedByteLen / (MSPM_UNROLL * MSPM_MASK_WIDTH); line++) {
    tpPaddedPktOffset[line] = 0;
  }

  // Load the test pattern
  if (traceInputMode) {
    if (loadTraceTestInputBuffer(tpPaddedByteLen, tpPaddedPack, tpPaddedPktOffset, datfile, tpNumPkt)) {
      std::cout << "IO Buffers not large enough to hold the trace file." << std::endl;
      exit(1);
    }
  } else {
    tpNumPkt = loadDefaultTestInputBuffer(tpPaddedByteLen, tpPaddedPack, tpPaddedPktOffset);
  }

  // Allocate host memory for trace results
  RidBcntPack *trace_host;
  posix_memalign((void **)&trace_host, 64, TRACE_SIZE / IO_WRITE_WIDTH * sizeof(RidBcntPack));
  if (trace_host == nullptr) {
    std::cerr << "Failed to allocate host memory for trace_host" << std::endl;
    exit(1);
  }

  // Send the test pattern to the FPGA for each HBM bundle being used (2 here)
  send_data(h2c_queue, HBM_BUNDLE0_ADDRESS << 32, tpPaddedByteLen / IO_HBM_NUM_CHANNELS,
            (char *)tpPaddedPack.getChannelVector(0).data());
  send_data(h2c_queue, HBM_BUNDLE1_ADDRESS << 32, tpPaddedByteLen / IO_HBM_NUM_CHANNELS,
            (char *)tpPaddedPack.getChannelVector(1).data());

  // Write first testpattern memory address to CSR registers (HBM_BUNDLE0_ADDRESS)
  qdma_register_write(0, pf, 2, 0x2410, 0x0, &read_val);
  printf("Before starting the DMA, CSR 0x2410 = 0x%x\n", read_val);
  qdma_register_write(0, pf, 2, 0x2414, HBM_BUNDLE0_ADDRESS, &read_val);
  printf("After writing 0x%llx to CSR 0x2414, CSR 0x2414 = 0x%x\n", HBM_BUNDLE0_ADDRESS, read_val);

  // Write second testpattern memory address to CSR registers (HBM_BUNDLE1_ADDRESS)
  qdma_register_write(0, pf, 2, 0x241C, 0x0, &read_val);
  printf("Before starting the DMA, CSR 0x241C = 0x%x\n", read_val);
  qdma_register_write(0, pf, 2, 0x2420, HBM_BUNDLE1_ADDRESS, &read_val);
  printf("After writing 0x%llx to CSR 0x2420, CSR 0x2420 = 0x%x\n", HBM_BUNDLE1_ADDRESS, read_val);

  // Write tpPaddedByteLen (count) parameter to CSR register
  qdma_register_write(0, pf, 2, 0x2428, tpPaddedByteLen / IO_READ_BURSTSZ, &read_val);
  printf("After writing %d to CSR 0x2428, CSR 0x2428 = 0x%x\n", tpPaddedByteLen / IO_READ_BURSTSZ, read_val);

  // Write trace_device memory address to CSR registers (A_ADDRESS)
  qdma_register_write(0, pf, 2, 0x2810, 0x0, &read_val);
  printf("Before starting the DMA, CSR 0x2810 = 0x%x\n", read_val);
  qdma_register_write(0, pf, 2, 0x2814, A_ADDRESS, &read_val);
  printf("After writing 0x%llx to CSR 0x2814, CSR 0x2814 = 0x%x\n", A_ADDRESS, read_val);

  // Set skipWrite to 0 for this test (If set to 1 output DRAM write is disabled)
  qdma_register_write(0, pf, 2, 0x281C, TEST_SKIP_WRITE ? 1 : 0, &read_val);
  printf("After writing 0x%x to CSR 0x281C, CSR 0x281C = 0x%x\n", TEST_SKIP_WRITE ? 1 : 0, read_val);

  // Write buffer_size parameter to CSR register
  qdma_register_write(0, pf, 2, 0x2824, TRACE_SIZE, &read_val);
  printf("After writing %d to CSR 0x2824, CSR 0x2824 = 0x%x\n", TRACE_SIZE, read_val);

  unsigned int read_val_source = 0, read_val_sink = 0;
  qdma_register_read(0, pf, 2, 0x2400, &read_val_source);
  qdma_register_read(0, pf, 2, 0x2800, &read_val_sink);
  printf("CSR 0x2400 = 0x%x, CSR 0x2800 = 0x%x\n", read_val_source, read_val_sink);

  // Use chrono to measure execution time
  auto startTime = std::chrono::high_resolution_clock::now();
  // Start by writing to ap_start for source and sink
  qdma_register_write(0, pf, 2, 0x2800, 0x1, &read_val_sink);
  qdma_register_write(0, pf, 2, 0x2400, 0x1, &read_val_source);
  printf("CSR 0x2400 = 0x%x, CSR 0x2800 = 0x%x\n", read_val_source, read_val_sink);

  // Check if ap_done is high for source and sink
  while (((read_val_source & 0b100) == 0) || ((read_val_sink & 0b100) == 0)) {
    qdma_register_read(0, pf, 2, 0x2400, &read_val_source);
    qdma_register_read(0, pf, 2, 0x2800, &read_val_sink);
    printf("CSR 0x2400 = 0x%x, CSR 0x2800 = 0x%x\n", read_val_source, read_val_sink);
  }
  auto endTime = std::chrono::high_resolution_clock::now();
  sleep(1);

  // Read the trace results back from the FPGA to the host
  read_data(c2h_queue, A_ADDRESS << 32, TRACE_SIZE / IO_WRITE_WIDTH * sizeof(RidBcntPack), (char *)trace_host);

  // Process test results
  std::cout << "Processing " << trace_host[0].ridBcnt[0].bcntSeq << " results..." << std::endl;
  for (UINT idx = 0; idx < trace_host[0].ridBcnt[0].bcntSeq; idx++) {
    RidBcnt ridbcnt = trace_host[idx / IO_WRITE_WIDTH + 1].ridBcnt[idx % IO_WRITE_WIDTH];

    // summarize results
    if (!TEST_SKIP_WRITE) {
      testPatternCheck(ridbcnt, idx, tpPaddedPack, tpPaddedPktOffset);
    }
  }

  // Print summarized detection results
  if (TEST_SKIP_WRITE) {
    printf("\n\n*** NO RESULTS WRITE ON THIS TEST. ***\n\n");
  }
  testPatternFinish();

  // Get elapsed time in seconds
  double elapsedTime = std::chrono::duration<double>(endTime - startTime).count();
  // print execution time and read bandwidth in Gbps
  std::cout << "Execution time: " << elapsedTime * 1E3 << " ms" << std::endl;
  std::cout << "Throughput: " << 8 * (tpPaddedByteLen / 1E9) / (elapsedTime) << " Gbps" << std::endl;

  return 0;
}

static int send_data(char *devname, uint64_t addr, uint64_t size, char *indata) {
  uint64_t i;
  ssize_t rc;
  struct timespec ts_start, ts_end;
  int fpga_fd = open(devname, O_RDWR);
  double total_time = 0;
  double result;
  double avg_time = 0;

  if (fpga_fd < 0) {
    fprintf(stderr, "unable to open device %s, %d.\n", devname, fpga_fd);
    perror("open device");
    return -EINVAL;
  }

  /* write buffer to AXI MM address using SGDMA */
  clock_gettime(CLOCK_MONOTONIC, &ts_start);

  rc = write_from_buffer(devname, fpga_fd, indata, size, addr);
  if (rc < 0) goto out;

  rc = clock_gettime(CLOCK_MONOTONIC, &ts_end);
  /* subtract the start time from the end time */
  timespec_sub(&ts_end, &ts_start);
  total_time += (ts_end.tv_sec + ((double)ts_end.tv_nsec / NSEC_DIV));
  /* a bit less accurate but side-effects are accounted for */
  if (verbose)
    fprintf(stdout, "#%lu: CLOCK_MONOTONIC %ld.%09ld sec. write %lu bytes\n", i, ts_end.tv_sec, ts_end.tv_nsec, size);

  result = ((double)size) / total_time;
  if (verbose)
    printf("** Time device %s, total time %f nsec, size = %lu, BW = %f bytes/sec\n", devname, total_time, size, result);
  dump_throughput_result(size, result);

  rc = 0;

out:
  close(fpga_fd);

  return rc;
}

static int read_data(char *devname, uint64_t addr, uint64_t size, char *outdata) {
  ssize_t rc;
  uint64_t i;
  struct timespec ts_start, ts_end;
  int fpga_fd = open(devname, O_RDWR | O_NONBLOCK);
  double total_time = 0;
  double result;
  double avg_time = 0;

  if (fpga_fd < 0) {
    fprintf(stderr, "unable to open device %s, %d.\n", devname, fpga_fd);
    perror("open device");
    return -EINVAL;
  }

  clock_gettime(CLOCK_MONOTONIC, &ts_start);
  /* lseek & read data from AXI MM into buffer using SGDMA */
  rc = read_to_buffer(devname, fpga_fd, outdata, size, addr);
  if (rc < 0) goto out;
  clock_gettime(CLOCK_MONOTONIC, &ts_end);

  /* subtract the start time from the end time */
  timespec_sub(&ts_end, &ts_start);
  total_time += (ts_end.tv_sec + ((double)ts_end.tv_nsec / NSEC_DIV));
  /* a bit less accurate but side-effects are accounted for */
  if (verbose)
    fprintf(stdout, "#%lu: CLOCK_MONOTONIC %ld.%09ld sec. read %lu bytes\n", i, ts_end.tv_sec, ts_end.tv_nsec, size);

  result = ((double)size) / total_time;
  if (verbose)
    printf("** Avg time device %s, total time %f nsec, size = %lu, BW = %f bytes/sec\n", devname, total_time, size,
           result);
  dump_throughput_result(size, result);

  rc = 0;

out:
  close(fpga_fd);

  return rc;
}

static void xnl_dump_response(const char *resp) {
  // printf("%s", resp);
}

static int qdma_register_write(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned long value,
                               unsigned int *reg_val) {
  struct xcmd_info xcmd;
  struct xcmd_reg *regcmd;
  int ret;

  memset(&xcmd, 0, sizeof(struct xcmd_info));

  regcmd = &xcmd.req.reg;
  xcmd.op = XNL_CMD_REG_WRT;
  xcmd.vf = is_vf;
  xcmd.if_bdf = pf;
  xcmd.log_msg_dump = xnl_dump_response;
  regcmd->bar = bar;
  regcmd->reg = reg;
  regcmd->val = value;
  regcmd->sflags = XCMD_REG_F_BAR_SET | XCMD_REG_F_REG_SET | XCMD_REG_F_VAL_SET;

  ret = qdma_reg_write(&xcmd);
  if (ret < 0) printf("QDMA_REG_WRITE Failed, ret :%d\n", ret);
  *reg_val = regcmd->val;

  return ret;
}

static int qdma_register_read(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned int *reg_val) {
  struct xcmd_info xcmd;
  struct xcmd_reg *regcmd;
  int ret;

  memset(&xcmd, 0, sizeof(struct xcmd_info));

  regcmd = &xcmd.req.reg;
  xcmd.op = XNL_CMD_REG_RD;
  xcmd.vf = is_vf;
  xcmd.if_bdf = pf;
  xcmd.log_msg_dump = xnl_dump_response;
  regcmd->bar = bar;
  regcmd->reg = reg;
  regcmd->sflags = XCMD_REG_F_BAR_SET | XCMD_REG_F_REG_SET;

  ret = qdma_reg_read(&xcmd);
  if (ret < 0) printf("QDMA_REG_READ Failed, ret :%d\n", ret);

  *reg_val = regcmd->val;

  return ret;
}
