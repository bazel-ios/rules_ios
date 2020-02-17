//
// MLNetworkingConfiguration.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/3/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Request type
 */
typedef NS_ENUM (NSUInteger, MLNetworkingRequestType) {
	MLNetworkingRequestTypeData     = 0,
	MLNetworkingRequestTypeDownload = 1,
	MLNetworkingRequestTypeUpload   = 2,
};

/**
 *  Http request methods
 */
typedef NS_ENUM (NSUInteger, MLNetworkingHTTPMethod) {
	MLNetworkingHTTPMethodGET,
	MLNetworkingHTTPMethodPOST,
	MLNetworkingHTTPMethodPUT,
	MLNetworkingHTTPMethodHEAD,
	MLNetworkingHTTPMethodDELETE,
	MLNetworkingHTTPMethodPATCH
};

/*
 *  Session task types
 */
typedef NS_ENUM (NSUInteger, MLNetworkingSessionType) {
	MLNetworkingSessionTypeForeground = 0,
	MLNetworkingSessionTypeBackground = 1
};

@interface MLNetworkingConfiguration : NSObject <NSCopying>

/**
 *  Request type to be created.
 */
@property (nonatomic, assign) MLNetworkingRequestType requestType;

/**
 *  Type of session that the request will be used.
 *  Default value is MLNetworkingSessionTypeForeground
 */
@property (nonatomic, assign) MLNetworkingSessionType sessionType;

/**
 *  Http method to be used in the request.
 */
@property (nonatomic, assign) MLNetworkingHTTPMethod httpMethod;

/**
 *  Base URL for the request
 *  Example: https://mobile.mercadolibre.com.ar:8081/
 */
@property (nonatomic, copy, nullable) NSString *baseURLString;

/**
 *  URL path.
 *  Example: /sites/MLA
 */
@property (nonatomic, copy, nullable) NSString *path;

/**
 *  Query params.
 *  Example: @{@"q":@"ipod"}
 */
@property (nonatomic, strong, nullable) NSDictionary *queryParams;

/**
 *  Data that will be sent as request body.
 */
@property (nonatomic, strong, nullable) NSData *body;

/**
 *  Additional headers to be sent in the request.
 */
@property (nonatomic, strong, nullable) NSDictionary *aditionalHeaders;

/**
 *  Data used to resume a download request.
 */
@property (nonatomic, strong, nullable) NSData *resumeData;

/*
 *  NSURL created in base of 'baseUrl', 'path' and 'queryParams'
 */
@property (nonatomic, copy, readonly, nullable) NSURL *url;

/*
 *  URL created in base of 'baseUrl', 'path' and 'queryParams'
 */
@property (nonatomic, copy, readonly, nullable) NSString *urlString;

/**
 *  Return the http method in string format
 */
@property (nonatomic, readonly, copy) NSString *methodString;

/*
 *  Data to upload
 */
@property (nonatomic, strong, nullable) NSData *uploadData;

/*
 *  File to upload
 */
@property (nonatomic, strong, nullable) NSURL *uploadURL;

/*
 * Setup the cache policy
 */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/**
 *  Value for User-Agent header.
 *  Default value has the next format: {{BundleDisplayName}}-{{System Name}}/{{App short version}} ({{Device model}}; {{System Name}} {{Version}})
 *  Example: MercadoLibre-iOS/1.0.0 (iPhone; iOS 8.3)
 */
@property (nonatomic, copy) NSString *userAgent;

/**
 *  Http request timeout. Is measured in seconds.
 *  Default value is 60.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  Size of the body. It corresponds to the value of the 'Content-Length' header.
 */
@property (nonatomic, readonly) uint64_t contentLength;

/**
 *  Creates an `NSMutableURLRequest` object in base of configuration parameters.
 *
 *  @param error The error that occurred while constructing the request.
 *
 *  @return An `NSMutableURLRequest` object
 */
- (nullable NSMutableURLRequest *)createRequestWithtError:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
