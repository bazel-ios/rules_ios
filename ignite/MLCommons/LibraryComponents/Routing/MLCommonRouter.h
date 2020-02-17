//
// MLCommonRouter.h
// MLCommons
//
// Created by William Mora on 24/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCommonRouteViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLCommonRouter : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Returns the shared router
 *
 *  @return the shared router
 */
+ (instancetype) router NS_SWIFT_NAME(sharedRouter());

/**
 *  Registers a URL handler to be used for routing. For a handler
 *  to be registered, two things need to happen:
 *    - The handler must be a subclass of MLRouteHandler
 *    - The host cannot be already registered
 *
 *  @param handler a subclass of MLURLHandler
 *  @param host    a unique host
 */
- (void)registerHandler:(Class)handler forHost:(NSString *)host;

/**
 *  Returns an UIViewController object for the given URL. Note that the host must
 *  already be registered to this manager in order to dispatch the request.
 *
 *  @param url Deeplink URL
 *  @param isPublic YES if the URL is being requested from outside the app
 *
 *  @return an UIViewController object. If no host is found or if the url does not match any routes for
 *  the registered handler for the host it will return nil
 */
- (nullable __kindof UIViewController *)viewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic;

/**
 *  Returns an UIViewController object for the given URL. Note that the host must
 *  already be registered to this manager in order to dispatch the request.
 *
 *  @param url Deeplink URL
 *  @param isPublic YES if the URL is being requested from outside the app
 *  @param additionalInfo additional info object passed to destination ViewController
 *
 *  @return an UIViewController object. If no host is found or if the url does not match any routes for
 *  the registered handler for the host it will return nil
 */
- (nullable __kindof UIViewController *)viewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic additionalInfo:(nullable id)additionalInfo;

/**
 *  Returns true if there is a route registered for the given URL.
 *
 *  @param url Deeplink URL
 *  @param isPublic YES if the URL is being requested from outside the app
 *
 *  @return a boolean. If the url is registered it will return true, otherwise it return false.
 */
- (BOOL)existsViewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic;

@end

NS_ASSUME_NONNULL_END
