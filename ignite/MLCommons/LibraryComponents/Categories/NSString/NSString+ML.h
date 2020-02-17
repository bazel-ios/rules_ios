//
// NSString+ML.h
// MLCommons
//
// Created by matias servetto on 10/12/17.
// Copyright © 2017 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ML)

- (BOOL)ml_isEqualToStringIgnoringCase:(nullable NSString *)aString;

/**
 * Checks if string is empty after triming by [NSCharacterSet whitespaceCharacterSet]
 */
- (BOOL)ml_isTrimmedEmpty;

/**
 * Checks if string is not empty after triming by [NSCharacterSet whitespaceCharacterSet]
 */
- (BOOL)ml_isNotTrimmedEmpty;

@end
