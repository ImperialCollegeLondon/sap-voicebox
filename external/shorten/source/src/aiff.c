/******************************************************************************
*                                                                             *
*       Copyright (C) 2002 Brian Willoughby and Sound Consulting              *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

/*
 * $Id: aiff.c,v 1.5 2003/01/11 01:28:23 jason Exp $
 */

#include <stdio.h>
#include <stdlib.h>

#include "shorten.h"

#define N_CKID	4

#define FORM_SIGNATURE "FORM"
#define AIFF_SIGNATURE "AIFF"
#define AIFC_SIGNATURE "AIFC"
#define COMM_SIGNATURE "COMM"
#define SSND_SIGNATURE "SSND"

ulong bytes;

const char *fread_id(FILE *fp) {
  static char ach[N_CKID];

  if (N_CKID > bytes)
    fprintf(stderr, "possible AIFF error - reading beyond chunk size\n");
  if (N_CKID != fread(ach, sizeof(char), N_CKID, fp))
    return NULL;
  bytes -= N_CKID;
  return ach;
}

/*
 * Portably read a big-endian long integer from a file.
 */
static ulong fread_long_int(fp) FILE *fp; {
  ulong result;

  if (sizeof(ulong) > bytes)
    fprintf(stderr, "possible AIFF error - reading beyond chunk size\n");
  result = ((ulong)fgetc(fp) << 24);
  result |= ((ulong)fgetc(fp) << 16);
  result |= ((ulong)fgetc(fp) << 8);
  result |= (ulong)fgetc(fp);
  bytes -= sizeof(ulong);
  return result;
}

/*
 * Retrieve a big-endian short integer from a char array, again
 * portably.
 */
static ushort short_at(p) unsigned char *p; {
  return ((ushort)p[0] << 8) | p[1];
}
static ulong long_at(p) unsigned char *p; {
  return ((ulong)p[0] << 24) | ((ulong)p[1] << 16) | ((ulong)p[2] << 8) | p[3];
}

/*
 * Write a big-endian long integer into a header chunk.
 */
static void write_hdr_long(data, hdr)
ulong data; Iff_Header *hdr;
{
  uchar realdata[4];
  realdata[0] = (data >> 24) & 0xFF;
  realdata[1] = (data >> 16) & 0xFF;
  realdata[2] = (data >> 8) & 0xFF;
  realdata[3] = data & 0xFF;
  write_hdr (realdata, 4, hdr);
}

Iff_Header *aiff_prochdr(filei, ftype, nchan, datalen, wtype)
FILE *filei; int *ftype, *nchan; slong *datalen; int *wtype;
{
  Iff_Header *hdr;
  const char *ckhdr;
  ulong len;
  int seen_fmt = 0;

  /* Initialize the returned aiff type */
  if (wtype)
    *wtype = 0;

  /* Reserve space for the header structure. */
  hdr = pmalloc(sizeof(*hdr));
  hdr->nblocks = hdr->nblk_alloc = 0;
  hdr->blocks = NULL;
  hdr->blklen = NULL;

  /* Read the AIFF signature. */
  bytes = 8;
  /* NOTE: The following comparison has been moved out to shorten.c
  if (strncmp(fread_id(filei), FORM_SIGNATURE, 4)) {
    goto abort;
  } */
  len = fread_long_int(filei);
  bytes = len;
  ckhdr = fread_id(filei);
  if (!ckhdr)
      goto abort;
  if (strncmp(ckhdr, AIFF_SIGNATURE, 4) && strncmp(ckhdr, AIFC_SIGNATURE, 4)) {
    goto abort;
  }

  /* Write the AIFF signature into the header buffer. */
  write_hdr("FORM", 4, hdr);
  write_hdr_long(len, hdr);
  write_hdr(ckhdr, 4, hdr);

  /* Now begin reading chunks. Give special processing to the "COMM"
   * chunk, end header processing on the "SSND" chunk, and skip
   * everything else. */
  while (!feof(filei)) {
    ulong cklen;
    int len, blklen;
    uchar buf[256];

      ckhdr = fread_id(filei);
      if (!ckhdr)
        goto abort;
      if (!strncmp(ckhdr, SSND_SIGNATURE, 4))
        break;
      cklen = fread_long_int(filei);

      write_hdr(ckhdr, 4, hdr);
    write_hdr_long(cklen, hdr);

    if (!strncmp(ckhdr, COMM_SIGNATURE, 4)) {
      uchar buf[18];
      if (cklen < 18 || fread(buf, 1, 18, filei) < 18) {
        /* We don't understand AIFF files with a header that's too short. */
        goto abort;
      }
      cklen -= 18;
      write_hdr(buf, 18, hdr);
      switch(short_at(buf+6)) {        /* sample size */
      case 8:
        *ftype = TYPE_U8;
        break;
      case 16:
        *ftype = TYPE_S16HL;
        break;
      default:
        /* We don't understand this format */
        if (wtype)
          *wtype = short_at(buf+6);
        goto abort;
      }

      if ((*nchan = short_at(buf)) < 1) { /* at least one channel */
        goto abort;
      }

      *datalen = long_at(buf+2);	/* frames */

      seen_fmt = 1;
    }

    while (cklen > 0 && (len = fread(buf, 1,
          (blklen = MIN(cklen,256)),
          filei)) > 0) {
      write_hdr(buf, blklen, hdr);
      cklen -= blklen;
    }
  }
  if (!seen_fmt) {  /* no fmt chunk before data chunk */
    goto abort;
  }
  write_hdr("SSND", 4, hdr);
  *datalen = fread_long_int(filei);
  write_hdr_long(*datalen, hdr);
  return hdr;

abort:
  free_header(hdr);
  return NULL;
}
