//
// MLRestClientService.h
// MercadoLibre
//
// Created by Fabian Celdeiro on 12/2/14.
// Copyright (c) 2014 MercadoLibre - Mobile Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLRestClientAuthenticationOperation.h"
#import "MLNetworkingConfiguration.h"
#import "MLNetworkingOperationError.h"
#import "MLNetworkingOperationResponse.h"
#import "MLNetworkingOperationDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MLServiceParseCompletionBlock)(id objectParsed);

@interface MLRestClientService : NSOperation <MLNetworkingOperationDelegate>

/**
 *  Determines which type of authentication to use.
 *  Default is MLRestClientAuthenticationModeNone.
 */
@property (nonatomic) MLRestClientAuthenticationMode authenticationMode;

/**
 *  Configuration that will be used to run the request.
 */
@property (nonatomic, strong) MLNetworkingConfiguration *config;

/**
 *  Cancels the execution of the networking operation if it's running.
 */
- (void)invalidate;

/**
 *  Method called when the networking operation finish succesfully.
 *  Is an abstract method, sublcass must override it.
 *
 *  @param response Response object with raw data.
 *  @param completionBlock Code block must be called after response data is parsed.
 *
 */
- (void)parseWithMLResponse:(MLNetworkingOperationResponse *)response withCompletionBlock:(MLServiceParseCompletionBlock)completionBlock;

/**
 *  Method called when after the response data is parsed.
 *  Is an abstract method, sublcass must override it.
 *
 *  @param object Parsed response data
 */
- (void)onServiceSuccessParseFinished:(id)object;

/**
 *  Method called when the networking operation finish with error.
 *
 *  @param error Error information
 */
- (void)onServiceFinishWithError:(MLNetworkingOperationError *)error;

/**
 *  Method called when the networking operation is canceled.
 *
 *  @param error Error information
 */
- (void)onServiceCanceled:(MLNetworkingOperationError *)error;

@end

NS_ASSUME_NONNULL_END
