//
// MLCommonRouterCallbackBehaviour.h
// MLCommons
//
// Created by Nicolas Andres Suarez on 29/08/2018.
// Copyright © 2018 MercadoLibre. All rights reserved.
//

#import <MLCommons/MLBaseBehaviour.h>

NS_ASSUME_NONNULL_BEGIN

// The block will be invoked either with error or result.
typedef void (^MLCRouterCallback)(NSError *_Nullable error, NSDictionary *_Nullable result);

// Possible error codes on callback
typedef NS_ENUM (NSInteger, MLCommonRouterCallbackBehaviourError) {
	MLCommonRouterCallbackBehaviourErrorResultNotSerializable, // The result must be serializable
};

// This behaviour execute a callback when the viewController is popped or dismissed
@interface MLCommonRouterCallbackBehaviour : MLBaseBehaviour

// Data that is passed to the callback. This data should be setted for the viewController
@property (nonatomic, nullable, strong) NSDictionary *result;

- (instancetype)initWithCallback:(MLCRouterCallback)callback;

@end

NS_ASSUME_NONNULL_END
