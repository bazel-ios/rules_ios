//
// UIViewController+MLInterceptorManager.h
// MLCommons
//
// Created by Jonatan Urquiza on 20/12/18.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MLInterceptorManager)

/**
    Swizzle UIViewController Navigation with interceptor
 */
+ (void)sw_viewControllerInterceptor;

@end
