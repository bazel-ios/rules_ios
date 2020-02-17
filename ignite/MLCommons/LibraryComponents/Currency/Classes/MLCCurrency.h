//
// MLCCurrency.h
// MLCommons
//
// Created by Itay Brenner on 6/13/18.
// Copyright (c) 2018 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLCCurrency : NSObject

// Quantity of decimals handled by the currency
@property (nonatomic, copy) NSNumber *decimalPlaces;

// ISO symbol that represents the currency
@property (nonatomic, copy) NSString *symbol;

@end
