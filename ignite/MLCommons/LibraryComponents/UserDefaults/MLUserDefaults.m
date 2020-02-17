//
// MLUserDefaults.m
// MLCommons
//
// Created by William Mora on 10/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLUserDefaults.h"
#import "MLPropertyList.h"

@interface MLUserDefaults ()

@property (nonatomic, copy) NSString *identifier;

@end

@implementation MLUserDefaults

- (id)init
{
	NSAssert(NO, @"-init is not allowed, use -initWithIdentifier: instead");
	return nil;
}

- (id)initWithIdentifier:(NSString *)identifier
{
	[self validateIsSubclass];

	identifier = [[identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];

	if ([identifier length] == 0) {
		NSAssert(NO, @"Identifier cannot be empty or nil");
		return nil;
	}

	self = [super init];
	if (self) {
		self.identifier = identifier;
	}
	return self;
}

- (void)validateIsSubclass
{
	if ([self class] == [MLUserDefaults class]) {
		NSAssert(NO, @"You cannot init this class directly. Instead, use a subclass");
	}
}

- (NSString *)fullUserDefaultKeyForKey:(NSString *)key
{
	key = [[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];

	if ([key length] == 0) {
		NSAssert(NO, @"Key cannot be empty or nil");
		return nil;
	}

	return [NSString stringWithFormat:@"%@_%@", self.identifier, key];
}

#pragma mark - Getting Default Values

- (NSArray *)arrayForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (BOOL)boolForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (NSData *)dataForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] dataForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] dictionaryForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (float)floatForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (NSInteger)integerForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (id)objectForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] stringArrayForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (NSString *)stringForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (double)doubleForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] doubleForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (NSURL *)URLForKey:(NSString *)defaultName
{
	return [[NSUserDefaults standardUserDefaults] URLForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

#pragma mark - Setting Default Values

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName
{
	[[NSUserDefaults standardUserDefaults] setFloat:value forKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
	if (![MLPropertyList isPropertyListValue:value]) {
		NSAssert(NO, @"The value can only be property list objects: NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary");
		return;
	}
	if ([MLPropertyList isIterablePropertyListValue:value] && ![MLPropertyList valueContentIsPropertyList:value]) {
		NSAssert(NO, @"Contents of NSArray and NSDictionary objects must be property list objects");
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName
{
	[[NSUserDefaults standardUserDefaults] setDouble:value forKey:[self fullUserDefaultKeyForKey:defaultName]];
}

- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName
{
	[[NSUserDefaults standardUserDefaults] setURL:url forKey:[self fullUserDefaultKeyForKey:defaultName]];
}

#pragma mark - Removing Defaults

- (void)removeObjectForKey:(NSString *)defaultName
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[self fullUserDefaultKeyForKey:defaultName]];
}

#pragma mark - Maintaining Persistent Domains
- (BOOL)synchronize
{
	return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
