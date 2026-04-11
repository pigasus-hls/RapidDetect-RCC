#include <rapidd_stages.h>
#include <utils/stream_primitives.h>

#define MAX_FIELD_LENGTH 11
#define NUM_FIELDS 3

// Hardcoded helper function to match fields of interest and tag them.
// Can be edited to match different fields or use a different matching logic as needed.
FTAG matchField(const char *data) {
  // match syscall
  const char matchFields[NUM_FIELDS][MAX_FIELD_LENGTH + 1] = {"\"syscall\": ", "****\"exe\": ", "***\"path\": "};

  FTAG ftag = 0;  // Default to MISC
  for (int i = 0; i < NUM_FIELDS; i++) {
#pragma HLS UNROLL
    BOOL match = true;
    for (int j = 0; j < MAX_FIELD_LENGTH; j++) {
#pragma HLS UNROLL
      if ((data[j] != matchFields[i][j]) && (matchFields[i][j] != '*')) {
        match = false;
      }
    }
    ftag |= (match ? ((i + 1) & 3) : 0);
  }

  return ftag;
}

void fieldMatchKernel(hls::stream<PayloadWordPack> &PayloadInPipe, hls::stream<PayloadWordPack> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe

  char matchData[MAX_FIELD_LENGTH + MSPM_UNROLL * MSPM_MASK_WIDTH] = {0};

  while (1) {
#pragma HLS PIPELINE II = 1
    PayloadWordPack wPack;
    BOOL valid = PayloadInPipe.read_nb(wPack);

    // Copy payload into matchData
    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      matchData[i + MAX_FIELD_LENGTH] = (wPack.word[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 8)) & 0xFF;
    }

    FTAG ftag[MSPM_UNROLL] = {0};  // field tag for each word
    BOOL hasQuote = false;         // flag to indicate if a quote is found

    // Mark all locations where the field matches
    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      ftag[i / MSPM_MASK_WIDTH] |= ((matchField(&matchData[i]) & 3) << ((i % MSPM_MASK_WIDTH) * 2));
    }

    // Propagate field matches until next quotation
    FTAG prevFtag = 0;
    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      FTAG currentFtag = (ftag[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 2)) & 3;

      // Always update; if prevFtag is 0, it will not change the current ftag, this is guaranteed to not overwrite
      // the current ftag since it will become 0 before it hits a match (quotes in the field will reset it)
      ftag[i / MSPM_MASK_WIDTH] |= ((prevFtag & 3) << ((i % MSPM_MASK_WIDTH) * 2));
      prevFtag = (ftag[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 2)) & 3;  // Replace with new ftag
      if ((currentFtag & 3) == 0 && matchData[i + MAX_FIELD_LENGTH] == '"') {
        prevFtag = 0;     // reset ftag on quote
        hasQuote = true;  // mark that we have a quote
      }
    }

    // Copy last bytes to front of matchData for next iteration
    for (int i = 0; i < MAX_FIELD_LENGTH; i++) {
#pragma HLS UNROLL
      if (wPack.eop & 1) {
        matchData[i] = 0xFF;
      } else if (valid) {
        matchData[i] = matchData[i + MSPM_UNROLL * MSPM_MASK_WIDTH];
      }
    }

    for (int i = 0; i < MSPM_UNROLL; i++) {
#pragma HLS UNROLL
      wPack.ftag[i] = ftag[i];  // copy field tag
    }
    wPack.hasQuote = hasQuote;  // mark if there was a quote
    if (valid) PayloadOutPipe.write(wPack);
  }
}

// Fix overflowing field tagging which is not handled in the previous kernel
void fieldMatchFixOverflowKernel(hls::stream<PayloadWordPack> &PayloadInPipe,
                                 hls::stream<PayloadWordPack> &PayloadOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = PayloadOutPipe

  FTAG overflowFtag = 0;

  while (1) {
#pragma HLS PIPELINE II = 1
    PayloadWordPack wPack;
    BOOL valid = PayloadInPipe.read_nb(wPack);  // Check if the read was valid

    FTAG currentFtag = (wPack.ftag[MSPM_UNROLL - 1] >> ((MSPM_MASK_WIDTH - 1) * 2)) & 3;  // Get last ftag bit
    // Note: if the last byte is an end quote the overflow ftag should be 0 but it could also be a starting quote
    // which would require more checks. Without checking we will only tag commas and spaces until the next field
    // anyways so the extra taggings should be innocuous and I leave it as it is for now.

    FTAG overflowFtagCopy = overflowFtag;  // Copy overflow ftag to use in the loop

    for (int i = 0; i < MSPM_UNROLL * MSPM_MASK_WIDTH; i++) {
#pragma HLS UNROLL
      // FTAG thisFtag = wPack.ftag[i / MSPM_MASK_WIDTH] >> (i % MSPM_MASK_WIDTH) & 1;
      // Shouldn't need this additional check since a quote would've reset it well before and at the beginning of
      // the flit if it's matched, the overflowFtag will be 0 since the field would have preceded this flit
      // if (overflowFtagCopy && !thisFtag) wPack.ftag[i / MSPM_MASK_WIDTH] |= (overflowFtagCopy << (i %
      // MSPM_MASK_WIDTH)); If there is an overflowing non misc ftag and this ftag is misc, overwrite

      if (overflowFtagCopy) {
        wPack.ftag[i / MSPM_MASK_WIDTH] |= ((overflowFtagCopy & 3) << ((i % MSPM_MASK_WIDTH) * 2));
      }
      if ((wPack.word[i / MSPM_MASK_WIDTH] >> ((i % MSPM_MASK_WIDTH) * 8) & 0xFF) == '"') {
        overflowFtagCopy = 0;  // reset overflow tag on quote
      }
    }

    if (valid) PayloadOutPipe.write(wPack);

    // If current flit has a quote, reset overflowFtag with current ftag else keep it from previous flit
    // This is the feedback path which needs to be able to run every cycle
    if (wPack.eop) {
      overflowFtag = 0;  // reset on end of packet
    } else if (valid) {
      overflowFtag = ((wPack.hasQuote || ((currentFtag & 3) != 0)) ? currentFtag : overflowFtag) & 3;
    }
  }
}

void smSteerPayloadKernel(hls::stream<MspmPayloadFlit> &PayloadInPipe, hls::stream<SmResultMetaFlit> &RidMetaInPipe,
                          hls::stream<MspmPayloadFlit> &PayloadMatchPipe, hls::stream<MspmPayloadFlit> &PayloadSafePipe,
                          hls::stream<SmResultMetaFlit> &RidMetaOutPipe) {
#pragma HLS INTERFACE mode = ap_ctrl_none port = return
#pragma HLS INTERFACE mode = axis port = PayloadInPipe
#pragma HLS INTERFACE mode = axis port = RidMetaInPipe
#pragma HLS INTERFACE mode = axis port = PayloadMatchPipe
#pragma HLS INTERFACE mode = axis port = PayloadSafePipe
#pragma HLS INTERFACE mode = axis port = RidMetaOutPipe

  hls_thread_local hls::stream<BOOL, DFLT_PIPE_DEPTH> SteeringPipe("SteeringPipe");

  hls_thread_local hls::task flagger_task(flagger<SmResultMetaFlit, SM_RESULT_WIDTH, (SM_EXPAND_OVERLOADED != 0)>,
                                          RidMetaInPipe, RidMetaOutPipe, SteeringPipe);
  hls_thread_local hls::task steerPayload_task(steerPayload<MspmPayloadFlit>, SteeringPipe, PayloadInPipe,
                                               PayloadMatchPipe, PayloadSafePipe);
}
