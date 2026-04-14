#ifndef NFPM_BITMAP_TABLE5_H
#define NFPM_BITMAP_TABLE5_H
#define NFPM_BITMAP_TABLE5_WIDTH (8)
#define NFPM_BITMAP_TABLE5_DEPTH (32)
#define NFPM_BITMAP_TABLE5_LGDEPTH (5)


#define NFPM_BITMAP_TABLE5_MAXLGDEPTH (11)


#if SPUMP_PRGMA
[[intel::singlepump]]
#endif
#if DPUMP_PRGMA
[[intel::doublepump]]
#endif
#if DPORT_PRGMA
[[intel::simple_dual_port]]
#endif
const static unsigned char NFPM_BITMAP_TABLE5[32] = {
 0x00,
 0x00,
 0x40,
 0x08,
 0x01,
 0x40,
 0x04,
 0x22,
 0x00,
 0xa8,
 0x00,
 0x04,
 0x00,
 0x84,
 0x00,
 0x00,
 0x12,
 0x02,
 0x20,
 0x04,
 0x10,
 0x19,
 0x81,
 0x0c,
 0x00,
 0x00,
 0x08,
 0x00,
 0x04,
 0x00,
 0x00,
 0x00
};
#endif
