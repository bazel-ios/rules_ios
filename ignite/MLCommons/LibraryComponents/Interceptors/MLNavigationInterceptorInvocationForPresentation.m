//
// MLNavigationInterceptorInvocationForPresentation.m
// MLCommons
//
// Created by Jonatan Urquiza on 18/12/18.
//

#import "MLNavigationInterceptorInvocationForPresentation.h"

@implementation MLNavigationInterceptorInvocationForPresentation

- (instancetype)initWithViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
	self = [super init];
	if (self) {
		_viewController = viewController;
		_animated = animated;
		_completion = completion;
		_continueInvocation = YES;
	}
	return self;
}

@end
