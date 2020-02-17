//
// MLCommonRoute.h
// MLCommons
//
// Created by William Mora on 10/3/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A route that responds to a path and specifies an UIViewController or subclass that should be
 *  initialized when the path is matched
 *
 */
@interface MLCommonRoute : NSObject

/**
 *  Path supported by this route. Ex: /items/:id
 */
@property (nonatomic, readonly) NSString *path;

/**
 *  UIViewController or subclass to be initialized when the path is matched
 */
@property (nonatomic, readonly) Class viewController;

/**
 *  If set to YES, this route may be accessed from outside the app
 */
@property (nonatomic, readonly) BOOL isPublic;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Creates a route that, when matched with the given path, returns an UIViewController or subclass that
 *  should be initialized
 *
 *  @param path           path supported by this route. Paths may be static (ex: /users/me) or dynamic
 *                        (ex: /users/:userId)
 *  @param viewController a subclass of UIViewController that must be initialized when a path is matched
 *  @param isPublic       if YES, this route may be accessed from outeside the app
 *
 *  @return a route that, when matched with the given path, returns an UIViewController or subclass that
 *  should be initialized
 */
- (instancetype)initWithPath:(NSString *)path viewController:(Class)viewController isPublic:(BOOL)isPublic NS_DESIGNATED_INITIALIZER;

/**
 *  Creates a route that, when matched with the given path, returns an UIViewController or subclass that
 *  should be initialized
 *
 *  @param path            path supported by this route. Paths may be static (ex: /users/me) or dynamic
 *                         (ex: /users/:userId)
 *  @param viewController  a subclass of UIViewController that must be initialized when a path is matched
 *
 *  @return a route that, when matched with the given path, returns an UIViewController or subclass that
 *  should be initialized
 */
- (instancetype)initWithPath:(NSString *)path viewController:(Class)viewController;

/**
 *  Returns whether the given URL matches the path provided by this route. Note that it will be evaluated against the
 *  same scheme and host provided in the url
 *
 *  @param url url to match against
 *
 *  @return YES if the url matches this route, otherwise NO
 */
- (BOOL)matchesURL:(NSURL *)url;

/**
 *  Builds a params dictionary for a URL that matches this MLRoute. Each parameter has a key that matches the one
 *  specified in the path. Ex: if the path is /users/:userId and the given URL is meli://users/12345 then this method
 *  will return an NSDictionary like @{@"userId": @"12345"}. If the path for this MLRoute is static
 *  (as in /users/me) this method will return an empty NSDictionary
 *
 *  @param url the final URL. It is assumed that the URL matches this route (see method matchesURL:)
 *
 *  @return an NSDictionary with parameters for a URL that matches this MLRoute
 */
- (NSDictionary *)paramsForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
