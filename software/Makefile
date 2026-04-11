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
CXX = g++

HOSTFLAGS = -DNO_MY_ASSERT=1 -DMSPM_TRACKPOS=1 -DMSPM_RESOLVE_CONFLICT=1 -DTEST_SAMEFLOW=0 -DTEST_PREPEND7=0 -DMSPM_UNROLL=8 -DMSPM_CHECKFIELD=1 -DTEST_FALSE_POSITIVES=0
# CFLAGS += -g
CFLAGS += -O2 -fno-inline -Wstrict-prototypes -Wno-unused-result
CFLAGS += -I./include -I$(QDMA_DIR)/include -I$(QDMA_DIR)/dma-utils/ -I../hardware/include
CFLAGS += $(EXTRA_FLAGS)

BOOST_ROOT ?= /usr
BOOST_INCLUDE := $(BOOST_ROOT)/include
BOOST_LIB := $(BOOST_ROOT)/lib/x86_64-linux-gnu

# Hyperscan library paths
HYPERSCAN_PATH = $(PWD)/hyperscan
HYPERSCAN_BUILD = $(HYPERSCAN_PATH)/build
HYPERSCAN_INCLUDES = -I$(HYPERSCAN_PATH)/include \
                    -I$(HYPERSCAN_PATH)/src \
                    -I$(HYPERSCAN_PATH)/tools \
                    -I$(HYPERSCAN_PATH)/tools/hsbench \
                    -I$(HYPERSCAN_PATH)/util \
                    -I$(HYPERSCAN_BUILD)

# Location of engine_hyperscan.o in Hyperscan build
ENGINE_HYPERSCAN = $(HYPERSCAN_BUILD)/tools/hsbench/CMakeFiles/hsbench.dir/engine_hyperscan.cpp.o

PRODUCER_CFLAGS = -I$(BOOST_INCLUDE) -I./include -DBOOST_BIND_GLOBAL_PLACEHOLDERS
CONSUMER_CFLAGS = $(PRODUCER_CFLAGS) $(HYPERSCAN_INCLUDES) -std=c++17 -O3 -march=native -flto -DNDEBUG -fopenmp
LDFLAGS = -L$(BOOST_LIB) -L$(HYPERSCAN_BUILD)/lib

HOST = host
DMA-UTILS_OBJS := $(QDMA_DIR)/dma-utils/dmautils.o \
				  $(QDMA_DIR)/dma-utils/dmaxfer.o \
				  $(QDMA_DIR)/dma-utils/dmactl.o \
				  $(QDMA_DIR)/dma-utils/dmactl_reg.o
HOST_OBJS = $(DMA-UTILS_OBJS)
HOST_SRCS := src/host.cpp ../hardware/src/test/testbench.cpp ../hardware/src/test/testinit.cpp src/qdma_helpers.cpp
HOST_PRODUCER_SRCS := src/host_producer.cpp ../hardware/src/test/testbench.cpp ../hardware/src/test/testinit.cpp src/qdma_helpers.cpp

ifneq ($(CROSS_COMPILE_FLAG),)
	CC=$(CROSS_COMPILE_FLAG)gcc
endif

all: clean host.x host_producer.x hyperscan_consumer.x

hyperscan_consumer.x: src/hyperscan_consumer.cpp
	$(CXX) $(CONSUMER_CFLAGS) $< -o $@ $(LDFLAGS) -lboost_thread -lhs

host.x: $(HOST_OBJS) $(HOST_SRCS)
	$(CC) $(HOSTFLAGS) $(CFLAGS) -lrt -o $@ $^ -laio -lstdc++ -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE

host_producer.x: $(HOST_OBJS) $(HOST_PRODUCER_SRCS)
	$(CC) $(HOSTFLAGS) $(CFLAGS) $(PRODUCER_CFLAGS) -lrt -o $@ $^ $(LDFLAGS) -lboost_thread -laio -lstdc++ -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE

${BUILD_DIR}/%.o: %.c
	$(CC) $(CFLAGS) -c -std=c99 -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE -D_AIO_AIX_SOURCE

${BUILD_DIR}/%.o: %.cpp
	$(CC) $(CFLAGS) -c -std=c++11 -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE -D_AIO_AIX_SOURCE

clean:
	@rm -f *.o */*.o $(QDMA_DIR)/dma-utils/*.o
	rm -rf *.o *.bin *.x
	rm -rf *.log
