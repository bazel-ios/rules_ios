//
// MLAccessTokenEnvelope.m
// Bugsnag
//
// Created by FEDERICO VENTRE on 16/01/2019.
//

#import "MLAccessTokenEnvelope.h"

@implementation MLAccessTokenEnvelope

- (BOOL)isAccessTokenEnvelopValid
{
	return self.accessToken && self.keychainId;
}

@end
