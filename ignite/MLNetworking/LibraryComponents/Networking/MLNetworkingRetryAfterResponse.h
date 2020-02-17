//
// MLNetworkingRetryAfterResponse.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 8/29/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNetworkingOperationResponse;

/**
 * Response handler to cache error responses using the 'Retry-After' header.
 */
@interface MLNetworkingRetryAfterResponse : NSObject

@property (nonatomic, strong, readonly) MLNetworkingOperationResponse *response;
@property (nonatomic, strong, readonly) NSDate *expireTime;
@property (nonatomic, assign, readonly) NSUInteger byteCount;

- (instancetype)initWithResponse:(MLNetworkingOperationResponse *)response retryAfterSeconds:(NSTimeInterval)seconds;

- (BOOL)isExpired;

- (NSComparisonResult)compareByExpireTime:(MLNetworkingRetryAfterResponse *)other;

@end

NS_ASSUME_NONNULL_END
