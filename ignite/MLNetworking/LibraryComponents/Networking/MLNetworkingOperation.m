//
// MLNetworkingOperation.m
// MLNetworking
//
// Created by Fabian Celdeiro on 9/14/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingOperation.h"
#import "MLNetworkingConfiguration.h"
#import "MLNetworkingSessionManager.h"
#import "MLNetworkingDefines.h"
#import "MLNetworkingRetryAfterHandler.h"

@interface MLNetworkingOperation () <MLNetworkingSessionManagerDelegate>

/**
 *  Flag to know if the operation finished
 */
@property (nonatomic, assign) BOOL operationFinished;

/**
 *  Flag to know if the operation is running
 */
@property (nonatomic, assign) BOOL operationExecuting;

/**
 *  Task's final response
 */
@property (nonatomic, strong) MLNetworkingOperationResponse *response;

/**
 *  Partial response data obtained.
 */
@property (nonatomic, strong) NSMutableData *partialResponse;

/**
 *  Task created to do the http request.
 */
@property (nonatomic, readwrite, strong) NSURLSessionTask *task;

/**
 *  Serial queue for asynchronous task
 */
@property (nonatomic, strong) dispatch_queue_t serialQueue;

/**
 *  Checks for dependencies failed or canceled.
 *
 *  @return YES if any dependency failed or canceled, but NO.
 */
- (BOOL)shouldCancel;

@end

@implementation MLNetworkingOperation

@synthesize configuration = _configuration;

#pragma mark - NSObject

- (instancetype)init
{
	return [self initWithNetworkingConfig:nil];
}

- (instancetype)initWithNetworkingConfig:(MLNetworkingConfiguration *)configuration
{
	if (self = [super init]) {
		_configuration = [configuration copy];
		_operationFinished = NO;
		_operationExecuting = NO;
		_operationIdentifier = [[NSUUID UUID] UUIDString];
		_serialQueue = dispatch_queue_create("com.mercadolibre.networking.operation.serialQueue", DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

#pragma mark - Custom methods

- (MLNetworkingConfiguration *)configuration
{
	return [_configuration copy];
}

- (void)setPriority:(MLNetworkingOperationPriority)priority
{
	@synchronized(self)
	{
		self.queuePriority = (NSOperationQueuePriority)priority;
	}
}

- (MLNetworkingOperationPriority)priority
{
	return (MLNetworkingOperationPriority)self.queuePriority;
}

- (BOOL)shouldCancel
{
	for (NSOperation *operation in self.dependencies) {
		if ([operation isCancelled]) {
			self.error = [[MLNetworkingOperationError alloc] initWithDomain:MLNetworkingOperationErrorDomain
			                                                           code:MLNetworkingOperationErrorCodeCanceledDependence
			                                                       userInfo:@{NSLocalizedDescriptionKey : @"Dependence canceled"}];
			return YES;
		} else if ([operation isKindOfClass:[MLNetworkingOperation class]]) {
		    MLNetworkingOperation *networkingOperation = (MLNetworkingOperation *)operation;
		    if (networkingOperation.error) {
		        NSString *reason = [NSString stringWithFormat:@"Dependence %@ failed with error code: %ld", networkingOperation.operationIdentifier, (long)networkingOperation.error.code];
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
    MLNETWORKING_ASSERT_NOT_MAIN_THREAD

    if ([self isExecuting]) {
        NSAssert(![self isExecuting], @"Trying to start an already executing operation");
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
        [self startNetworkRequestWithSessionManager];
	}

    [self didChangeValueForKey:@"isExecuting"];
}

- (void)startNetworkRequestWithSessionManager
{
    MLNETWORKING_ASSERT_NOT_MAIN_THREAD

    MLNetworkingConfiguration *configuration = self->_configuration;
    NSParameterAssert(configuration);

    if (!configuration) {
        [self finishOperation];
        return;
	}

    NSDictionary *additionalAuthParams = [self.authenticationDataSource mlNet_extraQueryParams];

    if (additionalAuthParams) {
        NSMutableDictionary *queryParamsWithAccessToken = nil;

        if (configuration.queryParams) {
            queryParamsWithAccessToken = [NSMutableDictionary dictionaryWithDictionary:configuration.queryParams];
            [queryParamsWithAccessToken addEntriesFromDictionary:additionalAuthParams];
            configuration.queryParams = [NSDictionary dictionaryWithDictionary:queryParamsWithAccessToken];
		} else {
            configuration.queryParams = [additionalAuthParams copy];
		}
	}

    NSError *error = nil;
    self.task = [[MLNetworkingSessionManager sharedInstance] taskFromConfiguration:configuration
                                                                      withDelegate:self
                                                                             error:&error];

    if (self.task == nil) {
        self.error = [[MLNetworkingOperationError alloc] initWithDomain:MLNetworkingOperationErrorDomain
                                                                   code:MLNetworkingOperationErrorCodeSessionTaskCouldNotBeCreated
                                                               userInfo:error.userInfo];
        [self finishOperation];
        return;
	}

    // Try get cached response
    MLNetworkingOperationResponse *cachedResponse = [[MLNetworkingRetryAfterHandler sharedInstance] cachedResponseForRequest:self.task.originalRequest];

    if (cachedResponse) {
        [self manageResponse:cachedResponse];
        [self finishOperation];
	} else {
        [self.task resume];
	}
}

- (void)finishOperation
{
    MLNETWORKING_ASSERT_NOT_MAIN_THREAD

    self.task = nil;

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    self.operationExecuting = NO;
    self.operationFinished = YES;

    // Why sync? Because if async, when the answers come too quickly, saturate the main thread.
    dispatch_sync(dispatch_get_main_queue(), ^{
		if ([self isCancelled]) {
		    if ([self.delegate respondsToSelector:@selector(mlNetworkingOperation:didCancelWithError:)]) {
		        [self.delegate mlNetworkingOperation:self didCancelWithError:self.error];
			} else if (self.canceledBlock) {
		        self.canceledBlock(self, self.error);
			}
		} else if (self.error) {
		    if (self.delegate) {
		        [self.delegate mlNetworkingOperation:self didFailWithError:self.error];
			} else if (self.failureBlock) {
		        self.failureBlock(self, self.error);
			}
		} else if (self.response) {
		    if (self.delegate) {
		        [self.delegate mlNetworkingOperation:self didFinishWithResponse:self.response];
			} else if (self.successBlock) {
		        self.successBlock(self, self.response);
			}
		}
	});

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancelOperation
{
    NSAssert(![self isCancelled], @"Trying to cancel a cancelled operation");

    if (![self isCancelled]) {
        [super cancel];

        if ([self isExecuting]) {
            if (self.task) {
                [self.task cancel];
			} else {
                [self finishOperation];
			}
		}
	}
}

- (void)manageResponse:(MLNetworkingOperationResponse *)response
{
    if (response.statusCode >= 400) {
        NSString *responseString = [[NSString alloc] initWithData:response.responseData
                                                         encoding:NSUTF8StringEncoding];
        NSDictionary *errorInfo;
        if (responseString) {
            errorInfo = @{MLNetworkingOperationErrorResponse : responseString};
		}
        self.error = [[MLNetworkingOperationError alloc] initWithDomain:MLNetworkingOperationErrorDomain
                                                                   code:response.statusCode
                                                               userInfo:errorInfo];
	} else {
        self.response = response;
	}
}

#pragma mark - NSOperation

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

- (void)start
{
    MLNETWORKING_ASSERT_NOT_MAIN_THREAD

    [self startOperation];
}

- (void)cancel
{
    dispatch_async(self.serialQueue, ^{
		if (![self isCancelled]) {
		    [self cancelOperation];
		}
	});
}

#pragma mark - MLNetworkingSessionManagerDelegate

- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)manager
                          dataTask:(NSURLSessionDataTask *)dataTask
                    didReceiveData:(NSData *)data
{
    if (!self.partialResponse) {
        self.partialResponse = [[NSMutableData alloc] init];
	}
    [self.partialResponse appendData:data];
}

- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                              task:(NSURLSessionTask *)task
              didCompleteWithError:(NSError *)error
{
    if (error) {
        self.error = [[MLNetworkingOperationError alloc] initWithDomain:error.domain
                                                                   code:error.code
                                                               userInfo:error.userInfo];
	}

    if ([self isCancelled]) {
        [self finishOperation];
        return;
	}

    if (error.code == NSURLErrorCancelled) {
        [super cancel];
	} else {
        MLNetworkingOperationResponse *response = [[MLNetworkingOperationResponse alloc] initWithURLResponse:task.response
                                                                                                responseData:[NSData dataWithData:self.partialResponse]];
        [[MLNetworkingRetryAfterHandler sharedInstance] saveResponse:response
                                                          forRequest:task.originalRequest];
        [self manageResponse:response];
	}

    [self finishOperation];
}

- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                          dataTask:(NSURLSessionDataTask *)dataTask
             didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    self.task = downloadTask;
}

- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                      downloadTask:(NSURLSessionDownloadTask *)downloadTask
         didFinishDownloadingToURL:(NSURL *)location
{
    // TODO: Ver en serio algo para manejar cache, asi esto no escala
    self.partialResponse = [NSMutableData dataWithContentsOfURL:location];
}

- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                              task:(NSURLSessionTask *)task
                   didSendBodyData:(int64_t)bytesSent
                    totalBytesSent:(int64_t)totalBytesSent
          totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if ([self.delegate respondsToSelector:@selector(mlNetworkingOperation:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
        [self.delegate mlNetworkingOperation:self didSendBodyData:bytesSent
                              totalBytesSent:totalBytesSent
                    totalBytesExpectedToSend:totalBytesExpectedToSend];
	}
}

- (void)mlNetworkingSessionManager:(MLNetworkingSessionManager *)sessionManager
                      downloadTask:(NSURLSessionDownloadTask *)downloadTask
                      didWriteData:(int64_t)bytesWritten
                 totalBytesWritten:(int64_t)totalBytesWritten
         totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if ([self.delegate respondsToSelector:@selector(mlNetworkingOperation:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate mlNetworkingOperation:self didWriteData:bytesWritten
                           totalBytesWritten:totalBytesWritten
                   totalBytesExpectedToWrite:totalBytesExpectedToWrite];
	}
}

#pragma mark - NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
    MLNetworkingOperation *operationCopy = [[[self class] alloc] init];

    operationCopy.delegate = self.delegate;
    operationCopy.successBlock = self.successBlock;
    operationCopy.failureBlock = self.failureBlock;
    operationCopy.canceledBlock = self.canceledBlock;
    operationCopy.operationIdentifier = self.operationIdentifier;
    operationCopy->_configuration = self.configuration;
    operationCopy.authenticationDataSource = self.authenticationDataSource;
    operationCopy.queuePriority = self.queuePriority;

    return operationCopy;
}

@end
