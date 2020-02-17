//
// NSArray+MapReduceFilter.m
// MLCommons
//
// Created by amargalef on 24/02/15.
// Copyright (c) 2015 Mercadolibre. All rights reserved.
//

#import "NSArray+MapReduceFilter.h"

@implementation NSArray (MapReduceFilter)

- (void)ml_each:(MLEachBlock)block
{
	if (!block) {
		NSAssert(NO, @"NULL block not expected");
		return;
	}

	for (id value in self) {
		block(value);
	}
}

- (NSArray *)ml_map:(MLMapBlock)block
{
	if (!block) {
		NSAssert(NO, @"NULL block not expected");
		return nil;
	}

	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
	for (id value in self) {
		id mapValue = block(value);
		if (mapValue) {
			[ret addObject:mapValue];
		}
	}
	return [NSArray arrayWithArray:ret];
}

- (id)ml_reduceWithValue:(id)initValue andBlock:(MLReduceBlock)block
{
	if (!block) {
		NSAssert(NO, @"NULL block not expected");
		return nil;
	}

	id ret = initValue;
	for (id value in self) {
		ret = block(ret, value);
	}
	return ret;
}

- (NSArray *)ml_filter:(MLFilterBlock)block
{
	if (!block) {
		NSAssert(NO, @"NULL block not expected");
		return nil;
	}

	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
	for (id value in self) {
		if (block(value)) {
			[ret addObject:value];
		}
	}
	return [NSArray arrayWithArray:ret];
}

- (id)ml_find:(MLFilterBlock)block
{
	if (!block) {
		NSAssert(NO, @"NULL block not expected");
		return nil;
	}

	for (id value in self) {
		if (block(value)) {
			return value;
		}
	}

	return nil;
}

- (NSUInteger)ml_indexOf:(MLBooleanBlock)block
{
	if (!block) {
		NSAssert(NO, @"NULL block not expected");
		return NSNotFound;
	}

	for (NSUInteger index = 0; index < self.count; index++) {
		if (block(self[index])) {
			return index;
		}
	}

	return NSNotFound;
}

- (NSArray <NSNumber *> *)ml_indexesOf:(MLBooleanBlock)block
{
	if (!block) {
		NSAssert(NO, @"NULL block not expected");
		return [NSArray array];
	}

	NSMutableArray *indexes = [NSMutableArray array];

	for (NSUInteger index = 0; index < self.count; index++) {
		if (block(self[index])) {
			[indexes addObject:@(index)];
		}
	}

	return [NSArray arrayWithArray:indexes];
}

@end
