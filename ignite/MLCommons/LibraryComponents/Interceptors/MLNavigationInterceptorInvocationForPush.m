//
// MLNavigationInterceptorInvocationForPush.m
// MLCommons
//
// Created by Jonatan Urquiza on 18/12/18.
//

#import "MLNavigationInterceptorInvocationForPush.h"

@implementation MLNavigationInterceptorInvocationForPush

- (instancetype)initWithViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	self = [super init];
	if (self) {
		_viewController = viewController;
		_animated = animated;
		_continueInvocation = YES;
	}
	return self;
}

@end
