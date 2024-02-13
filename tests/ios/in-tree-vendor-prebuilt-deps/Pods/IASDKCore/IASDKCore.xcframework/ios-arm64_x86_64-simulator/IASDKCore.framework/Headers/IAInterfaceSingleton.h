//
//  IAInterfaceSingleton.h
//  IASDKCore
//
//  Created by Digital Turbine on 22/03/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#ifndef IAInterfaceSingleton_h
#define IAInterfaceSingleton_h

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceAllocBlocker.h>

@protocol IAInterfaceSingleton <IAInterfaceAllocBlocker>

@required
+ (instancetype _Nonnull)sharedInstance;

@end

#endif /* IAInterfaceSingleton_h */
