//
// MLInterceptorManager.m
// MLCommons
//
// Created by Jonatan Urquiza on 20/12/18.
//

#import "MLInterceptorManager.h"
#import "UINavigationController+MLInterceptorManager.h"
#import "UIViewController+MLInterceptorManager.h"

@implementation MLInterceptorManager

+ (void)sw_interceptor
{
	[UINavigationController sw_navigationControllerInterceptor];
	[UIViewController sw_viewControllerInterceptor];
}

@end
