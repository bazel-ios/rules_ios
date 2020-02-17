//
// NSMutableArray+MLNull.m
// MLCommons
//
// Created by Ezequiel Perez Dittler on 03/01/2018.
// Copyright © 2018 MercadoLibre. All rights reserved.
//

#import "NSMutableArray+MLNull.h"

@implementation NSMutableArray (MLNull)

- (void)ml_addObject:(nullable id)anObject
{
	if (anObject) {
		[self addObject:anObject];
	}
}

@end
