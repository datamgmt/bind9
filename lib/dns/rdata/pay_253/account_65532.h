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

/*

// Possible Replacement Structure

typedef struct dns_rdata_account {
	dns_rdatacommon_t	common;
	isc_mem_t		*mctx;
	// The rdata is now pref, scheme_name, account_token, currency_code
	// pref: unisgned 16 bit int for compatibility with MX format
	uint16_t		pref;
	// scheme_name_length: unsignted 8 bit int - valid values 1-16
	uint8_t			scheme_name_len;
	// scheme_name: ascii string 1-15 chars long
	pay_scheme_name_t		scheme_name;
	// account_name_length: unsigned 8-bit int - valid values 1-192
	uint8_t			account_token_len
	// account_token: ascii string 1-192 chars long
    pay_account_token_t     account_token;
	// xurrency_code: ascii string 3 chars long, valid values must be part of ISI 4217
	// See https://www.iso.org/iso-4217-currency-codes.html 
	// and https://en.wikipedia.org/wiki/ISO_4217
    pay_currency_code_t	    currency_code;
	// The total RDAT size can vary from 10 to 215 in length which is less than <255 max recommended
} dns_rdata_account_t;

*/

#endif /* PAY_253_ACCOUNT_65532_H */
