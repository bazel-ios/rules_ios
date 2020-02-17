//
// MLCommonBundle.m
// MLCommons
//
// Created by ITAY BRENNER WERTHEIN on 25/6/18.
//

#import "MLCommonBundle.h"

@implementation MLCommonBundle

+ (NSBundle *)bundle
{
	return [NSBundle bundleForClass:[self class]];
}

@end
