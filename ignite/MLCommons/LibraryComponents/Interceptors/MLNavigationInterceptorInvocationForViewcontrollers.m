//
// MLNavigationInterceptorInvocationForViewcontrollers.m
// MLCommons
//
// Created by Jonatan Urquiza on 18/12/18.
//

#import "MLNavigationInterceptorInvocationForViewcontrollers.h"

@implementation MLNavigationInterceptorInvocationForViewcontrollers

- (instancetype)initWithViewControllers:(NSArray <UIViewController *> *)viewControllers animated:(BOOL)animated
{
	self = [super init];
	if (self) {
		_viewControllers = viewControllers;
		_animated = animated;
		_continueInvocation = YES;
	}
	return self;
}

@end
