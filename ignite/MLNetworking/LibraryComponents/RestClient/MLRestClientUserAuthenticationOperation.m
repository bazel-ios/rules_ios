//
// MLRestClientUserAuthenticationOperation.m
// MLNetworking
//
// Created by Fabian Celdeiro on 12/16/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import "MLRestClientUserAuthenticationOperation.h"
#import "MLRestClientAuthenticationOperation_Protected.h"
#import "MLRestClientManager.h"
#import <MLAuthentication/MLAuthenticationManager.h>
#import "MLRestClientNotificationsNames.h"

@implementation MLRestClientUserAuthenticationOperation

- (instancetype)initWithAppId:(NSString *)appId
           authenticationMode:(MLRestClientAuthenticationMode)authMode
{
	return [super initWithAppId:appId authenticationMode:authMode];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startOauthProcess
{
	MLSession *session = [[MLAuthenticationManager sharedInstance] getSession];

	if (session) {
		[self sessionObtained:session];
	} else if (self.authMode == MLRestClientAuthenticationUserMustLogin) {
		[self authenticate];
	} else if (self.authMode == MLRestClientAuthenticationUserOptional) {
		[self finishOperation];
	} else {
		[self cancelOperation];
	}
}

- (void)authenticate
{
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(loginEndedWithNotification:)
	                                             name:MLRestClientLoginEndedNotification
	                                           object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(loginCancelledWithNotification:)
	                                             name:MLRestClientLoginCanceledNotification
	                                           object:nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:MLRestClientNeedsLoginNotification
	                                                    object:nil];
}

- (void)loginEndedWithNotification:(NSNotification *)notification
{
	MLSession *session = [[MLAuthenticationManager sharedInstance] getSession];
	if (session) {
		[self sessionObtained:session];
	} else {
		[self authenticate];
	}
}

- (void)loginCancelledWithNotification:(NSNotification *)notification
{
	[self cancelOperation];
}

- (void)sessionObtained:(MLSession *)session
{
	self.accessToken = session.accessToken;
	[self finishOperation];
}

@end
