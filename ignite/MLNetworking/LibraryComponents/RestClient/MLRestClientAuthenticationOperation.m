//
// MLRestClientAuthenticationOperation.m
// MLNetworking
//
// Created by Fabian Celdeiro on 1/7/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLRestClientAuthenticationOperation.h"
#import "MLRestClientAuthenticationOperation_Protected.h"

@implementation MLRestClientAuthenticationOperation

- (instancetype)initWithAppId:(NSString *)appId authenticationMode:(MLRestClientAuthenticationMode)authMode
{
	NSAssert(appId.length > 0, @"AppId can not be nil or empty.");

	self = [super init];
	if (self) {
		_appId = [appId copy];
		_authMode = authMode;
	}
	return self;
}

- (BOOL)isAuthenticationError:(NSError *)error
{
	return error.code == 401;
}

- (void)startOperation
{
	if ([self isExecuting]) {
		NSAssert(![self isExecuting], @"Trying to start an already executing operation");
		return;
	}

	if ([self isCancelled]) {
		[self finishOperation];
		return;
	}

	// If the operation is not canceled, begin executing the task.
	[self willChangeValueForKey:@"isExecuting"];
	self.operationExecuting = YES;

	BOOL shouldCancel = [self isCancelled];

	for (NSOperation *operation in self.dependencies) {
		shouldCancel |= [operation isCancelled];
	}
	if (shouldCancel) {
		[self cancelOperation];
	} else {
		[self startOauthProcess];
	}

	[self didChangeValueForKey:@"isExecuting"];
}

- (void)startOauthProcess
{
	NSAssert(NO, @"You must override 'startOauthProcess' in a subclass");
}

- (void)cancelOperation
{
	NSAssert(![self isCancelled], @"Trying to cancel a cancelled operation");

	if (![self isCancelled]) {
		[super cancel];

		if ([self isExecuting]) {
			[self finishOperation];
		}
	}
}

- (void)finishOperation
{
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];

	self.operationExecuting = NO;
	self.operationFinished = YES;

	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NSOperation

- (BOOL)isExecuting
{
	return self.operationExecuting;
}

- (BOOL)isFinished
{
	return self.operationFinished;
}

- (BOOL)isAsynchronous
{
	return YES;
}

- (void)start
{
	[self startOperation];
}

- (void)cancel
{
	[self cancelOperation];
}

#pragma mark - MLNetworkingOperationAuthenticationProtocol

- (NSDictionary *)mlNet_extraQueryParams
{
	if (self.accessToken.length > 0) {
		return @{@"access_token" : self.accessToken};
	} else {
		return nil;
	}
}

@end
