#! /bin/sh

# $Id: test-seek.sh,v 1.8 2002/02/03 20:41:36 jason Exp $

SHORTEN=../src/shorten

if [ ! -x "$SHORTEN" ]; then
  echo "*** $SHORTEN is missing, please build it ***"
  exit 1
fi

echo ""
echo "=======================  shorten seek table tests  ======================="
echo ""

for testdir in mono stereo; do

  echo "+ Running seek table tests against $testdir benchmark files..."
  echo ""

  for testfile in test.shn test.skt test.wav seekable.shn; do
    if [ ! -f "$testdir/$testfile" ]; then
      echo "*** Missing test file '$testfile', cannot continue... ***"
      exit 1
    fi
  done

  cp $testdir/test.shn $testdir/seekable.shn .

  # test creation of separate seek table file with -S
  $SHORTEN -Sseektest.skt $testdir/test.shn || exit 1
  cmp seektest.skt $testdir/test.skt || exit 1
  rm -f seektest.skt

  # test creation of separate seek table file with -s
  cp $testdir/test.shn seektest.shn
  $SHORTEN -s seektest.shn || exit 1
  cmp seektest.skt $testdir/test.skt || exit 1
  rm -f seektest.skt

  # test proper naming of separate seek table file with -s
  cp $testdir/test.shn nametest.ext
  $SHORTEN -s nametest.ext || exit 1
  cmp nametest.ext.skt $testdir/test.skt || exit 1
  rm -f nametest.ext nametest.ext.skt

  # test creation of .shn with seek tables appended
  $SHORTEN $testdir/test.wav seektest.shn || exit 1
  cmp seektest.shn $testdir/seekable.shn || exit 1
  rm -f seektest.shn

  # test creation of separate seek table file from data read on stdin with -S
  $SHORTEN -Sstdin.skt < $testdir/test.shn || exit 1
  cmp stdin.skt $testdir/test.skt || exit 1
  rm -f stdin.skt

  # test creation of separate seek table file from data read on stdin with -s
  $SHORTEN -s < $testdir/test.shn || exit 1
  cmp stdin.skt $testdir/test.skt || exit 1
  rm -f stdin.skt

  # test creation of seek table from uncompressed data read from stdin
  $SHORTEN - seektest.shn < $testdir/test.wav || exit 1
  cmp seektest.shn $testdir/seekable.shn || exit 1
  rm -f seektest.shn

  # test non-creation of seek table from uncompressed data read from stdin
  $SHORTEN -v2 - seektest.shn < $testdir/test.wav || exit 1
  cmp seektest.shn $testdir/test.shn || exit 1
  rm -f seektest.shn

  # test non-creation of seek table from uncompressed data read from stdin
  $SHORTEN < $testdir/test.wav > seektest.shn || exit 1
  cmp seektest.shn $testdir/test.shn || exit 1
  rm -f seektest.shn

  # test appending of seek table
  $SHORTEN -k test.shn || exit 1
  cmp test.shn $testdir/seekable.shn || exit 1

  # test erasing of seek table
  $SHORTEN -e seekable.shn || exit 1
  cmp seekable.shn $testdir/test.shn || exit 1

  rm -f test.shn seekable.shn

  echo ""
done

exit 0
