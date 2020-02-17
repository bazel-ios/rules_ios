//
// MLRestClientManager.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/18/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLRestClientManager.h"
#import "MLNetworkingOperation.h"
#import "MLNetworkingOperationManager.h"
#import "MLNetworkingSessionManager.h"
#import "MLRestClientAppTokenAuthenticationOperation.h"
#import "MLRestClientUserAuthenticationOperation.h"
#import "MLRestClientOperationCallbacks.h"
#import <MLAuthentication/MLAuthenticationManager.h>
#import <MLAuthentication/MLAppAuthenticationManager.h>
#import "MLRestClientAuthenticationConnectionFactory.h"
#import "MLRestClientNotificationsNames.h"
#import "MLNetworkingDefines.h"

NSString *const MLAuthenticationKeychainId = @"com.mercadolibre.session";

@interface MLRestClientManager () <MLNetworkingOperationDelegate>

@property (nonatomic, strong, readonly) NSOperationQueue *authenticationQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t serialQueue;

@property (nonatomic, strong) NSMutableDictionary *authenticatedOperations;
@property (nonatomic, strong) NSMutableDictionary *operationCallbacks;
@property (nonatomic, strong, readonly) dispatch_queue_t operationCallbacksQueue;

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;

@end

@implementation MLRestClientManager

#pragma mark - Class methods

+ (MLRestClientManager *)sharedInstance
{
	static MLRestClientManager *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[MLRestClientManager alloc] init];
	});
	return shared;
}

+ (void)initializeWithAppId:(NSString *)appId andAppSecret:(NSString *)appSecret
{
	[self initializeWithAppId:appId andAppSecret:appSecret keychainId:MLAuthenticationKeychainId];
}

+ (void)initializeWithAppId:(NSString *)appId andAppSecret:(NSString *)appSecret keychainId:(NSString *)keychainId
{
	NSAssert(appId.length > 0, @"AppId can not be nil or empty.");
	NSAssert(appSecret.length > 0, @"AppSecret can not be nil or empty.");
	NSAssert(keychainId.length > 0, @"KeychainId can not be nil or empty.");

	MLRestClientManager *manager = [MLRestClientManager sharedInstance];
	manager.appId = appId;
	manager.appSecret = appSecret;

	[MLAuthenticationManager initializeWithAppId:appId
	                          keychainIdentifier:keychainId
	                        andConnectionFactory:[[MLRestClientAuthenticationConnectionFactory alloc] init]];

	[MLAppAuthenticationManager initializeWithConnectionFactory:[[MLRestClientAuthenticationConnectionFactory alloc] init]];
}

#pragma mark - Instance methods

- (id)init
{
	if (self = [super init]) {
		_authenticationQueue = [[NSOperationQueue alloc] init];
		_serialQueue = dispatch_queue_create("com.mercadolibre.restClient.manager.serialQueue", 0);
		_operationCallbacksQueue = dispatch_queue_create("com.mercadolibre.restClient.manager.operationCallbacksQueue", DISPATCH_QUEUE_CONCURRENT);
		_authenticatedOperations = [[NSMutableDictionary alloc] init];
		_operationCallbacks = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (void)addOperation:(MLNetworkingOperation *)operation
{
	if (operation == nil) {
		return;
	}

	// Save reference to original delegate and set MLRestClientManager as delegate.
	__weak typeof(self) weakSelf = self;

	[self createCallbackForOperation:operation
	                    successBlock: ^(MLRestClientOperationCallbacks *callbacks) {
	    operation.delegate = weakSelf;
	    [[MLNetworkingOperationManager sharedInstance] addOperation:operation];
	}];
}

- (void)addAuthenticatedOperation:(MLNetworkingOperation *)authenticatedOperation authenticationMode:(MLRestClientAuthenticationMode)authMode
{
	MLRestClientAuthenticationOperation *authOperation = self.authenticatedOperations[@(authMode)];

	if (!authOperation || [authOperation isFinished] || [authOperation isCancelled]) {
		authOperation = [self authOperationByMode:authMode];

		__weak MLRestClientManager *weakSelf = self;
		authOperation.completionBlock = ^{
			[weakSelf.authenticatedOperations removeObjectForKey:@(authMode)];
		};

		self.authenticatedOperations[@(authMode)] = authOperation;
		[self.authenticationQueue addOperation:authOperation];
	}

	[authenticatedOperation setAuthenticationDataSource:authOperation];
	[authenticatedOperation addDependency:authOperation];

	[self addOperation:authenticatedOperation];
}

- (void)addOperation:(MLNetworkingOperation *)operation withAuthenticationMode:(MLRestClientAuthenticationMode)authenticationMode
{
	if (operation == nil) {
		return;
	}

	dispatch_async(self.serialQueue, ^{
		if (authenticationMode == MLRestClientAuthenticationModeNone) {
		    [self addOperation:operation];
		} else {
		    [self addAuthenticatedOperation:operation authenticationMode:authenticationMode];
		}
	});
}

- (MLRestClientAuthenticationOperation *)authOperationByMode:(MLRestClientAuthenticationMode)authMode
{
	MLRestClientAuthenticationOperation *operation;
	switch (authMode) {
		case MLRestClientAuthenticationAppAuth:
		{
			operation = [[MLRestClientAppTokenAuthenticationOperation alloc] initWithAppId:self.appId
			                                                                  andAppSecret:self.appSecret];
			break;
		}

		case MLRestClientAuthenticationUserNoLogin:
		case MLRestClientAuthenticationUserMustLogin:
		case MLRestClientAuthenticationUserOptional: {
			operation = [[MLRestClientUserAuthenticationOperation alloc] initWithAppId:self.appId
			                                                        authenticationMode    :authMode];
			break;
		};

		case MLRestClientAuthenticationModeNone:
		default: {
			operation = nil;
			break;
		}
	}
	return operation;
}

- (void)logoutUser
{
	dispatch_async(self.serialQueue, ^{
		MLRestClientUserAuthenticationOperation *authOperation = self.authenticatedOperations[@(MLRestClientAuthenticationUserNoLogin)];
		if (authOperation && ![authOperation isCancelled]) {
		    [authOperation cancel];
		}

		authOperation = self.authenticatedOperations[@(MLRestClientAuthenticationUserMustLogin)];
		if (authOperation && ![authOperation isCancelled]) {
		    [authOperation cancel];
		}

		[[MLNetworkingOperationManager sharedInstance] cancelOperationsWithDependency:[MLRestClientUserAuthenticationOperation class]];

		[self removeSession];
	});
}

- (void)showLoginUser
{
	__weak MLRestClientManager *weakSelf = self;
	dispatch_async(self.serialQueue, ^{
		MLRestClientManager *strongSelf = weakSelf;

		// SI no tengo una operacion de autenticacion o ya termino creo una y la encolo
		MLRestClientUserAuthenticationOperation *userAuthenticationOperation = self.authenticatedOperations[@(MLRestClientAuthenticationUserMustLogin)];

		if (!userAuthenticationOperation || [userAuthenticationOperation isFinished] || [userAuthenticationOperation isCancelled]) {
		    userAuthenticationOperation = [[MLRestClientUserAuthenticationOperation alloc] initWithAppId:self.appId
		                                                                              authenticationMode    :MLRestClientAuthenticationUserMustLogin];
		    self.authenticatedOperations[@(MLRestClientAuthenticationUserMustLogin)] = userAuthenticationOperation;

		    __weak MLRestClientManager *weakSelf = self;
		    userAuthenticationOperation.completionBlock = ^{
		        [weakSelf.authenticatedOperations removeObjectForKey:@(MLRestClientAuthenticationUserMustLogin)];
			};

		    [[strongSelf authenticationQueue] addOperation:userAuthenticationOperation];
		}
	});
}

- (void)removeSession
{
	if ([self session]) {
		NSDictionary *userInfo;
		if (self.session.userId) {
			userInfo = @{MLRestClientUserIdParamNotification : [self session].userId};
		}

		[[MLAuthenticationManager sharedInstance] logout];

		// Notify that the session was removed
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:MLRestClientDidUserLogoutNotification object:nil userInfo:userInfo];
		});
	}
}

- (BOOL)isUserAuthenticated
{
	return ([self session] != nil);
}

- (NSString *)authenticatedUserId
{
	return [self session].userId;
}

- (MLSession *)session
{
	return [[MLAuthenticationManager sharedInstance] getSession];
}

- (void)setCommonHeaders:(NSDictionary *)commonHeaders
{
	[[MLNetworkingSessionManager sharedInstance] setGenericHeaders:commonHeaders];
}

- (void)handleNetworkingOperation:(MLNetworkingOperation *)operation
                      normalError:(MLNetworkingOperationError *)error
{
	__weak typeof(self) weakSelf = self;

	[self requestOperationCallbackWithIdentifier:operation.operationIdentifier
	                                successBlock: ^(MLRestClientOperationCallbacks *operationCallback) {
	    if (!operationCallback) {
	        return;
		}

	    dispatch_async(dispatch_get_main_queue(), ^{
						   if (operationCallback.delegate) {
						       [operationCallback.delegate mlNetworkingOperation:operation didFailWithError:error];
						   } else if (operation.failureBlock) {
						       operation.failureBlock(operation, error);
						   }
					   });

	    [weakSelf removeCallbackWithIdentifier:operation.operationIdentifier];
	}];
}

- (void)handleNetworkingOperation:(MLNetworkingOperation *)operation
              authenticationError:(MLNetworkingOperationError *)error
      withAuthenticationOperation:(MLRestClientAuthenticationOperation *)authOperation
{
	[self removeSession];

	// If the authentication mode requires login, then we run the operation again.
	if (authOperation.authMode == MLRestClientAuthenticationUserMustLogin) {
		// Create a copy of the original operation to retry
		MLNetworkingOperation *newOperation = [operation copy];

		__weak typeof(self) weakSelf = self;

		[self requestOperationCallbackWithIdentifier:operation.operationIdentifier
		                                successBlock: ^(MLRestClientOperationCallbacks *operationCallback) {
		    newOperation.delegate = operationCallback.delegate;

		    // Notify that the operation was changed
		    if ([operationCallback.delegate respondsToSelector:@selector(mlNetworkingOperation:wasInvalidatedWithNewOperation:)]) {
		        [operationCallback.delegate mlNetworkingOperation:operation
		                           wasInvalidatedWithNewOperation:newOperation];
			} else if (operation.invalidationBlock) {
		        operation.invalidationBlock(operation, newOperation);
			}

		    [weakSelf addOperation:newOperation withAuthenticationMode:authOperation.authMode];
		}];
	} else {
		[self handleNetworkingOperation:operation normalError:error];
	}
}

- (void)requestOperationCallbackWithIdentifier:(NSString *)identifier
                                  successBlock:(void (^)(MLRestClientOperationCallbacks *callback))successBlock
{
	if (!successBlock || identifier.length == 0) {
		return;
	}

	__weak typeof(self) weakSelf = self;

	dispatch_async(self.operationCallbacksQueue, ^{
		MLRestClientOperationCallbacks *operationCallbacks = weakSelf.operationCallbacks[identifier];
		successBlock(operationCallbacks);
	});
}

- (void)createCallbackForOperation:(MLNetworkingOperation *)operation
                      successBlock:(void (^)(MLRestClientOperationCallbacks *callback))successBlock
{
	__weak typeof(self) weakSelf = self;

	dispatch_barrier_async(self.operationCallbacksQueue, ^{
		MLRestClientOperationCallbacks *operationCallbacks = [[MLRestClientOperationCallbacks alloc] initWithOperation:operation];
		[weakSelf.operationCallbacks setObject:operationCallbacks
		                                forKey:operation.operationIdentifier];
		if (successBlock) {
		    successBlock(operationCallbacks);
		}
	});
}

- (void)removeCallbackWithIdentifier:(NSString *)identifier
{
	if (identifier.length == 0) {
		return;
	}

	__weak typeof(self) weakSelf = self;

	dispatch_barrier_async(self.operationCallbacksQueue, ^{
		[weakSelf.operationCallbacks removeObjectForKey:identifier];
	});
}

#pragma mark - MLNetworkingOperationDelegate

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
        didFinishWithResponse:(MLNetworkingOperationResponse *)response
{
	__weak typeof(self) weakSelf = self;

	[self requestOperationCallbackWithIdentifier:operation.operationIdentifier
	                                successBlock: ^(MLRestClientOperationCallbacks *operationCallback) {
	    if (!operationCallback) {
	        return;
		}

	    dispatch_async(dispatch_get_main_queue(), ^{
						   if (operationCallback.delegate) {
						       [operationCallback.delegate mlNetworkingOperation:operation
						                                   didFinishWithResponse:response];
						   } else if (operation.successBlock) {
						       operation.successBlock(operation, response);
						   }
					   });

	    [weakSelf removeCallbackWithIdentifier:operation.operationIdentifier];
	}];
}

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
             didFailWithError:(MLNetworkingOperationError *)error
{
	// Me fijo si es error de autenticacion
	if (operation.authenticationDataSource &&  [operation.authenticationDataSource isKindOfClass:[MLRestClientAuthenticationOperation class]]) {
		MLRestClientAuthenticationOperation *authOperation = (MLRestClientAuthenticationOperation *)operation.authenticationDataSource;

		if ([authOperation isAuthenticationError:error]) {
			[self handleNetworkingOperation:operation authenticationError:error withAuthenticationOperation:authOperation];
		} else {
			[self handleNetworkingOperation:operation normalError:error];
		}
	} else {
		[self handleNetworkingOperation:operation normalError:error];
	}
}

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
           didCancelWithError:(MLNetworkingOperationError *)error
{
	if (error.code == MLNetworkingOperationErrorCodeCanceledDependence) {
		NSPredicate *authenticationCanceledPredicate = [NSPredicate predicateWithBlock: ^BOOL (id evaluatedObject, NSDictionary *bindings) {
		    return [evaluatedObject isCancelled] && [evaluatedObject isKindOfClass:[MLRestClientAuthenticationOperation class]];
		}];

		if ([operation.dependencies filteredArrayUsingPredicate:authenticationCanceledPredicate].count > 0) {
			error = [[MLNetworkingOperationError alloc] initWithDomain:MLNetworkingOperationErrorDomain
			                                                      code:MLNetworkingOperationErrorCodeCanceledAuthenticationDependence
			                                                  userInfo:@{NSLocalizedDescriptionKey : @"Authentication dependence was canceled"}];
		}
	}

	__weak typeof(self) weakSelf = self;

	[self requestOperationCallbackWithIdentifier:operation.operationIdentifier
	                                successBlock: ^(MLRestClientOperationCallbacks *operationCallback) {
	    if (!operationCallback) {
	        return;
		}

	    dispatch_async(dispatch_get_main_queue(), ^{
						   if (operationCallback.delegate) {
						       if ([operationCallback.delegate respondsToSelector:@selector(mlNetworkingOperation:didCancelWithError:)]) {
						           [operationCallback.delegate mlNetworkingOperation:operation
						                                          didCancelWithError:error];
							   }
						   } else if (operation.canceledBlock) {
						       operation.canceledBlock(operation, error);
						   }
					   });

	    [weakSelf removeCallbackWithIdentifier:operation.operationIdentifier];
	}];
}

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
              didSendBodyData:(int64_t)bytesSent
               totalBytesSent:(int64_t)totalBytesSent
     totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    [self requestOperationCallbackWithIdentifier:operation.operationIdentifier
                                    successBlock: ^(MLRestClientOperationCallbacks *operationCallback) {
        if (operationCallback && operationCallback.delegate) {
            if ([operationCallback.delegate respondsToSelector:@selector(mlNetworkingOperation:
                                                                         didSendBodyData:
                                                                         totalBytesSent:
                                                                         totalBytesExpectedToSend:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
								   [operationCallback.delegate mlNetworkingOperation:operation
								                                     didSendBodyData:bytesSent
								                                      totalBytesSent:totalBytesSent
								                            totalBytesExpectedToSend:totalBytesExpectedToSend];
							   });
			}
		}
	}];
}

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
                 didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [self requestOperationCallbackWithIdentifier:operation.operationIdentifier
                                    successBlock: ^(MLRestClientOperationCallbacks *operationCallback) {
        if (operationCallback && operationCallback.delegate) {
            if ([operationCallback.delegate respondsToSelector:@selector(mlNetworkingOperation:
                                                                         didWriteData:
                                                                         totalBytesWritten:
                                                                         totalBytesExpectedToWrite:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
								   [operationCallback.delegate mlNetworkingOperation:operation
								                                        didWriteData:bytesWritten
								                                   totalBytesWritten:totalBytesWritten
								                           totalBytesExpectedToWrite:totalBytesExpectedToWrite];
							   });
			}
		}
	}];
}

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
           didCancelWithError:(MLNetworkingOperationError *)error
            didResumeAtOffset:(int64_t)fileOffset
           expectedTotalBytes:(int64_t)expectedTotalBytes
{
    [self requestOperationCallbackWithIdentifier:operation.operationIdentifier
                                    successBlock: ^(MLRestClientOperationCallbacks *operationCallback) {
        if (operationCallback && operationCallback.delegate) {
            if ([operationCallback.delegate respondsToSelector:@selector(mlNetworkingOperation:
                                                                         didCancelWithError:
                                                                         didResumeAtOffset:
                                                                         expectedTotalBytes:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
								   [operationCallback.delegate mlNetworkingOperation:operation
								                                  didCancelWithError:error
								                                   didResumeAtOffset:fileOffset
								                                  expectedTotalBytes:expectedTotalBytes];
							   });
			}
		}
	}];
}

@end
