//
// MLNavigationInterceptorInvocationForViewcontrollers.h
// MLCommons
//
// Created by Jonatan Urquiza on 18/12/18.
//

#import <Foundation/Foundation.h>

@interface MLNavigationInterceptorInvocationForViewcontrollers : NSObject

@property (nonnull, nonatomic, copy) NSArray <UIViewController *> *viewControllers;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL continueInvocation;

- (instancetype)initWithViewControllers:(NSArray <UIViewController *> *)viewControllers animated:(BOOL)animated;

@end
