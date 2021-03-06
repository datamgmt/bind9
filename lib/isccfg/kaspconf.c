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

#include <inttypes.h>
#include <stdbool.h>
#include <stdlib.h>

#include <isc/mem.h>
#include <isc/print.h>
#include <isc/string.h>
#include <isc/util.h>

#include <isccfg/namedconf.h>
#include <isccfg/cfg.h>
#include <isccfg/kaspconf.h>

#include <dns/kasp.h>
#include <dns/keyvalues.h>
#include <dns/log.h>


/*
 * Utility function for getting a configuration option.
 */
static isc_result_t
confget(cfg_obj_t const * const *maps, const char *name, const cfg_obj_t **obj)
{
	for (size_t i = 0;; i++) {
		if (maps[i] == NULL) {
			return (ISC_R_NOTFOUND);
		}
		if (cfg_map_get(maps[i], name, obj) == ISC_R_SUCCESS) {
			return (ISC_R_SUCCESS);
		}
	}
}

/*
 * Utility function for configuring durations.
 */
static uint32_t
get_duration(const cfg_obj_t **maps, const char* option, uint32_t dfl)
{
	const cfg_obj_t *obj;
	isc_result_t result;
	obj = NULL;

	result = confget(maps, option, &obj);
	if (result == ISC_R_NOTFOUND) {
		return (dfl);
	}
	INSIST(result == ISC_R_SUCCESS);
	return (cfg_obj_asduration(obj));
}

/*
 * Create a new kasp key derived from configuration.
 */
static isc_result_t
cfg_kaspkey_fromconfig(const cfg_obj_t *config, dns_kasp_t* kasp)
{
	isc_result_t result;
	dns_kasp_key_t *key = NULL;

	/* Create a new key reference. */
	result = dns_kasp_key_create(kasp, &key);
	if (result != ISC_R_SUCCESS) {
		return (result);
	}
	if (config == NULL) {
		/* We are creating a key reference for the default kasp. */
		key->role |= DNS_KASP_KEY_ROLE_KSK | DNS_KASP_KEY_ROLE_ZSK;
		key->lifetime = 0;
		key->algorithm = DNS_KEYALG_ECDSA256;
		key->length = -1;
	} else {
		const char* rolestr;
		const cfg_obj_t* obj;

		rolestr = cfg_obj_asstring(cfg_tuple_get(config, "role"));
		if (strcmp(rolestr, "ksk") == 0) {
			key->role |= DNS_KASP_KEY_ROLE_KSK;
		} else if (strcmp(rolestr, "zsk") == 0) {
			key->role |= DNS_KASP_KEY_ROLE_ZSK;
		} else if (strcmp(rolestr, "csk") == 0) {
			key->role |= DNS_KASP_KEY_ROLE_KSK;
			key->role |= DNS_KASP_KEY_ROLE_ZSK;
		}
		key->lifetime = cfg_obj_asduration(
					     cfg_tuple_get(config, "lifetime"));
		key->algorithm = cfg_obj_asuint32(
					    cfg_tuple_get(config, "algorithm"));
		obj = cfg_tuple_get(config, "length");
		if (cfg_obj_isuint32(obj)) {
			key->length = cfg_obj_asuint32(obj);
		}
	}
	dns_kasp_addkey(kasp, key);
	return (result);
}

isc_result_t
cfg_kasp_fromconfig(const cfg_obj_t *config, isc_mem_t* mctx,
		    dns_kasplist_t *kasplist, dns_kasp_t **kaspp)
{
	isc_result_t result;
	const cfg_obj_t *maps[2];
	const cfg_obj_t *koptions = NULL;
	const cfg_obj_t *keys = NULL;
	const cfg_listelt_t *element = NULL;
	const char *kaspname = NULL;
	dns_kasp_t *kasp = NULL;
	int i = 0;

	REQUIRE(kaspp != NULL && *kaspp == NULL);

	kaspname = (config != NULL) ?
		    cfg_obj_asstring(cfg_tuple_get(config, "name")) :
		    "default";

	REQUIRE(strcmp(kaspname, "none") != 0);

	result = dns_kasplist_find(kasplist, kaspname, &kasp);

	if (result == ISC_R_SUCCESS) {
		return (ISC_R_EXISTS);
	}
	if (result != ISC_R_NOTFOUND) {
		return (result);
	}

	/* No kasp with configured name was found in list, create new one. */
	INSIST(kasp == NULL);
	result = dns_kasp_create(mctx, kaspname, &kasp);
	if (result != ISC_R_SUCCESS) {
		return (result);
	}
	INSIST(kasp != NULL);

	/* Now configure. */
	INSIST(DNS_KASP_VALID(kasp));

	if (config != NULL) {
		koptions = cfg_tuple_get(config, "options");
		maps[i++] = koptions;
	}
	maps[i] = NULL;

	/* Configuration: Signatures */
	dns_kasp_setsigrefresh(kasp, get_duration(maps, "signatures-refresh",
						  DNS_KASP_SIG_REFRESH));
	dns_kasp_setsigvalidity(kasp, get_duration(maps, "signatures-validity",
						   DNS_KASP_SIG_VALIDITY));
	dns_kasp_setsigvalidity_dnskey(kasp, get_duration(maps,
						   "signatures-validity-dnskey",
						 DNS_KASP_SIG_VALIDITY_DNSKEY));

	/* Configuration: Keys */
	dns_kasp_setdnskeyttl(kasp, get_duration(maps, "dnskey-ttl",
						 DNS_KASP_KEY_TTL));
	dns_kasp_setpublishsafety(kasp, get_duration(maps, "publish-safety",
						     DNS_KASP_PUBLISH_SAFETY));
	dns_kasp_setretiresafety(kasp, get_duration(maps, "retire-safety",
						    DNS_KASP_RETIRE_SAFETY));

	(void)confget(maps, "keys", &keys);
	if (keys == NULL) {
		result = cfg_kaspkey_fromconfig(NULL, kasp);
		if (result != ISC_R_SUCCESS) {
			goto cleanup;
		}
	} else {
		for (element = cfg_list_first(keys); element != NULL;
		     element = cfg_list_next(element))
		{
			cfg_obj_t *kobj = cfg_listelt_value(element);
			result = cfg_kaspkey_fromconfig(kobj, kasp);
			if (result != ISC_R_SUCCESS) {
				goto cleanup;
			}
		}
	}
	ISC_INSIST(!(dns_kasp_keylist_empty(kasp)));

	/* Configuration: Zone settings */
	dns_kasp_setzonemaxttl(kasp, get_duration(maps, "zone-max-ttl",
						  DNS_KASP_ZONE_MAXTTL));
	dns_kasp_setzonepropagationdelay(kasp, get_duration(maps,
						       "zone-propagation-delay",
						      DNS_KASP_ZONE_PROPDELAY));

	/* Configuration: Parent settings */
	dns_kasp_setdsttl(kasp, get_duration(maps, "parent-ds-ttl",
					     DNS_KASP_DS_TTL));
	dns_kasp_setparentpropagationdelay(kasp, get_duration(maps,
						     "parent-propagation-delay",
						    DNS_KASP_PARENT_PROPDELAY));
	dns_kasp_setparentregistrationdelay(kasp, get_duration(maps,
						    "parent-registration-delay",
						     DNS_KASP_PARENT_REGDELAY));

	// TODO: Rest of the configuration

	/* Append it to the list for future lookups. */
	ISC_LIST_APPEND(*kasplist, kasp, link);
	ISC_INSIST(!(ISC_LIST_EMPTY(*kasplist)));

	/* Success: Attach the kasp to the pointer and return. */
	dns_kasp_attach(kasp, kaspp);
	/* Don't detach as kasp is on '*kasplist' */
	return (ISC_R_SUCCESS);

cleanup:

	/* Something bad happened, detach (destroys kasp) and return error. */
	dns_kasp_detach(&kasp);
	return (result);
}
