//
// NSString+JSON.m
// MLCommons
//
// Created by William Mora on 13/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (id)ml_JSONValue
{
	return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

@end
