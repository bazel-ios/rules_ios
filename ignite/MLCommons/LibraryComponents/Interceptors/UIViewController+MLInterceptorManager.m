//
// UIViewController+MLInterceptorManager.m
// MLCommons
//
// Created by Jonatan Urquiza on 20/12/18.
//

#import "UIViewController+MLInterceptorManager.h"
#import "MLNavigationInterceptorProtocol.h"
#import "MLRequiredInterceptor.h"
#import <objc/runtime.h>

@implementation UIViewController (MLInterceptorManager)

+ (void)sw_viewControllerInterceptor
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = [self class];

		[self sw_presentViewControllerWithClass:class];
	});
}

#pragma mark - Swizzle PresentViewController

+ (void)sw_presentViewControllerWithClass:(Class)class
{
	[self swizzleOriginalSelector:@selector(presentViewController:animated:completion:) swizzledSelector:@selector(interceptor_presentViewController:animated:completion:) class:class];
}

- (void)interceptor_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion
{
	id <MLNavigationInterceptorProtocol> interceptor = [MLRequiredInterceptor requiredInterceptor];
	if (interceptor) {
		MLNavigationInterceptorInvocationForPresentation *invocation = [[MLNavigationInterceptorInvocationForPresentation alloc] initWithViewController:viewControllerToPresent animated:animated completion:completion];

		[interceptor presentViewController:invocation];
		if (invocation.continueInvocation) {
			[self interceptor_presentViewController:invocation.viewController animated:invocation.animated completion:invocation.completion];
		}
		return;
	}
	[self interceptor_presentViewController:viewControllerToPresent animated:animated completion:completion];
}

#pragma mark - Swizzle

+ (void)swizzleOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector class:(Class)class
{
	Method originalMethod = class_getInstanceMethod(class, originalSelector);
	Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

	BOOL didAddMethod =
		class_addMethod(class,
		                originalSelector,
		                method_getImplementation(swizzledMethod),
		                method_getTypeEncoding(swizzledMethod));

	if (didAddMethod) {
		class_replaceMethod(class,
		                    swizzledSelector,
		                    method_getImplementation(originalMethod),
		                    method_getTypeEncoding(originalMethod));
	} else {
		method_exchangeImplementations(originalMethod, swizzledMethod);
	}
}

@end
