#include <qdma_helpers.h>

#undef _DEFAULT_SOURCE
#define _DEFAULT_SOURCE

#undef _XOPEN_SOURCE
#define _XOPEN_SOURCE 500

#include <cassert>
#include <fcntl.h>
#include <getopt.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <cerrno>
#include <ctime>

#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>

extern "C" {
#include "dmautils.h"
#include "qdma_nl.h"
}
#include "dma_xfer_utils.c"

int send_data(char *devname, uint64_t addr, uint64_t size, char *indata) {
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

int read_data(char *devname, uint64_t addr, uint64_t size, char *outdata) {
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

void xnl_dump_response(const char *resp) {
  // printf("%s", resp);
}

int qdma_register_write(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned long value,
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

int qdma_register_read(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned int *reg_val) {
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
