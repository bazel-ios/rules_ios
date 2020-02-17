//
// MLNetworkingConfiguration.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/10/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLNetworkingConfiguration.h"

#import "NSDictionary+MLNetworkingQueryString.h"
#import "NSString+MLNetworkingURLEncode.h"
#import "MLNetworkingDefines.h"

NSTimeInterval const MLNetworkingDefaultTimeOut = 60;

@implementation MLNetworkingConfiguration

@dynamic methodString;

- (id)init
{
	if (self = [super init]) {
		self.sessionType = MLNetworkingSessionTypeForeground;
		self.userAgent = [self defaultUserAgent];
		self.timeoutInterval = MLNetworkingDefaultTimeOut;
	}
	return self;
}

#pragma mark - Read only methods

- (NSString *)defaultUserAgent
{
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *appShortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *deviceModel = [[UIDevice currentDevice] model];
	NSString *systemVersion = [[UIDevice currentDevice] systemVersion];

	NSString *systemName = [[UIDevice currentDevice] systemName];
	if ([systemName isEqualToString:@"iPhone OS"]) {
		systemName = @"iOS";
	}

	return [NSString stringWithFormat:@"%@-%@/%@ (%@; %@ %@)", appName, systemName, appShortVersion, deviceModel, systemName, systemVersion];
}

- (NSString *)methodString
{
	switch (self.httpMethod) {
		case MLNetworkingHTTPMethodPOST: {
			return @"POST";
			break;
		}

		case MLNetworkingHTTPMethodPUT: {
			return @"PUT";
			break;
		}

		case MLNetworkingHTTPMethodGET:
		default: {
			return @"GET";
			break;
		}

		case MLNetworkingHTTPMethodDELETE: {
			return @"DELETE";
			break;
		}

		case MLNetworkingHTTPMethodHEAD: {
			return @"HEAD";
			break;
		}

		case MLNetworkingHTTPMethodPATCH: {
			return @"PATCH";
			break;
		}
	}
}

- (NSURL *)url
{
	return [NSURL URLWithString:[self urlString]];
}

- (NSString *)urlString
{
	NSString *result = self.baseURLString;

	if (result) {
		NSURLComponents *components = [NSURLComponents componentsWithString:self.baseURLString];

		if (self.path) {
			// Se verifica el caso en el que se pasen los query params dentro del path
			components.queryItems = [self verifyQueryParamsOnPath:self.path];
			if (components.path) {
				NSString *partialPath = [NSString stringWithFormat:@"%@%@", components.path, self.path];
				components.path = partialPath;
			} else {
				components.path = self.path;
			}
		}
		if (self.queryParams) {
			NSMutableArray <NSURLQueryItem *> *queryItems = [[NSMutableArray alloc] initWithCapacity:self.queryParams.count];

			for (NSString *key in [self.queryParams allKeys]) {
				if ([self.queryParams[key] isKindOfClass:[NSString class]] || [self.queryParams[key] isKindOfClass:[NSNumber class]]) {
					NSString *value = [NSString stringWithFormat:@"%@", self.queryParams[key]];
					if (value) {
						NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:value];
						[queryItems addObject:item];
					}
				}
				if ([self.queryParams[key] isKindOfClass:[NSArray class]]) {
					NSString *value = [self.queryParams[key] componentsJoinedByString:@","];
					NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:value];
					[queryItems addObject:item];
				}
			}
			if (components.queryItems) {
				for (NSURLQueryItem *queryParam in components.queryItems) {
					[queryItems addObject:queryParam];
				}
			}
			components.queryItems = [queryItems copy];
		}
		result = components.URL.absoluteString;
	}
	return result;
}

- (NSMutableURLRequest *)createRequestWithtError:(NSError *__autoreleasing *)error;
{
	NSString *urlString = [self urlString];

	NSURL *url = [NSURL URLWithString:urlString];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

	for (NSString *headerKey in self.aditionalHeaders.allKeys) {
		[request addValue:self.aditionalHeaders[headerKey] forHTTPHeaderField:headerKey];
	}

	if (self.userAgent) {
		[request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
	}

	if ([self methodString]) {
		[request setHTTPMethod:[self methodString]];
	}

	uint64_t contentLength = [self contentLength];
	if (contentLength > 0) {
		[request setValue:[NSString stringWithFormat:@"%llu", contentLength] forHTTPHeaderField:@"Content-Length"];
	}

	NSData *myBody = [self body];
	if (myBody) {
		[request setHTTPBody:myBody];
	}

	if (self.timeoutInterval > 0) {
		request.timeoutInterval = self.timeoutInterval;
	}

	if (self.cachePolicy) {
		request.cachePolicy = self.cachePolicy;
	}

	return request;
}

- (uint64_t)contentLength
{
	return [self.body length];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
	MLNetworkingConfiguration *copyConfiguration = [[self class] allocWithZone:zone];

	copyConfiguration.cachePolicy = self.cachePolicy;
	copyConfiguration.requestType = self.requestType;
	copyConfiguration.sessionType = self.sessionType;
	copyConfiguration.httpMethod = self.httpMethod;
	copyConfiguration.baseURLString = self.baseURLString;
	copyConfiguration.path = self.path;
	copyConfiguration.queryParams = [self.queryParams copy];
	copyConfiguration.aditionalHeaders = [self.aditionalHeaders copy];
	copyConfiguration.userAgent = self.userAgent;
	copyConfiguration.timeoutInterval = self.timeoutInterval;

	// I do not copy because it is very heavy
	copyConfiguration.body = self.body;
	copyConfiguration.resumeData = self.resumeData;

	return copyConfiguration;
}

- (NSArray <NSURLQueryItem *> *)verifyQueryParamsOnPath:(NSString *)path
{
	NSURLComponents *urlWithQueryParams = [NSURLComponents componentsWithString:path];
	if (urlWithQueryParams.queryItems) {
		self.path = urlWithQueryParams.path;
		return urlWithQueryParams.queryItems;
	}

	return nil;
}

@end
