#ifndef MSPM_BITMAP_TABLE7_H
#define MSPM_BITMAP_TABLE7_H
#define MSPM_BITMAP_TABLE7_WIDTH (8)
#define MSPM_BITMAP_TABLE7_DEPTH (8)
#define MSPM_BITMAP_TABLE7_LGDEPTH (3)


#define MSPM_BITMAP_TABLE7_MAXLGDEPTH (14)


#if SPUMP_PRGMA
[[intel::singlepump]]
#endif
#if DPUMP_PRGMA
[[intel::doublepump]]
#endif
#if DPORT_PRGMA
[[intel::simple_dual_port]]
#endif
const static unsigned char MSPM_BITMAP_TABLE7[8] = {
 0x00,
 0x00,
 0x04,
 0x04,
 0x00,
 0x00,
 0x00,
 0x00
};
#endif
