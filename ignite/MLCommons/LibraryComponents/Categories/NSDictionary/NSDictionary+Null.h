//
// NSDictionary+Null.h
// MLCommons
//
// Created by William Mora on 13/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary <__covariant KeyType, __covariant ObjectType> (Null)

/**
 *  Returns the value associated with the given key with extra verifications for nil values
 *
 *  @param key key of value to be evaluated
 *
 *  @return nil for all nil, NSNull, and empty NSString objects; otherwise the value associated with the key
 */
- (_Nullable ObjectType)ml_objectForKey:(nonnull id)key;

/**
 *  Returns a disctionary without nil values
 *
 *  @return nonnull Dictionary
 */
- (nonnull NSDictionary *)ml_dictionaryByRemovingNullValues;

/**
 * @return  the value associated with the key if it is kind of NSDictionary
 */
- (nullable NSDictionary *)ml_dictionaryForKey:(nonnull id)key;

/**
 * @return  the value associated with the key if it is kind of NSArray
 */
- (nullable NSArray *)ml_arrayForKey:(nonnull id)key;

/**
 * @return  the NSURL value associated with the key if it is kind of NSString
 */
- (nullable NSURL *)ml_URLForKey:(nonnull id)key;

/**
 * @return  the value associated with the key if it is kind of NSString or NSNumber (transformed into string)
 */
- (nullable NSString *)ml_stringForKey:(nonnull id)key;

/**
 * @return  the value associated with the key if it is kind of NSNumber or NSString (if it is a valid string number)
 */
- (nullable NSNumber *)ml_numberForKey:(nonnull id)key;

/**
   @return BOOL value for @param key or default value 'NO'
 */
- (BOOL)ml_boolForKey:(nonnull id)key;

/**
   @return BOOL value for key or defaultValue if object for key is nil or not a boolean
 */
- (BOOL)ml_boolForKey:(nonnull id)key defaultValue:(BOOL)defaultValue;

@end
