dnl Process this file with autoconf to produce a configure script.

AC_INIT([shorten],[3.6.1],[shnutils@freeshell.org])
AC_REVISION([$Id: configure.ac,v 1.29 2007/03/19 19:02:32 jason Exp $])

AC_CONFIG_SRCDIR([src/main.c])
AC_CONFIG_HEADERS([include/config.h])

AC_CANONICAL_HOST

AM_INIT_AUTOMAKE

dnl Checks for programs.
AC_LANG([C])
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_AWK
AC_PROG_LN_S
AC_PROG_MAKE_SET

dnl Checks for types.
AC_C_BIGENDIAN

dnl Checks for libraries.
dnl Replace `main' with a function in -lm:
AC_CHECK_LIB([m],[main])

dnl Checks for header files.
AC_MSG_NOTICE([checking for headers])
AC_HEADER_STDC
AC_CHECK_HEADERS([stdarg.h inttypes.h])
AC_MSG_NOTICE([checking for win32 environment])
AC_CHECK_HEADERS([windows.h])

dnl Checks for typedefs, structures, and compiler characteristics.
AC_MSG_NOTICE([checking for data types])
AC_CHECK_SIZEOF([unsigned long])

dnl Checks for library functions.
AC_MSG_NOTICE([checking for library functions])
AC_CHECK_FUNCS([strerror truncate])

AC_OUTPUT([
man/Makefile
utils/Makefile
src/Makefile
tests/Makefile
Makefile
])

AC_MSG_NOTICE([ready to compile.

$PACKAGE is now configured with the following options:

version:  $VERSION
install:  ${prefix}/bin

Type 'make' to build ${PACKAGE}.  Afterwards,
type 'make check' to run some verification tests.
])
