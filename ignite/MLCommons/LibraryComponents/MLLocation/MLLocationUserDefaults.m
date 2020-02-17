//
// MLLocationUserDefaults.m
// MLCommons
//
// Created by Mauricio Minestrelli on 11/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLLocationUserDefaults.h"
NSString *const kLocationDefaultName = @"mllocation";
@implementation MLLocationUserDefaults

+ (MLLocationUserDefaults *)locationUserDefaults
{
	static MLLocationUserDefaults *_locationUserDefaults;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_locationUserDefaults = [[self alloc] initWithIdentifier:kLocationDefaultName];
	});
	return _locationUserDefaults;
}

@end
