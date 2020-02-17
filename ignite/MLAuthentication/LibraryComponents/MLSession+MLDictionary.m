//
// MLSession+Dictionary.m
// MLAuthentication
//
// Created by FEDERICO VENTRE on 17/01/2019.
//

#import "MLSession+MLDictionary.h"
#import <MLCommons/NSDictionary+Null.h>

@implementation MLSession (Dictionary)

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (self) {
		// Se realizan estas validaciones porque en keychain se almacenan con key diferente a las que
		// vienen del servidor.
		if ([dictionary ml_objectForKey:@"accessToken"]) {
			self.accessToken = [dictionary ml_objectForKey:@"accessToken"];
		} else {
			self.accessToken = [dictionary ml_objectForKey:@"access_token"];
		}

		if ([dictionary ml_objectForKey:@"deviceProfileId"]) {
			self.deviceProfileId = [dictionary ml_objectForKey:@"deviceProfileId"];
		} else {
			self.deviceProfileId = [dictionary ml_objectForKey:@"device_profile_id"];
		}

		if ([dictionary ml_objectForKey:@"lastDayActive"]) {
			NSString *dateString = [dictionary ml_objectForKey:@"lastDayActive"];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"dd-MM-yyyy hh:mma"];
			self.lastDayActive = [dateFormatter dateFromString:dateString];
		} else {
			self.lastDayActive = [NSDate date];
		}
		if ([dictionary ml_objectForKey:@"authenticated_user"]) {
			NSDictionary *authenticatedUser = [dictionary ml_objectForKey:@"authenticated_user"];
			self.userId = [[authenticatedUser ml_objectForKey:@"id"] stringValue];
			self.nickname = [authenticatedUser ml_objectForKey:@"nickname"];
			self.siteId = [authenticatedUser ml_objectForKey:@"site_id"];
			self.firstName = [authenticatedUser ml_objectForKey:@"first_name"];
			self.lastName = [authenticatedUser ml_objectForKey:@"last_name"];
			self.email = [authenticatedUser ml_objectForKey:@"email"];
		} else {
			self.userId = [dictionary ml_objectForKey:@"userId"];
			self.nickname = [dictionary ml_objectForKey:@"nickname"];
			self.siteId = [dictionary ml_objectForKey:@"siteId"];
			self.firstName = [dictionary ml_objectForKey:@"firstName"];
			self.lastName = [dictionary ml_objectForKey:@"lastName"];
			self.email = [dictionary ml_objectForKey:@"email"];
		}
		if ([dictionary ml_objectForKey:@"scopes"]) {
			self.scopes = [dictionary ml_objectForKey:@"scopes"];
		}

		if ([dictionary ml_objectForKey:@"access_token_envelopes"]) {
			self.accessTokenEnvelopes = [dictionary ml_objectForKey:@"access_token_envelopes"];
		}
	}

	return self;
}

@end
