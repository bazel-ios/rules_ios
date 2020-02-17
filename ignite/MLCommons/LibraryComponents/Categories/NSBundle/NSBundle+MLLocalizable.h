//
// NSBundle+MLLocalizable.h
// MeliSDK
// Created by Mauricio Minestrelli on 05/03/16.
// Copyright (c) 2016 Mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (MLLocalizable)

/**
   @brief This method sets the language for the main bundle.

   @param locale Site locale
 */
+ (void)ml_setLanguage:(NSString *)locale;

/*!
 *  @brief This method searchs for the correspondant bundle language folder according to the site's language
 *
 *  @param key The key for a string in the table identified by tableName.
 *  @param tableName The receiver’s string table to search. If tableName is nil or is an empty string.
 *  @param bundleName Name of the package to which the table belongs
 *
 *  @return A localized version of the string designated by key in table tableName from bundleName.
 */
+ (NSString *)ml_localizedString:(NSString *)key fromTable:(NSString *)tableName inBundleWithName:(NSString *)bundleName;

/*!
 *  @brief This method searchs for the correspondant bundle language folder according to the site's language
 *
 *  @param key The key for a string in the table identified by tableName.
 *  @param tableName The receiver’s string table to search. If tableName is nil or is an empty string.
 *  @param bundle Bundle to serch tableName string file.
 *
 *  @return A localized version of the string designated by key in table tableName from bundleName or the
 *          key if not localized found
 */
+ (NSString *)ml_localizedString:(NSString *)key fromTable:(NSString *)tableName inBundle:(NSBundle *)bundle;

@end
