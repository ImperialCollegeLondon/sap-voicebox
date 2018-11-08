bin_PROGRAMS = shorten
BUILT_SOURCES = bitshift.h

shorten_LDADD = ../utils/Sulawalaw.o ../utils/array.o ../utils/exit.o

shorten_SOURCES = aiff.c dupfinfo.c fixio.c hsgetopt.c license.c lpc.c main.c poly.c riffwave.c shorten.c vario.c

CLEANFILES = $(BUILT_SOURCES)

dupfinfo.c: $(BUILT_SOURCES)

bitshift.h:
	-@if [ -x "../utils/mkbshift" ] ; then \
	  ../utils/mkbshift ; \
	else \
	  echo "" ; \
	  echo "***  missing ../utils/mkbshift - run '$(MAKE)' in the top-level directory to build it  ***" ; \
	  echo "" ; \
	  exit 1 ; \
	fi
