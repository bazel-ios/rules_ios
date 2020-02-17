//
// NSArray.h
// Pods
//
// Created by ITAY BRENNER WERTHEIN on 2/9/17.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Null)

/**
 *  Returns an array without nil values
 *
 *  @return nonnull Array
 */
- (nonnull NSArray *)ml_arrayByRemovingNullValues;

@end
