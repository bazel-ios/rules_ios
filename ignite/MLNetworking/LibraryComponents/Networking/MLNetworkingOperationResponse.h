//
// MLNetworkingResponse.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/4/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  NSURLResponse wrapper, that contain the NSData response.
 */
@interface MLNetworkingOperationResponse : NSObject

/*
 *  URLResponse
 */
@property (nonatomic, strong) NSURLResponse *urlResponse;

/*
 * Response data
 */
@property (nonatomic, strong, nullable) NSData *responseData;

/**
 *  Response's status code
 */
@property (nonatomic, assign) NSInteger statusCode;

/**
 *  Response's headers
 */
@property (nonatomic, strong, nullable) NSDictionary *headers;

/**
 *  URL from file with the response data.
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;

/**
 *  Returns a new response initialized with specified NSURLResponse and NSData response.
 *  This method is the primary designated initializer.
 *
 *  @param urlResponse Instance of NSURLResponse
 *  @param responseData Data obtain in the response
 *  @return An initialized response object
 */
- (instancetype)initWithURLResponse:(NSURLResponse *)urlResponse responseData:(nullable NSData *)responseData;

@end

NS_ASSUME_NONNULL_END
