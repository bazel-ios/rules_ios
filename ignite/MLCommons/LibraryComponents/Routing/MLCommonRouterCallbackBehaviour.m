//
// MLCommonRouterCallbackBehaviour.m
// MLCommons
//
// Created by Nicolas Andres Suarez on 29/08/2018.
// Copyright © 2018 MercadoLibre. All rights reserved.
//

#import "MLCommonRouterCallbackBehaviour.h"

static NSString *const ROUTER_CALLBACK_BEHAVIOUR_DOMAIN = @"ROUTER_CALLBACK_BEHAVIOUR";

@interface MLCommonRouterCallbackBehaviour ()

@property (nonatomic, nullable, copy) MLCRouterCallback callback;
@property (nonatomic) BOOL resultSet;

@end

@implementation MLCommonRouterCallbackBehaviour

- (instancetype)initWithCallback:(MLCRouterCallback)callback
{
	self = [super init];
	if (self) {
		self.callback = callback;
	}
	return self;
}

- (void)setResult:(NSDictionary *)result
{
	@synchronized(self) {
		_resultSet = YES;
		_result = result;
	}
}

- (BOOL)shouldForwardResult
{
	return (self.viewController.isMovingFromParentViewController
	        || self.viewController.isBeingDismissed)
	       && self.resultSet;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	if ([self shouldForwardResult]) {
		if ([NSJSONSerialization isValidJSONObject:self.result] || self.result == nil) {
			self.callback(nil, self.result);
		} else {
			self.callback([NSError errorWithDomain:ROUTER_CALLBACK_BEHAVIOUR_DOMAIN code:MLCommonRouterCallbackBehaviourErrorResultNotSerializable userInfo:nil], nil);
		}
	}
}

@end
