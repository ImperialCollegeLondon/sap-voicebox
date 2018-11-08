/******************************************************************************
*                                                                             *
*       Copyright (C) 1992-1997 Tony Robinson and SoftSound Limited           *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

/*
 * $Id: shorten.c,v 1.30 2007/03/19 19:48:01 jason Exp $
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#if defined(_WINDOWS) || defined(HAVE_WINDOWS_H)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef MSDOS
#include <io.h>
#include <fcntl.h>
#ifdef MSDOS_DO_TIMING
#include <time.h>
#endif
#else
#ifndef _WINDOWS
#include <unistd.h>
#endif
#include <errno.h>
#endif

#include <setjmp.h>
#include "shorten.h"

#ifdef WIN32
#define PATHSEPCHAR '\\'
#else
#define PATHSEPCHAR '/'
#endif

#define V2LPCQOFFSET (1 << LPCQUANT);

#define UINT_PUT(val, nbit, file) \
  if(version == 0) uvar_put((ulong) val, nbit, file); \
  else ulong_put((ulong) val, file)

#define UINT_GET(nbit, file) \
  ((version == 0) ? uvar_get(nbit, file) : ulong_get(file))

#define VAR_PUT(val, nbit, file) \
  if(version == 0) var_put((ulong) val, nbit - 1, file); \
  else var_put((ulong) val, nbit, file)

#define FILESUFFIX ".shn"
#define WAVESUFFIX ".wav"

extern char *exitmessage;

char *readmode = "rb";
char *writemode = "wb";
char *argv0 = NULL;
char *filenameo = NULL;

int  getc_exit_val;
int  Pass=0;

int  saw_e_op = FALSE;
int  saw_i_op = FALSE;
int  saw_k_op = FALSE;
int  saw_s_op = FALSE;
int  saw_S_op = FALSE;
int  saw_x_op = FALSE;

ulong bytes_read = 0;

FILE *fileo = NULL;

/* globals for seek table */

ulong SampleNumber=0;
ulong SHNFilePosition=0;
ulong SHNLastBufferReadPosition=0;
ushort SHNByteGet=0;
ushort SHNBufferOffset=0;
ushort SHNBitPosition=0;
ulong SHNGBuffer=0;

ulong LastBufferReadPosition;

int ReadingFunctionCode=FALSE;
int WriteSeekTable=TRUE;
int WriteWaveFile=FALSE;
int AppendSeekInfo=FALSE;
int DupFileInfo=FALSE;

slong CBuf_0_Minus1 = 0;
slong CBuf_0_Minus2 = 0;
slong CBuf_0_Minus3 = 0;

slong CBuf_1_Minus1 = 0;
slong CBuf_1_Minus2 = 0;
slong CBuf_1_Minus3 = 0;

slong Offset_0_0 = 0;
slong Offset_0_1 = 0;
slong Offset_0_2 = 0;
slong Offset_0_3 = 0;

slong Offset_1_0 = 0;
slong Offset_1_1 = 0;
slong Offset_1_2 = 0;
slong Offset_1_3 = 0;

typedef struct tag_TSeekTableHeader
{
  uchar data[SEEK_HEADER_SIZE];
}TSeekTableHeader;

typedef struct tag_TSeekTableTrailer
{
  uchar data[SEEK_TRAILER_SIZE];
}TSeekTableTrailer;

typedef struct tag_TSeekEntry
{
  uchar data[SEEK_ENTRY_SIZE];
}TSeekEntry;

/* old way, kept for reference.
   (changed because some compilers apparently don't support #pragma pack(1))

typedef struct tag_TSeekTableHeader
{
  char Signature[4];
  ulong Version;
  unsigned long SHNFileSize;
}TSeekTableHeader;

typedef struct tag_TSeekTableTrailer
{
  unsigned long SeekTableSize;
  char Signature[8];
}TSeekTableTrailer;

typedef struct tag_TSeekEntry
{
  unsigned long SampleNumber;
  unsigned long SHNFileByteOffset;
  unsigned long SHNLastBufferReadPosition;
  unsigned short SHNByteGet;
  unsigned short SHNBufferOffset;
  unsigned short SHNFileBitOffset;
  unsigned long SHNGBuffer;
  unsigned short SHNBitShift;
  long CBuf0[3];
  long CBuf1[3];
  long Offset0[4];
  long Offset1[4];
}TSeekEntry;
*/

void init_offset(slong **offset,int nchan,int nblock,int ftype)
{
  slong mean = 0;
  int  chan, i;

  /* initialise offset */
  switch(ftype)
  {
    case TYPE_AU1:
    case TYPE_S8:
    case TYPE_S16HL:
    case TYPE_S16LH:
    case TYPE_ULAW:
    case TYPE_AU2:
    case TYPE_AU3:
    case TYPE_ALAW:
      mean = 0;
      break;
    case TYPE_U8:
      mean = 0x80;
      break;
    case TYPE_U16HL:
    case TYPE_U16LH:
      mean = 0x8000;
      break;
    default:
      update_exit(1, "unknown file type: %d\n", ftype);
  }

  for(chan = 0; chan < nchan; chan++)
    for(i = 0; i < nblock; i++)
      offset[chan][i] = mean;
}

float Satof(char *string)
{
  int i, rval = 1;

  /* this should have tighter checking */
  for(i = 0; i < (int) strlen(string) && rval == 1; i++)
    if(string[i] != '.' && (string[i] < '0' || string[i] > '9'))
      usage_exit(1, "non-parseable float: %s\n", string);
  return((float) atof(string));
}

float* parseList(char *maxresnstr,int nchan)
{
  int   nval;
  char  *str, *floatstr;
  float *floatval;

  /* copy maxresnstr to temporary space, str */
  str = malloc(strlen(maxresnstr) + 1);
  strcpy(str, maxresnstr);

  /* grab space for the floating point parses */
  floatval = pmalloc((ulong) (nchan * sizeof(*floatval)));

  /* loop for all floats in the arguement */
  floatstr = strtok(str, ",");
  floatval[0] = Satof(floatstr);

  for(nval = 1; (floatstr = strtok(NULL, ",")) != NULL && nval < nchan;nval++)
    floatval[nval] = Satof(floatstr);

  for(; nval < nchan; nval++)
    floatval[nval] = floatval[nval - 1];

  free(str);

  return(floatval);
}

#ifdef _WINDOWS

/* Function to check whether shorten should abort, when running as a windows program */
static void CheckWindowsAbort(void)
{

#ifndef WIN32
  /* If we are not in Win32, we need to put in a Windows message handler to
  ** allow 'multi tasking' to continue.
  ** WIN32 (Windows 95 and NT) does not need to do this, as proper preemptive
  ** multitasking & threading is implemented
  */
  MSG localMessage;

  while (PeekMessage(&localMessage,NULL,0,0,PM_REMOVE))
  {
    TranslateMessage(&localMessage);
    DispatchMessage(&localMessage);
  }
#endif

#ifdef WINDOWS_ABORT_ALLOWED
  /* If abort is allowed, see if the abort flag has been set: */
  {
    extern int abortFlag;
    if (abortFlag)
    {
      /* If the abort flag is set, it means we should terminate processing */
      usage_exit(-2, PACKAGE " stopped by user\n");
    }
  }
#endif
}
#endif

#if defined(MSDOS) || defined(_WINDOWS)
int _export __stdcall _CallShorten(int argc, char **argv, char *errorString, int errorStringLength)
{
  exitmessage=errorString;
  return(shorten(stdin,stdout,argc,argv));
}
#endif

ulong uchar_to_ulong_le(uchar * buf)
/* converts 4 bytes stored in little-endian format to a ulong */
{
  return (ulong)((buf[3] << 24) + (buf[2] << 16) + (buf[1] << 8) + buf[0]);
}

void ulong_to_uchar_le(uchar * buf,ulong num)
/* converts a ulong to 4 bytes stored in little-endian format */
{
  uchar tmp[4];

  tmp[0] = (uchar)(num);
  tmp[1] = (uchar)(num >> 8);
  tmp[2] = (uchar)(num >> 16);
  tmp[3] = (uchar)(num >> 24);
  buf[0] = tmp[0];
  buf[1] = tmp[1];
  buf[2] = tmp[2];
  buf[3] = tmp[3];
}

void long_to_uchar_le(uchar * buf,slong num)
{
  ulong_to_uchar_le(buf,(ulong)num);
}

void ushort_to_uchar_le(uchar * buf,ushort num)
/* converts a ushort to 2 bytes stored in little-endian format */
{
  uchar tmp[2];

  tmp[0] = (uchar)(num);
  tmp[1] = (uchar)(num >> 8);
  buf[0] = tmp[0];
  buf[1] = tmp[1];
}

BOOL FileHasSeekInfoAppended(FILE *filei,ulong *seektable_version)
{
  char SeekTrailerSignature[9]="SHNAMPSK";
  char SeekHeaderSignature[5]="SEEK";
  TSeekTableTrailer SeekTrailer;
  TSeekTableHeader SeekHeader;

  long InitialPosition=ftell(filei);

  fseek(filei,-SEEK_TRAILER_SIZE,SEEK_END);
  fread(SeekTrailer.data,1,SEEK_TRAILER_SIZE,filei);

  if(0==memcmp(SeekTrailerSignature,SeekTrailer.data+4,8)) {
    if (seektable_version) {
      fseek(filei,-uchar_to_ulong_le(SeekTrailer.data),SEEK_END);
      fread(SeekHeader.data,1,SEEK_HEADER_SIZE,filei);

      if (0==memcmp(SeekHeaderSignature,SeekHeader.data,4)) {
        *seektable_version = uchar_to_ulong_le(SeekHeader.data+4);
      }
      else {
        *seektable_version = -1;
      }
    }

    fseek(filei,InitialPosition,SEEK_SET);
    return TRUE;
  }

  fseek(filei,InitialPosition,SEEK_SET);
  return FALSE;
}

BOOL FileIsExternalSeekTable(FILE *filei,ulong *seektable_version)
{
  char SeekHeaderSignature[5]="SEEK";
  TSeekTableHeader SeekHeader;

  long InitialPosition=ftell(filei);

  fread(SeekHeader.data,1,SEEK_HEADER_SIZE,filei);

  if (0==memcmp(SeekHeaderSignature,SeekHeader.data,4)) {
    if (seektable_version) {
      *seektable_version = uchar_to_ulong_le(SeekHeader.data+4);
    }

    fseek(filei,InitialPosition,SEEK_SET);
    return TRUE;
  }

  fseek(filei,InitialPosition,SEEK_SET);
  return FALSE;
}

void ShowSeekInfo(FILE *f,char *filename)
{
  ulong seektable_version;

  if (FileIsExternalSeekTable(f,&seektable_version)) {
    fprintf(stderr,"File '%s' is an external seek table file (revision %lu).\n",filename,(unsigned long)seektable_version);
    return;
  }

  if (FileHasSeekInfoAppended(f,&seektable_version)) {
    fprintf(stderr,"File '%s' contains appended seek tables (revision %lu).\n",filename,(unsigned long)seektable_version);
    return;
  }

  fprintf(stderr,"File '%s' does not contain seek information.\n",filename);
}

#ifdef WIN32
int truncate(char *filename,int filesize)
{ 
  HANDLE hFile;

  if (INVALID_HANDLE_VALUE == (hFile = CreateFile(filename,GENERIC_WRITE|GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)))
    return -1;

  SetFilePointer(hFile,filesize,NULL,FILE_BEGIN);

  SetEndOfFile(hFile);
  
  CloseHandle(hFile);

  return 0;
}
#endif

void RemoveSeekInfo(char *filename)
{
#if defined(HAVE_TRUNCATE) || defined(WIN32)
  ulong SHNFileSize,sktSize;
  TSeekTableTrailer Trailer;
  FILE *f;

  f=fopen(filename,"rb");
  if(!f)
    usage_exit(1,"failure opening '%s': %s\n",filename,strerror(errno));

  fseek(f,0,SEEK_END);
  SHNFileSize=(ulong)ftell(f);

  fseek(f,-SEEK_TRAILER_SIZE,SEEK_END);
  fread(&Trailer,SEEK_TRAILER_SIZE,1,f);
  fclose(f);

  sktSize = uchar_to_ulong_le(Trailer.data);

  SHNFileSize -= sktSize;

  fprintf(stderr,"removing seek table from file '%s'\n",filename);

  if (0 != truncate(filename,SHNFileSize))
#ifdef WIN32
    fprintf(stderr,"error: could not truncate file: Win32 error code %d\n",GetLastError());
#else
    fprintf(stderr,"error: could not truncate file: %s\n",strerror(errno));
#endif
#else
  fprintf(stderr,"error: Your system does not seem to support the truncate() function.\n");
  fprintf(stderr,"       Please report this error to <shnutils@freeshell.org>.\n");
#endif
}

void check_conflicting_options()
{
  if (saw_e_op && saw_i_op)
    usage_exit(1, "cannot use -e with -i\n");

  if (saw_x_op && saw_k_op)
    usage_exit(1, "cannot use -x with -k\n");

  if (saw_e_op && saw_x_op)
    usage_exit(1, "cannot use -e with -x\n");

  if (saw_e_op && saw_k_op)
    usage_exit(1, "cannot use -e with -k\n");

  if (saw_i_op && saw_x_op)
    usage_exit(1, "cannot use -i with -x\n");

  if (saw_i_op && saw_k_op)
    usage_exit(1, "cannot use -i with -k\n");

  if (saw_s_op && saw_S_op)
    usage_exit(1, "cannot use -s with -S\n");

  if (saw_x_op && saw_s_op)
    usage_exit(1, "cannot use -x with -s\n");

  if (saw_x_op && saw_S_op)
    usage_exit(1, "cannot use -x with -S\n");

  if (saw_k_op && saw_s_op)
    usage_exit(1, "cannot use -k with -s\n");

  if (saw_k_op && saw_S_op)
    usage_exit(1, "cannot use -k with -S\n");
}

int shorten(FILE *stdi, FILE *stdo,int argc,char **argv)
{
  TSeekTableHeader SeekTableHeader;
  TSeekTableTrailer SeekTableTrailer;

  slong  **buffer, **offset;
  slong  lpcqoffset = 0;
  int   version = MAX_SUPPORTED_VERSION, extract = 0, lastbitshift = 0, bitshift = 0, want_seeking = 1;
  int   hiloint = 1, hilo = !(*((char*) &hiloint));
  int   ftype = TYPE_EOF;
  char  *magic = MAGIC, *filenamei = NULL, *filenamei_orig = NULL, *dupfilenamei = NULL, *dupfilenameo = NULL;
  char  *tmpfilename = NULL;
  char  *maxresnstr = DEFAULT_MAXRESNSTR;
  FILE  *filei = 0;
  int   blocksize = DEFAULT_BLOCK_SIZE, nchan = DEFAULT_NCHAN;
  int   i, chan, nwrap, nskip = DEFAULT_NSKIP, ndiscard = DEFAULT_NDISCARD;
  int   *qlpc = NULL, maxnlpc = DEFAULT_MAXNLPC, nmean = UNDEFINED_UINT;
  int   quanterror = DEFAULT_QUANTERROR, minsnr = DEFAULT_MINSNR, nfilename;
  int   ulawZeroMerge = 0;
  slong  datalen = -1;
  Iff_Header *wavhdr = NULL;
  char  *minusstr  = "-";
  extern char *hs_optarg;
  extern int   hs_optind;
  ulong WriteCount=0;
  char SeekTableFilename[MAX_PATH];
  FILE *SeekTableFile=0;
  char *p;

#ifdef MSDOS
#ifdef MSDOS_DO_TIMING
  clock_t startTime, endTime;

  startTime = clock();
#endif
#endif

  argv0 = ((p = strrchr(argv[0],PATHSEPCHAR))) ? (p + 1) : argv[0];

#ifdef _WINDOWS
/* Need to set the FILE pointers to null, so we know if they have to be closed on abort */
  filei = fileo = NULL;

  /* Now we need to set up the error handler for Windows */
  {
    extern jmp_buf exitenv;
    int retVal;

    if ((retVal = setjmp(exitenv)) != 0)
    {
      /* If an error, make sure (at least) that files are closed.
         fileo will already have been closed in basic_exit();
         Plugging of memory leaks will be dealt with in a future release */
      if (filei)
        fclose(filei);
      return retVal;
    }
  }
#endif

  /* initialize the seek table header and trailer */
  SeekTableHeader.data[0]='S';
  SeekTableHeader.data[1]='E';
  SeekTableHeader.data[2]='E';
  SeekTableHeader.data[3]='K';
  ulong_to_uchar_le(SeekTableHeader.data+4,SEEK_TABLE_REVISION);
  ulong_to_uchar_le(SeekTableHeader.data+8,0);

  SeekTableTrailer.data[4]='S';
  SeekTableTrailer.data[5]='H';
  SeekTableTrailer.data[6]='N';
  SeekTableTrailer.data[7]='A';
  SeekTableTrailer.data[8]='M';
  SeekTableTrailer.data[9]='P';
  SeekTableTrailer.data[10]='S';
  SeekTableTrailer.data[11]='K';

  strcpy(SeekTableFilename,"");

  /* this block just processes the command line arguments */
  {
    int c;

    hs_resetopt();

    while((c = hs_getopt(argc, argv, "a:b:c:d:ekhilm:n:p:q:r:sS:t:uv:x")) != -1)
      switch(c)
      {
        case 'a':
          if((nskip = atoi(hs_optarg)) < 0)
            usage_exit(1, "number of bytes to copy must be positive\n");
          break;
        case 'b':
          if((blocksize = atoi(hs_optarg)) <= 0)
            usage_exit(1, "block size must be greater than zero\n");
          break;
        case 'c':
          if((nchan = atoi(hs_optarg)) <= 0)
            usage_exit(1, "number of channels must be greater than zero\n");
          break;
        case 'd':
          if((ndiscard = atoi(hs_optarg)) < 0)
            usage_exit(1, "number of bytes to discard must be positive\n");
          break;
        case 'e':
          saw_e_op = TRUE;
          break;
        case 'i':
          saw_i_op = TRUE;
          break;
        case 'h':
#ifdef _WINDOWS
          {
#endif
#define PRINTF0(a) fprintf(stderr,a)
#define PRINTF1(a,b) fprintf(stderr,a,b)
#define PRINTF2(a,b,c) fprintf(stderr,a,b,c)
#define PRINTF3(a,b,c,d) fprintf(stderr,a,b,c,d)

            PRINTF2("%s version %s: (c) 1992-1999 Tony Robinson and SoftSound Ltd\n",
            PACKAGE, VERSION);
            PRINTF0("Seek extensions by Wayne Stielau; UNIX maintenance by Jason Jordan\n");
/*
            PRINTF0("for more information see http://www.softsound.com/Shorten.html\n");
*/
#ifdef OLDHELP
            PRINTF1("usage: %s [-hx] [-a #byte] [-b #sample] [-c #channel] [-d #discard]\n\t[-m #block] [-p #delay] [-q #bit] [-r #bit] [-s] [-t filetype]\n\t[input file] [output file]\n", argv0);
#endif
            PRINTF1("Usage: %s {options} [input file] [output file]\n", argv0);
            PRINTF1("  -a %-5d bytes to copy verbatim to align file\n", DEFAULT_NSKIP);
            PRINTF1("  -b %-5d block size\n", DEFAULT_BLOCK_SIZE);
            PRINTF1("  -c %-5d number of channels\n", DEFAULT_NCHAN);
            PRINTF1("  -d %-5d number of bytes to discard before compression or decompression\n", DEFAULT_NDISCARD);
            PRINTF0("  -e       erase seek table appended to input file\n");
            PRINTF0("  -h       help (this message)\n");
            PRINTF0("  -i       inquire as to whether a seek table is appended to input file\n");
            PRINTF0("  -k       append seek table information to existing shorten file\n");
            PRINTF0("  -l       print the license giving the distribution and usage conditions\n");
            PRINTF1("  -m %-5d number of past block for mean estimation\n",(FORMAT_VERSION < 2) ? DEFAULT_V0NMEAN : DEFAULT_V2NMEAN);
            PRINTF2("  -n %-5d minimum signal to noise ratio in dB (%d == lossless coding)\n",DEFAULT_MINSNR, DEFAULT_MINSNR);
            PRINTF1("  -p %-5d maximum LPC predictor order (0 == fast polynomial predictor)\n", DEFAULT_MAXNLPC);
            PRINTF1("  -q %-5d acceptable quantisation error in bits\n",DEFAULT_QUANTERROR);
            PRINTF2("  -r %-5s maximum number of bits per sample (%s == lossless coding)\n",DEFAULT_MAXRESNSTR, DEFAULT_MAXRESNSTR);
            PRINTF0("  -s       generate seek table information in separate file [input file].skt\n");
            PRINTF0("  -S[name] generate seek table information in separate file given by [name]\n");
            PRINTF0("  -t wav   specify the bit packing and byte ordering of the sample file from\n           {aiff,wav,ulaw,alaw,s8,u8,s16,u16,s16x,u16x,s16hl,u16hl,s16lh,u16lh}\n");
            PRINTF0("  -u       merge the two zero codes in ulaw files\n");
            PRINTF1("  -v %-5d format version number (2: no seek info; 3: default)\n", MAX_SUPPORTED_VERSION);
            PRINTF0("  -x       extract (all other options except -a, -d and -t are ignored)\n");
#ifdef _WINDOWS
#ifdef WINDOWS_MESSAGEBOX
            MessageBox(NULL,totalMessage,"Shorten Help",MB_OK | MB_ICONINFORMATION);
            basic_exit(0);
#else
            error_exit("%s: usage: %s {options} [input file] [output file]\n",argv0, argv0);
#endif
          }
#else
          basic_exit(0);
#endif
#undef PRINTF0
#undef PRINTF1
#undef PRINTF2
#undef PRINTF3
          break;
        case 'k':
          saw_k_op = TRUE;
          AppendSeekInfo=TRUE;
          extract = 1;
          WriteWaveFile=FALSE;
          WriteSeekTable=TRUE;
          if (!strcmp(SeekTableFilename,""))
            SeekTableFilename[0]=0;
          break;
        case 'l':
          license();
          basic_exit(0);
          break;
        case 'm':
          if((nmean = atoi(hs_optarg)) < 0)
            usage_exit(1, "number of blocks for mean estimation must be positive\n");
          break;
        case 'n':
          if((minsnr = atoi(hs_optarg)) < 0)
            usage_exit(1, "Useful signal to noise ratios are positive\n");
          break;
        case 'p':
          maxnlpc = atoi(hs_optarg);
          if(maxnlpc < 0 || maxnlpc > MAX_LPC_ORDER)
            usage_exit(1, "linear prediction order must be in the range 0 ... %d\n", MAX_LPC_ORDER);
          break;
        case 'q':
          if((quanterror = atoi(hs_optarg)) < 0)
            usage_exit(1, "quantisation level must be positive\n");
          break;
        case 'r':
          maxresnstr = hs_optarg;
          break;
        case 'S':
          saw_S_op = TRUE;
          if (argv[hs_optind-1][0] != '-' || argv[hs_optind-1][1] != 'S')
            usage_exit(1, "missing seek table filename for -S\n");
          else
            strcpy(SeekTableFilename,hs_optarg);
          extract = 1;
          WriteWaveFile=FALSE;
          WriteSeekTable=TRUE;
          break;
        case 's':
          saw_s_op = TRUE;
          extract = 1;
          WriteWaveFile=FALSE;
          WriteSeekTable=TRUE;
          SeekTableFilename[0]=0;
          break;
        case 't':
          if(!strcmp(hs_optarg, "au"))
            ftype = TYPE_GENERIC_ULAW;
          else if(!strcmp(hs_optarg, "ulaw"))
            ftype = TYPE_GENERIC_ULAW;
          else if(!strcmp(hs_optarg, "alaw"))
            ftype = TYPE_GENERIC_ALAW;
          else if(!strcmp(hs_optarg, "s8"))
            ftype = TYPE_S8;
          else if(!strcmp(hs_optarg, "u8"))
            ftype = TYPE_U8;
          else if(!strcmp(hs_optarg, "s16"))
            ftype = hilo?TYPE_S16HL:TYPE_S16LH;
          else if(!strcmp(hs_optarg, "u16"))
            ftype = hilo?TYPE_U16HL:TYPE_U16LH;
          else if(!strcmp(hs_optarg, "s16x"))
            ftype = hilo?TYPE_S16LH:TYPE_S16HL;
          else if(!strcmp(hs_optarg, "u16x"))
            ftype = hilo?TYPE_U16LH:TYPE_U16HL;
          else if(!strcmp(hs_optarg, "s16hl"))
            ftype = TYPE_S16HL;
          else if(!strcmp(hs_optarg, "u16hl"))
            ftype = TYPE_U16HL;
          else if(!strcmp(hs_optarg, "s16lh"))
            ftype = TYPE_S16LH;
          else if(!strcmp(hs_optarg, "u16lh"))
            ftype = TYPE_U16LH;
          else if(!strcmp(hs_optarg, "wav"))
            ftype = TYPE_RIFF_WAVE;
          else if(!strncmp(hs_optarg, "aiff", 3))
            ftype = TYPE_AIFF;
          else
            usage_exit(1, "unknown file type: %s\n", hs_optarg);
          break;
        case 'u':
          ulawZeroMerge = 1;
          break;
        case 'v':
          version = atoi(hs_optarg);
          if(version < 0 || version > MAX_SUPPORTED_VERSION)
            usage_exit(1, "currently supported versions are in the range %d ... %d\n",MIN_SUPPORTED_VERSION, MAX_SUPPORTED_VERSION);
          break;
        case 'x':
          saw_x_op = TRUE;
          WriteWaveFile=TRUE;
          WriteSeekTable=FALSE;
          AppendSeekInfo=FALSE;
          extract = 1;
          break;
        default:
#ifdef _WINDOWS
          usage_exit(1, "apparently too many file names\n"); /* mrhmod */
#else
          usage_exit(1, NULL);
#endif
          break;
      }/* end switch */
  }

  check_conflicting_options();

  /* If user specifies -v 2, don't append seeking data */
  if (version <= 2)
      want_seeking = 0;
  else if (version > FORMAT_VERSION)
      version = FORMAT_VERSION;

  if(nmean == UNDEFINED_UINT)
    nmean = (version < 2) ? DEFAULT_V0NMEAN : DEFAULT_V2NMEAN;

  /* a few sanity checks */
  if(blocksize <= NWRAP)
    usage_exit(1, "blocksize must be greater than %d\n", NWRAP);

  if(maxnlpc >= blocksize)
    usage_exit(1, "the predictor order must be less than the block size\n");

  if(ulawZeroMerge == 1 && ftype != TYPE_GENERIC_ULAW)
    usage_exit(1, "the -u flag is only applicable to ulaw coding\n");

  /* this chunk just sets up the input and output files */
  nfilename = argc - hs_optind;
  switch(nfilename)
  {
    case 0:
#ifndef MSDOS
      filenamei = minusstr;
      filenameo = minusstr;
#else
      usage_exit(1, "must specify both input and output file when running under DOS\n");
#endif
      break;
    case 1:
    {
      int oldfilelen, newfilelen, suffixlen, maxlen, dots;
      char *p;

      filenamei  = argv[argc - 1];
      filenamei_orig = filenamei;
      oldfilelen = strlen(filenamei);

      if (extract) {
        suffixlen = strlen(FILESUFFIX);
        newfilelen = oldfilelen - suffixlen;
        maxlen = oldfilelen + suffixlen;
        tmpfilename = pmalloc((ulong) (maxlen + 1));
        strcpy(tmpfilename, filenamei);

        if (strcmp(tmpfilename,minusstr)) {
          if (newfilelen >= 0 &&
#if defined(MSDOS) || defined(_WINDOWS)
              !stricmp(tmpfilename + newfilelen, FILESUFFIX))
#else
              !strcasecmp(tmpfilename + newfilelen, FILESUFFIX))
#endif
          {
            p = tmpfilename + oldfilelen - 1;
            dots = 0;
            while (dots < 2 && p >= tmpfilename && '/' != *p) {
              if ('.' == *p)
                dots++;
              p--;
            }

            if (dots >= 2) {
              *(tmpfilename+newfilelen) = 0;
            }
            else {
              strcpy(tmpfilename+newfilelen,WAVESUFFIX);
            }
          }
          else {
            strcat(tmpfilename,WAVESUFFIX);
          }
        }
      }
      else {
        suffixlen = strlen(WAVESUFFIX);
        newfilelen = oldfilelen - suffixlen;
        maxlen = oldfilelen + suffixlen;
        tmpfilename = pmalloc((ulong) (maxlen + 1));
        strcpy(tmpfilename, filenamei);
        if (strcmp(tmpfilename,minusstr)) {
          if (newfilelen >= 0 &&
#if defined(MSDOS) || defined(_WINDOWS)
              !stricmp(tmpfilename + newfilelen, WAVESUFFIX))
#else
              !strcasecmp(tmpfilename + newfilelen, WAVESUFFIX))
#endif
          {
            strcpy(tmpfilename+newfilelen,FILESUFFIX);
          }
          else {
            strcat(tmpfilename,FILESUFFIX);
          }
        }
      }

      filenameo = tmpfilename;
#if defined (MSDOS) || defined (_WINDOWS)
      if (!saw_e_op && !saw_i_op)
        usage_exit(1, "must specify both input and output file when running under DOS\n");
#endif
      break;
    }
    case 2:
      if (saw_e_op || saw_i_op || saw_k_op || saw_s_op || saw_S_op)
        usage_exit(1, "-e, -i, -k, -s or -S can only be used on one file at a time\n");
      filenamei = argv[argc - 2];
      filenameo = argv[argc - 1];
      break;
    default:
      usage_exit(1, "too many filenames\n");
  }

StartAgain:

  if(strcmp(filenamei, minusstr))
  {
    if((filei = fopen(filenamei, readmode)) == NULL)
      usage_exit(1, "could not open file '%s' for input\n", filenamei);

    if (saw_e_op || saw_i_op) {
      if (saw_i_op) {
        ShowSeekInfo(filei,filenamei);
      }
      else {
        if (!FileHasSeekInfoAppended(filei,NULL))
          usage_exit(1,"file '%s' does not contain seek information\n",filenamei);

        fclose(filei);
        RemoveSeekInfo(filenamei);
      }
      exit(0);
    }

    if(WriteSeekTable && 0 == SeekTableFilename[0])
    {
      strcpy(SeekTableFilename,filenamei);
      if(0 == strcmp(filenamei+strlen(filenamei)-strlen(FILESUFFIX),FILESUFFIX))
        memcpy(SeekTableFilename+strlen(filenamei)-3,"skt",3);
      else
        strcat(SeekTableFilename,".skt");
    }
  }
  else
  {
    if (isatty(0))
      usage_exit(1, "will not input data from a tty\n");

    if (saw_e_op || saw_k_op || saw_i_op)
      usage_exit(1, "cannot use -e, -k or -i with data on standard input\n");

    if (saw_s_op)
      strcpy(SeekTableFilename,"stdin.skt");

    filei = stdi;

    SETBINARY_IN(filei);
  }

  if(strcmp(filenameo, minusstr))
  {
    if(WriteSeekTable && extract && AppendSeekInfo)
    {
      if(FileHasSeekInfoAppended(filei,NULL))
        usage_exit(1, "file '%s' already contains seek information\n", filenamei);
    }

    if(WriteWaveFile || (*filenameo && 0==Pass && !extract))
    {
      if((fileo = fopen(filenameo, writemode)) == NULL)
        usage_exit(1, "could not open file '%s' for output\n", filenameo);
    }
  }
  else
  {
    if (((WriteWaveFile && extract) || (!WriteWaveFile && !extract)) && isatty(1))
      usage_exit(1, "will not output data to a tty\n");

    fileo = stdo;

    SETBINARY_OUT(fileo);
  }

  /* discard header on input file - can't rely on fseek() here */
  if(ndiscard != 0)
  {
    char discardbuf[BUFSIZ];

    for(i = 0; i < ndiscard / BUFSIZ; i++) {
      if(fread(discardbuf, BUFSIZ, 1, filei) != 1)
        usage_exit(1, "EOF on input when discarding header\n");
      bytes_read++;
    }

    if(ndiscard % BUFSIZ != 0) {
      if(fread(discardbuf, ndiscard % BUFSIZ, 1, filei) != 1)
        usage_exit(1, "EOF on input when discarding header\n");
      bytes_read++;
    }
  }

  if(0 == extract)
  {
    float *maxresn;
    int   nread, nscan = 0, vbyte = MAX_VERSION + 1;
    char  xiff[4];

    /* read magic for AIFF or RIFF WAVE, or if not committed */
    if(ftype == TYPE_EOF || ftype == TYPE_AIFF || ftype == TYPE_RIFF_WAVE)
    {
      if (4 != fread(xiff, sizeof(char), 4, filei))
        usage_exit(1, "error reading magic from input file\n");
    }
    /* auto test type for AIFF or RIFF WAVE if not already committed */
    if(ftype == TYPE_EOF)
    {
      if (!strncmp(xiff, "FORM", 4))
        ftype = TYPE_AIFF;
      else if (!strncmp(xiff, "RIFF", 4))
        ftype = TYPE_RIFF_WAVE;
    }
    if(ftype == TYPE_AIFF)
    {
      int wtype;
      wavhdr = aiff_prochdr(filei, &ftype, &nchan, &datalen, &wtype);
      if (wavhdr == NULL)
      {
        if (wtype == 0)
          /* the header must have been invalid */
          usage_exit(1, "input file is not a valid AIFF file\n");
        else
          /* the bit depth is unsupported */
          usage_exit(1, "This AIFF has %d-bit samples, which is currently unsupported\n", wtype);
        ftype = TYPE_EOF;
      }
      else
      {
        /* we have a valid AIFF so override anything the user may have said to do with the alignment */
        nskip = 0;
      }
    }

    /* define type to be RIFF WAVE if not already committed */
    if(ftype == TYPE_EOF)
      ftype = TYPE_RIFF_WAVE;

    /* If we're dealing with RIFF WAVE, process the header now,
     * before calling fread_type_init() which will want to know the
     * sample type. This also resets ftype to the _real_ sample
     * type, and nchan to the correct number of channels, and
     * prepares a verbatim section containing the header, which we
     * will write out after the filetype and channel count. */
    if (ftype == TYPE_RIFF_WAVE)
    {
      int wtype;
      wavhdr = riff_wave_prochdr(filei, &ftype, &nchan, &datalen, &wtype);
      if (wavhdr == NULL)
      {
        if (wtype == 0)
          /* the header must have been invalid */
          usage_exit(1, "input file is not a valid RIFF WAVE file\n");
        else
          /* the wave type is wrong */
          usage_exit(1,"RIFF WAVE file has unhandled format tag %d\n",wtype);
      }
      else
      {
        /* we have a valid RIFF WAVE so override anything the user may have said to do with the alignment */
        nskip = 0;
      }
    }

    /* sort out specific types for ULAW and ALAW */
    if(ftype == TYPE_GENERIC_ULAW || ftype == TYPE_GENERIC_ALAW)
    {
      int linearLossy=(Satof(maxresnstr)!=Satof(DEFAULT_MAXRESNSTR)||quanterror!=DEFAULT_QUANTERROR);

      /* sort out which ulaw type we are going to use */
      if(ftype == TYPE_GENERIC_ULAW)
      {
        if(linearLossy)
          ftype = TYPE_ULAW;
        else if(version < 2 || ulawZeroMerge == 1)
          ftype = TYPE_AU1;
        else
          ftype = TYPE_AU2;
      }

      /* sort out which alaw type we are going to use */
      if(ftype == TYPE_GENERIC_ALAW)
      {
        if(linearLossy)
          ftype = TYPE_ALAW;
        else
          ftype = TYPE_AU3;
      }
    }

    /* mean compensation is not supported for TYPE_AU1 or TYPE_AU2 */
    /* (the bit shift compensation can't cope with the lag vector) */
    if(ftype == TYPE_AU1 || ftype == TYPE_AU2)
      nmean = 0;

    nwrap = MAX(NWRAP, maxnlpc);

    if(maxnlpc > 0)
      qlpc = (int*) pmalloc((ulong) (maxnlpc * sizeof(*qlpc)));

    /* verbatim copy of skip bytes from input to output checking for the
       existence of magic number in header, and defaulting to internal storage
       if that happens */
    if(version >= 2)
    {
      while(nskip - nscan > 0 && vbyte > MAX_VERSION)
      {
        int byte = getc_exit(filei);
        if(magic[nscan] != '\0' && byte == magic[nscan])
          nscan++;
        else if(magic[nscan] == '\0' && byte <= MAX_VERSION)
          vbyte = byte;
        else
        {
          for(i = 0; i < nscan; i++)
            putc_exit(magic[i], fileo);

          if(byte == magic[0])
          {
            nskip -= nscan;
            nscan = 1;
          }
          else
          {
            putc_exit(byte, fileo);
            nskip -= nscan + 1;
            nscan = 0;
          }
        }
      }

      if(vbyte > MAX_VERSION)
      {
        for(i = 0; i < nscan; i++)
          putc_exit(magic[i], fileo);

        nskip -= nscan;
        nscan = 0;
      }
    }

    /* write magic number */
    if(fwrite(magic, 1, strlen(magic), fileo) != strlen(magic))
      usage_exit(1, "could not write the magic number\n");

    /* write version number */
    putc_exit(version, fileo);

    /* grab some space for the input buffers */
    buffer = long2d((ulong) nchan, (ulong) (blocksize + nwrap));
    offset = long2d((ulong) nchan, (ulong) MAX(1, nmean));

    maxresn = parseList(maxresnstr, nchan);
    for(chan = 0; chan < nchan; chan++)
      if(maxresn[chan] < MINBITRATE)
        usage_exit(1,"channel %d: expected bit rate must be >= %3.1f: %3.1f\n",chan, MINBITRATE, maxresn[chan]);
      else
        maxresn[chan] -= 3.0;

    for(chan = 0; chan < nchan; chan++)
    {
      for(i = 0; i < nwrap; i++)
        buffer[chan][i] = 0;
      buffer[chan] += nwrap;
    }

    /* initialise the fixed length file read for the uncompressed stream */
    fread_type_init();

    /* initialise the variable length file write for the compressed stream */
    var_put_init();

    /* put file type and number of channels */
    UINT_PUT(ftype, TYPESIZE, fileo);
    UINT_PUT(nchan, CHANSIZE, fileo);

    /* put blocksize if version > 0 */
    if(version == 0)
    {
      if(blocksize != DEFAULT_BLOCK_SIZE)
      {
        uvar_put((ulong) FN_BLOCKSIZE, FNSIZE, fileo);
        UINT_PUT(blocksize, (int) (log((double) DEFAULT_BLOCK_SIZE) / M_LN2),fileo);
      }
    }
    else
    {
      UINT_PUT(blocksize, (int) (log((double) DEFAULT_BLOCK_SIZE) / M_LN2),fileo);
      UINT_PUT(maxnlpc, LPCQSIZE, fileo);
      UINT_PUT(nmean, 0, fileo);
      UINT_PUT(nskip, NSKIPSIZE, fileo);
      if(version == 1)
      {
        for(i = 0; i < nskip; i++)
        {
          int byte = getc_exit(filei);
          uvar_put((ulong) byte, XBYTESIZE, fileo);
        }
      }
      else
      {
        if(vbyte <= MAX_VERSION)
        {
          for(i = 0; i < nscan; i++)
            uvar_put((ulong) magic[i], XBYTESIZE, fileo);
          uvar_put((ulong) vbyte, XBYTESIZE, fileo);
        }
        for(i = 0; i < nskip - nscan - 1; i++)
        {
          int byte = getc_exit(filei);
          uvar_put((ulong) byte, XBYTESIZE, fileo);
        }
        lpcqoffset = V2LPCQOFFSET;
      }
    }

    /* if we had a RIFF WAVE header, write it out in the form of verbatim
     * chunks at this point */
    if (wavhdr)
      write_header(wavhdr, fileo);

    init_offset(offset, nchan, MAX(1, nmean), ftype);

    /* this is the main read/code/write loop for the whole file */
    while((nread = fread_type(buffer, ftype, nchan,blocksize, filei, &datalen)) != 0)
    {

#ifdef _WINDOWS
      /* Include processing to enable Windows program to abort */
      CheckWindowsAbort();
#endif

      /* put blocksize if changed */
      if(nread != blocksize)
      {
        uvar_put((ulong) FN_BLOCKSIZE, FNSIZE, fileo);
        UINT_PUT(nread, (int) (log((double) blocksize) / M_LN2), fileo);
        blocksize = nread;
      }

      /* loop over all channels, processing each channel in turn */
      for(chan = 0; chan < nchan; chan++)
      {
        float sigbit;  /* PT expected root mean squared value of the signal */
        float resbit;  /* PT expected root mean squared value of the residual*/
        slong coffset, *cbuffer = buffer[chan], fulloffset = 0L;
        int  fnd, resn = 0, nlpc = 0;

        /* force the lower quanterror bits to be zero */
        if(quanterror != 0)
        {
          slong offset = (1L << (quanterror - 1));
          for(i = 0; i < blocksize; i++)
            cbuffer[i] = (cbuffer[i] + offset) >> quanterror;
        }

        /* merge both ulaw zeros if required */
        if(ulawZeroMerge == 1)
          for(i = 0; i < blocksize; i++)
            if(cbuffer[i] == NEGATIVE_ULAW_ZERO)
              cbuffer[i]=POSITIVE_ULAW_ZERO;

        /* test for excessive and exploitable quantisation, and exploit!! */
        bitshift = find_bitshift(cbuffer, blocksize, ftype) + quanterror;
        if(bitshift > NBITPERLONG)
          bitshift = NBITPERLONG;

        /* find mean offset : N.B. this code duplicated */
        if(nmean == 0)
          fulloffset = coffset = offset[chan][0];
        else
        {
          slong sum = (version < 2) ? 0 : nmean / 2;
          for(i = 0; i < nmean; i++)
            sum += offset[chan][i];
          if(version < 2)
            coffset = sum / nmean;
          else
          {
            fulloffset = sum / nmean;
            if(bitshift == NBITPERLONG && version >= 2)
              coffset = ROUNDEDSHIFTDOWN(fulloffset, lastbitshift);
            else
              coffset = ROUNDEDSHIFTDOWN(fulloffset, bitshift);
          }
        }

        /* find the best model */
        if(bitshift == NBITPERLONG && version >= 2)
        {
          bitshift = lastbitshift;
          fnd = FN_ZERO;
        }
        else
        {
          int maxresnbitshift, snrbitshift, extrabitshift;
          float sigpow, nn;

          if(maxnlpc == 0)
            fnd = wav2poly(cbuffer, blocksize,coffset,version,&sigbit,&resbit);
          else
          {
            nlpc = wav2lpc(cbuffer, blocksize, coffset, qlpc, maxnlpc, version, &sigbit, &resbit);
            fnd  = FN_QLPC;
          }

          if(resbit > 0.0)
            resn = floor(resbit + 0.5);
          else
            resn = 0;

          maxresnbitshift = floor(resbit - maxresn[chan] + 0.5);
          sigpow          = exp(2.0 * M_LN2 * sigbit) / (0.5 * M_LN2 * M_LN2);
          nn              = 12.0 * sigpow / pow(10.0, minsnr / 10.0);
          snrbitshift     = (nn>25.0/12.0)?floor(0.5*log(nn-25.0/12.0)/M_LN2):0;
          extrabitshift   = MAX(maxresnbitshift, snrbitshift);

          if(extrabitshift > resn)
            extrabitshift = resn;

          if(extrabitshift > 0)
          {
            slong offset = (1L << (extrabitshift - 1));
            for(i = 0; i < blocksize; i++)
              cbuffer[i] = (cbuffer[i] + offset) >> extrabitshift;
            bitshift += extrabitshift;
            if(version >= 2)
              coffset = ROUNDEDSHIFTDOWN(fulloffset, bitshift);
            resn -= extrabitshift;
          }
        }

        /* store mean value if appropriate : N.B. Duplicated code */
        if(nmean > 0)
        {
          slong sum = (version < 2) ? 0 : blocksize / 2;

          for(i = 0; i < blocksize; i++)
            sum += cbuffer[i];

          for(i = 1; i < nmean; i++)
            offset[chan][i - 1] = offset[chan][i];
          if(version < 2)
            offset[chan][nmean - 1] = sum / blocksize;
          else
            offset[chan][nmean - 1] = (sum / blocksize) << bitshift;
        }

        if(bitshift != lastbitshift)
        {
          uvar_put((ulong) FN_BITSHIFT, FNSIZE, fileo);
          uvar_put((ulong) bitshift, BITSHIFTSIZE, fileo);
          lastbitshift = bitshift;
        }

        if(fnd == FN_ZERO)
        {
          uvar_put((ulong) fnd, FNSIZE, fileo);
        }
        else if(maxnlpc == 0)
        {
          uvar_put((ulong) fnd, FNSIZE, fileo);
          uvar_put((ulong) resn, ENERGYSIZE, fileo);

          switch(fnd)
          {
            case FN_DIFF0:
              for(i = 0; i < blocksize; i++)
                VAR_PUT(cbuffer[i] - coffset, resn, fileo);
              break;
            case FN_DIFF1:
              for(i = 0; i < blocksize; i++)
                VAR_PUT(cbuffer[i] - cbuffer[i - 1], resn, fileo);
              break;
            case FN_DIFF2:
              for(i = 0; i < blocksize; i++)
                VAR_PUT(cbuffer[i] - 2 * cbuffer[i - 1] + cbuffer[i - 2],resn, fileo);
              break;
            case FN_DIFF3:
              for(i = 0; i < blocksize; i++)
                VAR_PUT(cbuffer[i] - 3 * (cbuffer[i - 1] - cbuffer[i - 2])-cbuffer[i - 3], resn, fileo);
              break;
          }
        }
        else
        {
          uvar_put((ulong) FN_QLPC, FNSIZE, fileo);
          uvar_put((ulong) resn, ENERGYSIZE, fileo);
          uvar_put((ulong) nlpc, LPCQSIZE, fileo);
          for(i = 0; i < nlpc; i++)
            var_put((slong) qlpc[i], LPCQUANT, fileo);

          /* deduct mean from everything */
          for(i = -nlpc; i < blocksize; i++)
            cbuffer[i] -= coffset;

          /* use the quantised LPC coefficients to generate the residual */
          for(i = 0; i < blocksize; i++)
          {
            int j;
            slong sum = lpcqoffset;
            slong *obuffer = &(cbuffer[i - 1]);

            for(j = 0; j < nlpc; j++)
              sum += qlpc[j] * obuffer[-j];
            var_put(cbuffer[i] - (sum >> LPCQUANT), resn, fileo);
          }

          /* add mean back to those samples that will be wrapped */
          for(i = blocksize - nwrap; i < blocksize; i++)
            cbuffer[i] += coffset;
        }

        /* do the wrap */
        for(i = -nwrap; i < 0; i++)
          cbuffer[i] = cbuffer[i + blocksize];
      }
    }

    /* if we had a RIFF WAVE header, we had better be prepared to deal with a RIFF WAVE footer too... */
    if (wavhdr)
      verbatim_file (filei, fileo);

    /* wind up */
    fread_type_quit();
    uvar_put((ulong) FN_QUIT, FNSIZE, fileo);
    var_put_quit(fileo);

    /* and free the space used */
    if (wavhdr)
      free_header (wavhdr);
    free((void *) buffer);
    free((void *) offset);
    if(maxnlpc > 0)
      free((void *) qlpc);
  }
  else
  {
    /***********************/
    /* EXTRACT starts here */
    /***********************/

    int i, cmd;
    int internal_ftype;

    bitshift = 0;
    bytes_read = 0;

    /* Firstly skip the number of bytes requested in the command line */
    for(i = 0; i < nskip; i++)
    {
      int byte = getc(filei);
      bytes_read++;
      if(byte == EOF)
        usage_exit(1, "File too short for requested alignment\n");
      putc_exit(byte, fileo);
    }

    /* read magic number */
#ifdef STRICT_FORMAT_COMPATABILITY
    if(FORMAT_VERSION < 2)
    {
      for(i = 0; i < strlen(magic); i++) {
        if(getc_exit(filei) != magic[i])
          usage_exit(1, "Bad magic number\n");
        bytes_read++;
      }

      /* get version number */
      version = getc_exit(filei);
      bytes_read++;
    }
    else
#endif /* STRICT_FORMAT_COMPATABILITY */
    {
      int nscan = 0;

      version = MAX_VERSION + 1;
      while(version > MAX_VERSION)
      {
        int byte = getc(filei);
        bytes_read++;
        if(byte == EOF) {
          if (WriteSeekTable) {
            unlink(SeekTableFilename);
            usage_exit(1, "-k, -s and -S can only be used on shorten files\n");
          }
          else
            usage_exit(1, "No magic number\n");
        }
        if(magic[nscan] != '\0' && byte == magic[nscan])
          nscan++;
        else if(magic[nscan] == '\0' && byte <= MAX_VERSION)
          version = byte;
        else
        {
          for(i = 0; i < nscan; i++)
            if (0 == WriteSeekTable) {
              putc_exit(magic[i], fileo);
            }
          if(byte == magic[0])
            nscan = 1;
          else
          {
            if (0 == WriteSeekTable) {
              putc_exit(byte, fileo);
            }
            nscan = 0;
          }
          version = MAX_VERSION + 1;
        }
      }
    }

    /* check version number */
    if(version > MAX_SUPPORTED_VERSION)
      update_exit(1, "can't decode version %d\n", version);

    /* set up the default nmean, ignoring the command line state */
    nmean = (version < 2) ? DEFAULT_V0NMEAN : DEFAULT_V2NMEAN;

    /* initialise the variable length file read for the compressed stream */
    var_get_init();

    /* initialise the fixed length file write for the uncompressed stream */
    fwrite_type_init();

    /* get the internal file type */
    internal_ftype = UINT_GET(TYPESIZE, filei);

    /* has the user requested a change in file type? */
    if(internal_ftype != ftype) {
      if(ftype == TYPE_EOF)
        ftype = internal_ftype;    /*  no problems here */
      else             /* check that the requested conversion is valid */
        if(internal_ftype == TYPE_AU1 || internal_ftype == TYPE_AU2 ||
           internal_ftype == TYPE_AU3 || ftype == TYPE_AU1 ||ftype == TYPE_AU2 || ftype == TYPE_AU3)
          error_exit("Not able to perform requested output format conversion\n");
    }

    nchan = UINT_GET(CHANSIZE, filei);

    /* get blocksize if version > 0 */
    if(version > 0)
    {
      blocksize = UINT_GET((int) (log((double) DEFAULT_BLOCK_SIZE) / M_LN2),filei);
      maxnlpc = UINT_GET(LPCQSIZE, filei);
      nmean = UINT_GET(0, filei);
      nskip = UINT_GET(NSKIPSIZE, filei);
      for(i = 0; i < nskip; i++)
      {
        int byte = uvar_get(XBYTESIZE, filei);
        putc_exit(byte, fileo);
      }
    }
    else
      blocksize = DEFAULT_BLOCK_SIZE;

    nwrap = MAX(NWRAP, maxnlpc);

    /* grab some space for the input buffer */
    buffer  = long2d((ulong) nchan, (ulong) (blocksize + nwrap));
    offset  = long2d((ulong) nchan, (ulong) MAX(1, nmean));

    for(chan = 0; chan < nchan; chan++)
    {
      for(i = 0; i < nwrap; i++)
       buffer[chan][i] = 0;
      buffer[chan] += nwrap;
    }

    if(maxnlpc > 0)
      qlpc = (int*) pmalloc((ulong) (maxnlpc * sizeof(*qlpc)));

    if(version > 1)
      lpcqoffset = V2LPCQOFFSET;

    init_offset(offset, nchan, MAX(1, nmean), internal_ftype);

    if(WriteSeekTable && extract)
    {
      if(0 == Pass && (saw_s_op || saw_S_op))
        fprintf(stderr,"creating seek table file: '%s'\n",SeekTableFilename);
      else if (AppendSeekInfo)
        fprintf(stderr,"appending seek table to '%s'\n",filenamei);

      if((SeekTableFile = fopen(SeekTableFilename, writemode)) == NULL)
        usage_exit(1, "could not open seek table file '%s'\n", SeekTableFilename);

      fwrite(SeekTableHeader.data,1,SEEK_HEADER_SIZE,SeekTableFile);
    }

    /* get commands from file and execute them */
    chan = 0;
    while(1)
    {
      ReadingFunctionCode=TRUE;
      cmd = uvar_get(FNSIZE, filei);

      CBuf_0_Minus1=(slong)buffer[0][-1];
      CBuf_0_Minus2=(slong)buffer[0][-2];
      CBuf_0_Minus3=(slong)buffer[0][-3];
      Offset_0_0=(slong)offset[0][0];
      Offset_0_1=(slong)offset[0][1];
      Offset_0_2=(slong)offset[0][2];
      Offset_0_3=(slong)offset[0][3];

      if (nchan > 1)
      {
        CBuf_1_Minus1=(slong)buffer[1][-1];
        CBuf_1_Minus2=(slong)buffer[1][-2];
        CBuf_1_Minus3=(slong)buffer[1][-3];
        Offset_1_0=(slong)offset[1][0];
        Offset_1_1=(slong)offset[1][1];
        Offset_1_2=(slong)offset[1][2];
        Offset_1_3=(slong)offset[1][3];
      }
      else
      {
        CBuf_1_Minus1=0;
        CBuf_1_Minus2=0;
        CBuf_1_Minus3=0;
        Offset_1_0=0;
        Offset_1_1=0;
        Offset_1_2=0;
        Offset_1_3=0;
      }

      ReadingFunctionCode=FALSE;

      if(FN_QUIT==cmd)
        break;
      else
      {
#ifdef _WINDOWS
        /* Include processing to enable Windows program to abort */
        CheckWindowsAbort();
#endif
        switch(cmd)
        {
          case FN_ZERO:
          case FN_DIFF0:
          case FN_DIFF1:
          case FN_DIFF2:
          case FN_DIFF3:
          case FN_QLPC:
          {
            slong coffset, *cbuffer = buffer[chan];
            int resn = 0, nlpc, j;

            if(cmd != FN_ZERO)
            {
              resn = uvar_get(ENERGYSIZE, filei);
              /* this is a hack as version 0 differed in definition of var_get */
              if(version == 0)
                resn--;
            }

            /* find mean offset : N.B. this code duplicated */
            if(nmean == 0)
              coffset = offset[chan][0];
            else
            {
              slong sum = (version < 2) ? 0 : nmean / 2;
              for(i = 0; i < nmean; i++)
                sum += offset[chan][i];
              if(version < 2)
                coffset = sum / nmean;
              else
                coffset = ROUNDEDSHIFTDOWN(sum / nmean, bitshift);
            }

            switch(cmd)
            {
              case FN_ZERO:
                for(i = 0; i < blocksize; i++)
                  cbuffer[i] = 0;
                break;
              case FN_DIFF0:
                for(i = 0; i < blocksize; i++)
                  cbuffer[i] = var_get(resn, filei) + coffset;
                break;
              case FN_DIFF1:
                for(i = 0; i < blocksize; i++)
                  cbuffer[i] = var_get(resn, filei) + cbuffer[i - 1];
                break;
              case FN_DIFF2:
                for(i = 0; i < blocksize; i++)
                  cbuffer[i] = var_get(resn, filei) + (2 * cbuffer[i - 1] - cbuffer[i - 2]);
                break;
              case FN_DIFF3:
                for(i = 0; i < blocksize; i++)
                  cbuffer[i] = var_get(resn, filei) + 3 * (cbuffer[i - 1] -  cbuffer[i - 2]) + cbuffer[i - 3];
                break;
              case FN_QLPC:
                nlpc = uvar_get(LPCQSIZE, filei);

                for(i = 0; i < nlpc; i++)
                  qlpc[i] = var_get(LPCQUANT, filei);
                for(i = 0; i < nlpc; i++)
                  cbuffer[i - nlpc] -= coffset;
                for(i = 0; i < blocksize; i++)
                {
                  slong sum = lpcqoffset;

                  for(j = 0; j < nlpc; j++)
                    sum += qlpc[j] * cbuffer[i - j - 1];
                  cbuffer[i] = var_get(resn, filei) + (sum >> LPCQUANT);
                }
                if(coffset != 0)
                  for(i = 0; i < blocksize; i++)
                    cbuffer[i] += coffset;
                break;
            }

            /* store mean value if appropriate : N.B. Duplicated code */
            if(nmean > 0)
            {
              slong sum = (version < 2) ? 0 : blocksize / 2;

              for(i = 0; i < blocksize; i++)
                sum += cbuffer[i];

              for(i = 1; i < nmean; i++)
                offset[chan][i - 1] = offset[chan][i];
              if(version < 2)
                offset[chan][nmean - 1] = sum / blocksize;
              else
                offset[chan][nmean - 1] = (sum / blocksize) << bitshift;
            }

            if(chan==0)
            {
              if(WriteSeekTable && WriteCount%100 == 0)
              {
                TSeekEntry SeekEntry;

                ulong_to_uchar_le(SeekEntry.data,SampleNumber);
                ulong_to_uchar_le(SeekEntry.data+4,SHNFilePosition);
                ulong_to_uchar_le(SeekEntry.data+8,SHNLastBufferReadPosition);
                ushort_to_uchar_le(SeekEntry.data+12,SHNByteGet);
                ushort_to_uchar_le(SeekEntry.data+14,SHNBufferOffset);
                ushort_to_uchar_le(SeekEntry.data+16,SHNBitPosition);
                ulong_to_uchar_le(SeekEntry.data+18,SHNGBuffer);
                ushort_to_uchar_le(SeekEntry.data+22,bitshift);

                long_to_uchar_le(SeekEntry.data+24,CBuf_0_Minus1);
                long_to_uchar_le(SeekEntry.data+28,CBuf_0_Minus2);
                long_to_uchar_le(SeekEntry.data+32,CBuf_0_Minus3);

                long_to_uchar_le(SeekEntry.data+36,CBuf_1_Minus1);
                long_to_uchar_le(SeekEntry.data+40,CBuf_1_Minus2);
                long_to_uchar_le(SeekEntry.data+44,CBuf_1_Minus3);

                long_to_uchar_le(SeekEntry.data+48,Offset_0_0);
                long_to_uchar_le(SeekEntry.data+52,Offset_0_1);
                long_to_uchar_le(SeekEntry.data+56,Offset_0_2);
                long_to_uchar_le(SeekEntry.data+60,Offset_0_3);

                long_to_uchar_le(SeekEntry.data+64,Offset_1_0);
                long_to_uchar_le(SeekEntry.data+68,Offset_1_1);
                long_to_uchar_le(SeekEntry.data+72,Offset_1_2);
                long_to_uchar_le(SeekEntry.data+76,Offset_1_3);

                fwrite(&SeekEntry,SEEK_ENTRY_SIZE,1,SeekTableFile);
              }
              WriteCount++;
            }

            /* do the wrap */
            for(i = -nwrap; i < 0; i++)
              cbuffer[i] = cbuffer[i + blocksize];

            fix_bitshift(cbuffer, blocksize, bitshift, internal_ftype);

            if(chan == nchan - 1)
            {
              SampleNumber+=blocksize;
              fwrite_type(buffer, ftype, nchan, blocksize, fileo);
            }
            chan = (chan + 1) % nchan;
            break;
          }

          case FN_BLOCKSIZE:
            blocksize = UINT_GET((int) (log((double) blocksize) / M_LN2), filei);
            break;
          case FN_BITSHIFT:
            bitshift = uvar_get(BITSHIFTSIZE, filei);
            break;
          case FN_VERBATIM:
          {
            int cklen = uvar_get(VERBATIM_CKSIZE_SIZE, filei);
            while (cklen--)
            {
              int ByteToWrite = uvar_get(VERBATIM_BYTE_SIZE, filei);
              if(WriteWaveFile)
                fputc(ByteToWrite,fileo);
            }
            break;
          }

          default:
            update_exit(1, "sanity check fails trying to decode function: %d\n",cmd);
        }
      }
    }

    /* wind up */
    var_get_quit();
    fwrite_type_quit();

    free((void *) buffer);
    free((void *) offset);
    if(maxnlpc > 0)
      free((void *) qlpc);
  }

  /* close the files if this function opened them */
  if(filei && filei != stdi)
    fclose(filei);
  if(fileo && fileo != stdo)
    fclose(fileo);

  /* make the output file look like the original if possible - delay this until after seek tables are created (if any) */
  if((filei != stdi) && (fileo != stdo) && (0 == Pass)) {
    DupFileInfo = TRUE;
    dupfilenamei = filenamei;
    dupfilenameo = filenameo;
  }

  filei = fileo = 0;

  if(!extract && filenamei && filenameo && strcmp(filenameo,minusstr))
  {
    extract=TRUE;
    WriteWaveFile=FALSE;
    AppendSeekInfo=WriteSeekTable=want_seeking;
    filenamei=filenameo;
    Pass++;
    strcpy(SeekTableFilename,filenamei);
    if(0==strcmp(filenamei+strlen(filenamei)-strlen(FILESUFFIX),FILESUFFIX))
      memcpy(SeekTableFilename+strlen(filenamei)-3,"skt",3);
    else
      strcat(SeekTableFilename,".skt");
    goto StartAgain;
  }

  if(SeekTableFile)
  {
    ulong SeekTableSize;
    uchar *pSeekTableBuffer;

    fclose(SeekTableFile);

    SeekTableFile=fopen(SeekTableFilename,"rb+");
    if(!SeekTableFile)
      usage_exit(1,"failure opening '%s': %s\n",SeekTableFilename,strerror(errno));

    fseek(SeekTableFile,0,SEEK_END);
    SeekTableSize=ftell(SeekTableFile);

    /* first, rewrite the seek table file with the correct shn file size */

    /* allocate some memory and reload the seek table */
    pSeekTableBuffer=(uchar*)malloc(SeekTableSize);
    fseek(SeekTableFile,0,SEEK_SET);
    fread(pSeekTableBuffer,SeekTableSize,1,SeekTableFile);

    /* copy the shn file size to the SeekTableHeader */
    ulong_to_uchar_le(pSeekTableBuffer+8,bytes_read);

    fclose(SeekTableFile);

    SeekTableFile=fopen(SeekTableFilename,"wb+");
    if(!SeekTableFile)
      usage_exit(1,"failure reopening '%s' - %s\n",SeekTableFilename,strerror(errno));

    /* rewrite the seek table file */
    fwrite(pSeekTableBuffer,1,SeekTableSize,SeekTableFile);

    /* close the seek table file, and re-open it */
    fclose(SeekTableFile);
    free(pSeekTableBuffer);

    SeekTableFile=fopen(SeekTableFilename,"rb+");
    if(!SeekTableFile)
      usage_exit(1,"failure reopening '%s' - %s\n",SeekTableFilename,strerror(errno));

    if(AppendSeekInfo)
    {
      filei = fopen(filenamei,"ab+");

      if(!filei)
        usage_exit(1,"failure opening '%s': %s\n",filenamei,strerror(errno));

      fseek(filei,0,SEEK_END);

      fseek(SeekTableFile,0,SEEK_END);
      SeekTableSize=ftell(SeekTableFile) + SEEK_TRAILER_SIZE;

      /* allocate some memory and reload the seek table */
      pSeekTableBuffer=(uchar*)malloc(SeekTableSize);
      fseek(SeekTableFile,0,SEEK_SET);
      fread(pSeekTableBuffer,SeekTableSize-SEEK_TRAILER_SIZE,1,SeekTableFile);

      /* set the seek table size and copy the trailer to the buffer */
      ulong_to_uchar_le(SeekTableTrailer.data,SeekTableSize);
      memcpy(pSeekTableBuffer+SeekTableSize-SEEK_TRAILER_SIZE,&SeekTableTrailer,SEEK_TRAILER_SIZE);

      /* append the seek table and the trailer to the shn file */
      fwrite(pSeekTableBuffer,1,SeekTableSize,filei);

      free(pSeekTableBuffer);
    }

    /* and finally close the files */
    if (filei)
      fclose(filei);
    filei = 0;

    fclose(SeekTableFile);

    if (AppendSeekInfo && !saw_s_op && !saw_S_op) {
      if(unlink(SeekTableFilename))
        usage_exit(1, "could not remove seek table file '%s': %s\n",SeekTableFilename,strerror(errno));
    }
  }

  if (DupFileInfo)
    (void) dupfileinfo(dupfilenamei, dupfilenameo);

  if(tmpfilename != NULL)
    free(tmpfilename);

  if(nfilename == 1 && !(saw_s_op || saw_S_op || saw_k_op))
    if (unlink(filenamei_orig))
      usage_exit(1, "could not remove file '%s'\n", filenamei_orig);

#ifdef MSDOS
#ifdef MSDOS_DO_TIMING
  endTime = clock();
  fprintf(stderr,"elapsed time: %g sec\n",((double)(endTime-startTime))/CLOCKS_PER_SEC);
#endif
#endif

  /* quit happy */
  return(0);
}
