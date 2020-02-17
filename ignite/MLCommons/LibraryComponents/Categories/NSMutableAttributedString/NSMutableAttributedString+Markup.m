//
// NSMutableAttributedString+Markup.m
// MLCommons
//
// Created by Nicolas Andres Suarez on 16/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "NSMutableAttributedString+Markup.h"

NSString *const MLAttributedStringDefault = @"default";
NSString *const MLAttributedStringErrorDomain = @"com.mercadolibre.commons.attributedstring";

@implementation NSMutableAttributedString (Markup)

+ (NSMutableAttributedString *)ml_attributedStringWithMarkupText:(NSString *)text andAttributes:(NSDictionary *)attributes error:(NSError **)error
{
	NSAssert(text, @"text shouldn't be nil");
	NSAssert(attributes, @"attributes shouldn't be nil");

	// Este attribute con el que se inicializa el attributesString es por un bug que hay en iOS 8 que no permite que un string tenga un strikeThrough en el texto a menos que sea de comienzo a fin. No afecta al string que sale como resultado final ya que es un tachado de ancho 0.
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleNone)}];

	BOOL success = [attributedString ml_addMarkupAttributes:attributes error:error];
	return success ? attributedString : nil;
}

- (BOOL)ml_addMarkupAttributes:(NSDictionary *)attributes error:(NSError **)error
{
    NSArray *tags = [attributes allKeys];

    // Apply deafult attributes if are present
    if ([attributes objectForKey:MLAttributedStringDefault]) {
        [self addAttributes:attributes[MLAttributedStringDefault] range:NSMakeRange(0, self.string.length)];
        tags = [tags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", MLAttributedStringDefault]];
	}

    for (NSString *tagName in tags) {
        NSString *openTag = [NSString stringWithFormat:@"<%@>", tagName];
        NSString *closeTag = [NSString stringWithFormat:@"</%@>", tagName];

        // Search tag's location
        NSRange openTagRange = [self.string rangeOfString:openTag];
        NSRange closeTagRange = [self.string rangeOfString:closeTag];

        do {
            if (openTagRange.location == NSNotFound && closeTagRange.location != NSNotFound) {
                if (error) {
                    *error = [NSError errorWithDomain:MLAttributedStringErrorDomain
                                                 code:MLAttributedStringSyntaxErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Open tag not found: %@", openTag]}];
				}
                return NO;
			} else if (openTagRange.location != NSNotFound && closeTagRange.location == NSNotFound) {
                if (error) {
                    *error = [NSError errorWithDomain:MLAttributedStringErrorDomain
                                                 code:MLAttributedStringSyntaxErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Close tag not found: %@", closeTag]}];
				}
                return NO;
			} else if (openTagRange.location != NSNotFound && closeTagRange.location != NSNotFound) {
                // Apply attributes
                [self addAttributes:attributes[tagName]
                              range:NSMakeRange(openTagRange.location, closeTagRange.location - openTagRange.location)];

                // Remove tag from text
                [self deleteCharactersInRange:NSMakeRange(closeTagRange.location, closeTag.length)];
                [self deleteCharactersInRange:NSMakeRange(openTagRange.location, openTag.length)];

                // Search if the current tag is still present
                openTagRange = [self.string rangeOfString:openTag];
                closeTagRange = [self.string rangeOfString:closeTag];
			}
		} while (openTagRange.location != NSNotFound && openTagRange.location != NSNotFound);
	}
    return YES;
}

@end
