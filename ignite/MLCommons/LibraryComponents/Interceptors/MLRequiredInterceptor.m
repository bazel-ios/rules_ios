//
// MLRequiredInterceptor.m
// MLCommons
//
// Created by Jonatan Urquiza on 12/12/18.
//

#import "MLRequiredInterceptor.h"
#import "MLInterceptorManager.h"

static id <MLNavigationInterceptorProtocol> _requiredInterceptor;

@implementation MLRequiredInterceptor

+ (id <MLNavigationInterceptorProtocol>)requiredInterceptor
{
	return _requiredInterceptor;
}

+ (void)setRequiredInterceptor:(id <MLNavigationInterceptorProtocol>)interceptor
{
	if (!_requiredInterceptor) {
		_requiredInterceptor = interceptor;
		[MLInterceptorManager sw_interceptor];
	} else {
		NSAssert(NO, @"You cannot set required interceptor twice");
	}
}

+ (void)resetRequiredInterceptor
{
	_requiredInterceptor = nil;
}

@end
