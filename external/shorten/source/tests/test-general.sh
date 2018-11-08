#! /bin/sh

# $Id: test-general.sh,v 1.9 2002/11/15 15:56:24 jason Exp $

SHORTEN=../src/shorten

if [ ! -x "$SHORTEN" ]; then
  echo "*** $SHORTEN is missing, please build it ***"
  exit 1
fi

echo ""
echo "========================  General shorten tests  ========================="
echo ""

for testdir in mono stereo; do

  echo "+ Running general shorten tests against $testdir benchmark files..."
  echo ""

  for testfile in test.shn test.skt test.wav seekable.shn; do
    if [ ! -f "$testdir/$testfile" ]; then
      echo "*** Missing test file '$testfile', cannot continue... ***"
      exit 1
    fi
  done

  # sanity checks
  $SHORTEN -x $testdir/test.shn tmp.wav || exit 1
  cmp $testdir/test.wav tmp.wav || exit 1
  $SHORTEN -v2 $testdir/test.wav tmp.shn || exit 1
  cmp $testdir/test.shn tmp.shn || exit 1

  # test wave data to stdout from shorten data on stdin
  $SHORTEN < $testdir/test.wav > tmp.shn || exit 1
  cmp $testdir/test.shn tmp.shn || exit 1
  rm -f tmp.shn

  # test shorten data to stdout from wave data on stdin
  $SHORTEN -x < $testdir/test.shn > tmp.wav || exit 1
  cmp $testdir/test.wav tmp.wav || exit 1
  rm -f tmp.wav

  # test wav filename creation
  cp $testdir/test.wav tmp.wav
  $SHORTEN -v2 tmp.wav
  [ ! -f "tmp.shn" ] && exit 1
  $SHORTEN -x tmp.shn
  [ ! -f "tmp.wav" ] && exit 1
  rm -f tmp.wav

  # test non-wav filename creation
  cp $testdir/test.aiff tmp.aiff
  $SHORTEN -v2 tmp.aiff
  [ ! -f "tmp.aiff.shn" ] && exit 1
  $SHORTEN -x tmp.aiff.shn
  [ ! -f "tmp.aiff" ] && exit 1
  rm -f tmp.aiff

  # miscellaneous option checks (taken from original shorten makefile)

  for type in wav aiff; do
    echo "  + Checking $type test files..."

    tmpfile=tmp.$type

    if [ "$type" = "wav" ]; then
      tmpshn=test.shn
    else
      tmpshn=test.$type.shn
    fi

    $SHORTEN -x < $testdir/$tmpshn > $tmpfile
    $SHORTEN -v2 -t $type $tmpfile - | cmp - $testdir/$tmpshn || exit 1
    $SHORTEN -a2 -t s16 $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -a1024 -t s16x   $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -b1024 -t u16    $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -b 4   -t u16x   $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -m 0   -t s16hl  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -m 32  -t s16hl  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -v 0   -t s16hl  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -v 1   -t s16hl  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -v 2   -t s16hl  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -p1    -t s16hl  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -p16   -t s16hl  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -p16 -v2 -ts16hl $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -tulaw  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -talaw  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -ts8    $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -tu8    $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -ts16   $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -tu16   $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -tu16x  $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -ts16hl $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -tu16hl $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -ts16lh $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -tu16lh $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -c2 -tulaw $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -c2 -talaw $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -a340 -c16 $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -c2 -p4 -tu16 -b5 $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -v2 -t ulaw $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -v2 -t alaw $tmpfile - | $SHORTEN -x | cmp - $tmpfile || exit 1
    $SHORTEN -q3 -v2 $tmpfile tmp_q3.shn || exit 1
    $SHORTEN -q3 < $tmpfile > tmp_q3.shn || exit 1
    $SHORTEN -x tmp_q3.shn - | $SHORTEN | cmp - tmp_q3.shn || exit 1
    $SHORTEN -x tmp_q3.shn - | $SHORTEN -q3 | cmp - tmp_q3.shn || exit 1
    $SHORTEN -r3 -v2 $tmpfile tmp_r3.shn || exit 1

    rm -f tmp_q3.shn tmp_r3.shn $tmpfile $tmpshn

  done

  echo ""
done

exit 0
