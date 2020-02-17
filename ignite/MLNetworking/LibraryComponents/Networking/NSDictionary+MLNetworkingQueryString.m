//
// NSDictionary+MLNetworkingQueryString.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/22/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "NSDictionary+MLNetworkingQueryString.h"
#import "NSString+MLNetworkingURLEncode.h"

@implementation NSDictionary (MLNetworkingQueryString)

- (NSString *)mlNetworking_queryString
{
	NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [self keyEnumerator]) {
		if ([self[key] isKindOfClass:[NSString class]] || [self[key] isKindOfClass:[NSNumber class]]) {
			NSString *valueToAdd = [NSString stringWithFormat:@"%@", self[key]];
			valueToAdd = [valueToAdd mlNetworking_URLEncodedString];
			valueToAdd = [NSString stringWithFormat:@"%@=%@", key, valueToAdd];
			[pairs addObject:valueToAdd];
		}
		if ([self[key] isKindOfClass:[NSArray class]]) {
			NSMutableArray *encodedElements = [NSMutableArray arrayWithCapacity:[self[key] count]];
			for (NSString *value in self[key]) {
				[encodedElements addObject:[value mlNetworking_URLEncodedString]];
			}

			NSString *valueToAdd = [encodedElements componentsJoinedByString:@","];

			valueToAdd = [NSString stringWithFormat:@"%@=%@", key, valueToAdd];

			[pairs addObject:valueToAdd];
		}
	}
	NSString *queryString = [pairs componentsJoinedByString:@"&"];

	return queryString;
}

@end
