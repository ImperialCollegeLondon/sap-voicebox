/******************************************************************************
*                                                                             *
*       Copyright (C) 1992-1995 Tony Robinson                                 *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

/*
 * $Id: vario.c,v 1.3 2002/01/28 01:16:52 jason Exp $
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "shorten.h"

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

extern char *argv0;
extern int ReadingFunctionCode;
extern ulong SHNFilePosition;
extern ushort SHNBitPosition;
extern ulong SHNGBuffer;
extern ulong LastBufferReadPosition;
extern ulong SHNLastBufferReadPosition;
extern ushort SHNByteGet;
extern ushort SHNBufferOffset;

#define MASKTABSIZE 33
ulong masktab[MASKTABSIZE];

void mkmasktab() {
  int i;
  ulong val = 0;

  masktab[0] = val;
  for(i = 1; i < MASKTABSIZE; i++) {
    val <<= 1;
    val |= 1;
    masktab[i] = val;
  }
}

static uchar *putbuf;
static uchar *putbufp;
static ulong  pbuffer;
static int    nbitput;

void var_put_init() {
  mkmasktab();

  putbuf   = (uchar*) pmalloc((ulong) BUFSIZ);
  putbufp  = putbuf;
  pbuffer  = 0;
  nbitput  = 0;
}

static uchar *getbuf;
static uchar *getbufp;
static int    nbyteget;
static ulong  gbuffer;
static int    nbitget;

void var_get_init() {
  mkmasktab();

  getbuf   = (uchar*) pmalloc((ulong) BUFSIZ);
  getbufp  = getbuf;
  nbyteget = 0;
  gbuffer  = 0;
  nbitget  = 0;
}

void word_put(buffer, stream) ulong buffer; FILE *stream; {

  *putbufp++ = buffer >> 24;
  *putbufp++ = buffer >> 16;
  *putbufp++ = buffer >>  8;
  *putbufp++ = buffer;

  if(putbufp - putbuf == BUFSIZ) {
    if(fwrite((char*) putbuf, 1, BUFSIZ, stream) != BUFSIZ)
      update_exit(1, "failed to write compressed stream\n");

    putbufp = putbuf;
  }
}

void uvar_put(val, nbin, stream) ulong val; int nbin; FILE *stream; {
  ulong lobin, nsd;
  int  i, nlobin;

  if(nbin >= MASKTABSIZE)
    update_exit(1, "overflow of masktab[%d]\n", MASKTABSIZE);

  lobin = (1L << nbin) | (val & masktab[nbin]);
  nsd = val >> nbin;
  nlobin = nbin + 1;

  if(nbitput + nsd >= 32) {
    for(i = 0; i < ((nbitput + nsd) >> 5); i++) {
      word_put(pbuffer, stream);
      pbuffer = 0;
    }
    nbitput = (nbitput + nsd) % 32;
  }
  else
    nbitput += nsd;

  while(nlobin != 0) {
    if(nbitput + nlobin >= 32) {
      pbuffer |= (lobin >> (nbitput + nlobin - 32));
      word_put(pbuffer, stream);
      pbuffer = 0;
      nlobin -= 32 - nbitput;
      nbitput = 0;
    }
    else {
      nbitput += nlobin;
      pbuffer |= (lobin << (32 - nbitput));
      nlobin = 0;
    }
  }
}

void ulong_put(val, stream) ulong val; FILE *stream; {
  int i, nbit;

  for(i = 31; i >= 0 && (val & (1L << i)) == 0; i--);
  nbit = i + 1;

  uvar_put((ulong) nbit, ULONGSIZE, stream);
  uvar_put(val & masktab[nbit], nbit, stream);
}

ulong word_get(FILE *stream)
{
  ulong buffer;

  if(nbyteget < 4)
  {
    int bytes;
/*    LastBufferReadPosition = (ulong)ftell(stream); */
    LastBufferReadPosition = bytes_read;
    bytes = fread((char*) getbuf, 1, BUFSIZ, stream);
    nbyteget += bytes;
    if(nbyteget < 4)
      update_exit(1, "premature EOF on compressed stream\n");
    bytes_read += bytes;
    getbufp = getbuf;
  }

  buffer = (((slong) getbufp[0]) << 24) | (((slong) getbufp[1]) << 16) |
    (((slong) getbufp[2]) <<  8) | ((slong) getbufp[3]);

  getbufp += 4;
  nbyteget -= 4;

  return(buffer);
}

slong uvar_get(nbin, stream) int nbin; FILE *stream;
{
  slong result;

  if(ReadingFunctionCode == TRUE)
  {
    SHNLastBufferReadPosition = (ulong)  LastBufferReadPosition;
    SHNFilePosition           = (ulong)  ftell(stream);
    SHNBitPosition            = (ushort) nbitget;
    SHNGBuffer                = (ulong)  gbuffer;
    SHNByteGet                = (ushort) nbyteget;
    SHNBufferOffset           = (ushort) (getbufp-getbuf);
  }

  if(nbitget == 0)
  {
    gbuffer = word_get(stream);
    nbitget = 32;
  }

  for(result = 0; !(gbuffer & (1L << --nbitget)); result++)
  {
    if(nbitget == 0)
    {
      gbuffer = word_get(stream);
      nbitget = 32;
    }
  }

  while(nbin != 0)
  {
    if(nbitget >= nbin)
    {
      result = (result << nbin) | ((gbuffer >> (nbitget-nbin)) &masktab[nbin]);
      nbitget -= nbin;
      nbin = 0;
    }
    else
    {
      result = (result << nbitget) | (gbuffer & masktab[nbitget]);
      gbuffer = word_get(stream);
      nbin -= nbitget;
      nbitget = 32;
    }
  }

  return(result);
}

ulong ulong_get(stream) FILE *stream; {
  unsigned int nbit = uvar_get(ULONGSIZE, stream);
  return(uvar_get(nbit, stream));
}

void var_put(val, nbin, stream) slong val; int nbin; FILE *stream; {
  if(val < 0) uvar_put((ulong) ((~val) << 1) | 1L, nbin + 1, stream);
  else uvar_put((ulong) ((val) << 1), nbin + 1, stream);
}

void var_put_quit(stream) FILE *stream; {
  /* flush to a word boundary */
  uvar_put((ulong) 0, 31, stream);

  /* and write out the remaining chunk in the buffer */
  if(fwrite((char*) putbuf, 1, putbufp - putbuf, stream) != putbufp - putbuf)
    update_exit(1, "failed to write compressed stream\n");

  free((char*) putbuf);
}

slong var_get(nbin, stream) int nbin; FILE *stream; {
  ulong uvar = (ulong) uvar_get(nbin + 1, stream);

  if(uvar & 1) return((slong) ~(uvar >> 1));
  else return((slong) (uvar >> 1));
}

void var_get_quit() {
  free((char*) getbuf);
}

int sizeof_uvar(val, nbin) ulong val; int nbin; {
  return((val >> nbin) + nbin);
}

int sizeof_var(val, nbin) slong val; int nbin; {
  return((labs(val) >> nbin) + nbin + 1);
}
