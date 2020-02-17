//
// UINavigationController+MLInterceptorManager.m
// MLCommons
//
// Created by Jonatan Urquiza on 12/12/18.
//

#import "UINavigationController+MLInterceptorManager.h"
#import "MLNavigationInterceptorProtocol.h"
#import "MLRequiredInterceptor.h"
#import <objc/runtime.h>

@implementation UINavigationController (MLInterceptorManager)

+ (void)sw_navigationControllerInterceptor
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = [self class];

		[self sw_pushViewControllerWithClass:class];
		[self sw_setViewControllerWithClass:class];
	});
}

#pragma mark - Swizzle PushViewController

+ (void)sw_pushViewControllerWithClass:(Class)class
{
	[self swizzleOriginalSelector:@selector(pushViewController:animated:) swizzledSelector:@selector(interceptor_pushViewController:animated:) class:class];
}

- (void)interceptor_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	id <MLNavigationInterceptorProtocol> interceptor = [MLRequiredInterceptor requiredInterceptor];
	if (interceptor) {
		MLNavigationInterceptorInvocationForPush *invocation = [[MLNavigationInterceptorInvocationForPush alloc] initWithViewController:viewController animated:animated];

		[interceptor pushViewController:invocation];
		if (invocation.continueInvocation) {
			[self interceptor_pushViewController:invocation.viewController animated:invocation.animated];
		}
		return;
	}
	[self interceptor_pushViewController:viewController animated:animated];
}

#pragma mark - Swizzle SetViewController

+ (void)sw_setViewControllerWithClass:(Class)class
{
	[self swizzleOriginalSelector:@selector(setViewControllers:animated:) swizzledSelector:@selector(interceptor_setViewControllers:animated:) class:class];
}

- (void)interceptor_setViewControllers:(NSArray <UIViewController *> *)viewControllers animated:(BOOL)animated
{
	id <MLNavigationInterceptorProtocol> interceptor = [MLRequiredInterceptor requiredInterceptor];
	if (interceptor) {
		MLNavigationInterceptorInvocationForViewcontrollers *invocation = [[MLNavigationInterceptorInvocationForViewcontrollers alloc] initWithViewControllers:viewControllers animated:animated];

		[interceptor setViewControllers:invocation];
		if (invocation.continueInvocation) {
			[self interceptor_setViewControllers:invocation.viewControllers animated:invocation.animated];
		}
		return;
	}
	[self interceptor_setViewControllers:viewControllers animated:animated];
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
