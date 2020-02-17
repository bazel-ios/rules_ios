//
// NSObject+MLAs.m
// MLCommons
//
// Created by Konstantin Portnov on 28/03/17.
// Copyright (c) 2017 MercadoLibre. All rights reserved.
//

#import "NSString+JSON.h"
#import "NSObject+MLAs.h"

@implementation NSObject (MLAs)

- (id _Nullable)ml_asKindOf:(_Nonnull Class)aClass
{
	if ([self isKindOfClass:aClass]) {
		return self;
	}

	return nil;
}

- (NSArray *_Nullable)ml_asArray
{
	return [self ml_asKindOf:NSArray.class];
}

- (NSDictionary *_Nullable)ml_asDictionary
{
	return [self ml_asKindOf:NSDictionary.class];
}

@end
