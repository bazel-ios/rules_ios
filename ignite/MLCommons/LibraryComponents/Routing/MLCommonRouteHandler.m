//
// MLCommonRouteHandler.m
// MLCommons
//
// Created by William Mora on 24/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLCommonRouteHandler.h"
#import "MLCommonRouter.h"
#import "MLCommonRoute.h"
#import "MLCommonRouterManager.h"

@interface MLCommonRouteHandler ()

/**
 *  An array of MLRoute objects specifying all paths supported by this handler. Note
 *  that routes are matched in the order they are registered, so if you have a path /:users before
 *  a path /users, /:users will always be the one matched even if the url given is /users
 */
@property (nonatomic, readonly) NSMutableArray *routes;

@end

@implementation MLCommonRouteHandler

+ (void)registerHandlerForHost:(NSString *)host
{
	[[MLCommonRouter router] registerHandler:[self class] forHost:host];
}

- (nullable __kindof UIViewController *)viewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic
{
	[MLCommonRouterManager viewControllerForURL:url isPublic:isPublic];

	return [self viewControllerForURL:url isPublic:isPublic additionalInfo:nil];
}

- (nullable __kindof UIViewController *)viewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic additionalInfo:(nullable id)additionalInfo
{
	for (MLCommonRoute *route in self.routes) {
		if ([route matchesURL:url]) {
			if (isPublic && ![route isPublic]) {
				return nil;
			}
			NSDictionary *params = [self parametersForURL:url fromRoute:route];
			UIViewController *viewController;
			if ([route.viewController conformsToProtocol:@protocol(MLCommonRouteViewControllerProtocol)]) {
				if (additionalInfo) {
					NSAssert(!isPublic, @"Can't be a public access receiving additional info, check isPublic:NO");
					NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc] initWithDictionary:params];
					[mutableParams setObject:additionalInfo forKey:@"additionalInfo"];
					params = [mutableParams copy];
				}
				viewController = [[route.viewController alloc] initWithDictionary:params];
			} else if ([route.viewController instancesRespondToSelector:@selector(initWithDictionary:)]) {
				// Added just for backwards compatibility for MP, should be removed soon
				if (additionalInfo) {
					NSAssert(!isPublic, @"Can't be a public access receiving additional info, check isPublic:NO");
					NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc] initWithDictionary:params];
					[mutableParams setObject:additionalInfo forKey:@"additionalInfo"];
					params = [mutableParams copy];
				}
				viewController = [[route.viewController alloc] initWithDictionary:params];
			} else {
				viewController = [[route.viewController alloc] init];
			}
			[self prepareViewController:viewController withURL:url];

			return viewController;
		}
	}

	return nil;
}

- (BOOL)existsViewControllerForURL:(NSURL *)url isPublic:(BOOL)isPublic
{
	for (MLCommonRoute *route in self.routes) {
		if ([route matchesURL:url]) {
			if (isPublic && ![route isPublic]) {
				// If the route is registered but it's been publicly accessed and is not public then return false.
				return NO;
			}
			// If the route is registered and is accesible then return true.
			return YES;
		}
	}

	// If none of the routes matches the url then return false.
	return NO;
}

/**
 *  Builds an NSDictionary with url's components: url, params, query and fragment. url contains the entire url string.
 *  Params refer to all params that are specified by an MLRoute with a dynamic path
 *  (ex: an MLRoute with path /users/:userId would return a dicitionary @{@"userId":@"the_user_id"} for params).
 *  Query refers to all query params separated by an ampersand (&) in the url.
 *  The fragment identifier (introduced by a hash mark #) is the optional last part of a URL for a document.
 *
 *  @param url   the URL to get the params and query from
 *  @param route the MLRoute that matches this URL. Note that it is assumed that the URL matches this route
 *
 *  @return a dictionary with: url, params, query and fragment
 */
- (NSDictionary *)parametersForURL:(NSURL *)url fromRoute:(MLCommonRoute *)route
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

	dictionary[@"url"] = url.absoluteString;
	dictionary[@"query"] = [self queryForURL:url];
	dictionary[@"params"] = [route paramsForURL:url];

	NSDictionary *extraParams = [self parseExtraParametersFromURL:url];
	for (NSString *key in extraParams.allKeys) {
		dictionary[key] = extraParams[key];
	}

	return dictionary;
}

/**
 *  Builds an NSDictionary based on all query params given in a url. Note that params must be separated by an
 *  ampersand (&) and each param should be formatted as key=value. Ex: meli://search?key1=value1&key2=value2
 *  would return a dictionary like @{@"key1": @"value1", @"key2": @"value2"}
 *
 *  @param url url with the query
 *
 *  @return an NSDictionary with all query params
 */
- (NSDictionary *)queryForURL:(NSURL *)url
{
	NSMutableDictionary *query = [[NSMutableDictionary alloc] init];

	NSArray *queryParams = [url.query componentsSeparatedByString:@"&"];

	for (NSString *param in queryParams) {
		NSArray *paramComponents = [param componentsSeparatedByString:@"="];
		if (paramComponents.count == 2) {
			NSString *key = [paramComponents[0] stringByRemovingPercentEncoding];
			NSString *value = [paramComponents[1] stringByRemovingPercentEncoding];

			if (key == nil || [key isEqualToString:@""]) {
				NSAssert(NO, @"Invalid key %@, url: %@", paramComponents[0], url);
				continue;
			}

			if (value == nil || [value isEqualToString:@""]) {
				NSAssert(NO, @"Invalid value %@ for key %@, url: %@", paramComponents[1], key, url);
				continue;
			}

			[query setObject:value forKey:paramComponents[0]];
		}
	}

	return query;
}

- (void)registerRoute:(MLCommonRoute *)route
{
	if (route == nil) {
		NSAssert(NO, @"Route cannot be nil");
		return;
	}

	if (_routes == nil) {
		_routes = [[NSMutableArray alloc] init];
	}

	[_routes addObject:route];
}

- (void)prepareViewController:(UIViewController *)viewController withURL:(NSURL *)url
{
	[MLCommonRouterManager prepareViewController:viewController withURL:url];
}

- (NSDictionary *)parseExtraParametersFromURL:(NSURL *)url
{
	return [MLCommonRouterManager parseExtraParametersFromURL:url];
}

@end
