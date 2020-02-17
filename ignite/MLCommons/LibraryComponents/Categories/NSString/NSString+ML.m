//
// NSString+ML.m
// MLCommons
//
// Created by matias servetto on 10/12/17.
// Copyright © 2017 MercadoLibre. All rights reserved.
//

#import "NSString+ML.h"

@implementation NSString (ML)

- (BOOL)ml_isEqualToStringIgnoringCase:(NSString *)aString
{
	return [self.lowercaseString isEqualToString:aString.lowercaseString];
}

- (BOOL)ml_isTrimmedEmpty
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0;
}

- (BOOL)ml_isNotTrimmedEmpty
{
	return [self ml_isTrimmedEmpty] == NO;
}

@end
