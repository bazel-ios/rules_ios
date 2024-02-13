//
//  IAInterfaceAllocBlocker.h
//  IASDKCore
//
//  Created by Digital Turbine on 22/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#ifndef IAInterfaceAllocBlocker_h
#define IAInterfaceAllocBlocker_h

#import <Foundation/Foundation.h>

@protocol IAInterfaceAllocBlocker <NSObject>

@required
+ (null_unspecified instancetype)alloc __attribute__((unavailable("'alloc' is not available, use 'build:' instead.")));
// Causes error during building in xcode 12.5
//- (null_unspecified instancetype)init __attribute__((unavailable("'init' is not available, use 'build:' instead.")));
+ (null_unspecified instancetype)new __attribute__((unavailable("'new' is not available, use 'build:' instead.")));

@end

#endif /* IAInterfaceAllocBlocker_h */
