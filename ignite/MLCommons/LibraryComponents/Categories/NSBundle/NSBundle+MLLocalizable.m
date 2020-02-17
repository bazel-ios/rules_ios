//
// NSBundle+MLLocalizable.m
// MeliSDK
// Created by Mauricio Minestrelli on 05/03/16.
// Copyright (c) 2016 Mercadolibre. All rights reserved.
//

#import "NSBundle+MLLocalizable.h"
#import <objc/runtime.h>

static char kMLLocalizableLanguageBundle;
static char kMLLocalizableCountryBundle;
static NSString *const kMLLocalizableStringNotFound = @"com.mercadolibre.melisdk.MLLocalizableStringNotFound";
static NSString *mainBundleLanguage = nil;

@interface MLBundleEx : NSBundle
@end

@implementation MLBundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
	NSBundle *languageBundle = objc_getAssociatedObject(self, &kMLLocalizableLanguageBundle);
	NSBundle *countryBundle = objc_getAssociatedObject(self, &kMLLocalizableCountryBundle);

	if (languageBundle == nil && countryBundle == nil) {
		return [super localizedStringForKey:key value:value table:tableName];
	}

	NSString *string = [countryBundle localizedStringForKey:key value:kMLLocalizableStringNotFound table:tableName];

	if (string == nil || [string isEqualToString:kMLLocalizableStringNotFound]) {
		string = [languageBundle localizedStringForKey:key value:value table:tableName];
	}
	return string;
}

@end

@implementation NSBundle (MLLocalizable)

+ (void)ml_setLanguage:(NSString *)locale
{
	mainBundleLanguage = locale;
	if (mainBundleLanguage.length <= 0) {
		return;
	}

	NSBundle *countryBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:mainBundleLanguage ofType:@"lproj"]];
	NSBundle *languageBundle = nil;

	NSString *language = [mainBundleLanguage componentsSeparatedByString:@"-"].firstObject;
	if (language.length > 0) {
		languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]];
	}

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		object_setClass([NSBundle mainBundle], [MLBundleEx class]);
	});
	objc_setAssociatedObject([NSBundle mainBundle], &kMLLocalizableLanguageBundle, languageBundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject([NSBundle mainBundle], &kMLLocalizableCountryBundle, countryBundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *)ml_localizedString:(NSString *)key fromTable:(NSString *)tableName inBundleWithName:(NSString *)bundleName
{
	if (key == nil) {
		return key;
	}
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
	return [NSBundle ml_localizedString:key fromTable:tableName inBundle:bundle];
}

+ (NSString *)ml_localizedString:(NSString *)key fromTable:(NSString *)tableName inBundle:(NSBundle *)bundle
{
	if (bundle == nil) {
		return key;
	}

	NSBundle *languageBundle = nil;
	NSBundle *countryBundle = nil;

	if (mainBundleLanguage.length > 0) {
		countryBundle = [NSBundle bundleWithPath:[bundle pathForResource:mainBundleLanguage ofType:@"lproj"]];
	}

	NSString *language = [mainBundleLanguage componentsSeparatedByString:@"-"].firstObject;
	if (language.length > 0) {
		languageBundle = [NSBundle bundleWithPath:[bundle pathForResource:language ofType:@"lproj"]];
	}

	NSString *string;
	if (languageBundle == nil && countryBundle == nil) {
		string = [bundle localizedStringForKey:key value:nil table:tableName];
	} else {
		string = [countryBundle localizedStringForKey:key value:kMLLocalizableStringNotFound table:tableName];

		if (string == nil || [string isEqualToString:kMLLocalizableStringNotFound]) {
			string = [languageBundle localizedStringForKey:key value:nil table:tableName];
		}
	}

	return string ? string : key;
}

@end
