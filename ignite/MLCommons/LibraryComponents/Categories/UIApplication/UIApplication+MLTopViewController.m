//
// UIApplication+TopViewController.m
// MLCommons
//
// Created by Mauro Carreño on 3/22/17.
// Copyright © 2017 MercadoLibre. All rights reserved.
//

#import "UIApplication+MLTopViewController.h"

@implementation UIApplication (MLTopViewController)

+ (UIViewController *)ml_topViewController
{
	// Find best view controller
	UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	return [UIApplication ml_topViewController:viewController];
}

+ (UIViewController *)ml_topViewController:(UIViewController *)vc
{
	if (vc.presentedViewController) {
		// Return presented view controller
		return [UIApplication ml_topViewController:vc.presentedViewController];
	}

	if ([vc isKindOfClass:[UISplitViewController class]]) {
		// Return right hand side
		UISplitViewController *svc = (UISplitViewController *)vc;
		return svc.viewControllers.count > 0 ? [UIApplication ml_topViewController:svc.viewControllers.lastObject] : vc;
	}

	if ([vc isKindOfClass:[UINavigationController class]]) {
		// Return top view
		UINavigationController *svc = (UINavigationController *)vc;
		return svc.viewControllers.count > 0 ? [UIApplication ml_topViewController:svc.topViewController] : vc;
	}

	if ([vc isKindOfClass:[UITabBarController class]]) {
		// Return visible view
		UITabBarController *svc = (UITabBarController *)vc;
		return svc.viewControllers.count > 0 ? [UIApplication ml_topViewController:svc.selectedViewController] : vc;
	}

	// Unknown view controller type, return last child view controller
	return vc;
}

@end
