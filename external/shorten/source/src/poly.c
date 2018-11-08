/******************************************************************************
*                                                                             *
*       Copyright (C) 1992-1995 Tony Robinson                                 *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

/*
 * $Id: poly.c,v 1.3 2002/01/27 15:37:21 jason Exp $
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "shorten.h"

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#define ALPHA0 (3.0 / 2.0)
#define ALPHA1 M_LN2

int wav2poly(buf, nbuf, offset, version, psigbit, presbit) slong *buf; int nbuf;
  slong offset; int version; float *psigbit, *presbit;
{
  slong sum0 = 0, sum1 = 0, sum2 = 0, sum3 = 0, sum;
  slong last0 = buf[-1] - offset;
  slong last1 = buf[-1] - buf[-2];
  slong last2 = last1 - (buf[-2] - buf[-3]);
  float alpha = (float) ((version == 0) ? ALPHA0 : ALPHA1);
  int   i, fnd;

  for(i = 0; i < nbuf; i++) {
    slong diff0, diff1, diff2;

    sum0 += labs(diff0 = buf[i] - offset);
    sum1 += labs(diff1 = diff0 - last0);
    sum2 += labs(diff2 = diff1 - last1);
    sum3 += labs(        diff2 - last2);

    last0 = diff0;
    last1 = diff1;
    last2 = diff2;
  }

  if(sum0 < MIN(MIN(sum1, sum2), sum3)) {
    sum = sum0;
    fnd = FN_DIFF0;
  }
  else if(sum1 < MIN(sum2, sum3)) {
    sum = sum1;
    fnd = FN_DIFF1;
  }
  else if(sum2 < sum3) {
    sum = sum2;
    fnd = FN_DIFF2;
  }
  else {
    sum = sum3;
    fnd = FN_DIFF3;
  }

  /* return the expected number of bits per original signal sample */
  *psigbit = (float) ((sum0 > 0) ? log(alpha * sum0 / (double) nbuf) / M_LN2 : 0.0);

  /* return the expected number of bits per residual signal sample */
  *presbit = (float) ((sum  > 0) ? log(alpha * sum  / (double) nbuf) / M_LN2 : 0.0);

  return(fnd);
}
