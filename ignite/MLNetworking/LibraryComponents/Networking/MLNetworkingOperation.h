//
// MLNetworkingOperation.h
// MLNetworking
//
// Created by Fabian Celdeiro on 9/14/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingOperationDelegate.h"
#import "MLNetworkingOperationSessionProtocol.h"
#import "MLNetworkingOperationResponse.h"
#import "MLNetworkingOperationError.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNetworkingConfiguration;
@class MLNetworkingOperation;

/**
 *  Operation priorities
 */
typedef NS_ENUM (NSInteger, MLNetworkingOperationPriority) {
	MLNetworkingOperationPriorityVeryLow  = NSOperationQueuePriorityVeryLow,
	MLNetworkingOperationPriorityLow      = NSOperationQueuePriorityLow,
	MLNetworkingOperationPriorityNormal   = NSOperationQueuePriorityNormal,
	MLNetworkingOperationPriorityHigh     = NSOperationQueuePriorityHigh,
	MLNetworkingOperationPriorityVeryHigh = NSOperationQueuePriorityVeryHigh
};

/*
 *  This class will handle a single network operation. It will handle all the responsability of a request and a response.
 *  A network operation will work as a "single operation". This means that it can not be reused.
 *  This operation can be copied.
 */
@interface MLNetworkingOperation : NSOperation <NSCopying>

/**
 *  Operation identifier
 */
@property (nonatomic, copy) NSString *operationIdentifier;

/**
 *  Priority for queue execution
 */
@property (nonatomic) MLNetworkingOperationPriority priority;

/**
 *  Object responsible to create the request with all params
 */
@property (nonatomic, copy, readonly) MLNetworkingConfiguration *configuration;

/**
 *  Refenrence to error obtained.
 */
@property (nonatomic, strong, nullable) MLNetworkingOperationError *error;

/**
 *  Object that will be asked extra query params, for atuthentication.
 */
@property (nonatomic, weak, nullable) id <MLNetworkingOperationAuthenticationProtocol> authenticationDataSource;

/**
 *  Delegate who receive progress and completition callbacks.
 */
@property (atomic, weak, nullable) id <MLNetworkingOperationDelegate> delegate;

/**
 *  Block for success completion.
 *  It invoked when there is no delegate set
 */
@property (atomic, copy, nullable) void (^successBlock)(MLNetworkingOperation *operation, MLNetworkingOperationResponse *responseObject);

/**
 *  Block for error completion. It invoked when there is no delegate set.
 */
@property (atomic, copy, nullable) void (^failureBlock)(MLNetworkingOperation *operation, MLNetworkingOperationError *error);

/**
 *  Block for cancelation.
 *  It invoked when there is no delegate set.
 */
@property (atomic, copy, nullable) void (^canceledBlock)(MLNetworkingOperation *operation, MLNetworkingOperationError *error);

/**
 *  Block for invalidation.
 *  An operation is invalidated when it fails and you want to retry.
 *  It invoked when there is no delegate set.
 */
@property (atomic, copy, nullable) void (^invalidationBlock)(MLNetworkingOperation *operation, MLNetworkingOperation *newOperation);

/**
 *  Returns a new operation initialized with specified configuration
 *  This method is the primary designated initializer.
 *
 *  @param configuration  Object responsible to create the request with all params.
 *  @return A new operation
 */
- (instancetype)initWithNetworkingConfig:(MLNetworkingConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
