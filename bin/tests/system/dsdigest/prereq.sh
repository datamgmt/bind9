#!/bin/sh -e
#
# Copyright (C) 2012, 2014  Internet Systems Consortium, Inc. ("ISC")
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

gostfail=0 ecdsafail=0
$SHELL ../testcrypto.sh -q gost || gostfail=1
$SHELL ../testcrypto.sh -q ecdsa || ecdsafail=1

if [ $gostfail = 0 -a $ecdsafail = 0 ]; then
	echo both > supported
elif [ $gostfail = 1 -a $ecdsafail = 1 ]; then
	echo_i "This test requires support for ECDSA or GOST cryptography." >&2
	exit 255
elif [ $gostfail = 0 ]; then
	echo gost > supported
else
        echo ecdsa > supported
fi
