#ifndef NFPM_BITMAP_TABLE6_H
#define NFPM_BITMAP_TABLE6_H
#define NFPM_BITMAP_TABLE6_WIDTH (8)
#define NFPM_BITMAP_TABLE6_DEPTH (32)
#define NFPM_BITMAP_TABLE6_LGDEPTH (5)


#define NFPM_BITMAP_TABLE6_MAXLGDEPTH (11)


#if SPUMP_PRGMA
[[intel::singlepump]]
#endif
#if DPUMP_PRGMA
[[intel::doublepump]]
#endif
#if DPORT_PRGMA
[[intel::simple_dual_port]]
#endif
const static unsigned char NFPM_BITMAP_TABLE6[32] = {
 0x00,
 0x01,
 0x00,
 0x01,
 0x00,
 0x84,
 0x00,
 0x08,
 0x00,
 0x01,
 0x06,
 0x00,
 0x00,
 0x12,
 0x00,
 0x21,
 0x00,
 0x02,
 0x00,
 0x80,
 0x00,
 0x00,
 0x80,
 0x14,
 0x40,
 0x00,
 0x00,
 0x50,
 0x00,
 0x00,
 0x04,
 0x80
};
#endif
