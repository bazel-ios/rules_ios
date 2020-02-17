//
// MLCountryService.m
// MeliSDK
//
// Created by Roman Babkin on 1/16/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLCCountryService.h"
#import "MLCCountry.h"
#import <MLCommons/NSDictionary+Null.h>
#import "MLCommonBundle.h"

@interface MLCCountryService ()

// Contiene contenido de plist, se crea una sola vez para no acceder al disco.
@property (nonatomic, strong) NSDictionary *countriesConfigPList;

// Cache de configs, que se llena on demand.
@property (nonatomic, strong) NSMutableDictionary *lastCountriesConfig;

@end

@implementation MLCCountryService;

+ (instancetype)sharedServiceInstance
{
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
	self = [super init];

	if (self) {
		[self loadConfigFromFile];
	}

	return self;
}

- (void)loadConfigFromFile
{
	NSString *path = [[MLCommonBundle bundle] pathForResource:@"MLCCountryConfig" ofType:@"plist"];

	_countriesConfigPList = [[NSDictionary alloc] initWithContentsOfFile:path];

	_lastCountriesConfig = [[NSMutableDictionary alloc] init];
}

- (MLCCountry *)getCountryBySiteId:(NSString *)siteId
{
	if (!siteId) {
		return nil;
	}

	MLCCountry *countryConfig = [_lastCountriesConfig ml_objectForKey:siteId];
	if (!countryConfig) {
		NSDictionary *countryConfigDict = _countriesConfigPList[siteId];
		if (!countryConfigDict) {
			return nil;
		}
		countryConfig = [[MLCCountry alloc] initWithDictionary:countryConfigDict];
		self.lastCountriesConfig[siteId] = countryConfig;
	}

	return countryConfig;
}

- (NSString *)convertToSiteId:(NSString *)countryIdOrSiteId
{
	NSDictionary *countriesConfig = _countriesConfigPList;

	// Verify if the parameter is already a site_id.
	if (countriesConfig[countryIdOrSiteId]) {
		return countryIdOrSiteId;
	}

	// If the parameter is not a siteId, use it as country_id for searching site_id.
	for (NSString *siteId in countriesConfig) {
		NSDictionary *countryConfig = countriesConfig[siteId];
		if ([countryConfig[@"countryId"] isEqualToString:countryIdOrSiteId]) {
			return siteId;
		}
	}

	// If there is no match, returns the original value.
	return countryIdOrSiteId;
}

- (BOOL)isMercadolibreSite:(NSString *)urlStr
{
	if (!urlStr) {
		return NO;
	}

	NSURL *url = [NSURL URLWithString:urlStr];
	if (!url) {
		return NO;
	}

	// prevent using the cache, because is unnecesary
	NSArray *allKeys = [_countriesConfigPList allKeys];
	for (NSString *key in allKeys) {
		NSString *siteDomainSuffix = [_countriesConfigPList[key] ml_objectForKey:@"site_domain_suffix"];
		if (siteDomainSuffix && [url.host hasSuffix:siteDomainSuffix]) {
			return YES;
		}
	}

	return NO;
}

@end
