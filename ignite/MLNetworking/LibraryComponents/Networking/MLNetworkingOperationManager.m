//
// MLNetworkingOperationManager.m
// MLNetworking
//
// Created by Fabian Celdeiro on 9/22/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingOperationManager.h"
#import "MLNetworkingOperation.h"
#import "MLNetworkingSessionManager.h"

#define kMLNetworkingOperationManangerDefaultMaxConcurrentOperations 5

@interface MLNetworkingOperationManager ()
@property (nonatomic, strong, readonly) dispatch_queue_t serialQueue;
@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;

@end

@implementation MLNetworkingOperationManager

+ (MLNetworkingOperationManager *)sharedInstance
{
	static MLNetworkingOperationManager *shared;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[MLNetworkingOperationManager alloc] init];
	});
	return shared;
}

- (id)init
{
	if (self = [super init]) {
		_operationQueue = [[NSOperationQueue alloc] init];
		[_operationQueue setMaxConcurrentOperationCount:kMLNetworkingOperationManangerDefaultMaxConcurrentOperations];
		_serialQueue = dispatch_queue_create("com.mercadolibre.networking.operationManager.serialQueue", 0);
	}

	return self;
}

- (void)setMaxConcurrentOperations:(NSInteger)maxConcurrentOperations
{
	dispatch_async(self.serialQueue, ^{
		[self.operationQueue setMaxConcurrentOperationCount:maxConcurrentOperations];
	});
}

- (void)addOperation:(MLNetworkingOperation *)operation
{
	dispatch_async(self.serialQueue, ^{
		NSAssert(![operation isExecuting], @"La operación no puede estar ejecutandose al encolarese");
		[self.operationQueue addOperation:operation];
	});
}

- (NSArray *)allOperations
{
	return self.operationQueue.operations;
}

- (void)cancelOperationsWithDependency:(Class)dependencyClass
{
	dispatch_async(self.serialQueue, ^{
		for (NSOperation *operation in self.operationQueue.operations) {
		    for (NSOperation *operationDependency in operation.dependencies) {
		        if ([operationDependency class] == dependencyClass) {
		            if (![operation isCancelled]) {
		                [operation cancel];
					}
				}
			}
		}
	});
}

- (void)setGenericHeaders:(NSDictionary *)genericHeaders
{
	[[MLNetworkingSessionManager sharedInstance] setGenericHeaders:genericHeaders];
}

@end
