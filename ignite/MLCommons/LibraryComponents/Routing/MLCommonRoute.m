//
// MLCommonRoute.m
// MLCommons
//
// Created by William Mora on 10/3/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLCommonRoute.h"
#import "MLCommonRouterManager.h"

@implementation MLCommonRoute

- (instancetype)initWithPath:(NSString *)path viewController:(Class)viewController isPublic:(BOOL)isPublic
{
	self = [super init];
	if (self) {
		[self validatePath:path];
		[self validateViewController:viewController];
		_path = path;
		_viewController = viewController;
		_isPublic = isPublic;
	}
	return self;
}

- (instancetype)initWithPath:(NSString *)path viewController:(Class)viewController
{
	return [self initWithPath:path viewController:viewController isPublic:NO];
}

- (void)validatePath:(NSString *)path
{
	if (path == nil || [path isEqualToString:@""]) {
		NSAssert(NO, @"Path cannot be empty");
	}
	if (![path hasPrefix:@"/"]) {
		NSAssert(NO, @"Invalid path. Must at least start with '/'");
	}
}

- (void)validateViewController:(Class)viewController
{
	if (viewController == nil) {
		NSAssert(NO, @"No view controller provided");
	}

	if (viewController != [UIViewController class] && ![viewController isSubclassOfClass:[UIViewController class]]) {
		NSAssert(NO, ([NSString stringWithFormat:@"%@ is not a subclass of UIViewController", viewController]))
		;
	}
	[MLCommonRouterManager validateViewController:viewController];
}

- (BOOL)matchesURL:(NSURL *)url
{
	if (url.path == nil || [url.path isEqualToString:@""]) {
		NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
		urlComponents.scheme = url.scheme;
		urlComponents.host = url.host;
		urlComponents.path = @"/";
		urlComponents.query = url.query;

		url = urlComponents.URL;
	}

	NSURL *routeURL = [self URLWithScheme:url.scheme host:url.host];

	if (routeURL == nil) {
		return NO;
	}

	if ([routeURL isEqual:url]) {
		return YES;
	}

	if (routeURL.pathComponents.count != url.pathComponents.count) {
		return NO;
	}

	for (int i = 0; i < url.pathComponents.count; i++) {
		NSString *urlPathComponent = url.pathComponents[i];
		NSString *routeURLPathComponent = routeURL.pathComponents[i];

		if (![urlPathComponent isEqualToString:routeURLPathComponent] && ![self pathComponentIsWildcard:routeURLPathComponent]) {
			return NO;
		}
	}

	return YES;
}

/**
 *  Returns if the given path component is a wildcard
 *
 *  @param pathComponent the path component to be evaluated
 *
 *  @return YES if it's a wildcard, otherwise NO
 */
- (BOOL)pathComponentIsWildcard:(NSString *)pathComponent
{
	return [pathComponent hasPrefix:@":"];
}

/**
 *  Returns a complete URL with the given scheme, host and path for this instance
 *
 *  @param scheme URL scheme
 *  @param host   URL host
 *
 *  @return a complete URL as in meli://host/users/me, for dynamic paths it would be meli://host/users/:id/edit
 */
- (NSURL *)URLWithScheme:(NSString *)scheme host:(NSString *)host
{
	if (scheme == nil || [scheme isEqualToString:@""]) {
		NSAssert(NO, @"Scheme cannot be empty");
		return nil;
	}
	if (host == nil || [host isEqualToString:@""]) {
		NSAssert(NO, @"Host cannot be empty");
		return nil;
	}
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@", scheme, host, self.path]];
}

- (NSDictionary *)paramsForURL:(NSURL *)url
{
	NSURL *routeURL = [self URLWithScheme:url.scheme host:url.host];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

	for (int i = 0; i < routeURL.pathComponents.count; i++) {
		NSString *routePathComponent = routeURL.pathComponents[i];

		if ([self pathComponentIsWildcard:routePathComponent]) {
			NSString *paramKey = [routePathComponent substringFromIndex:1];
			NSString *paramValue = url.pathComponents[i];
			[params setObject:paramValue forKey:paramKey];
		}
	}

	return params;
}

@end
