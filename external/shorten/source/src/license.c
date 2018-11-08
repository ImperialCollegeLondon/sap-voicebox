/*
 * $Id: license.c,v 1.2 2001/12/31 02:49:22 jason Exp $
 */

#include <stdio.h>

#ifdef WINDOWS_MESSAGEBOX
#include <windows.h>
#include <string.h>
#include <malloc.h>
#define LICENSE_PRINT(a) strcat(licenseText,a)
#else
#define LICENSE_PRINT(a) printf(a)
#endif

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

void license() {
#ifdef WINDOWS_MESSAGEBOX
  char *licenseText = malloc(2000);

  if (licenseText) {
    licenseText[0] = '\0';
#endif

  LICENSE_PRINT("SHORTEN SOFTWARE LICENSE\n");
  LICENSE_PRINT("\n");
  LICENSE_PRINT("This software is being provided to you, the LICENSEE, by Tony Robinson\n");
  LICENSE_PRINT("and SoftSound under the following license.  By obtaining, using and/or\n");
  LICENSE_PRINT("copying this software, you agree that you have read, understood, and\n");
  LICENSE_PRINT("will comply with these terms and conditions:\n");
  LICENSE_PRINT("\n");
  LICENSE_PRINT("This software may not be sold or incorporated into any product which is\n");
  LICENSE_PRINT("sold without prior permission from SoftSound.  When no charge is made,\n");
  LICENSE_PRINT("this software may be copied and distributed freely.\n");
  LICENSE_PRINT("\n");
  LICENSE_PRINT("Permission is granted to use this software for decoding and\n");
  LICENSE_PRINT("non-commercial encoding (e.g. private or research use).  Please email\n");
  LICENSE_PRINT("shorten@softsound.com for commercial encoding terms.\n");
  LICENSE_PRINT("\n");
  LICENSE_PRINT("DISCLAIMER\n");
  LICENSE_PRINT("\n");
  LICENSE_PRINT("This software carries no warranty, expressed or implied.  The user\n");
  LICENSE_PRINT("assumes all risks, known or unknown, direct or indirect, which involve\n");
  LICENSE_PRINT("this software in any way.\n");
#ifdef WINDOWS_MESSAGEBOX
  MessageBox(NULL,licenseText,"License",MB_OK | MB_ICONINFORMATION);
  free(licenseText);
  }
#endif
}
