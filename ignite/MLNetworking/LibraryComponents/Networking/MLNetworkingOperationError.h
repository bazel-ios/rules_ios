//
// MLNetworkingError.h
// MLNetworking
//
// Created by Fabian Celdeiro on 9/19/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Error domain to identify errors from this library
 */
OBJC_EXTERN NSString *const MLNetworkingOperationErrorDomain;

/**
 *  Key in the userInfo dictionary of an MLNetworkingOperationError, which value is the response data obtained.
 */
OBJC_EXTERN NSString *const MLNetworkingOperationErrorResponse;

/**
 * Error codes
 */
typedef NS_ENUM (NSInteger, MLNetworkingOperationErrorCode) {
	MLNetworkingOperationErrorCodeFailureDependence                = -800,
	MLNetworkingOperationErrorCodeCanceledDependence               = -801,
	MLNetworkingOperationErrorCodeSessionTaskCouldNotBeCreated     = -802,
	MLNetworkingOperationErrorCodeCanceledAuthenticationDependence = -803,
	MLNetworkingOperationErrorCodeUnableCreateRequest              = -804
};

@interface MLNetworkingOperationError : NSError

@end
