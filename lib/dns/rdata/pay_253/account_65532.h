/*
 * Copyright (C) Internet Systems Consortium, Inc. ("ISC")
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * See the COPYRIGHT file distributed with this work for additional
 * information regarding copyright ownership.
 */

/* */
#ifndef PAY_253_ACCOUNT_65532_H
#define PAY_253_ACCOUNT_65532_H 1


typedef struct dns_rdata_account {
	dns_rdatacommon_t	common;
	isc_mem_t		*mctx;
	uint16_t		pref;
	dns_name_t		account;
} dns_rdata_account_t;

#endif /* PAY_253_ACCOUNT_65532_H */
