//
// MLRestClientAuthenticationOperation.h
// MLNetworking
//
// Created by Fabian Celdeiro on 1/7/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingOperationSessionProtocol.h"

/**
 *  Authentication modes
 */
typedef NS_ENUM (NSUInteger, MLRestClientAuthenticationMode) {
	/**
	 *  Not trigger authentication process
	 */
	MLRestClientAuthenticationModeNone      = 0,

	/**
	 *  If hasn't access token, begins login process
	 */
	MLRestClientAuthenticationUserMustLogin = 1,

	/**
	 *  If hasn't access token, the operation is cancelled.
	 */
	MLRestClientAuthenticationUserNoLogin   = 2,

	/**
	 *  The operation is executed even without access token
	 */
	MLRestClientAuthenticationUserOptional  = 3,

	/*
	 *  Try to get application credentials
	 */
	MLRestClientAuthenticationAppAuth       = 4
};

@interface MLRestClientAuthenticationOperation : NSOperation <MLNetworkingOperationAuthenticationProtocol>

/**
 *  Identifies the authentication mode.
 */
@property (nonatomic, readonly) MLRestClientAuthenticationMode authMode;

/**
 *  Application identifier, used in the authentication process
 */
@property (nonatomic, copy) NSString *appId;

/**
 *  Initialize the instance
 *
 *  @param appId Application identifier
 *
 *  @return Instance of MLRestClientAuthenticationOperation initialized
 */
- (instancetype)initWithAppId:(NSString *)appId authenticationMode:(MLRestClientAuthenticationMode)authMode;

/**
 *  Identifies if the error is of authentication
 *
 *  @param error NSError instance to be evaluated
 *
 *  @return YES if is an authentication error, but NO
 */
- (BOOL)isAuthenticationError:(NSError *)error;

@end
