//
// NSMutableArray+MLNull.h
// MLCommons
//
// Created by Ezequiel Perez Dittler on 03/01/2018.
// Copyright © 2018 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray <ObjectType> (MLNull)

/**
 *  Add the object with extra verifications for nil values
 *
 *  @param anObject object to add
 */
- (void)ml_addObject:(nullable ObjectType)anObject;

@end
