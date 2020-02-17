//
// MLNetworkingConfigurationDataCustomURLRequest.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/18/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingConfigurationDataCustomURLRequest.h"

@implementation MLNetworkingConfigurationDataCustomURLRequest

- (instancetype)init
{
	if (self = [super init]) {
		self.requestType = MLNetworkingRequestTypeData;
	}
	return self;
}

- (NSMutableURLRequest *)createRequestWithtError:(NSError *__autoreleasing *)error
{
	NSMutableURLRequest *mutableRequest;

	if (self.customURLRequest) {
		if (self.userAgent) {
			mutableRequest = [self.customURLRequest mutableCopy];
			[mutableRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
			self.customURLRequest = mutableRequest;
		}
	} else {
		mutableRequest = [super createRequestWithtError:error];
	}
	return mutableRequest;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	MLNetworkingConfigurationDataCustomURLRequest *myCopy = [super copyWithZone:zone];
	myCopy.customURLRequest = self.customURLRequest;
	return myCopy;
}

@end
