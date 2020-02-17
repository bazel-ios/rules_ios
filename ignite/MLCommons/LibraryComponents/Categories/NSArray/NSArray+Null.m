//
// NSArray.m
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 2/9/17.
//
//

#import "NSArray+Null.h"
#import "NSDictionary+Null.h"

@implementation NSArray (Null)

- (nonnull NSArray *)ml_arrayByRemovingNullValues
{
	NSMutableArray *newArray = [NSMutableArray array];

	for (id value in self) {
		if ([value isKindOfClass:[NSArray class]]) {
			NSArray *recursiveArray = [((NSArray *)value) ml_arrayByRemovingNullValues];
			[newArray addObject:recursiveArray];
		} else if ([value isKindOfClass:[NSDictionary class]]) {
			NSDictionary *recursiveDict = [((NSDictionary *)value) ml_dictionaryByRemovingNullValues];
			[newArray addObject:recursiveDict];
		} else if (value != [NSNull null]) {
			[newArray addObject:value];
		}
	}

	return [newArray copy];
}

@end
