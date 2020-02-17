//
// UIViewController+MLCommonRoute.h
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 29/11/17.
//

#import <UIKit/UIKit.h>
#import "MLCommonRouterCallbackBehaviour.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (MLCommonRoute)

/**
 *  @brief Navigates to the given URL with a horizontal slide transition
 *
 *  @param url Deeplink URL
 */
- (void)ml_pushViewControllerForURL:(NSURL *)url;

/**
 *  @brief Navigates to the given URL
 *
 *  @param url Deeplink URL
 *  @param animated if YES, uses a horizontal slide transition
 */
- (void)ml_pushViewControllerForURL:(NSURL *)url animated:(BOOL)animated;

/**
 *  @brief Navigates to the given URL
 *
 *  @param url Deeplink URL
 *  @param animated if YES, uses a horizontal slide transition
 *  @param additionalInfo additional info object passed to destination ViewController
 */
- (void)ml_pushViewControllerForURL:(NSURL *)url animated:(BOOL)animated additionalInfo:(nullable id)additionalInfo;

/**
   @brief Navigates to the given URL

 *  @param url Deeplink URL
 *  @param animated If YES, uses a horizontal slide transition
 *  @param additionalInfo Additional info object passed to destination ViewController
 *  @param callback Callback invoked when destination viewController is popped. The callback is invoked only if the destination viewController is an instance or inherit of MLBaseViewController
 */
- (void)ml_pushViewControllerForURL:(NSURL *)url animated:(BOOL)animated additionalInfo:(nullable id)additionalInfo forResult:(nullable MLCRouterCallback)callback;

/**
 *  @brief Presents the view controller associated to the given URL as a modal
 *
 *  @param url Deeplink URL
 *  @param animated   if YES, uses a vertical slide transition
 *  @param completion The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
 */
- (void)ml_presentViewControllerForURL:(NSURL *)url animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/**
 *  @brief Presents the view controller associated to the given URL as a modal
 *
 *  @param url Deeplink URL
 *  @param animated   if YES, uses a vertical slide transition
 *  @param completion The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
 *  @param additionalInfo additional info object passed to destination ViewController
 */
- (void)ml_presentViewControllerForURL:(NSURL *)url animated:(BOOL)animated completion:(nullable void (^)(void))completion additionalInfo:(nullable id)additionalInfo;

/**
 *  @brief Presents the view controller associated to the given URL as a modal
 *
 *  @param url Deeplink URL
 *  @param animated   If YES, uses a vertical slide transition
 *  @param completion The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
 *  @param additionalInfo Additional info object passed to destination ViewController
 *  @param callback Callback invoked when destination viewController is dissmised. The callback is invoked only if the destination viewController is an instance or inherit of MLBaseViewController.
 */
- (void)ml_presentViewControllerForURL:(NSURL *)url animated:(BOOL)animated completion:(nullable void (^)(void))completion additionalInfo:(nullable id)additionalInfo forResult:(nullable MLCRouterCallback)callback;

/**
 *  @brief Presents the view controller associated to the given URL as a modal
 *
 *  @param url Deeplink URL
 *  @param animated   If YES, uses a vertical slide transition
 *  @param completion The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
 *  @param additionalInfo Additional info object passed to destination ViewController
 *  @param callback Callback invoked when destination viewController is dissmised. The callback is invoked only if the destination viewController is an instance or inherit of MLBaseViewController.
 *  @param modalStyle modal presentation style for the presented ViewController.
 */
- (void)ml_presentViewControllerForURL:(NSURL *)url animated:(BOOL)animated completion:(nullable void (^)(void))completion additionalInfo:(nullable id)additionalInfo forResult:(nullable MLCRouterCallback)callback modalPresentationStyle:(UIModalPresentationStyle)modalStyle;
@end

NS_ASSUME_NONNULL_END
