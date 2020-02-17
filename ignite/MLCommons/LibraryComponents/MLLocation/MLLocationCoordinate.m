//
// MLLocationCoordinate.m
// MLCommons
//
// Created by Mauricio Minestrelli on 10/31/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLLocationCoordinate.h"
#import "NSDictionary+Null.h"

NSString *const kMLLocationCoordinateLatitudeKey = @"latitude";
NSString *const kMLLocationCoordinateLongitudeKey = @"longitude";
NSString *const kMLLocationCoordinateDateKey = @"date";

@interface MLLocationCoordinate ()
@property (nonatomic, strong) NSDate *creationDate;
@end

@implementation MLLocationCoordinate

- (instancetype)initWithLocation:(CLLocation *)location
{
	self = [super init];

	if (self) {
		_latitude = [[NSNumber alloc] initWithDouble:location.coordinate.latitude];
		_longitude = [[NSNumber alloc] initWithDouble:location.coordinate.longitude];
		self.creationDate = [NSDate date];
	}
	return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	if (dictionary && [dictionary ml_objectForKey:kMLLocationCoordinateLatitudeKey] && [dictionary ml_objectForKey:kMLLocationCoordinateLongitudeKey] && [dictionary ml_objectForKey:kMLLocationCoordinateDateKey]) {
		CLLocation *location = [[CLLocation alloc]initWithLatitude:[((NSNumber *)[dictionary ml_objectForKey:kMLLocationCoordinateLatitudeKey]) doubleValue] longitude:[((NSNumber *)[dictionary ml_objectForKey:kMLLocationCoordinateLongitudeKey]) doubleValue]];
		MLLocationCoordinate *coordinate = [[MLLocationCoordinate alloc]initWithLocation:location];
		coordinate.creationDate = [dictionary ml_objectForKey:kMLLocationCoordinateDateKey];
		return coordinate;
	}
	return nil;
}

- (BOOL)isExpired
{
	NSDateComponents *dateComponents = [NSDateComponents new];
	dateComponents.month = -6;
	NSDate *expirationDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];

	return [self.creationDate compare:expirationDate] == NSOrderedAscending;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSDictionary *dictionary = @{kMLLocationCoordinateLatitudeKey : self.latitude,
	                             kMLLocationCoordinateLongitudeKey : self.longitude,
	                             kMLLocationCoordinateDateKey : self.creationDate};
	return dictionary;
}

@end
