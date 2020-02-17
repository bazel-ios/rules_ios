//
// MLCommonRouteHandler.h
// MLCommons
//
// Created by William Mora on 24/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCommonRoute.h"
#import "MLCommonRouteViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Base class for handling URLs for a particular host. For this handler to work,
 *  it must register itself on -load by calling -registerHandlerForHost:
 */
@interface MLCommonRouteHandler : NSObject

/**
 *  Registers this class to MLRouter for route handling for the given host. You must
 *  call this function on -load
 *
 *  @param host host that will handle all routes registered in this class
 */
+ (void)registerHandlerForHost:(NSString *)host;

/**
 *  Returns an UIViewController object for the given URL
 *
 *  @param url Deeplink URL
 *  @param isPublic whether the URL is being requested from outside the app
 *
 *  @return an UIViewController object for the given url, otherwise nil
 */
- (nullable __kindof UIViewController *)viewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic;

/**
 *  Returns an UIViewController object for the given URL
 *
 *  @param url Deeplink URL
 *  @param isPublic whether the URL is being requested from outside the app
 *  @param additionalInfo additional info object passed to destination ViewController
 *
 *  @return UIViewController object for the given url, otherwise nil
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

/**
 *  Registers an MLRoute with a path supported by this handler. Note
 *  that routes are matched in the order they are registered, so if you have a path /:users before
 *  a path /users, /:users will always be the one matched even if the url given is /users
 *
 *  @param route the MLRoute to register
 */
- (void)registerRoute:(MLCommonRoute *)route;

/**
 *  Process UIViewController before being returned in viewControllerForURL:isPublic
 *
 *  @param viewController a UIViewConteroller
 *  @param url Deeplink URL
 */
- (void)prepareViewController:(UIViewController *)viewController withURL:(NSURL *)url;

/**
 *  Parse App specific parameters in the URL to be passed to the initWithDictionary
 *
 *  @param url Deeplink URL
 */
- (NSDictionary *)parseExtraParametersFromURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
