//
// MLNetworkingRetryAfterHandler.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 8/25/17.
//
//

#import <Foundation/Foundation.h>
#import "MLNetworkingOperationResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, MLRetryAfterStatusCode) {
	MLRetryAfterStatusCodeTooManyRequest     = 429,
	MLRetryAfterStatusCodeServiceUnavailable = 503
};

OBJC_EXTERN NSString *const MLRetryAfterHeader;

/**
 *  Class that handles everything related to the 'Retry-After' header,
 *  it saves an in-memory cache using the request URL params as key to return a response.
 */
@interface MLNetworkingRetryAfterHandler : NSObject

/**
 *  Cache limit. Default value is 0.
 */
@property (nonatomic, assign) NSUInteger cacheSizeLimit;

/**
 *  Current cache size
 */
@property (nonatomic, assign, readonly) NSUInteger cacheSize;

/**
 *  Returns the shared instance of MLNetworkingRetryAfterHandler
 */
+ (MLNetworkingRetryAfterHandler *)sharedInstance;

/**
 *  Check if the response should be add into the cache responses
 *
 *  @param response Response to be avaluated
 *  @param request Request to be avaluated
 */
- (BOOL)shouldSaveResponse:(MLNetworkingOperationResponse *)response forRequest:(NSURLRequest *)request;

/**
 *  Add a response objecto into the cache only if shouldSaveResponse return YES
 *
 *  @param response Response to be add into cache
 *  @param request Request related to the response
 */
- (void)saveResponse:(MLNetworkingOperationResponse *)response forRequest:(NSURLRequest *)request;

/**
 *   Returns a response if exists into the cache.
 *
 *   @param request Request used to search the response based on this URL
 */
- (nullable MLNetworkingOperationResponse *)cachedResponseForRequest:(NSURLRequest *)request;

/**
 * Remove all elements from cache
 */
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
