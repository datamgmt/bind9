#!/bin/sh
#
# Copyright (C) 2011-2015, 2017  Internet Systems Consortium, Inc. ("ISC")
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

rm -f dig.out.*.test*
rm -f ns*/named.lock
rm -f ns*/named.memstats
rm -f ns*/named.run
rm -f ns2/named.stats
rm -f ns2/nil.db ns2/other.db ns2/static.db ns2/*.jnl
rm -f ns2/session.key
rm -f ns3/named_dump.db
rm -f ns4/*.nta
rm -f ns4/key?.conf
rm -f ns6/huge.zone.db
rm -f ns*/named.conf
rm -f nsupdate.out.*.test*
rm -f python.out.*.test*
rm -f rndc.out.*.test*
