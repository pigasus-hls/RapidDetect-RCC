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
 0x41,
 0x00,
 0x40,
 0x08,
 0x00,
 0x40,
 0x00,
 0x02,
 0x28,
 0xa0,
 0x02,
 0x12,
 0x00,
 0x04,
 0x00,
 0x00,
 0x00,
 0x00,
 0x04,
 0x00,
 0x10,
 0x01,
 0x39,
 0x0c,
 0x00,
 0x0a,
 0x00,
 0x00,
 0x14,
 0x00,
 0x02,
 0x00
};
#endif
