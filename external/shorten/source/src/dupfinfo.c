/******************************************************************************
*                                                                             *
*       Copyright (C) 1992-1995 Tony Robinson                                 *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

/*
 * $Id: dupfinfo.c,v 1.4 2002/01/27 16:02:53 jason Exp $
 */

/*
 * set the atime and mtime of path1 to be the same as that of path0
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#if defined(MSDOS) || defined(_WINDOWS)
#include <io.h>
#include <sys/utime.h>
#else
#include <utime.h>
#include <unistd.h>
#endif
#include "shorten.h"

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

int dupfileinfo(path0, path1) char *path0, *path1; {
  int errcode;
  struct stat buf;

  errcode = stat(path0, &buf);
  if(!errcode) {
    struct utimbuf ftime;

    /* do what can be done, and igore errors */
    (void) chmod(path1, buf.st_mode);
    ftime.actime  = buf.st_atime;
    ftime.modtime = buf.st_mtime;
    (void) utime(path1, &ftime);
#ifdef unix
    (void) chown(path1, buf.st_uid, -1);
    (void) chown(path1, -1, buf.st_gid);
#endif
  }
  return(errcode);
}

#ifdef PROGTEST
int main(int argc, char **argv) {
  return(dupfileinfo(argv[1], argv[2]));
}
#endif
