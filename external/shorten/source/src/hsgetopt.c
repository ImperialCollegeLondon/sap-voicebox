/*
 * Copyright (c) 1987, 1989 University of Maryland
 * Department of Computer Science.  All rights reserved.
 * Permission to copy for any purpose is hereby granted
 * so long as this copyright notice remains intact.
 */

/*
 * getopt - get option letter from argv
 * (From Henry Spencer @ U of Toronto Zoology, slightly edited)
 */

/*
 * $Id: hsgetopt.c,v 1.4 2007/03/19 18:04:54 jason Exp $
 */

/*
 * modified by Tony Robinson on 27 March 1993 to remove the call to
 * index() and declare strcmp(); and strlen().
 * 08 Aug 94: these mods deleted and shorten.h included instead.
 */

/*
 * modified by Jon Fiscus on 18 August 1993: renamed to hs_getopt
 * to avoid conflicts with system provided calls.
 */

#include <stdio.h>
#include <string.h>
#include "shorten.h"

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

/* mrhmod - ensure init of static variables */
char *hs_optarg = NULL; /* Global argument pointer. */
int  hs_optind = 0;  /* Global argv index. */

static char *scan = NULL; /* Private scan pointer. */

void hs_resetopt() {
  scan = (char *)0;
  hs_optind = 0;
  hs_optarg = NULL;
}

int
hs_getopt(argc, argv, optstring)
  register int argc;
  register char **argv;
  char *optstring;
{
  register int c;
  register char *place;

  hs_optarg = NULL;
  if (scan == NULL || *scan == 0) {
    if (hs_optind == 0)
      hs_optind++;
    if (hs_optind >= argc || argv[hs_optind][0] != '-' ||
      argv[hs_optind][1] == 0)
      return (EOF);
    if (strcmp(argv[hs_optind], "--") == 0) {
      hs_optind++;
      return (EOF);
    }
    scan = argv[hs_optind] + 1;
    hs_optind++;
  }
  c = *scan++;

 /* BEGIN AJR MOD
    this used to read:
    place = index(optstring, c);
    this code modified from code by Steve Lowe (steve@dragonsys.com)
 */
  {
    char *str = optstring;
    if(str == NULL) place = NULL;
    while((*str != '\0') && (*str != c)) str++;
    if(*str == c) place = str;
    else place = NULL;
  }
 /* END AJR MOD */

  if (place == NULL || c == ':') {
#ifdef _WINDOWS /* mrhmod - avoid attempt to use stderr */
    error_exit("%s: unknown option -%c\n", argv0, c);
#else
    fprintf(stderr, "%s: unknown option -%c\n", argv0, c);
#endif
    return ('?');
  }
  place++;
  if (*place == ':') {
    if (*scan != '\0') {
      hs_optarg = scan;
      scan = NULL;
    } else {
      if (hs_optind >= argc) {
#ifdef _WINDOWS /* mrhmod - avoid attempt to use stderr */
        error_exit("%s: missing argument after -%c\n",
          argv0, c);
#else
        fprintf(stderr,
          "%s: missing argument after -%c\n",
          argv0, c);
#endif
        return ('?');
      }
      hs_optarg = argv[hs_optind];
      hs_optind++;
    }
  }
  return (c);
}
