//
// NSMutableDictionary.m
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 11/25/16.
//
//

#import "NSMutableDictionary+Null.h"

@implementation NSMutableDictionary (Null)

- (void)ml_setObject:(id)value forKey:(id <NSCopying>)key
{
	if (value && key) {
		[self setObject:value forKey:key];
	}
}

- (void)ml_setObject:(id)value forKey:(id <NSCopying>)key default:(id)defaultValue
{
	if (!value) {
		value = defaultValue;
	}
	[self ml_setObject:value forKey:key];
}
@end
