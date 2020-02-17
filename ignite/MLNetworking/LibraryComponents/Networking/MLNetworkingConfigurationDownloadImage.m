//
// MLNetworkingConfigurationDownloadImage.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/5/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingConfigurationDownloadImage.h"

@implementation MLNetworkingConfigurationDownloadImage

- (id)init
{
	if (self = [super init]) {
		self.requestType = MLNetworkingRequestTypeDownload;
	}
	return self;
}

- (NSMutableURLRequest *)createRequestWithtError:(NSError *__autoreleasing *)outError
{
	NSError *error = nil;
	NSMutableURLRequest *request = [super createRequestWithtError:&error];

	if (request && !error) {
		request.allHTTPHeaderFields = @{@"Connection" : @"keep-alive"};
	} else if (error && outError) {
		*outError = error;
	}

	return request;
}

@end
