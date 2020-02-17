//
// NSObject+MLAs.h
// MLCommons
//
// Created by Konstantin Portnov on 28/03/17.
// Copyright (c) 2017 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MLAs)

/**
 *  Verifies is self `isKindOfClass:` passed as argument
 *
 *  @return id _Nullable which is self if self `isKindOfClass:` passed as argument and `nil` otherwise
 */
- (id _Nullable)ml_asKindOf:(_Nonnull Class)aClass;

/**
 *  Verifies is self `isKindOfClass:` `NSArray`
 *
 *  @return id _Nullable which is self if self `isKindOfClass:` `NSArray` and `nil` otherwise
 */
- (NSArray *_Nullable)ml_asArray;

/**
 *  Verifies is self `isKindOfClass:` `NSDictionary`
 *
 *  @return id _Nullable which is self if self `isKindOfClass:` `NSDictionary` and `nil` otherwise
 */
- (NSDictionary *_Nullable)ml_asDictionary;

@end
