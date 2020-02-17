//
// NSMutableDictionary.h
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 11/25/16.
//
//

#import <UIKit/UIKit.h>

@interface NSMutableDictionary <KeyType, ObjectType> (Null)

/**
 *  Set the value associated with the given key with extra verifications for nil values
 *
 *  @param value variable a ser insertada en el Diccionario
 *  @param key key a ser insertada en el Diccionario
 */
- (void)ml_setObject:(nullable ObjectType)value forKey:(nullable KeyType <NSCopying>)key;

/**
 *  Set the value associated with the given key with default value for nil values
 *
 *  @param value variable a ser insertada en el Diccionario
 *  @param key key a ser insertada en el Diccionario
 *  @param defaultValue valor a insertar en caso de ser nil
 */
- (void)ml_setObject:(nullable ObjectType)value forKey:(nullable KeyType <NSCopying>)key default:(nullable ObjectType)defaultValue;

@end
