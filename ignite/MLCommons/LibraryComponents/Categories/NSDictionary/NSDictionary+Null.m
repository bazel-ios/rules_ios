//
// NSDictionary+Null.m
// MLCommons
//
// Created by William Mora on 13/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "NSDictionary+Null.h"
#import "NSMutableDictionary+Null.h"
#import "NSArray+Null.h"
#import "NSString+ML.h"

@implementation NSDictionary (Null)

- (_Nullable id)ml_objectForKey:(id)key
{
	id object = [self objectForKey:key];

	return [self isNullOrEmpty:object] ? nil : object;
}

- (BOOL)isNullOrEmpty:(id)object
{
	if (object == nil || [object isEqual:[NSNull null]]) {
		return YES;
	}

	if ([object isKindOfClass:[NSString class]]) {
		if ([object isEqualToString:@""]) {
			return YES;
		}
	}

	return NO;
}

- (nonnull NSDictionary *)ml_dictionaryByRemovingNullValues
{
	NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];

	for (NSString *key in self.allKeys) {
		if ([[self ml_objectForKey:key] isKindOfClass:[NSDictionary class]]) {
			NSDictionary *recursiveDict = [((NSDictionary *)[self ml_objectForKey:key]) ml_dictionaryByRemovingNullValues];
			[newDictionary ml_setObject:recursiveDict forKey:key];
		} else if ([[self ml_objectForKey:key] isKindOfClass:[NSArray class]]) {
			NSArray *recursiveArray = [((NSArray *)[self ml_objectForKey:key]) ml_arrayByRemovingNullValues];
			[newDictionary ml_setObject:recursiveArray forKey:key];
		} else {
			[newDictionary ml_setObject:[self ml_objectForKey:key] forKey:key];
		}
	}

	return [newDictionary copy];
}

- (nullable NSDictionary *)ml_dictionaryForKey:(nonnull id)key
{
	id value = [self ml_objectForKey:key];
	if (value != nil && [value isKindOfClass:[NSDictionary class]]) {
		return value;
	}
	return nil;
}

- (nullable NSArray *)ml_arrayForKey:(nonnull id)key
{
	id value = [self ml_objectForKey:key];
	if (value != nil && [value isKindOfClass:[NSArray class]]) {
		return value;
	}
	return nil;
}

- (nullable NSURL *)ml_URLForKey:(nonnull id)key
{
	id value = [self ml_objectForKey:key];
	if (value != nil && [value isKindOfClass:NSString.class]) {
		return [NSURL URLWithString:value];
	}
	return nil;
}

- (nullable NSString *)ml_stringForKey:(nonnull id)key
{
	id value = [self ml_objectForKey:key];
	if (value != nil && [value isKindOfClass:[NSString class]] && [value ml_isNotTrimmedEmpty]) {
		return value;
	}
	if (value != nil && [value isKindOfClass:[NSNumber class]]) {
		return [value stringValue];
	}
	return nil;
}

- (nullable NSNumber *)ml_numberForKey:(nonnull id)key
{
	id value = [self ml_objectForKey:key];
	if (value != nil && [value isKindOfClass:[NSNumber class]]) {
		return value;
	}
	if (value != nil && [value isKindOfClass:[NSString class]] && [value ml_isNotTrimmedEmpty]) {
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		f.numberStyle = NSNumberFormatterDecimalStyle;
		return [f numberFromString:value];
	}
	return nil;
}

- (BOOL)ml_boolForKey:(id)key
{
	return [self ml_boolForKey:key defaultValue:NO];
}

- (BOOL)ml_boolForKey:(nonnull id)key defaultValue:(BOOL)defaultValue
{
	id value = [self ml_objectForKey:key];
	if (value != nil && [value isKindOfClass:NSNumber.class]) {
		return [value boolValue];
	}
	if (value != nil && [value isKindOfClass:NSString.class] && [value ml_isNotTrimmedEmpty]) {
		return [value boolValue];
	}
	return defaultValue;
}

@end
