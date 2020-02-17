//
// MLLocationUserDefaults.h
// MLCommons
//
// Created by Mauricio Minestrelli on 11/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLUserDefaults.h"
NS_ASSUME_NONNULL_BEGIN
/** Identifier for the MLLocation user defaults group */
extern NSString *const kLocationDefaultName;

@interface MLLocationUserDefaults : MLUserDefaults

- (id)init __attribute__((unavailable("Cannot use init for this class, use +(MLLocationUserDefaults*)sharedInstance instead")));

/** Returns the singleton instance of this class. */
+ (MLLocationUserDefaults *)locationUserDefaults;
@end
NS_ASSUME_NONNULL_END
