//
// MLCommonRouterManager.m
// MLCommons
//
// Created by LEANDRO FURYK on 31/1/19.
//

#import "MLCommonRouterManager.h"
#import "MLCPRoutingConfigurationManager.h"

static id <MLCPRoutingConfigurationManager> _domainProvider;

@implementation MLCommonRouterManager

#pragma mark - Configuration
+ (void)configure:(id <MLCPRoutingConfigurationManager>)domainProvider
{
	NSParameterAssert(domainProvider != nil);

	_domainProvider = domainProvider;
}

#pragma mark - Exposed methods

+ (void)prepareViewController:(UIViewController *)viewController withURL:(NSURL *)url
{
	if ([self assertConfigured]) {
		[_domainProvider prepareViewController:viewController withURL:url];
	}
}

+ (NSDictionary *)parseExtraParametersFromURL:(NSURL *)url
{
	if ([self assertConfigured]) {
		return [_domainProvider parseExtraParametersFromURL:url];
	} else {
		return @{};
	}
}

+ (void)viewControllerForURL:(NSURL *)targetUrl isPublic:(BOOL)isPublic
{
	if ([self assertConfigured]) {
		[_domainProvider viewControllerForURL:targetUrl isPublic:isPublic];
	}
}

+ (void)validateViewController:(Class)viewController
{
	if ([self assertConfigured]) {
		[_domainProvider validateViewController:viewController];
	}
}

#pragma mark - Private utilities methods

+ (Boolean)assertConfigured
{
	return _domainProvider != nil ? true : false;
}

+ (void)cleanUp
{
	_domainProvider = nil;
}

@end
