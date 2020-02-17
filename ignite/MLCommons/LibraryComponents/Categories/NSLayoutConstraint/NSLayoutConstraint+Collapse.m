//
// NSLayoutConstraint+Collapse.m
// MLCommons
//
// Created by Martin Heras on 10/12/14.
// Copyright (c) 2014 Martin Heras. All rights reserved.
//

#import "NSLayoutConstraint+Collapse.h"
#import <objc/runtime.h>

static NSString *const kMLCommonsLayoutConstraintChildrenKey = @"com.mercadolibre.common.LayoutConstraintChildren";
static NSString *const kMLCommonsLayoutConstraintParentsKey = @"com.mercadolibre.common.LayoutConstraintParents";
static NSString *const kMLCommonsLayoutConstraintOriginalConstantKey = @"com.mercadolibre.common.LayoutConstraintOriginalConstant";
static NSString *const kMLCommonsLayoutConstraintOriginalPriorityKey = @"com.mercadolibre.common.LayoutConstraintOriginalPriority";

@interface NSLayoutConstraint ()

@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) NSNumber *originalConstant;
@property (nonatomic, strong) NSNumber *originalPriority;

@end

@implementation NSLayoutConstraint (MLSearch)

#pragma mark - Internal helper methods

- (NSHashTable *)hashTableFromArray:(NSArray *)array
{
	NSHashTable *hashTable = [NSHashTable weakObjectsHashTable];

	for (id object in array) {
		[hashTable addObject:object];
	}

	return hashTable;
}

- (void)addChild:(NSLayoutConstraint *)child
{
	NSMutableArray *children = [self.children mutableCopy];
	if (!children) {
		children = [[NSMutableArray alloc] init];
	}
	[children addObject:child];
	self.children = children;
}

- (void)notifyParentCollapsedStateChange
{
	BOOL collapsed = YES;
	for (NSLayoutConstraint *parent in self.parents) {
		collapsed &= parent.isCollapsed;
	}
	self.collapsed = collapsed;
}

#pragma mark - Children

- (void)setChildren:(NSArray *)children
{
	objc_setAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintChildrenKey, [self hashTableFromArray:children], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)children
{
	NSHashTable *hashTable = objc_getAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintChildrenKey);
	return [hashTable allObjects];
}

#pragma mark - Parents

- (void)setParents:(NSArray *)parents
{
	objc_setAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintParentsKey, [self hashTableFromArray:parents], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	for (NSLayoutConstraint *parent in parents) {
		[parent addChild:self];
	}
}

- (NSArray *)parents
{
	NSHashTable *hashTable = objc_getAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintParentsKey);
	return [hashTable allObjects];
}

#pragma mark - Original constant

- (NSNumber *)originalConstant
{
	return objc_getAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintOriginalConstantKey);
}

- (void)setOriginalConstant:(NSNumber *)constant
{
	objc_setAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintOriginalConstantKey, constant, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Original priority

- (NSNumber *)originalPriority
{
	return objc_getAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintOriginalPriorityKey);
}

- (void)setOriginalPriority:(NSNumber *)constant
{
	objc_setAssociatedObject(self, (__bridge const void *)kMLCommonsLayoutConstraintOriginalPriorityKey, constant, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Collapsed

- (void)setCollapsed:(BOOL)collapsed
{
	if (collapsed != self.isCollapsed) {
		if (collapsed) {
			self.originalConstant = @(self.constant);
			self.constant = 0.0f;

			// If priority is already set as "required", we don't need anything to do.
			if (self.priority != UILayoutPriorityRequired) {
				self.originalPriority = @(self.priority);
				self.priority = UILayoutPriorityRequired - 1; // iOS does not allow us to change priority from/to "required".
			}
		} else {
			self.constant = [self.originalConstant floatValue];
			self.originalConstant = nil;

			NSNumber *originalPriority = self.originalPriority;
			if (originalPriority != nil) {
				self.priority = [self.originalPriority floatValue];
				self.originalPriority = nil;
			}
		}

		for (NSLayoutConstraint *child in self.children) {
			[child notifyParentCollapsedStateChange];
		}
	}
}

- (BOOL)isCollapsed
{
	return self.originalConstant != nil;
}

+ (void)ml_collapseConstraints:(NSArray *)constraints collapse:(BOOL)collapse
{
	for (NSLayoutConstraint *constraint in constraints) {
		constraint.collapsed = collapse;
	}
}

@end
