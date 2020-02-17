//
// MLRestClientAuthenticationConnection.m
// MLNetworking
//
// Created by Nicolas Andres Suarez on 27/4/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLRestClientAuthenticationConnection.h"
#import "MLNetworkingConfigurationDataCustomURLRequest.h"
#import "MLNetworkingOperation.h"
#import "MLNetworkingOperationManager.h"

@interface MLRestClientAuthenticationConnection ()

@property (nonatomic, weak) MLNetworkingOperation *operation;

@end

@implementation MLRestClientAuthenticationConnection

- (void)makeRequestWithURLRequest:(NSURLRequest *)request
                  completionBlock:(void (^)(NSData *responseData))completionBlock
                     failureBlock:(void (^)(NSError *error))failureBlock
{
	MLNetworkingConfigurationDataCustomURLRequest *configuration = [[MLNetworkingConfigurationDataCustomURLRequest alloc] init];
	configuration.customURLRequest = request;

	MLNetworkingOperation *operation = [[MLNetworkingOperation alloc] initWithNetworkingConfig:configuration];

	if (completionBlock) {
		operation.successBlock = ^(MLNetworkingOperation *operation, MLNetworkingOperationResponse *responseObject) {
			completionBlock(responseObject.responseData);
		};
	}

	if (failureBlock) {
		operation.canceledBlock = ^(MLNetworkingOperation *operation, MLNetworkingOperationError *error) {
			failureBlock(error);
		};

		operation.failureBlock = ^(MLNetworkingOperation *operation, MLNetworkingOperationError *error) {
			failureBlock(error);
		};
	}

	self.operation = operation;

	[[MLNetworkingOperationManager sharedInstance] addOperation:operation];
}

- (void)invalidate
{
	[self.operation cancel];
	self.operation = nil;
}

@end
