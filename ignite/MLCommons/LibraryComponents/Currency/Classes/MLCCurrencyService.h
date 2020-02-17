//
// MLCCurrencyService.h
// MLCommons
//
// Created by Itay Brenner on 6/13/18.
// Copyright (c) 2018 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCCurrency.h"

@interface MLCCurrencyService : NSObject

/**
 *
 *  @return service instance
 */
+ (instancetype)sharedServiceInstance;

/**
 *  Retrieves information about an specific currency.
 *
 *  @param currencyId currencyId (ISO code) to be retrieved.
 *
 *  @return MLCurrency Currency information by currencyId
 */
- (MLCCurrency *)getCurrencyWithId:(NSString *)currencyId;

@end
