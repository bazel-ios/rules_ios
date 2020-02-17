//
// MLNetworkingResponse.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/4/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingOperationResponse.h"
#import "MLNetworkingDefines.h"

@implementation MLNetworkingOperationResponse

- (instancetype)initWithURLResponse:(NSURLResponse *)urlResponse responseData:(NSData *)responseData
{
	self = [super init];
	if (self) {
		self.urlResponse = urlResponse;
		self.statusCode = [MLNetworkingDynamicCast(urlResponse, NSHTTPURLResponse) statusCode];
		self.headers = [MLNetworkingDynamicCast(urlResponse, NSHTTPURLResponse) allHeaderFields];
		self.responseData = responseData;
	}
	return self;
}

@end
