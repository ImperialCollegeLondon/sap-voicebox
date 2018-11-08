#! /bin/sh

# $Id: test-errors.sh,v 1.4 2002/01/30 01:50:27 jason Exp $

SHORTEN=../src/shorten

if [ ! -x "$SHORTEN" ]; then
  echo "*** $SHORTEN is missing, please build it ***"
  exit 1
fi

echo ""
echo "=========================  shorten error tests  =========================="
echo ""

for testdir in mono stereo; do

  echo "+ Running error tests against $testdir benchmark files..."
  echo ""

  for testfile in test.shn test.skt test.wav seekable.shn; do
    if [ ! -f "$testdir/$testfile" ]; then
      echo "*** Missing test file '$testfile', cannot continue... ***"
      exit 1
    fi
  done

  cp $testdir/test.shn $testdir/test.wav $testdir/seekable.shn .

  # test seek table manipulation from stdin
  cat test.shn | $SHORTEN -e && exit 1
  cat test.shn | $SHORTEN -k && exit 1
  cat test.shn | $SHORTEN -i && exit 1

  # test for tty on stdin/stdout
  $SHORTEN - - && exit 1
  $SHORTEN - test.shn && exit 1
  $SHORTEN -x - test.wav && exit 1
  $SHORTEN test.wav - && exit 1
  $SHORTEN -x test.shn - && exit 1

  # test missing filename with -S
  $SHORTEN -S test.shn && exit 1

  # test parameters out of range
  $SHORTEN -a -1 test.wav && exit 1
  $SHORTEN -b 0 test.shn && exit 1
  $SHORTEN -c 0 test.shn && exit 1
  $SHORTEN -d -1 test.wav && exit 1
  $SHORTEN -m -1 test.wav && exit 1
  $SHORTEN -n -1 test.wav && exit 1
  $SHORTEN -p -1 test.wav && exit 1
  $SHORTEN -p 65 test.wav && exit 1
  $SHORTEN -q -1 test.wav && exit 1
  $SHORTEN -t bad test.wav && exit 1
  $SHORTEN -v -1 test.wav && exit 1
  $SHORTEN -v 4 test.wav && exit 1

  # test seek table generation from non-shorten data
  $SHORTEN -s test.wav && exit 1
  [ -f "test.wav.skt" ] && exit 1
  $SHORTEN -Stest.skt test.wav && exit 1
  [ -f "test.skt" ] && exit 1
  $SHORTEN -k test.wav && exit 1
  [ -f "test.wav.skt" ] && exit 1

  # test mutually exclusive parameters
  $SHORTEN -s -Stest.skt test.shn && exit 1
  $SHORTEN -e -i test.shn && exit 1
  $SHORTEN -e -k test.shn && exit 1
  $SHORTEN -i -k test.shn && exit 1
  $SHORTEN -e -x test.shn && exit 1
  $SHORTEN -i -x test.shn && exit 1
  $SHORTEN -k -x test.shn && exit 1
  $SHORTEN -s -x test.shn && exit 1
  $SHORTEN -Stest.skt -x test.shn && exit 1
  $SHORTEN -s -k test.shn && exit 1
  $SHORTEN -Stest.skt -k test.shn && exit 1
  $SHORTEN -b 32 -p 32 test.wav && exit 1
  $SHORTEN -u -t alaw test.wav && exit 1

  # test too many filenames
  $SHORTEN test.wav test.wav test.wav && exit 1

  # test discarding more bytes than file length
  $SHORTEN -d 1048576 test.wav && exit 1
  rm -f test.shn
  cp $testdir/test.shn test.shn

  $SHORTEN -x -d 1048576 test.shn && exit 1
  rm -f test.wav
  cp $testdir/test.wav test.wav

  # test appending seek tables to file that already has them
  $SHORTEN -k seekable.shn && exit 1

  # test deleting seek tables from file that does not have them
  $SHORTEN -e test.shn && exit 1

  # test shorten of missing file
  $SHORTEN missing.wav && exit 1

  # test un-shorten of missing file
  $SHORTEN -x missing.shn && exit 1

  # test shorten of non-audio file
  $SHORTEN test.shn && exit 1

  rm -f test.shn test.wav seekable.shn

  echo ""
done

exit 0
