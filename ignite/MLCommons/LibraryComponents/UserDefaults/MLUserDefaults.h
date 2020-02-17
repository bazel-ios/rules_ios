//
// MLUserDefaults.h
// MLCommons
//
// Created by William Mora on 10/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  The MLUserDefaults class provides a programmatic interface for interacting with the defaults system used by the MercadoLibre app.
 *  The defaults system in MercadoLibre is divided by groups that are set by each subclass of this class.
 *  Each subclass defines an identifier through the -initWithIdentifier: constructor which is used to save all its values as a group.
 *
 *  Note that you MUST subclass this.
 */
@interface MLUserDefaults : NSObject

/**
 *  Returns an MLUserDefaults object with the defaults for the group set by the subclass calling this
 *
 *  @param identifier the group identifier (ex: "vip", "search")
 *
 *  @return an MLUserDefaults object initialized with the defaults for this group
 */
- (id)initWithIdentifier:(NSString *)identifier;

/**
 *  Returns the array associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The array associated with the specified key, or nil if the key does not exist or its value is not an NSArray object.
 */
- (NSArray *)arrayForKey:(NSString *)defaultName;

/**
 *  Returns the Boolean value associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return If a boolean value is associated with defaultName in the user defaults, that value is returned. Otherwise, NO is returned.
 */
- (BOOL)boolForKey:(NSString *)defaultName;

/**
 *  Returns the data object associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The data object associated with the specified key, or nil if the key does not exist or its value is not an NSData object.
 */
- (NSData *)dataForKey:(NSString *)defaultName;

/**
 *  Returns the dictionary object associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The dictionary object associated with the specified key, or nil if the key does not exist or its value is not an NSDictionary object.
 */
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;

/**
 *  Returns the floating-point value associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The floating-point value associated with the specified key. If the key does not exist, this method returns 0.
 */
- (float)floatForKey:(NSString *)defaultName;

/**
 *  Returns the integer value associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The integer value associated with the specified key. If the specified key does not exist, this method returns 0.
 */
- (NSInteger)integerForKey:(NSString *)defaultName;

/**
 *  Returns the object associated with the first occurrence of the specified default.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The object associated with the specified key, or nil if the key was not found.
 */
- (id)objectForKey:(NSString *)defaultName;

/**
 *  Returns the array of strings associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The array of NSString objects, or nil if the specified default does not exist, the default does not contain an array, or the array does not contain NSString objects.
 */
- (NSArray *)stringArrayForKey:(NSString *)defaultName;

/**
 *  Returns the string associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return For string values, the string associated with the specified key. For number values, the string value of the number. Returns nil if the default does not exist or is not a string or number value.
 */
- (NSString *)stringForKey:(NSString *)defaultName;

/**
 *  Returns the double value associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The double value associated with the specified key. If the key does not exist, this method returns 0.
 */
- (double)doubleForKey:(NSString *)defaultName;

/**
 *  Returns the NSURL instance associated with the specified key.
 *
 *  @param defaultName A key in the current user's defaults group.
 *
 *  @return The NSURL instance value associated with the specified key. If the key does not exist, this method returns nil.
 */
- (NSURL *)URLForKey:(NSString *)defaultName;

/**
 *  Sets the value of the specified default key to the specified Boolean value.
 *
 *  @param value       The Boolean value to store in the defaults database.
 *  @param defaultName The key with which to associate with the value.
 */
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

/**
 *  Sets the value of the specified default key to the specified floating-point value.
 *
 *  @param value       The floating-point value to store in the defaults database.
 *  @param defaultName The key with which to associate with the value.
 */
- (void)setFloat:(float)value forKey:(NSString *)defaultName;

/**
 *  Sets the value of the specified default key to the specified integer value.
 *
 *  @param value       The integer value to store in the defaults database.
 *  @param defaultName The key with which to associate with the value.
 */
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;

/**
 *  Sets the value of the specified default key in the standard application domain. The value parameter can be only property
 *  list objects: NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary. For NSArray and NSDictionary objects, their
 *  contents must be property list objects.
 *
 *  @param value       The object to store in the defaults database.
 *  @param defaultName The key with which to associate with the value.
 */
- (void)setObject:(id)value forKey:(NSString *)defaultName;

/**
 *  Sets the value of the specified default key to the double value.
 *
 *  @param value       The double value.
 *  @param defaultName The key with which to associate with the value.
 */
- (void)setDouble:(double)value forKey:(NSString *)defaultName;

/**
 *  Sets the value of the specified default key to the specified URL.
 *
 *  @param url         The NSURL to store in the defaults database.
 *  @param defaultName The key with which to associate with the value.
 */
- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName;

/**
 *  Removes the value of the specified default key in the standard application domain.
 *
 *  @param defaultName The key whose value you want to remove.
 */
- (void)removeObjectForKey:(NSString *)defaultName;

/**
 *  Writes any modifications to the persistent domains to disk and updates all unmodified persistent domains to what is on disk.
 *  Use this method only if you cannot wait for the automatic synchronization (for example, if your application is about to exit)
 *  or if you want to update the user defaults to what is on disk even though you have not made any changes.
 *
 *  @return YES if the data was saved successfully to disk, otherwise NO.
 */
- (BOOL)synchronize;

@end
