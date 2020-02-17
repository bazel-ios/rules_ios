//
// NSString+MLNetworkingURLEnconde.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/22/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "NSString+MLNetworkingURLEncode.h"

@implementation NSString (MLNetworkingURLEncode)

- (NSString *)mlNetworking_URLEncodedString
{
	NSMutableCharacterSet *workingSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
	[workingSet addCharactersInString:@"_.-~"];
	return [self stringByAddingPercentEncodingWithAllowedCharacters:workingSet];
}

@end
