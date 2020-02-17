//
// MLRequiredInterceptor.h
// MLCommons
//
// Created by Jonatan Urquiza on 12/12/18.
//

#import <Foundation/Foundation.h>
@protocol MLNavigationInterceptorProtocol;
@protocol MLBehaviourProtocol;

@interface MLRequiredInterceptor : NSObject
/**
   Lets client add the required interceptor for all the view controllers in the app.

   @param interceptor to be added to all the view controllers.
 */
+ (void)setRequiredInterceptor:(id <MLNavigationInterceptorProtocol>)interceptor;

/**
   Lets the client get the required interceptor.

   @return the required interceptor
 */
+ (id <MLNavigationInterceptorProtocol>)requiredInterceptor;

@end
