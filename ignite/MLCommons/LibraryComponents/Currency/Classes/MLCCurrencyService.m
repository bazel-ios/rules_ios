//
// MLCCurrencyService.m
// MLCommons
//
// Created by Itay Brenner on 6/13/18.
// Copyright (c) 2018 MercadoLibre. All rights reserved.
//

#import "MLCCurrencyService.h"
#import "MLCCurrency.h"
#import "NSDictionary+Null.h"
#import "MLCommonBundle.h"

@interface MLCCurrencyService ()

// Contiene contenido de plist, se crea una sola vez para no acceder al disco.
@property (nonatomic, strong) NSDictionary *currenciesPList;

// Cache de configs, que se llena on demand.
@property (nonatomic, strong) NSMutableDictionary *lastCurrencies;

@end

@implementation MLCCurrencyService

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
	NSString *path = [[MLCommonBundle bundle] pathForResource:@"MLCCurrencyConfig" ofType:@"plist"];

	_currenciesPList = [[NSDictionary alloc] initWithContentsOfFile:path];

	_lastCurrencies = [[NSMutableDictionary alloc] init];
}

#pragma mark - static public methods
- (MLCCurrency *)getCurrencyWithId:(NSString *)currencyId
{
	MLCCurrency *currency = [_lastCurrencies ml_objectForKey:currencyId];
	if (currency == nil) {
		currency = [[MLCCurrency alloc] init];
		NSDictionary *currencyDict = _currenciesPList[currencyId];
		currency.decimalPlaces = currencyDict[@"decimal_places"];
		currency.symbol = currencyDict[@"symbol"];
		self.lastCurrencies[currencyId] = currency;
	}
	return currency;
}

@end
