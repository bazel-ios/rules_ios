//
// UIViewController+MLCommonRoute.m
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 29/11/17.
//

#import "UIViewController+MLCommonRoute.h"
#import "MLCommonRouter.h"
#import "MLCommonRoute.h"
#import "MLCommonRouteHandler.h"
#import "MLBaseViewController.h"

@implementation UIViewController (MLCommonRoute)

- (void)ml_pushViewControllerForURL:(NSURL *)url
{
	[self ml_pushViewControllerForURL:url animated:YES];
}

- (void)ml_pushViewControllerForURL:(NSURL *)url animated:(BOOL)animated
{
	[self ml_pushViewControllerForURL:url animated:animated additionalInfo:nil];
}

- (void)ml_pushViewControllerForURL:(NSURL *)url
                           animated:(BOOL)animated
                     additionalInfo:(nullable id)additionalInfo
{
	[self ml_pushViewControllerForURL:url animated:animated additionalInfo:additionalInfo forResult:nil];
}

- (void)ml_pushViewControllerForURL:(NSURL *)url
                           animated:(BOOL)animated
                     additionalInfo:(nullable id)additionalInfo
                          forResult:(nullable MLCRouterCallback)callback
{
	UIViewController *viewController = [[MLCommonRouter router] viewControllerForURL:url isPublic:NO additionalInfo:additionalInfo];

	if (viewController == nil) {
		return;
	}

	[self ml_setupRouterBehaviourForViewController:viewController callback:callback];
	[self.navigationController pushViewController:viewController animated:animated];
	[self ml_notifyDidPushViewController:viewController forURL:url];
}

- (void)ml_presentViewControllerForURL:(NSURL *)url
                              animated:(BOOL)animated
                            completion:(nullable void (^)(void))completion
{
	[self ml_presentViewControllerForURL:url animated:animated completion:completion additionalInfo:nil];
}

- (void)ml_presentViewControllerForURL:(NSURL *)url
                              animated:(BOOL)animated
                            completion:(nullable void (^)(void))completion
                        additionalInfo:(nullable id)additionalInfo
{
	[self ml_presentViewControllerForURL:url animated:animated completion:completion additionalInfo:additionalInfo forResult:nil];
}

- (void)ml_presentViewControllerForURL:(NSURL *)url
                              animated:(BOOL)animated
                            completion:(nullable void (^)(void))completion
                        additionalInfo:(nullable id)additionalInfo
                             forResult:(nullable MLCRouterCallback)callback
{
	[self ml_presentViewControllerForURL:url animated:animated completion:completion additionalInfo:additionalInfo forResult:callback modalPresentationStyle:UIModalPresentationFullScreen];
}

- (void)ml_presentViewControllerForURL:(NSURL *)url
                              animated:(BOOL)animated
                            completion:(nullable void (^)(void))completion
                        additionalInfo:(nullable id)additionalInfo
                             forResult:(nullable MLCRouterCallback)callback
                modalPresentationStyle:(UIModalPresentationStyle)modalStyle {
	UIViewController *viewController = [[MLCommonRouter router] viewControllerForURL:url isPublic:NO additionalInfo:additionalInfo];

	if (viewController == nil) {
		return;
	}

	[self ml_setupRouterBehaviourForViewController:viewController callback:callback];
	viewController.modalPresentationStyle = modalStyle;
	[self presentViewController:viewController animated:animated completion:completion];
	[self ml_notifyDidPushViewController:viewController forURL:url];
}

/**
 *  @brief Method to notify viewController that has been pushed with an URL
 *
 *  @param url Deeplink URL
 */
- (void)ml_notifyDidPushViewController:(UIViewController *)viewController forURL:(NSURL *)url
{
	if ([viewController isKindOfClass:MLBaseViewController.class]) {
		[((MLBaseViewController *)viewController) viewDidAppearForUrl:url];
	}
}

- (void)ml_setupRouterBehaviourForViewController:(UIViewController *)viewController
                                        callback:(nullable MLCRouterCallback)callback
{
	if (!callback) {
		return;
	}

	if ([viewController isKindOfClass:MLBaseViewController.class]) {
		MLCommonRouterCallbackBehaviour *behaviour = [[MLCommonRouterCallbackBehaviour alloc] initWithCallback:callback];
		[((MLBaseViewController *)viewController) addBehaviour:behaviour];
	}
}

@end
