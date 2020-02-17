//
// MLNetworkingOperationManager.h
// MLNetworking
//
// Created by Fabian Celdeiro on 9/22/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingOperation.h"
#import "MLNetworkingConfiguration.h"

@class MLNetworkingOperation;
@class MLNetworkingURLRequestSerializer;

@interface MLNetworkingOperationManager : NSObject

/*!
 *  Singleton instance
 *
 *  @return Instance
 */
+ (MLNetworkingOperationManager *)sharedInstance;

/*!
 *  Adds a networking operation and starts the execution
 *
 *  @param operation an MLNetworkingOperation
 */
- (void)addOperation:(MLNetworkingOperation *)operation;

/*!
 *  Returns all running operations
 *
 *  @return Array of operations
 */
- (NSArray *)allOperations;

/*!
 *  Sets how many operations con run concurrently
 *
 *  @param maxConcurrentOperations Number of concurrent operations
 */
- (void)setMaxConcurrentOperations:(NSInteger)maxConcurrentOperations;

/*!
 *  Cancels all operations that have a dependency with certain class
 *
 *  @param dependencyClass Class
 */
- (void)cancelOperationsWithDependency:(Class)dependencyClass;

/*!
 *  Generic headers to use on all requests
 */
- (void)setGenericHeaders:(NSDictionary *)genericHeaders;

@end
