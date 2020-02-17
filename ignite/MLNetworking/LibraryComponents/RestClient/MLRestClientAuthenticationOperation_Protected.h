//
// MLRestClientAuthenticationOperation_Protected.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 18/5/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLRestClientAuthenticationOperation.h"

@interface MLRestClientAuthenticationOperation ()

/**
 *  Flag to know if the operation finished
 */
@property (nonatomic, assign) BOOL operationFinished;

/**
 *  Flag to know if the operation is running
 */
@property (nonatomic, assign) BOOL operationExecuting;

/**
 *  Access token obtained at the end of the authentication process
 */
@property (nonatomic, copy) NSString *accessToken;

/**
 *  If the operation and his dependencies are not canceled, call startOauthProcess.
 *
 */
- (void)startOperation;

/**
 *  Sets operation state as completed
 */
- (void)finishOperation;

/**
 *  Cancels the execution of the operation
 */
- (void)cancelOperation;

/**
 *  Makes the authentication tasks
 */
- (void)startOauthProcess;

@end
