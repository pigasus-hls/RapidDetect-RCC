#pragma once

#include <cstdint>
#include <sys/types.h>

// QDMA functions copied over from the QDMA apps provided in the GitHub repo
int send_data(char *devname, uint64_t addr, uint64_t size, char *indata);
int read_data(char *devname, uint64_t addr, uint64_t size, char *outdata);
int qdma_register_write(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned long value,
                        unsigned int *reg_val);
int qdma_register_read(unsigned char is_vf, unsigned int pf, int bar, unsigned long reg, unsigned int *reg_val);
