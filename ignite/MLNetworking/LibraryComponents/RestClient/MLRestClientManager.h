//
// MLRestClientManager.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/18/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLRestClientAuthenticationOperation.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNetworkingOperation;
@class MLSession;

@interface MLRestClientManager : NSObject

/**
 *  @brief Returns the shared instance of MLRestClientManager.
 */
+ (MLRestClientManager *)sharedInstance;

/**
 *  @brief Initialize the singleton instance
 *
 *  @param appId     Application identifier
 *  @param appSecret Application secret key
 */
+ (void)initializeWithAppId:(NSString *)appId andAppSecret:(NSString *)appSecret;

/**
 *  @brief Initialize the singleton instance
 *
 *  @param appId     Application identifier
 *  @param appSecret Application secret key
 *  @param keychainId Application keychain id
 */
+ (void)initializeWithAppId:(NSString *)appId andAppSecret:(NSString *)appSecret keychainId:(NSString *)keychainId;

/**
 *  @brief Adds an MLNetworkingOperation to operation queue.
 *
 *  @param operation Operation to queue
 */
- (void)addOperation:(MLNetworkingOperation *)operation;

/**
 *  @brief Adds an MLNetworkingOperation to operation queue, and generates an authentication operation
 *  based on the authentication mode.
 *
 *  @param operation Operation to queue
 *  @param mode      Authentication mode
 */
- (void)addOperation:(MLNetworkingOperation *)operation withAuthenticationMode:(MLRestClientAuthenticationMode)mode;

/**
 *  @brief Closes current user session
 */
- (void)logoutUser;

/**
 *  @brief Creates an authentication operation which require user credentials.
 *  If no user session, the login UI will be showed.
 */
- (void)showLoginUser;

/*!
 *  @brief  Checks if the user has previously authenticated
 *
 *  @return YES if user is authenticated, NO otherwise
 */
- (BOOL)isUserAuthenticated;

/**
 *  @brief Returns the userId if the user is authenticated
 *
 *  @return userId
 */
- (nullable NSString *)authenticatedUserId;

/**
 *  Return the current session if exists.
 *
 *  @return Instance of MLSesssion or nil.
 */
- (nullable MLSession *)session;

/**
 *  @brief  Sets headers which will be set on all requests.
 *
 *  @param commonHeaders Headers to be setted.
 */
- (void)setCommonHeaders:(NSDictionary *)commonHeaders;

@end

NS_ASSUME_NONNULL_END
