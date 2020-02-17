//
// MLRestClientAppTokenAuthenticationOperation.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/24/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLRestClientAppTokenAuthenticationOperation.h"
#import <MLAuthentication/MLAppAuthenticationManager.h>
#import "MLRestClientAuthenticationOperation_Protected.h"

@implementation MLRestClientAppTokenAuthenticationOperation

- (instancetype)initWithAppId:(NSString *)appId
                 andAppSecret:(NSString *)appSecret
{
	self = [super initWithAppId:appId authenticationMode:MLRestClientAuthenticationAppAuth];
	if (self) {
		NSAssert(appId.length > 0, @"AppSecret can not be nil or empty.");
		_appSecret = [appSecret copy];
	}
	return self;
}

- (void)startOauthProcess
{
	__weak typeof(self) weakSelf = self;

	[[MLAppAuthenticationManager sharedInstance] createAppTokenWithAppId:self.appId
	                                                           appSecret:self.appSecret
	                                                             success: ^(NSString *appToken) {
	    weakSelf.accessToken = appToken;
	    [weakSelf finishOperation];
	}
	                                                             failure: ^(MLAppAuthenticationManagerError error) {
	    [weakSelf cancelOperation];
	}];
}

@end
