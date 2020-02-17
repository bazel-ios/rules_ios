//
// MLGateKeeperUserDefaults.m
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 1/30/17.
//
//

#import "MLCGateKeeperUserDefaults.h"

static NSString *const kGateKeeperIdentifier = @"com.mercadolibre.gatekeeper";

@implementation MLCGateKeeperUserDefaults

+ (instancetype)instance
{
	return [[self alloc] init];
}

- (instancetype)init
{
	return [self initWithIdentifier:kGateKeeperIdentifier];
}

@end
