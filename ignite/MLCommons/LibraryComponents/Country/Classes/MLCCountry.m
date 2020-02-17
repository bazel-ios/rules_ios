//
// MLCountry.m
// MeliSDK
//
// Created by Roman Babkin on 1/29/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLCCountry.h"
#import <MLCommons/NSDictionary+Null.h>

@implementation MLCCountry

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		_geoInformation = [[dictionary ml_objectForKey:@"geo_information"] copy];
		_decimalSeparator = [[dictionary ml_objectForKey:@"decimal_separator"] copy];
		_thousandsSeparator = [[dictionary ml_objectForKey:@"thousands_separator"] copy];
		_countryId = [[dictionary ml_objectForKey:@"countryId"] copy];
		_defaultCurrencyId = [[dictionary ml_objectForKey:@"defaultCurrencyId"] copy];
		_siteDomainSuffix = [[dictionary ml_objectForKey:@"site_domain_suffix"] copy];
		_isMpEnabled = [[dictionary ml_objectForKey:@"mp_enabled"] boolValue];
		_locale = [[dictionary ml_objectForKey:@"locale"] copy];
	}
	return self;
}

@end
