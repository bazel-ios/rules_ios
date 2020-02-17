//
// MLRestClientServiceManager.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/20/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLRestClientServiceManager.h"
#import "MLRestClientService.h"

@interface MLRestClientServiceManager ()

@property (nonatomic, strong) NSOperationQueue *serviceQueue;

@end

@implementation MLRestClientServiceManager

+ (MLRestClientServiceManager *)sharedInstance
{
	static MLRestClientServiceManager *shared;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[MLRestClientServiceManager alloc] init];
	});
	return shared;
}

- (instancetype)init
{
	if (self = [super init]) {
		self.serviceQueue = [[NSOperationQueue alloc] init];
	}

	return self;
}

- (void)enqueueService:(MLRestClientService *)service
{
	[self.serviceQueue addOperation:service];
}

@end
