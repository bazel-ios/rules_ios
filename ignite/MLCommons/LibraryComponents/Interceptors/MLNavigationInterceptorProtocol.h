//
// MLNavigationInterceptorProtocol.h
// MLCommons
//
// Created by Jonatan Urquiza on 12/12/18.
//

#import "MLNavigationInterceptorInvocationForPush.h"
#import "MLNavigationInterceptorInvocationForPresentation.h"
#import "MLNavigationInterceptorInvocationForViewcontrollers.h"

@protocol MLNavigationInterceptorProtocol <NSObject>
- (void)pushViewController:(MLNavigationInterceptorInvocationForPush *)invocation;
- (void)presentViewController:(MLNavigationInterceptorInvocationForPresentation *)invocation;
- (void)setViewControllers:(MLNavigationInterceptorInvocationForViewcontrollers *)invocation;
@end
