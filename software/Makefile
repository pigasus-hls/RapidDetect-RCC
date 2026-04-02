#
#/*
# * This file is part of the QDMA userspace application
# * to enable the user to execute the QDMA functionality
# *
# * Copyright (c) 2018-2022, Xilinx, Inc. All rights reserved.
# * Copyright (c) 2022-2024, Advanced Micro Devices, Inc. All rights reserved.
# *
# * This source code is licensed under BSD-style license (found in the
# * LICENSE file in the root directory of this source tree)
# */

QDMA_DIR = ../dma_ip_drivers/QDMA/linux-kernel/apps/

CC ?= gcc

HOSTFLAGS = -DNO_MY_ASSERT=1 -DMSPM_TRACKPOS=1 -DMSPM_RESOLVE_CONFLICT=1 -DTEST_SAMEFLOW=0 -DTEST_PREPEND7=0 -DMSPM_UNROLL=8 -DMSPM_CHECKFIELD=1
CFLAGS += -g
#CFLAGS += -O2 -fno-inline -Wall -Wstrict-prototypes
CFLAGS += -I. -I$(QDMA_DIR)/include -I$(QDMA_DIR)/dma-utils/ -I../hardware/include
CFLAGS += $(EXTRA_FLAGS)

HOST = host
DMA-UTILS_OBJS := $(QDMA_DIR)/dma-utils/dmautils.o \
				  $(QDMA_DIR)/dma-utils/dmaxfer.o \
				  $(QDMA_DIR)/dma-utils/dmactl.o \
				  $(QDMA_DIR)/dma-utils/dmactl_reg.o
HOST_OBJS = $(DMA-UTILS_OBJS)
HOST_SRCS := host.cpp ../hardware/src/test/testbench.cpp ../hardware/src/test/testinit.cpp

ifneq ($(CROSS_COMPILE_FLAG),)
	CC=$(CROSS_COMPILE_FLAG)gcc
endif

all: clean host.x

host.x: $(HOST_OBJS) $(HOST_SRCS)
	$(CC) $(HOSTFLAGS) $(CFLAGS) -lrt -o $@ $^ -laio -lstdc++ -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE

${BUILD_DIR}/%.o: %.c
	$(CC) $(CFLAGS) -c -std=c99 -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE -D_AIO_AIX_SOURCE

${BUILD_DIR}/%.o: %.cpp
	$(CC) $(CFLAGS) -c -std=c++11 -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE -D_AIO_AIX_SOURCE

clean:
	@rm -f *.o */*.o $(QDMA_DIR)/dma-utils/*.o
	rm -rf *.o *.bin host.x
