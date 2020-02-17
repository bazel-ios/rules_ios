//
// MLNetworkingRetryAfterResponse.m
// Pods
//
// Created by Nicolas Andres Suarez on 8/29/17.
//
//

#import "MLNetworkingRetryAfterResponse.h"
#import "MLNetworkingOperationResponse.h"

@implementation MLNetworkingRetryAfterResponse

- (instancetype)initWithResponse:(MLNetworkingOperationResponse *)response retryAfterSeconds:(NSTimeInterval)seconds
{
	self = [super init];
	if (self) {
		_expireTime = [[NSDate alloc] initWithTimeIntervalSinceNow:seconds];
		_response = response;
		_byteCount = response.responseData.length;
	}
	return self;
}

- (BOOL)isExpired
{
	return [self.expireTime compare:[NSDate date]] != NSOrderedDescending;
}

- (NSComparisonResult)compareByExpireTime:(MLNetworkingRetryAfterResponse *)other
{
	return [self.expireTime compare:other.expireTime];
}

@end
