//
// NSLayoutConstraint+Collapse.h
// MLCommons
//
// Created by Martin Heras on 10/12/14.
// Copyright (c) 2014 Martin Heras. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Collapse)

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *parents;

@property (nonatomic, assign, getter = isCollapsed) BOOL collapsed;

/**
 *  Collapsa un array de constraints
 *
 *  @param constraints constraints a colapsar
 *  @param collapse    YES para colapsar
 */
+ (void)ml_collapseConstraints:(NSArray *)constraints collapse:(BOOL)collapse;

@end
