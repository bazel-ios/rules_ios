//
// UINavigationController+MLInterceptorManager.h
// MLCommons
//
// Created by Jonatan Urquiza on 12/12/18.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (MLInterceptorManager)

/**
    Swizzle UINavigtionController Navigation with interceptor
 */
+ (void)sw_navigationControllerInterceptor;

@end
