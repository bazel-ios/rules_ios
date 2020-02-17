//
// MLAccessTokenEnvelope+Dictionary.m
// MLAuthentication
//
// Created by FEDERICO VENTRE on 18/01/2019.
//

#import "MLAccessTokenEnvelope+MLDictionary.h"
#import <MLCommons/NSDictionary+Null.h>

@implementation MLAccessTokenEnvelope (Dictionary)

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (self) {
		self.accessToken = [dictionary ml_objectForKey:@"access_token"];
		self.keychainId = [dictionary ml_objectForKey:@"keychain_id"];
		self.clientId = [dictionary ml_objectForKey:@"client_id"];
	}
	return self;
}

@end
