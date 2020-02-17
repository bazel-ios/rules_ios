//
// MLSession.m
// Authentication
//
// Created by Christian Perez Biancucci on 2/10/15.
// Copyright (c) 2015 MercadoLibre S.A. All rights reserved.
//

#import <MLAuthentication/MLSession.h>
#import "MLAccessTokenEnvelope+MLDictionary.h"

@implementation MLSession

- (BOOL)isSessionValid
{
	return self.accessToken && self.nickname && self.userId && [self isAccessTokenEnvelopesValid];
}

- (BOOL)isAccessTokenEnvelopesValid
{
	BOOL accessTokenEvelopesValid = YES;
	if (self.accessTokenEnvelopes) {
		if (self.accessTokenEnvelopes.count > 0) {
			for (int i = 0; i < self.accessTokenEnvelopes.count; i++) {
				if (!([[[MLAccessTokenEnvelope alloc] initWithDictionary:self.accessTokenEnvelopes[i]] isAccessTokenEnvelopValid])) {
					return NO;
				}
			}
		} else {
			accessTokenEvelopesValid = NO;
		}
	}

	return accessTokenEvelopesValid;
}

@end
