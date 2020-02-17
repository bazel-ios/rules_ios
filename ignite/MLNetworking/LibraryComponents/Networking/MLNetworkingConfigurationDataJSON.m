//
// MLConfigurationJSON.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/5/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingConfigurationDataJSON.h"

@implementation MLNetworkingConfigurationDataJSON

- (NSMutableURLRequest *)createRequestWithtError:(NSError *__autoreleasing *)outError
{
	NSError *error = nil;
	NSMutableURLRequest *request = [super createRequestWithtError:&error];

	if (request && !error && request.HTTPBody) {
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	}

	if (error && outError) {
		*outError = error;
	}

	return request;
}

- (void)setBodyDic:(NSDictionary *)bodyDic
{
	_bodyDic = bodyDic;
	self.body = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:nil];
}

@end
