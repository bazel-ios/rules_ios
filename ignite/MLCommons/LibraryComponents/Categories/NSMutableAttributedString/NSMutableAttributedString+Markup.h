//
// NSMutableAttributedString+Markup.h
// MLCommons
//
// Created by Nicolas Andres Suarez on 16/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Key that represent a base style for the whole string
 */
OBJC_EXTERN NSString *const MLAttributedStringDefault;

/**
 *  Error domain to identify errors from this category
 */
OBJC_EXTERN NSString *const MLAttributedStringErrorDomain;

/**
 *  Error codes
 */
typedef NS_ENUM (NSInteger, MLAttributedStringErrorCode) {
	MLAttributedStringSyntaxErrorCode = 1
};

@interface NSMutableAttributedString (Markup)

/**
 *  Returns an NSMutableAttributedString styled using custom tags like html.
 *
 *  Example:
 *  NSString *markupText = @"This is a <bold>bold text</bold>";
 *  NSDictionary *style = @{@"bold" : @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]}};
 *	NSMutableAttributedString *target = [NSMutableAttributedString ml_attributedStringWithMarkupText:markupText andAttributes:style error:nil];
 *
 *  @param text       An NSString containing text with markup format. Example: @"It is a <bold>text</bold>".
 *  @param attributes A NSDictionary whose keys should be tags name and values should be a dictionary mapping attribute
 *                    names to attribute values.
 *                    You may provide a style with a default key (MLAttributedStringDefault). The associated attributes will provide
 *                    a base style for the whole string, as if you had enclosed your markup in with <default></default>.
 *  @param error      If an error occurs parsing the text, a NSError object is seted.
 *
 *  @return NSMutableAttributedString styled or nil if an error occured.
 */
+ (NSMutableAttributedString *)ml_attributedStringWithMarkupText:(NSString *)text andAttributes:(NSDictionary *)attributes error:(NSError **)error;

@end
