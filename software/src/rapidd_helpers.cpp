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

#include <rapidd_helpers.h>
#include <qdma_helpers.h>
#include <host.h>
#include <iostream>
#include <iomanip>
#include <unistd.h>

uint32_t rapidd_read_reg(unsigned int pf, uint64_t base_addr, uint64_t offset) {
  uint32_t val = 0;
  qdma_register_read(0, pf, 2, base_addr + offset, &val);
  return val;
}

uint32_t rapidd_write_reg(unsigned int pf, uint64_t base_addr, uint64_t offset, uint32_t val) {
  uint32_t written_val = 0;
  qdma_register_write(0, pf, 2, base_addr + offset, val, &written_val);
  return written_val;
}

void setup_source_kernel(unsigned int pf, uint64_t input_addr_ch0, uint64_t input_addr_ch1, uint32_t trace_len) {
  std::cout << "\nSetting up payload source kernel..." << std::endl;
  rapidd_write_reg(pf, SOURCE_ADDRESS, SOURCE_CH0_ADDR_L_OFFSET, 0x0);
  std::cout << "[Source Kernel] Wrote channel 0 input address lower 32-bits = 0x0" << std::endl;
  rapidd_write_reg(pf, SOURCE_ADDRESS, SOURCE_CH0_ADDR_H_OFFSET, input_addr_ch0);
  std::cout << "[Source Kernel] Wrote channel 0 input address upper 32-bits = 0x" << std::hex << input_addr_ch0
            << std::dec << std::endl;

  rapidd_write_reg(pf, SOURCE_ADDRESS, SOURCE_CH1_ADDR_L_OFFSET, 0x0);
  std::cout << "[Source Kernel] Wrote channel 1 input address lower 32-bits = 0x0" << std::endl;
  rapidd_write_reg(pf, SOURCE_ADDRESS, SOURCE_CH1_ADDR_H_OFFSET, input_addr_ch1);
  std::cout << "[Source Kernel] Wrote channel 1 input address upper 32-bits = 0x" << std::hex << input_addr_ch1
            << std::dec << std::endl;

  rapidd_write_reg(pf, SOURCE_ADDRESS, SOURCE_LEN_OFFSET, trace_len);
  std::cout << "[Source Kernel] Wrote test pattern length = 0x" << std::hex << trace_len << std::dec << std::endl;
}

void setup_eth_kernel(unsigned int pf, uint32_t throttle_period) {
  rapidd_write_reg(pf, ETH_CONTROL_ADDRESS, ETH_THROTTLE_OFFSET, throttle_period);
  std::cout << "[Ethernet Control] Wrote throttle period = 0x" << std::hex << throttle_period << std::dec << std::endl;
}

void setup_rules_kernel(unsigned int pf, uint64_t results_addr, bool skip_write, uint32_t buffer_size) {
  std::cout << "\nSetting up result sink kernel..." << std::endl;
  rapidd_write_reg(pf, RULES_ADDRESS, RULES_ADDR_L_OFFSET, 0x0);
  std::cout << "[Rules Kernel] Wrote rule results address lower 32-bits = 0x0" << std::endl;
  rapidd_write_reg(pf, RULES_ADDRESS, RULES_ADDR_H_OFFSET, results_addr);
  std::cout << "[Rules Kernel] Wrote rule results address upper 32-bits = 0x" << std::hex << results_addr << std::dec
            << std::endl;

  uint32_t skip_val = skip_write ? 1 : 0;
  rapidd_write_reg(pf, RULES_ADDRESS, RULES_SKIP_OFFSET, skip_val);
  std::cout << "[Rules Kernel] Wrote skip write flag = 0x" << std::hex << skip_val << std::dec << std::endl;

  rapidd_write_reg(pf, RULES_ADDRESS, RULES_BUF_SIZE_OFFSET, buffer_size);
  std::cout << "[Rules Kernel] Wrote rule results size cap = 0x" << std::hex << buffer_size << std::dec << std::endl;
}

void setup_payload_kernel(unsigned int pf, uint64_t sink_addr, uint32_t tick_counter_limit, bool skip_write,
                          uint32_t max_size) {
  std::cout << "\nSetting up payload write kernel..." << std::endl;
  rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_ADDR_L_OFFSET, 0x0);
  std::cout << "[Payload Write Kernel] Wrote payload sink address lower 32-bits = 0x0" << std::endl;
  rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_ADDR_H_OFFSET, sink_addr);
  std::cout << "[Payload Write Kernel] Wrote payload sink address upper 32-bits = 0x" << std::hex << sink_addr
            << std::dec << std::endl;

  rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_LIMIT_OFFSET, tick_counter_limit);
  std::cout << "[Payload Write Kernel] Wrote tick limit counter = 0x" << std::hex << tick_counter_limit << std::dec
            << std::endl;

  uint32_t skip_val = skip_write ? 1 : 0;
  rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_SKIP_OFFSET, skip_val);
  std::cout << "[Payload Write Kernel] Wrote skip write flag = 0x" << std::hex << skip_val << std::dec << std::endl;

  rapidd_write_reg(pf, PAYLOAD_WRITE_ADDRESS, PAYLOAD_MAX_SIZE_OFFSET, max_size);
  std::cout << "[Payload Write Kernel] Wrote payload output size cap = 0x" << std::hex << max_size << std::dec
            << std::endl;
}

void reset_rapidd_design(unsigned int pf) {
  uint32_t read_val = rapidd_read_reg(pf, RESET_GPIO_ADDRESS, 0);
  std::cout << "Resetting RapidDetect..." << std::endl;
  rapidd_write_reg(pf, RESET_GPIO_ADDRESS, 0, 0x1);
  read_val = rapidd_read_reg(pf, RESET_GPIO_ADDRESS, 0);
  std::cout << "[Reset GPIO] After asserting reset (0x1), status = 0x" << std::hex << read_val << std::dec << std::endl;
  sleep(1);
  rapidd_write_reg(pf, RESET_GPIO_ADDRESS, 0, 0x0);
  read_val = rapidd_read_reg(pf, RESET_GPIO_ADDRESS, 0);
  std::cout << "[Reset GPIO] After releasing reset (0x0), status = 0x" << std::hex << read_val << std::dec << std::endl;
  std::cout << "Reset Complete" << std::endl;
}
