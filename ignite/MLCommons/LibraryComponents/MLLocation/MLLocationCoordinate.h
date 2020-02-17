//
// MLLocationCoordinate.h
// MLCommons
//
// Created by Mauricio Minestrelli on 10/31/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN
@interface MLLocationCoordinate : NSObject
@property (nonatomic, strong, readonly) NSNumber *latitude;
@property (nonatomic, strong, readonly) NSNumber *longitude;

/**
 *  Returns an MLLocationCoordinate object with a CLLocation object and todays date
 *
 *  @param location a CLLocation location
 *
 *  @return an MLLocationCoordinate object initialized with latitude and longitude from param and today date
 */
- (instancetype)initWithLocation:(CLLocation *)location;

/**
 *  Returns an MLLocationCoordinate object with the values from the dictionary representation of the object
 *
 *  @param dictionary representation of a MLLocationCoordinate
 *
 *  @return an MLLocationCoordinate object initialized withthe values from the dictionary representation of the object, nil if any of the components of the object is corrupted
 */
- (nullable instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Verifies if a date has expired the recommended cache time
 *  @return YES if creation date is older than 6 months from today, NO otherwise
 */
- (BOOL)isExpired;

/**
 *  Returns a NSDictionary representation of the object to be stored.
 *  @return a NSDictionary representation of the object with the content of its variables.
 */
- (NSDictionary *)dictionaryRepresentation;
@end
NS_ASSUME_NONNULL_END
