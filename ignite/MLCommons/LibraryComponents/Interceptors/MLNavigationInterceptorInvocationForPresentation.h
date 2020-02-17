//
// MLNavigationInterceptorInvocationForPresentation.h
// MLCommons
//
// Created by Jonatan Urquiza on 18/12/18.
//

#import <Foundation/Foundation.h>

@interface MLNavigationInterceptorInvocationForPresentation : NSObject

@property (nonnull, nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign) BOOL animated;
@property (nullable, nonatomic, copy) void (^completion)(void);
@property (nonatomic, assign) BOOL continueInvocation;

- (instancetype)initWithViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

@end
