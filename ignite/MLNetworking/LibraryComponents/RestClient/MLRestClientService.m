//
// MLRestClientService.m
// MercadoLibre
//
// Created by Fabian Celdeiro on 12/2/14.
// Copyright (c) 2014 MercadoLibre - Mobile Apps. All rights reserved.
//

#import "MLRestClientService.h"
#import "MLRestClientManager.h"
#import "MLNetworkingOperation.h"

@interface MLRestClientService ()

@property (nonatomic, strong) MLNetworkingOperation *operation;
@property (nonatomic) dispatch_queue_t serialQueue;

/**
 *  Variable utilizada para manejar el estado de la NSOperation
 */
@property (nonatomic, readwrite, assign) BOOL operationFinished;

/**
 *  Variable utilizada para manejar el estado de la NSOperation
 */
@property (nonatomic, readwrite, assign) BOOL operationExecuting;

@property (nonatomic, strong) MLNetworkingOperationResponse *response;
@property (nonatomic, strong) MLNetworkingOperationError *error;

/**
 *  Checks for dependencies failed or canceled.
 *
 *  @return YES if any dependency failed or canceled, but NO.
 */
- (BOOL)shouldCancel;

@end

@implementation MLRestClientService

- (id)init
{
	if (self = [super init]) {
		self.serialQueue = dispatch_queue_create("com.mercadolibre.restClient.serviceQueue", DISPATCH_QUEUE_SERIAL);
		self.authenticationMode = MLRestClientAuthenticationModeNone;
	}
	return self;
}

- (void)dealloc
{
	if (self.operation) {
		[self.operation cancel];
	}
}

- (BOOL)shouldCancel
{
	for (NSOperation *operation in self.dependencies) {
		if ([operation isCancelled]) {
			self.error = [[MLNetworkingOperationError alloc] initWithDomain:MLNetworkingOperationErrorDomain
			                                                           code:MLNetworkingOperationErrorCodeCanceledDependence
			                                                       userInfo:@{NSLocalizedDescriptionKey : @"Dependence canceled"}];
			return YES;
		} else if ([operation isKindOfClass:[MLRestClientService class]]) {
		    MLRestClientService *service = (MLRestClientService *)operation;
		    if (service.error) {
		        NSString *reason = [NSString stringWithFormat:@"Dependence MLRestClientService failed with error code: %ld", (long)service.error.code];
		        self.error = [[MLNetworkingOperationError alloc] initWithDomain:MLNetworkingOperationErrorDomain
		                                                                   code:MLNetworkingOperationErrorCodeFailureDependence
		                                                               userInfo:@{NSLocalizedFailureReasonErrorKey : reason}];
		        return YES;
			}
		} else if ([operation isKindOfClass:[MLNetworkingOperation class]]) {
		    MLNetworkingOperation *networkingOperation = (MLNetworkingOperation *)operation;
		    if (networkingOperation.error) {
		        NSString *reason = [NSString stringWithFormat:@"Dependence MLNetworkingOperation %@ failed with error code: %ld", networkingOperation.operationIdentifier, (long)networkingOperation.error.code];
		        self.error = [[MLNetworkingOperationError alloc] initWithDomain:MLNetworkingOperationErrorDomain
		                                                                   code:MLNetworkingOperationErrorCodeFailureDependence
		                                                               userInfo:@{NSLocalizedFailureReasonErrorKey : reason}];
		        return YES;
			}
		}
	}

	return NO;
}

- (void)startOperation
{
    NSAssert(self.config, @"The service must have a MLNetworkingConfiguration to start");

    if (!self.config) {
        [self finishOperation];
	} else {
        dispatch_async(self.serialQueue, ^{
			if (![self isCancelled]) {
			    self.operation = [[MLNetworkingOperation alloc] initWithNetworkingConfig:self.config];
			    self.operation.delegate = self;
			    [[MLRestClientManager sharedInstance] addOperation:self.operation
			                                withAuthenticationMode:self.authenticationMode];
			}
		});
	}
}

- (void)finishOperation
{
    self.operation = nil;

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    self.operationExecuting = NO;
    self.operationFinished = YES;

    // ME CANCELARON?
    if ([self isCancelled]) {
        dispatch_async(dispatch_get_main_queue(), ^{
			[self onServiceCanceled:self.error];
		});
	}
    // ERROR?
    else if (self.error) {
        dispatch_async(dispatch_get_main_queue(), ^{
			[self onServiceFinishWithError:self.error];
		});
	}
    // SUCCESS
    else if (self.response) {
        dispatch_async(self.serialQueue, ^{
			[self parseWithMLResponse:self.response withCompletionBlock: ^(id objectParsed) {
			    dispatch_async(dispatch_get_main_queue(), ^{
								   [self onServiceSuccessParseFinished:objectParsed];
							   });
			}];
		});
	}

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancelOperation
{
    NSAssert(![self isCancelled], @"Trying to cancel a cancelled operation");

    if (![self isCancelled]) {
        [super cancel];

        if ([self isExecuting]) {
            self.operation.delegate = nil;
            [self.operation cancel];
            [self finishOperation];
		}
	}
}

- (void)invalidate
{
    [self cancel];
}

#pragma mark - NSOperation

- (void)start
{
    NSAssert(![self isExecuting], @"Trying to start an already executing operation");

    if ([self isExecuting]) {
        return;
	}

    if ([self isCancelled]) {
        [self finishOperation];
        return;
	}

    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    self.operationExecuting = YES;

    if ([self shouldCancel]) {
        [self cancelOperation];
	} else {
        [self startOperation];
	}

    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancel
{
    dispatch_async(self.serialQueue, ^{
		if (![self isCancelled]) {
		    [self cancelOperation];
		}
	});
}

- (BOOL)isExecuting
{
    return self.operationExecuting;
}

- (BOOL)isFinished
{
    return self.operationFinished;
}

- (BOOL)isAsynchronous
{
    return YES;
}

#pragma mark - MLNetworkingOperationDelegate

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
        didFinishWithResponse:(MLNetworkingOperationResponse *)response
{
    [self setResponse:response];
    [self finishOperation];
}

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
             didFailWithError:(MLNetworkingOperationError *)error
{
    [self setError:error];
    [self finishOperation];
}

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
           didCancelWithError:(MLNetworkingOperationError *)error
{
    [self setError:error];
    [self cancelOperation];
}

- (void)     mlNetworkingOperation:(MLNetworkingOperation *)operation
    wasInvalidatedWithNewOperation:(MLNetworkingOperation *)newOperation
{
    [self setOperation:newOperation];
}

#pragma mark - Abstract methods

- (void)parseWithMLResponse:(MLNetworkingOperationResponse *)response
        withCompletionBlock:(MLServiceParseCompletionBlock)completionBlock
{
    NSAssert(NO, @"You must override 'parseWithMLResponse:withCompletionBlock:' in a subclass");
}

- (void)onServiceSuccessParseFinished:(id)object
{
    NSAssert(NO, @"You must override 'onServiceSuccessParseFinished:' in a subclass");
}

- (void)onServiceFinishWithError:(MLNetworkingOperationError *)error
{
    NSAssert(NO, @"You must override 'onServiceFinishWithError:' in a subclass");
}

- (void)onServiceCanceled:(MLNetworkingOperationError *)error
{
    NSAssert(NO, @"You must override 'onServiceCanceled:' in a subclass");
}

@end
