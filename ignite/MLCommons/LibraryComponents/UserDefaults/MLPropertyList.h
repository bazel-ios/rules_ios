//
// MLPropertyList.h
// MLCommons
//
// Created by William Mora on 11/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Property lists are based on an abstraction for expressing simple hierarchies of data. The items of data in a
 *  property list are of a limited number of types. Some types are for primitive values and others are for containers
 *  of values. The primitive types are strings, numbers, binary data, dates, and Boolean values. The containers are
 *  arrays—indexed collections of values—and dictionaries—collections of values each identified by a key. The
 *  containers can contain other containers as well as the primitive types. Thus you might have an array of
 *  dictionaries, and each dictionary might contain other arrays and dictionaries, as well as the primitive types. A
 *  root property-list object is at the top of this hierarchy, and in almost all cases is a dictionary or an array.
 *  Note, however, that a root property-list object does not have to be a dictionary or array; for example, you could
 *  have a single string, number, or date, and that primitive value by itself can constitute a property list.
 */
@interface MLPropertyList : NSObject

/**
 *  Determines if the given object is a property list
 *
 *  @param value the object to be checked if it's a property list
 *
 *  @return YES if the object is a property list type, NO otherwise
 */
+ (BOOL)isPropertyListValue:(id)value;

/**
 *  Determines if a given object is a property list that may be iterated (arrays and dictionaries).
 *
 *  @param value the object to be checked if it's an iterable property list
 *
 *  @return YES if it's an iterable property list, NO otherwise
 */
+ (BOOL)isIterablePropertyListValue:(id)value;

/**
 *  Besides checking if an object is a property list, this method also iterates through all elements of the object
 *  (if it's an iterable property list) checking if they are also property lists
 *
 *  @param value the object to be evaluated
 *
 *  @return YES if the object and all its children are property lists, NO otherwise
 */
+ (BOOL)valueContentIsPropertyList:(id)value;

@end
