/******************************************************************************
MIT License

Copyright (c) 2024-2026 Shashank Obla, Carnegie Mellon University
Copyright (c) 2024-2025 James C. Hoe, Carnegie Mellon University

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

#pragma once

#include "nfpm_params.h"

#include <tables/nf_bitmap_table0.h>
#include <tables/nf_bitmap_table1.h>
#include <tables/nf_bitmap_table2.h>
#include <tables/nf_bitmap_table3.h>
#include <tables/nf_bitmap_table4.h>
#include <tables/nf_bitmap_table5.h>
#include <tables/nf_bitmap_table6.h>
#include <tables/nf_bitmap_table7.h>
#include <tables/nf_shiftorF_table.h>
#include <tables/nf_shiftorR_table.h>

[[maybe_unused]] const static unsigned char *nf_bitmap_tables[8] = {
    NFPM_BITMAP_TABLE0, NFPM_BITMAP_TABLE1, NFPM_BITMAP_TABLE2, NFPM_BITMAP_TABLE3,
    NFPM_BITMAP_TABLE4, NFPM_BITMAP_TABLE5, NFPM_BITMAP_TABLE6, NFPM_BITMAP_TABLE7};

const static unsigned int nf_bitmap_tables_lgdepth[8] = {
    NFPM_BITMAP_TABLE0_LGDEPTH, NFPM_BITMAP_TABLE1_LGDEPTH, NFPM_BITMAP_TABLE2_LGDEPTH, NFPM_BITMAP_TABLE3_LGDEPTH,
    NFPM_BITMAP_TABLE4_LGDEPTH, NFPM_BITMAP_TABLE5_LGDEPTH, NFPM_BITMAP_TABLE6_LGDEPTH, NFPM_BITMAP_TABLE7_LGDEPTH};

#include <tables/nf_rule_fp.h>
#if NFPM_CHECK_FPDWIDE
#include <tables/nf_rule_fp_dwide.h>
#endif
#if NFPM_CHECK_FPALT
#include <tables/nf_rule_fp_alt.h>
#endif

#if NFPM_CHECKFIELD
#include <tables/nf_hash_bmaptable0.h>
#include <tables/nf_hash_bmaptable1.h>
#include <tables/nf_hash_bmaptable2.h>
#include <tables/nf_hash_bmaptable3.h>
#include <tables/nf_hash_bmaptable4.h>
#include <tables/nf_hash_bmaptable5.h>
#include <tables/nf_hash_bmaptable6.h>
#include <tables/nf_hash_bmaptable7.h>
#endif
