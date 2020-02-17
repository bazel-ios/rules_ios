//
// MLNavigationInterceptorInvocationForPush.h
// MLCommons
//
// Created by Jonatan Urquiza on 18/12/18.
//

#import <Foundation/Foundation.h>

@interface MLNavigationInterceptorInvocationForPush : NSObject

@property (nonnull, nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL continueInvocation;

- (instancetype)initWithViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
