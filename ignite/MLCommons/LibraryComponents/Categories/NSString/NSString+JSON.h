//
// NSString+JSON.h
// MLCommons
//
// Created by William Mora on 13/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

/**
 *  Parses the receiver as a text representation of JSON data with UTF-8 encoding, returning an NSDictionary or an NSArray object, according to the JSON format being parsed.
 *
 *  @return an NSDictionary for JSON objects or an NSArray for JSON arrays
 */
- (id)ml_JSONValue;
@end
