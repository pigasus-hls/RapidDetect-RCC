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

#include "mspm_params.h"

#include <tables/collision_table.h>
#include <tables/mspm_bitmap_table0.h>
#include <tables/mspm_bitmap_table1.h>
#include <tables/mspm_bitmap_table2.h>
#include <tables/mspm_bitmap_table3.h>
#include <tables/mspm_bitmap_table4.h>
#include <tables/mspm_bitmap_table5.h>
#include <tables/mspm_bitmap_table6.h>
#include <tables/mspm_bitmap_table7.h>
#include <tables/mspm_shiftorF_table.h>
#include <tables/mspm_shiftorR_table.h>
#include <tables/rid2sid_table.h>

[[maybe_unused]] const static unsigned char *bitmap_tables[8] = {
    MSPM_BITMAP_TABLE0, MSPM_BITMAP_TABLE1, MSPM_BITMAP_TABLE2, MSPM_BITMAP_TABLE3,
    MSPM_BITMAP_TABLE4, MSPM_BITMAP_TABLE5, MSPM_BITMAP_TABLE6, MSPM_BITMAP_TABLE7};

const static unsigned int bitmap_tables_lgdepth[8] = {
    MSPM_BITMAP_TABLE0_LGDEPTH, MSPM_BITMAP_TABLE1_LGDEPTH, MSPM_BITMAP_TABLE2_LGDEPTH, MSPM_BITMAP_TABLE3_LGDEPTH,
    MSPM_BITMAP_TABLE4_LGDEPTH, MSPM_BITMAP_TABLE5_LGDEPTH, MSPM_BITMAP_TABLE6_LGDEPTH, MSPM_BITMAP_TABLE7_LGDEPTH};

#include <tables/mspm_hash_table0.h>
#include <tables/mspm_hash_table1.h>
#include <tables/mspm_hash_table2.h>
#include <tables/mspm_hash_table3.h>
#include <tables/mspm_hash_table4.h>
#include <tables/mspm_hash_table5.h>
#include <tables/mspm_hash_table6.h>
#include <tables/mspm_hash_table7.h>

[[maybe_unused]] const static unsigned short *hash_tables[8] = {MSPM_HASH_TABLE0, MSPM_HASH_TABLE1, MSPM_HASH_TABLE2,
                                                                MSPM_HASH_TABLE3, MSPM_HASH_TABLE4, MSPM_HASH_TABLE5,
                                                                MSPM_HASH_TABLE6, MSPM_HASH_TABLE7};

const static unsigned int hash_tables_lgdepth[8] = {
    MSPM_HASH_TABLE0_LGDEPTH, MSPM_HASH_TABLE1_LGDEPTH, MSPM_HASH_TABLE2_LGDEPTH, MSPM_HASH_TABLE3_LGDEPTH,
    MSPM_HASH_TABLE4_LGDEPTH, MSPM_HASH_TABLE5_LGDEPTH, MSPM_HASH_TABLE6_LGDEPTH, MSPM_HASH_TABLE7_LGDEPTH};

#if MSPM_CHECKTAG
#include <tables/mspm_hash_tagtable0.h>
#include <tables/mspm_hash_tagtable1.h>
#include <tables/mspm_hash_tagtable2.h>
#include <tables/mspm_hash_tagtable3.h>
#include <tables/mspm_hash_tagtable4.h>
#include <tables/mspm_hash_tagtable5.h>
#include <tables/mspm_hash_tagtable6.h>
#include <tables/mspm_hash_tagtable7.h>

[[maybe_unused]] const static unsigned char *hash_tagtables[8] = {
    MSPM_HASH_TAGTABLE0, MSPM_HASH_TAGTABLE1, MSPM_HASH_TAGTABLE2, MSPM_HASH_TAGTABLE3,
    MSPM_HASH_TAGTABLE4, MSPM_HASH_TAGTABLE5, MSPM_HASH_TAGTABLE6, MSPM_HASH_TAGTABLE7};
#endif

#if MSPM_CHECKFIELD
#include <tables/mspm_hash_bmaptable0.h>
#include <tables/mspm_hash_bmaptable1.h>
#include <tables/mspm_hash_bmaptable2.h>
#include <tables/mspm_hash_bmaptable3.h>
#include <tables/mspm_hash_bmaptable4.h>
#include <tables/mspm_hash_bmaptable5.h>
#include <tables/mspm_hash_bmaptable6.h>
#include <tables/mspm_hash_bmaptable7.h>

[[maybe_unused]] const static unsigned char *hash_bmaptables[8] = {
    MSPM_HASH_BMAPTABLE0, MSPM_HASH_BMAPTABLE1, MSPM_HASH_BMAPTABLE2, MSPM_HASH_BMAPTABLE3,
    MSPM_HASH_BMAPTABLE4, MSPM_HASH_BMAPTABLE5, MSPM_HASH_BMAPTABLE6, MSPM_HASH_BMAPTABLE7};
#endif
