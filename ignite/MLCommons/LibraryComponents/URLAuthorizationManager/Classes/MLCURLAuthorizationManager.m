//
// MLCURLAuthorizationManager.m
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 2/15/17.
//
//

#import "MLCURLAuthorizationManager.h"
#import "MLCURLAuthorizationDomainProvider.h"
#import <MLCommons/NSArray+MapReduceFilter.h>

static id <MLCURLAuthorizationDomainProvider> _domainProvider;

@implementation MLCURLAuthorizationManager

#pragma mark - Configuration

+ (void)configure:(id <MLCURLAuthorizationDomainProvider>)domainProvider
{
	NSParameterAssert(domainProvider != nil);

	_domainProvider = domainProvider;
}

#pragma mark - Exposed methods

+ (BOOL)isURLAuthorized:(NSURL *)url
{
	[self assertConfigured];

	NSString *host = [url host];

	// Reject all urls containing a password or username
	if ([url.user length] > 0 || [url.password length] > 0) {
		return NO;
	}

	NSArray <NSString *> *whitelistArray = [_domainProvider domains];
	for (NSString *domain in whitelistArray) {
		NSString *suffixedDomain = [NSString stringWithFormat:@".%@", domain];
		if ([host isEqualToString:domain] || [host hasSuffix:suffixedDomain]) {
			return YES;
		}
	}
	return NO;
}

+ (BOOL)isURLStringAuthorized:(NSString *)urlString
{
	[self assertConfigured];

	NSURL *url = [NSURL URLWithString:urlString];
	return [self isURLAuthorized:url];
}

#pragma mark - Private utilities methods

+ (void)assertConfigured
{
	NSAssert(_domainProvider != nil, @"Class not yet configured");
}

@end
