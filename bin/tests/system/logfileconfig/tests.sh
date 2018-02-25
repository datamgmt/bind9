#!/bin/sh
#
# Copyright (C) 2011-2013, 2016, 2017  Internet Systems Consortium, Inc. ("ISC")
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS.  IN NO EVENT SHALL ISC BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
# OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

SYSTEMTESTTOP=..
. $SYSTEMTESTTOP/conf.sh
THISDIR=`pwd`
CONFDIR="ns1"

PLAINCONF="${THISDIR}/${CONFDIR}/named.plain"
PLAINFILE="named_log"
DIRCONF="${THISDIR}/${CONFDIR}/named.dirconf"
DIRFILE="named_dir"
PIPECONF="${THISDIR}/${CONFDIR}/named.pipeconf"
PIPEFILE="named_pipe"
SYMCONF="${THISDIR}/${CONFDIR}/named.symconf"
SYMFILE="named_sym"
UNLIMITEDCONF="${THISDIR}/${CONFDIR}/named.unlimited"
UNLIMITEDFILE="named_unlimited"
DLFILE="named_deflog"

PIDFILE="${THISDIR}/${CONFDIR}/named.pid"
myRNDC="$RNDC -c ${THISDIR}/${CONFDIR}/rndc.conf"
myNAMED="$NAMED -c ${THISDIR}/${CONFDIR}/named.conf -m record,size,mctx -T clienttest -T nosyslog -d 99 -U 4"

# Test given condition.  If true, test again after a second.  Used for testing
# filesystem-dependent conditions in order to prevent false negatives caused by
# directory contents not being synchronized immediately after rename() returns.
test_with_retry() {
	if test "$@"; then
		sleep 1
		if test "$@"; then
			return 0
		fi
	fi
	return 1
}

status=0
n=0

cd $CONFDIR

echo_i "testing log file validity (named -g + only plain files allowed)"

n=`expr $n + 1`
echo_i "testing plain file (named -g) ($n)"
# First run with a known good config.
echo > $PLAINFILE
copy_setports $PLAINCONF named.conf
$myRNDC reconfig > rndc.out.test$n 2>&1
grep "reloading configuration failed" named.run > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo_i "testing plain file succeeded"
else
	echo_i "testing plain file failed (unexpected)"
	echo_i "exit status: 1"
	exit 1 
fi

# Now try directory, expect failure
n=`expr $n + 1`
echo_i "testing directory as log file (named -g) ($n)"
echo > named.run
rm -rf $DIRFILE
mkdir -p $DIRFILE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	copy_setports $DIRCONF named.conf
	echo > named.run
	$myRNDC reconfig > rndc.out.test$n 2>&1
	grep "checking logging configuration failed: invalid file" named.run > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo_i "testing directory as file succeeded (UNEXPECTED)"
		echo_i "exit status: 1"
		exit 1
	else
		echo_i "testing directory as log file failed (expected)"
	fi
else
	echo_i "skipping directory test (unable to create directory)"
fi

# Now try pipe file, expect failure
n=`expr $n + 1`
echo_i "testing pipe file as log file (named -g) ($n)"
echo > named.run
rm -f $PIPEFILE
mkfifo $PIPEFILE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	copy_setports $PIPECONF named.conf
	echo > named.run
	$myRNDC reconfig > rndc.out.test$n 2>&1
	grep "checking logging configuration failed: invalid file" named.run  > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo_i "testing pipe file as log file succeeded (UNEXPECTED)"
		echo_i "exit status: 1"
		exit 1
	else
		echo_i "testing pipe file as log file failed (expected)"
	fi
else
	echo_i "skipping pipe test (unable to create pipe)"
fi

# Now try symlink file to plain file, expect success 
n=`expr $n + 1`
echo_i "testing symlink to plain file as log file (named -g) ($n)"
# Assume success
echo > named.run
echo > $PLAINFILE
rm -f  $SYMFILE  $SYMFILE
ln -s $PLAINFILE $SYMFILE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	copy_setports $SYMCONF named.conf
	$myRNDC reconfig > rndc.out.test$n 2>&1
	echo > named.run
	grep "reloading configuration failed" named.run > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo_i "testing symlink to plain file succeeded"
	else
		echo_i "testing symlink to plain file failed (unexpected)"
		echo_i "exit status: 1"
		exit 1
	fi
else
	echo_i "skipping symlink test (unable to create symlink)"
fi
# Stop the server and run through a series of tests with various config
# files while controlling the stop/start of the server.
# Have to stop the stock server because it uses "-g"
#
$PERL ../../stop.pl .. ns1

$myNAMED > /dev/null 2>&1

if [ $? -ne 0 ]
then
	echo_i "failed to start $myNAMED"
	echo_i "exit status: $status"
	exit $status
fi

status=0

echo_i "testing log file validity (only plain files allowed)"

n=`expr $n + 1`
echo_i "testing plain file (named -g) ($n)"
# First run with a known good config.
echo > $PLAINFILE
copy_setports $PLAINCONF named.conf
$myRNDC reconfig > rndc.out.test$n 2>&1
grep "reloading configuration failed" named.run > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo_i "testing plain file succeeded"
else
	echo_i "testing plain file failed (unexpected)"
	echo_i "exit status: 1"
	exit 1 
fi

# Now try directory, expect failure
n=`expr $n + 1`
echo_i "testing directory as log file ($n)"
echo > named.run
rm -rf $DIRFILE
mkdir -p $DIRFILE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	copy_setports $DIRCONF named.conf
	echo > named.run
	$myRNDC reconfig > rndc.out.test$n 2>&1
	grep "configuring logging: invalid file" named.run > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo_i "testing directory as file succeeded (UNEXPECTED)"
		echo_i "exit status: 1"
		exit 1
	else
		echo_i "testing directory as log file failed (expected)"
	fi
else
	echo_i "skipping directory test (unable to create directory)"
fi

# Now try pipe file, expect failure
n=`expr $n + 1`
echo_i "testing pipe file as log file ($n)"
echo > named.run
rm -f $PIPEFILE
mkfifo $PIPEFILE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	copy_setports $PIPECONF named.conf
	echo > named.run
	$myRNDC reconfig > rndc.out.test$n 2>&1
	grep "configuring logging: invalid file" named.run  > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo_i "testing pipe file as log file succeeded (UNEXPECTED)"
		echo_i "exit status: 1"
		exit 1
	else
		echo_i "testing pipe file as log file failed (expected)"
	fi
else
	echo_i "skipping pipe test (unable to create pipe)"
fi

# Now try symlink file to plain file, expect success 
n=`expr $n + 1`
echo_i "testing symlink to plain file as log file ($n)"
# Assume success
status=0
echo > named.run
echo > $PLAINFILE
rm -f $SYMFILE
ln -s $PLAINFILE $SYMFILE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	copy_setports $SYMCONF named.conf
	$myRNDC reconfig > rndc.out.test$n 2>&1
	echo > named.run
	grep "reloading configuration failed" named.run > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo_i "testing symlink to plain file succeeded"
	else
		echo_i "testing symlink to plain file failed (unexpected)"
		echo_i "exit status: 1"
		exit 1
	fi
else
	echo_i "skipping symlink test (unable to create symlink)"
fi

echo_i "testing logging functionality"

n=`expr $n + 1`
echo_i "testing explicit versions ($n)"
cp $VERSCONF named.conf
# a seconds since epoch version number
touch $VERSFILE.1480039317
t1=`$PERL -e 'print time()."\n";'`
$myRNDC reconfig > rndc.out.test$n 2>&1
$DIG version.bind txt ch @10.53.0.1 -p ${PORT} > dig.out.test$n
t2=`$PERL -e 'print time()."\n";'`
t=`expr ${t2:-0} - ${t1:-0}`
if test ${t:-1000} -gt 5
then
        echo_i "testing explicit versions failed: cleanup of old entries took too long ($t secs)"
	status=`expr $status + 1`
fi 
if ! grep "status: NOERROR" dig.out.test$n > /dev/null
then
	echo_i "testing explicit versions failed: DiG lookup failed"
	status=`expr $status + 1`
fi
if test_with_retry -f $VERSFILE.1480039317
then
	echo_i "testing explicit versions failed: $VERSFILE.1480039317 not removed"
	status=`expr $status + 1`
fi
if test_with_retry -f $VERSFILE.5
then
	echo_i "testing explicit versions failed: $VERSFILE.5 exists"
	status=`expr $status + 1`
fi
if test_with_retry ! -f $VERSFILE.4
then
	echo_i "testing explicit versions failed: $VERSFILE.4 does not exist"
	status=`expr $status + 1`
fi

n=`expr $n + 1`
echo_i "testing unlimited versions ($n)"
cp $UNLIMITEDCONF named.conf
# a seconds since epoch version number
touch $UNLIMITEDFILE.1480039317
t1=`$PERL -e 'print time()."\n";'`
$myRNDC reconfig > rndc.out.test$n 2>&1
$DIG version.bind txt ch @10.53.0.1 -p ${PORT} > dig.out.test$n
t2=`$PERL -e 'print time()."\n";'`
t=`expr ${t2:-0} - ${t1:-0}`
if test ${t:-1000} -gt 5
then
        echo_i "testing unlimited versions failed: took too long ($t secs)"
	status=`expr $status + 1`
fi 
if ! grep "status: NOERROR" dig.out.test$n > /dev/null
then
	echo_i "testing unlimited versions failed: DiG lookup failed"
	status=`expr $status + 1`
fi
if test_with_retry ! -f $UNLIMITEDFILE.1480039317
then
	echo_i "testing unlimited versions failed: $UNLIMITEDFILE.1480039317 removed"
	status=`expr $status + 1`
fi
if test_with_retry ! -f $UNLIMITEDFILE.4
then
	echo_i "testing unlimited versions failed: $UNLIMITEDFILE.4 does not exist"
	status=`expr $status + 1`
fi

echo_i "exit status: $status"
[ $status -eq 0 ] || exit 1
