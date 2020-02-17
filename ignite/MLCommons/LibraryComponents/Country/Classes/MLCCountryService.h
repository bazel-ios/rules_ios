//
// MLCountryService.h
// MeliSDK
//
// Created by Roman Babkin on 1/16/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCCountry.h"

@interface MLCCountryService : NSObject

/**
 *
 *  @return service instance
 */
+ (instancetype)sharedServiceInstance;

/**
 *  Retrieves country information.
 *
 *  @param siteId siteId of country to be retrieved.
 *
 *  @return MLCountry Country information by siteId
 */
- (MLCCountry *)getCountryBySiteId:(NSString *)siteId;

/**
 *  Return the siteId based on countryId. If the countryIdOrSiteId is already a siteId return the same value.
 *
 *  @param countryIdOrSiteId countryId or siteId param to convert or check.
 */
- (NSString *)convertToSiteId:(NSString *)countryIdOrSiteId;

/**
 *  Check if the url belongs to a mercadolibre site
 *
 *  @param url to check
 *
 *  @return YES if pass validations, otherwise NO
 */
- (BOOL)isMercadolibreSite:(NSString *)url;

@end
