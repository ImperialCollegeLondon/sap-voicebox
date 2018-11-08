/******************************************************************************
*                                                                             *
*       Copyright (C) 1992-1995 Tony Robinson                                 *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

/*
 * $Id: main.c,v 1.2 2001/12/31 02:49:22 jason Exp $
 */

#include <stdio.h>
#include <stdlib.h>
#include "shorten.h"

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

int main(argc, argv) int argc; char **argv; {
  return(shorten(stdin, stdout, argc, argv));
}
