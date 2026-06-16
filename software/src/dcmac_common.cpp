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

#include <dcmac_common.h>
#include <dcmac_reg.h>
#include <qdma_helpers.h>
#include <vector>
#include <iostream>
#include <unistd.h>
#include <utility>

const uint64_t DCMAC_BASE_ADDR[] = {0x00440000, 0x00540000};
const uint64_t GTWIZ_BASE_ADDR[] = {0x00400000, 0x00500000};
const uint64_t GPIO_RESET_ADDR[] = {0x00450000, 0x00550000};
const uint64_t GPIO_CTRL_ADDR[] = {0x00470000, 0x00570000};
const uint64_t GPIO_MONITOR_ADDR[] = {0x00460000, 0x00560000};

// CTRL Register:
// Default: 00110100000110000110000000000000
//          ||-----||----||----||-||------|
// [31 : 31]    CDR Hold
// [30 : 24]    Main Cursor
// [23 : 18]    Post Cursor
// [17 : 12]    Pre Cursor
// [11 :  9]    Loopback
// [ 8 :  1]    Line Rate

static void dcmac_reset_tx(int channel, unsigned int pf) {
  unsigned int read_val = 0;
  std::cout << "Resetting Channel " << channel << " DCMAC TX...";
  std::vector<uint64_t> rst_core_regs_offset = {dcmac_registers.at("GLOBAL_CONTROL_REG_TX").offset};
  std::vector<uint64_t> rst_serdes_regs_offset;
  std::vector<uint64_t> rst_flush_regs_offset;
  for (int i = 0; i < 6; i++) {
    rst_serdes_regs_offset.push_back(dcmac_registers.at("C0_PORT_CONTROL_REG_TX").offset + i * 0x1000);
    rst_flush_regs_offset.push_back(dcmac_registers.at("C0_CHANNEL_CONTROL_REG_TX").offset + i * 0x1000);
  }

  // Assert all resets
  for (auto &offset : rst_core_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset, 0xFFFFFFFF, &read_val);
  for (auto &offset : rst_serdes_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset, 0xFFFFFFFF, &read_val);
  for (auto &offset : rst_flush_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset, 0xFFFFFFFF, &read_val);

  usleep(100000);  // Sleep for 100ms to ensure resets are asserted for sufficient time

  // Release port reset
  for (auto &offset : rst_serdes_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset, 0x0, &read_val);

  // Release core reset
  for (auto &offset : rst_core_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset, 0x0, &read_val);

  // Wait for tx_local_fault
  read_val = 1;
  while (extract_field(read_val,
                       dcmac_registers.at("C0_STAT_CHAN_TX_MAC_RT_STATUS_REG").fields.at("c0_stat_tx_local_fault")) !=
         0) {
    qdma_register_read(
        0, pf, 2, DCMAC_BASE_ADDR[channel] + dcmac_registers.at("C0_STAT_CHAN_TX_MAC_RT_STATUS_REG").offset, &read_val);
    std::cout << ".";  // Print a dot to indicate we're still waiting
    usleep(200000);    // Sleep for 200ms before polling again
  }

  // Release flush reset
  for (auto &offset : rst_flush_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset, 0x0, &read_val);
  std::cout << "\nDCMAC TX Reset Complete!" << std::endl;
}

static void dcmac_reset_rx(int channel, unsigned int pf) {
  unsigned int read_val = 0;
  std::cout << "Resetting Channel " << channel << " DCMAC RX...";
  std::vector<std::pair<uint64_t, uint64_t>> rx_rst_core_regs_offset = {
      {dcmac_registers.at("GLOBAL_CONTROL_REG_RX").offset, 7}};
  std::vector<std::pair<uint64_t, uint64_t>> rx_rst_serdes_regs_offset;
  std::vector<std::pair<uint64_t, uint64_t>> rx_rst_flush_regs_offset;
  for (int i = 0; i < 6; i++) {
    rx_rst_serdes_regs_offset.push_back({dcmac_registers.at("C0_PORT_CONTROL_REG_RX").offset + i * 0x1000, 2});
    rx_rst_flush_regs_offset.push_back({dcmac_registers.at("C0_CHANNEL_CONTROL_REG_RX").offset + i * 0x1000, 1});
  }

  // Assert all resets
  for (auto &offset : rx_rst_core_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset.first, offset.second, &read_val);
  for (auto &offset : rx_rst_serdes_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset.first, offset.second, &read_val);
  for (auto &offset : rx_rst_flush_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset.first, offset.second, &read_val);
  usleep(500000);  // Sleep for 500ms to ensure resets are asserted for sufficient time

  // Release core, then flush and finally serdes resets
  for (auto &offset : rx_rst_core_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset.first, 0x0, &read_val);
  for (auto &offset : rx_rst_flush_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset.first, 0x0, &read_val);
  for (auto &offset : rx_rst_serdes_regs_offset)
    qdma_register_write(0, pf, 2, DCMAC_BASE_ADDR[channel] + offset.first, 0x0, &read_val);

  // Check RX alignment
  read_val = 1;
  while (
      (extract_field(read_val,
                     dcmac_registers.at("C0_STAT_PORT_RX_PHY_RT_STATUS_REG").fields.at("c0_stat_rx_status")) != 1) ||
      (extract_field(read_val,
                     dcmac_registers.at("C0_STAT_PORT_RX_PHY_RT_STATUS_REG").fields.at("c0_stat_rx_aligned")) != 1)) {
    qdma_register_read(
        0, pf, 2, DCMAC_BASE_ADDR[channel] + dcmac_registers.at("C0_STAT_PORT_RX_PHY_RT_STATUS_REG").offset, &read_val);
    std::cout << ".";  // Print a dot to indicate we're still waiting
    usleep(250000);    // Sleep for 250ms before polling again
  }
  std::cout << "\nDCMAC RX Reset Complete!" << std::endl;
}

void reset_procedure(int channel, unsigned int pf) {
  unsigned int read_val = 0;

  // Step 1: Reset GTs
  std::cout << "Resetting Channel " << channel << " GT...";
  qdma_register_write(0, pf, 2, GPIO_RESET_ADDR[channel], 1, &read_val);
  usleep(10000);  // Sleep for 10ms to ensure reset is asserted for sufficient time
  qdma_register_write(0, pf, 2, GPIO_RESET_ADDR[channel], 0, &read_val);

  read_val = 0;
  while ((read_val & 0b110) == 0) {  // Wait for both GT reset done and DCMAC reset done to be set
    qdma_register_read(0, pf, 2, GPIO_MONITOR_ADDR[channel], &read_val);
    std::cout << ".";  // Print a dot to indicate we're still waiting
    usleep(100000);    // Sleep for 100ms before polling again to avoid busy waiting
  }
  std::cout << "\nGT Reset Complete!" << std::endl;

  // Step 2: Reset DCMAC TX
  dcmac_reset_tx(channel, pf);

  // Step 3: Reset DCMAC RX
  dcmac_reset_rx(channel, pf);
}
