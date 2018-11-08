/******************************************************************************
*                                                                             *
*       Copyright (C) 1997 Tony Robinson and SoftSound Limited                *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

/*
 * $Id: riffwave.c,v 1.5 2002/11/16 18:03:07 jason Exp $
 */

#include <stdio.h>
#include <stdlib.h>

#include "shorten.h"

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#define BLOCKSIZE 256
#define NBLOCKS_INIT 16

#define RIFF_SIGNATURE 0x46464952   /* "RIFF" */
#define WAVE_SIGNATURE 0x45564157   /* "WAVE" */
#define fmt_SIGNATURE  0x20746D66   /* "fmt " */
#define data_SIGNATURE 0x61746164   /* "data" */

#define WAVE_FORMAT_PCM       0x0001
#define WAVE_FORMAT_ALAW      0x0006
#define WAVE_FORMAT_MULAW     0x0007

/*
 * Portably read a little-endian long integer from a file.
 */
static slong fread_long (fp) FILE *fp; {
  slong result;
  result = fgetc(fp);
  result |= ((slong)fgetc(fp) << 8);
  result |= ((slong)fgetc(fp) << 16);
  result |= ((slong)fgetc(fp) << 24);
  return result;
}

/*
 * Retrieve a little-endian sshort integer from a char array, again
 * portably.
 */
static sshort short_at (p) uchar *p; {
  return ((sshort)p[1] << 8) | p[0];
}

/*
 * Write a load of data into a header chunk.
 */
void write_hdr(buf, len, hdr)
const uchar *buf; int len; Iff_Header *hdr;
{
  while (len--) {
    if (hdr->nblocks == 0 ||
        hdr->blklen[hdr->nblocks-1] == VERBATIM_CHUNK_MAX) {
      hdr->nblocks++;
      if (hdr->nblocks > hdr->nblk_alloc) {
        long size;

        hdr->nblk_alloc += NBLOCKS_INIT;

        size = hdr->nblk_alloc * sizeof(uchar *);
        hdr->blocks = hdr->blocks ? realloc(hdr->blocks, size) : malloc(size);

        if (!hdr->blocks)
          perror_exit("malloc or realloc(%ld)", size);

        size = hdr->nblk_alloc * sizeof(unsigned);
        hdr->blklen = hdr->blklen ? realloc(hdr->blklen, size) : malloc(size);

        if (!hdr->blklen)
          perror_exit("malloc or realloc(%ld)", size);
      }
      hdr->blklen[hdr->nblocks-1] = 0;
      hdr->blocks[hdr->nblocks-1] = pmalloc(sizeof(uchar) *
        VERBATIM_CHUNK_MAX);
    }
    hdr->blocks[hdr->nblocks-1][hdr->blklen[hdr->nblocks-1]++] = *buf++;
  }
}

/*
 * Write a little-endian long integer into a header chunk.
 */
static void write_hdr_long(data, hdr)
ulong data; Iff_Header *hdr;
{
  uchar realdata[4];
  realdata[0] = data & 0xFF;
  realdata[1] = (data >> 8) & 0xFF;
  realdata[2] = (data >> 16) & 0xFF;
  realdata[3] = (data >> 24) & 0xFF;
  write_hdr (realdata, 4, hdr);
}

Iff_Header *riff_wave_prochdr (filei, ftype, nchan, datalen, wtype)
FILE *filei; int *ftype, *nchan; slong *datalen; int *wtype;
{
  Iff_Header *hdr;
  slong len, ckhdr;
  int seen_fmt = 0;

  /* Initialize the returned wave type */
  if (wtype)
    *wtype = 0;

  /* Reserve space for the header structure. */
  hdr = pmalloc(sizeof(*hdr));
  hdr->nblocks = hdr->nblk_alloc = 0;
  hdr->blocks = NULL;
  hdr->blklen = NULL;

  /* Read the RIFF signature. */
  /* NOTE: This comparison has been moved out to shorten.c to support AIFF
  if (fread_long(filei) != RIFF_SIGNATURE) {
    free_header(hdr);
    return NULL;
  }
  */
  if ((len = fread_long(filei)) < 12 ||
      fread_long(filei) != WAVE_SIGNATURE) {
    free_header(hdr);
    return NULL;
  }

  /* Write the RIFF signature into the header buffer. */
  write_hdr_long((slong)RIFF_SIGNATURE, hdr);
  write_hdr_long(len, hdr);
  write_hdr_long((slong)WAVE_SIGNATURE, hdr);

  /* Now begin reading chunks. Give special processing to the "fmt"
   * chunk, end header processing on the "data" chunk, and skip
   * everything else. */
  while (!feof(filei) && (ckhdr = fread_long(filei)) != data_SIGNATURE) {
    slong cklen = fread_long(filei);
    int len, blklen;
    uchar buf[256];

    write_hdr_long(ckhdr, hdr);
    write_hdr_long(cklen, hdr);

    if (ckhdr == fmt_SIGNATURE) {
      uchar buf[16];
      if (cklen < 16 || fread(buf, 1, 16, filei) < 16) {
        /* We don't understand WAVE files with a header that's too short. */
        free_header(hdr);
        return NULL;
      }
      cklen -= 16;
      write_hdr(buf, 16, hdr);
      switch(short_at(buf)) {        /* WAVE_FORMAT */
      case WAVE_FORMAT_PCM:
        switch (short_at(buf+14)) {   /* bits per sample */
        case 8:
          *ftype = TYPE_U8;
          break;
        case 16:
          *ftype = TYPE_S16LH;
          break;
        default:
          free_header(hdr);
          return NULL;
        }
        break;
      case WAVE_FORMAT_MULAW:
        *ftype = TYPE_GENERIC_ULAW;
        break;
             case WAVE_FORMAT_ALAW:
        *ftype = TYPE_GENERIC_ALAW;
        break;
      default:
        /* We don't understand this format */
        free_header(hdr);
        if (wtype)
          *wtype = short_at(buf);
        return NULL;
      }

      if ((*nchan = short_at(buf+2)) < 1) { /* at least one channel */
        free_header(hdr);
        return NULL;
      }

      seen_fmt = 1;
    }

    while (cklen > 0 && (len = fread(buf, 1,
          (blklen = MIN(cklen,256)),
          filei)) > 0) {
      write_hdr (buf, blklen, hdr);
      cklen -= blklen;
    }
  }
  if (!seen_fmt) {  /* no fmt chunk before data chunk */
    free_header(hdr);
    return NULL;
  }
  write_hdr_long (data_SIGNATURE, hdr);
  write_hdr_long (*datalen = fread_long(filei), hdr);
  return hdr;
}

static void write_verbatim_chunk (data, len, fileo)
uchar *data; int len; FILE *fileo;
{
  uvar_put((ulong) FN_VERBATIM, FNSIZE, fileo);
  uvar_put((ulong) len, VERBATIM_CKSIZE_SIZE, fileo);
  while (len--) {
    uvar_put ((ulong) *data, VERBATIM_BYTE_SIZE, fileo);
    data++;
  }
}

void write_header (hdr, fileo)
Iff_Header *hdr; FILE *fileo;
{
  uchar **blocks;
  unsigned *blklen;
  int nblocks;

  nblocks = hdr->nblocks;
  blocks = hdr->blocks;
  blklen = hdr->blklen;
  while (nblocks--)
    write_verbatim_chunk (*blocks++, *blklen++, fileo);
}

void verbatim_file (filei, fileo)
FILE *filei, *fileo;
{
  uchar buf[VERBATIM_CHUNK_MAX];
  int len;

  while ( (len = fread(buf, 1, VERBATIM_CHUNK_MAX, filei)) > 0)
    write_verbatim_chunk (buf, len, fileo);
}

void free_header (hdr)
Iff_Header *hdr;
{
  uchar **blocks;
  int nblocks;

  if (hdr) {
    if (hdr->blocks) {
      nblocks = hdr->nblocks;
      blocks = hdr->blocks;

      while (nblocks--)
        free (*blocks++);

      free (hdr->blocks);
    }
    if (hdr->blklen)
      free (hdr->blklen);
    free (hdr);
  }
}
