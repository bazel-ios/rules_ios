//
//  IASDKCore.h
//  IASDKCore
//
//  Created by Digital Turbine on 02/02/2017.
//  Copyright © 2022 Digital Turbine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceSingleton.h>

@interface IASDKMRAID : NSObject <IAInterfaceSingleton>

/**
 *  @brief Singleton method, use for any instance call.
 */
+ (instancetype)sharedInstance;

@end
