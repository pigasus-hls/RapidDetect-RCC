#ifndef NFPM_BITMAP_TABLE7_H
#define NFPM_BITMAP_TABLE7_H
#define NFPM_BITMAP_TABLE7_WIDTH (8)
#define NFPM_BITMAP_TABLE7_DEPTH (8)
#define NFPM_BITMAP_TABLE7_LGDEPTH (3)


#define NFPM_BITMAP_TABLE7_MAXLGDEPTH (11)


#if SPUMP_PRGMA
[[intel::singlepump]]
#endif
#if DPUMP_PRGMA
[[intel::doublepump]]
#endif
#if DPORT_PRGMA
[[intel::simple_dual_port]]
#endif
const static unsigned char NFPM_BITMAP_TABLE7[8] = {
 0x00,
 0x80,
 0x10,
 0x10,
 0x00,
 0x00,
 0x21,
 0x80
};
#endif
