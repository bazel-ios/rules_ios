//
// MLKeychain.m
// KeyChain
//
// Created by KH1386 on 3/10/14.
// Copyright (c) 2014 KH1386. All rights reserved.
//

#import <MLAuthentication/MLKeychain.h>
#import <Security/Security.h>

@implementation MLKeychain

- (id)initWithService:(NSString *)service_ withGroup:(NSString *)group_
{
	self = [super init];
	if (self) {
		service = [NSString stringWithString:service_];

#if defined(MDS_CUSTOM) || defined(MDS_NIGHTLY)
#else
		if (group_) {
			group = [NSString stringWithString:group_];
		}
#endif
	}

	return self;
}

- (NSMutableDictionary *)prepareDict:(NSString *)key
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

	NSData *encodedKey = [key dataUsingEncoding:NSUTF8StringEncoding];
	[dict setObject:encodedKey forKey:(__bridge id)kSecAttrGeneric];
	[dict setObject:encodedKey forKey:(__bridge id)kSecAttrAccount];
	[dict setObject:service forKey:(__bridge id)kSecAttrService];
	[dict setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

	// This is for sharing data across apps
	if (group != nil) {
		[dict setObject:group forKey:(__bridge id)kSecAttrAccessGroup];
	}

	return dict;
}

- (BOOL)insert:(NSString *)key data:(NSData *)data
{
	NSMutableDictionary *dict = [self prepareDict:key];
	[dict setObject:data forKey:(__bridge id)kSecValueData];

	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dict, NULL);
	if (errSecSuccess != status) {
		NSLog(@"Unable add item with key =%@ error:%d", key, (int)status);
	}
	return (errSecSuccess == status);
}

- (NSData *)find:(NSString *)key
{
	NSMutableDictionary *dict = [self prepareDict:key];
	[dict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	[dict setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	CFTypeRef result = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dict, &result);

	if (status != errSecSuccess) {
		NSLog(@"Unable to fetch item for key %@ with error:%d", key, (int)status);
		return nil;
	}

	return (__bridge NSData *)result;
}

- (BOOL)update:(NSString *)key data:(NSData *)data
{
	NSMutableDictionary *dictKey = [self prepareDict:key];

	NSMutableDictionary *dictUpdate = [[NSMutableDictionary alloc] init];
	[dictUpdate setObject:data forKey:(__bridge id)kSecValueData];

	OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)dictKey, (__bridge CFDictionaryRef)dictUpdate);
	if (errSecSuccess != status) {
		NSLog(@"Unable add update with key =%@ error:%d", key, (int)status);
	}
	return (errSecSuccess == status);

	return YES;
}

- (BOOL)remove:(NSString *)key
{
	NSMutableDictionary *dict = [self prepareDict:key];
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dict);
	if (status != errSecSuccess) {
		NSLog(@"Unable to remove item for key %@ with error:%d", key, (int)status);
		return NO;
	}
	return YES;
}

@end
