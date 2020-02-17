//
// MLCountry.h
// MeliSDK
//
// Created by Roman Babkin on 1/29/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLCCountry : NSObject

/**
 * Geopositioning information.
 *
 * Keys:
 * latitude: Latitude
 * longitude: Longitude
 * zoom: Zoom level (uses an exponentional scale, where zoom 0 represents the entire world as a
 * 256 x 256 square. Each successive zoom level increases magnification by a factor of 2. So at
 * zoom level 1, the world is 512x512, and at zoom level 2, the entire world is 1024x1024.
 * See https://developers.google.com/maps/terms  */
@property (nonatomic, readonly, copy) NSDictionary *geoInformation;

// Currency decimal separator
@property (nonatomic, readonly, copy) NSString *decimalSeparator;

// Currency thousands separator
@property (nonatomic, readonly, copy) NSString *thousandsSeparator;

// Country id
@property (nonatomic, readonly, copy) NSString *countryId;

// Default currency id
@property (nonatomic, copy) NSString *defaultCurrencyId;

// Site domain suffix
@property (nonatomic, readonly, copy) NSString *siteDomainSuffix;

// Gets if Mercadopago is enabled
@property (nonatomic, readonly) BOOL isMpEnabled;

// Country locale
@property (nonatomic, readonly, copy) NSString *locale;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
