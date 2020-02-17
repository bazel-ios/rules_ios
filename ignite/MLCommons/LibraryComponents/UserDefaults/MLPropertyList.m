//
// MLPropertyList.m
// MLCommons
//
// Created by William Mora on 11/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLPropertyList.h"

@implementation MLPropertyList

+ (BOOL)isPropertyListValue:(id)value
{
	BOOL isPropertyListValue = NO;
	for (Class cls in @[[NSData class], [NSString class], [NSNumber class], [NSDate class], [NSArray class], [NSDictionary class]]) {
		if ([value isKindOfClass:cls]) {
			isPropertyListValue = YES;
		}
	}
	return isPropertyListValue;
}

+ (BOOL)isIterablePropertyListValue:(id)value
{
	return [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]];
}

+ (BOOL)valueContentIsPropertyList:(id)value
{
	if (![MLPropertyList isIterablePropertyListValue:value]) {
		return [MLPropertyList isPropertyListValue:value];
	}

	if ([value isKindOfClass:[NSArray class]]) {
		for (id object in value) {
			if (![MLPropertyList valueContentIsPropertyList:object]) {
				return NO;
			}
		}
	}

	if ([value isKindOfClass:[NSDictionary class]]) {
		for (NSString *key in value) {
			if (![MLPropertyList valueContentIsPropertyList:[value objectForKey:key]]) {
				return NO;
			}
		}
	}

	return YES;
}

@end
